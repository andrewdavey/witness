describe "describe",
{
	"given a scenario definition": ->
		@target = {}
		@dsl = new Witness.Dsl(@target)
		@scenario = { given: (->), when: wait(10), then: [] }
		
	"when describing the scenario": ->
		@dsl.describe.call @target, "specification-name", @scenario
		{@given,@when,@then,@dispose} = @target.specifications[0].scenarios[0]

	then: [
		-> @target.specifications.length == 1
		-> @target.specifications[0].scenarios.length == 1
		-> $.isArray @given.actions
		-> $.isArray @when.actions
		-> $.isArray @then.actions
		-> $.isArray @dispose.actions
	]
},
{
	"given context has a property set to 42 and 'then' is an action factory reading the property name": ->
		@context = { contextProperty: 42 }
		textContext = this
		actionFactory = (name) => new Witness.Action (-> textContext.value = @[name])
		thenObject = { contextProperty: actionFactory }
		
		@scenario = { given: [], when: [], then: thenObject }
		@target = {}
		@dsl = new Witness.Dsl(@target)
	
	"when the assertion is run": ->
		@dsl.describe.call @target, "specification-name", @scenario
		@assertion = @target.specifications[0].scenarios[0].then.actions[0]
		@assertion.run @context, (->), (->)

	then:
		value: should.be 42
},
{
	"given the 'then' object contains a nested object with the property to check": ->
		@context = { outer: inner: 42 }
		textContext = this
		# actionFactory takes *two* arguments, one for each property name in the hirerachy
		actionFactory = (name1, name2) =>
			new Witness.Action (-> textContext.value = @[name1][name2]), []
		thenObject = { outer: inner: actionFactory }
		
		@scenario = { given: [], when: [], then: thenObject }
		@target = {}
		@dsl = new Witness.Dsl(@target)
	
	"when the assertion is run": ->
		@dsl.describe.call @target, "specification-name", @scenario
		@assertion = @target.specifications[0].scenarios[0].then.actions[0]
		@assertion.run @context, (->), (->)

	then:
		value: should.be 42
},
{
	"given a nested scenario definition": ->
		@definition = 
			"given this is the outer scenario": [
				-> @outerProperty = 1
				{
					"given this is the inner scenario": -> @innerProperty = 2
					when: (->)
					then: (->)
				}
			]
		@target = {}
		@dsl = new Witness.Dsl(@target)

	"when describe the scenario": ->
		@dsl.describe.call @target, "specification-name", @definition
		@scenario = @target.specifications[0].scenarios[0]

	"then":
		scenario: should.beInstanceof Witness.OuterScenario
}
