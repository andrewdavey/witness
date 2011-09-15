describe "loadResource",
{
	"when loading a simple html resource": loadResource
		url: "/htmltemplates/runner/error-message.htm"
		dataType: "html"
	"then it should return ok":
		status_code: should.be 200
		errored: should.be false
		response:
			li.error: should.be '${ message } <br/> ${ stack }'
}
,{
	"when parsing good json": loadResource
		url: "/htmltemplates/good-json.json"
		dataType: "json"
	"then it should return ok":
		status_code: should.be 200
		errored: should.be false
		response:
			name: should.be 'hello'
}
,{
	"when parsing bad json": loadResource
		url: "/htmltemplates/bad-json.json"
		dataType: "json"
	"then it should fail to parse":
		status_code: should.be 200
		errored: should.be true
}
,{
	"when no data type but accepts set": loadResource
		url: '/htmltemplates/runner/error-message.htm'
		accepts: 'application/atom+xml'
	"then it should do something unexpected":
		status_code: should.be 200
		errored: should.be false
}
,{
	"when no data type or accepts set": loadResource
		url: '/htmltemplates/runner/error-message.htm'
	"then it should do something unexpected":
		status_code: should.be 200
		errored: should.be false
}
,{
	"when no data type but accepts set": loadResource
		url: '/htmltemplates/runner/error-message.htm'
		accepts: 'text/html'
		dataType: 'html'
	"then it should do something unexpected":
		status_code: should.be 200
		errored: should.be false
}

