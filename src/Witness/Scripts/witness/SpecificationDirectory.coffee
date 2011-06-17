# reference "Witness.coffee"
# reference "SpecificationFile.coffee"

this.Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest) ->
		@name = manifest.name
		@on = Witness.Event.define "downloading", "downloaded", "run", "done", "fail"
		@directories = (new SpecificationDirectory directory for directory in manifest.directories)
		@files = (new Witness.SpecificationFile file for file in manifest.files)

	download: (done = (->), fail = (->)) ->
		@on.downloading.raise()

		# Download all the files and sub-directories
		items = @directories.concat @files
		remainingDownloadCount = items.length
		itemDownloadCallback = =>
			remainingDownloadCount--
			if remainingDownloadCount == 0
				@on.downloaded.raise()
				done()

		if items.length
			for item in items
				item.download itemDownloadCallback
		else
			@on.downloaded.raise()
			done()

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
