# reference "Witness.coffee"

this.Witness.Specification = class Specification
	constructor: (@description, @scenarios) ->
		@all = new Witness.TryAll @scenarios

	run: (context, done, fail) ->
		@all.run context, done, fail