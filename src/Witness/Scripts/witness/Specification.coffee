# reference "Witness.coffee"
# reference "MessageBus.coffee"

{ TryAll, Event } = @Witness

@Witness.Specification = class Specification
	constructor: (@description, @scenarios) ->
		@all = new TryAll @scenarios
		@on = Event.define "running", "passed", "failed"

	run: (context, done, fail) ->
		@on.running.raise()
		Witness.messageBus.send "SpecificationRunning", this
		@all.run context,
			=>
				@on.passed.raise()
				Witness.messageBus.send "SpecificationPassed", this
				done()
			=>
				@on.failed.raise()
				Witness.messageBus.send "SpecificationFailed", this
				fail()
