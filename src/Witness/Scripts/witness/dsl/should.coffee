﻿# reference "../Dsl.coffee"

predicateActionBuilder = (options) ->
	(expected) ->
		(propertyNames...) ->
			fullName = createFullName propertyNames
			description = options.description fullName, expected
			func = () ->
				actual = decendPropertiesToValue this, propertyNames
				return if options.test.call this, actual, expected
				error = options.error fullName, actual, expected
				if typeof error == "string"
					throw new Error error
				else
					throw error
			new Witness.Action func, [], description

createFullName = (propertyNames) ->
	# [ "foo", 0, "bar" ] -> "foo[0].bar"
	fullName = []
	for name in propertyNames
		if typeof name == "number"
			fullName.push "[", name, "]"
		else
			if fullName.length > 0
				fullName.push "."
			fullName.push name
	fullName.join ""

decendPropertiesToValue = (object, propertyNames) ->
	for name in propertyNames
		object = object[name]
	object

printableValue = (value) ->
	if typeof value == "string"
		"\"#{value}\""
	else if typeof value == "function"
		# The function is usually something returning a value from the context.
		# So try to chop off the "function() { return this." and "; }" junk
		value = value.toString().replace /\r|\n/g, ""
		value = value.replace(/^function\s*\(\)\s*\{\s*return\s* this\.(.*);\s*\}$/, "$1")
		value
	else
		value

this.Witness.Dsl::predicateActionBuilder = predicateActionBuilder

this.Witness.Dsl::should = should =
	unwrapActual: (actual) -> actual

	be: predicateActionBuilder
		test: (actual, expected) ->
			actual = should.unwrapActual actual
			if typeof expected == "function"
				expected = expected.call this	
			actual == expected
		description: (fullName, expected) ->
			expected = printableValue expected
			"#{fullName} should be #{expected}"
		error: (fullName, actual, expected) ->
			actual = printableValue should.unwrapActual actual
			expected = printableValue expected
			"Expected #{fullName} to be #{expected} but was #{actual}"

	notBe: predicateActionBuilder
		test: (actual, expected) ->
			actual = should.unwrapActual actual
			if typeof expected == "function"
				expected = expected.call this	
			actual != expected
		description: (fullName, expected) ->
			expected = printableValue expected
			"#{fullName} should not be #{expected}"
		error: (fullName, actual, expected) ->
			expected = printableValue expected
			"Expected #{fullName} to not be #{expected}"

	beLessThan: predicateActionBuilder
		test: (actual, expected) ->
			should.unwrapActual(actual) < expected
		description: (fullName, expected) ->
			"#{fullName} should be less than #{expected}"
		error: (fullName, actual, expected) ->
			"Expected #{fullName} to be less than #{expected}, but it was #{should.unwrapActual(actual)}"

	beGreaterThan: predicateActionBuilder
		test: (actual, expected) ->
			should.unwrapActual(actual) > expected
		description: (fullName, expected) ->
			"#{fullName} should be greater than #{expected}"
		error: (fullName, actual, expected) ->
			"Expected #{fullName} to be greater than #{expected}, but it was #{should.unwrapActual(actual)}"

	beGreaterThanOrEqual: predicateActionBuilder
		test: (actual, expected) ->
			should.unwrapActual(actual) >= expected
		description: (fullName, expected) ->
			"#{fullName} should be greater than or equal #{expected}"
		error: (fullName, actual, expected) ->
			"Expected #{fullName} to be greater than or equal #{expected}, but it was #{should.unwrapActual(actual)}"

	beLessThanOrEqual: predicateActionBuilder
		test: (actual, expected) ->
			should.unwrapActual(actual) <= expected
		description: (fullName, expected) ->
			"#{fullName} should be less than or equal #{expected}"
		error: (fullName, actual, expected) ->
			"Expected #{fullName} to be less than or equal #{expected}, but it was #{should.unwrapActual(actual)}"

	beInstanceof: predicateActionBuilder
		test: (actual, expected) ->
			should.unwrapActual(actual) instanceof expected
		description: (fullName, expected) ->
			typeName = expected.toString().match(/function\s*(.*?)\s*\(/)[1]
			"#{fullName} should be instance of #{typeName}"
		error: (fullName, actual, expected) ->
			"Expected #{fullName} to be instance of #{expected}"
