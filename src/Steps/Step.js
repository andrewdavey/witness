/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Synchronously running step.
Witness.Steps.Step = (function () {

    function Witness_Step(func, args) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(func, args);
        this.status = ko.observable("notrun");
    }

    Witness_Step.prototype.run = function (context, done, fail) {
        try {
            this.func.apply(context, this.args);
            this.status("passed");
            done.call(context);
        } catch (e) {
            fail.call(context, e);
        }
    };

    Witness_Step.prototype.reset = function () {
        this.status("notrun");
    };

    return Witness_Step;

})();