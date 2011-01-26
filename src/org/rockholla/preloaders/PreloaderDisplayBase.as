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
package org.rockholla.preloaders
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.events.FlexEvent;
	import mx.preloaders.IPreloaderDisplay;

	public class PreloaderDisplayBase extends Sprite implements IPreloaderDisplay
	{
		// Settings           fiddle with these as you like
		protected var _msecMinimumDuration:Number = 500;   // even if the preloader is done, take this long to "finish"
		
		// Implementation variables, used to make everything work properly
		protected var _isInitComplete:Boolean = false;
		protected var _timer:Timer;                 // we have a timer for animation
		protected var _bytesLoaded:uint = 0;
		protected var _bytesExpected:uint = 1;      // we start at 1 to avoid division by zero errors.
		protected var _fractionLoaded:Number = 0;   // 0-1
		
		protected var _preloader:Sprite;
		
		public function PreloaderDisplayBase()
		{
			super();
		}
		
		// This function is called whenever the state of the preloader changes.  Use the _fractionLoaded variable to draw your progress bar.
		virtual protected function _draw():void
		{
		}
		
		////
		//// IPreloaderDisplay interface elements
		////   check out the docs on IPreloaderDisplay to see more details.
		
		// This function is called when the PreloaderDisplayBase has been created and is ready for action.
		virtual public function initialize():void
		{
			this._timer = new Timer(1);
			this._timer.addEventListener(TimerEvent.TIMER, this.timerHandler);
			this._timer.start();
		}
		
		/**
		 *  The Preloader class passes in a reference to itself to the display class
		 *  so that it can listen for events from the preloader.
		 */
		// This code comes from DownloadProgressBar.  I have modified it to remove some unused event handlers.
		virtual public function set preloader(value:Sprite):void
		{
			this._preloader = value;
			
			value.addEventListener(ProgressEvent.PROGRESS, progressHandler);    
			value.addEventListener(Event.COMPLETE, completeHandler);
			
			value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
			value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
		}
		
		virtual public function set backgroundAlpha(alpha:Number):void{}
		virtual public function get backgroundAlpha():Number { return 1; }
		
		protected var _backgroundColor:uint = 0xffffffff;
		virtual public function set backgroundColor(color:uint):void { _backgroundColor = color; }
		virtual public function get backgroundColor():uint { return _backgroundColor; }
		
		virtual public function set backgroundImage(image:Object):void {}
		virtual public function get backgroundImage():Object { return null; }
		
		virtual public function set backgroundSize(size:String):void {}
		virtual public function get backgroundSize():String { return "auto"; }
		
		protected var _stageHeight:Number = 300;
		virtual public function set stageHeight(height:Number):void { _stageHeight = height; }
		virtual public function get stageHeight():Number { return _stageHeight; }
		
		protected var _stageWidth:Number = 400;
		virtual public function set stageWidth(width:Number):void { _stageWidth = width; }
		virtual public function get stageWidth():Number { return _stageWidth; }
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		// Called from time to time as the download progresses.
		virtual protected function progressHandler(event:ProgressEvent):void
		{
			var bytesLoaded:Number = event.bytesLoaded;
			var bytesExpected:Number = event.bytesTotal;
			this._fractionLoaded = bytesLoaded / bytesExpected;
			this._draw();
		}
		
		// Called when the download is complete, but initialization might not be done yet.  (I *think*)
		// Note that there are two phases- download, and init
		virtual protected function completeHandler(event:Event):void
		{
		}
		
		
		// Called from time to time as the initialization continues.        
		virtual protected function initProgressHandler(event:Event):void
		{
			this._draw();
		}
		
		// Called when both download and initialization are complete    
		virtual protected function initCompleteHandler(event:Event):void
		{
			this._isInitComplete = true;
		}
		
		// Called as often as possible
		virtual protected function timerHandler(event:Event):void
		{
			if (this._isInitComplete && getTimer() > this._msecMinimumDuration)
			{    
				// We're done!
				dispatchEvent(new Event(Event.COMPLETE));
				this._timer.stop();
			}
			this._draw();
		}
	}
}