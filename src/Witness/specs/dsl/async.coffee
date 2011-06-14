describe "async",
{
	"given the DSL is activated": ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	"when async is called with a function argument": ->
		@func = @target.async (->)
	
	"then the function has an async property added":
		func: async: should.notBe undefined
},
{
	"given the DSL is activated": ->
		@target = {}
		@dsl = new Witness.Dsl @target
		@dsl.activate()

	"when async is called with function and timeout of 2000 milliseconds": ->
		# specify the timeout
		@func = @target.async (->), 2000
	
	"then the timeout is stored":
		func: async: timeout: should.be 2000
}
