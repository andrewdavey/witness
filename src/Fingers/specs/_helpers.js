/*jslint sloppy: true */

should.beVisible = predicateActionBuilder({
    getActual: function (context, propertyNames) {
        return jQuery(propertyNames[0], context.document);
    },
    test: function (actual) {
        return actual.is(':visible');
    },
    description: function (selector) {
        return selector + " should be visible";
    },
    error: function (selector, actual) {
        return selector + " is not visible";
    }
});
shouldnot.beVisible = predicateActionBuilder({
    getActual: function (context, propertyNames) {
        return jQuery(propertyNames[0], context.document);
    },
    test: function (actual) {
        return !actual.is(':visible');
    },
    description: function (selector) {
        return selector + " should not be visible";
    },
    error: function (selector, actual) {
        return selector + " is visible";
    }
});