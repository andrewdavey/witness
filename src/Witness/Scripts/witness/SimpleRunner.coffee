# reference "Witness.coffee"
# reference "../lib/coffee-script.js"
# reference "../lib/jquery.js"
# reference "../lib/knockout.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: (@specsPath, iframeContainer) ->
		# Use an observable array, since knockout dislikes binding to a null object.
		# Once loaded, the array will contain the single directory object.
		@directory = ko.observableArray []

		Witness.MessageBus.addHandler "AppendIframe", (iframe) -> iframeContainer.append iframe

	fileSystemItemTemplate: (item) ->
		if item instanceof Witness.ViewModels.SpecificationDirectoryViewModel
			"directory"
		else
			"file"

	download: ->
		downloading = @downloadSpecificationManifest()
		downloading.then (manifest) =>
			if manifest.url?
				@createSpecificationFileFromManifest manifest
			else
				@createSpecificationDirectoryFromManifest manifest
		downloading

	downloadSpecificationManifest: ->
		$.ajax(
			url: "/specs.ashx?path=" + @specsPath
			cache: false
		)

	createSpecificationFileFromManifest: (manifest) ->
		file = new Witness.SpecificationFile manifest
		viewModel = new Witness.ViewModels.SpecificationFileViewModel file
		@directory.push viewModel
		viewModel.download()

	createSpecificationDirectoryFromManifest: (manifest) ->
		dir = new Witness.SpecificationDirectory manifest
		viewModel = new Witness.ViewModels.SpecificationDirectoryViewModel dir
		@directory.push viewModel
		viewModel.download()

	downloadSpecification: (url) ->
		waitForSpecifications = $.Deferred()
		$.ajax({
			url: url
			cache: false
			dataType: 'text'
			success: (script) =>
				if url.match(/.coffee$/)
					script = CoffeeScript.compile(script)
				@executeSpecificationScript script, (specs) =>
					@specifications = @specifications.concat specs
					waitForSpecifications.resolve()
		});
		waitForSpecifications

	executeSpecificationScript: (script, gotSpecifications) ->
		iframe = $("<iframe src='/empty.htm'/>").hide().appendTo("body")
		iframe.load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			
			# Copy all our scripts into the iframe.
			$("head > script[src]").each(() ->
				iframeDoc.write "<script type='text/javascript' src='#{this.src}'></script>"
			)
			
			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()
			iframeDoc.write "<script type='text/javascript'>#{script}</script>"
			iframeDoc.write "<script type='text/javascript'>_witnessScriptCompleted()</script>"
			

	runAll: () ->
		@directory()[0].run ->
			Witness.MessageBus.send "RunnerFinished"
