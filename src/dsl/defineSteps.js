Witness.dsl.addInitializer(function (target) {

    target.defineSteps = function Witness_defineSteps(array) {
        // Allow calling this function with multiple arguments instead of an array.
        // We'll convert them into a regular array.
        if (!(array instanceof Array)) array = Array.prototype.slice.apply(arguments);

        array.forEach(function (item) {
            if (item.regExp) {
                var stepType = item.async ? Witness.Steps.AsyncStep : Witness.Steps.Step;
                var step = define(stepType, item);
                Witness.addStepMatcher(item.regExp, step);
            } else {
                var name = Witness.util.parseFunctionName(item);
                var stepType = item.async ? Witness.Steps.AsyncStep : Witness.Steps.Step;
                target[name] = define(stepType, item);
            }
        });
    };

    target.match = function (regExp, func) {
        // Tag the function with the regExp used to find the step created in defineSteps.
        func.regExp = regExp;
        return func; // fluent interface
    };

    target.async = function (func) {
        // tag the function as "async" so we can create the AsyncStep in defineSteps.
        func.async = true;
        return func; // fluent interface
    };

    function define(type, fn) {
        return function () {
            var args = Array.prototype.slice.apply(arguments);
            return new type(fn, args);
        }
    };
});