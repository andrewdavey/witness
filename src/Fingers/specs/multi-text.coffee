describe "Multi text input UI creation",
{
	"Given multi text component with empty default value":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="" />
		"""

	"Then static view displays 'Click to edit'":
		".static-view": should.haveText "Click to edit"
},
{
	"Given multi text component with single default value 'HELLO'":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO"/>
		"""

	"Then static view displays 'HELLO'":
		".static-view": should.haveText "HELLO"
},
{
	"Given multi text component with default values 'HELLO' and 'WORLD'":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""

	"Then static view displays 'HELLO, WORLD'":
		".static-view": should.haveText "HELLO, WORLD"
}

describe "Multi text entering edit mode",
{
	"Given multi text component with missing default value":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"/>
		"""
	
	"When static view clicked":
		$(".static-view").click()

	"Then a single input box appears":
		"input:visible": should.match 1
},
{
	"Given multi text component with empty default value":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value=""/>
		"""
	
	"When static view clicked":
		$(".static-view").click()

	"Then a single input box appears":
		"input:visible": should.match 1
},
{
	"Given multi text component with single default value 'HELLO'":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO"/>
		"""
	
	"When static view clicked":
		$(".static-view").click()

	"Then two input boxes appear, the first contains 'HELLO', the second has focus":
		"input:visible": should.match 2
		"input:visible:eq(0)": should.haveVal "HELLO"
		"input:visible:eq(1)": should.beActive()
},
{
	"Given multi text component with default values 'HELLO', 'WORLD'":
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
	
	"When static view clicked":
		$(".static-view").click()

	"Then three input boxes appear, the first contains 'HELLO', the second contains 'WORLD', the third has focus":
		"input:visible": should.match 3
		"input:visible:eq(0)": should.haveVal "HELLO"
		"input:visible:eq(1)": should.haveVal "WORLD"
		"input:visible:eq(2)": should.beActive()
}

describe "Multi text component in edit mode",
{
	"Given a multi text component with two values and in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
	]

	"When Escape key pressed":
		$("input:visible:eq(0)").type ESCAPE
	
	"Then it is returned to static view":
		".static-view": should.beVisible()
		"input": shouldnot.beVisible()
},
{
	"Given a multi text component with two values and in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
	]

	"When Enter key pressed":
		$("input:visible:eq(0)").type ENTER
	
	"Then it is returned to static view":
		".static-view": should.beVisible()
		"input": shouldnot.beVisible()
},
{
	"Given a multi text component in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
		wait 250 # the component use setTimeout to bind click event after a small delay, so wait here for that.
	]

	"When click outside the component":
		$("body").click()
	
	"Then it is returned to static view":
		".static-view": should.beVisible()
		"input": shouldnot.beVisible()
},
{
	"Given a multi text component in edit mode with first input focused": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
		$("input:visible:first").focus()
	]

	"When Tab key pressed":
		tab()

	"Then the second input is focused":
		"input:visible:eq(1)": should.beActive()
},
{
	"Given a multi text component with two values in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
	]

	"When 'TEST' typed and tab key pressed":
		$("input:visible:eq(2)").type "TEST", TAB

	"Then a new input is created and focused":
		"input:visible": should.match 4
		"input:visible:eq(3)": should.beActive()
},
{
	"Given a multi text component with two values in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
	]

	"When first input is cleared and Enter key pressed": [
		$("input:visible:eq(0)").val ""
		$("input:visible:eq(0)").type ENTER
	]
	
	"Then the static view shows just the second value":
		".static-view": should.haveText "WORLD"
},
{
	"Given a multi text component with two values in edit mode": [
		createFingersUI """
		<input type="text"
		       class="editable view-multi-text"
		       value="HELLO|WORLD"/>
		"""
		$(".static-view").click()
	]

	"When make a deletion, edit and addition, and persist the changes": [
		$("input:visible:eq(0)").val ""
		$("input:visible:eq(1)").selectCharacters 5, 5
		$("input:visible:eq(1)").type " EDITED"
		$("input:visible:eq(2)").type "ADDED"
		$("input:visible:eq(2)").type ENTER
	]
	
	"Then the static view is updated":
		".static-view": should.haveText "WORLD EDITED, ADDED"
}
