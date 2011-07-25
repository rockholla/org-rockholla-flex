package org.rockholla.positioning
{
	public class Placement
	{
		public static const TOP:Placement = new Placement("top");
		public static const RIGHT:Placement = new Placement("right");
		public static const BOTTOM:Placement = new Placement("bottom");
		public static const LEFT:Placement = new Placement("left");
		public static const CENTER:Placement = new Placement("center");
		
		protected var _type:String;
		
		public function Placement(type:String)
		{
			if(type != TOP.toString() && type != RIGHT.toString() && type != BOTTOM.toString() && type != LEFT.toString() && type != CENTER.toString())
			{
				throw new PositioningError("Invalid Placement: " + type);
				return;
			}
			this._type = type;
		}
		
		public function toString():String
		{
			return this._type;
		}
	}
}