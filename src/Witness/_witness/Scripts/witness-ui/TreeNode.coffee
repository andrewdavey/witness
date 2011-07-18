# reference "_namespace.coffee"
# reference "../lib/knockout.js"


@Witness.ui.TreeNode = class TreeNode
	
	constructor: (@tree) ->
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
