# reference "Witness.coffee"
# reference "ScriptFile.coffee"

{ ScriptFile } = @Witness

@Witness.SpecificationHelper = class SpecificationHelper extends ScriptFile

	constructor: (url) ->
		super url

	scriptDownloaded: (script, done, fail) ->
		@script = script
		done()

