describe "SpecificationHelper",
{
	"given a SpecificationHelper": ->
		@helper = new Witness.SpecificationHelper "/exampe/url.js"
		@restorejQuery = mock jQuery, {
			ajax: (options) ->
				options.success ""
		}

	"when it is downloaded": ->
		@helper.download()

	dispose: ->
		@restorejQuery()
}
