describe "SpecificationDirectory constructor",
{
	"given a directory manifest with no files or sub-directories": ->
		@manifest =
			name: "example"
			files: []
			directories: []

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new witness.SpecificationDirectory @manifest

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
				{ name: "file.js", url: "example/file.js", path: "file.js" }
			],
			directories: []

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new witness.SpecificationDirectory @manifest

	"then a SpecificationFile is created":
		directory:
			files: arrayShouldBe [
				should.beInstanceof witness.SpecificationFile
			]
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
		@directory = new witness.SpecificationDirectory @manifest
	
	"then a sub SpecificationDirectory is created":
		directory:
			directories: arrayShouldBe [
				should.beInstanceof witness.SpecificationDirectory
			]
},
{
	"given a directory manifest with helpers": ->
		@manifest =
			helpers: [
				{ url: "/example/_helper1.js", path: "_helper1.js" }
				{ url: "/example/_helper2.js", path: "_helper2.js" }
			]

	"when a SpecificationDirectory is created with the manifest": ->
		@directory = new witness.SpecificationDirectory @manifest
	
	"then helpers property is array of SpecificationHelpers":
		directory: helpers: arrayShouldBe [
			should.beInstanceof witness.SpecificationHelper
			should.beInstanceof witness.SpecificationHelper
		]
}

describe "SpecificationDirectory download",
{
	"given a SpecificationDirectory": ->
		@directory = new witness.SpecificationDirectory {
			name: "example"
			files: []
			directories: []
		}

	"when it is downloaded": async ->
		@directory.on.downloading.addHandler =>
			@downloadingEventRaised = true
		@directory.on.downloaded.addHandler =>
			@downloadedEventRaised = true
			@done()
		@directory.download()

	then:
		downloadingEventRaised: should.be true
		downloadedEventRaised: should.be true
},
{
	"given a SpecificationDirectory with a file": ->
		@directory = new witness.SpecificationDirectory {
			name: "example"
			files: [
				{ name: "test.js", url: "example/test.js", path: "test.js" }
			],
			directories: []
		}
		@directory.on.downloaded.addHandler =>
			@downloadedEventRaised = true
			@done()
		# Mock the file download so we can verify that it happened.
		@directory.files[0].download = =>
			@fileDownloaded = true
			@directory.files[0].on.downloaded.raise()

	"when it is downloaded": async ->
		@directory.download()

	"then the file is downloaded":
		fileDownloaded: should.be true
		downloadedEventRaised: should.be true
},
{
	"given a SpecificationDirectory with a sub-directory": ->
		@directory = new witness.SpecificationDirectory {
			name: "example"
			files: [],
			directories: [
				{ name: "sub", files: [], directories: [] }
			]
		}
		@directory.on.downloaded.addHandler =>
			@downloadedEventRaised = true
			@done()
		# Mock the sub-directory download so we can verify that it happened.
		@directory.directories[0].download = =>
			@subDirectoryDownloaded = true
			@directory.directories[0].on.downloaded.raise()

	"when it is downloaded": async ->
		@directory.download()

	"then the sub-directory is downloaded":
		subDirectoryDownloaded: should.be true
		downloadedEventRaised: should.be true
},
{
	"given a SpecificationDirectory with helper and file": ->
		@directory = new witness.SpecificationDirectory {
			name: "example",
			files: [
				{ url: "file.js", path: "file.js" }
			]
			helpers: [
				{ url: "_helper.js", path: "_helper.js" }
			]
		}
		# Mock the file and helper download
		helper = @directory.helpers[0]
		file = @directory.files[0]
		time = 0
		helper.download = =>
			# Add a short delay to simulate async downloading
			# where the file could get ahead of the helper.
			setTimeout (=>
				@helperDownloadedAt = ++time
				helper.on.downloaded.raise()
			), 100
		file.download = =>
			@fileDownloadedAt = ++time
			file.on.downloaded.raise()
		@directory.on.downloaded.addHandler => @done()

	"when it is downloaded": async ->
		@directory.download()

	"then the helper was downloaded before the file":
		helperDownloadedAt: should.be 1
		fileDownloadedAt: should.be 2
}
