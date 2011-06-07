describe "dsl.defineAction",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl(@target)

	when: ->
		@target.defineAction "loadPage", ((url) -> console.log "loading " + url)

	then: [
		-> typeof @target.loadPage == "function"
		-> (@target.loadPage "test.com") instanceof Witness.Action
		-> (@target.loadPage "test.com").name == "load page test.com"
	]
}

describe "dsl.defineActions",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl(@target)

	when: ->
		@target.defineActions {
			loadPage: (url) -> console.log "loading " + url
			wait: (timeout) -> console.log "waiting " + timeout
		}

	then: [
		-> typeof @target.loadPage == "function"
		-> typeof @target.wait == "function"
		-> (@target.loadPage "test.com") instanceof Witness.Action
		-> (@target.wait 10) instanceof Witness.Action
	]
}