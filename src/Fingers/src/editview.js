/*
	editview.js

	Instance of an edit view

*/

	fingers.addStaticMethods({
		
		editView : base.createChild('editView')

	});

	fingers.editView.addInstanceMethods({

	    init: function (editViewType, uid) {

	        this.viewType = editViewType;
	        this.uid = uid;

	        if (fingers.middleware[this.viewType]) {

	            this.view = fingers.middleware[this.viewType](this.uid);

	        } else {

	            this.view = fingers.middleware.singleText(this.uid);

	        }

	        this.registerSubscriptions();

	        return this;

	    },

	    registerSubscriptions: function () {

	        // subscribe to outputs from front controller
	        fingers.broker
				.subscribe('request edit data', this, "requestEditData");

	        // subscribe to outputs from middleware
	        fingers.broker
				.subscribe('request update data', this, "requestUpdateData")
				.subscribe('request cancel update', this, "requestCancelUpdate");

	        return this;

	    },

	    requestEditData: function (msg) {


	        if (this.isMyMessage(msg)) {

	            fingers.broker.publish('event editing begins', fingers.util.message(this.uid, null));

	            // Here is where the UI component is activated via the Middleware.
	            this.view.beginEdit();

	            return this;

	        } else {

	            return this;

	        }

	    },

	    requestCancelUpdate: function (msg) {

	        // instruction from middleware that editing has been cancelled

	        if (this.isMyMessage(msg)) {

	            fingers.broker.publish('event editing complete', fingers.util.message(this.uid, null));

	            return this;

	        } else {

	            return this;

	        }

	    },

	    requestUpdateData: function (msg) {

	        var that = this;
	        // instruction from middleware that editing has completed, value changed

	        if (this.isMyMessage(msg)) {

	            fingers.formData.value(this.uid, msg.value);

	            fingers.broker.publish('event data updated', fingers.util.message(this.uid, null));

	            fingers.broker.publish('event editing complete', fingers.util.message(this.uid, null));

	            return this;

	        } else {

	            return this;

	        }

	    }

	});