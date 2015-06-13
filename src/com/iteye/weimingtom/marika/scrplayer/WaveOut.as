package com.iteye.weimingtom.marika.scrplayer
{
	
	public class WaveOut extends CMci
	{
		override public function Play2(str:String):Boolean
		{
			return false;
		}
		
		public function WaveOut()
		{
			super("sound", "Wave Audio的错误");
		}
	}
}
