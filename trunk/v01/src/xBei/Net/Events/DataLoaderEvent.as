package xBei.Net.Events{
	import flash.events.Event;
	
	/**
	 * xBei.Net.DataLoader 的扩展事件
	 * @author KoaQiu
	 * @see xBei.Net.DataLoader
	 */
	public class DataLoaderEvent extends Event {
		/**
		 * 超时 
		 */
		public static const TIME_OUT:String = "timeOut";
		/**
		 * 加载完毕 
		 */
		public static const DATA_LOADED:String = "dataLoaded";
		/**
		 * 不在线 
		 */
		public static const OFFLINE:String = "offline";
		/**
		 * 发生错误 
		 */
		public static const ERROR:String = "error";
		
		public function DataLoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event { 
			return new DataLoaderEvent(type, bubbles, cancelable);
		} 
		
		override public function toString():String { 
			return formatToString("DataLoaderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}