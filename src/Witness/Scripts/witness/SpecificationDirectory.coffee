# reference "Witness.coffee"
# reference "SpecificationFile.coffee"

this.Witness.SpecificationDirectory = class SpecificationDirectory
	constructor: (manifest) ->
		@name = manifest.name
		@directories = (new SpecificationDirectory directory for directory in manifest.directories)
		@files = (new Witness.SpecificationFile file for file in manifest.files)

		for file in @files
			file.download()

	run: (context, done, fail) ->
		all = @directories.concat @files
		tryAll = new Witness.TryAll all
		tryAll.run context, done, fail
