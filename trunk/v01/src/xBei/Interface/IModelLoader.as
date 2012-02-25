package xBei.Interface {
	import flash.display.DisplayObject;
	/**
	 * 模块加载器
	 * @author KoaQiu
	 */	
	public interface IModelLoader {
		/**
		 * 提供的模块列表
		 * @return 
		 */		
		function ModelList():Array;
		/**
		 * 创建新模块
		 * @param name	模块名称
		 * @return 
		 */
		function NewModel(name:String, initData:Object = null):DisplayObject;
	}
}
