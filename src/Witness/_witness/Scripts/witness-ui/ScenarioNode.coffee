# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.ScenarioNode = class ScenarioNode extends TreeNode
	
	constructor: (name) ->
		super()
		@text name

	templateId: "scenario"
