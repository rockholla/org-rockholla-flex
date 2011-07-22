package org.rockholla.controls.panzoom
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	import org.rockholla.events.PanZoomEvent;
	
	public class PanZoomContent extends Canvas
	{
		
		[Bindable]
		public var backgroundColor:uint = 0xFFFFFF;
		
		[Bindable]
		public var backgroundAlpha:Number = 1;
		
		[Bindable] 
		public var borderColor:uint;
		
		[Bindable]
		public var borderThickness:Number = 1;
		
		[Bindable]
		public var borderAlpha:Number = 1;
		
		protected var _created:Boolean = false;
		
		public function PanZoomContent(width:Number = 0, height:Number = 0)
		{
			super();
			this.width = width;
			this.height = height;
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
		}
		
		protected function _onCreationComplete(event:FlexEvent):void
		{
			this._created = true;
		}
		
		override protected function createChildren():void
		{
			this._drawContent();
			super.createChildren();
		}
		
		public function get created():Boolean
		{
			return this._created;
		}
		
		protected function _drawContent():void
		{
			
			this.graphics.clear();
			
			// draw the background
			this.graphics.beginFill(this.backgroundColor, this.backgroundAlpha);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
			// draw the border
			if(this.borderColor != 0)
			{
				this.graphics.lineStyle(this.borderThickness, this.borderColor, this.borderAlpha);
				this.graphics.drawRect(0, 0, this.width, this.height);	
			}
			
			if(this._created)
			{
				this.dispatchEvent(new PanZoomEvent(PanZoomEvent.CONTENT_REDRAWN));
			}
			
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			if(this._created == true) 
			{
				this._drawContent();
			}
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			if(this._created == true)
			{
				this._drawContent();
			}
		}
		
		override public function set scrollRect(value:Rectangle):void
		{
			var panZoomComponent:PanZoomComponent = this.parent as PanZoomComponent;
			var scale:Number = panZoomComponent.width/value.width;
			value.height = panZoomComponent.height/scale;
			var x:Number = value.x + value.width/2;
			var y:Number = value.y + value.height/2;
			panZoomComponent.zoomToPoint(new Point(x, y), scale); 	
		}
		
	}
}