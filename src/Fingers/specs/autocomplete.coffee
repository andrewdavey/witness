editor = "input:visible"

describe "Autocomplete",
{
	"given an autocomplete in edit mode": [
		createFingersUI """
		<input type="text" class="editable view-type-ahead" data-lookupurl="/lookup/publishers" />
		"""
		$("div.static-view.field").click()
	]

	"when 'ph', DOWN, ENTER are typed": [
		$(editor).type "ph"
		wait 500 # allow time for drop down menu to appear
		$(editor).type DOWN, ENTER
	]
	
	"then 'php' is selected":
		"div.static-view.field": should.haveText "php"
}
