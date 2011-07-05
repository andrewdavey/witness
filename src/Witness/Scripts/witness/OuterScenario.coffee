# reference "Witness.coffee"

{ Event, TryAll, Sequence, messageBus } = @Witness

@Witness.OuterScenario = class OuterScenario

	constructor: (parts, @innerScenarios, @id) ->
		{@given, @dispose} = parts
		@on = Event.define "run", "done", "fail"
		
		buildChildSequence = (child) =>
			new TryAll [].concat(
				(new Sequence [].concat(@given.actions, child)),
				@dispose.actions
			)

		@action = new TryAll (buildChildSequence child for child in @innerScenarios)

	run: (outerContext, done, fail) ->
		messageBus.send "OuterScenarioRunning", this
		@on.run.raise()
		@action.run {},
			=>
				messageBus.send "OuterScenarioPassed", this
				@on.done.raise()
				done()
			(error) =>
				messageBus.send "OuterScenarioFailed", this
				@on.fail.raise(error)
				fail(error)
