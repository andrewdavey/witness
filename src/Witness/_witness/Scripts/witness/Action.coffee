# reference "Witness.coffee"
# reference "Event.coffee"

{ Event } = @Witness

@Witness.Action = class Action

	constructor: (@func, @args = [], @description) ->
		throw new TypeError("The func parameter of Witness.Action must be a function.") if typeof @func != "function"
		@on = Event.define "run", "done", "fail"

	run: (context, done, fail) ->
		@on.run.raise()
		try
			result = @func.apply context, @args
			@on.done.raise()
			done result
		catch error
			@on.fail.raise error
			fail error
