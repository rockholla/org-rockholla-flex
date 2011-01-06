package org.rockholla.utils
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;

	public class ObjectHelper
	{
		
		public static function getType(object:Object):Class
		{
			return Class(getDefinitionByName(getQualifiedClassName(object)));
		}
		
		public static function dump(object:Object):void
		{
			trace(ObjectUtil.toString(object));
		}
		
	}
}