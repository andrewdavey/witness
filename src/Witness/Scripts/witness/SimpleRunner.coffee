# reference "Witness.coffee"
# reference "../lib/coffee-script.js"
# reference "../lib/jquery.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: () ->
		@specifications = []

	download: (url) ->
		waitForSpecifications = $.Deferred()
		$.ajax({
			url: url
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
				iframeDoc.write("<script type='text/javascript' src='#{this.src}'></script>")
			)
			
			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications
				iframe.remove();

			dsl = new Witness.Dsl(iframeWindow)
			iframeDoc.write("<script type='text/javascript'>#{script}</script>")
			iframeDoc.write("<script type='text/javascript'>_witnessScriptCompleted()</script>")
			

	runAll: (log) ->
		for specification in @specifications
			log "Testing " + specification.description
			for scenario in specification.scenarios
				scenario.run {}, (-> log "passed"), ((e) -> log e)