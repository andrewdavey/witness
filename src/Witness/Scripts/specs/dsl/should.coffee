describe "should.equal",
{
	given: ->
		@actionFactory = Witness.Dsl::should.equal 100
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: [
		-> @action.name == "theProperty should equal 100"
		-> @done == true
	]
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.equal 100
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	then: [
		-> @error.message == "Expected theProperty to equal 100 but was 666"
	]
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.notEqual 666
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: [
		-> @action.name == "theProperty should not equal 666"
		-> @done == true
	]
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.notEqual 666
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	then: [
		-> @error.message == "Expected theProperty to not equal 666"
	]
}
#,
### TODO implement nested object assertions
{ # Scenario is equivalent to the above, but using should's instead
	given: ->
		@actionFactory = Witness.Dsl::should.equal 100

	when: ->
		@action = @actionFactory "theProperty"
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: 
		action:
			name: should.equal "theProperty should equal 100"
		done: should.equal(true)
}
###