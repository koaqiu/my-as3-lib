package com.CGFinal.Events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author KoaQiu
	 */
	public class HotKeyEvent extends Event {
		/*
		 * 注册的快捷键被激发
		 */ 
		public static const ACTION:String = "action";
		/*
		 * 初始化完成
		 */ 
		public static const INIT:String = "onInit";
		public var App:String;
		public var Command:String;
		public var EventObject:Object;
		
		public function HotKeyEvent(type:String,app:String,command:String,eventObject:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.App = app;
			this.Command = command;
			this.EventObject = eventObject;
		} 
		
		public override function clone():Event { 
			return new HotKeyEvent(type, this.App, this.Command, this.EventObject, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("HotKeyEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
