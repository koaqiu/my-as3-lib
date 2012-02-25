package xBei.Manager
{
	import com.adobe.crypto.MD5;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import net.hires.debug.Logger;
	
	import xBei.Net.DataLoader;
	import xBei.Net.Events.DataLoaderEvent;

	public class ResourcesManager
	{
		private var _hashList:Object = {};
		
		private static var _inc:ResourcesManager;
		/**
		 * 唯一实例
		 * @return 
		 * 
		 */
		public static function get Instance():ResourcesManager{
			if(_inc == null){
				_inc = new ResourcesManager(new PrivateC());
			}
			return _inc;
		}
		
		public function ResourcesManager(pc:PrivateC){}
		/**
		 * 加载资源
		 * @param url
		 * @param callBack	function(result:Object):void; result={succ,message,loader}
		 * @param caller
		 */		
		public function Load(url:String, callBack:Function, caller:Object = null):void{
			var key:String = MD5.hash(url.toLowerCase());
			var data:Object = this._hashList[key];
			if(data == null){
				trace('加载：',url, key);
				this._hashList[key] = {
					'Data':null,
					'isLoading':true,
					'CallBack':callBack,
					'caller':caller
				};
				var l:DataLoader = new DataLoader();
				l.dataFormat = URLLoaderDataFormat.BINARY;
				l.addEventListener(DataLoaderEvent.DATA_LOADED, DPE_LoadCompleted);
				l.addEventListener(DataLoaderEvent.ERROR, DPE_LoadError);
				l.Load(url);
			}else if(data.isLoading){
				var tmp:Object = {
					'interval':0,
					'key':key,
					'data':data
				};
				tmp.interval = setInterval(function(LRS:Function, pData:Object, callBack:Function, caller:Object):void{
					if(pData.data.isLoading == false){
						clearInterval(pData.interval);
						LRS(pData.data, callBack, caller);
						pData = null;
					}
				}, 100, this._loadRs, tmp, callBack, caller);
				trace('等待加载完毕', key, tmp.interval);
			}else{
				trace('从缓存中加载：',url, key);
				this._loadRs(data, callBack, caller);
			}
		}
		private function _loadRs(item:Object, callBack:Function, caller:Object):void{
			var load:Loader = new Loader();
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
				var l:Loader = (e.target as LoaderInfo).loader;
				l.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
				callBack.call(caller, {'succ':true, 'loader':l});
			});
			var ct:LoaderContext = new LoaderContext();
			ct.allowCodeImport = true;
			load.loadBytes(item.Data, ct);
		}
		
		//Events
		private function DPE_LoadError(e:DataLoaderEvent):void{
			var l:DataLoader = e.target as DataLoader;
			l.removeEventListener(DataLoaderEvent.DATA_LOADED, DPE_LoadCompleted);
			l.removeEventListener(DataLoaderEvent.ERROR, DPE_LoadError);
			var key:String = MD5.hash(l.RequestUrl.url.toLowerCase());
			var item:Object = this._hashList[key];
			Logger.error('ResourcesManager 加载错误: ' + l.RequestUrl.url + '');
			if(item != null){
				item.isLoading = false;
				if(item.CallBack != null){
					var cb:Function = item.CallBack;
					var caller:Object = item.caller;
					cb.call(caller, {'succ':false, 'message':l.ErrorMessage});
				}
				delete item.CallBack;
				delete item.caller;
			}
			delete this._hashList[key];
		}
		private function DPE_LoadCompleted(e:DataLoaderEvent):void{
			var l:DataLoader = e.target as DataLoader;
			l.removeEventListener(DataLoaderEvent.DATA_LOADED, DPE_LoadCompleted);
			l.removeEventListener(DataLoaderEvent.ERROR, DPE_LoadError);
			
			var key:String = MD5.hash(l.RequestUrl.url.toLowerCase());
			trace('加载完毕：',l.RequestUrl.url,key);
			var item:Object = this._hashList[key];
			if(item != null){
				var data:ByteArray = l.data as ByteArray;
				item.Data = data;
				item.isLoading = false;
				if(item.CallBack != null){
					var cb:Function = item.CallBack;
					var caller:Object = item.caller;
					this._loadRs(item, cb, caller);
				}
				delete item.CallBack;
				delete item.caller;
			}
		}
	}
}
class PrivateC{}