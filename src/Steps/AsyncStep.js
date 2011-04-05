/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Asynchronously running step.
// The wrapped function must call this.done or this.fail to allow next step to run.
Witness.Steps.AsyncStep = (function () {

    function Witness_AsyncStep(func, args, description) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(description, args);
        this.status = ko.observable("pending");
    }

    Witness_AsyncStep.prototype.run = function (context, done, fail) {
        try {
            var status = this.status;
            context.done = function () {
                cleanUp();
                status("passed");
                done.apply(context);
            };
            context.fail = function () {
                cleanUp();
                status("failed");
                fail.apply(context, arguments);
            };
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

    Witness_AsyncStep.prototype.reset = function Witness_AsyncStep_reset() {
        this.status("pending");
    };

    return Witness_AsyncStep;

})();