package com.rubenswieringa.book {
	
	
	import flash.events.Event;
	
	
	/**
	 * Event class specifying type property values for Events broadcasted by the Book class.
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
	 * edit 3
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
	public class BookEvent extends Event {
		
		
		/**
		 * @private
		 */
		protected var _pageManager:PageManager;
		/**
		 * @private
		 */
		protected var _page:Page;
		
		/**
		 * Dispatched when the the corner of a page is picked up.
		 */
		public static const PAGEFLIP_STARTED:String = "pageflipStarted";
		/**
		 * Dispatched when the corner of a page is released. Note that this Event is dispatched just before the page starts falling back in place.
		 * @see	BookEvent#PAGEFLIP_FINISHED
		 */
		public static const PAGEFLIP_ENDING:String = "pageflipEnding";
		/**
		 * Dispatched when a page falls back in place after being flipped. This Event is dispatched regardless of whether or not the page has been turned, or has fallen back into its original position.
		 * @see	BookEvent#PAGE_TURNED
		 */
		public static const PAGEFLIP_FINISHED:String = "pageflipFinished";
		/**
		 * Dispatched when the corner of a page is rolled over with the mouse.
		 * Only applicable if the hover property of the accompanying Book instance is set to true.
		 * @see	Book#hover
		 */
		public static const HOVER_STARTED:String = "hoverStarted";
		/**
		 * Dispatched when the corner of a page is rolled out of with the mouse. Note that this Event is dispatched just before the page starts falling back in place.
		 * Only applicable if the hover property of the accompanying Book instance is set to true.
		 * @see	Book#hover
		 * @see	BookEvent#HOVER_FINISHED
		 */
		public static const HOVER_ENDING:String = "hoverEnding";
		/**
		 * Dispatched when a page falls back in place after being rolled over with the mouse.
		 * Only applicable if the hover property of the accompanying Book instance is set to true.
		 * @see	Book#hover
		 */
		public static const HOVER_FINISHED:String = "hoverFinished";
		/**
		 * Dispatched when a pageflip is successful.
		 * @see	BookEvent#PAGE_NOT_TURNED
		 */
		public static const PAGE_TURNED:String = "pageTurned";
		/**
		 * Dispatched when a pageflip is not successful.
		 * @see	BookEvent#PAGE_TURNED
		 */
		public static const PAGE_NOT_TURNED:String = "pageNotTurned";
		/**
		 * Dispatched when a Page is torn out of its Book.
		 */
		public static const PAGE_TORN:String = "pageTorn";
		/**
		 * Dispatched at the same time as the page-turned, when the Book was previously closed, and the first or last Page was flipped successfully.
		 * @see	BookEvent#PAGE_TURNED
		 */
		public static const BOOK_OPENED:String = "bookOpened";
		/**
		 * Dispatched at the same time as the page-turned, when the Book was previously open, and the first or last Page was flipped successfully.
		 * @see	BookEvent#PAGE_TURNED
		 */
		public static const BOOK_CLOSED:String = "bookClosed";
		/**
		 * Book state indicating that no pageflip is currently being executed.
		 */
		public static const NOT_FLIPPING:String = "notFlipping";
		/**
		 * Dispatched when a page is added to or removed from the PageManager.
		 * @see	PageManager#pages
		 */
		public static const CONTENT_CHANGED:String = "contentChanged";
		/**
		 * Dispatched when the status of the Book changes.
		 * @see	Book#status
		 */
		public static const STATUS_CHANGED:String = "statusChanged";
		/**
		 * Dispatched when the value of a PageManager its currentPage property changes.
		 * @see	PageManager#currentPage
		 */
		limited static const CURRENTPAGE_CHANGED:String = "currentPageChanged";
		
		
		/**
		 * Creates a BookEvent object to pass as a parameter to event listeners.
		 * 
		 * @param	type		The type of the event, accessible as BookEvent.type.
		 * @param	bubbles		Determines whether the BookEvent object participates in the bubbling stage of the event flow.
		 * @param	cancelable	Determines whether the BookEvent object can be canceled.
		 * 
		 */
		public function BookEvent  (type:String,
									book:PageManager,
									page:Page=null,
									bubbles:Boolean=false,
									cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			this._pageManager = book;
			this._page = page;
		}
		
		
		/**
		 * Returns the PageManager instance associated with this BookEvent.
		 * @see		BookEvent#book
		 */
		public function get pageManager ():PageManager {
			return this._pageManager;
		}
		/**
		 * Returns the Book instance associated with this BookEvent (actually the PageManager instance casted to a Book type).
		 * @see		BookEvent#pageManager
		 */
		public function get book ():Book {
			return Book(this._pageManager);
		}
		/**
		 * Returns the Page instance associated with this BookEvent.
		 */
		public function get page ():Page {
			return this._page;
		}
		
		
	}
	
	
}