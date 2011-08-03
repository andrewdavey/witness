# reference "../witness/Manifest.coffee"
# reference "../lib/jquery.js"

{ Manifest, Dsl, messageBus } = @witness

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

	manifest.on.downloadFailed.addHandler sendFinishedMessage
	manifest.on.downloaded.addHandler (directory) =>
		directory.on.downloadFailed.addHandler sendFinishedMessage
		directory.on.downloaded.addHandler =>
			action = Dsl::beforeAll.putBefore directory
			action.run {}, sendFinishedMessage, sendFinishedMessage
		directory.download()
	manifest.download()

pageArguments = ->
	hash = document.location.hash.substring 1
	items = hash.split /&/
	args = {}
	for item in items
		[key, value] = item.split /=/
		args[key] = decodeURIComponent value
	args
