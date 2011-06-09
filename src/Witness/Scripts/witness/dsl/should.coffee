# reference "../Dsl.coffee"

this.Witness.Dsl::should =
	equal: predicateActionBuilder
		test: (actual, expected) -> actual == expected
		description: (fullName, expected) -> "#{fullName} should equal #{expected}",
		error: (fullName, actual, expected) -> "Expected #{fullName} to equal #{expected} but was #{actual}"
	

	notEqual: predicateActionBuilder
		test: (actual, expected) -> actual != expected
		description: (fullName, expected) -> "#{fullName} should not equal #{expected}",
		error: (fullName, actual, expected) -> "Expected #{fullName} to not equal #{expected}"


predicateActionBuilder = (options) ->
	(expected) ->
		(propertyNames...) ->
			fullName = propertyNames.join "."
			description = options.description fullName, expected
			new Witness.Action description, () ->
				actual = decendPropertiesToValue this, propertyNames
				return if options.test actual, expected
				error = options.error fullName, actual, expected
				if typeof error == "string"
					throw new Error error
				else
					throw error

decendPropertiesToValue = (object, propertyNames) ->
	for name in propertyNames
		object = object[name]
	object