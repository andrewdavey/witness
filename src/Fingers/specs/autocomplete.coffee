describe "Autocomplete",
{
	"given an autocomplete in edit mode": [
		loadPage "/fingers/test.html"
        $("div.static-view.field:eq(8)").click()
	]

	"when 'ph' is typed and down pressed": [
		$(":focus").type "ph"
		wait 500 # allow time for drop down menu to appear
		$(":focus").type DOWN, ENTER
	]
	
	"then 'php' is selected":
		"div.static-view.field:eq(8)": should.haveText "php"
}
