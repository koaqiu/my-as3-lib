package xBei.UI {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.text.TextField;
	
	import gs.TweenLite;

	public class RadioButton extends LiteComponent {
		public const Version:String = "0.1";
		//属性
		private var _checked:Boolean = false;

		/**
		* 是否选择
		*/
		[Inspectable(defaultValue=false)]
		public function get Checked():Boolean {
			return _checked;
		}

		public function set Checked(v:Boolean):void {
			if (_checked != v) {
				_checked = v;
				if (v) {
					RadioButton.select(this);
				}
				TweenLite.to(this._dian, .3, {autoAlpha: v ? 1 : 0});
			}
		}
		private var _label:String = "标签";

		/**
		* 是否选择
		*/
		[Inspectable(defaultValue="标签")]
		public function get Label():String {
			return _label;
		}

		public function set Label(v:String):void {
			if (_label != v) {
				_label = v;
				_txt.text = v;
			}
		}
		private var _groupName:String = "RadioButtonGroup";

		/**
		* 是否选择
		*/
		[Inspectable(defaultValue="RadioButtonGroup")]
		public function get GroupName():String {
			return _groupName;
		}

		public function set GroupName(v:String):void {
			if (_groupName != v) {
				_groupName = v;
				RadioButton.changeGN(this);
			}
		}

	
		//static 单选按钮组管理
		private static var gm:Object = new Object();
		private static var __count:int = 0;

		/**
		* 初始化
		*/
		private static function add(rb:RadioButton):void {
			RadioButton.gm[rb.__index] = {GroupName: rb.GroupName, ins: rb};
		}

		/**
		* 修改分组
		*/
		private static function changeGN(rb:RadioButton):void {
			if (RadioButton.gm[rb.__index]) {
				RadioButton.gm[rb.__index].GroupName = rb.GroupName;
				RadioButton.gm[rb.__index].ins = rb;
			}
		}

		/**
		* 选择RadioButton
		*/
		private static function select(rb:RadioButton):void {
			for (var i:Object in RadioButton.gm) {
				var item:Object = RadioButton.gm[i];
				if (item.GroupName == rb.GroupName && item.ins != rb) {
					var rb2:RadioButton = (item.ins as RadioButton)
					if (rb2.Enabled && rb2.Checked) {
						rb2.Checked = false;
					}
				}
			}
		}
		//private
		private var __index:int = 0;
		private var _dian:Sprite;
		private var _bg:Sprite;
		private var _txt:TextField;
		private var _mouseOver:Boolean = false;

		public function RadioButton(){
			__index = RadioButton.__count++;
			super();
		}
		override protected function createChildren():void{
			super.createChildren();
			this.focusSkin.visible = false;
			RadioButton.add(this);
			this._bg = new Sprite();
			addChild(this._bg);
			this._dian = new Sprite();
			var g:Graphics = this._dian.graphics;
			g.clear();
			g.beginFill(0x1111ff, .9);
			g.drawCircle(12, height / 2, 2);
			g.endFill();
			//g = null;
			addChild(this._dian);
			TweenLite.to(this._dian, .1, {autoAlpha: 0});

			this._txt = new TextField();
			this._txt.textColor = 0;
			this._txt.autoSize = "left";
			this._txt.selectable = false;
			this._txt.text = this.Label;
			//this._txt.setTextFormat(tf);
			this._txt.x = 20;
			this._txt.y = (height - this._txt.height) / 2;

			this.addChild(_txt);

			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.CLICK, onClick);
		}

		override protected function draw():void {
			//super.draw();
			var g:Graphics = this._bg.graphics;
			g.clear();
			g.beginFill(0xffffff, 0);
			g.drawRect(0, 0, width, height);
			var m:Matrix = new Matrix();
			if (_mouseOver) {
				g.beginFill(0xffffff, .7);
				g.lineStyle(1, 0x11dd11, .8);
			} else {
				m.rotate(90);
				g.beginGradientFill("linear", [0xffffff, 0xffffff, 0xffffff], [.8, .01, .5], [0, 180, 255], m);
				g.lineStyle(1, 0x777777, .8);
			}
			//g.drawRect(5, 4, 14, 14);
			g.drawCircle(12, height / 2, 7);
			g.endFill();

		}

		//Events
		private function onClick(e:MouseEvent):void {
			this.Checked = !this._checked;
			this.dispatchEvent(new Event(Event.CHANGE));
		}

		private function onRollOver(e:MouseEvent):void {
			_mouseOver = true;
			this.draw();
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		private function onRollOut(e:MouseEvent):void {
			_mouseOver = false;
			this.draw();
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
	}
}