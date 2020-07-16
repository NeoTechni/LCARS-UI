B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
#End Region

'Widget names are in lcarseffects3.WidgetTypes
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim rv As RemoteViews
	Type WidgetPackage(BG As Canvas, Loc As Rect, WidgetID As Int,Alpha As Int)
	Type WidgetUpdate(WidgetID As Int, NextUpdate As Long, Value1 As Int)
	Dim WidgetUpdates As List ,ExpectedDataType As Int = -1 ,PreviewMode As Boolean , PE As PhoneEvents, OnlyWhenScreenIsOn As Boolean, NeedsRefreshing As Boolean = True
	Dim mAppWidgetIdList As List, CurrentWidget As Int = -1, HasDrawnWidgets As Boolean ,UpdateTime As Int =10
	Dim LauncherWidgets As List ,LauncherSettings As Map ,AndroidWidgets As List, OnlyWhenLWPisVisible As Boolean ,AnimationDelay As Int = 250
	
	Dim StardateMode As Int = 1, LockStardateMode As Boolean, Xpos As Int, Ypos As Int,BlankType As Int = -1
	Dim Reminders As List , MICpic As Bitmap, LastRefresh As Long, WasClicked As Boolean  ', needsload As Boolean 
End Sub

Sub GetBlankType As Int 
	If BlankType = -1 Then BlankType = LCARSeffects3.WidgetTypes.Size - 1
	Return BlankType
End Sub
'KEYEVENTS

'Sub GetBA As JavaObject
'	Dim jo As JavaObject, cls As String = Me
'	cls = cls.SubString("class ".Length)
'	jo.InitializeStatic(cls)
'	Return jo.GetFieldJO("processBA")
'End Sub
'Sub GetContext As JavaObject
'  	Return GetBA.GetField("context")
'End Sub
'Sub sendOrderedBroadcast(theIntent As Intent, Action As String)
'	Dim P As Phone
'	P.SendBroadcastIntent(theIntent)'method 1
'	'GetContext.RunMethod("sendOrderedBroadcast", Array As Object(theIntent,Action))'method 2
'End Sub

Sub SendMediaButton2(Keycode As Int)
	API.SendMediaButton(Keycode)'method 1 and 2
End Sub
'KEYEVENTS


Sub Phone_ScreenOff (Intent As Intent)
	CallSubDelayed2(STimer, "Phone_ScreenOff", Intent)
End Sub
Sub Phone_ScreenOn (Intent As Intent)
	CallSubDelayed2(STimer, "Phone_ScreenOn", Intent)
End Sub

Sub ScreenState As Boolean 
	If LCAR.BGisInit Then Return False
	If OnlyWhenLWPisVisible Then Return WallpaperService.IsVisible
	Return STimer.ScreenState 
End Sub

Sub LauncherDir As String 
	Return File.DirDefaultExternal.Replace(".test", ".launcher")
End Sub
Sub LoadLauncherWidgets As Boolean 
	LauncherWidgets.Initialize 
	Try
		If File.Exists(LauncherDir, "widgets.ini") Then
			LauncherSettings= File.ReadMap(LauncherDir, "widgets.ini")
			If LauncherSettings.Size >0 Then LauncherWidgets.AddAll( Regex.Split(",", LauncherSettings.Get("widgets")) )
		End If
		AddWidgetsToList(mAppWidgetIdList, AndroidWidgets, LauncherWidgets)
		'needsload = False
		Return True
	Catch
		'needsload = True
		StartServiceAt("", DateTime.Now + DateTime.TicksPerSecond, True)
		Return False
	End Try
End Sub



Sub RefreshAllOfOneType(WidgetType As Int)
	Dim TempWidgetType As Int , WidgetIndex As Int , WidgetID As Int ',temp As Int 
	For WidgetIndex = 0 To mAppWidgetIdList.Size - 1
		If IsNumber(mAppWidgetIdList.Get(WidgetIndex)) Then
			WidgetID=mAppWidgetIdList.Get(WidgetIndex)
			TempWidgetType = GetSetting(WidgetID, "Type", -1)
			If TempWidgetType = WidgetType Then UpdateWidget(rv, WidgetID)
		End If
	Next
End Sub

Sub RefreshAll(Index As Int) As Boolean 
	Dim temp As Int ,WasRedAlert As Boolean = LCAR.setredalert(False, "Widget.Refresh.1")
	'Log("Refresh: " & Index & " " & OnlyWhenScreenIsOn)
	If DateTime.Now - LastRefresh < (DateTime.TicksPerSecond * 5) Then Return False
	If Index = -2 And Not(OnlyWhenScreenIsOn) Then Return False
	If Index= -1 Then
		WidgetUpdates.Initialize 
		If Not(LoadLauncherWidgets) Then Return False
	Else
		temp= FindWidgetID(Index)
		If temp>-1 Then WidgetUpdates.RemoveAt(temp)
	End If
	rv_RequestUpdate
	If WasRedAlert Then LCAR.SetRedAlert(True, "Widget.Refresh.2")
	LastRefresh = DateTime.Now 
	Return True
End Sub

Sub WidgetUpdated(ID As Int) As Boolean 'returns false by default (not animated)
	Dim temp As Int = FindWidgetID(ID), tempW As WidgetUpdate ,WidgetType As Int = GetSetting(ID, "Type", -1)
	If temp=-1 Then 
		tempW.Initialize 
		tempW.WidgetID=ID
		WidgetUpdates.Add(tempW)
	Else
		tempW= WidgetUpdates.Get(temp)
	End If
	'Log("Updating widget: " & ID)
	'"STARDATE", "DOOR PNL", "POWER", "CLOCK", "CALENDAR", "EVENTS"
	Select Case WidgetType'allows for widgets to update faster than once per minute, or ignore the user's setting
		Case 3'clock
			tempW.NextUpdate=DateTime.Now + AnimationDelay
			tempW.Value1 = tempW.value1+1
			If tempW.Value1 = LCARSeffects.OkudaStages Then tempW.Value1 = 0
			Return True'is animated
		
		Case 4,5'calendar,events
			tempW.NextUpdate= Tomorrow	
			
		Case 10, 11, 12'Panel clock, Romulan Clock, Klingon Clock
			tempW.NextUpdate= DateTime.Now + (DateTime.TicksPerSecond*(59-DateTime.GetSecond(DateTime.Now)))'update at next minute
		
		'case 7,8,9'weather widgets
			'update at 0,6,12,18 hours
			'Return False
		
		Case Else
			temp = GetSetting(ID, "Delay", UpdateTime)
			tempW.NextUpdate=DateTime.Now + (DateTime.TicksPerMinute * temp)
	End Select
	Return False
End Sub


Sub Tomorrow As Long
	Dim temp As Long = DateTime.Now + DateTime.TicksPerDay 
	Return API.MakeDate( DateTime.GetYear(temp), DateTime.GetMonth(temp), DateTime.GetDayOfMonth(temp), 0,0,0,0)
End Sub

Sub WidgetNeedsUpdating(ID As Int) As Boolean 
	Dim temp As Int = FindWidgetID(ID), tempW As WidgetUpdate, WidgetType As Int = GetSetting(ID, "Type", -1)
	If WidgetType = GetBlankType Then Return False 
	If NeedsRefreshing Then Return True
	If temp >-1 Then
		tempW=WidgetUpdates.Get(temp)
		Return tempW.NextUpdate <= DateTime.Now Or NeedsRefreshing
	End If
	Return True 
End Sub

