package com.CGFinal.Utilities {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	
	import xBei.Manager.HotKeyManager;
	import xBei.Manager.MessageManager;
	
	/**
	 * 模式窗口管理
	 * @author KoaQiu
	 */
	public class LightBoxManager {
		private static var _curWin:LBWin;
		private static var _winList:Vector.<LBWin>;
		
		private static var _showing:Boolean = false;
		/**
		 * 是否正在打开窗口
		 * @return 
		 */
		public static function get Showing():Boolean {
			return LightBoxManager._showing;
		}
		/**
		 * 是否拥有打开的窗口
		 * @return 
		 */
		public static function get HasWinow():Boolean {
			return _winList != null && _winList.length > 0;
		}
		
		private static var _initArgs:Object;
		private static var _stage:Stage;
		/**
		 * 返回初始参数
		 * @return 
		 */
		public static function InitArgs():Object{
			var c:Object = {};
			for (var k:Object in _initArgs) {
				c[k] = _initArgs[k];
			}
			return c;
		}
		/**
		 * 初始化管理器
		 * @param stage
		 * @param args
		 */		
		public static function Init(stage:Stage,args:Object):void{
			_stage = stage;
			//初始化.参数
			var _args:Object = {
				ClickMaskClose:true,
				CloseButton:true,
				ClouseButtonClass:'CloseBt',
				clouseButtonName:'',
				closeButtonOffX:60,
				closeButtonOffY:19,
				maskAlpha:.6,
				OffsetY:0,
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
			
			LightBoxManager._initArgs = _args;
			LightBoxManager._winList = new Vector.<LBWin>();
		}
		/**
		 * 显示一个模式窗口
		 * @param	win
		 */
		internal static function ShowWin(win:LBWin):void {
			var index:int = LightBoxManager._winList.indexOf(win);
			if(index >= 0){
				trace('已经存在列表中....');
				LightBoxManager._winList.splice(index, 1);
			}
			LightBoxManager._winList.push(win);
			LightBoxManager._curWin = win;
			
			MessageManager.SendMessage(0xE0000000);
			
			//初始化.参数
			var stage:Stage = win.stage;
			win.scaleX = win.scaleY = .04;
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;

			if(sw < stage.width){
				sw = stage.width;
			}
			if(sh < stage.height){
				sh = stage.height;
			}
			
			var location:int = 0;
			if(stage.align == ''){
				location = 0x33;
			}else{
				if(stage.align.indexOf('L') >= 0){
					location |= 0x01;
				}else if(stage.align.indexOf('R') >= 0){
					location |= 0x07;
				}else{
					location |= 0x03;
				}
				if(stage.align.indexOf('T') >= 0){
					location |= 0x10;
				}else if(stage.align.indexOf('B') >= 0){
					location |= 0x70;
				}else{
					location |= 0x30;
				}
				
				trace('StageAlign = 0x', location.toString(16));
			}

			win.visible = false;
			win._mask = new Sprite();
			stage.addChild(win._mask);
			stage.addChild(win); 
			
			trace('mask.rect:',sw,sh);
			var g:Graphics = win._mask.graphics;
			g.beginFill(0, 1)
			g.drawRect(0, 0, sw, sh);
			g.endFill();
			win._mask.visible = false;
			win._mask.alpha = 0;
			if(win._args.ClickMaskClose){
				win._mask.addEventListener(MouseEvent.CLICK, mask_click);
			}
			win.x = (sw - win.width) / 2;
			win.y = (sh - win.height) / 2;
			//修正位置
			var dx:Number = 0;
			var dy:Number = 0;
			
			if((location & 0x03) == 0x03){
				dx = (sw - win._args.sWidth);
			}else if((location & 0x07) == 0x07){
				
			}else{
				trace('左边');
				dx = (sw - win._args.sWidth);
			}
			
			if((location & 0x30) == 0x30){
				dy = (sh - win._args.sHeight);
			}else if((location & 0x70) == 0x70){
				
			}else{
				trace('顶部');
				dy = (sh - win._args.sHeight);
			}
			win._mask.x -= dx / 2;
			win._mask.y -= dy / 2;

			if(win._args.CloseButton){
				win.btnClose.addEventListener(MouseEvent.CLICK, mask_click);
			}
			
			trace('OffsetY',win._args.OffsetY);
			var _onUpdate2:Function = function(pWin:LBWin, stageWidth:Number,stageHeight:Number):void {
				//trace(pWin.x, pWin._mask.x, stageWidth);
				pWin.x = pWin._mask.x + (stageWidth - pWin.width) / 2;
				pWin.y = pWin._mask.y + (
										pWin._args.OffsetY == 0 ? (stageHeight - pWin.height) / 2
																: pWin._args.OffsetY
										);
				//trace('size win:',stageWidth,stageHeight,pWin._mask.y ,pWin.y, pWin.height, (stageHeight - pWin.height) / 2);
			};
			var _onComplete3:Function = function(pWin:LBWin):void {
				if(pWin._args.CloseButton){
					//trace("窗体显示完成，移动关闭按钮");
					pWin.btnClose.x = (pWin.width - pWin.btnClose.width) / 2;
					TweenLite.to(pWin.btnClose, .3, { 
						x:glo.IsMac ? pWin._args.closeButtonOffX
									: pWin.width - pWin._args.closeButtonOffX,
						autoAlpha:1
					} );
				}
				//事件
				pWin.onShow();
				win.IsAni = false;
				LightBoxManager._showing = false;
			}
			var _onComplete2:Function = function(pWin:LBWin):void {
				//trace("第三步 颜色恢复正常");
				//pWin.onBeforeShow();
				TweenLite.to(pWin, .5, { 
					removeTint:true,
					onCompleteParams:[pWin],
					onComplete:_onComplete3
				});
			};
			var _onComplete1:Function =	function(pWin:LBWin,stageWidth:Number,stageHeight:Number):void {
				//trace("第二步 显示窗体（在中间从小到大，亮白）");
				TweenLite.to(pWin, .4, { 
					autoAlpha:1,
					scaleX:1,
					scaleY:1,
					onUpdateParams:[pWin,stageWidth, stageHeight],
					onUpdate:_onUpdate2,
					onCompleteParams:[pWin],
					onComplete:_onComplete2,
					ease:pWin._args.ease
				} );
			};
			//第一步 显示遮罩
			//trace("第一步 显示遮罩");
			LightBoxManager._showing = true;
			win.IsAni = true;
			TweenLite.to(win._mask, .2, {
				autoAlpha:win._args.maskAlpha,
				onCompleteParams:[win, sw, sh],
				onComplete: _onComplete1
			});
		}
		/**
		 * 隐藏窗口
		 */
		public static function Hide(tmpWin:LBWin = null):void {
			if(tmpWin == null){
				if(LightBoxManager._winList.length > 0){
					tmpWin = LightBoxManager._winList[LightBoxManager._winList.length - 1];
				}else{
					return;
				}
			}
			//*
			if (tmpWin.IsAni) {
				trace('窗口还在显示，等待一会儿再关闭...')
				var timer:Timer = new Timer(1500);
				timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
					var tt:Timer = e.target as Timer;
					//trace(tt, LightBoxManager._showing);
					tt.stop();
					tt.removeEventListener(TimerEvent.TIMER, arguments.callee);
					tt = null;
					LightBoxManager.Hide(tmpWin);
				} );
				timer.start();
				return;
			}
			//*/
			
			trace('LightBoxManager.Hide canClose=', tmpWin.canClose, 'isshow=', tmpWin.IsShow)
			if (tmpWin.canClose == false || tmpWin.IsShow == false) {
				return;
			}
			
			//trace("开始关闭 LightBox");
			if(tmpWin._args.CloseButton){
				//第一步 隐藏按钮
				TweenLite.to(tmpWin.btnClose, .3, {
					x:(tmpWin.width - tmpWin.btnClose.width) / 2,
					autoAlpha:0,
					onCompleteParams:[tmpWin],
					onComplete:function(pWin:LBWin):void {
						_hide(pWin);
					}
				});
			}else {
				//直接关闭
				_hide(tmpWin);
			}
			tmpWin = null;
		}
		private static function _hide(win:LBWin):void {
			//第二步 窗口闪白且同时消失
			TweenLite.to(win, .2, {
				tint:0xffffff,
				autoAlpha:0,
				onCompleteParams:[win],
				onComplete:function(pWin:LBWin):void {
					//第三步 隐藏遮罩
					//trace(win, win._mask, mask_click);
					pWin._mask.removeEventListener(MouseEvent.CLICK, mask_click);
					TweenLite.to(win._mask, .4, { 
						autoAlpha:0,
						onCompleteParams:[pWin],
						onComplete:function(ppWin:LBWin):void {
							//启用快捷键
							//事件
							ppWin.onHide();
							ppWin._mask.parent.removeChild(ppWin._mask);
							ppWin._mask = null;
							//移除对象
							if(ppWin.parent != null){
								ppWin.parent.removeChild(ppWin);
							}
							if (ppWin._args.noDispose == false) {
								if(ppWin._args.CloseButton){
									ppWin.btnClose.removeEventListener(MouseEvent.CLICK, mask_click);
								}
								ppWin.dispose();
							}
							LightBoxManager._winList.pop();
							if(LightBoxManager._winList.length == 0){
								MessageManager.SendMessage(0xE0000001);
							}else{
								MessageManager.SendMessage(0xE0000000);	
							}
						}
					} );
					//窗口恢复原始状态
					//TweenLite.to(win, .1, { removeTint:true,scaleX:.04,scaleY:.04} );
				}
			});
		}
		private static function mask_click(e:MouseEvent):void {
			trace('LightBoxManager.Mask clicked');
			if(_curWin != null){
				trace('_curWin.IsShow=',_curWin.IsShow)
			}
			if(_curWin == null || _curWin.IsShow)
			LightBoxManager.Hide();
		}
	}
}
