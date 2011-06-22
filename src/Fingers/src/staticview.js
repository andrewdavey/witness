/*
	editview.js

	Instance of an edit view

*/

	fingers.addStaticMethods({
		
		staticView : base.createChild('staticView')

	});

	fingers.staticView.addStaticMethods({
		
		uid : 0
		
	});

	fingers.staticView.addInstanceMethods({

	    init: function (uid) {

	        this.uid = uid;

	        // detect select, get the string version instead of teh raw value

	        var value = fingers.formData.value(this.uid);
	        if (value === '') {
	            value = 'Click to edit';
	        }

	        fingers.formData.element(this.uid).after(this.element);

	        this.registerSubscriptions();

	        return this;
	    },

	    registerSubscriptions: function () {

	        // subscribe to outputs from editview
	        fingers.broker
				.subscribe('event editing begins', this, "hide")
				.subscribe('event editing complete', this, "show");


	        return this;

	    },

	    hide: function (msg) {

	        if (this.isMyMessage(msg)) {

	            this.element.hide();
	            return this;

	        } else {

	            return this;

	        }

	    },

	    show: function (msg) {

	        if (this.isMyMessage(msg)) {

	            var value = fingers.formData.value(this.uid);
	            if (value === '') {
	                value = 'Click to edit';
	            }

	            this.element.html(value);
	            this.element.show();

	            return this;

	        } else {

	            return this;

	        }

	    }

	});