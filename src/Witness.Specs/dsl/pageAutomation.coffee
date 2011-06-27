describe "click",
{
	"given an element in the document to click": [
		loadEmptyPage()
		->
			@body.append "<a href='#'>test</a>"
			elementToClick = @body.find "a"
			elementToClick.click => @clickEventRaised = true
			@clickAction = $("a").click()
	]

	"when click action is run": ->
		@clickAction.run { document: @document }, (->), (->)

	"then":
		clickEventRaised: should.be true
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
