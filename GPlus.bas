B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim APIkey As String  ,maxResults As Int=20, vbQuote As String = Chr(34),CwActivity As List,CwReplies As String,CwReply As String,isGplus As Int  ', prettyPrint As Boolean
	Dim FacebookClientID As String, FacebookClientSecret As String , FacebookAccessToken As String 
	Dim TwitterThumb As String, TwitterEncodedKey As String ,TwitterAccessToken As String ,TwitterClientID As String, TwitterClientSecret As String 

	Type PlusActor(ID As String, ImageURL As String, URL As String, displayName As String)
	Type ImageAttachment(URL As String, Width As Int, Height As Int)
	Type PlusReply(Actor As PlusActor, Content As String)
	Type PlusAttachment(objectType As String, URL As String, displayName As String, content As String, Thumbnail As ImageAttachment, Image As ImageAttachment)
	Type PlusActivity(eTag As String,NextPageToken As String,  Kind As String, Title As String, id As String, Published As String, updated As String, url As String, Actor As PlusActor, Replies As Int,ReplyList As List, PlusOners As Int, Resharers As Int, Content As String, Attachments As List )
	
	Type INIsection(Name As String, Keys As List, Values As List, Sections As List, EndLine As Int )
	
	Dim ErrorAsset As String = "file:///android_asset/mission.png"
End Sub

Sub IIF(Value As Boolean , IfTrue As Object, IfFalse As Object) As Object
	If Value Then 
		Return IfTrue 
	Else 
		Return IfFalse
	End If
End Sub
Sub Instr(Text As String, TextToFind As String, Start As Int) As Int
	Return Text.IndexOf2(TextToFind,Start)
End Sub
Sub Left(Text As String, Length As Long)As String 
	If Length>Text.Length Then Length=Text.Length 
	If Length>0 Then Return Text.SubString2(0, Length)
End Sub
Sub Right(Text As String, Length As Long) As String
	If Length>Text.Length Then Length=Text.Length 
	If Length>0 Then Return Text.SubString(Text.Length-Length)
End Sub
Sub Mid(Text As String, Start As Int, Length As Int) As String 
	If Length>0 And Start>-1 And Start< Text.Length Then Return Text.SubString2(Start,Start+Length)
End Sub








Sub Clear
	If CwActivity.IsInitialized Then CwActivity.Clear 
End Sub
Sub NeedsParsing As Boolean 
	If CwActivity.IsInitialized Then
		Return CwActivity.Size=0
	Else
		Return True
	End If
End Sub












Sub HandleVariables(doQuestionMark As Boolean, DoMax As Boolean ) As String 
	'prettyPrint
	Dim tempstr As String = IIF(doQuestionMark, "?", "&")
	Select Case isGplus
		Case 0'Gplus
			tempstr= tempstr & "key=" & APIkey
			'If Not (prettyPrint) Then tempstr=tempstr & "&prettyPrint=false"
			If maxResults>0 And DoMax Then tempstr=tempstr & "&maxResults=" & maxResults
		Case 2'facebook
			tempstr = tempstr & "method=GET&format=json&access_token=" & FacebookAccessToken.Replace("|","%7C")
			If maxResults>0 And DoMax Then tempstr=tempstr & "&limit=" & maxResults
	End Select
	Return tempstr
End Sub
Sub ProfileURL(UserID As String) As String
	If isGplus =0 Then Return "https://www.googleapis.com/plus/v1/people/" & UserID & "?pp=1" & HandleVariables(False,False)
	Return ""
End Sub
Sub PostsURL(UserID As String, PageToken As String) As String 
	If API.Left(UserID,1) = "@" Then'twitter
		isGplus=1
		Return "https://api.twitter.com/1.1/statuses/user_timeline.json?count=" & maxResults & "&screen_name=%40" & API.Right( UserID,UserID.Length-1)
		'Return "https://api.twitter.com/1/statuses/user_timeline.xml?include_entities=true&include_rts=true&screen_name=" & API.Right( UserID,UserID.Length-1) & "&count=" & maxResults 'twitter
	Else If IsNumber(UserID) Then'google plus
		isGplus=0
		Return "https://www.googleapis.com/plus/v1/people/" & UserID & "/activities/public" & HandleVariables(True,True) & IIF(PageToken.Length=0, "", "&pageToken=" & PageToken)
	Else'facebook
		isGplus=2
		If Left(UserID, 1) = "f" Then UserID=Right(UserID, UserID.Length-1)'
		'Return "https://graph.facebook.com/" & UserID & "?fields=posts,picture" & HandleVariables(False,True)  '&method=GET&format=json&access_token=" & FacebookAccessToken.Replace("|","%7C")
		Return "https://graph.facebook.com/" & UserID & "?fields=posts,picture" & HandleVariables(False,True)  '&method=GET&format=json&access_token=" & FacebookAccessToken.Replace("|","%7C")
	End If
