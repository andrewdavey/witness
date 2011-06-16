# reference "Witness.coffee"
# reference "../lib/knockout.js"
# reference "../lib/coffee-script.js"
# reference "Event.coffee"

this.Witness.SpecificationFile = class SpecificationFile

	constructor: (manifest) ->
		{@name,@url} = manifest
		@on = Witness.Event.define "downloading", "downloaded", "run", "done", "fail"
		@specifications = []
		@errors = []

	download: () ->
		@errors = []
		@on.downloading.raise()
		$.ajax(
			url: @url
			cache: false
			dataType: 'text'
			success: (script) =>
				if @url.match(/.coffee$/)
					try
						script = CoffeeScript.compile(script)
					catch error
						@errors.push error
						@on.downloaded.raise [error]
						return
				else
					predef = (name for own name of Witness.Dsl::)
					if not JSLINT script, { predef: predef, white: true }
						@errors.push {message: "Line #{error.line}, character #{error.character}: #{error.reason}"} for error in JSLINT.errors when error?
						@on.downloaded.raise @errors
						return
				@executeSpecificationScript script, (specs) =>
					@specifications.push spec for spec in specs
					@on.downloaded.raise()
		)

	executeSpecificationScript: (script, gotSpecifications) ->
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

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()

			addScript script
			addScript "_witnessScriptCompleted();"

	run: (context, done, fail) ->
		Witness.messageBus.send "SpecificationFileRunning", this
		@on.run.raise()
		tryAll = new Witness.TryAll @specifications
		tryAll.run context,
			=>
				Witness.messageBus.send "SpecificationFilePassed", this
				@on.done.raise()
				done()
			(error) =>
				@on.fail.raise(error)
				Witness.messageBus.send "SpecificationFileFailed", this
				fail(error)
