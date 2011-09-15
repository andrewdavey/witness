# reference "../Dsl.coffee"
# reference "../../lib/jquery.js"

@witness.Dsl::ajax_request = (options, context) ->
	myasync = context
	myasync.response = null

	defaults =
		async: false
		success: (data) ->
			myasync.response = data
	

	options.url = "#{window.location.protocol}//#{window.location.host}/#{options.url}" unless options.url.match /^\//

	merged = jQuery.extend defaults options
	console.log options
	console.log defaults
	console.log merged
	
	xhr = jQuery.ajax merged
		#beforeSend: (xhr) ->
		#	xhr.setRequestHeader "Accept", options.content_type if options.data_type is undefined

	console.log "Request with accepts: #{options.accepts} completed for #{url}  "
	myasync.xhr = xhr
	myasync.errored = xhr.statusText isnt "success"
	myasync.content_type = xhr.getResponseHeader "content-type"
	myasync.headers = xhr.getAllResponseHeaders()
	myasync.status_code = xhr.status
	myasync.done()
