/**
 * Action 类
 * 此类是依照情况不定期产生消息
 * 是从CMainWin调用
 *
 */
package com.iteye.weimingtom.marika.scrplayer
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	
	public class CAction
	{
		private function error():void
		{
			try
			{
				throw new IllegalOperationError("abstract function");
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		protected var ScriptRunning:Boolean;
		protected var Parent:CMainWin;
		protected var Param1:uint;
		protected var Param2:uint;
		
		public function IsScriptRunning():Boolean
		{
			return ScriptRunning;
		}
		
		public function CAction(scriptRun:Boolean = false)
		{
			ScriptRunning = scriptRun;
		}
		
		public function Initialize(parent:CMainWin, param1:uint = 0, param2:uint = 0):void
		{
			Parent = parent;
			Param1 = param1;
			Param2 = param2;
		}
		
		public function Pause():void
		{
			error();
		}
		
		public function Resume():void
		{
			error();
		}
		
		public function LButtonDown(modKeys:uint, point:Point):void
		{
			error();
		}
		
		public function LButtonUp(modKeys:uint, point:Point):void
		{
			error();
		}
		
		public function RButtonDown(modKeys:uint, point:Point):void
		{
			error();
		}
		
		public function RButtonUp(modKeys:uint, point:Point):void
		{
			error();
		}
		
		public function MouseMove(modKeys:uint, point:Point):void
		{
			error();
		}
		
		public function KeyDown(key:uint):void
		{
			error();
		}
		
		public function TimedOut(timerId:int):void
		{
			error();
		}
		
		public function IdleAction():Boolean
		{
			error();
			return false;
		}
		
		public function MusicDone(music:int):void
		{
			error();
		}
		
		public function WipeDone():void
		{
			error();
		}
		
		public function WaveDone():void
		{
			error();
		}
	}
}