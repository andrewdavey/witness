/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Assertion step expects the wrapped function to return a boolean value.
Witness.Steps.Assertion = (function () {

    function Witness_Assertion(func, args) {
        this.func = func;
        this.args = args || [];
        this.status = ko.observable("pending");
        this.description = Witness.util.createStepDescription(func, args);
    }

    Witness_Assertion.prototype.run = function (context, done, fail) {
        try {
            var result = this.func.apply(context, this.args);
            if (result) {
                this.status("passed");
                done(this);
            } else {
                this.status("failed");
                fail(this);
            }
        } catch (e) {
            this.status("failed");
            fail(e);
        }
    };

    Witness_Assertion.prototype.reset = function () {
        this.status("pending");
    };

    return Witness_Assertion;

})();