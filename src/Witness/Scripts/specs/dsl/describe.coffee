describe "describe",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl(@target)
		@scenario = { given: (->), when: wait(10), then: [] }
		
	when: ->
		@dsl.describe.call @target, "specification-name", @scenario
		{@givens,@whens,@thens,@disposes} = @target.specifications[0].scenarios[0]

	then: [
		-> @target.specifications.length == 1
		-> @target.specifications[0].scenarios.length == 1
		-> $.isArray @givens
		-> $.isArray @whens
		-> $.isArray @thens
		-> $.isArray @disposes
	]
},
{
	given: ->
		@context = { contextProperty: 42 }
		textContext = this
		actionFactory = (name) => new Witness.Action "action", (-> textContext.value = @[name]), []
		thenObject = { contextProperty: actionFactory }
		
		@scenario = { given: [], when: [], then: thenObject }
		@target = {}
		@dsl = new Witness.Dsl(@target)
	
	when: ->
		@dsl.describe.call @target, "specification-name", @scenario
		@assertion = @target.specifications[0].scenarios[0].thens[0]
		@assertion.run @context, (->), (->)

	then: [
		-> @value == 42 # We were passed the value of the context property
	]
}