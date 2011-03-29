package com.CGFinal.Controls{
	import com.CGFinal.LiteComponent;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import gs.TweenGroup;
	
	public class NumberLineSilder extends LiteComponent{
		private var _txtNumber:TextBox;
		private var _lsNumber:LineSilder;
		private var _bg:Shape = new Shape();
		
		
		private var _value:Number = 0.0;
		//属性
		[Inspectable]
		/**
		 * 值 
		 * @return 
		 */
		public function get Value():Number {
			return _value;
		}
		public function set Value(v:Number):void {
			if (v < this.MinValue) {
				_value = this.MinValue;
			}else if (v > this.MaxValue) {
				_value = this.MaxValue;
			}else{
				_value = v;
			}
			this._lsNumber.Value = this._value;
			this.setText(_value);
		}
		private var _maxValue:Number = 100;
		/**
		 * 最大值
		 */
		[Inspectable(defaultValue = 100)]
		public function get MaxValue():Number {
			return _maxValue;
		}
		public function set MaxValue(v:Number):void {
			if (v < _minValue) return;
			_maxValue = v;
			if (v < this._value) {
				this.Value = v;
			}
			this._lsNumber.MaxValue = v;
		}
		private var _minValue:Number = 1;
		/**
		 * 最小值
		 */
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
			this._lsNumber.MinValue = v;
		}
		private var _decimalPlaces:int = 0;
		/**
		 * 显示的小数点位数
		 */
		public function get DecimalPlaces():int {
			return _decimalPlaces;
		}
		public function set DecimalPlaces(v:int):void {
			_decimalPlaces = v;
		}
		private var _increment:Number = 1;
		/**
		 * 每点击一次按钮增加或减少的数量
		 */
		public function get Increment():Number {
			return _increment;
		}
		public function set Increment(v:Number):void {
			_increment = v;
		}
		override public function set Enabled(value:Boolean):void {		
			super.Enabled = value;
			this._txtNumber.Enabled =
				this._lsNumber.Enabled = value;
			if (value) {
				this.addEventListener(MouseEvent.ROLL_OVER, DPE_RollOver);
				//this.addEventListener(MouseEvent.ROLL_OUT, DPE_RollOut);
				this._txtNumber.addEventListener(FocusEvent.FOCUS_OUT, DPE_FocusOut);
				this._txtNumber.addEventListener(MouseEvent.CLICK, DPE_TextBoxClicked);
				this._txtNumber.addEventListener(MouseEvent.MOUSE_WHEEL, DPE_TextBoxWheel);
				this._txtNumber.addEventListener(Event.CHANGE, DPE_TextBoxChanged);
				this._lsNumber.addEventListener(Event.CHANGE, DPE_LineSilderChanged);
			}else {
				this.removeEventListener(MouseEvent.ROLL_OVER, DPE_RollOver);
				//this.removeEventListener(MouseEvent.ROLL_OUT, DPE_RollOut);
				this._txtNumber.removeEventListener(FocusEvent.FOCUS_OUT, DPE_FocusOut);
				this._txtNumber.removeEventListener(MouseEvent.CLICK, DPE_TextBoxClicked);
				this._txtNumber.removeEventListener(MouseEvent.MOUSE_WHEEL, DPE_TextBoxWheel);
				this._txtNumber.removeEventListener(Event.CHANGE, DPE_TextBoxChanged);
				this._txtNumber.removeEventListener(Event.CHANGE, DPE_LineSilderChanged);
			}
		}
		override protected function createChildren():void {
			super.createChildren();
			this._txtNumber = new TextBox();
			this._txtNumber.text = "0";
			this._txtNumber.Note = "数字";
			this._txtNumber.restrict = "0-9.";
			
			this._lsNumber = new LineSilder();
			this._lsNumber.x = 2;
			this._lsNumber.y = 2;
			this._bg.y = 4;
			this.addChild(this._bg);
			this.addChild(this._lsNumber);
			this.addChild(this._txtNumber);
			this.Enabled = true;
		}
		override protected function draw():void {
			super.draw();
			var g:Graphics = this._bg.graphics;
			g.beginFill(0xffffff, .8);
			g.lineStyle(0, 0xcccccc, .8);
			g.drawRoundRect(1, -2, this.width-2, this._lsNumber.height + 4,5);
			g.endFill();
		}
		override public function SetSize(width:Number, height:Number):void {
			super.SetSize(width, height);
			this._txtNumber.width = width;
			this._txtNumber.height = height;
			this._lsNumber.width = width - 4;
		}
		/**
		 * 显示输出文本
		 * @param	v
		 */
		private function setText(v:Number):void {
			//显示指定位数的小数点
			var d:Number = Math.pow(10, this.DecimalPlaces);
			this._txtNumber.text = String(Math.floor(v * d) / d);
		}
		//Do Events
		protected function onValueChanged():void {
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		//Events
		private function DPE_TextBoxClicked(e:MouseEvent):void {
			this._txtNumber.SelAllText();
		}
		private function DPE_FocusOut(e:FocusEvent):void {
			this.setText(this.Value);
		}
		private function focusIn(e:FocusEvent):void {
			this._txtNumber.SelAllText();
		}
		private function DPE_TextBoxWheel(e:MouseEvent):void {
			if (e.delta > 0) {
				this.Value += this.Increment;
			}else {
				this.Value -= this.Increment;
			}
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		private function DPE_TextBoxChanged(e:Event):void {
			e.stopImmediatePropagation();
			if (this._txtNumber.text.length == 0) {
				this._value = this.MinValue;
			}else {
				var tmp:Number = Number(this._txtNumber.text);
				if (tmp >= this.MinValue && tmp <=this.MaxValue) {
					this.Value = tmp;
					this.onValueChanged();
				}
			}
		}
		private function DPE_LineSilderChanged(e:Event):void {
			this._value = this._lsNumber.Value;
			this.setText(this._value);
			this.onValueChanged();
		}
		private function DPE_GridMouseMove(e:MouseEvent):void {
			if (this._txtNumber.hitTestPoint(e.stageX, e.stageY) == false &&
				this._lsNumber.hitTestPoint(e.stageX, e.stageY) == false) {
				if (e.buttonDown) return;
				TweenGroup.allTo(
					[this._lsNumber, this._bg],
					.3,
					{
						y : 4
					}
				);
			}else {
				TweenGroup.allTo(
					[this._lsNumber, this._bg],
					.3,
					{
						y : - this._bg.height
					}
				);
			}
		}
		private function DPE_RollOver(e:MouseEvent):void {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, DPE_GridMouseMove);
			this.removeEventListener(MouseEvent.ROLL_OVER, DPE_RollOver);
		}
	}
}