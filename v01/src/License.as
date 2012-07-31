package {

	public final class License {
		
		public function License(c:pc){
			
		}
		public static function Encode(str:String, sn_len:int = 16):String{
			var l:License = new License(new pc());
			return l._encode(str,sn_len);
		}
		private function add2(x:int, y:int):int {
			return ((x + y) & 4294967295);
		}

		private function f(q:int, a:int, b:int, x:int, s:int, t:int):int {
			a = add2(add2(a, q), add2(x, t));
			return (add2((a << s) | (a >>> (32 - s)), b));
		}

		private function _encode(str:String,sn_len:int):String{
			var ff:Array = [
				function(a:int, b:int, c:int, d:int, x:int, s:int, t:int):int {
					return (f((b & c) | ((~b) & d), a, b, x, s, t));
				}, 
				function(a:int, b:int, c:int, d:int, x:int, s:int, t:int):int {
					return (f((b & d) | (c & (~d)), a, b, x, s, t));
				}, 
				function(a:int, b:int, c:int, d:int, x:int, s:int, t:int):int {
					return (f((b ^ c) ^ d, a, b, x, s, t));
				}, 
				function(a:int, b:int, c:int, d:int, x:int, s:int, t:int):int {
					return (f(c ^ (b | (~d)), a, b, x, s, t));
				}
			];
			var bin:Array = [];
			var len:int =(str.length * 8);
			var i:int = 0;
			while (i < len) {
				bin[i >> 5]=bin[i >> 5] | ((str.charCodeAt(i >> 3) & 255) << (i % 32));
				i = i + 8;
			}
			bin[len >> 5] = bin[len >> 5] | (128 << (len % 32));
			bin[(((len + 64) >>> 9) << 4) + 14] = len;
			var a:Array = [0, 1, 5, 0];
			var b:Array = [1, 5, 3, 7];
			var s:Array = [[7, 12, 17, 22], [5, 9, 14, 20], [4, 11, 16, 23], [6, 10, 15, 21]];
			var t:Array = [[-680876936, -389564586, 606105819, -1044525330, -176418897, 1200080426, -1473231341, -45705983, 1770035416, -1958414417, -42063, -1990404162, 1804603682, -40341101, -1502002290, 1236535329], [-165796510, -1069501632, 643717713, -373897302, -701558691, 38016083, -660478335, -405537848, 568446438, -1019803690, -187363961, 1163531501, -1444681467, -51403784, 1735328473, -1926607734], [-378558, -2022574463, 1839030562, -35309556, -1530992060, 1272893353, -155497632, -1094730640, 681279174, -358537222, -722521979, 76029189, -640364487, -421815835, 530742520, -995338651], [-198630844, 1126891415, -1416354905, -57434055, 1700485571, -1894986606, -1051523, -2054922799, 1873313359, -30611744, -1560198380, 1309151649, -145523070, -1120210379, 718787259, -343485551]];
			var v:Array = [1732584193, -271733879, -1732584194, 271733878];
			i = 0;
			while (i < bin.length) {
				var old_v:Array = v.slice();
				var n:int = 0;
				while (n < 4) {
					var j:int = 0;
					while (j < 16) {
						v[(16 - j) % 4] = ff[n](
							v[(16 - j) % 4], 
							v[(17 - j) % 4], 
							v[(18 - j) % 4], 
							v[(19 - j) % 4], 
							bin[i + ((a[n] + (b[n] * j)) % 16)], 
							s[n][j % 4], 
							t[n][j]
						);
						j++;
					}
					n++;
				}
				n = 0;
				while (n < 4) {
					v[n] = add2(v[n], old_v[n]);
					n++;
				}
				i = i + 16;
			}
			var sn:String = "";
			i = 1;
			while (i <= sn_len) {
				var x:Number = (((Math.sin(v[0]) * sn_len) + (Math.sin(v[1]) * i)) * Math.sin((v[2] * sn_len) + (v[3] * i)));
				sn = sn + (int(Math.abs(x) * (8 << (i % 16))) % 10).toString();
				i++;
			}
			return (sn);
		}
	}//end class
}
class pc{}