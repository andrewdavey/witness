# reference "Witness.coffee"

this.Witness.helpers.splitCasedString = (s) ->
	s.replace(
		/([a-z])([A-Z])/g,
		(_, x, y) -> "#{x} #{y.toLowerCase()}"
	)

this.Witness.helpers.flattenArray = flattenArray = (array) ->
	output = []
	for item in array
		if $.isArray item
			output = output.concat flattenArray item
		else
			output.push item
	output
