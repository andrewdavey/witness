describe "Dsl",
{
	given: ->
		@target = {}
		@dsl = new Witness.Dsl @target

	when: ->
		@dsl.activate()

	then: [ # Core DSL functions are added to target object
		-> "wait" of @target
		-> "async" of @target
		-> "defineAction" of @target
		-> "defineActions" of @target
	]
}