End Sub
Sub CommentsURL(ActivityID As String) As String 
	Select Case isGplus
		Case 0: Return "https://www.googleapis.com/plus/v1/activities/" & ActivityID & "/comments" & HandleVariables(True,False)	'gplus
		'Case 2: Return "https://graph.facebook.com/" & ActivityID & "?fields=comments" & API.IIF(maxResults=0,"", ".limit(" & maxResults & ")") & HandleVariables(False,False) 'facebook
		'Case 2: Return "https://graph.facebook.com/" & ActivityID & "?fields=comments&summary=true" & API.IIF(maxResults=0,"", ".limit(" & maxResults & ")") & "&filter=stream" & HandleVariables(False,False) 'facebook
		'Case 2: Return "https://graph.facebook.com/" & ActivityID & "?fields=comments.summary(true)" & API.IIF(maxResults=0,"", ".limit(" & maxResults & ")") & "&filter=stream" & HandleVariables(False,False) 'facebook
	End Select
	Return ""
End Sub
Sub PlusOnersURL(ActivityID As String, Resharers As Boolean) As String 
	Select Case isGplus
		Case 0: Return "https://www.googleapis.com/plus/v1/activities/" & ActivityID & "/people/" & IIF(Resharers, "resharers", "plusoners") & HandleVariables(True,False)'gplus
	End Select
	Return ""
End Sub









