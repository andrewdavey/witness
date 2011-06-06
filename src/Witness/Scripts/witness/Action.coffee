# reference "Witness.coffee"

this.Witness.Action = class Action

	constructor: (@name, @func, @args) ->

	run: (context, done, fail) ->
		try
			@func.apply context, @args
			done()
		catch error
			fail error