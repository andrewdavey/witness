# reference "Witness.coffee"

@Witness.TryAll = class TryAll
	
	constructor: (@actions) ->

	run: (context, done, fail) ->
		errors = []

		callDoneOrFail = ->
			if errors.length > 0
				fail errors
			else
				done()

		chainer = (next, action) -> 
			() ->
				action.run context, next, (error) ->
					errors.push error
					next()
				return

		tryAll = @actions.reduceRight chainer, callDoneOrFail
		tryAll()
