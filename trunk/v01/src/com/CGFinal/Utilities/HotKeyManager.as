package com.CGFinal.Utilities {
	import com.CGFinal.Events.HotKeyEvent;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * ...
	 * @author KoaQiu
	 */
	[Event(name = "action", type = "com.CGFinal.Events.HotKeyEvent")]
	[Event(name = "onInit", type = "com.CGFinal.Events.HotKeyEvent")]
	 public class HotKeyManager extends MovieClip {
		private static var _ins:HotKeyManager;
		private static var _initFunc:Array = [];
		
		public static const ALT_KEY:uint = 0x1;
		public static const CTRL_KEY:uint = 0x2;
		public static const SHIFT_KEY:uint = 0x4;
		/**
		 * 初始化
		 * @param	fun
		 */
		public static function addInitFunc(fun:Function):void {
			if(HotKeyManager._ins==null){
				_initFunc.push(fun);
			}else {
				fun();
			}
		}
		public static function get Instance():HotKeyManager {
			if (HotKeyManager._ins) {
				return HotKeyManager._ins;
			}else {
				throw new Error("未初始化");
			}
		}
		public static function AddEvent(listener:Function):void {
			if (HotKeyManager._ins) {
				HotKeyManager._ins.addEventListener(HotKeyEvent.ACTION, listener);
			}else {
				throw new Error("未初始化");
			}
		}
		public var _keyMpas:Object;
		private var _keys:Array;
		private var _enabled:Boolean = false;
		private var disableList:Object;
		public function HotKeyManager() {
			//trace("HotKeyManager");
			if(HotKeyManager._ins==null){
				_keyMpas = { };
				_keys = [ ];
				HotKeyManager._ins = this;
				for (var k:Object in com.CGFinal.Utilities.HotKeyManager._initFunc) {
					HotKeyManager._initFunc[k]();
				}
				HotKeyManager._initFunc = null;
			}else {
				throw new Error("只能有一个实例！");
				return;
			}
			this.mySo = SharedObject.getLocal("HotKeyManager");
			this.Enabled = true;
			this.disableList = {};
			this.dispatchEvent(new HotKeyEvent(HotKeyEvent.INIT, "", "",null));
		}
		
		private var mySo:SharedObject;

		public function Load():Boolean {
			return true;
			if (mySo.data.HotKey) {
				this.disableList = mySo.data.HotKey.disableList;
				this._keyMpas = mySo.data.HotKey.keyMpas;
				this._keys = mySo.data.HotKey.keys;
				return true;
			}else{
				return false;
			}
		}
		public function Save():Boolean {
			var r:Boolean = true;
			mySo.data.HotKey = { 
				disableList:disableList,
				keyMpas:_keyMpas,
				keys:_keys
			};
            var flushStatus:String = null;
            try {
                flushStatus = mySo.flush();
            } catch (error:Error) {
                trace("Error...Could not write SharedObject to disk\n");
				r = false;
            }
            if (flushStatus != null) {
                switch (flushStatus) {
                    case SharedObjectFlushStatus.PENDING:
                        trace("Requesting permission to save object...\n");
                        mySo.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                        break;
                    case SharedObjectFlushStatus.FLUSHED:
                        trace("Value flushed to disk.\n");
                        break;
                }
            }
			return r;
		}
        private function onFlushStatus(event:NetStatusEvent):void {
            trace("User closed permission dialog...\n");
            switch (event.info.code) {
                case "SharedObject.Flush.Success":
                    trace("User granted permission -- value saved.\n");
                    break;
                case "SharedObject.Flush.Failed":
                    trace("User denied permission -- value not saved.\n");
                    break;
            }
            mySo.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
        }
		
		public function set Enabled(v:Boolean):void {
			if (v) {
				if (_enabled == false && stage!=null) {
					stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUp);
				}
			}else {
				if(_enabled && stage!=null){
					stage.removeEventListener(KeyboardEvent.KEY_UP, stageKeyUp);
				}
			}
			_enabled = v;
		}
		public function get Enabled():Boolean {
			return this._enabled;
		}
		/*
		 * 设置程序的快捷键是否可用
		 * @param app		要设置的对象
		 * @param enabled	是否禁用
		 */ 
		public function Disable(app:String, isEnabled:Boolean):void {
			if (isEnabled) {
				delete disableList[app];
			}else {
				disableList[app] = true;
			}
		}
		public function IsEnabled(app:String):Boolean {
			return disableList[app] != true;
		}
		private var _eventObject:Object;
		private function stageKeyUp(e:KeyboardEvent):void {
			//trace(e.target, e.keyCode);
			_eventObject = e.target;
			checkKey(e.keyCode, e.altKey, e.ctrlKey, e.shiftKey);
		}
		private function checkKey(key:uint, alt:Boolean, ctrl:Boolean, shift:Boolean):Boolean {
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
			
			for (var k:Object in _keys) {
				var item:Object = _keys[k];
				if (item.key == key && item.extKey == ek) {
					var sn:Array = item.sn.split("|");
					var app:String = sn[0];
					if (disableList[app]) {
						return false;
					}
					var command:String = sn[1];
					this.dispatchEvent(new HotKeyEvent(HotKeyEvent.ACTION, app, command,this._eventObject));
					return true;
				}
			}
			return false;
		}
		/*
		 * 注册快捷键，
		 * @param app		注册的对象
		 * @param command	命令
		 * @param key		快捷键
		 * @param exKey		扩展数据（Ctrl、Alt、Shirt等）
		 * @return 成功返回true
		 */ 
		public function RegisterKey(app:String, command:String, key:uint, extKey:uint = 0):Boolean {
			var appObj:Object = _keyMpas[app];
			if (appObj == null) {
				_keyMpas[app] = appObj = { };
			}
			var hasK:Boolean = this.isReg(key, extKey);
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
		public function isReg(key:uint, extKey:uint):Boolean {
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
		/*
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
	}
	
}
