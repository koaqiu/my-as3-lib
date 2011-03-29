package com.CGFinal.Controls{
	import com.CGFinal.Controls.Skins.SkinItem;
	import com.CGFinal.LiteComponent;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import xBei.Helper.StringHelper;
	
	/**
	 * 实现文本输入
	 * @author KoaQiu
	 * 
	 */
	public class TextBox extends LiteComponent{
		//属性
		[Inspectable]
		/**
		 * 获取文本框的内容 
		 * @return 
		 * 
		 */
		public function get text():String {
			return _txtInput.text;
		}
		public function set text(v:String):void {
			_txtInput.text = v;
			_txtNote.visible = v.length == 0;
		}
		[Inspectable]
		/**
		 * 提示信息 
		 * @return 
		 * 
		 */
		public function get Note():String {
			return _txtNote.text;
		}
		public function set Note(v:String):void {
			if (StringHelper.IsNullOrEmpty(v)) {
				v = "请输入";
			}
			_txtNote.text = v;
		}
		/**
		 * 输入限制
		 */
		public function get restrict():String {
			return _txtInput.restrict;
		}
		public function set restrict(v:String):void {
			_txtInput.restrict = v;
		}
		private var _maskRegExp:String = "";
		/**
		* 掩码（正在表达式）
		* 例：
		* 匹配数字：^\\d+$
		* 匹配电子邮件：^([a-z0-9])(([\\-.]|[_]+)?([a-z0-9]+))*(@)([a-z0-9])((([-]+)?([a-z0-9]+))?)*((.[a-z]{2,3})?(.[a-z]{2,6}))$
		*/ 
		[Inspectable]
		public function get MaskRegExp():String {
			return _maskRegExp;
		}
		public function set MaskRegExp(v:String):void {
			_maskRegExp = v;
		}
		
		/**
		* 是否接受Tab
		*/ 
		[Inspectable]
		public function get maxChars():int {
			return _txtInput.maxChars;
		}
		public function set maxChars(v:int):void {
			_txtInput.maxChars = v;
		}
		
		private var _validated:Boolean = false;
		/**
		 * 输入的内容是否通过验证 
		 * @return 
		 * 
		 */
		public function Validated():Boolean {
			return _validated;
		}
		
		[Inspectable(defaultValule=false)]
		/**
		 * 是否是密码框
		 * @return 
		 * 
		 */
		public function get PassWord():Boolean {
			return _txtInput.displayAsPassword;
		}
		public function set PassWord(v:Boolean):void {
			_txtInput.displayAsPassword = v;
		}
		private var _multiline:Boolean = false;
		[Inspectable(defaultValule = false)]
		/**
		 * 是否是多行模式 
		 * @return 
		 * 
		 */
		public function get Multiline():Boolean {
			return _multiline;
		}
		public function set Multiline(v:Boolean):void {
			_multiline = v;
			this._txtInput.wordWrap = v;
			this._txtInput.multiline = v;
			if (v) {
				_txtInput.displayAsPassword = false;
			}
		}
		/**
		 * 文本的长度 
		 * @return 
		 * 
		 */
		public function get length():int {
			return _txtInput.length;
		}
		
		//private
		private var _txtInput:TextField;
		private var _txtNote:TextField;
		private var _scrollBarV:ScrollBar;
		private var _bg:SkinItem;
		
		//Public
		/**
		 * 添加文本 
		 * @param txt
		 * 
		 */
		public function AppendText(txt:String):void {
			this._txtInput.appendText(txt);
			this._txtInput.setSelection(this._txtInput.length - 1, this._txtInput.length - 1);
			this._txtNote.visible = false;
		}
		/**
		 * 选择所有文本 
		 * 
		 */
		public function SelAllText():void {
			this._txtInput.setSelection(0, 9999);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this._txtNote = new TextField();
			this._txtInput = new TextField();
			this._bg = super.createObject("TextInput_Skin") as SkinItem;
			
			this._txtNote.textColor = 0x999999;
			this._txtNote.type = TextFieldType.DYNAMIC;
			this._txtNote.selectable = false;
			
			this._txtInput.type = TextFieldType.INPUT;
			
			this.addChild(this._bg);
			this.addChild(this._txtNote);
			this.addChild(_txtInput);
			this._txtInput.addEventListener(FocusEvent.FOCUS_IN, DPE_InputFocusIn);
			this._txtInput.addEventListener(FocusEvent.FOCUS_OUT, DPE_InputFocusOut);
			this._txtInput.addEventListener(KeyboardEvent.KEY_UP, DPE_InputKeyUp);
			this._txtInput.addEventListener(MouseEvent.MOUSE_WHEEL, DPE_TextMouseWhell);
		}
		override protected function draw():void {
			super.draw();
			var txtWidth:Number = width - 4;
			var txtHeight:Number = height - 2;
			this._txtNote.x = _txtInput.x = 1;
			this._txtNote.y = _txtInput.y = 1;
			this._txtNote.width = this._txtInput.width = txtWidth;
			this._txtInput.height = txtHeight;
			this._txtNote.height = 20;
			this._bg.width = width;
			this._bg.height = height;
		}
		/**
		 * 验证输入的文本 
		 * @return 
		 * 
		 */
		protected function checkInput():Boolean {
			if (this.Multiline==false && this._maskRegExp.length > 0) {
				var reg:RegExp = new RegExp(this._maskRegExp, "ig");
				_validated = reg.test(_txtInput.text);
				if (!_validated) {
					_txtInput.text = "";
					_txtNote.visible = true;
					focusSkin.gotoAndStop("error");
					return false;
				}
			}
			focusSkin.gotoAndStop("normal");
			return true;
		}
		
		//Do Events
		protected function OnEnter():void {
			this.dispatchEvent(new Event("enter"));
		}
		protected function OnTextChanged():void {
			this._txtNote.visible = this._txtInput.text.length == 0;
			if (this.Multiline) {
				if (this._txtInput.maxScrollV > 1){
					//显示滚动条
					if (_scrollBarV == null) {
						_scrollBarV = new ScrollBar();
						_scrollBarV.MinValue = 1;
						_scrollBarV.addEventListener(Event.CHANGE, DPE_VScrollBarChanged);
						addChild(_scrollBarV);
						_scrollBarV.height = this.height - 2;
						_scrollBarV.x = this.width-_scrollBarV.width-1;
						_scrollBarV.y = 1;
					}else {
						_txtInput.width = this.width - _scrollBarV.width - 1;
						_scrollBarV.visible = true;
					}
					_scrollBarV.MaxValue = this._txtInput.maxScrollV;
					_scrollBarV.Value = this._txtInput.scrollV;
				}else {
					if (_scrollBarV != null) {
						_scrollBarV.visible = false;
					}
					this._txtInput.width = this.width - 4;
				}
			}
		}
		//Events
		private function DPE_VScrollBarChanged(e:Event):void {
			this._txtInput.scrollV = this._scrollBarV.Value;
		}
		private function DPE_TextMouseWhell(e:MouseEvent):void {
			if (this.Multiline) {
				if (_scrollBarV != null) {
					this._scrollBarV.Value = this._txtInput.scrollV;
				}
			}
		}
		private function DPE_InputFocusIn(e:FocusEvent):void {
			if (Enabled == false) return;
			this.focusSkin.visible = true;
			this._txtNote.visible = false;
		}
		private function DPE_InputFocusOut(e:FocusEvent):void {
			if (Enabled == false) return;
			this.focusSkin.visible = !this.checkInput();
			this._txtNote.visible = this._txtInput.text.length == 0;
		}
		private function DPE_InputKeyUp(e:KeyboardEvent):void {
			this.OnTextChanged();
			switch (e.keyCode) {
				//case 9:break;
				case 13:
					//enter
					if (this.Multiline==false && this.checkInput()) {
						this.OnEnter();
					}
					break;
			}
		}
	}
}