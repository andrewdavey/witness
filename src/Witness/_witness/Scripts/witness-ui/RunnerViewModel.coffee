# reference "_namespace.coffee"
# reference "treeBuilder.coffee"

{ treeBuilder } = @Witness.ui

@Witness.ui.RunnerViewModel = class RunnerViewModel

	constructor: (manifest) ->
		@treeRoot = treeBuilder.buildDirectoryNode manifest.rootDirectory

	templateId: "runner"


