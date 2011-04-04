Witness.Runner = (function () {

    function Witness_Runner() {
        this.specifications = ko.observableArray([]);
        this.canRun = ko.observable(true);
        loadSpecs(this.run.bind(this));
    }

    Witness_Runner.prototype.addSpecification = function (specification) {
        this.specifications.push(specification);
    };

    Witness_Runner.prototype.reset = function () {
        this.specifications().forEach(function (spec) { spec.reset(); });
    };

    Witness_Runner.prototype.run = function () {
        if (!this.canRun()) return; // Probably already running!

        this.reset();
        this.canRun(false);
        var self = this;

        var tryAll = new Witness.Steps.TryAll(this.specifications());
        tryAll.run(null, callback, callback);

        function callback() {
            self.canRun(true);
        }
    };


    function loadSpecs(callback) {
        var path    = document.location.search.match(/\bpath=(.*)(&|$)/)[1],
            nocache = (new Date()).getTime();

        $.get("server/aspnet/allspecs.ashx", { path: path, nocache: nocache }, function (urls) {
            var count = urls.length;
            urls.forEach(function (url) {
                var script = document.createElement("script");
                $(script).load(function () {
                    count--;
                    if (count === 0) callback();
                });
                script.setAttribute("src", url + "?nocache=" + nocache);
                script.setAttribute("type", "text/javascript");
                document.body.appendChild(script);
            });
        });
    }

    return Witness_Runner;
})();