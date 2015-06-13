/**
 * 24Bits/Pixel图像
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BlendMode;
	import flash.utils.ByteArray;
	
	/**
	 * 专给24bit使用的DIB类
	 */
	public class CImage extends CDib
	{
		/**
		 * 构造函数
		 * @param	width
		 * @param	height
		 */
		public function CImage(width:int = 0, height:int = 0)
		{
			if (width == 0 && height == 0)
				return;
			Create2(width, height);
		}
		
		/**
		 * DIB的制作
		 * @param	width
		 * @param	height
		 * @return
		 */
		public function Create2(width:int, height:int):Boolean
		{
			return super.Create(width, height, 24);
		}
		
		/**
		 * 由CGPATH指定之数据夹读取BMP档
		 * @param	name
		 * @param	ox
		 * @param	oy
		 * @return
		 */
		public function LoadImage(name:String, ox:int = 0, oy:int = 0):Boolean
		{
			var path:String;
			//FIXME：在AS3版中，后缀名不一定是.bmp，所以无视之
			//因为AS3使用预加载文件池
			//所以受文件预加载池的映射表键名规则影响
			if (false)
			{
				path = CConfig.CGPATH + name + ".bmp";
			}
			else
			{
				path = CConfig.CGPATH + name;
			}
			var file:CFile = new CFile(path);
			if (!file.IsOk())
				return false;
			return LoadBMP(file, ox, oy);
		}
		
		/**
		 * 绘制涂满矩形
		 * @param	rect
		 * @param	color
		 */
		public function FillRect(rect:Rectangle, color:uint):void
		{
			/*
			   const unsigned char b = GetBValue(color);
			   const unsigned char g = GetGValue(color);
			   const unsigned char r = GetRValue(color);
			
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   byte_t *p = (byte_t *)GetBits(rect.left, y);
			   for (int x = rect.left; x < rect.right; x++)
			   {
			 *p++ = b;
			 *p++ = g;
			 *p++ = r;
			   }
			   }
			 */
			_bmd.lock();
			_bmd.fillRect(rect, 0xFF000000 | color);
			_bmd.unlock();
		}
		
		/**
		 * 区域的复制
		 * @param	image
		 * @param	rect
		 */
		public function Copy(image:CImage, rect:Rectangle):void
		{
			/*
			   int	len = rect.Width() * 3;
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   memcpy(GetBits(rect.left, y), image->GetBits(rect.left, y), len);
			   }
			 */
			_bmd.lock();
			if (false)
			{
				//不考虑透明色
				_bmd.copyPixels(image._bmd, rect, new Point(rect.x, rect.y));
			}
			else
			{
				//考虑透明色
				_bmd.draw(image._bmd, null, null, null, rect);
			}
			_bmd.unlock();
		}
		
		/**
		 * 复制时考虑透明色
		 * @param	image
		 * @param	rect
		 * @param	trans_color
		 */
		public function MixImage(image:CImage, rect:Rectangle, trans_color:uint = 0x00FF00):void
		{
			/*
			   const unsigned char trans_b = GetBValue(trans_color);
			   const unsigned char trans_g = GetGValue(trans_color);
			   const unsigned char trans_r = GetRValue(trans_color);
			
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   byte_t *p = (byte_t *)GetBits(rect.left, y);
			   const byte_t *q = (byte_t *)image->GetBits(rect.left, y);
			   for (int x = rect.left; x < rect.right; x++)
			   {
			   const byte_t b = *q++;
			   const byte_t g = *q++;
			   const byte_t r = *q++;
			
			   if (b != trans_b || g != trans_g || r != trans_r) {
			   p[0] = b;
			   p[1] = g;
			   p[2] = r;
			   }
			   p += 3;
			   }
			   }
			 */
			_bmd.lock();
			_bmd.draw(image._bmd, null, null, null, rect, true);
			_bmd.unlock();
		}
		
		/**
		 * 矩形的描绘
		 */
		public function DrawRect(rect:Rectangle, color:uint):void
		{
			var width:int = rect.width;
			var height:int = rect.height;
			FillRect2(rect.left, rect.top, width, 1, color);
			FillRect2(rect.left, rect.top, 1, height, color);
			FillRect2(rect.right - 1, rect.top, 1, height, color);
			FillRect2(rect.left, rect.bottom - 1, width, 1, color);
		}
		
		/**
		 * 填入透明度50%的黑色
		 * @param	rect
		 */
		public function FillHalfToneRect(rect:Rectangle):void
		{
			/*
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   byte_t *p = (byte_t *)GetBits(rect.left, y);
			   for (int x = rect.left; x < rect.right; x++)
			   {
			 *p++ /= 2;
			 *p++ /= 2;
			 *p++ /= 2;
			   }
			   }
			 */
			_bmd.lock();
			var pixels:ByteArray = _bmd.getPixels(rect);
			var pixels2:ByteArray = new ByteArray();
			try
			{
				pixels.position = 0;
				while (pixels.bytesAvailable)
				{
					var p:uint = pixels.readUnsignedInt();
					var b:uint = (p & 0x000000FF);
					var g:uint = (p & 0x0000FF00) >>> 8;
					var r:uint = (p & 0x00FF0000) >>> 16;
					var a:uint = (p & 0xFF000000) >>> 24;
					b /= 2;
					g /= 2;
					r /= 2;
					pixels2.writeUnsignedInt((a << 24) | (r << 16) | (g << 8) | b);
				}
				//trace(pixels.bytesAvailable);
				//trace(pixels2.bytesAvailable);
				pixels2.position = 0;
				_bmd.setPixels(rect, pixels2);
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
			_bmd.unlock();
		}
		
		/**
		 * 框线的描绘
		 * @param	x
		 * @param	y
		 * @param	w
		 * @param	h
		 * @param	color
		 */
		public function DrawFrameRect(x:int, y:int, w:int, h:int, color:uint = 0xFFFFFF):void
		{
			DrawRect2(x, y + 1, w, h - 2, color);
			DrawRect2(x + 1, y, w - 2, h, color);
			FillHalfToneRect2(x + 2, y + 2, w - 4, h - 4);
		}
		
		public function Copy2(image:CImage):void
		{
			Copy(image, new Rectangle(0, 0, image.Width(), image.Height()));
		}
		
		public function FillRect2(x:int, y:int, w:int, h:int, color:uint):void
		{
			FillRect(new Rectangle(x, y, w, h), color);
		}
		
		public function DrawRect2(x:int, y:int, w:int, h:int, color:uint):void
		{
			DrawRect(new Rectangle(x, y, w, h), color);
		}
		
		public function FillHalfToneRect2(x:int, y:int, w:int, h:int):void
		{
			FillHalfToneRect(new Rectangle(x, y, w, h));
		}
		
		public function DrawFrameRect2(rect:Rectangle, color:uint = 0xFFFFFF):void
		{
			DrawFrameRect(rect.left, rect.top, rect.width, rect.height, color);
		}
	}
}