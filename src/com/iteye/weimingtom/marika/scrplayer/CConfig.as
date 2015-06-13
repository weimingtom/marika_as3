/**
 * Script player 组态设定
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	
	public class CConfig
	{
		public static const MAX_VALUES:uint = 100;
		
		public static const CompanyName:String = "HyperWorks";
		public static const ApplicationName:String = "ScriptPlayer";
		public static const ApplicationTitle:String = "Script player";
		
		public static const WindowWidth:uint = 640;
		public static const WindowHeight:uint = 480;
		
		public static const CGPATH:String = "cgdata/";
		public static const SCRIPTPATH:String = "data/";
		public static const WAVEPATH:String = "wave/";
		
		public static const MessageFont:uint = 16;
		public static const MessageStyle:uint = 0; //	FW_BOLD
		public static const MessageWidth:uint = 72;
		public static const MessageLine:uint = 4;
		
		public static const WM_KICKIDLE:uint = 0x036A;
		
		public function CConfig()
		{
		
		}
	}
}