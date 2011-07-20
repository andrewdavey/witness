# reference "Witness.coffee"
# reference "Event.coffee"

{ Event } = @witness

@witness.Action = class Action

	constructor: (@func, @args = [], @description) ->
		throw new TypeError("The func parameter of Witness.Action must be a function.") if typeof @func != "function"
		@on = Event.define "running", "passed", "failed"

	run: (context, done, fail) ->
		@on.running.raise()
		try
			result = @func.apply context, @args
			@on.passed.raise()
			done result
		catch error
			@on.failed.raise error
			fail error
