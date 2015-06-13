/**
 * 参数
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import com.iteye.weimingtom.marika.mkscript.ScriptType;
	
	/**
	 * 游戏参数类
	 */
	public class CParams
	{
		public static const PARAMS_MAX_SAVE:uint = 10;
		public static const PARAMS_MAX_VALUES:uint = CConfig.MAX_VALUES;
		
		public static const SHOWCG_BLACKNESS:int = 0;
		public static const SHOWCG_IMAGE:int = 1;
		public static const SHOWCG_WHITENESS:int = 2;
		
		public var save_month:uint = 0;
		public var save_date:uint = 0;
		public var save_hour:uint = 0;
		public var save_minute:uint = 0;
		public var script_pos:uint = 0;
		public var last_script:String = "";
		public var last_bg:String = "";
		public var last_center:String = "";
		public var last_left:String = "";
		public var last_right:String = "";
		public var last_overlap:String = "";
		public var last_bgm:uint = 0;
		public var show_flag:uint = 0;
		public var value_tab:Array = new Array(PARAMS_MAX_VALUES);
		
		public function CParams()
		{
		
		}
		
		public function Clear():void
		{
			save_month = 0;
			save_date = 0;
			save_hour = 0;
			save_minute = 0;
			script_pos = 0;
			last_script = "";
			last_bg = "";
			last_center = "";
			last_left = "";
			last_right = "";
			last_overlap = "";
			last_bgm = 0;
			show_flag = 0;
			for (var i:int = 0; i < PARAMS_MAX_VALUES; ++i)
			{
				value_tab[i] = 0;
			}
		}
		
		public function Load(no:int):Boolean
		{
			//TODO:
			return false;
		}
		
		public function Save(no:int):Boolean
		{
			//TODO:
			return false;
		}
		
		/**
		 * 消去背景CG
		 */
		public function ClearBackCG():void
		{
			last_bg = "";
		}
		
		/**
		 * 消去左侧重叠CG
		 */
		public function ClearLeftCG():void
		{
			last_left = "";
			last_center = "";
			last_overlap = "";
		}
		
		/**
		 * 消去右侧重叠CG
		 */
		public function ClearRightCG():void
		{
			last_right = "";
			last_center = "";
			last_overlap = "";
		}
		
		/**
		 * 消去中间重叠CG
		 */
		public function ClearCenterCG():void
		{
			last_left = "";
			last_right = "";
			last_center = "";
			last_overlap = "";
		}
		
		/**
		 * 消去重叠CG
		 */
		public function ClearOverlapCG():void
		{
			last_left = "";
			last_right = "";
			last_center = "";
			last_overlap = "";
		}
		
		/**
		 * 设定背景CG
		 * @param	file
		 */
		public function SetBackCG(file:String):void
		{
			last_bg = file;
		}
		
		/**
		 * 设定左侧重叠CG
		 * @param	file
		 */
		public function SetLeftCG(file:String):void
		{
			last_center = "";
			last_overlap = "";
			last_left = file;
		}
		
		/**
		 * 设定右侧重叠CG
		 * @param	file
		 */
		public function SetRightCG(file:String):void
		{
			last_center = "";
			last_overlap = "";
			last_right = file;
		}
		
		/**
		 * 设定中间重叠CG
		 * @param	file
		 */
		public function SetCenterCG(file:String):void
		{
			ClearOverlapCG();
			last_center = file;
		}
		
		/**
		 * 设定重叠CG
		 * @param	file
		 */
		public function SetOverlapCG(file:String):void
		{
			ClearOverlapCG();
			last_overlap = file;
		}
		
		/**
		 * 设定显示旗标
		 */
		public function SetShowFlag():void
		{
			show_flag = SHOWCG_IMAGE;
		}
		
		/**
		 * 消去显示旗标
		 * @param	white
		 */
		public function ResetShowFlag(white:Boolean = false):void
		{
			show_flag = white ? SHOWCG_WHITENESS : SHOWCG_BLACKNESS;
		}
	}
}