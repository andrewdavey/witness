Witness.Specification = (function () {
    function Witness_Specification(name, scenarios) {
        this.name = name;
        this.scenarios = scenarios;
    }

    Witness_Specification.prototype.reset = function () {
        this.scenarios.forEach(function (scenario) { scenario.reset(); });
    };

    Witness_Specification.prototype.run = function (context, done, fail) {
        var tryAll = new Witness.Steps.TryAll(this.scenarios);
        tryAll.run(context, done, fail);
    };

    return Witness_Specification;
})();