# reference "Witness.coffee"
# reference "TimeoutError.coffee"

this.Witness.AsyncAction = class AsyncAction
	
	constructor: (@name, @func, @args, @timeout = AsyncAction.defaultTimeout) ->
		
	run: (context, done, fail) ->
		cancelledByTimeout = false
		context.done = ->
			if not cancelledByTimeout
				clearTimeout timeoutId
				done()

		context.fail = (args...) ->
			if not cancelledByTimeout
				clearTimeout timeoutId
				fail.apply(null, args)

		failDueToTimeout = ->
			cancelledByTimeout = true
			delete timeoutId
			fail new Witness.TimeoutError "Asynchronous action timed out."

		timeoutId = setTimeout failDueToTimeout, @timeout
		try
			@func.apply context, @args
		catch e
			clearTimeout timeoutId
			fail e


AsyncAction.defaultTimeout = 1000 # milliseconds