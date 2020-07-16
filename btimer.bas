B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim NotificationWidget As Int = -1, UpdateFrequency As Int , HasDrawn As Boolean 
End Sub

Sub Service_Create
	API.AutoLoad
End Sub

Sub Service_Start (StartingIntent As Intent)
	Dim DoIt As Boolean 
	
	If NotificationWidget>-1 Then'WIDGET MODE
		UpdateFrequency=Max(0,UpdateFrequency-1)
		DoIt = UpdateFrequency<1
		If DoIt And Widgets.OnlyWhenScreenIsOn And Not(STimer.ScreenState) Then DoIt=False
		If DoIt Then
			DoIt= API.AutoUpdateNoti 
			Select Case NotificationWidget
				Case 4,5,6,7,8,9: UpdateFrequency=60'calendar, events, text, 1/5 day weather, Weather graphical
				Case Else:UpdateFrequency=1
			End Select
		End If
	End If
	
	'If Not(DoIt) Then'EMERGENCY BACKUP ALARM HANDLER
		'Log("Btimer: (" & STimer.CurrentAlarm & ") - " & DateTime.Date( STimer.AlarmTime) & " - " & DateTime.Time( STimer.AlarmTime) & " NOW: " & DateTime.Time(DateTime.Now))
		If STimer.AlarmTime > DateTime.Now - DateTime.TicksPerMinute * 2 And STimer.AlarmTime < DateTime.Now And DateTime.Now > API.BelayTime + DateTime.TicksPerMinute Then
			Log(STimer.AlarmTime & " " & (DateTime.Now - DateTime.TicksPerMinute * 2) & " " & DateTime.Now)
			If Not(API.IsScreenOn) Or Main.CurrentSection <> 999 Or IsPaused(Main) Then
				'Log("BTIMER ALARM CHECK PASSED")
				API.DoubleCheckAlarm(False) 'API.HandleAlarm(True)
			End If
		End If
	'End If

	'ANIMATED WIDGETS DON'T WORK
	If STimer.AllowServices Then API.StartServiceAtExact2("btimer", DateTime.Now + DateTime.TicksPerSecond* API.IIF(HasDrawn,60, 5) , False)
	HasDrawn=True
End Sub

Sub Service_Destroy

End Sub
