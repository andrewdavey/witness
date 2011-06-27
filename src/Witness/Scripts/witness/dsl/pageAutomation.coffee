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

