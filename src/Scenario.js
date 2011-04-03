Witness.Scenario = (function () {
    function Witness_Scenario(contexts, actions, assertions) {
        this.contexts = contexts;
        this.actions = actions;
        this.assertions = assertions;
        this.status = ko.observable("notrun");

        this.sequence = new Witness.Steps.Sequence(
            contexts
            .concat(actions)
            .concat(new Witness.Steps.TryAll(assertions))
        );
    }

    Witness_Scenario.prototype.reset = function Witness_Scenario_reset() {
        this.status("notrun");
        this.sequence.reset();
    };

    Witness_Scenario.prototype.run = function Witness_Scenario_run(_, done, fail) {
        var setStatus = this.status;
        setStatus("running");

        var context = {
            cleanUps: []
        };

        this.sequence.run(context, sequenceDone, sequenceFail);

        function sequenceDone() {
            setStatus("passed");
            cleanUp();
            done();
        }

        function sequenceFail(error) {
            setStatus("failed");
            cleanUp();
            fail(error);
        }

        function cleanUp() {
            context.cleanUps.forEach(function (f) { f(); });
        }
    };

    return Witness_Scenario;
})();