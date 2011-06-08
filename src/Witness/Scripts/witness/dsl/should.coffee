# reference "../Dsl.coffee"

this.Witness.Dsl::should =
	equal: (expected) ->
		(propertyName) ->
			new Witness.Action "#{propertyName} should equal #{expected}", () ->
				actual = @[propertyName] 
				if actual != expected
					throw new Error("Expected #{propertyName} to equal #{expected} but was #{actual}")

	notEqual: (expected) ->
		(propertyName) ->
			new Witness.Action "#{propertyName} should not equal #{expected}", () ->
				actual = @[propertyName] 
				if actual == expected
					throw new Error("Expected #{propertyName} to not equal #{expected}")
