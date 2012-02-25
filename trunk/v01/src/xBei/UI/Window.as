package xBei.UI
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import gs.TweenLite;
	
	import xBei.Data.WindowInitData;
	import xBei.Helper.StringHelper;
	import xBei.Manager.MessageManager;
	import xBei.Manager.StageManager;

	public class Window extends XMovieClip{
		private static var _winList:Vector.<Window> = new Vector.<Window>();
		private static var _showing:Boolean = false;
		
		/**
		 * 是否正在打开窗口
		 * @return 
		 */
		public static function get Showing():Boolean {
			return _showing;
		}
		/**
		 * 是否拥有打开的窗口
		 * @return 
		 */
		public static function get HasWinow():Boolean {
			return _winList != null && _winList.length > 0;
		}
		
		public var CanCloseWindow:Boolean = true;
		public var IsTransformation:Boolean = false;
		
		private var _closeButton:SimpleButton;
		private var _mask:Sprite;
		private var _isShow:Boolean = false;
		private var _id:int;
		
		/**
		 * ID
		 * @return 
		 */
		public function get ID():int{
			return this._id;
		}
		/**
		 * 是否已经显示
		 * @return 
		 */
		public function get IsShow():Boolean{
			return _isShow;
		}
		
		private var _args:WindowInitData;
		protected function get initData():WindowInitData{
			return this._args;
		}
		public function Window(){
			_args = new WindowInitData();
			this._id = NewID();
			stop();
			this.addEventListener(KeyboardEvent.KEY_UP, DPE_KeyUp);
			super();
		}
		private static var __id_creator:int = 0;
		public static function NewID():int{
			__id_creator++;
			return __id_creator;
		}
		/**
		 * 显示窗口（静态）
		 * @param	stage
		 * @param	pIsModel
		 * @param	args
		 */
		public function Show(pIsModel:Boolean, args:Object = null):void {
			//if(pStage == null){
			//	throw new ArgumentError('xBei.UI.Window.Show(); pStage不能为空（null）');
			//}
			var pStage:Stage = StageManager.Instance.Stage;
			if(!this.OnBeforeShow()){
				return;
			}
			
			this.alpha = 1;
			this.visible = true;
			this.scaleX = this.scaleY = 1;
			this.initData.Init(pStage, args);
			if (glo.IsNullOrUndefined(this.initData.goto) == false) {
				gotoAndStop(this.initData.goto);
			}
			
			pStage.addChild(this);
			//处理关闭按钮
			if (this.initData.HasCloseButton) {
				if (StringHelper.IsNullOrEmpty(this.initData.CloseButtonName)) {
					this._closeButton = new (getDefinitionByName(this.initData.CloseButtonClass) as Class);
					this.addChild(_closeButton);
				}else {
					this._closeButton = this.getChildByName(this.initData.CloseButtonName) as SimpleButton;
					trace('关闭按钮坐标！',this._closeButton.x, this._closeButton.y);
					this.initData.CloseButtonOffX = this.width - this._closeButton.x;
					this.initData.CloseButtonOffY = this._closeButton.y;
				}
				this._closeButton.alpha = .01;
				this._closeButton.y = this.initData.CloseButtonOffY;
			}else if (StringHelper.IsNullOrEmpty(this.initData.CloseButtonName) == false) {
				this.getChildByName(this.initData.CloseButtonName).visible = false;
			}
			this.show(pIsModel);
		}
		protected function show(pIsModel:Boolean):void{
			trace('显示：', this.ID);
			var index:int = _winList.indexOf(this);
			if(index >= 0){
				_winList.splice(index, 1);
			}
			_winList.push(this);
			////全局禁用热键
			MessageManager.SendMessage(0xE0000000);
			
			//初始化.参数
			
			this.Scale = .04;
			var sm:StageManager = StageManager.Instance;
			var r:Rectangle = sm.ClientRect;
			
			this.visible = false;
			this._mask = new Sprite();
			this._mask.name = StringHelper.Format('window_Mask_{0}', this.ID);
			sm.addChild(this._mask);
			sm.addChild(this); 
			
			var g:Graphics = this._mask.graphics;
			g.beginFill(0, 1)
			g.drawRect(r.x, r.y, r.width, r.height);
			g.endFill();
			this._mask.visible = false;
			this._mask.alpha = 0;
			if(this.initData.MaskCanBeClickForCloseWindow){
				this._mask.addEventListener(MouseEvent.CLICK, DPE_CloseButtonClicked);
			}
			var cp:Point = sm.GetPosition(this, 0x33);
			this.x = cp.x;
			this.y = cp.y;
			
			if(this.initData.HasCloseButton && this._closeButton != null){
				this._closeButton.addEventListener(MouseEvent.CLICK, DPE_CloseButtonClicked);
			}
			
			//第一步 显示遮罩
			//trace("第一步 显示遮罩");
			_showing = true;
			this.IsTransformation = true;
			TweenLite.to(this._mask, .2, {
				'autoAlpha':this.initData.MaskAlpha,
				'onComplete': _onComplete1
			});
		}
		private function _onComplete3():void {
			if(this.initData.HasCloseButton){
				//trace("窗体显示完成，移动关闭按钮");
				this._closeButton.x = (this.width - this._closeButton.width) / 2;
				TweenLite.to(this._closeButton, .3, { 
					'x':glo.IsMac ? this.initData.CloseButtonOffX : this.width - this.initData.CloseButtonOffX,
					'autoAlpha':1
				} );
			}
			//事件
			this.OnShow();
			this.IsTransformation = false;
			_showing = false;
		}
		private function _onComplete2():void {
			//trace("第三步 颜色恢复正常");
			//pWin.onBeforeShow();
			TweenLite.to(this, .5, { 
				'removeTint':true,
				'onComplete':_onComplete3
			});
		};
		private function _onUpdate2():void {
			var sm:StageManager = StageManager.Instance;
			var cenP:Point = sm.GetPosition(this, 0x33);
			this.x = cenP.x;
			this.y = cenP.y;
			//pWin._mask.y + (
			//	pWin.initData.OffsetY == 0 ? (stageHeight - pWin.height) / 2
			//	: pWin.initData.OffsetY
			//);
		};
		private function _onComplete1():void {
			//trace("第二步 显示窗体（在中间从小到大，亮白）");
			TweenLite.to(this, .4, { 
				'autoAlpha':1,
				'scaleX':1,
				'scaleY':1,
				'onUpdate':_onUpdate2,
				'onComplete':_onComplete2,
				'ease':this.initData.ease
			} );
		};
		/**
		 * 隐藏窗口
		 */
		public static function Hide(tmpWin:Window = null):void {
			if(tmpWin == null){
				if(_winList.length > 0){
					tmpWin = _winList[_winList.length - 1];
				}else{
					return;
				}
			}
			//*
			if (tmpWin.IsTransformation) {
				trace('窗口还在显示，等待一会儿再关闭...')
				var timer:Timer = new Timer(1500);
				timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
					var tt:Timer = e.target as Timer;
					tt.stop();
					tt.removeEventListener(TimerEvent.TIMER, arguments.callee);
					tt = null;
					Window.Hide(tmpWin);
				} );
				timer.start();
				return;
			}
			//*/
			
			trace('LightBoxManager.Hide canClose=', tmpWin.CanCloseWindow, 'isshow=', tmpWin.IsShow, tmpWin.ID)
			if (tmpWin.OnBeforeHide() == false || tmpWin.CanCloseWindow == false || tmpWin.IsShow == false) {
				return;
			}
			
			trace("开始关闭 LightBox");
			if(tmpWin.initData.HasCloseButton){
				//第一步 隐藏按钮
				TweenLite.to(tmpWin._closeButton, .3, {
					x:(tmpWin.width - tmpWin._closeButton.width) / 2,
					autoAlpha:0,
					onComplete:tmpWin._hide
				});
			}else {
				//直接关闭
				tmpWin._hide();
			}
			tmpWin = null;
		}
		private function _hide():void {
			//第二步 窗口闪白且同时消失
			TweenLite.to(this, .2, {
				'tint':0xffffff,
				'autoAlpha':0,
				'onCompleteParams':[this],
				'onComplete':function(pWin:xBei.UI.Window):void {
					//第三步 隐藏遮罩
					//trace(win, win._mask, mask_click);
					if(pWin._mask != null){
						pWin._mask.removeEventListener(MouseEvent.CLICK, pWin.DPE_CloseButtonClicked);
						TweenLite.to(pWin._mask, .4, { 
							'autoAlpha':0,
							'onComplete':_hide2
						} );
					}else{
						trace('mask is null');
						pWin._hide2();
					}
					//窗口恢复原始状态
					//TweenLite.to(win, .1, { removeTint:true,scaleX:.04,scaleY:.04} );
				}
			});
		}
		private function _hide2():void {
			//启用快捷键
			//事件
			this.OnHide();
			if(this._mask != null && this._mask.parent != null){
				this._mask.parent.removeChild(this._mask);
			}
			this._mask = null;
			//移除对象
			if(this.parent != null){
				this.parent.removeChild(this);
			}
			if (this.initData.NoDispose == false) {
				if(this.initData.HasCloseButton){
					this._closeButton.removeEventListener(MouseEvent.CLICK, DPE_CloseButtonClicked);
				}
				this.dispose();
			}
			_winList.pop();
			if(_winList.length == 0){
				//全局启用用热键
				MessageManager.SendMessage(0xE0000001);
			}else{
				//全局禁用热键
				MessageManager.SendMessage(0xE0000000);	
			}
			trace("完成关闭 LightBox");
		}
		//Do Event
		protected function OnBeforeShow():Boolean{
			return true;
		}
		protected function OnBeforeHide():Boolean{
			return true;
		}
		protected function OnHide():void{
			this._isShow = false;
			this.dispatchEvent(new Event("onHide"));
			this.removeEventListener(KeyboardEvent.KEY_UP, DPE_KeyUp);
		}
		protected function OnShow():void{
			this._isShow = true;
			trace(this,'onshow');
			this.dispatchEvent(new Event("onShow"));
			if(this.stage != null){
				this.stage.focus = this;
			}
		}
		
		//Events
		private function DPE_KeyUp(e:KeyboardEvent):void {
			if (e.keyCode == 27) {
				Hide(this);
			}
		}
		private function DPE_CloseButtonClicked(e:MouseEvent):void {
			trace('LightBoxManager.Mask clicked', e.target.name);
			var win:Window;
			if(e.target is SimpleButton){
				win = e.target.parent as Window;
				Hide(win);
			}else{
				var l:int = _winList.length;
				for(var i:int = l - 1; i >= 0; i--){
					win = _winList[i];
					if(win._mask == e.target){
						//if(win.IsShow)
						Hide(win);
						break;
					}
				}//end for
			}
		}//end function
	}
}