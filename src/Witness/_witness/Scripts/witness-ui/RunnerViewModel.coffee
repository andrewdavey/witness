# reference "_namespace.coffee"
# reference "treeBuilder.coffee"
# reference "ScenarioViewModel.coffee"

{ treeBuilder, ScenarioNode, SpecificationNode, ScenarioViewModel } = @Witness.ui

@Witness.ui.RunnerViewModel = class RunnerViewModel

	constructor: (manifest) ->
		@tree = treeBuilder.buildTree manifest.rootDirectory
		@activeItem = ko.observableArray [ { templateId: "no-active-item" } ]
		
		@tree.nodeSelected.addHandler (node) =>
			if node instanceof ScenarioNode
				@activeItem [ new ScenarioViewModel node.scenario ]
			else if node instanceof SpecificationNode
				@activeItem [ { templateId: "specification" } ]

	templateId: "runner"

	activeItemTemplateId: (item) ->
		item.templateId
		

