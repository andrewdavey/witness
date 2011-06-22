/*
	select-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        select: fingers.middleware.createChild('select-middleware')

    });

    fingers.middleware.select.addInstanceMethods({

        // This needs a custom showStaticView which pulls out the inner text of the option tag, rather than the internal value. 

        showStaticView: function () {

            var value = fingers.formData.value(this.uid);

            if (value === '') {
                value = 'Click to edit';
            } else {
                value = fingers.formData.element(this.uid).find(':selected').html();
            }

            this.staticView.html(value).show();

            return this;

        },

        createEditView: function () {

            var options = fingers.formData.element(this.uid)
                .find('option');
            this.editView = $('<select class="edit-view-control select"></select>');

            this.editView.append(options.clone());

            return this;

        }

    });

})(fingers);
