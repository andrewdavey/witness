defineSteps([

    async(function wait(delayInMilliseconds) {
        setTimeout(this.done, delayInMilliseconds)
    }),

    function input(obj) {
        for (var selector in obj) {
            if (obj.hasOwnProperty(selector)) {
                jQuery(selector, this.document).val(obj[selector]);
            }
        }
    },

    function click(selector) {
        jQuery(selector, this.document).click();
    },

    async(function loadPage(url) {
        // alter jQuery to target context.document
        var originaljQuery = window.jQuery;

        if (!this.iframe) {
            var iframe = this.iframe = createIFrame();
            this.cleanUps.push(function () {
                window.$ = window.jQuery = originaljQuery;
                document.body.removeChild(iframe);
            });
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
    })
]);