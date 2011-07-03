# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	loadPage: async (url) ->
		url = Witness.urlBase + url unless url.match /^\//

		iframe = @scenario.getIFrame()
		@scenario.setIFrameLoadCallback (iframeWindow) =>
			# Store page objects in the context so other actions can access them
			@window = iframeWindow
			@document = iframeWindow.document
			# Continue with the next action
			@done()

		pageAlreadyLoaded = iframe.attr("src") == url
		if pageAlreadyLoaded
			@scenario.forceReloadIFrame()
		else
			iframe.attr "src", url

	loadEmptyPage: ->
		iframe = @scenario.getIFrame()
		@document = iframe.contents()[0]
		@document.write "<!doctype html><html><body></body></html>"
		@body = jQuery "body", @document
	
	awaitPageLoad: async ->
		iframe = @scenario.getIFrame()
		loaded = (iframeWindow) =>
			# Store page objects in the context so other actions can access them
			@window = iframeWindow
			@document = iframeWindow.document
			# Continue with the next action
			@done()

		@scenario.setIFrameLoadCallback loaded, yes

	input: (inputs) ->
		for own selector, value of inputs
			jQuery(selector, @document).val value

	tab: ->
		current = jQuery(":focus", @document)[0]
		focusable = jQuery ":focusable", @document
		if current?
			for element, i in focusable
				if element == current
					nextIndex = (i + 1) % focusable.length
					focusable[nextIndex].focus()
					break
		else if focusable.length > 0
			focusable[0].focus()

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

