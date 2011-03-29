package com.CGFinal.Controls.Skins {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class SkinItem extends MovieClip	{
		
		public function SkinItem() {
			stop();
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if (value) {
				gotoAndStop("normal");
			}else {
				gotoAndStop("disable");
			}
		}
	}
	
}