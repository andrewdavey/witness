# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @witness.ui

@witness.ui.SpecificationNode = class SpecificationNode extends TreeNode

	constructor: (name, @specification, tree) ->
		super tree, @specification
		@text name
		@specification.on.running.addHandler =>
			@status "running"
		@specification.on.passed.addHandler =>
			@status "passed"
		@specification.on.failed.addHandler =>
			@status "failed"

	templateId: "specification-node"
