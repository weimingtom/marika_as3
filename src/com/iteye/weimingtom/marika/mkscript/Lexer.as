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
	public class Lexer
	{
		//调试开关
		private static const LEXER_DEBUG_01:Boolean = false; //废弃
		private static const LEXER_DEBUG_02:Boolean = false; //>>压入数组的符号	
		
		// Token的种类
		public static const IsError:String = "IsError"; //-1
		public static const IsNumber:String = "IsNumber";
		public static const IsString:String = "IsString";
		public static const IsDelimitter:String = "IsDelimitter";
		public static const IsLabel:String = "IsLabel";
		public static const IsMinus:String = "IsMinus";
		// 内部使用
		private static const IsSpace:String = "IsSpace";
		private static const IsTerminater:String = "IsTerminater";
		private static const IsQuotation:String = "IsQuotation";
		
		protected var nToken:int;
		protected var Value:Array = new Array(); //vector<LexValue>
		protected var Count:int;
		
		private var _pos:int = 0;
		
		public function Lexer(str:String)
		{
			parse(str);
		}
		
		private function parse(str:String):void
		{
			for (nToken = 0; ; nToken++)
			{
				if (LEXER_DEBUG_01)
					trace("[" + _pos + "/" + str.length + "]", str.substr(_pos, 1));
				SkipSpace(str);
				if (_pos >= str.length || str.substr(_pos, 1) == ';')
				{
					//trace("===========");
					break;
				}
				
				var type:String = CharType(str.charCodeAt(_pos));
				
				if (type == Lexer.IsTerminater && type == Lexer.IsSpace)
					break;
				
				var value:LexValue = new LexValue();
				
				if (type == Lexer.IsQuotation)
				{
					value.type = IsString;
					_pos++;
					while (_pos < str.length && CharType(str.charCodeAt(_pos)) != Lexer.IsQuotation)
					{
						if (_ismbblead(str.charCodeAt(_pos)))
						{
							value.value += str.substr(_pos, 1);
							_pos++;
						}
						value.value += str.substr(_pos, 1);
						_pos++;
					}
					if (_pos < str.length)
						_pos++;
				}
				else
				{
					if (str.substr(_pos, 1) == '-' && CharType(str.charCodeAt(_pos + 1)) == Lexer.IsNumber)
					{
						value.value += '-';
						value.type = Lexer.IsMinus;
						_pos++;
					}
					else
					{
						if (str.substr(_pos, 1) == '*' && nToken == 0)
							type = Lexer.IsLabel;
						
						value.type = type;
						while (_pos < str.length)
						{
							//-------------------------------
							//see MatchType
							var ch:uint = str.charCodeAt(_pos)
							var t:String = CharType(ch);
							var res:Boolean = true;
							
							switch (type)
							{
								case IsLabel: 
									if (ch == '*'.charCodeAt())
									{
										res = true;
										break;
									}
								// no break
								
								case IsNumber: 
									if (t == Lexer.IsString)
									{
										type = Lexer.IsString;
										res = (t == Lexer.IsString || t == Lexer.IsNumber);
										break; //这里太诡异了，必须break才不会出错
									}
								// no break
								
								case IsString: 
									res = (t == Lexer.IsString || t == Lexer.IsNumber);
									break;
								
								default: 
									res = (type == t);
									break;
							}
							
							if (res == false)
								break;
							
							//-------------------------------
							
							if (_ismbblead(str.charCodeAt(_pos)))
							{
								value.value += str.substr(_pos, 1);
								_pos++;
							}
							value.value += str.substr(_pos, 1);
							_pos++;
						}
						if (value.type == Lexer.IsNumber)
							value.type = type;
					}
				}
				if (LEXER_DEBUG_02)
					trace(">>[" + value.type + "]", value.value);
				Value.push(value);
			}
			Count = 0;
		}
		
		public function NumToken():int
		{
			return nToken;
		}
		
		public function NextToken():void
		{
			Count++;
		}
		
		public function GetString(index:int = -1):String
		{
			if (index >= 0)
				Count = index;
			if (Count >= nToken)
				return null;
			return (Value[Count++] as LexValue).value;
		}
		
		/**
		 * 注意：不需要第一个参数，直接赋值
		 * 用isNaN判断合法性
		 * @param	index
		 * @return
		 */
		public function GetValue(index:int = -1):Number
		{
			var value:int;
			var minus:Boolean = false;
			var type:String = GetType(index);
			if (type == IsMinus)
			{
				minus = true;
				NextToken();
				type = GetType();
			}
			if (type != IsNumber)
				return Number.NaN;
			var p:String = GetString();
			if (p == null)
				return Number.NaN;
			
			//char *q;
			var v:int = int(p);
			value = minus ? -v : v;
			return value;
		}
		
		public function GetType(index:int = -1):String
		{
			if (index >= 0)
				Count = index;
			if (Count >= nToken)
				return Lexer.IsError;
			return (Value[Count] as LexValue).type;
		}
		
		protected function SkipSpace(p:String):void
		{
			while (_pos < p.length && isspace(p.charCodeAt(_pos)))
				_pos++;
			//return p;
		}
		
		/**
		 *
		 * 注意，此函数无法处理字符串指针(_pos)溢出的情况
		 * @param	ch
		 * @return
		 */
		protected function CharType(ch:uint):String
		{
			if (ch == '\n'.charCodeAt())
				return Lexer.IsTerminater;
			if (isdigit(ch))
				return Lexer.IsNumber;
			if (isalpha(ch) || _ismbblead(ch) || ch == '_'.charCodeAt())
				return Lexer.IsString;
			if (isspace(ch))
				return Lexer.IsSpace;
			if (ch == '"'.charCodeAt())
				return Lexer.IsQuotation;
			if (ch == '-'.charCodeAt())
				return Lexer.IsMinus;
			return Lexer.IsDelimitter;
		}
		
		/**
		 * 该函数主要是用来测试一个字符是否是多字节字符。
		 * 如果整数c是第一个字节的多字节字符，返回一个非零值。
		 * @param	c
		 * @return
		 */
		private function _ismbblead(c:uint):Boolean
		{
			//trace(c);
			//FIXME:这里貌似有问题，还需要包括其它非保留的字符集
			return c > 255 || (/[\(\)\[\]]/).test(String.fromCharCode(c));
			//return (/\S/).test(String.fromCharCode(c));
		}
		
		/**
		 * 判断字符c是否为空白符
		 * @param	c
		 * @return
		 */
		private function isspace(c:uint):Boolean
		{
			return (/\s/).test(String.fromCharCode(c));
		}
		
		/**
		 * 判断字符c是否为数字
		 * @param	c
		 * @return
		 */
		private function isdigit(c:uint):Boolean
		{
			return (/\d/).test(String.fromCharCode(c));
		}
		
		/**
		 * 判断字符c是否为英文字母
		 * @param	c
		 * @return
		 */
		private function isalpha(c:uint):Boolean
		{
			return (/[A-Za-z]/).test(String.fromCharCode(c));
		}
	}
}