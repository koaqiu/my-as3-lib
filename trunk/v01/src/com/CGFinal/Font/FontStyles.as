package com.CGFinal.Font {
	/**
	 * 字体样式枚举
	 * @author KoaQiu
	 */
	public class FontStyles	{
		/**
		 * 正常
		 */
		public static const REGULAR:uint = 0x0;
		/**
		 * 粗体
		 */
		public static const BOLD:uint = 0x1;
		/**
		 * 斜体
		 */
		public static const ITALIC:uint = 0x2;
		/**
		 * 粗体+斜体
		 */
		public static const BOLD_ITALIC:uint = BOLD & ITALIC;
	}

}
