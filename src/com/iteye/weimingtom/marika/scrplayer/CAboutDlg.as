/**
 * 版本消息对话框
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	
	/**
	 * Dialog类的继承与消息处理的执行
	 */
	public class CAboutDlg extends CDialog
	{
		public function CAboutDlg()
		{
		
		}
		
		/**
		 * “本软件”的消息处理
		 * 对话框初始化，IDC_COMPANY和IDC_TITLE重写
		 * @param	uMsg
		 * @param	wParam
		 * @param	lParam
		 * @return
		 */
		public function DlgProc(uMsg:uint, wParam:uint, lParam:uint):Boolean
		{
			/*
			   switch (uMsg)
			   {
			   case WM_INITDIALOG: // 初始化
			   {
			   //char	copyright[256];
			   //sprintf(copyright, "Copyright(c) %s %s", __DATE__ + 7, CompanyName);
			   var copyright:String = "Copyright(c) ???? " + CConfig.CompanyName;
			   SetDlgItemText(IDC_COMPANY, copyright);
			   SetDlgItemText(IDC_TITLE, ApplicationTitle);
			   CenterWindow();
			   }
			   break;
			
			   case WM_COMMAND: // 按下按钮
			   switch (LOWORD(wParam))
			   {
			   case IDOK:
			   case IDCANCEL:
			   EndDialog(hDlg, LOWORD(wParam));
			   break;
			   }
			   break;
			
			   default:
			   return false;
			   }
			   return true;
			 */
			return false;
		}
	}
}