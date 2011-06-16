/*jslint sloppy: true */
/*global clickButtonNumber, $ */
defineActions({
    clickButtonNumber: function (number) {
        $("button.number:eq(" + (number-1).toString() + ")", this.document).click();
    }
});

describe("demo page",
{
    given: loadPage("/demo/index.htm"),
    when: [
        input({ "#name": "John" }),
        click("#hello")
    ],
    then: {
        "#message": should.haveText("Hello, John")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: clickButtonNumber(1),
    then: {
        "#message": should.haveText("Number is 1")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: clickButtonNumber(2),
    then: {
        "#message": should.haveText("Number is 2")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: clickButtonNumber(3),
    then: {
        "#message": should.haveText("Number is 3")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: [
        click("a[href^=second]"),
        awaitPageLoad()
    ],
    then: {
        document: { title: should.be("Second Page") }
    }
});
