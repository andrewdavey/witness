/// <reference path="namespace.js" />
/// <reference path="Steps/TryAll.js" />
/// <reference path="Steps/Sequence.js" />

Witness.ParentScenario = (function () {

    function Witness_ParentScenario(contexts, children) {
        contexts = convertAll(contexts, convertToStep)
        if (contexts.length > 0) contexts[0].first = true;
        
        this.contexts = contexts;
        this.children = children;

        this.status = ko.observable();
        this.error = ko.observable();
        this.selected = ko.observable(false);

        this.runner = new Witness.Steps.Sequence(
            contexts.concat(
                new Witness.Steps.TryAll(children)
            )
        );

        this.reset();

        function convertAll(args, convert) {
            var array = args ? Array.prototype.slice.apply(args) : [];
            return array.map(convert);
        }

        function convertToStep(item) {
            if (item.run) {
                return item; // Already a step
            }

            if (typeof item === "function") {
                var description = Witness.util.parseFunctionName(item);
                return item.async ? new Witness.Steps.AsyncStep(item, [], description) : new Witness.Steps.Step(item, [], description);
            }

            if (typeof item === "string") {
                return Witness.steps.findMatchingStep(item);
            }
        }
    }

    Witness_ParentScenario.prototype.reset = function Witness_ParentScenario_reset() {
        this.status("pending");
    };

    Witness_ParentScenario.prototype.run = function Witness_ParentScenario_run(outerContext, done, fail) {
        var setStatus = this.status;
        var setError = this.error;

        var context = {};
        this.runner.run(context, sequenceDone, sequenceFail);

        function sequenceDone() {
            setStatus("passed");
            done.call(outerContext);
        }

        function sequenceFail(error) {
            setStatus("failed");
            setError(error);
            fail.call(outerContext, error);
        }
    };

    Witness_ParentScenario.prototype.select = function () {
        if (Witness.theRunner.selectedScenario().length > 0) Witness.theRunner.selectedScenario()[0].deselect();
        this.selected(true);
        Witness.theRunner.selectedScenario.push(this);
    };

    Witness_ParentScenario.prototype.deselect = function () {
        Witness.theRunner.selectedScenario([]);
        this.selected(false);
    };

    Witness_ParentScenario.prototype.getScenarioTemplateName = function (scenario) {
        if (scenario instanceof Witness.ParentScenario) {
            return "parent-scenario";
        } else {
            return "scenario";
        }
    };

    return Witness_ParentScenario;

})();