B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region Module Attributes
	#StartAtBoot: False
#End Region

'Service module			WIDTH refers to width of wallpaper, widthofscreen refers to the resolution of the actual display/screen/LCD
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim lwm As LWManager,IsVisible As Boolean ',  ExDraw As ABExtDrawing
	Dim TempCurrentOffsetX As Int ,LastUpdate As Long,Delay As Int ,AllowPreview As Boolean, IsClean As Boolean 
	Dim msdWidth As Int, msdHeight As Int,msdY As Int, FramesPerSecond As Int ,OldPoint As Point ,AllowScrolling As Boolean ,OldY As Int, PreviewMode As Boolean  ,DoIncrement As Boolean ,isInPmode As Boolean 
	Dim SettingsLoaded As Boolean ,CurrentSection As Int=-1, CurrentMSD As String, Settings As Map ,CurrentMode As String ,LastSec As Int, BigText As Int 
	Dim SamsungMode As Int ,SamsungCursorCount As Int, SamsungX As Int,SamsungY As Int ,SamsungX2 As Int,DDisrunning As Boolean ,SamsungTolerance As Int=100
	'Type Cursor(Loc As Point, Element As Int, State As Int )
	
	'Dim DebugString As StringBuilder, DebugPoints As Int, DebugDone As Boolean ,OldX As Int:OldX=-99999
	
	Dim LCARelements As List, PhysicalWidth As Int ,PhysicalHeight As Int, VirtualWidth As Int ,X2 As Int ,TOP As Int, BOTTOM As Int ,DoScale As Boolean, SSM As Boolean ,LastX As Int
	Dim MSDList As List,LCARGroups As List,GroupsEnabled As Boolean, NeedsRefresh As Boolean ,RefreshesLive As Boolean,CursorID As Int, CursorCount As Int'Cursors As List , 'Not Downloaded yet
	Dim Landscape As Boolean 
	
	Dim MediaControls As Boolean =True,WasFromMainmenu As Boolean ,OmegaUnlock As String ,UseXinstead As Int, UseWidthinstead As Int ,NeedsReset As Boolean ,Darken As Int , TimeOut As Int' ,MouseState As Boolean
	
	Dim ENTdata As List, ENTmode As Boolean, ENTbuttons As Int = 2, PCARframeID As Int = -1, LastColor As Int = -1, BridgePanels As Int = 5, AllowAlpha As Boolean, RNDindex As Int, SubScreenIndex As Int = -1
End Sub

Sub Refresh
	lwm.StopTicking 
	lwm.StartTicking(1)
	NeedsReset=True
	NeedsRefresh=True
	'Log("FORCED REFRESH NEEDED!")
End Sub

Sub ClearLCARS
	LCARelements.Initialize 
	LCARGroups.Initialize 
	'Cursors.Initialize 
	ENTdata.Initialize 
	CursorID=-1
	ENTmode=False
	RNDindex=0
	PCARframeID=-1
	LastX=0
	AllowAlpha=False
	LCARSeffects2.ClearRandomNumbers
	'MouseState = False
End Sub

Sub AddMiniButton(Qty As Int) As Int ', LastColor As Int ) As Int
	Dim temp2 As Int' , LastColor As Int = -1
	ENTmode=True
	For temp2 = 1 To Qty 
		Dim temp As MiniButton '(Text As String, ColorID As Int)
		temp.initialize 
		temp.ColorID = LastColor
		Do Until temp.ColorID <> LastColor
			temp.ColorID = LCARSeffects3.ENTcolor(-1)
		Loop
		temp.Text = API.PadtoLength(Rnd(0,1000), True, 3, "0")
		ENTdata.Add(temp)
		LastColor = temp.ColorID
	Next
	Return LastColor
End Sub
Sub IsPCARSframe(ElementType As Int) As Boolean 
	Select Case ElementType 
		Case LCAR.ENT_Radar, LCAR.ENT_Meter, LCAR.ENT_Sin, LCAR.PCAR_Frame, LCAR.ENT_RndNumbers:	Return True
	End Select
End Sub
Sub AddLCAR2(Data As LCARelement) As Int 
	If IsPCARSframe(Data.ElementType) Then LastColor = AddMiniButton(ENTbuttons)', LastColor)
	Return AddLCAR(Data.Name, -999, Data.LOC.currX, Data.LOC.currY, Data.Size.currX, Data.Size.currY, Data.LWidth, Data.RWidth, Data.ColorID, Data.ElementType, Data.Text,Data.sidetext,Data.tag, Data.Group,True,Data.textalign, Data.enabled, Data.Align,255)
End Sub
Sub AddLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String,Group As Int,  Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int ) As Int
	Dim Temp As LCARelement 
	If Not(GroupsEnabled) Then Group=0
	If API.Left(Text,1)="!" Then Text = LCARSeffects3.RandomENT(API.Right(Text, Text.Length-1))
	LastX= Max(LastX, X+Width)'X coordinate of the right side of the right-most element
	If Not(AllowAlpha) Then Alpha = 255
	Temp=LCAR.MakeLCAR(Name,-999,X,Y,Width,Height,LWidth,RWidth,ColorID,ElementType,Text,SideText,Tag,Group,True,TextAlign,Enabled,Align,Alpha)
	If SurfaceID = 1 Then Temp.RespondToAll = True
	LCARelements.Add(Temp )	
	AddLCARtoGroup(LCARelements.Size-1, Group)
	Return LCARelements.Size-1
End Sub
Sub AddRND(Dest As Rect, Title As String)
	Dim X As Int = Dest.Left, Y As Int = Dest.Top, Width As Int = Dest.Right-Dest.Left, Height As Int = Dest.Bottom-Dest.Top
	If Dest.Right < Dest.Left Then Width = -1
	If Dest.Bottom< Dest.Top Then Height = -1
	AddLCAR("RNDnum", 0, X,Y, Width, Height,RNDindex,0, LCAR.LCAR_Orange , LCAR.LCAR_RndNumbers, Title,  "", "",   -1,   False,0 ,   True ,0,0)
	RNDindex=RNDindex+1
End Sub

Sub Service_Create
	'LCAR.SetupTheVariables 
	'LCAR.Setupcolors
	API.AutoLoad
	lwm.Initialize("LWM", True)
	
	'LCAR.LoadLCARSize(Null)
End Sub
Sub Service_Start (StartingIntent As Intent)
	API.StartPhoneEvents
End Sub
Sub Service_Destroy
	lwm.StopTicking 
End Sub







Sub PreviewLWP(BG As Canvas)
	'Dim Increment As Boolean 
	If AllowPreview Then
		If DreamService.DDisrunning  Then
			PhysicalWidth = 	DreamService.DD.Panel.Width
			PhysicalHeight = 	DreamService.DD.Panel.Height
		Else  
			PhysicalWidth = 	LCAR.Scalewidth
			PhysicalHeight= 	LCAR.ScaleHeight
		End If
		'VirtualWidth=PhysicalHeight*2 'Engine.FullWallpaperWidth
		NeedsRefresh=False
		If Not(PreviewMode) Then SettingsLoaded=False
		PreviewMode = True
		LoadSettings(BG, VirtualWidth,PhysicalHeight, PhysicalWidth )
		'PreviewMode=False
		VirtualWidth=Max(msdWidth,PhysicalHeight*2)
		LCAR.ClearLocked=True
		'Log(DateTime.Now & " " & LastUpdate & " " & Delay)
		'If DateTime.Now  >= LastUpdate + Delay Then Increment=True
		SystemTick
		DrawScreen(BG, DoIncrement,  TempCurrentOffsetX, VirtualWidth, PhysicalHeight, PhysicalWidth )  
		If DoIncrement Then 
			LastUpdate = DateTime.Now 
			DoIncrement=False
		End If
	End If
End Sub
Sub TouchDownLWP(X As Int, Y As Int)
	OldPoint = Trig.SetPoint(X,Y)
	If TimeOut> 0 Then API.NewTimer("Shutoff", 5, TimeOut)
	HandleTouch(0,X,Y)
	OldY=Y
	AllowScrolling=True 
	If Main.CurrentSection = 78 And PreviewMode Then 
		API.NewTimer("NNNtime", 7, 10)
		ToggleBigText(True)
	End If
End Sub
Sub ToggleBigText(Visible As Boolean)
	Dim element As LCARelement = LCARelements.Get(BigText)
	element.Visible = True 
	element.Opacity.Desired= API.IIF(Visible,255,0)
End Sub
Sub TouchUpLWP(X As Int, Y As Int)
	HandleTouch(1,X,Y)
End Sub
Sub TouchMoveLWP(X As Int, Y As Int)
	Dim Tolerance As Int = 50
	If LCAR.CrazyRez>0 Then Tolerance = Tolerance * LCAR.CrazyRez
	IsClean=False
	OldPoint.X=OldPoint.X+X
	OldPoint.Y=OldPoint.Y+Y
	If Abs(OldY - OldPoint.Y) >Tolerance Then AllowScrolling = False
	HandleTouch(2,OldPoint.X,OldPoint.Y)
End Sub
Sub ScrollLWP(ElementID As Int, X As Int)
	'Log(AllowScrolling & ": " & X & " (" & TempCurrentOffsetX & ")")
	If AllowScrolling Then BypassScroll(ElementID,X)
		'TempCurrentOffsetX = API.Limit( TempCurrentOffsetX - X,   0, VirtualWidth-PhysicalWidth)
		'LCAR.DirtyElement(ElementID)
	'End If
	'Log(TempCurrentOffsetX)
End Sub
Sub BypassScroll(ElementID As Int, X As Int)
	IsClean=False
	TempCurrentOffsetX = API.Limit( TempCurrentOffsetX - X,   0, VirtualWidth-PhysicalWidth)
	LCAR.DirtyElement(ElementID)
End Sub

Sub LoadSettings(BG As Canvas, Width As Int, Height As Int, WidthofScreen As Int)
	Dim temp As Int, temp2 As Int, tempstr As String ,RedAlert As Boolean ,tempP As Point ' ,temp3 As Int
	If Not(SettingsLoaded) Then
		If Not(Settings.IsInitialized) Then Settings = API.LoadMap(File.DirInternal, "LWP.MAP")
		TempCurrentOffsetX=0
		AllowAlpha=False
		SettingsLoaded=True
		FramesPerSecond = Settings.Getdefault("FPS", 0)
		If Not(IsPaused(Main)) Then PreviewMode = True
		isInPmode=PreviewMode
		SamsungMode=0
		IsClean=False
		BridgePanels=Settings.GetDefault("PAN",5)
		If PreviewMode Then
			Log("Preview mode: " & AllowPreview)
			CurrentMode="PRV"	
			If (DreamService.DDisrunning Or DDisrunning) And Settings.Getdefault("DAY", -1) > -1 Then  CurrentMode="DAY"
			If CurrentMode = "PRV" And Not(AllowPreview) Then Return 
			CurrentSection = Settings.Getdefault(CurrentMode, -1)
			If CurrentSection = -1 Then CurrentSection = Settings.Getdefault("SCR", -1)
			TOP=0
			BOTTOM=0
		Else
			Log("Wallpaper mode")
			If Settings.ContainsKey("SAM") Then
				Settings.Put("FSM", API.IIF(Settings.Get("SAM"), 1,0))
				Settings.Remove("SAM")
			End If
			SamsungMode= Settings.Getdefault("FSM",  0)
			CurrentSection = Settings.Getdefault("SCR", -1)
			CurrentMode="SCR"
			TOP = Settings.Getdefault("TOP", 0)
			BOTTOM = Settings.Getdefault(API.IIF(Height>WidthofScreen, "BOT", "LND"), 0)	
		End If
		If CurrentSection > -1 Then 
			tempstr = API.LWPLIST.Get(CurrentSection)
			If tempstr.Contains(":") Then'has a subscreen
				temp = tempstr.LastIndexOf(":")
				SubScreenIndex = API.Right(tempstr, tempstr.Length - temp - 1)
				SubScreenIndex = SubScreenIndex - 1
				tempstr = API.RemoveBrackets(API.Left(tempstr,temp).ToUpperCase, 0).Trim
				CurrentSection = API.LWPLIST.IndexOf(tempstr)
			End If
		End If
		
		LCAR.HideToast
		DDisrunning = (CurrentMode = "DAY") Or (API.CheckLock And Not(IsPaused(Main))) Or DreamService.DDisrunning
		MediaControls = Settings.Getdefault("MED",  False)
		Darken=Settings.GetDefault("DRK", 0)
		Landscape = PhysicalWidth > PhysicalHeight
		'Log("Loaded: " & PreviewMode & " " & CurrentSection)
		DoScale = Settings.GetDefault("SCL", False)
		RedAlert=Settings.Getdefault("ALERT", 0) > 0
		Wireframe.SVGscreen = -1
		
		SSM = Settings.Getdefault("SSM", False)
		GroupsEnabled=False
		lwm.StopTicking 
		ClearLCARS
		SetMSDwidthSquare(WidthofScreen,Height)
		If SamsungMode>0 Then SetupConsole(BG,-1)
		
		RefreshesLive=True
		If (CurrentSection = 12 Or CurrentSection = 27) And LCAR.LCARlists.Size = 0 Then 'analysis
			StartActivity(Main)
			LCAR.PushEvent(LCAR.SYS_System, 1,0,0,0,0,0,LCAR.Event_Down )
		End If
		Log("Starting wallpaper: " & CurrentMode & " " & CurrentSection)
		Select Case CurrentSection'API.LWPLIST 
			Case -1'none
				AddLCAR("TEXT", 0, 0, msdHeight/2,-1,20, 0,0,LCAR.LCAR_Orange , LCAR.LCAR_Textbox, API.GetString("no_wallpaper"), "", "", 0, True, 5, True,0,255)
			Case 0'Alert
				AddLCAR("AlertStatus", 0, 0,0,-1,-1, LCAR.Classic_Green, 0,  LCAR.Classic_Green, LCAR.LCAR_Alert, "", "","", 0, False,0,True,0,255)
			Case 1'starbase Clock
				AddLCAR("Starbase", 0, 0,0,-1,-1, 0, 0,  LCAR.Classic_Green, LCAR.LCAR_StarBase, "", "","", 18,False,0,True,0,255)
			Case 2'Sonar
				AddLCAR("Sonar", 0, 0,0,   -1 ,-1,  0,0,LCAR.Classic_Blue, LCAR.Legacy_Sonar, API.getstring("photic") & " ", "", "",   30, False,  0 ,True,  0,255)
			Case 3'Science Station
				AddLCAR("Moire", 0, 0,0,   -1 ,-1,  0,0,LCAR.lcar_orange, LCAR.TOS_Moires, "", "", "",   29, False,  0 ,True,  0,255)
			Case 4'FWD NAV SCAN
				tempP = MakeFrame("FWD NAV SCAN")
				AddLCAR("Navigation", 0,  tempP.x,tempP.y,  -1 ,-1, 0,-45,LCAR.lcar_orange, LCAR.LCAR_Navigation, "", "", "",   9, False,  0,True,  0,255)
			Case 5'AFM NAV SCAN
				tempP = Trig.SetPoint(0,0)' MakeFrame("FWD NAV SCAN")
				AddLCAR("Navigation", 0, tempP.x,tempP.y,  -1 ,-1, 0,-45,LCAR.lcar_orange, LCAR.SBALLS_Plaid, "", "", "",   9, False,  0,True,  0,255)	
			Case 6'PTOE
				AddLCAR("PToE", 0,0,0,-1,-1,0,0,LCAR.LCAR_Orange, LCAR.LCAR_PToE, API.GetString("sec_21"), API.GetString("lsod_0"), "", 32,False, 0,True, 0,0)
			Case 7'AFM PTOE
				FramesPerSecond=0
				AddLCAR("PToE", 0,0,0,-1,-1,0,1,LCAR.LCAR_Orange, LCAR.LCAR_PToE, "", "", "", 32,False, 0,True, 0,0)	
			Case 8'Federation database
				AddLCAR("TheMatrix", 0, 0,0,  -1 ,-1,  55,95, LCAR.LCAR_DarkBlue , LCAR.LCAR_Matrix, "",  "", "", 17,  False,4 ,  True ,0,0)
			Case 9'Warp core status
				If Height>WidthofScreen Then msdWidth=WidthofScreen
				AddLCAR("WARPCORE", 0, 0,0, -1,-1,  0,1, LCAR.LCAR_Orange , LCAR.LCAR_Engineering, "",  "", "",  20,  False,0 ,   True ,0,0)
			Case 10, 29'second and third in command
				SetupConsole(BG, CurrentSection)
				FramesPerSecond=0
			Case 11'MSD
				RedAlert=False
				FramesPerSecond=0
				tempstr=Settings.Getdefault("MSD","")
				If tempstr.Length =0 Or Not(LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, tempstr ,LCAR.LCAR_MSD)) Or tempstr.Contains("[") Then
					AddLCAR("TEXT", 0, 0, msdHeight/2,-1,20, 0,0,LCAR.LCAR_Orange , LCAR.LCAR_Textbox, API.getstring("no_msd"), "", "", 0, True, 5, True,0,255)
				Else
					msdWidth=0
				End If
			Case 12'Analysis	
				RedAlert=False
				tempP = MakeFrame(API.GetString("snsr_ana"))
				LCARSeffects2.SeedScanAnalysis(18, LCAR.LCAR_TNG)
				AddLCAR("AlertStatus", 0,tempP.x,tempP.y,-1,-1, 18, 0,  LCAR.LCAR_Orange, LCAR.LCAR_List, "", "","", 0, False,0,True,0,255)
			Case 13'Scan animation
				tempP = MakeFrame(API.GetString("snsr_scan"))
				AddLCAR("SensorGrid", 0, tempP.x,tempP.y,  -1 ,-1, 55,95, LCAR.LCAR_DarkBlue , LCAR.LCAR_SensorGrid, "",  "", "0", 2,    False,4,  True ,0,0)
			Case 14, 16, 22, 27, 28, 33, 34, 36,37,41,48,49 'transporter console, shuttle bay, CONN, Voyager conference room, OPS, TOS Bridge, NX-01 Bridge, Transporter 2, Hallway, Warp Field, TMP Bridge, TMP Helm
				RedAlert=False'Don't forget to add it to HandleTouch
				msdHeight= Height-BOTTOM-TOP
				SetupConsole(BG, CurrentSection)
				If CurrentSection = 34 Then 
					Log("NEEDS LCAR FONT")
					LCAR.NeedsLCARfont = True
				End If
				
			Case 15'Warp core 2
				RedAlert=False
				LCARSeffects2.SetupWarpCore(-1)
				LCARSeffects2.SetupWarpCore(msdHeight)
				AddLCAR("WarpCore", 0, 0,0,  -1 ,-1,  0,0, LCAR.LCAR_DarkBlue , LCAR.LCAR_WarpCore, "",  "", "", 0,    True,0,  True ,0,0)
			
			Case 17'Environmental
				AddLCAR("ENVIRON", 0, 0,0, -1,-1, -1, 0, LCAR.LCAR_Orange , LCAR.LCAR_ASquare, "",  "", "",  0,  True,0 ,   True ,0,0)
			Case 18'Starfield
				RedAlert=False
				LCARSeffects3.StarWidth=0
				LCARSeffects3.LoadMSD(Settings.Getdefault("MSD",""))'put effects here
				AddLCAR("stars", 0, 0,0, -1,-1, -1, 0, LCAR.LCAR_Orange , LCAR.LCAR_Starfield, "",  "", "",  0,  False,0 ,   True ,0,0) 
				
			Case 19'BORG
				temp=LCAR.BORG_Color' LCAR.AddLCARcolor("BORG", 0, 120,0, 64)
				AddLCAR("BORG",  0, 0, 0,-1,-1,  0,0,temp, LCAR.LCAR_Borg,"","","", 0 , True, 0,False,0,255)
			
			Case 20'science station 2 (TNG)
				tempP = MakeFrame("")
				temp=msdWidth-tempP.X 
				AddLCAR("SCI1", 0, tempP.x,0, temp, API.IIF(LCAR.SmallScreen,72,145),        LCAR.LCAR_LightPurple,0, LCAR.LCAR_Orange , LCAR.LCAR_Science, "",  "", "",  36,   False,0 ,   True ,0,0)'element 89 (group 36)'72 in SSM
				AddLCAR("SCI2", 0, tempP.x, API.IIF(LCAR.SmallScreen, 94, 181), temp,-1,       LCAR.LCAR_LightPurple,0, LCAR.LCAR_Orange , LCAR.LCAR_Science, "",  "", "",  36,   False,0 ,   True ,1,0)'element 90 (group 36)
			
			Case 21'alert status clock
				RedAlert=False
				AddLCAR("AlertStatus", 0, 0,0,-1,-1, -1, 0, -1, LCAR.LCAR_Alert, "", "","", 0, False,0,True,0,255)
			
			Case 23'cylon
				AddLCAR("CYLON", 0, 0,0,-1,-1, -1, 0, -1, LCAR.DRD_Matrix, "", "","", 0, False,0,True,0,255)
			
			Case 24'SHATTER Glass
				AddLCAR("DS9", 0,   0,0,-1,-1,     0,0,0,  LCAR.CRD_Shatter, "", "", "", 0, False, 0,True, 1,255)
			
			Case 25'SOLAR System
				AddLCAR("SOLAR", 0,   0,0,-1,-1,    0,0,0,  LCAR.ENT_Planets,  "", "", "", 0, False, 0,True, 0,255)
			
			Case 26, 42 'VEHICLE Status [VOY], [ENT-E]
				tempP = MakeFrame(API.GetString("vehicle_status"))
				temp=msdWidth-tempP.X
				temp2 = API.IIF(CurrentSection=26, 1,2)
				'AddLCAR("RNDnum", 0, tempP.x,0, -1,API.IIF(LCAR.SmallScreen,72,145),0,0, LCAR.LCAR_Orange , LCAR.LCAR_RndNumbers, API.GetString("vehicle_status"),  "", "",  -1,   False,0 ,   True ,0,0)
				AddLCAR("VOY", 0,  tempP.x, API.IIF(LCAR.SmallScreen, 94, 181), temp,-1,      1,1,LCAR.lcar_orange, LCAR.LCAR_ShieldStatus, "", "", "",   -1, False,  0,True,  temp2 ,255)
				
			'Case 27 Voyager conference room
			'case 28 OPS
			'case 29 Number two
			
			Case 30'Romulan Clock
				AddLCAR("RomClock", 0,      0,0,-1,-1,      -1,-1,    0, LCAR.ROM_Square, "","", "", -1, True, -1, True, -1, 255)
			
			Case 31'Klingon_Clock
				If PreviewMode Then msdWidth=WidthofScreen
				AddLCAR("KlnClock", 0,      0,0,-1,-1,      -1,-1,    0, LCAR.Klingon_Clock, "","","", -1, True, -1, True,-1 , 255)
			
			Case 32'DS9
				LCARSeffects5.SetupDS9(32, False)
				AddLCAR("DS9", 0,   0,0,-1,-1,     0,0,0,        		LCAR.CRD_Shatter, "", "", "", 0, False, 0,True, 2,255)
			
			'case 33,34 TOS, ENT
			
			Case 35'Tactical 2
				If msdHeight > msdWidth Then msdWidth = msdHeight*(LCARSeffects5.TacMaxWidth/LCARSeffects5.TacMaxHeight)
				AddLCAR("TAC2", 0,      0,0,-1,-1,      1,1,    0, LCAR.LCAR_Tactical2, "","", "",  -1, True, -1, True, LCARSeffects5.randomtactical, 255)
				
			'case 36'transporter 2
			'Case 37'UFP Logo/Hallway
			'	AddLCAR("UFP", 0,0,0,-1,-1, 0,0,LCAR.Classic_Blue, LCAR.LCAR_UFP, "","","", 0,True,0,True,0,0)
			
			Case 38'Qnet
				LCARSeffects3.StarWidth=0
				LCARSeffects3.LoadMSD(Settings.Getdefault("MSD",""))'put effects here
				AddLCAR("Qnet", 0, 0,0, -1,-1, 0, 0, LCAR.LCAR_Orange , LCAR.Q_net, "",  "", "",  0,  False,0 ,   True ,0,0) 
			
			Case 39'SHELIAK
				LCARSeffects5.ShowText= PreviewMode
				AddLCAR("SHELIAK", 0, 0,0, -1,-1, 0, 0, LCAR.LCAR_Orange , LCAR.MSC_Sheliak, "",  "", "",  0,  False,0 ,   True ,0,0) 
			
			Case 40'cardassian
				AddLCAR("CARDY", 1, 0,0, -1,-1, 0, -1, LCAR.LCAR_Orange , LCAR.CRD_Main, "cardassian",  "", "",  0,  False,0 , True ,0,0) 
			
			'case 41, 42'warp field, ent e
			
			Case 43'DNA
				temp = MakeFrameForDNA(LCARSeffects6.RandomDNA(-1))
				AddLCAR("DNA", 0, 0,0, -1,-1,  0, 0, LCAR.LCAR_Orange , LCAR.LCAR_DNA, "",  "", "",  0,  False,0 , True , temp , 0) 
			
			Case 44'INTRO 2
				AddLCAR("UFP", 0, 0,0, -1,-1,  -1, 0, LCAR.LCAR_Orange , LCAR.LCAR_UFP, API.GetString("comm_net"),  "", "",  0,  False,0 , True , 0, 0) 
				msdWidth = PhysicalWidth
			
			'Case 45'hackers			
			'	AddLCAR("ZEROCOOL", 0, 0,0, -1,-1, 0, 0, LCAR.LCAR_Orange , LCAR.MSC_Hacking, "",  "", "",  0,  False,0 , True , 0, 0) 
			
			Case 45'TCARS
				temp = Wireframe.RandomTCARS
				msdWidth = Wireframe.TCARSwidth(temp, msdHeight)
				AddLCAR("TCARS", 0, 0,0, -1,-1,  temp, 0, LCAR.TCAR_LightTurquoise, LCAR.TCAR_Main, API.GetString("werx_status"),  "", "",  0,  False,0 , True , 0, 0) 
			
			Case 46'Borg
				tempP = MakeFrame("EMULATION SUBROUTINE 408")
				LCARSeffects6.Init_Borg
				AddLCAR("BORG", 0,  tempP.x, API.IIF(LCAR.SmallScreen, 94, 181), -1,-1,    -1,-1,LCAR.lcar_orange, LCAR.BORG_Borg, "BORG SYSTEM EMULATION ACTION", "", "",   -1, False,  0,True,  0 ,255)
			
			Case 47'Ferengi
				AddLCAR("FERENGI", 0, 0,0, -1,-1,  -1, 0, LCAR.LCAR_Orange , LCAR.FER_Ticker, "",  "", "",  0,  False,0 , True , 0, 0) 
			
			'case 48, 49 'ENT-B Bridge, ENT-B HELM
			
			Case Else 
				AddLCAR("OMEGA", 0,0,0,-1,-1,Main.DOS,0,LCAR.Classic_Blue, LCAR.LCAR_Omega, "Ω","","", 24,True,0,True,0,0)'element 70 (group 24)
		End Select
		If MediaControls And DDisrunning Then
			temp=(WidthofScreen-6)/3
			AddLCAR("MEDIAREW", 0,		0,0, temp,LCAR.ItemHeight,	LCAR.leftside,0,	LCAR.LCAR_Orange, LCAR.LCAR_Button, API.GetString("prev"), "", "MEDIA_PREV", 0, True, 5, True,   0, 255)
			AddLCAR("MEDIAPLAY", 0,		temp+3,0, temp,LCAR.ItemHeight,	0,0,	LCAR.LCAR_Orange, LCAR.LCAR_Button, API.GetString("music_playpause_d"), "", "MEDIA_PLAY", 0, True, 5, True,   0, 255)
			AddLCAR("MEDIAPLAY", 0,		temp*2+6,0, temp,LCAR.ItemHeight,	0,LCAR.leftside, 	LCAR.LCAR_Orange, LCAR.LCAR_Button, API.GetString("next"), "", "MEDIA_NEXT", 0, True, 5, True,   0, 255)
		End If
		If PreviewMode And Main.CurrentSection = 78 Then 
			temp = msdHeight /3
			temp2= msdWidth / 4
			AllowAlpha=True
			BigText = AddLCAR("BigText", 0,  temp2,  temp,  temp2*2 , temp,  0,0,LCAR.lcar_orange, LCAR.LCAR_Textbox , "%TIME%", "", "NNN",   6 , False,  -12, True, 0, 0)
		End If 
		'If Not(LCAR.flagset) Then
		'	LCAR.WasRedAlert = LCAR.RedAlert 
		'	LCAR.flagset=True
		'End If
		If IsPaused(Main) Then
			 LCAR.SetRedAlert(RedAlert, "Load Settings")
			 If Settings.Getdefault("ALERT", 0) = 2 Then LCAR.RedAlertMode = LCAR.Classic_Blue 
		End If 
		If FramesPerSecond =0 And SamsungMode>0 Then FramesPerSecond=1
		If FramesPerSecond>0 Then 
			Delay=1000/FramesPerSecond
			'If DreamService.DDisrunning OR DDisrunning Then 
			DreamService.TimerMain.Interval = API.IIF(Delay=0,1000,Delay)
			lwm.StopTicking 
			lwm.StartTicking(Delay)
		Else
			DreamService.TimerMain.Interval = 1000
		End If
		LogColor("Delay: " & DreamService.TimerMain.Interval & " ms (" & Floor(1000/DreamService.TimerMain.Interval) & " fps)", Colors.Blue)
	End If
