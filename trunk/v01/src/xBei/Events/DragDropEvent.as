package xBei.Events {
	import flash.events.Event;
	
	import xBei.UI.DragItem;
	
	/**
	 * 拖曳对象的事件支持
	 * @author KoaQiu
	 */
	public class DragDropEvent extends Event {
		/**
		 * 当一个拖拽代理从目标外移动到目标上时广播。
		 * 一个组件成为一个释放目标必须为这个事件定义一个侦听器。使用侦听器，你可以改变释放目标的
		 * 外观提供一个可视化的效果以便用户了解到这个组件可以接受拖拽操作，例如，你可以在释放目标
		 * 周围绘制一个边框，或者使释放目标获得焦点。
		 */
		public static const DRAG_ENTER:String = "dragEnter";
		/**
		 * 当鼠标在目标上释放时广播--拖曳结束
		 */
		public static const DRAG_DROP:String = "dragDrop";
		/**
		 * 拖曳时鼠标在目标上时广播
		 */
		public static const DRAG_OVER:String = "drapOver";
		/**
		 * 拖曳时鼠标离开目标时广播
		 */
		public static const DRAG_LEAVE:String = "dragLeave";
		
		private var _obj:DragItem;
		/**
		 * 拖曳的对象
		 * @return 
		 */		
		public function get Item():DragItem {
			return _obj;
		}
		public function DragDropEvent(type:String, obj:DragItem, bubbles:Boolean = false, cancelable:Boolean = false) { 
			_obj = obj;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 	{ 
			return new DragDropEvent(type,_obj, bubbles, cancelable);
		} 
		
		public override function toString():String 	{ 
			return formatToString("DragDropEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}