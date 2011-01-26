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
package org.rockholla.utils  
{
	
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