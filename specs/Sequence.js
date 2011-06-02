(function () {

    function runTheSequence() {
        var context = this;
        context.sequence.run(
            {},
            function done() { context.doneCalled = true; },
            function fail(e) { context.failCalled = true; context.error = e; }
        );
    }

    describe("Sequence", [

    given(function aSequenceOfTwoSteps() {
        var context = this;
        context.sequence = new Witness.Steps.Sequence([
            new Witness.Steps.Step(function () { context.firstCalled = true; }),
            new Witness.Steps.Step(function () { context.secondCalled = true; })
        ]);
    }).
    when(runTheSequence).
    then(
        function firstStepWasCalled() {
            return this.firstCalled;
        },
        function secondStepWasCalled() {
            return this.secondCalled;
        },
        function doneWasCalled() {
            return this.doneCalled;
        },
        function failWasNotCalled() {
            return !this.failCalled;
        }
    ),

    given(function aSequenceWhereFirstStepFails() {
        var context = this;
        context.sequence = new Witness.Steps.Sequence([
            new Witness.Steps.Step(function () { throw new Error("fail"); }),
            new Witness.Steps.Step(function () { context.secondCalled = true; })
        ]);
    }).
    when(runTheSequence).
    then(
        function secondStepWasNotCalled() {
            return !this.secondCalled;
        },
        function failWasCalled() {
            return this.failCalled;
        },
        function failErrorIsThatThrownByFirstStep() {
            return this.error.message === "fail";
        }
    ),

    given(function aSequenceOfStepsToReset() {
        var context = this;
        context.sequence = new Witness.Steps.Sequence([
            { reset: function () { context.firstReset = true; } },
            { reset: function () { context.secondReset = true; } }
        ]);
    }).
    when(function resetTheSequence() {
        this.sequence.reset();
    }).
    then(
        function firstStepWasReset() {
            return this.firstReset;
        },
        function secondStepWasReset() {
            return this.secondReset;
        }
    )

]);

}());