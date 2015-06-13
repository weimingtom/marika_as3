package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWhiteIn extends CViewEffect
	{
		public function EffectWhiteIn(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / 16, dst, src);
		}
		
		/**
		 * 淡入(白进)动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.FadeFromWhite(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= 16)
				return false;
			return true;
		}
	}
}