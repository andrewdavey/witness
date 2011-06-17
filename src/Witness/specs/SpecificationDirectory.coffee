describe "SpecificationDirectory",
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
}
