package xBei.Helper{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.ByteArray;
	
	//import mx.graphics.codec.PNGEncoder;

	/**
	 * 一组图形处理的静态方法 
	 * @author KoaQiu
	 */
	public class ImageHelper{
		/**
		 * 位图转字节 
		 * @param bit	输入位图
		 * @param q		编码质量
		 * @return 
		 * 
		 */
		public static function GetByteData(bit:BitmapData,q:int=90):ByteArray {
			var _encoder:JPGEncoder = new JPGEncoder(q);
			return _encoder.encode(bit);
		}
		/**
		 * 得到PNG格式的图片数据
		 * @param bit
		 * @return 
		 */
		public static function GetPNGImageData(bit:BitmapData):ByteArray {
			//var _encoder:PNGEncoder = new PNGEncoder();
			return PNGEncoder.encode(bit);
		}
		/**
		 * 从二进制数据中读取位图
		 * @param data
		 * @param callBack	读取成功以后返回，function(bitmap:Bitmap):void
		 */		
		public static function BtyesToBitmap(data:ByteArray,callBack:Function):void{
			var bitmapData:BitmapData;
			var loader : Loader = new Loader();

			function getBitmapData(e:Event):void {
				var content:* = loader.content;
				bitmapData = new BitmapData(content.width,content.height,true,0x00000000);
				var matrix:Matrix = new Matrix();
				bitmapData.draw(content, matrix,null,null,null,true);
				callBack(new Bitmap( bitmapData ,'auto',true));
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, getBitmapData);
			loader.loadBytes(data);
		}
		/**
		 * 从可显示对象抓取图像
		 * @param	sr	源对象
		 * @param	rect	要抓取的区域，默认是null即全部区域
		 * @return	成功则返回 BitmapData
		 */ 
		public static function GetBitmap(sr:DisplayObject, rect:Rectangle = null):BitmapData {
			if (rect == null) {
				rect = new Rectangle(0, 0, sr.width, sr.height);
			}
			if(rect.width == 0 || rect.height == 0){
				return null;
			}
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height ,true, 0x00ffffff);
			var m:Matrix = new Matrix();
			bitmapData.draw(sr, new Matrix(1, 0, 0, 1, -rect.x, -rect.y)); //将bitmapData的注册点放在截图的起点39,99
			return bitmapData;
		}
		/**
		 * 得到适应容器的尺寸，会自动按比例缩放，并且进行对齐<br/>
		 * Ver:2.0
		 * @update	2010/07/20
		 * @version	2.0
		 * @param inputWidth		输入宽度
		 * @param inputHeight		输入高度
		 * @param containerWidth	容器宽度
		 * @param containerHeight	容器高度
		 * @param location			位置、对齐
		 * <p>
		 * 0（默认值） - 水平垂直都居中<br/>
		 * 0x01-水平左
		 * 0x03-水平居中
		 * 0x07-水平右<br/>
		 * 0x10-垂直顶部
		 * 0x30-垂直居中
		 * 0x70-垂直底部<br/>
		 * 2位16进制数，低位表示水平，高位表示垂直，如果是0表示使用默认值（居中）
		 * </p>
		 * @return 
		 */
		public static function TestRect(inputWidth:Number, 
										inputHeight:Number, 
										containerWidth:Number, 
										containerHeight:Number, 
										location:int = 0):Rectangle {
			if (inputHeight == 0 || inputWidth == 0 || 
				containerHeight == 0 || containerWidth == 0) {
				throw new Error('TestRect 参数非法！');
			}
			
			if (inputWidth == containerWidth && inputHeight == containerHeight) {
				return new Rectangle(0, 0, inputWidth, inputHeight);
			}
			var r:Rectangle;
			var _scale:Number = inputWidth / inputHeight;
			var _rect_scale:Number = containerWidth / containerHeight;
			var end_w:Number = inputWidth;
			var end_h:Number = inputHeight;
			
			if (inputWidth < containerWidth && inputHeight < containerHeight) {
				r = new Rectangle(0, 0, inputWidth, inputHeight);
				//trace('元素图片比目标文件小！');
			}else if(location >= 0x100){
				if (_scale > _rect_scale) {
					end_h = containerHeight;
					end_w = end_h * _scale;
				}else{
					end_w = containerWidth;
					end_h = end_w / _scale;
				}
				r = new Rectangle(0, 0, end_w, end_h);
			}else{
				if (_scale > _rect_scale) {
					end_w = containerWidth;
					end_h = end_w / _scale;
				} else {
					end_h = containerHeight;
					end_w = end_h * _scale;
				}
				r = new Rectangle(0, 0, end_w, end_h);
			}
			//对齐
			if(location == 0){
				location = 0x33;
			}else if(location < 0x10){
				location |= 0x30;
			}else if((location & 0xf) == 0){
				location |= 0x03;
			}
			if((location & 0x70) == 0x70){
				r.y = containerHeight - r.height;
			}else if((location & 0x30) == 0x30){
				r.y = (containerHeight - r.height) / 2;
			}else if((location & 0x10) == 0x10){
				r.y = 0;
			}else{
				r.y = (containerHeight - r.height) / 2;
			}
			if((location & 0x07) == 0x07){
				r.x = containerWidth - r.width;
			}else if((location & 0x03) == 0x03){
				r.x = (containerWidth - r.width)/2;
			}else if((location & 0x01) == 0x01){
				r.x = 0;
			}else{
				r.x = (containerWidth - r.width)/2;
			}
			return r;
		}
		
		/**
		 * 缩放位图 
		 * @param source	输入源
		 * @param width		目标宽度
		 * @param height	目标高度
		 * @param iw		
		 * @param ih
		 * @return 
		 */
		public static function ScaleBitmap(source:DisplayObject, width:Number, height:Number,iw:Number=0,ih:Number=0):BitmapData {
			var s1:Number = source.scaleX;
			var s2:Number = source.scaleY;
			source.scaleX = source.scaleY = 1;
			if (iw == 0) { iw = source.width; }
			if (ih == 0) { ih = source.height; }
			
			var toSize:Rectangle = TestRect(source.width, source.height, width, height);
			var scaleX:Number = toSize.width / source.width;
			var scaleY:Number = toSize.height / source.height;
			var bd:BitmapData = new BitmapData(toSize.width, toSize.height, true, 0x00ffffff);
			var m:Matrix = new Matrix();
			//m.translate(iw / 2, ih / 2);
			//m.scale(scaleX, scaleY);
			
			bd.draw(source, m,null,null,null,true);
			source.scaleX = s1;source.scaleY = s2;
			return bd;
		}
		
		/**
		 * 绘制网格线
		 * @param g
		 * @param rect		绘制范围
		 * @param styles	网格线的样式，数组
		 */		
		public static function DrawGridLine(g:Graphics, rect:Rectangle, styles:Array = null):void{
			//校验，step，color为必要属性
			if(style != null && styles.length > 0){
				styles = styles.filter(function(item:Object, index:int, arr:Array):Boolean{
					if(item.hasOwnProperty('step') &&
						item.hasOwnProperty('color')){
						try{
							item.step = uint(item.step);
							item.color = uint(item.color);
						}catch(err:Error){
							return false;
						}
						
						if(item.hasOwnProperty('alpha')){
							try{
								item.alpha = Number(item.alpha);
							}catch(err:Error){
								item.alpha = 1;
							}
						}else{
							item.alpha = 1;
						}
						if(item.hasOwnProperty('thickness')){
							try{
								item.thickness = Number(item.thickness);
							}catch(err:Error){
								item.thickness = 0;
							}
						}else{
							item.thickness = 0;
						}
						return true;
					}
					return false;
				});
			}
			if(styles == null || styles.length == 0){
				styles = [{
					'step':10,
					'color':0xeeeeee,
					'alpha':1,
					'thickness':0
				},{
					'step':50,
					'color':0xcccccc,
					'alpha':1,
					'thickness':0
				},{
					'step':100,
					'color':0xcccccc,
					'alpha':1,
					'thickness':2
				}];
			}
			
			var style:Object = styles[0];
			
			var v:int, i:int, isc:Boolean;
			var step:int;
			if(styles.length > 1){
				step = MathHelper.GreatestCommonDivisor(function():Array{
					var steps:Array = [];
					for(var i:int = 0; i < styles.length; i++)
						steps.push((styles[i].step));
					return steps;
				});
			}else{
				step = style.step;
			}
			trace('步进', step);
			//横线
			for(v = rect.top + style.step; v < rect.bottom; v++){
				for(i = styles.length - 1; i >= 0; i--){
					//trace(v, '%', styles[i].step, '=', v % styles[i].step == 0);
					if((v % styles[i].step) == 0){
						//trace('L', v, styles[i].color.toString(16));
						g.lineStyle(styles[i].thickness, styles[i].color,styles[i].alpha);
						g.moveTo(rect.left, v);
						g.lineTo(rect.right, v);
						break;
					}
				}
			}
			//g.lineStyle(style.thickness, style.color,style.alpha);
			for(v = rect.left + style.step; v < rect.right; v++){
				for(i = styles.length - 1; i >= 0; i--){
					//trace(v, '%', styles[i].step, '=', v % styles[i].step);
					if(v % styles[i].step == 0){
						g.lineStyle(styles[i].thickness, styles[i].color,styles[i].alpha);
						g.moveTo(v, rect.top);
						g.lineTo(v, rect.bottom);
						break;
					}
				}
			}
			g.endFill();
		}
		/**
		 * 垂直翻转图片
		 * @param bt
		 * @return 
		 */
		public static function FlipVertical(bt:BitmapData):BitmapData {
			var bmd:BitmapData = new BitmapData(bt.width, bt.height, true, 0x00000000);
			bt.lock();
			for (var xx:int = 0; xx<bt.width; xx++) {
				for (var yy:int = 0; yy<bt.height; yy++) {
					bmd.setPixel32(xx, bt.height-yy-1, bt.getPixel32(xx,yy));
				}
			}
			bt.unlock();
			bt.dispose();
			return bmd;
		}
		/**
		 * 水平翻转图片
		 * @param bt
		 * @return 
		 */
		public static function FlipHorizontal(bt:BitmapData):BitmapData {
			var bmd:BitmapData = new BitmapData(bt.width, bt.height, true, 0x00000000);
			for (var yy:int = 0; yy<bt.height; yy++) {
				for (var xx:int = 0; xx<bt.width; xx++) {
					bmd.setPixel32(bt.width-xx-1, yy, bt.getPixel32(xx,yy));
				}
			}
			bt.dispose();
			return bmd;
		}
	}
}