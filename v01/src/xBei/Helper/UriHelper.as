package xBei.Helper{
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import xBei.Net.Uri;

	public final class UriHelper	{
		public function UriHelper(){
		}
		/**
		 * 合并路径，如果参数不是Uri类型则会强制转换成String
		 * @param basePath
		 * @param path
		 * @return 
		 */		
		public static function Combine(basePath:*, path:*):Uri{
			if(basePath == null || path == null){
				throw new ArgumentError('参数不能为空（null）');
			}
			var baseUri:Uri;
			var pUri:Uri;
			if(basePath is Uri) 
				baseUri = basePath as Uri;
			else
				baseUri = new Uri(String(basePath));
			if(path is Uri) 
				pUri = path as Uri;
			else
				pUri = new Uri(String(path));
			return baseUri.Combine(pUri);
		}
		/**
		 * 得到Html的Uri地址，很大几率会返回null，所以在引用此值时要先判断
		 * @return 
		 */		
		public static function get HtmlUri():Uri{
			if(ExternalInterface.available){
				try	{
					return new Uri(ExternalInterface.call('location.toString'));
				} catch(error:Error) {
					return null;
				}
			}
			return null;
		}
		/**
		 * 得到主SWF的Uri地址
		 * @param stage
		 * @return 
		 */		
		public static function GetStageUri(stage:Stage):Uri{
			if(stage == null || stage.loaderInfo == null){
				return null;
			}else{
				return new Uri(stage.loaderInfo.loaderURL);
			}
		}
		/**
		 * 得到Swf的Uri地址
		 * @param swf
		 * @return 
		 */		
		public static function GetSwfUri(swf:Object):Uri{
			if(swf != null && swf.hasOwnProperty('loaderInfo')){
				var li:LoaderInfo = swf['loaderInfo'] as LoaderInfo;
				if(li != null){
					return new Uri(li.loaderURL);
				}
			}
			return null;
		}
	}
}