package xBei.Helper
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import xBei.AnimationMode;

	public final class XSpriteHelper
	{
		public function XSpriteHelper(c:pc)
		{
		}
		
		public static function Setup():void{
			Sprite.prototype.GetFullPath = function():String{
				return getFullPath(this);
			}
		}
		public static function getFullPath(disp:DisplayObject):String{
			if(disp == null){
				return 'null';
			}else if(disp is Stage){
				return 'STAGE';
			}else if(disp.parent == null){
				return disp.name;
			}else{
				return StringHelper.Format('{0}.{1}', getFullPath(disp.parent), disp.name);
			}
		}
		//静态方法
		/**
		 * 修改对象的颜色 
		 * @param disp
		 * @param color
		 */
		public static function ChangeColor(disp:DisplayObject, color:int):void{
			if(color == -1){
				disp.transform.colorTransform = new ColorTransform();
			}else{
				var ct:ColorTransform = disp.transform.colorTransform;
				ct.color = color;
				disp.transform.colorTransform = ct;
			}
		}
		/**
		 * 隐藏
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接隐藏，1-渐显，2-闪白
		 * @param duration	动画时间（秒）
		 * @param callBack	function(disp):void;
		 * @param thisObject
		 * @return 
		 * @see xBei.AnimationMode
		 */
		public static function HideItByAni(disp:DisplayObject,aniMode:int = 0, duration:Number = .3, 
										   callBack:Function = null, thisObject:* = null):DisplayObject{
			TweenLite.killTweensOf(disp);
			if(duration > 10){
				duration /= 1000;
			}
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = false;
				if(disp.alpha == 1){
					disp.alpha = 0;
				}
				if(callBack != null){
					callBack.call(thisObject, disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_OUT:
						TweenLite.to(disp, duration, {
							autoAlpha:0,
							onComplete:function():void{
								if(callBack != null){
									callBack.call(thisObject, disp);
								}
							}
						});
						break;
				}
			}
			return disp;
		}
		/**
		 * 显示
		 * @param disp
		 * @param aniMode	动画模式，默认值：0 直接显示，1-渐显，2-闪白
		 * @param duration	动画时间（秒）
		 * @param callBack	function(disp):void;
		 * @param thisObject
		 * @retrun
		 * @see xBei.AnimationMode
		 */
		public static function ShowItByAni(disp:DisplayObject, aniMode:int = 0, duration:Number = .3, 
										   callBack:Function = null, thisObject:* = null):DisplayObject{
			if(duration > 10){
				duration /= 1000;
			}
			TweenLite.killTweensOf(disp);
			if(aniMode == AnimationMode.DIRECT){
				disp.visible = true;
				if(disp.alpha == 0){
					disp.alpha = 1;
				}
				if(callBack != null){
					callBack.call(thisObject, disp);
				}
			}else{
				switch(aniMode){
					case AnimationMode.FADE_IN:
						TweenLite.to(disp, duration,{
							autoAlpha:1,
							onCompleteParams:[disp],
							onComplete:function(vd:DisplayObject):void{
								if(callBack != null){
									callBack.call(thisObject, vd);
								}
							}
						});
						break;
					case AnimationMode.FLASH_WHITE:
						TweenLite.to(disp, duration,{ 
							autoAlpha : 1,
							tint:0xffffff,
							onCompleteParams:[disp],
							onComplete:function(v:DisplayObject):void{
								TweenLite.to(v,.2,{tint:null});
								if(callBack != null){
									callBack.call(thisObject, v);
								}
							}
						});
						break;
				}
			}
			return disp;
		}//end function
		public static function GetSafeBounds(target:DisplayObject, targetCoordinateSpace:DisplayObject):Rectangle {
			if(target == null){
				throw new ArgumentError('target 不能为空（null）');
			}else if(targetCoordinateSpace == null){
				throw new ArgumentError('targetCoordinateSpace 不能为空（null）');
			}
			if(target.width == 0 || target.height == 0)
				return new Rectangle();
			
			return target.getBounds(targetCoordinateSpace);
		}
	}
}
class pc{}