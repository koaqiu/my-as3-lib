package xBei.Net
{
	import flash.utils.ByteArray;

	public final class PostFileItem
	{
		public var Data:ByteArray;
		public var FileName:String;
		public var Field:String;
		
		public function PostFileItem(data:ByteArray)
		{
			this.Data = data;
			this.Field = 'Filedata';
		}
	}
}