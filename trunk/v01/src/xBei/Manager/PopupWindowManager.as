package xBei.Manager
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	
	import xBei.Helper.StringHelper;

	/**
	 * 弹出窗口管理器，同一时间只有一个弹出窗口，新窗口弹出会自动关闭旧窗口
	 * @author KoaQiu
	 * @see xBei.Manager.PopUpManager
	 */
	public final class PopupWindowManager {
		private static var _curWin:DisplayObject;
		private static var _mask:Sprite;
		private static var _stage:Stage;
		private static var _initArgs:Object;
		private static var _curArgs:Object;
		private static var _showing:Boolean;
		private static var _list:Array = [];
		
		/**
		 * 禁止实例化
		 * @private 
		 * @param c
		 */
		function PopupWindowManager(c:pc){}
		/**
		 * 初始化 
		 * @param stage
		 * @param args		初始参数<p><pre>
{
	clickMaskClose:true,
	closeButton:true,
	clouseButtonClass:'CloseBt',
	clouseButtonName:'',
	closeButtonOffX:60,
	closeButtonOffY:19,
	maskAlpha:.6,
	offsetY:0,
	ease:null,
	noDispose:false,
	gotoFrame:'',
	sWidth:_stage.width,
	sHeight:_stage.height
}</pre></p>
		 * 
		 */
		public static function Init(stage:Stage,args:Object):void{
			_stage = stage;
			//初始化.参数
			var _args:Object = {
				clickMaskClose:true,
				closeButton:true,
				clouseButtonClass:'CloseBt',
				clouseButtonName:'',
				closeButtonOffX:60,
				closeButtonOffY:19,
				maskAlpha:.6,
				offsetY:0,
				ease:null,
				noDispose:false,
				gotoFrame:'',
				sWidth:_stage.width,
				sHeight:_stage.height,
				disableHostKey:false,
				onHide:null
			};
			if (args != null) {
				for (var k:String in args) {
					_args[k] = args[k];
				}
			}
			
			PopupWindowManager._initArgs = _args;
		}
		/**
		 * 显示弹出窗口，默认动画是在场景正中心从小到大显示
		 * @param win	要显示的对象
		 * @param args	参数
		 * 
		 */
		public static function Show(win:DisplayObject,args:Object = null):void{
			if(win == null || (win is DisplayObject) == false){
				throw new Error('xBei.Manager.PopupWindowManager.Show() 参数错误！必须是DisplayObject');
				return;
			}else if(_stage == null && win.stage == null){
				throw new Error('xBei.Manager.PopupWindowManager.Show() 严重错误！Stage 未初始化');
				return;
			}else if(win.stage != null){
				_stage = win.stage;
			}
			
			var curArgs:Object = {};
			for (var k:String in _initArgs) {
				curArgs[k] = _initArgs[k];
			}
			if (args != null) {
				for (var k2:String in args) {
					curArgs[k2] = args[k2];
				}
			}
			_list.push({w:win,arg:curArgs});
			if(_list.length == 1){
				_showWin(win,curArgs);
			}
		}
		private static function _showWin(win:DisplayObject,args:Object):void{
			_curArgs = args;
			if(_curArgs.disableHostKey){
				//MessageManager.SendMessage(HotKeyManager.DISABLED_KEYS);
				MessageManager.SendMessage(0xE0000000);
			}
			if(win is MovieClip && StringHelper.IsNullOrEmpty(_curArgs.gotoFrame) == false){
				(win as MovieClip).gotoAndStop(_curArgs.gotoFrame);
			}
			win.scaleX = win.scaleY = .04;
			var sw:Number = _curArgs.sWidth;// _stage.stageWidth;
			var sh:Number = _curArgs.sHeight;//_stage.stageHeight;
			win.x = (sw - win.width) / 2;
			win.y = (sh - win.height) / 2;
			win.visible = false;
			if(_mask == null){
				_mask = new Sprite();
				var g:Graphics = _mask.graphics;
				g.beginFill(0, 1)
				g.drawRect(0, 0, sw, sh);
				g.endFill();
			}
			_stage.addChild(_mask);
			_stage.addChild(win);
			
			_mask.visible = false;
			_mask.alpha = 0;
			if(_curArgs.clickMaskClose){
				_mask.addEventListener(MouseEvent.CLICK, DPE_MaskClick);
			}
			
			//修正位置
			if (_stage.align == "") {
				//居中
				var dx:Number = (_stage.stageWidth - _curArgs.sWidth);
				var dy:Number = (_stage.stageHeight - _curArgs.sHeight);
				
				win.x -= dx / 2;
				win.y -= dy / 2;
				//win._mask.x -= dx / 2;
				//win._mask.y -= dy / 2;
				
				win.x = (sw - win.width) / 2;
				win.y = (sh - win.height) / 2;
			}
			_curWin = win;
			_showing = true;
			//第一步 显示遮罩
			TweenLite.to(_mask, .2, {
				autoAlpha:_curArgs.maskAlpha,
				onCompleteParams:[win,sw,sh,_curArgs],
				onComplete:_showWindow
				}
			);
		}
		/**
		 * 隐藏窗口
		 */
		public static function Hide():void {
			//trace('_curWin=',_curWin);
			if (_curWin == null) return;
			//if (!_curWin.canClose) {
			//	return;
			//}
			_mask.removeEventListener(MouseEvent.CLICK, DPE_MaskClick);
			if (_showing) {
				//还在显示，延迟执行
				var timer:Timer = new Timer(1500);
				timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
					var tt:Timer = e.target as Timer;
					tt.stop();
					tt.removeEventListener(TimerEvent.TIMER, arguments.callee);
					tt = null;
					PopupWindowManager.Hide();
				} );
				timer.start();
				return;
			}
			
			//try{
			//	HotKeyManager.Instance.Enabled = true;
			//}catch(error:Error){}
			//trace("开始关闭 LightBox");
			
			if(_curArgs.closeButton){
				//第一步 隐藏按钮
				//TweenLite.to(btnClose, .3, {
				//	x:(win.width - win.btnClose.width) / 2,
				//	autoAlpha:0,
				//	onComplete:function():void {
				//		_hide(win);
				//	}
				//});
				_hide(_curWin,_curArgs);
			}else {
				//直接关闭
				_hide(_curWin,_curArgs);
			}
			
			_curWin = null;
		}
		private static function _showWindow(win:DisplayObject,sw:Number, sh:Number, args:Object):void{
			//第二步 显示窗体（在中间从小到大，亮白）
			TweenLite.to(win, .4, { 
				autoAlpha:1,
				scaleX:1,
				scaleY:1,
				onUpdate:function():void {
					win.x = _mask.x + (sw - win.width) / 2;
					win.y = _mask.y + (args.offsetY == 0?(sh - win.height) / 2:args.offsetY);
				},
				onCompleteParams:[win,_curArgs],
				onComplete:_changeWindowColor,
				ease:args.ease
				}
			);
		}
		private static function _changeWindowColor(win:DisplayObject,args:Object):void{
			//第三步 颜色恢复正常
			//win.onBeforeShow();
			TweenLite.to(win, .5, { 
				removeTint:true,
				onComplete:function():void {
					if(args.closeButton){
						//窗体显示完成，移动关闭按钮
						//win.btnClose.x = (win.width - win.btnClose.width) / 2;
						//TweenLite.to(win.btnClose, .3, { 
						//	x:glo.IsMac?_args.closeButtonOffX:win.width - _args.closeButtonOffX,
						//	autoAlpha:1
						//} );
					}
					//事件
					//win.onShow();
					_showing = false;
				}
			} );
		}
		private static function _hide(win:DisplayObject,args:Object):void {
			trace('_hide(win:DisplayObject,_args:Object):void');
			//第二步 窗口闪白且同时消失
			TweenLite.to(win, .2, {
				tint:0xffffff,
				autoAlpha:0,
				onComplete:function():void {
					//第三步 隐藏遮罩
					TweenLite.to(_mask, .4, { 
						autoAlpha:0,
						onComplete:function():void {
							//启用快捷键
							_mask.parent.removeChild(_mask);
							//win._mask = null;
							//移除对象
							win.parent.removeChild(win);
							if (args.noDispose == false) {
								if(args.closeButton){
									//btnClose.removeEventListener(MouseEvent.CLICK, DPE_MaskClick);
								}
							}
							if(args.disableHostKey){
								//MessageManager.SendMessage(HotKeyManager.ENABLED_KEYS);
								MessageManager.SendMessage(0xE0000001);
							}
							//事件
							_onWindowHide(win,args);
						}
					} );
				}
			});
		}
		private static function _onWindowHide(win:DisplayObject,args:Object):void{
			if(args.onHide != null){
				args.onHide(win);
			}
			_list.splice(0,1);
			if(_list.length > 0){
				var obj:Object = _list[0];
				_showWin(obj.w,obj.arg);
			}
		}
		//Events
		private static function DPE_MaskClick(e:MouseEvent):void {
			Hide();
		}
	}
}
class pc{}