/********************************************************************
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
	
