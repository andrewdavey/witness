/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Synchronously running step.
Witness.Steps.Step = (function () {

    function Witness_Step(func, args, name) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(name, args);
        this.status = ko.observable("pending");
    }

    Witness_Step.prototype.run = function (context, done, fail) {
        try {
            this.func.apply(context, this.args);
            this.status("passed");
            done.call(context);
        } catch (e) {
            this.status("failed");
            fail.call(context, e);
        }
    };

    Witness_Step.prototype.reset = function () {
        this.status("pending");
    };

    return Witness_Step;

})();