package org.rockholla.controls.panzoom.tools
{
	import com.greensock.TweenLite;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Box;
	import mx.controls.Button;
	import mx.controls.sliderClasses.Slider;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	import mx.managers.CursorManager;
	
	import org.rockholla.controls.panzoom.PanZoomComponent;
	import org.rockholla.events.PanZoomEvent;
	
	public class PanZoomTools extends Box
	{
		
		public function PanZoomTools()
		{
			
			super();
			this.width = 500;
			this.height = 20;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
			
		}
		
		protected function _onCreationComplete(event:FlexEvent):void
		{	
			(this.parent as PanZoomComponent).addEventListener(PanZoomEvent.ZOOM, _onZoom);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0.5);
			this.graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, 0, 0, 5, 0);
			this.graphics.endFill();
			
			
			
		}
		
		protected function _onZoom(event:PanZoomEvent):void
		{
			trace("ZOOOOOOM!");
		}

		
	}
}