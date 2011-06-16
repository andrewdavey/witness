handlers = {}

addHandler = (messageType, handlerFunction) ->
	array = handlers[messageType] or (handlers[messageType] = [])
	array.push handlerFunction
	return

addHandlers = (object) ->
	for own messageType, handlerFunction of object
		addHandler messageType, handlerFunction 

send = (messageType, data) ->
	array = handlers[messageType]
	return if not array
	run data for run in array
	return

this.Witness.messageBus =
	addHandler: addHandler
	addHandlers: addHandlers
	send: send
