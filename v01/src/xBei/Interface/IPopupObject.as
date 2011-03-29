package xBei.Interface
{
	/**
	 * 实现可弹出对象
	 * @author KoaQiu
	 * @see xBei.Manager.PopUpManager
	 */
	public interface IPopupObject{
		/**
		 * 弹出时调用 
		 * 
		 */
		function OnShow():void;
		/**
		 * 隐藏时调用 
		 * 
		 */
		function OnHide():void;
		/**
		 * 是否弹出 
		 * @return 
		 * 
		 */
		function get IsPopuped():Boolean;
		function set IsPopuped(v:Boolean):void;
	}
}