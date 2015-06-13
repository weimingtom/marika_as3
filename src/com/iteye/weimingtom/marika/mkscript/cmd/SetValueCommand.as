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
	
	/**
	 * ...
	 * @author
	 */
	public class SetValueCommand extends Command
	{
		public var value_addr:uint;
		public var set_value:int;
		
		public function SetValueCommand(type:uint)
		{
			super(type);
		}
		
		public function toString():String
		{
			return "[SetValueCommand] { value_addr: " + value_addr + ", set_value: " + set_value + " }";
		}
	}
}
