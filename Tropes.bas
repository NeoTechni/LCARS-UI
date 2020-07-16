B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Code module SITE IS NO LONGER IN OPERATION!!!! NONE OF THIS WORKS ANYMORE AS I COULD NOT AFFORD THE URL
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim WebRoot As String = "http://www.lcarsui.com/tropes/ajax/"
	
	Dim Series As Map, Messages As Map, Episodes As Map, CurrentEpisode As Map, ShowSpoilers As Boolean, TropesList As Map  
	Dim CurrentSection As Int, CurrentSeries As String, CurrentSeason As Int, CurrentEpisodeID As Int, MyProfile As Map, CurrentEpisodeIndex As Int 
	Dim CurrentSearch As String, CurrentOffset As Int, Limit As Int= 25, ReturnTo As Int, CurrentTrope As Int, CurrentTropeID As Int
	Dim ColorYES As String = "[YES]", RecentChanges As Map 
End Sub

Sub SetElement18Text(Text As String) 
	Games.SetElement18Text(Text.ToUpperCase)
End Sub
Sub Toast(Text As String)
	Games.Toast(Text)
End Sub
Sub SeedSetting(Name As String, Description As String, CurrentValue As String) As Int 
	Return Games.SeedSetting(Name.ToUpperCase, Description, CurrentValue.ToUpperCase)
End Sub
Sub SetINIColor(ListItem As Int, INIfilename As String)
	Dim YEScolor As Int = LCAR.LCAR_Purple, NOcolor As Int = LCAR.LCAR_Red, ColorID As Int = NOcolor
	If INIfilename = ColorYES Then 
		ColorID = YEScolor 
	Else if INIfilename.Length > 0 Then 
		ColorID = API.IIF(INIexists(INIfilename), YEScolor, NOcolor)
	End If
	LCAR.LCAR_GetListItem(3, ListItem).ColorID = ColorID 
End Sub
Sub ClearList
	LCAR.LCAR_ClearList(3,0)
End Sub
Sub SeedButtonBar(Items As List)
	LCAR.SeedButtonBar(LCAR.EmergencyBG, Items)
End Sub
Sub HideButtonMenu
	LCAR.HideButtonBar(LCAR.EmergencyBG)
End Sub

Sub IsConnected As Boolean
	If API.IsConnected Then Return True 
	Toast(API.getstring("offline"))
End Sub

Sub DownloadFile(URL As String, Post As String) As Boolean 
	Dim DeviceID As String = API.DeviceID 
	If IsConnected Then 
		If Not(URL.Contains("://")) Then URL = WebRoot & URL 
		If Post.Length = 0 Then 
			Post = "deviceid=" & DeviceID
		Else 
			Post = Post & "&deviceid=" & DeviceID
		End If
		'Log("POST=" & Post)
		API.PostString("tropes", URL, Post)
		Toast(API.getstring("loading"))
		'Dim job As HttpJob job.PostString( 
		Return True
	End If
End Sub

Sub JobDone (URL As String, HTML As String)
	Dim INI As Map = API.LoadINI(HTML)
	URL = API.Right(URL, URL.Length - WebRoot.Length)
	'Log("Tropes.JobDone")
	'Log("WebRoot=" & WebRoot)
	'Log("URL=" & URL)
	'Log("INI")
	'Log(INI)
	'Log("HTML=" & HTML)
	LCAR.HideToast 
	Select Case URL
		Case "login"
			Messages= INI
			EnumSeries
		Case "enumseries"
			Series = INI 
			SaveINI("series", HTML, INI)
			ShowMenu(0)
		Case "enumepisodes"
			Episodes= INI
			SaveINI(CurrentSeries & CurrentSeason, HTML, INI)
			ShowMenu(4)
		Case "searchepisode"
			Episodes= INI
			ShowMenu(4)
		Case "enumepisodetropes"
			CurrentEpisode = INI 
			SaveINI("episode" & CurrentEpisodeID, HTML,INI)
			ShowMenu(5)
		Case "getprofile"
			MyProfile = INI
			SaveINI("profile", HTML,INI)
			ShowMenu(6)
		Case "enumtropes"
			TropesList = INI
			SaveINI("tropes", HTML,INI)
			ShowMenu(7)
		Case "viewtrope"
			Episodes = INI
			SaveINI("trope" & CurrentTrope, HTML,INI)
			ShowMenu(8)
		Case "edittrope", "editepisodetrope"
			INI = API.GetSection(INI, "Status")
			If "true".EqualsIgnoreCase(INI.Get("status")) Then
				Toast(INI.Get("reason"))
			Else
				Toast("Error:" & CRLF & INI.Get("reason"))
			End If
		Case "recentchanges"
			RecentChanges = INI 
			ShowMenu(9)
		Case "sendmessage"
			Toast("MESSAGE SENT")
	End Select
End Sub

Sub Login
	Dim shipname As String = Main.Starshipname, captainname As String = Main.YourName, registry As String = Main.StarshipID, Class As String = API.Model(1), Emailaddress As String = Main.Settings.GetDefault("EMAILaddress", "")
	If shipname.Length = 0 Then shipname = "UNNAMED"
	If captainname.Length = 0 Then captainname = "UNNAMED"
	If Emailaddress.Length = 0 Then 
		Emailaddress = "UNSPECIFIED"
	else If Not(Emailaddress.Contains("@")) Then 
		Emailaddress = Emailaddress & "@gmail.com"
	End If
	DownloadFile("login", "shipname=" & shipname & "&captainname=" & captainname & "&registry=" & registry & "&class=" & Class & "&email=" & Emailaddress & "&version=" & API.Model(5))
End Sub

Sub INIexists(Filename As String) As Boolean 
	Return File.Exists(LCAR.DirDefaultExternal, Filename & ".ini") 
End Sub

Sub EnumSeries
	Dim Filename As String = "series"
	If INIexists(Filename) Then Series = ReadINI(Filename)
	If Series.IsInitialized Then 
		ShowMenu(0)'ShowSeries
	Else 
		DownloadFile("enumseries", "")
	End If 
