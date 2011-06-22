/********************************************************************
*
* Filename:		application.js
* Description:	creating the application wide namespace ("fingers") and a util
*				object for hooking /most/ of the helper objects to.
*	
********************************************************************/

	var fingers = base.createChild('fingers');
	
	fingers.addStaticMethods({
	
		util : base.createChild('util')
		
	
	});
	
	fingers.addInstanceMethods({
	
	});

	String.prototype.toCamelCase = function () {
	    return this.replace(/\s[a-z0-9]/g, function (str, n) { return str.toUpperCase(); });
	};
	
	window.fingers = fingers;

	
	

	