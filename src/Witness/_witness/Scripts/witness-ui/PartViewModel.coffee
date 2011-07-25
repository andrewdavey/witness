# reference "_namespace.coffee"
# reference "ActionViewModel.coffee"

{ ActionViewModel } = @witness.ui

@witness.ui.PartViewModel = class PartViewModel

	constructor: (part) ->
		@description = part.description
		@actions = (new ActionViewModel action for action in part.actions)
