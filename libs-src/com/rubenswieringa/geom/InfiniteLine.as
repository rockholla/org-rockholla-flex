package com.rubenswieringa.geom {
	
	
	import flash.geom.*;

	
	/**
	 * Describes a line consisting of a slope (coefficient) and an intersection-point with either the x or y axis.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * 
	 * 
	 * edit 3
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/Geom/docs/
	 * 
	 */
	public class InfiniteLine {
		
		
		/**
		 * @private
		 */
		protected var _xIntersection:Number = 0;
		/**
		 * @private
		 */
		protected var _yIntersection:Number = 0;
		/**
		 * @private
		 */
		protected var _xCoefficient:Number = 1;
		
		/**
		 * @private
		 */
		protected static const ROUND:uint = 100;
		
		
		/**
		 * Constructor.
		 * 
		 * @param	xIntersection	
		 * @param	xCoefficient	
		 * 
		 * @see		InfiniteLine#xIntersection
		 * @see		InfiniteLine#xCoefficient
		 * @see		InfiniteLine#yIntersection
		 * @see		InfiniteLine#yCoefficient
		 * 
		 */
		public function InfiniteLine (xIntersection:Number=0, xCoefficient:Number=1):void {
			this.setXCoefficient(xCoefficient);
			this.setXIntersection(xIntersection);
		}
		
		
		/**
		 * Returns a Point instance that represents the coordinate at which two InfiniteLine instances intersect.
		 * Many thanks to Arno van Oordt for taking the time to explain the concept of intersection to me, check out his blog at http://blog.justgreat.nl
		 * 
		 * @internal	Note that the below code is actually a slightly modified version of the intersection method from a class Arno wrote some time ago.
		 * 
		 * @param	line1	InfiniteLine
		 * @param	line2	InfiniteLine
		 * 
		 * @return	A Point instance if intersections occurs, null of otherwise.
		 */
		public static function getIntersection (line1:InfiniteLine, line2:InfiniteLine):Point { 
			
			if (line1.horizontal)	return line2.getPointByY(line1.yIntersection);
			if (line1.vertical)		return line2.getPointByX(line1.xIntersection);
			if (line2.horizontal)	return line1.getPointByY(line2.yIntersection);
			if (line2.vertical)		return line1.getPointByX(line2.xIntersection);
			
			var lengthA:Number = Math.abs(line2.yIntersection - line1.yIntersection);
			var lengthB:Number;
			var lengthC:Number;
			
			var arcB:Number;
			var arcC:Number;
			var arcA:Number;
			if (line1.yIntersection > line2.yIntersection){
				arcB = Math.abs(Math.PI/2 + line1.getAngle());
				arcC = Math.abs(Math.PI/2 - line2.getAngle());
			}else{
				arcB = Math.abs(Math.PI/2 - line1.getAngle());
				arcC = Math.abs(Math.PI/2 + line2.getAngle());
			}
			arcA = Math.PI - arcB - arcC;
			
			var ratio:Number = Math.sin(arcA) / lengthA;
			lengthB = Math.sin(arcB) / ratio;
			lengthC = Math.sin(arcC) / ratio;
			
			var x:Number = Math.sin(arcC) * lengthB;
			
			return line1.getPointByX(x);
		}
		
		
		/**
		 * Creates an InfiniteLine at the hand of two Points.
		 * 
		 * @param	a	Point
		 * @param	b	Point
		 * 
		 * @see		InfiniteLine#syncToPoints()
		 * 
		 * @return	InfiniteLine
		 */
		public static function createFromPoints (a:Point, b:Point):InfiniteLine {
			var line:InfiniteLine = new InfiniteLine();
			line.syncToPoints(a, b);
			return line;
		}
		
		
		/**
		 * Returns a cloned instance of this InfiniteLine.
		 * 
		 * @return	InfiniteLine
		 */
		public function clone ():* {
			var line:InfiniteLine = new InfiniteLine(this.xIntersection, this.xCoefficient);
			line.yIntersection = this.yIntersection;
			return line;
		}
		
		
		/**
		 * The String representation of this InfiniteLine instance.
		 * 
		 * @return	String
		 */
		public function toString ():String {
			return "InfiniteLine(xIntersection="+this.xIntersection+", xCoefficient="+this.xCoefficient+")";
		}
		
		
		/**
		 * Synchronizes this InfiniteLine instance to contain two Points.
		 * 
		 * @param	a	First Point.
		 * @param	b	Second Point.
		 * 
		 */
		public function syncToPoints (a:Point, b:Point):void {
			var point1:Point;
			var point2:Point;
			// calculate coefficient:
			point1 = (a.x < b.x) ? a : b;
			point2 = (a.x > b.x) ? a : b;
			this.setXCoefficient((b.y-a.y) / (b.x-a.x));
			// calculate intersection:
			point1 = (a.y < b.y) ? a : b;
			point2 = (a.y > b.y) ? a : b;
			this.setXIntersection(point2.x - (point2.y / (point2.y-point1.y)) * (point2.x-point1.x));
			// don't lose yIntersection:
			if (this.horizontal){
				this.setYIntersection(a.y);
			}
		}
		
		
		/**
		 * Creates an InfiniteLine instance at the hand of an x-intersection and an x-coefficient. Note that this method is exactly the same as the class its constructor.
		 * 
		 * @param	xIntersection	x-position of this InfiniteLine's intersection-point with the x-axis.
		 * @param	xCoefficient	x-coefficient.
		 * 
		 * @see		InfiniteLine#createFromY()
		 * @see		InfiniteLine#xIntersection
		 * @see		InfiniteLine#xCoefficient
		 * 
		 * @return	InfiniteLine
		 */
		public static function createFromX (xIntersection:Number, xCoefficient:Number):InfiniteLine {
			return new InfiniteLine(xIntersection, xCoefficient);
		}
		/**
		 * Creates an InfiniteLine instance at the hand of an y-intersection and an y-coefficient.
		 * 
		 * @param	xIntersection	y-position of this InfiniteLine's intersection-point with the y-axis.
		 * @param	xCoefficient	y-coefficient.
		 * 
		 * @see		InfiniteLine#createFromX()
		 * @see		InfiniteLine#yIntersection
		 * @see		InfiniteLine#yCoefficient
		 * 
		 * @return	InfiniteLine
		 */
		public static function createFromY (yIntersection:Number, yCoefficient:Number):InfiniteLine {
			var line:InfiniteLine = new InfiniteLine();
			line.yIntersection	= yIntersection;
			line.yCoefficient	= yCoefficient;
			return line;
		}
		
		
		/**
		 * Returns the angle of this InfiniteLine with the x-axis.
		 * 
		 * @return	Angle in radians.
		 */
		public function getAngle ():Number {
			if (this.horizontal)	return 0;
			if (this.vertical)		return Math.PI/2;
			var point1:Point = new Point(this.xIntersection, 0);
			var point2:Point = new Point(this.xIntersection+1, this.xCoefficient);
			return Math.atan2(point2.y-point1.y, point2.x-point1.x);	
		}
		
		
		/**
		 * Return a Point on this InfiniteLine where the x-position equals the specified value.
		 * 
		 * @see		InfiniteLine#getPointByY()
		 * 
		 * @return	Point
		 */
		public function getPointByX (x:Number):Point {
			var y:Number = (this.horizontal) ? this.yIntersection : this.yIntersection + x * this.xCoefficient;
			return new Point(x, y);
		}
		/**
		 * Return a Point on this InfiniteLine where the y-position equals the specified value.
		 * 
		 * @see		InfiniteLine#getPointByX()
		 * 
		 * @return	Point
		 */
		public function getPointByY (y:Number):Point {
			var x:Number = (this.vertical) ? this.xIntersection : this.xIntersection + y * this.yCoefficient;
			return new Point(x, y);
		}
		
		
		/**
		 * Returns true if the provided Point is on this InfiniteLine.
		 * 
		 * @param	point	Point instance representing a coordinate.
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @see		InfiniteLine#contains()
		 * 
		 * @returns	Boolean
		 */
	 	public function containsPoint (point:Point, round:Boolean=true):Boolean {
	 		var value1:Number;
	 		var value2:Number;
			// single-axis equation for horizontal and vertical Lines:
			if (this.horizontal){
				value1 = point.y;
				value2 = this.yIntersection;
			}
			if (this.vertical){
				value1 = point.x;
				value2 = this.xIntersection;
			}
			// otherwise calculate by slope of this Line:
			if (!this.horizontal && !this.vertical){
				value1 = (point.x-this.xIntersection) * this.xCoefficient;
				value2 = point.y;
			}
			// round if necessary:
			if (round){
				value1 = Math.round(value1);
				value2 = Math.round(value2);
			}
			// return value:
			return (value1 == value2);
		}
		
		
		/**
		 * Returns true if the provided InfiniteLine instance is parallel to this InfiniteLine.
		 * 
		 * @param	line	InfiniteLine
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @return	Boolean
		 */
		public function isParallelTo (line:InfiniteLine, round:Boolean=true):Boolean {
			var value1:Number = this.xCoefficient;
			var value2:Number = line.xCoefficient;
			if (round){
				value1 = Math.round(value1*InfiniteLine.ROUND)/InfiniteLine.ROUND;
				value2 = Math.round(value2*InfiniteLine.ROUND)/InfiniteLine.ROUND;
			}
			return (value1 == value2);
		}
		/**
		 * Returns true if the intersection-points and coefficients of both InfiniteLine instances are equal.
		 * 
		 * @param	line	InfiniteLine
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @return	Boolean
		 */
		public function equals (line:InfiniteLine, round:Boolean=true):Boolean{
			var value1:Number = this.xIntersection;
			var value2:Number = line.xIntersection;
			var value3:Number = this.yIntersection;
			var value4:Number = line.yIntersection;
			if (round){
				value1 = Math.round(value1);
				value2 = Math.round(value2);
				value3 = Math.round(value3);
				value4 = Math.round(value4);
			}
			return (this.isParallelTo(line) && (value1 == value2 || value3 == value4));
		}
		
				
		/**
		 * Indicates whether or not this InfiniteLine instance is horizontal.
		 * @see	InfiniteLine#vertical
		 */
		public function get horizontal ():Boolean {
			return (this.xCoefficient == 0);
		}
		public function set horizontal (value:Boolean):void {
			if (this.horizontal == value){
				return;
			}
			if (value){
				this.setXCoefficient(0);
			}else{
				this.setXCoefficient(1);
			}
		}
		/**
		 * Indicates whether or not this InfiniteLine instance is vertical.
		 * @see	InfiniteLine#horizontal
		 */
		public function get vertical ():Boolean {
			return (this.yCoefficient == 0);
		}
		public function set vertical (value:Boolean):void {
			if (this.vertical == value){
				return;
			}
			if (value){
				this.yCoefficient = (this.yCoefficient >= 0) ? Number.POSITIVE_INFINITY : Number.NEGATIVE_INFINITY;
			}else{
				this.yCoefficient = 1;
			}
		}
		
		
		/**
		 * The x-position of the coordinate where this InfiniteLine crosses the x-axis (and consequently the y-position will be equal to zero).
		 * @see	InfiniteLine#xCoefficient
		 * @see	InfiniteLine#yCoefficient
		 * @see	InfiniteLine#yIntersection
		 */
		public function get xIntersection ():Number {
			return this._xIntersection;
		}
		public function set xIntersection (value:Number):void {
			this.setXIntersection(value);
		}
		/**
		 * Sets the value of the internal for the xIntersection property.
		 * This method is used internally by the InfiniteLine class and its subclasses, whereas outer classes use the public accompanying setter-method.
		 * Where the getter methods sometimes also synchronize properties to eachother (in subclasses), this method is purely for setting its own internal property.
		 * @see	InfiniteLine#xIntersection
		 * @private
		 */
		protected function setXIntersection (value:Number):void {
			this._xIntersection =  value;
			this._yIntersection = -value * this.xCoefficient;
		}
		
		
		/**
		 * The y-position of the coordinate where this InfiniteLine crosses the y-axis (and consequently the x-position will be equal to zero).
		 * @see	InfiniteLine#xCoefficient
		 * @see	InfiniteLine#xIntersection
		 * @see	InfiniteLine#yCoefficient
		 */
		public function get yIntersection ():Number {
			return this._yIntersection;
		}
		public function set yIntersection (value:Number):void {
			this.setYIntersection(value);
		}
		/**
		 * Sets the value of the internal for the yIntersection property.
		 * This method is used internally by the InfiniteLine class and its subclasses, whereas outer classes use the public accompanying setter-method.
		 * Where the getter methods sometimes also synchronize properties to eachother (in subclasses), this method is purely for setting its own internal property.
		 * @see	InfiniteLine#yIntersection
		 * @private
		 */
		protected function setYIntersection (value:Number):void {
			this._yIntersection =  value;
			this._xIntersection = -value / this.xCoefficient;
		}
		
		
		/**
		 * Value with which the y-position of this InfiniteLine increases, relative to that with which the x-position increases.
		 * @see	InfiniteLine#yCoefficient
		 * @see	InfiniteLine#xIntersection
		 * @see	InfiniteLine#yIntersection
		 */
		public function get xCoefficient ():Number {
			return this._xCoefficient;
		}
		public function set xCoefficient (value:Number):void {
			this.setXCoefficient(value);
		}
		/**
		 * Sets the value of the internal for the xCoefficient property.
		 * This method is used internally by the InfiniteLine class and its subclasses, whereas outer classes use the public accompanying setter-method.
		 * Where the getter methods sometimes also synchronize properties to eachother (in subclasses), this method is purely for setting its own internal property.
		 * @see	InfiniteLine#xCoefficient
		 * @private
		 */
		protected function setXCoefficient (value:Number):void {
			this._xCoefficient = value;
			this.setXIntersection(this.xIntersection);
		}
		
		
		/**
		 * Value with which the x-position of this InfiniteLine increases, relative to that with which the y-position increases.
		 * @see	InfiniteLine#xCoefficient
		 * @see	InfiniteLine#xIntersection
		 * @see	InfiniteLine#yIntersection
		 */
		public function get yCoefficient ():Number {
			return 1 / this.xCoefficient;
		}
		public function set yCoefficient (value:Number):void {
			this.setYCoefficient(value);
		}
		/**
		 * Sets the value of the internal for the yCoefficient property.
		 * This method is used internally by the InfiniteLine class and its subclasses, whereas outer classes use the public accompanying setter-method.
		 * Where the getter methods sometimes also synchronize properties to eachother (in subclasses), this method is purely for setting its own internal property.
		 * @see	InfiniteLine#yCoefficient
		 * @private
		 */
		protected function setYCoefficient (value:Number):void {
			this.setXCoefficient(1/value);
		}
		
		
	}
	
	
}