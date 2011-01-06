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