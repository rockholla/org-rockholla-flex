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