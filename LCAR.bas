B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Special values: C:\Users\Techni\Documents\VB\LCAR\Sounds
'X/Y locations
'>MaxInt	% of width/height relative to left/top (%= (value-MaxInt) * 0.01)
'<MinINT	% of width/height relative to width/height (%= (value+MinINT) * 0.01)
'=>0 		relative to left/top
'<0  		relative to width/height

'LCAR_Button
'LWidth=Width of left curved part, RWidth=Width of right curved part, Number is only drawn if >-1

'LCAR_Timer
'Not drawn, but will still move if visible=true, so you can use it to delay the LCAR_StoppedMoving event

'LCAR_Slider, LCAR_Meter, LCAR_Chart
'Lwidth=current percent, rwidth=desired percent, align=LCAR_Random randomizes rwidth when lwidth=rwidth
'LCAR_Chart Align -1= top edge, LCAR_Random or 0=graph item, 1=bottom edge, sidetext=0,empty = normal, sidetext=-1 = left edge, sidetext=1 = right edge

'LCAR_SensorGrid
'Lwidth=current X, rwidth=current y, element.Align=desired X, element.TextAlign=desired y,  Enabled=true randomizes desired when = to current

'LCAR_Picture
'LWidth=Picture ID/Index, Align=5 Picture is centered on X/Y

'LCAR_Textbox
'Lwidth=Selection start, RWidth=Selection Width

'LCAR_Elbow
'Lwidth=BarWidth, Rwidth=BarHeight

'LCAR_Numbers
'LWidth=Number list ID

'LCAR_List
'Style 0=normal, 1(LCAR_Chart), 2(LCAR_Graph) =Chart ShowNumber=true randomizes item Number when Number = whitespace, Number=Desired Percent, WhiteSpace=Current Percent

'fonts http://star-trek-fonts.fanspace.com/

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.	
	Dim ScaleWidth As Int, 				ScaleHeight As Int , 			BiggestHeight As Int,  			Landscape As Boolean ,		MultiTouchEnabled As Boolean,	SpeedSensor As Int=2,		WasPlaying As Int ,				ChartWidth As Int=40, 		ChartEdgeHeight As Int=13, 	ChartHeight As Int=62,  	LCAR_DarkYellow As Int,		LCAR_RandomTheme As Int=-9998
	Dim LCAR_Black As Byte, 			LCAR_DarkOrange As Byte, 		LCAR_Orange As Byte,  			LCAR_LightOrange As Byte,	LCAR_Purple As Byte,			LCAR_RedAlert As Byte,  	LCAR_LightPurple As Byte,		LCAR_LightBlue As Byte,	 	LCAR_Red As Byte,  			LCAR_Yellow  As Byte, 		LCAR_DarkBlue As Byte,		LCAR_Random As Int =-9999
	Dim LCARcolors As List ,			Mute As Boolean,				ElementMoving As Boolean,		BlinkState As Boolean ,		ListitemWhiteSpace As Int=3,	NumberWhiteSpace As Int, 	NumberTextSize As Int ,			Alphaspeed As Int=16,		Stage As Int,				MeterWidth As Int=60,  		LCAR_DarkPurple  As Byte,	LCAR_Blue As Byte
	Dim Looping As Int,					HalfWhite As Int, 				FPS As Int,						FramesDrawn As Int ,		AlphaBlending As Boolean=True,	SelectedIP As Int=-1,		VisibleList As Int, 			BackupKB As APIKeyboard , 	ChartSpace As Int=5,		ListIsMoving As Boolean ,	LCAR_White  As Byte,		LCAR_LightYellow As Byte
	
	Dim MaxINT As Int=2147483647,		MinINT As Int= -2147483648, 	MAXDIM As Int=MaxINT-100, 		MINDIM As Int=MinINT+100, 	BatteryPercent As Int, 			WasFull As Boolean,			OldBattery As Int, 				isCharging As Boolean , 	BatteryTemp As Float,		LCAR_NumberTextSize As Int=9999,LCAR_RandomText As String = "RNDTXT", NewSecond As Boolean, LastUpdate As Int
	
	'ElementTypes: 0=button
	Type Point							(X As Int, 						Y As Int)
	Type ColorTheme						(Name As String,				ColorList(5) As Int, 			ColorCount As Int)
	Type LCARColor						(Name As String, 				Normal As Int, 					Selected As Int, 				nR As Int, 						nG As Int, 					nB As Int, 						sR As Int, 					sG As Int, 					SB As Int) 
	Type tween							(currX As Int, 					currY As Int, 					offX As Int, 					offY As Int)
	Type TweenAlpha						(Current As Int, 				Desired As Int)
	Type ElementClicked					(ElementType As Int, 			X As Int, 						Y As Int, 						Index As Int, 					Dimensions As tween,		X2 As Int, 						Y2 As Int, 					Index2 As Int , 			EventType As Int,			RespondToAll As Boolean , Index3 As Int)
	Type LCARnumberlist					(Rows As Int, 					ShowRows As Int, 				Cols As List)
	Type LCARnumberCol					(Numbers As List, 				Width As Int, 					Digits As Int, 					Align As Int)
	Type LCARpicture					(Name As String, 				Picture As Bitmap, 				Dir As String )
	Type LCARlistitem					(Text As String, 				Side As String, 				Tag As String , 				Selected As Boolean, 			Number As Int, 				IsClean As Boolean , 			ColorID As Int, 			WhiteSpace As Int)
	Type LCARlist						(Opacity As TweenAlpha, 		LastMint As Int, 				ForcedMint As LCARlistitem, 	ForcedMintCount As Int, 		Style As Int, 				ColsPortrait As Int, 			ColsLandscape As Int, 		Start As Int, 				LOC As tween, 				Size As tween ,				SurfaceID As Int, 				ShowNumber As Boolean,	Name As String,	RhasCurve As Boolean,	Tag As String,		IsClean As Boolean,	MultiSelect As Boolean,	SelectedItems As Int,	SelectedItem As Int,	isDown As Boolean,	isScrolling As Boolean,	Visible As Boolean,	RedX As Int,		RedY As Int,		Red As Int,				WhiteSpace As Int, LWidth As Int, RWidth As Int, Alignment As Int, ListItems As List,Locked As Boolean, OneColOnly As Boolean ,Async As Boolean, SelectedXY As Point, Offset As Int,Ydown As Float)
	Type LCARelement					(LOC As tween ,					Size As tween,					Opacity As TweenAlpha, 			ElementType As Int, 			ColorID As Int, 			IsDown As Boolean, 				Name As String,				SurfaceID As Int, 			Tag As String, 				Group As Int,				Text As String,					SideText As String,  	LWidth As Int,	RWidth As Int,			IsClean As Boolean,	TextAlign As Int,	RedAlertHold As Int,	RedAlertCycles As Int,	State As Boolean,		Visible As Boolean,	Enabled As Boolean,		Align As Int,		Blink As Boolean,	Async As Boolean,	RespondToAll As Boolean)
	Type LCARgroup						(Visible As Boolean, 			RedAlert As Int, 				LCARlist As List, 				HoldList As List, 				Hold As Int )
	
	Dim LCARelements As List , 			LCARGroups As List , 			LCARlists As List ,				LCARnumberlists As LCARnumberlist, 								LCARVisibleLists As List,		LCAR_Grey As Byte,				ClearLocked As Boolean
	Dim Fontsize As Int, 				LCARfont As Typeface ,			LCARfontheight As Int, 			RedAlert As Boolean ,			IsClean As Boolean, 			LCAR_Block As String= "‖" ' , NeedsEnumerating As Boolean 
	
	Dim KBListID As Int, 				KBCancelID As Int, 				KBGroup As Int, 				KBShift As Boolean ,			NumListID As Int, 				NumButtonID As Int, 			NumGroup As Int, 				KBCaps As Boolean =True
	Dim ItemHeight As Int,				AntiAliasing As Boolean, 		WebviewOffset As Int,			LessRandom As Boolean,			CurrRandom As Int,				CurrListID As Int=-1:			AntiAliasing=True
	Dim LCARCorner As Bitmap, 			LCARCornerSlider As Bitmap,		LCARCornerElbow As Bitmap,		LCARCornerElbow2 As Bitmap,		ScreenIsOn As Boolean,			LargeScreen As Boolean 
	Dim LCARCornera As Bitmap, 			LCARCornerSlidera As Bitmap,	LCARCornerElbowa As Bitmap,		LCARCornerElbow2a As Bitmap,	UseAnotherFolder As Boolean 

	Dim LCAR_List As Byte=-1, 			LCAR_Button As Byte=0,			LCAR_Elbow As Byte=1,			LCAR_Textbox As Byte=2, 		LCAR_Slider As Byte=3,			LCAR_CodeChanged As Byte=-2,	LCAR_Meter As Byte=4,			LCAR_Keyboard As Byte=-10
	Dim LCAR_StoppedMoving As Byte=-3, 	LCAR_Timer As Byte=-4,			LCAR_StoppedPlaying As Byte=-5, LCAR_Chart As Byte=7,			LCAR_Picture As Byte=6,			LCAR_SensorGrid As Byte=5,		LCAR_ChartNeg As Byte=-6,		LCAR_Navigation As Byte=8
	Dim LCAR_SensorChanged As Byte=-7,	LCAR_IGNORE As String,			LCAR_TimerIncrement As Byte=-8, leftside As Byte,				Zoom As Int,					LoadedFilename As String,   	LOD As Boolean=True , 			LCAR_OK As Byte=-9
	Dim LCAR_Tactical As Byte=9,		LCAR_LastListitem As Int=-1000,	SymboardID As Int ,				ElbowTextHeight As Byte,		LCAR_Borg As Byte=10,			SmallScreen As Boolean ,		LCAR_Okuda As Byte=11
	Dim LCAR_Dpad As Byte=12,			LCAR_Alert As Byte=13, 			Classic_Yellow As Byte,			Classic_Green As Byte,			Classic_Blue As Byte, 			Classic_LightBlue As Byte,		LCAR_HardwareBTN As Byte=-11,	LCAR_HorSlider As Byte=14
	Dim LCAR_Matrix As Byte=15,			LCAR_StarBase As Byte=16,		LCAR_Analysis As Byte=17,		Klingon_Button As Byte=18,		Klingon_Frame As Byte=19,		Legacy_Button As Byte=20,		LCAR_ToastDone As Byte =21,		LCAR_Graph As Byte =22
	Dim LCAR_Engineering As Byte=23 ,	ENT_Button As Byte=24,			LCAR_SensorSweep As Byte=25,	LCAR_Clear As Int,				LCAR_BigText As Int=-999,		LCAR_Omega As Byte=26,			LCAR_Ruler As Byte =27,			LCAR_MultiSpectral As Byte=28
	Dim LCAR_ShieldStatus As Byte=29,	LCAR_PdP As Byte=30,			PCAR_Frame As Byte=31,			LCAR_PdPSelector As Byte=32,	LCAR_Static As Byte=33,			SBALLS_Plaid As Byte=34,		TOS_Moires As Byte=35, 			Legacy_Sonar As Byte=36
	Dim Classic_Turq As Int,			LCAR_RndNumbers As Byte=37,		TMP_RndNumbers As Byte=38,		LCAR_TextButton As Byte=39, 	LCAR_PToE As Byte=40,			LCAR_MSD As Byte=41,			LCAR_NCC1701D As Byte=42,		BTTF_Flux As Byte=43
	Dim LCAR_LWP As Byte=44,			LCAR_MiniButton As Byte=45,		LCAR_WarpCore As Byte=46,		LCAR_ShuttleBay As Byte=47, 	IsInternal As Boolean,			LCAR_ASquare As Byte=48,		LCAR_Starfield As Byte=49,		LCAR_MultiLine As Byte=50
	Dim LCAR_Answer As Byte=51,			LCAR_AnswerMade As Byte=52, 	LCAR_LSOD As Byte=53,			LCAR_Science As Byte=54,		TOS_Button As Byte =55,			LCAR_Frame As Byte=56,			SWARS_Targeting As Byte=57,		LCAR_Metaphasic As Byte =58
	Dim TMP_Switch As Byte=59,			TMP_Text As Byte=60,			TMP_Numbers As Byte=61,			TMP_Reliant As Byte=62,			TMP_FireControl As Byte=63,		LCAR_Widget As Byte=64,			SYS_System As Byte=65,			CHX_Logo As Byte = 66
	Dim CHX_Iconbar As Byte=67,			CHX_Window As Byte=68,			DRD_Timer As Byte = 69,			DRD_Matrix As Byte = 70,		VOY_Tricorder As Byte=71,		SYS_Camera As Byte = 72,		AIR_Alart As Byte= 73,			LCAR_ThreeDGame As Byte = 74
	Dim ENT_Planets As Byte = 75,		SYS_Lightpack As Byte = 76,		EVENT_Horizon As Byte = 77,		CRD_Shatter As Byte = 78,		LCAR_3Dmodel As Byte = 79,		ROM_Square As Byte = 80,		Klingon_Clock As Byte = 81,		TMP_3Dwave As Byte = 82
	Dim ENT_Radar As Byte = 83,			ENT_Meter As Byte = 84,			ENT_RndNumbers As Byte= 85,		ENT_Sin As Byte = 86,			LCAR_GNDN As Byte = 87,			LCAR_Tactical2 As Byte = 88,	LCAR_Basic As Byte = -2,		LCAR_UFP As Byte =89
	Dim LCAR_Bit As Byte = 90,			Q_net As Byte = 91,				LCAR_Cards As Byte = 92,		ENT_Graph As Byte = 93,			MSC_Sheliak As Byte = 94,		CRD_Main As Byte = 95,			LCAR_SVG As Byte = 96,			LCAR_WarpField As Byte = 97
	Dim TMP_Alert As Byte = 98,			LCAR_DNA As Byte = 99,			MSC_Hacking As Byte = 100,		LCAR_Plasma As Byte = 101,		DrP_Board As Byte = 102,		TCAR_Main As Byte = 103,		BORG_Borg As Byte = 104,		FER_Ticker As Byte = 105
	Dim TMP_Engineering As Byte = 106,	TMP_Meter As Byte = 107
	
	Dim Educational As Boolean,			Classic_Red As Int
	Type LCARSound						(Name As String, 				Filename As String, 			Dir As String,   				Length As Int, SPID As Int) 'UseSoundPool As Int,)
	Type GesturePoint					(Id As Int,						prevX As Int,					prevY As Int,					Element As ElementClicked )
	Dim GestureMap As List,				EventList As List,				SoundList As List ,				PictureList As List,			MP As MediaPlayer,				ThemeList As List,			CurrentTheme As ColorTheme, 	CTindex As Int, DontHide As Boolean 
	'Dim MP2 As MediaPlayer 
	
	
	Dim Event_Down As Byte=1,			Event_Up As Int, 				Event_Move As Int=2, 			Event_Scroll As Int=3, 			Event_Move_Absolute As Int = 4, OldX As Int, 				OldY As Int, 					MinTimer As Long,				TimerPeriod As Int, 		VibratePeriod As Int ,		didIncrementNumbers As Boolean
	Dim IsAAon As Boolean ,				SmoothScrolling As Boolean,		DoVector As Boolean  ,			ResetVol As Boolean, 			Locked As Boolean  ,			BGisInit As Boolean,		SymbolsEnabled As Boolean, 		BypassHardwareKB As Boolean, Event_Other As Int=4
	Dim VolOpacity As Int, 				VolSeconds As Int ,				VolVisible As Int=5,			FPSCounter As Boolean,			DrawFPS As Boolean ,			VolText As String , 		VolTextList As List,			VolInc As Int  ,			VolDimensions As Point 
	Dim HasHardwareKeyboard As Boolean, KBisVisible As Boolean,			ToastAlign As Boolean ,			CurrSound As LCARSound ,		Fontfactor As Int=50, 			Vibrate As PhoneVibrate, 	RumbleUnit As Int=0 ,			IsRumbling As Boolean, 		NeedsResuming As Int = -1
	'Dim SP As SoundPool,PlayID As Int :PlayID=-1:SP.Initialize(1)
		
	LCAR_IGNORE="IGNORETHIS": 											HalfWhite =Colors.ARGB(128,255,255,255)		
	LCARCornerElbowa.Initialize(File.DirAssets,"elbow.gif"):			LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2.gif")
	LCARCornerElbow.Initialize(File.DirAssets,"elbow.png"):				LCARCornerElbow2.Initialize(File.DirAssets,"elbow2.png")
	Dim BorgFont As Typeface = Typeface.LoadFromAssets("borg.ttf"), 	BORG_Color As Int 
	VolTextList.Initialize 
	
	Dim LCAR_SelectedItem As Int=-999, 	ButtonList As Int=-1 , 			TOSFont As Typeface, 			RedAlertMode As Int',			LCAR_BlueAlert As Int ',WasRedAlert As Boolean ,FlagSet As Boolean 
	Dim TextPos As Point , 				CharSize As Point ,				ClickedOK As Boolean ,			LCAR_Sidebar As Int ,			MinWidth As Int ,				CurrentStyle As Int,		StarDateMode As Int,			CurrentRotationX As Int, 	CurrentRotationY As Int
	Dim LCAR_TNG As Byte=0, 			LCAR_TOS As Byte =1, 			LCAR_ENT As Byte =2 ,			LCAR_TMP As Byte=3, 			Klingon As Byte =4,				Ferengi As Byte=5,			StarWars As Byte =6,			ChronowerX As Byte = 7, 	Romulan As Byte=8, 			StarshipTroopers As Byte = 10'styles
	Dim BattleStar As Byte = 13,		Cardassian As Byte = 14,		ImageToast As Byte = 9,			OverscanX As Int, 				OverscanY As Int,				OvalHeight As Byte=20 ,		FreedomWars As Byte=11,			KnightRider As Byte = 12, 	LCAR_ClassicTNG As Byte = 15'styles
	Dim tCARS As Byte = 16,				BORG As Byte = 17
	Dim LWPUnlocked As Boolean,			KBLayout As Int,				LCAR_Beeps As Int,				CurrentVersion As Int,			CrazyRez As Float , 			LCAR_Chrono As Byte,		DontCancel As Boolean, 			ROMfont As Typeface, hVol As Int
	Dim TCAR_DarkTurquoise As Byte, 	TCAR_LightTurquoise As Byte, 	TCAR_Yellow As Byte, 			TCAR_Orange As Byte, 			TCAR_DarkOrange As Byte,		TCAR_DarkPurple As Byte,	TCAR_LightPurple As Byte
	
	Dim SRV_State As Byte = Games.PT_Local ,LightpackLEDs As Int , LightpackPattern As Int, LightpackIndex As Int, LightpackUpdateFreq As Long, LightpackNextUpdate As Long , LightpackOld As Int , PartyTime As Boolean, NeedsLCARfont As Boolean, ListWasScrolling As Int 
End Sub

'Index=0 (showsection, index2=-1 is modeselect, 1=goto sleep) 
Sub SystemEvent(Index As Int,Index2 As Int)
	PushEvent(SYS_System,  Index,Index2,0,0,0,0, Event_Down)
End Sub

Sub LightpackChangePattern(PatternID As Int, Delay As Int, ColorID As Int, Smoothness As Int )
	'Log("Changing lightpack pattern")
	LightpackPattern=PatternID
	LightpackIndex = 0
	If PatternID = 0 Then 
		ColorID=LCAR_Orange
		Delay=0
	Else If PatternID = 3 Then
		LightpackIndex = ColorID
	End If
	LightpackUpdateFreq=Delay
	LightpackOld = -1
	LightpackNextUpdate = DateTime.Now + LightpackUpdateFreq
	If Smoothness >-1 And Smoothness <101 Then LightpackEvent(-4,0,  Smoothness, 0,0)
	If ColorID>-1 Then LightpackColor(-1,0, ColorID,False, 255)
End Sub

'LED: -1=all >-1=specific LED, -2=brightness (0 to 100), -3=gamma (0.01 to 10.00), -4=setsmooth (0/off to 255/full), -5=ticks between updates, -6=Pattern, -7=Index
'for gamma, red = whole number, green = fraction *100 (so a max of 2 decimal places)
Sub LightpackEvent(LED As Int, LED2 As Int, R As Int, G As Int, B As Int)
	PushEvent(SYS_Lightpack, LED, LED2, Max(0,Min(255, R)),Max(0,Min(255,G)),Max(0,Min(255,B)), 0, Event_Down)
End Sub
Sub LightpackColor(LED As Int, LED2 As Int, ColorID As Int, State As Boolean, Alpha As Int) As Int 
	Dim tempcolor As LCARColor =  GetColorFlat(ColorID,State,Alpha)
	If LED>= LightpackLEDs Then Return 0
	LightpackEvent(LED, LED2, tempcolor.nR, tempcolor.ng, tempcolor.nb)
	Return tempcolor.Normal 
End Sub
Sub LCAR_HandleLightpack
	Dim temp As Int , temp2 As Int, HasChanged As Boolean = LightpackIndex<>LightpackOld
	If LightpackPattern>0 And LightpackNextUpdate <= DateTime.Now And LightpackUpdateFreq>0 And (LightpackLEDs>0 Or API.debugMode) Then
		Select Case  LightpackPattern 
			Case 1'red alert
				temp = LightpackLEDs / 2
				LightpackIndex = 1-LightpackIndex
				LightpackColor(0,temp-1,   RedAlertMode, LightpackIndex=1, 255)'first half red/white
				LightpackColor(temp,LightpackLEDs-1,   RedAlertMode, LightpackIndex=0, 255)'second half white/red
			Case 2'warp core (0 to 6, 7 states, 0 being all off)
				If LightpackIndex = 0 Then
					LightpackColor(-1, 0, LCAR_White, False, 255)
				Else If HasChanged Then '1 to 6
					temp = LightpackLEDs / 2
					temp2 = API.IIF(RedAlert, LCAR_Red, LCAR_Blue)
					
					LightpackColor(temp- LightpackOld, 0,  LCAR_White, False,255)
					LightpackColor(temp + LightpackOld -1, 0,  LCAR_White, False,255)
					
					LightpackColor(temp- LightpackIndex, 0,  temp2, False,255)
					LightpackColor(temp + LightpackIndex -1, 0,  temp2, False,255)
					
				End If
			Case 3'solid color (	LightpackIndex)
				LightpackColor(-1, 0,    LightpackIndex, False, Rnd(128,256))
			Case 4'Manual control
				'GNDN
			Case 5'rainbow
				LightpackIndex = (LightpackIndex + 1) Mod 239
				temp = API.HSLtoRGB(LightpackIndex,127,127,255)
				LightpackEvent(-1,0, API.GetARGB(temp, 1), API.GetARGB(temp, 2),API.GetARGB(temp, 3))
				
			Case Else
				Log("Lightpack pattern not recognized")
		End Select
		If HasChanged Then LightpackOld=LightpackIndex
		LightpackNextUpdate= DateTime.Now + LightpackUpdateFreq
	End If
End Sub





Sub DirDefaultExternal As String 
	If UseAnotherFolder Then
		If Not( File.Exists(File.DirRootExternal, "LCARS")) Then File.MakeDir(File.DirRootExternal, "LCARS")
		Return File.Combine(File.DirRootExternal, "LCARS")
	Else
		Return File.DirDefaultExternal 
	End If
End Sub

Sub HandleBattery(Level As Int, Scale As Int, Plugged As Boolean, Intent As Intent)As Int
	Dim temp As Int
	temp=Level/Scale*100
	If OldBattery = temp And Plugged = isCharging Then Return temp 
	'Log(temp & " " & Plugged)
	If Plugged <> isCharging And OldBattery<>0 And BatteryPercent <>0 And BGisInit Then
		SetRedAlert(True, "HandleBattery")
		RedAlertMode = Classic_Blue
	End If
	OldBattery= BatteryPercent
	BatteryPercent=temp
	isCharging=Plugged
	If Not(isCharging) Then
		If BatteryPercent< 95 Then WasFull=False
		If OldBattery>=50 And BatteryPercent<50 Then API.SendPebble(API.getstring("yellow_alert"), API.GetStringVars("percent_alert", Array As String(50)))
		If OldBattery>=25 And BatteryPercent<25 Then API.SendPebble(API.getstring("red_alert"),    API.GetStringVars("percent_alert", Array As String(25)))
		If OldBattery>=10 And BatteryPercent<10 Then API.SendPebble(API.getstring("red_alert"),    API.GetStringVars("percent_alert", Array As String(10)))
		If OldBattery>=5  And BatteryPercent<5  Then API.SendPebble(API.getstring("red_alert"),    API.GetStringVars("percent_alert", Array As String(5)))
	Else
		If OldBattery>0 And OldBattery<100 And BatteryPercent=100 And Not(WasFull) Then '<DateTime.Now-DateTime.TicksPerSecond-5 Then 
			API.SendPebble(API.getstring("green_alert"), API.getstring("charged_alert"))
			WasFull=True
		End If
		'WasFull=-1
	End If
	'Bundle[{icon-small=17302834, scale=100, present=true, technology=Li-ion, level=95, voltage=4026, status=2, invalid_charger=0, plugged=2, health=2, temperature=280}]
	If Intent.HasExtra("temperature") Then BatteryTemp= Intent.GetExtra("temperature")/10
	API.NotiEmpty 
	CallSubDelayed2(Widgets, "RefreshAllOfOneType", 2)
	Return temp
End Sub

Sub SetupTheVariables As Boolean 
	If Not(LCARlists.IsInitialized) Then 
		'LCARCornerElbowa.Initialize(File.DirAssets,"elbow.gif"):							LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2.gif")
		'LCARCornerElbow.Initialize(File.DirAssets,"elbow.png"):								LCARCornerElbow2.Initialize(File.DirAssets,"elbow2.png")
		GestureMap.Initialize:			EventList.Initialize:	SoundList.Initialize:		PictureList.Initialize:	MP.Initialize :			ThemeList.Initialize':		MP2.Initialize  
		LCARelements.Initialize:		LCARGroups.Initialize:	LCARlists.Initialize:		LCARnumberlists.Initialize :					LCARVisibleLists.Initialize 
		'MultiTouchEnabled = True:
		LCARSeffects.PromptWidth = LCARSeffects.BarWidth+ LCARCornerElbow2.width
		'DoVector=True
		LCAR_Clear=Colors.ARGB(0,0,0,0)		
		LCARSeffects2.SetKlingonFont
		Return True
	End If
	Return False
End Sub

Sub HandleRumbleTimer(CurrentTime As Int, StartTime As Int, EndTime As Int, Period As Int) As Boolean 
	If CurrentTime >= StartTime And CurrentTime< EndTime And Period <> VibratePeriod Then 
		RumblePeriod(Period)
		Return True
	End If
End Sub

Sub RumblePeriod(MS As Int)
	VibratePeriod=MS
	If MS =-1 Then 
		StopRumble
	Else
		RumblePattern( Array As Long( MS, RumbleUnit))
	End If
End Sub
Sub Rumble(Units As Int)
	If RumbleUnit>0 And Units > 0 Then Vibrate.Vibrate(Units*RumbleUnit)
End Sub
Sub RumblePattern(Pattern() As Long)
    Dim r As Reflector' 0=pause 1=rumble
    r.Target = r.GetContext
    r.Target = r.RunMethod2("getSystemService", "vibrator", "java.lang.String")
    r.RunMethod4("vibrate", Array As Object(Pattern, 0), Array As String("[J", "java.lang.int"))
	IsRumbling=True
End Sub
Sub StopRumble
    Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod2("getSystemService", "vibrator", "java.lang.String")
	r.RunMethod("cancel")
	IsRumbling=False
End Sub








Sub ActivateAA(BG As Canvas, AAstate As Boolean ) As Boolean 
	Dim Obj1 As Reflector
	If AntiAliasing Then 
		'If AAstate =True AND AntiAliasing=False Then Return False
		Obj1.Target = BG
		Obj1.Target = Obj1.GetField("paint")
		Obj1.RunMethod2("setAntiAlias", AAstate, "java.lang.boolean")
		IsAAon=AAstate
		'Log("AA=" & AAstate)
		Return AAstate
	End If
End Sub

Sub LoadLCARSize(BG As Canvas)
	Dim NewLeftSide As Int , temp As Int, Lists As LCARlist , Filename As String ,Element As LCARelement 
	If Zoom>0 Then Filename=Zoom
	SetupColors
	LCARCorner.Initialize(File.DirAssets,"test1" & Filename & ".png")
	LCARCornera.Initialize(File.DirAssets,"test1" & Filename & ".gif")
	LCARCornerSlider.Initialize(File.DirAssets,"test2" & Filename & ".png")
	LCARCornerSlidera.Initialize(File.DirAssets,"test2" & Filename & ".gif")
	LoadedFilename= "test1" & Filename
	
	ItemHeight = LCARCorner.Height
	LCARfontheight=ItemHeight*(Fontfactor*0.01)
	If BG=Null Then 
		Dim BMP As Bitmap ,tempBG As Canvas 
		BMP.InitializeMutable(1,1)
		tempBG.Initialize2(BMP)
		BG=tempBG
	End If
	
	Fontsize= API.GetTextHeight(BG, LCARfontheight, "ABC123", LCARfont)  '14+(Zoom*2)
	MinWidth = (LCARCorner.Width*2) + 4 + TextWidth(BG, "YES")
	NumberWhiteSpace=0
	WallpaperService.NeedsRefresh=True
	
	NewLeftSide = LCARCorner.Width+4
	If leftside>0 Then
		For temp = 0 To LCARlists.Size-1
			Lists=LCARlists.Get(temp)
			If Lists.LWidth = leftside Then Lists.LWidth=NewLeftSide
		Next
		For temp = 0 To LCARelements.Size-1
			Element = LCARelements.Get(temp)
			If Element.ElementType = LCAR_Button Then
				If Element.LWidth = leftside Then Element.LWidth = NewLeftSide
				If Element.RWidth = leftside Then Element.RWidth = NewLeftSide
			End If
		Next
	End If
	leftside=NewLeftSide
	IsClean=False
End Sub



Sub NewTheme(Name As String, ColorList As List) As Int
	Dim Theme As ColorTheme , temp As Int 
	Theme.Initialize
	Theme.ColorCount=ColorList.Size 
	For temp=0 To ColorList.Size -1
		Theme.ColorList(temp) = ColorList.Get(temp)
	Next
	ThemeList.Add(Theme)
	Return ThemeList.Size -1
End Sub
Sub ChangeTheme(Index As Int)
	CurrentTheme = ThemeList.Get(Index)
	CTindex = Index
End Sub



Sub LoadPicture(Filename As String, Dir As String)As Int 
	Dim temp As LCARpicture, Index As Int 
	Index=FindPicture(Filename,Dir)
	If Index>-1 Then Return Index 
	temp.Initialize 
	temp.Name = Filename 
	If Dir.Length = 0 Then Dir = File.DirAssets
	temp.Dir = Dir 
	temp.Picture.Initialize(Dir,Filename)
	PictureList.Add(temp)
	Return PictureList.Size-1
End Sub
Sub FindPicture(Filename As String, Dir As String) As Int
	Dim temp As Int ,Picture As LCARpicture 
	If Dir.Length = 0 Then Dir = File.DirAssets
	For temp = 0 To PictureList.Size-1
		Picture = PictureList.Get(temp)
		If Picture.Name=Filename Then
			If Picture.Dir = Dir Then Return temp
		End If
	Next
	Return -1
End Sub

Sub IsToastVisible(BG As Canvas, Resize As Boolean ) As Int
	If VolSeconds >0 Or VolOpacity >0 Then
		If VolText.Length = 0 Then
			Return 1'is volume
		Else
			If BG <> Null And Resize Then SizeToast(BG, VolText.Replace(" " & CRLF , " ").ToUpperCase)
			Return 2'is text
		End If
	End If
	If VolTextList.Size>0 Then Return 3'has text queued
End Sub

Sub ToastImage(BG As Canvas, Filename As String, Seconds As Int)
	DontHide=false 
	HideToast'("ToastImage")
	CurrentStyle = ImageToast
	ToastMessage(BG, Filename,Seconds)
End Sub 
Sub ToastMessage(BG As Canvas, Text As String, Seconds As Int)
	Dim temp As LCARtimer  'VolOpacity VolOpacity
	If Text.Length>0 Then
		Log("TOAST: " & Text)
		If VolSeconds >0 Or VolOpacity >0 Or Not( BGisInit ) Then'the toast is visible, push it onto the stack
			temp.Initialize 
			temp.Name = Text
			temp.Duration = Seconds
			VolTextList.Add(temp)
			'Log("Pushed onto stack " & VolSeconds & " " & VolOpacity & " " & BGisInit)
		Else
			VolSeconds=(1000/VolInc)*Seconds
			SizeToast(BG,Text)
		End If
	End If
End Sub

Sub GetStyleFont(Style As Int) As Typeface
	If Style=-1 Then Style = CurrentStyle
	Select Case Style
		Case -Klingon:		Return LCARSeffects2.KlingonFont
		Case LCAR_ENT:		Return LCARSeffects2.PCARfont
		Case LCAR_TOS: 		Return TOSFont
		Case Klingon: 		If Not(Games.UT) Then Return LCARSeffects2.KlingonFont
		Case LCAR_TMP:		Return LCARSeffects2.starshipfont 
		Case ChronowerX:	Return LCARSeffects3.CHX_Font
		Case StarWars: 	
			If Not(LCARSeffects3.SWFont.IsInitialized) Then LCARSeffects3.SWFont = Typeface.LoadFromAssets("starwars.ttf")
			Return LCARSeffects3.SWFont 
		Case BattleStar
			If Not(LCARSeffects4.DRD_Font.IsInitialized) Then LCARSeffects4.DRD_Font = Typeface.LoadFromAssets("dradis.ttf")
			Return LCARSeffects4.DRD_Font 
		Case EVENT_Horizon:	Return Typeface.DEFAULT_BOLD 
		Case -Romulan, Romulan
			If Not(ROMfont.IsInitialized) Then ROMfont=Typeface.LoadFromAssets("rom.ttf")
			If Not(Games.UT) Or Style=-Romulan Then Return ROMfont
		Case FreedomWars: 	Return Typeface.DEFAULT 
		Case Cardassian:	Return Wireframe.CardassianFont
		Case tCARS:			Return Wireframe.TCARSfont
		Case BORG:			Return BorgFont 
	End Select
	Return LCARfont
End Sub
Sub SizeToast(BG As Canvas,Text As String)
	Dim MaxWidth As Int, Font As Typeface', Style As Int = CurrentStyle
	If Text.StartsWith("GSF") Then
		MaxWidth = Text.IndexOf(":")
		If MaxWidth>3 Then
			CurrentStyle = Text.SubString2(3 ,MaxWidth)
			Text = Text.SubString2(MaxWidth+1, Text.Length)
		End If
	End If
		
	Font=GetStyleFont(CurrentStyle)
	Select Case CurrentStyle
		Case FreedomWars:	 	MaxWidth = Min(ScaleHeight * 0.94, ScaleWidth) * 0.84
		Case Else: 				
			MaxWidth = ScaleWidth-50' Min(ScaleWidth,ScaleHeight)-50
			Text=Text.ToUpperCase 
	End Select
	If CurrentStyle = Klingon Or CurrentStyle = -Klingon Then
		VolText=Text.ToUpperCase
	Else If Text.Contains(":") Then
		VolText= API.TextWrap(BG, Font, Fontsize, API.GetSide(Text, ":", True, False), MaxWidth) & ":" & API.TextWrap(BG, Font, Fontsize, API.GetSide(Text, ":", False, False), MaxWidth)
	Else
		VolText= API.TextWrap(BG, Font, Fontsize, Text, MaxWidth)
	End If
	If VolText.Contains(CRLF) Then
		MaxWidth= API.CountInstances(VolText,CRLF)'  (Regex.Matcher(CRLF, VolText).GroupCount+1)
		'Log(MaxWidth & " returns in " & VolText)
	Else
		MaxWidth=1
	End If
	VolDimensions=Trig.SetPoint(API.TextWidthAtHeight(BG,Font,VolText,Fontsize),  TextHeight(BG, "TEST")*MaxWidth + API.IIF(MaxWidth=1, 0,2))
End Sub
Sub PullNextToast(BG As Canvas)
	Dim temp As LCARtimer
	If VolSeconds=0 And VolOpacity=0 Then
		If VolTextList.Size =0 Then
			VolText=""
		Else 'If VolTextList.Size>0 Then
			temp = VolTextList.Get(0)
			'Log("pulled: " & temp.Name)
			ToastMessage(BG, temp.Name, temp.Duration )
			VolTextList.RemoveAt(0)
		End If
	End If
End Sub

Sub EnumFiles(ListID As Int, Dir As String, Ext As String)
	Dim temp As Int, Files As List = File.ListFiles(Dir), tempstr As String 
	For temp = 0 To Files.Size-1
		tempstr = Files.Get(temp)
		If tempstr.ToLowerCase.EndsWith(Ext) Then
			LCAR_AddListItem(ListID,   API.GetSide(tempstr, ".", True, False), LCAR_Random, -1,  File.Combine(Dir, tempstr), False, API.getside(tempstr, ".", False, False), 0, False,-1)
		End If
	Next
End Sub


Sub PlaySoundAnyway(Index As Int)
	'Dim temp As Boolean 
	'temp=Mute
	'Log("PlaySoundAnyway: " & Index)
	'Mute=False
	'MP.SetVolume(1,1)
	DontCancel=False 
	API.SetVolume(True, Index<0, "Playsoundanyway " & Index)
	PlaySound(Abs(Index),False)
	'MP.SetVolume(1,1)
	'Mute=temp
End Sub

Sub EnumSounds(ListID As Int)
	Dim temp As Int ,Sound As LCARSound 
	'lcar_clearlist(listid,0)
	For temp=0 To SoundList.Size-1
		Sound = SoundList.Get(temp)
		LCAR_AddListItem(ListID, Sound.Name , LCAR_Random, File.Size(Sound.Dir, Sound.Filename)  , Sound.Filename ,False, "", 0, False,-1)
	Next
End Sub


Sub cVol As Int
	Dim P As Phone, Channel As Int = P.VOLUME_MUSIC
	Return Round(P.GetVolume(Channel) / P.GetMaxVolume(Channel) * 100)
End Sub
Sub SetVolume(Percent As Float)
	Dim P As Phone, Channel As Int = P.VOLUME_MUSIC
	P.SetVolume(Channel, Percent * P.GetMaxVolume(Channel),False)
End Sub
Sub Volume(Value As Int, ShowToast As Boolean )As Int 
	'Dim temp As Double = Value*0.01 
	If API.AllowVolumeAccess Then 
		If Value = -999 Then
			Mute = Not(Mute)
			Value = API.IIF(Mute,0,cVol)
		End If
		If Value<0 Then Value=0
		If Value>100 Then Value=100
		If Value=0 Then 
			Mute=True
			Stop("VOL0")
		Else 
			Mute=False
			'If MP.IsPlaying Then  MP.SetVolume(temp, temp)
		End If
		SetVolume( Value * 0.01 )
		
		
		'temp=Value*0.01
		'MP.SetVolume(temp,temp)
		'MP2.SetVolume(temp,temp)
		'If PlayID>-1 Then SP.SetVolume(PlayID, Value*0.01, Value*0.01)
		If ShowToast Then
			'VolOpacity=255
			If IsToastVisible(Null,False)<>1 Then HideToast'("Volume")
			VolSeconds=VolVisible
	'	Else
	'		Log("Volume: " & Value)
		End If
		'cVol = Value
	End If
	Return cVol
End Sub

Sub SetVol(Direction As Boolean)As Boolean 
	Dim temp As Int ,RetVal As Boolean 
	'If API.CheckLock Then Return True
	temp = cVol
	'Log("Looping: " & Looping & " " & NeedsResuming)
	'Log("VOL: " & (cVol+ API.IIF(Direction, 10,-10)))
	RetVal=Volume(cVol+ API.IIF(Direction, 10,-10), True) <> temp
	If Direction And temp = 0 Then CheckResumeSound
	Return True' RetVal
End Sub

Sub IsPlaying As Boolean 
	Return MP.IsPlaying 'OR MP2.IsPlaying  'OR PlayID>-1
End Sub 
Sub Stop(Why As String)
	If DontCancel Then
		Log("CANT CANCEL")
		Return False 
	End If
	'Log("STOP: " & Why)
	Looping=-1
	MP.Stop 
	If ResetVol Then 
		API.SetVolume(False,False,"STOP")' Volume(cVol,False)
		ResetVol=False
	End If
	'MP2.Stop 
	'If PlayID>-1 Then 
	'	SP.Stop (PlayID)
	'	SP.Unload(PlayID)
	'	PlayID=-1
	'End If
End Sub
Sub Stop2(Why As String)
	NeedsResuming = Looping
	Stop("STOP2: " & Why)
End Sub
Sub CheckResumeSound
	If NeedsResuming>-1 Then PlaySound(NeedsResuming,True)
End Sub

'if dir is empty, it'll use the assets/defaultexternal dir
Sub PlaySoundFile(Dir As String, Filename As String, doLoop As Boolean ) As Boolean 
	If Not(Filename.Contains(".")) Then 
		If File.Exists(Dir, Filename & ".mp3") Then 
			Filename = Filename & ".mp3"
		else if File.Exists(Dir, Filename & ".ogg") Then 
			Filename = Filename & ".ogg"
		Else if File.Exists(Dir, Filename & ".wav") Then 
			Filename = Filename & ".wav"
		End If 
	End If
	Dim temp As Int = FindSound(Filename)
	If temp =-1 Then temp = AddSound("temp", Filename,Dir)
	Stop("PLAY SND FL")
	If temp>-1 Then
		PlaySound( temp, doLoop)	
	Else
		Log(Filename & " not found")
	End If
	Return temp > -1
End Sub

Sub PlaySound2(Name As String, doLoop As Boolean) As Boolean 
	Dim temp As Int = FindSound(Name)
	LogColor("Playsound: " & temp, Colors.Blue )
	If temp>-1 Then PlaySound(temp, doLoop)
End Sub
Sub PlaySound(Index As Int, doLoop As Boolean )As Boolean 
	Dim temp As Float, WasPlayingSound As Boolean = MP.IsPlaying
	If Index < SoundList.Size And Index >-1 Then'Not(Mute) And 
		If WasPlayingSound Then
			If (WasPlaying<>Looping) And Not(doLoop) Then Return False'prevent interuptions
			If DontCancel Then Return False 
			Stop("PLAY SOUND NOT LOCKED")
		End If
		'If Index<0 Then Index = Rnd(0, SoundList.Size)
		If doLoop Then 
			Looping = Index
			NeedsResuming=Index
		Else
			NeedsResuming=-1
		End If
		CurrSound = SoundList.Get(Index)
		WasPlaying=Index
'		If CurrSound.UseSoundPool>0 Then
'		'	PlayID=SP.Load(Sound.Dir, Sound.Filename)
'		'	SP.Play(PlayID, cVol*0.01,  cVol*0.01, 9999,-1,1)
'			MP2.Load(CurrSound.Dir, CurrSound.Filename)
'		End If
		'Else
		Try
			MP.Load(CurrSound.Dir, CurrSound.Filename)
			temp=1
			If STimer.Headset_Plug Then temp = hVol*0.01
			'Log("Playing sound " & CurrSound.Filename & " at " & temp)
			MP.SetVolume(temp,temp)
			MP.Looping=doLoop 'AND (CurrSound.UseSoundPool=0)
			If API.IsBluetoothHeadsetOn And Not(WasPlayingSound) Then 
				CallSubDelayed(Main, "DelayedPlay")
			Else 
				MP.Play 
			End If
			
			DontCancel = False 
			'MP.Looping=doLoop
			'Log(ResetVol)
		'End If
		Catch
			Return False
		End Try
		Return True
	End If
End Sub

Sub CheckLoopingSound()
	Dim Clicked As ElementClicked
	If WasPlaying>-1 Then
		If MP.IsPlaying = False Then 'AND MP2.IsPlaying=False Then
			If CurrSound.Length=0 Then CurrSound.Length = MP.Position 
			If Looping=WasPlaying Then'AND CurrSound.UseSoundPool>0 Then
				'MP.Position=0
				'MP.Play 
				'MP.Looping=True
				'Log("SKIPPING LOOP")
			Else
				'Log("SHOULD PLAY OLD " & Looping)
				Clicked.ElementType = LCAR_StoppedPlaying
				Clicked.Index = WasPlaying
				Clicked.Index2= MP.Position 
				Clicked.Index3= Looping
				WasPlaying=-1
				EventList.Add(Clicked)
				'Log("ResetVol: " & ResetVol)
				If Looping>-1 Then	
					PlaySound(Looping,True)
				Else
					If ResetVol Then API.SetVolume(False,False,"Check looping")' Volume(cVol,False)
				End If
			End If
'		Else If CurrSound.UseSoundPool>0 Then
'			CheckSound(MP,MP2)
'			CheckSound(MP2,MP)
		End If
	End If
End Sub
'Sub CheckSound(MP1 As MediaPlayer, aMP2 As MediaPlayer)
'	If MP1.IsPlaying AND MP1.Position>= CurrSound.UseSoundPool Then 
'		If aMP2.IsPlaying Then
'			If aMP2.Position>0 Then
'				MP1.Pause 
'				MP1.Position=0
'			End If
'		Else
'			aMP2.Play  
'		End If
'	End If
'End Sub
Sub GetSound(Index As Int) As LCARSound 
	Return SoundList.Get(Index)
End Sub
Sub FindSound(Name As String) As Int
	Dim temp As Int,Sound As LCARSound 
	'If dir.Length = 0 Then dir = File.DirAssets
	For temp = 0 To SoundList.Size-1
		Sound=SoundList.Get(temp)
		If Sound.Name.EqualsIgnoreCase(Name) Then Return temp
	Next
	Return -1
End Sub
Sub AddSound(Name As String , Filename As String, Dir As String)As Int 
	Dim Sound As LCARSound,temp As Int 
	temp=FindSound(Name)
	If Dir.Length = 0 Then 
		If File.Exists(File.DirAssets, Filename) Then
			Dir = File.DirAssets
		Else If File.Exists(DirDefaultExternal, Filename) Then
			Dir = DirDefaultExternal
		Else
			Return -1
		End If
	End If
	If temp>-1 Then 	
		Sound = SoundList.Get(temp)
		Sound.Filename=Filename
		Sound.Dir =Dir 
		Return temp
	End If
	Sound.Initialize 
	Sound.Name = Name
	Sound.Filename = Filename
	Sound.Dir = Dir
	SoundList.Add(Sound)
	Return SoundList.Size-1
End Sub'1610
Sub SetSoundLength(SoundID As Int, Length As Int)
	Dim Sound As LCARSound 
	Sound=SoundList.Get(SoundID) 
	Sound.Length=Length
End Sub

'Sub SetSoundPool(SoundID As Int, UseSoundPool As Int)
'	Dim Sound As LCARSound 
'	Sound=SoundList.Get(SoundID) 
'	Sound.UseSoundPool=UseSoundPool
'End Sub
Sub GetColorFlat2(ColorID As Int, State As Boolean, Alpha As Int) As Int 
	Dim temp As LCARColor = GetColorFlat(ColorID, State, Alpha)
	Return Colors.RGB(temp.nR, temp.nG, temp.nB)
End Sub
Sub GetColorFlat(ColorID As Int, State As Boolean, Alpha As Int) As LCARColor 
	Dim temp As LCARColor = LCARcolors.Get(ColorID), temp2 As LCARColor , Factor As Double = Alpha/255
	temp2.Initialize 
	temp2.nR = API.IIF(State, temp.sr, temp.nR) * Factor
	temp2.nG = API.IIF(State, temp.sg, temp.ng) * Factor
	temp2.nB = API.IIF(State, temp.sb, temp.nb) * Factor
	temp2.Normal = Colors.RGB(temp2.nR,temp2.ng,temp2.nb)
	Return temp2
End Sub
Sub GetColor2(ColorID As Int, State As Boolean) As Int
	Return GetColor(ColorID,State,255)
End Sub
Sub GetColor(ColorID As Int, State As Boolean, Alpha As Int)As Int
	Dim Color As LCARColor ,temp As Int
	If ColorID>= LCARcolors.Size Or ColorID<-5 Then 
		Return ColorID'ColorID= LCAR_Orange
	Else
		If RedAlert And ColorID< LCAR_White And ColorID>LCAR_Black Then
			If State Then ColorID= LCAR_RedAlert Else ColorID = RedAlertMode'
		End If
		If ColorID<0 Then ColorID=CurrentTheme.ColorList( Abs(ColorID)-1)
		Color = LCARcolors.Get(ColorID)
		If Alpha<0 Then
			Alpha=Abs(Alpha)
			If State Then 
				If ColorID = RedAlertMode Then 'LCAR_RedAlert Then
					temp=Min(255,256-Alpha)
					Return Colors.RGB(temp,temp,temp)
				Else
					Return Colors.RGB( Min(Color.sR+Alpha,255), Min(Color.sG+Alpha,255), Min(Color.SB+Alpha,255))
				End If
			Else
				Return Colors.RGB( Min(Color.nR+Alpha,255), Min(Color.nG+Alpha,255), Min(Color.nB+Alpha,255))
			End If
		Else If Alpha<255 Then
			If State Then 
				Return Colors.ARGB(Alpha, Color.sR, Color.sG, Color.SB ) 
			Else
				Return Colors.ARGB(Alpha, Color.nR, Color.nG, Color.nB ) 
			End If
		Else 
			If State Then
				Return Color.Selected 
			Else 
				Return Color.Normal 
			End If
		End If
	End If
End Sub

'align: 0=left, 1=center, 2=right
Sub DrawText2(BG As Canvas,X As Int, Y As Int, Textsize As Int, Text As String, Color As Int, Align As Int) As Int 
	BG.DrawText(Text,X, Y + BG.MeasureStringHeight(Text,LCARfont,Textsize), LCARfont, Textsize,Color, API.IIFIndex(Align, Array As String("LEFT", "CENTER", "RIGHT")))
	Return BG.MeasureStringwidth(Text,LCARfont, Textsize)
End Sub
Sub DrawText(BG As Canvas, X As Int,  Y As Int, Text As String, ColorID As Int, Align As Int,State As Boolean, Alpha As Int, Off As Int  )As Boolean 
	Dim Alignment As String  ,temp As Int, tempstr() As String ,doBG As Boolean ,Width As Int , theFont As Typeface = LCARfont
	If Text=Null Then Return False
	If Text.Length>0 Then
		ColorID=GetColor(ColorID, State,Alpha)
		doBG=Off<0
		If Text.StartsWith("GSF") Then
			temp = Text.IndexOf(":")
			If temp>3 Then
				Alignment = Text.SubString2(3 ,temp)
				theFont = GetStyleFont(Alignment)
				Text = Text.SubString2(temp+1, Text.Length)
			End If
		End If
		
		If doBG Then Width=BG.MeasureStringWidth(Text,theFont,Fontsize)+1
		If Off <1 Then Off=BG.MeasureStringHeight("ABC123",theFont,Fontsize)'      Text,LCARfont,Fontsize)'+1'   TextHeight(BG, "ABC123")+1'bg.MeasureStringHeight(text,lcarfont,fontsize)'LCARfontheight+1'
		
		Select Case Align
			Case 0,1,4,7
				Alignment = "LEFT"
				If doBG Then BG.DrawRect(SetRect(X,Y, Width+1, Off+1), Colors.Black, True,0)
			Case 2,5,8
				Alignment = "CENTER"
				If doBG Then BG.DrawRect(SetRect(X-Width*0.5,Y, Width+1, Off+1), Colors.Black, True,0)
			Case 3,6,9
				Alignment = "RIGHT"
				If doBG Then BG.DrawRect(SetRect(X-Width,Y, Width+1, Off+1), Colors.Black, True,0)
			Case Else
				Return False'invalid alignment, prevent crashing
		End Select
		
		Text=Text.Replace("\n", CRLF)
		If Text.Contains(CRLF) Then
			tempstr= Regex.Split(CRLF, Text)
			For temp = 0 To tempstr.Length -1
				BG.DrawText(tempstr(temp).Trim,X,Y +Off, theFont, Fontsize,ColorID, Alignment)
				Y=Y+Off
			Next
		Else
			BG.DrawText(Text,X,Y +Off, theFont, Fontsize,ColorID, Alignment)
		End If
	End If
End Sub

Sub TextHeight(BG As Canvas, Text As String)As Int 
	Return API.TextHeightAtHeight(BG, LCARfont, Text,Fontsize)
End Sub
Sub TextWidth(BG As Canvas, Text As String) As Int
	Return API.TextWidthAtHeight(BG,LCARfont,  Text, Fontsize)
End Sub

Sub GetARGB(Color As Int) As Int()
    Dim res(4) As Int
    res(0) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)
    res(1) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)
    res(2) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)
    res(3) = Bit.And(Color, 0xff)
    Return res
End Sub

Sub LCAR_RandomColor2(CurrentColorID As Int) As Int
	Dim temp As Int = LCAR_RandomColor
	Do While temp = CurrentColorID 
		temp = LCAR_RandomColor
	Loop
	Return temp
End Sub
Sub LCAR_RandomColor As Int'5 6 11
	'LCARcolors.Size-2
	Return Rnd(1, 12)'doesnt include black (0) or redalert (LCARcolors.Size-1), or white (LCARcolors.Size-2)
End Sub

Sub LCAR_RandomUnusedColor(ListID As Int, ExcludeBlack As Boolean ) As Int
	Dim TempList As LCARlist, TempItem As LCARlistitem, temp As Int, temp2 As Int, UsedColors As List 
	UsedColors.Initialize 
	For temp = 0 To LCARcolors.Size-1
		UsedColors.Add(False)
	Next
	If ExcludeBlack Then UsedColors.Set(LCAR_Black,True)
	UsedColors.Set(LCAR_RedAlert,True)
	
	TempList= GetList(ListID)
	For temp = 0 To TempList.ListItems.Size-1
		TempItem = TempList.ListItems.Get(temp)
		UsedColors.Set( TempItem.ColorID, True)
	Next
	
	For temp = 0 To LCARcolors.Size-1
		If UsedColors.Get(temp) Then temp2 = temp2+1
	Next

	If temp2 = LCARcolors.Size Then
		Return -1'all colors are used
	Else
		temp=Rnd(0, LCARcolors.Size)
		Do While UsedColors.Get(temp)
			temp=Rnd(0, LCARcolors.Size)
		Loop
		Return temp
	End If
End Sub

Sub FindLCARcolor(Name As String) As Int 
	Dim temp As Int, tempColor As LCARColor
	For temp = 0 To LCARcolors.Size-1
		tempColor = LCARcolors.Get(temp)
		If tempColor.Name.EqualsIgnoreCase(Name) Then Return temp
	Next
	Return -1
End Sub
Sub AddLCARcolor(Name As String, R As Int,G As Int, B As Int, Brightness As Int ) As Int 
	Dim temp As LCARColor ,temp2 As Int
	temp2=FindLCARcolor(Name)
	If temp2=-1 Then
		temp.Initialize 
		temp.Name = Name
		temp.Normal = Colors.ARGB(255,R,G,B)
		temp.nR=R:temp.nG=G:temp.nB=B 
		If R=0 And G=0 And B=0 Then
			temp.Selected = temp.Normal 
			temp.sR=R:temp.sG=G:temp.SB=B
		Else If Brightness<0 Then'red/blue alert
			temp.Selected = Colors.White 
			temp.sR=255:temp.sG=255:temp.SB=255
		Else
			temp.sR=Min(R+Brightness,255):temp.sG= Min(G+Brightness,255):temp.SB=Min(B+Brightness,255)
			temp.Selected = Colors.RGB(temp.sR, temp.sG,temp.SB )
		End If
		LCARcolors.Add(temp)
		Return LCARcolors.Size -1
	Else
		Return temp2
	End If
End Sub

Sub GetRealSize(Height As Boolean)As Int 
	Dim Model As String = API.Model(1).ToLowerCase
	If Model.StartsWith(API.getstring("sovereign_class")) Then Return 1920
	If Model.StartsWith("nexus 6") Then Return 2560
	
	Return API.RealHeight' Max(GetDeviceLayoutValues.Height, GetDeviceLayoutValues.Width) + 48dip
End Sub

Sub SetupLCARcolors(Act As Activity)As Boolean 
	Dim temp As Int, Lists As LCARlist, Ret As Boolean 
	Ret = SetupTheVariables
	ScaleWidth = Act.Width
	ScaleHeight = Act.Height 
	
	If API.FullscreenMode Then 
		If ScaleHeight > ScaleWidth Then 'portrait 
			ScaleHeight = GetRealSize(True)' Act.Height
			Act.Height = ScaleHeight
		Else 
			ScaleWidth = GetRealSize(False)' Act.Height
			Act.Width = ScaleWidth
		End If 
	End If
	
	ScaleWidth = ScaleWidth - OverscanX*2 
	ScaleHeight = ScaleHeight - OverscanY*2
	LogColor("Setting up: " & ScaleWidth & " x " & ScaleHeight & " " & API.FullscreenMode & " " & GetDeviceLayoutValues.Width & " x " & GetDeviceLayoutValues.Height, Colors.Magenta)
	
	If Max(ScaleHeight,ScaleWidth)>=1700 Then LargeScreen = True
	LCARSeffects.CacheAngles( Min(ScaleWidth,ScaleHeight)*2,-1)
	Landscape= ScaleWidth>ScaleHeight
	CurrentVersion=API.model(5)
	For temp =0 To LCARlists.Size-1
		Lists = LCARlists.Get(temp)
		Lists.RedX=0
		Lists.RedY=0
		LCARlists.Set(temp,Lists)
	Next
	IsClean=False
	If VolDimensions.IsInitialized And VolText.Length>0 Then
		If Act.Width < VolDimensions.X Then 
			HideToast'("SetupLCARcolors " & Act.Width & " < " & VolDimensions.X )
		End If
	End If
	SetupColors
	Return Ret
End Sub
Sub SetupColors As Boolean 
	Dim DB As Int
	If Not(LCARcolors.IsInitialized)  Then	
		DB=64
		If Landscape Then BiggestHeight = ScaleWidth Else BiggestHeight=ScaleHeight
		WasPlaying=-1
		Looping=-1
		LCARfont = Typeface.LoadFromAssets("lcars.ttf")
		TOSFont =Typeface.DEFAULT '_BOLD '  =Typeface.LoadFromAssets("tos.ttf")
		LCARSeffects2.StarshipFont=Typeface.LoadFromAssets("federation.ttf")   
		LCARSeffects2.PCARfont = Typeface.LoadFromAssets("precars.ttf")
		LCARSeffects3.CHX_Font = Typeface.LoadFromAssets("chicago.ttf")
		LCARcolors.Initialize
		LCAR_Black = AddLCARcolor("Black",0,0,0, DB )						'0	checked manually
		
		LCAR_DarkOrange = AddLCARcolor("Dark Orange", 215, 107, 0, DB)		'1	checked
		LCAR_Orange = AddLCARcolor("Orange", 253,153,0, DB) 				'2	checked
		LCAR_LightOrange = AddLCARcolor("Light Orange", 255, 255, 0, DB*2)	'3	checked
		LCAR_Purple = AddLCARcolor("Purple", 255,0,255, DB*2)				'4	checked
		LCAR_LightPurple = AddLCARcolor("Light Purple", 204,153,204, DB)	'5
		LCAR_LightBlue = AddLCARcolor("Light Blue", 153,153,204, DB)		'6
		LCAR_Red = AddLCARcolor("Red", 204,102,102, DB)						'7	checked
		LCAR_Yellow = AddLCARcolor("Yellow", 255,255,0, DB*2)				'8	checked
		LCAR_DarkBlue = AddLCARcolor("Dark Blue", 153,153,255, DB)			'9	checked
		LCAR_DarkYellow = AddLCARcolor("Dark Yellow", 255,153,102, DB)		'10	checked
		LCAR_DarkPurple = AddLCARcolor("Dark Purple", 204,102,153, DB)		'11
		LCAR_White = AddLCARcolor("White", 255,255,255, DB*2)				'12 checked
		
		LCAR_RedAlert = AddLCARcolor("Red Alert", 204,102,102, -DB)			'13	checked manually
		
		Classic_Yellow = AddLCARcolor("Light Green", 152,255,102, DB)		'14
		Classic_Green = AddLCARcolor("Green", 6,138,3, DB)					'15
		Classic_LightBlue=AddLCARcolor("Lighter Blue",153,205,255,DB)		'16
		Classic_Blue = AddLCARcolor("Blue", 0,0,254, DB)					'17
		Classic_Turq = AddLCARcolor("Turq", 76,232,185, DB)					'18
		Classic_Red=  AddLCARcolor("Classic Red", 223,83,36, DB)			'19
		
		LCAR_Grey = AddLCARcolor("Grey", 128,128,128,128)					'20
		LCAR_Blue= AddLCARcolor("LBlue", 158,193,225, DB)					'21
		LCAR_LightYellow= AddLCARcolor("Light Yellow", 225,239,160, DB*2)	'22
		
		BORG_Color = AddLCARcolor("BORG", 0, 120,0, 64)						'23
		
		LCAR_Chrono = AddLCARcolor("Chrono" , 15,65,124 , DB)				'24
		
		TCAR_DarkTurquoise = AddLCARcolor("tDark Turq" , 45,191,228, DB)	'25
		TCAR_LightTurquoise = AddLCARcolor("tLight Turq" , 61,249,234, DB*2)'26
		TCAR_Yellow = AddLCARcolor("tYellow" , 199,198,106, DB)				'27
		TCAR_Orange = AddLCARcolor("tOrange" , 188,163,123, DB)				'28
		TCAR_DarkOrange = AddLCARcolor("tDark Orange" , 147,173,172, DB)	'29
		TCAR_DarkPurple = AddLCARcolor("tDarkPurple" , 55,78,158, DB)		'30
		TCAR_LightPurple = AddLCARcolor("tLightPurple" , 112,144,201, DB)	'31
		
		NewTheme("TNG", Array As Int(LCAR_LightPurple,LCAR_DarkPurple,LCAR_Orange,LCAR_Red,LCAR_LightOrange))
		ChangeTheme(0)
		
		Return True
	End If
End Sub

Sub FindTheme(Name As String) As Int
	Dim temp As Int, Theme As ColorTheme 
	For temp = 0 To ThemeList.Size-1
		Theme=ThemeList.Get(temp)
		If Theme.Name.EqualsIgnoreCase(Name) Then Return temp 
	Next
	Return -1
End Sub 

Sub ProcessScale(X As Int, Width As Int) As Int 
	If X>MAXDIM Then' is above maximum X, so scale to width by percent
		Return ((X-MAXDIM)*0.01)*Width
	Else If X<MINDIM Then'is below minimum X so scale to width by percent
		Return ((X+MINDIM)*0.01)*Width
	End If
	Return X
End Sub

Sub ProcessLocX(X As Int, Off As Int, Width As Int, IsWidth As Int )As Int 
	Dim temp As Int 
	temp=ProcessScale(X , Width)

	If IsWidth>0 Then'is a width/height
		If temp<=0 Then 
			temp = Width+temp -IsWidth
		'Else If smallscreen Then 
		'	temp=temp*0.5
		End If
	Else'is an x/y
		If temp<0 Then
			temp = Width+temp 
		'Else If smallscreen Then 
		'	temp=temp*0.5
		End If
	End If	
	Return temp+Off
End Sub

Sub ProcessLoc(LOC As tween, Size As tween) As tween 
	Dim temp As tween 'OverscanX OverscanY
	If LOC<> Null And Size <> Null Then
		temp.Initialize 
		temp.currX=ProcessLocX( LOC.currX , LOC.offX, ScaleWidth,0 )'X/left
		temp.curry=ProcessLocX( LOC.curry, LOC.offy, ScaleHeight,0 )'Y/top
		temp.offX = ProcessLocX( Size.currX , Size.offX, ScaleWidth,temp.currX)'-temp.currX'width
		temp.offy=ProcessLocX( Size.curry , Size.offy, ScaleHeight,temp.curry)'-temp.curry'height
		
		temp.currX=temp.currX+OverscanX
		temp.curry=temp.curry+OverscanY
		Return temp
	End If
End Sub
Sub ProcessLoc2(LOC As tween, Size As tween) As tween
	Dim temp As tween ,Height As Int ,tempX As Int ,tempY As Int
	If LOC<> Null And Size <> Null Then
		Height=WallpaperService.msdHeight-WallpaperService.top-WallpaperService.bottom
		temp.Initialize 
		tempX=ProcessLocX( LOC.currX , LOC.offX,	WallpaperService.msdWidth 		,0 )
		tempY=ProcessLocX( LOC.curry , LOC.offy,		Height		,0 )
		temp.currX=-WallpaperService.X2 + tempX'X/left
		temp.curry=WallpaperService.TOP+ tempY'Y/top
		temp.offX = ProcessLocX( Size.currX , Size.offX, 						WallpaperService.msdWidth		,tempX)'-temp.currX'width
		temp.offy=ProcessLocX( Size.curry , Size.offy,							Height		,tempY)'-temp.curry'height
		Return temp
	End If
End Sub

Sub NeedsClearing As Boolean 
	Return ElementMoving Or Not(IsClean) Or ListIsMoving 
End Sub 

Sub BlankScreen(BG As Canvas)
	If BGisInit And Not(BG=Null) Then BG.Drawcolor(Colors.Black)'LCAR.DrawRect(BG,0,0,LCAR.ScaleWidth,LCAR.ScaleHeight,Colors.Black,0)
End Sub
Sub ClearScreen(BG As Canvas )
	If Not(ClearLocked) Then
		IsClean=False
		'If BG<> Null Then 	BG.Drawcolor(Colors.Black)
		IsAAon=False
		CurrListID=-1
	End If
End Sub

Sub SetSensorXY(LCARid As Int, Xpercent As Int, Ypercent As Int, ScaleToNeg As Boolean )
	Dim Element As LCARelement
	Element = LCARelements.Get(LCARid)
	If Element.Visible Then
		Element.IsClean=False
		If ScaleToNeg Then
			Xpercent= 50 + Xpercent*0.5
			Ypercent=50 + Ypercent*0.5
		End If
		Element.align= Xpercent
		Element.TextAlign=Ypercent
		'Log("X: " & Xpercent & " Y: " & Ypercent)
		LCARelements.Set(LCARid, Element)
	End If
End Sub

Sub IncrementSensorX(LCARid As Int, RWidth As Int, Z As Int)
	Dim Element As LCARelement
	Element = LCARelements.Get(LCARid)
	Element.RWidth = Increment(Element.RWidth, 5, RWidth)
	Element.align = Increment(Element.align, 5, Z)
	'Log(LCARid & " X: " & RWidth & " Z: " & Z)
	LCARelements.Set(LCARid, Element)
End Sub

Sub SetGraphPercent(ListID As Int, ListItems As List)
	Dim Lists As LCARlist , ListItem As LCARlistitem ,temp As Int ,Index As Int, Percent As Int
	If LCARVisibleLists.Get(ListID) Then
		Lists = LCARlists.Get(ListID)
	'If lists.Visible Then
		Lists.IsClean = False
		For temp = 0 To ListItems.Size-1 Step 2
			Index=ListItems.Get(temp)
			Percent=ListItems.Get(temp+1)
			'Log("I: " & index & " P: " & percent)
			ListItem=Lists.ListItems.Get(Index)
			ListItem.IsClean=False
			ListItem.Number=Abs(Percent)
		
			Lists.ListItems.Set(Index,ListItem)
		Next
		LCARlists.Set(ListID, Lists)
	End If
End Sub

Sub IncrementLOC(LOC As tween,Speed As Int, BothAxis As Boolean) As Boolean 
	Dim Didit As Boolean 
	If LOC.offX <> 0 Then 
		LOC.offX = Increment(LOC.offX, Speed,0)
		Didit=True
	End If 
	If Didit And Not(BothAxis) Then Return True
	If LOC.offy <> 0 Then	
		LOC.offy = Increment(LOC.offy, Speed,0)
		Didit=True
	End If
	Return Didit
End Sub
Sub IncrementElement(ElementID As Int, Element As LCARelement,Speed As Int, SpeedSlider As Int ) As Boolean 
	Dim  Didit As Boolean , Didit2 As Boolean , Didit3 As Boolean ,Old As Int
	'DIDIT:  if resized, moved, or alpha changed
	'DIDIT2: if either
	'DIDIT3: if special incremented, but stays dirty
	
	If Element.Visible Then'AND group.Visible Then
		'move on 1 axis at a time
		If Element.LOC.offX <> 0 Then 
			Element.LOC.offX = Increment(Element.LOC.offX, Speed,0)
			Didit = True	
		Else If Element.LOC.offy <> 0 Then	
			Element.LOC.offy = Increment(Element.LOC.offy, Speed,0)
			Didit=True
		End If
		
		'resize
		If (Element.Size.offX <> 0) Or (Element.Size.offy <> 0) Then
			Element.Size.offX = Increment(Element.Size.offX, Speed,0)
			Element.Size.offy = Increment(Element.Size.offy, Speed,0)
			Didit=True
		End If
		
		'alpha
		If Element.Opacity.Current <> Element.Opacity.Desired Then
			If AlphaBlending Then 
				Element.Opacity.Current = Increment(Element.Opacity.Current, Alphaspeed,Element.Opacity.Desired)
			Else
				Element.Opacity.Current = Element.Opacity.Desired
			End If
			If Element.Opacity.Current = 0 Then  Element.Visible = False 
			Didit=True
		End If	

		Select Case Element.ElementType 
			Case LCAR_Button, LCAR_Elbow
				If NewSecond Then 
					If Element.SideText = LCAR_RandomText Then
						Element.Text = LCARSeffects6.RandomNumber(Element.Tag)
						Didit3= True 
					End If
				End If 
			
			Case LCAR_Navigation
				If Element.RWidth<-90 Or Element.RWidth>90 Then
					Element.LWidth= Element.LWidth-1
					If Element.LWidth<1 Then Element.LWidth= LCARSeffects.NAVMAXDISTANCE
				Else
					Element.LWidth= Element.LWidth+1
					If Element.LWidth>LCARSeffects.NAVMAXDISTANCE Then Element.LWidth= 0
				End If
				Didit3= True 
			
			Case SBALLS_Plaid
				Element.LWidth= Element.LWidth+1
				If Element.LWidth>LCARSeffects.NAVMAXDISTANCE Then Element.LWidth= 0
				Element.RWidth = Element.RWidth+5
				If Element.RWidth>359 Then Element.RWidth=0
				Didit3= True 
			
			Case SWARS_Targeting
				Element.LWidth= Element.LWidth+1
				If Element.LWidth>LCARSeffects.NAVMAXDISTANCE Then Element.LWidth= 0
				Element.RWidth=Max(Element.RWidth-1,0)
				If Element.RWidth=0 Then Element.TextAlign = 1-Element.TextAlign
				Didit3= True 	
			
			Case LCAR_3Dmodel
				Didit3=Wireframe.IncrementElement(Element, ElementID)
			
			Case LCAR_Cards
				Didit3= Games.CARD_IncrementCards
				
			Case Q_net
				Didit3 = LCARSeffects5.IncrementQnet 
				
			Case LCAR_Meter, LCAR_Slider,LCAR_HorSlider, LCAR_Tactical, ENT_Meter, TMP_Meter', LCAR_Chart
				Old=Element.LWidth
				Element.LWidth=Increment(Element.LWidth, SpeedSlider, Element.RWidth)
				If Old <> Element.LWidth Then 
					Didit3= True 
					If Element.RespondToAll And ElementID>-1 Then PushEvent(Element.ElementType , ElementID, Element.LWidth- Old,0,0,0,0, Event_Scroll)
				Else
					If Element.TextAlign= LCAR_Random Or Element.ElementType = TMP_Meter Then
						Didit3=True
						Element.RWidth = Rnd(0,101)
					End If
				End If
				
			Case LCAR_SensorGrid
				Element.LWidth = Increment(Element.LWidth, SpeedSensor, Element.align)
				Element.rWidth = Increment(Element.rWidth, SpeedSensor, Element.TextAlign)
				If Not(IsNumber(Element.Tag)) Then Element.Tag= "0"
				Element.Tag= Increment(Element.Tag, SpeedSensor, 360) 'uncomment
				If Element.Tag=360 Then Element.Tag = 0
				If Element.Enabled Then
					If Element.LWidth = Element.Align Then Element.Align = Rnd(5,96)
					If Element.rWidth = Element.TextAlign Then Element.TextAlign = Rnd(5,96)
				End If
				'Log("SENSOR GRID: " & Element.LWidth & " " & Element.rWidth & " " & Element.Tag)
				Didit3=True
				
			Case LCAR_Textbox,TMP_Text
				If Element.SideText.Length>0 And Element.Opacity.Current>0 Then
					Element.Text = Element.Text & Element.SideText.SubString2(0,1)'typewriter effect
					Element.SideText = Element.SideText.SubString(1)
					Didit3=True
				End If
			
			Case LCAR_Borg
				Element.LWidth=Element.LWidth+2
				If Element.LWidth>359 Then Element.LWidth = 0
				LCARSeffects2.IncrementNumbers
				Didit3=True
				Didit2=True
				Didit=True
				IsClean=False
				
			Case BORG_Borg
				Didit3 = LCARSeffects6.IncrementBorg(Element)
				
			Case FER_Ticker
				Didit3 = LCARSeffects7.IncrementFerengi(Element)
				
			Case LCAR_Alert, AIR_Alart, TMP_Alert
				Element.rWidth=Element.rWidth+1
				If Element.RWidth = LCARSeffects.OkudaStages Then Element.rWidth=0
				Didit3=True
			
			Case LCAR_Matrix
				LCARSeffects2.LE_IncrementMatrix
				Didit3=True
			
			Case LCAR_StarBase' LCAR_Starships
				If LCARSeffects2.IncrementStarships Then	Didit3=True
			
			Case LCAR_Graph
				'LCARSeffects2.IncrementGraph(Element.TextAlign, Element.Align)
				If Not(LCARSeffects2.isGraphClean(Element.TextAlign)) Then Didit3=True
			
			Case LCAR_Tactical2
				Element.LWidth = Element.LWidth-1 
				If Element.LWidth<1 Then
					Didit3 = LCARSeffects5.IncrementTactical(Element.Align)
					Element.LWidth = Element.RWidth
				End If
			
			Case LCAR_Engineering,BTTF_Flux,TMP_Engineering
				'If MP.IsPlaying Or Element.RWidth=1 Or Element.ElementType = TMP_Engineering Then 'MP.IsPlaying Or
					didIncrementNumbers=True
					LCARSeffects2.IncrementNumbers
					Element.LWidth = Element.LWidth + 1 'MP.Position / CurrSound.Length * LCARSeffects2.MaxStages 
					If Element.LWidth = LCARSeffects2.MaxStages*2  Then Element.LWidth=0
					'Log("Stage: " & Element.LWidth & "POS: " & MP.Position & " LEN: " & CurrSound.Length & " %: " & (MP.Position / CurrSound.Length))
					LightpackIndex = Element.LWidth/ (LCARSeffects2.MaxStages*2-1) * 6
					Didit3=True
				'End If
			
			Case LCAR_MultiSpectral
				Didit3 = LCARSeffects2.AssimilateNewData(True)
			
			Case LCAR_ShieldStatus
				Pulse(Element,LCARSeffects.MaxShieldStages)
				If Element.TextAlign>-1 Then Element.TextAlign = (Element.TextAlign + 10) Mod 360
				Didit3=True
			
			Case LCAR_Static
				Pulse(Element,16)
				Didit3=True
				
			Case Klingon_Frame
				If Element.rwidth =-1 And Not(Games.Paused) Or Element.rwidth>-1 Then
					Element.Lwidth=Element.LWidth+1
					If Element.LWidth >= LCARSeffects2.MaxKcycles Then Element.LWidth= 0
					If Element.rwidth =-1 Then Games.TRI_IncrementAll
					Didit3=True
				End If
			
			Case LCAR_PdP
				Didit3=Games.PDPHandleMouse(0,0,-1,Element.Lwidth)
				
			Case LCAR_PdPSelector
				If Games.PDPSelectedColor <> Games.PDPWasSelected Then
					Games.PDPWasSelected = Games.PDPSelectedColor
					Didit3=True
				End If
			
			Case TOS_Moires
				Element.Align = (Element.Align+1) 'Mod 360
				If Element.Align > 89 Then
					Element.Align = Element.Align Mod 90
					Element.TextAlign = Element.TextAlign + 1
					If Element.TextAlign >= LCARSeffects2.MoireOffsets Then Element.TextAlign = 0
				End If
				Didit3=True
			
			Case Legacy_Sonar
				didIncrementNumbers=True
				Didit3=LCARSeffects2.IncrementPhotonicSonar
			
			Case LCAR_RndNumbers, ENT_RndNumbers, TMP_RndNumbers
				If Not(didIncrementNumbers) Then 
					didIncrementNumbers=True
					Didit3 = LCARSeffects2.IncrementNumbers
				Else
					Didit3=didIncrementNumbers
				End If
				
			Case LCAR_PToE
				If LCARSeffects2.PToEHandleMouse(0,0, LCAR_Timer) Then
					Didit3=True
					Element.LWidth = (Element.LWidth +1) Mod 120
				End If
				
			Case LCAR_List
				Didit2 = IncrementList( Element.LWidth, Speed,SpeedSlider) 
			
			Case LCAR_WarpCore
				Element.LWidth= Element.LWidth+1
				If Element.LWidth>6 Then Element.LWidth=0
				LightpackIndex = Element.LWidth
				Didit3=True
				
			Case LCAR_ShuttleBay
				If Element.LWidth=0 Then LCARSeffects2.IncrementShuttles 
				Didit3=True
				
			Case LCAR_LWP
				If Element.LWidth=-1 Then
					If LWPUnlocked Or DateTime.Now  >= WallpaperService.LastUpdate + WallpaperService.Delay Then 
						Didit3= True
						WallpaperService.DoIncrement=True
					End If
				Else 
					Didit3 = LCARSeffects2.IncrementCustomElement(Element)
				End If
			
			Case LCAR_ASquare
				Element.LWidth=(Element.LWidth+1) Mod LCARSeffects2.MaxSquareStages
				Didit= True
				
			Case LCAR_Starfield
				Didit3 = LCARSeffects3.IncrementStars(True)
			
			Case LCAR_Answer
				Old=2
				Select Case Element.LWidth
					Case -2'false/red and larson red
						Element.RWidth=Element.RWidth-Old
						If Element.RWidth<0 Then 
							Element.RWidth=0 'Element.RWidth+Old
							Element.LWidth=-1
							Rumble(Element.align)
							PushEvent(LCAR_Answer,ElementID, -1, 0,0,0,0, Event_Down)
						End If
					Case -1'true/green and larson green
						Element.RWidth=Element.RWidth+Old
						If Element.RWidth>100 Then
							Element.RWidth=100'Element.RWidth-Old
							Element.LWidth=-2
							Rumble(Element.align)
							PushEvent(LCAR_Answer,ElementID, -2, 0,0,0,0, Event_Down)
						End If
				End Select
				Didit= True
				Didit3=True
				
			Case LCAR_Science
				Element.RWidth=(Element.RWidth+1) Mod 32
				Didit3=True
			
			Case TMP_3Dwave
				Element.LWidth=(Element.LWidth+1) Mod 360
				Didit3=True
				
			Case LCAR_Frame
				If RedAlert Then
					Old=DateTime.GetSecond(DateTime.Now)*10 + API.IIF((DateTime.Now Mod 1000) >500,1,0)
					If Old <> Element.TextAlign Then'Element.Align
						Element.RWidth=Element.RWidth+1' Mod 6
						If Element.RWidth>5 Then Element.RWidth=0
						Element.TextAlign=Old
						Didit3=True
					End If
				Else If Element.RWidth> 0 Then
					Element.RWidth=0
				End If
			
			Case LCAR_Metaphasic
				Element.LWidth=Element.LWidth+1
				If Element.LWidth >= LCARSeffects3.MaxStages Then
					Element.LWidth=0
					Element.RWidth=Element.RWidth+1
					If Element.RWidth=5 Then Element.RWidth=3
				End If
				Didit3=True
			
			Case VOY_Tricorder
				Element.ColorID=0
				If Element.LWidth <> Element.RWidth Then
					Element.ColorID=1
					Element.LWidth = Increment(Element.LWidth, LCARSeffects4.Tri_Speed, Element.RWidth)
				End If
				Didit3=True
			
			Case LCAR_DNA
				Didit3 = LCARSeffects6.IncrementDNA(Element)
				
			'TWOK/TMP game
			Case TMP_Reliant
				If LCARSeffects3.IncrementReliant(ElementID,Element) Then Didit3=True
				LCARSeffects3.IncrementViewscreen(False)
				
			Case TMP_FireControl 
				LCARSeffects3.IncrementViewscreen(False)
				Didit3=True
				Didit= True
			
			Case LCAR_ThreeDGame 
				Didit3=Games.ThD_Increment 
				If Element.LWidth>0 Then
					Element.LWidth=Element.LWidth-1 
					If Element.LWidth = 0 Then Games.ThD_HandleAI 
					Didit3=True
				End If
			
			Case ENT_Planets
				Didit3=True
			
			Case ENT_Radar
				Didit3=True
				Element.LWidth = Element.LWidth + 1
				Element.RWidth = Element.RWidth + 2
				Element.Align = Element.Align + 5
			
			Case ENT_Sin
				Didit3=True
				If Element.RWidth > 0 Then
					Element.Align = (Element.Align + 1) Mod Element.RWidth
					If Element.Tag.Length=0 Then Element.tag = Element.LWidth 
					Element.LWidth= Increment(Element.LWidth, 5, Element.TextAlign)
					If Element.LWidth = Element.textalign Then Element.textalign = API.IIF(Element.LWidth = 0, Element.Tag,0)
				End If 
				
			Case ENT_Graph
				Didit3 = True
				If Element.SideText.Length = 0 Then
					If Element.TextAlign = 0 Then Element.TextAlign = 10
					Element.SideText = LCARSeffects5.NewGraph(Element.TextAlign*2)
				Else
					Element.Align = Element.Align + 10
					If Element.Align > 99 Then 
						Element.Align =0
						Element.SideText = LCARSeffects5.NewGraph2(Element.SideText)'Element.Align
					End If
				End If
			
			Case CRD_Shatter
				LCARSeffects5.IncrementCardy(Element.Align)
				Didit3=True
				
			Case LCAR_UFP
				Didit3=LCARSeffects6.IncrementUFPlogo(Element)
				'Element.LWidth = (Element.LWidth + 1) Mod 360
				
				
			'Chronowerx OS
			Case CHX_Logo:		If LCARSeffects3.CHX_IncLogo(5) 					Then Didit3=True
			Case CHX_Iconbar:	If LCARSeffects3.CHX_IncIconbar(Element) 			Then Didit3=True
			Case CHX_Window
				If Element.Opacity.Current=Element.Opacity.Desired Then
					If LCARSeffects3.CHX_IncWindow(ElementID, Element) 	Then Didit3=True
				End If
				
			'Battlestar Gallactica
			Case DRD_Matrix
				LCARSeffects4.IncrementCylon
				Didit3=True
				Didit= True
				
			Case MSC_Sheliak
				Didit3 = LCARSeffects5.IncrementSheliak 	
				
			Case CRD_Main
				Element.LWidth = 0
				Didit3 = True
				
			Case EVENT_Horizon
				Didit3= LCARSeffects4.ResetEventHorizon(Null, -1)
				
			Case LCAR_Widget
				Element.Opacity.Current=Element.Opacity.Desired
			
			Case TOS_Button
				Didit3 = LCARSeffects3.IncrementTOSbutton(Element)
				
			Case LCAR_WarpField
				LCARSeffects2.IncrementNumbers
				Didit3 = LCARSeffects5.IncrementWarpField(Element) 
				
			Case LCAR_Plasma
				Didit3 = LCARSeffects6.IncrementPlasma

			Case MSC_Hacking
				Didit3 = Wireframe.IncrementCubes(Element)
				
			Case DrP_Board
				Didit3 = Games.Incement_DrPulaski(ElementID) 
					
			Case TCAR_Main
				Didit3 = Wireframe.IncrementTCARS(Element)
						
		End Select
	
		If Didit Or Didit3 Then
			Element.IsClean = False
			'LCARelements.Set(ElementID,Element)
			If Didit And Not(Element.Async) Then Didit2=True  
			'isclean=False
		End If
		
	End If
	Return Didit2
End Sub
Sub IncrementList(ListID As Int, Speed As Int, SpeedSlider As Int)As Boolean 
	Dim ListItem As LCARlistitem , didit As Boolean , didit2 As Boolean, didit3 As Boolean ,Lists As LCARlist
	If LCARlists.Size <= ListID Then Return False
		Lists= LCARlists.Get(ListID)
	'If lists.IsInitialized Then
				Lists.Visible = True
				'alpha
				If Lists.Opacity.Current <> Lists.Opacity.Desired Then
					If AlphaBlending Then 
						Lists.Opacity.Current = Increment(Lists.Opacity.Current, Alphaspeed,Lists.Opacity.Desired)
					Else 
						Lists.Opacity.Current =Lists.Opacity.Desired
					End If
					If Lists.Opacity.Current = 0 Then 
						LCARVisibleLists.Set(ListID,False)
						Lists.Visible = False 
						If VisibleList = ListID Then VisibleList=-1
					End If
					didit=True	
				End If	
				'cleanup
				If Lists.Visible And Lists.Opacity.Current=0 Then 
					Lists.visible=False
					LCARVisibleLists.Set(ListID,False)
					didit=True
				End If
			
				'move on 1 axis at a time
				If Lists.LOC.offX <> 0 Then 
					Lists.LOC.offX = Increment(Lists.LOC.offX, Speed,0)
					didit = True	
				Else If Lists.LOC.offy <> 0 Then	
					Lists.LOC.offy = Increment(Lists.LOC.offy, Speed,0)
					didit=True
				End If
				
				'size
				If (Lists.Size.offX <>0) Or (Lists.Size.offy <> 0) Then
					Lists.Size.offX = Increment(Lists.Size.offX, Speed,0)
					Lists.Size.offy = Increment(Lists.Size.offy, Speed,0)
					didit=True
				End If
				
				'items
				Select Case Lists.Style 
					Case LCAR_Button'Normal, GNDN
					Case LCAR_Chart, LCAR_Meter'Chart, '1=Chart ShowNumber=true randomizes item Numbers when = whitespace, Number=Desired Percent, WhiteSpace=Current Percent
						For temp2 = 0 To Lists.ListItems.Size-1
							ListItem = Lists.ListItems.Get(temp2)

							ListItem.WhiteSpace= Increment(ListItem.WhiteSpace,SpeedSlider,ListItem.Number)	
							If Lists.ShowNumber And ListItem.Number = ListItem.WhiteSpace Then ListItem.Number = Rnd(0,101)
							
							Lists.ListItems.Set(temp2,ListItem)
						Next
						didit3=True
						ListIsMoving=True
							
					Case LCAR_Analysis
						LCARSeffects2.IncrementAnalysisList(Lists,1)
						didit3=True
						ListIsMoving=True
				End Select
				
				If didit Or didit3 Then 
					Lists.IsClean = False
					'LCARlists.Set(temp,Lists)
					If didit And Not (Lists.Async) Then didit2=True  
					Lists.IsClean=False
				End If
			
			'Else
			'	Log("List " & temp & " is not initialized")
			'End If
			Return didit2
End Sub
Sub IncrementLCARs(Speed As Int, SpeedSlider As Int, Interval As Int )
	Dim Element As LCARelement ,Didit As Boolean ,Didit2 As Boolean ,Didit3 As Boolean ,Old As Int ,WasMoving As Boolean ,Clicked As ElementClicked ,Lists As LCARlist 
	Dim temp2 As Int,  temp As Int ,temp2 As Int, Group As LCARgroup,ElementID As Int
	ListIsMoving=False
	WasMoving = ElementMoving
	ElementMoving=True
	didIncrementNumbers=False
	If LargeScreen Then Speed=Speed*2 
	
	For temp=0 To LCARlists.Size-1
		Didit=False
		'If lists.Visible Then
		If LCARVisibleLists.Get(temp) Then
			If IncrementList(temp, Speed,SpeedSlider) Then Didit2=True
		End If
	Next
	
	For temp = 0 To  LCARGroups.Size-1
		Group= LCARGroups.Get(temp)
		If Group.Visible Then
			'Log("original size: " & Group.LCARlist.Size)
			For temp2= Group.LCARlist.Size-1 To 0 Step -1
				If temp2< Group.LCARlist.Size Then
					ElementID = Group.LCARlist.Get(temp2)
					If ElementID < LCARelements.Size Then
						Element= LCARelements.Get(ElementID)
						If IncrementElement(ElementID, Element, Speed, SpeedSlider) Then Didit2=True
					Else
						'RemoveLCARfromGroup(ElementID,temp2)
					End If
				End If
			Next
		End If
	Next

	If Not(Didit2) Then 
		ElementMoving = False 
		'isclean=False
		If WasMoving Then 
			Clicked.ElementType = LCAR_StoppedMoving
			Clicked.Index = Stage
			EventList.Add(Clicked)
		End If
	End If
	
	CheckLoopingSound
	
	If VolSeconds>0 Then
		VolOpacity = Increment(VolOpacity,16,255)
	Else If VolOpacity>0 Then
		If VolSeconds=0 Then
			VolOpacity = Increment(VolOpacity,16,0)
			If VolOpacity=0 Then 
				PushEvent(LCAR_ToastDone,0,0,0,0,0,0, Event_Down)
				If SpecialToast Then 
					If MP.Looping Then Stop("SPC. TOAST")  
					CurrentStyle = LCAR_TNG
				End If
			End If
		End If
	End If
	
	If TimerPeriod >0 Then
		If MinTimer = 0 Then 
			MinTimer = DateTime.Now 
		Else
			temp = DateTime.Now - MinTimer 
			If temp> TimerPeriod Then
				MinTimer = MinTimer + (Floor(temp / TimerPeriod)*TimerPeriod)
				temp = DateTime.Now - MinTimer 
			End If
			PushEvent(LCAR_TimerIncrement , -1, temp ,-1,0,0,0,0)
		End If
	End If
	
	Select Case CurrentStyle 
		Case LCAR_ENT 
			LCARSeffects3.IncrementENT
	End Select
End Sub
Sub StartMicroTimer(Period As Int)
	If Period=0 Then
		MinTimer=0
	Else
		MinTimer = DateTime.Now 
	End If
	TimerPeriod=Period
End Sub

Sub Pulse(Element As LCARelement, Maximum As Int)
	If Element.RWidth=0 Then
		Element.Lwidth=Element.Lwidth+1
		If Element.Lwidth = Maximum Then 
			Element.Lwidth=Maximum-1
			Element.RWidth=1
		End If
	Else
		Element.Lwidth=Element.Lwidth-1
		If Element.Lwidth = 0 Then Element.RWidth=0
	End If
End Sub

Sub Increment(X As Int, Speed As Int, Neutral As Int) As Int
	If X=Neutral Then
		Return Neutral
	Else If X<Neutral Then
		If X+Speed<Neutral Then Return X+Speed Else Return Neutral
	Else If X>Neutral Then
		If X-Speed>Neutral Then Return X-Speed Else Return Neutral
	End If
End Sub

Sub SetLRwidth(ElementID As Int, Lwidth As Int, Rwidth As Int)
	Dim temp As LCARelement=LCAR_GetElement(ElementID)
	temp.Lwidth=Lwidth
	temp.Rwidth=Rwidth
	temp.IsClean=False
End Sub

Sub SetAsync(Element As Int, IsList As Boolean )
	Dim temp As LCARelement,temp2 As LCARlist 
	If IsList Then
		temp2=LCARlists.Get(Element)
		temp2.Async=True
		'LCARlists.Set(Element,temp2)
	Else
		temp=LCAR_GetElement(Element)
		temp.Async=True
		'LCARelements.Set(Element, temp)
	End If
End Sub
Sub SetAlignment(ListID As Int, Alignment As Int)
	Dim temp As LCARlist 
	temp = LCARlists.Get(ListID)
	temp.Alignment = Alignment
	temp.IsClean=False
	'LCARlists.Set(ListID,temp)
End Sub

Sub ClearLRwidths(ListID As Int)
	Dim Lists As LCARlist 
	Lists = LCARlists.Get(ListID)
	Lists.LWidth=0
	Lists.RWidth=0
	'LCARlists.Set(ListID,Lists)
End Sub

Sub LockListStart(ListID As Int, State As Boolean)As Int 
	Dim Lists As LCARlist 
	Lists = LCARlists.Get(ListID)
	Lists.Locked=State
	Return ListID
	'LCARlists.Set(ListID,Lists)
End Sub

Sub GetListItemHeight(Lists As LCARlist) As Int   
	Dim Dimensions As tween, Cols As Int, ColWidth As Int 
	Select Case Lists.Style 
		Case LCAR_Meter, LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List, TMP_Switch, CHX_Iconbar
			Dimensions = ProcessLoc(Lists.LOC, Lists.Size)
	End Select
	Select Case Lists.Style 
		Case LCAR_Button,TMP_Numbers: Return ItemHeight+ListitemWhiteSpace
		Case LCAR_Chart, LCAR_ChartNeg: Return ChartHeight + ChartSpace
		Case ENT_Button: Return (50*ScaleFactor)+ ListitemWhiteSpace	
		Case LCAR_Meter		
			ColWidth=(ChartSpace + MeterWidth)
			Cols=Floor( Dimensions.offX  / ColWidth)
			If Lists.ListItems.Size > Cols Then Return Dimensions.offY  / Ceil(Lists.ListItems.Size / Cols)' Else Return Dimensions.offY 
		Case TMP_Switch
			Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
			ColWidth=Dimensions.offX/ Cols
			Return ColWidth*1.333333333
		'Case LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List, CHX_Iconbar: Return Dimensions.offY 
	End Select
	Return Dimensions.offY 
End Sub
Sub NotMoving(ListID As Int)
	Dim Lists As LCARlist= LCARlists.Get(ListID) , HalfItemHeight As Int = GetListItemHeight(Lists) * 0.5
	If SmoothScrolling And Lists.isScrolling And Not(Lists.Locked) Then 
		'Log(Lists.Offset & " " & HalfItemHeight & " " & Lists.Start)
		If Abs(Lists.Offset) < HalfItemHeight Then Lists.Start = Max(0,Min(Lists.ListItems.Size-1, Lists.start-1))
	End If
	Lists.isScrolling=False
	Lists.Offset=0
	Lists.IsClean=False
	Lists.Ydown=0
	'LCARlists.Set(ListID,Lists)
End Sub


Sub MoveList(ListID As Int, X As Int, Y As Int)
	Dim Lists As LCARlist
	Lists = LCARlists.Get(ListID)
	Lists.LOC.currX=X
	Lists.LOC.currY=Y
	Lists.IsClean=False
	'LCARlists.Set(ListID, Lists)
End Sub

'if Rwidth is -1, ignore. If Width or Height = -999, ignore
Sub ResizeList(ListID As Int, Width As Int, Height As Int, Rwidth As Int, X As Int, Y As Int, Move As Boolean )As Boolean 
	Dim Lists As LCARlist , Element As LCARelement , Size As tween , LOC As tween ,Visible As Boolean 
	If ListID < LCARlists.Size Then
		Lists = LCARlists.Get(ListID)
		Size=Lists.Size 
		LOC=Lists.LOC
		If Rwidth=-2 Then
			Visible=Element.Visible 
		Else 
			Visible=LCARVisibleLists.Get(ListID)  'lists.Visible 
		End If 
	Else
		Return False
	End If
	
	If Visible Then 
		If Width > -999 Then 
			If Width>-1 Then Size.offX= Size.currX - Width
			Size.currX = Width
		End If 
		If Height > -999 Then 
			If Height>-1 Then Size.offy= Size.curry - Height
			Size.curry = Height
		End If 
		If Move Then
			LOC.offX=LOC.currX - X
			LOC.offY=LOC.currY - Y
			LOC.currX=X
			LOC.currY=Y
		End If
	Else
		Size.offX=0
		Size.offY=0
		If Width > -999 Then Size.currx=Width
		If Height > -999 Then Size.curry=Height
		If Move Then
			LOC.currX=X
			LOC.currY=Y
			LOC.offX=0
			LOC.offY=0
		End If
	End If
	
	If Rwidth=-2 Then
		Element.Size=Size
		Element.LOC = LOC
	Else
		Lists.Size = Size
		Lists.LOC=LOC
		If Rwidth>-1 Then Lists.Rwidth = Rwidth
	End If
	Return True
End Sub

Sub MoveLCAR(LCARid As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, DoXY As Boolean , DoWH As Boolean , DoAlpha As Boolean )As Boolean 
	Dim Element As LCARelement  ,Group As LCARgroup 
	Element = LCARelements.Get(LCARid)
	Group= LCARGroups.Get( Element.Group )
	ElementMoving=True
	If DoXY Then
		If Element.Visible And Group.Visible Then
			Element.LOC.currX = ProcessScale(Element.LOC.currX, ScaleWidth)
			Element.LOC.currY = ProcessScale(Element.LOC.currY, ScaleHeight)
			If X<0 And Element.LOC.currX >0 Then Element.LOC.currX=-ScaleWidth + Element.LOC.currX'normalize
			If Y<0 And Element.LOC.currY >0 Then Element.LOC.currY=-ScaleHeight + Element.LOC.currY'normalize
			Element.LOC.offX= Element.LOC.currX - X
			Element.LOC.offy= Element.LOC.curry - Y
			Element.LOC.currX=X
			Element.LOC.curry=Y
		Else
			Element.LOC.currX=X
			Element.LOC.currY=Y
			Element.LOC.offX=0
			Element.LOC.offY=0
		End If
	End If
	If DoWH Then
		If Element.Visible And Group.Visible Then
		
		Else
			Element.size.currX=Width
			Element.size.currY=Height
			Element.size.offX=0
			Element.size.offY=0
		End If
	End If
	
	If DoAlpha Then 
		Element.Opacity.Desired=Alpha
		Element.Visible = True
	End If
	'LCARelements.Set(LCARid,Element)
	If Element.LOC.offX <> 0 And Element.LOC.offy<>0 Then Return True
End Sub

Sub GetListHeight(ListID As Int)As Int 
	Dim Lists As LCARlist,Cols As Int ,RowHeight As Int ,ItemsPerCol As Int, Dimensions As tween 
	Lists= LCARlists.Get(ListID) 
	Select Case Lists.Style 
		Case 0'normal
			Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
			RowHeight= ItemHeight+ListitemWhiteSpace
			ItemsPerCol= LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
			If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
		Case LCAR_Chart, LCAR_ChartNeg
			RowHeight=ChartHeight + ChartSpace
			ItemsPerCol=Lists.ListItems.Size
		Case LCAR_Meter
			Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
			Return Dimensions.offY 		
	End Select
	Return RowHeight*ItemsPerCol
End Sub

Sub FindClickedElement(SurfaceID As Int, X As Int, Y As Int, GetIndex As Boolean ) As ElementClicked
	Dim temp As Int,temp2 As Int, Element As LCARelement, ElementID As Int, Dimensions As tween ,Group As LCARgroup, ReturnValue As ElementClicked,Lists As LCARlist , SideRect As Rect , TopRect As Rect ,Found As Boolean 
	Dim Cols As Int ,ItemsPerCol As Int ,Start As Int ,RowHeight As Int, ColWidth As Int 

	ReturnValue.Initialize
	ReturnValue.Index=-1
	
	If SurfaceID<0 Then Start= Abs(SurfaceID+1) Else Start = LCARlists.Size-1
	

	
	If ReturnValue.Index=-1 Then' not(found) 
		For temp =Start To 0 Step -1'  Start To LCARlists.Size-1
			If LCARVisibleLists.Get(temp) And (Lists.SurfaceID = SurfaceID Or SurfaceID<0) Then' lists.Visible
				Lists= LCARlists.Get(temp) 
				Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
				If IsWithin(X,Y, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, False) Then
					
					ReturnValue.Index=temp
					ReturnValue.ElementType= LCAR_List
					ReturnValue.X = X-Dimensions.currX
					ReturnValue.Y = Y-Dimensions.curry
					
					
					Select Case Lists.Style 
						Case LCAR_Button,TMP_Numbers'normal
							Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
							ColWidth=Dimensions.offX/ Cols
							RowHeight= ItemHeight+ListitemWhiteSpace
							ItemsPerCol= LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
							If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
						Case LCAR_Chart, LCAR_ChartNeg
							Cols=1
							ColWidth= Dimensions.offX 
							RowHeight=ChartHeight + ChartSpace
							ItemsPerCol=Lists.ListItems.Size
						Case LCAR_Meter
							ColWidth=(ChartSpace + MeterWidth)
							Cols=Floor( Dimensions.offX  / ColWidth)
							ItemsPerCol=Cols
							RowHeight=Dimensions.offY 
							If Lists.ListItems.Size > Cols Then RowHeight= RowHeight / Ceil(Lists.ListItems.Size / Cols)
							
							ItemsPerCol=1
						Case ENT_Button
							Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
							ColWidth=Dimensions.offX/ Cols
							RowHeight=(50*ScaleFactor)+ ListitemWhiteSpace
							ItemsPerCol = LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
							If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
						Case LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List
							Cols = Lists.ListItems.Size
							ColWidth=Dimensions.offX/ Cols
							RowHeight=Dimensions.offY 
							ItemsPerCol=1
						Case TMP_Switch
							Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
							ColWidth=Dimensions.offX/ Cols
							RowHeight=ColWidth*1.333333333
						Case CHX_Iconbar 
							Cols = Lists.ListItems.Size 
							ColWidth = Lists.ColsLandscape+ 15
							X=X-Lists.whitespace
					End Select
					
					ReturnValue.X2= Floor(ReturnValue.X/ (Dimensions.offX/ Cols))'COL
					ReturnValue.Y2= Floor(ReturnValue.Y/RowHeight)'ROW
					ReturnValue.Index2=-1'ListItem
					If GetIndex Then 
						Select Case Lists.Style 
							Case LCAR_Button,ENT_Button, LCAR_Chart, LCAR_ChartNeg,TMP_Numbers'normal and ENT
								'ItemsPerCol= lcar_listitemspercol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
								If ReturnValue.Y2 >-1 And ReturnValue.Y2 < Lists.LastMint Then
								'original formula: y = y + .Start + (ItemsPerCol * x)
								
									'Log("X: " & ReturnValue.X2 & " Y: " & ReturnValue.Y2 & " IPC: " & ItemsPerCol)
									'If ReturnValue.Y2<ItemsPerCol Then 
										ReturnValue.Index2 = ReturnValue.Y2 + Lists.Start + ((ItemsPerCol) * ReturnValue.X2)
										temp2  = ReturnValue.Y2 + Lists.Start + ((ItemsPerCol+1) * ReturnValue.X2)
										'Log ("Item: " & ReturnValue.Index2 & " or " & temp2   &  " Row: " & ReturnValue.Y2)
									'End If
									
									'ReturnValue.Index2 = ReturnValue.Y2 + lists.Start + (lists.LastMint * ReturnValue.X2)
									'Log ("START: " & lists.Start  & " ITEMSPERCOL: " & ItemsPerCol)
									'Log(ReturnValue.X2 & ", " & ReturnValue.Y2 & "CLICKED of: " & lists.LastMint & " ITEM: " & ReturnValue.Index2)
								End If
							'Case LCAR_Chart, LCAR_ChartNeg
								'If ReturnValue.Y2>-1 AND ReturnValue.Y2 < Lists.ListItems.Size Then
								'	ReturnValue.Index2 = ReturnValue.Y2
								'End If
							Case LCAR_Meter
								temp2= ReturnValue.X2 + (ReturnValue.Y2*Cols)
								If temp2>-1 And temp2 < Lists.ListItems.Size Then 
									ReturnValue.Index2 = temp2
									ReturnValue.Index3 = (RowHeight - ReturnValue.Y) / RowHeight * 100
									Log(ReturnValue.Y & " " & RowHeight & ": " & ReturnValue.Index3)
								End If
							Case LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List,CHX_Iconbar, EVENT_Horizon , DRD_Timer
								'If Lists.Style = CHX_Iconbar Then '+ API.IIF(Lists.Style = CHX_Iconbar,1,0)
								'	If X < 0 Then ReturnValue.Index2=0 Else ReturnValue.Index2=ReturnValue.X2+1
									ReturnValue.Index2=ReturnValue.X2
							Case TMP_Switch
								ReturnValue.Index2= Lists.Start + (ReturnValue.Y2 * Cols) + ReturnValue.X2
						End Select
					End If
					Exit 'For
					'temp=-1'LCARlists.Size.
					If ReturnValue.Index2 >= Lists.Size  Then ReturnValue.Index2=-1
				End If
			End If
			If SurfaceID<0 Then Exit 'For'temp =-1' LCARlists.Size  
		Next
	End If
	
	'elements
		If SurfaceID>-1 And ReturnValue.Index=-1 Then
		For temp = 0 To LCARGroups.Size-1
			Group = LCARGroups.Get(temp)
			If Group.Visible Then
				For temp2 = Group.LCARlist.Size-1 To 0 Step -1
					ElementID = Group.LCARlist.Get(temp2)
					If ElementID < LCARelements.Size Then
						Element = LCARelements.Get(ElementID)
						If Element.Visible And Element.Opacity.Current>0 And Element.Enabled And (SurfaceID = Element.SurfaceID Or SurfaceID<0) Then
							Dimensions=ProcessLoc( Element.LOC, Element.Size)
							If Element.ElementType = LCAR_Elbow And Element.Align<4 Then
								'If smallscreen Then
								'	element.LWidth=element.LWidth*0.5
								'	element.RWidth=element.RWidth*0.5
								'End If
								Select Case Element.Align
									Case 0,4' |-  top left
										SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Element.LWidth,Dimensions.offY)
										TopRect = SetRect(Dimensions.currX+Element.LWidth-1,Dimensions.currY,Dimensions.offX-Element.LWidth,Element.RWidth)
									Case 1,5'  -| top right
										SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Dimensions.offX,Element.RWidth) 
										TopRect = SetRect(Dimensions.currX+Dimensions.offX-Element.LWidth,Dimensions.currY+Element.RWidth-1,Element.LWidth,Dimensions.offY-Element.RWidth)
									Case 2,6,8' |_  bottom left
										SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Element.LWidth,Dimensions.offY)
										TopRect = SetRect(Dimensions.currX+Element.LWidth-1,Dimensions.currY+Dimensions.offY-Element.RWidth,Dimensions.offX-Element.LWidth,Element.RWidth)
									Case 3,7,9'  _| bottom right
										SideRect =  SetRect(Dimensions.currX+Dimensions.offX-Element.LWidth,Dimensions.currY,Element.LWidth,Dimensions.offY)
										TopRect = SetRect(Dimensions.currX,Dimensions.currY+Dimensions.offY-Element.RWidth,Dimensions.offX-Element.LWidth+1,Element.RWidth)
								End Select
								Found= IsWithin(X,Y, SideRect.Left, SideRect.Top, SideRect.Right ,SideRect.Bottom ,True ) 
								If Not(Found) Then Found = IsWithin(X,Y, TopRect.Left, TopRect.Top, TopRect.Right ,TopRect.Bottom ,True )
							Else
								Found= IsWithin(X,Y, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, False) 
							End If
							If Found Or SurfaceID<0 Then
								ReturnValue.RespondToAll = Element.RespondToAll
								ReturnValue.Index=ElementID
								ReturnValue.ElementType= Element.ElementType
								temp=LCARGroups.Size
								temp2=-1
								ReturnValue.X = X-Dimensions.currX 
								ReturnValue.Y = Y-Dimensions.curry
								Select Case Element.ElementType 
									Case LCAR_PdP: 		ReturnValue.Index2 = Element.LWidth 
									Case CHX_Iconbar:	ReturnValue.Index2 = LCARSeffects3.CHX_IconIndex(ReturnValue.Y, Dimensions.offX, Dimensions.offY )
								End Select
							End If
						End If
					Else
						'removelcarfromgroup(elementid,temp)
					End If
				Next
			End If
		Next
	End If
	
	If ReturnValue.Index>-1 Then ReturnValue.Dimensions = Dimensions
	Return ReturnValue
End Sub


'WidthIncludesX=false, will add width to left to get right. true, will not add it
Sub IsWithin(X As Int, Y As Int, Left As Int, Top As Int, Width As Int, Height As Int, WidthIncludesX As Boolean ) As Boolean 
	If X >= Left Then
		If Y >= Top Then
			If WidthIncludesX Then
				If X<Width Then Return Y<Height
			Else
				If X< Left+Width Then  Return Y<Top+Height
			End If
		End If
	End If
End Sub

Sub IsElementMoving(LOC As tween, Size As tween,Alpha As TweenAlpha  ) As Boolean 
	Return LOC.offX<>0 Or LOC.offY<>0 Or Size.offX<>0 Or Size.offY<>0 Or Alpha.Current <> Alpha.Desired 
End Sub 

Sub ScientificNotation(Number As Int) As Int
	Dim tempstr As String 
	If Number>0 Then
		If Number <10 Then
			Return Number*100
		Else
			tempstr=Number
			Return API.left(tempstr,2) & (tempstr.Length-1)
		End If
	End If
End Sub

Sub DaysInYear(Year As Int) As Int 
	If Year Mod 4 = 0 Then Return 366 Else Return 365
End Sub

'Mode: -2=regular date/time, -1=legacy, 0=accurate stardate, 1=accurate stardate 400 years from now, 2=same as 1, but ignores time zone
Sub Stardate(Mode As Int, theDate As Long, ForceNoon As Boolean, DigitsAfterDecimal As Int)As String 
	Dim Year As Long, Day As Long, Hour As Double,temp As Int , tempstr As String , tempstr2 As String 
	Year = DateTime.GetYear(theDate)
	Select Case Mode
		Case -3
			Return API.DayLabel(theDate,True)
		Case -2'return normal date
			tempstr = API.getDate(theDate)
			Select Case DigitsAfterDecimal
				Case 0: Return tempstr
				Case 1: Return tempstr &  " " & API.TheTime(theDate) 
				Case 2: Return tempstr &  " " & DateTime.Time(theDate)
			End Select
		Case -1'legacy
			Year = (Year - 1923) * 1000
		    Day = DateTime.GetDayOfYear(theDate) /  DaysInYear(DateTime.GetYear(theDate)) * 1000
		    Hour = (DateTime.GetHour(theDate) * 3600 + DateTime.GetMinute(theDate) * 60 + DateTime.GetSecond(theDate) ) / 86400
			If DigitsAfterDecimal>0 Then Hour=Round2(Hour,DigitsAfterDecimal)
			If ForceNoon And Year<0 Then
				tempstr = Year+Day+1-Hour
			Else
				tempstr = Year+Day + Hour
			End If
		Case 0,1,2	'http://sto-forum.perfectworld.com/showpost.php?p=5893581&postcount=10 and http://trekguide.com/Stardates.htm#TNGcalculator
			If Mode = 1 Then	Year=Year+400
			If Mode < 2 Then temp = DateTime.TimeZoneOffset*DateTime.TicksPerHour 
			theDate = API.MakeDate(Year, DateTime.GetMonth(theDate), DateTime.GetDayOfMonth(theDate), DateTime.GetHour(theDate), DateTime.GetMinute(theDate), DateTime.GetSecond(theDate), theDate Mod 1000) - temp
			Year = API.MakeDate(2318,7,5,12,0,0,0)-temp	
			Day = theDate - Year
			Hour = Day / 34367056.4
			Hour = Floor(Hour * 100)
			If Mode = 2 Then 
				theDate = DateTime.GetHour(theDate) * DateTime.TicksPerHour + DateTime.GetMinute(theDate) * DateTime.TicksPerMinute + DateTime.GetSecond(theDate) * DateTime.TicksPerSecond
				temp = (theDate/DateTime.TicksPerDay) * Power(10, DigitsAfterDecimal)
				tempstr = Round(Hour / 100) & "." & temp
			Else 
				tempstr = Round2(Hour / 100,DigitsAfterDecimal)
			End If 
	End Select
	If Mode < 2 Then 
		If DigitsAfterDecimal>0 And Mode>-2 Then
			If tempstr.Contains(".") Then
				tempstr2 = API.GetSide(tempstr, ".",False, False)
				tempstr = API.PadtoLength(tempstr,False,  DigitsAfterDecimal-tempstr2.Length ,"0")
			Else
				tempstr = API.PadtoLength(tempstr & ".",False, tempstr.Length + 1 + DigitsAfterDecimal, "0")
			End If
		Else If tempstr.Contains(".") Then
			tempstr = API.GetSide(tempstr,".",True,False)
		End If
	End If 
	Return tempstr
End Sub

'											lwidth			rwidth
Sub ResizeElbowDimensions(ElementID As Int, BarWidth As Int, BarHeight As Int)
	Dim Element As LCARelement
	Element= LCARelements.Get(ElementID)
		Element.LWidth = BarWidth
		Element.RWidth = BarHeight
	LCARelements.Set(ElementID, Element)
End Sub
Sub IsGroupDown(ElementIsDown As Boolean, GroupID As Int) As Boolean 
	Dim Group As LCARgroup,Element As LCARelement 'Group.Visible 
	If WallpaperService.LCARGroups.IsInitialized And WallpaperService.GroupsEnabled Then
		If GroupID>-1 And GroupID< WallpaperService.LCARGroups.Size Then
			Group = WallpaperService.LCARGroups.Get(GroupID)
			Return Group.Visible 
		Else 'If ElementID>-1 AND ElementID< WallpaperService.LCARelements.Size Then
			'Element = WallpaperService.LCARelements.Get(ElementID) 
			'Return Element.IsDown 
			Return ElementIsDown
		End If
	End If
End Sub
Sub DrawElement(BG As Canvas, SurfaceID As Int, ElementID As Int, istheRedAlert As Boolean )As Boolean 
	Dim Element As LCARelement, Dimensions As tween  ,State As Boolean ,Drew As Boolean ,doAlpha As Boolean , BGC As Int,elementismoving As Boolean, temp As Int, tempstr As String 
	If SurfaceID = -999 Then
		Element = WallpaperService.LCARelements.Get(ElementID)
	Else If ElementID < LCARelements.Size Then
		Element= LCARelements.Get(ElementID)
	End If
	If Element.Visible And (SurfaceID= Element.SurfaceID Or SurfaceID=-1) Then
		'Group= lcargroups.Get(element.Group)
		If Element.Opacity.Current>0  Then
			Drew=True
			If Not( Element.IsClean ) Or Not(IsClean) Then
				elementismoving=IsElementMoving( Element.LOC, Element.Size, Element.Opacity )
				State = Element.IsDown
				If Element.SurfaceID=-999 Then
					Dimensions=ProcessLoc2( Element.LOC, Element.Size)
					If (Dimensions.currX > WallpaperService.PhysicalWidth) Or (Dimensions.currX + Dimensions.offX <0) Then 
						If Element.ElementType = LCAR_Elbow And Element.Align>3 Then
							temp= API.GetTextHeight(BG, Element.LWidth, Element.Text, LCARfont)
							If (Dimensions.currX + Dimensions.offX + BG.MeasureStringWidth(Element.Text, LCARfont, temp) <0) Then Return False
						Else
							Return False
						End If
					End If
					State=IsGroupDown(Element.IsDown, Element.Group) Or Element.IsDown
				Else
					Dimensions=ProcessLoc( Element.LOC, Element.Size)
				End If

				If RedAlert And istheRedAlert Then 
					'If group.LCARlist.Get( group.RedAlert ) = ElementID Then 
					State = True
				Else
					If Element.Blink And BlinkState Then State=True
				End If
				Element.IsClean = True
				
				'Select Case Element.ElementType 
				'	Case LCAR_Alert
				'		ActivateAA(BG,True)
				'	Case LCAR_Button,LCAR_Elbow,LCAR_Slider,LCAR_HorSlider
				'		ActivateAA(BG, DoVector)
				'	Case Else: ActivateAA(BG,False)
				'End Select
				If LCARSeffects2.KlingonVirus Then
					If Element.Tag.Length = 0 Then 
						Select Case Element.ElementType
							Case ENT_Radar, ENT_RndNumbers, ENT_Sin, ENT_Graph
								Element.Tag = LCARSeffects3.RandomKlingonText(BG, Dimensions.offX ,Dimensions.offY)
							Case PCAR_Frame
								If Element.Align = 0 Then Element.Tag = LCARSeffects3.RandomKlingonText(BG, Dimensions.offX ,Dimensions.offY)
							Case ENT_Meter
								Element.Tag = LCARSeffects3.RandomKlingonText(BG, -1,-1)
						End Select 
					End If 
				End If 
				
				Select Case Element.ElementType 
					Case LCAR_Button 
						Select Case Element.Align 
							Case -6:	LCARSeffects5.DrawMiniFrame(BG,Dimensions.currX,Dimensions.currY,  Element.LWidth , Dimensions.offX ,Dimensions.offY, Element.RWidth, Element.Opacity.Current, Element.Text)
							Case 0:		DrawLCARbutton(BG, Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.ColorID, State, Element.Text , Element.SideText  , Element.LWidth , Element.RWidth ,Element.RWidth>0 And Element.SideText.Length=0 , 4, Element.TextAlign, -1, Element.Opacity.Current,elementismoving)
							Case Else:	DrawLCARslantedbutton(BG,Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.ColorID,  Element.Opacity.Current, State, Element.Text ,Element.Align, Element.TextAlign)
						End Select
					Case LCAR_Elbow
						DrawLCARelbow(BG,  Dimensions.currX ,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.LWidth, Element.RWidth , Element.Align , Element.ColorID , State, Element.Text, Element.TextAlign ,Element.Opacity.Current,elementismoving)
						'If element.Opacity.Current < 255 Then DrawLCARelbow(bg,  Dimensions.currX ,Dimensions.currY, Dimensions.offX ,Dimensions.offY , element.LWidth, element.RWidth , element.Align , lcar_black , state, element.Text, element.TextAlign , 255-element.Opacity.Current )
					Case LCAR_Textbox
						If Element.Align>0 Then LCARSeffects.MakeClipPath(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX, Element.Align)
						tempstr=Element.Text
						If tempstr.Contains("%TIME%") Then tempstr = tempstr.Replace("%TIME%", API.GetTimer(Element.Tag))
						DrawLCARtextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, tempstr, Element.ColorID, Element.ColorID, LCAR_LightBlue,State, BlinkState, Element.TextAlign,Element.Opacity.Current )
						If Element.Align>0 Then BG.RemoveClip 
					Case LCAR_Bit
						DrawLCARbit(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, State, Element.Opacity.Current, Element.Align, Element.textalign)
					Case LCAR_MultiLine
						DrawLCARMultiLineTextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Text, Element.ColorID, State, BlinkState, Element.Opacity.Current, Element.TextAlign)
					
					Case LCAR_Slider
						DrawLCARSlider(BG , Dimensions.currX , Dimensions.currY,Dimensions.offY, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current,elementismoving,False)
					Case LCAR_HorSlider
						DrawLCARSlider(BG , Dimensions.currX , Dimensions.currY,Dimensions.offx, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current,elementismoving,True)	
					Case LCAR_Meter
						DrawLCARmeter(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current)
					Case LCAR_SensorGrid
						'Log("DRAW GRID: " & Element.LWidth & " " &  Element.RWidth & " " & Element.Tag)
						DrawLCARSGrid(BG,  Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.LWidth, Element.RWidth, Element.ColorID, Element.Tag)
						doAlpha=Element.Opacity.Current < 255
					Case LCAR_Picture
						'HandleDrawPicture(BG, Dimensions, Element)
						If Element.LWidth=-1 And Element.Text.Length > 0 Then LCARSeffects2.LoadUniversalBMP(Element.SideText, Element.Text, LCAR_Picture)
						DrawLCARPicture(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.LWidth, Element.Align, Element.Opacity.Current, Element.RWidth=1, 0,0,0,0)
					'Case LCAR_Chart
						'DrawLCARchart(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, element.LWidth, element.ColorID, element.Align, element.SideText  , element.Opacity.Current)
					Case LCAR_Dpad
						temp= Min(Dimensions.offX,Dimensions.offY)
						LCARSeffects.DrawDpad(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, temp*0.5, LCAR_LightOrange, temp*LCARSeffects.DpadCenter, Element.ColorID , 2, Element.Opacity.Current , BlinkState, Element.LWidth)
					Case LCAR_Graph
						LCARSeffects2.DrawGraph(Element.TextAlign,  BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.ColorID, Colors.White,  Element.Opacity.Current, Element.Align, Element.LWidth, Element.RWidth)
					Case LCAR_SensorSweep
						LCARSeffects.DrawSensorSweep(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.align, Element.TextAlign )
					Case LCAR_Ruler
						LCARSeffects2.DrawRuler(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current),  Element.Align, Element.TextAlign, Element.LWidth, Element.RWidth) 
					Case LCAR_MultiSpectral
						LCARSeffects2.DrawAllGraphs(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, Element.Opacity.Current, Element.Text)
					Case LCAR_ShieldStatus
						LCARSeffects.DrawShieldStatus(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth,Element.RWidth, Element.ColorID, Element.Opacity.Current, Element.Align, Element.textalign)'align is ship id
					Case LCAR_Static
						LCARSeffects2.DrawStatic(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Dimensions.offX/64,Dimensions.offY/64, Min(255, Element.LWidth*16) )
					Case LCAR_TextButton
						LCARSeffects2.DrawTextButton(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX, Element.LWidth, Element.Align, Element.RWidth, Element.Opacity.Current, State, Element.Text, Element.ColorID, State, Element.Textalign=0, elementismoving)
					Case LCAR_NCC1701D
						LCARSeffects2.DrawEnterprise(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.Align, GetColor(Element.ColorID, State, Element.Opacity.Current))
					Case LCAR_List
						DrawList(BG, -1, Element.LWidth, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY)
					Case LCAR_MiniButton
						LCARSeffects2.DrawLegacyButton(BG, Dimensions.currX, Dimensions.currY, -Dimensions.offX, Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current), Element.Text, Element.TextAlign, 0)
					Case LCAR_Answer
						DrawAnswerSlider(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, ItemHeight,  Element.LWidth, Element.RWidth, Element.Opacity.Current, Element.Text, Element.colorid, Element.SideText, Element.TextAlign)
					Case LCAR_Science
						LCARSeffects3.DrawScienceStation(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.Align, Element.RWidth, Element.ColorID, Element.LWidth, Element.Opacity.Current)
					Case LCAR_Frame
						LCARSeffects3.DrawTNGFrame(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.LWidth, Element.Opacity.Current,Element.RWidth, Element.Align)
					
					'3d effects
					Case LCAR_3Dmodel
						Wireframe.DrawVerteces(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY,  Wireframe.GetModel(Element.Text, Element.SideText), Element.ColorID, State,Element.Opacity.Current,  Element.LWidth, Element.RWidth, Element.TextAlign, True)
					Case TMP_3Dwave
						Wireframe.Draw3Dwave(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.LWidth, Element.ColorID, Element.Align, Element.RWidth, Element.TextAlign) 
						
					'Novelties
					Case LCAR_Navigation
						LCARSeffects.DrawNavigation(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX+1,Dimensions.offY+1, Element.RWidth,Element.align,5 , Element.LWidth , 45)					
					Case LCAR_Tactical
						Element.RWidth= LCARSeffects.DrawGPS(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX+1,Dimensions.offY+1,  Element.LWidth)
					Case LCAR_Engineering
						LCARSeffects2.DrawWarpFieldStatus(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth*0.5, LCARSeffects2.WarpMode )
					Case LCAR_StarBase
						LCARSeffects2.DrawClock(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Not(IsClean))
					Case LCAR_Alert, TMP_Alert
						Element.TextAlign = LCARSeffects.drawalert(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, Min(Dimensions.offX,Dimensions.offY)/2,  Element.ColorID, Element.RWidth , Element.Opacity.Current,  Element.TextAlign, Element.Text, Element.SideText, Element.ElementType=LCAR_Alert)
					Case LCAR_Matrix
						LCARSeffects2.LE_DrawMatrix(BG, Dimensions.currX,Dimensions.currY, Dimensions.offX,Dimensions.offY)
						Element.IsClean = False
					Case LCAR_Okuda
						Element.Opacity.Current= Element.Opacity.desired
						LCARSeffects.DrawCirLCAR(BG, LCARSeffects.Okuda, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, Min(Dimensions.offX,Dimensions.offY)/2,BlinkState,Element.Opacity.Current, Element.Align)
						'lcarseffects.Okudagrams.Get(element.LWidth)
					Case LCAR_Omega
						LCARSeffects2.DrawOmega(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.Opacity.Current, Element.LWidth,elementismoving, Element.Text, BlinkState)
					Case LCAR_PdP
						Games.PDPDrawScreen(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth)
					Case LCAR_PdPSelector
						Games.PDPDrawColorSelector(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY)
					Case LCAR_PToE
						LCARSeffects2.DrawPToE(BG,Dimensions.currX ,Dimensions.currY,Dimensions.offX,Dimensions.offY, Element.Text, Element.SideText,Element.LWidth, Element.RWidth)
					Case LCAR_WarpCore
						LCARSeffects2.DrawWarpCoreReal(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.LWidth)
					Case LCAR_ShuttleBay
						LCARSeffects2.DrawShuttleBay(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.LWidth)
					Case LCAR_ASquare
						LCARSeffects2.DrawAnimatedSquare(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.LWidth, Element.RWidth = 1) 
					Case LCAR_Starfield
						LCARSeffects3.DrawStars(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY)
					Case LCAR_LSOD
						LCARSeffects3.DrawLSOD(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.Text, Element.SideText, Element.Opacity.Current)
					Case LCAR_Metaphasic
						LCARSeffects3.DrawMetaphasicShields(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.LWidth, Element.RWidth, Element.Align, Element.TextAlign, Element.Text, Element.SideText, Element.Opacity.Current)
					Case VOY_Tricorder
						LCARSeffects4.DrawTricorder(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.LWidth, Element.colorid=1, Element.Text, Element.SideText)
					Case LCAR_Tactical2
						LCARSeffects5.DrawTactical(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.Align)
					Case LCAR_UFP
						'LCARSeffects5.DrawUFPlogo(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.Lwidth, Element.Opacity.Current)
						LCARSeffects6.DrawUFPlogo(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.Opacity.Current, Element)
					Case Q_net
						LCARSeffects5.drawqnet(BG,Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY)
					Case LCAR_Cards'CARD_IncrementCards
						Games.CARD_DrawCards(BG,Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.ColorID, Element.Opacity.Current, BlinkState, Element.LWidth, Element.RWidth=0)
					Case LCAR_WarpField
						LCARSeffects5.DrawWarpField(BG,Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.ColorID, Element.Opacity.Current, State, Element.LWidth)
					Case LCAR_DNA
						LCARSeffects6.DrawDNA(BG,Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element)
					Case LCAR_Plasma
						LCARSeffects6.DrawPlasmaAll(BG,Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, Element.ColorID, Element.Opacity.Current)
					Case DrP_Board
						Element.LWidth = Games.DrP_DrawScreen(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current))
					
					'Not Star Trek
					Case SBALLS_Plaid
						LCARSeffects.DrawPlaid(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX+1,Dimensions.offY+1, Element.LWidth, Element.RWidth)
					Case BTTF_Flux
						LCARSeffects2.DrawFluxCapacitor(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth*0.5)
					Case SWARS_Targeting
						LCARSeffects3.DrawStarWars(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,Element.LWidth,Element.RWidth,Element.Align,Element.TextAlign=0)
					Case AIR_Alart
						LCARSeffects4.DrawAirplaneAlart(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID,Element.RWidth , Element.Opacity.Current)

					'RANDOM NUMBER BLOCKS
					Case LCAR_RndNumbers, TMP_RndNumbers
						LCARSeffects.MakeClipPath(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX+1,Dimensions.offY+1)
						LCARSeffects2.DrawNumberBlock(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID,  Element.LWidth, Element.ElementType, Element.Text)
						BG.RemoveClip 
					Case ENT_RndNumbers
						LCARSeffects2.DrawPreCARSRND(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, Element.Text, Element.LWidth, Element.rwidth)
						If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonFrame(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, -4, 128, True, False, Element.Tag)
										
					'KLINGON
					Case Klingon_Button
						LCARSeffects2.DrawKlingonGlyph(BG, Dimensions.currX, Dimensions.currY, Element.Align , GetColor(Element.ColorID, State, Element.Opacity.Current), Dimensions.offX,Dimensions.offY, 5)
					Case Klingon_Frame
						LCARSeffects2.DrawKlingonFrame(BG,  Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Colors.argb(Element.Opacity.Current, 255,0,0) , Element.LWidth,  Element.RWidth, Element.Align, Element.Text, Element.sidetext, Element.Opacity.Current, Element.TextAlign  )
					Case Klingon_Clock
						LCARSeffects5.DrawKlingonClock(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Align)
					'ROMULAN
					Case ROM_Square
						LCARSeffects5.DrawRomulan(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY,       Element.LWidth, Element.RWidth, Element.Align, Element.TextAlign,	True)
					'BORG
					Case LCAR_Borg
						LCARSeffects.DrawBorg(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.LWidth)
					Case BORG_Borg
						LCARSeffects6.DrawBORG(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Opacity.Current, Element.Text, Element.SideText)
					'Ferengi
					Case FER_Ticker
						LCARSeffects7.DrawFerengi(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Align)

					'TOS, TOS MOVIES and ENTERPRISE
					Case Legacy_Button
						LCARSeffects2.DrawLegacyButton(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current), Element.Text, Element.Align, Element.TextAlign)
					Case PCAR_Frame
						LCARSeffects2.DrawPreCARSFrame(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, Element.Opacity.Current, Element.Align, Element.rWidth, Element.lWidth, Element.Text, Element.TextAlign, Element.Tag)	
					Case TOS_Moires	'LCARSeffects2.DrawMoires(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, Min(Dimensions.offX,Dimensions.offY)/2, Element.Align , 3, Element.LWidth,Element.RWidth, Colors.White, Colors.Black,2)
						LCARSeffects2.DrawTheMoire(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, Min(Dimensions.offX,Dimensions.offY)/2, Element.Align  , Element.TextAlign )
					Case Legacy_Sonar
						LCARSeffects2.DrawPhotonicSonar(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, Min(Dimensions.offX,Dimensions.offY)/2, Element.ColorID, Element.Text)
					Case TMP_Switch
						LCARSeffects3.DrawWOKSwitch(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorId, Element.Opacity.Current, Element.Text,State)
					Case TMP_Text
						DrawLegacyText(BG, Dimensions.currX, Dimensions.currY, 0,0, Element.text & CRLF, Fontsize,  GetColor(Element.ColorId, State,Element.Opacity.Current), Element.TextAlign)
					Case TMP_Numbers
						LCARSeffects3.DrawDigits(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.text, Element.lwidth, GetColor(Element.ColorId, State,Element.Opacity.Current), Colors.Black)
					Case TMP_Reliant
						LCARSeffects3.DrawReliant(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.Opacity.Current)
					Case TMP_FireControl
						LCARSeffects3.DrawFireControl(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.Opacity.Current,State)
					Case LCAR_ThreeDGame
						Games.THD_Drawgame(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.Opacity.Current, Element.Text, Element.SideText, Element.ColorID)
					Case TOS_Button 
						LCARSeffects3.DrawTOSButton2(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, GetColor(Element.ColorId, State,Element.Opacity.Current), Element.Align,  Element.Text, Element.SideText, Element.TextAlign,  Element.lWidth,Element.rWidth)
					Case TMP_Engineering
						LCARSeffects7.DrawWarpFieldStatus(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth*0.5, Element.ColorID, Element.Text, Element.SideText, Element.Tag)
					Case TMP_Meter
						LCARSeffects7.DrawENTBmeter(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.TextAlign, Element.Text, Element.SideText, Element.Align)
					
					'Enterprise
					Case ENT_Planets
						LCARSeffects4.SOL_DrawPlanets(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.lwidth)
					Case ENT_Button
						LCARSeffects2.DrawPreCARSButton(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, State, Element.Opacity.Current, Element.Text, Element.SideText, Element.Align=1)
					Case ENT_Radar 'DrawPreCARSradar
						LCARSeffects2.DrawPreCARSradar(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Align, Element.ColorID, Element.Text, Element.TextAlign)
						If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonFrame(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, -1, 128, True, True, Element.Tag)
					Case ENT_Meter
						LCARSeffects2.DrawPreCARSMeter(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.align, Element.LWidth, Element.text, Element.ColorID, 8)
						If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonMeter(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, 128, Element.align, Element.LWidth, Element.Tag)
					Case ENT_Sin
						LCARSeffects2.DrawPreCARSSin(BG,  Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Text, Element.ColorID, Element.LWidth,Element.RWidth,Element.Align, Colors.white)
						If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonFrame(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, -5, 128, True, False, Element.Tag)
					Case ENT_Graph
						LCARSeffects2.DrawPreCARSgraph(BG,  Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Text, Element.ColorID,     Element.SideText,Element.LWidth, Element.Align)
						If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonFrame(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, -6, 128, True, False, Element.Tag)
					
					'Deep Space 9
					Case CRD_Shatter
						 LCARSeffects5.DrawShatterglass(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX+1,Dimensions.offY+1, Element.Align)
					Case CRD_Main
						 Wireframe.DrawCardassian(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element)
					
					'BattleStar Galactica
					Case DRD_Timer
						LCARSeffects4.DrawDRADISTimer(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth)
						'DrawDRADIS(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, LCARSeffects4.DRD_Red, 3)
					Case DRD_Matrix 'IncrementCylon
						LCARSeffects4.DrawCylon(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY)
					
					'Chronowerx'case CHX_Password
					Case CHX_Logo
						LCARSeffects3.CHX_DrawLogo(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY)
					Case CHX_Iconbar
						LCARSeffects3.CHX_DrawIconbar(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.Align )
					Case CHX_Window
						LCARSeffects3.CHX_SetWindow(Element,LCARSeffects3.CHX_DrawWindow(BG, Element.LWidth, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Opacity.Current, Element.Text,"CLOSE", Element.SideText, Element.rwidth, LCARSeffects3.CHX_GetWindow(ElementID,Element)))				
					
					'Else
					Case MSC_Sheliak 
						LCARSeffects5.DrawSheliakContract(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY)
					Case MSC_Hacking
						Wireframe.DrawCubes(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element)
					Case TCAR_Main
						Wireframe.DrawTCARS(BG, Element.LWidth, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Opacity.Current, Element.RWidth, Element.Align, Element.textAlign, Element.ColorID, Element.text)
					
					'Event Horizon
					Case EVENT_Horizon
						LCARSeffects4.Draw_EventHorizon(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth)
					
					'system
					Case LCAR_SVG
						Wireframe.DrawSVG2(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.Text, Element.LWidth, Element.RWidth, Element.ColorID, BlinkState, Element.Opacity.Current, Element.Align, 0, Element.TextAlign)
					Case LCAR_Widget
						LCARSeffects3.DrawWidget(BG,Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth)
						'doAlpha=True
					Case LCAR_LWP
						LCARSeffects2.DrawCustomElement(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth,  Element.RWidth, Element.ColorID, State, Element.Opacity.Current, Element.Text,Element.SideText,Element.TextAlign,Element.Align, Element.Tag)
					Case LCAR_GNDN
						'GNDN
						
					Case LCAR_Basic
						DrawUnknownElement(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, State, Element.Opacity.Current, Element.text)
					Case Else
						DrawUnknownElement(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, State, Element.Opacity.Current, "UNKNOWN ELEMENT TYPE")
				End Select'Other styles: Romulan, TOS, Nemesis LCARS (Gradients), TCARS
				If doAlpha Then
					'If element.Opacity.Current < 255 Then'AND element.Opacity.Current>0 Then
						BGC=Colors.ARGB(255-Element.Opacity.Current, 0,0,0)
						BG.DrawRect( SetRect(Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY),  	BGC,	True ,0)
					'End If
				End If
				
				'LCARelements.Set(ElementID, Element)
				Return True
			End If
		End If
	End If
End Sub

Sub DrawUnknownElement (BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Alpha As Int,Text As String)
	DrawRect(BG, X +2, Y +2, Width-3, Height-3,  GetColor(ColorID, State, Alpha) , 4)
	DrawText(BG, X + Width/2, Y + Height/2 - TextHeight(BG,"U")*0.5 , Text, ColorID, 5, State, Alpha,0)
End Sub

Sub LegacyTextHeight(BG As Canvas, Textsize As Int) As Int
	Return BG.MeasureStringHeight("ABCgjy123",LCARSeffects2.StarshipFont, Textsize     )+2
End Sub
Sub DrawLegacyText(BG As Canvas, X As Int, Y As Int, dWidth As Int, dHeight As Int, Text As String, Textsize As Int, Color As Int, Align As Int )As Int
	Dim Height As Int, width As Int ,tempstr() As String 
	LCARSeffects.InitStarshipFont
	If Text.Contains(CRLF) Then 
		tempstr = Regex.Split(CRLF, Text)
		Height=BG.MeasureStringHeight("ABCgjy123",LCARSeffects2.StarshipFont, Textsize     )+2
		For width = 0 To tempstr.Length-1
			DrawRect(BG,X,Y,width,Height,Colors.Black,0)
			Y=Y+Height
			DrawLegacyText(BG,X,Y,dWidth,dHeight, tempstr(width), Textsize,Color,Align)
		Next
		Return Height
	Else If Text.Length>0 Then 
		Height=BG.MeasureStringHeight(Text,LCARSeffects2.StarshipFont, Textsize     )
		width=BG.MeasureStringwidth(Text,LCARSeffects2.StarshipFont, Textsize     )
		
		Select Case Align
			Case 0
				BG.DrawRect(SetRect(X,Y,width+2,Height+1),Colors.Black, True,0)
				Y=Y+ Height
			Case 1,2,3: Y=Y+ Height
			Case 4,5,6: Y=Y+(dHeight*0.5) -(Height*0.5)
			Case 7,8,9: Y=Y+dHeight
		End Select
		Select Case Align
			Case 2,5,8: X=X+(dWidth*0.5)-(width*0.5)
			Case 3,6,9: X=X+dWidth-width
		End Select
		
		BG.DrawText(Text, X, Y    , LCARSeffects2.StarshipFont , Textsize,Color, "LEFT")
		Return width
	End If
End Sub

Sub CheckNumbersize(BG As Canvas)
	If NumberWhiteSpace=0 Or NumberTextSize=0 And LCARCorner.IsInitialized And LCARfont.IsInitialized Then 
		Try
			NumberTextSize = GetTextHeight(BG, LCARCorner.Height , "000")
			NumberWhiteSpace= BG.MeasureStringWidth("000", LCARfont, NumberTextSize)+ListitemWhiteSpace
		Catch
			NumberTextSize=0
			NumberWhiteSpace=0
		End Try
	End If
End Sub

Sub IsElementVisible(ElementID As Int) As Boolean 
	If ElementID< 0 Or ElementID >= LCARelements.Size Then Return False
	Dim Element As LCARelement = LCARelements.Get( ElementID ), Group As LCARgroup = LCARGroups.Get( Element.Group )
	Return Group.Visible And Element.Visible 
End Sub

Sub DrawLCARs(BG As Canvas,SurfaceID As Int)As Boolean 
	Dim temp As Int,temp2 As Int,Group As LCARgroup ,State As Boolean ,Drew As Boolean 
	If ElementMoving Then IsClean=False
	If LCARfontheight=0 Then LCARfontheight = BG.MeasureStringHeight("ABC123",LCARfont,Fontsize)
	
	temp = DateTime.GetSecond(DateTime.Now)
	NewSecond = temp <> LastUpdate
	If NewSecond Then 
		FPS = FramesDrawn
		FramesDrawn=0
	End If 
	LastUpdate = temp
	
	FramesDrawn=FramesDrawn+1
	If Not(BGisInit) Then 
		BGisInit=True
		PullNextToast(BG)
	End If
	
	IsInternal=True
	If Not(IsClean) And Not(ClearLocked) Then 
		If CurrentStyle = ChronowerX Then
			BG.Drawcolor(LCARSeffects3.CHX_Beige)
		Else
			BG.Drawcolor(Colors.Black)
		End If
	End If
	
	IsAAon=False
	Locked=True
	For temp = 0 To LCARGroups.Size-1
		Group = LCARGroups.Get(temp)
		If Group.Visible Then
			For temp2 = 0 To Group.LCARlist.Size-1
				'If temp2 < Group.LCARlist.Size Then
					If DrawElement(BG, SurfaceID, Group.LCARlist.Get(temp2 ) , Group.RedAlert = temp2 )  Then  Drew=True
				'End If
			Next
		End If
	Next
	
	'ActivateAA(BG, DoVector)
	For temp = 0 To LCARlists.Size-1
		If DrawList(BG,SurfaceID, temp, 0,0,0,0)  Then  Drew=True
	Next
	Locked=False
	IsClean=Not(LCARSeffects2.HelpMode)
	If HandleVolume(BG, False) Then Drew=True
	
	If DrawFPS And FPSCounter Then
		DrawText(BG, ScaleWidth, 0, FPS & API.IIF(LCARSeffects2.helpmode, "FPS*", "FPS"), LCAR_Orange, 3,False,255,-1)
	End If
	Return Drew
End Sub

Sub HandleVolume(BG As Canvas, IsWallpaper As Boolean) As Boolean 
	If Not(IsWallpaper) And WallpaperService.PreviewMode Then Return False
	'Log(WallpaperService.PreviewMode & " " & Main.ButtonMenu & " " & IsWallpaper)
	If WallpaperService.PreviewMode And Main.ButtonMenu > -1 And IsWallpaper Then 
		DrawList(BG, 0, Main.ButtonMenu,0,0,0,0)
	End If 
	If VolOpacity > 0 Then
		If VolText.Length=0 Then
			DrawVolume(BG,API.IIF(SmallScreen, 200, 300),75)
		Else
			DrawVolume(BG, VolDimensions.X+20, VolDimensions.Y+20)
		End If
		If VolOpacity<255 Or SpecialToast Then IsClean=False
	'Else If VolTextList.Size>0 Then
		'PushEvent(LCAR_ToastDone,0,0,0,0,0,0, Event_Down)
		Return True
	End If
End Sub

Sub DrawVolume(BG As Canvas, Width As Int, Height As Int)
	Dim X As Int, Y As Int , BarHeight As Int=15,P As Path ,temp As Int,WhiteSpace As Int=2,Black As Int,tempstr() As String ,LineHeight As Int,tVol As Int = API.IIF(Mute,0, cVol), ColorID As Int = LCAR_Orange 'cvol
	If CurrentStyle = LCAR_TNG Or CurrentStyle = LCAR_ClassicTNG Then
		If CurrentStyle = LCAR_ClassicTNG Then ColorID = Classic_Green	
		X=ScaleWidth*0.5-Width*0.5
		If Not(ToastAlign) Then Y=ScaleHeight-Height*2
		
		Black=Colors.ARGB(VolOpacity,0,0,0)
		LCARSeffects2.DrawLegacyButton(BG, X-WhiteSpace,Y-WhiteSpace,Width+WhiteSpace*2,Height+WhiteSpace*2, Black, "", 1, 0)
		LCARSeffects2.DrawLegacyButton(BG, X,Y,Width,Height, GetColor(ColorID,False, VolOpacity), "", 1, 0)
		
		If VolText.Length=0 Then
			DrawText(BG, X + 10,Y+10, "VOLUME: ", LCAR_Black, 1,False,VolOpacity,0)
			LCARSeffects2.DrawLegacyButton(BG, X+10, Y+Height-10-BarHeight, Width-20, BarHeight, Black,"",-5, 0)' GetColor(LCAR_Black,False, VolOpacity), "", -5)
			If tVol<100 Then
				temp=(Width-20) * (tVol*0.01)+ (X+10)
				P.Initialize(X,Y)
				P.LineTo(temp,Y)
				P.LineTo(temp,Y+Height)
				P.LineTo(X,Y+Height)
				BG.ClipPath(P)
			End If
			If RedAlert Then
				WhiteSpace=Colors.ARGB(VolOpacity,255,255,255)
			Else 
				WhiteSpace=GetColor(LCAR_Purple,False, VolOpacity)
			End If
			LCARSeffects2.DrawLegacyButton(BG, X+10, Y+Height-10-BarHeight, Width-20, BarHeight, WhiteSpace, "", -5, 0)
			If tVol<100 Then BG.RemoveClip
		Else
			If VolText.Contains(CRLF) Then
				tempstr = Regex.Split(CRLF, VolText)
				LineHeight=TextHeight(BG, "HELLO")
				For temp = 0 To tempstr.Length-1 
					DrawText(BG, X + 10,Y+10, tempstr(temp), LCAR_Black,   1,False,VolOpacity, 0)
					Y=Y+ LineHeight
				Next
			Else
				DrawText(BG, X + 10,Y+10, VolText, LCAR_Black,   1,False,VolOpacity, 0)
			End If
		End If
	Else
		LCARSeffects3.DrawStyledToast(BG, CurrentStyle, tVol, VolText,VolOpacity, Width,Height,ScaleWidth,ScaleHeight)
	End If
End Sub

Sub GetText(inEnglish As String, inKlingon As String)As String 
	If CurrentStyle=Klingon And Not(Games.UT) Then
		Return inKlingon
	Else
		Return inEnglish
	End If
End Sub

'Sub HandleDrawPicture(BG As Canvas, Dimensions As tween, Element As LCARelement)
'	Dim SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, Margin As Float, MarginX As Int, MarginY As Int, Tag() As String 
'	If Element.LWidth=-1 And Element.Text.Length > 0 Then 
'		If Element.Text.Length = 0 Then Element.Text = File.DirAssets
'		LCARSeffects2.LoadUniversalBMP(Element.Text, Element.SideText, Element.ElementType)
'	End If
'	If Element.Tag.Contains(",") Then 
'		Tag = Regex.Split(",", Element.tag)
'		If Tag.Length = 1 Or Tag.Length = 5 Then 
'			Margin = Tag(Tag.Length-1)
'			If Margin > 1 Then Margin = Margin * 0.01
'			MarginX = Dimensions.offX * Margin 
'			MarginY = Dimensions.offY * Margin 
'		End If
'		If Tag.length > 3 Then 
'			SrcX = Tag(0)
'			SrcY = Tag(1)
'			SrcWidth = Tag(2)
'			SrcHeight = Tag(3)
'		End If 
'	End If
'	DrawLCARPicture(BG, Dimensions.currX + MarginX, Dimensions.currY + MarginY, Dimensions.offX - MarginX*2, Dimensions.offY - MarginY*2, Element.LWidth, Element.Align, Element.Opacity.Current, Element.RWidth=1, SrcX,SrcY,SrcWidth,SrcHeight)
'End Sub

Sub DrawLCARPicture(BG As Canvas,X As Int, Y As Int, Width As Int,Height As Int,PictureID As Int,Align As Int,Alpha As Int, FullSize As Boolean, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int) As Boolean 
	Dim Picture As LCARpicture ,Size As tween, X2 As Int, Y2 As Int, retval As Boolean, Dest As Rect 
	If PictureID=-1 Then
		Picture.Initialize 
		Picture.Picture = LCARSeffects2.CenterPlatform 
	Else
		Picture=PictureList.Get(PictureID)
	End If
	'DrawUnknownElement(BG,X, Y, Width, Height, LCAR_Orange, False, 255, "PICTURE")
	If Picture.Picture.IsInitialized Then
		If SrcWidth = 0 Then SrcWidth = Picture.Picture.Width
		If SrcHeight = 0 Then SrcHeight = Picture.Picture.Height
		Size = ThumbSize(SrcWidth, SrcHeight, Width,Height, FullSize, False)
		retval=True
		Select Case Align
			Case 0,1'top left
				X2=X+Width/2 - Size.currX/2
				Y2=Y+Height/2 - Size.curry/2
			Case 5'center
				retval=False
				X2=X-Size.currX/2
				Y2=Y- Size.curry/2
		End Select
		Dest=LCARSeffects4.SetRect(X2, Y2, Size.currX, Size.currY)
		BG.DrawBitmap(Picture.Picture, LCARSeffects4.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), Dest )
		If Alpha < 255 Then BG.DrawRect(Dest, Colors.ARGB(255-Alpha, 0,0,0), True ,0)
	End If
	Return retval
End Sub 

'PicWidth/PicHeight: Original image dimensions
'ThumbWidth/ThumbHeight: Desired maximum dimensions
'ForceToEdge: This will force it so at least one axis is the same as the desired dimensions
'ForceFull: Force the thumb to fill the entire desired dimensions, with cropping
Sub ThumbSize(PicWidth As Int, PicHeight As Int, ThumbWidth As Int, ThumbHeight As Int, ForceToEdge As Boolean, ForceFull As Boolean  ) As tween
	Dim Size As tween 
	Size.Initialize 
	
	If ForceToEdge Then'Zooms/crops image to force it to fill the entire space
        If PicHeight < ThumbHeight Then
            PicWidth = PicWidth * ThumbHeight / PicHeight
            PicHeight = ThumbHeight
        End If
    End If
	
    If PicWidth > ThumbWidth Then
        PicHeight = PicHeight / (PicWidth / ThumbWidth)
        PicWidth = ThumbWidth
    End If
    If PicHeight > ThumbHeight Then
        PicWidth = PicWidth / (PicHeight / ThumbHeight)
        PicHeight = PicHeight / (PicHeight / ThumbHeight)
    End If
	
    If ForceFull Then'if the image is smaller than the thumbnail, it zooms in to fit an edge
        If PicWidth < ThumbWidth Then
            PicHeight = PicHeight * (ThumbWidth / PicWidth)
            PicWidth = ThumbWidth
        End If
        If PicHeight < ThumbHeight Then
            PicWidth = PicWidth * (ThumbHeight / PicHeight)
            PicHeight = PicHeight * (ThumbHeight / PicHeight)
        End If
    End If
	
	Size.currX=PicWidth
	Size.currY=PicHeight 
	Return Size
End Sub

Sub DrawLCARtextbox(BG As Canvas, X As Int, Y As Int, Width As Int,Height As Int, SelStart As Int, SelWidth As Int, Text As String, ColorID As Int, CursorColorID As Int, HighliteColorID As Int, State As Boolean, Blink As Boolean,Align As Int ,Alpha As Int  )As String 
	Dim OldFontSize As Int, StartChar As Int, EndChar As Int, StartX As Long, FinishX As Long , Color As LCARColor ,SelText As String , tHeight As Int,SelTextColorID As Int, Maxsize As Int, DoBG As Boolean = True 
	If Align<20 Then
		OldFontSize=Fontsize
		If Height=LCAR_NumberTextSize Then 
			CheckNumbersize(BG)
			Height =NumberTextSize 
		End If
		If Align < -9 Then
			DoBG = False 
			Align = Abs(Align)
		End If 
		If Align>9 Then
			Align=Align-10
			If BG.MeasureStringWidth(Text, LCARfont, Height) > Width Then Height = API.GetTextHeight(BG, -Width, Text, LCARfont)
		End If
		
		Fontsize=Height
		SelTextColorID=LCAR_Black
		Maxsize=TextHeight(BG,API.IIF(Text.Length=0, "ABC123",  Text))
		If RedAlert Then
			HighliteColorID = RedAlertMode'LCAR_RedAlert
			CursorColorID= LCAR_White
			ColorID= RedAlertMode'LCAR_RedAlert
			If Not(Blink) Then SelTextColorID=LCAR_White
		End If
		'If Not( elementmoving) Then
		If Align>-1 Then 
			If DoBG Then BG.DrawRect( SetRect(X-1,Y, Width+1, Maxsize+3), Colors.Black, True,0) 
		Else 
			Align=-1-Align
		End If
		Select Case Align
			Case 0, 1,4,7
				DrawText(BG, X,Y, Text, ColorID, Align,State, Alpha,0)
				tHeight=Maxsize'bg.MeasureStringHeight(Text , lcarfont, height )+1
				If SelStart>-1 Then
					If SelWidth<>0 And HighliteColorID> LCAR_Black Then
						If SelWidth<0 Then 
							StartChar= SelStart+SelWidth
						Else
							StartChar=SelStart
						End If
						EndChar = StartChar+ Abs(SelWidth)
						StartX = BG.MeasureStringWidth(Text.SubString2(0, StartChar)  ,LCARfont, Height)
						SelText=Text.SubString2(StartChar, EndChar)
						FinishX=BG.MeasureStringWidth(SelText,LCARfont, Height)
						Color = LCARcolors.Get(HighliteColorID)
						BG.DrawRect( SetRect(X+StartX-1,Y,FinishX+2, tHeight),  Color.Normal ,True,0)
						DrawText(BG, X+StartX,Y, SelText, SelTextColorID,  1,State, Alpha,0)
					End If
					If Blink And CursorColorID>LCAR_Black And SelStart>-1 Then
						StartX= BG.MeasureStringWidth(API.left(Text,SelStart)  ,LCARfont, Height)
						Color = LCARcolors.Get(CursorColorID)
						BG.DrawRect( SetRect(X+StartX-1,Y,3, tHeight), Color.Normal,True,0)
					End If
				End If
			Case 2,5,8'center
				DrawText(BG, X+Width/2,Y, Text, ColorID, 2,State, Alpha,0)
			Case 3,6,9'right
				If Width = -1 Then
					StartChar = BG.MeasureStringWidth(Text, LCARfont, Fontsize)
					BG.DrawRect( SetRect(X-StartChar,Y, StartChar+1, Maxsize+4), Colors.black, True,0) 
					Width=0
				End If
				DrawText(BG, X+Width-1,Y, Text, ColorID, 3,State, Alpha,0)
		End Select
		'If alpha<255 Then bg.DrawRect( setrect(x,y, width, textheight(bg, text)+1), Colors.ARGB(255-alpha,0,0,0), True,0)
		Fontsize=OldFontSize
		Return SelText
	Else
		Return Null
	End If
End Sub

Sub DrawTextbox(BG As Canvas, Text As String,ColorID As Int, X As Int, Y As Int, Width As Int, Height As Int, Align As Int)
	Dim retval As Int 
	If Text.Length>0 Then
		Select Case Align
			'case 1,4,7:x=x'Left Col
			Case 2,5,8: X = X+Width/2'Center
			Case 3,6,9:X=X+Width-1
		End Select
		If Align>3 Then retval=TextHeight(BG,Text)
		Select Case Align
			'case 1,2,3:y=y'top row
			Case 4,5,6:Y= Y+Height/2 - retval/2'middle row
			Case 7,8,9:Y=Y+Height-1 - retval'bottom row
		End Select
		DrawText(BG, X,Y, Text,ColorID,Align,False,255,0)
	End If
	Return retval
End Sub

Sub DrawRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)As Rect 
	Dim Dest As Rect 
	If Width=1 And Height=1 Then
		BG.DrawPoint(X,Y,Color)
	Else If Width >0 And Height> 0 Then
		Dest=SetRect(X,Y,Width,Height)
		BG.DrawRect(Dest, Color, Stroke=0,Stroke)
		Return Dest
	End If
End Sub
Sub DrawPic(BG As Canvas, X As Int, Y As Int, BMP As Bitmap, FlipX As Boolean, FlipY As Boolean )
	DrawPic2(BG,X,Y,BMP,FlipX,FlipY,1)
	'If FlipX OR FlipY Then
'		BG.DrawBitmapFlipped(BMP, Null, SetRect(X,Y, BMP.Width, BMP.Height) , FlipX,FlipY)
'	Else
'		BG.DrawBitmap(BMP, Null, SetRect(X,Y, BMP.Width, BMP.Height) )
'	End If
End Sub
Sub DrawPic2(BG As Canvas, X As Int, Y As Int, BMP As Bitmap, FlipX As Boolean, FlipY As Boolean, Factor As Float ) As Point 
	If Factor = 0 Then Factor = GetScalemode
	Dim temp As Point = Trig.SetPoint(BMP.Width*Factor, BMP.Height*Factor)
	If FlipX Or FlipY Then
		BG.DrawBitmapFlipped(BMP, Null, LCARSeffects4.SetRect(X,Y,temp.X, temp.Y) , FlipX,FlipY)
	Else
		BG.DrawBitmap(BMP, Null, LCARSeffects4.SetRect(X,Y,temp.X, temp.Y) )
	End If
	Return temp
End Sub

Sub ResizeElement(ElementID As Int, LandscapeX As Int, LandscapeY As Int, LandscapeWidth As Int, LandscapeHeight As Int, PortraitX As Int, PortraitY As Int, PortraitWidth As Int, PortraitHeight As Int)
	If Landscape Then
		ForceElementData(ElementID,  LandscapeX,LandscapeY, 0,0, LandscapeWidth,LandscapeHeight,0,0,255,255,True,False)
	Else
		ForceElementData(ElementID,  PortraitX,PortraitY, 0,0, PortraitWidth,PortraitHeight,0,0,255,255,True,False)
	End If
End Sub

Sub ForceElementData(ElementID As Int,X As Int, Y As Int, XOffset As Int, YOffset As Int, Width As Int, Height As Int, WidthOffset As Int, HeightOffset As Int, CurrAlpha As Int, DesAlpha As Int, Visible As Boolean, IsAnimated As Boolean  )As Int
	Dim Element As LCARelement 
	If Not(IsAnimated) Then
		XOffset=0
		YOffset=0
		WidthOffset=0
		HeightOffset=0
		CurrAlpha=DesAlpha
	End If
	'If ElementID<LCARelements.Size Then
		Element=LCARelements.Get(ElementID)
			Element.LOC.currX=X
			Element.LOC.currY=Y
			Element.LOC.offX=XOffset
			Element.LOC.offY=YOffset
			Element.Size.currX=Width
			Element.Size.currY=Height
			Element.Size.offx = WidthOffset
			Element.Size.offy = HeightOffset
			Element.Opacity.Current=CurrAlpha
			Element.Opacity.Desired=DesAlpha
			Element.IsClean=False
			Element.Visible = Visible
		LCARelements.Set(ElementID,Element)
	'End If
	Return X+Width
End Sub





Sub DrawBGText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Int, Text As String, TextSize As Int, ColorID As Int, DoBG As Boolean ,Alpha As Int, State As Boolean, LockWidth As Boolean , LockHeight As Boolean  )
	Dim MoveBox As Boolean ,OldY As Int=Y, OldX As Int = X,tempHeight As Int 
	CheckNumbersize(BG)
	If TextSize= NumberTextSize Then
		Height = ItemHeight 
		Width = BG.MeasureStringWidth(Text,LCARfont,TextSize)
		MoveBox=True
	Else If TextSize=0 Then
		If Height>0 And Width>0 Then
			If Align=5 Then
				X=X+Width/2
				Y=Y+Height/2
			End If
			TextSize = Min(GetTextHeight(BG, Height,Text), GetTextHeight(BG, -Width,Text) )
		Else If Height>0 Then 
			TextSize = GetTextHeight(BG, Height,Text)
		Else If Width>0 Then 
			TextSize = GetTextHeight(BG, -Width,Text)
		End If
		tempHeight= BG.MeasureStringHeight(Text, LCARfont, TextSize)
		If Not(LockHeight) Then Height = tempHeight
		If Not(LockWidth) Then Width = BG.MeasureStringWidth(Text,LCARfont,TextSize)
		MoveBox=True
	Else If Height = 0 Or Width=0 Then
		If Height=0 Then Height = BG.MeasureStringHeight(Text, LCARfont, TextSize)
		If Width=0 Then Width = BG.MeasureStringWidth(Text,LCARfont,TextSize)
		MoveBox=True
	End If
	
	If MoveBox Then 
		Select Case Align
			Case 1,2,3'top
				'leave Y the same
			Case 4,5,6
				Y=Y-(Height/2)-1
			Case 7,8,9
				Y=Y-Height-1
		End Select
		Select Case Align
			Case 1,4,7
				'leave x the same
			Case 2,5,8
				X=X-(Width/2)-1
			Case 3,6,9
				X=X-Width-1
		End Select
	End If

	ColorID=GetColor(ColorID,State,Alpha)
	If DoBG Then DrawRect(BG,X-2,Y-2,Width+6,Height+4, Colors.Black,0)
	
	If LockHeight Then
		Select Case Align
			Case 1,2,3:Height=tempHeight/2 + Height/2
		End Select
	End If
	
	BG.DrawText(Text,X,Y+Height, LCARfont, TextSize, ColorID, "LEFT")
End Sub
Sub Draw2Elbows(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, TopText As String, BottomText As String, State As String, Alpha As Int)As Int 
	Dim temp As Int =API.IIF(SmallScreen,50,100)
	DrawLCARelbow(BG,X,Y, Width,Height-10, temp, ItemHeight, 0, ColorID, State, "", 0,Alpha,False)
	DrawLCARelbow(BG,X,Y+Height/2, Width,Height/2, temp, ItemHeight, 2, ColorID, State, "", 0,Alpha,False)
	
	DrawLCARbutton(BG,X+Width-leftside,Y,  leftside, ItemHeight, ColorID, State, "", "", 0,leftside,True,0,0,-1,Alpha,False)
	DrawLCARbutton(BG,X+Width-leftside,Y+Height-ItemHeight-1,  leftside, ItemHeight, ColorID, State, "", "", 0,leftside,True,0,0,-1,Alpha,False)
	temp=temp+LCARCornerElbow2.Width+4+leftside
	DrawBGText(BG, X+Width-leftside,Y-1, Width-temp - 2,ItemHeight,  	3, TopText,0, ColorID,True,Alpha,State,False,True)
	DrawBGText(BG, X+Width-leftside,Y+Height-ItemHeight-1, Width-temp -2,ItemHeight,  	3, BottomText,0, ColorID,True,Alpha,State,False,True)
	Return temp-2-leftside
End Sub

Sub InnerElbowSize(ElementID As Int, isX As Boolean) As Int
	Dim Element As LCARelement = LCARelements.Get(ElementID)
	Return InnerElbowSize2(Element.LWidth, Element.RWidth, isX)
	'If Element.LWidth >100 OR Element.RWidth > 100 Then Return Min(Element.LWidth,Element.RWidth) *0.5
	'Return API.iif(isX, LCARCornerElbow2.Width, LCARCornerElbow2.Height)
End Sub
Sub InnerElbowSize2(LWidth As Int, RWidth As Int, isX As Boolean) As Int
	If LWidth >100 Or RWidth > 100 Then Return Min(LWidth,RWidth) *0.5
	Return API.iif(isX, LCARCornerElbow2.Width, LCARCornerElbow2.Height)
End Sub


'Align: -2 to -5 are minis, 0 to 3 are regular, 5 to 9 are angled, -2/0/4=top left, -3/1/5=top right, -4/2/6=bottom left, -5/3/7=bottom right, -1=2 elbows in the shape of a C
Sub DrawLCARelbow(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Align As Int, ColorID As Int, State As Boolean , Text As String, TextAlign As Int,Alpha As Int,IsMoving As Boolean)As Boolean 
	Dim Color As Int,  Start As Int ,X2 As Int,Y2 As Int=Y,X3 As Int=X , TextColorID As Int , Corner As Rect ,  FlipX As Boolean , FlipY As Boolean, TextWhiteSpace As Int,ElbowMode As Int,ElbowMode2 As Int = LCARCornerElbow2.Width 'LCARC As LCARColor ,
	If BG=Null Then Return False
	If BarWidth >100 Or BarHeight >100 Then 
		ElbowMode = Min(BarWidth,BarHeight)
		ElbowMode2 = ElbowMode * 0.5
	End If
	
	TextWhiteSpace=4'previous was 10
	'If smallscreen Then
	'	BarWidth=BarWidth*0.5
	'	BarHeight=BarHeight*0.5
	'End If
	'If colorid= lcar_black Then'AND alpha<255 Then
		'Color= Colors.argb( Alpha,0,0,0)
	'Else
		If ColorID>-1 Then Color=GetColor(ColorID, State,Alpha)
		'If redalert AND colorid<> lcar_black Then colorid= LCAR_RedAlert
		'LCARC= lcarcolors.Get(colorid)
		'If state Then  Color = lcarc.Selected Else color = lcarc.Normal
		TextColorID=LCAR_Black
		If Not (RedAlert) And ColorID=LCAR_Black Then TextColorID =LCAR_Orange
	'End If
	
	Select Case Align
		Case -2,-3,-4,-5'mini elbows
			Start=Max(BarWidth,BarHeight)*0.5
			If Align = -4 Or Align = -5 Then Y2=Y+Height-BarHeight
			If Text.Length > 0 And BarHeight = ItemHeight Then
				CheckNumbersize(BG)
				TextWhiteSpace=Start'BarHeight* 0.5
				If Align = -2 Or Align = -4 Then'left align
					X2 = DrawText2(BG, X+ TextWhiteSpace+1, Y2, NumberTextSize, Text, Color, 0) + TextWhiteSpace+4
					DrawRect(BG, X+X2, Y2, Width-X2, BarHeight, Color,0)
					X3=X+Start-1
				Else'right align
					X2 = DrawText2(BG, X+ Width- Start - 2, Y2, NumberTextSize, Text, Color, 2)' + TextWhiteSpace+4
					DrawRect(BG, X, Y2, Width-X2, BarHeight, Color,0)
					X=X+Width-TextWhiteSpace
				End If
				Width=TextWhiteSpace
				If Width-Start > 0 Then DrawRect(BG,X3,Y2,Width-Start,BarHeight, Color,0)'top
			Else
				If Align = -2 Or Align = -4 Then'left align
					DrawRect(BG, X + Start-1, Y2, Width-Start+1, BarHeight,Color,0)
				Else
					DrawRect(BG, X, Y2, Width-Start, BarHeight,Color,0)
				End If
			End If
	End Select
	
	Select Case Align'		   _
		Case -2'top left mini |
			'If Text.Length > 0 AND BarHeight = ItemHeight Then
				'X2 = DrawText2(BG, X+ TextWhiteSpace+1, Y, NumberTextSize, Text, Color, 0) + TextWhiteSpace+4
				'DrawRect(BG, X+X2, Y, Width-X2, BarHeight, Color,0)				
				'Width=TextWhiteSpace
			'End If
			
			'DrawRect(BG,X,Y+BarHeight,BarWidth,Height-BarHeight, Color,0)'left
			'DrawRect(BG,X+Start-1,Y,Width-Start,BarHeight, Color,0)'top
			If Start > BarHeight Then LCARSeffects4.DrawRect(BG, X + Start-1, Y+BarHeight-1, BarWidth-Start, Start-BarHeight, Color, 0)
			DrawRect(BG,X+BarWidth-1, Y+Start-1, Start-BarWidth+1,Start+1, Color,0)'missing bit under curve
			DrawCircle(BG,X,Y, Start,Start, 1, Color)'outer curve
			DrawRect(BG,X,Y+Start-1, BarWidth, Height-Start+1, Color,0)'|
			Start= BarHeight * 0.2
			DrawCircle(BG,X+BarWidth-1,Y+BarHeight-1, Start,Start, -1, Color)'inner corner
	
		'						_
		Case -3'top right mini   |
			'If Text.Length > 0 AND BarHeight = ItemHeight Then
				'X2 = DrawText2(BG, X+ Width- Start - 1, Y, NumberTextSize, Text, Color, 2)' + TextWhiteSpace+4
				'DrawRect(BG, X, Y, Width-X2, BarHeight, Color,0)		
				'X=X+Width-TextWhiteSpace
				'Width=TextWhiteSpace
			'End If
			'If Width-Start > 0 Then DrawRect(BG,X,Y,Width-Start,BarHeight, Color,0)'top
			DrawCircle(BG,X+Width-Start,Y, Start,Start, 3, Color)'outer curve
			DrawRect(BG,X+Width-Start, Y+Start-1, Start,Start+1, Color,0)'missing bit under curve
			DrawRect(BG,X+Width-BarWidth,Y+Start-1, BarWidth, Height-Start , Color,0)'|
			Start= BarHeight * 0.2
			DrawCircle(BG,X+Width-BarWidth-Start+1,Y+BarHeight-1, Start,Start, -3 , Color)'inner corner
	
		Case -4'bottom left mini 	|_
			'If Text.Length > 0 AND BarHeight = ItemHeight Then
				'X2 = DrawText2(BG, X+ TextWhiteSpace+1, Y+Height-BarHeight, NumberTextSize, Text, Color, 0) + TextWhiteSpace+4
				'DrawRect(BG, X+X2, Y+Height-BarHeight, Width-X2, BarHeight, Color,0)				
				'Width=TextWhiteSpace
			'End If
			'If Width-Start > 0 Then DrawRect(BG,X+Start-1,Y+Height-BarHeight,Width-Start,BarHeight, Color,0)'top
			DrawCircle(BG,X,Y+Height-Start, Start,Start, 7, Color)'outer curve
			DrawRect(BG,X, Y+Height-BarHeight, Start,Start, Color,0)'missing bit under curve
			'LCARSeffects4.DrawRect(BG, X, Y+Height-BarHeight, Width, BarHeight*0.5, Colors.red, 0)'Filler
			DrawRect(BG,X+Start-1, Y+Height-Start, BarWidth - Start,Start, Color,0)'missing bit under curve
			DrawRect(BG,X,Y+1, BarWidth-1, Height-Start, Color,0)'|
			Start= BarHeight * 0.2
			DrawCircle(BG,X+BarWidth-1,Y+Height-BarHeight-Start, Start,Start, -7, Color)'inner corner
	
		Case -5'bottom right mini	_|
			X3=X+Width-Start
			DrawCircle(BG, X3,Y+Height-Start-1, Start,Start, 9, Color)'outer curve
			DrawRect(BG,X3, Y+Height-BarHeight-1, Start+1,Start+1, Color,0)'missing bit under curve
			DrawRect(BG,X+Width-BarWidth,Y, BarWidth, Height-Start , Color,0)'|
			Start= BarHeight * 0.2
			DrawCircle(BG,X+Width-BarWidth-Start+1,Y+Height-BarHeight-Start, Start,Start, -9 , Color)'inner corner
	
		Case -1' C
			Draw2Elbows(BG,X,Y,Width,Height, ColorID,API.GetSide(Text,"|", True,False),API.GetSide(Text,"|", False,False), State,Alpha)
		
		'		 _
		Case 0' |  top left
			'If TextAlign =10 Then height=height-barheight
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
			'bg.DrawRect(setrect(x,y,width,barheight), Color, True,1)'top
				BG.DrawRect(SetRect(X+BarWidth-1,Y,Width-BarWidth+1,BarHeight), Color, True,1)'top
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmap(LCARCornerElbow, Null,  setrect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ))
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG,LCARCornerElbow,LCARCornerElbowa, SetRect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,False,IsMoving)
					Corner=SetRect(X+BarWidth-1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X,Y, ElbowMode,ElbowMode, 1, Color, True)
					DrawCircle2(BG, X+BarWidth-1, Y+BarHeight-1, ElbowMode2,  ElbowMode2, -1 , Color, False)
				End If
				
				Select Case TextAlign
					Case 10
						DrawLCARtextbox(BG,  X+BarWidth+ElbowMode2,Y, API.TextWidthAtHeight(BG,LCARfont, Text, ElbowTextHeight)+3    ,  ElbowTextHeight,  0,0, Text, ColorID, ColorID, ColorID, False,False,4,Alpha) 
					Case Else	
						If TextAlign<0 Then
							DrawTextbox(BG, Text, TextColorID, X+BarWidth-10,Y+10,Width-BarWidth-9,BarHeight-20 ,Abs(TextAlign))
						Else
							DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
						End If
				End Select
			'End If
			
		'        _
		Case 1'   | top right
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,Width,BarHeight) , Color, True,1)'top
				BG.DrawRect(SetRect(X+Width-BarWidth,Y+BarHeight-1,BarWidth,Height-BarHeight), Color, True,1)'right
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,True)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ),True,False,IsMoving)
					Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X +Width-ElbowMode,Y, ElbowMode,ElbowMode, 3, Color, True)
					DrawCircle2(BG, X+Width-BarWidth-ElbowMode2-1,Y+BarHeight-1, ElbowMode2,  ElbowMode2, -3 , Color, False)
				End If
				
				FlipX=True
				If TextAlign<0 Then
					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace, BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))'previous boundaries were 10, not 4
				Else
					DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace+Width-BarWidth-1,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
				End If
			'End If
			
		Case 2' |_  bottom left
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
				BG.DrawRect(SetRect(X+BarWidth-1,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
			End If
			'If colorid> lcar_black Then
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,True,False)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa,SetRect(X, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,False,True,IsMoving)
					Corner=SetRect(X+BarWidth-1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X,Y +Height-ElbowMode, ElbowMode,ElbowMode,  7, Color, True)
					DrawCircle2(BG, X+BarWidth-1,Y+Height-BarHeight-ElbowMode2-1, ElbowMode2,ElbowMode2,  -7, Color, False)
				End If
				
				FlipY=True
				DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
			'End If
			
		Case 3'  _| bottom right
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X+Width-BarWidth,Y,BarWidth,Height) , Color, True,1)'left
				BG.DrawRect(SetRect(X,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True,IsMoving)
					Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG,X +Width-ElbowMode, Y +Height-ElbowMode, ElbowMode,ElbowMode,  9, Color, True)
					DrawCircle2(BG,X+Width-BarWidth-ElbowMode2,Y+Height-BarHeight-ElbowMode2, ElbowMode2,ElbowMode2,  -9, Color, False)
				End If
				FlipX=True:FlipY=True
				If TextAlign<0 Then
					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace+ (Height-BarHeight), BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))
				Else
					DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace+Width-1-BarWidth, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
				End If
			'End If		
			
		Case Else
			Corner = LCARSeffects2.DrawAngledElbow(BG,X,Y,Width,Height,BarWidth,BarHeight, Align,ColorID,State,Text,Alpha,IsMoving)
			Select Case Align
				Case 5:FlipX=True
				Case 6,8:FlipY=True
				Case 7,9:FlipX=True:FlipY=True
			End Select
			
	End Select
	If Corner.IsInitialized Then 
		If ColorID>-1 Then BG.DrawRect (Corner, Color,True,1)
		'If flipx OR flipy Then
			If ColorID<> LCAR_Black  Then 'bg.DrawBitmapFlipped(LCARCornerElbow2, Null, Corner, FlipY, FlipX)
				DrawBitmap(BG, LCARCornerElbow2, LCARCornerElbow2a, Corner, FlipX,FlipY,IsMoving)
			End If
		'Else
		'	If colorid> lcar_black Then' bg.DrawBitmap(LCARCornerElbow2, Null,  corner)
		'		drawbitmap(bg, LCARCornerElbow2, LCARCornerElbow2a, corner, False,False)
		'	End If
		'End If
	End If
End Sub

Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String) As Int 
	Return API.GetTextHeight(BG,DesiredHeight,Text,LCARfont)
End Sub

Sub DrawMiniGradient(BG As Canvas, Color1 As Int, Color2 As Int, Alignment As Int, X As Int, Y As Int, X2 As Int, Y2 As Int,X3 As Int, Y3 As Int,X4 As Int, Y4 As Int,Width As Int, Height As Int)
	Dim P As Path
	P.Initialize(X,Y)
	P.LineTo(X2, Y2)
	P.LineTo(X3,Y3)
	BG.ClipPath(P)
	DrawGradient(BG,Color1,Color2,Alignment,X4,Y4,Width,Height,0,0)
	BG.RemoveClip 
End Sub

Sub SetRadialGradient(GD As GradientDrawable, radius As Float)
    Dim r As Reflector
    r.Target = GD
    r.RunMethod2("setGradientType", 1, "java.lang.int")
    r.RunMethod2("setGradientRadius", radius, "java.lang.float")
End Sub


'Align: 0=Outwards from center, 1=Bottom Right to Top Left, 2=Bottom to TOP, 3=Bottom Left to Top Right, 4=RIGHT to LEFT 
'5=CornerRadius, 6=LEFT To RIGHT, 7=Top Right To Bottom Left, 8=TOP To Bottom, 9=Top Left To Bottom Right
'First direction=Color1, second direction=Color2
'If CornerRadius is below 0, then it's a sphere gradient
Sub DrawGradient(BG As Canvas, Color1 As Int, Color2 As Int, Alignment As Int, X As Int, Y As Int, Width As Int, Height As Int, CornerRadius As Int, Angle As Float)As Boolean 
	Dim CLRS(2) As Int, CLRS2(9) As Int, Align As String, X2 As Int, Y2 As Int ' , Alignments As List 
	Dim grad As GradientDrawable, grad2 As ColorDrawable, DoRainbow As Boolean = (Color1=Color2) And (Color1= Colors.Black )
	If Color1<>Color2 Or DoRainbow Then
		Select Case Alignment
			Case 0
				X2=X+(Width/2)
				Y2=Y+(Height/2)
				
				DrawMiniGradient(BG, Color1,Color2, 4, X,Y, X2,Y2, X, Y+Height, X,Y, Width/2, Height)'left
				DrawMiniGradient(BG, Color1,Color2, 2, X,Y, X2,Y2, X+Width, Y, X,Y, Width, Height/2)'top
				DrawMiniGradient(BG, Color1,Color2, 6, X+Width,Y, X2,Y2, X+Width, Y+Height, X2,Y, Width/2, Height)'right
				DrawMiniGradient(BG, Color1,Color2, 8, X,Y+Height, X2,Y2, X+Width, Y+Height, X,Y2, Width, Height/2)'bottom			
				Return False
				
			Case 1:Align="BR_TL"
			Case 2:Align="BOTTOM_TOP"
			Case 3:Align="BL_TR"
			Case 4:Align="RIGHT_LEFT"
			
			Case 5
				DrawGradient(BG, Color1,Color2,0,X,Y,Width,Height, CornerRadius,Angle)
				Return False
			
			Case 6:Align="LEFT_RIGHT"
			Case 7:Align="TR_BL"
			Case 8:Align="TOP_BOTTOM"
			Case 9:Align="TL_BR"'\
			
			Case Else:Return True
		End Select
		'Alignments.Initialize2(Array As String("BR_TL", "BOTTOM_TOP", "BL_TR", "RIGHT_LEFT", "", "LEFT_RIGHT", "TR_BL", "TOP_BOTTOM", "TL_BR"))
		If DoRainbow Then
			CLRS2(0) = Colors.White 
			CLRS2(1) = Colors.Red 
			CLRS2(2) = Colors.RGB(255, 128, 0)'Orange
			CLRS2(3) = Colors.Yellow
			CLRS2(4) = Colors.Green
			CLRS2(5) = Colors.Blue
			CLRS2(6) = Colors.rgb(75, 0, 130)'Indigo
			CLRS2(7) = Colors.RGB(138, 43, 226)'Violet
			CLRS2(8) = Colors.Black 
			grad.Initialize(Align,CLRS2)
		Else
			CLRS(0) = Color1
			CLRS(1) = Color2
			grad.Initialize(Align,CLRS )' Alignments.Get(Alignment-1)  ,  clrs)
		End If
		
		If CornerRadius>0 Then 
			grad.CornerRadius = CornerRadius
		Else If CornerRadius<0 Then
			SetRadialGradient(grad,Abs(CornerRadius))
		End If
		DrawDrawable(BG, grad,X,Y,Width,Height,Angle)
	Else
		grad2.Initialize(Color1, CornerRadius)
		DrawDrawable(BG, grad2,X,Y,Width,Height,Angle)
	End If
End Sub
Sub DrawDrawable(BG As Canvas,Drawable As Object , X As Int, Y As Int, Width As Int,Height As Int, Angle As Float)
	If Angle = 0 Then
		BG.DrawDrawable(Drawable, SetRect(X,Y,Width,Height) )
	Else
		BG.DrawDrawableRotate(Drawable, SetRect(X,Y,Width,Height), Angle)
	End If
End Sub

'Align: 1=Bottom Right to Top Left, 2=Bottom to TOP, 3=Bottom Left to Top Right, 4=RIGHT to LEFT, 6=LEFT To RIGHT, 7=Top Right To Bottom Left, 8=TOP To Bottom, 9=Top Left To Bottom Right
'If CornerRadius < 0, then it'll be a sphere
Sub DrawGradient2(BG As Canvas, CLRS() As Int, Alignment As Int, X As Int, Y As Int, Width As Int, Height As Int, CornerRadius As Int, Angle As Float)As Boolean 
	Dim Align As String, grad As GradientDrawable 
	Select Case Alignment
		Case 1:Align="BR_TL"
		Case 2:Align="BOTTOM_TOP"
		Case 3:Align="BL_TR"
		Case 4:Align="RIGHT_LEFT"
		Case 6:Align="LEFT_RIGHT"
		Case 7:Align="TR_BL"
		Case 8:Align="TOP_BOTTOM"
		Case 9:Align="TL_BR"'\
		Case Else:Return False
	End Select
	grad.Initialize(Align,CLRS )
	If CornerRadius < 0 Then 
		SetRadialGradient(grad,Abs(CornerRadius))
	Else 
		grad.CornerRadius = CornerRadius
	End If
	DrawDrawable(BG, grad,X,Y,Width,Height, Angle)
	Return True 
End Sub


Sub DrawLCARmeter(BG As Canvas, X As Int,Y As Int,Width As Int, Height As Int, Percent As Int, ColorID As Int,tBlinkState As Boolean, alpha As Int)
	Dim  ColorInt As Int, Border As Int, Middle As Int , Unit As Int ,Y2 As Int,temp As Int,Width2 As Int, P As Path 'Color As LCARColor ,
	Border=2
	'If RedAlert Then ColorID = LCAR_RedAlert
	'color = lcarcolors.Get(colorid)
	'If tBlinkState Then 
	'	colorint=color.Selected
	'Else 
	'	colorint=color.Normal
	'End If
	ColorInt=GetColor(ColorID, tBlinkState,alpha)
	BG.DrawRect(SetRect(X,Y,Width,Height), ColorInt, False,2)

	
	Middle= (Height-(Border*2)) * ( (100-Percent)/100 )
	Unit=Height/6
	
	
	'bg.DrawRect(setrect(x+Border,y+Border,width-Border*2,Middle), Colors.black, True,0)
	'DrawGradient(BG, Colors.Black , colorint, 8, x+Border,y+Border,width-Border*2,Middle)
	DrawGradient(BG, Colors.Black , ColorInt, 2, X+Border,Y+Middle+2,Width-Border*2,Height-Middle-4,0,0)

	
	Y2=Y+Height -Unit
	Middle = Y+Middle
	Width2=(Width-Border*2)
	
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 1, Width2*0.3, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 2, Width2*0.3, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 3, Width2*0.15, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 4, Width2*0.15, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 5, Width2*0.3, ColorInt, Middle, Border)
	
	P.Initialize(X,Y)
	P.LineTo(X+Width,Y)
	P.LineTo(X+Width,Y+Height)
	P.LineTo(X,Y+Height)
	BG.ClipPath(P)
	DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 0, Width2*0.3, ColorInt, Middle, Border)
End Sub
Sub DrawLCARunit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Number As Int, Length As Int, Color As Int, Middle As Int, Border As Int)As Int 
	Dim Unit As Int, MaxLength As Int ,X2 As Int ,color2 As Int ,P As Path 
	Unit=Height/4
	If Number=0 Then
		MaxLength= Width*0.2		
'		If method1 Then
			DrawLCARunitLine(BG, X-1,Y-Border*2, MaxLength+1, Height+Border*2+1, Middle,Color)
			DrawLCARunitLine(BG,X+Width-MaxLength,Y-Border*2, MaxLength+1, Height+Border*2+1, Middle,Color)
'		Else
'			DrawLCARunitLine(BG, X-1,Y-Border, MaxLength+1, Height+Border*2, Middle,Color)
'			DrawLCARunitLine(BG,X+Width-MaxLength,Y-Border, MaxLength+1, Height+Border*2, Middle,Color)
'		End If
		BG.RemoveClip

	Else
		MaxLength = Width*0.4
		DrawLCARunitLine(BG,X,Y, MaxLength, Border, Middle, Color)
		DrawLCARunitLine(BG,X+Width-MaxLength,Y, MaxLength, Border, Middle, Color)
		'drawtext(BG, x+width/2, Y, Number, color,5,False)
		
		X2=Y + LCARfontheight*0.5
		color2=Color
		
		
		'If X2>=Middle Then color2 = Colors.Black 
		BG.DrawText(Number, X+Width/2, X2  , LCARfont, Fontsize,color2, "CENTER")
		
		If X2>=Middle Then' Color = Colors.Black 
			P.Initialize(X,Middle+1)
			P.lineto(X+Width,Middle+1)
			P.LineTo(X+Width,ScaleHeight)
			P.LineTo(X,ScaleHeight)
			BG.ClipPath(P)
			BG.DrawText(Number, X+Width/2, X2  , LCARfont, Fontsize,Colors.Black , "CENTER")
			BG.RemoveClip 
		End If
		
		
	End If
	X2= X+Width-Length
	
	DrawLCARunitLine(BG,X,Y+Unit, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X,Y+Unit*2, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X,Y+Unit*3, Length, Border, Middle, Color)
	
	DrawLCARunitLine(BG,X2,Y+Unit, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X2,Y+Unit*2, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X2,Y+Unit*3, Length, Border, Middle, Color)
	Return Y-Height
End Sub
Sub DrawLCARunitLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Middle As Int, Color As Int)
	Dim Height2 As Int ,P As Path 
	If Y< Middle Then
		If Y+Height-1 > Middle Then
			Height2= Middle-Y
			BG.DrawRect(SetRect(X,Y,Width,Height2),Color, True,0)
			Height=Height-Height2
			Y=Y+Height2
			
			'bg.DrawRect(setrect(x,y+height2,width,height-height2),Colors.black, True,0)
		End If
	End If

	If Y>=Middle Then Color = Colors.Black 
	BG.DrawRect(SetRect(X,Y,Width,Height),Color, True,0)
End Sub

Sub DrawLCARSlider(BG As Canvas, X As Int,Y As Int, Height As Int, Percent As Int, ColorID As Int,tBlinkState As Boolean,Alpha As Int ,IsMoving As Boolean, Horizontal As Boolean    )
	Dim FullSquares As Int, LastSquare As Int, ColorInt As Int, lastcolorint As Int, R As Int, G As Int, B As Int ,y2 As Int  , TotalHeight As Int,ItemHeight2 As Int,temp As Int,temp2 As Int',Perc As Double Color As LCARColor ,
	'If RedAlert Then ColorID = LCAR_RedAlert
	ColorInt = GetColor(ColorID, tBlinkState, Alpha)
	FullSquares= Floor(Percent/10)
	LastSquare= (Percent Mod 10) * (Alpha/255)
	lastcolorint = GetColor(ColorID, tBlinkState, LastSquare*25.5)
	If Horizontal Then
		BG.DrawRect(SetRect(X, Y, Height, LCARCorner.Height),  Colors.black , True ,1)
		y2=X+Height-LCARCorner.Width 
		TotalHeight=Height-LCARCorner.width*2- ListitemWhiteSpace*2
		ItemHeight2=(TotalHeight/10)-ListitemWhiteSpace
		For temp = y2-ListitemWhiteSpace - ItemHeight2 To X+LCARCorner.width+ListitemWhiteSpace Step -(ItemHeight2+ListitemWhiteSpace)
			temp2=temp2+1
			If temp2<= FullSquares Then
				BG.DrawRect(SetRect(temp, Y, ItemHeight2,LCARCorner.Height ),   ColorInt , True ,1)
			Else If temp2=FullSquares+1 Then
				BG.DrawRect(SetRect(temp, Y, ItemHeight2,LCARCorner.Height ),   lastcolorint , True ,1)
			End If
		Next
		temp=temp+ (ItemHeight2-LCARCorner.width)
		BG.DrawRect(SetRect(temp, Y, LCARCorner.width,LCARCorner.Height),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCorner,LCARCornera, SetRect(temp,Y, LCARCorner.Width , LCARCorner.Height), False,False ,IsMoving)
		BG.DrawRect(SetRect(y2, Y, LCARCorner.width,LCARCorner.Height-1),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,y2, LCARCornerSlider.Width , LCARCornerSlider.Height), False,True ,IsMoving)
	Else
		BG.DrawRect(SetRect(X, Y,  LCARCornerSlider.Width,Height),  Colors.black , True ,1)
		y2=Y+Height-LCARCornerSlider.Height
		TotalHeight=Height-LCARCornerSlider.Height*2- ListitemWhiteSpace*2
		ItemHeight2=(TotalHeight/10)-ListitemWhiteSpace
		For temp = y2-ListitemWhiteSpace - ItemHeight2 To Y+LCARCornerSlider.Height+ListitemWhiteSpace Step -(ItemHeight2+ListitemWhiteSpace)
			temp2=temp2+1
			If temp2<= FullSquares Then
				BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,ItemHeight2),   ColorInt , True ,1)
			Else If temp2=FullSquares+1 Then'draw last square
				BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,ItemHeight2), lastcolorint,True,1)
			End If
		Next
		temp=temp+    (ItemHeight2-LCARCornerSlider.Height)
		BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,LCARCornerSlider.Height),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,temp, LCARCornerSlider.Width , LCARCornerSlider.Height), False,False ,IsMoving)
		BG.DrawRect(SetRect(X, y2, LCARCornerSlider.width,LCARCornerSlider.Height-1),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,y2, LCARCornerSlider.Width , LCARCornerSlider.Height), False,True ,IsMoving)
	End If
End Sub 

'if PatchSize is 0, it'll draw the whole image scaled to fit, AND if ScaleFactor is greater than 1 then it'll force it to fit to the edge. If it's less than 1, it'll be shrunk
Sub Draw9Patch(BG As Canvas, Src As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, PatchSize As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, Scale As Float, Alpha As Int)
	Dim DestSize As Int = PatchSize * Scale
	If PatchSize = 0 Then
		Dim Thumb As Point = API.ThumbSize(SrcWidth, SrcHeight, DestWidth, DestHeight, Scale<>1, False)
		If Scale<1 Then
			Thumb.x=Thumb.X*Scale
			Thumb.y=Thumb.y*Scale
		End If
		LCARSeffects2.DrawBMP(BG,       Src,       SrcX,   SrcY,   SrcWidth,  SrcHeight,  DestX+ DestWidth*0.5 - Thumb.X * 0.5, DestY+ DestHeight*0.5 - Thumb.Y * 0.5, Thumb.X , Thumb.Y, Alpha, False,False)
	Else
		LCARSeffects.MakeClipPath(BG,DestX, DestY, DestWidth+1, DestHeight+1)
			LCARSeffects2.TileBitmap(BG, Src, SrcX+PatchSize, SrcY+PatchSize, PatchSize,PatchSize,  DestX+DestSize, DestY+DestSize, DestWidth-DestSize*2, DestHeight-DestSize*2, False,False, Alpha,Scale)'middle
			'edges
			LCARSeffects2.TileBitmap(BG, Src,SrcX+PatchSize, SrcY, PatchSize,PatchSize, DestX+DestSize, DestY, DestWidth-DestSize*2, 0, False,False, Alpha, Scale)'top edge
			LCARSeffects2.TileBitmap(BG, Src,SrcX+PatchSize, SrcY+PatchSize*2, PatchSize,PatchSize, DestX+DestSize, DestY+DestHeight-DestSize, DestWidth-DestSize*2, 0, False,False, Alpha, Scale)'bottom edge
			
			LCARSeffects2.TileBitmap(BG, Src,SrcX, SrcY+PatchSize, PatchSize,PatchSize, DestX, DestY+DestSize,  0, DestHeight-DestSize*2, False,False, Alpha, Scale)'left edge
			LCARSeffects2.TileBitmap(BG, Src,SrcX+PatchSize*2, SrcY+PatchSize, PatchSize,PatchSize, DestX+DestWidth-DestSize, DestY+DestSize, 0, DestHeight-DestSize*2, False,False, Alpha, Scale)'right edge
			'corners
			BG.DrawBitmap(Src, LCARSeffects4.SetRect(SrcX,SrcY, PatchSize, PatchSize), LCARSeffects4.SetRect(DestX, DestY, DestSize,DestSize))'top left corner
			BG.DrawBitmap(Src, LCARSeffects4.SetRect(SrcX,SrcY+PatchSize*2, PatchSize, PatchSize), LCARSeffects4.SetRect(DestX, DestY+DestHeight-DestSize, DestSize,DestSize))'bottom left corner
			BG.DrawBitmap(Src, LCARSeffects4.SetRect(SrcX+PatchSize*2, SrcY, PatchSize, PatchSize), LCARSeffects4.SetRect(DestX+DestWidth-DestSize,DestY,DestSize,DestSize))'top right corner
			BG.DrawBitmap(Src, LCARSeffects4.SetRect(SrcX+PatchSize*2, SrcY+PatchSize*2, PatchSize, PatchSize), LCARSeffects4.SetRect(DestX+DestWidth-DestSize,DestY+DestHeight-DestSize,DestSize,DestSize))'bottom right corner
		BG.RemoveClip 
	End If
End Sub 
Sub DrawBitmap(BG As Canvas,  AAenabled As Bitmap, AAdisabled As Bitmap, Dest As Rect, FlipX As Boolean , FlipY As Boolean ,IsMoving As Boolean  ) As Boolean 
	If FlipX Or FlipY Then
		If LOD And (Not(AntiAliasing) Or IsMoving) Then
			BG.DrawBitmapFlipped(AAdisabled,Null, Dest,FlipY,FlipX)
		Else
			BG.DrawBitmapFlipped(AAenabled,Null, Dest,FlipY,FlipX)
			Return True
		End If
	Else
		If LOD And (Not(AntiAliasing) Or IsMoving) Then
			BG.DrawBitmap(AAdisabled, Null, Dest)
		Else
			BG.DrawBitmap(AAenabled, Null, Dest)
			Return True
		End If
	End If
End Sub

Sub DrawLCARslantedbutton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int,Alpha As Int, State As Boolean, Text As String , Align As Int, TextAlign As Int)
	'1 pixels shifted per 11 vertical pixels
	Dim Plist As Path,Slant As Int, Color As Int, Radius As Int
	Color = GetColor(ColorID, State, Alpha)
	Slant=Height/11
	Radius=10
	ActivateAA(BG,True)
	Select Case Align 
	
		Case -4, -5' ( and )
			Radius=Height*0.5
			Height=Radius*2+1
			If Align=-4 Then
				LCARSeffects.MakeClipPath(BG,X,Y,Radius,Height)
				BG.DrawCircle(X+Radius,Y+Radius, Radius, Color, True, 0)
				BG.RemoveClip 
				DrawRect(BG,X+Radius,Y, Width-Radius+1,Height,Color,0)
			Else
				LCARSeffects.MakeClipPath(BG,X+Width-Radius,Y,Radius,Height)
				BG.DrawCircle(X+Width-Radius,Y+Radius, Radius, Color, True, 0)
				BG.RemoveClip 
				DrawRect(BG,X,Y, Width-Radius+1,Height,Color,0)
			End If
			ActivateAA(BG,False)
			If Text.length>0 Then DrawTextbox(BG,    Text,     LCAR_Black,X+Radius,Y+Height-Radius, Width-Radius*2, 0, TextAlign)
			Return
			
		Case -1,-2,-3'|_|
			LCARSeffects2.MakePoint(Plist, X,Y)
			LCARSeffects2.MakePoint(Plist, X+Width,Y)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height)
			LCARSeffects2.MakePoint(Plist, X,Y+Height)
			If Align=-3 Then'|u| curved bottom
				BG.DrawOval( SetRect(X, Y+Height-Radius,Width,Radius*2) , Color,True,0)
			Else If Align=-2 Then'|^| curved top
				BG.DrawOval( SetRect(X, Y-Radius,Width,Radius*2) , Color,True,0)
			End If
			
		Case 1 '/_|
			TextAlign=9
			LCARSeffects.DrawPartOfCircle(BG, X+Slant, Y,Radius, 0, Color,0,0)'top
			LCARSeffects.DrawPartOfCircle(BG, X, Y+Height-Radius,Radius, 2, Color,0,0)'bottom 
			LCARSeffects2.MakePoint(Plist, X,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Radius-1,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Radius-1,Y+Height)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height)
			LCARSeffects2.MakePoint(Plist, X+Width,Y)
			LCARSeffects2.MakePoint(Plist, X+Slant+Radius-1,Y)
			LCARSeffects2.MakePoint(Plist, X+Slant+Radius-1,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Slant,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X,Y+Height-Radius+1)
		Case 2' |_\
			TextAlign=7
			LCARSeffects.DrawPartOfCircle(BG, X+Width-Slant-Radius, Y,Radius, 1, Color,0,0)'top
			LCARSeffects.DrawPartOfCircle(BG, X+Width-Radius, Y+Height-Radius,Radius, 3, Color,0,0)'bottom 
			LCARSeffects2.MakePoint(Plist, X,Y)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant-Radius+1,Y)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant-Radius+1,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Width-Radius+1,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Width-Radius+1,Y+Height)
			LCARSeffects2.MakePoint(Plist, X,Y+Height)
		Case Else
			Return
	End Select
	
	BG.DrawPath(Plist, Color, False, 1)
	BG.DrawPath(Plist, Color, True, 0)
	
	'BG.DrawRect(LCARSeffects2.CopyPlistToPath(Plist,P, BG, Color,  1, True,False) , Color, True, 0)
	'BG.RemoveClip 
	If Text.length>0 Then DrawTextbox(BG,    Text,     LCAR_Black,X+Radius,Y+Height-Radius, Width-Radius*2, 0, TextAlign)
	ActivateAA(BG,False)
End Sub

'Textalign: 0 has flat, 1 no flat, 2 wide
Sub DrawLCARbit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Alpha As Int, Align As Int, TextAlign As Int)
	If Align= 1 Or Align = 3 Then Height=Height-1
	Dim Color As Int = GetColor(ColorID, State, Alpha), SmallAxis As Int = Min(Width,Height), Radius As Int = SmallAxis*0.5, Width2 As Int = Width*0.5, Height2 As Int = Height *0.5
	ActivateAA(BG,True)
	Select Case TextAlign
		Case 0'flat part (square)
			BG.DrawCircle(X+Radius, Y+Radius, Radius, Color, True, 0)
			Select Case Align
				Case 0: LCARSeffects4.DrawRect(BG,X,Y,Width,Height2, Color,0)'north
				Case 1: LCARSeffects4.DrawRect(BG,X+Width2,Y,Width2,Height, Color,0)'east
				Case 2: LCARSeffects4.DrawRect(BG,X,Y+Height*0.5,Width,Height2, Color,0)'south
				Case 3: LCARSeffects4.DrawRect(BG,X,Y,Width2,Height, Color,0)'west
			End Select
		Case 1'no flat part (square)
			LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			Select Case Align
				Case 0,2'north/south
					X=X+Width2
					If Align=2 Then Y = Y+Height
				Case 1,3'east/west
					Y=Y+Height2
					If Align=1 Then X=X+Width
			End Select
			BG.DrawCircle(X,Y,Radius,Color,True,0)
			BG.RemoveClip 
		Case 2'wide (non-square)
			LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			Select Case Align
				Case 0,2'north/south
					LCARSeffects4.DrawRect(BG, X, Y + API.IIF(Align=0,0, Height2), Width,Height2, Color, 0)
					Radius=Height2
					If Align=0 Then Y= Y+Height2
					BG.DrawCircle(X+Radius,Y,Radius,Color,True,0)
					BG.DrawCircle(X+Width-Radius,Y,Radius,Color,True,0)
					LCARSeffects4.DrawRect(BG, X+Radius, Y, Width-Height, Radius, Color,0)
				Case 1,3'east/west
					'not complete
			End Select
			BG.RemoveClip 
	End Select
End Sub 

'																	 false=normal/not clicked, true=bright/clicked
Sub DrawLCARbutton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Text As String, SideText As String, LWidth As Int, RWidth As Int, RhasCurve As Boolean, WhiteSpace As Int, TextAlign As Int, Number As Int, Alpha As Int ,IsMoving As Boolean )
	Dim Color As Int , Start As Int ,X2 As Int , TextColorID As Int ,NumberText As String, NumberTextColorID As Int,NumberSize As Int  'Temp As Int, LCARC As LCARColor
	'If RedAlert Then ColorID= RedAlertMode'LCAR_RedAlert
	'LCARC= lcarcolors.Get(colorid)
	NumberTextColorID=ColorID
	Color= GetColor(ColorID, State, Alpha)
	If State Then 
		'Color = lcarc.Selected
		If RedAlert Then NumberTextColorID = LCAR_White 
	Else 
		'color = lcarc.Normal
	End If
	'If RWidth<0 Then RWidth = Width+RWidth
	If LWidth>0 Or (RWidth>0 And RhasCurve) Then 
		Height=LCARCorner.Height
		If RhasCurve And (LCARCorner.Width*2)>Width+2 And LWidth>0 Then 
			LWidth=0
			RhasCurve=False
			RWidth=0
		End If	
	End If
	Start=X
	TextColorID=LCAR_Black
	If Not (RedAlert) And ColorID=TextColorID Then TextColorID =LCAR_Orange
	
	If LWidth>0 Then
		Height= LCARCorner.Height
	
		'bg.DrawBitmap(lcarcorner, Null, SetRect(x,y, lcarcorner.Width, lcarcorner.Height))
		If DoVector Then
			X2=Height*0.5
			DrawCircle(BG, X,Y,X2, Height,  6 ,Color)
			BG.DrawRect(SetRect(X+X2-1, Y, LWidth-X2+1,Height), Color, True ,1)
		Else
			BG.DrawRect(SetRect(X, Y, LWidth,Height), Color, True ,1)
			DrawBitmap(BG, LCARCorner,LCARCornera, SetRect(X,Y, LCARCorner.Width, LCARCorner.Height), False, False , IsMoving)
		End If
		
		'bg.DrawBitmapFlipped(lcarcorner, Null, SetRect(x,y+lcarcorner.Height+1, lcarcorner.Width, lcarcorner.Height) , True,False)
		Start=Start+LWidth+WhiteSpace
		Width=Width-LWidth-WhiteSpace
		
		If Number>-1 Then
			NumberText=Min(999, Number) 'API.Left(Number,3)
			Do Until NumberText.Length = 3
				NumberText = "0" & NumberText
			Loop
			CheckNumbersize(BG)
			NumberSize=NumberWhiteSpace
		Else If TextAlign=LCAR_BigText Then
			NumberText = Text
			Text=""
			CheckNumbersize(BG)
			NumberSize = API.TextWidthAtHeight(BG,LCARfont, NumberText, NumberTextSize)
		End If
		If NumberSize>0 Then
			DrawLCARtextbox(BG, Start,Y,  NumberSize, NumberTextSize,0,0, NumberText, NumberTextColorID, LCAR_Black, LCAR_Black, State,False, 1,Alpha)
			Start=Start+ NumberSize
			Width=Width-NumberSize		
		End If
		
	End If
	If RWidth>0 Then
		X2=Start+Width-RWidth
		If RhasCurve Then
			'bg.DrawBitmapFlipped(lcarcorner,Null, setrect(x2 + rwidth-lcarcorner.Width+1,y, lcarcorner.Width, lcarcorner.Height),False,True)
			If DoVector Then
				DrawCircle(BG, X2 + RWidth-LCARCorner.Width+1,Y,LCARCorner.Width, Height,  4 ,Color)
			Else
				BG.DrawRect( SetRect(X2 , Y, RWidth, Height) , Color ,True,1)
				DrawBitmap(BG, LCARCorner,LCARCornera, SetRect(X2 + RWidth-LCARCorner.Width+1,Y, LCARCorner.Width, LCARCorner.Height),True,False ,IsMoving )
			End If
			'bg.DrawBitmapFlipped(lcarcorner,Null, setrect(x2,y+lcarcorner.Height+1, lcarcorner.Width, lcarcorner.Height),True,True)
		Else
			BG.DrawRect( SetRect(X2 , Y, RWidth, Height) , Color ,True,1)
		End If
		If SideText.Length>0 Then  DrawTextbox(BG, SideText, TextColorID,X2,Y, RWidth,Height, 5 )
		'drawtextbox(bg, sidetext, textcolorid, x2, y, rwidth,Height, 5 )
		'If sidetext.Length>0 Then  drawtext(bg,x2+rwidth/2-1,y+ height/2 - TextHeight(bg,sidetext)/2, sidetext, Textcolorid,5)
		Width=Width-RWidth-WhiteSpace
	End If
	BG.DrawRect(SetRect(Start,Y,Width,Height), Color,True,1)
	
	'Log("start: " &  start & " width: " & width  & " twidth: " &  textwidth(bg,text))
	'Select Case TextAlign
    '    'Case 1, 2, 3: Y = Y  'top row
    '    Case 4, 5, 6: Y = Y + height/2 - TextHeight(bg,text)/2  'middle row
    '    Case 7, 8, 9: tY = Y + Height - TextHeight(bg,text) 'bottom row
    'End Select
    'Select Case TextAlign
    '    Case 1, 4, 7: X = start + 3 ' left column
    '    Case 2, 5, 8: X = start + (width/2) - (textwidth(bg,text)/2) 'middle column
    '    Case 3, 6, 9: X = start + Width - textwidth(bg,Text) - 2 'right column
    'End Select
		'Log(Text & " X: (after) " & X )
	'drawtext(bg,x,y, Text, Textcolorid,TextAlign,False,alpha, LCARfontheight)
	If Text.Length>0 Then 	
		If Text = LCAR_Block Then
			Start = Start + Width/2 - 2
			Width=Width/2 - 2
			Y= Y+ Height/2 + 2
			Height=Height/3
			DrawRect(BG, Start,Y,Width,Height,Colors.Black,0)
			'Log("TEXTBLOCK")
		Else
			'Log(X & " " & Start & " " & Width & " " & Text)
			If SmallScreen Then LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			DrawTextbox(BG,  Text, TextColorID, Start+2,Y+2, Width-4,Height-4, TextAlign)
			If SmallScreen Then BG.RemoveClip 
		End If
	End If
	'If sidetext.Length>0 Then   drawtext(bg,x2+rwidth/2-1,y +LCARfontheight/2, sidetext, Textcolorid,5,False,alpha, LCARfontheight)'+ height/2 - TextHeight(bg,sidetext)/2
		'DrawTextbox(bg, text, Textcolorid, start+2,y+2, width-4,height-4, 5)
	'End If
	ActivateAA(BG,False)
End Sub






Sub ForceHide(ElementID As Int )
	Dim Element As LCARelement , Group As LCARgroup 
	Element= LCARelements.Get(ElementID)
	
	Group=LCARGroups.Get( Element.Group )
	Group.Visible=False
	LCARGroups.Set( Element.Group, Group)
	
	Element.Opacity.Current =0
	Element.Opacity.Desired=0
	Element.Visible=False
	LCARelements.Set(ElementID,Element)
End Sub

Sub ExDraw As ABExtDrawing
	'If IsInternal Then
	
		Return Main.ExDraw 'HARD CODED ROOT REFERENCE
	'Else
		'Log("UNCOMMENT WallpaperService.ExDraw")
	'	Return WallpaperService.ExDraw
	'End If
End Sub

'StrokeWidth: 0 = filled
Sub DrawRoundedRectangle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CornerRadius As Int, Color As Int, StrokeWidth As Float)
    Dim pt As ABPaint, dest As ABRectF 
    pt.Initialize
    pt.SetColor(Color)
	dest.Initialize(X,Y, X+Width,Y+Height)
    If StrokeWidth=0 Then
        pt.SetStyle(pt.Style_FILL)
    Else
		pt.SetStrokeWidth(StrokeWidth)
        pt.SetStyle(pt.Style_STROKE)
    End If
    ExDraw.drawRoundRect(BG, dest, CornerRadius, CornerRadius, pt)
End Sub

Sub ForceShow(ElementID As Int, Visible As Boolean )
	Dim Element As LCARelement =LCARelements.Get(ElementID), Group As LCARgroup =LCARGroups.Get( Element.Group )
	If ElementID = 113 Then Log("FORCE SHOW PULASKI, GROUP " & Element.Group)
	Element.Visible = True
	Group.Visible=True
	If Visible Then
		Element.IsClean=False
		Element.Opacity.Current=0
		Element.Opacity.Desired=255
	Else 
		If Element.Visible Then
			Element.Opacity.Current=255
			Element.Opacity.Desired=0
		Else
			Element.Opacity.Current =0
			Element.Opacity.Desired=0
		End If
	End If
End Sub

Sub SetRect(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	Dim Rect1 As Rect 
	Rect1.Initialize(X,Y,X+Width-1,Y+Height-1)
	Return Rect1
End Sub

Sub AddGroup As Int 
	Dim group As LCARgroup
	group.Initialize 
	group.LCARlist.Initialize 
	group.HoldList.Initialize 
	group.Visible = True 
	LCARGroups.Add(group)
	Return LCARGroups.Size-1
End Sub

Sub ForceGroupCount(Count As Int)
	Dim temp As Int
	For temp = LCARGroups.Size To Count
		AddGroup
	Next
End Sub

Sub AddLCARtoGroup(LCARid As Int, GroupID As Int)
	Dim Group As LCARgroup
	ForceGroupCount(GroupID+1)
	Group = LCARGroups.Get(GroupID)
	Group.LCARlist.Add(LCARid)
	Group.HoldList.add(1)
	LCARGroups.Set(GroupID,Group)
End Sub

Sub RemoveLCARfromGroup(LCARid As Int, GroupID As Int) As Boolean 
	Log("REMOVE THIS CALL")
'	Dim Group As LCARgroup,temp As Int 
'	If GroupID=-1 Then GroupID = GetElement(LCARid).Group 
'	Group = LCARGroups.Get(GroupID)
'	For temp = 0 To Group.LCARlist.Size-1 
'		If Group.LCARlist.Get(temp)=LCARid Then
'			Group.LCARlist.RemoveAt(temp)
'			Group.HoldList.RemoveAt(temp)
'			Return True
'		End If
'	Next
End Sub
Sub FindElement(ElementType As Int) As Int
	Dim Element As LCARelement, temp As Int
	For temp = 0 To LCARelements.Size - 1 
		Element = LCARelements.Get(temp)
		If Element.ElementType = ElementType Then Return temp
	Next
	Return -1
End Sub
Sub FindElementsGroup(LCARid As Int) As Point 'X = group, Y=index in group
	Dim Element As LCARelement ,Group As LCARgroup ,temp As Int,Ret As Point 
	Element = LCARelements.Get(LCARid)
	Ret.Initialize 
	Ret.X = Element.Group 
	Group = LCARGroups.Get(Element.Group)
	Ret.Y=Group.LCARlist.IndexOf(LCARid)
	
	'For temp = 0 To group.LCARlist.Size -1
	'	If group.LCARlist.Get(temp) = lcarid Then
	'		ret.Y=temp 
			Return Ret
	'	End If
	'Next 
End Sub 

Sub SetGroupIndexHold(LCARid As Int,HoldCount As Int )
	Dim Ret As Point ,Group As LCARgroup
	Ret=FindElementsGroup(LCARid)
	Group = LCARGroups.Get(Ret.x)
	Group.HoldList.Set(Ret.Y, HoldCount)
	LCARGroups.Set(Ret.x,Group)
End Sub
Sub ReorderGroup(LCARid As Int, Index As Int)
	Dim Ret As Point , Hold As Int, Group As LCARgroup
	Ret=FindElementsGroup(LCARid)
	Group = LCARGroups.Get(Ret.x)'X=group, Y=index
	
	Hold = Group.HoldList.Get(Ret.Y)
	Group.LCARlist.RemoveAt(Ret.y)
	Group.HoldList.RemoveAt(Ret.Y)
	
	If Index=-1 Then
		Group.LCARlist.Add(LCARid)
		Group.HoldList.Add(Hold)
	Else
		Group.LCARlist.AddAllAt(Index, Array As Int(LCARid))
		Group.HoldList.AddAllAt(Index, Array As Int(Hold))
	End If
	IsClean=False
	'LCARGroups.Set(Ret.X, Group)
End Sub
Sub ResetRedAlert()
	Dim temp As Int, Group As LCARgroup , Element As LCARelement 
	For temp = 0 To LCARGroups.Size-1
		Group = LCARGroups.Get(temp)
		Group.RedAlert=0
		If Group.HoldList.Size>0 Then Group.Hold = Group.HoldList.Get(0)  Else Group.Hold=1
		LCARGroups.Set(temp,Group)
	Next
End Sub











Sub SetRedAlert(State As Boolean, SubCalling As String) As Boolean 
	Dim event As ElementClicked , WasRedAlert As Boolean = RedAlert
	Log(SubCalling & " set red alert to " & State)
	If Not( LCARSeffects.IsPromptVisible(Null)) Then
		If State Then ResetRedAlert
		RedAlertMode=LCAR_RedAlert
		RedAlert = State' Not( redalert)
		IsClean =False 
		event.Initialize 	
		event.ElementType=LCAR_CodeChanged
		If State Then event.Index =1
		EventList.Add(event)
	End If
	If Not(State) And RedAlert Then Return True
End Sub

Sub LCAR_ListItemsPerCol(ColsLandscape As Int,ColsPortrait As Int, ListItemSize As Int ) As Int 'ListID As Int)As Int
	Dim Cols As Int', Lists As LCARlist',Rows As Int
	'Lists= lcarlists.Get(ListId)
	Cols=LCAR_ListCols(ColsLandscape , ColsPortrait )'rows=LCAR_ListRows(listid)
	Return Floor(ListItemSize / Cols)
End Sub

Sub LCAR_ListHeight(ListID As Int)As Int
	Dim Lists As LCARlist,  Dimensions As tween
	Dim ItemsOnScreen As Int, ItemsPerCol As Int 
	Lists= LCARlists.Get(ListID) 
	Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
	ItemsOnScreen = LCAR_ListRows(Dimensions.offY )
	ItemsPerCol = LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size )
	
    If ItemsPerCol < ItemsOnScreen Then
        Return ItemsOnScreen * (ItemHeight + ListitemWhiteSpace)
    Else
        Return Dimensions.offY 
    End If
End Sub

Sub LCAR_ListRows(ListHeight As Int) As Int' ListID As Int)As Int
	Dim Height As Long', Lists As LCARlist,  Dimensions As tween 
	'Lists= lcarlists.Get(ListID) 
	'Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
	Return Floor(ListHeight  / (ItemHeight + ListitemWhiteSpace))
End Sub

Sub LCAR_ListCols(ColsLandscape As Int,ColsPortrait As Int) As Int' ListID As Int)As Int
	'If SmallScreen AND OneColOnly Then 
	'	Return 1
	'Else
		If Landscape Then 
			Return ColsLandscape'lists.
		Else
			Return ColsPortrait'lists.
		End If
	'End If
End Sub

Sub LCAR_ListID(Name As String) As Int
	Dim temp As Int, Lists As LCARlist 
	For temp = 0 To LCARlists.Size-1
		Lists= LCARlists.Get(temp) 
		If Lists.Name.EqualsIgnoreCase(Name) Then
			Return temp
		End If
	Next
	Return -1
End Sub
Sub LCAR_AddList(Name As String, SurfaceID As Int, ColsPortrait As Long, ColsLandscape As Long, X As Long, Y As Long, Width As Long, Height As Long, Visible As Boolean, WhiteSpace As Int,  LWidth As Int,  RWidth As Int, RhasCurve As Boolean ,  ShowNumber As Boolean, MultiSelect As Boolean, Style As Int  ) As Int
	Dim Lists As LCARlist
	Lists.Initialize 
	Lists.alignment=4
	Lists.SurfaceID = SurfaceID 
	Lists.Name = Name
	Lists.Style=Style
	Lists.ColsLandscape = ColsLandscape
	Lists.ColsPortrait=ColsPortrait
	Lists.IsClean=False
	Lists.isDown = False
	Lists.isScrolling=False
	Lists.MultiSelect = MultiSelect
	Lists.SelectedItem=-1
	Lists.RhasCurve = RhasCurve
	Lists.Visible = Visible
	Lists.WhiteSpace = WhiteSpace
	Lists.LWidth=LWidth
	Lists.RWidth =RWidth
	Lists.ShowNumber= ShowNumber
	
	Lists.ListItems.Initialize 
	
	Lists.Opacity.Initialize 
	Lists.Opacity.Desired=255
	Lists.Opacity.Current=255
	
	Lists.LOC.Initialize 
	Lists.LOC.currX=X
	Lists.LOC.currY=Y 
	
	Lists.Size.Initialize 
	Lists.Size.currX=Width
	Lists.Size.currY =Height
	
	LCARlists.Add(Lists)
	LCARVisibleLists.Add(Visible)

	Return LCARlists.Size-1
End Sub

Sub LCAR_AddListItems(ListID As Int, ColorID As Int, WhiteSpace As Int, Items As List)As Int
	Dim temp As Int
	For temp = 0 To Items.Size-1
		LCAR_AddListItem(ListID, Items.Get(temp),  ColorID,  -1 , Items.Get(temp), False, "",  WhiteSpace,  False,-1)
	Next
	Return Items.Size'*itemheight) +3)
End Sub

Sub LCAR_AddLCARcolors(ListID As Int, doText As Boolean )As Int
	Dim temp As Int ,Text As String , COLOR As LCARColor ,ret As Int
	For temp = 0 To LCARcolors.Size -1
		If temp <> LCAR_RedAlert Then
			If doText Then 
				COLOR = LCARcolors.Get(temp)
				Text = COLOR.Name 
			End If
			LCAR_AddListItem(ListID, Text.ToUpperCase, temp, -1, "", False, "", 0, False,-1)
			ret=ret+1
		End If
	Next
	Return ret
End Sub

Sub LCAR_RemoveListitem(ListID As Int, ItemID As Int)
	Dim Lists As LCARlist 
	If ListID>-1 And ListID< LCARlists.Size And (ItemID>-1 Or ItemID = LCAR_SelectedItem) Then
		Lists=LCARlists.Get(ListID) 
		If ItemID = LCAR_SelectedItem Then ItemID = Lists.SelectedItem
		If ItemID = LCAR_LastListitem Or ItemID>=Lists.ListItems.Size Then ItemID = Lists.ListItems.Size-1
		Lists.ListItems.RemoveAt(ItemID)
		Lists.IsClean=False
		'LCARlists.Set(ListID,Lists)
	End If
End Sub 

Sub ForceRandomColor As Int 
	Dim temp As Int 
	temp = LCAR_RandomColor
	Do While temp = CurrRandom
		temp = LCAR_RandomColor
	Loop
	CurrRandom=temp
	Return temp
End Sub

'If Index = -1, then add to the end, otherwise it'll be added BEFORE that listitem
Sub LCAR_AddListItem(ListID As Int, Text As String, ColorID As Int, Number As Int, Tag As String, Selected As Boolean, SideText As String, WhiteSpace As Int,IsMint As Boolean, Index As Int ) As Int
	Dim ListItem As LCARlistitem , Lists As LCARlist
	ListItem.Initialize
	If ColorID= LCAR_Random Then
		'LessRandom As Boolean,	CurrRandom As Int,			CurrListID As Int:
		'Log(LessRandom & " " & CurrRandom)
		If LessRandom Then
			If CurrListID <> ListID Then
				'Log("FORCED RANDOM " & CurrListID & " " & ListID)
				ForceRandomColor
				CurrListID=ListID
			End If
			ColorID = CurrRandom
		Else
			ColorID = LCAR_RandomColor
		End If
	Else If ColorID = LCAR_RandomTheme Then
		ColorID = Rnd(-CurrentTheme.ColorCount ,0)
	End If
	
	ListItem.ColorID=ColorID
	ListItem.IsClean=False
	ListItem.Number =Number
	ListItem.Selected=Selected
	ListItem.Side=SideText
	ListItem.Tag=Tag
	ListItem.Text=Text
	ListItem.WhiteSpace =WhiteSpace
	
	Lists=LCARlists.Get(ListID) 
	
	If Lists.Style=CHX_Iconbar Then
		If LCARSeffects3.CHX_Fontsize=0 Then LCARSeffects3.CHX_Fontsize = Fontsize
		ListItem.WhiteSpace = EmergencyBG.MeasureStringWidth(Text, LCARSeffects3.CHX_Font, LCARSeffects3.CHX_Fontsize)
		Lists.ColsLandscape = Max(Lists.ColsLandscape,ListItem.WhiteSpace)
	End If
	
	If IsMint Then 
		Lists.IsClean = False
		Lists.ForcedMint = ListItem
	Else
		If Index=-1 Then
			Lists.ListItems.Add(ListItem)
			Return Lists.ListItems.Size-1
		Else
			Lists.ListItems.InsertAt(Index,ListItem)
			Return Index
		End If
	End If
	'LCARlists.Set(ListID, Lists)
End Sub



Sub MaxRandomColors As Int
	Return 6
End Sub
Sub DrawLCARchart(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Percent As Int , ColorID As Int, Align As Int, Align2 As Int, Alpha As Int,Style As Int,SecColorID As String  )
	Dim Color As Int,  BGColor As Int,Stroke As Int,temp As Int,temp2 As Int
	Stroke=2
	If RedAlert Then
		Color=GetColor(LCAR_DarkBlue, False,Alpha)
		BGColor=Colors.White'GetColor(LCAR_DarkBlue, False,Alpha)
	Else
		Color=GetColor(ColorID, False,Alpha)
		Select Case SecColorID
			Case 0, "": BGColor=GetColor(LCAR_DarkBlue, False,Alpha)
			Case 1: BGColor=GetColor(LCAR_DarkBlue, True,Alpha)
			Case 2: BGColor=GetColor(Classic_Blue, False,Alpha)
			Case 3: BGColor=GetColor(Classic_Blue, True,Alpha)
			Case 4: BGColor=GetColor(LCAR_Purple, False,Alpha)
			Case 5: BGColor=GetColor(LCAR_Purple, True,Alpha)
		End Select
	End If
	Select Case Align
		Case -1'top
			BG.DrawLine(X, Y, X+Width, Y, Color,Stroke)
		Case 0,LCAR_Random 'normal
			Select Case Style
				Case LCAR_Chart
					BG.DrawRect(SetRect(X,Y,  Width* (Percent*0.01), Height), BGColor, True,0)
				Case LCAR_ChartNeg
					temp=(Width*0.5)
					If Percent>0 Then
						BG.DrawRect(SetRect(X+temp,Y,  temp * (Percent*0.01), Height), BGColor, True,0)
					Else If Percent<0 Then
						temp2=temp * (Percent*0.01)
						BG.DrawRect(SetRect(X+temp-temp2,Y,  temp2, Height), BGColor, True,0)
					End If
			End Select
			BG.DrawRect(SetRect(X,Y,  Width, Height),Color,False,Stroke)
		Case 1'bottom
			BG.DrawLine(X, Y+Height-1, X+Width, Y+Height-1, Color,Stroke)
	End Select
	Select Case Align2
		Case -1'left edge
			If Align=0 Then
				BG.DrawRect(SetRect(X,Y,  ChartSpace, Height),Color,True,0)
			Else
				BG.DrawRect(SetRect(X-Stroke,Y,  ChartSpace+Stroke, Height),Color,True,0)
			End If
		Case 1'right edge
			BG.DrawRect(SetRect(X+Width-1-ChartSpace,Y,  ChartSpace, Height),Color,True,0)
			If Align <> 0 Then BG.DrawRect(SetRect(X-Stroke,Y,  Stroke+Stroke, Height),Color,True,0)
	End Select
	
	For BGColor = X To X+Width Step ChartWidth
		BG.DrawLine(BGColor, Y, BGColor, Y+Height-1, Color,Stroke)
	Next
	'If align<>0 Then bg.DrawLine(x,  y, BGColor, y+height-1, color,Stroke)
End Sub 


Sub SetListitemColor(ListID As Int, ItemID As Int, ColorID As Int) As Int 
	Dim Lists As LCARlist, ListItem As LCARlistitem
	If ListID < LCARlists.Size Then
		Lists= LCARlists.Get(ListID)
		If ItemID < Lists.ListItems.Size Then 
			ListItem=Lists.ListItems.Get(ItemID)
			If ColorID =-1 Then ColorID=CurrRandom
			ListItem.ColorID=ColorID
			Return ColorID
		End If
	End If
	Return -1
End Sub
Sub DeRandomizeColors(ListID As Int, ColorID As Int)
	Dim temp As Int, Lists As LCARlist, ListItem As LCARlistitem,dochart As Boolean
	If ColorID = LCAR_Random Then
		RandomizeColors(ListID)
	Else
		Lists= LCARlists.Get(ListID)
		Select Case Lists.Style 
			Case LCAR_Chart, LCAR_ChartNeg: dochart = True
		End Select
		For temp = 0 To Lists.ListItems.Size-1
			ListItem=Lists.ListItems.Get(temp)
			If dochart Then
				ListItem.side = ColorID
			Else
				ListItem.ColorID= ColorID
			End If
			ListItem.IsClean=False 
		Next
		Lists.IsClean=False
	End If
End Sub
Sub RandomizeColors(ListID As Int)
	Dim temp As Int, Lists As LCARlist, ListItem As LCARlistitem, dochart As Boolean ,Old As String 
	If Not(LessRandom) Then
		Lists= LCARlists.Get(ListID)
		Select Case Lists.Style 
			Case LCAR_Chart, LCAR_ChartNeg: dochart = True
		End Select
		For temp = 0 To Lists.ListItems.Size-1
			ListItem=Lists.ListItems.Get(temp)
			If dochart Then
				If ListItem.WhiteSpace <> ListItem.Number Then 
					Old = ListItem.side
					Do Until Not(Old.EqualsIgnoreCase(ListItem.side))
						ListItem.side = Rnd(0,MaxRandomColors)
					Loop
				End If
			Else
				ListItem.ColorID= LCAR_RandomColor
			End If
			ListItem.IsClean=False 
			'Lists.ListItems.Set(temp,ListItem)
		Next
		Lists.IsClean=False
		'LCARlists.Set(ListID,Lists)
	End If
End Sub

Sub SmallScreenMode(ListID As Int)
	Dim Lists As LCARlist ,temp As Int
	If ListID=-1 Then
		SmallScreen = (CrazyRez=0)
		For temp = 0 To LCARlists.Size-1
			Lists = LCARlists.Get(temp)
			If Lists.OneColOnly Then
				Lists.ColsLandscape=1
				Lists.ColsPortrait =1
				LCARlists.Set(temp,Lists)
			End If
		Next
		
		LCARCornerElbow.Initialize(File.DirAssets,"elbows.png")
		LCARCornerElbow2.Initialize(File.DirAssets,"elbow2s.png")
		LCARCornerElbowa.Initialize(File.DirAssets,"elbows.gif")
		LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2s.gif")
		LCARSeffects.PromptWidth = LCARSeffects.BarWidth+ LCARCornerElbow2.width
		
		LCARSeffects.SmallScreenMode
		ChartHeight=62
		MeterWidth = 60 * GetScalemode
		If SmallScreen Then ChartHeight=ChartHeight*0.5 Else ChartHeight=ChartHeight*CrazyRez 
		
		temp = API.IIF(CrazyRez=0, 50, 100*CrazyRez)
		If NumGroup>0 Then 'resize IP numboard
			ClearLRwidths(NumListID)
			ResizeElbowDimensions(NumButtonID,temp,ItemHeight)
			ResizeElbowDimensions(NumButtonID+4,temp,ItemHeight)
		End If
		If KBCancelID>0 Then'resize keyboard
			ClearLRwidths(KBListID)
			ResizeElbowDimensions(KBCancelID, temp, ItemHeight)
			ResizeElbowDimensions(KBCancelID+4,temp, ItemHeight)
		End If
	Else If CrazyRez=0 Then
		Lists = LCARlists.Get(ListID)
		Lists.OneColOnly=True
		'LCARlists.Set(ListID,Lists)
	End If
End Sub

Sub DrawList(BG As Canvas,SurfaceID As Int , ListID As Int, X2 As Int, Y2 As Int, Width2 As Int, Height2 As Int)As Boolean 
	Dim temp As Int, Lists As LCARlist, Dimensions As tween, ListItem As LCARlistitem 'ListitemWhiteSpace ItemHeight
	Dim temp As Int, temp2 As Int, temp3 As Int, X As Int, Y As Int,Bottom As Int'=y2+height2',ItemsDrawn As Int ',Number As Int
    Dim ItemsOnScreen As Int, ItemsPerCol As Int, ItemWidth As Int,tItemHeight As Int, Cols As Int, color As Int
    Dim Width As Int, Height As Int, tX As Int, tY As Int, Mint As Int,State As Boolean , dItemHeight As Int, Start As Int 
    Dim WhiteSpace2 As Int, RText As String,ChartStart As Int, P As Path ,Scrolling As Boolean ,Selected As Boolean ,IsSmooth As Boolean 
	If ListID >= LCARlists.Size Then Return False
	If LCARVisibleLists.Get(ListID) Or Width2>0 Then
		CheckNumbersize(BG)
		Lists= LCARlists.Get(ListID)
		Start = Max(0, Lists.Start )
		If  ((Lists.SurfaceID = SurfaceID Or SurfaceID=-1) And (Not(Lists.IsClean) Or Not(IsClean)))  Then'Main.ButtonMenu = ListID Or
			If Width2=0 Then
				Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
			Else 
				Dimensions.Initialize 
				Dimensions.currX =X2
				Dimensions.currY =Y2
				Dimensions.offX =Width2
				Dimensions.offY =Height2
				Lists.Opacity.Current=255
			End If
			tX = Dimensions.currX 
			tY = Dimensions.currY 
			Width = Dimensions.offX 
			Height= Dimensions.offY 
			If Lists.Locked Or Lists.Start<0 Then Lists.Start=0
			If Lists.SelectedItem=-1 Then Lists.SelectedXY = LCARSeffects.SetPoint(-1,-1)
			Bottom = tY+Height
			
			Select Case Lists.Style
				Case LCAR_Button, ENT_Button,TMP_Switch,TMP_Numbers' normal/LCAR_Buttons DoesSmoothlyScroll
					If SmoothScrolling And DoesSmoothlyScroll(Lists) And Lists.offset<0 And Lists.isScrolling And Start>0 Then
						If Not( LimitStart(Lists,0, True)) Then
							Mint=Lists.Offset*-1
							IsSmooth=True
							'LCARSeffects4.DrawRect(BG,tX,tY-(ItemHeight+ListitemWhiteSpace), Width, ItemHeight+ListitemWhiteSpace, Colors.Black, 0)
							'BG.DrawLine(tX, tY-Mint, tX+Width, tY-Mint, Colors.Red,3)
							
							LCARSeffects.MakeClipPath(BG, tX, tY, Width+1,Height+1)	
							'LCARSeffects4.DrawRect(BG,tX, tY, Width,Height, Colors.Black, 0)
							'Start=Start-1
							tY=tY- Mint
							Height=Height+(ItemHeight+ListitemWhiteSpace)*2
							Scrolling=True
							'Log(Lists.Start & " : " &  Start & " : " & Lists.Offset & " : " & Mint)
						End If
					End If
				
					ItemsPerCol=LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
					Cols= LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait)
					ItemWidth = Floor(Width / Cols) - ListitemWhiteSpace
					If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
					
					Select Case Lists.Style'row count
						Case LCAR_Button,TMP_Numbers: 
							ItemsOnScreen= LCAR_ListRows(Height)'regular
							dItemHeight=ItemHeight
						Case ENT_Button
							dItemHeight=50 * ScaleFactor
						Case TMP_Switch
							dItemHeight=ItemWidth*1.333333333
					End Select
					If ItemsOnScreen = 0 Then ItemsOnScreen = Max(1, Floor(Height / (dItemHeight+ListitemWhiteSpace)))
					
					Mint = ItemsOnScreen
					Lists.LastMint=Mint
					If Mint > ItemsPerCol Then 
						Lists.LastMint=ItemsPerCol
						If Not(Lists.ForcedMint.IsInitialized) Then  Mint = ItemsPerCol
					End If
					If Lists.LastMint=0 Then Lists.LastMint = Mint 
					temp =  ItemsPerCol-ItemsOnScreen
					If temp<0 Then temp =Min(ItemsOnScreen, Lists.ListItems.Size)
					'temp=Lists.ListItems.Size-Mint
					'Log("List start: " & lists.Start & " mint: " & mint & " lists.ListItems.Size " & lists.ListItems.Size )
					If Lists.Start > temp And Not(SmoothScrolling) Then 
						Lists.Start=temp
						Start=temp
					End If
					
					X = tX
					If Not(Lists.IsClean) Then BG.DrawRect( SetRect(tX,tY,Width,Height), Colors.Black, True,0)
					
					Select Case Lists.Style
						Case TMP_Switch
							Y=tY
							For temp = Start To Lists.ListItems.Size-1
								ListItem= Lists.ListItems.Get(temp)
								Selected= BlinkState And  ((temp3= Lists.SelectedItem) Or ListItem.Selected )
								LCARSeffects3.DrawWOKSwitch(BG, X,Y, ItemWidth, dItemHeight, ListItem.ColorID, Lists.Opacity.Current, ListItem.Text, Selected)
								X=X+ItemWidth
								If X+ItemWidth >= tX+Width Then
									Y=Y+dItemHeight
									X=tX
									'temp=temp-1
									If Y > tY+Height Then Exit
								End If
							Next
							
						Case Else
							For temp = 0 To Cols-1
								temp3 = Start + (ItemsPerCol * temp)
								Y = tY
								If Scrolling Then
									'Y=Y+ItemHeight+ListitemWhiteSpace
									temp3=temp3-1
								End If
								For temp2 = 1 To Mint
									If temp3 < Lists.ListItems.Size  And temp3 > -1 Then
										ListItem= Lists.ListItems.Get(temp3)
										If Lists.style>0 Then Selected= BlinkState And  ((temp3= Lists.SelectedItem) Or ListItem.Selected )
										Select Case Lists.Style
											Case LCAR_Button
												Selected= DrawListItem(BG, Lists, ListItem, X,Y, temp3,ItemWidth, temp,temp2, Lists.Opacity.Current, Lists.Alignment) 'Then Lists.SelectedXY=LCARSeffects.SetPoint(temp, temp2-1 )
											Case ENT_Button	
												LCARSeffects2.DrawPreCARSButton(BG, X,Y, ItemWidth, dItemHeight, ListItem.ColorID, Selected  Or ListItem.Selected , 255, ListItem.Text, ListItem.Side, Selected Or ListItem.Selected )
											Case TMP_Numbers
												LCARSeffects3.DrawDigitItem(BG, Lists.RWidth, ListItem.Text, ListItem.Side, X,Y, ItemWidth, ItemHeight, temp3, Lists.Opacity.Current, ListItem.ColorID, Selected  Or ListItem.Selected)
										End Select
										If Selected Then Lists.SelectedXY=LCARSeffects.SetPoint(temp, temp2-1 )
										'State= BlinkState AND listitem.Selected 
										'If redalert AND temp= lists.RedX AND temp2=lists.RedY Then
										'	state=True
										'	listitem.IsClean = False
										'End If
										'If Not(listitem.IsClean) OR Not(lists.IsClean) OR Not(isclean)  Then
										'	Number=-1
										'	If lists.ShowNumber Then Number = listitem.Number 
										'	DrawLCARButton(BG, X, Y, ItemWidth, ItemHeight, listitem.ColorID, State, listitem.Text, listitem.Side, lists.LWidth, lists.RWidth, lists.RhasCurve, lists.WhiteSpace, 4,Number)
										'	listitem.IsClean = True
										'	lists.ListItems.Set(temp3,listitem)
										'End If
									Else If Lists.ForcedMint.IsInitialized Then
										DrawListItem(BG, Lists, Lists.ForcedMint, X,Y, -2,ItemWidth,temp,temp2, Lists.Opacity.Current,Lists.Alignment)
									End If
									temp3=temp3+1
									
									'Select Case Lists.Style
									'	Case 0: 			Y=Y+ItemHeight+ListitemWhiteSpace
									'	Case ENT_Button:	Y=Y+50+ListitemWhiteSpace
									'	Case TMP_Switch:	Y=Y+50+ListitemWhiteSpace
									'End Select
									Y=Y+dItemHeight+ListitemWhiteSpace
									If Lists.ForcedMintCount = temp2 Then temp2=Mint
								Next
								X = X + ItemWidth + ListitemWhiteSpace
							Next
					End Select
					If P.IsInitialized Then BG.RemoveClip 
				Case LCAR_Chart, LCAR_ChartNeg 'ChartWidth=40:ChartEdgeHeight=13:ChartHeight=62:ChartSpace=5
					X=tX:Y=tY
					If Lists.ColsLandscape>0 Or Lists.ColsPortrait>0 Then
						ChartStart=100
						If CrazyRez>0 Then
							ChartStart=ChartStart * CrazyRez 
						Else
							If SmallScreen Then ChartStart = 50
						End If
						X=X+ChartStart+3
						Width=Width-ChartStart-3
						Y=Y-(ChartEdgeHeight + ChartSpace)
					End If
					ChartWidth= Floor(Width/10)
					ItemsOnScreen= (Dimensions.offY - (ChartEdgeHeight + ChartSpace)*2) / (ChartSpace+ChartHeight)
					Lists.LastMint=ItemsOnScreen
					Width= Floor(Width / ChartWidth)*ChartWidth
					DrawLCARchart(BG, X, Y, Width, ChartEdgeHeight,0, LCAR_Orange, 1, Lists.LWidth, Lists.Opacity.Current,0,0)
					Y=Y+ChartEdgeHeight + ChartSpace
					For temp = Start To Start +ItemsOnScreen' 0 To ItemsOnScreen
						If temp < Lists.ListItems.Size And Y+ChartHeight < Bottom Then
							ListItem= Lists.ListItems.Get(temp)
							If Not(ListItem.IsClean)  Or Not(Lists.IsClean) Or Not(IsClean)  Then'																								  A
								If ChartStart>0 Then DrawLCARbutton(BG,  tX,Y-1, ChartStart, ChartHeight+2, ListItem.ColorID,   False, API.LimitTextWidth(BG, ListItem.Text, LCARfont, Fontsize, ChartStart, "..."  ), "", 0,0,False,0,  1 ,-1,255,False)
								ListItem.IsClean = True
								'Lists.ListItems.Set(temp,ListItem)
								DrawLCARchart(BG, X, Y, Width,  ChartHeight, ListItem.WhiteSpace , ListItem.ColorID, 0, Lists.LWidth, Lists.Opacity.Current, Lists.Style, ListItem.Side  )
							End If
							Y=Y+ChartHeight + ChartSpace
						Else
							temp=Start +ItemsOnScreen
						End If
					Next
					temp=Max(tY+ Height - Y +ChartEdgeHeight*2, ChartEdgeHeight)
					DrawLCARchart(BG, X, Y, Width, ChartEdgeHeight,0, LCAR_Orange, -1, Lists.LWidth, Lists.Opacity.Current,0,0 )
					DrawRect(BG,X-ChartStart-3,Y-1, ChartStart, temp, GetColor(LCAR_Orange,False,255), 0)' (ItemsDrawn * (ChartHeight + ChartSpace)) 
					
				Case LCAR_Meter
					X=tX:Y=tY
					ItemsOnScreen= Width/ (ChartSpace + MeterWidth)
					tItemHeight= Height
					If Lists.ListItems.Size > ItemsOnScreen Then tItemHeight= Height / Ceil(Lists.ListItems.Size / ItemsOnScreen) - ChartSpace

					For temp = 0 To Lists.ListItems.Size-1' ItemsOnScreen-1
						If temp < Lists.ListItems.Size Then
							ListItem= Lists.ListItems.Get(temp)
							If Not(ListItem.IsClean)  Or Not(Lists.IsClean) Or Not(IsClean)  Then
								ListItem.IsClean = True
								'Lists.ListItems.Set(temp,ListItem)
								DrawLCARmeter(BG, X,Y, MeterWidth, tItemHeight,  ListItem.WhiteSpace , ListItem.ColorID, ListItem.Selected, Lists.Opacity.Current)
							End If
							X=X+ChartSpace + MeterWidth
							If X> tX+Width-MeterWidth Then 
								X=tX
								Y=Y+tItemHeight+ChartSpace
							End If
						End If
					Next
				Case LCAR_Analysis
					LCARSeffects2.DrawAnalysis(BG, Lists,  tX,tY,Width,Height, ListID)
				
				Case LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List,EVENT_Horizon,DRD_Timer
					If Lists.ListItems.Size>0 Then
						ItemWidth = Width/ Lists.ListItems.Size 
						X=tX
						For temp = 0 To Lists.ListItems.Size-1
							ListItem= Lists.ListItems.Get(temp)
							Selected = BlinkState And (ListItem.Selected  Or (Lists.SelectedItem = temp))
							If Lists.Style = LCAR_MiniButton Then
								temp2 = -ItemWidth+ChartSpace
							Else
								temp2=ItemWidth-ChartSpace
							End If
							Select Case Lists.Style 
								Case LCAR_List
									If temp = 0 Then'first
										DrawLCARslantedbutton(BG,X,tY,temp2,Height,ListItem.ColorID,Lists.Opacity.Current,Selected,  ListItem.Text,-4,5)
									Else If temp = Lists.ListItems.Size-1 Then'last
										DrawLCARslantedbutton(BG,X,tY,temp2,Height,ListItem.ColorID,Lists.Opacity.Current,Selected,  ListItem.Text,-5,5)
									Else
										DrawLCARbutton(BG,X,tY,temp2,Height,ListItem.ColorID, Selected, ListItem.Text, "",  0, 0, False, 0, 5,-1,   Lists.Opacity.Current,False)
									End If							
								Case TOS_Button
									LCARSeffects3.DrawTOSButton(BG,X,tY,temp2,Height,  GetColor(ListItem.ColorID, Selected, Lists.Opacity.Current), ListItem.Text)
								Case Klingon_Button
									LCARSeffects3.DrawKlingonButton(BG,X,tY,temp2,Height, Lists.Opacity.Current,Selected, ListItem.Text)
								Case LCAR_MiniButton, Legacy_Button
									LCARSeffects2.DrawLegacyButton(BG, X,tY, temp2, Height, GetColor(ListItem.ColorID, Selected, Lists.Opacity.Current), ListItem.Text, 9, 0)
								Case EVENT_Horizon
									LCARSeffects4.DrawButton(BG,X,tY,temp2,Height, ListItem.text.ToLowerCase, Lists.Opacity.Current)
								Case DRD_Timer
									If temp = 0 Then'first
										LCARSeffects4.DrawSliver2(BG, X,tY,temp2,Height, LCARSeffects4.DRD_Red, 0,1, ListItem.Text, Colors.White, 0)
									Else If temp = Lists.ListItems.Size-1 Then'last
										LCARSeffects4.DrawSliver2(BG, X,tY,temp2,Height, LCARSeffects4.DRD_Red, 1,0, ListItem.Text, Colors.White, 0)
									Else
										LCARSeffects4.DrawSliver2(BG, X,tY,temp2,Height, LCARSeffects4.DRD_Red, 1,1, ListItem.Text, Colors.White, 0)
									End If
									BG.removeclip
							End Select
							X=X+ItemWidth'+ChartSpace
						Next
					End If
				
				Case CHX_Iconbar
					LCARSeffects3.CHX_DrawMenubar(BG,Lists, tX, tY, Width, Height)
				Case Else
					DrawUnknownElement(BG,X,Y,Width,Height, LCAR_Orange,False, Lists.Opacity.Current, "UNKNOWN LIST STYLE")
			End Select
			'If lists.ForcedMintCount >0 AND lists.ForcedMintCount< mint Then 
			'	lists.ForcedMintCount=lists.ForcedMintCount+1
			'Else
			'	lists.ForcedMintCount=0'Just in case
				Lists.IsClean = True'Main.ButtonMenu <> ListID 
			'End If
			BG.RemoveClip 

			'LCARlists.Set(ListID,Lists)
			Return True
		End If
	End If
End Sub

Sub AddChartItem(ListID As Int, ColorID As Int, Percent As Int, Index As Int,Text As String,Tag As String   )
	If Percent<0 Or Percent>100 Then Percent = Rnd(0,101)
	LCAR_AddListItem(ListID, Text, ColorID, Percent,   Tag, False, "", 0,  False, Index)
End Sub



Sub LCAR_GetSelectedItem(ListId As Int) As Int
	Dim lists As LCARlist
	lists=LCARlists.Get(ListId)
	Return lists.SelectedItem 
End Sub

Sub LCAR_GetListItem(ListID As Int, Item As Int) As LCARlistitem 
	Dim temp As List , lists As LCARlist,listitem As LCARlistitem 
	If ListID>-1 And ListID< LCARlists.Size Then
		lists=LCARlists.Get(ListID)
		If Item>-1 And Item < lists.ListItems.Size Then
			Return lists.ListItems.Get(Item)
			'temp.Initialize2(Array As String( listitem.Text, listitem.Side, listitem.Tag))
			'Return temp
		Else If Item = LCAR_SelectedItem And lists.SelectedItem>-1 Then
			Return lists.ListItems.Get(lists.SelectedItem)
		End If
	End If
	Return listitem
End Sub

'Index: 0=Text, 1=SideText, 2=Tag, 3=number
Sub LCAR_FindListItem(ListID As Int, Text As String, Index As Int, RemoveIt As Boolean, Number As Int)As Int
	Dim temp As Int , lists As LCARlist ,listitem As LCARlistitem ,found As Boolean 
	If Index=3 And Not(IsNumber(Text)) Then Return -1
	If ListID>-1 And ListID< LCARlists.Size Then
		lists=LCARlists.Get(ListID)
		For temp = 0 To lists.ListItems.Size-1
			listitem = lists.ListItems.Get(temp)
			Select Case Index
				Case 0: found = listitem.Text.EqualsIgnoreCase(Text) 'text
				Case 1: found = listitem.side.EqualsIgnoreCase(Text) 'sidetext
				Case 2: found = listitem.Tag.EqualsIgnoreCase(Text)'tag
				Case 3: found = (listitem.Number = Text)'number
			End Select
			If found Then 
				found=False
				If RemoveIt Then 
					lists.ListItems.RemoveAt(temp)
				Else If Number>-1 Then 
					listitem.Number=Number
					found=True
				Else If Number=-2 Then
					listitem.Selected=True
				End If
				If found Then lists.ListItems.Set(temp,listitem)
				Return temp
			End If
		Next
	End If
	Return -1
End Sub

'Sub SetIncrementingList(ListID As Int)'
	'Dim lists As LCARlist 
	'lists = lcarlists.Get(listid)
	'lists.ForcedMintCount=1
	'lcarlists.Set(listid,lists)
'End Sub

Sub DrawListItem(BG As Canvas, Lists As LCARlist , ListItem As LCARlistitem , X As Int, Y As Int, ItemIndex As Int,ItemWidth As Int, temp As Int, temp2 As Int, Alpha As Int , Alignment As Int   )As Boolean 
	Dim Number As Int,State As Boolean,Text As String ,L As Int, R As Int
	'If ShowNumber Then WhiteSpace2 = 41		
    'WhiteSpace2 = listitem.WhiteSpace 
	State= BlinkState And (ListItem.Selected  Or (Lists.SelectedItem = ItemIndex))
	If RedAlert Then
		If temp= Lists.RedX And temp2=Lists.RedY Then
			State=True
			Lists.Red=ItemIndex
			ListItem.IsClean = False
		Else If ItemIndex = Lists.Red Then
			ListItem.IsClean = False
			Lists.Red = -1
		End If
	End If
	If Not(ListItem.IsClean) Or Not(Lists.IsClean) Or Not(IsClean) Or (ItemIndex<0)  Then
		BG.DrawRect( SetRect(X,Y,ItemWidth,ItemHeight), Colors.Black, True,0)
		Number=-1
		If Lists.ShowNumber Then 
			'If itemindex<0 then load cached numbers
			Number = ListItem.Number 
		End If
		L=PreProcessLRwidth(ItemWidth, Lists.LWidth)
		R=PreProcessLRwidth(ItemWidth,Lists.RWidth)
		If ListItem.Text.Length<6 Then
			Text= ListItem.Text
		Else
			temp=ItemWidth-ListItem.WhiteSpace-L-R-Lists.WhiteSpace*2
			If ListItem.Number>-1 And Lists.ShowNumber Then temp = temp - NumberWhiteSpace
			Text= API.LimitTextWidth(BG, ListItem.Text, LCARfont, Fontsize, temp,  "...")
		End If
		DrawLCARbutton(BG, X+ ListItem.WhiteSpace, Y, ItemWidth- ListItem.WhiteSpace, ItemHeight, ListItem.ColorID, State, Text, ListItem.Side, L, R, Lists.RhasCurve, Lists.WhiteSpace, Alignment, API.IIF(SmallScreen,-1,Number), Alpha,False)
		ListItem.IsClean = True
		If ItemIndex>-1 Then Lists.ListItems.Set(ItemIndex,ListItem)
	End If
	Return Lists.SelectedItem = ItemIndex 
End Sub
Sub PreProcessLRwidth(ItemWidth As Int, LRWidth As Int) As Int
	If LRWidth<0 Then
		Return LRWidth/-100*ItemWidth
	Else
		Return LRWidth
	End If
End Sub

'Public Function LCAR_AddListItem(ListId As Long, Text As String, Optional color As Long = -1, Optional LightColor As Long = -1, Optional Size As Long = -1, Optional Tag As String, Optional Icon As Long = -1, Optional Selected As Boolean, Optional Side As String, Optional WhiteSpace As Long = -1, Optional FILEsize As String, Optional LCARtext As String) As Long
Sub LCAR_ClearList(ListId As Int, DownToItem As Int)
	Dim Lists As LCARlist, temp As Int 
	If ListId < 0 Then Return 
	Lists= LCARlists.Get(ListId) 
	If DownToItem=0 Then
		Lists.ListItems.Clear 
		If Lists.Style=CHX_Iconbar Then 
			Lists.ColsLandscape = 0		
			LCARSeffects3.CHX_Fontsize=0
		End If
	Else
		For temp = Lists.ListItems.Size-1 To DownToItem Step -1
			Lists.ListItems.RemoveAt(DownToItem)' Lists.ListItems.Size-1)
		Next
	End If
	Lists.Red=-1
	Lists.IsClean = False
	Lists.SelectedItem = -1
	Lists.SelectedItems=0 
	Lists.Start=0	
	LCARlists.Set(ListId,Lists)
End Sub

Sub LCAR_RemoveList(Index As Int) As Boolean 
	If Index< LCARlists.Size And Index>-1 Then 
		LCARlists.RemoveAt(Index)
		Return True
	End If
End Sub 
Sub LCAR_FindList(Name As String) As Int
	Dim Lists As LCARlist, temp As Int 
	For temp = 0 To LCARlists.Size-1
		Lists = LCARlists.Get(temp)
		If Lists.Name.EqualsIgnoreCase(Name) Then Return temp
	Next
	Return -1
End Sub
Sub LCAR_FindLCAR(Name As String, Group As Int, Index As Int) As Int 'If Index=-1 then it will count the occurances of that button id
	Dim temp As Int, temp2 As Int,Element As LCARelement 
    For temp = 0 To LCARelements.Size - 1
		Element = LCARelements.Get(temp)
        If Name.EqualsIgnoreCase(Element.Name) Then
            If Group <0 Or Group = Element.Group Then
                If Index = 0 Then
                    Return temp
                Else
                    If temp2 = Index Then Return temp
                    temp2 = temp2 + 1
                End If
            End If
        End If
    Next
    If Index = -1 Then Return temp2 Else Return -1
End Sub

Sub ForceShowGroup(GroupID As Int, State As Boolean)
	Dim temp As Int, Element As LCARelement ,Group As LCARgroup ,Alpha As Int, Index As Int 
	'If GroupID< LCARGroups.Size Then
		Group = LCARGroups.Get(GroupID)
		ismoving = True
		For temp = 0 To Group.LCARlist.Size-1 'lcarelements.Size - 1
			Index=Group.LCARlist.Get(temp)
			Element = LCARelements.Get( Index  )
			'If  element.Visible <> state Then		'element.Group = groupid AND
			Element.Opacity.Desired= API.iif(State,255,0)
			Element.Opacity.Current= API.iif(State,0,255)
			Element.Visible = State
			Element.IsClean = False
		Next
		Group.Visible=True
		LCARGroups.Set(GroupID,Group)
		IsClean=False
	'End If
End Sub 

Sub HideGroup(GroupID As Int, State As Boolean, UseAlpha As Boolean )
	Dim temp As Int, Element As LCARelement ,Group As LCARgroup ,Alpha As Int, Index As Int 
	'If GroupID< LCARGroups.Size Then
		Group = LCARGroups.Get(GroupID)
		If UseAlpha Then
			ismoving = True
			If State Then Alpha = 255 
			
			
			For temp = 0 To Group.LCARlist.Size-1 'lcarelements.Size - 1
				Index=Group.LCARlist.Get(temp)
				Element = LCARelements.Get( Index  )
				If  Element.Visible <> State Then		'element.Group = groupid AND
					Element.Opacity.Desired=Alpha
					Element.Visible = ( (Alpha>0)  Or (Element.Opacity.Current >0) )
					Element.IsClean = False
					LCARelements.Set(Index, Element)
				End If
			Next
		'Else
			'state=True
		End If
		'If Not(state) Then
			'group = lcargroups.Get(groupid)
			Group.Visible=State
			LCARGroups.Set(GroupID,Group)
			IsClean=False
		'End If
	'End If
End Sub

Sub ForceHideAll(BG As Canvas)
	Dim temp As Int
	ToggleMultiLine(False)
	WallpaperService.AllowPreview=False
	LCAR_HideAll(BG,False)
	For temp=0 To LCARelements.Size-1
		ForceHide( temp)
	Next
	ClearScreen(BG)
End Sub

Sub LCAR_HideAll(BG As Canvas, UseAlpha As Boolean )
	Dim temp As Int
	VisibleList=-1
	CurrListID=-1
	ToggleMultiLine(False)
	If NeedsLCARfont Then LCARfont = Typeface.LoadFromAssets("lcars.ttf")
	
	For temp = 0 To LCARlists.Size-1
		LCAR_HideElement(BG, temp,   True, False ,  Not(UseAlpha))
	Next
'	For temp=0 To LCARelements.Size-1
'		LCAR_HideElement(BG, temp,False,False, Not(UseAlpha))
'	Next
	For temp = 0 To LCARGroups.Size-1
		HideGroup(temp,False,  UseAlpha )
	Next
	LCARSeffects.FrameBitsVisible=False
	LCARSeffects3.TMPisVisible=False
	KBisVisible=False
	
	'If ClearLocked Then
		
		'WallpaperService.SettingsLoaded=False
	'End If
	

	IsClean=False
	ClearLocked=False
End Sub


Sub LCAR_SetListStyle(BG As Canvas, ListID As Int, Style As Int, Visible As Boolean )
	Dim Lists As LCARlist,Dimensions As tween	
	Lists=LCARlists.Get(ListID)
	If LCARVisibleLists.Get(ListID) Then' lists.Visible Then
		Lists.IsClean = False
		Dimensions=ProcessLoc(Lists.LOC, Lists.Size)
		BG.DrawRect( SetRect( Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY), Colors.Black , True,0 )
	End If
	LCARVisibleLists.Set(ListID, Visible)
	'lists.Visible = visible
	Lists.Style = Style
	LCARlists.Set(ListID,Lists)
End Sub

Sub LCAR_SetListCols(ListID As Int, ColsPortrait As Int, ColsLandscape As Int)
	Dim Lists As LCARlist
	Lists=LCARlists.Get(ListID)
	Lists.IsClean=False
	Lists.ColsLandscape = ColsLandscape
	Lists.ColsPortrait = ColsPortrait
End Sub

Sub LCAR_SortList(ListID As Int)
	Dim Lists As LCARlist, ListItem1 As LCARlistitem , temp As Int 
	Lists=LCARlists.Get(ListID)
	Lists.IsClean=False
	Lists.ListItems.SortType("Text", True)
End Sub

Sub TweenOpacity(IsVisible As Boolean , Visible As Boolean ,Alpha As TweenAlpha ) As TweenAlpha 
	If IsVisible Then
		If Visible Then 
			Alpha.Desired = 255
			Alpha.Current=0
		Else
			Alpha.Desired = 0
			Alpha.Current = 255
		End If
	Else
		Alpha.Current=0
		Alpha.Desired = 0
	End If
	Return Alpha
End Sub

Sub FadeList(BG As Canvas, ListID As Int,Visible As Boolean )
	Dim Lists As LCARlist
	
	If Visible Or LCARVisibleLists.Get(ListID) Then
		Lists=LCARlists.Get(ListID)
		LCARVisibleLists.Set(ListID,True)' lists.Visible = True
		Lists.Opacity= TweenOpacity(True,Visible, Lists.Opacity)
	
		LCARlists.Set(ListID,Lists)
	End If
End Sub

Sub LCAR_HideElement(BG As Canvas, LCARid As Int, isList As Boolean,Visible As Boolean,Nofade As Boolean  ) As Boolean 
	Dim Lists As LCARlist, Element As LCARelement ,Dimensions As tween, Rect1 As Rect,Did As Boolean 
	If LCARid>-1 Then
		If BG=Null Then ClearScreen(Null)
		If isList Then
			If Visible Then	
				VisibleList=LCARid
			Else If VisibleList = LCARid Then
				VisibleList = -1
			End If 
			
			If LCARid < LCARlists.Size Then
				Lists=LCARlists.Get(LCARid)
				If LCARVisibleLists.Get(LCARid) = False And Visible = True Then
					LCARVisibleLists.Set(LCARid,True)'lists.Visible = visible
					Lists.Opacity.Desired=255
					If Nofade Then Lists.Opacity.Current=255
				Else If LCARVisibleLists.Get(LCARid) = True And Visible = False Then
					If Nofade Then
						LCARVisibleLists.Set(LCARid,False)
					Else
						Lists.Opacity.Desired=0
					End If
				End If
				Lists.IsClean = False
				LCARlists.Set(LCARid,Lists)
				If Not(Visible) Then
					Did=True
					Dimensions=ProcessLoc(Lists.LOC, Lists.Size)
				End If
			End If
		Else
			If LCARid<LCARelements.Size Then
				Element = LCARelements.Get(LCARid)
				Element.Visible = Visible
				Element.IsClean = False
				LCARelements.Set(LCARid, Element)
				If Not(Visible) Then
					If Nofade Or (Element.ElementType = LCAR_LWP And Element.LWidth=-1) Then
						Element.Opacity.Current=0
						Element.Opacity.Desired=0
					End If
					If BG <>Null Then
						Dimensions=ProcessLoc(Element.LOC, Element.Size)
						If Element.ElementType=LCAR_Elbow Then
							DrawLCARelbow(BG, Dimensions.currx,  Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.LWidth, Element.RWidth, Element.Align, LCAR_Black, False, "", 0,255 ,False)
						Else
							Did=True
						End If
					End If
				End If
			End If
		End If
		If Did And BG <> Null And Dimensions.offY>0 And Dimensions.offX>0 Then 
			Rect1=SetRect( Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY)
			Try
				BG.DrawRect(Rect1, Colors.Black , True,0 )
			Catch
				Did = False
			End Try
		End If
	End If
	Return Did
End Sub

Sub LCAR_HideLCAR(Name As String, Visible As Boolean)
	Dim temp As Int, Element As LCARelement 
    For temp = 0 To LCARelements.Size - 1
		Element = LCARelements.Get(temp)
        If Name.EqualsIgnoreCase(Element.Name) Then
        	Element.Visible = Visible
			Element.IsClean = False
			LCARelements.Set(temp,Element)
        End If
    Next
End Sub
Sub LCAR_GetElement(LCARid As Int) As LCARelement  
	Return LCARelements.Get(LCARid)
End Sub
Sub LCAR_Blink(LCARid As Int, State As Boolean )
	Dim  Element As LCARelement
	Element = LCARelements.Get(LCARid)
	Element.Blink = State
	LCARelements.Set(LCARid, Element)
End Sub

Sub LCAR_State(LCARid As Int, State As Boolean)
	Dim Element As LCARelement
	'If lcarid>-1 Then
		Element = LCARelements.Get(LCARid)
		If Element.Enabled Then
			Element.isdown = State
			Element.IsClean = False
		End If
		LCARelements.Set(LCARid, Element)
	'End If
End Sub

Sub GotoNextVisibleElement(GroupID As Int)As Int
	Dim temp As Int, Group As LCARgroup, Element As LCARelement,ID As Int
	If GroupID<0 Or GroupID >= LCARGroups.Size Then Return
	Group = LCARGroups.Get(GroupID)
	If Group.Visible And Group.LCARlist.Size>0 Then
		If Group.LCARlist.Size=1 Then
			If Group.RedAlert>-1 Then
				Group.RedAlert=-1
				'LCARGroups.Set(GroupID,Group)
			End If
		Else
			Group.Hold = Group.Hold -1
			If Group.Hold <1 Then
				If Group.RedAlert>-1 And Group.RedAlert<Group.LCARlist.size Then 
					ID= Group.LCARlist.Get(Group.RedAlert)
					If ID>-1 And ID< LCARelements.Size Then
						Element = LCARelements.Get(ID)
						Element.IsClean = False
						LCARelements.Set(ID, Element)
				
						For temp = Group.RedAlert+1 To Group.LCARlist.Size-1
							If IsRedAlert(temp, Group, GroupID) Then Return temp
						Next
						For temp = 0 To Group.RedAlert-1
							If IsRedAlert(temp, Group, GroupID) Then Return temp
						Next
					End If
				Else
					Group.RedAlert=0
				End If
			End If
		End If
	End If
End Sub
Sub IsRedAlert(temp As Int,  Group As LCARgroup, GroupID As Int  )As Boolean 
	Dim Element As LCARelement,ElementID As Int 
	ElementID=Group.LCARlist.get(temp)'group.RedAlert'(temp)
	Element = LCARelements.Get(ElementID )
	If Element.Visible Then 
		Element.IsClean = False
		LCARelements.Set(ElementID,Element)
		Group.RedAlert = temp
		Group.Hold = Group.HoldList.Get(temp)
		LCARGroups.Set(GroupID, Group)
		Return True
	End If
End Sub


Sub LCAR_BlinkLCARs
	Dim temp As Int, temp2 As Int, Element As LCARelement,ElementID As Int ,Group As LCARgroup ,Lists As LCARlist ,ListItem As LCARlistitem
	BlinkState=Not(BlinkState)
	If RedAlert Then
		For temp = 0 To LCARGroups.Size-1
			GotoNextVisibleElement(temp)
		Next
		For temp = 0 To LCARlists.Size-1
			
			If LCARVisibleLists.Get(temp) Then ' lists.Visible Then
				Lists= LCARlists.Get(temp)
				Lists.IsClean=False 
				'temp2 = GetListItem (temp, Lists.RedX, Lists.RedY, False,True)
				'If temp=0 Then Log("Current Red alert: " & Lists.RedX & ", " & Lists.RedY & "(item " & temp2 & ") " & Lists.LastMint)
				'ListItem=LCAR_GetListItem(temp,temp2)
				'ListItem.IsClean = False
				
				Lists.RedY =Lists.RedY+1
				
				If Lists.RedY-1 > Lists.LastMint Then
					Lists.RedY =0
					Lists.RedX = Lists.RedX + 1
					temp2=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait)
					'If temp=0 Then Log("Cols " & temp2)
					If Lists.RedX =temp2 Then Lists.RedX = 0'LCAR_ListCols
				End If
				'If temp=0 Then Log("New Red alert: " & Lists.RedX & ", " & Lists.RedY)
				'LCARlists.Set(temp,Lists)
			End If
		Next
	Else
	
		'For temp = 0 To lcarelements.Size - 1
			'element = lcarelements.Get(temp)
			'If element.Blink Then
				'element.IsClean = False
				'lcarelements.Set(temp,element)
			'End If
		'Next
	
		For temp = 0 To LCARGroups.Size-1
			Group = LCARGroups.Get(temp)
			If Group.Visible Then
				For temp2 =  Group.LCARlist.Size-1 To 0 Step -1
					ElementID = Group.LCARlist.Get(temp2)
					If ElementID< LCARelements.Size Then
						Element = LCARelements.Get(ElementID)
						If Element.Blink Then
							Element.IsClean = False
							LCARelements.Set(ElementID,Element)
						End If
					Else
						'Group.LCARlist.RemoveAt(temp2)
						'Group.Holdlist.RemoveAt(temp2)
					End If	
				Next
			End If
		Next
	
		For temp = 0 To LCARlists.Size-1
			
			If LCARVisibleLists.Get(temp) Then'lists.Visible
				Lists= LCARlists.Get(temp)
				Lists.IsClean =False
				If PartyTime Then Party(Lists)
				'LCARlists.Set(temp,Lists)
				'Log ( "LIST: " &  lists.SelectedItems)
				'If  lists.SelectedItems=1 Then
				'	DirtyListItem(lists, lists.SelectedItem , False,False,False)
				'	lcarlists.Set(temp,lists)
				'Else If lists.SelectedItems>1 Then
				'	lists.IsClean = False
				'	lcarlists.Set(temp,lists)
				'End If
			End If
		Next
	End If
	If VolOpacity=255 Then 'Dim VolOpacity As Int, VolSeconds As Int VolVisible
		If VolSeconds>0 Then VolSeconds=VolSeconds-1
	End If
End Sub
Sub Party(Lists As LCARlist) 
	Dim temp As Int , tempItem As LCARlistitem, tempItem2 As LCARlistitem  
	For temp = Lists.ListItems.Size -1 To 0 Step -1 
		tempItem = Lists.ListItems.Get(temp)
		If temp = 0 Then 
			tempItem.ColorID = LCAR_RandomColor
		Else
			tempItem2 = Lists.ListItems.Get(temp-1)
			tempItem.ColorID = tempItem2.ColorID 
		End If
		tempItem.IsClean = False
	Next
End Sub

Sub HideToast'(Why As String  )
	'Log("HIDE TOAST: " & Why)
	If DontHide Then 
		DontHide = False
		Return 
	End If
	VolOpacity=0
	VolSeconds=0
	VolText=""
	VolTextList.Clear 
	IsClean = False
	If SpecialToast Then
		CurrentStyle = LCAR_TNG
		If MP.IsPlaying Then Stop("HIDE TOAST")
	End If
End Sub
Sub SpecialToast As Boolean 
	Select Case CurrentStyle
		Case StarshipTroopers, Ferengi, ImageToast, FreedomWars, KnightRider: Return True
	End Select
End Sub


Sub LCAR_DeleteLCAR(LCARid As Int)As Boolean 
	Dim temp As Int, Element As LCARelement ,Group As LCARgroup ,Ret As Boolean ,temp2 As Int
	If LCARid>-1 And LCARid< LCARelements.Size Then
		Element = LCARelements.Get(LCARid)
		Group = LCARGroups.Get( Element.Group)
		Group.RedAlert=0
		For temp =  Group.LCARlist.Size-1 To 0 Step -1
			temp2= Group.LCARlist.get(temp) 
			If temp2 = LCARid Then
				'Log("BEFORE: " & Group.LCARlist)
				Group.LCARlist.RemoveAt(temp)
				Group.holdlist.removeat(temp)
				Ret=True
				'Log("Element deleted " & LCARid & " from group " & Element.Group & " " & Group.LCARlist)
			Else If temp2 > LCARid Then
				Group.LCARlist.Set(temp, temp2-1)
			End If
		Next
		'If Not(Ret) Then RemoveLCARfromGroup(LCARid,Element.Group)
		'If Ret Then 
'			For temp = 0 To  Group.LCARlist.Size-1 
'				temp2= Group.LCARlist.get(temp) 
'				If temp2 > LCARid Then
'					Log(temp & " became " & (temp-1))
'					Group.LCARlist.Set(temp, temp2-1)
'				End If
'			Next
		'End If	
		LCARelements.RemoveAt(LCARid)
		
		IsClean=False
		Return Ret
	End If
End Sub

Sub MakeLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String, Group As Int, Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int )  As LCARelement 
	Dim temp As LCARelement ,Picture As LCARpicture 
	temp.Initialize 
	temp.LOC.Initialize 
	temp.Size.Initialize 
	temp.Opacity.Initialize 
	
	temp.SurfaceID = SurfaceID
	temp.Opacity.Current=Alpha
	temp.Opacity.Desired=Alpha
	
	temp.Name=Name
	temp.Tag = Tag
	
	Select Case ElementType
		Case LCAR_Picture
			If Width=0 Or Height=0 Then
				Picture = PictureList.Get(LWidth)
				Width = Picture.Picture.Width 
				Height=Picture.Picture.Height 
				Select Case Align
					Case 1'top left
						X=X-Width/2
						Y=Y-Height/2
				End Select
			End If
		Case LCAR_Button 
			If (LWidth>0 Or RWidth>0) And Align=0 Then Height=ItemHeight
	End Select
	
	temp.LOC.currX=X
	temp.LOC.currY=Y
	temp.Size.currX=Width
	temp.Size.currY=Height
	
	temp.ColorID =ColorID
	temp.ElementType =ElementType
	temp.Enabled =Enabled
	temp.Group=Group
	temp.Visible=Visible
	
	temp.Text=Text
	temp.SideText=SideText
	temp.TextAlign =TextAlign
	
	temp.LWidth=LWidth
	temp.RWidth=RWidth
	temp.Align = Align 

	temp.RedAlertHold =1
	temp.State=False
	temp.IsDown = False
	temp.IsClean = False
	
	Return temp
End Sub
Sub LCAR_AddLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String, Group As Int, Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int ) As Int
	Dim temp As LCARelement
	temp=MakeLCAR(Name,SurfaceID,X,Y,Width,Height,LWidth,RWidth,ColorID,ElementType,Text,SideText,Tag,Group,Visible,TextAlign,Enabled,Align,Alpha) 
	LCARelements.Add(temp)	
	AddLCARtoGroup( LCARelements.Size-1, Group)
	Return LCARelements.Size-1
End Sub
'Sub LCAR_DeleteLCAR2(Index As Int)
'	RemoveLCARfromGroup(Index,-1)
'	LCARelements.RemoveAt(Index)
'	IsClean=False
'End Sub
Sub SizeToColor(Size As Int) As Int
	If Size<1025 Then
		Return LCAR_Orange
	Else If Size<13108 Then
		Return LCAR_Orange
	Else If Size<1048577 Then
		Return LCAR_Yellow
	Else If Size<13421773 Then
		Return LCAR_DarkBlue
	Else If Size<1073741825 Then
		Return LCAR_DarkYellow
	Else
		Return LCAR_DarkPurple
	End If
End Sub



Sub GetListItemCount(ListID As Int) As Int
	Dim lists As LCARlist
	lists=LCARlists.Get(ListID)
	Return lists.ListItems.Size 
End Sub
Sub GetListItem(ListID As Int, Col As Int, Row As Int,MakeItSelected As Boolean, IgnoreMINT As Boolean  ) As Int
	Dim lists As LCARlist ,Ret As Int , ItemsPerCol As Int, Cols As Int, Start As Int, Dimensions As tween ,ItemsOnScreen As Int
	Ret=-1
	lists=LCARlists.Get(ListID)

	Cols=LCAR_ListCols(lists.ColsLandscape,lists.ColsPortrait )
	If Cols = 0 Or lists.ListItems.Size = 0 Then Return Min(Max(Col,Row), lists.ListItems.Size)
	ItemsPerCol= LCAR_ListItemsPerCol(lists.ColsLandscape, lists.ColsPortrait, lists.ListItems.Size)
	Dimensions=ProcessLoc( lists.LOC, lists.Size )
	ItemsOnScreen= LCAR_ListRows(Dimensions.offY )
	
	If lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
	If Col<0 Then Col= Cols-1
	If Col>=Cols Then Col=0
		
	If Row >-1 And Row <= lists.LastMint Or IgnoreMINT Then
		If Row < ItemsPerCol Then
			Start= lists.Start + (ItemsPerCol * Col)
            Row = Row + Start
			If Row<Start Then
				lists.Start = lists.Start-1 
				lists.IsClean=False
			Else If Row>= Start+ItemsOnScreen Then
				lists.Start=lists.Start+1
				lists.IsClean=False
			End If
            If Row < lists.ListItems.Size Then 
				If MakeItSelected Then
					SetSelectedItem(lists,Row)
					LCARlists.Set(ListID,lists)
				End If
				Return Row
			End If
        End If
	End If
	Return Ret
End Sub

Sub LCAR_SliderState(Clicked As ElementClicked, State As Boolean)
	Dim Element As LCARelement
	'If lcarid>-1 Then
		Element = LCARelements.Get(Clicked.Index )
		If Element.Enabled Then
			Element.isdown = State
			Element.IsClean = False
			'If state Then
				Select Case Clicked.ElementType 
					Case LCAR_Slider
						Element.RWidth = (1- Clicked.Y / Clicked.Dimensions.offY)*100
						'Msgbox (clicked.Y &  CRLF & clicked.Dimensions.offY & CRLF &  (clicked.Y/clicked.Dimensions.offY) & CRLF & element.RWidth,"Slider")
					Case LCAR_HorSlider
						Element.RWidth = (1- Clicked.x / Clicked.Dimensions.offx)*100
				End Select
			'End If
		End If
		LCARelements.Set(Clicked.Index, Element)
	'End If
End Sub

Sub RespondToAll(ElementID As Int) As Int 
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.RespondToAll=True
	LCARelements.Set(ElementID,Element)
	Return ElementID
End Sub

Sub GetElement(Index As Int) As LCARelement 
	If Index>-1 And Index< LCARelements.Size Then Return LCARelements.Get(Index)
End Sub

Sub IfRside(Clicked As ElementClicked)
	Dim Width As Int ,X As Int ,Element As LCARelement 
	X= Clicked.X
	Width = Clicked.Dimensions.offx 
	Element=GetElement(Clicked.Index)
	'Msgbox (Element.Rwidth & CRLF & Width & CRLF & X & CRLF & (Width-Element.Rwidth), "TEST")
	Return X> (Width-Element.Rwidth )
End Sub

Sub ScaleValue(Value As Int, LowestValue As Int, HighestValue As Int, MinRange As Int, MaxRange As Int) As Int 
	Dim ValueF As Float = (Min(Max(LowestValue, Value), HighestValue) - LowestValue) / (HighestValue-LowestValue), ValueI As Int = MinRange + (ValueF * (MaxRange-MinRange))
	Return ValueI
	'Log("SCALE1: " & ValueF & " " & Value & " " & ValueI & " " & Value & " " & LowestValue & " " &  HighestValue  & " " &  MinRange & " " & MaxRange)
	'Return MinRange + (ValueF * (MaxRange-MinRange))
End Sub

Sub MouseEvent(Down As Boolean, Element As ElementClicked, IsWithinBounds As Boolean, EventType As Int) 'As ElementClicked
	Dim Clicked As ElementClicked ,WasScrolling As Boolean,Radius As Int
	If Element.Index>-1 Then
		Clicked.Initialize 
		Clicked.Dimensions = Element.Dimensions 
		Clicked.Index2 = Element.Index2 
		
		If EventType = Event_Move Then
			Clicked.X2=Element.X2
			Clicked.y2=Element.y2
		End If

		Select Case Element.ElementType
			Case LCAR_Button
				If IfRside(Element) Then  Clicked.Index2 =1 
				LCAR_State(Element.Index, Down)
				'If IfRside(Clicked , GetElement(Element.Index)) Then Element.Index2 =1 
				
			Case LCAR_List 
				Clicked.X=Element.X2'COL X
				Clicked.Y=Element.y2'ROW Y
				Clicked.X2=Element.Index2
				Clicked.Index2=Element.Index2
				If Down Then 
					LCAR_SetSelectedItem(Element.Index, Element.Index2)
					VisibleList=Element.Index 
					If SmoothScrolling Then Element.RespondToAll = True
				Else If EventType = Event_Up Then
					NotMoving(Element.Index)	'set list to not scrolling		
					If SmoothScrolling Then IsClean = True
				End If
				IsWithinBounds= Element.Index2>-1 And Element.Index2 < GetListItemCount(Element.Index)
				Clicked.Index3 = Element.Index3 
'			Case ROM_Square
'				If EventType = Event_Down Then 
'					LCARSeffects5.ROM_LastUpdate=-1
'					IsClean=False'GetElement(Element.Index).
'				End If
				
			Case LCAR_Slider,LCAR_HorSlider
				LCAR_SliderState(Element, Down)
			Case LCAR_Dpad
				Radius= Min(Element.Dimensions.offX,Element.Dimensions.offY) * LCARSeffects.DpadCenter ' * 0.5
				Clicked.X2 = Element.Dimensions.offX/2
				Clicked.Y2 = Element.Dimensions.offY/2
				If Element.X >  Clicked.X2 - Radius And Element.x < Clicked.X2+Radius And Element.y >  Clicked.y2 - Radius And Element.y < Clicked.y2+Radius Then
					Clicked.Index2=0
					Clicked.X2=0
					Clicked.Y2=-1
				Else
					Clicked.Index2=Trig.FindDistance(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
					Clicked.X2 = Trig.GetCorrectAngle(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
					Clicked.Y2 = Trig.FindSection(Clicked.X2)
				End If
			Case LCAR_Okuda
				Clicked.X2 = Trig.GetCorrectAngle(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
				Clicked.y2 = Trig.FindDistance(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
				Clicked.X2 = Floor( Clicked.X2 / LCARSeffects.OkudaColWidth)
				Clicked.y2 = Floor( Clicked.Y2/ (    Min(Element.Dimensions.offX, Element.Dimensions.offy)/2 / LCARSeffects.OkudaRows) )
			Case LCAR_Engineering
				Clicked.Index2= ( Element.Dimensions.offy-Element.Y) / ItemHeight
			Case Klingon_Frame
				Select Case EventType
					Case Event_Down: Games.TRI_HandleMouse(Element.X,Element.Y,Event_Down)'down
					Case Event_Move: Games.TRI_HandleMouse(Element.X2,Element.Y2,Event_Move)'move	
				End Select
			Case VOY_Tricorder
				Select Case EventType
					Case Event_Down,Event_Up: LCARSeffects4.TRI_HandleMouse(Element.X,Element.Y,EventType)'up/down
					Case Event_Move: LCARSeffects4.TRI_HandleMouse(Element.X2,Element.Y2,Event_Move)'move	
				End Select
			Case LCAR_PdP
				Select Case EventType
					Case Event_Down: Games.PDPHandleMouse(Element.X,Element.Y,Event_Down,Element.Index2  )'down
					Case Event_Move: Games.PDPHandleMouse(Element.X2,Element.Y2,Event_Move,Element.Index2)'move	
				End Select
			Case LCAR_ThreeDGame 
				Select Case EventType
					Case Event_Down,Event_Up: Games.ThD_HandleMouse(Element.X,Element.Y,EventType)'down
					Case Event_Move: Games.ThD_HandleMouse(Element.X2,Element.Y2,Event_Move)'move	
				End Select
			Case ENT_Planets
				Select Case EventType
					Case Event_Down: LCARSeffects4.SOL_HandleMouse(Element.X,Element.Y,EventType,Element.Dimensions.offx, Element.Dimensions.offy)'down
					Case Event_Move: LCARSeffects4.SOL_HandleMouse(Element.X2,Element.Y2,Event_Move,Element.Dimensions.offx, Element.Dimensions.offy)'move
				End Select
			
			Case LCAR_Cards
				Select Case EventType
					Case Event_Down,Event_Up: Games.CARD_HandleMouse(Element.X,Element.Y,EventType,Element.Dimensions.offx, Element.Dimensions.offy)'down
					Case Event_Move: Games.CARD_HandleMouse(Element.X2,Element.Y2,EventType,Element.Dimensions.offx, Element.Dimensions.offy)'move
				End Select
			
			Case EVENT_Horizon, DRD_Timer
				Select Case EventType
					Case Event_Down: LCARSeffects4.EVN_and_BTL_HandleMouse(EventType, Element.X,Element.Y, Element.Dimensions.offx, Element.Dimensions.offy, Element.ElementType)
					Case Event_Move: LCARSeffects4.EVN_and_BTL_HandleMouse(EventType, Element.X2,Element.Y2, Element.Dimensions.offx, Element.Dimensions.offy, Element.ElementType)
				End Select
				
			Case LCAR_PdPSelector
				Games.PDPSelectedColor = Floor(Element.X / (Element.Dimensions.offX/6))
			Case LCAR_PToE
				Select Case EventType
					Case Event_Down
						LCARSeffects2.PToEHandleMouse(Element.X,Element.Y,Event_Down )'down
						 DirtyElement(Element.Index)
					Case Event_Move
						If LCARSeffects2.PToEHandleMouse(Element.X2,Element.Y2,Event_Move)Then DirtyElement(Element.Index) 'move	
					Case Event_Up
						If LCARSeffects2.PToEHandleMouse(Element.X,Element.Y,Event_Up) Then'up
							PushEvent(LCAR_PToE, Element.Index, 0, LCARSeffects2.TheSelectedElement.X, LCARSeffects2.TheSelectedElement.y, LCARSeffects2.TheSelectedElement.X, LCARSeffects2.TheSelectedElement.y, Event_Down)
						End If
						DirtyElement(Element.Index)
				End Select	
			
			Case LCAR_LWP
				LCAR_State(Element.Index, Down)
				If GetElement(Element.Index).LWidth=-1 Then
					Select Case EventType
							Case Event_Up:		CallSubDelayed3(WallpaperService, "TouchUpLWP", Element.X,Element.Y)
							Case Event_Down:	CallSubDelayed3(WallpaperService, "TouchDownLWP", Element.X,Element.Y)
							Case Event_Move
								CallSubDelayed3(WallpaperService, "TouchMoveLWP", Element.X2,Element.Y2)
								CallSubDelayed3(WallpaperService, "ScrollLWP", Element.Index, Element.x2)
					End Select
				End If
				
			Case LCAR_3Dmodel
				Select Case EventType
					Case Event_Move:	Wireframe.HandleMouse(Element.Index, EventType, Element.X2,Element.Y2)
					Case Else:			Wireframe.HandleMouse(Element.Index, EventType, Element.X,Element.Y)
				End Select
			
			Case LCAR_MultiLine, LCAR_Textbox
				Select Case EventType
					Case Event_Down:	HandleTextboxMouse(Element.Index, Element.ElementType, EventType, Element.X,Element.Y)
					Case Event_Move:	HandleTextboxMouse(Element.Index, Element.ElementType, EventType, Element.X2,Element.Y2)
				End Select
			
			Case LCAR_Answer
				Select Case EventType
					Case Event_Up
						'ResetLCARAnswer -4=direction (0=false/red/right to left, 1=true/green/left to right), -5=value 	'LCAR_AnswerMade
						If ResetLCARAnswer(Element.Index, -4) = 0 Then'false/red/right to left
							If ResetLCARAnswer(Element.Index,-5)<=5 Then PushEvent(LCAR_AnswerMade,Element.Index,0, 0,0,0,0, Event_Up)
						Else
							If ResetLCARAnswer(Element.Index,-5)>=95 Then PushEvent(LCAR_AnswerMade,Element.Index,1, 0,0,0,0, Event_Up)
						End If
						ResetLCARAnswer(Element.Index,-1)
					
					Case Event_Down
						If Element.X <= MinWidth Then
							ResetLCARAnswer(Element.Index, -2)
						Else If Element.X > Element.Dimensions.offX-MinWidth Then
							ResetLCARAnswer(Element.Index, -3)
						End If
					
					Case Event_Move
						Element.X = Element.X+Clicked.x2
						If Element.X<= MinWidth Then
							Radius=0
						Else If Element.x >=Element.Dimensions.offX-MinWidth Then
							Radius=100
						Else
							Radius = (Element.x-MinWidth) / (Element.Dimensions.offX-(MinWidth*2)) * 100
						End If
						ResetLCARAnswer(Element.Index,Radius)
						
				End Select
			
			Case TMP_FireControl
				Clicked.X=Element.X
				Clicked.y=Element.y
				Clicked.X2=Element.Dimensions.offx
				Clicked.Y2=Element.Dimensions.offy 
			
			Case CHX_Window
				Clicked.X=Element.X
				Clicked.y=Element.y
				Clicked.X2=Element.X2
				Clicked.y2=Element.y2
			
			Case LCAR_Tactical2
				LCARSeffects5.TouchTactical(Element.X,Element.Y,EventType,Element.Dimensions.offx, Element.Dimensions.offy)
			
			Case DrP_Board 
				Select Case EventType
					Case Event_Down,Event_Up: 	Games.DrP_HandleMouse(Element.Index, Element.X,Element.Y,  EventType,  Element.Dimensions.offx, Element.Dimensions.offy)'down
					Case Event_Move: 			Games.DrP_HandleMouse(Element.Index, Element.X2,Element.Y2,Event_Move, Element.Dimensions.offx, Element.Dimensions.offy)'move	
				End Select
			
			Case CRD_Main'NeedsUpdate
				Select Case EventType
					Case Event_Down,Event_Up: 	Wireframe.CRD_HandleMouse(Element.X,Element.Y,  EventType,  Element.Dimensions.offx, Element.Dimensions.offy)'down
					Case Event_Move: 			Wireframe.CRD_HandleMouse(Element.X2,Element.Y2,Event_Move, Element.Dimensions.offx, Element.Dimensions.offy)'move	
				End Select
			
			Case Else
				Log("ELSE: " & Element.ElementType)
				LCAR_State(Element.Index, Down)
		End Select
		If (Not(Down) And IsWithinBounds) Or Element.RespondToAll Then' OR multitouchenabled  Then			'must uncomment when GestureLibrary works again
			'IsWithinBounds not suitable for small screens
			Clicked.EventType=EventType
			Clicked.ElementType= Element.ElementType
			Clicked.Index=Element.Index			
			EventList.Add(Clicked)
		End If
	End If
	'Return Clicked
End Sub

Sub NukeEvents
	EventList.Initialize 
End Sub

Sub PushEvent(ElementType As Int,Index As Int,Index2 As Int,X As Int, Y As Int, X2 As Int, Y2 As Int, EventType As Int )
	Dim Clicked As ElementClicked 
	Clicked.Initialize
	Clicked.ElementType= ElementType
	Clicked.Index=Index
	Clicked.Index2=Index2
	Clicked.X =X
	Clicked.X2 =X2
	Clicked.Y =Y
	Clicked.Y2 =Y2
	Clicked.EventType=EventType
	If Not(EventList.IsInitialized) Then SetupTheVariables' EventList.Initialize 
	EventList.Add(Clicked) 
End Sub

'Index: 0=Text, 1=Side, 2=Tag, 3=Number
Sub LCAR_GetSelectedItems(ListID As Int, Index As Int) As List
	Dim Lists As LCARlist = LCARlists.Get(ListID), Listitem As LCARlistitem, Item As Int, RET As List 
	RET.Initialize
	For Item = 0 To Lists.ListItems.Size - 1
		Listitem = Lists.ListItems.Get(Item)
		If Listitem.Selected Then RET.Add(LCAR_GetListitemText2(Listitem, Index))
	Next
	Return RET 
End Sub

'Index: 0=Text, 1=Side, 2=Tag, 3=Number
Sub LCAR_GetListitemText(ListID As Int, Item As Int, Index As Int) As String
	Dim Lists As LCARlist = LCARlists.Get(ListID), Listitem As LCARlistitem 
	If Item <0 Then Item = Lists.SelectedItem 
	If Item< Lists.listitems.Size And Item>-1 Then
		Listitem = Lists.ListItems.Get(Item)
		Return LCAR_GetListitemText2(Listitem,Index)
	End If
End Sub
'Index: 0=Text, 1=Side, 2=Tag, 3=Number
Sub LCAR_GetListitemText2(Listitem As LCARlistitem, Index As Int) As String 
	Select Case Index
		Case 0: Return Listitem.Text 
		Case 1: Return Listitem.Side 
		Case 2: Return Listitem.Tag 
		Case 3: Return Listitem.Number
	End Select
End Sub

'User LCAR_IGNORE to ignore text or side
Sub LCAR_SetListitemText(ListID As Int, Item As Int, Text As String, Side As String)  As LCARlistitem
	Dim Lists As LCARlist = LCARlists.Get(ListID), Listitem As LCARlistitem 
	If Item < 0 Then Item = Lists.SelectedItem
	Listitem = Lists.ListItems.Get(Item)
	If Text <> LCAR_IGNORE Then Listitem.Text=Text
	If Side <> LCAR_IGNORE Then Listitem.Side = Side
	Return Listitem
End Sub
'User LCAR_IGNORE to ignore text or side
Sub LCAR_SetElementText(ElementID As Int, Text As String, Side As String)
	Dim Element As LCARelement 
	'If ElementID<LCARelements.Size Then
		Element = LCARelements.Get(ElementID)
		Element.IsClean =False
		If Text <> LCAR_IGNORE Then Element.Text=Text
		If Side <> LCAR_IGNORE Then Element.SideText = Side
		'LCARelements.Set(ElementID,Element)
	'End If
End Sub

Sub DirtyListItem(Lists As LCARlist, Listindex As Int, ToggleSelected As Boolean, SetOff As Boolean, SetOn As Boolean  )
	Dim ListItem As LCARlistitem ,WasSelected As Boolean 
	If Listindex>-1 And Listindex< Lists.ListItems.Size Then
		ListItem=Lists.ListItems.Get(Listindex)
		ListItem.IsClean = False
		If Lists.MultiSelect And ToggleSelected Then 
			WasSelected= ListItem.Selected 
			ListItem.Selected = Not(ListItem.Selected)
			If WasSelected And Not(ListItem.Selected) Then
				Lists.SelectedItems= Lists.SelectedItems-1
				If Lists.SelectedItem = Listindex Then Lists.SelectedItem=-1
			Else If ListItem.Selected And Not(WasSelected) Then
				Lists.SelectedItems= Lists.SelectedItems+1
				Lists.SelectedItem = Listindex
			End If
		Else
			If ToggleSelected Then SetOn= Not(ListItem.Selected)
			SelectNone(Lists)
			If SetOn Then
				ListItem.Selected =True
				ListItem.IsClean= False
				Lists.SelectedItem = Listindex
				Lists.SelectedItems=1
			End If
		End If
		Lists.ListItems.Set(Listindex,ListItem)
	End If
End Sub 
Sub SelectNone(Lists As LCARlist)
	Dim ListItem As LCARlistitem ,temp As Int
	For temp = 0 To Lists.ListItems.Size-1
		ListItem=Lists.ListItems.Get(temp)
		If ListItem.Selected Then
			ListItem.Selected = False
			ListItem.IsClean = False
		End If
		Lists.ListItems.Set(temp,ListItem)
	Next
	Lists.SelectedItems=0
	Lists.SelectedItem=-1
End Sub

Sub SetSelectedItem(Lists As LCARlist, ListIndex As Int)
	If Lists.MultiSelect Then 
		If ListIndex = Lists.SelectedItem Then 
			DirtyListItem(Lists,Lists.SelectedItem, False,False,False )
			Lists.SelectedItem = -1
		End If 
	Else 
		DirtyListItem(Lists,Lists.SelectedItem, False,False,False )
		If ListIndex = LCAR_SelectedItem Then ListIndex = Lists.ListItems.Size - 1
	End If
	Lists.SelectedItem = ListIndex
	DirtyListItem(Lists,Lists.SelectedItem,True,False,False)
End Sub






Sub IndexOfInt(Items() As Int, Value As Int) As Int 
	Dim temp As Int 
	For temp = 0 To Items.Length -1 
		If Value = Items(temp) Then Return temp 
	Next
	Return -1 
End Sub
Sub SetSelectedItem2(Lists As LCARlist, Index As Int)
	If Lists.SelectedItem > -1 Then 
		Dim Item As LCARlistitem = Lists.ListItems.Get(Lists.SelectedItem)
		Item.Selected = False 
		Item.IsClean = False 
	End If
	Lists.SelectedItem = Index
	Lists.IsClean = False 
End Sub

'Direction: -1=enter, 0=up, 1=right, 2=down, 3=left, 6=prev, 7=next, 8=start
Sub LCAR_DpadList(ListID As Int, Direction As Int)As Boolean 
	Dim lists As LCARlist, IsSpecialList As Int = -1, Direction2 As Int, SpecialLists() As Int = Array As Int(Main.ButtonMenu, 19, ButtonList)'Sidebar = 19
	If ListID>-1 And ListID < LCARlists.Size Then
		If IsListVisible(ListID) Then
			lists = LCARlists.Get(ListID)
			IsSpecialList = IndexOfInt(SpecialLists, ListID)
			If Direction = -1 Or Direction = 8 Then' center, start
				If lists.SelectedItem>-1 Then
					PushEvent(LCAR_List, ListID, lists.SelectedItem, lists.SelectedXY.X, lists.SelectedXY.Y, lists.SelectedItem, 0, Event_Up)
				End If
			Else
				If IsSpecialList > -1 Then 
					Select Case Direction
						Case 0,3,6'up left prev
							If lists.SelectedItem < 1 And IsSpecialList > -1 Then
								Direction2 = -1
								SetSelectedItem2(lists, -1)
							Else
								SetSelectedItem2(lists, lists.SelectedItem - 1)
							End If
						Case 1,2,7'right down next
							If lists.SelectedItem = lists.ListItems.Size - 1 And IsSpecialList > -1 Then
								Direction2 = 1
								SetSelectedItem2(lists, -1)
							Else
								SetSelectedItem2(lists, lists.SelectedItem + 1)
							End If
					End Select
					SetSelectedItem(lists, lists.SelectedItem)
				Else If lists.SelectedItem=-1 Then
					SetSelectedItem(lists,0)
				Else
					Select Case Direction
						Case 0: GetListItem(ListID, lists.SelectedXY.X, lists.SelectedXY.Y-1, True,True) 'up
						Case 1: GetListItem(ListID, lists.SelectedXY.X+1, lists.SelectedXY.Y, True,True) 'right
						Case 2: GetListItem(ListID, lists.SelectedXY.X, lists.SelectedXY.Y+1, True,True) 'down
						Case 3: GetListItem(ListID, lists.SelectedXY.X-1, lists.SelectedXY.Y, True,True) 'left
						Case 6: SelectNextVisibleList(False)'prev
						Case 7: SelectNextVisibleList(True)'next
					End Select
				End If
			End If
			BlinkState = True 
			lists.IsClean = False
			If Direction2 <> 0 Then 'next list 
				IsSpecialList = IsSpecialList + Direction2
				If IsSpecialList > SpecialLists.Length Then IsSpecialList = 0
				If IsSpecialList < 0 Then IsSpecialList = SpecialLists.Length - 1
				VisibleList = ListID 
			End If
			Return True
		End If
	End If
End Sub

Sub LCAR_SetSelectedItem(ListID As Int, SelectedItem As Int)
	Dim lists As LCARlist = LCARlists.Get(ListID)
	SetSelectedItem(lists,SelectedItem)
	'LCARlists.Set(ListID,lists)
End Sub

Sub GroupVisible(GroupID As Int ) As Boolean 
	Dim group As LCARgroup 
	If LCARGroups.IsInitialized Then 
		If GroupID>-1 And GroupID< LCARGroups.Size Then
			group=LCARGroups.get(GroupID)
			Return group.Visible 
		End If
	End If
	Return False
End Sub

Sub DoesSmoothlyScroll(Lists As LCARlist) As Boolean 
	If Lists.Locked Then Return False 
	Select Case Lists.Style 
		Case LCAR_Button: Return True
	End Select
End Sub

Sub LimitOffset(Value As Int) As Int
	Dim Limit As Int=ItemHeight+ListitemWhiteSpace, Before As Int = Value
	'If Value>0 Then Value=Value*-1
	If Value < -Limit  Then
		Do Until Value>= -Limit
			Value=Value+Limit
		Loop
	Else If Value> 0 Then 
		Do Until Value<0
			Value=Value-Limit
		Loop
	End If
	Log("Before: " & Before & " After: " & Value)
	Return Value
End Sub
Sub GesturesTouch(SurfaceID As Int, G As Gestures, PointerID As Int, Action As Int, X As Float, Y As Float) As Boolean
	'GestureMap As List GesturePoint
	Dim Point As GesturePoint, Element As ElementClicked, ret As Boolean, lists As LCARlist, SavePrevXY As Boolean = True
	Select Action
		Case G.ACTION_DOWN, G.ACTION_POINTER_DOWN
			'New Point is assigned to the new touch
			Point.Id = PointerID
			Element = FindClickedElement(SurfaceID, X,Y,True)
			Point.Element = Element
			Select Case Element.ElementType
				Case LCAR_List
					Point.PrevX=Element.X2'COL X
					Point.PrevY=Element.y2'ROW Y
					SavePrevXY=False 
					ListWasScrolling = -1
			End Select
			GestureMap.Add(Point)
			MouseEvent(True, Element, True, Event_Down)
			ret=True
		Case  G.ACTION_POINTER_UP, G.ACTION_UP
			'remove id
			If PointerID< GestureMap.Size Then
				Point = GestureMap.Get(PointerID)
				GestureMap.RemoveAt(PointerID)
				ret=True
				If Point.Element.Index>-1 Then
					MouseEvent(False, Point.Element, IsWithin(X, Y, Point.Element.Dimensions.currX, Point.Element.Dimensions.currY, Point.Element.Dimensions.offX,Point.Element.Dimensions.offY, False), Event_Up)
				End If
			End If
			If Action = G.ACTION_UP Then GestureMap.Clear		
		Case G.ACTION_MOVE 
			If PointerID< GestureMap.Size Then
				Point = GestureMap.Get(PointerID)
				Select Case Point.Element.ElementType
					Case LCAR_List 
						SavePrevXY= False
						Element = FindClickedElement(-1-Point.Element.Index , X,Y,False)

						If Element.Y2 <> Point.Element.y2 Then
							If Not( lists.IsInitialized) Then  lists = LCARlists.Get(Point.Element.Index)
							If Point.Element.Index2>=-1 Then
								If Not (lists.Locked) Then lists.SelectedItem = -1
								Point.Element.Dimensions.Initialize 
								DirtyListItem(lists, Point.Element.Index2, True,True,False)
								If Not (lists.Locked) Then Point.Element.Index2=-1
								GestureMap.Set(PointerID, Point)
							End If
							
							If Not(lists.Locked) Then
								'MouseEvent(False, point.Element, False)
								lists.isScrolling = True
								lists.IsClean = False
								'Log("SCROLL: " & Point.Element.y2 & " " & Element.Y2)
								Select Case lists.Style 
									Case TMP_Switch
										LimitStart(lists, (Point.Element.y2-Element.Y2) * LCAR_ListCols(lists.ColsLandscape , lists.ColsPortrait),False)
									Case Else
										LimitStart(lists, Point.Element.y2-Element.Y2, False)
								End Select
								Point.Element.y2=Element.Y2
							End If
							'lists.Start = lists.Start + (element.Y2-point.Element.y2)
							ret=True
						End If
						
						If SmoothScrolling Then
							If Not(lists.IsInitialized) Then lists = LCARlists.Get(Point.Element.Index)					
							Dim temp As Int = GetListItemHeight(lists) 'LCAR_Button  ItemHeight+ListitemWhiteSpace
							If DoesSmoothlyScroll(lists) Then
								lists.Offset = 0 
								If lists.isScrolling Or lists.Ydown <>0 Then
									If lists.Start>0 Then 'If Not( LimitStart(lists,0) ) Then
										'Log(Y & " : " & Point.Element )
										If Element.dimensions.OffY = 0 Then Element.Dimensions = ProcessLoc(lists.LOC, lists.Size)
										'lists.Offset = Abs(Y- Point.Element.Y) * -1 Mod (ItemHeight+ListitemWhiteSpace)
										'Log(Y & " " & temp & " " &  Element.Dimensions)
										lists.Offset =  (Y - Element.dimensions.currY) Mod temp 'LimitOffset(y -lists.Ydown)
										'Log("B: " & lists.Offset)
										lists.Offset = -temp + lists.Offset
										'Log("A: " & lists.Offset)
										lists.IsClean = False
									End If
								End If
								lists.Ydown=Y
								ret=True
							End If
						End If

						If Element.Y2 <> Point.prevY Or Element.x2 <> Point.prevX Then
							PushEvent(LCAR_List, Point.Element.Index, 0, Element.X2, Element.Y2, Point.prevX, Point.prevY, Event_Move)
							lists.isScrolling = True
							ListWasScrolling = Point.Element.Index
							Point.prevX = Element.X2
							Point.prevY = Element.Y2
							GestureMap.Set(PointerID, Point)
						End If
					Case LCAR_Slider,LCAR_HorSlider
						Element = Point.Element' FindClickedElement(-1-Point.Element.Index, x,y,False)
						Element.X2=X-OldX
						Element.Y2=Y-OldY
						Element.X = Element.X + Element.X2
						Element.Y = Element.Y + Element.Y2
						Element.RespondToAll=True
						MouseEvent(True, Element, True, Event_Move)
'					Case Klingon_Frame
'						Log("MOVE AT " & Element.X & ", " & Element.Y)
'						Games.TRI_HandleMouse(Element.X,Element.Y,Event_Move)
'							

					Case Else
						If Point.Element.RespondToAll Then
							Point.Element.X2=X-OldX
							Point.Element.Y2=Y-OldY
							MouseEvent(True, Point.Element, True, Event_Move)
						End If
				End Select
			End If
	End Select
	If SavePrevXY And Point.IsInitialized Then
		Point.prevX = X
		Point.prevY = Y
		GestureMap.Set(PointerID, Point)
	End If 
	'Log(act & " " & PointerID & " (" & x & "," & y & ")")
	OldX=X
	OldY=Y
	Return ret
End Sub
Sub LimitStart(Lists As LCARlist, ScrollBy As Int, RetIfEqualTo As Boolean)As Boolean
	Dim MAXLIMIT As Int = Max(0, LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)-Lists.LastMint+2), Ret As Boolean 
	Lists.Start = Max(0,Lists.Start + ScrollBy)
	'If Lists.Start<0 Then Lists.Start=0
	'If Lists.Start> Lists.LastMint Then Lists.Start=Lists.LastMint 
	'Log("SCROLLING " & ScrollBy)
	'MAXLIMIT=Lists.ListItems.Size-Lists.LastMint
	If RetIfEqualTo Then
		'Log(Lists.start & " - " &  MAXLIMIT)
		If Lists.start >= MAXLIMIT-2 Then Ret=True
	End If
	
	
	If Lists.Start > MAXLIMIT Then
		Lists.Start=MAXLIMIT
		'Lists.Offset=0
		Return True
	End If
	Return Ret
End Sub


Sub DrawLCARSGrid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, oX As Int, oY As Int, ColorID As Int, Angle As Float)
	Dim OvalWidth As Int, tX As Int, tY As Int , W2 As Int, H2 As Int,temp As Int, tH As Int, Color As Int, tX2 As Int, tY2 As Int
	'If SmallScreen Then OvalHeight=10 Else OvalHeight=20
	LCARSeffects.MakeClipPath(BG,X,Y,Width+1,Height+1)
	If ColorID = LCAR_Black Then 
		OvalWidth = ItemHeight
		W2=Width-OvalWidth*1.5
		H2=Height-OvalWidth*1.5
		Color = GetColor(Classic_Blue, True, 255)
		tH = BG.MeasureStringHeight("0123", LCARSeffects2.StarshipFont, Fontsize* 0.5)
		
		tY = W2 * 0.125 '/ 8
		tX = X+OvalWidth + tY * 0.5
		tY2 = H2 * 0.125 '/ 8
		tX2 = Y+OvalWidth + tY2 * 0.5 + tH * 0.5
		tH = Y+OvalWidth*0.5 + tH * 0.5
		For temp = 1 To 8 
			BG.DrawText(temp, tX, tH, LCARSeffects2.StarshipFont, Fontsize* 0.5, Color, "CENTER")
			BG.DrawText(temp, x + OvalWidth*0.5, tX2, LCARSeffects2.StarshipFont, Fontsize* 0.5, Color, "CENTER")
			tX = tX + tY
			tX2 = tX2 + tY2
		Next
	Else 
		OvalWidth=OvalHeight*2
		W2=Width-OvalWidth'*2
		H2=Height-OvalWidth'*2
		BG.DrawRect( SetRect(X,Y,Width,Height), Colors.Black, True ,0)
	End If

	tX=Max(5, oX)*0.01 * W2
	tY=Max(5, oY)*0.01 * H2
	
	DrawLCARSensorGrid(BG,  X+OvalWidth ,Y+OvalWidth, W2,H2, tX,tY, ColorID, Angle)
	BG.RemoveClip
	
	If ColorID = LCAR_Black Then 
		temp = OvalWidth * 0.5 - 2
		LCARSeffects.DrawTriangle(BG, X+OvalWidth + W2,  Y+ OvalWidth + tY - temp*0.25, temp,temp*0.5, 2, Color)'RIGHT
		LCARSeffects.DrawTriangle(BG, X + OvalWidth + tX - temp*0.25, Y+OvalWidth + H2, temp*0.5, temp, 1, Color)'BOTTOM
	else If OvalHeight > 0 Then
		temp=OvalHeight*1.5
		BG.DrawOval(SetRect( X, Y+tY+temp, OvalWidth,OvalHeight), Colors.white,True,0)
		'BG.DrawOval(SetRect( X+Width-OvalWidth,Y+tY+temp, OvalWidth,OvalHeight), Colors.white,True,0)
		
		BG.DrawOval(SetRect( X+tX+temp,Y,OvalHeight, OvalWidth), Colors.white,True,0)
		'BG.DrawOval(SetRect( X+tX+temp,Y+Height-OvalWidth,OvalHeight, OvalWidth), Colors.white,True,0)
	End If
End Sub

Sub DrawLCARSensorGrid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, oX As Int, oY As Int, ColorID As Int, Angle As Float )
	Dim Cx As Double, CWidth As Double,  color As LCARColor ,temp As Int,Width2 As Int, Height2 As Int, DoOval As Boolean = ColorID > LCAR_Black
	Dim StartSize As Float , Factor As Float, Border As Int
	StartSize= 0.1:Factor = 0.95:Border = 2
	If RedAlert Then ColorID= RedAlertMode'LCAR_RedAlert
	color = LCARcolors.Get(ColorID)
	ColorID= color.normal' getcolor(colorid, False,255)

	BG.DrawRect( SetRect(X + Border, Y + Border, Width - Border * 2, Height - Border * 2), ColorID, True,0)
	BG.DrawRect( SetRect(X + Border, Y + Border, Width - Border * 2, Height - Border * 2), Colors.White, False,Border)
    
	'Height2=width2*0.5
	'Log("ColorID: " & ColorID & " " & LCAR_Black)
	If DoOval Then
		temp=color.Selected
		If RedAlert Then temp = HalfWhite
		If Width<Height Then 
			Width2=Trig.MaxSizeOfOval2(Width, Height, Angle+90)*0.9
		Else 
			Width2= Height
		End If
		'Width2=Trig.MaxSizeOfOval2(Width, Height, Angle+90)*0.9
		Height2=Width2*0.5
		'Log(cwidth)
		BG.DrawOvalRotated(SetRect(X+Width/2-Width2/2,Y+Height/2-Height2/2,Width2,Height2), temp, True, 0,  Angle)'0=east instead of north
	End If 
	
    CWidth = StartSize * oX
    Cx = oX + X
	BG.DrawRect(SetRect(Cx, Y + 1, 1, Height - 2), Colors.White,False,3)
	BG.DrawRect(SetRect(X + 1, oY + Y, Width - 2, 1), Colors.White,False,3)
    
    temp = X + Border
    Do While Cx > temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx - CWidth
        If Cx > X Then BG.DrawRect(SetRect(Cx, Y, 1, Height), Colors.White,False,1)
        If CWidth < 2 Then Cx = 0'exit loop
    Loop
    
    CWidth = StartSize * (Width - oX)
    Cx = oX + X
    temp = X + Width - Border
    Do While Cx < temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx + CWidth
        If Cx < temp Then BG.DrawRect(SetRect(Cx, Y, 1, Height), Colors.White,False,1) 
        If CWidth < 2 Then Cx = X + Width'exit loop
    Loop
    
    CWidth = StartSize * oY
    Cx = oY + Y
    temp = Y + Border
    Do While Cx > temp
       CWidth = Max(2, CWidth * Factor)
        Cx = Cx - CWidth
        If Cx > temp Then  BG.DrawRect(SetRect(X, Cx, Width, 1), Colors.White,False,1) 
        If CWidth < 2 Then Cx = 0'exit loop
    Loop
    
    CWidth = StartSize * (Height - oY)
    Cx = oY + Y
    temp = Y + Height - Border
    Do While Cx < temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx + CWidth
        If Cx < temp Then BG.DrawRect(SetRect(X, Cx, Width, 1), Colors.White,False,1) 
        If CWidth < 2 Then Cx = temp'exit loop
    Loop
End Sub

Sub GetList(ListID As Int) As LCARlist 
	Return LCARlists.Get(ListID)
End Sub
Sub IsListVisible(ListID As Int)As Boolean 
	If ListID > -1 And ListID < LCARVisibleLists.Size Then Return LCARVisibleLists.Get(ListID) 'GetList(ListID).Visible 
End Sub 

'Direction: False=down, True=Up
Sub SelectNextVisibleList(Direction As Boolean) As Int 
	Dim temp As Int, Start As Int, Finish As Int, Inc As Int = 1 
	If Direction Then 
		Start = VisibleList + 1
		Finish = LCARVisibleLists.Size-1
	Else 
		Start = VisibleList - 1 
		Inc = -1 
	End If
	For temp = Start To Finish Step Inc
		If temp <> VisibleList Then
			If LCARVisibleLists.Get(temp) Then
				VisibleList =temp
				Return temp 
			End If
		End If
	Next
End Sub
Sub DirtyElement (ElementID As Int) 
	Dim temp As LCARelement 
	If ElementID<LCARelements.Size Then
		temp = LCARelements.Get(ElementID)
		If temp.Visible Then
			temp.IsClean=False
			'LCARelements.Set(ElementID,temp)
		End If
	End If
End Sub




Sub GetSelectedText As String 
	Return LCAR_GetElement(KBCancelID+5).Text
End Sub

Sub HideSideBar(BG As Canvas,ListID As Int ,TheStage As Int)
	If ListID = -1 Then 
		LCAR_HideElement(BG, LCAR_Sidebar, True,False,True)
		LCARSeffects.frameoffset=0
	Else
		LCAR_ClearList(LCAR_Sidebar,0)
		LCARSeffects.frameoffset=0
		LCARSeffects.NeedsRedrawFrame=True
		LCAR_HideElement(BG, LCAR_Sidebar, True,False,True)
		LCARSeffects.ShowFrame(BG, False, True, TheStage)
	End If
End Sub
Sub HideButtonBar(BG As Canvas)
	If ButtonList>-1 Then LCAR_HideElement(BG, ButtonList, True,False,True)
End Sub
Sub SetButtonText(Index As Int, Text As String)
	LCAR_SetListitemText(ButtonList, Index, Text, False)
End Sub
Sub SeedButtonBar(BG As Canvas, Items As List)
	Dim Height As Int, Y As Int ,Width As Int
	Height=ButtonBarHeight
	LCAR_ClearList(ButtonList,0)
	LCAR_AddListItems(ButtonList, LCAR_Random,0,  Items)
	'bottom = 72,145
	Y=BG.MeasureStringHeight("TEST", LCARfont, BigTextboxHeight)+ ChartSpace'height of text box
	Height=Height- Y - ChartSpace
	Width=Min((Height*1.5) * Items.Size, Min(ScaleWidth,ScaleHeight)- GetScaledPosition(3,True))' API.iif(SmallScreen,53,103))
	ResizeList(ButtonList, Width,Height, -1, -Width-ChartSpace, Y, True)
	LCAR_HideElement(BG, ButtonList,True,True,False)
	RemoveAnimation(ButtonList,True)
End Sub 
Sub ButtonBarHeight As Int
	If ButtonList=-1 Then ButtonList = LockListStart(LCAR_AddList("ButtonBar", 0, 0,0, -100,0, 100,50, False, 0, 0,0, False,False,False, LCAR_MiniButton), True)
	Return GetScaledPosition(0,False)' API.IIF(SmallScreen,72,145)
End Sub

'ListID,TheStage: -1=use default values
Sub SeedSideBar(BG As Canvas, ListID As Int, Items As List,DoAnimation As Boolean, LeftBar As Boolean ,TheStage As Int) As Boolean 
	Dim Lists As LCARlist , Width As Int = 100, Y As Int = 256
	If SmallScreen Then 
		Width = 50
		Y=132
	Else If CrazyRez>0 Then 
		Width= Width*CrazyRez
		Y= GetScaledPosition(4,False)'  (CrazyRez*250)+LCARSeffects.frameoffset'    503
	End If
	If ListID=-1 Then ListID=19 
	LCAR_Sidebar=ListID 
	LCAR_ClearList(LCAR_Sidebar,0)
	LCARSeffects.NeedsRedrawFrame=True
	LCAR_AddListItems(LCAR_Sidebar, LCAR_Random,0,  Items)
	LockListStart(LCAR_Sidebar,True)
	LCAR_SetSelectedItem(LCAR_Sidebar,0)
	LCARSeffects.frameoffset=ListItemsHeight(Items.size)
	ResizeList(LCAR_Sidebar,  Width+ListitemWhiteSpace, LCARSeffects.frameoffset, -1,0,Y, True)
	LCARSeffects.ShowFrame(BG, DoAnimation, LeftBar, TheStage)
	LCAR_HideElement(BG, LCAR_Sidebar,True,True,False)
	If DoAnimation Then
		Lists = LCARlists.Get(LCAR_Sidebar)
		Lists.Opacity.Current=0
	End If
	Log("Show sidebar")
End Sub

Sub IsNumboardVisible As Boolean 
	Return IsListVisible(NumListID) And NumListID>0
End Sub
Sub MakeNumBoard(SurfaceID As Int, Group As Int, Settings As Map )
	'NumListID as Int, NumButtonID as Int, NumGroup as int
	'0,1,2,3,4,5,6,7,8,9, next, prev, left, right, delete, backspace, ok, cancel
	
	Dim X As Int, Y As Int, Width As Int, Height As Int , MidHeight As Int, MidWidth As Int
	X=0'105
	Y=400
	Width=200
	Height=( 4*(ItemHeight+ListitemWhiteSpace))
	
	
	NumGroup=Group
	NumListID= LCAR_AddList("Numboard",  SurfaceID,  3  ,3,  X+110,Y+ItemHeight+5, Width ,Height,  False,  -1, leftside, leftside,  True, False,False ,0 )
	SetAlignment(NumListID,5)
	LockListStart(NumListID,True)
	
	Dim Keys As List, temp As Int 
	Keys.Initialize2(Array As String("7", "4", "1", "0", "8", "5", "2", "<ı", "9", "6", "3", "ı>"))
	For temp = 0 To Keys.Size-1
		LCAR_AddListItem(NumListID, Keys.Get(temp), LCAR_Random, API.GetKeyCode(Keys.Get(temp),False, False)    , "", False, "", 0,False,-1)
	Next
	
	MidHeight=Height/2 + ItemHeight+2
	MidWidth=(Width-20)/2-2
	NumButtonID=LCAR_AddLCAR("NumCancel", SurfaceID,  X,Y, 130,MidHeight,100  ,ItemHeight, LCAR_Orange, LCAR_Elbow ,"CANCEL","","", Group,   True, 8,  True,0, 0)
		LCAR_AddLCAR("NumBKSP", SurfaceID,  X+133,Y, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"BKSP","","", Group,   True, 5,  True,0,  0)'+1
		LCAR_AddLCAR("NumDEL", SurfaceID,  X+136+MidWidth,Y, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"DEL","","", Group,   True, 5,  True,0,  0)'+2
		LCAR_AddLCAR("NumDELIP", SurfaceID,  X+139+MidWidth*2,Y, -1,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"DELETE IP","","", Group,   True, 5,  True,0,  0)'+3
	
	LCAR_AddList("NumboardIPs",  SurfaceID, 1  ,1, X+139+MidWidth*2,Y+ItemHeight+5, 0 , Height,  False,  -1,0, 0, False, False,False ,0 )
	LoadIPs(NumListID+1, Settings )
	
	LCAR_AddLCAR("NumOK", SurfaceID,  X,Y+MidHeight+3, 130,MidHeight,100  ,ItemHeight, LCAR_Orange, LCAR_Elbow ,"OK","","", Group,  True, 2,  True,2,  0)'+4
		LCAR_AddLCAR("NumPREV", SurfaceID,  X+133,Y+Height+ItemHeight+7, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"PREV","","", Group,   True, 5,  True,0,  0)'+5
		LCAR_AddLCAR("NumNEXT", SurfaceID,  X+136+MidWidth,Y+Height+ItemHeight+7, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"NEXT","","", Group,   True, 5,  True,0,  0)'+6
		LCAR_AddLCAR("NumSAVE", SurfaceID,  X+139+MidWidth*2,Y+Height+ItemHeight+7, -1,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"SAVE IP","","", Group,   True, 5,  True,0,  0)'+7
	
	LCAR_AddLCAR("NumText1", SurfaceID,  105, 16,  -1 , 16 , -1,0,LCAR_Orange, LCAR_Textbox , "192.", "", "",   Group, False,    1, False, 0,0)'+8
		LCAR_AddLCAR("NumText2", SurfaceID,  120, 0,  -1 , BigTextboxHeight , 0,3,LCAR_Orange, LCAR_Textbox , "168", "", "",   Group, False,    1,True, 0,0)'+9
		LCAR_AddLCAR("NumText3", SurfaceID,  140, 16,  -1 , 16 ,-1,0,LCAR_Orange, LCAR_Textbox , ".0.1:3030", "", "",   Group, False,    1,False, 0,0)'+10
		
	LCAR_Blink(NumButtonID+9,True)
End Sub
Sub LoadIPs(ListID As Int, Settings As Map) 
	Dim temp As Int, Count As Int
	If Not(Settings.IsInitialized) Then Settings= API.AutoLoad 
	Count = Settings.GetDefault("SaveIPs", 0)
	For temp = 0 To Count-1
		LCAR_AddListItem(ListID, Settings.Get("SavedIP" & temp), LCAR_Random, -1, "", False, "", 0, False,-1)
	Next
End Sub
Sub LoadIP(BG As Canvas, Index As Int, Settings As Map, CurrentPort As Int )As IPaddress 
	Dim IP As IPaddress  
	SelectedIP = Index 
	IP = API.ParseIP(Settings.Getdefault("SavedIP" & Index, "0.0.0.0"))
	IP.Port = CurrentPort
	If IP.Octets(0) = 0 Then 
		Return IP
	Else
		Return ResizeNumboard(BG, IP, 4,True)
	End If
End Sub
Sub GetSavedIP(IP As String, Settings As Map) As Int 
	Dim temp As Int, Count As Int
	Count = Settings.GetDefault("SaveIPs", 0)
	For temp = 0 To Count-1
		If IP.EqualsIgnoreCase(Settings.Get("SavedIP" & temp)) Then Return temp
	Next
	Return -1
End Sub

Sub SaveIP(IP As IPaddress, Settings As Map) As Boolean 
	Dim Count As Int, IPA As String 
	Count = Settings.GetDefault("SaveIPs", 0)
	IPA=API.GetIP(IP,False)  '
	If GetSavedIP( IPA,Settings )=-1 Then
		LCAR_AddListItem(NumListID+1, IPA, LCAR_Random, -1, "", False, "", 0, False,-1)
		Settings.Put("SavedIP" & Count , IPA)
		Settings.put("SaveIPs", Count+1)
		Return True
	End If
End Sub 
Sub DeleteIP(Index As Int, Settings As Map) As Boolean 
	Dim temp As Int, Count As Int
	Count = Settings.GetDefault("SaveIPs", 0)
	If Index>-1 Then
		LCAR_RemoveListitem(NumListID+1,Index)
		For temp = Index To Count-2
			Settings.put("SavedIP" & temp,  Settings.Get("SavedIP" & (temp+1) ) )
		Next
		Count=Count-1
		Settings.put("SaveIPs", Count)
		Settings.Remove("SavedIP" & Count)
	End If
	If SelectedIP =Index Then SelectedIP =-1
End Sub

Sub ResizeNumboard(BG As Canvas, IP As IPaddress, SelectedOctet As Int, SelectAll As Boolean )As IPaddress 
	Dim tempstr As StringBuilder ,temp As Int, temp2 As Int, tempstr2 As String ,oldsize As Int , startofmiddle As Int,tempstr3 As StringBuilder ,X As Int
	SelectedOctet= Min(4,SelectedOctet)
	temp2=SelectedOctet
	tempstr.Initialize 
	tempstr3.Initialize 
	X=105

	If temp2>3 Then 
		'temp2=3
		tempstr2=  IP.Port
	Else
		tempstr2 = IP.Octets(SelectedOctet)
		For temp = SelectedOctet+1 To 3
			tempstr3.Append ("." & IP.Octets(temp) )
		Next
		tempstr3.Append(":" & IP.Port)
	End If
	For temp = 0 To temp2-1
		tempstr.Append( IP.Octets(temp))
		If temp < 3 Then tempstr.Append (".") Else tempstr.Append(":")
	Next
	
	'text before the selected octet
	LCAR_SetElementText( NumButtonID+8,tempstr.ToString, "")
	temp=TextWidth(BG, tempstr.ToString )
	ForceElementData( NumButtonID+8,  X, 16, 0,0, temp,16,0,0,0,255,True,False)
	
	'Selected Octet
	startofmiddle=X+ temp
	ForceElementData(NumButtonID+9, startofmiddle,0,0,0,20,BigTextboxHeight,0,0,255,255,True,False)
	LCAR_SetElementText( NumButtonID+9,tempstr2, "")
	If SelectAll Then API.SelectAll(NumButtonID+9)
	
	oldsize=Fontsize
	Fontsize=BigTextboxHeight
	startofmiddle=startofmiddle+ TextWidth(BG, tempstr2)+2
	Fontsize=oldsize
	
	ForceElementData(NumButtonID+10, startofmiddle, 16, 0,0, TextWidth(BG, tempstr3.ToString) ,16, 0,0,255,255,True,False)
	LCAR_SetElementText( NumButtonID+10,tempstr3.ToString, "")
	
	'startofmiddle=startofmiddle+ textwidth(bg, tempstr3.ToString)
	BG.DrawRect( SetRect(X,0,200,40),Colors.Black,True,1)
'	
'	Dim tempel As LCARelement = lcarelements.Get(NumButtonID)
'	tempel.Size.currX= X-3
'	tempel.LWidth=X-3
'	tempel = LCARelements.Get(NumButtonID+4)
'	tempel.Size.currX= X-3
'	tempel.LWidth=X-33  
	
	IP.SelectedOctet = SelectedOctet
	Return IP 
End Sub

Sub ShowNumBoard(Bg As Canvas,IP As IPaddress )
	Dim X As Int, Y As Int, Width As Int, Height As Int , MidHeight As Int, MidWidth As Int ,OFF As Int, BarWidth As Int,Element As LCARelement , ElbowWidth As Int 
	X=0'105
	Y=Bg.MeasureStringHeight("TEST", LCARfont, BigTextboxHeight)+ ChartSpace
	Width= ScaleWidth /3
	BarWidth=100 * GetScalemode 
	If BarWidth>100 Then ElbowWidth = BarWidth*0.5 Else ElbowWidth = 20
	
	Height=( 4*(ItemHeight+ListitemWhiteSpace))
	MidHeight=Height/2 + ItemHeight+2
	MidWidth=(Width-20)/2-2

	ElbowWidth = X+BarWidth+33
	RandomizeColors(NumListID)
	ResizeList(NumListID, Width-18 ,0 ,-1,ElbowWidth,Y+Height, True)
	LCAR_HideElement(Bg, NumListID, True, True,False )
	ResizeList(NumListID, Width-18 ,Height ,-1, ElbowWidth,Y+ItemHeight+5,True)
	
	RandomizeColors(NumListID+1)
	ResizeList(NumListID+1, 0 ,0 , -1, X+BarWidth+39+MidWidth*2,Y+Height, True)
	LCAR_HideElement(Bg, NumListID+1, True, True,False)
	ResizeList(NumListID+1, 0 ,Height ,-1,X+BarWidth+39+MidWidth*2,Y+ItemHeight+5,True)
	
	HideGroup(NumGroup, True,  True)
	ResizeNumboard(Bg, IP, 1,True)
	
	OFF=MidHeight-ItemHeight
	ForceElementData(NumButtonID, X,Y, 0, OFF, 	BarWidth+30,MidHeight,0,-OFF,0,255,True,True)'CANCEL
	ForceElementData(NumButtonID+1,X+BarWidth+33,Y,0,OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'BKSP
	ForceElementData(NumButtonID+2,X+BarWidth+36+MidWidth,Y,0,OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'DEL
	ForceElementData(NumButtonID+3,X+BarWidth+39+MidWidth*2,Y,0,OFF,0,ItemHeight,0,0,0,255,True,True)'DELETE IP
	
	ForceElementData(NumButtonID+4, X,Y+MidHeight+3, 0,0, BarWidth+30,MidHeight,0,-OFF,0,255,True,True)'OK
	ForceElementData(NumButtonID+5,X+BarWidth+33,Y+Height+ItemHeight+7,0,-OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'PREV
	ForceElementData(NumButtonID+6,X+BarWidth+36+MidWidth,Y+Height+ItemHeight+7,0,-OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'NEXT
	ForceElementData(NumButtonID+7,X+BarWidth+39+MidWidth*2,Y+Height+ItemHeight+7,0,-OFF,0,ItemHeight,0,0,0,255,True,True)'SAVE IP
	
	Element= GetElement(NumButtonID)
	Element.LWidth=BarWidth
	Element.RWidth = ItemHeight
	Element= GetElement(NumButtonID+4)
	Element.LWidth=BarWidth
	Element.RWidth = ItemHeight
End Sub

Sub HideNumboard(BG As Canvas)
	LCAR_HideElement(BG, NumListID, True,  False, False )
	LCAR_HideElement(BG, NumListID+1, True, False,False)
	HideGroup(NumGroup, False, False)
End Sub


Sub HandleNumboard(BG As Canvas, Key As String, IP As IPaddress, Settings As Map) As IPaddress 
	Dim Element As LCARelement ,APIKB As APIKeyboard, SelectAll As Boolean 
	SelectAll= False
	If Key.EqualsIgnoreCase(API.getstring("prev")) Then
		If IP.SelectedOctet>0 Then
			IP.SelectedOctet = IP.SelectedOctet-1
			SelectAll=True
		End If
	Else If Key.EqualsIgnoreCase(API.getstring("next")) Then
		If IP.SelectedOctet<4 Then 
			IP.SelectedOctet = IP.SelectedOctet+1
			SelectAll=True
		End If
	Else If Key.EqualsIgnoreCase(API.GetString("ip_save")) Then
		SaveIP(IP,Settings) 
		Return IP
	Else If Key.EqualsIgnoreCase(API.GetString("ip_delete")) Then
		'deleteip( getsavedip ( api.GetIP(ip,False), settings) , settings )
		DeleteIP(SelectedIP, Settings)
		SelectedIP=-1
		Return IP
	Else If Key.EqualsIgnoreCase(API.GetString("enter")) Then
		PushEvent(LCAR_OK, KBCancelID+5,0,0,0,0,0,Event_Up)
	 	Return IP
	Else If Key.EqualsIgnoreCase(API.GetString("first")) Then 
		IP.SelectedOctet = 0
		SelectAll=True
	Else
		Element=LCARelements.Get(NumButtonID+9)
		APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
		APIKB=API.HandleKeyboard(APIKB,Key)
		HandleElement(Element,APIKB,NumButtonID+9)
		If APIKB.Text.Length = 0 Then
			APIKB.Text= "0"
			SelectAll=True
		End If
		If IP.SelectedOctet <3 And APIKB.Text > 255 Then
			IP.SelectedOctet=IP.SelectedOctet+1
			SelectAll=True
		Else
			IP = API.SetOctet(IP, IP.SelectedOctet, APIKB.Text)
			If  IP.SelectedOctet<4 And APIKB.Text.Length=3 Or (APIKB.Text ="0" And Key = KeyCodes.KEYCODE_0) Then 
				IP.SelectedOctet=IP.SelectedOctet+1
				SelectAll=True
			End If
		End If
	End If
	IsClean=False
	Return ResizeNumboard(BG, IP, IP.SelectedOctet,SelectAll)
End Sub

Sub BackupRestoreKB(Save As Boolean, Text As String)
	Dim Element As LCARelement 
	Element=LCARelements.Get(KBCancelID+5)
	If Save Then
		BackupKB = API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
	Else If BackupKB.IsInitialized Then 'restore
		If Text.length>0 Then
			BackupKB=API.SetSelText(BackupKB, Text , False)
			BackupKB.Shift=False
		End If
		HandleElement(Element,BackupKB, KBCancelID+5)
		IsClean=False
	End If
End Sub

Sub HandleElement(Element As LCARelement , APIKB As APIKeyboard, ElementID As Int)
	Element.IsClean=False
	Element.Text = APIKB.Text'.ToUpperCase 
	Element.LWidth = APIKB.SelStart 
	Element.RWidth = APIKB.SelLength 
	LCARelements.Set(ElementID, Element)
End Sub

Sub InsertText(Text As String) 
	Dim Element As LCARelement ,APIKB As APIKeyboard 
	ClearScreen(Null)
	Element=LCARelements.Get(KBCancelID+5)
	APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift, KBCaps)
	APIKB=API.SetSelText(APIKB, Text , False)
	APIKB.Shift=False
	HandleElement(Element,APIKB, KBCancelID+5)
	IsClean=False
End Sub
Sub HandleKeyboard(KeyCode As Int) As Boolean 
	Dim Element As LCARelement, APIKB As APIKeyboard, ret As Boolean
	Select Case KeyCode
		Case KeyCodes.KEYCODE_SHIFT_LEFT, KeyCodes.KEYCODE_SHIFT_RIGHT
			If SymbolsEnabled Then 	KBLayout=(KBLayout+1) Mod 3
			SeedKeyboard
		Case -97: 	KBShift = Not(KBShift)'insert
		Case -100: 	InsertText( API.Clipboard(1,"") )'paste
		Case 4, API.BUTTON_C, -96 'back button, caps
			Log("Caps")
			KBCaps = Not(KBCaps)
			ret=True
		Case Else
			ClearScreen(Null)
			Element=LCARelements.Get(KBCancelID+5)
			APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
			APIKB=API.HandleKeyboard(APIKB,KeyCode)
			HandleElement(Element,APIKB, KBCancelID+5)
	End Select
	IsClean=False
	Return ret
End Sub 

Sub IsKeyboardVisible(BG As Canvas, AnimationStage As Int,Toggle As Boolean  ) As Boolean
	Dim Visible As Boolean ''HasHardwareKeyboard As Boolean , KBisVisible As Boolean
	If HasHardwareKeyboard Then
		Visible = KBisVisible'
	Else
		Visible =  IsListVisible(KBListID)
	End If
	'If Visible Then DirtyElement(KBCancelID+5)
	If AnimationStage>0 And Not( ElementMoving) Then 
		If Visible Then
			If Toggle Then
				HideKeyboard(BG,AnimationStage)
			Else
				ShowKeyboard(BG, AnimationStage)
			End If
		Else
			If Toggle Then ShowKeyboard(BG, AnimationStage)
		End If
	End If
	Return Visible
End Sub

Sub SeedKeyboard
	Dim Keys As List, temp As Int,tempstr As String 
	LCAR_ClearList(KBListID,0)
	If Not(SymbolsEnabled) Then KBLayout=0
	Select Case KBLayout
		Case 0: Keys.Initialize2(Array As String("Q", "A", "Z", "W", "S", "X", "E", "D", "C", "R", "F", "V", "T", "G", "B", "Y", "H", "N", "U", "J", "M", "I", "K", API.getstring("kb_shift"), "O", "L", "<ı", "P", ".", "ı>" ))
		Case 1: Keys.Initialize2(Array As String("1", "!", "/", "2", "@", "-", "3", "?", "+", "4", "$", "=", "5", "%", ",", "6", "^", "'", "7", "&", "|", "8", "*", API.getstring("kb_shift"), "9", "(", "<ı", "0", ")", "ı>" ))
		Case 2: Keys.Initialize2(Array As String("~", API.getstring("kb_caps"), API.getstring("kb_copy"), "`", API.getstring("kb_insert"), API.getstring("kb_cut"), "#", "", API.getstring("kb_paste"), "", "", "", "•", "", "", "{", "<", "-", "}", ">", "_", "[", ";", API.getstring("kb_shift"), "]", ":", "<ı", "\", Eval.vbQuote, "ı>" ))
	End Select
	
	For temp = 0 To Keys.Size-1
		tempstr = Keys.Get(temp)
		If tempstr = "_" Then tempstr = "—"
		LCAR_AddListItem(KBListID, tempstr, LCAR_Random, API.GetKeyCode(Keys.Get(temp),False, KBShift)    , "", False, "", 0,False,-1)
	Next
End Sub
Sub MakeKeyboard(SurfaceID As Int,  Group As Int)
	'Dim ListID As Int',X As Int, Y As Int, Width As Int, Height As Int'  ,temp As Int ,temp2 As Int ,Unit As Int
	'height=3*(itemheight+listitemwhitespace)
	KBGroup=Group
	KBListID= LCAR_AddList("Keyboard",  SurfaceID,  10  ,10,  0,0, -1 ,0,   False,  -1, leftside, leftside,  True, False,False ,0 )
	SetAlignment(KBListID,5)
	LockListStart(KBListID,True)
	
	'lcar_addlistitem(KBListID, "Q", LCAR_Random,KeyCodes.KEYCODE_Q, "", False, "", 0,False,-1)
	
	'SeedKeyboard
	'LCAR_AddListItems(KBListID , LCAR_Random,0 , Array As String("Q", "A", "Z", "W", "S", "X", "E", "D", "C", "R", "F", "V", "T", "G", "B", "Y", "H", "N", "U", "J", "M", "I", "K", "SHIFT", "O", "L", "<", "P", "#", ">" ))
	
	KBCancelID=LCAR_AddLCAR("KBCancel", SurfaceID,  0,0,130,88,100,ItemHeight, LCAR_Orange, LCAR_Elbow ,API.GetString("kb_cancel"),"","", Group,  False, 2,  True, 2,0)
	LCAR_AddLCAR("KBBackspace" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, API.GetString("kb_backspace"), "", "", Group, False, 5,True,0,0)'+1
	LCAR_AddLCAR("KBSpace" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, API.GetString("kb_space"), "", "", Group, False, 5,True,0,0)'+2
	LCAR_AddLCAR("KBDelete" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, API.GetString("kb_delete"), "", "", Group, False, 5,True,0,0)'+3
	LCAR_AddLCAR("KBOK",SurfaceID,0,0,130,88 ,100,ItemHeight, LCAR_Orange, LCAR_Elbow , API.GetString("kb_ok"),"","", Group,  False, 2 ,  True, 3,0)'+4
	
	RespondToAll(LCAR_AddLCAR("KBText", SurfaceID,  105, 0,  -1 , BigTextboxHeight , 0,6,LCAR_Orange, LCAR_Textbox , API.GetString("kb_search"), "", "",   Group, False,    1,True, 0,0))'5
	'LCAR_AddLCAR("KBText", SurfaceID,  105, 0,  -1 , BigTextboxHeight , 0,6,LCAR_Orange, LCAR_MultiLine , "SEARCH", "", "",   Group, False,    1,True, 0,0)'5
	
	'LCAR_MultiLine
End Sub

Sub SelectText(Text As String ) As Boolean 
	Dim Element As LCARelement ,ElementID As Int 
	If KBCancelID>0 Then
		ElementID=KBCancelID+5
		If Text = LCAR_IGNORE Then 
			LCAR_HideElement(EmergencyBG, ElementID, False, False, True)
			Return True
		End If
		If Not(IsElementVisible(ElementID)) Then 
			ForceShowGroup(KBGroup, False)
			ForceShow(ElementID,True)
		End If
		Element = LCARelements.Get(ElementID)
		Element.Visible=True
		Element.IsClean =False
		Element.Text=Text.ToUpperCase 
		Element.LWidth=0
		Element.rWidth=Text.Length 
		'LCARelements.Set(ElementID,Element)
		Return True
	End If
End Sub
Sub GetInputText As String 
	Return LCAR_GetElement(KBCancelID+5).Text 
End Sub



Sub HideKeyboard(BG As Canvas, AnimationStage As Int ) 
	Dim Height As Int, Unit As Int , Element As LCARelement
	Height=KeyboardHeight
	Unit=(ScaleWidth-276)/4
	KBisVisible=False
	KBShift=False
	ToggleMultiLine(False)
	
	ResizeList(KBListID,  ScaleWidth,  Height,   -1,0, ScaleHeight, True)
	LCAR_HideElement(BG, KBListID, True , False ,False)
	'FadeList(bg,KBListID,False)
	MoveLCAR(KBCancelID,    0, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+1,134, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+2,138+Unit, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+3,-134-Unit, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+4,-130, ScaleHeight, 0,0,0,True,False,True)
	
	LCAR_HideElement(BG,KBCancelID+5,False,False ,False)
	
	'Element= lcarelements.Get(17)
	'If element.Visible Then ForceElementData(17, Element.LOC.currX , Element.LOC.currY ,0,0, Element.Size.currX, Element.Size.currY +Height+4,0, Height-4, 255,255, True,True)
	WebviewOffset=Height+16
	PushEvent(LCAR_Keyboard,  -1 ,Height+4,0,0,0,0,0)
	'LCARSeffects.QuestionAsked=False
End Sub

Sub ListItemsHeight(Items As Double) As Int
	Return Items*(ItemHeight+ListitemWhiteSpace)
End Sub


Sub ShowTextbox(BG As Canvas)
	Dim temp As Int 
	MoveLCAR(KBCancelID+5, GetScaledPosition(0,True), 0, -1,0, 255,True,False,False)
	ForceShow(KBCancelID+5,True)
	For temp = 0 To 4
		LCAR_HideElement(BG, KBCancelID+ temp, False, False ,False)
	Next
	InitCharsize(BG)
End Sub

Sub KeyboardHeight As Int
	Dim BarHeight As Int = 88, BarWidth As Int ,Corner As Int = LCARCornerElbow2.Height
	If CrazyRez>0 Then
		BarWidth = (100*CrazyRez) + 30 
		If BarWidth >100 Or ItemHeight>100 Then Corner=(Min(ItemHeight,BarWidth) *0.5)
		BarHeight = ItemHeight + Corner + ListitemWhiteSpace
	End If
	If HasHardwareKeyboard Then
		Return BarHeight
	Else
		Return ( 3*(ItemHeight+ListitemWhiteSpace))+BarHeight + ItemHeight*0.5
	End If
End Sub
Sub ShowKeyboard(BG As Canvas, AnimationStage As Int ) As Int 
	Dim Height As Int,Yoff As Int ,Y As Int ,KBHeight As Int, temp As Int ,temp2 As Int ,Unit As Int, Element As LCARelement ,BarWidth As Int,X As Int, UseKB As Boolean ,Corner As Int = LCARCornerElbow2.Height, BarHeight As Int 
	If SmallScreen Then
		BarWidth=70
		X=55
	Else
		X=100*GetScalemode' 105
		BarWidth=X + 30
		If BarWidth >100 Or ItemHeight>100 Then Corner=(Min(ItemHeight,BarWidth) *0.5)
		X=X+Corner
	End If
	BarHeight = ItemHeight + Corner
	
	'If AnimationStage>0 Then y=scaleheight
	'forceshow(18,False)'HARDCODED-BAD
	ClickedOK=False
	HideSideBar(BG,-1,0)
	UseKB = Not(HasHardwareKeyboard) Or BypassHardwareKB
	If Not(UseKB) Then ToastMessage(BG, API.getstring("kb_disabled"), 3)
	ToggleMultiLine(False)
	InitCharsize(BG)
	LCARSeffects.QuestionAsked=False
	
	If UseKB Then 
		Height= ListItemsHeight(3)' 3*(itemheight+listitemwhitespace)
		KBShift=False
		KBCaps=True
		SeedKeyboard
	End If
	
	KBHeight=Height+BarHeight
	Y=ScaleHeight-KBHeight
	If AnimationStage>0 Then
		Stage=AnimationStage
		If UseKB Then ResizeList(KBListID, ScaleWidth, Height,  -1,0, ScaleHeight ,True)
	End If
	If UseKB Then 
		LCAR_HideElement(BG, KBListID, True, True  ,False)
		ResizeList(KBListID, ScaleWidth,  Height,  -1,0, Y,True)
		RandomizeColors(KBListID)
	End If
	
	HideGroup(KBGroup, True, False)
	
	temp=ScaleWidth-BarWidth
	temp2=ScaleWidth-268
	'temp=width-130+1
	Unit=(temp2-8)/4

	ForceElementData(KBCancelID,   0, Y +Height,0,KBHeight,         BarWidth,BarHeight,0,0,0 ,255,True,AnimationStage>0)						'KBCancel
	ForceElementData(KBCancelID+4, -BarWidth, Y +Height,0,KBHeight, BarWidth,BarHeight,0,0,0 ,255,True,AnimationStage>0)						'KBOK
	
	temp2=Y+Height+BarHeight-ItemHeight
	If SmallScreen Then
		Unit= ( (ScaleWidth- (BarWidth*2) ) / 3) - 2
		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1	
	Else
		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1
	End If
	ForceElementData(KBCancelID+1, BarWidth+4, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)								'KBBackspace
	ForceElementData(KBCancelID+3, -BarWidth-4-Unit, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)						'KBDelete
	
	ForceElementData(KBCancelID+5, X, 0, 0,0,  -1, 40,0,0,0 ,255,True,AnimationStage>0)															'KBText
	
	'MoveLCAR(KBCancelID+5,105, 0,  scalewidth-105,40, 255,True, True,True)
	
	'LCAR_HideElement(BG,KBCancelID+5,False,True ,false)
	
	Element= LCARelements.Get(KBCancelID)
	Element.RWidth=ItemHeight
	Element= LCARelements.Get(KBCancelID+4)
	Element.RWidth=ItemHeight
	
	'Element= lcarelements.Get(17)
	'If element.Visible Then ForceElementData(17, Element.LOC.currX , Element.LOC.currY ,0,0, Element.Size.currX, Element.Size.currY -kbHeight-4,0, kbHeight, 255,255, True,True)
	WebviewOffset=-KBHeight-16
	PushEvent(LCAR_Keyboard, 1 ,-KBHeight-4,0,0,0,0,0)
	KBisVisible =True
	'KeyboardHeight = KBHeight
	Return KBHeight
End Sub

Sub RemoveAnimation(ID As Int, IsList As Boolean )
	Dim Lists As LCARlist, Element As LCARelement, LOC As tween, Size As tween 
	If IsList Then
		Lists = LCARlists.Get(ID)
		LOC=Lists.LOC
		Size= Lists.Size
	Else
		Element = LCARelements.Get(ID)
		LOC = Element.LOC
		Size=Element.Size 
	End If
	LOC.offX=0
	LOC.offY=0
	Size.offX=0
	Size.offY=0
	If IsList Then
		Lists.LOC=LOC
		Lists.Size=Size
	Else
		Element.LOC=LOC
		Element.Size=Size
	End If
End Sub

Sub SwapMode(ElementID As Int , TheStage As Int, DoSound As Boolean) As Int
	Dim Element As LCARelement ,Color As Int
	If ElementID<0 Then 
		Element = WallpaperService.LCARelements.Get(Abs(ElementID)-1)
	Else
		Element = LCARelements.Get(ElementID)
	End If
	If DoSound Then Stop("SWAP MODE")
	If TheStage=0 Then
		Element.ColorID= Classic_Green 
	Else If TheStage = 999 Then
		Element.ColorID= -1
	Else
		RedAlert=False
		Select Case TheStage
			Case -1:Element.ColorID=Classic_Green'switch to condition green
			Case -2:Element.ColorID=LCAR_Yellow'switch to yellow alert
			Case -3:Element.ColorID=LCAR_Red 'switch to red alert
			Case -4'switch to blue alert
				Element.ColorID=Classic_Blue
				If DoSound Then PlaySound(13,True)
			Case Else
				Select Case Element.ColorID
					Case Classic_Green: Element.ColorID=LCAR_Yellow
					Case LCAR_Yellow 
						Element.ColorID=LCAR_Red 
						If DoSound Then PlaySound(13,True)
					Case LCAR_Red, Classic_Blue: Element.ColorID=Classic_Green
				End Select
		End Select
	End If
End Sub

Sub SetGraphStyle(ElementID As Int, Style As Int, Cols As Int, Rows As Int)
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.Align= Style
	If Cols>-1 Then Element.LWidth= Cols
	If Rows>-1 Then Element.rWidth= Rows
	Element.IsClean=False
End Sub
Sub SetGraphID(ElementID As Int, GraphID As Int)
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.TextAlign=GraphID
	Element.IsClean=False
End Sub

'abandoned
Sub DrawCircle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Corner As Int, Color As Int)
	Dim P As Path 
	ActivateAA(BG,True)
	If Corner = 5 Then
		BG.DrawOval(SetRect(X,Y,Width,Height), Color, True, 0)
	Else
		P.Initialize(X,Y)
		P.LineTo(X+Width-1,Y)
		P.LineTo(X+Width-1,Y+Height-1)
		P.LineTo(X,Y+Height-1)
		BG.ClipPath(P)
		If Corner<0 Then
			DrawRect(BG,X,Y,Width,Height,Color,0)
			Corner=Abs(Corner)
			Color=Colors.Black
		End If

		Select Case Corner
			Case 1'top left
				BG.DrawOval(SetRect(X,Y,Width*2,Height*2), Color, True, 0)				'top left
				
			Case 2'top middle
			Case 3'top right
				BG.DrawOval(SetRect(X-Width,Y,Width*2,Height*2), Color, True, 0)
			
			Case 4'middle left
				BG.DrawOval(SetRect(X-Width,Y,Width*2,Height), Color, True, 0)

			Case 6'middle right
				BG.DrawOval(SetRect(X,Y,Width*2,Height), Color, True, 0)
			
			Case 7'bottom left
				BG.DrawOval(SetRect(X,Y-Height,Width*2,Height*2), Color, True, 0)	
				
			Case 8'bottom middle
			Case 9'bottom right
				BG.DrawOval(SetRect(X-Width,Y-Height,Width*2,Height*2), Color, True, 0)
		End Select
		BG.RemoveClip
	End If
	'IsAAon =False
End Sub


'TOP: 1=left, 2=middle, 3=right	MIDDLE: 4=left, 5=middle, 6=right BOTTOM: 7=left, 8=middle, 9=right, use negatives for inside curve
Sub DrawCircle2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Corner As Int, Color As Int, ClearFirst As Boolean )
	Dim PT As Point 
	If Corner = 5 Then
		BG.DrawOval(SetRect(X,Y,Width,Height), Color, True, 0)
	Else
		LCARSeffects.MakeClipPath(BG,X,Y,Width+1,Height+1)
		If ClearFirst Then DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
		ActivateAA(BG,True)
		If Corner<0 Then'inside corner
			DrawRect(BG,X,Y,Width+2,Height+2, Color,0)
			Select Case Corner
				Case -1: PT=Trig.SetPoint(X+Width,Y+Height)'top left
				Case -3: PT=Trig.SetPoint(X+2,Y+Height)'top right
				Case -7: PT=Trig.SetPoint(X+Width, Y+1)'bottom left
				Case -9: PT=Trig.SetPoint(X+2, Y+1)'bottom right
				Case Else:Return
			End Select
			BG.DrawCircle(PT.X,PT.Y,Width,Colors.black,True,0)
		Else
			Select Case Corner
				Case 1:	BG.DrawOval(SetRect(X,Y,Width*2,Height*2), Color, True, 0)				'top left
				Case 2:	BG.DrawOval(SetRect(X,Y,Width,Height*2), Color, True, 0)				'top middle
				Case 3:	BG.DrawOval(SetRect(X-Width,Y,Width*2,Height*2), Color, True, 0)		'top right
				Case 4:	BG.DrawOval(SetRect(X-Width,Y,Width*2,Height), Color, True, 0)			'middle left
				Case 6:	BG.DrawOval(SetRect(X,Y,Width*2,Height), Color, True, 0)				'middle right
				Case 7:	BG.DrawOval(SetRect(X,Y-Height,Width*2,Height*2), Color, True, 0)		'bottom left
				Case 8:	BG.DrawOval(SetRect(X,Y-Height,Width,Height*2), Color, True, 0)			'bottom middle
				Case 9:	BG.DrawOval(SetRect(X-Width,Y-Height,Width*2,Height*2), Color, True, 0)	'bottom right
			End Select
		End If
		BG.RemoveClip
		If Corner = -3 Or Corner = -9 Then BG.DrawLine(X+Width+1, Y, X+Width+1,Y+Height+1, Color, 1)
		If Corner = -7 Or Corner = -9 Then BG.DrawLine(X, Y+Height+1, X+Width+1, Y+Height+1, Color, 1)
	End If
End Sub


Sub ResetLCARAnswer(ElementID As Int, Direction As Int)As Int 
	Dim Element As LCARelement
	Element= LCARelements.Get(ElementID)
	Select Case Direction
		Case -1
			Element.LWidth= -1
			Element.RWidth= 0 
			Element.RespondToAll=True
			ForceShow(ElementID,True)
		
		Case -2'green/true/left to right
			Element.LWidth=1
			Element.RWidth=0

		Case -3'red/false/right to left
			Element.LWidth=0
			Element.RWidth=100
		
		Case -4'return direction
			Return Element.LWidth
		Case -5'return value
			Return Element.RWidth
		
		Case Else'value
			Element.RWidth=Direction'
			'If Element.LWidth = 1 Then'green/true/left to right
			'Else'red/false/right to left
			'End If
	End Select
End Sub

Sub DrawAnswerSlider(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Direction As Int, Value As Int, Alpha As Int, LeftText As String, LeftColorID As Int, RightText As String, RightColorID As Int)
	Dim ColorID As Int, Wid As Double, temp As Int,temp2 As Int ,X2 As Double,Alpha2 As Int, Stages As Int=10
	Select Case Direction
		Case 0,-2'false/red/right and larson red
			ColorID = RightColorID'LCAR_Red
		Case 1,-1'true/green/left and larson green
			ColorID = LeftColorID'Classic_Green
	End Select
	'Log(Direction & "  " & Value)
	'ColorHalf= GetColor(ColorID, False,Alpha*0.5)
	'ColorID = GetColor(ColorID, False,Alpha)
	
	Wid=(Width - MinWidth*2 - 2) / Stages
	X2=X+MinWidth
	
	DrawLCARbutton(BG,X,Y,MinWidth, ItemHeight, LeftColorID, False, LeftText, "", leftside, 0, False,  -1, 5,-1,255,False)
	
	For temp = 0 To Stages-1
		temp2=temp*Stages
		If Direction<0 Then
			Alpha2= API.IIF(API.IsBetween(temp2,temp2+Stages-1,Value),255, 128)
		Else If Direction = 1 Then'green left-to-right
			temp2=temp2+Stages-1
			Alpha2 = API.IIF(Value>temp2,255,128)
		Else'red right-to-left
			Alpha2 = API.IIF(temp2>=Value,255,128)
		End If
		DrawLCARslantedbutton(BG, X2+2,Y,Wid-2,ItemHeight-1,ColorID, Alpha2, False, "", -1,0)
		X2=X2+Wid
	Next
	
	DrawLCARbutton(BG,X+Width-MinWidth,Y,MinWidth, ItemHeight, RightColorID, False, RightText, "", 0, leftside, True,-1, 5,-1,255,False)
End Sub

Sub EmergencyBG As Canvas 
	Dim BMP As Bitmap ,BG As Canvas 
	BMP.InitializeMutable(1,1)
	BG.Initialize2(BMP)
	Return BG
End Sub



Sub DrawSurface(DestBG As Canvas, ID As Int, X As Int, Y As Int, Width As Int, Height As Int)
	Dim BMP As Bitmap ,BG As Canvas ,OldSW As Int=ScaleWidth, OldSH As Int = ScaleHeight
	BMP.InitializeMutable(Width,Height)
	BG.Initialize2(BMP)
	ScaleWidth=Width
	ScaleHeight=Height
	IsClean=False
	DrawLCARs(BG,ID)	
	DestBG.DrawBitmap(BMP, Null, SetRect(X,Y,Width,Height))
	ScaleWidth=OldSW
	ScaleHeight=OldSH
End Sub




















Sub BigTextboxHeight As Int
	Return 32
End Sub
Sub InitCharsize(BG As Canvas)
	If Not(CharSize.IsInitialized) Then CharSize = Trig.SetPoint(API.TextWidthAtHeight(BG,LCARfont, "A", BigTextboxHeight),API.TextHeightAtHeight(BG,LCARfont, "ABCjgq", BigTextboxHeight))
End Sub
Sub HandleTextboxMouse(ElementIndex As Int, ElementType As Int, EventType As Int, X As Int , Y As Int)
	Dim Element As LCARelement,Lines As Int ,Size As tween 
	If ElementIndex = KBCancelID+5 Then
		If ElementType = LCAR_MultiLine Then 
			Element = LCARelements.Get(KBCancelID+5)
			Size = ProcessLoc(Element.LOC, Element.Size)
		End If
		Select Case EventType
			Case Event_Down
				TextPos=Trig.SetPoint(0,0)
				
			Case Event_Move 
				TextPos.X=TextPos.X+X
				TextPos.Y=TextPos.Y+Y
				
				If TextPos.X<-CharSize.X Then
					HandleKeyboard(KeyCodes.KEYCODE_DPAD_LEFT)
					TextPos.X=TextPos.X+CharSize.X
				Else If TextPos.X > CharSize.X Then
					HandleKeyboard(KeyCodes.KEYCODE_DPAD_RIGHT)
					TextPos.X=TextPos.X-CharSize.X
				End If
				
				If ElementType = LCAR_MultiLine Then
					If TextPos.Y<-CharSize.Y Then
						Lines=1
						TextPos.Y=TextPos.Y+CharSize.Y
					Else If TextPos.Y> CharSize.Y Then
						Lines=-1
						TextPos.Y=TextPos.Y-CharSize.Y
					End If
					If Lines<>0 Then Element.TextAlign=MoveLinestart(LCARfont,BigTextboxHeight, Element.Text, Size.offX, Size.offY, Element.TextAlign, True,Lines)
				End If
		End Select
	End If
End Sub
Sub MoveLinestart(Font As Typeface, TextSize As Int, Text As String, Width As Int, Height As Int,LineStart As Int, ByLines As Boolean, Quantity As Int) As Int
	Dim temp As Int,BG As Canvas 
	If Not(LCARSeffects2.CenterPlatform.IsInitialized) Then LCARSeffects2.CenterPlatform.InitializeMutable(1,1)
	BG.Initialize2(LCARSeffects2.CenterPlatform)
	InitCharsize(BG)
	If Not(ByLines) Then Quantity=Quantity* Height/CharSize.Y 
	For temp = 1 To Quantity
		If Quantity>0 Then
			Log("BEFORE: " & LineStart & " width=" & Width)
			LineStart= DrawLineOfText(BG,Font,TextSize, Text,0,0, Width,Colors.Transparent, Colors.Transparent,Colors.Transparent,Colors.Transparent,Colors.Transparent,LineStart,  0,0,False).x+1
			'DrawMultiLineTextbox(BG,Font,TextSize,Text,0,0, Width,Height, Colors.Transparent, Colors.Transparent,Colors.Transparent,Colors.Transparent,Colors.Transparent, LineStart,0,0,False).X 
			Log("After: " & LineStart)
		Else
			LineStart= GoBack1Line(BG,Font,TextSize,Text,LineStart, Width)
		End If
	Next
	Return Min(LineStart, Text.Length)
End Sub

Sub IsMultilineEnabled As Boolean 
	Return GetElement(KBCancelID+5).ElementType = LCAR_MultiLine
End Sub
Sub ToggleMultiLine(Enabled As Boolean )
	Dim Element As LCARelement 
	If KBCancelID>0 Then
		Element= LCARelements.Get(KBCancelID+5)
		Element.ElementType = API.IIF(Enabled, LCAR_MultiLine, LCAR_Textbox)
		Element.LOC.currX = GetScaledPosition(0,True)' API.IIF(SmallScreen ,55, 105)
		Element.LOC.currY =0
		If Enabled Then
			Element.Size.currY = API.IIF(SmallScreen ,72, 145)
			Element.TextAlign=0
		Else
			Element.Size.currY =BigTextboxHeight
			Element.TextAlign=1
		End If
	End If
End Sub

Sub DrawLCARMultiLineTextbox(BG As Canvas, X As Int, Y As Int, Width As Int,Height As Int, SelStart As Int, SelWidth As Int, Text As String, ColorID As Int, State As Boolean, Blink As Boolean,Alpha As Int ,LineStart As Int )As Int
	Dim SelTextColorID As Int,CursorColorID As Int,HighliteColorID As Int 'cursor and text are the same color
	'DrawLCARtextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Text, Element.ColorID, Element.ColorID,   LCAR_LightBlue,State, BlinkState, Element.TextAlign,Element.Opacity.Current )
	If RedAlert Then
		HighliteColorID = RedAlertMode'LCAR_RedAlert'highlight color		LCAR_LightBlue
		CursorColorID= LCAR_White'caret color
		ColorID= RedAlertMode' LCAR_RedAlert'text color
		If Not(Blink) Then SelTextColorID=LCAR_White'highlighted text color
	Else 
		HighliteColorID = LCAR_LightBlue
		CursorColorID=ColorID
		SelTextColorID=LCAR_Black
	End If
	Return DrawMultiLineTextbox(BG, LCARfont, BigTextboxHeight, Text, X,Y,Width, Height, Colors.Black, GetColor(ColorID, False, Alpha), GetColor(SelTextColorID, False, Alpha), GetColor(HighliteColorID, False, Alpha),  GetColor(CursorColorID, False, Alpha),  LineStart, SelStart,SelWidth, Blink).X
End Sub

Sub DrawMultiLineTextbox(BG As Canvas,Font As Typeface, TextSize As Int, Text As String, X As Int, Y As Int,  Width As Int, Height As Int, BGColor As Int, TextColor As Int,SelTextColor As Int, HighlightColor As Int, CaretColor As Int, LineStart As Int, SelStart As Int, SelLength As Int, ShowCaret As Boolean) As Point
	Dim temppoint As Point ,Bottom As Int ,LineHeight As Int,Line As Int
	DrawRect(BG,X,Y,Width+1,Height+1, BGColor, 0)
	'Log("Line: " & Line)
	
	temppoint = DrawLineOfText(BG,Font,TextSize,Text,X,Y,Width,Colors.Transparent,TextColor, SelTextColor, HighlightColor, CaretColor, LineStart, SelStart, SelLength, ShowCaret) 
	Bottom=Y+Height
	LineHeight=temppoint.Y + 1
	Y=Y+ LineHeight
	Do Until LineStart >= Text.Length -1 Or Y +LineHeight >= Bottom
		Line=Line+1
		LineStart=LineStart+ temppoint.X+1
		If LineStart< Text.Length -1 Then
			If Y< Bottom Then 
				'Log("Line: " & Line)
				temppoint= DrawLineOfText(BG,Font,TextSize,Text,X,Y,Width,Colors.Transparent,TextColor,SelTextColor, HighlightColor, CaretColor, LineStart, SelStart, SelLength, ShowCaret) 
			End If
		End If
		Y=Y+ LineHeight
	Loop
	Return temppoint
End Sub

Sub GoBack1Line(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, LineStart As Int, Width As Int) As Int
	Dim tempstr() As String, CRLFloc As Int,WidthofSpace As Int ,Text2 As String ,temp As Int, WidthofWord As Int ,WidthofLine As Int,LengthOfLine As Int  ', tempstr2 As StringBuilder
	InitCharsize(BG)
	CRLFloc = Text.LastIndexOf2(CRLF, LineStart-1)
	Text=API.Left(Text,LineStart)
	If CRLFloc=-1 Then CRLFloc=0
	Text2=API.Mid(Text, CRLFloc, LineStart-CRLFloc)
	If API.TextWidthAtHeight(BG,Font,Text2,TextSize) <= Width Then
		Return CRLFloc
	Else
		'tempstr2.Initialize
		tempstr = Regex.Split(" ", Text2)
		WidthofSpace=API.TextWidthAtHeight(BG,Font, " ", TextSize)
		For temp = tempstr.Length-1 To 0 Step -1
			WidthofWord=API.TextWidthAtHeight(BG,Font, tempstr(temp), TextSize)
			If WidthofLine + WidthofWord > Width Then 
				If WidthofLine = 0 Then LengthOfLine= tempstr(temp).Length - FindEndOfWord(BG, Font,TextSize,tempstr(temp),Width)
				temp=0
			Else
				LengthOfLine=LengthOfLine+tempstr(temp).Length+1
				'tempstr2.Insert(0, tempstr(temp) & " ")
				WidthofLine=WidthofLine + WidthofWord + WidthofSpace
			End If
		Next
		Return Max(0, LineStart-LengthOfLine)
	End If
End Sub
Sub FindEndOfWord(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, Width As Int) As Int
	Dim LineStart As Int ,Ret As Int 
	Do Until LineStart >= Text.Length -1
		LineStart = DrawLineOfText(BG,Font,TextSize,Text,0,0,Width,Colors.Transparent,Colors.Transparent, Colors.Transparent, Colors.Transparent, Colors.Transparent, LineStart, 0, 0, False).X 
		If LineStart< Text.Length -1 Then Ret = LineStart
	Loop
	Return Ret
End Sub

Sub DrawLineOfText(BG As Canvas,Font As Typeface, TextSize As Int, Text As String, X As Int, Y As Int,  Width As Int, BGColor As Int, TextColor As Int,SelTextColor As Int, HighlightColor As Int, CaretColor As Int, LineStart As Int, SelStart As Int, SelLength As Int, ShowCaret As Boolean) As Point
	Dim tempstr() As String, CRLFloc As Int, tempstr2 As StringBuilder, WidthofSpace As Int ,temp As Int, WidthofWord As Int ,WidthofLine As Int ,tempstr3 As String , LineHeight As Int,LengthOfLine As Int
	Dim SelText As String, StartChar As Int ,EndChar As Int
	InitCharsize(BG)
	CRLFloc= Text.IndexOf2(CRLF, LineStart)-1
	If CRLFloc <0 Then CRLFloc = Text.Length-LineStart 
	Text = API.Mid(Text, LineStart, CRLFloc )
	tempstr2.Initialize
	If API.TextWidthAtHeight(BG,Font,Text,TextSize) <= Width Then
		tempstr2.Append(Text)
		LengthOfLine = Text.Length -1
	Else
		tempstr = Regex.Split(" ", Text)
		WidthofSpace=API.TextWidthAtHeight(BG,Font, " ", TextSize)
		For temp = 0 To tempstr.Length-1
			WidthofWord=API.TextWidthAtHeight(BG,Font, tempstr(temp), TextSize)
			'Log(tempstr(temp) & " is " & WidthofWord & " px, max " & WidthofLine & "/" & Width)
			If WidthofLine + WidthofWord > Width Then 
				If WidthofLine = 0 Then
					tempstr3=API.LimitTextWidth(BG, tempstr(temp), Font,TextSize, Width, "-")
					LengthOfLine=tempstr3.Length -2
					tempstr2.Append(tempstr3)
				End If
				temp=tempstr.Length
			Else
				tempstr2.Append(tempstr(temp) & " ")
				WidthofLine=WidthofLine + WidthofWord + WidthofSpace
			End If
		Next
		If LengthOfLine = 0 Then LengthOfLine = tempstr2.Length -1
	End If
	
	'Log("BEFORE: " & Text)
	Text= tempstr2.ToString
	
	If TextColor <> Colors.Transparent Then
		'If Text=0 Then
		'	LineHeight = API.TextHeightAtHeight(BG,Font, "ABC", TextSize)+1
		'Else
		'	LineHeight = API.TextHeightAtHeight(BG,Font, Text, TextSize)+1
		'End If
		LineHeight=CharSize.Y
		If BGColor <> Colors.Transparent Then DrawRect(BG,X,Y,Width, LineHeight, BGColor, 0)
		BG.DrawText(Text,X,Y+LineHeight, Font, TextSize, TextColor, "LEFT")
		SelStart= SelStart- LineStart
		If HighlightColor <> Colors.Transparent And SelLength <> 0 Then
			If SelStart < 0 And SelLength > -SelStart Then' selstart is before linestart, and sellength is larger than the difference between the 2
				ShowCaret=False
				SelLength = SelLength - (0- SelStart)
				SelStart=0
				'Log("PHASE1")
			Else If SelStart > LengthOfLine And SelLength<0 And Abs(SelLength)> SelStart-LengthOfLine  Then' selstart is after linestart, and sellength is below zero and abs(greater than the difference between selstart and linelength)
				ShowCaret=False
				SelLength= SelLength + (SelStart-LengthOfLine) - 1
				SelStart=LengthOfLine+1
				'Log("PHASE2")
			Else If SelStart >=0 And SelStart <= 0+LengthOfLine+1 Then 'selstart is in between linestart and linestart+lengthofline
				If SelLength<0 Then
					If Abs(SelLength) > SelStart Then SelLength= -SelStart
					'Log("PHASE3")
				Else
					SelLength = Min(SelLength, LengthOfLine-SelStart+1)
					'Log("PHASE4")
				End If
			Else
				'Log("PHASE5")
				SelLength=0
			End If
			If SelLength <> 0 Then
				StartChar = API.IIF(SelLength<0, SelStart+SelLength, SelStart)
				EndChar = StartChar+ Abs(SelLength)
				StartChar=Max(0,StartChar)
				EndChar=Min(EndChar,LengthOfLine+1)
				
				temp = BG.MeasureStringWidth(Text.SubString2(0, StartChar)  ,Font, TextSize)
				SelText=Text.SubString2(StartChar, EndChar)
				'Log(SelStart & " " & SelLength & " " & SelText)
				WidthofWord=BG.MeasureStringWidth(SelText,Font, TextSize)
				BG.DrawRect( SetRect(X+temp-1,Y+2,WidthofWord+2, LineHeight-1),  HighlightColor ,True,0)
				BG.DrawText(SelText,X+temp,Y+LineHeight, Font, TextSize, SelTextColor, "LEFT")
			End If
		End If
		If CaretColor <> Colors.Transparent And ShowCaret Then
			'Log(SelStart)
			'If SelStart=0 Then
			'	BG.DrawRect( SetRect(X,Y+1,3, LineHeight+1), CaretColor,True,0)
			If SelStart <= LengthOfLine+1 And SelStart>-1 Then	
				'If SelLength =0 Then
					temp = SelStart
				'Else
				'	temp = API.IIF(SelLength<0, StartChar,EndChar)
				'End If
				temp = BG.MeasureStringWidth(API.left(Text, temp)  ,Font, TextSize)
				BG.DrawRect( SetRect(X+temp-1,Y+1,3, LineHeight), CaretColor,True,0)
			End If
		End If
	End If
	Return Trig.SetPoint(LengthOfLine, LineHeight)
End Sub

Sub ScaleFactor As Float
	Return Max(1, GetScalemode)
End Sub
Sub GetScalemode As Float
	If SmallScreen Then Return 0.5
	If CrazyRez = 0 Then Return 1
	Return CrazyRez 
End Sub
'Position:
'[] (0) top right corner
'[|_ _ ___1____ _
'  _ _ ___2____ _
'[|
'__ (3) bottom of the screen
'||
'(4) below the frame elbow
'||
'--
'(5) below the sidebar
Sub GetScaledPosition(Position As Int, isX As Boolean) As Int
	Dim Top As Int = 145, Bottom As Int = 165, Width As Int = 100, Factor As Float = 1, X As Int, Y As Int 
	If SmallScreen Then
		Top = 72
		Bottom = 85
		Width=50
		Factor=0.5
	Else If CrazyRez>0 Then 
		Factor=CrazyRez
		Width=Width*Factor
		Bottom = Bottom*Factor - (ListitemWhiteSpace*2)
		Top=Bottom - ((17*Factor)+ListitemWhiteSpace)
	End If
	Select Case Position
		Case 0'top right corner
			X=Width+ListitemWhiteSpace + LCARCornerElbow2.Width 
			Y=Top-LCARCornerElbow2.Height
		Case 1,2'along top/bottom of the frame divider
			X=(100*Factor) * 1.33 + ListitemWhiteSpace'' (71*Factor) +
			Y=Top
			If Position = 2 Then Y = Y  + (17*Factor) + ListitemWhiteSpace
		Case 3'bottom of the screen
			X=Width+ListitemWhiteSpace + LCARCornerElbow2.Width 
			Y=Bottom + (17*Factor) + LCARCornerElbow2.Height
		Case 4, 5'below the frame elbow
			Y=Bottom+ (88*Factor) + ListitemWhiteSpace 
			If Position = 5 Then Y=Y+ ListItemsHeight( GetList(LCAR_Sidebar).ListItems.Size )
			If Position = 4 And CrazyRez = 1 Then y = y + ListitemWhiteSpace * 2 
	End Select
	If isX Then Return X Else Return Y
End Sub