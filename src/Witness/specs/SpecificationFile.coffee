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
},
{
	"given a SpecificationFile that is a file manifest of a file with a syntax error": ->
		manifest =
			name: "test.coffee"
			url: "/specs/test.coffee"
		@restorejQuery = mock jQuery, {
			ajax: (options) -> options.success " { "
		}
		@file = new Witness.SpecificationFile manifest

	"when the file is downloaded": async ->
		@file.on.downloaded.addHandler => @done()
		@file.download()

	then:
		file: errors: length: should.be 1
}
