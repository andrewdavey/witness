staticViewSelector = ".static-view"
staticViewHasText = (expectedText) ->
	obj = {}
	obj[staticViewSelector] = should.haveText expectedText
	obj
clickStaticView = $(staticViewSelector).click()

describe "Single text initial UI",
{
	"Given a single text component with empty default value":
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""

	"Then it is in read mode with text 'Click to edit' displayed": [
		{ "input": should.haveLength 1 }
		{ "input": shouldnot.beVisible() }
		staticViewHasText "Click to edit"
	]
},
{
	"Given a single text component with a default value of HELLO":
		createFingersUI """
		<label for="test">Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="HELLO" />
		"""
	
	"Then it is in read mode with text 'HELLO' displayed":
		staticViewHasText "HELLO"
}


describe "Single text with default empty value",
{
	"Given a single text component with empty default value":
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""

	"When the displayed value is clicked":
		clickStaticView

	"Then the input UI is created":
		".static-view": shouldnot.beVisible()
		"input.edit-view-control:visible": [
			should.haveLength 1
			should.haveVal ""
		]
},
{
	"Given a single text component in edit mode": [
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""
		clickStaticView
	]

	"When Escape key is pressed":
		$("input.edit-view-control").type ESCAPE
	
	"Then it is returned to static view":
		".static-view": should.beVisible()
},
{
	"Given a single text component in edit mode": [
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""
		clickStaticView
	]

	"When some text is typed then Escape key is pressed":
		$("input.edit-view-control").type "some text", ESCAPE
	
	"Then it is returned to static view with original value displayed":
		staticViewHasText "Click to edit"
},
{
	"Given a single text component in edit mode": [
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""
		clickStaticView
	]

	"When some text is typed then Enter key is pressed":
		$("input.edit-view-control").type "some text", ENTER
	
	"Then it is returned to static view with new value displayed":
		staticViewHasText "some text"
},
{
	"Given a single text component in edit mode": [
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="" />
		"""
		clickStaticView
	]

	"When some text is typed then input is blurred": [
		$("input.edit-view-control").type "some text"
		$("input.edit-view-control").blur()
	]

	"Then it is returned to static view with new value displayed":
		staticViewHasText "some text"
}

describe "Single text component with default value",
{
	"Given a single text component with default value of HELLO":
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="HELLO" />
		"""

	"When the displayed value is clicked":
		clickStaticView

	"Then the edit view is created with the value HELLO":
		".static-view": shouldnot.beVisible()
		"input.edit-view-control:visible": [
			should.haveLength 1
			should.haveVal "HELLO"
		]
},
{
	"Given a single text component with default value of HELLO in edit mode": [
		createFingersUI """
		<label for="test">Empty Single Text</label>
		<input type="text" name="test"
		       class="editable view-single-text"
		       value="HELLO" />
		"""
		clickStaticView
	]

	"When 'WORLD', Enter typed":
		$("input.edit-view-control").type "WORLD", ENTER

	"Then it is returned to static view with HELLOWORLD displayed":
		staticViewHasText "HELLOWORLD"
}
