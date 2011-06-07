# reference "../witness/dsl/describe.coffee"
# refernce "../witness/Assertion.coffee"

describe "Assertion",
{
	given: ->
		@assertion = new Witness.Assertion "assertion-name", (-> true)

	then: [
		-> @assertion.name == "assertion-name"
	]
},
{
	given: ->
		@assertion = new Witness.Assertion "assertion-name", (-> true)

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (-> @failCallbackCalled = true)
	
	then: [
		-> @doneCallbackCalled == true
		-> not @failCallbackCalled
	]
},
{
	given: ->
		@assertion = new Witness.Assertion "assertion-name", (-> false)

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)
	
	then: [
		-> not @doneCallbackCalled
		-> @failCallbackCalled == true
	]
},
{
	given: ->
		@assertion = new Witness.Assertion "assertion-name", (-> throw new Error "custom error")

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)
	
	then: [
		-> not @doneCallbackCalled
		-> @error.message == "custom error"
	]
}