package xBei.Manager
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import xBei.Interface.IListener;

	/**
	 * 全局热键支持 
	 * @author KoaQiu
	 * 
	 */
	public final class HotKeyManager implements IListener{
		/**
		 * 全局禁用热键 
		 */
		public static const DISABLED_KEYS:uint = 0xE0000000;
		/**
		 * 全局启用用热键
		 */
		public static const ENABLED_KEYS:uint = 0xE0000001;
		/**
		 * 检测到热键被按下
		 */
		public static const KEY_PRESS:uint = 0xE0000002;
		
		private static var _ins:HotKeyManager;
		/**
		 * 得到唯一实例 
		 * @return 
		 */
		public static function get Instance():HotKeyManager {
			if (HotKeyManager._ins != null) {
				return HotKeyManager._ins;
			}else {
				throw new Error("未初始化");
			}
		}
		/**
		 * 初始化 
		 * @param stage
		 * @return 
		 * 
		 */
		public static function Init():HotKeyManager{
			if(HotKeyManager._ins == null){
				HotKeyManager._ins = new HotKeyManager();
			}
			return HotKeyManager._ins;
		}
		private var _stage:Stage;
		private var _eventObject:Object;
		private var _disableList:Object;
		private var _keys:Array = [];
		private var _keyMpas:Object = {};

		private var _enabled:Boolean = false;
		/**
		 * 热键是否可用 
		 * @return 
		 * 
		 */
		public function get Enabled():Boolean{
			return _enabled;
		}

		public function set Enabled(v:Boolean):void	{
			if(this._enabled != v && this._stage != null){
				if (v) {
					this._stage.addEventListener(KeyboardEvent.KEY_UP, DPE_StageKeyUp);
				}else {
					this._stage.removeEventListener(KeyboardEvent.KEY_UP, DPE_StageKeyUp);
				}
				this._enabled = v;
			}
		}

		/**
		 * 创建唯一实例 
		 * @param stage
		 * 
		 */
		function HotKeyManager(){
			if(HotKeyManager._ins != null) {
				throw new Error("只能有一个实例！");
				return;
			}
			this._disableList = {};
			this._eventObject = {};
			this._keyMpas = [];
			this._keys =[];
			this._stage = StageManager.Instance.Stage;
			
			MessageManager.AddListener([
				DISABLED_KEYS,
				ENABLED_KEYS
			],this);
			
			this.Enabled = true;
		}
		/**
		* 设置程序的快捷键是否可用
		* @param app		要设置的对象
		* @param enabled	是否禁用
		*/ 
		public function Disable(app:String, isEnabled:Boolean):void {
			if (isEnabled) {
				delete _disableList[app];
			}else {
				_disableList[app] = true;
			}
		}
		/**
		* 注册快捷键，
		* @param app		注册的对象
		* @param command	命令
		* @param key		快捷键
		* @param exKey		扩展数据（Ctrl 0x2、Alt 0x1、Shirt 0x4 等）
		* @return 成功返回true
		*/ 
		public function RegisterKey(app:String, command:String, key:uint, extKey:uint = 0):Boolean {
			var appObj:Object = _keyMpas[app];
			if (appObj == null) {
				_keyMpas[app] = appObj = { };
			}
			var hasK:Boolean = this.IsRegistered(key, extKey);
			var keyObj:Object = appObj[command];
			if (keyObj == null) {
				appObj[command] = keyObj = { };
				if (hasK) {
					return false;
				}
			}else {
				//快捷键已经注册
				if (hasK) {
					//是否注册给 app,command
					if (keyObj.key == key && keyObj.extKey == extKey) {
						//是，直接返回
						return true;
					}else {
						//否，注册失败
						return false;
					}
				}
			}
			
			appObj[command] = keyObj = { key:key, extKey:extKey, sn:app + "|" + command };
			
			if (hasK) {
				for (var i:int = 0; i < _keys.length; i++ ) {
					var item:Object = _keys[i];
					if (item.key == key && item.extKey == extKey) {
						_keys.splice(i, 1);
						break;
					}
				}
			}
			
			_keys.push( { key:key, extKey:extKey, sn:app + "|" + command } );
			
			return true;
		}
		/**
		 * 是否已经注册 
		 * @param key
		 * @param extKey
		 * @return 
		 * 
		 */
		public function IsRegistered(key:uint, extKey:uint):Boolean {
			//trace("find ", key, extKey);
			for (var k:Object in _keys) {
				var item:Object = _keys[k];
				//trace("check ", item.key, item.extKey);
				if (item.key == key && item.extKey == extKey) {
					return true;
				}
			}
			return false;
		}
		/**
		* 解除注册
		*/ 
		public function UnRegisterKey(app:String, command:String):void {
			var appObj:Object = _keyMpas[app];
			if (appObj == null) {
				return;
			}
			delete appObj[command];
			return;
		}
		public function WndProc(MESSAGE:uint, source:Object = null, args:*=null):uint {
			switch(MESSAGE) {
				case HotKeyManager.DISABLED_KEYS:
					this.Enabled = false;
					break;
				case HotKeyManager.ENABLED_KEYS:
					this.Enabled = true;
					break;
			}
			return MessageManager.SUCCEED;
		}
		private function _checkKey(key:uint, alt:Boolean, ctrl:Boolean, shift:Boolean):Boolean {
			var ek:uint = 0;
			if (alt) {
				ek += 0x1;
			}
			if (ctrl) {
				ek += 0x2;
			}
			if (shift) {
				ek += 0x4;
			}
			
			for (var k:Object in this._keys) {
				var item:Object = this._keys[k];
				if (item.key == key && item.extKey == ek) {
					var sn:Array = item.sn.split("|");
					var app:String = sn[0];
					if (this._disableList[app]) {
						return false;
					}
					var command:String = sn[1];
					this.OnKeyPress(app, command,this._eventObject);
					return true;
				}
			}
			return false;
		}
		//Do Events
		protected function OnKeyPress(app:String,cmd:String,eobj:Object):void{
			trace('HOTKEY ' ,app, cmd, eobj);
			MessageManager.SendMessage(HotKeyManager.KEY_PRESS,this,null,app,cmd,eobj);
			
		}
		//Events
		private function DPE_StageKeyUp(e:KeyboardEvent):void {
			trace('HotKeyManager ',e.target, e.keyCode);
			this._eventObject = e.target;
			this._checkKey(e.keyCode, e.altKey, e.ctrlKey, e.shiftKey);
		}
	}
}