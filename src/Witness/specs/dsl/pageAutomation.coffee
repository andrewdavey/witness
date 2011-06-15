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

describe "input",
{
	"given an input action that sets two values": ->
		@input = input
			"#selector": "value-a"
			"#another": "value-b"
		@valCalledCount = 0
		@restore$ = mock this.window,
			$: (selector, context) =>
				val: => @valCalledCount++

	"when it is run": ->
		@input.run { document: "document" }, (->), (->)
	
	then: [
		valCalledCount: should.be 2
	]

	dispose: ->
		@restore$()
}
