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

		for status in [ "downloading", "downloaded", "running", "passed", "failed" ]
			do (status) =>
				@directory.on[status].addHandler => @status status

	download: ->
		@directory.download()

	fileTemplate: (file) ->
		return "file-of-one" if file.specifications().length == 1
		return "file-of-many"

	run: (done = (->)) ->
		@reset()
		@directory.run {}, done, done if @canRun() 

	reset: ->
		directory.reset() for directory in @directories
		file.reset() for file in @files

	toggleOpen: ->
		@isOpen(not @isOpen())
