# reference "TreeNode.coffee"

{ TreeNode } = @witness.ui
ui = @witness.ui

@witness.ui.DirectoryNode = class DirectoryNode extends TreeNode

	constructor: (name, directory, tree, parentNode) ->
		super tree, parentNode, directory
		@text name
		directory.on.running.addHandler =>
			@status "running"
		directory.on.passed.addHandler =>
			@status "passed"
		directory.on.failed.addHandler =>
			@status "failed"

	templateId: "directory-node"
