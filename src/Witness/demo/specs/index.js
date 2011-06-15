describe("demo page", {
    "given": loadPage("/demo/index.htm"),
    when: click("#btn"),
    "then": {
        "#message": should.haveText("Hello, world!")
    }
});
