package xBei.Net{
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
		override protected function runCallBackFunc(resultData:*):void{
			//trace('JSONLoader.runCallBackFunc');
			if(this.dataFormat == URLLoaderDataFormat.TEXT){
				resultData['resultData'] = this.JSONObject;				
			}
			super.runCallBackFunc(resultData);
		}
		override protected function OnDataLoaded():void {
			if(this.dataFormat == URLLoaderDataFormat.BINARY){
				super.OnDataLoaded();
			}else{
				try {
					this._jsonData = decode(this.ResultData);
					super.OnDataLoaded();
				}catch(error:ArgumentError){
					//trace('参数错误：',error.toString());
					super.OnError("参数错误： \n"+String(error)+"\n\n"+String(super.ResultData));
					this._jsonData = {
						'success':false,
						'message':'参数错误'
					}
				}catch (error:Error) {
					//trace('错误！',error, this.ResultData);
					super.OnError("解析失败！ \n"+String(error)+"\n\n"+String(super.ResultData));
					this._jsonData = {
						'success':false,
						'message':'解析失败'
					}
				}
			}
		}
		protected function encode( o:Object ):String {
			//var player_version:int = int(Capabilities.version.substr(3).split(',')[0]);
			//if(player_version >=11){
			//	return glo.EncodeJson(o);
			//}else{
				return com.adobe.serialization.json.JSON.encode(o);
			//}
		}
		protected function decode( s:String ):* {
			//trace(Capabilities.version);
			//var player_version:int = int(Capabilities.version.substr(3).split(',')[0]);
			//if(player_version >=11){
			//	return glo.DecodeJson(s);
			//}else{
				return com.adobe.serialization.json.JSON.decode(s);
			//}
			//return JSON.decode(s);
		}
	}
}