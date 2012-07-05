package xBei.UI {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import gs.*;
	
	import xBei.AnimationMode;
	import xBei.Events.*;
	import xBei.Helper.StringHelper;
	import xBei.Interface.*;
	import xBei.Manager.*;
	import xBei.Net.Uri;

	/**
	 * Enter
	 * @eventType xBei.Events.DragDropEvent.DRAG_ENTER
	 */
	[Event(name = "dragEnter", type = "xBei.Events.DragDropEvent")]
	[Event(name = "dragOver", type = "xBei.Events.DragDropEvent")]
	[Event(name = "dragLeave", type = "xBei.Events.DragDropEvent")]
	[Event(name = "dragDrop", type = "xBei.Events.DragDropEvent")]
	/**
	 * 从Sprite扩展，添加了些实用的方法和属性
	 * @author KoaQiu
	 * @see xBei.Interface.IChildSprite
	 * @see xBei.Interface.IDispose
	 * @see xBei.Interface.IEnabled
	 */
	public  class XSprite extends Sprite implements IChildSprite, IDispose, IEnabled {
		private var _depth:int = -1;
		private var _enable:Boolean = true;
		
		public var Tag:Object;
		/**
		 * @private
		 */
		protected var callLaterMethods:Dictionary;
		public static var inCallLaterPhase:Boolean=false;
		
		/**
		 * 自动Alpha值（0~1），值大于0时自动设置visible = true，否则设置visible = false
		 * @return 
		 */
		public function get AutoAlpha():Number{
			if(this.alpha == 0 && this.visible){
				this.visible = false;
			}else if(this.alpha > 0 && this.visible == false){
				this.visible = true;
			}
			return this.alpha;
		}
		public function set AutoAlpha(v:Number):void{
			this.visible = v > 0;
			this.alpha = v;
		}
		override public function set useHandCursor(value:Boolean):void{
			super.useHandCursor = value;
			if(value){
				this.buttonMode = true;
			}
		}
		/**
		 * 返回该对象在显示层级中的引索，如果不在显示队列则返回 -1。0 表示对象在最底层
		 * @return 
		 * @see #VDepth()
		 */
		public function get Depth():int{
			if(this.parent == null){
				return -1;
			}else{
				return this.parent.getChildIndex(this);
			}
		}
		/**
		 * 同时设置scaleX、scaleY为同一个值，即按原比例同比缩放，如果原来比例不同将会覆盖
		 * @param v
		 */		
		public function set Scale(v:Number):void{
			this.scaleX = this.scaleY = v;
		}
		
		/**
		 * 是否可用
		 */
		public function get Enabled():Boolean {
			return this._enable;
		}
		/**
		 * 会覆盖子对象状态，如果有
		 * @param v
		 */		
		public function set Enabled(v:Boolean):void {
			//if(this._enable != v){
				this._enable = v;
				var l:int = super.numChildren;
				for(var i:int = 0;i < l; i++){
					var disp:DisplayObject = super.getChildAt(i); 
					if(disp is IEnabled){
						(disp as IEnabled).Enabled = v;
					}else if(disp.hasOwnProperty('enable')){
						try{disp['enable'] = v}
						catch(e:Error){}
					}
				}
			//}
		}
		/**
		 * 级层深度（模拟AS2）
		 * @see xBei.Interface.IChildSprite
		 * @see xBei.Manager.DepthManger
		 */
		public function get VDepth():int {
			return this._depth;
		}
		public function set VDepth(v:int):void {
			this._depth = v;
		}
		
		public function get Url():Uri{
			return new Uri(this.loaderInfo.loaderURL);
		}
		/**
		 * @inheritDoc
		 */
		public function XSprite() {
			this.callLaterMethods = new Dictionary();
			this.callLater(this._initDrag);
			this.createChildren();
			this.draw();
			this.DataBind();
		}

		/**
		 * @inheritDoc
		 */
		override public function dispatchEvent(event:Event):Boolean {
			if(this.Enabled){
				return super.dispatchEvent(event);
			}else {
				return false;
			}
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void {
			this.callLaterMethods = null;
			if (this.CanDrag) {
				this.removeEventListener(MouseEvent.MOUSE_DOWN, DPE_itemMouseDown);
			}
			if (this.AllowDrop) {
				//接收拖曳事件
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, DPE_ADMouseMove);
			}
			this.RemoveAllChildren();
			if(this.parent != null){
				this.parent.removeChild(this);
			}
		}
		/**
		 * 添加并设置属性
		 * @param child
		 * @param initData
		 * @return 
		 */		
		public function AddChild(child:DisplayObject, initData:Object = null):DisplayObject{
			if(child == null)throw new ArgumentError('child不能为空（null）');
			this.addChild(child);
			for(var k:* in initData){
				if(initData[k] is Function){
					initData[k](child);
				}else if(child.hasOwnProperty(k)){
					child[k] = initData[k];
				}
			}
			return child;
		}
		/**
		 * 将子项添加到target的前面
		 * @param child
		 * @param target
		 * @return 
		 */
		public function AddChildAfter(child:DisplayObject, target:DisplayObject):DisplayObject{
			if(child == null)throw new ArgumentError('child不能为空（null）');
			if(target == null)throw new ArgumentError('target不能为空（null）');
			else if(target.parent == null || target.parent != this)throw new ArgumentError('target错误');
			var index:int = this.getChildIndex(target) + 1;
			if(index >= this.numChildren){
				this.addChild(child);
			}else{
				this.addChildAt(child, index);
			}
			return child;
		}
		public function GetChildByName(pName:String, ...args):DisplayObject{
			if(args.length == 0){
				return super.getChildByName(pName);
			}else{
				return super.getChildByName(StringHelper.Format(pName, args));
			}
		}
		
		/**
		 * 查找子项
		 * @param callBack	function(disp,index):Boolean;
		 * @param thisObject
		 * @param	返回找到的子项，未找到返回null
		 */
		public function FindChildren(callBack:Function,thisObject:* = null):DisplayObject{
			if(thisObject == null){
				thisObject = this;
			}
			for(var i2:int = 0;i2 < this.numChildren;i2++){
				var item:DisplayObject = this.getChildAt(i2);
				if(callBack.call(thisObject,item,i2)){
					return item
				}
			}
			return null;
		}
		/**
		 * 返回经过过滤的子项
		 * @param callBack		为空时返回所有对象，并且忽略thisObject 
		 * function(disp,index):Boolean;
		 * @param thisObject
		 */
		public function FilterChildren(callBack:Function = null,thisObject:* = null):Vector.<DisplayObject>{
			var list:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			if(thisObject == null){
				thisObject = this;
			}
			for(var i2:int = 0;i2 < this.numChildren;i2++){
				var item:DisplayObject = this.getChildAt(i2);
				if(callBack == null || callBack.call(thisObject,item,i2)){
					list.push(item);
				}
			}
			return list;
		}
		/**
		 * 遍历所有子项
		 * @param callBack	function(item,index):void;
		 * @param thisObject
		 * 
		 */
		public function ForeachChildren(callBack:Function,thisObject:* = null):void{
			if(thisObject == null){
				thisObject = this;
			}
			for(var i2:int = 0;i2 < this.numChildren;i2++){
				var item:DisplayObject = this.getChildAt(i2);
				callBack.call(thisObject, item, i2);
			}
		}
		/**
		 * 隐藏 
		 * @param aniMode	动画模式，默认值：0 直接隐藏，1-渐显，2-闪白
		 * @param duration	动画时间（毫秒）
		 * @param callBack	function(disp:DisplayObject):void;
		 * @param thisObject
		 * @see xBei.AnimationMode
		 */
		public function HideMe(aniMode:int = 0, duration:int = 300, callBack:Function = null, 
							   thisObject:* = null):XSprite{
			if(thisObject == null){
				thisObject = this;
			}
			XSprite.HideItByAni(this, aniMode, duration, callBack, thisObject);
			return this;
		}
		/**
		 * 显示
		 * @param aniMode	动画模式，默认值：0 直接显示，1-渐显，2-闪白
		 * @param duration	动画时间（毫秒）
		 * @param callBack	function(disp:DisplayObject):void;
		 * @param thisObject
		 * @see xBei.AnimationMode
		 */
		public function ShowMe(aniMode:int = 0, duration:int = 300, callBack:Function = null, 
							   thisObject:* = null):XSprite{
			if(thisObject == null){
				thisObject = this;
			}
			XSprite.ShowItByAni(this, aniMode, duration, callBack, thisObject);
			return this;
		}
		/**
		 * 移除所有子项，调用内建的removeChild移除子项，并调用callBack，自动调用dispose()
		 * @param callBack	function(disp:DisplayObject):void{}
		 * @param thisObject
		 */
		public function RemoveAllChildren(callBack:Function = null,thisObject:* = null):void{
			if(thisObject == null){
				thisObject = this;
			}
			while(this.numChildren > 0){
				var item:DisplayObject = this.removeChildAt(0);
				if(callBack != null)
					callBack.call(thisObject, item);
				glo.DisposeDisplayObject(item);
			}
		}
		
		/* *************************
		* 拖曳支持
		* ************************* */
		private var _allowDrop:Boolean = false;
		private var _canDrag:Boolean = false;
		private var _dragOver:Boolean = false;
		private var _isDroping:Boolean = false;
		private var _isInitDrag:Boolean = false;
		
		/**
		 * 是否接受拖放
		 */
		public function get AllowDrop():Boolean {
			return this._allowDrop;
		}
		public function set AllowDrop(v:Boolean):void {
			if (this._allowDrop == v) return;
			this._allowDrop = v;
			if (this._isInitDrag) {
				
			}
		}
		
		/**
		 * 是否可以拖曳
		 */
		public function get CanDrag():Boolean {
			return this._canDrag;
		}
		public function set CanDrag(v:Boolean):void {
			if (this._canDrag == v) return;
			this._canDrag = v;
			if (this._isInitDrag) {
				if (v) {
					this.addEventListener(MouseEvent.MOUSE_DOWN, DPE_itemMouseDown);
				}else {
					this.removeEventListener(MouseEvent.MOUSE_DOWN, DPE_itemMouseDown);
				}
			}
		}
		
		/**
		 * 是否拖曳 
		 * @return 
		 */
		public function get IsDragOver():Boolean {
			return _dragOver;
		}
		private function _initDrag():void {
			if (this._isInitDrag) return;
			this._isInitDrag = true;
			if (this.CanDrag) {
				this.addEventListener(MouseEvent.MOUSE_DOWN, DPE_itemMouseDown);
			}
			if (this.AllowDrop) {
				//接收拖曳事件
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, DPE_ADMouseMove);
			}
		}
		private function DPE_ADMouseMove(e:MouseEvent):void {
			if (e.buttonDown) {
				if (this.hitTestPoint(e.stageX, e.stageY, true)){
					if(this._dragOver==false){
						this.OnDragOver();
					}
				}else if (this._dragOver) {
					this.OnDragLeave();
				}
			}
		}
		private function DPE_itemMouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, DPE_DDMouseMove);
		}
		private function DPE_DDMouseMove(e:MouseEvent):void {
			if (e.buttonDown && stage!=null) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, DPE_DDMouseMove);
				DragManager.BeginDragIt(this);
			}
		}
		/**
		 * 拖曳进行时
		 */
		protected function OnDragOver():void {
			this._dragOver = true;
			DragManager.DropItemAction = this.OnDragDrop;
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OVER, DragManager.DragingItem));
		}
		/**
		 * 拖曳（离开）
		 */		
		protected function OnDragLeave():void {
			this._dragOver = false;
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_LEAVE, DragManager.DragingItem));
		}
		/**
		 * 拖曳完成
		 */		
		protected function OnDragEnter():void {
		}
		/**
		 * 拖曳完成
		 * @param obj
		 */		
		protected function OnDragDrop(obj:DragItem):void {
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_DROP, DragManager.DragingItem));
		}
		/* *************************
		* 拖曳支持结束
		* ************************* */
		
		//protected
		/**
		 * 创建并初始化子对象
		 */
		protected function createChildren():void {
		}
		
		/**
		 * 绘制UI
		 */
		protected function draw():void {
		}
		/**
		 * 数据绑定
		 */
		public function DataBind():void {
		}
		protected function callLater(fn:Function):void {
			if (XSprite.inCallLaterPhase) { return; }
			this.callLaterMethods[fn] = true;
			if (stage != null) {
				stage.addEventListener(Event.RENDER,DPE_callLaterDispatcher,false,0,true);
				stage.invalidate();				
			} else {
				addEventListener(Event.ADDED_TO_STAGE,DPE_callLaterDispatcher,false,0,true);
			}
		}
		private function DPE_callLaterDispatcher(event:Event):void {
			if (event.type == Event.ADDED_TO_STAGE) {
				removeEventListener(Event.ADDED_TO_STAGE,DPE_callLaterDispatcher);
				// now we can listen for render event:
				stage.addEventListener(Event.RENDER,DPE_callLaterDispatcher,false,0,true);
				stage.invalidate();
				return;
			} else {
				event.target.removeEventListener(Event.RENDER,DPE_callLaterDispatcher);
				if (stage == null) {
					// received render, but the stage is not available, so we will listen for addedToStage again:
					addEventListener(Event.ADDED_TO_STAGE,DPE_callLaterDispatcher,false,0,true);
					return;
				}
			}
			
			XSprite.inCallLaterPhase = true;
			
			var methods:Dictionary = this.callLaterMethods;
			for (var method:Object in methods) {
				//trace('CALL LATER',method.toString());
				if(method is Function){
					(method as Function).call(this);
				}
				delete(methods[method]);
			}
			XSprite.inCallLaterPhase = false;
		}
		/**
		 * 延迟执行
		 * 每0.1秒检查条件（check）
		 * @param	check		function(args...):Boolean;返回true时执行action
		 * @param	action		function(args...):void;
		 * @param	checkArgs	传送个check的参数
		 * @param	actionArgs	传送给action的参数
		 */
		protected function runLater(check:Function, action:Function, checkArgs:Array =  null, 
									actionArgs:Array = null):void {
			function timer(e:TimerEvent):void {
				var t:Timer = e.target as Timer;
				if (check.apply(null, checkArgs)) {
					t.removeEventListener(TimerEvent.TIMER, arguments.callee);
					action.apply(null, actionArgs);
				}else{
					t.reset();
					t.start();
				}
			}
			var time:Timer = new Timer(30, 1);
			time.addEventListener(TimerEvent.TIMER, timer);
			time.start();
		}
		/**
		 * 检查鼠标点击位置 
		 * @param me	MouseEvent
		 * @return Boolean	在目标内返回 true
		 * @see flash.events.MouseEvent
		 */
		protected function isMouseDownInMe(me:MouseEvent):Boolean{
			if(me.target == this){
				return true;
			}else if(me.target.parent == this){
				return true;
			}
			var p:DisplayObjectContainer = me.target.parent as DisplayObjectContainer;
			while(p != null){
				if(p == this){
					return true;
				}
				p = p.parent;
			}
			return false;
		}
		public static function Setup():void{
			Sprite.prototype.GetFullPath = function():String{
				return getFullPath(this);
			}
		}
		public static function getFullPath(disp:DisplayObject):String{
			if(disp == null){
				return 'null';
			}else if(disp is Stage){
				return 'STAGE';
			}else if(disp.parent == null){
				return disp.name;
			}else{
				return StringHelper.Format('{0}.{1}', getFullPath(disp.parent), disp.name);
			}
		}
		//静态方法
		/**
		 * 修改对象的颜色 
		 * @param disp
		 * @param color
		 */
		public static function ChangeColor(disp:DisplayObject, color:int):void{
			if(color == -1){
				disp.transform.colorTransform = new ColorTransform();
			}else{
				var ct:ColorTransform = disp.transform.colorTransform;
				ct.color = color;
				disp.transform.colorTransform = ct;
			}
		}
		/**
		 * 隐藏
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接隐藏，1-渐显，2-闪白
		 * @param duration	动画时间（秒）
		 * @param callBack	function(disp):void;
		 * @param thisObject
		 * @return 
		 * @see xBei.AnimationMode
		 */
		public static function HideItByAni(disp:DisplayObject,aniMode:int = 0, duration:Number = .3, 
										   callBack:Function = null, thisObject:* = null):DisplayObject{
			TweenLite.killTweensOf(disp);
			if(duration > 10){
				duration /= 1000;
			}
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = false;
				if(disp.alpha == 1){
					disp.alpha = 0;
				}
				if(callBack != null){
					callBack.call(thisObject, disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_OUT:
						TweenLite.to(disp, duration, {
							autoAlpha:0,
							onComplete:function():void{
								if(callBack != null){
									callBack.call(thisObject, disp);
								}
							}
						});
						break;
				}
			}
			return disp;
		}
		/**
		 * 显示
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接显示，1-渐显，2-闪白
		 * @param duration	动画时间（秒）
		 * @param callBack	function(disp):void;
		 * @param thisObject
		 * @retrun
		 * @see xBei.AnimationMode
		 */
		public static function ShowItByAni(disp:DisplayObject, aniMode:int = 0, duration:Number = .3, 
										   callBack:Function = null, thisObject:* = null):DisplayObject{
			if(duration > 10){
				duration /= 1000;
			}
			TweenLite.killTweensOf(disp);
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = true;
				if(disp.alpha == 0){
					disp.alpha = 1;
				}
				if(callBack != null){
					callBack.call(thisObject, disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_IN:
						TweenLite.to(disp, duration,{
							autoAlpha:1,
							onCompleteParams:[disp],
							onComplete:function(vd:DisplayObject):void{
								if(callBack != null){
									callBack.call(thisObject, vd);
								}
							}
						});
						break;
					case AnimationMode.FLASH_WHITE:
						TweenLite.to(disp, duration,{ 
							autoAlpha : 1,
							tint:0xffffff,
							onCompleteParams:[disp],
							onComplete:function(v:DisplayObject):void{
								TweenLite.to(v,.2,{tint:null});
								if(callBack != null){
									callBack.call(thisObject, v);
								}
							}
						});
						break;
				}
			}
			return disp;
		}//end function
		public static function GetSafeBounds(target:DisplayObject, targetCoordinateSpace:DisplayObject):Rectangle {
			if(target == null){
				throw new ArgumentError('target 不能为空（null）');
			}else if(targetCoordinateSpace == null){
				throw new ArgumentError('targetCoordinateSpace 不能为空（null）');
			}
			if(target.width == 0 || target.height == 0)
				return new Rectangle();
			
			return target.getBounds(targetCoordinateSpace);
		}
	}
}