package xBei.Manager{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	import flash.utils.getDefinitionByName;
	
	import xBei.Helper.ImageHelper;
	import xBei.Net.Uri;
	import xBei.Net.XLoader;

	/**
	 * 光标管理器 
	 * @author KoaQiu
	 */
	public final class CursorManager{
		
		private static var _inc:CursorManager
		
		public static function get Inc():CursorManager{
			if(_inc == null){
				throw new Error('xBei.Manager.CursorManger 没有初始化');
			}
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
		public static function Init(stage:Stage = null):void{
			_inc = new CursorManager();
			if(stage != null){
				_inc._stage = stage;
			}else{
				_inc._stage = StageManager.Instance.Stage;
			}
		}
		/**
		 * 添加光标 
		 * @param name		光标名称；如果重复就会覆盖
		 * @param cursor	添加到管理器的光标
		 * @see #Init()
		 * @see #ShowCursor()
		 */
		public static function AddCursor(name:String, cursor:*, hotSpot:Point):void{
			if(cursor is BitmapData){
				_addBitemapDataCursor(name, cursor as BitmapData, hotSpot);
			}else if(cursor is Class){
				var cls:Class = cursor as Class;
				AddCursor(name, new cls(), hotSpot);
			}else if(cursor is DisplayObject){
				_addDisplayObjectCursor(name, cursor as DisplayObject, hotSpot);
			}else if(cursor is String){
				var str:String = String(cursor);
				Uri.Test(str, function(result:Object):void{
					if(result.success){
						_addUrlCursor(name, str, hotSpot);
					}else{
						var obj:Object = getDefinitionByName(str);
						AddCursor(name, obj, hotSpot);
					}
				});
			}
		}
		private static function _addUrlCursor(name:String, url:String, hotSpot:Point):void{
			var loader:XLoader = new XLoader();
			loader.Load(url, 30, null, function(loader:XLoader):void{
				_addDisplayObjectCursor(name, loader.content, hotSpot);
			});
		}
		private static function _addBitemapDataCursor(name:String, bd:BitmapData, hotSpot:Point):void{
			if(Mouse.supportsNativeCursor){
				var cu:MouseCursorData = new MouseCursorData();
				cu.hotSpot = hotSpot;
				cu.data = new Vector.<BitmapData>();
				cu.data.push(bd);
				Mouse.registerCursor(name, cu);
			}else{
				_addDisplayObjectCursor(name, new Bitmap(bd), hotSpot);
			}
		}
		private static function _addDisplayObjectCursor(name:String, dp:DisplayObject, hotSpot:Point):void{
			if(Mouse.supportsNativeCursor){
				var bd:BitmapData;
				if(dp.width > 32 || dp.height > 32){
					bd = ImageHelper.ScaleBitmap(dp, 32, 32);
				}else{
					bd = ImageHelper.GetBitmap(dp);
				}
				var mcd:MouseCursorData = new MouseCursorData();
				mcd.hotSpot = hotSpot;
				mcd.data = new Vector.<BitmapData>(1);
				mcd.data[0] = bd;
				Mouse.registerCursor(name, mcd);
				Inc._cursorList[name] = 'nativeCursor';
			}else{
				Inc._cursorList[name] = dp;
			}
		}
		/**
		 * 显示自定义光标 
		 * @param name
		 * @see #Init()
		 * @see #AddCursor()
		 */
		public static function ShowCursor(name:String):void{
			if(Mouse.supportsNativeCursor){
				Mouse.cursor = name;
			}else if(Inc._cursorList[name] is DisplayObject){
				Mouse.hide();
				Inc._showCursor(name);
			}
		}
		/**
		 * 光标跟随
		 * @see #ShowCursor()
		 * @see #Hide()
		 */
		public static function MoveCursor():void{
			if(!Mouse.supportsNativeCursor){
				Inc._move();
			}
		}
		/**
		 * 清除注册过的所有光标
		 */
		public static function ClearCursor():void{
			for(var k:* in Inc._cursorList){
				Mouse.unregisterCursor(k);
				delete Inc._cursorList[k];
			}
		}
		public static function RemoveCursor(name:String):void{
			Mouse.unregisterCursor(name);
			delete Inc._cursorList[name];
		}
		/**
		 * 隐藏自定义光标，显示标准光标
		 * @see #ShowCursor() 
		 */
		public static function Hide():void{
			Mouse.cursor = MouseCursor.AUTO;
			Mouse.show();
			Inc._hide();
		}
	}
}