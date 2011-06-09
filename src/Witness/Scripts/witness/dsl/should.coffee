# reference "../Dsl.coffee"

predicateActionBuilder = (options) ->
	(expected) ->
		(propertyNames...) ->
			fullName = propertyNames.join "."
			description = options.description fullName, expected
			new Witness.Action description, () ->
				actual = decendPropertiesToValue this, propertyNames
				return if options.test.call this, actual, expected
				error = options.error fullName, actual, expected
				if typeof error == "string"
					throw new Error error
				else
					throw error

decendPropertiesToValue = (object, propertyNames) ->
	for name in propertyNames
		object = object[name]
	object

printableValue = (value) ->
	if typeof value == "string"
		"\"#{value}\""
	else
		value

this.Witness.Dsl::should =

	be: predicateActionBuilder
		test: (actual, expected) ->
			if typeof expected == "function"
				expected = expected.call this	
			actual == expected
		description: (fullName, expected) ->
			expected = printableValue expected
			"#{fullName} should be #{expected}"
		error: (fullName, actual, expected) ->
			actual = printableValue actual
			expected = printableValue expected
			"Expected #{fullName} to be #{expected} but was #{actual}"

	notBe: predicateActionBuilder
		test: (actual, expected) ->
			if typeof expected == "function"
				expected = expected.call this	
			actual != expected
		description: (fullName, expected) ->
			expected = printableValue expected
			"#{fullName} should not be #{expected}"
		error: (fullName, actual, expected) ->
			actual = printableValue actual
			expected = printableValue expected
			"Expected #{fullName} to not be #{expected}"