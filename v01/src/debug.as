package {
	import com.realeyesmedia.debug.redbug.modules.*;
	import com.realeyesmedia.debug.redbug.*;
	import flash.net.LocalConnection;
	
	/**
	 * 支持调试
	 * @author KoaQiu
	 * 
	 */
	public class debug {
		private static var d:Boolean = false;
		/**
		 * 是否显示调试信息
		 * 只写，默认：false
		 */ 
		public static function set isDebug(v:Boolean):void {
			debug.d = v;
		}
		/**
		 * @param app
		 * 
		 */
		public static function InitDebugFlash(app:String):void {
			//CONFIG::Debug 
			{
				trace("测试模式",app);
				REDbug.initialize(app, REDAppTypes.TYPE_FLASH);
			}
		}
		/**
		 * @param data
		 * @return 
		 * 
		 */
		private static function checkData(data:Object):Object {
			if (data is String) {
				return {
					text:data
				};
			}else {
				return data;
			}
		}
		/**
		 * @param msg
		 * @param args
		 * 
		 */
		public static function err(msg:String,...args):void {
			//CONFIG::Debug 
			{
				if (args) {
					if(args.length > 1) {
						REDbug.send(new RED_Logger( REDLogLevels.ERROR, msg, args));
					}else {
						REDbug.send(new RED_Logger( REDLogLevels.ERROR, msg, checkData(args[0])));
					}
				}else{
					REDbug.send(new RED_Logger( REDLogLevels.ERROR, msg, "no data"));
				}
			}
			//trace(msg, args);
		}
		/**
		 * @param msg
		 * @param args
		 * 
		 */
		public static function log(msg:String,...args):void {
			//CONFIG::Debug 
			{
				if (args) {
					if (args.length > 1) {
						REDbug.send(new RED_Logger( REDLogLevels.LOG, msg, args));
					}else {
						REDbug.send(new RED_Logger( REDLogLevels.LOG, msg, checkData(args[0])));
					}
				}else{
					REDbug.send(new RED_Logger( REDLogLevels.LOG, msg, "no data"));
				}
			}
			//trace(msg, args);
		}
		/**
		 * @param msg
		 * @param args
		 * 
		 */
		public static function info(msg:String,...args):void {
			//CONFIG::Debug 
			{
				if (args) {
					if (args.length > 1) {
						REDbug.send(new RED_Logger( REDLogLevels.INFO, msg, args));
					}else {
						REDbug.send(new RED_Logger( REDLogLevels.INFO, msg, checkData(args[0])));
					}
				}else{
					REDbug.send(new RED_Logger( REDLogLevels.INFO, msg, "no data"));
				}
			}
			trace(msg, args);
		}
		/**
		 * @param args
		 * 
		 */
		public static function tc(... args):void {
			//CONFIG::Debug 
			{
				trace(args);
			}
		}
	}
}
