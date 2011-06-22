# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	loadPage: async (url) ->
		iframe = @scenario.getIFrame()
		@scenario.setIFrameLoadCallback (iframeWindow) =>
			# Store page objects in the context so other actions can access them
			@window = iframeWindow
			@document = iframeWindow.document
			# Continue with the next action
			@done()

		iframe.attr "src", url
	
	awaitPageLoad: async ->
		iframe = @scenario.getIFrame()
		loaded = (iframeWindow) =>
			# Store page objects in the context so other actions can access them
			@window = iframeWindow
			@document = iframeWindow.document
			# Continue with the next action
			@done()

		@scenario.setIFrameLoadCallback loaded, yes

	click: (selector) ->
		# Thanks to http://stackoverflow.com/questions/1421584/how-can-i-simulate-a-click-to-an-anchor-tag/1421968#1421968
		fakeClick = (anchorObj) =>
			if @document.createEvent
				evt = @document.createEvent "MouseEvents"
				evt.initMouseEvent "click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
				anchorObj.dispatchEvent evt
			else if anchorObj.click
				anchorObj.click()
			else
				throw new Error "Unable to simulate click in this web browser."

		$(selector, @document).each -> fakeClick this

	input: (inputs) ->
		for own selector, value of inputs
			$(selector, @document).val value

	blur: (selector) ->
		$(selector, @document).blur()

	focus: (selector) ->
		$(selector, @document).focus()

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