End Sub

Sub MakeFrame(Text As String)As Point 
	Dim Height As Int,Width As Int  
	Width=API.IIF(LCAR.SmallScreen, 53,115)
	Height=API.IIF(LCAR.SmallScreen, 72,145)
	LCARSeffects2.ClearRandomNumbers
	AddLCAR("FRAME", 0, 0,0,-1,-1, Height,0,0, LCAR.LCAR_Frame, "","","",0, True,0,False,0,255)
	If Text.Length>0 Then AddLCAR("RNDnum", 0, Width, 0, -1,Height,0,0, LCAR.LCAR_Orange , LCAR.LCAR_RndNumbers, Text,  "", "",  31,   False,0 ,   True ,0,0)
	If LCAR.SmallScreen Then 
		Return Trig.SetPoint( 56,102)
	Else
		Return Trig.SetPoint(115,200)
	End If
End Sub

Sub MakeFrameForDNA(Style As Int) As Int 
	Select Case Style 
		Case 0'VOY
			MakeFrame2(0,0, msdWidth, msdHeight, LCARSeffects6.DNAdim(0,0), msdHeight*0.5, 3,3)
		Case 3'3D
			'MakeFrame("DNA ANALYSIS")
	End Select
	Return Style 
End Sub

Sub MakeFrame2(X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, MiddleY As Int, TopSquares As Int, BottomSquares As Int)
	Dim WhiteSpace As Int = 10, BarHeight As Int = WhiteSpace * LCAR.ScaleFactor, HalfWhitespace As Int = 5, TextFormat As String = "###@"', temp As Int, temp2 As Int
 	AddLCAR("BLElbow", 0, X, Y+MiddleY-BarWidth-HalfWhitespace, Width-BarWidth-WhiteSpace, BarWidth, BarWidth, BarHeight, LCAR.LCAR_RandomColor, LCAR.LCAR_Elbow , LCARSeffects6.RandomNumber(TextFormat),LCAR.LCAR_RandomText,TextFormat,1, True, 3, True, 2, 255)
	AddLCAR("TLElbow", 0, X, Y+MiddleY+HalfWhitespace, Width-BarWidth-WhiteSpace, BarWidth, BarWidth, BarHeight, LCAR.LCAR_RandomColor, LCAR.LCAR_Elbow , LCARSeffects6.RandomNumber(TextFormat),LCAR.LCAR_RandomText,TextFormat,1, True, 9, True, 0, 255)
	MakeButtons(X, Y, BarWidth, MiddleY - BarWidth - HalfWhitespace, TopSquares, WhiteSpace, TextFormat)
	MakeButtons(X, Y + MiddleY + BarWidth + HalfWhitespace+ WhiteSpace, BarWidth, (Height - MiddleY) - BarWidth - HalfWhitespace, TopSquares, WhiteSpace, TextFormat)
	
	AddLCAR("SQRBL", 0, X+Width-BarWidth, Y+MiddleY-HalfWhitespace-BarHeight, BarWidth, BarHeight, 0,0, LCAR.LCAR_RandomColor, LCAR.LCAR_Button, "", "", "", 1, True, 9, True, 0, 255)
	AddLCAR("SQRTL", 0, X+Width-BarWidth, Y+MiddleY+HalfWhitespace, BarWidth, BarHeight, 0,0, LCAR.LCAR_RandomColor, LCAR.LCAR_Button, "", "", "", 1, True, 9, True, 0, 255)
End Sub
Sub MakeButtons(X As Int, Y As Int, Width As Int, Height As Int, Squares As Int, WhiteSpace As Int, TextFormat As String)
	Dim SquareHeight As Int = Height / Squares 
	Do Until Squares < 1
		AddLCAR("SQR" & Squares, 0, X, Y, Width, SquareHeight - WhiteSpace, 0,0, LCAR.LCAR_RandomColor, LCAR.LCAR_Button, LCARSeffects6.RandomNumber(TextFormat), LCAR.LCAR_RandomText, TextFormat, 1, True, 9, True, 0, 255)
		Y = Y + SquareHeight
		Squares = Squares - 1
	Loop
End Sub

Sub SetupRandomNumbers(ConsoleID As Int, Force As Boolean)
	If Force Then LCARSeffects2.ClearRandomNumbers  
	If LCARSeffects2.InitRandomNumbers(LCAR.LCAR_LWP, True) Or Force Then
		Select Case ConsoleID 
			Case 14'transporter
				LCARSeffects2.AddRowOfNumbers(0, LCAR.LCAR_White, Array As Int(4,1,26,1,6,1,8,1,3,1))
				LCARSeffects2.AddRowOfNumbers(1, LCAR.LCAR_White, Array As Int(-4,1,2,1,6,1))
			'Case 16
				'LCARSeffects2.AddRowOfNumbers(0, LCAR.lcar_Orange, Array As Int(
				
		End Select
	End If
