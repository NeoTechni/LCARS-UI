B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'Class module
Sub Class_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

	'Dim scope as string = "http://api.microsofttranslator.com"
	'Dim grant_type as string "client_credentials"
	Dim client_secret As String,client_id As String, access_token As String, token_type As String, expires_at As Long, scope As String ,MaxChars As Int
	Dim CurrentText As String, TranslatedText As String,Src As String, Dest As String , SupportedLanguages As Map ,isTranslating As Boolean ,History As Map ,IsNew As Boolean
	Dim MustBeKlingon As Boolean, KlingonPG As Map   'Klingon specific stuff can be removed
	
	Private module As Object, eventName As String
End Sub

'BEGIN Klingon specific stuff can be removed
Public Sub IsInvolvingKlingon(SrcLang As String, DestLang As String) As Boolean 
	If Not(MustBeKlingon) Then Return True
	Return IsKlingon(SrcLang) Or IsKlingon(DestLang)
End Sub
Public Sub IsKlingon(ShortString As String)As Boolean 
	Return ShortString.EqualsIgnoreCase("tlh") Or ShortString.EqualsIgnoreCase("tlh-QON") 
End Sub
Public Sub KlingonLanguage(IsKronos As Boolean) As String 
 	If IsKronos Then 
 		Return "tlh-QON"
	Else
		Return "tlh"
	End If 
End Sub
Sub AddKlingonTest
	History.Put(MakeKey(API.GetString("klingon_dbds"), "en", "tlh"), "Hegh pong lam paSlogh")
End Sub
Sub InitKlingon
	Dim temp As Int 
	If Not(KlingonPG.IsInitialized) Then'longest syllables first
		Dim KlingonText() As String = Array As String("tlh",	"ch",	"gh",	"ng",	"aw",	"ew",	"Iw",	"ay",	"ey",	"Iy",	"oy",	"uy",	"'",	"a",	"b",	"D",	"e",	"H",	"I",	"j",	"l",	"m",	"n",	"o",	"p",	"q",	"Q",	"r",	"S",	"t",	"u",	"v",	"w",	"y",	" ")
		Dim EnglishText() As String = Array As String("dl",		"ch", 	"k",	"ng",	"ow",	"ehw",	"ew",	"eye",	"ay",	"eee",	"oi",	"oee",	"ah",	"ah",	"bah",	"d",	"eh",	"ch",	"ih",	"j",	"l",	"m",	"n",	"oh",	"p",	"k",	"k ha",	"rr",	"shh",	"t",	"ooh",	"vv",	"w",	"y",	" ")
		KlingonPG.Initialize 
		For temp = 0 To KlingonText.Length-1 
			KlingonPG.Put(KlingonText(temp), EnglishText(temp))
		Next
	End If
End Sub
Sub PronounceKlingon(Text As String) As String 
	Dim tempstr As StringBuilder ,tempstr2 As String 
	InitKlingon
	tempstr.Initialize 
	tempstr2=GrabKlingonPart(Text)
	Do Until Text.Length=0 Or tempstr2.Length=0
		'Log(Text & " (K: " & tempstr2 & " )(E: " & KlingonPG.Get(tempstr2) & " )")
		tempstr.Append(KlingonPG.Get(tempstr2))
		Text = API.Right(Text, Text.Length-tempstr2.Length) ' Text.SubString(Text.Length-tempstr2.Length)
		tempstr2=GrabKlingonPart(Text)
	Loop
	Return tempstr.ToString.ToLowerCase 
End Sub
Sub GrabKlingonPart(Text As String) As String
	Dim temp As Int , Backup As String = "", tempstrKlingon As String ,tempstrEnglish As String 
	For temp = 0 To KlingonPG.Size-1
		tempstrKlingon = KlingonPG.GetKeyAt(temp)
		tempstrEnglish= Text.SubString2(0,Min(Text.Length,tempstrKlingon.Length))
		If tempstrEnglish = tempstrKlingon Then
			Return tempstrKlingon
		Else If tempstrEnglish.EqualsIgnoreCase(tempstrKlingon) Then
			If Backup.Length=0 Then Backup=tempstrKlingon
		End If
	Next
	Return Backup
End Sub
'END Klingon specific stuff can be removed

'BEGIN LCARS specific stuff can be removed
Public Sub SeedHistory(ListID As Int,Start As Int)
	Dim temp As Int , tempstr() As String '0=text, 1=srclang, 2=destlang
	For temp = Start To History.Size-1
		tempstr = Regex.Split("\|", History.GetKeyAt(temp))
		LCAR.LCAR_AddListItem(ListID, ToKlingon(tempstr(0),tempstr(1)),  API.IIF(IsKlingon(tempstr(1)), LCAR.LCAR_Red, LCAR.LCAR_Orange), temp+1, "", False, "", 0, False,-1)
		LCAR.LCAR_AddListItem(ListID, ToKlingon(History.GetValueAt(temp),tempstr(2)), API.IIF(IsKlingon(tempstr(2)), LCAR.LCAR_Red, LCAR.LCAR_Purple), -1, "", False, "", 0, False,-1)
	Next