Sub WidgetUpdateTime(ID As Int)As Long 
	Dim temp As Int = FindWidgetID(ID), tempW As WidgetUpdate, WidgetType As Int = GetSetting(ID, "Type", -1)
	If WidgetType = GetBlankType Then Return DateTime.Now + DateTime.TicksPerDay
	If temp>-1 Then 
		tempW=WidgetUpdates.Get(temp)
		Return tempW.NextUpdate 
	End If
End Sub

Sub NextWidgetUpdate As Long
	Dim WidgetIndex As Int,WidgetID As Int, Ret As Long, temp As Long 
	For WidgetIndex = 0 To mAppWidgetIdList.Size - 1
		If IsNumber(mAppWidgetIdList.Get(WidgetIndex)) Then
			WidgetID=mAppWidgetIdList.Get(WidgetIndex)
			temp=WidgetUpdateTime(WidgetID)
			If Ret = 0 Or Ret > temp Then Ret = temp
		End If
	Next
	If Ret<DateTime.Now Then Ret=DateTime.Now+100
	If (Ret-DateTime.Now) > DateTime.TicksPerMinute Then
		Ret = Ret + DateTime.TicksPerMinute
		Ret= Ret - (Ret Mod DateTime.TicksPerMinute)	
		If Ret<= DateTime.Now Then Ret = DateTime.Now + (DateTime.TicksPerMinute*10)
	End If
	'Log("Next widget update is in: " & Round2((Ret-DateTime.Now)/DateTime.TicksPerMinute,2) & " minutes")
	Return Ret
End Sub

Sub FindWidgetID(ID As Int) As Int
	Dim temp As Int, tempW As WidgetUpdate 
	If WidgetUpdates.IsInitialized Then
		For temp = 0 To WidgetUpdates.Size-1
			tempW=WidgetUpdates.Get(temp)
			If tempW.WidgetID=ID Then Return temp
		Next
	Else
		WidgetUpdates.Initialize 
	End If
	Return -1
End Sub





Sub Service_Create
	'Set the widget to update every 10 minutes.
	rv = ConfigureHomeWidget("L1", "rv", 10, "LCARS WIDGET",True)
	mAppWidgetIdList.Initialize
	PE.Initialize("PE")
End Sub

Sub WidgetUpdateBundle(StartingIntent As Intent)
	Dim jintent As JavaObject = StartingIntent, widgetOptions As JavaObject = jintent.RunMethod("getBundleExtra", Array As Object("appWidgetOptions")), WidgetID As Int = StartingIntent.GetExtra("appWidgetId"), Width As Int, Height As Int
	
	'http://stackoverflow.com/questions/16801721/calculate-height-of-appwidget
	If API.IsLandscape Then 
		Width = widgetOptions.RunMethod("getInt", Array As Object("appWidgetMaxWidth"))
		Height = widgetOptions.RunMethod("getInt", Array As Object("appWidgetMinHeight"))
	Else 'Portrait
		Width = widgetOptions.RunMethod("getInt", Array As Object("appWidgetMinWidth"))
		Height = widgetOptions.RunMethod("getInt", Array As Object("appWidgetMaxHeight"))
	End If 
	
	Log("Widget: " & Width & "x" & Height)
	
	SetSetting(WidgetID, "Width", Width * 1dip)' * 0.7652173913043478
	SetSetting(WidgetID, "Height", Height * 1dip)
	UpdateWidget(rv, WidgetID)
End Sub
	
Sub Service_Start (StartingIntent As Intent)
	Dim helper() As Int
	API.AutoLoad
	
'	Log("Service_Start")
'	Log(StartingIntent)
'	Log(StartingIntent.ExtrasToString)
'	'Bundle[{appWidgetId=17, appWidgetOptions=Bundle[mParcelledData.dataSize=272]}]
'	If StartingIntent.HasExtra("appWidgetOptions") Then 
'		Log("appWidgetOptions: " & StartingIntent.GetExtra("appWidgetOptions"))
'	End If
'	Log("End_log")
	
	
	'The mAppWidgetIdList keeps track of what widgets we have to update.
	'If there is only one appWidgetId in the starting intent, the list contains just this id.
	'If there is a list of appWidgetIds in the starting intent, then we will fill the mAppWidgetIdList with them.
	'If there is no appWidgetId and no appWidgetId list in the starting intent then the
	'Sub Util.GetWidgetIds() tries to get all ids of the widgets created by this service.
	If StartingIntent.IsInitialized  Then 
		'Is the Service called from a single widget?
		If StartingIntent.HasExtra("appWidgetId") Then
		 	CurrentWidget =StartingIntent.GetExtra("appWidgetId")
		Else
			mAppWidgetIdList.Clear'Clear the list of AppWidgetIds
			If StartingIntent.HasExtra("appWidgetIds") Then'Is there a list of widget ids in the Intent?
				helper = StartingIntent.GetExtra("appWidgetIds")
			Else'Is the Service called manually without any widget ids In starting Intent?
				helper = GetWidgetIds("widgets")
			End If
			AndroidWidgets.Initialize 
			AndroidWidgets.AddAll(helper)
			If Not(LoadLauncherWidgets) Then Return
			'mAppWidgetIdList.AddAll(helper)
		End If
		
		If Not(rv.HandleWidgetEvents(StartingIntent)) Then
			Select Case StartingIntent.Action
				Case "android.appwidget.action.APPWIDGET_UPDATE_OPTIONS" 'If the service is called from the configuration activity, the starting intent has a special action
					'APPWIDGET_UPDATE_OPTIONS: Bundle[{appWidgetId=7, appWidgetOptions=Bundle[mParcelledData.dataSize=272]}]
					If StartingIntent.HasExtra("appWidgetId") And StartingIntent.HasExtra("appWidgetOptions") Then WidgetUpdateBundle(StartingIntent)
					'Widget_UpdateSettings("Resolution change")

				Case "android.appwidget.action.APPWIDGET_DELETED" 'If a widget instance is deleted we can delete its configuration
					Widget_Deleted
				Case "android.intent.action.TIMEZONE_CHANGED", "android.intent.action.TIME_SET","android.appwidget.action.APPWIDGET_UPDATE"'If the time or timezone changed on the device
					RefreshAll(-1)', "Service_Start: intent.action")
					API.ForceAlarmRecheck
				Case "com.omnicorp.lcar.launcher.widget"
					RefreshAll(-1)', "Service_Start: launcher")
				Case Else
					'Log("Widgets.StartingIntent.Action!: " & StartingIntent.Action)
				'Log(StartingIntent.ExtrasToString)
		End Select		
	End If
	
	'If NeedsRefreshing Then Widget_UpdateSettings
	
	'Reschedule the service every minute, so the clock gets updated correctly
	If StartingIntent.Action <> "android.appwidget.action.APPWIDGET_DISABLED" And mAppWidgetIdList.Size>0 Then
		'LCAR.BGisInit: true false true false = false
		'Log("LCAR.BGisInit: " & OnlyWhenScreenIsOn & " " & OnlyWhenLWPisVisible & " " & ScreenState & " " & LCAR.BGisInit & " = " & ((OnlyWhenScreenIsOn OR OnlyWhenLWPisVisible) AND Not(ScreenState) ))
		If (OnlyWhenScreenIsOn Or OnlyWhenLWPisVisible) And (Not(ScreenState) Or LCAR.BGisInit) Then 
			Log("Screen or LWP is not active")
			Return
		End If
		
		SetNextUpdatetime
	End If	
	End If 