End Sub
Sub SetupConsole(BG As Canvas, ConsoleID As Int)'also add the section to Games.ImagePackDone for ambient noise, SetGroup for beeps
	Dim temp As Int, temp0 As Int, temp1 As Int, temp2 As Int, temp3 As Int, temp4 As Int,temp5 As Int ,temp6 As Int, temp7 As Int, temp8 As Int, temp9 As Int,temp10 As Int, temp11 As Int, temp12 As Int,tempstr As String ,tempdbl As Double 
	Dim ElbowSize As Int 
	LCAR.CheckNumbersize(BG)
	Select Case ConsoleID
		Case 1,27, 34
		Case Else
			FramesPerSecond=1
			GroupsEnabled=True
			RefreshesLive=False
	End Select
	
	SetupRandomNumbers(ConsoleID,True)	
	PlayRandomBeep(True)
	Select Case ConsoleID
		Case 10,29'number 1 and 2
			temp = msdHeight'Min(Activity.Width, Activity.Height)
			temp2=temp*0.05	
			temp3=temp2
			msdWidth=0
			
			temp4= API.IIF(LCAR.SmallScreen,65,95)
			temp5= API.IIF(LCAR.SmallScreen,42,72)
			temp6= API.IIF(LCAR.SmallScreen,26,36)
			AddLCAR("TL2", 0, 216,0, temp-temp2-216, temp4,temp5,temp6, API.IIF(ConsoleID=10, LCAR.lcar_yellow, LCAR.LCAR_Purple) , LCAR.LCAR_Elbow, "",  "", "",  -1,   False,0 ,  True ,5,0)
			AddLCAR("TL1", 0, temp2,0, 96,temp4,temp5,temp6, API.IIF(ConsoleID=10, LCAR.lcar_yellow, LCAR.LCAR_LightPurple ), LCAR.LCAR_Elbow, "34-1906",  "", "",  -1,   False,0 ,   True ,4,0) 
			
			temp4= API.IIF(LCAR.SmallScreen,120,212)
			
			
			temp2=temp*0.37
			temp5= API.IIF(LCAR.SmallScreen,89,129)
			temp6= API.IIF(LCAR.SmallScreen,48,58)
			temp7= API.IIF(LCAR.SmallScreen,69,122)''temp4-temp6  -LCAR.LCARCornerElbow2.Height   ' API.IIF(LCAR.SmallScreen,102,122)
			temp8= API.IIF(LCAR.SmallScreen,72,82)
			AddLCAR("TL3", 0, 0,temp-temp4, temp2,temp5,temp8,temp6, API.IIF(ConsoleID=10, LCAR.LCAR_Orange, LCAR.LCAR_Purple ) , LCAR.LCAR_Elbow, "",  "", "",  -1,   False,0 ,   True ,6,0)
			temp2=temp*0.6
			AddLCAR("TL4", 0, temp-temp2,temp-temp4, temp2,temp4, temp8,temp7,API.IIF(ConsoleID=10, LCAR.lcar_yellow , LCAR.LCAR_LightPurple), LCAR.LCAR_Elbow, "",  "", "",  -1,   False,0 ,   True ,9,0)
			
			temp2=temp3
			temp3= temp - temp2*2  - 144
			temp5= API.IIF(LCAR.SmallScreen,30,60)
			
			If ConsoleID=10 Then
				AddLCAR("ENT", 0, temp2+72, temp5,temp3,temp-temp5-temp4, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_NCC1701D, "", "", "", -1, True, 0, True, 0, 255)'element 4
			Else
				AddLCAR("SQR", 0, temp2+72, temp5,temp3,temp-temp5-temp4, 29,0,  LCAR.LCAR_Orange, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255)
			End If
		Case 14'transporter
			'msdWidth = msdHeight * 4.5			
			'Column 1 (Sequence select)
			temp2=LCAR.ListItemsHeight(4)-3'height of top half
			temp10=BG.MeasureStringWidth("451", LCAR.LCARfont, LCAR.NumberTextSize)
			temp0=LCAR.TextWidth(BG, "EMERGENCY OVERIDE")+30
			temp= Max(LCAR.leftside*6+ temp10+6,temp0)   'temp2* 89/111'width of current column
			
			'temp3= LCAR.leftside*3 + LCAR.TextWidth(BG,"20150")'width of the minibuttons
			
			temp11=BG.MeasureStringWidth("451", LCAR.LCARfont, LCAR.NumberTextSize)+LCAR.TextWidth(BG,"20150")+LCAR.leftside*10+1'total width of the COORDINATE LOCK-198696 button
			If temp2>100 Or temp11>100 Then ElbowSize = temp2 * 0.5 Else ElbowSize=LCAR.LCARCornerElbow2.height'     LCAR.InnerElbowSize2(temp11,  temp2, False)
			
			temp5 = msdHeight -LCAR.ListItemsHeight(8) + LCAR.LCARCornerElbow2.height'Y of bottom half
			If temp5 < temp2 + ElbowSize Then temp5 = temp2 + ElbowSize'LCAR.LCARCornerElbow2.height 'force it to be below the upper half
			
			temp12=temp'width of the slanted button
			AddLCAR("SEQSEL", 0, 17,0,temp, temp2, 0, 0,  LCAR.LCAR_Red, LCAR.LCAR_Button, "SEQUENCE SELECT", "","", -1, True,0,True,1,255)'group -1
			temp6=17+temp - LCAR.leftside*2 - 3
			temp7=temp6+LCAR.leftside+3
			
			temp8=7+temp - LCAR.leftside*2
			AddLCAR("15G88L", 0, 10, temp5, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 0, True, 6, True, 0,255)'group 0
			AddLCAR("15G88R", 0, 10+ LCAR.leftside*2, temp5, temp8, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"15G88", "","", 0,True, 6,True, 0,255)
			
			temp8=temp5 + LCAR.ItemHeight + LCAR.LCARCornerElbow2.height
			temp1=temp8
			AddLCAR("20T", 0, 10+LCAR.leftside, temp8, temp6-13-LCAR.leftside, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "20", "", "", 1, True, 6, True,0,255)'group 1
			AddLCAR("20L", 0, 10, temp8, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 1, True, 6, True, 0,255)
			AddLCAR("20R", 0, temp6 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.lcar_button,"", "","", 1,True, 7,True, -1,255)
			
			temp8=temp8 + LCAR.ItemHeight + 3' 
			temp9=temp6-16 -LCAR.leftside*2- temp10'width of middle block
			AddLCAR("G92T", 0, 10+LCAR.leftside*3, temp8, temp6-13-LCAR.leftside*3, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Grey, LCAR.LCAR_Textbox, "008", "", "", 2, True, 6, True,0,255)'group 2
			AddLCAR("G92L", 0, 10, temp8, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 2, True, 6, True, 0,255)
			AddLCAR("G92M", 0, 10+LCAR.leftside*2 , temp8, temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"G92", "","", 2,True, 6,True, 0,255)
			AddLCAR("G92R", 0, temp6 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", 2,True, 7,True, -1,255)
			AddLCAR("G92G", 0, temp7 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Grey, LCAR.LCAR_Button,"", "","", -1,True, 7,True, -1,255)'group -1

			temp8=temp8 + LCAR.ItemHeight+3
			AddLCAR("72T", 0, 10+LCAR.leftside, temp8, temp6-13-LCAR.leftside, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "72", "", "", 3, True, 6, True,0,255)'group 3
			AddLCAR("72L", 0, 5, temp8, LCAR.leftside+5, LCAR.ItemHeight, LCAR.leftside+5, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "", "", 3, True, 6, True, 0,255)
			AddLCAR("72R", 0, temp6 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","",3,True, 7,True, -1,255)
			AddLCAR("72G", 0, temp7 , temp8, LCAR.leftside, LCAR.ItemHeight*3+6, 0,0,LCAR.LCAR_Grey, LCAR.LCAR_Button,"", "","", -1,True, 7,True, -1,255)'group -1
			
			temp8=temp8 + LCAR.ItemHeight+3
			AddLCAR("514T", 0, 10+LCAR.leftside, temp8, temp6-13-LCAR.leftside, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Grey, LCAR.LCAR_Textbox, "358", "", "", 4, True, 6, True,0,255)'group 4
			AddLCAR("514L", 0, 0, temp8, LCAR.leftside+10, LCAR.ItemHeight, LCAR.leftside+10, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 4, True, 6, True, 0,255)
			AddLCAR("514M", 0, 10+ LCAR.leftside*2 , temp8, temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"514", "","", 4,True, 6,True, 0,255)
			AddLCAR("514R", 0, temp6 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "","", 4,True, 7,True, -1,255)
			
			temp8=temp8 + LCAR.ItemHeight+3
			AddLCAR("G83T", 0, 10+LCAR.leftside, temp8, temp6-10-LCAR.leftside, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Grey, LCAR.LCAR_Textbox, "451", "", "", 5, True, 6, True,0,255)'group 5
			AddLCAR("G83M", 0, 10+ LCAR.leftside*2 , temp8,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"G83", "","", 5,True, 6,True, 0,255)
			AddLCAR("G83R", 0, temp6 , temp8, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "","", 5,True, 7,True, -1,255)
			
			temp8=temp8 + (LCAR.ItemHeight*1.5)+3
			AddLCAR("BOTBAR", 0, 0 , temp8, temp+18, LCAR.ItemHeight*0.5, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)'group -1
			
			'Column 2 PATTERN BUFFER (QUANTUM)/PHASE TRANSITION COILS (PRIMARY)
			'temp1 = Y of first item in the list
			temp3=27+temp'X position of current column
			temp10=LCAR.TextWidth(BG, "PHASE TRANSITION COILS (PRIMARY)")+20
			temp=Max(temp2* 182/111,temp10)'width of column
			
			AddLCAR("PATBUF", 0, temp3,0,temp, temp2, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "SUBSPACE FIELD COMPENSATION", "","", -1, False,9,True,-1,255)'PATTERN BUFFER (QUANTUM)
			AddLCAR("PTC", 0,temp3, temp5, temp, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"PHASE TRANSITION COILS (PRIMARY)", "","", -1,True, 6,True, 0,255)
			AddLCAR("BOTBAR2", 0, temp3, temp8, temp, LCAR.ItemHeight*0.5, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			
			AddLCAR("RNDNUM2", 0, temp3, temp1+LCAR.ListItemsHeight(1)  , temp*0.7, LCAR.ListItemsHeight(2.5), 1,0, LCAR.LCAR_White, LCAR.LCAR_RndNumbers, "", "","", 6,True, 0,True,0,255)'group 6
			AddLCAR("RNDNUM1", 0, temp3, temp1, temp*0.75, LCAR.ListItemsHeight(1), 14,1,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "00283", "","", 6,True, 0,True,0,255)
			
			'column 3 (The buttons next to pattern buffer)
			temp3=temp3+temp+20	
			temp10=temp3
			AddLCAR("TOPUSL", 0, temp3, 0, LCAR.leftside+4, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Red, LCAR.LCAR_Button,"", "", "", 7, True, 0, True, 0,255)'group 7
			AddLCAR("BALIVL", 0, temp3, LCAR.ItemHeight+3, LCAR.leftside+4, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "", "", 8, True, 0, True, 0,255)'group 8
			'AddLCAR("GRJEIL", 0, temp3, (LCAR.ItemHeight+3)*2, LCAR.leftside+4, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 9, True, 0, True, 0,255)'group 9
			AddLCAR("MISCNL", 0, temp3, (LCAR.ItemHeight+3)*3, LCAR.leftside+4, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 10, True, 0, True, 0,255)'group 10
			
			temp3=temp3+LCAR.leftside
			temp4=BG.MeasureStringWidth(" 72001", LCAR.LCARfont, LCAR.NumberTextSize)
			AddLCAR("TOPUST", 0, temp3, 0, temp4, LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Textbox, " 72001", "", "", 7, True, 4, True,0,255)'group 7
			AddLCAR("BALIVT", 0, temp3, LCAR.ItemHeight+3, temp4, LCAR.NumberTextSize,  0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Textbox, "020", "", "", 8, True, 6, True,0,255)'group 8
			AddLCAR("GRJEIT", 0, temp3, (LCAR.ItemHeight+3)*2, temp4, LCAR.NumberTextSize,  0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "51906", "", "", 9, True, 6, True,0,255)'group 9
			AddLCAR("MISCNT", 0, temp3, (LCAR.ItemHeight+3)*3, temp4, LCAR.NumberTextSize,  0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Textbox, "40776", "", "", 10, True, 6, True,0,255)'group 10
			
			temp3=temp3+temp4
			AddLCAR("TOPUSR", 0, temp3 , 0, 120, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button,"TE FRE", "","", 7,True,  7,True, -1,255)'group 7
			AddLCAR("BALIVR", 0, temp3 , LCAR.ItemHeight+3, 120, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"JE HAY", "","", 8,True,  7,True, -1,255)'group 8
			AddLCAR("GRJEIR", 0, temp3 , (LCAR.ItemHeight+3)*2, 120, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"JO SYM", "","", 9,True, 7,True, -1,255)'group 9
			AddLCAR("MISCNR", 0, temp3 , (LCAR.ItemHeight+3)*3, 120, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"TI IAC", "","", 10,True, 7,True, -1,255)'group 10
			
			'column 4 (Targeting coordiante reference/G92)
			temp7=temp5
			temp3=temp3+120+LCAR.leftside
			temp=temp2* 160/111'width of column
			
			temp5=LCAR.TextWidth(BG, "TARGETING COORDINATE REFERENCE")+20 + LCAR.ListItemsHeight(5) 
			temp9=Max(temp+ temp4+120+LCAR.leftside*2,temp5)
			temp=Max(temp, (temp10+temp9)-(temp3+1))
			
			temp5 = LCAR.ListItemsHeight(5)'width/height of dpad
			temp0 = temp10+temp9-temp5'X coord of dpad
			temp11 = temp5 * LCARSeffects.DpadCenter *1.6 'width of center
			temp6 = temp5 * 0.5 - (temp11*0.5)'X coord in dpad of start of middle
			temp9 = temp9 - (temp5-temp6)'width of bar
			
			AddLCAR("SQUARE", 0, temp3+1,0,temp, temp2+1, 14, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_LWP, "", "","", -1,  False, temp11 +1 ,True,temp5-temp6,255)	
			AddLCAR("TCR", 0,temp10, temp7, temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"TARGETING COORDINATE REFERENCE", "","", 11,True, 6,True, 0,255)'group 11
			AddLCAR("DPAD", 0, temp0, temp1, temp5,temp5, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Dpad, "","","", -1 ,True, 0,True, 0,0)
			AddLCAR("BOTBAR3", 0, temp0, temp8, temp5, LCAR.ItemHeight*0.5, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			
			AddLCAR("TCR1", 0, temp10+temp9+1, temp7 - LCAR.ItemHeight*0.25 -1, temp11, LCAR.ItemHeight*0.25, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "","",11,True, 5,True, -1,255)'group 11
			AddLCAR("TCR2", 0, temp10+temp9+1, temp7, temp11, LCAR.ItemHeight*0.25, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "","", 11,True, 5,True, -1,255)
			AddLCAR("TCR3", 0, temp10+temp9+1, temp7 + LCAR.ItemHeight*0.5, temp11, LCAR.ItemHeight*0.5-1, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "","", 11,True, 5,True, -1,255)
			
			AddLCAR("G92", 0,temp10+temp9+2+temp11+1, temp7,  temp6  , LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"G92", "","", 11,True, 6,True, 0,255)'group 11
			
			'Trgetting scanners/Coordinate Lock/Auto Seq columns
			temp = temp10+temp9+2+temp11+1+temp6 + LCAR.leftside 'X of current column
			temp0=BG.MeasureStringWidth("451", LCAR.LCARfont, LCAR.NumberTextSize)'width of 3 BIG numbers
			'temp1 = y of first item in bottom half
			'temp2 = height of top half
			temp3= LCAR.leftside*3 + LCAR.TextWidth(BG,"20150")'width of the minibuttons
			temp4=temp3+temp+LCAR.leftside'x start of buttons
			temp6= temp0 + temp3+LCAR.leftside*7'width of these 2 columns
			'temp7 = y of bottom half
			'temp8 = Y of bottom row
			temp11=temp0+temp3+LCAR.leftside*7+1'total width of the COORDINATE LOCK-198696 button
			
			AddLCAR("TARSCAL", 0, temp,0, temp6*1.33+3,  temp7-3, temp6*0.33, temp2, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "TARGET ACQUISITION", "", "", -1, True, -2, True, 1  ,255)		
			
			AddLCAR("COORDL", 0,temp, temp7,  temp3+LCAR.leftside*5  , LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"COORDINATE LOCK", "","", 12,True, 4,True, 0,255)'group 12
			AddLCAR("COORDM", 0,temp+temp3+LCAR.leftside*5-1, temp7,  temp0+LCAR.leftside*2+1, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"198696", "","", 12,True, 6,True, 0,255)
			AddLCAR("COORDR", 0,temp+temp6+3, temp7,  temp6*0.33, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"AUTO SEQ", "","", -1,True, 6,True, 0,255)
			
			AddLCAR("20T", 0, temp4+LCAR.leftside*5, temp1, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_White, LCAR.LCAR_Textbox, "20", "", "", 13, True, 6, True,0,255)'group 13
			AddLCAR("20L", 0, temp4, temp1, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Purple, LCAR.LCAR_Button,"", "", "", 13, True, 6, True, 0,255)
			AddLCAR("20M", 0, temp4+LCAR.leftside*2 , temp1, LCAR.leftside*3, LCAR.ItemHeight, 0,0,LCAR.LCAR_Purple, LCAR.LCAR_Button,"2904", "","", 13,True, 6,True, 0,255)
			AddLCAR("20R", 0, temp4+LCAR.leftside*5+ temp0, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button,"", "","", 13,True, 7,True, -1,255)
			
			AddLCAR("DAMUOKUDA1", 0, temp4+LCAR.leftside*2,temp1, temp6*1.33+3 - temp3- LCAR.leftside*3, LCAR.ListItemsHeight(6)-2, temp6*0.33,  LCAR.ListItemsHeight(0.5)  , LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "", "", "", -1, True, -2, False, 3  ,255)
			AddLCAR("DAMUOKUDA2", 0, temp+temp6+3, temp1, temp6*0.66, LCAR.ListItemsHeight(6)-2, temp6*0.33, LCAR.ListItemsHeight(1), LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "", "", "", -1, True, -2, False, 2  ,255)
			AddLCAR("DAMUOKUDA3", 0, temp+temp6+3, temp1, temp6* 0.33,LCAR.ListItemsHeight(6)-3, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", -1,True, 0,False, -1,255)
			
			AddLCAR("20150", 0, temp, temp1+LCAR.ItemHeight+3, temp3, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_MiniButton, "20150", "", "", -1, True, 6, True,0,255)
			
			AddLCAR("008T", 0, temp4+LCAR.leftside*5, temp1+LCAR.ItemHeight+3, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Purple, LCAR.LCAR_Textbox, "008", "", "", 14, True, 6, True,0,255)'group 14
			'AddLCAR("008L", 0, temp4, temp1+LCAR.ItemHeight+3, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "", "", 0, True, 6, True, 0,255)
			AddLCAR("008M", 0, temp4+LCAR.leftside*2 , temp1+LCAR.ItemHeight+3, LCAR.leftside*3, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"13888", "","", 14,True, 6,True, 0,255)
			'AddLCAR("008R", 0, temp4+LCAR.leftside*5+ temp0, temp1+LCAR.ItemHeight+3, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "","", 0,True, 7,True, -1,255)
			
			AddLCAR("B33", 0, temp, temp1+(LCAR.ItemHeight+3)*2, temp3, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_MiniButton, "B33", "", "", -1, True, 6, True,0,255)
			
			AddLCAR("B72T", 0, temp4+LCAR.leftside*5, temp1+(LCAR.ItemHeight+3)*2, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_White, LCAR.LCAR_Textbox, "72", "", "", 15, True, 6, True,0,255)'group 15
			AddLCAR("B72L", 0, temp4, temp1+(LCAR.ItemHeight+3)*2, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"", "", "", 15, True, 6, True, 0,255)
			AddLCAR("B72M", 0, temp4+LCAR.leftside*2 , temp1+(LCAR.ItemHeight+3)*2, LCAR.leftside*3, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button, LCAR.LCAR_Block, "","", 15,True, 6,True, 0,255)
			AddLCAR("B72R", 0, temp4+LCAR.leftside*5+ temp0, temp1+(LCAR.ItemHeight+3)*2, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"", "","",15,True, 7,True, -1,255)
			
			AddLCAR("04", 0, temp, temp1+(LCAR.ItemHeight+3)*3, temp3, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_MiniButton, "04", "", "", -1, True, 6, True,0,255)
			
			AddLCAR("B358T", 0, temp4+LCAR.leftside*5, temp1+(LCAR.ItemHeight+3)*3, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "358", "", "", 16, True, 6, True,0,255)'group 16
			AddLCAR("B358L", 0, temp4, temp1+(LCAR.ItemHeight+3)*3, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 16, True, 6, True, 0,255)
			AddLCAR("B358M", 0, temp4+LCAR.leftside*2 , temp1+(LCAR.ItemHeight+3)*3, LCAR.leftside*3, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button, LCAR.LCAR_Block, "","", 16,True, 6,True, 0,255)
			AddLCAR("B358R", 0, temp4+LCAR.leftside*5+ temp0, temp1+(LCAR.ItemHeight+3)*3, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "","", 16,True, 7,True, -1,255)
			
			AddLCAR("957", 0, temp, temp1+(LCAR.ItemHeight+3)*4, temp3, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red, LCAR.LCAR_MiniButton, "957", "", "", -1, True, 6, True,0,255)
			
			AddLCAR("451T", 0, temp4+LCAR.leftside*5, temp1+(LCAR.ItemHeight+3)*4, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_White, LCAR.LCAR_Textbox, "451", "", "", 17, True, 6, True,0,255)'group 17
			AddLCAR("451L", 0, temp4, temp1+(LCAR.ItemHeight+3)*4, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Purple, LCAR.LCAR_Button,"", "", "", 17, True, 6, True, 0,255)
			AddLCAR("451M", 0, temp4+LCAR.leftside*2 , temp1+(LCAR.ItemHeight+3)*4, LCAR.leftside*3, LCAR.ItemHeight, 0,0,LCAR.LCAR_Purple, LCAR.LCAR_Button,"6009", "","", 17,True, 6,True, 0,255)
			AddLCAR("451R", 0, temp4+LCAR.leftside*5+ temp0, temp1+(LCAR.ItemHeight+3)*4, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "","", 17,True, 7,True, -1,255)
			
			AddLCAR("BOTBAR4", 0, temp, temp8-LCAR.ItemHeight*0.1, temp3, LCAR.ItemHeight*0.6+1, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,False, -1,255)
			AddLCAR("BOTBAR5", 0, temp+temp3-1, temp8, LCAR.leftside*2 +5   , LCAR.ItemHeight*0.5, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,False, -1,255)
			
			'Transporter sliders
			'temp0 = width of the 3 BIG numbers
			'temp1 = y of first item in bottom half
			'temp2 = height of top half
			temp3= temp6*0.25 'width of a transporter slider
			temp =temp+temp6+3 + temp6*0.33 + temp3 'x coord of this column
			temp4=temp+temp3-1
			
			'temp7 = y of bottom half
			'temp8 = Y of bottom row
			
			
			ElbowSize =  LCAR.InnerElbowSize2(temp3, LCAR.ItemHeight*0.5, False)
			AddLCAR("DAMUOKUDA5", 0, temp, temp8-LCAR.ItemHeight, temp3, LCAR.ItemHeight*1.5, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,False, -1,255)
			AddLCAR("DAMUOKUDA6", 0, temp4, temp8-ElbowSize, temp3*3+10, LCAR.ItemHeight*0.5+ElbowSize+1, temp3, LCAR.ItemHeight*0.5, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "","","", -1, True, 0,False, 3 ,255)
			AddLCAR("DAMUOKUDA7", 0, temp4+ temp3, temp1, 10, LCAR.ListItemsHeight(6)-5, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,False, -1,255)
			
			AddLCAR("MIDBAR1", 0, temp4+ temp3, 0, 10,     temp7-5, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			AddLCAR("MIDBAR2", 0, temp4+ temp3, temp7, 10, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			
			AddTransporterSlider("TS1", temp, temp7, temp3, temp8-LCAR.ItemHeight , "6688", 18)'group 18
			AddTransporterSlider("TS2", temp+10+temp3*3, temp7, temp3, temp8-LCAR.ItemHeight , "835", 19)'group 19
			AddTransporterSlider("TS3", temp4+ temp3*5, temp7, temp3, temp8-LCAR.ItemHeight , "965", 20)'group 20
			'AddLCAR("MIDBAR3", 0,temp, temp7,  temp3, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"6688", "","", 0,True, 6,True, 0,255)
			
			AddLCAR("MIDBAR4", 0, temp4+ temp3*4, 0, 10, temp7-5, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			AddLCAR("MIDBAR5", 0, temp4+ temp3*4, temp7, 10, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			
			AddLCAR("DAMUOKUDA8",0,temp4+ temp3*4, temp1, 10+temp3, LCAR.ListItemsHeight(6), 10, LCAR.ItemHeight*0.5, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow,"", "","", -1,True, 5,True, 2,255)
			AddLCAR("DAMUOKUDA9", 0, temp4+ temp3*5, temp8-LCAR.ItemHeight, temp3, LCAR.ItemHeight*1.5+2, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "","", -1,True, 5, False, -1,255)
			
			
			temp= temp4+ temp3*6'start X coord of this column
			temp9= temp3 + temp0 + 7 + LCAR.leftside 'width of the buttons
			'temp11=total width of the COORDINATE LOCK-198696 button
			temp10=temp+temp3
			
			'top half
			AddLCAR("MOLIMG1", 0,temp10,0, temp11+temp3*2 , temp7-3, temp11  , temp2, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "", "", "", -1, True, -2, True, 0  ,255)	
			AddLCAR("MOLIMG2", 0,temp10, temp7,  temp11 , LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"MOLECULAR IMAGING SCANNERS", "","", -1,True, 4,True, 0,255)
			AddLCAR("EMRGOVR", 0, temp10+temp11+temp3*2+10,0,temp12, temp2-1, 0, 0,  LCAR.LCAR_Red, LCAR.LCAR_Button, "EMERGENCY OVERIDE", "","", -1, False,0,True,2,255)
			
			AddLCAR("DAMUOKUDAX", 0, temp, temp1, temp11+temp3, LCAR.ListItemsHeight(6), temp11-temp9, LCAR.ItemHeight*0.5, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow,"", "","", -1,True, 5,True, 3,255)
			
			AddLCAR("9580T", 0,temp10+temp3+3, temp1, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_White, LCAR.LCAR_Textbox, "300", "", "", 21, True, 6, True,0,255)'group 21
			AddLCAR("9580L", 0,temp10 , temp1,temp3, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "9580", "","", 21,True, 6,True, 0,255)
			AddLCAR("9580R", 0,temp10+temp3+temp0+6 , temp1,LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "","", 21,True, 6,True, 0,255)
			
			AddLCAR("653L", 0,temp10 , temp1 + LCAR.ListItemsHeight(1) ,temp3, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "653", "","", 22,True, 6,True, 0,255)'group 22
			AddLCAR("653R", 0,temp10+temp3+temp0+6 , temp1 + LCAR.ListItemsHeight(1),LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "","", 22,True, 6,True, 0,255)
			
			AddLCAR("B947T", 0,temp10+temp3+3, temp1 + LCAR.ListItemsHeight(2), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Textbox, "947", "", "", 23, True, 6, True,0,255)'group 23
			AddLCAR("B947L", 0,temp10 , temp1 + LCAR.ListItemsHeight(2),temp3, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, LCAR.LCAR_Block, "","", 23,True, 6,True, 0,255)
			AddLCAR("B947R", 0,temp10+temp3+temp0+6 , temp1 + LCAR.ListItemsHeight(2),LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 23,True, 6,True, 0,255)
			
			AddLCAR("B88T", 0,temp10+temp3+3, temp1 + LCAR.ListItemsHeight(3), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightPurple , LCAR.LCAR_Textbox, "88", "", "", 24, True, 6, True,0,255)'group 24
			AddLCAR("B88L", 0,temp10 , temp1 + LCAR.ListItemsHeight(3),temp3, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, LCAR.LCAR_Block, "","", 24,True, 6,True, 0,255)
			AddLCAR("B88R", 0,temp10+temp3+temp0+6 , temp1 + LCAR.ListItemsHeight(3),LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 24,True, 6,True, 0,255)
			
			temp= temp10 + temp11 + LCAR.leftside'start X coord of this column
			'temp1 = Y first list item
			temp9=temp3'width of a button
			temp2 = temp3*2'width of space under the elbow
			temp3= temp12-LCAR.leftside'width of CH NOL button
			temp4=temp2-LCAR.leftside 'width of elbow
			temp5=temp+temp4+10'X of CH NOL button
			temp6= temp2-LCAR.leftside-LCAR.ItemHeight'barwidth
			temp10=temp5+temp9+LCAR.leftside
			temp11=temp12+17
			temp12=temp10+LCAR.leftside+3'X of final col
			
			AddLCAR("CHNOL1", 0,temp,temp7, temp4 , LCAR.ListItemsHeight(4), temp6  , LCAR.ItemHeight, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "", "", "", -1, True, -2, True, 0  ,255)	
			AddLCAR("CHNOL2", 0,temp5, temp7,  temp3 , LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,"CH NOL", "","", 25,True, 6,True, 0,255)'group 25
			AddLCAR("CHNOL3", 0,temp5+10+temp3, temp7, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 25, True, 6, True, 0,255)
			AddLCAR("CHNOL4", 0, temp, temp1, temp4, LCAR.ListItemsHeight(6), temp6, LCAR.ItemHeight*0.5, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow,"", "","", -1,True, 5,True, 2,255)
			AddLCAR("BOTBAR6", 0, temp5, temp8+3, temp11  , LCAR.ItemHeight*0.5, 0,0,LCAR.LCAR_LightOrange, LCAR.LCAR_Button,"", "","", -1,True, 5,True, -1,255)
			
			temp=temp+temp4 -LCAR.leftside'start X coord of this column
			temp11=temp11-temp9-LCAR.leftside*3-20'width of final column
			temp0=temp12+temp11-1'X of final bubbles
			
			AddLCAR("9220L", 0,temp, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "","", 26,True, 6,True, 0,255)'group 26
			AddLCAR("9220M", 0,temp5, temp1,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "9220", "","", 26,True, 4,True, 0,255)
			AddLCAR("9220N", 0,temp10, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 26,True, 6,True, 0,255)
			AddLCAR("9220O", 0,temp12, temp1, temp11, LCAR.ItemHeight, 0,0,LCAR.LCAR_Purple, LCAR.LCAR_Button, "", "","", 26,True, 6,True, 0,255)
			AddLCAR("9220P", 0,temp0, temp1, LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside,LCAR.LCAR_Purple, LCAR.LCAR_Button, "", "","", 26,True, 6,True, 0,255)
			
			temp1=temp1+LCAR.ListItemsHeight(1)
			AddLCAR("120L", 0,temp, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 27,True, 6,True, 0,255)'group 27
			AddLCAR("120M", 0,temp5, temp1,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "120", "","", 27,True, 4,True, 0,255)
			AddLCAR("120N", 0,temp10, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 27,True, 6,True, 0,255)
			AddLCAR("120O", 0,temp12, temp1, temp11, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 27,True, 6,True, 0,255)
			AddLCAR("120P", 0,temp0, temp1, LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 27,True, 6,True, 0,255)
			
			temp1=temp1+LCAR.ListItemsHeight(1)
			AddLCAR("10825L", 0,temp, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 28,True, 6,True, 0,255)'group 28
			AddLCAR("10825M", 0,temp5, temp1,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "10825", "","", 28,True, 4,True, 0,255)
			AddLCAR("10825N", 0,temp10, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 28,True, 6,True, 0,255)
			AddLCAR("10825O", 0,temp12, temp1, temp11, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 28,True, 6,True, 0,255)
			AddLCAR("10825P", 0,temp0, temp1, LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 28,True, 6,True, 0,255)
			
			temp1=temp1+LCAR.ListItemsHeight(1)
			AddLCAR("990L", 0,temp, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "","", 29,True, 6,True, 0,255)'group 29
			AddLCAR("990M", 0,temp5, temp1,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "990", "","", 29,True, 4,True, 0,255)
			AddLCAR("990N", 0,temp10, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 29,True, 6,True, 0,255)
			AddLCAR("990O", 0,temp12, temp1, temp11, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 29,True, 6,True, 0,255)
			AddLCAR("990P", 0,temp0, temp1, LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 29,True, 6,True, 0,255)
			
			temp1=temp1+LCAR.ListItemsHeight(1)
			AddLCAR("92L", 0,temp, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_Red, LCAR.LCAR_Button, "", "","", 30,True, 6,True, 0,255)'group 30
			AddLCAR("92M", 0,temp5, temp1,temp9, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button, "92", "","", 30,True, 4,True, 0,255)
			AddLCAR("92N", 0,temp10, temp1, LCAR.leftside, LCAR.ItemHeight, 0,0,LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "","", 30,True, 6,True, 0,255)
			AddLCAR("92O", 0,temp12, temp1, temp11, LCAR.ItemHeight, 0,0,LCAR.LCAR_Purple, LCAR.LCAR_Button, "", "","", 30,True, 6,True, 0,255)
			AddLCAR("92P", 0,temp0, temp1, LCAR.leftside, LCAR.ItemHeight,  0,LCAR.leftside,LCAR.LCAR_Purple, LCAR.LCAR_Button, "", "","", 30,True, 6,True, 0,255)
		Case 16' shuttle bay
			'GroupsEnabled=False
			RefreshesLive=True
			
			tempstr="SHUTTLEBAY OPERATIONS"
			temp=LCAR.ItemHeight+1'*2 'height of the buttons
			temp2=API.GetTextHeight(BG, temp, tempstr,LCAR.LCARfont)
			temp3=BG.MeasureStringWidth(tempstr, LCAR.LCARfont, temp2)' LCAR.NumberTextSize)
			'dimensions of starship 701(width) x 370(height)
			temp4= msdHeight-(temp*2) 'max height available to the starship
			tempdbl=temp4/370
			If tempdbl >1 Then 	
				tempdbl= Floor(tempdbl)
				temp4 = 370* tempdbl  'height of starship redone
			End If
			temp5 = tempdbl * 701 'width of starship at that height
			temp8= LCAR.TextWidth(BG, "PRIMARY ACQUISITION ZONE") * 1.2
			temp10=msdHeight/2-temp4/2'top of the ship
			
			AddLCAR("TL", 0, 0,0,temp, temp-1, 0, 0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "", "","", -1, True,0,True,-4  ,255)'element 0
			AddLCAR("SHIP", 0, temp, temp10, temp5, temp4, 0,0, 0, LCAR.LCAR_ShuttleBay, "","","", -1,True,0,True,0,255)'element (drawn before text, cause of the shuttles)
			AddLCAR("TXT", 0, temp+4,0,temp3, temp2 , -1, 0, LCAR.LCAR_Purple , LCAR.LCAR_Textbox, tempstr, "","", -1, True,0,True,0 ,255)'element 
			
			'start at 380 (0.5420827389443652), width = 150 (0.2139800285306705), max height of 60 (0.2139800285306705)
			If temp10-temp>0 Then
				AddLCAR("RNDnum", 0, temp +  (temp5*0.50) ,temp , temp5*0.22, temp10-temp,0,0, LCAR.LCAR_Orange , LCAR.LCAR_RndNumbers, "",  "", "",  -1,   False,0 ,   True ,0,0)'element 
			End If
			
			temp9=Max(0, (temp5*0.87) - temp3 - temp8) 'temp3*1.2 ' width of the shuttlebay ops button
			If temp9>0 Then	
				AddLCAR("T1", 0, temp+8+temp3, 0,  temp9, temp, 0,0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "", "","", -1, True,0,True,0  ,255)'element 
			Else
				temp9=-4
			End If
			temp7=temp+12+temp3+temp9
			AddLCAR("T2", 0, temp7, 0,  temp8, temp, 0,0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "SHUTTLE BAYS 2/3", "","",  -1, True,7,True,0  ,255)'element 
			
			tempstr="MAIN SHUTTLE BAY"
			temp3=LCAR.TextWidth(BG,tempstr)
			temp7=temp7+temp8+4
			temp0=temp7-temp5-temp
			temp11= Max(temp3+temp*3+LCAR.LCARCornerElbow2.Width,temp0)  'width of elbow
			temp12= Max(temp10, temp+LCAR.LCARCornerElbow2.height) 'height of elbow
			AddLCAR("TR", 0, temp7,0, temp11, temp12,  temp*3, temp, LCAR.LCAR_ORANGE, LCAR.LCAR_Elbow, tempstr, "", "", -1, True, -7, True, 1, 255)
			temp0= temp7+temp11
			temp11=temp0 - temp*3'x of new area
			
			temp6=msdHeight-temp',temp
			AddLCAR("BL1", 0, 0,temp6, temp,temp-1, 0, 0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "", "","",-1,  True,0,True,-4 ,255)'element 
			temp7=temp5*0.47
			AddLCAR("BL2", 0, temp+4, temp6, temp7, temp, 0, 0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "APPROACH VECTORS", "","", -1, True,1,True,0 ,255)'element 
			temp7=temp+8+temp7
			temp5=temp5*0.5-8
			AddLCAR("BL3", 0, temp7, temp6, temp8, temp, 0, 0,  LCAR.LCAR_Purple, LCAR.LCAR_Button, "PRIMARY ACQUISITION ZONE", "","", -1, True, 1,True,0 ,255)'element 
			
			temp7=temp7+temp8+4'X
			temp1 = temp0-temp7'width
			AddLCAR("BR", 0, temp7, msdHeight-temp12, temp1, temp12, temp*3, temp,  LCAR.LCAR_DarkPurple, LCAR.LCAR_Elbow, "TRACTOR CONTROL ZONE", "","", -1, True,-1,True,3 ,255)'element 
			
			'temp11=x temp12 +4=y
			temp4=( msdHeight-(temp12+4)*2 )/2
			temp5=temp12+6+temp4
			temp6=temp12+2 + temp4 - temp
			AddLCAR("NT", 0, temp11, temp12+2, temp*4, temp4, temp*3, temp, LCAR.LCAR_ORANGE, LCAR.LCAR_Elbow, "", "", "", -1, True, 0,True, 2  ,255)
			AddLCAR("NB", 0, temp11, temp5, temp*4, temp4-1, temp*3, temp, LCAR.LCAR_ORANGE, LCAR.LCAR_Elbow, "", "", "", -1, True, 0,True, 0  ,255)
			
			LCARSeffects2.ShuttleVehicleW = LCAR.TextWidth(BG,"SHUTTLE VEHICLE")*1.5
			LCARSeffects2.StatusW = LCAR.TextWidth(BG,"STATUS")*1.5
			LCARSeffects2.LocationW  = LCAR.TextWidth(BG,"LOCATION")*1.5
			temp2=LCARSeffects2.ShuttleVehicleW + LCARSeffects2.StatusW + LCARSeffects2.LocationW + 4
			temp3=(msdHeight/2)-temp*2
			
			temp11=temp11+temp*4+4
			AddLCAR("TR1", 0, temp11, temp6, LCARSeffects2.ShuttleVehicleW, temp, 0, 0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "SHUTTLE VEHICLE", "","",  -1, True,7,True,0 ,255)'element   
			AddLCAR("BR1", 0, temp11, temp5, LCARSeffects2.ShuttleVehicleW, temp, 0, 0,  LCAR.LCAR_ORANGE, LCAR.LCAR_Button, "2840", "","",  -1, True,1,True,0 ,255)'element 
			
			AddLCAR("SHTL", 0, temp11,0, temp2, temp3, 1,0, LCAR.LCAR_Black, LCAR.LCAR_Shuttlebay, "", "", "", -1,True, 0, True,0,255)
			AddLCAR("PODS", 0, temp11,temp5+temp*2, temp2, temp3, 2,0, LCAR.LCAR_Black, LCAR.LCAR_Shuttlebay, "", "", "", -1,True, 0, True,0,255)

			temp11= temp11+LCARSeffects2.ShuttleVehicleW+4
			AddLCAR("TR2", 0, temp11, temp6, LCARSeffects2.StatusW, temp, 0, 0,  LCAR.LCAR_yellow, LCAR.LCAR_Button, "STATUS", "","",  -1, True,7,True,0 ,255)'element 
			AddLCAR("BR2", 0, temp11, temp5, LCARSeffects2.StatusW, temp, 0, 0,  LCAR.LCAR_yellow, LCAR.LCAR_Button, "9395", "","",  -1, True,1,True,0 ,255)'element 
			
			temp11= temp11+LCARSeffects2.StatusW+4
			AddLCAR("TR3", 0, temp11, temp6, LCARSeffects2.LocationW, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "LOCATION", "","",  -1, True,7,True,0 ,255)'element 
			AddLCAR("BR3", 0, temp11, temp5, LCARSeffects2.LocationW, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "6348", "","",  -1, True,1,True,0 ,255)'element
			
			temp11= temp11+LCARSeffects2.LocationW+4
			temp2=LCAR.TextWidth(BG,"0897 1324")+10
			AddLCAR("TR4", 0, temp11, temp6, temp2, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "0897 1324", "","",  -1, True,7,True,0 ,255)'element 
			AddLCAR("BR4", 0, temp11, temp5, temp2, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "8348 8385", "","",  -1, True,1,True,0 ,255)'element 
			
			temp11= temp11+temp2+4
			AddLCAR("TR5", 0, temp11, temp6, temp, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "","",  -1, True,7,True,-5 ,255)'element 
			AddLCAR("BR5", 0, temp11, temp5, temp, temp, 0, 0,  LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "","",  -1, True,1,True,-5 ,255)'element 
		Case 22'CONN
			temp0 = LCAR.ListItemsHeight(5)'height of top half
			temp1 = msdHeight -LCAR.ListItemsHeight(8) + LCAR.LCARCornerElbow2.height'Y of bottom half
			temp4= LCAR.leftside*3 + LCAR.TextWidth(BG,"20150")'width of the minibuttons
			If temp0>100 Or temp4>100 Then ElbowSize = Min(temp0,temp4*2) * 0.5 Else ElbowSize=LCAR.LCARCornerElbow2.height'     LCAR.InnerElbowSize2(temp11,  temp2, False)
			If temp1 < temp0 + ElbowSize Then temp1 = temp0 + ElbowSize 'force it to be below the upper half
			temp3=msdHeight-temp1'height of bottom
			
			temp11 = temp0 * LCARSeffects.DpadCenter *1.6 'width of center
			temp2 = temp0 * 0.5 - (temp11*0.5)'X coord in dpad of start of middle
			
			'Column 1
			AddLCAR("DPD1", 0,  temp0*0.5, 0, temp0,temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Dpad, "","","", -1 ,True, 0,True, 0,0)
			AddLCAR("SLNT", 0,  0, temp1,   temp0*1.5,  LCAR.ListItemsHeight(7)+8, 22, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, temp0,True,temp11,255)
			
			'Column 2
			temp = temp0*1.5+5
			'temp4= LCAR.leftside*3 + LCAR.TextWidth(BG,"20150")'width of the minibuttons
			temp8=temp1+LCAR.ItemHeight*2'start of items
			AddLCAR("0027", 0, temp+temp4, temp1+LCAR.ItemHeight*2, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_MiniButton, "27", "", "", -1, True, 6, True,0,255)
			AddLCAR("0330", 0, temp+temp4, temp1+LCAR.ItemHeight*3+2, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_MiniButton, "330", "", "", -1, True, 6, True,0,255)
			AddLCAR("0495", 0, temp+temp4, temp1+LCAR.ItemHeight*4+4, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Blue, LCAR.LCAR_MiniButton, "495", "", "", -1, True, 6, True,0,255)
			AddLCAR("0023", 0, temp+temp4, temp1+LCAR.ItemHeight*5+6, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_MiniButton, "23", "", "", -1, True, 6, True,0,255)
			AddLCAR("0845", 0, temp+temp4, temp1+LCAR.ItemHeight*6+8, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Blue, LCAR.LCAR_MiniButton, "845", "", "", -1, True, 6, True,0,255)
			
			'Column 3
			temp5=temp1+LCAR.ItemHeight*2
			temp6=temp+temp4*2+10
			AddLCAR("300T", 0, temp6+LCAR.leftside*3+32, temp8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Yellow, LCAR.LCAR_Textbox, "300", "", "", 0, True, 6, True,0,255)'group 0			
			AddLCAR("300L", 0, temp6+20, temp8, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Yellow, LCAR.lcar_button,"", "","", 0,True, 6,True,0,255)
			AddLCAR("300M", 0, temp6+LCAR.leftside+32, temp8, LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"324", "", "", 0, True, 6, True, 0,255)
			AddLCAR("300R", 0, temp6+LCAR.leftside*3+LCAR.NumberWhiteSpace+34, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 0, True, 6, True, 0,255)
			
			AddLCAR("477L", 0, temp6+20, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_LightYellow, LCAR.lcar_button,"", "","", 1,True, 6,True,0,255)'group 1
			AddLCAR("477M", 0, temp6+LCAR.leftside+32, temp8+LCAR.ItemHeight+2, LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"4077", "", "", 1, True, 6, True, 0,255)
			AddLCAR("477R", 0, temp6+LCAR.leftside*3+LCAR.NumberWhiteSpace+34, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 1, True, 6, True, 0,255)
			
			AddLCAR("947T", 0, temp6+LCAR.leftside*3+32, temp8+LCAR.ItemHeight*2+4, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Blue, LCAR.LCAR_Textbox, "947", "", "", 2, True, 6, True,0,255)'group 2
			AddLCAR("947L", 0, temp6+20, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Blue, LCAR.lcar_button,"", "","", 2,True, 6,True,0,255)
			AddLCAR("947M", 0, temp6+LCAR.leftside+32, temp8+LCAR.ItemHeight*2+4, LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"411", "", "", 2, True, 6, True, 0,255)
			AddLCAR("947R", 0, temp6+LCAR.leftside*3+LCAR.NumberWhiteSpace+34, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 2, True, 6, True, 0,255)
			
			AddLCAR("088T", 0, temp6+LCAR.leftside*3+32, temp8+LCAR.ItemHeight*3+6, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "88", "", "", 3, True, 6, True,0,255)'group 3
			AddLCAR("088L", 0, temp6+20, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Blue, LCAR.lcar_button,"", "","", 3,True, 6,True,0,255)
			AddLCAR("088M", 0, temp6+LCAR.leftside+32, temp8+LCAR.ItemHeight*3+6, LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"265", "", "", 3, True, 6, True, 0,255)
			AddLCAR("088R", 0, temp6+LCAR.leftside*3+LCAR.NumberWhiteSpace+34, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 3, True, 6, True, 0,255)
			
			AddLCAR("083T", 0, temp6+LCAR.leftside*3+32, temp8+LCAR.ItemHeight*4+8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Blue, LCAR.LCAR_Textbox, "83", "", "", 4, True, 6, True,0,255)'group 4
			AddLCAR("083L", 0, temp6+20, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_DarkOrange, LCAR.lcar_button,"", "","", 4,True, 6,True,0,255)
			AddLCAR("083M", 0, temp6+LCAR.leftside+32, temp8+LCAR.ItemHeight*4+8, LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"0081", "", "", 4, True, 6, True, 0,255)
			AddLCAR("083R", 0, temp6+LCAR.leftside*3+LCAR.NumberWhiteSpace+34, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 4, True, 6, True, 0,255)
			
			'Elbows and middle bar	LCAR.LCARCornerElbow2.Width
			temp7=LCAR.TextWidth(BG, "LCARS MODE SELECT")+20
			temp9=LCAR.leftside*3+8+LCAR.NumberWhiteSpace + temp7
			AddLCAR("LMS0", 0, temp6+LCAR.leftside+32, temp8, temp9, LCAR.ItemHeight*6+4, LCAR.leftside*3+8+LCAR.NumberWhiteSpace, LCAR.ItemHeight*0.4, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "LCARS MODE SELECT", "", "", -1, True, 0,True,  3,255)
			AddLCAR("LMS1", 0, temp6+LCAR.leftside+32, temp8+LCAR.ItemHeight*5.5, LCAR.leftside*2, LCAR.ItemHeight*0.5-2, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", -1, True, 6, True, 0,255)
			AddLCAR("LMS2", 0, temp6+LCAR.leftside+32, 0, temp9+ LCAR.LCARCornerElbow2.Width*2 + temp4*4 + LCAR.leftside*4, Max(temp0+ElbowSize -10, temp1-LCAR.ItemHeight*0.75), temp9, temp0, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "NAVIGATIONAL REFERENCE", "", "", -1, True, 9,True, 0,255)'LCAR_LightYellow
			ElbowSize = temp6+LCAR.leftside+32 + temp9'end X coordinate of below' LCAR.leftside*5+13+LCAR.NumberWhiteSpace + temp7+temp4*2
			AddLCAR("CRSL", 0, temp+5, temp1,ElbowSize- (temp+5)   , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"COURSE SELECT", "", "", -1, True, 6, True, 0,255)
			
			'third column elbows and bits
			'ElbowSize=LCAR.LCARCornerElbow2.Width
			temp = temp  + LCAR.leftside*5+18+LCAR.NumberWhiteSpace + temp7+temp4*2 + LCAR.LCARCornerElbow2.Width
			temp7=LCAR.TextWidth(BG, "FLIGHT CONTROL")+20
			AddLCAR("NAV1", 0, temp, temp1, temp4*4+ LCAR.LCARCornerElbow2.Width + LCAR.leftside*4     , LCAR.ItemHeight*7,  temp4, LCAR.ItemHeight, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "NAVIGATIONAL REFERENCE", "", "", -1, True, -9,True, 0,255)'LCAR_Elbow	LCAR.LCAR_LightYellow
			AddLCAR("NAV2", 0, temp, temp8+LCAR.ItemHeight*4+4,LCAR.LCARCornerElbow2.Width+temp4+ LCAR.leftside, LCAR.ItemHeight*2+1,temp4, LCAR.ItemHeight*0.5-2, LCAR.LCAR_LightYellow,LCAR.LCAR_Elbow,"","","",-1,True,0,True,2,255)'LCAR_Elbow	LCAR.LCAR_LightYellow
			AddLCAR("NAV3", 0, temp + LCAR.LCARCornerElbow2.Width+temp4+ LCAR.leftside*2, temp8+LCAR.ItemHeight*5+7 + LCAR.ItemHeight*0.5, temp4*3 + LCAR.leftside*2,LCAR.ItemHeight*0.5-2, 0,0,  LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", -1, True, 0, True,0,255)'LCAR_Button	LCAR.LCAR_Orange
			AddLCAR("NAV4", 0, temp+temp4*3+ LCAR.LCARCornerElbow2.Width + LCAR.leftside*4 , 0, temp4, temp0, 0,0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button, "FLIGHT CONTROL", "","", -1,True,8,False,0,255)'LCAR_Button	LCAR.LCAR_LightYellow
			
			temp = temp + LCAR.LCARCornerElbow2.Width + temp4
			AddLCAR("R1C1", 0, temp, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 5, True, 6, True, 0,255)'group 5
			AddLCAR("R1C2", 0, temp+LCAR.leftside*2, temp8, temp4 , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"2652", "", "", 5, True, 4, True, 0,255)
			AddLCAR("R1C3", 0, temp+LCAR.leftside+temp4, temp8, LCAR.leftside , LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 5, True, 4, True, 0,255)
			AddLCAR("R1C4", 0, temp+LCAR.leftside*3+temp4, temp8, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Blue, LCAR.LCAR_MiniButton,"150", "", "", 5, True, 6, True, 0,255)
			AddLCAR("R1C5", 0, temp+LCAR.leftside*4+temp4*2, temp8, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_MiniButton,"2113", "", "", 5, True, 6, True, 0,255)
			
			AddLCAR("R2C1", 0, temp, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 6, True, 6, True, 0,255)'group 6
			AddLCAR("R2C2", 0, temp+LCAR.leftside*2, temp8+LCAR.ItemHeight+2, temp4 , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"201", "", "", 6, True, 4, True, 0,255)
			AddLCAR("R2C3", 0, temp+LCAR.leftside+temp4, temp8+LCAR.ItemHeight+2, LCAR.leftside , LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 6, True, 4, True, 0,255)
			
			AddLCAR("R3C1", 0, temp, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 7, True, 6, True, 0,255)'group 7
			AddLCAR("R3C2", 0, temp+LCAR.leftside*2, temp8+LCAR.ItemHeight*2+4, temp4 , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"36", "", "", 7, True, 4, True, 0,255)
			AddLCAR("R3C3", 0, temp+LCAR.leftside+temp4, temp8+LCAR.ItemHeight*2+4, LCAR.leftside , LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 7, True, 4, True, 0,255)
			AddLCAR("R3C4", 0, temp+LCAR.leftside*3+temp4, temp8+LCAR.ItemHeight*2+4, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_MiniButton,"118", "", "", 7, True, 6, True, 0,255)
			AddLCAR("R3C5", 0, temp+LCAR.leftside*4+temp4*2, temp8+LCAR.ItemHeight*2+4, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Blue, LCAR.LCAR_MiniButton,"330", "", "", 7, True, 6, True, 0,255)
			
			AddLCAR("R4C2", 0, temp+LCAR.leftside*2, temp8+LCAR.ItemHeight*3+6, temp4 , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"4011", "", "", 8, True, 4, True, 0,255)'group 8
			AddLCAR("R4C3", 0, temp+LCAR.leftside+temp4, temp8+LCAR.ItemHeight*3+6, LCAR.leftside , LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 8, True, 4, True, 0,255)
			AddLCAR("R4C4", 0, temp+LCAR.leftside*3+temp4, temp8+LCAR.ItemHeight*3+6, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_MiniButton,"158", "", "", 8, True, 6, True, 0,255)
			AddLCAR("R4C5", 0, temp+LCAR.leftside*4+temp4*2, temp8+LCAR.ItemHeight*3+6, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_MiniButton,"41", "", "", 8, True, 6, True, 0,255)
			
			AddLCAR("R5C1", 0, temp, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 9, True, 6, True, 0,255)'group 9
			AddLCAR("R5C2", 0, temp+LCAR.leftside*2, temp8+LCAR.ItemHeight*4+8, temp4 , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"581", "", "", 9, True, 4, True, 0,255)
			AddLCAR("R5C3", 0, temp+LCAR.leftside+temp4, temp8+LCAR.ItemHeight*4+8, LCAR.leftside , LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 9, True, 4, True, 0,255)
			AddLCAR("R5C5", 0, temp+LCAR.leftside*4+temp4*2, temp8+LCAR.ItemHeight*4+8, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_MiniButton,"508", "", "", 9, True, 6, True, 0,255)
			
			'fourth column
			temp = temp + LCAR.leftside*4+temp4*3+ 10
			AddLCAR("SQRE", 0, temp, 0,  temp2*2+9+temp11, temp0, 22, 1,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255)
			
			AddLCAR("C4E1", 0, temp, temp1, temp2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "", "", 10, True, 6, True, 0,255)'Group 10
			AddLCAR("C4E2", 0, temp+temp2+2, temp1, temp11, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 10, True, 6, True, 0,255)
			AddLCAR("C4E3", 0, temp+temp2+2, temp1-12, temp11, 10, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 10, True, 6, True, 0,255)
			AddLCAR("C4E4", 0, temp+temp2+4+temp11, temp1, temp2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightPurple, LCAR.LCAR_Button,"", "", "", 10, True, 6, True, 0,255)
			AddLCAR("C4E5", 0, temp, temp8+LCAR.ItemHeight*5+7 + LCAR.ItemHeight*0.5,  temp2*2+4+temp11 ,LCAR.ItemHeight*0.5-2, 0,0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 10, True, 0, True,0,255)
			
			AddLCAR("DPD2", 0, temp+temp2+2+(temp11*0.5)-(temp0*0.5), temp1+LCAR.ItemHeight*2+ ((LCAR.ItemHeight*5+5)*0.5)-(temp0*0.5), temp0,temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Dpad, "","","", -1 ,True, 0,True, 0,0)
			
			'fifth column
			temp = temp + temp2*2+14+temp11
			AddLCAR("WPDS", 0, temp, 0, LCAR.leftside*10+temp4*2+2+LCAR.NumberWhiteSpace, temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"WARP DRIVE SYSTEMS", "", "", -1, True, 9, True, 0,255)
			AddLCAR("OPSL", 0, temp, temp1, LCAR.leftside*10+temp4*2+2+LCAR.NumberWhiteSpace, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"OPTION SELECT", "", "", -1, True, 6, True, 0,255)
			AddLCAR("C5BT", 0, temp, temp8+LCAR.ItemHeight*5+7 + LCAR.ItemHeight*0.5,  LCAR.leftside*10+temp4*2+2+LCAR.NumberWhiteSpace ,LCAR.ItemHeight*0.5-2, 0,0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 10, True, 0, True,0,255)
			
			AddLCAR("R1C8", 0, temp+LCAR.leftside*3+temp4*2+2, temp8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "20", "", "", 11, True, 6, True,0,255)'group 11			
			AddLCAR("R1C6", 0, temp+LCAR.leftside, temp8, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_MiniButton,"70", "", "", 11, True, 6, True, 0,255)
			AddLCAR("R1C7", 0, temp+LCAR.leftside*2+temp4, temp8, temp4+LCAR.leftside+2, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"069", "", "", 11, True, 6, True, 0,255)
			AddLCAR("R1C9", 0, temp+LCAR.leftside*3+temp4*2+2+LCAR.NumberWhiteSpace, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 11, True, 6, True, 0,255)
			AddLCAR("R1CB", 0, temp+LCAR.leftside*7+temp4*2+2+LCAR.NumberWhiteSpace, temp8, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Yellow, LCAR.lcar_button,"", "","", 11,True, 6,True,0,255)
			AddLCAR("R1CC", 0, temp+LCAR.leftside*9+temp4*2+2+LCAR.NumberWhiteSpace, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 11, True, 6, True, 0,255)
			
			AddLCAR("R2C8", 0, temp+LCAR.leftside*3+temp4*2+2, temp8+LCAR.ItemHeight+2, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Blue, LCAR.LCAR_Textbox, "008", "", "", 12, True, 6, True,0,255)'group 12
			AddLCAR("R2C6", 0, temp+LCAR.leftside, temp8+LCAR.ItemHeight+2, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_MiniButton,"8080", "", "", 12, True, 6, True, 0,255)
			AddLCAR("R2C7", 0, temp+LCAR.leftside*2+temp4, temp8+LCAR.ItemHeight+2, temp4+LCAR.leftside+2, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightYellow , LCAR.LCAR_Button,"358", "", "", 12, True, 6, True, 0,255)
			AddLCAR("R2C9", 0, temp+LCAR.leftside*3+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 12, True, 6, True, 0,255)
			AddLCAR("R2CB", 0, temp+LCAR.leftside*7+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Blue, LCAR.lcar_button,"", "","", 12,True, 6,True,0,255)
			
			AddLCAR("R3C8", 0, temp+LCAR.leftside*3+temp4*2+2, temp8+LCAR.ItemHeight*2+4, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "72", "", "", 13, True, 6, True,0,255)'group 13			
			AddLCAR("R3C6", 0, temp+LCAR.leftside, temp8+LCAR.ItemHeight*2+4, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_MiniButton,"82", "", "", 13, True, 6, True, 0,255)
			AddLCAR("R3C7", 0, temp+LCAR.leftside*2+temp4, temp8+LCAR.ItemHeight*2+4, temp4+LCAR.leftside+2, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"88", "", "", 13, True, 6, True, 0,255)
			AddLCAR("R3C9", 0, temp+LCAR.leftside*3+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 13, True, 6, True, 0,255)
			AddLCAR("R3CB", 0, temp+LCAR.leftside*7+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_Blue, LCAR.lcar_button,"", "","", 13,True, 6,True,0,255)
			AddLCAR("R3CC", 0, temp+LCAR.leftside*9+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "", 13, True, 6, True, 0,255)
					
			AddLCAR("R4C8", 0, temp+LCAR.leftside*3+temp4*2+2, temp8+LCAR.ItemHeight*3+6, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Blue, LCAR.LCAR_Textbox, "358", "", "", 14, True, 6, True,0,255)'group 14			
			AddLCAR("R4C6", 0, temp+LCAR.leftside, temp8+LCAR.ItemHeight*3+6, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Blue, LCAR.LCAR_MiniButton,"563", "", "", 14, True, 6, True, 0,255)
			AddLCAR("R4C7", 0, temp+LCAR.leftside*2+temp4, temp8+LCAR.ItemHeight*3+6, temp4+LCAR.leftside+2, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"190", "", "", 14, True, 6, True, 0,255)
			AddLCAR("R4C9", 0, temp+LCAR.leftside*3+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 14, True, 6, True, 0,255)
			AddLCAR("R4CA", 0, temp+LCAR.leftside*4+temp4*2+7+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 14, True, 6, True, 0,255)
			AddLCAR("R4CB", 0, temp+LCAR.leftside*7+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_LightYellow, LCAR.lcar_button,"", "","", 14,True, 6,True,0,255)
			AddLCAR("R4CC", 0, temp+LCAR.leftside*9+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 14, True, 6, True, 0,255)
			
			AddLCAR("R5C8", 0, temp+LCAR.leftside*3+temp4*2+2, temp8+LCAR.ItemHeight*4+8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "451", "", "", 15, True, 6, True,0,255)'group 15			
			AddLCAR("R5C6", 0, temp+LCAR.leftside, temp8+LCAR.ItemHeight*4+8, temp4 , LCAR.ItemHeight, LCAR.leftside, LCAR.leftside,  LCAR.LCAR_Blue, LCAR.LCAR_MiniButton,"2069", "", "", 15, True, 6, True, 0,255)
			AddLCAR("R5C7", 0, temp+LCAR.leftside*2+temp4, temp8+LCAR.ItemHeight*4+8, temp4+LCAR.leftside+2, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"2034", "", "", 15, True, 6, True, 0,255)
			AddLCAR("R5C9", 0, temp+LCAR.leftside*3+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 15, True, 6, True, 0,255)
			AddLCAR("R5CB", 0, temp+LCAR.leftside*7+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight-1, LCAR.leftside,0,LCAR.LCAR_LightYellow, LCAR.lcar_button,"", "","", 15,True, 6,True,0,255)
			AddLCAR("R5CC", 0, temp+LCAR.leftside*9+temp4*2+2+LCAR.NumberWhiteSpace, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 15, True, 6, True, 0,255)
			
			'sixth column
			temp = temp+LCAR.leftside*10+temp4*2+2+LCAR.NumberWhiteSpace+10
			temp7=LCAR.TextWidth(BG, "MODE SELECT")+10
			AddLCAR("IMPL", 0, temp, 0, temp4*2, temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"IMPULSE SYSTEMS", "", "", 16, True, 9, True, 0,255)'group 16
			AddLCAR("MDS1", 0, temp+temp4*2-temp7, temp1-10, temp7, 11, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 16, True, 6, True, 0,255)
			AddLCAR("MDS2", 0, temp, temp1, temp4*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"MODE SELECT", "", "", 16, True, 6, True, 0,255)
			AddLCAR("C6BT", 0, temp, temp8+LCAR.ItemHeight*5+7 + LCAR.ItemHeight*0.5, temp4*2,LCAR.ItemHeight*0.5-2, 0,0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 16, True, 0, True,0,255)
			AddLCAR("CURV", 0, temp, temp8, temp4, LCAR.ItemHeight*5+8, 22, 2,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, LCAR.ItemHeight*3+6,True,LCAR.ItemHeight,255)
			AddLCAR("BIG1", 0, temp+temp4, temp8, temp4, LCAR.ItemHeight*3+4, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", -1, True, 6, True, 0,255)
			AddLCAR("R4CD", 0, temp+temp4, temp8+LCAR.ItemHeight*3+6, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,LCAR.LCAR_Block, "", "", 17, True, 6, True, 0,255)'group 17
			AddLCAR("R5CD", 0, temp+temp4, temp8+LCAR.ItemHeight*4+8, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"00800", "", "", 18, True, 6, True, 0,255)'group 18
			
			'mini column
			temp = temp+temp4*2+10
			AddLCAR("BLUE", 0, temp, 0, LCAR.leftside*3, temp0, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "", 19, True, 9, True, 0,255)'group 19
			AddLCAR("ORNG", 0, temp, temp1, LCAR.leftside*3, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 19, True, 6, True, 0,255)
			AddLCAR("BIT1", 0, temp+LCAR.leftside*2, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",19, True, 6, True, 0,255)
			AddLCAR("BIT2", 0, temp, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 19, True, 6, True, 0,255)
			AddLCAR("BIT3", 0, temp, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 19, True, 6, True, 0,255)
			AddLCAR("BIT4", 0, temp, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 17, True, 6, True, 0,255)'group 17
			AddLCAR("BIT5", 0, temp+LCAR.leftside*2, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 17, True, 6, True, 0,255)'group 17
			AddLCAR("BIT6", 0, temp, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "", 18, True, 6, True, 0,255)'group 18
			
			'seventh column
			temp = temp+LCAR.leftside*3+10
			AddLCAR("EMRG", 0, temp,0,temp2*2+9+temp11, temp0, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button, "EMERGENCY OVERIDE", "","", -1, False,0,True,2,255)'group 20
			AddLCAR("HNV1", 0, temp, temp1-10, temp7, 11, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 20, True, 6, True, 0,255)
			AddLCAR("HNV2", 0, temp, temp1, temp4*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"HELM/NAVIGATION", "", "", 20, True, 6, True, 0,255)
			AddLCAR("HNV3", 0, temp+temp4*2+10, temp1, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 20, True, 6, True, 0,255)
			
			AddLCAR("BIG2", 0, temp, temp8, temp4, LCAR.ItemHeight*3+4, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "", 21, True, 6, True, 0,255)'group 21
			AddLCAR("BIG3", 0, temp, temp8+LCAR.ItemHeight+2, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,LCAR.LCAR_Block, "", "", 21, True, 6, True, 0,255)
			AddLCAR("R4CE", 0, temp, temp8+LCAR.ItemHeight*3+6, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "", 17, True, 6, True, 0,255)'group 17
			AddLCAR("R5CD", 0, temp, temp8+LCAR.ItemHeight*4+8, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,LCAR.LCAR_Block, "", "", 18, True, 6, True, 0,255)'group 18
			
			AddLCAR("BIT7", 0, temp+temp4+2, temp8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",-1, True, 6, True, 0,255)
			AddLCAR("BIT8", 0, temp+temp4+2, temp8+LCAR.ItemHeight+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",-1, True, 6, True, 0,255)
			AddLCAR("BIT9", 0, temp+temp4+2, temp8+LCAR.ItemHeight*2+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button,"", "", "",-1, True, 6, True, 0,255)
			AddLCAR("BITA", 0, temp+temp4+2, temp8+LCAR.ItemHeight*3+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)'group 17
			AddLCAR("BITB", 0, temp+temp4+2, temp8+LCAR.ItemHeight*4+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Blue, LCAR.LCAR_Button,"", "", "",18, True, 6, True, 0,255)'group 18
			
			temp1=temp+temp4+2+LCAR.leftside*2
			temp3=LCAR.ItemHeight*5+7
			temp5=temp4*2-temp4-2+(temp3/11)
			AddLCAR("ENDP", 0, temp1, temp8,  temp5, temp3, 22, 3,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255)
			
			AddLCAR("C7BT", 0, temp, temp8+LCAR.ItemHeight*5+7 + LCAR.ItemHeight*0.5,		LCAR.leftside*2+ temp4+2+temp5  ,LCAR.ItemHeight*0.5-2, 0,0,  LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 16, True, 0, True,0,255)
		
		Case 27'Voyager conference room
			'align= -6: LCARSeffects5.DrawMiniFrame(BG,Dimensions.currX,Dimensions.currY,  Element.LWidth ,  Dimensions.offX ,Dimensions.offY, Element.RWidth, Element.Opacity.Current)
			'RefreshesLive=True
			temp = 50 * LCAR.GetScalemode 'Divider width
			temp2 = (msdHeight + temp) * 3'width of screen
			temp4= 10'space between frame and objects
			
			AddLCAR("MF1", 0,    0, 0, msdHeight+temp+temp4, msdHeight, temp, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"SYSTEMS INTEGRITY 0385", "", "",-1, True, 0, True, -6,255)
			AddLCAR("VOY3D", 0,  temp+temp4,LCAR.ItemHeight, msdHeight,msdHeight-temp*2,            0,        35,       2,        LCAR.LCAR_3Dmodel, "", "voyager.3d", "", -1, False, 35,True, 1,255)
			
			temp3=temp+msdHeight+temp4*2
			AddLCAR("MF2", 0,   temp3, 0, msdHeight+temp+temp4, msdHeight, temp, 1,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"SUBSPACE SCAN 11555", "", "",-1, True, 0, True, -6,255)
			AddLCAR("SensorGrid",  0,   temp3+temp+temp4,LCAR.ItemHeight,  msdHeight ,msdHeight-temp*2,  55,95, LCAR.LCAR_DarkBlue , LCAR.LCAR_SensorGrid, "",  "", "0", 2,    False, 0,  True ,20,0)
			
			temp3=temp3 + temp+msdHeight+temp4*2
			AddLCAR("MF3", 0,   temp3, 0, msdHeight+temp+temp4, msdHeight, temp, 2,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"SCAN ANALYSIS 27186", "", "",-1, True, 0, True, -6,255)
			AddLCAR("AlertStatus", 0, temp3+temp+temp4,LCAR.ItemHeight,  msdHeight ,msdHeight-temp*2, 18, 0,  LCAR.LCAR_Orange, LCAR.LCAR_List, "", "","", 0, False,0,True,0,255)
		
		Case 28'OPS
			temp0 = LCAR.ListItemsHeight(4)'height of top half
			temp1 = msdHeight -LCAR.ListItemsHeight(8) + LCAR.LCARCornerElbow2.height'Y of bottom half
			temp4= LCAR.leftside*3 + LCAR.TextWidth(BG,"20150")'width of the minibuttons
			If temp0>100 Or temp4>100 Then ElbowSize = Min(temp0,temp4*2) * 0.5 Else ElbowSize=LCAR.LCARCornerElbow2.height'     LCAR.InnerElbowSize2(temp11,  temp2, False)
			If temp1 < temp0 + ElbowSize Then temp1 = temp0 + ElbowSize 'force it to be below the upper half
			temp3=msdHeight-temp1'height of bottom
			temp6 = temp1+ LCAR.ListItemsHeight(7)-2 + (LCAR.ItemHeight*0.5)'bottom was temp1+LCAR.ItemHeight*7.5
			
			temp2 = LCAR.leftside * 4.5 + 2 + temp4 + LCAR.NumberWhiteSpace'width of column 1
			
			'column 1
			AddLCAR("EMERG", 0,   LCAR.leftside *2,0,temp2-(LCAR.leftside *2), temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button, "EMERGENCY OVERRIDE", "","", -1, True,0,True,1,255)'group -1
			
			AddLCAR("ENG", 0, LCAR.leftside * 1.75 , temp1, temp2-(LCAR.leftside *1.75), LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"ENGINEERING STATUS", "", "",-1, True, 6, True, 0,255)
			
			AddLCAR("BT28A", 0, LCAR.leftside * 1.5 , temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",0, True, 6, True, 0,255)'group 0
			AddLCAR("BT28B", 0, LCAR.leftside * 2.5+temp4-2, temp1+LCAR.ItemHeight*2+2, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "28", "", "", 0, True, 6, True,0,255)		
			AddLCAR("BT28C", 0, LCAR.leftside * 2.5+temp4+ LCAR.NumberWhiteSpace , temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",0, True, 6, True, 0,255)
			AddLCAR("BT28D", 0, LCAR.leftside * 3.5+temp4+ LCAR.NumberWhiteSpace+2, temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",0, True, 6, True, 0,255)
			
			AddLCAR("BT123A", 0, LCAR.leftside * 1.25 ,  		temp1+LCAR.ItemHeight*3+4, LCAR.leftside*1.25, LCAR.ItemHeight, LCAR.leftside*1.25, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",1, True, 6, True, 0,255)'group 1
			AddLCAR("BT123B", 0, LCAR.leftside * 2.5+6 , 		temp1+LCAR.ItemHeight*3+4, temp4-6, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"5820", "", "",1, True, 6, True, 0,255)
			AddLCAR("BT123C", 0, LCAR.leftside * 2.5+temp4-2, 	temp1+LCAR.ItemHeight*3+4, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "123", "", "", 1, True, 6, True,0,255)			
			AddLCAR("BT123D", 0, LCAR.leftside * 2.5+temp4+ LCAR.NumberWhiteSpace , temp1+LCAR.ItemHeight*3+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",1, True, 6, True, 0,255)
			AddLCAR("BT123E", 0, LCAR.leftside * 3.5+temp4+ LCAR.NumberWhiteSpace+2, temp1+LCAR.ItemHeight*3+4, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",1, True, 6, True, 0,255)
			
			AddLCAR("BT29A", 0, LCAR.leftside ,  		temp1+LCAR.ItemHeight*4+6, LCAR.leftside*1.5, LCAR.ItemHeight, LCAR.leftside*1.5, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",2, True, 6, True, 0,255)'group 2
			AddLCAR("BT29B", 0, LCAR.leftside * 2.5+temp4-2, 	temp1+LCAR.ItemHeight*4+6, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "29", "", "", 2, True, 6, True,0,255)			
			AddLCAR("BT29C", 0, LCAR.leftside * 2.5+temp4+ LCAR.NumberWhiteSpace , temp1+LCAR.ItemHeight*4+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",2, True, 6, True, 0,255)
			
			AddLCAR("BT523A", 0, LCAR.leftside * 0.87 ,  		temp1+LCAR.ItemHeight*5+8, LCAR.leftside*1.63, LCAR.ItemHeight, LCAR.leftside*1.63, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",3, True, 6, True, 0,255)'group 3
			AddLCAR("BT523B", 0, LCAR.leftside * 2.5+6 , 		temp1+LCAR.ItemHeight*5+8, temp4-6, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"532", "", "",3, True, 6, True, 0,255)
			AddLCAR("BT523C", 0, LCAR.leftside * 2.5+temp4-2, 	temp1+LCAR.ItemHeight*5+8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "523", "", "", 3, True, 6, True,0,255)			
			AddLCAR("BT523D", 0, LCAR.leftside * 2.5+temp4+ LCAR.NumberWhiteSpace , temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",3, True, 6, True, 0,255)
			AddLCAR("BT523E", 0, LCAR.leftside * 3.5+temp4+ LCAR.NumberWhiteSpace+2, temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",3, True, 6, True, 0,255)
			
			AddLCAR("BT523A", 0, LCAR.leftside * 2.5+6 , 		temp1+LCAR.ItemHeight*6+10, temp4-6, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"235", "", "",4, True, 6, True, 0,255)'group 4
			AddLCAR("BT523B", 0, LCAR.leftside * 2.5+temp4-2, 	temp1+LCAR.ItemHeight*6+10, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "621", "", "", 4, True, 6, True,0,255)			
			AddLCAR("BT523C", 0, LCAR.leftside * 3.5+temp4+ LCAR.NumberWhiteSpace+2, temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",4, True, 6, True, 0,255)
			
			AddLCAR("BTM0", 0,   LCAR.leftside*0.5, temp6,temp2-LCAR.leftside*0.5, LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			'column 2
			temp5=temp2+LCAR.leftside'X coordinate of column 2
			
			AddLCAR("WARP", 0, temp5 , 		0, temp2*1.5, temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"WARP DRIVE SYSTEMS", "", "",-1, True, 9, True, 0,255)
			
			AddLCAR("WARP2", 0, temp5 , 		temp1, temp2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",5, True, 9, True, 0,255)'group 5
			AddLCAR("WARP3", 0, temp5 +temp2+LCAR.leftside, 		temp1, temp2 * 0.5 -LCAR.leftside , LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",5, True, 9, True, 0,255)

			AddLCAR("RNDNUM1", 0, temp5, temp1+LCAR.ItemHeight*2+2, temp2*0.5+LCAR.leftside, LCAR.ListItemsHeight(1), 14,1,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "ATMOSPHERIC PROCESS", "","", 30,True, 0,True,-1,255)
			AddLCAR("RNDNUM2", 0, temp5+temp2*0.5+LCAR.leftside*2, temp1+LCAR.ItemHeight*2+2, temp2*0.5-LCAR.leftside*2, LCAR.ListItemsHeight(1), 14,1,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "00803", "","", 30,True, 0,True,-2,255)
			AddLCAR("RNDNUM3", 0, temp5 +temp2+LCAR.leftside, temp1+LCAR.ItemHeight*2+2, temp2 * 0.5 -LCAR.leftside, LCAR.ListItemsHeight(1), 14,1,  LCAR.LCAR_LightBlue, LCAR.LCAR_LWP, "00156", "","", 30,True, 0,True,-3,255)
			
			AddLCAR("RNDNUM4", 0, temp5, temp1+LCAR.ItemHeight*3+4 , temp2*0.5+LCAR.leftside, LCAR.ListItemsHeight(2.5), 1,0, LCAR.LCAR_White, LCAR.LCAR_RndNumbers, "", "","", 30,True, 0,True,0,255)'group 30
			AddLCAR("RNDNUM5", 0, temp5+temp2*0.5+LCAR.leftside*2, temp1+LCAR.ItemHeight*3+4 ,temp2*0.5-LCAR.leftside*2, LCAR.ListItemsHeight(2.5), 2,0, LCAR.LCAR_White, LCAR.LCAR_RndNumbers, "", "","", 30,True, 0,True,0,255)'group 30
			AddLCAR("RNDNUM6", 0, temp5 +temp2+LCAR.leftside, temp1+LCAR.ItemHeight*3+4 , temp2 * 0.5 -LCAR.leftside, LCAR.ListItemsHeight(2.5), 3,0, LCAR.LCAR_White, LCAR.LCAR_RndNumbers, "", "","", 30,True, 0,True,0,255)'group 30
			
			AddLCAR("BTM1", 0,   temp5, temp6,temp2, LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			'column 3
			temp5=temp5+temp2*1.5+LCAR.leftside'X coordinate of column 3
			
			temp2=Max(Max(LCAR.TextWidth(BG, "OPERATIONAL PRIORITIES"),LCAR.TextWidth(BG, "LCARS MODE SELECT")),temp4*2)+10
			AddLCAR("OPS1", 0, temp5+temp4-LCAR.leftside, 		0, temp2, temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"OPERATIONAL PRIORITIES", "", "",-1, True, 8, True, 0,255)
			AddLCAR("LMS0", 0, temp5 , 		temp1-LCAR.ItemHeight*0.5, temp4-LCAR.leftside, LCAR.ItemHeight*1.5, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",6, True, 9, True, 0,255)'group 6
			AddLCAR("LMS1", 0, temp5+temp4-2-LCAR.leftside, temp1, temp2+2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"LCARS MODE SELECT", "", "",6, True, 9, True, 0,255)
			'AddLCAR("LMS2", 0,   temp5, temp1+LCAR.ItemHeight*2+2,temp4-LCAR.leftside, LCAR.ListItemsHeight(5)-2, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",-1, True, 6, True, 0,255)
			AddLCAR("BLOCKA", 0, temp5, temp1+LCAR.ItemHeight*2+2, temp4-LCAR.leftside, LCAR.ListItemsHeight(5)-2, 28,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_LWP,  "01001", "", "", 6, True, LCAR.ItemHeight*0.5, True, 0,255)
			
			AddLCAR("BTM2", 0,   temp5, temp6,temp4-LCAR.leftside, LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			temp5=temp5+temp4'still column 3
			
			AddLCAR("BT125A", 0, temp5, temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",7, True, 6, True, 0,255)'group 7
			AddLCAR("BT125B", 0, temp5+LCAR.leftside*2, 		temp1+LCAR.ItemHeight*2+2, temp4-LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"125", "", "",7, True, 4, True, 0,255)
			AddLCAR("BT125C", 0, temp5+temp4, 		temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",7, True, 4, True, 0,255)
			
			AddLCAR("BT593A", 0, temp5+LCAR.leftside*2, 		temp1+LCAR.ItemHeight*3+4, temp4-LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"593", "", "",8, True, 4, True, 0,255)'group 8
			AddLCAR("BT593B", 0, temp5+temp4, 		temp1+LCAR.ItemHeight*3+4, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",8, True, 4, True, 0,255)
			
			AddLCAR("BT063A", 0, temp5, temp1+LCAR.ItemHeight*4+6, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",9, True, 6, True, 0,255)'group 9
			AddLCAR("BT063B", 0, temp5+LCAR.leftside*2, 		temp1+LCAR.ItemHeight*4+6, temp4-LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"063", "", "",9, True, 4, True, 0,255)
			AddLCAR("BT063C", 0, temp5+temp4, 		temp1+LCAR.ItemHeight*4+6, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",9, True, 4, True, 0,255)
			
			AddLCAR("BT58A", 0, temp5, temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",10, True, 6, True, 0,255)'group 10
			AddLCAR("BT58B", 0, temp5+LCAR.leftside*2, 		temp1+LCAR.ItemHeight*5+8, temp4-LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"58", "", "",10, True, 4, True, 0,255)
			AddLCAR("BT58C", 0, temp5+temp4, 		temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",10, True, 4, True, 0,255)
			
			AddLCAR("BT0523A", 0, temp5, temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",11, True, 6, True, 0,255)'group 11
			AddLCAR("BT0523B", 0, temp5+LCAR.leftside*2, 		temp1+LCAR.ItemHeight*6+10, temp4-LCAR.leftside*2, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"0523", "", "",11, True, 4, True, 0,255)
			AddLCAR("BT0523C", 0, temp5+temp4, 		temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",11, True, 4, True, 0,255)
			
			AddLCAR("BTM3", 0,   temp5, temp6,   temp2- LCAR.leftside   , LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			'column 4
			temp5=temp5+temp2
			
			AddLCAR("SQRE", 0, temp5, 0,  temp0, temp0, 28, 1,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255)
			
			temp11 = temp0 * LCARSeffects.DpadCenter *1.6 'width of center
			temp12 = (temp0 * 0.5) - (temp11*0.5)'width of left/right side of center
			AddLCAR("DPDA", 0, temp5, temp1, temp12, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",12, True, 9, True, 0,255)'group 12
			AddLCAR("DPDB", 0, temp5+temp0-temp12, temp1, temp12, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",12, True, 9, True, 0,255)
			AddLCAR("DPDC", 0,  temp5, temp1+LCAR.ItemHeight*2+2, temp0,temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Dpad, "","","", 12 ,True, 0,True, 0,0)
			
			AddLCAR("BTM4", 0,   temp5, temp6,   temp0   , LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			'column 5
			temp5=temp5+LCAR.leftside+temp0
			temp12=temp4-LCAR.leftside+5
			temp11=temp12+LCAR.leftside * 4+4+temp4+LCAR.NumberWhiteSpace
			temp10=LCAR.TextWidth(BG, "MANAGEMENT")+20
			
			AddLCAR("OPS2", 0, temp5, 0, temp11+LCAR.leftside+temp10,  temp1-LCAR.ItemHeight*0.25, temp10, temp0, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "OPERATIONS MANAGEMENT", "", "", -1, True, -7,True, 1,255)
			AddLCAR("OPS3", 0, temp5+temp12+LCAR.leftside * 3+4, temp1+LCAR.ItemHeight*2+2, temp11+temp10-(temp12+LCAR.leftside * 2+4), LCAR.ListItemsHeight(6)-2, temp10, LCAR.ItemHeight*0.5, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "OPERATIONS" & CRLF & "MANAGEMENT", "", "", -1, True, 1,True, 3,255)
			'bottom right align = 3
			
			
			AddLCAR("LCARS1", 0, temp5, temp1, temp11, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",18, True, 9, True, 0,255)'group 18
			AddLCAR("LCARS1", 0, temp5+temp11+LCAR.leftside, temp1, temp10, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"LCARS", "", "",18, True, 4, True, 0,255)
			
			AddLCAR("BT2325A", 0, temp5+temp12+LCAR.leftside * 2-4 , temp1+LCAR.ItemHeight*2+2, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",19, True, 6, True, 0,255)'group 19
			AddLCAR("BT2325B", 0, temp5+temp12+LCAR.leftside * 3+4, temp1+LCAR.ItemHeight*2+2, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_Button,"23", "", "",19, True, 6, True, 0,255)
			AddLCAR("BT2325C", 0, temp5+temp12+LCAR.leftside * 3+4+temp4, 	temp1+LCAR.ItemHeight*2+2, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Yellow, LCAR.LCAR_Textbox, "25", "", "", 19, True, 6, True,0,255)			
			AddLCAR("BT2325D", 0, temp5+temp12+LCAR.leftside * 3+4+temp4+LCAR.NumberWhiteSpace, 	temp1+LCAR.ItemHeight*2+2, LCAR.leftside , LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_Button, "", "", "", 19, True, 6, True,0,255)			

			AddLCAR("BT988A", 0, temp5,  		temp1+LCAR.ItemHeight*3+4, temp4, LCAR.ItemHeight,temp4, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",13, True, 6, True, 0,255)'group 13
			AddLCAR("BT988B", 0, temp5+temp12, temp1+LCAR.ItemHeight*3+4, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"988", "", "",13, True, 6, True, 0,255)
			AddLCAR("BT988D", 0, temp5+temp12+LCAR.leftside * 3+4, temp1+LCAR.ItemHeight*3+4, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"2566", "", "",13, True, 6, True, 0,255)
			AddLCAR("BT988E", 0, temp5+temp12+LCAR.leftside * 3+4+temp4, 	temp1+LCAR.ItemHeight*3+4, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "036", "", "", 13, True, 6, True,0,255)			
			
			AddLCAR("BT3852A", 0, temp5,  		temp1+LCAR.ItemHeight*4+6, temp4, LCAR.ItemHeight, temp4, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",14, True, 3, True, 0,255)'group 14
			AddLCAR("BT3852B", 0, temp5+temp12,temp1+LCAR.ItemHeight*4+6, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"3852", "", "",14, True, 6, True, 0,255)
			AddLCAR("BT3852C", 0, temp5+temp12+LCAR.leftside * 2-4 , temp1+LCAR.ItemHeight*4+6, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",14, True, 6, True, 0,255)
			AddLCAR("BT3852D", 0, temp5+temp12+LCAR.leftside * 3+4, temp1+LCAR.ItemHeight*4+6, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button,"4788", "", "",14, True, 6, True, 0,255)
			AddLCAR("BT3852E", 0, temp5+temp12+LCAR.leftside * 3+4+temp4, 	temp1+LCAR.ItemHeight*4+6, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "69", "", "", 14, True, 6, True,0,255)			
			AddLCAR("BT3852F", 0, temp5+temp12+LCAR.leftside * 3+4+temp4+LCAR.NumberWhiteSpace, 	temp1+LCAR.ItemHeight*4+6, LCAR.leftside , LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Button, "", "", "", 14, True, 6, True,0,255)			
			
			AddLCAR("BT59A", 0, temp5,  		temp1+LCAR.ItemHeight*5+8, temp4, LCAR.ItemHeight, temp4, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"", "", "",15, True, 3, True, 0,255)'group 15
			AddLCAR("BT59B", 0, temp5+temp12,temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"59", "", "",15, True, 6, True, 0,255)
			AddLCAR("BT59C", 0, temp5+temp12+LCAR.leftside * 2-4 , temp1+LCAR.ItemHeight*5+8, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",15, True, 6, True, 0,255)
			AddLCAR("BT59D", 0, temp5+temp12+LCAR.leftside * 3+4, temp1+LCAR.ItemHeight*5+8, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"6985", "", "",15, True, 6, True, 0,255)
			AddLCAR("BT59E", 0, temp5+temp12+LCAR.leftside * 3+4+temp4, 	temp1+LCAR.ItemHeight*5+8, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "340", "", "", 15, True, 6, True,0,255)			
			AddLCAR("BT59F", 0, temp5+temp12+LCAR.leftside * 3+4+temp4+LCAR.NumberWhiteSpace, 	temp1+LCAR.ItemHeight*5+8, LCAR.leftside , LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 15, True, 6, True,0,255)			
			
			AddLCAR("BT8220A", 0, temp5,  		temp1+LCAR.ItemHeight*6+10, temp4, LCAR.ItemHeight, temp4, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",16, True, 3, True, 0,255)'group 16
			AddLCAR("BT8220B", 0, temp5+temp12,temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, 0, LCAR.leftside,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"8220", "", "",16, True, 6, True, 0,255)
			AddLCAR("BT8220C", 0, temp5+temp12+LCAR.leftside * 2-4 , temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button,"", "", "",16, True, 6, True, 0,255)
			AddLCAR("BT8220D", 0, temp5+temp12+LCAR.leftside * 3+4+temp4, 	temp1+LCAR.ItemHeight*6+10, LCAR.NumberWhiteSpace , LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "463", "", "", 16, True, 6, True,0,255)			
			AddLCAR("BT8220E", 0, temp5+temp12+LCAR.leftside * 3+4+temp4+LCAR.NumberWhiteSpace, 	temp1+LCAR.ItemHeight*6+10, LCAR.leftside , LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 16, True, 6, True,0,255)			
			
			AddLCAR("BTM5A", 0,   temp5, temp6-LCAR.ItemHeight*0.25,   temp12+LCAR.leftside+5   , LCAR.ItemHeight*0.4, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 3, True, 0,255)
			AddLCAR("BTM5B", 0,   temp5, temp6,   temp4+LCAR.leftside*2   , LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
			
			'column 6
			temp5=temp5+temp11+LCAR.leftside*2+temp10
			temp7 = BG.MeasureStringWidth("00000", LCAR.LCARfont, LCAR.NumberTextSize)
			temp8 = temp4 + LCAR.leftside*3 'LCAR.TextWidth(BG, "COMMUNICATIONS")
			AddLCAR("BT72001A", 0, temp5+temp4,  		0, LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",20, True, 3, True, 0,255)'group 20
			AddLCAR("BT72001B", 0, temp5+temp4+LCAR.leftside, 	0, temp7 , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "72001", "", "", 20, True, 6, True,0,255)	
			AddLCAR("BT72001C", 0, temp5+temp4+LCAR.leftside+temp7,  		0, temp8, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"DEPARTMENTAL", "", "",20, True, 4, True, 0,255)
			
			AddLCAR("BT020A", 0, temp5+temp4,  LCAR.ListItemsHeight(1), LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",21, True, 3, True, 0,255)'group 21
			AddLCAR("BT020B", 0, temp5+temp4+LCAR.leftside, LCAR.ListItemsHeight(1), temp7 , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightBlue, LCAR.LCAR_Textbox, "020", "", "", 21, True, 6, True,0,255)	
			AddLCAR("BT020C", 0, temp5+temp4+LCAR.leftside+temp7, LCAR.ListItemsHeight(1), temp8, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightBlue, LCAR.LCAR_Button,"STATUS", "", "",21, True, 4, True, 0,255)
			
			AddLCAR("BT51906A", 0, temp5+temp4,  LCAR.ListItemsHeight(2), LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",22, True, 3, True, 0,255)'group 22
			AddLCAR("BT51906B", 0, temp5+temp4+LCAR.leftside, LCAR.ListItemsHeight(2), temp7 , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "51906", "", "", 22, True, 6, True,0,255)	
			AddLCAR("BT51906C", 0, temp5+temp4+LCAR.leftside+temp7, LCAR.ListItemsHeight(2), temp8, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"COMMUNICATIONS", "", "",22, True, 4, True, 0,255)
			
			AddLCAR("BT40776A", 0, temp5+temp4,  LCAR.ListItemsHeight(3), LCAR.leftside, LCAR.ItemHeight, LCAR.leftside, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",23, True, 3, True, 0,255)'group 23
			AddLCAR("BT40776B", 0, temp5+temp4+LCAR.leftside, LCAR.ListItemsHeight(3), temp7 , LCAR.NumberTextSize, -1,0, LCAR.LCAR_LightYellow, LCAR.LCAR_Textbox, "40776", "", "", 23, True, 6, True,0,255)	
			AddLCAR("BT40776C", 0, temp5+temp4+LCAR.leftside+temp7, LCAR.ListItemsHeight(3), temp8, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"MISSION STATUS", "", "",23, True, 4, True, 0,255)
			
			AddLCAR("DAMNYOUOKUDA1", 0, temp5+temp4+LCAR.leftside*2+temp7,temp1-LCAR.ItemHeight*0.5,    temp8-LCAR.leftside, LCAR.ItemHeight,           0,     0,                   LCAR.LCAR_LightYellow, LCAR.LCAR_Button, "","", "", -1, True, 0, False,  0, 255)
			AddLCAR("DAMNYOUOKUDA2", 0, temp5, temp1,                           temp8+temp4+LCAR.leftside+temp7, LCAR.ListItemsHeight(6)-2, temp4, LCAR.ItemHeight,     LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "", "", "", -1, True, 0, False,  0, 255)
			AddLCAR("DAMNYOUOKUDA3", 0, temp5, temp1+LCAR.ListItemsHeight(6)-10, temp8+temp4+LCAR.leftside+temp7, LCAR.ItemHeight*2+8,         temp4, LCAR.ItemHeight*0.5, LCAR.LCAR_LightYellow, LCAR.LCAR_Elbow, "", "", "", -1, True, 0, False,  2, 255)
			
			AddLCAR("BLOCKB", 0, temp5+temp4+LCAR.leftside, temp1+LCAR.ItemHeight*2+2, temp4-LCAR.leftside, LCAR.ListItemsHeight(5)-2, 28,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_LWP,  "00001", "", "", -1, True, LCAR.ItemHeight*0.75, True, 1,255)
			
			AddLCAR("BT2382A",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*2+2,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "",  "", "", 24, True, 0, True,0,255)'group 24
			AddLCAR("BT2382B",  0, temp5+temp4*2+LCAR.leftside*3, temp1+LCAR.ItemHeight*2+2,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "2382",  "", "", 24, True, 4, True,0,255)
			AddLCAR("BT2382C",  0, temp5+temp4*3+LCAR.leftside*2, temp1+LCAR.ItemHeight*2+2,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "",  "", "", 24, True, 0, True,0,255)
			
			AddLCAR("BT948A",  0, temp5+temp4*2+LCAR.leftside*3, temp1+LCAR.ItemHeight*3+4,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "948",  "", "", 25, True, 4, True,0,255)'group 25
			AddLCAR("BT948B",  0, temp5+temp4*3+LCAR.leftside*2, temp1+LCAR.ItemHeight*3+4,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "",  "", "", 25, True, 0, True,0,255)
			
			AddLCAR("BT2001A",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*4+6,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightYellow, 	LCAR.LCAR_Button, "",  "", "", -1, True, 0, True,0,255)'group 26
			AddLCAR("BT2001B",  0, temp5+temp4*2+LCAR.leftside*3, temp1+LCAR.ItemHeight*4+6,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "2001",  "", "", 26, True, 4, True,0,255)
			AddLCAR("BT2001C",  0, temp5+temp4*3+LCAR.leftside*2, temp1+LCAR.ItemHeight*4+6,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "",  "", "", 26, True, 0, True,0,255)
			
			AddLCAR("BT80A",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*5+8,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "",  "", "", 27, True, 0, True,0,255)'group 27
			AddLCAR("BT80B",  0, temp5+temp4*2+LCAR.leftside*3, temp1+LCAR.ItemHeight*5+8,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "80",  "", "", 27, True, 4, True,0,255)
			AddLCAR("BT80C",  0, temp5+temp4*3+LCAR.leftside*2, temp1+LCAR.ItemHeight*5+8,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "",  "", "", 27, True, 0, True,0,255)
			
			AddLCAR("BT2034A",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*6+10, LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "",  "", "", 28, True, 0, True,0,255)'group 28
			AddLCAR("BT2034B",  0, temp5+temp4*2+LCAR.leftside*3, temp1+LCAR.ItemHeight*6+10,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "2034",  "", "", 28, True, 4, True,0,255)
			AddLCAR("BT2034C",  0, temp5+temp4*3+LCAR.leftside*2, temp1+LCAR.ItemHeight*6+10,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "",  "", "", 28, True, 0, True,0,255)
			
			'column 7
			temp5=temp5+temp4+LCAR.leftside*2+temp7+temp8
			AddLCAR("COMMSA", 0, temp5,0, temp4+LCAR.leftside,temp0, 0,0, LCAR.LCAR_LightBlue,LCAR.LCAR_Button,"", "", "",29, True, 3, True, 0,255)
			AddLCAR("COMMSB", 0, temp5, temp1, temp4+LCAR.leftside, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_LightYellow, LCAR.LCAR_Button,"", "", "",29, True, 9, True, 0,255)
			
			AddLCAR("BT52",  0, temp5, temp1+LCAR.ItemHeight*2+2,  temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_MiniButton, "52",  "", "", 24, True, 6, True,0,255)
			AddLCAR("BT65",  0, temp5, temp1+LCAR.ItemHeight*3+4,  temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightYellow, 	LCAR.LCAR_MiniButton, "65",  "", "", 25, True, 6, True,0,255)
			AddLCAR("BT000", 0, temp5, temp1+LCAR.ItemHeight*4+6,  temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, 		LCAR.LCAR_MiniButton, "000", "", "", 26, True, 6, True,0,255)
			AddLCAR("BT350", 0, temp5, temp1+LCAR.ItemHeight*6+10, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 	LCAR.LCAR_MiniButton, "354", "", "", 28, True, 6, True,0,255)
			
			'column 8
			temp2 = (LCAR.leftside * 3.5 + 2 + temp4 + LCAR.NumberWhiteSpace)*1.5-LCAR.leftside*2'width of column 1
			temp5=temp5+temp4+LCAR.leftside*2

			AddLCAR("COMMSC", 0,  temp5,0,temp2, temp0, 0, 0,  LCAR.LCAR_Yellow, LCAR.LCAR_Button, "COMMUNICATIONS", "","", -1, True,0,True,2,255)
			AddLCAR("ATSQ1", 0,  temp5, temp1-LCAR.ItemHeight*0.5, temp4, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"", "", "",29, True, -1, True, 0,255)'group 29
			AddLCAR("ATSQ2", 0,  temp5, temp1, temp2-LCAR.leftside*0.5, LCAR.ItemHeight, 0, 0,  LCAR.LCAR_Orange, LCAR.LCAR_Button,"AUTOSEQUENCE SELECT", "", "",29, True, 9, True, 0,255)
			AddLCAR("ATSQ3", 0, temp5+temp2+LCAR.leftside*0.5, temp1, LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",29, True, -1, True, 0,255)
			
			AddLCAR("BLOCKC", 0, temp5, temp1+LCAR.ItemHeight*2+2, temp4-LCAR.leftside, LCAR.ListItemsHeight(5)-2, 28,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_LWP,  "11110", "", "", -1, True, LCAR.ItemHeight*0.75, True, 7,255)
			
			AddLCAR("BT2382D",  0, temp5+temp4, temp1+LCAR.ItemHeight*2+2,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightYellow, 		LCAR.LCAR_Button, "",  "", "", 24, True, 0, True,0,255)'group 24
			AddLCAR("BT2382E",  0, temp5+temp4+LCAR.leftside*2, temp1+LCAR.ItemHeight*2+2,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "753",  "", "", 24, True, 4, True,0,255)
			AddLCAR("BT2382F",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*2+2,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_Orange, 		LCAR.LCAR_Button, "",  "", "", 24, True, 0, True,0,255)
			
			AddLCAR("BT948C",  0, temp5+temp4, temp1+LCAR.ItemHeight*3+4,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "",  "", "", 25, True, 0, True,0,255)'group 25
			
			AddLCAR("BT2001D",  0, temp5+temp4, temp1+LCAR.ItemHeight*4+6,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "",  "", "", 26, True, 0, True,0,255)'group 26
			AddLCAR("BT2001E",  0, temp5+temp4+LCAR.leftside*2, temp1+LCAR.ItemHeight*4+6,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightYellow, 		LCAR.LCAR_Button, "6324",  "", "", 26, True, 4, True,0,255)
			AddLCAR("BT2001F",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*4+6,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_LightYellow, 		LCAR.LCAR_Button, "",  "", "", 26, True, 0, True,0,255)
			
			AddLCAR("BT80D",  0, temp5+temp4, temp1+LCAR.ItemHeight*5+8,  LCAR.leftside, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "",  "", "", 27, True, 0, True,0,255)'group 27
			AddLCAR("BT80E",  0, temp5+temp4+LCAR.leftside*2, temp1+LCAR.ItemHeight*5+8,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "6267",  "", "", 27, True, 4, True,0,255)
			AddLCAR("BT80F",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*5+8,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_Yellow, 		LCAR.LCAR_Button, "",  "", "", 27, True, 0, True,0,255)
			
			AddLCAR("BT2034D",  0, temp5+temp4+LCAR.leftside*2, temp1+LCAR.ItemHeight*6+10,  temp4-LCAR.leftside+2, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "0694",  "", "", 28, True, 4, True,0,255)'group 28
			AddLCAR("BT2034E",  0, temp5+temp4*2+LCAR.leftside, temp1+LCAR.ItemHeight*6+10,  LCAR.leftside, LCAR.ItemHeight, 0,LCAR.leftside, LCAR.LCAR_LightBlue, 		LCAR.LCAR_Button, "",  "", "", 28, True, 0, True,0,255)
				
			AddLCAR("ENDP", 0, temp5+temp2-LCAR.leftside, temp1+LCAR.ItemHeight*2+2,  temp4, LCAR.ListItemsHeight(5)-2, 22, 3,  LCAR.LCAR_DarkOrange, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255)
			
			AddLCAR("BTM6", 0, temp5, temp6,   temp2-LCAR.leftside+temp4   , LCAR.ItemHeight*0.5, 0, 0,  LCAR.LCAR_DarkYellow, LCAR.LCAR_Button,"", "", "",17, True, 6, True, 0,255)
		
		Case 33,34,48' TOS,ENT,ENT-B
			LCARSeffects3.DeclareTOSPage(-1)
			temp7=(50*LCAR.GetScalemode)
			Select Case ConsoleID
				Case 33'TOS Bridge
					temp11 = LCAR.LCAR_TOS
				Case 34'NX01 Bridge
					temp11 = LCAR.LCAR_ENT
					temp4= LCARSeffects2.Images(0).Width * LCAR.GetScalemode * 0.4'width of sliver
				Case 48'Movie era/ENT-B Bridge
					temp11 = LCAR.LCAR_TMP
			End Select
			
			temp0 = BridgePanels
			If PreviewMode And Main.ShowSubBridges Then temp0 = 1
			
			For temp = temp0 To 1 Step -1
				temp2 = LCARSeffects3.RandomTOSpage(temp, temp11)'DeclareTOSPage(-2)
				If temp2 > -1 And temp2 <> 999 Then 
					temp6= LCARSeffects3.TOSpageWidth(temp2)
					temp3 = temp6* msdWidth
					temp5 = LCARSeffects3.DeclareTOSPage(temp2)
					Log("NEW TOSPAGE: " & temp2 & " " & temp3 & " " & temp5)
					If ConsoleID = 33 Then'TOS
						Select Case temp2 
							Case 18'moire
								AddLCAR("Moire", 0, temp4,0,temp3,-1,  0,0,LCAR.lcar_orange, LCAR.TOS_Moires, "", "", "",   0, True,  0 ,True,  0,255)
							Case 19'tactical 2
								LCARSeffects5.RandomTactical
								AddLCAR("TAC2", 0,  temp4,0,temp3,-1,  1,1,    0, LCAR.LCAR_Tactical2, "","", "",  -1, True, -1, True, 1, 255)
							Case Else'button grids
								AddLCAR("TOSP", 1,      	temp4,0, temp3, -1,   temp5, temp5, 		0, LCAR.TOS_Button, "", "", "", -1, True,  0, True, -2, 255)
						End Select
					Else If ConsoleID = 34 Then'NX01
						LCARSeffects3.AddENTpage(temp4, 0, temp3, msdHeight, temp2)
					Else 'If ConsoleID = 48 Then'ENT-B
						LCARSeffects7.AddENTBpage(temp4, 0, temp3, msdHeight, temp2)
					End If
					temp4 = temp4 + temp3 + temp7
					If temp6>1 Then temp = temp + (temp6-1)
				End If
			Next
			
		Case 36' Transporter 2						'Textalign: 0 has flat, 1 no flat, 2 wide, Align: 0 north, 1 east 2 south 3 west
			temp=API.iif(Landscape, 4, 8)'whitespace
			temp0=LCAR.TextWidth(BG,"7200")
			
			'first line
			AddLCAR("1A", 0,  0,0, LCAR.ItemHeight*2, LCAR.ItemHeight*2-LCAR.ListitemWhiteSpace, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Bit, "","","",0, True, 0, True, 1, 255)
			tempstr = "TRANSPORTER SYSTEM"
			temp2=API.GetTextHeight(BG, LCAR.ItemHeight*2, tempstr, LCAR.LCARfont)'textsize
			temp3=BG.MeasureStringWidth(tempstr,LCAR.LCARfont,temp2)'textwidth
			AddLCAR("1B", 0,  LCAR.ItemHeight*2+temp*2,0, temp3, temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, tempstr,"","",0, True, 12, True, 0, 255)
			tempstr = "MOLECULAR IMAGING SCANNER"
			temp2=LCAR.ItemHeight* API.iif(Landscape, 4.5, 6) + temp *2 'height of bar
			temp4= BG.MeasureStringWidth(tempstr, LCAR.LCARfont, LCAR.Fontsize)*1.25 'width of bar
			temp11=LCAR.ItemHeight*2+temp+temp3+temp*2+temp6*1.5
			AddLCAR("1C", 0, temp11,0, temp3*2, temp2, temp4,LCAR.ItemHeight*2, LCAR.LCAR_DarkYellow, LCAR.LCAR_Elbow, tempstr,"","",0, True, 7, True,  1, 255)
			temp11=temp11+temp3*2-temp4'X2
			
			'second line
			temp5 = Floor(temp4*2 / 7.5)*7.5'width of bar
			temp9=temp3*1.5'width of entire bar
			AddLCAR("2A", 0, LCAR.ItemHeight, LCAR.ItemHeight*2+temp, LCAR.ItemHeight,LCAR.ItemHeight, 0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Bit, "","","",0, True, 0, True, 1, 255)
			AddLCAR("2B", 0, LCAR.ItemHeight*2+temp, LCAR.ItemHeight*2+temp, temp9, LCAR.ItemHeight*API.iif(Landscape, 1.5, 2),temp5,LCAR.ItemHeight, LCAR.LCAR_Orange, LCAR.LCAR_Elbow, "PRIMARY POWER FEED","","", 0, True, -1, True, 1, 255)
			temp8= LCAR.ListItemsHeight(API.iif(Landscape, 4, 5))'height of new bar
			
			'third line
			temp6 = temp5 / 7.5'width of a bit
			temp7=  LCAR.ItemHeight*2+temp*2 + LCAR.ItemHeight*API.iif(Landscape, 1.5, 2) 'Y
			temp2= LCAR.ItemHeight*2+temp + temp9 - temp5
			AddLCAR("3A", 0, temp2, temp7, temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_Red,  LCAR.LCAR_Button, "!-1", "","",  1, True, 9, True, 0, 255)
			AddLCAR("3B", 0, temp2+temp6*1.5+temp, temp7, temp5 - temp - temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_DarkYellow,  LCAR.LCAR_Button, "PRIMARY IMAGING COILS", "","",  1, True, 9, True, 0, 255)
			
			'fourth line/vertical bars
			temp7=temp7+ LCAR.ItemHeight* API.iif(Landscape, 1, 2) + temp
			temp10=temp2 +  temp6*1.5 + temp
			temp3=temp11+temp4+temp6*2+temp
			AddLCAR("4A", 0, temp2, temp7, temp6*1.5, temp8, 0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "!-1", "", "", 2, True, 9, True, 0,255)
			AddLCAR("4B", 0, temp10, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 3, True, 9, True, 0,255)
			AddLCAR("4C", 0, temp10+temp6, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_Red, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 4, True, 9, True, 0,255)
			AddLCAR("4D", 0, temp10+temp6*2, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 5, True, 9, True, 0,255)
			AddLCAR("4E", 0, temp10+temp6*3, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 6, True, 9, True, 0,255)
			AddLCAR("4F", 0, temp10+temp6*4, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 7, True, 9, True, 0,255)
			AddLCAR("4G", 0, temp10+temp6*5, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, Rnd(1000, 10000), "", "", 8, True, 9, True, 0,255)
			
			'horizontal bars
			AddLCAR("4H1", 0, temp11-temp6*3-temp*2-LCAR.ItemHeight,temp7, LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 9, True, 0, True, 1, 255)
			AddLCAR("4H2", 0, temp11-temp6*3+LCAR.ItemHeight, temp7, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "7200", "", "", 9, True, 6, True,0,255)
			AddLCAR("4H3", 0, temp11-temp0-LCAR.ItemHeight, temp7, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "0", "", "", 9, True, 6, True,0,255)
			AddLCAR("4H4", 0, temp11,temp7, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "ANNULAR CONFINEMENT BEAM", "", "", 9, True, 4, True,0, 255)'<-THIS ONE
			AddLCAR("4H5", 0, temp11+temp4+temp6,temp7, temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 9, True, 4, True,0, 255)
			AddLCAR("4H6", 0, temp3,temp7, LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 9, True, 0, True, 3, 255)
			AddLCAR("4H7", 0, temp3+temp4-temp6*2-LCAR.ItemHeight*0.5-temp,temp7, temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 9, True, 4, True,0, 255)
			AddLCAR("4H8", 0, temp3+temp4-temp0-LCAR.ItemHeight*0.5-temp, temp7, temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "020", "", "", 9, True, 6, True,0,255)
			AddLCAR("4H9", 0, temp3+temp4-LCAR.ItemHeight*0.5,temp7,LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 9, True, 0, True,0, 255)
			AddLCAR("4H10",0, temp3+temp4+temp*2+temp6*2,temp7,temp6,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 9, True, 4, True,0, 255)
			AddLCAR("4H11",0, temp3+temp4+temp*2+temp6*3+temp,temp7,LCAR.ItemHeight,LCAR.ItemHeight,0,0, LCAR.LCAR_Red, LCAR.LCAR_Bit, "", "", "", 9, True, 0, True,3, 255)
			
			tempstr= "PATTERN BUFFER"
			AddLCAR("4I1", 0, temp11-temp6*3-temp*2-LCAR.ItemHeight,temp7+LCAR.ListItemsHeight(1), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 10, True, 0, True, 1, 255)
			AddLCAR("4I2", 0, temp11-temp6*3+LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(1), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "5802", "", "",10, True, 6, True,0,255)
			AddLCAR("4I3", 0, temp11-temp0-LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(1), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "90", "", "",10, True, 6, True,0,255)
			AddLCAR("4I4", 0, temp11,temp7+LCAR.ListItemsHeight(1), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, tempstr & " (PRIMARY)", "", "", 10, True, 4, True,0, 255)'<-THIS ONE
			AddLCAR("4I5", 0, temp11+temp4+temp6,temp7+LCAR.ListItemsHeight(1), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Button, "!-1", "", "", 10, True, 4, True,0, 255)
			AddLCAR("4I7", 0, temp3+temp4-temp6*2-LCAR.ItemHeight*0.5-temp,temp7+LCAR.ListItemsHeight(1), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 10, True, 4, True,0, 255)
			AddLCAR("4I8", 0, temp3+temp4-temp0-LCAR.ItemHeight*0.5-temp, temp7+LCAR.ListItemsHeight(1), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "008", "", "", 10, True, 6, True,0,255)
			AddLCAR("4I9", 0, temp3+temp4-LCAR.ItemHeight*0.5,temp7+LCAR.ListItemsHeight(1),LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 10, True, 0, True,0, 255)
			AddLCAR("4I10",0, temp3+temp4+temp*2+temp6*2,temp7+LCAR.ListItemsHeight(1),temp6,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 10, True, 4, True,0, 255)
			
			AddLCAR("4J2", 0, temp11-temp6*3+LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(2), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "90", "", "", 11, True, 6, True,0,255)
			AddLCAR("4J3", 0, temp11-temp0-LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(2), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "0", "", "", 11, True, 6, True,0,255)
			AddLCAR("4J4", 0, temp11,temp7+LCAR.ListItemsHeight(2), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, tempstr & " (SECONDARY)", "", "", 11, True, 4, True,0, 255)'<-THIS ONE
			AddLCAR("4J6", 0, temp3,temp7+LCAR.ListItemsHeight(2), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red, LCAR.LCAR_Bit, "", "", "", 11, True, 0, True, 3, 255)
			AddLCAR("4J7", 0, temp3+temp4-temp6*2-LCAR.ItemHeight*0.5-temp,temp7+LCAR.ListItemsHeight(2), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "!-1", "", "", 11, True, 4, True,0, 255)
			AddLCAR("4J8", 0, temp3+temp4-temp0-LCAR.ItemHeight*0.5-temp, temp7+LCAR.ListItemsHeight(2), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "72", "", "", 11, True, 6, True,0,255)
			AddLCAR("4J9", 0, temp3+temp4-LCAR.ItemHeight*0.5,temp7+LCAR.ListItemsHeight(2),LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 11, True, 0, True,0, 255)
			AddLCAR("4J10",0, temp3+temp4+temp*2+temp6*2,temp7+LCAR.ListItemsHeight(2),temp6,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button, "!-1", "", "", 11, True, 4, True,0, 255)
			AddLCAR("4J11",0, temp3+temp4+temp*2+temp6*3+temp,temp7+LCAR.ListItemsHeight(2),LCAR.ItemHeight,LCAR.ItemHeight,0,0, LCAR.LCAR_Red, LCAR.LCAR_Bit, "", "", "", 11, True, 0, True,3, 255)
			
			AddLCAR("4X2", 0, temp3+temp4+LCAR.ItemHeight*1.5,temp7+LCAR.ListItemsHeight(API.iif(Landscape, 2,3)),temp6*2-LCAR.ItemHeight*1.5+temp,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button, "", "", "", 12, True, 0, True,0, 255)
			AddLCAR("CURV", 0, temp3+temp4+temp, temp7, LCAR.ItemHeight*2.5, LCAR.ListItemsHeight(API.iif(Landscape, 4,5))- LCAR.ListitemWhiteSpace, 22, 2,  LCAR.LCAR_DarkYellow, LCAR.LCAR_LWP, "", "","", 12,True, LCAR.ListItemsHeight(API.iif(Landscape, 2,3)),True,LCAR.ItemHeight,255)
			AddLCAR("4X1", 0, temp3+temp4+temp,temp7+LCAR.ListItemsHeight(API.iif(Landscape, 2,3)),LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 12, True, 0, True,0, 255)
			
			AddLCAR("4K1", 0, temp11-temp6*3-temp*2-LCAR.ItemHeight,temp7+LCAR.ListItemsHeight(3), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red, LCAR.LCAR_Bit, "", "", "", 13, True, 0, True, 1, 255)
			AddLCAR("4K2", 0, temp11-temp6*3+LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(3), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "4077", "", "", 13, True, 6, True,0,255)
			AddLCAR("4K3", 0, temp11-temp0-LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(3), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "80", "", "", 13, True, 6, True,0,255)
			AddLCAR("4K4", 0, temp11,temp7+LCAR.ListItemsHeight(3), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, tempstr & " (BACKUP)", "", "", 13, True, 4, True,0, 255)'<-THIS ONE
			AddLCAR("4K5", 0, temp11+temp4+temp6,temp7+LCAR.ListItemsHeight(3), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Button, "", "", "", 13, True, 4, True,0, 255)
			AddLCAR("4K6", 0, temp3,temp7+LCAR.ListItemsHeight(3), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 13, True, 0, True, 3, 255)
			AddLCAR("4K8", 0, temp3+temp4-temp0-LCAR.ItemHeight*0.5-temp, temp7+LCAR.ListItemsHeight(3), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Red, LCAR.LCAR_Textbox, "358", "", "", 13, True, 6, True,0,255)
			AddLCAR("4K9", 0, temp3+temp4-LCAR.ItemHeight*0.5,temp7+LCAR.ListItemsHeight(3),LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 13, True, 0, True,0, 255)
			AddLCAR("4K10",0, temp3+temp4+temp*2+temp6*2,temp7+LCAR.ListItemsHeight(3),temp6,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button, "!-1", "", "", 13, True, 4, True,0, 255)
			AddLCAR("4K11",0, temp3+temp4+temp*2+temp6*3+temp,temp7+LCAR.ListItemsHeight(3),LCAR.ItemHeight,LCAR.ItemHeight,0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Bit, "", "", "", 13, True, 0, True,3, 255)
			
			If Not(Landscape) Then
				AddLCAR("4L1", 0, temp11-temp6*3-temp*2-LCAR.ItemHeight,temp7+LCAR.ListItemsHeight(4), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red, LCAR.LCAR_Bit, "", "", "", 14, True, 0, True, 1, 255)
				AddLCAR("4L2", 0, temp11-temp6*3+LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(4), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "56", "", "", 14, True, 6, True,0,255)
				AddLCAR("4L3", 0, temp11-temp0-LCAR.ItemHeight, temp7+LCAR.ListItemsHeight(4), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "451", "", "", 14, True, 6, True,0,255)
				AddLCAR("4L4", 0, temp11,temp7+LCAR.ListItemsHeight(4), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, tempstr & " (BACKUP AUX.)", "", "", 14, True, 4, True,0, 255)'<-THIS ONE
				AddLCAR("4L5", 0, temp11+temp4+temp6,temp7+LCAR.ListItemsHeight(4), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 14, True, 4, True,0, 255)
				AddLCAR("4L6", 0, temp3,temp7+LCAR.ListItemsHeight(4), LCAR.ItemHeight, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 14, True, 0, True, 3, 255)
				AddLCAR("4L7", 0, temp3+temp4-temp6*2-LCAR.ItemHeight*0.5-temp,temp7+LCAR.ListItemsHeight(4), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 14, True, 4, True,0, 255)
				AddLCAR("4L8", 0, temp3+temp4-temp0-LCAR.ItemHeight*0.5-temp, temp7+LCAR.ListItemsHeight(4), temp0, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "451", "", "", 14, True, 6, True,0,255)
				AddLCAR("4L9", 0, temp3+temp4-LCAR.ItemHeight*0.5,temp7+LCAR.ListItemsHeight(4),LCAR.ItemHeight*0.5,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 14, True, 0, True,0, 255)
				AddLCAR("4L10",0, temp3+temp4+temp*2+temp6*2,temp7+LCAR.ListItemsHeight(4),temp6,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "!-1", "", "", 14, True, 4, True,0, 255)
				AddLCAR("4L11",0, temp3+temp4+temp*2+temp6*3+temp,temp7+LCAR.ListItemsHeight(4),LCAR.ItemHeight,LCAR.ItemHeight,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Bit, "", "", "", 14, True, 0, True,3, 255)
			End If
			
			'Second half of second line
			AddLCAR("2C", 0, temp11+temp4+temp6, LCAR.ItemHeight*2+temp, temp6+temp+temp4,LCAR.ItemHeight*API.iif(Landscape, 2.5, 4)+temp, temp6,LCAR.ItemHeight, LCAR.LCAR_DarkYellow, LCAR.LCAR_Elbow, "!-1","","",15, True, -9, True,  0, 255)
			AddLCAR("2D", 0, temp11+temp4+temp6*2+temp4+temp*2, LCAR.ItemHeight*2+temp, temp6*2, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange,  LCAR.LCAR_Button, "!-1", "","",  15, True, 9, True, 0, 255)
			AddLCAR("2E", 0, temp11+temp4+temp6*4+temp4+temp*3, LCAR.ItemHeight*2+temp, temp4*3-LCAR.ItemHeight-temp*2, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange,  LCAR.LCAR_Button, "TARGETING SCANNERS", "","",  15, True, 9, True, 0, 255)
			AddLCAR("2F", 0, temp11+temp4+temp6*4+temp4*4+temp*3-LCAR.ItemHeight, LCAR.ItemHeight*2+temp, LCAR.ItemHeight,LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Bit, "","","",15, True, 0, True, 3, 255)
			
			'For temp9 = temp10 To temp10 + (temp5 - temp - temp6*1.5) Step temp6
			'	AddLCAR("4B", 0, temp9, temp7, temp6-temp, temp8, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "TEST", "", "", 0, True, 9, True, 0,255)
			'Next
			'temp10=temp7
			'For temp9 = 1 To API.iif(Landscape, 4, 5)
			'	AddLCAR("4C", 0, temp11,temp10, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "TEST", "", "", 0, True, 4, True,0, 255)
			'	temp10=temp10+LCAR.ListItemsHeight(1)
			'Next
			
			'fifth line
			temp7=temp7+temp8+temp
			AddLCAR("5A", 0, temp2, temp7, temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Button, "!-1", "","",  16, True, 9, True, 0, 255)
			AddLCAR("5B", 0, temp2+temp6*1.5+temp, temp7, temp5 - temp - temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_Orange,  LCAR.LCAR_Button, "PHASE TRANSITION COILS (PRIMARY)", "","",  16, True, 9, True, 0, 255)
			AddLCAR("5C", 0, temp11, temp7-LCAR.ListitemWhiteSpace , temp4, LCAR.ItemHeight* API.iif(Landscape, 2.5, 5)+temp+LCAR.ListitemWhiteSpace, 0,0, LCAR.LCAR_Orange,  LCAR.LCAR_Button, "SUBSPACE RELAY COMPENSATION", "","",  16, True, 7, True, 0, 255)
			AddLCAR("5D", 0, temp11+temp4+temp6, temp7-LCAR.ListitemWhiteSpace , temp6, LCAR.ItemHeight* API.iif(Landscape, 2.5, 5)+temp+LCAR.ListitemWhiteSpace , 0,0, LCAR.LCAR_Purple,  LCAR.LCAR_Button, "!-1", "","",  16, True, 9, True, 0, 255)
			
			'sixth line
			temp7=temp7+ LCAR.ItemHeight* API.iif(Landscape, 1, 2) + temp
			AddLCAR("6A", 0, temp2, temp7, temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Button, "!-1", "","",  17, True, 9, True, 0, 255)
			AddLCAR("6B", 0, temp2+temp6*1.5+temp, temp7, temp5 - temp - temp6*1.5, LCAR.ItemHeight* API.iif(Landscape, 1, 2), 0,0, LCAR.LCAR_Purple,  LCAR.LCAR_Button, "TRANSPORTER", "","",  17, True, 9, True, 0, 255)
			
			'seventh line
			temp7=temp7+ LCAR.ItemHeight* API.iif(Landscape, 1, 2) + temp
			temp10 = temp2 + temp5+LCAR.ItemHeight + temp 'new X  temp11 next X
			temp12 = temp11 - temp10 - temp
			AddLCAR("7A", 0, temp2, temp7, temp5+LCAR.ItemHeight, LCAR.ItemHeight*API.iif(Landscape, 1.5, 2),temp5,LCAR.ItemHeight, LCAR.LCAR_DarkYellow, LCAR.LCAR_Elbow, "!-1","","", 0, True, 1, True, 2 , 255)
			AddLCAR("7B", 0, temp10, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp12 - temp - temp6*3, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red,  LCAR.LCAR_Button, "!-1", "","",  18, True, 7, True, 0, 255)
			AddLCAR("7C", 0, temp11-temp6*3-temp, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp6*3, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkOrange,  LCAR.LCAR_Button, "!-1", "","",  18, True, 9, True, 0, 255)
			AddLCAR("7D", 0, temp11, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightPurple,  LCAR.LCAR_Button, "HEISENBERG COMPENSATOR", "","",  18, True, 7, True, 0, 255)
			AddLCAR("7E", 0, temp11+temp4+temp6, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Purple,  LCAR.LCAR_Button, "", "","",  18, True, 0, True, 0, 255)
			AddLCAR("7F", 0, temp11+temp4+temp6*2+temp, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Button, "!-1", "","",  18, True, 9, True, 0, 255)
			AddLCAR("7G", 0, temp11+temp4+temp6*2+temp4+temp*2, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp6*2, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightPurple,  LCAR.LCAR_Button, "!-1", "","",  18, True, 9, True, 0, 255)
			AddLCAR("7H", 0, temp11+temp4+temp6*4+temp4+temp*3, temp7+ LCAR.ItemHeight*API.iif(Landscape, 0.5, 1), temp4*3, LCAR.ItemHeight*4+temp*2,temp4*2,LCAR.ItemHeight, LCAR.LCAR_DarkOrange, LCAR.LCAR_Elbow, "PHASE TRANSITION COILS (SECONDARY)","","", 18, True,9, True,  1, 255)
			AddLCAR("7I", 0, temp11+temp4+temp6*4+temp4*2+temp*3, temp7+ LCAR.ItemHeight*API.iif(Landscape, 4.5, 5)+temp*3, temp4*2, LCAR.ItemHeight*2,temp4*2,LCAR.ItemHeight, LCAR.LCAR_DarkPurple, LCAR.LCAR_Bit, "","","", 18, True, 2, True,  0, 255)
			
			'eighth line
			temp7=temp7+ LCAR.ItemHeight*API.iif(Landscape, 1.5, 2) + temp
			AddLCAR("8A", 0, LCAR.ItemHeight, temp7+LCAR.ItemHeight*2, LCAR.ItemHeight,LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Bit, "","","",19, True, 0, True, 1, 255)
			AddLCAR("8B", 0, LCAR.ItemHeight*2+temp, temp7+LCAR.ItemHeight, temp2-(LCAR.ItemHeight*2+temp) + temp6*1.5, LCAR.ItemHeight*2,temp6*1.5,LCAR.ItemHeight, LCAR.LCAR_DarkYellow, LCAR.LCAR_Elbow, "SECONDARY POWER FEED","","", 19, True, -7, True, 3 , 255)
			AddLCAR("8C", 0, temp2, temp7, temp5 + temp + (temp12 - temp - temp6*3)+LCAR.ItemHeight, LCAR.ItemHeight*2,temp6*1.5,LCAR.ItemHeight, LCAR.LCAR_DarkYellow, LCAR.LCAR_Elbow, "","","", 19, True, 1, True, 0 , 255)
			AddLCAR("8D", 0, temp11-temp6*3-temp, temp7, temp6*3, LCAR.ItemHeight, 0,0, LCAR.LCAR_Red,  LCAR.LCAR_Button, "", "","",  19, True, 9, True, 0, 255)
			AddLCAR("8E", 0, temp11, temp7, temp4, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightPurple,  LCAR.LCAR_Button, "", "","",  19, True, 7, True, 0, 255)
			
			'ninth line
			temp7=temp7+ LCAR.ItemHeight + temp
			AddLCAR("9A", 0, temp11, temp7, temp4, LCAR.ItemHeight*2, 0,0, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Button, "DOPPLER COMPENSATOR", "","",  20, True, 7, True, 0, 255)
			AddLCAR("9B", 0, temp11, temp7+LCAR.ItemHeight*2+temp, temp4, LCAR.ItemHeight*2, 0,0, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Bit, "", "","",  20, True, 2, True,  0, 255)
			AddLCAR("9C", 0, temp11+temp4+temp6, temp7, temp6, LCAR.ItemHeight*2, 0,0, LCAR.LCAR_Purple,  LCAR.LCAR_Button, "!-1", "","",  20, True,  9, True, 0, 255)
			AddLCAR("9D", 0, temp11+temp4+temp6, temp7+LCAR.ItemHeight*2+temp, temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Purple,  LCAR.LCAR_Bit, "", "","",  20, True, 2, True,  0, 255)
		
		Case 37'CORRIDOR panel				FLXB2-7T03A-QK6M9
			tempstr="40271"
			temp0 = LCAR.ItemHeight*2'height of top bar (just the top part of it)
			temp = API.GetTextHeight(BG, temp0, tempstr, LCAR.LCARfont)'textsize
			temp2 = BG.MeasureStringWidth(tempstr, LCAR.LCARfont, temp)'text width
			temp3 = temp2*1.10'width of first bars
			temp4 = LCAR.ItemHeight*3'height of bottom bar 
			temp5 = msdHeight - temp4 - LCAR.ListItemsHeight(4) - LCAR.ListitemWhiteSpace 'height of entire top bar
			temp6 = LCAR.ItemHeight*0.5 'width of bit
			temp7 = temp6*0.75 'extra space
			temp5=temp5-temp7
			temp12=LCAR.ItemHeight+LCAR.NumberWhiteSpace+temp7-LCAR.ListitemWhiteSpace 'width of inner elbow
			
			'Column 1
			AddLCAR("1A", 0, 		0, 0, temp3 + temp12+temp7, temp5-temp7, temp3,temp0, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 0, 255)
			AddLCAR("1B", 0,  		temp3 + temp12+ LCAR.ListitemWhiteSpace+temp7,0, temp2, temp, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_Textbox, tempstr,"","",-1, True, 12, True, 0, 255)
			AddLCAR("1C", 0,  		temp3 + temp12+ temp2+ LCAR.ListitemWhiteSpace*2+temp7,0, temp2,temp0,  0,0,  LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "", "", -1, True, 0, True, 0, 255)
			
			tempstr= " SEQUENCE"
			AddLCAR("2A", 0, 		0, temp5+LCAR.ListitemWhiteSpace, temp3-temp6- LCAR.ListitemWhiteSpace, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkYellow , LCAR.LCAR_Button, "PRIMARY" & tempstr, "", "", 1, True, 6, True, 0, 255)
			AddLCAR("2B", 0, 		temp3-temp6, temp5+LCAR.ListitemWhiteSpace, temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange , LCAR.LCAR_Button, "", "", "", 1, True, 6, True, 0, 255)
			
			AddLCAR("3A", 0, 		0, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), temp3-temp6- LCAR.ListitemWhiteSpace, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkYellow , LCAR.LCAR_Button, "SECONDARY" & tempstr, "", "",2 , True, 6, True, 0, 255)
			
			AddLCAR("4A", 0, 		0, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp3-temp6- LCAR.ListitemWhiteSpace, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkPurple , LCAR.LCAR_Button, "AUXILARY" & tempstr, "", "",3 , True, 6, True, 0, 255)
			AddLCAR("4B", 0, 		temp3-temp6, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_LightOrange , LCAR.LCAR_Button, "", "", "", 3, True, 6, True, 0, 255)
			
			AddLCAR("5A", 0, 		0, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp3-temp6- LCAR.ListitemWhiteSpace, LCAR.ItemHeight, 0,0, LCAR.LCAR_DarkPurple , LCAR.LCAR_Button, "EMERGENCY" & tempstr, "", "",4 , True, 6, True, 0, 255)
			AddLCAR("5B", 0, 		temp3-temp6, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp6, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange , LCAR.LCAR_Button, "", "", "", 4, True, 6, True, 0, 255)
			
			AddLCAR("6A", 0, 		0, msdHeight -temp4, temp3 + temp12+temp7, temp4, temp3,temp4*0.5, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True,  2, 255)
			AddLCAR("6B", 0,  		temp3 + temp12+ LCAR.ListitemWhiteSpace+temp7,msdHeight-temp4*0.5, temp2, temp4*0.5, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_Button, "MODE SELECT","","",5, True, 6, True, 0, 255)
			AddLCAR("6C", 0,  		temp3 + temp12+ temp2+ LCAR.ListitemWhiteSpace*2+temp7,msdHeight-temp4*0.5, temp2,temp4*0.5,  0,0,  LCAR.LCAR_Orange,LCAR.LCAR_Button, "ACCESS", "", "",5, True,  4, True, 0, 255)
			
			'Text blocks
			temp8=temp3+temp7*2+LCAR.ItemHeight
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace, LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "30", "", "",1, True, 6, True,0,255)
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "000", "", "",2, True, 6, True,0,255)
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "2", "", "",3, True, 6, True,0,255)
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Textbox, "080", "", "",4, True, 6, True,0,255)
			
			'Column 2
			temp8 = temp3 +temp7'X coordinate
			temp9 = Min( LCAR.ItemHeight*2, temp5-temp0 - LCAR.ItemHeight)'height of new elbow
			
			temp10=temp3 + temp12+ LCAR.ListitemWhiteSpace+temp7  'temp8+temp2+LCAR.ListitemWhiteSpace-temp7'start of 40271
			temp11=temp3 + temp12+ temp2+ LCAR.ListitemWhiteSpace*2+temp7'temp10+ temp2+ LCAR.ListitemWhiteSpace 'temp10 + temp2 + LCAR.ListitemWhiteSpace     'temp8+(temp2*2)-temp7'start of bits
			AddLCAR("1D", 0, 		temp8, temp5-temp7-temp9, temp12, temp9, LCAR.ItemHeight,LCAR.ItemHeight, LCAR.LCAR_DarkPurple,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 0, 255)
			AddLCAR("1E", 0, 		temp10, temp5-temp7-temp9, temp2-LCAR.ListitemWhiteSpace, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "LCARS", "","", 7, True, 6, True, 0,255)
			AddLCAR("1F", 0, 		temp11, temp5-temp7-temp9, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkPurple,LCAR.LCAR_Bit, "", "","", 7, True, 0, True, 3,255)
			
			AddLCAR("2D", 0, 		temp10,    temp5+LCAR.ListitemWhiteSpace, temp2-LCAR.ListitemWhiteSpace, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "", "","",1, True, 6, True, 0,255)
			AddLCAR("2F", 0, 		temp11, temp5+LCAR.ListitemWhiteSpace, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 1, True, 0, True, 3,255)
			
			AddLCAR("3C", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.ItemHeight,LCAR.ItemHeight,  0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 2, True, 6, True, 0,255)
			AddLCAR("3F", 0, 		temp11, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 2, True, 0, True, 3,255)
			
			AddLCAR("4C", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), LCAR.ItemHeight,LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "", "","",3, True, 6, True, 0,255)
			AddLCAR("4D", 0, 		temp10,    temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp2-LCAR.ListitemWhiteSpace, LCAR.ItemHeight,     0,0, LCAR.LCAR_LightPurple,LCAR.LCAR_Button, "", "","", 3, True, 6, True, 0,255)
			AddLCAR("4F", 0, 		temp11, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Bit, "", "","", 3, True, 0, True, 3,255)
			
			AddLCAR("5C", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), LCAR.ItemHeight,LCAR.ItemHeight,  0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 4, True, 6, True, 0,255)
			AddLCAR("5D", 0, 		temp10,    temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp2-LCAR.ListitemWhiteSpace, LCAR.ItemHeight,     0,0, LCAR.LCAR_LightPurple,LCAR.LCAR_Button, "", "","", 4, True, 6, True, 0,255)
			AddLCAR("5F", 0, 		temp11, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Bit, "", "","", 4, True, 0, True, 3,255)
			
			AddLCAR("6D", 0, 		temp8, msdHeight -temp4,temp12, LCAR.ItemHeight+temp7, LCAR.ItemHeight,LCAR.ItemHeight, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 2, 255)
			AddLCAR("6E", 0, 		temp10,    msdHeight -temp4 +temp7, temp2-LCAR.ListitemWhiteSpace, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 5, True, 6, True, 0,255)
			AddLCAR("6F", 0, 		temp11, msdHeight -temp4 +temp7, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkPurple,LCAR.LCAR_Bit, "", "","", 5, True, 0, True, 3,255)
			
			'Column 3	the Enterprise
			temp8=temp3 + temp2*4'X coordinate         temp4*0.5
			tempstr = "HOLODECK 4J•11-2917"
			AddLCAR("7", 0,  		temp8, 0, Max(msdHeight,msdWidth), msdHeight, 37, temp4*0.5, LCAR.LCAR_Orange, LCAR.LCAR_LWP, tempstr,"","",-1, True,   temp0, False,  API.GetTextHeight(BG, temp4*0.5, tempstr, LCAR.LCARfont), 255)
			
			'Column 4
			temp8 = temp8 + Max(msdHeight,msdWidth) + LCAR.ItemHeight 
			AddLCAR("1G", 0,  		temp8,0, temp2,temp0,  0,0,  LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "", "", 7, True, 0, True, 0, 255)
			
			AddLCAR("6G", 0,  		temp8,msdHeight-temp4*0.5, temp2,temp4*0.5,  0,0,  LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "", "", 0, True,  4, True, 0, 255)
			
			'Bits before Column 5
			temp10 = temp8 + temp2 - LCAR.ItemHeight 
			AddLCAR("1F", 0, 		temp10, temp5-temp7-temp9, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 7, True, 0, True, 1,255)
			AddLCAR("1F", 0, 		temp10, temp5+LCAR.ListitemWhiteSpace, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 1, True, 0, True, 1,255)
			AddLCAR("1F", 0, 		temp10, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 2, True, 0, True, 1,255)
			AddLCAR("1F", 0, 		temp10,  msdHeight -temp4 +temp7, LCAR.ItemHeight, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Bit, "", "","", 5, True, 0, True, 1,255)
			
			'Column 5	40271
			tempstr = "40271"
			temp8 = temp8 + temp2 + LCAR.ListitemWhiteSpace 
			AddLCAR("1H", 0,  		temp8,0, temp2, temp, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Textbox, tempstr,"","",7, True, 12, True, 0, 255)
			AddLCAR("1E", 0, 		temp8, temp5-temp7-temp9, temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "LCARS", "","", 7, True, 6, True, 0,255)
			
			AddLCAR("1E", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace, temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","",1, True, 6, True, 0,255)
			AddLCAR("1E", 0, 		temp8,  temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "", "","",3, True, 6, True, 0,255)
			AddLCAR("1E", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 4, True, 6, True, 0,255)
			
			
			AddLCAR("6B", 0,  		temp8,msdHeight-temp4*0.5, temp2, temp4*0.5, 0,0, LCAR.LCAR_Yellow, LCAR.LCAR_Button, "MODE SELECT","","",5, True, 6, True, 0, 255)
			
			'Column 6	midbit
			temp8 = temp8 + temp2 + LCAR.ListitemWhiteSpace 
			AddLCAR("1G", 0,  		temp8,0, LCAR.NumberWhiteSpace, temp0,  0,0,  LCAR.LCAR_DarkPurple,LCAR.LCAR_Button, "", "", "", 7, True, 0, True, 0, 255)
			AddLCAR("1G", 0,  		temp8,temp5-temp7-temp9, LCAR.NumberWhiteSpace, LCAR.ItemHeight,  0,0,  LCAR.LCAR_DarkPurple,LCAR.LCAR_Button, "", "", "", 7, True, 0, True, 0, 255)
			
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace, LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Textbox, "238", "", "",1, True, 6, True,0,255)
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Textbox, "089", "", "",2, True, 6, True,0,255)
			AddLCAR("4I3", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), LCAR.NumberWhiteSpace, LCAR.NumberTextSize, -1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox, "2", "", "",3, True, 6, True,0,255)
			
			AddLCAR("6B", 0,  		temp8, msdHeight -temp4 +temp7, LCAR.NumberWhiteSpace, LCAR.ItemHeight, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "","","",5, True, 6, True, 0, 255)
			AddLCAR("6B", 0,  		temp8,msdHeight-temp4*0.5, LCAR.NumberWhiteSpace, temp4*0.5, 0,0, LCAR.LCAR_DarkPurple, LCAR.LCAR_Button, "","","",5, True, 6, True, 0, 255)
			
			'Column 7	Elbow
			temp8 = temp8 + LCAR.NumberWhiteSpace+LCAR.ListitemWhiteSpace 
			AddLCAR("1A", 0, 		temp8, 0, temp3 + temp2 - LCAR.NumberWhiteSpace, temp5-temp7, temp3,temp0, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 1, 255)
			AddLCAR("1D", 0, 		temp8, temp5-temp7-temp9, temp2-temp7-LCAR.NumberWhiteSpace, temp9, LCAR.ItemHeight,LCAR.ItemHeight, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 1, 255)
			
			temp11=LCAR.ItemHeight
			temp10=temp8 + (temp2-temp7-LCAR.NumberWhiteSpace-temp11)
			AddLCAR("2F", 0, 		temp10, temp5+LCAR.ListitemWhiteSpace, temp11, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 1, True, 0, True, 0,255)
			AddLCAR("2F", 0, 		temp10, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp11, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkOrange,LCAR.LCAR_Button, "", "","", 3, True, 0, True, 0,255)
			AddLCAR("2F", 0, 		temp10, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp11, LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "", "","", 4, True, 0, True, 0,255)
			
			AddLCAR("6A", 0, 		temp8, msdHeight -temp4, temp3 + temp2- LCAR.NumberWhiteSpace, temp4, temp3,temp4*0.5, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True,  3, 255)
			AddLCAR("6D", 0, 		temp8, msdHeight -temp4, temp2-temp7-LCAR.ListitemWhiteSpace - LCAR.NumberWhiteSpace, LCAR.ItemHeight+temp7, LCAR.ItemHeight,LCAR.ItemHeight, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 3, 255)
			
			'Column 7.5
			temp8 = temp8 + temp2 - LCAR.NumberWhiteSpace
			tempstr= " SEQUENCE"
			AddLCAR("2F", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace, LCAR.ItemHeight*0.5, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "", "","",  1, True, 0, True, 0,255)
			AddLCAR("2D", 0, 		temp8+LCAR.ItemHeight*0.5+LCAR.ListitemWhiteSpace,    temp5+LCAR.ListitemWhiteSpace, temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkYellow,LCAR.LCAR_Button, "PRIMARY" & tempstr, "","", 1, True, 6, True, 0,255)
			
			AddLCAR("2F", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), LCAR.ItemHeight*0.5, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkOrange,LCAR.LCAR_Button, "", "","", 2, True, 0, True, 0,255)
			AddLCAR("2D", 0, 		temp8+LCAR.ItemHeight*0.5+LCAR.ListitemWhiteSpace,    temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(1), temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "SECONDARY" & tempstr, "","", 2, True, 6, True, 0,255)
			
			AddLCAR("2F", 0, 		temp8, temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), LCAR.ItemHeight*0.5, LCAR.ItemHeight,     0,0, LCAR.LCAR_DarkOrange,LCAR.LCAR_Button, "", "","", 3, True, 0, True, 0,255)
			AddLCAR("2D", 0, 		temp8+LCAR.ItemHeight*0.5+LCAR.ListitemWhiteSpace,    temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(2), temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "AUXILARY" & tempstr, "","", 3, True, 6, True, 0,255)
			
			AddLCAR("2D", 0, 		temp8+LCAR.ItemHeight*0.5+LCAR.ListitemWhiteSpace,    temp5+LCAR.ListitemWhiteSpace+LCAR.ListItemsHeight(3), temp2-(LCAR.ListitemWhiteSpace*2), LCAR.ItemHeight,     0,0, LCAR.LCAR_Orange,LCAR.LCAR_Button, "EMERGENCY" & tempstr, "","", 4, True, 6, True, 0,255)
			
		Case 41'WARP FIELD
			temp0=20'height of blocks
			temp = LCAR.ListitemWhiteSpace'whitespace
			temp2=4'difference between regular and slightly large blocks
			temp3 = msdWidth * 0.32203'width of elbow
			temp4 = msdWidth * 0.07506'width of small unit
			temp5 = msdHeight * 0.39579'start of middle row
			temp6 = msdHeight * 0.02105'height of middle row
			temp7 = msdHeight * 0.04632'height of lower block
			temp8 = msdWidth * 0.09927'width of left column
			temp9 = temp4*2+temp+temp0'width of 2 blocks
			temp10 = msdWidth * 0.32203'start of second col (elbows)
			temp11 = msdHeight*0.15579
			temp12 = temp5 -temp11-temp2'height of top lines
			
			AddLCAR("TL", 0, 		0, 0, temp8, msdHeight * 0.14737, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("TM", 0, 		0, temp11, temp8, msdHeight * 0.11789, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, Rnd(100,1000), "", "", 0, True, 9, True, 0,255)
			
			AddLCAR("TR1", 0, 		temp10+temp, 0, msdWidth * 0.54237, msdHeight * 0.14737, temp9, temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True,  0, 255)
			AddLCAR("TR2", 0, 		msdWidth * 0.86, 0, -1, msdHeight * 0.073685, temp4, temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True,  1, 255)
			
			AddLCAR("TB", 0, 		0, msdHeight*0.27579, temp3, msdHeight * 0.14105, temp8,temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 2, 255)
			
			AddLCAR("T1A", 0, 		temp3 + temp, temp5, temp4, msdHeight * 0.01053, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T1B", 0, 		temp3 + temp, temp5-temp2*2, temp4, temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T1C", 0,		temp3 + temp, temp11, 2, temp12, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T1D", 0,		temp3 + temp, temp11, temp0,temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
						
			AddLCAR("T2A", 0, 		temp3 + temp*2 + temp4, temp5-temp2, temp4, temp6+temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T2B", 0, 		temp3 + temp*2 + temp4 - temp, temp5-temp2*3, temp4 + temp, temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T2C", 0,		temp3 + temp + temp4, temp11, 2, temp12-temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			AddLCAR("T3A", 0, 		temp3 + temp*3 + temp4*2, temp5, temp4*2, temp6, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T3C", 0,		temp3 + temp*2 + temp4*2-2, temp11, 2, temp12-temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T3D", 0,		temp3 + temp*2 + temp4*2-2, temp11, temp0,temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			AddLCAR("T4A", 0, 		temp3 + temp*4 + temp4*4, temp5-temp2, -1, temp6+temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("T4B", 0, 		msdWidth-temp4, temp5-temp2*3, temp4, temp6+temp2*3, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)

			temp5 = temp5 + temp6 + 2'second row
			temp12= msdHeight * 0.38947 + temp*3 + temp7*2 - temp6'height of lines 'msdHeight*0.47 
			temp1= temp5+temp6 + temp12 - temp0'start of blocks
			AddLCAR("BT", 0, 		0, temp5, temp3, msdHeight * 0.19789, temp8,temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, Rnd(100,1000), "","",  -1, True,  9, True, 0, 255)
			
			AddLCAR("B1A", 0, 		temp3 + temp, temp5, temp4, temp6, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,128)
			AddLCAR("B1B", 0, 		temp3 + temp, temp5 + temp6*1.25+temp2*3, temp4+temp2, temp6*0.5, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B1C", 0, 		temp3 + temp, temp5+temp6, 2, temp12, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B1D", 0, 		temp3 + temp, temp1, temp0, temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			AddLCAR("B2A", 0, 		temp3 + temp*2 + temp4, temp5, temp4, temp6+temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B2B", 0, 		temp3 + temp*2 + temp4, temp5 + temp6+temp2*3, temp4, temp6*0.75, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B2C", 0, 		temp3 + temp*2 + temp4, temp5+temp6, 2, temp12, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B2D", 0, 		temp3 + temp*2 + temp4, temp1, temp0, temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			AddLCAR("B3A", 0, 		temp3 + temp*3 + temp4*2, temp5, temp4*2, temp6, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B3C", 0, 		temp3 + temp*3 + temp4*2-2-temp, temp5+temp6, 2, temp12, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B3D", 0, 		temp3 + temp*3 + temp4*2-2-temp, temp1, temp0, temp0, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			AddLCAR("B4A", 0, 		temp3 + temp*4 + temp4*4, temp5, -1, temp6+temp2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("B4B", 0, 		msdWidth-temp4, temp5, temp4, temp6+temp2*3, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			temp5 = temp5 + msdHeight * 0.19789 + temp
			AddLCAR("TL", 0, 		0, temp5, temp8, temp7, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("TL", 0, 		0, temp5 + temp + temp7, temp8, temp7, 0,0, LCAR.LCAR_DarkOrange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			AddLCAR("TL", 0, 		0, temp5 + temp*2 + temp7*2, temp8, msdHeight*0.19158, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", 0, True, 0, True, 0,255)
			
			temp5 = temp5 + temp*3 + temp7*2 + msdHeight*0.19158
			AddLCAR("LA", 0, 		0, temp5, temp3, -1, temp8,temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 2, 255)
			AddLCAR("LB", 0, 		temp10-temp8, msdHeight*0.94526, temp9+temp8, msdHeight*0.05474, temp9,temp6, LCAR.LCAR_Orange,  LCAR.LCAR_Elbow, "", "","",  -1, True,  0, True, 3, 255)
			
			AddLCAR("WARPF", 0, 0,0, -1,-1, 0, 0, LCAR.LCAR_Orange , LCAR.LCAR_WarpField, "warp field",  "", "",  0,  False,0 ,   True ,0,0) 
		
		Case 49'ENT-B Helm 
			temp  = msdHeight * 0.051'Height of a button (Width is 1.5 times height)
			temp2 = BG.MeasureStringHeight("0123456789", LCARSeffects2.StarshipFont, LCAR.Fontsize*0.5)'msdHeight * 0.019'Stroke 
			temp3 = temp * 2 + temp2 * 5' msdHeight * 0.199'Height of bottom half
			temp5 = msdHeight-temp3-temp2'Height of top half
			temp6 = msdHeight * 0.0833333333333333'Radius
			temp9 = temp5 - temp2*4 - temp * 3'start of top row of buttons
			temp0 = temp9 - temp2 * 3'height of meters
			'Align=corner, Rwidth=radius, Lwidth=stroke, textalign: 0=top left, 1=top right, 2=bottom left, 3=bottom right (add 4 for each increase in font size), tag=klingon data
			
			'Left Corner
			temp7 = temp6 + temp2
			AddENTBmeters(temp7, temp2*2, temp*1.5, temp0, temp2, 0, 	Array As Int(1,1,1,1,1,2), LCAR.TMP_Meter)
			temp4 = AddENTBbuttons(temp7, temp9, temp, temp2,    		Array As Int(1,1,1,1,1,2)) + temp7'temp * 15
			AddENTBbuttons(temp7, temp9+temp+temp2, temp, temp2, 		Array As Int(1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp9+(temp+temp2)*2, temp, temp2, 	Array As Int(1,1,1,1,1,2))
			LCARSeffects7.AddWallpaperLCAR("LT", 0, 0, 0, temp4, temp5, temp2, temp6, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "0.1", 0, True, -3, False, 1, 255,  	0,0,"", 0)
			LCARSeffects7.AddWallpaperLCAR("LB", 0, 0, temp5+temp2, temp4, temp3, temp2, temp6, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "", 0, True, -3, False, 7, 255,  	0,0,"", 0)
			AddENTBbuttons(temp7, temp5+temp2*3, temp, temp2, 			Array As Int(1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp5+temp2*4+temp, temp, temp2, 		Array As Int(1,1,1,1,1,2))
			
			'Second (big) column
			temp7 = temp4 + temp2'X
			temp8 = AddENTBbuttons(temp7, temp9, temp, temp2,    		Array As Int(1,1,1,1,1,1,1,1,1,1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp9+temp+temp2, temp, temp2, 		Array As Int(1,1,1,1,1,1,1,1,1,1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp9+(temp+temp2)*2, temp, temp2, 	Array As Int(1,1,1,1,1,1,1,1,1,1,1,1,1,1,2))
			LCARSeffects7.AddWallpaperLCAR("MLT", 0, temp7, 0, temp8, temp5,  temp2, 0, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "", 0, True, -3, False, 10, 255,  	0,0,"", 0)
			LCARSeffects7.AddWallpaperLCAR("MLB", 0, temp7, temp5+temp2, temp8, temp3,  temp2, 0, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "", 0, True, -3, False, 10, 255,  	0,0,"", 0)
			AddENTBbuttons(temp7, temp5+temp2*3, temp, temp2, 			Array As Int(1,1,1,1,1,1,1,1,1,1,1,1,1,1))
			AddENTBbuttons(temp7, temp5+temp2*4+temp, temp, temp2, 		Array As Int(1,1,1,1,1,1,1,1,1,1,1,1,1,1,2))
			
			'Still second (big) column
			temp10 = temp8 - temp2*4'width (-whitespaces)
			temp11 = temp7 + temp2*2'left
			temp12 = temp10*0.08923'width of meter
			AddLCAR("MTR1", 0, temp11 + temp10*0.01923, temp2*2, temp12, temp0, 0,0, LCAR.Classic_Blue, LCAR.TMP_Meter, API.GetString("helmb0"), "", "",  0, True, 6, True, 0, 255)
			AddLCAR("MTR2", 0, temp11 + temp10*0.12538, temp2*2, temp12, temp0, 0,0, LCAR.Classic_Blue, LCAR.TMP_Meter, API.GetString("helmb1"), "", "",  0, True, 7, True, 0, 255)
			AddLCAR("MTR3", 0, temp11 + temp10*0.23692, temp2*2, temp12, temp0, 0,0, LCAR.Classic_Blue, LCAR.TMP_Meter, API.GetString("helmb2"), "", "",  0, True, 8, True, 0, 255)
			AddLCAR("MTR4", 0, temp11 + temp10*0.35462, temp2*2, temp12, temp0, 0,0, LCAR.Classic_Blue, LCAR.TMP_Meter, API.GetString("helmb3"), "", "",  0, True, 9, True, 0, 255)
			AddLCAR("MTR5", 0, temp11 + temp10*0.47846, temp2*2, temp12, temp0, 0,0, LCAR.Classic_Blue, LCAR.TMP_Meter, API.GetString("helmb4"), "", "",  0, True, 10, True, 0, 255)
			
			temp12 = temp0 * 0.20
			AddLCAR("BP1", 0, temp11 + temp10*0.62077, temp2*2,          temp12, temp12, 49,0, LCAR.Classic_Turq, LCAR.LCAR_LWP, API.GetString("helmbtn0"), "", "",  0, True, LCAR.Fontsize*0.5, True, 9, Min(Rnd(4,16) * 16, 255))
			AddLCAR("BP2", 0, temp11 + temp10*0.62077, temp2*2+temp12*2, temp12, temp12, 49,0, LCAR.Classic_Green, LCAR.LCAR_LWP, API.GetString("helmbtn1"), "", "",  0, True, LCAR.Fontsize*0.5, True, 9, Min(Rnd(4,16) * 16, 255))
			AddLCAR("BP3", 0, temp11 + temp10*0.62077, temp2*2+temp12*4, temp12, temp12, 49,0, LCAR.Classic_Yellow, LCAR.LCAR_LWP, API.GetString("helmbtn2"), "", "",  0, True, LCAR.Fontsize*0.5, True, 9, Min(Rnd(4,16) * 16, 255))
			
			temp12 = (temp0 - temp2) * 0.5
			AddLCAR("SQ1", 0, temp11 + temp10 - temp12 - temp2*2, temp2*2, temp12+temp2*2, temp12, 49,1, LCAR.Classic_Green, LCAR.LCAR_LWP, 0, "", "",  0, True, 0, True, 0, 255)
			AddLCAR("SQ2", 0, temp11 + temp10 - temp12 - temp2*2, temp2*3 + temp12, temp12+temp2*2, temp12, 49,2, LCAR.Classic_Green, LCAR.LCAR_LWP, 0, "", "",  0, True, 1, True, 0, 255)
			
			'Third (small) Column
			temp7 = temp7 + temp8 + temp2'X
			temp8 = AddENTBbuttons(temp7, temp5+temp2*3, temp, temp2, 	Array As Int(2,1,1,1,1)) +  temp'Width of Right part
			LCARSeffects7.AddWallpaperLCAR("MRT", 0, temp7, 0, temp8, temp5,  48, 24, LCAR.LCAR_Random, LCAR.LCAR_LWP, API.getstring("helmb"), "", "", 0, True, temp2, False, temp, 255,  	0,0,"", 0)
			LCARSeffects7.AddWallpaperLCAR("MRB", 0, temp7, temp5+temp2, temp8, temp3,  temp2, 0, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "", 0, True, -3, False, 10, 255,  	0,0,"", 0)
			AddENTBbuttons(temp7, temp5+temp2*4+temp, temp, temp2, 		Array As Int(2,1,1,1,1))
			
			'Right corner
			temp7 = temp7 + temp8 + temp2'X
			AddENTBmeters(temp7, temp2*2, temp*1.5, temp0, temp2, 11, 	Array As Int(1,1,1,1,1,2), LCAR.TMP_Meter)
			AddENTBbuttons(temp7, temp9, temp, temp2,    				Array As Int(1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp9+temp+temp2, temp, temp2, 		Array As Int(1,1,1,1,1,2))
			AddENTBbuttons(temp7, temp9+(temp+temp2)*2, temp, temp2, 	Array As Int(1,1,1,1,1,2))
			LCARSeffects7.AddWallpaperLCAR("RT", 0, temp7, 0, temp4, temp5, temp2, temp6, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "0.1", 0, True, -3, False, 3, 255,  	0,0,"", 0)
			LCARSeffects7.AddWallpaperLCAR("RB", 0, temp7, temp5+temp2, temp4, temp3, temp2, temp6, LCAR.LCAR_Random, LCAR.PCAR_Frame, Rnd(1000,10000), "", "", 0, True, -3, False, 9, 255,  	0,0,"", 0)
			AddENTBbuttons(temp7, temp5+temp2*3, temp, temp2, 			Array As Int(1,0,0,2,2))
			AddENTBbuttons(temp7, temp5+temp2*4+temp, temp, temp2, 		Array As Int(0,0,0,2,2))
			
			LCARSeffects7.AddWallpaperLCAR("RND", 0, temp7+temp2*3 + temp*1.5, temp5+temp2*3, temp*3+temp2, temp*2+temp2, 0,0, LCAR.LCAR_Random, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, 0, 0, "", 0)
	End Select
	msdWidth=Max( msdWidth,LastX)
	If ConsoleID=34 Then msdWidth = Max(temp4-temp7, msdWidth)
	Games.ImagePackDone("bridge.ogg")
	EnumIDs
	'http://www.jedi-counsel.net/s/startrek/decks/saucer/a-deck-01/bridge/06-tac/
	Log("FPS actual: " & FramesPerSecond & " FPS setting: " & Settings.Getdefault("FPS", 0))
End Sub

'Quantities: -1=Random, 0=Empty, above 0=number of Widths (1.5*height) the button will be
'Starts adding buttons at X+Whitespace*2
'Returns the width of all the buttons+whitespace + whitespace*3
Sub AddENTBbuttons(X As Int, Y As Int, Height As Int, WhiteSpace As Int, Quantities() As Int) As Int 
	Dim temp As Int, Width As Int = Height * 1.5, tempWidth As Int, TotalWidth As Int, FontSize As Int = LCAR.Fontsize*0.5
	If Quantities.Length> 1 Then X=X+WhiteSpace*2
	For temp = 0 To Quantities.Length - 1 
		tempWidth = Width 
		If Quantities(temp) < 0 Then Quantities(temp) = Min(1,Rnd(0,10))
		If Quantities(temp) > 1 Then tempWidth = tempWidth * Quantities(temp) + WhiteSpace * (Quantities(temp) -1)
		If Quantities(temp) > 0 Then AddLCAR("BTN" & LCARelements.Size, 0, X, Y, tempWidth, Height, 0,0, LCARSeffects7.RNDENTcolor, LCAR.Legacy_Button, Rnd(10,100), "", "",  0, True, FontSize, True, 9, 255)
		tempWidth=tempWidth+WhiteSpace
		X = X + tempWidth
		TotalWidth=TotalWidth+ tempWidth
	Next
	Return TotalWidth + WhiteSpace * 3
End Sub
Sub AddENTBmeters(X As Int, Y As Int, Width As Int, Height As Int, WhiteSpace As Int, StartingID As Int, Quantities() As Int, ElementType As Int)
	Dim temp As Int, tempWidth As Int
	If Quantities.Length> 1 Then X=X+WhiteSpace*2
	For temp = 0 To Quantities.Length - 1
		tempWidth = Width
		If Quantities(temp) > 1 Then tempWidth = tempWidth * Quantities(temp) + WhiteSpace * (Quantities(temp) -1)
		If Quantities(temp) > 0 Then AddLCAR("MTR" & StartingID, 0, X, Y, tempWidth, Height, 0,0, LCAR.Classic_Blue, ElementType, API.RandomText(2), "", "", 0, True, StartingID, True, 0, 255)
		X = X + tempWidth + WhiteSpace
		StartingID = StartingID + 1
	Next
End Sub

Sub AddTransporterSlider(Name As String, X As Int, Y As Int, Width As Int, MaxY As Int, Text As String, Group As Int)
	Dim Temp As Int ,ID As Int ,WhiteSpace As Int ,temp2 As Int,temp3 As Int
	WhiteSpace=5
	
	ID=1
	Temp = Floor( (Y-10) / (Width+WhiteSpace))'how many units will fit
	temp2= Y - (Width+WhiteSpace)*Temp - WhiteSpace*2
	AddLCAR(Name & "T1", 0 , X, temp2+10, Width,Width, 0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button , "","","", Group, True, 0, True, -2, 255)'curved top
	temp2 = temp2 + 10
	For temp3 = 2 To Temp 'Step Width+WhiteSpace
		temp2 = temp2 + Width+WhiteSpace
		ID=ID+1
		AddLCAR(Name & "T" & ID, 0 , X, temp2, Width,Width, 0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button , "","","", Group, True, 0, True, -1, 255)
	Next
	
	AddLCAR(Name & "M", 0,X, Y,  Width+1, LCAR.ItemHeight, 0,0,LCAR.LCAR_Orange, LCAR.LCAR_Button,Text, "","", Group,True, 6,True, 0,255)
	
	Temp = Y+ LCAR.ItemHeight + LCAR.LCARCornerElbow2.height
	AddLCAR(Name & "L1", 0 , X, Temp, Width,Width, 0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button , "","","", Group, True, 0, True, -1, 255)
	AddLCAR(Name & "L2", 0 , X, Temp+Width+WhiteSpace, Width,Width, 0,0, LCAR.LCAR_DarkYellow, LCAR.LCAR_Button , "","","", Group, True, 0, True, -3, 255)'curved bottom
	
	SetGroup(Group,False)
End Sub












Sub SetMSDwidthSquare(Width As Int, Height As Int)
	msdHeight=Height-TOP-BOTTOM
	'Log("DDisrunning: " & DDisrunning)
	If DreamService.DDisrunning Or DDisrunning Then
		msdWidth=Width
	Else
		msdWidth = Max(Width,msdHeight)
	End If
End Sub

Sub LWM_VisibilityChanged (Engine As LWEngine, Visible As Boolean)
	IsVisible=Visible
	'Log("LWP Visibility: " & Visible & " " & Widgets.OnlyWhenLWPisVisible & " " & Widgets.OnlyWhenScreenIsOn)
	If Visible Then
		DDisrunning=False
		SetupLCARS(Engine.Canvas)
		SetupRandomNumbers(CurrentSection, False)
	Else
		PCARframeID=-1
	End If
	If Widgets.OnlyWhenLWPisVisible Or Widgets.OnlyWhenScreenIsOn  Then 	API.startWidgets
	SamsungUp
End Sub
Sub SetupLCARS(BG As Canvas)
	'If Not(LCAR.LCARCorner.IsInitialized) Then LCAR.LoadLCARSize(BG) 	
End Sub

Sub LWM_Touch (Engine As LWEngine, Action As Int, X As Float, Y As Float)
	'Log("LWM: " & Action & " " & X & " "  & Y)
	If HandleTouch(Action,X,Y) Then LWM_Refresh(Engine, False)
End Sub

Sub HandleTouchP(Action As Int, P As Point) As Boolean 
	Return HandleTouch(Action, P.X, P.Y)
End Sub
Sub HandleTouch(Action As Int,X As Int, Y As Int)As Boolean 
	Dim Act As Point ,temp As Int , Element As LCARelement 
	'Log("HandleTouch: " & Action & " " & X & " "  & Y)
	Select Case CurrentSection
		Case 0'alert
			If Action = LCAR.Event_Down Then LCAR.SwapMode(-1,  1, False)
		Case 6,7'PTOE/AFM PTOE
			Y=Y-TOP-BOTTOM
			If Action = LCAR.event_down Then 
				LCARSeffects2.PToEHandleMouse(X-X2,Y,LCAR.event_down)
				LCARSeffects2.PToEHandleMouse(X-X2,Y,LCAR.event_up)
			End If
		
		Case 10,14,16,22,28,33,34, 36,37'consoles (Number 1, transporter, shuttles, CONN, OPS, TOS bridge, NX-01 bridge, Transporter 2, Corridor)
			If LogCursor(Action, X,Y) Then Return True
		
		Case 30'Romulan clock
			If PreviewMode And Action = LCAR.event_down Then
				LCARSeffects5.ROM_LastUpdate=-1
				Return True
			End If
		
		Case 35'tactical
			LCARSeffects5.TouchTactical(X,Y, Action, msdWidth, msdHeight)
			
		Case 40'romulan 
			If Action = LCAR.Event_Move Then Action = LCAR.Event_Move_Absolute
			Wireframe.CRD_HandleMouse(X,Y, Action, msdWidth, msdHeight)
			
	End Select
	
	'Log(MediaControls & " " & DDisrunning & " " & Action & " " & LCAR.Event_Down)
	If MediaControls And DDisrunning And Action = LCAR.Event_Down Then
		temp = FindClickedElement(X,Y,True)
		If temp>-1 Then 
			Element = LCARelements.Get(temp)
			Log(Element.Tag )
			Select Case Element.Tag 
				Case "MEDIA_PLAY":	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE)
				Case "MEDIA_NEXT": 	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_NEXT)
				Case "MEDIA_PREV": 	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_PREVIOUS)
				Case "MEDIA_STOP": 	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_STOP)
				Case "MEDIA_FFD": 	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_FAST_FORWARD)
				Case "MEDIA_REW": 	API.SendMediaButton(KeyCodes.KEYCODE_MEDIA_REWIND)
			End Select
		End If
	End If

	Select Case SamsungMode
		Case 0'disabled
			SamsungCursorCount=0
		Case 1'passive
			Act=ParseAction(Action)
			Select Case Act.Y 'up/down are reversed for some reason!
				Case LCAR.event_up
					If Act.X=0 Then SamsungCursorCount=0
					SamsungCursorCount=SamsungCursorCount+1
					If SamsungCursorCount=1 Then SamsungX= X
					API.DebugLog("Passive Down: " & X)
				Case LCAR.event_down
					SamsungCursorCount=SamsungCursorCount-1
					API.DebugLog("Passive up")
					'Log("UP " & SamsungCursorCount)
				Case LCAR.Event_Move: 
					If SamsungCursorCount=1 Then 	
						'Log("Moved: " & (SamsungX-X) & " from " & SamsungX2 & " to " & (API.Limit( SamsungX2 + (SamsungX-X),   0, VirtualWidth-PhysicalWidth))) 
						'SamsungX2 = API.Limit( SamsungX2 + (SamsungX-X),   0, VirtualWidth-PhysicalWidth)
						'SamsungX = X
						API.DebugLog("Passive move: " & X)
						SamsungMove(X)
					Else If SamsungCursorCount=0 Then'some down events are missed
						SamsungCursorCount=1
						SamsungX= X
						API.DebugLog("Passive down (missed): " & X)
						'Log("DOWN2 " & SamsungCursorCount & " " & X)
					End If
			End Select
		Case 2'aggressive
			Act=ParseAction(Action)
			If Act.Y = LCAR.Event_Move Then
				If SamsungCursorCount = 0 Then
					SamsungDown(X,Y)
				Else
					temp=Trig.FindDistance(SamsungX,SamsungY, X,Y)
					If temp <SamsungTolerance Then
						SamsungMove(X)
						'SamsungX2 = API.Limit( SamsungX2 + (SamsungX-X),   0, VirtualWidth-PhysicalWidth)
						'SamsungX = X
						SamsungY=Y
					Else
						SamsungDown(X,Y)
					End If
				End If
			End If
	End Select
		
	Return False
End Sub
Sub SamsungMove(X As Int)
	'API.DebugLog("Currently at: " & SamsungX2 & " move by: " & ((SamsungX-X)*0.5) & " VirtualWidth: " & VirtualWidth & " PhysicalWidth: " & PhysicalWidth)
	SamsungX2 = API.Limit( SamsungX2 + (SamsungX-X)*0.5,   0, VirtualWidth-PhysicalWidth)
	SamsungX = X
End Sub
Sub SamsungDown(X As Int, Y As Int)
	'API.DebugLog("Aggressive Down: " & X)
	SamsungX=X
	SamsungY=Y
	SamsungCursorCount=1
End Sub
Sub SamsungUp
	If SamsungMode=2 Then SamsungCursorCount=0
End Sub

Sub ParseAction(Action As Int) As Point 
	Dim Finger As Int
	If Action>5 Then 
		Finger= Floor((Action-5)/256)
		Action = Action - (Finger*256 + 5)
	End If
	Return Trig.SetPoint(Finger,Action)
End Sub
Sub HandleAction(Action As Int)As Point 
	Dim Finger As Int, State As Int 
	If Action=2 Then
		If CursorCount = 1 Then
			State = LCAR.Event_Move 
		Else If CursorCount=0 Then'some down events are missed
			CursorCount=CursorCount+1
			State = LCAR.Event_Down 
		Else 
			Return Trig.SetPoint(-1, -1)
		End If
	Else
		If Action>5 Then 
			Finger= Floor((Action-5)/256)
			Action = Action - (Finger*256 + 5)
		End If
		If Finger=0 Then CursorCount=0
		If Action=0 Then
			CursorCount=CursorCount+1
			State = LCAR.Event_Down 
		Else' If Action=1 Then 
			CursorCount=CursorCount-1
			State = LCAR.Event_Up
		End If
	End If
	Return Trig.SetPoint(Finger, State)
End Sub

Sub LogCursor(Action As Int, X As Int, Y As Int)As Boolean 
	'finger					 0			   1		   2		   3			4
	'2=move		down,up		0,1			261,262		517,518		773,774		1029,1030
	
	Dim State As Int' , tempcursor As Cursor ',tempstr As String 
	'tempcursor.Initialize 
	'tempcursor.Element=-1
'	If Action=2 Then
'		If CursorCount = 1 Then
'			'Finger = FindClosestCursor(X,Y) ' finger will always be 0, as all fingers after the first one are rejected
'			State = LCAR.Event_Move 
'			'tempstr= " move"
'		Else
'			Return
'		End If
'	Else
'		If Action>5 Then 
'			Finger= Floor((Action-5)/256)
'			'Log("finger: " & Finger)
'			Action = Action - (Finger*256 + 5)
'		End If
'		If Action=0 Then
'			CursorCount=CursorCount+1
'			State = LCAR.Event_Down 
'			'tempstr=" down"
'		Else' If Action=1 Then 
'			CursorCount=CursorCount-1
'			State = LCAR.Event_Up
'			'tempstr=" up"
'		End If
'	End If
	State = HandleAction(Action).Y 
	If State>-1 Then HandleElement(State,X,Y)
	
'	tempcursor=HandleElement(tempcursor,X,Y)
'	If Finger > Cursors.Size-1 Then 
'		Cursors.Add(tempcursor)
'	Else If Finger>-1 Then
'		Log("SETTING FINGER " & Finger & " of " & Cursors.Size)
'		Cursors.Set(Finger, tempcursor)
'	End If
	'Log(NeedsRefresh)
	Return NeedsRefresh
	'Log("Finger: " & Finger & " (" & X & ", " & Y & ") ID: " & tempcursor.Element & tempstr)
End Sub

Sub EnumIDs
	'randomize one of the sections, then randomly select an element. if it's an elbow, re-randomize. if it has a group>-1 then use the group id
	Dim temp As Int, CurrElement As LCARelement',  MaxGroup As Int = -1 'main.Settings 
	If Main.DOS=-1 Then'omega is not unlocked 
		OmegaUnlock = Main.Settings.GetDefault("OmegaUnlock", "")
		If OmegaUnlock.Length=0 Then
			If CurrentSection=10 Then'number 1
				If Rnd(0,25)=0 Then OmegaUnlock = "S10E4"
			Else
				Do Until OmegaUnlock.Length>0 Then
					temp = Rnd(0, LCARelements.Size)
					CurrElement = LCARelements.Get(temp)
					If CurrElement.ElementType <> LCAR.LCAR_Elbow And CurrElement.Enabled  Then
						If CurrElement.Group=-1 Then
							OmegaUnlock = "S" & CurrentSection & "E" & temp
						Else
							OmegaUnlock = "S" & CurrentSection & "G" & CurrElement.Group
						End If
					End If
				Loop
			End If
		End If
	End If
End Sub
Sub HandleID(ElementID As Int)
	Dim GroupID As Int , Element As String 
	If ElementID <> -1 And isInPmode And Main.DOS<0 Then 
		If ElementID<-1 Then GroupID= Abs(ElementID+2)
		Element = "S" & CurrentSection & API.IIF(ElementID<-1, "G" & GroupID, "E" & ElementID)
		'Log("OmegaUnlock: " & OmegaUnlock & " Element: " & Element)
		If OmegaUnlock.EqualsIgnoreCase(Element) Then
			Main.DOS = 9999
			CallSubDelayed3(Main, "ShowSection",-2,False)
		End If
	End If
End Sub

Sub HandleElement(State As Int, X As Int, Y As Int) As Int 
	Dim Element As Int ,Element2 As Int ,Element3 As Int, Element4 As Int, TempElement As LCARelement , Dimensions As tween 
	'tempcursor.Loc = Trig.SetPoint(X,Y)
	If State = LCAR.Event_Up Then
		Element=-1
		'MouseState = False
		SetGroup(CursorID, False)
		Select Case CurrentSection
			Case 33: LCARSeffects3.HandleTOSButton(-1,X,Y, LCAR.Event_Up)'TOS Bridge
		End Select
		'Log("UP " & CursorID)
	Else
		Element=FindClickedElement(X,Y, False)
		If Element<-1 Then Element4= Abs(Element+2)
		If Element>-1 Then 
			Select Case CurrentSection
				Case 33'add sections here that need the X/Y within an element
					TempElement = LCARelements.get(Element)
					Dimensions=LCAR.ProcessLoc2( TempElement.LOC, TempElement.Size)
					X = X - Dimensions.currX 
					Y = Y - Dimensions.currY 
			End Select
		End If
		
		'If Element <> CursorID Then 'tempcursor.Element Then 
		Select Case CurrentSection
			'Case 10'number 1
			Case 14'transporter
				If Element<-1 Then
					Select Case Element4
						Case 18,19,20'sliders
							'Log(Element4 & "ITS A SLIDER")
							Element2=FindClickedElement(X,Y, True)
							Element3=FindGroupIndex(Element2,Element4,True)
							If CursorID<>Element4 Then HandleID(Element)
							SetGroup(CursorID, False)'old group is false
							CursorID=Element4
							Element = Element4
							
							If Element3 =0 And isInPmode Then' LCAR.PlaySound(Element4+16, False)' sound 34,35,36 (TOS,TNG,VOY transporter)
								Games.PlayFile(Element4-18)
							End If
					End Select
				End If
			'Case 16'shuttles
			Case 33'TOS Bridge
				LCARSeffects3.HandleTOSButton(Element,X,Y,State)
		End Select
		
		'Log(Element & " " & X & " " & Y )Log(Element & " " & X & " " & Y )
		If Element <> CursorID Then 'tempcursor.Element Then 
			SetGroup(CursorID, False)'old group is false
			SetGroup(Element, True)		'new group is true
			
			HandleID(Element)
'			If Element <> -1 Then 
'				Log("Element: " & CurrentSection & "." & API.IIF(Element<-1, "G:" & Element4, "E:" & Element))
'			End If
		End If
	End If
	
	CursorID=Element
	'tempcursor.Element=Element
	'Log("tempcursor.Element " & CursorID)
	Return CursorID
End Sub
Sub FindGroupIndex(ElementID As Int, GroupID As Int,SetDown As Boolean ) As Int
	Dim Group As LCARgroup,Temp As Int ,DoIT As Boolean , Element As LCARelement , temp2 As Int, Ret As Int
	Group = LCARGroups.Get( GroupID)
	Group.Visible=False
	Ret=-1
	For Temp = 0 To Group.LCARlist.Size-1
		temp2= Group.LCARlist.Get(Temp)
		'Log("Element: " & temp & " of group " & GroupID & " is " & temp2 & " looking for " & ElementID)
		If temp2 = ElementID Then 
		 	If SetDown Then 
				'Log("Element index clicked: " & temp)
				DoIT=True
				Ret=Temp
			Else
				Return Temp
			End If
		End If
		If SetDown Then
			Element = LCARelements.Get( temp2 )
			Element.IsDown=DoIT
			Element.IsClean=False
			NeedsRefresh=True
		End If
	Next
	Return Ret
End Sub

Sub SetGroup(GroupID As Int, State As Boolean)
	Dim Group As LCARgroup, Element As LCARelement  'Group.Visible 
	If GroupID<-1 Then
		GroupID=Abs(GroupID+2)
		If GroupID>-1 And GroupID < LCARGroups.Size Then
			Group = LCARGroups.Get( GroupID)	
			If Group.Visible <> State Then
				Group.Visible=State
				NeedsRefresh=True
				'Log(GroupID & " changed to " & State)
			End If
		End If
		Select Case CurrentSection & "." & GroupID
			Case 14.18,14.19,14.20: Return
		End Select
	Else If GroupID>-1 Then
		Element = LCARelements.Get(GroupID)
		If Element.IsDown <> State Then
			'Log("ELEMENT: " & GroupID & " changed to " & State)
			Element.IsDown= State
			Element.isclean=False
			NeedsRefresh=True
		End If
	End If
	If State And isInPmode Then 
		Select Case CurrentSection'10,14,16,22'consoles (Number 1, transporter, shuttles, CONN)
			Case 10, 14, 16, 22, 28,36,37'number 1, transporter, shuttles, conn, ops, transporter 2
				PlayRandomBeep(False) 'LCAR.PlaySound( LCAR.FindSound("BEEP 4"), False)
		End Select
	End If
End Sub


Sub PlayRandomBeep(Init As Boolean)
	Dim temp As Int ,temp2 As Int 
	If isInPmode Then
		If Init Then
			Games.InitAudioPool(5)
			'transporters
			Games.LoadAudioFile(34)'transporter 1 = 0 (group 18)-18
			Games.LoadAudioFile(35)'transporter 2 = 1 (group 19)-18
			Games.LoadAudioFile(36)'transporter 3 = 2 (group 20)-18
			'beeps
			For temp = 1 To 99
				temp2 = LCAR.FindSound("BEEP " & temp)
				If temp2=-1 Then 
					temp = 100
				Else
					Games.LoadAudioFile(temp2)
				End If
			Next
		Else If Main.Keytones And LCAR.cVol>0 Then ' LCAR.PlaySoundAnyway(API.IIF(KeyToneIndex=1, Rnd(9,12),KeyToneIndex+7))
			temp=Main.KeyToneIndex'0=disabled, 1=random, 2=beep 1, 3=beep 2, 4=beep 3, 5=beep 4
			If temp > 0 Then
				If Main.KeyToneIndex =1 Then temp = Rnd(3,Games.AudioFiles.Size) Else temp = temp+1
				Games.PlayFile(temp)
				'LCAR.PlaySoundAnyway( LCAR.FindSound("BEEP " & (temp-1)) )
				LCAR.Rumble(1)
			End If
		End If
	End If
End Sub

'Sub FindClosestCursor(X As Int, Y As Int) As Int 
'	Dim temp As Int , Index As Int, Distance As Int  , tempcursor As Cursor ,tempDistance As Int 
'	For temp = 0 To Cursors.Size-1
'		tempcursor=Cursors.Get(temp)
'		If tempcursor.State <> LCAR.Event_Up Then 
'			Index=Index+1
'			Distance=temp
'		End If
'	Next
'	If Index=0 Then 
'		Return -1
'	Else If Index = 1 Then
'		Return Distance
'	Else
'		Index=-1
'		For temp = 0 To Cursors.Size-1
'			tempcursor=Cursors.Get(temp)
'			If tempcursor.State <> LCAR.Event_Up Then
'				tempDistance = Trig.FindDistance( tempcursor.Loc.X, tempcursor.Loc.Y, X,Y)
'				Log(temp & " Distance: " & tempDistance)
'				If Index=-1 OR tempDistance<Distance Then
'					Index=temp
'					Distance=tempDistance
'					If Distance = 0 Then temp = Cursors.Size 
'				End If
'			End If
'		Next
'		Return Index
'	End If
'End Sub

Sub LWM_OffsetChanged (Engine As LWEngine)
	IsClean=False
	LWM_Refresh(Engine,False)
End Sub
Sub LWM_SizeChanged (Engine As LWEngine)
	SettingsLoaded=False
	IsClean=False
	SamsungUp
	LWM_Refresh(Engine,False)
End Sub

Sub SystemTick
	If LastSec <> DateTime.GetSecond(DateTime.Now) Then
		LastSec = DateTime.GetSecond(DateTime.Now)
		Select Case CurrentSection
			Case 34'Enterprise
				Flicker(LCAR.ENT_Button, False)
			Case 49'TMP HELM
				Flicker(LCAR.Legacy_Button, True)
		End Select
	End If
		
End Sub

Sub LWM_Tick (Engine As LWEngine)
	SystemTick
	If NeedsRefresh Or RefreshesLive Or SamsungCursorCount>0 Then LWM_Refresh(Engine,True)
	If NeedsReset Then
		lwm.StopTicking
		lwm.StartTicking(API.IIF(Delay=0,1000,Delay))
		NeedsReset=False
	End If
End Sub

Sub Flicker(ElementType As Int, Smooth As Boolean) 
	Dim temp As Int, tempElement As LCARelement 
	For temp = 0 To LCARelements.size-1
		tempElement = LCARelements.Get(temp)
		If tempElement.ElementType = ElementType Then
			If tempElement.Visible Then
				If Rnd(0,6) = 0 Then 
					If Smooth Then 
						tempElement.Opacity.Desired = 0
					Else 
						tempElement.Visible = False
					End If
				End If
			Else
				Select Case ElementType
					Case LCAR.ENT_Button 
						If tempElement.lwidth = -1 Then tempElement.ColorID = LCARSeffects3.ENTcolor(-1)
						tempElement.Text = LCARSeffects2.RandomENT
						tempElement.Align = Rnd(0,2)
					Case LCAR.Legacy_Button
						tempElement.ColorID = LCARSeffects7.RNDENTcolor
						If IsNumber(tempElement.Text) Then tempElement.Text = Rnd(10,100)
				End Select
				tempElement.Visible = True
				tempElement.Opacity.Desired = 255
			End If
		End If
	Next
	NeedsRefresh=True
End Sub

Sub AddGroup
	Dim group As LCARgroup
	group.Initialize 
	group.LCARlist.Initialize 
	group.HoldList.Initialize 
	group.Visible = False 
	LCARGroups.Add(group)
End Sub

Sub ForceGroupCount(Count As Long)
	Dim Temp As Long
	If Not(LCARGroups.IsInitialized ) Then LCARGroups.Initialize 
	For Temp = LCARGroups.Size To Count
		AddGroup
	Next
End Sub

Sub AddLCARtoGroup(LCARid As Int, GroupID As Int)
	Dim Group As LCARgroup
	If GroupsEnabled And GroupID>-1 Then
		ForceGroupCount(GroupID+1)
		Group = LCARGroups.Get(GroupID)
		Group.LCARlist.Add(LCARid)
		Group.HoldList.add(1)
		LCARGroups.Set(GroupID,Group)
	End If
End Sub

Sub FindElementsGroup(LCARid As Int) As Point 'X = group, Y=index in group
	Dim Element As LCARelement ,Group As LCARgroup,Ret As Point 
	Element = LCARelements.Get(LCARid)
	Ret.Initialize 
	Ret.X = Element.Group 
	Group = LCARGroups.Get(Element.Group)
	Ret.Y=Group.LCARlist.IndexOf(LCARid)
	Return Ret
End Sub 
Sub FindClickedElement(X As Int, Y As Int, GetIndex  As Boolean ) As Int 
	Dim Temp As Int ,Dimensions As tween , Element As LCARelement 
	For Temp = LCARelements.Size-1 To 0 Step -1 '0 To LCARelements.Size-1
		Element = LCARelements.Get(Temp)
		If Element.ElementType<> LCAR.LCAR_Elbow And Element.Enabled Then
			Dimensions=LCAR.ProcessLoc2( Element.LOC, Element.Size)
			If LCAR.IsWithin(X,Y, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, False) Then
				If Element.Group = -1 Or GetIndex Then
					Return Temp
				Else
					Return -2 - Element.Group
				End If
			End If
		End If
	Next
	Return -1
End Sub

Sub LWM_Refresh(Engine As LWEngine,Increment As Boolean )
	If isInPmode Or PreviewMode Then 
		SettingsLoaded = False
		isInPmode=False
		PreviewMode=False
	End If
	SetupLCARS(Engine.Canvas)
	PhysicalWidth = Engine.ScreenWidth
	PhysicalHeight=Engine.ScreenHeight
	VirtualWidth=Engine.FullWallpaperWidth
	If UseWidthinstead>0 Then VirtualWidth=UseWidthinstead	
	If Engine.IsPreview Then VirtualWidth= PhysicalWidth
	NeedsRefresh=False
	LoadSettings(Engine.Canvas, VirtualWidth,PhysicalHeight, PhysicalWidth )
	Landscape= PhysicalWidth>PhysicalHeight
	If DrawScreen(Engine.Canvas , Increment, API.IIF(SamsungMode>0,SamsungX2, Engine.CurrentOffsetX), VirtualWidth, PhysicalHeight, PhysicalWidth ) Then 
		If Darken > 0 Then LCAR.DrawRect(Engine.Canvas, 0,0, PhysicalWidth+1,PhysicalHeight+1, Colors.ARGB(Darken, 0,0,0),0)
		Engine.Refreshall
	End If
End Sub


Sub DrawScreen(BG As Canvas, Increment As Boolean,X As Int, Width As Int, Height As Int , WidthofScreen As Int )As Boolean 
	Dim Temp As Int, Element As LCARelement ', PCARframe As Int 
	If BG = Null Then Return False
	LCAR.IsInternal=False
	LCAR.OvalHeight = 0
	If Increment Then LCARSeffects2.ENTcanupdatewave=True
	PCARframeID=0
	If UseWidthinstead>0 Then  X=UseXinstead
	If CurrentSection = 11 Then
		DrawMSD(BG, Increment,X,Width,Height-TOP-BOTTOM,WidthofScreen)
		Return True
	Else
		If Not(IsClean) Then BG.DrawColor(Colors.Black)
		If SSM Then
			X2= msdWidth  * (X/Width)
		Else
			X2 = (msdWidth-WidthofScreen)  * (X/(Width-WidthofScreen))
		End If
		If LCARelements.IsInitialized Then
			LCAR.IsClean=False
			LCAR.didIncrementNumbers=False
			For Temp = 0 To LCARelements.Size-1
				Element=LCARelements.Get(Temp)
				If Increment Or ENTmode Then
					If Increment Then
						If LCAR.IncrementElement(Temp, Element, 5,10) Then Element.IsClean=False
						If Element.ElementType = LCAR.LCAR_PToE Then msdWidth = LCARSeffects2.PTOESIZE 
					End If
				End If
				If Not(IsClean) Or Not(Element.IsClean) Then
					LCAR.DrawElement(BG, -999, Temp, False) 'Then Drawn = True 
					Element.IsClean=True
				End If 
				If ENTmode Then
					If IsPCARSframe(Element.ElementType) Then PCARframeID=PCARframeID+ENTbuttons
				End If
			Next
		Else 
			LCAR.DrawTextbox(BG, API.GetString("no_wall_loaded"), LCAR.LCAR_Red, X2, Height/2,Width,10, 5)
			'Drawn=True
		End If
		If PreviewMode Then LCAR.HandleVolume(BG, True)
'		If X<> OldX Then
'			If DebugLog("X=" & X & " X2=" & X2 & " W=" & Width & " H=" & Height & " WoS=" & WidthofScreen) Then
'				LCAR.DrawTextbox(BG, "LOG FILE WRITTEN TO SD CARD", LCAR.LCAR_Red, 0, Height/2,Width,10, 5)
'			End If
'			OldX=X
'		End If
		'IsClean=True
		Return True' Drawn
	End If
End Sub

Sub DrawMSD(BG As Canvas, Increment As Boolean,X As Int, Width As Int, Height As Int , WidthofScreen As Int )
	Dim TempX As Int ,  MSD As Bitmap 
	If LCARSeffects2.CenterPlatform.IsInitialized Then
	
		BG.DrawColor(Colors.Black)
		MSD=LCARSeffects2.CenterPlatform
		If msdWidth = 0 Then
			If DoScale Then 
				msdHeight = Min(MSD.Height , Height)'   Bottom - TempY)
			Else
				msdHeight=Height
			End If
			msdWidth  =  msdHeight * (MSD.Width/MSD.Height) ' (MSD.Height/MSD.Width) * msdHeight
			msdY= Height/2- msdHeight/2 '+ Cellheight
			'msdY = (Bottom - TempY)/2 + TempY - MSD.Height/2
		End If
		
		
		'TempY=TOP+ msdY
		'LCAR.DrawLCARbutton(BG, -X,    TempY,    Width, LCAR.ItemHeight,   LCAR_Orange, False, "", "", 20,20,True, 2, 0,-1,255,False)
		'TempY=TempY+Cellheight
		'LCAR.DrawText(BG, -X, TempY, "GALAXY CLASS              U.S.S. ENTERPRISE", LCAR_Pink, 1,False,255,0)
		'LCAR.DrawText(BG, -X+Width, TempY, "NCC-1701D", LCAR_Pink, 3,False,255,0)
		'TempY=TempY+Cellheight
		
		'LCAR.DrawLCARbutton(BG, -X,  Bottom,    Width, LCAR.ItemHeight,   LCAR_Orange, False, "", "", 20,20,True, 2, 0,-1,255,False)
		
		'Log(  (X/Width) & " - " & (msdWidth  * (X/Width))   )
		If SSM Then
			TempX = msdWidth  * (X/Width)
		Else
			TempX = (msdWidth-WidthofScreen)  * (X/(Width-WidthofScreen))
		End If
		
		BG.DrawBitmap(MSD, Null, LCAR.SetRect( -TempX, msdY,msdWidth, msdHeight) )
	End If
End Sub