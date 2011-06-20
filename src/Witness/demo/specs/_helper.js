/*jslint sloppy: true */
/*global $ */

defineActions({

    clickButtonNumber: function (number) {
        $("button.number:eq(" + (number-1).toString() + ")", this.document).click();
    }

});
