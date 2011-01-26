/*
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
	import flash.events.Event;
	
	import mx.controls.Image;
	
	public class CachedImage extends Image
	{
		public function CachedImage()
		{
			super();
			this.addEventListener(Event.COMPLETE, this._onComplete);
		}
		
		protected function _onComplete(event:Event):void
		{
			trace('running complete...');
			var image:Image = event.target as Image;
			var imageCache:ImageCache = ImageCache.getInstance();
			if(!imageCache.hasKey(image.source))
			{
				var bitmapData:BitmapData = new BitmapData(image.content.width, image.content.height, true);
				bitmapData.draw(image.content);
				imageCache.add(image.source, bitmapData);
			}
		}
	}
}