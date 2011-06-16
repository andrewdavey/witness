# reference "Witness.coffee"
# reference "SpecificationFile.coffee"

this.Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest) ->
		@name = manifest.name
		@on = Witness.Event.define "downloading", "downloaded", "run", "done", "fail"
		@directories = (new SpecificationDirectory directory for directory in manifest.directories)
		@files = (new Witness.SpecificationFile file for file in manifest.files)

	download: ->
		@on.downloading.raise()
		items = @directories.concat @files
		remainingDownloadCount = items.length
		for item in items
			item.on.downloaded.addHandler =>
				remainingDownloadCount--
				@on.downloaded.raise() if remainingDownloadCount == 0
			item.download()

	run: (context, done, fail) ->
		Witness.messageBus.send "SpecificationDirectoryRunning", this
		@on.run.raise()
		all = @directories.concat @files
		tryAll = new Witness.TryAll all
		tryAll.run context,
			=>
				@on.done.raise()
				Witness.messageBus.send "SpecificationDirectoryPassed", this
				done()
			(error) =>
				@on.fail.raise(error)
				Witness.messageBus.send "SpecificationDirectoryFailed", this
				fail(error)
