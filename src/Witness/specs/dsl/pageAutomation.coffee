describe "click",
{
	"given a click action": ->
		@click = click("button")
		# Mock the $(selector, context).click() call
		@restore$ = mock this.window,
			$: (selector, context) =>
				@selector = selector
				@context = context
				return click: => @clickCalled = true

	"when it is run": ->
		@click.run { document: "document" }, (->), (->)
	
	then: [
		selector: should.be "button"
		context: should.be "document"
		clickCalled: should.be true
	]

	dispose: ->
		@restore$()
}
