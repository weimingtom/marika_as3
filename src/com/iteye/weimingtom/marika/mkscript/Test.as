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
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	[SWF(width = "640", height = "480")]
	public class Test extends Sprite
	{
		[Embed(source = '../../../../../../assets/main.txt', mimeType = 'application/octet-stream')]
		private static var main_txt:Class;
		
		[Embed(source = '../../../../../../assets/sample1old.txt', mimeType = 'application/octet-stream')]
		private static var sample1old_txt:Class;
		
		[Embed(source = '../../../../../../assets/sample3.txt', mimeType = 'application/octet-stream')]
		private static var sample3_txt:Class;
		
		//private var lexer:Lexer;
		
		public function Test()
		{
			//初始化资源分配器
			FileLoader.insertClass("main.txt", main_txt);
			FileLoader.insertClass("sample1old.txt", sample1old_txt);
			FileLoader.insertClass("sample3.txt", sample3_txt);
			
			//打开文件
			if (false)
			{
				var fileReader:FileReader = new FileReader("main.txt"); //"sample3.txt");
				while (true)
				{
					var str:String = fileReader.GetString();
					if (str == null)
						break;
					//trace(str);
					//trace("line:", fileReader.GetLineNo());
					var lexer:Lexer;
					lexer = new Lexer(str);
				}
			}
			
			//trace("========================");
			if (true)
			{
				var makeScript:MakeScript = new MakeScript();
				makeScript.ReadScript("sample3.txt");
				makeScript.dumpBuffer();
				makeScript.uploadBuffer();
			}
			
			if (false)
			{
				var test_bytes:ByteArray = new ByteArray();
				test_bytes.writeByte(0xFA);
				test_bytes.position = 0;
				if (test_bytes.bytesAvailable > 0)
				{
					var result:uint = test_bytes.readByte() & 0xFF;
					trace("result:", result.toString(16));
				}
				test_bytes.position = 0;
				if (test_bytes.bytesAvailable > 0)
				{
					var result2:uint = test_bytes.readByte();
					trace("result2:", result2.toString(16));
				}
					//输出
					//result: fa
					//result2: fffffffa
			}
			
			if (false)
			{
				var test2:ByteArray = new ByteArray();
				test2.writeMultiByte("“总算到学校了，在这里打听些情报吧”", "gbk");
				test2.position = 0;
				var len:int = test2.bytesAvailable;
				for (var kk:int = 0; kk < len; kk++)
				{
					var test2_value:uint = test2.readByte() & 0xFF;
					trace(kk, ":", test2_value.toString(16));
				}
			}
			
			if (false)
			{
				var test3:ByteArray = new ByteArray();
				test3.writeByte(4);
				test3.position++;
				test3.writeByte(6);
				test3.position = 1;
				test3.writeByte(5);
				test3.position = 0;
				var len3:int = test3.bytesAvailable;
				for (var kkk:int = 0; kkk < len3; kkk++)
				{
					var test3_value:uint = test3.readByte() & 0xFF;
					trace(kkk, ":", test3_value.toString(16));
				}
			}
		}
	}
}
