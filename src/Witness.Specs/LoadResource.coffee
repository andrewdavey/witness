describe "loadResource",
{
	"when loading a simple html resource": ->
		@response = loadResource
			url: "htmltemplates/runner/error-message.htm"
			dataType: "html"
	
	"then it should return ok":
		response:
			status_code: should.be 200
			errored: should.be false
}
