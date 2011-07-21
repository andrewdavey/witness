# reference "../lib/jquery.js"
# reference "Event.coffee"
# reference "SpecificationDirectory.coffee"

{ Event, SpecificationDirectory } = @witness

# Manifest downloads manifest data and creates a SpecificationDirectory.
@witness.Manifest = class Manifest

	constructor: (@specificationPath) ->
		@on = Event.define "downloading", "downloaded", "downloadFailed"

	download: ->
		@on.downloading.raise()
		jQuery.ajax
			type: "get"
			url: "/_witness/manifest"
			data: { path: @specificationPath }
			cache: no
			success: (manifestData) =>
				@on.downloaded.raise new SpecificationDirectory manifestData
			error: (xhr) => 
				error = xhr.getResponseText()
				@on.downloadFailed.raise [ error ]
