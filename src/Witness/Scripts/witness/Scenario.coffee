# reference "Witness.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"

this.Witness.Scenario = class Scenario
	
	constructor: (@setupActions, @actions, @assertionActions, @disposeActions) ->
		assertions = (new Witness.Assertion action for action in @assertionActions)
		tryAllAssertions = new Witness.TryAll assertions
		sequence = new Witness.Sequence [].concat @setupActions, @actions, tryAllAssertions
		# The dispose actions must *always* run, even if the previous sequence fails.
		# So combine them using a TryAll.
		@aggregateAction = new Witness.TryAll [].concat sequence, disposeActions

	run: (outerContext, done, fail) ->
		context = {}
		@aggregateAction.run context, done, fail
