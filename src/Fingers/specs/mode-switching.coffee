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
			":input:visible": should.match 1
		spec

	"Cancel edit": (ui) ->
		spec = {}
		spec["given #{ui.name} component in edit mode"] = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		spec["when Escape key pressed"] = $(":input:visible:first").type ESCAPE
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

	"Save edit by losing focus": (ui) ->
		spec = {}
		spec["given #{ui.name} component in edit mode"] = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		spec["when input blurred"] = ui.blur or $(":input:visible:first").blur()
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

	"Save edit by pressing Enter key": (ui) ->
		spec = {}
		spec["given #{ui.name} component in edit mode"] = [
			createFingersUI ui.html
			$(".static-view").click()
		]
		spec["when Enter key pressed"] = $(":input:visible:first").type ENTER
		spec["then static view displayed, input control hidden"] =
			".static-view": should.beVisible()
			":input:visible": should.match 0
		spec

for own description, specBuilder of specBuilders
	specs = (specBuilder uiType for own uiType in uiTypes)
	describe description, specs...
