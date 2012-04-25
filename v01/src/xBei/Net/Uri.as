package xBei.Net{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	import xBei.Helper.StringHelper;

	/**
	 * Uri 不完全解析版
	 * @version 0.1
	 * @author KoaQiu
	 * @see http://www.ietf.org/rfc/rfc3986 URI标准（RFC3986）
	 */
	public class Uri{
		private var _isLocal:Boolean = false;
		/**
		 * 是否本地地址 （file:///开头或者localhost主机）
		 * @return 
		 */
		public function get IsLocal():Boolean{
			return _isLocal;
		}
		public function get IsLoacalHost():Boolean{
			return this.Host == 'localhost' || this.Host == '127.0.0.1';
		}
		private var _valid:Boolean = false;
		private var _url:String;
		private var _scheme:String = 'unknown';
		private var _scheme_xx:String;
		/**
		 * 协议，目前支持http、https、ftp、mailto
		 * @return 
		 */		
		public function get Scheme():String{
			return this._scheme;
		}
		private var _authority:String = "";
		private var _username:String = "";
		private var _password:String = "";

		private var _host:String ='';
		/**
		 * 主机名 
		 * @return 
		 */
		public function get Host():String{
			return _host;
		}
		public function set Host(value:String):void	{
			_host = value;
		}

		private var _port:int = 80;

		/**
		 * 端口
		 * @default 80 
		 * @return 
		 */
		public function get Port():int{
			return _port;
		}

		public function set Port(value:int):void{
			_port = value;
		}

		private var _path:String = "/";

		/**
		 * 路径 
		 * @return 
		 */
		public function get Path():String{
			return _path;
		}

		/**
		 * 设置路径，会自动用'/'包围 
		 * @param value
		 */
		public function set Path(value:String):void{
			_path = value;
			if(value.charAt(0) !='/'){
				_path = '/' + value;
			}
			if(_path.charAt(_path.length-1) != '/'){
				_path = _path + '/';
			}
		}
		/**
		 * 忽略问号“？”后面的任何内容
		 * @param value
		 */	
		public function set FullPath(value:String):void{
			if(StringHelper.IsNullOrEmpty(value)){
				throw new ArgumentError('参数不能会空（null）');
			}
			var i1:int = value.lastIndexOf('?');
			if(i1 == 0){
				throw new ArgumentError('参数错误！');
			}else if(i1 > 0){
				value = value.substr(0, i1);
			}
			i1 = value.lastIndexOf('/');
			if(i1 == -1){
				this._path = '/';
				this._file = value;
			}else if(i1 == 0){
				this._path = '/';
				this._file = value.replace(/\//ig, '');
			}else{
				this.Path = value.substr(0, i1);
				this._file = value.substr(i1 + 1);
			}
		}

		private var _file:String = '';
		/**
		 * 得到文件名 
		 * @return 
		 */
		public function get File():String{
			return _file;
		}
		/**
		 * 设置文件名 
		 * @param vaule
		 */
		public function set File(vaule:String):void{
			_file = vaule.replace(/^\/+/,'');
		}
		private var _query:String = "";
		private var _fragment:String ='';
		
		private var _uv:RequestQueryString;
		public function get QueryString():RequestQueryString{
			return _uv;
		}
		
		/**
		 * 测试地址是否可以访问
		 * @param url
		 * @param callBack function(result:Object):void;result={url,success,error}
		 */
		public static function Test(url:String, callBack:Function):void{
			var isCb:Boolean = false;
			var uri:Uri = new Uri(url);
			var http_status:Function = function(e:HTTPStatusEvent):void{
				//trace(e.status,url,isCb);
				time.stop();
				if(isCb)return;isCb = true;
				if(e.status == 0){
					if(!uri.IsLocal){
						callBack({
							'url':url,
							'success':false,
							'error':'timeout'
						});
					}else{
						isCb = false;
					}
				}else if(e.status == 200){
					callBack({
						'url':url,
						'success':true
					});
				}else if(e.status == 404){
					callBack({
						'url':url,
						'success':false,
						'error':404
					});
				}else if(e.status == 403){
					callBack({
						'url':url,
						'success':false,
						'error':403
					});
				}else if(e.status >= 500 && e.status < 600){
					callBack({
						'url':url,
						'success':false,
						'error':'服务器错误'
					});
				}
			};
			var io_error:Function = function(e:IOErrorEvent):void{
				//trace(e,url,isCb);
				time.stop();
				if(isCb)return;isCb = true;
				callBack({
					'url':url,
					'success':false,
					'error':e.type
				});
			};
			var security_error:Function = function(e:SecurityErrorEvent):void{
				//trace(e,url,isCb);
				time.stop();
				if(isCb)return;isCb = true;
				callBack({
					'url':url,
					'success':false,
					'error':e.type
				});
			};
			var complete:Function = function(e:Event):void{
				//trace(e,url,isCb);
				time.stop();
				if(isCb)return;isCb = true;
				callBack({
					'url':url,
					'success':true
				});
			};
			var open:Function = function(e:Event):void{
				//if(isCb)return;isCb = true;
				//trace(e,url,isCb);
				time.stop();
			};
			var timeout:Function = function(e:TimerEvent):void{
				//trace(e,url,isCb);
				time.stop();
				if(isCb)return;isCb = true;
				callBack({
					'url':url,
					'success':false,
					'error':'timeout'
				});
			};
			var time:Timer = new Timer(30000);
			time.addEventListener(TimerEvent.TIMER, timeout);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, http_status);
			loader.addEventListener(IOErrorEvent.IO_ERROR, io_error);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, security_error);
			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(Event.OPEN, open);
			loader.load(new URLRequest(url));
			time.start();
		}
		public function Uri(url:String = null){
			if(StringHelper.IsNullOrEmpty(url) == false){
				//分解Uri各部分
				_valid = this._parseUrl(url.replace(/\\{1}/ig,'/'));//''
				if(_valid){
					this._parseQuery();
				}else{
					this._uv = new RequestQueryString();
				}
			}
		}
		
		private function _parseUrl(url:String):Boolean{
			//trace('解析：',url);
			this._url = url;
			var index:int = url.indexOf('#');
			if(index != -1){
				if(url.length > index + 1){
					_fragment = url.substr(index + 1);
				}
				url = url.substring(0, index - 1);
			}
			index = url.indexOf('?');
			if(index != -1){
				if(url.length > index + 1){
					_query = url.substr(index + 1);
				}
				url = url.substring(0,index - 1);
			}
			
			//开始检查协议
			var reg:RegExp = new RegExp('^([a-z]+):(/{2,4}).+','i');
			var fileReg:RegExp = /^[a-z]:[\\\/]/ig;
			if(reg.test(url)){
				var match:Object = reg.exec(url);
				_scheme = match[1].toLocaleLowerCase();
				this._isLocal = _scheme == 'file';
				_scheme_xx = String(match[2]);
				
				url = url.substr(_scheme.length + _scheme_xx.length + 1);
				//trace('检查协议：',this._isLocal,_scheme,url);
			}else if(fileReg.test(url)){
				_scheme = 'file';
				//trace('本地文件!');
				this._isLocal = true;
				//var m_file:Object = fileReg.exec(url);
				//url = url.substr(m_file.length);
			}
			if(this._isLocal == false){
				//检查端口
				var regPort:RegExp = new RegExp(':(\\d+)');
				if(regPort.test(url)){
					var mP:Object = regPort.exec(url);
					_port = int(mP[1]);
					url = url.replace(regPort,'');
					//trace('检查端口：',_port);
				}else{
					_port = PORT[_scheme];
				}
			
				//检查用户
				var regUser:RegExp = new RegExp('^([^:]+):{0,1}(.+){0,1}@.+','i');
				if(regUser.test(url)){
					var mU:Object = regUser.exec(url);
					_username = mU[1];
					_password = mU[2];
					
					index = _username.length + 1;
					if(_password.length > 0){
						index +=_password.length + 1;
					}
					
					url = url.substr(index);
				}
			}else{
				_port = 0;
			}
			//解析路径
			index = url.indexOf('/');
			//trace('解析路径', index, url);
			if(index > 0){
				_host = url.substring(0, index).replace(/[\|:]/ig,'');
				if(url.length > index + 1){
					_path = url.substr(index);
					
					var tmpAff:Array = _path.split('/').filter(function(str:String, index:int, arr:Array):Boolean{
						return !StringHelper.IsNullOrEmpty(str);
					});
					//trace(tmpAff);
					if(tmpAff[tmpAff.length - 1].length > 0){
						_file = String(tmpAff.pop());
						_path = '/' + tmpAff.join('/') + '/';
					}
					
				}
			}else{
				_host = url;
			}
			
			return _host.length > 0;
		}
		private function _parseQuery():void{
			if(_query.length == 0){
				_uv = new RequestQueryString();
			}else{
				try{
					_uv = new RequestQueryString(_query);
				}catch(err:Error){
					_uv = new RequestQueryString(err.message);
				}
			}
		}
		private var PORT:Object={
			'http':80,
			'https':443,
			'ftp':21,
			'file':0,
			'mailto':0
		}
		private function _validateURI():Boolean{
			if(['','http','https','ftp','file','mailto'].indexOf(_scheme) == -1){
				return false;
			}else if(_host.length == 0){
				return false;
			}
			
			return true;
		}
		/**
		 * 添加查询，如果key已经存在则直接替换新值 
		 * @param key	如果为null不会进行任何操作（会trace一个错误信息）
		 * @param value	如果值为null会删除该key
		 * 
		 */
		public function AddQuery(key:String,value:*):void{
			if(_uv == null){
				if(value == null || key == null){
					return;
				}
				_uv = new RequestQueryString();
			}
			_uv.Add(key,value);
		}
		/**
		 * 该地址是否在某个域
		 * @param domain
		 * @return 
		 */		
		public function IsInDomain(domain:String):Boolean{
			if(StringHelper.IsNullOrEmpty(domain)){
				return false;
			}else if(this.Host.toLowerCase() == domain.toLowerCase()){
				return true;
			}else{
				var a:Array = domain.toLowerCase().split('.').reverse();
				var b:Array = this.Host.toLowerCase().split('.').reverse();
				var i:int = 0
				for(;i < a.length && i < b.length;i++){
					if(a[i] != b[i]){
						break;
					}
				}
				return i == a.length - 1;
			}
		}
		/**
		 * 删除一个查询 
		 * @param key	要删除的key，如果为空或者不存在不会进行任何操作且不会发生异常
		 */
		public function RemoveQuery(key:String):void{
			if(_uv == null || key == null){
				return;
			}
			_uv.Remove(key);
		}
		/**
		 * 合并路径
		 * @param path	要合并的路径，“/”开头表示绝对路径，“～/”开头表示使用当前Uri的目录作为跟，其他开头则为相对路径
		 * 不同域或不同协议直接返回path的Uri
		 * @return 返回合并好的路径
		 */		
		public function Combine(path:*):Uri{
			if(path == null)throw new ArgumentError('参数不能会空（null）');
			var pUri:Uri;
			if(path is Uri) 
				pUri = path as Uri;
			else
				pUri = new Uri(String(path));
			if(pUri._validateURI()){
				return pUri;
			}else{
				var strPath:String = String(path);
				var r:Uri = new Uri(this.toString());
				if(strPath.indexOf('/') == 0){
					//“/”开头表示绝对路径
					r.FullPath = strPath;
				}else if(strPath.indexOf('~/') == 0){
					//“～/”开头表示使用当前Uri的目录作为根
					r.FullPath = r.Path + strPath.substr(2);
				}else if(strPath.indexOf('./') == 0){
					r.FullPath = r.Path + strPath.substr(2);
				}else if(strPath.indexOf('../') == 0){
					var lp:int = 1;
					var tp:String = strPath.substr(3);
					while(tp.indexOf('../') == 0){
						lp++;
						tp = tp.substr(3);
					}
					var parr:Array = r.Path.split('/');
					var rlp:int = parr.length - 2;
					if(lp > rlp){
						throw new ArgumentError('相对路径错误，没有那么多层');
					}
					for(var i:int = 0; i < lp; i++){
						parr.pop();
					}
					parr.pop();
					if(parr.length < 2){
						r.FullPath = '/' + tp;
					}else{
						r.FullPath =  parr.join('/') + '/' + tp;
					}
				}else{
					r.FullPath = r.Path + strPath;
				}
				return r;
			}
		}
		/**
		 * 销毁对象
		 */
		public function dispose():void {
			//if(this.QueryString != null){
			//	this.QueryString.dispose();
			//}
			this._uv = null;
		}
		/**
		 * 返回完整的uri地址（例如：http://www.xbei.net/blog/?p=1#comment） 
		 * @return 如果uri不可用则返回 null
		 */
		public function toString():String{
			_valid = _validateURI();
			if(_valid == false){
				return null;
			}
			var sScheme:String = 'http://';
			if(_scheme == 'file'){
				if(_scheme_xx == '////'){
					sScheme = 'file:///';
				}else{
					sScheme = 'file:' + _scheme_xx;
				}
			}else if(this._scheme == 'mailto'){
				sScheme = 'mailto:';
			}else if(_scheme.length > 0){
				sScheme = _scheme + '://';
			}
			var sAuthority:String = '';
			if(this.IsLocal == false && _username.length > 0){
				if(_password.length > 0){
					sAuthority = _username + ':' + _password + '@';
				}else{
					sAuthority = _username + '@'
				}
			}
			
			var sPort:String = '';
			if((this._scheme == 'http' && _port != 80) ||
				(this._scheme == 'https' && _port != 443) ||
				(this._scheme == 'ftp' && _port != 21)){
				sPort = ':' + _port.toString();
			}
			var sPath:String = '/';
			if(_path.length > 0){
				sPath = _path;
			}
			
			var sQuery:String = '';
			if(_uv != null && this._uv.HasKey){
				sQuery = '?' + _uv.toString();
			}
			var sFragment:String = '';
			if(_fragment.length > 0){
				sFragment = '#' + _fragment;
			}
			
			var s:String = sScheme + sAuthority + _host;
			if(this.IsLocal && glo.IsMac == false){
				s += '|';
			}
			s += sPort + sPath + _file + sQuery + sFragment;
			return s;
		}
	}
}