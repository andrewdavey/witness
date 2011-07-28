# reference "../witness/Manifest.coffee"
# reference "../lib/jquery.js"

{ Manifest, messageBus } = @witness

$ ->
	{ specs, url } = pageArguments()

	if url
		jQuery.post "/_witness/setupproxy", {
			url: url,
			path: specs
		}

	manifest = new Manifest specs

	manifest.on.downloaded.addHandler (directory) =>
		directory.run {},
			-> messageBus.send "RunnerFinished"
			-> messageBus.send "RunnerFinished"

	manifest.on.downloadFailed.addHandler =>
		messageBus.send "RunnerFinished"

	manifest.download()

pageArguments = ->
	hash = document.location.hash.substring 1
	items = hash.split /&/
	args = {}
	for item in items
		[key, value] = item.split /=/
		args[key] = value
	args