End Sub

Sub SearchEpisode(SearchFor As String)
	DownloadFile("searchepisode", "search=" & SearchFor)
End Sub

Sub ShowMenu(Section As Int)
	Dim temp As Int,  Count As Int, INIS As Map, tempstr As String, DOIT As Boolean  
	ClearList
	HideButtonMenu
	Select Case Section
		Case 3, 4, 7'seasons, episodes, episode, trope
			tempstr = API.IIF(LCAR.SmallScreen, "SRCH", "SEARCH")
	End Select
	Select Case Section 
		Case 5, 8
		Case Else: CallSub(Main, "HideWebview")
	End Select
	CallSub(Main, "HideSubSettings")
	LCAR.LCAR_SetElementText(LCARSeffects.FrameElement, tempstr, "")
	LCAR.IsClean = False
	'LCAR.HideToast 
	Select Case Section
		Case 0'main
			ReturnTo=0
			SetElement18Text("OFFLINE MODE")
			If Messages.IsInitialized Then
				If Not(Messages.ContainsKey("Status")) Then temp = Messages.Size 
				SetElement18Text("YOU HAVE " & API.IIF(temp=0, "NO", temp) & " MESSAGE" & API.IIF(temp=1, "", "S"))
			End If
			SetINIColor(SeedSetting("YOUR STATS", "YOUR PROFILE DATA", ""), "profile")
			SetINIColor(SeedSetting("YOUR MESSAGES", "YOUR MESSAGES", ""), "")
			SetINIColor(SeedSetting("SERIES", "VIEW THE EPISODES/MOVIES OF A SERIES", ""), "series")
			SetINIColor(SeedSetting("TROPES", "VIEW THE LIST OF TROPES", ""), "")
			SetINIColor(SeedSetting("RECENT CHANGES", "RECENT CHANGES", ""), "")
			SetINIColor(SeedSetting("HELP", "", ""), "")
		
		Case 1'series
			SetElement18Text("SELECT A SERIES")
			For temp = 0 To Series.Size - 1 
				INIS = Series.GetValueAt(temp)
				SetINIColor(SeedSetting(INIS.get("name"), INIS.get("description"), INIS.get("acronym")),ColorYES)
			Next
		
		Case 2'messages
			If Not(Messages.ContainsKey("Status")) Then temp = Messages.Size
			SeedButtonBar(Array As String("DEL", "SEND"))
			If Messages.Size = 0 Then 
				SetElement18Text("YOU HAVE NO MESSAGES")			
			Else 
				For temp = 0 To Messages.Size - 1 
					INIS = Messages.GetValueAt(temp)
					If INIS.ContainsKey("message") Then 
						SetINIColor(SeedSetting(INIS.Get("message"), INIS.Get("message"), ""), ColorYES)
					End If 
				Next
			End If 
		
		Case 3'seasons
			tempstr = API.FindSection(Series, "acronym", CurrentSeries)
			INIS = API.GetSection(Series, tempstr)
			Count = INIS.GetDefault("seasons", 1)
			If Count = 1 Then
				enumEpisodes(CurrentSeries, 1)
			Else
				SetElement18Text("SELECT A SEASON OF " & FindSeriesKey(-1, "name"))
				For temp = 1 To Count 
					SetINIColor(SeedSetting("SEASON " & temp, "", temp), CurrentSeries & temp)
				Next
			End If
		
		Case 4'episodes
			If CurrentSection=3 Then
				tempstr = API.GetKey(Series, API.FindSection(Series, "acronym", CurrentSeries), "name", "")
				SetElement18Text("SEASON " & CurrentSeason & " OF " & tempstr)
				For temp = 0 To Episodes.Size - 1 
					INIS = Episodes.GetValueAt(temp)
					Count = INIS.Get("tropes")
					SetINIColor(SeedSetting( INIS.Get("name") & " - [" & Count & " TROPE" & API.IIF(Count = 1, "", "S") & "]", Episodes.GetKeyAt(temp), INIS.Get("episode")), "episode" & Episodes.GetKeyAt(temp))
				Next
			Else
				EnumEpisodeTropes(CurrentEpisodeID)
			End If
		
		Case 5'episode
			SeedButtonBar(Array As String("SPL", "ADD"))
			LoadEpisode
		
		Case 6'profile
			SetElement18Text("YOUR STATS")
			For temp = 0 To MyProfile.Size - 1 
				INIS = MyProfile.GetValueAt(temp)
				For Count = 0 To INIS.Size - 1
					SetINIColor(SeedSetting(INIS.GetKeyAt(Count) , INIS.GetKeyAt(Count) & " = " & INIS.GetValueAt(Count), INIS.GetValueAt(Count)), "")
				Next
			Next
			SeedSetting("DEVICE ID", "YOUR DEVICE'S UNIQUE ID", API.DeviceID)
		
		Case 7'tropes
			SetElement18Text("TROPES")
			SeedButtonBar(Array As String("<<", "<", ">", ">>"))
			If TropesList.IsInitialized Then 
				If CurrentSearch.Length > 0 Then
					SetElement18Text("SEARCH FOR '" & CurrentSearch & "'")
					SetINIColor(SeedSetting("[CLEAR SEARCH]", "", ""), "")
				End If
				SetINIColor(SeedSetting("[MAKE TROPE]", "", ""), "")
				For temp = 0 To TropesList.Size - 1 
					INIS = TropesList.GetValueAt(temp)
					tempstr = TropesList.GetKeyAt(temp)
					DOIT = IsNumber(tempstr)
					If ReturnTo = 5 And DOIT And CurrentEpisode.IsInitialized Then 
						tempstr = API.FindSection(CurrentEpisode, "tropeid", tempstr)
						DOIT = tempstr.Length=0'do not list tropes it has already
					End If
					If DOIT Then
						tempstr = TropesList.GetKeyAt(temp)
						SetINIColor(SeedSetting( INIS.Get("name"), INIS.Get("title"), tempstr), "trope" & tempstr)
					End If
				Next
			Else
				LoadTropes("",CurrentOffset)
			End If
		
		Case 8'trope
			LoadTrope
		
		Case 9'recent changes
			If RecentChanges.IsInitialized Then
				'URLclicked
				For temp = 0 To RecentChanges.Size - 1 
					INIS = RecentChanges.GetValueAt(temp)
					SetINIColor(SeedSetting(  INIS.Get("title"), INIS.Get("link"), INIS.Get("date")), "")
				Next
			End If
	End Select
	CurrentSection=Section
