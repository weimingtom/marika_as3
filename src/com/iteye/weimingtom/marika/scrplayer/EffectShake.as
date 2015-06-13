package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Rectangle;
	
	public class EffectShake extends CViewEffect
	{
		public function EffectShake(win:CMainWin, dst:CDrawImage)
		{
			super(win, 1000 / 24, dst);
		}
		
		/**
		 * 摇晃动作的步骤
		 * 将CG缓冲区“挪动”显示在屏幕上，以表现“摇晃”的效果
		 * @return
		 */
		override public function Step():Boolean
		{
			/*
			   var x:int, y:int, w:int, h:int, ox:int, oy:int;
			   var rect:Rectangle = new Rectangle();
			
			   switch (EffectCnt)
			   {
			   case 0:
			   case 2:
			   x = 0;
			   y = 0;
			   w = WindowWidth;
			   h = WindowHeight - 10;
			   ox = 0;
			   oy = 10;
			   rect.SetRect(0, WindowHeight - 10, WindowWidth, WindowHeight);
			   break;
			
			   case 4:
			   x = 0;
			   y = 0;
			   w = WindowWidth;
			   h = WindowHeight;
			   ox = 0;
			   oy = 0;
			   rect.SetRect(0, 0, 0, 0);
			   break;
			
			   case 1:
			   case 3:
			   x = 0;
			   y = 10;
			   w = WindowWidth;
			   h = WindowHeight - 10;
			   ox = 0;
			   oy = 0;
			   rect.SetRect(0, 0, WindowWidth, 10);
			   break;
			
			   default:
			   return false;
			   }
			   CClientDC	dc(Window);
			   Dst.Draw(dc, x, y, w, h, ox, oy);
			   if (x != ox || y != oy)
			   {
			   dc.SetBkColor(RGB(0, 0, 0));
			   dc.ExtTextOut(0, 0, ETO_OPAQUE, &rect, 0, 0, NULL);
			   }
			   if (++EffectCnt >= 5)
			   return false;
			   return true;
			 */
			return false;
		}
	}
}