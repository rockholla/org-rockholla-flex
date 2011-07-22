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
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.managers.CursorManager;
	
	import org.rockholla.events.PanZoomEvent;
	
	/**
	 * Dispatched when the user is zooming in or out
	 * 
	 * @eventType org.rockholla.events.PanZoomEvent.ZOOM
	 */
	[Event(name="zoom", type="org.rockholla.events.PanZoomEvent")]
	/**
	 * Dispatched when the user is zooming panning or scrolling
	 * 
	 * @eventType org.rockholla.events.PanZoomEvent.PAN
	 */
	[Event(name="pan", type="org.rockholla.events.PanZoomEvent")]
	
	/**
	 * The PanZoomComponent is a Flex 3 and 4 compatible control, capable of receiving standard flex components,
	 * placing them within a container that can be panned and zoomed via dragging, dropping, and mouse wheel operation.
	 * 
	 * @langversion 3.0
	 */
	public class PanZoomComponent extends Canvas 
	{
		
		/**
		 * Constant to identify a top left corner 
		 */
		public static const TOP_LEFT:String = "topLeft";
		/**
		 * Constant to identify a top right corner 
		 */
		public static const TOP_RIGHT:String = "topRight";
		/**
		 * Constant to identify a bottom left corner 
		 */
		public static const BOTTOM_LEFT:String = "bottomLeft";
		/**
		 * Constant to identify a bottom right corner 
		 */
		public static const BOTTOM_RIGHT:String = "bottomRight";
		
		/**
		 * This is the container where all custom children are placed.  It represents
		 * the bounded area that can be panned and zoomed.
		 */
		public var content:PanZoomContent;

		/**
		 * When true, while the mouse is over a child within the <strong>content</strong> container disables normal panning
		 * by drag and drop.
		 */
		[Bindable]
		public var childPreventsPan:Boolean = true;
		/**
		 * If true, then the mouse wheel zooming will zoom to cursor point instead of center of screen (a little wonky still)
		 */
		[Bindable]
		public var zoomToCursor:Boolean = true;
		/**
		 * If greater than zero, double clicking in the content will zoom "this amount", a scale step value
		 */
		[Bindable]
		public var doubleClickZoomStep:Number = 0;
		/**
		 * If set, this point designates a center point for initial view
		 */
		[Bindable]
		public var loadCenterPoint:Point;
		/**
		 * If set to true, will center the view on load
		 */
		[Bindable]
		public var centerOnLoad:Boolean = false;
		/**
		 * Can be set for initially zooming to a given level, default is 1 (100%)
		 */
		[Bindable]
		public var initialZoomLevel:Number = 1;
		
		/**
		 * The minimum zoom level allowed (where 1 is actual size, 100%)
		 */
		protected var _scaleMin:Number = 0.125;
		/**
		 * The maximum zoom level allowed (where 1 is actual size, 100%)
		 */
		protected var _scaleMax:Number = 5;
		/**
		 * The zoom level, initially set to 1
		 */
		protected var _scale:Number = 1;
		/**
		 * The base zoom speed, initially set to 1
		 */
		protected var _zoomSpeed:Number = 1;
		
		/**
		 * Our custom vertical scroll bar, replacing the built-in Flex one
		 */
		protected var _vScrollBar:VScrollBar = new VScrollBar();
		/**
		 * Our custom horizontal scroll bar, replacing the built-in Flex one
		 */
		protected var _hScrollBar:HScrollBar = new HScrollBar();
		/**
		 * Tracks where the top, left point of the <strong>content</strong> container is for panning/zooming purposes
		 */
		protected var _contentTopLeft:Point = new Point(0,0);
		/**
		 * Tracks a point where the mouse was clicked for panning/zooming purposes
		 */
		protected var _mouseDownPosition:Point = new Point(0,0);
		/**
		 * Tracks the current center point of the viewable window into the <strong>content</strong> container
		 */
		protected var _viewCenter:Point = new Point(0,0);
		/**
		 * A simple rectangular mask to be placed at the bottom-right most part of the component, for covering
		 * the area where the scrollbars meet
		 */
		protected var _bottomRightMask:UIComponent = new UIComponent();
		
		/**
		 * The default container icon, an open hand
		 */
		[Embed(source="../../assets/icons/iconography.swf", symbol="IconHandOpen")] 
		private var _iconHandOpen:Class;
		/**
		 * The closed icon hand, used when dragging the <strong>content</strong> container around
		 */
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
			
			this.addEventListener(Event.ADDED_TO_STAGE, this._onAddedToStage);
			this.content.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this._activateNormalMouseEvents(true);
			
			this._updateViewCenter();
			
			this._hScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this._vScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this.addEventListener(ResizeEvent.RESIZE, _enforcePlacementRules);
			
			this.content.addEventListener(PanZoomEvent.CONTENT_REDRAWN, _onContentRedrawn);
			
			if(this.centerOnLoad == true)
			{
				this.loadCenterPoint = new Point(this.content.width/2, this.content.height/2);
			}
			if(this.loadCenterPoint != null)
			{
				if(this.loadCenterPoint.x > this.content.width) this.loadCenterPoint.x = this.content.width;
				if(this.loadCenterPoint.y > this.content.height) this.loadCenterPoint.y = this.content.height;
				if(this.loadCenterPoint.x < 0) this.loadCenterPoint.x = 0;
				if(this.loadCenterPoint.y < 0) this.loadCenterPoint.y = 0;
				this.zoomToPoint(this.loadCenterPoint, this.initialZoomLevel);
			}
			else
			{
				this.zoom(this.initialZoomLevel);	
			}
			
		}
		
		protected function _onAddedToStage(event:Event):void
		{
			MouseWheelEnabler.init(stage);
		}
		
		protected function _onContentRedrawn(event:PanZoomEvent):void
		{
			// this will reset center after a possible resize
			this.zoom(this.scale);
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
			
			super.createChildren();
			
			var children:Array = this.getChildren();
			if(children.length != 1 || (children[0] is PanZoomContent) == false)
			{
				throw new PanZoomComponentError("The PanZoomComponent must have exactly 1 immediate child of type PanZoomContent.");
				return;
			}
			
			this.content = children[0];
			
			if(this.content.width <= 0) 
			{
				throw new PanZoomComponentError("Width of the PanZoomContent must be greater than zero.  This error likely means you just haven't set it.");
				return;
			}
			if(this.content.height <= 0) 
			{
				throw new PanZoomComponentError("Height of the PanZoomContent must be greater than zero.  This error likely means you just haven't set it.");
				return;
			}
			
			this.addChild(this._vScrollBar);
			this.addChild(this._hScrollBar);
			this.addChild(this._bottomRightMask);
			
		}
		
		/**
		 * Replaces the default updateDisplayList method, calls the original and performs tasks necessary to create
		 * pieces of this component in the correct position/layout, etc.
		 * 
		 * @param unscaledWidth		the unscaledWidth of this component
		 * @param unscaledHeight	the unscaledHeight of this component 
		 * 
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this._updateScrollBars();
		}	
		
		/**
		 * Used for updating the dimensions/positions of the scrollbars
		 * 
		 */
		protected function _updateScrollBars():void 
		{
			
			this._vScrollBar.x = unscaledWidth - this._vScrollBar.width;
			this._vScrollBar.y = 0;
			this._vScrollBar.height = unscaledHeight - this._hScrollBar.height;
			
			this._hScrollBar.y = unscaledHeight - this._hScrollBar.height;
			this._hScrollBar.x = 0;
			this._hScrollBar.width = unscaledWidth - this._vScrollBar.width;
			
			this._hScrollBar.maxScrollPosition = this.content.width * this.scale;
			this._hScrollBar.pageSize = this.content.width * this.scale;
			this._vScrollBar.maxScrollPosition = this.content.height * this.scale;
			this._vScrollBar.pageSize = this.content.height * this.scale;
			
			// draw bottom right rect covering up area where scrollbars meet
			this._bottomRightMask.graphics.clear();
			this._bottomRightMask.graphics.beginFill(0xFFFFFF);
			this._bottomRightMask.graphics.drawRect(this.width - this._vScrollBar.width, this.height - this._hScrollBar.height, this._vScrollBar.width, this._hScrollBar.height);
			this._bottomRightMask.graphics.endFill();
			
			this._hScrollBar.maxScrollPosition = (this.content.width * this.scale) - (this.width - this._vScrollBar.width);
			this._vScrollBar.maxScrollPosition = (this.content.height * this.scale) - (this.height - this._hScrollBar.height);
			this._hScrollBar.scrollPosition = -1 * this.content.x;
			this._vScrollBar.scrollPosition = -1 * this.content.y;
			
			this._hScrollBar.pageScrollSize = this._hScrollBar.maxScrollPosition/10;
			this._hScrollBar.lineScrollSize = this._hScrollBar.maxScrollPosition/30;
			this._vScrollBar.pageScrollSize = this._vScrollBar.maxScrollPosition/10;
			this._vScrollBar.lineScrollSize = this._vScrollBar.maxScrollPosition/30;
		}
		
		/**
		 * Used for keeping track of the center point of the viewable area of the <strong>content</strong> container
		 * 
		 */
		protected function _updateViewCenter():void 
		{
			
			var contentPixelsPerViewPixel:Number = (this.content.width/this.scale)/this.content.width;
			if((this.width - this._vScrollBar.width) >= (this.content.width * this.scale)) 
			{
				this._viewCenter.x = this.content.width/2;
			} 
			else 
			{
				this._viewCenter.x = (-1 * this._contentTopLeft.x * contentPixelsPerViewPixel) + ((this.width - this._vScrollBar.width)/2 * contentPixelsPerViewPixel);
			}
			if((this.height - this._hScrollBar.height) >= (this.content.height * this.scale)) 
			{
				this._viewCenter.y = this.content.height/2;
			} 
			else 
			{
				this._viewCenter.y = (-1 * this._contentTopLeft.y * contentPixelsPerViewPixel) + ((this.height - this._hScrollBar.height)/2 * contentPixelsPerViewPixel);
			}
			
		}

		/**
		 * Sets the minimum zoom level
		 * 
		 * @param value	the minimum level
		 * 
		 */
		[Bindable]
		public function set scaleMin(value:Number):void 
		{
			this._scaleMin = value;
		}
		
		/**
		 * The minimum zoom level
		 * 
		 * @return the minimum level
		 * 
		 */
		public function get scaleMin():Number 
		{ 
			return this._scaleMin; 
		}
		
		/**
		 * Sets the maximum zoom level
		 * 
		 * @param the maximum level
		 * 
		 */
		[Bindable]
		public function set scaleMax(value:Number):void 
		{ 
			this._scaleMax = value; 
		}
		/**
		 * The maximum zoom level
		 * 
		 * @return the maximum level
		 * 
		 */
		public function get scaleMax():Number 
		{ 
			return this._scaleMax; 
		}
		
		/**
		 * Sets the scale or zoom level of the content
		 * 
		 * @param value the scale, zoom level to set
		 * 
		 */
		[Bindable]
		public function set scale(value:Number):void 
		{ 
			this._scale = value;
		}
		/**
		 * The current scale or zoom level
		 * 
		 * @return the scale, zoom level
		 * 
		 */
		public function get scale():Number 
		{ 
			return this._scale; 
		}
		
		/**
		 * Sets the zoom speed base value
		 * 
		 * @param value	the positive number speed
		 * 
		 */
		[Bindable]
		public function set zoomSpeed(value:Number):void
		{
			if(value < 0)
			{
				throw new PanZoomComponentError("You can't set a zoom speed less than zero");
			}
			this._zoomSpeed = value;
		}
		/**
		 * The zoom speed base value
		 * 
		 * @return the zoom speed
		 * 
		 */
		public function get zoomSpeed():Number
		{
			return this._zoomSpeed;
		}
		
		/**
		 * Activates the mouse events necessary for panning and zooming
		 * 
		 * @param isFirstActivation	tells whether we're activating these events for the first time or not
		 * 
		 */
		protected function _activateNormalMouseEvents(isFirstActivation:Boolean = false):void 
		{
			
			if(this.content.hasEventListener(MouseEvent.MOUSE_DOWN) && !isFirstActivation)
			{
				return;
			}
			this.content.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.content.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this.content.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			if(this.doubleClickZoomStep > 0)
			{
				this.doubleClickEnabled = true;
				this.content.addEventListener(MouseEvent.DOUBLE_CLICK, _onDoubleClick);
			}
			
		}
		/**
		 * Removes the mouse events necessary for panning and zooming
		 * 
		 * @param exceptMouseWheel	when true, then mouse wheel zooming event will remain active
		 * 
		 */
		protected function _cancelNormalMouseEvents(exceptMouseWheel:Boolean = false):void 
		{
			
			this.content.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.content.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			if(!exceptMouseWheel)
			{
				this.content.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);	
			}
			if(this.content.hasEventListener(MouseEvent.DOUBLE_CLICK))
			{
				this.content.removeEventListener(MouseEvent.DOUBLE_CLICK, _onDoubleClick);		
			}
			
		}
		
		/**
		 * Executed when the mouse is over the <strong>content</strong> container
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
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
		
		/**
		 * Executed when the mouse is pressed down on the <strong>content</strong> container
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onMouseDown(event:MouseEvent):void 
		{
			
			this._setCursorHandClosed();
			this._mouseDownPosition.x = this.parent.mouseX;
			this._mouseDownPosition.y = this.parent.mouseY;
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseDownMove);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this._cancelNormalMouseEvents();
			
		}
		
		/**
		 * Executed when the mouse is pressed down and is moving around the <strong>content</strong> container
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onMouseDownMove(event:MouseEvent):void 
		{
			
			this.content.x = this._contentTopLeft.x - (this._mouseDownPosition.x - this.parent.mouseX);
			this.content.y = this._contentTopLeft.y - (this._mouseDownPosition.y - this.parent.mouseY);
			this.dispatchEvent(new PanZoomEvent(PanZoomEvent.PAN));
			
		}
		
		/**
		 * Executed when the mouse is depressed 
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
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
		
		/**
		 * Executed when the mouse is moved out of the <strong>content</strong> container
		 * 
		 * @param event	the MouseEvent
		 * 
		 */ 
		protected function _onMouseOut(event:MouseEvent):void 
		{ 
			CursorManager.removeAllCursors();	
		}
		
		/**
		 * Executed on double click in the content (if doubleClickZoomStep is greater than 0)
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onDoubleClick(event:MouseEvent):void
		{
			this.zoomToPoint(new Point(this.content.mouseX, this.content.mouseY), this.scale + this.doubleClickZoomStep);
		}
		
		/**
		 * A centralized method for enforcing that the <strong>content</strong> container has not been "placed" invalidly, and if it has,
		 * then snap it back to the closest valid state.
		 * 
		 * @param event	the relevant event that most recently placed the content
		 * 
		 */
		protected function _enforcePlacementRules(event:Event = null):void 
		{
			
			var xLocked:Boolean = false;
			var yLocked:Boolean = false;
			var updateViewCenter:Boolean = false;
			if(this.content.width * this.scale <= (this.width - this._vScrollBar.width)) 
			{
				// center content on x axis
				this._contentTopLeft.x = ((this.width - this._vScrollBar.width) - (this.content.width * this.scale))/2;
				xLocked = true;
				updateViewCenter = true;
			}
			if(this.content.height * this.scale <= (this.height - this._hScrollBar.height)) 
			{
				// center content on y axis
				this._contentTopLeft.y = (this.height - (this.content.height * this.scale))/2;
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
				else if(this._contentPointInView(this.content.width.toString(), null)) 
				{
					this._contentTopLeft.x = (this.width - this._vScrollBar.width) - (this.content.width * this.scale);
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
				else if(this._contentPointInView(null, this.content.height.toString())) 
				{
					this._contentTopLeft.y = (this.height - this._hScrollBar.height) - (this.content.height * this.scale);
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
		
		/**
		 * Sets the Flex cursor to the open hand
		 * 
		 */
		protected function _setCursorHandOpen():void 
		{
			
			CursorManager.removeAllCursors();
			CursorManager.setCursor(this._iconHandOpen);
			
		}
		
		/**
		 * Sets the Flex cursor to the closed hand
		 * 
		 */
		protected function _setCursorHandClosed():void 
		{
			
			CursorManager.removeAllCursors();
			CursorManager.setCursor(this._iconHandClosed);
			
		}
		
		/**
		 * Zooms center to a particular point in the content
		 * 
		 * @param point			the x,y point zoom center destination
		 * @param toScale		the new zoom scale
		 * @param validateWarn	if true, then trace warns of out-of-bounds scale value (default = true)
		 * 
		 */
		public function zoomToPoint(point:Point, toScale:Number):void
		{
			
			this._viewCenter.x = point.x;
			this._viewCenter.y = point.y;
			this.zoom(toScale, true);
			
		}
		
		protected function _fixToScale(toScale:Number):Number
		{
			if(toScale > this.scaleMax) return this.scaleMax;
			if(toScale < this.scaleMin) return this.scaleMin;
			return toScale;
		}
		
		/**
		 * Executes a zoom to a particular level/scale
		 * 
		 * @param toScale	the zoom destination scale
		 * 
		 */
		public function zoom(toScale:Number, computeDuration:Boolean = false):void 
		{
			
			toScale = this._fixToScale(toScale);
			
			// Let's adjust zoom time based on scale jump if calling context should compute duration
			var duration:Number = (computeDuration == true ? Math.abs(this.scale - toScale) : 0.2)/this._zoomSpeed;
			
			this.scale = toScale;
			
			this._contentTopLeft.x = 0 - (this._viewCenter.x - (((this.width - this._vScrollBar.width)/2)/this.scale)) * this.scale;
			this._contentTopLeft.y = 0 - (this._viewCenter.y - (((this.height - this._hScrollBar.height)/2)/this.scale)) * this.scale;
			
			this._enforcePlacementRules();
			
			TweenLite.to(this.content, duration, { scaleX: this.scale, scaleY: this.scale, x: this._contentTopLeft.x, y: this._contentTopLeft.y });
			
			this.dispatchEvent(new PanZoomEvent(PanZoomEvent.ZOOM));
			
		}
		
		/**
		 * Zooms in a particular directional speed relative to the current scale.  I.e. if we're zooming in quicker, we pass in a large number greater than
		 * 1.  If we'd like to zoom out slowly, then it's a number just less than zero.
		 * 
		 * @param directionalSpeed	the vector-like value, designating a direction (positive or negative) and a magnitude (how large or small it is)
		 * 
		 */
		public function zoomDirectional(directionalSpeed:int):void 
		{
			this.zoom(this.scale + (.04 * directionalSpeed));
		}
		
		/**
		 * Executed when a user uses the mouse wheel
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onMouseWheel(event:MouseEvent):void 
		{ 
			if(this.zoomToCursor)
			{
				this._viewCenter.x = this.content.mouseX;
				this._viewCenter.y = this.content.mouseY;
			}
			this.zoomDirectional(event.delta); 
		}
		
		/**
		 * Determines if/which corner point(s) of the <strong>content</strong> container is in view
		 * 
		 * @param cornerName	the contstant corner name representing one of four possible corners
		 * 
		 */
		protected function _cornerPointInView(cornerName:String):Boolean 
		{
			
			// This function is run against unscaled content x/y coords
			if(cornerName == TOP_LEFT) 
			{
				return this._contentPointInView("0", "0");
			} 
			else if(cornerName == TOP_RIGHT) 
			{
				return this._contentPointInView(this.content.width.toString(), "0");
			} 
			else if(cornerName == BOTTOM_LEFT) 
			{
				return this._contentPointInView("0", this.content.height.toString());
			} 
			else if(cornerName == BOTTOM_RIGHT) 
			{
				return this._contentPointInView(this.content.width.toString(), this.content.height.toString());
			}
			
			throw new Error("Invalid corner point name: " + cornerName);
			
		}
		
		/**
		 * Determines if a particular x,y coord of the <strong>content</strong> container is in view
		 * 
		 * @param x	the x coordinate to check
		 * @param y the y coordinate to check
		 * 
		 */
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