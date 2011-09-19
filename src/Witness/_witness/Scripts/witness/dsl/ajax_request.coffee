# reference "../Dsl.coffee"
# reference "should.coffee"
# reference "../../lib/jquery.js"

@witness.Dsl::ajax_request = (options, context) ->
	async_context = context
	async_context.document = null
	merged = jQuery.extend
		async:false
		success: (data,status,jxhr)->
			content_type = jxhr.getResponseHeader "content-type"
			is_xml = content_type.indexOf 'xml'
			async_context.document = data if is_xml is -1
			async_context.document = jQuery data if is_xml isnt -1
		beforeSend: (jxhr,settings)->
			try console.log "Request with accepts: #{settings.accepts} dataType: #{settings.dataType} completed for #{settings.url}" if  typeof settings.accepts is 'string' and typeof settings.dataType is 'string'
			try console.log "Request with accepts: #{settings.accepts} completed for #{settings.url}" if  typeof settings.accepts is 'string' and typeof settings.dataType isnt 'string'
			try console.log "Request with dataType: #{settings.dataType} completed for #{settings.url}" if typeof settings.accepts isnt 'string' and typeof settings.dataType is 'string'
			try console.log "Request completed for #{settings.url}" if typeof settings.accepts isnt 'string' and typeof settings.dataType isnt 'string'
			jxhr.setRequestHeader "Accept", settings.accepts if typeof settings.accepts is 'string'
		options
	
	xhr = jQuery.ajax merged

	async_context.xhr = xhr
	async_context.errored = xhr.statusText isnt "success"
	async_context.content_type = xhr.getResponseHeader "content-type"
	async_context.headers = xhr.getAllResponseHeaders()
	async_context.status_code = xhr.status
	async_context.done()

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
