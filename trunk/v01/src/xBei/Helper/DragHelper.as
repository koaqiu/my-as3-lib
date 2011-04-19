package xBei.Helper {
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;

	/**
	 * 快速实现拖动
	 * @author KoaQiu
	 */
	public class DragHelper {
		private static var _isDraging:Boolean = false;
		private static var _rect:Object = { };
		/**
		 * 拖动对象
		 * @param	target
		 * @param	rect
		 * @param	onStartDrag
		 * @param	onEndDrag
		 * @param	onMove		拖动时触发
		 */
		public static function MakeItCanDrag(target:Sprite, rect:Rectangle = null, onStartDrag:Function = null, 
											 onEndDrag:Function = null, onMove:Function = null, canDrag:Function = null):void {
			_rect[target.name] = rect;
			function _makeItCanDragMouseUp(me:MouseEvent):void {
				_isDraging = false;
				if (onMove != null) {
					target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				}
				target.stage.removeEventListener(MouseEvent.MOUSE_UP, _makeItCanDragMouseUp);
				target.stopDrag();
				if (onEndDrag != null) {
					onEndDrag(target);
				}
			}
			function _makeItCanDragMouseDown(me:MouseEvent):void {
				//var tg:Sprite = me.target as Sprite;
				//if (tg == null) return;
				if (canDrag != null && canDrag() == false) {
					return;
				}
				//trace(target.name);
				target.startDrag(false, _rect[target.name]);
				target.stage.addEventListener(MouseEvent.MOUSE_UP, _makeItCanDragMouseUp);
				_isDraging = true;
				if (onStartDrag != null) {
					onStartDrag(target);
				}
				if (onMove != null) {
					target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				}
			}
			target.addEventListener(MouseEvent.MOUSE_DOWN, _makeItCanDragMouseDown);
		}

		/**
		 * 修改拖动区域
		 * @param target
		 * @param rect
		 * @see #MakeItCanDrag()
		 */
		public static function ChangeDragRect(target:Sprite, rect:Rectangle):void {
			_rect[target.name] = rect;
		}
	}
}