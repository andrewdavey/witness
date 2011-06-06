# reference "Witness.coffee"
# reference "../lib/coffee-script.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: (@specifications) ->

	download: (url, callback) ->
		$.ajax({
			url: url
			dataType: 'text'
			success: (script) ->
				dsl = new Witness.Dsl()
				window[name] = value for name, value of dsl 
				CoffeeScript.eval(script)
				delete window[name] for name, value of dsl
				callback()
		});

	runAll: (log) ->
		for specification in @specifications
			log "Testing " + specification.description
			for scenario in specification.scenarios
				scenario.run {}, (-> log "passed"), ((e) -> log e)