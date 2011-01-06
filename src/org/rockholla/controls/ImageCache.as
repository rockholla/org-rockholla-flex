package org.rockholla.controls
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import mx.controls.Image;
	
	public class ImageCache extends Dictionary
	{
		private static var instance:ImageCache;
		
		public static function getInstance():ImageCache
		{
			return (instance ? instance : new ImageCache()) as ImageCache;
		}
		
		public function ImageCache()
		{
			super(false);
		}
		
		public function add(key:Object, bitmapData:BitmapData):void
		{
			this[key] = bitmapData;
		}
		
		public function hasKey(key:Object):Boolean
		{
			for(var existingKey:Object in this)
			{
				if(existingKey == key) return true;
			}
			return false;
		}
		
		protected function _getKeys():Array
		{
			var a:Array = new Array();
			
			for (var key:Object in this)
			{
				a.push(key);
			}
			
			return a;
		}
		
		protected function _getValues():Array
		{
			var a:Array = new Array();
			
			for each (var value:Object in this)
			{
				a.push(value);
			}
			
			return a;
		}
	}
}