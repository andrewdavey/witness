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
