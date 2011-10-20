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
	import com.greensock.TweenLite;
	
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
	import mx.events.ScrollEventDirection;
	import mx.managers.CursorManager;
	
	import org.rockholla.controls.panzoom.tools.PanZoomTools;
	import org.rockholla.events.PanZoomEvent;
	import org.rockholla.utils.MouseWheelHandler;
	
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
	 * The PanZoomComponent is a Flex 3 and 4 compatible control, capable of laying out flex components
	 * within a container that can be panned and zoomed via dragging, dropping, and mouse wheel operation.
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
		 * General error message thrown when an implementation tries to add children directly to the component 
		 * instead of the content
		 */
		public static const INVALID_CHILD_ERROR:String = "The PanZoomComponent must have exactly 1 immediate child of type PanZoomContent.";
		/**
		 * General error message thrown when an implementation hasn't set the width/height of the content
		 */
		public static const DIMENSIONS_UNSET_ERROR:String = "The width and height of the PanZoomContent must be greater than zero.  This error likely means you just haven't set one or both of these values."
		/**
		 * General error message thrown when an implementation tries to access/update/etc. the built-in scrollbars 
		 * for the component, and instructs on how to access the custom scroll bars instead.
		 */
		public static const SCROLL_BARS_ACCESS_ERROR:String = "The scrollbars for the PanZoomComponent do not rely on built in scrollbars.  Please access panHorizontalScrollBar and panVerticalScrollBar properties to access the scrollbars.  If you want to hide or show the scrollbars, use the panScrollBarsVisible method.";

		public static const MOUSEWHEEL_JS:String = "function cancelEvent(a){a=a?a:window.event;if(a.stopPropagation){a.stopPropagation()}if(a.preventDefault){a.preventDefault()}a.cancelBubble=true;a.cancel=true;a.returnValue=false;return false}function onMouseWheel(a){var b=0;if(!a){a=window.event}if(a.wheelDelta){b=a.wheelDelta/120;if(window.opera)b=-b}else if(a.detail){b=-a.detail/3}if(isOverSwf(a)){return cancelEvent(a)}return true}function isOverSwf(a){var b;if(a.srcElement){b=a.srcElement.nodeName}else if(a.target){b=a.target.nodeName}if(b.toLowerCase()=='object'||b.toLowerCase()=='embed'){return true}return false}function hookMouseWheel(){if(window.addEventListener){window.addEventListener('DOMMouseScroll',onMouseWheel,false)}window.onmousewheel=document.onmousewheel=onMouseWheel}hookMouseWheel()";
		
		/**
		 * When true, while the mouse is over a child within the <strong>content</strong> container disables normal panning
		 * by drag and drop.
		 */
		[Bindable]
		[Inspectable (defaultValue=true)]
		public var childPreventsPan:Boolean = true;
		/**
		 * If true, then the mouse wheel zooming will zoom to cursor point instead of center of screen (a little wonky still)
		 */
		[Bindable]
		[Inspectable (defaultValue=true)]
		public var zoomToCursor:Boolean = true;
		/**
		 * If greater than zero, double clicking in the content will zoom "this amount", a scale step value
		 */
		[Bindable]
		[Inspectable (defaultValue=0)]
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
		[Inspectable (defaultValue=false)]
		public var centerOnLoad:Boolean = false;
		/**
		 * Can be set for initially zooming to a given level, default is 1 (100%)
		 */
		[Bindable]
		[Inspectable (defaultValue=1)]
		public var initialZoomLevel:Number = 1;
		/**
		 * If true, then the mouse wheel operates as a zooming mechanism, if false, then it acts as a scroll 
		 * up-down mechanism
		 */
		[Bindable]
		[Inspectable (defaultValue=true)]
		public var mouseWheelZoomingEnabled:Boolean = true;	
		/**
		 * If set (not null), this will cause all zoom operations to always zoom centered on this point
		 */
		[Bindable]
		public var fixedZoomPoint:Point;
		/**
		 * If true, then we will disable browser scrolling when over the Flash area of the page
		 */
		[Bindable]
		[Inspectable(defaultValue=true)]
		public var disableBrowserScrolling:Boolean = true;
		
		/**
		 * This is the container where all custom children are placed.  It represents the bounded area that can be 
		 * panned and zoomed.
		 */
		protected var _content:PanZoomContent;
		
		protected var _tools:PanZoomTools = new PanZoomTools();
		
		/**
		 * The minimum zoom level allowed (where 1 is actual size, 100%)
		 */
		[Inspectable (defaultValue=0.125)]
		protected var _scaleMin:Number = 0.125;
		/**
		 * The maximum zoom level allowed (where 1 is actual size, 100%)
		 */
		[Inspectable (defaultValue=5)]
		protected var _scaleMax:Number = 5;
		/**
		 * The zoom level, initially set to 1
		 */
		[Inspectable (defaultValue=1)]
		protected var _scale:Number = 1;
		/**
		 * The base zoom speed, initially set to 1
		 */
		[Inspectable (defaultValue=1)]
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
		protected var _contentTopLeft:Point;
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
		private var __iconHandOpen:Class;
		/**
		 * The closed icon hand, used when dragging the <strong>content</strong> container around
		 */
		[Embed(source="../../assets/icons/iconography.swf", symbol="IconHandClosed")] 
		private var __iconHandClosed:Class;

		/**
		 * Tracks whether local mouse events are activated or not
		 */
		private var __mouseEventsActivated:Boolean = false;
		
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
		 * 
		 */
		protected function _onCreationComplete(event:FlexEvent):void 
		{
			
			this.addEventListener(Event.ADDED_TO_STAGE, this._onAddedToStage);
			
			this._hScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this._vScrollBar.addEventListener(ScrollEvent.SCROLL, _onScrollBarScroll);
			this.addEventListener(ResizeEvent.RESIZE, _enforcePlacementRules);
			
			this._initializeContent();
			
		}
		
		/**
		 * Used to initialize the content container on creation of PanZoomComponent or replacement of the PanZoomContent
		 * 
		 */
		protected function _initializeContent():void
		{
			
			this._contentTopLeft = new Point(0,0);
			this._activateNormalMouseEvents(true);
			if(!this._content.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				this._content.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);	
			}
			if(!this._content.hasEventListener(PanZoomEvent.CONTENT_REDRAWN))
			{
				this._content.addEventListener(PanZoomEvent.CONTENT_REDRAWN, _onContentRedrawn);	
			}
			
			this._updateViewCenter();
			if(this.centerOnLoad == true)
			{
				this.loadCenterPoint = new Point(this._content.widthAsSet/2, this._content.heightAsSet/2);
			}
			if(this.loadCenterPoint != null)
			{
				this.zoomToPoint(this.loadCenterPoint, this.initialZoomLevel);
			}
			else
			{
				this.zoom(this.initialZoomLevel, false);	
			}
			
		}
		
		/**
		 * Executed when this component is added to the stage
		 * 
		 * @param event	the related Event
		 * 
		 */
		protected function _onAddedToStage(event:Event):void
		{
			
			MouseWheelHandler.init(stage);
			
		}
		
		/**
		 * Executed whenever the content is redrawn, i.e. resized, retooled, etc.
		 * 
		 */
		protected function _onContentRedrawn(event:PanZoomEvent):void
		{
			this._initializeContent();
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
				this._content.x = -1 * event.position;
				this._contentTopLeft.x = this._content.x;
			}
			else if(event.currentTarget is VScrollBar || event.currentTarget == null) 
			{
				this._content.y = -1 * event.position;
				this._contentTopLeft.y = this._content.y;	
			}
			this._updateViewCenter();
			
			this.dispatchEvent(new PanZoomEvent(PanZoomEvent.PAN));
			
		}
		
		/**
		 * We want to do some validation of the only expected child, PanZoomContent.  Additionally, we
		 * are adding the custom scroll bars here.
		 * 
		 */
		override protected function createChildren():void 
		{
			
			super.createChildren();
			
			var children:Array = this.getChildren();
			if(children.length != 1 || (children[0] is PanZoomContent) == false)
			{
				throw new PanZoomComponentError(INVALID_CHILD_ERROR);
				return;
			}
			
			this._content = children[0];
			
			if(this._content.widthAsSet <= 0) 
			{
				throw new PanZoomComponentError(DIMENSIONS_UNSET_ERROR);
				return;
			}
			if(this._content.heightAsSet <= 0) 
			{
				throw new PanZoomComponentError(DIMENSIONS_UNSET_ERROR);
				return;
			}
			
			this.addChild(this._vScrollBar);
			this.addChild(this._hScrollBar);
			this.addChild(this._bottomRightMask);
			this.addChild(this._tools);
			
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
			
			this._tools.top = 0;
			this._tools.right = 0 + (this.panScrollBarsVisible ? this._vScrollBar.width : 0);
			
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
			
			this._hScrollBar.pageSize = this._content.widthAsSet * this._scale;
			this._vScrollBar.pageSize = this._content.heightAsSet * this._scale;
			
			// draw bottom right rect covering up area where scrollbars meet
			this._bottomRightMask.graphics.clear();
			this._bottomRightMask.graphics.beginFill(0xFFFFFF);
			this._bottomRightMask.graphics.drawRect(this.width - this._vScrollBar.width, this.height - this._hScrollBar.height, this._vScrollBar.width, this._hScrollBar.height);
			this._bottomRightMask.graphics.endFill();
			
			this._hScrollBar.maxScrollPosition = (this._content.widthAsSet * this._scale) - (this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0));
			this._vScrollBar.maxScrollPosition = (this._content.heightAsSet * this._scale) - (this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0));
			this._hScrollBar.scrollPosition = -1 * this._content.x;
			this._vScrollBar.scrollPosition = -1 * this._content.y;
			
			this._hScrollBar.pageScrollSize = this._hScrollBar.maxScrollPosition/10;
			this._hScrollBar.lineScrollSize = this._hScrollBar.maxScrollPosition/30;
			this._vScrollBar.pageScrollSize = this._vScrollBar.maxScrollPosition/10;
			this._vScrollBar.lineScrollSize = this._vScrollBar.maxScrollPosition/30;
		}
		
		/**
		 * Used for keeping track of the center point of the viewable area of the PanZoomContent container
		 * 
		 */
		protected function _updateViewCenter():void 
		{
			
			var contentPixelsPerViewPixel:Number = (this._content.widthAsSet/this._scale)/this._content.widthAsSet;
			if((this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0)) >= (this._content.widthAsSet * this._scale)) 
			{
				this._viewCenter.x = this._content.widthAsSet/2;
			} 
			else 
			{
				this._viewCenter.x = (-1 * this._contentTopLeft.x * contentPixelsPerViewPixel) + ((this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0))/2 * contentPixelsPerViewPixel);
			}
			if((this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0)) >= (this._content.heightAsSet * this._scale)) 
			{
				this._viewCenter.y = this._content.heightAsSet/2;
			} 
			else 
			{
				this._viewCenter.y = (-1 * this._contentTopLeft.y * contentPixelsPerViewPixel) + ((this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0))/2 * contentPixelsPerViewPixel);
			}
			
		}

		/**
		 * Setter for the PanZoomContent, used to replace the content container
		 * 
		 * @param content	the new PanZoomContent
		 * 
		 */
		public function set content(content:PanZoomContent):void
		{
			var childIndex:int = this.getChildIndex(this._content);
			this._cancelNormalMouseEvents();
			this.removeChild(this._content);
			this._content = content;
			this.addChildAt(this._content, childIndex);
			this._initializeContent();
		}
		
		/**
		 * Gets the PanZoomContent for the component
		 * 
		 * @return the current PanZoomContent
		 * 
		 */
		public function get content():PanZoomContent
		{
			return this._content;
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
			if(value > this._scaleMax)
			{
				throw new PanZoomComponentError(value + " is greater than the maxium allowed scale setting.");
				return;
			}
			if(value < this._scaleMin)
			{
				throw new PanZoomComponentError(value + " is less than the minimum allowed scale setting.");
				return;
			}
			this.zoom(value);
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
				throw new PanZoomComponentError("You can't set a zoom speed less than zero.");
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
		 * Gets the custom horizontal scroll bar for this component
		 * 
		 * @return the HScrollBar
		 * 
		 */
		public function get panHorizontalScrollBar():HScrollBar
		{
			return this._hScrollBar;
		}
		
		/**
		 * Gets the custom vertical scroll bar for this component
		 * 
		 * @return the VScrollBar
		 * 
		 */
		public function get panVerticalScrollBar():VScrollBar
		{
			return this._vScrollBar;
		}
		
		/**
		 * Gets whether or not the custom scroll bars are set visible
		 * 
		 * @return true or false
		 * 
		 */
		public function get panScrollBarsVisible():Boolean
		{
			return this._hScrollBar.visible;
		}
		
		/**
		 * Sets whether or not the custom scroll bars are visible
		 * 
		 * @param value	true or false
		 * 
		 */
		public function set panScrollBarsVisible(value:Boolean):void
		{
			this._hScrollBar.visible = value;
			this._vScrollBar.visible = value;
			this._bottomRightMask.visible = value;
		}
		
		/**
		 * Override of the default setter for horizontal scroll policy, so we can throw an error if an implementation 
		 * tries to set this to "on"
		 * 
		 * @param value	the scroll policy
		 * 
		 */
		override public function set horizontalScrollPolicy(value:String):void
		{
			if(this.content != null && this.content.created)
			{
				throw new PanZoomComponentError(SCROLL_BARS_ACCESS_ERROR);
			}
			else
			{
				super.horizontalScrollPolicy = value;
			}
		}
		/**
		 * Override of the default setter for vertical scroll policy, so we can throw an error if an implementation 
		 * tries to set this to "on"
		 * 
		 * @param value	the scroll policy
		 * 
		 */
		override public function set verticalScrollPolicy(value:String):void
		{
			if(this.content != null && this.content.created)
			{
				throw new PanZoomComponentError(SCROLL_BARS_ACCESS_ERROR);
			}
			else
			{
				super.verticalScrollPolicy = value;
			}
		}
		
		/**
		 * Activates the mouse events necessary for panning and zooming
		 * 
		 * @param isFirstActivation	tells whether we're activating these events for the first time or not
		 * 
		 */
		protected function _activateNormalMouseEvents(isFirstActivation:Boolean = false):void 
		{
			
			if(this.__mouseEventsActivated && !isFirstActivation)
			{
				return;
			}
			this._content.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this._content.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this._content.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			if(this.doubleClickZoomStep > 0)
			{
				this.doubleClickEnabled = true;
				this._content.addEventListener(MouseEvent.DOUBLE_CLICK, _onDoubleClick);
			}
			this.__mouseEventsActivated = true;
			
		}
		/**
		 * Removes the mouse events necessary for panning and zooming
		 * 
		 * @param exceptMouseWheel	when true, then mouse wheel zooming event will remain active
		 * 
		 */
		protected function _cancelNormalMouseEvents(exceptMouseWheel:Boolean = false):void 
		{
			
			this._content.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this._content.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			if(!exceptMouseWheel)
			{
				this._content.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);	
			}
			if(this._content.hasEventListener(MouseEvent.DOUBLE_CLICK))
			{
				this._content.removeEventListener(MouseEvent.DOUBLE_CLICK, _onDoubleClick);		
			}
			this.__mouseEventsActivated = false;
			
		}
		
		/**
		 * Executed when the mouse is over the <strong>content</strong> container
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onMouseOver(event:MouseEvent):void 
		{ 
			
			if((this.childPreventsPan == true && event.target == this._content) || this.childPreventsPan == false)
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
			
			this._content.x = this._contentTopLeft.x - (this._mouseDownPosition.x - this.parent.mouseX);
			this._content.y = this._contentTopLeft.y - (this._mouseDownPosition.y - this.parent.mouseY);
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
			
			this._contentTopLeft.x = this._content.x;
			this._contentTopLeft.y = this._content.y;
			this._enforcePlacementRules();
			TweenLite.to(this._content, 0.2, {x: this._contentTopLeft.x, y: this._contentTopLeft.y, onComplete: this._updateViewCenter});
			
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
			this.zoomToPoint(new Point(this._content.mouseX, this._content.mouseY), this._scale + this.doubleClickZoomStep);
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
			if(this._content.widthAsSet * this._scale <= (this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0))) 
			{
				// center content on x axis
				this._contentTopLeft.x = ((this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0)) - (this._content.widthAsSet * this._scale))/2;
				xLocked = true;
				updateViewCenter = true;
			}
			if(this._content.heightAsSet * this._scale <= (this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0))) 
			{
				// center content on y axis
				this._contentTopLeft.y = (this.height - (this._content.heightAsSet * this._scale))/2;
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
				else if(this._contentPointInView(this._content.widthAsSet.toString(), null)) 
				{
					this._contentTopLeft.x = (this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0)) - (this._content.widthAsSet * this._scale);
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
				else if(this._contentPointInView(null, this._content.heightAsSet.toString())) 
				{
					this._contentTopLeft.y = (this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0)) - (this._content.heightAsSet * this._scale);
					updateViewCenter = true;
				}
			}
			if(updateViewCenter && event == null) 
			{
				this._updateViewCenter();
			}
			if(event != null) 
			{
				TweenLite.to(this._content, 0.2, {x: this._contentTopLeft.x, y: this._contentTopLeft.y, onComplete: this._updateViewCenter});
			}
			
		}
		
		/**
		 * Sets the Flex cursor to the open hand
		 * 
		 */
		protected function _setCursorHandOpen():void 
		{
			
			CursorManager.removeAllCursors();
			CursorManager.setCursor(this.__iconHandOpen);
			
		}
		
		/**
		 * Sets the Flex cursor to the closed hand
		 * 
		 */
		protected function _setCursorHandClosed():void 
		{
			
			CursorManager.removeAllCursors();
			CursorManager.setCursor(this.__iconHandClosed);
			
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
			// we're going to opt for just fixing invalid values here instead of throwing an error
			if(point.x > this._content.widthAsSet) point.x = this._content.widthAsSet;
			if(point.x < 0) point.x = 0;
			if(point.y > this._content.heightAsSet) point.y = this._content.heightAsSet;
			if(point.y < 0) point.y = 0;
			this._viewCenter.x = point.x;
			this._viewCenter.y = point.y;
			
			this.zoom(toScale);
			
		}
		
		/**
		 * Used to fix a pending scale-to value that might fall out of the valid range
		 * 
		 * @param toScale	the pending scale-to value
		 * 
		 */
		protected function _fixToScale(toScale:Number):Number
		{
			if(toScale > this._scaleMax) return this._scaleMax;
			if(toScale < this._scaleMin) return this._scaleMin;
			return toScale;
		}
		
		/**
		 * Executes a zoom to a particular level/scale
		 * 
		 * @param toScale	the zoom destination scale
		 * 
		 */
		public function zoom(toScale:Number, computeDuration:Boolean = true):void 
		{
			
			toScale = this._fixToScale(toScale);
			
			// Let's adjust zoom time based on scale jump if calling context should compute duration
			var duration:Number = (computeDuration == true ? Math.abs(this._scale - toScale) : 0.2)/this._zoomSpeed;
			
			this._scale = toScale;
			
			if(this.fixedZoomPoint != null)
			{
				this._viewCenter.x = this.fixedZoomPoint.x;
				this._viewCenter.y = this.fixedZoomPoint.y;
			}

			this._contentTopLeft.x = 0 - (this._viewCenter.x - (((this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0))/2)/this._scale)) * this._scale;
			this._contentTopLeft.y = 0 - (this._viewCenter.y - (((this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0))/2)/this._scale)) * this._scale;
			
			this._enforcePlacementRules();
			
			TweenLite.to(this._content, duration, { scaleX: this._scale, scaleY: this._scale, x: this._contentTopLeft.x, y: this._contentTopLeft.y });
			
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
			this.zoom(this._scale + (.04 * directionalSpeed), false);
		}
		
		/**
		 * Executed when a user uses the mouse wheel
		 * 
		 * @param event	the MouseEvent
		 * 
		 */
		protected function _onMouseWheel(event:MouseEvent):void 
		{ 
			
			if(this.mouseWheelZoomingEnabled)
			{
				if(this.zoomToCursor)
				{
					this._viewCenter.x = this._content.mouseX;
					this._viewCenter.y = this._content.mouseY;
				}
				this.zoomDirectional(event.delta);	
			} 
			else
			{
				// with mouse wheel zooming disabled, we want the mouse wheel to scroll/pan instead
				if(this._cornerPointInView(TOP_LEFT) && this._cornerPointInView(BOTTOM_RIGHT))
				{
					// we can see the top and the bottom, so no scrolling should happen
					return;
				}
				this._vScrollBar.scrollPosition -= (event.delta < 0 ? -10 : 10) + (event.delta * 3);
				if(this._vScrollBar.scrollPosition > this._vScrollBar.maxScrollPosition)
				{
					this._vScrollBar.scrollPosition = this._vScrollBar.maxScrollPosition;
				}
				if(this._vScrollBar.scrollPosition < 0)
				{
					this._vScrollBar.scrollPosition = 0;
				}
				var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL, false, false, null, this._vScrollBar.scrollPosition, ScrollEventDirection.VERTICAL, event.delta);
				this._onScrollBarScroll(scrollEvent);
				
			}
			
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
				return this._contentPointInView(this._content.widthAsSet.toString(), "0");
			} 
			else if(cornerName == BOTTOM_LEFT) 
			{
				return this._contentPointInView("0", this._content.heightAsSet.toString());
			} 
			else if(cornerName == BOTTOM_RIGHT) 
			{
				return this._contentPointInView(this._content.widthAsSet.toString(), this._content.heightAsSet.toString());
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
			if(x == null || ((this._contentTopLeft.x + (Number(x) * this._scale)) <= (this.width - (this.panScrollBarsVisible ? this._vScrollBar.width : 0)) && (this._contentTopLeft.x + (Number(x) * this._scale)) >= 0)) 
			{
				// no perform the same calc for y
				if(y == null || ((this._contentTopLeft.y + (Number(y) * this._scale)) <= (this.height - (this.panScrollBarsVisible ? this._hScrollBar.height : 0)) && (this._contentTopLeft.y + (Number(y) * this._scale)) >= 0)) 
				{
					return true;
				}
			}
			return false;
			
		}
		
	}
	
}