# reference "../Witness.coffee"
# reference "../Specification.coffee"
# reference "../Scenario.coffee"
# reference "../Action.coffee"
# reference "../Assertion.coffee"
# reference "../Dsl.coffee"

this.Witness.Dsl::describe = (specificationName, scenariosDefinitions...) ->
	scenarios = (createScenario scenario for scenario in scenariosDefinitions)
	specification = new Witness.Specification specificationName, scenarios

	if not this.specifications
		this.specifications = []
	this.specifications.push specification


createScenario = (scenario) ->
	createActions = (input) -> (createAction definition for definition in ensureArray input)
	givens   = createActions scenario.given
	whens    = createActions scenario.when
	thens    = createActions scenario.then
	disposes = createActions scenario.dispose

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
		when "function" 
			action = createActionFromFunction definition

		when "object"
			if isAnActionObject definition
				action = definition
			else
				throw new Error "Unknown type of action definition."

		else throw new Error "Unknown type of action definition."

	return action

isAnActionObject = (object) -> "run" of object

createActionFromFunction = (func) ->
	if func.async?
		new Witness.AsyncAction func.toString(), func, [], func.async.timeout 
	else
		new Witness.Action func.toString(), func, []