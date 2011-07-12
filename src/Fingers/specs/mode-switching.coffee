# The basic interaction behaviors of creating UI, switching between
# static and edit modes are similar for all Fingers components.
# So this file generates the specifications, rather than manually
# typing them all out.

uiTypes = [
	name: "single text"
	html: '<input type="text" class="editable view-single-text"/>'
,
	name: "multi text"
	html: '<input type="text" class="editable view-multi-text"/>'
	blur: [
		wait 250 # the component use setTimeout to bind click event after a small delay, so wait here for that.
		$("body").click()
	]
,
	name: "autocomplete"
	html: '<input type="text" class="editable view-type-ahead" data-lookupUrl="/lookup/Publishers" />'
	blur: [
		$(":input:visible").blur()
		wait 250
	]
,
	name: "select"
	html: """
		<select class="editable view-select">
			<option value="">(select)</option>
			<option value="1">First</option>
			<option value="2">Second</option>
		</select>
		"""
,
	name: "select with selection"
	html: """
		<select class="editable view-select">
			<option value="">(select)</option>
			<option value="1" selected="selected">First</option>
			<option value="2">Second</option>
		</select>
		"""
	staticDefault: "First"
,
	name: "bool (default false)"
	html: '<input type="text" class="editable view-bool" value="false"/>'
	staticDefault: "false"
	blur: [
		$(":input:visible:first").blur()
		wait 250
	]
,
	name: "bool (default true)"
	html: '<input type="text" class="editable view-bool" value="true"/>'
	staticDefault: "true"
	blur: [
		$(":input:visible:first").blur()
		wait 250
	]
,
	name: "date picker"
	html: '<input type="text" class="editable view-date-picker" />'
	afterGiven: wait 250
	afterWhen: wait 250
	editingInputCount: 2
	blur: [
		->
			input = @window.jQuery("input:visible", @document)
			input.datepicker("hide")
		wait 250
	]
,
	name: "ckeditor with no default content"
	html: '<textarea class="editable view-ck-editor"></textarea>'
	blur: [
		wait 250
		$("body").click()
	]
	ignore: { escape: true, enter: true } # leave these for now
,
	name: "ckeditor with default content"
	html: '<textarea class="editable view-ck-editor"><p>This is some rich HTML content</p></textarea>'
	staticDefault: "This is some rich HTML content"
	blur: [
		wait 250
		$("body").click()
	]
	ignore: { escape: true, enter: true } # leave these for now
]

specBuilders =
	"Create initial UI": (ui) ->
		staticDefault = ui.staticDefault or "Click to edit"
		spec = {}
		spec["given #{ui.name} component"] = createFingersUI ui.html
		spec["then static view displayed '#{staticDefault}'"] =
			".static-view": should.haveText staticDefault
		spec

	"Start editing": (ui) ->
		spec = {}
		spec["given #{ui.name} component"] = createFingersUI ui.html
		spec["when static view clicked"] = $(".static-view").click()
		spec["then static view hidden, input control displayed"] =
			".static-view": shouldnot.beVisible()
			":input:visible": should.match (ui.editingInputCount or 1)
		spec

	"Cancel edit": (ui) ->
		return null if ui.ignore?.escape?
		spec = {}
		givenActions = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		if ui.afterGiven?
			givenActions.push ui.afterGiven
		spec["given #{ui.name} component in edit mode"] = givenActions 
		whenActions = [ $(":input:visible:first").type ESCAPE ]
		if ui.afterWhen?
			whenActions.push ui.afterWhen
		spec["when Escape key pressed"] = whenActions
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

	"Save edit by losing focus": (ui) ->
		spec = {}
		givenActions = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		if ui.afterGiven?
			givenActions.push ui.afterGiven
		spec["given #{ui.name} component in edit mode"] = givenActions  
		spec["when input blurred"] = ui.blur or $(":input:visible:first").blur()
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

	"Save edit by pressing Enter key": (ui) ->
		return null if ui.ignore?.enter?

		spec = {}
		givenActions = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		if ui.afterGiven?
			givenActions.push ui.afterGiven
		spec["given #{ui.name} component in edit mode"] = givenActions
		whenActions = [ $(":input:visible:first").type ENTER ]
		if ui.afterWhen?
			whenActions.push ui.afterWhen
		spec["when Enter key pressed"] = whenActions
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

for own description, specBuilder of specBuilders
	specs = (specBuilder uiType for own uiType in uiTypes)
	specs = (spec for spec in specs when spec?)
	describe description, specs...
