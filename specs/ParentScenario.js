(function () {

    function mockScenario() {
        var scenario;
        var context = new Witness.Steps.Step(function () { scenario.contextCalled = true; });
        var action = new Witness.Steps.Step(function () { scenario.actionCalled = true; });
        var assertion = new Witness.Steps.Assertion(function () { scenario.assertionCalled = true; return true; });
        scenario = new Witness.Scenario([context], [action], [assertion]);
        return scenario;
    }

    describe("ParentScenario", [

    given(function aParentScenario() {
        var testContext = this;
        testContext.outerContextCalled = 0;
        this.outerContext = function () {
            testContext.outerContextCalled++;
        };
        this.childScenario0 = mockScenario(testContext);
        this.childScenario1 = mockScenario(testContext);
        this.parentScenario = new Witness.ParentScenario(
            [this.outerContext],
            [this.childScenario0, this.childScenario1]
        );
    }).
    when(function run() {
        this.parentScenario.run({}, function () { }, function () { });
    }).
    then(
        function outerContextCalledOnce() {
            return this.outerContextCalled === 1;
        },
        function childScenario0WasRun() {
            return this.childScenario0.contextCalled &&
                   this.childScenario0.actionCalled &&
                   this.childScenario0.assertionCalled;
        },
        function childScenario1WasRun() {
            return this.childScenario1.contextCalled &&
                   this.childScenario1.actionCalled &&
                   this.childScenario1.assertionCalled;
        }
    )

]);


} ());