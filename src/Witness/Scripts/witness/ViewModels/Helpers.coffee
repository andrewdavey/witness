# reference "../OuterScenario.coffee"
# reference "ViewModels.coffee"
# reference "ScenarioViewModel.coffee"
# reference "OuterScenarioViewModel.coffee"

{ OuterScenario } = @Witness
ViewModels = @Witness.ViewModels

ViewModels.createScenarioViewModel = (scenario) ->
	if scenario instanceof OuterScenario
		new ViewModels.OuterScenarioViewModel scenario
	else
		new ViewModels.ScenarioViewModel scenario
