describe("AsyncStep", [
    given(function AsyncStepWithFunctionThatCallsDone() {
        this.step = new Witness.Steps.AsyncStep(function () { this.done(); });
        this.contextUsedByStep = {};
    }).
    when(function callRun() {
        var done = this.done,
            fail = this.fail;

        this.step.run(
            this.contextUsedByStep,
            function () {
                this.doneCalled = true;
                this.thisInDone = this;
            },
            function (e) { fail(e); }
        );
    }).
    then(
        function doneCallbackIsCalled() {
            return this.contextUsedByStep.doneCalled;
        },
        function thisInDoneIsTheContext() {
            return this.contextUsedByStep.thisInDone === this.contextUsedByStep;
        }
    ),


    given(function stepWithFunctionThatThrows() {
        this.step = new Witness.Steps.AsyncStep(function () { this.fail("failed"); });
        this.contextUsedByStep = {};
    }).
    when(async(function callRun() {
        var done = this.done;
        var fail = this.fail;
        this.step.run(
            this.contextUsedByStep,
            function stepDone() {
                fail("Should not call done.");
            },
            function (error) {
                this.failCalled = true;
                this.thisInFailCallback = this;
                this.error = error;
                done();
            }
        );
    })).
    then(
        function failCallbackIsCalled() {
            return this.contextUsedByStep.failCalled;
        },
        function thisInFailIsTheContext() {
            return this.contextUsedByStep.thisInFailCallback === this.contextUsedByStep;
        },
        function errorIsPassedToFailCallback() {
            return this.contextUsedByStep.error === "failed";
        }
    ),

    given(function asyncStepThatHasRun() {
        this.step = new Witness.Steps.AsyncStep(function () { this.done(); });
        this.step.run({}, function () { }, function () { });
    }).
    when(function callReset() {
        this.step.reset();
    }).
    then(function statusIspending() {
        return this.step.status() === "pending";
    })

]);