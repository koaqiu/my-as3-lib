package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.utils.*;
	
	import xBei.Interface.IDispose;

	/**
	 * 用于实现全局数据共享
	 * 使用方法：glo.bal.yourdata=value;
	 * @author KoaQiu
	 * 
	 */
	public class glo {
		/**
		 * 用于实现全局数据共享
		 * 使用方法：glo.bal.yourdata=value;
		 * 默认值：blo.bal.IsLocal = true;
		 */
		public static  var bal:Object = {
			IsLocal : true
		};
		
		/**
		 * 是否为空 
		 * @param test
		 * @return 
		 * 
		 */
		public static function IsNullOrUndefined(test:*):Boolean {
			return test == null || test == undefined;
		}
		/**
		 * 根据当前语言跳转
		 * @param mc
		 * 
		 */
		public static function GotoByLanguage(mc:MovieClip):void{
			//trace('GotoByLanguage',mc,mc.currentFrame,mc.currentFrameLabel);
			mc.stop();
			mc.addEventListener(Event.ENTER_FRAME,function(e:Event):void{
			//var t:Timer = new Timer(50);
			//t.addEventListener(TimerEvent.TIMER,function(e:Event):void{
				//trace('GotoByLanguage',mc,mc.currentFrame,mc.currentFrameLabel);
				try{
					if(mc.currentLabel != Capabilities.language){
						mc.gotoAndStop(Capabilities.language);
					}
				}catch(err:Error){
					if(mc.currentFrame != 1){
						mc.gotoAndStop(1);
					}
				}
				//mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
			});
			//t.start();
		}
		//属性
		/**
		 * 返回操作系统信息 
		 * @return 
		 * 
		 */
		public static function get OS():String {
			return Capabilities.os;
		}
		/**
		 * 当前是否运行在Mac OSX系统下 
		 * @return 
		 * 
		 */
		public static function get IsMac():Boolean {
			return OS.toLocaleLowerCase().indexOf("mac") == 0;
		}
		/**
		* 是否在Dir环境下
		*/ 
		public static function get IsDir():Boolean {
			return Capabilities.playerType == "DirectorXtra";
		}
		//方法
		/**
		* 向Dir发送命令
		*/ 
		public static function CommandDir(cmdl:String):void {
			if(IsDir){
				navigateToURL(new URLRequest(cmdl));
			}else{
				trace('glo.CommandDir:',cmdl);
			}
		}
		/**
		 * 销毁可视对象
		 * @param item
		 */
		public static function DisposeDisplayObject(item:*):void{
			if(item is Loader){
				(item as Loader).unloadAndStop();
			}
			if(item is IDispose){
				(item as IDispose).dispose();
			}else if(item.hasOwnProperty('dispose')){
				try{
					item['dispose']();
				}catch(err:Error){}
			}
		}
		/**
		* 模拟旧版getURL，自动判断Dir环境
		*/ 
		public static function GetUrl(url:String, window:String = ""):void {
			if (IsDir) {
				navigateToURL(new URLRequest("lingo:gotoNetPage \""+url+"\""));
			}else {
				navigateToURL(new URLRequest(url));
			}
		}
		/**
		 * 安全的转换布尔类型
		 * @param s
		 * @param dv
		 * @return 
		 * 
		 */
		public static function ToBoolean(s:*,dv:Boolean):Boolean{
			if(IsNullOrUndefined(s)){
				return dv;
			}else{
				try{
					return Boolean(s);
				}catch(err:Error){
				}
				return dv;
			}
		}
		/**
		 * 安全的转换数值类型
		 * @param s
		 * @param dv
		 * @return 
		 * 
		 */
		public static function ToNumber(s:*,dv:Number):Number{
			if(IsNullOrUndefined(s)){
				return dv;
			}else{
				try{
					return Number(s);
				}catch(err:Error){
				}
				return dv;
			}
		}
		/**
		 * 根据类名创建对象 
		 * @param className
		 * @return 
		 */
		public static function CreateObject(className:String):Object {
			return new (getDefinitionByName(className) as Class)();
		}
	}
}