package xBei.Manager {
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * 克隆管理
	 * @author KoaQiu
	 */
	final public class CloneManager {
		private static function newSibling(sourceObj:Object):* {
			if (sourceObj != null) {
				var objSibling:*;
				try {
					var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
					objSibling = new classOfSourceObj();
				}catch (e:Object) {
				}
				return objSibling;
			}
			return null;
		}
		public static function Clone(source:*):* {
			var clone:Object = null;
			if(source != null) {
				clone = newSibling(source);
				if(clone != null) {
					copyData(source, clone);
				}
			}
			
			return clone;
		}
		private static function copyData(source:*, destination:*):void {
			if(source != null && destination != null) {
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					for each(prop in sourceInfo.variable) {
						if(destination.hasOwnProperty(prop.@name)) {
							destination[prop.@name] = source[prop.@name];
						}
					}
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(destination.hasOwnProperty(prop.@name)) {
								destination[prop.@name] = source[prop.@name];
							}
							
						}
					}
				}catch (err:Object) {
				}
			}
		}
	}
}