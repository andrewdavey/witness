# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"

async = this.Witness.Dsl::async

this.Witness.Dsl::defineActions
	wait: async (delay) ->
		setTimeout @done, delay