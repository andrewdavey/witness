# reference "Witness.coffee"

this.Witness.OuterScenario = class OuterScenario

	constructor: (parts, @innerScenarios) ->
		{@given, @dispose} = parts
		@on = Witness.Event.define "run", "done", "fail"
		children = new Witness.TryAll @innerScenarios
		sequence = new Witness.Sequence [].concat @given.actions, children 
		@action = if @dispose.actions.length > 0
			new Witness.TryAll [sequence].concat @dispose.actions
		else
			sequence

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
