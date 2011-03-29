package xBei.Controls {
	import com.CGFinal.BaseUI;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.system.Capabilities;
	import flash.text.*;
	
	import gs.TweenLite;
	
	/**
	 * 在顶部显示一个提示信息，多个信息同时显示时会从上到下依次排列
	 * @author KoaQiu
	 */
	public class Alert extends BaseUI {
		public const Version:String = "0.12";
		//属性
		private var _bgColor:uint = 0xffffff;
		[Inspectable(defaultValue="ffffff", type="Color")]
		public function get BgColor():uint {
			return _bgColor;
		}
		public function set BgColor(v:uint):void {
			_bgColor = v;
		}
		
		private var _font:String = "_sans";
		[Inspectable(defaultValue="_sans", type="Font Name")]
		public function get Font():String {
			return _font;
		}
		public function set Font(v:String):void {
			_font = v;
		}
		
		private var _fontSize:Number = 12;
		[Inspectable(defaultValue=12, type="Number")]
		public function get FontSize():Number {
			return _fontSize;
		}
		public function set FontSize(v:Number):void {
			_fontSize= v;
		}
		
		private var __alpha:Number = .8;
		[Inspectable(defaultValue=.8, type="Number")]
		public function get Alpha():Number {
			return __alpha;
		}
		public function set Alpha(v:Number):void {
			__alpha= v;
		}
		
		private var _textColor:uint = 0;
		[Inspectable(defaultValue="0", type="Color")]
		public function get TextColor():uint {
			return _textColor;
		}
		public function set TextColor(v:uint):void {
			_textColor= v;
		}
		[Inspectable(defaultValue=3)]
		public function get WaitTime():Number {
			return waittime;
		}
		public function set WaitTime(v:Number):void {
			waittime= v;
		}
		[Inspectable(defaultValue=.3)]
		public function get AniTime():Number {
			return anitime;
		}
		public function set AniTime(v:Number):void {
			anitime= v;
		}
		//使用变量
		private var waittime:Number = 3;
		private var anitime:Number = .3;
		private var swidth:Number = 690;
		private var sheight:Number = 400;
		//private var index = 1;
		private var lasty:int = 50;
		private var c:int = 0;

		private static var _ins:Alert = null;
		public function Alert() {
			if (Alert._ins!= null) {
				throw new Error("此组件只能有一个实例！");
				return;
			}
			this.visible = false;
			Alert._ins = this;
			if (stage) {
				this.onAddedToStage();
			}else {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		private function onAddedToStage(e:Event = null):void {
			if(e){
				this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			//this.swidth = stage.stageWidth;
			//this.sheight = stage.stageHeight;
		}
		/**
		 * 初始化组件
		 * @param	stage
		 * @param	config
		 */
		public static function Init(stage:Stage, config:Object = null):void {
			if(Alert._ins==null){
				Alert._ins = new Alert();
				stage.addChild(Alert._ins);
			}
			Alert._ins.swidth = stage.stageWidth;
			if (config) {
				for (var k:Object in config) {
					if (Alert._ins[k]) {
						Alert._ins[k] = config[k];
					}
				}
			}
		}

		/**
		 * 显示信息
		 * @param	txt		要显示的信息（支持使用\n换行）
		 * @param	exp		发生错误时是否抛出异常（默认抛出）
		 */
		public static function show(txt:String, exp:Boolean = true):void {
			if (Alert._ins == null || Alert._ins.stage == null ) {
				if(exp){
					//ToolTip._ins = new ToolTip();
					throw new Error("使用此方法前必须在stage中创建一个Alert实例！");
				}
				return;
			}
			Alert._ins._show(txt);
		}
		internal function _show(text:String):void{
			var mc:Sprite = new Sprite();
			
			stage.addChild(mc);
			var _txt:TextField = new TextField();
			mc.addChild(_txt);
			_txt.multiline = true;
			_txt.autoSize = TextFieldAutoSize.CENTER;
			_txt.selectable = false;
			_txt.htmlText = this.zy(text);// text.replace("\\n", "\n");
		
			var tf:TextFormat = _txt.defaultTextFormat;
			tf.font = _font;
			tf.size = _fontSize;
			tf.color = _textColor;
			_txt.setTextFormat(tf);
			//_txt.textColor = _textColor;
			
			var bg_width:Number = _txt.width+20;
			if (bg_width<30) {
				bg_width = 30;
			}
			var bg_height:Number = _txt.height+15;
			if (bg_height<20) {
				bg_height = 20;
			}

			_txt.x = (bg_width - _txt.width) / 2;
			_txt.y = (bg_height - _txt.height) / 2;
			
			var g:Graphics = mc.graphics;
			g.beginFill(_bgColor);
			g.lineStyle(0,0xcccccc);
			g.drawRoundRect(0, 0, bg_width, bg_height, 5);
			g.endFill();
			 
			//mc.filters = [new DropShadowFilter(4,45,0,.8)];
			mc.alpha = 0;
			if (stage.align == "") {
				mc.x = (swidth - mc.width) / 2;
			}else{
				mc.x = (stage.stageWidth - mc.width) / 2;
			}
			mc.y = -mc.height - 10;
			if(c==0){
				lasty=50;
			}
			var toy:Number=lasty;
			if(toy>sheight){
				lasty = 50;
			}
			//TODO 不滚动！
			//lasty += mc.height - 10;
			c++;
			TweenLite.to(mc, anitime, {
				y:toy,
				autoAlpha:Alpha,
				//delay:(c-1)*.2,
				onComplete:function():void{
					TweenLite.to(mc, anitime, {
						autoAlpha:0,
						delay:waittime,
						onComplete:function():void{
							mc.parent.removeChild(mc);
							c--;
					}});
			}});
		}//end function
		
		private function zy(str:String):String {
			str = str.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t");
			return str;
		}

	}
	
}
