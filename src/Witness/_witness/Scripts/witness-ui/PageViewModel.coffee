# reference "../lib/jquery.js"
# reference "../lib/knockout.js"
# reference "_namespace.coffee"
# reference "SetupViewModel.coffee"
# reference "RunnerViewModel.coffee"

{ SetupViewModel, RunnerViewModel } = @Witness.ui

# PageViewModel is the root of the Witness page.
# It contains all the nested view models and transition behavior.
class PageViewModel

	constructor: ->
		# The body view model is the currently active view model of the page.
		# (Using an array to work around strange KnockoutJS behavior.)
		@bodyViewModel = ko.observableArray []
		@setupViewModel = new SetupViewModel @getPageArguments()

		@setupViewModel.finished.addHandler (manifest) =>
			@showRunner manifest

		@showSetup()

	bodyTemplateId: (viewModel) ->
		viewModel.templateId

	showSetup: ->
		@bodyViewModel [ @setupViewModel ]

	showRunner: (manifest) ->
		@bodyViewModel [ new RunnerViewModel manifest ]
	
	getPageArguments: ->
		pairs = window.location.hash.substring(1).split /&/
		args = {}
		for pair in pairs
			[ key, value ] = pair.split /\=/ 
			args[key] = decodeURIComponent value
		args


# Bind the view model to the whole page.
$ -> ko.applyBindings new PageViewModel()
