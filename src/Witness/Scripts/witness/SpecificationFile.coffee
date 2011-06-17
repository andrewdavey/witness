# reference "Witness.coffee"
# reference "../lib/knockout.js"
# reference "../lib/coffee-script.js"
# reference "Event.coffee"

this.Witness.SpecificationFile = class SpecificationFile

	constructor: (manifest) ->
		{@name,@url} = manifest
		@on = Witness.Event.define "downloading", "downloaded", "running", "passed", "failed"
		@specifications = []
		@errors = []

	download: (done = (->), fail = (->)) ->
		@errors = []
		@on.downloading.raise()
		$.ajax
			url: @url
			cache: false
			dataType: 'text'
			success: (script) =>
				script = @parseScript script
				if not script
					fail()
					return

				@executeSpecificationScript script,
					(specs) =>
						@specifications.push spec for spec in specs
						@on.downloaded.raise()
						done()
					(error) =>
						@errors.push error
						@on.downloaded.raise [ error ]
						fail()

			error: =>
				errorMessage = "Could not download #{@url}"
				@errors.push errorMessage
				@on.downloaded.raise [ errorMessage ]
				fail()
				

	parseScript: (script) ->
		if @url.match(/.coffee$/)
			try
				script = CoffeeScript.compile(script)
			catch error
				@errors.push error
				@on.downloaded.raise [error]
				return null
		else
			predef = (name for own name of Witness.Dsl::)
			if not JSLINT script, { predef: predef, white: true }
				@errors.push {message: "Line #{error.line}, character #{error.character}: #{error.reason}"} for error in JSLINT.errors when error?
				@on.downloaded.raise @errors
				return null
		# If we get here, then the script is okay.
		script

	executeSpecificationScript: (script, gotSpecifications, fail) ->
		iframe = $("<iframe src='/home/sandbox'/>").hide().appendTo("body")
		iframe.load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			body = iframeDoc.getElementsByTagName("head")[0]
			addScript = (scriptText) ->
				scriptElement = iframeDoc.createElement "script"
				scriptElement.type = "text/javascript"
				scriptElement.async = false # else some browser seem to execute scripts in non-sequential order!
				if document.createElement("script").textContent == ""
					scriptElement.textContent = scriptText
				else
					scriptElement.innerText = scriptText
				body.appendChild scriptElement

			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications or []
			failed = false
			iframeWindow._witnessScriptError = (args...) ->
				failed = true
				fail.apply this, args

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()

			script = """
			try {
				#{script}
			} catch (e) {
				_witnessScriptError(e);
			}
			"""
			addScript script
			if not failed
				addScript "_witnessScriptCompleted();"

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
				@on.failed.raise(error)
				Witness.messageBus.send "SpecificationFileFailed", this
				fail(error)
