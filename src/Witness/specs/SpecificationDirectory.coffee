describe "SpecificationDirectory constructor",
{
	"given a directory manifest with no files or sub-directories": ->
		@manifest =
			name: "example"
			files: []
			directories: []

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new Witness.SpecificationDirectory @manifest

	then:
		directory:
			name: should.be "example"
			files:
				length: should.be 0
			directories:
				length: should.be 0
},
{
	"given a directory manifest with a file": ->
		@manifest = 
			name: "example"
			files: [
				{ name: "file.js", url: "example/file.js" }
			],
			directories: []

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new Witness.SpecificationDirectory @manifest

	"then a SpecificationFile is created":
		directory:
			files: [ should.beInstanceof Witness.SpecificationFile ]
},
{
	"given a directory manifest with a sub-directory": ->
		@manifest =
			name: "example"
			files: []
			directories: [
				{ name: "sub", files:[], directories: []}
			]
	
	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new Witness.SpecificationDirectory @manifest
	
	"then a sub SpecificationDirectory is created":
		directory:
			directories: [ should.beInstanceof Witness.SpecificationDirectory ]
},
{
	"given a directory manifest with helpers": ->
		@manifest =
			helpers: [ "/example/_helper1.js", "/example/_helper2.js" ]

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new Witness.SpecificationDirectory @manifest
	
	"then helpers property is array of SpecificationHelpers":
		directory: helpers: [
			should.beInstanceof Witness.SpecificationHelper
			should.beInstanceof Witness.SpecificationHelper
		]
}

describe "SpecificationDirectory download",
{
	"given a SpecificationDirectory": ->
		@directory = new Witness.SpecificationDirectory {
			name: "example"
			files: []
			directories: []
		}
		@directory.on.downloading.addHandler => @downloadingEventRaised = true
		@directory.on.downloaded.addHandler => @downloadedEventRaised = true

	"when it is downloaded": ->
		@directory.download()

	then:
		downloadingEventRaised: should.be true
		downloadedEventRaised: should.be true
},
{
	"given a SpecificationDirectory with a file": ->
		@directory = new Witness.SpecificationDirectory {
			name: "example"
			files: [
				{ name: "test.js", url: "example/test.js" }
			],
			directories: []
		}
		@directory.on.downloaded.addHandler => @downloadedEventRaised = true
		# Mock the file download so we can verify that it happened.
		@directory.files[0].download = (done) => @fileDownloaded = true; done()

	"when it is downloaded": ->
		@directory.download()

	"then the file is downloaded":
		fileDownloaded: should.be true
		downloadedEventRaised: should.be true
},
{
	"given a SpecificationDirectory with a sub-directory": ->
		@directory = new Witness.SpecificationDirectory {
			name: "example"
			files: [],
			directories: [
				{ name: "sub", files: [], directories: [] }
			]
		}
		@directory.on.downloaded.addHandler => @downloadedEventRaised = true
		# Mock the sub-directory download so we can verify that it happened.
		@directory.directories[0].download = (done) => @subDirectoryDownloaded = true; done()

	"when it is downloaded": ->
		@directory.download()

	"then the sub-directory is downloaded":
		subDirectoryDownloaded: should.be true
		downloadedEventRaised: should.be true
}
