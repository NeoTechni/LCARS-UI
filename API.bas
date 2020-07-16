B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Google weather API: http://www.google.com/ig/api?weather=L8L%206V6
'IP http://api.hostip.info/get_html.php
'http://ipinfodb.com/ip_locator.php?ip=70.52.165.17

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim dURL As String ,Title As String ,FileLoaded As String ,BaseHref As String , aHREF As String ,Encryption As Boolean ,SearchProvider As Int, CurrentOrientation As Int '= 1
	
	Type HTMLvalue(Key As String, Value As String)
	Type HTMLtag(Level As Int, TagName As String, Node As String, Values As List)
	
	Type APIKeyboard(Text As String, SelStart As Int, SelLength As Int, Shift As Boolean,CapsLock As Boolean  )
	Type IPaddress(Octets(4) As Int, Port As Int, SelectedOctet As Int )
	
	Type Alarm(Hour As Byte,Minute As Byte, SoundID As Int,SoundEnabled As Boolean, Repeats As List, Enabled As Boolean, Action As Byte, Snooze As Int, Length As Int, Text As String)
	Dim CWA As Alarm, AlarmIndex As Int,IsSnoozing As Boolean, Alarms As List,DeadmanPass As String,TempPass As String,PassAttempts As Int,Locked As Boolean=True
	Dim IsDeadMan As Boolean ,isDemoing As Boolean,OldDay As Int=-1, OldTimezone As Int, BelayTime As Long  'Actions: 0=Normal alarm, 1=DND OFF, 2=DND ON, 3=DEAD MAN
	
	Dim debugMode As Boolean, HasChecked As Boolean , ascA As Int= Asc("A"), ascZ As Int= Asc("Z"), IsOuya As Boolean ,IsSpeakerPhone As Boolean , datemode As Int, FullscreenMode As Boolean, RealHeight As Int  
	
	Dim BUTTON_A As Int=96, BUTTON_B As Int=97, BUTTON_C As Int=98, BUTTON_X As Int=99, BUTTON_Y As Int=100, BUTTON_Z As Int=101, BUTTON_L1 As Int=102, BUTTON_R1 As Int=103, BUTTON_L2 As Int=104, BUTTON_R2 As Int=105
	Dim BUTTON_SELECT As Int=109, BUTTON_START As Int=108, BUTTON_MODE As Int=110, BUTTON_L3 As Int=106, BUTTON_R3 As Int=107 ':BUTTON_MODE=316:BUTTON_L3=317:BUTTON_R3=318
	'BUTTON_A= 304 :BUTTON_B=305:BUTTON_C=306:BUTTON_X = 307:BUTTON_Y=308:BUTTON_Z=309:BUTTON_L1 =310:BUTTON_R1=311:BUTTON_L2=312:BUTTON_R2=313:BUTTON_SELECT=314:BUTTON_START=315
	    
	Dim DIRECTORY_MUSIC As Int=7, DIRECTORY_PICTURES As Int, DIRECTORY_RINGTONES As Int=1, DIRECTORY_ALARMS As Int=2,DIRECTORY_DCIM As Int=4,DIRECTORY_DOWNLOADS As Int=5,DIRECTORY_MOVIES As Int=6, DIRECTORY_NOTIFICATIONS As Int=3,  DIRECTORY_PODCASTS As Int=8
	
	Type Country(Name As String, Code As Int)
	Dim Countries As List 
	
	Dim AndroidMediaPlayer As String '= "com.google.android.music"'.MusicPlaybackService"
	Type MediaFile(ID As Int,FileType As String, Title As String, Album As String, Artist As String, Track As Int, Year As Int, Filename As String, DisplayName As String, Size As Long, DateTaken As Long, Height As Int, Width As Int)
	Dim MB As MediaBrowser, MBisInitialized As Boolean ,IsMediaFiles As Boolean 
	
	Dim NOTI As Notification, AllowNoti As Boolean ,NOTITitle As String, NOTIBody As String ,OldVolume As Int ,OldVolume As Int =-1,OldInternalVol As Int ,WasPaused As Boolean ,UsePebble As Boolean 
	Dim CurrBrightness As Float=-1, AllowVolumeAccess As Boolean =True, NOTIPLUS As NotificationBuilder 
	
	Type CalendarEvent(CalID As Int, EventName As String, Description As String, StartTime As Long, EndTime As Long, Loc As String, AllDay As Boolean, EventID As Int)
	Dim InternalEvents As Boolean , TempAlarmS As String 
	
	Type Histogram(Values As List, Highest As Int, Inc As Int)
	Dim TimeMin As Double=1000000,TimeMax As Double =-1000000, FFTMax As Double ,  FFTLimit As Double, FFTThreshold = 0.8 As Double, N_Samples As Int , CursorScaleFreq As Double , FFTprev As Int 
	Dim FFT1 As FFT
	
	Dim LastChecked As String, AutoUpdateAPKs As Boolean, AutoInstallAPKs As Boolean , MaxZoomFactor As Byte = 15
'	Type Stack(SubName As String, Tabs As Int, Duration As Long)
'	Dim StackTrace As List , CurrentStackID As Int, CurrentSubID As Int 
	Dim CurrentJob As HttpJob 
	
	Type KeyBinding(KeyCode As Int, ControllerKey As Int)
	Dim NFCtags As List, KeyBindings As List, UseDefaultBindings As Boolean = True   
	
	Dim BluetoothDelay As Int, Translation As Map, TransLanguage As String, TransDebugMode As Boolean, TransNew As Boolean 
End Sub

Sub EnumLanguages As List 
	Dim Files As List = GetFiles(LCAR.DirDefaultExternal, "ut"), RET As List, temp As Int, tempstr As String 
	RET.Initialize
	RET.Add("english")
	For temp = 0 To Files.Size -1 
		tempstr = lCase(Files.get(temp))
		If tempstr.EndsWith(".ut") Then tempstr = Left(tempstr, tempstr.Length-3)
		If Not(tempstr = "english") Then RET.Add(tempstr)
	Next
	Return RET
End Sub

Sub GetMS As Int 
	Return DateTime.Now Mod DateTime.TicksPerSecond
End Sub

Sub LoadTranslation(Language)
	Dim Dir As String = File.DirAssets
	If Language.Length=0 Then Language = "english"
	Language=Language.ToLowerCase
	TransLanguage = Language
	If File.Exists(LCAR.DirDefaultExternal, Language & ".ut") Then Dir = LCAR.DirDefaultExternal
	Translation = File.ReadMap(Dir, Language & ".ut")
	Translation.Put("language", Language)
	TransNew = True
End Sub
Sub GetRandomString(Name As String) As String 
	Dim Index As Int = Rnd(0, GetString(Name & "s"))
	Return GetString(Name & Index)
End Sub
Sub GetString(Name As String) As String 
	Return GetStringVars(Name, Array As String()) 
End Sub
Sub GetStringVars(Name As String, Variables() As String) As String 
	Dim temp As Int, Words As List, tempstr As StringBuilder 
	If Not(Translation.IsInitialized) Then LoadTranslation(TransLanguage)
	If Not(TransLanguage.EqualsIgnoreCase(Translation.Get("language"))) Then LoadTranslation(TransLanguage)
	'Name=Name.Trim
	If Not(TransDebugMode) And Translation.ContainsKey(Name) Then 
		If LCAR.SmallScreen Then 
			If Translation.ContainsKey(Name & "_sm") Then Name = Name & "_sm"
		End If 
		Name = Translation.get(Name)
		For temp = 0 To Variables.Length - 1 
			Name = Name.Replace("[" & temp & "]", Variables(temp))
		Next
		If Name.Contains("~") Then 
			Name = Name.Replace("~", "")
		else If Name.Contains("[") And Name.Contains("]") Then 
			Words = SplitVars(Name)
			tempstr.Initialize
			For temp = 0 To Words.Size - 1
				Name = Words.Get(temp)
				If Name.StartsWith("[") And Name.EndsWith("]") Then 
					Name = Mid(Name,1, Name.Length-2)
					If Translation.ContainsKey(Name) Then 
						Name = GetStringVars(Name, Variables)
					Else if Main.Settings.ContainsKey(Name) Then 
						Name = Main.Settings.Get(Name)
					End If 
				End If
				tempstr.Append(Name)
			Next
			Name = tempstr.ToString
		End If 
		If Name.Contains("%N%") Then Name = Name.Replace("%N%", CRLF)
	End If
	Name = Name.Replace("â¢", "•")
	Return Name 
End Sub
Sub GetStrings(Name As String, Start As Int) As List 
	Dim RET As List, temp As Int 
	RET.Initialize
	Do Until Not(Translation.ContainsKey(Name & Start))
		RET.Add(GetString(Name & Start))
		Start=Start+1
	Loop
	Return RET 
End Sub




Sub IsBluetoothHeadsetOn As Boolean
	If BluetoothDelay = 0 Then Return False 
    Dim r As Reflector
    r.Target = r.GetContext
    r.Target = r.RunMethod2("getSystemService", "audio", "java.lang.String")
    Return r.RunMethod("isBluetoothA2dpOn") Or r.RunMethod("isBluetoothScoOn")
End Sub

Sub LoadKeyBindings(Save As Boolean)
	UseDefaultBindings = HandleSetting("UseDefaultBindings", UseDefaultBindings, True, Save)
End Sub
Sub HandleControllerButton(KeyCode As Int) As Boolean 
	Dim Ret As Boolean 
	If UseDefaultBindings Then 
		Ret = True 
		Select Case KeyCode 
			Case 19, KeyCodes.KEYCODE_W: 													LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 0       ,0,0,0,0,0, LCAR.Event_Down)'up
			Case 22, KeyCodes.KEYCODE_D: 													LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 1       ,0,0,0,0,0, LCAR.Event_Down)'right
			Case 20, KeyCodes.KEYCODE_S: 													LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 2       ,0,0,0,0,0, LCAR.Event_Down)'down
			Case 21, KeyCodes.KEYCODE_A: 													LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 3       ,0,0,0,0,0, LCAR.Event_Down)'left
			Case 23, KeyCodes.KEYCODE_ENTER, BUTTON_A,0,188: 								LCAR.PushEvent(LCAR.LCAR_HardwareBTN,-1       ,0,0,0,0,0, LCAR.Event_Down)'center/cross/X/O (OUYA), center dpad(SONY), click (SONY)
			
			Case 99, KeyCodes.KEYCODE_SPACE: 												LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 4       ,0,0,0,0,0, LCAR.Event_Down)'square, 		U
			Case 100, KeyCodes.KEYCODE_DEL: 												LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 5       ,0,0,0,0,0, LCAR.Event_Down)'triangle, 	Y
			Case 102, KeyCodes.KEYCODE_Q,BUTTON_L1, KeyCodes.KEYCODE_MEDIA_REWIND: 			LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 6       ,0,0,0,0,0, LCAR.Event_Down)'l shoulder,	L1, ◄◄
			Case 103, KeyCodes.KEYCODE_P,BUTTON_R1, KeyCodes.KEYCODE_MEDIA_FAST_FORWARD: 	LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 7       ,0,0,0,0,0, LCAR.Event_Down)'r shoulder,	R1, ►►
			Case 108, KeyCodes.KEYCODE_F,BUTTON_START, KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE: 	LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 8       ,0,0,0,0,0, LCAR.Event_Down)'start, ►/❚❚ 
			
			Case 109, BUTTON_SELECT
				'If Main.Screenshots Then
				'	CallSub(Main, "TakeScreenshot")
				'Else
				'	LCAR.PushEvent(LCAR.LCAR_HardwareBTN, 9       ,0,0,0,0,0, LCAR.Event_Down)'select
				'End If
				LCAR.PushEvent(LCAR.SYS_System, 0, -1, 0,0,0,0, LCAR.Event_Down)
			
			Case 164'mute (SONY)
				AllowVolumeAccess=True
				LCAR.Volume(-999,True)
				
			Case Else: Ret = False
		End Select
	End If
	
	Return Ret 
End Sub

Sub GetDate(Ticks As Long) As String
	Dim Month As String = PadtoLength(DateTime.GetMonth(Ticks), True, 2, "0")
	Dim Day As String = PadtoLength(DateTime.GetDayOfMonth(Ticks), True, 2, "0")
	Dim Year As String = DateTime.GetYear(Ticks)
	Select Case datemode
		Case 0: Return Day & "/" & Month & "/" & Year
		Case 1: Return Month & "/" & Day & "/" & Year
		Case 2: Return Year & "/" & Month & "/" & Day
	End Select
End Sub
Sub OnlyDate(Ticks As Long) As Long 
	Return MakeDate(DateTime.GetYear(Ticks), DateTime.GetMonth(Ticks), DateTime.GetDayOfMonth(Ticks), 0,0,0,0)
End Sub
Sub ValidDate(Date As String) As Long
    Dim matcher1 As Matcher, days As Int, months As Int, years As Int = DateTime.GetYear(DateTime.Now), themonths As List, temp As Int, Words As List, Word As String 
    matcher1 = Regex.Matcher("(\d\d)/(\d\d)/(\d\d\d\d)", Date)
	Date = Date.ToUpperCase.Trim
	If matcher1.Find = True Then
		Select Case datemode
			Case 0'day/month/year
				days = matcher1.Group(1)
				months = matcher1.Group(2)
			Case 1'month/day/year
				months = matcher1.Group(1)
				days = matcher1.Group(2)
			Case 2'year/month/day
				months = matcher1.Group(2)
				days = matcher1.Group(3)
		End Select
		years = matcher1.Group(3) 'fetch the second captured group
	else if Date = GetString("date_now") Then 
		Return DateTime.Now 
	Else if Date = GetString("date_yesterday") Then 
		Return OnlyDate(DateTime.Now - DateTime.TicksPerDay)
	else if Date = GetString("date_today") Then 
		Return OnlyDate(DateTime.Now)
	else if Date = GetString("date_tomorrow") Then 
		Return OnlyDate(DateTime.Now + DateTime.TicksPerDay)
	Else 
		themonths = LCARSeffects3.GetMonths()
		For temp = 0 To themonths.size - 1 
			If Date.Contains( themonths.get(temp) ) Then 
				months = temp + 1
				Date = Date.Replace(themonths.get(temp), "").Trim
			End If
		Next
		
		Words = Eval.splitbychartype(Date, False,False,False)
		For temp = 0 To Words.size - 1 
			Word = Words.Get(temp)
			If IsNumber(Word) Then 
				If Word.Length = 4 Then 
					years = Word
				Else if Word.Length < 3 Then 
					days = Word
				End If
			End If 
		Next
		
    End If 
	If months > 12 And days < 13 Then 
		temp = months 
		months = days
		days = temp 
	End If
	If months > 12 Or days > LCARSeffects3.GetDaysInMonth(months, years) Then Return 0
    Return MakeDate(years, months, days, 0,0,0,0)
End Sub
'Sub Trace(SubName As String, Entering As Boolean) As Boolean 
'	Dim tempStack As Stack , temp As Int 
'	If SubName.Length = 0 Then
'		If Entering Then 
'			StackTrace.Initialize 
'		Else
'			File.WriteList(File.DirRootExternal,  "stacktrace " & DateTime.Now & ".map", StackTrace)
'			Log("Trace saved")
'		End If
'	Else If StackTrace.IsInitialized Then
'		If Entering Then 
'			tempStack.Initialize
'			tempStack.SubName=SubName 
'			tempStack.Tabs = CurrentStackID
'			tempStack.Duration = DateTime.Now 
'			StackTrace.Add(tempStack)
'			CurrentStackID=CurrentStackID+1
'		Else
'			CurrentStackID=CurrentStackID-1
'			For temp = StackTrace.Size-1 To 0 Step -1
'				tempStack = StackTrace.Get(temp)
'				If tempStack.SubName.EqualsIgnoreCase(SubName) AND tempStack.Tabs = CurrentStackID Then
'					tempStack.Duration = DateTime.Now - tempStack.Duration 
'					temp=-1
'				End If
'			Next
'		End If
'	End If
'End Sub

Public Sub CopyMusicData(IsNull As Boolean, StartingIntent As Intent)
	STimer.music.Initialize 
	If IsNull Then
'		stimer.music.Put("track", "NO TRACK")
'		stimer.music.Put("album", "NO ALBUM")
'		stimer.music.Put("artist", "NO ARTIST")
		STimer.music.Put("playing", "false")
		STimer.music.Put("duration", "0")
	Else
	'Bundle[{duration=254407, currentContainerName=All songs, artist=田村ゆかり, domain=0, currentSongLoaded=true, preparing=false, rating=0, albumId=1538217360, 
	'currentContainerTypeValue=13, currentContainerId=42, playing=True, streaming=False, inErrorState=False, albumArtFromService=False, id=33, currentContainerExtData=Null,
	'album=Fantastic future, local=True, track=Fantastic future, position=20732, currentContainerExtId=Null, supportsRating=True, ListSize=201, previewPlayType=-1, ListPosition=1}]
		PutExtra(STimer.music, StartingIntent, "duration", "0")
		PutExtra(STimer.music, StartingIntent, "currentContainerName", "UNKNOWN LIST")
		'API.PutExtra(stimer.music, StartingIntent, "domain", "")
		'PutExtra(stimer.music, StartingIntent, "currentSongLoaded", "false")
		PutExtra(STimer.music, StartingIntent, "preparing", "false")		
		PutExtra(STimer.music, StartingIntent, "track", GetExtra(StartingIntent, "com.amazon.mp3.track", "UNKNOWN TRACK"))
		PutExtra(STimer.music, StartingIntent, "album", GetExtra(StartingIntent, "com.amazon.mp3.album", "UNKNOWN ALBUM"))
		PutExtra(STimer.music, StartingIntent, "artist", GetExtra(StartingIntent, "com.amazon.mp3.artist", "UNKNOWN ARTIST"))
		PutExtra(STimer.music, StartingIntent, "rating", "0")
		PutExtra(STimer.music, StartingIntent, "albumId", "")
		'PutExtra(stimer.music, StartingIntent, "currentContainerTypeValue", "")
		'PutExtra(stimer.music, StartingIntent, "currentContainerId", "")
		PutExtra(STimer.music, StartingIntent, "playing", "false")
		'PutExtra(stimer.music, StartingIntent, "streaming", "false")
		PutExtra(STimer.music, StartingIntent, "inErrorState", "false")
		'PutExtra(stimer.music, StartingIntent, "albumArtFromService", "false")
		'PutExtra(stimer.music, StartingIntent, "id", "")
		'PutExtra(stimer.music, StartingIntent, "currentContainerExtData", "")
		'PutExtra(stimer.music, StartingIntent, "local", "true")
		PutExtra(STimer.music, StartingIntent, "position", "0")
		'PutExtra(stimer.music, StartingIntent, "currentContainerExtId", "")
		'PutExtra(stimer.music, StartingIntent, "supportsRating", "false")
		'PutExtra(stimer.music, StartingIntent, "ListSize", "0")
		'PutExtra(stimer.music, StartingIntent, "previewPlayType", "")
		'PutExtra(stimer.music, StartingIntent, "ListPosition", "0")
		CallSubDelayed2(Widgets, "RefreshAllOfOneType", 13)
	End If
End Sub



Sub MakeString(Character As String, Amount As Int) As String 
	Dim temp As Int , tempstr As StringBuilder
	tempstr.Initialize 
	For temp = 1 To Amount
		tempstr.Append(Character)
	Next
	Return tempstr.ToString 
End Sub

Sub EnumSections(Section As Int)
	Dim Values As List , temp As Int ,tempstr As String 
	Values.Initialize2(Regex.Split(",",GetSectionInfo(Section,-1)))
	For temp = 0 To Values.Size-1
		tempstr=GetSectionInfo(Values.Get(temp),1)
		If tempstr.Length>0 Then BroadcastToLauncher3("seedsection", tempstr, "toast", GetSectionInfo(Values.Get(temp),2), "index", Values.Get(temp))
	Next
	BroadcastToLauncher("enumdone",0)
End Sub
Sub FileExists(Dir As String, Filename As String) As Boolean
	If File.Exists(Dir, Filename) Then Return File.size(Dir, Filename)>0	
End Sub
Sub GetHelpFile(SectionID As Int) As String 
	Select Case SectionID
			Case -1,11,13: Return "help"
			Case -2: Return "dos"
			Case 20,25,26,27,28,29,34,43,44,53,54,55, 56,57,61,63, 68,69,70,75,76,77,80,81,82,86,87,88,91,-999: Return ""
			Case 79: Return "voice"
	End Select
	If SectionID>1000 Then Return "educational"
	Return SectionID
End Sub
'-1=reverse section, 0=section, 1=Name, 2=Toast
Sub GetSectionInfo(Index As Int , Data As Int) As String 
	Dim tempstr As String ,temp As Int, Values As List, IsValid As Boolean
	Select Case Data
		Case -1'reverse section		last 49
			Select Case Index
				Case -1:tempstr=GetSectionInfo(0,-1) & "," & GetSectionInfo(1,-1) & "," & GetSectionInfo(2,-1) & "," & GetSectionInfo(3,-1) & "," & GetSectionInfo(4,-1)'ALL
				Case 0: tempstr="1,2,3,6,8,18,39,48"'SNSR
				Case 1: tempstr="4,5,7,12,15,21,22,24,37,42,43,31,58,59,60,62,65,74,78,83"'FNCT
				Case 2: tempstr="16,17,40,49,72,85"'GAME
				Case 3: tempstr="9,10,11,13,14,19,20,25,26,27,28,29,30,33,44,45,34,50,53,54,55,56,57,61,63,64,66,67,68,69,70,75,76,77,80,81,84,86,87,88,89,91,92"'GNDN
				Case 4: tempstr="-3,-2,-1,0,23,36,35,32,38,41,47,51,52,71,73,79,82,90"'SYS
				
				Case 5:	tempstr="1001,1002,1003,51,-3"'Educational mode
			End Select
		Case 0'section
			For temp = 0 To 4
				Values.Initialize 
				Values.AddAll( Regex.Split(",", GetSectionInfo(temp,-1)))
				If Values.IndexOf(Index)>-1 Then Return IIFIndex(temp, Array As String("SNSR","FNCT", "GAME", "GNDN", "SYS"))
			Next	
		Case 1'Name
			Select Case Index
				Case -2:	IsValid = Main.DOS > -1'OMEGA DIRECTIVE
				Case 31,32,35,37,38,41:  	IsValid = Not(IsRIM) And Not(IsOuya)'DAY DREAM/LOCK SCREEN,COMMUNICATOR SETTINGS,SECURITY,WIDGETS,ALARMS,COMMUNICATOR
				Case 51:	IsValid = debugMode'DEBUG SETTINGS
				Case 3,8,18,22:  	IsValid = Not(IsOuya)'SENSOR METERS,TACTICAL,FREQUENCY,PERSONAL LOG
				Case 58:	IsValid = debugMode And IsPackageInstalled("com.omnicorp.lcarui.launcher")'ICON MODIFIER
				Case 34:  	IsValid = Main.AprilFools Or (DateTime.GetMonth(DateTime.Now)=5 And DateTime.GetDayOfMonth(DateTime.Now)=4)'TARGETING COMPUTER
				Case 48:	IsValid = Not(IsAmazonFireTV)'TRICORDER
				Case Else:  IsValid = True
			End Select
			If IsValid Then 
				If Main.aprilfools And Translation.ContainsKey("sec_" & Index & "_afm") Then 
					tempstr = GetString("sec_" & Index & "_afm")
				Else 
					tempstr = GetString("sec_" & Index)	
				End If
			End If			
		Case 2'Toast info/description
			If Index>1000 And Index <1004 Then 
				tempstr = GetString("toast_edu")
			Else 
				tempstr = GetString("toast_" & Index)
			End If
	End Select
	Return tempstr
End Sub

Sub RandomQuote(Character As String) As String 
	Dim Quotes As Int, AFMquotes As Int = 0 
	Select Case Character.ToUpperCase 
		Case "Q"
			Quotes=GetString("q_count")
			Return GetString("q_" & Rnd(0,Quotes+1+AFMquotes))
	End Select
End Sub

Sub LWPLIST As List
	Dim temp As List = GetStrings("lwp_", 0)
	temp.AddAll( Regex.Split(",", GetString("lwp_sub")) )'The RANDOM screens, add to Main.TranslateSection
	If Main.DOS>-1 Then temp.Add(GetString("lwp_-1"))
	Return temp
End Sub

'Sub GetBundleExtra(StartingIntent As Intent, Key As String)
	'Dim jintent As JavaObject = StartingIntent, widgetOptions As JavaObject = jintent.RunMethod("getBundleExtra", Array As Object(Key))
'End Sub

'Used by: LCAR.LCAR_DNA, LCAR.LCAR_Tactical2, LCAR.CRD_Main
Sub dRnd(Start As Int, Finish As Int, ElementType As Int) As Int
	Select Case ElementType
		Case LCAR.LCAR_Tactical2, LCAR.LCAR_DNA, LCAR.CRD_Main, LCAR.TCAR_Main
			If WallpaperService.SubScreenIndex >-1 Then Return WallpaperService.SubScreenIndex 
	End Select
	If debugMode Then Return Finish - 1
	Return Rnd(Start,Finish)
End Sub

Sub PutExtra(Dest As Map, StartingIntent As Intent, Extra As String, Default As String)
	Dest.Put(Extra, GetExtra(StartingIntent, Extra, Default))
End Sub
Sub GetExtra(StartingIntent As Intent, Extra As String, Default As String) As String 
	If StartingIntent.HasExtra(Extra) Then Return StartingIntent.GetExtra(Extra) Else Return Default
End Sub

Sub Beep(Duration As Int, Frequency As Int)
	Dim temp As Beeper 
	If Duration>0 And Frequency>0 Then
		temp.Initialize(Duration, Frequency)
		temp.Beep 
	End If
End Sub

Sub SetSpeakerPhone(Value As Boolean)
    Dim R As Reflector, mode As Int = IIF(SDKversion <= 19, 2,3)'Android 4.4
	IsSpeakerPhone=Value
	Log("SetSpeakerPhone: " & Value)
	'https://developer.android.com/reference/android/media/AudioManager.html#MODE_IN_COMMUNICATION
	'MODE_IN_CALL =2, MODE_IN_COMMUNICATION=3
	
	Log("SDKversion: " & SDKversion)
    R.Target = R.GetContext
	R.Target = R.RunMethod2("getSystemService", "audio", "java.lang.String")
    If Not(Value) Then mode = 0
    R.RunMethod2("setMode", mode, "java.lang.int")
	R.RunMethod2("setSpeakerphoneOn", Value, "java.lang.boolean")
	'R.RunMethod2("setWiredHeadsetOn", Not(Value), "java.lang.boolean")
End Sub

Sub DebugLog(Text As String)As Boolean 
	LogColor("DEBUG: " & Text, Colors.red)
	If debugMode Then
		Dim Output As OutputStream = File.OpenOutput(LCAR.DirDefaultExternal, "log.txt", True), ST As ByteConverter 
		Text= DateTime.Time(DateTime.Now) & ": " &  Text & CRLF
		Output.WriteBytes( ST.StringToBytes(Text, "UTF8"), 0, Text.Length)
		Output.Close
	End If
End Sub



Sub SetVolume(Full As Boolean, DoFull As Boolean , CallingSub As String)
	Dim P As Phone , Channel As Int = P.VOLUME_MUSIC, DesiredVolume As Int = 100' P.VOLUME_SYSTEM
	If Full Then
		If Not(LCAR.ResetVol) Then OldInternalVol=LCAR.cVol
		'If OldInternalVol =0 OR DoFull Then LCAR.Volume(100, False)
		'If STimer.Headset_Plug Then 
		'	DesiredVolume= 15
		'	Log("HEADSET DETECTED! " & IsSpeakerPhone & " " & DesiredVolume)
		'End If 
		LCAR.Volume(DesiredVolume, False)'And Not(IsSpeakerPhone)
		LCAR.ResetVol=True
		OldVolume = P.GetVolume(Channel)
		DebugLog("LCAR.cVol: " & LCAR.cVol & " intVol: " & OldVolume)
		P.SetVolume(Channel, P.GetMaxVolume(Channel),False)
		
'			P.SetVolume(P.VOLUME_ALARM, P.GetMaxVolume(P.VOLUME_ALARM),False)
'			P.SetVolume(P.VOLUME_MUSIC , P.GetMaxVolume(P.VOLUME_MUSIC),False)
'			P.SetVolume(P.VOLUME_NOTIFICATION , P.GetMaxVolume(P.VOLUME_NOTIFICATION),False)
'			P.SetVolume(P.VOLUME_RING , P.GetMaxVolume(P.VOLUME_RING),False)
'			P.SetVolume(P.VOLUME_SYSTEM , P.GetMaxVolume(P.VOLUME_SYSTEM),False)

	Else If AllowVolumeAccess Then 
		DebugLog("OldInternalVol: " & OldInternalVol & " oldIntVol: " & OldVolume)
		LCAR.ResetVol=False
		LCAR.Volume(OldInternalVol,False)
		P.SetVolume(Channel, OldVolume,False)
	End If

End Sub






Sub GetNotification As Object 
	If NOTIPLUS.IsInitialized Then Return NOTIPLUS
	If NOTI.IsInitialized Then Return NOTI
End Sub

Sub InitNotiPlus
	NOTIPLUS.Initialize
	NOTIPLUS.setActivity(Main)
	NOTIPLUS.LargeIcon = LoadPicture(File.DirAssets, "insigniabig.png")
	NOTIPLUS.SmallIcon = "insignia"
	NOTIPLUS.OnGoingEvent=True
	NOTIPLUS.AutoCancel=False
	NOTIPLUS.DefaultSound=False
	NOTIPLUS.DefaultVibrate=False 
	NOTIPLUS.DefaultLight=False
End Sub
Sub SetNoti(Enabled As Boolean)
	If APIlevel >= 16 Then 'jellybean
		If Enabled <> AllowNoti Or Not(NOTIPLUS.IsInitialized) Then
			If Enabled Then
				AllowNoti=True
				InitNotiPlus
				AutoUpdateNoti
			Else
				CloseNoti
			End If
		End If
	Else If Enabled <> AllowNoti Or Not(NOTI.IsInitialized) Then
		If Enabled Then
			AllowNoti=True
			NOTI.Initialize 
			NOTI.Icon="insignia"
			NOTI.Sound=False
			NOTI.AutoCancel=False
			NOTI.Vibrate=False
			NOTI.OnGoingEvent=True
			AutoUpdateNoti
		Else 
			CloseNoti
		End If
	End If
	AllowNoti=Enabled
End Sub

Sub StartStimer
	Dim Started As Boolean = False' CallSub(stimer, "StartStimer")
	If Not(Started) Then StartService(STimer)
End Sub

Sub CloseNoti
	If APIlevel >= 16 Then
		If NOTIPLUS.IsInitialized Then NOTIPLUS.Cancel(0)
	Else
		If NOTI.IsInitialized Then NOTI.Cancel(0)
	End If
End Sub
Sub UpdateNoti(tTitle As String, Body As String)
	Dim TimerIsRunning As Boolean = IsTimerRunning(0)>0, Actions As Int , BatS As String 
	If Not(AllowNoti) Then 
		CloseNoti
	Else If APIlevel >= 16 Then
		InitNotiPlus
		If Body.Length = 0 Then BatS = GetStringVars("noti_batt", Array As String(LCAR.BatteryPercent, IIF(LCAR.isCharging, GetString("noti_ac"), "")))
		If TimerIsRunning Then 
			NOTIPLUS.setCustomLight(LCAR.GetColor(LCAR.LCAR_Orange,False,255), 500,500)
			NOTIPLUS.AddAction2("notimer", GetString("noti_belay_timer"), "BELAY TIMER", STimer)
			Actions=Actions+1
		Else 
			If STimer.AlarmTime>0 Then
				NOTIPLUS.AddAction2("noalarm", GetString("noti_belay_alarm") ,"BELAY ALARM", STimer)
				Actions=Actions+1
				NOTIPLUS.Ticker = Body
			End If
			If BelayTime > DateTime.Now Then 
				NOTIPLUS.AddAction2("yesalarm", GetString("noti_unbelay_alarm"),"UNBELAY ALARM", STimer)
				Actions=Actions+1
			End If
		End If
		If Actions < 2 Then NOTIPLUS.AddAction2("vrec", GetString("vrec"),"V.REC", STimer)
		NOTIPLUS.ContentTitle=tTitle
		If btimer.NotificationWidget>-1 And Not(TimerIsRunning) Then
			NOTIPLUS.SetStyle( MakeBigPictureStyle(tTitle,Body) )
		Else If Body.Length = 0 Then
			NOTIPLUS.setProgress(100, LCAR.BatteryPercent, False)
			Body = BatS
		End If
		NOTIPLUS.ContentText = Body	
		NOTIPLUS.Notify(0)	
	Else If NOTI.IsInitialized Then
		If Body.Length = 0 Then Body = BatS
		NOTI.SetInfo(tTitle,Body,Main)
		NOTI.Notify(0)
	End If
End Sub
Sub GetDeviceSize(Width As Boolean) As Int
	If Width Then Return GetDeviceLayoutValues.Width
	Return GetDeviceLayoutValues.height
End Sub

Sub MakeBigPictureStyle(tTitle As String, Body As String) As NotificationBigPictureStyle 
	Dim BP As NotificationBigPictureStyle, BMP As Bitmap, Width As Int = Max(512dip, Min(GetDeviceLayoutValues.Width,GetDeviceLayoutValues.height))'200dip
	AutoLoad
	BP.Initialize 
	BP.BigContentTitle=tTitle
	BP.SummaryText = Body
	BMP.InitializeMutable(Width, Width*0.5)'2:1 aspect ratio, height has a max of 256dp
	CallSubDelayed(Widgets,"LauncherDir")
	CallSub3(Widgets, "AutoDrawWidget", BMP,  btimer.NotificationWidget)
	BP.BigPicture = BMP
	Log("btimer.NotificationWidget: " & btimer.NotificationWidget)
'	If Not(btimer.HasDrawn) Then
'		btimer.HasDrawn = True
'		StartServiceAt(btimer, DateTime.Now + DateTime.TicksPerSecond * 5, True)
'	End If
	Return BP
End Sub
Sub NotiEmpty
	If STimer.AlarmTime = 0 And NOTITitle.Length=0 Then 
		Select Case btimer.NotificationWidget 
			Case -1, 2: UpdateNoti(GetString("app"), "")'none, battery
		End Select
	End If
End Sub

Sub AutoUpdateNoti() As Boolean 
	Dim tempstr As String ,RET As Boolean 
	If NOTITitle.Length=0 Then 
		tempstr=HandleAlarm(False)
		RET=True
	End If
	If tempstr.Length=0 Or NOTITitle.Length>0 Then
		tempstr=NOTITitle
	Else If Not(STimer.AllowServices) Then
		tempstr=GetString("noti_noservices")
	Else
		tempstr=GetStringVars("noti_nextalarm", Array As String(tempstr))
	End If
	'If tempstr.Length = 0 Then tempstr = "AUX. POWER: " & LCAR.BatteryPercent & IIF(LCAR.isCharging , " (CHARGING)", "")
	'If NOTIBody.Length >0 Then		
	'	UpdateNoti(tempstr,NOTIBody)
	'Else
	UpdateNoti(GetString("app"), tempstr)
	If STimer.AlarmTime>0 And IsPaused(STimer) And(STimer.AllowServices) Then StartStimer'StartService(STimer)
	'end if
	Return RET
End Sub

