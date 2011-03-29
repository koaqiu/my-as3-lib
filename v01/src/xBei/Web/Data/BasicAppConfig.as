package xBei.Web.Data {
	import flash.display.LoaderInfo;

	/**
	 * 全局配置信息
	 * @author KoaQiu
	 *
	 */
	public dynamic class BasicAppConfig {
		private var _parameters:Object;
		
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
			this._parameters = info.parameters;
			_instance = this;
			this.processParameters();
		}
		
		/**
		 * 处理FlashVars传入的参数
		 * @see flash.display.DisplayObject.root
		 * @see flash.display.LoaderInfo.parameters
		 */
		protected function processParameters():void{
			
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
	}
}