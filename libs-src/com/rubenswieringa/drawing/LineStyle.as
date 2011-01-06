package com.rubenswieringa.drawing {
	
	
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	
	
	/**
	 * Stores line-styles.
	 * 
	 * @author		Ruben Swieringa
	 * 				ruben.swieringa@gmail.com
	 * 				www.rubenswieringa.com
	 * 				www.rubenswieringa.com/blog
	 * @version		1.0.0
	 * @see			DrawingTool
	 * @see			http://livedocs.adobe.com/flex/2/langref/flash/display/Graphics.html#lineStyle()
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
	public class LineStyle {
		
		
		/**
		 * @private
		 */
		protected var _dash:Number = 2;
		/**
		 * @private
		 */
		protected var _space:Number = -1;
		/**
		 * @private
		 */
		protected var _thickness:Number = 1;
		/**
		 * @private
		 */
		protected var _alpha:Number = 1.0;
		/**
		 * @private
		 */
		protected var _scaleMode:String = "normal";
		/**
		 * @private
		 */
		protected var _caps:String;
		/**
		 * @private
		 */
		protected var _joints:String;
		/**
		 * @private
		 */
		protected var _miterLimit:Number = 3;
		
		/**
		 * If true, the line this LineStyle instance is applied to will have a dashed line.
		 * @default	false
		 * @see		LineStyle#dash
		 * @see		LineStyle#space
		 */
		public var dashEnabled:Boolean = false;
		/**
		 * Line color.
		 * @default	0
		 */
		public var color:uint = 0;
		/**
		 * A Boolean value that specifies whether to hint strokes to full pixels.
		 * @default	false
		 */
		public var pixelHinting:Boolean = false;
		
		/**
		 * @see		LineStyle#dash
		 * @private
		 */
		protected static const MIN_DASH:Number = 0.1;
		
		
		/**
		 * Constructor.
		 * 
		 * @see		LineStyle#thickness
		 * @see		LineStyle#color
		 * @see		LineStyle#alpha
		 * @see		LineStyle#pixelHinting
		 * @see		LineStyle#scaleMode
		 * @see		LineStyle#caps
		 * @see		LineStyle#joints
		 * @see		LineStyle#miterLimit
		 * 
		 * @see		http://livedocs.adobe.com/flex/2/langref/flash/display/Graphics.html#lineStyle()
		 */
		public function LineStyle  (thickness:Number=1, 
									color:uint=0, 
									alpha:Number=1.0, 
									pixelHinting:Boolean=false, 
									scaleMode:String="normal", 
									caps:String=null, 
									joints:String=null, 
									miterLimit:Number=3):void {
			
			this.thickness = thickness;
			this.color = color;
			this.alpha = alpha;
			this.pixelHinting = pixelHinting;
			this.scaleMode = scaleMode;
			this.caps = caps;
			this.joints = joints;
			this.miterLimit = miterLimit;
			
		}
		
		
		/**
		 * An integer that indicates the thickness of the line in points; valid values are 0 to 255.
		 */
		public function get thickness ():Number {
			return this._thickness;
		}
		public function set thickness (value:Number):void {
			if (value < 0) value = 0;
			if (value > 255) value = 255;
			this._thickness = value;
		}
		/**
		 * A number that indicates the alpha value of the color of the line; valid values are 0 to 1.
		 */
		public function get alpha ():Number {
			return this._alpha;
		}
		public function set alpha (value:Number):void {
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			this._alpha = value;
		}
		/**
		 * A value from the LineScaleMode class that specifies which scale mode to use.
		 * @see		http://livedocs.adobe.com/flex/2/langref/flash/display/LineScaleMode.html
		 */
		public function get scaleMode ():String {
			return this._scaleMode;
		}
		public function set scaleMode (value:String):void {
			if (value == LineScaleMode.NONE || value == LineScaleMode.NORMAL || value == LineScaleMode.HORIZONTAL || value == LineScaleMode.VERTICAL ){
				this._scaleMode = value;
			}
		}
		/**
		 * A value from the CapsStyle class that specifies the type of caps at the end of lines.
		 * @see		http://livedocs.adobe.com/flex/2/langref/flash/display/CapsStyle.html
		 */
		public function get caps ():String {
			return (this._caps != null) ? this._caps : CapsStyle.ROUND;
		}
		public function set caps (value:String):void {
			if (value == CapsStyle.NONE || value == CapsStyle.ROUND || value == CapsStyle.SQUARE){
				this._caps = value;
			}
		}
		/**
		 * A value from the JointStyle class that specifies the type of joint appearance used at angles.
		 * @see		http://livedocs.adobe.com/flex/2/langref/flash/display/JointStyle.html
		 */
		public function get joints ():String {
			return (this._joints != null) ? this._joints : JointStyle.ROUND;
		}
		public function set joints (value:String):void {
			if (value == JointStyle.BEVEL || value == JointStyle.MITER || value == JointStyle.ROUND){
				this._joints = value;
			}
		}
		/**
		 * A number that indicates the limit at which a miter is cut off. Valid values range from 1 to 255.
		 */
		public function get miterLimit ():Number {
			return this._miterLimit;
		}
		public function set miterLimit (value:Number):void {
			if (value < 1) value = 1;
			if (value > 255) value = 255;
			this._miterLimit = value;
		}
		
		
		/**
		 * Sets a Graphics instance its lineStyle equal to the values of the native supported properties (all of which can be set through this class its constructor).
		 * 
		 * @param	graphics	A Graphics instance.
		 * 
		 * @see		LineStyle#thickness
		 * @see		LineStyle#color
		 * @see		LineStyle#alpha
		 * @see		LineStyle#pixelHinting
		 * @see		LineStyle#scaleMode
		 * @see		LineStyle#caps
		 * @see		LineStyle#joints
		 * @see		LineStyle#miterLimit
		 * 
		 */
		public function applyTo (graphics:Graphics):void {
			graphics.lineStyle (this.thickness, 
								this.color, 
								this.alpha, 
								this.pixelHinting, 
								this.scaleMode, 
								this.caps, 
								this.joints, 
								this.miterLimit);
		}
		
		
		/**
		 * The length of a dash in a dashed line. When this property is set, dashEnabled is automatically set to true.
		 * 
		 * @default	2
		 * 
		 * @see		LineStyle#space
		 * @see		LineStyle#dashEnabled
		 */
		public function get dash ():Number {
			return this._dash;
		}
		public function set dash (value:Number):void {
			if (value < LineStyle.MIN_DASH) value = LineStyle.MIN_DASH;
			this._dash = value;
			this.dashEnabled = true;
		}
		
		
		/**
		 * The space between two dashes in a dashed line. If untouched, the value of the space property will be equal to that of the dash property.
		 * 
		 * @default	2
		 * 
		 * @see		LineStyle#dash
		 * @see		LineStyle#dashEnabled
		 */
		public function get space ():Number {
			return (this._space == -1) ? this._dash : this._space;
		}
		public function set space (value:Number):void {
			if (value < LineStyle.MIN_DASH) value = LineStyle.MIN_DASH;
			this._space = value;
		}
		
		
	}
	
	
}