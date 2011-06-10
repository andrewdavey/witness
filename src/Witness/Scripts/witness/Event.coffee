# reference "Witness.coffee"

this.Witness.Event = class Event
	constructor: ->
		@handlers = []

	addHandler: (handler) ->
		@handlers.push handler

	raise: (args...) ->
		for handler in @handlers
			handler.apply null, args


Event.define = (names...) ->
	events = {}
	events[name] = new Event() for name in names
	events