End Sub
Sub ToKlingon(Text As String, Language As String) As String 
	If IsKlingon(Language) Then Return "GSF4:" & Text.ToUpperCase 
	Return Text.ToUpperCase 
End Sub
Public Sub SeedLanguages(ListID As Int, IncludeAutoDetect As Boolean) 
	Dim temp As Int
	For temp = API.IIF(IncludeAutoDetect,0,1) To SupportedLanguages.Size-1
		LCAR.LCAR_AddListItem(ListID, API.uCase(SupportedLanguages.GetKeyAt(temp)), LCAR.LCAR_Random, -1, SupportedLanguages.GetValueAt(temp), False, "", 0, False,-1)
	Next
End Sub
'END LCARS specific stuff can be removed

Public Sub ClearHistory
	History.Initialize 
End Sub

'Register your app: https://datamarket.azure.com/developer/applications/
Public Sub Initialize(ModulePar As Object, EventNamePar As String, Secret As String, ID As String)
	module = ModulePar
    eventName = EventNamePar
	client_secret=Secret
	client_id=ID 
	InitLangs
	
	'TTS1.InitializeTTs("TTS", "en")'Can be commented out
End Sub

Private Sub InitLangs
	Dim temp As Int  ,su As StringUtils'su.EncodeUrl(access_token, "UTF8")
	If Not(SupportedLanguages.IsInitialized) Then
		SupportedLanguages.Initialize 
		Dim keys() As String = Array As String("","ar","bg","ca","zh-CHS","zh-CHT","cs","da","nl","en","et","fi","fr","de","el","ht","he","hi","mww","hu","id","it","ja","tlh","tlh-QON","ko","lv","lt","ms","no","fa","pl","pt","ro","ru","sk","sl","es","sv","th","tr","uk","ur","vi")
		Dim values() As String = Regex.Split(",", API.getstring("klingon_languages"))
		' Array As String("Auto-Detect","Arabic","Bulgarian","Catalan","Chinese Simplified","Chinese Traditional","Czech","Danish","Dutch","English","Estonian","Finnish","French","German","Greek","Haitian Creole","Hebrew","Hindi","Hmong Daw","Hungarian","Indonesian","Italian","Japanese","Klingon","Klingon (Kronos)","Korean","Latvian","Lithuanian","Malay","Norwegian","Persian","Polish","Portuguese","Romanian","Russian","Slovak","Slovenian","Spanish","Swedish","Thai","Turkish","Ukrainian","Urdu","Vietnamese")
		For temp = 0 To keys.Length-1
			SupportedLanguages.Put(values(temp).ToLowerCase, su.EncodeUrl(keys(temp), "UTF8"))
		Next
		ClearHistory
	End If
End Sub

'Returns empty if it's not found
Public Sub GetLanguageName(ShortString As String) As String 
	Dim temp As Int 
	For temp = 0 To SupportedLanguages.Size -1 
		If ShortString.EqualsIgnoreCase(SupportedLanguages.GetValueAt(temp)) Then
			Return SupportedLanguages.GetKeyAt(temp)
		End If
	Next
	Return ""
End Sub
Public Sub GetLanguageID(LongString As String) As String 
	Return SupportedLanguages.Get(LongString.ToLowerCase)
End Sub

Private Sub RaiseEvent(Event As String)
	If SubExists(module, eventName  & "_" & Event) Then CallSub(module, eventName  & "_" & Event)
End Sub 
Private Sub RaiseEvent1Par(Event As String, Par1 As Object)
	If SubExists(module, eventName  & "_" & Event) Then CallSub2(module, eventName  & "_" & Event, Par1)
End Sub 
Private Sub RaiseEvent2Pars(Event As String, Par1 As Object, Par2 As Object)
	If SubExists(module, eventName  & "_" & Event) Then CallSub3(module, eventName  & "_" & Event, Par1, Par2)
End Sub 

Sub Failed(External As Boolean, Message As String)
	RaiseEvent1Par("Error", Message)
	If External Then isTranslating=False
End Sub
'Sub Response(JobName As String, Data As HttpResponse)
'	Dim M As Map = Data.GetHeaders  
'	Log("Response-" & JobName & ": " & M)
'End Sub

