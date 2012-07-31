package {
	import flash.net.LocalConnection;
	/**
	 * 利用bug进行手动垃圾回收 
	 * @author KoaQiu
	 * 
	 */
	public final class MyGC {
		/**
		 * 回收垃圾 
		 */
		public static function GC():void {
			try {
				var lc1:LocalConnection = new LocalConnection();
				var lc2:LocalConnection = new LocalConnection();
				lc1.connect('name');
				lc2.connect('name2');
			} catch (e:Error) {
			}
		}
	}
}
