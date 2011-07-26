# reference "Witness.coffee"
# reference "Event.coffee"
# reference "TimeoutError.coffee"

{ Event, TimeoutError } = @witness

@witness.AsyncAction = class AsyncAction
	
	constructor: (@func, @args = [], @description, @timeout = AsyncAction.defaultTimeout) ->
		@on = Event.define "running", "passed", "failed"

	run: (context, done, fail) ->
		@on.running.raise()

		cancelledByTimeout = false
		context.done = (args...)=>
			if not cancelledByTimeout
				clearTimeout timeoutId
				@on.passed.raise()
				done.apply(null,args)

		context.fail = (args...) =>
			if not cancelledByTimeout
				clearTimeout timeoutId
				@on.failed.raise.apply @on.failed, args
				fail.apply(null, args)

		failDueToTimeout = =>
			cancelledByTimeout = true
			delete timeoutId
			error = new TimeoutError "Asynchronous action timed out."
			@on.failed.raise error
			fail error
		
		timeoutId = setTimeout failDueToTimeout, @timeout if @timeout > 0
		try
			@func.apply context, @args
		catch e
			clearTimeout timeoutId
			fail e
			@on.failed.raise e


AsyncAction.defaultTimeout = 10000 # milliseconds
