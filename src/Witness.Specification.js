Witness.Specification = (function () {
    function Witness_Specification(name, scenarios) {
        this.name = name;
        this.scenarios = scenarios;
    }

    Witness_Specification.prototype.reset = function () {
        this.scenarios.forEach(function (scenario) { scenario.reset(); });
    };

    Witness_Specification.prototype.runAll = function (callback) {
        Witness.util.runFunctionSequence(this.scenarios, function (scenario) { return scenario.run }, callback);
    };

    return Witness_Specification;
})();