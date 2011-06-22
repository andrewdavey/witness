/*
	multiselect-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        multiSelect: fingers.middleware.createChild('multiselect-middleware')

    });

    fingers.middleware.multiSelect.addInstanceMethods({

        // This needs a custom showStaticView which pulls out the inner text of the option tag, rather than the internal value. 

        showStaticView: function () {
            console.log('creating multi select static view');

            var value = fingers.formData.value(this.uid);

            if (!value) {
                value = 'Click to edit';
            } else {
                value = '';
                var eles = fingers.formData.element(this.uid).find(':selected');
                eles.each(function () {
                    value += $(this).html() + ', ';
                });
                value = value.slice(0, -2);
            }

            this.staticView.html(value).show();

            return this;

        },

        createEditView: function () {

            console.log('creating multi select edit view');

            var options = fingers.formData.element(this.uid)
                .find('option');

            this.editView = $('<select class="edit-view-control multi-select" size="8" multiple="multiple"></select>');

            this.editView.append(options.clone());

            return this;

        },

        persistChange: function () {

            // get the current value from the input field
            // pass to okay
            var value = this.editView.val();
            if (value && value.length > 5) {
                console.log('static view too many selected');
            }
            else {
                this.okay(value);
            }

            return this;

        }

    });

})(fingers);