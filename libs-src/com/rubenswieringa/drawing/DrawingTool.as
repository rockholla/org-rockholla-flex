package com.rubenswieringa.drawing {
	
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * Provides basic functionality for drawing with the Drawing API.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			LineStyle
	 * 
	 * 
	 * edit 1
	 * 
	 * Before modifying and/or redistributing this class, please contact Ruben Swieringa (ruben.swieringa@gmail.com).
	 * 
	 * 
	 * View code documentation at:
	 *  http://www.rubenswieringa.com/code/as3/flex/DrawingTool/docs/
	 * 
	 */
	public class DrawingTool {
		
		
		// constants:
		public static const CROSS:String = "cross";
		public static const CIRCLE:String = "circle";
		
		
		/**
		 * Constructor.
		 * @private
		 */
		public function DrawingTool ():void {}
		
		
		/**
		 * Draws a cross shaped marker on the specified coordinate(s).
		 * This method its main functionality is that it executes the lineTo() method, so (for example) when aiming to draw a filled shape, beginFill() must be called first. For drawing lines, either the lineStyle() method of the Graphics class must be executed, or a LineStyle instance must be used as a parameter value for this method.
		 * 
		 * @param	graphics	Graphics instance on which to draw the shape.
		 * @param	point		Array or Point specifying one or more Point instances. If the point parameter value is neither a Point nor an Array then the function will silently fail.
		 * @param	size		Size of the marker.
		 * @param	shape		Shape of the marker, either DrawingTool.CROSS or DrawingTool.CIRCLE. Defaults to DrawingTool.CROSS.
		 * @param	lineStyle	LineStyle instance carrying the styles for the lines of the marker to be drawn.
		 * 
		 * @see		LineStyle
		 * @see		DrawingTool#CROSS
		 * @see		DrawingTool#CIRCLE
		 * 
		 */
		public static function drawMarker  (graphics:Graphics, 
											point:*, 
											size:Number=10, 
											shape:String=DrawingTool.CROSS, 
											lineStyle:LineStyle=null):void {
			if (point is Array){
				for (var i:String in point){
					DrawingTool.drawMarker(graphics, point[i], size, shape);
				}
			}
			if (point is Point){
				switch (shape){
					case DrawingTool.CROSS :
						var point1:Point = new Point(point.x-size/2, point.y-size/2);
						var point2:Point = new Point(point.x+size/2, point.y+size/2);
						var point3:Point = new Point(point.x+size/2, point.y-size/2);
						var point4:Point = new Point(point.x-size/2, point.y+size/2);
						DrawingTool.drawLine(graphics, point1, point2, lineStyle);
						DrawingTool.drawLine(graphics, point3, point4, lineStyle);
						break;
					case DrawingTool.CIRCLE :
						if (lineStyle != null){
							lineStyle.applyTo(graphics);
						}
						graphics.moveTo(point.x+size/2, point.y);
						graphics.curveTo(point.x+size/2, point.y+size/2, point.x, point.y+size/2);
						graphics.curveTo(point.x-size/2, point.y+size/2, point.x-size/2, point.y);
						graphics.curveTo(point.x-size/2, point.y-size/2, point.x, point.y-size/2);
						graphics.curveTo(point.x+size/2, point.y-size/2, point.x+size/2, point.y);
						break;
				}
			}
		}
		
		
		/**
		 * Draws lines between the Point instances in the area Array onto graphics with the drawing API.
		 * This method its main functionality is that it executes the lineTo() method, so (for example) when aiming to draw a filled shape, beginFill() must be called first. For drawing lines, either the lineStyle() method of the Graphics class must be executed, or a LineStyle instance must be used as a parameter value for this method (DrawingTool.draw()). Also see the example below.
		 * 
		 * @param	graphics	Graphics instance on which the lines should be drawn
		 * @param	area		Array with coordinates (Point instances)
		 * @param	connect		Boolean indicating whether or not to connect the last Point in area with the last Point in area. Defaults to true.
		 * @param	lineStyle	LineStyle instance carrying the styles for the lines of the shape to be drawn.
		 * 
		 * @example	Drawing a filled shape:
		 * 			<listing version="3.0">
		 * 			var shape:Array = [new Point(0,0), new Point(100,0), new Point(0,100)];
		 * 			myGraphics.beginFill(0xFF0000);
		 * 			DrawingTool.draw(myGraphics, shape);
		 * 			myGraphics.endFill();
		 * 			</listing>
		 * 
		 * @example	Drawing a shape with outline:
		 * 			<listing version="3.0">
		 * 			var shape:Array = [new Point(0,0), new Point(100,0), new Point(0,100)];
		 * 			myGraphics.lineStyle(1, 0x00FF00);
		 * 			DrawingTool.draw(myGraphics, shape);
		 * 			</listing>
		 * 
		 * @example	Drawing a shape with dashed outline using the LineStyle class:
		 * 			<listing version="3.0">
		 * 			var shape:Array = [new Point(0,0), new Point(100,0), new Point(0,100)];
		 * 			var lineStyle:LineStyle = new LineStyle(1, 0x00FF00);
		 * 			lineStyle.dash = 4;
		 * 			DrawingTool.draw(myGraphics, shape);
		 * 			</listing>
		 * 
		 * @see		LineStyle
		 * 
		 */
		public static function draw    (graphics:Graphics, 
										area:Array, 
										connect:Boolean=true, 
										lineStyle:LineStyle=null):void {
			var i:int;
			var newArea:Array = [];
			for (i=0; i<area.length; i++){
				if (area[i] != null){
					newArea.push(area[i]);
				}
			}
			if (newArea.length < 2){
				return;
			}
			graphics.moveTo(newArea[0].x, newArea[0].y);
			for (i=1; i<newArea.length; i++){
				if (newArea[i] != null){
					DrawingTool.drawLine(graphics, newArea[i-1], newArea[i], lineStyle, false);
				}
			}
			if (connect){
				DrawingTool.drawLine(graphics, newArea[newArea.length-1], newArea[0], lineStyle, false);
			}
		}
		
		
		/**
		 * Draws lines between the four corners of a Rectangle.
		 * Note that this method is not the same as the method with the same name in the Graphics class, which takes the parameters of the Rectangle constructor as parameters, instead of a Rectangle instance, as does this method.
		 * This method its main functionality is that it executes the lineTo() method, so (for example) when aiming to draw a filled shape, beginFill() must be called first. For drawing lines, either the lineStyle() method of the Graphics class must be executed, or a LineStyle instance must be used as a parameter value for this method. Also see the example included in the documentation for the draw() method.
		 * 
		 * @param	graphics	Graphics instance on which the lines should be drawn
		 * @param	rect		Rectangle
		 * @param	lineStyle	LineStyle instance carrying the styles for the lines of the Rectangle to be drawn.
		 * 
		 * @see		LineStyle
		 * @see		DrawingTool#draw()
		 */
		public static function drawRect    (graphics:Graphics, 
											rect:Rectangle, 
											lineStyle:LineStyle=null):void {
			var area:Array =   [rect.topLeft,
								new Point(rect.right, rect.top),
								rect.bottomRight,
								new Point(rect.left, rect.bottom)];
			DrawingTool.draw(graphics, area, true, lineStyle);
		}
		
		
		/**
		 * Draws a line from one Point to another.
		 * This method its main functionality is that it executes the lineTo() method, so (for example) when aiming to draw a filled shape, beginFill() must be called first. For drawing lines, either the lineStyle() method of the Graphics class must be executed, or a LineStyle instance must be used as a parameter value for this method.
		 * 
		 * @param	graphics	Graphics instance on which to draw the line.
		 * @param	point1		First Point.
		 * @param	point2		second Point.
		 * @param	lineStyle	LineStyle instance storing the properties of the line to be drawn.
		 * @param	moveTo		Whether or not to execute the Graphics class its moveTo() method before running the rest of the method.
		 * 
		 * @see		LineStyle
		 */
		public static function drawLine    (graphics:Graphics, 
											point1:Point, 
											point2:Point, 
											lineStyle:LineStyle=null, 
											moveTo:Boolean=true):void {
			
			if (moveTo){
				graphics.moveTo(point1.x, point1.y);
			}
			
			if (lineStyle != null && lineStyle.dashEnabled){ // draw dashed line
				
				var distance:Number = Point.distance(point1, point2);
				var traveled:Number = 0;
				var next:Point;
				
				for (var i:int=0; i<Math.ceil(distance/(lineStyle.dash+lineStyle.space)); i++){
					traveled = i * (lineStyle.dash + lineStyle.space);
					// draw line:
					traveled = (traveled + lineStyle.dash >= distance) ? distance : traveled + lineStyle.dash;
					next = Point.interpolate(point1, point2, 1-(traveled/distance));
					lineStyle.applyTo(graphics);
					graphics.lineTo(next.x, next.y);
					// stop if end of dash is equal to end of line:
					if (next.equals(point2)) break;
					// draw space:
					traveled = (traveled + lineStyle.space >= distance) ? distance : traveled + lineStyle.space;
					next = Point.interpolate(point1, point2, 1-(traveled/distance));
					DrawingTool.clearLineStyle(graphics);
					graphics.lineTo(next.x, next.y);
				}
				
			}else{ // draw normal line
				
				if (lineStyle != null){
					lineStyle.applyTo(graphics);
				}
				graphics.lineTo(point2.x, point2.y);
				
			}
			
		}
		
		
		/**
		 * Sets the lineStyle of a Graphics instance to none.
		 * 
		 * @param	graphics	Graphics instance of which to clear the lineStyle.
		 * 
		 */
		public static function clearLineStyle (graphics:Graphics):void {
			graphics.lineStyle(undefined, undefined, undefined);
		}
		
		
	}
	
}