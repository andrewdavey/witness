# reference "../lib/knockout.js"
# reference "../witness/manifests/Manifest.coffee"
# reference "_namespace.coffee"

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

	templateId: "Setup"

	download: ->
		@canInput no
		@showLog yes
		@log.removeAll()

		manifest = new Manifest @specificationDirectory
		manifest.statusChanged.addHandler (message) =>
			@log.push { message: message, type: "message" }
		errors = no
		manifest.error.addHandler (message) =>
			errors = yes
			@log.push { message: message, type: "error" }
		manifest.downloadFinished.addHandler =>
			@canInput yes if errors

		manifest.download()

	
