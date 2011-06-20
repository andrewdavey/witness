# reference "Witness.coffee"
# reference "SpecificationFile.coffee"
# reference "SpecificationHelper.coffee"

this.Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest) ->
		@name = manifest.name
		@on = Witness.Event.define "downloading", "downloaded", "running", "passed", "failed"
		@directories = (new SpecificationDirectory directory for directory in manifest.directories or [])
		@files = (new Witness.SpecificationFile file for file in manifest.files or [])
		@helpers = (new Witness.SpecificationHelper url for url in manifest.helpers or [])

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
				item.download itemDownloadCallback, fail
		else
			@on.downloaded.raise()
			done()

	run: (context, done, fail) ->
		Witness.messageBus.send "SpecificationDirectoryRunning", this
		@on.running.raise()
		all = @directories.concat @files
		tryAll = new Witness.TryAll all
		tryAll.run context,
			=>
				@on.passed.raise()
				Witness.messageBus.send "SpecificationDirectoryPassed", this
				done()
			(error) =>
				@on.failed.raise(error)
				Witness.messageBus.send "SpecificationDirectoryFailed", this
				fail(error)
