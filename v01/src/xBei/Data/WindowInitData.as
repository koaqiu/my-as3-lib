package xBei.Data
{
	import flash.display.Stage;
	
	import xBei.Helper.StringHelper;
	import xBei.Manager.StageManager;

	public dynamic class WindowInitData
	{
		/**
		 * 点击遮罩可以关闭窗口
		 */
		public var MaskCanBeClickForCloseWindow:Boolean = true;
		/**
		 * 是否有关闭按钮，CloseButtonClass、CloseButtonName任意一属性有些此属性为真
		 * @return 
		 */
		public function get HasCloseButton():Boolean{
			return !(StringHelper.IsNullOrEmpty(this.CloseButtonName) && StringHelper.IsNullOrEmpty(this.CloseButtonClass));
		}
		/**
		 * 关闭按钮类名
		 */
		public var CloseButtonClass:String = '';
		/**
		 * 关闭按钮名称
		 */
		public var CloseButtonName:String = '';
		/**
		 * CloseButtonClass有效，此属性才有意义
		 * CloseButtonName有戏，此属性自动忽略
		 */
		public var CloseButtonOffX:int = 60;
		/**
		 * CloseButtonClass有效，此属性才有意义
		 * CloseButtonName有戏，此属性自动忽略
		 */
		public var CloseButtonOffY:int = 19;
		public var MaskAlpha:Number = .6;
		public var OffsetX:int = 0;
		public var OffsetY:int = 0;
		public var ease:Object = null;
		public var NoDispose:Boolean = false;
		/**
		 * 帧标签
		 */
		public var GotoLabel:Object;
		//public var sWidth:int;
		//public var sHieght:int;
		
		public function WindowInitData(){
			this.Init(_stage, _initData);
		}
		private static var _stage:flash.display.Stage;
		private static var _initData:Object;
		public static function get Stage():flash.display.Stage{
			return _stage;
		}
		public static function Initialize(initData:Object = null):void{
			//if(pStage == null){
			//	throw new ArgumentError('xBei.Data.WindowInitData.Initialize(); pStage不能为空（null）');
			//}
			_stage = StageManager.Instance.Stage;
			_initData = initData;
		}
		
		public function Init(pStage:flash.display.Stage, initData:Object):void{
			if (initData != null) {
				for (var k:* in initData) {
					//if(this.hasOwnProperty(k)){
						this[k] = initData[k];
					//}
				}
			}
			//if(sWidth == 0)sWidth = pStage.width;
			//if(sHieght == 0)sHieght = pStage.height;
		}
	}
}