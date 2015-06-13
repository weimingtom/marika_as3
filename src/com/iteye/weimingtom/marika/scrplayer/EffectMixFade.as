package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectMixFade extends CViewEffect
	{
		public function EffectMixFade(win:CMainWin, dst:CDrawImage, src:CImage, rect:Rectangle)
		{
			super(win, 1000 / 8, dst, src, rect);
		}
		
		/**
		 * 淡化合成动作的1步
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.Mix(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= 8)
				return false;
			return true;
		}
	}
}