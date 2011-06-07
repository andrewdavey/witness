now = -> new Date().getTime()

describe "wait",
{
	given: ->
		@action = wait(100)
		@startTime = now()

	when: async ->
		@action.run {}, (=> @finishTime = now(); @done()), @fail

	then: ->
		(@finishTime - @startTime) >= 100
}