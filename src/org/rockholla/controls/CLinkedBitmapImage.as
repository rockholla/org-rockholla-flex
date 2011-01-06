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