defineAssertions({
    messageShouldBeDisplayed: function (message) {
        return this.$("#message").text() === message;
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
        $("#message").textShouldBe("Hello, John")
    ),

    given(
        loadPage("/witness/demo/app.htm")
    ).
    when(
        input({ "#name": "" }),
        click("#hello")
    ).
    then(
        $("#message").textShouldBe("Enter your name.")
    )
]);

describe("Loading a page that does not exist", [
    given(loadPage("/witness/demo/unknown.htm")).
    then(
        function theResourceCannotBeFound() {
            return this.document.title === "The resource cannot be found.";
        }
    )
]);

defineSteps({
    emptyDatabase: function () {
        console.log("Creating empty database.");
    }
});

describe("Something complex", [

    given(emptyDatabase(), [

        given(function aCustomer() { this.customer = {}; }).
        when(function setTest() { this.customer.test = 1; }).
        then(function testIsSet() { return this.customer.test === 1; }),

        given(function aCustomer() { this.customer = {}; }).
        when(function setFoo() { this.customer.foo = 1; }).
        then(function fooIsSet() { return this.customer.foo === 1; })

    ])

]);