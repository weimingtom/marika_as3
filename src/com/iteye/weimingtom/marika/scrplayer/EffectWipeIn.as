package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWipeIn extends CViewEffect
	{
		public function EffectWipeIn(win:CMainWin, dst:CDrawImage, src:CImage, rect:Rectangle)
		{
			super(win, 1000 / 8, dst, src, rect);
		}
		
		/**
		 * 继承 effect 的步骤动作
		 * 要处理一项项步骤时，每个动作都需要花时间等待，因此
		 * WipeIn的转入动作
		 * @return
		 */
		override public function Step():Boolean
		{
			Dst.WipeIn(Src, EffectRect, EffectCnt);
			Window.Repaint(EffectRect);
			if (++EffectCnt >= 8)
				return false;
			return true;
		}
	}
}
