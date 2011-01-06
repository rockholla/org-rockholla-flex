package org.rockholla.controls
{
	import spark.components.Button;
	
	public class Button extends spark.components.Button
	{
		public function Button()
		{
			super();
			this.buttonMode = true;
			this.mouseChildren = false;
			this.useHandCursor = true;
		}
	}
}