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
				###
				else
					if not JSLINT script
						@errors.push {message: "Line #{error.line}, character #{error.character}: #{error.reason}"} for error in JSLINT.errors when error?
						@on.downloaded.raise @errors
						return
				###
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
			addScript = (properties) ->
				scriptElement = iframeDoc.createElement "script"
				scriptElement.type = "text/javascript"
				scriptElement.async = false # else some browser seem to execute scripts in non-sequential order!
				scriptElement[name] = value for own name, value of properties
				body.appendChild scriptElement

			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications or []

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()

			addScript { innerText: script }
			addScript { innerText: "_witnessScriptCompleted();" }

	run: (context, done, fail) ->
		@on.run.raise()
		tryAll = new Witness.TryAll @specifications
		tryAll.run context,
			(=> @on.done.raise(); done())
			((error) => @on.fail.raise(error); fail(error))
