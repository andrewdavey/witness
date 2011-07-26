# reference "../lib/knockout.js"
# reference "../witness/Manifest.coffee"
# reference "../witness/Event.coffee"
# reference "../witness/MessageBus.coffee"
# reference "_namespace.coffee"

{ Manifest, Event, messageBus } = @witness

# The setup view model allows the use to specify a specification 
# directory to download. The manifest is downloaded, scripts parsed
# and evaluated to produce a tree of specifications.

@witness.ui.SetupViewModel = class SetupViewModel

	constructor: (pageArguments, cookieData) ->
		@specificationDirectory = ko.observable pageArguments.specs or cookieData["_witness_path"] or ""
		@applicationUrl = ko.observable (pageArguments.url or cookieData["_witness_proxy"] or "")
		@canInput = ko.observable yes
		@showLog = ko.observable no
		@log = ko.observableArray []
		@hasErrors = ko.observable no
		@finished = new Event()
		
		if @specificationDirectory() and @applicationUrl()
			@download()

	templateId: "setup-screen"

	reset: ->
		@log.removeAll()
		@canInput yes
		@showLog no
		@hasErrors no

	download: ->
		@log.removeAll()
		@canInput no
		@showLog yes
		@hasErrors no

		if @applicationUrl().length > 0
			jQuery.post "/_witness/setupproxy", {
				url: @applicationUrl(),
				path: @specificationDirectory()
			}

		manifest = new Manifest @specificationDirectory

		manifest.on.downloaded.addHandler (rootDirectory) =>
			rootDirectory.on.downloaded.addHandler =>
				@finished.raise rootDirectory
			rootDirectory.on.downloadFailed.addHandler =>
				@hasErrors yes
				@canInput yes
			@bindDirectoryDownloadEventsToLog rootDirectory
			rootDirectory.download()

		manifest.on.downloadFailed.addHandler (error) =>
			@hasErrors yes
			@canInput yes
			@startLog error, "error"
			messageBus.send "RunnerDownloadFailed", error

		manifest.download()

	startLog: (message, status) ->
		logItem = new LogItem message
		logItem.status status if status?
		@log.push logItem
		logItem

	bindDirectoryDownloadEventsToLog: (directory) ->
		logItem = null
		directory.on.downloading.addHandler =>
			logItem = @startLog "Downloading #{directory.name}..."
		directory.on.downloaded.addHandler ->
			logItem.appendMessage " done."
		directory.on.downloadFailed.addHandler ->
			logItem.appendMessage " failed."

		for subDirectory in directory.directories
			@bindDirectoryDownloadEventsToLog subDirectory
		for file in directory.files.concat(directory.helpers)
			@bindFileDownloadEventsToLog file
	
	bindFileDownloadEventsToLog: (file) ->
		logItem = null
		file.on.downloading.addHandler =>
			logItem = @startLog "Downloading #{file.path}..."
		file.on.downloaded.addHandler =>
			logItem.appendMessage " done."
		file.on.downloadFailed.addHandler (errors) =>
			logItem.status "error"
			logItem.appendMessage " failed."
			for error in errors
				logItem.addDetail error.message

class LogItem

	constructor: (message) ->
		@status = ko.observable ""
		@message = ko.observable message
		@details = ko.observableArray []

	appendMessage: (message) ->
		@message(@message() + message)

	addDetail: (detail) ->
		@details.push detail
