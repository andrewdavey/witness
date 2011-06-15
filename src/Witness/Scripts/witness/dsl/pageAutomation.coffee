# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	loadPage: async (url) ->
		if not @iframe
			@iframe = $("<iframe/>")
			Witness.MessageBus.send "AppendIframe", @iframe

			@iframe.bind "load", =>
				@iframe.contents().ready =>
					@window = @iframe[0].contentWindow
					@document = @iframe[0].contentWindow.document
					@done()

		@iframe.attr "src", url
	
	click: (selector) ->
		$(selector, @document).click()

this.Witness.Dsl::should.haveText = (expected) -> (selector) ->
	func = ->
		actual = $(selector, @document).text()
		return if actual == expected
		throw new Error "Expected #{selector} to have text \"#{expected}\", but was \"#{actual}\""

	new Witness.Action func, [], "#{selector} should have the text \"#{expected}\""
