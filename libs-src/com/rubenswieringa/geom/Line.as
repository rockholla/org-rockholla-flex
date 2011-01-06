package com.rubenswieringa.geom {

	
	import flash.geom.*;

	
	/**
	 * Describes a line consisting of two Points.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			InfiniteLine
	 * 
	 * 
	 * edit 4
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/Geom/docs/
	 * 
	 */
	public class Line extends InfiniteLine {
		
		
		/**
		 * @private
		 */
		protected var _a:Point = new Point(0, 0);
		/**
		 * @private
		 */
		protected var _b:Point = new Point(1, 1);
		
		
		/**
		 * Constructor.
		 * 
		 * @param	pointA	Line's first Point.
		 * @param	pointB	Line's second Point.
		 * 
		 * @see		Line#a
		 * @see		Line#b
		 * 
		 */
		public function Line (pointA:Point=null, pointB:Point=null):void {
			if (pointA != null) this.a = pointA;
			if (pointA != null) this.b = pointB;
		}
		
		
		/**
		 * Returns a Point instance that represents the coordinate at which two Line instances intersect.
		 * 
		 * @param	line1	Line
		 * @param	line2	Line
		 * 
		 * @see		InfiniteLine#getIntersection()
		 * 
		 * @return	A Point instance if intersections occurs, null of otherwise.
		 */
		public static function getIntersection (line1:Line, line2:Line):Point { 
			var intersect:Point = InfiniteLine.getIntersection(line1, line2);
			if (!line1.containsPoint(intersect) || !line2.containsPoint(intersect)){
				return null;
			}else{
				return intersect;
			}
		}
		
		
		/**
		 * Creates a Line from an InfiniteLine instance.
		 * 
		 * @param	line	InfiniteLine
		 * @param	range	Distance between both ends of the returned Line and the x-intersection of the InfiniteLine. Consequently, the returned Line instance its length will be twice the value of the range parameter.
		 * 
		 * @see		InfiniteLine
		 * @see		InfiniteLine#xIntersection
		 * 
		 * @return	Line.
		 */
		public static function createFromInfinite (line:InfiniteLine, range:Number=100):Line {
			var point1:Point;
			var point2:Point;
			if (!line.horizontal){
				point1 = new Point(line.xIntersection, 0);
				point2 = new Point(line.xIntersection+1, line.xCoefficient);
			}else{
				point1 = new Point(0, line.yIntersection);
				point2 = new Point(line.yCoefficient, line.yIntersection+1);
			}
			var angle:Number = line.getAngle();
			// calculate ends:
			var newLine:Line = new Line();
			newLine.a = new Point(point1.x + range * Math.cos(angle), point1.y + range * Math.sin(angle));
			angle += Math.PI;
			newLine.b = new Point(point1.x + range * Math.cos(angle), point1.y + range * Math.sin(angle));
			// return value:
			return newLine;
		}
		
		/**
		 * Returns an Array if which the first index and second (0 and 1) indexes are (respectively) the Line its first and second Points (a and b).
		 * 
		 * @return	Array
		 */
		public function toArray ():Array {
			return [this.a, this.b];
		}
		/**
		 * The String representation of this Line instance.
		 * 
		 * @return	String
		 */
		override public function toString ():String {
			return "Line(("+this.a.x+","+this.a.y+")->("+this.b.x+","+this.b.y+"))";
		}
		
		
		/**
		 * Sets both ends of this Line instance equal to the values of the respective parameter values. This method does nothing more than setting the values of the a and b properties.
		 * 
		 * @param	a	Line's first Point.
		 * @param	b	Line's second Point.
		 * 
		 * @see		Line#a
		 * @see		Line#b
		 * 
		 */
		override public function syncToPoints (a:Point, b:Point):void {
			this.a = a;
			this.b = b;
		}
		
		
		/**
		 * Returns a cloned instance of this Line.
		 * 
		 * @return	Line
		 */
		override public function clone ():* {
			return new Line(this.a, this.b);
		}
		
		
		/**
		 * Returns true if the provided coordinate is on this Line.
		 * 
		 * @param	point	Point instance representing a coordinate.
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @see		Line#containsLine()
		 * 
		 * @returns	Boolean
		 */
		override public function containsPoint (point:Point, round:Boolean=true):Boolean {
	 		// coordinate can't be on this Line if both Points in this Line are on one side of the coordinate:
			if ((point.x < this.a.x && point.x < this.b.x) || (point.x > this.a.x && point.x > this.b.x) || 
				(point.y < this.a.y && point.y < this.b.y) || (point.y > this.a.y && point.y > this.b.y) ){
				return false;
			}
			// invoke super:
			return super.containsPoint(point, round);
		}
		/**
		 * Returns true if the provided Line is in this Line. Note that true is only returned if both Points of the provided Line instance are on this Line.
		 * 
		 * @param	line	Line
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @see		Line#containsLinePartially()
		 * @see		Line#containsPoint()
		 * @see		Line#equals()
		 * @see		InfiniteLine#isParallelTo()
		 * 
		 * @returns	Boolean
		 */
		public function containsLine (line:Line, round:Boolean=true):Boolean {
			return (this.containsPoint(line.a, round) && this.containsPoint(line.b, round));
		}
		/**
		 * Returns true if the provided Line is partially in this Line.
		 * 
		 * @param	line	Line
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @see		Line#containsLine()
		 * @see		Line#containsPoint()
		 * @see		Line#equals()
		 * @see		InfiniteLine#isParallelTo()
		 * 
		 * @returns	Boolean
		 */
		public function containsLinePartially (line:Line, round:Boolean=true):Boolean {
			return ((this.containsPoint(line.a, round) || this.containsPoint(line.b, round)) && this.xCoefficient == line.xCoefficient);
		}
		
		
		/**
		 * Returns true if the provided Line instance is equal to this Line.
		 * 
		 * @param	line	Line
		 * @param	round	Boolean indicating whether or not to round values before making equations.
		 * 
		 * @see		Line#containsLine()
		 * @see		InfiniteLine#isParallelTo()
		 * 
		 * @return	Boolean
		 */
	 	override public function equals (line:InfiniteLine, round:Boolean=true):Boolean {
			if (line is Line){
				var castLine:Line = Line(line);
				var a1:Point = (round) ? SuperPoint.round(this.a) : this.a;
				var b1:Point = (round) ? SuperPoint.round(this.b) : this.b;
				var a2:Point = (round) ? SuperPoint.round(castLine.a) : castLine.a;
				var b2:Point = (round) ? SuperPoint.round(castLine.b) : castLine.b;
				return ((a1.equals(a2) && b1.equals(b2)) || (a1.equals(b2) && b1.equals(a2)));
			}else{
				return super.equals(line);
			}
		}
		
		
		/**
		 * The outcome of Point B its x-position minus Point A its x-position.
		 * @see	Line#diffY
		 */
		public function get diffX ():Number {
			return this.b.x - this.a.x;
		}
		/**
		 * The outcome of Point B its y-position minus Point A its y-position.
		 * @see	Line#diffY
		 */
		public function get diffY ():Number {
			return this.b.y - this.a.y;
		}
		
		
		/**
		 * The exact center of the first and second Points of this Line.
		 */
		public function get middle ():Point {
			return Point.interpolate(this.a, this.b, 0.5);
		}
		
		
		/**
		 * Line's first Point.
		 */
		public function get a ():Point {
			return this._a;
		}
		public function set a (point:Point):void {
			this._a = point;
			super.syncToPoints(this.a, this.b);
		}
		
		
		/**
		 * Line's second Point.
		 */
		public function get b ():Point {
			return this._b;
		}
		public function set b (point:Point):void {
			this._b = point;
			super.syncToPoints(this.a, this.b);
		}
		
		
		/**
		 * @inheritdoc
		 * @see	InfiniteLine#xIntersection
		 */
		override public function get xIntersection ():Number {
			return super.xIntersection;
		}
		override public function set xIntersection (value:Number):void {
			this._a.x += value - this._xIntersection;
			this._b.x += value - this._xIntersection;
			this.setXIntersection(value);
		}
		/**
		 * @inheritdoc
		 * @see	InfiniteLine#yIntersection
		 */
		override public function get yIntersection ():Number {
			return super.yIntersection;
		}
		override public function set yIntersection (value:Number):void {
			this._a.y += value - this._yIntersection;
			this._b.y += value - this._yIntersection;
			this.setYIntersection(value);
		}
		
		
		/**
		 * @inheritdoc
		 * @see	InfiniteLine#xCoefficient
		 */
		override public function get xCoefficient ():Number {
			return super.xCoefficient;
		}
		override public function set xCoefficient (value:Number):void {
			// remember distances between both ends and the intersection with the x-axis:
			var xIntersect:Point = new Point(this.xIntersection, 0);
			var dist1:Number = Point.distance(this.a, xIntersect);
			var dist2:Number = Point.distance(this.b, xIntersect);
			// set property:
			this.setXCoefficient(value);
			// reposition both ends of this Line:
			var angle:Number = this.getAngle();
			angle += Math.PI;
			this._a = new Point(xIntersect.x + dist1 * Math.cos(angle), xIntersect.y + dist1 * Math.sin(angle));
			angle += Math.PI;
			this._b = new Point(xIntersect.x + dist2 * Math.cos(angle), xIntersect.y + dist2 * Math.sin(angle));
		}
		
		
		/**
		 * @inheritdoc
		 * @see	InfiniteLine#yCoefficient
		 */
		override public function get yCoefficient ():Number {
			return super.yCoefficient;
		}
		override public function set yCoefficient (value:Number):void {
			// remember distances between both ends and the intersection with the x-axis:
			var xIntersect:Point = new Point(this.xIntersection, 0);
			var dist1:Number = Point.distance(this.a, xIntersect);
			var dist2:Number = Point.distance(this.b, xIntersect);
			// set property:
			this.setYCoefficient(value);
			// reposition both ends of this Line:
			var angle:Number = this.getAngle();
			angle += Math.PI;
			this._a = new Point(xIntersect.x + dist1 * Math.cos(angle), xIntersect.y + dist1 * Math.sin(angle));
			angle += Math.PI;
			this._b = new Point(xIntersect.x + dist2 * Math.cos(angle), xIntersect.y + dist2 * Math.sin(angle));
		}
		
		
	}
	
	
}