[url, path] = phantom.args

if not url? or not path?
	console.log "Usage:"
	console.log "phantomjs.exe run-witness.coffee application-URL spec-path"
	phantom.exit()
	return

runnerUrl = "#{url}/_witness/runner.htm?path=#{path}&manualdownload=yes&autorun=yes"
console.log "Loading #{runnerUrl}"

startTime = +new Date()
page = new WebPage()
loaded = no
page.open runnerUrl, (status) ->
	return if loaded # callback called for iframe loads as well, so skip those!

	if status == "success"
		loaded = yes
		page.onConsoleMessage = (message) ->
			if message == "!exit"
				endTime = +new Date()
				duration = endTime - startTime
				console.log "Duration #{duration}ms"
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
			
			flattenErrorMessage = (error) ->
				if error.join
					(escape e.message for e in error).join("|n")
				else if error.message?
					escape error.message
				else
					escape error.toString()

			passCount = 0
			failCount = 0

			Witness.messageBus.addHandlers
				RunnerFinished: ->
					console.log "#{passCount} passed. #{failCount} failed."
					console.log "!exit"
				RunnerDownloadFailed: ->
					console.log "#{passCount} passed. #{failCount} failed."
					console.log "!exit"

				ScriptDownloading: (script) ->
					console.log "##teamcity{compilationStarted compiler='script'}"
					console.log "##teamcity{message text='Parsing #{escape script.url}'}"
				ScriptDownloaded: ->
					console.log "##teamcity{compilationFinished compiler='script'}"
				ScriptDownloadError: (script, error) ->
					message = flattenErrorMessage error
					console.log "##teamcity{message text='#{script.url} #{message}' status='ERROR'}"
					console.log "##teamcity{compilationFinished compiler='script'}"

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

				SpecificationRunning: (spec) ->
					console.log "##teamcity[testSuiteStarted name='#{spec.description}']"
				SpecificationPassed: (spec) ->
					console.log "##teamcity[testSuiteFinished name='#{spec.description}']"
				SpecificationFailed: (spec) ->
					console.log "##teamcity[testSuiteFinished name='#{spec.description}']"

				OuterScenarioRunning: (outer) ->
					console.log "##teamcity[testSuiteStarted name='Outer scenario #{outer.id}']"
				OuterScenarioPassed: (outer) ->
					console.log "##teamcity[testSuiteFinished name='Outer scenario #{outer.id}']"
				OuterScenarioFailed: (outer) ->
					console.log "##teamcity[testSuiteFinished name='Outer scenario #{outer.id}']"

				ScenarioRunning: (scenario) ->
					console.log "##teamcity[testStarted name='scenario-#{scenario.id}']"
				ScenarioPassed: (scenario) ->
					passCount++
					console.log "##teamcity[testFinished name='scenario-#{scenario.id}']"
				ScenarioFailed: (scenario, error) ->
					failCount++
					message = flattenErrorMessage error
					console.log "##teamcity[testFailed name='scenario-#{scenario.id}' message='#{message}']"
					console.log "##teamcity[testFinished name='scenario-#{scenario.id}']"
				
			Witness.runner.download()
			# All specs are run once download has finished because
			# autorun=yes in the runner page URL. 
	else
		console.log "Could not load Witness runner page."
		phantom.exit()
