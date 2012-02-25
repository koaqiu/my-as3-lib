package xBei.Interface{
	/**
	 * 模块，为了降低耦合性所有的非数据类一律使用接口进行调用
	 * @author KoaQiu
	 */	
	public interface IModel{
		/**
		 * 模块名称
		 * @return 
		 */
		function get ModelName():String;
		/**
		 * 作者
		 * @return 
		 */
		function get Author():String;
		/**
		 * 版本
		 * @return 
		 */
		function get Version():String;
		/**
		 * 初始化模块
		 * @param data
		 */		
		function Init(data:Object):void;
	}
}