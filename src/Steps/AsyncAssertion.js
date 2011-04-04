/// <reference path="namespace.js" />
/// <reference path="../util.js" />

// Asynchronously running assertion.
Witness.Steps.AsyncAssertion = (function () {

    function Witness_AsyncAssertion(func, args) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
        this.description = Witness.util.createStepDescription(func, args);
    }

    Witness_AsyncAssertion.prototype.run = function (context, done, fail) {
        try {
            context.done = function () { cleanUp(); done(); };
            context.fail = function (e) { cleanUp(); fail(e); };
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

    return Witness_AsyncAssertion;

})();