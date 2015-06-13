package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWhiteOut extends CViewEffect
	{
		public function EffectWhiteOut(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / 16, dst, src);
		}
		
		/**
		 * 淡出(白出)动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.FadeToWhite(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= 16)
				return false;
			return true;
		}
	}
}