package xBei.Net{
	import com.adobe.serialization.json.JSON;

	/**
	 * JSON加载器
	 * @author KoaQiu
	 * @see xBei.Events.DataLoaderEvent
	 */
	public class JSONLoader extends DataLoader {
		private var _data:*;
		/**
		 * JSON对象，加载成功后有效
		 */
		public function get JSONObject():*{
			if (_data == null) {
				return null;
			}else {
				return _data;
			}
		}
		override protected function OnDataLoaded():Boolean {
			try {
				this._data = JSON.decode(super.ResultData);
				return super.OnDataLoaded();
			}catch (error:Error) {
				trace('发生错误！',super.data);
				super.OnError("解析失败！ \n"+String(error)+"\n\n"+String(super.ResultData));
				this._data={
					success:false,
					result:{
						message:'解析失败'
					}
				}
				return false;
			}
			return false;
		}
		protected function encode( o:Object ):String {
			return JSON.encode(o);
		}
		protected function decode( s:String ):* {
			return JSON.decode(s);
		}
	}
}