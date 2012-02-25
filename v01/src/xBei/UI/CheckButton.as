package xBei.UI
{
	import flash.events.*;
	import flash.filters.*;

	[Event(name = "change", type = "flash.events.Event")]
	public class CheckButton extends XMovieClip
	{
		private var _checked:Boolean = false;
		private static var _itemFilter:Array = [new GlowFilter(0x0033ff,.5,5,5,2,BitmapFilterQuality.HIGH)];
		public function get Checked():Boolean {
			return _checked;
		}
		public function set Checked(v:Boolean):void {
			//if(_checked != v){
			_checked = v;
			gotoAndStop(v?"checked":"unchecked");
			//}
		}
		public function CheckButton() {
			super();
			this.useHandCursor = true;
			this.buttonMode = true;
			stop();
			this.addEventListener(MouseEvent.CLICK, DPE_Click);
			this.addEventListener(MouseEvent.ROLL_OVER, DPE_RollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, DPE_RollOut);
		}
		//Events
		private function DPE_Click(e:MouseEvent):void {
			//trace(this, ".enabled=", this.enabled);
			if (enabled == false) return;
			Checked = !Checked;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		private function DPE_RollOver(e:MouseEvent):void {
			//this.filters = CheckButton._itemFilter;
			if(this.enabled){
				gotoAndStop("over");
			}
		}
		private function DPE_RollOut(e:MouseEvent):void {
			if(this.enabled){
				gotoAndStop(this.Checked?"checked":"unchecked");
			}
		}
	}
}