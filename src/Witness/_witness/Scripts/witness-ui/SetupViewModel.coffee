# reference "../lib/knockout.js"
# reference "../witness/manifests/Manifest.coffee"
# reference "../witness/Event.coffee"
# reference "../witness/MessageBus.coffee"
# reference "_namespace.coffee"

{ Event, messageBus } = @Witness
{ Manifest } = @Witness.manifests

# The setup view model allows the use to specify a specification 
# directory to download. The manifest is downloaded, scripts parsed
# and evaluated to produce a tree of specifications.

@Witness.ui.SetupViewModel = class SetupViewModel

	constructor: (pageArguments) ->
		@specificationDirectory = ko.observable pageArguments.specs or ""
		@applicationUrl = ko.observable (pageArguments.url or "")
		@canInput = ko.observable yes
		@showLog = ko.observable no
		@log = ko.observableArray []
		@finished = new Event()
		
		if @specificationDirectory() and @applicationUrl()
			@download()

	templateId: "setup-screen"

	reset: ->
		@log.removeAll()
		@canInput yes
		@showLog no

	download: ->
		@log.removeAll()
		@canInput no
		@showLog yes

		if @applicationUrl().length > 0
			jQuery.post "/_witness/setupproxy", { url: @applicationUrl() }

		manifest = new Manifest @specificationDirectory

		manifest.statusChanged.addHandler (message) =>
			@log.push { message: message, type: "message" }
		manifest.error.addHandler (message) =>
			@log.push { message: message, type: "error" }
		manifest.downloadSucceeded.addHandler =>
			@finished.raise manifest
		manifest.downloadFailed.addHandler =>
			@canInput yes
			messageBus.send "RunnerDownloadFailed"

		manifest.download()

	
