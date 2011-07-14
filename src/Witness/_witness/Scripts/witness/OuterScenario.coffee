# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "Event.coffee"
# reference "TryAll.coffee"
# reference "Sequence.coffee"
# reference "Scenario.coffee"

{ Event, TryAll, Sequence, Scenario, messageBus } = @Witness

@Witness.OuterScenario = class OuterScenario extends Scenario

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
		context =
			scenario: this
		@action.run context,
			=>
				messageBus.send "OuterScenarioPassed", this
				@on.done.raise()
				done()
			(error) =>
				messageBus.send "OuterScenarioFailed", this
				@on.fail.raise(error)
				fail(error)
