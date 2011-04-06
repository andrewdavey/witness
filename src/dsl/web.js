Witness.dsl.addInitializer(function (target) {

    // Probably need to make this public so users of Witness can add their own jQuery extensions.
    function jQueryAssertions(selector) {
        this.selector = selector;
    };
    jQueryAssertions.prototype.textShouldBe = function (text) {
        var selector = this.selector;
        var status = ko.observable("pending");
        // Create an Assertion-like step object 
        return {
            status: status,
            description: "Text of " + selector + " should be '" + text + "'",
            run: function (context, done, fail) {
                var actual = jQuery(selector, context.document).text();
                if (actual === text) {
                    status("passed");
                    done();
                } else {
                    status("failed");
                    fail("Expected '" + text + "' but found '" + actual + "'");
                }
            },
            reset: function () { }
        };
    };
    target.$ = function (selector) {
        return new jQueryAssertions(selector);
    };

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

            context.manualLoad = true;
            if (!context.iframeLoadEventBound) {
                context.iframeLoadEventBound = true;
                jQuery(iframe).bind("load", function () {
                    jQuery(iframe).contents().ready(function () {
                        console.log("Loaded page " + iframe.contentWindow.document.title);
                        context.$ = function (selector) { return jQuery(selector, context.document); };

                        context.document = iframe.contentWindow.document;
                        context.window = iframe.contentWindow;
                        if (context.manualLoad) {
                            context.manualLoad = false;
                            context.done();
                        } else if (context.waitingForPageLoad) {
                            var callback = context.waitingForPageLoad;
                            context.waitingForPageLoad = null;
                            callback();
                        } else {
                            context.loadedPage = true;
                        }
                    });
                });
            }

            iframe.src = url;
        }),

        waitForPageLoad: async(function () {
            if (this.loadedPage) {
                this.loadedPage = false;
                this.done();
            } else {
                this.waitingForPageLoad = this.done;
            }
        })

    });

});