defineAssertion(function messageShouldBeDisplayed(message) {
    return $("#message").text() == message;
});

describe("example 1", {
    "scenario 1":
        given(
            loadPage("app.htm")
        ).
        when(
            input({ "#name": "John" }),
            click("#hello")
        ).
        then(
            messageShouldBeDisplayed("Hello, John")
        )
});

//describe("example 2", {
//    "scenario 1": given().when(wait(500)).then(),
//    "scenario 2": given().when(wait(500)).then()
//});