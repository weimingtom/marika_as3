package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectWipeIn2 extends CViewEffect
	{
		public function EffectWipeIn2(win:CMainWin, dst:CDrawImage, src:CImage, rect:Rectangle)
		{
			super(win, 1000 / 20, dst, src, rect);
		}
		
		/**
		 * 转入2动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			var result:Boolean = Dst.WipeIn2(Src, EffectRect, EffectCnt++);
			Window.Repaint(EffectRect);
			return result;
		}
	}
}