# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.OuterScenarioNode = class OuterScenarioNode extends TreeNode

	constructor: (name, tree) ->
		super tree
		@text name

	templateId: "outer-scenario-node"
