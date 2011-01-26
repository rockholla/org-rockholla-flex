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
package org.rockholla.containers
{
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.SkinnableContainer;
	
	/**
	 * The LoadingContainer provides a mask to turn on and off to grant the container the ability of two states
	 * <ul>
	 * 		<li>Loading information, and therfore disabled</li>
	 * 		<li>Idle, and therefore enabled</li>
	 * </ul>
	 * 
	 * @langversion 3.0
	 */
	public class LoadingContainer extends SkinnableContainer
	{
		/**
		 * The embedded "loading" animation icon
		 */
		[Embed(source="../assets/swf/loading-indicator.swf")]
		private var loadingAnimation:Class;

		/**
		 * The container for the mask and loading image
		 */
		protected var _uiContainer:UIComponent;
		/**
		 * The actual component to display the loading animation
		 */
		protected var _loadImage:Image;
		/**
		 * The container for the mask
		 */
		protected var _fade:UIComponent;
		/**
		 * Designates whether in load or idle state
		 */
		protected var _isLoading:Boolean;
		
		/**
		 * Constructore
		 */
		public function LoadingContainer()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
		}
		
		/**
		 * Executed when the component is done being created
		 * 
		 */
		protected function _onCreationComplete(event:FlexEvent):void
		{
			
		}
		
		/**
		 * Public access to set the state of the container
		 * 
		 * @param isLoading	if true, the mask and loading icon are displayed, and the container contents are "disabled"
		 * 
		 */
		[Bindable]
		public function set isLoading(isLoading:Boolean):void
		{
			this._isLoading = isLoading;
			this.invalidateDisplayList();
		}
		/**
		 * Determines the current state of the container, whether it's in loading state or not
		 * 
		 * @return true or false
		 * 
		 */
		public function get isLoading():Boolean
		{
			return this._isLoading;
		}
		
		/**
		 * Overrides the parent children creation by adding the necessary mask and icon elements
		 * as children to this container
		 * 
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			this._uiContainer = new UIComponent();
			this._loadImage = new Image();
			this._loadImage.width = 31;
			this._loadImage.height = 31;
			this._fade = new UIComponent();		
			
			this.addElement(this._uiContainer);
		}
		
		/**
		 * Will update the layout/display of the container based on whether or not its state is
		 * currently loading or not
		 * 
		 * @param unscaledWidth		the unscaledWidth of this component
		 * @param unscaledHeight	the unscaledHeight of this component 
		 * 
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(!this._isLoading)
			{
				this._uiContainer.visible = false;
				if(this._uiContainer.contains(this._loadImage))
				{
					this._uiContainer.removeChild(this._loadImage);
				}
				if(this._uiContainer.contains(this._fade))
				{
					this._uiContainer.removeChild(this._fade);
				}
				return;
			}
			
			if(this._uiContainer)
			{
				this._uiContainer.width = unscaledWidth;
				this._uiContainer.height = unscaledHeight;	
			}
			
			if(this._isLoading)
			{	
				if(this._fade)
				{
					this._uiContainer.addChild(this._fade);
					this._fade.graphics.clear();
					this._fade.graphics.beginFill(0x9c9c9c, 0.4);
					this._fade.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					this._fade.graphics.endFill();	
				}
				if(this._loadImage)
				{
					this._loadImage.source = this.loadingAnimation;
					this._uiContainer.addChild(this._loadImage);
					this._loadImage.x = unscaledWidth/2 - this._loadImage.width/2;
					this._loadImage.y = unscaledHeight/2 - this._loadImage.height/2;
				}
				
				this._uiContainer.visible = true;
				this._uiContainer.width = 0;
				this._uiContainer.height = 0;
				
			}
		}
		
	}
}