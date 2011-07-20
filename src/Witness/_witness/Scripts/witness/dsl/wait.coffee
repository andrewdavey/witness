# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"

{ async }= @witness.Dsl::

@witness.Dsl::defineActions
	wait: async ((delay) ->
		setTimeout @done, delay), -1
