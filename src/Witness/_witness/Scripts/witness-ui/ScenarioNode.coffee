# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.ScenarioNode = class ScenarioNode extends TreeNode
	
	constructor: (name, @scenario, tree) ->
		super tree, @scenario
		@text name
		@scenario.on.running.addHandler => @status "running"
		@scenario.on.passed.addHandler => @status "passed"
		@scenario.on.failed.addHandler => @status "failed"

	templateId: "scenario-node"
