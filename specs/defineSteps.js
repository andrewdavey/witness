(function () {

    function dslTargetObjectInitialized() {
        this.dsl = {};
        Witness.dsl.defineStepInitializer(this.dsl);
    }

    function callDefineSteps() {
        this.dsl.defineSteps(this.steps);
    }

    describe("defineSteps", [

    given(
        dslTargetObjectInitialized,
        function stepDefinitionsWithValidJavascriptIdentifierNames() {
            this.steps = {
                exampleOne: function () { },
                example_two: function () { }
            };
        }
    ).
    when(callDefineSteps).
    then(
        function stepsAreAvailableOnTheTargetObject() {
            return this.dsl.exampleOne() instanceof Witness.Steps.Step
                && this.dsl.example_two() instanceof Witness.Steps.Step;
        },
        function stepDescriptionsAreDerivedByExpandingCasing() {
            return this.dsl.exampleOne().description === "example one";
        },
        function stepDescriptionsAreDerivedByReplacingUnderscoresWithSpaces() {
            return this.dsl.example_two().description === "example two";
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
    when(callDefineSteps).
    then(function stepsAreAvailableOnTheTargetObject() {
        return this.dsl.example() instanceof Witness.Steps.AsyncStep;
    }),

    given(
        dslTargetObjectInitialized,
        function stepDefinitionWithNonJavaScriptIdentfierName() {
            this.steps = {
                "regex example (.*)": function (value) { this.stepRunValue = value; }
            };
        }
    ).
    when(callDefineSteps).
    then(
        function stepMatcherCreated() {
            var step = this.dsl.findStep("regex example abc");
            return step instanceof Witness.Steps.Step;
        },
        function stepIsRunWithArgumentMatchedFromString() {
            var step = this.dsl.findStep("regex example abc");
            var context = {};
            step.run(context, function () { }, function () { });
            return context.stepRunValue === "abc";
        }
    )

]);


}());