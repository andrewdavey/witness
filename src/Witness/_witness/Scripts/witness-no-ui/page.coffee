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

	body = $("body")
	messageBus.addHandler "AppendIframe", (iframe) => body.append iframe

	manifest = new Manifest specs

	sendFinishedMessage = ->
		messageBus.send "RunnerFinished"

	manifest.on.downloaded.addHandler (directory) =>
		directory.on.downloaded.addHandler =>
			directory.run {},
				sendFinishedMessage,
				sendFinishedMessage
		directory.on.downloadFailed.addHandler sendFinishedMessage
		directory.download()
	manifest.on.downloadFailed.addHandler sendFinishedMessage
	manifest.download()

pageArguments = ->
	hash = document.location.hash.substring 1
	items = hash.split /&/
	args = {}
	for item in items
		[key, value] = item.split /=/
		args[key] = decodeURIComponent value
	args
