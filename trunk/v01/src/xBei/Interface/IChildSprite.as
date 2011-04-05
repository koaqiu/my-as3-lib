package xBei.Interface {

	/**
	 * 子对象，可以进行级层管理
	 * @author KoaQiu
	 * @see xBei.Manager.DepthManger
	 */
	public interface IChildSprite {
		/**
		 * 级层深度
		 * @see xBei.Manager.DepthManger
		 */
		function get VDepth():int;
		function set VDepth(v:int):void;
	}
}