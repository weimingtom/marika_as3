package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWipeOut extends CViewEffect
	{
		public function EffectWipeOut(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / 8, dst, src);
		}
		
		/**
		 * 转出动作
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.WipeOut(EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= 8)
				return false;
			return true;
		}
	}
}