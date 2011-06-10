# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"
# reference "SpecificationFileViewModel.coffee"

this.Witness.ViewModels.SpecificationDirectoryViewModel = class SpecificationDirectoryViewModel
	
	constructor: (@directory) ->
		@name = @directory.name
		@status = ko.observable "notdownloaded"
		
		@files = (new Witness.ViewModels.SpecificationFileViewModel file for file in @directory.files)
		@directories = (new SpecificationDirectoryViewModel directory for directory in @directory.directories)

		@directory.on.downloaded.addHandler => @status "ready"
		@directory.on.run.addHandler => @status "running"
		@directory.on.done.addHandler => @status "passed"
		@directory.on.fail.addHandler => @status "failed"
	

	download: ->
		@status = ko.observable "downloading"
		@directory.download()

	run: ->
		@directory.run({}, (->), (->)) if @status() != "downloading" and @status() != "running"
