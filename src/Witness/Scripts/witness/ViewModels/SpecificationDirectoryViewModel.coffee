# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"
# reference "SpecificationFileViewModel.coffee"

this.Witness.ViewModels.SpecificationDirectoryViewModel = class SpecificationDirectoryViewModel
	
	constructor: (@directory) ->
		@name = @directory.name
		@status = ko.observable "notdownloaded"
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

	run: ->
		@directory.run({}, (->), (->)) if @canRun() 
