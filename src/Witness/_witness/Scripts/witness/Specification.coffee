# reference "Witness.coffee"
# reference "MessageBus.coffee"
# reference "TryAll.coffee"
# reference "Event.coffee"

{ TryAll, Event, messageBus } = @witness

@witness.Specification = class Specification
	constructor: (@description, @scenarios) ->
		@all = new TryAll @scenarios
		@on = Event.define "running", "passed", "failed"

		# Useful to assign the parent of each scenario so the UI can display
		# information such as spec file path.
		for scenario in @scenarios
			scenario.setParentSpecification this

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
