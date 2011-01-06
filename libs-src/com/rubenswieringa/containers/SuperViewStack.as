package com.rubenswieringa.containers {
	
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import mx.containers.Canvas;
	import mx.core.Container;
	
	import flash.events.Event;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	
	// event declarations:
	/**
	 * Dispatched when the selected child Container changes.
	 * 
	 * @eventType	mx.events.IndexChangedEvent.CHANGE
	 */
	[Event(name="change", type="mx.events.IndexChangedEvent")]
	
	
	/**
	 * SuperViewStack in many ways behaves like the classic ViewStack.
	 * Additional features are reversed indexing (0=top, N=bottom) and fading of children.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * @version		1.0.3
	 * @see			mx.containers.ViewStack
	 * 
	 * 
	 * edit 3
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com)
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/SuperViewStack/docs/
	 * 
	 */
	public class SuperViewStack extends Canvas {
		
		
	// status variables:
		/**
		 * @private
		 */
 		protected var _childrenCreated:Boolean = false;
		
	// internals for accessors:
		/**
		 * @private
		 */
 		protected var _selectedIndex:int = -1;
		/**
		 * @private
		 */
 		protected var __fade:Array = [SuperViewStack.DEFAULT_FADE, 1.0];
		/**
		 * @private
		 */
 		protected var _fadeColor:uint = SuperViewStack.DEFAULT_FADECOLOR; 
 			
	// constants:
		/**
		 * Name of the Shape that is used to simulate fading of Containers.
		 */
 		public static const FADESHAPE_NAME:String = "superviewstackfade";
		/**
		 * Event type for the Event that is dispatched when the selected child Container changes.
		 * 
		 * @see		SuperViewStack#behavior
		 */
		public static const BEHAVIOR_CHANGED:String = "Behavior of SuperViewStack changed";
		/**
		 * Full-feature SuperViewStack behavior mode
		 * 
		 * @see		SuperViewStack#behavior
		 */
		public static const SUPER:String = "SuperViewStack";
		/**
		 * Normal behavior mode, simulating the behavior of the classic ViewStack
		 * 
		 * @see		SuperViewStack#behavior
		 * @see		mx.containers.ViewStack
		 */
		public static const NORMAL:String = "ViewStack";
		/**
		 * @private
		 */
 		protected static const DEFAULT_FADE:Number = 0.6;
		/**
		 * @private
		 */
		protected static const DEFAULT_FADECOLOR:uint = 0xFFFFFF;
		
		
	// CONSTRUCTOR:
		
		/**
		 * Constructor.
		 */
		public function SuperViewStack ():void {
			super();
			
			// set creationPolicy so that all children will be created from the start off:
			this.creationPolicy = "all";
			
		}
		
		
	// OVERRIDES:
		
		
		/**
		 * @see		mx.containers.ViewStack#childrenCreated()
		 * 
		 * @private
		 */
		override protected function childrenCreated ():void {
			super.childrenCreated();
			
			this._childrenCreated = true;
			
			if (this._selectedIndex == -1){
				this.selectedIndex = 0;
			}
			this.showChildren();
			
		}
		
		/**
		 * @see		mx.containers.ViewStack#updateDisplayList()
		 * 
		 * @private
		 */
		override protected function updateDisplayList (unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.showChildren();
			
			for (var i:uint=0; i<this.numChildren; i++){
				this.resizeFade(this.getChildAt(i) as Container);
			}
		}
		
		/**
		 * Adds a child DisplayObject instance to this DisplayObjectContainer instance.
		 *  Adjusted to make sure that (if reverse is set to true) children are created from top to bottom.
		 * 
		 * @param	child	The DisplayObject to add as a child of this Container.
		 * 
		 * @return	The added child as an object of type DisplayObject.
		 * 
		 * @see		mx.containers.ViewStack#addChild()
		 */
		override public function addChild (child:DisplayObject):DisplayObject {
			return this._addChild(child);
		}
		
		/**
		 * Adds a child DisplayObject to this Container. The child is added at the index specified.
		 *  Adjusted to make sure that (if reverse is set to true) children are created from top to bottom.
		 * 
		 * @param	child	The DisplayObject to add as a child of this Container.
		 * @param	index	The index to add the child at.
		 * 
		 * @return	The added child as an object of type DisplayObject.
		 * 
		 * @see		mx.containers.ViewStack#addChildAt
		 */
		override public function addChildAt (child:DisplayObject, index:int):DisplayObject {
			return this._addChild(child, index);
		}
		
		/**
		 * @private
		 */
		protected function _addChild (child:DisplayObject, index:int=-1):DisplayObject {
			if (index == -1){
				child = super.addChildAt(child, 0);
			}else{
				child = super.addChildAt(child, this.reverseIndex(index)+1);
			}
			
			// create a Shape for the fade to be drawn on and make sure it gets sized on the right time:
			this.drawFade(child as Container);
			child.addEventListener(FlexEvent.CREATION_COMPLETE, this.childCreationComplete);
			
			// execute some additional tasks if this is during runtime:
			if (this._childrenCreated){
				if (index == -1){
					if (this.numChildren > this.selectedIndex) this._selectedIndex++;
				}else{
					if (index > this.selectedIndex) this._selectedIndex++;
				}
				this.applyFade();
				this.showChildren();
			}
			
			// return child:
			return child;
		}
		
		/**
		 * Event handler for the creationComplete event of an added child, calls resizeFade().
		 * 
		 * @param	event	.
		 * 
		 * @see		SuperViewStack#resizeFade()
		 * 
		 * @private
		 */
		protected function childCreationComplete (event:FlexEvent):void {
			this.resizeFade(event.target as Container);
		}
		
		/**
		 * Returns the child display object instance that exists at the specified index.
		 * 
		 * @param	index	The index position of the child object.
		 * 
		 * @return	The child display object at the specified index position.
		 * 
		 * @see		mx.containers.ViewStack#getChildAt()
		 */
		override public function getChildAt (index:int):DisplayObject {
			return super.getChildAt(this.reverseIndex(index));
		}
		
		/**
		 * Returns the index position of a child DisplayObject instance.
		 * 
		 * @param	child	The DisplayObject instance to identify.
		 * 
		 * @return	The index position of the child display object to identify.
		 * 
		 * @see		mx.containers.ViewStack#getChildIndex()
		 */
		override public function getChildIndex (child:DisplayObject):int {
			return this.reverseIndex(super.getChildIndex(child));
		}
		
		/**
		 * Removes a child DisplayObject from the specified index position in the child list of the DisplayObjectContainer.
		 * 
		 * @param	index	The child index of the DisplayObject to remove.
		 * 
		 * @return	The DisplayObject instance that was removed.
		 * 
		 * @see		mx.containers.ViewStack#removeChildAt()
		 */
		override public function removeChildAt (index:int):DisplayObject {
			this.unregisterChildAt(index);
			return super.removeChildAt(this.reverseIndex(index));
		}
		/**
		 * Removes a child DisplayObject from the child list of this Container.
		 * 
		 * @param	child	The DisplayObject to remove.
		 * 
		 * @return	The DisplayObject instance that was removed.
		 * 
		 * @see		mx.containers.ViewStack#removeChild()
		 */
		override public function removeChild (child:DisplayObject):DisplayObject {
			this.unregisterChildAt(this.getChildIndex(child));
			return super.removeChild(child);
		}
		/**
		 * Clears a child to be removed of event listeners added by this class and refreshes visuals.
		 * 
		 * @param	index	The index of the DisplayObject to be removed.
		 * 
		 * @see		SuperViewStack#removeChild()
		 * @see		SuperViewStack#removeChildAt()
		 * 
		 * @private
		 */
		protected function unregisterChildAt (index:int):void {
			var child:DisplayObject = this.getChildAt(index);
			
			child.removeEventListener(FlexEvent.CREATION_COMPLETE, this.childCreationComplete);
			
			if (this._childrenCreated){
				if (index < this.selectedIndex) this._selectedIndex--;
				this.applyFade();
				this.showChildren();
			}
		}
		
		/**
		 * Changes the position of an existing child in the display object container.
		 * 
		 * @param	child	The child DisplayObject instance for which you want to change the index number.
 		 * @param	index	The resulting index number for the child display object.
		 * 
		 * @see		mx.containers.ViewStack#setChildIndex()
		 */
		override public function setChildIndex(child:DisplayObject, index:int):void {
			super.setChildIndex(child, this.reverseIndex(index));
		}
		
		/**
		 * Swaps the z-order (front-to-back order) of the child objects at the two specified index positions in the child list.
		 * 
		 * @param	index1	The index position of the first child object.
		 * @param	index2	The index position of the second child object.
		 * 
		 * @see		mx.containers.ViewStack#swapChildrenAt()
		 */
		override public function swapChildrenAt (index1:int, index2:int):void {
			index1 = this.reverseIndex(index1);
			index2 = this.reverseIndex(index2);
			super.swapChildrenAt(index1, index2);
		}
		
		/**
		 * Removes all children from the child list of this container.
		 * 
		 * @see		mx.containers.ViewStack#removeAllChildren()
		 */
		override public function removeAllChildren ():void {
			super.removeAllChildren();
			this._selectedIndex = -1;
		}
		
		
	// CUSTOM:
		
		/**
		 * Set visibility to true for the children underneath selectedChild (and selectedChild itself), false for the rest.
		 * 
		 * @private
		 */
		protected function showChildren ():void {
			
			for (var i:uint=0; i<this.numChildren; i++){
				var child:Container = super.getChildAt(i) as Container;
				if (this._fade == 1.0){
					child.visible = (i == this._selectedIndex);
				}else{
					child.visible = (i <= this._selectedIndex);
				}
			}
			
			// make sure fading is adjusted:
			this.applyFade();
			
		}
		
		/**
		 * Creates an empty Shape (for the fade to be drawn on) inside a child.
		 * 
		 * @param	child	Child of this SuperViewStack instance
		 * 
		 * @private
		 */
		protected function drawFade (child:Container):void {
			
			var shape:Shape = new Shape();
			shape.name = SuperViewStack.FADESHAPE_NAME;
			child.rawChildren.addChild(shape);
			
		}
		
		/**
		 * Sizes of resizes the Shape in which the fade is drawn, called by childCreationComplete()
		 * 
		 * @param	child	Child of this SuperViewStack instance whose fade Shape to resize.
		 * 
		 * @see		SuperViewStack#childCreationComplete()
		 * 
		 * @private
		 */
		protected function resizeFade (child:Container):void {
			
			// point out the Shape:
			var shape:Shape = child.rawChildren.getChildByName(SuperViewStack.FADESHAPE_NAME) as Shape;
			
			// size and position:
			shape.x = -child.x;
			shape.y = -child.y;
			shape.width = child.getExplicitOrMeasuredWidth();
			shape.height = child.getExplicitOrMeasuredHeight();
			
		}
		
		/**
		 * Loops through this SuperViewStack its children and draws a fade for each one.
		 * 
		 * @private
		 */
		protected function applyFade ():void {
			
			var child:Container;
			var shape:Shape;
			
			for (var i:uint=0; i<this.numChildren; i++){
				
				child = super.getChildAt(i) as Container;
				shape = child.rawChildren.getChildByName(SuperViewStack.FADESHAPE_NAME) as Shape;
				
				shape.visible = (this._fade != 0);
				if (!shape.visible) continue;
				
				shape.graphics.clear();
				if (i != this._selectedIndex){
					shape.graphics.beginFill(this._fadeColor, this._fade);
					shape.graphics.drawRect(0, 0, 100, 100);
					shape.graphics.endFill();
				}
				
			}
			
		}
		
		/**
		 * Returns the reverse value of a specified index.
		 * 
		 * @param	index	Index (uint) for a specific child
		 * 
		 * @return	Reverse value (uint) of the specified index
		 * 
		 * @private
		 */
		protected function reverseIndex (value:uint):uint {
			return this.numChildren - 1 - value;
		}
		
		
	// ACCESSORS:
		
		/**
		 * The zero-based index of the currently visible child container.
		 * 
		 * @copy	mx.containers.ViewStack#selectedIndex
		 * @see		mx.containers.ViewStack#selectedIndex
		 */
		public function get selectedIndex ():uint {
			var index:uint = (this._selectedIndex != -1) ? this._selectedIndex : 0;
			return this.reverseIndex(index);
		}
		public function set selectedIndex (value:uint):void {
			// delay if necessary:
			if (!this._childrenCreated){
				callLater(function(value:uint):void{
					selectedIndex = value;
				}, [value]);
				return;
			}
			
			// store old value:
			var event:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.CHANGE);
			event.oldIndex = this.selectedIndex;
			
			// make sure value is within bounds:
			if (value < 0) value = 0;
			if (value > this.numChildren-1) value = this.numChildren-1;
			
			// reverse value:
			value = this.reverseIndex(value);
			
			// return if there is no change:
			if (this._selectedIndex == value) return;
			
			// set internal and refresh children:
			this._selectedIndex = value;
			this.showChildren();
			
			// store new value and dispatch event:
			event.newIndex = this.selectedIndex;
			event.relatedObject = this.selectedChild;
	        dispatchEvent(event);
		}
		
		/**
		 * A reference to the currently visible child container.
		 * 
		 * @copy	mx.containers.ViewStack#selectedChild
		 * @see		mx.containers.ViewStack#selectedChild
		 */
		public function get selectedChild ():Container {
			return super.getChildAt(this._selectedIndex) as Container;
		}
		public function set selectedChild (child:Container):void {
			this.selectedIndex = this.getChildIndex(child);
		}
		
		/**
		 * Degree to which a child should be faded if it's underneath another visible child.
		 *  Values range from 0.0 (completely transparent) to 1.0 (no transparency), defaults to 0.6.
		 */
		public function get fade ():Number {
			return this._fade;
		}
		public function set fade (value:Number):void {
			// make sure value is within bounds:
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			// return if there is no change:
			if (this._fade == value) return;
			// switch back to SuperViewStack behavior (if necessary):
			this.behavior = SuperViewStack.SUPER;
			// set internal and refresh children:
			this._fade = value;
			this.showChildren();
		}
		
		/**
		 * First value in __fade (Array), indicating the transparency of fades
		 * 
		 * @private
		 */
		protected function get _fade ():Number {
			return this.__fade[0];
		}
		/**
		 * @private
		 */
		protected function set _fade (value:Number):void {
			this.__fade[0] = value;
		}
		
		/**
		 * Color with which to fade a child, defaults to white (0xFFFFFF).
		 */
		public function get fadeColor ():uint {
			return this._fadeColor;
		}
		public function set fadeColor (value:uint):void {
			// switch back to SuperViewStack behavior (if necessary):
			this.behavior = SuperViewStack.SUPER;
			// set internal and refresh children:
			this._fadeColor = value;
			this.applyFade();
		}
		
		/**
		 * Behavior of this SuperViewStack. Can be adjusted during runtime.
		 *  Values can be either SuperViewStack.SUPER or SuperViewStack.NORMAL.
		 *  If normal, the SuperViewStack will act like the classic ViewStack.
		 * 
		 * @see		SuperViewStack#BEHAVIOR_CHANGED
		 * @see		SuperViewStack#SUPER
		 * @see		SuperViewStack#NORMAL
		 */
		public function get behavior ():String {
			if (this._fade == 1.0){
				return SuperViewStack.NORMAL;
			}else{
				return SuperViewStack.SUPER;
			}
		}
		public function set behavior (value:String):void {
			if (value == this.behavior || (value != SuperViewStack.SUPER && value != SuperViewStack.NORMAL)){
				return;
			}
			this.__fade.reverse();
			this.showChildren();
			this.dispatchEvent(new Event(SuperViewStack.BEHAVIOR_CHANGED));
		}
		
		
	}
	
	
}