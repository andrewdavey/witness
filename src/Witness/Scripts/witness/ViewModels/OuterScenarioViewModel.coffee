# reference "ViewModels.coffee"
# reference "../../lib/knockout.js"

this.Witness.ViewModels.OuterScenarioViewModel = class OuterScenarioViewModel

	constructor: (@outerScenario) ->
		@status = ko.observable "notrun"
		@outerScenario.on.run.addHandler => @status "running"
		@outerScenario.on.done.addHandler => @status "passed"
		@outerScenario.on.fail.addHandler (error) => @status "failed"

	run: (context, done, fail) ->
		@outerScenario.run {}, done, fail
