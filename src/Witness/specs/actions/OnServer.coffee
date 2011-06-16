# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

describe "Execute javascipt on server",
"Given an action that runs on the server": ->
	@action = on_server( -> 'key':'value')

"when the action is run": async ->
   @action.run {}, ((data) => @result = data;@done()) , @fail
   
"Then the result is passed by the done callback":->
  @result.key == 'value'