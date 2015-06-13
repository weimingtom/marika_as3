package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.events.Event;
	
	public class CWindow extends Sprite
	{
		public static const MB_ICONQUESTION:uint = 0x00000020;
		public static const MB_OKCANCEL:uint = 0x00000001;
		public static const IDOK:uint = 1;
		public static const WM_CLOSE:uint = 0x0010;
		
		//新增
		public function OnLButtonUp(modKeys:uint, point:Point):void
		{
		
		}
		
		public function OnLButtonDown(modKeys:uint, point:Point):void
		{
		
		}
		
		public function OnRButtonUp(modKeys:uint, point:Point):void
		{
		
		}
		
		public function OnMouseMove(modKeys:uint, point:Point):void
		{
		
		}
		
		//
		// IDLE处理
		//
		//FIXME:long count
		public function OnIdle(count:int):Boolean
		{
			return false;
		}
		
		//
		// WM_CREATE 的处理函数
		//
		//FIXME:CREATESTRUCT *cs
		public function OnCreate():Boolean
		{
			return true;
		}
		
		//
		// WM_PAINT 的处理函数
		//
		//FIXME:
		public function OnPaint():void
		{
			// 这是为了调用在 OnPaint 里产生 CPaintDC 的
			// BeginPaint 与 EndPaint
			//CPaintDC	dc(this);	
		}
		
		//FIXME:
		public function PostQuitMessage(n:int):void
		{
		
		}
		
		public function OnDestroy():void
		{
			//::PostQuitMessage(0);
			PostQuitMessage(0);
		}
		
		//FIXME:
		public function MessageBox(str:String):void
		{
			trace("NOTE:[MessageBox] -> ", str);
			try
			{
				throw new Error();
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		public function MessageBox2(str:String, title:String, style:uint):uint
		{
			return IDOK;
		}
		
		//FIXME:
		public function KillTimer(idTimer:uint):Boolean
		{
			return true;
		}
		
		public function PostMessage(i:uint):void
		{
		
		}
		
		public function SendMessage(i:uint):void
		{
		
		}
		
		//FIXME:
		public function SetTimer(id:int, time:int):void
		{
		
		}
		
		//FIXME:
		public function ScreenToClient(pt:Point):void
		{
		
		}
		
		private function onAddToStage(event:Event):void
		{
			trace("CWindow::onAddToStarge -> OnCreate");
			OnCreate();
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			trace("CWindow::onRemovedFromStage -> OnDestory");
			OnDestroy();
		}
		
		private function onEnterFrame(e:Event):void
		{
			//trace("CWindow::onEnterFrame -> OnIdle");
			OnIdle(0);
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			OnLButtonUp(0, new Point(e.stageX, e.stageY));
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			OnMouseMove(0, new Point(e.stageX, e.stageY));
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			OnLButtonDown(0, new Point(e.stageX, e.stageY));
		}
		
		public function CWindow()
		{
			//FIXME:AS3风格的消息分发
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
	}
}