// Synchronously running step.
Witness.Steps.Step = (function () {

    function Witness_Step(func, args) {
        this.func = func; // the function to call.
        this.args = args || []; // the arguments to call the function with.
    }

    Witness_Step.prototype.run = function (context, done, fail) {
        try {
            this.func.apply(context, this.args);
            done.call(context);
        } catch (e) {
            fail.call(context, e);
        }
    };

    return Witness_Step;

})();