package xBei.Media {
	import flash.events.*;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	import xBei.Helper.StringHelper;
	
	[Event(name = "open", type = "flash.events.Event")]
	[Event(name = "play", type = "flash.events.Event")]
	[Event(name = "pause", type = "flash.events.Event")]
	[Event(name = "stop", type = "flash.events.Event")]
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	[Event(name = "onPlayComplete", type = "flash.events.Event")]
	[Event(name = "volumeChange", type = "flash.events.Event")]
	/**
	 * Mp3播放内核
	 * @author KoaQiu
	 */
	public class Mp3 extends EventDispatcher {
		public const Version:String = "0.3";
		
		private var _s:Sound;
		private var _channel:SoundChannel;
		private var positionTimer:Timer;
		private var _lt:Timer;
		private var _to:Timer;
		/**
		 * 缓存百分比
		 */
		private var Lp:Number = .2;
		/**
		 * 用于计算下载速率
		 */
		private var _sd:Date;
		
		public function get State():int {
			return this._state;
		}
		//状态，0-初始，1-缓冲，2-播放，3-暂停，4-停止
		private var _state:int = 0;
		private var _prePos:Number = 0;
		private var _preVolume:Number = .8;
		private var _loaded:Boolean = false;
		private var _isMute:Boolean = false;
		private var _timeOut:int = 30;
		private var _onLine:Boolean = true;
		public var data:Object;
		
		public static function PlaySound(soundName:String):Boolean {
			if (StringHelper.IsNullOrEmpty(soundName)) return false;
			try{
				var sound:Sound = new( getDefinitionByName(soundName) as Class);
				sound.play();
			}catch (error:Error) {
				return false;
			}
			return true;
		}
		public function Mp3() {
			
		}
		//公用属性
		/*
		 * 当前音乐长度
		 */
		public function get Length():Number {
			return _s.length;
		}
		/*
		 * 播放进度
		 */
		public function get Position():Number{
			return this._channel.position;
		}
		public function set Position(v:Number):void{
			//this._channel.stop();
			this.Play(v);
		}
		/*
		 * 音量大小
		 */
		public function get Volume():Number {
			if (this._channel == null) {
				return 0;
			}
			return this._channel.soundTransform.volume;
		}
		public function set Volume(v:Number):void {
			//trace("Set Volume _p=", _preVolume, v);
			if (v < 0) v = 0;
			else if (v > 1) v = 1;
			if (v > 0) {
				_preVolume = v;
			}
			_isMute = v == 0;
			TweenLite.to(this._channel, 2, { 
				volume:v ,
				onUpdate:this.onVolumeChange
			} );
			//TweenLite.to(this.VolumeBar, 2, { scaleX : v } );
		}
		public function SetVolume(v:Number, tween:Boolean = false):void {
			if (v > 0) {
				_preVolume = v;
			}
			_isMute = v == 0;
			if (tween) {
				TweenLite.to(this._channel, 2, { 
					volume:v
				} );
			}else{
				var st:SoundTransform = this._channel.soundTransform;
				st.volume = v;
				this._channel.soundTransform = st;
			}
		}
		public function get IsMute():Boolean {
			return this._isMute;
		}
		public function set IsMute(v:Boolean):void {
			if (this._isMute) {
				this.Volume = _preVolume > 0?this._preVolume:1;
			}else {
				this.Volume = 0;
			}
		}
		public function Mute():void {
			this.IsMute = !this.IsMute;
		}
		//公用方法
		/**
		 * 打开Mp3资源准备播放
		 * @param	file	Mp3资源
		 * @return	Boolean	成功返回true
		 */ 
		public function Open(file:String, onLine:Boolean = true):Boolean {
			if (file == "") {
				return false;
			}
			trace("open",file);
			_loaded = false;
			_onLine = onLine;
			if (_s != null) {
				//this._s.removeEventListener(Event.ID3 , sound_id3);
				this._s.removeEventListener(Event.OPEN, onMp3Open );
				this._s.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIoErr);
				this._s.removeEventListener(ProgressEvent.PROGRESS, DPE_Mp3DownloadProgress);
				this._s.removeEventListener(Event.COMPLETE, onMp3Complete);
			}
			try{
				//判断音乐来源并做对应处理
				if(onLine){
					var request:URLRequest = new URLRequest(file);
					this._s = new Sound();
				}else {
					trace("open emabed mp3",file)
					var cls:Class= getDefinitionByName(file) as Class;
					this._s = new cls();
				}
				//附加事件
				//this._s.addEventListener(Event.ID3 , sound_id3);
				this._s.addEventListener(Event.OPEN, onMp3Open);
				this._s.addEventListener(ProgressEvent.PROGRESS, DPE_Mp3DownloadProgress);
				this._s.addEventListener(Event.COMPLETE, onMp3Complete);
				this._s.addEventListener(IOErrorEvent.IO_ERROR, onLoadIoErr);
				if(onLine){
					var csc:SoundLoaderContext = new SoundLoaderContext(1000, true);
					this._s.load(request, csc);
					this._to = new Timer(_timeOut * 1000);
					this._to.addEventListener(TimerEvent.TIMER, onTimeOut);
				}
			}catch (err:Error) {
				trace(err);
				//this.PlayNext();
				return false;
			}
			
			this._prePos = 0;
			this.Lp = .2;
			return true;
		}
		/**
		 * 播放Mp3，必须先用Open打开资源
		 * @param	pos	起始播放位置，未指定则重新开始或者从上次暂停位置开始
		 */ 
		public function Play(pos:Number = 0):void {
			if (this._state == 2) {
				//已经在播放了
				return;
			}
			if (_onLine && _s.bytesTotal == 0) {
				//延迟运行
				//trace("延迟运行");
				_lt = new Timer(100);
				_lt.addEventListener(TimerEvent.TIMER, _ltTimer);
				_lt.start();
				return;
			}
			if (_onLine && this._state == 1) {
				//正在缓冲
				if (_s.bytesLoaded / _s.bytesTotal < this.Lp) {
					//trace("缓存");
					//下载小于20%
					return;
				}
			}
			this._state = 2;
			if(pos==0){
				pos=this._prePos;
			}
			if (this._channel != null) {
				this._channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			}
			
			this._channel = this._s.play(pos);
			//trace("play pos", pos,this._channel);
			this._channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			
			if (positionTimer != null) {
				this.positionTimer.stop();
				this.positionTimer.removeEventListener(TimerEvent.TIMER, positionTimerHandler);
			}
			this.positionTimer = new Timer(50);
			this.positionTimer.addEventListener(TimerEvent.TIMER, positionTimerHandler);
			this.positionTimer.start();
			
			var st:SoundTransform = this._channel.soundTransform;
			st.volume = 0;
			this._channel.soundTransform = st;
			
			if (!_isMute) {
				//trace(_preVolume);
				//声音淡入
				TweenLite.to(this._channel, 2, {
					volume:this._preVolume,
					onUpdate:this.onVolumeChange
				});
			}
			//触发 播放事件
			this.dispatchEvent(new Event("play"));
		}
		/*
		 * 停止播放，需要用Open重新打开
		 */ 
		public function Stop():void {
			if (this._state == 4) {
				return;
			}
			//trace("stop");
			this._state = 4;
			if(_lt!=null){
				_lt.stop();
				_lt.removeEventListener(TimerEvent.TIMER, _ltTimer);
				_lt = null;
			}
			if (_s != null) {
				//this._s.removeEventListener(Event.ID3 , sound_id3);
				this._s.removeEventListener(Event.OPEN, onMp3Open );
				this._s.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIoErr);
				this._s.removeEventListener(ProgressEvent.PROGRESS, DPE_Mp3DownloadProgress);
				this._s.removeEventListener(Event.COMPLETE, onMp3Complete);
				
				if(this.positionTimer!=null){
					this.positionTimer.removeEventListener(TimerEvent.TIMER, positionTimerHandler);
					this.positionTimer = null;
				}
				//停止播放
				if(this._channel!=null){
					this._channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					this._channel.stop();
					this._channel = null;
				}
				
				//this._s.close();
				//this._s = null;
			}
			MyGC.GC();
			MyGC.GC();
			this.dispatchEvent(new Event("stop"));
		}
		/**
		 * 暂停播放
		 */ 
		public function Pause():void {
			if (this._state == 3) {
				return;
			}
			this._state = 3;
			this.dispatchEvent(new Event("pause"));
			if (_isMute) {
				_pause();
			}else{
				//记录音量
				this._preVolume = this.Volume;
				//淡出声音
				TweenLite.to(this._channel, 2, {
					volume:0, 
					onUpdate:this.onVolumeChange,
					onComplete:_pause
				});
			}
		}
		private function _pause():void {
			//记录播放位置
			this._prePos = this._channel.position;
			//移除监听
			this._channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			this.positionTimer.removeEventListener(TimerEvent.TIMER, positionTimerHandler);
			this.positionTimer = null;
			//停止播放
			this._channel.stop();
			this._channel = null;
		}

		public function GetFormatTime(t:Number=-1):String{
			if(t==-1){
				t = Math.floor(this._channel.position/10);
			}
			var n:Number = t % 100;
			t=(t-n)/100;
			var s:Number = t % 60;
			t=(t-s)/60;
			var m:Number = t % 60;
			return f2(m) + ":" + f2(s);// +"." + f2(n);			
		}
		private function f2(n:Number):String{
			return n>9?String(n):"0"+n;
		}
		
		//Events
		private function onTimeOut(e:TimerEvent):void {
			_to.removeEventListener(TimerEvent.TIMER, onTimeOut);
			_to.stop();
			_to = null;
			this._s.close();
			this.Stop();
			//超时
			this.dispatchEvent(new Event("TimeOut"));
		}
		private function _ltTimer(e:TimerEvent):void {
			if (_s.bytesTotal > 0 && _s.bytesLoaded > 0) {
				var t:Timer = e.target as Timer;
				if(t!=null){
					t.stop();
					t.removeEventListener(TimerEvent.TIMER, _ltTimer);
					t = null;
				}
			}
		}
		private function soundCompleteHandler(e:Event):void {
			//播放完毕了，卸载资源
			trace("stop soundCompleteHandler");
			this.Stop();
			this.dispatchEvent(new Event("onPlayComplete"));
		}
		private function positionTimerHandler(e:TimerEvent):void {
			//var v:Number = this._channel.position / this._s.length;
			if (this._channel == null || this._s == null) {
				return;
			}
			this.dispatchEvent(new ProgressEvent("playProgress", e.bubbles, e.cancelable, this._channel.position, this._s.length));
		}
		private function onMp3Open(e:Event):void {
			_state = 1;
			//清除超时
			_to.removeEventListener(TimerEvent.TIMER, onTimeOut);
			_to.stop();
			_to = null;
			this.dispatchEvent(new Event("open"));
		}
		/**
		 *  下载进度
		 * @param	e
		 */
		private function DPE_Mp3DownloadProgress(e:ProgressEvent):void {
			var speed:Number = 0;
			
			//计算加载速率
			if (_sd == null) {
				_sd = new Date();
			}else {
				var now:Date = new Date();
				var scd:Number = (now.time-_sd.time) / 1000;
				//kb/s
				//计算下载速度和预载百分比
				speed = e.bytesLoaded / scd / 1024;
				if (speed < 10) {
					Lp = .8;
				}else if (speed < 50) {
					Lp = .6;
				}else if (speed < 80) {
					Lp = .4;
				}else if (speed < 100) {
					Lp = .3;
				}
				//trace("下载速度", speed, "缓存", Lp);
			}
			if (e.bytesLoaded > 0 && this._state == 1) {
				if (e.bytesLoaded / e.bytesTotal > Lp) {
					trace("缓存完毕！");
					this.Play();
				}
			}
			this.dispatchEvent(new ProgressEvent(e.type, e.bubbles, e.cancelable, e.bytesLoaded, e.bytesTotal));
		}
		private function onMp3Complete(e:Event):void {
			//加载完毕
			_loaded = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		private function sound_id3(e:Event):void {
			if(this._s.id3.songName != null){
				//trace(this._s.id3.songName);
				//trace(this.GetString(this._s.id3.songName));
			}
		}
		private function onLoadIoErr(e:IOErrorEvent):void {
			//发生IO错误
			trace("发生错误");
			this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.text));
			this.Stop();
		}
		protected function onVolumeChange():void {
			this.dispatchEvent(new Event("volumeChange"));
		}
	}//End Class
}