End Sub

Sub Ask(Title As String, tMessage As String, Default As String) As String 
	If Title = "[MULTI]" Then Title = "[MULTI]TREK TROPES"
	If Title.Length = 0 Then Title = "TREK TROPES"
	Main.speaktext = Title
	Return CallSub3(Main, "Ask2", tMessage, Default) 
End Sub
Sub Messagebox(tMessage As String, Title As String, Positive As String, Cancel As String, Negative As String) As Int 
	If Title.Length = 0 Then Title = "TREK TROPES"
	Return CallSub2(Main, "qMSG", Array As String(tMessage, Title, Positive, Cancel, Negative))
End Sub

Sub HandleSetting(ListID As Int, Index As Int) As Boolean 
	Dim SettingIndex As Int, SubItems As List, tempitem As LCARlistitem, Value As String
	If ListID = 3 Or ListID = 4 Then 
		tempitem=LCAR.LCAR_GetListItem(ListID, Index)
		Value = tempitem.Text
	End If
	Select Case ListID
		Case 0'hardware button
			Select Case Index
				Case 4'back
					SettingIndex = 0
					Select Case CurrentSection
'						Case 3'seasons
'							SettingIndex = API.GetKey(Series, API.FindSection(Series, "acronym", CurrentSeries), "seasons", "1")
'							If SettingIndex = 1 Then 
'								SettingIndex = 0
'							Else 
'								SettingIndex = 
'							End If
						Case 4: SettingIndex=3'episodes to seasons
						'Case 5: SettingIndex=4'episode to episodes
						Case 8: SettingIndex=7'trope to tropes
					End Select 
					Log("BACK: " & CurrentSection & " - " & SettingIndex)
					ShowMenu(SettingIndex)
				Case 74'search button
					If IsConnected Then 
						Select Case CurrentSection
							Case 3,4: Value= "EPISODE"
							Case 7: Value = "TROPE"
						End Select
						If Value.Length > 0 Then 
							CurrentSearch = Ask("", "WHAT " & Value & " WOULD YOU LIKE TO SEARCH FOR?", CurrentSearch)	
							If CurrentSearch.Length>0 Then 
								CallSub(Main, "HideWebview")
								Log("SEARCH " & CurrentSection & " FOR: " & CurrentSearch)
								Select Case CurrentSection
									Case 3,4,5: 	SearchEpisode(CurrentSearch)
									Case 7:			LoadTropes(CurrentSearch, 0)
								End Select
							End If
						End If
					End If
			End Select
		Case 3'master list
			Select Case CurrentSection' & "." & Index
				Case 0'main
					Select Case Index 
						Case 0: LoadProfile'stats
						Case 1: ShowMenu(2)'messages
						Case 2:	ShowMenu(1)'show series
						Case 3: ShowMenu(7)'tropes
						Case 4: DownloadFile("recentchanges", "")
						Case 5: CallSub3(Main, "ShowSection",  Main.CurrentSection, True)
					End Select
					
				Case 1'series
					CurrentSeries = tempitem.side
					ShowMenu(3)

				Case 3'seasons
					enumEpisodes(CurrentSeries, tempitem.side)
				
				Case 4'episodes
					EnumEpisodeTropes(tempitem.Tag)
				
				Case 7'tropes
					If tempitem.Side.Length = 0 Then 
						Select Case tempitem.Text
							Case "[CLEAR SEARCH]": LoadTropes("", 0)'clear
							Case "[MAKE TROPE]":	SendSuggestion("newtrope", 0, Ask("", "WHAT WOULD YOU LIKE TO NAME THIS TROPE?", ""))'make trope
						End Select
						
					else If ReturnTo = 5 Then 
						If IsConnected Then
							Value = Ask("[MULTI]", "PLEASE DESCRIBE THE '" & tempitem.Text & "' EVENT:", "")
							If Value.Length>0 Then SendSuggestion("addepisodetrope", tempitem.Side, Value)
							ShowMenu(5)		
						End If
					Else 
						CurrentTrope = tempitem.Side
						SubItems = Array As String("VIEW", "EDIT NAME", "EDIT DESC.")
					End If
					
				Case 9
					URLclicked(tempitem.Tag)
			End Select
			If SubItems.IsInitialized Then LCAR.LCAR_AddListItems(4, LCAR.LCAR_Random,0, SubItems)
		Case 4'sub items
			tempitem = LCAR.LCAR_GetListItem(3, Main.SettingIndex) 
			Select Case CurrentSection
				Case 7'tropes
					Select Case Index
						Case 0'view
							ViewTrope(CurrentTrope)
						Case 1'edit NAME
							Value = Ask("", "WHAT WOULD YOU LIKE TO CHANGE '" & tempitem.Text & "' TO?", tempitem.Text)
							If Value.Length>0 And Not(Value.EqualsIgnoreCase(tempitem.Text)) Then  SendSuggestion("tropename", CurrentTrope, Value)								
						Case 2'edit DESCRIPTION
							Value = Ask("[MULTI]", "WHAT WOULD YOU LIKE TO CHANGE '" & tempitem.Text & "' TO?", tempitem.Tag)
							If Value.Length>0 And Not(Value.EqualsIgnoreCase(tempitem.Text)) Then  SendSuggestion("tropedesc", CurrentTrope, Value)	
					End Select
			End Select
		Case 5'button menu
			Select Case CurrentSection 
				Case 2'messages
					Select Case Index
						Case 0'DEL
							If DownloadFile("deletemessages", "") Then
								ClearList
								Toast("MESSAGES DELETED")
							End If
						Case 1'SND
							Value=Ask("[MULTI]", "WHAT MESSAGE WOULD YOU LIKE TO SEND ME?", "")
							If Value.Length>0 Then SendSuggestion("message", 1, Value)
					End Select
				Case 5'episode
					Select Case Index
						Case 0'SPL
							ShowSpoilers = Not(ShowSpoilers)
							LoadEpisode
						Case 1'ADD
							ReturnTo = 5
							ShowMenu(7)
					End Select
				Case 7'tropes
					TropeDirection(Index)
				Case 8
					Select Case Index
						Case 0'SPL
							ShowSpoilers = Not(ShowSpoilers)
							LoadTrope
						Case 1'add
							SendSuggestion("newtrope", 0, Ask("", "WHAT WOULD YOU LIKE TO NAME THIS TROPE?", ""))
					End Select
			End Select
	End Select
	Return SubItems.IsInitialized
