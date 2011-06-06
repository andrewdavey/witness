# reference "Witness.coffee"

this.Witness.Sequence = class Sequence

	constructor: (@actions) ->

	run: (context, done, fail) ->

		chainer = (next, action) ->
			() -> action.run context, next, fail

		runSequence = @actions.reduceRight chainer, done
		runSequence()