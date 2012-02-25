package xBei.LivePreview{
	import adobe.utils.MMExecute;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.MovieClip;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;

	/**
	 * ...
	 * @author KoaQiu
	 */
	public class BasicLivePreview extends MovieClip {
		//fl.getDocumentDOM().selection[0].parameters[\"[NAME]\"].value
		public function BasicLivePreview() 	{
			var ct:ContextMenu = new ContextMenu();
			ct.hideBuiltInItems();
			this.contextMenu = ct;
		}
		public function get FileName():String {
			var str:String = "fl.getDocumentDOM().name";
			return MMExecute(str);
		}
		public function GetPValue(name:String):Object {
			var str:String = "fl.getDocumentDOM().selection[0]." + name + ";";
			return MMExecute(str);
		}
		public function GetValue(name:String):Object {
			var str:String = "fl.getDocumentDOM().selection[0].parameters[\"" + name + "\"].value;";
			return MMExecute(str);
		}
		public function SetPValue(name:String, v:Object):void {
			var str:String = "fl.getDocumentDOM().selection[0]." + name + "=";
			if (v is String) {
				str += "\""+v.toString()+"\"";
			}else if (v is Number || v is int || v is uint || v is Boolean) {
				str += v.toString();
			}else {
				str += "\""+v.toString()+"\"";
			}
			//trace('执行：',str);
			MMExecute(str);
		}
		public function SetValue(name:String, v:Object):void {
			var str:String = "fl.getDocumentDOM().selection[0].parameters[\"" + name + "\"].value=";
			if (v is String) {
				str += "'"+v.toString().replace(/\r/g,'\\r').replace(/\n/g,'\\n')+"'";
			}else if (v is Number || v is int || v is uint || v is Boolean) {
				str += v.toString();
			}else {
				str += "'"+v.toString()+"'";
			}
			//trace('执行：',str);
			MMExecute(str);
		}
		protected function GetBoolean(v:Object):Boolean {
			if (v == null){
				return false;
			}else {
				var s:String = v.toString();
				if (s == "0" || s.toLowerCase() == "false") {
					return false;
				}
				return true;
			}
		}
		public function SetValueExt(name:String, v:Object):void {
			var d:Object = {
				'vauleName':name,
				'data':v
			};
			var json:String = '';
			var player_version:int = int(Capabilities.version.substr(3).split(',')[0]);
			if(player_version >=11){
				json = glo.EncodeJson(d);
			}else{
				json = com.adobe.serialization.json.JSON.encode(d);
			}
			var str:String = "fl.getDocumentDOM().selection[0].parameters[\"CUIV\"].value=\"" + json + "\"";
			MMExecute(str);
		}
	}
	
}
