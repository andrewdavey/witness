Witness.Scenario = (function () {
    function Witness_Scenario(contexts, actions, assertions) {
        this.contexts = contexts;
        this.actions = actions;
        this.assertions = assertions;
        this.status = ko.observable("notrun");
    }

    Witness_Scenario.prototype.reset = function Witness_Scenario_reset() {
        this.status("notrun");
    };

    Witness_Scenario.prototype.run = function Witness_Scenario_run(_, done, fail) {
        var setStatus = this.status;
        setStatus("running");

        var sequence = new Witness.Steps.Sequence(
            this.contexts
            .concat(this.actions)
            .concat(new Witness.Steps.TryAll(this.assertions))
        );

        var context = {
            cleanUps: []
        };

        sequence.run(context, sequenceDone, sequenceFail);

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