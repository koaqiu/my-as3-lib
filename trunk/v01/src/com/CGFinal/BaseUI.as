package com.CGFinal {
	import com.CGFinal.DragAndDrop.DragItem;
	import com.CGFinal.Events.DragDropEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.text.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	import xBei.AnimationMode;
	import xBei.Helper.StringHelper;
	import xBei.Interface.*;
	import xBei.Manager.DragManager;
	import xBei.Net.RequestQueryString;
	import xBei.Net.Uri;

	
	/**
	 * 继承至 flash.display.Sprite ，扩展了一堆方法
	 * @author KoaQiu
	 */
	public class BaseUI extends Sprite implements IChildSprite,IDispose {
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var callLaterMethods:Dictionary;
        /**
         * @private (internal)
         * Indicates whether the current execution stack is within a call later phase.
         *
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static var inCallLaterPhase:Boolean=false;
		//dynamic
		private var _uri:xBei.Net.Uri
		public function get Uri():xBei.Net.Uri{
			if(_uri == null){
				parseQS();
			}
			return _uri;
		}
		
		/**
		 *  QueryString 参数
		 * @return 
		 * 
		 */
		public function get QueryString():RequestQueryString {
			if(_uri == null){
				parseQS();
			}
			return _uri.QueryString;
		}
		
		public function set Scale(v:Number):void{
			this.scaleX = this.scaleY = v;
		}
		
		private var _enable:Boolean = true;
		/**
		 * 是否可用
		 */
		public function get Enabled():Boolean {
			return _enable;
		}
		public function set Enabled(v:Boolean):void {
			if(_enable != v){
				_enable = v;
				var l:int = super.numChildren;
				for(var i:int =0;i<l;i++){
					var disp:DisplayObject = super.getChildAt(i); 
					if(disp is BaseUI){
						(disp as BaseUI).Enabled = v;
					}else{
						try{disp['enable'] = v}
						catch(e:Error){}
					}
				}
			}
		}
		/**
		 * 返回该对象在显示层级中的引索，如果不在显示队列则返回 -1。0 表示对象在最底层
		 * @return 
		 * 
		 */
		public function get Depth():int{
			if(this.parent == null){
				return -1;
			}else{
				return this.parent.getChildIndex(this);
			}
		}
		private var _depth:int;
		/**
		 * 深度
		 */
		public function get VDepth():int {
			return _depth;
		}
		public function set VDepth(v:int):void {
			_depth = v;
		}
		
		public function BaseUI() {
			super();
			this.callLaterMethods = new Dictionary();
			this.callLater(this.parseQS);
			this.callLater(this._initDrag);
			this.createChildren();
			this.draw();
			this.DataBind();
		}
		/**
		 * 销毁对象
		 */
		public function dispose():void {
			callLaterMethods = null;
			if(_uri != null){
				_uri.dispose();
			}
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
				trace('删除自己');
			}
		}
		override public function dispatchEvent(event:Event):Boolean {
			//trace("dispatchEvent",event.type,this.Enabled);
			if(this.Enabled){
				return super.dispatchEvent(event);
			}else {
				return false;
			}
		}
		
		/**
		 * 创建并初始化子对象
		 */
		protected function createChildren():void {
			//trace("this is the BaseUI createChildren");
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
		
		/**
		 * 返回经过过滤的子项
		 * @param callBack		为空时返回所有对象，并且忽略thisObject 
		 * function(disp,index):Boolean;
		 * @param thisObject
		 * 
		 */
		public function ChildrenFilter(callBack:Function = null,thisObject:* = null):Array{
			var list:Array = [];
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
				callBack.call(thisObject,item,i2);
			}
			
		}
		/**
		 * 移除所有子项，调用内建的removeChild移除子项，并调用callBack，自动调用dispose()
		 * @param callBack	function(disp:DisplayObject):void{}
		 * @param thisObject
		 * 
		 */
		public function RemoveAllChildren(callBack:Function = null,thisObject:* = null):void{
			if(thisObject == null){
				thisObject = this;
			}
			while(this.numChildren > 0){
				var item:DisplayObject = this.removeChildAt(0);
				if(callBack != null)
					callBack.call(thisObject,item);
				if(item is IDispose){
					(item as IDispose).dispose();
				}else{
					try{
						item['dispose']();
					}catch(err:Error){}
				}
			}
		}
		/**
		 * 隐藏 
		 * @param aniMode	动画模式，默认值：0 直接隐藏，1-渐显，2-闪白
		 * @see xBei.AnimationMode
		 */
		public function HideMe(aniMode:int = 0):void{
			BaseUI.HideItByAni(this,aniMode);
		}
		/**
		 * 隐藏
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接隐藏，1-渐显，2-闪白
		 * @return 
		 * @see xBei.AnimationMode
		 */
		public static function HideItByAni(disp:DisplayObject,aniMode:int = 0, callBack:Function = null):void{
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = false;
				if(disp.alpha == 1){
					disp.alpha = 0;
				}
				if(callBack != null){
					callBack(disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_OUT:
						TweenLite.to(disp,.3,{
							autoAlpha:0,
							onComplete:function():void{
								if(callBack != null){
									callBack(disp);
								}
							}
						});
						break;
				}
			}
		}
		/**
		 * 显示
		 * @param aniMode	动画模式，默认值：0 直接显示，1-渐显，2-闪白
		 * @see xBei.AnimationMode
		 */
		public function ShowMe(aniMode:int = 0):void{
			BaseUI.ShowItByAni(this,aniMode);
		}
		/**
		 * 显示
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接显示，1-渐显，2-闪白
		 * @param callBack	function(disp):void;
		 * @see xBei.AnimationMode
		 */
		public static function ShowItByAni(disp:DisplayObject,aniMode:int = 0, callBack:Function = null):void{
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = true;
				if(disp.alpha == 0){
					disp.alpha = 1;
				}
				if(callBack != null){
					callBack(disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_IN:
						TweenLite.to(disp,.3,{
							autoAlpha:1,
							onCompleteParams:[disp],
							onComplete:function(vd:DisplayObject):void{
								if(callBack != null){
									callBack(vd);
								}
							}
						});
						break;
					case AnimationMode.FLASH_WHITE:
						TweenLite.to(disp,.3,{ 
							autoAlpha : 1,
							tint:0xffffff,
							onCompleteParams:[disp],
							onComplete:function(v:DisplayObject):void{
								TweenLite.to(v,.2,{tint:null});
								if(callBack != null){
									callBack(v);
								}
							}
						});
						break;
				}
			}
		}
		
		/**
		 * 修改对象的颜色 
		 * @param disp
		 * @param color
		 * 
		 */
		public static function ChangeColor(disp:DisplayObject,color:uint):void{
			var ct:ColorTransform = disp.transform.colorTransform;
			ct.color = color;
			disp.transform.colorTransform = ct;
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
		/* *************************
		 * 拖曳支持
		 * ************************* */
		private var _isDroping:Boolean = false;
		private var _isInitDrag:Boolean = false;
		private var _allowDrop:Boolean = false;
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
		private var _canDrag:Boolean = false;
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
		
		private var _dragOver:Boolean = false;
		/**
		 * 是否拖曳 
		 * @return 
		 * 
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
				//if (this.hitTestObject(DragManager.DragingItem)) {
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
		protected function OnDragOver():void {
			this._dragOver = true;
			DragManager.DropItemAction = this.OnDragDrop;
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OVER, DragManager.DragingItem));
			//trace(this.name,DragDropEvent.DRAG_OVER);
		}
		protected function OnDragLeave():void {
			this._dragOver = false;
			//DragManager.DropItemAction = null;
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_LEAVE, DragManager.DragingItem));
			//trace(this.name,DragDropEvent.DRAG_LEAVE);
		}
		protected function OnDragEnter():void {
			//trace(DragDropEvent.DRAG_ENTER);
		}
		protected function OnDragDrop(obj:DragItem):void {
			this.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_DROP, DragManager.DragingItem));
			//trace(DragDropEvent.DRAG_DROP, obj);
		}
		/* *************************
		 * 拖曳支持结束
		 * ************************* */
		protected function BindToolTip(owner:InteractiveObject, text: String):void {
			//ToolTip.Bind(owner, text);
		}
		protected function RemoveToolTip(owner:InteractiveObject):void {
			//ToolTip.Remove(owner);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function callLater(fn:Function):void {
			if (inCallLaterPhase) { return; }
			callLaterMethods[fn] = true;
			if (stage != null) {
				stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
				stage.invalidate();				
			} else {
				addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
			}
		}
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function callLaterDispatcher(event:Event):void {
			if (event.type == Event.ADDED_TO_STAGE) {
				removeEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher);
				// now we can listen for render event:
				stage.addEventListener(Event.RENDER,callLaterDispatcher,false,0,true);
				stage.invalidate();
				return;
			} else {
				event.target.removeEventListener(Event.RENDER,callLaterDispatcher);
				if (stage == null) {
					// received render, but the stage is not available, so we will listen for addedToStage again:
					addEventListener(Event.ADDED_TO_STAGE,callLaterDispatcher,false,0,true);
					return;
				}
			}

			inCallLaterPhase = true;
			
			var methods:Dictionary = callLaterMethods;
			for (var method:Object in methods) {
				//trace('CALL LATER',method.toString());
				method();
				delete(methods[method]);
			}
			inCallLaterPhase = false;
		}
		//****************************
		//* QueryString相关操作
		//****************************
		
		protected function parseQS():void {
			//trace('DO parseQS');
			if(root != null){
				_uri = new xBei.Net.Uri(root.loaderInfo.url);
			}
		}
		/**
		 * 读取FlashVars
		 * @param	key		变量名称
		 * @param	dv		默认值
		 * @return
		 */
		protected function GetAppParam(key:String, dv:String = ""):String {
			if (root.loaderInfo.parameters[key] && String(root.loaderInfo.parameters[key]).length > 0) {
				return String(root.loaderInfo.parameters[key]);
			}else {
				return dv;
			}
		}
		/**
		 * 从FlashVars读取int
		 * @param	key		变量名称
		 * @param	dv		默认值
		 * @return
		 */
		protected function GetIntAppParam(key:String, dv:int = 0):int {
			var value:String = this.GetAppParam(key, "==");
			if (value == "==") {
				return dv;
			}
			try {
				return int(value);
			}catch (err:Error) {
			}
			return dv;
		}
		/**
		 * 从FlashVars读取Number
		 * @param	key		变量名称
		 * @param	dv		默认值
		 * @return
		 */
		protected function GetNumberAppParam(key:String, dv:Number = 0.0):Number {
			var value:String = this.GetAppParam(key, "==");
			if (value == "==") {
				return dv;
			}
			try {
				return Number(value);
			}catch (err:Error) {
			}
			return dv;
		}
		/**
		 * 从FlashVars读取Boolean
		 * @param	key		变量名称
		 * @param	dv		默认值
		 * @return
		 */
		protected function GetBooleanAppParam(key:String, dv:Boolean = false):Boolean {
			var value:String = this.GetAppParam(key, "==").toLowerCase();
			if (value == "==") {
				return dv;
			}
			if (value == "0" ||	value == "false" ||	value == "null" || value == "undefined") {
				return false;
			}else {
				return true;
			}
		}
		/**
		 * 创建一个标签（Label）
		 * @param	text
		 * @return
		 */
		protected function createLabel(text:String):TextField {
			var lab:TextField = new TextField();
			lab.selectable = false;
			lab.autoSize = "left";
			lab.text = text;
			return lab;
		}
		/**
		 * 延迟执行
		 * 每0.1秒检查条件（check）
		 * @param	check		返回true时执行action
		 * @param	action
		 */
		protected function LaterRun(check:Function, action:Function):void {
			//var me:BaseUI = this;
			function timer(e:TimerEvent):void {
				if (check()) {
					var t:Timer = e.target as Timer;
					t.stop();
					t.removeEventListener(TimerEvent.TIMER, arguments.callee);
					action();
				}
			}
			var time:Timer = new Timer(30);
			time.addEventListener(TimerEvent.TIMER, timer);
			time.start();
		}
		/**
		 * 是否正在拖动
		 */ 
		protected var isDraging:Boolean = false;
		private var _rect:Object = { };
		/**
		 * 拖动对象
		 * @param	target
		 * @param	rect
		 * @param	onStartDrag	
		 * @param	onEndDrag	
		 * @param	onMove		拖动时触发
		 */
		protected function MakeItCanDrag(target:Sprite, 
				rect:Rectangle = null, 
				onStartDrag:Function = null,
				onEndDrag:Function = null, 
				onMove:Function = null,
				canDrag:Function = null):void {
				
			_rect[target.name] = rect;
			function _makeItCanDragMouseUp(me:MouseEvent):void {
				isDraging = false;
				if (onMove!=null) {
					target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				}
				target.stage.removeEventListener(MouseEvent.MOUSE_UP, _makeItCanDragMouseUp);
				target.stopDrag();
				if (onEndDrag!=null) {
					onEndDrag(target);
				}
			}
			function _makeItCanDragMouseDown(me:MouseEvent):void {
				//var tg:Sprite = me.target as Sprite;
				//if (tg == null) return;
				if (canDrag != null && canDrag() == false) {
					return;
				}
				//trace(target.name);
				target.startDrag(false, _rect[target.name]);
				target.stage.addEventListener(MouseEvent.MOUSE_UP, _makeItCanDragMouseUp);
				isDraging = true;
				if (onStartDrag != null) {
					onStartDrag(target);
				}
				if (onMove!=null) {
					target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				}
			}
			target.addEventListener(MouseEvent.MOUSE_DOWN, _makeItCanDragMouseDown);
		}
		/**
		 * 修改拖动区域 
		 * @param target
		 * @param rect
		 * @see #MakeItCanDrag()
		 */
		protected function ChangeDragRect(target:Sprite, rect:Rectangle):void {
			_rect[target.name] = rect;
		}
		/**
		 * 根据类名创建对象 
		 * @param className
		 * @return 
		 * 
		 */
		protected function createObject(className:String):Object {
			return new (getDefinitionByName(className) as Class)();
		}
		/**
		 * 播放音乐 
		 * @param soundName 库中导出的声音类名
		 * @param volume	音量，(0~1)默认是：1
		 * @return 成功播放返回true
		 * 
		 */
		protected function playSound(soundName:String, volume:Number = 1):Boolean {
			if (StringHelper.IsNullOrEmpty(soundName)) return false;
			try{
				var sound:Sound = new( getDefinitionByName(soundName) as Class);
				var st:SoundTransform = new SoundTransform ();
				st.volume = volume;
				sound.play(0,0,st);
			}catch (err:Error) {
				return false;
			}
			return true;
		}
	}
	
}
