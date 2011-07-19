describe "Multi text component, with limit, initial UI",
{
	"given multi text component, limit 5, with 3 values":
		createFingersUI """
		<input type="text" class="editable view-multi-text-limit-5" value="value1|value2|value3" />
		"""

	"then static view displays the 3 values":
		".static-view": should.haveText "value1, value2, value3"
},
{
	"given multi text component, limit 5, with empty default value":
		createFingersUI """
		<input type="text" class="editable view-multi-text-limit-5" />
		"""

	"then static view displays 'Click to edit'":
		".static-view": should.haveText "Click to edit"
}

describe "Multi text component, with limit, entering edit mode",
{
	"given multi text component, limit 5":
		createFingersUI """
		<input type="text" class="editable view-multi-text-limit-5" />
		"""

	"when static view clicked":
		$(".static-view").click()
	
	"then 5 input elements are displayed":
		".static-view": shouldnot.beVisible()
		"input:visible": should.match 5
},
{
	"given multi text component, limit 5, with 2 default values":
		createFingersUI """
		<input type="text" class="editable view-multi-text-limit-5" value="value1|value2" />
		"""

	"when static view clicked":
		$(".static-view").click()
	
	"then first two inputs have the values":
		"input:visible:eq(0)": should.haveVal "value1"
		"input:visible:eq(1)": should.haveVal "value2"
}

describe "Multi text component, limit 5, in edit mode",
{
	"given multi text component, limit 5, in edit mode": [
		createFingersUI """
		<input type="text" class="editable view-multi-text-limit-5" />
		"""
		$(".static-view").click()
	]
	
	"when type values into first 2 inputs and then presses Enter key": [
		$("input:visible:eq(0)").type "value1"
		$("input:visible:eq(1)").type "value2", ENTER
		$("body").click()
	]

	"then the static view displays 'value1, value2'":
		".static-view": should.haveText "value1, value2"
}
