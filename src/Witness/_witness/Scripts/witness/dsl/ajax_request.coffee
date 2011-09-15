# reference "../Dsl.coffee"
# reference "../../lib/jquery.js"

@witness.Dsl::ajax_request = (options, context) ->
	async_context = context
	async_context.response = null

	merged = jQuery.extend
		async:false, success: (data)-> async_context.response = data
		options
	
	console.log merged

	xhr = jQuery.ajax merged


	console.log "Request with accepts: #{options.accepts} completed for #{options.url}  "
	async_context.xhr = xhr
	async_context.errored = xhr.statusText isnt "success"
	async_context.content_type = xhr.getResponseHeader "content-type"
	async_context.headers = xhr.getAllResponseHeaders()
	async_context.status_code = xhr.status
	async_context.done()
