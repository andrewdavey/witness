# reference "Witness.coffee"

this.Witness.OuterScenario = class OuterScenario

	constructor: (parts, @innerScenarios) ->
		{@given, @dispose} = parts
		@on = Witness.Event.define "run", "done", "fail"
		
		buildChildSequence = (child) =>
			new Witness.Sequence [].concat(@given.actions, child, @dispose.actions)

		@action = new Witness.TryAll (buildChildSequence child for child in @innerScenarios)

	run: (outerContext, done, fail) ->
		Witness.messageBus.send "OuterScenarioRunning", this
		@on.run.raise()
		@action.run {},
			=>
				Witness.messageBus.send "OuterScenarioPassed", this
				@on.done.raise()
				done()
			(error) =>
				Witness.messageBus.send "OuterScenarioFailed", this
				@on.fail.raise(error)
				fail(error)
