handlers = {}

addHandler = (messageType, handlerFunction) ->
	array = handlers[messageType] or (handlers[messageType] = [])
	array.push handlerFunction
	return

send = (messageType, data) ->
	array = handlers[messageType]
	return if not array
	run data for run in array
	return

this.Witness.MessageBus =
	addHandler: addHandler
	send: send
