/// <reference path="namespace.js" />

Witness.stepMatchers = (function () {
    var matchers = []; // array of { Regex, Step } objects

    return {
        addStepMatcher: function (regExp, step) {
            matchers.push({ regExp: regExp, step: step });
        },

        findMatchingStep: function (text) {
            for (var i = 0, n = matchers.length; i < n; i++) {
                var matcher = matchers[i];
                var match = matcher.regExp.exec(text);
                if (match) {
                    var args = match.slice(1); // skip the first match item which is just the whole string.
                    return matcher.step.apply(undefined, args);
                }
            }
            throw new Error("Cannot find step definition for '" + text + "'.");
        }
    };
})();