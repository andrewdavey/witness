var Witness = {

    init: function (target) {
        // Add DSL functions to the target object e.g. window
        // So we can write the specifications without typing "Witness." everywhere!
        target.describe = this.describe;
        target.given = this.given;

        // Add named step functions to target object.
        var steps = (this.namedSteps || {});
        for (var name in steps) {
            if (steps.hasOwnProperty(name)) {
                target[name] = steps[name]();
            }
        }
    },

    namedSteps: {},
    regexSteps: [],

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
            var name = parseFunctionName(regexpOrFunction);
            this.namedSteps[name] = Witness.util.lift(regexpOrFunction);

        } else {
            throw new TypeError("Either pass a named function or a RegExp and a function.");
        }

        function parseFunctionName(func) {
            return func.toString()
                       .match(/function\s+(.*)\s*\(/)[1];
        }
    },

    describe: function Witness_describe(specificationName, scenarioBuilders) {
        return new Witness.Specification(specificationName, buildScenarios(scenarioBuilders));

        function buildScenarios(scenarioBuilders) {
            var scenarios = [];
            for (var prop in scenarioBuilders) {
                if (scenarioBuilders.hasOwnProperty(prop)) {
                    scenarios.push(scenarioBuilders[prop].buildScenario(prop));
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

    Specification: function Witness_Specification(name, scenarios) {
        this.name = name;
        this.scenarios = scenarios;
    },

    Scenario: (function () {
        function Witness_Scenario(name, contexts, actions, assertions) {
            this.name = name;
            this.contexts = contexts;
            this.actions = actions;
            this.assertions = assertions;
        }

        Witness_Scenario.prototype.run = function Witness_Scenario_run(callback) {
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
                            callback({ status: "passed", assertions: assertionResults });
                        } else {
                            callback({ status: "failed", assertions: assertionResults });
                        }
                    }
                },
                function (e) {
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

            function createAssertionAction(assertions) {
                return function (done, fail) {
                    var errors = [];
                    assertions.forEach(function (assertion) {
                        assertion(
                            function () { },
                            function (e) { results.push(e); failAny = true; }
                        );
                    });
                    if (failAny) fail(results); else done();
                }
            }
        };

        return Witness_Scenario;
    })()
};

