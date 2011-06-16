# reference "Witness.coffee"

this.Witness.Specification = class Specification
	constructor: (@description, @scenarios) ->
		@all = new Witness.TryAll @scenarios

	run: (context, done, fail) ->
		Witness.messageBus.send "SpecificationRunning", this
		@all.run context,
			->
				Witness.messageBus.send "SpecificationPassed", this
				done()
			->
				Witness.messageBus.send "SpecificationFailed", this
				fail()
