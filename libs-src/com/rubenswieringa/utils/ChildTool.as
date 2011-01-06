package com.rubenswieringa.utils {
	
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	
	/**
	 * All-static class that provides additional functionality for adding and removing children to and from Containers.
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
	 */
	public class ChildTool {
		
		
		/**
		 * Constructor.
		 * @private
		 */
		public function ChildTool ():void {}
		
		
		/**
		 * Moves child1 to child2 its place and the other way around.
		 * 
		 * @param	child1	DisplayObject to move to child2's place.
		 * @param	child2	DisplayObject to move to child1's place.
		 * 
		 */
		public static function swapChildren (child1:DisplayObject, child2:DisplayObject):void {
			var parent1:DisplayObjectContainer = child1.parent;
			var parent2:DisplayObjectContainer = child2.parent;
			
			var index1:int = parent1.getChildIndex(child1);
			var index2:int = parent2.getChildIndex(child2);
			
			ChildTool.moveChild(child1, parent2, index2);
			ChildTool.moveChild(child2, parent1, index1);
		}
		
		
		/**
		 * Removes a DisplayObject from its parent and adds it to a new parent at a certain index (if provided).
		 * 
		 * @param	child		DisplayObject to move.
		 * @param	container	New parent for child.
		 * @param	index		Index at which to add child to container.
		 * 
		 */
		public static function moveChild (child:DisplayObject, container:DisplayObjectContainer, index:int=-1):void {
			// remove child from old parent:
			child.parent.removeChild(child);
			// add child to new parent:
			if (index == -1){
				child = container.addChild(child);
			}else{
				child = container.addChildAt(child, index);
			}
		}
		
		
	}
	
	
}