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
	import com.adobe.utils.mousewheel.MouseWheelEnabler;
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.HScrollBar;
	import mx.controls.VScrollBar;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.managers.CursorManager;
	
	import org.rockholla.events.PanZoomEvent;
	
	[Event(name="zoom", type="org.rockholla.events.PanZoomEvent")]
	[Event(name="pan", type="org.rockholla.events.PanZoomEvent")]
	
	/**
	 * The PanZoomComponent is a Flex 3 and 4 compatible control, capable of receiving standard flex components,
	 * placing them within the component's pannable and zoomable container.
	 * 
	 * @langversion 3.0
	 */
	public class PanZoomComponent extends Canvas 
	{
		
		public static const TOP_LEFT:String = "topLeft";
		public static const TOP_RIGHT:String = "topRight";
		public static const BOTTOM_LEFT:String = "bottomLeft";
		public static const BOTTOM_RIGHT:String = "bottomRight";
		
		protected var _initialized:Boolean = false;
		protected var _created:Boolean = false;
		
		public var content:Canvas = new Canvas();
		
		[Bindable]
		public var contentBorderColor:uint = 0xFFFFFF;
		[Bindable]
		public var contentBorderAlpha:Number = 1;
		[Bindable]
		public var contentBorderThickness:Number = 1;
		[Bindable]
		public var contentBackgroundColor:uint = 0xFFFFFF;
		[Bindable]
		public var contentBackgroundAlpha:Number = 1;
		[Bindable]
		public var childPreventsPan:Boolean = true;
		
		protected var _contentWidth:Number;
		protected var _contentHeight:Number;
		
		protected var _scaleMin:Number = 0.125;
		protected var _scaleMax:Number = 5;
		protected var _scale:Number = 1;
		
		protected var _vScrollBar:VScrollBar = new VScrollBar();
		protected var _hScrollBar:HScrollBar = new HScrollBar();
		protected var _contentTopLeft:Point = new Point(0,0);
		protected var _mouseDownPosition:Point = new Point(0,0);
		protected var _viewCenter:Point = new Point(0,0);
		protected var _bottomRightMask:UIComponent = new UIComponent();
		
		[Embed(source="../../assets/icons/iconography.swf", symbol="IconHandOpen")] 
		private var _iconHandOpen:Class;		
		[Embed(source="../../assets/icons/iconography.swf", symbol="IconHandClosed")] 
		private var _iconHandClosed:Class;
		
		/**
		 * Constructor
		 * 
		 */
		public function PanZoomComponent() 
		{
			super();
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.addEventListener(FlexEvent.CREATION_COMPLETE, this._onCreationComplete);
		}
		
		/**
		 * Run when the component and all its initial children have been created
		 * 
		 * @param event	the FlexEvent
		 */
		protected function _onCreationComplete(event:FlexEvent):void 
		{
			
			this.content.width = this._contentWidth;
			this.content.height = this._contentHeight;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void { MouseWheelEnabler.init(stage); });
			this.content.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._activateNormalMouseEvents(true);
			
			this._updateViewCenter();
			
			this._hScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this._vScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this.addEventListener(ResizeEvent.RESIZE, _enforcePlacementRules);
			
			this.zoom(1);
			
			this._created = true;
		
		}
		
		/**
		 * Run when a user is using the scrollbars.  This is a necessary function since we are bypassing
		 * built-in Flex scrollbar functionality
		 * 
		 * @param event	the ScrollEvent
		 * 
		 */
		protected function _onScrollBarScroll(event:ScrollEvent):void 
		{
			
			if(event.currentTarget is HScrollBar) 
			{
				this.content.x = -1 * event.position;
				this._contentTopLeft.x = this.content.x;
			}
			else if(event.currentTarget is VScrollBar) 
			{
				this.content.y = -1 * event.position;
				this._contentTopLeft.y = this.content.y;	
			}
			this._updateViewCenter();
			
			this.dispatchEvent(new PanZoomEvent(PanZoomEvent.PAN));
			
		}
		
		/**
		 * We want to do some things before the "children" of this container are added, i.e.
		 * add the actual children, then add the initial "children" of this container to the content
		 * 
		 */
		override protected function createChildren():void 
		{
			
			this.content.graphics.clear();
			
			// draw the background
			this.content.graphics.beginFill(this.contentBackgroundColor, this.contentBackgroundAlpha);
			this.content.graphics.drawRect(0, 0, this._contentWidth, this._contentHeight);
			this.content.graphics.endFill();
			
			// draw the border
			this.content.graphics.lineStyle(this.contentBorderThickness, this.contentBorderColor, this.contentBorderAlpha);
			this.content.graphics.drawRect(0, 0, this._contentWidth, this._contentHeight);
			
			this.addChild(this.content);
			this.addChild(this._vScrollBar);
			this.addChild(this._hScrollBar);
			this.addChild(this._bottomRightMask);
			
			this._initialized = true;
			
			super.createChildren();

		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			
			if(this._initialized)
			{
				return this.content.addChild(child);
			}
			else
			{
				return super.addChild(child);
			}
			
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			
			if(this._initialized)
			{
				return this.content.addChildAt(child, index);
			}
			else
			{
				return super.addChildAt(child, index);
			}
			
		}
		
		override public function getChildren():Array
		{
			if(this._created)
			{
				return this.content.getChildren();
			}
			else
			{
				return super.getChildren();
			}
		}
		
		override public function getChildAt(index:int):DisplayObject
		{
			if(this._created)
			{
				return this.content.getChildAt(index);	
			}
			else
			{
				return super.getChildAt(index);
			}
		}
		
		override public function getChildIndex(child:DisplayObject):int
		{
			if(this._created)
			{
				return this.content.getChildIndex(child);	
			}
			else
			{
				return super.getChildIndex(child);
			}
		}
		
		override public function getChildByName(name:String):DisplayObject
		{
			if(this._created)
			{
				return this.content.getChildByName(name);		
			}
			else
			{
				return super.getChildByName(name);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this._updateScrollBars();
			
		}
		
		protected function _updateScrollBars():void 
		{
			
			this._vScrollBar.x = unscaledWidth - this._vScrollBar.width;
			this._vScrollBar.y = 0;
			this._vScrollBar.height = unscaledHeight - this._hScrollBar.height;
			
			this._hScrollBar.y = unscaledHeight - this._hScrollBar.height;
			this._hScrollBar.x = 0;
			this._hScrollBar.width = unscaledWidth - this._vScrollBar.width;
			
			this._hScrollBar.maxScrollPosition = this._contentWidth * this.scale;
			this._hScrollBar.pageSize = this._contentWidth * this.scale;
			this._vScrollBar.maxScrollPosition = this._contentHeight * this.scale;
			this._vScrollBar.pageSize = this._contentHeight * this.scale;
			
			// draw bottom right rect covering up area where scrollbars meet
			this._bottomRightMask.graphics.clear();
			this._bottomRightMask.graphics.beginFill(0xFFFFFF);
			this._bottomRightMask.graphics.drawRect(this.width - this._vScrollBar.width, this.height - this._hScrollBar.height, this._vScrollBar.width, this._hScrollBar.height);
			this._bottomRightMask.graphics.endFill();
			
			this._hScrollBar.maxScrollPosition = (this._contentWidth * this.scale) - (this.width - this._vScrollBar.width);
			this._vScrollBar.maxScrollPosition = (this._contentHeight * this.scale) - (this.height - this._hScrollBar.height);
			this._hScrollBar.scrollPosition = -1 * this.content.x;
			this._vScrollBar.scrollPosition = -1 * this.content.y;
			
			this._hScrollBar.pageScrollSize = this._hScrollBar.maxScrollPosition/10;
			this._hScrollBar.lineScrollSize = this._hScrollBar.maxScrollPosition/30;
			this._vScrollBar.pageScrollSize = this._vScrollBar.maxScrollPosition/10;
			this._vScrollBar.lineScrollSize = this._vScrollBar.maxScrollPosition/30;
		}
		
		protected function _updateViewCenter():void 
		{
			
			var contentPixelsPerViewPixel:Number = (this._contentWidth/this.scale)/this._contentWidth;
			if((this.width - this._vScrollBar.width) >= (this._contentWidth * this.scale)) 
			{
				this._viewCenter.x = this._contentWidth/2;
			} 
			else 
			{
				this._viewCenter.x = (-1 * this._contentTopLeft.x * contentPixelsPerViewPixel) + ((this.width - this._vScrollBar.width)/2 * contentPixelsPerViewPixel);
			}
			if((this.height - this._hScrollBar.height) >= (this._contentHeight * this.scale)) 
			{
				this._viewCenter.y = this._contentHeight/2;
			} 
			else 
			{
				this._viewCenter.y = (-1 * this._contentTopLeft.y * contentPixelsPerViewPixel) + ((this.height - this._hScrollBar.height)/2 * contentPixelsPerViewPixel);
			}
			
		}
		
		public function set contentWidth(value:Number):void 
		{
			this._contentWidth = value;
		}
		public function get contentWidth():Number
		{
			return this._contentWidth;
		}
		public function set contentHeight(value:Number):void 
		{
			this._contentHeight = value;
		}
		public function get contentHeight():Number
		{
			return this._contentHeight;
		}
		public function set scaleMin(value:Number):void 
		{
			this._scaleMin = value;
		}
		
		[Bindable]
		public function get scaleMin():Number 
		{ 
			return this._scaleMin; 
		}
		[Bindable]
		public function get scaleMax():Number 
		{ 
			return this._scaleMax; 
		}
		public function set scaleMax(value:Number):void 
		{ 
			this._scaleMax = value; 
		}
		public function set scale(value:Number):void 
		{ 
			this._scale = value;
		}
		[Bindable]
		public function get scale():Number 
		{ 
			return this._scale; 
		}
		
		protected function _activateNormalMouseEvents(isFirstActivation:Boolean = false):void 
		{
			
			if(this.content.hasEventListener(MouseEvent.MOUSE_DOWN) && !isFirstActivation)
			{
				return;
			}
			this.content.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.content.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this.content.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			
		}
		protected function _cancelNormalMouseEvents(exceptMouseWheel:Boolean = false):void 
		{
			
			this.content.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.content.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			if(!exceptMouseWheel)
			{
				this.content.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);	
			}
			
		}
		
		protected function _onMouseOver(event:MouseEvent):void 
		{ 
			if((this.childPreventsPan == true && event.target == this.content) || this.childPreventsPan == false)
			{
				this._setCursorHandOpen();
				this._activateNormalMouseEvents();
			}
			else
			{
				CursorManager.removeAllCursors();
				this._cancelNormalMouseEvents(true);
			} 
		}
		
		protected function _onMouseDown(event:MouseEvent):void 
		{

			this._setCursorHandClosed();
			this._mouseDownPosition.x = this.parent.mouseX;
			this._mouseDownPosition.y = this.parent.mouseY;
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseDownMove);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._cancelNormalMouseEvents();
			
		}
		
		protected function _onMouseDownMove(event:MouseEvent):void 
		{
			
			this.content.x = this._contentTopLeft.x - (this._mouseDownPosition.x - this.parent.mouseX);
			this.content.y = this._contentTopLeft.y - (this._mouseDownPosition.y - this.parent.mouseY);
			this.dispatchEvent(new PanZoomEvent(PanZoomEvent.PAN));
			
		}
		
		protected function _onMouseUp(event:Event):void 
		{
			
			this._setCursorHandOpen();
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseDownMove);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._activateNormalMouseEvents();
			
			this._contentTopLeft.x = this.content.x;
			this._contentTopLeft.y = this.content.y;
			this._enforcePlacementRules();
			TweenLite.to(this.content, 0.2, {x: this._contentTopLeft.x, y: this._contentTopLeft.y, onComplete: this._updateViewCenter});
			
		}
		
		protected function _onMouseOut(event:MouseEvent):void 
		{ 
			CursorManager.removeAllCursors();	
		}
		
		protected function _enforcePlacementRules(event:Event = null):void 
		{
			
			var xLocked:Boolean = false;
			var yLocked:Boolean = false;
			var updateViewCenter:Boolean = false;
			if(this._contentWidth * this.scale <= (this.width - this._vScrollBar.width)) 
			{
				// center content on x axis
				this._contentTopLeft.x = ((this.width - this._vScrollBar.width) - (this._contentWidth * this.scale))/2;
				xLocked = true;
				updateViewCenter = true;
			}
			if(this._contentHeight * this.scale <= (this.height - this._hScrollBar.height)) 
			{
				// center content on y axis
				this._contentTopLeft.y = (this.height - (this._contentHeight * this.scale))/2;
				yLocked = true;
				updateViewCenter = true;
			}
			
			if(!xLocked) 
			{
				if(this._contentPointInView("0", null)) 
				{
					this._contentTopLeft.x = 0;
					updateViewCenter = true;
				} 
				else if(this._contentPointInView(this._contentWidth.toString(), null)) 
				{
					this._contentTopLeft.x = (this.width - this._vScrollBar.width) - (this._contentWidth * this.scale);
					updateViewCenter = true;
				}
			}
			if(!yLocked) 
			{
				if(this._contentPointInView(null, "0")) 
				{
					this._contentTopLeft.y = 0;	
					updateViewCenter = true;
				} 
				else if(this._contentPointInView(null, this._contentHeight.toString())) 
				{
					this._contentTopLeft.y = (this.height - this._hScrollBar.height) - (this._contentHeight * this.scale);
					updateViewCenter = true;
				}
			}
			if(updateViewCenter && event == null) 
			{
				this._updateViewCenter();
			}
			if(event != null) 
			{
				TweenLite.to(this.content, 0.2, {x: this._contentTopLeft.x, y: this._contentTopLeft.y, onComplete: this._updateViewCenter});
			}
			
		}
		
		protected function _setCursorHandOpen():void 
		{
			
			if(CursorManager.currentCursorID) 
			{
				CursorManager.removeCursor(CursorManager.currentCursorID);
			}
			CursorManager.setCursor(this._iconHandOpen);
			
		}
		
		protected function _setCursorHandClosed():void 
		{
			
			if(CursorManager.currentCursorID) 
			{
				CursorManager.removeCursor(CursorManager.currentCursorID);
			}
			CursorManager.setCursor(this._iconHandClosed);
			
		}
		
		public function zoom(toScale:Number):void 
		{
			
			if(toScale >= this.scaleMin && toScale <= this.scaleMax) 
			{
				this.scale = toScale;
				
				this._contentTopLeft.x = 0 - (this._viewCenter.x - (((this.width - this._vScrollBar.width)/2)/this.scale)) * this.scale;
				this._contentTopLeft.y = 0 - (this._viewCenter.y - (((this.height - this._hScrollBar.height)/2)/this.scale)) * this.scale;

				this._enforcePlacementRules();
				
				TweenLite.to(this.content, 0.2, { scaleX: this.scale, scaleY: this.scale, x: this._contentTopLeft.x, y: this._contentTopLeft.y });
			
				this.dispatchEvent(new PanZoomEvent(PanZoomEvent.ZOOM));
			}
			
		}
		
		public function zoomDirectional(directionalSpeed:int):void 
		{
			
			if(directionalSpeed > 0) 
			{
				this.zoom(this.scale + (.04 * directionalSpeed));
			} 
			else if(directionalSpeed < 0) 
			{
				this.zoom(this.scale + (.04 * directionalSpeed));
			}
				
		}
		
		protected function _onMouseWheel(event:MouseEvent):void 
		{ 
			this.zoomDirectional(event.delta); 
		}
		
		protected function _cornerPointInView(cornerName:String):Boolean 
		{
			
			// This function is run against unscaled content x/y coords
			if(cornerName == TOP_LEFT) 
			{
				return this._contentPointInView("0", "0");
			} 
			else if(cornerName == TOP_RIGHT) 
			{
				return this._contentPointInView(this._contentWidth.toString(), "0");
			} 
			else if(cornerName == BOTTOM_LEFT) 
			{
				return this._contentPointInView("0", this._contentHeight.toString());
			} 
			else if(cornerName == BOTTOM_RIGHT) 
			{
				return this._contentPointInView(this._contentWidth.toString(), this._contentHeight.toString());
			}
			
			throw new Error("Invalid corner point name: " + cornerName);
			
		}
		
		protected function _contentPointInView(x:String, y:String):Boolean 
		{
				
			// this function should be run after calculations and BEFORE physical updating
			// we have top left
			// if (content top x + (x * scale)) is less than or equal to this.width then x is in view
			if(x == null || ((this._contentTopLeft.x + (Number(x) * this.scale)) <= (this.width - this._vScrollBar.width) && (this._contentTopLeft.x + (Number(x) * this.scale)) >= 0)) 
			{
				// no perform the same calc for y
				if(y == null || ((this._contentTopLeft.y + (Number(y) * this.scale)) <= (this.height - this._hScrollBar.height) && (this._contentTopLeft.y + (Number(y) * this.scale)) >= 0)) 
				{
					return true;
				}
			}
			return false;
			
		}
						
	}
	
}