describe "describe",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl(@target)
		@scenario = { given: (->), when: wait(10), then: [] }
		
	when: ->
		@dsl.describe.call @target, "specification-name", @scenario

	then: ->
		@target.specifications.length == 1
}