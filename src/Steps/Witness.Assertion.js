// Assertion step expects the wrapped function to return a boolean value.
Witness.Assertion = (function () {

    function Witness_Assertion(func, args) {
        this.func = func;
        this.args = args;
    }

    Witness_Assertion.prototype.run = function (context, done, fail) {
        try {
            var result = this.func.apply(context, this.args);
            if (result) {
                done(result);
            } else {
                fail(result);
            }
        } catch (e) {
            fail(e);
        }
    };

    return Witness_Assertion;

})();