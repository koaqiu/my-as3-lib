package xBei.Helper{
	import flash.utils.ByteArray;

	/**
	 * 一组字符串扩展方法
	 * @author KoaQiu
	 * 
	 */
	public class StringHelper{
		/**
		 * 两字符串是否相等，忽略大小写
		 * @param	str
		 * @return
		 */
		public static function Equals(str1:String,str2:String):Boolean {
			var reg:RegExp = new RegExp("^" + str2 + "$", "i");
			return reg.test(str1);
		}
		/**
		 * @author 25swf
		 * @blog http://www.25swf.com/
		 * @param myByteArray 被当成UTF8读取的gb2312字节数组   
		 */
		private static function Gb2312ToUtf8(myByteArray : ByteArray) : String {
			var tempByteArray : ByteArray = new ByteArray();
			for (var a:int = 1; a < myByteArray.length; a += 2) {
				if (myByteArray[a - 1] == 194)
					tempByteArray.writeByte(myByteArray[a]);
				else if (myByteArray[a - 1] == 195)
					tempByteArray.writeByte(myByteArray[a] + 64);
				else{
					//是英文数字
					tempByteArray.writeByte(myByteArray[a - 1]);
					tempByteArray.writeByte(myByteArray[a]);
				}
			}
			//重设游标
			tempByteArray.position = 0;
			return tempByteArray.readMultiByte(tempByteArray.bytesAvailable, "cn-bg");
		}
		/**
		 * 是否为空字符串
		 * 如果都是空白字符也是空
		 * @param	str
		 * @return	Boolean
		 */
		public static function IsNullOrEmpty(str:*):Boolean {
			if(str == null || str == undefined){
				return true;
			}else {
				return String(str).replace(/\s/ig,"").length == 0;
			}
		}
		/**
		 * 格式化输出
		 * @param	text	输入文本，包括格式化信息
		 * @param	...args	输入参数（可选）
		 * @return
		 */
		public static function Format(text:*, ...args):String {
			if (text == null) {
				return "";
			}
			var str:String = String(text);
			//var ms:Array = str.match(/{\d+}/);
			for (var i:int = 0; i < args.length; i++) {
				var reg:RegExp = new RegExp("\\{" + String(i) + "\\}", "ig");
				str = str.replace(reg, String(args[i]));
				//str = str.replace("{" + String(i) + "}", String(args[i]));
			}
			return str;
		}
		/**
		 * Substitutes keywords in a string using an object/array. Removes undefined keywords and ignores escaped keywords.
		 * @param text
		 * @param object
		 * @param regexp
		 * @return 
		 * 
		 */		
		public static function Substitute(text:String,object:Object, regexp:RegExp):String{
			return text.replace(regexp || (/\\?\{([^{}]+)\}/g), function(match:*, name:String):String{
				if (match.charAt(0) == '\\') return match.slice(1);
				return (object[name] != null) ? object[name] : '';
			});
		}
		/**
		 * 移除字符串头尾的空白字符 
		 * @param input
		 * @return 
		 * 
		 */
		public static function Trim(input:String):String{
			return LeftTrim(RightTrim(input));
		}
		/**
		 * 移除字符串左边的空白字符 
		 * @param input
		 * @return 
		 * 
		 */
		public static function LeftTrim(input:String):String{
			var size:Number = input.length;
			for(var i:Number = 0; i < size; i++){
				if(input.charCodeAt(i) > 32){
					return input.substring(i);
				}
			}
			return "";
		}
		/**
		 * 移除字符串右边的空白字符 
		 * @param input
		 * @return 
		 * 
		 */
		public static function RightTrim(input:String):String{
			var size:Number = input.length;
			for(var i:Number = size; i > 0; i--){
				if(input.charCodeAt(i - 1) > 32){
					return input.substring(0, i);
				}
			}
			
			return "";
		}
		
		//////////////////////
		public static function Length(str:String):uint {
			var pattern:RegExp = /[^\x00-\xff]/g;
			if (pattern.test(str) == false) {
				return str.length;
			}
			var cl:int = str.match(/[^\x00-\xff]/g).length;
			var el:int = str.length - cl;
			return el + cl + cl;
		}
		public static function getFileType(fileData : ByteArray) : String {
			fileData.position = 0;
			var b0 : int = fileData.readUnsignedByte();
			var b1 : int = fileData.readUnsignedByte();
			var fileType : String = "ANSI";
			if (b0 == 0xFF && b1 == 0xFE) {
				fileType = "Unicode";
			}else if (b0 == 0xFE && b1 == 0xFF) {
				fileType = "Unicode big endian";
			}else if (b0 == 0xEF && b1 == 0xBB) {
				fileType = "UTF-8";
			}
			return fileType;
		}
		/**
		 * 转换乱码
		 * @param	inStr
		 * @return
		 */
		public static function GetString(inStr:String):String {
			//首先把乱码按utf-8的编码写进ByteArray里
			var myByteArray : ByteArray = new ByteArray();
			myByteArray.writeUTFBytes(inStr);
			//还原成可读的字符
			return(Gb2312ToUtf8(myByteArray));
		}
		/**
		 * 格式化数值，添加前（后）导“0” 
		 * @param v
		 * @param length
		 * @param mode		Boolean	值为true则把“0”添加到后面
		 * @param Prefix
		 * @return 
		 * 
		 */
		public static function FormatNumber(v:int,length:int=0,mode:Boolean=false,Prefix:String ='0'):String{
			if(length == 0 || v.toString().length >= length){
				return v.toString();
			}else{
				var l:int = length - v.toString().length;// Math.floor(v / 10) - 1;
				var str:String = v.toString();
				for(var i:int =0;i<l;i++){
					if(mode){
						str= str + Prefix;
					}else{
						str=Prefix + str;
					}
				}
				return str;
			}
		}
		/**
		 * 格式化数值，添加前（后）导“0” 
		 * @param v
		 * @param length
		 * @param mode		Boolean	值为true则把“0”添加到后面
		 * @param Prefix
		 * @return 
		 * 
		 */
		public static function FormatS(s:String,length:int=0,mode:Boolean=false,Prefix:String ='0'):String{
			if(length == 0 || s.length >= length){
				return s;
			}else{
				var l:int = length - s.length;
				var str:String = s;
				for(var i:int =0;i<l;i++){
					if(mode){
						str= str + Prefix;
					}else{
						str=Prefix + str;
					}
				}
				return str;
			}
		}
	}
}