# reference "../lib/knockout.js"
# reference "../lib/jquery.js"
# reference "../witness/MessageBus.coffee"

{ messageBus } = @Witness

ko.bindingHandlers['iframes'] =
	init: (element, valueAccessor) ->
		messageBus.addHandler "AppendIframe", (iframe) ->
			jQuery(element).append(iframe)
