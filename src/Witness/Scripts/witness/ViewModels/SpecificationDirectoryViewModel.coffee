# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"
# reference "SpecificationFileViewModel.coffee"

this.Witness.ViewModels.SpecificationDirectoryViewModel = class SpecificationDirectoryViewModel
	
	constructor: (@directory) ->
		@name = @directory.name
		@status = ko.observable "notdownloaded"
		@isOpen = ko.observable true
		@canRun = ko.dependentObservable =>
			result = null
			switch @status()
				when "downloaded", "passed", "failed" then result = yes
				else result = no
			result

		@files = (new Witness.ViewModels.SpecificationFileViewModel file for file in @directory.files)
		@directories = (new SpecificationDirectoryViewModel directory for directory in @directory.directories)

		@directory.on.downloading.addHandler => @status "downloading"
		@directory.on.downloaded.addHandler => @status "downloaded"
		@directory.on.run.addHandler => @status "running"
		@directory.on.done.addHandler => @status "passed"
		@directory.on.fail.addHandler => @status "failed"
	

	download: ->
		@directory.download()

	fileTemplate: (file) ->
		return "file-of-one" if file.specifications().length == 1
		return "file-of-many"

	run: ->
		@directory.run {}, (->), (->) if @canRun() 

	toggleOpen: ->
		@isOpen(not @isOpen())
