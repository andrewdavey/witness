# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"
# reference "../../lib/Sizzle.js"

applySelector = (context,propertyNames) -> $(propertyNames[0],context.document)

this.Witness.Dsl::defineShouldFunctions
	haveText:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).text()
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"#{selector} should have the text \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have text \"#{expected}\", but was \"#{actual}\""
   
	haveElements:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).length
		test: (actual, expected = 1) ->
			actual == expected
		description: (selector, expected) ->
			"#{selector} should match  \"#{expected}\" elements"
		error: (selector, actual, expected) ->
			"Expected #{selector} to have \"#{expected}\" elements, but matched \"#{actual}\" elements"