if (phantom.state.length === 0) {
    phantom.state = 'run';
    console.log('Loading page with specs ' + phantom.args[0 ]);
    phantom.open('http://localhost:63333/witness/src/witness.htm?path=' + phantom.args[0]);
} else {
window.resultsCallback = function (specifications) {
    specifications.forEach(function (specification) {
        console.log(specification.name +
            " passed: " + specification.passCount() +
            " failed: " + specification.failCount());

        specification.scenarios.forEach(function (scenario) {
            logSection("Given ", scenario.contexts);
            logSection("When ", scenario.actions);
            logSection("Then ", scenario.assertions);

            function logSection(type, steps) {
                var first = true;
                steps.forEach(function (step) {
                    console.log("    " + (first ? type : "  and ") + step.description + " (" + step.status() + ")");
                    first = false;
                });
            }
            console.log("");
        });

        console.log("");

    });
    phantom.exit();
};
}
