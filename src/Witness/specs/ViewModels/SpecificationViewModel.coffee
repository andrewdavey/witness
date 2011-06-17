should.unwrapActual = (actual) -> 
	if actual?.__ko_proto__?
		actual()
	else
		actual

describe "SpecificationViewModel",
{
	"given a Specification with a description and one scenario": ->
		@specification = new Witness.Specification "example", [ new Witness.Scenario({}) ]

	"when a SpecificationViewModel is created": ->
		@viewModel = new Witness.ViewModels.SpecificationViewModel @specification

	then:
		viewModel:
			description: should.be "example"
			scenarios: [ should.beInstanceof Witness.ViewModels.ScenarioViewModel ]
			status: should.be "notrun"
			isOpen: should.be false
},
{
	"given a SpecificationViewModel": ->
		@specification = new Witness.Specification "example", [ new Witness.Scenario {} ]
		@viewModel = new Witness.ViewModels.SpecificationViewModel @specification
	
	inner: [
		{
			"given we track the status observable property": ->
				# Track the status changes
				@statuses = []
				@viewModel.status.subscribe (status) => @statuses.push status

			"when the underlying Specification is run": ->
				@specification.run {}, (->), (->)

			"then the status was running and then passed":
				statuses: [ should.be("running"), should.be("passed") ]
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
		}
	]
}
