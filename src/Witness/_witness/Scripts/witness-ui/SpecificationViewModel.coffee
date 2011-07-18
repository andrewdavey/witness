# reference "_namespace.coffee"

@Witness.ui.SpecificationViewModel = class SpecificationViewModel

	constructor: (@specification) ->
		@filename = @specification.filename

	templateId: "specification"
