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
	
	public class LexValue
	{
		//保证value不是null，否则+=会有问题
		public var value:String = "";
		
		//类型值，例如Lexer.IsNumber
		public var type:String;
		
		public function LexValue()
		{
		
		}
	}
}