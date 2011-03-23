// Runs an array of steps in order, but if any fail it continues on to the next.
// This is useful when wanting to run all AssertionSteps, which are independent of each other.
Witness.Steps.TryAll = (function () {

    function Witness_TryAll(steps) {
        this.steps = steps;
    }

    Witness_TryAll.prototype.run = function (context, done, fail) {
        var results = [],
            anyFailed = false;

        var tryAll = this.steps.reduceRight(
            function (next, step) {
                return function () {
                    step.run(
                        context,
                        function actionDone(result) {
                            results.push({ step: step });
                            next();
                        },
                        function actionFailed(error) {
                            results.push({ step: step, error: error });
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
                fail(results);
            } else {
                done(results);
            }
        }
    };

    return Witness_TryAll;
})();