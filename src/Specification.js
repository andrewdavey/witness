﻿Witness.Specification = (function () {
    function Witness_Specification(name, scenarios) {
        if (!scenarios.every(function (s) { return !!s.reset && !!s.run; })) throw new TypeError("An object is not a scenario.");

        this.name = name;
        this.scenarios = scenarios;

        this.passCount = ko.dependentObservable(function () {
            return this.scenarios.filter(function (s) { return s.status() === "passed"; }).length;
        }, this);
        this.failCount = ko.dependentObservable(function () {
            return this.scenarios.filter(function (s) { return s.status() === "failed"; }).length;
        }, this);
    }

    Witness_Specification.prototype.reset = function () {
        this.scenarios.forEach(function (scenario) { scenario.reset(); });
    };

    Witness_Specification.prototype.run = function (context, done, fail) {
          // This will select each scenario in turn and pause after each is run.
//        var steps = this.scenarios.map(function (s) {
//            return new Witness.Steps.Sequence([
//                new Witness.Steps.Step(function () { s.select(); }),
//                s,
//                wait(200)
//            ]);
//        });

        var tryAll = new Witness.Steps.TryAll(this.scenarios);
        tryAll.run(context, done, fail);
    };

    return Witness_Specification;
})();