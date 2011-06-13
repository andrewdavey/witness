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
	parts = {}
	for name in ["given","when","then","dispose"]
		parts[name] = findPart name, scenario

	new Witness.Scenario parts

findPart = (name, scenario) ->
	startsWith = new RegExp "^#{name}", "i"
	for own key, value of scenario
		match = key.match startsWith
		if match
			return {
				description: key
				actions: flatten createActions value
			}

	return {
		description: name 
		actions: []
	}

createActions = (input) ->
	(createAction definition for definition in ensureArray input)

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
				action = createActionsFromObject definition

		else throw new Error "Unknown type of action definition."

	return action

isAnActionObject = (object) -> "run" of object

createActionFromFunction = (func) ->
	if func.async?
		new Witness.AsyncAction "", func, [], func.async.timeout 
	else
		new Witness.Action "", func, []

createActionsFromObject = (object, parentNames = []) ->
	if typeof object == "function"
		if parentNames[parentNames.length - 1] == "this"
			parentNames = parentNames[0...parentNames.length - 1]
		object.apply(null, parentNames)
	else if $.isArray object
		(createActionsFromObject(value, parentNames.concat(i)) for value, i in object)
	else if typeof object == "object"
		(createActionsFromObject(value, parentNames.concat(key)) for own key, value of object)
	else
		throw new TypeError "Input must be a Function, Array or Object."

flatten = (input) ->
	output = []
	for item in input
		if $.isArray item
			output = output.concat flatten item
		else
			output.push item
	output
