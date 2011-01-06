package com.rubenswieringa.utils {
	
	
	import com.rubenswieringa.utils.MathTool;
	
	
	/**
	 * Provides additional functionality for Arrays.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			MathTool
	 * 
	 * 
	 * edit 2
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/ArrayTool/docs/
	 * 
	 */
	public class ArrayTool {
		
		
		/**
		 * Constructor.
		 * @private
		 */
		public function ArrayTool ():void {}
		
		
		/**
		 * Adjusts all values in an Array.
		 * 
		 * @param	array		Array whose values to adjust
		 * @param	value		Value with which to increase, decrease, multiply, or divide a value from array with	
		 * @param	operator	Indicates how to adjust a value from array (addition, minus, multiplication, or division)
		 * 
		 * @see		MathTool#PLUS
		 * @see		MathTool#MINUS
		 * @see		MathTool#MULTIPLICATION
		 * @see		MathTool#DIVISION
		 * 
		 * @return	Array with adjusted values
		 */
		public static function adjustValues    (array:Array,
												value:*,
												operator:String="*"):Array {
			var newArray:Array = [];
			
			for (var i:String in array){
				switch (operator){
					case MathTool.PLUS : 
						newArray[i] = array[i] + value;
						break;
					case MathTool.MINUS : 
						newArray[i] = array[i] - value;
						break;
					case MathTool.MULTIPLICATION : 
						newArray[i] = array[i] * value;
						break;
					case MathTool.DIVISION : 
						newArray[i] = array[i] / value;
						break;
				}
			}
			
			return newArray;
		}
		
		
		/**
		 * Similar to ArrayUtil.getItemIndex(), this method searches an Array for an Object with a given property that has a certain value. Can also search for nested Objects.<br /><br />
		 * 
		 * @example	The following code returns 2:<br /><br />
		 * <code>var array:Array = [ {foo: {bar: 'value1'}}, {foo: {bar: 'value2'}}, {foo: {bar: 'value3'}} ];<br />
		 * var propChain:Array = ['foo', 'bar'];<br />
		 * var value:String = 'value3';<br />
		 * ArrayTool.getValueMatchIndex (array, propChain, value); // outputs 2</code>
		 * 
		 * @param	array		Array to search.
		 * @param	property	Property or property-chain to try every item in the Array for. This parameter can either be a String (normal property), Array (property-chain), or numeric value (array index).
		 * @param	value		Value to be found.
		 * 
		 * @return	Index of the item where the value was found on the end of the property chain.
		 */
		public static function getValueMatchIndex (array:Array, property:*, value:*):int {
			
			// if property param is neither an Array nor a String nor a numeric value, try to cast it to a String:
			if (!(property is Array) && !(property is String) && !(property is uint || property is int || property is Number)){
				property = String(property);
			}
			// now make sure that we have a chain of properties (in the form of an Array) to loop through:
			var propertyChain:Array;
			if (property is Array){
				propertyChain = property;
			}else{
				propertyChain = [property];
			}
			
			// loop through source Array:
			var path:*;
			for (var i:int=0; i<array.length; i++){
				path = array[i];
				// loop through property-chain:
				for (var j:int=0; j<propertyChain.length; j++){
					if (path.hasOwnProperty(propertyChain[j])){
						path = path[propertyChain[j]];
						if (j == propertyChain.length-1 && path == value){
							return i;
						}
					}else{
						break;
					}
				}
			}
			
			// if value was not found:
			return -1;
		}
		
		
		/**
		 * Returns a shallow copy of an Array.
		 * 
		 * @param	source	Array to be copied.
		 * 
		 * @param	Copied Array.
		 * 
		 * @see	http://livedocs.adobe.com/flex/201/html/10_Lists_of_data_166_5.html
		 * 
		 */
		public static function copy (source:Array):Array {
			var array:Array = [];
			for (var i:int=0; i<source.length; i++){
				array[i] = source[i];
			}
			return array;
		}
		
	}
	
	
}