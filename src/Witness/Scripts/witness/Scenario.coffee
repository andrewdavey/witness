# reference "Witness.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"

globalIndex = 0

this.Witness.Scenario = class Scenario
	
	constructor: (@parts) ->
		{@given, @when, @then, @dispose} = @parts
		for name in ["given","when","then","dispose"]
			if not @[name]?
				@[name] = { description: name, actions: [] }
	
		assertions = (new Witness.Assertion action for action in @then.actions)
		tryAllAssertions = new Witness.TryAll assertions
		sequence = new Witness.Sequence [].concat @given.actions, @when.actions, tryAllAssertions
		# The disposes must *always* run, even if the previous sequence fails.
		# So combine them using a TryAll.
		if @dispose.actions.length > 0
			@aggregateAction = new Witness.TryAll [].concat sequence, @dispose.actions
		else
			@aggregateAction = sequence

		@index = globalIndex++

	run: (outerContext, done, fail) ->
		context = {}
		@aggregateAction.run context, done, fail
