/**
 * MCI 类/CD-DA/Wave 类
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	
	/**
	 * MCI类
	 */
	public class CMci
	{
		protected var Window:CWindow;
		protected var device:String;
		protected var errTitle:String;
		protected var Id:uint;
		
		public function GetId():uint
		{
			return Id;
		}
		
		public function CMci(_device:String, _errTitle:String)
		{
			Id = 0;
			device = _device;
			errTitle = _errTitle;
		}
		
		/*
		   inline CMci::~CMci()
		   {
		   Close();
		   }
		 */
		
		/**
		 * 开启
		 * @param	window
		 * @return
		 */
		public function Open(window:CWindow):Boolean
		{
			Window = window;
			return true;
		}
		
		/**
		 * 关闭
		 * @return
		 */
		public function Close():Boolean
		{
			return true;
		}
		
		/**
		 * 演奏(曲目编号)
		 * @param	no
		 * @return
		 */
		public function Play(no:int):Boolean
		{
			return false;
		}
		
		/**
		 * 演奏(档名)
		 * @param	name
		 * @return
		 */
		public function Play2(name:String):Boolean
		{
			return false;
		}
		
		/**
		 * 重放
		 * @return
		 */
		public function Replay():Boolean
		{
			return false;
		}
		
		/**
		 * 停止
		 * @return
		 */
		public function Stop():Boolean
		{
			return false;
		}
		
		/**
		 * 显示错误消息
		 * @param	err
		 */
		public function MciErrorMessageBox(err:uint):void
		{
		/*
		   char errstr[256];
		   mciGetErrorString(err, errstr, sizeof(errstr));
		   Window.MessageBox(errstr, errTitle);
		 */
		}
		
		/**
		 * 送出MCI的open命令(共通部分)
		 * @param	command
		 * @return
		 */
		public function MciOpen(command:String):Boolean
		{
			/*
			   DWORD err;
			   char	result[128];
			   if ((err = mciSendString(command, result, sizeof(result), 0)) != 0)
			   {
			   MciErrorMessageBox(err);
			   return false;
			   }
			   char *p;
			   Id = strtol(result, &p, 0);
			   return true;
			 */
			return false;
		}
		
		/**
		 * 送出MCI的open命令(无参数)
		 * @return
		 */
		public function MciOpen2():Boolean
		{
			/*
			   char	command[128];
			   sprintf(command, "open %s wait", device);
			   return MciOpen(command);
			 */
			return false;
		}
		
		/**
		 * 送出MCI的open命令(设定元素)
		 * @param	dev
		 * @param	element
		 * @return
		 */
		public function MciOpen3(dev:String, element:String):Boolean
		{
			/*
			   char	command[_MAX_PATH + 128];
			   sprintf(command, "open \"%s!%s\" alias %s wait", dev, element, device);
			   return MciOpen(command);
			 */
			return false;
		}
		
		/**
		 * 送出MCI的close命令
		 * @return
		 */
		public function MciClose():Boolean
		{
			/*
			   Id = 0;
			   char	command[128];
			   sprintf(command, "close %s wait", device);
			   if (mciSendString(command, NULL, 0, 0) != 0)
			   return false;
			   return true;
			 */
			return false;
		}
		
		/**
		 * 送出MCI的play命令
		 * @param	request
		 * @return
		 */
		public function MciPlay(request:String):Boolean
		{
			/*
			   char	command[256];
			   sprintf(command, "play %s %s notify", device, request);
			   DWORD	err;
			   if ((err = mciSendString(command, NULL, 0, * Window)) != 0)
			   {
			   MciErrorMessageBox(err);
			   return false;
			   }
			   return true;
			 */
			return false;
		}
		
		/**
		 * 送出MCI的stop命令
		 * @return
		 */
		public function MciStop():Boolean
		{
			/*
			   char	command[128];
			   sprintf(command, "stop %s wait", device);
			   if (mciSendString(command, NULL, 0, 0) != 0)
			   return false;
			   return true;
			 */
			return false;
		}
		
		/**
		 * 送出MCI的set命令
		 * @param	request
		 * @return
		 */
		public function MciSet(request:String):Boolean
		{
			/*
			   char	command[128];
			   sprintf(command, "set %s %s wait", device, request);
			   DWORD	err;
			   if ((err = mciSendString(command, NULL, 0, 0)) != 0)
			   {
			   MciErrorMessageBox(err);
			   return false;
			   }
			   return true;
			 */
			return false;
		}
		
		/**
		 * 送出MCI的status命令
		 * @param	request
		 * @param	result
		 * @param	resultlen
		 * @return
		 */
		public function MciStatus(request:String, result:String, resultlen:int):Boolean
		{
			/*
			   char	command[128];
			   sprintf(command, "status %s %s wait", device, request);
			   DWORD err;
			   if ((err = mciSendString(command, result, resultlen, 0)) != 0)
			   {
			   MciErrorMessageBox(err);
			   return false;
			   }
			   return true;
			 */
			return false;
		}
	}
}