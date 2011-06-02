(function () {

    function run() {
        var context = this;
        context.tryAll.run(
            {},
            function () { context.doneCalled = true; },
            function (e) { context.failCalled = true; context.error = e; }
        );
    }

describe("TryAll", [

    given(function tryAllWithTwoSteps() {
        var context = this;
        context.tryAll = new Witness.Steps.TryAll([
            new Witness.Steps.Step(function () { context.firstCalled = true; }),
            new Witness.Steps.Step(function () { context.secondCalled = true; })
        ]);
    }).
    when(run).
    then(
        function firstStepWasRun() {
            return this.firstCalled;
        },
        function secondStepWasRun() {
            return this.secondCalled;
        },
        function doneWasCalled() {
            return this.doneCalled;
        },
        function failWasNotCalled() {
            return !this.failCalled;
        }
    ),

    given(function tryAllWithFirstStepThatThrowsError() {
        var context = this;
        context.errorToThrow = new Error("first failed");
        context.tryAll = new Witness.Steps.TryAll([
            new Witness.Steps.Step(function () { throw context.errorToThrow; }),
            new Witness.Steps.Step(function () { context.secondCalled = true; })
        ]);
    }).
    when(run).
    then(
        function secondStepWasRunEvenThoughFirstFailed() {
            return this.secondCalled;
        },
        function doneNotCalled() {
            return !this.doneCalled;
        },
        function failCalled() {
            return this.failCalled;
        },
        function failErrorMessageIsArrayContainingOneError() {
            return this.error.length === 1
                && this.error[0].message === this.errorToThrow.message;
        }
    ),

    given(function aSequenceOfStepsToReset() {
        var context = this;
        context.tryAll = new Witness.Steps.TryAll([
            { reset: function () { context.firstReset = true; } },
            { reset: function () { context.secondReset = true; } }
        ]);
    }).
    when(function resetTheSequence() {
        this.tryAll.reset();
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