package xBei.iterator
{
	public class NullIterator implements IIterator
	{
		public function NullIterator()
		{
		}
		
		public function Reset():void
		{
		}
		
		public function Next():Object
		{
			return null;
		}
		public function get Current():Object{
			return null;
		}
		public function get HasNext():Boolean
		{
			return false;
		}
	}
}