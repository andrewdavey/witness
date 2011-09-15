# reference "../Dsl.coffee"
# reference "../../lib/jquery.js"

@witness.Dsl::ajax_request = (options, context) ->
	async_context = context
	async_context.response = null

	merged = jQuery.extend
		async:false
		success: (data,status,jxhr)->
			content_type = jxhr.getResponseHeader "content-type"
			console.log content_type
			async_context.response = data if content_type isnt 'text/html'
			async_context.response = jQuery(data) if content_type is 'text/html'
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
