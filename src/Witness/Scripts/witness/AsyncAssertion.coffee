# reference "Witness.coffee"

this.Witness.AsyncAssertion = class AsyncAssertion
	constructor: (@name, @func, @args, @timeout = AsyncAssertion.defaultTimeout) ->

	run: (context, done, fail) ->
		context.done = (result) =>
			clearTimeout timeoutId
			if typeof result == "undefined" # no error thrown, so treat as success
				done()
			else if result == true
				done()
			else
				fail new Error "Assertion failed: " + @name

		context.fail = (args...) ->
			clearTimeout timeoutId
			fail.apply(null, args)

		failDueToTimeout = ->
			fail new Witness.TimeoutError "Asynchronous assertion timed out."
		timeoutId = setTimeout failDueToTimeout, @timeout

		try
			@func.apply context, @args
		catch e
			fail e

AsyncAssertion.defaultTimeout = 1000 # milliseconds