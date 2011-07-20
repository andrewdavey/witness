# reference "../OuterScenario.coffee"
# reference "ViewModels.coffee"

{ OuterScenario, ViewModels } = @witness

ViewModels.createScenarioViewModel = (scenario) ->
	if scenario instanceof OuterScenario
		new ViewModels.OuterScenarioViewModel scenario
	else
		new ViewModels.ScenarioViewModel scenario
