package com.rubenswieringa.managers {
	
	
	import mx.core.UIComponent;
	import mx.utils.ArrayUtil;
	import mx.events.FlexEvent;
	import flash.events.Event;
	
	
	/**
	 * Class that enables you to keep track of which state (creationComplete, childrenCreated, etc.) a certain component is in. Note that StateManager is a singleton class.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * 
	 * 
	 * edit 2
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/StateManager/docs/
	 * 
	 */
	public class StateManager {
		
		
		/**
		 * @private
		 */
		protected static var _instance:StateManager;
		/**
		 * @private
		 */
		protected var _items:Array = [];
		/**
		 * @private
		 */
		protected var _states:Array = [];
		
		
		/**
		 * @private
		 */
		protected static const STATES:Array = [BABY, PREINITIALIZE, INITIALIZE, CREATION_COMPLETE, UPDATE_COMPLETE];
		
		
		/**
		 * Indicates that a component has not reached the first state yet.
		 */
		public static const BABY:int = -1;
		/**
		 * State indicating that a component has begun with its initialization sequence.
		 */
		public static const PREINITIALIZE:int =  0;
		/**
		 * State indicating that a component has finished its construction and has all initialization properties set.
		 */
		public static const INITIALIZE:int =  1;
		/**
		 * State indicating that a component has finished its construction, property processing, measuring, layout, and drawing.
		 */
		public static const CREATION_COMPLETE:int =  2;
		/**
		 * State indicating that a component has had its commitProperties(), measure(), and updateDisplayList() methods called.
		 */
		public static const UPDATE_COMPLETE:int =  3;
		
		
		/**
		 * Constructor.
		 */
		public function StateManager ():void {
			// static class
		}
		
		
		/**
		 * Singleton instance.
		 */
		public static function get instance ():StateManager {
			if (StateManager._instance == null){
				StateManager._instance = new StateManager();
			}
			return StateManager._instance;
		}
		
		
		/**
		 * Registers the provided UIComponent with this StateManager so that the component its state will be available through the getState method.
		 * 
		 * @param	item	Component to register.
		 * 
		 * @see	StateManager#getState()
		 */
		public function register (item:UIComponent):void {
			// don't register if UIComponent is already registered:
			if (ArrayUtil.getItemIndex(item, this._items) != -1){
				return;
			}
			
			// add UIComponent to Arrays:
			this._items.push(item);
			this._states.push(StateManager.BABY);
			// add eventlisteners:
			item.addEventListener(FlexEvent.CREATION_COMPLETE, this.updateState);
			item.addEventListener(FlexEvent.INITIALIZE, this.updateState);
			item.addEventListener(FlexEvent.PREINITIALIZE, this.updateState);
			item.addEventListener(FlexEvent.UPDATE_COMPLETE, this.updateState);
		}
		
		
		/**
		 * Event-handler for the listeners that watch the state-changes of the registered components.
		 * 
		 * @private
		 */
		protected function updateState (event:Event=null):void {
			var item:UIComponent = this._items[ArrayUtil.getItemIndex(event.target, this._items)];
			// set state in Array:
			switch (event.type){
				case FlexEvent.CREATION_COMPLETE : 
					this.setState(item, StateManager.CREATION_COMPLETE);
					break;
				case FlexEvent.INITIALIZE : 
					this.setState(item, StateManager.INITIALIZE);
					break;
				case FlexEvent.PREINITIALIZE : 
					this.setState(item, StateManager.PREINITIALIZE);
					break;
				case FlexEvent.UPDATE_COMPLETE : 
					this.setState(item, StateManager.UPDATE_COMPLETE);
					break;
			}
			// remove listeners if last event was broadcasted:
			if (this.getState(item) == StateManager.LAST_STATE){
				item.removeEventListener(FlexEvent.CREATION_COMPLETE, this.updateState);
				item.removeEventListener(FlexEvent.INITIALIZE, this.updateState);
				item.removeEventListener(FlexEvent.PREINITIALIZE, this.updateState);
				item.removeEventListener(FlexEvent.UPDATE_COMPLETE, this.updateState);
			}
		}
		
		
		/**
		 * Returns a numeric value corresponding to one of the the constants in the StateManager class.
		 * 
		 * @param	item	Component of which to return the current state.
		 * 
		 * @return	Value indicating the current state of the provided UIComponent.
		 */
		public function getState (item:UIComponent):int {
			return this._states[ArrayUtil.getItemIndex(item, this._items)];
		}
		/**
		 * Sets the state of the provided UIComponent.
		 * 
		 * @param	item	Component of which to set the state.
		 * @param	state	Value indicating which state the provided UIComponent is in.
		 * 
		 * @private
		 */
		protected function setState (item:UIComponent, state:int):void {
			this._states[ArrayUtil.getItemIndex(item, this._items)] = state;
		}
		
		
		/**
		 * Array with all items registered with this class.
		 */
		public function get items ():Array {
			return this._items;
		}
		
		
		/**
		 * A reference to the last state (known to the StateManager class) a registered component can be in.
		 */
		public static function get LAST_STATE ():int {
			return StateManager.STATES[StateManager.STATES.length-1];
		}
		
		
	}
	
	
}