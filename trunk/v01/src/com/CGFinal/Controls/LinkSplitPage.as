package com.CGFinal.Controls {
	import com.CGFinal.BaseUI;
	import com.CGFinal.LiteComponent;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import xBei.Helper.StringHelper;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LinkSplitPage extends BaseUI {

		private var _txt:TextField;

		private var _format:String = '<a href="[FIRST]">首页</a> <a href="[PRE]">上一页</a> [PAGELIST] <a href="[NEXT]">下一页</a> <a href="[LAST]">尾页</a>';
		public function set Format(v:String):void{
			_format = v;
		}
		private var _recordCount:uint = 0;

		/**
		 * 总记录数
		 */
		public function get RecordCount():uint {
			return _recordCount;
		}

		public function set RecordCount(v:uint):void {
			_recordCount = v;
			_pageCount = 0;
		}

		private var _pageSize:uint = 10;

		/**
		 * 分页大小
		 */
		public function get PageSize():uint {
			return _pageSize;
		}

		public function set PageSize(v:uint):void {
			if (v < 0) {
				_pageSize = 1;
			}
			_pageSize = v;
			_pageCount = 0;
		}

		private var _oldPageIndex:uint = 1;

		public function get OldPageIndex():uint {
			return _oldPageIndex;
		}
		private var _pageIndex:uint = 1;

		/**
		 * 当前页码
		 */
		public function get PageIndex():uint {
			return _pageIndex;
		}

		public function set PageIndex(v:uint):void {
			if (v == _pageIndex) {
				return;
			}
			if (_pageCount != _oldPageIndex) {
				_oldPageIndex = _pageIndex;
			}
			if (v > this.PageCount) {
				_pageIndex = this.PageCount;
			} else {
				_pageIndex = v;
			}
			if (_pageIndex < 1) {
				_pageIndex = 1;
			}

		}

		private var _pageCount:uint = 0;

		/**
		 * 页码总数（只读）
		 */
		public function get PageCount():uint {
			if (this.RecordCount < 1) {
				_pageCount = 0;
				return 0;
			} else if (_pageCount == 0) {
				_pageCount = Math.round(RecordCount / PageSize + 0.499999999999);
			}
			return _pageCount;
		}

		public function LinkSplitPage() {
			super();
		}

		private var _tf:TextFormat;
		override protected function createChildren():void {
			super.createChildren();
			_txt = super.createLabel('');
			_tf = _txt.getTextFormat();
			_tf.bold = true;
			_tf.font = 'Arial';
			_tf.color = 0x366989;
			_txt.defaultTextFormat = _tf; 
			_txt.addEventListener(TextEvent.LINK, DPE_ChangePageIndex);
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("body{font-size:12;font-family:Arial;font-weight:bold;color:#366989;}a:link{text-decoration:none;color:#366989;}a:hover{text-decoration:none;color:#0E84CE;}.s{font-size:20;}");
			this._txt.styleSheet = css;
			addChild(_txt);
		}

		public function RenderPager():void {
			if (this.RecordCount == 0 || this.PageCount == 0) {
				this._txt.text = '没有任何记录';
				return;
			}
			var si:int = this.PageIndex - 5;
			var ei:int = this.PageIndex + 4;

			if (ei > this.PageCount) {
				si -= ei - this.PageCount;
				ei = this.PageCount;
			}
			if (si <= 0) {
				ei -= si;
				ei++;
				if (ei > this.PageCount) {
					ei = this.PageCount;
				}
				si = 1;
			}

			var pagelist:String = '';
			if(this.PageIndex > 6){
				pagelist += '<a href="event:gotoPage:1">1</a>...';
			}
			for (var i:int = si; i <= ei; i++) {
				var tmp:String;
				if(this.PageIndex == i){
					tmp = StringHelper.Format('<a href="event:gotoPage:{0}" class="s">{0}</a> ',i);
				}else {
					tmp = StringHelper.Format('<a href="event:gotoPage:{0}">{0}</a> ', i);
				}
				//tmp = StringHelper.Format('<a href="event:gotoPage:{0}">{0}</a>', i);
				
				pagelist += tmp;
			}
			if(this.PageIndex + 5 <= this.PageCount){
				pagelist += StringHelper.Format('...<a href="event:gotoPage:{0}">{0}</a>', this.PageCount);
			}
			//trace("pageindex=",this.PageIndex,this.PageIndex > 1 ? this.PageIndex - 1 : 1);
			var html:String = this._format.replace("[FIRST]", "event:gotoPage:1").
				replace("[PRE]", StringHelper.Format("event:gotoPage:{0}", this.PageIndex > 1 ? this.PageIndex - 1 : 1)).
				replace("[NEXT]", StringHelper.Format("event:gotoPage:{0}", this.PageIndex < this.PageCount ? this.PageIndex + 1 : this.PageCount))
				.replace("[LAST]", StringHelper.Format("event:gotoPage:{0}", this.PageCount)).replace("[PAGELIST]", pagelist)
			this._txt.htmlText = html;
			//this._txt.setTextFormat(_tf);
		}

		//Do Events
		protected function OnPageIndexChanged(newIndex:int):void {
			if(this.PageIndex != newIndex){
				this.PageIndex = newIndex;
				//trace("old:",this.OldPageIndex,"new:",newIndex);
				trace("选择了：", newIndex);
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}

		//Events
		private function DPE_ChangePageIndex(e:TextEvent):void {
			//trace(e.text);
			var reg:RegExp = /^gotoPage:(\d+)$/ig;
			var m:Object = reg.exec(e.text);
			if (m) {
				//trace("goto:",m[1]);
				this.OnPageIndexChanged(int(m[1]));
			}
		}
	}

}