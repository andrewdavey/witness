# reference "../../lib/jquery.js"
# reference "../Event.coffee"

{ Event } = @Witness

@Witness.manifests = {}

@Witness.manifests.Manifest = class Manifest

	constructor: (@specificationDirectory) ->
		@scripts = []
		@statusChanged = new Event()
		@error = new Event()
		@downloadFinished = new Event()

	log: (message) ->
		@statusChanged.raise message

	download: ->
		@log "Downloading manifest"
		jQuery.ajax
			type: "get"
			url: "/_witness/manifest"
			data: { path: @specificationDirectory }
			cache: no
			success: (manifestData) =>
				@downloadManifestSucceeded manifestData
			error: (xhr) => 
				@downloadManifestFailed xhr

	downloadManifestSucceeded: (manifestData) ->
		# manifestData is a directory object
		# directory = { helpers: url string array: file array, directories: directory array }
		# file = { url: string, name: string }

		collectUrls = (directory, urls = []) ->
			for helper in directory.helpers
				urls.push helper
			for file in directory.files
				urls.push file.url
			# Recurse into sub-directories
			for subDirectory in directory.directories
				collectUrls subDirectory, urls
			urls

		allUrls = collectUrls manifestData
		@downloadScripts allUrls

	downloadManifestFailed: (xhr) ->
		@error.raise "Manifest download failed. " + xhr.responseText
		@downloadFinished.raise()

	downloadScripts: (urls) ->
		@log "Downloading scripts"
		downloads = (@downloadScript url for url in urls)
		jQuery.when(downloads...).then(
			=> @downloadScriptsSucceeded()
			=> @downloadScriptsFailed()
		)

	downloadScript: (url) ->
		script = @scripts[url] = { url: url }
		# return the deferred object so we can wait for it to resolve.
		jQuery.ajax
			type: "get"
			url: url
			dataType: "text" # Stop jQuery executing the script. We'll be handling that later.
			cache: no
			success: (scriptSource) =>
				script.source = scriptSource
			error: (xhr) =>
				script.error = xhr.responseText

	downloadScriptsSucceeded: ->
		@log "Parsing scripts"

	downloadScriptsFailed: ->
		for script in @scripts when script.error?
			@error.raise "Download of #{script.url} failed: #{script.error}"
		@downloadFinished.raise()
