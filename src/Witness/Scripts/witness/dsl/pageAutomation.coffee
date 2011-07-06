# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"
# reference "../../lib/LAB.js"

{ async } = @Witness.Dsl::
Witness = @Witness

@Witness.Dsl::defineActions
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
	
	# The `html` action creates a new page with the body containing
	# the given html content.
	html: (htmlContent) ->
		iframe = @scenario.getIFrame()
		@document = iframe.contents()[0]
		@document.write """
		<!doctype html>
		<html>
		<head>
			<base href="#{Witness.urlBase}"/>
		</head>
		<body>
			#{htmlContent}
		</body>
		</html>
		"""
		@window = iframe[0].contentWindow
		@lab = installLAB @window

	loadScripts: async (urls...) ->
		# Can pass either a single array or multiple string arguments
		# Normalize the urls variable to be an array
		if typeof urls[0] isnt "string"
			urls = urls[0]

		# TODO: if lab is undefined then inject LABjs ?
		count = urls.length
		for url in urls
			@lab.script(Witness.urlBase + url).wait =>
				count--
				@done() if count == 0

	execute: (func) ->
		@window.eval "(#{func.toString()}());"

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
		current = @document.activeElement
		focusable = jQuery ":focusable", @document
		if current?
			for element, i in focusable
				if element == current
					nextIndex = (i + 1) % focusable.length
					focusable[nextIndex].focus()
					break
		else if focusable.length > 0
			focusable[0].focus()
