# reference "Witness.coffee"
# reference "Event.coffee"

{ Event } = @witness

createDescriptionFromFunction = (func) ->
	s = func.toString()
	match = s.match /function\s*\(\)\s*{\s*return\s*(.*)\s*;\s*}/
	return match[1] if match
	return s

@witness.Assertion = class Assertion
	constructor: (@action) ->
		if @action.description
			@description = @action.description
		else
			@description = createDescriptionFromFunction @action.func

		@on = Event.define "running", "passed", "failed"

	run: (context, assertionDone, assertionFail) ->
		@on.running.raise()

		done = (result) =>
			if typeof result == "undefined" # no error thrown, so treat as success
				@on.passed.raise()
				assertionDone()
			else if result == true
				@on.passed.raise()
				assertionDone()
			else
				error = new Error "Assertion failed: " + @description
				error.fromAssertion = true
				@on.failed.raise error
				assertionFail error

		@action.run context,
			done
			(error) =>
				@on.failed.raise error
				assertionFail error
