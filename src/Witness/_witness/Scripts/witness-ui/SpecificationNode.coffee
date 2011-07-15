# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.SpecificationNode = class SpecificationNode extends TreeNode

	constructor: (name) ->
		super()
		@text name

	templateId: "specification"