End Sub
Sub SetNextUpdatetime
	Dim si As Intent
	si.Initialize("android.appwidget.action.APPWIDGET_UPDATE", "")
	si.SetComponent(GetPackageName & "/.widgets")
	StartServiceAt(si, NextWidgetUpdate  , False)
End Sub
Sub AddWidgetsToList(Destination As List, Src1 As List, Src2 As List)
	Dim temp As Int 
	If Not(Destination.IsInitialized ) Then Destination.Initialize Else Destination.Clear 
	If Not(Src1.IsInitialized) Then Src1.Initialize 
	If Not(Src2.IsInitialized) Then Src2.Initialize 
	
	For temp = 0 To Src1.Size-1
		Destination.Add(Src1.Get(temp))
	Next
	For temp = 0 To Src2.Size-1
		Destination.Add(Src2.Get(temp))
	Next
End Sub
'Sub GetNextStartTime As Long 
'	Dim temp As Long = TimeToNextMinute , Minutes As Int = (Main.Settings.GetDefault("WidgetUpdate", 10) - 1 ) * DateTime.TicksPerMinute 
'	'Log("Minutes till update: " & minutes)
'	If mAppWidgetIdList.Size>0 Then Return NextWidgetUpdate'
'	Return temp + Minutes
'End Sub

Sub Service_Destroy

End Sub

Sub rv_RequestUpdate	
	Dim WidgetIndex As Int,tempstr As StringBuilder,WidgetID As Int ', BG As Canvas
	If Not(ScreenState) And OnlyWhenScreenIsOn Then Return
	tempstr.Initialize 
	For WidgetIndex = 0 To mAppWidgetIdList.Size - 1
		If IsNumber(mAppWidgetIdList.Get(WidgetIndex)) Then
			WidgetID=mAppWidgetIdList.Get(WidgetIndex)
			'Log("WidgetID: " & WidgetID)
			If WidgetNeedsUpdating(WidgetID) Then
				UpdateWidget(rv, WidgetID)
				HasDrawnWidgets=True
			End If
			tempstr.Append( API.IIF(tempstr.Length=0, "", ",") & WidgetID)
		End If
		'BMP.InitializeMutable(320,320)
		'BG.Initialize2(BMP)
		'BG.DrawColor(Colors.Black)
		'LCAR.DrawUnknownElement(BG,0,0, BMP.Width,BMP.Height, LCAR.LCAR_Orange, False, 255, "WIDGET ID: " & CurrentWidget)' LCAR.Stardate(DateTime.Now, False,4))
	Next
	
	
	
	Main.Settings.Put("Widgets", tempstr.ToString)
	'Log("Widgets: " &  tempstr.ToString)
	CurrentWidget=-1
	NeedsRefreshing=False
End Sub

Sub UpdateWidget(prv As RemoteViews, WidgetID As Int)
	Dim BMP As Bitmap, BG As Canvas ,IsAnimated As Boolean 
	If WidgetID>-1 Then
		IsAnimated= WidgetUpdated(WidgetID)
		Log(WidgetID & " isanimated: " & IsAnimated)
		PreviewMode=False
		BMP=DrawWidget(BG,True, WidgetID, 0,0,0,0)
		
		Try 
			If IsAnimated Then
				prv.SetImage("ImageView1", BMP)
			Else
				SetRemoteViewImageBitMap("Widgets", "ImageView1", prv, BMP)
			End If
			SetRemoteViewAlpha("Widgets", "ImageView1", prv,GetSetting(WidgetID,"Alpha", 192))
			SetWidgetClickEvent("Widgets",WidgetID, prv, "ImageView1", "ImageView1")
		Catch 
			Log("WIDGET PICTURE FAILED TO UPDATE")
		End Try 
		'Log("Drawing widget ID: " & WidgetID & " at " & BMP.Width  & "x" & BMP.Height & " " & GetSetting(WidgetID,"Alpha", 192) & "a")
		'SaveBMP(BMP, File.DirRootExternal, WidgetID & ".png")

		UpdateSingleWidget(prv, WidgetID)
		ExpectedDataType=-1
	Else 'if wallpaperservice.UseWidthinstead>0 then
		UpdateLauncher(WidgetID)
		'SaveBMP(BMP,LauncherDir,WidgetID & ".png")
		'API.BroadcastToLauncher2("widget", WidgetID, "Alpha", GetSetting(WidgetID,"Alpha", 192))
	End If
End Sub

Sub GetByteArrayFromBitmap(BMP As Bitmap) As Byte()
	Dim Output As OutputStream 
	Output.InitializeToBytesArray(BMP.Width * BMP.Height )
	BMP.WriteToStream(Output, 100, "PNG") 
	Return Output.ToBytesArray
End Sub

Sub UpdateLauncher(WidgetID As Int)
	Dim BMP As Bitmap, BG As Canvas, WidgetType As Int = GetSetting(WidgetID, "Type", -1)
	If WidgetType < GetBlankType Then 
		If WidgetID = -1 Then
			Widget_UpdateSettings'("UpdateLauncher")
		Else
			TransmitUpdate(WidgetID, DrawWidget(BG,True, WidgetID, 0,0,0,0))
		End If
	End If 
End Sub
Sub TransmitUpdate(WidgetID As Int, BMP As Bitmap)
	Dim IsAnimated As Boolean = WidgetUpdated(WidgetID)
	PreviewMode=False
	If IsAnimated Then
		API.BroadcastToLauncher3("widgetbmp", WidgetID, "Alpha", GetSetting(WidgetID,"Alpha", 192), "BMP", GetByteArrayFromBitmap(BMP))
	Else
		If SaveBMP(BMP,LauncherDir,WidgetID & ".png") Then API.BroadcastToLauncher2("widget", WidgetID, "Alpha", GetSetting(WidgetID,"Alpha", 192))
	End If
End Sub

Sub SaveBMP(BMP As Bitmap, Dir As String, Filename As String) As Boolean 
	If BMP.IsInitialized And File.ExternalWritable Then
		If File.Exists(Dir,Filename) Then File.Delete(Dir,Filename)
		Dim Out As OutputStream = File.OpenOutput(Dir, Filename, False)
		BMP.WriteToStream(Out, 100, "PNG")
		Out.Close
		Return True
	End If
End Sub

Sub rv_Disabled
	StopService("")
End Sub

Sub WidgetClicked(WidgetID As Object)
	CurrentWidget=WidgetID
	ImageView1_Clicked
End Sub

Sub WidgetT As Int
	Try
		Return GetSetting(CurrentWidget, "Type", -1)
	Catch
		Return -1
	End Try
End Sub

