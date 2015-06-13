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
	import flash.utils.ByteArray;
	
	import com.iteye.weimingtom.marika.mkscript.cmd.CalcValueCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.ClearCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.Command;
	import com.iteye.weimingtom.marika.mkscript.cmd.ExecCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.GotoCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.IfCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.LoadCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.MenuCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.MenuItemCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.ModeCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.MusicCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.SetValueCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.SleepCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.SoundCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.TextCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.UpdateCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.WipeinCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.WipeoutCommand;
	
	/*
	 * 特殊写入方式：
	 * 		label_ref: if/goto
	 * 		=> 类型值(字节数, 块头偏移label position) : 05/06/...(16, +12), 04(8, +4)
	 * 		AddMessage: menuitem/load/sound/exec/text
	 * 		=> 写入pack body
	 *
	 * pack结构(含义:字节数)，4字节对齐，字符串为gbk编码
	 * 		pack header:
	 * 			type:1
	 * 			header size(4 bytes align):1
	 * 			properties(optional):n
	 * 			...(include body length):...
	 * 		pack body(optional):
	 * 			string(gbk encode, 4 bytes align):n
	 *
	 * if/goto的写入必须跳过label地址(label position)
	 */
	
	public class CommandBuffer
	{
		private static const DEBUG_WRITE_COMMAND:Boolean = true;
		
		//注意：这里的命令类型与类型整数不是一对一关系
		private static var setValueCmd:SetValueCommand = new SetValueCommand(ScriptType.SET_VALUE_CMD);
		private static var calcValueCmd:CalcValueCommand = new CalcValueCommand(ScriptType.CALC_VALUE_CMD);
		private static var textCmd:TextCommand = new TextCommand(ScriptType.TEXT_CMD);
		private static var gotoCmd:GotoCommand = new GotoCommand(ScriptType.GOTO_CMD);
		private static var ifCmd:IfCommand = new IfCommand(0); //可变类型
		private static var menuItemCmd:MenuItemCommand = new MenuItemCommand(ScriptType.MENU_ITEM_CMD);
		private static var menuCmd:MenuCommand = new MenuCommand(ScriptType.MENU_CMD);
		private static var execCmd:ExecCommand = new ExecCommand(ScriptType.EXEC_CMD);
		private static var loadCmd:LoadCommand = new LoadCommand(ScriptType.LOAD_CMD);
		private static var updateCmd:UpdateCommand = new UpdateCommand(ScriptType.UPDATE_CMD);
		private static var clearCmd:ClearCommand = new ClearCommand(ScriptType.CLEAR_CMD);
		private static var musicCmd:MusicCommand = new MusicCommand(ScriptType.MUSIC_CMD);
		private static var soundCmd:SoundCommand = new SoundCommand(ScriptType.SOUND_CMD);
		private static var sleepCmd:SleepCommand = new SleepCommand(ScriptType.SLEEP_CMD);
		private static var wipeinCmd:WipeinCommand = new WipeinCommand(ScriptType.WIPEIN_CMD);
		private static var wipeoutCmd:WipeoutCommand = new WipeoutCommand(ScriptType.WIPEOUT_CMD);
		private static var modeCmd:ModeCommand = new ModeCommand(ScriptType.MODE_CMD);
		
		private static var normalCmd:Command = new Command(0);
		private static var current_read_cmd:Command;
		
		public function CommandBuffer()
		{
			//
		}
		
		public static function GetCommand():Command
		{
			return current_read_cmd;
		}
		
		public static function NewCommand(id:int):Command
		{
			switch (id)
			{
				case ScriptType.SET_VALUE_CMD: 
					return setValueCmd;
					break;
				
				case ScriptType.CALC_VALUE_CMD: 
					return calcValueCmd;
					break;
				
				case ScriptType.TEXT_CMD: 
					return textCmd;
					break;
				
				case ScriptType.CLEAR_TEXT_CMD: 
					return clearCmd;
					break;
				
				case ScriptType.GOTO_CMD: 
					return gotoCmd;
					break;
				
				case ScriptType.IF_TRUE_CMD: 
				case ScriptType.IF_FALSE_CMD: 
				case ScriptType.IF_BIGGER_CMD: 
				case ScriptType.IF_SMALLER_CMD: 
				case ScriptType.IF_BIGGER_EQU_CMD: 
				case ScriptType.IF_SMALLER_EQU_CMD: 
					return ifCmd;
					break;
				
				case ScriptType.MENU_ITEM_CMD: 
					return menuItemCmd;
					break;
				
				case ScriptType.MENU_CMD: 
					return menuCmd;
					break;
				
				case ScriptType.EXEC_CMD: 
					return execCmd;
					break;
				
				case ScriptType.LOAD_CMD: 
					return loadCmd;
					break;
				
				case ScriptType.UPDATE_CMD: 
					return updateCmd;
					break;
				
				case ScriptType.CLEAR_CMD: 
					return clearCmd;
					break;
				
				case ScriptType.MUSIC_CMD: 
					return musicCmd;
					break;
				
				case ScriptType.SOUND_CMD: 
					return soundCmd;
					break;
				
				case ScriptType.SLEEP_CMD: 
					return sleepCmd;
					break;
				
				case ScriptType.WIPEIN_CMD: 
					return wipeinCmd;
					break;
				
				case ScriptType.WIPEOUT_CMD: 
					return wipeoutCmd;
					break;
				
				case ScriptType.MODE_CMD: 
					return modeCmd;
					break;
				
				default: 
					break;
			}
			return null;
		}
		
		public static function WriteCommand(id:int, bytes:ByteArray):int
		{
			return ReadWriteCommand(id, bytes, true);
		}
		
		public static function ReadCommand(id:int, bytes:ByteArray):int
		{
			return ReadWriteCommand(id, bytes, false);
		}
		
		private static function ReadWriteCommand(id:int, bytes:ByteArray, isWrite:Boolean):int
		{
			var nBytes:uint;
			
			if (isWrite == false)
			{
				id = bytes.readByte();
				nBytes = bytes.readByte();
				current_read_cmd = null;
			}
			
			switch (id)
			{
				case ScriptType.SET_VALUE_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SET_VALUE_CMD : " + setValueCmd);
					if (isWrite)
					{
						bytes.writeByte(setValueCmd.type); //1
						bytes.writeByte(8); //2
						bytes.writeShort(setValueCmd.value_addr); //4
						bytes.writeInt(setValueCmd.set_value); //8
					}
					else
					{
						setValueCmd.type = id;
						setValueCmd.value_addr = bytes.readShort();
						setValueCmd.set_value = bytes.readInt();
						setValueCmd.size = nBytes;
						current_read_cmd = setValueCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.CALC_VALUE_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<CALC_VALUE_CMD : " + calcValueCmd);
					if (isWrite)
					{
						bytes.writeByte(calcValueCmd.type); //1
						bytes.writeByte(8); //2
						bytes.writeShort(calcValueCmd.value_addr); //4
						bytes.writeInt(calcValueCmd.add_value); //8
					}
					else
					{
						calcValueCmd.type = id;
						calcValueCmd.value_addr = bytes.readShort();
						calcValueCmd.add_value = bytes.readInt();
						calcValueCmd.size = nBytes;
						current_read_cmd = calcValueCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.TEXT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<TEXT_CMD : " + textCmd);
					if (isWrite)
					{
						bytes.writeByte(textCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeShort(textCmd.msg_len); //4
						bytes.writeBytes(textCmd.bytes);
					}
					else
					{
						textCmd.msg_len = bytes.readShort();
						textCmd.size = nBytes;
						current_read_cmd = textCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.CLEAR_TEXT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<CLEAR_TEXT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.CLEAR_TEXT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3 
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.GOTO_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<GOTO_CMD : " + gotoCmd);
					if (isWrite)
					{
						bytes.writeByte(gotoCmd.type); //1
						bytes.writeByte(8); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
						bytes.position += 4; //8 //label position: +4
					}
					else
					{
						bytes.position += 2;
						gotoCmd.goto_label = bytes.readInt();
						gotoCmd.size = nBytes;
						current_read_cmd = gotoCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.IF_TRUE_CMD: 
				case ScriptType.IF_FALSE_CMD: 
				case ScriptType.IF_BIGGER_CMD: 
				case ScriptType.IF_SMALLER_CMD: 
				case ScriptType.IF_BIGGER_EQU_CMD: 
				case ScriptType.IF_SMALLER_EQU_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<IF_XXX_CMD : " + ifCmd);
					if (isWrite)
					{
						bytes.writeByte(ifCmd.type); //1
						bytes.writeByte(16); //2
						bytes.writeByte(ifCmd.flag); //3
						bytes.writeByte(0); //4
						bytes.writeInt(ifCmd.value1); //8
						bytes.writeInt(ifCmd.value2); //12
						bytes.position += 4; //16 //label position: +12
					}
					else
					{
						ifCmd.type = id;
						ifCmd.flag = bytes.readByte();
						bytes.position++;
						ifCmd.value1 = bytes.readInt();
						ifCmd.value2 = bytes.readInt();
						ifCmd.goto_label = bytes.readInt();
						ifCmd.size = nBytes;
						current_read_cmd = ifCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.MENU_INIT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<MENU_INIT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.MENU_INIT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.MENU_INIT_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.MENU_ITEM_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<MENU_ITEM_CMD : " + menuItemCmd);
					if (isWrite)
					{
						bytes.writeByte(menuItemCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(menuItemCmd.number); //3
						bytes.writeByte(menuItemCmd.label_len); //4
						bytes.writeBytes(menuItemCmd.bytes);
					}
					else
					{
						menuItemCmd.number = bytes.readByte();
						menuItemCmd.label_len = bytes.readByte();
						menuItemCmd.size = nBytes;
						current_read_cmd = menuItemCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.MENU_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<MENU_CMD : " + menuCmd);
					if (isWrite)
					{
						bytes.writeByte(menuCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeShort(menuCmd.value_addr); //4
					}
					else
					{
						menuCmd.value_addr = bytes.readShort();
						menuCmd.size = nBytes;
						current_read_cmd = menuCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.EXEC_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<EXEC_CMD : " + execCmd);
					if (isWrite)
					{
						bytes.writeByte(execCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(execCmd.path_len); //4
						bytes.writeBytes(execCmd.bytes);
					}
					else
					{
						bytes.position++;
						execCmd.path_len = bytes.readByte();
						execCmd.size = nBytes;
						current_read_cmd = execCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.LOAD_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<LOAD_CMD : " + loadCmd);
					if (isWrite)
					{
						bytes.writeByte(loadCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(loadCmd.flag); //3
						bytes.writeByte(loadCmd.path_len); //4
						bytes.writeBytes(loadCmd.bytes);
					}
					else
					{
						loadCmd.flag = bytes.readByte();
						loadCmd.path_len = bytes.readByte();
						loadCmd.size = nBytes;
						current_read_cmd = loadCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.UPDATE_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<UPDATE_CMD : " + updateCmd);
					if (isWrite)
					{
						bytes.writeByte(updateCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(updateCmd.flag); //3
						bytes.writeByte(0); //4
					}
					else
					{
						updateCmd.flag = bytes.readByte();
						updateCmd.size = nBytes;
						current_read_cmd = updateCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.CLEAR_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<CLEAR_CMD : " + clearCmd);
					if (isWrite)
					{
						bytes.writeByte(clearCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(clearCmd.pos); //3
						bytes.writeByte(0); //4
					}
					else
					{
						clearCmd.pos = bytes.readByte();
						clearCmd.size = nBytes;
						current_read_cmd = clearCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.MUSIC_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<MUSIC_CMD : " + musicCmd);
					if (isWrite)
					{
						bytes.writeByte(musicCmd.type); //1
						bytes.writeByte(8); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
						bytes.writeInt(musicCmd.number); //8
					}
					else
					{
						bytes.position += 2;
						musicCmd.number = bytes.readInt();
						musicCmd.size = nBytes;
						current_read_cmd = musicCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.STOPM_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<STOPM_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.STOPM_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.STOPM_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SOUND_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SOUND_CMD : " + soundCmd);
					if (isWrite)
					{
						bytes.writeByte(soundCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(soundCmd.path_len); //4
						bytes.writeBytes(soundCmd.bytes);
					}
					else
					{
						bytes.position++;
						soundCmd.path_len = bytes.readByte();
						soundCmd.size = nBytes;
						current_read_cmd = soundCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SLEEP_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SLEEP_CMD : " + sleepCmd);
					if (isWrite)
					{
						bytes.writeByte(sleepCmd.time); //1
						bytes.writeByte(8); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
						bytes.writeInt(sleepCmd.time); //8
					}
					else
					{
						bytes.position += 2;
						sleepCmd.time = bytes.readInt();
						sleepCmd.size = nBytes;
						current_read_cmd = sleepCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.FADEIN_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<FADEIN_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.FADEIN_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.FADEIN_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.FADEOUT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<FADEOUT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.FADEOUT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.FADEOUT_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.WIPEIN_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<WIPEIN_CMD : " + wipeinCmd);
					if (isWrite)
					{
						bytes.writeByte(wipeinCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(wipeinCmd.pattern); //4
					}
					else
					{
						bytes.position++;
						wipeinCmd.pattern = bytes.readByte();
						wipeinCmd.size = nBytes;
						current_read_cmd = wipeinCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.WIPEOUT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<WIPEOUT_CMD : " + wipeoutCmd);
					if (isWrite)
					{
						bytes.writeByte(wipeoutCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(wipeoutCmd.pattern); //4
					}
					else
					{
						bytes.position++;
						wipeoutCmd.pattern = bytes.readByte();
						wipeoutCmd.size = nBytes;
						current_read_cmd = wipeoutCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.CUTIN_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<CUTIN_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.CUTIN_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.CUTIN_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.CUTOUT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<CUTOUT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.CUTOUT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.CUTOUT_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.WHITEIN_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<WHITEIN_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.WHITEIN_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.WHITEIN_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.WHITEOUT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<WHITEOUT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.WHITEOUT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.WHITEOUT_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.FLASH_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<FLASH_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.FLASH_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.FLASH_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SHAKE_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SHAKE_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.SHAKE_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.SHAKE_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.MODE_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<MODE_CMD : " + modeCmd);
					if (isWrite)
					{
						bytes.writeByte(modeCmd.type); //1
						bytes.writeByte(4); //2
						bytes.writeByte(modeCmd.mode); //3
						bytes.writeByte(0); //4
					}
					else
					{
						modeCmd.mode = bytes.readByte();
						bytes.position++;
						modeCmd.size = nBytes;
						current_read_cmd = modeCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SYS_LOAD_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SYS_LOAD_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.SYS_LOAD_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.SYS_LOAD_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SYS_EXIT_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SYS_EXIT_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.SYS_EXIT_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.SYS_EXIT_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.SYS_CLEAR_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<SYS_CLEAR_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.SYS_CLEAR_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.SYS_CLEAR_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				case ScriptType.END_CMD: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<END_CMD : ");
					if (isWrite)
					{
						bytes.writeByte(ScriptType.END_CMD); //1
						bytes.writeByte(4); //2
						bytes.writeByte(0); //3
						bytes.writeByte(0); //4
					}
					else
					{
						bytes.position += 2;
						normalCmd.type = ScriptType.END_CMD;
						normalCmd.size = nBytes;
						current_read_cmd = normalCmd;
						return nBytes;
					}
					break;
				
				default: 
					if (DEBUG_WRITE_COMMAND)
						trace("<<defalut : ");
					break;
			}
			return 0;
		}
	}
}

