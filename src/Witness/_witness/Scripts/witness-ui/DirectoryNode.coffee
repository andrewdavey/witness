# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.DirectoryNode = class DirectoryNode extends TreeNode

	constructor: (name, tree) ->
		super tree
		@text name

	templateId: "directory-node"
