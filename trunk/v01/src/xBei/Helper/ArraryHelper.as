package xBei.Helper
{
	public final class ArraryHelper
	{
		public function ArraryHelper(c:pc)
		{
		}
		
		public static function HasItems(data:Object):Boolean{
			return data != null && data is Array && (data as Array).length > 0; 
		}
	}
}

class pc{}