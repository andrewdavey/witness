# reference "_namespace.coffee"
# reference "treeBuilder.coffee"
# reference "ScenarioViewModel.coffee"
# reference "SpecificationViewModel.coffee"
# reference "IframeManager.coffee"
# reference "../witness/TryAll.coffee"
# reference "../witness/Event.coffee"
# reference "../witness/MessageBus.coffee"

{ TryAll, Event, messageBus } = @witness
{
	treeBuilder,
	ScenarioNode,
	SpecificationNode,
	ScenarioViewModel,
	SpecificationViewModel,
	IframeManager
} = @witness.ui

@witness.ui.RunnerViewModel = class RunnerViewModel

	constructor: (rootDirectory) ->
		@rootDirectory = rootDirectory
		@tree = treeBuilder.buildTree rootDirectory
		@scenarioViewModels = {} # ID -> view model
		@activeItemModel = ko.observable null
		@activeItem = ko.observableArray []
		@iframeManager = new IframeManager()
		@canRun = ko.observable yes
		@setupInvoked = new Event()
		@status = ko.observable ""
		@showScenarioActions = ko.observable no

		createScenarioViewModels = =>
			@tree.map (node) =>
				if node instanceof ScenarioNode
					@scenarioViewModels[node.data.uniqueId] = new ScenarioViewModel node.data
		createScenarioViewModels()
		@tree.rebuilt.addHandler -> createScenarioViewModels()

		@canRunSelected = ko.dependentObservable =>
			@canRun() and @activeItemModel()?
		@tree.nodeSelected.addHandler (node) =>
			@treeNodeSelected node

	templateId: "runner-screen"

	activeItemTemplateId: (item) ->
		item.templateId
		
	getScenarioViewModel: (scenario) ->
		id = scenario.uniqueId
		if id of @scenarioViewModels
			@scenarioViewModels[id]
		else
			throw new Error "A scenario view model does not exist for scenario #{id}."

	treeNodeSelected: (node) ->
		@activeItemModel node.data
		if node instanceof ScenarioNode
			@activeItem [ @getScenarioViewModel node.data ]
			@iframeManager.show node.data.uniqueId

		else if node instanceof SpecificationNode
			@activeItem [ new SpecificationViewModel node.data ]
			@iframeManager.hideActive()

		else
			@activeItem.removeAll()
			@iframeManager.hideActive()

	run: (item) ->
		@canRun no
		@status "Running..."
		passedOrFailed = =>
			@canRun yes
			@status ""
			messageBus.send "RunnerFinished"
		item.run {}, passedOrFailed, passedOrFailed

	runAll: ->
		@run @rootDirectory

	runSelected: ->
		@run @activeItemModel()

	reloadSelected: ->
		@activeItemModel()?.download()

	setup: ->
		@setupInvoked.raise()
