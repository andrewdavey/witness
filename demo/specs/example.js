defineAssertions({
    messageShouldBeDisplayed: function (message) {
        return $$("#message").text() == message;
    }
});

describe("Say Hello Page", [
    given(
        loadPage("/witness/demo/app.htm")
    ).
    when(
        input({ "#name": "John" }),
        click("#hello")
    ).
    then(
        messageShouldBeDisplayed("Hello, John")
    ),

    given(
        loadPage("/witness/demo/app.htm")
    ).
    when(
        input({ "#name": "" }),
        click("#hello")
    ).
    then(
        messageShouldBeDisplayed("Enter your name.")
    )
]);

describe("Loading a page that does not exist", [
    given(loadPage("/witness/demo/unknown.htm")).
    then(
        function theResourceCannotBeFound() {
            return this.document.title === "The resource cannot be found."
        }
    )
]);
