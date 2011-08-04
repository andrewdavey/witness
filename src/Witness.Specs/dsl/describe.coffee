describe "describe",
{
	"given a DSL and target": ->
		@target = {}
		@dsl = new witness.Dsl(@target)

	"for each": [
		{
			"given a scenario definition": ->
				@scenario = { given: (->), when: wait(10), then: [], dispose: [] }

			"when describing the scenario": ->
				spec = @dsl.describe.call @target, "specification-name", @scenario
				{@given,@when,@then,@dispose} = spec.scenarios[0]

			then: [
				-> @target.specifications.length == 1
				-> @target.specifications[0].scenarios.length == 1
				-> jQuery.isArray @given[0].actions
				-> jQuery.isArray @when[0].actions
				-> jQuery.isArray @then[0].actions
				-> jQuery.isArray @dispose[0].actions
			]
		},
		{
			"given context has a property set to 42 and 'then' is an action factory reading the property name": ->
				@context = { contextProperty: 42 }
				textContext = this
				actionFactory = (name) => new witness.Action (-> textContext.value = @[name])
				thenObject = { contextProperty: actionFactory }
				@scenario = { given: [], when: [], then: thenObject }
			
			"when the assertion is run": ->
				spec = @dsl.describe.call @target, "specification-name", @scenario
				@assertion = spec.scenarios[0].then[0].actions[0]
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
					new witness.Action (-> textContext.value = @[name1][name2]), []
				thenObject = { outer: inner: actionFactory }
				
				@scenario = { given: [], when: [], then: thenObject }
				@target = {}
				@dsl = new witness.Dsl(@target)
			
			"when the assertion is run": ->
				spec = @dsl.describe.call @target, "specification-name", @scenario
				@assertion = spec.scenarios[0].then[0].actions[0]
				@assertion.run @context, (->), (->)

			then:
				value: should.be 42
		},
		{
			"given the 'then' object contains an array property": ->
				@context = { foo: 1 }
				@scenario =
					given: []
					when: []
					then:
						foo: [
							should.be 1
							should.beGreaterThan 0
						]
				@target = {}
				@dsl = new witness.Dsl @target

			"when the assertion is run": ->
				spec = @dsl.describe.call @target, "specification-name", @scenario
				@assertion = spec.scenarios[0].then[0].actions[0]
				@assertion.run @context, (=> @passed = true), (->)

			"then it should pass":
				passed: should.be true
		}
		{
			"given a nested scenario definition": ->
				@definition = 
					"given this is the outer scenario": -> @outerProperty = 1
					"for each": [
						{
							"given this is the inner scenario": -> @innerProperty = 2
							when: (->)
							then: (->)
						},
						{
							"given this is the other inner scenario": (->)
							when: (->)
							then: (->)
						}
					]
					dispose: (->)
				@target = {}
				@dsl = new witness.Dsl(@target)

			"when describe the scenario": ->
				spec = @dsl.describe.call @target, "specification-name", @definition
				@scenario = spec.scenarios[0]

			"then":
				scenario:
					this: should.beInstanceof witness.OuterScenario
					innerScenarios:
						length: should.be 2
						0: should.beInstanceof witness.Scenario
						1: should.beInstanceof witness.Scenario
		},
		{
			"given a scenario definition with two 'then' clauses": ->
				@definition = 
					given: []
					when: []
					"then it is foo": {}
					"then it is bar": {}
				@target = {}
				@dsl = new witness.Dsl @target

			"when describe the scenario": ->
				spec = @dsl.describe.call @target, "specification-name", @definition
				@scenario = spec.scenarios[0]

			"then scenario has two 'then' parts":
				scenario: then: length: should.be 2
		}
	]
}
