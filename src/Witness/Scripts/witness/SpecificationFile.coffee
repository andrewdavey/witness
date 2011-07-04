# reference "Witness.coffee"
# reference "../lib/knockout.js"
# reference "../lib/coffee-script.js"
# reference "Event.coffee"

Witness = this.Witness

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
	
	if iframeDoc.createElement("script").textContent == ""
		scriptElement.textContent = scriptText
	else
		scriptElement.innerText = scriptText

	head = iframeDoc.getElementsByTagName("head")[0]
	head.appendChild scriptElement



Witness.SpecificationFile = class SpecificationFile extends Witness.ScriptFile

	constructor: (manifest, @helpers = []) ->
		super manifest.url
		@name = manifest.name
		@on.ready = new Witness.Event()
		@on.running = new Witness.Event()
		@on.passed = new Witness.Event()
		@on.failed = new Witness.Event()
		@specifications = []

	scriptDownloaded: (script, done, fail) ->
		@executeSpecificationScript script,
			(specs) =>
				@specifications.push spec for spec in specs
				@on.ready.raise()
				done()
			(error) =>
				@errors.push error
				@on.downloadFailed.raise @errors
				fail error

	executeSpecificationScript: (script, gotSpecifications, fail) ->
		iframe = jQuery("<iframe src='sandbox.htm'/>").hide().appendTo("body")
		iframe.load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			addScript = (script) -> addInlineScript script, iframeDoc
			failed = false
			# Track current helper (if any) so if it throws an exception
			# we can report it's URL. 
			currentHelper = null

			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications or []

			# Global error handling function for the iframe window
			iframeWindow._witnessScriptError = (args...) ->
				failed = true
				error = args[0]
				if typeof error.stack == "string"
					message = extractRuntimeErrorFromStack error.stack, currentHelper
					fail.call this, new Error message
				else
					fail.apply this, args

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()
			
			for helper in @helpers
				currentHelper = helper
				addScript wrapScript helper.script
				break if failed
			currentHelper = null
			addScript wrapScript script if not failed
			addScript "_witnessScriptCompleted();" if not failed

	run: (context, done, fail) ->
		Witness.messageBus.send "SpecificationFileRunning", this
		@on.running.raise()
		tryAll = new Witness.TryAll @specifications
		tryAll.run context,
			=>
				Witness.messageBus.send "SpecificationFilePassed", this
				@on.passed.raise()
				done()
			(error) =>
				Witness.messageBus.send "SpecificationFileFailed", this
				@on.failed.raise(error)
				fail(error)
