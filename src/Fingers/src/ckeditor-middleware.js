/*
	ckEditor.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		ckEditor : fingers.middleware.createChild('middleware')

	});

	fingers.middleware.ckEditor.addInstanceMethods({

	    createEditView: function () {

	        this.editView = $('<textarea type="text" class="edit-view-control ckeditor" ></textarea>');

	        return this;

	    },

	    beginEdit: function () {

	        // do something
	        var that = this;

	        if (fingers.formData.element(this.uid)) {

	            this.hideStaticView();

	            fingers.formData.element(this.uid).after(this.editView);
	            this.editView.val(fingers.formData.value(this.uid));


	            this.editView.ckeditor({ skin: 'kama',
	                toolbar: 'Basic'
	            });

	            this.ckEdit = this.editView.ckeditorGet();

	            setTimeout(function () {

	                $(document)
						.bind('click', { that: that }, that.checkForClick);

	            }, 250);

	        }

	        return this;

	    },

	    endEdit: function () {

	        $(document).unbind('click', this.checkForClick);

	        this.ckEdit.destroy();

	        this.hideEditView();

	        this.showStaticView();
	        // do somethign else

	        return this;

	    },

	    checkForClick: function (event) {

	        var that = event.data.that;

	        if (!$(event.target).is('#cke_editor1')) {

	            that.persistChange();

	        }

	        return this;

	    }


	});

})(fingers);