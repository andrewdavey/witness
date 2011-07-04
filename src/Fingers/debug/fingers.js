/*
* fingers
*
* Date: Tue Jun 21 13:43:49 2011 +0100
*/

/********************************************************************
*
* Filename:		intro.js
* Description:	wraps everything else, holds notices etc
*	
********************************************************************/

(function (window) {

/********************************************************************
*
* Filename:		config.js
* Description:	A singleton containing default configurations for
*				various helper objects.
*	
********************************************************************/

	fingersConfig = {
	
		base : {
			name : "base"
		},
		
		fingers : {
			name : "fingers"
		},

		controller : {
			
			selector : "editable"

		}
	
	};
	
	/********************************************************************
*
* Filename:		base.js
* Description:	Creates the 'base' class.
*	
********************************************************************/

	var base = function ( args ) {
	
		if ( this instanceof arguments.callee ) {
		
			this._init.apply( this, args.callee ? args : arguments );
			
			return this;
		
		} else { 
		
			return new arguments.callee( arguments );
		
		}
		
	};
	
	$.extend(base, {
	
		addStaticMethods : function addStaticMethods(methods){
			$.extend(this, methods);
		},
		
		addInstanceMethods : function addInstanceMethods(methods){
			$.extend(this.prototype, methods);
		},
		
		createChild : function createChild(){
		
			var child = function ( args ){
				
				if ( this instanceof arguments.callee ) {
		
					this.init.apply( this, args.callee ? args : arguments );
			
					return this;
		
				} else { 
		
					return new arguments.callee( arguments );
		
				}
			};
			
            $.extend(true, child, this);
            var method;
            for(method in this.prototype){
                child.prototype[method] = this.prototype[method];
            }

			return child;
		
		}
	
	});
	
	base.addInstanceMethods({

		_init : function( config ){
			
			this.init( config );

			return this;

		},
	
		init : function( config ){
		
			this.config = fingersConfig.base;
			$.extend(this.config, config);
			
			return this;
			
		},

		isMyMessage : function( msg ){
			
			if(!msg || (msg && msg.recipientId === this.uid)){
				
				return true;

			}else{
				
				return false;

			}

		}
	
	});
	
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

	
	

	/*

	form-data.js

*/

	fingers.util.addStaticMethods({
		
		formData : base.createChild()

	});

	fingers.util.formData.addStaticMethods({
		
		uid : 0

	});

	fingers.util.formData.addInstanceMethods({
		
		init : function(){
			
			this.fields = {};

		},

		registerField : function( element ){

			var newElement, storedValue;

			if(element){

				// wrap with jQuery object if it's not already happened.
				element.selector ? newElement = element : newElement = $(element);
				storedValue = newElement.val();

			}else{
				
				// throw an error
				throw('Invalid DOM element ');

			}
			
			this.fields[ ++fingers.util.formData.uid ] = {
				
					element : newElement,
					storedValue : storedValue

			};

			return fingers.util.formData.uid;

		},

		value : function( uid, val ){
			
			if(typeof uid==='number' && this.fields[uid]){

				if(arguments.length > 1){
					// update the stored value
					this.fields[uid].storedValue = val;

					// actually update the element
					this.fields[uid].element.val( val );

					// publish a message to say that the field value has been changed
					fingers.broker.publish('event field value changed', fingers.util.message( uid, val ) );

				}else {
					
					return this.fields[uid].storedValue;

				}

			}else{
				
				return false;

			}

		},

		element : function( uid ){
			
			if(uid && typeof uid==='number' && this.fields[uid] && this.fields[uid].element){
				
				return this.fields[uid].element;

			}else{
				
				return false;

			}

		}

	});

	fingers.formData = fingers.util.formData();/********************************************************************
*
* Filename:		pub-sub.js
* Description:	
*	
********************************************************************/

// Pub Sub Broker

	fingers.util.addStaticMethods({
	
		broker : base.createChild()

	});
	
	fingers.util.broker.addInstanceMethods({
	
		init : function(){
		
			this.subscribers = {};
			
			var signals = arguments;
			
			this.subscribers = {};
			this.subscribersAsync = {};
			
			return this;
		},
		publish : function(signal){
		
			var handler, i;
		
			if(!this.subscribers[signal]){
			
				this.subscribers[signal] = [];
			}
			
			if(!this.subscribersAsync[signal]){
				
				this.subscribersAsync[signal] = [];
				
			}
		
			var args = Array.prototype.slice.call(arguments, 1);
			
			for (i=0; i < this.subscribersAsync[signal].length; i++) {
			
				handler = this.subscribersAsync[signal][i];
				handler.apply(this, args);
				
			}
			
			for (i=0; i < this.subscribers[signal].length; i++) {
			
				handler = this.subscribers[signal][i];
				handler.apply(this, args);
				
			}
			
			return this;
		},
		subscribe : function(signal, scope, handlerName){
		
			if(!this.subscribers[signal]){
			
				this.subscribers[signal] = [];
				
			}
		
			var curryArray = Array.prototype.slice.call(arguments, 3);
			
			this.subscribers[signal].push(function(){
			
				var normalizedArgs = Array.prototype.slice.call(arguments, 0);
				
				scope[handlerName].apply((scope || window), curryArray.concat(normalizedArgs));
				
			});
			
			return this;
		},
		subscribeAsync : function(signal, scope, handlerName){
		
			if(!this.subscribersAsync[signal]){
			
				this.subscribersAsync[signal] = [];
				
			}
		
			var curryArray = Array.prototype.slice.call(arguments, 3);
			
			this.subscribersAsync[signal].push(function(){
			
				var normalizedArgs = Array.prototype.slice.call(arguments, 0);
			
				var func = function(){
			
						scope[handlerName].apply((scope || window), curryArray.concat(normalizedArgs));
					
				};
				
				setTimeout(function(){
					func(arguments);
				}, 0);
				
			});
			
			return this;
		}
		
		
	
	});

	fingers.addStaticMethods({
	
		broker : fingers.util.broker()
	
	});
	
/*
	controller.js
*/

	fingers.util.controller = base.createChild();

	fingers.util.controller.addInstanceMethods({
		
			init : function(){
			
				var that = this;
				var formElements = $( '.' + fingersConfig.controller.selector );

				this.editViews = [];
				this.staticViews = [];

				this.length = formElements.length;

				formElements.each( function(){
					
					that.invokeView( $(this) );

				});

				return this;
			}, 

			invokeView : function( jq ){
				
					// pull out the edit view type using a bit of magic regex

					var i, matches, view, viewType = '', uid, words;

					// find the view type... view-*

					// because this information is in the class attribute of the form element, we pull out all the classes
					// and find one that begins view-
					var classes = (jq.attr('class')).split(' ');

					classes.forEach(function( element ){
						
						matches = element.match(/^view\-([A-Za-z0-9\-]+)$/);

						if(matches){
							
							view = matches[1];

						}
					
					});

					//format the viewtype into camelCase, the convention for middleware class names.
					viewType = view.replace(/\-/g, ' ').toCamelCase().replace(/\s/g, '');

					// now that we have it, push a new instance of editView into the editViews array.
					// We invoke editView by passing it a string of teh viewType and a databox.


					uid = fingers.formData.registerField( jq );

					this.registerEditView( fingers.editView( viewType, uid ) );

					// hide the form element
					jq.hide();

					return this;

			},

			registerEditView : function( view ){
				
				this.editViews.push( view );

				return this;


			}


	});

	fingers.controller = fingers.util.controller;
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

	});/*
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

	});/*
	
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
/*
	bool-middleware.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		bool : fingers.middleware.createChild('bool-middleware')

	});

	fingers.middleware.bool.addInstanceMethods({

		createEditView : function(){
			
			this.editView = $('<input type="checkbox" class="edit-view-control bool" />');

		},

		persistChange : function( ){
					
				// get the current value from the input field
				// pass to okay

				var isChecked = (this.editView.is(':checked')).toString();

				this.okay(isChecked);

		},

		beginEdit: function(){
			
			// do something

			var that = this;

			if(fingers.formData.element(this.uid)){
				
				this.showEditView();
				this.hideStaticView();


				fingers.formData.value( this.uid ) === 'true' ? this.editView.attr('checked', 'checked') : this.editView.removeAttr('checked');

				//this.element.val(fingers.formData.value( this.uid ));

				this.editView
					.bind('blur', function(){
						that.blurTimeout = setTimeout(function(){
							that.persistChange();
							}, 250);
					})
					.bind('change', function(){
						if(that.blurTimeout!== -1){
							
							clearTimeout(that.blurTimeout);
							that.blurTimeout = -1;

						}
						$(this).focus();

					})
					.bind('keydown', function( e ) {
						if (e.which === 13) {
							that.persistChange( this );
						}
						if (e.which === 27){
							that.cancel();							
						}
					});				
				
				this.editView.focus();
				
			}


		}

	});

})(fingers);/*
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
/*
	multi-text-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        multiText: fingers.middleware.createChild('select-middleware')

    });

    fingers.middleware.multiText.addInstanceMethods({

        

        // This needs a custom showStaticView which pulls out the inner text of the option tag, rather than the internal value. 

        showStaticView : function(){
            // get value out...
            var rawValue = fingers.formData.value(this.uid);

            // then find the inner text of the relevant option....
            // and display that instead, or if it's a vlaue of '' then display click to edit.

            if (rawValue === '') {
                rawValue = 'Click to edit';
            }

            var value = rawValue.replace(/\|/g, ', ');



            this.staticView.html(value).show();

            return this;

        },

		persistChange : function(){
					
			// read in all the values of all the inputs that are children of
			// this.editView, turn into a single string with each value separated by a pipe

			var values = [];

			this.editView.find('input.single-text').each(function(){
				
				var val = $(this).val();

				if(val && val !== ''){
					
					values.push( $(this).val() );

				}

			});

			this.okay( values.toString().replace(/,/g, '|') );

			return this;

		},

		beginEdit: function(){
			
			// do something
			var that = this;

			if(fingers.formData.element(this.uid)){

				this.hideStaticView();
				this.showEditView();

	            var rawValue = fingers.formData.value(this.uid);

	            var values = rawValue.split('|');

	            values.forEach(function( element ){

					this.editView.append('<input type="text" value="' + element + '" class="edit-view-control single-text" />');

	            }, this);

	            // then add an empty one..
				this.editView.append('<input type="text" value="" class="edit-view-control single-text last" />');

				this.editView
					.bind('keydown', function( e ) {
						if (e.which === 13) {
							that.persistChange();
						}
						if (e.which === 27){
							that.cancel();							
						}

						if(e.which === 9){
							
							if( $(e.target).is('.last') && e.shiftKey === false){
										
								$(e.target).removeClass('last');
								that.editView.append('<input type="text" value="" class="edit-view-control single-text last" />');


							}

						}
					});


					this.editView.children('.last').focus();

					setTimeout( function(){
						
						$(document).bind('click', {that : that}, that.checkForClick );

					}, 250 );

				
				
			}

			return this;
		

		},

		checkForClick : function( event ){
			
			var that = event.data.that;

			if(!$(event.target).is('input', that.editView)){
				
				that.persistChange();
				
			}

			return this;

		},

		endEdit: function(){

			$(document).unbind('click', this.checkForClick );

			this.hideEditView();
			this.showStaticView();

			// do somethign else
			this.editView.empty();

			return this;

		},

        createEditView : function(){
            
            this.editView = $('<div class="edit-view-control multi-text"></div>');

            return this;

        }


    });

})(fingers);/*
	multi-text-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        multiTextLimit5: fingers.middleware.createChild('select-middleware')

    });

    fingers.middleware.multiTextLimit5.addInstanceMethods({

        

        // This needs a custom showStaticView which pulls out the inner text of the option tag, rather than the internal value. 

        showStaticView : function(){
            // get value out...
            var rawValue = fingers.formData.value(this.uid);

            // then find the inner text of the relevant option....
            // and display that instead, or if it's a vlaue of '' then display click to edit.

            if (rawValue === '') {
                rawValue = 'Click to edit';
            }

            var value = rawValue.replace(/\|/g, ', ');



            this.staticView.html(value).show();

            return this;

        },

		persistChange : function(){
					
			// read in all the values of all the inputs that are children of
			// this.editView, turn into a single string with each value separated by a pipe

			var values = [];

			this.editView.find('input.single-text').each(function(){
				
				var val = $(this).val();

				if(val && val !== ''){
					
					values.push( $(this).val() );

				}

			});

			this.okay( values.toString().replace(/,/g, '|') );

			return this;

		},

		beginEdit: function(){
			
			// do something
			var that = this, i;

			if(fingers.formData.element(this.uid)){

				this.hideStaticView();
				this.showEditView();

	            var rawValue = fingers.formData.value(this.uid);

	            var values = rawValue.split('|');

	            this.length = 0;

	            values.forEach(function( element ){

					this.editView.append('<input type="text" value="' + element + '" class="edit-view-control single-text" />');
					this.length++;

	            }, this);

	            for(i = this.length; i < 5; i++){

					this.editView.append('<input type="text" value="" class="edit-view-control single-text last" />');

				}

				this.editView
					.bind('keydown', function( e ) {
						if (e.which === 13) {
							that.persistChange();
						}
						if (e.which === 27){
							that.cancel();							
						}
					});


					this.editView.children('.last').focus();

					setTimeout( function(){
						
						$(document).bind('click', {that : that}, that.checkForClick );

					}, 250 );

				
				
			}

			return this;
		

		},

		checkForClick : function( event ){
			
			var that = event.data.that;

			if(!$(event.target).is('input', that.editView)){
				
				that.persistChange();
				
			}

			return this;

		},

		endEdit: function(){

			$(document).unbind('click', this.checkForClick );

			this.hideEditView();
			this.showStaticView();

			// do somethign else
			this.editView.empty();

			return this;

		},

        createEditView : function(){
            
            this.editView = $('<div class="edit-view-control multi-text"></div>');

            return this;

        }


    });

})(fingers);/*
	middleware.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		datePicker : fingers.middleware.createChild('middleware')

	});

	fingers.middleware.datePicker.addInstanceMethods({

		createEditView : function(){
			
			this.editView = $('<input type="text" class="edit-view-control date-picker" />');

			return this;

		},

		beginEdit: function(){
			
			// do something
			var that = this;

			if(fingers.formData.element(this.uid)){

				this.hideStaticView();

				fingers.formData.element(this.uid).after(this.editView);

				this.editView.datepicker({ 
					onSelect : function(){
						that.persistChange();		
					}, 
					onClose : function(){
						that.cancel();	

					},
					changeYear: "true", 
					dateFormat: 'dd M yy'
				}).focus();

			}

			return this;
		
		},

		endEdit : function(){

			this.editView.datepicker('destroy');

			this.hideEditView();

			this.showStaticView();
			// do somethign else

			return this;

		}


	});

})(fingers);/*
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

})(fingers);/*
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

})(fingers);/*
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
/*
multi-type-ahead-middleware.js
*/

