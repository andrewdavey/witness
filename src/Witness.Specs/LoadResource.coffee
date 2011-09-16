describe "loadResource",
{
	"when loading a simple html resource": loadResource
		url: "/htmltemplates/runner/directory-node.htm"
		dataType: "html"
	"then it should return ok":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'text/html'
		'div.header': should.haveLength 1
		xhr: should.haveHeader {key:'content-type',value:'text/html'}
			
}
,{
	"when parsing good json": loadResource
		url: "/htmltemplates/good-json.json"
		dataType: "json"
	"then it should return ok":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'application/json'
		document:
			name: should.be 'hello'
}
,{
	"when parsing bad json": loadResource
		url: "/htmltemplates/bad-json.json"
		dataType: "json"
	"then it should fail to parse":
		status_code: should.be 200
		errored: should.be true
		content_type: should.be 'application/json'
}
,{
	"when no data type but accepts set": loadResource
		url: '/htmltemplates/runner/directory-node.htm'
		accepts: 'application/atom+xml'
	"then it should parse the html response":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'text/html'
		'div.header': should.haveLength 1
}
,{
	"when no data type or accepts set": loadResource
		url: '/htmltemplates/runner/directory-node.htm'
	"then it should parse the html response":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'text/html'
		'div.header': should.haveLength 1
}
,{
	"when data type and accepts set": loadResource
		url: '/htmltemplates/runner/directory-node.htm'
		accepts: 'text/html'
		dataType: 'html'
	"then it should parse the html response":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'text/html'
		'div.header': should.haveLength 1
}
,{
	"when parsing good xml": loadResource
		url: '/htmltemplates/good-xml.xml'
		dataType: 'xml'
	"then it should parse the xml":
		status_code: should.be 200
		errored: should.be false
		content_type: should.be 'text/xml'
		document: should.haveRoot 'xmlRoot'
		document: should.haveElement 'xmlChild'
		document: should.haveMoreThanOneElement 'anotherChild subChild'
}
