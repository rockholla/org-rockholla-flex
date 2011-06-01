package org.rockholla.controls.panzoom
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	
	public class PanZoomContent extends Canvas
	{
		
		public function PanZoomContent()
		{
			super();
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