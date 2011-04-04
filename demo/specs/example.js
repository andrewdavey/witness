defineAssertions([
    function messageShouldBeDisplayed(message) {
        return $$("#message").text() == message;
    }
]);

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
