package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWipeOut2 extends CViewEffect
	{
		public function EffectWipeOut2(win:CMainWin, dst:CDrawImage, src:CImage)
		{
			super(win, 1000 / 20, dst, src);
		}
		
		/**
		 * 转出2动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			var result:Boolean = Dst.WipeOut2(EffectRect, EffectCnt++);
			Window.Repaint(EffectRect);
			return result;
		}
	}
}
