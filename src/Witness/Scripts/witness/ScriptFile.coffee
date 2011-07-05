# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "Event.coffee"
# reference "Dsl.coffee"

{ Event, messageBus, Dsl } = @Witness

# A ScriptFile represents either a JavaScript or CoffeeScript file that
# is to be downloaded, parsed and executed.
# It is an abstract base class. Subclasses must provide a scriptDownloaded function.
@Witness.ScriptFile = class ScriptFile
	
	constructor: (@url) ->
		@errors = []
		@on = Event.define "downloading", "downloaded", "downloadFailed"

	download: (done = (->), fail = (->)) ->
		@on.downloading.raise()
		@errors = []
		jQuery.ajax
			url: @url
			cache: false
			dataType: 'text' # Must be 'text' else jQuery tries to execute the script for us!
			success: (script) =>
				messageBus.send "ScriptDownloading", this
				script = @parseScript script
				if not script
					messageBus.send "ScriptDownloadError", this, @errors
					@on.downloadFailed.raise @errors
					fail @errors
					return

				messageBus.send "ScriptDownloaded", this
				@on.downloaded.raise()
				@scriptDownloaded script, done, fail

			error: =>
				errorMessage = "Could not download #{@url}"
				@errors.push errorMessage
				messageBus.send "ScriptDownloadError", this, @errors
				@on.downloadFailed.raise @errors
				fail @errors

	parseScript: (script) ->
		if @url.match(/.coffee$/)
			try
				script = CoffeeScript.compile(script)
			catch error
				@errors.push error
				return null
		else
			predef = (name for own name of Dsl::)
			predef.push "dsl"
			if not JSLINT script, { predef: predef, white: true }
				@errors.push {message: "#{@url} Line #{error.line}, character #{error.character}: #{error.reason}"} for error in JSLINT.errors when error?
				return null
		# If we get here, then the script is okay.
		script


