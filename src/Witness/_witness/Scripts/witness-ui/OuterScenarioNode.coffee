# reference "_namespace.coffee"
# reference "TreeNode.coffee"

{ TreeNode } = @Witness.ui

@Witness.ui.OuterScenarioNode = class OuterScenarioNode extends TreeNode

	constructor: (name, outerScenario, tree) ->
		super tree, outerScenario
		@text name
		outerScenario.on.running.addHandler => @status "running"
		outerScenario.on.passed.addHandler => @status "passed"
		outerScenario.on.failed.addHandler => @status "failed"

	templateId: "outer-scenario-node"
