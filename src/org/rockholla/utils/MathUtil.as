package org.rockholla.utils
{
	public class MathUtil
	{
		public static function randomInRange(min:Number, max:Number):Number 
		{
			var scale:Number = max - min;
			return Math.random() * scale + min;
		}
	}
}