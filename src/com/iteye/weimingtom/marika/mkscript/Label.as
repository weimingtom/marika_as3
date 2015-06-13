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
	public class Label
	{
		public var label:String;
		public var line:uint;
		public var jmp_addr:int;
		public var ref:LabelRef;
		
		public function Label(label:String, line:uint, jmp_addr:int, ref:LabelRef)
		{
			this.label = label;
			this.line = line;
			this.jmp_addr = jmp_addr;
			this.ref = ref;
		}
	}
}