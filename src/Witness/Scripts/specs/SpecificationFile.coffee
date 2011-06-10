describe "SpecificationFile",
{
	given: ->
		manifest =
			name: "test.coffee"
			url: "/specs/test.coffee"
		@restorejQuery = mock jQuery, {
			ajax: (options) ->
				options.success ""
		}
		@file = new Witness.SpecificationFile manifest

	when: async ->
		@file.on.downloading.addHandler => @downloadingEventRaised = true
		@file.on.downloaded.addHandler => @downloadedEventRaised = true; @done()
		@file.download()

	then:
		downloadingEventRaised: should.be true
		downloadedEventRaised: should.be true

	dispose: ->
		@restorejQuery()
}
