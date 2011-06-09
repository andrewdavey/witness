describe "async",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	when: ->
		@func = @target.async (->)
	
	then:
		func: async: should.notBe undefined
},
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	when: ->
		# specify the timeout
		@func = @target.async (->), 2000
	
	then:
		func: async: timeout: should.be 2000
}