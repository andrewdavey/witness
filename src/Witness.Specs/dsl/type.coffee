describe "type",
{
	"given a text input and a type action": [
		loadEmptyPage(),
		->
			@body.append "<input type='text'/>"
			@input = @body.find "input"
			@typeAction = $("input").type("example")
	]

	"when the type action is run": ->
		@typeAction.run { document: @document }, (->), (->)
	
	"then the input's value is set": ->
		@input.val() == "example"
}
