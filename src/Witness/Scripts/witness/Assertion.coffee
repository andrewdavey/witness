# reference "Witness.coffee"

this.Witness.Assertion = class Assertion
	constructor: (@name, @func, @args) ->

	run: (context, done, fail) ->
		result = null
		try
			result = @func.apply(context, @args)
		catch error
			fail error
			return

		if typeof result == "undefined" # no error thrown, so treat as success
			done()
		else if result == true
			done()
		else
			fail new Error "Assertion failed: " + @name
	