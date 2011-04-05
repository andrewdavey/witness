(function () {

describe("defineAssertions", [

    given(
        dslTargetObjectInitialized,
        function stepDefinitionsWithValidJavascriptIdentifierNames() {
            this.steps = {
                example1: function () { },
                example2: function () { }
            };
        }
    ).
    when(callDefineAssertions).
    then(
        function stepsAreAvailableOnTheTargetObject() {
            return this.dsl.example1() instanceof Witness.Steps.Assertion
                && this.dsl.example2() instanceof Witness.Steps.Assertion;
        }
    ),

    given(
        dslTargetObjectInitialized,
        function asyncStepDefinition() {
            this.steps = {
                example: this.dsl.async(function () { })
            };
        }
    ).
    when(callDefineAssertions).
    then(
        function stepsAreAvailableOnTheTargetObject() {
            return this.dsl.example() instanceof Witness.Steps.AsyncAssertion;
        }
    ),

    given(
        dslTargetObjectInitialized,
        function stepDefinitionWithNonJavaScriptIdentfierName() {
            this.steps = {
                "regex example (.*)": function (value) { this.stepRunValue = value; }
            };
        }
    ).
    when(callDefineAssertions).
    then(
        function stepMatcherCreated() {
            var step = this.dsl.findStep("regex example abc");
            return step instanceof Witness.Steps.Assertion;
        },
        function stepIsRunWithArgumentMatchedFromString() {
            var step = this.dsl.findStep("regex example abc");
            var context = {};
            step.run(context, function () { }, function () { });
            return context.stepRunValue === "abc";
        }
    )

]);


function dslTargetObjectInitialized() {
    this.dsl = {};
    Witness.dsl.defineStepInitializer(this.dsl);
}

function callDefineAssertions() {
    this.dsl.defineAssertions(this.steps);
}

})();