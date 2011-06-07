describe "async",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	when: ->
		@func = @target.async (->)
	
	then: ->
		@func.async?
},
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	when: ->
		# specify the timeout
		@func = @target.async (->), 2000
	
	then: -> @func.async.timeout == 2000
}