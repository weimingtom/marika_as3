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
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author
	 */
	public class ExecCommand extends Command
	{
		private const NO_BYTEARRY_CLEAR:Boolean = true;
		
		public var path_len:uint;
		public var message:String;
		public var nMessageTail:int;
		public var bytes:ByteArray = new ByteArray();
		
		public function ExecCommand(type:int)
		{
			super(type);
		}
		
		public function toString():String
		{
			return "[ExecCommand] { path_len: " + path_len + ", message: " + message + " }";
		}
		
		/**
		 * 将字符串登录在表格里
		 * @param	msg
		 * @param	limit
		 * @return
		 */
		public function AddMessage(msg:String, limit:int):uint
		{
			this.message = msg;
			if (NO_BYTEARRY_CLEAR)
			{
				this.bytes.position = 0;
				this.bytes.length = 0;
			}
			else
			{
				Object(this.bytes).clear();
			}
			
			this.bytes.writeMultiByte(this.message, "gbk");
			var n:int = this.bytes.position % 4;
			this.nMessageTail = n >= 0 ? (4 - n) : 0;
			for (var i:int = 0; i < this.nMessageTail; i++)
			{
				this.bytes.writeByte(0);
			}
			this.bytes.position = 0;
			return this.bytes.bytesAvailable;
		}
	}
}