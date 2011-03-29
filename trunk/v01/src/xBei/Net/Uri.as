package xBei.Net{
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
		 * 是否本地地址 （file:///开头）
		 * @return 
		 */
		public function get IsLocal():Boolean{
			return _isLocal;
		}

		private var _valid:Boolean = false;
		
		private var _scheme:String = 'unknown';
		private var _authority:String = "";
		private var _username:String = "";
		private var _password:String = "";

		private var _host:String ='';
		/**
		 * 主机名 
		 * @return 
		 * 
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
		 * 
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
		 * 
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
		
		public function Uri(url:String = null){
			if(url != null){
				//分解Uri各部分
				_valid = this._parseUrl(url);
				if(_valid){
					this._parseQuery();
				}
			}
		}
		
		private function _parseUrl(url:String):Boolean{
			//trace('解析：',url);
			var index:int = url.indexOf('#');
			if(index != -1){
				if(url.length > index + 1){
					_fragment = url.substr(index + 1);
				}
				url = url.substring(0,index - 1);
			}
			index = url.indexOf('?');
			if(index != -1){
				if(url.length > index + 1){
					_query = url.substr(index + 1);
				}
				url = url.substring(0,index - 1);
			}
			
			//开始检查协议
			var reg:RegExp = new RegExp('^([a-z]+):(/{2,3}).+','i');
			if(reg.test(url)){
				var match:Object = reg.exec(url);
				_scheme = match[1].toLocaleLowerCase();
				_isLocal = _scheme == 'file' && match[2] == '///';
				
				url = url.substr(_scheme.length + match[2].length + 1);
				//trace('检查协议：',url);
			}
			//检查端口
			var regPort:RegExp = new RegExp(':(\\d+)');
			if(regPort.test(url)){
				var mP:Object = regPort.exec(url);
				_port = int(mP[1]);
				url = url.replace(regPort,'');
				//trace('检查端口：',_port);
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
			
			//if(url.indexOf(':') != 0){
			//	trace('格式错误！',url);
			//	return false;
			//}
			
			//解析路径
			index = url.indexOf('/');
			if(index > 0){
				_host = url.substring(0, index - 1);
				if(url.length > index + 1){
					_path = url.substr(index);
					
					var tmpAff:Array = _path.split('/');
					if(tmpAff[tmpAff.length - 1].length > 0){
						_file = String(tmpAff.pop());
						_path = tmpAff.join('/') + '/';
					}
					
				}
			}else{
				_host = url;
			}
			
			return _host.length > 0;
		}
		private function _parseQuery():void{
			if(_query.length == 0){
				return;
			}
			
			var uv:RequestQueryString = new RequestQueryString();
			try{
				uv.decode(_query);
			}catch(err:Error){
			}
			_uv = uv;
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
				sScheme = 'file:///';
			}else if(_scheme.length > 0){
				sScheme = _scheme + '//';
			}
			var sAuthority:String = '';
			if(_username.length > 0){
				if(_password.length > 0){
					sAuthority = _username + ':' + _password + '@';
				}else{
					sAuthority = _username + '@'
				}
			}
			
			var sPort:String = '';
			if(_port != 80){
				sPort = ':' + _port.toString();
			}
			
			var sPath:String = '/';
			if(_path.length > 0){
				sPath = _path;
			}
			
			var sQuery:String = '';
			if(_uv != null){
				sQuery = '?' + _uv.toString();
			}
			var sFragment:String = '';
			if(_fragment.length > 0){
				sFragment = '#' + _fragment;
			}
			
			return sScheme + sAuthority + _host + sPort + sPath + _file + sQuery + sFragment;
		}
	}
}