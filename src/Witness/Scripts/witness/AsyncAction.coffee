# reference "Witness.coffee"
# reference "TimeoutError.coffee"

this.Witness.AsyncAction = class AsyncAction
	
	constructor: (@name, @func, @args, @timeout = AsyncAction.defaultTimeout) ->
		
	run: (context, done, fail) ->
		context.done = ->
			clearTimeout timeoutId
			done()

		context.fail = (args...) ->
			clearTimeout timeoutId
			fail.apply(null, args)

		failDueToTimeout = ->
			fail new Witness.TimeoutError "Asynchronous action timed out."
		timeoutId = setTimeout failDueToTimeout, @timeout

		try
			@func.apply context, @args
		catch e
			fail e


AsyncAction.defaultTimeout = 1000 # milliseconds