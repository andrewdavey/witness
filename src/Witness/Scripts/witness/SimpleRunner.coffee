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
		onloadName = 'iframe_' + (new Date().getTime())
		iframe = $("<iframe src='/empty.htm'/>").hide().appendTo("body")
		$(iframe).load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			iframeHead = $("head", iframeWindow.document)
			$("head > script[src]").each(() ->
				iframeDoc.write("<script type='text/javascript' src='#{this.src}'></script>")
			)
			dsl = new Witness.Dsl(iframeWindow)
			iframeDoc.write("<script type='text/javascript'>#{script}</script>")
			iframeWindow.Witness_Completed = (-> gotSpecifications dsl.specifications)
			iframeDoc.write("<script type='text/javascript'>Witness_Completed()</script>")
			

	runAll: (log) ->
		for specification in @specifications
			log "Testing " + specification.description
			for scenario in specification.scenarios
				scenario.run {}, (-> log "passed"), ((e) -> log e)