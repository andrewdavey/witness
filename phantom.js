if (phantom.state.length === 0) {
    phantom.state = "run";
    var path = phantom.args[0];
    console.log("Loading Witness Runner for '" + path + "'");
    phantom.open("http://localhost:1234/?path=" + path);

} else if (phantom.state === "run") {
    // PhantomJS seems to reload for any page automation iframes loaded by specs
    // So change the state to something else to avoid this coding runing again
    phantom.state = "running";

    var indent = 0;
    function log(message) {
        var padding = new Array(indent + 1).join('  ');
        console.log(padding + message);
    }

    window.Witness.messageBus.addHandlers({
        SpecificationDirectoryRunning: function(directory) {
            log("Running directory: " + directory.name + "/");
            indent++;
        },
        SpecificationDirectoryPassed: function() {
            indent--;
        },
        SpecificationDirectoryFailed: function() {
            indent--;
        },

        SpecificationFileRunning: function(file) {
            log("Running file: " + file.name);
            indent++;
        },
        SpecificationFilePassed: function() {
            indent--;
        },
        SpecificationFileFailed: function() {
            indent--;
        },
 
        SpecificationRunning: function(specification) {
            log("Running specification: " + specification.description);
            indent++;
        },
        SpecificationPassed: function() {
            indent--;
        },
        SpecificationFailed: function() {
            indent--;
        },

        OuterScenarioRunning: function() {
            log("Running outer scenario");
            indent++;
        },
        OuterScenarioPassed: function() {
            indent--;
        },
        OuterScenarioFailed: function() {
            indent--;
        },
 
        ScenarioRunning: function() {
            log("Running scenario");
        },
        ScenarioPassed: function() {
            log("passed");
        },
        ScenarioFailed: function() {
            log("failed");
        },
 
        RunnerFinished: function() {
            phantom.exit();
        }
    });
   
    window.Witness.runner.runAll();
}
