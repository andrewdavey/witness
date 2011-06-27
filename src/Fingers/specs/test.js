/*jslint sloppy: true */

describe("fingers suite", {
    "given a page containing a single text component":
        loadPage('/fingers/test.html'),

    "when a static view is clicked":
        click('div.static-view.field:eq(0)'),

    "then an edit view should appear": {
        'div.static-view.field:eq(0)': shouldnot.beVisible(),
        'input.edit-view-control.single-text': should.haveLength(1)
    }
}, {
    "given a page with an active edit view component": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(0)').click()
	],
    "when the edit view is blurred": [
        $('input.edit-view-control.single-text:eq(0)').blur()
	],
    "then the static view should reappear": {
        'div.static-view.field:eq(0)': should.beVisible()
    }
}, {
    "given a page with an active edit view component and text entered": [
		loadPage('/fingers/test.html'),
		$('div.static-view.field:eq(0)').click(),
        $('input.edit-view-control.single-text:eq(0)').val("TEST")
	],
    "when the edit view is blurred": [
        blur('input.edit-view-control.single-text:eq(0)')
	],
    "then the static view should show the entered text": {
        'div.static-view.field:eq(0)': should.haveText("TEST")
    }
});

describe("Low level JS test", {

    given: [
		loadPage('/fingers/lowlevel.html'),
		function () {
		    this.fingersInstance = this.window.fingers.controller();
		} ],
    then: {
        fingersInstance: {
            length: should.be(12)
        }
    }

});



/*

WOULD LIKE! :

// so value of form element = "foo"
loadPage('/test.html'),
click('.blah.thingy:eq(0)'),
type(["bar", keys.esc]),
// value should still be "foo", not "bar"

*/



