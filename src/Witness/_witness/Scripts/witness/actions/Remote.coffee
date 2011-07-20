# reference "../Dsl.coffee"
# reference "../dsl/async.coffee"
# reference "../dsl/defineActions.coffee"

{ async } = @witness.Dsl::

@witness.Dsl::defineActions
	remote: async (remotefunc) ->
		$.ajax 
			url:"execute-script"
			type: "POST"
			data: "(#{remotefunc})(this)"
			success: (data) =>
				@done data
			error: (xhr, data) =>
				contentType = xhr.getResponseHeader "Content-Type"
				if contentType.match /application\/json/
					@fail { message: JSON.parse(xhr.responseText).error }
				else
					@fail { message: xhr.responseText }
			dataType: "json"

