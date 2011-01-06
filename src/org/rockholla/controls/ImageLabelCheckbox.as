package org.rockholla.controls
{
	import org.rockholla.skins.ImageLabelCheckboxSkin;
	
	import flash.events.Event;
	
	import spark.components.CheckBox;
	import spark.primitives.BitmapImage;
	
	[Event(name="selectedChanged", type="flash.events.Event")]
	public class ImageLabelCheckbox extends CheckBox
	{
		[Bindable]
		public var source:Class;
		
		[Bindable]
		public var imageSide:String = "right";
		
		public function ImageLabelCheckbox()
		{
			super();
			this.setStyle('skinClass', org.rockholla.skins.ImageLabelCheckboxSkin);
		}

		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			dispatchEvent(new Event("selectedChanged"));
		}
	}
}