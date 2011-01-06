package com.rubenswieringa.geom {
	
	
	import flash.geom.Point;	
	
	
	/**
	 * Provides additional functionality for working with Points.
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
	 *  http://www.rubenswieringa.com/code/as3/flex/Geom/docs/
	 * 
	 */
	public class SuperPoint {
		
		
		/**
		 * Rounds the x and y values of a Point instance.
		 * 
		 * @point	A Point instance.
		 * @factor	Indicates how much to round the coordinates stored in point. For example, with a factor of 100, an x-value of 12.345678 will become 12.34. With a factor of 1000 it would become 12.345, and so forth.
		 * 
		 * @return	A new Point instance storing the round coordinate.
		 */
		public static function round (point:Point, factor:uint=1):Point {
			var newPoint:Point = new Point();
			newPoint.x = Math.round(point.x*factor)/factor;
			newPoint.y = Math.round(point.y*factor)/factor;
			return newPoint;
		}
		
		
	}
	
	
}