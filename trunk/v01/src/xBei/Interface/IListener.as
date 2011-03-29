package xBei.Interface {
	
	/**
	 * 消息接收接口
	 * @author KoaQiu
	 * @see xBei.Manager.MessageManager
	 */
	public interface IListener {
		/**
		 * 处理消息
		 * @param	MESSAGE
		 * @param	source
		 * @param	...args
		 * @return
		 */
		function WndProc(MESSAGE:uint, source:Object = null, args:*=null):uint;
	}
	
}
