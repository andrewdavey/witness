# reference "Witness.coffee"

this.Witness.helpers.splitCasedString = (s) ->
	s.replace(
		/([a-z])([A-Z])/g,
		(_, x, y) -> "#{x} #{y.toLowerCase()}"
	)