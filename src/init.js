// This script runs after all other Witness scripts.

Witness.dsl.initialize(Witness.dsl.target);

jQuery(window.document).ready(function () {
    setTimeout(function () {

        Witness.theRunner = new Witness.Runner();
        // Data bind the UI to the runner.
        ko.applyBindings(Witness.theRunner);

    }, 1);
});