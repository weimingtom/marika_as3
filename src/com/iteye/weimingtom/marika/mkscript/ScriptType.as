/**
 * Copyright (c) Chihiro.SAKAMOTO (HyperWorks)
 * original code is from 坂本千尋(HyperWorks)
 * アドベンチャーゲームプログラミング　美少女ゲームの作り方
 *
 * @see http://www.kt.rim.or.jp/~lunatic/
 * @see http://www.sbcr.jp/products/479731186X.html
 */

package com.iteye.weimingtom.marika.mkscript
{
	
	/**
	 * ...
	 * @author
	 */
	public class ScriptType
	{
		//不可以超过8字节
		public static const SCRIPT_MAGIC:String = "[SCRIPT]";
		
		/*
		 * 注意，与相应的类不一定是一对一的，所以要单独集中，放在这个类中
		 */
		
		public static const SET_VALUE_CMD:int = 0x00;
		public static const CALC_VALUE_CMD:int = 0x01;
		public static const TEXT_CMD:int = 0x02;
		public static const CLEAR_TEXT_CMD:int = 0x03;
		public static const GOTO_CMD:int = 0x04;
		public static const IF_TRUE_CMD:int = 0x05;
		public static const IF_FALSE_CMD:int = 0x06;
		public static const IF_BIGGER_CMD:int = 0x07;
		public static const IF_SMALLER_CMD:int = 0x08;
		public static const IF_BIGGER_EQU_CMD:int = 0x09;
		public static const IF_SMALLER_EQU_CMD:int = 0x0A;
		public static const MENU_INIT_CMD:int = 0x0B;
		public static const MENU_ITEM_CMD:int = 0x0C;
		public static const MENU_CMD:int = 0x0D;
		public static const EXEC_CMD:int = 0x0E;
		public static const LOAD_CMD:int = 0x0F;
		public static const UPDATE_CMD:int = 0x10;
		public static const CLEAR_CMD:int = 0x11;
		public static const MUSIC_CMD:int = 0x12;
		public static const STOPM_CMD:int = 0x13;
		public static const SOUND_CMD:int = 0x14;
		public static const SLEEP_CMD:int = 0x15;
		public static const FADEIN_CMD:int = 0x16;
		public static const FADEOUT_CMD:int = 0x17;
		public static const WIPEIN_CMD:int = 0x18;
		public static const WIPEOUT_CMD:int = 0x19;
		public static const CUTIN_CMD:int = 0x1A;
		public static const CUTOUT_CMD:int = 0x1B;
		public static const WHITEIN_CMD:int = 0x1C;
		public static const WHITEOUT_CMD:int = 0x1D;
		public static const FLASH_CMD:int = 0x1E;
		public static const SHAKE_CMD:int = 0x1F;
		public static const MODE_CMD:int = 0x20;
		public static const SYS_LOAD_CMD:int = 0x21;
		public static const SYS_EXIT_CMD:int = 0x22;
		public static const SYS_CLEAR_CMD:int = 0x23;
		public static const END_CMD:int = 0x24;
		
		// CG的位置
		public static const POSITION_BACK:int = 0;
		public static const POSITION_BACKONLY:int = 1;
		public static const POSITION_CENTER:int = 2;
		public static const POSITION_LEFT:int = 3;
		public static const POSITION_RIGHT:int = 4;
		public static const POSITION_OVERLAP:int = 5;
		
		// Mode Flag
		public static const MODE_SYSTEM:int = 0;
		public static const MODE_SCENARIO:int = 1;
		
		// Update Code
		public static const UPDATE_NOW:int = 0;
		public static const UPDATE_OVERLAP:int = 1;
		public static const UPDATE_WIPE:int = 2;
		
		public function ScriptType()
		{
		
		}
	
	}

}