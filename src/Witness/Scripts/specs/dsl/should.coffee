describe "should.be",
{
	given: ->
		@actionFactory = Witness.Dsl::should.be 100
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: [
		-> @action.name == "theProperty should be 100"
		-> @done == true
	]
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.be 100
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	then: [
		-> @error.message == "Expected theProperty to be 100 but was 666"
	]
},
{ # Scenario is equivalent to the above, but using should's instead
	given: ->
		@actionFactory = Witness.Dsl::should.be 100

	when: ->
		@action = @actionFactory "theProperty"
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: 
		action:
			name: should.be "theProperty should be 100"
		done: should.be(true)
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.be "a string value"
	when: ->
		@action = @actionFactory "theProperty"
		@action.run { theProperty: "incorrect string value" }, (->), ((error) => @error = error)
	then:
		action:
			name: should.be "theProperty should be \"a string value\""
}

describe "should.notBe",
{
	given: ->
		@actionFactory = Witness.Dsl::should.notBe 666
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	then: [
		-> @action.name == "theProperty should not be 666"
		-> @done == true
	]
},
{
	given: ->
		@actionFactory = Witness.Dsl::should.notBe 666
		@action = @actionFactory "theProperty"

	when: ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	then: [
		-> @error.message == "Expected theProperty to not be 666"
	]
}