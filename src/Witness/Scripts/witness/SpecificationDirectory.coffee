# reference "Witness.coffee"
# reference "SpecificationFile.coffee"
# reference "SpecificationHelper.coffee"

this.Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest, parentHelpers = []) ->
		@name = manifest.name
		@on = Witness.Event.define "downloading", "downloaded", "downloadFailed", "running", "passed", "failed"
		@helpers = (new Witness.SpecificationHelper url for url in manifest.helpers or [])
		allHelpers = parentHelpers.concat @helpers
		@directories = (new SpecificationDirectory(directory, allHelpers) for directory in manifest.directories or [])
		@files = (new Witness.SpecificationFile(file, allHelpers) for file in manifest.files or [])

	download: (done = (->), fail = (->)) ->
		@on.downloading.raise()

		# Download all the helpers, sub-directories and files
		items = [].concat @helpers, @directories, @files
		downloadActions = for item in items
			do (item) ->
				new Witness.AsyncAction (-> item.download @done, @fail)

		sequence = new Witness.Sequence downloadActions
		sequence.run {},
			=> # all done
				@on.downloaded.raise()
				done()
			(args...) => # something failed
				@on.downloadFailed.raise args...
				fail.apply null, args


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
