# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "TryAll.coffee"
# reference "Event.coffee"

{ TryAll, Event, messageBus } = @witness

@witness.Specification = class Specification
	constructor: (@description, @scenarios) ->
		@all = new TryAll @scenarios
		@on = Event.define "running", "passed", "failed"

	run: (context, done, fail) ->
		@on.running.raise()
		messageBus.send "SpecificationRunning", this
		@all.run context,
			=>
				@on.passed.raise()
				messageBus.send "SpecificationPassed", this
				done()
			=>
				@on.failed.raise()
				messageBus.send "SpecificationFailed", this
				fail()
