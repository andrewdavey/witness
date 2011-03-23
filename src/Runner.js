Witness.Runner = (function () {
    function Witness_Runner(specifications) {
        this.specifications = specifications;
        this.canRun = ko.observable(true);
    }

    Witness_Runner.prototype.reset = function () {
        this.specifications.forEach(function (spec) { spec.reset(); });
    };

    Witness_Runner.prototype.run = function () {
        if (!this.canRun()) return; // Probably already running!

        this.reset();
        this.canRun(false);
        var self = this;

        var tryAll = new Witness.Steps.TryAll(this.specifications);
        tryAll.run(null, callback, callback);

        function callback() {
            self.canRun(true);
        }
    };

    return Witness_Runner;
})();