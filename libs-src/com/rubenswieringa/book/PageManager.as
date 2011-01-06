package com.rubenswieringa.book {
	
	
	import com.rubenswieringa.containers.SuperViewStack;
	import com.rubenswieringa.managers.StateManager;
	import com.rubenswieringa.utils.ChildTool;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.events.CollectionEvent;
	
	use namespace limited;
	
	
	/**
	 * Dispatched when a page is added to or removed from the PageManager.
	 * @eventType	com.rubenswieringa.book.BookEvent.CONTENT_CHANGED
	 * @see			BookEvent#CONTENT_CHANGED
	 * @see			PageManager#pages
	 */
	[Event(name="contentChanged", type="com.rubenswieringa.book.BookEvent")]
	
	
	/**
	 * PageManager provides the core functionality for the Book class.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.1
	 * @see			Book Book
	 * @see			Page Page
	 * 
	 * 
	 * @internal
	 * 
	 * edit 5
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
	public class PageManager extends Canvas {
		
		
		/**
		 * Left-hand stack of Page instances.
		 * @private
		 */
		protected var pageL:SuperViewStack = new SuperViewStack();
		/**
		 * Left-hand stack of Page instances.
		 * @private
		 */
		protected var pageR:SuperViewStack = new SuperViewStack();
		/**
		 * Shape instance on which pageflips are drawn as BitmapData.
		 * @private
		 */
		protected var render:Shape = new Shape();
		
		// internals for accessors:
		/**
		 * @see	PageManager#openAt
		 * @private
		 */
		protected var _openAt:int = -1;
		/**
		 * @see	PageManager#currentPage
		 * @see	PageManager#_currentPage
		 * @private
		 */
		protected var __currentPage:int = -1;
		/**
		 * @see	PageManager#pages
		 * @private
		 */
		protected var _pages:ArrayCollection = new ArrayCollection;
		
		
	// CONSTRUCTOR:
		
		/**
		 * Constructor.
		 */
		public function PageManager ():void {
			super();
			
			StateManager.instance.register(this);
			
			this._pages.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.onContentChanged);
		}
		
		
	// LISTENERS:
		
		
		/**
		 * Listener-method for the collectionChange Event of the pages property.
		 * 
		 * @see		PageManager#pages
		 * 
		 * @private
		 */
		protected function onContentChanged (event:CollectionEvent):void {
			this.dispatchEvent(new BookEvent(BookEvent.CONTENT_CHANGED, this));
		}
		
		
	// OVERRIDES:
		
		/**
		 * @private
		 */
		override protected function updateDisplayList (unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this.refreshViewStacks();
		}
		
		
		/**
		 * Adds the ViewStacks for left and right, also adds a render Shape (for during pageflips).
		 * 
		 * @private
		 */
		override protected function createChildren ():void {
			
			super.createChildren();
			
			this.pageL.width =	this.pageR.width =	this.width / 2;
			this.pageL.height =	this.pageR.height =	this.height;
			
			this.pageL.fade = this.pageR.fade = 0;
			this.pageR.x = this.render.x = this.width / 2;
			
			this.rawChildren.addChild(this.pageL);
			this.rawChildren.addChild(this.pageR);
			this.rawChildren.addChild(this.render);
		}
		
		
		/**
		 * Sets startup-values and checks for an even amount of Pages.
		 * 
		 * @private
		 */
		override protected function childrenCreated ():void {
			super.childrenCreated();
			
			// if the amount of Pages is uneven, add another Page:
			if (this._pages.length%2 == 1){
				var page:Page = new Page();
				this.addChild(page);
			}
			
			// set startup properties:
			this.openAt = this._openAt;
			this._currentPage = this._openAt;
			
			// activate children:
			this.refreshViewStacks();
		}
		
		
		/**
		 * Adds a child Page instance to this PageManager instance. Regardless of this method's signiature, the child parameter must always be an instance of the Page class.
		 * 
		 * @param	child	The Page instance to add as a child of this PageManager instance.
		 * 
		 * @return	The Page instance that you pass in the child parameter.
		 * 
		 * @throws	BookError	Gets thrown when the child parameter is not an instance of the Page class.
		 * @see		BookError#CHILD_NOT_PAGE
		 * 
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			return this.addChildAt(child, this._pages.length);
		}
		/**
		 * Adds a child Page instance to this PageManager instance at the index position specified.
		 * 
		 * @param	child	The Page instance to add as a child of this PageManager instance.
		 * @param	index	The index position to which the child is added.
		 * 
		 * @return	The Page instance that you pass in the child parameter.
		 * 
		 * @throws	BookError	Gets thrown when the child parameter is not an instance of the Page class.
		 * @see		BookError#CHILD_NOT_PAGE
		 * 
		 */
	  	override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			// only allow children that are instances of the Page class:
			if (child is Page){
				var page:Page = Page(child);
				// correct index so that it is within bounds:
				if (index < 0)					index = 0;
				if (index > this._pages.length)	index = this._pages.length;
				// initialize Page:
				this.initPage(page, index);
				// add Page to left or right ViewStack:
				if (index%2 == 1){
					this.pageL.addChildAt(child, this.generateStackIndex(page));
				}else{
					this.pageR.addChildAt(child, this.generateStackIndex(page));
				}
				// make sure all other Pages are in the right ViewStacks:
				if (index < this._pages.length-1){
					this.jumpViewStacks(index+1);
				}
				if (StateManager.instance.getState(this) == StateManager.UPDATE_COMPLETE){
					this.refreshViewStacks();
				}
				// return value:
				return page;
			}else{
				throw new BookError(BookError.CHILD_NOT_PAGE);
			}
		}
		
		
		/**
		 * Removes all children (Page instances) from the child list of this container.
		 */
		override public function removeAllChildren ():void {
			// remove all Pages children from ViewStacks:
			this.pageL.removeAllChildren();
			this.pageR.removeAllChildren();
			// clear book property of Pages:
			for (var i:int=0; i<this._pages.length; i++){
				Page(this._pages.getItemAt(i)).setBook(null);
			}
			// reset properties:
			this._pages = new ArrayCollection();
			this._currentPage = -1;
			// refresh ViewStacks:
			this.refreshViewStacks();
		}
		/**
		 * Removes a child Page from the child list of this Container.
		 * 
		 * @param	child	The Page instance to remove.
		 * 
		 * @return	The removed child.
		 * 
		 * @throws	BookError		Gets thrown when the child parameter is not an instance of the Page class.
		 * @see		BookError#CHILD_NOT_PAGE
		 * 
		 * @throws	ArgumentsError	Gets thrown when the child parameter is not a child of this PageManager.
		 * @see		BookError#PAGE_NOT_CHILD
		 * 
		 */
		override public function removeChild (child:DisplayObject):DisplayObject {
			// only instances of the Page class are allowed as children:
			if (child is Page){
				var index:int = this._pages.getItemIndex(child);
				if (Page(child).book != this || index == -1){
					throw new ArgumentError(BookError.PAGE_NOT_CHILD);
				}
				return this.removeChildAt(index);
			}else{
				throw new BookError(BookError.CHILD_NOT_PAGE);
			}
		}
		/**
		 * Removes a child Page from the child list of this Container at the specified index.
		 * 
		 * @param	index	The child index of the Page to remove.
		 * 
		 * @return	The removed child.
		 * 
		 * @throws	ArgumentError	Gets thrown when the supplied index is out of bounds.
		 * @see		BookError#OUT_OF_BOUNDS
		 * 
		 */
		override public function removeChildAt (index:int):DisplayObject {
			// throw error if index is out of bounds:
			if (index < 0 || index > this._pages.length-1){
				throw new ArgumentError(BookError.OUT_OF_BOUNDS);
			}
			// define Page:
			var page:Page = Page(this._pages.getItemAt(index));
			// remove Page from left or right ViewStack:
			if (index%2 == 1){
				this.pageL.removeChild(page);
			}else{
				this.pageR.removeChild(page);
			}
			// remove Page from Array and clear book property:
			this._pages.removeItemAt(index);
			page.setBook(null);
			// adjust _currentPage if necessary:
			if (this._currentPage > this._pages.length-1){
				this._currentPage -= 2;
			}
			// make sure all other Pages are in the right ViewStacks:
			if (index <= this._pages.length-1){
				this.jumpViewStacks(index);
			}
			if (StateManager.instance.getState(this) >= StateManager.UPDATE_COMPLETE){
				this.refreshViewStacks();
			}
			
			// return value:
			return page;
		}
		
		
		/**
		 * Changes the position of an existing child in the PageManager container.
		 * 
		 * @param	child	The child Page instance for which you want to change the index number.
		 * @param	index	The resulting index number for the child display object.
		 * 
		 * @throws	BookError	Gets thrown when the child parameter is not an instance of the Page class.
		 * @see		BookError#CHILD_NOT_PAGE
		 * 
		 * @throws	ArgumentsError	Gets thrown when the child parameter is not a child of this PageManager.
		 * @see		BookError#PAGE_NOT_CHILD
		 * 
		 */
		override public function setChildIndex (child:DisplayObject, newIndex:int):void {
			// only instances of the Page class are allowed as children:
			if (child is Page){
				if (Page(child).book != this || Page(child).index == -1){
					throw new ArgumentError(BookError.PAGE_NOT_CHILD);
				}
				this.removeChild(child);
				this.addChildAt(child, newIndex);
				Page(child).refreshFoldGradient();
			}else{
				throw new BookError(BookError.CHILD_NOT_PAGE);
			}
		}
		/**
		 * Swaps the position of two Page instances in the PageManager.
		 * 
		 * @param	child1	The first child object.
		 * @param	child2	The second child object.
		 * 
		 * @throws	BookError	Gets thrown when the child parameter is not an instance of the Page class.
		 * @see		BookError#CHILD_NOT_PAGE
		 * 
		 * @throws	ArgumentsError	Gets thrown when the child parameter is not a child of this PageManager.
		 * @see		BookError#PAGE_NOT_CHILD
		 * 
		 */
		override public function swapChildren (child1:DisplayObject, child2:DisplayObject):void {
			if (child1 is Page && child2 is Page){ // if both children are Pages, treat them special
				var index1:int = Page(child1).index;
				var index2:int = Page(child2).index;
				if (Page(child1).book != this || index1 == -1 || Page(child2).book != this || index2 == -1){
					throw new ArgumentError(BookError.PAGE_NOT_CHILD);
				}
				ChildTool.swapChildren(child1, child2);
				this._pages.setItemAt(child2, index1);
				this._pages.setItemAt(child1, index2);
				this.refreshViewStacks();
				Page(child1).refreshFoldGradient();
				Page(child2).refreshFoldGradient();
			}else{ // if children are not both Pages, then they don't belong to the externally visible part of this instance:
				throw new BookError(BookError.CHILD_NOT_PAGE);
			}
		}
		/**
		 * Swaps the position of two Page instances in the PageManager at the specified indexes.
		 * 
		 * @param	index1	The index position of the first child object.
		 * @param	index2	The index position of the second child object.
		 * 
		 */
		override public function swapChildrenAt (index1:int, index2:int):void {
			this.swapChildren(Page(this._pages.getItemAt(index1)), Page(this._pages.getItemAt(index2)));
		}
		
		
		/**
		 * Returns the child display object that exists with the specified name.
		 * 
		 * @param	name	The name of the child to return.
		 * 
		 * @return	The child Page with the specified name as a DisplayObject. You may want to cast the return value of this method back to a Page.
		 * 
		 */
		override public function getChildByName (name:String):DisplayObject {
			// see if child with provided name is in either one of the ViewStacks:
			var child:Page;
			for (var i:int=0; i<this._pages.length; i++){
				child = Page(this._pages.getItemAt(i));
				if (child.name == name){
					return child;
				}
			}
			// if not, return null:
			return null;
		}
		/**
		 * Returns the index position of a child Page instance.
		 * 
		 * @param	child	The Page instance to identify.
		 * 
		 * @return	The index position of the child Page to identify.
		 * 
		 */
		override public function getChildIndex (child:DisplayObject):int {
			return this._pages.getItemIndex(child);
		}
		/**
		 * Returns an Array of Page objects consisting of the content children of the container. Note that this method returns the source property of the pages property.
		 * 
		 * @return	Array of Page objects consisting of the content children of the container.
		 * 
		 * @see		PageManager#pages
		 * 
		 */
		override public function getChildren ():Array {
			return this._pages.source;
		}
		/**
		 * Returns an array of objects that lie under the specified point and are children (or grandchildren, and so on) of this PageManager instance.
		 * 
		 * @param	point	The point under which to look.
		 * 
		 * @return	An array of objects that lie under the specified point and are children (or grandchildren, and so on) of this PageManager instance.
		 * 
		 */
		override public function getObjectsUnderPoint (point:Point):Array {
			var pagesL:Array = this.pageL.getObjectsUnderPoint(point);
			var pagesR:Array = this.pageR.getObjectsUnderPoint(point);
			return pagesL.concat(pagesR);
		}
		
		
		/**
		 * Determines whether the specified display object is a child of the PageManager instance or the instance itself.
		 * 
		 * @param	child	The child object to test.
		 * 
		 * @return	true if the child object is a child of the PageManager or the container itself; otherwise false.
		 * 
		 */
		override public function contains (child:DisplayObject):Boolean {
			return (this.pageL.contains(child) || this.pageR.contains(child) || child == this);
		}
		/**
		 * Returns true if the chain of owner properties points from child to this PageManager.
		 * 
		 * @param	child	A UIComponent.
		 * 
		 * @return	true if the child is parented or owned by this PageManager.
		 * 
		 */
		override public function owns (child:DisplayObject):Boolean {
			return (this.pageL.owns(child) || this.pageR.owns(child));
		}
		
		
	// COMMON USAGE:
		
		
		/**
		 * Sets standard settings (such as width and height) for Page instances, typically called by addChildAt().
		 * 
		 * @see		PageManager#addChildAt()
		 * 
		 * @param	page	Page of which to set the settings.
		 * @param	index	Index at which to insert this Page into the pages ArrayCollection.
		 * 
		 * @return	Page passed as a parameter, with settings set.
		 * 
		 * @private
		 */
		protected function initPage (page:Page, index:int):void {
			// set properties:
			page.setBook(this);
			page.width =	this.width / 2;
			page.height =	this.height;
			// add Page to Array:
			this._pages.addItemAt(page, index);
		}
		
		
		/**
		 * Calculates the relative index at which a Page should be added to either one of the two ViewStacks. Not to be confused with the absolute index used in the pages property.
		 * 
		 * @param	page	Page for which to calculate the relative index.
		 * 
		 * @return	Relative index for the provided Page.
		 * 
		 * @private
		 */
		protected function generateStackIndex (page:Page):int {
			var index:int = this._pages.getItemIndex(page);
			if (index%2 == 1){
				return Math.ceil(this._pages.length/2)-Math.ceil(index/2);
			}else{
				return index/2;
			}
		}
		
		
		/**
		 * Makes all Page instances above (or equal to) the provided index switch ViewStacks. Called, for example, by addChildAt because when a new Page is inserted lefthand-side Pages become righthand-side Pages, etc.
		 * 
		 * @param	fromIndex	Absolute index (indicating the Page its position in the pages property) from which to start switching ViewStacks.
		 * 
		 * @private
		 */
		protected function jumpViewStacks (fromIndex:int):void {
			var page:Page;
			for (var i:int=fromIndex; i<this._pages.length; i++){
				page = Page(this._pages.getItemAt(i))
				if (page.side != Page.LEFT){
					ChildTool.moveChild(page, this.pageR, this.generateStackIndex(page));
				}else{
					ChildTool.moveChild(page, this.pageL, this.generateStackIndex(page));
				}
			}
		}
		
		
		/**
		 * Displays the appropriate Pages in the two ViewStacks.
		 * 
		 * @private
		 */
		protected function refreshViewStacks ():void {
			
			this.pageL.visible = ((!this.isFirstPage(this._currentPage+1) || this._pages.length <= 1) && this.pageL.numChildren > 0);
			if (this.pageL.visible){
				this.pageL.selectedChild = Page(this._pages.getItemAt(this._currentPage));
			}
			this.pageL.invalidateDisplayList();
			
			this.pageR.visible = ((!this.isLastPage(this._currentPage) || this._pages.length <= 1) && this.pageR.numChildren > 0);
			if (this.pageR.visible){
				this.pageR.selectedChild = Page(this._pages.getItemAt(this._currentPage+1));
			}
			this.pageR.invalidateDisplayList();
			
		}
		
		
		/**
		 * Returns true if the provided Page is the first Page in the Array, false if otherwise.
		 * 
		 * @param	page	int/uint or Page, indicating the index or instance of a Page.
		 * 
		 * @return	Boolean indicating whether or not the Page is the first in line.
		 * 
		 * @throws	ArgumentsError	Gets thrown when the page parameter is a Page but not a child of this PageManager.
		 * @see		BookError#PAGE_NOT_CHILD
		 * 
		 * @private
		 */
		protected function isFirstPage (page:*):Boolean {
			page = this.getPage(page, false);
			return (page != null && page.index == 0);
		}
		/**
		 * Returns true if the provided Page is the last Page in the Array, false otherwise.
		 * 
		 * @param	page	int/uint or Page, indicating the index or instance of a Page.
		 * 
		 * @return	Boolean indicating whether or not the Page is the last in line.
		 * 
		 * @throws	ArgumentsError	Gets thrown when the page parameter is a Page but not a child of this PageManager.
		 * @see		BookError#PAGE_NOT_CHILD
		 * 
		 * @private
		 */
		protected function isLastPage (page:*):Boolean {
			page = this.getPage(page, false);
			return (page != null && page.index == this._pages.length-1);
		}
		
		
		/**
		 * Takes an index or Page instance and returns it as a Page instance.
		 * 
		 * @param	page	int/uint or Page, indicating the index or instance of a Page to be returned.
		 * @param	varify	If true, this method will throw an Error if page is an out-of-bounds index or a Page that is not a child of this PageManager. If false, the method will return null under the previously described circumstances.
		 * 
		 * @return	Page
		 * 
		 * @private
		 */
		protected function getPage (page:*, varify:Boolean=false):Page {
			// throw Error if page is not a Page instance nor a numeric variable:
			if (!(page is Page) && !(page is int) && !(page is uint)){
				throw new BookError(BookError.CHILD_NOT_PAGE);
			}
			// if page is numeric, transform it into a Page:
			if (!(page is Page)){
				// throw Error if index is out of bounds:
				if (page < 0 || page >= this._pages.length){
					if (varify && page != -1){ // even though -1 is not a valid index, it does virtually indicate a Page
						throw new ArgumentError(BookError.OUT_OF_BOUNDS);
					}else{
						page = null;
					}
				}else{
					page = Page(this._pages.getItemAt(page));
				}
			}
			// throw Error if Page its parent is not this PageManager instance:	
			if (page != null && page.book != this){
				throw new ArgumentError(BookError.PAGE_NOT_CHILD);
			}
			// return index:
			return page;
		}
		/**
		 * Takes an index or Page instance and returns it as the index of a Page instance.
		 * 
		 * @param	page	int/uint or Page, indicating the index or instance of a Page-index to be returned.
		 * @param	varify	If true, this method will throw an Error if page is an out-of-bounds index or a Page that is not a child of this PageManager. If false, the method will return null under the previously described circumstances.
		 * 
		 * @return	int
		 * 
		 * @private
		 */
		protected function getPageIndex (page:*, varify:Boolean=false):int {
			page = this.getPage(page, varify);
			return (page == null) ? -1 : page.index;
		}
		
		
	// ACCESSORS:
		
		
		/**
		 * Flag indicating whether the instance has reached the creationComplete state.
		 * @private
		 */
		protected function get created ():Boolean {
			return (StateManager.instance.getState(this) >= StateManager.CREATION_COMPLETE);
		}
		
		
		/**
		 * Index of the current left-hand page (-1 if the Book is unopened).
		 */
		[Bindable(event='currentPageChanged')]
		public function get currentPage ():int {
			return this._currentPage;
		}
		
		
		/**
		 * Internet accessor for the public currentPage property.
		 * @see	PageManager#currentPage
		 * @see	http://www.rubenswieringa.com/blog/binding-read-only-accessors-in-flex Rubens blog: Binding read-only accessors in Flex
		 * @private
		 */
		protected function set _currentPage (value:int):void {
			if (this._currentPage == value){
				return;
			}
			this.__currentPage = value;
			this.dispatchEvent(new Event(BookEvent.CURRENTPAGE_CHANGED));
		}
		/**
		 * @private
		 */
		protected function get _currentPage ():int {
			return this.__currentPage;
		}
		
		
		/**
		 * Index of the Page at which the Book is opened at startup, can only be set once, and only at startup.
		 * @default	-1
		 */
		public function get openAt ():int {
			return this._openAt;
		}
		public function set openAt (value:int):void {
			if (value < -1){
				value = -1;
			}
			if (value > this._pages.length-1 && this._pages.length > 0){
				value = this._pages.length-1;
			}
			if (value % 2 == 0){
				value--;
			}
			this._openAt = value;
		}
		
		
		/**
		 * Array of all respective Pages in this Book instance.
		 */
		[Bindable(event='contentChanged')]
		public function get pages ():ArrayCollection {
			return this._pages;
		}
		
		
	}
	
	
}