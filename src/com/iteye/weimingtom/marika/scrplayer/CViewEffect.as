/**
 * 画面特效
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	
	/**
	 * Effect类
	 */
	public class CViewEffect
	{
		protected var Window:CMainWin;
		protected var Dst:CDrawImage;
		protected var Src:CImage;
		
		protected var TimeBase:uint;
		protected var EffectCnt:int;
		protected var EffectRect:Rectangle;
		protected var lastTime:uint;
		
		public function Step():Boolean
		{
			throw new IllegalOperationError("abstract function");
			return false;
		}
		
		private static const default_rect:Rectangle = new Rectangle(0, 0, CConfig.WindowWidth, CConfig.WindowHeight);
		
		public function CViewEffect(win:CMainWin, step:uint, dst:CDrawImage, src:CImage = null, rect:Rectangle = null)
		{
			if (rect == null)
				rect = CViewEffect.default_rect;
			
			Window = win;
			Dst = dst;
			Src = src;
			TimeBase = step;
			EffectRect = rect.clone(); //TODO:???
			EffectCnt = 0;
			lastTime = 0;
		}
		
		public function Step2(time:uint):Boolean
		{
			if (TimeBase <= time - lastTime)
			{
				lastTime = time;
				return Step();
			}
			return true;
		}
	}
}