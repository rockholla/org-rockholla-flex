package org.rockholla.positioning
{
	import flash.events.EventDispatcher;
	
	import org.rockholla.events.PositioningEvent;
	
	public class Positioning extends EventDispatcher
	{
		
		protected var _placement:Placement;
		protected var _orientation:Orientation;
		protected var _alignment:Alignment;
		
		public function Positioning(placement:Placement, orientation:Orientation, alignment:Alignment)
		{
			this._placement = placement;
			this._orientation = orientation;
			this._alignment = alignment;
		}
		
		[Bindable]
		public function set placement(value:Placement):void
		{
			this._placement = value;
			this.dispatchEvent(new PositioningEvent(PositioningEvent.PLACEMENT_UPDATED));
		}
		
		public function get placement():Placement
		{
			return this._placement;
		}
		
		[Bindable]
		public function set orientation(value:Orientation):void
		{
			this._orientation = value;
			this.dispatchEvent(new PositioningEvent(PositioningEvent.ORIENTATION_UPDATED));
		}
		
		public function get orientation():Orientation
		{
			return this._orientation;
		}
		
		[Bindable]
		public function set alignment(value:Alignment):void
		{
			this._alignment = value;
			this.dispatchEvent(new PositioningEvent(PositioningEvent.ALIGNMENT_UPDATED));
		}
		
		public function get alignment():Alignment
		{
			return this._alignment;
		}
		
	}
}