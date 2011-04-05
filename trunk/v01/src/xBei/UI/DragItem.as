package xBei.UI {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	import xBei.Helper.ImageHelper;
	
	/**
	 * 正在拖曳的对象
	 * @author KoaQiu
	 */
	public class DragItem extends Sprite	{
		private var _targetItem:DisplayObject;
		/**
		 * 目标
		 * @return 
		 */
		public function get Target():DisplayObject {
			return this._targetItem;
		}
		private var _funDD:Function;
		/**
		 * 创建拖曳数据对象 
		 * @param disp		被拖曳的对象
		 * @param funDD		拖曳停止时触发 function(DragItem):void;
		 * 
		 */
		public function DragItem(disp:DisplayObject, funDD:Function) {
			this._targetItem = disp;
			this._funDD = funDD;
			super();
			var g:Graphics = this.graphics;
			g.beginBitmapFill(ImageHelper.GetBitmap(disp));
			g.drawRect(0, 0, disp.width, disp.height);
			g.endFill();
			var p:Point = new Point(0, 0);
			p = disp.localToGlobal(p);
			this.x = p.x;
			this.y = p.y;
			disp.stage.addChild(this);
			this.alpha = .5;
			this.startDrag(false);
			stage.addEventListener(MouseEvent.MOUSE_UP, DPE_DDMouseUp);
		}
		private function DPE_DDMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, DPE_DDMouseUp);
			this.stopDrag();
			stage.removeChild(this);
			this._funDD(this);
		}
		
	}

}