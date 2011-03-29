package {
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class ExMath{
		function ExMath() { }
		/**
		 * 返回由参数 val 指定的数字或表达式的下限值
		 * @param	x
		 * @param	length	保留的小数位
		 * @return
		 */
		public static function floor(x:Number, length:int = 0):Number {
			if(length>0){
				var zs:Number = Math.floor(x);
				var xiaos:Number = x - zs;
				var beishu:Number = Math.pow(10, length);
				return zs + Math.floor(xiaos * beishu) / beishu;
			}else {
				return Math.floor(x);
			}
		}
	}

}
