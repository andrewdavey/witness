# reference "_namespace.coffee"

@witness.ui.SpecificationViewModel = class SpecificationViewModel

	constructor: (@specification) ->
		{ @path, @url } = @specification.parentFile

	templateId: "specification"
