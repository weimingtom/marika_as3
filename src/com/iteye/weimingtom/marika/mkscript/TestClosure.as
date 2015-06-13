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
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author
	 */
	public class TestClosure extends Sprite
	{
		private var time:int = 0;
		
		public function TestClosure()
		{
			(function():void
			{
				trace("time:", time);
			})();
			
			var time:int = 1;
			(function():void
			{
				var time:int = 2;
				trace("time:", time);
			})();
			(function():void
			{
				trace("time:", time);
			})();
		/**
		 * 输出：0, 2, 1
		 *
		 */
		}
	}
}