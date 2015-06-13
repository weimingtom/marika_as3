/**
 * Copyright (c) Chihiro.SAKAMOTO (HyperWorks)
 * original code is from 坂本千尋(HyperWorks)
 * アドベンチャーゲームプログラミング　美少女ゲームの作り方
 *
 * @see http://www.kt.rim.or.jp/~lunatic/
 * @see http://www.sbcr.jp/products/479731186X.html
 */

package com.iteye.weimingtom.marika.mkscript.cmd
{
	
	public class CalcValueCommand extends Command
	{
		public var value_addr:uint;
		public var add_value:int;
		
		public function CalcValueCommand(type:int)
		{
			super(type);
		}
		
		public function toString():String
		{
			return "[CalcValueCommand] { value_addr: " + value_addr + ", add_value: " + add_value + " }";
		}
	}
}