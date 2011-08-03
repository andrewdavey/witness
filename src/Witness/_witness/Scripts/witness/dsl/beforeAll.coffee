# reference "../Dsl.coffee"
# reference "../Action.coffee"
# reference "../AsyncAction.coffee"

{ Action, AsyncAction, Dsl, Sequence } = @witness

hasRun = no
beforeAllAction = null

Dsl::beforeAll = (func) ->
	return if beforeAllAction? # Only define it once

	wrappedFunc = ->
		hasRun = yes
		func.call this

	beforeAllAction = if func.async?
		new AsyncAction wrappedFunc, [], "before all", func.timeout
	else
		new Action wrappedFunc

# In the UI when re-running we'll need to also re-run the beforeAll action
Dsl::beforeAll.reset = ->
	hasRun = no

# Chains the beforeAllAction ahead of the given action (but only once).
Dsl::beforeAll.putBefore = (action) ->
	# Ensure the beforeAllAction is run only once (if it exists).
	if beforeAllAction? and not hasRun
		return new Sequence [ beforeAllAction, action ]
	else
		# We've already run the beforeAllAction, so skip it.
		return action
