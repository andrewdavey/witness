editor = "input:eq(1)"

describe "Autocomplete",
{
	"given an autocomplete in edit mode": [
		loadPage "/fingers/autocomplete.html"
        $("div.static-view.field").click()
	]

	"when 'ph' is typed and down pressed": [
		$(editor).type "ph"
		wait 500 # allow time for drop down menu to appear
		$(editor).type DOWN, ENTER
	]
	
	"then 'php' is selected":
		"div.static-view.field": should.haveText "php"
}
