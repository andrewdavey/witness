describe "type",
{
	"given a text input and a type action": [
		html "<input type='text'/>"
		->
			@input = jQuery "input", @document
			@typeAction = $("input").type("example")
			# Type requires the iframe to have it's own jQuery object.
			# This is because event handlers like keydown are cached on the window object.
			# We aren't testing that, so just give it ours. 
			@window.jQuery = jQuery
	]

	"when the type action is run": ->
		@typeAction.run { document: @document, window: @window },
			(->),
			(->)
	
	"then the input's value is set": ->
		@input.val() == "example"
}
