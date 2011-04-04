/// <reference path="lib/knockout-1.1.2.js" />

ko.bindingHandlers.scrollIntoView = {

    update: function (element, valueAccessor) {
        var value = ko.utils.unwrapObservable(valueAccessor());
        if (value) {
            element.scrollIntoView(false);
        }
    }

};