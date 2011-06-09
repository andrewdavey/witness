# reference "Witness.coffee"
# reference "Event.coffee"

this.Witness.Action = class Action

	constructor: (@name, @func, @args) ->
		throw new TypeError("The func parameter of Witness.Action must be a function.") if typeof @func != "function"
		@on =
			run: new Witness.Event()
			done: new Witness.Event()
			fail: new Witness.Event()

	run: (context, done, fail) ->
		@on.run.raise()
		try
			result = @func.apply context, @args
			@on.done.raise()
			done result
		catch error
			@on.fail.raise error
			fail error