defineAssertion(function fail(message) {
    throw new Error(message);
});

describe("example 1", {
    "scenario 1": given().when(wait(500)).then(),
    "scenario 2": given().when(wait(500)).then(fail("die die"))
});

describe("example 2", {
    "scenario 1": given().when(wait(500)).then(),
    "scenario 2": given().when(wait(500)).then()
});