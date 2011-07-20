# reference "../witness/Event.coffee"
# reference "../witness/MessageBus.coffee"
# reference "_namespace.coffee"

{ Event, messageBus } = @witness

@witness.ui.IframeManager = class IframeManger

	constructor: ->
		@iframes = {}
		@currentId = null
		@iframeAdded = new Event()
		messageBus.addHandler "AppendIframe", (iframe, id) =>
			@add iframe, id

	add: (iframe, id) ->
		@iframes[id] = iframe
		@iframeAdded.raise iframe
		@show id

	show: (id) ->
		@hideActive()
		if id of @iframes
			@iframes[id]?.show()
			@currentId = id
		else
			@currentId = null

	hideActive: ->
		@iframes[@currentId]?.hide()
