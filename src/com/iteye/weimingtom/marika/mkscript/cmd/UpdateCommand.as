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
	public class UpdateCommand extends Command
	{
		public var flag:int;
		
		public function UpdateCommand(type:int)
		{
			super(type);
		}
		
		public function toString():String
		{
			return "[UpdateCommand] { flag: " + flag + " }";
		}
	}
}