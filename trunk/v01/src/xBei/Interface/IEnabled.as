package xBei.Interface {

	/**
	 * 可以禁用的对象
	 * @author KoaQiu
	 */
	public interface IEnabled {
		/**
		 * 对象是否可用
		 * @return
		 */
		function get Enabled():Boolean;
		function set Enabled(v:Boolean):void;
	}
}