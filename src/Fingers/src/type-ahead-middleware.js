/*
typeahead-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        typeAhead: fingers.middleware.createChild('typeahead-middleware')

    });

    fingers.middleware.typeAhead.addInstanceMethods({

        createEditView: function () {

            // not sure I like this. You're creating a dependency in the form. 
            
            //this.editView = fingers.formData.element(this.uid).clone();

            this.editView = $('<input type="text" class="edit-view-control type-ahead" />');

            return this;

        },

        beginEdit: function () {

            // do something
            var that = this;

            if (fingers.formData.element(this.uid)) {

                this.hideStaticView();

                fingers.formData.element(this.uid).after(this.editView);

                var lookupUrl = fingers.formData.element(this.uid).attr("data-lookupUrl");

                this.editView
					.val(fingers.formData.value(this.uid))
					.bind('blur', function () {
					    that.blurTimeout = setTimeout(function () {
					        that.cancel();
					    }, 250);
					})
					.bind('keydown', function (e) {
					    if (e.which === 27) {
					        that.cancel();
					    }
					})
					.focus()
                    .autocomplete({
                        source: ["c++", "java", "php", "coldfusion", "javascript", "asp", "ruby"],
                        //function (req, add) {
                        //    $.getJSON(lookupUrl + "/" + arms.cleanSearchText(req.term), function (data) {
                        //        add(data);
                        //    });
                        //},
                        select: function (event, ui) {
                            that.editView.val(ui.item.value);
                            that.persistChange();
                        },
                        minLength: 2
                    });

            }

            return this;

        }

    });

})(fingers);
