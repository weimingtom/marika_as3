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
	import flash.utils.ByteArray;
	
	public class FileLoader
	{
		private static var contents:Object = new Object();
		private static var classes:Object = new Object();
		
		public function FileLoader()
		{
		
		}
		
		/**
		 *
		 * @param	name
		 * @param	cls
		 */
		public static function insertClass(name:String, cls:Class):void
		{
			contents[name] = clsToUTF8(cls);
			//trace(contents[name]);
			classes[name] = cls;
		}
		
		/**
		 *
		 * @param	name
		 * @param	options
		 * @return
		 */
		public static function open(name:String, options:String = "r"):FileHandle
		{
			if (contents[name] == null)
				return null;
			
			var fileHandle:FileHandle = new FileHandle(name, contents[name] as String, options);
			return fileHandle;
		}
		
		/**
		 *
		 * @param	cls
		 * @return
		 */
		private static function clsToUTF8(cls:Class):String
		{
			var bytes:ByteArray = ByteArray(new cls);
			return bytes.readUTFBytes(bytes.bytesAvailable);
		}
	}
}
