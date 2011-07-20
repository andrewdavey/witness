# reference "../lib/knockout.js"
# reference "../lib/jquery.js"
# reference "../witness/MessageBus.coffee"

{ messageBus } = @witness

ko.bindingHandlers['iframes'] =
	init: (element, valueAccessor) ->
		iframeManager = ko.utils.unwrapObservable valueAccessor()
		iframeManager.iframeAdded.addHandler (iframe) ->
			jQuery(element).append iframe
