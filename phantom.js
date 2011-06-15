if (phantom.state.length === 0) {
    phantom.state = 'run';
    console.log('Loading page with specs ' + phantom.args[0]);
    phantom.open('http://localhost:1234/?path=' + phantom.args[0]);
} else {
    console.log("Runner loaded");
    window.Witness.MessageBus.addHandler("ScenarioPassed", function() {
        console.log("passed");
    });
    window.Witness.MessageBus.addHandler("RunnerFinished", function() {
        phantom.exit();
    });
    window.Witness.runner.runAll();
}
