package xBei.Web.Data {
	import flash.display.LoaderInfo;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	
	import xBei.Debug.Logger;
	import xBei.Helper.StringHelper;
	import xBei.Net.Uri;

	/**
	 * 全局配置信息
	 * @author KoaQiu
	 *
	 */
	public dynamic class BasicAppConfig {
		private var _parameters:Object;
		private var _url:Uri;
		public function get Url():Uri{
			return this._url;
		}
		private var _docUrl:Uri;
		public function get DocumentUrl():Uri{
			return this._docUrl;
		}
		
		private static var _instance:BasicAppConfig;
		/**
		 * 静态唯一实例 
		 * @return 
		 */
		public static function get Instance():BasicAppConfig {
			if (BasicAppConfig._instance == null) {
				throw new Error("未初始化！");
			}
			return BasicAppConfig._instance;
		}
		
		/**
		 * 创建实例
		 * @param info	一般是主文档的root.loaderInfo
		 */
		public function BasicAppConfig(info:LoaderInfo) {
			this._url = new Uri(info.url);
			//var cache:String = url.QueryString.Get('cache');
			//trace('cache=', cache);
			this._parameters = info.parameters;
			_instance = this;
			this.processParameters();
			if(glo.bal.INIT_SETTING && this.Url.IsLocal){
				for(var k:* in glo.bal.INIT_SETTING){
					this[k] = glo.bal.INIT_SETTING[k];
				}
			}
			
			//检查宿主地址
			if(ExternalInterface.available){
				//ExternalInterface.marshallExceptions = true;
				var documentUrl:String = ExternalInterface.call('location.toString');
				if(!StringHelper.IsNullOrEmpty(documentUrl)){
					this._docUrl = new Uri(documentUrl);
				}
			}
		}
		
		/**
		 * 处理FlashVars传入的参数
		 * @see flash.display.DisplayObject.root
		 * @see flash.display.LoaderInfo.parameters
		 */
		protected function processParameters():void{
			throw new Error('processParameters 未实现');
		}
		
		/**
		 * 读取保存在“FlashVars”中的参数值
		 * @param	key		变量名称
		 * @param	dv		默认值
		 */
		protected function getAppParam(key:String, dv:String = ""):String {
			if (glo.IsNullOrUndefined(_parameters[key]) == false) {
				return String(_parameters[key]);
			}else {
				return dv;
			}
		}
		/**
		 * 从“FlashVars”中读取布尔值
		 * @param key
		 * @param dv
		 * @return 
		 */
		protected function getAppParamBoolean(key:String, dv:Boolean):Boolean{
			return glo.ToBoolean(_parameters[key], dv);
		}
	}
}