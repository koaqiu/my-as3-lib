package com.CGFinal.Controls{
	import com.CGFinal.LiteComponent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	[Event(name = "change", type = "flash.events.Event")]
	/**
	 *是个数字选择器 
	 * @author KoaQiu
	 * 
	 */
	public class LineSilder extends LiteComponent{
		private var _bg:Sprite;
		private var _ball:Sprite;
		
		private var _maxValue:Number = 100;
		private var _minValue:Number = 0;
		private var _value:Number = 0;
		private var _sW:Number = 46;
		/**
		* 最大值
		*/
		[Inspectable(defaultValue=100)]
		public function get MaxValue():Number {
			return _maxValue;
		}
		public function set MaxValue(v:Number):void {
			if (v < _minValue) return;
			if (_maxValue != v) {
				var oldV:Number = this.Value;
				_maxValue = v;
				if (v < this.Value) {
					this.Value = v;
				}else {
					_ball.x = (oldV - this.MinValue) / (this.MaxValue-this.MinValue) * _sW ;
				}
			}
		}
		/**
		* 最小值
		*/
		[Inspectable(defaultValue=1)]
		public function get MinValue():Number {
			return _minValue;
		}
		public function set MinValue(v:Number):void {
			if (v>_maxValue) return;
			if (_minValue != v) {
				_minValue = v;
			}
		}
		
		/**
		 * 值 
		 * @return 
		 * 
		 */
		public function get Value():Number {
			return this._value;
		}
		public function set Value(v:Number):void {
			if (v < this.MinValue) {
				v = this.MinValue;
			}else if (v > this.MaxValue) {
				v = this.MaxValue;
			}
			this._value = v;
			_ball.x = (v - this.MinValue) / (this.MaxValue-this.MinValue) * _sW;
			this.OnValueChanged();
		}
		public function LineSilder() {
			super();
			//this.SetSize(58,12);
		}
		override public function set Enabled(value:Boolean):void {
			super.Enabled = value;
			if (value) {
				_ball.addEventListener(MouseEvent.MOUSE_DOWN, DPE_BallMouseDown);
			}else {
				_ball.removeEventListener(MouseEvent.MOUSE_DOWN, DPE_BallMouseDown);
			}
		}
		protected override function createChildren():void {
			super.createChildren();
			this._sW = this.width - 12;
			this._bg = super.createObject("LSBg") as Sprite;
			this._bg.width = this.width;
			this._ball = super.createObject("LSBall") as Sprite;
			
			this.addChild(_bg);
			this.addChild(_ball);
			this._ball.x = 19;
			this._ball.y = 0;
			this.Enabled = true;
		}
		override public function SetSize(width:Number, height:Number):void 	{
			super.SetSize(width, height);
			this._sW = this.width - 12;
			if (this._bg != null) {
				this._bg.width = this.width;
				_ball.x = (this.Value - this.MinValue) / (this.MaxValue-this.MinValue) * _sW;
			}
		}
		//Do Events
		/**
		 * 修改数值时触发 
		 */
		protected function OnValueChanged():void {
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		//Evnets
		private function DPE_BallMouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, DPE_BallMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, DPE_BallMouseMove);
			var rect:Rectangle = new Rectangle(0, 0, _sW, 0);
			_ball.startDrag(false, rect);
		}
		private function DPE_BallMouseMove(e:MouseEvent):void {
			this._value = Math.round((_ball.x) / _sW * (this.MaxValue-this.MinValue) + this.MinValue);
			this.OnValueChanged();
		}
		private function DPE_BallMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, DPE_BallMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, DPE_BallMouseUp);
			_ball.stopDrag();
		}
	}
}