B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region Module Attributes
	#StartAtBoot: True
	#StartCommandReturnValue: android.app.Service.START_STICKY
#End Region

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	API.DebugLog(API.GetDate(DateTime.Now) & "*************************" & CRLF & Error.Message & CRLF & StackTrace)
	Return False
End Sub

'Service module
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

	Type LCARtimer(Duration As Int, ID As Int, Name As String, Index As Int,EndTime As Long)
	Dim TimerList As List, timersrunning As Boolean , Infinite As Int=-999, Increment As Int=1000
	Dim CurrentAlarm As Int, AlarmTime As Long, SkipUpdate As Boolean, Downloader As HttpJob 
	Dim ReturnAddress As String , AllowServices As Boolean = True , Headset_Plug As Boolean 
	TimerList.Initialize 
	
	'LCAR.CheckLoopingSound
	Dim Music As Map   'MusicState As BroadCastReceiver, 
	Dim PE As PhoneEvents,TurnedOff As Long,ActAsLockscreen As Boolean,ScreenState As Boolean=True,OnlyWhenCharging As Boolean  ',PEisInit As Boolean ', AC As AnswerCall, PhoneId As PhoneId
	
	Dim HTTPJobs As List, Broadcast As BroadCastReceiver
End Sub

Sub FindJob(JobName As String) As Int
	Dim temp As Int , tempJob As HttpJob 
	If HTTPJobs.IsInitialized Then
		For temp = 0 To HTTPJobs.Size - 1 
			tempJob = HTTPJobs.Get(temp)
			If tempJob.JobName.EqualsIgnoreCase(JobName) Then Return temp 
		Next
	Else
		HTTPJobs.Initialize 
	End If
	Return -1
End Sub

Sub PostString(JobName As String, URL As String) As String
	Dim tempJob As HttpJob = DownloadFile(JobName, "")
	Return tempJob.PostString(API.GetSide2(URL, "?", True), API.GetSide2(URL, "?", False) )	
End Sub
Sub DownloadFile(JobName As String, URL As String) As HttpJob
	Dim JobID As Int = FindJob(JobName), tempJob As HttpJob
	If JobID=-1 Then
		tempJob.Initialize(JobName, "STimer")
		HTTPJobs.Add(tempJob)
	Else
		tempJob=HTTPJobs.Get(JobID)
	End If
	If URL.Length>0 Then tempJob.Download(URL)
	Return tempJob 
End Sub

Sub JobDone (Job As HttpJob)
	Dim JobID As Int, Filename As String = API.GetURLfilename(Job.URL)
	Log("Job complete: " & Job.JobName & " (" & Job.URL & ")")
 	Select Case Job.JobName
		Case "Downloader"
			If Job.Success Then
				Weather.CheckWeather(Job.GetString, True)
			Else
				Weather.NeedsUpdate = True
			End If

		Case "filelist"
			If Job.Success Then
				If Not(IsPaused(Main)) Then CallSub2(Main, "JobDone", Job)
			End If
			
		Case "apk"
			If Job.Success Then
				API.SaveFile(Job.GetInputStream, File.DirDefaultExternal, Filename)
				API.InstallAPK(File.DirDefaultExternal, Filename) 
			End If
			
		Case "tropes"
			If Job.Success Then
				Tropes.JobDone(Job.url, Job.GetString)
			End If
			
		Case Else: 
			'Log("unhandled http job: " & Job.JobName)			
			CallSub2(Main, "JobDone", Job)
	End Select
	If Not(Job.Success) Then
		Log("JOB FAILED: " & Job.ErrorMessage)
		Log(Job.URL)
	End If
	Job.release
End Sub




Sub Phone_BatteryChanged (Level As Int, Scale As Int, Plugged As Boolean, Intent As Intent)
	LCAR.HandleBattery(Level,Scale,Plugged,Intent)
End Sub

Sub Phone_ScreenOff (Intent As Intent)
	TurnedOff = DateTime.Now 
	ScreenState=False
End Sub

