# reference "Witness.coffee"
# reference "ScriptFile.coffee"

{ ScriptFile } = @witness

@witness.SpecificationHelper = class SpecificationHelper extends ScriptFile

	constructor: (url) ->
		super url

	scriptDownloaded: (script, done, fail) ->
		@script = script
		done()

