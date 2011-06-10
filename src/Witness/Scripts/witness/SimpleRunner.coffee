# reference "Witness.coffee"
# reference "../lib/coffee-script.js"
# reference "../lib/jquery.js"
# reference "../lib/knockout.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: (@specsPath) ->
		# Use an observable array, since knockout dislikes binding to a null object.
		# Once loaded, the array will contain the single directory object.
		@directory = ko.observableArray []

	download: ->
		downloading = @downloadSpecificationManifest()
		downloading.then (manifest) => @createSpecificationDirectoryFromManifest manifest
		downloading

	downloadSpecificationManifest: ->
		$.ajax(
			url: "/specs.ashx/" + @specsPath
			cache: false
		)

	createSpecificationDirectoryFromManifest: (manifest) ->
		@directory.push new Witness.SpecificationDirectory manifest	

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
		@directory()[0].run {}, (->), (->)
