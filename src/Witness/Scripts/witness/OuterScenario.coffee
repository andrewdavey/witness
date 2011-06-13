# reference "Witness.coffee"

this.Witness.OuterScenario = class OuterScenario

	constructor: (@description, @setupAction, @childScenarios) ->
		children = new Witness.TryAll @childScenario
		sequence = new Witness.Sequence [ @setupAction, children] 

	run: (outerContext, done, fail) ->
		sequence.run {}, done, fail
