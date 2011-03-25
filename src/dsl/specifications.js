﻿Witness.dsl.addInitializer(function (target) {

    target.describe = function Witness_describe(specificationName, scenarioBuilders) {
        var specification = new Witness.Specification(specificationName, buildScenarios(scenarioBuilders));
        Witness.addSpecification(specification);

        function buildScenarios(scenarioBuilders) {
            var scenarios = [];
            for (var scenarioName in scenarioBuilders) {
                if (scenarioBuilders.hasOwnProperty(scenarioName)) {
                    var build = scenarioBuilders[scenarioName];
                    var scenario = build(scenarioName);
                    scenarios.push(scenario);
                }
            }
            return scenarios;
        }
    };

    target.given = function Witness_given() {
        var contexts = convertAll(arguments, convertToStep);
        var actions;

        return {
            when: when, // Declares steps to run.
            then: then  // Can jump directly to assertions if no actions are required.
        };

        function when() {
            actions = convertAll(arguments, convertToStep);
            return {
                then: then // Declares assertions to run.
            };
        }

        function then() {
            var assertions = convertAll(arguments, convertToAssertion);
            return function scenarioBuilder(scenarioName) {
                return new Witness.Scenario(
                    scenarioName,
                    contexts,
                    (actions || []),
                    assertions
                );
            };
        }

        function convertAll(args, convert) {
            var array = args ? Array.prototype.slice.apply(args) : [];
            return array.map(convert);
        }

        function convertToStep(item) {
            if (item.run)
                return item; // Already a step

            if (typeof item === "function")
                return item.async ? new Witness.Steps.AsyncStep(item) : new Witness.Steps.Step(item);

            if (typeof item === "string") 
                return Witness.findMatchingStep(item);
        }

        function convertToAssertion(item) {
            if (item.run)
                return item; // Already a step

            if (typeof item === "function")
                return item.async ? new Witness.Steps.AsyncAssertion(item) : new Witness.Steps.Assertion(item);

            if (typeof item === "string")
                return Witness.findMatchingStep(item);
        }
    };

});