# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"

this.Witness.ViewModels.SpecificationFileViewModel = class SpecificationFileViewModel

	constructor: (@file) ->
		@name = @file.name
		@status = ko.observable "notdownloaded"
		@specifications = ko.observableArray []

		@file.on.downloading.addHandler => @status "downloading"
		@file.on.downloaded.addHandler =>
			@status "downloaded"
			@specifications @file.specifications
		@file.on.run.addHandler => @status "running"
		@file.on.done.addHandler => @status "passed"
		@file.on.fail.addHandler => @status "failed"
		
	download: ->
		@file.download()

	run: ->
		@file.run {}, (->), (->) 
