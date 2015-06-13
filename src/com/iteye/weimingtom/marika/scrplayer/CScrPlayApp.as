/**
 * Script Player Application
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Sprite;
	
	/**
	 * 应用程序类
	 */
	[SWF(width = '640', height = '480', backgroundColor = "0x000000", frameRate = '24')]
	public class CScrPlayApp extends Sprite
	{
		public var MainWin:CMainWin;
		
		[Embed(source = '../../../../../../assets/data/sample3.dat', mimeType = 'application/octet-stream')]
		public static var sample3_dat:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/bg001.JPG')]
		private static var bg001:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/bg002.JPG')]
		private static var bg002:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/bg003.JPG')]
		private static var bg003:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/event1.JPG')]
		private static var event1:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU111.png')]
		private static var megu111:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU112.png')]
		private static var megu112:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU113.png')]
		private static var megu113:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU121.png')]
		private static var megu121:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU122.png')]
		private static var megu122:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU123.png')]
		private static var megu123:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU211.png')]
		private static var megu211:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU212.png')]
		private static var megu212:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU213.png')]
		private static var megu213:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU221.png')]
		private static var megu221:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU222.png')]
		private static var megu222:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU223.png')]
		private static var megu223:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU311.png')]
		private static var megu311:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU312.png')]
		private static var megu312:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU313.png')]
		private static var megu313:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU321.png')]
		private static var megu321:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU322.png')]
		private static var megu322:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU323.png')]
		private static var megu323:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/mesi111.png')]
		private static var mesi111:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO111.png')]
		private static var sino111:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO112.png')]
		private static var sino112:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO113.png')]
		private static var sino113:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO121.png')]
		private static var sino121:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO122.png')]
		private static var sino122:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO123.png')]
		private static var sino123:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO211.png')]
		private static var sino211:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO212.png')]
		private static var sino212:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO213.png')]
		private static var sino213:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO221.png')]
		private static var sino221:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO222.png')]
		private static var sino222:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO223.png')]
		private static var sino223:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO224.png')]
		private static var sino224:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO311.png')]
		private static var sino311:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO312.png')]
		private static var sino312:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO313.png')]
		private static var sino313:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO321.png')]
		private static var sino321:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO322.png')]
		private static var sino322:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO323.png')]
		private static var sino323:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO411.png')]
		private static var sino411:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO412.png')]
		private static var sino412:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO413.png')]
		private static var sino413:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO421.png')]
		private static var sino421:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO422.png')]
		private static var sino422:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/SINO423.png')]
		private static var sino423:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/title001.JPG')]
		private static var title001:Class;
		
		public function CScrPlayApp()
		{
			//TODO: 内存问题
			//如果想节约内存，可以考虑减少这里的loadBitmap
			//似乎上面的带元数据的Class对象不会占据太大内存
			//因为每次调用都会产生一个新的BitmapData (实际上是带BitmapData的Bitmap对象)
			//可能的解决办法
			// 1. 使用单张图片代替多张图片
			// 2. 在使用的时候才new出BitmapData对象，然后缓存
			// 3. 不使用BitmapData
			// 4. 使用差分图片，或者使用视频文件代替图片
			
			//TODO: CPU占用率问题
			// 1. 特效只能流畅地运行于fp10.2的非debug版
			//    	<= CDrawImage::FadeCvt 使用tempBmd优化
			//      <= CDrawImage::Mix 使用threshold优化
			// 2. 窗口缩放后运行会变得很慢，即使不是运行特效
			
			CFile.loadData("data/main.scr", sample3_dat);
			CFile.loadBitmap("cgdata/bg001", bg001);
			CFile.loadBitmap("cgdata/bg002", bg002);
			CFile.loadBitmap("cgdata/bg003", bg003);
			CFile.loadBitmap("cgdata/event1", event1);
			CFile.loadBitmap("cgdata/megu111", megu111);
			CFile.loadBitmap("cgdata/megu112", megu112);
			CFile.loadBitmap("cgdata/megu113", megu113);
			CFile.loadBitmap("cgdata/megu121", megu121);
			CFile.loadBitmap("cgdata/megu122", megu122);
			CFile.loadBitmap("cgdata/megu123", megu123);
			CFile.loadBitmap("cgdata/megu211", megu211);
			CFile.loadBitmap("cgdata/megu212", megu212);
			CFile.loadBitmap("cgdata/megu213", megu213);
			CFile.loadBitmap("cgdata/megu221", megu221);
			CFile.loadBitmap("cgdata/megu222", megu222);
			CFile.loadBitmap("cgdata/megu223", megu223);
			CFile.loadBitmap("cgdata/megu311", megu311);
			CFile.loadBitmap("cgdata/megu312", megu312);
			CFile.loadBitmap("cgdata/megu313", megu313);
			CFile.loadBitmap("cgdata/megu321", megu321);
			CFile.loadBitmap("cgdata/megu322", megu322);
			CFile.loadBitmap("cgdata/megu323", megu323);
			CFile.loadBitmap("cgdata/mesi111", mesi111);
			CFile.loadBitmap("cgdata/sino111", sino111);
			CFile.loadBitmap("cgdata/sino112", sino112);
			CFile.loadBitmap("cgdata/sino113", sino113);
			CFile.loadBitmap("cgdata/sino121", sino121);
			CFile.loadBitmap("cgdata/sino122", sino122);
			CFile.loadBitmap("cgdata/sino123", sino123);
			CFile.loadBitmap("cgdata/sino211", sino211);
			CFile.loadBitmap("cgdata/sino212", sino212);
			CFile.loadBitmap("cgdata/sino213", sino213);
			CFile.loadBitmap("cgdata/sino221", sino221);
			CFile.loadBitmap("cgdata/sino222", sino222);
			CFile.loadBitmap("cgdata/sino223", sino223);
			CFile.loadBitmap("cgdata/sino224", sino224);
			CFile.loadBitmap("cgdata/sino311", sino311);
			CFile.loadBitmap("cgdata/sino312", sino312);
			CFile.loadBitmap("cgdata/sino313", sino313);
			CFile.loadBitmap("cgdata/sino321", sino321);
			CFile.loadBitmap("cgdata/sino322", sino322);
			CFile.loadBitmap("cgdata/sino323", sino323);
			CFile.loadBitmap("cgdata/sino411", sino411);
			CFile.loadBitmap("cgdata/sino412", sino412);
			CFile.loadBitmap("cgdata/sino413", sino413);
			CFile.loadBitmap("cgdata/sino421", sino421);
			CFile.loadBitmap("cgdata/sino422", sino422);
			CFile.loadBitmap("cgdata/sino423", sino423);
			CFile.loadBitmap("cgdata/title001", title001);
			
			MainWin = new CMainWin();
			addChild(MainWin);
		}
	}
}
