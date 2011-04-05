Witness.dsl.addInitializer(function () {

    defineSteps({

        input: function (obj) {
            for (var selector in obj) {
                if (obj.hasOwnProperty(selector)) {
                    jQuery(selector, this.document).val(obj[selector]);
                }
            }
        },

        click: function (selector) {
            jQuery(selector, this.document).click();
        },

        wait: async(function (delayInMilliseconds) {
            setTimeout(this.done, delayInMilliseconds)
        }),

        loadPage: async(function (url) {
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

    });

});