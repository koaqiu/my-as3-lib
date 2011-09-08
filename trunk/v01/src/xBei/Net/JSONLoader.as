package xBei.Net{
	import com.adobe.serialization.json.JSON;
	
	import flash.net.URLLoaderDataFormat;

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
			trace('JSONLoader.runCallBackFunc');
			resultData['resultData'] = this.JSONObject;
			super.runCallBackFunc(resultData);
		}
		override protected function OnDataLoaded():void {
			trace('JSONLoader.OnDataLoaded');
			try {
				this._jsonData = decode(this.ResultData);
				super.OnDataLoaded();
			}catch(error:ArgumentError){
				trace('参数错误：',error.toString());
			}catch (error:Error) {
				super.OnError("解析失败！ \n"+String(error)+"\n\n"+String(super.ResultData));
				this._jsonData = {
					'success':false,
					'message':'解析失败'
				}
			}
		}
		protected function encode( o:Object ):String {
			return JSON.encode(o);
		}
		protected function decode( s:String ):* {
			return JSON.decode(s);
		}
	}
}