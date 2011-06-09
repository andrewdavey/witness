# reference "Witness.coffee"
# reference "Event.coffee"

this.Witness.Assertion = class Assertion
	constructor: (@action) ->
		@name = @action.name
		@on =
			run: new Witness.Event()
			done: new Witness.Event()
			fail: new Witness.Event()

	run: (context, assertionDone, assertionFail) ->
		@on.run.raise()

		done = (result) =>
			if typeof result == "undefined" # no error thrown, so treat as success
				@on.done.raise()
				assertionDone()
			else if result == true
				@on.done.raise()
				assertionDone()
			else
				error = new Error "Assertion failed: " + @name
				@on.done.raise error
				assertionFail error

		@action.run context,
			done
			(error) =>
				@on.fail.raise error
				assertionFail error