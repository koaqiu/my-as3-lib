package xBei.Net{
	//import com.adobe.serialization.json.JSON;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.net.URLLoaderDataFormat;
	import flash.system.Capabilities;

	/**
	 * JSON加载器
	 * @author KoaQiu
	 * @see xBei.Events.DataLoaderEvent
	 */
	public class JSONLoader extends DataLoader {
		private var _jsonData:*;
		/**
		 * JSON对象，加载成功后有效
		 */
		public function get JSONObject():*{
			if (_jsonData == null) {
				return null;
			}else {
				return _jsonData;
			}
		}
		private var _isImg:Boolean;
		override public function GetImage(pUrl:*, options:Object=null, callBack:Function=null):void
		{
			this._isImg = true;
			super.GetImage(pUrl, options, callBack);
		}
		
		override protected function runCallBackFunc(resultData:*):void{
			if(this.dataFormat == URLLoaderDataFormat.TEXT){
				resultData['resultData'] = this.JSONObject;
			}else{
				resultData['resultData'] = this.data;
			}
			super.runCallBackFunc(resultData);
		}
		override protected function getOption(pName:String, dv:*):*{
			if(pName == 'dataFormat'){
				return this._isImg ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
			}
			return super.getOption(pName, dv);
		}
		override protected function OnDataLoaded():void {
			if(this.dataFormat == URLLoaderDataFormat.TEXT){
				try {
					this._jsonData = decode(this.ResultData);
					
				//}catch(error:ArgumentError){
				//	this._jsonData = {
				//		'success':false,
				//		'message':'参数错误'
				//	}
				//	super.OnError("参数错误： \n"+String(error)+"\n\n"+String(super.ResultData));
				//	return;
				}catch (error:Error) {
					this._jsonData = {
						'success':false,
						'message':'解析失败'
					}
					super.OnError("解析失败！ \n" + String(error) + "\n\n" + error.getStackTrace() + "\n\n" + String(super.ResultData));
					return;
				}
			}
			super.OnDataLoaded();
		}
		protected function encode( o:Object ):String {
			var player_version:int = int(Capabilities.version.substr(3).split(',')[0]);
			if(player_version >=11){
				return glo.EncodeJson(o);
			}else{
				return com.adobe.serialization.json.JSON.encode(o);
			}
		}
		protected function decode( s:String ):* {
			//trace(Capabilities.version);
			var player_version:int = int(Capabilities.version.substr(3).split(',')[0]);
			if(player_version >=11){
				return glo.DecodeJson(s);
			}else{
				return com.adobe.serialization.json.JSON.decode(s);
			}
			//return JSON.decode(s);
		}
	}//end class
}