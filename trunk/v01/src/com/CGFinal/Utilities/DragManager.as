package com.CGFinal.Utilities {
	import com.CGFinal.BaseUI;
	import com.CGFinal.DragAndDrop.DragItem;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class DragManager {
		private static var _dragItem:DragItem;
		private static var _funDropItem:Function;
		public static function get DragingItem():DragItem {
			return DragManager._dragItem;
		}
		public static function set DropItemAction(v:Function):void {
			DragManager._funDropItem = v;
		}
		public function DragManager() {
			
		}
	
		public static function BeginDragIt(disp:DisplayObject):void {
			throw new Error('请使用新类：xBei.Manager.Dragmanager');
			if (disp == null || disp.stage == null || disp.parent == null) {
				//无效的拖曳目标
				return;
			}
			var item:DragItem = new DragItem(disp, DragManager.DragDrop);
			DragManager._dragItem = item;
		}
		protected static function DragDrop(obj:DragItem):void {
			if (DragManager._funDropItem != null) {
				DragManager._funDropItem(obj);
			}else {
				trace("-----------------------------------------------------------------------");
			}
		}
	}

}