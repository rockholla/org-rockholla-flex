package org.rockholla.positioning
{
	public class Alignment
	{
		public static const LEFT:Alignment = new Alignment("left");
		public static const RIGHT:Alignment = new Alignment("right");
		public static const CENTER:Alignment = new Alignment("center");
		
		protected var _type:String;
		
		public function Alignment(type:String)
		{
			if(type != LEFT.toString() && type != RIGHT.toString() && type != CENTER.toString())
			{
				throw new PositioningError("Invalid Alignment: " + type);
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