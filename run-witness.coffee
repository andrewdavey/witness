[path] = phantom.args

if not path?
	console.log "Web application relative path to specifications required."
	phantom.exit()
	return

page = new WebPage()
page.open "http://localhost:1337/fingers/_witness/runner.htm?path=#{path}", (status) ->
	if status == "success"
		page.onConsoleMessage = (message) ->
			if message == "!exit"
				phantom.exit()
			else
				console.log message

		page.evaluate ->
			Witness.messageBus.addHandlers
				RunnerFinished: -> console.log "!exit"

				SpecificationDirectoryRunning: (directory) ->
					console.log "##teamcity[testSuiteStarted name='#{directory.name}']"
				SpecificationDirectoryPassed: (directory) ->
					console.log "##teamcity[testSuiteFinished name='#{directory.name}']"
				SpecificationDirectoryFailed: (directory) ->
					console.log "##teamcity[testSuiteFinished name='#{directory.name}']"

				SpecificationFileRunning: (file) ->
					console.log "##teamcity[testSuiteStarted name='#{file.name}']"
				SpecificationFilePassed: (file) ->
					console.log "##teamcity[testSuiteFinished name='#{file.name}']"
				SpecificationFileFailed: (file) ->
					console.log "##teamcity[testSuiteFinished name='#{file.name}']"

				ScenarioRunning: (scenario) ->
					console.log "##teamcity[testStarted name='scenario-#{scenario.id}']"
				ScenarioPassed: (scenario) ->
					console.log "##teamcity[testFinished name='scenario-#{scenario.id}']"
				ScenarioFailed: (scenario) ->
					console.log "##teamcity[testFailed name='scenario-#{scenario.id}']"
					console.log "##teamcity[testFinished name='scenario-#{scenario.id}']"
				
				ScenarioRunning: -> 
			Witness.runner.runAll()
	else
		console.log "Could not load Witness runner page."
		phantom.exit()
