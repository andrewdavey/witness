# reference "Witness.coffee"
# reference "SpecificationFile.coffee"
# reference "SpecificationHelper.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"
# reference "AsyncAction.coffee"
# reference "Event.coffee"

{ Event, SpecificationHelper, SpecificationFile, AsyncAction, Sequence, TryAll, messageBus } = @witness

@witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest, parentHelpers = []) ->
		@name = manifest.name
		@on = Event.define "downloading", "downloaded", "downloadFailed", "running", "passed", "failed"
		@helpers = (new SpecificationHelper url for url in manifest.helpers or [])
		allHelpers = parentHelpers.concat @helpers
		@directories = (new SpecificationDirectory(directory, allHelpers) for directory in manifest.directories or [])
		@files = (new SpecificationFile(file, allHelpers) for file in manifest.files or [])

	download: ->
		@on.downloading.raise()

		# Download all the helpers, sub-directories and files
		@listenToChildDownloadEvents()
		for child in @allChildren()
			child.download()

	allChildren: ->
		[].concat @helpers, @directories, @files

	listenToChildDownloadEvents: ->
		children = @allChildren()
		childFailed = no
		childDownloadCount = 0

		childDownloadFinished = =>
			# Have they all finished?
			return if ++childDownloadCount < children.length

			unbindChildEvents()
			if childFailed
				@on.downloadFailed.raise()
			else
				@on.downloaded.raise()

		childDownloadFailed = ->
			childFailed = yes
			childDownloadFinished()

		unbindChildEvents = ->
			for child in children
				child.on.downloaded.removeHandler childDownloadFinished
				child.on.downloadFailed.removeHandler childDownloadFailed

		for child in children
			child.on.downloaded.addHandler childDownloadFinished
			child.on.downloadFailed.addHandler childDownloadFailed

	run: (context, done, fail) ->
		messageBus.send "SpecificationDirectoryRunning", this
		@on.running.raise()
		all = @directories.concat @files
		tryAll = new TryAll all
		tryAll.run context,
			=>
				messageBus.send "SpecificationDirectoryPassed", this
				@on.passed.raise()
				done()
			(error) =>
				messageBus.send "SpecificationDirectoryFailed", this
				@on.failed.raise(error)
				fail(error)
