# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	loadPage: async (url) ->
		createIframe = =>
			iframe = @scenario.iframe = $("<iframe/>").hide()
			Witness.MessageBus.send "AppendIframe", iframe
			iframe

		iframeLoadHandler = =>
			# Only handle this once
			iframe.unbind "load", iframeLoadHandler
			iframe.data "WitnessLoadHandler", null
			iframe.contents().ready =>
				# Store page objects in the context so other actions can access them
				@window = iframe[0].contentWindow
				@document = iframe[0].contentWindow.document
				# Continue with the next action
				@done()
		
		iframe = @scenario.iframe or createIframe()

		# The "done" callback is called once the iframe has loaded.
		# But the same iframe is reused each time the scenario is run.
		# Therefore we must only have the current "load" handler bound to it.
		if iframe.data("WitnessLoadHandler")?
			iframe.unbind "load", iframe.data("WitnessLoadHandler")
		iframe.bind "load", iframeLoadHandler
		iframe.data "WitnessLoadHandler", iframeLoadHandler

		iframe.attr "src", url
	
	click: (selector) ->
		$(selector, @document).click()

this.Witness.Dsl::defineShouldFunctions
	haveText:
		getActual: (context, propertyNames) ->
			$(propertyNames[0], context.document).text()
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"#{selector} should have the text \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have text \"#{expected}\", but was \"#{actual}\""

