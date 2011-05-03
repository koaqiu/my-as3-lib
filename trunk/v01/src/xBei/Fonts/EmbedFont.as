package xBei.Fonts {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.*;
	import flash.text.*;
	
	import xBei.Interface.IFont;
	
	/**
	 * 嵌入字体
	 * @author KoaQiu
	 */
	public dynamic class EmbedFont extends EventDispatcher implements IFont{
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
		public function getTextField():TextField{
			return new TextField();
		}
		function EmbedFont(pFontID:String, pFontUrl:String) {
			this._fontID = pFontID;
			this._fontUrl = pFontUrl;
			var _loader:Loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFontError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontsLoad);
			//trace("下载字体", pFontUrl);
			_downloading = true;
			var context:LoaderContext = new LoaderContext();
			/* 加载到子域(模块) */
			//context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			/* 加载到同域(共享库) */
			//context.applicationDomain = ApplicationDomain.currentDomain;
			/* 加载到新域(独立运行的程序或模块) */
			context.applicationDomain = new ApplicationDomain();

			Security.allowDomain("*");
			//_loader.load(new URLRequest(APIUtility.Instance.GetEmbedFontUrl(pFontUrl)),context);
			_loader.load(new URLRequest("Lang/"+pFontUrl));
		}
		public function SetFont(pFont:Font):void {
			this._fontName = pFont.fontName;
			switch(pFont.fontStyle) {
				case FontStyle.BOLD:
					this._fontStyle = FontStyles.BOLD;
					break;
				case FontStyle.ITALIC:
					this._fontStyle = FontStyles.ITALIC;
					break;
				case FontStyle.BOLD_ITALIC:
					this._fontStyle = FontStyles.BOLD_ITALIC;
					break;
				default:
					this._fontStyle = FontStyles.REGULAR;
			}
			this._fontType = pFont.fontType;
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
		private function onFontsLoad(e:Event):void {
			var font:Class;
			try {
				//trace("注册字体：",fontID);
				font = e.target.applicationDomain.getDefinition(fontID) as Class;
				Font.registerFont(font);
			}catch (err:Error) {
				trace(err)
				this.onError("字体注册失败！"+err);
				return;
			}
			this.SetFont(new font());
			//_fontList.push(eFont);
			onFontLoadCompleted();
		}
		private function onLoadProgress(e:ProgressEvent):void {
			this.dispatchEvent(e);
		}
		private function onLoadFontError(e:IOErrorEvent):void {
			this.dispatchEvent(e);
		}
	}
}
