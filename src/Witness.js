var Witness = {

    specifications: [], // array of Specification objects
    stepMatchers: [], // array of { Regex, Step } objects

    addSpecification: function (specification) {
        this.specifications.push(specification);
    },

    createRunner: function () {
        return new Witness.Runner(this.specifications);
    },

    addStepMatcher: function (regExp, step) {
        this.stepMatchers.push({ regExp: regExp, step: step });
    },

    findMatchingStep: function (text) {
        for (var i = 0, n = this.stepMatchers.length; i < n; i++) {
            var matcher = this.stepMatchers[i];
            var match = matcher.regExp.exec(text);
            if (match) {
                var args = match.slice(1); // skip the first match item which is just the whole string.
                return matcher.step.apply(undefined, args);
            }
        }
        throw new Error("Cannot find step definition for '" + text + "'.");
    }

};