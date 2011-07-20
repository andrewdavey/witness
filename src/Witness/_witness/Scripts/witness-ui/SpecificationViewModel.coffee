# reference "_namespace.coffee"

@witness.ui.SpecificationViewModel = class SpecificationViewModel

	constructor: (@specification) ->
		{ @filename, @url } = @specification

	templateId: "specification"
