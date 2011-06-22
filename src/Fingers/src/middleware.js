/*
	middleware.js
*/

	fingers.addStaticMethods({
		
		middleware : base.createChild('middleware')

	});

	fingers.middleware.addInstanceMethods({

	    init: function (uid) {

	        var that = this, value;

	        this.uid = uid;

	        this.createStaticView();
	        this.createEditView();

	        return this;

	    },

	    createStaticView: function () {

	        var that = this;

	        this.staticView = $('<div class="static-view field"></div>');

	        fingers.formData.element(this.uid).after(this.staticView);

	        this.staticView.bind('click', function (e) {

	            e.preventDefault();
	            fingers.broker.publish('request edit data', fingers.util.message(that.uid, null));

	        });

	        this.showStaticView();

	        return this;

	    },

	    createEditView: function () {

	        this.editView = $('<input type="text" class="edit-view-control single-text" />');

	        return this;

	    },

	    /* generally speaking these should never need to be touched */

	    showStaticView: function () {

	        var value = fingers.formData.value(this.uid);

	        if (value === '') {
	            value = 'Click to edit';
	        }

	        this.staticView.html(value).show();

	        return this;

	    },

	    hideStaticView: function () {

	        this.staticView.hide();

	        return this;

	    },

	    showEditView: function () {

	        fingers.formData.element(this.uid).after(this.editView);
	        this.editView.val(fingers.formData.value(this.uid));

	        return this;

	    },

	    hideEditView: function () {

	        this.editView.remove();

	        return this;

	    },

	    persistChange: function () {

	        // get the current value from the input field
	        // pass to okay

	        this.okay(this.editView.val());

	        return this;

	    },

	    beginEdit: function () {

	        // do something
	        var that = this;

	        if (fingers.formData.element(this.uid)) {

	            this.hideStaticView();
	            this.showEditView();

	            this.editView
					.bind('blur', function () {
					    that.persistChange();
					})
					.bind('keydown', function (e) {
					    if (e.which === 13) {
					        that.persistChange();
					    }
					    if (e.which === 27) {
					        that.cancel();
					    }
					})
					.focus();


	        }

	        return this;

	    },

	    endEdit: function () {

	        this.hideEditView();
	        this.showStaticView();
	        // do somethign else

	        return this;

	    },

	    okay: function (value) {

	        fingers.broker.publish('request update data', fingers.util.message(this.uid, value));

	        this.endEdit();

	        return this;

	    },

	    cancel: function () {

	        fingers.broker.publish('request cancel update', fingers.util.message(this.uid, null));

	        this.endEdit();

	        return this;

	    }


	});
