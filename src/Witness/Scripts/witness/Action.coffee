# reference "Witness.coffee"

this.Witness.Action = class Action

	constructor: (@name, @func, @args) ->
		throw new TypeError("The func parameter of Witness.Action must be a function.") if typeof @func != "function"

	run: (context, done, fail) ->
		try
			result = @func.apply context, @args
			done result
		catch error
			fail error