Sub ImageView1_Clicked'return to skip the widget update
	Dim theType As Int = WidgetT, IsLCARSlauncher As Boolean, Width As Int, Height As Int', IsRedAlert As Boolean = LCAR.RedAlert 
	'If IsRedAlert Then LCAR.SetRedAlert(False, "W.Imageview.1")
	If CurrentWidget>-2 Then 
		Xpos =-1
		Ypos =-1
	Else
		IsLCARSlauncher=True
		Width=LauncherSettings.Get(CurrentWidget & ".width")
		Height=LauncherSettings.Get(CurrentWidget & ".height")
	End If
	Log(CurrentWidget & " was clicked, type: " & theType & API.IIF(IsLCARSlauncher, " at: " & Xpos & ", " & Ypos &  " IN THE LAUNCHER", ""))
	Select Case theType
		Case -1:
			StartActivity(Main) 
			CallSubDelayed3(Main, "ShowSection", 41 ,False)'not set up yet
		
		Case 0, 5 ,6, 7,8, 9, 10'time,events,text,graphical weather, panel clock
			'Log("BEFORE: " & StardateMode & " AND AFTER: " &  API.ToggleStardatemode(StardateMode))
			If Not(LockStardateMode) Then StardateMode = API.ToggleStardatemode(StardateMode)
			'Widget_UpdateSettings
			
		Case 1,2'door panel,battery
			'UpdateCurrentWidget
			
		Case 3'clock
		
		Case 4'calendar
			API.OpenCalendarApp
		
		Case 11'Romulan Clock
			LCARSeffects5.ROM_LastUpdate=-1
			
		Case 13'Music
			theType=KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE
			If IsLCARSlauncher Then 
				Xpos = Xpos - (LCAR.ItemHeight *0.5)
				Width = Width - LCAR.ItemHeight
				Ypos=Min(2,Floor(Xpos/(Width/3)))
				Select Case Ypos
					Case 0: theType = KeyCodes.KEYCODE_MEDIA_PREVIOUS
					Case 2: theType = KeyCodes.KEYCODE_MEDIA_NEXT
				End Select
			End If
			SendMediaButton2(theType)
			Return 
		
		Case 14'reminders
			StartActivity(Main)
			LCAR.SystemEvent(2, 0)
			Return
		
		Case 15'google
			'Log(Xpos & " " & Max(0, Width - Height*2))
			API.StartGoogleNow( Xpos >= Max(0, Width - Height) )
			Return
		
		Case 17'alarms
			theType=0'Belay
			If IsLCARSlauncher Then 
				If Ypos < Height - LCAR.ItemHeight Then
					theType=1'stardate toggle
				Else If API.BelayTime> DateTime.Now Then
					If Xpos > Width*0.5 Then theType=2'unbelay
				End If
			End If
			Select Case theType
				Case 0,2: API.BelayCurrentAlarm(theType=0)'belay/unbelay
				Case 1: If Not(LockStardateMode) Then StardateMode = API.ToggleStardatemode(StardateMode)'stardate toggle
			End Select
	
	End Select
	WasClicked = True 
	UpdateCurrentWidget
	WasClicked = False 
	'If IsRedAlert Then LCAR.SetRedAlert(True, "W.Imageview.2")
End Sub

Sub UpdateCurrentWidget
	UpdateWidget(rv, CurrentWidget)
End Sub

Sub Widget_Deleted
	DeleteSettings(CurrentWidget)
End Sub

Sub Widget_UpdateSettings'(Why As String)
	NeedsRefreshing=True
	Log("Refresh all widgets")
	RefreshAll(-1)', Why)
End Sub

Sub DrawWidget2(Data As WidgetPackage)
	Dim WidthD As Int =LCARSeffects3.GetSize(Data.loc, True), HeightD As Int =LCARSeffects3.GetSize(Data.loc, False), BMP As Bitmap' = DrawWidget(Data.widgetid,WidthD,HeightD)
	'WidthD = Data.BG.Bitmap.Width
	If Data.Alpha<0 Then Data.Alpha = GetSetting(Data.WidgetID,"Alpha", 192)
	If Data.WidgetID>=-1 Then
		PreviewMode=True
		BMP = DrawWidget(Data.BG ,False, Data.WidgetID, Data.Loc.Left, Data.Loc.Top, WidthD,HeightD)
	Else
		TransmitUpdate(Data.WidgetID, DrawWidget(LCAR.EmergencyBG,False, Data.WidgetID, Data.Loc.Left, Data.Loc.Top, WidthD,HeightD))
	End If
	
	'If Data.alpha<1 Then Data.Alpha= GetSetting(CurrentWidget,"Alpha", 192)
	'If Data.alpha <1 OR Data.alpha>255 Then
'	If BMP.IsInitialized Then
'		Data.BG.DrawBitmap(BMP,Null,Data.Loc)
'	Else
'		LCAR.DrawUnknownElement(Data.BG, Data.Loc.Left, Data.Loc.Top, WidthD,HeightD,LCAR.LCAR_Orange,  False,255, "ERROR")
'	End If
	'Else
	'	LCARSeffects2.DrawBMP(Data.BG, BMP , 0,0, WidthD,HeightD, Data.Loc.Left,Data.Loc.Top , WidthD,HeightD,  Data.Alpha, False,False)
	'End If
End Sub

Sub AutoDrawWidget(BMP As Bitmap, WidgetType As Int)
	Dim BG As Canvas, OverScanX As Int = 20dip
	BG.Initialize2(BMP)
	BG.DrawColor(Colors.Black)
	'DrawWidget(BG, False,WidgetType, 0,0, BMP.Width, BMP.Height)
	DrawWidgetType(BG,OverScanX,0, BMP.Width-OverScanX*2, BMP.Height*0.75, WidgetType, "NOTIFICATION", 0, 3)
End Sub

Sub DrawWidget(BG As Canvas, MakeBG As Boolean , WidgetID As Int, X As Int, Y As Int, Width As Int, Height As Int) As Bitmap 
	Dim BMP As Bitmap,WidgetType As Int , temp As Int ,AA As Boolean = LCAR.AntiAliasing , tempW As WidgetUpdate, IsRedAlert As Boolean = LCAR.RedAlert ,RedAlertColor As Int = LCAR.RedAlertMode 
	Dim WidgetClass As Int = API.IIF(MakeBG, 0,1)
	If IsRedAlert Then LCAR.SetRedAlert(False, "W.Imageview.1")
	If BG= Null Then MakeBG=True
	If WidgetID=-1 Then WidgetID = CurrentWidget
	If WidgetID <> -1 Then
		If WidgetID > -2 Then
			If Width=0 Then Width = GetSetting(WidgetID, "Width",320)
			If Height=0 Then Height= GetSetting(WidgetID, "Height", 320)
			If Width=0 Then Width = 320
			If Height=0 Then Height= 320
		Else
			WidgetClass=2
			Width=LauncherSettings.Get(WidgetID & ".width")
			Height=LauncherSettings.Get(WidgetID & ".height")
		End If
		WidgetType= GetSetting(WidgetID, "Type", -1)
		
		Select Case WidgetType
			Case 3'clock (animated widgets that need Value1)
				temp = FindWidgetID(WidgetID)
				If temp>-1 Then 
					tempW = WidgetUpdates.Get(temp)
				Else
					tempW.Initialize 
				End If
		End Select
		
		If MakeBG  Then
			BMP.InitializeMutable(Width,Height)
			BG.Initialize2(BMP)	
			Select Case WidgetType'widget backgrounds
				Case 1,2,3,10,15,18,19,21'door panel, battery, clock, panel clock, Google now (no background), photos, operations widget
				Case Else: BG.DrawColor(Colors.Black)'(black background)
			End Select
		Else
			LCAR.DrawRect(BG, X,Y,Width+1,Height+1, Colors.Black,0)
		End If
		LCAR.ActivateAA(BG,True)
		DrawWidgetType(BG, X,Y,Width,Height, WidgetType, WidgetID, tempW.Value1, WidgetClass)
	Else
		LCAR.DrawUnknownElement(BG,X,Y, Width,Height, LCAR.LCAR_Orange, False, 255, "ERROR")
	End If
	
	LCAR.AntiAliasing =AA
	If IsRedAlert Then 
		LCAR.SetRedAlert(True, "W.Imageview.1")
		LCAR.RedAlertMode=RedAlertColor
	End If
	Return BMP
End Sub

