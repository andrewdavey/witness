# reference "Witness.coffee"
# reference "../lib/knockout.js"
# reference "../lib/coffee-script.js"

this.Witness.SpecificationFile = class SpecificationFile

	constructor: (manifest) ->
		{@name,@url} = manifest
		@specifications = ko.observableArray []
		@downloadSpecification @url

	downloadSpecification: (url) ->
		$.ajax(
			url: url
			cache: false
			dataType: 'text'
			success: (script) =>
				if url.match(/.coffee$/)
					script = CoffeeScript.compile(script)
				@executeSpecificationScript script, (specs) =>
					@specifications.push spec for spec in specs
		)

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

