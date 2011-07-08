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
