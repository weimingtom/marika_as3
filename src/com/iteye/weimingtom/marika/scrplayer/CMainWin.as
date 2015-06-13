/**
 * Script player主窗口(MainWindow)
 * Copyright (c) 2000-2002 Chihiro.SAKAMOTO (HyperWorks)
 */

package com.iteye.weimingtom.marika.scrplayer
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.utils.getTimer;
	
	import com.iteye.weimingtom.marika.mkscript.ScriptType;
	
	/**
	 * 主窗口类
	 *
	 * (已修正 -> ) FIXME：由于不能局部重画，所以改为全部重画
	 * 真正的绘画在Mixing中
	 * 凡是局部绘画出现问题，可以用Update的方法暂时解决
	 * (或者CopyAndRepaint(CMainWin.Position[CMainWin.Both]);)
	 *
	 *
	 *
	 * @see Update()
	 * @see Mixing()
	 *
	 * FIXME: 真正的消息分发在CWindow中
	 * AS3版直接用监听器实现
	 *
	 *
	 * TODO:
	 * 		对话框警告
	 */
	public class CMainWin extends CWindow
	{
		//FIXME: (已经过时了->) 暂时的方法，解决重画问题
		//NOTE: 这个bug已经修正，应该设置为true, 仅用于记录
		private static const NO_FIX_UPDATE_BUG:Boolean = true;
		
		// 常数
		
		// 动作
		public static const ActionNop:int = 0;
		public static const ActionScriptDone:int = 1;
		public static const ActionScriptSetup:int = 2;
		public static const ActionScript:int = 3;
		public static const ActionGameLoad:int = 4;
		public static const ActionGameSave:int = 5;
		
		// 音乐模式
		public static const MusicCD:int = 0;
		public static const MusicOff:int = 1;
		
		// 计时器ID
		public static const TimerSleep:int = 0;
		
		// 待机中的事件旗标
		public static const IS_TIMEDOUT:int = (1 << 0);
		
		// 项目的最大值
		public static const MAX_MENU_ITEM:uint = 8;
		public static const MAX_MENU_TEXT:uint = 60;
		public static const MAX_SAVE_TEXT:uint = 62;
		
		// 重叠的显示位置
		protected static const None:int = 0;
		protected static const Left:int = 1;
		protected static const Right:int = 2;
		protected static const Both:int = 3;
		protected static const Center:int = 4;
		
		// 消息的显示位置
		protected static const MSG_W:int = CConfig.MessageFont * CConfig.MessageWidth / 2 + 20;
		protected static const MSG_H:int = (CConfig.MessageFont + 2) * CConfig.MessageLine + 14;
		protected static const MSG_X:int = (CConfig.WindowWidth - MSG_W) / 2;
		protected static const MSG_Y:int = CConfig.WindowHeight - MSG_H - 8;
		protected static const MSG_TEXTOFFSET_X:int = MSG_X + 10;
		protected static const MSG_TEXTOFFSET_Y:int = MSG_Y + 7;
		protected static const MSG_TEXTSPACE_Y:int = 2;
		protected static const WAITMARK_X:int = CConfig.MessageWidth - 2;
		protected static const WAITMARK_Y:int = CConfig.MessageLine - 1;
		
		// 菜单的显示位置
		protected static const MENU_X:int = 20;
		protected static const MENU_Y:int = MSG_Y - 2; // 与消息区域不重叠
		protected static const MENU_WIDTH:int = (MAX_MENU_TEXT + 2) * CConfig.MessageFont / 2;
		protected static const MENU_HEIGHT:int = (MAX_MENU_ITEM + 1) * CConfig.MessageFont;
		protected static const MENU_MIN_WIDTH:int = 80; //FIXME: 这里调节菜单宽度
		protected static const MENU_FRAME_WIDTH:int = 10;
		protected static const MENU_FRAME_HEIGHT:int = 10;
		protected static const MENU_ITEM_SPACE:int = 2;
		protected static const MENU_ITEM_HEIGHT:int = CConfig.MessageFont + MENU_ITEM_SPACE;
		
		// 装入·存储菜单项目的显示位置
		protected static const SAVE_ITEM_HEIGHT:int = 32;
		protected static const SAVE_ITEM_SPACE:int = 4;
		protected static const SAVE_ITEM_INTERVAL:int = SAVE_ITEM_HEIGHT + SAVE_ITEM_SPACE;
		protected static const SAVE_W:int = 400;
		protected static const SAVE_H:int = SAVE_ITEM_INTERVAL * CParams.PARAMS_MAX_SAVE + SAVE_ITEM_HEIGHT;
		protected static const SAVE_X:int = (CConfig.WindowWidth - SAVE_W) / 2;
		protected static const SAVE_Y:int = (CConfig.WindowHeight - SAVE_H) / 2;
		protected static const SAVE_TEXT_OFFSET_X:int = SAVE_X + 10;
		protected static const SAVE_TEXT_OFFSET_Y:int = SAVE_Y + 8;
		protected static const SAVE_TITLE_WIDTH:int = 72;
		
		// 画面合成项目
		protected static const TextMessage:int = 1 << 0;
		protected static const TextWaitMark:int = 1 << 1;
		protected static const MenuFrame:int = 1 << 2;
		protected static const SaveTitle:int = 1 << 3;
		
		protected static const MenuItemFirst:int = 4;
		protected static const SaveItemFirst:int = 12;
		
		protected static function MenuItem(n:int):uint
		{
			return 1 << (MenuItemFirst + n);
		}
		
		protected static function SaveItem(n:int):uint
		{
			return 1 << (SaveItemFirst + n);
		}
		
		protected var hFont:CFont = new CFont(); // 文字的字型
		protected var MusicMode:int; // BGM的演奏模式
		
		protected var music:CMci; // BGM演奏的装置
		protected var cdaudio:CDAudio = new CDAudio(); // CD-DA演奏的类
		protected var MusicNo:int; // 演奏的曲目编号
		protected var wave:WaveOut = new WaveOut(); // 播放Wave
		
		protected var LoadParam:CParams = new CParams(); // “Load”带出的参数
		
		protected var Action:CAction; // 现在选择的动作集
		protected var NopAction:CAction = new CAction(); // 什么都不做的动作集
		protected var ScriptAction:CScriptAction = new CScriptAction(); // 执行脚本时所用的动作集
		protected var GameLoadAction:CGameLoadAction = new CGameLoadAction(); // 游戏装入动作 
		protected var GameSaveAction:CGameSaveAction = new CGameSaveAction(); // 游戏存储动作
		
		protected var ViewImage:CDrawImage = new CDrawImage(); // 显示
		protected var MixedImage:CDrawImage = new CDrawImage(); // 合成结果
		protected var BackLayer:CImage = new CImage(); // 背景
		protected var OverlapLayer:CImage = new CImage(); // 重叠
		protected var OverlapFlags:uint; // 重叠的状态旗标
		protected var TextDisplay:Boolean; // 文字显示旗标
		protected var WaitMarkShowing:Boolean; // 显示等待键盘输入的符号
		
		protected var InvalidRect:Rectangle = new Rectangle(0, 0, 0, 0); // 无效区域
		protected var TextRect:Rectangle = new Rectangle(MSG_X, MSG_Y, MSG_W, MSG_H); // 文字显示区域
		protected var WaitMarkRect:Rectangle = new Rectangle(MsgX(WAITMARK_X), MsgY(WAITMARK_Y), 
		//	MsgX(WAITMARK_X) + CConfig.MessageFont, MsgY(WAITMARK_Y) + CConfig.MessageFont); // 等待键盘输入符号显示区域
		CConfig.MessageFont, CConfig.MessageFont); // 等待键盘输入符号显示区域
		protected var MenuRect:Rectangle = new Rectangle(); // 菜单显示区域
		protected var OverlapBounds:Rectangle = new Rectangle(); // 重叠的有效区域
		protected var BackShow:Boolean; // 显示哪个背景?
		protected var OverlapShow:Boolean; // 显示哪个重叠?
		protected var TextShow:Boolean; // 文字显示旗标
		protected var MenuShow:Boolean; // 菜单显示旗标
		protected var SaveShow:Boolean; // 读取装入/存档的显示
		protected var SaveRect:Rectangle = new Rectangle(SAVE_X, SAVE_Y, SAVE_W, SAVE_H); // 读取装入/存档的区域
		protected var BgColor:uint; // 当没有背景时填入的色彩
		
		protected var ViewEffect:CViewEffect; // 特效
		protected var TimePeriod:uint; // 计时器
		
		//char MsgBuffer[MessageLine][MessageWidth + 1];
		protected var MsgBuffer:Array = new Array(CConfig.MessageLine);
		
		protected var CurX:int;
		protected var CurY:int;
		
		protected var MenuBuffer:Array = new Array(CMainWin.MAX_MENU_ITEM); //CMenuItem[MAX_MENU_ITEM];
		protected var MenuCount:int;
		
		protected var IsSaveMenu:Boolean;
		protected var DataTitle:Array = new Array(CParams.PARAMS_MAX_SAVE); //CDataTitle[PARAMS_MAX_SAVE];
		
		protected static const Position:Array = [new Rectangle(0, 0, 0, 0), // None
		new Rectangle(0, 0, CConfig.WindowWidth / 2, CConfig.WindowHeight), // Left
		new Rectangle(CConfig.WindowWidth / 2, 0, CConfig.WindowWidth / 2, CConfig.WindowHeight), // Right
		new Rectangle(0, 0, CConfig.WindowWidth, CConfig.WindowHeight), // Both
		new Rectangle(CConfig.WindowWidth / 4, 0, CConfig.WindowWidth / 2, CConfig.WindowHeight), // Center
		];
		
		/**
		 * CClientDC(this)
		 * @return
		 */
		public function getClientDC():Graphics
		{
			trace("getClientDC()", this.graphics);
			return this.graphics;
		}
		
		/**
		 * 显示内存上的图像
		 * @param	rect
		 */
		public function Repaint(rect:Rectangle):void
		{
			//ViewImage.Draw(CClientDC(this), rect);
			ViewImage.Draw3(getClientDC(), rect);
		}
		
		/**
		 * 合成用イメージから、表示用イメージに複写して表示する
		 * @param	rect
		 */
		public function CopyAndRepaint(rect:Rectangle):void
		{
			//FIXME:
			//var allRactangle:Rectangle = new Rectangle(0, 240, 640, 480);
			trace("CMainWin::CopyAndRepaint rect == ", rect.x, rect.y, rect.width, rect.height);
			ViewImage.Copy(MixedImage, rect);
			if (NO_FIX_UPDATE_BUG)
			{
				Repaint( /*allRactangle*/rect);
			}
		/*
		   else
		   {
		   Repaint(CMainWin.Position[CMainWin.Both]);
		   }
		 */
		}
		
		/**
		 * 从鼠标光标取得菜单项目
		 * @param	point
		 * @return
		 */
		public function GetMenuSelect(point:Point):int
		{
			if (point.x < MenuRect.left + MENU_FRAME_WIDTH || point.y < MenuRect.top + MENU_FRAME_HEIGHT || point.x >= MenuRect.right - MENU_FRAME_WIDTH || point.y >= MenuRect.bottom - MENU_FRAME_HEIGHT)
				return -1;
			return (point.y - MenuRect.top - MENU_FRAME_WIDTH) / MENU_ITEM_HEIGHT;
		}
		
		/**
		 * 转入
		 * @param	rect
		 * @param	pattern
		 */
		public function WipeIn(rect:Rectangle, pattern:int = 1):void
		{
			//FIXME，Update可能修改rect
			var rect2:Rectangle = rect.clone();
			Update(false);
			switch (pattern)
			{
				case 1: 
					ViewEffect = new EffectWipeIn(this, ViewImage, MixedImage, rect2);
					break;
				
				default: 
					ViewEffect = new EffectWipeIn2(this, ViewImage, MixedImage, rect2);
					break;
			}
		}
		
		/**
		 * 转入
		 * @param	pattern
		 */
		public function WipeIn2(pattern:int = 1):void
		{
			WipeIn(new Rectangle(0, 0, CConfig.WindowWidth, CConfig.WindowHeight), pattern);
		}
		
		/**
		 * 转出
		 * @param	pattern
		 */
		public function WipeOut(pattern:int):void
		{
			HideMessageWindow();
			switch (pattern)
			{
				case 1: 
					ViewEffect = new EffectWipeOut(this, ViewImage, MixedImage);
					break;
				
				default: 
					ViewEffect = new EffectWipeOut2(this, ViewImage, MixedImage);
					break;
			}
			HideAllLayer(CMisc.BlackPixel);
		}
		
		/**
		 * 淡入
		 */
		public function FadeIn():void
		{
			Update(false);
			ViewEffect = new EffectFadeIn(this, ViewImage, MixedImage);
		}
		
		/**
		 * 淡出
		 */
		public function FadeOut():void
		{
			HideMessageWindow();
			ViewEffect = new EffectFadeOut(this, ViewImage, MixedImage);
			HideAllLayer(CMisc.BlackPixel);
		}
		
		/**
		 * 切入
		 * @param	rect
		 */
		public function CutIn(rect:Rectangle):void
		{
			//FIXME：这里Update(false)可能会修改rect的值，所以复制一个新的
			var rect2:Rectangle = rect.clone();
			Update(false);
			CopyAndRepaint(rect2);
		}
		
		/**
		 * 切入
		 */
		public function CutIn2():void
		{
			CutIn(new Rectangle(0, 0, CConfig.WindowWidth, CConfig.WindowHeight));
		}
		
		/**
		 * 切出
		 * @param	white
		 */
		public function CutOut(white:Boolean):void
		{
			HideMessageWindow();
			HideAllLayer(white ? CMisc.WhitePixel : CMisc.BlackPixel);
			Invalidate(Position[Both]);
			Update();
		}
		
		/**
		 * 白进
		 */
		public function WhiteIn():void
		{
			Update(false);
			ViewEffect = new EffectWhiteIn(this, ViewImage, MixedImage);
		}
		
		/**
		 * 白出
		 */
		public function WhiteOut():void
		{
			HideMessageWindow();
			ViewEffect = new EffectWhiteOut(this, ViewImage, MixedImage);
			HideAllLayer(CMisc.WhitePixel);
		}
		
		/**
		 * 淡化合成
		 * @param	rect
		 */
		public function MixFade(rect:Rectangle):void
		{
			//FIXME: Update(false)可能修改了rect的值
			var rect2:Rectangle = rect.clone();
			Update(false);
			ViewEffect = new EffectMixFade(this, ViewImage, MixedImage, rect2);
		}
		
		/**
		 * 摇晃
		 */
		public function Shake():void
		{
			ViewEffect = new EffectShake(this, ViewImage);
		}
		
		/**
		 * 闪动
		 */
		public function Flash():void
		{
			ViewEffect = new EffectFlash(this, ViewImage);
		}
		
		/**
		 * 停止特效
		 */
		public function StopWipe():void
		{
			//FIXME:
			//delete ViewEffect;
			ViewEffect = null;
		}
		
		/**
		 * 可以读取装入吗?
		 * @return
		 */
		public function IsLoadOK():Boolean
		{
			return Action.IsScriptRunning() && ScriptAction.IsSaveLoadOK();
		}
		
		/**
		 * 可以读取存储吗?
		 * @return
		 */
		public function IsSaveOK():Boolean
		{
			return Action.IsScriptRunning() && ScriptAction.IsSaveLoadOK();
		}
		
		/**
		 *
		 */
		public function CMainWin()
		{
			CurX = CurY = 0;
			OverlapFlags = 0;
			BgColor = CMisc.BlackPixel;
			TextDisplay = false;
			WaitMarkShowing = false;
			
			OverlapBounds.setEmpty();
			BackShow = false;
			OverlapShow = false;
			TextShow = false;
			MenuShow = false;
			SaveShow = false;
			
			Action = NopAction;
			hFont = null;
			
			// 时间到即播放CD
			// 若没有CD则在Open时设成Off
			MusicMode = MusicCD;
			music = cdaudio;
			MusicNo = 0;
			
			//FIXME:设置时钟的最小单位
			/*
			   TIMECAPS timeCaps;
			   timeGetDevCaps(&timeCaps, sizeof(timeCaps));
			   TimePeriod = max(timeCaps.wPeriodMin, 1U);
			   timeBeginPeriod(TimePeriod);
			 */
			
			ViewEffect = null;
			
			//addWindowEventListener();
			
			//FIXME：实体化MenuBuffer成员
			for (var i:int = 0; i < MenuBuffer.length; i++)
			{
				MenuBuffer[i] = new CMenuItem();
			}
		}
		
		//FIXME:
		//
		// 析构函数
		//
		/*
		   CMainWin::~CMainWin()
		   {
		   timeEndPeriod(TimePeriod);
		
		   if (hFont) {
		   DeleteObject(hFont);
		   hFont = 0;
		   }
		   }
		 */
		
		//
		// 窗口制作的前置处理
		//
		// 指定样式与大小
		//
		/*
		   BOOL CMainWin::PreCreateWindow(CREATESTRUCT &cs)
		   {
		   cs.dwExStyle = WS_EX_CLIENTEDGE;
		   cs.style = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX;
		
		   CRect	rect(0, 0, WindowWidth, WindowHeight);
		   ::AdjustWindowRectEx(&rect, cs.style, TRUE, cs.dwExStyle);
		
		   int width = rect.Width();
		   int height = rect.Height();
		
		   CRect rcArea;
		   SystemParametersInfo(SPI_GETWORKAREA, NULL, &rcArea, NULL);
		
		   int	x = rcArea.left + (rcArea.Width() - width) / 2;
		   int	y = rcArea.top + (rcArea.Height() - height) / 2;
		
		   cs.x = x;
		   cs.y = y;
		   cs.cx = width;
		   cs.cy = height;
		   cs.lpszClass = "MainWindow";
		
		   if (!Application->RegisterWndClass(cs.lpszClass,
		   CS_VREDRAW | CS_HREDRAW | CS_OWNDC, LoadCursor(NULL, IDC_ARROW),
		   (HBRUSH)::GetStockObject(BLACK_BRUSH), Application->LoadIcon(IDC_APPICON)))
		   return FALSE;
		   return TRUE;
		   }
		 */
		
		/**
		 *
		 */
		/*
		   public function addWindowEventListener():void
		   {
		   //FIXME:
		   //this.addEventListener(Event.ADDED_TO_STAGE, OnCreate);
		   //this.addEventListener(Event.REMOVED_FROM_STAGE, OnClose);
		   }
		 */
		
		//
		// 消息处理
		//
		/*
		   LRESULT CMainWin::WindowProc(UINT uMsg, WPARAM wParam, LPARAM lParam)
		   {
		   switch (uMsg) {
		   case WM_FIRSTACTION:		// 盘一个送来的消息
		   OnFirstAction();
		   break;
		
		   case WM_CLOSE:			// 关闭窗口
		   OnClose();
		   break;
		
		   case WM_ERASEBKGND:		// 删除背景
		   return FALSE;			// 什么都不做
		
		   case WM_LBUTTONDOWN:		// 按下鼠标左键
		   Action->LButtonDown(wParam, CPoint(lParam));
		   break;
		
		   case WM_LBUTTONUP:		// 放开鼠标左键
		   Action->LButtonUp(wParam, CPoint(lParam));
		   break;
		
		   case WM_RBUTTONDOWN:		// 按下鼠标右键
		   Action->RButtonDown(wParam, CPoint(lParam));
		   break;
		
		   case WM_RBUTTONUP:		// 放开鼠标右键
		   Action->RButtonUp(wParam, CPoint(lParam));
		   break;
		
		   case WM_MOUSEMOVE:		// 移动鼠标
		   Action->MouseMove(wParam, CPoint(lParam));
		   break;
		
		   case WM_KEYDOWN:			// 键盘事件
		   Action->KeyDown(wParam);
		   break;
		
		   case WM_DESTROY:			// 窗口摧毁
		   OnDestroy();
		   break;
		
		   case WM_TIMER:			// 计时器经过的时间
		   OnTimer(wParam);
		   break;
		
		   case MM_MCINOTIFY:		// MCI的消息
		   OnMciNotify(wParam, LOWORD(lParam));
		   break;
		
		   default:
		   return CWindow::WindowProc(uMsg, wParam, lParam);
		   }
		   return 0L;
		   }
		 */
		
		override public function OnLButtonUp(modKeys:uint, point:Point):void
		{
			Action.LButtonUp(modKeys, point);
		}
		
		override public function OnLButtonDown(modKeys:uint, point:Point):void
		{
			Action.LButtonDown(modKeys, point);
		}
		
		override public function OnRButtonUp(modKeys:uint, point:Point):void
		{
			Action.RButtonUp(modKeys, point);
		}
		
		override public function OnMouseMove(modKeys:uint, point:Point):void
		{
			Action.MouseMove(modKeys, point);
		}
		
		/**
		 * IDLE处理
		 * @param	count
		 * @return
		 */
		override public function OnIdle(count:int):Boolean
		{
			// 如果是特效...
			if (ViewEffect)
			{
				if (ViewEffect.Step2(getTimer() /*timeGetTime()*/)) // 执行特效1个步骤
					return true; // 继续特效
				StopWipe(); // 停止特效
				Action.WipeDone(); // 通知Action特效结束
			}
			return Action.IdleAction();
		}
		
		/**
		 *
		 * @param	i
		 */
		public function Sleep(i:int):void
		{
		
		}
		
		/**
		 * WM_CREATE的处理
		 * @param	cs
		 * @return
		 */
		/*cs:Object CREATESTRUCT*/
		//Boolean
		override public function OnCreate():Boolean
		{
			trace("CMainWin::OnCreate");
			//LoadAccelTable(IDC_APPACCEL);
			
			//CClientDC	dc(this);
			var dc:Graphics = getClientDC();
			
			//  配置图片区域
			if (!ViewImage.Create3(dc, CConfig.WindowWidth, CConfig.WindowHeight) || !MixedImage.Create3(dc, CConfig.WindowWidth, CConfig.WindowHeight) || !BackLayer.Create2(CConfig.WindowWidth, CConfig.WindowHeight) || !OverlapLayer.Create2(CConfig.WindowWidth, CConfig.WindowHeight))
			{
				MessageBox("内存无法配置。\n" + "请先关闭其他应用程序，在重新执行这个程序。");
				return false;
			}
			
			// 显示用图像的清除
			ViewImage.Clear();
			
			// 事先建立字型
			//FIXME:
			/*
			   if ((hFont = CreateFont(-MessageFont, 0, 0, 0, MessageStyle, FALSE, FALSE, FALSE,
			   GB2312_CHARSET, OUT_DEFAULT_PRECIS, CLIP_CHARACTER_PRECIS,
			   DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "宋体")) == 0) {
			   MessageBox("找不到宋体。");
			   return FALSE;
			   }
			 */
			if ((hFont = new CFont()) == null)
			{
				MessageBox("找不到宋体。");
				return false;
			}
			
			SetAction(ActionNop);
			
			//FIXME:
			// 送出盘一个消息作为开端
			/*
			   while (!PostMessage(WM_FIRSTACTION))
			   {
			   // PostMessage 当伫列满时会错误故重复送出
			   //#ifdef	_DEBUG
			   trace("PostMessage Error code = %d\n", GetLastError());
			   //#endif
			   Sleep(110);	// 重新送出消息时要稍作等待
			   }
			 */
			OnFirstAction();
			
			return true;
		}
		
		/**
		 * 开始时盘一个动作
		 */
		public function OnFirstAction():void
		{
			// 如果需要CD-DA会开启
			if (music)
			{
				if (!music.Open(this) && MusicMode == MusicCD)
				{
					MusicMode = MusicOff;
					music = null;
				}
			}
			wave.Open(this);
			StartMainMenu();
		}
		
		//::DestroyWindow(hWnd);
		/**
		 *
		 */
		public function DestroyWindow():void
		{
			//FIXME:
		}
		
		/**
		 * WM_CLOSE的处理
		 */
		public function OnClose():void
		{
			if (MessageBox2("确定要结束了吗?", CConfig.ApplicationTitle, CWindow.MB_ICONQUESTION | CWindow.MB_OKCANCEL) == CWindow.IDOK)
			{
				DestroyWindow();
			}
		}
		
		//FIXME:
		/**
		 *
		 * @return
		 */
		public function getPaintDC():Graphics
		{
			return null;
		}
		
		//FIXME:
		//dc.ps.rcPaint
		/**
		 *
		 * @return
		 */
		public function getRcPaint():Rectangle
		{
			return null;
		}
		
		/**
		 * WM_PAINT的处理(再绘制)
		 */
		override public function OnPaint():void
		{
			//CPaintDC	dc(this);
			var dc:Graphics = getPaintDC();
			ViewImage.Draw3(dc, getRcPaint());
		}
		
		/**
		 * WM_DESTROY的处理
		 */
		override public function OnDestroy():void
		{
			// もし、音楽が鳴っている場合それを止める
			// MCIの場合、アプリケーションが終了しても演奏を続けるので、
			// ウインドウが破棄されるときに強制的に止める
			if (music)
			{
				music.Stop();
				music.Close();
				music = null;
			}
			super.OnDestroy();
		}
		
		/**
		 * WM_TIMER的处理
		 * @param	id
		 */
		public function OnTimer(id:int):void
		{
			KillTimer(id);
			Action.TimedOut(id);
		}
		
		/**
		 * WM_COMMAND的处理(Menu的处理)
		 * @param	notifyCode
		 * @param	id
		 * @param	ctrl
		 */
		public function OnCommand(notifyCode:uint, id:uint, ctrl:CWindow /*:HWND*/):void
		{
		/*
		   switch (id)
		   {
		   case ID_APP_EXIT: // 结束
		   SendMessage(WM_CLOSE);
		   break;
		
		   case ID_APP_ABOUT: // 版本消息
		   CAboutDlg().DoModal(IDD_ABOUT, hWnd);
		   break;
		
		   case ID_MUSIC_CD: // BGM/ON
		   ChangeMusicMode(MusicCD);
		   break;
		
		   case ID_MUSIC_OFF: // BGM/OFF
		   ChangeMusicMode(MusicOff);
		   break;
		
		   case ID_LOADGAME: // 装入
		   if (IsLoadOK())
		   SetAction(ActionGameLoad);
		   break;
		
		   case ID_SAVEGAME: // 存储
		   if (IsSaveOK())
		   SetAction(ActionGameSave);
		   break;
		
		   case ID_STOPSCRIPT: // 中断剧情
		   if (IsSaveOK()
		   && MessageBox("您确定要停止游戏吗？", ApplicationTitle,
		   MB_ICONQUESTION|MB_OKCANCEL) == IDOK)
		   ScriptAction.Abort();
		   break;
		
		   default:
		   break;
		   }
		 */
		}
		
		/**
		 * 功能表初始化
		 */
		public function OnInitSubMenu(hMenu:Object /*HMENU*/, id:uint):void
		{
		/*
		   switch (id)
		   {
		   case ID_MUSIC_CD: // BGM/ON
		   // 核取功能表选项
		   CheckMenuItem(hMenu, id, MusicMode == MusicCD? MF_CHECKED: MF_UNCHECKED);
		   break;
		
		   case ID_MUSIC_OFF: // BGM/OFF
		   // 核取功能表选项
		   CheckMenuItem(hMenu, id, MusicMode == MusicOff? MF_CHECKED: MF_UNCHECKED);
		   break;
		
		   case ID_LOADGAME:	// 读取装入
		   // 只有可以读取时，才让选项有效
		   EnableMenuItem(hMenu, id, IsLoadOK()? MF_ENABLED: (MF_DISABLED | MF_GRAYED));
		   break;
		
		   case ID_SAVEGAME: // 存档
		   // 只有可以存档时，才让选项有效
		   EnableMenuItem(hMenu, id, IsSaveOK()? MF_ENABLED: (MF_DISABLED | MF_GRAYED));
		   break;
		
		   case ID_STOPSCRIPT: // 中断剧情
		   // 只有可以中断剧情时，才让选项有效
		   EnableMenuItem(hMenu, id, IsSaveOK()? MF_ENABLED: (MF_DISABLED | MF_GRAYED));
		   break;
		   }
		 */
		}
		
		/**
		 * MCI传来的消息
		 * 藉由这个消息获知音乐与音效播放结束
		 * @param	flag
		 * @param	id
		 */
		public function OnMciNotify(flag:uint, id:uint):void
		{
		/*
		   if (flag == MCI_NOTIFY_SUCCESSFUL)
		   {
		   if (music && music.GetId() == id)
		   {
		   Action.MusicDone(MusicNo);
		   }
		   else if (wave.GetId() == id)
		   {
		   wave.Stop();
		   Action.WaveDone();
		   }
		   }
		 */
		}
		
		/**
		 * 演奏音乐的切换
		 * @param	mode
		 */
		public function ChangeMusicMode(mode:int):void
		{
			// 如果模式有变更
			if (MusicMode != mode)
			{
				MusicMode = mode;
				// 如果还在演奏中则停止
				if (music)
				{
					music.Stop();
					music.Close();
					music = null;
				}
				switch (MusicMode)
				{
					case MusicCD: 
						music = cdaudio;
						if (!music.Open(this))
						{
							MusicMode = MusicOff;
							music = null;
						}
						break;
				}
				if (music && MusicNo > 0)
					music.Play(MusicNo); // 播放现在指定的音乐
			}
		}
		
		/**
		 * 设定动作
		 * @param	action
		 * @param	param
		 * @return
		 */
		public function SetAction(action:int, param:int = 0):Boolean
		{
			trace("CMainWin::SetAction() " + action);
			StopWipe();
			// 停止音乐演奏
			switch (action)
			{
				case ActionScriptDone: 
				case ActionScript: 
					StopMusic();
					break;
			}
			switch (action)
			{
				case ActionNop: // 什么都不做
					Action = NopAction;
					NopAction.Initialize(this);
					break;
				
				case ActionScriptDone: // 脚本结束
					StartMainMenu();
					break;
				
				case ActionScriptSetup: // 执行读取的脚本
					ScriptAction.Setup(LoadParam);
				// no break
				
				case ActionScript: // 执行脚本
					Action = ScriptAction;
					break;
				
				case ActionGameLoad: // 游戏的读取菜单
					ShowLoadSaveMenu(false);
					GameLoadAction.Initialize(this);
					Action.Pause();
					Action = GameLoadAction;
					break;
				
				case ActionGameSave: // 游戏的存档菜单
					ShowLoadSaveMenu(true);
					GameSaveAction.Initialize(this);
					Action.Pause();
					Action = GameSaveAction;
					break;
			}
			//FIXME:
			PostMessage(CConfig.WM_KICKIDLE); // 为求慎重，传递空消息
			return true;
		}
		
		/**
		 * 执行脚本
		 * @param	name
		 * @param	mode
		 * @return
		 */
		public function StartScript(name:String, mode:int):Boolean
		{
			ScriptAction.Initialize(this, mode); // 初始化
			if (!ScriptAction.Load(name)) // 读取脚本
				return false;
			SetAction(ActionScript); // 开始执行
			return true;
		}
		
		/**
		 * 主菜单
		 * 显示主菜单
		 */
		public function StartMainMenu():void
		{
			if (!StartScript("main", ScriptType.MODE_SYSTEM))
				DestroyWindow();
		}
		
		/**
		 * 显示消息
		 * @param	msg
		 */
		public function WriteMessage(msg:String):void
		{
			FormatMessage(msg);
			WaitMarkShowing = true;
			ShowMessageWindow();
		}
		
		/**
		 * 清除等待输入符号
		 */
		public function HideWaitMark():void
		{
			if (WaitMarkShowing)
			{
				WaitMarkShowing = false;
				if (TextShow)
				{
					Mixing(WaitMarkRect, TextWaitMark);
					CopyAndRepaint(WaitMarkRect);
				}
			}
		}
		
		/**
		 * 显示菜单
		 */
		public function OpenMenu():void
		{
			//FIXME:
			var maxlen:int = MENU_MIN_WIDTH;
			/*
			   {
			   CMemoryDC	memdc(0);
			   HFONT	oldFont = memdc.SelectObject(hFont);
			
			   for (var i:int = 0; i < MenuCount; i++)
			   {
			   CSize	size;
			   memdc.GetTextExtentPoint32(MenuBuffer[i].text, MenuBuffer[i].length, &size);
			   if (maxlen < size.cx)
			   maxlen = size.cx;
			   }
			   memdc.SelectObject(oldFont);
			   }
			 */
			MenuRect.top = MENU_Y - ((MENU_FRAME_HEIGHT * 2) + MenuCount * MENU_ITEM_HEIGHT - MENU_ITEM_SPACE);
			MenuRect.left = MENU_X;
			MenuRect.bottom = MENU_Y;
			MenuRect.right = MENU_X + (MENU_FRAME_WIDTH * 2) + maxlen;
			MenuShow = true;
			trace("CMainWin::OpenMenu == ", MenuRect.x, MenuRect.y, MenuRect.width, MenuRect.height);
			Mixing(MenuRect);
			if (NO_FIX_UPDATE_BUG)
			{
				CopyAndRepaint(MenuRect);
			}
		/*
		   else
		   {
		   //FIXME:暂时的方法，解决重画问题
		   CopyAndRepaint(CMainWin.Position[CMainWin.Both]);
		   }
		 */
		}
		
		/**
		 * 切换菜单是否显示
		 * @param	index
		 * @param	select
		 */
		public function SelectMenu(index:int, select:Boolean):void
		{
			if (index >= 0)
			{
				(MenuBuffer[index] as CMenuItem).color = select ? CMisc.RedPixel : CMisc.WhitePixel;
				/*
				   var r:Rectangle;
				   r.left = MenuRect.left + MENU_FRAME_WIDTH;
				   r.top = MenuRect.top + MENU_FRAME_HEIGHT + MENU_ITEM_HEIGHT * index;
				   r.right = r.left + MenuRect.width - MENU_FRAME_WIDTH * 2;
				   r.bottom = r.top + CConfig.MessageFont;
				 */
				var r:Rectangle = new Rectangle(MenuRect.left + MENU_FRAME_WIDTH, MenuRect.top + MENU_FRAME_HEIGHT + MENU_ITEM_HEIGHT * index, MenuRect.width - MENU_FRAME_WIDTH * 2, CConfig.MessageFont);
				Mixing(r, MenuItem(index));
				CopyAndRepaint(r);
			}
		}
		
		/**
		 * 显示消息区域
		 */
		public function ShowMessageWindow():void
		{
			TextDisplay = true;
			TextShow = true;
			Invalidate(TextRect);
			Update();
		}
		
		/**
		 * 清除画面上的消息
		 * @param	update
		 */
		public function HideMessageWindow(update:Boolean = true):void
		{
			TextDisplay = false;
			if (TextShow)
			{
				TextShow = false;
				Invalidate(TextRect);
				if (update)
					Update();
			}
		}
		
		/**
		 * 切换消息窗口是否显示
		 */
		public function FlipMessageWindow():void
		{
			if (TextDisplay)
			{
				TextShow = TextShow ? false : true;
				Invalidate(TextRect);
				Update();
			}
		}
		
		/**
		 * 显示重叠的CG
		 * @param	pos
		 */
		public function ShowOverlapLayer(pos:int):void
		{
			// 是要显示的状态吗？
			if (OverlapShow)
			{
				// 如果是显示在中间时，就删除所有之前显示的图形
				if ((OverlapFlags == Center && pos != Center) || // 中间 -> 其他
				(OverlapFlags != Center && pos == Center)) // 其他 -> 中间
				{
					trace("CMainWin::ShowOverlapLayer 显示在中间，删除所有之前显示的图形");
					Invalidate(Position[OverlapFlags]);
					OverlapFlags = None;
					OverlapBounds.setEmpty();
				}
			}
			OverlapFlags |= pos;
			OverlapBounds = Position[OverlapFlags];
			OverlapShow = true;
			trace("CMainWin::ShowOverlapLayer Invalidate == ", Position[pos]);
			Invalidate(Position[pos]);
		}
		
		/**
		 * 重叠(overlap)的消去
		 * 实际上只有显示状况变更
		 * @param	pos
		 */
		public function HideOverlapLayer(pos:int):void
		{
			// 是要显示的状态吗？
			if (OverlapShow)
			{
				// 如果是显示在中间时，就删除所有之前显示的图形
				if ((OverlapFlags == Center && pos != Center) || // 中间 -> 其他
				(OverlapFlags != Center && pos == Center)) // 其他 -> 中间
				{
					Invalidate(Position[OverlapFlags]);
					OverlapFlags = None;
					OverlapBounds.setEmpty();
				}
			}
			OverlapFlags &= ~pos;
			OverlapBounds = Position[OverlapFlags];
			if (OverlapFlags == None)
				OverlapShow = false;
			Invalidate(Position[pos]);
		}
		
		/**
		 * 隐藏功能表菜单
		 * @param	update
		 */
		public function HideMenuWindow(update:Boolean = true):void
		{
			if (MenuShow)
			{
				MenuShow = false;
				Invalidate(MenuRect);
				if (update)
					Update();
			}
		}
		
		/*
		   public function ClearMenuItemCount():void
		   {
		   MenuCount = 0;
		   }
		 */
		
		/**
		 *
		 * @return
		 */
		public function GetMenuItemCount():int
		{
			return MenuCount;
		}
		
		/**
		 *
		 * @param	index
		 * @return
		 */
		public function GetMenuAnser(index:int):int
		{
			return (MenuBuffer[index] as CMenuItem).anser;
		}
		
		/**
		 * 清除所有图片
		 * pix所指定的就是填满用的色彩
		 * @param	pix
		 */
		public function HideAllLayer(pix:uint):void
		{
			BgColor = pix;
			BackShow = false;
			OverlapShow = false;
			OverlapFlags = None;
			OverlapBounds.setEmpty();
		}
		
		/**
		 * CG与文字的合成
		 * @param	rect
		 * @param	flags FIXME:
		 */
		public function Mixing(rect:Rectangle, flags:uint = 0xFFFFFFFF):void
		{
			// 背景
			if (BackShow)
				MixedImage.Copy(BackLayer, rect); // 如果有背景就复制
			else
				MixedImage.FillRect(rect, BgColor); // 如果没有背景就涂满
			
			// 重叠
			if (OverlapShow) // 如要要重叠就叠合
			{
				trace("CMainWin::Mixing, OverlapShow", OverlapBounds.intersection(rect));
				MixedImage.MixImage(OverlapLayer, OverlapBounds.intersection(rect));
			}
			
			// 存档 读取装入菜单
			if (SaveShow)
			{
				if (flags & SaveTitle)
				{
					MixedImage.DrawFrameRect(SAVE_X, SAVE_Y, SAVE_TITLE_WIDTH, SAVE_ITEM_HEIGHT);
					MixedImage.DrawText(hFont, SAVE_TEXT_OFFSET_X, SAVE_TEXT_OFFSET_Y, IsSaveMenu ? "存档" : "装入");
				}
				for (var i:int = 0; i < CParams.PARAMS_MAX_SAVE; i++)
				{
					if (flags & SaveItem(i))
					{
						var y:int = (i + 1) * SAVE_ITEM_INTERVAL;
						MixedImage.DrawFrameRect(SAVE_X, SAVE_Y + y, SAVE_W, SAVE_ITEM_HEIGHT, DataTitle[i].color);
						MixedImage.DrawText(hFont, SAVE_TEXT_OFFSET_X, SAVE_TEXT_OFFSET_Y + y, DataTitle[i].title, DataTitle[i].color);
					}
				}
			}
			else
			{
				// 消息区域
				if (TextShow)
				{
					if (flags & TextMessage)
					{
						trace("CMainWin::Mixing: TextRect == ", TextRect.x, TextRect.y, TextRect.width, TextRect.height);
						MixedImage.DrawFrameRect2(TextRect);
						for (i = 0; i < CConfig.MessageLine; i++)
						{
							trace("CMainWin::Mixing DrawText " + MsgX(0) + "," + MsgY(i) + "," + MsgBuffer[i]);
							MixedImage.DrawText(hFont, MsgX(0), MsgY(i), MsgBuffer[i]);
						}
					}
					else
					{
						var temp:Rectangle = TextRect.intersection(rect);
						trace("CMainWin::Mixing: FillHalfToneRect " + temp.x + " " + temp.y + " " + temp.width + " " + temp.height);
						MixedImage.FillHalfToneRect(temp);
					}
					// 等待输入标志（沿用DrawText秀出符号）
					if (WaitMarkShowing && flags & TextWaitMark)
						MixedImage.DrawText(hFont, MsgX(WAITMARK_X), MsgY(WAITMARK_Y), "▼");
				}
				// 菜单
				if (MenuShow)
				{
					if (flags & MenuFrame)
						MixedImage.DrawFrameRect2(MenuRect);
					else
						MixedImage.FillHalfToneRect(MenuRect.intersection(rect));
					for (i = 0; i < MenuCount; i++)
					{
						if (flags & MenuItem(i))
						{
							MixedImage.DrawText(hFont, MenuRect.left + MENU_FRAME_WIDTH, MenuRect.top + MENU_FRAME_HEIGHT + MENU_ITEM_HEIGHT * i, (MenuBuffer[i] as CMenuItem).text, (MenuBuffer[i] as CMenuItem).color);
						}
					}
				}
			}
		}
		
		/**
		 * 当画面显示变更时，就再描绘
		 * @param	repaint
		 * @return
		 */
		public function Update(repaint:Boolean = true):Boolean
		{
			// 有无效区域
			if (!InvalidRect.isEmpty())
			{
				//FIXME: 由于不能局部重画，所以改为全部重画
				if (NO_FIX_UPDATE_BUG)
				{
					Mixing(InvalidRect); // 合成
					if (repaint)
					{
						CopyAndRepaint(InvalidRect); // 重绘
					}
				}
				/*
				   else
				   {
				   //FIXME:真正的绘画在Mixing中
				   Mixing(CMainWin.Position[CMainWin.Both]);
				   if (repaint)
				   CopyAndRepaint(CMainWin.Position[CMainWin.Both]);
				   }
				 */
				InvalidRect.setEmpty(); // 将无效区域设定为“无”
				return true; // Update了
			}
			return false; // 什么都没作
		}
		
		/**
		 * 读取背景CG
		 * @param	name
		 * @return
		 */
		public function LoadImageBack(name:String):Boolean
		{
			BackShow = true;
			Invalidate(Position[Both]);
			return BackLayer.LoadImage(name);
		}
		
		/**
		 * 重叠背景CG
		 * @param	name
		 * @param	pos
		 * @return
		 */
		public function LoadImageOverlap(name:String, pos:int = CMainWin.Both):Boolean
		{
			ShowOverlapLayer(pos);
			return OverlapLayer.LoadImage(name, Position[pos].left, Position[pos].top);
		}
		
		/**
		 * 删除背景CG
		 * @return
		 */
		public function ClearImageBack():Boolean
		{
			BackShow = false;
			Invalidate(Position[Both]);
			return true;
		}
		
		/**
		 * 不合法文字的判断
		 *
		 * 换行时要判定行首是否为不合法的文字
		 * 此字码为检查日文系统的日文字码，不影响中文的处理
		 * 读者也可依需求加入中文特殊字码的检查
		 * @param	p
		 * @return
		 */
		public function Kinsoku(p:String):Boolean
		{
			switch ((p[0]) & 0xFF)
			{
				case 0x81: 
					switch ((p[1]) & 0xFF)
					{
						case 0x41: 
						case 0x42: 
						case 0x49: 
						case 0x48: 
						case 0x5B: 
						case 0x6A: 
						case 0x76: 
						case 0x78: 
						case 0x99: 
						case 0xf4: 
							return true;
					}
					break;
				
				case 0x82: 
					switch ((p[1]) & 0xFF)
					{
						case 0x9f: 
						case 0xa1: 
						case 0xa3: 
						case 0xa5: 
						case 0xa7: 
						case 0xe1: 
						case 0xe3: 
						case 0xe5: 
						case 0xc1: 
							return true;
					}
					break;
				
				case 0x83: 
					switch ((p[1]) & 0xFF)
					{
						case 0x40: 
						case 0x42: 
						case 0x44: 
						case 0x46: 
						case 0x48: 
						case 0x83: 
						case 0x85: 
						case 0x87: 
						case 0x62: 
							return true;
					}
			}
			return false;
		}
		
		public static const STR_LIMIT:int = (CConfig.MessageWidth - 2);
		public static const STR_WIDTH:int = (STR_LIMIT - 2);
		
		/**
		 * 清除消息
		 */
		public function ClearMessage():void
		{
			HideMessageWindow();
			CurX = CurY = 0;
			for (var i:int = 0; i < CConfig.MessageLine; i++)
			{
				//MsgBuffer[i][0] = 0;
				MsgBuffer[i] = "";
			}
		}
		
		/**
		 *
		 * @param	c
		 * @return
		 */
		public function _ismbblead(c:int):Boolean
		{
			//FIXME:
			return false;
		}
		
		/**
		 * 将消息填入文字缓冲区(MsgBuffer)
		 * @param	msg
		 * @return
		 */
		public function ____FormatMessage(msg:String):int
		{
			//FIXME:
			CurX = CurY = 0;
			
			//for (var i:int = 0; i < CConfig.MessageLine; i++)
			//	MsgBuffer[i][0] = 0;
			for (var i:int = 0; i < CConfig.MessageLine; i++)
				MsgBuffer[i] = "";
			
			var pos:int = 0;
			while (msg.substr(pos, 1) && CurY < CConfig.MessageLine)
			{
				if (msg.substr(pos, 1) == "\n")
				{
					pos++;
					MsgBuffer[CurY][CurX] = 0;
					CurX = 0;
					CurY++;
				}
				else if (_ismbblead(msg.charCodeAt(pos)))
				{
					if (CurX >= STR_LIMIT || (CurX >= STR_WIDTH && Kinsoku(msg) == 0))
					{
						MsgBuffer[CurY][CurX] = 0;
						CurX = 0;
						CurY++;
					}
					MsgBuffer[CurY][CurX++] = msg.charCodeAt(pos);
					pos++;
					MsgBuffer[CurY][CurX++] = msg.charCodeAt(pos);
					pos++;
				}
				else
				{
					if (CurX >= STR_WIDTH)
					{
						MsgBuffer[CurY][CurX] = 0;
						CurX = 0;
						CurY++;
					}
					MsgBuffer[CurY][CurX++] = msg.charCodeAt(pos);
					pos++;
				}
			}
			if (CurX > 0 && CurY < CConfig.MessageLine)
			{
				MsgBuffer[CurY][CurX] = 0;
				CurY++;
			}
			return CurY;
		}
		
		/**
		 * 将消息填入文字缓冲区(MsgBuffer)
		 * @param	msg
		 * @return
		 */
		public function FormatMessage(msg:String):int
		{
			//FIXME:
			//这个是纯AS3的实现
			CurX = CurY = 0;
			var lines:Array = msg.split("\n", CConfig.MessageLine);
			for (var i:int = 0; i < CConfig.MessageLine; i++)
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
		
		/**
		 * 设定选项到菜单缓冲区
		 * @param	str
		 * @param	anser
		 */
		public function SetMenuItem(str:String, anser:int):void
		{
			//FIXME: 这里的数组成员可能未实体化 -> 改为在构造函数中完成
			//FIXME: 这里有可能数组溢出
			var n:int = str.length;
			(MenuBuffer[MenuCount] as CMenuItem).text = str;
			(MenuBuffer[MenuCount] as CMenuItem).anser = anser;
			(MenuBuffer[MenuCount] as CMenuItem).length = n;
			(MenuBuffer[MenuCount] as CMenuItem).color = CMisc.WhitePixel;
			MenuCount++;
		}
		
		/**
		 *
		 */
		public function ClearMenuItemCount():void
		{
			MenuCount = 0;
		}
		
		/**
		 * 读取装入游戏
		 * @param	no
		 */
		public function LoadGame(no:int):void
		{
			if (!LoadParam.Load(no))
			{
				MessageBox("无法读取。");
				return;
			}
			ScriptAction.Initialize(this, ScriptType.MODE_SCENARIO);
			if (ScriptAction.Load(LoadParam.last_script))
			{
				HideMessageWindow(false);
				HideMenuWindow(false);
				if (SaveShow)
				{
					SaveShow = false;
					Invalidate(SaveRect);
				}
				Update();
				SetAction(ActionScriptSetup);
			}
		}
		
		/**
		 * 存储游戏
		 * @param	no
		 * @param	flags
		 */
		public function SaveGame(no:int, flags:int):void
		{
			if (!ScriptAction.Params.Save(no))
			{
				MessageBox("无法存储。");
				return;
			}
			CancelLoadSaveMenu(flags);
		}
		
		/**
		 * 显示读取装入／存档画面
		 * @param	isSave
		 */
		public function ShowLoadSaveMenu(isSave:Boolean):void
		{
			IsSaveMenu = isSave;
			SaveShow = true;
			for (var i:int = 0; i < CParams.PARAMS_MAX_SAVE; i++)
			{
				var param:CParams = new CParams();
				if (param.Load(i))
				{
					DataTitle[i].activate = true;
					DataTitle[i].title = (i + 1) + ": " + param.save_month + "/" + param.save_date + " " + param.save_hour + ":" + param.save_minute;
					/*
					   sprintf(DataTitle[i].title, "%2d: %2d/%2d %2d:%02d", i + 1,
					   param.save_month, param.save_date,
					   param.save_hour, param.save_minute);
					 */
				}
				else
				{
					DataTitle[i].activate = IsSaveMenu ? true : false;
					//sprintf(DataTitle[i].title, "%2d: -- no data --", i + 1);
					DataTitle[i].title = (i + 1) + ": -- no data --";
				}
				DataTitle[i].color = DataTitle[i].activate ? CMisc.WhitePixel : CMisc.GrayPixel;
			}
			Invalidate(SaveRect);
			if (TextShow)
				Invalidate(TextRect);
			if (MenuShow)
				Invalidate(MenuRect);
			Update();
		}
		
		/**
		 * 清除读取／存档画面
		 */
		public function HideLoadSaveMenu():void
		{
			SaveShow = false;
			Invalidate(SaveRect);
			if (TextShow)
				Invalidate(TextRect);
			if (MenuShow)
				Invalidate(MenuRect);
			Update();
		}
		
		/**
		 * 离开读取／存档画面
		 * @param	flags
		 */
		public function CancelLoadSaveMenu(flags:int):void
		{
			HideLoadSaveMenu();
			Action = ScriptAction;
			Action.Resume();
			if (flags & IS_TIMEDOUT)
				Action.TimedOut(TimerSleep);
			PostMessage(CConfig.WM_KICKIDLE);
		}
		
		/**
		 * 开／关选项高亮度显示
		 * @param	int index
		 * @param	bool select
		 */
		public function SelectLoadSaveMenu(index:int, select:Boolean):void
		{
			if (index >= 0)
			{
				DataTitle[index].color = select ? CMisc.RedPixel : CMisc.WhitePixel;
				var y:int = index * SAVE_ITEM_INTERVAL + SAVE_ITEM_INTERVAL;
				var rect:Rectangle = new Rectangle(SAVE_X, SAVE_Y + y, SAVE_W, SAVE_ITEM_HEIGHT);
				Mixing(rect, SaveItem(index));
				CopyAndRepaint(rect);
			}
		}
		
		/**
		 * 取得读取装入·存储选项
		 * 从鼠标坐标取得选项索引
		 * @param	point
		 * @return
		 */
		public function GetLoadSaveSelect(point:Point):int
		{
			if (point.x >= SAVE_X && point.x < SAVE_X + SAVE_W && point.y >= SAVE_Y + SAVE_ITEM_INTERVAL)
			{
				var index:int = point.y - SAVE_Y - SAVE_ITEM_INTERVAL;
				if (index % SAVE_ITEM_INTERVAL < SAVE_ITEM_HEIGHT)
				{
					index /= SAVE_ITEM_INTERVAL;
					if (index < CParams.PARAMS_MAX_SAVE && DataTitle[index].activate)
						return index;
				}
			}
			return -1;
		}
		
		/**
		 * 取得下一个可以选取的选项
		 * @param	index
		 * @return
		 */
		public function NextLoadSaveSelect(index:int):int
		{
			for (var i:int = 1; i <= CParams.PARAMS_MAX_SAVE; i++)
			{
				var next:int = (index + i) % CParams.PARAMS_MAX_SAVE;
				if (DataTitle[next].activate)
					return next;
			}
			return -1;
		}
		
		/**
		 * 取得前一个可以选取的选项
		 * @param	index
		 * @return
		 */
		public function PrevLoadSaveSelect(index:int):int
		{
			for (var i:int = CParams.PARAMS_MAX_SAVE - 1; i > 0; i--)
			{
				var prev:int = (index + i) % CParams.PARAMS_MAX_SAVE;
				if (DataTitle[prev].activate)
					return prev;
			}
			return -1;
		}
		
		/**
		 * 播放音乐
		 * @param	no
		 * @return
		 */
		public function StartMusic(no:int):Boolean
		{
			if (MusicNo != no)
			{
				MusicNo = no;
				if (music)
				{
					music.Stop();
					return music.Play(no);
				}
			}
			return true;
		}
		
		/**
		 * 重播音乐
		 * @return
		 */
		public function RestartMusic():Boolean
		{
			if (music)
				return music.Replay();
			return true;
		}
		
		/**
		 * 停止音乐
		 * @return
		 */
		public function StopMusic():Boolean
		{
			MusicNo = 0;
			if (music)
				return music.Stop();
			return true;
		}
		
		/**
		 * 播放WAVE音效
		 * @param	name
		 * @return
		 */
		public function StartWave(name:String):Boolean
		{
			//char	path[_MAX_PATH];
			var path:String;
			//sprintf(path, WAVEPATH "%s.wav", name);
			path = CConfig.WAVEPATH + name + ".wav";
			return wave.Play2(path);
		}
		
		/**
		 *
		 * @param	rect
		 */
		public function Invalidate(rect:Rectangle):void
		{
			trace("CMainWin::Invalidate() InvalidRect == " + InvalidRect.x + "," + InvalidRect.y + "," + InvalidRect.width + "," + InvalidRect.height);
			trace("CMainWin::Invalidate() rect " + rect.x + "," + rect.y + "," + rect.width + "," + rect.height);
			InvalidRect = InvalidRect.union(rect);
			trace("CMainWin::Invalidate() InvalidRect(2) == " + InvalidRect.x + "," + InvalidRect.y + "," + InvalidRect.width + "," + InvalidRect.height);
		}
		
		/**
		 *
		 * @param	x
		 * @return
		 */
		public function MsgX(x:int):int
		{
			return x * CConfig.MessageFont / 2 + CMainWin.MSG_TEXTOFFSET_X;
		}
		
		/**
		 *
		 * @param	y
		 * @return
		 */
		public function MsgY(y:int):int
		{
			return y * (CConfig.MessageFont + CMainWin.MSG_TEXTSPACE_Y) + CMainWin.MSG_TEXTOFFSET_Y;
		}
		
		/**
		 *
		 */
		public function ClearBack():void
		{
			ClearImageBack();
		}
		
		/**
		 *
		 */
		public function ClearCenter():void
		{
			HideOverlapLayer(CMainWin.Center);
		}
		
		/**
		 *
		 */
		public function ClearLeft():void
		{
			HideOverlapLayer(CMainWin.Left);
		}
		
		/**
		 *
		 */
		public function ClearRight():void
		{
			HideOverlapLayer(CMainWin.Right);
		}
		
		/**
		 *
		 */
		public function ClearOverlap():void
		{
			HideOverlapLayer(CMainWin.Both);
		}
		
		/**
		 *
		 * @param	name
		 * @return
		 */
		public function LoadImageLeft(name:String):Boolean
		{
			return LoadImageOverlap(name, CMainWin.Left);
		}
		
		/**
		 *
		 * @param	name
		 * @return
		 */
		public function LoadImageRight(name:String):Boolean
		{
			return LoadImageOverlap(name, CMainWin.Right);
		}
		
		/**
		 *
		 * @param	name
		 * @return
		 */
		public function LoadImageCenter(name:String):Boolean
		{
			trace("CMainWin::LoadImageCenter");
			return LoadImageOverlap(name, CMainWin.Center);
		}
		
		/*
		   public function LoadImageOverlap(name:String):Boolean
		   {
		   return LoadImageOverlap(name, CMainWin.Both);
		   }
		 */
		
		/**
		 *
		 * @return
		 */
		public function GetInvalidRect():Rectangle
		{
			return InvalidRect;
		}
	}
}
