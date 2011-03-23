/// <reference path="Witness.js" />
/// <reference path="Witness.util.js" />

Witness.defineAsyncStep(function wait(delayInMilliseconds) {
    setTimeout(this.done, delayInMilliseconds)
});

Witness.defineStep(function click(selector) {
    jQuery(selector, this.document).click();
});

Witness.defineStep(function input(obj) {
    for (var selector in obj) {
        if (obj.hasOwnProperty(selector)) {
            jQuery(selector, this.document).val(obj[selector]);
        }
    }
});

Witness.defineAsyncStep(function loadPage(url) {
    // alter jQuery to target context.document
    var originaljQuery = window.jQuery;

    if (!this.iframe) {
        this.iframe = createIFrame();
        this.cleanUps.push(function () {
            document.body.removeChild(this.iframe);
            window.$ = window.jQuery = originaljQuery;
        } .bind(this));
    }

    var context = this;
    jQuery(context.iframe).one("load", function () {
        jQuery(context.iframe).contents().ready(function () {

            window.$ = window.jQuery = function (selector) { return originaljQuery(selector, context.document); };

            context.document = context.iframe.contentWindow.document;
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