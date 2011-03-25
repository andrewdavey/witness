describe("Step", {
    "run with function that completes without throwing an exception":
        given(function () {
            this.step = new Witness.Steps.Step(function () { });
            this.contextUsedByStep = {};
        }).
        when(async(function () {
            var done = this.done;
            var fail = this.fail;
            this.step.run(
                this.contextUsedByStep,
                function stepDone() {
                    this.doneCalled = true;
                    this.thisInDone = this;
                    done();
                },
                function (e) {
                    fail(e);
                }
            );
        })).
        then(
            function doneCallbackIsCalled() {
                return this.contextUsedByStep.doneCalled;
            },
            function thisInDoneIsTheContext() {
                return this.contextUsedByStep.thisInDone === this.contextUsedByStep;
            }
        ),

    "run with function that throws an exception":
        given(function () {
            this.step = new Witness.Steps.Step(function () { throw new Error("failed"); });
            this.contextUsedByStep = {};
        }).
        when(async(function () {
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
                return this.contextUsedByStep.error.message === "failed";
            }
        )
});
