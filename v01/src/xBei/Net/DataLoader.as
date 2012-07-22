package xBei.Net{
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import xBei.Debug.Logger;
	import xBei.Helper.ArraryHelper;
	import xBei.Helper.StringHelper;
	import xBei.Net.Events.DataLoaderEvent;
	
	
	use namespace xbei_internal;
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
	/**
	 * 数据加载类，封装flash.net.URLLoader
	 * @author KoaQiu
	 * @see xBei.Net.Events.DataLoaderEvent
	 */
	public class DataLoader extends URLLoader{
		private static var _boundary:String = "";
		
		protected static const HTTP_SEPARATOR:String="\r\n";
		private static var MIME_Type:Object = {
			'.ai':'application/postscript',
			'.aif':'audio/x-aiff',
			'.aifc':'audio/x-aiff',
			'.aiff':'audio/x-aiff',
			'.asc':'text/plain',
			'.au':'audio/basic',
			'.avi':'video/x-msvideo',
			'.bcpio':'application/x-bcpio',
			'.bin':'application/octet-stream',
			'.c':'text/plain',
			'.cc':'text/plain',
			'.ccad':'application/clariscad',
			'.cdf':'application/x-netcdf',
			'.class':'application/octet-stream',
			'.cpio':'application/x-cpio',
			'.cpt':'application/mac-compactpro',
			'.csh':'application/x-csh',
			'.css':'text/css',
			'.dcr':'application/x-director',
			'.dir':'application/x-director',
			'.dms':'application/octet-stream',
			'.doc':'application/msword',
			'.drw':'application/drafting',
			'.dvi':'application/x-dvi',
			'.dwg':'application/acad',
			'.dxf':'application/dxf',
			'.dxr':'application/x-director',
			'.eps':'application/postscript',
			'.etx':'text/x-setext',
			'.exe':'application/octet-stream',
			'.ez':'application/andrew-inset',
			'.f':'text/plain',
			'.f90':'text/plain',
			'.fli':'video/x-fli',
			'.gif':'image/gif',
			'.gtar':'application/x-gtar',
			'.gz':'application/x-gzip',
			'.h':'text/plain',
			'.hdf':'application/x-hdf',
			'.hh':'text/plain',
			'.hqx':'application/mac-binhex40',
			'.htm':'text/html',
			'.html':'text/html',
			'.ice':'x-conference/x-cooltalk',
			'.ief':'image/ief',
			'.iges':'model/iges',
			'.igs':'model/iges',
			'.ips':'application/x-ipscript',
			'.ipx':'application/x-ipix',
			'.jpe':'image/jpeg',
			'.jpeg':'image/jpeg',
			'.jpg':'image/jpeg',
			'.js':'application/x-javascript',
			'.kar':'audio/midi',
			'.latex':'application/x-latex',
			'.lha':'application/octet-stream',
			'.lsp':'application/x-lisp',
			'.lzh':'application/octet-stream',
			'.m':'text/plain',
			'.man':'application/x-troff-man',
			'.me':'application/x-troff-me',
			'.mesh':'model/mesh',
			'.mid':'audio/midi',
			'.midi':'audio/midi',
			'.mif':'application/vnd.mif',
			'.mime':'www/mime',
			'.mov':'video/quicktime',
			'.movie':'video/x-sgi-movie',
			'.mp2':'audio/mpeg',
			'.mp3':'audio/mpeg',
			'.mpe':'video/mpeg',
			'.mpeg':'video/mpeg',
			'.mpg':'video/mpeg',
			'.mpga':'audio/mpeg',
			'.ms':'application/x-troff-ms',
			'.msh':'model/mesh',
			'.nc':'application/x-netcdf',
			'.oda':'application/oda',
			'.pbm':'image/x-portable-bitmap',
			'.pdb':'chemical/x-pdb',
			'.pdf':'application/pdf',
			'.pgm':'image/x-portable-graymap',
			'.pgn':'application/x-chess-pgn',
			'.png':'image/png',
			'.pnm':'image/x-portable-anymap',
			'.pot':'application/mspowerpoint',
			'.ppm':'image/x-portable-pixmap',
			'.pps':'application/mspowerpoint',
			'.ppt':'application/mspowerpoint',
			'.ppz':'application/mspowerpoint',
			'.pre':'application/x-freelance',
			'.prt':'application/pro_eng',
			'.ps':'application/postscript',
			'.qt':'video/quicktime',
			'.ra':'audio/x-realaudio',
			'.ram':'audio/x-pn-realaudio',
			'.ras':'image/cmu-raster',
			'.rgb':'image/x-rgb',
			'.rm':'audio/x-pn-realaudio',
			'.roff':'application/x-troff',
			'.rpm':'audio/x-pn-realaudio-plugin',
			'.rtf':'text/rtf',
			'.rtx':'text/richtext',
			'.scm':'application/x-lotusscreencam',
			'.set':'application/set',
			'.sgm':'text/sgml',
			'.sgml':'text/sgml',
			'.sh':'application/x-sh',
			'.shar':'application/x-shar',
			'.silo':'model/mesh',
			'.sit':'application/x-stuffit',
			'.skd':'application/x-koan',
			'.skm':'application/x-koan',
			'.skp':'application/x-koan',
			'.skt':'application/x-koan',
			'.smi':'application/smil',
			'.smil':'application/smil',
			'.snd':'audio/basic',
			'.sol':'application/solids',
			'.spl':'application/x-futuresplash',
			'.src':'application/x-wais-source',
			'.step':'application/STEP',
			'.stl':'application/SLA',
			'.stp':'application/STEP',
			'.sv4cpio':'application/x-sv4cpio',
			'.sv4crc':'application/x-sv4crc',
			'.swf':'application/x-shockwave-flash',
			'.t':'application/x-troff',
			'.tar':'application/x-tar',
			'.tcl':'application/x-tcl',
			'.tex':'application/x-tex',
			'.texi':'application/x-texinfo',
			'.texinfo':'application/x-texinfo',
			'.tif':'image/tiff',
			'.tiff':'image/tiff',
			'.tr':'application/x-troff',
			'.tsi':'audio/TSP-audio',
			'.tsp':'application/dsptype',
			'.tsv':'text/tab-separated-values',
			'.txt':'text/plain',
			'.unv':'application/i-deas',
			'.ustar':'application/x-ustar',
			'.vcd':'application/x-cdlink',
			'.vda':'application/vda',
			'.viv':'video/vnd.vivo',
			'.vivo':'video/vnd.vivo',
			'.vrml':'model/vrml',
			'.wav':'audio/x-wav',
			'.wrl':'model/vrml',
			'.xbm':'image/x-xbitmap',
			'.xlc':'application/vnd.ms-excel',
			'.xll':'application/vnd.ms-excel',
			'.xlm':'application/vnd.ms-excel',
			'.xls':'application/vnd.ms-excel',
			'.xlw':'application/vnd.ms-excel',
			'.xml':'text/xml',
			'.xpm':'image/x-xpixmap',
			'.xwd':'image/x-xwindowdump',
			'.xyz':'chemical/x-pdb',
			'.zip':'application/zip'
		}
		
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
		public function get IsLocal():Boolean{
			var uri:Uri = new Uri(this._lastRq.url);
			return uri.IsLocal;
		}
		private var _isDebug:Boolean = false;
		/**
		 * 是否是调试模式 
		 * @return 
		 */
		public function get IsDebug():Boolean { return _isDebug; }
		public function set IsDebug(v:Boolean):void {
			_isDebug = v;
		}
		private var _timer:Timer;
		private var _callBack:Function;
		private var _lastRq:URLRequest;
		public function get RequestUrl():URLRequest{
			return this._lastRq;
		}
		private var _file:FileReference;
		/**
		 * 工作模式
		 * 0 - url
		 * 1 - 上传文件 
		 */
		private var _mode:int=0;
		
		private var _errMessage:String = "";
		/**
		 * 错误信息 
		 * @return 
		 * 
		 */
		public function get ErrorMessage():String {
			return _errMessage;
		}
		
		private var _resultData:*;
		/**
		 * 返回的数据 
		 * @return 
		 * 
		 */
		public function get ResultData():*{
			return _resultData;
		}
		
		private var _requestData:*;

		/**
		 * 要发送的数据（POST） 
		 */
		public function get RequestData():*
		{
			return _requestData;
		}

		/**
		 * @private
		 */
		public function set RequestData(value:*):void
		{
			_requestData = value;
		}

		private var _options:Object;
		private var _url:Uri;
		private var _qs:RequestQueryString;
		/**
		 * 参数（GET） 
		 */
		public function get QueryString():RequestQueryString{
			if(this._url == null){
				return this._qs;
			}else{
				return this._url.QueryString;
			}
		}
		
		public function DataLoader(){
			super();
			this._qs = new RequestQueryString();
			this.addEventListener(Event.OPEN, DPE_BeginTransfer);
			this.addEventListener(Event.COMPLETE, DPE_DataLoaded);
			this.addEventListener(HTTPStatusEvent.HTTP_STATUS, DPE_HttpStatusChanged);
			this.addEventListener(IOErrorEvent.IO_ERROR, DPE_IOError);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, DPE_SecurityError);
			
			this._timer = new Timer(this._timeOut * 1000);
		}
		private function _initTimer(pTimeOut:int):void{
			if(pTimeOut > 0){
				this._timeOut = pTimeOut;
				this._timer.delay = this._timeOut * 1000;
			}
		}
		private function _checkUrl(pUrl:*):Boolean{
			var check:Boolean = false;
			if (!StringHelper.IsNullOrEmpty(pUrl)) {
				if(pUrl is String){
					this._url = new Uri(String(pUrl));
					check = true;
				}else if(pUrl is Uri){
					this._url = pUrl;
					check = true;
				}else if (pUrl is URLRequest) {
					_lastRq = pUrl;
					this._url = new Uri(this._lastRq.url);
					check = true;
				}else if (pUrl != null) {
					this._url = new Uri(pUrl.toString());
					check = true;
				}
			}
			if(check){
				this._url.QueryString.Combine(this._qs);
				_lastRq = new URLRequest(this._url.toString());
				//if(this._options != null && this._options.hasOwnProperty('method')){
				//	_lastRq.method = this._options['method'];
				//}
				this._lastRq.method = this.getOption('method', URLRequestMethod.GET);
				_lastRq.data = this.prepareRequest();
			}else{
				this.OnError("没有地址");
			}
			return check;
		}
		//public
		/**
		 * 加载数据（默认使用get）
		 * @param	pUrl		要加载的地址
		 * @param	options		参数，{
		 * 	'timeout':30,//超时，0  表示使用默认值（30秒）
		 * 	'method':'get',
		 * 	'dataFormat':'text'
		 * }
		 * @param	callBack	回调函数 function(data:*, loader:DataLoader):Boolean;
		 */	
		public function Load(pUrl:*, options:Object = null, callBack:Function = null):void {
			this._setOptions(options);
			this._callBack = callBack;
			this._mode = 0;
			if(this._checkUrl(pUrl)){
				super.dataFormat = this.getOption('dataFormat', URLLoaderDataFormat.TEXT);
				this._setupTimerAndStart();
				super.load(_lastRq);
			}
		}
		/**
		 * 用POST方法提交数据
		 * @param	pUrl		要加载的地址
		 * @param	options		参数，{
		 * 	'timeout':30,//超时，0  表示使用默认值（30秒）
		 * 	'method':'post',//忽略此参数
		 * 	'dataFormat':'text'
		 * }
		 * @param	callBack	回调函数 function(data:*, loader:DataLoader):Boolean;
		 */	
		public function Post(pUrl:*, options:Object = null, callBack:Function = null):void{
			this.Load(pUrl, options == null ? {'method' : URLRequestMethod.POST}:
								glo.Extends(options, {'method' : URLRequestMethod.POST}),
								callBack);
		}
		/**
		 * 用POST方法提交数据
		 * @param	pUrl		要加载的地址
		 * @param	options		参数，{
		 * 	'timeout':30,//超时，0  表示使用默认值（30秒）
		 * 	'method':'post',//忽略此参数
		 * 	'dataFormat':'text'
		 * }
		 * @param	callBack	回调函数 function(data:*, loader:DataLoader):Boolean;
		 */	
		public function MyPost(pUrl:*, headers:Array = null, options:Object = null, callBack:Function = null):void{
			this._callBack = callBack;
			this._setOptions(options, {'method' : URLRequestMethod.POST});
			if(this._checkUrl(pUrl)){
				//_lastRq.method = URLRequestMethod.POST;
				this.setHeader(_lastRq, new URLRequestHeader("Cache-Control", "no-cache"));
				this.setHeader(_lastRq, new URLRequestHeader("Content-Type", "multipart/form-data; boundary=" + getBoundary()));
				
				_lastRq.data = this.getMultipart(_lastRq.data);
				if(ArraryHelper.HasItems(header)){
					for(var i:int = 0; i < headers.length; i++){
						var header:Object = headers[i];
						this.setHeader(_lastRq, new URLRequestHeader(header.key, header.value));
					}
				}
				super.dataFormat = this.getOption('dataFormat', URLLoaderDataFormat.TEXT);
				this._setupTimerAndStart();
				super.load(_lastRq);
			}
		}
		/**
		 * 请求图片资源
		 * @param	pUrl		要加载的地址
		 * @param	options		参数，{
		 * 	'timeout':30,//超时，0  表示使用默认值（30秒）
		 * 	'method':'get',
		 * 	'dataFormat':'text'
		 * }
		 * @param	callBack	回调函数 function(data:*, loader:DataLoader):Boolean;
		 */	
		public function GetImage(pUrl:*, options:Object = null, callBack:Function = null):void{
			this.Load(pUrl, options == null ? {'dataFormat' : URLLoaderDataFormat.BINARY}:
				glo.Extends(options, {'dataFormat' : URLLoaderDataFormat.BINARY}),
				callBack);
			
			//this._setOptions(options);
			//this._callBack = callBack;
			//this._mode = 0;
			//if(this._checkUrl(url)){
			//	super.dataFormat = URLLoaderDataFormat.BINARY;
			//	this._setupTimerAndStart();
			//	super.load(_lastRq);
			//}
		}
		/**
		 * 上传文件 
		 * @param fileToUpload	要上传的文件
		 * @param	pUrl		要加载的地址
		 * @param	options		参数，{
		 * 	'timeout':30,//超时，0  表示使用默认值（30秒）
		 * 	'method':'post',//忽略此参数
		 * 	'dataFormat':'text'
		 * }
		 * @param	callBack	回调函数 function(data:*, loader:DataLoader):Boolean;
		 */
		public function UploadFile(fileToUpload:FileReference, pUrl:*, options:Object = null, callBack:Function = null):void {
			this._callBack = callBack;
			this._setOptions(options, {'method' : URLRequestMethod.POST});
			if(fileToUpload != null && this._checkUrl(pUrl)){
				_mode = 1;
				_file = fileToUpload;
				_file.addEventListener(Event.OPEN,DPE_BeginTransfer);
				_file.addEventListener(IOErrorEvent.IO_ERROR, DPE_IOError);
				_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, DPE_SecurityError);
				_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, DPE_upload_complete_data);
				_file.addEventListener(ProgressEvent.PROGRESS, DPE_ProgressChanged);
				this._setupTimerAndStart();
				_file.upload(this._lastRq);
			}
		}
		/**
		 * 请使用新的方法：Load(); 
		 * @private
		 * @param request
		 * @see DataLoader#Load()
		 */
		override public function load(request:URLRequest):void {
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
			if(_mode == 0){
				super.close();
			}else if(_mode == 1){
				_file.cancel();
			}
		}
		/**
		 * 准备要发送的参数 
		 * @return 
		 */
		protected function prepareRequest():URLVariables {
			var uv:URLVariables = new URLVariables();
			if (this.RequestData != null) {
				for (var k:* in this.RequestData) {
					uv[k] = this.RequestData[k];
				}
			}
			return uv;
		}
		/**
		 * 准备 Url 
		 * @return 
		 */
		protected function prepareUrl():String {
//			var qs:String = '';
//			if(this.IsDebug){
//				qs += 'debug=0bb595a26db8fdb9556a298bcd092ab7';
//			}
//			if (this.QueryString != null) {
//				for (var k:Object in this.QueryString) {
//					var data:Object = this.QueryString[k];
//					if (glo.IsNullOrUndefined(data) == false) {
//						qs += StringHelper.Format("&{0}={1}", k, data.toString());
//					}
//				}
//			}
//			return qs;
			throw new Error('不使用！');
		}
		protected function runCallBackFunc(resultData:*):void{
			if (this._callBack != null) {
				var cb:Function = this._callBack;
				this._callBack = null;
				try{
					cb.call(this, resultData, this);
				}catch(error:ArgumentError){
					this._callBack = null;
					throw new ArgumentError('CallBack错误，正确的回调函数结构为：function(data:*,loader:*):Boolan{}');
				}
			}
		}
		protected function getOption(pName:String, dv:*):*{
			if(this._options != null && this._options.hasOwnProperty(pName)){
				return this._options[pName];
			}
			return dv;
		}
		private function _setupTimerAndStart():void{
			this.TimeOut = this.getOption('timeout', this.TimeOut);
			this._timer.delay = this._timeOut * 1000;
			this._timer.addEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.start();
		}
		private function _closeTimer():void{
			this._timer.removeEventListener(TimerEvent.TIMER, DPE_TimeOut);
			this._timer.stop();
		}
		
		private function _setOptions(options:Object, dv:Object = null):void{
			if(options != null && dv != null){
				this._options = glo.Extends(options, dv);
			}else if(dv != null){
				this._options = dv;
			}else{
				this._options = options;
			}
		}
		private function setHeader(rq:URLRequest, header:URLRequestHeader):void	{
			rq.requestHeaders.push(header);
		}
		private function getMultipart(dataToSend:Object):ByteArray{
			var body:ByteArray = new ByteArray;
			var key:String;
			for (key in dataToSend)	{
				var tData:Object = dataToSend[key];
				if (tData is PostFileItem){
					var pfi:PostFileItem = tData as PostFileItem;
					if(pfi.Data != null){
						if(StringHelper.IsNullOrEmpty(pfi.FileName)){
							pfi.FileName = 'unknowFile';
						}
						if(StringHelper.IsNullOrEmpty(pfi.Field)){
							pfi.Field = 'FileData';
						}
						body.writeUTFBytes("--" + getBoundary());
						body.writeUTFBytes(HTTP_SEPARATOR);
						body.writeUTFBytes("Content-Disposition: form-data; name=\"" + pfi.Field + "\"; filename=\"" + pfi.FileName + "\"");
						body.writeUTFBytes(HTTP_SEPARATOR);
						//body.writeUTFBytes("application/octet-stream");//Content-Type: application/octet-stream
						body.writeUTFBytes("Content-Type: " + this.getContentType(pfi.FileName));
						body.writeUTFBytes(HTTP_SEPARATOR);
						body.writeUTFBytes(HTTP_SEPARATOR);
						body.writeBytes(pfi.Data, 0, pfi.Data.length);
						body.writeUTFBytes(HTTP_SEPARATOR);
					}
				}else if (tData is String || tData is Boolean || tData is Number || tData is int || tData is uint || tData is Date)	{
					body.writeUTFBytes("--" + getBoundary());
					body.writeUTFBytes(HTTP_SEPARATOR);
					body.writeUTFBytes("Content-Disposition: form-data; name=\"" + key + "\"");
					body.writeUTFBytes(HTTP_SEPARATOR);
					body.writeUTFBytes(HTTP_SEPARATOR);
					body.writeUTFBytes(tData.toString());
					body.writeUTFBytes(HTTP_SEPARATOR);
				}
			}
			
			body.writeUTFBytes("--" + getBoundary() + "--");
			body.writeUTFBytes(HTTP_SEPARATOR);
			
			return body;
		}
		private function getContentType(file:String):String{
			if(file != null && file.length >1){
				var i:int = file.lastIndexOf('.');
				if(i >= 0 && i < file.length - 1){
					var ext:String = file.substr(i);
					if(MIME_Type[ext] != null){
						return MIME_Type[ext];
					}
				}
			}
			return 'application/octet-stream';
		}
		private static function getBoundary():String	{
			var int32:int;
			if (_boundary.length == 0) {
				int32 = 0;
				while (int32 < 32) {
					_boundary = _boundary + String.fromCharCode(int(97 + Math.random() * 25));
					int32++;
				}
				_boundary = _boundary;
			}
			return _boundary;
		}
		//Do Event
		/**
		 * 数据加载完毕时触发 
		 * @return 
		 */
		protected function OnDataLoaded():void {
			this._closeTimer();
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.DATA_LOADED));
			this.runCallBackFunc({
				'success':true,
				'resultData':this.data
			});
		}
		/**
		 * 发生错误时触发 
		 * @param msg
		 */
		protected function OnError(msg:String):void {
			this._closeTimer();
			_errMessage = msg;
			Logger.error(StringHelper.Format('加载错误：{0}', msg));
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.ERROR));
			this.runCallBackFunc({
				'success':false,
				'error':DataLoaderEvent.ERROR,
				'message':msg
			});
		}
		/**
		 * 加载超时 
		 */
		protected function OnTimeOut():void {
			this._closeTimer();
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.TIME_OUT));
			this.runCallBackFunc({
				'success':false,
				'error':DataLoaderEvent.TIME_OUT,
				'message':'timeout'
			});
		}
		/**
		 * 网络离线 
		 */
		protected function OnOffline():void {
			this._closeTimer();
			this.dispatchEvent(new DataLoaderEvent(DataLoaderEvent.OFFLINE));
			this.runCallBackFunc({
				'success':false,
				'message':'offline'
			});
		}
		//Events
		private function DPE_DataLoaded(e:Event):void {
			if (Capabilities.playerType != "DirectorXtra") {
				this._resultData = super.data;
				this.OnDataLoaded();
			}
		}
		private function DPE_BeginTransfer(e:Event):void {
			this._closeTimer();
		}
		private function DPE_IOError(e:IOErrorEvent):void {
			this.OnError('错误：找不到地址');
		}
		private function DPE_SecurityError(e:SecurityErrorEvent):void {
			this.OnError('安全错误：' + e.text);
		}
		
		private function DPE_DIR_Loaded(e:TimerEvent):void {
			if (this.data != null) {
				var str:String = String(this.data);
				
				var reg1:RegExp = new RegExp("Content-Length: (\\d+)", "ig");
				var m1:Object = reg1.exec(str);
				if(m1 != null){
					this.data = str.substr(str.length - m1[1]);
					str = this.data;
				}
				if (str.indexOf("Content-Type:") == -1) {
					var t:Timer = e.target as Timer;
					t.removeEventListener(TimerEvent.TIMER, DPE_DIR_Loaded);
					t.stop();
					this._resultData = super.data;
					this.OnDataLoaded();
				}
			}
		}
		private function DPE_TimeOut(e:TimerEvent):void {
			this.OnTimeOut();
		}
		private function DPE_HttpStatusChanged(e:HTTPStatusEvent):void {
			//trace("HTTPStatus:",e.status, this.RequestUrl.url);
			Logger.log(StringHelper.Format("HTTPStatus:{0},{1}",e.status, this.RequestUrl.url));
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
				Logger.error(e.status.toString() + '错误 ' + this.RequestUrl.url);
				if(e.status != 404){
					this.OnError(StringHelper.Format('服务器错误：{0}',e.status));
				}
			}
		}
		
		//UPLOAD
		private function DPE_upload_complete_data(e:DataEvent):void {
			this._resultData = e.data;
			this.OnDataLoaded();
		}
		private function DPE_ProgressChanged(e:ProgressEvent):void {
			//trace('进度条：',e.bytesLoaded);
			this.dispatchEvent(e);
		}
	}
}