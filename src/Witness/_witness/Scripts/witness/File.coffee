# reference "Witness.coffee"
# reference "Event.coffee"
# reference "TryAll.coffee"
# reference "MessageBus.coffee"

{ messageBus, Event, TryAll } = @Witness

@Witness.File = class File

	constructor: (@name, @specifications) ->
		@on = Event.define "running", "passed", "failed"
	
	run: (context, done, fail) ->
		messageBus.send "SpecificationFileRunning", this
		@on.running.raise()
		tryAll = new TryAll @specifications
		tryAll.run context,
			=>
				messageBus.send "SpecificationFilePassed", this
				@on.passed.raise()
				done()
			(error) =>
				messageBus.send "SpecificationFileFailed", this
				@on.failed.raise(error)
				fail(error)
