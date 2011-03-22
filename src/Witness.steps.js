/// <reference path="Witness.js" />
/// <reference path="Witness.util.js" />

Witness.defineAsyncStep(function wait(delayInMilliseconds) {
    setTimeout(this.done, delayInMilliseconds)
});

Witness.defineStep(function click(selector) {
    $(selector).click();
});

Witness.defineAsyncStep(function loadPage(url) {
    if (!this.iframe) {
        this.iframe = createIFrame();
        this.cleanUps.push(function () { document.body.removeChild(this.iframe); }.bind(this));
    }

    var context = this;
    $(context.iframe).one("load", function () {
        $(context.iframe).contents().ready(function () {
            context.document = this;
            context.window = context.iframe.contentWindow;
            context.done();
        });
    });
    context.iframe.src = url;

    function createIFrame() {
        var iframe = document.createElement("iframe");
        document.body.appendChild(iframe);
        return iframe;
    }
});