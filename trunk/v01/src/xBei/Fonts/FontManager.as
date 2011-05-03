package xBei.Fonts {
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.text.Font;
	
	
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "ioError", type = "flash.events.IOErrorEvent")]
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	/**
	 * 字体管理器
	 * @author KoaQiu
	 */
	 public class FontManager extends EventDispatcher{
		private static var _instance:FontManager;
		private var _fontList:Array;
		function FontManager() {
			super();
			_fontList = [];
		}
		/**
		 * 注册事件
		 * @param	onComplete
		 * @param	onProgress
		 * @param	onIoError
		 */
		public static function AttEvents(onComplete:Function, onProgress:Function = null, onIoError:Function = null):void {
			var fm:FontManager = FontManager.instance;
			fm.addEventListener(Event.COMPLETE, onComplete);
			if (onProgress != null) {
				fm.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			if (onIoError != null) {
				fm.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			}
		}
		/**
		 * 得到加载的字体信息
		 * @param	fontID
		 * @return	{fontID,fontName,fontStyle,fontType,fontUrl}
		 */
		public static function getFont(fontID:String):Object {
			for each(var obj:Object in xBei.Fonts.FontManager.instance._fontList) {
				if (obj.fontID == fontID) {
					return obj;
				}
			}
			return null;
		}
		/**
		 * 注册字体
		 * 接受多个参数
		 * 一个：registerFont({fontID:"fontName",fontUrl:"font.swf"});
		 * 两个：registerFont("fontName","font.swf");
		 * @param	args...
		 */
		public static function registerFont(... args):EmbedFont {
			if (args.length == 1) {
				var obj:Object = args[0];
				if (obj.fontID && obj.fontUrl) {
					return FontManager.instance._registerFont(obj.fontID, obj.fontUrl);
				}
			}else if (args.length >= 2) {
				if (args[0] is String && args[1] is String) {
					return FontManager.instance._registerFont(args[0], args[1]);
				}
			}
			return null;
		}
		/**
		 * 管理器唯一实例
		 */
		public static function get instance():FontManager {
			if (FontManager._instance == null) {
				FontManager._instance = new FontManager();
			}
			return FontManager._instance;
		}

		/**
		 * 注册字体
		 * @param	fontID		字体ID
		 * @param	fontUrl		字体库地址
		 */
		private function _registerFont(fontID:String, fontUrl:String):EmbedFont {
			for each(var item:EmbedFont in _fontList) {
				if (item.fontUrl == fontUrl) {
					//已经注册过了
					return item;
				}
			}
			var eFont:EmbedFont = new EmbedFont(fontID, fontUrl);
			_fontList.push(eFont);
			return eFont;
		}
		//Events
	}
	
}
