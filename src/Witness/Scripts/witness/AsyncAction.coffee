# reference "Witness.coffee"
# reference "Event.coffee"
# reference "TimeoutError.coffee"

this.Witness.AsyncAction = class AsyncAction
	
	constructor: (@func, @args = [], @description, @timeout = AsyncAction.defaultTimeout) ->
		@on =
			run: new Witness.Event()
			done: new Witness.Event()
			fail: new Witness.Event()

	run: (context, done, fail) ->
		@on.run.raise()

		cancelledByTimeout = false
		context.done = (args...)=>
			if not cancelledByTimeout
				clearTimeout timeoutId
				@on.done.raise()
				done.apply(null,args)

		context.fail = (args...) =>
			if not cancelledByTimeout
				clearTimeout timeoutId
				@on.fail.raise.apply @on.fail, args
				fail.apply(null, args)

		failDueToTimeout = =>
			cancelledByTimeout = true
			delete timeoutId
			error = new Witness.TimeoutError "Asynchronous action timed out."
			@on.fail.raise error
			fail error
		
		timeoutId = setTimeout failDueToTimeout, @timeout if @timeout > 0
		try
			@func.apply context, @args
		catch e
			clearTimeout timeoutId
			fail e
			@on.fail.raise e


AsyncAction.defaultTimeout = 1000 # milliseconds
