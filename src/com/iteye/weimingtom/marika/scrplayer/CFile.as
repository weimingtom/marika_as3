package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	
	public class CFile
	{
		private static var _classes:Object = new Object();
		private static var _bitmaps:Object = new Object();
		
		private static var _dat_classes:Object = new Object();
		private static var _dat_bytes:Object = new Object();
		
		public static function loadBitmap(name:String, cls:Class):void
		{
			_classes[name] = cls;
			_bitmaps[name] = Bitmap(new cls);
		}
		
		public static function loadData(name:String, cls:Class):void
		{
			_dat_classes[name] = cls;
			_dat_bytes[name] = ByteArray(new cls);
		}
		
		//------------------------------------------
		
		public static const read:int = 0;
		public static const write:int = 1;
		
		public var bitmap:Bitmap;
		public var _bytes:ByteArray;
		public var _filename:String;
		
		public function CFile(file:String, mode:int = CFile.read)
		{
			Open(file, mode);
		}
		
		public function Open(file:String, mode:int = CFile.read):Boolean
		{
			//FIXME:ADD
			//添加，方便调试
			this._filename = file;
			
			bitmap = CFile._bitmaps[file];
			if (bitmap)
				return true;
			else
			{
				//return false;
				_bytes = CFile._dat_bytes[file];
				trace("open hex file:", file);
				if (_bytes)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		public function Close():Boolean
		{
			return true;
		}
		
		public function IsOk():Boolean
		{
			return true;
		}
		
		//FIXME:
		public function Read(bytes:ByteArray, length:int):int
		{
			var pos:int = bytes.position;
			_bytes.position = 0;
			_bytes.readBytes(bytes, 0, length);
			return bytes.length - pos;
		}
		
		//FIXME:
		public function GetFileSize():int
		{
			if (_bytes)
			{
				return _bytes.length;
			}
			return 0;
		}
	}
}
