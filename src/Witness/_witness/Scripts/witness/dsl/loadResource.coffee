# reference "../Dsl.coffee"
# reference "should.coffee"
# reference "async.coffee"
# reference "../../lib/jquery.js"

{ async, defineActions } = @witness.Dsl::

defineActions
	loadResource: async (options) ->
		ajaxOptions = jQuery.extend
			complete: (xhr, status) =>
				content_type = xhr.getResponseHeader "content-type"
				@xhr = xhr
				@errored = status isnt "success"
				@content_type = content_type
				@headers = xhr.getAllResponseHeaders()
				@status_code = xhr.status
				@document = if content_type == "application/json"
					try
						JSON.parse xhr.responseText
					catch e
						@errored = true
				else if content_type.indexOf 'xml'
					jQuery xhr.responseText
				else
					xhr.responseText
				@done()
			beforeSend: (jxhr, settings) ->
				try console.log "Request with accepts: #{settings.accepts} dataType: #{settings.dataType} completed for #{settings.url}" if  typeof settings.accepts is 'string' and typeof settings.dataType is 'string'
				try console.log "Request with accepts: #{settings.accepts} completed for #{settings.url}" if  typeof settings.accepts is 'string' and typeof settings.dataType isnt 'string'
				try console.log "Request with dataType: #{settings.dataType} completed for #{settings.url}" if typeof settings.accepts isnt 'string' and typeof settings.dataType is 'string'
				try console.log "Request completed for #{settings.url}" if typeof settings.accepts isnt 'string' and typeof settings.dataType isnt 'string'
				jxhr.setRequestHeader "Accept", settings.accepts if typeof settings.accepts is 'string'
			options

		@document = null
		jQuery.ajax ajaxOptions

shouldHaveHeader = 
	haveHeader:
		test: (xhr, expected) ->
			@actual_value = xhr.getResponseHeader expected.key
			expected.value is @actual_value 
		description: (fullname, expected) -> 
			"The response should include the header '#{expected.key}: #{expected.value}'"
		error: (fullname, actual, expected) ->
			if @actual_value? then "but it was actually '#{@actual_value}'" else "but the header wasn't present"
	
{ Dsl } = @witness
Dsl::extendShould shouldHaveHeader