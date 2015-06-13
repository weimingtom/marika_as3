package com.iteye.weimingtom.marika.scrplayer
{
	
	public class CGameLoadAction extends CGameLoadSaveAction
	{
		override protected function DoLoadSave():void
		{
			Parent.LoadGame(Selection);
		}
		
		public function CGameLoadAction()
		{
		
		}
	}
}