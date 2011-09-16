# reference "../Dsl.coffee"
# reference "should.coffee"

xmlPredicates =
	haveRoot:
		test: (actual, expected) ->
			actual? and actual[0]? and actual[0].tagName is expected
		description: (fullname, expected) -> 
			"The document should have the root element <#{expected}>"
		error: (fullname, actual, expected) ->
			if actual? then "but it was actually <#{@actual_node}>" else "but the document was null"

	haveElement:
		test: (actual, expected) ->
			actual? and jQuery(expected, actual).length > 0
		description: (fullname, expected) -> 
			"The document should have the element '#{expected}'"
		error: (fullname, actual, expected) -> 
			if actual? then "but it didn't" else "but the document was null"

	haveMoreThanOneElement:
		test: (actual, expected) ->
			@matched_nodes = jQuery(expected, actual).length
			@matched_nodes > 1
		description: (fullname, expected) -> 
			"The document should have more than one element '#{expected}'"
		error: (fullname, actual, expected) -> 
			if actual? then "but #{@matched_nodes} element#{if @matched_nodes == 0 then "s were" else " was"} found" else "but the document was null"

{ Dsl } = @witness
Dsl::extendShould xmlPredicates
