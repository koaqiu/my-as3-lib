package xBei.Manager{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import xBei.Helper.StringHelper;

	public class StageManager	extends EventDispatcher{
		private static var _inc:StageManager;
		/**
		 * 唯一实例 
		 * @return 
		 */
		public static function get Instance():StageManager {
			if (StageManager._inc == null) {
				StageManager._inc = new StageManager(new pc());
			}
			return StageManager._inc;
		}
		private var _stage:flash.display.Stage;
		public function get Stage():flash.display.Stage{
			if(this._stage == null)throw new Error('StageManager没有初始化！');
			return this._stage;
		}
		
		private var _stageWidth:int;
		/**
		 * 实际宽度
		 * @return 
		 */
		public function get StageWidth():int{
			return this._stageWidth;
		}
		private var _stageHeight:int;
		/**
		 * 实际高度
		 * @return 
		 */
		public function get StageHeight():int{
			return this._stageHeight;
		}
		
		private var _sWidth:int;
		/**
		 * flash文件的设置宽度
		 * @return 
		 */
		public function get Width():int{
			return this._sWidth;
		}
		private var _sHeight:int;
		/**
		 * flash文件的设置高度
		 * @return 
		 */
		public function get Height():int{
			return this._sHeight;
		}
		
		/**
		 * 返回Flash的可见区域
		 * @return 
		 */
		public function get ClientRect():Rectangle{
			var align:uint = 0x0;
			if(StringHelper.IsNullOrEmpty(this.Stage.align)){
				align = 0x33;
			}else{
				if(this.Stage.align.indexOf('T') >= 0)
					align |= 0x10;
				else if(this.Stage.align.indexOf('B') >= 0)
					align |= 0x70;
				else
					align |= 0x30;
				
				if(this.Stage.align.indexOf('L') >= 0)
					align |= 0x01;
				else if(this.Stage.align.indexOf('R') >= 0)
					align |= 0x7;
				else
					align |= 0x03;
			}
			var r:Rectangle = new Rectangle(
				0, 0,
				this.StageWidth,
				this.StageHeight
			);
			if((align & 0x30) == 0x30){
				//垂直居中
				r.y = ((this.Height - this.StageHeight) / 2);
			}else if((align & 0x10) == 0x10){
				//顶部对齐
				r.y = 0;
			}else if((align & 0x70) == 0x70){
				//底部对齐
				r.y = this.StageHeight - this.Height;
			}
			if((align & 0x03) == 0x03){
				//水平居中
				r.x = ((this.Width - this.StageWidth) / 2);
			}else if((align & 0x01) == 0x01){
				//左对齐
				r.x = 0;
			}else if((align & 0x07) == 0x07){
				//左对齐
				r.x = this.StageWidth - this.Width;
			}
			
			return r;
		}
		
		public function StageManager(c:pc){
		}
		
		/**
		 * 初始化
		 * @param pStage	舞台实例
		 * @param pWidth	flash文件的设置宽度
		 * @param pHeight	flash文件的设置高度
		 */
		public static function Initialize(pStage:flash.display.Stage, pWidth:int, pHeight:int):void{
			if(pStage == null){
				throw new ArgumentError('stage不能为空（null）');
			}
			Instance._stage = pStage;
			Instance._sWidth = pWidth;
			Instance._sHeight = pHeight;
			Instance._initialize();
		}
		public function addChild(child:DisplayObject):DisplayObject{
			return this.Stage.addChild(child);
		}
		/**
		 * 得到位置坐标
		 * @param disp
		 * @param align
		 * @return 
		 */		
		public function GetPosition(disp:DisplayObject, align:uint):Point{
			var r:Rectangle = this.ClientRect;
			var p:Point = new Point();
			if((align & 0x30) == 0x30){
				//垂直居中
				p.y = r.y + (r.height - disp.height) / 2;
			}else if((align & 0x10) == 0x10){
				//顶部对齐
				p.y = r.y;
			}else if((align & 0x70) == 0x70){
				//底部对齐
				p.y = r.y + r.height - disp.height;
			}
			if((align & 0x03) == 0x03){
				//水平居中
				p.x = r.x + (r.width - disp.width) / 2;
			}else if((align & 0x01) == 0x01){
				//左对齐
				p.x = r.x;
			}else if((align & 0x07) == 0x07){
				//左对齐
				p.x = r.x + r.width - disp.width;
			}
			//if(ExternalInterface.available)	ExternalInterface.call('console.log',p.x,p.y);
			//trace('StageManager.GetPosition',p);
			return p;
		}
		
		private function _initialize():void{
			this._stage.scaleMode = 'noScale';
			this._stageWidth = this._stage.stageWidth;
			this._stageHeight = this._stage.stageHeight;
			this._stage.addEventListener(Event.RESIZE, DPE_StageResized);
		}
		//Do Event
		protected function OnStageResized():void{
			this.dispatchEvent(new Event(Event.RESIZE));
		}
		//Events
		private function DPE_StageResized(e:Event):void{
			this._stageWidth = this._stage.stageWidth;
			this._stageHeight = this._stage.stageHeight;
			this.OnStageResized();
		}
	}
}
class pc{}