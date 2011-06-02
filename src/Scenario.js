Witness.Scenario = (function () {
    function Witness_Scenario(contexts, actions, assertions) {
        this.contexts = contexts;
        this.actions = actions;
        this.assertions = assertions;

        if (contexts.length > 0) contexts[0].first = true;
        if (actions.length > 0) actions[0].first = true;
        if (assertions.length > 0) assertions[0].first = true;

        this.sequence = new Witness.Steps.Sequence(
            contexts
            .concat(actions)
            .concat(new Witness.Steps.TryAll(assertions))
        );

        this.status = ko.observable();
        this.selected = ko.observable(false);
        this.error = ko.observable();

        this.reset();
    }

    var selectedScenario = null;

    Witness_Scenario.prototype.reset = function Witness_Scenario_reset() {
        if (this.iframe) {
            this.iframe.parentNode.removeChild(this.iframe);
        }

        this.status("pending");
        this.error(null);

        this.sequence.reset();
    };

    Witness_Scenario.prototype.run = function Witness_Scenario_run(outerContext, done, fail) {
        var setStatus = this.status;
        var setError = this.error;
        var scenario = this;
        setStatus("running");

        var context = {
            getIFrame: function () {
                if (!scenario.iframe) scenario.iframe = createIFrame();
                return scenario.iframe;
            },
            cleanUps: []
        };

        this.sequence.run(context, sequenceDone, sequenceFail);

        function sequenceDone() {
            setStatus("passed");
            cleanUp();
            done.call(outerContext);
        }

        function sequenceFail(error) {
            setStatus("failed");
            setError(error);
            cleanUp();
            fail.call(outerContext, error);
        }

        function cleanUp() {
            context.cleanUps.forEach(function (f) { f(); });
        }

        function createIFrame() {
            var iframe = document.createElement("iframe");
            iframe.setAttribute("class", "scenario");
            iframe.setAttribute("frameborder", "0");
            document.getElementById("output").appendChild(iframe);
            iframe.style.display = scenario.selected() ? "block" : "none";
            return iframe;
        }
    };

    Witness_Scenario.prototype.select = function () {
        if (Witness.theRunner.selectedScenario().length > 0) Witness.theRunner.selectedScenario()[0].deselect();
        if (this.iframe) this.iframe.style.display = "block";
        this.selected(true);
        Witness.theRunner.selectedScenario.push(this);
    };

    Witness_Scenario.prototype.deselect = function () {
        if (this.iframe) this.iframe.style.display = "none";
        Witness.theRunner.selectedScenario([]);
        this.selected(false);
    };

    return Witness_Scenario;
})();