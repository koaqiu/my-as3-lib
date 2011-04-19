package xBei.UI {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import xBei.Helper.DragHelper;
	
	
	/**
	 * 滚动条控件
	 * @author KoaQiu
	 */
	public class ScrollBar extends LiteComponent{
		private var _bg:Sprite;
		private var _scrollArrowUp:Sprite;
		private var _scrollArrowDown:Sprite;
		private var _scrollDragBar:Sprite;
		private var _scrollThumb:Sprite;
		private var _scrollBarThumbIcon:Sprite;
		
		private var _maxValue:Number = 100;
		[Inspectable(defaultValue=100)]
		public function get MaxValue():Number {
			return _maxValue;
		}
		public function set MaxValue(v:Number):void {
			if (v < _minValue) return;
			_maxValue = v;
			if (v < this._value) {
				this.Value = v;
			}
		}
		private var _minValue:Number = 1;
		[Inspectable(defaultValue=1)]
		public function get MinValue():Number {
			return _minValue;
		}
		public function set MinValue(v:Number):void {
			if (v>_maxValue) return;
			_minValue = v;
			if (v > this._value) {
				this.Value = v;
			}
		}
		private var _minChangeValue:Number = 5;
		/**
		 * 每次修改 
		 * @return 
		 * 
		 */
		public function get MinChangeValue():Number {
			return _minChangeValue;
		}
		public function set MinChangeValue(v:Number):void {
			_minChangeValue = v;
		}
		
		private var _value:Number = 1;
		public function get Value():Number {
			return _value;
		}
		public function set Value(v:Number):void {
			if (v < _minValue) v = _minValue;
			else if (v > _maxValue) v = _maxValue;
			if(_value != v){
				_value = v;
				var maxy:Number = this.height - this._scrollArrowUp.height - this._scrollArrowDown.height - this._scrollThumb.height;
				var vx:Number = _value - this.MinValue;
				
				var ty:Number = vx * maxy / (this.MaxValue-this.MinValue);
				this._scrollDragBar.y = ty + this._scrollArrowUp.height;
			}
		}
		//属性
		private var _direction:String = "vertical";
		[Inspectable(defaultValue="vertical",enumeration="vertical,horizontal")]
	    public function get direction():String {
			return _direction;
		}
		public function set direction(v:String):void {
			if (_direction != v) {
				_direction = v;
			}
		}
		public function ScrollBar(direction:String = "vertical") {
			this._direction = direction;
		}
		override protected function createChildren():void {
			super.createChildren();
			this._scrollDragBar = new Sprite();
			this._bg = glo.CreateObject("ScrollTrackSkin") as Sprite;
			this._bg.addEventListener(MouseEvent.CLICK, DPE_TrackClick);
			this._scrollArrowUp = glo.CreateObject("ScrollArrowUpSkin") as Sprite;
			this._scrollArrowUp.addEventListener(MouseEvent.CLICK, DPE_ArrowClick);
			this._scrollArrowDown = glo.CreateObject("ScrollArrowDownSkin") as Sprite;
			this._scrollArrowDown.addEventListener(MouseEvent.CLICK, DPE_ArrowClick);
			this._scrollThumb = glo.CreateObject("ScrollThumbSkin") as Sprite;
			this._scrollBarThumbIcon = glo.CreateObject("ScrollBarThumbIcon") as Sprite;
			
			this.addChild(this._bg);
			this.addChild(this._scrollArrowUp);
			this.addChild(this._scrollArrowDown);
			this.addChild(this._scrollDragBar);
			this._scrollDragBar.addChild(this._scrollThumb);
			this._scrollDragBar.addChild(this._scrollBarThumbIcon);
		}
		override protected function draw():void {
			super.draw();
			this._bg.width = this._scrollArrowUp.width = this._scrollArrowDown.width = this._scrollThumb.width = this.width;
			this._bg.height = this.height;
			
			this._scrollDragBar.y = this._scrollArrowUp.height;
			this._scrollArrowDown.y = this.height - this._scrollArrowDown.height;
			
			this._scrollBarThumbIcon.x = (this._scrollThumb.width - this._scrollBarThumbIcon.width) / 2;
			this._scrollBarThumbIcon.y = (this._scrollThumb.height - this._scrollBarThumbIcon.height) / 2;
		}
		override public function SetSize(width:Number, height:Number):void {
			super.SetSize(width, height);
			if (this._scrollArrowDown == null ||
				this._scrollArrowUp == null ||
				this._scrollThumb == null) {
					return;
				}
			var rect:Rectangle = new Rectangle(0, this._scrollArrowUp.height, 0, this.height - this._scrollArrowUp.height - this._scrollArrowDown.height - this._scrollThumb.height);
			rect.height = Math.round(rect.height);
			DragHelper.ChangeDragRect(this._scrollDragBar, rect);
		}
		override public function DataBind():void {
			super.DataBind();
			var rect:Rectangle = new Rectangle(0, this._scrollArrowUp.height, 0, this.height - this._scrollArrowUp.height - this._scrollArrowDown.height - this._scrollThumb.height);
			DragHelper.MakeItCanDrag(this._scrollDragBar, rect,
				_cb_StartDrag, _cb_EndDrag, _cb_Move, _cb_canDrag);
		}
		//Do Event
		protected function OnValueChanged():void {
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		//CallBack
		private function _cb_StartDrag(target:Sprite):void {
			
		}
		private function _cb_EndDrag(target:Sprite):void {
			
		}
		private function _cb_Move(e:MouseEvent):void {
			var y:Number = this._scrollDragBar.y - this._scrollArrowUp.height;
			var maxy:Number = this.height - this._scrollArrowUp.height - this._scrollArrowDown.height - this._scrollThumb.height;
			
			var v:Number = (this.MaxValue-this.MinValue) * y / maxy;
			this.Value = v + this.MinValue;
			//trace(this._scrollDragBar.y,this._scrollArrowUp.height,y);
			this.OnValueChanged();
		}
		private function _cb_canDrag():Boolean {
			return true;
		}
		//Events
		private function DPE_TrackClick(e:MouseEvent):void {
			var p1:Point = this.localToGlobal(new Point(this._scrollDragBar.x, this._scrollDragBar.y));
			//trace (e.stageY , p1.y)
			if (e.stageY > p1.y) {
				this.Value += this.MinChangeValue;
			}else {
				this.Value -= this.MinChangeValue;
			}
			this.OnValueChanged();
		}
		private function DPE_ArrowClick(e:MouseEvent):void {
			if (e.target == this._scrollArrowDown) {
				this.Value += this.MinChangeValue;
			}else if (e.target == this._scrollArrowUp) {
				//trace("arrow up");
				this.Value -= this.MinChangeValue;
			}
			this.OnValueChanged();
		}
	}
	
}
