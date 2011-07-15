# reference "_namespace.coffee"
# reference "../lib/knockout.js"

@Witness.ui.TreeNode = class TreeNode
	
	constructor: ->
		@text = ko.observable ""
		@isOpen = ko.observable no
		@selected = ko.observable no
		@children = ko.observableArray []

	childTemplateId: (child) ->
		child.templateId

	toggleOpen: ->
		@isOpen not @isOpen()
