describe("demo page",
{
    given: loadPage("/demo/index.htm"),
    when: [
        input({ "#name": "John" }),
        click("#hello")
    ],
    then: {
        "#message": should.haveText("Hello, John!")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: click("button.number:eq(0)"),
    then: {
        "#message": should.haveText("Number is 1")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: click("button.number:eq(1)"),
    then: {
        "#message": should.haveText("Number is 2")
    }
},
{
    given: loadPage("/demo/index.htm"),
    when: click("button.number:eq(2)"),
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
