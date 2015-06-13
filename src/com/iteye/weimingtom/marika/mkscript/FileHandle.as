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
	
	public class FileHandle
	{
		private var _filename:String;
		private var _content:String;
		private var _options:String;
		private var _lines:Array;
		private var _currentLine:int;
		
		/**
		 *
		 * @param	filename
		 * @param	content
		 * @param	options
		 */
		public function FileHandle(filename:String, content:String, options:String = "r")
		{
			_filename = filename;
			_content = content;
			_options = options;
			_lines = content.split("\n");
			_currentLine = 0;
		}
		
		/**
		 * 取一行的内容
		 * @return
		 */
		public function getLineString():String
		{
			var str:String;
			
			if (_currentLine >= _lines.length)
				str = null;
			else
			{
				str = _lines[_currentLine] as String;
				_currentLine++;
			}
			
			return str;
		}
	}
}

