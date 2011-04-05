/// <reference path="../namespace.js" />
/// <reference path="../stepMatchers.js" />
/// <reference path="../util.js" />
/// <reference path="dsl.js" />

Witness.dsl.defineStepInitializer = function (target) {

    target.stepMatchers = []; // array of { regex, step } objects.

    target.findStep = function (text) {
        for (var i = 0, n = target.stepMatchers.length; i < n; i++) {
            var matcher = target.stepMatchers[i];
            var match = matcher.regExp.exec(text);
            if (match) {
                var args = match.slice(1); // skip the first match item which is just the whole string.
                var step = matcher.step.apply(undefined, args);
                step.description = text;
                return step;
            }
        }
        throw new Error("Cannot find step definition for '" + text + "'.");
    };

    target.defineStep = function Witness_defineStep(name, func) {
        define(name, func, false);
    };

    target.defineSteps = function Witness_defineSteps(object) {
        for (var property in object) {
            if (object.hasOwnProperty(property)) {
                target.defineStep(property, object[property])
            }
        }
    };

    target.defineAssertion = function (name, func) {
        define(name, func, true);
    };

    target.defineAssertions = function Witness_defineAssertions(object) {
        for (var property in object) {
            if (object.hasOwnProperty(property)) {
                target.defineAssertion(property, object[property]);
            }
        }
    };

    target.async = function (func) {
        // tag the function as "async" so we can create the AsyncStep in defineSteps.
        func.async = true;
        return func; // fluent interface
    };

    function define(name, func, isAssertion) {
        var stepTypeName = (func.async ? "Async" : "") + (isAssertion ? "Assertion" : "Step");
        var step = createStep(Witness.Steps[stepTypeName], func, name);
        var isRegex = !(/^[a-z_][a-z0-9_]*$/i).test(name);
        if (isRegex) {
            target.stepMatchers.push({ regExp: new RegExp(name), step: step });
        } else {
            target[name] = step;
        }
    }

    function createStep(type, fn, name) {
        return function () {
            var args = Array.prototype.slice.apply(arguments);
            return new type(fn, args, name);
        }
    }
}

Witness.dsl.addInitializer(Witness.dsl.defineStepInitializer);