End Sub

Sub enumEpisodes(tSeries As String, Season As Int)
	Dim Filename As String = tSeries & Season
	CurrentSeason = Season
	If INIexists(Filename) Then
		Episodes = ReadINI(Filename)
		ShowMenu(4)
	Else
		DownloadFile("enumepisodes", "series=" & tSeries & "&season=" & Season)
	End If
End Sub

Sub SaveINI(Filename As String, INI As String, INImap As Map)
	If Not(INImap.ContainsKey("Status")) Then 
		File.WriteString(LCAR.DirDefaultExternal, Filename & ".ini", INI)
	End If
End Sub

Sub ReadINI(Filename As String) As Map 
	Return API.LoadINI(File.ReadString(LCAR.DirDefaultExternal, Filename & ".ini"))
End Sub

Sub EnumEpisodeTropes(EpisodeID As Int) 
	If EpisodeID = 0 Then 
		EpisodeID = API.FindSection(Episodes, "episode", CurrentEpisodeIndex)
		Log("Attempt to find episode: " & EpisodeID)
	End If
	CurrentEpisodeID = EpisodeID
	If API.IsConnected Then
		DownloadFile("enumepisodetropes", "episode=" & EpisodeID)
	Else If INIexists("episode" & EpisodeID) Then
		CurrentEpisode = ReadINI("episode" & EpisodeID)
		ShowMenu(5)
	End If
End Sub

Sub FileAge(Filename As String) As Long
	Dim Debugging As Boolean = True
	If File.Exists(LCAR.DirDefaultExternal, Filename) And Not(Debugging) Then 
		Return DateTime.Now - File.LastModified(LCAR.DirDefaultExternal, Filename)
	End If
	Return DateTime.TicksPerDay * 365 
End Sub

Sub LoadProfile
	If FileAge("profile.ini") > DateTime.TicksPerDay Then 
		DownloadFile("getprofile", "")
	Else
		MyProfile = ReadINI("profile")
		ShowMenu(6)
	End If
End Sub

Sub TropeDirection(Direction As Int)
	Dim Count As Int = API.GetKey(TropesList, "Status", "count", 0)
	Log("Direction: " & Direction)
	Select Case Direction
		Case 0: Direction=0'<<
		Case 1: Direction=CurrentOffset-Limit'<
		Case 2: If CurrentOffset+Limit < Count Then Direction = CurrentOffset + Limit Else Direction = CurrentOffset '>
		Case 3: Direction = Floor(Count/Limit)*Limit '>>
	End Select
	Direction = Min(Max(0,Direction),Count)
	'Log("Before: " & CurrentOffset & " After: " & Direction & " Limit: " & Limit & " Count: " & Count & " For: " & CurrentSearch)
	If Direction <> CurrentOffset Then	LoadTropes(CurrentSearch, Direction)
End Sub

Sub LoadTropes(Search As String, Offset As Int)
	If Search.EqualsIgnoreCase(CurrentSearch) & CurrentOffset=Offset & INIexists("tropes") And Search.Length = 0 Then 
		TropesList = ReadINI("tropes")
		ShowMenu(7)
	Else
		DownloadFile("enumtropes", "limit=" & Limit & "&start=" & Offset & "&search=" & Search)
	End If
	CurrentSearch=Search
	CurrentOffset=Offset
End Sub

Sub EditEpisodeTrope(ID As Int) As Boolean  
	Dim INIS As Map, Tempstr As String, Name As String, Description As String 
	If Not(IsConnected) Then  Return False
	
	CurrentTrope = ID
	If CurrentEpisode.IsInitialized Then
		Tempstr = API.FindSection(CurrentEpisode, "tropeid", ID)
		If Tempstr.Length > 0 Then 
			INIS = API.GetSection(CurrentEpisode, Tempstr)
			Name = INIS.Get("trope.name")
			Description = INIS.Get("description")
		End If
	End If
	'If TropesList.IsInitialized And Not(INIS.IsInitialized) Then
	'	If TropesList.ContainsKey(ID) And Not(INIS.IsInitialized) Then 
	'		INIS = API.GetSection(TropesList, ID)
	'		
	'	End If
	'End If
	
	'Log("EditEpisodeTrope")
	If Name.Length > 0 Then 
		Tempstr = Ask("[MULTI]", "WHAT WOULD YOU LIKE TO CHANGE '" & Name & "' TO?", Description)
		If Not(Tempstr = Description) And Tempstr.Length > 0 Then
			'Log("Edit trope ID: " & ID & " to " & Tempstr)
			SendSuggestion("episodetrope", ID, Tempstr)
		End If
	'Else
		'Log("EditEpisodeTrope " & ID)
		'Log(Name & ": " & Description)
		'Log(INIS)
	End If
End Sub

