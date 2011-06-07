# reference "Witness.coffee"

this.Witness.Action = class Action

	constructor: (@name, @func, @args) ->

	run: (context, done, fail) ->
		try
			result = @func.apply context, @args
			done result
		catch error
			fail error