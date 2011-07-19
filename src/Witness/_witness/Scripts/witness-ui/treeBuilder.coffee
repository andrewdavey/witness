# reference "_namespace.coffee"
# reference "Tree.coffee"
# reference "DirectoryNode.coffee"
# reference "SpecificationNode.coffee"
# reference "ScenarioNode.coffee"
# reference "OuterScenarioNode.coffee"

{ Tree, DirectoryNode, SpecificationNode, ScenarioNode, OuterScenarioNode } = @Witness.ui

@Witness.ui.treeBuilder =
	buildTree: (directory) ->
		tree = new Tree()
		subDirectoryNodes = (@buildDirectoryNode d, tree for d in directory.directories)
		specificationNodes = (@buildSpecificationNode s, tree for s in @getSpecificationNodes(directory))
		tree.nodes subDirectoryNodes.concat specificationNodes
		tree

	buildDirectoryNode: (directory, tree) ->
		subDirectoryNodes = (@buildDirectoryNode d, tree for d in directory.directories)
		specificationNodes = (@buildSpecificationNode s, tree for s in @getSpecificationNodes(directory))
		childNodes = subDirectoryNodes.concat specificationNodes

		directoryNode = new DirectoryNode directory.name, directory, tree
		directoryNode.children childNodes
		directoryNode

	buildSpecificationNode: (specification, tree) ->
		node = new SpecificationNode specification.description, specification, tree
		scenarios = (@buildScenarioNode scenario, index, tree for scenario, index in specification.scenarios)
		node.children scenarios
		node

	buildScenarioNode: (scenario, index, tree) ->
		if scenario instanceof Witness.OuterScenario
			node = new OuterScenarioNode scenario.given.description, tree
			node.children (@buildScenarioNode child, index, tree for child, index in scenario.innerScenarios)
			node
		else
			new ScenarioNode "Scenario #{index + 1}", scenario, tree

	getSpecificationNodes: (directoryData) ->
		specs = []
		for file in directoryData.files
			for spec in file.specifications
				specs.push spec
		specs
