fingersScripts = [ "lib/jquery.js", "lib/arms-common.js", "lib/jquery-ui/jquery-ui-1.8.7.custom.min.js", "lib/ckeditor/ckeditor.js", "lib/ckeditor/adapters/jquery.js", "debug/fingers.js" ]
editor = "input:eq(1)"

describe "Autocomplete",
{
	"given simple autocomplete UI": [
		html """
			 <label for="test">Look up/Autocomplete</label>
			 <input type="text" name="test" class="editable view-type-ahead" data-lookupUrl="/lookup/Publishers" />
			 """
		loadScripts fingersScripts
		execute(-> fingers.controller())
	]

	inner: [
		{
			"given an autocomplete in edit mode": [
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
	]
}
