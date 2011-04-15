Witness.Runner = (function () {

    function Witness_Runner() {
        this.specifications = ko.observableArray([]);
        this.canRun = ko.observable(true);
        this.hidePassed = ko.observable(false);
        this.passCount = ko.dependentObservable(function () {
            return this.specifications().reduceRight(function (sum, specification) { return sum + specification.passCount() }, 0);
        }, this);
        this.failCount = ko.dependentObservable(function () {
            return this.specifications().reduceRight(function (sum, specification) { return sum + specification.failCount() }, 0);
        }, this);

        this.selectedScenario = ko.observableArray([]);

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
        tryAll.run({}, callback, callback.bind(this));

        function callback() {
            self.canRun(true);

            if (window.resultsCallback) {
                resultsCallback(this.specifications());
            }
        }
    };


    function loadSpecs(callback) {
        var path = document.location.search.match(/\bpath=(.*)(&|$)/)[1],
            nocache = (new Date()).getTime();

        jQuery.get("server/aspnet/allspecs.ashx", { path: path, nocache: nocache }, function (urls) {
            var count = urls.length;
            urls.forEach(function (url) {

                jQuery.ajax({
                    url: url,
                    dataType: 'text',
                    success: function (scriptSource) {
                        var globals = [];
                        for (var prop in window) {
                            globals.push(prop);
                        }
                        var result = JSLINT(scriptSource, { globals: globals });
                        if (result) {
                            eval(scriptSource);
                        } else {
                            alert("JSLint hates your code: " + JSON.stringify(JSLINT.errors));
                            // TODO: report script error somewhere!!
                        }
                        count--;
                        if (count === 0) {
                            callback();
                        }
                    }
                });
                //                var script = document.createElement("script");
                //                document.body.appendChild(script);
                //                var loaded = false;
                //                script.onload = function () {
                //                    loaded = true;
                //                    count--;
                //                    if (count === 0) callback();
                //                };
                //                // IE < 9
                //                script.onreadystatechange = function () {
                //                    if (!loaded && (script.readyState === "loaded" || script.readyState === "complete")) {
                //                        loaded = true;
                //                        count--;
                //                        if (count === 0) {
                //                            // Allow the browser to run the scripts before we start running.
                //                            setTimeout(callback, 10);
                //                        }
                //                    }
                //                };
                //                script.setAttribute("src", url + "?nocache=" + nocache);
                //                script.setAttribute("type", "text/javascript");
            });
        });
    }

    return Witness_Runner;
})();