'WidgetClass: 0=regular widget, 1=inside the app, 2=LCARS Launcher, 3=Expanding notification
Sub DrawWidgetType(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, WidgetType As Int, WidgetID As String, Value1 As Int, WidgetClass As Int)
	Dim temp As Int, IsLCARSlauncher As Boolean = WidgetClass=2, tempstr As String = API.GetString("widget_unknown")
	API.LoadSettings(True, BG)
	If LCARSeffects3.WidgetTypes.Size > WidgetType And WidgetType >-1 Then tempstr = LCARSeffects3.WidgetTypes.Get(WidgetType)
	API.DebugLog("Update Widget: " & WidgetID & " (" & tempstr & ")")
	Select Case WidgetType'LCARSeffects3.WidgetTypes
		Case 0'time
			'LCAR.StarTrekOnline=True
			temp=LCAR.Draw2Elbows(BG,X,Y,Width,Height, LCAR.LCAR_Orange,Main.StarshipID, API.GetString("name_uss") & " " & API.IIF(Main.Starshipname.Length=0, API.GetString("name_unnamed"), Main.Starshipname),False,255)
			LCAR.DrawBGText(BG, X+temp, Y+LCAR.ItemHeight, Width-temp, Height-LCAR.ItemHeight*2-4, 5, LCAR.Stardate(Max(-2,StardateMode),DateTime.Now, True,4), 0, LCAR.LCAR_Orange, False,255,False,False,False)
			
		Case 1'door panel	
			LCARSeffects3.DrawPanel(BG,X,Y,Width,Height, GeneratePanel(-1), GeneratePanel(0), GeneratePanel(1), GeneratePanel(2) )
			
		Case 2'battery
			DrawWidgetMeter(BG,X,Y,Width,Height, LCARSeffects.GetColor( LCAR.Classic_Blue), LCAR.BatteryPercent, API.GetString("widg_aux"))
		
		Case 3'clock
			LCARSeffects.DrawAlert(BG,X+Width/2,Y+Height/2, Min(Width,Height)/2, -1, Value1, 255, 0, "", "", Not(Main.AprilFools))
		
		Case 4'calendar
			LCARSeffects3.DrawMonth(BG,X,Y,Width,Height, 0,0, 255)
			
		Case 5'events
			LCARSeffects3.DrawEvents(BG,X,Y,Width,Height, StardateMode, 0,0,255)
			
		Case 6'text
			LCARSeffects3.DrawTextWidget(BG,X,Y,Width,Height, StardateMode, 255)
		
		Case 7,8'1/5 day weather
			Weather.ChangeUpdateTime(0)
			LCARSeffects3.DrawWeatherTextWidget(BG,X,Y,Width,Height, WidgetType=8, Weather.CurrentWeather,  StardateMode)				
		
		Case 9'Weather graphical
			Weather.ChangeUpdateTime(0)
			LCARSeffects3.DrawGraphicalWeather(BG,X,Y,Width,Height,LCAR.LCAR_RandomColor, Weather.CurrentWeather,  StardateMode, 255)
		
		Case 10'Panel clock
			LCARSeffects3.DrawPanel(BG,X,Y,Width,Height, LCAR.GetColor(LCAR.LCAR_Orange, False,255), DateTime.GetHour(DateTime.Now) & API.PadtoLength(DateTime.GetMinute(DateTime.Now), True, 2, "0"), API.GetString("stardate") & ": " & LCAR.Stardate(StardateMode, DateTime.Now, False,2), API.AbsoluteDateVerbose(DateTime.Now) & "|" & API.GetStringVars("noti_batt", Array As String(LCAR.BatteryPercent)) & API.IIF(LCAR.isCharging, API.GetString("noti_ac"), ""))
		
		Case 11'Romulan Clock
			LCARSeffects5.DrawRomulan(BG,X,Y,Width,Height, -1,-1,-1,-1, False)
		
		Case 12'Klingon Clock
			LCARSeffects5.DrawKlingonClock(BG,X,Y,Width,Height, -1, -1, -2)
			
		Case 13'MUSIC
			DrawMusicWidget(BG,X,Y,Width,Height, LCAR.LCAR_Orange, WidgetClass)
		
		Case 14'Reminders
			DrawReminderWidget(BG,X,Y,Width,Height, LCAR.LCAR_RandomColor)
		
		Case 15'Google now
			DrawGoogleNow(BG,X,Y+Height*0.25,Width,Height*0.5, LCAR.LCAR_Orange, API.GetString("widg_google"), IsLCARSlauncher)
		
		Case 16'Sanctuary district calendar
			LCARSeffects5.DrawSanctuaryDistrictClock(BG, X,Y,Width,Height, DateTime.Now, 255,  Weather.CurrentWeather)
		
		Case 17'Alarms
			DrawTextWidget(BG,X,Y,Width,Height, 0, LCAR.LCAR_Random, IsLCARSlauncher)
		
		Case 18'photos
			DrawPhotoWidget(BG,X,Y,Width,Height, LCAR.LCAR_Random)
		
		Case 19'Operations
			If WasClicked Then 
				LCARSeffects7.DrawOperationsP2(BG,X,Y,Width, Height)
			Else 
				LCARSeffects7.DrawOperations(BG,X,Y,Width, Height, "")
			End If
		
		Case 20'Mondrian
			LCARSeffects7.DrawDatasPainting(BG,X,Y,Width, Height, 0)
		
		Case 21'Captain's Itinerary
			LCARSeffects7.DrawCaptainsWidget(BG,X,Y,Width, Height, DateTime.Now, DateTime.Now + DateTime.TicksPerDay)
		
		Case Else'not set up yet
			LCAR.DrawUnknownElement(BG,X,Y, Width,Height, LCAR.LCAR_Orange, False, 255, API.GetStringVars("widg_setup", Array As String(WidgetID, WidgetType, DateTime.Time(DateTime.Now))))' LCAR.Stardate(DateTime.Now, False,4))
	End Select
	API.DebugLog("Widget success")
End Sub

Sub DrawPhotoWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int) As Boolean 
	Dim Filename As String = API.RandomFile("PhotoWidget", "images"), Thumbsize As Point, BIG As Int = LCAR.ItemHeight, small As Int = BIG * 0.25, Whitespace As Int = LCAR.ListitemWhiteSpace
	If ColorID= LCAR.LCAR_Random Then ColorID = LCAR.LCAR_RandomColor
	If Filename.Length > 0 Then
		If LCARSeffects2.LoadUniversalBMP( API.GetDir(Filename), API.GetFile(Filename), LCAR.LCAR_Widget) Then 
			Filename = API.GetTitle(Filename).ToUpperCase
			If LCARSeffects2.CenterPlatform.Width > LCARSeffects2.CenterPlatform.Height Then'wide
				Thumbsize = API.Thumbsize(LCARSeffects2.CenterPlatform.Width, LCARSeffects2.CenterPlatform.Height, Width-small-Whitespace, Height-BIG-Whitespace, True, False)
				LCAR.DrawLCARelbow(BG,X,Y, Width, Height, small,BIG, -2, ColorID, False, Filename, 4, 255, False)
				X = X + small + Whitespace + (Width - small - Whitespace) * 0.5 - Thumbsize.X * 0.5
				Y = Y + BIG + Whitespace + (Height - BIG - Whitespace) * 0.5 - Thumbsize.Y * 0.5
			Else'height
				Thumbsize = API.Thumbsize(LCARSeffects2.CenterPlatform.Width, LCARSeffects2.CenterPlatform.Height, Width-BIG-Whitespace, Height-small-Whitespace, True, False)
				LCAR.DrawLCARelbow(BG,X,Y, Width, Height, BIG,small, -2, ColorID, False, "", 0, 255, False)
				X = X + BIG + Whitespace + (Width - BIG - Whitespace) * 0.5 - Thumbsize.X * 0.5
				Y = Y + small + Whitespace + (Height - small - Whitespace) * 0.5 - Thumbsize.Y * 0.5
			End If
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCARSeffects4.SetRect(X,Y, Thumbsize.X,Thumbsize.Y))
			Return True 
		End If 
		Log("Load image failed: " & Filename)
	End If
	Log("NO FILE: " & Filename)
	LCARSeffects3.DrawTextItems( BG, X, Y, Width, Height, Array As String(API.GetString("photo_none")), 255) 
