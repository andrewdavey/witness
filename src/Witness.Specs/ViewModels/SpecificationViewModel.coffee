describe "SpecificationViewModel",
{
	"given a Specification with a description and one scenario": ->
		@specification = new witness.Specification "example", [ new witness.Scenario({}) ]

	"when a SpecificationViewModel is created": ->
		@viewModel = new witness.ViewModels.SpecificationViewModel @specification

	then:
		viewModel:
			description: should.be "example"
			scenarios: arrayShouldBe [
				should.beInstanceof witness.ViewModels.ScenarioViewModel
			]
			status: should.be "notrun"
			isOpen: should.be false
},
{
	"given a SpecificationViewModel": ->
		@specification = new witness.Specification "example", [ new witness.Scenario {} ]
		@viewModel = new witness.ViewModels.SpecificationViewModel @specification
	
	inner: [
		{
			"given we track the status observable property": ->
				# Track the status changes
				@statuses = []
				@viewModel.status.subscribe (status) => @statuses.push status

			"when the underlying Specification is run": async ->
				@specification.run {},
					(=> @done())
					(=> @done())

			"then the status was running and then passed":
				statuses: arrayShouldBe [
					should.be("running")
					should.be("passed")
				]
		},
		{
			when: ->
				@viewModel.toggleOpen()
			then:
				viewModel: isOpen: should.be true
		},
		{
			"when toggleOpen twice": ->
				@viewModel.toggleOpen()
				@viewModel.toggleOpen()
			then:
				viewModel: isOpen: should.be false
		},
		{
			"given we intercept the ScenarioViewModel reset function": ->
				@viewModel.scenarios[0].reset = => @scenarioReset = true
			"when reset": ->
				@viewModel.reset()
			then:
				scenarioReset: should.be true
		},
		{
			"when the underlying specification fails": ->
				@specification.on.failed.raise new Error("failed")
			then:
				viewModel:
					isOpen: should.be true
					status: should.be "failed"
		}
	]
}
