# Thanks to http://ejohn.org/blog/objectgetprototypeof/

if typeof Object.getPrototypeOf != "function"
	if typeof "test".__proto__ == "object"
		Object.getPrototypeOf = (object) -> object.__proto__
    
	else
		# May break if the constructor has been tampered with
		Object.getPrototypeOf = (object) -> object.constructor.prototype