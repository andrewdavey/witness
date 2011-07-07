# reference "../Witness.coffee"
# reference "../Specification.coffee"
# reference "../Scenario.coffee"
# reference "../OuterScenario.coffee"
# reference "../Action.coffee"
# reference "../AsyncAction.coffee"
# reference "../Assertion.coffee"
# reference "../Dsl.coffee"
# reference "../helpers.coffee"

{ Action, AsyncAction, Specification, Scenario, OuterScenario, Assertion } = @Witness
{ flattenArray } = @Witness.helpers

@Witness.Dsl::describe = (specificationName, scenariosDefinitions...) ->
	idGenerator = new IdGenerator()
	scenarios = (createScenario(scenario, idGenerator) for scenario in scenariosDefinitions)
	specification = new Specification specificationName, scenarios

	if not this.specifications
		this.specifications = []
	this.specifications.push specification
	specification


# Scenarios need an Id generated.
# Scenarios can be be nested. So adopt a 1.2.3 numbering scheme.
class IdGenerator
	constructor: ->
		# Start with top-level numbering.
		@nextIdStack = [0]

	getNext: ->
		# Increment current level of numbering
		@nextIdStack[@nextIdStack.length - 1]++
		@nextIdStack.join "."

	push: ->
		# Start a new level of numbering
		@nextIdStack.push 0

	pop: ->
		# Exit the current level of numbering
		@nextIdStack.pop()

createScenario = (scenario, idGenerator) ->
	parts = {}
	for name in ["given","when","then","dispose"]
		parts[name] = findPart name, scenario
	for own name, value of parts
		parts[name].actions = flattenArray createActions flattenArray value.actions
	isOuter = scenario.inner?
	if isOuter
		idGenerator.push()
		children = (createScenario item, idGenerator for item in scenario.inner)
		idGenerator.pop()
		new OuterScenario parts, children, idGenerator.getNext()
	else
		parts.then.actions = (new Assertion action for action in parts.then.actions)
		new Scenario parts, idGenerator.getNext()

findPart = (name, scenario) ->
	startsWith = new RegExp "^#{name}", "i"
	for own key, value of scenario
		match = key.match startsWith
		if match
			return {
				description: key
				actions: value
			}

	return {
		description: name 
		actions: []
	}

createActions = (input) ->
	(createAction definition for definition in ensureArray input)

ensureArray = (arrayOrObject) ->
	if arrayOrObject?
		if jQuery.isArray arrayOrObject
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
		new AsyncAction func, [], func.toString(), func.async.timeout 
	else
		new Action func, [], func.toString()

createActionsFromObject = (object, parentNames = []) ->
	if typeof object == "function"
		if parentNames[parentNames.length - 1] == "this"
			parentNames = parentNames[0...parentNames.length - 1]
		object.apply(null, parentNames)
	else if jQuery.isArray object
		(createActionsFromObject(value, parentNames.concat(i)) for value, i in object)
	else if typeof object == "object"
		(createActionsFromObject(value, parentNames.concat(key)) for own key, value of object)
	else
		throw new TypeError "Input must be a Function, Array or Object."

