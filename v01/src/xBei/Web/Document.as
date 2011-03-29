package xBei.Web {
	import flash.display.MovieClip;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import xBei.Helper.StringHelper;

	/**
	 * 主程序、程序入口
	 * 只包含加载处理和“Loading”UI
	 * 所有的预加载都完毕以后把控制权交给WrokSpace
	 * @author KoaQiu
	 * @version 1.0
	 * @created 2010-10-13
	 */
	public class Document extends MovieClip{
		/**
		 * 软件版本号 
		 */
		public static const Version:String = '1.001';
		public function Document(){
			super();
			trace("xBei.Web.Document");
			glo.bal.OK = false;
			glo.bal.LoadingLog = '';
			glo.bal.LoadingPorgress = '0%';
			this.contextMenu = this.createContextMenu();
			stop();
		}
		
		/**
		 * 创建右键菜单
		 */
		protected function createContextMenu():ContextMenu{
			var ct:ContextMenu = new ContextMenu();
			ct.customItems.push(new ContextMenuItem("Design Version:" + Version));
			ct.customItems.push(new ContextMenuItem("FP Ver:" + Capabilities.version));
			ct.hideBuiltInItems();
			return ct;
		}
	}
}