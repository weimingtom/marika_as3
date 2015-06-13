package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectFadeOut extends CViewEffect
	{
		private const STEP:int = 16; //和算法有关
		
		public function EffectFadeOut(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / STEP, dst, src);
		}
		
		/**
		 * 淡出动作的1步
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.FadeToBlack(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= STEP)
				return false;
			return true;
		}
	}
}