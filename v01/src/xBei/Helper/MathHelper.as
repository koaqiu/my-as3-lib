package xBei.Helper {
	import mx.effects.Fade;

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
		public static function Random(max:Number, min:Number):Number{
			return Math.random() * (max - min) + min;
		}
		/**
		 * 四舍五入，保留小数
		 * @param x
		 * @param length	保留的小数位数
		 * @return 
		 */
		public static function round(x:Number, length:int = 0):Number{
			if(length > 0){
				var beishu:Number = Math.pow(10, length);
				return Math.round(x * beishu) / beishu;
			}else{
				return Math.round(x);
			}
		}
		
		/**
		 * 求最大公约数
		 * @param args 2个以上正整数，
		 * 或者只有一个正整数数组参数，
		 * 或者一个返回正整数数组的无参函数（function(void):Array;）
		 * @return 
		 */
		public static function GreatestCommonDivisor(...args):uint{
			if(args.length == 1)
				if(args[0] is Array) args = args[0];
				else if(args[0] is Function) args = args[0]();
			
			if(args.length < 2)throw new ArgumentError('必需要有两个正整数参数！');
			var nums:Array = [];
			var i:int;
			for(i = 0; i < args.length; i++){
				try{
					nums.push(uint(args[i]));
				}catch(err:Error){
					
				}
			}
			if(nums.length < 2)throw new ArgumentError('必需要有两个正整数参数！');
			var pnc:int = 0;
			var pn:int = 0;
			for(i = 0; i < nums.length; i++){
				if(IsPrimeNumber(nums[i])) {
					if(pnc == 0) pn = nums[i];
					pnc++;
				}
				//有两个以上素数 直接返回 1
				if(pnc > 1) return 1;
			}
			var num:uint = Math.min.apply(null, nums);
			//有素数且不是最小 直接返回 1
			if(pn > 0 && num != pn)return 1;
			for(var n:uint = num; n >= 2; n--){
				for(i = 0; i < nums.length; i++){
					if(nums[i] % n > 0){
						break;
					}
				}
				if(i == nums.length){
					return n;
				}
			}
			return 1;
		}
		/**
		 * 是否是素数
		 * @param v		传入时请转换成正整数
		 * @return 
		 */		
		public static function IsPrimeNumber(v:uint):Boolean{
			//1、排除偶数
			if(v <= 3)return true;
			else if(v % 2 === 0)return false;
			var q:Number = v / 2;
			if(q === Math.floor(q)) return false;
			for(var i:int = 3; i < q; i++){
				if(v % i === 0){
					return false;
				}
			}
			return true;
		}
	}
}
class pc{}