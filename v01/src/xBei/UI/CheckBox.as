package xBei.UI {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	
	import gs.TweenLite;

	[Event(name="change", type="flash.Events.Event")]
	public class CheckBox extends LiteComponent {
		public static const Version:String = "0.2";
		private var _cvs:Array = [];
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
			//trace(this.name, ".set checked:", v, _checked,"_inspector=",_inspector);
			if (super.addInitData("Checked", v)) {
				return;
			}
			if (this._checked != v) {
				this._checked = v;
				TweenLite.to(this._gou, .3, {autoAlpha: v ? 1 : 0});
			}
		}
		private var _autoSize:Boolean = false;
		[Inspectable(defaultValue="false")]
		public function get AutoSize():Boolean{
			return this._autoSize;
		}
		public function set AutoSize(v:Boolean):void{
			if(this._autoSize == v) return;
			this._autoSize = v;
			if(v){
				this._txt.autoSize = "left";
				this._txt.y = (height-this._txt.height)/2;
			}else{
				this._txt.autoSize = 'none';
			}
		}

		/**
		* 是否选择
		*/
		[Inspectable(defaultValue="标签")]
		public function get Label():String {
			return _txt.text;
		}

		public function set Label(v:String):void {
			this._txt.text = v;
			this._txt.y = (height-this._txt.height)/2;
		}

		override public function set Enabled(value:Boolean):void {
			if (super.Enabled == value)
				return;
			if (value) {
				this._txt.textColor = 0x0;
			} else {
				this._txt.textColor = 0x999999;
			}
			super.Enabled = value;
		}

		protected var _icon:SkinItem;
		protected var _gou:Sprite;
		protected var _txt:TextField;

		private var _isOver:Boolean = false;

		override protected function createChildren():void {
			super.createChildren();
			this._icon = glo.CreateObject("CheckBoxIcon") as SkinItem;
			this._gou = glo.CreateObject("CheckBoxSelectedIcon") as Sprite;
			this._gou.alpha = 0;
			this.focusSkin.width = this._icon.width + 2;
			this.focusSkin.height = this._icon.height + 2;
			this._txt = new TextField();
			this._txt.textColor = 0;
			//this._txt.autoSize = "left";
			//this._txt.autoSize = 'none';
			this._txt.width = this.width - 2 - this._icon.width;
			this._txt.height = this.height + 2;
			this._txt.selectable = false;
			//this._txt.setTextFormat(tf);
			this.addChild(this._icon);
			this.addChild(this._gou);
			this.addChild(this._txt);

			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(MouseEvent.ROLL_OVER, function(me:MouseEvent):void {
				_isOver = true;
				_icon.gotoAndStop("over");
			});
			this.addEventListener(MouseEvent.ROLL_OUT, function(me:MouseEvent):void {
				_isOver = false;
				_icon.gotoAndStop("normal");
			});
			this.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
				_icon.gotoAndStop("down");
			});
			this.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
				_icon.gotoAndStop(_isOver ? "over" : "normal");
			});
		}

		override protected function draw():void {
			super.draw();
			this._txt.x = 20;
			//trace('h:',this.height, 'th:', this._txt.height)
			//this._txt.y = (this.height - this._txt.height) / 2;
			this._icon.y = (height - this._icon.height) / 2;
			this._gou.y = this._icon.y + 2.5;
			this._gou.x = this._icon.x + 2;
			//this._txt.y = (height-this._txt.height)/2;
		}

		override public function DataBind():void {
			super.DataBind();
			this.Label = "CheckBox";
		}

		//Events
		private function onClick(e:MouseEvent):void {
			if (!this.Enabled)
				return;
			this.Checked = !this._checked;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}