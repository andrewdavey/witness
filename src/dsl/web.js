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
            var context = this,
                iframe = this.getIFrame();
            jQuery(iframe).one("load", function () {
                jQuery(iframe).contents().ready(function () {
                    window.$$ = function (selector) { return jQuery(selector, context.document); };

                    context.document = iframe.contentWindow.document;
                    context.window = iframe.contentWindow;
                    context.done();
                });
            });
            iframe.src = url;
        })

    ]);

});