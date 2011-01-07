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
package org.rockholla.xml
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class XmlData extends EventDispatcher implements IXmlData
	{
		protected var _built:Boolean = false;
		protected var _xml:XML;
		protected var _xmlModel:XML;
		
		public function XmlData(... args)
		{
			if(args.length == 1 && args[0] is XML)
			{
				// We will be building the object from existing XML
				this._xml = args[0] as XML;
				this.buildExisting();
			}
			else
			{
				// Otherwise, we initial values to help us build XML from the internal model
				this.buildNew(args);
			}
		}
		
		public function get xml():XML
		{
			return this._xml;
		}
		
		public function set xml(xml:XML):void
		{
			this._xml = xml;
		}
		
		public function buildNew(args:Array):void 
		{
			this._xml = this._xmlModel;
		}		
		public function buildExisting():void {}
		
	}
}