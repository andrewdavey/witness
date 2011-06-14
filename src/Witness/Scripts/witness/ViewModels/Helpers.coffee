# reference "ViewModels.coffee"

this.Witness.ViewModels.createScenarioViewModel = (scenario) ->
	if scenario instanceof Witness.OuterScenario
		new Witness.ViewModels.OuterScenarioViewModel scenario
	else
		new Witness.ViewModels.ScenarioViewModel scenario
