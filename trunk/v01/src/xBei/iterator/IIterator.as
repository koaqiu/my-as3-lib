package xBei.iterator
{
	public interface IIterator
	{
		function Reset():void;
		function Next():Object;
		function get Current():Object;
		function get HasNext():Boolean;			
	}
}