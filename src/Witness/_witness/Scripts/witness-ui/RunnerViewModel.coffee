# reference "_namespace.coffee"
# reference "DirectoryNode.coffee"
# reference "SpecificationNode.coffee"
# reference "ScenarioNode.coffee"
# reference "OuterScenarioNode.coffee"

{ DirectoryNode, SpecificationNode, ScenarioNode, OuterScenarioNode } = @Witness.ui

@Witness.ui.RunnerViewModel = class RunnerViewModel

	constructor: (manifest) ->
		@treeRoot = treeBuilder.buildDirectoryNode manifest.rootDirectory

	templateId: "runner"


# Utilities

treeBuilder =
	buildDirectoryNode: (directory) ->
		subDirectoryNodes = (@buildDirectoryNode d for d in directory.directories)
		specificationNodes = (@buildSpecificationNode s for s in @getSpecificationNodes(directory))
		childNodes = subDirectoryNodes.concat specificationNodes

		directoryNode = new DirectoryNode directory.name
		directoryNode.children childNodes
		directoryNode

	buildSpecificationNode: (specification) ->
		node = new SpecificationNode specification.description
		scenarios = (@buildScenarioNode scenario, index for scenario, index in specification.scenarios)
		node.children scenarios
		node

	buildScenarioNode: (scenario, index) ->
		if scenario instanceof Witness.OuterScenario
			node = new OuterScenarioNode scenario.given.description
			node.children (@buildScenarioNode child, index for child, index in scenario.innerScenarios)
			node
		else
			new ScenarioNode "Scenario #{index + 1}"

	getSpecificationNodes: (directoryData) ->
		specs = []
		for file in directoryData.files
			for spec in file.specifications
				specs.push spec
		specs
