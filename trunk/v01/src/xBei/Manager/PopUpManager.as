package xBei.Manager
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
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
		 * 
		 */
		public static function Show(disp:DisplayObject, location:Point = null, target:DisplayObject = null, onHide:Function = null):PopUpManager {
			if(disp == null){
				throw new Error('xBei.Manager.PopUpManager.Show() 参数错误！必须是DisplayObject');
				return;
			}else if(_stage == null && disp.stage == null){
				throw new Error('xBei.Manager.PopUpManager.Show() 严重错误！Stage 未初始化');
				return;
			}else if(disp.stage != null){
				_stage = disp.stage;
			}
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
				location : new Point(disp.x,disp.y)
			};
			this._disp = disp;
			trace('PopUpManager.Create',this._disp is IPopupObject);
			this._show(location, target,onHide);
			_stage.addEventListener(MouseEvent.MOUSE_UP, this.DPE_ClickOnStage);
		}
		private function _show(location:Point = null, target:DisplayObject = null, onHide:Function = null):void{
			_target = target;
			_cb_OnHide = onHide;
			trace('PopUpManager.Show',this._disp is IPopupObject);
			
			var useLoc:Point;
			if(location == null){
				//未指定显示位置
				if(_oldParent.parent == null || _disp.stage == null){
					//显示对象不在显示列表中
					useLoc = new Point(_stage.stageWidth / 2,_stage.stageHeight / 2);
				}else{
					useLoc = _disp.parent.localToGlobal(_oldParent.location);
				}
			}else{
				useLoc = location;
			}
			
			//边界检查，调整位置
			if(useLoc.x + this._disp.width >= _stage.stageWidth){
				useLoc.x = _stage.stageWidth - this._disp.width -2;
			}else if(useLoc.x < 0){
				useLoc.x = 0;
			}
			if(useLoc.y + this._disp.height >= _stage.stageHeight){
				useLoc.y = _stage.stageHeight - this._disp.height -2;
			}else if(useLoc.x < 0){
				useLoc.y = 0;
			}
			_disp.x = useLoc.x;
			_disp.y = useLoc.y;
			_stage.addChild(_disp);
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