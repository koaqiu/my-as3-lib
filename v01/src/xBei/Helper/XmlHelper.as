package xBei.Helper {

	public class XmlHelper {
		
		public static function GetInt(xml:*,dv:int = 0):int{
			var str:String = StringHelper.Trim(xml.text().toString());
			if(str.length == 0){
				return dv;
			}else if(/^\d+$/.test(str)){
				return int(str);
			}else{
				return dv;
			}
		}
		public static function GetNumber(xml:*,dv:Number = 0.0):Number{
			var str:String = xml.text().toString();
			if(str.length == 0){
				return dv;
			}else if(/^[0123456789\.]+$/.test(str)){
				return Number(str);
			}else{
				return dv;
			}
		}
		public static function GetColor(xml:*,dv:uint = 0):uint{
			var str:String = xml.text().toString();
			if(str.length == 0){
				return dv;
			}else if(/^#\d{6}$/.test(str)){
				return  parseInt('0x'+str.substr(1),16);
			}else if(/^0x\d{6}$/.test(str)){
				return  parseInt(str,16);
			}else if(/^\d+$/.test(str)){
				return int(str);
			}else{
				return dv;
			}
		}
		public static function GetBoolean(xml:*, dv:Boolean):Boolean{
			var str:String = xml.text().toString().toLowerCase();
			if(str.length == 0){
				return dv;
			}else if(str == '1' || str == 'true'){
				return true;
			}else if(str == '0' || str == 'false'){
				return false;
			}else{
				return dv;
			}
		}
		
		/**
		 * 读取节点属性（Number）
		 * @param xml	节点
		 * @param name	属性名称
		 * @param dv	默认值
		 * @return 返回属性值
		 */
		public static function GetAttribeNumber(xml:*, name:String, dv:Number):Number{
			var str:String = xml.attribute(name).toString();
			if(str.length == 0){
				return dv;
			}else if(/^[0123456789\.]+$/.test(str)){
				return Number(str);
			}else{
				return dv;
			}
		}
		/**
		 * 读取节点属性（Boolean）
		 * @param xml	节点
		 * @param name	属性名称
		 * @param dv	默认值
		 * @return 返回属性值
		 */
		public static function GetAttribeBoolean(xml:*, name:String, dv:Boolean):Boolean{
			var str:String = xml.attribute(name).toString();
			//trace('xxxxxxxxxxxxxxx',str,name);
			if(str.length == 0){
				return dv;
			}else if(str == '1' || str == 'true'){
				return true;
			}else if(str == '0' || str == 'false'){
				return false;
			}else{
				return dv;
			}
		}
	}
}