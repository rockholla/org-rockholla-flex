package org.rockholla.utils
{
	public class TypesUtil
	{
		
		public static function parseBoolean(value:String):Boolean
		{
			switch(value) 
			{     
				case "1":     
				case "true":     
				case "yes": 
				{
					return true;
				}
				case "0":     
				case "false":     
				case "no":
				{
					return false;
				}
				default:
				{
					return Boolean(value);
				}
			}
		}
		
	}
}