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
package org.rockholla.events
{
	import flash.events.Event;
	
	/**
	 * An event specific to the PanZoomComponent
	 * 
	 */
	public class PanZoomEvent extends Event
	{
		
		/**
		 * Event relevant to zooming
		 */
		public static const ZOOM:String = "zoom";
		/**
		 * Event relevant to panning
		 */
		public static const PAN:String = "pan";
		/**
		 * Content redrawn
		 */
		public static const CONTENT_REDRAWN:String = "contentRedrawn";
		
		/**
		 * Constructor
		 * 
		 */
		public function PanZoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}