describe "Autocomplete",
{
	"given an autocomplete in edit mode": [
		loadPage "/fingers/test.html"
        $("div.static-view.field:eq(8)").click()
	]

	"when 'ph' is typed and down pressed": [
		$(":focus").type "ph"
		wait 500
		$(":focus").type DOWN
		$(":focus").type RETURN
	]
	
	"then 'php' is selected":
		"div.static-view.field:eq(8)": should.haveText "php"
}
