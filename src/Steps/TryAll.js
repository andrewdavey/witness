// Runs an array of steps in order, but if any fail it continues on to the next.
// This is useful when wanting to run all AssertionSteps, which are independent of each other.
Witness.Steps.TryAll = (function () {

    function Witness_TryAll(steps) {
        this.steps = steps;
    }

    Witness_TryAll.prototype.run = function (context, done, fail) {
        var errors = [],
            anyFailed = false;

        var tryAll = this.steps.reduceRight(
            function (next, step) {
                return function () {
                    step.run(
                        context,
                        function actionDone(result) {
                            next();
                        },
                        function actionFailed(error) {
                            errors.push(error);
                            anyFailed = true;
                            next();
                        }
                    );
                }
            },
            callDoneOrFail
        );
        tryAll();

        function callDoneOrFail() {
            if (anyFailed) {
                fail(errors);
            } else {
                done();
            }
        }
    };

    Witness_TryAll.prototype.reset = function Witness_TryAll_reset() {
        this.steps.forEach(function (step) { step.reset(); });
    }

    return Witness_TryAll;
})();