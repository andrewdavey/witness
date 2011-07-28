# reference "_namespace.coffee"
# reference "../lib/knockout.js"

@witness.ui.TreeNode = class TreeNode
	
	constructor: (@tree, @parent, @data) ->
		# @data stores an underlying model object e.g. Scenario, Specificiation, etc
		@text = ko.observable ""
		@status = ko.observable ""
		@children = ko.observableArray []
		@isOpen = ko.observable no
		@isSelected = ko.observable no

	nodeTemplateId: (node) ->
		node.templateId

	toggleOpen: ->
		@isOpen not @isOpen()

	select: ->
		@tree.selectNode this

	map: (func) ->
		func this
		for child in @children()
			child.map func

	remove: ->
		@parent.children.remove this
