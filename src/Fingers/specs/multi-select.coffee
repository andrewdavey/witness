describe "Multi select component UI creation",
{
	"Given a multi select component with no default selections":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""

	"Then static view displays 'Click to edit'":
		".static-view": should.haveText 'Click to edit'
},
{
	"Given a multi select component with a first option selected":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""

	"Then static view displays text of first option":
		".static-view": should.haveText 'A'
},
{
	"Given a multi select component with a first and second options selected":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2" selected="selected">B</option>
			<option value="3">C</option>
		</select>
		"""

	"Then static view displays text of first and second options":
		".static-view": should.haveText 'A, B'
}

describe "Multi select component entering edit mode",
{
	"Given a multi select component with two selections":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2" selected="selected">B</option>
			<option value="3">C</option>
		</select>
		"""
	
	"When static view clicked":
		$(".static-view").click()

	"Then select control appears":
		".static-view": shouldnot.beVisible()
		"select:visible": should.haveVal ["1", "2"]
},
{
	"Given a multi select component with a first option selected":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""

	"When static view clicked":
		$(".static-view").click()

	"Then select control has one selection":
		"select:visible": should.haveVal ["1"]
},
{
	"Given a multi select component with no default selections":
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""

	"When static view clicked":
		$(".static-view").click()

	"Then select control has no selections":
		"select:visible": should.haveVal null
}

describe "Multi select in edit mode",
{
	"Given a multi select component in edit mode with change": [
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""
		$(".static-view").click()
		$("select:visible").val ["3"]
	]

	"When it is blurred":
		$("select:visible").blur()
	
	"Then static view displayed":
		".static-view:visible": should.match 1
		".static-view": should.haveText "C"
},
{
	"Given a multi select component in edit mode": [
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""
		$(".static-view").click()
	]

	"When Escape key pressed":
		$("select:visible").type ESCAPE
	
	"Then static view displayed":
		".static-view": should.beVisible()
		"select": shouldnot.beVisible()
},
{
	"Given a multi select component in edit mode with changes": [
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""
		$(".static-view").click()
		$("select:visible").val(["2"])
	]

	"When Escape key pressed":
		$("select:visible").type ESCAPE
	
	"Then static view displayed with original value":
		".static-view": should.haveText "A"
},
{
	"Given a multi select component in edit mode": [
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""
		$(".static-view").click()
	]

	"When Enter key pressed":
		$("select:visible").type ENTER
	
	"Then static view displayed":
		".static-view": should.beVisible()
		"select": shouldnot.beVisible()
},
{
	"Given a multi select component in edit mode with changes": [
		createFingersUI """
		<select class="editable view-multi-select" size="3" multiple="multiple">
			<option value="1" selected="selected">A</option>
			<option value="2">B</option>
			<option value="3">C</option>
		</select>
		"""
		$(".static-view").click()
		$("select:visible").val(["2", "3"])
	]

	"When Enter key pressed":
		$("select:visible").type ENTER
	
	"Then static view displays the new selected text":
		".static-view": should.haveText "B, C"
}
