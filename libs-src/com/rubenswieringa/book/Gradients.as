package com.rubenswieringa.book {
	
	
	import com.rubenswieringa.drawing.*;
	import com.rubenswieringa.geom.*;
	import com.rubenswieringa.utils.*;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	use namespace limited;
	
	
	/**
	 * Draws shadows and highlights for a Page.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			Page Page
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
	public class Gradients {
		
		
		// internals accessors:
		/**
		 * @private
		 */
		protected var _page:Page;
		/**
		 * @private
		 */
		protected var _solidColorAlpha:Number = 0.3;
		
		// plain var properties:
		/**
		 * If true, highlights for the insides of hardcover Pages are not drawn.
		 * @default	true
		 */
		public var eliminateSolidHighlights:Boolean = true;
		
		// constants:
		public static const ROTATE_FULL:Number = 0.25;
		public static const ROTATE_HALF:Number = 0.75;
		public static const LIGHT:String =	"light";
		public static const DARK:String	=	"dark";
		/**
		 * @private
		 */
		protected static const LIGHTCOLOR:uint	= 0xFFFFFF;
		/**
		 * @private
		 */
		protected static const DARKCOLOR:uint	= 0x000000;
		
		/**
		 * @private
		 */
		protected static const FLIPSIDE:Object = {
								light:	{	color: [LIGHTCOLOR, LIGHTCOLOR, LIGHTCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0, 0.3, 0.2, 0.5,   0],
											ratio: [  0,  88,  96, 128, 129] },
								dark:	{	color: [0xCCCCCC, 0x999999, 0x444444, 0x000000],
											alpha: [  0, 0.1, 0.3, 0.6],
											ratio: [  0,  74, 100, 128] } };
		/**
		 * @private
		 */
		protected static const INSIDE_SMOOTH:Object = {
								light:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0,   0, 0.5,   0],
											ratio: [  0,   1, 128, 129] },
								dark:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0,   0, 0.5,   0],
											ratio: [  0,   1, 128, 129] } };
		/**
		 * @private
		 */
		protected static const OUTSIDE_SMOOTH:Object = {
								light:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0, 0.2,   0,   0,   0],
											ratio: [126, 127, 141, 191, 255] },
								dark:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0, 0.4,   0,   0],
											ratio: [126, 127, 191, 255] } };
		/**
		 * @private
		 */
		protected static const OUTSIDE_HARD:Object = {
								light:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [0.8, 0.3, 0.1,  0],
											ratio: [  0,  96, 160, 255] },
								dark:	{	color: [DARKCOLOR, DARKCOLOR, DARKCOLOR],
											alpha: [  0, 0.2, 0.9],
											ratio: [  0,  96, 255] } };
		
		
	// CONSTRUCTOR:
		
		/**
		 * Constructor.
		 */
		public function Gradients (p:Page):void {
			
			this._page = p;
			
		}
		
		
	// CUSTOM:
		
		/**
		 * Draws a gradient to simulate depth in the middle of the Book.
		 * 
		 * @param	tint	Indicates whether to draw a highlight (Gradients.LIGHT) or shadow (Gradients.DARK)
		 * 
		 * @see		#LIGHT
		 * @see		#DARK
		 * 
		 * @see		#FOLD
		 * 
		 * @see		Book#addGradients()
		 * 
		 */
		public function drawFold   (graphics:Graphics, 
									tint:String=Gradients.LIGHT,
									rotate:Number=Gradients.ROTATE_FULL):void {
			
			var gradient:Object = Gradients.FLIPSIDE[tint];
			var area:SuperRectangle = new SuperRectangle(0, 0, this._page.book.width/2, this._page.book.height);
			
			// define the points that the calculation will be based on:
			var point1:Point = (this._page.side == Page.LEFT) ? area.topRight : area.topLeft;
			var point2:Point = (this._page.side == Page.LEFT) ? area.bottomRight : area.bottomLeft;
			
			// create the model for the gradient:
			var matrix:Matrix = this.createNewMatrix(point1, point2, rotate);
			
			// draw gradient:
			graphics.beginGradientFill (GradientType.LINEAR,
										gradient.color,
										gradient.alpha,
										gradient.ratio,
										matrix);
			DrawingTool.drawRect(graphics, area);
			graphics.endFill();
			
		}
		
		
		/**
		 * Draws a gradient to simulate a shadow on the facing pages of the Book.
		 * 
		 * @param	area	Array with coordinates (Point instances), typically the cPoints property of the ocf Object returned by the computeFlip method of the PageFlip class
		 * @param	tint	Indicates whether to draw a light or dark shadow
		 * @param	rotate	The correction of the gradient its rotation (from 0.0 to 1.0)
		 * 
		 * @see		Gradients#ROTATE_FULL;
		 * @see		Gradients#ROTATE_HALF;
		 * 
		 * @see		Gradients#LIGHT
		 * @see		Gradients#DARK
		 * 
		 * @see		Gradients#INSIDE
		 * 
		 * @see		Book#addGradients()
		 * @see		PageFlip#computeFlip()
		 * 
		 */
		public function drawInside (graphics:Graphics, 
									area:Array,
									tint:String=Gradients.DARK,
									rotate:Number=Gradients.ROTATE_FULL):void {
			
			if (this._page.hard){
				this.drawInsideHard(graphics, area, tint, rotate);
			}else{
				this.drawInsideSmooth(graphics, area, tint, rotate);
			}
			
		}
		/**
		 * @see	Gradients#drawInside()
		 * 
		 * @private
		 */
		protected function drawInsideHard  (graphics:Graphics, 
											area:Array,
											tint:String=Gradients.DARK,
											rotate:Number=Gradients.ROTATE_FULL):void {
			// hard pages don't need highlights, only shadows:
			if (this.eliminateSolidHighlights && tint == Gradients.LIGHT){
				return;
			}
			
			var color:uint = (tint == Gradients.DARK) ? Gradients.DARKCOLOR : Gradients.LIGHTCOLOR;
			
			// calculate strength (opacity) of the color:
			var strength:Number = (this._page.book.width/2 - Math.abs(area[0].x - area[1].x)) / (this._page.book.width/2) * this._solidColorAlpha;
			
			// draw color:
			graphics.beginFill(color, strength);
			DrawingTool.draw(graphics, area);
			graphics.endFill();
			
		}
		/**
		 * @see	Gradients#drawInside()
		 * 
		 * @private
		 */
		protected function drawInsideSmooth    (graphics:Graphics, 
												area:Array,
												tint:String=Gradients.DARK,
												rotate:Number=Gradients.ROTATE_FULL):void {
			
			var gradient:Object = Gradients.INSIDE_SMOOTH[tint];
			
			// define the points that the calculation will be based on:
			var point1:Point = area[area.length-2];
			var point2:Point = area[area.length-1];
			var point3:Point = new Point((this._page.book.width/2)*this._page.book.getLastFlippedCorner().x, this._page.book.height*this._page.book.getLastFlippedCorner().y);
			var point4:Point = area[0];
			var newArea:Array = [point1, point2];
			
			// adjust area (inside shadow is in a combination-area of the facing and flipping coordinates):
			var x:Number = (this._page.side == Page.LEFT) ? this._page.book.width : -this._page.book.width/2;
			var y:Number = (point2.y == 0) ? 0 : this._page.book.height;
			newArea.push(new Point(x, y));
			y = (point2.y == 0) ? this._page.book.height : 0;
			newArea.push(new Point(x, y));
			
			// creates Lines that will be defined in all following if-statements:
			var line:Line = new Line();
			var hLine:Line = new Line();
			
			// if only one corner is flipping:
			if (area.length == 3){
				
				x = (this._page.side == Page.LEFT) ? 0 : this._page.book.width/2;
				newArea.push(new Point(x, y));
				newArea.splice(1, 0, area[0]);
				
				// if flipped corner is outside of the Book its boundaries:
				if (area[0].y < 0 || area[0].y > this._page.book.height){
					
					var intersection1:Point;
					var intersection2:Point;
					
					line.a	= area[0];
					hLine.a	= newArea[4];
					hLine.b	= newArea[5];
					
					// calculate first intersection Point:
					line.b	= area[2];
					intersection1 = Line.getIntersection(line, hLine);
					
					// calculate second intersection Point:
					line.b	= area[1];
					intersection2 = Line.getIntersection(line, hLine);
					
					// replace the out-of-bounds Point with the two intersection Points:
					newArea.splice(1, 1, intersection2, intersection1);
					
				}
				
			}
			
			// if two corners are flipped:
			if (area.length == 4){
				
				var intersection:Point;
				
				// calculate intersection (if both flipped corners are out of the bounds of the Book):
				if ((area[0].y < 0 && area[1].y < 0) || (area[0].y > this._page.book.height && area[1].y > this._page.book.height)){
					
					var correctionIndex:uint;
					
					if (this._page.book.lastFlippedSide == Page.LEFT){
						correctionIndex = (area[0].x > area[1].x) ? 0 : 1;
						line.a	= (area[0].x > area[1].x) ? area[0] : area[1];
						line.b	= (area[0].x > area[1].x) ? area[3] : area[2];
						hLine.a	= (area[0].x > area[1].x) ? newArea[3] : newArea[2];
						hLine.b	= (area[0].x > area[1].x) ? newArea[0] : newArea[1];
					}else{
						correctionIndex = (area[0].x < area[1].x) ? 0 : 1;
						line.a	= (area[0].x < area[1].x) ? area[0] : area[1];
						line.b	= (area[0].x < area[1].x) ? area[3] : area[2];
						hLine.a	= (area[0].x < area[1].x) ? newArea[3] : newArea[2];
						hLine.b	= (area[0].x < area[1].x) ? newArea[0] : newArea[1];
					}
					
					intersection = Line.getIntersection(line, hLine);
					newArea[correctionIndex] = intersection;
					
				// calculate intersection (if only one flipped corner is out of the bounds of the Book):
				}else{
					
					newArea.splice(1, 0, area[1]);
					newArea.splice(2, 0, area[0]);
					line = new Line(newArea[1], newArea[2]);
					
					if (line.a.y < 0 || line.b.y < 0){
						hLine.a = (line.a.y < line.b.y) ? newArea[newArea.length-1] : newArea[newArea.length-3];
						hLine.b = (line.a.y < line.b.y) ? newArea[0] : newArea[newArea.length-2];
					}else{
						hLine.a = (line.a.y > line.b.y) ? newArea[newArea.length-1] : newArea[newArea.length-3];
						hLine.b = (line.a.y > line.b.y) ? newArea[0] : newArea[newArea.length-2];
					}
					
					if (line.a.y != hLine.a.y && line.b.y != hLine.a.y){
						intersection = Line.getIntersection(line, hLine);
						var spliceAt:uint;
						if (newArea[1].y < 0 || newArea[1].y > this._page.book.height)	spliceAt = 0;
						if (newArea[2].y < 0 || newArea[2].y > this._page.book.height)	spliceAt = newArea.length-4;
						newArea.splice(spliceAt, 2, intersection);
					}
					
				}
				
			}
			
			// calculate strength of the gradient:
			var strength:Number = Point.distance(point3, point4) / this._page.book.width;
			
			// create the model for the gradient:
			var matrix:Matrix = this.createNewMatrix(point1, point2, rotate);
			
			// draw gradient:
			graphics.beginGradientFill (GradientType.LINEAR,
										gradient.color,
										ArrayTool.adjustValues(gradient.alpha, strength, MathTool.MULTIPLICATION),
										gradient.ratio,
										matrix);
			DrawingTool.draw(graphics, newArea);
			graphics.endFill();
			
		}
		
		
		/**
		 * Draws a gradient to simulate a shadow on the next page of the Book.
		 * 
		 * @param	area	Array with coordinates (Point instances), typically the pPoints property of the ocf Object returned by the computeFlip method of the PageFlip class
		 * @param	tint	Indicates whether to draw a light or dark shadow
		 * @param	rotate	The correction of the gradient its rotation (from 0.0 to 1.0)
		 * 
		 * @see		Gradients#ROTATE_FULL;
		 * @see		Gradients#ROTATE_HALF;
		 * 
		 * @see		Gradients#LIGHT
		 * @see		Gradients#DARK
		 * 
		 * @see		Gradients#OUTSIDE
		 * 
		 * @see		Book#addGradients()
		 * @see		PageFlip#computeFlip()
		 * 
		 */
		public function drawOutside    (graphics:Graphics, 
										area:Array,
										tint:String=Gradients.DARK,
										rotate:Number=Gradients.ROTATE_FULL):void {
			
			if (this._page.hard){
				this.drawOutsideHard(graphics, area);
			}else{
				this.drawOutsideSmooth(graphics, area, tint, rotate);
			}
			
		}
		/**
		 * @see	Gradients#drawOutside()
		 * 
		 * @private
		 */
		protected function drawOutsideHard (graphics:Graphics, 
											area:Array):void {
			
			var gradient0:Object = Gradients.OUTSIDE_HARD.dark;
			var gradient1:Object = Gradients.OUTSIDE_HARD.light;
			
			// define the coordinates for the gradients:
			var area0:Rectangle = new Rectangle(0, 0, this._page.book.width/2, this._page.book.height);
			var area1:Rectangle = new Rectangle(0, 0, this._page.book.width/2, this._page.book.height);
			area0.left	= area[0].x - this._page.book.width/2;
			area0.right	= Math.min(area[0].x, area[1].x);
			area1.left	= Math.max(area[0].x, area[1].x);
			area1.right	= area[0].x + this._page.book.width/2;
			
			// calculate strength of the gradients:
			var strength0:Number = 1 - (area[1].x - area0.x) / this._page.book.width;
			var strength1:Number = Math.max(0, (area[1].x - area[0].x) / (this._page.book.width/2))
			
			// create the model for the gradients:
			var matrix0:Matrix = new Matrix();
			var matrix1:Matrix = new Matrix();
			matrix0.createGradientBox(this._page.book.width/2, this._page.book.height, 0, area0.left, 0);
			matrix1.createGradientBox(this._page.book.width/2, this._page.book.height, 0, area[0].x, 0);
			
			// draw left gradient:
			if (strength0 > 0){
				graphics.beginGradientFill (GradientType.LINEAR,
											gradient0.color,
											ArrayTool.adjustValues(gradient0.alpha, strength0, MathTool.MULTIPLICATION),
											gradient0.ratio,
											matrix0);
				DrawingTool.drawRect(graphics, area0);
				graphics.endFill();
			}
			
			// draw right gradient:
			if (strength1 > 0){
		  		graphics.beginGradientFill (GradientType.LINEAR,
											gradient1.color,
											ArrayTool.adjustValues(gradient1.alpha, strength1, MathTool.MULTIPLICATION),
											gradient1.ratio,
											matrix1);
				DrawingTool.drawRect(graphics, area1);
				graphics.endFill();
			}
			
		}
		/**
		 * @see	Gradients#drawOutside()
		 * 
		 * @private
		 */
		protected function drawOutsideSmooth   (graphics:Graphics, 
												area:Array,
												tint:String=Gradients.DARK,
												rotate:Number=Gradients.ROTATE_FULL):void {
			
			var gradient:Object = Gradients.OUTSIDE_SMOOTH[tint];
			
			// define the points that the calculation will be based on:
			var newArea:Array;
			var point1:Point = area[area.length-3];
			var point2:Point = area[area.length-2];
			// calculation for normal pageflips:
			if (!this._page.book.tearActive){
				newArea = [point1, point2];
				if (newArea[0].y == 0 || newArea[1].y == 0){
					newArea.push(new Point(this._page.side*this._page.book.width/2, 0));
				}else{
					newArea.push(new Point(this._page.side*this._page.book.width/2, this._page.book.height));
				}
				if (area.length == 4){
					var spliceAt:uint = (newArea[1].y == 0) ? 0 : newArea.length - 1;
					if (newArea[0].y == this._page.book.height || newArea[1].y == this._page.book.height){
						newArea.splice(spliceAt, 0, new Point(this._page.side*this._page.book.width/2, this._page.book.height));
					}
				}
			}
			// calculation for tearing pageflips:
			if (this._page.book.tearActive){
				newArea = ArrayTool.copy(area);
		 		if (newArea[0].y == 0){
					newArea[0].y = newArea[3].y = this._page.book.height;
				}else{
					newArea[0].y = newArea[3].y = 0;
				}
			}
			
			// define additional points and calculate strength of the gradient:
			var point3:Point = newArea[newArea.length-1];
			var point4:Point = Point.interpolate(point1, point2, 0.5);
			var max:Number;
			var strength:Number;
			if (!this._page.book.tearActive){
				max = this._page.book.width/2;
				strength = 1 - Math.abs(max/2-Math.abs(point3.x-point4.x)) / (max/2);
			}else{
				max = this._page.book.height;
				strength = 1 - Math.abs(point3.y-point4.y)/max;
			}
			
			// create the model for the gradient:
			var matrix:Matrix = this.createNewMatrix(point1, point2, rotate);
			
			// draw gradient:
			graphics.beginGradientFill (GradientType.LINEAR,
										gradient.color,
										ArrayTool.adjustValues(gradient.alpha, strength, MathTool.MULTIPLICATION),
										gradient.ratio,
										matrix);
			DrawingTool.draw(graphics, newArea);
			graphics.endFill();
			
		}
		
		
		/**
		 * Draws a gradient to simulate depth on the flipside of the Page.
		 * 
		 * @param	area	Array with coordinates (Point instances), typically the cPoints property of the ocf Object returned by the computeFlip method of the PageFlip class
		 * @param	tint	Indicates whether to draw a highlight (Gradients.LIGHT) or shadow (Gradients.DARK)
		 * @param	rotate	The correction of the gradient its rotation (from 0.0 to 1.0)
		 * 
		 * @see		Gradients#ROTATE_FULL;
		 * @see		Gradients#ROTATE_HALF;
		 * 
		 * @see		Gradients#LIGHT
		 * @see		Gradients#DARK
		 * 
		 * @see		Gradients#FLIPSIDE
		 * 
		 * @see		Book#addGradients()
		 * @see		PageFlip#computeFlip()
		 * 
		 */
		public function drawFlipside   (graphics:Graphics, 
										area:Array,
										tint:String=Gradients.LIGHT,
										rotate:Number=Gradients.ROTATE_FULL):void {
			
			// this method is not applicable to hard Pages:
			if (this._page.hard){
				return;
			}
			
			var gradient:Object = Gradients.FLIPSIDE[tint];
			
			// define the points that the calculation will be based on:
			var point1:Point = area[area.length-2];
			var point2:Point = area[area.length-1];
			
			// calculate strength of the gradient:
			var point3:Point = Point.interpolate(point1, point2, 0.5);
			var point4:Point = Point.interpolate(area[0], area[1], 0.5);
			var max:Number = this._page.book.width/2;
			var strength:Number = 0.5 + (Math.abs(point3.x-point4.x)/max) * 0.5;
			
			// create the model for the gradient:
			var matrix:Matrix = this.createNewMatrix(point1, point2, rotate);
			
			// draw gradient:
			graphics.beginGradientFill (GradientType.LINEAR,
										gradient.color,
										ArrayTool.adjustValues(gradient.alpha, strength, MathTool.MULTIPLICATION),
										gradient.ratio,
										matrix);
			DrawingTool.draw(graphics, area);
			graphics.endFill();
			
		}
		
		
		/**
		 * Returns a Matrix instance with a gradientbox with the properties read from the provided parameters.
		 * 
		 * @param	point1	Point indicating the first coordinate in a line used for calculating the gradient its rotation and position
		 * @param	point2	Point indicating the second coordinate in a line used for calculating the gradient its rotation and position
		 * @param	rotate	The correction of the gradient its rotation (from 0.0 to 1.0)
		 * 
		 * @see		Gradients#ROTATE_FULL;
		 * @see		Gradients#ROTATE_HALF;
		 * 
		 * @see		Gradients#drawInside()
		 * @see		Gradients#drawOutside()
		 * @see		Gradients#drawFlipside()
		 * 
		 * @return	Matrix
		 * 
		 * @private
		 */
		protected function createNewMatrix (point1:Point, point2:Point, rotate:Number=Gradients.ROTATE_FULL):Matrix {
			
			rotate *= Math.PI * 2
			
			// get offset and angle:
			var offset:Point =	this.getOffset(point1, point2);
			var angle:Number =	Geom.getAngle (point1, point2) - rotate;
			
			// define sizes:
			var larger:Number	= Math.max(this._page.book.width/2, this._page.book.height);
			var smaller:Number	= Math.min(this._page.book.width/2, this._page.book.height);
			if (larger == this._page.book.height){
				offset.x -= (larger-smaller) / 2;
			}else{
				offset.y -= (larger-smaller) / 2;
			}
			
			// create the model for the gradient:
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(larger, larger, angle, offset.x, offset.y);
			
			// return value:
			return matrix;
			
		}
		/**
		 * Calculates offset for the createGradientBox() method executed in createNewMatrix().
		 * 
		 * @param	point1	Point indicating the first coordinate in a line used for calculating the gradient its position
		 * @param	point2	Point indicating the second coordinate in a line used for calculating the gradient its position
		 * 
		 * @see		Gradients#createNewMatrix()
		 * 
		 * @return	Point with x (for x-offset) and y (y-offset) properties
		 * 
		 * @private
		 */
		protected function getOffset (point1:Point, point2:Point):Point {
			var middle:Point =	new Point(this._page.book.width/2/2, this._page.book.height/2);
			var average:Point =	Point.interpolate(point1, point2, 0.5);
			var offset:Point =	new Point(average.x - middle.x, average.y - middle.y);
			return offset;
		}
		
		
	// ACCESSORS:
		
		/**
		 * Page this Gradients instance is associated with.
		 * 
		 * @see	Page
		 * 
		 */
		public function get page ():Page {
			return this._page;
		}
		
		/**
		 * The maximum alpha value for solid shadows or highlights on Pages.
		 * 
		 * @default	0.3
		 */
		public function get solidColorAlpha ():Number {
			return this._solidColorAlpha;
		}
		public function set solidColorAlpha (value:Number):void {
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			this._solidColorAlpha = value;
		}
		
		
	}
	
	
}