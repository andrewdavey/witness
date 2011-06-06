describe "dsl.defineAction",
{
	given: ->
		@dsl = new Witness.Dsl()

	when: ->
		@dsl.defineAction "loadPage", ((url) -> console.log "loading " + url)

	then: [
		-> typeof @dsl.loadPage == "function"
		-> (@dsl.loadPage "test.com") instanceof Witness.Action
		-> (@dsl.loadPage "test.com").name == "load page test.com"
	]
}

describe "dsl.defineActions",
{
	given: ->
		@dsl = new Witness.Dsl()

	when: ->
		@dsl.defineActions {
			loadPage: (url) -> console.log "loading " + url
			wait: (timeout) -> console.log "waiting " + timeout
		}

	then: [
		-> typeof @dsl.loadPage == "function"
		-> typeof @dsl.wait == "function"
		-> (@dsl.loadPage "test.com") instanceof Witness.Action
		-> (@dsl.wait 10) instanceof Witness.Action
	]
}