# reference "Witness.coffee"

@Witness.helpers.splitCasedString = (s) ->
	s.replace(
		/([a-z])([A-Z])/g,
		(_, x, y) -> "#{x} #{y.toLowerCase()}"
	)

@Witness.helpers.flattenArray = flattenArray = (array) ->
	if not jQuery.isArray array
		return [ array ]

	output = []
	for item in array
		if jQuery.isArray item
			output = output.concat flattenArray item
		else
			output.push item
	output
