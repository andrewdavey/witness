Witness.dsl.addInitializer(function () {

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
            if (!this.iframe) {
                var iframe = this.iframe = createIFrame();
                this.cleanUps.push(function () {
                    document.getElementById("output").removeChild(iframe);
                });
            }

            var context = this;
            jQuery(context.iframe).one("load", function () {
                jQuery(context.iframe).contents().ready(function () {
                    window.$$ = function (selector) { return jQuery(selector, context.document); };

                    context.document = context.iframe.contentWindow.document;
                    context.window = context.iframe.contentWindow;
                    context.done();
                });
            });
            context.iframe.src = url;

            function createIFrame() {
                var iframe = document.createElement("iframe");
                document.getElementById("output").appendChild(iframe);
                return iframe;
            }
        })

    ]);

});