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
	public class FileReader
	{
		private static const DEBUG_GETSTRING:Boolean = false; //-->GetString stack
		
		private var _filename:String;
		private var _lineno:int;
		private var _fp:FileHandle;
		private var _readBuffer:String;
		
		//逐行读入
		public function GetString():String
		{
			_lineno++;
			_readBuffer = _fp.getLineString();
			if (_readBuffer == null)
				return null;
			
			if (DEBUG_GETSTRING)
			{
				trace("_readBuffer:", _readBuffer);
				if (_readBuffer.substr(0, 4) == "goto")
				{
					try
					{
						throw new Error();
					}
					catch (e:Error)
					{
						trace(e.getStackTrace());
					}
				}
			}
			
			while (_readBuffer.length > 0 && (_readBuffer.substr(_readBuffer.length - 1) == '\n' || _readBuffer.substr(_readBuffer.length - 1) == '\r'))
			{
				//trace("delete return");
				_readBuffer = _readBuffer.substr(0, _readBuffer.length - 1);
			}
			
			return _readBuffer;
		}
		
		/**
		 *
		 * @return
		 */
		public function GetFileName():String
		{
			return _filename;
		}
		
		/**
		 *
		 * @return
		 */
		public function GetLineNo():int
		{
			return _lineno;
		}
		
		/**
		 * 判断是否成功开启文件
		 * @return
		 */
		public function IsOpen():Boolean
		{
			return _fp != null;
		}
		
		/**
		 *
		 * @param	filename
		 */
		public function FileReader(filename:String)
		{
			_filename = filename;
			_lineno = 0;
			_fp = FileLoader.open(filename, "r");
		}
	}
}
