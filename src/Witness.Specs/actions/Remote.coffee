# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

describe "Execute javascipt on server",
"Given an action that runs on the server": ->
	@action = remote( -> serverfunctionthatreturns42())

"when the action is run": async ->
   @action.run {}, ((data) => @result = data;@done()) , @fail
   
"Then the result is passed by the done callback":->
  @result == 42
,
describe "Execute javascipt on server that throws an exception",
"Given a throwing method that runs on the server": ->
	@action = remote( -> servermethodthatthrowsanexception())

"when the action is run": async ->
   @action.run {}, (->), ((error) => @error = error;@done())
   
"Then the exception message is passed to the fail callback":->
  @error == 'bang'


