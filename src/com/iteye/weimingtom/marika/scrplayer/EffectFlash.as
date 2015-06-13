package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectFlash extends CViewEffect
	{
		public function EffectFlash(win:CMainWin, dst:CDrawImage)
		{
			super(win, 1000 / 24, dst);
		}
		
		/**
		 * 闪动动作的步骤
		 * @return
		 */
		override public function Step():Boolean
		{
			/*
			   switch (EffectCnt++)
			   {
			   case 0:	// 涂白
			   {
			   CClientDC	dc(Window);
			   dc.SetBkColor(RGB(255, 255, 255));
			   dc.ExtTextOut(0, 0, ETO_OPAQUE, &EffectRect, 0, 0, NULL);
			   }
			   break;
			
			   case 1:	// 复原
			   Window.Repaint(EffectRect);
			   break;
			
			   default: // 一拍就结束是因为可能会重复使用
			   return false;
			   }
			   return true;
			 */
			return false;
		}
	}

}