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
				iframeDoc.write "<script type='text/javascript' src='#{this.src}'></script>"
			)
			
			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications
				# Can't instantly remove the iframe since it's still running this code!
				# So delay for a moment to let the current code finish
				setTimeout (-> iframe.remove()), 200

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()
			iframeDoc.write "<script type='text/javascript'>#{script}</script>"
			iframeDoc.write "<script type='text/javascript'>_witnessScriptCompleted()</script>"
			

	runAll: (log) ->
		before = (object, name, newFunc) ->
			old = object[name]
			# replace the function
			object[name] = (args...) ->
				newFunc.apply this, args
				old.apply this, args
			# return a 'restore' function
			() -> object[name] = old

		before Witness.Specification::, "run", () -> log "Testing: " + @description
		before Witness.Scenario::, "run", () -> log "Scenario:"
		before Witness.Assertion::, "run", () -> log "Asserting: " + @name

		all = new Witness.TryAll @specifications
		all.run {}, (->), (->)