Sub ViewTrope(ID As Int)
	Dim tempstr As String 
	If ReturnTo > 0 Then
		'add trope to episode
		tempstr = Ask("[MULTI]", "DESCRIBE THE TROPE EVENT", CurrentSeries & "." & CurrentSeason & "." & CurrentEpisodeID)
		If tempstr.Length>0 Then
			'Log("Add trope: " & tempstr)
			SendSuggestion("addepisodetrope", ID, tempstr)
		End If
	Else If CurrentTrope <> ID Or Not(Episodes.IsInitialized) Or Not(INIexists("trope" & ID)) Then
		DownloadFile("viewtrope", "id=" & ID)
		CurrentTrope = ID
	Else
		Episodes = ReadINI("trope" & ID)
		CurrentTrope = ID
		ShowMenu(8)
	End If
End Sub

Sub FindSeries(ID As Int) As String 
	Return FindSeriesKey(ID, "acronym")
End Sub

Sub FindSeriesKey(ID As Int, Key As String) As String
	Dim INIS As INIsection 
	If ID = -1 Then ID = API.FindSection(Series, "acronym", CurrentSeries)
	Return API.GetSection(Series, ID).Get(Key)
End Sub

Sub Spoilers() As String 
	Return API.IIF(ShowSpoilers, " [SPOILERS]", "")
End Sub

Sub LoadTrope()
	Dim INIS As Map = API.GetSection(Episodes, "Trope"), tempstr As String, temp As Int, HTML As StringBuilder, Count As Int  
	SeedButtonBar(Array As String("SPL", "ADD"))
	HTML.Initialize
	tempstr = INIS.Get("name")
	SetElement18Text(tempstr & Spoilers)
	'Log("Loading trope HTML " & tempstr)
	HTML.Append("<CENTER>" & tempstr & "</CENTER>" & Markdown(INIS.Get("title")))

	For temp = 0 To Series.Size - 1
		INIS = API.GetSection(Series, Series.GetKeyAt(temp))
		Count= Count + LoadTropBySeries(Series.Getkeyat(temp), HTML, INIS)
	Next 
	If Count = 0 Then 
		HTML.Append("<HR>Nothing uses this trope yet")
	End If	
	HTML.Append("</UL>")
	LoadHTML(HTML)
End Sub

Sub LoadTropBySeries(SeriesID As Int, HTML As StringBuilder, SeriesMap As Map) As Int 
	Dim INIS As Map, temp As Int, SeriesAcro As String = SeriesMap.Get("acronym") , tempstr As String, HasDone As Boolean, Count As Int 
	For temp = 1 To Episodes.Size - 1
		INIS = API.GetSection(Episodes, Episodes.GetKeyAt(temp))
		If INIS.IsInitialized Then 
			Log(SeriesID & " " & INIS.Get("series") & " " & SeriesAcro)
			If SeriesID = INIS.Get("series") Then 
				If Not(HasDone) Then 
					HTML.Append("<CENTER>" & SeriesMap.Get("name")  & "</CENTER><HR><UL>")
					HasDone = True
					SeriesAcro = FindSeries(SeriesID)
				End If
				tempstr = "<LI><A HREF='action=episode&id=" & INIS.Get("episodeid") & "&season=" & INIS.Get("season") & "&episode=" & INIS.Get("episode") & "&series=" & SeriesAcro & "' CLASS='" & INIclass("episode" & INIS.Get("episodeid")) & "'>" 
				tempstr = tempstr & INIS.Get("name") & " (" & SeriesAcro & ")</A>: " & Markdown(INIS.Get("description")) & "</LI>"
				HTML.Append(tempstr)
				Count=Count+1
			End If
		End If
	Next
	Return Count
End Sub

Sub INIclass(Filename As String) As String
	If Filename.Length = 0 Then Return "bad"
	If INIexists(Filename) Then Return "norm"
	Return "bad"
End Sub

Sub LoadHTML(HTML As StringBuilder)
	Dim tempstr As String 
	CallSub(Main, "HideWebview")'Main.webview1.StopLoading
	If ShowSpoilers Then
		tempstr = HTML.ToString.Replace("[", "").Replace("]", "")
	Else
		tempstr = HTML.ToString.Replace("[", "<FONT COLOR=BLACK>").Replace("]", "</FONT>")
	End If
	tempstr = API.MakeHTML(tempstr)
	CallSub3(Main, "BrowseWeb", tempstr, 3)
	Main.needsreloading = True 
End Sub

