/// <reference path="Witness.js" />
/// <reference path="Witness.util.js" />

Witness.defineAsyncStep(function wait(delayInMilliseconds) {
    setTimeout(this.done, delayInMilliseconds)
});

Witness.defineStep(function click(selector) {
    $(selector).click();
});

Witness.defineStep(/click (.*)/, function click(selector) {
    $(selector).click();
});
