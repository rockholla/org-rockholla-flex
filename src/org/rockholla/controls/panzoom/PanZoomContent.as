/*
*	This is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*	 
*/
package org.rockholla.controls.panzoom
{
	import flash.display.CapsStyle;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	import org.rockholla.events.PanZoomEvent;
	
	/**
	 * The default content wrapper within a PanZoomComponent implementation.  This class can be extended to implement
	 * your own custom PanZoomContent.
	 * 
	 * @langversion 3.0
	 */
	public class PanZoomContent extends Canvas
	{
		
		/**
		 * The background color for the content
		 */
		[Inspectable (defaultValue=0xFFFFFF)]
		protected var _backgroundColor:uint = 0xFFFFFF;
		/**
		 * the background alpha for the content
		 */
		[Inspectable (defaultValue=1)]
		protected var _backgroundAlpha:Number = 1;
		/**
		 * the border color for the content
		 */
		[Bindable] 
		protected var _borderColor:uint = 0;
		/**
		 * the border thickness for the content
		 */
		[Inspectable (defaultValue=0)]
		protected var _borderThickness:Number = 0;
		/**
		 * the border alpha for the content
		 */
		[Inspectable (defaultValue=1)]
		protected var _borderAlpha:Number = 1;
		/**
		 * Tracks whether or not this content has been fully created and added to
		 * the PanZoomComponent
		 */
		protected var _created:Boolean = false;
		
		/**
		 * Constructor
		 * 
		 * @param width		the width for the content
		 * @param height	the height for the content
		 * 
		 */
		public function PanZoomContent(width:Number = 0, height:Number = 0)
		{
			super();
			this.width = width;
			this.height = height;
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
		}
		
		/**
		 * Executed when the content has been successfully created and added to the
		 * PanZoomComponent
		 * 
		 */
		protected function _onCreationComplete(event:FlexEvent):void
		{
			this._created = true;
		}
		
		/**
		 * Override of default createChildren method
		 * 
		 */
		override protected function createChildren():void
		{
			this._drawContent(false);
			super.createChildren();
		}
		
		/**
		 * Gets whether or not this content has been created and added to its PanZoomComponent
		 * 
		 */
		public function get created():Boolean
		{
			return this._created;
		}
		
		/**
		 * General method to be executed whenever the content (background, border, etc.) need to be drawn (or redrawn)
		 * 
		 */
		protected function _drawContent(isRedraw:Boolean = true):void
		{
			
			if(isRedraw && !this._created)
			{
				return;
			}
			
			this.graphics.clear();
			
			// draw the background
			this.graphics.beginFill(this._backgroundColor, this._backgroundAlpha);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
			// draw the border
			if(this._borderThickness > 0)
			{
				this.graphics.lineStyle(this._borderThickness, this._borderColor, this._borderAlpha);
				this.graphics.drawRect(0, 0, this.width, this.height);	
			}
			
			if(isRedraw && this._created)
			{
				this.dispatchEvent(new PanZoomEvent(PanZoomEvent.CONTENT_REDRAWN));
			}
			
		}
		
		/**
		 * Executed when the width is set/updated
		 * 
		 * @param value	the new width
		 * 
		 */
		override public function set width(value:Number):void
		{
			super.width = value;
			this._drawContent();
		}
		
		/**
		 * Executed when the height is set/updated
		 * 
		 * @param value	the new height
		 * 
		 */
		override public function set height(value:Number):void
		{
			super.height = value;
			this._drawContent();
		}
		
		/**
		 * Sets the background color for the content
		 * 
		 * @param value	the uint color
		 * 
		 */
		[Bindable]
		public function set backgroundColor(value:uint):void
		{
			this._backgroundColor = value;
			this._drawContent();
		}
		/**
		 * Gets the background color for the content
		 * 
		 * @return the uint color
		 * 
		 */
		public function get backgroundColor():uint
		{
			return this._backgroundColor;
		}
		
		/**
		 * Sets the background alpha for the content
		 * 
		 * @param value	the numeric alpha value
		 * 
		 */
		[Bindable]
		public function set backgroundAlpha(value:Number):void
		{
			this._backgroundAlpha = value;
			this._drawContent();
		}
		/**
		 * Gets the background alpha for the content
		 * 
		 * @return the numeric alpha value
		 * 
		 */
		public function get backgroundAlpha():Number
		{
			return this._backgroundAlpha;
		}
		
		/**
		 * Sets the border color for the content
		 * 
		 * @param value	the uint color
		 * 
		 */
		[Bindable]
		public function set borderColor(value:uint):void
		{
			this._borderColor = value;
			this._drawContent();
		}
		/**
		 * Gets the border color for the content
		 * 
		 * @return the uint color
		 * 
		 */
		public function get borderColor():uint
		{
			return this._borderColor;
		}
		
		/**
		 * Sets the thickness of the border for the content
		 * 
		 * @param value	the numeric thickness
		 * 
		 */
		[Bindable]
		public function set borderThickness(value:Number):void
		{
			this._borderThickness = value;
			this._drawContent();
		}
		/**
		 * Gets the thickness of the border for the content
		 * 
		 * @return the numeric thickness
		 * 
		 */
		public function get borderThickness():Number
		{
			return this._borderThickness;
		}
		
		/**
		 * Sets the border alpha for the content
		 * 
		 * @param value	the numeric alpha value
		 * 
		 */
		[Bindable]
		public function set borderAlpha(value:Number):void
		{
			this._borderAlpha = value;
			this._drawContent();
		}
		/**
		 * Gets the border alpha for the content
		 * 
		 * @return the numeric alpha value
		 * 
		 */
		public function get borderAlpha():Number
		{
			return this._borderAlpha;
		}
		
		/**
		 * Override of the default scrollRect setter, so we can do some different things specific to
		 * the PanZoomComponent
		 * 
		 * @param value	the Rectangle-defined "window" where we want to zoom/pan to
		 * 
		 */
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