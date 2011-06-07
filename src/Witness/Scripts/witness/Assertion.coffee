# reference "Witness.coffee"

this.Witness.Assertion = class Assertion
	constructor: (@action) ->
		@name = @action.name

	run: (context, assertionDone, assertionFail) ->
		done = (result) =>
			if typeof result == "undefined" # no error thrown, so treat as success
				assertionDone()
			else if result == true
				assertionDone()
			else
				assertionFail new Error "Assertion failed: " + @name

		@action.run context, done, assertionFail