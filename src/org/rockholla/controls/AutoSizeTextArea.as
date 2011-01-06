package org.rockholla.controls
{
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.TextArea;
	
	public class AutoSizeTextArea extends TextArea
	{
		
		public function AutoSizeTextArea()
		{
			super();
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, _onUpdateComplete);	
		}
		
		protected function _onUpdateComplete(event:FlexEvent):void
		{
			this.heightInLines = NaN;
		}

	}
}