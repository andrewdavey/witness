now = -> new Date().getTime()

describe "wait",
{
	"given an action that is wait 100 milliseconds": ->
		@action = wait(100)
		@startTime = now()

	"when the action is run": async ->
		@action.run {}, (=> @finishTime = now(); @done()), @fail

	"then it completes after 100 milliseconds": ->
		(@finishTime - @startTime) >= 100
}
