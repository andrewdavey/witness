# reference "Witness.coffee"
# reference "Event.coffee"
# reference "TryAll.coffee"
# reference "MessageBus.coffee"

{ messageBus, Event, TryAll } = @Witness

@Witness.Directory = class Directory

	constructor: (@name, @directories, @files) ->
		@on = Event.define "running", "passed", "failed"

	run: (context, done, fail) ->
		messageBus.send "SpecificationDirectoryRunning", this
		@on.running.raise()
		all = @directories.concat @files
		tryAll = new TryAll all
		tryAll.run context,
			=>
				messageBus.send "SpecificationDirectoryPassed", this
				@on.passed.raise()
				done()
			(error) =>
				messageBus.send "SpecificationDirectoryFailed", this
				@on.failed.raise(error)
				fail(error)
