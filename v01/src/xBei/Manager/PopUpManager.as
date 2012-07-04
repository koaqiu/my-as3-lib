package xBei.Manager
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import xBei.Debug.Logger;
	import xBei.Interface.IPopupObject;

	/**
	 * 弹出对象管理，同一时间只有一个弹出对象 
	 * @author KoaQiu
	 * @see xBei.Interface.IPopupObject
	 */
	public final class PopUpManager{
		private static var _popupObjectList:Vector.<PopUpManager> = new Vector.<PopUpManager>();
		private static var _stage:Stage;
		/**
		 * 将参数中的disp弹出显示 
		 * @param disp		要弹出的对象
		 * @param location	弹出位置
		 * @param target	调用此方法的对象
		 * @param onHide	回调函数，当弹出对象隐藏时调用
		 * @return 执行成功返回本管理器
		 */
		public static function Show(disp:DisplayObject, location:Point = null, target:DisplayObject = null, onHide:Function = null):PopUpManager {
			if((disp is DisplayObject) == false){
				throw new Error('xBei.Manager.PopUpManager.Show() 参数错误！必须是DisplayObject');
				return;
			}
			_stage = StageManager.Instance.Stage;
			var ppm:PopUpManager = _isPopup(disp); 
			if(ppm == null){
				ppm = new PopUpManager(disp, location, target, onHide);
				_popupObjectList.push(ppm);
			}else{
				ppm._show(location, target, onHide);
			}
			return ppm;
		}
		/**
		 * 显示并隐藏其他
		 * @param disp		要弹出的对象
		 * @param location	弹出位置
		 * @param target	调用此方法的对象
		 * @param onHide	回调函数，当弹出对象隐藏时调用
		 * @return 执行成功返回本管理器
		 */
		public static function ShowAndHideOther(disp:DisplayObject, location:Point = null, target:DisplayObject = null, onHide:Function = null):PopUpManager {
			var l:int = _popupObjectList.length;
			for(var i:int = 0;i < l;i++){
				if(_popupObjectList[i]._disp != disp){
					_popupObjectList[i]._hide(true);
					_popupObjectList.splice(i,1);
					i--;
					l--;
				}
			}
			return Show(disp,location,target,onHide);
		}
		/**
		 * 隐藏弹出对象 
		 * 
		 */
		public static function Hide(disp:DisplayObject = null):void{
			if(_popupObjectList.length > 0){
				if(disp == null){
					_popupObjectList.pop()._hide(true);
				}else{
					var l:int = _popupObjectList.length;
					for(var i:int = 0;i < l;i++){
						if(_popupObjectList[i]._disp == disp){
							 _popupObjectList[i]._hide(true);
							 _popupObjectList.splice(i,1);
							return;
						}
					}
					trace('列表中没有找到');
				}
			}
		}
		/**
		 * 隐藏所有 
		 * 
		 */
		public static function HideAll():void{
			while(_popupObjectList.length > 0){
				_popupObjectList.pop()._hide(true);
			}
		}
		
		private static function _isPopup(disp:DisplayObject):PopUpManager{
			var l:int = _popupObjectList.length;
			for(var i:int = 0;i < l;i++){
				if(_popupObjectList[i]._disp == disp){
					return _popupObjectList[i];
				}
			}
			return null;
		}
		private var _oldParent:Object;
		private var _disp:DisplayObject;
		private var _target:DisplayObject;
		private var _cb_OnHide:Function;
		private var _isTop:Boolean = false;
		
		function PopUpManager(disp:DisplayObject, location:Point = null, target:DisplayObject = null, onHide:Function = null){
			//保存原始信息
			_oldParent = {
				parent : disp.parent,
				depth : disp.parent == null ? -1 : disp.parent.getChildIndex(disp),
				location : new Point(disp.x, disp.y)
			};
			this._disp = disp;
			//trace('PopUpManager.Create',this._disp is IPopupObject);
			this._show(location, target,onHide);
			_stage.addEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
		}
		/**
		 * 显示
		 * @param location
		 * @param target
		 * @param onHide
		 * 历史：
		 * 2011-12-13 修正边界检查代码
		 */		
		private function _show(pLocationToShow:Point = null, target:DisplayObject = null, onHide:Function = null):void{
			_target = target;
			_cb_OnHide = onHide;
			
			var useLoc:Point;
			if(pLocationToShow == null){
				//未指定显示位置
				if(_oldParent.parent == null || _disp.stage == null){
					//显示对象不在显示列表中
					useLoc = new Point(this._disp.x, this._disp.y); //new Point(_stage.stageWidth / 2, _stage.stageHeight / 2);
				}else{
					useLoc = _disp.parent.localToGlobal(_oldParent.location);
				}
			}else{
				useLoc = pLocationToShow;
			}
			var bak_visible:Boolean = _disp.visible;
			_disp.visible = false;
			_stage.addChild(_disp);
			_disp.x = useLoc.x;
			_disp.y = useLoc.y;
			//边界检查，调整位置
			var rc:Rectangle = this._disp.getBounds(_stage);
			if(rc.right >= _stage.stageWidth){
				_disp.x = _stage.stageWidth - rc.width -2;
			}else if(rc.left < 0){
				_disp.x = 0;
			}
			//Logger.info('调整位置:',rc.top, rc.bottom, _stage.stageHeight, useLoc);
			if(rc.bottom >= _stage.stageHeight){
				//trace('调整位置', useLoc.y, this._disp.height, _disp.getBounds(_stage));
				_disp.y = _stage.stageHeight - rc.height -2;
			}else if(rc.top < 0){
				_disp.y = 0;
			}
			_disp.visible = bak_visible;
			
			var po:IPopupObject = _disp as IPopupObject;
			if(po != null){
				po.IsPopuped = true;
				po.OnShow();
			}
			_isTop = true;
		}
		private function _hide(isRemove:Boolean = false):void{
			if(_isTop == false)return;
			var po:IPopupObject = _disp as IPopupObject;
			if(po != null){
				po.IsPopuped = false;
				po.OnHide();
			}
			if(isRemove){
				_stage.removeEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
			}
			if(_cb_OnHide != null){
				_cb_OnHide();
			}
			if(_oldParent.parent == null){
				_stage.removeChild(_disp);
			}else{
				_oldParent.parent.addChildAt(_disp,_oldParent.depth);
			}
			_isTop = false;
			_disp.x = _oldParent.location.x;
			_disp.y = _oldParent.location.y;
			
		}
		
		//Events
		private function DPE_ClickOnStage(e:MouseEvent):void {
			if (e.target == this._disp || e.target == this._target) {
				return;
			//}else if (LightBoxManager.HasWinow) {
			//	return;
			}else {
				var p:DisplayObjectContainer = e.target.parent as DisplayObjectContainer;
				while (p != null && p != this._disp && p != this._target) {
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