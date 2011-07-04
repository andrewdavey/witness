[url, path] = phantom.args

if not url? or not path?
	console.log "Usage:"
	console.log "phantomjs.exe run-witness.coffee application-URL spec-path"
	phantom.exit()
	return

runnerUrl = "#{url}/_witness/runner.htm?path=#{path}"
console.log "Loading #{runnerUrl}"

page = new WebPage()
loaded = no
page.open runnerUrl, (status) ->
	return if loaded # callback called for iframe loads as well, so skip those!

	if status == "success"
		loaded = yes
		page.onConsoleMessage = (message) ->
			if message == "!exit"
				phantom.exit()
			else
				console.log message

		# evaluate runs the function in the context of the page.
		# So it has no access to phantom, exception for logging to console.
		page.evaluate ->
			escape = (s) ->
				s.replace(/\|/g, "||")
				 .replace(/\n/g, "|n")
				 .replace(/\r/g, "|r")
				 .replace(/'/g,  "|'")

			Witness.messageBus.addHandlers
				RunnerFinished: ->
					console.log "!exit"

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
				ScenarioFailed: (scenario, error) ->
					console.log error
					message = if error.join
						(escape e.message for e in error).join("|n")
					else if error.message?
						escape error.message
					else
						escape error.toString()
					console.log "##teamcity[testFailed name='scenario-#{scenario.id}' message='#{message}']"
					console.log "##teamcity[testFinished name='scenario-#{scenario.id}']"
				
			Witness.runner.runAll()
	else
		console.log "Could not load Witness runner page."
		phantom.exit()
