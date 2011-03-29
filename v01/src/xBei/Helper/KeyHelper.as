package xBei.Helper{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	/**
	 * 检测按键是否被按下 
	 * @author KoaQiu
	 * 
	 */
	public class KeyHelper{
		private static var _keyobj:Object = {};
		private static var _ins:KeyHelper;
		private var _stage:Stage;
		/**
		 * @private 
		 * 
		 */
		function KeyHelper(c:pc){
		}
		
		/**
		 * 初始化 
		 * @param stage
		 * @return 
		 * 
		 */
		public static function Init(stage:Stage):KeyHelper{
			if(_ins == null){
				if(stage == null){
					throw new Error('初始化失败！stage不可用。');
					return null;
				}else{
					stage.addEventListener("keyDown", DPE_KeyDown);
					stage.addEventListener("keyUp", DPE_KeyUp);
					_ins = new KeyHelper(new pc());
					_ins._stage = stage;
				}
			}
			return _ins;		
		}
		
		/**
		 * 列表中的键值所代表的按键是否被按下；
		 * @param keys	keyCode
		 * @return 
		 * @see flash.events.KeyboardEvent
		 */
		public function IsDown(...keys):Boolean{
			//trace(keys)
			for (var i:uint = 0; i < keys.length; i++) { 
				if(_keyobj[keys[i]])return true;
			} 
			return false;
		}
		/**
		 * 列表中的键值所代表的按键是否全部被按下； 
		 * @param keys	keyCode
		 * @return 
		 * @see flash.events.KeyboardEvent
		 */
		public function IsAllDown(...keys):Boolean{
			for (var i:uint = 0; i < keys.length; i++) { 
				if(!_keyobj[keys[i]])return false;
			} 
			return true;
		}
		//Events
		private static function DPE_KeyDown(event:KeyboardEvent):void{
			_keyobj[event.keyCode] = true;
		}
		
		private static function DPE_KeyUp(event:KeyboardEvent):void{
			delete _keyobj[event.keyCode];
		}
	}
}
class pc{}