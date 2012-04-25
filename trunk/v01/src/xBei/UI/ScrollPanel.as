package xBei.UI {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	public class ScrollPanel extends LiteComponent {
		public static const AutoShowScrollBar:String = "auto";
		public static const DisableScrollBar:String = "none";
		/**
		 * 垂直
		 */
		public static const VerticalScrollBar:String = "vertical";
		/**
		 * 水平
		 */
		public static const HorizontalScrollBar:String = "horizontal";
		
		//垂直
		private var _vScrollBar:ScrollBar;
		//水平
		private var _hScrollBar:ScrollBar;
		private var _frame:Sprite;
		private var _bg:Sprite;
		protected var _con:XSprite = new XSprite();
		private var _conRc:XSprite;
		
		private var timer:Timer;
		private var _created:Boolean = false;
		
		private var _BackgroundColor:uint = 0xffffff;
		/**
		 * 背景颜色
		 * @author KoaQiu
		 */
		public function get BackgroundColor():uint{ 
			return _BackgroundColor; 
		}
		public function set BackgroundColor(v:uint):void {
			_BackgroundColor = v;
			this.draw();
		}
		private var _BackgroundAlpha:uint=60;
		/**
		 * 背景透明度
		 * @author KoaQiu
		 */
		public function get BackgroundAlpha():uint{ 
			return _BackgroundAlpha; 
		}
		public function set BackgroundAlpha(v:uint):void {
			_BackgroundAlpha = v > 100?100:v;
			this.draw();
		}
		private var _FrameColor:uint = 0x999999;
		/**
		 * 边框颜色
		 * @author KoaQiu
		 */
		public function get FrameColor():uint{ 
			return _FrameColor; 
		}
		public function set FrameColor(v:uint):void {
			_FrameColor = v;
		}
		private var _ScrollBars:String = "auto";
		/**
		 * 滚动条显示模式
		 * @author KoaQiu
		 */
		public function get ScrollBars():String{ 
			return _ScrollBars; 
		}
		public function set ScrollBars(v:String):void {
			_ScrollBars = v;
			if (_created) {
				//this._showScrollBars(v);
				this.reLayout();
			}
		}
		private function _showScrollBars(v:String):void {
			switch(v) {
				case ScrollPanel.AutoShowScrollBar:
					this._vScrollBar.visible =
					this._hScrollBar.visible = true;
					break;
				case ScrollPanel.DisableScrollBar:
					this._vScrollBar.visible =
					this._hScrollBar.visible = false;
					break;
				case ScrollPanel.HorizontalScrollBar:
					this._vScrollBar.visible = false;
					this._hScrollBar.visible = true;
					break;
				case ScrollPanel.VerticalScrollBar:
					this._vScrollBar.visible = true;
					this._hScrollBar.visible = false;
					break;
			}
		}
		private var _FrameVisible:Boolean=true;
		/**
		 * 是否显示边框
		 * @author KoaQiu
		 */
		public function get FrameVisible():Boolean{ 
			return _FrameVisible; 
		}
		public function set FrameVisible(v:Boolean):void {
			_FrameVisible = v;
			if (_frame != null) {
				_frame.visible = v;
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this._bg = new Sprite();
			this._frame = new Sprite();
			this._conRc = new XSprite();
			this._vScrollBar = new ScrollBar();
			this._vScrollBar.visible = false;
			this._vScrollBar.addEventListener(Event.CHANGE, DPE_VScrollBarChanged);
			this._hScrollBar = new ScrollBar();
			this._hScrollBar.rotation = 270;
			this._hScrollBar.visible = false;
			this._hScrollBar.addEventListener(Event.CHANGE, DPE_HScrollBarChanged);
			//this._hScrollBar.direction = "horizontal";
			
			this.timer = new Timer(200);
			this.timer.addEventListener(TimerEvent.TIMER, DPE_Timer);
			//this.timer.start();
			
			super.addChild(_bg);
			super.addChild(_frame);
			super.addChild(_conRc);
			this._conRc.addChild(_con);
			super.addChild(_vScrollBar);
			super.addChild(_hScrollBar);
			_created = true;
		}
		override public function SetSize(pWidth:Number, pHeight:Number):void {
			super.SetSize(pWidth, pHeight);
			if (_created) {
				var rc:Rectangle = this._conRc.scrollRect;
				if (rc == null) {
					rc = new Rectangle(0, 0, pWidth, pHeight);
				}else {
					rc.width = pWidth;
					rc.height = pHeight;
				}
				this._conRc.scrollRect = rc;
			}
		}
		public function Clear():void {
			while (this._con.numChildren > 0) {
				this._con.removeChildAt(0);
			}
		}
		/**
		 * 将child提到最顶层
		 * @param	child
		 */
		public function BringToFornt(child:DisplayObject):void {
			this._con.swapChildrenAt(this._con.getChildIndex(child), this._con.numChildren - 1);
		}
		/**
		 * 子项目个数
		 */
		public function get ChildCount():int {
			return _con.numChildren;
		}
		/**
		 * 删除项目
		 * @param	item
		 */
		public function RemoveItem(item:DisplayObject):DisplayObject {
			return this._con.removeChild(item);
		}
		/**
		 * 删除项目
		 * @param	index
		 * @return
		 */
		public function RemoveItemAt(index:int):DisplayObject {
			var tmp:DisplayObject = this._con.removeChildAt(index);
			this.reLayout();
			return tmp;
		}
		/**
		 * 添加项目
		 * @param	child
		 * @return
		 */
		public function AddItem(child:DisplayObject):DisplayObject {
			var tmp:DisplayObject = _con.addChild(child);
			this.reLayout();
			return tmp;
		}
		public function AddItemAt(child:DisplayObject, index:int):DisplayObject {
			var tmp:DisplayObject = _con.addChildAt(child, index);
			this.reLayout();
			return tmp;
		}
		public function GetItemAt(index:int):DisplayObject {
			if (index >= 0 && index < _con.numChildren) {
				return _con.getChildAt(index) as DisplayObject;
			}
			return null;
		}
		override protected function draw():void {
			super.draw();
			if (this._created == false) {
				return;
			}
			var g:Graphics;
			g = this._bg.graphics;
			g.clear();
			g.beginFill(this.BackgroundColor, this.BackgroundAlpha / 100);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			if (this.FrameVisible) {
				g = this._frame.graphics;
				g.lineStyle(1, this.FrameColor);
				g.moveTo(0, height);
				g.lineTo(0, 0);
				g.lineTo(width, 0);
				//g.lineStyle(1, 0xdddddd);
				g.lineTo(width, height);
				g.lineTo(0, height);
			}
			this.OnConRender();
		}
		protected function reLayout():void {
			this.OnConRender();
		}
		
		//Do Event
		private function OnConRender():void {
			this._showScrollBars(this.ScrollBars);
			if (this.ScrollBars == ScrollPanel.DisableScrollBar) {
				return;
			}
			var rc:Rectangle = this._conRc.scrollRect;
			if (rc == null) {
				rc = new Rectangle(0, 0, this.width, this.height);
				this._conRc.scrollRect = rc;
			}
			//trace(rc)
			this._vScrollBar.x = width - this._vScrollBar.width;
			this._hScrollBar.y = height;// - this._hScrollBar.height;
			if (this._con.width > rc.width && 
				(this.ScrollBars == ScrollPanel.AutoShowScrollBar || this.ScrollBars == ScrollPanel.HorizontalScrollBar)
			) {
				this._hScrollBar.visible = true;
				this._vScrollBar.height = height - this._hScrollBar.width;
			}else {
				this._hScrollBar.visible = false;
				this._vScrollBar.height = height;
			}
			if (this._con.height > rc.height && 
				(this.ScrollBars == ScrollPanel.AutoShowScrollBar || this.ScrollBars == ScrollPanel.VerticalScrollBar)
			){
				this._vScrollBar.visible = true;
				this._hScrollBar.height = width - this._vScrollBar.width;
			}else {
				this._vScrollBar.visible = false;
				this._hScrollBar.height = width;
			}
		}
		//Events
		private function DPE_Timer(e:TimerEvent):void {
			this.OnConRender();
		}
		private function DPE_VScrollBarChanged(e:Event):void {
			var maxH:Number = this._con.height - this._conRc.scrollRect.height;
			if (this.ScrollBars == ScrollPanel.AutoShowScrollBar) {
				maxH += this._vScrollBar.width;
			}
			var h:Number = maxH * this._vScrollBar.Value / 100;
			//trace('DPE_VScrollBarChanged', h);
			this._con.y = -h;
		}
		private function DPE_HScrollBarChanged(e:Event):void {
			var maxW:Number = this._con.width - this._conRc.scrollRect.width;
			if (this.ScrollBars == ScrollPanel.AutoShowScrollBar) {
				maxW += this._vScrollBar.width;
			}
			var w:Number = maxW * this._hScrollBar.Value / 100;
			this._con.x = -w;
		}
	}
}