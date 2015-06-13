package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import com.iteye.weimingtom.marika.scrplayer.CDrawImage;
	
	[SWF(width = "640", height = "480")]
	public class CTest extends Sprite
	{
		private var layer1:Sprite = new Sprite();
		
		[Embed(source = '../../../../../../assets/cgdata/bg001.JPG')]
		private static var bg001:Class;
		
		[Embed(source = '../../../../../../assets/cgdata/MEGU111.png')]
		private static var ch001:Class;
		
		private var img1:CImage = new CImage(640, 480);
		private var img2:CImage = new CImage(640, 480); //new CImage(320, 480);
		private var img2_:CImage = new CImage(640, 480);
		
		private var img3:CDrawImage = new CDrawImage();
		
		public function CTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace("init");
			CFile.loadBitmap("cgdata/bg001", bg001);
			CFile.loadBitmap("cgdata/ch001", ch001);
			
			testCImage();
			//testCDrawImage();
			//testFormatMessage();
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private var wheel_degree:int = 0;
		
		private function onMouseWheel(event:MouseEvent):void
		{
			trace("wheel_degree", wheel_degree);
			if (event.delta > 0)
			{
				wheel_degree++;
			}
			else
			{
				wheel_degree--;
			}
			layer1.graphics.clear();
			img3.LoadImage("bg001", 0, 0);
			//img3.FadeToWhite(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			img3.Mix(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			//img3.WipeIn(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			img3.Draw3(layer1.graphics, new Rectangle(0, 0, 640, 480));
		}
		
		private function testCImage():void
		{
			img1.LoadImage("bg001", 0, 0);
			img2.LoadImage("ch001", 0, 0);
			
			//img1.Copy2(img2);
			//img1.MixImage(img2, new Rectangle(0, 0, 320, 480), 0x00FF00);
			//img1.FillRect2(100, 100, 100, 100, 0xFF0000);
			//img1.DrawRect2(100, 100, 100, 100, 0xFF0000);
			//img1.FillHalfToneRect2(100, 100, 100, 100);
			//img1.DrawFrameRect(100, 100, 100, 100, 0xFF0000);
			img1.DrawFrameRect2(new Rectangle(100, 100, 100, 100));
			
			layer1.graphics.clear();
			layer1.graphics.beginBitmapFill(img1._bmd, null, false, true);
			layer1.graphics.drawRect(0, 0, 640, 480);
			layer1.graphics.endFill();
			
			addChild(layer1);
		}
		
		/**
		 * 效果测试
		 * 注意检查异常（尤其是涉及ByteArray的复杂运算）
		 */
		private function testCDrawImage():void
		{
			img3.LoadImage("bg001", 0, 0);
			img2.LoadImage("ch001", 160, 0);
			addChild(layer1);
			//layer1.graphics.clear();
			//img3.Copy2(img2);
			
			//img3.MixImage(img2, new Rectangle(160, 0, 320, 480));
			
			img3.DrawText(null, 0, 100, "hello, world", 0x0000FF);
			//img3.WipeIn(img2, new Rectangle(0, 0, 640, 480), 0);
			img3.WipeOut(new Rectangle(50, 0, 640, 480), 0);
			//img3.FadeToWhite(img2, new Rectangle(0, 0, 640, 480), 0);
			//img3.Mix(img2, new Rectangle(0, 0, 640, 480), 0);
			img3.Draw3(layer1.graphics, new Rectangle(0, 0, 640, 480));
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			trace("wheel_degree", wheel_degree);
			switch (e.keyCode)
			{
				case Keyboard.UP: 
					wheel_degree++;
					break;
				
				case Keyboard.DOWN: 
					wheel_degree--;
					break;
			}
			layer1.graphics.clear();
			img3.LoadImage("bg001", 0, 0);
			img3.DrawText(null, 0, 100, "hello, world", 0x0000FF);
			//img3.WipeIn(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			img3.WipeOut(new Rectangle(50, 0, 640, 480), wheel_degree);
			//img3.FadeToWhite(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			//img3.Mix(img2, new Rectangle(0, 0, 640, 480), wheel_degree);
			img3.Draw3(layer1.graphics, new Rectangle(0, 0, 640, 480));
		}
		
		private function testFormatMessage():void
		{
			var testStr:String = "“２楼已经去过了啦！\n去别的地方吧”"
			trace("original:", testStr);
			var i:int = FormatMessage(testStr);
			//trace("FormatMessage :", );
		}
		
		private var MsgBuffer:Array = new Array(4);
		private var CurY:int = 0;
		private var CurX:int = 0;
		
		public function FormatMessage(msg:String):int
		{
			CurX = CurY = 0;
			var lines:Array = msg.split("\n", 4);
			for (var i:int = 0; i < 4; i++)
			{
				if (lines[i] != null)
				{
					MsgBuffer[i] = lines[i];
					trace("FormatMessage", i, MsgBuffer[i]);
					CurY++;
				}
				else
				{
					trace("FormatMessage", i, "");
					MsgBuffer[i] = "";
				}
			}
			trace("FormatMessage CurY == ", CurY);
			return CurY;
		}
	}
}