describe "OuterScenario",
{
	"given an OuterScenario with two inner scenarios": ->
		@outerGivenCalled = 0
		@outerDisposeCalled = 0
		parts =
			given:
				description: "given"
				actions: [ new Witness.Action (=> @outerGivenCalled++) ]

			dispose:
				description: "dispose"
				actions: [ new Witness.Action (=> @outerDisposeCalled++) ]

		innerScenarios = [
			new Witness.Scenario({
				given:
					description: "given"
					actions: [ new Witness.Action (=> @inner0GivenCalled = true) ]
				when:
					description: "when"
					actions: [ new Witness.Action (=> @inner0WhenCalled = true) ]
				then:
					description: "then"
					actions: [ new Witness.Action (=> @inner0ThenCalled = true) ]
			}),
			new Witness.Scenario({
				given:
					description: "given"
					actions: [ new Witness.Action (=> @inner1GivenCalled = true) ]
				when:
					description: "when"
					actions: [ new Witness.Action (=> @inner1WhenCalled = true) ]
				then:
					description: "then"
					actions: [ new Witness.Action (=> @inner1ThenCalled = true) ]
			})
		]
		@outerScenario = new Witness.OuterScenario parts, innerScenarios
	
	"when it is run": ->
		@outerScenario.run {}, (=> @doneCalled = true), (->)
	
	"then":
		outerGivenCalled: should.be 1
		outerDisposeCalled: should.be 1
		inner0GivenCalled: should.be true
		inner0WhenCalled: should.be true
		inner0ThenCalled: should.be true
		inner1GivenCalled: should.be true
		inner1WhenCalled: should.be true
		inner1ThenCalled: should.be true
		doneCalled: should.be true
}
