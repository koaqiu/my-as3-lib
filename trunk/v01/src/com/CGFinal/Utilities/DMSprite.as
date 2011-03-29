package com.CGFinal.Utilities {
	import com.CGFinal.Interface.IDepth;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class DMSprite extends Sprite implements IDepth {
		private var _depth:int;
		/**
		 * 深度
		 */
		public function get depth():int {
			return _depth;
		}
		public function set depth(v:int):void {
			_depth = v;
		}		
	}
	
}
