package xBei.Net {
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import xBei.Helper.StringHelper;
	import xBei.Interface.IDispose;
	import xBei.Net.Events.DataLoaderEvent;

	/**
	 * 连接超时 
	 */
	[Event(name = "timeOut", type = "xBei.Net.Events.DataLoaderEvent")]
	/**
	 * 数据加载完毕 
	 */
	[Event(name = "dataLoaded", type = "xBei.Net.Events.DataLoaderEvent")]
	/**
	 * 网络离线 
	 */
	[Event(name = "offline", type = "xBei.Net.Events.DataLoaderEvent")]
	/**
	 * 发生错误，包括IO错误和安全（Security）错误 
	 */
	[Event(name = "error", type = "xBei.Net.Events.DataLoaderEvent")]
	public class XLoader extends Loader implements IDispose {
		private var _timeOut:int = 30;
		
		/**
		 * 请求加载超时时间
		 * @default	20 
		 * @return 
		 * 
		 */
		public function get TimeOut():int{
			return _timeOut;
		}
		
		public function set TimeOut(value:int):void{
			if(value > 0){
				_timeOut = value;
			}
		}
		private var _errMessage:String = "";
		/**
		 * 错误信息 
		 * @return 
		 * 
		 */
		public function get ErrorMessage():String {
			return _errMessage;
		}
		/**
		 * 要发送的数据（POST） 
		 */
		public var RequestData:*;
		
		private var _timer:Timer;
		private var _callBack:Function;
		private var _lastRq:URLRequest;
		private var _dataLoadCompleted:Boolean;
		private var _begingDataLoad:Boolean;

		public function get IsLocal():Boolean{
			var uri:Uri = new Uri(this._lastRq.url);
			return uri.IsLocal;
		}

		public function XLoader() {
			super();
			this.contentLoaderInfo.addEventListener(Event.INIT, DPE_Init);
			this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, DPE_Progress);
			this.contentLoaderInfo.addEventListener(Event.OPEN, DPE_BeginTransfer);
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, DPE_DataLoaded);
			this.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, DPE_HttpStatusChanged);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, DPE_IOError);
			this.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, DPE_SecurityError);
			
			this._timer = new Timer(this._timeOut * 1000);
		}
		
		public function dispose():void{
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
			this._timer = null;
			this.RequestData = null;
			this._callBack = null;
				
			this.contentLoaderInfo.removeEventListener(Event.INIT, DPE_Init);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, DPE_Progress);
			this.contentLoaderInfo.removeEventListener(Event.OPEN, DPE_BeginTransfer);
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, DPE_DataLoaded);
			this.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, DPE_HttpStatusChanged);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, DPE_IOError);
			this.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, DPE_SecurityError);
			
			this.unloadAndStop();
		}
		
		
		/**
		 * 请使用新的方法：Load(); 
		 * @private
		 * @param request
		 * @see DataLoader#Load()
		 */
		override public function load(request:URLRequest, context:LoaderContext = null):void {
			throw new Error("请使用新的方法：Load();");
		}
		/**
		 * 请使用新的方法：Close();
		 * @private
		 * @see DataLoader#Close()
		 */
		override public function close():void{
			throw new Error("请使用新的方法：Close();");
		}
		/**
		 * 关闭进行中的操作
		 */
		public function Close():void{
			super.close();
		}
		/**
		 * 
		 * @param	pUrl		要加载的地址
		 * @prame	context
		 * @param	timeOut		超时，0  表示使用默认值（30秒）
		 * @param	callBack	回调函数 function(DataLoader):Boolean;
		 */	
		public function Load(pUrl:*, timeOut:int = 0,context:LoaderContext = null, callBack:Function = null):void {
			if(this._checkUrl(pUrl)){
				this._initTimer(timeOut);
				this._callBack = callBack;
				
				this._timer.addEventListener(TimerEvent.TIMER, DPE_TimeOut);
				this._timer.start();
				super.load(_lastRq, context);
			}
		}
		/**
		 * 用POST方法提交数据
		 * @param url
		 * @param callBack
		 * 
		 */		
		public function Post(url:String, 
							 timeOut:int = 0,
							 context:LoaderContext = null, callBack:Function = null):void{
			this._callBack = callBack;
			var rq:URLRequest = new URLRequest(url);
			rq.method = URLRequestMethod.POST;
			rq.data = this.prepareRequest();
			
			this.Load(rq, timeOut, context);
		}
		/**
		 * 准备要发送的参数 
		 * @return 
		 * 
		 */
		protected function prepareRequest():URLVariables {
			var uv:URLVariables = new URLVariables();
			
			if (this.RequestData != null) {
				for (var k:* in this.RequestData) {
					uv.param[k] = this.RequestData[k];
				}
			}
			
			return uv;
		}
		
		private function _initTimer(pTimeOut:int):void{
			if(pTimeOut > 0){
				this._timeOut = pTimeOut;
				this._timer.delay = this._timeOut * 1000;
			}
		}
		private function _checkUrl(pUrl:*):Boolean{
			if (pUrl is String) {
				if (String(pUrl).length == 0) {
					this.OnError("没有地址");
					return false;
				}
				_lastRq = new URLRequest(pUrl);
			}else if (pUrl is URLRequest) {
				_lastRq = pUrl;
			}else if (pUrl != null) {
				_lastRq = new URLRequest(pUrl.toString());
			}else {
				this.OnError("没有地址");
				return false;
			}
			return true;
		}
		private function _stopTimeoutCheck():void {
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
		}
		//On Event
		/**
		 * 数据加载完毕时触发 
		 * @return 
		 */
		protected function OnDataLoaded():Boolean {
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.DATA_LOADED));
			if (this._callBack != null) {
				return this._callBack(this);
			}
			return true;
		}
		/**
		 * 发生错误时触发 
		 * @param msg
		 */
		protected function OnError(msg:String):void {
			this._errMessage = msg;
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.ERROR));
			try{this.Close();}catch(error:Error){}
		}
		/**
		 * 加载超时 
		 */
		protected function OnTimeOut():void {
			trace("time out",this._lastRq, this._lastRq.url);
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
			try{this.Close();}catch(error:Error){}
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.TIME_OUT));
		}
		//Events
		private function DPE_Progress(e:ProgressEvent):void{
			if(e.bytesTotal > 0 && e.bytesLoaded >= e.bytesTotal){
				this._dataLoadCompleted = true;
			}
			if(e.bytesLoaded > 0){
				this._begingDataLoad = true;
				this._stopTimeoutCheck();
			}
			
			this.dispatchEvent(e);
		}
		private function DPE_Init(e:Event):void{
			if(this.contentLoaderInfo.content == null && this._dataLoadCompleted == false){
				setTimeout(this.DPE_Init,100,e);
			}else{
				this.dispatchEvent(new Event(Event.INIT));
			}
		}
		private function DPE_DataLoaded(e:Event):void {
			if (Capabilities.playerType != "DirectorXtra") {
				this.OnDataLoaded();
			}
		}
		private function DPE_DIR_Loaded(e:TimerEvent):void {
			if(super.contentLoaderInfo.content != null){
				
			}
		}
		private function DPE_HttpStatusChanged(e:HTTPStatusEvent):void {
			//trace(e.status);
			if (Capabilities.playerType == "DirectorXtra") {
				var t:Timer = new Timer(100);
				t.addEventListener(TimerEvent.TIMER, DPE_DIR_Loaded);
				t.start();
			}else if (e.status == 0) {
				if(this.IsLocal){
					//this.OnError('IOError');
				}else{
					this.OnTimeOut();
				}
			}else if(e.status != 200){
				this.OnError(StringHelper.Format('服务器错误：{0}',e.status));
			}
		}
		private function DPE_BeginTransfer(e:Event):void {
			//trace("DPE_BeginTransfer",this._lastRq.url, JSON.encode(this._lastRq.data));
			//trace('开始下载');
			this._dataLoadCompleted = false;
			this._begingDataLoad = false;
			this._stopTimeoutCheck();
		}
		
		private function DPE_IOError(e:IOErrorEvent):void {
			//trace(e);
			if(this._begingDataLoad == false){
				this.OnError('IOError' + e.text);
			}
		}
		private function DPE_SecurityError(e:SecurityErrorEvent):void {
			this.OnError('Secure Error' + e.text);
		}
		private function DPE_TimeOut(e:TimerEvent):void {
			this.OnTimeOut();
		}
	}
}