Sub Phone_ScreenOn (Intent As Intent)
	ScreenState=True
	If ActAsLockscreen And (Not(OnlyWhenCharging) Or (OnlyWhenCharging And LCAR.isCharging)) Then
		If (DateTime.Now - TurnedOff) > (DateTime.TicksPerSecond * 5) Then
			If API.IsScreenLocked And Main.CurrentSection <> 999 Then
				StartActivity(Main)
				CallSubDelayed2(Main, "PreviewDD",True)
				If WallpaperService.TimeOut> 0 Then API.NewTimer("Shutoff", 5, WallpaperService.TimeOut)
			End If
		End If
	End If
	If Widgets.OnlyWhenScreenIsOn And AllowServices Then
		StartService(Widgets)
		CallSubDelayed2(Widgets, "RefreshAll", -2)
		API.AutoUpdateNoti 
	End If
End Sub

'Sub StartStimer As Boolean 
'	If API.NOTIPLUS.IsInitialized Then 
'		Service.StartForeground(1,API.NOTIPLUS)
'	Else If API.NOTI.IsInitialized Then
'		Service.StartForeground(1,API.NOTI)
'	Else
'		Return False
'	End If
'	Return True
'End Sub

Sub Service_Create
	API.CopyMusicData(True, Null)
	PE.Initialize("Phone")
	If Not(Downloader.IsInitialized) Then Downloader.Initialize("Downloader", Me)
	Broadcast.Initialize("BroadcastReceiver")
End Sub

Sub HandleTimerWhilePaused(tempTimer As LCARtimer) As Boolean 
	Select Case tempTimer.ID 
		Case 0'auto-destruct timer
			API.NOTITitle = API.GetTime(tempTimer.Duration) & " REMAINING"
			API.AutoUpdateNoti
			Select Case tempTimer.Duration
				Case 5,10,15,60: API.SendPebble("LCARS TIMER", API.NOTITitle)
				Case 0
					WakeUp
					API.SendPebble("LCARS TIMER", "TIME IS UP!")
					API.NOTITitle = ""
					API.AutoUpdateNoti
					Main.CurrentSection=4
					LCAR.rumble(5)
					LCAR.PlaySoundAnyway(-5)'If CurrentSection=4 Then 
					CallSubDelayed(Main,"ShowUFPLogo")
			End Select
	End Select
	Return Not( IsPaused(Main) )
End Sub

Sub RefreshLWP
	CallSubDelayed(WallpaperService, "Refresh")
End Sub
Sub StartMain
	Main.CurrentSection = 10000
	StartActivity(Main)
	CallSubDelayed(Main,"HideWebview")
End Sub
Sub BringUpKeyboard(Title As String, Message As String, DefaultValue As String, ReturnIntent As String)
	Main.CurrentSection = 10000
	'StartActivity(Main)
	'CallSubDelayed2(Main,"Activity_Create", True)
	'DoEvents


	LCAR.KBLayout=0
	LCAR.SymbolsEnabled=True
	LCAR.SelectText(DefaultValue)
	LCARSeffects.ShowPrompt(LCAR.EmergencyBG,-10, Title, Message,  -12,"OK", "CANCEL")
	
	ReturnAddress = API.IIF(ReturnIntent.Length=0, "com.omnicorp.launcher", ReturnIntent)
End Sub

