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