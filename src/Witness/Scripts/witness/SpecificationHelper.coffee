# reference "Witness.coffee"

Witness = this.Witness

Witness.SpecificationHelper = class SpecificationHelper extends Witness.ScriptFile

	constructor: (url) ->
		super url

	scriptDownloaded: (script, done, fail) ->
		@script = script
		done()

