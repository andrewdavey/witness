# reference "Witness.coffee"
# reference "../lib/knockout.js"
# reference "../lib/coffee-script.js"
# reference "Event.coffee"

this.Witness.SpecificationFile = class SpecificationFile

	constructor: (manifest) ->
		{@name,@url} = manifest
		@on =
			downloading: new Witness.Event()
			downloaded: new Witness.Event()
		@specifications = ko.observableArray []

	download: () ->
		@on.downloading.raise()
		$.ajax(
			url: @url
			cache: false
			dataType: 'text'
			success: (script) =>
				if @url.match(/.coffee$/)
					script = CoffeeScript.compile(script)
				@executeSpecificationScript script, (specs) =>
					@specifications.push new Witness.ViewModels.SpecificationViewModel(spec) for spec in specs
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
		tryAll = new Witness.TryAll @specifications()
		tryAll.run context, done, fail
