describe "Bool component initial UI",
{
	"Given a bool component with default value `true`":
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
	
	"Then it is in read mode with text 'true' displayed":
		".static-view": should.haveText "true"
},{
	"Given a bool component with default value `false`":
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="false" />
		"""
	
	"Then it is in read mode with text 'false' displayed":
		".static-view": should.haveText "false"
},{
	"Given a bool component with default value `FALSE`":
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="FALSE" />
		"""
	
	"Then normalized text 'false' is displayed":
		".static-view": should.haveText "false"
}

describe "Bool component entering edit mode",
{
	"Given a bool component with default value `true`":
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
	
	"When it is clicked":
		$(".static-view").click()

	"Then it is in edit mode": [
		{ ".static-view": shouldnot.beVisible() }
		{ "input[type=checkbox]": should.beVisible() }
		{ "input[type=checkbox]:checked": should.match 1 }
	]
},
{
	"Given a bool component with default value `false`":
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="false" />
		"""
	
	"When it is clicked":
		$(".static-view").click()

	"Then it is in edit mode": [
		{ ".static-view": shouldnot.beVisible() }
		{ "input[type=checkbox]": should.beVisible() }
		{ "input[type=checkbox]:checked": should.match 0 }
	]
}

describe "Bool component in edit mode",
{
	"Given a bool component in edit mode": [
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
		$(".static-view").click()
	]

	"When ESCAPE key pressed":
		$("input[type=checkbox]").type ESCAPE
	
	"Then it is returned to read mode":
		".static-view": should.beVisible()
},
{
	"Given a bool component in edit mode, with value changed": [
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
		$(".static-view").click()
		$("input[type=checkbox]").click()
	]

	"When ESCAPE key pressed":
		$("input[type=checkbox]").type ESCAPE
	
	"Then it is returned to read mode with original value":
		".static-view": should.haveText "true"
},
{
	"Given a bool component in edit mode, with value changed": [
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
		$(".static-view").click()
		$("input[type=checkbox]").click()
	]

	"When ENTER key is pressed":
		$("input[type=checkbox]").type ENTER

	"Then it is returned to read mode with new value displayed": [
		{ ".static-view": should.haveText "false" }
	]
},
{
	"Given a bool component in edit mode": [
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
		$(".static-view").click()
	]

	"When it is blurred": [
		$("input[type=checkbox]").blur()
		wait 250 # bool middleware has a 250ms delay before persisting
	]

	"Then it is returned to read mode":
		".static-view": should.beVisible()
},
{
	"Given a bool component in edit mode, with value changed": [
		createFingersUI """
		<label for="test">Boolean</label>
		<input type="text" name="test" id="test"
		       class="editable view-bool"
		       value="true" />
		"""
		$(".static-view").click()
		$("input[type=checkbox]").click()
	]

	"When it is blurred": [
		$("input[type=checkbox]").blur()
		wait 250 # bool middleware has a 250ms delay before persisting
	]

	"Then it is returned to read mode with new value displayed":
		".static-view": should.haveText "false"
}
