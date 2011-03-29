package xBei.Manager{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.ui.Mouse;

	/**
	 * 光标管理器 
	 * @author KoaQiu
	 */
	public final class CursorManager{
		
		private static var _inc:CursorManager = new CursorManager();
		
		public static function get Inc():CursorManager{
			return _inc;
		}
		
		private var _cursorList:Object;
		private var _currentCursor:DisplayObject;
		private var _stage:Stage;
		
		/**
		 * @private 
		 */
		function CursorManager(){
			_cursorList = {};
		}
		private function _showCursor(name:String):void{
			if(_currentCursor != null){
				_stage.removeChild(_currentCursor);
			}
			_currentCursor = _cursorList[name];
			_stage.addChild(_currentCursor);
			_currentCursor.x = _stage.mouseX;
			_currentCursor.y = _stage.mouseY;
		}
		private function _hide():void{
			if(_currentCursor == null){return;}
			_stage.removeChild(_currentCursor);
			_currentCursor = null;
		}
		private function _move():void{
			if(_currentCursor == null){return;}
			_currentCursor.x = _stage.mouseX;
			_currentCursor.y = _stage.mouseY;
		}
		
		/**
		 * 初始化 
		 * @param stage
		 */
		public static function Init(stage:Stage):void{
			if(stage == null){
				throw new Error('xBei.Manager.CursorManger 初始化失败！stage不可用。');
			}else{
				_inc._stage = stage;
			}
		}
		/**
		 * 添加光标 
		 * @param name		光标名称；如果重复就会覆盖
		 * @param cursor	添加到管理器的光标
		 * @see #Init()
		 * @see #ShowCursor()
		 */
		public static function AddCursor(name:String,cursor:DisplayObject):void{
			_inc._cursorList[name] = cursor;
		}
		/**
		 * 显示自定义光标 
		 * @param name
		 * @see #Init()
		 * @see #AddCursor()
		 */
		public static function ShowCursor(name:String):void{
			if(_inc._stage == null){
				throw new Error('没有初始化');
			}else if(_inc._cursorList[name] is DisplayObject){
				Mouse.hide();
				_inc._showCursor(name);
			}
		}
		/**
		 * 光标跟随
		 * @see #ShowCursor()
		 * @see #Hide()
		 */
		public static function MoveCursor():void{
			if(_inc._stage != null){
				_inc._move();
			}
		}
		/**
		 * 隐藏自定义光标，显示标准光标
		 * @see #ShowCursor() 
		 */
		public static function Hide():void{
			Mouse.show();
			if(_inc._stage != null){
				_inc._hide();
			}
		}
	}
}