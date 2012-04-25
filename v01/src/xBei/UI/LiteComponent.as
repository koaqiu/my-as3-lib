package xBei.UI {
	import flash.utils.getQualifiedClassName;

	/**
	 * 轻量级的组件基类
	 * @author KoaQiu
	 * @version	0.2
	 */
	public class LiteComponent extends XSprite {
		private var _initDatas:Object;
		private var _inited:Boolean;
		private var _width:Number = 100;
		private var _height:Number = 100;
		/**
		 * @private
		 */
		protected var focusSkin:SkinItem;

		override public function get width():Number {
			return _width;
		}

		override public function set width(value:Number):void {
			if (_width != value) {
				this.SetSize(value, 0);
			}
		}

		override public function get height():Number {
			return _height;
		}

		override public function set height(value:Number):void {
			if (_height == value) {
				return;
			}
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
			return this._inspector;
		}
		/**
		 * @private (setter)
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		public function set componentInspectorSetting(value:Boolean):void {
			//trace(this,'.componentInspectorSetting',value);
			this._inspector = value;
			if (this._inspector) {
				this.beforeComponentParameters();
			} else {
				if (this._initDatas != null) {
					for (var key:Object in this._initDatas) {
						var arr:Array = this._initDatas[key] as Array;
						//trace('componentInspectorSetting after:',key, arr);
						if (arr != null && arr.length > 0) {
							//arr.pop();
							this[key] = arr.pop();
							//trace('the value=', x);
							while (arr.length > 0) {
								arr.pop();
							}
							delete this._initDatas[key];
						}
					}
				}
				this.afterComponentParameters();	
			}
		}

		/**
		 * 是否是编辑状态
		 * @return 
		 */
		protected function get isLivePreview():Boolean {
			if (parent == null) { return false; }
			var className:String;
			try {
				className = getQualifiedClassName(parent);
			} catch (e:Error) {}
			return (className == "fl.livepreview::LivePreviewParent");	
		}
		
		override protected function createChildren():void{
			var tw:Number = super.width;
			var th:Number = super.height;
			trace('组件初始化：', this.name,tw, th, this.scaleX, this.scaleY);
			this.Scale = 1;
			while(super.numChildren > 0){
				super.removeChildAt(0);
			}
			this.focusSkin = glo.CreateObject('FocusRectSkin') as SkinItem;
			this.focusSkin.x = -1;
			this.focusSkin.y = -1;
			this.focusSkin.visible = false;
			this.addChild(this.focusSkin);
			this.SetSize(tw,th);
			this._inited = true;
		}
		public function Focus():void{
			if(this.stage != null){
				this.stage.focus = this;
			}
			
		}
		/**
		 * 设置组件尺寸
		 * @param pWidth
		 * @param pHeight
		 */
		public function SetSize(pWidth:Number, pHeight:Number):void {
			var vc:Boolean = false;
			if(pWidth > 0){
				this._width = pWidth;
				this.focusSkin.width = pWidth + 2;
				vc = true;
			}
			if(pHeight > 0){
				this._height = pHeight;
				this.focusSkin.height = pHeight + 2;
				vc = true;
			}
			if (vc && this._inited) {
				this.draw();
			}
		}
		
		protected function addInitData(key:String, value:*):Boolean {
			if(this._inspector){
				if (this._initDatas == null) {
					this._initDatas = { };
				}
				trace('initdata',key,value);
				if (glo.IsNullOrUndefined(this._initDatas[key])) {
					this._initDatas[key] = [];
				}
				(this._initDatas[key] as Array).push(value);
			}
			
			return this._inspector;
		}
		/**
		 * @private (protected)
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		protected function afterComponentParameters():void {
		}
		/**
		 * @private (protected)
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		protected function beforeComponentParameters():void { 
		}
	}
}