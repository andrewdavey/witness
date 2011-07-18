# reference "_namespace.coffee"
# reference "treeBuilder.coffee"
# reference "ScenarioViewModel.coffee"
# reference "SpecificationViewModel.coffee"
# reference "IframeManager.coffee"
# reference "../witness/TryAll.coffee"

{ TryAll } = @Witness
{
	treeBuilder,
	ScenarioNode,
	SpecificationNode,
	ScenarioViewModel,
	SpecificationViewModel,
	IframeManager
} = @Witness.ui

@Witness.ui.RunnerViewModel = class RunnerViewModel

	constructor: (manifest) ->
		@tree = treeBuilder.buildTree manifest.rootDirectory
		@scenarioViewModels = {} # ID -> view model
		@activeItemModel = null
		@activeItem = ko.observableArray []
		@iframeManager = new IframeManager()
		@canRun = ko.observable yes

		@tree.map (node) =>
			if node instanceof ScenarioNode
				@scenarioViewModels[node.data.uniqueId] = new ScenarioViewModel node.data

		@canRunSelected = ko.dependentObservable =>
			@canRun() and @activeItem().length > 0
		@tree.nodeSelected.addHandler (node) =>
			@treeNodeSelected node

	templateId: "runner-screen"

	activeItemTemplateId: (item) ->
		item.templateId
		
	getScenarioViewModel: (scenario) ->
		id = scenario.uniqueId
		@scenarioViewModels[id]

	treeNodeSelected: (node) ->
		if node instanceof ScenarioNode
			@activeItemModel = node.data
			@activeItem [ @getScenarioViewModel node.data ]
			@iframeManager.show node.data.uniqueId

		else if node instanceof SpecificationNode
			@activeItemModel = node.data
			@activeItem [ new SpecificationViewModel node.data ]
			@iframeManager.hideActive()

		else
			@activeItemModel = null
			@activeItem.removeAll()
			@iframeManager.hideActive()

	run: (item) ->
		@canRun no
		passedOrFailed = =>
			@canRun yes
		item.run {}, passedOrFailed, passedOrFailed

	runAll: ->
		models = (node.data for node in @tree.nodes())
		action = new TryAll models
		@run action

	runSelected: ->
		@run @activeItemModel
