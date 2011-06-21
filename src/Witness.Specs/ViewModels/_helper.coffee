# Override the default unwrapActual function to handle Knockout observables.
should.unwrapActual = (actual) -> 
	isObservable = actual?.__ko_proto__?
	if isObservable
		actual()
	else
		actual
