@witness.Dsl::mock = (targetObject, functions) ->
	originals = {}
	for own name, func of functions
		original = targetObject[name]
		targetObject[name] = func
		originals[name] = original

	->
		for own name, func of originals
			targetObject[name] = func
