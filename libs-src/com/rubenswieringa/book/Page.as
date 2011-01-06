package com.rubenswieringa.book {
	
	
	import com.rubenswieringa.geom.*;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.core.FlexGlobals;
	import mx.core.ScrollPolicy;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	
	/**
	 * Dispatched when this Page its index changes (triggered by change in the pages property of the accompanying PageManager).
	 * @eventType	com.rubenswieringa.book.Page.INDEX_CHANGED
	 * @see			Page#INDEX_CHANGED
	 * @see			Page#index
	 * @see			PageManager#pages
	 * @private
	 */
	[Event(name="indexChanged", type="flash.events.Event")]
	
	
	/**
	 * A container class that stores contents of a page in the Book class.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			Book Book
	 * 
	 * 
	 * @internal
	 * 
	 * edit 4
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/Book/docs/
	 * 
	 * 
	 * Copyright (c) 2005 Ruben Swieringa. All rights reserved.
	 * 
	 * This class is part of the Book component, which is licensed under the CREATIVE COMMONS Attribution 3.0 Unported.
	 *   You may not use this file except in compliance with the License.
	 *   You may obtain a copy of the License at:
	 *   http://creativecommons.org/licenses/by/3.0/deed.en
	 * 
	 */
	public class Page extends Canvas {
		
		
		/**
		 * @private
		 */
		protected static const DEFAULT_STYLES:Object = { backgroundColor: 0xFFFFFF, backgroundAlpha: 0.3 };
		/**
		 * @private
		 */
		protected static var classConstructed:Boolean = Page.classConstruct();
		
		// internals accessors:
		/**
		 * @see	Page#tearable
		 * @private
		 */
		protected var _tearable:Boolean = false;
		/**
		 * @see	Page#hard
		 * @private
		 */
		protected var _hard:Boolean = false;
		/**
		 * @see	Page#gradients
		 * @private
		 */
		protected var _gradients:Gradients;
		/**
		 * @see	Page#book
		 * @private
		 */
		protected var _book:Book;
		/**
		 * @private
		 */
		protected var _shape:Shape = new Shape();
		/**
		 * @see	Page#liveBitmapping
		 * @private
		 */
		protected var _liveBitmapping:Boolean = false;
		/**
		 * @see	Page#index
		 * @private
		 */
		protected var _index:int = -1;
		
		// plain var properties:
		/**
		 * If true, this Page can not be flipped over.
		 * @default	false
		 */
		public var lock:Boolean = false;
		
		// constants:
		public static const LEFT:uint = 0;
		public static const RIGHT:uint = 1;
		/**
		 * @private
		 */
		protected static const INDEX_CHANGED:String = "indexChanged";
		
		
	// CONSTRUCTOR:
		
		
		/**
		 * Constructor
		 */
		public function Page ():void {
			super();
			
			this._gradients = new Gradients(this);
			
			// disable scrolling to force this Page its fold-gradient to remain in place (this issue may be addressed in future versions):
			super.horizontalScrollPolicy	= ScrollPolicy.OFF;
			super.verticalScrollPolicy		= ScrollPolicy.OFF;
		}
		
		
		/**
		 * Static style initializer. Sets default style settings for all Page instances. Executed only once.
		 * 
		 * @see	http://livedocs.adobe.com/flex/201/html/skinstyle_149_8.html
		 * @see	Page#classConstructed
		 * @see	Page#DEFAULT_STYLES
		 * 
		 * @private
		 */
		protected static function classConstruct ():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("Page")){
				var defaultStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
		 		for (var i:String in DEFAULT_STYLES){
					defaultStyles.setStyle(i, DEFAULT_STYLES[i]);
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("Page", defaultStyles, true);
			}
			return true;
		}
		
		
	// OVERRIDES:
		
		
		/**
		 * Adds additional children
		 * 
		 * @private
		 */
		override protected function childrenCreated ():void {
			this.rawChildren.addChild(this._shape);
		}
		
		
	// CUSTOM:
		
		
		/**
		 * Draws itself on a BitmapData instance and returns it.
		 * 
		 * @return	BitmapData
		 */
		public function getBitmapData ():BitmapData {
			var bmd:BitmapData = new BitmapData(this.width, this.height, true, 0x00ffffff);
			bmd.draw(this);
			return bmd;
		}
		
		
		/**
		 * Draws a gradient on the folding-side of the page.
		 */
		public function drawFoldGradient ():void {
			var tint:String = (this.side == Page.LEFT) ? Gradients.LIGHT : Gradients.DARK;
			var rotate:Number = (this.side == Page.LEFT) ? Gradients.ROTATE_FULL : Gradients.ROTATE_HALF;
			this._shape.graphics.clear();
			this._gradients.drawFold(this._shape.graphics, tint, rotate);
		}
		/**
		 * Erases the gradient on the folding-side of the page.
		 */
		public function clearFoldGradient ():void {
			this._shape.graphics.clear();
		}
		/**
		 * Hides fold-gradient.
		 */
		public function hideFoldGradient ():void {
			this._shape.visible = false;
		}
		/**
		 * Shows fold-gradient.
		 */
		public function showFoldGradient ():void {
			this._shape.visible = true;
		}
		/**
		 * Erase or draw fold gradient for this Page and the Page on the flipside (if includeFlipSide is true).
		 * 
		 * @param	includeFlipSide	Boolean indicating whether or not to draw the fold-gradient for this Page its flipside.
		 * 
		 */
		public function refreshFoldGradient (includeFlipSide:Boolean=true):void {
			// if flipside isn't available yet then don't bother trying to reach it:
			var flipSide:Page = this.getFlipSide();
			if (flipSide == null){
				includeFlipSide = false;
			}
			// refresh fold-gradients:
			if (this.hard){
				this.clearFoldGradient();
				if (includeFlipSide){
					flipSide.clearFoldGradient();
				}
			}else{
				this.drawFoldGradient();
				if (includeFlipSide){
					flipSide.drawFoldGradient();
				}
			}
		}
		
		
		/**
		 * Tears this Page instance out of its corresponding Book.When called, this method will be executed regardless of the tearable property its value.
		 * 
		 * @param	fromTop	If true, the Page will be torn out by its upper outer corner, if false by its lower outer corner.
		 * 
		 * @see		Book#tearPage()
		 * @see		Page#tearable
		 * 
		 * @throws	BookError	Gets thrown when page is an index-value and out of bounds.
		 * @see		BookError#OUT_OF_BOUNDS
		 * 
		 */
		public function tear (fromTop:Boolean=true):void {
			this._book.tearPage(this, fromTop);
		}
		
		
		/**
		 * Returns the Page instance that is displayed on the other side of this Page.
		 * 
		 * @return	Page
		 */
		public function getFlipSide ():Page {
			if (this.index == -1){
				return null;
			}
			var i:int = (this.side == Page.LEFT) ? this.index - 1 : this.index + 1;
			if (i < 0 || i >= this._book.pages.length){
				return null;
			}
			return Page(this._book.pages.getItemAt(i));
		}
		
		
		/**
		 * Returns true if this is the first Page in the Book it belongs to, false otherwise.
		 * 
		 * @return	Boolean indicating whether or not the Page is the first in line
		 */
		public function isFirstPage ():Boolean {
			if (this._book == null){
				return false;
			}
			return (this._book.pages.length > 0 && this == this._book.pages.getItemAt(0));
		}
		/**
		 * Returns true if this is the last Page in the Book it belongs to, false otherwise.
		 * 
		 * @return	Boolean indicating whether or not the Page is the last in line
		 */
		public function isLastPage ():Boolean {
			if (this._book == null){
				return false;
			}
			return (this._book.pages.length > 0 && this == this._book.pages.getItemAt(this._book.pages.length-1));
		}
		
		
		/**
		 * Re-calculates the internal for the index property of this Page instance. Typically this method is used as a listener for the contentChanged Event of the accompanying PageManager.
		 * @see		BookEvent#CONTENT_CHANGED
		 * @see		Page#index
		 * @private
		 */
		protected function changeIndex (event:BookEvent=null):void {
			this._index = this._book.pages.getItemIndex(this);
			this.dispatchEvent(new Event(Page.INDEX_CHANGED));
		}
		
		
	// ACCESSORS:
		
		
		/**
		 * Gradients instance associated with this Page.
		 * @see	Gradients
		 * @private
		 */
		limited function get gradients ():Gradients {
			return this._gradients;
		}
		
		
		/**
		 * Book instance with which this Page is associated. Can only be set once.
		 * 
		 * @see	Book
		 * 
		 */
		public function get book ():Book {
			return this._book;
		}
		/**
		 * Sets the internal for the book property.
		 * @see		Page#book
		 * @private
		 */
		limited function setBook (value:PageManager):void {
			if (value == null){
				this._book.removeEventListener(BookEvent.CONTENT_CHANGED, this.changeIndex);
				this._book =  null;
			}else if (this._book != value && value is Book){
				this._book = Book(value);
				this._book.addEventListener(BookEvent.CONTENT_CHANGED, this.changeIndex);
			}
		}
		
		
		/**
		 * Indicates whether or not this Page should be hard (true) or flexible (false). Defaults to false. Returns true if either this Page or the flipside Page has is hard..
		 * @default	false
		 * @see		Page#explicitHard
		 */
		public function get hard ():Boolean {
			// if flipside has its hard property set to true then return true:
			var flipSide:Page = this.getFlipSide();
			if (flipSide != null && flipSide.explicitHard){
				return true;
			}
			// if none of the above were true then return this Page its hard property:
			return this.explicitHard;
		}
		public function set hard (value:Boolean):void {
			// return if there is no change in value:
			if (this._hard == value){
				return;
			}
			// set value:
			this._hard = value;
			// erase or draw fold gradient for this Page and the Page on the flipside:
			this.refreshFoldGradient();
		}
		/**
		 * Returns the hard option for this Page only, where the hard property returns true if either this Page or its flipside is hard.
		 * Unless you're modifying this class you will most likely not need to use this property.
		 * @default	false
		 * @see		Page#hard
		 */
		public function get explicitHard ():Boolean {
			// if hardCover is enabled in the corresponding Book and this is either the first or last Page then return true:
			if (this._book != null && this._book.hardCover && (this.isFirstPage() || this.isLastPage())){
				return true;
			}
			// if none of the above were true then return this Page its hard property:
			return this._hard;
		}
		
		
		/**
		 * Index of this Page within the pages property of the containing Book instance.
		 * 
		 * @see	Book#pages
		 * 
		 */
		[Bindable(event='indexChanged')]
		public function get index ():int {
			if (this._book == null){
				return -1;
			}
			return this._book.pages.getItemIndex(this);
		}
		
		
		/**
		 * Indicates whether or not this Page plays animation while being flipped.
		 * Note that enabling liveBitmapping may result in decreased performance.
		 * @default	false
		 * @see		Book#lifeBitmapping
		 */
		public function get liveBitmapping ():Boolean {
			if (this._book.liveBitmapping){
				return true;
			}else{
				return this._liveBitmapping;
			}
		}
		public function set liveBitmapping (value:Boolean):void {
			this._liveBitmapping = value;
		}
		
		
		/**
		 * int indicating on which side the Page is displayed (0=left, 1=right).
		 * 
		 * @see	Page#LEFT
		 * @see	Page#RIGHT
		 * 
		 */
		[Bindable(event='indexChanged')]
		public function get side ():int {
			if (this._index == -1){
				return -1;
			}else{
				return ((this._index+1) % 2);
			}
		}
		
		
		/**
		 * Indicates whether or not this Page should be allowed to be be torn from its Book, false if not. Defaults to false. Returns true if either this Page or its flipside Page has is tearable, or if the Book associated with this Page has its tearable property set to true.
		 * Note that even if a Page has its tearable property set to false, it can still be torn out of its Book with the tear() or tearPage() methods. This property merely indicates whether or not tearing can be achieved by dragging the page-corner manually.
		 * @default	false
		 * @see		Book#tearPage()
		 * @see		Page#tear()
		 * @see		Page#explicitTearable
		 */
		public function get tearable ():Boolean {
			return (!this.hard && (this.explicitTearable || this.getFlipSide().explicitTearable || this._book.tearable));
		}
		public function set tearable (value:Boolean):void {
			this._tearable = value;
		}
		/**
		 * Returns the tearable option for this Page only, where the tearable property returns true if either this Page or its flipside is tearable.
		 * Unless you're modifying this class you will most likely not need to use this property.
		 * @default	false
		 * @see		Page#tearable
		 */
		public function get explicitTearable ():Boolean {
			return this._tearable;
		}
		
		
		/**
		 * Disable scrolling to force this Page its fold-gradient to remain in place. Both scroll-policies have already been turned off in the constructor.
		 * This is an issue that may be addressed in future versions.
		 * @see		Page#verticalScrollPolicy
		 * @private
		 */
		override public function set horizontalScrollPolicy (value:String):void {
			// empty
		}
		/**
		 * Disable scrolling to force this Page its fold-gradient to remain in place. Both scroll-policies have already been turned off in the constructor.
		 * This is an issue that may be addressed in future versions.
		 * @see		Page#horizontalScrollPolicy
		 * @private
		 */
		override public function set verticalScrollPolicy (value:String):void {
			// empty
		}
		
	}
	
}