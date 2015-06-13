/**
 * 执行Script
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.ui.Keyboard;
	import flash.utils.Endian;
	import com.iteye.weimingtom.marika.mkscript.ScriptType;
	import com.iteye.weimingtom.marika.mkscript.cmd.*;
	import com.iteye.weimingtom.marika.mkscript.ScriptType;
	import com.iteye.weimingtom.marika.mkscript.CommandBuffer;
	
	public class CScriptAction extends CAction
	{
		private const NO_BYTEARRY_CLEAR:Boolean = true;
		
		public static const BreakGame:int = -1;
		public static const Continue:int = 0;
		public static const WaitNextIdle:int = 1;
		public static const WaitKeyPressed:int = 2;
		public static const WaitTimeOut:int = 3;
		public static const WaitMenuDone:int = 4;
		public static const WaitWipeDone:int = 5;
		public static const WaitWaveDone:int = 6;
		
		protected static const FileNoError:int = 0;
		protected static const FileCannotOpen:int = 1;
		protected static const NotEnoughMemory:int = 2;
		protected static const FileCannotRead:int = 3;
		
		public var Params:CParams = new CParams();
		protected var Pressed:Boolean;
		protected var MenuSelect:int;
		protected var MenuAnserAddr:int;
		protected var PlayMode:int;
		protected var script_buffer:ByteArray; // = new ByteArray();
		protected var current:ScriptData = new ScriptData();
		protected var position:int;
		protected var status:int;
		
		public function CScriptAction()
		{
			super(true);
			//FIXME:
			//script_buffer.clear();
		}
		
		public function IsSaveLoadOK():Boolean
		{
			return PlayMode != ScriptType.MODE_SYSTEM && (status == WaitKeyPressed || status == WaitMenuDone);
		}
		
		/**
		 * FIXME:
		 * @return
		 */
		protected function GetCommand():Command //Object//command_t
		{
			//command_t *p = (command_t *)(current.commands + position);
			//position += p->common.size;
			script_buffer.position = current.commands + this.position;
			trace("CScriptAction::GetCommand() at ", this.position, " in script_buffer", " , length == ", script_buffer.length);
			CommandBuffer.ReadCommand(0, script_buffer);
			var p:Command = CommandBuffer.GetCommand();
			this.position += p.size;
			trace("p.size == ", p.size, " this.position == ", this.position);
			return p;
		}
		
		protected function GotoCommand2(next:uint):void
		{
			this.position = next;
		}
		
		/**
		 * FIXME:
		 * @param	size
		 * @return
		 */
		protected function GetString(size:uint):String
		{
			trace("CScriptAction::GetString() " + size);
			if (size == 0)
				return null;
			//char *p = (char *)current.commands + position;
			script_buffer.position = current.commands + this.position;
			var p:String = script_buffer.readMultiByte(size, "gbk");
			this.position += size;
			return p;
		}
		
		protected function GetValue(value_addr:uint):int
		{
			return Params.value_tab[value_addr];
		}
		
		//FIXME:flag:uint?int?
		protected function GetValue2(addr:int, flag:uint):int
		{
			if (flag)
				return addr;
			
			return Params.value_tab[addr];
		}
		
		protected function SetValue(value_addr:uint, set_value:int):void
		{
			Params.value_tab[value_addr] = set_value;
		}
		
		protected function CalcValue(value_addr:uint, calc_value:int):void
		{
			Params.value_tab[value_addr] += calc_value;
		}
		
		protected function ClearAllValues():void
		{
			Params.Clear();
		}
		
		/**
		 * 错误消息的格式
		 * @param	fmt
		 * @param	...rest
		 */
		/*
		   private function Format(fmt:String, ...rest)
		   {
		   static	char	tmp[256];
		
		   va_list	args;
		   va_start(args, fmt);
		   vsprintf(tmp, fmt, args);
		   va_end(args);
		
		   return tmp;
		   }
		 */
		
		/**
		 * 初始化
		 * @param	parent
		 * @param	param1
		 * @param	param2
		 */
		override public function Initialize(parent:CMainWin, param1:uint = 0, param2:uint = 0):void
		{
			super.Initialize(parent, param1, param2);
			status = Continue;
			Pressed = false;
			MenuSelect = -1;
			PlayMode = param1;
			Params.Clear();
			
			//FIXME:
			//delete[] script_buffer;
			//script_buffer = 0;
			script_buffer = null;
		}
		
		/**
		 * 暂停
		 */
		override public function Pause():void
		{
			switch (status)
			{
				case WaitMenuDone: // 等待菜单
					if (MenuSelect >= 0)
					{
						Parent.SelectMenu(MenuSelect, false);
						MenuSelect = -1;
					}
					break;
			}
		}
		
		//FIXME:
		public function GetCursorPos():Point
		{
			return null;
		}
		
		/**
		 * 解除暂停
		 */
		override public function Resume():void
		{
			switch (status)
			{
				case WaitMenuDone: // 等待菜单
				{
					//var	point:Point = new Point();
					var point:Point = GetCursorPos();
					Parent.ScreenToClient(point);
					MenuSelect = Parent.GetMenuSelect(point);
					if (MenuSelect >= 0)
						Parent.SelectMenu(MenuSelect, true);
				}
					break;
			}
		}
		
		//
		// 按下鼠标左键的处理
		//
		override public function LButtonDown(modKeys:uint, point:Point):void
		{
			switch (status)
			{
				case WaitMenuDone: // 等待菜单
					Pressed = true;
					break;
			}
		}
		
		/**
		 * 放开左键的处理
		 * @param	modKeys
		 * @param	point
		 */
		override public function LButtonUp(modKeys:uint, point:Point):void
		{
			switch (status)
			{
				case WaitKeyPressed: // 等待按键
					Parent.HideWaitMark();
					status = Continue;
					break;
				
				case WaitMenuDone: // 等待菜单
					if (Pressed)
					{
						Pressed = false;
						MouseMove(modKeys, point);
						
						if (MenuSelect >= 0)
						{
							SetValue(MenuAnserAddr, Parent.GetMenuAnser(MenuSelect));
							Parent.HideMenuWindow();
							status = Continue;
						}
						MenuSelect = -1;
					}
					break;
			}
		}
		
		//
		// 按下鼠标右键时的处理
		//
		override public function RButtonDown(modKeys:uint, point:Point):void
		{
			switch (status)
			{
				case WaitKeyPressed: // 等待按键
					Parent.FlipMessageWindow();
					break;
			}
		}
		
		/**
		 * 移动右键时的处理
		 * @param	modKeys
		 * @param	point
		 */
		override public function MouseMove(modKeys:uint, point:Point):void
		{
			switch (status)
			{
				case WaitMenuDone: // 等待菜单
				{
					var sel:int = Parent.GetMenuSelect(point);
					if (sel != MenuSelect)
					{
						Parent.SelectMenu(MenuSelect, false);
						MenuSelect = sel;
						Parent.SelectMenu(MenuSelect, true);
					}
				}
					break;
			}
		}
		
		/**
		 * 键盘按键按下时的处理
		 * @param	key
		 */
		override public function KeyDown(key:uint):void
		{
			switch (key)
			{
				case Keyboard.ENTER: 
				case Keyboard.SPACE: 
					switch (status)
					{
						case WaitKeyPressed: // 等待按键
							Parent.HideWaitMark();
							status = Continue;
							break;
						
						case WaitMenuDone: // 等待菜单
							if (MenuSelect >= 0)
							{
								SetValue(MenuAnserAddr, Parent.GetMenuAnser(MenuSelect));
								Parent.HideMenuWindow();
								status = Continue;
								MenuSelect = -1;
							}
							break;
					}
					break;
				
				case Keyboard.ESCAPE: 
					switch (status)
					{
						case WaitKeyPressed: // 等待按键
							Parent.FlipMessageWindow();
							break;
					}
					break;
				
				case Keyboard.UP: 
					// 等待菜单
					if (status == WaitMenuDone)
					{
						Parent.SelectMenu(MenuSelect, false);
						MenuSelect--;
						if (MenuSelect < 0)
							MenuSelect = Parent.GetMenuItemCount() - 1;
						Parent.SelectMenu(MenuSelect, true);
					}
					break;
				
				case Keyboard.DOWN: 
					// 等待菜单
					if (status == WaitMenuDone)
					{
						Parent.SelectMenu(MenuSelect, false);
						MenuSelect++;
						if (MenuSelect >= Parent.GetMenuItemCount())
							MenuSelect = 0;
						Parent.SelectMenu(MenuSelect, true);
					}
					break;
			}
		}
		
		/**
		 * IDLE处理
		 * @return
		 */
		override public function IdleAction():Boolean
		{
			// “继续”执行
			if (status == Continue)
			{
				do
				{
					// 执行1步
					status = Step();
				} while (status == Continue); // 继续？
				
				if (status == BreakGame) // 结束
				{
					Abort();
				}
				else if (status == WaitNextIdle) // 等到下一次IDLE再进来 
				{
					status = Continue; // 改为继续
					return true;
				}
				else if (status == WaitWipeDone) // 等待特效结束 
				{
					return true; // IDLE继续
				}
			}
			else
			{
				//trace("NOTE:CScriptAction::IdleAction status != Continue");
			}
			return false;
		}
		
		/**
		 * 计时器的处理
		 * @param	timerId
		 */
		override public function TimedOut(timerId:int):void
		{
			switch (timerId)
			{
				case CMainWin.TimerSleep: // 等待TimeOut
					if (status == WaitTimeOut)
						status = Continue;
					break;
			}
		}
		
		/**
		 * Wipe结束时的处理
		 */
		override public function WipeDone():void
		{
			if (status == WaitWipeDone) // 等待特效结束
				status = Continue;
		}
		
		/**
		 * Wave演奏结束时的处理
		 */
		override public function WaveDone():void
		{
			if (status == WaitWaveDone) // 等待播放WAVE结束
				status = Continue;
		}
		
		/**
		 * Script执行的结束
		 */
		public function Abort():void
		{
			if (status == WaitMenuDone) // 如果是等待菜单状态
				Parent.HideMenuWindow(); // 关闭菜单
			Parent.HideMessageWindow(); // 关闭文字框
			
			status = BreakGame;
			if (NO_BYTEARRY_CLEAR)
			{
				script_buffer.position = 0;
				script_buffer.length = 0;
			}
			else
			{
				Object(script_buffer).clear(); // 释放脚本
			}
			
			Parent.SetAction(CMainWin.ActionScriptDone);
		}
		
		/**
		 * 读取脚本档
		 * @param	name
		 * @return
		 */
		public function LoadFile(name:String):int
		{
			trace("CScriptAction::LoadFile ", name);
			
			//char	path[_MAX_PATH];
			//sprintf(path, SCRIPTPATH "%s.scr", name);
			var path:String = CConfig.SCRIPTPATH + name + ".scr";
			
			//delete[] script_buffer;
			//script_buffer = 0;
			script_buffer = null;
			
			//CFile file(path);
			var file:CFile = new CFile(path);
			
			if (!file)
				return FileCannotOpen;
			
			var length:int = file.GetFileSize();
			
			//if ((script_buffer = new char [length]) == 0)
			//	return NotEnoughMemory;
			script_buffer = new ByteArray();
			//FIXME: Windows风格
			script_buffer.endian = Endian.LITTLE_ENDIAN;
			
			if (file.Read(script_buffer, length) != length)
				return FileCannotRead;
			
			return FileNoError;
			//return 0;
		}
		
		/**
		 * 从文件读取脚本，存储脚本的空间也是在这里配置
		 * @param	name
		 * @return
		 */
		public function Load(name:String):Boolean
		{
			//strncpy(Params.last_script, name, 16);
			Params.last_script = name.substr(0, 16);
			trace("Params.last_script = ", Params.last_script);
			
			switch (LoadFile(name))
			{
				case FileCannotOpen: 
					Parent.MessageBox("脚本 [" + name + "] 无法开启。");
					return false;
				
				case NotEnoughMemory: 
					Parent.MessageBox("内存不足, 无法读取脚本[" + name + "]。");
					return false;
				
				case FileCannotRead: 
					Parent.MessageBox("无法读取脚本。[" + name + "]");
					return false;
			}
			trace("CScriptAction::Load ", "LoadFile(\"" + name + "\") success");
			
			//script_t *header = (script_t *)script_buffer;
			var magic:String = script_buffer.readMultiByte(8, "gbk");
			var ncommand:int = script_buffer.readInt();
			
			//header magic ==  [SCRIPT]
			//header ncommand ==  1880
			//dumpBuffer: 1892
			
			trace("magic == ", magic);
			trace("ncommand == ", ncommand);
			
			//if (memcmp(header.magic, SCRIPT_MAGIC, 8) != 0)
			if (magic != ScriptType.SCRIPT_MAGIC)
			{
				Parent.MessageBox("没有脚本数据。[" + name + "]");
				return false;
			}
			
			trace("CScriptAction::Load ", "magic correct");
			
			current.ncommand = ncommand; //header.ncommand;
			//current.commands = (byte_t * )(header + 1);
			current.commands = script_buffer.position;
			
			this.position = 0;
			
			return true;
		}
		
		/**
		 * 设定读取出的状态
		 * @param	param
		 * @return
		 */
		public function Setup(param:CParams):Boolean
		{
			Params = param;
			this.position = Params.script_pos;
			if (current.ncommand < this.position)
			{
				Parent.MessageBox("读取的数据异常。");
				return false;
			}
			if (param.last_bgm)
				Parent.StartMusic(param.last_bgm);
			switch (param.show_flag)
			{
				case CParams.SHOWCG_IMAGE: 
					if (param.last_bg[0])
						LoadGraphic(param.last_bg, ScriptType.POSITION_BACK);
					if (param.last_overlap[0])
					{
						LoadGraphic(param.last_overlap, ScriptType.POSITION_OVERLAP);
					}
					else if (param.last_center[0])
					{
						LoadGraphic(param.last_center, ScriptType.POSITION_CENTER);
					}
					else
					{
						if (param.last_left[0])
							LoadGraphic(param.last_left, ScriptType.POSITION_LEFT);
						if (param.last_right[0])
							LoadGraphic(param.last_right, ScriptType.POSITION_RIGHT);
					}
					status = WipeIn();
					break;
				
				case CParams.SHOWCG_BLACKNESS: 
					CutOut();
					status = Continue;
					break;
				
				case CParams.SHOWCG_WHITENESS: 
					CutOut(true);
					status = Continue;
					break;
			}
			return true;
		}
		
		//FIXME:
		/*
		 *
		 */
		public function ASSERT(... args):void
		{
		
		}
		
		/**
		 * 执行脚本的1步
		 * @return
		 */
		public function Step():int
		{
			ASSERT(script_buffer);
			
			var last_pos:int = this.position;
			var cmd:Command = GetCommand();
			
			switch (cmd.type)
			{
				case ScriptType.SET_VALUE_CMD: 
					SetValue(SetValueCommand(cmd).value_addr, SetValueCommand(cmd).set_value);
					break;
				
				case ScriptType.CALC_VALUE_CMD: 
					CalcValue(CalcValueCommand(cmd).value_addr, CalcValueCommand(cmd).add_value);
					break;
				
				case ScriptType.TEXT_CMD: 
					Params.script_pos = last_pos;
					Parent.WriteMessage(GetString(TextCommand(cmd).msg_len));
					return WaitKeyPressed;
				
				case ScriptType.CLEAR_TEXT_CMD: 
					Parent.ClearMessage();
					return WaitNextIdle;
				
				case ScriptType.MUSIC_CMD: 
					Params.last_bgm = MusicCommand(cmd).number;
					Parent.StartMusic(MusicCommand(cmd).number);
					break;
				
				case ScriptType.STOPM_CMD: 
					Params.last_bgm = 0;
					Parent.StopMusic();
					break;
				
				case ScriptType.SOUND_CMD: 
					if (Parent.StartWave(GetString(SoundCommand(cmd).path_len)))
						return WaitWaveDone;
					return Continue;
				
				case ScriptType.SLEEP_CMD: 
					Parent.SetTimer(CMainWin.TimerSleep, SleepCommand(cmd).time * 1000);
					return WaitTimeOut;
				
				case ScriptType.GOTO_CMD: 
					GotoCommand2(GotoCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_TRUE_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) == GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand2(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_FALSE_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) != GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand2(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_BIGGER_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) > GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand2(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_SMALLER_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) < GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand2(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_BIGGER_EQU_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) >= GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.IF_SMALLER_EQU_CMD: 
					if (GetValue2(IfCommand(cmd).value1, IfCommand(cmd).flag & 1) <= GetValue2(IfCommand(cmd).value2, IfCommand(cmd).flag & 2))
						GotoCommand2(IfCommand(cmd).goto_label);
					break;
				
				case ScriptType.MENU_INIT_CMD: 
					Params.script_pos = last_pos;
					Parent.ClearMenuItemCount();
					break;
				
				case ScriptType.MENU_ITEM_CMD: 
					Parent.SetMenuItem(GetString(MenuItemCommand(cmd).label_len), MenuItemCommand(cmd).number);
					break;
				
				case ScriptType.MENU_CMD: 
					MenuSelect = -1;
					MenuAnserAddr = MenuCommand(cmd).value_addr;
					Parent.OpenMenu();
					return WaitMenuDone;
				
				case ScriptType.EXEC_CMD: 
					if (!Load(GetString(ExecCommand(cmd).path_len)))
						return BreakGame;
					PlayMode = ScriptType.MODE_SCENARIO;
					break;
				
				case ScriptType.LOAD_CMD: 
					return LoadGraphic(GetString(LoadCommand(cmd).path_len), LoadCommand(cmd).flag);
				
				case ScriptType.UPDATE_CMD: 
					return UpdateImage(UpdateCommand(cmd).flag);
				
				case ScriptType.CLEAR_CMD: 
					return Clear(ClearCommand(cmd).pos);
				
				case ScriptType.CUTIN_CMD: 
					return CutIn();
				
				case ScriptType.CUTOUT_CMD: 
					return CutOut();
				
				case ScriptType.FADEIN_CMD: 
					return FadeIn();
				
				case ScriptType.FADEOUT_CMD: 
					return FadeOut();
				
				case ScriptType.WIPEIN_CMD: 
					return WipeIn(WipeinCommand(cmd).pattern);
				
				case ScriptType.WIPEOUT_CMD: 
					return WipeOut(WipeoutCommand(cmd).pattern);
				
				case ScriptType.WHITEIN_CMD: 
					return WhiteIn();
				
				case ScriptType.WHITEOUT_CMD: 
					return WhiteOut();
				
				case ScriptType.SHAKE_CMD: 
					Parent.Shake();
					return WaitWipeDone;
				
				case ScriptType.FLASH_CMD: 
					Parent.Flash();
					return WaitWipeDone;
				
				case ScriptType.MODE_CMD: 
					PlayMode = ModeCommand(cmd).mode;
					break;
				
				case ScriptType.SYS_LOAD_CMD: 
					Parent.SetAction(CMainWin.ActionGameLoad);
					return WaitNextIdle;
				
				case ScriptType.SYS_EXIT_CMD: 
					Parent.SendMessage(CWindow.WM_CLOSE);
					return WaitNextIdle;
				
				case ScriptType.SYS_CLEAR_CMD: 
					ClearAllValues();
					break;
				
				case ScriptType.END_CMD: 
					return BreakGame;
				
				default: 
					ASSERT(false);
					break;
			}
			return Continue;
		}
		
		/**
		 * 读取图片档CG
		 * @param	file
		 * @param	pos
		 * @return
		 */
		public function LoadGraphic(file:String, pos:int):int
		{
			var result:Boolean = false;
			switch (pos)
			{
				case ScriptType.POSITION_BACK: // 背景
					trace("CScriptAction::LoadGraphic POSITION_BACK :" + file);
					Params.ClearOverlapCG();
					Parent.ClearOverlap();
				// no break
				
				case ScriptType.POSITION_BACKONLY: // 只有背景
					trace("CScriptAction::LoadGraphic POSITION_BACKONLY :" + file);
					Params.SetBackCG(file);
					result = Parent.LoadImageBack(file);
					break;
				
				case ScriptType.POSITION_CENTER: // 中间
					trace("CScriptAction::LoadGraphic POSITION_CENTER :" + file);
					Params.SetCenterCG(file);
					result = Parent.LoadImageCenter(file);
					break;
				
				case ScriptType.POSITION_LEFT: // 左
					trace("CScriptAction::LoadGraphic POSITION_LEFT :" + file);
					Params.SetLeftCG(file);
					result = Parent.LoadImageLeft(file);
					break;
				
				case ScriptType.POSITION_RIGHT: // 右
					trace("CScriptAction::LoadGraphic POSITION_RIGHT :" + file);
					Params.SetRightCG(file);
					result = Parent.LoadImageRight(file);
					break;
				
				case ScriptType.POSITION_OVERLAP: // 重叠
					trace("CScriptAction::LoadGraphic POSITION_OVERLAP :" + file);
					Params.SetOverlapCG(file);
					result = Parent.LoadImageOverlap(file);
					break;
			}
			if (!result)
			{
				Parent.MessageBox("文件无法读取。[" + file + "]");
				if (PlayMode == ScriptType.MODE_SYSTEM)
					Parent.SendMessage(CWindow.WM_CLOSE);
				return BreakGame;
			}
			return Continue;
		}
		
		/**
		 * 清除图片CG
		 * @param	pos
		 * @return
		 */
		public function Clear(pos:int):int
		{
			switch (pos)
			{
				case ScriptType.POSITION_BACK: // 背景
					Params.ClearOverlapCG();
					Parent.ClearOverlap();
				// no break
				
				case ScriptType.POSITION_BACKONLY: // 只有背景
					Params.ClearBackCG();
					Parent.ClearBack();
					break;
				
				case ScriptType.POSITION_CENTER: // 中间
					Params.ClearCenterCG();
					Parent.ClearCenter();
					break;
				
				case ScriptType.POSITION_LEFT: // 左
					Params.ClearLeftCG();
					Parent.ClearLeft();
					break;
				
				case ScriptType.POSITION_RIGHT: // 右
					Params.ClearRightCG();
					Parent.ClearRight();
					break;
				
				case ScriptType.POSITION_OVERLAP: // 重叠
					Params.ClearOverlapCG();
					Parent.ClearOverlap();
					break;
			}
			return Continue;
		}
		
		/**
		 * 更新显示
		 * @param	flag
		 * @return
		 */
		public function UpdateImage(flag:int):int
		{
			Params.SetShowFlag();
			var rect:Rectangle = Parent.GetInvalidRect();
			if (rect.isEmpty())
				return Continue;
			switch (flag)
			{
				case ScriptType.UPDATE_NOW: 
					trace("CScriptAction::UpdateImage() UPDATE_NOW " + rect);
					Parent.CutIn(rect);
					return WaitNextIdle;
				
				case ScriptType.UPDATE_OVERLAP: 
					trace("CScriptAction::UpdateImage() UPDATE_OVERLAP " + rect);
					Parent.MixFade(rect);
					break;
				//Parent.CutIn(rect);
				//return WaitNextIdle;
				
				case ScriptType.UPDATE_WIPE: 
					trace("CScriptAction::UpdateImage() UPDATE_WIPE " + rect);
					Parent.WipeIn(rect);
					break;
			}
			return WaitWipeDone;
		}
		
		/**
		 * 淡入
		 * @return
		 */
		public function FadeIn():int
		{
			Params.SetShowFlag();
			Parent.FadeIn();
			return WaitWipeDone;
		}
		
		/**
		 * 淡出
		 * @return
		 */
		public function FadeOut():int
		{
			Params.ResetShowFlag();
			Parent.FadeOut();
			return WaitWipeDone;
		}
		
		/**
		 * 切入
		 * @return
		 */
		public function CutIn():int
		{
			Params.SetShowFlag();
			Parent.CutIn2();
			return WaitNextIdle;
		}
		
		/**
		 * 切出
		 * @param	white
		 * @return
		 */
		public function CutOut(white:Boolean = false):int
		{
			Params.ResetShowFlag(white);
			Parent.CutOut(white);
			return WaitNextIdle;
		}
		
		/**
		 * 转入
		 * @param	pattern
		 * @return
		 */
		public function WipeIn(pattern:int = 1):int
		{
			Params.SetShowFlag();
			Parent.WipeIn2(pattern);
			return WaitWipeDone;
		}
		
		/**
		 * 转出
		 * @param	pattern
		 * @return
		 */
		public function WipeOut(pattern:int):int
		{
			Params.ResetShowFlag();
			Parent.WipeOut(pattern);
			return WaitWipeDone;
		}
		
		/**
		 * 淡入(白入)
		 * @return
		 */
		public function WhiteIn():int
		{
			Params.SetShowFlag();
			Parent.WhiteIn();
			return WaitWipeDone;
		}
		
		/**
		 * 淡出(白出)
		 * @return
		 */
		public function WhiteOut():int
		{
			Params.ResetShowFlag(true);
			Parent.WhiteOut();
			return WaitWipeDone;
		}
	}
}