Sub LoadEpisode()
	Dim tempstr As StringBuilder, temp As Int, INIS As Map, tempstr2 As String, tempstr3 As String  
	tempstr.Initialize
	'Log("Load episode " & CurrentSeries & "." & CurrentSeason & "." & CurrentEpisodeID & "[" & CurrentSection & "]")
	If Series.IsInitialized Then
		INIS = API.GetSection(Series, API.FindSection(Series, "acronym", CurrentSeries))
		If INIS.IsInitialized Then tempstr2 = INIS.Get("name")
	End If
	If Episodes.IsInitialized Then 
		tempstr3 = API.findsection(Episodes, "episodeid", CurrentEpisodeID)
		If tempstr3.Length = 0 Then 
			INIS = API.GetSection(Episodes, CurrentEpisodeID)
		Else
			INIS = API.GetSection(Episodes, API.findsection(Episodes, "episodeid", CurrentEpisodeID))
		End If
		If INIS.IsInitialized Then 
			Log(INIS)
			
			SetElement18Text(INIS.Get("name") & Spoilers)
			tempstr.Append("<CENTER>" & INIS.Get("name") & "</CENTER>")
			If tempstr2.Length>0 Then tempstr.Append("<BR>Series: " & tempstr2)
			tempstr.Append("<BR>Season: " & INIS.Get("season") & " Episode: " & INIS.Get("episode") & "<BR>Air date: " & INIS.Get("airdate"))
			tempstr2 = INIS.Get("stardate")
			If tempstr2.Length=0 Then
				tempstr.Append("<BR>Stardate: Unknown")
			Else
				tempstr.Append("<BR>Stardate: " & tempstr2)
			End If
			tempstr2 = INIS.Get("memoryalpha")
			tempstr3 = INIS.Get("chakoteya")
			If tempstr2.Length>0 Or tempstr3.Length>0 Then
				tempstr.Append("<BR>Link(s): ")
				If tempstr2.Length>0 Then 
					tempstr.Append("<A HREF='http://memory-alpha.wikia.com/wiki/" & tempstr2 & "' CLASS='bad'>Memory-Alpha</A>")
					If API.Len(INIS.Get("memorybeta")) = 0 Or Not(INIS.ContainsKey("memorybeta")) Then 
						tempstr2 = tempstr2.Replace("_(episode)", "")
					Else 
						tempstr2 = INIS.Get("memorybeta")
					End If
					tempstr.Append(", <A HREF='http://memory-beta.wikia.com/wiki/" & tempstr2 & "' CLASS='bad'>Memory-Beta</A>")
				End If
				If tempstr2.Length>0 And tempstr3.Length>0 Then tempstr.Append(", ")
				If INIS.ContainsKey("chakoteya") Then 
					tempstr3 = tempstr3.Replace("http://www.chakoteya.net/", "")
					If tempstr3.Length>0 Then tempstr.Append("<A HREF='http://www.chakoteya.net/" & tempstr3 & "' CLASS='bad'>Chrissie's Transcripts</A>")
				End If 
			End If	
			tempstr.Append("<HR>" & Markdown(INIS.Get("summary")) & "<HR>")
		End If
	End If
	tempstr.Append("<UL>")
	For temp = 0 To CurrentEpisode.Size - 1
		INIS = CurrentEpisode.GetValueAt(temp)
		If INIS.IsInitialized Then 
			If INIS.ContainsKey("tropeid") Then
				INIS.Put("id", CurrentEpisode.GetKeyAt(temp))
				TestLog(INIS)
				
				tempstr2 = INIS.Get("description")
				tempstr3 = Markdown(tempstr2)
				Log("BEFORE: " & tempstr2)
				Log("AFTER: " & tempstr3)
				tempstr.Append("<LI><A HREF='action=trope&key=" & INIS.Get("id") & "&id=" & INIS.Get("tropeid") & "' CLASS='" & INIclass("trope" & INIS.Get("tropeid") ) & "'>" & INIS.Get("trope.name") & "</A>: " & tempstr3 & "</LI>")
			End If
		End If
	Next
	tempstr.Append("</UL>")
	LoadHTML(tempstr)
End Sub

Sub TestLog(INIS As Map) 
	Dim temp As Int 
	Log(INIS)
	For temp = 0 To INIS.Size - 1 
		Log("KEY: " & temp & " " & INIS.GetKeyAt(temp) )
		Log("VAL: " & temp & " " & INIS.GetValueAt(temp))
	Next
End Sub

Sub URLclicked(URL As String) As Int 
	Dim temp As Int, Data As Map 
	Log("opening URL: " & URL)
	If URL.StartsWith("file:///") Or Not(URL.Contains("/")) Then
		Log("Local URL")
		If URL.Contains("/") Then 
			temp = URL.LastIndexOf("/")
			URL = API.Right(URL, URL.Length-temp-1)
		End If
		Data = ProcessURL(URL)
		'Log("URLCLICKED")
		'Log(Data)
		Select Case Data.GetDefault("action", "")
			Case "trope":
				CurrentTrope =  Data.GetDefault("id", "")
				temp = -1 
				If Data.ContainsKey("key") Then 
					CurrentTropeID = Data.Get("key")
					temp = Messagebox("WHAT WOULD YOU LIKE TO DO WITH THIS TROPE?", "", "VIEW", "EDIT", "")
				End If
				If temp = -1 Then
					ViewTrope(CurrentTrope)
					Return -1
				Else if temp = -3 Then ' may not be right
					EditEpisodeTrope(CurrentTrope)
				End If
			Case "episode":
				CurrentSeries = Data.Get("series")
				CurrentSeason = Data.Get("season")
				CurrentEpisodeIndex = Data.GetDefault("episode", 0)	
				CurrentEpisodeID = Data.GetDefault("id", 0)	
				enumEpisodes(CurrentSeries, CurrentSeason)
				Return -1
			Case "audio"
				If Data.ContainsKey("file") Then
					CallSub3(Main, "DownloadAndPlay", Data.Get("file"), 0)
				End If
			Case Else
				Log("Action: " & Data.GetDefault("action", "") & " is unhandled")
		End Select
	Else
		Log("Remote URL")
		CallSub3(Main, "BrowseWeb", URL, 0)
	End If
	'Log("URLclicked: " & URL)
End Sub

Sub ProcessURL(URL As String) As Map 
	Dim tempstr() As String = Regex.Split("&", URL), temp As Int, Data As Map, Key As String, Val As String 
	Data.Initialize 
	For temp = 0 To tempstr.Length - 1
		Key = API.GetSide(tempstr(temp), "=", True, False)
		Val = API.GetSide(tempstr(temp), "=", False, False)
		Data.Put(Key, Val)
	Next
	Return Data 
End Sub


'edittrope			"id" => 0, "name", "title"
'editepisode		"id" => 0, "series", "name", "season", "episode", "summary"
'editepisodetrope	"id" => 0, "episodeid", "tropeid", "description"	
'changeeditstatus	"status", "editid"

