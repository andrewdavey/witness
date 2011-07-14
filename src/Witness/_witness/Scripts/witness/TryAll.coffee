# reference "Witness.coffee"

# TryAll is an asynchronous action. Although each child action executes
# in the original order. setTimeout is used to queue the next action
# after the previous completes. This avoid overflowing the stack when
# a large number of actions are running.
@Witness.TryAll = class TryAll
	
	constructor: (@actions) ->

	run: (context, done, fail) ->
		actions = @actions.slice(0) # copy of the array
		errors = []

		runNext = ->
			action = actions.shift()
			if action?
				action.run context,
					-> queueNext()
					(error) ->
						errors.push error
						queueNext()
			else
				callDoneOrFail()

		callDoneOrFail = ->
			if errors.length > 0
				fail errors
			else
				done()

		# User setTimeout to avoid blowing up the stack when lots of 
		# actions are to be run.
		queueNext = -> setTimeout runNext, 1

		# Start running...
		queueNext()
