describe "should.be",
{
	"given an action created from the should.be builder": ->
		@actionFactory = Witness.Dsl::should.be 100
		@action = @actionFactory "theProperty"

	"when the action is run with the correct property in the context": ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	"then the action has a readable description and completes": [
		-> @action.description == "theProperty should be 100"
		-> @done == true
	]
},
{
	"given an action created from the should.be builder": ->
		@actionFactory = Witness.Dsl::should.be 100
		@action = @actionFactory "theProperty"

	"when the action is run with the incorrect property in the context": ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	"then a readable error is created": [
		-> @error.message == "Expected theProperty to be 100 but was 666"
	]
},
{ # Scenario is equivalent to the above, but using should's instead
	"given an action created from the should.be builder": ->
		@actionFactory = Witness.Dsl::should.be 100

	"when the action is run with the correct property in the context": ->
		@action = @actionFactory "theProperty"
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	"then the action has a readable description and completes": 
		action:
			description: should.be "theProperty should be 100"
		done: should.be(true)
},
{
	"given an action created from the should.be builder": ->
		@actionFactory = Witness.Dsl::should.be "a string value"
		@action = @actionFactory "theProperty"

	"when the action is run with the incorrect property in the context": ->
		@action.run { theProperty: "incorrect string value" }, (->), ((error) => @error = error)

	"then a readable error is created":
		action:
			description: should.be "theProperty should be \"a string value\""
}

describe "should.notBe",
{
	"given an action is created from the should.notBe builder": ->
		@actionFactory = Witness.Dsl::should.notBe 666
		@action = @actionFactory "theProperty"

	"when the action is run with a non-equal property value in the context": ->
		@action.run { theProperty: 100 }, (=> @done = true), (->)

	"then the action has a readable description and completes": [
		-> @action.description == "theProperty should not be 666"
		-> @done == true
	]
},
{
	"given an action is created from the should.notBe builder": ->
		@actionFactory = Witness.Dsl::should.notBe 666
		@action = @actionFactory "theProperty"

	"when the action is run with a equal property value in the context": ->
		@action.run { theProperty: 666 }, (->), ((error) => @error = error)

	"then a readable error is created": [
		-> @error.message == "Expected theProperty to not be 666"
	]
}

describe "should.beLessThen",
{
	"given the assertion: context property should.beLessThan 100": ->
		@actionFactory = Witness.Dsl::should.beLessThan 100
		@action = @actionFactory "theProperty"
	
	inner: [
		{
			"given the context property is 50": ->
				@context = { theProperty: 50 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be less than 100"
				done: should.be true
		},
		{
			"given the context propert is 101": ->
				@context = { theProperty: 101 }

			"when the action is run": ->
				@action.run @context, (->), ((error) => @error = error)
		
			"then a readable error is created":
				error: message: should.be "Expected theProperty to be less than 100, but it was 101"
		}
	]
}

describe "should.beGreaterThan",
{
	"given the assertion: context property should.beGreaterThan 100": ->
		@actionFactory = Witness.Dsl::should.beGreaterThan 100
		@action = @actionFactory "theProperty"
	
	inner: [
		{
			"given the context property is 101": ->
				@context = { theProperty: 101 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be greater than 100"
				done: should.be true
		},
		{
			"given the context propert is 99": ->
				@context = { theProperty: 99 }

			"when the action is run": ->
				@action.run @context, (->), ((error) => @error = error)
		
			"then a readable error is created":
				error: message: should.be "Expected theProperty to be greater than 100, but it was 99"
		}
	]
}

describe "should.beGreaterThanOrEqual",
{
	"given the assertion: context property should.beGreaterThanOrEqual 100": ->
		@actionFactory = Witness.Dsl::should.beGreaterThanOrEqual 100
		@action = @actionFactory "theProperty"
	
	inner: [
		{
			"given the context property is 101": ->
				@context = { theProperty: 101 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be greater than or equal 100"
				done: should.be true
		},
		{
			"given the context property is 100": ->
				@context = { theProperty: 100 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be greater than or equal 100"
				done: should.be true
		},
		{
			"given the context propert is 99": ->
				@context = { theProperty: 99 }

			"when the action is run": ->
				@action.run @context, (->), ((error) => @error = error)
		
			"then a readable error is created":
				error: message: should.be "Expected theProperty to be greater than or equal 100, but it was 99"
		}
	]
}

describe "should.beLessThanOrEqual",
{
	"given the assertion: context property should.beLessThanOrEqual 100": ->
		@actionFactory = Witness.Dsl::should.beLessThanOrEqual 100
		@action = @actionFactory "theProperty"
	
	inner: [
		{
			"given the context property is 99": ->
				@context = { theProperty: 99 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be less than or equal 100"
				done: should.be true
		},
		{
			"given the context property is 100": ->
				@context = { theProperty: 100 }

			"when the action is run": ->
				@action.run @context, (=> @done = true), (->)
		
			"then the action has a readable description and completes":
				action:
					description: should.be "theProperty should be less than or equal 100"
				done: should.be true
		},
		{
			"given the context propert is 101": ->
				@context = { theProperty: 101 }

			"when the action is run": ->
				@action.run @context, (->), ((error) => @error = error)
		
			"then a readable error is created":
				error: message: should.be "Expected theProperty to be less than or equal 100, but it was 101"
		}
	]
}