End Sub
Sub DrawGoogleNow(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Text As String, IsLauncher As Boolean)
	Dim ThumbSize As Point 
	LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height, LCAR.GetColor(ColorID,False,255), 10)
	API.DrawTextAligned(BG, Text,  X+ Height*0.18, Y+Height*0.5, 0,  LCAR.LCARfont, API.GetTextHeight(BG, Height*0.64, Text, LCAR.LCARfont), Colors.Black, 1, 0, 0)
	If IsLauncher Then 
		If Not(MICpic.IsInitialized) Then MICpic.Initialize(File.DirAssets, "mic.png")'48 x 66
		ThumbSize = API.ThumbSize(MICpic.Width,MICpic.Height, Height*0.5, Height*0.5, True, False)
		BG.DrawBitmap(MICpic, Null, LCARSeffects4.SetRect( X + Width - Height*0.18 - ThumbSize.X, Y+Height*0.5 - ThumbSize.Y*0.5, ThumbSize.X, ThumbSize.Y))
	End If
End Sub

'Index: 0=cpu stats
Sub DrawTextWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Index As Int, ColorID As Int, IsLCARSlauncher As Boolean )
	Dim temp As Int, temp2 As Long, Items As List , SmallItems As List , Left As String , Right As String ,Corner  As Int = LCAR.ItemHeight * 0.1
	Items.Initialize 
	Items.Add("")
	If ColorID= LCAR.LCAR_Random Then ColorID = LCAR.LCAR_RandomColor	
	Select Case Index
		Case 0'	alarms
			SmallItems.Initialize 
			SmallItems.Add(API.GetString("alarm_belay"))
			temp2=DateTime.Now
			Left = API.GetString("alarm_none")
			If API.BelayTime> DateTime.Now Then 
				If IsLCARSlauncher Then SmallItems.Add(API.GetString("alarm_unbelay"))
				Items.Add(API.GetString("alarm_belayed"))
				Items.Add(LCAR.Stardate(StardateMode,API.BelayTime, True,4) & ": " & API.TheTime(API.BelayTime))
				temp2=API.BelayTime
				Items.Add(API.GetString("alarm_future"))
			End If
			For temp = 1 To 10
				temp2 = API.GetNextAlarmTime2(-1, temp2)
				If temp = 1 Then
					Left = LCAR.Stardate(StardateMode,temp2, True,4)
					Right = API.TheTime(temp2)
				Else
					Items.Add(LCAR.Stardate(StardateMode,temp2, True,4) & ": " & API.TheTime(temp2))
				End If
			Next
			
	End Select
	Log(Index & ": " & Left & " " & Right & " " & SmallItems & " " & Items)
	If SmallItems.IsInitialized Then
		LCARSeffects3.DrawGraphicalElbows(BG,X,Y,Width,Height,ColorID, 255, Left,Right, Items, SmallItems, False)
	Else If Left.Length>0 Then
		LCAR.DrawLCARelbow(BG,X,Y,Width, LCAR.ItemHeight+ 2,5 , LCAR.ItemHeight, -2,  ColorID, False, Left, 0, 255,False)
		LCARSeffects3.DrawTextItems(BG, X+5+Corner, Y+LCAR.ItemHeight+Corner, Width-5-Corner, Height - LCAR.ItemHeight*2-Corner*2, Items, 255)
	Else
		LCARSeffects3.DrawTextItems(BG, X, Y, Width, Height, Items, 255)
	End If
End Sub

Sub DrawReminderWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int)
	Dim temp As Int, Items As List 
	Items.Initialize 
	Items.Add("")
	If Not(Reminders.IsInitialized) Then API.LoadReminders(False)
	If Reminders.Size = 0 Then 
		Items.AddAll(API.GetStrings("rem_none",0))
	Else
		For temp = 0 To Reminders.Size - 1 
			Items.Add( (temp+1) & ": " & Reminders.get(temp))
		Next
	End If
	LCARSeffects3.DrawGraphicalElbows(BG,X,Y,Width,Height,ColorID, 255, API.GetString("widget_14"), Reminders.Size, Items, Array As String(API.GetString("vrec")), False)
End Sub

'WidgetClass: 0=regular widget, 1=inside the app, 2=LCARS Launcher, 3=Expanding notification
Sub DrawMusicWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, WidgetClass As Int) 
	If Not(STimer.Music.IsInitialized) Then API.CopyMusicData(True, Null)'"track", "album", "artist"
	Dim SmallItems As List , Track As String = STimer.Music.Getdefault("track", API.getstring("music_u_track")), TextItems As List , RightText As String, Duration As Long   
	Dim Album As String = API.uCase(STimer.Music.Getdefault("album", API.getstring("music_u_album"))).Trim
	Dim Artist As String = API.uCase(STimer.Music.Getdefault("artist", API.getstring("music_u_artist"))).Trim
	Select Case WidgetClass
		Case 0,1: SmallItems.Initialize2(Array As String(API.getstring("music_playpause"))) 'regular widget
		Case 2:	SmallItems.Initialize2(Array As String(API.getstring("prev"), API.getstring("log_side0"), API.getstring("next")))'LCARS LAUNCHER 
		'case 3: 'Expanding notification widget
	End Select
	TextItems.Initialize 
	TextItems.Add("")
	If Track.Contains("[") And Track.Contains("]") Then
		RightText = API.GetBetween(Track, "[", "]")
		Track = API.GetSide(Track, "[", True, False)
	End If
	If Eval.isinbrackets2(Track) Then
		RightText = Eval.GetFromBrackets(Track,  False).ToUpperCase
		Track = Eval.JustTheName(Track)
	End If
	If Track.Contains(" - ") Then
		RightText = API.GetSide(Track, " - ", False, False)
		Track = API.GetSide(Track, " - ", True, False)
	End If
	Do While RightText.Contains("-")
		RightText = RightText.Replace("-", "")
	Loop
	If Album.EqualsIgnoreCase("music") Then Album = ""
	Track = Track.Replace("_", " ")
	If Album.Length>0 Then TextItems.Add(Album)
	If Artist.Length>0 Then TextItems.Add(Artist)
	Duration = STimer.Music.GetDefault("duration", 0)
	If Duration > 0 Then TextItems.Add(API.GetString("date_time") & ": " & API.GetTimeIn(Duration, "", "", API.GetString("date_hrs"), API.GetString("date_min"), API.GetString("date_sec"), "", " "))
	LCARSeffects3.DrawGraphicalElbows(BG,X,Y,Width,Height,ColorID, 255, Track.Trim, RightText.Trim, TextItems, SmallItems, False)
End Sub 

