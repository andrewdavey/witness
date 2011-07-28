# reference "_namespace.coffee"
# reference "Tree.coffee"
# reference "DirectoryNode.coffee"
# reference "SpecificationNode.coffee"
# reference "ScenarioNode.coffee"
# reference "OuterScenarioNode.coffee"
# reference "../witness/OuterScenario.coffee"

{ OuterScenario } = @witness
{ Tree, DirectoryNode, SpecificationNode, ScenarioNode, OuterScenarioNode } = @witness.ui

@witness.ui.treeBuilder =
	buildTree: (directory) ->
		tree = new Tree directory
		subDirectoryNodes = (@buildDirectoryNode d, tree, tree for d in directory.directories)
		specificationNodes = (@buildSpecificationNode s, tree, tree for s in @getSpecificationNodes(directory))
		tree.children subDirectoryNodes.concat specificationNodes
		tree

	buildDirectoryNode: (directory, tree, parentNode) ->
		directoryNode = new DirectoryNode directory.name, directory, tree, parentNode
		subDirectoryNodes = (@buildDirectoryNode d, tree, directoryNode for d in directory.directories)
		specificationNodes = (@buildSpecificationNode s, tree, directoryNode for s in @getSpecificationNodes(directory))
		childNodes = subDirectoryNodes.concat specificationNodes

		directoryNode.children childNodes
		directoryNode

	buildSpecificationNode: (specification, tree, parentNode) ->
		node = new SpecificationNode specification.description, specification, tree, parentNode
		scenarios = (@buildScenarioNode scenario, index, tree, node for scenario, index in specification.scenarios)
		node.children scenarios
		node

	buildScenarioNode: (scenario, index, tree, parentNode) ->
		if scenario instanceof OuterScenario
			node = new OuterScenarioNode scenario.given[0].description, scenario, tree, parentNode
			node.children (@buildScenarioNode child, index, tree, node for child, index in scenario.innerScenarios)
			node
		else
			new ScenarioNode "Scenario #{index + 1}", scenario, tree, parentNode

	getSpecificationNodes: (directoryData) ->
		specs = []
		for file in directoryData.files
			for spec in file.specifications
				specs.push spec
		specs
