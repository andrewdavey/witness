# reference "Witness.coffee"
# reference "SpecificationFile.coffee"
# reference "SpecificationHelper.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"
# reference "AsyncAction.coffee"

{ Event, SpecificationHelper, SpecificationFile, AsyncAction, Sequence, TryAll } = @Witness

@Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest, parentHelpers = []) ->
		@name = manifest.name
		@on = Event.define "downloading", "downloaded", "downloadFailed", "running", "passed", "failed"
		@helpers = (new SpecificationHelper url for url in manifest.helpers or [])
		allHelpers = parentHelpers.concat @helpers
		@directories = (new SpecificationDirectory(directory, allHelpers) for directory in manifest.directories or [])
		@files = (new SpecificationFile(file, allHelpers) for file in manifest.files or [])

	download: (done = (->), fail = (->)) ->
		@on.downloading.raise()

		# Download all the helpers, sub-directories and files
		items = [].concat @helpers, @directories, @files
		downloadActions = for item in items
			do (item) ->
				action = new AsyncAction (-> item.download @done, @fail)
				action.timeout = 10000 # 10 seconds
				action

		sequence = new Sequence downloadActions
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
		tryAll = new TryAll all
		tryAll.run context,
			=>
				Witness.messageBus.send "SpecificationDirectoryPassed", this
				@on.passed.raise()
				done()
			(error) =>
				Witness.messageBus.send "SpecificationDirectoryFailed", this
				@on.failed.raise(error)
				fail(error)
