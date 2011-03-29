package xBei.Manager {
	import com.CGFinal.DragAndDrop.DragItem;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * 拖曳管理器
	 * @author KoaQiu
	 */
	public class DragManager {
		private static var _dragItem:DragItem;
		private static var _funDropItem:Function;
		/**
		 * 当前正在拖曳的对象 
		 * @return 
		 * 
		 */
		public static function get DragingItem():DragItem {
			return DragManager._dragItem;
		}
		public static function set DropItemAction(v:Function):void {
			DragManager._funDropItem = v;
		}
		
		/**
		 * @private 
		 */
		function DragManager(c:pc) {
		}
	
		/**
		 * 开始拖曳 
		 * @param disp
		 */
		public static function BeginDragIt(disp:DisplayObject):void {
			if (disp == null || disp.stage == null || disp.parent == null) {
				//无效的拖曳目标
				return;
			}
			var item:DragItem = new DragItem(disp, DragManager.DragDrop);
			DragManager._dragItem = item;
		}
		/**
		 * @private 
		 * @param obj
		 * 
		 */
		protected static function DragDrop(obj:DragItem):void {
			if (DragManager._funDropItem != null) {
				DragManager._funDropItem(obj);
			}else {
				trace("-----------------------------------------------------------------------");
			}
		}
	}
}
class pc{}