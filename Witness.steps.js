/// <reference path="Witness.js" />
/// <reference path="Witness.util.js" />

Witness.defineAsyncStep("wait", function (delayInMilliseconds) {
    setTimeout(this.done, delayInMilliseconds)
});

Witness.defineStep("click", function click(selector) {
    $(selector).click();
});

Witness.defineStep(/click (.*)/, function click(selector) {
    $(selector).click();
});
