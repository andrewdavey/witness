Witness.Runner = (function () {
    function Witness_Runner(specifications) {
        this.specifications = specifications;
        this.canRunAll = ko.observable(true);
    }

    Witness_Runner.prototype.reset = function () {
        this.specifications.forEach(function (spec) { spec.reset(); });
    };

    Witness_Runner.prototype.runAll = function (callback) {
        if (!this.canRunAll()) return; // Probably already running!

        this.reset();
        this.canRunAll(false);
        Witness.util.runFunctionSequence(this.specifications, function (spec) { return spec.runAll }, function () {
            this.canRunAll(true);
            callback();
        } .bind(this));
    };

    return Witness_Runner;
})();