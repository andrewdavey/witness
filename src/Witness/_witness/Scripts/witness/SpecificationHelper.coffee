# reference "Witness.coffee"
# reference "ScriptFile.coffee"

{ ScriptFile } = @witness

@witness.SpecificationHelper = class SpecificationHelper extends ScriptFile

	constructor: (manifest) ->
		super manifest