Sub ParseTag(Text2 As String, LeftSide As Boolean) As String 
	' "kind": "plus#activityFeed",
	Dim Start As Int, Finish As Int,Text As String 
	Text=Text2
	'Text=Text.Replace("'", vbQuote)'debugging only
	Start=Instr(Text, vbQuote & ": ",0)
	If Start>0 Then
		If LeftSide Then
			Text=Left(Text, Start).Trim
			Text=Right(Text, Text.Length-1)
		Else
			Text=Right(Text, Text.Length - Start - 3).Trim.Replace("\u003cbr /\u003e","<P>").Replace("&#39;", "'").Replace("&quot;", vbQuote).Replace("\n", "<BR>").Replace("\" & vbQuote, vbQuote)
			Text=Text.Replace("\u003c", "<").Replace("\u003e", ">")
			
			Select Case Text
				Case "[", "{"
				Case Else
					If Right(Text,2)= vbQuote & "," Then
						Text=Left(Text, Text.Length-2)
					Else
						Text=Left(Text, Text.Length-1)
					End If
					If Left(Text,1)=vbQuote Then Text=Right(Text, Text.Length -1)
			End Select
		End If
		Return Text
	End If
End Sub


Sub ParseSocialMediaFeed(Text As String) As List 
	Dim INI As INIsection , tempList As List 
	Select Case isGplus
		Case 0'gplus
			INI=	ParseActivityFeed(Text)
			tempList = EnumActivities(INI)
		Case 1'twitter
			tempList = ParseTwitter(Text)
		Case 2'facebook
			tempList = ParseFacebook(Text)
	End Select
	Return tempList
End Sub



'parses all google plus feeds, not just activities
Sub ParseActivityFeed(Text As String) As INIsection 
	Dim tempstr() As String ,temp As Int , Key As String, Value As String , tempINI As INIsection ,tempINI2 As INIsection 
	tempINI=InitINI
	If isGplus< 2 Then tempstr = Regex.Split(CRLF, Text)
	Select Case isGplus
		Case 0'gplus
			For temp = 1 To tempstr.Length -1'ignore line 1
				tempINI2 = ParseActivityFeedItems(tempstr,temp) 
				If temp = tempINI2.EndLine Then
					temp=temp+1
				Else
					If tempINI2.Keys.Size>0 Or tempINI2.Sections.Size>0 Then	tempINI.Sections.Add(tempINI2)
					temp=tempINI2.EndLine
				End If
			'	Key= ParseTag( tempstr(temp),True )
			'	Select Case Key
			'		Case "kind","etag","nextpagetoken","title","updated","id"
			'			Value=ParseTag( tempstr(temp),False )
			'			SetValue(tempINI, Key, Value)
			'		Case "items"
			'			tempINI.Sections.Add( ParseActivityFeedItems(tempstr,temp+2))
			'			Return tempINI
			'	End Select
			Next
		'Case 1 'twitter
		'	For temp = 2 To tempstr.Length -2'ignore lines 1, 2 and the last one
		'		tempINI2= ParseTwitterStatus(tempstr,temp) 
		'		tempINI.Sections.Add(tempINI2)
		'		temp=tempINI2.EndLine
		'	Next
		'Case 2'facebook
			'ParseFacebook(Text, tempINI)
	End Select
	Return tempINI
End Sub






Sub GetFacebookAccessToken(Text As String)
	If Text.Length=0 Then
		If FacebookAccessToken.Length = 0 Or Not(FacebookAccessToken.Contains("|")) Then
			API.Download("Facebook", "https://graph.facebook.com/oauth/access_token?client_id=" & FacebookClientID & "&client_secret=" & FacebookClientSecret& "&grant_type=client_credentials")
		End If
	Else'access_token=244830352304933|W9mGMvqs4p9UHlSS9lcKOe-8y1Y
		FacebookAccessToken=Right(Text, Text.length - 13)
	End If
End Sub
Sub ParseFacebook(Text As String) As List 
	Dim JSON As JSONParser ,Map1 As Map,m As Map ,MenuItems As List,temp As Int,PictureURL As String,tempINI As List 
	JSON.Initialize(Text)
	Map1 = JSON.NextObject 
	tempINI.Initialize 
	m = Map1.Get("picture")
	m = m.Get("data")
	PictureURL = m.Get("url")
	If Map1.ContainsKey("posts") Then
		m = Map1.Get("posts")
		MenuItems = m.Get("data")
		For temp = 0 To MenuItems.Size - 1
			m = MenuItems.Get(temp)
			AddFBS(tempINI,ParseFacebookStatus(m, PictureURL))
			'tempINI.Sections.Add()
		Next
	End If
	Return tempINI
End Sub
Sub AddFBS(tempINI As List, data As PlusActivity)
	If data.IsInitialized Then tempINI.Add(data)
End Sub
Sub ParseFacebookStatus(m As Map,PictureURL As String ) As PlusActivity 'converts twitter feed into compatible GPLUS feed data
	'Dim tempINI As INIsection,Content As INIsection,Actor As INIsection,Image As INIsection , Attachments As INIsection, Replies As INIsection, PlusOners As INIsection , Resharers As INIsection
	Dim temp As Int, Done As Boolean ,Dir As String,Value As String, tempMap As Map ,tempComment As StringBuilder,Plus As PlusActivity ', Thumbnail As INIsection, FullImage As INIsection ,
	Dim tempattach As PlusAttachment, Thumb As ImageAttachment 
	
	If m.ContainsKey("status_type") Then
		Select Case m.Get("status_type")
			Case "shared_story","mobile_status_update" ,"wall_post","link","added_photos"
				Plus.Initialize 
				Plus.ReplyList.Initialize 
				Plus.Attachments.Initialize 
				Plus.Kind="plus#activity"
		
				'Actor info
				tempMap = m.Get("from")
				
				Plus.Actor.Initialize 
				Plus.actor.ID=tempMap.Get("id")
				Plus.Actor.displayName=tempMap.Get("name")
				Plus.Actor.ImageURL=PictureURL
				Plus.Actor.URL =PictureURL
				
				If m.ContainsKey("likes") Then
					tempMap = m.Get("likes")
					Plus.PlusOners=tempMap.Get("count")
				End If
				
				'status/object/content
				tempComment.Initialize 
				If m.ContainsKey("story") Then tempComment.Append( ParseTwitterText(m.Get("story")) )
				If m.ContainsKey("message") Then tempComment.Append( ParseTwitterText(m.Get("message")) )
				Plus.Content = tempComment.ToString
				Plus.Published= m.Get("created_time")
				
				If m.ContainsKey("link") Then
					tempattach.Initialize'objectType As String, URL As String, displayName As String, content As String, Thumbnail As ImageAttachment, Image As ImageAttachment
					Thumb.Initialize 
					tempattach.objectType="article"
					tempattach.URL="<BR><A HREF=""" & m.Get("link") & """>" & m.Get("link") & "</A>"
					tempattach.content=m.Getdefault("description","")
					tempattach.displayName = tempattach.content
					Thumb.URL=m.Get("picture")
					tempattach.Thumbnail = Thumb
					Plus.Attachments.Add(tempattach)
				End If
		End Select
	End If
	Return Plus
End Sub

'Sub ParseFacebookReplies(Replies As List, Text As String) As INIsection 
'	Dim JSON As JSONParser ,Map1 As Map,m As Map ,MenuItems As List,temp As Int,PictureURL As String
'	JSON.Initialize(Text)
'	Map1 = JSON.NextObject 
'	
'	m = Map1.Get("comments")
'	MenuItems = m.Get("data")
'	For temp = 0 To MenuItems.Size - 1
'		m = MenuItems.Get(temp)
'		Replies.Add(ParseFacebookReply(m))
'	Next
'End Sub
Sub ParseFacebookReply(Data As Map) As PlusReply 
	Dim temp As PlusReply
	temp.Initialize 
	temp.Actor.Initialize
	temp.Content =Data.Get("message")
	Data = Data.Get("from")
	temp.Actor.displayName  = Data.Get("name")
	temp.Actor.ID= Data.Get("id")
	temp.Actor.ImageURL= ErrorAsset
	Return temp
End Sub






Sub GetTwitterAccessCode(Job As HttpJob, TargetModule As Object)
	'Dim SSL As SocketSSL 
	'SSL.Initialize("SSL")
	'SSL.Connect("api.twitter.com", 443, 20)
	
	Job.Initialize("Twitter", TargetModule)
	'Job.PostString("http://request.urih.com/", "grant_type=client_credentials")
	Job.PostString("https://api.twitter.com/oauth2/token", "grant_type=client_credentials")
	Job.GetRequest.SetHeader("User-Agent", "LCARS UI")
	Job.GetRequest.SetHeader("Authorization", "Basic " & TwitterEncodedKey)
	Job.GetRequest.SetHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8")
	Job.GetRequest.SetHeader("Accept-Encoding", "Text/plain")
End Sub

Sub EncodeTwitterConsumerKeyAndSecret(Key As String, Secret As String)
	Dim STRutils As StringUtils , BYTutils As ByteConverter ,tempstr As String 
	TwitterClientID=Key
	TwitterClientSecret=Secret
	tempstr = STRutils.EncodeUrl(Key, "UTF8") & ":" & STRutils.EncodeUrl(Secret, "UTF8")
	'TwitterEncodedKey = STRutils.EncodeUrl( STRutils.EncodeBase64( BYTutils.StringToBytes(tempstr, "UTF8")) , "UTF8")
	TwitterEncodedKey = STRutils.EncodeBase64( BYTutils.StringToBytes(tempstr, "UTF8"))
	'b3pQVGFlVUJiN3pETnFvM002dTVKZzpoNnlUWFlZYjlvSnZtRnBHQTZLd2lPdVFRSXFxYU5kRGR2RVN1REl0RGs=
End Sub

Sub GetTwitterAccessToken(Text As String)
	'Dim TwitterThumb As String, TwitterConsumerKey As String, TwitterConsumerSecret As String 
	If Text.Length>0 Then TwitterAccessToken = API.GetBetween(Text, "access_token" & vbQuote & ":" & vbQuote, vbQuote)
End Sub

Sub ParseTwitterText(Text As String) As String 
	Dim temp As Int,tempstr As StringBuilder 
	Text = Text.Replace("&amp;", "&")
	tempstr.Initialize 
	Do Until Text.Length=0
		temp= Instr(Text, "http://",0)
		If temp = -1 Then temp= Instr(Text, "https://",0)
		If temp = -1 Then
			tempstr.Append(Text)
			Text=""
		Else
			tempstr.Append(Left(Text,temp))
			Text=Right(Text,Text.Length-temp)
			temp = Instr(Text, " ", 0)
			If temp = -1 Then temp = Instr(Text, "&", 0)
			If temp = -1 Then
				tempstr.Append(MakeTwitterURL(Text))
				Text=""
			Else
				tempstr.Append(MakeTwitterURL(Left(Text,temp)))
				Text=Right(Text,Text.Length-temp)
			End If
		End If
	Loop
	Return tempstr.ToString
End Sub
Sub MakeTwitterURL(URL As String)
	Return " <A HREF=" & URL & ">" & URL & "</A>"
End Sub
Sub ParseTwitter(Text As String) As List 'converts twitter feed into compatible GPLUS feed data
	Dim JSON As JSONParser ,Map1 As List,m As Map ,MenuItems As List,temp As Int,PictureURL As String, tempActivity As PlusActivity,tempINI As List 
	File.WriteString(File.DirRootExternal, "twitter.txt", Text)
	JSON.Initialize(Text)
	Map1 = JSON.NextArray  
	tempINI.Initialize 
	
	For temp = 0 To Map1.Size - 1
		tempINI.Add(ParseTwitterStatus(Map1.Get(temp)))
	Next
	Return tempINI
End Sub
Sub ParseTwitterStatus(tempMap As Map ) As PlusActivity 
	Dim Plus As PlusActivity, User As Map,tempattach As PlusAttachment, thumb As ImageAttachment ,tempstr As String ,tempList As List 
	'(MyMap) {contributors=null, text=@JamieFriend12  Yes. Mike Piller, Jeri Taylor and I all felt it was time., geo=null, retweeted=false, in_reply_to_screen_name=JamieFriend12, truncated=false, lang=en, 
		'entities={urls=[], hashtags=[], user_mentions=[{id=142705642, indices=[0, 14], screen_name=JamieFriend12, id_str=142705642, name=Jamie Somerville}], symbols=[]}
	', in_reply_to_status_id_str=369283739932565504, id=369286845449773056, in_reply_to_user_id_str=142705642, source=<a href="http://twitter.com/download/iphone" 
	'rel="nofollow">Twitter For iPhone</a>, favorited=False, in_reply_to_status_id=369283739932565504, retweet_count=2, in_reply_to_user_id=142705642, 
	'created_at=Mon Aug 19 02:36:59 +0000 2013, favorite_count=3, id_str=369286845449773056, place=Null, 
	'user={Location=, default_profile=True, profile_background_tile=False, statuses_count=249, lang=en, profile_link_color=0084B4, id=1287374131, following=Null,
		'favourites_count=1, protected=False, profile_text_color=333333, contributors_enabled=False, verified=False, 
		'description=Executive Producer of four Star Trek series AND four Star Trek films. Writer, Photographer, Scuba Diver, Husband AND Father, 
		'profile_sidebar_border_color=C0DEED, name=Rick Berman, profile_background_color=C0DEED, created_at=Fri Mar 22 00:52:11 +0000 2013, 
		'default_profile_image=False, followers_count=6987, profile_image_url_https=https://si0.twimg.com/profile_images/3416203507/37aed8424ead05ac0b6caa0b7ba0a868_normal.jpeg, 
		'geo_enabled=False, profile_background_image_url=http://a0.twimg.com/images/themes/theme1/bg.png, 
		'profile_background_image_url_https=https://si0.twimg.com/images/themes/theme1/bg.png, follow_request_sent=Null, 
		'entities={description={urls=[]}}, url=Null, utc_offset=Null, time_zone=Null, notifications=Null, profile_use_background_image=True, friends_count=28, 
		'profile_sidebar_fill_color=DDEEF6, screen_name=berman_rick, id_str=1287374131, 
		'profile_image_url=http://a0.twimg.com/profile_images/3416203507/37aed8424ead05ac0b6caa0b7ba0a868_normal.jpeg, is_translator=False, listed_count=156}, coordinates=Null}

	Plus.Initialize 
	Plus.ReplyList.Initialize 
	Plus.Attachments.Initialize 
	Plus.Kind="plus#activity"
	Plus.id=tempMap.Get("id")
	Plus.PlusOners = tempMap.GetDefault("favorite_count", 0)
	
	Plus.Content= ParseTwitterText(tempMap.Get("text"))
	Plus.Published= tempMap.Get("created_at")
	
	User=tempMap.Get("user")
	Plus.Actor.Initialize 
	Plus.actor.ID=User.Get("screen_name")
	Plus.Actor.displayName=User.Get("name")
	Plus.Actor.ImageURL=User.GetDefault("profile_image_url", User.GetDefault("profile_image_url_https", ErrorAsset))
	Plus.Actor.URL = Plus.Actor.ImageURL		
	If tempMap.ContainsKey("entities") Then
		User=tempMap.Get("entities")
		
		If User.ContainsKey("media") Then
			tempList.Initialize2(User.Get("media"))
			User = tempList.Get(0)
			'User.Get("media")'objectType As String, URL As String, displayName As String, content As String, Thumbnail As ImageAttachment, Image As ImageAttachment)
			tempattach.Initialize
			thumb.Initialize 
			tempattach.objectType="article"
			tempattach.URL = "<BR><A HREF=""" & User.Get("url") & """>" & User.Get("url") & "</A>"
			thumb.URL=User.Get("media_url")
			tempattach.Thumbnail=thumb
			Plus.Attachments.Add(tempattach)
		End If
	End If
	Return Plus
End Sub















Sub ParseActivityFeedItems(tempstr() As String, Line As Int) As INIsection 
	Dim tempINI As INIsection ,temp As Int  ,Key As String, Value As String, tempINI2 As INIsection ,NextRoot As Int 
	tempINI=InitINI
	For temp = Line To tempstr.Length -1
		Value=tempstr(temp).Trim 
		If Value = "}" Or Value = "}," Then
			tempINI.EndLine=temp
			Return tempINI
		Else If Value <> "{" Then
			Key= ParseTag(Value,True )
			Value= ParseTag(Value,False )
			Select Case Value
				Case ""
				Case "[","{"
					tempINI2=InitINI
					tempINI2=ParseActivityFeedItems(tempstr, temp+1)
					If tempINI2.Keys.Size>0 Or tempINI2.Sections.Size>0 Then
						tempINI2.Name =Key
						tempINI.Sections.Add(tempINI2)
					End If
					temp=tempINI2.EndLine
				Case Else
					If Value.Length>0 Then 
						If SetValue(tempINI, Key,Value, True) Then
							tempINI.EndLine=temp-1
							Return tempINI
						End If
					End If
			End Select
		End If
	Next
	tempINI.EndLine=tempstr.Length -1
	Return tempINI
End Sub

Sub CountSpaces(Text As String ) As Int
	Dim count As Int, temp As Int
	For temp = 0 To Text.Length-1
		If Mid(Text,temp,1) = " " Then
			count=count+1
		Else
			Return count
		End If
	Next
End Sub










Sub InitINI As INIsection 
	Dim tempINI As INIsection 
	tempINI.Initialize 
	tempINI.Sections.Initialize 
	tempINI.Keys.Initialize 
	tempINI.Values.Initialize 
	Return tempINI
End Sub
Sub SetValue(INI As INIsection, Key As String, Value As String,AbortIfExists As Boolean )As Boolean 
	Dim temp As Int 
	temp=INI.Keys.IndexOf(Key.ToLowerCase)
	If temp=-1 Then
		INI.Keys.Add(Key.ToLowerCase)
		INI.Values.Add(Value)
	Else
		If AbortIfExists Then 
			Return True
		Else
			INI.Values.Set(temp,Value)
		End If
	End If
End Sub
Sub GetValue(INI As INIsection, Key As String)As String 
	Dim temp As Int 
	temp=INI.Keys.IndexOf(Key.ToLowerCase)
	If temp>-1 Then Return INI.Values.Get( temp )
End Sub
Sub FindINIsection(INI As INIsection, Section As String) As Int 
	Dim temp As Int, tempINI As INIsection 
	For temp = 0 To INI.Sections.Size-1
		tempINI = INI.Sections.Get(temp)
		If tempINI.Name.EqualsIgnoreCase(Section) Then	Return temp
	Next
	Return -1
End Sub
Sub GetRootedValue(INI As INIsection, tPath As String, Key As String) As String 
	Dim tempstr() As String,temp As Int,temp2 As  Int, tempINI As INIsection 
	tempstr=Regex.Split("/", tPath)
	temp2=FindINIsection(INI, tempstr(0))
	If temp2>-1 Then
		tempINI= INI.Sections.Get(temp2)
		For temp = 1 To tempstr.Length-1
			temp2=FindINIsection(tempINI, tempstr(temp))
			If temp2>-1 Then tempINI= tempINI.Sections.Get(temp2) Else Return ""
		Next
		Return GetValue(tempINI, Key)
	End If
End Sub







Sub EnumActivities(INI As INIsection ) As List 
	Dim temp As Int , cINI As INIsection ,theList As List 
	theList.Initialize 
	For temp = 0 To INI.Sections.Size-1
		cINI = INI.Sections.Get(temp)
		EnumActivities2(cINI,theList)
	Next
	Return theList
End Sub

Sub EnumActivities2(INI As INIsection, theList As List)
	Dim eTag As String ,NextPageToken As String ,temp As Int , cINI As INIsection,Kind As String , tempActivity As PlusActivity ,tempAttachments As PlusAttachment 
	Kind=GetValue(INI, "kind")
	Select Case Kind
		Case "", "plus#activityFeed"
			If Kind=""  Then
				'Msgbox(DebugSections(INI), "DebugSections")
				tempAttachments=GetAttachment(INI)
				If tempAttachments<> Null Then
					tempActivity=theList.Get(theList.Size-1)
					tempActivity.Attachments.Add(tempAttachments)
				End If
			End If
			
			NextPageToken = GetValue(INI, "nextPageToken")
			eTag= GetValue(INI, "eTag")
			For temp = 0 To INI.Sections.Size-1
				cINI = INI.Sections.Get(temp)
				EnumActivities2(cINI,theList)
			Next
		Case "plus#activity"
			tempActivity=EnumActivity(INI,NextPageToken,eTag)
			theList.Add (tempActivity)
		Case "plus#acl"
			'GNDN			
		'Case Else 
		'	Msgbox (GetValue(INI, "kind"),"error")
	End Select
End Sub

Sub EnumActivity(INI As INIsection,NextPageToken As String, eTag As String )As PlusActivity 
	Dim Plus As PlusActivity ,temp As Int ,tempINI As INIsection 
	
	Plus.Initialize 
	Plus.NextPageToken=NextPageToken
	Plus.eTag=eTag
	Plus.ReplyList.Initialize 
	Plus.Attachments.Initialize 
	
	Plus.Kind=GetValue(INI, "kind")
	Plus.Title=GetValue(INI, "title")
	Plus.id=GetValue(INI, "id")
	Plus.Published=GetValue(INI, "published")
	Plus.updated=GetValue(INI, "updated")
	
	Plus.Actor=ParseActor(INI)
	'Plus.Actor.Initialize
	'Plus.Actor.ID = GetRootedValue(INI,"actor", "id")
	'Plus.Actor.displayName=GetRootedValue(INI,"actor", "displayName")
	'Plus.Actor.ImageURL =GetRootedValue(INI,"actor/image", "url")
	'Plus.Actor.URL=GetRootedValue(INI,"actor", "url")

	Plus.Content=GetRootedValue(INI,"object", "content")
	Plus.Replies = GetRootedValue(INI,"object/replies", "totalItems")
	Plus.PlusOners = GetRootedValue(INI,"object/plusoners", "totalItems")
	Plus.Resharers= GetRootedValue(INI, "object/resharers", "totalItems") 
	
	'temp=FindINIsection(INI, "attachments")
	'If temp>-1 Then 
	'	Msgbox("HAS ATTC", "YES")
	'	Plus.Attachments=EnumAttachments( INI.Sections.Get(temp) )
	'End If
	
	Dim tempattach As PlusAttachment
	tempINI=GetRootedSection(INI, "object/attachments")
	'Msgbox(DebugSections(tempINI), "DebugSections")
	tempattach=GetAttachment( tempINI )
	CheckArticle(tempINI,tempattach)	
	If tempattach<>Null Then  Plus.Attachments.Add(tempattach)
	tempattach=GetAttachment(INI )
	CheckArticle(tempINI,tempattach)
	If tempattach<>Null Then  Plus.Attachments.Add(tempattach)
	
	Return Plus
End Sub
Sub CheckArticle(INI As INIsection, Attachment As PlusAttachment)
	If INI <> Null AND Attachment<> Null Then
		If GetValue(INI, "objectType").EqualsIgnoreCase("article") Then
			Attachment.content =  GetValue(INI, "content")
			Attachment.objectType = GetValue(INI, "objectType")
			Attachment.URL = GetValue(INI, "URL")
		End If
	End If
End Sub

Sub DebugSections(INI As INIsection) As String 
	Dim tempstr As StringBuilder
	If INI<>Null Then
		tempstr.Initialize 
		enumSections(INI, "", tempstr)
		Return tempstr.ToString 
	End If
End Sub
Sub GetRootedSection(INI As INIsection, tPath As String) As INIsection 
	Dim tempstr() As String,temp As Int,temp2 As  Int, tempINI As INIsection 
	tempstr=Regex.Split("/", tPath)
	temp2=FindINIsection(INI, tempstr(0))
	If temp2>-1 Then
		tempINI= INI.Sections.Get(temp2)
		For temp = 1 To tempstr.Length-1
			temp2=FindINIsection(tempINI, tempstr(temp))
			If temp2>-1 Then tempINI= tempINI.Sections.Get(temp2) Else Return
		Next
		Return tempINI
	End If
End Sub
Sub enumSections(INI As INIsection, Name As String,tempstr As StringBuilder  ) 
	Dim temp As Int, tempini As INIsection 
	tempstr.Append( Name & CRLF)
	For temp = 0 To INI.Sections.Size-1
		tempini = INI.Sections.Get(temp)
		enumSections(tempini,Name & "/" & tempini.Name,tempstr )
	Next
End Sub


Sub EnumAttachments(INI As INIsection) As List 
	Dim temp As Int, theList As List , tINI As INIsection,tempAt As PlusAttachment, tempBK As PlusAttachment
	theList.Initialize 
	theList.Add( GetAttachment(INI))
	For temp = 1 To INI.Sections.Size-1
		tINI = INI.Sections.Get(temp)
		tempAt=GetAttachment(tINI)
		If tempAt <> Null Then
			If tempAt.Thumbnail.URL.Length >0 And tempAt.Image.URL.Length>0 Then
				If tempBK<> Null Then
					tempAt.objectType=tempBK.objectType 
					tempAt.content =tempBK.content
					tempAt.URL =tempBK.URL
				End If
				theList.Add( tempAt )
			Else
				tempBK=tempAt
			End If
		End If
	Next
	Return theList
End Sub
Sub GetAttachment(INI As INIsection) As PlusAttachment 
	Dim temp As PlusAttachment  
	If INI<>Null Then
		temp.Initialize 
		temp.objectType = GetValue(INI, "objectType")
		temp.content = GetValue(INI, "content")
		temp.URL = GetValue(INI, "URL")
		
		temp.Thumbnail.Initialize
		temp.Thumbnail.URL  = GetRootedValue(INI, "image", "url")
		temp.Thumbnail.Height= ToNumber( GetRootedValue(INI,"image", "height"))
		temp.Thumbnail.Width = ToNumber(GetRootedValue(INI,"image", "width"))

		temp.Image.Initialize 
		temp.Image.URL = GetRootedValue(INI,"fullImage", "url")
		temp.Image.Height= ToNumber(GetRootedValue(INI,"fullImage", "height"))
		temp.Image.Width = ToNumber(GetRootedValue(INI,"fullImage", "width"))
		
		If temp.Image.URL.Length>0 And temp.Thumbnail.URL.Length>0  Then
			Return temp		
		End If
	End If
End Sub
Sub ToNumber(Text As String) As Int
	If IsNumber(Text) Then Return Text
End Sub

Sub GetActivityID(ActivityID As String,CwdActivity As List) As Int
	Dim temp As Int, tempActivity As PlusActivity
	For temp = 0 To CwdActivity.Size-1
		tempActivity = CwdActivity.Get(temp)
		If tempActivity.id.EqualsIgnoreCase(ActivityID) Then Return temp
	Next
	Return -1
End Sub

Sub GetReplies(CwdActivity As List) As Boolean 
	Dim temp As Int, tempActivity As PlusActivity
	Select Case isGplus 
		Case 0,2'google plus, facebook
			For temp = 0 To CwdActivity.Size-1
				tempActivity = CwdActivity.Get(temp)
				If tempActivity.Replies >0 And tempActivity.ReplyList.Size=0 Then
					CwReplies = CommentsURL(tempActivity.id)
					CwReply=tempActivity.id
					API.Download("plusreplies", CwReplies)
					Return False
				End If
			Next
			Return True
	End Select
End Sub

Sub ParseReplies(Text As String, CwdActivity As List, ActivityID As String, GetNextReply As Boolean )As Boolean 
	Dim temp As Int, tempActivity As PlusActivity, INI As INIsection 
	Select Case isGplus 
		Case 0,2'google plus,facebook
			temp=GetActivityID(CwReply,CwdActivity)
			If temp>-1 Then
				tempActivity=CwdActivity.Get(temp)
				If Text.Length=0 Then 
					If API.CurrentJob.Success Then' Text= HttpUtils.GetString(CwReplies) Else Return False
						Text = API.CurrentJob.GetString
					Else 
						Return False
					End If 
				End If
				If isGplus=0 Then
					INI=ParseActivityFeed(Text)
					CheckForReplies(INI,tempActivity)
				'Else
				'	ParseFacebookReplies(tempActivity.ReplyList, Text)
				End If
				'Msgbox(DebugSections(INI), "PARSE REPLIES")
				If GetNextReply Then Return GetReplies(CwdActivity)
			End If
		Case Else: Return True
	End Select
End Sub
Sub CheckForReplies(INI As INIsection, tempActivity As PlusActivity)
	Dim temp As Int,Plus As PlusReply 
	If GetValue(INI, "kind").EqualsIgnoreCase("plus#comment") Then
		Plus.Actor=ParseActor(INI)
		Plus.Content = GetRootedValue(INI,"object", "content")
		tempActivity.ReplyList.Add(Plus)
	Else
		For temp = 0 To INI.Sections.Size-1
			CheckForReplies( INI.Sections.Get(temp), tempActivity)
		Next
	End If
End Sub

Sub ParseActor(INI As INIsection) As PlusActor 
	Dim temp As PlusActor 
	temp.Initialize
	temp.ID = GetRootedValue(INI,"actor", "id")
	temp.displayName=GetRootedValue(INI,"actor", "displayName")
	If temp.displayName.EqualsIgnoreCase("Tanya Myoko") Then temp.displayName = "Techni Myoko"
	temp.ImageURL =GetRootedValue(INI,"actor/image", "url")
	temp.URL=GetRootedValue(INI,"actor", "url")
	Return temp
End Sub