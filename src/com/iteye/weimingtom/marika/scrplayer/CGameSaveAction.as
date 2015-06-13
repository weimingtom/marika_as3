package com.iteye.weimingtom.marika.scrplayer
{
	
	public class CGameSaveAction extends CGameLoadSaveAction
	{
		override protected function DoLoadSave():void
		{
			Parent.SaveGame(Selection, Flags);
		}
		
		public function CGameSaveAction()
		{
		
		}
	}
}