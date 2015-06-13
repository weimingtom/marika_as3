package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectFadeIn extends CViewEffect
	{
		private const STEP:int = 16; //和算法有关
		
		public function EffectFadeIn(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / STEP, dst, src);
		}
		
		/**
		 * 淡入动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.FadeFromBlack(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= STEP)
				return false;
			return true;
		}
	}
}