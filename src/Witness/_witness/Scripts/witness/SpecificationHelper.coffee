# reference "Witness.coffee"
# reference "ScriptFile.coffee"

{ ScriptFile } = @witness

@witness.SpecificationHelper = class SpecificationHelper extends ScriptFile

	constructor: (url) ->
		super url

	scriptDownloaded: (script) ->
		@script = script
		super()
