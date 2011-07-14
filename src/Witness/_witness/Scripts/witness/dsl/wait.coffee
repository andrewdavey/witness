# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"

{ async }= @Witness.Dsl::

@Witness.Dsl::defineActions
	wait: async ((delay) ->
		setTimeout @done, delay), -1
