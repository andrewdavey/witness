# reference "Witness.coffee"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: (@specifications) ->

	runAll: (log) ->
		for specification in @specifications
			log "Testing " + specification.name
			for scenario in specification.scenarios
				scenario.run {}, (-> log "passed"), ((e) -> log e)