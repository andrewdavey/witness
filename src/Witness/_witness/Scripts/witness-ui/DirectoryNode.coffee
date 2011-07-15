# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.DirectoryNode = class DirectoryNode extends TreeNode

	constructor: (name) ->
		super()
		@text name

	templateId: "directory"
