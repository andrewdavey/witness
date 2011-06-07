# reference "Witness.coffee"
# reference "Specification.coffee"
# reference "Scenario.coffee"
# reference "Action.coffee"
# reference "Assertion.coffee"
# reference "Dsl.coffee"

this.Witness.Dsl::functions.describe = (specificationName, scenariosDefinitions...) ->
	scenarios = (createScenario scenario for scenario in scenariosDefinitions)
	specification = new Witness.Specification specificationName, scenarios

	if not this.specifications
		this.specifications = []
	this.specifications.push specification


createScenario = (scenario) ->
	givens   = (createAction definition for definition in ensureArray scenario.given)
	whens    = (createAction definition for definition in ensureArray scenario.when)
	thens    = (createAssertion definition for definition in ensureArray scenario.then)
	disposes = (createAction definition for definition in ensureArray scenario.dispose)

	new Witness.Scenario givens, whens, thens, disposes

ensureArray = (arrayOrObject) ->
	if arrayOrObject?
		if $.isArray arrayOrObject
			arrayOrObject
		else
			[ arrayOrObject ]
	else
		return []

createAction = (definition) ->
	# TODO: Tidy this code when Jurrasic stops breaking CoffeeScript compiler!
	action = null
	switch typeof definition
		when "function" then action = createActionFromFunction definition
		else throw new Error "Unknown type of action definition."
	return action

createActionFromFunction = (func) ->
	new Witness.Action func.toString(), func, []

createAssertion = (definition) ->
	# TODO: Tidy this code when Jurrasic stops breaking CoffeeScript compiler!
	assertion = null
	switch typeof definition
		when "function" then assertion = createAssertionFromFunction definition
		else throw new Error "Unknown type of assertion definition."
	return assertion

createAssertionFromFunction = (func) ->
	new Witness.Assertion func.toString(), func, []