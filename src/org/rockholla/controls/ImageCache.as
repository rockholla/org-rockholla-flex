/**
 * 
 *	This is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *	 
 */
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