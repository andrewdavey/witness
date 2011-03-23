// This script runs after all other Witness scripts.

Witness.dsl.initialize(Witness.dsl.target);

jQuery(window.document).ready(function () {
    setTimeout(function () {
        var runner = Witness.createRunner();
        // Data bind the UI to the runner.
        ko.applyBindings(runner);
        // gogogogogogo!
        runner.run();
    }, 1);
});