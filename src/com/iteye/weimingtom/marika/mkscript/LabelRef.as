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
	public class LabelRef
	{
		public var next:LabelRef;
		//public var label_ref:GotoLabelRef;
		public var label_ref_address:uint;
		
		public function LabelRef(next:LabelRef, label_ref_address:uint) //label_ref:GotoLabelRef) 
		{
			this.next = next;
			//this.label_ref = label_ref;
			this.label_ref_address = label_ref_address;
		}
	}

}