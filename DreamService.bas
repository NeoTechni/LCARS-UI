B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.3
@EndOfDesignText@
#Region Module Attributes
	#StartAtBoot: False
#End Region

'Service module
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim TimerMain As Timer, DDisrunning As Boolean, DD As Daydream, Phone1 As PhoneEvents, Bright As Boolean = True
End Sub
Sub Service_Create
	API.AutoLoad
End Sub

Sub Service_Start (StartingIntent As Intent)
	DD.Initialize("DD")
	TimerMain.Initialize("Timer", WallpaperService.Delay)
End Sub

Sub DDpanel_Touch (Action As Int, X As Float, Y As Float)
	CallSub3(WallpaperService, "HandleTouchP", Action, Trig.SetPoint(X,Y))
End Sub

Sub Service_Destroy

End Sub

Sub DD_SizeChanged
	Dim Touch As Reflector 
	Touch.Target = DD.Panel 
	Touch.SetOnTouchListener("Panel_Touch")
	DD.Canvas.Initialize(DD.Panel)
End Sub

Sub Panel_Touch(Viewtag As Object, Action As Int, X As Float, Y As Float, motionEvent As Object) As Boolean 
	DDpanel_Touch(LCAR.Event_Down, X,Y)
End Sub

Sub DD_DreamStarted
	WallpaperService.SettingsLoaded=False
	WallpaperService.AllowPreview=True
	WallpaperService.IsVisible=False
	DDisrunning=True
	DD.Interactive = False
	DD.ScreenBright=Bright
	If TimerMain.Interval=0 Then TimerMain.Interval=1000
    TimerMain.Enabled = True
	Phone1.Initialize("Phone")
	DD_SizeChanged
End Sub
Sub DD_DreamStopped
	WallpaperService.AllowPreview=False
	DDisrunning=False
	TimerMain.Enabled=False
	Phone1.StopListening 
End Sub

Sub Phone_BatteryChanged (Level As Int, Scale As Int, Plugged As Boolean, Intent As Intent)
	LCAR.HandleBattery(Level,Scale,Plugged,Intent)
End Sub

Sub Timer_Tick
	DDisrunning=True
	'LCARSeffects2.DrawCustomElement(DD.Canvas, 0, 0, DD.Panel.Width,DD.Panel.height,  -1,  0, LCAR.LCAR_LWP, False, 255, "","",0,0, "")
	CallSubDelayed2(WallpaperService, "PreviewLWP", DD.Canvas)
	WallpaperService.DoIncrement=True
	DD.Interactive =WallpaperService.MediaControls
	DD.Panel.Invalidate
End Sub