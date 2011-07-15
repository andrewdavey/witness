# reference "../../lib/jquery.js"
# reference "../Event.coffee"
# reference "../Dsl.coffee"

{ Event, Dsl } = @Witness

@Witness.manifests = {}

@Witness.manifests.Manifest = class Manifest

	constructor: (@specificationDirectory) ->
		@scripts = []
		@statusChanged = new Event()
		@error = new Event()
		@downloadFinished = new Event()

	log: (message) ->
		@statusChanged.raise message

	download: ->
		@log "Downloading manifest"
		jQuery.ajax
			type: "get"
			url: "/_witness/manifest"
			data: { path: @specificationDirectory }
			cache: no
			success: (manifestData) =>
				@downloadManifestSucceeded manifestData
			error: (xhr) => 
				@downloadManifestFailed xhr

	downloadManifestSucceeded: (manifestData) ->
		# manifestData is a directory object
		# directory = { helpers: url string array: file array, directories: directory array }
		# file = { url: string, name: string }

		collectUrls = (directory, urls = []) ->
			for helper in directory.helpers
				urls.push helper
			for file in directory.files
				urls.push file.url
			# Recurse into sub-directories
			for subDirectory in directory.directories
				collectUrls subDirectory, urls
			urls

		allUrls = collectUrls manifestData

		@rootDirectory = manifestData
		@downloadScripts allUrls

	downloadManifestFailed: (xhr) ->
		@error.raise "Manifest download failed. " + xhr.responseText
		@downloadFinished.raise()


	downloadScripts: (urls) ->
		@log "Downloading scripts"
		downloads = (@downloadScript url for url in urls)
		jQuery.when(downloads...).then(
			=> @downloadScriptsSucceeded()
			=> @downloadScriptsFailed()
		)

	downloadScript: (url) ->
		script = @scripts[url] = { url: url }
		# return the deferred object so we can wait for it to resolve.
		jQuery.ajax
			type: "get"
			url: url
			dataType: "text" # Stop jQuery executing the script. We'll be handling that later.
			cache: no
			success: (scriptSource) =>
				script.source = scriptSource
			error: (xhr) =>
				script.error = xhr.responseText

	downloadScriptsSucceeded: ->
		@log "Parsing scripts"
		errors = no
		for url, script of @scripts
			result = @parseScript url, script.source
			if typeof result == "string"
				# parse changed the source (e.g. CoffeeScript -> JavaScript)
				script.source = result
			else if result is no
				errors = yes
			# else the JavaScript parsed - continue to next.

		if errors
			@downloadFinished.raise()
		else
			@evaluateScripts()

	downloadScriptsFailed: ->
		for script in @scripts when script.error?
			@error.raise "Download of #{script.url} failed: #{script.error}"
		@downloadFinished.raise()


	parseScript: (url, source) ->
		if url.match /\.coffee$/
			@parseCoffeeScript url, source
		else
			@parseJavaScript url, source

	parseCoffeeScript: (url, source) ->
		try
			CoffeeScript.compile source
		catch error
			@error.raise "#{url} #{error.message}"
			no

	parseJavaScript: (url, source) ->
		predef = (name for own name of Dsl::)
		predef.push "dsl"
		return yes if JSLINT source, { predef: predef, white: true }

		for error in JSLINT.errors when error?
			@error.raise "#{@url} Line #{error.line}, character #{error.character}: #{error.reason}"
		no
		

	evaluateScripts: ->
		@log "Evaluating scripts"

		@evaluateDirectory @rootDirectory

	evaluateDirectory: (directory, parentHelpers = []) ->
		helpers = parentHelpers.concat directory.helpers

		for subDirectory in directory.directories
			@evaluateDirectory subDirectory, helpers

		for script in directory.files
			@evaluateScript script, helpers

	evaluateScript: (script, helpers) ->
		iframe = jQuery("<iframe src='/_witness/sandbox.htm'/>").hide().appendTo("body")
		iframe.load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			addScript = (script) -> addInlineScript script, iframeDoc
			failed = false
			# Track current helper (if any) so if it throws an exception
			# we can report it's URL. 
			currentHelper = null

			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = =>
				script.specifications = dsl.specifications or []
				@log "#{script.path}: #{script.specifications.length} specifications"

			# Global error handling function for the iframe window
			iframeWindow._witnessScriptError = (args...) =>
				failed = true
				error = args[0]
				if typeof error.stack == "string"
					message = extractRuntimeErrorFromStack error.stack, currentHelper
					@error.raise message
				else
					@error.raise error.message

			dsl = new Dsl iframeWindow
			dsl.activate()
			
			for helper in helpers
				currentHelper = helper
				addScript wrapScript @scripts[helper].source
				break if failed
			currentHelper = null
			addScript wrapScript @scripts[script.url].source if not failed
			addScript "_witnessScriptCompleted();" if not failed

# Wrapping a script in an anonymous function call prevents it accidently
# leaking into global scope. The try..catch should catch any runtime errors.
# For example, calling a function that does not exist.
# The global function _witnessScriptError is added to the window executing
# the script by SpecificationFile below.
wrapScript = (script) ->
	"""
	try {
		(function() {
		#{script}
		}());
	} catch (e) {
		_witnessScriptError(e);
	}
	"""

# In Chrome, error objects have a stack string property.
# Parse this to get the error message and also the line and character
# of the error. This makes for a more useful error message to display.
extractRuntimeErrorFromStack = (stack, helper) ->
	firstLine = stack.match(/^(.*)(:?\r|\n|$)/)[1]
	location = stack.match(/sandbox\.htm:(\d+):(\d+)/)
	
	if location? 
		# line number was offset by 2 in the wrapScript function
		line = parseInt(location[1], 10) - 2
		if helper?
			"#{firstLine}. #{helper.url} at line #{line}, character #{location[2]}."
		else
			"#{firstLine}. Line #{line}, character #{location[2]}."
	else
		firstLine

addInlineScript = (scriptText, iframeDoc) ->
	scriptElement = iframeDoc.createElement "script"
	scriptElement.type = "text/javascript"
	scriptElement.async = false # else some browser seem to execute scripts in non-sequential order!
	
	if scriptElement.textContent == ""
		scriptElement.textContent = scriptText
	else
		scriptElement.innerText = scriptText

	head = iframeDoc.getElementsByTagName("head")[0]
	head.appendChild scriptElement


