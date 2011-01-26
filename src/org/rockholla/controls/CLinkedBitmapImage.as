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
	import flash.events.MouseEvent;

	public class CLinkedBitmapImage extends Button
	{
		[Bindable]
		public var source:Class;

		protected var _onClick:Function;
		
		public function CLinkedBitmapImage()
		{
			super();
		}
		
		public function set onClick(onClick:Function):void
		{
			if(this._onClick != null)
			{
				this.removeEventListener(MouseEvent.CLICK, this._onClick);
			}
			this._onClick = onClick;
			this.addEventListener(MouseEvent.CLICK, this._onClick);
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			if(value == true)
			{
				if(this._onClick != null)
				{
					this.onClick = this._onClick;
				}
			}
		}
	}
}