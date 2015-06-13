/**
 * 装入·存储动作
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	/**
	 * 游戏装入·存储画面的类
	 */
	public class CGameLoadSaveAction extends CAction
	{
		protected var Selection:int;
		protected var Pressed:Boolean;
		protected var CancelPressed:Boolean;
		protected var Flags:int;
		
		public function CGameLoadSaveAction()
		{
		
		}
		
		override public function Initialize(parent:CMainWin, param1:uint = 0, param2:uint = 0):void
		{
			super.Initialize(parent, param1, param2);
			Selection = -1;
			Pressed = false;
			CancelPressed = false;
			Flags = 0;
		}
		
		override public function LButtonDown(modKeys:uint, point:Point):void
		{
			Pressed = true;
		}
		
		override public function LButtonUp(modKeys:uint, point:Point):void
		{
			Pressed = false;
			if (Selection >= 0)
				DoLoadSave();
		}
		
		override public function RButtonDown(modKeys:uint, point:Point):void
		{
			CancelPressed = true;
		}
		
		override public function RButtonUp(modKeys:uint, point:Point):void
		{
			if (CancelPressed)
				Parent.CancelLoadSaveMenu(Flags);
		}
		
		override public function MouseMove(modKeys:uint, point:Point):void
		{
			var sel:int = Parent.GetLoadSaveSelect(point);
			if (sel != Selection)
			{
				Parent.SelectLoadSaveMenu(Selection, false);
				Selection = sel;
				Parent.SelectLoadSaveMenu(Selection, true);
			}
		}
		
		override public function KeyDown(key:uint):void
		{
			var sel:int;
			
			switch (key)
			{
				case Keyboard.ENTER: 
				case Keyboard.SPACE: // 执行装入存储
					if (Selection >= 0)
						DoLoadSave();
					break;
				
				case Keyboard.ESCAPE: // 取消
					Parent.CancelLoadSaveMenu(Flags);
					break;
				
				case Keyboard.UP: // 选前一项
				{
					sel = Parent.PrevLoadSaveSelect(Selection);
					if (sel != Selection)
					{
						Parent.SelectLoadSaveMenu(Selection, false);
						Selection = sel;
						Parent.SelectLoadSaveMenu(Selection, true);
					}
				}
					break;
				
				case Keyboard.DOWN: // 选后一项
				{
					sel = Parent.NextLoadSaveSelect(Selection);
					if (sel != Selection)
					{
						Parent.SelectLoadSaveMenu(Selection, false);
						Selection = sel;
						Parent.SelectLoadSaveMenu(Selection, true);
					}
				}
					break;
			}
		}
		
		override public function TimedOut(timerId:int):void
		{
			switch (timerId)
			{
				case CMainWin.TimerSleep: 
					Flags |= CMainWin.IS_TIMEDOUT;
					break;
			}
		}
		
		protected function DoLoadSave():void
		{
			throw new IllegalOperationError("abstract function");
		}
	}
}