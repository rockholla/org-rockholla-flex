package org.rockholla.containers
{
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.SkinnableContainer;
	
	public class LoadingContainer extends SkinnableContainer
	{
		[Embed(source="../assets/swf/loading-indicator.swf")]
		private var loadingAnimation:Class;

		protected var _uiContainer:UIComponent;
		protected var _loadImage:Image;
		protected var _fade:UIComponent;
		protected var _isLoading:Boolean;
		
		public function LoadingContainer()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
		}
		
		protected function _onCreationComplete(event:FlexEvent):void
		{
			
		}
		
		[Bindable]
		public function set isLoading(isLoading:Boolean):void
		{
			this._isLoading = isLoading;
			this.invalidateDisplayList();
		}
		public function get isLoading():Boolean
		{
			return this._isLoading;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			this._uiContainer = new UIComponent();
			this._loadImage = new Image();
			this._loadImage.width = 31;
			this._loadImage.height = 31;
			this._fade = new UIComponent();		
			
			this.addElement(this._uiContainer);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(!this._isLoading)
			{
				this._uiContainer.visible = false;
				if(this._uiContainer.contains(this._loadImage))
				{
					this._uiContainer.removeChild(this._loadImage);
				}
				if(this._uiContainer.contains(this._fade))
				{
					this._uiContainer.removeChild(this._fade);
				}
				return;
			}
			
			if(this._uiContainer)
			{
				this._uiContainer.width = unscaledWidth;
				this._uiContainer.height = unscaledHeight;	
			}
			
			if(this._isLoading)
			{	
				if(this._fade)
				{
					this._uiContainer.addChild(this._fade);
					this._fade.graphics.clear();
					this._fade.graphics.beginFill(0x9c9c9c, 0.4);
					this._fade.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					this._fade.graphics.endFill();	
				}
				if(this._loadImage)
				{
					this._loadImage.source = this.loadingAnimation;
					this._uiContainer.addChild(this._loadImage);
					this._loadImage.x = unscaledWidth/2 - this._loadImage.width/2;
					this._loadImage.y = unscaledHeight/2 - this._loadImage.height/2;
				}
				
				this._uiContainer.visible = true;
				this._uiContainer.width = 0;
				this._uiContainer.height = 0;
				
			}
		}
		
	}
}