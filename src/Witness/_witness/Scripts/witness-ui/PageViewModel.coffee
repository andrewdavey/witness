# reference "../lib/jquery.js"
# reference "../lib/knockout.js"
# reference "_namespace.coffee"
# reference "SetupViewModel.coffee"

{ SetupViewModel } = @Witness.ui

# PageViewModel is the root of the Witness page.
# It contains all the nested view models and transition behavior.
class PageViewModel

	constructor: ->
		# The body view model is the currently active view model of the page.
		# (Using an array to work around strange KnockoutJS behavior.)
		@bodyViewModel = ko.observableArray []
		@setupViewModel = new SetupViewModel()
		@showSetup()

	bodyTemplateId: (viewModel) ->
		viewModel.templateId

	showSetup: ->
		@bodyViewModel [ @setupViewModel ]
	
# Bind the view model to the whole page.
$ -> ko.applyBindings new PageViewModel()
