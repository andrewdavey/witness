# reference "Witness.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"

globalIndex = 0

createDescriptionFromFunction = (func) ->
	return "" if typeof func != "function"
	s = func.toString()
	match = s.match /function\s*\(\)\s*{\s*(.*)\s*}/
	return match[1] if match
	return s

this.Witness.Scenario = class Scenario
	
	constructor: (@parts) ->
		@on = Witness.Event.define "run", "done", "fail"
		{@given, @when, @then, @dispose} = @parts
		for name in ["given","when","then","dispose"]
			part = @[name]
			if part?
				if name != "then" and part.description.indexOf(' ') < 0 and part.actions.length > 0
					actionDescription = part.actions[0].description ? (createDescriptionFromFunction part.actions[0].func)
					part.description = "#{name} #{actionDescription}" 
			else
				@[name] = { description: name, actions: [] }
			
	
		tryAllAssertions = new Witness.TryAll @then.actions
		sequence = new Witness.Sequence [].concat @given.actions, @when.actions, tryAllAssertions
		# The disposes must *always* run, even if the previous sequence fails.
		# So combine them using a TryAll.
		if @dispose.actions.length > 0
			@aggregateAction = new Witness.TryAll [].concat sequence, @dispose.actions
		else
			@aggregateAction = sequence

		@index = globalIndex++

	run: (outerContext, done, fail) ->
		context = {}
		context[key] = value for own key, value of outerContext
		context.scenario = this
		context.window = window

		@on.run.raise()
		@aggregateAction.run(
			context
			=> @on.done.raise(); done()
			(error) => @on.fail.raise(error); fail(error)
		)


