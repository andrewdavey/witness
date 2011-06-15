﻿describe("demo page",
{
    given: loadPage("/demo/index.htm"),
    when: click("#hello"),
    then: {
        "#message": should.haveText("Hello, world!")
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
});