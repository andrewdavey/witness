# reference "Witness.coffee"

this.Witness.TimeoutError = class TimeoutError extends Error
	constructor: (message) ->
		super message