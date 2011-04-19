package xBei.UI {
	import flash.display.*;
	import flash.events.Event;
	
	import xBei.Interface.*;

	public class XMovieClip extends MovieClip implements IDispose, IChildSprite, IEnabled {
		private var _depth:int;
		private var _enable:Boolean = true;
		/**
		 * 返回该对象在显示层级中的引索，如果不在显示队列则返回 -1。0 表示对象在最底层
		 * @return 
		 * @see #VDepth()
		 */
		public function get Depth():int{
			if(this.parent == null){
				return -1;
			}else{
				return this.parent.getChildIndex(this);
			}
		}
		/**
		 * 是否可用
		 */
		public function get Enabled():Boolean {
			return this._enable;
		}
		public function set Enabled(v:Boolean):void {
			if(this._enable != v){
				this._enable = v;
				var l:int = super.numChildren;
				for(var i:int = 0;i < l; i++){
					var disp:DisplayObject = super.getChildAt(i); 
					if(disp is IEnabled){
						(disp as IEnabled).Enabled = v;
					}else if(disp.hasOwnProperty('enable')){
						try{disp['enable'] = v}
						catch(e:Error){}
					}
				}
			}
		}
		/**
		 * 级层深度（模拟AS2）
		 * @see xBei.Interface.IChildSprite
		 * @see xBei.Manager.DepthManger
		 */
		public function get VDepth():int {
			return this._depth;
		}
		public function set VDepth(v:int):void {
			this._depth = v;
		}
		
		public function XMovieClip() {
			super();
			this.createChildren();
		}
		protected function createChildren():void{
			
		}
		/**
		 * 清理对象
		 */
		public function dispose():void {
			while(this.numChildren > 0){
				var item:DisplayObject = this.removeChildAt(0);
				glo.DisposeDisplayObject(item);
			}
			if(this.parent != null){
				this.parent.removeChild(this);
			}
		}
		override public function dispatchEvent(event:Event):Boolean {
			if(this.Enabled){
				return super.dispatchEvent(event);
			}else {
				return false;
			}
		}
	}
}