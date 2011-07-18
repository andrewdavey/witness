# reference "_namespace.coffee"

@Witness.ui.SpecificationViewModel = class SpecificationViewModel

	constructor: (@specification) ->
		{ @filename, @url } = @specification

	templateId: "specification"
