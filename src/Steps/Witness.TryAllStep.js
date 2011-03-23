// Runs an array of steps in order, but if any fail it continues on to the next.
// This is useful when wanting to run all AssertionSteps, which are independent of each other.
Witness.TryAppStep = (function () {

    function Witness_TryAllStep(steps) {
        this.steps = step;
    }

    Witness_TryAllStep.prototype.run = function (context, done, fail) {
        var results = [],
            anyFailed = false;

        var tryAll = actions.reduceRight(
            function (next, action) {
                return function () {
                    action.run(
                        context,
                        function actionDone(result) {
                            results.push({ action: action });
                            next();
                        },
                        function actionFailed(error) {
                            results.push({ action: action, error: error });
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

    return Witness_TryAllStep;
})();