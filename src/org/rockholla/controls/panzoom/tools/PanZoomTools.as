package org.rockholla.controls.panzoom.tools
{
	import mx.containers.Box;
	import mx.containers.BoxDirection;
	import mx.containers.Canvas;
	import mx.controls.sliderClasses.Slider;
	import mx.controls.sliderClasses.SliderDirection;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	
	import org.rockholla.controls.panzoom.PanZoomComponent;
	import org.rockholla.events.PanZoomEvent;
	import org.rockholla.positioning.Alignment;
	import org.rockholla.positioning.Orientation;
	import org.rockholla.positioning.Placement;
	import org.rockholla.positioning.Positioning;
	
	public class PanZoomTools extends Box
	{
		
		protected var _slider:Slider = new Slider();
		protected var _miniMapNavigator:MiniMapNavigator = new MiniMapNavigator();
		
		public function PanZoomTools()
		{
			super();
			
			/* Temporary until we put in place user positioning */
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.right = 0;
			this.top = 0;
			this.height = 50;
			this.width = 200;
			this.setStyle("paddingTop", 20);
			this.setStyle("paddingBottom", 20);
			this.setStyle("backgroundColor", 0x000000);
			this.setStyle("backgroundAlpha", 0.2);
			this.setStyle("horizontalAlign", "right");
			this.direction = BoxDirection.HORIZONTAL;
			this._slider.direction = SliderDirection.HORIZONTAL;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
			
		}
		
		protected function _onCreationComplete(event:FlexEvent):void
		{
			(this.parent as PanZoomComponent).addEventListener(PanZoomEvent.ZOOM, _onZoom);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			this.addChild(this._miniMapNavigator);
			
			this._slider.liveDragging = true;
			this._slider.value = 100;
			this._slider.addEventListener(SliderEvent.CHANGE, _onSliderChanged);
			
			this.addChild(this._slider);
		}
		
		protected function _onZoom(event:PanZoomEvent):void
		{
			trace("ZOOOOOOM!");
			/*if(this.slider.value/100 != this.panzoom.scale)
			{
				this.slider.value = this.panzoom.scale * 100;
			}*/
		}
		
		protected function _onSliderChanged(event:SliderEvent):void
		{
			trace(event);
			//this.dispatchEvent(new PanZoomEvent(PanZoomEvent.SLIDER_CHANGED, true));
		}
		
		public function setSliderLimits(scaleMin:Number, scaleMax:Number):void
		{
			this._slider.minimum = scaleMin * 100;
			this._slider.maximum = scaleMax * 100;
			this._slider.labels = [this._slider.minimum + "%", "Zoom", this._slider.maximum + "%"];
		}
		
	}
}