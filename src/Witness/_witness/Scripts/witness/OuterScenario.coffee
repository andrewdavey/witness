# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "Event.coffee"
# reference "TryAll.coffee"
# reference "Sequence.coffee"
# reference "Scenario.coffee"

{ Event, TryAll, Sequence, Scenario, messageBus } = @witness
{ flattenArray } = @witness.helpers

@witness.OuterScenario = class OuterScenario extends Scenario

	constructor: (parts, @innerScenarios, @id) ->
		{@given, @dispose} = parts
		@on = Event.define "running", "passed", "failed"
		
		getActions = (part) -> flattenArray (item.actions for item in part)
		buildChildSequence = (child) =>
			new TryAll [].concat(
				(new Sequence [].concat(getActions(@given), child)),
				getActions(@dispose)
			)

		@action = new TryAll (buildChildSequence child for child in @innerScenarios)

	setParentSpecification: (parent) ->
		super parent
		for child in @innerScenarios
			child.setParentSpecification parent

	run: (outerContext, done, fail) ->
		messageBus.send "OuterScenarioRunning", this
		@on.running.raise()
		context =
			scenario: this
		@action.run context,
			=>
				messageBus.send "OuterScenarioPassed", this
				@on.passed.raise()
				done()
			(error) =>
				messageBus.send "OuterScenarioFailed", this
				@on.failed.raise(error)
				fail(error)