Sub BroadcastTo(Package As String, Action As String, Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize(Package, "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	P.SendBroadcastIntent(I)
End Sub

Sub Broadcast(Action As String, Value As Object)
	BroadcastTo("com.omnicorp.dialer", Action, Value)
End Sub
Sub BroadcastToReturnAddress(Action As String, Value As Object)
	If STimer.ReturnAddress.Length=0 Then STimer.ReturnAddress="com.omnicorp.launcher"
	BroadcastTo(STimer.ReturnAddress, Action, Value)
End Sub
Sub BroadcastToLauncher(Action As String, Value As Object)
	BroadcastTo("com.omnicorp.launcher", Action, Value)
End Sub
Sub BroadcastToLauncher2(Action As String, Value As Object, Value2Name As String, Value2Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.launcher", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	I.PutExtra(Value2Name, Value2Value)
	P.SendBroadcastIntent(I)
End Sub
Sub BroadcastToLauncher3(Action As String, Value As Object, Value2Name As String, Value2Value As Object, Value3Name As String, Value3Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.launcher", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	I.PutExtra(Value2Name, Value2Value)
	I.PutExtra(Value3Name, Value3Value)
	P.SendBroadcastIntent(I)
End Sub
Sub HILOFile(Dir As String, HiFilename As String, LoFilename As String)As String 
	If File.Exists(Dir, LoFilename) Then Return LoFilename
	If File.Exists(Dir, HiFilename) Then Return HiFilename
	Return ""
End Sub

'Alarm handling api
Sub ForceAlarmRecheck
	STimer.CurrentAlarm = -1
	STimer.AlarmTime = 0 
	HandleAlarm(False)
	AutoUpdateNoti
End Sub
'auto-update the alarm after midnight or time zone changes
Sub DoubleCheckAlarm(Force As Boolean)
	If OldDay=-1 Or Force Then
		OldDay= DateTime.GetDayOfYear(DateTime.Now)
		OldTimezone = DateTime.TimeZoneOffset 
	Else 
		If DateTime.GetDayOfYear(DateTime.Now) <> OldDay Or OldTimezone <> DateTime.TimeZoneOffset Then 
			DoubleCheckAlarm(True)
			AutoUpdateNoti
		End If
	End If
	If STimer.AlarmTime>0 And STimer.AlarmTime<= DateTime.Now And Main.CurrentSection <> 999 Then 
		Log("Alarm should have went off")
		CallSub(STimer,"WakeUp")
		HandleAlarm(True)
	End If
End Sub
'check if there's any enabled alarm using a deadman
Sub HasDeadMan As Boolean
	Dim temp As Int, TempAlarm As Alarm 
	If DeadmanPass.Length>0 Then
		For temp = 0 To Alarms.Size-1
			TempAlarm=AlarmHandler(Alarms.Get(temp))
			If TempAlarm.Enabled And TempAlarm.Action=3 Then Return True
		Next
	End If
End Sub

Sub SDKversion As Int 
	Dim p As Phone
   	Return p.SdkVersion
End Sub
Sub GetHalfSecond As Boolean 
	Return (DateTime.Now Mod DateTime.TicksPerSecond) > 500
End Sub
'try open the nfc setting, the intent is api dependant
Sub OpenNFCsettings 
    Dim In As Intent, Ph As Phone
    Dim getAPIlevel As Int = SDKversion
	If getAPIlevel < 10 Then Return 
    Try      
        If getAPIlevel >=16 Then          
            In.Initialize("android.settings.NFC_SETTINGS","")
        Else 'on old devices is located in wireless settings
            In.Initialize("android.settings.WIRELESS_SETTINGS","")
        End If 
        StartActivity(In)
    Catch
        Log("error opening the NFC settings: " & LastException.Message)
    End Try
End Sub

Sub SetExactAndAllowWhileIdle (Time As Long, ServiceName As String)
     Dim in As Intent, ctxt As JavaObject, pi As JavaObject, amc As JavaObject
     in.Initialize("", "")
     in.SetComponent(Application.PackageName & "/." &  ServiceName.ToLowerCase)
     ctxt.InitializeContext
     Dim am As JavaObject = ctxt.RunMethod("getSystemService", Array("alarm"))
     pi = pi.InitializeStatic("android.app.PendingIntent").RunMethod("getService", Array(ctxt, 1, in, 134217728))
     amc.InitializeNewInstance("android.app.AlarmManager$AlarmClockInfo", Array(Time, Null))
     am.RunMethod("setAlarmClock", Array(amc, pi))
End Sub

Sub StartServiceAtExact2 (ServiceName As String, Time As Long, DuringSleep As Boolean)
  	StartServiceAtExact(ServiceName, Time, True)
	If SDKversion >= 23 And DuringSleep Then
		LogColor("Sleeping alarm: " & Time, Colors.Red)
		'BroadcastTo	("com.omnicorp.mew", "timer", Time)  
		
		Dim in As Intent, ctxt As JavaObject, pi As JavaObject
	    in.Initialize("", "")
	    in.SetComponent(Application.PackageName & "/." &  ServiceName.ToLowerCase)
	    ctxt.InitializeContext
	    Dim am As JavaObject = ctxt.RunMethod("getSystemService", Array("alarm"))
	    pi = pi.InitializeStatic("android.app.PendingIntent").RunMethod("getService",  Array(ctxt, 1, in, 134217728))
	    am.RunMethod("setExactAndAllowWhileIdle", Array(0, Time, pi))
		
		SetExactAndAllowWhileIdle(Time, ServiceName)
  	End If
End Sub


'handle the alarm answer slider
Sub HandleAlarmAnswer(Answer As Boolean,Settings As Map ) As Boolean 
	'true = wake up, false = snooze
	If Answer Then'woke up
		'Log("alarmindex: " & AlarmIndex)
		If CWA.IsInitialized And AlarmIndex>-1 And AlarmIndex< Alarms.Size And Not(isDemoing) Then
			'Log("Is a real alarm")
			If DaysOfWeek(CWA,False).Length = 0 Then'non-repeating, disable it
				'Log("Disable alarm!")
				CWA.Enabled=False
				SaveAlarm(Settings)
			End If
		End If
		AutoUpdateNoti
		IsSnoozing=False
		Main.AwaitingAnswer=False
		Log("no longer awaiting answer")
	Else If Not(CWA.IsInitialized) Then'demo mode snooze
		IsSnoozing=True
		STimer.AlarmTime=DateTime.Now + DateTime.TicksPerSecond'(10 * DateTime.TicksPerMinute)
		StartServiceAtExact2("STimer", STimer.AlarmTime, True)
		Return False
	Else If CWA.Snooze>0 Then'snoozed
		IsSnoozing=True
		STimer.AlarmTime=DateTime.Now + (CWA.Snooze * DateTime.TicksPerMinute)
		StartServiceAtExact2("STimer", STimer.AlarmTime, True)
		Main.AwaitingAnswer=False
		Log("no longer awaiting answer")
	Else'unable to snooze
		If IsScreenOn Or Not(LCAR.MP.IsPlaying) Then 
			LCAR.PlaySoundAnyway(32)
			If IsScreenLocked Then' UserEscapedAlarm
				STimer.AlarmTime=DateTime.Now + DateTime.TicksPerSecond*2
				StartServiceAtExact2("STimer", STimer.AlarmTime, True)
			End If
		Else If LCAR.MP.IsPlaying Then
			LCAR.MP.Looping =True
		Else
			LCAR.PlaySound(0,True)
		End If
		Return False
	End If
	Return True
End Sub
Sub UserEscapedAlarm
	Log("CANNOT SNOOZE " & LCAR.WasPlaying)
	LCAR.Looping = LCAR.WasPlaying
	LCAR.NeedsResuming = LCAR.WasPlaying
	HandleAlarmAnswer(False, Main.Settings)	
	'STimer.AlarmTime=DateTime.Now + DateTime.TicksPerSecond
	'StartServiceAt(STimer, STimer.AlarmTime, True)
	
	'If Main.CurrentSection<>999 Then
	'	CallSub(STimer,"WakeUp")
	'	CallSubDelayed3(Main,"ShowSection", 999,False)
	'Else 
	'	Log("Main.CurrentSection: " & Main.CurrentSection)
	'End If
End Sub
'handle alarm triggers and/or getting the next alarm
Sub HandleAlarm(Expire As Boolean)As String 
	Dim tempstr As String ,Today As String ,Tomorrow As String ,Now As String 
	If Expire Then
		If Not(IsSnoozing) Then
			AlarmIndex=STimer.CurrentAlarm
			CWA = AlarmHandler(Alarms.Get(AlarmIndex))
		End If
		If CWA.SoundEnabled Or CWA.Action = 3 And DateTime.Now > (BelayTime + DateTime.TicksPerMinute) Then
			If CWA.Length >0 Then NewTimer("Alarm",2, CWA.Length*60)
			STimer.SkipUpdate=True
			CallSubDelayed3(Main,"ShowSection", 999,False)
		End If
		Select Case CWA.Action 
			Case 1,2:Broadcast("DND", CWA.Action=2) '1=DND OFF,2=DND ON
		End Select
	End If
	If STimer.CurrentAlarm = -1 Or STimer.AlarmTime < DateTime.Now Then
		STimer.AlarmTime = -1
		STimer.CurrentAlarm=GetNextAlarm(DateTime.Now)
		
	
		'If STimer.CurrentAlarm>-1 Then 
	'		STimer.AlarmTime = GetNextAlarmTime(AlarmHandler(Alarms.Get(STimer.CurrentAlarm)), Max(STimer.AlarmTime,DateTime.Now + DateTime.TicksPerMinute))
	'	End If
	End If
	
	If STimer.CurrentAlarm>-1 Then
		If STimer.AllowServices Then 
			StartServiceAtExact2("STimer", STimer.AlarmTime, True)
			Now = DateTime.Date(STimer.AlarmTime)
			Today = DateTime.Date(DateTime.Now)
			Tomorrow=DateTime.Date(DateTime.Now + DateTime.TicksPerDay)
			Select Case Now
				Case Today: tempstr=GetString("date_today")
				Case Tomorrow: tempstr = GetString("date_tomorrow")
				Case Else: tempstr=GetDate(STimer.AlarmTime)
			End Select
			TempAlarmS = "(" & (STimer.CurrentAlarm+1) & ") " & tempstr & " AT " & TheTime(STimer.AlarmTime)
		Else
			TempAlarmS = GetString("noti_noservices")
		End If
		Return TempAlarmS
	End If

	Return ""
End Sub
Sub GetDateVerbose(Date As Long, TwelveHourTime As Boolean, IncludeSeconds As Boolean) As String 
	Dim tempstr As StringBuilder , Today As String ,Tomorrow As String, Yesterday As String, Now As String = DateTime.Date(Date) , Hour As Int = DateTime.GetHour(Date), Seconds As String 
	If Date = 0 Then Return GetString("invalid")
	tempstr.Initialize 
	Today     =	DateTime.Date(DateTime.Now)
	Tomorrow  =	DateTime.Date(DateTime.Now + DateTime.TicksPerDay)
	Yesterday =	DateTime.Date(DateTime.Now - DateTime.TicksPerDay)
	Select Case Now
		Case Yesterday: tempstr.Append(GetString("date_yesterday"))
		Case Today: 	tempstr.Append(GetString("date_today"))
		Case Tomorrow: 	tempstr.Append(GetString("date_tomorrow"))
		Case Else
			If Date < DateTime.Now Then 'the past
				tempstr.Append(GetString("date_" & DateTime.GetMonth(Date)) & " " & DateTime.GetDayOfMonth(Date) & ", " & DateTime.GetYear(Date))
			Else 'the future
				For temp = 2 To 14
					Tomorrow=DateTime.Date(DateTime.Now + DateTime.TicksPerDay*temp)
					If Now = Tomorrow Then'blow up the world cause a paradox has just occurred
						If temp>7 Then tempstr.Append("NEXT ")
						tempstr.Append(GetDateString(0, DateTime.GetDayOfWeek(DateTime.Now) + temp, False))
					End If
				Next
				If temp = 15 Then tempstr.Append(" " & GetDateString(0, DateTime.GetDayOfWeek(Date),False) & " " & GetDateString(1, DateTime.GetMonth(Date),False) & " " & DateTime.GetDayOfMonth(Date))
			End If 
	End Select
	tempstr.Append(", AT ")
	If DateTime.GetSecond(Date) = 0 Then IncludeSeconds = False
	If IncludeSeconds Then Seconds = " AND " & DateTime.GetSecond(Date) & " SECONDS"
	If DateTime.GetMinute(Date) = 0 And (Hour = 0 Or Hour = 12) Then
		If IncludeSeconds Then tempstr.Append( Seconds.Replace(" AND ", "") & " AFTER ")
		If Hour = 0 Then tempstr.Append("MIDNIGHT") Else tempstr.Append("NOON")
	Else If TwelveHourTime And DateTime.GetMinute(Date) = 0 And Not(IncludeSeconds) Then
		tempstr.Append(Hour  & " O CLOCK " & IIF(Hour<12, "A.M.", "P.M."))
	Else If TwelveHourTime Then
		tempstr.Append(Hour & " " & DateTime.GetMinute(Date) & " " & IIF(Hour<12, "A.M.", "P.M.") & Seconds)
	Else If DateTime.GetMinute(Date) = 0 Then
		tempstr.Append(Hour & " HUNDRED HOURS" & Seconds)
	Else
		tempstr.Append(Hour & " " & DateTime.GetMinute(Date) & " HOURS" & Seconds)
	End If
	Return tempstr.ToString 
End Sub
Sub AbsoluteDateVerbose(Date As Long) As String 
	Return GetDateString(0, DateTime.GetDayOfWeek(DateTime.Now), False) & ", " & GetDateString(1, DateTime.GetMonth(DateTime.Now), False) & " " & DateTime.GetDayOfMonth(DateTime.Now) & " " & DateTime.GetYear(DateTime.Now)
End Sub

'ID: 0=day of week, 1=month, Index: Starts at 1 (Sunday=1, 1st day of the month = 1)
Sub GetDateString(ID As Int, Index As Int, ShortForm As Boolean) As String 
	Dim tempstr As String 
	Select Case ID
		Case 0
			tempstr = IIFIndex((Index-1) Mod 7, Array As String("SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"))'day of week
			tempstr = GetString("date_" & tempstr.ToLowerCase)
		Case 1
			'tempstr = IIFIndex((Index-1) Mod 12, LCARSeffects3.getmonths)'month
			tempstr = LCARSeffects3.NameOfMonth(Index, True)
	End Select
	If ShortForm Then Return Left(tempstr,3) Else Return tempstr
End Sub

Sub EnumAlarms(Settings As Map, Source As List,Load As Boolean ) As List 
	Dim Temp As Int,Count As Int 
	If Load Then'load
		Source.Initialize
		Count = Settings.GetDefault("Alarms",0)
		For Temp = 0 To Count-1
			Source.Add( Settings.Get("Alarm" & Temp) )
		Next
		Return Source
	Else If Source.IsInitialized Then 'save
		Settings.Put("Alarms", Source.Size)
		For Temp = 0 To Alarms.size-1
			'Log(Temp  & " = " &  Source.Get(Temp))
			Settings.Put("Alarm" & Temp, Source.Get(Temp))
		Next
	End If
End Sub
Sub T2B(Text As String) As Boolean
	Return Text.EqualsIgnoreCase(GetString("y")) Or Text.EqualsIgnoreCase(GetString("true"))
End Sub
Sub B2T(Value As Boolean) As String 
	Return IIF(Value,GetString("y"),GetString("n"))
End Sub
Sub AlarmHandler(Text As Object) As Object 
	Dim Temp As Alarm, C As String = ",", tempstr() As String ,Temp2 As Int 
	If Text Is Alarm Then'to string
		Temp = Text		'0			    1				  2  			                                   3					4				  5					6		  7,8,9,10,11,12,13,        14
		If Temp.IsInitialized Then
			Return Temp.Hour & C & Temp.Minute & C & IIF(Temp.SoundEnabled, Temp.SoundID,-1) & C & B2T(Temp.Enabled) & C & Temp.Action & C & Temp.Snooze & C & Temp.Length & Repeats2String(Temp) & C & Temp.Text 
		End If
	Else 'is text, convert to alarm
		If Len(Text)>0 Then
			'Log(Text)
			tempstr=Regex.Split(C,Text)
			Temp=Repeats2String(tempstr)'7 to 13
			Temp.Hour = tempstr(0)
			Temp.Minute = tempstr(1)
			Temp.SoundID = tempstr(2)
			Temp.SoundEnabled=Temp.SoundID>-1
			Temp.Enabled= T2B(tempstr(3))
			Temp.Action = tempstr(4)
			Temp.Snooze = tempstr(5)
			Temp.Length = tempstr(6)
			If tempstr.Length>14 Then Temp.Text = tempstr(14)
		End If
		Return Temp
	End If
'	Temp.Initialize 
'			Temp.Repeats.Initialize 
'			For Temp2 = 0 To 6
'				Temp.Repeats.Add(False)
'			Next
'		End If
End Sub
Sub Repeats2String(Text As Object) As Object 
	Dim Temp As Int,TempAlarm As Alarm, tempstr As StringBuilder ,tempstr2() As String 
	If Text Is Alarm Then'to string
		TempAlarm=Text
		tempstr.Initialize
		For Temp = 0 To TempAlarm.Repeats.Size-1
			tempstr.Append("," & B2T(TempAlarm.Repeats.Get(Temp)))
		Next
		Return tempstr.ToString 
	Else'to alarm
		tempstr2=Text
		TempAlarm.Initialize 
		TempAlarm.Repeats.Initialize 
		For Temp = 0 To 6
			TempAlarm.Repeats.Add( tempstr2(Temp+7).EqualsIgnoreCase("Y"))
		Next
		Return TempAlarm
	End If
End Sub

Sub LoadAlarm(Index As Int, ListID As Int)As String 
	Dim Temp As Int, Tempstr As String ,TempAlarm As Alarm,RetVal As String ,ColorID As Int ,Sound As LCARSound ,Selected As Boolean ,Conflictions As StringBuilder
	If ListID>-1 Then LCAR.LCAR_ClearList(ListID,0)
	If Index = -1 Then'load entire list
		AlarmIndex=-2 
		If Not(Alarms.IsInitialized) Then Alarms = EnumAlarms(Main.Settings, Null,True)
		If ListID>-1 Then LCAR.LCAR_AddListItem(ListID, GetString("alarm_new"), LCAR.lcar_orange, -1, "", False,"", 0,False,-1)
		Conflictions.Initialize 
		For Temp = 0 To Alarms.Size-1
			TempAlarm = AlarmHandler(Alarms.Get(Temp))
			Tempstr= PadtoLength(TempAlarm.Hour,True,2,"0") & ":" & PadtoLength(TempAlarm.Minute,True,2,"0") & " " & DaysOfWeek(TempAlarm,True)'
			Selected=DoesAlarmConflict(Temp)
			If Selected Then Conflictions.Append(IIF(Conflictions.Length=0,"", ", ") & (Temp+1))
			ColorID= IIF(Selected, LCAR.LCAR_RedAlert, IIFIndex(TempAlarm.Action, Array As Int(LCAR.LCAR_Orange, LCAR.LCAR_DarkPurple,LCAR.LCAR_LightPurple, LCAR.LCAR_DarkBlue, LCAR.LCAR_Red)))'Actions: 0=Normal alarm, 1=DND OFF, 2=DND ON, 3=DEAD MAN, 4=alert
			If ListID>-1 Then LCAR.LCAR_AddListItem(ListID, Tempstr, ColorID, Temp+1,  Temp,Selected,  BoolToText(TempAlarm.Enabled), 0,False, -1)
		Next
		RetVal = "NEXT ALARM: " & HandleAlarm(False) & " CURRENT TIME: " & GetDate(DateTime.Now) & " " & TheTime(DateTime.Now)
		If Conflictions.Length>0 Then RetVal = "CONFLICTING ALARMS: " & Conflictions.ToString	
		If BelayTime > DateTime.Now Then RetVal = RetVal & CRLF & "ALARMS BELAYED UNTIL: " & GetDate(BelayTime) & " " & TheTime(BelayTime)
		AutoUpdateNoti 
	Else 
		If Index = 0 Then 'new alarm
			RetVal = GetString("alarm_new")
			AlarmIndex=-1
			CWA.Initialize 
			CWA.Repeats.Initialize 		
			For Temp = 1 To 7
				CWA.Repeats.Add(False)
			Next
			CWA.Enabled=True
			CWA.SoundEnabled=True
			CWA.SoundID=38
			CWA.Hour = DateTime.GetHour(DateTime.Now)
			CWA.Minute=DateTime.GetMinute(DateTime.Now)
			CWA.Text=GetString("alarm_text")
		Else'load existing alarm
			RetVal = "EDIT ALARM " & Index
			AlarmIndex=Index-1
			CWA = AlarmHandler( Alarms.Get(AlarmIndex) )
		End If
		'(Hour As Byte,Minute As Byte, SoundID As Int, Repeats(7) As Boolean, Enabled As Boolean, Action As Byte, Snooze As Int, Length As Int)'Actions: 0=Normal alarm, 1=DND OFF, 2=DND ON, 3=DEAD MAN
		Sound = LCAR.SoundList.Get(CWA.SoundID)
		
		If ListID>-1 Then
			Log(CWA)
			LCAR.LCAR_AddListItem(ListID, GetString("enabled"), 			LCAR.LCAR_Random, IIF(CWA.Enabled,1,0), "", False, BoolToText(CWA.Enabled), 0, False,-1)'0
			LCAR.LCAR_AddListItem(ListID, GetString("date_hour"), 			LCAR.LCAR_Random, CWA.Hour, "", False, CWA.Hour, 0, False,-1)
			LCAR.LCAR_AddListItem(ListID, GetString("date_minute"), 		LCAR.LCAR_Random, CWA.Minute, "", False, CWA.Minute, 0, False,-1)
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_play_sound"), 	LCAR.LCAR_Random, IIF(CWA.SoundEnabled,1,0), GetString("alarm_play_sound_desc"), False, BoolToText(CWA.SoundEnabled), 0, False,-1)
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_sound_name"), 	LCAR.LCAR_Random, CWA.SoundID, "", False, Sound.Name, 0, False,-1)
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_action"), 		LCAR.LCAR_Random, CWA.Action, "", False, IIFIndex(CWA.Action, GetStrings("alarm_actions_", 0)), 0, False,-1)''''
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_time"), 			LCAR.LCAR_Random, CWA.Length, GetString("alarm_time_desc"), False, CWA.Length, 0, False,-1)
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_snooze"), 		LCAR.LCAR_Random, CWA.Snooze, GetString("alarm_snooze_desc"), False, CWA.Snooze, 0, False,-1)
				
			GetDay(ListID, 0,"SUNDAY", CWA)
			GetDay(ListID, 1,"MONDAY", CWA)
			GetDay(ListID, 2,"TUESDAY", CWA)
			GetDay(ListID, 3,"WEDNESDAY", CWA)
			GetDay(ListID, 4,"THURSDAY", CWA)
			GetDay(ListID, 5,"FRIDAY", CWA)
			GetDay(ListID, 6,"SATURDAY", CWA)
			
			If CWA.Text.Length=0 Then CWA.Text = GetString("alarm_text")
			LCAR.LCAR_AddListItem(ListID, GetString("alarm_title"), LCAR.LCAR_Random, -1, CWA.Text, False, CWA.Text, 0, False,-1)
		End If
	End If
	Return RetVal
End Sub
Sub CopyAlarm(TempAlarm As Alarm) As Alarm 
	Return AlarmHandler(AlarmHandler(TempAlarm))
End Sub
Sub SaveAlarm(Settings As Map)
	Dim CurrentAlarm As Alarm 
	If AlarmIndex=-1 Then
		CurrentAlarm = CWA'AlarmHandler(CWA)
		Alarms.Add(AlarmHandler(CWA))'CurrentAlarm)
	Else If AlarmIndex>-1 And AlarmIndex<Alarms.Size Then
		CurrentAlarm =CWA' AlarmHandler(CWA)
		Alarms.Set(AlarmIndex,AlarmHandler(CWA))'CurrentAlarm)
	End If
	STimer.CurrentAlarm = -1 
	STimer.AlarmTime =0
	EnumAlarms(Settings, Alarms,False)
	AutoUpdateNoti 
	If CurrentAlarm.IsInitialized Then
		If IsPaused(STimer) And CurrentAlarm.Enabled And STimer.AllowServices Then StartStimer' StartService(STimer)
	End If
	'EMG: 2 lines above if
End Sub
Sub DeleteAlarm(Settings As Map)
	If AlarmIndex>-1 Then Alarms.RemoveAt(AlarmIndex)
	AlarmIndex=-1
	STimer.CurrentAlarm = -1 
	STimer.AlarmTime =0
	EnumAlarms(Settings, Alarms,False)
	HandleAlarm(False)
End Sub

'ActionID: 0=delete, 1=enable, 2=disable, 3=toggle, AlarmID: 0=All
Sub QuickAlarmAction(Settings As Map, AlarmID As Int, ActionID As Int) As Boolean 
	Dim Count As Int = Settings.GetDefault("Alarms",0), temp As Int 
	If AlarmID < 1 Then
		For temp = Count To 1 Step -1 
			QuickAlarmAction(Settings, temp, ActionID)
		Next
		Return Count>0
	Else If AlarmID <= Count And AlarmID>0  Then
		Select Case ActionID
			Case 0'delete
				AlarmIndex = AlarmID-1
				DeleteAlarm(Settings)
			Case 1,2,3'enable/disable/toggler
				LoadAlarm(AlarmID, -1)
				Select Case ActionID 
					Case 1: CWA.Enabled = True
					Case 2: CWA.Enabled = False
					Case 3: CWA.Enabled = Not(CWA.Enabled)
				End Select
				SaveAlarm(Settings)
				
			Case Else: Return False
		End Select
		Return True
	End If
End Sub

Sub GetDay(ListID As Int, Index As Int, Day As String,TempAlarm As Alarm)
	LCAR.LCAR_AddListItem(ListID, GetString("date_" & Day.ToLowerCase).ToUpperCase, LCAR.LCAR_Random, -1, "", False, BoolToText(TempAlarm.Repeats.Get(Index)), 0, False,-1)
End Sub
Sub DaysOfWeek(TempAlarm As Alarm,asString As Boolean) As String 
	Dim tempstr As StringBuilder ,Temp As Int ,tempstr2() As String = Regex.Split(",", GetString("date_short")),Count As Int,Index As Int
	tempstr.Initialize 
	For Temp = 0 To 6
		If TempAlarm.Repeats.Get(Temp) Then 
			tempstr.Append(IIF(tempstr.Length=0, "", ",") & IIF(asString,tempstr2(Temp),Temp))
			Index=Temp
			Count=Count+1
		End If
	Next
	If asString Then
		Select Case Count
			Case 0: Return GetString("alarm_no_repeat")
			Case 1: Return GetString("date_" & lCase(IIFIndex(Index, Array As String("SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"))))
			Case 7: Return GetString("alarm_everyday")
		End Select
	End If
	Return tempstr.ToString 
End Sub

'Timer 0 is the auto-destruct timer
Sub BelayTimer(ID As Int)
	StopTimer(ID)
	LCAR.SetRedAlert(False, "BelayTimer")
	NOTITitle = ""
	AutoUpdateNoti
	LCAR.SystemEvent(0, -1)
End Sub

'State: True=belay, False=unbelay
Sub BelayCurrentAlarm(State As Boolean)
	If STimer.CurrentAlarm>-1 Or Not(State) Then
		BelayTime = IIF(State, STimer.AlarmTime, 0)
		STimer.CurrentAlarm = -1 
		STimer.AlarmTime = 0 
		AutoUpdateNoti
	End If
End Sub

Sub TheDateTime(Ticks As Long) As String 
	Return DateTime.Date(Ticks) & " " & DateTime.Time(Ticks)
End Sub

Sub GetNextAlarm(Now As Long) As Int
	Dim Temp As Int, tempAlarmTime As Long,NextAlarmTime As Long, NextAlarm As Int =-1
	If Not(Alarms.IsInitialized) Then Return -1
	If Now< BelayTime Then Now = BelayTime
	For Temp = 0 To Alarms.Size-1
		tempAlarmTime = GetNextAlarmTime(AlarmHandler(Alarms.Get(Temp)), Now)
		'Log(Temp & ": " & TheDateTime( tempAlarmTime) & " Belay: " & TheDateTime(BelayTime) & " NOW: " & TheDateTime(Now))
		If tempAlarmTime > Now Then
			If (NextAlarmTime=0 Or tempAlarmTime<NextAlarmTime) And tempAlarmTime>BelayTime Then
				NextAlarmTime=tempAlarmTime
				NextAlarm=Temp
			End If
		End If
	Next
	If STimer.AlarmTime = -1 Then STimer.AlarmTime = NextAlarmTime
	Return NextAlarm
End Sub
Sub DoesAlarmConflict(AlarmID As Int) As Boolean
	Dim Temp As Int,temp2 As Int, TempAlarm As Alarm,tempAlarmTime As Int, tempAlarm2 As Alarm  
	TempAlarm= AlarmHandler(Alarms.Get(AlarmID))
	tempAlarmTime=GetAlarmTime(TempAlarm)
	For Temp = 0 To Alarms.Size-1
		If Temp <> AlarmID Then
			tempAlarm2=AlarmHandler(Alarms.Get(Temp))
			If tempAlarmTime=GetAlarmTime(tempAlarm2) Then
				For temp2 = 0 To TempAlarm.Repeats.Size-1
					If TempAlarm.Repeats.Get(temp2) And tempAlarm2.Repeats.Get(temp2) Then Return True
				Next
			End If
		End If
	Next
End Sub

'AlarmID: if is -1 then find next alarm ID
Sub GetNextAlarmTime2(AlarmID As Int, Now As Long) As Long 
	Dim TempAlarm As Alarm
	If AlarmID=-1 Then AlarmID=GetNextAlarm(Now)
	If AlarmID >-1 And AlarmID < Alarms.Size Then
		TempAlarm =  AlarmHandler(Alarms.Get(AlarmID))
		Return GetNextAlarmTime(TempAlarm, Now)
	End If
End Sub
Sub GetNextAlarmTime(TempAlarm As Alarm, CurrentDate As Long)As Long
	Dim EnabledDays As String,DayOfWeek As Int ,Temp As Int, temptime As Long '
	If TempAlarm.Enabled Then
		If CurrentDate=0 Then CurrentDate = DateTime.Now 
		If CurrentDate<BelayTime Then CurrentDate = BelayTime
		EnabledDays= DaysOfWeek(TempAlarm,False) 'Regex.Split(",", )
		DayOfWeek=DateTime.GetDayOfWeek(CurrentDate)-1
		'Log("CurrentDate: " & TheDateTime( CurrentDate) & " " & DayOfWeek)
		If EnabledDays.Length=0 Then
			If GetAlarmTime(TempAlarm) > GetCurrentTime(CurrentDate) Then'return alarm time at today
				Return MakeTime(TempAlarm.Hour,TempAlarm.Minute,0)
			Else'return alarm time at tomorrow
				Return MakeTime(TempAlarm.Hour,TempAlarm.Minute,0) + DateTime.TicksPerDay
			End If
		Else'return next enabled day
'			If TempAlarm.Repeats.Get(DayOfWeek) Then
'				If GetAlarmTime(TempAlarm) > GetCurrentTime(CurrentDate) Then'return alarm time at today
'					Log("RET3")
'					Return MakeTime(TempAlarm.Hour,TempAlarm.Minute,0)
'				End If
'			End If
			temptime = MakeDate(DateTime.GetYear(CurrentDate), DateTime.GetMonth(CurrentDate), DateTime.GetDayOfMonth(CurrentDate), TempAlarm.Hour,TempAlarm.Minute, 0, 0)'                       ' MakeTime(
			For Temp = DayOfWeek To DayOfWeek+7
				If TempAlarm.Repeats.Get(Temp Mod 7) Then 
					If temptime > CurrentDate Then Return temptime
				End If
				temptime=temptime +  DateTime.TicksPerDay
			Next
'			For Temp = 0 To DayOfWeek
'				DaysAdded=DaysAdded+1
'				If TempAlarm.Repeats.Get(Temp) Then Return MakeTime(TempAlarm.Hour,TempAlarm.Minute,0) + DateTime.TicksPerDay*DaysAdded
'			Next
		End If
	End If
	Return 0
End Sub

Sub GetAlarmTime(TempAlarm As Alarm) As Int
	Return TempAlarm.Hour*100+TempAlarm.Minute 
End Sub
Sub GetCurrentTime(CWDate As Long) As Int
	Return DateTime.GetHour(CWDate) * 100 + DateTime.GetMinute(CWDate)
End Sub

Sub MakeTime(Hour As Int, Minute As Int, Second As Int) As Long
	Dim Now As Long = DateTime.Now 
	Return MakeDate(DateTime.GetYear(Now), DateTime.GetMonth(Now), DateTime.GetDayOfMonth(Now), Hour,Minute,Second,0)
End Sub

'Any paramter: Use -1 for now
Sub MakeDate(Year As Int, Month As Int, Day As Int, Hour As Int, Minute As Int, Second As Int, Millisecond As Int) As Long
	Dim tempDate As Long, HourDiff As Long, tempHour As Int  
	If Year = -1 Then Year = DateTime.GetYear(DateTime.Now)
	If Month = -1 Then Month = DateTime.GetMonth(DateTime.Now)
	If Day = -1 Then Day = DateTime.GetDayOfMonth(DateTime.Now)
	If Hour = -1 Then Hour = DateTime.GetHour(DateTime.Now)
	If Minute = -1 Then Minute = DateTime.GetMinute(DateTime.Now)
	If Second = -1 Then Second = DateTime.GetSecond(DateTime.Now)
	If Millisecond = -1 Then Millisecond = DateTime.Now Mod 1000
	
	tempDate = DateTime.DateParse(PadtoLength(Month,True,2,"0") & "/" & PadtoLength(Day,True,2,"0") & "/" & PadtoLength(Year,True,4,"0")) + (DateTime.TicksPerHour*Hour) + (DateTime.TicksPerMinute*Minute) + (DateTime.TicksPerSecond*Second) + Millisecond
	HourDiff = DateTime.GetHour(tempDate) - Hour
	If HourDiff <> 0 Then 
		HourDiff = -HourDiff * DateTime.TicksPerHour 
		tempDate = tempDate + HourDiff
	End If
	
	'daylight savings time compensator
'	tempHour = ParseTimePart(tempDate,0)
'	Log(tempHour & ": " & DateTime.Time(tempDate))
'	If tempHour < Hour Then 
'		tempDate = tempDate + DateTime.TicksPerHour
'	Else If tempHour > Hour Then 
'		tempDate = tempDate - DateTime.TicksPerHour
'	End If
'	tempHour = ParseTimePart(tempDate,0)
'	Log(tempHour & ": " & DateTime.Time(tempDate))
	
	Return tempDate
End Sub

'Index: 0=hour, 1=minute, 2=second
Sub ParseTimePart(Time As Long, Index As Int) As Int 
	Dim tempstr() As String = Regex.Split(":", DateTime.Time(Time))
	Return tempstr(Index)
End Sub










'settings handling
Sub BoolToText(Value As Boolean ) As String
	If Value Then Return GetString("enabled") Else Return GetString("disabled")
End Sub
Sub HandleSetting(VariableName As String, CurrentValue As Object , DefaultValue As Object, Save As Boolean )As Object
	Dim tempstr As String 
	If Save Then
		Main.Settings.Put(VariableName, CurrentValue)
		Return CurrentValue
	Else
		tempstr=Main.Settings.GetDefault(VariableName,DefaultValue)
		Select Case tempstr.ToLowerCase 
			Case "true": Return True
			Case "false": Return False
			Case Else: Return tempstr
		End Select
	End If
End Sub 
Sub SaveLWPsetting(SettingName As String, Value As Object, Get As Boolean) As Object 
	If Not(WallpaperService.Settings.IsInitialized) Then WallpaperService.Settings = LoadMap(File.DirInternal, "LWP.MAP")
	If Get Then
		Return WallpaperService.Settings.GetDefault(SettingName, Value)
	Else
		WallpaperService.SettingsLoaded=False
		If SettingName.length>0 Then WallpaperService.Settings.Put(SettingName,Value)
		WallpaperService.Settings.Put("SSM", LCAR.SmallScreen)
		File.WriteMap(File.DirInternal,"LWP.MAP",WallpaperService.Settings)
	End If
End Sub
Sub AutoLoad()As Map 
	Dim BMP As Bitmap ,BG As Canvas 
	LCAR.SetupTheVariables 
	LCAR.Setupcolors
	If Not(Main.Settings.IsInitialized) Then 
		BMP.InitializeMutable(1,1)
		BG.Initialize2(BMP)
		LoadSettings(False,BG)
	End If
	Return Main.Settings
End Sub

Sub isSmallScreenDevice As Boolean 
	Dim Manufacturer As String = Model(0).ToLowerCase & " " & Model(1).ToLowerCase & " " & Model(2).ToLowerCase 
	Return Manufacturer.Contains("omate") Or Manufacturer.Contains("rufus") Or Manufacturer.Contains("truesmart")
End Sub

Sub IsDirectory(Filename As String) As Boolean 
	Return File.IsDirectory( GetDir(Filename), GetFile(Filename))
End Sub
Sub RandomFile(Keyname As String, Extensions As String) As String 
	Dim DIRS As List = LoadFiles(Keyname), FILES As List, Dir As String, temp As Int 
	If Extensions = "images" Then Extensions = "jpg,jpeg,png,gif,bmp"
	Do Until Dir.Length > 0 Or DIRS.Size = 0
		temp = Rnd(0, DIRS.Size)
		Dir = DIRS.Get(temp)
		FILES = GetFiles(Dir, Extensions)
		If FILES.Size = 0 Then 
			Dir = ""
			DIRS.RemoveAt(temp)
		End If
	Loop
	If DIRS.Size = 0 Or FILES.Size = 0 Then Return ""
	Return FILES.Get(Rnd(0,FILES.Size))
End Sub
Sub GetFiles(Dir As String, Extensions As String) As List
	Dim EXTS() As String = Regex.Split(",", Extensions.ToLowerCase), temp As Int, RET As List, Files As List = File.ListFiles(Dir), Filename As String 
	RET.Initialize
	For temp = Files.Size - 1 To 0 Step -1
		Filename = File.Combine(Dir, Files.Get(temp))
		'If IsDirectory(Filename) OR Not(IsFileExt(Filename, EXTS)) Then Files.RemoveAt(temp)
		If Not(IsDirectory(Filename)) Then
			If IsFileExt(Filename, EXTS) Then RET.Add(Filename)
			' And File.Exists(Dir, Filename) And File.Size(Dir, Filename) > 0
		End If
	Next
	Return RET 
End Sub
Sub IsFileExt(Filename As String, EXTS As List) As Boolean 
	Dim temp As Int 
	If Filename.Contains(".") Then Filename = GetExtension(Filename)
	Return EXTS.IndexOf( Filename.ToLowerCase) > -1
End Sub
Sub LoadFiles(Keyname As String) As List 
	Dim Files As List, Count As String = Main.Settings.GetDefault(Keyname & ".Count", 0), temp As Int 
	Files.Initialize
	For temp = 0 To Count -1 
		Files.Add(Main.Settings.Get(Keyname & "." & temp))
	Next
	Return Files
End Sub
Sub AddFile(Keyname As String, Filename As String) 
	Dim Count As String = Main.Settings.GetDefault(Keyname & ".Count", 0) 
	Main.Settings.Put(Keyname & "." & Count,  Filename)
	Count=Count+1
	Main.Settings.Put(Keyname & ".Count", Count)
End Sub
Sub RemoveFile(Keyname As String, Filename As String) 
	Dim Files As List = LoadFiles(Keyname), Index As Int = Files.IndexOf(Filename), temp As Int 
	If Index>-1 Then
		Files.RemoveAt(Index)
		Main.Settings.Put(Keyname & ".Count", Files.Size)
		For temp = Index To Files.Size - 1
			Main.Settings.Put(Keyname & "." & temp, Files.Get(temp))
		Next
		Main.Settings.Remove(Keyname & "." & Files.Size)
	End If
End Sub

Sub DefaultZoom() As Int 
	If Model(1) = GetString("sovereign_class") Then Return 8
	Return 2
End Sub

Sub ModifySize(BG As Canvas, Increase As Boolean, Font As Boolean) 
	'LCAR.zoom "0", "1", "2", "3", "4", "5", "6", "7", "8"
	'LCAR.Fontfactor "50%", "55%", "60%", "65%", "70%", "75%", "80%"
	Dim tempstr As String 
	LCAR.HideToast' ("ModifySize")
	If Font Then
		LCAR.Fontfactor = Max(Min(LCAR.Fontfactor + IIF(Increase, 5,-5)  ,80) ,50)
		tempstr= GetStringVars("set_font_factor", Array As String(LCAR.Fontfactor))
	Else
		LCAR.Zoom = Max(Min(LCAR.Zoom + IIF(Increase, 1,-1),MaxZoomFactor),0)
		tempstr= GetStringVars("set_lcars_size", Array As String(LCAR.Zoom))
	End If
	LCAR.LoadLCARSize(BG)
	LCAR.ToastMessage(BG,tempstr,3)
	CallSub2(Main, "SetElement18Text", GetString("set_size_back"))
End Sub

Sub GetDefaultDPI As Float  
	Dim DPI As Int = GetDeviceDPI
	If DPI = 480 Then 
		Return 1.5
	else if DPI > 480 Then 
		Return 2
	End If
End Sub

Sub HasFeature(feature As String) As Boolean
   Dim r As Reflector
   r.Target = r.GetContext
   r.Target = r.RunMethod("getPackageManager")
   Return r.RunMethod2("hasSystemFeature", feature, "java.lang.String")
End Sub

Sub IsAmazonFireTV As Boolean 
	'Dim ModelName As String = Model(0) 
	'If ModelName.Length=4 Then Return Left(ModelName, 3) = "AFT"
	Return HasFeature("amazon.hardware.fire_tv")
End Sub

Sub LoadSettings(Save As Boolean,BG As Canvas) As Boolean 
	Dim tempdate As Long, IsSmaller As Boolean = isSmallScreenDevice
	If Not(Save) Then 
'		Settings.Initialize
'		If File.ExternalReadable = True Then
'			If File.Exists(File.DirInternal, "settings.ini") Then Settings = File.ReadMap (File.DirInternal , "settings.ini") 
'		End If
		Main.Settings = LoadMap(File.DirInternal, "settings.ini")
		IsOuya=Model(0).EqualsIgnoreCase("OUYA") Or IsAmazonFireTV 
		If Main.Settings.ContainsKey("SkipIntro") Then 
			If Main.Settings.Get("SkipIntro") Then Main.Settings.Put("IntroScreen", 0)
			Main.Settings.Remove("SkipIntro")
		End If
	End If
	LoadKeyBindings(Save)
	'lcarseffects.ClearGPScoordinates(Settings)
	'DOS=1
	btimer.NotificationWidget = HandleSetting("NotificationWidget", btimer.NotificationWidget, -1, Save)
	Main.MicEnabled = HandleSetting("MicEnabled",Main.MicEnabled, True, Save)
	LCAR.AntiAliasing = HandleSetting("AntiAliasing",LCAR.AntiAliasing,True, Save)
	'LCAR.Volume(HandleSetting("Volume",  LCAR.cVol, 100, Save), False)
	'LCAR.Mute = HandleSetting("Mute",LCAR.Mute,False, Save)
	Main.BackToQuit= HandleSetting("BackToQuit",Main.BackToQuit,False, Save)
	LCAR.Zoom = HandleSetting("Zoom", LCAR.Zoom, DefaultZoom, Save)
	LCAR.LOD = HandleSetting("LOD",LCAR.LOD, True, Save) And (APIlevel < 19)
	Main.Keytones=HandleSetting("Keytones", Main.Keytones, True,Save)
	Main.KeyToneIndex=HandleSetting("KeyToneIndex",Main.KeyToneIndex, 1,Save)
	'lcarseffects.NAVSTARS = HandleSetting("NAVSTARS",lcarseffects.NAVSTARS, False, Save)
	LCAR.SmallScreen = HandleSetting("SmallScreen", LCAR.SmallScreen, False, Save) Or IsSmaller
	If Save And LCAR.SmallScreen <> WallpaperService.SSM Then SaveLWPsetting("","", False)
	BaseHref = HandleSetting("BaseHREF", BaseHref, "http://en.memory-alpha.org/", Save)
	Main.Screenshots= HandleSetting("Screenshots", Main.Screenshots, True, Save)
	LCAR.SmoothScrolling= HandleSetting("SmoothScrolling", LCAR.SmoothScrolling, False, Save)
	'api.Title = HandleSetting("Title", api.Title, "", Save)
	Main.SkipIntro= HandleSetting("IntroScreen",Main.SkipIntro, 2, Save)
	LCAR.HasHardwareKeyboard= HandleSetting("HasHardwareKeyboard",LCAR.HasHardwareKeyboard,False, Save)
	LCAR.Fontfactor=HandleSetting("Fontfactor",LCAR.Fontfactor, 50, Save)
	Games.UT=HandleSetting("UniversalTranslator",Games.UT, False, Save)
	'LCAR.RumbleEnabled=HandleSetting("Rumble",LCAR.RumbleEnabled, True, Save)
	LCAR.RumbleUnit = HandleSetting("RumbleUnit", LCAR.RumbleUnit,  IIF(HandleSetting("Rumble",True, True, False), 75,0)   , Save)
	Main.DOS=HandleSetting("DOS", Main.DOS, -1, Save)
	Main.WarpCoreRumble=HandleSetting("WarpCoreRumble", Main.WarpCoreRumble, False, Save)
	LCAR.LessRandom= HandleSetting("LessRandom", LCAR.LessRandom, False, Save)
	LCAR.UseAnotherFolder = HandleSetting("UseAnotherFolder", LCAR.UseAnotherFolder, False, Save)
	Main.MenuEnabled = HandleSetting("MenuEnabled",Main.MenuEnabled, True, Save)
	Main.DoSectionToast= HandleSetting("DoSectionToast",Main.DoSectionToast, True, Save)
	SearchProvider=HandleSetting("SearchProvider",SearchProvider, 0, Save)	
	Main.LastVersion= HandleSetting("LastVersion", Main.LastVersion, "", Save) 
	debugMode= HandleSetting("debugMode", debugMode, False, Save) 
	If debugMode Then Main.AprilFools = HandleSetting("AprilFools", Main.AprilFools, False, Save) 
	UsePebble= HandleSetting("UsePebble", UsePebble, False, Save) 
	'AllowVolumeAccess=HandleSetting("AllowVolumeAccess", AllowVolumeAccess, True, Save)
	Widgets.StardateMode = HandleSetting("StardateMode", Widgets.StardateMode, 1, Save)
	InternalEvents=HandleSetting("InternalEvents", InternalEvents, True, Save)
	LCAR.CrazyRez = HandleSetting("HIRES", LCAR.CrazyRez, GetDefaultDPI,Save)
	Main.AllowVRecOffline=HandleSetting("AllowVRecOffline", Main.AllowVRecOffline, False,Save)
	AutoUpdateAPKs = HandleSetting("AutoUpdateAPKS", AutoUpdateAPKs, False,Save)
	AutoInstallAPKs = HandleSetting("AutoInstallAPKS", AutoInstallAPKs, False,Save)
	BelayTime = HandleSetting("BelayTime", BelayTime, 0,Save)
	Main.cTimer = HandleSetting("cTimer", Main.cTimer, 0,Save)
	LCAR.hVol= HandleSetting("hVol", LCAR.hVol, 100,Save)
	BluetoothDelay = HandleSetting("BluetoothDelay", BluetoothDelay, 0,Save)
	TransLanguage = HandleSetting("TransLanguage", TransLanguage, "english",Save)

	LCAR.OverscanX = HandleSetting("OverscanX", LCAR.OverscanX, 0,Save)'OverscanX OverscanY
	LCAR.OverscanY = HandleSetting("OverscanY", LCAR.OverscanY, 0,Save) 
	WallpaperService.TimeOut = HandleSetting("TimeOut", WallpaperService.TimeOut,0 , Save)
	'WallpaperService.BridgePanels = HandleSetting("BridgePanels", WallpaperService.BridgePanels, 5 , Save)
	STimer.AllowServices = HandleSetting("AllowServices", STimer.AllowServices, True , Save)
	
	Games.CardWidth =HandleSetting("CardWidth",Games.CardWidth, 196 , Save)
	Games.CARD_Face =HandleSetting("CARD_Face",Games.CARD_Face, 1 , Save)
	Games.SOL_MaxCards =HandleSetting("SOL_MaxCards",Games.SOL_MaxCards, 3 , Save)
	Games.SOL_ScoringMethod =HandleSetting("SOL_ScoringMethod",Games.SOL_ScoringMethod, 0 , Save)
	Games.SOL_TimedGame =HandleSetting("SOL_TimedGame",Games.SOL_TimedGame, False, Save)
	Games.CARD_UseMulti =HandleSetting("UseMulti",Games.CARD_UseMulti, False, Save)
	Games.DrP_HighScore = HandleSetting("DrP_HighScore", Games.DrP_HighScore, 10000, Save)
	Games.DrP_Motion = HandleSetting("DrP_Motion", Games.DrP_Motion, False, Save)

	Main.Obfuscated = HandleSetting("Obfuscated", Main.Obfuscated, False, Save)
	Main.Password= HandleSetting("Password", Main.Password,  "", Save)
	Main.Starshipname= HandleSetting("Starshipname", Main.Starshipname,  "", Save)
	Main.StarshipID = HandleSetting("StarshipID", Main.StarshipID,  RandomStarshipID, Save)
	Main.UID=HandleSetting("UID", Main.UID, "",Save)
	If Main.UID.Length=0 Then 
		Main.UID=GetUniqueKey(True)
		Main.Settings.Put("UID", Main.UID)
	End If
	Main.YourName=HandleSetting("YourName", Main.YourName, "UNNAMED", Save)
	STimer.ActAsLockscreen=HandleSetting("ActAsLockscreen", STimer.ActAsLockscreen, False, Save)
	STimer.OnlyWhenCharging=HandleSetting("OnlyWhenCharging", STimer.OnlyWhenCharging, False, Save)
	LCAR.LWPUnlocked=HandleSetting("LWPUnlocked", LCAR.LWPUnlocked, True, Save)
	GPlus.FacebookAccessToken = HandleSetting("Facebook",GPlus.FacebookAccessToken,"",Save)
	Widgets.OnlyWhenScreenIsOn = HandleSetting("WidgetsOnlyWhenOn", Widgets.OnlyWhenScreenIsOn, False, Save)
	DreamService.Bright= HandleSetting("Bright", DreamService.Bright, True, Save)
	If Main.DOS =-1 Then WallpaperService.OmegaUnlock  = HandleSetting("OmegaUnlock", WallpaperService.OmegaUnlock, "", Save)
	AllowNoti = HandleSetting("AllowNoti", AllowNoti, False, Save)
	Weather.LoadWeatherSettings(Save)
	Main.HeadsetAction = HandleSetting("HeadsetAction", Main.HeadsetAction, 0, Save)
	LCARSeffects4.TRI_CameraOrientation = HandleSetting("CameraOrientation", LCARSeffects4.TRI_CameraOrientation, 0, Save)
	Main.ScreenOrientation = HandleSetting("ScreenOrientation", Main.ScreenOrientation, 1, Save)
	If IsSmaller Then  Main.ScreenOrientation=0
	LastChecked = HandleSetting("LastChecked", LastChecked, "", Save)
	Main.ShowSubBridges = HandleSetting("ShowSubBridges", Main.ShowSubBridges, False, Save)
	
	datemode = HandleSetting("datemode", datemode, 0, Save)
	Widgets.LockStardateMode = HandleSetting("LockStardateMode", Widgets.LockStardateMode, False, Save)
	AndroidMediaPlayer =HandleSetting("AndroidMediaPlayer", AndroidMediaPlayer, "", Save)
	If AndroidMediaPlayer.Length>0 And Not(IsPackageInstalled(AndroidMediaPlayer)) Then AndroidMediaPlayer = ""
	
	FullscreenMode = HandleSetting("Fullscreen", FullscreenMode, False, Save)
	RealHeight = HandleSetting("RealHeight", RealHeight, LCAR.GetRealSize(True), Save)
	
	LoadReminders(Save)
	LoadNFCtags(Save)
	If Save Then 
		EnumAlarms(Main.Settings, Alarms,False)
		Main.Settings.Put("Security",  CODEC(DeadmanPass, True, GetEncryptionKey(False)))
		If Main.Settings.ContainsKey("EMAILpass") And Encryption Then
			Main.Settings.Put("EMAILencrypted",  CODEC( Main.Settings.Get("EMAILpass"), True, GetEncryptionKey(False)))
			Main.Settings.Remove("EMAILpass")
		End If
		
		tempdate= Main.Settings.Getdefault("FirstRun", 0)
		If tempdate=0 Then Main.Settings.Put("FirstRun", DateTime.Now)
	
		File.WriteMap(File.DirInternal, "settings.ini", Main.Settings)
		
		If File.ExternalWritable Then
			File.Copy(File.DirInternal, "settings.ini", LCAR.DirDefaultExternal, "settings.ini")
		Else
			LCAR.ToastMessage(BG, GetString("sd_card_error"),2)
		End If
		WallpaperService.SettingsLoaded=False
		If Main.Educational.IsInitialized Then File.WriteMap(LCAR.DirDefaultExternal, "educational.ini", Main.Educational)
	Else
		If IsSmaller Then
			LCAR.Zoom=0
			Main.Screenshots=False
		End If
	
		DeadmanPass=Main.settings.Getdefault("Security","")
		If DeadmanPass.Length>0 Then DeadmanPass = CODEC(DeadmanPass,False,GetEncryptionKey(False))
		LoadAlarm(-1,-1)
		SetNoti(AllowNoti)
		Title = GetString("web_default_title")
		LCAR.LoadLCARSize(BG)
		LoadTimers
		If Not( Widgets.HasDrawnWidgets) Then CallSubDelayed(Widgets, "rv_RequestUpdate")		
		Return True
	End If
End Sub

'Second in current minute level
Sub SeedRND
	RndSeed( DateTime.GetSecond(DateTime.Now) )
End Sub
'MilliSeconds since Epoch level
Sub SeedRND2
	RndSeed( DateTime.Now )
End Sub
'Seconds since epoch level
Sub SeedRND3
	RndSeed(Floor(DateTime.Now * 0.001))
End Sub

Sub RandomStarshipID As String 
	Dim Temp As Int 
	If IsInIDE Or IsMyDevice(False) Then
		Return "NX-01"
	Else
		Temp=Rnd( Asc("A"), Asc("Z")+2) 
		If Temp = Asc("Z")+1 Then
			Return "NCC-" & Rnd(999, 999999)
		Else
			Return "NCC-" & Rnd(999, 999999) & "-" & Chr(Temp) 
		End If
	End If
End Sub

Sub RandomText(Digits As String) As String 
	Dim tempstr As StringBuilder, A As String = Asc("A"), Z As String = Asc("Z") + 1
	tempstr.Initialize
	Do Until Digits < 1 
		tempstr.Append(Chr(Rnd(A,Z)))
		Digits = Digits - 1		
	Loop
	Return tempstr.ToString
End Sub

Sub SearchProviders As List
	Dim Temp As List 
	Temp.Initialize2( Array As String("MEMORY-ALPHA", "WIKIPEDIA", "MEMORY-BETA"))
	Return Temp
End Sub

Sub StartGoogleNow(Voice As Boolean)
	Dim i As Intent
	i.Initialize("android.intent.action." & IIF(Voice, "VOICE_", "") & "ASSIST", "")
	StartActivity(i)
End Sub

Sub StartDoze()
	'https://github.com/android/platform_frameworks_base/blob/master/core/java/android/provider/Settings.java
	'OpenSettings("IGNORE_BATTERY_OPTIMIZATION_SETTINGS", "package:" & MyPackage)
End Sub

Sub OpenSettings(Section As String, Uri As String)
	If Section.Length=0 Then Section = "SETTINGS"
	If Section.Contains(".") Then
		OpenActivity(Section, Uri)
	Else
		OpenActivity("android.settings." & Section, Uri)
	End If
End Sub	
Sub OpenActivity(Name As String, Uri As String)
	Dim DoAction As Intent
	DoAction.Initialize(Name, "")
	StartActivity(DoAction)
End Sub


Sub LoadReminders(Save As Boolean)
	Dim temp As Int, Count As Int 
	If Not( Widgets.Reminders.IsInitialized) Then Widgets.Reminders.Initialize 
	If Save Then
		Main.Settings.Put("reminders", Widgets.Reminders.Size)
		For temp = 0 To Widgets.Reminders.Size -1 
			Main.Settings.Put("reminder" & temp, Widgets.Reminders.get(temp))
		Next
	Else
		Widgets.Reminders.Initialize 
		Count = Main.Settings.GetDefault("reminders", 0)
		For temp = 0 To Count - 1
			Widgets.Reminders.Add( Main.Settings.Get("reminder" & temp))
		Next
	End If
End Sub

'ActionID: 0=add reminder, 1=delete reminder (-1=all)
Sub ReminderAction(ActionID As Int, Value As Object) As Boolean 
	Dim Ret As Boolean 
	Select Case ActionID
		Case 0'add
			Value = Trim(Value)
			If Len(Value) > 0 Then
				Widgets.Reminders.Add(Value)
				Ret= True
			End If
		Case 1'delete
			If Value <0 Then
				If Main.CurrentSection = 62 Then LCAR.LCAR_ClearList(3,0)
				Widgets.Reminders.Initialize 
				Ret= True
			Else If Value < Widgets.Reminders.size Then
				If Main.CurrentSection = 62 Then LCAR.LCAR_RemoveListitem(3,Value)
				Widgets.Reminders.RemoveAt(Value)
				Ret= True
			End If 
	End Select
	CallSubDelayed2(Widgets, "RefreshAllOfOneType", 14)'refresh widgets
	Return Ret
End Sub

'Action: 0=down, 1=up
Sub MakeKeyEvent(Action As Int, KeyCode As Int) As Object 
	Dim ke As JavaObject
	ke.InitializeNewInstance("android.view.KeyEvent", Array As Object(Action,  KeyCode))   
	Return ke
End Sub
'ie: keycodes.KEYCODE_MEDIA_FAST_FORWARD 
Sub SendMediaButton(TheButton As Int)
	'method 3
	Dim Data As Intent, P As Phone,Command As String 
	Data.Initialize("android.intent.action.MEDIA_BUTTON", "")
	If AndroidMediaPlayer.Length>0 Then Data.SetComponent(AndroidMediaPlayer)
	Data.PutExtra("android.intent.extra.KEY_EVENT",MakeKeyEvent(0, TheButton))'needs to be passed as a keyevent, not an Int. 1 is up
'	sendOrderedBroadcast(Data, "")
	P.SendBroadcastIntent(Data)
	
	Data.Initialize("android.intent.action.MEDIA_BUTTON", "")
	If AndroidMediaPlayer.Length>0 Then Data.SetComponent(AndroidMediaPlayer)
	Data.PutExtra("android.intent.extra.KEY_EVENT",MakeKeyEvent(1, TheButton))'needs to be passed as a keyevent, not an Int. 1 is up
'	sendOrderedBroadcast(Data, "")
	P.SendBroadcastIntent(Data)


'
'	'method 1
'	Dim MC As MediaController , Command As String 
'	'If thebutton = KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE Then thebutton = KeyCodes.KEYCODE_HEADSETHOOK 
'	If AndroidMediaPlayer.Length=0 Then MC.MediaButton(TheButton)
'
'	'method 2
	Select Case TheButton 
		Case KeyCodes.KEYCODE_MEDIA_NEXT: Command = "next"
		Case KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE: Command = "togglepause"
		Case KeyCodes.KEYCODE_MEDIA_PREVIOUS: Command = "previous"
		Case KeyCodes.KEYCODE_MEDIA_STOP: Command = "stop"
		Case Else: Return
	End Select
	
'	'If Not(IsPackagerunning(AndroidMediaPlayer, False)) Then StartPackage(AndroidMediaPlayer)
'	
'	Dim I As Intent , P As Phone 
'	I.Initialize("com.android.music.musicservicecommand", "")
'	If AndroidMediaPlayer.Length>0 Then I.SetComponent(AndroidMediaPlayer)
'	I.PutExtra("command", Command)
'	P.SendBroadcastIntent(I)
'	
''	I.Initialize("com.android.music.musicservicecommand." & Command, "")
''	If AndroidMediaPlayer.Length>0 Then I.SetComponent(AndroidMediaPlayer)
''	I.PutExtra("command", Command)
''	P.SendBroadcastIntent(I)
'		
	Log("media command: " & Command)
End Sub

Sub StartPackage(PackageName As String)
	Dim PM As PackageManager
	StartActivity(PM.GetApplicationIntent(PackageName))
End Sub

'CurrentOrientation: 0=up, 1=right, 2=down, 3=left
Sub GetOrientation As Int
   	Dim r As Reflector
	r.Target = r.GetActivity
	r.Target = r.RunMethod("getWindowManager")
	r.Target = r.RunMethod("getDefaultDisplay")
	Return r.RunMethod("getRotation")
End Sub

Sub IsLandscape As Boolean
   Dim context As JavaObject
   context = context.InitializeStatic("anywheresoftware.b4a.BA").GetField("applicationContext")
   Dim rotation As Int = context.RunMethodJO("getSystemService", Array As Object("window")).RunMethodJO("getDefaultDisplay", Null).RunMethod("getRotation", Null)
   Dim configOrientation As Int = context.RunMethodJO("getResources", Null).RunMethodJO("getConfiguration", Null) .GetField("orientation")
   Return ((rotation = 0 Or rotation = 2) And configOrientation = 2) Or ((rotation = 1 Or rotation = 3) And configOrientation = 1)
End Sub

'Sub UptimeMillis As Long 
'	Dim REF As Reflector 
'	Return REF.RunStaticMethod("android.os.SystemClock", "uptimeMillis", Null, Null)
'End Sub

'	Long eventtime = SystemClock.uptimeMillis();
'  Intent downIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent downEvent = new KeyEvent(eventtime, eventtime, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  downIntent.putExtra(Intent.EXTRA_KEY_EVENT, downEvent);
'  sendOrderedBroadcast(downIntent, Null);
'
'  Intent upIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent upEvent = new KeyEvent(eventtime, eventtime, KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  upIntent.putExtra(Intent.EXTRA_KEY_EVENT, upEvent);
'  sendOrderedBroadcast(upIntent, Null);



Sub StartPhoneEvents
	If IsPaused(STimer) And STimer.ActAsLockscreen And STimer.AllowServices Then StartStimer' StartService(STimer)
End Sub

Sub CheckLock As Boolean
	Dim R As Reflector
	R.Target = R.GetContext
	R.Target = R.RunMethod2("getSystemService", "keyguard", "java.lang.String")
	Return  R.RunMethod("inKeyguardRestrictedInputMode")
End Sub

Sub SetupCountries
	If Not(Countries.IsInitialized) Then
		Countries.Initialize 
		MakeCountry("Afghanistan", 93)
		MakeCountry("Albania", 355)
		MakeCountry("Algeria", 213)
		MakeCountry("American Samoa", 1684)
		MakeCountry("Andorra", 376)
		MakeCountry("Angola", 244)
		MakeCountry("Anguilla", 1264)
		MakeCountry("Antarctica", 672)
		MakeCountry("Antigua/Barbuda", 1268)
		MakeCountry("Argentina", 54)
		MakeCountry("Armenia", 374)
		MakeCountry("Aruba", 297)
		MakeCountry("Australia", 61)
		MakeCountry("Austria", 43)
		MakeCountry("Azerbaijan", 994)
		MakeCountry("Bahamas", 1242)
		MakeCountry("Bahrain", 973)
		MakeCountry("Bangladesh", 880)
		MakeCountry("Barbados", 1246)
		MakeCountry("Belarus", 375)
		MakeCountry("Belgium", 32)
		MakeCountry("Belize", 501)
		MakeCountry("Benin", 229)
		MakeCountry("Bermuda", 1441)
		MakeCountry("Bhutan", 975)
		MakeCountry("Bolivia", 591)
		MakeCountry("Bosnia/Herzegovina", 387)
		MakeCountry("Botswana", 267)
		MakeCountry("Brazil", 55)
		MakeCountry("British Virgin Islands", 1284)
		MakeCountry("Brunei", 673)
		MakeCountry("Bulgaria", 359)
		MakeCountry("Burkina Faso", 226)
		MakeCountry("Burma (Myanmar)", 95)
		MakeCountry("Burundi", 257)
		MakeCountry("Cambodia", 855)
		MakeCountry("Cameroon", 237)
		MakeCountry("Cape Verde", 238)
		MakeCountry("Cayman Islands", 1345)
		MakeCountry("Central African Republic", 236)
		MakeCountry("Chad", 235)
		MakeCountry("Chile", 56)
		MakeCountry("China", 86)
		MakeCountry("Christmas Island", 61)
		MakeCountry("Cocos Islands", 61)
		MakeCountry("Colombia", 57)
		MakeCountry("Comoros", 269)
		MakeCountry("Rep. of Congo", 242)
		MakeCountry("Dem. Rep. of Congo", 243)
		MakeCountry("Cook Islands", 682)
		MakeCountry("Costa Rica", 506)
		MakeCountry("Croatia", 385)
		MakeCountry("Cuba", 53)
		MakeCountry("Cyprus", 357)
		MakeCountry("Czech Republic", 420)
		MakeCountry("Denmark", 45)
		MakeCountry("Djibouti", 253)
		MakeCountry("Dominica", 1767)
		MakeCountry("Dominican Republic", 1809)
		MakeCountry("Timor-Leste", 670)
		MakeCountry("Ecuador", 593)
		MakeCountry("Egypt", 20)
		MakeCountry("El Salvador", 503)
		MakeCountry("Equatorial Guinea", 240)
		MakeCountry("Eritrea", 291)
		MakeCountry("Estonia", 372)
		MakeCountry("Ethiopia", 251)
		MakeCountry("Falkland Islands", 500)
		MakeCountry("Faroe Islands", 298)
		MakeCountry("Fiji", 679)
		MakeCountry("Finland", 358)
		MakeCountry("France", 33)
		MakeCountry("French Polynesia", 689)
		MakeCountry("Gabon", 241)
		MakeCountry("Gambia", 220)
		MakeCountry("Gaza Strip", 970)
		MakeCountry("Georgia", 995)
		MakeCountry("Germany", 49)
		MakeCountry("Ghana", 233)
		MakeCountry("Gibraltar", 350)
		MakeCountry("Greece", 30)
		MakeCountry("Greenland", 299)
		MakeCountry("Grenada", 1473)
		MakeCountry("Guam", 1671)
		MakeCountry("Guatemala", 502)
		MakeCountry("Guinea", 224)
		MakeCountry("Guinea-Bissau", 245)
		MakeCountry("Guyana", 592)
		MakeCountry("Haiti", 509)
		MakeCountry("Honduras", 504)
		MakeCountry("Hong Kong", 852)
		MakeCountry("Hungary", 36)
		MakeCountry("Iceland", 354)
		MakeCountry("India", 91)
		MakeCountry("Indonesia", 62)
		MakeCountry("Iran", 98)
		MakeCountry("Iraq", 964)
		MakeCountry("Ireland", 353)
		MakeCountry("Isle of Man", 44)
		MakeCountry("Israel", 972)
		MakeCountry("Italy", 39)
		MakeCountry("Ivory Coast", 225)
		MakeCountry("Jamaica", 1876)
		MakeCountry("Japan", 81)
		MakeCountry("Jordan", 962)
		MakeCountry("Kazakhstan", 7)
		MakeCountry("Kenya", 254)
		MakeCountry("Kiribati", 686)
		MakeCountry("Kosovo", 381)
		MakeCountry("Kuwait", 965)
		MakeCountry("Kyrgyzstan", 996)
		MakeCountry("Laos", 856)
		MakeCountry("Latvia", 371)
		MakeCountry("Lebanon", 961)
		MakeCountry("Lesotho", 266)
		MakeCountry("Liberia", 231)
		MakeCountry("Libya", 218)
		MakeCountry("Liechtenstein", 423)
		MakeCountry("Lithuania", 370)
		MakeCountry("Luxembourg", 352)
		MakeCountry("Macau", 853)
		MakeCountry("Macedonia", 389)
		MakeCountry("Madagascar", 261)
		MakeCountry("Malawi", 265)
		MakeCountry("Malaysia", 60)
		MakeCountry("Maldives", 960)
		MakeCountry("Mali", 223)
		MakeCountry("Malta", 356)
		MakeCountry("Marshall Islands", 692)
		MakeCountry("Mauritania", 222)
		MakeCountry("Mauritius", 230)
		MakeCountry("Mayotte", 262)
		MakeCountry("Mexico", 52)
		MakeCountry("Micronesia", 691)
		MakeCountry("Moldova", 373)
		MakeCountry("Monaco", 377)
		MakeCountry("Mongolia", 976)
		MakeCountry("Montenegro", 382)
		MakeCountry("Montserrat", 1664)
		MakeCountry("Morocco", 212)
		MakeCountry("Mozambique", 258)
		MakeCountry("Namibia", 264)
		MakeCountry("Nauru", 674)
		MakeCountry("Nepal", 977)
		MakeCountry("Netherlands", 31)
		MakeCountry("Netherlands Antilles", 599)
		MakeCountry("New Caledonia", 687)
		MakeCountry("New Zealand", 64)
		MakeCountry("Nicaragua", 505)
		MakeCountry("Niger", 227)
		MakeCountry("Nigeria", 234)
		MakeCountry("Niue", 683)
		MakeCountry("Norfolk Island", 672)
		MakeCountry("Northern Mariana Islands", 1670)
		MakeCountry("North Korea", 850)
		MakeCountry("Norway", 47)
		MakeCountry("Oman", 968)
		MakeCountry("Pakistan", 92)
		MakeCountry("Palau", 680)
		MakeCountry("Panama", 507)
		MakeCountry("Papua New Guinea", 675)
		MakeCountry("Paraguay", 595)
		MakeCountry("Peru", 51)
		MakeCountry("Philippines", 63)
		MakeCountry("Pitcairn Islands", 870)
		MakeCountry("Poland", 48)
		MakeCountry("Portugal", 351)
		MakeCountry("Qatar", 974)
		MakeCountry("Romania", 40)
		MakeCountry("Russia", 7)
		MakeCountry("Rwanda", 250)
		MakeCountry("Saint Barthelemy", 590)
		MakeCountry("Samoa", 685)
		MakeCountry("San Marino", 378)
		MakeCountry("Sao Tome/Principe", 239)
		MakeCountry("Saudi Arabia", 966)
		MakeCountry("Senegal", 221)
		MakeCountry("Serbia", 381)
		MakeCountry("Seychelles", 248)
		MakeCountry("Sierra Leone", 232)
		MakeCountry("Singapore", 65)
		MakeCountry("Slovakia", 421)
		MakeCountry("Slovenia", 386)
		MakeCountry("Solomon Islands", 677)
		MakeCountry("Somalia", 252)
		MakeCountry("South Africa", 27)
		MakeCountry("South Korea", 82)
		MakeCountry("Spain", 34)
		MakeCountry("Sri Lanka", 94)
		MakeCountry("Saint Helena", 290)
		MakeCountry("Saint Kitts/Nevis", 1869)
		MakeCountry("Saint Lucia", 1758)
		MakeCountry("Saint Martin", 1599)
		MakeCountry("Saint Pierre/Miquelon", 508)
		MakeCountry("Saint Vincent/Grenadines", 1784)
		MakeCountry("Sudan", 249)
		MakeCountry("Suriname", 597)
		MakeCountry("Swaziland", 268)
		MakeCountry("Sweden", 46)
		MakeCountry("Switzerland", 41)
		MakeCountry("Syria", 963)
		MakeCountry("Taiwan", 886)
		MakeCountry("Tajikistan", 992)
		MakeCountry("Tanzania", 255)
		MakeCountry("Thailand", 66)
		MakeCountry("Togo", 228)
		MakeCountry("Tokelau", 690)
		MakeCountry("Tonga", 676)
		MakeCountry("Trinidad/Tobago", 1868)
		MakeCountry("Tunisia", 216)
		MakeCountry("Turkey", 90)
		MakeCountry("Turkmenistan", 993)
		MakeCountry("Turks/Caicos Islands", 1649)
		MakeCountry("Tuvalu", 688)
		MakeCountry("United Arab Emirates", 971)
		MakeCountry("Uganda", 256)
		MakeCountry("United Kingdom", 44)
		MakeCountry("Ukraine", 380)
		MakeCountry("Uruguay", 598)
		MakeCountry("Uzbekistan", 998)
		MakeCountry("Vanuatu", 678)
		MakeCountry("Vatican City", 39)
		MakeCountry("Venezuela", 58)
		MakeCountry("Vietnam", 84)
		MakeCountry("US Virgin Islands", 1340)
		MakeCountry("Wallis and Futuna", 681)
		MakeCountry("West Bank", 970)
		MakeCountry("Yemen", 967)
		MakeCountry("Zambia", 260)
		MakeCountry("Zimbabwe", 263)
		MakeCountry("North America", 1)
	End If
End Sub
Sub MakeCountry(Name As String, Code As Int)
	Dim Temp As Country 
	Temp.Initialize 
	Temp.Name=Name
	Temp.Code=Code
	Countries.Add(Temp)
End Sub
Sub GetCountry(PhoneNumber As String) As Int 
	Dim Temp As Int ,tempcountry As Country,tempstr As String 
	Log("Get country: " & PhoneNumber)
	If Left(PhoneNumber,1)="+" Then
		SetupCountries
		PhoneNumber = Right(PhoneNumber, PhoneNumber.Length-1)
		For Temp = 0 To Countries.Size-1
			tempcountry= Countries.Get(Temp)
			tempstr=tempcountry.Code
			If PhoneNumber.Length>=tempstr.Length Then
				If Left(PhoneNumber, tempstr.Length) = tempstr Then Return Temp
			End If
		Next
	End If
	Return -1
End Sub
Sub CountryList(ListID As Int)As Boolean 
	Dim Temp As Int ,tempcountry As Country
	LCAR.LCAR_ClearList(ListID,0)
	LCAR.LCAR_AddListItem(ListID, GetString("disabled"), -1, -1, "-1", False, "", 0,False,-1)
	LCAR.LCAR_AddListItem(ListID, GetString("northamerica"), -1, -1, "1", False, "", 0,False,-1)
	For Temp = 0 To Countries.Size-2
		tempcountry= Countries.Get(Temp)
		LCAR.LCAR_AddListItem(ListID, tempcountry.Name.ToUpperCase, -1, -1, tempcountry.Code, False, "", 0,False,-1)
	Next
	Return True
End Sub
Sub CountryName(Code As Int) As String 
	Dim Temp As Int, tempCountry As Country 
	Temp = GetCountry("+" & Code)
	If Temp = -1 Or Temp>= Countries.size Then 
		Return GetString("disabled")
	Else
		tempCountry= Countries.Get(Temp)
		Return tempCountry.Name.ToUpperCase 
	End If
End Sub









Sub LoadPicture(Dir As String, Filename As String) As Bitmap 
	Dim BMP As Bitmap 
	If Dir.Length=0 Then Dir = File.DirAssets 
	BMP.Initialize(Dir, Filename)
	Return BMP
End Sub

Sub RemoveAllExceptNumbers(Text As String) As String
	Return RemoveAllNumbers(Text, True)
End Sub
Sub RemoveAllNumbers(Text As String, IsANumber As Boolean) As String
	Dim tempstr As StringBuilder ,Temp As Int ,Chars As String
	tempstr.Initialize 
	For Temp = 0 To Text.Length-1 
		Chars=Mid(Text,Temp,1)
		If IsANumber = IsNumber(Chars) Then tempstr.Append(Chars)
	Next
	Return tempstr.ToString 
End Sub

Sub GetPackageName As String
    Dim R As Reflector
    Return R.GetStaticField("anywheresoftware.b4a.BA", "packageName")
End Sub

Sub GetPackageDirDefaultExternal(PackageName As String) As String 
	Return File.DirDefaultExternal.Replace(GetPackageName, PackageName)
End Sub







Sub PasswordText(Text As String, Character As String, MaxLen As Int) As String 
	Dim Temp As Int , tempstr As StringBuilder ,Length As Int 
	tempstr.Initialize 
	If MaxLen>0 And MaxLen< Text.Length Then Length = MaxLen Else Length = Text.Length 
	For Temp = 1 To Length
		tempstr.Append(Character)
	Next
	Return tempstr.ToString 
End Sub

Sub ListSize(tList As List) As Int
	If tList.IsInitialized Then Return tList.Size
	Return 0
End Sub 

Sub IsRIM As Boolean 
	Dim P As Phone 
	Return P.Manufacturer.EqualsIgnoreCase("BlackBerry") Or P.Product.EqualsIgnoreCase("BlackBerry") Or P.Model.EqualsIgnoreCase("BlackBerry") Or P.Manufacturer = "RIM" Or P.Manufacturer.ToLowerCase.Contains("research in motion")
End Sub


Sub IsPackageInstalled(PackageName As String) As Boolean 
	Dim PM As PackageManager , temp As Int =-1
 	Try
 		temp = PM.GetVersionCode(PackageName)
	Catch
		temp=-1
	End Try
	Return temp>-1
End Sub


Sub DeviceID As String 
	Dim P As Phone 
	Return P.GetSettings("android_id").ToLowerCase 
End Sub
Sub IsStolen As Boolean 
 	If IsPackageInstalled("com.baidu.appsearch") Then'OR IsPackageInstalled("cm.aptoide.pt") Then
		Select Case DeviceID
			Case "3a81ca1daccc141d", "1dac0726e9915e2b", "361d1b67f7c043d0"
			Case Else: Return True
		End Select
	End If
End Sub

Sub MyPackage() As String 
	Return "com.omnicorp.lcarui.test"
End Sub

Sub Model(ID As Int) As String 
	Dim P As Phone , PM As PackageManager 
	If ID=-1 Then'sll
		Dim tempstr As StringBuilder,Temp As Int 
		tempstr.Initialize 
		For Temp = 0 To 11
			tempstr.Append(Model(Temp) & CRLF)
		Next
		Return tempstr.ToString 
	Else If ID<3 Then
		If ID=1 Then 
			If P.Manufacturer.EqualsIgnoreCase("samsung") Then
				If P.Model.StartsWith("GT-") Then Return GetString("galaxy_class")
			Else If P.Model.StartsWith("Nexus 5") Then 
				Return GetString("sovereign_class")
			End If
		End If 
		
		Select Case ID
			Case 0: Return P.Manufacturer 
			Case 1: Return P.Model
			Case 2: Return P.Product 
		End Select
	Else
		Try
			Select Case ID
				Case 3: Return APIlevel
				Case 4: Return GetDevicePhysicalSize
				Case 5:	Return PM.GetVersionCode(MyPackage)
				Case 6: Return PM.GetVersionName(MyPackage)
				Case 7:	Return PM.GetVersionCode("com.omnicorp.lcarui.dialer")
				Case 8:	Return PM.GetVersionName("com.omnicorp.lcarui.dialer")
				Case 9: Return Main.StarshipID 
				Case 10: Return Main.Starshipname 
				Case 11: Return Main.YourName
				Case 12: Return Main.StarshipID & "'" & Main.Starshipname & "' '" & Main.YourName & "'"
			End Select
		Catch
			Select Case ID
				Case 7:	Return "-1"
				Case 8: Return GetString("not_installed")
				Case Else: Return ""
			End Select
		End Try
	End If
End Sub
Sub SetRingtone(RingType As Int, Uri As String) As Boolean 
	Dim RING As RingtoneManager 
	If Uri.Length>0 Then
		Select Case RingType 
			Case DIRECTORY_ALARMS:			RingType = RING.TYPE_ALARM 
			Case DIRECTORY_RINGTONES:		RingType = RING.TYPE_RINGTONE 
			Case DIRECTORY_NOTIFICATIONS:	RingType = RING.TYPE_NOTIFICATION 
			Case Else: Return False
		End Select
		Try
			RING.SetDefault(RingType, Uri) 
			Return True
		Catch
			Return False
		End Try
	End If
End Sub
Sub SetScreenBrightness(Value As Float)
	Dim tempP As Phone 
	Log("Set brightness to " & Value)
	CurrBrightness =Value
	tempP.SetScreenBrightness(Value)
End Sub
Sub ResetBrightness
	'Log("Reset brightness")
	If CurrBrightness <> -1 Then SetScreenBrightness(-1)
End Sub
Sub GetSystemDir(Dir As Int) As String 
	Dim tempstr As String 
	Select Case Dir
		Case DIRECTORY_PICTURES:		tempstr= "DIRECTORY_PICTURES"
		Case DIRECTORY_MUSIC:			tempstr= "DIRECTORY_MUSIC"
		Case DIRECTORY_RINGTONES:		tempstr= "DIRECTORY_RINGTONES"
		Case DIRECTORY_ALARMS:			tempstr= "DIRECTORY_ALARMS"
		Case DIRECTORY_DCIM:			tempstr= "DIRECTORY_DCIM"
		Case DIRECTORY_DOWNLOADS:		tempstr= "DIRECTORY_DOWNLOADS"
		Case DIRECTORY_MOVIES:			tempstr= "DIRECTORY_MOVIES"
		Case DIRECTORY_NOTIFICATIONS:	tempstr= "DIRECTORY_NOTIFICATIONS"
		Case DIRECTORY_PODCASTS:		tempstr= "DIRECTORY_PODCASTS"
		Case Else: 						Return ""
	End Select 
	tempstr = GetString(tempstr)
	If File.exists(File.Combine(File.DirRootExternal, "media"), tempstr.ToLowerCase) Then
		Return File.Combine(File.Combine(File.DirRootExternal, "media"), tempstr.ToLowerCase)
	Else If File.Exists(File.DirRootExternal, tempstr) Then
		Return File.Combine(File.DirRootExternal, tempstr)
	Else If File.Exists(File.DirRootExternal, tempstr.ToLowerCase) Then
		Return File.Combine(File.DirRootExternal, tempstr.ToLowerCase)
	End If
	Return ""
End Sub

Sub LoadMap(Dir As String, Filename As String) As Map 
	Dim Settings As Map' , temp As Int ,tempstr As String 
	If File.Exists(Dir, Filename) Then 
		Settings = File.ReadMap( Dir, Filename) 
	Else
		Settings.Initialize
	End If
	Return Settings
End Sub

Sub CopyFile(SrcDir As String, SrcFilename As String, DestDir As String, DestFilename As String, DuplicateIfSame As Boolean) As Boolean
	If File.Combine(SrcDir, SrcFilename).EqualsIgnoreCase( File.Combine(DestDir, DestFilename) ) Then 
		If Not(DuplicateIfSame) Then Return False 
		DestFilename = LCARSeffects.UniqueFilename(DestDir,DestFilename, " (#)")
	End If
	File.Copy(SrcDir, SrcFilename, DestDir, DestFilename)
	Return True 
End Sub
Sub RenameFile(SrcDir As String, SrcFilename As String, DestDir As String, DestFilename As String) As Boolean
    Dim R As Reflector, NewObj As Object, New As String , Old As String ', Ph As Phone, Q As String: Q=Chr(34)
	If SrcFilename=Null Or DestFilename=Null Or SrcDir=Null Or DestDir=Null Then Return False
	If File.Exists(SrcDir,SrcFilename) And Not(File.Exists(DestDir,DestFilename)) Then    
		'Return Ph.Shell("mv " & Q & File.Combine(SrcDir,SrcFilename) & Q &  " "  & Q &  File.Combine(DestDir,DestFilename)  & Q, Null, Null, Null) = 0
		New=File.Combine(DestDir,DestFilename)
		Old=File.Combine(SrcDir,SrcFilename)
		If Not(New = Old) Then
    		NewObj=R.CreateObject2("java.io.File",Array As Object(New),Array As String("java.lang.String"))
    		R.Target=R.CreateObject2("java.io.File",Array As Object(Old),Array As String("java.lang.String"))
    		Return R.RunMethod4("renameTo",Array As Object(NewObj),Array As String("java.io.File"))
		End If
	End If
	Return False
End Sub

Sub ShowCaret As Boolean 
	Return DateTime.Now Mod DateTime.TicksPerSecond < DateTime.TicksPerSecond * 0.5
End Sub

Sub LimitTextWidth(BG As Canvas, Text As String,  theTypeface As Typeface, TextSize As Int, Width As Int, AppendString As String) As String 
	Dim Temp As Int 
	If Text.Length>0 Then
		Temp = BG.MeasureStringWidth(Text, theTypeface,TextSize)
		If Temp> Width Then
			Do While Temp > Width And Text.Length>0
				Text= Left(Text, Text.Length-1)
				Temp = BG.MeasureStringWidth(Text & AppendString, theTypeface,TextSize)
			Loop
			Return Text & AppendString
		End If
	End If
	Return Text
End Sub

'Align: 0,1,4,7=left, 2,5,8=center, 3,6,9=right, negative values will go up instead of down on CRLF
Sub DrawText(BG As Canvas,Text As String , X As Int, Y As Int, theTypeface As Typeface, TextSize As Int, Color As Int, Align As Int)
	Dim Alignment As String,tempstr() As String,Temp As Int ,temp2 As Int, GoDown As Boolean = Align < 0 
	Select Case Abs(Align)
		Case 0,1,4,7:Alignment="LEFT"
		Case 2,5,8:Alignment="CENTER"
		Case 3,6,9:Alignment="RIGHT"
	End Select
	
	If Text.Contains(CRLF) Then
		tempstr=Regex.Split(CRLF, Text)
		For Temp = 0 To tempstr.Length-1
			temp2= BG.MeasureStringHeight(tempstr(Temp),theTypeface,TextSize)
			If GoDown Then 
				Y=Y-temp2
			Else 
				Y=Y+temp2
			End If
			BG.DrawText(tempstr(Temp), X,Y, theTypeface,TextSize, Color, Alignment)
		Next
	Else
		BG.DrawText(Text,X,Y+ BG.MeasureStringHeight(Text,theTypeface,TextSize),theTypeface,TextSize,Color, Alignment)
	End If
End Sub

'align must be below zero if there is no CRLF to vertically align. If stroke is below 0 it is treated as the line spacing
Sub DrawTextAligned(BG As Canvas, Text As String,  X As Int, Y As Int, Height As Int, theTypeface As Typeface, TextSize As Int, Color As Int, Align As Int, Stroke As Int, StrokeColor As Long) As Int 
	Dim Alignment As String,TextHeight As Int ,tempheight As Int ,tempstr() As String,Temp As Int , doaligntext As Boolean , LineSpacing As Int 
	If Text.contains("%n%") Then Text = Text.Replace("%n%", CRLF)
	tempheight=BG.MeasureStringHeight(Text,theTypeface,TextSize)
	TextHeight = tempheight
	If Align >=0 And Align<7 Then 
		TextHeight=TextHeight*0.5 
	Else If Align<0 Or Align>10 Then 
		Align=Abs(Align) Mod 10
		doaligntext =True
	End If
	If Stroke<0 Then 
		LineSpacing=Abs(Stroke)
		Stroke=0
	End If
	
	Select Case Align
		Case 0,1,4,7:Alignment="LEFT"
		Case 2,5,8:Alignment="CENTER"
		Case 3,6,9:Alignment="RIGHT"
	End Select
	If Text.Contains(CRLF) Then
		tempstr=Regex.Split(CRLF, Text)
		Select Case Align
			'Case 0,1,2,3	'middle
			Case 4,5,6:Y=Y+Height/2 - (tempheight*tempstr.Length)/2
			Case 7,8,9:Y=Y+Height - (tempheight*tempstr.Length)
		End Select
		For Temp = 0 To tempstr.Length-1
			tempheight = Max(tempheight, BG.MeasureStringHeight(tempstr(Temp),theTypeface,TextSize)+LineSpacing)
		Next
		For Temp = 0 To tempstr.Length-1
			If Stroke>0 Then 
				DrawText(BG, tempstr(Temp), X-Stroke,Y-Stroke, theTypeface,TextSize, StrokeColor, Align) 
				DrawText(BG, tempstr(Temp), X+Stroke,Y+Stroke, theTypeface,TextSize, StrokeColor, Align) 
			End If
			DrawText(BG, tempstr(Temp), X,Y, theTypeface,TextSize, Color, Align) 
			Y=Y+tempheight+1
		Next
	Else
		If doaligntext Then
			Select Case Align
				'Case 0,1,2,3	'top
				Case 4,5,6:Y=Y+Height/2 - TextHeight/2'middle
				Case 7,8,9:Y=Y+Height - TextHeight'bottom
			End Select
		End If
		If Stroke>0 Then 
			BG.DrawText(Text,X-Stroke,Y+TextHeight-Stroke,theTypeface,TextSize,StrokeColor, Alignment)
			BG.DrawText(Text,X+Stroke,Y+TextHeight+Stroke,theTypeface,TextSize,StrokeColor, Alignment)
		End If
		BG.DrawText(Text,X,Y+TextHeight,theTypeface,TextSize,Color, Alignment)
	End If
	Return tempheight
End Sub

Sub Plural(Value As Int, Singular As String, Pluralized As String) As String 
	If Value=1 Then Return Singular Else Return Pluralized
End Sub

Sub Move(OBJ As View, ACT As Activity, X As Int, Y As Int, Width As Int, Height As Int)
	Try
		If Not(OBJ = Null) And Not(ACT = Null) And OBJ.IsInitialized And ACT.IsInitialized Then
			If X<0 Then
				OBJ.Left = ACT.Width-X
			Else
				OBJ.Left=X
			End If
			If Y<0 Then
				OBJ.top = ACT.Width-Y
			Else
				OBJ.top=Y
			End If
			If Width<1 Then
				OBJ.Width = ACT.Width-OBJ.Left +Width
			Else
				OBJ.Width=Width
			End If
			If Width<1 Then
				OBJ.Height = ACT.Height-OBJ.top +Height
			Else
				OBJ.Height=Height
			End If
		End If
	Catch
	End Try
End Sub

Sub GetTextLimitedHeight(BG As Canvas,DesiredHeight As Int, DesiredWidth As Int, Text As String, theTypeface As Typeface ) As Int
	Return Min(GetTextHeight(BG,DesiredHeight,Text,theTypeface), GetTextHeight(BG,-DesiredWidth,Text,theTypeface))
End Sub
'A negative DesiredHeight will act as the desired width instead
Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String, theTypeface As Typeface ) As Int 
	Dim Temp As Int,CurrentHeight As Int 
	If theTypeface.IsInitialized And Text.Trim.Length>0 Then
		Do Until Temp >=  Abs(DesiredHeight)
			CurrentHeight=CurrentHeight+1
			If DesiredHeight>0 Then
				Temp = BG.MeasureStringHeight(Text, theTypeface, CurrentHeight)
			Else
				Temp = BG.MeasureStringWidth(Text, theTypeface, CurrentHeight)
			End If
		Loop
		If Temp>=Abs(DesiredHeight) Then CurrentHeight=CurrentHeight-1
	End If
	Return CurrentHeight
End Sub

Sub GetDevicePhysicalSize As Float
    Dim lv As LayoutValues = GetDeviceLayoutValues
    Return Sqrt(Power(lv.Height / lv.Scale / 160, 2) + Power(lv.Width / lv.Scale / 160, 2))
End Sub

Sub GetDeviceDPI As Int 
	Dim lv As LayoutValues = GetDeviceLayoutValues
	Return lv.Scale * 160
End Sub

Sub GetUniqueKey(Mac As Boolean ) As String 
	If Mac Then
		Dim myWifi As ABWifi
		myWifi.ABLoadWifi
		Return myWifi.ABGetCurrentWifiInfo().MacAddress
	Else
	    Dim R As Reflector
	    R.Target = R.RunStaticMethod("java.util.UUID", "randomUUID", Null, Null)
	    Return R.RunMethod("toString")
	End If
End Sub

Sub PadtoLength(Text As String, LeftSide As Boolean , Length As Int, PadChar As String ) As String 
	Dim Temp As Int,tempstr As StringBuilder 
	If PadChar.Length=0 Or PadChar.Length>1 Then PadChar = " "
	If Text.Length<Length Then
		tempstr.Initialize 
		For Temp = Text.Length+1 To Length
			tempstr.Append(PadChar)
		Next
		If LeftSide Then Return tempstr.ToString & Text
		Return Text & tempstr.ToString 
	End If
	Return Text
End Sub

Sub IsBetween(Lower As Int, Higher As Int, Value As Int) As Boolean 
	Return Value >=Lower And Value<=Higher
End Sub
Sub IsEven(Value As Int) As Boolean 
	Return (Value Mod 2)=0 
End Sub

Sub ForceMain
	StartActivity(Main)
End Sub
Sub IsScreenLocked As Boolean
	Dim R As Reflector
	R.Target = R.GetContext
	R.Target = R.RunMethod2("getSystemService", "keyguard", "java.lang.String")
	Return R.RunMethod("inKeyguardRestrictedInputMode")
End Sub
Sub IsScreenOn As Boolean
    Dim R As Reflector
    R.Target = R.GetContext
    R.Target = R.RunMethod2("getSystemService", "power", "java.lang.String")
    Return R.RunMethod("isScreenOn")
End Sub
Sub IsMyDevice(Mark As Boolean ) As Boolean 
	Dim NeoTechni As String:NeoTechni = "NeoTechni.txt"
	If Mark Then File.WriteString(File.DirRootExternal, NeoTechni, NeoTechni)
	Return File.Exists(File.DirRootExternal , NeoTechni)
End Sub

Sub IsInIDE As Boolean 
	If Not(HasChecked) Then 
		Dim R As Reflector
		debugMode = debugMode Or R.GetStaticField("anywheresoftware.b4a.BA", "debugMode")
		HasChecked =True
	End If
	Return debugMode
End Sub 

Sub CreateLocation (Location1 As Location, Distance As Double, Bearing As Double) As Location
    Dim lat, lon, dlon As Double
    Dim lat1, lon1, tc, D As Double
    tc = -Bearing / 180 * cPI
    lat1 = Location1.Latitude / 180 * cPI
    lon1 = Location1.Longitude / 180 * cPI
    D = Distance  / 1852 * cPI / (180 * 60)
    
    lat =ASin(Sin(lat1)*Cos(D)+Cos(lat1)*Sin(D)*Cos(tc))
    dlon=ATan2(Sin(tc)*Sin(D)*Cos(lat1),Cos(D)-Sin(lat1)*Sin(lat))
    lon = (lon1-dlon +cPI) - 2*cPI * Floor(((lon1-dlon +cPI)) / (2 * cPI)) - cPI
    Dim L As Location
    L.Initialize2(lat * 180 / cPI, lon * 180 / cPI)
	
	'Log("src: " & Location1.Latitude & ", " & Location1.Longitude)
	'Log("dest: " & L.Latitude & ", " & L.Longitude)
	
    Return L
End Sub

Sub Limit(Value As Int, Lower As Int, Upper As Int) As Int
	Return Max(Min(Upper,Value), Lower)
End Sub

Sub ReverseIIFindex(Key As String, KeyValuePairs As List, Default As String) As String 
	Dim temp As Int 
	For temp = 0 To KeyValuePairs.Size-1 Step 2
		If Key.EqualsIgnoreCase( KeyValuePairs.Get(temp) ) Then Return KeyValuePairs.get(temp + 1)
	Next
	Return Default
End Sub

Sub IIFIndex(Index As Int, Values As List) As String 
	If Index<Values.Size And Index>-1 Then Return Values.Get(Index)
End Sub

Sub FindIndex(Values As List, Key As String) As Int
	Return Values.IndexOf(Key)
End Sub

Sub IIF(Value As Boolean , IFtrue, IfFalse)
	If Value Then Return IFtrue 
	Return IfFalse
End Sub
Sub IIFt(Value As Boolean, IfTrue)
	If Value Then Return IfTrue 
End Sub
Sub RNDBOOL As Boolean 
	Return Rnd(0,2) = 0
End Sub

Sub ParseCommand(Text As String) As List
	Dim Temp As List ,tempstr As String ,temp2 As Int 
	Temp.Initialize 
	Do Until Text.Length =0
		temp2=GrabWord(Text)
		'Log("WORD: " & temp & " " & temp2)
		tempstr= Left(Text,temp2)
		Select Case Left(tempstr,1)
			Case "'",Chr(34),Chr(39)
				Temp.Add(Mid(tempstr, 1, tempstr.Length-2))
			Case Else
				Temp.Add(tempstr)
		End Select
		
		Text=Right(Text, Text.Length-temp2).Trim 
	Loop
	Log("Words: " & Temp)
	Return Temp
End Sub

Sub GrabAWord(Text As String) As String 
	Dim Temp As Int 
	Temp=GrabWord(Text)
	Return Left(Text,Temp)
End Sub

Sub GrabWord(Text As String) As Int
	Dim Char1 As String,Temp As Int   
	Char1= Left(Text,1)
	Select Case Char1
		Case " ": Return 0
		Case "'",Chr(34),Chr(39)
			Temp = Instr(Text, Char1, 1)
			If Temp=-1 Then
				Return Text.Length
			Else
				Return Temp+1
			End If
		Case Else
			Temp = Instr(Text, " ", 1)
			If Temp=-1 Then 
				Return Text.Length
			Else 
				Return Temp
			End If
	End Select
End Sub

Sub ParseIP(IP As String ) As IPaddress 
	Dim octets() As String ,Temp As IPaddress ,tempstr2() As String ,temp2 As Int 
	octets= Regex.Split("\.", IP)
	Temp.Initialize 
	If octets.Length >= 4 Then 
		For temp2 = 0 To 2 
			If octets(temp2).Length = 0 Or Not(IsNumber(octets(temp2))) Then octets(temp2) = 0
			Temp.octets(temp2)= Max(0, Min(255, octets(temp2)))
		Next
		If octets(3).Contains(":") Then
			tempstr2=Regex.Split(":", octets(3))
			If IsNumber(tempstr2(0)) And IsNumber(tempstr2(1)) Then
				Temp.octets(3)=Max(0, Min(255, tempstr2(0)))'tempstr2(0)
				Temp.Port = Max(0,tempstr2(1).Trim )
			End If
		Else
			If IsNumber(Temp.octets(3)) Then Temp.octets(3)= Max(0, Min(255, octets(3)))' temp.octets(3)=octets(3)
		End If
	End If
	Return Temp
End Sub
Sub GetIP(IP As IPaddress, IncludePort As Boolean) As String
	Dim tempstr As String 
	tempstr = IP.Octets(0) & "." & IP.Octets(1) & "." & IP.Octets(2) & "." & IP.Octets(3) 
	If IncludePort Then tempstr= tempstr & ":" & IP.Port 
	Return tempstr
End Sub
Sub GetOctet(IP As IPaddress) As String 
	If IP.SelectedOctet=4 Then
		Return IP.Port 
	Else 
		Return IP.Octets(IP.SelectedOctet)
	End If
End Sub
Sub SetOctet(IP As IPaddress, Octet As Int, Value As Int) As IPaddress 
	If Octet=4 Then
		IP.Port=Value
	Else
		If Value<0 Or Value>255 Then Value=0
		IP.Octets(Octet)=Value
	End If
	Return IP
End Sub

Sub DownloadURL(URL As String) As Boolean 
	'?useskin=wikiamobile  en.memory-alpha.org
	Dim Temp As Int , URLl As String
	LCAR.forceshow(18,True)
	LCAR.LCAR_SetElementText( 18, GetString("loading"), "")
	aHREF=""
	Temp = URL.IndexOf("#")
	If Temp>0 Then
		If URL.Contains("?") Then
			aHREF= "#" & GetBetween(URL, "#", "?") & "?"
			URL=URL.Replace(aHREF, "")
		Else
			aHREF=Right(URL, URL.Length-Temp)
			URL = Left(URL, Temp)
		End If
	End If
	If Not (URL.ToLowerCase.StartsWith("http://")) Then URL = "http://" & URL
	URLl= URL.ToLowerCase 
	
	If  URLl.StartsWith("http://memory-alpha.org/") Or  URLl.StartsWith("http://en.memory-alpha.org/") Or URLl.StartsWith("http://memory-beta.wikia.com") Then' url = url & "?useskin=wikiamobile"
		If Not(URL.Contains("?")) Then URL=URL & "?" Else  URL=URL & "&"
		URL=URL & "useskin=wikiamobile"
	End If
	dURL=URL
	'Log("Downloading: " & URL)
	Return Download("WebPage", URL)
End Sub
Sub Searchfor(Content As String ) As String 
	Dim Temp As String 
	Select Case SearchProvider
		Case 0: Temp="http://en.memory-alpha.org/wiki/Special:Search?fulltext=Search&search=" & Content 'memory alpha
		'Case 0: Temp="http://en.memory-alpha.org/wiki/index.php?title=Special:Search&search=" & Content 'memory alpha (depreciated)
		Case 1: Temp = "http://en.m.wikipedia.org/w/index.php?title=Special:Search&search=" & Content 'wikipedia
		Case 2: Temp = "http://memory-beta.wikia.com/wiki/index.php?search=" & Content & "&fulltext=Search" 'memory beta
	End Select
	DownloadURL(Temp)
	Return Temp
End Sub

Sub GetBaseURL(URL As String) As String
	Dim Temp As Int
	Temp = URL.IndexOf2("/",8)
	If Temp=-1 Then
		Return URL
	Else
		Return Left(URL,Temp)
	End If
End Sub


Sub MakeHTMLColor(LCARcolorID As Int) As String 
	Dim Temp As LCARColor 
	Temp=LCAR.LCARcolors.Get(LCARcolorID)
	Return "#" & Hex(Temp.nR) & Hex(Temp.nG) & Hex(Temp.nB)
End Sub 

Sub Hex(Number As Int) As String 
	Dim Temp As Int
	Temp = Floor(Number / 16)
	Return ToHex(Temp) & ToHex(Number - Temp*16)
End Sub
Sub ToHex(Number As Int) As String 
	If Number < 10 Then 
		Return Number 
	Else
		Return Chr(Number-10+ Asc("A"))
	End If
End Sub

Sub MakeErrrorPage(URL As String, Error As String )As String 
	Dim tempstr As StringBuilder, strings As List = GetStrings("404_text", 0), temp As Int, tempstr2 As String 
	URL = "<A HREF='" & URL & "'>"
	If LCAR.CurrentStyle = LCAR.LCAR_ENT Then
		URL = URL.ToUpperCase & "</A>"
	Else
		URL = "<FONT COLOR=#FF0000>" & URL.ToUpperCase & "</FONT></A>"
	End If
	For temp = 0 To strings.Size -1 
		tempstr2 = strings.Get(temp)
		If tempstr2.Contains("[URL]") Then strings.Set(temp, tempstr2.Replace(URL, "[URL]"))
	Next
		
	tempstr.Initialize 
	tempstr.Append("<H1>" & strings.Get(0) & "</H1><P>")
	tempstr.Append(strings.Get(1) & "<p>")
	tempstr.Append("<B>" & strings.Get(2) & "</B><P><UL>")
	For temp = 3 To strings.Size -1 
		tempstr.Append("<LI>" & strings.Get(temp) & "</LI>")
	Next
	tempstr.Append("</UL><P>" & Error.ToUpperCase)
	
	'LCAR.PlaySound2("MISSINGDATA", False)
	LCAR.SystemEvent(3,43)
	If LCAR.CurrentStyle = LCAR.LCAR_ENT Then
		Return LCARSeffects2.PreCARSStyle("") & LCARSeffects2.PreCARSFrame("red",tempstr.ToString, "file:///android_asset/mission.png", GetString("404_title"), 100) & "</TABLE></BODY></HTML>"
	Else
		Return "<IMG SRC='file:///android_asset/data.png'><P>" & tempstr.ToString
	End If
End Sub









'Sub RunTests
'	TestMedia("M", "Artists\Cyanometry")
'End Sub
'Sub TestMedia(FileType As String, Directory As String)
'	Dim Files As List, temp As Int ,MF As MediaFile 
'	Files=ListMedia(FileType, Directory)
'	Log(Files.Size & " items")
'	For temp = 0 To Files.Size-1
'		If IsMediaFiles Then
'			MF=Files.Get(temp)
'			Log("SONG: " & MF.Filename)
'		Else
'			Log("DIR: " & Files.Get(temp))
'		End If
'	Next
'End Sub


Sub ListMedia(FileType As String, Directory As String)As List 
	IsMediaFiles=False
	Directory=Directory.Replace("/", "\")
	Log("ListMedia: " & FileType & " - " & Directory)
	If Directory.Contains("\") Then' album\[albumname]
		Return EnumMedia(FileType, GetSide(Directory,"\",True,False), True, False, GetSide(Directory,"\",False,False))
	Else If Directory.Length=0 Then
		If FileType="M" Then
			Return Array As String("Songs", "Albums", "Artists")
		Else
			Return EnumMedia(FileType, Null,True,False,"")
		End If
	Else 'enum albums
		Return EnumMedia(FileType, Directory, True,True, "")
	End If
End Sub

Sub InitMB
	If Not(MBisInitialized) Then
		MB.Initialize("MB")
		MBisInitialized=True
	End If
End Sub
'FileTypes: P=Photo, V=Video, M=Music) The allowed fields for sorting are:
'M: Null (If Null Is used, it will sort on the ID), "_data" (Location), "_display_name", "title", "album", "artist", "track", "year", "duration"
'P: Null (if Null is used, it will sort on the ID), "_data" (Location), "_display_name", "datetaken", "size"
'V: Null (if Null is used, it will sort on the ID), "_data" (Location), "_display_name", "datetaken", "_size"
Sub EnumMedia(FileType As String, SortBy As String, External As Boolean, RetFolders As Boolean, RetOnly As String)As List 
	Dim Files As Map,Columns As Int ,MF As MediaFile ,Temp As Int ,templist As List ,tempstr As String ,tempstr2 As String 
	InitMB
	FileType=Left(FileType ,1).ToUpperCase 
	SortBy=SortBy.Replace("/", "")
	Select Case SortBy.Trim.ToLowerCase
		Case "", "id", "index": SortBy=Null
		Case "albums", "artists": SortBy= Left(SortBy, SortBy.Length-1).ToLowerCase 
		Case "title": If Not(FileType.EqualsIgnoreCase("M")) Then SortBy= "_data"
		Case "location", "filename", "directory", "dir", "path", "data", "loc": SortBy= "_data"
		Case "size": If FileType="V" Then SortBy = "_size"
		Case "name", "displayname", "display_name","songs" 
			SortBy = "_display_name"
			RetFolders=False
		Case Else: SortBy=SortBy.ToLowerCase 
	End Select
	Select Case FileType
		Case "M"
			Files=MB.GetMediaAudioList(External, SortBy)
			Columns=9
		Case "V"
			Files=MB.GetMediaVideoList(External, SortBy)
			Columns=6
		Case "P"
			Files=MB.GetMediaImageList(External, SortBy)
			Columns=7
	End Select
	Select Case SortBy
		Case Null, "id": SortBy = "ID"
		Case "_data": SortBy = "Location"
		Case "_display_name": SortBy="DisplayName"
		Case "datetaken": SortBy="DateTaken"
		Case Else : SortBy=Left(SortBy,1).ToUpperCase & Right(SortBy, SortBy.Length-1)
	End Select
	templist.Initialize 
	'Log( (Files.Size / Columns) & " files found")
	For Temp= 0 To (Files.Size / Columns)-1
		If RetFolders Or RetOnly.Length>0 Then tempstr2 = Files.GetDefault(SortBy & Temp, "")
		If RetFolders Then'returns only unique sortby data (ie: all the albums)
			If Not(tempstr.EqualsIgnoreCase(tempstr2)) Then
				templist.Add(tempstr2)
				tempstr=tempstr2
			End If
		Else 
			MF = ReadMediaFile(FileType, Files, Temp)
			If RetOnly.Length>0 Then'returns only files with matching SortBy data (ie: songs in an album)
				If tempstr2.EqualsIgnoreCase(RetOnly) Then templist.Add(MF)
			Else'return all files
				templist.Add(MF)
			End If
		End If
	Next
	IsMediaFiles=Not(RetFolders)
	Return templist
End Sub
Sub GetFileData(FileType As String,Directory As String, Filename As String) As MediaFile 
	Dim Temp As Map 
	InitMB
	If IsNumber(Directory) And Filename.Length=0 Then
		Temp = MB.GetAudioFileInfoByID(True, Filename)
		If Not(Temp.ContainsKey("ID")) Then Temp = MB.GetAudioFileInfoByID(False,Filename)
	Else
		Select Case Left(FileType ,1).ToUpperCase 
			Case "M": Temp = MB.GetAudioFileInfo(Directory, Filename)
			Case "V": Temp = MB.GetExtVideoFileInfo(File.Combine(Directory,Filename))
			Case "P": Temp = MB.GetExtImageFileInfo(File.Combine(Directory,Filename))
		End Select
	End If
	Return ReadMediaFile(FileType, Temp, -1)
End Sub
Sub GetThumbnail(FileType As String, ID As Long, Mini As Boolean) As Bitmap 
	Dim files As List , MF As MediaFile ,Temp As Int,Dir As String  
	Select Case FileType
		Case "M"
			MF= GetFileData("M", ID, "")
			Dir=GetDir(MF.Filename)
			files = File.ListFiles(Dir)
			For Temp = 0 To files.Size-1
				If GetFileType(files.Get(Temp),False) = "P" Then
					MF = GetFileData("P", Dir, files.Get(Temp))
					Return MB.GetImgThumbnailByID(MF.ID, Mini)
				End If
			Next
		Case "P": Return MB.GetImgThumbnailByID(ID, Mini)
		Case "V": Return MB.GetVideoThumbnailByID(ID, Mini)
	End Select
End Sub
Sub ReadMediaFile(FileType As String, Files As Map, Index As Int) As MediaFile
	Dim Temp As MediaFile ,IndexS As String ,Unknown As String = "<Unknown>"
	Try
		If Index > -1 Then IndexS=Index
		If Files.ContainsKey("ID" & IndexS) Then
			Temp.Initialize 
			Temp.FileType=FileType.ToUpperCase 
			Temp.ID= Files.Get("ID" & IndexS)
			Temp.Filename = Files.Get("Location" & IndexS)
			Temp.DisplayName = Trim(Files.Get("DisplayName" & IndexS))
			Temp.Title = Temp.DisplayName
			Select Case Temp.FileType
				Case "M"'music
					'Title As String, Album As String, Artist As String, Track As Int, Year As Int, Filename As String, DisplayName As String, Size As Long, DateTaken As Long, Height As Int, Width As Int)
					Temp.Title = Trim(Files.Getdefault("Title" & IndexS, ""))
					Temp.Album = Trim(Files.Getdefault("Album" & IndexS, ""))
					Temp.Artist = Trim(Files.Getdefault("Artist" & IndexS, ""))
					If Temp.Title.Length=0 Then Temp.Title= Unknown
					If Temp.Album.Length=0 Then Temp.Album= Unknown
					If Temp.Artist.Length=0 Then Temp.Artist= Unknown
					Temp.Track = Trim(Files.Getdefault("Track" & IndexS, 0))
					Temp.Year = Files.Getdefault("Year" & IndexS, 0)
					Temp.size = Files.Getdefault("Duration" & IndexS,0)/1000'in MS
				Case "V"'video
					Temp.DateTaken = Trim(Files.Getdefault("DateTaken" & IndexS,0))
					Temp.Size=Files.Getdefault("Size" & IndexS,0)
					Log("Resolution: " & Files.Get("Resolution" & IndexS))
				Case "P"'photo
					Temp.DateTaken = Files.Get("DateTaken" & IndexS)
					Temp.Height=Files.Get("Height" & IndexS)
					Temp.Width=Files.Get("Width" & IndexS)
					Temp.Size=Files.Get("Size" & IndexS)
			End Select
		End If
	Catch
		Temp.Initialize
	End Try
	Return Temp
End Sub
Sub GetFileType(Filename As String, MIME As Boolean) As String 
	Dim MT As MimeType ,tempstr As String 
	tempstr= GetExtension(Filename)' MT.getFileExtensionFromUrl(Filename)
	'Log("ext: " & tempstr)
	If tempstr.Length>0 Then
		tempstr= MT.getMimeTypeFromExt(tempstr)
		'Log("typ: " & tempstr)
		If MIME Then
			Return tempstr
		Else
			Select Case tempstr.ToLowerCase 
				Case "image/*": Return "P"
				Case "audio/*": Return "M"
				Case "video/*": Return "V"
			End Select
		End If
	End If
	Return "*"
End Sub








Sub GetURLfilename(URL As String) As String 
	'https://sites.google.com/site/vkwidgetskins/apks/classes.dex?attredirects=0&d=1
	URL = Right(URL, URL.Length - URL.LastIndexOf("/") - 1)
	If URL.Contains("?") Then URL = Left(URL, URL.IndexOf("?"))
	Return URL
End Sub
Sub SaveFile(Input As InputStream, Dir As String, Filename As String)
	If Input.IsInitialized Then 
		Dim out As OutputStream
		If File.Exists(Dir,Filename) Then File.Delete(Dir,Filename)
		out = File.OpenOutput(Dir,Filename,False )
		File.Copy2(Input, out)
		out.Close
	End If 
	Log("File saved: " & Dir & "/" & Filename)
End Sub
Sub InstallAPK(Dir As String, Filename As String)
	Dim I As Intent
	I.Initialize(I.ACTION_VIEW, "file:///" & File.Combine(Dir,Filename))
	I.SetType("application/vnd.android.package-archive")
	StartActivity(I)
End Sub

Sub PostString(JobName As String, URL As String, Data As String) As Boolean 
	If IsConnected Then 
		CallSubDelayed3(STimer, "PostString", JobName, URL & "?" & Data)
		Return True 
	End If 
End Sub
Sub Download(JobName As String, URL As String) As Boolean 
	If IsConnected Then 
		Log(JobName & " Downloading: " & URL)
		CallSubDelayed3(STimer, "DownloadFile", JobName, URL)
		Return True 
	End If 
End Sub

Sub HandleFiles(ListID As Int, URL As String, HTML As String)'https://sites.google.com/site/vkwidgetskins/apks
	Dim Files As Map = EnumFiles(URL, HTML), temp As Int, FileCount As Int = Files.Get("Files"), PM As PackageManager
	Dim PackageName As String , VersionCode As String, NeedsUpdating As String, Name As String, URL As String , EXT As String 
	Dim sInstall = GetString("apk_install"), sUpdate As String = GetString("apk_update"), sUpToDate = GetString("apk_up2date"), sNotAnAPK As String = GetString("apk_notanapk")
	
	For temp = 1 To FileCount
		NeedsUpdating= sNotAnAPK
		Name= Trim(Files.Getdefault(temp & ".Name", ""))
		PackageName = Trim(Files.Getdefault(temp & ".pkg", ""))
		VersionCode = KillAllExceptNumbers(Files.Getdefault(temp & ".ver", ""))
		URL= Trim(Files.Getdefault(temp & ".URL", ""))
		EXT = GetExtension(Name)
		If EXT = "apk" Then
			If IsPackageInstalled(PackageName) Then 
				If IsNumber(VersionCode) Then 
					If PM.GetVersionCode(PackageName) < VersionCode Then NeedsUpdating = sUpdate Else NeedsUpdating = sUpToDate
				End If
			Else
				NeedsUpdating= sInstall
			End If 
			If (AutoUpdateAPKs And NeedsUpdating = sUpdate) Or (AutoInstallAPKs And NeedsUpdating = sInstall) Then Download("apk", URL)
		End If
		Name= Left(Name, Name.Length-EXT.Length-1).ToUpperCase 
		If ListID>-1 Then LCAR.LCAR_AddListItem(ListID, Name,  LCAR.LCAR_Random, -1,  URL, False, NeedsUpdating, 0,False,-1)
	Next
End Sub
Sub GetFileList(URL As String, Override As Boolean) As Boolean 
	Dim Now As String = DateTime.GetDayOfMonth(DateTime.Now) & "-" & DateTime.GetMonth(DateTime.Now) & "-" & DateTime.GetYear(DateTime.Now)
	If Override Or (LastChecked<>Now And IsPaused(Main)) Then 'only check once a day and if the activity is not open
		If IsOnWifi Then
			If URL.Length=0 Then URL = "http://sites.google.com/site/vkwidgetskins/apks"
			Download("filelist", URL)
			LastChecked = Now
			Return True
		End If
	End If
End Sub
Sub SetMargin(Target As Object, Value As Int)
	Dim refl As Reflector, args(4) As Object, types(4) As String
    refl.Target = Target
    args(0) = Value    ' left
    args(1) = Value    ' top
    args(2) = Value    ' right
    args(3) = Value    ' bottom
    types(0) = "java.lang.int"
    types(1) = "java.lang.int"
    types(2) = "java.lang.int"
    types(3) = "java.lang.int"
    refl.RunMethod4("setPadding", args, types)    
End Sub
Sub EnumFiles(URL As String, HTML As String) As Map 
	Dim Files As Map, Q As String =GPlus.vbQuote,Start As String , Finish As String, temp As Int,temp2 As Int ,TAG As String, tempstr() As String, tempstr2() As String 
	Files.Initialize
	Files.Put("MOTD", StripHTML(GetBetween(HTML.ToUpperCase, "[START]", "[END]").Trim))
	Start="<div id='filecabinet-body' class='filecabinet'>"
	Finish="</table>"
	temp=Instr(HTML, Start,0)
	HTML = GetBetween(HTML , Start.Replace("'",Q) ,Finish.Replace("'",Q) )
	If HTML.Length>0 Then
		Start="<tr id='JOT_FILECAB_container_wuid:gx:".Replace("'",Q)
		tempstr = Regex.Split(Start, HTML)
		Files.Put("Files", tempstr.Length-1)
		For temp = 1 To tempstr.Length-1
			tempstr2 = Regex.Split("<td class=", tempstr(temp))
			Files.Put(temp & ".Name", StripHTML("<" & tempstr2(3)).Replace("Download","").Trim)
			Files.Put(temp & ".URL", "http://sites.google.com" & GetBetween(tempstr2(3), "<a href=" & Q, Q & " dir="))
			Files.Put(temp & ".Size", KillAllExceptNumbers(GetGoogleValue(tempstr2(5))))
			Files.Put(temp & ".Version", KillAllExceptNumbers(GetGoogleValue(tempstr2(6))))
			Files.Put(temp & ".Time", KillAllExceptNumbers(GetGoogleValue(tempstr2(7))))
			TAG=StripHTML("<" & tempstr2(4)).Trim
			Files.Put(temp & ".Description", TAG)
			If TAG.Contains("|") Then
				tempstr2 = Regex.Split("\|", TAG)
				For temp2 = 0 To tempstr2.Length-1
					TAG= tempstr2(temp2)
					If tempstr2(temp2).Contains("=") Then
						Start=GetSide(TAG, "=", True, False).Trim.ToLowerCase 
						Finish =GetSide(TAG, "=", False, False).Trim 
						Files.Put(temp & "." & Start, Finish)
					End If
				Next
			End If
		Next
	End If
	Log(URL & " " & Files)
	Return Files
End Sub
Sub GetGoogleValue(Text As String) As String 
	Return GetBetween(Text, "data-val=" & GPlus.vbQuote,GPlus.vbQuote & ">").Trim 
End Sub

'MF: folder 90 'C:\FLASH\mnt\sdcard\media\music\iphone\F00\I am Canadian.mp3' 'I AM CANADIAN Anthem' 1
Sub OpenFile(Filename As String) As Boolean 
	Dim i As Intent, typ As String ,p As PhoneIntents, DIR As String, NAME As String 
	typ=GetFileType(Filename,True)
	
	Try
		DIR=GetDir(Filename)'File.Combine(File.DirRootExternal, GetDir(Filename))
		NAME=GetFile(Filename)
		Log("OPEN FILE: " & DIR)
		Log(NAME)
		If typ.StartsWith("audio") Then
			StartActivity(p.PlayAudio(DIR,NAME))
			If APIlevel<14 Then  NewTimer("Me", -1,2)
			Return True
		Else If typ.StartsWith("video") Then
			StartActivity(p.PlayVideo(DIR,NAME))
			Return True
		End If
	Catch
		Log(LastException.Message)
	End Try
	
	Filename = "file://" & Filename.Replace("\","/").Replace(" ", "%20")
	Log(Filename)
	i.Initialize(i.ACTION_VIEW, Filename)' "file:///sdcard/1.jpg")
	i.SetType(typ)
	Try
		StartActivity(i)
		If typ.StartsWith("audio") And APIlevel<14 Then NewTimer("Me", -1,2)
		Return True
	Catch
		Log(LastException.Message)
	End Try
End Sub

Sub GetDir(Filename As String) As String
	Return GetSide(Filename, "/", True,False)
End Sub
Sub GetFile(Filename As String) As String
	Return GetSide(Filename, "/", False,False)
End Sub
Sub GetTitle(Filename As String) As String 
	Return GetSide(GetFile(Filename), ".", True,False)
End Sub
Sub GetExtension(Filename As String) As String 
	Return GetSide(Filename, ".", False,False).ToLowerCase 
End Sub

Sub GetSide(Text As String, Delimeter As String, LeftSide As Boolean,DoRightSide As Boolean  ) As String 
	Dim Temp As Int
	If Text.Length > 0 Then 
		If Text.Contains(Delimeter) Then
			Temp=Text.LastIndexOf(Delimeter)
			If LeftSide Then
				Return Left(Text,Temp)
			Else
				Return Right(Text, Text.Length-Temp-1)
			End If
		Else If LeftSide Or DoRightSide Then 
			Return Text
		End If
	End If 
End Sub

Sub ScrollTo(Section As Int)As String 
	Dim filename As String 
	filename= FileLoaded'"file://" & LCAR.DirDefaultExternal & "/HTML/index.html" 
	'If section>-1 Then filename = filename & "#NID" & section
	If filename.Length=0  Then MakeHTML(GetString("web_default_title"))'Not( File.Exists(LCAR.DirDefaultExternal,  "HTML/index.html" ))
	Return filename
End Sub

Sub MakeHTML(Body As String) As String
	Dim FontName As String, FontFile As String, textColor As String, bgcolor As String  ,HTMLcode As StringBuilder  ,tempstr As String ',Dir As String
	'Body = Body.Replace(CRLF, "<BR>")
	
	'dir= File.DirInternalCache
	'Dir= LCAR.DirDefaultExternal 
	FontFile = "lcars.ttf"
	FontName= "LCARS"
	textColor= MakeHTMLColor(LCAR.LCAR_Orange)' "#800080"'LCAR_Orange
	bgcolor = "#000000"
	
	tempstr= "{display: block; width: 100%; COLOR: #000000; }" & CRLF'text-decoration: none; font-size: " & LCAR.Fontsize & "px;
	
	HTMLcode.Initialize 
	HTMLcode.Append( "<html><head><style Type='text/css'>" )
	HTMLcode.Append( CRLF & "@font-face { font-family: " & FontName & ";	src: url('file:///android_asset/" & FontFile & "')" & CRLF & "; }" )
	'htmlcode=htmlcode & CRLF & ".image{	border-style:outset; border-color: " & textColor & "; border-width:2px; }"
	HTMLcode.Append( CRLF & "a.lcars:link " & tempstr & "a.lcars:visited " & tempstr & "a.lcars:hover " & tempstr & "a.lcars:active " & tempstr )'
	HTMLcode.Append( CRLF & "hr { border-color: " & textColor & ";}")
	HTMLcode.Append( CRLF & "ul {padding-left: 20px;}")
	HTMLcode.Append( CRLF & "blockquote { margin: 4px 20px; }")
	
	tempstr = "{COLOR: " & MakeHTMLColor(LCAR.LCAR_Purple) & ";}" & CRLF ' text-decoration: none; font-size: " & LCAR.Fontsize & "px;
	HTMLcode.Append( CRLF & "a.norm:link " & tempstr & "a.norm:visited " & tempstr & "a.norm:hover " & tempstr & "a.norm:active " & tempstr )'
	tempstr = "{COLOR: " & MakeHTMLColor(LCAR.LCAR_Purple) & ";}" & CRLF ' text-decoration: none; font-size: " & LCAR.Fontsize & "px;
	
	tempstr = "{COLOR: " & MakeHTMLColor(LCAR.LCAR_Red) & ";}" & CRLF ' text-decoration: none; font-size: " & LCAR.Fontsize & "px;
	HTMLcode.Append( CRLF & "a.bad:link " & tempstr & "a.bad:visited " & tempstr & "a.bad:hover " & tempstr & "a.bad:active " & tempstr )'
	
	tempstr= "{COLOR: " & textColor & "; text-decoration: none; font-size: " & LCAR.Fontsize & "px;}" & CRLF
	HTMLcode.Append( CRLF & "a:link " & tempstr & "a:visited " & tempstr & "a:hover " & tempstr & "a:active " & tempstr )'
	
	HTMLcode.Append( "body {" & CRLF & "	background-color : " & bgcolor & ";" & CRLF & "	COLOR: " & textColor & ";" &  CRLF & "	font-family: " & FontName & ";" & CRLF & "	font-size: " & LCAR.Fontsize & "px;" & CRLF & "	text-align: justify;}")
	HTMLcode.Append( CRLF & "</style></head><meta name=viewport content='width=1200'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><body>")
	HTMLcode.Append(Body.Replace("[script]", "<SCRIPT>").Replace("[/script]", "</SCRIPT>") & "</BODY></HTML>" )
	
	HTMLcode.Append("<SCRIPT>document.onkeypress = function (e) { B4A.CallSub('Activity_KeyPress', false, e.keyCode); };</SCRIPT>")
	
	Return MakeHTMLFile(HTMLcode.ToString)
	'File.MakeDir(Dir,"HTML")
	'Dir= File.Combine(Dir, "HTML")
	'FileLoaded=LCARSeffects.UniqueFilename(Dir,  "index.html", "#")
	
	'File.WriteString(Dir, FileLoaded, HTMLcode.ToString) 
	'FileLoaded="file://" & File.Combine(Dir, FileLoaded) 'dir & "/HTML/index.html" 
	'Return FileLoaded
End Sub
Sub MakeHTMLFile(HTMLcode As String)As String 
	Dim Dir As String = LCAR.DirDefaultExternal 
	If File.ExternalWritable Then
		File.MakeDir(Dir,"HTML")
		Dir= File.Combine(Dir, "HTML")
		FileLoaded=LCARSeffects.UniqueFilename(Dir,  "index.html", "#")
		
		File.WriteString(Dir, FileLoaded, HTMLcode) 
		FileLoaded="file://" & File.Combine(Dir, FileLoaded) 'dir & "/HTML/index.html" 
	Else
		FileLoaded = ""
	End If
	Return FileLoaded
End Sub

Sub MakeTag(Dest As List, Level As Int, TagName As String, Node As String)As HTMLtag 
	Dim Temp As HTMLtag 
	Temp.Initialize
	Temp.Level=Level
	Temp.TagName=TagName
	Temp.Node=Node
	Return Temp
End Sub
Sub MakeValue(Key As String, Value As String) As HTMLvalue 
	Dim Temp As HTMLvalue 
	Temp.Initialize
	Temp.Key=Key
	Temp.Value = Value
	Return Temp
End Sub

'don't forget the HREF in HTMLcode, | in sidetext will be separated into different cells
Sub MakeLCARbutton(ColorID As Int, HTMLCode As String, LCARButtonMode As Boolean, SideText As String, DoUppercase As Boolean) As String
	Dim Color As String ,Extension As String ,tempstr() As String 
	Color=MakeHTMLColor(ColorID)
	If HTMLCode.ToUpperCase.StartsWith("<A ") Then HTMLCode = Right(HTMLCode, HTMLCode.Length-2)
	If HTMLCode.ToLowerCase.Contains("<img") Then
		Return "<A " &  HTMLCode.Replace("<img ", "<img border=2 ")
	Else If LCARButtonMode Then
		If DoUppercase And HTMLCode.Contains("<") And HTMLCode.Contains(">") Then
			Extension = GetBetween(HTMLCode, ">", "<")
			HTMLCode = HTMLCode.Replace(Extension, Extension.ToUpperCase)
		End If
		If LCAR.AntiAliasing Then Extension = ".png" Else Extension = ".gif"
		If SideText.Length>0 Then 
			If SideText.Contains("|") Then SideText = SideText.Replace("|", "</font></TD><TD WIDTH=4 BGCOLOR=BLACK></TD><TD BGCOLOR=" & Color & "><font color=black>")
			SideText = "<TD WIDTH=4 BGCOLOR=BLACK></TD><TD BGCOLOR=" & Color & "><font color=black>" & SideText & "</font></TD>"
		End If
		Return "<TABLE WIDTH=100% HEIGHT=" & (LCAR.ItemHeight+4) & " BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD HEIGHT=" & LCAR.ItemHeight & " WIDTH=" & LCAR.lcarcorner.Width & " BACKGROUND='file:///android_asset/" & LCAR.LoadedFilename & Extension & "' BGCOLOR=" & Color & "></TD><TD WIDTH=4 BGCOLOR=" & Color & "></TD><TD WIDTH=4 BGCOLOR=BLACK></TD><TD WIDTH=4 BGCOLOR=" & Color & "><TD BGCOLOR=" & Color & "><A CLASS='lcars' " & HTMLCode & "</TD>" & SideText & "</TR><TR><TD HEIGHT=4 COLSPAN=5 BGCOLOR=BLACK></TR></TABLE>"
	Else
		Return "<A CLASS='norm' " & HTMLCode
	End If
End Sub

Sub ParseTag(Tag As String) As List 
	Dim templist As List
	templist.Initialize 
	
	Return templist
End Sub

Sub GetBetween(Text As String, Start As String, Finish As String) As String 
	Dim Temp As Int,temp2 As Int
	Temp=Text.IndexOf(Start)
	If Temp>-1 Then
		temp2=Text.IndexOf2(Finish, Temp+ Start.Length  +1)
		Return Mid(Text, Temp+Start.Length,temp2-Temp-Start.Length)
	End If
End Sub

Sub CorrectImage(HTMLcode As String) As String
	If HTMLcode.Contains("src='data:image") Then
		HTMLcode = HTMLcode.Replace("src='data:image", "datasrc")
		HTMLcode = HTMLcode.Replace("data-src=", "src=")
	End If
	Return HTMLcode
End Sub
				
Sub MakeHelpButton(Text As String) As String
	Dim URL1 As String= "http://sites.google.com/site/neotechni/Home/lcars/changes/" , URL2 As String = ".png?attredirects=0", DeviceSpecific As String 
	If IsAmazonFireTV Then 
		DeviceSpecific = GetString("amazon_firetv") 
	else if IsOuya Then 
		DeviceSpecific = GetString("is_ouya")
	End If
	Return "<TABLE WIDTH=100% BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD HEIGHT=73 WIDTH=60 BACKGROUND='" & URL1 & "HELP" & URL2 & "' BGCOLOR=BLACK></TD><TD HEIGHT=73 VALIGN=TOP BGCOLOR=BLACK BACKGROUND='" & URL1 & "LINE" & URL2 & "'>" & Text.ToUpperCase & "</TD></TR></TABLE>" & DeviceSpecific
End Sub				

Sub ParseHTML(HTMLCode As String, URL As String)As String 
	Dim Temp As Int,temp2 As Int, htag As String , Name As String ,temp3 As String, Node As String,Q As String = Eval.vbQuote, StartLength As Int = 7  ', BaseHREF
	Dim IO As TextWriter ,tempstr As String,LCARButtonMode As Boolean ,FoundDisabler As Boolean, DoUppercase As Boolean    ', tempstr As StringBuilder
	Dim IsHTML As Boolean = HTMLCode.Contains("<") And HTMLCode.Contains(">")
	If Not(IsHTML) Then HTMLCode = HTMLCode.Replace(CRLF, "<BR>")
	IO.Initialize( File.OpenOutput(File.DirInternalCache, "temp.html", False) )
	LCARButtonMode=True
	
	'tempstr="THIS IS A TEST OF THE LCARS WEB SYSTEM"
	Title=""
	BaseHref=""
	
	'tempstr.Initialize 
	
	Temp=HTMLCode.IndexOf("[START]")
	If Temp>-1 Then
		Title=GetBetween(HTMLCode, "<title>", " - Techni's Controller and Peripheral Museum</title>").ToUpperCase '"ABOUT LCARS UI" '<title>ABOUT LCARS UI -
		temp2 = HTMLCode.IndexOf("[" & TransLanguage & "]")
		If temp2 > -1 Then 
			Temp = temp2
			StartLength = 2 + TransLanguage.Length
		End If 
		temp2=HTMLCode.IndexOf2("[END]", Temp)
		DoUppercase=True
		HTMLCode=Mid(HTMLCode, Temp+StartLength,temp2-Temp-StartLength)'.ToUpperCase'
		If HTMLCode.Contains("[HELP]") Then HTMLCode = HTMLCode.Replace("[HELP]", MakeHelpButton(GetString("web_help")))
	End If
	Temp=0
	
	Do Until Temp >= HTMLCode.Length Or Temp<0 'OR tempstr.Length > MaxStringBuilderLength
		tempstr=""
		'Log(temp & "/" & HTMLCode.Length)
		If Mid(HTMLCode, Temp,1) = "<" Then
			temp2=HTMLCode.IndexOf2(">", Temp+1)
			htag=Mid(HTMLCode, Temp,temp2-Temp+1)
			Temp=temp2+1
			
			'Log("HTML: " & htag)
			'Log("TAG: " & GetTagName(htag))
			
			Name=GetTagName(htag)
			Select Case Name.ToLowerCase 
				Case "a", "script", "title", "h1", "h2", "h3", "header","footer","style"
					'If Not( name.EqualsIgnoreCase("a") AND htag.Contains(" name=") ) Then
						temp3 = HTMLCode.IndexOf2("</" & Name, temp2)
						Node=Mid(HTMLCode, temp2+1,temp3-temp2-1).Replace("&quot;", "'").Trim 
						temp2=HTMLCode.IndexOf2(">", temp3+1)
						Temp=temp2+1
						'Log("NODE2:" & Node)
					'End If
			End Select
			
			Select Case Name.ToLowerCase.Replace("/", "")
				Case "base": BaseHref=htag
				Case "title": 	Title= Node
				Case "img"
					'removed broken images
					tempstr = CRLF & htag 
					'src="data:image
					
					tempstr=CorrectImage(tempstr)
					
				Case "h1", "h2", "h3", "h4"
					'tempstr= tempstr & htag & node & "</" & name & ">"
					tempstr = CRLF & htag & Node & "</" & Name & ">"
				Case "a"':		tempstr= tempstr & MakeLCARbutton(lcar.LCAR_Orange, node)
					'If htag.Contains("#") Then'basehref
						
					'End If
					If Node.Length>0 Then
						If Node.ToLowerCase.Contains("img") Then
							Node=CorrectImage(Node)
						Else	
							Node=Node.ToUpperCase 
						End If
						Node=MakeLCARbutton(LCAR.LCAR_Orange, htag & Node & "</A>",LCARButtonMode, "", DoUppercase)
					End If
					Node=Node.Replace(" href=" & Chr(34) & "#", " href=" & Chr(34) & ScrollTo(0) & "#")
					'tempstr= tempstr & node
					tempstr = CRLF & Node
					
				Case "meta", "link", "!--", "script", "style", "body", "span", "nav" , "input", "form", "ul", "li", "header","section","footer"  'ignore these tags
					
				Case "div"
					If Name.EqualsIgnoreCase("div") Then
						If htag = "<div class=" & Q & "title" & Q & ">" Then LCARButtonMode=False
						'"<div class=" & Q & "collapsible-menu table-of-contents" & Q & ">"
					End If
					
				Case Else
					Select Case Name.ToLowerCase
						Case "th":		htag="<TH>"
						Case "table":	
							If LCARButtonMode Then
								'Log(htag & CRLF & "<table class=" & Q & "infobox" & Q & " cellspacing=" & Q & "3" & Q & " style=" & Q & "border-spacing: 3px; width:22em;" & Q & ">" & Q)
								Select Case htag
									Case "<table class=" & Q & "wiki-sidebar" & Q & ">": FoundDisabler= True
									Case "<table id=" & Q & "toc" & Q & " class=" & Q & "toc" & Q & ">" : FoundDisabler= True
									Case "<table class=" & Q & "infobox" & Q & " cellspacing=" & Q & "3" & Q & " style=" & Q & "border-spacing: 3px; width:22em;" & Q & ">": FoundDisabler= True
									Case "<table class=" & Q & "infobox vevent" & Q & " cellspacing=" & Q & "3" & Q & " style=" & Q & "border-spacing: 3px; width:22em;" & Q & ">": FoundDisabler= True
									Case Else
										If htag.Contains("class=" & Q & "vertical-navbox" & Q) Then
											htag="<TABLE>"
											FoundDisabler= True
										End If
								End Select
							End If
						Case "/table": If FoundDisabler Then LCARButtonMode=False
					End Select
					'tempstr = tempstr & htag 
					tempstr = CRLF & htag
			End Select
			
		Else
			temp2=HTMLCode.IndexOf2("<", Temp+1)
			If temp2>-1 Then
				htag=Mid(HTMLCode, Temp,temp2-Temp).Trim
			Else
				temp2=HTMLCode.Length 
				htag=Right(HTMLCode, temp2-Temp).Trim 
			End If
			Temp=temp2
			Select Case htag
				Case CRLF, "" 
				Case Else 
					'Log("NODE: " & htag)
					If CountAlphaNumericCharacters(htag) >0 Then 'tempstr=tempstr & CRLF & htag.Replace("•", "-")
						'If Main.AprilFools Then
						'	tempstr = CRLF & ReorganizeText(htag.Replace("•", "-"))
						'Else
							tempstr = CRLF & htag.Replace("•", "-")
						'End If
					End If
			End Select
			If DoUppercase Then tempstr = tempstr.ToUpperCase 
		End If
		
		If tempstr.Length>0 Then IO.Write(tempstr)
	Loop
	IO.Close 
	
	If BaseHref.Length=0 Then
		BaseHref=Left(URL, URL.LastIndexOf("/")+1)
		Node="<BASE HREF='" & BaseHref & "'>"
	Else
		Msgbox("EMERGENCY","EMERGENCY")
	End If
	
	Return Node & File.ReadString(File.DirInternalCache, "temp.html" )' tempstr.ToString 
	'htmlcode.IndexOf2(
End Sub

Sub GetTag(HTML As String, Tag As String) As String 
	Return GetBetween(HTML, " " &  Tag  & "=" & GPlus.vbQuote, GPlus.vbQuote)
End Sub
Sub EnumAHREFs(HTMLCode As String)As List 
	Dim Temp As Int,temp2 As Int, htag As String  ,Name As String ,temp3 As String, Node As String
	Dim tempstr As String ,HREFS As List  ', tempstr As StringBuilder
	HREFS.Initialize 
	Do Until Temp >= HTMLCode.Length Or Temp<0 'OR tempstr.Length > MaxStringBuilderLength
		tempstr=""
		'Log(temp & "/" & HTMLCode.Length)
		If Mid(HTMLCode, Temp,1) = "<" Then
			temp2=HTMLCode.IndexOf2(">", Temp+1)
			htag=Mid(HTMLCode, Temp,temp2-Temp+1)
			Temp=temp2+1
			Name=GetTagName(htag)
			Select Case Name.ToLowerCase 
				Case "a"', "script", "title", "h1", "h2", "h3", "header","footer","style"
					'If Not( name.EqualsIgnoreCase("a") AND htag.Contains(" name=") ) Then
						temp3 = HTMLCode.IndexOf2("</" & Name, temp2)
						Node=Mid(HTMLCode, temp2+1,temp3-temp2-1).Replace("&quot;", "'").Trim 
						temp2=HTMLCode.IndexOf2(">", temp3+1)
						Temp=temp2+1
						'Log("NODE2:" & Node)
					'End If
			End Select
			
			Select Case Name.ToLowerCase.Replace("/", "")
				Case "a"':		tempstr= tempstr & MakeLCARbutton(lcar.LCAR_Orange, node)
					'Log("HTML: " & htag)
					'Log("TAG: " & GetTagName(htag))
					HREFS.Add( htag )
			End Select
			
		Else
			temp2=HTMLCode.IndexOf2("<", Temp+1)
			If temp2>-1 Then
				htag=Mid(HTMLCode, Temp,temp2-Temp).Trim
			Else
				temp2=HTMLCode.Length 
				htag=Right(HTMLCode, temp2-Temp).Trim 
			End If
			Temp=temp2
		End If
	Loop

	Return HREFS
	'htmlcode.IndexOf2(
End Sub


Sub ReorganizeText(Text As String) As String 
	Dim tempstr() As String , tempstr2 As StringBuilder , Temp As Int 
	tempstr = Regex.Split(" ", Text)
	tempstr2.Initialize 
	For Temp = 0 To tempstr.Length -1
		tempstr2.Append( ReorganizeWord( tempstr(Temp).ToUpperCase )  & " ")
	Next
	Return tempstr2.ToString 
End Sub
Sub ReorganizeWord(Text As String) As String 
	Dim Temp As Int , tempstr As String , Word As List ,temp2 As Int , LastChars As String , Length As Int 
	If Text.Length>4 And Not(IsNumber(Text)) Then
		LastChars= Right(Text,1) 
		Length=1
		Do While Asc(Left(LastChars,1)) < ascA And  Asc(Left(LastChars,1)) > ascZ
			Length=Length+1
			LastChars= Right(Text,Length)
		Loop
		Text=Left(Text, Text.Length-Length)
		
		'Msgbox(Text, LastChars)
		Word.Initialize 
		For Temp = 1 To Text.Length- 1
			'Log("Adding: " & Mid(Text, temp,1))
			Word.Add( Mid(Text, Temp,1) )
		Next
		
		
		tempstr= Left(Text,1)
		For Temp = 1 To Text.Length- 1
			temp2 = Rnd(0, Word.Size)
			tempstr = tempstr & Word.Get(temp2)
			Word.RemoveAt(temp2)
		Next
		Return tempstr & LastChars'Right(Text, 1)
	Else
		Return Text
	End If
End Sub 

Sub GetTagName(content As String) As String
    Dim Temp As Long, temp2 As Long
    Temp = Instr(content, " ",0)
    temp2 = Instr(content, ">",0)
    If Temp > 0 And Temp < temp2 Then temp2 = Temp
    Return Mid(content, 1, temp2 - 1)
End Sub

Sub CountAlphaNumericCharacters(Text As String)As Int
	Dim Temp As Int, Count As Int,Character As Int 
	For Temp = 0 To Text.Length-1
		Character=Asc(Mid(Text,Temp,1).ToLowerCase )
		If ( Character >= Asc("a") And Character <= Asc("z") ) Or ( Character >= Asc("0") And Character <= Asc("9")) Then Count=Count+1
	Next
	Return Count
End Sub



'returns -1 if not found
Sub Instr(Text As String, TextToFind As String, Start As Int) As Int
	Return Text.IndexOf2(TextToFind,Start)
End Sub
Sub InstrRev(Text As String, TextToFind As String) As Int
	Return Text.LastIndexOf(TextToFind)
End Sub
Sub Instr2(Text As String, Start As Int, TextsToFind As List) As Int 
	Dim Temp As Int, temp2 As Int, temp3 As Int
	temp2=Text.Length 
	For Temp = 0 To TextsToFind.Size -1
		temp3 = Instr(Text, TextsToFind.Get(Temp), Start)
		If temp3<temp2 And temp3>-1 Then temp2=temp3
	Next
	Return temp2
End Sub

Sub IsOnWifi As Boolean 
	Dim Wifi As ABWifi , Info As ABWifiInfo,State As Boolean  
	If IsConnected Then
		If Wifi.ABLoadWifi() = True Then
			'Return wifi.ABGetCurrentWifiInfo.IsConnected 
			Try
				State= Wifi.ABGetCurrentWifiInfo.SSID.Length>0
			Catch
				State= False
			End Try
		End If
	End If
	Return State
End Sub
Sub isWIFI_enabled As Boolean 
	Dim P As Phone '0 is off, 2 is on, don't know if it's connected, same for 3
	Return P.GetSettings ("wifi_on") <> 0
End Sub
Sub IsConnected As Boolean 
	Dim P As Phone,server As ServerSocket'Add a reference to the network library  'Check status: DISCONNECTED 0
	Try
	    server.Initialize(0, "")
		'Log("mobile data state: " & P.GetDataState & " wifi_on: " & P.GetSettings("wifi_on") & " server ip: " & server.GetMyIP & CRLF &  "wifi ip: " & server.GetMyWifiIP)
	    If server.GetMyIP = "127.0.0.1" Then Return False  'this is the local host address
		If Not(P.GetDataState.EqualsIgnoreCase("CONNECTED")) And server.GetMyWifiIP = "127.0.0.1" Then Return False
	    Return True
	Catch
		Return False
	End Try
End Sub

Sub CountOccurences(Text As String, TextToFind As String) As Int
	Dim Start As Int, Count As Int
	Do Until Start=-1
		Start=Text.IndexOf2(TextToFind, Start)
		If Start>-1 Then 
			Start = Start+TextToFind.Length 
			Count=Count+1
		End If
	Loop
	Return Count
End Sub
Sub StrReverse(Text As String) As String 
	Dim tempstr As StringBuilder,Temp As Int
	tempstr.Initialize 
	For Temp = Text.Length-1 To 0 Step -1
		tempstr.Append( Text.CharAt(Temp) )
	Next
	Return tempstr.ToString 
End Sub

Sub RemoveWord(FromLeft As Boolean, Text As String, Word As String) As String
	If FromLeft Then
		If Text.StartsWith(Word) Then Return Right(Text, Text.Length-Word.Length).Trim
	Else
		If Text.EndsWith(Word) Then Return Left(Text, Text.Length-Word.Length).Trim 
	End If
	Return Text
End Sub

Sub Len(Text As String) As Int
	Return Text.Length 
End Sub
Sub Left(Text As String, Length As Long)As String 
	If Text.Length>0 And Length>0 Then Return Text.SubString2(0, Min(Text.Length,Length))
End Sub
Sub Right(Text As String, Length As Long) As String
	If Text.Length>0 And Length>0 Then Return Text.SubString(Text.Length-Min(Text.Length,Length))
End Sub
Sub Mid(Text As String, Start As Int, Length As Int) As String 
	If Length>0 And Start>-1 And Start< Text.Length Then Return Text.SubString2(Start,Start+Length)
End Sub
public Sub SplitVars(Text As String) As List
	Dim RET As List, Cont As Boolean = True, temp As Int, temp2 As Int  
	RET.Initialize
	Do Until Not(Cont)
		temp = Text.IndexOf("[")
		If temp = -1 Then 
			Cont = False 
		Else 
			temp2 = Text.IndexOf2("]", temp)
			If temp2 = -1 Then 
				Cont = False 
			Else 
				RET.Add(Left(Text, temp))
				RET.Add(Mid(Text, temp, temp2-temp+1))
				Text = Right(Text, Text.Length-temp2-1)
			End If 
		End If
	Loop
	If Text.Length > 0 Then RET.Add(Text)
	Return RET 
End Sub

Sub CallNativeMethod(OnWhat As Object, MethodName As String, Params() As Object)
	Dim jo As JavaObject = OnWhat
	jo.RunMethod(MethodName, Params)
End Sub

Sub IsTimerRunning(ID As Int) As Int
	Dim Temp As Int, tTimer As LCARtimer 
	For Temp = STimer.TimerList.Size-1 To 0 Step -1
		tTimer=STimer.TimerList.Get(Temp)
		If tTimer.ID =ID Then 
			Return tTimer.Duration 
		End If
	Next
	Return -2
End Sub

Sub StartTimer(Seconds As Int)
	Main.cTimer = Seconds
	Broadcast("timer", Seconds)
	Log("TimerAction: " & Seconds & " = " & GetTime(Seconds))
	NewTimer("Main", 0, Seconds)
	NOTITitle = GetStringVars("auto_noti", Array As String(DateTime.Time(DateTime.Now+Seconds)))
	AutoUpdateNoti
End Sub

Sub SaveMRU(Settings As Map, Key As String, Value As Int, AddIt As Boolean) As Boolean
	Dim Values As List, Index As Int, NeedsSaving As Boolean, tempstr As StringBuilder
	Values.Initialize
	Values.AddAll(Regex.Split(",", Settings.GetDefault(Key, "")))
	Index = Values.IndexOf(Value)
	If AddIt Then
		If Index = -1 Then
			Values.Add(Value)
			NeedsSaving = True
		End If
	Else if Index > -1 Then 'remove it
		Values.RemoveAt(Index)
		NeedsSaving=True
	End If
	If NeedsSaving Then
		tempstr.Initialize
		For Index = 0 To Values.Size - 1
			If Index < Values.Size - 2 Then tempstr.Append( "," )
			tempstr.Append( Values.Get(Index) )
		Next
		Settings.Put(Key, tempstr.ToString)
	End If
	Return NeedsSaving
End Sub
Sub LoadTimers
	Dim Timers() As String = Regex.Split(",", Main.Settings.GetDefault("timers", "")), Index As Int, ID As Int, EndTime As Long, Name As String, Duration As Int
	For Index = 0 To Timers.Length - 1
		Name = Timers(Index)
		If IsNumber(Name) Then
			ID = Name
			EndTime = Main.Settings.Getdefault("timer" & ID, 0)
			If EndTime > DateTime.Now - DateTime.TicksPerMinute Then
				Name = Main.Settings.Getdefault("timer" & ID & ".name", "unnamed timer")
				Duration = Max(1, (EndTime - DateTime.Now) / DateTime.TicksPerSecond)
				NewTimer(Name, ID, Duration)
			End If
		End If
	Next
End Sub
Sub NewTimer(Name As String,ID As Int, Duration As Int) As Int
	Dim Temp As LCARtimer, Index As Int = FindTimer(ID)
	If Index = -1 Then
		Temp.Initialize
		Temp.Name = Name
		Temp.ID = ID
	Else
		Temp = STimer.TimerList.Get(Index)
	End If
	Temp.Duration = Duration
	If Temp.Duration > STimer.Infinite Then
		Temp.EndTime = DateTime.Now + (Duration* DateTime.TicksPerSecond)
		Main.Settings.Put("timer" & ID, Temp.EndTime)
		Main.Settings.Put("timer" & ID & ".name", Name)
		SaveMRU(Main.Settings, "timers", ID, True)
	End If
	If Index = -1 Then STimer.timerlist.Add(Temp)
	If STimer.AllowServices Then StartStimer'StartService(STimer)
	If Index = -1 Then Return STimer.timerlist.Size-1 Else Return Index
End Sub
Sub StopTimer(ID As Int) As Boolean
	Dim Temp As Int = FindTimer(ID)
	If Temp >- 1 Then
		SaveMRU(Main.Settings, "timers", ID, False)
		Main.Settings.Remove("timer" & ID)
		Main.Settings.Remove("timer" & ID & ".name")
		STimer.TimerList.RemoveAt(Temp)
		Return True
	End If
End Sub

Sub FindTimer(ID As Int) As Int 
	Dim Temp As Int, tTimer As LCARtimer 
	For Temp = STimer.TimerList.Size-1 To 0 Step -1
		tTimer=STimer.TimerList.Get(Temp)
		If tTimer.ID = ID Then Return Temp
	Next
	Return -1
End Sub
Sub GetTimer(Name As String ) As String 
	Dim Temp As Int, temp2 As LCARtimer 
	For Temp = 0 To STimer.TimerList.Size-1
		temp2= STimer.TimerList.Get(Temp)
		If temp2.Name.EqualsIgnoreCase(Name) Then
			If temp2.Duration > -1 Then 
				Return GetTime( temp2.Duration)
			Else If temp2.Duration = STimer.Infinite Then
				Return GetString("infinite")
			End If
		End If
	Next
	Return ""
End Sub

Sub GetTimeReverse(Time As String) As Int 
	'If Time.Length = 5 Then Time = "00:" & Time 
	'Dim Hours As Int = Left(Time,2), Minutes As Int = Mid(Time, 3,2), Seconds As Int = Right(Time,2), Total As Int = (Hours * 3600) + (Minutes * 60) + Seconds
	'Log(Time & " IS " & Hours & " HOURS " & Minutes & " MINUTES " & Seconds & " SECONDS (" & Total & ")")
	'Return Total
	
	Dim Units() As String = Regex.Split(":", Time), temp As Int, Seconds As Int = 1, Total As Int 
	For temp = Units.Length - 1 To 0 Step -1 
		Total = Total + (Units(temp)*Seconds )
		Seconds = Seconds * 60		
	Next
	Return Total 
End Sub
Sub GetTime(Seconds As Int) As String 
	Dim SecondsPerHour As Int = 3600, SecondsPerMinute As Int = 60, Hours As Int, Minutes As Int, Time As String '= Seconds
	
	Hours = Floor(Seconds / SecondsPerHour)
	Seconds = Seconds Mod SecondsPerHour
	Minutes = Floor(Seconds / SecondsPerMinute)
	Seconds = Seconds Mod SecondsPerMinute
	
	'Log("GETTIME: (" & Time & ") " & Hours & " HOURS " & Minutes & " MINUTES " & Seconds & " SECONDS")
	'Time=""
	
	If Hours>0 Then Time = Hours & ":"
	Time=Time & ForceLength(Minutes, 2, "0",False) & ":" & ForceLength(Seconds, 2, "0",False)
	Return Time'Time.Replace("000:", "00:")
End Sub

Sub FindWord(Text() As String, TextToFind As String, Start As Int) As Int 
	Dim Temp As Int
	For Temp = Max(0, Start) To Text.Length -1
		If Text(Temp).EqualsIgnoreCase(TextToFind) Then Return Temp
	Next	
	Return -1
End Sub

Sub Containsword(Text() As String , TextToFind As String) As Boolean 
	Dim Temp As Int, tempstr() As String ,temp2 As Int , Found As Boolean ,Start As Int
	tempstr = Regex.Split(" ", TextToFind.ToLowerCase)
	For temp2 = 0 To tempstr.Length-1
		Found=False
		For Temp = Start To Text.Length -1
			If Text(Temp) = tempstr(temp2) Then 
				Found = True
				Start=Temp+1
				Temp=Text.Length 
			End If
		Next
		If Not(Found) Then Return False
	Next	
	Return True
End Sub

Sub IsTime(Text As String) As Boolean 
	'00:00 00:00:00
	Dim ret As Boolean 
	If Text.Length = 5 Or Text.Length=8 Then
		If IsNumber(Left(Text,2)) And IsNumber(Right(Text,2)) And Mid(Text, 2, 1) = ":" Then
			If Text.Length = 8 Then
				ret = IsNumber(Mid(Text,3,2)) And Mid(Text,5,1) = ":" 
			Else
				ret=True 
			End If
		End If
	End If
	Return ret
End Sub
Sub ParseTime(Time As String) As Int 
	Dim Multiplier As Int , Value As Int , Total As Int 
	Do Until Time.Length = 0 
		Value = Right(Time,2)
		Time = Left(Time , Time.Length - 2)
		If Time.Length>0 Then
			If Right(Time, 1) = ":" Then 
				Time = Left(Time , Time.Length - 1)
			End If
		End If
		Total = Total + Value * IIFIndex(Multiplier, Array As Int(1, 60, 3600))
		Multiplier=Multiplier+1
	Loop
	Return Total
End Sub

Sub ForceLength(Text As String, Length As Int, Character As String, AtEnd As Boolean  )As String 
	Dim Temp As Int 
	For Temp = Text.Length +1 To Length
	'Do Until text.Length=>length
		If AtEnd Then Text=Text & Character Else Text = Character & Text
	'Loop
	Next
	Return Text
End Sub




Sub MakeKB(Text As String, SelStart As Int, SelLength As Int, Shift As Boolean, CapsLock As Boolean ) As APIKeyboard 
	Dim Temp As APIKeyboard 
	Temp.Initialize 
	Temp.Text=Text
	Temp.SelLength =SelLength
	Temp.SelStart=SelStart
	Temp.Shift = Shift
	Temp.CapsLock=CapsLock
	Return Temp
End Sub

Sub HandleDirection(KB As APIKeyboard, Direction As Int) As APIKeyboard
	If KB.Shift Then
		KB.SelLength=KB.SelLength+Direction
		If KB.SelLength<0 Then
			If KB.SelStart + KB.SelLength <0 Then KB.SelLength =-KB.SelStart 
		Else If KB.SelLength>0 Then
			If KB.SelStart + KB.SelLength > =KB.Text.Length Then KB.SelLength = KB.Text.Length - KB.SelStart 
		End If
	Else
		KB.SelLength=0
		KB.SelStart = KB.SelStart + Direction
		If KB.SelStart<0 Then KB.SelStart=0
		If KB.SelStart>=KB.Text.Length Then KB.SelStart=KB.Text.Length
	End If
	
	Return KB
End Sub

Sub SelectAll(ElementID As Int) 
	Dim element As LCARelement 
	element=LCAR.LCARelements.Get(ElementID)
	element.LWidth=0
	element.RWidth = element.Text.Length 
	LCAR.LCARelements.Set(ElementID,element)
End Sub

Sub HandleKeyboard(KB As APIKeyboard,KeyCode As Int  ) As APIKeyboard 
	'Msgbox(KeyCode, KeyCodes.KEYCODE_DPAD_LEFT)
	Dim Temp As Boolean ,tempstr As String 
	Select Case KeyCode
		Case -98,-99 'copy, cut
			If KB.SelLength=0 Then
				Log("Copy: " & KB.Text)
				Clipboard(0, KB.Text)
				If KeyCode=-99 Then KB=MakeKB("", 0,0, KB.Shift,LCAR.KBCaps)
			Else
				Log("Copy: " & GetSelText(KB))
				Clipboard(0, GetSelText(KB))
				If KeyCode=-99 Then KB=SetSelText(KB, "", False)
			End If
	
		Case KeyCodes.KEYCODE_SHIFT_LEFT, KeyCodes.KEYCODE_SHIFT_RIGHT: KB.Shift=Not(KB.Shift)
		Case KeyCodes.KEYCODE_DPAD_LEFT:  KB= HandleDirection(KB, -1)
		Case KeyCodes.KEYCODE_DPAD_RIGHT: KB= HandleDirection(KB, 1)
		Case KeyCodes.KEYCODE_SPACE: KB=SetSelText(KB, " ",False)
		Case KeyCodes.KEYCODE_DEL,KeyCodes.KEYCODE_UNKNOWN
			'temp = (KB.SelLength=0)
			KB=SetSelText(KB, KeyCode,True) 'backspace,Delete
			'If temp Then KB= HandleDirection(KB, -1)
		Case -9'clear
			KB = MakeKB("",0,0,False, True)
		Case Else'  "*",  "(",   ")"
			Temp= (KeyCode>28 And KeyCode< 55) 'A-Z
			'If temp=False Then temp = (KeyCode>= Asc("a") AND KeyCode<= Asc("z"))'a-z
			If Temp = False Then Temp = (KeyCode >6 And KeyCode <17)'1-0
			If Temp = False Then Temp = KeyCode<0 '!,$,%,&,|
			If Temp=False Then'symbols
				Select Case KeyCode
					Case KeyCodes.KEYCODE_PERIOD, KeyCodes.KEYCODE_AT ,KeyCodes.KEYCODE_BACKSLASH, KeyCodes.KEYCODE_MINUS, KeyCodes.KEYCODE_POUND:		Temp=True
					Case KeyCodes.KEYCODE_EQUALS, KeyCodes.KEYCODE_COMMA, KeyCodes.KEYCODE_POWER , KeyCodes.KEYCODE_APOSTROPHE , KeyCodes.KEYCODE_STAR:	Temp=True
					Case KeyCodes.KEYCODE_LEFT_BRACKET , KeyCodes.KEYCODE_RIGHT_BRACKET , KeyCodes.KEYCODE_PLUS, KeyCodes.KEYCODE_SLASH :				Temp=True	
					Case KeyCodes.KEYCODE_SEMICOLON: Temp=True
				End Select
			End If
			If Temp Then 'A to Z OR 0 to 9
				tempstr = GetChar( GetKeyCode(KeyCode, True,KB.shift),KB.shift)
				If KB.CapsLock Then tempstr = tempstr.ToUpperCase Else tempstr = tempstr.ToLowerCase  
				KB=SetSelText(KB, tempstr , False)
				KB.Shift=False
			'Else
				'Log("CODE: " & KeyCode & ", CHAR: " & GetKeyCode(KeyCode,True,KB.shift))
			End If
	End Select
	Return KB
End Sub


Sub GetChar(Text As String, Shift As Boolean ) As String 
	If Shift Then 
		Return Text.ToUpperCase 
	Else
		Return Text.ToLowerCase 
	End If
End Sub

Sub GetSelText(KB As APIKeyboard) As String
    If Abs(KB.SelLength) = KB.Text.Length  Then
        Return KB.Text
    Else
        If KB.SelLength > 0 Then
            Return Mid(KB.Text, KB.SelStart, KB.SelLength)
        Else If KB.SelLength < 0 Then
            Return Mid(KB.Text, KB.SelStart + KB.SelLength, Abs(KB.SelLength))
        End If
    End If
End Sub
Sub SetSelText(KB As APIKeyboard, Key As String, KeyCode As Boolean ) As APIKeyboard 
    Dim LSide As Long, RSide As Long, L As String, R As String
    If KB.SelLength > 0 Then
        LSide = KB.SelStart
        RSide = KB.Text.Length - KB.SelStart - KB.SelLength
        KB.SelStart = KB.SelStart + Key.Length 
    Else If KB.SelLength < 0 Then
        LSide = KB.SelStart + KB.SelLength
        RSide = KB.Text.Length - KB.SelStart
        KB.SelStart = LSide + Key.Length
    Else'if kb.sellength=0 then
        LSide = KB.SelStart
        RSide = KB.Text.Length - KB.SelStart
        KB.SelStart = KB.SelStart + Key.Length
    End If
    If LSide > 0 Then L = Left(KB.Text, LSide)
    If RSide > 0 Then R = Right(KB.Text, RSide)
	
	If KeyCode Then
		Select Case Key
			Case KeyCodes.KEYCODE_DEL'backspace
				If KB.SelLength = 0 And L.Length>0 Then
					L= Left(L, L.Length-1)
					KB.SelStart=KB.SelStart-3
				Else
					KB.SelStart=LSide
				End If
				KB.Text = L & R
			Case KeyCodes.KEYCODE_UNKNOWN'delete
				If KB.SelLength = 0 And R.Length>0 Then
					R=Right(R,R.Length-1)
					KB.SelStart=KB.SelStart-1
				Else
					KB.SelStart=LSide
				End If
				KB.Text = L & R
		End Select
		
	Else
		KB.Text = L & Key & R
	End If
	
    KB.SelLength = 0
	Return KB
End Sub

Sub GetKeyCode(Letter As String, GetCharacter As Boolean,Shift As Boolean  ) As String
	Dim ret As String 
	
	ret= ConvertKeyCode(ret, Letter, "0", KeyCodes.KEYCODE_0, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "1", KeyCodes.KEYCODE_1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "2", KeyCodes.KEYCODE_2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "3", KeyCodes.KEYCODE_3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "4", KeyCodes.KEYCODE_4, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "5", KeyCodes.KEYCODE_5, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "6", KeyCodes.KEYCODE_6, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "7", KeyCodes.KEYCODE_7, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "8", KeyCodes.KEYCODE_8, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "9", KeyCodes.KEYCODE_9, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "\", KeyCodes.KEYCODE_SLASH, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "!", -1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "$", -2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "%", -3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "&", -4, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "|", -5, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "?", -6, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "<", -7, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ">", -8, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, GetString("kb_clr"), -9, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, "{", -10, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "}", -11, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "•", -12, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Ω", -13, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "π", -14, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "_", -15, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ":", -16, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[", -17, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "]", -18, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "~", -19, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "`", -20, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, """", -21, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, GetString("kb_caps"), -96, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, GetString("kb_insert"), -97, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, GetString("kb_copy"), -98, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, GetString("kb_cut"), -99, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "A", KeyCodes.KEYCODE_A, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ALT", KeyCodes.KEYCODE_ALT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ALTR", KeyCodes.KEYCODE_ALT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "'", KeyCodes.KEYCODE_APOSTROPHE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "@", KeyCodes.KEYCODE_AT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "B", KeyCodes.KEYCODE_B, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "BACK", KeyCodes.KEYCODE_BACK, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "/", KeyCodes.KEYCODE_BACKSLASH, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "C", KeyCodes.KEYCODE_C, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CALL", KeyCodes.KEYCODE_CALL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CAMERA", KeyCodes.KEYCODE_CAMERA, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CLEAR", KeyCodes.KEYCODE_CLEAR, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ",", KeyCodes.KEYCODE_COMMA, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "D", KeyCodes.KEYCODE_D, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "BKSP", KeyCodes.KEYCODE_DEL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CENTER", KeyCodes.KEYCODE_DPAD_CENTER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "DOWN", KeyCodes.KEYCODE_DPAD_DOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "<ı", KeyCodes.KEYCODE_DPAD_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ı>", KeyCodes.KEYCODE_DPAD_RIGHT, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, "", KeyCodes.KEYCODE_DEL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "DEL", KeyCodes.KEYCODE_UNKNOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "", KeyCodes.KEYCODE_UNKNOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[B", KeyCodes.KEYCODE_DPAD_DOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[D", KeyCodes.KEYCODE_DPAD_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[C", KeyCodes.KEYCODE_DPAD_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[A", KeyCodes.KEYCODE_DPAD_UP, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "UP", KeyCodes.KEYCODE_DPAD_UP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "E", KeyCodes.KEYCODE_E, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENDCALL", KeyCodes.KEYCODE_ENDCALL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENTER", KeyCodes.KEYCODE_ENTER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENVELOPE", KeyCodes.KEYCODE_ENVELOPE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "=", KeyCodes.KEYCODE_EQUALS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "EXPLORER", KeyCodes.KEYCODE_EXPLORER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "F", KeyCodes.KEYCODE_F, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "FOCUS", KeyCodes.KEYCODE_FOCUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "G", KeyCodes.KEYCODE_G, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "GRAVE", KeyCodes.KEYCODE_GRAVE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "H", KeyCodes.KEYCODE_H, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "HEADSET", KeyCodes.KEYCODE_HEADSETHOOK, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "HOME", KeyCodes.KEYCODE_HOME, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "I", KeyCodes.KEYCODE_I, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "J", KeyCodes.KEYCODE_J, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "K", KeyCodes.KEYCODE_K, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L", KeyCodes.KEYCODE_L, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "(", KeyCodes.KEYCODE_LEFT_BRACKET, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "M", KeyCodes.KEYCODE_M, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "FORWARD", KeyCodes.KEYCODE_MEDIA_FAST_FORWARD, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NEXT", KeyCodes.KEYCODE_MEDIA_NEXT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "PLAY", KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "PREVIOUS", KeyCodes.KEYCODE_MEDIA_PREVIOUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "REWIND", KeyCodes.KEYCODE_MEDIA_REWIND, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "STOP", KeyCodes.KEYCODE_MEDIA_STOP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MENU", KeyCodes.KEYCODE_MENU, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "-", KeyCodes.KEYCODE_MINUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MUTE", KeyCodes.KEYCODE_MUTE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "N", KeyCodes.KEYCODE_N, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NOTIFICATION", KeyCodes.KEYCODE_NOTIFICATION, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NUM", KeyCodes.KEYCODE_NUM, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "O", KeyCodes.KEYCODE_O, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "P", KeyCodes.KEYCODE_P, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ".", KeyCodes.KEYCODE_PERIOD, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "+", KeyCodes.KEYCODE_PLUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "#", KeyCodes.KEYCODE_POUND, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "^", KeyCodes.KEYCODE_POWER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Q", KeyCodes.KEYCODE_Q, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R", KeyCodes.KEYCODE_R, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ")", KeyCodes.KEYCODE_RIGHT_BRACKET, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "S", KeyCodes.KEYCODE_S, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SEARCH", KeyCodes.KEYCODE_SEARCH, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ";", KeyCodes.KEYCODE_SEMICOLON, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SHIFT", KeyCodes.KEYCODE_SHIFT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SHIFTR", KeyCodes.KEYCODE_SHIFT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SOFT", KeyCodes.KEYCODE_SOFT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SOFTR", KeyCodes.KEYCODE_SOFT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SPACE", KeyCodes.KEYCODE_SPACE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, " ", KeyCodes.KEYCODE_SPACE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "*", KeyCodes.KEYCODE_STAR, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SYM", KeyCodes.KEYCODE_SYM, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "T", KeyCodes.KEYCODE_T, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "	", KeyCodes.KEYCODE_TAB, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "U", KeyCodes.KEYCODE_U, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "V", KeyCodes.KEYCODE_V, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "VOLDOWN", KeyCodes.KEYCODE_VOLUME_DOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "VOLUP", KeyCodes.KEYCODE_VOLUME_UP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "W", KeyCodes.KEYCODE_W, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "X", KeyCodes.KEYCODE_X, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Y", KeyCodes.KEYCODE_Y, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Z", KeyCodes.KEYCODE_Z, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, "A BTN", BUTTON_A, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "B BTN", BUTTON_B, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "C BTN", BUTTON_C, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "X BTN", BUTTON_X, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Y BTN", BUTTON_Y, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Z BTN", BUTTON_Z, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L1", BUTTON_L1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L2", BUTTON_L2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L3", BUTTON_L3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R1", BUTTON_R1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R2", BUTTON_R2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R3", BUTTON_R3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "START", BUTTON_START, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SELECT", BUTTON_SELECT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MODE", BUTTON_MODE, GetCharacter)
	
	If ret.Length =0 Then
		If Letter = "PST" Then'ret= ConvertKeyCode(ret, Letter, "PST", -12, GetCharacter)
			If GetCharacter Then 
				ret = Clipboard(1,"")
			Else
				ret=-100
			End If
		Else If Not(GetCharacter) Then 
			ret = -999
		End If
	End If
	Return ret
End Sub
Sub ConvertKeyCode(ret As String, Check As String, Letter As String, KeyCode As Int, GetCharacter As Boolean) As String 
	If ret.Length=0 Then
		If GetCharacter Then
			If Check = KeyCode Then Return Letter
		Else
			If Check.EqualsIgnoreCase(Letter) Then Return KeyCode
		End If
	End If
	Return ret
End Sub








Sub InputMethodSelector
	Dim Obj1 As Reflector
	Obj1.Target = Obj1.GetContext
	Obj1.Target = Obj1.RunMethod2("getSystemService", "input_method", "java.lang.String")
	Obj1.RunMethod("showInputMethodPicker")
End Sub
Sub APIlevel As Int 
	Dim R As Reflector
	Return R.GetStaticField("android.os.Build$VERSION", "SDK_INT")
End Sub
Sub LWPselector As Boolean 
	Dim Intent1 As Intent
	Try
		Intent1.Initialize(Intent1.ACTION_MAIN, "")
		If APIlevel<15 Then
			Intent1.SetComponent("com.android.wallpaper.livepicker/.LiveWallpaperListActivity")
		Else
			Intent1.SetComponent("com.android.wallpaper.livepicker/.LiveWallpaperActivity")'this will work for android 4.0.4
		End If
		StartActivity(Intent1)
		Return True
	Catch
		Return False
	End Try
End Sub

'picwidth/height is the size of the image itself (src, before)
'thumbwidth/height is the desired/maximum dimensions (dest, after)
'forcefit expands smaller images to fit picwidth/height while retaining the aspect ratio (ie: letterboxing/pillarboxing)
'forcefull expands smaller images to fill the entire picwidth/height leaving no border, destroying the aspect ratio
Sub Thumbsize(PicWidth As Int, PicHeight As Int, thumbwidth As Int, thumbheight As Int, ForceFit As Boolean, ForceFull As Boolean)As Point 
	Dim Temp As Point 
	Temp.X=PicWidth
	Temp.Y=PicHeight
    If ForceFit Then
        If Temp.Y < thumbheight Then
            Temp.X = Temp.X * thumbheight / Temp.Y
            Temp.Y = thumbheight
        End If
    End If
    If Temp.X > thumbwidth Then
        Temp.Y = Temp.Y / (Temp.X / thumbwidth)
        Temp.X = thumbwidth
    End If
    If Temp.Y > thumbheight Then
        Temp.X = Temp.X / (Temp.Y / thumbheight)
        Temp.Y = Temp.Y / (Temp.Y / thumbheight)
    End If
    If ForceFull Then
        If Temp.X < thumbwidth Then
            Temp.Y = Temp.Y * (thumbwidth / Temp.X)
            Temp.X = thumbwidth
        End If
        If Temp.Y < thumbheight Then
            Temp.X = Temp.X * (thumbheight / Temp.Y)
            Temp.Y = Temp.Y * (thumbheight / Temp.Y)
        End If
    End If
	Return Temp
End Sub











Sub LineSize(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, MaxWidth As Int, Start As Int, GoRight As Boolean) As Int
	Dim tempstr As String ,Temp As Int,tChar As String , Length As Int ,OldLength As Int
	Temp=Start
	Do Until Length>=MaxWidth Or tChar = CRLF 
		Temp = GetNextDelimeter(Text, Temp, GoRight)
		tChar = Mid(Text, Temp,1)
		tempstr=GrabTillNextDelimeter(Text,Start,GoRight,Temp)
		Length = BG.MeasureStringWidth(tempstr, Font, TextSize)
		If Length<= MaxWidth Or tChar= CRLF Then OldLength = Temp
	Loop
	Return OldLength
End Sub



Sub GrabTillNextDelimeter(Text As String, Start As Int, GoRight As Boolean, EndPoint As Int) As String 
	If GoRight Then
		'If EndPoint = Text.Length Then
		'	Return Mid(Text, Start, Text.Length-1-Start)
		'Else
			Return Mid(Text, Start, EndPoint-Start-1)
		'End If
	Else
		If EndPoint = 0 Then
			Return Left(Text,Start)
		Else
			Return Mid(Text, EndPoint+1, Start-EndPoint-1)
		End If
	End If
End Sub
Sub GetNextDelimeter(Text As String, Start As Int, GoRight As Boolean) As Int
	Dim Temp As Int , LocOfSpace As Int ,LocOfCRLF As Int , LocOfEnd As Int 
	If GoRight Then
		LocOfEnd=Text.Length'-1
		LocOfSpace = Text.IndexOf2(" ", Start)'-1 if not found
		LocOfCRLF = Text.IndexOf2(CRLF, Start)
	Else
		LocOfEnd=0
		LocOfSpace = Text.LastIndexOf2(" ", Start)
		LocOfCRLF = Text.LastIndexOf2(CRLF, Start)
	End If
	If LocOfSpace=-1 Then
		If LocOfCRLF =-1 Then
			Return LocOfEnd
		Else
			Return LocOfCRLF
		End If
	Else If LocOfCRLF =-1 Then
		Return LocOfSpace
	Else If GoRight Then
		Return Min(LocOfSpace,LocOfCRLF)
	Else
		Return Max(LocOfSpace,LocOfCRLF)
	End If
End Sub










Sub FormatPercent(Value As Float, Digits As Int) As String 
	Return Round2(Value * 100,Digits) & "%"
End Sub






Sub TextWrap(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, MaxWidth As Int ) As String
	Dim tempstr() As String,Temp As Int , WidthofWord As Int ,WidthofLine As Int , tempstr2 As StringBuilder ,WidthofSpace As Int 
	If TextWidthAtHeight(BG,Font,Text,TextSize) <= MaxWidth Then
		Return Text
	Else
		tempstr2.Initialize
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF, Text.Trim)
			For Temp = 0 To tempstr.Length-1
				If tempstr(Temp).Trim.Length>0 Then
					tempstr2.Append( TextWrap(BG, Font, TextSize, tempstr(Temp), MaxWidth))
					If Temp < tempstr.Length-1 Then tempstr2.Append(CRLF)
				End If
			Next
		Else
			tempstr = Regex.Split(" ", Text)'(\b[^\s]+\b)
			WidthofSpace=TextWidthAtHeight(BG,Font, " ", TextSize)
			For Temp = 0 To tempstr.Length-1
				WidthofWord=TextWidthAtHeight(BG,Font, tempstr(Temp), TextSize)
				If WidthofLine + WidthofWord > MaxWidth Then 
					tempstr2.Append (" " & CRLF)
					If WidthofWord>WidthofLine Then
						tempstr2.Append(SplitWord(BG,Font, TextSize, tempstr(Temp),MaxWidth,True) & " " & CRLF)
						WidthofLine=0
					Else
						tempstr2.Append(tempstr(Temp) & " ")
						WidthofLine=WidthofWord + WidthofSpace
					End If
				Else
					tempstr2.Append(tempstr(Temp) & " ")
					WidthofLine=WidthofLine+WidthofWord + WidthofSpace
				End If
			Next
		End If
		Return tempstr2.ToString 
	End If
End Sub

Sub SplitWord(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, MaxWidth As Int, DoAppend As Boolean ) As String
	Dim Temp As Int, tempstr As StringBuilder , WidthofLine As Int ,WidthofChar As Int ,tempstr2 As String ,WidthofDash As Int
	tempstr.Initialize 
	WidthofDash=TextWidthAtHeight(BG,Font,"-",TextSize)
	WidthofLine=WidthofDash
	For Temp = 0 To Text.Length-1
		tempstr2=Mid(Text,Temp,1)
		WidthofChar = TextWidthAtHeight(BG,Font,tempstr2,TextSize)
		If WidthofLine+WidthofChar>MaxWidth Then 
			If DoAppend Then tempstr.Append("- " & CRLF & tempstr2 ) Else tempstr.Append("-")
			WidthofLine=WidthofDash
		Else
			tempstr.Append(tempstr2)
		End If
		WidthofLine=WidthofLine+WidthofChar
	Next
	Return tempstr.ToString 
End Sub
Sub RemoveChars(Text As String, Chars As String) As String
	Dim temp As Int 
	For temp = 0 To Chars.Length - 1 
		Text = Text.Replace(Mid(Chars,temp,1), "")
	Next
	Return temp
End Sub
Sub TextHeightAtHeight(BG As Canvas, Font As Typeface, Text As String, theFontSize As Int)As Int 
	Dim tempstr() As String ,Height As Int,Temp As Int, CRLFspace As Int 
	CRLFspace=15
	If Text<>Null Then
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF,Text)
			For Temp = 0 To tempstr.Length -1
				Height=Height+BG.MeasureStringHeight(tempstr(Temp),Font,theFontSize)+CRLFspace
			Next
			Return Height-CRLFspace
		Else
			Return BG.MeasureStringHeight(Text,Font,theFontSize)
		End If
	End If
End Sub
Sub TextWidthAtHeight(BG As Canvas,Font As Typeface, Text As String, Height As Int) As Int
	Dim tempstr() As String ,Width As Int,Temp As Int ,temp2 As Int
	If Text<>Null Then
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF,Text)
			For Temp = 0 To tempstr.Length -1
				temp2=BG.MeasureStringWidth(tempstr(Temp),Font,Height)
				If temp2>Width Then Width=temp2
			Next
			Return Width
		Else
			Return BG.MeasureStringWidth(Text,Font,Height)
		End If
	End If
End Sub

Sub GetBiggestTextDimension(Width As Boolean, BG As Canvas, Font As Typeface, TextSize As Int, Text() As String) As Int 
	Dim temp As Int, Count As Int 
	For temp = 0 To Text.Length - 1
		If Width Then 
			Count = Max(Count, BG.MeasureStringWidth(Text(temp), Font, TextSize))
		Else 
			Count = Max(Count, BG.MeasureStringHeight(Text(temp), Font, TextSize))
		End If
	Next
	Return Count
End Sub

Sub CountInstances2(Text As String, Substring As String) As Int
	Dim Start As Int, Count As Int 
	Do Until Start=-1
		Start=Instr(Text, Substring, Start)+1
		If Start >-1 Then Count = Count+ 1	
	Loop
	Return Count
End Sub
Sub FindAtInstance(Text As String, Substring As String, EndAtInstance As Int, Start As Int) As Int 
	Dim Count As Int 'it's a safe assumption that the words will be at least 2 characters on average
	If Start >= Text.Length Then Return Text.Length 
	Do Until Start=-1
		Start=Instr(Text, Substring, Start)+1
		If Start =-1 Then 
			Return Text.Length 
		Else
			Count = Count+ 1	
			If Count = EndAtInstance Then Return Start  
		End If
	Loop
	Return Text.Length 
End Sub

Sub CountInstances(Text As String, Substring As String) As Int
	Return Regex.Split(Substring, Text).Length 
End Sub

Sub KillAllExceptNumbers(Text As String) As Int
	Dim tempstr As String, Temp As Int , Letter As String 
	For Temp = 0 To Text.Length-1 
		Letter= Mid(Text, Temp,1)
		Select Case Letter
			Case "0","1","2","3","4","5","6","7","8","9"
				tempstr=tempstr & Letter
		End Select
	Next
	If IsNumber(tempstr) Then
		Return tempstr
	Else
		Return 0
	End If
End Sub

Sub GetRotation As Int
	Dim R As Reflector
	R.Target = R.GetActivity
	R.Target = R.RunMethod("getWindowManager")
	R.Target = R.RunMethod("getDefaultDisplay")
	Return R.RunMethod("getRotation")
End Sub


'Wav header =9*4+4*2 = 80 bytes
Sub ReadAllBytes(folder As String , filename As String ) As Byte()
    Try 
        Dim In As InputStream
        In = File.OpenInput(folder,filename)
        Dim out As OutputStream
        out.InitializeToBytesArray(1)
        File.Copy2(In, out)

        Dim data() As Byte
        data = out.ToBytesArray
        
        out.Close
        In.Close 
        out.Flush
        
        Return data 
    Catch 
        Return Null 
    End Try 
End Sub

'Sub MediaButton
'	Long eventtime = SystemClock.uptimeMillis();
'
'  Intent downIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent downEvent = new KeyEvent(eventtime, eventtime,
'KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  downIntent.putExtra(Intent.EXTRA_KEY_EVENT, downEvent);
'  sendOrderedBroadcast(downIntent, Null);
'
'  Intent upIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent upEvent = new KeyEvent(eventtime, eventtime,
'KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  upIntent.putExtra(Intent.EXTRA_KEY_EVENT, upEvent);
'  sendOrderedBroadcast(upIntent, Null); 
'End Sub


Sub LogBytes(RecData() As Byte)
	Dim tempstr As StringBuilder ,Temp As Int ,temp2 As Int 
	tempstr.Initialize 
	tempstr.Append( "Bytes:"  )
	For Temp = 0 To RecData.Length-1 Step 2
		'temp2 =RecData(temp) Normalize(RecData(temp))
		'If temp2<0 Then temp2 = 127 - temp2
		
		temp2 = Combine(RecData(Temp+1), RecData(Temp))
		tempstr.Append( " " & temp2 )
	Next
End Sub
Sub Normalize(Data As Byte) As Int
	If Data<0 Then
		Return 127 - Data
	Else
		Return Data
	End If
End Sub
Sub Combine(Byte1 As Byte, Byte2 As Byte) As Int
	Dim Temp As Int 
	'Return Normalize(Byte2) + (Normalize(Byte1)*256)
	'Return Normalize(Byte2) + Bit.ShiftLeft(Normalize(Byte1),8)  '*256)
	
	Return Bit.Or( Byte2 , Bit.ShiftLeft(Byte1,8)) *0.5 '*256)
End Sub




'To get a rainbow: Hue=PercentOfROYGBIV*239, Saturation=127,Luminance=127
Sub HSLtoRGB(Hue As Int, Saturation As Int, Luminance As Int, Alpha As Int ) As Int 
   Dim temp3(3) As Double , Red As Int, Green As Int, Blue As Int ,temp1 As Double, temp2 As Double ,n As Int 
   Dim pHue As Double, pSat As Double, pLum As Double , pRed As Double, pGreen As Double, pBlue As Double 
   
   pHue = Min(239, Hue) / 239
   pSat = Min(239, Saturation) / 239
   pLum = Min(239, Luminance) / 239

   If pSat = 0 Then
      pRed = pLum
      pGreen = pLum
      pBlue = pLum
   Else
      If pLum < 0.5 Then
         temp2 = pLum * (1 + pSat)
      Else
         temp2 = pLum + pSat - pLum * pSat
      End If
      temp1 = 2 * pLum - temp2
   
      temp3(0) = pHue + 1 / 3
      temp3(1) = pHue
      temp3(2) = pHue - 1 / 3
      
      For n = 0 To 2
         If temp3(n) < 0 Then temp3(n) = temp3(n) + 1
         If temp3(n) > 1 Then temp3(n) = temp3(n) - 1
      
         If 6 * temp3(n) < 1 Then
            temp3(n) = temp1 + (temp2 - temp1) * 6 * temp3(n)
         Else
            If 2 * temp3(n) < 1 Then
               temp3(n) = temp2
            Else
               If 3 * temp3(n) < 2 Then
                  temp3(n) = temp1 + (temp2 - temp1) * ((2 / 3) - temp3(n)) * 6
               Else
                  temp3(n) = temp1
                End If
             End If
          End If
       Next 

       pRed = temp3(0)
       pGreen = temp3(1)
       pBlue = temp3(2)
    End If

    Red = pRed * 255
    Green = pGreen * 255
    Blue = pBlue * 255

	Return Colors.ARGB(Alpha, Red,Green,Blue)
End Sub


Sub uCase(Text As String)As String 
	Return Text.ToUpperCase 
End Sub
Sub lCase(Text As String) As String 
	Return Text.ToLowerCase 
End Sub
Sub Trim(Text As String) As String 
	Return Text.Trim 
End Sub
Sub Replace(Text As String, TextToReplace As String, ReplaceWith As String) As String 
	Return Text.Replace(TextToReplace,ReplaceWith)
End Sub
Sub StartsWith(Text As String, StartsWithThis As String) As Boolean
	Return Left(Text, StartsWithThis.Length).EqualsIgnoreCase(StartsWithThis)
End Sub
Sub EndsWith(Text As String, EndsWithThis As String) As Boolean
	Return Right(Text, EndsWithThis.Length).EqualsIgnoreCase(EndsWithThis)
End Sub

'0=copy 1=paste 2=return if has text, 3=return if has LCARS text, 4=Copy LCARS text
Sub Clipboard(Op As Int, Text As String) As String 
	Dim Temp As BClipboard 
	Select Case Op
		Case 0'copy
			Temp.clrText 
			Temp.settext(Text)
		Case 1: Return Temp.getText'paste
		Case 2: Return Temp.hasText'return if has text
		Case 3'LCARSUI TEXT
			If Temp.hasText Then Return StartsWith(Temp.getText, "LCARSUI")
		Case 4:Clipboard(0, "LCARSUI" & CRLF & Text) 'COPY LCARS UI TEXT
	End Select
End Sub

Sub DeleteFileOrDir(Filename As String) 
	Dim Dir As String = GetDir(Filename), Files As List, FullPath As String = Filename, temp As Int 
	Filename = GetFile(Filename)
	If File.IsDirectory(Dir,Filename) Then 
		Files = File.ListFiles(FullPath)
		For temp = 0 To Files.Size - 1
			DeleteFileOrDir(File.Combine(FullPath, Files.Get(temp)))
		Next
	End If
	File.Delete(Dir,Filename)
End Sub





Sub GetEncryptionKey (isPublic As Boolean) As Object 
	Dim keys(8) As Byte, Temp As Int,tempstr As String ,tempstr2() As String 
	If isPublic Then
		For Temp = 0 To 7
			If Temp < Main.StarshipID.Length-1 Then
				keys(Temp) = Asc(Mid(Main.StarshipID, Temp,1))
			Else
				keys(Temp) = 0
			End If
		Next
	Else
		Encryption = True
		If Main.Settings.ContainsKey("Key") Then
			tempstr = Main.Settings.Get("Key")
			tempstr = CODEC(tempstr, False, GetEncryptionKey(True))
		Else
			For Temp = 0 To 7
				tempstr = tempstr & Rnd(0,255) & IIF(Temp<7, ",", "")
			Next
			Main.Settings.Put("Key", CODEC(tempstr, True, GetEncryptionKey(True)))
		End If
		tempstr2 = Regex.Split(",", tempstr)
		If tempstr2.Length = 8 Then
			keys = Array As Byte( tempstr2(0), tempstr2(1), tempstr2(2),tempstr2(3),tempstr2(4),tempstr2(5),tempstr2(6),tempstr2(7) )
			'For temp = 0 To 7
			'	keys(temp) = tempstr2(temp)
			'Next
		End If
	End If
	Return keys
End Sub


Sub CODEC(Text As String, Encrypt As Boolean, key() As Byte ) As String    'mode= 0/1 = encode/decode
    If Text = Null Or Text = "" Then Return ""
    Dim data(0) As Byte ,bytes(0) As Byte , Bconv As ByteConverter,Kg As KeyGenerator,C As Cipher, Diff As Int ,Temp As Int 'key(0) As Byte,
    C.Initialize("DES/ECB/NoPadding") ' just "DES" actually performs "DES/ECB/PKCS5Padding". 
    Kg.Initialize("DES")
    Kg.KeyFromBytes(key)
    If Encrypt Then    
        data = Bconv.StringToBytes(padString(Text), "UTF8")
		Diff=data.Length Mod 8
		If Diff =0 Then
        	data = C.Encrypt(data, Kg.key, False)
		Else
			Dim NewData( data.Length+ 8-Diff) As Byte ,BC As ByteConverter 
			BC.ArrayCopy(data,0,NewData,0, data.Length)
			data = C.Encrypt(NewData, Kg.key, False)
		End If
		Return Bconv.HexFromBytes(data)
    Else
        data = Bconv.HexToBytes(Text)
        bytes = C.Decrypt(data, Kg.key, False)
        Return Bconv.StringFromBytes(bytes,"UTF8").Trim
    End If
End Sub

Sub padString(source As String) As String
	Dim x As Int, padLength As Int
	x = source.Length Mod 16
	padLength = 16 - x
	For i = 0 To padLength - 1
	    source = source & " "
	Next
	Return source
End Sub


Sub RemoveTag(Text As String, Tag As String) As String 
	Dim Temp As Int ,temp2 As Int 
	Do While Temp>-1 'remove GMAIL quote	<div class=3D"gmail_quote"> to <br>
		Temp = Instr(Text, "<" & Tag, 0)
		If Temp >-1 Then'is gmail
			temp2 = Instr(Text, "</" & Tag & ">", Temp)
			If temp2=-1 Then
				Temp=-1
			Else
				Text = Left(Text, Temp) & Right(Text, Text.Length - (temp2+3+Tag.Length))
			End If
		End If
	Loop
	Return Text
End Sub
Sub StripHTML(Text As String) As String
	Dim Temp As Int ,temp2 As Int 
	Text = RemoveTag(Text, "script")
	Text = RemoveTag(Text, "style")	
	Text = Text.Replace("<br>", CRLF).Replace("<p>", CRLF)
	Temp=0
	Do While Temp>-1'remove all HTML
		Temp = Instr(Text, "<", 0)
		If Temp>-1 Then
			temp2=Instr(Text,">", Temp)
			If temp2=-1 Then
				Temp=-1
			Else
				Text = Left(Text, Temp) & " " &  Right(Text, Text.Length - (temp2+1))
			End If
		End If
	Loop	
	Do While Instr(Text, CRLF & CRLF,0)>-1 'remove double new lines
		Text=Text.Replace(CRLF & CRLF, CRLF)
	Loop
	Return Text.Trim'.Replace(STimer.ReplyWarning, "").Trim
End Sub


Sub StartWidgets
	If STimer.AllowServices Then
		StartService(Widgets)
		CallSubDelayed2(Widgets, "RefreshAll", -2)
	End If
End Sub

Sub SendPebble(Header As String, Body As String)
	If UsePebble Then SendAlertToPebble("LCARSUI", Header,Body)
End Sub

Sub SendAlertToPebble(ThisAppsName As String, Header As String, Body As String)
	Dim I As Intent,P As Phone, JSON As String ' , JSON As JSONGenerator , M As Map , alist As List
	I.Initialize("com.getpebble.action.SEND_NOTIFICATION", "")
	
	'SendAlertToPebble: [{"body":"TEST","title":"LCARS"}]
	'alist.Initialize
	'M.Initialize 
	'M.put("title", Header)
	'M.put("body", Body)
	'alist.Add(M)
	'JSON.Initialize2(alist)
	
	Body=Body.Replace(Eval.vbQuote, "\" & Eval.vbQuote)
	Body=Body.Replace("\", "\\")
	Body=Body.Replace("/", "\/")
	Body=Body.Replace(CRLF, "\n")'\r
	
	JSON = "[{""body"":""" & Body & """,""title"":""" & Header & """}]"
		
	I.PutExtra("messageType", "PEBBLE_ALERT")
	I.PutExtra("sender", ThisAppsName)
	I.PutExtra("notificationData", JSON )
	'Log("SendAlertToPebble: " & JSON.ToString)
	P.SendBroadcastIntent(I)
End Sub





'Sub HandleFTL(Dir As String, Filename As String)
'	Dim INIfiles As List ,temp As Int,tempstr As String 
'	If Dir.Length=0 Then'enumerate INI files
'		Dir = File.Combine( File.DirRootExternal , "Technis")
'		INIfiles = File.ListFiles(Dir)
'		For temp = 0 To INIfiles.Size-1
'			tempstr = INIfiles.Get(temp)
'			If tempstr.ToLowerCase.EndsWith(".ini") Then
'				HandleFTL(Dir, tempstr)
'			End If
'		Next
'	Else'given an INI file
'		tempstr=Left(Filename, Filename.Length-4)
'		If Not(File.Exists(Dir,tempstr)) Then File.MakeDir(Dir, tempstr)
'		INIfiles = INI.LoadINI(Dir,Filename)
'		Dir = File.Combine(Dir,tempstr)
'		For temp = 0 To INIfiles.Size-1
'			HandleFTLelement(Dir, INIfiles.Get(temp))
'		Next
'	End If
'End Sub
'Sub HandleFTLelement(Dir As String, INIdata As INIfile)As Boolean 
'	Dim Element As LCARelement ,tempstr As String ,temp As Int, BMP As Bitmap ,BG As Canvas 
'	'(LOC As tween ,					Size As tween,					Opacity As TweenAlpha, 		ElementType As Int, 			ColorID As Int, 			IsDown As Boolean, 				Name As String,				SurfaceID As Int, 			Tag As String, 				Group As Int,				Text As String,					SideText As String,  	LWidth As Int,	RWidth As Int,			IsClean As Boolean,	TextAlign As Int,	RedAlertHold As Int,	RedAlertCycles As Int,	State As Boolean,		Visible As Boolean,	Enabled As Boolean,		Align As Int,		Blink As Boolean,	Async As Boolean,	RespondToAll As Boolean)
'	If Not(File.Exists(Dir, INIdata.Section)) Then
'		Element.Initialize 
'		tempstr = INI.GetKey2(INIdata, "Type", 0)
'		If IsNumber(tempstr) Then
'			Element.ElementType = tempstr
'		Else
'			Element.ElementType = LCAR.GetElementType(tempstr)
'		End If
'		tempstr = INI.GetKey2(INIdata, "Color", 0)
'		If IsNumber(tempstr) Then
'			Element.ColorID = tempstr
'		Else
'			Element.ColorID = LCAR.FindLCARcolor(tempstr)
'		End If
'		'If SurfaceID = -999 Then
'		'Element = WallpaperService.LCARelements.Get(ElementID)
'		Element = LCAR.MakeLCAR("FTL", 0, 0,0,   INI.GetKey2(INIdata, "Width",0), INI.GetKey2(INIdata, "Height",0), GetINIValue(INIdata, "Lwidth"), GetINIValue(INIdata, "Rwidth"), Element.ColorID, Element.ElementType, INI.GetKey2(INIdata, "Text",""),INI.GetKey2(INIdata, "SideText", ""), "", 0, True, INI.GetKey2(INIdata, "TextAlign", 0), True, INI.GetKey2(INIdata, "Align", 0), INI.GetKey2(INIdata, "Alpha",255)) 
'		WallpaperService.LCARelements.Clear 
'		WallpaperService.LCARelements.Add(Element)
'		BMP.InitializeMutable(INI.GetKey2(INIdata, "Width",0), INI.GetKey2(INIdata, "Height",0))
'		BG.Initialize2(BMP)
'		LCAR.DrawElement(BG, -999, 0, False)
'		LCARSeffects.SaveScreenshot(BMP, Dir, INIdata.Section)
'	End If'leftside
'End Sub
'Sub GetINIValue(INIdata As String, Key As String) As Int 
'	Dim tempstr As String = INI.GetKey2(INIdata, Key,0)
'	Select Case tempstr.ToLowerCase 
'		Case "leftside":	Return LCAR.leftside 
'		Case "itemheight":	Return LCAR.ItemHeight 
'	End Select
'	Return tempstr
'End Sub
Sub ToNumber(Text As String) As Double 
	If IsNumber(Text) Then Return Text
	Return 0
End Sub

Sub ToggleStardateMode(CurrentMode As Int) As Int
	'Mode: -2=regular date/time, -1=legacy, 0=accurate stardate, 1=accurate stardate 400 years from now, 2=same as 1 but ignores timezone
	If CurrentMode>1 Then Return -3 Else Return CurrentMode+1
End Sub
Sub EnumAllEvents(StartDate As Long, EndDate As Long)As List 
	Dim CAL As MyCalendar, Calendars As Map, temp As Int, Events As List, temp2 As Int, UTC As Long =(DateTime.TimeZoneOffset-1)*-DateTime.TicksPerHour 
	CAL.Initialize 
	Events.Initialize 
	Calendars = CAL.GetListOfAllCalendars(False)'key=id, value=name of calendar
	If UTC > 0 Then StartDate = StartDate - UTC
	For temp = 0 To Calendars.Size-1
		Dim calEvents As List, calID As Int = Calendars.GetKeyAt(temp)
		If StartDate=EndDate Then
			calEvents = CAL.GetListofAllEventsforCalendar(calID)
		Else
			calEvents = CAL.GetListofEventsforCalendarBetweenDates(calID,StartDate,EndDate)
		End If
		'Log("Checking calendar " & calID & " " & Calendars.GetValueAt(temp) & " = " & (calEvents.Size/7) & " events")
		For temp2 = 0 To calEvents.Size-1 Step 7
			Dim Event As CalendarEvent
			Event.Initialize 
			Event.calID = calID
			Event.EventName = 	calEvents.Get(temp2)			'(0) Event Name
			Event.Description = calEvents.Get(temp2+1)			'(1) Description
			Event.StartTime  = 	calEvents.Get(temp2+2)			'(2) Start Time
			Event.EndTime = 	calEvents.Get(temp2+3)			'(3) End Time
			Event.Loc = 		calEvents.Get(temp2+4)			'(4) Location
			Event.AllDay = 		calEvents.Get(temp2+5) = "1"	'(5) All day indicator, 1= all day, 0= not 
			Event.EventID = 	calEvents.Get(temp2+6)			'(6) Event_ID
			If Event.AllDay Then
				Event.StartTime = Event.StartTime + UTC
				Event.EndTime = Event.EndTime + UTC
				'If DateTime.GetHour(Event.EndTime) > (24 - DateTime.GetHour(Event.StartTime)) AND DateTime.GetDayOfMonth(Event.StartTime) <> DateTime.GetDayOfMonth(Event.EndTime) Then
				'	Event.StartTime  = 	MakeDate(  DateTime.getyear(Event.EndTime), DateTime.GetMonth(Event.EndTime), DateTime.GetDayOfMonth(Event.EndTime), 0,0,0,0)
				'Else
				'	Event.StartTime  = 	MakeDate(  DateTime.getyear(Event.StartTime), DateTime.GetMonth(Event.StartTime), DateTime.GetDayOfMonth(Event.StartTime), 0,0,0,0)
				'End If
			End If
			Events.Add(Event)
		Next
	Next
	Events.SortType("StartTime", True)
	Return Events
End Sub

'Hour or Minute: -1=now
Sub GetToday(Hour As Int, Minute As Int) As Long 
	If Hour = -1 Then Hour = DateTime.GetHour(DateTime.Now)
	If Minute = -1 Then Minute = DateTime.GetMinute(DateTime.Now)
	Return MakeDate( DateTime.GetYear(DateTime.Now), DateTime.GetMonth(DateTime.Now), DateTime.GetDayOfMonth(DateTime.Now), Hour, Minute,0,0)
End Sub
Sub EnumEvents(Events As List, StartDate As Long, EndDate As Long)As List 
	Dim Ret As List, temp As Int, IsSorted As Boolean=True , LastStartDate As Long, DoIt As Boolean 
	Ret.Initialize 
	'Log("Between: " & DateTime.Date(StartDate) & " - " & DateTime.Time(StartDate) & " (" & StartDate & ") and " & DateTime.Date(EndDate) & " - " & DateTime.Time(EndDate) & " (" & EndDate & ")")
	For temp = 0 To Events.Size-1
		Dim tempEvent As CalendarEvent 
		tempEvent = Events.Get(temp)
		DoIt = False 
		
		If tempEvent.StartTime >= StartDate And tempEvent.StartTime< EndDate Then DoIt = True 
		
		'If DoIt And tempEvent.AllDay Then 
		
		If DoIt Then Ret.Add(tempEvent)
		
		If tempEvent.StartTime >= LastStartDate Then
			LastStartDate=tempEvent.StartTime
		Else
			IsSorted=False
		End If
		If tempEvent.StartTime > EndDate And IsSorted Then temp = Events.Size'only for sorted event lists
	Next
	Return Ret
End Sub

Sub TheTime(Time As Long) As String 
	Return PadtoLength(DateTime.GetHour(Time),True,2,"0") & ":" & PadtoLength(DateTime.GetMinute(Time),True,2,"0")
End Sub

'returns the the day of the month for the Index day of the week. ie: third wednesday of october 2013 = 16
'DayOfWeek: 1=sunday,2=monday,3=tuesday,4=wednesday,5=thursday,6=friday,7=saturday
Sub GetXday(Year As Int, Month As Int, Index As Int, DayOfWeek As Int) As Int 
	Dim DayOfMonth As Int =1, temp As Long  = MakeDate(Year,Month,1,0,0,0,0), Day As Int = DateTime.GetDayOfWeek(temp), temp2 As Int 
	If Day < DayOfWeek Then
		DayOfMonth = DayOfWeek-Day+1
	Else If Day > DayOfWeek Then
		DayOfMonth = 8-(Day-DayOfWeek)
	End If
	Return DayOfMonth + (7 * (Index-1))'MakeDate(Year,Month,DayOfMonth,0,0,0,0)
End Sub
Sub GetHoliday(StartDate As Long) As String 
	'Dim bday As String = "'s Birthday", D As String = " Day"'http://en.memory-alpha.org/wiki/Star_Trek_birthdays
	'If Not(InternalEvents) Then Return ""
	Dim Day As String = "date_" & DateTime.GetMonth(StartDate) & "_" & DateTime.GetDayOfMonth(StartDate)
	If Translation.ContainsKey(Day) Then Return GetString(Day)
	Return ""
End Sub

'Index: -1=Random (Excludes transparent), 0=Black, 1=Blue, 2=Cyan, 3=Dark gray, 4=Gray, 5=Green, 6=Light Gray, 7=Magenta, 8=Red, 9=White, 10=Yellow, 11=Transparent
Sub SystemColor(Index As Int) As Int 
	Select Case Index 
		Case -1: Return SystemColor(Rnd(0,11))
		Case 0:  Return Colors.Black
		Case 1:  Return Colors.Blue
		Case 2:  Return Colors.Cyan
		Case 3:  Return Colors.DarkGray
		Case 4:  Return Colors.Gray
		Case 5:  Return Colors.Green
		Case 6:  Return Colors.LightGray
		Case 7:  Return Colors.Magenta
		Case 8:  Return Colors.Red
		Case 9:  Return Colors.White
		Case 10: Return Colors.Yellow
		Case 11: Return Colors.Transparent
	End Select
End Sub










'
''moon stuff
'Sub JulianDay(When As Long) As Long	
'	Return DateTime.DateParse(DateTime.Date(When))/DateTime.TicksPerDay
'End Sub
'
''0=t (julian date), 1=i (moon phase angle)
'Sub NewMoon(When As Long) As Object 
'	Dim t As Double = (JulianDay(When) - 2451545) / 36525'See Meeus 22.1
'	Dim i As Double = Moon_PhaseAngle(t)' the phase angle
'	Return Array As Double(t,i)
'End Sub
'
'Sub Moon_MeanElongation(t As Double) As Double '/** Mean elongation of the moon.  See Meeus 47.2. */			aka d
'    Return 297.8501921 + t * (445267.1114034 + t * (-0.0018819 + t * (1.0 / 545868.0 - t / 113065000.0)))
'End Sub
'
'Sub Sun_MeanAnomaly(t As Double) '/** Sun's mean anomaly.  See Meeus 47.3. */									aka m
'    Return 357.5291092 + t * (35999.0502909 + t * (-0.0001536 + t / 24490000.0))
'End Sub
'
'Sub Moon_MeanAnomaly(t As Double) ' /** Moon's mean anomaly.  See Meeus 47.4. */								aka mPrime
'    Return 134.9633964 + t * (477198.8675055 + t * (0.0087414 + t * (1.0 / 69699.0 - t / 14712000.0)))
'End Sub
'
'Sub Moon_PhaseAngle(t As Double) As Double '/** Determines the phase angle between the sun, moon and earth.		aka i
'	Dim D As Double = Moon_MeanElongation(t), M As Double = Sun_MeanAnomaly(t), mPrime As Double = Moon_MeanAnomaly(t)
'    Return 180.0  - D  - 6.289 * Sin(mPrime) + 2.100 * Sin(M) - 1.274 * Sin(2.0 * D - mPrime) - 0.658 * Sin(2.0 * D) - 0.214 * Sin(2.0 * mPrime) - 0.110 * Sin(D)
'End Sub
'
'Sub Moon_illuminatedFraction(i As Double) As Double  '/** Returns the illuminated fraction of the moon's surface. */
'	Return (1 + Cos(i)) * 0.5;
'End Sub
'
''True=waxes (grows), False=wanes (shrinks)		Meeus didn't have a formula for this, but it seemed obvious (famous last words?  ;)
'Sub Moon_BrightnessState(i As Double) As Boolean 
'	Dim s As Double =  Sin(i)
'	If s > 0 Then Return True
'	If s < 1 Then Return False 
'	Return Cos(i) > 0'// d'oh, now we're either at the absolute full moon or new moon!
'End Sub
'
'Sub TestMoon(When As Long) 
'	If when=0 Then when = DateTime.Now 
'	Dim TheMoon() As Double = NewMoon(when)
'	Dim MoonElong As Long = Moon_MeanElongation(TheMoon(0)) * 100, MoonAnon As Long = Moon_MeanAnomaly(TheMoon(0)) * 100, SunAnon As Long = Sun_MeanAnomaly(TheMoon(0)) * 100
'	Log("Moon_MeanElongation: " & MoonElong)
'	Log("Moon_MeanAnomaly: " & MoonAnon)
'	Log("Sun_MeanAnomaly: " & SunAnon)
'	Log("The moon is " & Round(Moon_illuminatedFraction(TheMoon(1)) * 100) & "% full and " & IIF(Moon_BrightnessState(TheMoon(1)),  "waxing (growing)", "waning (shrinking)"))
'End Sub

Sub OpenCalendarApp
	Dim I As Intent
	'intent.setData(Uri.parse("market://details?id=com.example.android")); becomes i.Initialize(i.ACTION_VIEW, "market://details?id=com.example.android")
	If APIlevel >=8 Then '// Android 2.2+  
		I.Initialize(I.ACTION_VIEW, "content://com.android.calendar/time")
	Else'// Before Android 2.2+  
		I.Initialize(I.ACTION_VIEW, "content://calendar/time")  
	End If
'	I.Initialize(I.ACTION_VIEW, "")
'	'I.AddCategory("android.intent.category.APP_CALENDAR")
'	I.SetType("vnd.android.cursor.item/event")
'	I.PutExtra("time", DateTime.Now)
'	I.putExtra("begin", MakeDate(-1,-1,-1, 0,0,0,0))
'	I.putExtra("end", MakeDate(-1,-1,-1, 23,59,59,0))
	StartActivity(I)
	
'	Try
'	  	I.Initialize("android.intent.action.VIEW", "content://com.android.calendar/time/" &DateTime.Now)
'	   	I.AddCategory("android.intent.category.DEFAULT")'add cat launcher
'	   	I.PutExtra("id", 6637)
'		StartActivity(I)'start the activity
'	Catch
'		Log("Error Caught: " & LastException)
'	End Try
End Sub

Sub CompressSize(Bytes As Double, DecimalPlaces As Int) As String 
	Dim Units As String
	If Bytes < 1024 Then
		Units = "shortsize_b"
	Else If Bytes < 1048576 Then
		Bytes = Bytes / 1024
		Units = "shortsize_kb"
	Else If Bytes < 1073741824 Then 
		Bytes = Bytes / 1048576
		Units = "shortsize_mb"
	Else If Bytes < 1099511627776 Then
		Bytes = Bytes / 1073741824
		Units = "shortsize_gb"
	Else 
		Bytes = Bytes / 1099511627776
		Units = "shortsize_tb"
	End If
	Return GetStringVars(Units, Array As String(Round2(Bytes, DecimalPlaces)))
End Sub 

Sub DayLabel(Date As Long, DayOfWeek As Boolean) As String 
	Dim temp As Long = DateTime.Now + DateTime.TicksPerDay , tempstr() As String = Array As String("SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY")
	If DateTime.GetDayOfYear(Date) = DateTime.GetDayOfYear(DateTime.Now) And DateTime.GetYear(Date) = DateTime.GetYear(DateTime.Now) Then Return GetString("date_today")
	If DateTime.GetDayOfYear(Date) = DateTime.GetDayOfYear(temp) And DateTime.GetYear(Date) = DateTime.GetYear(temp) Then Return GetString("date_tomorrow")
	If Date < DateTime.Now Then Return GetString("date_past")
	If DayOfWeek And Date < (DateTime.Now + DateTime.TicksPerDay*7) Then Return GetString("date_" & tempstr(DateTime.GetDayOfWeek(Date)-1).ToLowerCase)
	temp = Floor( (Date - MakeTime(0,0,0)) / DateTime.TicksPerDay)
	Return GetStringVars("date_daysfrom", Array As String(temp))' & " DAYS FROM NOW"
End Sub





Sub GetFreeMemory As Long
   Dim jo As JavaObject
   Return jo.InitializeStatic("java.lang.Runtime").RunMethodJO("getRuntime", Null).RunMethod("totalMemory", Null)
End Sub




'Channel: 0=a, 1=r, 2=g, 3=b, 4=BW(lightness), 5=BW(average), 6=BW(luminosity), 7=Hue, 8=Saturation, 9=Value, 10=RGB compressed
Sub MakeHistogram(SRC As Bitmap, Channel As Int, Inc As Int) As Histogram
	Dim TotalValues As Int = 256, temp As Int,temp2 As Int, Value As Int , tempHist As Histogram 
	'TotalValues = TotalValues*TotalValues*TotalValues*TotalValues
	tempHist.Initialize 
	tempHist.Values.Initialize 
	tempHist.Inc = 1'Inc
	For temp = 0 To TotalValues-1
		tempHist.Values.Add(0)
	Next
	For temp2 = 0 To SRC.Height-1 Step Inc 
		For temp = 0 To SRC.Width -1 Step Inc
			Value = GetARGB(SRC.GetPixel(temp,temp2), Channel)
			'Value = HistogramIndex( SRC.GetPixel(temp,temp2), Inc)
			If Value < tempHist.Values.size Then
				TotalValues = tempHist.Values.Get(Value) + 1
				tempHist.Highest = Max(tempHist.Highest,TotalValues)
				tempHist.Values.set(Value,TotalValues)
			End If
		Next
	Next
	Return tempHist
End Sub

Sub HistogramIndex(Color As Int, Inc As Int) As Int
	Dim R As Int = GetARGB(Color,1), G As Int = GetARGB(Color,2), B As Int = GetARGB(Color,3), Inc2 As Int = 255/Inc
	R = Floor(R / Inc)
	G = Floor(G / Inc)
	B = Floor(B / Inc)
	Return B + (G*Inc2) + (R*Inc2*Inc2)
End Sub


'if Fontsize<0 then a point will be drawn instead of a bar
Sub DrawHistogram(Dest As Bitmap, HIST As Histogram, Alpha As Int, BGColor As Int, Color As Int, Text As String, Font As Typeface, Fontsize As Int) As Boolean 
	Dim R As Int, G As Int, B As Int, X As Int , ScaleFactor As Float = HIST.Values.Size / HIST.Highest ,Height As Int, BG As Canvas ,UseBars As Boolean = True , UseRainbow As Boolean 
	InitDest(Dest, HIST.Values.Size,HIST.Values.Size)
	If Fontsize<0 Then
		UseBars=False
		Fontsize=Abs(Fontsize)
	End If
	UseRainbow= Color = Colors.Black 
	If Dest.IsInitialized Then
		BG.Initialize2(Dest)
		If BGColor <> Colors.Transparent Then BG.DrawColor(BGColor)
		If Text.Length>0 Then DrawText(BG, Text, HIST.Values.Size*0.5 ,0, Font, Fontsize, Color, 5)
		For X = 0 To HIST.Values.Size-1
			Height = HIST.Values.Get(X) * ScaleFactor
			If UseBars Then Height = Max(1,Height)
			If Height>0 Then
				'Color = Colors.ARGB(Alpha, B,B,B)' Colors.ARGB(Alpha, R,G,B)
				If UseRainbow Then Color = HSLtoRGB( X/Dest.Width*239, 127,127,255)
				If UseBars Then
					BG.DrawLine(X, Dest.Height-1, X, Dest.Height-1-Height, Color, 1)
				Else
					BG.DrawPoint(X, Dest.Height-1-Height, Color)
				End If
				B=B+ HIST.inc 
	'			If B > 255 Then
	'				B=0
	'				G= G + HIST.inc 
	'				If G > 255 Then 
	'					G=0
	'					R = R+ HIST.inc 
	'					If R > 255 Then R = 0
	'				End If
	'			End If
			End If
		Next
		Return True
	End If
End Sub

'Channel: 0=a, 1=r, 2=g, 3=b, 4=BW(lightness), 5=BW(average), 6=BW(luminosity), 7=Hue, 8=Saturation, 9=Value, 10=RGB compressed
Sub GetARGB(Color As Int, Channel As Int) As Int
    Select Case Channel
    	Case 0: Return Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)'A
    	Case 1: Return Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)'R
    	Case 2: Return Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)'G
    	Case 3: Return Bit.And(Color, 0xff)'B
		
		'Black and white
		Case 4: Return ColorToBW(Color, 0)'lightness
		Case 5: Return ColorToBW(Color, 1)'average
		Case 6: Return ColorToBW(Color, 2)'luminosity
		'HSL
		Case 7,8,9
			Dim R As Reflector, HSV(3) As Float
			R.RunStaticMethod("android.graphics.Color", "RGBToHSV", Array As Object(GetARGB(Color,1) , GetARGB(Color,2), GetARGB(Color,3), HSV), Array As String("java.lang.int", "java.lang.int", "java.lang.int", "[F"))
			Return HSV(Channel-7)
		
		Case 10'Histogram index
			Return HistogramIndex(Color,5)
    End Select
End Sub
'METHOD: 0=lightness, 1=average, 2=luminosity
Sub ColorToBW(Color As Int, Method As Int) As Int
	Dim R As Int = GetARGB(Color,1) ,G As Int = GetARGB(Color,2), B As Int = GetARGB(Color,3)
	Select Case Method
		Case 0: Return (Min(Min(R,G),B) + Max(Max(R,G),B)) *0.5 'lightness
		Case 1: Return (R + G + B) / 3'average 
		Case 2: Return (0.21 * R) + (0.71 * G) + (0.07 * B)'luminosity 
	End Select
End Sub

Sub CompareColor(R1 As Int, G1 As Int, B1 As Int, R2 As Int, G2 As Int, B2 As Int) As Int
    Dim dR As Int, dG As Int, dB As Int, dT As Int, OutOf As Int = 255, OneColor As Float = OutOf / (OutOf * 3)
    dR = Abs(R1 - R2)
    dG = Abs(G1 - G2)
    dB = Abs(B1 - B2)
    dT = dR + dG + dB
    Return (dT * OneColor)'OutOf - 
End Sub

Sub CompareColors(Color1 As Int, Color2 As Int) As Int
    Return CompareColor(GetARGB(Color1,1), GetARGB(Color1,2), GetARGB(Color1,3), GetARGB(Color2,1), GetARGB(Color2,2), GetARGB(Color2,3))
End Sub

Sub CompareToBW(Value As Float) As Long
	'Dim temp As Int = Value * 255
    Return Colors.RGB(Value, Value, Value)
End Sub

Sub InitDest(Dest As Bitmap, Width As Int, Height As Int) As Boolean 
	Dim NeedsSizing As Boolean  
	If Height=0 Or Width = 0 Then 
		Log("W/H cannot equal zero")
	Else
		If Dest.IsInitialized Then 
			NeedsSizing = Dest.Width <> Width Or Dest.Height <> Height
		Else
			NeedsSizing=True
		End If
		If NeedsSizing Then Dest.InitializeMutable(Width, Height)
	End If
	Return NeedsSizing
End Sub
Sub CompareImage(CurrentFrame As Bitmap, PreviousFrame As Bitmap, Dest As Bitmap, Pixels As Int) As Boolean 
	Dim BG As Canvas ,X As Int, y As Int ,X2 As Int, Y2 As Int
	If CurrentFrame.IsInitialized And PreviousFrame.IsInitialized Then
		If CurrentFrame.Width = PreviousFrame.Width And CurrentFrame.Height = PreviousFrame.Height Then
			InitDest(Dest, CurrentFrame.Width/Pixels, CurrentFrame.Height/Pixels)
			BG.Initialize2(Dest)
			For y = 0 To CurrentFrame.Height-1 Step Pixels
				X2=0
				For X = 0 To CurrentFrame.Width -1 Step Pixels
					BG.DrawPoint(X2,Y2, CompareToBW(CompareColors( CurrentFrame.GetPixel(X,y),PreviousFrame.GetPixel(X,y))))
					X2=X2+1
				Next
				Y2=Y2+1
			Next
			Return True
		End If
	End If
End Sub

Sub AddImageToAndroid(Dir As String, Filename As String)
	Dim Phone As Phone, i As Intent
	i.Initialize("android.intent.action.MEDIA_SCANNER_SCAN_FILE", "file://" & File.Combine(Dir, Filename))
	Phone.SendBroadcastIntent(i)
End Sub



Sub Max2N(Value As Int)As Int 
	Select Case Value
		Case 2,4,8,16,32,64,128,256,512,1024,2048,4096,8192: Return Value
	End Select
	Dim Current As Int = 1 , tNext As Int 
	Do Until tNext >= Value
		tNext = Current * 2
		If tNext < Value Then Current = tNext
	Loop
	Return tNext
End Sub
Sub CopyRecDataD(SampleRate As Int, recData() As Short) As Double()
	If FFTprev = 0 Then FFTprev = Max2N(recData.Length * 0.5)
	'Log("Step 0 - SampleRate: " & SampleRate & " FFTprev: " & FFTprev)
	Dim N As Int = FFTprev, soundD(N) As Double, temp As Int  'N= recData.Length * 0.5
	For temp = 0 To N -1
		soundD(temp) = recData(temp)
		TimeMin = Min(TimeMin, soundD(temp))
		TimeMax = Max(TimeMax, soundD(temp))
	Next
	N_Samples = N
	CursorScaleFreq = SampleRate / N
	Return soundD
End Sub

Sub PeakDetect(FFTAmp() As Double) As List 
	Dim i As Int, PeakAsc = True As Boolean, N_2 As Int = FFTAmp.Length, FFTPeaks As List 
	
	FFTMax = 0
	For i = 0 To N_2 - 1
		FFTMax = Max(FFTMax, FFTAmp(i))
	Next
	
	FFTLimit = FFTThreshold * FFTMax
	FFTPeaks.Initialize
	For i = 1 To N_2 - 1
		If FFTAmp(i - 1) > FFTLimit Or FFTAmp(i) > FFTLimit  Then
			If PeakAsc = True And FFTAmp(i) < FFTAmp(i - 1) Then
				FFTPeaks.Add((i - 1) * CursorScaleFreq)
				PeakAsc = False
			Else If FFTAmp(i) > FFTAmp(i - 1) Then
				PeakAsc = True
			End If
		Else
			PeakAsc = True
		End If
	Next
	
	Return FFTPeaks
End Sub

Sub RecData2Histogram(SampleRate As Int, recData() As Short) As Histogram ', recData() As Double =  fft1.CopyArray(srcData)
	Dim tempHist As Histogram ,  soundD() As Double = CopyRecDataD(SampleRate, recData), N_2 As Int = soundD.Length * 0.5 ',FFTPeaks As List 
	Dim FFTReal(N_2) As Double, FFTImg(N_2) As Double, FFTAmp(N_2) As Double
	
	tempHist.Initialize 
	tempHist.Values.Initialize 
	
	FFT1.Transform2(soundD, FFTReal, FFTImg )
	FFTAmp = FFT1.ToAmplitude(FFTReal,FFTImg)
	PeakDetect(FFTAmp)
	
	tempHist.Inc = 1
	tempHist.Highest = FFTMax' TimeMax
	tempHist.values.AddAll(FFTAmp)
	
	Return tempHist
End Sub

Sub ClearBMP(BMP As Bitmap, Color As Int)
	Dim BG As Canvas 
	If BMP.IsInitialized Then
		BG.Initialize2(BMP)
		BG.DrawColor(Color)
	End If
End Sub

Sub GetTimeIn(Date As Long, Weeks As String, Days As String, Hours As String, Minutes As String, Seconds As String, Milliseconds As String, Delimeter As String) As String 
	Dim Tempstr As StringBuilder , temp As Int 
	Tempstr.Initialize  
	Date = GetTimeInUnit(Date, Tempstr, DateTime.TicksPerDay * 7, Weeks, Delimeter)
	Date = GetTimeInUnit(Date, Tempstr, DateTime.TicksPerDay, Days, Delimeter)
	Date = GetTimeInUnit(Date, Tempstr, DateTime.TicksPerHour, Hours, Delimeter)
	Date = GetTimeInUnit(Date, Tempstr, DateTime.TicksPerMinute, Minutes, Delimeter)
	Date = GetTimeInUnit(Date, Tempstr, DateTime.TicksPerSecond, Seconds, Delimeter)
	Date = GetTimeInUnit(Date, Tempstr, 1, Milliseconds, Delimeter)
	Return Tempstr.ToString 
End Sub
Sub GetTimeInUnit(Date As Long, tempstr As StringBuilder, Unit As Long, UnitName As String, Delimeter As String) As Long 
	Dim temp As Int 
	If Date >= Unit And UnitName.Length>0 Then
		temp = Floor(Date / Unit)
		tempstr.Append(IIF(tempstr.Length=0, "", Delimeter) & temp & " " & UnitName)
		Date = Date Mod Unit
	End If
	Return Date
End Sub

Sub QueryIntent(Intent1 As Intent, ReturnPackage As Boolean) As List
   Dim R As Reflector, list1 As List, listRes As List
   R.Target = R.GetContext
   R.Target = R.RunMethod("getPackageManager")
   list1 = R.RunMethod4("queryIntentActivities", Array As Object(Intent1, 0), Array As String("android.content.Intent", "java.lang.int"))
   listRes.Initialize
   For i = 0 To list1.Size - 1
      R.Target = list1.Get(i)
      R.Target = R.GetField("activityInfo")
      listRes.Add(R.GetField(IIF(ReturnPackage, "packageName", "name")))
   Next
   Return listRes
End Sub
Sub FindDefaultApp(Intent1 As Intent) As String
   Dim R As Reflector, pm As Object, mInfo As Object
   R.Target = R.GetContext
   pm = R.RunMethod("getPackageManager")
   R.Target = pm
   mInfo = R.RunMethod4("resolveActivity", Array As Object(Intent1, 0), Array As String("android.content.Intent", "java.lang.int"))
   If mInfo = Null Then Return "" 'no activity found
   R.Target = mInfo
   R.Target = R.GetField("activityInfo")
   R.Target = R.GetField("applicationInfo")
   Return R.GetField("packageName")
End Sub
Sub EnumApps(ListID As Int, Mime As String, Default As String, ClearFirst As Boolean, DefaultApp As Boolean)
	Dim pm As PackageManager, Packages As List, temp As Int , I As Intent 
	If Mime.Length = 0 Then 
		Packages = pm.GetInstalledPackages 
	Else 
   		I.Initialize(I.ACTION_VIEW,"")' "content://media/internal/audio/media")' File.Combine(File.DirRootExternal, "test." & Extension))
		I.SetType(Mime)' "audio/*")
		Packages = QueryIntent(I, True)'android.media.action.MEDIA_PLAY_FROM_SEARCH
		If Mime.StartsWith("audio/") Then 
			Packages.Add("com.google.android.music")
			Packages.Add("com.amazon.mp3")
		End If
	End If
	If ClearFirst Then LCAR.LCAR_ClearList(ListID,0)
	If Default.Length>0 Then LCAR.LCAR_AddListItem(ListID, Default, LCAR.LCAR_RandomColor, -1, "", False, "", 0, False,-1)
	If Mime.Length>0 And DefaultApp Then AddPackage(ListID,pm, FindDefaultApp(I))
	For temp = 0 To Packages.Size-1 
		AddPackage(ListID, pm, Packages.Get(temp))
	Next
End Sub
Sub AddPackage(ListID As Int, PM As PackageManager, Package As String) As Int
	If Package.Length>0 And IsPackageInstalled(Package) Then 
		If LCAR.LCAR_FindListItem(ListID, Package, 2, False, -1) = -1 Then
			Return LCAR.LCAR_AddListItem(ListID, PM.GetApplicationLabel(Package).ToUpperCase, LCAR.LCAR_RandomColor, PM.GetVersionCode(Package) Mod 1000, Package, False, PM.GetVersionName(Package), 0, False, -1)
		End If
	End If
	Return -1
End Sub
Sub AppName(Package As String) As String 
	Dim PM As PackageManager 
	If IsPackageInstalled(Package) Then Return PM.GetApplicationLabel(Package) 
End Sub

Sub GetPathFromContentResult(UriString As String) As String
  If UriString.StartsWith("/") Then Return UriString 'If the user used a file manager to choose the image
  Dim Cursor1 As Cursor, Uri1 As Uri, Proj() As String = Array As String("_data"), cr As ContentResolver, res As String
  cr.Initialize("")
  If UriString.StartsWith("content://com.android.providers.media.documents") Then
  	Dim i As Int = UriString.IndexOf("%3A"), id As String = UriString.SubString(i + 3)
  	Uri1.Parse("content://media/external/images/media")
  	Cursor1 = cr.Query(Uri1, Proj, "_id = ?", Array As String(id), "")
  Else
  	Uri1.Parse(UriString)
  	Cursor1 = cr.Query(Uri1, Proj, "", Null, "")
  End If
  Cursor1.Position = 0
  res = Cursor1.GetString("_data")
  Cursor1.Close
  Return res
End Sub

Sub DateDiff(CurrentDate As Long, TimeDate As Long) As String 
	Dim Diff As Long,Text As String 
	Diff = CurrentDate - TimeDate
	If Diff < DateTime.TicksPerMinute Then
		Return GetString("date_submin")
	Else If Diff < DateTime.TicksPerHour Then
		Diff = Floor(Diff / DateTime.TicksPerMinute)
		Text = GetString("date_min")
	Else If Diff < DateTime.TicksPerDay Then
		Diff =  Floor(Diff / DateTime.TicksPerHour)
		Text= GetString("date_hrs")
	Else If Diff< DateTime.TicksPerDay * 7 Then
		Diff = Floor(Diff / DateTime.TicksPerDay)
		Text = GetString("date_days")
	Else If Diff< (DateTime.TicksPerDay * 30) Then
		Diff = Floor(Diff / (DateTime.TicksPerDay*7))
		Text = GetString("date_wks")
	Else If Diff < (DateTime.TicksPerDay * 365) Then
		Diff = Floor(Diff / (DateTime.TicksPerDay*30))
		Text= GetString("date_mths")
	Else
		Diff = Floor(Diff / (DateTime.TicksPerDay*365)) 
		Text = GetString("daye_yrs")
	End If
	If Diff = 1 Then Text = Text.Replace(GetString("plural"), "")
	Return Diff & " " & Text '& " AGO"
End Sub

Sub GetKey(INI As Map, Section As String, Key As String, Default As String) As String 
	Dim INIS As Map = GetSection(INI, Section)
	Return INIS.GetDefault(Key.ToLowerCase, Default)
End Sub
Sub FindSection(INI As Map, Key As String, Value As String) As String
	Dim temp As Int, Section As Map 
	For temp = 0 To INI.Size - 1 
		Section = INI.GetValueAt(temp)
		If Value.EqualsIgnoreCase(Section.getdefault(Key.ToLowerCase, "")) Then Return INI.GetKeyAt(temp)
	Next
	Return ""
End Sub
Sub LoadINI(Contents As String) As Map 
	Dim tempstr() As String , INI As Map,Section As Map,CurrentSection As String, temp As Int ,CurrLine As String 
	tempstr = Regex.Split(CRLF, Contents.Replace("%n%", CRLF))
	INI.Initialize 
	For temp = 0 To tempstr.Length -1 
		CurrLine = Trim(tempstr(temp))
		If CurrLine.Length>0 Then 
			If Left(CurrLine,1) = "[" And Right(CurrLine,1) = "]" Then 'section
				If Section.IsInitialized Then INI.Put(CurrentSection, Section)
				Section.Initialize
				CurrentSection = Mid(CurrLine,1,CurrLine.Length-2)
			Else If Not(Left(CurrLine,1) = "#") And Section.IsInitialized Then'comment
				If CurrLine.Contains("=") Then'KVP
					Section.Put(GetSide2(CurrLine, "=",True).ToLowerCase,  GetSide2(CurrLine, "=",False))
				Else If CurrLine.Length>0 Then
					Section.Put(CurrLine.ToLowerCase, "")
				End If
			End If
		End If
	Next
	If Section.IsInitialized Then INI.Put(CurrentSection, Section)
	Return INI
End Sub
Sub GetSide2(Text As String, Delimeter As String, isLeft As Boolean) As String
	Dim Start As Int = Instr(Text, Delimeter, 0)
	If Start > -1 Then 
		If isLeft Then Return Left(Text, Start)
		Return Right(Text, Text.Length - Start -1)
	End If
End Sub
Sub GetSection(INI As Map, Section As String) As Map 
	Dim temp As Map 
	If INI.ContainsKey(Section) Then Return INI.Get(Section)
	temp.Initialize
	Return temp
End Sub
Sub SplitRange(range As String) As List 
	Dim temp As Int, temp2 As Int, ret As List, tempstr() As String = Regex.Split(",", range.Replace(" ", "")), tempstr2() As String 
	ret.Initialize
	For temp = 0 To tempstr.Length -1 
		If tempstr(temp).Contains("-") And Len(tempstr(temp)) > 1 Then 
			tempstr2 = Regex.Split("-", tempstr(temp))
			If tempstr2.Length = 2 And IsNumber(tempstr2(0)) And IsNumber(tempstr2(1)) Then 
				For temp2 = Min(tempstr2(0), tempstr2(1)) To Max(tempstr2(0), tempstr2(1))
					ret.Add(temp2)
				Next
			End If 
		Else if IsNumber(tempstr(temp)) Then 
			temp2=tempstr(temp)
			ret.Add(temp2)
		Else 
			Select Case tempstr(temp)
				Case "-", "+": ret.Add(tempstr(temp))
			End Select
		End If
	Next
	Return ret 
End Sub


Sub AddNFCtag(ndef As String) As Boolean 
	If NFCtags.IndexOf(ndef) = -1 Then 
		NFCtags.Add(ndef)
		Return True 
	End If
End Sub
Sub LoadNFCtags(Save As Boolean)
	Dim temp As Int, Count As Int 
	If Save Then 
		Main.Settings.Put("nfctags", NFCtags.Size)
		For temp = 0 To NFCtags.Size - 1 
			Main.Settings.put("nfctag" & temp, NFCtags.Get(temp))
		Next
	Else if Main.Settings.IsInitialized Then 'load
		NFCtags.Initialize 
		Count = Main.Settings.GetDefault("nfctags", 0)
		For temp = 0 To Count - 1 
			NFCtags.Add( Main.Settings.Get("nfctag" & temp) )
		Next
	Else 
		LogColor("WHY ARENT THE SETTINGS LOADED?", Colors.red)
	End If
End Sub
''GetTasks: True=activities, False=Services
'Sub EnumTasks(GetTasks As Boolean) As List 
'	Dim Tasks As List, OS As OperatingSystem ,r As Reflector, I As Int ,tempstr As String
'	If GetTasks Then
'		Tasks=OS.getRunningTasks(1000)
'	Else
'		Tasks =OS.getRunningServices(1000)'
'	End If
'	If Tasks.Size > 0 Then
'	    For I = 0 To Tasks.Size - 1
'	        r.Target = Tasks.Get(I)
'			If GetTasks Then 
'				tempstr=r.GetField("baseActivity")
'			Else'android.app.ActivityManager$RunningServiceInfo@2afd91e0
'				tempstr = r.GetField("service")'Service: ComponentInfo{com.sonyericsson.lockscreen.notifications/com.sonyericsson.lockscreen.notifications.services.MissedCallsService}
'				tempstr= Mid(tempstr, 14, tempstr.Length-15)
'				tempstr=GetSide(tempstr, "/", False,False)
'				'tempstr=r.GetField("process") 'Tasks.Get(i)
'			End If
'			Tasks.Set(I, tempstr)
'	    Next
'	End If
'	Return Tasks
'End Sub


'Sub IsLocationON As Boolean 
'	Dim p As Phone, tempstr As String 
'	If APIlevel > 18 Then
'		tempstr = p.GetSettings("LOCATION_MODE") 
'	Else 
'		tempstr = p.GetSettings("location_providers_allowed")
'	End If
'	Log(APIlevel & ": " & tempstr)
'	If tempstr.Length>0 Then 
'		If tempstr.EqualsIgnoreCase("LOCATION_MODE_OFF") Then Return False
'		Return True
'	End If
'End Sub


'all intents
'android.intent.action.ASSIST opens google now
'android.app.action.ACTION_PASSWORD_CHANGED
'android.app.action.ACTION_PASSWORD_EXPIRING
'android.app.action.ACTION_PASSWORD_FAILED
'android.app.action.ACTION_PASSWORD_SUCCEEDED
'android.app.action.DEVICE_ADMIN_DISABLED
'android.app.action.DEVICE_ADMIN_DISABLE_REQUESTED
'android.app.action.DEVICE_ADMIN_ENABLED
'android.bluetooth.a2dp.profile.action.CONNECTION_STATE_CHANGED
'android.bluetooth.a2dp.profile.action.PLAYING_STATE_CHANGED
'android.bluetooth.adapter.action.CONNECTION_STATE_CHANGED
'android.bluetooth.adapter.action.DISCOVERY_FINISHED
'android.bluetooth.adapter.action.DISCOVERY_STARTED
'android.bluetooth.adapter.action.LOCAL_NAME_CHANGED
'android.bluetooth.adapter.action.SCAN_MODE_CHANGED
'android.bluetooth.adapter.action.STATE_CHANGED
'android.bluetooth.device.action.ACL_CONNECTED
'android.bluetooth.device.action.ACL_DISCONNECTED
'android.bluetooth.device.action.ACL_DISCONNECT_REQUESTED
'android.bluetooth.device.action.BOND_STATE_CHANGED
'android.bluetooth.device.action.CLASS_CHANGED
'android.bluetooth.device.action.FOUND
'android.bluetooth.device.action.NAME_CHANGED
'android.bluetooth.device.action.UUID
'android.bluetooth.devicepicker.action.DEVICE_SELECTED
'android.bluetooth.devicepicker.action.LAUNCH
'android.bluetooth.headset.action.VENDOR_SPECIFIC_HEADSET_EVENT
'android.bluetooth.headset.profile.action.AUDIO_STATE_CHANGED
'android.bluetooth.headset.profile.action.CONNECTION_STATE_CHANGED
'android.bluetooth.input.profile.action.CONNECTION_STATE_CHANGED
'android.bluetooth.pan.profile.action.CONNECTION_STATE_CHANGED
'android.hardware.action.NEW_PICTURE
'android.hardware.action.NEW_VIDEO
'android.hardware.input.action.QUERY_KEYBOARD_LAYOUTS
'android.Intent.action.ACTION_POWER_CONNECTED
'android.Intent.action.ACTION_POWER_DISCONNECTED
'android.Intent.action.ACTION_SHUTDOWN
'android.Intent.action.AIRPLANE_MODE
'android.Intent.action.BATTERY_CHANGED
'android.Intent.action.BATTERY_LOW
'android.Intent.action.BATTERY_OKAY
'android.Intent.action.BOOT_COMPLETED
'android.Intent.action.CAMERA_BUTTON
'android.Intent.action.CONFIGURATION_CHANGED
'android.Intent.action.DATA_SMS_RECEIVED
'android.Intent.action.DATE_CHANGED
'android.Intent.action.DEVICE_STORAGE_LOW
'android.Intent.action.DEVICE_STORAGE_OK
'android.Intent.action.DOCK_EVENT
'android.Intent.action.EXTERNAL_APPLICATIONS_AVAILABLE
'android.Intent.action.EXTERNAL_APPLICATIONS_UNAVAILABLE
'android.Intent.action.FETCH_VOICEMAIL
'android.Intent.action.GTALK_CONNECTED
'android.Intent.action.GTALK_DISCONNECTED
'android.Intent.action.HEADSET_PLUG
'android.Intent.action.INPUT_METHOD_CHANGED
'android.Intent.action.LOCALE_CHANGED
'android.Intent.action.MANAGE_PACKAGE_STORAGE
'android.Intent.action.MEDIA_BAD_REMOVAL
'android.Intent.action.MEDIA_BUTTON
'android.Intent.action.MEDIA_CHECKING
'android.Intent.action.MEDIA_EJECT
'android.Intent.action.MEDIA_MOUNTED
'android.Intent.action.MEDIA_NOFS
'android.Intent.action.MEDIA_REMOVED
'android.Intent.action.MEDIA_SCANNER_FINISHED
'android.Intent.action.MEDIA_SCANNER_SCAN_FILE
'android.Intent.action.MEDIA_SCANNER_STARTED
'android.Intent.action.MEDIA_SHARED
'android.Intent.action.MEDIA_UNMOUNTABLE
'android.Intent.action.MEDIA_UNMOUNTED
'android.Intent.action.MY_PACKAGE_REPLACED
'android.Intent.action.NEW_OUTGOING_CALL
'android.Intent.action.NEW_VOICEMAIL
'android.Intent.action.PACKAGE_ADDED
'android.Intent.action.PACKAGE_CHANGED
'android.Intent.action.PACKAGE_DATA_CLEARED
'android.Intent.action.PACKAGE_FIRST_LAUNCH
'android.Intent.action.PACKAGE_FULLY_REMOVED
'android.Intent.action.PACKAGE_INSTALL
'android.Intent.action.PACKAGE_NEEDS_VERIFICATION
'android.Intent.action.PACKAGE_REMOVED
'android.Intent.action.PACKAGE_REPLACED
'android.Intent.action.PACKAGE_RESTARTED
'android.Intent.action.PHONE_STATE
'android.Intent.action.PROVIDER_CHANGED
'android.Intent.action.PROXY_CHANGE
'android.Intent.action.REBOOT
'android.Intent.action.SCREEN_OFF
'android.Intent.action.SCREEN_ON
'android.Intent.action.TIMEZONE_CHANGED
'android.Intent.action.TIME_SET
'android.Intent.action.TIME_TICK
'android.Intent.action.UID_REMOVED
'android.Intent.action.USER_PRESENT
'android.Intent.action.WALLPAPER_CHANGED
'android.media.ACTION_SCO_AUDIO_STATE_UPDATED
'android.media.AUDIO_BECOMING_NOISY
'android.media.RINGER_MODE_CHANGED
'android.media.SCO_AUDIO_STATE_CHANGED
'android.media.VIBRATE_SETTING_CHANGED
'android.media.action.CLOSE_AUDIO_EFFECT_CONTROL_SESSION
'android.media.action.OPEN_AUDIO_EFFECT_CONTROL_SESSION
'android.net.conn.BACKGROUND_DATA_SETTING_CHANGED
'android.net.nsd.STATE_CHANGED
'android.net.wifi.NETWORK_IDS_CHANGED
'android.net.wifi.RSSI_CHANGED
'android.net.wifi.SCAN_RESULTS
'android.net.wifi.STATE_CHANGE
'android.net.wifi.WIFI_STATE_CHANGED
'android.net.wifi.p2p.CONNECTION_STATE_CHANGE
'android.net.wifi.p2p.DISCOVERY_STATE_CHANGE
'android.net.wifi.p2p.PEERS_CHANGED
'android.net.wifi.p2p.STATE_CHANGED
'android.net.wifi.p2p.THIS_DEVICE_CHANGED
'android.net.wifi.supplicant.CONNECTION_CHANGE
'android.net.wifi.supplicant.STATE_CHANGE
'android.provider.Telephony.SIM_FULL
'android.provider.Telephony.SMS_CB_RECEIVED
'android.provider.Telephony.SMS_EMERGENCY_CB_RECEIVED
'android.provider.Telephony.SMS_RECEIVED
'android.provider.Telephony.SMS_REJECTED
'android.provider.Telephony.SMS_SERVICE_CATEGORY_PROGRAM_DATA_RECEIVED
'android.provider.Telephony.WAP_PUSH_RECEIVED
'android.speech.TTS.TTS_QUEUE_PROCESSING_COMPLETED
'android.speech.TTS.engine.TTS_DATA_INSTALLED

Sub Shutdown(Reboot As Boolean)
    Dim ph As Phone,Command As String, Runner As String, StdOut As StringBuilder, StdErr As StringBuilder
    StdOut.Initialize
    StdErr.Initialize
    Runner = File.Combine(File.DirInternalCache, "runner")
    Command = File.Combine(File.DirInternalCache, "command")
    File.WriteString(File.DirInternalCache, "runner", "su < " & Command)
    File.WriteString(File.DirInternalCache, "command", "su -c reboot" & IIF(Reboot, "", " -p"))
    ph.Shell("sh", Array As String(Runner), StdOut, StdErr)   
End Sub


Sub GetWordRelative(Text() As String, Word As String, Start As Int, LeftSide As Boolean, Default As String) As String 
	Dim temp As Int = FindWord(Text, Word, Start)
	If LeftSide Then
		If temp>0 Then Return Text(temp-1)
	Else
		If temp < Text.Length-1 Then Return Text(temp+1)
	End If
	Return Default
End Sub

Sub ToSeconds(Text As String) As Int 
	Dim JustNumbers As String, tempstr As String, Command() As String = Regex.Split(" ", Eval.VReplace(Text,True)), temp As Int, temp2 As Int
	For temp = 0 To Command.Length - 1 
		JustNumbers = Command(temp).trim.Replace(":", "")
		If IsNumber(JustNumbers) And Command(temp).Contains(":") Then 
			Return GetTimeReverse(JustNumbers)'"00:00" Or "00:00:00"
		End If 
	Next 
	
	Dim Words() As String = Array As String(GetString("date_week").ToLowerCase, 	GetString("date_day").ToLowerCase, 		GetString("date_hour").ToLowerCase, 	GetString("date_minute").ToLowerCase, 	GetString("date_second").ToLowerCase)
	Dim Times() As Int = Array As Int(      604800, 	86400, 		3600, 		60, 		1)
	temp=0
	For temp2 = 0 To Words.Length - 1 
		tempstr = GetWordRelative(Command, Words(temp2) & "s", 0, True, GetWordRelative(Command, Words(temp2), 0, True, ""))
		If IsNumber(tempstr) Then temp = temp + (Times(temp2) * tempstr)
	Next
	Return temp
End Sub
Sub CommaDelimit(TheList As List) As String 
	Dim temp As Int, tempstr As StringBuilder, Delimiter As String = GetString("delimiter") & " ", LastDelimiter As String = " " & GetString("last_delimiter") & " "
	tempstr.Initialize
	For temp = 0 To TheList.Size - 1
		If temp = 0 Then 
			tempstr.Append(TheList.Get(temp))
		else if temp = TheList.Size - 1 Then 
			tempstr.Append(LastDelimiter & TheList.Get(temp))
		Else 
			tempstr.Append(Delimiter & TheList.Get(temp))
		End If
	Next
	Return tempstr.ToString
End Sub

'bType: -1=all, 0=(), 1={}, 2=[], 3=<>
Sub RemoveBrackets(Text As String, bType As Int) As String 
	Dim tempL As Int, tempR As Int, Ls As String, Rs As String 
	Select Case bType 
		Case -1
			For bType = 0 To 3
				Text = RemoveBrackets(Text, bType)
			Next
			Return Text 
		Case 0
			Ls="("
			Rs=")"
		Case 1
			Ls="{"
			Rs="}"
		Case 2
			Ls="["
			Rs="]"
		Case 3
			Ls="<"
			Rs=">"
	End Select
	tempL = Text.IndexOf(Ls)
	If tempL > -1 Then 
		tempR = Text.IndexOf2(Rs, tempL)
		If tempR > -1 Then Text = Left(Text, tempL - 1) & Right(Text, Text.Length - tempR - 1)
	End If
	Return Text.Trim 
End Sub

Sub isLike(Text As String, Pattern As String) As Boolean
	If Not(Pattern.StartsWith("^") And Pattern.EndsWith("$")) Then'is not a regular expression
		If Pattern.Contains("*") Or Pattern.Contains("?") Then 'is a DOS wildcard
			Pattern = "^" & RegexEscape(Pattern).Replace("\*", ".*").Replace("\?", ".") & "$"
		Else 'is not a regular expression, and is not a DOS wildcard
			Return Text.ToLowerCase.Contains(Pattern.ToLowerCase)
		End If 
	End If
	Return Regex.IsMatch(Pattern, Text)
End Sub

Sub RegexEscape(Text As String) As String'\ ^ $ . | ? * + ( ) [ {
	Dim temp As Int, tempstr As StringBuilder, Letter As String
	tempstr.Initialize
	For temp = 0 To Text.Length - 1
		Letter = Mid(Text, temp,1)
		Select Case Letter 
			Case "\", "^", "$", ".", "|", "?", "*", "+", "(", ")", "[", "{": Letter = "\" & Letter 
		End Select
		tempstr.Append(Letter)
	Next
	Return tempstr.ToString
End Sub

Sub Implode(glue As String, items As List) As String 
   Dim result As StringBuilder
   If items.Size = 0 Then Return ""
   If items.Size = 1 Then Return items.get(0)
   result.Initialize
   result.Append(items.get(0))
   For i=1 To items.Size-1
      result.Append(glue & items.get(i))
   Next
   Return result.ToString
End Sub