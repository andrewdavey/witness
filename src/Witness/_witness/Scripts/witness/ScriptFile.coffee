# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "Event.coffee"
# reference "Dsl.coffee"

{ Event, Dsl, messageBus } = @witness

# A ScriptFile represents either a JavaScript or CoffeeScript file that
# is to be downloaded, parsed and executed.
# It is an abstract base class. Subclasses must provide a scriptDownloaded function.
@witness.ScriptFile = class ScriptFile
	
	constructor: (manifest) ->
		{ @url, @path } = manifest
		@type = if @path.match /\.coffee$/ then "coffee" else "js"
		@on = Event.define "downloading", "downloaded", "downloadFailed"

	download: ->
		@on.downloading.raise()
		jQuery.ajax
			url: @url
			cache: false
			dataType: 'text' # Must be 'text' else jQuery tries to execute the script for us!
			success: (script) =>
				messageBus.send "ScriptDownloading", this
				{ @script, errors} = @parseScript script
				if errors?
					messageBus.send "ScriptDownloadError", this, errors
					@on.downloadFailed.raise errors
					return

				messageBus.send "ScriptDownloaded", this
				@scriptDownloaded()

			error: =>
				errorMessage = "Could not download #{@url}"
				messageBus.send "ScriptDownloadError", this, [ errorMessage ]
				@on.downloadFailed.raise [ errorMessage ]

	scriptDownloaded: (script) ->
		@on.downloaded.raise()

	parseScript: (script) ->
		if @type == "coffee"
			try
				script = CoffeeScript.compile(script)
				# CoffeeScript compile wraps the code in a self-executing function.
				# So no need to wrap it again. Return as-is.
				return script: script
			catch error
				return script: null, errors: [ error ]
		else
			predef = (name for own name of Dsl::)
			predef.push "dsl"
			if not JSLINT script, { predef: predef, white: true }
				buildError = (error) -> { message: "#{@url} Line #{error.line}, character #{error.character}: #{error.reason}" }
				errors = (buildError error for error in JSLINT.errors when error?)
				return script: null, errors: errors
		
			return script: script

	# Wrapping a script in an anonymous function call prevents it accidently
	# leaking into global scope. The try..catch should catch any runtime errors.
	# For example, calling a function that does not exist.
	# The global function _witnessScriptError is added to the window executing
	# the script by SpecificationFile below.
	getWrappedScript: (errorFunctionName) ->
		script = if @type == "js"
			"""
			(function() {
			#{@script}
			}());
			"""
		else
			@script

		"""
		try {
			#{script}
		} catch (e) {
			#{errorFunctionName}(e);
		}
		"""
