/*
	
	message.js

*/

	fingers.util.addStaticMethods({
		
		message : base.createChild('message')

	});

	fingers.util.message.addInstanceMethods({

	    init: function (recipientId, value) {

	        this.recipientId = recipientId;
	        this.value = value;
	        return this;

	    }

	});
