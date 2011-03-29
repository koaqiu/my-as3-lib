package xBei.Interface {
	import flash.text.TextField;

	/**
	 * 字体管理
	 * @author KoaQiu
	 */
	public interface IFont {
		/**
		 * 字体ID
		 * @return
		 *
		 */
		function get fontID():String;
		/**
		 * 字体资源地址
		 * @return
		 *
		 */
		function get fontUrl():String;
		/**
		 * 字体名称
		 * @return
		 *
		 */
		function get fontName():String;
		/**
		 * 字体样式
		 * @return
		 *
		 */
		function get fontStyle():uint;
		/**
		 * 字体类型
		 * @return
		 *
		 */
		function get fontType():String;
		/**
		 * 是否下载
		 * @return
		 *
		 */
		function get IsDown():Boolean;
		/**
		 * 得到文本框
		 * @return
		 *
		 */
		function getTextField():TextField;
	}
}