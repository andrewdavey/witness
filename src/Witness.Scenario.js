Witness.Scenario = (function () {
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
        var assertions = this.assertions.map(liftAssertionIfNotLifted);
        var context = {
            cleanUps: []
        };
        runActions.call(context,
                function runAssertions() {
                    var run = assertions.reduceRight(function (next, assertion) {
                        return function (assertionResults) {
                            assertion.call(context, function (result) {
                                assertionResults.push(result);
                                next(assertionResults);
                            });
                        }
                    }, finish);
                    run([]);

                    function finish(assertionResults) {
                        if (assertionResults.every(function (r) { return r === true; })) {
                            setStatus("passed");
                            cleanUp();
                            callback({ status: "passed", assertions: assertionResults });
                        } else {
                            setStatus("failed");
                            cleanUp();
                            callback({ status: "failed", assertions: assertionResults });
                        }
                    }
                },
                function (e) {
                    setStatus("failed");
                    cleanUp();
                    callback({ status: "An action failed." });
                }
            );

        function cleanUp() {
            context.cleanUps.forEach(function (f) { f(); });
        }

        function stringToAction(item) {
            if (typeof item === "string") {
                return Witness.getAction(item);
            } else {
                return item;
            }
        }

        function liftAssertionIfNotLifted(funcOrAssertion) {
            if (Witness.util.getMetadata(funcOrAssertion, "assertion")) {
                return funcOrAssertion;
            } else {
                // lift the function into an assertion step and call to return its action.
                return Witness.util.liftAssertion(funcOrAssertion)();
            }
        }
    };

    return Witness_Scenario;
})();