package com.CGFinal.Utilities {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.getDefinitionByName;
	
	import xBei.Helper.StringHelper;
	import xBei.Interface.IDispose;
	import xBei.UI.XMovieClip;
	
	/**
	 * 一个弹出窗口
	 * ClickMaskClose:true,
	 * CloseButton:true,
	 * ClouseButtonClass:'CloseBt',
	 * ClouseButtonName:'',
	 * closeButtonOffX:60,
	 * closeButtonOffY:19,
	 * maskAlpha:.6,
	 * OffsetY:0,
	 * ease:null,
	 * noDispose:false
	 * @author KoaQiu
	 */
	public class LBWin extends XMovieClip {
		public var btnClose:SimpleButton;
		private var _isShow:Boolean = false;

		/**
		 * 是否已经显示
		 * @return 
		 * 
		 */
		public function get IsShow():Boolean{
			return _isShow;
		}
		public var IsAni:Boolean = false;

		public var _args:Object;
		internal var _mask:Sprite;
		public var canClose:Boolean = true;
		private var _id:int;
		public function get ID():int{
			return this._id;
		}
		/**
		 * ClickMaskClose:true,
		 * CloseButton:true,
		 * ClouseButtonClass:'CloseBt',
		 * ClouseButtonName:'',
		 * closeButtonOffX:60,
		 * closeButtonOffY:19,
		 * maskAlpha:.6,
		 * OffsetY:0,
		 * ease:null,
		 * noDispose:false
		 */
		public function LBWin() {
			super();
			_args = LightBoxManager.InitArgs();
			this._id = LightBoxManager.NewID();
			stop();
			this.addEventListener(KeyboardEvent.KEY_UP, DPE_KeyUp);
		}
		protected function CreateChildren():void {
		}
		override public function dispose():void{
			while(super.numChildren > 0){
				var disp:DisplayObject = super.removeChildAt(0); 
				if(disp is IDispose){
					(disp as IDispose).dispose();
				}
			}
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
		/**
		 * 显示窗口（静态）
		 * @param	stage
		 * @param	args
		 */
		public function Show(stage:Stage, args:Object = null):void {
			this.alpha = 1;
			this.visible = true;
			this.scaleX = this.scaleY = 1;
			if (args) {
				for (var k:Object in args) {
					this._args[k] = args[k];
				}
			}
			if (glo.IsNullOrUndefined(this._args.goto)==false) {
				gotoAndStop(this._args.goto);
			}
			
			this.CreateChildren();
			this.onBeforeShow();
			stage.addChild(this);
			if (this._args.CloseButton) {
				if (StringHelper.IsNullOrEmpty(this._args.ClouseButtonName)) {
					this.btnClose = new (getDefinitionByName(this._args.ClouseButtonClass) as Class);
					this.addChild(btnClose);
				}else {
					this.btnClose = this.getChildByName(this._args.ClouseButtonName) as SimpleButton;
				}
				this.btnClose.alpha = .01;
				this.btnClose.y = this._args.closeButtonOffY;
			}else if (StringHelper.IsNullOrEmpty(this._args.ClouseButtonName) == false) {
				this.getChildByName(this._args.ClouseButtonName).visible = false;
			}
			LightBoxManager.ShowWin(this);
		}
		/**
		 * 隐藏当前窗口
		 * @see com.CGFinal.Utilities.LightBoxManager#Hide()
		 */
		public function Hide():void {
			LightBoxManager.Hide(this);
		}
		
		protected function doShow():void { }
		protected function doHide():void { }
		protected function doBeforeShow():void {}
		internal function onBeforeShow():void {
			this.doBeforeShow();
		}
		internal function onShow():void {
			this._isShow = true;
			trace(this,'onshow');
			this.doShow();
			this.dispatchEvent(new Event("onShow"));
			if(this.stage != null){
				this.stage.focus = this;
			}
		}
		
		internal function onHide():void {
			this._isShow = false;
			this.doHide();
			this.dispatchEvent(new Event("onHide"));
			this.removeEventListener(KeyboardEvent.KEY_UP, DPE_KeyUp);
		}
		
		//Events
		private function DPE_KeyUp(e:KeyboardEvent):void {
			if (e.keyCode == 27) {
				LightBoxManager.Hide();
			}
		}
	}
	
}