Sub SendSuggestion(sType As String, ID As Int, Value As String)
	Log("episode " & CurrentSeries & "." & CurrentSeason & "." & CurrentEpisodeID & "[" & CurrentSection & "] - " & CurrentTrope & " (" & CurrentTropeID & ")")
	Dim Value2 As String = Value, STR As StringUtils
	Value = STR.EncodeUrl(Value, "UTF8")
	Select Case sType
		Case "episodetrope"
			'Log("Add trope " & ID & " to episode ID " & CurrentEpisodeID & ": " & Value)
			DownloadFile("editepisodetrope", "id=" & CurrentTropeID & "&episodeid=" & CurrentEpisodeID & "&description=" & Value & "&tropeid=" &  ID)
		Case "addepisodetrope"
			'Log("Add trope " & ID & " to episode ID " & CurrentEpisodeID & ": " & Value)
			DownloadFile("editepisodetrope", "id=0&episodeid=" & CurrentEpisodeID & "&description=" & Value & "&tropeid=" & ID)
		Case "tropename"
			'Log("Edit Trope Name " & ID & " to " & Value)
			DownloadFile("edittrope", "id=" & ID & "&name=" & Value)
		Case "tropedesc"
			'Log("Edit Trope Description " & ID & " to " & Value)	
			DownloadFile("edittrope", "id=" & ID & "&title=" & Value)
		Case "newtrope"
			Value2= Ask("[MULTI]", "HOW WOULD YOU LIKE TO DESCRIBE '" & Value2 & "'?", "")
			If Value2.Length>0 Then 
				'Log("Make a new trope, named: " & Value & " - " & Value2)
				DownloadFile("edittrope", "id=0&name=" & Value & "&title=" & STR.EncodeUrl(Value2, "UTF8"))
			End If
		Case "message"
			DownloadFile("sendmessage", "user=" & ID & "&message=" & STR.EncodeUrl(Value2, "UTF8"))
		Case Else 
			Log("Unhandled SendSuggestion - " & sType & ": " & ID & " - " & Value)		
	End Select
End Sub

Sub Markdown(Text As String) As String
	Dim tempstr() As String, temp As Int, temp2 As Int, HTML As StringBuilder, CurrentLine As String, NextLine As String, IsInside As Int, LeftSide As String, RightSide As String , SkipLine As Boolean 
	Dim Debugging As Boolean = True 
	'sanitize
	If Debugging Then Log("Step 1: " & Text)
	Text = Text.Replace("<BR>", CRLF)
	Text = Text.Replace("<UL>", CRLF)
	Text = Text.Replace("<LI>", "* ")
	Text = Text.Replace("</LI>", "")
	Text = Text.Replace("</UL>", CRLF)
	If Debugging Then Log("Step 2: " & Text)
	Text = Text.Replace("---", "&mdash;")
	Text = Text.Replace("\\", "&#92;")
	Text = Text.Replace("\`", "&#39;")
	Text = Text.Replace("\*", "&#42;")
	Text = Text.Replace("\_", "&#95;")
	Text = Text.Replace("\{", "&#123;")
	Text = Text.Replace("\}", "&#125;")
	Text = Text.Replace("\[", "&#91;")
	Text = Text.Replace("\]", "&#93;")
	Text = Text.Replace("\(", "&#40;")
	Text = Text.Replace("\)", "&#41;")
	Text = Text.Replace("\#", "&#35;")
	Text = Text.Replace("\+", "&#43;")
	Text = Text.Replace("\-", "&#45;")
	Text = Text.Replace("\.", "&#46;")
	Text = Text.Replace("\!", "&#33;")	
	Text = ProcessURLs(Text, "bad")
	Text = ProcessSuperscript(Text)
	If Debugging Then Log("Step 3: " & Text)
	tempstr = Regex.Split(CRLF, Text)

	HTML.Initialize
	For temp = 0 To tempstr.Length-1 
		CurrentLine = tempstr(temp)
		If temp+1 < tempstr.Length Then  NextLine = tempstr(temp+1).Trim 
		LeftSide = GetLeftSide(CurrentLine, " ")
		RightSide = GetRightSide(CurrentLine, " ")
		If Debugging Then Log("CurrentLine:" & temp & " - " & CurrentLine)
		'Log("Nextline: " & NextLine)
		
		If SkipLine Then 
			SkipLine= False 	
		else If IsHR(CurrentLine) Then 
			CurrentLine = "<HR>"
		else if IsQuote(CurrentLine) Then 
			CurrentLine = "<BLOCKQUOTE>&quot;" & API.right(CurrentLine, CurrentLine.Length-1).Trim & "&quot;</BLOCKQUOTE>"
		else if IsListItem(CurrentLine, False) Then 
			If IsInside = 0 Then CurrentLine = "<UL>"
			IsInside = 1
			CurrentLine = CurrentLine & "<LI>" & RightSide & "</LI>"
			If Not(IsListItem(NextLine, False)) Then 
				IsInside = 0
				If IsInside = 0 Then CurrentLine = CurrentLine & "</UL>"
			End If
		else if IsListItem(CurrentLine, True) Then 
			If IsInside = 0 Then CurrentLine = "<OL>"
			IsInside = 2
			CurrentLine = CurrentLine & "<LI>" & RightSide & "</LI>"
			If Not(IsListItem(NextLine, True)) Then 
				IsInside = 0
				If IsInside = 0 Then CurrentLine = CurrentLine & "</OL>"
			End If
		Else if OnlyContains(NextLine, "=") Then 
			CurrentLine = "<H1><CENTER>" & CurrentLine & "</CENTER></H1>"
			SkipLine=True
		Else if OnlyContains(NextLine, "-") Then 
			CurrentLine = "<H2><CENTER>" & CurrentLine & "</CENTER></H2>"
			SkipLine=True
		else if OnlyContains(LeftSide, "#") Then 
			temp2 = API.CountInstances2(LeftSide, "#")
			CurrentLine = "<H" & temp2 & "><CENTER>" & CurrentLine.Replace("#", "") & "</CENTER></H" & temp2 & ">"
		End If
		If CurrentLine.Length > 0 Then 
			Log("After: " & CurrentLine)
			HTML.Append(CurrentLine & CRLF)
		End If
	Next
	If Debugging Then Log("Step 4: " & HTML.ToString)
	CurrentLine=CRLF & "<BR>"
	Text = HTML.ToString.Replace(CRLF, CurrentLine)
	If Debugging Then Log("Step 5: " & Text)
	Text = Enclose(Text, "_", "U")
	Text = Enclose(Text, "~~", "strike")
	Text = Enclose(Text, "**", "B")
	Text = Enclose(Text, "*", "I")
	If Debugging Then Log("Step 6: " & Text)
	Do While Text.StartsWith(CurrentLine)
		Text = API.Right(Text, Text.Length - CurrentLine.Length)
	Loop
	Do While Text.EndsWith(CurrentLine)
		Text = API.Left(Text, Text.Length - CurrentLine.Length)
	Loop
	If Debugging Then Log("Step 7: " & Text)
	Return Text.Trim 
