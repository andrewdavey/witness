# reference "SimpleRunner.coffee"

# Page initialization for runner.htm
$ ->
	return if not $("html").hasClass "runner"

	queryString = document.location.search
	path = queryString.match /\bpath=(.*?)(&|$)/
	autoRun = queryString.match /\bautorun=(yes|true|on|1)/i
	manualDownload = queryString.match /\bmanualdownload=(yes|true|on|1)/i

	return if not path? # TODO: Display error message asking for the path

	runner = new Witness.SimpleRunner path[1], $("#view"), autoRun
	runner.download() unless manualDownload

	# Make runner the page's root view model.
	ko.applyBindings runner

	# Expose the runner for PhantomJS access
	Witness.runner = runner 
