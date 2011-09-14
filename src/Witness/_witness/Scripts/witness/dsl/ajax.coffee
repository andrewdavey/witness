# reference "../Dsl.coffee"
# reference "../../lib/jquery.js"

@witness.Dsl::ajax_request = (options, context) ->
	myasync = context
	url = "#{window.location.protocol}//#{window.location.host}/#{options.url}" unless options.url.match /^\//
	myasync.response = null
	xhr = jQuery.ajax
		async: false
		url: url
		contentType: options.content_type
		headers: options.headers
		dataType: options.data_type
		success: (data) ->
			myasync.response = data
		beforeSend: (xhr) ->
			xhr.setRequestHeader "Accept", options.content_type

	console.log "Request with content type #{options.content_type} completed for #{url}  "
	myasync.xhr = xhr
	myasync.errored = xhr.statusText isnt "success"
	myasync.content_type = xhr.getResponseHeader "content-type"
	myasync.headers = xhr.getAllResponseHeaders()
	myasync.status_code = xhr.status
	myasync.done()
