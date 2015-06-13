package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class CDib
	{
		public var _bmd:BitmapData;
		
		public function CDib()
		{
		
		}
		
		public function Create(width:int, height:int, depth:int):Boolean
		{
			_bmd = new BitmapData(width, height, true, 0x00000000);
			return true;
		}
		
		/**
		 * FIXME:注意这里的ox和oy的偏移功能是否正常
		 * @param	file
		 * @param	ox
		 * @param	oy
		 * @return
		 */
		public function LoadBMP(file:CFile, ox:int = 0, oy:int = 0):Boolean
		{
			if (file.bitmap == null)
			{
				throw Error("CDib::LoadBMP 失败!" + file._filename);
				return false;
			}
			
			if (_bmd == null)
			{
				_bmd = new BitmapData(file.bitmap.width, file.bitmap.height, true, 0);
			}
			_bmd.lock();
			trace("CDib::LoadBMP -> file.bitmap == ", file.bitmap);
			//防止重新载入
			_bmd.fillRect(new Rectangle(ox, oy, _bmd.width, _bmd.height), 0x00000000);
			_bmd.draw(file.bitmap, new Matrix(1, 0, 0, 1, ox, oy), null, null, new Rectangle(ox, oy, _bmd.width, _bmd.height), true);
			_bmd.unlock();
			return true;
		}
		
		public function Width():int
		{
			return _bmd.width;
		}
		
		public function Height():int
		{
			return _bmd.height;
		}
		
		//FIXME:
		public function Clear():void
		{
			_bmd.lock();
			_bmd.fillRect(new Rectangle(0, 0, _bmd.width, _bmd.height), 0x00000000);
			_bmd.unlock();
		}
	}
}
