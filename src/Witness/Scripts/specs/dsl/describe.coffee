describe "describe",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl(@target)
		@scenario = { given: (->), when: wait(10), then: [] }
		
	when: ->
		@dsl.describe.call @target, "specification-name", @scenario
		{givens,whens,thens,disposes} = @target.specifications[0].scenarios[0]

	then: [
		-> @target.specifications.length == 1
		-> @target.specifications[0].scenarios.length == 1
		-> $.isArray givens
		-> $.isArray whens
		-> $.isArray thens
		-> $.isArray disposes
	]
}