var Witness = {

    go: function (window) {
        this.defineDSL(window);

        jQuery(window.document).ready(function () {
            setTimeout(function () {
                var runner = new Witness.Runner(Witness.specifications);
                ko.applyBindings(
                    runner,
                    window.document.body
                );
                runner.runAll(function () { });
            }, 1);
        });
    },

    defineDSL: function (target) {
        // Add DSL functions to the target object e.g. window
        // So we can write the specifications without typing "Witness." everywhere!
        target.describe = function () {
            var specification = this.describe.apply(this, arguments);
            Witness.specifications.push(specification);
            return specification;
        } .bind(this);
        target.given = this.given;
        target.defineAssertion = this.defineAssertion;

        // Add named step functions to target object.
        var steps = this.namedSteps;
        for (var name in steps) {
            if (steps.hasOwnProperty(name)) {
                target[name] = steps[name];
            }
        }
    },

    specifications: [],
    namedSteps: {},
    regexSteps: [],
    assertions: [],

    getAction: function (text) {
        for (var i = 0, n = this.regexSteps.length; i < n; i++) {
            var match = this.regexSteps[i].regexp.exec(text);
            if (match) {
                var args = match.slice(1);
                return this.regexSteps[i].getAction.apply(undefined, args);
            }
        }
        throw new Error("Regex step not found for: " + text);
    },

    defineStep: function Witness_defineStep(regexpOrFunction, stepFunction) {
        if (regexpOrFunction instanceof RegExp) {
            if (typeof stepFunction !== "function") throw new TypeError("Must pass a step function as well.");
            this.regexSteps.push({
                regexp: regexpOrFunction,
                getAction: Witness.util.lift(stepFunction)
            });

        } else if (typeof regexpOrFunction === "function") {
            var name = Witness.util.parseFunctionName(regexpOrFunction);
            this.namedSteps[name] = Witness.util.lift(regexpOrFunction);

        } else {
            throw new TypeError("Either pass a named function or a RegExp and a function.");
        }
    },

    defineAsyncStep: function Witness_defineAsyncStep(regexpOrFunction, stepFunction) {
        if (typeof regexpOrFunction === "function") regexpOrFunction = Witness.util.async(regexpOrFunction);
        if (typeof stepFunction === "function") stepFunction = Witness.util.async(stepFunction);
        return Witness.defineStep(regexpOrFunction, stepFunction);
    },

    defineAssertion: function (assertFunction) {
        var name = Witness.util.parseFunctionName(assertFunction);
        window[name] = Witness.util.liftAssertion(a);
    },

    describe: function Witness_describe(specificationName, scenarioBuilders) {
        return new Witness.Specification(specificationName, buildScenarios(scenarioBuilders));

        function buildScenarios(scenarioBuilders) {
            var scenarios = [];
            for (var prop in scenarioBuilders) {
                if (scenarioBuilders.hasOwnProperty(prop)) {
                    scenarios.push(scenarioBuilders[prop](prop));
                }
            }
            return scenarios;
        }
    },

    given: function Witness_given() {
        var contexts = arguments ? Array.prototype.slice.apply(arguments) : [];
        var actions = [];

        return {
            when: when, // Defines actions.
            then: then  // Can jump directly to assertions if no actions are required.
        };

        function when() {
            actions = (arguments ? Array.prototype.slice.apply(arguments) : []);
            return { then: then };
        }

        function then() {
            var assertions = (arguments ? Array.prototype.slice.apply(arguments) : []);
            return scenarioBuilder;

            function scenarioBuilder(scenarioName) {
                return new Witness.Scenario(scenarioName, contexts, actions, assertions);
            };
        }
    },

    Specification: (function () {
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
    })(),

    Scenario: (function () {
        function Witness_Scenario(name, contexts, actions, assertions) {
            this.name = name;
            this.contexts = contexts;
            this.actions = actions;
            this.assertions = assertions;
            this.status = ko.observable("notrun");
        }

        Witness_Scenario.prototype.reset = function Witness_Scenario_reset() {
            this.status("notrun");
        };

        Witness_Scenario.prototype.run = function Witness_Scenario_run(callback) {
            var setStatus = this.status;
            setStatus("running");
            var runActions = Witness.util.sequence(this.contexts.concat(this.actions).map(stringToAction));
            var assertions = this.assertions;
            runActions(
                function runAssertions() {
                    var run = assertions.reduceRight(function (next, assertion) {
                        return function (assertionResults) {
                            assertion(function (result) {
                                assertionResults.push(result);
                                next(assertionResults);
                            });
                        }
                    }, finish);
                    run([]);

                    function finish(assertionResults) {
                        if (assertionResults.every(function (r) { return r === true; })) {
                            setStatus("passed");
                            callback({ status: "passed", assertions: assertionResults });
                        } else {
                            setStatus("failed");
                            callback({ status: "failed", assertions: assertionResults });
                        }
                    }
                },
                function (e) {
                    setStatus("failed");
                    callback({ status: "An action failed." });
                }
            );

            function stringToAction(item) {
                if (typeof item === "string") {
                    return Witness.getAction(item);
                } else {
                    return item;
                }
            }
        };

        return Witness_Scenario;
    })(),

    Runner: (function () {
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
    })()
};

Witness.go(window);