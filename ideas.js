/*
objects:
  Specification - text description, scenarios
  Scenario - contexts, actions, assertions and clean-ups
  ParentScenario - contexts, nested Scenarios
  Step - run(context, done, fail)
  Assertion - conforms with the Step interface
  AsyncStep
  AsyncAssertion

  Step combinators: Sequence, TryAll

Separate scenario definitions from runtime state? Or include status, etc in the objects
as observable properties for data-binding to UI?
Step <-> StepViewModel
new StepViewModel(step)
    - calls run on underlying step
    - has status observable property
Step has to have the friendly description text. Too much work for ViewModel to re-create it.

defineSteps({
    loadPage: async(function (url) {
        
    })
});

---> loadPage === function(url) {
    return function() {
        return new Step(original_function, [ url ], "load page " + url);
    };
}

Should matchers...

  then({ foo: should.equal("bar") });
  --->
  then({ foo: new AssertionBuilder(dsl.should.equals, ["bar"])})
 
  assertionBuilder.build("foo") ---> new Assertion(...)

  should.equal = defineValueAssertion(function(actualValue, expected) {
    if (actualValue !== expected) {
      throw new AssertionException("Expected #{expected} but got #{actualValue}");
  });

  defineContextAssertions({
    "customer is prefered": function() {
      return this.customer.isPreferred;
    }
  });
  
  Value assertion function:   Actual-value, [original arguments array]. this === context
  Context assertion function: no-arguments. this === context 

  Return true|false or return undefined|throw-error ???
  We have to run assertion within a try...catch anyway - so just use an exception based assert?
  Exception contains a message...
  Probably too hard to generate a decent error message in general case. The assertion function
  knows the precise reason for failure.

  "The value 42 failed the assertion: `between 1, 10`"
  vs
  "The value 42 was not between 1 and 10"

  if assertion function returns undefined or true then pass, else fail with generated message

Mocking/overriding dependencies

{
  given: -> this.replace(jQuery, "get", function(url,_,callback) { callback("fake data"); })
  when: -> foo.download()
  then: -> assert(foo.text).equal("fake data")
}

 */

// One spec per file ideally please. Starts with "describe".
describe("Specification description text here",
    // Scenario at the top-level of the specification
    {
        given: function() {...}, // Context is a {function, array of context, string, Step object}
        when:  [
            clickButton(),
            wait(1000),
            waitUntil(function() { return $("#message").text() == ""; })
        ], // Action is a {function, array of actions, string, Step object}
        then:  function() {...},  // Assertion is a {function, array of assertions, string, Assertion object)
        cleanup: function() {}
    },

    // A parent-context
    {
        given: [
            function outerContext1() {...}, // 1 or more context setup steps
            function outerContext2() {...},

            // Then 1 or more scenarios (GWT-object literals).
            {
                given: function() { ... },
                when:  function() { ... },
                then:  function() { ... }
                cleanup: function() {}
            },
            
            // Alternative fluent-interface. Returns an object like the above.
            given(function() {})
            .when(function() {})
            .then(function() {})
            .cleanup(function() {})

            // Another scenario
            {
                // Allow multiple steps in each section by using an array
                given: function() { ... },
                when:  function() { ... },
                then:  [ 
                    function something_should_be_whatever() {
                        assert(this.something).equal("asdas");
                    },
                    function something_else_should_blah() {
                    }
                ]
            },

            // Scenario with object literal assertion syntax
            {
                given: function() {
                    this.something = "somevalue";
                    this.moar = "blah";
                },
                when: function() { ... },
                then: {
                    // the properties of the literal refer to properties in the scenario context. 
                    something: should.equal("expected-value"),
                    moar: should.notEqual("no thanks"),
                    // potentially allow jQuery selectors too:
                    "#message": should.containText("Hello world"),
                    // allow nested assertion objects for awesome-win
                    customer: {
                        firstname: should.equal("john"),
                        lastname:  should.equal("smith")
                    }
                }
            }
        ],
        cleanup: function() {...}
    },

    // Another parent-context
    given(
        function outerContext() {...},
        // Nested scenario
        {
            given: function() {...},
            when:  function() {...},
            then:  function() {...}
        }
    )

);
