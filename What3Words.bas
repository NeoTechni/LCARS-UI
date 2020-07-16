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
	Public Key As String = "JOSXPM1E"
	Public TimeBetweenUpdates As Long = DateTime.TicksPerMinute 'set to 0 to update immediately
	Public RequiresWifi As Boolean = False
	
	Public LastWords As List , LastUpdate As Long, IsUpdating As Long  
	
	Public HTTPJ As HttpJob 
End Sub

Sub InitHTTP(Target As Object)
	HTTPJ.Initialize("w3w", Target)
	LastWords.Initialize 
End Sub
Sub CancelJob
	HTTPJ.Release 
	LastUpdate =0
End Sub

Sub NeedsUpdate As Boolean
	If IsUpdating > DateTime.Now - TimeBetweenUpdates Then Return False
	If API.ListSize(LastWords) = 0 Then Return True
	Return LastUpdate + TimeBetweenUpdates <= DateTime.Now 
End Sub

Sub AllWords As String 
	Dim tempstr As StringBuilder , temp As Int  
	If API.ListSize(LastWords)=0 Then Return ""
	tempstr.Initialize 
	For temp = 0 To LastWords.Size -1  
		tempstr.Append( API.IIF(temp=0, "", ".") & LastWords.Get(temp))
	Next
	Return tempstr.ToString 
End Sub

'coordinates must be in degrees
Sub RequestURL(Lattitude As String, Longitude As String) As String 
	Dim URL As String 'http://api.what3words.com/w3w?key=JOSXPM1E&lang=EN&position=51.484463,-0.195405
	If NeedsUpdate And API.IsConnected Then
		If RequiresWifi Then
			If Not(API.IsOnWifi) Then Return ""
		End If
		IsUpdating = DateTime.Now 
		URL = "http://api.what3words.com/v2/reverse?key=" & Key & "&lang=en&coords=" & Lattitude & "," & Longitude
		HTTPJ.Download(URL)
	End If
	Return URL
End Sub

Sub ProcessWords(Text As String)
	Dim JSON As JSONParser , Map1 As Map ,  temp As Int , tempstr As StringBuilder 
	JSON.Initialize(Text)
	Map1 = JSON.NextObject 
	LastWords = Map1.Get("words")
	LastUpdate = DateTime.Now 
End Sub