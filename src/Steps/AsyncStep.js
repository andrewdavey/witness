/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Asynchronously running step.
// The wrapped function must call this.done or this.fail to allow next step to run.
Witness.Steps.AsyncStep = (function () {

    function Witness_AsyncStep(func, args, description) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(description, args);
        this.timeout = Witness_AsyncStep.defaultTimeout;
        this.status = ko.observable("pending");
    }

    Witness_AsyncStep.prototype.run = function (context, done, fail) {
        var status = this.status,
            step = this,
            timeoutId;

        try {
            context.done = function () {
                if (step.timeoutExpired) return;
                cleanUp();
                status("passed");
                done.apply(context);
            };
            context.fail = function () {
                if (step.timeoutExpired) return;
                cleanUp();
                status("failed");
                fail.apply(context, arguments);
            };
            timeoutId = setTimeout(cancelDueToTimeout.bind(this), this.timeout);
            this.func.apply(context, this.args);

        } catch (e) { // in case the func throws before going async.
            cleanUp();
            fail(e);
        }

        function cleanUp() {
            if (timeoutId) clearTimeout(timeoutId);
            delete context.done;
            delete context.fail;
        }

        function cancelDueToTimeout() {
            this.timeoutExpired = true;
            timeoutId = null;
            cleanUp();
            status("failed");
            fail.call(context, "Timeout expired. Step took too long to run.");
        }
    };

    Witness_AsyncStep.prototype.reset = function Witness_AsyncStep_reset() {
        this.status("pending");
    };

    Witness_AsyncStep.defaultTimeout = 10000; // 10 seconds

    return Witness_AsyncStep;

})();