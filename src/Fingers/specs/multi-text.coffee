should.beActive = predicateActionBuilder
	getActual: (context, propertyNames) ->
		console.log 'active element class = ' + context.document.activeElement.className
		console.log 'selector = ' + propertyNames[0]
		console.log 'selected element class = ' + jQuery(propertyNames[0], context.document).attr('class')
		context.document.activeElement == jQuery(propertyNames[0], context.document)[0]
	test: (actual) ->
		actual
	description: (selector) ->
		selector + " should be active"
	error: (selector) ->
		"#{selector} was not active"

describe "Multi text input",
{
	"given editing multi text input with first input focused": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(3)').click(),
		$(".multi-text input:eq(0)").focus()
	]

	"when tabbing to next field":
		tab()

	"then the second input is focused":
		".multi-text input:eq(1)": should.beActive()
},
{
	"given editing multi text input with last input focused": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(3)').click(),
		$(".multi-text input:eq(3)").focus()
	]

	"when tabbing to next field": [
		$(".multi-text input:eq(3)").type(TAB)
		wait 1000
	]

	"then a new input is appended and focused":
		".multi-text input:eq(4)": should.beActive()
}
