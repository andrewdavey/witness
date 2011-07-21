# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "Event.coffee"
# reference "Dsl.coffee"

{ Event, Dsl, messageBus } = @witness

# A ScriptFile represents either a JavaScript or CoffeeScript file that
# is to be downloaded, parsed and executed.
# It is an abstract base class. Subclasses must provide a scriptDownloaded function.
@witness.ScriptFile = class ScriptFile
	
	constructor: (@url) ->
		@on = Event.define "downloading", "downloaded", "downloadFailed"

	download: ->
		@on.downloading.raise()
		jQuery.ajax
			url: @url
			cache: false
			dataType: 'text' # Must be 'text' else jQuery tries to execute the script for us!
			success: (script) =>
				messageBus.send "ScriptDownloading", this
				{ script, errors} = @parseScript script
				if errors?
					messageBus.send "ScriptDownloadError", this, errors
					@on.downloadFailed.raise errors
					return

				messageBus.send "ScriptDownloaded", this
				@scriptDownloaded script

			error: =>
				errorMessage = "Could not download #{@url}"
				messageBus.send "ScriptDownloadError", this, [ errorMessage ]
				@on.downloadFailed.raise [ errorMessage ]

	scriptDownloaded: (script) ->
		@on.downloaded.raise()

	parseScript: (script) ->
		if @url.match(/.coffee$/)
			try
				script = CoffeeScript.compile(script)
			catch error
				return script: null, errors: [ error ]
		else
			predef = (name for own name of Dsl::)
			predef.push "dsl"
			if not JSLINT script, { predef: predef, white: true }
				buildError = (error) -> { message: "#{@url} Line #{error.line}, character #{error.character}: #{error.reason}" }
				errors = (buildError error for error in JSLINT.errors when error?)
				return script: null, errors: errors
		
		# If we get here, then the script is okay.
		return script: script


