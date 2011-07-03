# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"

this.Witness.ViewModels.SpecificationFileViewModel = class SpecificationFileViewModel

	constructor: (@file) ->
		@name = @file.name
		@status = ko.observable "notdownloaded"
		@isOpen = ko.observable false
		@specifications = ko.observableArray []
		@errors = ko.observableArray []
		@canRun = ko.dependentObservable =>
			result = null
			switch @status()
				when "ready", "passed", "failed" then result = yes
				else result = no
			result

		@file.on.downloading.addHandler =>
			@errors.removeAll()
			@specifications.removeAll()
			@status "downloading"
		@file.on.downloaded.addHandler =>
			@status "downloaded"
		@file.on.downloadFailed.addHandler (errors) =>
			@status "downloadFailed"
			@errors.push error for error in errors
			@isOpen true

		@file.on.ready.addHandler =>
			@status "ready"
			@specifications (new Witness.ViewModels.SpecificationViewModel spec for spec in @file.specifications)

		@file.on.running.addHandler => @status "running"
		@file.on.passed.addHandler => @status "passed"
		@file.on.failed.addHandler =>
			@status "failed"
			@isOpen true
		
	download: ->
		@file.download()

	run: ->
		@file.run {}, (->), (->) if @canRun()
		
	reset: ->
		specification.reset() for specification in @specifications()

	toggleOpen: ->
		@isOpen(not @isOpen())

	scenarioTemplate: (item) ->
		if item instanceof Witness.ViewModels.OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"
