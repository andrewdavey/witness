# reference "Witness.coffee"

@witness.Sequence = class Sequence

	constructor: (@actions) ->

	run: (context, done, fail) ->

		chainer = (next, action) ->
			innerDone = (result) ->
				if result and typeof result.run == "function"
					result.run context, next, fail
				else
					next(result)
			() -> action.run context, innerDone, fail

		runSequence = @actions.reduceRight chainer, done
		runSequence()
