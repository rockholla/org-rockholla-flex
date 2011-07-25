package org.rockholla.positioning
{
	public class Orientation
	{
		public static const HORIZONTAL:Orientation = new Orientation("horizontal");
		public static const VERTICAL:Orientation = new Orientation("vertical");
		
		protected var _type:String;
		
		public function Orientation(type:String)
		{
			if(type != HORIZONTAL.toString() && type != VERTICAL.toString())
			{
				throw new PositioningError("Invalid Orientation: " + type);
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