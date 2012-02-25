package xBei.Net{
	import flash.net.URLVariables;
	
	/**
	 * 请求地址查询参数支持 
	 * @author KoaQiu
	 * @see xBei.Net.Uri
	 */
	public dynamic class RequestQueryString extends URLVariables{
		private var _hasKey:Boolean = false;
		public function get HasKey():Boolean{
			return this._hasKey;
		}
		public function RequestQueryString(source:String = null){
			this._hasKey = source != null;
			super(source);
		}
		public function Clear():void{
			for(var k:* in this){
				if((this[k] is Function) == false){
					try{delete this[k];}
					catch(e:Error){}
				}
			}
		}
		/**
		 * 添加
		 * @param key
		 * @param value
		 * 
		 */
		public function Add(key:String,value:*):void{
			if(key == null){
				trace('xBei.Net.RequestQueryString.Add 发生错误：参数key为空（null）');
				return;
			}else if(value == null){
				this.Remove(key);
			}else{
				this[key] = value;
				this._hasKey = true;
			}
		}
		/**
		 * 删除Key 
		 * @param key
		 * 
		 */
		public function Remove(key:String):void{
			delete super[key];
		}
		/**
		 * 读取 QueryString 值
		 * @param	key		关键字
		 * @param	dv		默认值
		 * @return	发生错误时返回 dv 的值
		 */
		public function Get(key:String, dv:String = ""):String {
			if (this.hasOwnProperty(key) == false || this[key] == null) {
				return dv;
			}else {
				return this[key];
			}
		}
		/**
		 * 从QueryString中读取Int
		 * @param	key
		 * @param	dv
		 * @return
		 */
		public function GetInt(key:String, dv:int=0):int {
			if (this.hasOwnProperty(key) == false || this[key] == null) {
				return dv;
			}
			try{
				return int(this[key]);
			}catch (err:Error) {
			}
			return dv;
		}
		/**
		 * 从QueryString中读取Number
		 * @param	key
		 * @param	dv
		 * @return
		 */
		public function GetNumber(key:String, dv:Number=0.0):Number {
			if (super.hasOwnProperty(key) == false || super[key] == null) {
				return dv;
			}
			try{
				return Number(super[key]);
			}catch (err:Error) {
			}
			return dv;
		}
		/**
		 * 从QueryString中读取Boolean
		 * @param	key
		 * @param	dv
		 * @return
		 */
		public function GetBoolean(key:String, dv:Boolean=false):Boolean {
			if (this.hasOwnProperty(key) == false || this[key] == null) {
				return dv;
			}else {
				var value:String = this.Get(key).toLowerCase();
				if (value == "0" ||	value == "false" ||	value == "null" || value == "undefined") {
					return false;
				}else {
					return true;
				}
			}
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void {
			this.Clear();
		}
	}
}