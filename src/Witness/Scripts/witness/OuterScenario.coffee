# reference "Witness.coffee"

this.Witness.OuterScenario = class OuterScenario

	constructor: (parts, @innerScenarios) ->
		{@given, @dispose} = parts
		children = new Witness.TryAll @innerScenarios
		sequence = new Witness.Sequence [].concat @given.actions, children 
		@action = if @dispose.actions.length > 0
			new Witness.TryAll [sequence].concat @dispose.actions
		else
			sequence

	run: (outerContext, done, fail) ->
		@action.run {}, done, fail
