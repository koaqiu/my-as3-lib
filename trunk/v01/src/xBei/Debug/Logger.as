/**
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 *
 * 	addChild(new Logger());
 *
 *	Logger.info("Info message");
 * 	Logger.debug("Debug message");
 * 	Logger.warning("This is just a warning!");
 * 	Logger.error("Ok, something crashed");
 *
 * version log:
 *
 * 	07.10.12		1.0		xBei			+ First version
 **/

package xBei.Debug {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import xBei.Helper.StringHelper;
	import xBei.UI.XSprite;

	public class Logger extends Sprite {
		public static var LEVEL_INFO:int = 0x01;
		public static var LEVEL_DEBUG:int = 0x02;
		public static var LEVEL_WARNING:int = 0x04;
		public static var LEVEL_ERROR:int = 0x08;
		public static var LEVEL_SILENT:int = 0x10;

		private static var level_names:Object = {
			'1':{'name':"INFO",'color':0xFFFFFF}, 
			'2':{'name':"DEBUG", 'color':0xff00ff},
			'4':{'name':"WARNING", 'color':0xffff00},
			'8':{'name':"ERROR", 'color':0xff0000},
			'16':{'name':"SILENT", 'color':0xeeeeee}
		}

		private static var _inc:Logger;

		public var global:Boolean;
		public var level:int;

		private var _showLog:int = 0x1F;
		private var bgBox:Sprite;
		private var textBox:TextField;
		private var _toolBars:XSprite;
		private var logs:Array = [];

		private var _height:Number;
		private static var _cache_logs:Array = [];
		
		private static var _noDebug:Boolean = false; 
		public static function set NoDebug(v:Boolean):void{
			_noDebug = v;
			if(v){
				_cache_logs = [];
				_clear();
			}
		}
		
		public function Logger(height:Number = 40, level : int = 1, global : Boolean = true) {
			_height = height;
			if(_inc == null){
				_inc = this;
			}else{
				throw new Error('xBei.Debug.Logger 已经初始化。');
			}
			this.level = level;
			this.global = global;

			bgBox = new Sprite();
			bgBox.graphics.beginFill(0x000000, .8);
			bgBox.graphics.drawRect(0, 0, 10, 10);
			bgBox.graphics.endFill();
			addChild(bgBox);

			textBox = new TextField();
			textBox.y = 10;
			textBox.height = height;
			textBox.multiline = true;
			textBox.defaultTextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
			addChild(textBox);

			this._toolBars = new XSprite();
			this._createButtons();
			this.addChild(this._toolBars);
			this._clear();
			this.addEventListener(MouseEvent.ROLL_OVER, DPE_RollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, DPE_RollOver);
			
			for(var i:int = 0; i < _cache_logs.length; i++){
				var log:Object = _cache_logs[i];
				var level:int = int(log.level);
				if((_showLog & level) == level){
					this._addLog(log.msg, level);
				}
			}
			_cache_logs = [];
		}
		private function DPE_RollOver(e:MouseEvent):void{
			if(e.type == MouseEvent.ROLL_OVER){
				this.alpha = 1;
				this.x = 0;
			}else if(e.type == MouseEvent.ROLL_OUT){
				this.alpha = .1;
				this.x = 10 - this.width
			}
		}
		private function _createButtons():void{
			var tx:Number = 0;
			for(var k:* in level_names){
				var data:Object = level_names[k];
				var lab:TextField = new TextField();
				var bg:Sprite = new Sprite();
				bg.buttonMode = bg.useHandCursor = true;
				bg.name = String(k);
				bg.x = tx;
				bg.addEventListener(MouseEvent.CLICK, DPE_ButtonClick);
				this._toolBars.addChild(bg);
				lab.defaultTextFormat = new TextFormat("_sans", 10, data.color);
				lab.mouseEnabled = false;
				lab.selectable = false;
				lab.autoSize = 'left';
				lab.text = data.name.charAt(0);
				lab.x = tx;
				lab.y = -2;
				var g:Graphics = bg.graphics;
				g.clear();
				g.beginFill(0x999999);
				g.drawRect(0, 0, lab.width > 10 ? lab.width : 10, 10);
				g.endFill();
				tx += lab.width + 10;
				this._toolBars.addChild(lab);
			}
		}
		private function DPE_ButtonClick(e:MouseEvent):void{
			var bg:Sprite = e.target as Sprite;
			var level:int = int(bg.name);
			if((_showLog & level) == level){
				_showLog -= level;
				bg.alpha = .5;
			}else{
				_showLog += level;
				bg.alpha = 1;
			}
			this._rePrintLogs();
		}

		private function _rePrintLogs():void{
			textBox.text = getTimestamp() + " :: Hi-ReS! Logger > " + level_names[level].name + " mode.\n";
			bgBox.width = textBox.width;
			bgBox.height = textBox.height + 10;
			for(var i:int = 0; i < logs.length; i++){
				var log:Object = logs[i];
				var level:int = int(log.level);
				if((_showLog & level) == level){
					this._addLog(log.msg, level);
				}
			}
		}
		public static function info( ...msg : * ):void {
			Logger.log(msg, LEVEL_INFO);
		}

		public static function debug( ...msg : * ):void {
			Logger.log(msg, LEVEL_DEBUG);
		}

		public static function warning( ...msg : * ):void {
			Logger.log(msg, LEVEL_WARNING);
		}

		public static function error( ...msg : * ):void {
			Logger.log(msg, LEVEL_ERROR);
		}

		public static function log( msg : *, level : int = 1 ):void {
			if(_noDebug){
				//do noThing
			}else if(_inc != null){
				_inc._log( msg, level );
			}else{
				_cache_logs.push({
					'level':level,
					'msg':msg
				});
			}
		}

		public static function _clear():void {
			if(_inc != null){
				_inc._clear();
			}
		}


		// .. INSTANCE METHODS

		private function _info( ...msg : * ):void {
			_log(msg, LEVEL_INFO);
		}

		private function _debug( ...msg : * ):void {
			_log(msg, LEVEL_DEBUG);
		}

		private function _warning( ...msg : * ):void {
			_log(msg, LEVEL_WARNING);
		}

		private function _error( ...msg : * ):void {
			_log(msg, LEVEL_ERROR);
		}

		private function _log( msg : *, level : int = 1 ):void {
			logs.push({
				'level':level,
				'msg':msg
			});
			if((_showLog & level) == level){
				this._addLog(msg, level);
			}
		}
		private function _addLog(msg:*, level:int):void{
			var beginIndex:int = textBox.length;
			//是否显示
			var tf:TextFormat = new TextFormat("_sans", 10, level_names.hasOwnProperty(level) ? level_names[level].color : 0xFFFFFF);
			textBox.appendText(getTimestamp());
			textBox.appendText(' :: ');
			textBox.appendText(level_names.hasOwnProperty(level) ? level_names[level].name : 'LOG');
			textBox.appendText(' :: ');
			textBox.appendText(String(msg) + "\n");
			
			textBox.setTextFormat(tf, beginIndex, textBox.length - 1);
			textBox.autoSize = "left";
			bgBox.width = textBox.width + 10;
			textBox.autoSize = 'none';
			
			textBox.height = _height;
			textBox.scrollV = textBox.maxScrollV;
			
			//bgBox.width = textBox.width;
			bgBox.height = textBox.height + 10;
			
			this.alpha = 1;
			this.x = 0;
		}
		private function _clear():void {
			textBox.text = getTimestamp() + " :: Hi-ReS! Logger > " + level_names[level].name + " mode.\n";
			//textBox.autoSize = "left";

			bgBox.width = textBox.width;
			bgBox.height = textBox.height + 10;
			logs = [];
		}


		// .. UTILS

		private static function getTimestamp():String {
			var d:Date = new Date();
			return "[" + StringHelper.FormatNumber(d.hours, 2) + ":" + StringHelper.FormatNumber(d.minutes, 2) + ":" + StringHelper.FormatNumber(d.seconds, 2) + "::" + StringHelper.FormatNumber(d.milliseconds, 3) + "]";
		}

	}
}