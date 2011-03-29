package com.CGFinal {
	import com.CGFinal.Controls.Skins.SkinItem;
	
	import flash.utils.getQualifiedClassName;

	/**
	 * 轻量级的组件基类
	 * @author KoaQiu
	 */
	public class LiteComponent extends BaseUI{
		protected var focusSkin:SkinItem;
		
		private var _width:Number=100;
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			if (_width != value) {
				this.SetSize(value, 0);
			}
		}
		private var _height:Number=100;
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			if (_height == value) { return; }
			this.SetSize(0, value);
		}
		
		protected var _inspector:Boolean = false;
		/**
         * @private (internal)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get componentInspectorSetting():Boolean {
			return _inspector;
		}
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set componentInspectorSetting(value:Boolean):void {
			_inspector = value;
			if (_inspector) {
				beforeComponentParameters();
			} else {
				if (_initDatas != null) {
					for (var key:Object in _initDatas) {
						var arr:Array = _initDatas[key] as Array;
						if (arr != null && arr.length > 1) {
							arr.pop();
							this[key] = arr.pop();
							while (arr.length > 0) {
								arr.pop();
							}
							delete _initDatas[key];
						}
					}
				}
				afterComponentParameters();	
			}
		}
		public function LiteComponent() {
			super();
			this.SetSize(this.width, this.height);
		}
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function beforeComponentParameters():void { 
			//trace(this, "do beforeComponentParameters"); 
		}
		
		private var _initDatas:Object;
		protected function addInitData(key:String, value:*):Boolean {
			if(_inspector){
				if (_initDatas == null) {
					_initDatas = { };
				}else if (_isNullOrUndefined(_initDatas[key])) {
					_initDatas[key] = [];
				}
				(_initDatas[key] as Array).push(value);
			}

			return _inspector;
		}
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function afterComponentParameters():void {
			//trace(this.name,".afterComponentParameters");
			//this.createChildren();
			
		}
		private function _isNullOrUndefined(o:*):Boolean{
			return o == null || o == undefined;
		}
		override protected function createChildren():void {
			//super.createChildren();
			//记录尺寸
			this._width = super.width;
			this._height = super.height;
			
			this.scaleX = 1;
			this.scaleY = 1;
			while (numChildren > 0) {
				removeChildAt(0);
				//break;
			}
			
			focusSkin = this.createObject("FocusRectSkin") as SkinItem;
			focusSkin.x = -1;
			focusSkin.y = -1;
			focusSkin.visible = false;
			
			this.addChild(focusSkin);
		}
		public function SetSize(pWidth:Number, pHeight:Number):void {
			var vc:Boolean = false;
			if(pWidth > 0){
				_width = pWidth;
				focusSkin.width = pWidth + 2;
				vc = true;
			}
			if(pHeight > 0){
				_height = pHeight;
				focusSkin.height = pHeight + 2;
				vc = true;
			}
			if (vc) {
				this.draw();
			}
		}
		
		protected function get isLivePreview():Boolean {
			if (parent == null) { return false; }
			var className:String;
			try {
				className = getQualifiedClassName(parent);
			} catch (e:Error) {}
			return (className == "fl.livepreview::LivePreviewParent");	
		}
	}

}