End Sub

Sub Enclose(Text As String, Find As String, HTMLtag As String) As String 
	Do While Has2(Text, Find)
		Text = ReplaceNext(Text, 0, Find, "<" & HTMLtag & ">")
		Text = ReplaceNext(Text, 0, Find, "</" & HTMLtag & ">")
	Loop
	Return Text 
End Sub

Sub Has2(Text As String, Find As String) As Boolean 
	Dim instr As Int = API.Instr(Text, Find, 0) 
	If instr > -1 Then 
		instr = API.Instr(Text, Find, instr+1)
		Return instr > -1 
	End If
End Sub

Sub ReplaceNext(Text As String, Start As Int, ToFind As String, ToReplace As String) As String 
	Dim instr As Int = API.Instr(Text, ToFind, Start)
	If instr > -1 Then 
		Return API.Left(Text, instr) & ToReplace & API.Right(Text, Text.Length - instr - ToFind.Length)	
	End If
	Return Text 
End Sub

Sub IsHR(Text As String) As Boolean 
	Text = Text.trim.Replace(" ", "")
	Return OnlyContains(Text, "*-_") And Text.Length > 2
End Sub

Sub OnlyContains(Text As String, Characters As String) As Boolean
	Dim temp As Int, Character As String 
	If Text.Length = 0 Then Return False 
	For temp = 0 To Text.Length -1 
		Character = API.Mid(Text, temp, 1)	
		If Not(Characters.Contains(Character)) Then Return False 
	Next
	Return True 
End Sub
Sub IsListItem(Text As String, Numbered As Boolean) As Boolean 
	If Text.Length = 0 Then Return False 
	If Numbered Then 
		Text = GetLeftSide(Text, ".").Trim 
		Return IsNumber(Text) 
	Else 
		Return Text.StartsWith("*")
	End If
End Sub

Sub GetLeftSide(Text As String, Delimeter As String) As String
	Dim instr As Int 
	Text = Text.Trim
	instr = API.Instr(Text, Delimeter, 0)
	If instr > -1 Then Return API.Left(Text, instr).Trim 
End Sub
Sub GetRightSide(Text As String, Delimeter As String) As String
	Dim instr As Int 
	Text = Text.Trim
	instr = API.Instr(Text, Delimeter, 0)
	If instr > -1 Then Return API.right(Text, Text.Length-instr).Trim 
	Return Text 
End Sub

Sub IsQuote(Text As String) As Boolean
	Return API.Left(Text.Trim, 1) = ">" 
End Sub

Sub ProcessSuperscript(Text As String) As String 
	Dim instr As Int  = API.Instr(Text, "^", 0), SpaceChar As Int, CRLFchar As Int 
	Do Until instr = -1 
		Text = ReplaceNext(Text, 0, "^", "<SUP>")
		SpaceChar = API.Instr(Text, " ", instr) 
		CRLFchar = API.Instr(Text, CRLF, instr) 
		If SpaceChar > -1 And (SpaceChar < CRLFchar Or CRLFchar = -1) Then 
			Text = ReplaceNext(Text, instr, " ", "</SUP>")
		Else if CRLFchar > -1 Then 
			Text = ReplaceNext(Text, instr, CRLF, "</SUP>" & CRLF)
		Else 
			Text = Text & "</SUP>"
		End If
		instr  = API.Instr(Text, "^", 0)
	Loop
	Return Text 
End Sub

Sub ProcessURLs(Text As String, Class As String) As String
	Dim Start As Int, Middle As Int, Finish As Int, Possible As Int, Cont As Boolean = True 
	Dim URL As String, Tempstr As String 
	Do While Cont '<http://www.url.com> 
		Start = API.Instr(Text, "<", Start)
		If Start > -1 Then
			Finish = API.Instr(Text, ">", Start)
			If Finish = -1 Then 
				Cont = False
			Else
				URL = API.Mid(Text, Start + 1, Finish - Start - 1)
				Tempstr = NewLink(URL, URL)' "<A HREF='" & URL & "' CLASS='" & Class & "'>" & URL & "</A>"
				Text = API.Left(Text, Start) & Tempstr & API.Right(Text, Text.Length - Finish - 1)
				Start = Start + Tempstr.Length  
			End If
		End If
		If Cont Then Cont = Start > -1 
	Loop 
	Cont = True 
	Start = 0
	Do While Cont'[text!](http://www.url.com)
		Start = API.Instr(Text, "[", Start)
		If Start > -1 Then 
			Possible = API.Instr(Text, "]", Start)
			Middle = API.Instr(Text, "](", Start)	
			If Middle = -1 Then 
				Cont = False 
			Else If Possible > -1 And Possible < Middle Then
				Start = Possible+1
			Else 
				Finish = API.Instr(Text, ")", Middle)
				If Finish = -1 Then 
					Cont = False
				Else
					Tempstr = API.Mid(Text, Start+1, Middle - Start - 1)
					URL = API.Mid(Text, Middle + 2, Finish - Middle - 2)
					Tempstr = "<A HREF='" & URL & "' CLASS='" & Class & "'>" & Tempstr & "</A>"
					Log("1: " & Tempstr)
					Text = API.Left(Text, Start) & Tempstr & API.Right(Text, Text.Length - Finish - 1)
					Start = Finish 
				End If 	
			End If
		End If 
		If Cont Then Cont = Start > -1 
	Loop
	Return Text 
End Sub
	
Sub NewLink(URL As String, Text As String) As String 
	Return "<A HREF='" & URL & "' CLASS='" & IsCached(URL) & "'>" & Text & "</A>"
End Sub
Sub IsCached(URL As String) As String
	'Dim Data As Map = ProcessURL(URL)
	Return "bad"'not cached, norm is cached
End Sub