Sub DrawWidgetMeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Percent As Int, Text As String)
	Dim Hwidth As Int = Width*0.5, Color As Int = LCAR.GetColor(ColorID, False, 255)
	LCAR.DrawLCARmeter(BG, X+Hwidth-Min(Hwidth,LCAR.MeterWidth*0.5), Y, Min(Width,LCAR.MeterWidth), Height-LCAR.ItemHeight, Percent, ColorID, False,255)
	API.DrawTextAligned(BG, Text, X+Hwidth,Y+Height, 0, LCAR.LCARfont, LCAR.Fontsize, Color, -8, 0,0)
End Sub 

Sub GetSetting(WidgetID As Int, Setting As String, Default As Object) As Object 
	Return Main.Settings.GetDefault("Widget" & WidgetID & "." & Setting, Default)
End Sub
Sub SetSetting(WidgetID As Int, Setting As String, Value As Object)
	Main.Settings.Put("Widget" & WidgetID & "." & Setting, Value)
End Sub

Sub DeleteSettings(WidgetID As Int)
	Dim temp As Int, tempstr As StringBuilder, Keys() As String = Array As String("Width", "Height", "Type", "Alpha")
	For temp = 0 To Keys.Length -1
		Main.Settings.Remove("Widget" & WidgetID & "." & Keys(temp))
	Next
	
	Keys = Regex.Split(",", Main.Settings.Getdefault("Widgets", ""))
	tempstr.Initialize 
	For temp = 0 To Keys.Length -1
		If Keys(temp) <> WidgetID Then tempstr.Append (API.IIF(tempstr.Length=0, "", ",") & Keys(temp))
	Next
	Main.Settings.Put("Widgets", tempstr.ToString)
End Sub






Sub GeneratePanel(Mode As Int) As String 
	Dim temp As Int, tempstr As String 
	Select Case Mode
		Case -1'color
			If Not(PreviewMode) Then temp= Rnd(0,3)
			Select Case temp
				Case 0: Return Colors.RGB(45,16,12)
				Case 1: Return Colors.RGB(208,32,32)
				Case 2: Return Colors.RGB(0,102,151)
			End Select
		Case 0'Number
			If PreviewMode Then Return "047"
			Return API.PadtoLength(Rnd(0,1000), True,3,"0")
		Case 1'Title
			If Not(PreviewMode) Then temp= Rnd(0,API.GetString("panel_titles"))
			tempstr = API.GetString("panel_title" & temp)
'			Select Case temp
'				Case 0: tempstr = "RESTRICTED ACCESS"
'				Case 1: tempstr = "EPS POWER SYSTEM #"
'				Case 2: tempstr = "ACCESS PANEL #"
'				Case 3: tempstr = "AUXILIARY SYSTEMS #"
'				Case 4: tempstr = "ENGINEERING ACCESS ONLY"
'				Case 5: tempstr = "ENVIRONMENTAL SYSTEM #"
'				Case 6: tempstr = "OPTICAL DATA NET SERVICE ACCESS"
'				Case 7: tempstr = "LCARS TERMINAL # ALPHA CHARLIE-1"
'				Case 8: tempstr = "Danger: Antimatter containment module"
'				Case 9: tempstr = "Caution: Variable gravity area"
'				Case 10: tempstr= "Emergency systems access #"
'				Case 11: tempstr= "LIBRARY computer access and retrieval sys"
'				Case 12: tempstr= "Caution: Cryogenic fluid hazard"
'				Case 13: tempstr= "TERTIARY SUBSYSTEM #"
'			End Select
		Case 2'Text
			If Not(PreviewMode) Then temp= Rnd(0,API.GetString("panel_texts"))
			tempstr = API.GetString("panel_text" & temp)
'			Select Case temp
'				Case 0: tempstr = "Refer servicing to qualified starfleet technicians. No user servicable parts|inside. Remember, no matter where you go, there you are."
'				Case 1: tempstr = "Caution: Objects in mirror are closer than they appear to be. A stitch in|time saves nine. In space, no one can hear you scream"
'				Case 2: tempstr = "Three hundred thousand kilometers per second: it's not just a good|idea, it's the law. Your actual mileage may vary of course."
'				Case 3: tempstr = "Don't tug on Superman's cape. Don't spit into the wind. Don't pull the|mask off the Lone Ranger, and you don't mess around with Jim."
'				Case 4: tempstr = "Just sit right back and you'll hear a tale of a fateful trip, that|started from this tropic port, aboard this tiny ship"
'				Case 5: tempstr = "Daisy, daisy, give me your answer too. I'm half crazy over the love of you|Gort, Klaatu barada nikto"
'				Case 6: tempstr = "Your mission, should you choose to accept it, is to go boldly where no one|has gone before. this label will self-destruct in 5 seconds. good luck, jim."
'				Case 7: tempstr = "caution: operating protocol # requires full redundancy for|all primary lcars network data feed and isolinear components."
'				Case 8: tempstr = "this unit is for emergency use only during alert conditions or|other criticality-1 situations. upon use, notify duty officer."
'				Case 9: tempstr = "shifts in local gravity field may occur at any time without warnings.|please be sure that all unused equipment is secured at all times."
'				Case 10: tempstr= "magnetic containment field must remain on-power at all times.|Failure to do so will result in immediate destruction of the starship."
'				Case 11: tempstr= "caution: mission-critical optical data network elements must remain|online unless disconnect is authorized by bridge ops manager."
'				Case 12: tempstr= "extremely cold temperatures inside. proper safety equipment must|be used and safety protocols observed when opening this unit."
'				Case 13: tempstr= "LIBRARY computer access and retrieval system|Press any key to continue - which one's the any key?"
'				Case 14: tempstr = "caution: operating protocol # requires full redundancy for|all emergency systems. We'll never be caught, we're on a mission from god."
'				Case 15: tempstr = "Safety protocols must be observed prior to opening this compartment. In|the event of a water landing, this unit may be used as a flotation device"
'				Case 16: tempstr = "This defensive weapons system locker contains two charged phaser devices|follow all standard power charging and safety procesures per SFRA #"
'			End Select
	End Select
	If tempstr.Contains("#") Then tempstr=tempstr.Replace("#",LCARSeffects2.RandomENT)
	Return tempstr.ToUpperCase 
End Sub










'Get the Ids of all instances of this widget on the homescreen created by the given service
'
' ServiceName - The name of the WidgetService
Public Sub GetWidgetIds(ServiceName As String) As Int()
	Dim Obj1 As Reflector, Obj2 As Reflector,cn As Object
	Obj2.Target = Obj1.RunStaticMethod("android.appwidget.AppWidgetManager", "getInstance", Array As Object(Obj1.GetContext), Array As String("android.content.Context"))
	cn = Obj1.CreateObject2("android.content.ComponentName", Array As Object(Obj1.GetContext, Obj1.GetStaticField("anywheresoftware.b4a.BA", "packageName") & "." & ServiceName & "$" & ServiceName & "_BR"), Array As String("android.content.Context", "java.lang.String"))
	Return Obj2.RunMethod4( "getAppWidgetIds", Array As Object(cn), Array As String("android.content.ComponentName"))
End Sub

Public Sub UpdateSingleWidget(pRv As RemoteViews, WidgetId As Int)
	Dim Obj1 As Reflector, Obj2 As Reflector, current As Object
	Obj1.Target = pRv ' a RemoteViewsWrapper
	Obj1.RunMethod("checkNull") 'does some internal checking and may set current
	current = Obj1.GetField("current") ' a RemoteViews - get this after checkNull
	Obj2.Target = Obj1.RunStaticMethod("android.appwidget.AppWidgetManager", "getInstance", Array As Object(Obj1.GetContext), Array As String("android.content.Context"))
	Obj2.RunMethod4("updateAppWidget", Array As Object(WidgetId, current), Array As String("java.lang.int", "android.widget.RemoteViews"))
	Obj1.SetField2("current", Null)
