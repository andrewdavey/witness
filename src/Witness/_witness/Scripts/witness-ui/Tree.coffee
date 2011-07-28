# reference "_namespace.coffee"
# reference "../lib/knockout.js"
# reference "../witness/Event.coffee"
# reference "DirectoryNode.coffee"

{ Event, ui: { DirectoryNode } } = @witness

@witness.ui.Tree = class Tree extends DirectoryNode

	constructor: (rootDirectory) ->
		super "", rootDirectory, this, null
		@selectedNode = ko.observable null

		@nodeSelected = new Event()

	nodeTemplateId: (node) ->
		node.templateId

	selectNode: (node) ->
		@selectedNode()?.isSelected no
		node.isSelected yes
		@selectedNode node
		@nodeSelected.raise node
		
	map: (func) ->
		for node in @children()
			node.map func
