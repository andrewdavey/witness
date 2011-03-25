
defineAssertions([
    function messageShouldBeDisplayed(message) {
        return $("#message").text() == message;
    }
]);

describe("Say Hello Page", {
    "Click hello to John Smith":
        given(
            loadPage("app.htm")
        ).
        when(
            input({ "#name": "John" }),
            click("#hello")
        ).
        then(
            messageShouldBeDisplayed("Hello, John")
        ),

    "Click hello with a missing name":
        given(
            loadPage("app.htm")
        ).
        when(
            input({ "#name": "" }),
            click("#hello")
        ).
        then(
            messageShouldBeDisplayed("Enter your name.")
        )
});
