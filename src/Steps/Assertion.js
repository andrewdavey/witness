// Assertion step expects the wrapped function to return a boolean value.
Witness.Steps.Assertion = (function () {

    function Witness_Assertion(func, args) {
        this.func = func;
        this.args = args || [];
        this.status = ko.observable("pending");

        var funcName = Witness.util.parseFunctionName(func);
        if (funcName) {
            this.description = Witness.util.expandCasing(Witness.util.parseFunctionName(func)) +
            " (" + this.args.map(JSON.stringify).join(", ") + ")";
        } else {
            this.description = "";
        }
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