describe("Scenario", [

    given(function aScenario() {
        this.context0 = new Witness.Steps.Step(function () { });
        this.context1 = new Witness.Steps.Step(function () { });
        this.action0 = new Witness.Steps.Step(function () { });
        this.action1 = new Witness.Steps.Step(function () { });
        this.assertion0 = new Witness.Steps.Assertion(function () { return true; });
        this.assertion1 = new Witness.Steps.Assertion(function () { return true; });
        this.scenario = new Witness.Scenario(
            [this.context0, this.context1],
            [this.action0, this.action1],
            [this.assertion0, this.assertion1]
        );
    }).
    then(
        function context0HasFirstProperty() {
            return this.context0.first === true;
        },
        function context1DoesNotHaveFirstProperty() {
            return !this.context1.first;
        },
        function action0HasFirstProperty() {
            return this.action0.first === true;
        },
        function action1DoesNotHaveFirstProperty() {
            return !this.action1.first;
        },
        function assertion0HasFirstProperty() {
            return this.assertion0.first === true;
        },
        function assertion1DoesNotHaveFirstProperty() {
            return !this.assertion1.first;
        }
    )

]);