# reference "../OuterScenario.coffee"
# reference "ViewModels.coffee"
# reference "ScenarioViewModel.coffee"
# reference "OuterScenarioViewModel.coffee"

{ OuterScenario } = @Witness
{ OuterScenarioViewModel, ScenarioViewModel } = @Witness.ViewModels

@Witness.ViewModels.createScenarioViewModel = (scenario) ->
	if scenario instanceof OuterScenario
		new OuterScenarioViewModel scenario
	else
		new ScenarioViewModel scenario