(function (fingers) {

    fingers.middleware.addStaticMethods({

        multiTypeAhead: fingers.middleware.createChild('multi-type-ahead-middleware')

    });

    fingers.middleware.multiTypeAhead.addInstanceMethods({


        // This needs a custom showStaticView which pulls out the inner text of the option tag, rather than the internal value. 

        showStaticView : function(){
            // get value out...
            var rawValue = fingers.formData.value(this.uid);

            // then find the inner text of the relevant option....
            // and display that instead, or if it's a vlaue of '' then display click to edit.

            if (rawValue === '') {
                rawValue = 'Click to edit';
            }

            var value = rawValue.replace(/\|/g, ', ');



            this.staticView.html(value).show();

            return this;

        },

		persistChange : function(){
					
			// read in all the values of all the inputs that are children of
			// this.editView, turn into a single string with each value separated by a pipe

			var values = [];

			this.editView.find('input.single-text').each(function(){
				
				var val = $(this).val();

				if(val && val !== ''){
					
					values.push( $(this).val() );

				}

			});

			this.okay( values.toString().replace(/,/g, '|') );

			return this;

		},

		beginEdit: function(){
			
			// do something
			var that = this, i;

			if(fingers.formData.element(this.uid)){

				this.hideStaticView();
				this.showEditView();

				var rawValue = fingers.formData.value(this.uid);

				var values = rawValue.split('|');

				this.length = 0;

				values.forEach(function( element ){

					this.editView.append('<input type="text" value="' + element + '" class="edit-view-control single-text" />');
					this.length++;

				}, this);

				for(i = this.length; i < 5; i++){

					this.editView.append('<input type="text" value="" class="edit-view-control single-text last" />');

				}

				this.editView.children().each(function(){

					$(this).autocomplete({
						source: ["c++", "java", "php", "coldfusion", "javascript", "asp", "ruby"],
                        //function (req, add) {
                        //    $.getJSON(lookupUrl + "/" + arms.cleanSearchText(req.term), function (data) {
                        //        add(data);
                        //    });
                        //},
                        select: function (event, ui) {
							$(this).val(ui.item.value);
                        },
                        minLength: 2
                    }).bind('blur', function(){

                    });
                  });

				this.editView
					.bind('keydown', function( e ) {
						if (e.which === 13) {
							that.persistChange();
						}
						if (e.which === 27){
							that.cancel();							
						}
					});

					
					this.editView.children('.last').focus();

					setTimeout( function(){
						
						$(document).bind('click', {that : that}, that.checkForClick );

					}, 250 );
					

				
				
			}

			return this;
		

		},

		checkForClick : function( event ){
			
			var that = event.data.that;

			if(!$(event.target).is('input', that.editView) && !$(event.target).is('ul.ui-autocomplete li a')){
			
				that.persistChange();
				
			}

			return this;

		},

		endEdit: function(){

			$(document).unbind('click', this.checkForClick );

			this.hideEditView();
			this.showStaticView();

			// do somethign else
			this.editView.empty();

			return this;

		},

        createEditView : function(){
            
            this.editView = $('<div class="edit-view-control multi-text"></div>');

            return this;

        }

});

})(fingers);/********************************************************************
*
* Filename:		outro.js
* Description:	Finishing up...
*	
********************************************************************/

	// expose base to the outside world for external modification
	window.base = base;


} (window));
