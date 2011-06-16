# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	loadPage: async (url) ->
		createIframe = =>
			iframe = @scenario.iframe = $("<iframe/>").hide()
			Witness.messageBus.send "AppendIframe", iframe
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
	
	awaitPageLoad: ->
		if not @scenario.iframe?
			throw new Error "Cannot await page load when no page is loading."
		# TODO


	click: (selector) ->
		# Thanks to http://stackoverflow.com/questions/1421584/how-can-i-simulate-a-click-to-an-anchor-tag/1421968#1421968
		fakeClick = (anchorObj) ->
			if document.createEvent
				evt = document.createEvent "MouseEvents"
				evt.initMouseEvent "click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
				anchorObj.dispatchEvent evt
			else if anchorObj.click
				anchorObj.click()

		$(selector, @document).each -> fakeClick this

	input: (inputs) ->
		for own selector, value of inputs
			$(selector, @document).val value

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

