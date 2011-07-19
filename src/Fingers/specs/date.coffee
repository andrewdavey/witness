describe "Date picker component initial UI",
{
	"given date component":
		createFingersUI """
    	<input type="text" class="editable view-date-picker" />
		"""

	"then static views displays 'Click to edit'":
		".static-view": should.haveText "Click to edit"
},
{
	"given date component with default value 01/01/2011":
		createFingersUI """
    	<input type="text" class="editable view-date-picker" value="01/01/2011"/>
		"""

	"then static views displays 01/01/2011":
		".static-view": should.haveText "01/01/2011"
}

describe "Date picker component entering edit mode",
{
	"given date component in edit mode": [
		createFingersUI """
    	<input type="text" class="editable view-date-picker" />
		"""
	]

	"when static view clicked":
		$(".static-view").click()

	"then calendar is displayed":
		".ui-datepicker-calendar:visible": should.match 1
		"input[type=text]:visible": should.match 1
}

describe "Date picker component selecting a date on calendar",
{
	"given date component in edit mode, with default value of 01 Jan 2011": [
		createFingersUI """
    	<input type="text" class="editable view-date-picker" value="01 Jan 2011"/>
		"""
		$(".static-view").click()
	]

	"when the 10th day is clicked":
		$("a:contains(10)").click()

	"then":
		".static-view": should.haveText "10 Jan 2011"
}

