/*jslint sloppy: true */
/*global jQuery */

dsl.extendShould({

    beVisible: {
        getActual: function (propertyNames) {
            return jQuery(propertyNames[0], this.document);
        },
        test: function (actual) {
            return actual.is(":visible");
        },
        description: function (selector) {
            return selector + " should be visible";
        },
        error: function (selector, actual) {
            return selector + " is not visible";
        }
    }

});
