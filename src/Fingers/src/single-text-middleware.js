/*
	singletext-middleware.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		singleText : fingers.middleware.createChild('singletext-middleware')

	});

	fingers.middleware.singleText.addInstanceMethods({

		// single text is the default behaviour so no custom methods necessary

	});

})(fingers);
