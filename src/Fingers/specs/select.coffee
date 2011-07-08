describe "Select component initial UI",
{
	"Given a select component with no selection and no empty option":
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2">Second</option>
		</select>
		"""

	"Then it is in read mode with text 'First'":
		".static-view": should.haveText "First"
},
{
	"Given a select component with no selection and an empty option":
		createFingersUI """
		<select class="editable view-select">
			<option value="">(choose)</option>
			<option value="1">First</option>
			<option value="2">Second</option>
		</select>
		"""

	"Then it is in read mode with text 'Click to edit'":
		".static-view": should.haveText "Click to edit"
},
{
	"Given a select component with a selected option":
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2" selected="selected">Second</option>
		</select>
		"""

	"Then it is in read mode with text 'Second'":
		".static-view": should.haveText "Second"
}

describe "Select component entering edit mode",
{
	"Given a select component with no selection and no empty option":
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2">Second</option>
		</select>
		"""

	"When it is clicked":
		$(".static-view").click()

	"Then select control is displayed with first selected":
		".static-view": shouldnot.beVisible()
		"select.edit-view-control": should.haveVal "1"
},
{
	"Given a select component with no selection and an empty option":
		createFingersUI """
		<select class="editable view-select">
			<option value="">(choose)</option>
			<option value="1">First</option>
			<option value="2">Second</option>
		</select>
		"""

	"When it is clicked":
		$(".static-view").click()

	"Then select control is displayed with empty option selected":
		".static-view": shouldnot.beVisible()
		"select.edit-view-control:visible": should.match 1
		"select.edit-view-control": should.haveVal ""
},
{
	"Given a select component with a option 2 selected":
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2" selected="selected">Second</option>
		</select>
		"""

	"When it is clicked":
		$(".static-view").click()

	"Then select control is visible with option 2 selection":
		".static-view": shouldnot.beVisible()
		"select.edit-view-control:visible": should.match 1
		"select.edit-view-control": should.haveVal "2"
}


describe "Select component in edit mode",
{
	"Given a select component in edit mode": [
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2" selected="selected">Second</option>
		</select>
		"""
		$(".static-view").click()
	]

	"When Escape key is pressed":
		$("select.edit-view-control").type ESCAPE

	"Then it is returned to read mode":
		".static-view": should.beVisible()
		"select.edit-view-control": should.match 0
},
{
	"Given a select component in edit mode, with changed value": [
		createFingersUI """
		<select class="editable view-select">
			<option value="1">First</option>
			<option value="2" selected="selected">Second</option>
		</select>
		"""
		$(".static-view").click()
		$("select.edit-view-control").val "1"
	]

	"When Enter key is pressed":
		$("select.edit-view-control").type ENTER

	"Then it is returned to read mode and displays the selected option text":
		".static-view:visible": should.match 1
		".static-view": should.haveText "First"
		"select.edit-view-control": should.match 0
}
