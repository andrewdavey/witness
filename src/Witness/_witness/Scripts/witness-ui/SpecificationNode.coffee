# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @witness.ui

@witness.ui.SpecificationNode = class SpecificationNode extends TreeNode

	constructor: (name, @specification, tree, parentNode) ->
		super tree, parentNode, @specification
		@text name
		@specification.on.running.addHandler =>
			@status "running"
		@specification.on.passed.addHandler =>
			@status "passed"
		@specification.on.failed.addHandler =>
			@status "failed"

		# When our parent file is downloaded again, remove this node.
		# The directory will create a new node once it's downloaded.
		@specification.parentFile.on.downloading.addHandler => @remove()

	templateId: "specification-node"
