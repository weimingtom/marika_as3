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
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import com.iteye.weimingtom.marika.mkscript.cmd.CalcValueCommand;
	import com.iteye.weimingtom.marika.mkscript.cmd.ClearCommand;
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
	
	/**
	 * ...
	 * @author
	 */
	public class MakeScript
	{
		private const NO_BYTEARRY_CLEAR:Boolean = true;
		
		/**
		 * 调试输出前缀：
		 * 		<< 输出
		 * 		<<<< 标号输出
		 * 		>> 扫描器的符号切割
		 * 		===> 标号相关信息
		 *
		 *  if/goto回填地址见
		 * 		WriteIntByAddress
		 *
		 *  在写入后添加标签
		 *
		 */
		
		private static const DEBUG_MENU:Boolean = false; //-->menu:
		private static const DEBUG_NORMAL_ERROR:Boolean = true;
		private static const DEBUG_FATAL_ERROR:Boolean = true;
		private static const DEBUG_NOTICE:Boolean = true;
		private static const DEBUG_FMT_THEN_LABEL:Boolean = false;
		private static const DEBUG_FMT_ENDIF:Boolean = false;
		private static const DEBUG_REF_VALUE:Boolean = true;
		private static const DEBUG_WRITE_LABEL:Boolean = true;
		
		// 错误消息
		protected static const MsgNotice:int = 0;
		protected static const MsgError:int = 1;
		protected static const MsgFatal:int = 2;
		
		private var nerror:int;
		private var then_index:uint;
		
		//then堆栈
		private var then_nest:Array = new Array(); //stack<unsigned>
		
		//缓冲区
		private var command_buffer:ByteArray = new ByteArray(); //TODO:
		//缓冲区最大值
		private static const MAX_COMMAND:int = 65536;
		//缓冲区command_buffer的当前位置，随ByteArray的数据而增加
		//private var ncommand:int;
		
		private var add_value:Boolean;
		
		private var value_name:Array = new Array(); //vector<string>
		//value_name的最大长度
		private static const MAX_VALUES:int = 100;
		
		//文本框的最大行数
		private static const MAX_TEXTLINE:int = 4;
		
		//关于Label的Array
		private var labels:Array = new Array(); //vector<Label>	
		
		private var cmd_table:Object = new Object(); //cmdmap
		
		protected var reader:FileReader;
		
		// 调试用，用于保存数据到本地文件（使用Java搭建简单服务器）
		private var socket:Socket = new Socket();
		
		public function IsError():Boolean
		{
			return nerror != 0;
		}
		
		public function MakeScript()
		{
			reader = null;
			nerror = 0;
			then_index = 0;
			//ncommand = 0;
			command_buffer.position = 0;
			add_value = false;
			
			//if ((command_buffer = new char[MAX_COMMAND]) == 0)
			//	throw bad_alloc();
			
			// 命令表格初始化
			cmd_table["set"] = SetCmd;
			cmd_table["calc"] = SetCmd;
			cmd_table["text"] = TextCmd;
			cmd_table["goto"] = GotoCmd;
			cmd_table["if"] = IfCmd;
			cmd_table["else"] = ElseCmd;
			cmd_table["endif"] = EndifCmd;
			cmd_table["menu"] = MenuCmd;
			cmd_table["exec"] = ExecCmd;
			cmd_table["load"] = LoadCmd;
			cmd_table["update"] = UpdateCmd;
			cmd_table["clear"] = ClearCmd;
			cmd_table["music"] = MusicCmd;
			cmd_table["stopm"] = StopmCmd;
			cmd_table["wait"] = WaitCmd;
			cmd_table["sound"] = SoundCmd;
			cmd_table["fadein"] = FadeInCmd;
			cmd_table["fadeout"] = FadeOutCmd;
			cmd_table["wipein"] = WipeInCmd;
			cmd_table["wipeout"] = WipeOutCmd;
			cmd_table["cutin"] = CutInCmd;
			cmd_table["cutout"] = CutOutCmd;
			cmd_table["whitein"] = WhiteInCmd;
			cmd_table["whiteout"] = WhiteOutCmd;
			cmd_table["flash"] = FlashCmd;
			cmd_table["shake"] = ShakeCmd;
			cmd_table["mode"] = ModeCmd;
			cmd_table["system"] = SystemCmd;
			cmd_table["end"] = EndCmd;
			
			// 遵循Windows文件系统的习惯
			command_buffer.endian = Endian.LITTLE_ENDIAN;
			if (NO_BYTEARRY_CLEAR)
			{
				command_buffer.position = 0;
				command_buffer.length = 0;
			}
			else
			{
				Object(command_buffer).clear();
			}
			
			// 调试端口，用于保存到本地文件
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecrityError);
			socket.addEventListener(Event.CLOSE, onSocketClose);
			socket.addEventListener(Event.CONNECT, onSocketConnect);
		}
		
		/**
		 * 读进变量表格
		 * @return
		 */
		public function OpenValueTable():Boolean
		{
			var fin:FileHandle = FileLoader.open(GetValueFile(), "r");
			if (fin == null)
				return false;
			
			var str:String;
			while ((str = fin.getLineString()) != null)
			{
				value_name.push_back(str);
				trace(str);
			}
			
			return true;
		}
		
		/**
		 * 将数据写入变量表格
		 * @return
		 */
		public function CloseValueTable():Boolean
		{
			//TODO:
			/*
			   ofstream	fout(GetValueFile());
			
			   if (!fout)
			   throw("can't create value table file");
			
			   for (int i = 0; i < value_name.size(); i++)
			   {
			   fout << value_name[i] << '\n';
			   }
			   return true;
			 */
			return false;
		}
		
		/**
		 * 在变量表格搜寻该变量，传回索引值
		 * @param	value
		 * @return
		 */
		public function FindValue(value:String):int
		{
			var i:int = value_name.indexOf(value);
			// 找到变量，传回变量的索引
			if (i != -1)
				return i;
			
			// 变量表格结束了？
			if (value_name.length >= MAX_VALUES)
			{
				NormalError("too meny values.");
				return -1;
			}
			
			// 新增变量
			value_name.push(value);
			// 记忆有更改的动作发生
			add_value = true;
			
			return value_name.length - 1; // 传回变量索引
		}
		
		/**
		 * 变量表格的参照档名
		 * @return
		 */
		public function GetValueFile():String
		{
			//return "value.tbl";
			return "value.txt";
		}
		
		/**
		 * 错误消息的输出
		 * @param	code
		 * @param	str
		 */
		public function OutputMessage(code:int, str:String):void
		{
			trace(str);
		}
		
		/**
		 * 加入档名与行号(错误消息)
		 * @return
		 */
		public function GetErrorPrefix():String
		{
			if (reader == null)
				return "";
			return reader.GetFileName() + ":" + reader.GetLineNo();
		}
		
		/**
		 * 错误消息的输出(有错误编号)
		 * @param	str
		 */
		public function ErrorMessage(str:String):void
		{
			nerror++;
			OutputMessage(MsgError, GetErrorPrefix() + str);
		}
		
		/**
		 * 错误消息的输出(错误计数值、行号)
		 * @param	str
		 */
		public function NormalError(str:String):void
		{
			if (DEBUG_NORMAL_ERROR)
			{
				try
				{
					throw new Error();
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
			}
			
			nerror++;
			OutputMessage(MsgError, "[" + GetErrorPrefix() + "]" + str);
		}
		
		/**
		 * 显示致命错误消息(错误计数值、行号)
		 * @param	str
		 */
		public function FatalError(str:String):void
		{
			if (DEBUG_FATAL_ERROR)
			{
				try
				{
					throw new Error();
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
			}
			
			nerror++;
			OutputMessage(MsgFatal, GetErrorPrefix() + str);
		}
		
		/**
		 * 显示消息(但消息计数器不递增)
		 * @param	str
		 */
		public function Notice(str:String):void
		{
			if (DEBUG_NOTICE)
			{
				try
				{
					throw new Error();
				}
				catch (e:Error)
				{
					trace(e.getStackTrace());
				}
			}
			
			OutputMessage(MsgNotice, GetErrorPrefix() + str);
		}
		
		//
		// 产生if then时的标签
		//
		public function ThenLabel():String
		{
			// 产生then的标签号码
			var idx:uint = then_index++ << 16;
			// 压进堆栈(push)
			then_nest.push(idx);
			return FmtThenLabel(idx);
		}
		
		/**
		 * 注册标签
		 * @param	label
		 */
		public function AddLabel(label:String):void
		{
			for each (var lp:Label in labels)
			{
				// 已经注册了
				if (lp.label == label)
				{
					// 标签已经定义了
					if (lp.ref == null)
					{
						NormalError("label " + label + " redefinition line " + lp.line + " and " + reader.GetLineNo());
					}
					// 标签已经被引用了
					else
					{
						var chain:LabelRef = lp.ref;
						lp.line = reader.GetLineNo();
						lp.ref = null;
						lp.jmp_addr = command_buffer.position; //ncommand;
						// 清除引用
						while (chain != null)
						{
							if (DEBUG_REF_VALUE)
								trace("===>ref label_ref_address:", chain.label_ref_address);
							var next:LabelRef = chain.next;
							//FIXME:在label_ref_address处写入command_buffer.position
							//chain.label_ref_address = command_buffer.position; //ncommand;
							if (DEBUG_WRITE_LABEL)
								trace("<<<< write address: " + chain.label_ref_address + " , value: " + command_buffer.position);
							WriteIntByAddress(chain.label_ref_address, command_buffer.position);
							chain = null; // delete chain
							chain = next;
						}
						if (DEBUG_REF_VALUE)
							trace("===>set label_ref:", label, lp.line, command_buffer.position);
					}
					return;
				}
			}
			// 注册新的标签
			labels.push(new Label(label, reader.GetLineNo(), command_buffer.position, null)); // ncommand, null));
			if (DEBUG_REF_VALUE)
				trace("===>new Label:", label, reader.GetLineNo(), command_buffer.position);
		}
		
		/**
		 * 引用标签（标签指以*开头的标识符或者else if/else/endif）
		 * 记录标签被使用的地方（在缓冲区的goto或if/else if/else命令后），
		 * 找到标签后才在这个缓冲区地址处写入标签信息。
		 * @param	label 标签名称
		 * @param	reference_address 标签块的开始位置
		 */
		public function FindLabel(label:String, reference_address:uint):void //reference:GotoLabelRef):void
		{
			//FIXME:在reference_address处写入0
			//reference.value = 0;
			if (DEBUG_WRITE_LABEL)
				trace("<<<< write address: " + reference_address + " , value: " + 0);
			WriteIntByAddress(reference_address, 0);
			
			for each (var lp:Label in labels)
			{
				// 已经注册了
				if (lp.label == label)
				{
					// 标签有被引用
					if (lp.ref != null)
					{
						// 新增在参考串列中
						lp.ref = new LabelRef(lp.ref, reference_address);
						if (DEBUG_REF_VALUE)
							trace("===>new LabelRef:", lp.label, lp.jmp_addr);
					}
					// 已经注册了
					else
					{
						// 回填跳跃目标
						//FIXME:在reference_address处写入跳跃目标
						//reference.value = lp.jmp_addr;
						if (DEBUG_WRITE_LABEL)
							trace("<<<< write address: ", reference_address + ", value: " + lp.jmp_addr, lp.label);
						WriteIntByAddress(reference_address, lp.jmp_addr);
					}
					return;
				}
			}
			// 登录新的标签参考
			var chain:LabelRef = new LabelRef(null, reference_address);
			labels.push(new Label(label, reader.GetLineNo(), 0, chain));
			if (DEBUG_REF_VALUE)
				trace("===>new Label:", label, reader.GetLineNo());
		}
		
		/**
		 * 标签的确认
		 */
		public function LabelCheck():void
		{
			for each (var lp:Label in labels)
			{
				// 还有引用留下
				if (lp.ref != null)
				{
					var label:String = lp.label;
					switch (label.substr(0, 1))
					{
						case '#': 
							ErrorMessage("can't find \"endif\". (line " + lp.line + ")");
							break;
						
						default: 
							ErrorMessage("label " + label + " undefined. (line " + lp.line + ")");
							break;
					}
					var chain:LabelRef = lp.ref;
					// 释放引用连结
					while (chain != null)
					{
						var next:LabelRef = chain.next;
						//delete chain;
						chain = null;
						chain = next;
					}
				}
			}
		}
		
		/**
		 * 注册标签
		 * @param	lexer
		 */
		public function SetLabel(lexer:Lexer):void
		{
			if (lexer.NumToken() != 1)
			{
				NormalError("too meny parameter");
				return;
			}
			
			var p:String = lexer.GetString().substr(1);
			AddLabel(p);
		}
		
		/**
		 * 比较关键字，允许头文字的省略写法
		 * @param	str
		 * @param	keyword
		 * @return
		 */
		public function ChkKeyword(str:String, keyword:String):Boolean
		{
			for (var pos:int = 0; pos < str.length; ++pos)
			{
				if (str.substr(pos, 1).toLowerCase() != keyword.substr(pos, 1))
					return false;
			}
			return true;
		}
		
		//
		// 判断CG读入的位置
		//
		public function GetPosition(str:String):int
		{
			if (ChkKeyword(str, "center"))
				return ScriptType.POSITION_CENTER;
			if (ChkKeyword(str, "left"))
				return ScriptType.POSITION_LEFT;
			if (ChkKeyword(str, "right"))
				return ScriptType.POSITION_RIGHT;
			if (ChkKeyword(str, "bg") || ChkKeyword(str, "back"))
				return ScriptType.POSITION_BACK;
			if (ChkKeyword(str, "bgo") || ChkKeyword(str, "backonly"))
				return ScriptType.POSITION_BACKONLY;
			if (ChkKeyword(str, "overlap"))
				return ScriptType.POSITION_OVERLAP;
			NormalError("syntax error (position)");
			return ScriptType.POSITION_BACK;
		}
		
		//
		// 特效指定的更新作进程序码中
		//
		public function GetUpdateType(str:String):int
		{
			if (ChkKeyword(str, "cut") || ChkKeyword(str, "now"))
				return ScriptType.UPDATE_NOW;
			if (ChkKeyword(str, "overlap"))
				return ScriptType.UPDATE_OVERLAP;
			if (ChkKeyword(str, "wipe"))
				return ScriptType.UPDATE_WIPE;
			NormalError("syntax error (update type)");
			return ScriptType.UPDATE_NOW;
		}
		
		/**
		 * 登录set命令
		 * @param	lexer
		 */
		public function SetCmd(lexer:Lexer):void
		{
			var p1:String = lexer.GetString();
			var p2:String = lexer.GetString();
			var value:Number = lexer.GetValue(); // b3
			
			if (p1 == null || p2 == null || isNaN(value) || lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			
			switch (p2)
			{
				// 指定
				case "=": 
					var cp1:SetValueCommand = CommandBuffer.NewCommand(ScriptType.SET_VALUE_CMD) as SetValueCommand;
					cp1.value_addr = FindValue(p1);
					cp1.set_value = value;
					CommandBuffer.WriteCommand(ScriptType.SET_VALUE_CMD, command_buffer);
					break;
				
				// 加法
				case "+": 
					var cp2:CalcValueCommand = CommandBuffer.NewCommand(ScriptType.CALC_VALUE_CMD) as CalcValueCommand;
					cp2.value_addr = FindValue(p1);
					cp2.add_value = value;
					CommandBuffer.WriteCommand(ScriptType.CALC_VALUE_CMD, command_buffer);
					break;
				
				// 减法
				case "-": 
					var cp3:CalcValueCommand = CommandBuffer.NewCommand(ScriptType.CALC_VALUE_CMD) as CalcValueCommand;
					cp3.value_addr = FindValue(p1);
					// 改为加上负值
					cp3.add_value = -value;
					CommandBuffer.WriteCommand(ScriptType.CALC_VALUE_CMD, command_buffer);
					break;
				
				default: 
					NormalError("syntax error");
					break;
			}
		}
		
		//
		// 登录goto命令
		//
		public function GotoCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in goto command)");
				return;
			}
			
			var cp:GotoCommand = CommandBuffer.NewCommand(ScriptType.GOTO_CMD) as GotoCommand;
			//FIXME:goto的写入地址偏移块头+4
			FindLabel(p, command_buffer.position + 4); //cp.goto_label);
			CommandBuffer.WriteCommand(ScriptType.GOTO_CMD, command_buffer);
		}
		
		//
		// 判断并取得变量或数字字符串
		//
		public function GetValueOrNumber(value:ValueOrNumber, lexer:Lexer):Boolean
		{
			var type:String = lexer.GetType();
			
			// 字符串
			if (type == Lexer.IsString)
			{
				var p:String = lexer.GetString();
				value.value = FindValue(p);
				value.isvalue = false;
			}
			// 字符串以外
			else
			{
				// 读取数字
				var result:Number = lexer.GetValue();
				if (isNaN(result))
					return false; // 错误
				value.value = result;
				value.isvalue = true;
			}
			return true;
		}
		
		//
		// 指令码与比较运算子的对应关系
		//
		public function BoolOp(op:String):int
		{
			switch (op)
			{
				case "==": 
					return ScriptType.IF_TRUE_CMD;
				
				case "!=": 
					return ScriptType.IF_FALSE_CMD;
				
				case "<=": 
					return ScriptType.IF_SMALLER_EQU_CMD;
				
				case ">=": 
					return ScriptType.IF_BIGGER_EQU_CMD;
				
				case "<": 
					return ScriptType.IF_SMALLER_CMD;
				
				case ">": 
					return ScriptType.IF_BIGGER_CMD;
			}
			NormalError("syntax error");
			return -1;
		}
		
		//
		// 比较运算子的判断(逻辑反转)
		//
		public function NegBoolOp(op:String):int
		{
			switch (op)
			{
				case "==": 
					return ScriptType.IF_FALSE_CMD;
				
				case "!=": 
					return ScriptType.IF_TRUE_CMD;
				
				case "<=": 
					return ScriptType.IF_BIGGER_CMD;
				
				case ">=": 
					return ScriptType.IF_SMALLER_CMD;
				
				case "<": 
					return ScriptType.IF_BIGGER_EQU_CMD;
				
				case ">": 
					return ScriptType.IF_SMALLER_EQU_CMD;
			}
			NormalError("syntax error");
			return -1;
		}
		
		//
		// 登录if命令
		//
		public function IfCmd(lexer:Lexer):void
		{
			var val1:ValueOrNumber = new ValueOrNumber();
			var val2:ValueOrNumber = new ValueOrNumber();
			var b1:Boolean = GetValueOrNumber(val1, lexer);
			var op:String = lexer.GetString();
			var b2:Boolean = GetValueOrNumber(val2, lexer);
			
			if (!b1 || !b2 || op == null)
			{
				NormalError("syntax error (in if command)");
				return;
			}
			
			var cp:IfCommand = CommandBuffer.NewCommand(ScriptType.IF_TRUE_CMD) as IfCommand;
			cp.flag = 0;
			if (val1.isvalue)
				cp.flag |= 1;
			cp.value1 = val1.value;
			if (val2.isvalue)
				cp.flag |= 2;
			cp.value2 = val2.value;
			
			var p:String = lexer.GetString();
			var label:String = null;
			if (p != null)
			{
				switch (p.toLowerCase())
				{
					// if-goto
					case "goto": 
						label = lexer.GetString();
						cp.type = BoolOp(op);
						break;
					
					// if-then
					case "then": 
						label = ThenLabel();
						cp.type = NegBoolOp(op);
						break;
				}
			}
			if (label == null || lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			//FIXME:if的写入地址偏移块头+12
			FindLabel(label, command_buffer.position + 12); // cp.goto_label);
			CommandBuffer.WriteCommand(ScriptType.IF_TRUE_CMD, command_buffer);
		}
		
		//
		// 处理else命令
		//
		public function ElseCmd(lexer:Lexer):void
		{
			// then标签没有登录
			if (then_nest.length == 0)
			{
				NormalError("\"if\", \"else\" nest error.");
				return;
			}
			
			//FIXME:弹出堆栈
			var idx:uint = then_nest.pop() as uint;
			
			var else_label:String = FmtThenLabel(idx);
			
			var cp1:GotoCommand = CommandBuffer.NewCommand(ScriptType.GOTO_CMD) as GotoCommand;
			var goto_label:String;
			then_nest.push(idx + 1);
			goto_label = FmtThenLabel(idx | 0xffff);
			//FIXME:goto的写入地址偏移块头+4
			FindLabel(goto_label, command_buffer.position + 4); //cp1.goto_label);
			CommandBuffer.WriteCommand(ScriptType.GOTO_CMD, command_buffer);
			//FIXME:在写入后添加标签
			AddLabel(else_label);
			
			var p:String = lexer.GetString();
			
			// 如果只有else就结束
			if (p == null)
			{
				return;
			}
			// else if时的动作
			else if (p.toLowerCase() == "if")
			{
				var val1:ValueOrNumber = new ValueOrNumber();
				var val2:ValueOrNumber = new ValueOrNumber();
				var b1:Boolean = GetValueOrNumber(val1, lexer);
				var op:String = lexer.GetString();
				var b2:Boolean = GetValueOrNumber(val2, lexer);
				
				if (!b1 || !b2 || op == null)
				{
					NormalError("syntax error (in else if command)");
					return;
				}
				var cp2:IfCommand = CommandBuffer.NewCommand(ScriptType.IF_TRUE_CMD) as IfCommand;
				cp2.type = NegBoolOp(op)
				cp2.flag = 0;
				if (val1.isvalue)
					cp2.flag |= 1;
				cp2.value1 = val1.value;
				if (val2.isvalue)
					cp2.flag |= 2;
				cp2.value2 = val2.value;
				
				var p2:String = lexer.GetString();
				if (p2 == null || p2.toLowerCase() != "then")
				{
					NormalError("syntax error");
					return;
				}
				
				var label:String = FmtThenLabel(idx + 1);
				//FIXME:if的写入地址偏移块头+12
				FindLabel(label, command_buffer.position + 12); //p2.goto_label);
				CommandBuffer.WriteCommand(ScriptType.IF_TRUE_CMD, command_buffer);
			}
			else
			{
				NormalError("syntax error (in else command)");
				return;
			}
		}
		
		/**
		 * 处理endif命令
		 * @param	lexer
		 */
		public function EndifCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error (in endif command)");
				return;
			}
			
			if (then_nest.length == 0)
			{
				NormalError("\"if\", \"endif\" nest error.");
				return;
			}
			
			var tmp:String;
			//FIXME:弹出堆栈
			var idx:uint = then_nest.pop();
			//trace("idx:", idx);
			
			tmp = FmtThenLabel(idx);
			AddLabel(tmp);
			
			if ((idx & 0xffff) != 0)
			{
				//FIXME:这里为何用|不用& ？
				tmp = FmtThenLabel(idx | 0xffff);
				AddLabel(tmp);
			}
		}
		
		//
		// 登录Menu命令
		//
		public function MenuCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in menu command)");
				return;
			}
			var value_addr:int = FindValue(p);
			
			CommandBuffer.WriteCommand(ScriptType.MENU_INIT_CMD, command_buffer);
			
			var str:String;
			for (var no:int = 0; (str = reader.GetString()) != null; no++)
			{
				if (DEBUG_MENU)
					trace("-->menu:", str, "length=", str.length);
				if (str.toLowerCase() == "end")
					break;
				var ip:MenuItemCommand = CommandBuffer.NewCommand(ScriptType.MENU_ITEM_CMD) as MenuItemCommand;
				ip.label_len = ip.AddMessage(str, 255);
				ip.number = no + 1;
				CommandBuffer.WriteCommand(ScriptType.MENU_ITEM_CMD, command_buffer);
			}
			var op:MenuCommand = CommandBuffer.NewCommand(ScriptType.MENU_CMD) as MenuCommand;
			op.value_addr = value_addr;
			CommandBuffer.WriteCommand(ScriptType.MENU_CMD, command_buffer);
		}
		
		//
		// 登录load命令
		//
		public function LoadCmd(lexer:Lexer):void
		{
			var p1:String = lexer.GetString();
			var p2:String = lexer.GetString();
			
			if (p1 == null || p2 == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in load command)");
				return;
			}
			
			var cp:LoadCommand = CommandBuffer.NewCommand(ScriptType.LOAD_CMD) as LoadCommand;
			cp.flag = GetPosition(p1);
			cp.path_len = cp.AddMessage(p2, 255);
			CommandBuffer.WriteCommand(ScriptType.LOAD_CMD, command_buffer);
		}
		
		//
		// 登录update命令
		//
		public function UpdateCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in update command)");
				return;
			}
			
			var cp:UpdateCommand = CommandBuffer.NewCommand(ScriptType.UPDATE_CMD) as UpdateCommand;
			cp.flag = GetUpdateType(p);
			CommandBuffer.WriteCommand(ScriptType.UPDATE_CMD, command_buffer);
		}
		
		//
		// 登录clear命令
		//
		public function ClearCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in clear command)");
				return;
			}
			
			// clear text分别对待
			if (p.toLowerCase() == "text")
			{
				CommandBuffer.WriteCommand(ScriptType.CLEAR_TEXT_CMD, command_buffer);
			}
			else
			{
				var cp:ClearCommand = CommandBuffer.NewCommand(ScriptType.CLEAR_CMD) as ClearCommand;
				cp.pos = GetPosition(p);
				CommandBuffer.WriteCommand(ScriptType.CLEAR_CMD, command_buffer);
			}
		}
		
		//
		// 登录music命令
		//
		public function MusicCmd(lexer:Lexer):void
		{
			//int value;
			//bool isval;
			var value:Number = lexer.GetValue();
			
			if (isNaN(value) || value <= 0 || lexer.GetString() != null)
			{
				NormalError("syntax error (in music command)");
				return;
			}
			var cp:MusicCommand = CommandBuffer.NewCommand(ScriptType.MUSIC_CMD) as MusicCommand;
			cp.number = value;
			CommandBuffer.WriteCommand(ScriptType.MUSIC_CMD, command_buffer);
		}
		
		//
		// 登录sound命令
		//
		public function SoundCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in sound command)");
				return;
			}
			var cp:SoundCommand = CommandBuffer.NewCommand(ScriptType.SOUND_CMD) as SoundCommand;
			cp.path_len = cp.AddMessage(p, 255);
			CommandBuffer.WriteCommand(ScriptType.SOUND_CMD, command_buffer);
		}
		
		//
		// 登录exec命令
		//
		public function ExecCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error (in exec command)");
				return;
			}
			var cp:ExecCommand = CommandBuffer.NewCommand(ScriptType.EXEC_CMD) as ExecCommand;
			cp.path_len = cp.AddMessage(p, 255);
			CommandBuffer.WriteCommand(ScriptType.EXEC_CMD, command_buffer);
		}
		
		//
		// 登录wait命令
		//
		public function WaitCmd(lexer:Lexer):void
		{
			//var value:int;
			//var isval:Boolean = 
			var value:Number = lexer.GetValue();
			
			if (isNaN(value) || value <= 0 || lexer.GetString() != null)
			{
				NormalError("syntax error (in wait command)");
				return;
			}
			var cp:SleepCommand = CommandBuffer.NewCommand(ScriptType.SLEEP_CMD) as SleepCommand;
			cp.time = value;
			CommandBuffer.WriteCommand(ScriptType.SLEEP_CMD, command_buffer);
		}
		
		//
		// 检查文字的尾端
		//
		public function ChkTermination(str:String):Boolean
		{
			return str.substr(0, 1) == '.';
		}
		
		//
		// 登录text命令
		//
		public function TextCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error (in text command)");
				return;
			}
			
			var cp:TextCommand = CommandBuffer.NewCommand(ScriptType.TEXT_CMD) as TextCommand;
			
			var work:String = "";
			
			for (var i:int = 0; ; i++)
			{
				var str:String;
				if ((str = reader.GetString()) == null)
				{
					NormalError("syntax error (text syntax)");
					break;
				}
				
				if (ChkTermination(str))
					break;
				
				work += str;
				work += '\n';
				if (i >= MAX_TEXTLINE)
				{
					NormalError("text line overflow");
					break;
				}
			}
			cp.msg_len = cp.AddMessage(work, 255);
			CommandBuffer.WriteCommand(ScriptType.TEXT_CMD, command_buffer);
		}
		
		//
		// 登录mode命令
		//
		public function ModeCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			if (p.toLowerCase() == "system")
			{
				var cp1:ModeCommand = CommandBuffer.NewCommand(ScriptType.MODE_CMD) as ModeCommand;
				cp1.mode = ScriptType.MODE_SYSTEM;
				CommandBuffer.WriteCommand(ScriptType.MODE_CMD, command_buffer);
			}
			else if (p.toLowerCase() == "scenario")
			{
				var cp2:ModeCommand = CommandBuffer.NewCommand(ScriptType.MODE_CMD) as ModeCommand;
				cp2.mode = ScriptType.MODE_SCENARIO;
				CommandBuffer.WriteCommand(ScriptType.MODE_CMD, command_buffer);
			}
			else
			{
				NormalError("syntax error");
			}
		}
		
		//
		// 登录system命令
		//
		public function SystemCmd(lexer:Lexer):void
		{
			var p:String = lexer.GetString();
			if (p == null || lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			if (p.toLowerCase() == "load")
			{
				CommandBuffer.WriteCommand(ScriptType.SYS_LOAD_CMD, command_buffer);
			}
			else if (p.toLowerCase() == "exit")
			{
				CommandBuffer.WriteCommand(ScriptType.SYS_EXIT_CMD, command_buffer);
			}
			else if (p.toLowerCase() == "clear")
			{
				CommandBuffer.WriteCommand(ScriptType.SYS_EXIT_CMD, command_buffer);
			}
			else
			{
				NormalError("syntax error");
			}
		}
		
		//
		// 登录stopm命令
		//
		public function StopmCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.STOPM_CMD, command_buffer);
		}
		
		//
		// 登录fadein命令
		//
		public function FadeInCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.FADEIN_CMD, command_buffer);
		}
		
		//
		// 登录fadeout命令
		//
		public function FadeOutCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.FADEOUT_CMD, command_buffer);
		}
		
		//
		// 登录wipein命令
		//
		public function WipeInCmd(lexer:Lexer):void
		{
			//var value:int;
			//var isval:Boolean
			var value:Number = lexer.GetValue();
			
			if (isNaN(value) || value <= 0 || value > 2 || lexer.GetString() != null)
			{
				NormalError("syntax error (in wipein command)");
				return;
			}
			var cp:WipeinCommand = CommandBuffer.NewCommand(ScriptType.WIPEIN_CMD) as WipeinCommand;
			cp.pattern = value;
			CommandBuffer.WriteCommand(ScriptType.WIPEIN_CMD, command_buffer);
		}
		
		//
		// 登录wipeout命令
		//
		public function WipeOutCmd(lexer:Lexer):void
		{
			var value:Number = lexer.GetValue();
			
			if (isNaN(value) || value <= 0 || value > 2 || lexer.GetString() != null)
			{
				NormalError("syntax error (in wipeout command)");
				return;
			}
			var cp:WipeoutCommand = CommandBuffer.NewCommand(ScriptType.WIPEOUT_CMD) as WipeoutCommand;
			cp.pattern = value;
			CommandBuffer.WriteCommand(ScriptType.WIPEOUT_CMD, command_buffer);
		}
		
		//
		// 登录cutin命令
		//
		public function CutInCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.CUTIN_CMD, command_buffer);
		}
		
		//
		// 登录cutout命令
		//
		public function CutOutCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.CUTOUT_CMD, command_buffer);
		}
		
		//
		// 登录whitein命令
		//
		public function WhiteInCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.WHITEIN_CMD, command_buffer);
		}
		
		//
		// 登录whiteout命令
		//
		public function WhiteOutCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.WHITEOUT_CMD, command_buffer);
		}
		
		//
		// 登录flash命令
		//
		public function FlashCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.FLASH_CMD, command_buffer);
		}
		
		//
		// 登录shake命令
		//
		public function ShakeCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.SHAKE_CMD, command_buffer);
		}
		
		//
		// 登录end命令
		//
		public function EndCmd(lexer:Lexer):void
		{
			if (lexer.GetString() != null)
			{
				NormalError("syntax error");
				return;
			}
			CommandBuffer.WriteCommand(ScriptType.END_CMD, command_buffer);
		}
		
		//
		// 分析脚本的命令
		//
		public function ParseCommand(lexer:Lexer):Function
		{
			var command:String = lexer.GetString(0);
			
			var p:Function = cmd_table[command];
			if (p != null)
				return p;
			
			// 是否为 set, calc 的省略形式
			if (lexer.NumToken() >= 3)
			{
				var p2:String = lexer.GetString(1);
				// 卷回前面
				lexer.GetType(0);
				if (p2 == "+" || p2 == "-" || p2 == "=")
				{
					return SetCmd;
				}
			}
			NormalError("syntax error (command syntax)");
			return null;
		}
		
		//
		// 单行分析
		//
		public function ParserString(str:String):void
		{
			var lexer:Lexer = new Lexer(str);
			
			if (lexer.NumToken() == 0)
				return;
			
			var type:String = lexer.GetType();
			
			if (type == Lexer.IsLabel)
			{
				SetLabel(lexer);
			}
			else
			{
				var commandFunc:Function = ParseCommand(lexer);
				if (commandFunc != null)
				{
					commandFunc.apply(this, [lexer]);
				}
			}
		}
		
		//
		// 读取脚本原始档并转换
		//
		public function ReadScript(name:String):int
		{
			var Reader:FileReader = new FileReader(name);
			
			if (!Reader)
			{
				ErrorMessage("file " + name + " can't open.");
				return 1;
			}
			
			reader = Reader;
			
			try
			{
				OpenValueTable();
				var str:String;
				while ((str = reader.GetString()) != null)
				{
					ParserString(str);
				}
				CommandBuffer.WriteCommand(ScriptType.END_CMD, command_buffer);
				
				LabelCheck();
				
				if (nerror != 0)
					Notice("I have " + nerror + " error" + (nerror == 1 ? "" : "s") + " found.");
				
				if (nerror == 0 && add_value)
					CloseValueTable();
			}
			catch (error:Error)
			{
				//TODO:这里可能还要检查序列化内存是否足够
				FatalError(error.message);
				trace(error.getStackTrace());
			}
			
			return nerror;
		}
		
		/**
		 * 存储脚本文件
		 * @param	name
		 * @return
		 */
		public function WriteScript(name:String):int
		{
			//TODO:
			/*
			   FILE *fp;
			
			   if ((fp = fopen(name, "wb")) == NULL) {
			   ErrorMessage("can't create %s.", name);
			   return -1;
			   }
			
			   int		error = 0;
			   if (fwrite(SCRIPT_MAGIC, sizeof(char), 8, fp) != 8
			   || fwrite(&ncommand, sizeof(long), 1, fp) != 1
			   || fwrite(command_buffer, sizeof(char), ncommand, fp) != (unsigned)ncommand) {
			   ErrorMessage("write error in %s.", name);
			   error = 1;
			   }
			   else {
			   Notice("command %d bytes use", ncommand);
			   }
			   fclose(fp);
			
			   return error;
			 */
			return -1;
		}
		
		private function FmtThenLabel(i:uint):String
		{
			if (DEBUG_FMT_THEN_LABEL)
			{
				if (i == 0xFFFF)
				{
					try
					{
						throw new Error();
					}
					catch (e:Error)
					{
						trace(e.getStackTrace());
					}
				}
			}
			var str:String = i.toString(16);
			var zero:String = "";
			if (str.length < 8)
			{
				for (var n:int = 0; n < 8 - str.length; n++)
				{
					zero += "0";
				}
			}
			
			if (DEBUG_FMT_ENDIF)
				trace("#endif#" + zero + str);
			
			return "#endif#" + zero + str;
		}
		
		/**
		 * 回填地址值到特殊位置，
		 * ByteArray支持随机写入（即使地址超过现在的位置）
		 * 而且必须保证这个值不会被新的块所覆盖（常规写入必须跳过这些特殊位置）
		 * @param	pos 要写入的位置(不是块头，而是已经换算好的偏移位置）
		 * @param	value 要跳转的二进制块头
		 */
		private function WriteIntByAddress(pos:uint, value:int):void
		{
			var oldpos:uint = command_buffer.position;
			command_buffer.position = pos;
			command_buffer.writeInt(value);
			command_buffer.position = oldpos;
		}
		
		/**
		 * 创建一个命令缓冲的副本，加入一些附加信息
		 * @return
		 */
		public function duplicateBuffer():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			//头部魔法数，填充到8字节
			bytes.writeMultiByte(ScriptType.SCRIPT_MAGIC, "gbk");
			for (var i:int = 0; i < 8 - ScriptType.SCRIPT_MAGIC.length; ++i)
				bytes.writeByte(0);
			trace("header magic == ", ScriptType.SCRIPT_MAGIC);
			
			var oldpos:uint = command_buffer.position;
			command_buffer.position = 0;
			//4字节的数据块长度
			bytes.writeInt(command_buffer.bytesAvailable);
			trace("header ncommand == ", command_buffer.bytesAvailable);
			
			//数据块
			bytes.writeBytes(command_buffer);
			bytes.position = 0;
			command_buffer.position = oldpos;
			return bytes;
		}
		
		public function dumpBuffer():void
		{
			var bytes:ByteArray = duplicateBuffer();
			var num:int = bytes.bytesAvailable;
			trace("dumpBuffer: " + num);
			var str:String = "";
			if (num > 0)
			{
				for (var i:int = 0; i < num; i++)
				{
					var value:uint = bytes.readByte() & 0xFF;
					if (i % 16 == 0)
					{
						var address:String = i.toString(16);
						for (var k:int = 0; k < 8 - address.length; k++)
							str += "0";
						str += address + ":";
					}
					if (value >= 16)
						str += value.toString(16) + " ";
					else
						str += "0" + value.toString(16) + " ";
					if (i % 16 == 15)
					{
						str += '\n';
					}
				}
			}
			trace(str);
		}
		
		public function uploadBuffer():void
		{
			if (socket.connected)
				return;
			
			try
			{
				socket.connect("127.0.0.1", 8888);
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		
		private function onSocketConnect(event:Event):void
		{
			var bytes:ByteArray = duplicateBuffer();
			if (bytes.bytesAvailable > 0)
			{
				//trace("send:" + bytes.bytesAvailable);
				socket.writeBytes(bytes);
				//socket.writeMultiByte("HELLO", "gbk");
				socket.flush();
			}
		}
		
		private function onSocketClose(event:Event = null):void
		{
			socket.close();
		}
		
		private function onSecrityError(event:SecurityErrorEvent):void
		{
			//trace(event.text);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace(event.text);
		}
	}
}