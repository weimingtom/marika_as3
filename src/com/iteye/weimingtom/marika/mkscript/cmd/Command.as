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
	public class Command
	{
		public var type:uint;
		public var size:uint;
		
		/**
		 * 从命令表格配置内存
		 * @throws
		 */
		/*
		   public function AllocCommand(size:int, cmd:int):Object
		   {
		   //FIXME:???
		   if (ncommand + size >= MAX_COMMAND)
		   throw Error("command table overflow");
		
		   void *p = command_buffer + ncommand;
		   ncommand += size;
		
		   memset(p, 0, size);
		   ((single_cmd_t *)p)->type = cmd;
		   ((single_cmd_t *)p)->size = size;
		
		   return p;
		
		   return null;
		   }
		 */
		
		public function Command(type:int)
		{
			this.type = type;
		}
	}
}