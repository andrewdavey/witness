describe "SpecificationHelper",
{
	"given a SpecificationHelper": ->
		@helper = new witness.SpecificationHelper { url: "/exampe/url.js", path: "url.js" }
		@restorejQuery = mock jQuery, {
			ajax: (options) ->
				options.success ""
		}

	"when it is downloaded": ->
		@helper.download()

	dispose: ->
		@restorejQuery()
}
