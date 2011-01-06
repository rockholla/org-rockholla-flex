package org.rockholla.controls
{
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	
	public class CButtonBitmapImage extends Button
	{	
		[Bindable]
		public var source:Class;
		
		protected var _onClick:Function;
		
		public function CButtonBitmapImage()
		{
			super();
		}
	}
}