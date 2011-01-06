package com.rubenswieringa.geom {


	import flash.geom.*;
	
	import mx.geom.RoundedRectangle;
	
	/**
	 * Provides functionality for working with Rectangles. This class extends the RoundedRectangle class and thus has all of its functionality (and also the functionality of the Rectangle class, which RoundedRectangle extends).
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * 
	 * 
	 * edit 5b*
	 * 
	 * * This class is a slightly stripped-down version of the original SuperRectangle class (the unfinished method getCornersInbetween() has been removed)
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/Geom/docs/
	 * 
	 */
	public class SuperRectangle extends RoundedRectangle {
		
		
		public static const NONE:int = -1;
		public static const TOP:int = 0;
		public static const RIGHT:int = 1;
		public static const BOTTOM:int = 2;
		public static const LEFT:int = 3;
		
		
		/**
		 * Constructor.
		 */
		public function SuperRectangle (x:Number=0, y:Number=0, 
										width:Number=0, height:Number=0, 
										cornerRadius:Number=0):void {
			super(x, y, width, height, cornerRadius);
		}
		
		
		/**
		 * Takes a Rectangle instance and returns it as a SuperRectangle with the same position, width, height, and (if applicable) corner-radius.
		 * 
		 * @param	rect	Rectangle
		 * 
		 * @return	rect as a SuperRectangle.
		 */
		public static function createSuperRectangle (rect:Rectangle):SuperRectangle {
			if (rect is SuperRectangle){
				return SuperRectangle(rect);
			}
			var newRect:SuperRectangle = new SuperRectangle(rect.x, rect.y, rect.width, rect.height);
			if (rect is RoundedRectangle){
				newRect.cornerRadius = RoundedRectangle(rect).cornerRadius;
			}
			return newRect;
		}
		
		
		/**
		 * Indicates on which side of this SuperRectangle a Point is. Note that if the Point is not on the SuperRectangle its border, -1 will be the return-value.
		 * 
		 * @param	point	A coordinate.
		 * 
		 * @see		SuperRectangle#NONE
		 * @see		SuperRectangle#TOP
		 * @see		SuperRectangle#RIGHT
		 * @see		SuperRectangle#BOTTOM
		 * @see		SuperRectangle#LEFT
		 * 
		 * @return	An integer indicating on which side a given coordinate is. 0 stands for he top-side, 1 for right-side, etc. Use the constants of the SuperRectangle class for improved code-readability.
		 */
		public function isOnSide (point:Point):int {
			var lines:Array = this.getLines();
			for (var i:int=0; i<lines.length; i++){
				if (lines[i].containsPoint(point)){
					switch (i){
						case 0 : return SuperRectangle.TOP;
						case 1 : return SuperRectangle.RIGHT;
						case 2 : return SuperRectangle.BOTTOM;
						case 3 : return SuperRectangle.LEFT;
					}
				}
			}
			return SuperRectangle.NONE;
		}
		
		
		/**
		 * Returns an Array with Point instances indicating the corners of the SuperRectangle. The first index (0) is the top-left corner, the second (1) the top-right, etc.
		 * 
		 * @return	Array
		 */
		public function getCorners ():Array {
			return [this.topLeft, this.topRight, this.bottomRight, this.bottomLeft];
		}
		/**
		 * Returns an Array with Point instances indicating the 4 sides of this SuperRectangle as Lines.
		 * 
		 * @see		Line
		 * 
		 * @return	Array
		 */
		public function getLines ():Array {
			var lines:Array = [];
			var corners:Array = this.getCorners();
			lines.push(new Line(corners[0], corners[1]));
			lines.push(new Line(corners[1], corners[2]));
			lines.push(new Line(corners[2], corners[3]));
			lines.push(new Line(corners[3], corners[0]));
			return lines;
		}
		/**
		 * @copy	SuperRectangle#getCorners()
		 * 
		 * @see		SuperRectangle#getCorners()
		 * 
		 * @return	Array
		 */
		public function toArray ():Array {
			return this.getCorners();
		}
		
		
		/**
		 * The center of the SuperRectangle.
		 */
		public function get center ():Point {
			return Point.interpolate(this.bottomRight, this.topLeft, 0.5);
		}
		
		
		/**
		 * Point representing the lower left corner of this SuperRectangle.
		 */
		public function get bottomLeft ():Point {
			return new Point(this.left, this.bottom);
		}
		/**
		 * Point representing the upper right corner of this SuperRectangle.
		 */
		public function get topRight ():Point {
			return new Point(this.right, this.top);
		}
		
		
		/**
		 * The center of this SuperRectangle instance.
		 */
		public function get middle ():Point {
			var point:Point = new Point();
			point.x = this.x + this.width/2;
			point.y = this.y + this.height/2;
			return point;
		}
		
		
	}
	
	
}