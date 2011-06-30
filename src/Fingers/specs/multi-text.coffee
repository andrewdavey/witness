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
		".multi-text input:eq(1):focus": should.match(1)
},
{
	"given editing multi text input with last input focused": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(3)').click(),
		$(".multi-text input:eq(3)").click()
	]

	"when tabbing to next field":
		$(":focus").type(TAB)

	"then a new input is appended and focused":
		".multi-text input:eq(4):focus": should.match(1)
}
