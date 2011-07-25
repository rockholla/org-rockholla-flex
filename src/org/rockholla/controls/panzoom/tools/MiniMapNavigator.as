package org.rockholla.controls.panzoom.tools
{
	import mx.containers.Box;
	
	public class MiniMapNavigator extends Box
	{
		public function MiniMapNavigator()
		{
			super();
			this.width = 200;
			this.height = 180;
			this.setStyle("borderColor", 0xFF0000);
			this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", 1);
		}
	}
}