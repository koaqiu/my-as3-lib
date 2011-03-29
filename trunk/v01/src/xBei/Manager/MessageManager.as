package xBei.Manager {
	import xBei.Interface.IListener;
	
	/**
	 * 消息管理
	 * 用于 数据、事件的统一管理。当需要将一个消息发送个N个接收对象，消息的发送者和接收者不在同一位置时推荐使用
	 * @author KoaQiu
	 * @see xBei.Interface.IListener
	 */
	//[Event(name="deactivate", type="flash.events.Event")] 
	public final class MessageManager	{
		/**
		 * 成功 
		 */
		public static const SUCCEED:uint = 0;
		/**
		 *  
		 */
		public static const ITEM_EXIST:uint = 0x00000001;
		/**
		 * 项目不存在 
		 */
		public static const ITEM_NOEXIST:uint = 0x00000002;
		/**
		 * 对方不能接收消息 
		 */
		public static const ITEM_IS_NOT_LISTENER:uint = 0x00000003;
		/**
		 * 共享的数据发生改变时触发
		 * key:String, data:*
		 */
		public static const DATA_CHANGE:uint = 0x00010000;
		/**
		 * 未知错误 
		 */
		public static const UNKNOWN_ERROR:uint = 0xFFFFFFFF;
		/**
		 * 共享数据
		 */
		private var Data:Object = { };
		private var _listeners:Object = { };
		private static var _inc:MessageManager;
		function MessageManager(c:pc) {
		}
		/**
		 * 设置共享数据 
		 * @param key
		 * @param data
		 * 
		 */
		public static function SetData(key:String, data:*):void {
			trace('MessageManager.SetData',key,data);
			MessageManager.Instance.Data[key] = data;
			MessageManager.SendMessage(DATA_CHANGE, null, null, key, data);
		}
		/**
		 * 读取共享数据 
		 * @param key
		 * @return 
		 * 
		 */
		public static function GetData(key:String):*{
			return MessageManager.Instance.Data[key];
		}
		/**
		 * 唯一实例 
		 * @return 
		 * 
		 */
		protected static function get Instance():MessageManager {
			if (MessageManager._inc == null) {
				MessageManager._inc = new MessageManager(new pc());
			}
			return MessageManager._inc;
		}
		private var _errorCount:int = 0;
		private var _lastErrorList:Array;
		/**
		 * 发送消息
		 * @param	MESSAGE		消息ID		必需
		 * @param	source		发生者		可空
		 * @param	target		接收者		可空，暂时未使用
		 * @param	...args		参数列表	如果需要
		 * @return	非零则表示发生错误，返回值是错误ID；如果有多个接收者，且发生错误则返回最后一个出错ID
		 */
		public static function SendMessage(MESSAGE:uint, source:Object = null, target:IListener = null, ...args):uint {
			return MessageManager.Instance.sendMessage(MESSAGE, source, target, args);
		}
		protected function sendMessage(MESSAGE:uint, source:Object = null, target:IListener = null, args:*=null):uint {
			var tmp:Array = _listeners[MESSAGE];
			if (tmp == null) {
				return ITEM_NOEXIST;
			}
			var c:int = tmp.length;
			var r:uint = SUCCEED;
			_errorCount = 0;
			_lastErrorList = [];
			for (var i:int = 0; i < c; i++) {
				var ls:IListener = tmp[i] as IListener;
				var r1:uint = SUCCEED;
				if (ls == null) {
					r1 = ITEM_IS_NOT_LISTENER;
					_lastErrorList.push(r1);
					_errorCount++;
					continue;
				}else if (ls == source) {
					//不会发生给自己
					//什么都不做
				}else {
					r1 = ls.WndProc(MESSAGE, source, args);
					if (r1 != SUCCEED) {
						_lastErrorList.push(r1);
						_errorCount++;
					}					
				}
				if (r1 > 0xFF000000 && r1 != UNKNOWN_ERROR) {
					//发生致命错误！
					return r1;
				}else if (r1 > SUCCEED) {
					r = r1;
				}
			}
			//未知错误
			return r;
		}
		/**
		 * 添加监听
		 * @param	MESSAGE		消息ID		必需
		 * @param	listener	接收者
		 * @return	成功返回0，其他是出错ID，如果MESSAGE是个数组则返回的也是数组
		 */
		public static function AddListener(MESSAGE:*, listener:IListener):* {
			return MessageManager.Instance.addListener(MESSAGE, listener);
		}
		/**
		 * 删除监听 
		 * @param listener
		 * 
		 */
		public static function RemoveListener(listener:IListener):void {
			return MessageManager.Instance.removeListener(listener);
		}
		protected function removeListener(listener:IListener):void {
			for each(var item:Array in _listeners) {
				var index:int = item.indexOf(listener);
				if (index >= 0) {
					trace("remove ", listener, index);
					item.splice(index, index);
				}
			}
		}
		protected function addListener(MESSAGE:*, listener:IListener):* {
			if (MESSAGE is uint) {
				return _addListener(uint(MESSAGE), listener);
			}else if (MESSAGE is Array) {
				var tmp:Array = MESSAGE;
				var c:int = tmp.length;
				var result:Array = [];
				for (var i:int = 0; i < c; i++) {
					result.push(_addListener(tmp[i], listener));
				}
				return result;
			}else {
				try{
				var id:uint = uint(MESSAGE);
				return _addListener(id,listener);
				}catch(err:Error){}
			}
			//未知错误
			return UNKNOWN_ERROR;
		}
		private function _addListener(MESSAGE:uint, listener:IListener):uint {
			var tmp:Array = _listeners[MESSAGE];
			if (tmp == null) {
				tmp = _listeners[MESSAGE] = [];
			}
			if(tmp.indexOf(listener)==-1){
				tmp.push(listener);
				return SUCCEED;
			}else {
				//已经存在
				return ITEM_EXIST;
			}
		}
		public function toString():String {
			return '[MessageManager V:0.1] 静态类，自动初始化，请直接调用静态方法';
		}
	}
}
class pc{}