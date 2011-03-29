package com.CGFinal.Controls.Skins {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class ButtonSkin extends SkinItem{
		private var _isOver:Boolean = false;
		public function ButtonSkin() {
			stop();
			this.useHandCursor = true;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.CLICK,onClick);
		}
		//Events
		private function onRollOver(e:MouseEvent):void {
			if (enabled == false) return;
			_isOver = true;
			gotoAndStop("over");
		}
		private function onRollOut(e:MouseEvent):void {
			if (enabled == false) return;
			_isOver = false;
			gotoAndStop("normal");
		}
		private function onMouseDown(e:MouseEvent):void {
			if (enabled == false) return;
			gotoAndStop("down");
		}
		private function onMouseUp(e:MouseEvent):void {
			//trace("mouse up",_isOver,enabled);
			if (enabled == false) return;
			gotoAndStop(_isOver?"over":"normal");
		}
		private function onClick(e:MouseEvent):void {
			if (enabled == false) {
				e.stopImmediatePropagation();
				//dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
	}
}
