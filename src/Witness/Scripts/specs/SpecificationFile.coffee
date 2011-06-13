describe "SpecificationFile",
{
	"given a SpecificationFile that is passed a file manifest": ->
		manifest =
			name: "test.coffee"
			url: "/specs/test.coffee"
		@restorejQuery = mock jQuery, {
			ajax: (options) ->
				options.success ""
		}
		@file = new Witness.SpecificationFile manifest

	"when the file is downloaded": async ->
		@file.on.downloading.addHandler => @downloadingEventRaised = true
		@file.on.downloaded.addHandler => @downloadedEventRaised = true; @done()
		@file.download()

	then:
		downloadingEventRaised: should.be true
		downloadedEventRaised: should.be true

	dispose: ->
		@restorejQuery()
}
