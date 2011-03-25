// Asynchronously running step.
// The wrapped function must call this.done or this.fail to allow next step to run.
Witness.Steps.AsyncStep = (function () {

    function Witness_AsyncStep(func, args) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(func, args);
    }

    Witness_AsyncStep.prototype.run = function (context, done, fail) {
        try {
            context.done = function () { cleanUp(); done.apply(context); };
            context.fail = function () { cleanUp(); fail.apply(context, arguments); };
            this.func.apply(context, this.args);

        } catch (e) { // in case the func throws before going async.
            cleanUp();
            fail(e);
        }
        function cleanUp() {
            delete context.done;
            delete context.fail;
        }
    };

    return Witness_AsyncStep;

})();