package xBei.Fonts {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import xBei.Interface.IFont;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="io_error", type="flash.events.IOErrorEvent")]
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 简单字体
	 * @author KoaQiu
	 */
	public dynamic class SimpleFont extends EventDispatcher	implements IFont{
		private var _fontUrl:String;
		private var _fontID:String;
		private var _fontName:String;
		private var _fontStyle:uint;
		private var _fontType:String;
		private var _downloaded:Boolean = false;
		private var _downloading:Boolean = false;
		
		public function get fontID () : String {
			return _fontID;
		}
		public function get fontUrl () : String{
			return _fontUrl;
		}
		public function get fontName () : String {
			return _fontName;
		}
		public function get fontStyle () : uint{
			return _fontStyle;
		}
		public function get fontType () : String{
			return _fontType;
		}
		public function get IsDown():Boolean {
			return _downloaded;
		}
		private var _loader:Loader;
		function SimpleFont(pFontID:String, pFontUrl:String) {
			SimpleFont._list.push(this);
			this._fontID = pFontID;
			this._fontUrl = pFontUrl;
			this._fontStyle = FontStyles.REGULAR;
			this._loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, DPE_HttpStatus);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFontError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontsLoad);
			_downloading = true;
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = false;
			if(glo.bal.IsLocal == false){
				context.securityDomain = SecurityDomain.currentDomain;
			}
			/* 加载到子域(模块) */
			//context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			/* 加载到同域(共享库) */
			context.applicationDomain = ApplicationDomain.currentDomain;
			/* 加载到新域(独立运行的程序或模块) */
			//context.applicationDomain = new ApplicationDomain();

			//TODO 字体下载地址
			//var fontUrl:String = APIUtility.Instance.GetEmbedFontUrl(pFontUrl);
			//debug.info("字体下载", this._fontUrl);
			_loader.load(new URLRequest(this._fontUrl), context);
			//_loader.load(new URLRequest(APIUtility.Instance.GetEmbedFontUrl("msYH.swf")), context);
			//_loader.load(new URLRequest("Lang/" + pFontUrl));
		}
		public function CancelDownload():void {
			this._loader.close();
			this._downloaded = false;
			this._downloading = false;
		}
		private static var _list:Vector.<SimpleFont> = new Vector.<SimpleFont>();
		public static function Create(pFontID:String,pFontUrl:String):SimpleFont {
			for each(var item:SimpleFont in SimpleFont._list) {
				if (item.fontID == pFontID) {
					return item;
				}
			}
			return new SimpleFont(pFontID, pFontUrl);
		}
		/*private function SetFont(pFont:FontItem):void {
			this._fontName = pFont.FontName;
		}*/
		private var _fontClass:Class;
		public function getTextField():TextField {
			//var sF:SFont = (new _fontClass() as SFont);
			//return sF.getTextField();
			var sp:Sprite=(new _fontClass() as Sprite);
			var i:int = 0;
			while (i < sp.numChildren) {
				//trace(sp.getChildAt(i));
				if (sp.getChildAt(i) is TextField) {
					//trace('xxxxxxxxxxxxxxx');
					return sp.getChildAt(i) as TextField;
				}
			}
			return null;
		}
		//Do Event
		protected function onFontLoadCompleted():void {
			_downloaded = true;
			_downloading = false;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		protected function onError(msg:String):void {
			var err:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, false, msg);
			_downloaded = true;
			_downloading = false;
			this.dispatchEvent(err);
		}
		//Events
		private function DPE_HttpStatus(e:HTTPStatusEvent):void {
		}
		private function onFontsLoad(e:Event):void {
			var font:Class;
			try {
				var app:ApplicationDomain = e.target.applicationDomain;
				var mc:Sprite = (e.target as LoaderInfo).content as Sprite;
				var l:int = mc.numChildren;
				var sp:Sprite;
				//var txt:SFont;
				for (var i:int = 0; i < l; i++) {
					//txt = mc.getChildAt(i) as SFont;
					//if (txt != null) {
					//	break;
					//}
					sp = mc.getChildAt(i) as Sprite;
					if (sp != null) {
						break;
					}
				}
				//var clasName:String = getQualifiedClassName(txt);
				var clasName:String = getQualifiedClassName(sp);
				this._fontClass = app.getDefinition(clasName) as Class;
				trace('注册成功：',this._fontClass,clasName);
			}catch (err:Error) {
				trace("字体注册失败",err);
				this.onError("字体注册失败！"+err);
				return;
			}
			onFontLoadCompleted();
		}
		private function onLoadProgress(e:ProgressEvent):void {
			//trace(this,e);
			this.dispatchEvent(e);
		}
		private function onLoadFontError(e:IOErrorEvent):void {
			this.dispatchEvent(e);
		}
	}
}
