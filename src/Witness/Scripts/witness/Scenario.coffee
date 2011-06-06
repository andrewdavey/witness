# reference "Witness.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"

this.Witness.Scenario = class Scenario
	
	constructor: (@setupActions, @actions, @assertions, @disposeActions) ->
		allActions = [].concat @setupActions, @actions, new Witness.TryAll(@assertions), disposeActions
		@sequence = new Witness.Sequence allActions

	run: (outerContext, done, fail) ->
		context = {}
		@sequence.run context, done, fail
