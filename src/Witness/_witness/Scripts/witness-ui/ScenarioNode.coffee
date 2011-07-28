# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @witness.ui

@witness.ui.ScenarioNode = class ScenarioNode extends TreeNode
	
	constructor: (name, @scenario, tree, parentNode) ->
		super tree, parentNode, @scenario
		@text name
		@scenario.on.running.addHandler => @status "running"
		@scenario.on.passed.addHandler => @status "passed"
		@scenario.on.failed.addHandler => @status "failed"

	templateId: "scenario-node"
