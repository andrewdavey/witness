describe "OuterScenario",
{
	"given an OuterScenario with two inner scenarios": ->
		@outerGivenCalled = 0
		@outerDisposeCalled = 0
		parts =
			given:
				description: "given"
				actions: [ new witness.Action (=> @outerGivenCalled++) ]

			dispose:
				description: "dispose"
				actions: [ new witness.Action (=> @outerDisposeCalled++) ]

		innerScenarios = [
			new witness.Scenario({
				given:
					description: "given"
					actions: [ new witness.Action (=> @inner0GivenCalled = true) ]
				when:
					description: "when"
					actions: [ new witness.Action (=> @inner0WhenCalled = true) ]
				then:
					description: "then"
					actions: [ new witness.Action (=> @inner0ThenCalled = true) ]
			}),
			new witness.Scenario({
				given:
					description: "given"
					actions: [ new witness.Action (=> @inner1GivenCalled = true) ]
				when:
					description: "when"
					actions: [ new witness.Action (=> @inner1WhenCalled = true) ]
				then:
					description: "then"
					actions: [ new witness.Action (=> @inner1ThenCalled = true) ]
			})
		]
		@outerScenario = new witness.OuterScenario parts, innerScenarios
	
	"when it is run": async ->
		@outerScenario.run {},
			(=> @doneCalled = true; @done())
			(=> @done())
	
	"then":
		outerGivenCalled: should.be 2
		outerDisposeCalled: should.be 2
		inner0GivenCalled: should.be true
		inner0WhenCalled: should.be true
		inner0ThenCalled: should.be true
		inner1GivenCalled: should.be true
		inner1WhenCalled: should.be true
		inner1ThenCalled: should.be true
		doneCalled: should.be true
},
{
	"given an OuterScenario with event handlers added": ->
		parts =
			given:
				description: "given"
				actions: []

			dispose:
				description: "dispose"
				actions: []

		innerScenarios = []
		@outerScenario = new witness.OuterScenario parts, innerScenarios
		@outerScenario.on.running.addHandler => @runningEventRaised = true
		@outerScenario.on.passed.addHandler => @passedEventRaised = true
		@outerScenario.on.failed.addHandler => @failedEventRaised = true

	"when it is run": async ->
		@outerScenario.run {},
			(=> @done())
			(=> @done())

	then:
		runningEventRaised: should.be true
		passedEventRaised: should.be true
		failedEventRaised: should.be undefined
},
{
	"given an OuterScenario that fails with an inner Scenario and event handlers added": ->
		parts =
			given:
				description: "given"
				actions: [ new witness.Action(-> throw new Error "failed") ]

			dispose:
				description: "dispose"
				actions: []

		innerScenarios = [ new witness.Scenario {} ]
		@outerScenario = new witness.OuterScenario parts, innerScenarios
		@outerScenario.on.running.addHandler => @runningEventRaised = true
		@outerScenario.on.passed.addHandler => @passedEventRaised = true
		@outerScenario.on.failed.addHandler => @failedEventRaised = true

	"when it is run": async ->
		@outerScenario.run {},
			(=> @done())
			(=> @done())

	then:
		runningEventRaised: should.be true
		passedEventRaised: should.be undefined
		failedEventRaised: should.be true
},
{
	"given an OuterScenario that fails but has no inner Scenarios": ->
		parts =
			given:
				description: "given"
				actions: [ new witness.Action(-> throw new Error "failed") ]

			dispose:
				description: "dispose"
				actions: []

		innerScenarios = []
		@outerScenario = new witness.OuterScenario parts, innerScenarios
		@outerScenario.on.passed.addHandler => @passedEventRaised = true

	"when it is run": async ->
		@outerScenario.run {},
			(=> @done()),
			(=> @done())

	"then the done event is raised":
		passedEventRaised: should.be true
# The outer Given and Dispose run for each inner scenario.
# So when there are none, technically they should never run.
# However, we can't just stall the action execution, so we simply
# expect `done` to be called.
}
