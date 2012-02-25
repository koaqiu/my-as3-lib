package xBei.Manager {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	/**
	 * 深度管理（模拟AS2）
	 * @version v0.1
	 * @author KoaQiu
	 */
	public final class DepthManger {
		function DepthManger(p:pc) {
		}
		/**
		* 得到下一个可用的最高深度
		* @param	doc		容器
		* @return	最高深度（当前最高深度+1）
		*/ 
		public static function getNextHighestDepth(doc:DisplayObjectContainer):int {
			throw new Error("未实现！");
			return doc["__dm__"].top==null?0:doc["__dm__"].top++;
		}
		/**
		* 添加对象到特定深度，如果指定深度上已存在对象则覆盖
		* @param	doc		容器
		* @param	child	要添加的子对象
		* @param	depth	深度
		* @param	add		是否添加
		* @return	返回值为：{depth:深度, index:系列引索}
		*/ 
		public static function addAt(doc:DisplayObjectContainer, child:DisplayObject, depth:int,add:Boolean=true):void {
			var t1:int = -1;
			var l:int = doc.numChildren;
			
			if (l == 0) {
				//没有子对象，直接添加
				doc.addChild(child);
				child["VDepth"] = depth;
				return;
			}else {
				for (var i:int = 0; i < l; i++ ) {
					var dp:DisplayObject = doc.getChildAt(i);
					var itemDp:int;
					if(dp.hasOwnProperty('VDepth')){
						itemDp = dp["VDepth"];
					}else{
						itemDp = i;
					}
					//if(depth>100)trace(child,doc.getChildAt(i).name+".depth="+itemDp+",toDepth="+depth,itemDp > depth);
					if (itemDp == depth) {
						//有对象，覆盖之
						doc.removeChildAt(i);
						doc.addChildAt(child, i);
						child["VDepth"] = depth;
						//trace("覆盖",depth);
						return;
					}else if (itemDp > depth) {
						t1 = i;
						break;
					}
				}
				//if(child is Page)trace(t1);
				if (t1 == -1) {
					//添加到最后
					doc.addChild(child);
				}else {
					//插入到中间
					doc.addChildAt(child, t1);
				}
				child["VDepth"] = depth;
			}
			return;
		}//end function
		/**
		* 删除深度上的对象
		* @param	doc		容器
		* @param	depth	目标深度
		* @return	无
		*/ 
		public static function removeAt(doc:DisplayObjectContainer,depth:int):void {
			var l:int = doc["__dm__"].list.length;
			//查找深度
			for (var i:int= 0;i<l;i++ ) {
				var item:int = doc["__dm__"].list[i];
				if (item == depth) {
					//找到
					doc.removeChildAt(item);//删除
					doc["__dm__"].list.splice(i, 1);
					doc["__dm__"].count--;
					if (i == l - 1) {
						doc["__dm__"].top = doc["__dm__"].list[l - 2];
					}
					doc["__dm__"].list.sort(16);
					return;
				}
			}
		}//end function
		/**
		* 删除对象
		* @param	doc		容器
		* @param	child	要删除的子对象
		* @return	无
		*/
		public static function remove(doc:DisplayObjectContainer, child:DisplayObject):void {
			//if(child is Page)trace("删除："+child.name+".depth="+child["depth"]);
			doc.removeChild(child);
		}//end function
		/**
		* 交换深度
		* @param	doc		容器
		* @param	child	要交换的子对象
		* @param	toDepth	目标深度
		* @return	无
		*/ 
		public static function swapDepths(doc:DisplayObjectContainer,child:DisplayObject,toDepth:int):void {
			if (doc == null || child == null) {
				return;
			}
			var cindex:int = doc.getChildIndex(child);
			var childDp:int = int(child["VDepth"]);
			//trace(child.name,"交换深度",childDp,toDepth);
			if (childDp == toDepth) {
				//就是child
				return;
			}
			//临时移除
			doc.removeChild(child);
			
			var l:int = doc.numChildren;
			var itemDp:int;
			
			//查找深度
			for (var i:int = 0;i<l;i++ ) {
				itemDp = doc.getChildAt(i)["VDepth"];
				if (itemDp == toDepth) {
					//找到
					//交换位置
					doc.swapChildrenAt(cindex, i);
					doc.getChildAt(i)["VDepth"] = childDp;
					child["VDepth"] = toDepth;
					return;
				}
			}
			//在目标深度上没有找到对象，直接添加移动到深度
			//trace("在目标深度上没有找到对象，直接添加并移动到深度", child.name,toDepth);
			for (i = 0; i < l; i++ ) {
				itemDp = doc.getChildAt(i)["VDepth"];
				if (itemDp > toDepth) {
					doc.addChildAt(child, i);
					child["VDepth"] = toDepth;
					return;
				}
			}
			//添加到最顶层
			doc.addChild(child);
			child["VDepth"] = toDepth;
		}//end function
	}
}
class pc{}