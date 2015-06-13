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
	public class IfCommand extends Command
	{
		public var flag:uint;
		public var value1:int;
		public var value2:int;
		//TODO:这里可以随机写
		//public var goto_label:GotoLabelRef = new GotoLabelRef(0);
		public var goto_label:int;
		
		public function IfCommand(type:int)
		{
			super(type);
		}
		
		public function toString():String
		{
			return "[IfCommand] { flag: " + flag + ", value1: " + value1 + ", value2: " + value2 + 
			//", goto_label: " + goto_label +
			" }";
		}
	}
}