describe "defineAction",
{
	"given the DSL is activated": ->
		@target = {}
		@dsl = new witness.Dsl @target
		@dsl.activate()

	"when defineAction is called": ->
		@target.defineAction "loadPage", ((url) -> console.log "loading " + url)

	"then a new action builder is added to the DSL target object": [
		-> typeof @target.loadPage == "function"
		-> (@target.loadPage "test.com") instanceof witness.Action
		-> (@target.loadPage "test.com").description == "load page test.com"
	]
},
{
	"given the DSL is activated": ->
		@target = {}
		@dsl = new witness.Dsl @target
		@dsl.activate()

	"when definedAction is called with an async function": ->
		@target.defineAction "loadPage", async ((url) -> console.log "loading " + url)

	"then a new async action builder is added to the DSL target object": [
		-> typeof @target.loadPage == "function"
		-> (@target.loadPage "test.com") instanceof witness.AsyncAction
		-> (@target.loadPage "test.com").description == "load page test.com"
	]
}

describe "defineActions",
{
	"given the DSL is activated": ->
		@target = {}
		@dsl = new witness.Dsl @target
		@dsl.activate()

	"when defineActions is called with a object of functions": ->
		@target.defineActions
			loadPage: (url) -> console.log "loading " + url
			wait: (timeout) -> console.log "waiting " + timeout
	
	"then new action builders are added to the DSL target object": [
		-> typeof @target.loadPage == "function"
		-> typeof @target.wait == "function"
		-> (@target.loadPage "test.com") instanceof witness.Action
		-> (@target.wait 10) instanceof witness.Action
	]
}