End Sub



'Set a new click event for a view which includes the WidgetId so we can decide from which widget the event was fired.
'After setting an event with this sub the standard B4A event for this view will not work anymore.
'
' ServiceName - The name of the WidgetService
' WidgetId - Id of the widget
' rv - RemoteViews object
' ViewName - Name of the view for which the event is set
' EventName - The name of the event. A "_clicked" is appended to this event.
Public Sub SetWidgetClickEvent(ServiceName As String, WidgetId As Int, pRv As RemoteViews, ViewName As String, EventName As String)
	Dim vIntent As Object, vPendingIntent As Object, ref As Reflector, ViewId As Int

	vIntent = ref.RunStaticMethod("anywheresoftware.b4a.keywords.Common", "getComponentIntent", Array As Object(ref.GetProcessBA(ServiceName), Null), Array As String("anywheresoftware.b4a.BA", "java.lang.Object"))
	ref.Target = vIntent
	EventName = EventName.ToLowerCase
	ref.RunMethod4("putExtra", Array As Object("b4a_internal_event", EventName & "_clicked"), Array As String("java.lang.String", "java.lang.String"))
	ref.RunMethod4("putExtra", Array As Object("appWidgetId", WidgetId), Array As String("java.lang.String", "java.lang.int"))

	ref.Target = pRv
	ViewId = ref.RunMethod4("getIdForView", Array As Object(ref.GetProcessBA(ServiceName), ViewName), Array As String("anywheresoftware.b4a.BA", "java.lang.String"))

	vPendingIntent = ref.RunStaticMethod("android.app.PendingIntent", "getService", Array As Object(ref.GetContext, WidgetId, vIntent, 134217728), Array As String("android.content.Context", "java.lang.int", "android.content.Intent", "java.lang.int"))
	ref.RunMethod("checkNull")
	ref.Target = ref.GetField("current")
	ref.RunMethod4("setOnClickPendingIntent", Array As Object(ViewId, vPendingIntent), Array As String("java.lang.int", "android.app.PendingIntent"))
	
	UpdateSingleWidget(pRv, WidgetId)
End Sub

'Load a new xml layout file for the widget. This will create completely new Remoteviews object for the widget.
'
'ServiceName - Name of the widget service
'pRv - RemoteViews object
'LayoutName - Name of the layout to load
Public Sub SetWidgetLayout(ServiceName As String, pRv As RemoteViews, LayoutName As String)
	Dim Obj1 As Reflector, Obj2 As Reflector,id As Int, newRV As Object, packagename As String
	packagename = GetPackageName
	id = Obj1.GetStaticField(packagename & ".R$layout", LayoutName)
	newRV = Obj1.CreateObject2("android.widget.RemoteViews", Array As Object(packagename, id), Array As String("java.lang.String", "java.lang.int"))
	Obj1.Target = pRv ' a RemoteViewsWrapper
	Obj2.Target = Obj1.GetField("original")
	Obj2.RunMethod4("setDataPosition", Array As Object(0), Array As String("java.lang.int"))
	Obj2.Target = newRV
	Obj2.RunMethod4("writeToParcel", Array As Object(Obj1.GetField("original"), 0), Array As String("android.os.Parcel", "java.lang.int"))
	Obj1.SetField2("current", Null)
End Sub

Sub DisallowScrolling(sv As ScrollView)
	Dim r As Reflector
	r.Target = sv
	r.RunMethod4("requestDisallowInterceptTouchEvent", Array As Object(True), Array As String("java.lang.boolean"))
End Sub


'Set the alpha value of a View on the widget.
'Works only with Android SDK version >=8
'
'ServiceName - Name of the widget service
'ViewName - Name of the view
'pRv - RemoteViews object
'pAlpha - Alpha value (0-255)
Sub SetRemoteViewAlpha(ServiceName As String, ViewName As String, pRv As RemoteViews, pAlpha As Int)
	Dim ref As Reflector, id As Int, p As Phone
	If p.SdkVersion >= 8 Then
		ref.Target = pRv
		id = ref.RunMethod4("getIdForView", Array As Object(ref.GetProcessBA(ServiceName), ViewName), Array As String("anywheresoftware.b4a.BA", "java.lang.String"))
		ref.RunMethod("checkNull")
		ref.Target = ref.GetField("current")
		ref.RunMethod4("setInt", Array As Object(id, "setAlpha", pAlpha), Array As String("java.lang.int", "java.lang.String", "java.lang.int"))
	End If
End Sub

'Manually set the intent for the activity
Sub SetActivityIntent(pIntent As Intent)
	Dim ref As Reflector
	ref.Target = ref.GetActivity
	ref.RunMethod4("setIntent", Array As Object(pIntent), Array As String("android.content.Intent"))
End Sub

'Returns the package name of the app
Public Sub GetPackageName As String
    Dim r As Reflector
    Return r.GetStaticField("anywheresoftware.b4a.BA", "packageName")
End Sub

Public Sub GetWallpaper As BitmapDrawable
	Dim r As Reflector
	r.Target = r.RunStaticMethod("android.app.WallpaperManager", "getInstance", Array As Object(r.GetContext), Array As String("android.content.Context"))
	Return r.RunMethod("getDrawable")
End Sub

'Calculate the time to the next full minute
Sub TimeToNextMinute As Long
	Dim ret As Long = DateTime.Now + DateTime.TicksPerMinute
	Return ret - (ret Mod DateTime.TicksPerMinute)	
End Sub

Public Sub SetRemoteViewImageBitMap(ServiceName As String, ViewName As String, pRv As RemoteViews, pBitMap As Bitmap) As Boolean 
    Dim ref As Reflector, id As Int, out As OutputStream, Uri As Object, filename As String = "tmp_widget_" & ViewName & ".png"

    'Save the bitmap to a file for the RemoteView
    out = File.OpenOutput(File.DirInternalCache, filename, False)
    pBitMap.WriteToStream(out, 100, "PNG")
    out.Close
	If File.IsDirectory(File.DirInternalCache, filename) Or Not(File.Exists(File.DirInternalCache, filename)) Then Return False 

	Try 
	    ref.Target = ref.CreateObject2("java.io.File", Array As Object(File.DirInternalCache, filename), Array As String("java.lang.String", "java.lang.String"))
	    ref.RunMethod4("setReadable", Array As Object(True, False), Array As String("java.lang.boolean", "java.lang.boolean"))

	    ref.Target = pRv
	    id = ref.RunMethod4("getIdForView", Array As Object(ref.GetProcessBA(ServiceName), ViewName), Array As String("anywheresoftware.b4a.BA", "java.lang.String"))
	    ref.RunMethod("checkNull")
	    
	    ref.Target = ref.GetField("current")
	    Uri = ref.RunStaticMethod("android.net.Uri", "parse", Array As Object(""), Array As String("java.lang.String"))
	    ref.RunMethod4("setImageViewUri", Array As Object(id, Uri), Array As String("java.lang.int", "android.net.Uri"))
	    Uri = ref.RunStaticMethod("android.net.Uri", "parse", Array As Object(File.Combine(File.DirInternalCache, filename)), Array As String("java.lang.String"))
	    ref.RunMethod4("setImageViewUri", Array As Object(id, Uri), Array As String("java.lang.int", "android.net.Uri"))
		Return True 
	Catch 
		Return False
	End Try 
End Sub