describe "Low level JS test",
{
	given: [
		loadPage('lowlevel.html'),
		->
			this.fingersInstance = this.window.fingers.controller();
	],
	then:
		fingersInstance: length: should.be(12)
}
