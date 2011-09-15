describe "loadResource",
{
	"when loading a simple html resource": loadResource
		url: "htmltemplates/runner/error-message.htm"
		data_type: "html"

	"then it should return ok":
		response:
			status_code: should.be 200
			errored: should.be false
}


