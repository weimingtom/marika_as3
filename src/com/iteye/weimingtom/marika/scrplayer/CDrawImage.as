/**
 * DIB Section
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * 使用DIB section的24bit的DIB类
	 */
	public class CDrawImage extends CImage
	{
		private const NO_BYTEARRY_CLEAR:Boolean = true;
		
		public function CDrawImage()
		{
			super(0, 0);
		}
		
		/**
		 * 把类里的内存位图bitblt到dc
		 * @param	dc
		 * @param	x
		 * @param	y
		 * @param	w
		 * @param	h
		 * @param	ox
		 * @param	oy
		 */
		//FIXME: public -> private 保证ox, oy总是和x, y相等
		private function Draw(dc:Graphics, x:int, y:int, w:int, h:int, ox:int, oy:int):void
		{
			/*
			   HDC	memdc = CreateCompatibleDC(dc);
			   HGDIOBJ	oldbmp = SelectObject(memdc, hBitmap);
			   BitBlt(dc, x, y, w, h, memdc, ox, oy, SRCCOPY);
			   GdiFlush();
			   SelectObject(memdc, oldbmp);
			   DeleteDC(memdc);
			 */
			//TODO:无法实现重叠式会话，有问题。
			
			//FIXME：这里不应该用clear全部清除!!!
			//如果clear，则全部重绘，造成CPU和内存上升
			if (false)
			{
				dc.clear();
			}
			
			//FIXME:ox, oy怎么办???，
			//如果ox, oy总是和x, y相等。就不需要使用临时bmd进行剪裁，
			//直接用_bmd即可
			if (x != ox || y != oy)
			{
				throw new Error("Draw的坐标位置和偏移量不等");
			}
			
			//dc.beginBitmapFill(_bmd, new Matrix(1, 0, 0, 1, 0, 0), false, true);
			dc.beginBitmapFill(_bmd, null, false, true);
			dc.drawRect(x, y, w, h); //这里是Adobe的陷阱，如果不这样画，BitmapFill将无效
			//dc.endFill(); //endFill可以无视???
		}
		
		/**
		 *
		 * @param	dc
		 * @param	rect
		 * @param	point
		 */
		//FIXME: public -> private 保证ox, oy总是和x, y相等
		private function Draw2(dc:Graphics, rect:Rectangle, point:Point):void
		{
			Draw(dc, rect.left, rect.top, rect.width, rect.height, point.x, point.y);
		}
		
		/**
		 *
		 * @param	dc
		 * @param	rect
		 */
		public function Draw3(dc:Graphics, rect:Rectangle):void
		{
			Draw(dc, rect.left, rect.top, rect.width, rect.height, rect.left, rect.top);
		}
		
		//
		// 析构函数
		//
		/*
		   CDrawImage::~CDrawImage()
		   {
		   GdiFlush();
		   if (hBitmap) {
		   ::DeleteObject(hBitmap);
		   }
		   }
		 */
		
		/**
		 * DIB section的建立
		 * @param	dc
		 * @param	width
		 * @param	height
		 * @return
		 */
		public function Create3(dc:Graphics, width:int, height:int):Boolean
		{
			/*
			   W = width;
			   H = height;
			   D = 24;
			
			   bytes_per_line = ScanBytes(width, 24);
			   bytes_per_pixel = PixelBytes(24);
			
			   InfoHeader.biSize			= sizeof(BITMAPINFOHEADER);
			   InfoHeader.biWidth			= width;
			   InfoHeader.biHeight			= height;
			   InfoHeader.biBitCount		= 24;
			   InfoHeader.biPlanes			= 1;
			   InfoHeader.biXPelsPerMeter	= 0;
			   InfoHeader.biYPelsPerMeter	= 0;
			   InfoHeader.biClrUsed		= 0;
			   InfoHeader.biClrImportant	= 0;
			   InfoHeader.biCompression	= BI_RGB;
			   InfoHeader.biSizeImage		= bytes_per_line * height;
			
			   Info = (BITMAPINFO *)&InfoHeader;
			   hBitmap = CreateDIBSection(dc, Info, DIB_RGB_COLORS, &Bits, NULL, 0);
			
			   return hBitmap != 0;
			 */
			//TODO:在AS3中创建内存位图不需要知道dc是什么
			super.Create(width, height, 24);
			return true;
		}
		
		/**
		 * 字符串的绘制到DIB
		 * @param	hFont
		 * @param	x1
		 * @param	y1
		 * @param	str
		 * @param	color
		 */
		public function DrawText(hFont:CFont, x1:int, y1:int, str:String, color:uint = CMisc.WhitePixel):void
		{
			/*
			   CMemoryDC	dc(0);
			   HBITMAP	oldBitmap = dc.SelectObject(hBitmap);
			   HFONT	oldFont = dc.SelectObject(hFont);
			   dc.SetTextColor(color);
			   dc.SetBkMode(TRANSPARENT);
			   dc.ExtTextOut(x1, y1, 0, 0, str, strlen(str), NULL);
			   dc.SelectObject(oldBitmap);
			   dc.SelectObject(oldFont);
			   GdiFlush();
			 */
			//TODO:AS3的字体还没有搞清楚怎么用
			var tf:TextField = new TextField();
			tf.multiline = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.textColor = 0xFF000000 | color;
			tf.text = str; //文字输出最后才调用
			_bmd.lock();
			_bmd.draw(tf, new Matrix(1, 0, 0, 1, x1, y1), null, null, null, true);
			_bmd.unlock();
		}
		
		[Embed(source = '../../../../../../assets/rule/wipe.png')]
		private static var wipe_rule_cls:Class;
		private static var _wiperulebmd:BitmapData = new BitmapData(640, 480, false, 0);
		//static
		{
			_wiperulebmd.draw(new wipe_rule_cls);
		}
		
		/**
		 * Wipe-In的处理
		 * 注意，image的宽度可能比当前位图的宽度小
		 * 假设image和目标图（当前位图）的左上角对齐
		 * @param	image
		 * @param	rect
		 * @param	count
		 * @return
		 */
		public function WipeIn(image:CImage, rect:Rectangle, count:int):void
		{
			/*
			   int	len = rect.Width() * 3;
			   for (int y = rect.top + count; y < rect.bottom; y += 8)
			   {
			   memcpy(GetBits(rect.left, y), image->GetBits(rect.left, y), len);
			   }
			 */
			//TODO:从上而下描绘水平线，间隔为8
			if (false) //这种方法可能较慢
			{
				_bmd.lock();
				var rect2:Rectangle = rect.clone();
				if (rect2.left < 0)
					rect2.left = 0;
				if (rect2.right > image.Width())
					rect2.right = image.Width();
				if (rect2.right > this.Width())
					rect2.right = this.Width();
				//trace("rect2.x", rect2.x);
				var pixels:ByteArray = _bmd.getPixels(rect2);
				var img_pixels:ByteArray = image._bmd.getPixels(rect2);
				var pixels2:ByteArray = new ByteArray();
				var temp:ByteArray = new ByteArray();
				//var w:int = (rect.width < image.Width()) ? rect.width : image.Width();
				var w:int = rect2.width;
				var y:int = 0;
				//TODO:
				count = count % 8;
				try
				{
					pixels.position = 0;
					img_pixels.position = 0;
					while (pixels.bytesAvailable)
					{
						/*
						   trace("pixels.bytesAvailable", pixels.bytesAvailable,
						   "w * 4", w * 4);
						   trace("img_pixels.bytesAvailable", img_pixels.bytesAvailable,
						   "w * 4", w * 4);
						 */
						if (y % 8 == count)
						{
							if (NO_BYTEARRY_CLEAR)
							{
								temp.position = 0;
								temp.length = 0;
							}
							else
							{
								Object(temp).clear();
							}
							img_pixels.readBytes(temp, 0, w * 4);
							pixels2.writeBytes(temp);
							pixels.position += w * 4;
						}
						else
						{
							if (NO_BYTEARRY_CLEAR)
							{
								temp.position = 0;
								temp.length = 0;
							}
							else
							{
								Object(temp).clear();
							}
							pixels.readBytes(temp, 0, w * 4);
							pixels2.writeBytes(temp);
							img_pixels.position += w * 4;
						}
						y++;
							//trace("pixels2.length", pixels2.length);
					}
					//trace("write");
					pixels2.position = 0;
					_bmd.setPixels(rect2, pixels2);
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
				_bmd.unlock();
			}
			else
			{
				var threshold:int = count * 32;
				_bmd.lock();
				var tempBmd:BitmapData = image._bmd.clone();
				tempBmd.threshold(_wiperulebmd, rect, new Point(rect.x, rect.y), ">", threshold, 0, 0xFF, false);
				_bmd.draw(tempBmd, null, null, null, rect);
				_bmd.unlock();
				tempBmd.dispose();
			}
		}
		
		/**
		 * Wipe-Out的处理
		 * @param	rect
		 * @param	count
		 */
		public function WipeOut(rect:Rectangle, count:int):void
		{
			/*
			   int		len = rect.Width() * 3;
			   for (int y = rect.top + count; y < rect.bottom; y += 8)
			   {
			   memset(GetBits(rect.left, y), 0, len);
			   }
			 */
			//TODO:从上而下描绘水平线，间隔为8
			if (true)
			{
				_bmd.lock();
				var rect2:Rectangle = rect.clone();
				if (rect2.left < 0)
					rect2.left = 0;
				if (rect2.right > this.Width())
					rect2.right = this.Width();
				//trace("rect2.x", rect2.x);
				var pixels:ByteArray = _bmd.getPixels(rect2);
				var pixels2:ByteArray = new ByteArray();
				var temp:ByteArray = new ByteArray();
				var temp2:ByteArray = new ByteArray();
				//var w:int = (rect.width < image.Width()) ? rect.width : image.Width();
				var w:int = rect2.width;
				var y:int = 0;
				//TODO:
				count = count % 8;
				try
				{
					for (var i:int = 0; i < w; i++)
					{
						temp2.writeUnsignedInt(0xFF000000);
					}
					pixels.position = 0;
					while (pixels.bytesAvailable)
					{
						/*
						   trace("pixels.bytesAvailable", pixels.bytesAvailable,
						   "w * 4", w * 4);
						   trace("img_pixels.bytesAvailable", img_pixels.bytesAvailable,
						   "w * 4", w * 4);
						 */
						if (y % 8 == count)
						{
							temp2.position = 0;
							pixels2.writeBytes(temp2);
							pixels.position += w * 4;
						}
						else
						{
							if (NO_BYTEARRY_CLEAR)
							{
								temp.position = 0;
								temp.length = 0;
							}
							else
							{
								Object(temp).clear();
							}
							pixels.readBytes(temp, 0, w * 4);
							pixels2.writeBytes(temp);
						}
						y++;
							//trace("pixels2.length", pixels2.length);
					}
					//trace("write");
					pixels2.position = 0;
					_bmd.setPixels(rect2, pixels2);
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
				_bmd.unlock();
			}
			else
			{
				var threshold:int = count * 32;
				_bmd.lock();
				//var tempBmd:BitmapData = _bmd.clone();
				/*tempBmd*/
				_bmd.threshold(_wiperulebmd, rect, new Point(rect.x, rect.y), "<", threshold, 0xFF000000, 0xFF, false);
				//_bmd.draw(tempBmd, null, null, null, rect);
				_bmd.unlock();
					//tempBmd.dispose();
			}
		}
		
		/**
		 * Wipe-In2的处理
		 * @param	image
		 * @param	rect
		 * @param	count
		 * @return
		 */
		public function WipeIn2(image:CImage, rect:Rectangle, count:int):Boolean
		{
			var width:int = rect.width;
			var height:int = rect.height;
			var update:Boolean = false;
			var npos:int = count * 4;
			for (var y:int = 0; y < height; y += 32)
			{
				if (npos >= 0 && npos < 32)
				{
					var ypos:int = y + npos;
					//注意Rectangle和CRect的不同
					Copy(image, new Rectangle(0, ypos, width, 4));
					update = true;
				}
				npos -= 4;
			}
			return update;
		}
		
		/**
		 * Wipe-Out2的处理
		 * @param	rect
		 * @param	count
		 * @return
		 */
		public function WipeOut2(rect:Rectangle, count:int):Boolean
		{
			var width:int = rect.width;
			var height:int = rect.height;
			var update:Boolean = false;
			var npos:int = count * 4;
			for (var y:int = 0; y < height; y += 32)
			{
				if (npos >= 0 && npos < 32)
				{
					var ypos:int = y + npos;
					FillRect(new Rectangle(0, ypos, width, 4), 0);
					update = true;
				}
				npos -= 4;
			}
			return update;
		}
		
		/**
		 * Fade的处理
		 * @param	image
		 * @param	rect
		 * @param	cvt
		 */
		public function FadeCvt(image:CImage, rect:Rectangle, cvt:Array):void
		{
			/*
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   byte_t *p1 = (byte_t *)GetBits(rect.left, y);
			   byte_t *p2 = (byte_t *)image->GetBits(rect.left, y);
			   for (int x = rect.left; x < rect.right; x++)
			   {
			 *p1++ = cvt[*p2++];		// blue
			 *p1++ = cvt[*p2++];		// green
			 *p1++ = cvt[*p2++];		// red
			   }
			   }
			 */
			// see 
			// http://blog.naver.com/PostView.nhn?blogId=hkn10004&logNo=20100862268&categoryNo=33&viewDate=&currentPage=1&listtype=0
			//TODO:
			//1. paletteMap无法成功 <- 已修正
			//2. rect不可以超出范围，否则会有问题
			if (false)
			{
				_bmd.lock();
				//trace("CDrawImage::FadeCvt, rect -> ", rect);
				//trace("CDrawImage::FadeCvt, _bmd -> ", _bmd.width, _bmd.height);
				var pixels:ByteArray = image._bmd.getPixels(rect);
				var pixels_bg:ByteArray = _bmd.getPixels(rect);
				var pixels2:ByteArray = new ByteArray();
				try
				{
					//Adobe的陷阱，读出来时的位置不是0
					pixels.position = 0;
					pixels_bg.position = 0;
					//Adobe的陷阱，必须检查bytesAvailable才可以读
					while (pixels.bytesAvailable && pixels_bg.bytesAvailable)
					{
						var p:uint = pixels.readUnsignedInt(); //前景像素
						//注意，p2必须读出一次，哪怕没有用（对齐p）
						var p2:uint = pixels_bg.readUnsignedInt(); //后景像素
						var a:uint = (p & 0xFF000000) >>> 24;
						if (a == 0) //透明色问题
						{
							pixels2.writeUnsignedInt(p2);
						}
						else
						{
							var b:uint = (p & 0x000000FF);
							var g:uint = (p & 0x0000FF00) >>> 8;
							var r:uint = (p & 0x00FF0000) >>> 16;
							b = cvt[b];
							g = cvt[g];
							r = cvt[r];
							pixels2.writeUnsignedInt((a << 24) | (r << 16) | (g << 8) | b);
						}
					}
					//trace(pixels.bytesAvailable);
					//trace(pixels2.bytesAvailable);
					//_bmd.unlock();
					pixels2.position = 0;
					//_bmd.lock();
					_bmd.setPixels(rect, pixels2);
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
				_bmd.unlock();
			}
			else //用paletteMap似乎会比setPixels快
			{
				var redArray:Array = new Array(256);
				var greenArray:Array = new Array(256);
				var blueArray:Array = cvt;
				var alphaArray:Array = new Array(256);
				var tempBmd:BitmapData = new BitmapData(image._bmd.width, image._bmd.height, true, 0);
				for (var kk:int = 0; kk < 256; kk++)
				{
					redArray[kk] = blueArray[kk] << 16;
					greenArray[kk] = blueArray[kk] << 8;
				}
				_bmd.lock();
				//paletteMap可以进行颜色快速变换
				//但似乎不能处理透明色问题
				tempBmd.paletteMap(image._bmd, rect, new Point(0, 0), redArray, greenArray, blueArray);
				_bmd.draw(tempBmd);
				_bmd.unlock();
				tempBmd.dispose();
			}
		}
		
		/**
		 * 由“黑->图片”的淡入处理
		 * @param	image
		 * @param	rect
		 * @param	count
		 */
		public function FadeFromBlack(image:CImage, rect:Rectangle, count:int):void
		{
			var cvt:Array = new Array(256);
			count++;
			for (var i:int = 0; i < 256; i++)
			{
				cvt[i] = ((i * count) / 16) & 0xFF;
			}
			FadeCvt(image, rect, cvt);
		}
		
		/**
		 * 由“图片->黑”的淡出处理
		 * @param	image
		 * @param	rect
		 * @param	count
		 */
		public function FadeToBlack(image:CImage, rect:Rectangle, count:int):void
		{
			var cvt:Array = new Array(256);
			count = 15 - count;
			for (var i:int = 0; i < 256; i++)
			{
				cvt[i] = ((i * count) / 16) & 0xFF;
			}
			FadeCvt(image, rect, cvt);
		}
		
		/**
		 * 由“白->图片”的淡入处理
		 * @param	image
		 * @param	rect
		 * @param	count
		 */
		public function FadeFromWhite(image:CImage, rect:Rectangle, count:int):void
		{
			var cvt:Array = new Array(256);
			count++;
			var level:int = 255 * (16 - count);
			for (var i:int = 0; i < 256; i++)
			{
				cvt[i] = ((i * count + level) / 16) & 0xFF;
			}
			FadeCvt(image, rect, cvt);
		}
		
		/**
		 * 由“图片->白”的淡出处理
		 * @param	image
		 * @param	rect
		 * @param	count
		 */
		public function FadeToWhite(image:CImage, rect:Rectangle, count:int):void
		{
			var cvt:Array = new Array(256);
			count = 15 - count;
			var level:int = 255 * (16 - count);
			for (var i:int = 0; i < 256; i++)
			{
				cvt[i] = ((i * count + level) / 16) & 0xFF;
					//trace(i, "->", cvt[i]);
			}
			FadeCvt(image, rect, cvt);
		}
		
		private static var BitMask:Array = [0x2080, // 0010 0000 1000 0000
		0xa0a0, // 1010 0000 1010 0000
		0xa1a4, // 1010 0001 1010 0100
		0xa5a5, // 1010 0101 1010 0101
		0xada7, // 1010 1101 1010 0111
		0xafaf, // 1010 1111 1010 1111
		0xefbf, // 1110 1111 1011 1111
		0xffff, // 1111 1111 1111 1111
		];
		private static var XMask:Array = [0xf000, 0x0f00, 0x00f0, 0x000f,];
		private static var YMask:Array = [0x8888, 0x4444, 0x2222, 0x1111,];
		
		[Embed(source = '../../../../../../assets/rule/mix.png')]
		private static var mix_rule_cls:Class;
		private static var _mixrulebmd:BitmapData = new BitmapData(640, 480, false, 0);
		//static
		{
			_mixrulebmd.draw(new mix_rule_cls);
		}
		
		/**
		 * 图片数据合成的处理
		 * @param	CImage *image
		 * @param	const CRect &rect
		 * @param	int count
		 */
		public function Mix(image:CImage, rect:Rectangle, count:int):void
		{
			/*
			   static unsigned	BitMask[] = {
			   0x2080,	// 0010 0000 1000 0000
			   0xa0a0,	// 1010 0000 1010 0000
			   0xa1a4,	// 1010 0001 1010 0100
			   0xa5a5,	// 1010 0101 1010 0101
			   0xada7,	// 1010 1101 1010 0111
			   0xafaf,	// 1010 1111 1010 1111
			   0xefbf,	// 1110 1111 1011 1111
			   0xffff,	// 1111 1111 1111 1111
			   } ;
			   static unsigned	XMask[] = {
			   0xf000, 0x0f00, 0x00f0, 0x000f,
			   } ;
			   static unsigned	YMask[] = {
			   0x8888, 0x4444, 0x2222, 0x1111,
			   } ;
			   for (int y = rect.top; y < rect.bottom; y++)
			   {
			   unsigned char *p = (unsigned char *)GetBits(rect.left, y);
			   byte_t *q = (byte_t *)image->GetBits(rect.left, y);
			   unsigned	mask = BitMask[count] & YMask[y & 3];
			   for (int x = rect.left; x < rect.right; x++)
			   {
			   if (mask & XMask[x & 3])
			   {
			   p[0] = q[0]; // blue
			   p[1] = q[1]; // green
			   p[2] = q[2]; // red
			   }
			   p += 3;
			   q += 3;
			   }
			   }
			 */
			//TODO: 方法较慢(?)
			if (false)
			{
				trace("CDrawImage::Mix setPixels ", count);
				_bmd.lock();
				var rect2:Rectangle = rect.clone();
				if (rect2.left < 0)
					rect2.left = 0;
				if (rect2.right > image.Width())
					rect2.right = image.Width();
				if (rect2.right > this.Width())
					rect2.right = this.Width();
				//trace("rect2.x", rect2.x);
				var pixels:ByteArray = _bmd.getPixels(rect2);
				var img_pixels:ByteArray = image._bmd.getPixels(rect2);
				var pixels2:ByteArray = new ByteArray();
				var temp:ByteArray = new ByteArray();
				//var w:int = (rect.width < image.Width()) ? rect.width : image.Width();
				var w:int = rect2.width;
				//var y:int = 0;
				
				//TODO:
				//count = count % 8;
				//trace("CDrawImage::BitMask[count] => ", uint(BitMask[count]).toString(16));
				
				try
				{
					pixels.position = 0;
					img_pixels.position = 0;
					for (var y:int = 0; pixels.bytesAvailable; y++)
					{
						for (var x:int = 0; x < rect.width; x++)
						{
							var mask:uint = uint(BitMask[count]) & uint(YMask[y & 3]);
							var p:uint = pixels.readUnsignedInt(); //后景图
							var p2:uint = img_pixels.readUnsignedInt(); //前景图					
							//FIXME: 暂时修正透明色问题
							if (false)
							{
								if (mask & XMask[x & 3])
								{
									pixels2.writeUnsignedInt(p2);
								}
								else
								{
									pixels2.writeUnsignedInt(p);
								}
							}
							else
							{
								if (!(p2 & 0xFF000000)) //前景图中的透明像素点
								{
									pixels2.writeUnsignedInt(p);
								}
								else if ((mask & XMask[x & 3]))
								{
									pixels2.writeUnsignedInt(p2);
								}
								else
								{
									pixels2.writeUnsignedInt(p);
								}
							}
						}
							//trace("pixels2.length", pixels2.length);
					}
					//trace("write");
					pixels2.position = 0;
					_bmd.setPixels(rect2, pixels2);
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
				_bmd.unlock();
			}
			else //用threshold实现rule过渡可能会快些
			{
				trace("CDrawImage::threshold mix " + count);
				//mix_rule
				var threshold:int = count * 32;
				_bmd.lock();
				var tempBmd:BitmapData = image._bmd.clone();
				tempBmd.threshold(_mixrulebmd, rect, new Point(rect.x, rect.y), ">", threshold, 0, 0xFF, false);
				_bmd.draw(tempBmd, null, null, null, rect);
				_bmd.unlock();
				tempBmd.dispose();
			}
		}
	}
}