Sub Service_Start (StartingIntent As Intent)
	Dim temp As Long , temp2 As LCARtimer ,Value As Object ,temp3 As Long
	
	Broadcast.addAction("android.intent.action.HEADSET_PLUG")
    Broadcast.SetPriority(999)
    Broadcast.registerReceiver("")
	
	If StartingIntent.IsInitialized Then 
		If StartingIntent.HasExtra("Notification_Action_Tag") Then
			Value=StartingIntent.GetExtra("Notification_Action_Tag")
			Select Case Value
				Case "BELAY TIMER":		API.BelayTimer(0)
				Case "UNBELAY ALARM": 	API.BelayCurrentAlarm(False)
				Case "BELAY ALARM": 	API.BelayCurrentAlarm(True)
				Case "V.REC"
										StartActivity(Main)
										LCAR.SystemEvent(2, 0)
					
			End Select
			If API.StartsWith(Value, "START TIMER") Then 
				API.StartTimer( API.Right(Value, API.Len(Value) - 12) )
			End If
		Else If StartingIntent.Action ="com.omnicorp.lcarui" Then
			If StartingIntent.HasExtra("Value") Then Value=StartingIntent.GetExtra("Value")
			Select Case API.lCase(StartingIntent.GetExtra("Action"))
				Case "state":			TurnedOff = DateTime.Now + (DateTime.TicksPerSecond * 5)
				Case "toast":			LCAR.ToastMessage(LCAR.EmergencyBG, Value,3)
				Case "noti" 
										API.SendPebble("COMMUNICATOR", Value)
										API.NOTIBody = Value
										API.AutoUpdateNoti
				Case "lwpreset"
										WallpaperService.UseWidthinstead=0
										RefreshLWP
				Case "lwpscroll"	
										WallpaperService.UseXinstead = StartingIntent.GetExtra("X")
										WallpaperService.UseWidthinstead= StartingIntent.GetExtra("W")
										RefreshLWP
				Case "showsection"	
										StartMain
										LCAR.SystemEvent(0,Value)

				Case "seedsections":	API.EnumSections(Value)
								
				Case "widgets":			If IsNumber(Value) Then CallSub2(Widgets,"UpdateLauncher", Value)
				Case "widgetclicked":	
										If StartingIntent.HasExtra("x") Then Widgets.Xpos=StartingIntent.GetExtra("x") Else Widgets.Xpos = -1
										If StartingIntent.HasExtra("y") Then Widgets.ypos=StartingIntent.GetExtra("y") Else Widgets.Ypos = -1
										If IsNumber(Value) Then CallSub2(Widgets, "WidgetClicked", Value)
				Case "configwidget"
										Widgets.CurrentWidget = Value
										StartActivity(Main) 
										CallSubDelayed3(Main, "ShowSection", 41 ,False)
				Case "widgetdelay":		If IsNumber(Value) Then Widgets.AnimationDelay = Value
				Case "deletewidget":	If IsNumber(Value) Then CallSub2(Widgets, "DeleteSettings", Value)
	'			Case "widgetupdate"
	'									If IsNumber(Value) Then 
	'										Dim tempWidget As WidgetPackage 
	'										tempWidget.Initialize 
	'										tempWidget.WidgetID=Value
	'										tempWidget.Alpha=-1
	'										tempWidget.Loc=LCAR.SetRect(0,0, StartingIntent.GetExtra("Width")+1, StartingIntent.GetExtra("Height")+1)
	'										CallSubDelayed2(Widgets, "DrawWidget2", tempWidget)
	'									End If
				
				'Case "keyboard"
				'						BringUpKeyboard(StartingIntent.GetExtra("title"), StartingIntent.GetExtra("message"), Value, StartingIntent)
								
				Case "msgbox":			
										StartMain
										LCARSeffects.ShowPrompt(LCAR.EmergencyBG, -10, StartingIntent.GetExtra("title"), StartingIntent.GetExtra("message"),  13, "OK", Value)
										ReturnAddress = "com.omnicorp.launcher"
										If StartingIntent.HasExtra("returnintent") Then ReturnAddress = StartingIntent.GetExtra("returnintent")
				Case "browseweb":		
										StartActivity(Main)
										CallSubDelayed2(Main, "BrowseWeb2", Value)
				Case "answermade"
										temp = Main.Settings.GetDefault("AnswerMade", 0) + 1
										Main.Settings.put("AnswerMade", Max(5,temp))
				Case "vrec"
										StartMain
										CallSubDelayed2(Main, "VR_Handle", Value)
				'Case "mew" API.ForceAlarmRecheck
			End Select
		Else If StartingIntent.HasExtra("track") Or StartingIntent.HasExtra("com.amazon.mp3.track") Then
			API.CopyMusicData(False, StartingIntent)
		Else
			Select Case StartingIntent.Action
				'Case "android.bluetooth.device.action.ACL_CONNECTED"
				'	BluetoothHeadset = True 
				'Case "android.bluetooth.device.action.ACL_DISCONNECTED"
				'	BluetoothHeadset = False 
				Case Else		
					If API.debugMode Then 
						Log("Stimer, unhandled intent")
						Log("intent: " & StartingIntent)
						Log("extras: " & StartingIntent.ExtrasToString)
					End If 
			End Select
		End If
	End If 

	timersrunning=False
	API.WasPaused= IsPaused(Main)
	For temp =  TimerList.Size-1 To 0 Step -1
		temp2 = TimerList.Get(temp)
		temp2.Index = temp
		If temp2.Duration > Infinite Then' temp2.Duration=temp2.Duration-1
			temp3 = Max(0, Ceil( (temp2.EndTime - DateTime.Now) / DateTime.TicksPerSecond ))
			If temp2.Duration = temp3 Then temp3= Max(Floor( (temp2.EndTime - DateTime.Now) / DateTime.TicksPerSecond ),0)
			If temp3 < temp2.Duration Then temp2.Duration = temp3
			If temp2.Duration > 0 Then timersrunning=True 
		End If
		If temp2.Duration=0 Or ( temp2.Duration > Infinite And DateTime.Now >= temp2.EndTime) Then
			If HandleTimerWhilePaused(temp2) Then
				CallSubDelayed2(Main, "TimerIncrement" , temp2)
			'If Not(LCAR.ScreenIsOn ) Then WakeUp
			End If
		Else
			If API.WasPaused Then
				HandleTimerWhilePaused(temp2)
			Else
				CallSub2(Main, "TimerIncrement" , temp2)
			End If
		End If
		
		If temp2.Duration >0 Or temp2.Duration = Infinite Then
			'TimerList.Set(temp, temp2)
			timersrunning=True 
		Else
			TimerList.RemoveAt(temp)
		End If
	Next
	If Increment <1000 Then'audio looping mode
		timersrunning=True 
		If LCAR.MP.Position>=1500 Then LCAR.MP.Position=0
	End If
	'End If
	
	API.DoubleCheckAlarm(False)
	temp=0
	If timersrunning Then
		temp=Increment
	Else If Not(AllowServices) Then
		temp=-1
	Else If AlarmTime>0 Then
		If AlarmTime > DateTime.Now Then temp = AlarmTime-DateTime.Now
	Else If Not(ActAsLockscreen) Then
		temp=-1
	End If
	If Not(timersrunning) Then API.GetFileList("", False)

	If temp>-1 Then
		Value=15 * DateTime.TicksPerMinute
		If temp=0 Or temp>Value Then temp= Value
		'Log("Update " & API.GetTime(temp/DateTime.TicksPerSecond) & " from " & DateTime.Time(DateTime.now) & " " & temp)
		API.StartServiceAtExact2("STimer",DateTime.Now+ temp,False)
		
	'Else If Not(ActAsLockscreen) Then 
		'Log("Stimer stopped")
		'StopService("")
	End If
	If AllowServices Then API.StartServiceAtExact2("btimer", DateTime.Now + DateTime.TicksPerMinute ,False)
End Sub

Sub Service_Destroy
	TimerList.Clear 
End Sub

Sub WakeUp
	Dim P As PhoneWakeState
	API.Broadcast("Suppress", 5)
    P.ReleaseKeepAlive
	If Not(API.IsScreenOn) Then
    	P.KeepAlive(True)
    	'P.PartialLock
	End If
	SkipUpdate=True
    StartActivity(Main) ' start the activity
End Sub


Sub BroadcastReceiver_OnReceive (Action As String, i As Object)
    Dim i2 As Intent = i
	Headset_Plug = i2.GetExtra("state") = 1
	Log("Headset " & API.IIF(Headset_Plug, "inserted", "removed"))
End Sub