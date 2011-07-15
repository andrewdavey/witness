# reference "../lib/knockout.js"
# reference "../witness/manifests/Manifest.coffee"
# reference "../witness/Event.coffee"
# reference "_namespace.coffee"

{ Event } = @Witness
{ Manifest } = @Witness.manifests

# The setup view model allows the use to specify a specification 
# directory to download. The manifest is downloaded, scripts parsed
# and evaluated to produce a tree of specifications.

@Witness.ui.SetupViewModel = class SetupViewModel

	constructor: ->
		@specificationDirectory = ko.observable ""
		@applicationUrl = ko.observable ""
		@canInput = ko.observable yes
		@showLog = ko.observable no
		@log = ko.observableArray []
		@finished = new Event()

	templateId: "Setup"

	download: ->
		@log.removeAll()
		@canInput no
		@showLog yes

		manifest = new Manifest @specificationDirectory

		manifest.statusChanged.addHandler (message) =>
			@log.push { message: message, type: "message" }
		manifest.error.addHandler (message) =>
			@log.push { message: message, type: "error" }
		manifest.downloadSucceeded.addHandler =>
			@finished.raise manifest
		manifest.downloadFailed.addHandler =>
			@canInput yes

		manifest.download()

	
