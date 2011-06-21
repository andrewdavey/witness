describe "Dsl",
{
	"given a DSL that will write into a target object": ->
		@target = {}
		@dsl = new Witness.Dsl @target

	"when the DSL is activated": ->
		@dsl.activate()

	"then core DSL functions are added to target object": [
		-> "wait" of @target
		-> "async" of @target
		-> "defineAction" of @target
		-> "defineActions" of @target
		-> typeof @target.should == "object"
	]
}
