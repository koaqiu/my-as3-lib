package com.CGFinal.Utilities {
	import com.CGFinal.Interface.IPopUpPanel;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	/**
	 * 弹出对象管理类
	 * @author KoaQiu
	 */
	public class PopUpManager {
		
		private var _stage:Stage;
		private var _dis:DisplayObject;
		private var _target:DisplayObject;
		private var _oldParent:Object;
		private var _onHide:Function;
		private static var _ppm:PopUpManager;
		public function dispose():void{
			_dis = null;
			_target = null;
			_oldParent = null;
			if(_stage != null){
				_stage.removeEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
			}
			_stage = null;
		}
		public static function Show(dis:DisplayObject, target:DisplayObject, onHide:Function = null):PopUpManager {
			//if(_ppm != null){
			//	_ppm.dispose();
			//} 
			_ppm = new PopUpManager();
			_ppm._show(dis, target, onHide);
			return _ppm;
		}
		public static function ChangeTarget(target:DisplayObject):void{
			if(PopUpManager._ppm != null){
				PopUpManager._ppm._target = target;
			}
		}
		public static function Hide():void {
			if(PopUpManager._ppm != null){
				try{
				PopUpManager._ppm._hide();
				}catch(err:Error){
					trace('PopUpManager.Hide() ',err);
				}
			}
		}
		private function _hide():void {
			this._stage.removeEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
			//this._dis.visible = false;
			trace('hide',_dis,_oldParent.loc);
			TweenLite.to(this._dis,.1,{ 
				autoAlpha:0,
				onComplete:function():void{
					//trace('xxx',_dis,_oldParent,_oldParent.loc);
					if(_oldParent !=null && _oldParent.loc != null){
						_dis.x = _oldParent.loc.x;
						_dis.y = _oldParent.loc.y;
					}
				}
			});
			var ppp:IPopUpPanel = this._dis as IPopUpPanel;
			if (ppp != null) {
				ppp.IsShow = false;
			}
			if (this._oldParent != null && this._oldParent.p != null) {
				try{
					this._oldParent.p.addChildAt(this._dis, this._oldParent.depth);
				}catch(error:Error){trace('HIDE:',error.message);}
			}
			if (this._onHide != null) {
				this._onHide();
			}
		}
		private function _show(dis:DisplayObject, target:DisplayObject,onHide:Function = null):void {
			this._stage = dis.stage;
			if (this._stage == null) {
				throw new Error("Stage 未初始化");
			}
			this._dis = dis;
			this._target = target;
			var ppp:IPopUpPanel = this._dis as IPopUpPanel;
			if (ppp != null) {
				if (ppp.IsShow) {
					trace('已经显示');
					return;
				}
				ppp.IsShow = true;
			}
			this._onHide = onHide;
			this._oldParent = { p:null, depth: -1, loc:null };
			var gloc:Point;
			//如果目标有父则保存相关信息
			if (dis.parent != null && dis.parent != dis.stage) {
				this._oldParent = { p:dis.parent, depth:dis.parent.getChildIndex(dis),loc:null };
				if (this._oldParent.depth == this._stage.numChildren - 1) {
					trace('已经是最顶层了');
					TweenLite.to(this._dis,.3,{ autoAlpha:1 });
					return;
				}else{
					this._oldParent.loc = new Point(dis.x, dis.y);
					gloc = this._oldParent.p.localToGlobal(this._oldParent.loc);
				}
			}
			
			//添加到Stage最顶层
			this._stage.addChild(dis);
			
			if (ppp != null) {
				ppp.OnShow();
			}
			if(this._oldParent.p != null && this._oldParent.p != this._stage){
				//调整位置
				var sloc:Point = this._stage.globalToLocal(gloc);
				dis.x = sloc.x;
				dis.y = sloc.y;
			}
			TweenLite.to(this._dis,.3,{ autoAlpha:1 });
			this._stage.addEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
		}
		//Events
		private function DPE_ClickOnStage(e:MouseEvent):void {
			if (e.target == this._dis || e.target == this._target) {
				return;
			}else if (LightBoxManager.HasWinow) {
				return;
			}else {
				var p:DisplayObjectContainer = e.target.parent as DisplayObjectContainer;
				while (p != null && p != this._dis && p != this._target) {
					p = p.parent;
				}
				if (p != null) {
					return;
				}
			}
			//隐藏
			this._hide();
		}
	}
	
}
