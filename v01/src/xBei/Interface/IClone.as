package xBei.Interface {

	/**
	 * 实现深度克隆
	 * @param isDeep
	 * @author KoaQiu
	 */
	public interface IClone {
		/**
		 * 克隆对象（包括内部对象）
		 * @param isDeep	是否深度克隆
		 * @return 
		 */
		function Clone(isDeep:Boolean = true):*;
	}
}