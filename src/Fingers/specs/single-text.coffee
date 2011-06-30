describe "Single text input",
{
	"given a page containing a single text component":
		loadPage("/fingers/test.html")

	"when a static view is clicked":
		$("div.static-view.field:eq(0)").click()

	"then an edit view should appear":
		"div.static-view.field:eq(0)": shouldnot.beVisible(),
		"input.edit-view-control.single-text": should.haveLength(1)
},
{
	"given a page with an active edit view component": [
		loadPage("/fingers/test.html"),
		$("div.static-view.field:eq(0)").click()
	]

	"when the edit view is blurred":
		$("input.edit-view-control.single-text:eq(0)").blur()
	
	"then the static view should reappear":
		"div.static-view.field:eq(0)": should.beVisible()
},
{
	"given a page with an active edit view component and text entered": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(0)').click(),
		$('input.edit-view-control.single-text:eq(0)').val("TEST")
	]
	
	"when the edit view is blurred": [
		$('input.edit-view-control.single-text:eq(0)').blur()
	]
	
	"then the static view should show the entered text": {
		'div.static-view.field:eq(0)': should.haveText("TEST")
	}
},
{
	"given a page with an active edit view component that was empty, clicked and had text entered": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(0)').click(),
		$('input.edit-view-control.single-text:eq(0)').type("TEST")
	]

	"when Escape key is pressed":
		$("input.edit-view-control.single-text:eq(0)").type(ESCAPE)

	"then the static view should be empty":
		'div.static-view.field:eq(0)': should.haveText("Click to edit"),
		"input.edit-view-control.single-text:eq(0)": shouldnot.beVisible()
},
{
	"given a page with an active edit view component that was empty, clicked and had text entered": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(0)').click(),
		$('input.edit-view-control.single-text:eq(0)').type("TEST")
	]

	"when Return key is pressed":
		$("input.edit-view-control.single-text:eq(0)").type(RETURN)

	"then the static view should be updated to equal the entered text":
		'div.static-view.field:eq(0)': should.haveText("TEST")
}
