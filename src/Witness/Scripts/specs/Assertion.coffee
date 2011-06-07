# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

actionThatReturns = (result) -> new Witness.Action("assertion-name", (-> result))
actionThatThrows = new Witness.Action("assertion-name", (-> throw new Error "custom error"))

describe "Assertion",
{
	given: ->
		@assertion = new Witness.Assertion actionThatReturns true

	then: [
		-> @assertion.name == "assertion-name"
	]
},
{
	given: ->
		@assertion = new Witness.Assertion actionThatReturns true

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (-> @failCallbackCalled = true)
	
	then: [
		-> @doneCallbackCalled == true
		-> not @failCallbackCalled
	]
},
{
	given: ->
		@assertion = new Witness.Assertion actionThatReturns false

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)
	
	then: [
		-> not @doneCallbackCalled
		-> @failCallbackCalled == true
	]
},
{
	given: ->
		@assertion = new Witness.Assertion actionThatThrows

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)
	
	then: [
		-> not @doneCallbackCalled
		-> @error.message == "custom error"
	]
}