Sub JobDone(JobName As String, Text As String)
	'Log("JobDone-" & JobName & ": " & Text)
	'JobDone-BING.AUTH: {"token_type":"http://schemas.xmlsoap.org/ws/2009/11/swt-token-profile-1.0","access_token":"http%3a%2f%2fschemas.xmlsoap.org%2fws%2f2005%2f05%2fidentity%2fclaims%2fnameidentifier=LCARS_UI&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&Audience=http%3a%2f%2fapi.microsofttranslator.com&ExpiresOn=1368909336&Issuer=https%3a%2f%2fdatamarket.accesscontrol.windows.net%2f&HMACSHA256=JuvkQIW7p6CkkIvC%2f9UXuOGVAuJWK6BHs42plcB0SQo%3d","expires_in":"599","scope":"http://api.microsofttranslator.com"}
	Dim JSON As JSONParser , Data As Map ,su As StringUtils'su.EncodeUrl(access_token, "UTF8")
	Select Case JobName
		Case eventName & ".AUTH"
			expires_at= DateTime.Now+ (DateTime.TicksPerMinute*10)-1
			JSON.Initialize(Text)
			Data = JSON.NextObject
			access_token = su.EncodeUrl("Bearer " & Data.Get("access_token"), "UTF8")
			Translate(CurrentText,Src,Dest)
		Case eventName & ".TRANS"
			isTranslating=False
			TranslatedText=Text.SubString2(4, Text.Length-3)
			'History.Put(CurrentText.ToLowerCase & "|" & Src & "|" & Dest", TranslatedText)
			History.Put(MakeKey(CurrentText, Src, Dest), TranslatedText)
			IsNew=True
			RaiseEvent2Pars("Done", CurrentText, TranslatedText)
	End Select
End Sub

Private Sub ObtainAccessToken As Boolean 
	If expires_at <= DateTime.Now Or access_token.Length=0 Then
		API.PostString(eventName & ".AUTH", "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/", "client_secret=" & client_secret & "&client_id=" & client_id & "&scope=http://api.microsofttranslator.com&grant_type=client_credentials")
		Return True
	End If
End Sub

Private Sub MakeKey(Text As String, SrcLang As String, DestLang As String) As String 
	If Not(IsKlingon(SrcLang)) Then Text = Text.ToLowerCase 
	Return Text.Trim.Replace("  ", " ") & "|" & SrcLang & "|" & DestLang
End Sub

Sub AutoTranslate
	Translate(CurrentText,Src,Dest)
End Sub
Sub Translate(Text As String, SrcLang As String, DestLang As String) As Boolean 
	Dim URL As String ,su As StringUtils'su.EncodeUrl(access_token, "UTF8")
	Text=Text.Replace("|", " ").Trim.Replace("  ", " ")
	URL=MakeKey(Text,SrcLang,DestLang)'  Text.ToLowerCase & "|" & SrcLang & "|" & DestLang
	If History.ContainsKey(URL) Then
		IsNew=False
		RaiseEvent2Pars("Done", Text, History.Get(URL))
	Else If API.IsConnected And Not(SrcLang.EqualsIgnoreCase(DestLang)) And DestLang.Length>0 And Not(isTranslating) And (Text.Length<=MaxChars Or MaxChars=0) And Text.Length>0 And IsInvolvingKlingon(SrcLang,DestLang) Then'<-- Klingon specific stuff can be removed
		CurrentText=Text'There is Klingon specific stuff in the line above this
		TranslatedText=""
		Src=SrcLang
		Dest=DestLang
		If Not(ObtainAccessToken) Then
			'"http://api.microsofttranslator.com/V2/Ajax.svc/Translate" +
                '"?appId=Bearer " + encodeURIComponent(window.accessToken) +
                '"&from=" + encodeURIComponent(from) +
                '"&to=" + encodeURIComponent(To) +
                '"&text=" + encodeURIComponent(Text) +
                '"&oncomplete=mycallback";
			Text = su.EncodeUrl(Text, "UTF8")
			URL="http://api.microsofttranslator.com/V2/Ajax.svc/Translate?appId=" & access_token & "&from=" & SrcLang & "&to=" & DestLang & "&text=" & Text & "&oncomplete=t"
			API.Download(eventName & ".TRANS", URL)

			'HttpUtils.PostString("BING.TRANS",  "http://api.microsofttranslator.com/v2/Http.svc/Translate?text=" & Text & "&from=" & SrcLang & "&to=" & DestLang, "&Authorization=" & access_token)
		End If
		Return True
	Else 
		If isTranslating Then
			Failed(False, API.GetString("klingon_inprogress"))
		Else If DestLang.Length=0 Then
			Failed(False, API.GetString("klingon_notspecified"))
		Else If Text.Length = 0 Then
			Failed(False, API.GetString("klingon_noinput"))
		Else If Text.Length>MaxChars And MaxChars>0 Then
			Failed(False, API.GetStringvars("klingon_toolong", Array As String(MaxChars)))
		Else If DestLang.EqualsIgnoreCase(SrcLang) Then
			Failed(False, API.GetString("klingon_thesame"))
		Else If Not(IsInvolvingKlingon(SrcLang,DestLang)) Then		'<-- Klingon specific stuff can be removed
			Failed(False, API.GetString("klingon_klingon"))	'<-- Klingon specific stuff can be removed
		Else
			Failed(False, API.GetString("offline"))
		End If
	End If
End Sub

























