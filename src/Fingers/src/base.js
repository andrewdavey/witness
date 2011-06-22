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
		
			var child = function base( args ){
				
				if ( this instanceof arguments.callee ) {
		
					this.init.apply( this, args.callee ? args : arguments );
			
					return this;
		
				} else { 
		
					return new arguments.callee( arguments );
		
				}
			};
			
			$.extend(child, this);
			$.extend(child.prototype,  this.prototype);

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
	
	