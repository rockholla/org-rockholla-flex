package org.rockholla.utils  {
	
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	
	import mx.core.FlexGlobals;
	
	public class Window 
	{
		
		public static var isAir:Boolean = (Capabilities.playerType == "Desktop");
		public static var isFlashPlayer:Boolean = (Capabilities.playerType == "StandAlone");
		public static var isBrowser:Boolean = (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn");
		public static var isOther:Boolean = (Capabilities.playerType == "External");
		
		public static function enableFullScreenSwitching():void
		{
			FlexGlobals.topLevelApplication.systemManager.stage.addEventListener(
				KeyboardEvent.KEY_DOWN, 
				function(event:KeyboardEvent):void
				{
					if((event.ctrlKey || event.controlKey) && event.keyCode == 70)
					{
						Window.toggleFullScreen();
					}
				}
			);
		}
		
		public static function toggleFullScreen():void
		{
			var displayState:String = FlexGlobals.topLevelApplication.systemManager.stage.displayState;
			
			if(displayState == StageDisplayState.FULL_SCREEN || displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
			{
				FlexGlobals.topLevelApplication.systemManager.stage.displayState = StageDisplayState.NORMAL;
			}
			else if(displayState == StageDisplayState.NORMAL)
			{
				if(!Window.isAir) FlexGlobals.topLevelApplication.systemManager.stage.displayState = StageDisplayState.FULL_SCREEN;
				else FlexGlobals.topLevelApplication.systemManager.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}

	}
	
}