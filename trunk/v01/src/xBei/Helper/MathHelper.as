package xBei.Helper {

	public class MathHelper {
		public function MathHelper(c:pc) {
		}
		/**
		 * 返回由参数 x 指定的数字或表达式的下限值
		 * 下限值是小于等于指定数字或表达式的最接近的整数。
		 * @param	x
		 * @param	length	保留的小数位
		 * @return
		 */
		public static function floor(x:Number, length:int = 0):Number {
			if(length > 0){
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
class pc{}