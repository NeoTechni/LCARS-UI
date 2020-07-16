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

	'Starfield stuff
	Type Star(Loc As Point,Distance As Int, Angle As Int, Speed As Int, Trail As Int,Alpha As Int, Multiplier As Float  )
	Dim StarS As List , StarAngle As Int, StarCenter As Point ,StarSpeedC As Float ,StarSpeedD As Float ,StarGrad As Bitmap ,StarBG As Boolean,StarBGP As Point, StarWidth As Int
	Dim StarHeight As Int,StarSize As Int,StarFull As Boolean , StarEffect As Int, StarFrame As Int, StarMaxFrames As Int ,StarUpdate As Int ,StarScalefactor As Float 
	'0=out from center,
	
	'mini starfield
	Type MiniStar(X As Float, Y As Float, Radius As Int)
	Type MiniStarField(ID As Int, StarS As List)
	Dim MiniStarfields As List 
	
	'Special Toasts
	Dim Qangle As Int 'Quark
	Dim SWtoggle As Boolean ,SWF As Int ,SWFont As Typeface 'StarWars
	Dim ST_MouseX As Int, ST_MouseY As Int , ST_PathX As Int 'Starship troopers
	Dim KR_LastUpdate As Long, KR_Index As Int, KR_Delay As Int = 100, KR_LUnits As Int = 8, KR_Direction As Boolean 'Knight Rider
	
	'Metaphasic shields
	Dim CurrentURL As String,URLIndex As Int=-1 ,JPGHighQuality As Boolean , SOHOAnimated As Boolean ,HideEnterprise As Boolean ,MaxStages As Int=20
	
	'TMP (TWOK game)
	Dim TMPframe As Int=-1, TMPlist As Int =-1,TMPGroup As Int =-1,TMPisVisible As Boolean 'Msgbox
	Dim MaxShields As Int=44, LastUpdated As Long ,UpdateDelay As Int = 150 'Reliant
	Dim FullscreenMode As Boolean, Nebula As TweenAlpha, MaxNebulaX As Int=160, Reliant As TweenAlpha, Flash As TweenAlpha,ReliantDamaged As Boolean   'FireControl/ViewScreen
	Dim YourATKt As Int=-1, YourATKc As TweenAlpha , TheirATKt As Int=-1, TheirATKc As TweenAlpha , TMP_Phasers As Int = 0, TMP_PhoTorps As Int =1, TMP_Evade As Int =2
	Dim EndGame As Int =-1,DoFlash As Boolean ,YourATKa As TweenAlpha ,TheirATKa As TweenAlpha 
	
	'ChronowerX
	Type CHX_Window(Index As Int, WindowType As Int,ElementIndex As Int, Val1 As Int, Val2 As Int, Val3 As Int, Val4 As Int)
	Dim CNX_OldSize As Point,CNX_Pos As Point, CHX_Up As Boolean , CHX_Right As Boolean , CHX_Beige As Int= Colors.RGB( 169,197,175), CHX_LightBlue As Int = Colors.RGB(61,186,208),CHX_DarkBlue As Int = Colors.RGB(15,65,124)
	Dim CHX_Font As Typeface, CHX_Icons As Bitmap, CHX_IconbarID As Int = -1 ,CHX_GroupID As Int =-1,CHX_Digits As Int,CHX_Width2 As Int, CHX_Height2 As Int ', CHX_DarkTeal As Int = Colors.RGB(30,68,77), CHX_LightTeal As Int = Colors.RGB(93,112,118)
	Dim CHX_LightRed As Int = Colors.RGB(159,145,144), CHX_DarkRed As Int = Colors.RGB(104,40,2), CHX_MenubarID As Int = -1, CHX_Fontsize As Int , CHX_LightBeige As Int = Colors.RGB(146,230,204), CHX_LogoMode As Int,CHX_Attempts As Int, CHX_Dimensions As Rect 
	Dim CHX_AnimatedWindows As Int,CHX_WindowCount As Int , CHX_WinBlank As Int = 0, CHX_WinSIN As Int = 1, CHX_WinSAT As Int = 2, CHX_WinTSH As Int = 3, CHX_WinGAN As Int=4, CHX_WinCLP As Int = 5, CHX_WinNUM As Int = 6
	Dim MAC_Height As Int, MAC_TextHeight As Int, CHX_ElementID As Int, CHX_MaxWindows As Int = 5, PixelFont As Typeface = Typeface.LoadFromAssets("pixelmen.ttf")
	
	'TOS/ENT
	Type TOSButton(Name As String, Visible As Boolean, Before As Int, After As Int, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int)
	Type TOSPage(TOStype As Int, Buttons As List, LastUpdate As Long, Touched As Int)
	Dim TOSPages As List , RND_ID As Int, ENTFrames As Int, ENTSize As Int, ENTfontsize As Int 
End Sub
Sub IncrementENT
	Dim OldValue As Int = ENTFrames
	If LCAR.RedAlert Then 
		ENTFrames = LCAR.Increment(ENTFrames, 1, 0)
		If ENTFrames = 0 Then 
			If OldValue < 0 Then 'LCAR.FPS
				ENTFrames = 15 * Rnd(2,4)'2-4 seconds of frames 
			Else 
				ENTFrames = -15'half a second of frames
			End If 
		End If
	End If 
End Sub



Sub IsPNG(Filename As String, EXT As String) As Boolean 
	'If EXT.Length =0 Then EXT = API.GetSide(Filename, ".",False,False)
	Return Filename.Contains("[") And Filename.Contains("]")'EXT.EqualsIgnoreCase("png") AND 
End Sub
Sub LoadMSD(Filename As String) As Boolean 
	Dim Parameters As List , Width As Int, Height As Int, Angle As Int ,CenterX As Int ,CenterY As Int 
	StarBG=False
	'Log(StarBG & " " & Filename)
	If IsPNG(Filename, "") Then
		Height=WallpaperService.msdHeight-WallpaperService.top-WallpaperService.bottom

		If File.Exists(LCAR.DirDefaultExternal, Filename) And Filename.Contains(".") Then
			LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, Filename ,LCAR.LCAR_MSD)'CenterPlatform
			StarBG=LCARSeffects2.CenterPlatform.IsInitialized
			'Log("StarBG: " & StarBG & " " &  Filename)
		End If
		
		Do Until WallpaperService.msdWidth > LCARSeffects2.CenterPlatform.Width 
			WallpaperService.msdWidth=WallpaperService.msdWidth*2
		Loop
		Width=WallpaperService.msdWidth-1
			
		
		Parameters = SplitParameters(API.GetBetween(Filename, "[", "]"))
'		Log("P: = " & API.GetBetween(Filename, "[", "]"))
'		For angle = 0 To Parameters.Size-1
'			Log("P: " & angle & " = " & Parameters.Get(angle))
'		Next
		
		Angle=GetParameter(Parameters, "D", -1)'direction of stars
		If Angle>359 Then Angle=-2
		
		StarFull=False
		StarEffect=-1
		StarFrame=0
		StarUpdate = DateTime.GetSecond(DateTime.now)
		
		If StarBG Then
			Select Case GetParameter(Parameters, "S", 0)'sector to draw picture
				Case 0'fullscreen
					StarScalefactor=(LCARSeffects2.CenterPlatform.Width/LCARSeffects2.CenterPlatform.Height)
					WallpaperService.msdWidth = Height * StarScalefactor'(LCARSeffects2.CenterPlatform.Width/LCARSeffects2.CenterPlatform.Height)
					Width=WallpaperService.msdWidth-1
					StarFull=True
					StarEffect=GetParameter(Parameters, "E", -1)
					'Log("Effect: " & StarEffect)
					Select Case StarEffect'handled in DrawEffect
						Case 0:StarMaxFrames=10 'Galaxy Class Bridge
						Case 1:StarMaxFrames=20 'Constitution-refit Class (movies) Bridge
						Case 2:StarMaxFrames=5'Galaxy-refit Class Bridge (from parallels)
					End Select
				
				Case 1:StarBGP = Trig.SetPoint(0,0) 'top left
				Case 2:StarBGP = Trig.SetPoint(Width/2 - LCARSeffects2.CenterPlatform.Width/2, 0)'top middle
				Case 3:StarBGP = Trig.SetPoint(Width - LCARSeffects2.CenterPlatform.Width, 0)'top right
				
				Case 4:StarBGP = Trig.SetPoint(0,Height/2 - LCARSeffects2.CenterPlatform.Height/2) 'middle left
				Case 5:StarBGP = Trig.SetPoint(Width/2 - LCARSeffects2.CenterPlatform.Width/2, Height/2 - LCARSeffects2.CenterPlatform.Height/2)'middle middle
				Case 6:StarBGP = Trig.SetPoint(Width - LCARSeffects2.CenterPlatform.Width, Height/2 - LCARSeffects2.CenterPlatform.Height/2)'middle right
				
				Case 7:StarBGP = Trig.SetPoint(0,Height - LCARSeffects2.CenterPlatform.Height) 'bottom left
				Case 8:StarBGP = Trig.SetPoint(Width/2 - LCARSeffects2.CenterPlatform.Width/2, Height - LCARSeffects2.CenterPlatform.Height)'bottom middle
				Case 9:StarBGP = Trig.SetPoint(Width - LCARSeffects2.CenterPlatform.Width, Height - LCARSeffects2.CenterPlatform.Height)'bottom right
				
				Case 10'fill top
					WallpaperService.msdWidth = LCARSeffects2.CenterPlatform.Width
					Width=WallpaperService.msdWidth-1
					StarBGP = Trig.SetPoint(0,0)
				Case 11'fill bottom
					WallpaperService.msdWidth = LCARSeffects2.CenterPlatform.Width
					Width=WallpaperService.msdWidth-1
					StarBGP = Trig.SetPoint(0,Height - LCARSeffects2.CenterPlatform.Height)
			End Select
		End If
		
		CenterX=GetParameter(Parameters, "CX", 50) * 0.01 * Width'center position
		CenterY=GetParameter(Parameters, "CY", 50) * 0.01 * Height
		
		'Log(angle & " " & CenterX & " " & CenterY & " - " &  StarBGP.X & " " & StarBGP.Y)
		InitStars(Angle, CenterX,CenterY, 1, StarBG, 100, Width , Height)
	End If
	Return StarBG
End Sub
Sub SplitParameters(Text As String) As List
	Dim oType As Int, cType As Int , cChar As String, tempstr As String, tList As List 
	tList.Initialize 
	oType = Eval.CharType(API.left(Text,1))
	Do While Text.Length>0 
		cChar=API.left(Text,1)
		cType = Eval.CharType(cChar)
		Text=API.Right(Text, Text.Length-1)
		
		If Text.Length=0 Then
			If oType = cType Then
				tList.Add(tempstr & cChar)
			Else
				tList.Add(tempstr)
				tList.Add(cChar)
			End If
			Return tList
		Else
			If oType <> cType Then
				tList.Add(tempstr)
				tempstr=cChar
				oType=cType
			Else
				tempstr=tempstr & cChar
			End If
		End If
	Loop
	Return tList
End Sub
Sub GetParameter(Parameters As List, Par As String, Default As Int) As Int 
	Dim temp As Int ,tempstr As String 
	For temp = 0 To Parameters.Size-1
		tempstr=Parameters.Get(temp)
		If tempstr.EqualsIgnoreCase(Par) Then Return Parameters.Get(temp+1)
	Next
	Return Default
End Sub

Public Sub InitStars(Angle As Int, CenterX As Int, CenterY As Int, Speed As Float, UseBG As Boolean, StarCount As Int, Width As Int, Height As Int  )
	Dim tempCanvas As Canvas ,temp As Int
	StarS.Initialize 
	If Angle=-3 Then'randomize all
		Speed=1
		temp=Rnd(0,3)
		Select Case temp '3
			Case 0'out from center
				Angle=-1
				CenterX=Width/2
				CenterY=Height/2
			Case 1'towards center
				Angle=-2
				CenterX=Width/2
				CenterY=Height/2
			Case 2'fixed direction
				Angle= API.IIFIndex( Rnd(0,2), Array As Int( 90,   270) )
		End Select
	End If
	'Log("INIT STARS " & Angle)
	StarSize=Trig.FindDistance(0,0,Max(CenterX,Width-CenterX),Max(CenterY,Height-CenterY))
	StarWidth=Width
	StarHeight=Height
	If Not(StarGrad.IsInitialized ) Then
		StarGrad.InitializeMutable(64,1)
		tempCanvas.Initialize2(StarGrad)
		LCAR.DrawGradient(tempCanvas, Colors.Black,Colors.Black, 6, 0,0, StarGrad.Width+1 ,StarGrad.Height+1,0,0)
'		Dim Out As OutputStream 
'		Out = File.OpenOutput(File.DirRootExternal, "GRADTEST.BMP", False)
'		tempCanvas.Bitmap.WriteToStream(Out, 100, "PNG")
'		Out.Close 
	End If
	StarAngle=Angle
	StarCenter=Trig.SetPoint(CenterX,CenterY)
	StarSpeedC=Speed
	StarSpeedD=StarSpeedC
	StarBG=UseBG
	For temp = 1 To StarCount
		StarS.Add( MakeStar )
	Next
End Sub
Public Sub MakeStar As Star 
	Dim temp As Star 
	temp.Initialize 
	temp.Alpha=255
	If StarAngle<0 Then 'out from/towards center
		temp.Angle = Rnd(0,360)
		temp.Multiplier = 0.5'outwards from center
		If StarAngle=-2 Then 'towards center
			temp.Multiplier=3
			temp.Distance=StarSize	
			temp.Alpha=255
		End If
	Else
		Select Case StarAngle
			Case 90:temp.Loc= Trig.SetPoint(0,  Rnd(0,StarHeight) )'go right, from left
			Case 270:temp.Loc= Trig.SetPoint(StarWidth, Rnd(0,StarHeight) )'go left, from right
			Case Else:Trig.FindAnglePoint( StarCenter.x,StarCenter.y, StarSize, Trig.CorrectAngle(temp.Angle+180))
		End Select
	End If
	temp.Speed = Rnd(1,11)
	temp.Trail = temp.Speed* Rnd(1,4)
	Return temp 
End Sub
Public Sub IncrementStars(DoStars As Boolean) As Boolean 
	Dim temp As Int ,tempStar As Star ,NeedsNew As Boolean, StarInc As Float = 0.05
	If StarS.IsInitialized And DoStars Then
		For temp = 0 To StarS.Size-1
			tempStar=StarS.Get(temp)
			NeedsNew=False
			If StarAngle<0 Then StarInc = tempStar.Speed * 0.005
			Select Case StarAngle
				Case -1'out from center
					tempStar.Multiplier = tempStar.multiplier + StarInc
					tempStar.Distance = tempStar.Distance + tempStar.Speed*StarSpeedC
					tempStar.Alpha=Min(255,tempStar.Distance)
					NeedsNew= tempStar.Distance > StarSize + tempStar.Trail 
				Case -2'towards center
					tempStar.Multiplier = Max(tempStar.multiplier - StarInc, 0.5)
					tempStar.Distance = tempStar.Distance - tempStar.Speed*StarSpeedC
					tempStar.Alpha=Min(255 ,tempStar.Distance)
					NeedsNew = tempStar.Distance<1
				Case 90
					tempStar.Loc.X=tempStar.Loc.X+ tempStar.Speed*StarSpeedC
					NeedsNew = tempStar.Loc.X+tempStar.Trail  > StarWidth
				Case 180
					tempStar.Loc.X=tempStar.Loc.X- tempStar.Speed*StarSpeedC
					NeedsNew = tempStar.Loc.X+tempStar.Trail < 0
				Case Else
					tempStar.Loc = Trig.FindAnglePoint(tempStar.Loc.X, tempStar.Loc.Y, tempStar.Speed*StarSpeedC, StarAngle)
			End Select
			If NeedsNew Or tempStar.Alpha=0  Then StarS.Set(temp, MakeStar)
		Next
	End If
	If StarEffect>-1 And StarMaxFrames>0 Then
		temp= DateTime.GetSecond(DateTime.Now) 
		If temp <> StarUpdate  Then
			StarUpdate=temp
			StarFrame = (StarFrame+1) 
			If StarFrame>= StarMaxFrames  Then StarFrame=0
		End If
	End If
	Return True 
End Sub
Public Sub DrawStars(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int, tempStar As Star ,Dest As Rect ,Size As Int ,Distance As Int ,Angle As Int, DidDraw As Boolean ,Size2 As Int 
	LCAR.DrawRect(BG, X,Y,Width+2,Height+2, Colors.Black ,0)
	If StarS.IsInitialized And Width>StarWidth-5  And Width < StarWidth+5 Then 
		StarWidth=Width
		LCARSeffects.MakeClipPath(BG,X,Y,Width+2,Height+2)
		For temp = 0 To StarS.Size-1
			DidDraw=False
			tempStar = StarS.Get(temp)
			Size=Max(1, tempStar.speed*0.5)
			Size2=(tempStar.Trail+1) * tempStar.Multiplier
			Distance=tempStar.Distance 
			If LCAR.AntiAliasing And StarAngle<0 Then Distance=Distance+(Size*0.5)
			If StarAngle<0 Then tempStar.loc = Trig.FindAnglePoint( StarCenter.X, StarCenter.Y, Distance, tempStar.Angle)
			If (tempStar.Loc.X<-Size2*2  Or tempStar.Loc.X > Width+tempStar.Trail Or tempStar.Loc.Y <-Size2*2 Or tempStar.Loc.Y > Height+tempStar.Trail) And StarAngle>-2  Then 
				StarS.Set(temp, MakeStar)
			Else If LCAR.AntiAliasing Then 'AND StarGrad.IsInitialized Then
				Select Case StarAngle
					Case -1,-2'out from/towards center
						'DrawStar(BG,X,Y,  tempStar,Size)
						If Distance > tempStar.Trail Then
							DidDraw=True
							Angle= (tempStar.Angle+90) Mod 360
							Dest=LCAR.SetRect(X+tempStar.Loc.X, Y+tempStar.Loc.Y, Size2, Size+1)
							BG.DrawBitmapRotated(StarGrad, Null,Dest, Angle)
						End If
					Case 90'go right
						DidDraw=True
						Dest=LCAR.SetRect(X+tempStar.Loc.X, Y+tempStar.Loc.Y, tempStar.Trail+1, Size+1)
						BG.DrawBitmapFlipped(StarGrad, Null, Dest, False,True)
					Case 270'go left
						DidDraw=True
						Dest=LCAR.SetRect(X+tempStar.Loc.X-tempStar.Trail, Y+tempStar.Loc.Y, tempStar.Trail+1, Size+1)
						BG.DrawBitmap(StarGrad, Null, Dest)
					Case Else
						'Log("ANGLE FAILURE")
						temp=StarS.Size 
				End Select
				If Dest.IsInitialized  And tempStar.Alpha<255 And DidDraw Then
					Distance= Colors.ARGB(255-tempStar.Alpha, 0,0,0)
					If StarAngle>-1 Then
						BG.DrawRect(Dest,Distance,True, 0)
					Else
						BG.DrawRectRotated( Dest,  Distance,  True, 0, Angle)
					End If
				End If
			Else	
				BG.DrawCircle(X+ tempStar.Loc.X, Y+ tempStar.Loc.Y, Size , Colors.RGB(tempStar.Alpha,tempStar.Alpha,tempStar.Alpha),True,0)
			End If
		Next
		BG.RemoveClip 
		DrawStarBG(BG,X,Y,Width,Height, False)
	Else
		InitStars(-3, 0,0,0,StarBG, 100, Width,Height)
	End If
End Sub

Sub DrawStarBG(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ForceFullscreen As Boolean)
	If StarBG Then
		If StarFull Or ForceFullscreen Then
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X,Y,Width+2,Height+2))
			DrawEffect(BG,X,Y,Width+1,Height+1)
		Else
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X+StarBGP.X,Y+StarBGP.Y,LCARSeffects2.CenterPlatform.Width+1,LCARSeffects2.CenterPlatform.Height+1))
		End If
	End If
End Sub
Sub DrawEffect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Double,temp2 As Double ,Color As Int  '255,245,193 	246,211,81
	Select Case StarEffect
		Case 0'D Bridge
			Color=Colors.RGB(246,211,81)
			If StarFrame Mod 2 = 0 Then
				LCAR.DrawRect(BG, X + Width * 0.647, Y+Height*0.83, Width*0.00624 +1 , Height * 0.00469 +1, Color,0)
			Else
				LCAR.DrawRect(BG, X + Width * 0.343, Y+Height*0.828, Width*0.0052 +1, Height * 0.00625 +1, Color,0)
			End If
		
			X=X+ Width*0.436
			Y=Y+ Height*0.83516'0.82656
			Width = Width * 0.145
			Height = Height * 0.008595'0.01719
			
			temp=Width/(StarMaxFrames*2)
			Color=Colors.RGB(255,245,193)
			
			LCAR.DrawRect(BG, X + temp*StarFrame      ,Y, temp,Height, Color, 0)
			LCAR.DrawRect(BG, X + Width- (temp+1)*StarFrame      ,Y, temp,Height, Color, 0)
		
		Case 1'A bridge
			DrawTime(BG, X + Width*0.42604, Y+ Height*0.11138, Width*0.13802, Height * 0.06416, DateTime.Now)'X= 0.42604 , Y= 0.11138 Width= 0.13802 Height= 0.06416
			
			X=X+Width* 0.2375
			Y=Y+ Height* 0.84504
			Width = Width * 0.51927
			Height = Height * 0.03027
			
			temp=Width/(StarMaxFrames*2)
			Color=Colors.RGB(245,242,173)
			temp2=temp*0.25
			
			LCAR.DrawRect(BG, X + temp*StarFrame + temp2   ,Y+temp2, temp2*2,temp2*2, Color, 0)
			LCAR.DrawRect(BG, X + Width- (temp+1)*StarFrame + temp2     ,Y+ temp2, temp2*2,temp2*2, Color, 0)
		Case 2'D-refit bridge from parallels
			Color= Colors.RGB(255,224,156)
			If StarFrame=0 Then LCAR.DrawRect(BG, X + Width * 0.506, Y+Height*0.78, Width*0.00832 +1 , Height * 0.00625 +1, Color,0)
			If StarFrame=0 Or StarFrame = 3 Then
				LCAR.DrawRect(BG, X + Width * 0.647, Y+Height*0.83, Width*0.00624 +1 , Height * 0.00469 +1, Color,0)
				LCAR.DrawRect(BG, X + Width * 0.343, Y+Height*0.828, Width*0.0052 +1, Height * 0.00625 +1, Color,0)
			End If
			
			X=X+ Width*0.47763
			Y=Y+ Height*0.82812
			Width = Width * 0.06348
			Height = Height * 0.06875
			Select Case StarFrame
				Case 0'first frame, middle square
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.43, Width*0.14754 +1 , Height * 0.18182 +1, Color,0)
				Case 1
					LCAR.DrawRect(BG, X + Width * 0.31148, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.57377, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.29364, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.61182, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
				Case 2
					LCAR.DrawRect(BG, X + Width * 0.19672, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.67213, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.13636, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.75000, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
				Case 3
					Color = Colors.RGB(247,208,179)
					LCAR.DrawRect(BG, X + Width * 0.09836, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.78689, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.00000, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
					LCAR.DrawRect(BG, X + Width * 0.42623, Y+Height*0.86364, Width*0.14754 +1 , Height * 0.13636 +1, Color,0)'y
				Case 4
					Color = Colors.RGB(255,94,76)
					LCAR.DrawRect(BG, X - Width * 0.03279, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
					LCAR.DrawRect(BG, X + Width * 0.90164, Y+Height*0.43, Width*0.11475 +1 , Height * 0.18182 +1, Color,0)'x
			End Select
	End Select
End Sub

Sub DrawDigitItem(BG As Canvas, RWidth As Int, Text As String, SideText As String, X As Int, Y As Int, Width As Int, Height As Int, ItemIndex As Int, Alpha As Int, ColorID As Int, State As Boolean)
	Dim Dark As Int = LCAR.GetColor(ColorID, State,Alpha * 0.125), Light As Int = LCAR.GetColor(ColorID,State,Alpha)
	'If ItemIndex Mod 1 = 0 Then LCAR.DrawRect(BG, X,Y,Width,Height, GetGrey(0.1, Alpha), 0)
	If SideText.Length=0 Then RWidth=0
	DrawDigits(BG,X+10,Y+10, Width-20 - RWidth , Height-10, Text, 0, Light, Dark)
	DrawDigits(BG,X+Width-RWidth+10,Y+10, RWidth-10, Height-10, SideText, 0, Light, Dark)
End Sub

Sub DigitsNeeded(Text As String) As Int
	''m,q,t,w,x,v count as 2
	Dim temp As Int = Text.Length 
	Text=Text.ToLowerCase 
	temp = temp + API.CountOccurences(Text, "m") + API.CountOccurences(Text, "w")
	temp = temp + API.CountOccurences(Text, "q") + API.CountOccurences(Text, "x")
	Return temp + API.CountOccurences(Text, "t") + API.CountOccurences(Text, "v")
End Sub

Sub DrawDigits(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, Digits As Int, BrightColor As Int, DarkColor As Int)
	Dim CellWidth As Int, Skew As Int ,temp As Int ,Stroke As Int =4,WhiteSpace As Int =10,Digit As String ,Increment As Int 
	LCAR.DrawRect(BG,X,Y,Width+Stroke+WhiteSpace,Height+Stroke+WhiteSpace,Colors.Black,0)
	If Text.Length>0 Then
		If Digits < Text.Length Then Digits = DigitsNeeded(Text)'Text.Length 
		Y=Y+2
		X=X+2
		Width=Width-2
		Height=Height-4
		Skew= Height / 5.5
		CellWidth= (Width-Skew- (Digits*(Stroke+WhiteSpace)))/Digits
		Increment=CellWidth+Stroke+WhiteSpace
		For temp = 0 To Text.Length-1
			Digit=API.Mid(Text,temp,1)
			Select Case Digit.ToLowerCase 
				Case "m", "q", "t", "w", "x", "v"
					Draw1Digit(BG,X,Y,CellWidth,Height, Digit & "1", BrightColor,DarkColor,Skew,Stroke)
					X=X+Increment-WhiteSpace
					Draw1Digit(BG,X,Y,CellWidth,Height, Digit & "2", BrightColor,DarkColor,Skew,Stroke)
					X=X+WhiteSpace
				Case Else
					Draw1Digit(BG,X,Y,CellWidth,Height, Digit, BrightColor,DarkColor,Skew,Stroke)
			End Select
			X=X+Increment
		Next
	End If
End Sub

Sub DrawTime(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Now As Long)
	Dim CellWidth As Int, Skew As Int ,BrightRed As Int ,DarkRed As Int , Second As Int ,DoColon As Boolean 
	LCAR.DrawRect(BG, X,Y,Width+(Height/5.5),Height, Colors.RGB(25,18,0), 0)
	BrightRed= Colors.RGB( 183,46,30)
	DarkRed = Colors.RGB(47, 22,0)
	
	CellWidth=Width* 0.12' /25*3   '(6*3+ 7)=18+7=25
	Y=Y+2
	X=X+2
	Width=Width-2
	Height=Height-4
	Skew= Height / 5.5
	Second=DateTime.GetSecond(Now)
	DoColon= Second Mod 2 = 0 
	
	Draw2Digits(BG, X,Y, CellWidth, Height, DateTime.GetHour(Now), BrightRed,DarkRed, Skew,4, DoColon)
	Draw2Digits(BG, X+ CellWidth*3,Y, CellWidth, Height, DateTime.GetMinute(Now), BrightRed,DarkRed, Skew,4, DoColon)
	Draw2Digits(BG, X+ CellWidth*6,Y, CellWidth, Height, Second, BrightRed,DarkRed, Skew,4, False)
End Sub
Sub Draw2Digits(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Value As Int, ColorT As Int, ColorF As Int, Skew As Int, Stroke As Int, DoColon As Boolean)
	Dim Tens As Int, Ones As Int, Third As Int
	Tens = Floor(Value / 10 )
	Ones = Value Mod 10
	Third=Width/3
	Draw1Digit(BG,X,Y,Width,Height, Tens, ColorT,ColorF,Skew,Stroke)
	Draw1Digit(BG,X+Width+Third,Y,Width,Height, Ones, ColorT,ColorF,Skew,Stroke)
	If DoColon Then Draw1Digit(BG,X+(Width+Third)*2,Y,Third,Height, ":", ColorT,ColorF,Skew,Stroke)
End Sub
Sub Draw1Digit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Value As String, ColorT As Int, ColorF As Int, Skew As Int, Stroke As Int)
	Dim Bits() As Boolean , O As Boolean=False, I As Boolean = True
	Select Case Value.ToLowerCase'      0 1 2 3 4 5 6  
		Case 0: Bits = Array As Boolean(O,I,I,I,I,I,I)'middle hor
		Case 1: Bits = Array As Boolean(O,O,O,O,I,I,O)'top left ver
		Case 2: Bits = Array As Boolean(I,O,I,I,O,I,I)'bottom left ver
		Case 3: Bits = Array As Boolean(I,O,O,I,I,I,I)'bottom hor
		Case 4: Bits = Array As Boolean(I,I,O,O,I,I,O)'bottom right ver
		Case 5: Bits = Array As Boolean(I,I,O,I,I,O,I)'top right ver
		Case 6: Bits = Array As Boolean(I,I,I,I,I,O,I)'top hor
		Case 7: Bits = Array As Boolean(O,O,O,O,I,I,I)
		Case 8: Bits = Array As Boolean(I,I,I,I,I,I,I)
		Case 9: Bits = Array As Boolean(I,I,O,O,I,I,I)
		
		'symbols						 0 1 2 3 4 5 6 
		Case "/": Bits= Array As Boolean(I,O,I,O,O,I,O)
		Case "\": Bits= Array As Boolean(I,I,O,O,I,O,O)
		Case ".": BG.DrawOval(LCAR.SetRect(X+Width*0.75,Y+Height*0.75, Stroke,Stroke), ColorT, True,0)
		Case ":"
			BG.DrawOval(LCAR.SetRect(X+Width,Y+Height*0.25, Stroke,Stroke), ColorT, True,0)
			BG.DrawOval(LCAR.SetRect(X+Width*0.75,Y+Height*0.75, Stroke,Stroke), ColorT, True,0)
			Return 
			
		'letters						0 1 2 3 4 5 6 
		Case " ":Bits= Array As Boolean(O,O,O,O,O,O,O)
		Case "a":Bits= Array As Boolean(I,I,I,O,I,I,I)
		Case "b":Bits= Array As Boolean(I,I,I,I,I,O,O)
		Case "c":Bits= Array As Boolean(O,I,I,I,O,O,I)
		Case "d":Bits= Array As Boolean(I,O,I,I,I,I,O)
		Case "e":Bits= Array As Boolean(I,I,I,I,O,O,I)
		Case "f":Bits= Array As Boolean(I,I,I,O,O,O,I)
		Case "g":Bits= Array As Boolean(I,I,O,O,I,I,I)
		Case "h":Bits= Array As Boolean(I,I,I,O,I,I,O)
		Case "i":Bits= Array As Boolean(O,I,I,O,O,O,O)
		Case "j":Bits= Array As Boolean(O,O,I,I,I,I,I)
		'Case "k":Bits= Array As Boolean(I,I,I,I,I,I,I)
		Case "l":Bits= Array As Boolean(O,I,I,I,O,O,O)
		'Case "m":Bits= Array As Boolean(I,I,I,I,I,I,I)		
		Case "n":Bits= Array As Boolean(I,O,I,O,I,O,O)
		Case "o":Bits= Array As Boolean(O,I,I,I,I,I,I)
		Case "p":Bits= Array As Boolean(I,I,I,O,O,I,I)
		'Case "q":Bits= Array As Boolean(I,I,I,I,I,I,I)
		Case "r":Bits= Array As Boolean(I,O,I,O,O,O,O)
		Case "s":Bits= Array As Boolean(I,I,O,I,I,O,I)
		'Case "t":Bits= Array As Boolean(I,I,I,I,I,I,I)
		Case "u":Bits= Array As Boolean(O,I,I,I,I,I,O)
		'Case "v":Bits= Array As Boolean(O,O,I,I,I,O,O)
		'Case "w":Bits= Array As Boolean(I,I,I,I,I,I,I)
		'Case "x":Bits= Array As Boolean(I,I,I,I,I,I,I)
		Case "y":Bits= Array As Boolean(I,I,O,I,I,I,O)
		Case "z":Bits= Array As Boolean(I,O,I,I,O,I,I)
		
		'2 digit digits					 0 1 2 3 4 5 6 
		Case "m1":Bits= Array As Boolean(O,I,I,O,O,I,I)
		Case "m2":Bits= Array As Boolean(O,I,O,O,I,I,I)
		Case "q1":Bits= Array As Boolean(I,I,O,O,I,I,I)
		Case "q2":Bits= Array As Boolean(O,O,O,I,O,O,O)
		Case "t1":Bits= Array As Boolean(O,O,O,O,I,I,I)
		Case "t2":Bits= Array As Boolean(O,O,O,O,O,O,I)
		Case "w1":Bits= Array As Boolean(O,I,I,I,I,O,O)
		Case "w2":Bits= Array As Boolean(O,O,O,I,I,I,O)
		Case "x1":Bits= Array As Boolean(O,O,O,I,I,I,I)
		Case "x2":Bits= Array As Boolean(O,O,O,I,O,O,I)
		Case "v1":Bits= Array As Boolean(I,I,O,O,I,O,O)
		Case "v2":Bits= Array As Boolean(O,O,O,I,I,I,O)
	End Select
	Draw1Bit(BG, X + Skew, Y, Width, 0, Bits(6), ColorT,ColorF, Skew,Stroke)'top hor
	Draw1Bit(BG, X + Skew + Width, Y, 0, Height/2, Bits(5), ColorT,ColorF, Skew,Stroke)'top right ver
	Draw1Bit(BG, X + Skew/2 + Width, Y+ Height/2, 0, Height/2, Bits(4), ColorT,ColorF, Skew,Stroke)'bottom right ver
	
	Draw1Bit(BG, X, Y+Height, Width, 0, Bits(3), ColorT,ColorF, Skew,Stroke)'bottom hor
	Draw1Bit(BG, X + Skew/2, Y+ Height/2, 0, Height/2, Bits(2), ColorT,ColorF, Skew,Stroke)'bottom left ver
	Draw1Bit(BG, X + Skew, Y, 0, Height/2, Bits(1), ColorT,ColorF, Skew,Stroke)'top left ver
	
	Draw1Bit(BG, X + Skew/2, Y+ Height/2, Width,0 , Bits(0), ColorT,ColorF, Skew,Stroke)'middle hor
End Sub
Sub Draw1Bit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Value As Boolean, ColorT As Int, ColorF As Int, Skew As Int, Stroke As Int)
	If Height=0 Then'horizontal
		BG.DrawLine( X+Stroke, Y+Stroke, X+Width,Y+Stroke, API.IIF(Value, ColorT,ColorF), Stroke)
	Else'vertical
		BG.DrawLine(X+Stroke, Y+Stroke, X+Stroke-Skew/2, Y+Height, API.IIF(Value, ColorT,ColorF) ,Stroke)
	End If
End Sub






















Sub DrawLSOD(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, SideText As String,Alpha As Int)
	Dim TextSize As Int,TextWidth As Int, TextHeight As Int,tempX As Int, tempY As Int, tempWidth As Int, tempstr As String, Color As Int ,Landscape As Boolean
	Dim strings As List = API.GetStrings("lsod_", 0)
	Color=Colors.ARGB(Alpha,255,255,255)
	LCARSeffects2.LoadUniversalBMP("", "bsod.png", LCAR.LCAR_LSOD)
	LCARSeffects2.TileBitmap(BG, LCARSeffects2.CenterPlatform, 	0,0, 	LCARSeffects2.CenterPlatform.Width,LCARSeffects2.CenterPlatform.Height, 	X,Y,Width+1,Height+1,  False,False, 255, 1)
	Landscape=Width>Height
	
	tempstr= strings.get(0)'"THE LCARS COMPUTER NETWORK"
	TextSize = API.GetTextHeight(BG, Width*-0.75, tempstr, LCAR.LCARfont)
	TextHeight = API.TextHeightAtHeight(BG, LCAR.LCARfont, tempstr, TextSize)
	TextWidth= API.TextWidthAtHeight(BG, LCAR.LCARfont, tempstr, TextSize)
	
	tempX=X+Width/2
	tempY=Y + Height* API.iif(Landscape,0.05, 0.18)
	tempWidth= TextHeight *1.5

	BG.DrawText(tempstr, tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "CENTER")
	LCAR.DrawLCARslantedbutton(BG,tempX - TextWidth/2 - tempWidth-2, tempY, tempWidth, TextHeight+1, LCAR.LCAR_White, Alpha, False, "", -4,0)
	LCAR.DrawLCARslantedbutton(BG,tempX + TextWidth/2 + 4, tempY, tempWidth, TextHeight+1, LCAR.LCAR_White, Alpha, False, "", -5,0)
	
	tempY=tempY+TextHeight
	tempstr = strings.get(1)'"A FATAL EXCEPTION O.E. HAS OCCURED AT 0028:C0011E36 IN SYSREG 47 ALPHA (SYSREG.L47)"
	TextSize = API.GetTextHeight(BG, -Width, tempstr, LCAR.LCARfont)
	TextWidth= API.TextWidthAtHeight(BG, LCAR.LCARfont, tempstr, TextSize)
	TextHeight = API.TextHeightAtHeight(BG, LCAR.LCARfont, tempstr, TextSize)
	If Landscape Then
		tempY=tempY + TextHeight*1.5
	Else
		tempY=Y + Height*0.33
	End If
	BG.DrawText(tempstr, tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "CENTER")
	
	tempY=tempY + TextHeight*1.5'Height*0.40
	BG.DrawText(Text, tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "CENTER")
	
	tempY=tempY + TextHeight*1.5
	BG.DrawText(strings.get(2), tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "CENTER")'"THE CURRENT APPLICATION WILL BE TERMINATED"
	
	
	tempX=tempX-TextWidth/2
	If Landscape Then
		tempY=tempY + TextHeight*2
	Else
		tempY=Y + Height*0.52
	End If
	BG.DrawText(strings.get(3), tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "LEFT")'" • PRESS ANY KEY TO TERMINATE THE APPLICATION."
	
	tempY=tempY + TextHeight*1.5
	BG.DrawText(strings.get(4), tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "LEFT")' " • PRESS MODE SELECT AND ABORT TO PURGE THE DATA AND REBOOT THE TERMINAL."
	
	tempY=tempY + TextHeight*1.5
	TextWidth= API.TextWidthAtHeight(BG, LCAR.LCARfont, " • ", TextSize)
	BG.DrawText(strings.get(5), tempX+TextWidth, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "LEFT")'"YOU WILL LOSE ANY UNSAVED INFORMATION IN ALL APPLICATIONS."
	
	
	tempX=X+Width/2
	If Landscape Then
		tempY=tempY + TextHeight*2
	Else
		tempY=Y + Height*0.78
	End If
	BG.DrawText(strings.get(6), tempX, tempY+TextHeight, LCAR.LCARfont, TextSize,Color, "CENTER")'"PRESS BACK KEY TO CONTINUE"
End Sub










Sub DrawScienceStation(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Index As Int, Stage As Int, ColorID1 As Int, ColorID2 As Int, Alpha As Int)
	Dim temp As Int,temp4 As Int ,temp2 As Float ,temp3 As Float,WS As Float,temp5 As Float  
	'Log("SCIENCE: " & Width)
	If LCAR.CrazyRez > 0 Then temp = 17 * LCAR.CrazyRez + 2 Else temp=API.IIF(LCAR.SmallScreen,14,19)
	'LCAR.DrawRect(BG,X,Y,Width+2,Height+2,Colors.Black,0)
	'LCAR.DrawUnknownElement(BG,X,Y,Width+2,Height+2, ColorID1, False,255, Stage)
	If Index = 0 Then'top
		LCAR.DrawRect(BG, X+ Width*0.42, Y+Height, Width*0.16, temp, Colors.black, 0)
		
		DrawMiniStarfield(BG, 0, 10, X,Y,Width,Height, ColorID1,Alpha)
	
		'top middle
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0,						0.1439075630252101,		0.11, 						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0,						0.009453781512605,		0.30,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.5625000000000001,	0,						0.009453781512605,		0.20,						ColorID2, False, -1)
		
		'Black+stars
		'DrawRect(BG,X,Y,Width,Height,		0,					0.42128,				1,						0.17021, 					LCAR.LCAR_Black, True, -1)
		
		'DrawRect(BG,X,Y,Width,Height,		0.42,				1,						0.16,					temp/ Height, 				LCAR.LCAR_Black, True, -1)
		
		
		'bottom middle
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0.7,					0.009453781512605,		0.28,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0.85,					0.01890756302521,		0.14,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0.97,					0.1439075630252101,		0.07, 						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.5625000000000001,	0.85,					0.009453781512605,		0.1352657004830918,			ColorID2, False, -1)
		
		'bars | 				0.0126																												0.03256
		'DrawRect(BG,X,Y,Width,Height,		0.02166,			0.42128, 				0.01996, 				0.13,						ColorID1, False, Stage)
		DrawRect(BG,X,Y,Width,Height,		0,					0.42128, 				0.03992, 				0.13,						ColorID1, False, Stage)
		DrawRect(BG,X,Y,Width,Height,		0.05422,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+3)
		DrawRect(BG,X,Y,Width,Height,		0.08678,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+6)
		DrawRect(BG,X,Y,Width,Height,		0.11934,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+9)
		DrawRect(BG,X,Y,Width,Height,		0.15190,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+12)
		DrawRect(BG,X,Y,Width,Height,		0.18446,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+15)
		DrawRect(BG,X,Y,Width,Height,		0.21702,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+18)
		DrawRect(BG,X,Y,Width,Height,		0.24958,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+21)
		DrawRect(BG,X,Y,Width,Height,		0.28214,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+24)
		DrawRect(BG,X,Y,Width,Height,		0.31470,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+27)
		DrawRect(BG,X,Y,Width,Height,		0.34621,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+30)
		
		'[
		DrawRect(BG,X,Y,Width,Height,		0.37877,			0.3234, 				0.03151, 				0.0383,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.37877,			0.3234, 				0.01155, 				0.3617,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.37877,			0.6468, 				0.03151, 				0.0383,						ColorID2, False, -1)

		']
		DrawRect(BG,X,Y,Width,Height,		0.58972,			0.3234, 				0.03151, 				0.0383,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.61,				0.3234, 				0.01155, 				0.3617,						ColorID2, False, -1)
		DrawRect(BG,X,Y,Width,Height,		0.58972,			0.6468, 				0.03151, 				0.0383,						ColorID2, False, -1)
		
		'|																																	0.03256
		DrawRect(BG,X,Y,Width,Height,		0.63383,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+30)
		DrawRect(BG,X,Y,Width,Height,		0.66639,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+27)
		DrawRect(BG,X,Y,Width,Height,		0.69895,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+24)
		DrawRect(BG,X,Y,Width,Height,		0.73151,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+21)
		DrawRect(BG,X,Y,Width,Height,		0.76407,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+18)
		DrawRect(BG,X,Y,Width,Height,		0.79663,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+15)
		DrawRect(BG,X,Y,Width,Height,		0.82919,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+12)
		DrawRect(BG,X,Y,Width,Height,		0.86175,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+9)
		DrawRect(BG,X,Y,Width,Height,		0.89431,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+6)
		DrawRect(BG,X,Y,Width,Height,		0.92687,			0.42128, 				0.01996, 				0.17021,					ColorID1, False, Stage+3)
		DrawRect(BG,X,Y,Width,Height,		0.95943,			0.42128, 				0.03992, 				0.13,						ColorID1, False, Stage)
	Else
		'black+stars
		'DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0,						0.1439075630252101,		1, 							LCAR.LCAR_Black, True, -1)
		temp = temp +  LCAR.LCARCornerElbow2.Height
		LCAR.DrawRect(BG, X+ Width*0.42, LCAR.GetScaledPosition(2,False), Width*0.6, temp+1, Colors.black ,0)
		'DrawRect(BG,X,Y,Width,Height,		0.42,				-temp/ Height,			0.60,					(temp+2)/ Height, 			LCAR.LCAR_Black, True, -1)
		DrawMiniStarfield(BG, 1, 25, X,Y,Width,Height, ColorID1,Alpha)
		BG.RemoveClip 
		'bars above
		WS=2/Height
		temp2= ((temp)/ Height+0.03) * 0.5
		temp3= 0.045- ((temp2+WS)*2) '-temp/Height
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	temp3,					0.1439075630252101,		temp2, 						ColorID1, False, Stage)
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	temp3+ WS +temp2,		0.1439075630252101,		temp2, 						ColorID1, False, Stage+1)
		
		'top middle
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	0.045,					0.15,					0.03, 						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.04206,			0.05,					0.74027,				0.03086,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.04206,			0.05,					0.09258,				0.06172,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.753,				0.05,					0.03086,				0.06172,					ColorID1, True, -1)
		
		'bars below
		temp3=0.08086+WS
		temp4=1
		Do Until temp3 + temp2 + WS >= 0.45
			temp4=temp4+1
			DrawRect(BG,X,Y,Width,Height,	0.428046218487395,	temp3,					0.1439075630252101,		temp2, 						ColorID1, False, Stage+temp4)
			temp3=temp3 + temp2 + WS
		Loop
		
		'middle
		temp5=temp3
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	temp3,					0.1439075630252101,		temp2/2, 					ColorID1, False, Stage+temp4+1)
		'bars in between
		temp3=temp3 + temp2/2 + WS
		For temp4 = temp4 To 1 Step-1
			DrawRect(BG,X,Y,Width,Height,	0.428046218487395,	temp3,					0.1439075630252101,		temp2, 						ColorID1, False, Stage+temp4)
			temp3=temp3 + temp2 + WS
		Next
		'For temp4 = 31 To 29 Step-1
			DrawRect(BG,X,Y,Width,Height,	0.428046218487395,	temp3,					0.1439075630252101,		temp2, 						ColorID1, False, Stage+31)'temp4)
			temp3=temp3 + temp2 + WS
		'Next

		'bottom long bar
		DrawRect(BG,X,Y,Width,Height,		0.04206,			temp3-0.03086,			0.03086,				0.05,						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.68975,			temp3-0.03086,			0.09258,				0.05,						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.04206,			temp3,					0.74027,				0.03086,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.04206,			temp3+0.02,				0.38598-WS,				0.02,						ColorID1, True, -1)
		
		'bars below
		temp3=temp3 + 0.03086 + WS
		temp4=30
		Do Until temp3 + temp2 + WS >= 1
			DrawRect(BG,X,Y,Width,Height,	0.428046218487395,	temp3,					0.1439075630252101,		temp2, 						ColorID1, False, Stage+temp4)
			temp4=temp4-1
			temp3=temp3 + temp2 + WS
		Loop
		DrawRect(BG,X,Y,Width,Height,		0.428046218487395,	temp3,					0.1439075630252101,		1-temp3, 					ColorID1, False, Stage+temp4-1)
		
		'middle left bracket [
		temp5 = (temp5  - 0.25 +temp2/4)*2
		DrawRect(BG,X,Y,Width,Height,		0.35,				0.25,					0.03086,				temp5,						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.35,				0.25,					0.04500,				0.03086,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.35,				0.25+temp5-0.03,		0.04500,				0.03086,					ColorID1, True, -1)
		
		'middle right bracket
		DrawRect(BG,X,Y,Width,Height,		0.68,				0.25,					0.03086,				temp5,						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.60,				0.25,					0.1,					0.03086,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.60,				0.25+temp5-0.03,		0.11086,				0.03086,					ColorID1, True, -1)
		
		'right right bracket
		DrawRect(BG,X,Y,Width,Height,		0.82,				0.25+temp5/4,			0.015,					temp5/2,					ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.81,				0.25+temp5/4,			0.015,					0.015,						ColorID1, True, -1)
		DrawRect(BG,X,Y,Width,Height,		0.81,				0.25+ temp5*0.75-0.03,	0.015,					0.03,						ColorID1, True, -1)
		
		'Random number block
		If LCARSeffects2.InitRandomNumbers(LCAR.LCAR_Science, False ) Then LCARSeffects2.MakeRowOfRandomNumbers(BG, LCAR.LCARfont, LCAR.Fontsize, Width*0.17, 0, ColorID1)
		temp3= 0.25+temp5/4
		temp=Y+ Height *temp3 
		temp4=X + Width*0.83
		temp2=LCAR.TextHeight(BG,"0123")
		LCAR.DrawRect(BG, temp4,temp,Width*0.17,Height*temp5+temp2, Colors.Black, 0)
		LCARSeffects2.DrawRandomNumbers(BG, temp4 ,temp+ temp2, LCAR.LCARfont, LCAR.Fontsize, Width*0.17,Height*temp5, 0)
		LCARSeffects2.IncrementNumbers
	End If
	BG.RemoveClip 
End Sub
Sub DrawRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xp As Float, Yp As Float, WidthP As Float, HeightP As Float, ColorID As Int, State As Boolean, Stage As Int)
	Dim Color As Int  ,Dest As Rect ,Alpha As Int 
	If ColorID>LCAR.LCAR_Black Then
		Stage = Stage Mod 32
		If Stage = -1 Then
			Color = 255
		Else If Stage<16 Then
			Color=Stage*-16
		Else
			Color=(15-(Stage-16))*-16
		End If
		If Color<>0 Then 'Return'Color=255
			Alpha=Min(Max(-255,Abs(Color)),255)
			Color = LCAR.GetColor(ColorID, State, Alpha)
		End If
	Else
		Color=Colors.Black 
	End If
	Dest = LCAR.SetRect(X + Xp*Width, Y+ Yp*Height, Width * WidthP, Height*HeightP)
	If Alpha<255 Then BG.DrawRect(Dest,  Colors.Black ,True,0)
	If Color <> 0 Then BG.DrawRect(Dest,  Color,True,0)
	'LCAR.DrawRect(BG, X + Xp*Width, Y+ Yp*Height, Width * WidthP, Height*HeightP,  Color   ,0)
End Sub










Sub FindMiniStarfield(ID As Int) As Int
	Dim temp As Int, tempSF As MiniStarField 
	If MiniStarfields.IsInitialized Then
		For temp = 0 To MiniStarfields.Size-1
			tempSF=MiniStarfields.Get(temp)
			If tempSF.ID=ID Then Return temp
		Next
	Else
		MiniStarfields.Initialize 
	End If
	Return -1
End Sub
Sub MakeMiniStarfield(ID As Int, Quantity As Int) As Int 
	Dim tempSF As MiniStarField ,temp As Int 
	temp=FindMiniStarfield(ID)
	If temp=-1 Then 
		tempSF.Initialize 
		tempSF.ID=ID
		tempSF.StarS.Initialize 
		For temp = 1 To Quantity
			tempSF.StarS.Add(MakeRandomMiniStar)
		Next
		MiniStarfields.Add(tempSF)
		temp = MiniStarfields.Size-1
	End If
	Return temp
End Sub
Sub MakeRandomMiniStar As MiniStar
	Dim temp As MiniStar
	temp.Initialize 
	temp.X = Rnd(1, 1000) / 1000
	temp.y = Rnd(1, 1000) / 1000
	temp.Radius = Rnd(1,6)
	Return temp
End Sub

Sub DrawMiniStarfield(BG As Canvas,ID As Int, Quantity As Int, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int)
	Dim temp As Int , tempSF As MiniStarField, tempS As MiniStar
	temp = FindMiniStarfield(ID)
	If temp=-1 Then temp = MakeMiniStarfield(ID,Quantity)
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	tempSF = MiniStarfields.Get(temp)
	ColorID = LCAR.GetColor(ColorID,False,Alpha)
	For temp = 0 To tempSF.StarS.Size-1
		tempS = tempSF.StarS.Get(temp)
		BG.DrawCircle(X+ (Width*tempS.X) , Y+(Height*tempS.Y) , tempS.Radius , ColorID, True, 0)
	Next
	'BG.RemoveClip 
End Sub






Sub DrawKlingonButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, State As Boolean, Text As String)
	Dim Color As Int, P As Path ,C As Int =Height/5, M As Int = (Width-C*4)/3,B As Int =Y+Height,Font As Typeface'= Colors.ARGB(alpha,api.iif(state,128,255),0,0),
	If State Then Color = Colors.ARGB(Alpha, 255,255,27) Else Color = Colors.ARGB(Alpha, 255,128,24)

	P.Initialize(X+C,Y)
	P.LineTo(X,Y+C)
	P.LineTo(X,B-C)
	P.LineTo(X+C,B)
	P.LineTo(X+M+C,B)
	P.LineTo(X+M+C*2,B-C)
	P.LineTo(X+M*2+C*2,B-C)
	P.LineTo(X+M*2+C*3,B)
	P.LineTo(X+M*3+C*3,B)
	P.LineTo(X+M*3+C*4,B-C)
	
	P.LineTo(X+M*3+C*4,Y+C)
	P.LineTo(X+M*3+C*3,Y)
	P.LineTo(X+M*2+C*3,Y)
	P.LineTo(X+M*2+C*2,Y+C)
	P.LineTo(X+M+C*2,Y+C)
	P.LineTo(X+M+C,Y)

	BG.ClipPath(P)
	LCAR.DrawRect(BG,X,Y,Width+1,Height+1, Color,0)
	BG.RemoveClip 
	
	If Games.UT  Then
		Font= LCAR.LCARfont
	Else
		LCARSeffects2.SetKlingonFont
		Font=LCARSeffects2.KlingonFont
	End If
	Color=BG.MeasureStringHeight(Text, Font, LCAR.Fontsize)
	BG.DrawText(Text, X+Width/2, Y+ Height/2-Color/2+Color, Font, LCAR.Fontsize, Colors.Black, "CENTER")
End Sub




















Sub HandleTOSButton(Index As Int, X As Int, Y As Int, State As Int)
	Dim temp As Int, Page As TOSPage 
	If Index = -1 Then
		For temp = 0 To TOSPages.Size-1
			Page = TOSPages.Get(temp)
			Page.Touched= -1 
		Next
	Else If Index > -1 And Index < TOSPages.Size Then 
		Page = TOSPages.Get(Index)
		Page.Touched = FindTOSbutton(Index,X,Y)
		'Log("HandleTOSButton: " & Index & " X: " & X & " Y: " & Y & " State: " & State & " ID: " & Page.Touched)
	End If
End Sub
Sub DrawTOSButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Text As String)
	Dim temp As Int 'http://www.startrekpropauthority.com/2009/02/star-trek-exhibition-in-detroit-bridge.html
	LCARSeffects2.DrawLegacyButton(BG, X,Y, Width, Height, Color, "", 9, 0)
	If Text.Length>0 Then
		temp=BG.MeasureStringHeight(Text, LCAR.TOSFont, LCAR.Fontsize)
		BG.DrawText(Text, X+Width*0.5, Y+ (Height*0.5)-(temp*0.5)+temp, LCAR.TOSFont, LCAR.Fontsize, Colors.Black, "CENTER")
	End If
End Sub

Sub IncrementTOSbutton(Element As LCARelement) As Boolean 
	Select Case Element.Align 
		Case -2'page
			IncrementTOSpage(Element.LWidth)
	End Select
	Return True
End Sub
Sub FindTOSbutton(PageID As Int, X As Int, Y As Int) As Int
	Dim temp As Int , Page As TOSPage = TOSPages.Get(PageID), BTN As TOSButton 
	For temp = 0 To Page.Buttons.Size-1
		BTN=Page.Buttons.Get(temp)
		If BTN.X <= X And BTN.Y<=Y And BTN.X + BTN.Width >= X And BTN.Y + BTN.Height >= Y Then Return temp
	Next
	Return -1
End Sub
Sub DrawTOSButton2FLT(Page As TOSPage, Index As Int,   BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xf As Float, Yf As Float, Widthf As Float, Heightf As Float, ColorID As Int, bType As Int, Text As String, SideText As String, TextAlign As Int, Lw As Int, Rw As Int)  As Int 
	Dim BTN As TOSButton, Dest As Rect , Fontsize As Int ,State As Boolean 
	If Index>-1 Then BTN = Page.Buttons.Get(Index) Else BTN.Initialize
	Select Case bType'always visible types
		Case 3,6,15,16: BTN.Visible = True
	End Select
	If BTN.Visible Or Index = -1 Then 
		If Text.Length = 0 Then Text = BTN.Name Else Text = Text.Replace("#", BTN.Name).Replace("%n%", CRLF)
		If SideText.Contains("#") Then SideText = BTN.Name 
		BTN.X = Width * Xf
		BTN.Y = Height * Yf
		BTN.Width = Width*Widthf
		BTN.Height = Height * Heightf
		If ColorID = LCAR.LCAR_Random Then
			If BTN.ColorID = 0 Then BTN.ColorID = API.IIFIndex(Rnd(0,3), Array As Int(LCAR.LCAR_LightYellow, LCAR.Classic_Green, LCAR.LCAR_Red))
			ColorID = BTN.ColorID 
		End If
		If bType = 15 Then 
			If Rnd(0,20)=0 Then BTN.Name = TOSRandomNumber(BTN.Before, BTN.After)
		End If
		State = Page.Touched>-1 And Page.Touched=Index 
		If bType< 1000 Then'TOS
			Dest = DrawTOSButton2(BG,X + BTN.X, Y + BTN.Y, BTN.Width, BTN.Height, LCAR.GetColor(ColorID,State,255), bType, Text ,SideText,TextAlign,Lw,Rw)
			If bType>=11 And bType<= 13 And CheckForTOS Then
				Fontsize=LCAR.Fontsize*0.5
				Index = TextAlign
				X = Dest.Left
				Y = Dest.Top 
				Width = Dest.Right-Dest.Left 
				Height = Dest.Bottom-Dest.Top 
				Select Case bType 'draw random numbers overtop the starship schematics
					Case 11'ENT side
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.67509, 0.58218,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'3 digits
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.59157, 0.74860,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.44246, 0.91061,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.50729, 0.91061,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.64992, 0.13966,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'4 digits
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.76013, 0.73184,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0) 
					Case 12'ENT top
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.66021, 0.11027,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'6 digits
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.66021, 0.88973,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.76585, 0.50000,  0,0,		LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'3 digits
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.02641, 0.47148,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'top
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.20775, 0.06464,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.20775, 0.31939,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.26232, 0.06464,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.27641, 0.28517,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.45246, 0.47148,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.59859, 0.45247,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.02641, 0.52852,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)'bottom
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.20775, 0.93536,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.20775, 0.68061,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.26232, 0.93536,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.27641, 0.71483,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.45246, 0.52852,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.59859, 0.54753,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
					Case 13'star drive
						DrawTOSButton2FLT(Page, -1,    BG, X,Y,Width,Height, 			0.35734, 0.16916, 0.27978, 0.18713,		LCAR.LCAR_Black, 15, "PRI", "", -8, Fontsize,0)
						DrawTOSButton2FLT(Page, -1,    BG, X,Y,Width,Height, 			0.35734, 0.16916, 0.27978, 0.18713,		LCAR.LCAR_Black, 15, "FC3", "", -2, Fontsize,0)
						DrawTOSButton2FLT(Page, -1,    BG, X,Y,Width,Height, 			0.35734, 0.35629, 0.27978, 0.23503,		LCAR.LCAR_Black, 15, "AUX", "", -8, Fontsize,0)
						DrawTOSButton2FLT(Page, -1,    BG, X,Y,Width,Height, 			0.35734, 0.35629, 0.27978, 0.23503,		LCAR.LCAR_Black, 15, "PLB", "", -2, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.48753, 0.1003,   0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.25485, 0.54641,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.74515, 0.54641,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0)
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.07479, 0.61527,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0) 
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.09695, 0.80988,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0) 
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.92521, 0.61527,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0) 
						Index = DrawTOSButton2FLT(Page, Index, BG, X,Y,Width,Height, 	0.90305, 0.80988,  0,0,    	LCAR.LCAR_Black, 15, "", "", 5, Fontsize,0) 
				End Select
				Return Index
			End If
		Else'ENTERPRISE
			Select Case bType'PreCARS
				Case 1000: LCARSeffects2.DrawPreCARSButton(BG,X + BTN.X, Y + BTN.Y, BTN.Width, BTN.Height, ColorID,State,255, Text,SideText,Lw=1)'button
				Case 1001: LCARSeffects2.DrawPreCARSFrame(BG,X + BTN.X, Y + BTN.Y, BTN.Width, BTN.Height, ColorID, 255, 0, Lw,0, Text,0, "")'frame
			End Select
		End If
	End If
	Return Index+1
End Sub
Sub DrawTOSButton2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, bType As Int, Text As String, SideText As String, TextAlign As Int, Lw As Int, Rw As Int) As Rect 
	Dim temp As Int, temp2 As Int, CornerRadius As Int = 10, P As Path , Thumb As Point , P As Path, Ret As Rect
	Select Case bType
		Case 11,12,13
			If CheckForTOS Then
				LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, "systos.png", LCAR.TOS_Button)
			Else
				LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.Classic_Yellow, False,255, API.GetString("tos_button"))' "ENTER GNDN\TOS BRIDGE TO" & CRLF & "DOWNLOAD THE NECESSARY FILE")
				Return Ret 
			End If
	End Select
	Select Case bType
		Case -2'page
			DrawTOSpage(BG, X,Y,Width,Height, Lw)
		Case -1'grid
			For temp = X To X+ Width Step Width / Lw 
				BG.DrawLine(temp, Y, temp, Y+Height, Colors.Black, 2)
			Next
			For temp = Y To Y + Height Step Height / Rw
				BG.DrawLine(X,temp, X+Width, temp, Colors.Black, 2)
			Next
		Case 0'normal
			DrawTOSButton(BG,X,Y,Width,Height,Color, API.IIF(TextAlign=5, Text, ""))
			If TextAlign<> 5 Then 
				temp2=LCAR.Fontsize
				If TextAlign<0 Then
					temp2=temp2*0.5
					TextAlign = Abs(TextAlign) Mod 10
				End If
				temp=BG.MeasureStringHeight(Text, LCAR.TOSFont, temp2)
				Select Case TextAlign
					Case 2:API.DrawTextAligned(BG, Text, X+ Width*0.5, Y+ CornerRadius+temp, 0,   LCAR.TOSFont, temp2, Colors.Black, 2, 0,0) 'top
					Case 5:API.DrawTextAligned(BG, Text, X+ Width*0.5, Y+ Height*0.5,0, LCAR.TOSFont, temp2, Colors.Black, 5,0,0)'middle
					Case 8:API.DrawTextAligned(BG, Text, X+ Width*0.5, Y+ Height-temp-CornerRadius*2, 0,   LCAR.TOSFont, temp2, Colors.Black, 8, 0,0) 'bottom
				End Select
			End If
		Case 1'circle
			BG.DrawCircle(X+Width*0.5, Y+Height*0.5, Min(Width,Height) * 0.5, Color, True, 0)
			API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.5, 0, LCAR.TOSFont, LCAR.Fontsize, Colors.Black, 5, 0, 0)
		Case 2,7'hollow square
			LCAR.CheckNumbersize(BG)
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Color,0)
			temp2 = API.IIF(bType=2, LCAR.ItemHeight, LCAR.ItemHeight*0.5)
			LCARSeffects4.DrawRect(BG,X + temp2, Y + temp2,  Width- temp2*2, Height - temp2*2, Colors.Black, 0)
			temp = API.IIF(bType=2, LCAR.NumberTextSize, LCAR.Fontsize)
			If SideText.Length=0 Then
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
			Else If SideText.Contains("-") Then
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.25+temp2*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
				API.DrawTextAligned(BG, API.GetSide(SideText,"-", True,False), X+temp2, Y+Height*0.75-temp2*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 4, 0, 0)
				API.DrawTextAligned(BG, API.GetSide(SideText,"-", False,False), X+Width-temp2, Y+Height*0.75-temp2*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 6, 0, 0)
			End If
		Case 3,6'text
			temp = API.IIF(bType=3, LCAR.NumberTextSize, LCAR.Fontsize)
			If SideText.Length=0 Then
				Select Case TextAlign
					Case 4: API.DrawTextAligned(BG, Text, X, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 4, 0, 0)
					Case 5: API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
					Case 6: API.DrawTextAligned(BG, Text, X+Width, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 6, 0, 0)
				End Select
			Else
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y, 0, Typeface.DEFAULT_BOLD, temp, Color, 2, 0, 0)
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height, 0, Typeface.DEFAULT_BOLD, temp-2, Color, 8, 0, 0)
			End If
		Case 4,8'hollow rounded-rect
			LCAR.CheckNumbersize(BG)
			temp = API.IIF(bType=4, LCAR.NumberTextSize, LCAR.Fontsize)
			temp2 = LCAR.ItemHeight * API.IIF(bType=4, 0.5, 0.25)
			LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height,Color, temp2)
			LCARSeffects4.DrawRect(BG,X + temp2, Y + temp2,  Width- temp2*2, Height - temp2*2, Colors.Black, 0)
			If SideText.Length=0 Then
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
			Else
				API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height*0.25+LCAR.ItemHeight*0.25, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
				API.DrawTextAligned(BG, SideText, X+Width*0.5, Y+Height*0.75-LCAR.ItemHeight*0.25, 0, Typeface.DEFAULT_BOLD, temp, Color, 5, 0, 0)
			End If
		Case 5,9'meter			lw=percent, rw=color for right side
			LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height,Color, CornerRadius)
			temp = (Width-Height)* (Lw*0.01) + (Height* 0.5)
			P.Initialize(X + temp - Height*0.5, Y)
			P.LineTo(X+Width, Y)
			P.LineTo(X+Width,Y+Height)
			P.LineTo(X + temp + Height*0.5, Y+Height)
			BG.ClipPath(P)
			LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height,Rw, CornerRadius)
			BG.DrawLine(X + temp - Height*0.5, Y, X + temp + Height*0.5, Y+Height, Colors.Red, 4)
			BG.RemoveClip 
			temp = API.IIF(bType=5, LCAR.NumberTextSize, LCAR.Fontsize)
			API.DrawTextAligned(BG, Text, X+Height, Y+Height*0.5, 0, Typeface.DEFAULT_BOLD, temp, Colors.Black, 5, 0, 0)
		Case 10'square
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Color,0)
		Case 11'ENT Side   x,y 0.14062, 0.13675 'CheckForTOS
			Thumb = API.Thumbsize(584, 170, Width, Height, True, False)
			X=X+Width*0.5-Thumb.X*0.5
			Y=Y+Height*0.5-Thumb.Y*0.5
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 183, 0,    584, 170,    X, Y, Thumb.X, Thumb.Y, 255, False,False)
			Return LCARSeffects4.SetRect(X,Y, Thumb.X, Thumb.Y)
		Case 12'ENT Top
			Thumb = API.Thumbsize(571,266, Width, Height, True, False)
			Thumb.Y=Thumb.Y*0.5
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 184,181, 571,133,         X+Width*0.5- Thumb.X*0.5, Y+Height*0.5-Thumb.Y, Thumb.X, Thumb.Y, 255, False, True)
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 184,181, 571,133,         X+Width*0.5- Thumb.X*0.5, Y+Height*0.5, Thumb.X, Thumb.Y, 255, False, False)
			X = X+Width*0.5- Thumb.X*0.5
			Y = Y+Height*0.5-Thumb.Y
			Thumb.Y=Thumb.Y*2
			Return LCARSeffects4.SetRect(X,Y,Thumb.X,Thumb.Y)
		Case 13'Stardrive
			Thumb = API.Thumbsize(366,668, Width, Height, True, False)
			Thumb.X=Thumb.X*0.5
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 0,0, 183, 668,    X+Width*0.5- Thumb.X, Y+Height*0.5-Thumb.Y*0.5, Thumb.X, Thumb.Y, 255, False,  False)
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 0,0, 183, 668,    X+Width*0.5, Y+Height*0.5-Thumb.Y*0.5, Thumb.X, Thumb.Y, 255, True, False)
			Return LCARSeffects4.SetRect(X+Width*0.5- Thumb.X,Y+Height*0.5-Thumb.Y*0.5,Thumb.X*2,Thumb.Y)
		Case 14'oval
			temp=Min(Width,Height)*0.5
			LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height,Color,  temp)
			API.DrawTextAligned(BG, Text, X+Width*0.5, Y+temp, 0, LCAR.TOSFont, LCAR.Fontsize, Colors.black,2, 0, 0)
		Case 15'mini text 
			 API.DrawTextAligned(BG,   Text,      X+Width*0.5,    Y+Height*0.5,    0,       LCAR.TOSFont,     API.IIF(Lw=0, LCAR.Fontsize, Lw), Color, TextAlign,0,0)
		Case 16'CONTIGENCY POWER GRID		
			Width=Floor(Width/14)*14
			Height=Floor(Height/8)*8
			temp = Height * 0.33
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height-temp, Colors.RGB(186,172,107), 0)
			LCARSeffects4.DrawRect(BG,X,Y+Height-temp, Width,temp, Colors.RGB(179,81,42),0)
			BG.DrawLine(X,Y+Height, X+Width,Y, Colors.Black, 4)
			temp = X+ (Width/7)
			BG.DrawLine(temp,Y, temp,Y+Height, Colors.Black, 4)
			temp=Y + (Height*0.75)
			BG.DrawLine(X, temp, X+Width, temp, Colors.Black,4)
			DrawTOSButton2(BG,X,Y,Width,Height, Colors.Black, -1, "", "", 0, 14,8)
			Color=Colors.RGB(137,142,88)
			DrawNumbers(BG,X,Y+Height+13, Width, 14,True, 10, "", True,False, 2, -2, Typeface.DEFAULT, LCAR.Fontsize,Color)
			DrawNumbers(BG,X,Y+Height, Height, 8,False, 100, "", False,True, 3, -6, Typeface.DEFAULT, LCAR.Fontsize,Color)
		Case 17'graviton field decay
			temp = Floor(Width / 9)
			temp2= Floor(Height/9)
			Width= temp*9
			Height=temp2*9
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.RGB(151,179,94), 0)
			DrawTOSButton2(BG,X,Y,Width,Height, Colors.Black, -1, "", "", 0, 9,9)
			LCARSeffects4.DrawCurve(BG, X,Y+Height,  X+temp*3.5,Y+temp2*2.8,  X+Width, Y+temp2*0.3,20, Colors.Black, 5)  
			LCARSeffects4.DrawCurve(BG, X,Y+Height,  X+temp*4.4,Y+temp2*3.7,  X+Width, Y+temp2*1.9,20, Colors.Black, 5)  
			LCARSeffects4.DrawCurve(BG, X,Y+Height,  X+temp*5,Y+temp2*4.5,  X+Width, Y+temp2*3.6,20, Colors.Black, 15)   
			BG.DrawCircle(X+temp*5.5,Y+temp2*5, temp*0.5, Colors.Black, False,10)
			BG.DrawLine(X+temp, Y, X+Width,Y+Height, Colors.RGB(144,81,40), 10)'orange line
			Color=Colors.RGB(137,142,88)
			DrawNumbers(BG,X,Y+Height+13, Width,  9,True, 10, "", False,False, 2, -3, Typeface.DEFAULT, LCAR.Fontsize,Color)
			DrawNumbers(BG,X,Y+Height, Height, 9,False, 10, " psec", False,False, 2, -6, Typeface.DEFAULT, LCAR.Fontsize,Color)
		Case 18'NET WARP FIELD STABILITY
			temp = Floor(Width / 12)
			temp2= Floor(Height/8)
			Width= temp*12
			Height=temp2*8
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.RGB(151,179,94), 0)
			
			LCARSeffects4.MakeCurvePath(X,Y+Height, X+temp*10, Y+temp2*2.5,  X+Width, Y+temp2*3.4, 20, P)'P.LineTo(X+Width,Y+Height)
			LCARSeffects4.MakeCurvePath(X+Width, Y+Height,   X+temp*6.5, Y+temp2*6.2,   X,Y+Height,  20, P)
			BG.DrawPath(P, Colors.RGB(167,54,24), True, 0)
			
			DrawTOSButton2(BG,X,Y,Width,Height, Colors.Black, -1, "", "", 0, 12,8)
			LCARSeffects4.DrawCurve(BG, X,Y+Height,  X+temp*5,Y+temp2*3,  X+temp*10.5, Y,20, Colors.Black, 5)  
			LCARSeffects4.DrawCurve(BG, X,Y+Height,  X+temp*9.5,Y+temp2*4.2,  X+Width, Y+temp2*5,20, Colors.Black, 20)  
			Color=Colors.RGB(137,142,88)
			DrawNumbers(BG,X,Y+Height+13, Width,  12,True, 10, "", True,True, 2, -2, Typeface.DEFAULT, LCAR.Fontsize,Color)
			DrawNumbers(BG,X,Y+Height, Height, 8,False, 100, "", False,False, 2, -6, Typeface.DEFAULT, LCAR.Fontsize,Color)
		Case 19'line
			BG.DrawLine(X,Y, X+Width,Y+Height, Color, Lw)
		Case 20'tank
			temp = Height*0.1
			temp2=Height-temp
			LCARSeffects2.DrawRoundRect(BG, X, Y + API.iif(Lw=0, 0, temp), Width, Height-temp, Color, CornerRadius)
			P.Initialize(X+Width*0.5, Y+API.iif(Lw=0, Height, 0))
			If Lw>0 Then temp2 = temp
			P.LineTo(X+CornerRadius, Y+temp2)
			P.LineTo(X+Width-CornerRadius*0.5, Y+temp2)
			BG.DrawPath(P, Color, True,0)
			temp2= Y + Height* API.iif(Lw=0, 0.2, 0.8)
			temp= LCAR.Fontsize*0.5
			API.DrawTextAligned(BG,   Text,      X+Width*0.5,    temp2,    0,       LCAR.TOSFont,     temp, Colors.Black, -8,0,0)
			API.DrawTextAligned(BG,   SideText,  X+Width*0.5,    temp2,    0,       LCAR.TOSFont,     temp, Colors.Black, -2,0,0)
		Case 21'angled bit
			If Lw=0 Then
				P.Initialize(X,Y+Height)
				P.LineTo(X+Rw, Y+Height)
				P.LineTo(X+Width,Y+Rw)
				P.LineTo(X+Width,Y)
			Else
				P.Initialize(X,Y)
				P.LineTo(X+Rw,Y)
				P.LineTo(X+Width,Y+Height-Rw)
				P.LineTo(X+Width,Y+Height)
			End If
			BG.DrawPath(P, Color, True,0)
		Case Else: LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False,255, "UNKNOWN TOS ELEMENT: " & bType)
	End Select
End Sub


Sub DrawNumbers(BG As Canvas,X As Int,Y As Int,Size As Int, Increments As Int, Xaxis As Boolean, Multiplier As Int, Text As String, DoFirst As Boolean, DoLast As Boolean, MinDigits As Int, TextAlign As Int, theTypeface As Typeface, TextSize As Int, Color As Int)
	Dim Space As Int = Size/Increments, temp As Int, tempstr As String 
	For temp = 0 To Increments
		If (temp = 0 And DoFirst) Or (temp = Increments And DoLast) Or (temp>0 And temp<Increments) Then
			tempstr = API.PadtoLength( temp * Multiplier, True, MinDigits, "0") & Text
			API.DrawTextAligned(BG, tempstr, X,Y,0, theTypeface, TextSize, Color, TextAlign,0,0)
		End If
		If Xaxis Then X=X+Space Else Y=Y-Space
	Next
End Sub


'Digit request must be 3 numbers per request. Quantity, Before dash digits, after dash digits (0 for no dash)
Sub NewTOSpage(PageType As Int, DigitRequest() As Int) As Int 
	Dim Page As TOSPage , temp As Int, temp2 As Int 
	If PageType = -1 Or Not(TOSPages.IsInitialized) Then TOSPages.Initialize 
	If PageType > -1 Then
		Page.Initialize 
		Page.Touched=-1
		Page.TOStype = PageType 
		Page.Buttons.Initialize
		If DigitRequest.Length > 0 And DigitRequest.Length Mod 3 = 0 Then
			For temp = 0 To DigitRequest.Length - 1 Step 3
				For temp2 = 1 To DigitRequest(temp)
					Dim NewButton As TOSButton 
					NewButton.Initialize 
					NewButton.Before = DigitRequest(temp+1)
					NewButton.After = DigitRequest(temp+2)
					NewButton.Name = TOSRandomNumber(NewButton.Before, NewButton.After)
					NewButton.Visible = API.IIF(Rnd(0,5) = 0, False,True)
					Page.Buttons.Add(NewButton)
				Next
			Next
		End If
		Page.LastUpdate=DateTime.Now 
		TOSPages.Add(Page)
	End If
	Return TOSPages.Size -1
End Sub

Sub TOSRandomNumber(BeforeDash As Int, AfterDash As Int) As String 
	If BeforeDash = 0 Then Return ""
	Dim tempstr As String = LCARSeffects2.RandomNumber(BeforeDash,True)
	If AfterDash = 0 Then Return tempstr
	Return tempstr & "-" & LCARSeffects2.RandomNumber(AfterDash, True)
End Sub

Sub IncrementTOSpage(PageID As Int)
	If PageID<TOSPages.Size Then
		Dim Page As TOSPage = TOSPages.Get(PageID), temp As Int 
		If Page.LastUpdate< DateTime.Now - DateTime.TicksPerSecond And Page.Buttons.Size> 0 Then
			For temp = 0 To Page.Buttons.Size - 1
				Dim tButton As TOSButton = Page.Buttons.Get(temp)
				If tButton.Visible Then
					tButton.Visible = API.IIF(Rnd(0,5) = 0, False,True)
				Else
					tButton.Name = TOSRandomNumber(tButton.Before, tButton.After)
					tButton.Visible = True
				End If
			Next
			Page.LastUpdate=DateTime.Now 
		End If
	End If
End Sub
Sub DeclareTOSPage(PageType As Int) As Int 
	'Log("DeclareTOSPage: " & PageType)
	Select Case PageType 
		'system types	
		Case -3:		Return 20'number of TOS page types
		Case -2:		Return RandomTOSpage(5, LCAR.LCAR_TOS)'random TOS page type
		Case -1: 		Return NewTOSpage(-1, Array As Int(0))'init pages
		'easy page types
		Case 0: 		Return NewTOSpage(PageType,  Array As Int(10,2,0,   1,4,0,     	5,5,0,      3,5,4,		2,0,0 ))				'Universal translator status
		Case 1: 		Return NewTOSpage(PageType,  Array As Int(1,2,0,	3,0,0,		5,6,0))											'SUBSPACE RELAY STATUS
		Case 2:			Return NewTOSpage(PageType,  Array As Int(30,5,0))																'random buttons
		Case 3:			Return NewTOSpage(PageType,  Array As Int(1,5,6, 	3,0,0, 		42, 3,0))										'subspace feq scan
		Case 4:			Return NewTOSpage(PageType,  Array As Int(6,4,0,	22,5,0))													'random buttons and circles
		Case 5:			Return NewTOSpage(PageType,  Array As Int(27,4,0))																'random buttons and text
		Case 6:			Return NewTOSpage(PageType,  Array As Int(53,5,0))																'wide random buttons
		'reconstructed easy page types
		Case 7:			Return NewTOSpage(PageType,  Array As Int(37,3,0))																'artificial 1
		Case 8:			Return NewTOSpage(PageType,  Array As Int(32,5,0))																'artificial 2
		Case 9:			Return NewTOSpage(PageType,  Array As Int(37,5,0))																'artificial 3
		Case 10:		Return NewTOSpage(PageType,  Array As Int(30,5,0))																'artificial 4
		Case 11:		Return NewTOSpage(PageType,  Array As Int(31,5,0))																'artificial 5
		'starship schematic page types
		Case 12:		Return NewTOSpage(PageType,  Array As Int(7,3,0,	2,4,0,		2,6,0,		15,3,0))							'shipwide environmental status
		Case 13:		Return NewTOSpage(PageType,  Array As Int(9,2,0,	17,3,0,		1,4,0,		2,5,0,		3,3,0,		5,2,0))		'stardrive
		'graph page types
		Case 14:		Return NewTOSpage(PageType,  Array As Int(1,2,0,	53, 3,0))													'contingency power
		Case 15,18,19:	Return NewTOSpage(PageType,  Array As Int(0,0,0))																'graviton field decay, spockoscope/moire, tactical 2
		Case 16:		Return NewTOSpage(PageType,  Array As Int(10,3,0,	5,0,0))														'net warp field stability
		Case 17:		Return NewTOSpage(PageType,  Array As Int(18,3,0,	2,6,0))														'station keeping
		
		'Enterprise
		Case -4:	Return 1014'number of ENT page types + 1000
		Case -5:	Return RandomTOSpage(5, LCAR.LCAR_ENT)'random ENT page type
		'easy page types
		Case Else:	Return NewTOSpage(PageType,  Array As Int(1,1,1))																'test
	End Select
End Sub
Sub TOSPageCanBeUsed(PageType As Int) As Boolean 
	Select Case PageType
		Case 12,13: 	Return CheckForTOS
	End Select
	Return True
End Sub
Sub TOSpageWidth(PageType As Int) As Int
	Select Case PageType
		Case 6:		Return 2
		Case Else:	Return 1
	End Select
End Sub

Sub RandomENT (EntType As Int) As String 
	Dim Texts As List, tempstr As String, tempstr2 As StringBuilder, temp As Int , tempchar As String 
	Texts.Initialize 
	Select Case EntType
		Case -1'TNG for Transporter 2
			Texts.AddAll(Array As String("TE FRE", "JE HAY", "JO SYM", "TI IAC", "CH NOL", "AL CHN", "BO BUV", "PE SON", "JI IVM", "PI MOV", "JI LOU", "TI POL"))
			
		Case 0'buttons
			Texts.AddAll(Array As String("seq verify", "calibrate", "emer", "enable ri ber", "enable da ros", "run ga har", "run jo cunn", "run ma dru", "run ch pet", "run ju fer", "run je fle", "subsys sel", "autoconfig"))
			Texts.AddAll(Array As String("secondary", "mode sel", "seq ji van", "seq do ana", "seq lo dor", "seq cr bin", "display config", "load file", "sub sys sel", "aux mode", "comm sys", "nav con", "phase comp"))
			Texts.AddAll(Array As String("command sys", "sen scan", "sec scan", "bio scan", "reset", "power dis", "abort mode", "main file", "override", "chk file", "main access", "config mode", "primary", "or image"))
			Texts.AddAll(Array As String("smp verify", "alert mode", "rf modulate", "scale mode", "display resulte", "adges file", "band override", "read file", "configuration", "screen display", "edit file", "call system"))
		Case 1'frames		respiration, cell activity, neural activity, cortical, dendritic, neural, cerebral monitor, synaptic analysis, eeg, resp, pulse, cell rate
			Texts.AddAll(Array As String("helm plane", "declanation", "navigation", "Modulation &###", "Log ####", "Formula ref ####", "rel mol pres ##", "std mol pres ##", "rev mol pres ##"))
			Texts.AddAll(Array As String("stellar scan ####", "perimeter scan", "attenuation", "bearing", "unbg", "primary systems analysis", "secondary systems analysis", "systems monitor #####"))
			Texts.AddAll(Array As String("propulsion sys", "gndn ###-#", "transcription 09-27", "coil emissions ###", "plasma level #", "external pressure", "comm analysis", "bio analysis"))
			Texts.AddAll(Array As String("&&&-##", "SNSR DATA", "SPATIAL FLUX", "DIAGNOSTIC", "SYS. MAIN"))
		Case 2'printed frames
			Texts.AddAll(Array As String("shield freq", "Power avail", "#-### aux", "unit #", "&####", "reset seq &-###", "power levels", "&-##&", "freq level", "&&&", "BANDWIDTH", "prg level", "pwr", "comm bnd")) 
			Texts.AddAll(Array As String("###-###", "aux"))
	End Select
	tempstr = Texts.get(Rnd(0, Texts.Size))'get random
	If tempstr.Contains("#") Then
		tempstr2.Initialize 
		For temp = 0 To tempstr.Length-1
			tempchar = API.mid(tempstr, temp,1)
			Select Case tempchar 
				Case "#":	tempstr2.Append( Rnd(0,10) )'replace # with random numbers
				Case "&":	tempstr2.Append( Chr(Asc("A") + Rnd(0,26)) )'replace & with random letters
				Case Else:	tempstr2.Append(API.mid(tempstr, temp,1))
			End Select
		Next
		tempstr = tempstr2.ToString 
	End If
	Return tempstr.ToUpperCase 
End Sub

'TheColors: array of Quantity, ColorID pairs
Sub AddENTbuttons(X As Int, Y As Int, Width As Int, Height As Int, ButtonWidth As Int, ButtonHeight As Int, TheColors() As Int)
	Dim WhitespaceX As Int, WhitespaceY As Int, ButtonsX As Int, ButtonsY As Int, ColorIndex As Int , X2 As Int, TempX As Int, TempY As Int, ColorID As Int 
	If Width > 0 And Height>0 Then
		ButtonsX = ENTbuttonsCanFit(Width,Height,ButtonWidth,ButtonHeight,True)
		ButtonsY = ENTbuttonsCanFit(Width,Height,ButtonWidth,ButtonHeight,False)
		WhitespaceX = ENTWhiteSpace(Width,Height,ButtonWidth,ButtonHeight,True,ButtonsX)
		WhitespaceY = ENTWhiteSpace(Width,Height,ButtonWidth,ButtonHeight,False,ButtonsY)	
		If ButtonsX > 0 And ButtonsY > 0 Then 
			ColorID = TheColors(1)
			For TempY = 1 To ButtonsY
				If ButtonsX = 1 Then X2 = X+Width*0.5-ButtonWidth*0.5 Else X2=X
				For TempX=1 To ButtonsX
					AddWallpaperLCAR("ARTENT", -1, X2,Y, ButtonWidth, ButtonHeight, ColorID,0, ENTcolor(ColorID), LCAR.ENT_Button, LCARSeffects2.RandomENT, RandomENT(0), "", -1, True, 5, True, Rnd(0,2), 255)
					X2=X2+ButtonWidth+WhitespaceX
				Next
				Y=Y+ButtonHeight+WhitespaceY
				TheColors(ColorIndex) = TheColors(ColorIndex) - 1 
				If TheColors(ColorIndex) = 0 And ColorIndex + 1 < TheColors.Length -2 Then
					ColorIndex=ColorIndex+1
					ColorID = TheColors(ColorIndex+1)
				End If
			Next
		End If
	End If
End Sub

Sub AddWallpaperLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String,Group As Int,  Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int ) As Int
	Dim IsRND As Boolean = ElementType = LCAR.ENT_RndNumbers Or ElementType = LCAR.TMP_RndNumbers Or ElementType = LCAR.LCAR_RndNumbers, LeftChar As String = API.Left(Text,1)
	If ColorID = LCAR.LCAR_Random Then ColorID = ENTcolor(-1)
	If IsRND Then LWidth = API.IIF(LWidth < 0, -RND_ID, RND_ID)
	If LeftChar = "&" Then Text = RandomENT( API.Right(Text, Text.Length-1) )
	If LeftChar = "#" Then Text = LCARSeffects6.RandomNumber( Text )
	Dim Temp As LCARelement =LCAR.MakeLCAR(Name,-999,X,Y,Width,Height,LWidth,RWidth,ColorID,ElementType,Text,SideText,Tag,Group,True,TextAlign,Enabled,Align,255)
	CallSub2(WallpaperService, "AddLCAR2", Temp)
	If IsRND Then RND_ID = RND_ID + 1
End Sub
Sub AddENTpage(X As Int, Y As Int, Width As Int, Height As Int, PageType As Int)
	Dim ButtonWidth As Int = 150 * LCAR.ScaleFactor, ButtonHeight As Int = 50 * LCAR.ScaleFactor
	Dim Circlesize As Int = LCARSeffects2.GetPreCARSminimumWidth( Min(Width,Height) * 0.5), MeterSize As Int = Circlesize* 0.3, Whitespace As Int = 50
	Dim temp As Int=Y+Height*0.5-Circlesize*0.5, temp2 As Int=Whitespace*2+Circlesize, temp3 As Int = Width*0.5 - (Circlesize+Whitespace+ButtonWidth)*0.5
	Dim temp4 As Int=Width-ButtonWidth-Whitespace*2, tempX As Int=X', tempY As Int =Y
	'Log("AddENTpage: " & PageType)
	Select Case PageType '- 1000
		'Wallpaperservice.LCARelements	ENT_Radar	ENT_Meter	ENT_RndNumbers	PCAR_Frame	ENT_Sin		LCAR_DNA
		
		Case 1000'rnd buttons
			AddENTbuttons(X,Y,Width,Height, ButtonWidth,ButtonHeight, Array As Int(999, -1))

		Case 1001'big radar
			tempX=Circlesize*1.6 +100
			AddWallpaperLCAR("PERSCAN", -1, X,Y,Circlesize,Circlesize, 0,0,  LCAR.LCAR_Random, LCAR.ENT_Radar, "PERIMETER SCAN", "", "", 0, True, 0, True, 0, 255)'PCAR_Frame
			AddWallpaperLCAR("ATTENUA", -1, X+Circlesize+Whitespace,Y, MeterSize, Circlesize, Whitespace,Whitespace, LCAR.LCAR_Random, LCAR.ENT_Meter, "ATTENUATION", "", "", 0, True, LCAR.LCAR_Random, True,  3, 255)
			AddWallpaperLCAR("BEARING", -1, X+Circlesize*1.3+Whitespace*2,Y, MeterSize, Circlesize, Whitespace,Whitespace, -1, LCAR.ENT_Meter, "BEARING", "", "", 0, True, LCAR.LCAR_Random, True,  3, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+Circlesize+Whitespace, tempX, Height-Circlesize-Whitespace,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "SNSR DATA", "", "", 0, True, 0, True, 0, 255)
			AddENTbuttons(X+tempX+Whitespace, Y, Width-tempX-Whitespace, Height, ButtonWidth, ButtonHeight, Array As Int(3,0, 3,1, 999,2))
		
		Case 1002'big wavedar
			AddWallpaperLCAR("ATTENUA", -1, X,Y, MeterSize, Circlesize, 50,50, LCAR.LCAR_Random, LCAR.ENT_Meter, "ATTENUATION", "", "", 0, True, LCAR.LCAR_Random, True,  3, 255)
			AddWallpaperLCAR("PREFRAME", -1, X+Whitespace+MeterSize,Y, Circlesize,Circlesize,  0,-1,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "SPATIAL FLUX", "", "",   0, True, 2, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+Circlesize+Whitespace*2, Whitespace+MeterSize+Circlesize, Height-Circlesize-Whitespace*2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "SENSOR DATA", "", "", 0, True, 0, True, 0, 255)
			temp=MeterSize+Whitespace*2+Circlesize
			AddENTbuttons(X+temp, Y, Width-temp, Height, ButtonWidth, ButtonHeight, Array As Int(999,-1))
			
		Case 1003'small wavedar
			AddWallpaperLCAR("PREFRAME", -1, X+temp3,temp, Circlesize,Circlesize,  0,-1,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "SPATIAL FLUX", "ATTACK THRESHOLD 0.23", "",   0, True, 2, True, 0, 255)
			
		Case 1004'small rnd
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3,temp, Circlesize,Circlesize, RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			
		Case 1005'hoshi's
			temp=ButtonWidth+Whitespace
			temp2=(Height-(Whitespace*2))/ 3
			temp3=(Width-temp)*0.5 - Whitespace*0.5
			AddWallpaperLCAR("PREFRAME", -1, X,Y, Width-temp,temp2,  80,15,  LCAR.LCAR_Random,  LCAR.ENT_Sin,  "&1", "", "",  0, True,  1, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("PREFRAME", -1, X,Y+Height-temp2, Width-temp,temp2,  90,5,  LCAR.LCAR_Random,  LCAR.ENT_Sin,  "&1", "", "",  0, True,  1, True, 0, 255)
		
		Case 1006'block of 6 rnds
			temp=ButtonWidth+Whitespace
			temp2=(Height-(Whitespace*2))/ 3
			temp3=(Width-temp)*0.5 - Whitespace*0.5
			AddWallpaperLCAR("RNDBLOC", -1, X, Y, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+Height-temp2, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y+Height-temp2, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
		
		Case 1007'small circle ent
			AddWallpaperLCAR("PREFRAME", -1, X+temp3,temp, Circlesize,Circlesize,  0,-1,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "&1", "", "",   0, True, 1, True, 0, 255)
			
		Case 1008'block of 3 rnds
			temp=(Width-ButtonWidth-Whitespace*3) * 0.5'width
			temp2 = Height/3
			AddWallpaperLCAR("RNDBLOC", -1, X, Y, temp, temp2*2-Whitespace,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "PRIMARY SYSTEMS ANALYSIS", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp+Whitespace, Y, temp, Height,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "SECONDARY SYSTEMS ANALYSIS", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+Height-temp2, temp, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "UNBG", "", "", 0, True, 0, True, 0, 255)
		
		Case 1009'small radar
			AddWallpaperLCAR("PERSCAN", -1, X+temp3,temp,Circlesize,Circlesize, 0,0,  LCAR.LCAR_Random, LCAR.ENT_Radar, "PERIMETER SCAN", "", "", 0, True, 0, True, 0, 255)'PCAR_Frame
			
		Case 1010'2 rnds plus topview
			temp2=Height*0.5 - Whitespace * 0.5
			temp3 = Width*0.60
			AddWallpaperLCAR("RNDBLOC", -1, X, Y, temp4, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y+Height-temp2, temp4-temp3-Whitespace, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("PREFRAME", -1, X,Y+Height-temp2, temp3,temp2,  0,0,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "&1", "", "",   0, True, 1, True, 0, 255)
	
		Case 1011'hoshi's sequel
			temp=ButtonWidth+Whitespace
			temp2=(Height-(Whitespace*2))/ 3
			temp3=(Width-temp)*0.5 - Whitespace*0.5
			AddWallpaperLCAR("PREFRAME", -1, X,Y, Width-temp,temp2,   0,0,  LCAR.LCAR_Random,  LCAR.ENT_Sin,  "&1", "", "",   0, True, 4, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X+temp3+Whitespace, Y+temp2+Whitespace, temp3, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("PREFRAME", -1, X,Y+Height-temp2, Width-temp,temp2,   0,0,  LCAR.LCAR_Random,  LCAR.ENT_Sin,  "&1", "", "",   0, True, 4, True, 0, 255)
		
		Case 1012'3 squircles + rnd
			temp=(temp4 - Whitespace) * 0.5
			temp2 = (Height-Whitespace) *0.5
			AddWallpaperLCAR("PREFRAME", -1, X,Y, temp,temp2,  0,1,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "&1", "", "",   0, True, 3, True, 0, 255)
			AddWallpaperLCAR("PREFRAME", -1, X+temp+Whitespace,Y, temp,temp2,  0,2,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "&1", "", "",   0, True, 4, True, 0, 255)
			AddWallpaperLCAR("RNDBLOC", -1, X, Y+Height-temp2, temp, temp2,  RND_ID,0, LCAR.LCAR_Random, LCAR.ENT_RndNumbers, "&1", "", "", 0, True, 0, True, 0, 255)
			AddWallpaperLCAR("PREFRAME", -1, X+temp+Whitespace,Y+Height-temp2, temp,temp2,  0,3,  LCAR.LCAR_Random,  LCAR.PCAR_Frame,  "&1", "", "",   0, True, 1, True, 0, 255)
		
		Case 1013'DNA
			AddWallpaperLCAR("DNA",  0, X, Y, Width-Whitespace,Height,  0, 0, LCAR.LCAR_Orange , LCAR.LCAR_DNA, "",  "", "",  0,  False,0 , True , LCARSeffects6.RandomDNA(2) , 0) 
		
	End Select'update DeclareTOSPage
	Select Case PageType
		Case 1003,1004,1007,1009: AddENTbuttons(X+temp3+Circlesize+Whitespace, temp, ButtonWidth, Circlesize, ButtonWidth, ButtonHeight, Array As Int(999,-1))'small types
		Case 1005,1006,1008,1010,1011, 1012: AddENTbuttons(X+Width-ButtonWidth-Whitespace, Y, ButtonWidth+Whitespace, Height, ButtonWidth, ButtonHeight, Array As Int(999,-1))'along right edge			
	End Select
End Sub

'Index: -9=wavedar blue, -8=elemental grey, -7=dark turquoise, -6=turquiose, -5=red, -4=light grey, -3=grey, -2=count, -1=random, 0=green, 1=yellow, 2=red
Sub ENTcolor(Index As Int) As Int 
	Select Case Index
		Case -9: Return Colors.rgb(51,121,191)	'wavedar blue
		Case -8: Return Colors.RGB(193,198,204)	'elemental grey
		Case -7: Return Colors.RGB(74,130,170)	'dark turquoise
		Case -6: Return Colors.rgb(114,194,194)	'turquoise
		Case -5: Return Colors.RGB(190,20,20)	'red
		Case -4: Return Colors.RGB(170,170,170)	'light grey
		Case -3: Return Colors.Gray 			'grey
		
		Case -2: Return 3
		Case 0: Return LCAR.Classic_Green 
		Case 1: Return LCAR.LCAR_Yellow
		Case 2: Return LCAR.LCAR_Red
	
		Case Else: Return ENTcolor(Rnd(0, ENTcolor(-2)))'random
	End Select
End Sub 

Sub ENTbuttonsCanFit(Width As Int, Height As Int, ButtonWidth As Int, ButtonHeight As Int, IsX As Boolean) As Int 
	Dim temp As Int
	If IsX Then
		Height=Width
		ButtonHeight=ButtonWidth
	End If
	temp = Floor(Height / ButtonHeight)
	If Not(IsX) Then temp = temp - 1
	'If temp = Ceil(Height/ButtonHeight) Then temp = temp -1 
	Return temp 
End Sub
Sub ENTWhiteSpace(Width As Int, Height As Int, ButtonWidth As Int, ButtonHeight As Int, IsX As Boolean, ButtonsCanFit As Int) As Int
	If ButtonsCanFit = 0 Then ButtonsCanFit = ENTbuttonsCanFit(Width,Height,ButtonWidth,ButtonHeight,IsX)
	If IsX Then
		Height=Width
		ButtonHeight=ButtonWidth
	End If
	Return (Height - (ButtonHeight * ButtonsCanFit)) / (ButtonsCanFit-1)
End Sub

Sub CheckForTOS As Boolean 'https://sites.google.com/site/emhbackupmodule/home/lcars/systos.png?attredirects=0&d=1
	Return File.Exists(LCAR.DirDefaultExternal, "systos.png") 
End Sub
Sub DrawTOSpage(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ID As Int)
	Dim Page As TOSPage = TOSPages.Get(ID), temp As Int , temp2 As Int, tempf As Float , Xs As List, Ys As List 
	Select Case Page.TOStype '	http://tosdisplaysproject.wordpress.com/bridge-station-displays/library_computer/
		Case 0'Universal translator status
			DrawTOSButton2FLT(Page, 10,			BG, X,Y,Width,Height,       	0.08995, 0.00000, 0.82710, 0.03402,			LCAR.LCAR_LightYellow,	6, "UNIVERSAL TRANSLATOR 0 5 TRANSMISSION STATUS - #", "", 2, 0,0)
			DrawTOSButton2FLT(Page, 3,			BG, X,Y,Width,Height,       	0.13551, 0.26731, 0.29907, 0.03402,			LCAR.LCAR_LightYellow,	6, "LINGUACODE #", "",  8, 0, 0)
			DrawTOSButton2FLT(Page, 7,			BG, X,Y,Width,Height,       	0.13201, 0.58809, 0.28505, 0.02795,			LCAR.LCAR_LightYellow,	6, "LINGUACODE #", "",  8, 0, 0) 
			DrawTOSButton2FLT(Page, 8,			BG, X,Y,Width,Height,       	0.12033, 0.73998, 0.29556, 0.02795,			LCAR.LCAR_LightYellow,	6, "LINGUACODE #", "",  8, 0, 0) 
			
			DrawTOSButton2FLT(Page, 0,   		BG, X,Y,Width,Height,       	0.00935, 0.32078, 0.10164, 0.0644,         	LCAR.Classic_Green,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 16,   		BG, X,Y,Width,Height,       	0.13785, 0.32078, 0.30257, 0.0644,         	LCAR.LCAR_LightYellow,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 1,   		BG, X,Y,Width,Height,       	0.45794, 0.32078, 0.10164, 0.0644,			LCAR.LCAR_LightYellow,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 19,			BG, X,Y,Width,Height,       	0.67056, 0.32078, 0.30257, 0.0644,			LCAR.LCAR_LightYellow,  	0, "S/COMMS","", 5, 0,0)
			
			DrawTOSButton2FLT(Page, 2,			BG, X,Y,Width,Height,       	0.01168, 0.63791, 0.10164, 0.0644,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 17,			BG, X,Y,Width,Height,       	0.12967, 0.63791, 0.30257, 0.0644,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 4,			BG, X,Y,Width,Height,       	0.44977, 0.63791, 0.07126, 0.0644,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 5,			BG, X,Y,Width,Height,       	0.53972, 0.63791, 0.07126, 0.0644,         	LCAR.Classic_Green,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 6,			BG, X,Y,Width,Height,       	0.62850, 0.63670, 0.07126, 0.0644,         	LCAR.Classic_Green,  	0, "", "", 5, 0,0)
			
			DrawTOSButton2FLT(Page, 18,			BG, X,Y,Width,Height,       	0.11799, 0.79222, 0.29556, 0.0644,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 20,			BG, X,Y,Width,Height,       	0.00000, 0.90279, 0.43121, 0.0644,			LCAR.LCAR_LightYellow,	0, "AUTO SYNTAX ANALYSIS MODE", "", 5,0,0)
			DrawTOSButton2FLT(Page, 9,			BG, X,Y,Width,Height,       	0.45794, 0.90279, 0.32477, 0.0644,			LCAR.LCAR_LightYellow,	0, "PROGRESS   - #", "", 5,0,0)
			
			DrawTOSButton2FLT(Page, 11,			BG, X,Y,Width,Height,       	0.79439, 0.64763, 0.19393, 0.06561,			LCAR.Classic_Green,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 12,			BG, X,Y,Width,Height,       	0.79439, 0.82260, 0.19393, 0.06561,			LCAR.Classic_Green,  	0, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 13,			BG, X,Y,Width,Height,       	0.79439, 0.93196, 0.19393, 0.06561,			LCAR.LCAR_DarkOrange, 	0, "", "", 5, 0,0)
		Case 1'Subspace relay status
			DrawTOSButton2FLT(Page, 0,   		BG, X,Y,Width,Height,       	0.0664, 0, 0.41463, 0.08874,				LCAR.Classic_Red,		6, "SUBSPACE RELAY%n%STATUS - #", "", 2, 0,0)
			DrawTOSButton2FLT(Page, 1,   		BG, X,Y,Width,Height,       	0.07724, 0.17881, 0.39973, 0.1947,			LCAR.LCAR_LightYellow,	7, "CIVIL COMM", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 2,   		BG, X,Y,Width,Height,       	0.07724, 0.49934, 0.39973, 0.1947,			LCAR.LCAR_LightYellow,	7, "TEMP RELAY", "", 5, 0,0)
			DrawTOSButton2FLT(Page, 3,   		BG, X,Y,Width,Height,       	0.07724, 0.81325, 0.39973, 0.1947,			LCAR.LCAR_LightYellow,	7, "LOCAL NET", "", 5, 0,0)
			
			DrawTOSButton2FLT(Page, 4,   		BG, X,Y,Width,Height,       	0.52710, 0.00927, 0.1626, 0.07682,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 5,   		BG, X,Y,Width,Height,       	0.77100, 0.19073, 0.1626, 0.07682,			LCAR.LCAR_DarkOrange,	0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 6,   		BG, X,Y,Width,Height,       	0.62195, 0.28742, 0.1626, 0.07682,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 7,   		BG, X,Y,Width,Height,       	0.62195, 0.60662, 0.1626, 0.07682,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			DrawTOSButton2FLT(Page, 8,   		BG, X,Y,Width,Height,       	0.62195, 0.91391, 0.1626, 0.07682,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
		Case 2'random buttons
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00135, 0.06805, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17116, 0.06805, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33423, 0.06805, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.06805, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.00000, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83288, 0.00000, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33423, 0.16272, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.21746, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.21746, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83288, 0.16272, 0.15768, 0.07988,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00135, 0.36095, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17116, 0.36095, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33423, 0.42160, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.36095, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.36095, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00135, 0.50888, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17116, 0.47337, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.56953, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.56953, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83288, 0.47337, 0.15768, 0.07988,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00135, 0.83728, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17116, 0.83728, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33423, 0.77663, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.77663, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.83728, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83288, 0.83728, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17116, 0.91864, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.50135, 0.65533, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.66442, 0.70710, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83288, 0.56953, 0.15768, 0.07988,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
		
		Case 3'SUBSPACE FREQ SCAN
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.20186, 0.41328, 0.59281, 0.13776,			LCAR.LCAR_LightYellow,	7, "SUBSPACE FEQ SCAN", "#", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.07425, 0.95695, 0.26914, 0.03321,			LCAR.LCAR_LightYellow,	10, " ", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.38863, 0.95695, 0.26914, 0.03321,			LCAR.Classic_Green,		10, " ", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.70070, 0.95695, 0.26914, 0.03321,			LCAR.LCAR_DarkOrange,	10, " ", "", 5,0,0)

			tempf=0.07077
			For temp2 = 1 To 10
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf,   0.00369, 0.06729, 0.17958,			LCAR.LCAR_LightYellow,	0, "", "", 8,0,0)'row 1
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf,   0.57621, 0.06729, 0.17958,			LCAR.Classic_Green,		0, "", "", 8,0,0)'row 3
				tempf=tempf+0.08816
			Next 
			
			tempf=0.02088
			For temp2 = 1 To 11
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf,   0.20172, 0.06729, 0.17958,			LCAR.LCAR_LightYellow,	0, "", "", 2,0,0)'row 2
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf,   0.76932, 0.06729, 0.17958,			LCAR.LCAR_DarkOrange,	0, "", "", 2,0,0)'row 4
				tempf=tempf+0.08816
			Next
		Case 4'random buttons and circles
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.04241, 0.14003, 0.14003,			LCAR.LCAR_LightYellow,	1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.21067, 0.14003, 0.14003,			LCAR.LCAR_LightYellow,	1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.37756, 0.14003, 0.14003,			LCAR.Classic_Red,		1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.54036, 0.14003, 0.14003,			LCAR.Classic_Red,		1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.70451, 0.14003, 0.14003,			LCAR.Classic_Red,		1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.8529, 0.85226, 0.14003, 0.14003,			LCAR.LCAR_LightYellow,	1, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.01414, 0.09850, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.18529, 0.09850, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.01414, 0.19425, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.18529, 0.19425, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.34795, 0.25855, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.02462, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.12312, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.01414, 0.90561, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.34795, 0.90561, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.90561, 0.14569, 0.0725,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.01414, 0.41313, 0.14569, 0.0725,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.18529, 0.41313, 0.14569, 0.0725,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.34795, 0.41313, 0.14569, 0.0725,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51061, 0.37209, 0.14569, 0.0725,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.18529, 0.55814, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.37209, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51061, 0.46375, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51061, 0.55814, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51061, 0.64843, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.46375, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.55814, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67610, 0.64843, 0.14569, 0.0725,			LCAR.Classic_Red,		0, "", "", 5,0,0)
		
		Case 5'random buttons with text
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.05954, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "TERMINAL%n%NODE", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.20305, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "SHORT RNG%n%RF PKUP", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.34198, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "OPTICAL%n%DATA NET", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.49771, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "DSKTOP%n%TERMINAL", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.64275, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "LCARS%n%SUBPROC", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.77710, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "TRICORDR%n%DUMP", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00000, 0.91145, 0.14401, 0.07634,			LCAR.LCAR_LightYellow,	6, "PERSNL%n%COMMUN", "", 4, 0,0)
				
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.00611, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.09313, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51413, 0.00611, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67295, 0.04427, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83849, 0.00611, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.22901, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.17863, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51413, 0.22901, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67295, 0.17863, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83849, 0.17863, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.34351, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.29008, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.40153, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67295, 0.29008, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83849, 0.40153, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.63817, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.57557, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67295, 0.46412, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67295, 0.57557, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83849, 0.57557, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.74962, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.74962, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51413, 0.74962, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83849, 0.74962, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17362, 0.86412, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.33917, 0.92519, 0.15343, 0.06718,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.51413, 0.86412, 0.15343, 0.06718,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
		
		Case 6'                           0        1        2        3        4        5        6        7        8        9        10       11       12       13       14       15
			Xs.Initialize2(Array As Float(0.03651, 0.09524, 0.15317, 0.21349, 0.28413, 0.34365, 0.40317, 0.46190, 0.52381, 0.58571, 0.64444, 0.70476, 0.76587, 0.82460, 0.88492, 0.94524))
			Ys.Initialize2(Array As Float(0.01587, 0.06349, 0.10317, 0.15873, 0.18651, 0.25794, 0.28175, 0.34524, 0.42063, 0.48810, 0.58730, 0.71825, 0.87302))
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00159, 0.05556, 0.02619, 0.29762,			LCAR.Classic_Red,		0, "", "", 2,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00159, 0.38095, 0.02619, 0.29762,			LCAR.LCAR_LightYellow,	0, "", "", 2,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.00159, 0.70635, 0.02619, 0.29762,			LCAR.Classic_Green,		0, "", "", 2,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0),Ys.Get(5), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1),Ys.Get(3), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1),Ys.Get(7), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2),Ys.Get(0), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2),Ys.Get(9), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3),Ys.Get(5), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4),Ys.Get(4), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5),Ys.Get(2), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(6),Ys.Get(0), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(6),Ys.Get(8), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(7),Ys.Get(4), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(8),Ys.Get(0), 0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(10),Ys.Get(4),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(11),Ys.Get(1),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(12),Ys.Get(5),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(13),Ys.Get(4),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(14),Ys.Get(0),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(15),Ys.Get(0),0.05238,0.12698,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0),Ys.Get(9), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0),Ys.Get(11),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3),Ys.Get(9), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4),Ys.Get(10),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5),Ys.Get(6), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(6),Ys.Get(5), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(8),Ys.Get(4), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(8),Ys.Get(10),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(9),Ys.Get(8), 0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(10),Ys.Get(7),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(11),Ys.Get(8),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(12),Ys.Get(10),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(13),Ys.Get(11),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(14),Ys.Get(8),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(15),Ys.Get(8),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(15),Ys.Get(11),0.05238,0.12698,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			For temp2 = 0 To 15
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       Xs.Get(temp2),Ys.Get(12),0.05238,0.12698,	LCAR.Classic_Green,		0, "", "", 5,0,0)
			Next
		
		Case 7'artificial 1
			Xs.Initialize2(Array As Float(0.11321, 0.25067, 0.39084, 0.54717, 0.69811))
			tempf=0.04582
			For temp2 = 1 To 6
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf, 0.00469, 			0.07817, 0.18545,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf+ 0.05121, 0.19718,  	0.07817, 0.18545,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf+ 0.11321, 0.39437,  	0.07817, 0.18545,		API.IIF(temp2<3, LCAR.Classic_Green, LCAR.LCAR_LightYellow),	0, "", "", 5,0,0)
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       tempf+ 0.15633, 0.58685,  	0.07817, 0.18545,		API.IIF(temp2<3, LCAR.Classic_Green, LCAR.LCAR_LightYellow),	0, "", "", 5,0,0)
				tempf=tempf+0.11321
			Next
			For temp2 = 0 To Xs.Size-1
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       Xs.Get(temp2), 0.80516, 0.07817, 0.18545,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			Next
			tempf=0.00704
			For temp2 = 0 To 7
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       0.9000, tempf, 0.10000, 0.0892,				API.IIF(temp2=2 Or temp2=3,LCAR.LCAR_Red ,LCAR.LCAR_LightYellow),  0, "", "", 5,0,0)
				tempf=tempf+0.10094
			Next
		
		Case 8'artificial 2
			Xs.Initialize2(Array As Float(0.00903, 0.1693, 0.33183, 0.49661, 0.66140, 0.83296))
			Ys.Initialize2(Array As Float(0.01053, 0.0800, 0.16211, 0.22947, 0.29895, 0.44632, 0.51579, 0.56421, 0.61263, 0.66316, 0.76421, 0.81263, 0.85895, 0.92000  ))
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(1), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(2), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(1), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(2), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(1), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(0), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(4), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(4), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(3), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(4), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(4), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(4), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(5), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(5), 0.15124, 0.07158,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(5), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(6), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(5), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(6), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(7), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(10), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(9), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(8), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(9), 0.15124, 0.07158,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(8), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(9), 0.15124, 0.07158,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(8), 0.15124, 0.07158,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(12), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(12), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(11), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(11), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(11), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(13), 0.15124, 0.07158,	LCAR.Classic_Red,		0, "", "", 5,0,0)
		
		Case 9'artificial 3 'nice grid
			InitXY(Xs, 0.01050, 0.15612, 6)
			InitXY(Ys, 0.02948, 0.09297, 11)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(0), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(0), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), 0.0000000, 0.14768, 0.13832,		LCAR.Classic_Green,		1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(0), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(0), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), 0.1400000, 0.14768, 0.13832,		LCAR.Classic_Red,		1, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(2), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(3), 0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(3), 0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(3), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(3), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(3), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(4), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(4), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(4), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(4), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(5), 0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(5), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(5), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(5), 0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(6), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(6), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(6), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(7), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(7), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(7), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(8), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(8), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(9), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(9), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(9), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(9), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(10),0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(10),0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(10),0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
		
		Case 10'artificial 4, staggerd grid
			InitXY(Xs, 0.02110, 0.15612, 6)',0.14768, 0.08163
			Ys.Initialize2(Array As Float(0.01131, 0.09502, 0.18778, 0.22624, 0.34842, 0.38235, 0.42081, 0.45023, 0.47964, 0.56561, 0.65611, 0.70362, 0.77828, 0.83032, 0.91855)) 
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(0), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(0), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(1), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(2), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(3), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(3), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(2), 0.14768, 0.08163,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(4), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(4), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(5), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(4), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(4), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(6), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(8), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(7), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(9), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(9), 0.14768, 0.08163,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(9), 0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(10),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(11),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(13),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(13),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(12),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(12),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(13),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(13),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(14),0.14768, 0.08163,		LCAR.Classic_Red,		0, "", "", 5,0,0)
		Case 11'artificial 5 
			InitXY(Xs, 0.01050, 0.15612, 6)
			Ys.Initialize2(Array As Float(0.02321, 0.14979, 0.22785, 0.2827, 0.327, 0.35865, 0.43882, 0.47257, 0.50422, 0.51899, 0.54641, 0.57806, 0.67932, 0.75105, 0.82068, 0.89873))
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(0), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(0), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(1), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(1), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(2), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(1), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(3), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(5), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(4), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(3), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(5), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(3), 0.14768, 0.07595,		LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(8), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(6), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(7), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(6), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(6), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(6), 0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(11),0.14768, 0.07595,		LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(9), 0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(10),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(0), Ys.Get(12),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(12),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(2), Ys.Get(13),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(12),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(12),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(13),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(1), Ys.Get(14),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(3), Ys.Get(15),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(4), Ys.Get(14),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	Xs.Get(5), Ys.Get(15),0.14768, 0.07595,		LCAR.Classic_Red,		0, "", "", 5,0,0)
		Case 12'shipwide environmental status
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.02865, 0.0188, 0.45443, 0.04615,			LCAR.LCAR_LightYellow,	6, "SHIPWIDE ENVIRONMENTAL STATUS", "", 4, 0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.03776, 0.40342,0.05208, 0.04103,			LCAR.LCAR_LightYellow,	0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.59245, 0.02393, 0.05208, 0.04103,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.0651, 0.45299, 0.05208, 0.04103,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			temp = DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       		0.14062, 0.13675, 0.8112, 0.32308,			ID,						11, "","", temp, 0,0)
			temp = DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       		0.14062, 0.50256, 0.8112, 0.46496,			ID,						12, "","", temp, 0,0)
		Case 13'star drive
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.63071, 0.03841, 0.35025, 0.03585,			LCAR.LCAR_LightYellow,	6, "DISTRIBUTION NETWORK", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.63071, 0.37004, 0.35025, 0.03585,			LCAR.LCAR_LightYellow,	6, "ESS BUS SOURCE CLOSED", "", 4, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.63071, 0.67222, 0.35025, 0.03585,			LCAR.LCAR_LightYellow,	6, "NETWORK CROSSFEEDS", "", 4, 0,0)
			
			tempf=0.0128
			For temp2 = 1 To 6
				temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       0.01777, tempf,   0.06218, 0.15749,			LCAR.LCAR_LightYellow,	14, "", "", 2, 0,0)
				tempf = tempf + 0.16133
			Next
			
			'ESS SOURCE BUS
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67386, 0.43662, 0.10152, 0.06018,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67386, 0.52881, 0.10152, 0.06018,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.80584, 0.52881, 0.10152, 0.06018,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.91117, 0.58515, 0.05838, 0.03713,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			
			'Surrounding STAR DRIVE
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.17259, 0.22407, 0.06472, 0.03969,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.47335, 0.22535, 0.06472, 0.03969,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.32741, 0.00896, 0.06472, 0.03969,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			
			'DISTRIBUTION NETWORK
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.73731, 0.10115, 0.06472, 0.03969,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.68274, 0.17670, 0.06472, 0.03969,			LCAR.Classic_Green,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.78807, 0.14853, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.84137, 0.19974, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.91117, 0.16005, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.91117, 0.28169, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5,0,0)
			
			'NETWORK CROSSFEEDS
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67640, 0.80282, 0.06472, 0.03969,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.67386, 0.90397, 0.06472, 0.03969,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.72843, 0.72727, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.78046, 0.77337, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83376, 0.81818, 0.06472, 0.03969,			LCAR.Classic_Red,		0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.75888, 0.90397, 0.06472, 0.03969,			LCAR.Classic_Green,		0, "", "", 5, 0, 0) 
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.83249, 0.90397, 0.06472, 0.03969,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			
			'Under STAR DRIVE
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.29569, 0.85787, 0.13071, 0.12804,			LCAR.Classic_Red,		1, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.29569, 0.68246, 0.13071, 0.06402,			LCAR.LCAR_LightYellow,	0, "", "", 5, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.29569, 0.76312, 0.13071, 0.06402,			LCAR.Classic_Green,		0, "", "", 5, 0, 0)
			
			'STAR DRIVE
			DrawTOSButton2FLT(Page, -1,BG, X,Y,Width,Height,       				0.125, 0.07298, 0.46701, 0.86684,			ID,						13, "", "", temp, 0,0)
		Case 14'contingency power
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.09218, 0.17867, 0.90782, 0.66533,			0, 16, "", "", 5,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.10385, 0.90933, 0, 0,						LCAR.LCAR_LightYellow,	15, "CONTINGENCY POWER/BATTERIES SUBSYSTEMS", "", -1, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.10385, 0.95067, 0, 0,						LCAR.LCAR_LightYellow,	15, "SUBSYSTEM ELEMENTS G-#", "", -1, LCAR.Fontsize-2,0)
			
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.86814, 0.908, 0.04201, 0.036,				LCAR.Classic_Green,		0, "", "", -15, 0, 0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.86814, 0.96, 0.04201, 0.036,				LCAR.Classic_Green,		0, "", "", -15, 0, 0)

			tempf= 0.06534
			For temp2 = 1 To 17
				temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      tempf, 0.01333, 0.04201, 0.036,				LCAR.LCAR_Random,		0, "", "", -15, 0, 0)
				temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      tempf, 0.06667, 0.04201, 0.036,				LCAR.LCAR_Random,		0, "", "", -15, 0, 0)
				temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      tempf, 0.11600, 0.04201, 0.036,				LCAR.LCAR_Random,		0, "", "", -15, 0, 0)
				tempf=tempf+0.055
			Next
		Case 15'graviton field decay in picoseconds
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.12848, 0.00244, 0.86788, 0.87439,			0,17,"","",0,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.22182, 0.94512, 0.56485, 0.04634,			LCAR.LCAR_LightYellow,	15, "GRAVITON FIELD DECAY IN PICOSECONDS", "", 5,0,0)
		
		Case 16'net field stability
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.14815, 0.0049, 0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.21759, 0.05882,0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.28819, 0.11397,0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.43519, 0.05882,0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.57755, 0.11397,0.05787, 0.04044,			LCAR.Classic_Green,		0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.71759, 0.05882,0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.78704, 0.00000,0.05787, 0.04044,			LCAR.Classic_Green,		0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.78704, 0.05882,0.05787, 0.04044,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.86690, 0.0049, 0.05787, 0.04044,			LCAR.Classic_Red,		0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.93403, 0.0049, 0.05787, 0.04044,			LCAR.Classic_Green,		0, "", "", -15, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.01852, 0.26103, 0.01968, 0.10662,			LCAR.LCAR_LightYellow,	10, "", "", 5, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.01852, 0.38725, 0.01968, 0.10662,			LCAR.LCAR_LightYellow,	10, "", "", 5, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.01852, 0.54412, 0.01968, 0.10662,			LCAR.LCAR_LightYellow,	10, "", "", 5, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.01852, 0.66667, 0.01968, 0.10662,			LCAR.Classic_Green,		10, "", "", 5, 0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,      	0.01852, 0.78799, 0.01968, 0.10662,			LCAR.Classic_Green,		10, "", "", 5, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.13773, 0.18137, 0.83565, 0.70711,			0,						18,"","",0,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.50000, 1.00000, 0.00000, 0.00000,			LCAR.LCAR_LightYellow,	15, "NET FIELD STABILITY IN MILLICOCHRANES/NANOSECOND", "", -8,0,0)
		
		Case 17'station keeping
			tempf= Height*0.03137
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.09522, 0.37014, 0.00000, 0.088455,		LCAR.Classic_Red,		19, "", "", 0, tempf,0)'0.00195
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.10059, 0.44291, 0.05664, 0.00000,			LCAR.Classic_Red,		19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.20996, 0.25721, 0.68359, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.40918, 0.11794, 0.30664, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.71484, 0.09285, 0.00000, 0.16186,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)'|
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.73828, 0.04141, 0.22852, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)'--
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.15723, 0.07152, 0.09766, 0.00000,			LCAR.Classic_Green,		19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.70600, 0.025725, 0.033, 0.07, 			LCAR.LCAR_LightYellow,	21, "", "", 0, 0, tempf)
			
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.09522, 0.54300, 0.0000, 0.088455,			LCAR.Classic_Red,		19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.10059, 0.55709, 0.05664, 0.00000,			LCAR.Classic_Red,		19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.20996, 0.74279, 0.68359, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.40918, 0.88206, 0.30664, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.71484, 0.74529, 0.00000, 0.16186,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.73828, 0.95859, 0.22852, 0.00000,			LCAR.LCAR_LightYellow,	19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.15723, 0.92848, 0.09766, 0.00000,			LCAR.Classic_Green,		19, "", "", 0, tempf,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.70600, 0.905, 0.033, 0.07, 				LCAR.LCAR_LightYellow,	21, "", "", 0, 1, tempf)'0312825
			
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.21387, 0.07100, 0.00000, 0.87250,			LCAR.Classic_Green,		19, "", "", 0, tempf,0)'big
			
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00391, 0.00000, 0.18262, 0.40276,			LCAR.Classic_Red,		20, "DEUTERIUM", "TANK", 0, 0,0)
			temp= DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.13086, 0.41029, 0.05371, 0.06399,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.24219, 0.00000, 0.18066, 0.15000,			LCAR.Classic_Red,		0, "LASER IGNITION", "SYSTEM", -15,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.24219, 0.19322, 0.36133, 0.13676,			LCAR.Classic_Green,		0, "PORT FUSION REACTOR", "", -15,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.76660, 0.08407, 0.15918, 0.06148,			LCAR.Classic_Red,		0, "S/COMS", "", -15,0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.87305, 0.237135,0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )'''''
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.94824, 0.28858, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.94824, 0.00000, 0.04688, 0.277285,		LCAR.LCAR_LightYellow,	0, "", "", -18, 0,0)'
			
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.63867, 0.40527, 0.04688, 0.04015,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.63867, 0.45671, 0.04688, 0.04015,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.63867, 0.50816, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.69336, 0.40527, 0.04688, 0.04015,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.76855, 0.40527, 0.04688, 0.04015,			LCAR.Classic_Red,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.76855, 0.45671, 0.04688, 0.04015,			LCAR.Classic_Red,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.82227, 0.40527, 0.04688, 0.04015,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.88281, 0.40527, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.88281, 0.45671, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.88281, 0.50816, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.25000, 0.40903, 0.36719, 0.14555,			LCAR.LCAR_LightYellow,	8, "STATION KEEPING", "SYSTEM CONTROLLER", 5, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.46484, 0.58344, 0.14062, 0.06000,			LCAR.Classic_Green,		0, "S/COMS", "", -15, 0,0 )
			
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.00391, 0.59724, 0.18262, 0.40276,			LCAR.Classic_Red,		20, "DEUTERIUM", "TANK", -15, 1,0)			
			temp= DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.13086, 0.52572, 0.05371, 0.06399,			LCAR.LCAR_LightYellow,	0, "", "", -15, 0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.24219, 0.85000, 0.18066, 0.15000,			LCAR.Classic_Red,		0, "LASER IGNITION", "SYSTEM", -15,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.24219, 0.67002, 0.36133, 0.13676,			LCAR.Classic_Green,		0, "STBD FUSION REACTOR", "", -15,0,0)
			DrawTOSButton2FLT(Page, -1, BG, X,Y,Width,Height,       			0.76660, 0.85445, 0.15918, 0.06148,			LCAR.Classic_Red,		0, "S/COMS", "", -15,0,0)
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.87305, 0.722715,0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )''''
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.94824, 0.67127, 0.04688, 0.04015,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.94824, 0.722715,0.04688, 0.277285,		LCAR.LCAR_LightYellow,	0, "", "", -12, 0,0)
			
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.45703, 0.00000, 0.15039, 0.09787,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			temp = DrawTOSButton2FLT(Page, temp, BG, X,Y,Width,Height,       	0.45703, 0.90213, 0.15039, 0.09787,			LCAR.Classic_Green,		0, "", "", -15, 0,0 )
			
		'ENTERPRISE pages
		'Case 1000'should not be encountered
		'	temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0, 0, 0.15124, 0.07158,		LCAR.LCAR_Red,	1000,  "TEST", "#", 5,0,0)
		'	temp = DrawTOSButton2FLT(Page, temp,BG, X,Y,Width,Height,       	0.155, 0, 0.15124, 0.07158,		LCAR.LCAR_Yellow,	1000,  "TEST", "#", 5,0,0)
			
		Case Else: LCAR.DrawUnknownElement(BG, X,Y,Width,Height,				LCAR.LCAR_LightYellow, False, 255,			"UNKNOWN " & API.IIF(Page.TOStype<1000, "TOS", "ENT") & " PAGE TYPE: " & ID)
	End Select 
End Sub' http://tosdisplaysproject.wordpress.com/bridge-station-displays/library_computer/
Sub InitXY(theList As List, Start As Float, Increment As Float, Quantity As Int)
	Dim temp As Int 
	theList.Initialize
	For temp = 1 To Quantity
		theList.Add(Start)
		Start = Start + Increment
	Next
End Sub

Sub RandomTOSpage(MaxWidth As Int, Era As Int) As Int 
	Dim Pages As List, temp As Int, MaxTypes As Int, MinTypes As Int, Name As String 
	Select Case Era 
		Case LCAR.LCAR_TOS
			MaxTypes = DeclareTOSPage(-3)
			Name = "TOS"
		
		Case LCAR.LCAR_ENT
			MaxTypes = DeclareTOSPage(-4)
			MinTypes = 1000
			Name = "NX1"
		
		Case LCAR.LCAR_TMP
			MinTypes = 2000
			MaxTypes = MinTypes + LCARSeffects7.AddENTBpage(0,0,0,0,-1)
			Name = "TMP"
	End Select
	
	If API.debugMode And Not(Main.ShowSubBridges) Then 
		'If WallpaperService.PreviewMode Then Return MaxTypes-1'last/newest pagetype first
		For temp = MaxTypes-1 To 0 Step -1
			If FindTOSpage(temp) = -1 And TOSPageCanBeUsed(temp) Then Return temp
		Next
	End If
	
	Pages.Initialize 
	For temp = MinTypes To MaxTypes -1 
		If FindTOSpage(temp) = -1 And TOSpageWidth(temp) <= MaxWidth And TOSPageCanBeUsed(temp) Then Pages.Add(temp)
	Next
	If Pages.Size=0 Then 
		Return -1 
	Else 
		If WallpaperService.PreviewMode And Main.ShowSubBridges Then 
			If WallpaperService.SubScreenIndex = -1 Then 
				Log("RandomTOSpage: " & Name & " Index was empty")
				WallpaperService.SubScreenIndex = 0
			End If
			Return Pages.Get(WallpaperService.SubScreenIndex)
		End If
		If Not(WallpaperService.PreviewMode) And WallpaperService.BridgePanels = 1 And WallpaperService.Settings.ContainsKey(Name) Then
			temp = WallpaperService.Settings.Get(Name)
			If temp = -1 Then 
				Log("RandomTOSpage: " & Name & " was empty")
				temp = 0 
			End If
			Return Pages.Get( temp )
		End If
		Return Pages.Get( Rnd(0, Pages.Size) )
	End If
End Sub
Sub FindTOSpage(PageType As Int) As Int 
	Dim temp As Int, tempPage As TOSPage 
	For temp = 0 To TOSPages.Size - 1
		tempPage = TOSPages.Get(temp)
		If tempPage.TOStype = PageType Then Return temp
	Next
	Return -1
End Sub








Sub DrawTNGFrame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, TopHeight As Int, Alpha As Int,Stage As Int, Style As Int)
	'Log("FRAME: " & Width)
	Dim BarWidth As Int=100,BarHeight As Int=17 ,ElbowHeight As Int =88,WhiteSpace As Int = 3,temp As Int,OneThird As Int= Width/3,SW As Int=23'LCAR_LightPurple,LCAR_DarkPurple,LCAR_Orange,LCAR_Red,LCAR_LightOrange)
	Select Case Style
		Case 0'standard
			If LCAR.SmallScreen Then
				BarWidth=BarWidth*0.5
				ElbowHeight=ElbowHeight*0.5
				BarHeight=10
				SW=12
			End If
			If Not(LCAR.RedAlert) Then Stage=-1
			temp=TopHeight- (ElbowHeight-BarHeight)
			LCAR.DrawRect(BG,X,Y,BarWidth, temp - WhiteSpace,  LCAR.GetColor(LCAR.LCAR_LightPurple, Stage=0,Alpha), 0)'top left corner square
			LCAR.DrawLCARelbow(BG,X,Y+temp, OneThird, ElbowHeight,BarWidth,BarHeight, 2, LCAR.LCAR_DarkPurple, Stage=1, "", 0, Alpha, Alpha<255)'top elbow
			
			Y=Y+TopHeight
			LCAR.DrawLCARelbow(BG,X,Y+BarHeight+WhiteSpace, OneThird, ElbowHeight,BarWidth,BarHeight, 0, LCAR.LCAR_Red, Stage=1, "", 0, Alpha, Alpha<255)'bottom elbow
			temp=BarHeight+ElbowHeight+WhiteSpace*2
			LCAR.DrawRect(BG,X, Y+temp,BarWidth, Height-temp, LCAR.GetColor(LCAR.LCAR_Orange, Stage=0,Alpha), 0)' left bar
			
			temp=X+OneThird+WhiteSpace
			ElbowHeight=Y+BarHeight+WhiteSpace
			LCAR.DrawRect(BG,temp,Y, SW, BarHeight,  LCAR.GetColor(LCAR.LCAR_Orange, Stage=2,Alpha), 0)
			LCAR.DrawRect(BG,temp,ElbowHeight, SW, BarHeight,  LCAR.GetColor(LCAR.LCAR_LightOrange, Stage=2,Alpha), 0)
			
			temp=temp+SW+WhiteSpace
			BarWidth=OneThird-SW-WhiteSpace
			LCAR.DrawRect(BG,temp,Y, BarWidth, BarHeight,  LCAR.GetColor(LCAR.LCAR_LightPurple, Stage=3,Alpha), 0)
			LCAR.DrawRect(BG,temp,ElbowHeight, BarWidth, API.IIF(LCAR.SmallScreen,5,6),  LCAR.GetColor(LCAR.LCAR_LightOrange, Stage=3,Alpha), 0)
			
			temp=temp+BarWidth+WhiteSpace
			LCAR.DrawRect(BG,temp,Y, BarWidth, BarHeight,  LCAR.GetColor(LCAR.LCAR_LightPurple, Stage=4,Alpha), 0)
			LCAR.DrawRect(BG,temp,ElbowHeight, BarWidth, BarHeight,  LCAR.GetColor(LCAR.LCAR_LightPurple, Stage=4,Alpha), 0)

			temp=temp+BarWidth+WhiteSpace
			LCAR.DrawRect(BG,temp,Y, SW, BarHeight,  LCAR.GetColor(LCAR.LCAR_Red, Stage=5,Alpha), 0)
			LCAR.DrawRect(BG,temp,ElbowHeight, SW, BarHeight,  LCAR.GetColor(LCAR.LCAR_LightOrange, Stage=5,Alpha), 0)
	End Select
End Sub


Sub DrawStyledToast(BG As Canvas, Style As Int, Volume As Int, Text As String, Alpha As Int, Width As Int, Height As Int,ScaleWidth As Int, ScaleHeight As Int) 
	Dim SideText As String,X As Int, Y As Int,Color As Int,temp As Int,temp2 As Int, temp3 As Float , Stage As Int, tempstr As String '0=fading in, 1=waiting, 2=fading out
	If Alpha = 255 Then 
		Stage= 1
	Else If LCAR.VolSeconds =0 Then
		Stage= 2
	End If
	
	X=ScaleWidth/2 - Width/2
	If Not(LCAR.ToastAlign) Then Y=ScaleHeight-Height*2
	If Text.Length=0 Then 
		SideText=LCAR.GetText("VOLUME", "chuS")
	Else If Text.Contains(":") Then
		SideText=API.GetSide(Text,":",True,False)
		Text=API.GetSide(Text,":",False,False)
	End If

	Select Case Style
		Case LCAR.LCAR_ENT
			LCAR.DrawRect(BG,ScaleWidth/2 - Width/2 - 13,0, Width+26, 54,Colors.ARGB(Alpha, 0,0,0), 0)
			LCARSeffects2.DrawPreCARSButton(BG, ScaleWidth/2 - Width/2 - 10, 0, Width+20, 50*LCAR.ScaleFactor,  LCAR.LCAR_Orange, False, Alpha, Text, SideText, True)
			If Text.Length=0 Then
				temp2=LCAR.ScaleFactor 
				temp=(50*temp2/3)-2
				
				DrawStyledVolume(BG, Style,Volume, ScaleWidth/2 - Width/2+(17*temp2), temp - (7*temp2), Width-(34*temp2),14*temp2, Alpha)
			End If
			
		Case LCAR.LCAR_TOS
			Color=LCAR.GetColor(LCAR.LCAR_Yellow, False,Alpha)
			LCAR.DrawRect(BG, X - 12, Y-12,Width+24,Height+24 , Colors.black , 0)
			LCAR.DrawRect(BG, X - 10, Y-10,Width+20,Height+20 , Color , 10)
			If SideText.Length>0 Then
				API.DrawText(BG, SideText, X+Width/2,Y, LCAR.TOSFont, LCAR.Fontsize, Color, 2)
				temp=BG.MeasureStringHeight(SideText,LCAR.TOSFont, LCAR.Fontsize)
				Y=Y+temp
			End If
			If Text.Length=0 Then 
				If Text.Length=0 Then DrawStyledVolume(BG, Style,Volume, X + 10, Y+Height/2-10, Width-20,20, Alpha)
			Else
				API.DrawText(BG, Text, X+Width/2,Y, LCAR.TOSFont, LCAR.Fontsize, Color, 2)
			End If
			
		Case LCAR.LCAR_TMP
			Color=Colors.ARGB(Alpha,0,0,0)		
			LCARSeffects2.DrawLegacyButton(BG,X-20,Y-20,Width+40,Height+40, Color, "",0, 0)
			temp = API.IIF(LCAR.RedAlert, LCAR.LCAR_RedAlert,LCAR.Classic_Blue)
			LCARSeffects2.DrawPreCARSFrame(BG,X-10,Y-10, Width+20, Height+20, temp, Alpha, 5, 10,10, SideText, API.IIF(Text.Length=0, 3,0), "TOAST")
			Color=LCAR.GetColor(temp, False,Alpha)
			If Text.Length=0 Then 
				DrawStyledVolume(BG, Style,Volume, X + 10, Y+Height/2-15, Width-20,30, Alpha)
			Else
				temp2=BG.MeasureStringHeight(SideText, LCARSeffects2.StarshipFont, LCAR.Fontsize)+2
				API.DrawText(BG, Text, X,Y+temp2, LCARSeffects2.StarshipFont, LCAR.Fontsize, Color, 0)
			End If
			
		Case LCAR.Klingon 
			'72w x 60h with 33h as the middle bar
			If Alpha=255 Then
				temp=1'staying
			Else If LCAR.VolSeconds>0 Then
				temp=2'going up
			Else 
				temp=3'going down
			End If
			
			Color = Colors.argb(Alpha, 255,0,0)'Colors.ARGB(Alpha, 255,255,27)
			LCARSeffects2.DrawKlingonFrame(BG,X-20,Y-20,Width+40,Height*2+40,Color,-1, 0,0, Text, SideText, Alpha,temp)
			temp=10
			If Text.Length=0 Then DrawStyledVolume(BG,Style, Volume, X+temp, Y+20,Width-temp, 20,Alpha)
		
		Case LCAR.Ferengi
			Width=170
			Height=106
			If LCAR.CrazyRez > 1 Then 
				Width=Width*LCAR.CrazyRez
				Height=Height*LCAR.CrazyRez
			End If
			X=ScaleWidth/2-Width/2
			Y=ScaleHeight-Height*2
			LCARSeffects2.LoadUniversalBMP(File.DirAssets, "quark.png", -LCAR.Ferengi)
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform,		0,0, 0,0, 		  X,Y,Width,Height, 		Alpha,False,False)
			
			Text="*Limit one per customer"
			temp2=10
			temp=BG.MeasureStringHeight(Text, Typeface.DEFAULT, temp2)
			BG.DrawText(Text, ScaleWidth/2, Y+ Height +temp*2, Typeface.DEFAULT, temp2, Colors.ARGB(Alpha, 90,54,49), "CENTER")
			
			Text="QUARK'S"
			temp2=API.GetTextHeight(BG, -Min(ScaleWidth,ScaleHeight), Text, Typeface.DEFAULT_BOLD)
			BG.DrawTextRotated(Text, ScaleWidth/2,ScaleHeight/2, Typeface.DEFAULT_BOLD, temp2, LCAR.GetColor(LCAR.LCAR_Purple, False, Alpha), "CENTER",  Qangle)
			Qangle=(Qangle+1) Mod 360
		
		Case LCAR.StarWars 
			If Text.Length=0 Then
				Color=Colors.ARGB(Alpha,0,0,0)'black
				LCAR.DrawRect(BG,X,Y,Width,Height,Color,0)
				Color=Colors.ARGB(Alpha,254,0,0)'red
				
				temp = Height*0.0773
				temp2= Height*0.0476
				BG.DrawCircle(X+Width/2, Y+temp, temp2,Color,True,0) 
				BG.DrawCircle(X+Width/2, Y+Height-temp, temp2,Color,True,0)
				
				temp=Width*0.937
				temp2=Height*0.773
				DrawStyledVolume(BG,Style, Volume,X+Width/2-temp/2,Y+Height/2-temp2/2,temp,temp2,Alpha)
			Else
				Height=Height*0.5
				Color= Colors.aRGB(Alpha,206, 211, 30)
				LCARSeffects2.DrawPreCARSFrame(BG,X-25,Y-15,Width+50,Height+30,Color, 0 ,5, 10,12, "",0, "")

				temp=BG.MeasureStringHeight("SCREENSHOT", LCAR.GetStyleFont(-1), LCAR.Fontsize)
				temp2=BG.MeasureStringwidth("SCREEN",LCAR.GetStyleFont(-1), LCAR.Fontsize)
				LCAR.DrawRect(BG,X,Y-temp, temp2,temp, Colors.black ,0)
				temp2=BG.MeasureStringwidth("SHOT",LCAR.GetStyleFont(-1), LCAR.Fontsize)
				LCAR.DrawRect(BG,X+Width-temp2,Y+Height, temp2,temp, Colors.black,0)

				API.DrawText(BG, "SCREEN", X, Y-3-temp, LCAR.GetStyleFont(-1), LCAR.Fontsize, Color, 0)
				API.DrawText(BG, "SHOT", X+Width, Y+Height+3, LCAR.GetStyleFont(-1), LCAR.Fontsize, Color,  3)
				
				API.DrawText(BG, Text,X,Y,LCAR.GetStyleFont(-1),LCAR.Fontsize, Color,0)
			End If
		
		Case LCAR.ChronowerX 
			temp = (ScaleHeight-Y) * ((255-Alpha)/255)
			If Text.Length=0 Then Text = "VOL: " & Volume & "%"
			CHX_DrawSquare(BG,X,Y+temp,Width,Height, False, Text, 2, CHX_LightBeige)
			
		Case LCAR.Battlestar
			If Text.Length = 0 Then Text = "VOL: " & Volume
			LCARSeffects4.DrawSliver2(BG, X,Y+temp, Width, Height,Colors.aRGB(Alpha,252,75,143), 1,-1, Text,Colors.argb(Alpha, 255,255,255),-1)
			
		Case LCAR.EVENT_Horizon 
			If Text.Length = 0 Then Text = "volume : " & Volume & " %"
			LCARSeffects4.DrawButton(BG,X,Y+temp,Width*1.5,Height, Text.ToLowerCase, Alpha)
			
		Case LCAR.StarshipTroopers
			If Text.Length = 0 Then 
				'Volume
			Else
				LCARSeffects2.LoadUniversalBMP(File.DirAssets, "troopers.png", LCAR.LCAR_AnswerMade)
				temp = LCAR.ListItemsHeight(2)
				temp2= (Alpha/255) * temp
				Color=Colors.RGB(192, 177, 155)

				'Top
				Y = -temp+ temp2
				LCARSeffects4.DrawRect(BG,0,Y, LCAR.ScaleWidth, temp, Color, 0)
				BG.DrawLine(0, Y+temp, LCAR.ScaleWidth, Y+temp, Colors.white,3)
				BG.DrawLine(0, Y+temp+2, LCAR.ScaleWidth, Y+temp+2, Colors.black,3)
				
				'Text
				Color = API.GetTextHeight(BG, -LCAR.ScaleWidth * 0.8, "FEDERALGALAXYTOP NEWSENLISTEXIT", LCARSeffects2.StarshipFont)
				X = BG.MeasureStringWidth("FEDERALGALAXYTOP NEWSENLISTEXIT", LCARSeffects2.StarshipFont, Color)
				X = (LCAR.ScaleWidth - X) / 6
				API.DrawTextAligned(BG, "FEDERAL", X, Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.Black,  7, 0,0)
				API.DrawTextAligned(BG, "GALAXY", X*2+BG.MeasureStringWidth("FEDERAL", LCARSeffects2.StarshipFont, Color), Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.Black, 7, 0,0)
				temp3=X*3+BG.MeasureStringWidth("FEDERALGALAXY", LCARSeffects2.StarshipFont, Color)'mouse center point
				If Stage=1 And ST_MouseX=0 And ST_MouseY = 0 And LCAR.VolSeconds = 1 Then
					LCARSeffects4.DrawRect(BG, temp3- X*0.5, Y+LCAR.ItemHeight*0.1, X + BG.MeasureStringWidth("TOP NEWS", LCARSeffects2.StarshipFont, Color), temp*0.95, Colors.Black, 0)
					API.DrawTextAligned(BG, "TOP NEWS", temp3, Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.white, 7, 0,0)	
				Else
					API.DrawTextAligned(BG, "TOP NEWS", temp3, Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.Black, 7, 0,0)				
				End If
				If Stage>0 Then temp3=temp3+ BG.MeasureStringWidth("TOP ", LCARSeffects2.StarshipFont, Color)
				API.DrawTextAligned(BG, "ENLIST", X*4+BG.MeasureStringWidth("FEDERALGALAXYTOP NEWS", LCARSeffects2.StarshipFont, Color), Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.Black, 7, 0,0)
				API.DrawTextAligned(BG, "EXIT", X*5+BG.MeasureStringWidth("FEDERALGALAXYTOP NEWSENLIST", LCARSeffects2.StarshipFont, Color), Y+LCAR.ItemHeight, 0, LCARSeffects2.StarshipFont,  Color, Colors.Black, 7, 0,0)
				
				'Mouse
				Select Case Stage'ST_MouseX, ST_MouseY 
					Case 0'fade in
						ST_MouseX = LCAR.ScaleWidth - temp3 
						ST_MouseY = LCAR.ScaleHeight*0.33
						ST_PathX  = 0
					Case 1'wait
						ST_MouseX = LCAR.Increment(ST_MouseX, 30, 0)
						ST_MouseY = LCAR.Increment(ST_MouseX, 10, 0)
						ST_PathX  = LCAR.Increment(ST_PathX,  30, LCAR.ScaleWidth)
				End Select
				If Stage>0 Then
					LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 128,0,39,115,       temp3+ST_MouseX, Y+LCAR.ItemHeight*1.5 + ST_MouseY, 39,115, 255, False,False)
				End If
				
				'Bottom
				Color=Colors.RGB(192, 177, 155)
				Y= LCAR.ScaleHeight - temp2
				BG.DrawLine(0, Y-2, LCAR.ScaleWidth, Y-2, Colors.black,3)
				BG.DrawLine(0, Y, LCAR.ScaleWidth, Y, Colors.white,3)
				LCARSeffects4.DrawRect(BG,0,Y, LCAR.ScaleWidth, temp, Color, 0)
				temp3 = 1.1130434782608695652173913043478'width/height     0.8984375'height/width
				LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform,		 0,0,  128,115,      0, Y,  temp*temp3, temp, 255, False,False)'logo
				If ST_PathX > 0 Then
					LCARSeffects.MakeClipPath(BG, 0, Y, ST_PathX, temp)
					temp3 = API.GetTextLimitedHeight(BG, temp, LCAR.ScaleWidth- (temp*temp3*2) ,Text, Typeface.DEFAULT_BOLD)
					API.DrawTextAligned(BG,  Text, LCAR.ScaleWidth*0.5, Y+ temp*0.5,  0, Typeface.DEFAULT_BOLD, temp3, Colors.White, 5, 2, Colors.Black)	
					BG.RemoveClip 
				End If
			End If
			
		Case LCAR.ImageToast
			If Text.Length = 0 Then 
				Style= LCAR.LCAR_TNG
			Else
				LCARSeffects2.LoadUniversalBMP("", Text, LCAR.SYS_Lightpack)
				Width=LCARSeffects2.CenterPlatform.Width
				Height=LCARSeffects2.CenterPlatform.Height 
				If LCAR.CrazyRez > 1 Then 
					Width=Width*LCAR.CrazyRez
					Height=Height*LCAR.CrazyRez
				End If
				If Width > LCAR.ScaleWidth Then 
					temp3 = Width/Height
					Width = LCAR.ScaleWidth
					Height = Width *temp3
				End If
				X=ScaleWidth/2-Width/2
				If LCAR.ToastAlign Then
					Y= LCAR.GetScaledPosition(1, False) *0.5 - Height *0.5
				Else
					Y=ScaleHeight-Height*2
				End If
				LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform,		0,0, 0,0, 		  X,Y,Width,Height, 		Alpha,False,False)
			End If
		
		Case LCAR.FreedomWars 
			LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, "sysfwars.png", LCAR.SYS_Lightpack)	
			Alpha = Min(Alpha, 192)
			Height = LCAR.ScaleHeight * 0.94
			Width = Min(Height, LCAR.ScaleWidth) * 0.84
			X=LCAR.ScaleWidth*0.5-Width*0.5
			Y=LCAR.ScaleHeight*0.5-Height*0.5
			If Alpha<255 Then Y = (Y-Height) + Height*(Alpha/192)
			
			If LCAR.Landscape Then 
				temp = Min(120, (LCAR.ScaleWidth - Width - 28) * 0.5)
				LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 384, 0, 120, 120, LCAR.ScaleWidth-temp-14, LCAR.ScaleHeight-temp-28, temp,temp, Alpha, False,False)
			End If
			
			Color = Colors.aRGB(Alpha, 242,54,49)'194, 11,13)
			LCAR.DrawGradient(BG, Colors.ARGB(Alpha,0,0,0), Colors.ARGB(Alpha,194,11,13), 8, X+1,Y+1,Width,Height, 0,0)
			LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Colors.ARGB(Alpha,194,11,13), 2)
			LCARSeffects2.TileBitmap(BG, LCARSeffects2.CenterPlatform, 504,17,17,16,       X,Y,Width, 0, False,False, Alpha ,1)
			LCARSeffects2.TileBitmap(BG, LCARSeffects2.CenterPlatform, 538,17,17,16,       X,Y+Height-16,Width, 0, False,False, Alpha,1)
			
			tempstr="Disciplinary Notice"
			temp = Y + 42 + API.DrawTextAligned(BG,tempstr, X+Width*0.5, Y+32, 0, Typeface.DEFAULT,Min(API.GetTextHeight(BG, -Width*0.9, tempstr, Typeface.DEFAULT), LCAR.Fontsize*2), Color,8, 0,0)
			temp2 = Width* 0.88
			
			X= X+Width*0.5-temp2*0.5
			Width = temp2
			
			BG.DrawLine(X, temp, X+Width, temp, Color, 3)
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 504,0,76,17,      X,temp+20, 152,    34, Alpha, False,False)
			API.DrawTextAligned(BG, "008049.04804.0847", X+Width*0.5, temp+20, 0, Typeface.DEFAULT, LCAR.Fontsize*0.25, Color, -8, 0,0)
			API.DrawTextAligned(BG, "RC.FT.100000013", X+Width, temp+20, 0, Typeface.DEFAULT, LCAR.Fontsize*0.25, Color, -3, 0,0)
			
			tempstr="People's Charter, Article 48230, Paragraph 3"
			temp3 = API.GetTextHeight(BG, -Width, tempstr, Typeface.DEFAULT)
			Stage=temp+52+API.DrawTextAligned(BG, tempstr, X, temp+50, 0, Typeface.DEFAULT, temp3, Color, -1, 0,0)
			Stage=Stage+API.DrawTextAligned(BG, SideText,X, Stage, 0, Typeface.DEFAULT, temp3, Color, -1, -2,0)
			API.DrawTextAligned(BG, Text,X, Stage, 0, Typeface.DEFAULT, temp3, Colors.aRGB(Alpha, 242,54,49), -1, -2,0)
			
			'               008049.04804.0847
			'504,0,76,17 'barcode            RC.FT.100000013
			'People's Charter, Article 48230, Paragraph 3
			'Text (left side of :) (sidetext)
			'Text (right side of :)
			'_______________________________________________
			'Penalty                80               Years
			'_______________________________________________
			
			temp=temp2*0.35417
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 0,0, 384, 136,            X+Width*0.5-temp2*0.5, Y+Height-24-temp, temp2,temp, Alpha, False,False)
			temp = Y+Height-24-temp - LCAR.ItemHeight*0.5 
			tempstr = "By order of the Committee for the Greater Good."
			temp2=API.DrawTextAligned(BG, tempstr, X+Width*0.5 + temp2*0.5, temp, 0, Typeface.DEFAULT, API.GetTextHeight(BG, -temp2, tempstr, Typeface.DEFAULT), Color, -6, 0,0)*0.5
			BG.DrawLine(X, temp-temp2, X+Width, temp-temp2, Color, 3)
			Stage=temp-temp2- (LCAR.TextHeight(BG,"80")*2)-30
			BG.DrawLine(X, Stage, X+Width, Stage, Color, 3)
			
			Stage = Colors.ARGB(Alpha, 255,255,255)
			API.DrawTextAligned(BG, "Penalty", X+20, temp-temp2-10, 0, Typeface.DEFAULT, LCAR.Fontsize, Stage, -7, 0,0)
			API.DrawTextAligned(BG, "80", X+Width*0.5, temp-temp2-10, 0, Typeface.DEFAULT, LCAR.Fontsize*2, Stage, -8, 0,0)
			API.DrawTextAligned(BG, "Years", X+Width-40, temp-temp2-10, 0, Typeface.DEFAULT, LCAR.Fontsize, Stage, -9, 0,0)
		
		Case LCAR.KnightRider'Dim KR_LastUpdate As Long, KR_Index As Int, KR_Delay As Int = 100, KR_LUnits As Int = 8, KR_Direction'Knight Rider
			If DateTime.Now - KR_LastUpdate >= KR_Delay Then 
				If KR_Direction Then KR_Index = KR_Index - 1 Else KR_Index = KR_Index + 1
				If KR_Index = KR_LUnits-1 Or KR_Index = 0 Then KR_Direction = Not(KR_Direction)
				KR_LastUpdate = DateTime.Now
			End If
			Width = LCAR.ScaleWidth*0.60'Min(250 * LCAR.GetScalemode , 
			X=LCAR.ScaleWidth*0.5-Width*0.5
			Height = Width * 0.05
			temp2 = Width / KR_LUnits
			For temp = 0 To KR_LUnits - 1 
				'Stage = ' Alpha * API.IIF(temp=KR_Index, 1, 0.5)
				LCAR.DrawRect(BG, X,Y,temp2,Height, Colors.ARGB(Alpha * GetKITTAlpha(temp), 234,31,25), 0)
				X=X+temp2
			Next
		
		Case LCAR.DrP_Board 
			Color=		LCAR.GetColor(LCAR.LCAR_Orange, False,Alpha)
			temp = 		LCAR.Fontsize*4
			temp2 = 	BG.MeasureStringHeight(Text, LCAR.LCARfont, temp)
			Width = 	BG.MeasureStringWidth(Text, LCAR.LCARfont, temp)
			Height = 	Alpha/255 * temp2 
			Y= 			ScaleHeight*0.5
			Stage = 	LCAR.ItemHeight
			
			LCARSeffects2.DrawBracketS(BG, ScaleWidth*0.5-Width*0.5 - Stage, Y- Height*0.5, Stage, Height, True)
			LCARSeffects2.DrawBracketS(BG, ScaleWidth*0.5+Width*0.5, Y- Height*0.5, Stage, Height, False)
			'LCARSeffects4.DrawRect(BG,0, Y- Height*0.5-Stage,ScaleWidth,Height+Stage, Color,Stage)
			LCARSeffects.MakeClipPath(BG, 0, Y- Height*0.5, ScaleWidth, Height)
			BG.DrawText(Text, ScaleWidth*0.5, Y+temp2*0.5, LCAR.LCARfont, temp, Color, "CENTER")
			BG.RemoveClip
		
		Case LCAR.tCARS
			If Text.Length = 0 Then
				DrawStyledVolume(BG, LCAR.tCARS, Volume, x,y,Width,Height,Alpha)
			Else 
				Color = LCAR.TCAR_DarkTurquoise
				If SideText.Length> 0 Then Text = SideText & ":" & Text 
				DrawBubbleText(BG,LCAR.ScaleWidth*0.5,y,0,0, Color, False, Alpha, Text, Wireframe.TCARSfont, LCAR.Fontsize)
			End If 
		
		Case LCAR.BORG
			If Text.Length = 0 Then
				DrawStyledVolume(BG, LCAR.BORG, Volume, x,y,Width,Height,Alpha)
			Else 
				Color = LCAR.GetColor(LCAR.BORG_Color, False, Alpha)
				If SideText.Length> 0 Then Text = SideText & ":" & Text 
				API.DrawText(BG, Text, X,Y,LCAR.BorgFont, LCAR.Fontsize, Color, 0)
			End If
	End Select
	'Return Trig.SetPoint(Width,Height)
	'(BG As Canvas, Style As Int, Volume As Int, Text As String, Alpha As Int, Width As Int, Height As Int,ScaleWidth As Int, ScaleHeight As Int)
	'Dim SideText As String,X As Int, Y As Int,Color As Int,temp As Int,temp2 As Int ,P As Path , temp3 As Float , Stage As Int, tempstr As String '0=fading in, 1=waiting, 2=fading out
End Sub
Sub DrawBubbleText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Opacity As Int, Text As String, Font As Typeface, FontSize As Int) As Point 
	Dim Black As Int = Colors.ARGB(Opacity,0,0,0), WhiteSpace As Int=2, tempstr() As String = Regex.Split(CRLF, Text), LineHeight As Int = BG.MeasureStringHeight(Text, Font, FontSize), temp As Int
	If Width = 0 Or Height = 0 Then 
		For temp = 0 To tempstr.Length -1
			Width = Max(Width, BG.MeasureStringWidth(tempstr(temp), Font, FontSize))
		Next
		Width = Width + 20
		Height = (tempstr.Length+1) * LineHeight + 20
		X=X-Width*0.5
		Y=Y-Height*0.5
	End If
	LCARSeffects2.DrawLegacyButton(BG, X-WhiteSpace,Y-WhiteSpace,Width+WhiteSpace*2,Height+WhiteSpace*2, Black, "", 1, 0)
	LCARSeffects2.DrawLegacyButton(BG, X,Y,Width,Height, LCAR.GetColor(ColorID,State, Opacity), "", 1, 0)
	For temp = 0 To tempstr.Length-1 
		Y=Y+LineHeight
		BG.DrawText(tempstr(temp), X +10, Y+10, Font, FontSize, Black, "LEFT")
	Next
	Return Trig.SetPoint(Width,Height)
End Sub
Sub GetKITTAlpha(Index As Int) As Float 
	Dim Minimum As Float = 0.25, Maximum As Float = 1, Increment As Float = 0.10
	If KR_Index = Index Then Return Maximum
	If KR_Direction Then ' 7 to 0
		If Index < KR_Index Then Return Minimum
		Index = (KR_LUnits - 1) - Index
	Else If Index > KR_Index Then 
		Return Minimum
	End If
	Return Min(Minimum + (Index+1) * Increment, Maximum)
End Sub
Sub DrawStyledVolume(BG As Canvas, Style As Int, Volume As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int)
	Dim temp As Int ,temp2 As Int,temp3 As Int,temp4 As Int,temp5 As Int, Color1 As Int,Color2 As Int ,P As Path' ,Dest As Rect 
	Select Case Style
		Case LCAR.LCAR_ENT
			Color1=Colors.ARGB(Alpha,0,0,0)
			LCAR.DrawRect(BG,X-1,Y,Width+3,Height+2, Color1, 0)
			LCAR.DrawRect(BG,X,Y,Width+1,Height+1, 	Colors.ARGB(Alpha,115,148,191), 0)
			
			For temp = 5 To 95 Step 5
				temp2=X+Width*(temp*0.01)
				If temp Mod 25 = 0 Then
					BG.DrawLine(temp2,Y,temp2,Y+Height, Color1,1)
				Else
					BG.DrawLine(temp2,Y+Height*0.5,temp2,Y+Height,Color1,1)
				End If
			Next
			
			temp=Height*0.75
			temp2=X+Width*(Volume*0.01)
			temp2=Min(Max(X+temp/2, temp2), X+Width-temp)
			LCARSeffects.DrawTriangle(BG, temp2, Y, temp/2, temp, 4, Colors.ARGB(Alpha,255,255,255))
		Case LCAR.LCAR_TOS
			temp=Height*0.5
			temp2=X+Width*(Volume*0.01)
			
			If Volume>0 Then
				If Volume<100 Then
					P.Initialize(temp2-temp,Y)
					P.LineTo(X,Y)
					P.LineTo(X,Y+Height)
					P.LineTo(temp2+temp,Y+Height)
					BG.ClipPath(P)
				End If
				Color1=LCAR.GetColor(LCAR.LCAR_Yellow, False,Alpha)
				LCARSeffects2.DrawLegacyButton(BG,X,Y,Width,Height,Color1,"",0, 0)
				If Volume>0 Then BG.RemoveClip
			End If
			
			If Volume<100 Then
				If Volume>0 Then
					P.Initialize(temp2-temp,Y)
					P.LineTo(X+Width,Y)
					P.LineTo(X+Width,Y+Height)
					P.LineTo(temp2+temp,Y+Height)
					BG.ClipPath(P)
				End If
				Color1=LCAR.GetColor(API.IIF(LCAR.RedAlert, LCAR.LCAR_RedAlert,LCAR.Classic_Green), LCAR.RedAlert,Alpha)
				LCARSeffects2.DrawLegacyButton(BG,X,Y,Width,Height,Color1,"",0, 0)
				If Volume<100 Then BG.RemoveClip 
			End If
			
			For temp = 20 To 80 Step 20
				temp2=X+Width*(temp*0.01)
				BG.DrawLine(temp2,Y,temp2,Y+Height, Colors.ARGB(Alpha,0,0,0),1)
			Next
		
		Case LCAR.LCAR_TMP
			Color1 = LCAR.GetColor(API.iif(LCAR.RedAlert,LCAR.LCAR_RedAlert, LCAR.Classic_Blue), False,Alpha)'color1 (blue/red)
			Color2 = LCAR.GetColor(API.iif(LCAR.RedAlert,LCAR.LCAR_RedAlert, LCAR.Classic_Green), LCAR.RedAlert,Alpha)'color2 (green/white)
			
			temp=Y+Height*0.5
			BG.DrawLine(X,Y,X,temp, Color1,2)
			BG.DrawLine(X,temp,X+Width,temp, Color1,2)
			BG.DrawLine(X+Width*0.375,temp,X+Width*0.625,temp, Color2,2)
			BG.DrawLine(X+Width,Y,X+Width,temp, Color1,2)
			
			temp2=Colors.ARGB(Alpha,255,255,255)
			BG.DrawCircle(X+Width*0.2,temp+5, 3, temp2, True,0)
			BG.DrawCircle(X+Width*0.8,temp+5, 3, temp2, True,0)
			
			BG.DrawLine(X+Width*0.25,temp+3,X+Width*0.75,temp+3, Color1,3)
			BG.DrawLine(X+Width*0.375,temp+3,X+Width*0.625,temp+3, Color2,3)
			
			temp3=Height*0.5-4
			temp2=Min(X+Width*(Volume*0.01), X+Width-temp3)
			LCARSeffects.DrawTriangle(BG, temp2, temp+6, temp3, temp3, 1, LCAR.GetColor(LCAR.LCAR_Yellow,False,Alpha))
			
			For temp2=5 To 95 Step 5
				temp3=X+Width*(temp2*0.01)
				temp4=Y+ Height * API.IIF( temp Mod 25 = 0 , 0.15,0.30)
				BG.DrawLine(temp3,temp4,temp3,temp, API.IIF(temp2>=37.5 And temp2<=62.5,Color2, Color1),2)
			Next
		
		Case LCAR.Klingon 
			Color1 = Colors.argb(Alpha, 255,0,0)
			temp2=Height*0.75
			temp=Width*(Volume*0.01)', Width-temp2) Min(
			'Log(Volume & " " & temp & "/" & Width & " (" & X & "," & Y & ") " & Height & " - " & Alpha)
			LCAR.DrawRect(BG,X,Y,temp, Height,Color1,0)
			temp=Y+Height-2
			BG.DrawLine(X,temp,X+Width-2,temp,Color1,2)
			
			LCARSeffects2.DrawKlingonTriangle(BG, X+Width,Y,temp2,Height, Color1, 0,0)
			'LCARSeffects.DrawTriangle(BG, X+Width-temp2,Y,temp2,Height,1,Color1)
		
		Case LCAR.StarWars 
			Color1=Colors.ARGB(Alpha, 176,206,206)
			'DrawTines(BG,X,Y,Width,Height, 0,Color1, Array As Float(0,0.245,0.445,0.575,0.69,0.80,0.86,0.90,0.93,0.95, 0.97,0.985,1))
			
			temp = Height*0.1
			BG.DrawLine(X,Y+temp,X+Width,Y+temp,Color1,2)
			DrawTines(BG,X,Y,Width,Height, temp,Color1, Array As Float(0.13,0.36,0.53,0.62,0.76,0.84,0.88,0.92,0.94,0.96,0.98,0.99))
			
			temp = Height*0.9
			BG.DrawLine(X,Y+temp,X+Width,Y+temp,Color1,2)
			
			Color1=Colors.ARGB(Alpha,0,98,202)
			Color2=Colors.ARGB(Alpha,0,168,253)
			temp=Height*0.35'height of bar
			temp2=Y+Height*0.5-temp*0.5'Y of bar
			temp4=Width*0.5'width of bar
			
			LCAR.DrawGradient(BG,Color1,Color2,6, X,temp2, Width*0.5, temp, 0,0)
			If Volume<50 Then
				temp3 = (50-Volume)*0.01 * Width
				LCAR.DrawRect(BG,X+temp4-temp3, temp2, temp3, temp, Colors.ARGB(Alpha*0.5,0,0,0),0)
			End If
			
			temp=Height*0.45'height of bar
			temp2=Y+(Height*0.5)-(temp*0.5)'Y of bar
			Color1=Colors.argb(Alpha,254,0,0)
			Color2=Colors.ARGB(Alpha,255,255,255)
			
			temp3=Height*0.07'height of white bars
			LCAR.DrawRect(BG,X+temp4, temp2-temp3-1, temp4, temp+temp3*2+1, Colors.black,0)
			
			LCAR.DrawRect(BG,X+temp4+1,temp2-temp3,temp4,temp3,Color2,0)
			LCAR.DrawRect(BG,X+temp4+1,temp2+temp,temp4,temp3,Color2,0)
			
			Color2=Colors.ARGB(Alpha,0,0,0)
			temp5=Height*0.16
			DrawTine(BG,X,Y,Width,Height, 0.56,temp5,Color2)
			DrawTine(BG,X,Y,Width,Height, 0.59,temp5,Color2)
			DrawTine(BG,X,Y,Width,Height, 0.68,temp5,Color2)
			DrawTine(BG,X,Y,Width,Height, 0.73,temp5,Color2)
			
			LCAR.DrawRect(BG,X+temp4+1,temp2,temp4,temp,Color1,0)
			
			If Volume<100 Then
				If Volume<50 Then 
					temp5=temp4
				Else
					temp5 = (100-Volume)*0.01 * Width 
				End If
				LCAR.DrawRect(BG,X+Width-temp5, temp2-temp3, temp5, temp+temp3*2, Colors.ARGB(Alpha*0.5,0,0,0),0)
			End If
			
			temp=X+ Width*0.01
			temp2=Y+Height*0.13
			LCARSeffects2.DrawBitmap(BG,LCARSeffects2.CenterPlatform, 0,21,  temp, temp2,     74,8,    False,False)
			If Alpha<255 Then LCAR.DrawRect(BG,temp,temp2, 75,9, Colors.ARGB(255-Alpha,0,0,0),0)
			'LCARSeffects2.DrawBMP(BG,LCARSeffects2.CenterPlatform,  0,21,74,8,   X+ Width*0.01, Y+Height*0.13, 74,8, Alpha,False,False)			
		Case LCAR.tCARS
			X=LCAR.ScaleWidth*0.25
			Height = LCAR.ItemHeight
			temp = LCAR.TCAR_LightTurquoise
			temp2 = LCAR.TCAR_Orange
			temp3 = LCAR.TCAR_DarkTurquoise
			Wireframe.DrawInsigniaMeter(BG, X, Y, Array As Int(51, 41, 43, 50+Volume, 38, -Volume), Height, Array As Int(temp,temp3,temp,temp3,temp,temp, temp2), False, Alpha, 0.2) 
			
		Case LCAR.BORG
			X=LCAR.Scalewidth*0.5 
			temp = Min(Width,Height)' * 0.5 
			temp2 = LCAR.GetColor(LCAR.BORG_Color, False, Alpha)
			BG.DrawCircle(X,Y, temp + 14, Colors.ARGB(Alpha, 0,0,0), True, 0)
			BG.DrawCircle(X,Y, temp + 12, temp2, False, 5)
			Wireframe.CircleGradient(BG, X,Y, temp * Volume * 0.01, temp2, Colors.Black)
	End Select
End Sub

Sub DrawTines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Yp As Float, Color As Int, Xps As List)
	Dim temp As Int,temp2 As Float ,temp3 As Float
	DrawTine(BG,X,Y,Width,Height, 0,0,Color)
	For temp = 0 To Xps.Size-1
		temp2=Xps.Get(temp)'new
		DrawTine(BG,X,Y,Width,Height,temp2,Yp,Color)
		If temp>0 Then
			DrawTine(BG,X,Y,Width, Height,(temp2-temp3)/2+temp3,0,Color)'(old-new)/2 + old
		End If
		temp3=temp2'old
	Next
	DrawTine(BG,X,Y,Width,Height, 1,0,Color)
End Sub
Sub DrawTine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xp As Float, Yp As Int,Color As Int)
	'Dim temp As Int = height*yp
	X=X+Width*Xp - API.IIF(Y=0,1,0)
	BG.DrawLine(X, Y+Yp, X,Y+Height-Yp, Color, API.IIF(Yp=0,2,1) )
End Sub





Sub ResetStarWars(ElementID As Int)
	Dim Element As LCARelement 
	Element = LCAR.GetElement(ElementID)
	Element.Lwidth=999
	Element.RWidth=Element.Lwidth
	LCAR.ForceShow(ElementID, True)
End Sub
Sub DrawStarWars(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, Range As Int,TotalRange As Int,toggle As Boolean)
	Dim Yellow As Int = Colors.RGB(206, 211, 30), Red As Int = Colors.RGB( 255,55,40),Height2 As Int ,temp2 As Float ,Width2 As Int,Height3 As Int 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "nixie.png", LCAR.SWARS_Targeting)
	LCAR.DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
	If TotalRange>0 Then  temp2=Range/TotalRange Else  temp2 = -1
	If Width>Height Then 'landscape
		Height2=Height*0.8
		DrawTarget(BG,X,Y,Width,Height2,Stage,Yellow,12,Red,temp2,toggle)
	Else'portrait
		Height2= LCAR.ScaleWidth * (LCAR.ScaleWidth /LCAR.ScaleHeight)'height of the main display
		DrawTarget(BG,X,Y,Width,Height2,Stage,Yellow,12,Red,temp2,toggle)'712 427	-	429,75 		-   25
	End If
	Height3=Height2*0.1756
	Width2=Width*0.6
	DrawRange(BG, X+Width/2-Width2/2, Y+Height2+(Height3/3),  Width2, Height3+24,   temp2, Yellow, 12)
End Sub
Sub DrawRange(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Percent As Float,Color As Int,Stroke As Int)
	Dim Range As String ,Size As Int'403403 0.4034034013748169
	'Range = Percent * 999999
	Range=Percent
	'Range =  API.Mid(Range,8,6)
	Range = API.mid(Range,2,3) & API.Mid(Range,11,3)
	Do Until Range.Length= 6
		Range = "0" & Range
	Loop
	Size= Min(Height-Stroke*2, (Width-Stroke*2) / Range.Length)*0.8
	'Size=(Height-Stroke*2)*0.8
	LCARSeffects2.DrawPreCARSFrame(BG,X,Y,Width+1,Height+1,Color,0,2, 35,Stroke, "",0, "")
	DrawRangeText(BG, X+(Width*0.5)-(Size*3)   ,Y+Height*0.5-Size*0.5,    Size, Range)'+Stroke+Height*0.2
End Sub
Sub DrawRangeText(BG As Canvas, X As Int, Y As Int, Size As Int, Value As String)
	Dim temp As Int , temp2 As Int 
	For temp = 0 To Value.Length-1
		temp2 = API.Mid(Value, temp,1)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCAR.SetRect(21*temp2,0,22,22), LCAR.SetRect(X,Y,Size+1,Size+1))
		X=X+Size
	Next
End Sub
Sub DrawTarget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int,Color As Int,Stroke As Int,LineColor As Int, Range As Float, toggle As Boolean )
	Dim Offset As Int = Stroke * 0.5 , O2 As Int = Stroke * 0.25, temp As Int,temp2 As Float, cX As Int=X+Width*0.5, cY As Int=Y+Height*0.5,DistanceInc As Int ,Distance As Int
	Dim MaxDistance = Max(Width,Height), X2 As Int=X+ Width*0.25 + Offset,X3 As Int=X+ Width*0.75-Offset,Y2 As Int=Y+Height-Offset, tempP As Point ,Y3 As Int,DoWall As Float 
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	
	'top
	temp=Y+Offset
	BG.DrawLine(X+ Width*0.087 + Offset, temp, cX,cY, Color, Stroke)
	BG.DrawLine(X2, temp, cX,cY, Color, Stroke)'TLoM
	BG.DrawLine(X3, temp, cX,cY, Color, Stroke)'TRoM
	BG.DrawLine(X+ Width*0.913-Offset, temp, cX,cY, Color, Stroke)
	
	'bottom
	temp=Y2'Y+Height-Offset
	BG.DrawLine(X+ Width*0.087 + Offset,temp, cX,cY, Color, Stroke)
	BG.DrawLine(X2, temp, cX,cY, Color, Stroke)
	BG.DrawLine(X3, temp, cX,cY, Color, Stroke)
	BG.DrawLine(X+ Width*0.913-Offset, temp, cX,cY, Color, Stroke)
	
	'left
	temp=X+Offset
	BG.DrawLine(temp, Y+Height*0.3, cX,cY, Color, Stroke)
	BG.DrawLine(temp, Y+Height*0.7, cX,cY, Color, Stroke)
	
	'right
	temp=X+Width-Offset
	BG.DrawLine(temp, Y+Height*0.3, cX,cY, Color, Stroke)
	BG.DrawLine(temp, Y+Height*0.7, cX,cY, Color, Stroke)
	
	'moving lines
	DistanceInc=5+Stage'MaxDistance/PointsOnScreen+FirstDistance
	temp=Height*0.18
	temp2 = temp/(Width*0.1-Stroke)  'Height/Width*0.875
	For temp=1 To 10 
		Distance=Distance + DistanceInc*4
		
		tempP= Trig.LineLineIntercept(X2,Y2,cX,cY, 		X,cY- Distance*temp2, X+Width, cY- Distance*temp2)
		
		X3=cX + (cX-tempP.X) 
		Y3=cY + (cY-tempP.Y)
		BG.DrawLine(tempP.X,tempP.Y,     tempP.X,    Y3,   Color, Offset)
		BG.DrawLine(X3,Y3,tempP.X, Y3, Color, Offset)
		BG.DrawLine(X3,tempP.Y,X3, Y3, Color, Offset)
		
		DistanceInc=DistanceInc+1
		If DistanceInc>MaxDistance Then Exit
	Next
	
	'cX=X+Width*0.45	
	If Range<0.1 Then  'center black
		DoWall = 10*(0.1-Range)
		Y2=cX'center x
		X3=Width*DoWall'width of wall
		cX=cX-Width*DoWall*0.5'left of wall
		
		temp=X3*1.15' Height						*DoWall'0.18
		cY=Y+Height*0.5-temp*0.5'top of wall        0.41
		
		LCAR.DrawRect(BG, cX, cY, X3, temp, Colors.Black,0)
	End If
	
	If Range>0 Then
		'red lines
		Distance=X+(Width*0.5)
		If Range>-1 Then
			temp2=Width*Range*0.5
			DrawLine(BG,Distance-temp2,Y,Height,Stroke,Offset,LineColor)
			DrawLine(BG,Distance+temp2,Y,Height,Stroke,Offset,LineColor)
		End If
	End If
	
	If DoWall>0 Then 'center 
		If Range>0 Then
			'Case 0',2
				LCAR.DrawRect(BG, cX, cY, X3, temp,Color, Offset)'37 41 of 74 88
				BG.DrawLine(Y2, cY+O2, Y2,cY+temp-O2, Color, Offset)'|
				BG.DrawLine(cX+O2, cY+temp*0.45-O2, cX+X3-O2, cY+temp*0.45-O2, Color,Offset)'-
				
				'If NegStage=0 Then
					cX=X+Width*0.5
					cY=cY+temp*0.45
					BG.DrawCircle(cX,cY, X3 * 0.4, Color,False,O2)
				'End If
		Else	
			BG.RemoveClip 
			cX=X+Width*0.5
			cY=cY+temp*0.45
			SWF=SWF+1
			If SWF=5 Then
				SWtoggle=Not(SWtoggle)
				SWF=0
			End If
			If SWtoggle Then
				BG.DrawLine(cX,Y, cX,Y+Height,Color,Offset)
				BG.DrawLine(X,cY, X+Width,cY,Color,Offset)
			Else
				DrawChevron(BG,     cX,   cY,   45,      15,          20,          Width*0.2,  Width*0.15,   LineColor)  
				DrawChevron(BG,     cX,   cY,  135,      15,          20,          Width*0.2,  Width*0.15,   LineColor)
				DrawChevron(BG,     cX,   cY,  225,      15,          20,          Width*0.2,  Width*0.15,   LineColor)
				DrawChevron(BG,     cX,   cY,  315,      15,          20,          Width*0.2,  Width*0.15,   LineColor)
			End If
		End If
		
	End If	
	BG.RemoveClip 
	
	temp=35
	cX=X+Width-temp+1
	cY=Y+Height-temp+1
	DrawTriangle(BG,X,Y,temp,Offset,2)
	DrawTriangle(BG,cX,Y,temp,Offset,3)
	DrawTriangle(BG,X,cY,temp,Offset,1)
	DrawTriangle(BG,cX,cY,temp,Offset,0)
	
	LCARSeffects2.DrawPreCARSFrame(BG,X,Y,Width+1,Height+1,Color,0,5, temp,Stroke, "",0,"")
End Sub
Sub DrawLine(BG As Canvas, X As Int, Y As Int, Height As Int, Stroke As Int,Offset As Int, Color As Int)
	Dim temp As Int
	For temp = Y To Y+Height Step Stroke+1
		BG.DrawLine(X-Offset,temp-Offset, X+Offset,temp+Offset, Color,Stroke)
	Next
End Sub
Sub DrawTriangle(BG As Canvas, X As Int, Y As Int, Size As Int,Offset As Int,Skip As Int)
	Dim P As Path 
	If Skip <> 0 Then MakePoint(P, X,Y)
	If Skip <> 1 Then MakePoint(P, X+Size,Y)
	If Skip <> 2 Then MakePoint(P, X+Size,Y+Size)
	If Skip <> 3 Then MakePoint(P, X,Y+Size)
	
	'P.Initialize(X,Y)
	'P.LineTo(X+35-Offset,Y)
	'P.LineTo(X,Y+35-Offset)
	BG.ClipPath(P)
	LCAR.DrawRect(BG,X,Y,Size,Size,Colors.black,0)
	BG.RemoveClip 
End Sub
Sub MakePoint(P As Path, X As Int, Y As Int) As Point 
	If P.IsInitialized Then 
		P.LineTo(X,Y)
	Else
		P.Initialize(X,Y)
	End If
	Return Trig.SetPoint(X,Y)
End Sub
Sub MakePoint3(P As Path, XY As Point) As Point 
	Return MakePoint(P,XY.X,XY.Y)
End Sub

Sub DrawChevron(BG As Canvas, X As Int, Y As Int, Angle As Int,AngleWidth As Int, RadiusStart As Int, RadiusEnd As Int, RadiusMiddle As Int, Color As Int)
	Dim P As Path
	MakePoint3(P, Trig.FindAnglePoint(X,Y,  RadiusStart,Angle))'starting point/tip
	MakePoint3(P, Trig.FindAnglePoint(X,Y,  RadiusEnd,Angle+AngleWidth))'right
	MakePoint3(P, Trig.FindAnglePoint(X,Y,  RadiusMiddle,Angle))'middle/indent
	MakePoint3(P, Trig.FindAnglePoint(X,Y,  RadiusEnd,Angle-AngleWidth))'left
	MakePoint3(P, Trig.FindAnglePoint(X,Y,  RadiusStart,Angle))'starting point/tip
	BG.DrawPath(P, Color, True, 0)
End Sub








'metaphasic shields
Sub ToggleEnterprise(ElementID As Int)
	HideEnterprise = Not(HideEnterprise)
	LCAR.ForceShow(ElementID,True)
End Sub
Sub SOHODIR(Index As Int) As String
	If Index=-1 Then
		Return File.Combine(LCAR.DirDefaultExternal, "soho")
	Else
		Return API.IIFIndex(Index, Array As String("eit_171", "eit_195", "eit_284", "eit_304", "hmi_igr", "hmi_mag", "c2", "c3"))
	End If
End Sub
Sub HandleJobDone(URL As String, ElementID As Int)
	If File.Exists(SOHODIR(-1), CurrentURL) Then File.Delete(SOHODIR(-1), CurrentURL)
	If Not(File.Exists(LCAR.DirDefaultExternal, "soho")) Then File.MakeDir(LCAR.DirDefaultExternal, "soho")
    API.CurrentJob.SaveFile(SOHODIR(-1), CurrentURL)
	LoadMetaphasicImage(URLIndex, ElementID)	
	URLIndex=-1
End Sub
Sub SetupRandomNumbers
	Dim ARR() As Int' = api.IIF(lcar.SmallScreen, Array As Int(2,-1), Array As Int(2,-1,3,-1,3,-1,1,-1,3,-1))
	If LCAR.SmallScreen Then
		ARR=Array As Int(2,-1)
	Else
		ARR=Array As Int(2,-1,3,-1,3,-1,1,-1,3,-1)
	End If
	LCARSeffects2.AddRowOfNumbers(1, LCAR.LCAR_Purple, ARR)
	LCARSeffects2.AddRowOfNumbers(2, LCAR.LCAR_Purple, ARR)
End Sub
Sub LoadMetaphasicImage(Index As Int, ElementID As Int)
	Dim Element As LCARelement,NeedsDownloading As Boolean    ' JPGHighQuality  SOHOAnimated 
	If Index=-1 Then'enter screen
		SetupRandomNumbers
		LoadMetaphasicImage(0,ElementID)
	Else
		Element = LCAR.GetElement(ElementID)
		Element.Align=-1
		Element.LWidth=0
		Element.RWidth=0
		Element.TextAlign=0'0=not found, 1=animated (gif), 2=not animated (jpg)
		Element.Text = SOHODIR(Index)
		JPGHighQuality= Min(LCAR.ScaleWidth,LCAR.ScaleHeight) >=720
		'check if file exists
		If SOHOAnimated And File.Exists(SOHODIR(-1),Element.Text & ".gif") Then 
			Element.Text = Element.Text & ".gif"
			Element.TextAlign=1'animated
		Else If File.Exists(SOHODIR(-1),Element.Text & ".jpg") Then
			Element.Text = Element.Text & ".jpg"
			Element.TextAlign=2'not animated
		End If
		If Element.TextAlign=0 Then'file does not exist
			If API.IsConnected Then 
				Element.SideText = API.GetStringVars("soho_attempting", Array As String(Element.Text.ToUpperCase.Replace("_"," ")))' "ATTEMPTING TO ACCESS " & Element.Text.ToUpperCase.Replace("_"," ")
				NeedsDownloading=True
			Else
				Element.SideText = API.GetStringVars("soho_offline", Array As String(Element.Text.ToUpperCase.Replace("_"," ")))' "UNABLE TO ACCESS " & Element.Text.ToUpperCase.Replace("_"," ") & CRLF & "SENSORS ARE OFFLINE"
			End If
		Else'file does exist
			Element.Align=Index
			NeedsDownloading = ((DateTime.Now - File.LastModified(SOHODIR(-1), Element.Text)) / DateTime.TicksPerDay) >= 7 'check if it's older than 1 week
		End If
		If NeedsDownloading Then  API.Download("soho", GetURL(Index, API.IIF(SOHOAnimated, False, JPGHighQuality), SOHOAnimated))
		LCAR.ForceShow(ElementID, True)
	End If
End Sub
Sub GetURL(Index As Int, HighQuality As Boolean, Animated As Boolean) As String 
	Dim tempstr As String, BaseHREF As String="http://sohowww.nascom.nasa.gov/data/"
	'EIT 171, EIT 195, EIT 284, EIT 304, SDO/HMI Continuum N/A, SDO/HMI Magnetogram N/A, LASCO C2, LASCO C3
	tempstr = SOHODIR(Index)' API.IIFIndex(Index, Array As String("eit_171", "eit_195", "eit_284", "eit_304", "hmi_igr", "hmi_mag", "c2", "c3"))
	If Index = 4 Or Index =5 Then Animated=False
	URLIndex=Index
	If Animated Then
		CurrentURL = tempstr & ".gif"
		Return BaseHREF & "LATEST/current_" & tempstr & API.IIF(HighQuality, ".gif", "small.gif")
	Else
		CurrentURL = tempstr & ".jpg"
		Return BaseHREF & "realtime/" & tempstr & API.IIF(HighQuality, "/1024", "/512") & "/latest.jpg"
	End If
End Sub
Sub DrawBubbles(BG As Canvas, SmallStage As Int, BigStage As Int, Increment As Int, X As Int, Y As Int, Width As Int, R As Int, G As Int, B As Int)
	Dim Height As Int = 137 * (Width/100),temp As Int = Height * 0.6,Radius As Int,Color As Int'X = (Dest.Right-Dest.Left) * 0.35
	X=X-Width*0.15
	Y=Y-Height*0.5
	'48,24 of 137,100. So X = 35% of width Y = 24% and 76% of height			MaxStages
	If BigStage = 0 Then'expand bubbles
		Radius = temp * (SmallStage/MaxStages)
	Else'contract bubbles
		Radius = temp * (1-(SmallStage/MaxStages))
	End If
	Color=Colors.ARGB(16,R,G,B)
	For temp = Increment To Radius Step Increment
		BG.DrawCircle(X,Y + Height*0.3,temp, Color, True,0)
		BG.DrawCircle(X,Y + Height*0.7,temp, Color, True,0)
	Next
End Sub
Sub DrawMetaphasicShields(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SmallStage As Int, BigStage As Int, SOHOIndex As Int, Animated As Int, Filename As String, Text As String,Alpha As Int)
	Dim Size As Point, Color As Int, w2 As Int=Width/2, h2 As Int=Height/2, temp As Int,temp2 As Int, Small As Int, tempstr As String, tempstr2 As String 
	If SOHOIndex=-1 Then
		LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False, Alpha, Text)
	Else
		'If LCARSeffects2.InitRandomNumbers(LCAR.LCAR_Metaphasic, False ) Then
			
		'End If
		LCARSeffects2.LoadUniversalBMP(SOHODIR(-1), Filename, LCAR.LCAR_Metaphasic)
		If LCARSeffects2.CenterPlatformID <> LCAR.LCAR_Metaphasic Then 
			LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False, Alpha, Text)
			Return 
		End If 
		LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
		LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
		Size = API.Thumbsize(LCARSeffects2.CenterPlatform.Width ,LCARSeffects2.CenterPlatform.Height, Width,Height, False,True)
		LCAR.DrawLCARPicture(BG, X+Width/2 - Size.X/2, Y+Height/2 - Size.Y/2, Size.X,Size.Y, -1,0, Alpha,True,   0,0,0,0)
		If Not(HideEnterprise) Then
			LCAR.ActivateAA(BG,True)
			Small=Min(w2,h2)
			
			Color=LCAR.GetColor(LCAR.LCAR_Purple,False, Alpha)
			BG.DrawLine(X+w2, Y, X+w2, Y+Height, Color,2)'top/down
			BG.DrawLine(X, Y+h2, X+Width, Y+h2, Color, 2)'left/right
			BG.DrawCircle(X+w2, Y+h2, Small*0.75, Color, False, 2)'circle
				
			If LCAR.Educational Then
				temp=10
				LCAR.DrawText(BG, X+temp, Y+temp,  API.TextWrap(BG, LCAR.LCARfont, LCAR.Fontsize, Text, Width-(temp*2)), LCAR.LCAR_Orange, 7, False, Alpha,0)
			Else
				'LCAR.DrawText(BG, X+Width,Y, "SUBSPACE COMPRESSION FACTOR 0" & BigStage & Rnd(10,100), LCAR.LCAR_Purple, 3,False, Alpha,0)
				LCAR.DrawText(BG, X+Width,Y, API.GetStringVars("soho_compression", Array As String(BigStage & Rnd(10,100))), LCAR.LCAR_Purple, 3,False, Alpha,0)
				tempstr = API.getstring("soho_axis")
				
				tempstr2 = tempstr.replace("[0]", "Z")
				LCAR.DrawTextbox(BG,tempstr2,  LCAR.LCAR_Purple, X+w2,Y+h2+4,w2,h2, 3)
				temp=LCAR.TextWidth(BG,tempstr2)
				BG.DrawLine(X+Width-temp, Y+h2+2, X+Width, Y+h2+2, Color, 2)
				
				tempstr2 = tempstr.replace("[0]", "X") & " "
				temp = LCAR.DrawTextbox(BG,tempstr2,  LCAR.LCAR_Purple, X,Y,w2,Height, 9)
				BG.DrawLine(X+w2-2, Y+Height-temp, X+w2-2, Y+Height, Color,2)'top/down
				
				If BigStage <3 Then
					LCAR.DrawTextbox(BG,API.GetStringVars("soho_distortion", Array As String((BigStage+1) & Rnd(1,10))),  LCAR.LCAR_Purple, X,Y,Width,Height, 9)'"FIELD DISTORTION = 45" & (BigStage+1) & Rnd(1,10) & " MILLICOCHRANES"
				Else
					tempstr = API.GetString("soho_engaged")
					temp2=LCAR.TextWidth(BG,tempstr) + 10
					LCAR.DrawRect(BG, X+Width-temp2, Y+Height-temp-2, temp2,temp+3, Colors.ARGB(Alpha,0,0,0), 0)
					LCAR.DrawTextbox(BG,tempstr,  LCAR.LCAR_Yellow, X,Y,Width,Height, 9)
				End If
				
				temp=LCAR.TextHeight(BG, "0123")
				temp2=h2-20-temp
				Color=w2-(Small*0.75)-40
				If LCARSeffects2.DrawRandomNumbers(BG, X+20,Y+10+temp*2, LCAR.LCARfont,LCAR.Fontsize,Color, temp2, 1)=0 Then SetupRandomNumbers
				LCARSeffects2.DrawRandomNumbers(BG, X+20,Y+h2+10+temp*2, LCAR.LCARfont,LCAR.Fontsize,Color, temp2, 2)
			End If
			
			Height= Min(150,Small*0.7)
			Width= 137 * (Height/100)
			temp=X+w2+Width*0.2
			temp2 = 0
			LCARSeffects.DrawEnterpriseD(BG,temp,Y+h2,Height,0, 0, 0)
			
			Color=LCAR.GetColor(LCAR.LCAR_Orange,False, Alpha)
			Select Case BigStage
				Case 0,1'expand bubbles then contract bubbles
					DrawBubbles(BG, SmallStage,BigStage, 8 ,temp,Y+h2, Height, 255,255,255)
				Case 2'expand gold circle
					temp2=Small * 0.8 * (SmallStage/MaxStages)
				Case 3'visible gold circle at full radius
					temp2=Small * 0.8
			End Select
			If temp2>0 Then 
				BG.DrawCircle(X+w2,Y+h2, temp2, Color, False,3)
				If LCAR.Educational Then
					temp = temp2*0.1
					Do Until temp2 <= 0 
						temp2=temp2-temp
						If temp2>0 Then BG.DrawCircle(X+w2,Y+h2, temp2, Color, False,3)
					Loop
				End If
			End If
			LCAR.ActivateAA(BG,False)
		End If
		BG.RemoveClip 
	End If
End Sub


























Sub GetGrey(Percent As Float, Alpha As Int) As Int
	If Percent>1 Then Percent=Percent*0.01
	Dim temp As Int = 255 * Percent
	Return Colors.aRGB(Alpha, temp,temp,temp)
End Sub

Sub MakeSlantedPath(BG As Canvas, X As Int, Y As Int, Width As Int, LeftHeight As Int, RightHeight As Int)As Path 
	Dim P As Path 
	P.Initialize(X,Y)
	P.LineTo(X, Y+LeftHeight)
	P.LineTo(X+Width,Y+RightHeight)
	P.LineTo(X+Width,Y)
	BG.ClipPath(P)
	Return P
End Sub

Sub DrawSlantedRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, StartFactor As Float )
	Dim DoSlant As Boolean = True
	If StartFactor<0 Then 
		DoSlant=False
		StartFactor=Abs(StartFactor)
	End If
	If DoSlant Then
		LCAR.DrawRect(BG,X,Y,Width, Height, GetGrey(StartFactor+ 0.30, Alpha), 0)'background
		MakeSlantedPath(BG,X,Y,Width, Height*0.33, Height *0.16)
		LCAR.DrawRect(BG,X,Y,Width, Height, GetGrey(StartFactor+ 0.40, Alpha), 0)'shine
		BG.RemoveClip 
	Else
		LCAR.DrawRect(BG,X,Y,Width, Height, Colors.ARGB(Alpha,255,255,255), 0)'background
		DrawDots(BG,X,Y,Width,Height, GetGrey(StartFactor+ 0.40, Alpha*0.5) , 2, Height*0.5)
	End If
	LCAR.DrawRect(BG,X,Y,Width, Height, GetGrey(0.20, Alpha), 2)'outline
End Sub

Sub DrawSwitched(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, ColorID As Int, Direction As Boolean, State As Boolean )
	Dim P As Path ,HalfHeight As Int = Height*0.5
	LCARSeffects2.MakePoint(P,X,Y)
	LCARSeffects2.MakePoint(P,X,Y+Height)
	If Direction Then
		LCARSeffects2.MakePoint(P,X+Width,Y+Height)
		LCARSeffects2.MakePoint(P,X+Width,Y)
		LCARSeffects2.MakePoint(P,X+Width-HalfHeight,Y-Height)
		LCARSeffects2.MakePoint(P,X+HalfHeight,Y-Height)
	Else
		LCARSeffects2.MakePoint(P,X+HalfHeight,Y+Height*2)
		LCARSeffects2.MakePoint(P,X+Width-HalfHeight,Y+Height*2)
		LCARSeffects2.MakePoint(P,X+Width,Y+Height)
		LCARSeffects2.MakePoint(P,X+Width,Y)
	End If
	LCARSeffects2.MakePoint(P,X,Y)
	BG.DrawPath(P, GetGrey(0.20, Alpha), False, 3)
	BG.DrawPath(P, LCAR.GetColor(ColorID, State,Alpha), True, 0)
	BG.clippath(P)
	'BG.DrawRect( LCARSeffects2.CopyPlistToPath(P, Pt, BG, GetGrey(0.20, Alpha), 3, True, True), LCAR.GetColor(ColorID, State,Alpha), True,0)
	'LCARSeffects2.CopyPlistToPath(P, Pt, BG, GetGrey(0.20, Alpha), 2, True, False)
	DrawDots(BG,X,Y- API.IIF(Direction, Height,0), Width,Height*2,  GetGrey(0.40, Alpha*0.5), 2,HalfHeight)
	BG.RemoveClip 
End Sub

Sub DrawDots(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Radius As Int, Spacing As Int)
	Dim tempx As Int, isOdd As Boolean , tempY As Int , OneQuarter As Int = Spacing*0.25
	For tempx=X+OneQuarter To X+Width Step Spacing
		For tempY =Y+OneQuarter+ API.IIF(isOdd, 0, Spacing/2) To Y+Height Step Spacing
			BG.DrawCircle(tempx+Radius,tempY+Radius, Radius, Color, True,0)
		Next
		isOdd=Not(isOdd)
	Next
End Sub



Sub DrawWOKSwitch(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int, Text As String, State As Boolean)
	Dim BottomHeight As Float = 0.20, Height2 As Int = Height * (1-BottomHeight), Width2 As Int = Height2* 0.65, Factor As Float = 0.8, Height3 As Int = Height2*Factor,Value As Boolean = (ColorID<> LCAR.LCAR_Black) 	
	DrawSlantedRect(BG, X+ Width/2- Width2/2, Y, Width2, Height2,Alpha,0)'outer box
	Width2=Width2*Factor
	DrawSlantedRect(BG, X+ Width/2- Width2/2, Y + Height2/2 - Height3/2,  Width2,Height3, Alpha,0.1)'inner box
	Width2=Width2*Factor
	Height3=Width2
	DrawSlantedRect(BG, X+ Width/2- Width2/2, Y + Height2/2 - Height3/2,  Width2,Height3, Alpha,0.1)'inner-inner box
	Width2=Width2*Factor
	Height3=Width2*0.5
	If Value Then
		DrawSwitched(BG, X+ Width/2- Width2/2, Y + Height2/2 - Height3/2,  Width2,Height3, Alpha, ColorID, ColorID= LCAR.Classic_Green, State)
	Else
		DrawSlantedRect(BG, X+ Width/2- Width2/2, Y + Height2/2 - Height3/2,  Width2,Height3, Alpha, -0.1)'inner-inner box
	End If
	LCAR.DrawRect(BG,X,Y+Height2,Width+1,Height-Height2, GetGrey(0.70,Alpha),0)
	API.DrawTextAligned(BG, Text, X+Width/2, Y+Height*(1-(BottomHeight*0.5)), 0, Typeface.DEFAULT_BOLD, API.GetTextHeight(BG,Height*BottomHeight*0.8, Text,Typeface.DEFAULT_BOLD), GetGrey(0.9,Alpha), -5, 0, 0)
End Sub

Sub FlashViewscreen
	DoFlash=True
	'Flash.Desired = 255
End Sub

Sub IncrementViewscreen(Finish As Boolean) As Boolean 
	Dim Ret As Boolean
	'If FullscreenMode Then
	'Log("Increment viewscreen")
		
		Ret = IncrementTween(Flash,16, Finish, "Flash")
		If Flash.Current = 255 And Flash.Desired = 255 Then Flash.Desired = 0 
		'If FullscreenMode Then Ret = True
		If IncrementTween(Nebula, 5,Finish, "Nebula") Then Ret=True
		If Nebula.Current = 0 And Nebula.Desired = 0 Then Nebula.Desired = MaxNebulaX
		If IncrementTween(Reliant, 5,Finish, "Reliant") Then Ret=True
		If Reliant.Desired>0 And Reliant.Current = Reliant.Desired Then Reliant.Desired=0
		
		If IncrementTween(YourATKc, API.IIF(YourATKt=TMP_Phasers,10, 5),Finish, "YourATKc") Then 
			Ret=True
			If YourATKc.current = YourATKc.Desired Then YourATKa.Desired=0
		End If
		If IncrementTween(YourATKa, 5, Finish, "YourAlpha") Then Ret=True
		
		If IncrementTween(TheirATKc, API.IIF(TheirATKt=TMP_Phasers,10, 5),Finish, "TheirATKc") Then 
			Ret=True
			If TheirATKc.current = TheirATKc.Desired Then TheirATKa.Desired=0
			If DoFlash And TheirATKc.Current = TheirATKc.Desired And TheirATKc.Desired>0 Then	
				Flash.Desired = 255
				Games.PlayFile(4)
				DoFlash=False
			End If
		End If
		If IncrementTween(TheirATKa, 5, Finish, "TheirAlpha") Then Ret=True
		
		If Not(Ret) Then Ret = LCAR.IsToastVisible(LCAR.EmergencyBG,False) >0
		If Not(Ret) And FullscreenMode Then 
			ResetViewScreen(ReliantDamaged)
			FullscreenMode = False
			Games.BMN_HandleAnswer(LCAR.EmergencyBG, -4,0)
		Else
			LCAR.IsClean=False
		End If
	'Log("Done viewscreen " & Ret)
	Return Ret
End Sub
Sub IncrementTween(tweenA As TweenAlpha, Speed As Int, Finish As Boolean, Name As String ) As Boolean 
	'Log(Name & ": " & tweenA.Current & " / " & tweenA.Desired)
	If tweenA.Current<> tweenA.Desired Then 
		If Finish Then 
			If tweenA.Current > tweenA.Desired Then tweenA.Current = tweenA.Desired+1 Else tweenA.Current = tweenA.Desired-1
		Else
			tweenA.Current = LCAR.Increment(tweenA.Current, Speed, tweenA.Desired)
		End If
		Return True
	End If
End Sub

Sub ResetViewScreen(Damaged As Boolean)
	'Dim FullscreenMode As Boolean, Nebula As TweenAlpha, Reliant As TweenAlpha 
	FullscreenMode=False
	If Nebula.IsInitialized Then
		Nebula.desired =MaxNebulaX
	Else
		Nebula=Games.MakeTween(MaxNebulaX)'max=160
	End If
	If Reliant.IsInitialized Then
		Reliant.Desired =0
	Else
		Reliant=Games.MakeTween(0)
	End If
	If Flash.IsInitialized Then
		Flash.desired=0
	Else
		Flash=Games.MakeTween(0)
	End If
	ReliantDamaged=Damaged
	EndGame=-1
	'YourATKt=-1
	'TheirATKt=-1
	YourATKc=Games.MakeTween(0)
	TheirATKc=Games.MakeTween(0)
	DoFlash=False
End Sub

Sub DrawViewScreen(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Rect= MakeRect2(0,0,1280,544) ,Size As Point =API.Thumbsize(GetSize(temp,True),GetSize(temp,False), Width,Height, True,False)
	Dim temp2 As Rect ,ReliantX As Int ,temp3 As Int ,temp4 As Int 
	X=X+Width/2 - Size.X/2
	Y=Y+Height/2 - Size.Y/2
	Width=Size.X
	Height=Size.Y
	Games.LoadImagePack(True)
	LCARSeffects2.WarpScaleFactor=  Height/LCARSeffects2.CenterPlatform.Height 
	If Flash.Current>0 Then 
		X=X+ Rnd(0,10)
		Y=Y+Rnd(0,10)
	End If

	If Nebula.IsInitialized And Reliant.IsInitialized Then'nebula width=1440   MaxNebulaX=160 (first step)
		temp2 = MakeRect2(1280+Nebula.Current,0,1280,544)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, temp2, LCAR.SetRect(X, Y, Width+1,Height+1))'draw nebula
		
		'reliant
		ReliantX=Width*0.5
		ReliantX=  Width - ( ReliantX* (Nebula.Current/MaxNebulaX) ) + (ReliantX * (Reliant.Current*0.005))
		temp2 = MakeRect2(2719, API.IIF(ReliantDamaged,104,0) , 253,104)
		If LCARSeffects2.WarpLowRes Then temp2.Left= temp2.Left+1
		temp3=Width*0.20
		temp4=temp3*0.4110671936758893
		If Reliant.Current=0 Then
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, temp2, LCAR.SetRect(X+ReliantX - temp3/2, Y+Height/2-temp4/2, temp3,temp4))
		Else
			BG.DrawBitmapRotated(LCARSeffects2.CenterPlatform, temp2, LCAR.SetRect(X+ReliantX - temp3/2, Y+Height/2-temp4/2, temp3,temp4), Reliant.Current * 0.3)' * 30)
		End If
		
		'API.DrawText(BG, LCAR.IsToastVisible(LCAR.EmergencyBG,False) & " " & FullscreenMode & CRLF & Nebula.Current & " " & Nebula.Desired & CRLF & Reliant.Current & " " & Reliant.Desired & CRLF & YourATKt & " " & YourATKc.Current & " " & YourATKc.Desired & CRLF & TheirATKt & " " & TheirATKc.Current & " " & TheirATKc.Desired , X+Width/2,Y+Height/2, LCAR.LCARfont,LCAR.Fontsize , LCAR.GetColor(LCAR.LCAR_Orange,False,255),5)
		
		DrawAttack(BG,X,Y,Width,Height,True,  ReliantX)
		DrawAttack(BG,X,Y,Width,Height,False, ReliantX)
	End If
	If Flash.IsInitialized Then
		If Flash.Current>0 Then LCAR.DrawRect(BG, X, Y, Width,Height, Colors.ARGB(Flash.Current,255,0,0), 0)
	End If 	
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, temp, LCAR.SetRect(X, Y, Width+2,Height+2))'Border (last step)
End Sub

Sub DrawAttack(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Yours As Boolean, ReliantX As Int)
	Dim tempP As Point, HalfHeight As Int =Height/2'Dim YourATKt As Int, YourATKc As TweenAlpha , TheirATKt As Int, TheirATKc As TweenAlpha , TMP_Phasers As Int = 0, TMP_PhoTorps As Int =1, TMP_Evade=2
	tempP.Initialize 
	If Yours Then 
		If YourATKt <> TMP_Evade And YourATKa.Current>0 Then
			tempP.Y = Y+ Height - (HalfHeight*(YourATKc.current*0.01))
			If YourATKt = TMP_Phasers Then
				tempP.X = X+ Width/2
				DrawPhasers(BG, tempP.X, Y+Height, tempP.X,tempP.Y, False,YourATKa.Current*0.01)
			Else If YourATKt =TMP_PhoTorps And TheirATKt <> TMP_Phasers Then
				tempP.X= X+ReliantX
				DrawPhotonTorpedo(BG, tempP.X,tempP.Y, 75* ((100-YourATKc.current)*0.01))
			End If
		End If
	Else 
		If TheirATKt  <> TMP_Evade And TheirATKa.Current>0 Then
			tempP.Y = Y+ HalfHeight + (HalfHeight *(TheirATKc.current*0.01))
			If TheirATKt = TMP_PhoTorps And YourATKt <> TMP_Phasers Then
				tempP.X = X+ Width/2
				DrawPhotonTorpedo(BG, tempP.X,tempP.Y, 75*(TheirATKc.current*0.01))
			Else If TheirATKt=TMP_Phasers Then
				tempP.X= X+ReliantX
				DrawPhasers(BG, tempP.X, tempP.Y, tempP.X,Y+HalfHeight, True,TheirATKa.Current *0.01)
			End If
		End If
	End If
End Sub

Sub GetPalpha(Stage As Int, Alpha As Float) As Int 
	Return Min(255,32*Stage*Alpha)
End Sub
Sub PhaserColor(Index As Int, Alpha As Float) As Int 
	Select Case Index
		Case 0: Return Colors.ARGB(GetPalpha(1, Alpha),  31,  1,    0)
		Case 1: Return Colors.ARGB(GetPalpha(2, Alpha),  41,  5,    2)
		Case 2: Return Colors.ARGB(GetPalpha(3, Alpha),  54,  11,   2)
		Case 3: Return Colors.ARGB(GetPalpha(4, Alpha),  79,  14,   1)
		Case 4: Return Colors.ARGB(GetPalpha(5, Alpha), 104,  20,   1)
		Case 5: Return Colors.ARGB(GetPalpha(6, Alpha), 130,  28,   2)
		Case 6: Return Colors.ARGB(GetPalpha(7, Alpha), 157,  41,   5)
		Case 7: Return Colors.ARGB(GetPalpha(8, Alpha), 220, 150,  42)
		Case 8: Return Colors.ARGB(GetPalpha(9, Alpha), 224, 185,  73)
		Case 9: Return Colors.ARGB(GetPalpha(10,Alpha), 223, 198, 159)
	End Select
End Sub
Sub DrawPhasers(BG As Canvas, BottomX As Int, BottomY As Int, TopX As Int, TopY As Int, NeedsBottom As Boolean , Alpha As Float)
	DrawPhaserSlice(BG, BottomX,BottomY,  78   ,TopX,TopY, PhaserColor(0, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  59   ,TopX,TopY, PhaserColor(1, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  45   ,TopX,TopY, PhaserColor(2, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  37   ,TopX,TopY, PhaserColor(3, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  29   ,TopX,TopY, PhaserColor(4, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  20   ,TopX,TopY, PhaserColor(5, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  15   ,TopX,TopY, PhaserColor(6, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  12   ,TopX,TopY, PhaserColor(7, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  8    ,TopX,TopY, PhaserColor(8, Alpha), NeedsBottom)
	DrawPhaserSlice(BG, BottomX,BottomY,  4    ,TopX,TopY, PhaserColor(9, Alpha), NeedsBottom)
End Sub
Sub DrawPhaserSlice(BG As Canvas, BottomX As Int, BottomY As Int, BottomWidth As Int, TopX As Int, TopY As Int, Color As Int, NeedsBottom As Boolean) 
	Dim P As Path 
	BottomWidth=BottomWidth* API.iif(LCARSeffects2.WarpLowRes, 0.25, 0.5)
	LCARSeffects2.MakePoint(P, TopX,TopY)
	LCARSeffects2.MakePoint(P, BottomX-BottomWidth, BottomY)
	LCARSeffects2.MakePoint(P, BottomX+BottomWidth, BottomY)
	LCARSeffects2.MakePoint(P, TopX,TopY) 
	BG.DrawPath(P, Color, False, 1)
	BG.DrawPath(P, Color, True, 0)
	'BG.DrawRect( LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 1, True, False), Color, True,0)
	If NeedsBottom Then BG.DrawCircle(BottomX,BottomY,BottomWidth, Color, True,0)
End Sub

Sub DrawPhotonTorpedo(BG As Canvas, X As Int, Y As Int, Radius As Int)
	Dim temp As Int, Color As Int, HalfR As Int = Radius *0.5

	'sun
	Color = 8'Radius*0.25
	For temp = Radius To 1 Step -4
		If temp <= 16 Then
			BG.DrawCircle(X,Y, temp, Colors.ARGB(32,255,255,255), True, 0)
		Else If Color>0 Then
			BG.DrawCircle(X,Y, temp, LCAR.GetColor(LCAR.LCAR_Red,False, Color), True, 0)
			Color=Min(255,Color+8)
			If temp<HalfR Then Color=0
		Else
			BG.DrawCircle(X,Y, temp, LCAR.GetColor(LCAR.LCAR_Yellow , True, Color), True, 0)
			Color=Color-8
		End If
	Next
	
	'flares
	HalfR=LCAR.GetColor(LCAR.LCAR_Red,True, 128) '  Colors.ARGB(96,255,0,0)
	Radius=Radius*0.75
	For temp = 1 To 8
		LCAR.DrawGradient(BG, HalfR ,HalfR-1 , 6, X-Radius,Y,  Radius*2,3, 0, Rnd(0,360) )
	Next
	


'	Dim temp As Rect ,Width As Int=56, Height As Int =51,Size As Point 
'	Select Case Rnd(0,5)
'		Case 0: 
'			temp=MakeRect2(	2719,	430,	56,		51)
'		Case 1: 
'			temp=MakeRect2( 2776,	430,	51,		51)
'			Width=51
'		Case 2: 
'			temp=MakeRect2( 2828,	430,	50,		51)
'			Width=50
'		Case 3: 
'			temp=MakeRect2( 2719,	482,	60,		57)
'			Width=60
'			Height=57
'		Case 4: 
'			temp=MakeRect2( 2780,	482,	74,		62)
'			Width=74
'			Height=62
'	End Select
'	Size = API.Thumbsize(Width,Height, Radius*2,Radius*2, True,False)
'	BG.DrawBitmap(LCARSeffects2.CenterPlatform, temp, LCAR.SetRect(X-Size.X/2, Y-Size.Y/2,Size.X,Size.Y))
End Sub

Sub GetSize(Temp As Rect, Width As Boolean )As Int
	If Width Then Return Temp.Right-Temp.Left Else Return Temp.Bottom-Temp.Top 
End Sub
Sub MakeRect2(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	If LCARSeffects2.WarpLowRes Then
		Return LCAR.SetRect(X*0.5,Y*0.5,Width*0.5,Height*0.5)
	Else
		Return LCAR.SetRect(X,Y,Width,Height)
	End If
End Sub

Sub DrawEndGame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, State As Boolean) As Boolean 
	Dim Filename As String ,Size As Point
	If EndGame>0 Then
		'0=won 1=lost
		Filename = "twok" & API.iif(EndGame=1, "win", "lose")
		Filename = API.HILOFile(LCAR.DirDefaultExternal, Filename & "hi.jpg", Filename & "lo.jpg")
		If Filename.length=0 Then
			
			Filename = API.getstringvars("twok_filemissing", Array As String(API.GetString("twok_" & API.iif(EndGame=1, "won", "lose"))))
			LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, State,Alpha, Filename)
			'LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, State,Alpha, "YOU " & API.iif(EndGame=1, "WON", "LOST") & CRLF & "BUT THE IMAGE IS MISSING")
			'IsHighQ = API.HILOFile(LCAR.DirDefaultExternal,"twokhi.png", "twoklo.png").Contains("hi.")
			'Games.DownloadMSD("twok" & API.iif(EndGame=1, "win", "lose") & ".jpg" ,IsHighQ)
		Else
			LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, Filename, LCAR.TMP_FireControl)
			Size = API.Thumbsize(LCARSeffects2.CenterPlatform.Width ,LCARSeffects2.CenterPlatform.Height, Width,Height,True,False)
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X+Width/2-Size.X/2, Y+Height/2-Size.Y/2, Size.X,Size.Y))
		End If
		Return True
	End If
End Sub
Sub DrawFireControl(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Selected As Int, Alpha As Int, State As Boolean)
	Dim temp As Int,temp2 As Int,temp3 As Float ,temp4 As Int,temp5 As Int, tempY As Int, OriginalWidth As Int = Width, Fontsize As Int,Spacing As Int = 10, tempstr As String 
	LCAR.DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
	If Height>Width Then 
		temp3= Width/Height	
		temp=Width*temp3
		'Y=Y+ Height/2 - temp/2
		'If FullscreenMode Then
		'	DrawViewScreen(BG,X,Y+Height/2-temp/2,Width,temp)
		'	Return
		'End If
		If DrawEndGame(BG,X,Y,Width,temp,Alpha,State) Then Return
		DrawViewScreen(BG,X,Y,Width,temp)
		Y=Y+Height-temp
		Height=temp
	Else If FullscreenMode Or EndGame>0 Then
		If Not(DrawEndGame(BG,X,Y,Width,Height,Alpha,State)) Then DrawViewScreen(BG,X,Y,Width,Height)
		Return
	End If
	'LCAR.DrawRect( BG, X,Y,Width,Height,Colors.Green ,0)
	
	Width=Width*0.6666666
	tempstr = API.getstring("twok_firecontrol")
	temp = Min(API.GetTextHeight(BG,Width*-0.5, tempstr,  Typeface.DEFAULT), LCAR.Fontsize)
	temp  = API.drawtextaligned(BG, tempstr, X+Width/2, Y,0, Typeface.DEFAULT, temp, Colors.White, 8, 0, 0) 
	Fontsize= API.GetTextHeight(BG, temp*0.5, tempstr, Typeface.DEFAULT)
	
	tempstr = API.getstring("twok_torpedos")
	temp2 = BG.MeasureStringWidth(tempstr, Typeface.DEFAULT, Fontsize)
	API.drawtextaligned(BG,API.getstring("twok_phasers"), X,Y+temp,0, Typeface.DEFAULT, Fontsize, Colors.White, 7, 0, 0)
	API.drawtextaligned(BG, API.getstring("twok_photon"), X+Width-temp2,Y+temp-6, 0, Typeface.DEFAULT, Fontsize, Colors.White, 2, 0, 0)
	API.drawtextaligned(BG, tempstr, X+Width-temp2,Y+temp, 0, Typeface.DEFAULT, Fontsize, Colors.White, 8, 0, 0)
	
	Width=Width*0.5
	temp2 = Width*0.20
	temp3=temp2*0.5
	temp5=Height*0.15
	
	For temp4=0 To 3
		tempY=Y+temp*2.5
		LCAR.DrawRect(BG,temp3, tempY, temp2, temp5, Colors.Red, 0)
		tempY=tempY+temp5+2
		API.DrawTextAligned(BG,  API.IIFIndex(temp4,Array As String( "I", "II", "III", "IV")) , temp3+temp2*0.5, tempY, 0, Typeface.DEFAULT, Fontsize, Colors.Red, 8, 0, 0)
		tempY= tempY+temp
		DrawTriangle2(BG, temp3+ temp2*0.3, tempY, temp2*0.4, temp*0.75, Colors.Yellow)
		tempY=tempY+temp*0.75+2
		If temp4=0 Then DrawContinuity(BG, temp3-2, tempY,  temp2*4+10  , temp2*0.4, Colors.Yellow, Fontsize, API.GetString("twok_continuity"),temp*0.5,temp2*0.3)
		tempY=tempY+temp*0.75+2
		DrawOctagon(BG,temp3, tempY, temp2, temp2, Colors.Blue)
		tempY=tempY+temp2+temp*0.5
		API.DrawTextAligned(BG,  API.IIFIndex(temp4,Array As String( "PRT", "STB", "FWD", "AFT")) , temp3+temp2*0.5, tempY - API.IIF(temp4=1,1,0) , 0, Typeface.DEFAULT, Fontsize, Colors.white, 8, 0, 0)
		'tempY2=tempY
		temp3=temp3+temp2+2
	Next
	temp3=X+Width
	
	temp2 = temp2*2 '(Width -OriginalWidth*3) *0.5
	temp3=temp3+Spacing'temp2*0.5
	For temp4=1 To 2
		tempY=Y+temp*2
		DrawRoundSquare(BG, temp3, tempY, temp2, temp2, Colors.Red)
		tempY= tempY+temp2+temp
		API.DrawTextAligned(BG, API.GetString("twok_launcher") & " " & temp4, temp3+temp2/2, tempY, 0, Typeface.DEFAULT, Fontsize, Colors.white, 5, 0, 0)
		tempY=tempY+temp
		DrawCircle(BG,temp3,tempY, temp2*0.5-1,temp2*0.5, Colors.yellow)
		DrawOctagon(BG, temp3+ temp2*0.5+1, tempY, temp2*0.5,temp2*0.5, Colors.red)
		tempY= tempY+temp2*0.5+temp*0.5        'tempY2'tempY+temp2*0.5
		API.DrawTextAligned(BG,"CTY", temp3+temp2*0.25,tempY-2, 0,Typeface.DEFAULT, Fontsize , Colors.yellow, 8, 0, 0)
		API.DrawTextAligned(BG,"FIRE", temp3+temp2*0.75,tempY, 0,Typeface.DEFAULT, Fontsize , Colors.red, 8, 0, 0)
		
		temp3=temp3+temp2+Spacing
	Next
	
	Width=OriginalWidth*0.33333
	X=X+ OriginalWidth*0.6666666
	
	API.drawtextaligned(BG, API.GetString("twok_thruster"), X+Width/2, Y,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 8, 0, 0) 
	API.drawtextaligned(BG, API.GetString("twok_ignition"), X+Width/2, Y+temp+2,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 8, 0, 0) 
	
	API.drawtextaligned(BG, "fwd", X+Width/2, Y+temp*3+2,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 8, 0, 0) 
	API.drawtextaligned(BG, " port", X, Y+temp*5,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 7, 0, 0)
	API.drawtextaligned(BG, "stbd ", X+Width, Y+temp*5+2,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 9, 0, 0)
	
	temp2=Y+(temp*4.5)
	temp3=tempY-temp2-(temp*0.5)
	DrawRoundSquare(BG, X+Width/2 - temp/2, temp2, temp, temp3, GetGrey(0.20,255)  )
	BG.DrawCircle(X+Width/2, temp2+temp3/2, temp, GetGrey(0.90,255), True,0) 
	BG.DrawCircle(X+Width/2, temp2+temp3/2, temp-3, GetGrey(0.70,255), True,0) 
	
	API.drawtextaligned(BG, "aft", X+Width/2, tempY ,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 8, 0, 0) 'Y+Height-temp*2+2
	API.drawtextaligned(BG, " port", X, tempY-temp*2-4,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 7, 0, 0)
	API.drawtextaligned(BG, "stbd ", X+Width, tempY-temp*2-2,0, Typeface.DEFAULT, LCAR.Fontsize, Colors.White, 9, 0, 0)
End Sub

Sub DrawContinuity(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int,Fontsize As Int, Text As String ,TextHeight As Int, Spacing As Int)
	Dim tempCont As Int = BG.MeasureStringWidth(Text,Typeface.DEFAULT, Fontsize)+2 , Space As Int = 5
	X=X+Spacing-2
	Width=Width-Spacing*2+4
	BG.DrawLine(X, Y,X+Space,Y+Space, Colors.yellow, 2)
	BG.DrawLine(X+Space,Y+Space, X+Width-Space, Y+Space, Colors.yellow, 2)
	BG.DrawLine(X+Width-Space, Y+Space,X+Width,Y, Colors.yellow, 2)
	LCAR.DrawRect(BG, X+Width/2-tempCont/2,Y, tempCont, TextHeight*2, Colors.Black, 0)
	API.DrawTextAligned(BG, Text,X+Width/2, Y+Space,0, Typeface.DEFAULT, Fontsize,  Color, 5, 0, 0)
End Sub
Sub DrawRoundSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	 Dim grad2 As ColorDrawable
	 grad2.Initialize(Color, Min(Width,Height)*0.25)
	 BG.DrawDrawable(grad2, LCAR.SetRect(X,Y,Width,Height))
End Sub
Sub DrawTriangle2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	Dim P As Path 
	LCARSeffects2.MakePoint(P, X,Y+Height)
	LCARSeffects2.MakePoint(P, X+Width*0.5,Y)
	LCARSeffects2.MakePoint(P, X+Width,Y+Height)
	LCARSeffects2.MakePoint(P, X,Y+Height)
	BG.DrawPath(P, Color, False, 2)
	BG.DrawPath(P, Color, True, 0)
	'BG.DrawRect( LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 2, True, True), Color, True,0)
	'BG.RemoveClip 
End Sub
Sub DrawOctagon(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	Dim P As Path ,Middle As Int = Width*0.3,WhiteSpace As Int = 2
	X=X+WhiteSpace
	Y=Y+WhiteSpace
	Width=Width - WhiteSpace*2
	Height=Height-WhiteSpace*2 
	
	LCARSeffects2.MakePoint(P,X+Middle,Y)
	LCARSeffects2.MakePoint(P,X,Y+Height*0.5)
	LCARSeffects2.MakePoint(P,X+Middle,Y+Height)
	LCARSeffects2.MakePoint(P,X+Width-Middle,Y+Height)
	LCARSeffects2.MakePoint(P,X+Width,Y+Height*0.5)
	LCARSeffects2.MakePoint(P,X+Width-Middle,Y)
	LCARSeffects2.MakePoint(P,X+Middle,Y)
	'BG.DrawRect( LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 2, True, True), Color, True,0)
	BG.DrawPath(P, Color, False, 2)
	BG.DrawPath(P, Color, True, 0)
	'BG.RemoveClip 
End Sub
Sub DrawCircle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int) As Int 
	Dim Radius As Int = Min(Width,Height)/2
	BG.DrawCircle(X+Width/2, Y+Height/2, Radius, Color, True,0) 
	Return Radius
End Sub
Sub DrawPercentBar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, colorid As Int, Alpha As Int, Percent As Float)
	Dim Width2 As Int = Width*0.25,temp As Int
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	LCAR.DrawGradient(BG, LCAR.GetColor(colorid,False,Alpha),  Colors.Black, 6,X,Y,Width*Percent*2,Height,0,0)
	For temp = 1 To 3
		X=X+Width2
		BG.DrawLine(X,Y,X,Y+Height,Colors.Black,2)
	Next
	BG.RemoveClip 
End Sub














Sub ShowTMPPrompt(BG As Canvas, Title As String, Text As String, Options As List,QuestionID As Int)
	'Dim TMPframe As Int=-1, TMPlist As Int =-1 	align=2        Element.rWidth=radius, Element.lWidth=stroke
	Dim Width As Int = Min(LCAR.ScaleWidth,LCAR.ScaleHeight), ItemHeight As Int = 50 
	If TMPframe=-1 Then 
		TMPGroup=LCAR.AddGroup
		TMPframe = LCAR.LCAR_AddLCAR("TMPFrame", 0,0,0,100,100,10,20, LCAR.Classic_Blue,LCAR.PCAR_Frame, "TEST", "","", TMPGroup,False, 0,False, 2, 255)
		LCAR.LCAR_AddLCAR("TMPTEXT", 0,0,0, Width- 30, Width-ItemHeight-30, 0,0, LCAR.Classic_LightBlue, LCAR.TMP_Text, "", "", "", TMPGroup, False, 7,False,0,255)
		TMPlist = LCAR.LCAR_AddList("TMPList", 0, 4,5, 0,0,Width+LCAR.ListitemWhiteSpace*2,ItemHeight, False, 0, 0,0, False,False,False, LCAR.Legacy_Button)
	End If
	LCAR.LCAR_HideElement(BG, TMPframe, False,False,True)
	LCAR.LCAR_HideElement(BG, TMPframe+1, False,False,True)
	TMPisVisible=True
	If Title.Length>0 Then
		LCARSeffects.PromptQID=QuestionID
		LCAR.LCAR_SetElementText(TMPframe, Title,"")
		LCAR.LCAR_SetElementText(TMPframe+1, "", API.TextWrap(BG, LCARSeffects2.StarshipFont, LCAR.Fontsize, Text, Width-30))
		LCAR.LCAR_ClearList(TMPlist, 0)
		LCAR.LCAR_AddListItems(TMPlist, LCAR.Classic_Blue,0, Options)
	End If
	LCAR.MoveLCAR(TMPframe, LCAR.ScaleWidth/2 - Width/2, LCAR.ScaleHeight/2-Width/2, Width, Width-ItemHeight-12 - LCAR.ListitemWhiteSpace, 255,True,True,True)
	LCAR.MoveLCAR(TMPframe+1, LCAR.ScaleWidth/2 - Width/2+15, LCAR.ScaleHeight/2-Width/2+30, Width-30, Width-ItemHeight-57 - LCAR.ListitemWhiteSpace, 255,True,True,True)
	LCAR.MoveList(TMPlist, LCAR.ScaleWidth/2 - Width/2, LCAR.ScaleHeight/2 + Width/2 - ItemHeight)
	LCAR.ForceShow(TMPframe,True)
	LCAR.ForceShow(TMPframe+1,True)
	LCAR.LCAR_HideElement(BG,TMPlist,True,True,False)
	LCAR.LCAR_HideElement(BG,TMPlist+1,True,True,False)
End Sub



Sub DrawReliant(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Shields As Int,Alpha As Int)
	Dim Size As Point ,Radius As Int 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "reliant.png", LCAR.TMP_Reliant)
	Size = API.Thumbsize(LCARSeffects2.CenterPlatform.Width ,LCARSeffects2.CenterPlatform.Height, Width,Height, True,False)
	X=X+Width/2 - Size.X/2
	Y=Y+Height/2 - Size.Y/2
	Width=Size.X
	Height=Size.Y
	'LCAR.DrawLCARPicture(BG, X, Y,Width,Height, -1,0, Alpha)
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X,Y,Width,Height) )
	Radius = Height *  0.026 
	CoverShield(1,  BG,X,Y,Width,Height,Radius, 0.02594, 0.44880, Shields)
	CoverShield(2,  BG,X,Y,Width,Height,Radius, 0.03066, 0.35241, Shields)
	CoverShield(3,  BG,X,Y,Width,Height,Radius, 0.05425, 0.25602, Shields)
	CoverShield(4,  BG,X,Y,Width,Height,Radius, 0.09670, 0.17470, Shields)
	CoverShield(5,  BG,X,Y,Width,Height,Radius, 0.14858, 0.11145, Shields)
	CoverShield(6,  BG,X,Y,Width,Height,Radius, 0.20755, 0.07229, Shields)
	CoverShield(7,  BG,X,Y,Width,Height,Radius, 0.27830, 0.05422, Shields)
	CoverShield(8,  BG,X,Y,Width,Height,Radius, 0.35377, 0.03012, Shields)
	CoverShield(9,  BG,X,Y,Width,Height,Radius, 0.42217, 0.06928, Shields)
	CoverShield(10, BG,X,Y,Width,Height,Radius, 0.50943, 0.10542, Shields)
	CoverShield(11, BG,X,Y,Width,Height,Radius, 0.58255, 0.09639, Shields)
	CoverShield(12, BG,X,Y,Width,Height,Radius, 0.65802, 0.09639, Shields)
	CoverShield(13, BG,X,Y,Width,Height,Radius, 0.73585, 0.09337, Shields)
	CoverShield(14, BG,X,Y,Width,Height,Radius, 0.8184,  0.10241, Shields)
	CoverShield(15, BG,X,Y,Width,Height,Radius, 0.89623, 0.11145, Shields)
	CoverShield(16, BG,X,Y,Width,Height,Radius, 0.96698, 0.15964, Shields)
	CoverShield(17, BG,X,Y,Width,Height,Radius, 0.92453, 0.23494, Shields)
	CoverShield(18, BG,X,Y,Width,Height,Radius, 0.84670, 0.25000, Shields)
	CoverShield(19, BG,X,Y,Width,Height,Radius, 0.76651, 0.25602, Shields)
	CoverShield(20, BG,X,Y,Width,Height,Radius, 0.68868, 0.26205, Shields)
	CoverShield(21, BG,X,Y,Width,Height,Radius, 0.70047, 0.34940, Shields)
	CoverShield(22, BG,X,Y,Width,Height,Radius, 0.75472, 0.40964, Shields)
	CoverShield(23, BG,X,Y,Width,Height,Radius, 0.74764, 0.51506, Shields)
	CoverShield(24, BG,X,Y,Width,Height,Radius, 0.68868, 0.56928, Shields)
	CoverShield(25, BG,X,Y,Width,Height,Radius, 0.66745, 0.66867, Shields)
	CoverShield(26, BG,X,Y,Width,Height,Radius, 0.74528, 0.67470, Shields)
	CoverShield(27, BG,X,Y,Width,Height,Radius, 0.82075, 0.67470, Shields)
	CoverShield(28, BG,X,Y,Width,Height,Radius, 0.89387, 0.68373, Shields)
	CoverShield(29, BG,X,Y,Width,Height,Radius, 0.95991, 0.73795, Shields)
	CoverShield(30, BG,X,Y,Width,Height,Radius, 0.91509, 0.82229, Shields)
	CoverShield(31, BG,X,Y,Width,Height,Radius, 0.83019, 0.83735, Shields)
	CoverShield(32, BG,X,Y,Width,Height,Radius, 0.75236, 0.83434, Shields)
	CoverShield(33, BG,X,Y,Width,Height,Radius, 0.66981, 0.83434, Shields)
	CoverShield(34, BG,X,Y,Width,Height,Radius, 0.58726, 0.83133, Shields)
	CoverShield(35, BG,X,Y,Width,Height,Radius, 0.50708, 0.81928, Shields)
	CoverShield(36, BG,X,Y,Width,Height,Radius, 0.42453, 0.83133, Shields)
	CoverShield(37, BG,X,Y,Width,Height,Radius, 0.35849, 0.87048, Shields)
	CoverShield(38, BG,X,Y,Width,Height,Radius, 0.28066, 0.84940, Shields)
	CoverShield(39, BG,X,Y,Width,Height,Radius, 0.21226, 0.82831, Shields)
	CoverShield(40, BG,X,Y,Width,Height,Radius, 0.15330, 0.79217, Shields)
	CoverShield(41, BG,X,Y,Width,Height,Radius, 0.09670, 0.72892, Shields)
	CoverShield(42, BG,X,Y,Width,Height,Radius, 0.05425, 0.65060, Shields)
	CoverShield(43, BG,X,Y,Width,Height,Radius, 0.03066, 0.55120, Shields)
End Sub
Sub CoverShield(DotID As Int, BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Radius As Int, X2 As Float, Y2 As Float, Shields As Int)
	If Shields<DotID Then BG.DrawCircle(X+ Width*X2, Y+ Height*Y2,Radius,Colors.black, True,0)
End Sub
Sub IncrementReliant(ElementID As Int, Element As LCARelement)As Boolean 
	If Element.LWidth <> Element.RWidth Then
		If DateTime.Now >= LastUpdated + UpdateDelay Then'
			LastUpdated=DateTime.Now
			Games.PlayFile(0)
			Element.LWidth=LCAR.Increment(Element.LWidth,1, Element.RWidth)
			If Element.LWidth=Element.RWidth Then LCAR.PushEvent(LCAR.TMP_Reliant, ElementID, Element.LWidth, MaxShields,0,0,0,LCAR.Event_Scroll)
			Return True
		End If
	End If
End Sub











Sub CellSize(Cells As Int) As Int
	Return (70 * Cells-30) * (1dip)
End Sub
Sub GetWidgetSetting(WidgetID As Int, Setting As String, Default As Object) As Object 
	If WidgetID=-1 Then Return ""
	Return Main.Settings.GetDefault("Widget" & WidgetID & "." & Setting, Default)
End Sub
Sub SetWidgetSetting(WidgetID As Int, Setting As String, Value As Object)
	If WidgetID=-1 Then WidgetID = Widgets.CurrentWidget 
	Main.Settings.Put("Widget" & WidgetID & "." & Setting, Value)
End Sub

Sub IsAnimatedWidget(wType As Int) As Boolean 
	Select Case wType
		Case 3: Return True'clock
	End Select
End Sub
Sub WidgetTypes As List 
	'Return Array As String("STARDATE", "DOOR PNL", "POWER", "CLOCK", "CALENDAR", "EVENTS", "TEXT", "1DAY WEATHER", "5DAY WEATHER", "GRFX WEATHER", "PANEL CLOCK", "ROMULAN CLOCK", "KLINGON CLOCK", "MUSIC", "REMINDERS", "GOOGLE NOW", "SANCTUARY", "ALARMS", "PHOTOS")', "SYSTEM STATS")
	Dim types As List 
	types = API.GetStrings("widget_", 0)
	types.Add(API.GetString("widget_blank"))
	Return types 
End Sub
Sub WidgetType(Index As Int) As String
	'Dim tempstr As List = WidgetTypes
	'If Index>-1 And Index<tempstr.Size Then Return tempstr.Get(Index)
	If API.Translation.ContainsKey("widget_" & Index) Then Return API.GetString("widget_" & Index)
	If Widgets.BlankType = -1 Then Widgets.BlankType = WidgetTypes.Size - 1
	If Index = Widgets.BlankType Then Return API.GetString("widget_blank")
	Return API.GetString("widget_unknown")
End Sub

Sub DrawWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int,WidgetID As Int)
	Dim Data As WidgetPackage' ,Color As Int = Colors.ARGB(255-Data.Alpha,0,0,0) 
	LCAR.DrawRect(BG, X, Y,Width+1,Height+1,  Colors.Black,0)
	'LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange, False,255, "TEST")
	Data.Initialize 
	Data.BG = BG
	Data.WidgetID=WidgetID
	Data.Loc=LCAR.SetRect(X,Y,Width+1,Height+1)
	Data.Alpha=255'Alpha
	CallSubDelayed2(Widgets, "DrawWidget2", Data)
End Sub













Sub DrawPanel(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, BigText As String, MiddleText As String, LittleText As String)
	Dim HalfH As Int= Height/2, TextSize As Int',tempstr As String  '636 * 133
	Height=HalfH*2
	TextSize=Width*0.21
	Y=Y+HalfH- (TextSize*0.5)
	Height=TextSize
	HalfH= Height/2
	
	BG.DrawCircle(X+HalfH, Y+HalfH, HalfH, Color, True,0)
	LCAR.DrawRect(BG,X+HalfH,Y,Width-HalfH*2,Height,  Color, 0)
	LCAR.DrawRect(BG,X+Height,Y,9,Height,  Colors.white, 0)
	LCAR.DrawRect(BG,X+Height+13,Y,2,Height,  Colors.white, 0)
	BG.DrawCircle(X+Width-HalfH, Y+HalfH, HalfH, Color, True,0)
	
	TextSize = API.GetTextlimitedHeight(BG, Height*0.6, Height*0.6, BigText, LCAR.LCARfont)
	API.DrawTextAligned(BG, BigText, X+Height-5,Y+HalfH, 0, LCAR.LCARfont,TextSize, Colors.White,6, 0, 0)
	'LCAR.DrawBGText(BG,X+HalfH, Y+ Height*0.2, HalfH-5, Height*0.6,       5,BigText,0, LCAR.LCAR_White,  False,255,False,False,False)
	'LCAR.DrawLCARtextbox(BG,X+HalfH, Y+ Height*0.2, HalfH, Height*0.6, 0,0, BigText, LCAR.LCAR_White, 0,0, False,False,4,255)
	
	TextSize=Height+16
	X=X+TextSize
	Width=Width-TextSize'494   14
	X=X+Width*0.03
	
	TextSize = API.GetTextHeight(BG, Height*0.2, MiddleText, LCAR.LCARfont)'  26pixels of 133
	TextSize= API.DrawTextAligned(BG,MiddleText, X,Y+Height*0.35,0, LCAR.LCARfont,TextSize,Colors.White, 1, 0, 0)'30
	
	TextSize = API.GetTextHeight(BG, Height*0.12, LittleText.Replace("|",""), LCAR.LCARfont)'  26pixels of 133
	TextSize= API.DrawTextAligned(BG,LittleText.Replace("|",CRLF), X,Y+Height*0.5, 0, LCAR.LCARfont,TextSize,Colors.White, 1, 0, 0)
	'GetTextLimitedHeight
End Sub






















Sub CHX_RandomPassword As Int 
	If Main.AprilFools Then
		Return API.Len(API.IIFIndex(CHX_Attempts, Array As String("OZYMANDIAS", "PHARAOHS", "RAMESESII")))
	Else
		Return Rnd(3,10)
	End If
End Sub
Sub CHX_ShowLogo(ElementID As Int, PasswordMode As Boolean)
	If PasswordMode Then
		If (CHX_Attempts >0 Or CHX_LogoMode>1) And CHX_Attempts< 3 Then
			CHX_Attempts=2
			CHX_LogoMode=CHX_Digits*10
		Else
			CHX_LogoMode=1
			CHX_Attempts=0
			CHX_Digits= CHX_RandomPassword'Rnd(3,10)
		End If
	Else
		CHX_Attempts=0
		If ElementID = -1 Then
			CHX_HideWindow(-1)
			LCAR.LCAR_HideElement(Null, CHX_MenubarID, True, False, True)
			CHX_LogoMode = -1
			ElementID = CHX_ElementID
			LCAR.PlaySoundFile(File.DirAssets, "modem.ogg", True)
		Else 
			CHX_LogoMode=0
			CHX_ElementID = ElementID
		End If
		LCAR.ForceShow(ElementID ,True)
		LCAR.DrawFPS=True
		LCAR.CurrentStyle = LCAR.ChronowerX
	End If
End Sub

Sub DrawCorners(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ScaleFactor As Int)
	Dim SampleSize As Int = 5, SRC As Rect = LCARSeffects4.SetRect(257,106, SampleSize, SampleSize), ScaleSize As Int = ScaleFactor * SampleSize, Right As Int = X + Width - ScaleSize + 1, Bottom As Int = Y + Height - ScaleSize + 1
	BG.DrawBitmap( LCARSeffects2.CenterPlatform, SRC, LCARSeffects4.SetRect(X,Y, ScaleSize, ScaleSize))
	BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, SRC, LCARSeffects4.SetRect(Right, Y, ScaleSize, ScaleSize), False, True)
	BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, SRC, LCARSeffects4.SetRect(Right, Bottom, ScaleSize, ScaleSize), True, True)
	BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, SRC, LCARSeffects4.SetRect(X, Bottom, ScaleSize, ScaleSize), True, False)
End Sub

Sub CHX_DrawLogo(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim NeedsInit As Boolean , TextSize As Int, Width2 As Int, Height2 As Int ,Text As String,TextHeight As Int  ,cX As Int, cY As Int, ScaleFactor As Int
	If CHX_LogoMode < 0 Then
		CHX_DrawSkull(BG,X,Y,Width,Height)
	Else If Main.AprilFools Then'x 620 y 95 w 262 h 111
		LCARSeffects2.LoadUniversalBMP(File.DirAssets, "veidt.png", LCAR.CHX_Logo)
		Width=Width+2
		Height=Height+2
		If CHX_LogoMode = 0 Then
			LCAR.DrawRect(BG,X,Y,Width,Height, Colors.Black, 0)
			Width2=262 * LCAR.GetScalemode 
			Height2=111 * LCAR.GetScalemode 
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,0,262,111), LCARSeffects4.SetRect( X+Width*0.5 - Width2*0.5, Y+Height*0.5- Height2*0.5, Width2,Height2))
		Else 'CHX_Attempts OZYMANDIAS PHARAOHS RAMESESII
			ScaleFactor=Ceil(LCAR.GetScalemode)
			LCARSeffects2.TileBitmap(BG, LCARSeffects2.CenterPlatform, 234, 111, 28,28, X,Y,Width,Height, False,False, 255,ScaleFactor)'background
			DrawCorners(BG,X,Y,Width,Height, ScaleFactor)
			Text = API.IIFIndex(CHX_Attempts, Array As String("OZYMANDIAS", "PHARAOHS", "RAMESESII"))
			Width2 = Width*0.65 
			Height2 = Min(Height,Width)*0.40
			X=X+Width*0.5- Width2*0.5
			Y=Y+Height*0.5-Height2*0.5
			cX=2*ScaleFactor
			
			'background
			LCARSeffects4.DrawRect(BG,X,Y, Width2-(2*ScaleFactor), Height2, Colors.Black, 0)
			LCARSeffects4.DrawRect(BG,X,Y, Width2-(2*ScaleFactor), Height2, Colors.White, 1*ScaleFactor)
			LCARSeffects4.DrawRect(BG,X+ cX, Y+Height2+1, Width2-cX, cX, Colors.Black,0)'---------
			LCARSeffects4.DrawRect(BG,X+Width2-cX,Y+cX, cX, Height2,Colors.Black,0)'|
						
			'titlebar
			cX=20*ScaleFactor
			cY=16*ScaleFactor
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,111,20,16), LCARSeffects4.SetRect(X,Y,cX, cY))'[
			LCARSeffects2.TileBitmap(BG, LCARSeffects2.CenterPlatform, 175,111,4,16, X+cX, Y, Width2-cX-(3*ScaleFactor), 0, False,False, 255, ScaleFactor)'---------------
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(20,111,155,16),  LCARSeffects4.SetRect(X+Width2*0.5- (155*ScaleFactor*0.5), Y,155*ScaleFactor, cY))'VEIDT INDUSTRIES caption
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(179,111, 4,16), LCARSeffects4.SetRect(X+Width2-4*ScaleFactor, Y, 4*ScaleFactor,cY))']
			
			X=X+(3*ScaleFactor)
			Width2=Width2-(6*ScaleFactor)
			Y=Y+cY
			Height2=Height2-cX			
			TextHeight=Min(Width2,Height2)
			LCAR.Draw9Patch(BG, LCARSeffects2.CenterPlatform, 0,0,262,111, 0,   X,Y, TextHeight,TextHeight,  0.75  ,255)'VEIDT ENTERPRISES logo
			X=X+TextHeight
			Width2=Width2-TextHeight
			NeedsInit=CHX_Attempts>0 And CHX_LogoMode<10
			If NeedsInit Then
				X=X + Width2*0.09
				API.DrawTextAligned(BG, API.getstring("access_denied"), X+Width2*0.4, Y+Height2*0.5, 0, CHX_Font, MAC_TextHeight, Colors.RGB(118, 166, 180), -5, 0, 0)'ACCESS DENIED
			Else
				TextHeight=Y + Height2*0.15
				LCAR.Draw9Patch(BG, LCARSeffects2.CenterPlatform, 183,111, 27,27, 9,                 X, TextHeight, Width2*0.93, Height2*0.55, ScaleFactor, 255)' . . . . . . . . 
				LCAR.Draw9Patch(BG, LCARSeffects2.CenterPlatform, 210,111, 24,24, 8,                 X+Width2*0.06, Y+Height2*0.27, Width2*0.81,Height2*0.31, ScaleFactor,255)' [_]
				BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(8,128,86,7), LCARSeffects4.SetRect(X + Width2*0.20, TextHeight- (3*ScaleFactor), 86*ScaleFactor, 7*ScaleFactor))'ENTER PASSWORD
				X=X + Width2*0.09
			
				'x 65 (0.09) y 95 (0.32) w 555 (0.76) h 51 (0.17) of 727 x 293 Dim MAC_Height As Int, MAC_TextHeight As Int 
				'Log(MAC_Height  & " " & Height)
				If MAC_Height <> Height Then 
					MAC_TextHeight=API.GetTextLimitedHeight(BG,  Height2 * 0.17, Width2*0.80,API.getstring("access_denied"), PixelFont)
					MAC_Height =Height
					'Log("Changed size " & MAC_TextHeight)
				End If
				Text = API.Left(Text, Floor(CHX_LogoMode/10)+1)' & API.IIF(DateTime.GetSecond(DateTime.now) Mod 2=0, "|", "")
				API.DrawTextAligned(BG, Text, X, Y+Height2*0.42, 0, PixelFont, MAC_TextHeight, Colors.Black, -4, 0, 0)'password
				If API.ShowCaret Then
					X=X+BG.MeasureStringWidth(Text,PixelFont, MAC_TextHeight)+2
					BG.DrawLine(X, Y+Height2*0.31, X, Y+Height2*0.53, Colors.Black, 2*ScaleFactor)
				End If
			End If
		End If
	Else
		LCAR.DrawRect(BG,X,Y,Width+2,Height+2, CHX_Beige,0)'beige
		If CHX_LogoMode = 0 Then
			LCARSeffects2.LoadUniversalBMP(File.DirAssets, "chronowerx.png", LCAR.CHX_Logo)
			If Not(CNX_OldSize.IsInitialized) Or Not(CNX_Pos.IsInitialized) Then
				NeedsInit=True
			Else If CNX_OldSize.X<>Width Or CNX_OldSize.Y<>Height Then
				NeedsInit=True
			End If
			If NeedsInit Then 
				CNX_OldSize = Trig.SetPoint(Width,Height)
				CNX_Pos	= Trig.SetPoint( Width/2, Height/2)
			End If
			If LCAR.LargeScreen Then 
				BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X+CNX_Pos.X -  LCARSeffects2.CenterPlatform.Width, Y+CNX_Pos.Y -  LCARSeffects2.CenterPlatform.Height,LCARSeffects2.CenterPlatform.Width*2+1, LCARSeffects2.CenterPlatform.Height*2+1))
			Else
				BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X+CNX_Pos.X -  LCARSeffects2.CenterPlatform.Width/2, Y+CNX_Pos.Y -  LCARSeffects2.CenterPlatform.Height/2,LCARSeffects2.CenterPlatform.Width+1, LCARSeffects2.CenterPlatform.Height+1))
			End If
		Else
			Text= api.GetString("werx_password")
			TextSize = API.GetTextHeight(BG, Width*-0.5, Text, CHX_Font)
			Width2 = Width*0.65 
			TextHeight = BG.MeasureStringHeight(Text, CHX_Font, TextSize) 
			Height2=TextHeight*4
			cX=X+ Width/2
			cY=Y+Height/2
			
			NeedsInit=CHX_Attempts>0 And CHX_LogoMode<10
			CHX_DrawSquare(BG, cX - Width2/2, cY-Height2/2, Width2, Height2, NeedsInit, "", 4, CHX_LightBlue)
			If NeedsInit Then
				Text = API.GetString("invalid_password")
				TextSize = API.GetTextHeight(BG, Width2*-0.8, Text, CHX_Font)
				TextHeight = BG.MeasureStringHeight(Text, CHX_Font, TextSize) 
				BG.DrawText(Text, cX,cY+TextHeight*0.5, CHX_Font, TextSize, CHX_DarkRed, "CENTER")
			Else
				BG.DrawText(Text, cX,cY-TextHeight*0.3, CHX_Font, TextSize, CHX_DarkBlue, "CENTER")
				Text=""
				For Height2 = 0 To Floor(CHX_LogoMode/10)
					Text = Text & "*"
				Next
				BG.DrawText(Text, cX-Width2*0.3,cY+TextHeight*1.5, CHX_Font, TextSize, CHX_DarkBlue, "LEFT")
				
				Height2=cX-Width2*0.3+ BG.MeasureStringWidth(Text,CHX_Font, TextSize)+2
				CHX_DrawInsertion(BG,Height2,cY+TextHeight*0.3, TextHeight,CHX_DarkBlue,1)
			End If
		End If
	End If
End Sub
Sub CHX_DrawInsertion(BG As Canvas, X As Int, Y As Int, Size As Int, Color As Int, Stroke As Int)
	Dim S2 As Int = Size * 0.333
	BG.DrawLine(X,Y,X+S2,Y, Color,Stroke)'top left
	BG.DrawLine(X,Y,X,Y+S2, Color,Stroke)
	
	BG.DrawLine(X,Y+Size-S2,X,Y+Size, Color,Stroke)'bottom left
	BG.DrawLine(X,Y+Size,X+S2,Y+Size, Color,Stroke)
	
	BG.DrawLine(X+Size-S2,Y,X+Size,Y, Color,Stroke)'top right
	BG.DrawLine(X+Size,Y,X+Size,Y+S2, Color,Stroke)
	
	BG.DrawLine(X+Size,Y+Size-S2,X+Size,Y+Size, Color,Stroke)'bottom right
	BG.DrawLine(X+Size-S2,Y+Size,X+Size,Y+Size, Color,Stroke)
End Sub

Sub CHX_IncLogo(Speed As Int)As Boolean 
	If CHX_LogoMode = 0 Then
		If CNX_Pos.IsInitialized And CNX_OldSize.IsInitialized And LCARSeffects2.CenterPlatform.IsInitialized And LCARSeffects2.CenterPlatformID = LCAR.CHX_Logo Then
			Dim Width As Int= LCARSeffects2.CenterPlatform.Width/2, Height As Int= LCARSeffects2.CenterPlatform.Height/2
			If LCAR.LargeScreen Then 
				Width=Width*2
				Height=Height*2
			End If
			CNX_Pos.Y = CNX_Pos.Y + API.IIF(CHX_Up, -Speed, Speed)
			If CNX_Pos.Y<Height Then
				CNX_Pos.Y=Height
				CHX_Up=False
			Else If CNX_Pos.Y > CNX_OldSize.Y-Height Then
				CNX_Pos.Y=CNX_OldSize.Y-Height
				CHX_Up=True
			End If
			
			CNX_Pos.X = CNX_Pos.X + API.IIF(CHX_Right, Speed, -Speed)
			If CNX_Pos.X<Width Then
				CNX_Pos.X=Width
				CHX_Right=True
			Else If CNX_Pos.X > CNX_OldSize.X-Width Then
				CNX_Pos.X=CNX_OldSize.X-Width
				CHX_Right=False
			End If
		End If
	Else If CHX_LogoMode <0 Then ' 'CHX_LogoMode=-1, CHX_Attempts, CHX_ElementID
		CHX_IncSkull
	Else
		CHX_LogoMode=Min(CHX_LogoMode+1,CHX_Digits*10+1)
		If CHX_LogoMode>=CHX_Digits*10 Then
			CHX_Attempts=CHX_Attempts+1
			If CHX_Attempts>2 Then 
				CHX_ResetBars(Null, -1,-1)
			Else
				CHX_LogoMode=1
				CHX_Digits=CHX_RandomPassword
			End If
		End If
	End If
	Return True
End Sub

Sub CHX_GetIconY(Index As Int)As Int 
	Dim Height As Int = CHX_Dimensions.bottom-CHX_Dimensions.Top, Width As Int = CHX_Dimensions.Right-CHX_Dimensions.Left 
	Dim IconSize As Int = (28*(Width/57))+2, WhiteSpace As Int =Max(0,((Height-14) - (IconSize*9) ) / 8)
	Return CHX_Dimensions.Top + 14 + ((IconSize+WhiteSpace) * Index) + (IconSize*0.5) - (CHX_Height2*0.5)
End Sub
Sub CHX_IconIndex(Y As Int, Width As Int, Height As Int) As Int
	Dim IconSize As Int = (28*(Width/57))+2, WhiteSpace As Int =Max(0,((Height-14) - (IconSize*9) ) / 8)
	'Log(Y & " " & Width & " " & IconSize)
	'Log((Y-14) & " " & ((Y-14) / IconSize))
	If Y>13 Then IconSize= Floor((Y-14) / (IconSize+WhiteSpace)) Else IconSize = -1
	Return API.IIF(IconSize <9, IconSize,-1)
	'if iconsize>8 then iconsize=-1
	'If Y>13 Then Return Floor((Y-14) / IconSize)
End Sub
Sub CHX_DrawIconbar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int,Selected As Int)
	Dim temp As Int  , ScaleFactor As Double = Width/57,WhiteSpace As Int = 28*ScaleFactor+2, Blank As Int=WhiteSpace
	If Not(CHX_Icons.IsInitialized) Then CHX_Icons.Initialize(File.DirAssets,"icons.png")
	'LCARSeffects2.LoadUniversalBMP(File.DirAssets, "icons.png", LCAR.CHX_Logo)
	If Width>0 And Height>0 And CHX_LogoMode>-1 Then
		CHX_Dimensions=LCAR.SetRect(X,Y,Width+2,Height+2)
		LCAR.DrawRect(BG,X,Y,Width+1,Height+2, CHX_DarkBlue ,0)

		WhiteSpace=Max(0,((Height-14) - (WhiteSpace*9) ) / 8)
		
		If Stage >0 Then CHX_DrawIcon(BG,X,Y,Width, -1, False ,False,ScaleFactor)
		'X=Min(X+10, Width-Blank-2)
		Y=Y+14
		For temp = 2 To 10
			Blank= (temp-1)*2
			If Stage >= Blank Then Y=Y+	CHX_DrawIcon(BG,X,Y,Width,temp,Stage=Blank,Selected=temp,ScaleFactor)+ WhiteSpace
			'Y=Y+29
		Next	
	End If
End Sub
Sub CHX_DrawIcon(BG As Canvas, X As Int, Y As Int, Width As Int, Index As Int, DoBlank As Boolean, Selected As Boolean ,ScaleFactor As Double) As Int 
	If DoBlank Then Index=1
	Select Case Index 
		Case -1:	BG.DrawBitmap(CHX_Icons, LCAR.SetRect(0,11,43,9),LCAR.SetRect(X+(Width/2)-(22*ScaleFactor),Y,42*ScaleFactor+1,8*ScaleFactor+1))'CHRONOWERX
		Case -2:	BG.DrawBitmap(CHX_Icons, LCAR.SetRect(0,0,43,12),LCAR.SetRect(X+(Width/2)-(22*ScaleFactor),Y-11*ScaleFactor-1,42*ScaleFactor+1,11*ScaleFactor+1))'insignia
		Case Else
			X= X+(Width/2)-(API.IIF(Index=10,26,17)*ScaleFactor)
			'Log(Index & " = " & X & " of " & Width)
			BG.DrawBitmap(CHX_Icons, LCAR.SetRect(0, Index*28, 43, 29),  LCAR.SetRect(X,Y,42*ScaleFactor+1,28*ScaleFactor+1))'icon
			'if selected then
			Return 28*ScaleFactor+2
	End Select
End Sub
Sub CHX_IncIconbar(Element As LCARelement)As Boolean 
	Dim Lists As LCARlist 
	If Element.TextAlign>-1 Then'sync to menu bar
		Lists=LCAR.LCARlists.Get(Element.TextAlign)
		If Lists.Size.offY<> 0 Then Return False
	End If
	If Element.LWidth<20 And Element.Size.offY=0 Then
		Element.rwidth = Element.RWidth + 1
		If Element.RWidth=5 Then 
			Element.rwidth=0
			Element.LWidth=Element.LWidth +1 
			If Lists.IsInitialized Then Lists.LWidth = Min(Lists.LWidth+1,Lists.ListItems.Size+2)
			If Element.LWidth=20 Then 
				CHX_HideWindow(-2)'show all
				Element.Enabled=True
			End If
		End If
		Return True
	End If
End Sub
Sub CHX_ResetBars(BG As Canvas, IconbarID As Int, MenubarID As Int)
	Dim SmallestAxis As Int = Min(LCAR.ScaleHeight, LCAR.ScaleWidth), Element As LCARelement ,Y As Int = SmallestAxis*0.12, Lists As LCARlist 
	LCAR.LCAR_HideAll(BG,True)
	If IconbarID=-1 Then
		If CHX_IconbarID = -1 Then
			CHX_GroupID=LCAR.AddGroup  
			CHX_IconbarID=LCAR.LCAR_AddLCAR("CHXICONS",0, 	0,40,	57,0,	0,0,	LCAR.LCAR_Black,LCAR.CHX_Iconbar, 	"","","",	CHX_GroupID, True,	-1,True,0,255)
			LCAR.RespondToAll(CHX_IconbarID)
		End If
		IconbarID=CHX_IconbarID
	End If	
	Element = LCAR.LCARelements.Get(IconbarID)
	Element.LWidth=0
	Element.RWidth=0
	Element.Enabled= False
	LCAR.ForceElementData(IconbarID,	0,Y,	0,0, 	SmallestAxis*0.1,-1,		0,-(LCAR.ScaleHeight-Y),		255,255,	True,True)
	LCAR.ForceShow(IconbarID,True)
	
	If MenubarID = -1 Then
		If CHX_MenubarID=-1 Then 
			CHX_MenubarID = LCAR.LCAR_AddList("CHXMENU", 0,		0,0,	 0,0, 	-1,Y,	True,SmallestAxis*0.1,		0,0,	False,False,	False,LCAR.CHX_Iconbar)
			LCAR.LCAR_ClearList(CHX_MenubarID,0)
			LCAR.LCAR_AddListItems(CHX_MenubarID,0,0, API.GetStrings("werx_menu", 0)) ' Array As String("FILE", "EDIT", "INPUT", "END"))
			Element.TextAlign=CHX_MenubarID
		End If
		MenubarID=CHX_MenubarID
	End If
	Lists=LCAR.LCARlists.Get(MenubarID)
	Lists.LWidth=0
	Lists.Tag="CHX"
	Lists.Size.offX=-LCAR.ScaleWidth 
	LCAR.LCAR_HideElement(BG,MenubarID,	True,True,True)
End Sub
Sub CHX_DrawSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, DoRed As Boolean, Text As String, Stroke As Int, FillColor As Int)
	Dim Dark As Int = API.IIF(DoRed, CHX_DarkRed,CHX_DarkBlue), Light As Int = Dark'API.IIF(DoRed,CHX_LightRed,CHX_LightBlue)
	If FillColor <> Colors.Transparent Then  LCAR.DrawRect(BG,X,Y,					Width,Height,						FillColor,0)
	BG.DrawLine(X,Y+Stroke,					X+Width,Y+Stroke,     				Light, Stroke*2)'-
	BG.DrawLine(X+Stroke,Y,					X+Stroke,Y+Height,    				Light, Stroke*2)'|
	BG.DrawLine(X,Y+Height-Stroke,			X+Width,Y+Height-Stroke,    		Dark, Stroke*2)'-
	BG.DrawLine(X+Width-Stroke,Y,			X+Width-Stroke,Y+Height,    		Dark, Stroke*2)'|
	If Text.Length>0 Then
		If CHX_Fontsize=0 Then CHX_Fontsize=LCAR.Fontsize 
		Stroke = BG.MeasureStringHeight(Text,CHX_Font,CHX_Fontsize)
		BG.DrawText(Text, X+Width/2, Y+Height/2+Stroke/2,  CHX_Font, CHX_Fontsize,   Dark,  "CENTER")
	End If
End Sub
Sub CHX_DrawMenubar(BG As Canvas, Lists As LCARlist, X As Int, Y As Int, Width As Int, Height As Int)
	Dim ScaleFactor As Double = Lists.whitespace/57, temp As Int , Listitem As LCARlistitem ,ColWidth As Int ,IsMine As Boolean = (Lists.Tag="CHX")
	CHX_Height2 = BG.MeasureStringHeight("TEST", CHX_Font,CHX_Fontsize)+20
	LCAR.DrawRect(BG,X,Y,Width+2,Height+2, CHX_LightBlue ,0)
	If Lists.LWidth>0 And IsMine Then CHX_DrawIcon(BG,X,Y+Height,Lists.whitespace, -2,False,False, ScaleFactor)
	Width=X+Width
	X=X+Lists.whitespace
	
	If IsMine Then  
		CHX_Width2=Lists.ColsLandscape+ 10
		ColWidth=CHX_Width2
	Else
		Lists.ColsLandscape = (Width/ Lists.ListItems.Size)-5
		ColWidth=Lists.ColsLandscape'(Width/ Lists.ListItems.Size)-5
	End If
	
	For temp = 0 To Lists.ListItems.Size-1
		If Lists.lwidth > temp+1 Or Lists.whitespace=0 Then
			If X + ColWidth + 5 <= Width Then
				Listitem=Lists.ListItems.Get(temp)
				CHX_DrawSquare(BG, X+5,Y+Height-CHX_Height2-4, ColWidth, CHX_Height2, False, Listitem.Text, 3,CHX_LightBeige)
				X=X+ColWidth+ 5
			End If
		End If
	Next
End Sub

Sub CHX_IncSkull
	Dim Limit As Int 
	LCARSeffects2.IncrementNumbers 
	Select Case CHX_LogoMode
		Case -1: Limit = 255'scrolling bits
		Case -2: Limit = 50'expanding window
		Case -3: Limit = 55'expanding skull
		Case -4: Limit = 5'collapsing skull
		Case -5: Limit = 20'showing text
		Case -6: Limit = 20'resting
	End Select
	CHX_Attempts=CHX_Attempts+1
	If CHX_Attempts = Limit Then 
		If CHX_LogoMode > -6 Then 
			Select Case CHX_LogoMode
				Case -4: LCAR.PlaySoundFile(File.DirAssets, "ding.ogg", True)
			End Select
			CHX_LogoMode = CHX_LogoMode - 1
		End If
		CHX_Attempts = 0
	End If
End Sub
Sub CHX_DrawSkull(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim WindowSize As Int, WindowSizeX As Int, SkullSize As Int, MaxSize As Int = Min(Width,Height) * 0.90, Color As Int = CHX_DarkBlue, Lines As Int, tempstr As String   'CHX_LogoMode=-1, CHX_Attempts, CHX_ElementID
	BG.DrawColor(CHX_LightBeige)
	'-1 LCARSeffects3.CHX_Beige, -2 LCARSeffects3.CHX_DarkBlue, -3 LCARSeffects3.CHX_DarkRed, -4 LCARSeffects3.CHX_LightBeige, -5 LCARSeffects3.CHX_LightBlue, -6 LCARSeffects3.CHX_LightRed
	LCARSeffects2.DrawNumberBlock(BG, X,			Y,	Width*0.25, 	Height, -5, 0, LCAR.CHX_Iconbar, "")
	LCARSeffects2.DrawNumberBlock(BG, X+Width*0.25,	Y,	Width*0.40, 	Height, -2, 1, LCAR.CHX_Iconbar, "")
	LCARSeffects2.DrawNumberBlock(BG, X+Width*0.65,	Y,	Width*0.25, 	Height, -2, 2, LCAR.CHX_Iconbar, "")
	LCARSeffects2.DrawNumberBlock(BG, X+Width*0.90,	Y,	Width*0.10, 	Height, -5, 3, LCAR.CHX_Iconbar, "")
	
	'LCAR.DrawUnknownElement(BG,X,Y,Width*0.25, Height, LCAR.LCAR_Orange, False, 255, "0")
	'LCAR.DrawUnknownElement(BG,X+Width*0.25,Y,Width*0.40, Height, LCAR.LCAR_Orange, False, 255, "1")
	'LCAR.DrawUnknownElement(BG,X+Width*0.65,Y,Width*0.25, Height, LCAR.LCAR_Orange, False, 255, "2")
	'LCAR.DrawUnknownElement(BG,X+Width*0.90,Y,Width*0.10, Height, LCAR.LCAR_Orange, False, 255, "3")
	Select Case CHX_LogoMode
		Case -1'pause for scrolling bits
		Case -2'expanding window
			WindowSize = CHX_Attempts*2
		Case -3'expanding skull
			WindowSize = 100
			SkullSize = CHX_Attempts * 2
		Case -4'collapsing skull
			WindowSize = 100
			SkullSize = 110 - CHX_Attempts * 2
		Case -5, -6'showing text
			Lines = 3
			If CHX_LogoMode = -5 Then Lines = Ceil(CHX_Attempts/10)
			WindowSize = 100
			SkullSize = 100
			If CHX_Attempts > 9 Then Color = CHX_DarkRed
	End Select
	'Log("CHX_DrawSkull: " & CHX_LogoMode & " - " & CHX_Attempts & " - " & WindowSize & " - " & SkullSize & " " & (Color = CHX_DarkBlue))
	If WindowSize > 0 Then
		WindowSize = WindowSize * 0.01 * MaxSize 
		WindowSizeX = Max(WindowSize, Width*0.5)
		CHX_DrawSquare2(BG, X+Width*0.5 - WindowSizeX*0.5, Y+Height*0.5 - WindowSize*0.5, WindowSizeX,WindowSize)
		If SkullSize > 0 Then CHX_DrawSkullLogo(BG,X+Width*0.5,Y+Height*0.5-WindowSize*0.10,SkullSize*0.01*WindowSize*0.75)
		If Lines > 0 Then 
			tempstr=API.GetString("werx_err0")
			WindowSizeX = API.GetTextLimitedHeight(BG, WindowSize * 0.08, WindowSize*0.9, tempstr, CHX_Font)
			MaxSize=Y+Height*0.5+WindowSize*0.37
			BG.DrawText(tempstr,X+Width*0.5,MaxSize, CHX_Font, WindowSizeX, Color, "CENTER")
			If Lines > 1 Then
				MaxSize=MaxSize + BG.MeasureStringHeight(tempstr, CHX_Font, WindowSizeX)
				tempstr = API.GetString("werx_err1") '"ERROR # 0047"
				WindowSizeX = API.GetTextHeight(BG, WindowSize * 0.05, tempstr, CHX_Font)
				BG.DrawText(tempstr,X+Width*0.5,MaxSize, CHX_Font, WindowSizeX, Color, "CENTER")
				If Lines > 2 Then
					MaxSize=MaxSize + BG.MeasureStringHeight(tempstr, CHX_Font, WindowSizeX)
					tempstr =API.GetString("werx_err2") ' "CONTACT CHRONOWERX TECHNICAL SUPPORT 1-800-ON-HOLD"
					WindowSizeX = API.GetTextLimitedHeight(BG, WindowSize * 0.02, WindowSize, tempstr, CHX_Font)
					MaxSize=MaxSize - BG.MeasureStringHeight(tempstr, CHX_Font, WindowSizeX)
					BG.DrawText(tempstr,X+Width*0.5,MaxSize, CHX_Font, WindowSizeX, Color, "CENTER")
				End If
			End If
		End If
	End If
End Sub
Sub CHX_DrawSquare2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim Stroke As Int = 3
	BG.DrawLine(X-Stroke,Y-Stroke,X+Width+Stroke,Y-Stroke, CHX_LightBlue, Stroke)
	BG.DrawLine(X-Stroke,Y-Stroke,X-Stroke,Y+Height+Stroke, CHX_LightBlue, Stroke)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height, CHX_LightBeige, 0)
	BG.DrawLine(X-Stroke,Y+Height+Stroke,X+Width+Stroke*2, Y+Height+Stroke, CHX_DarkBlue, Stroke*2)
	BG.DrawLine(X+Width+Stroke*2,Y-Stroke,X+Width+Stroke*2, Y+Height+Stroke, CHX_DarkBlue, Stroke*2)
End Sub
Sub CHX_DrawSkullLogo(BG As Canvas, X As Int, Y As Int, Height As Int)
	Dim Width As Int = Height * 1.13'Size As Point
	LCARSeffects2.LoadUniversalBMP(File.DirAssets,"skull.png", LCAR.CHX_Logo)'  195x172
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCARSeffects4.SetRect(X-Width*0.5, Y - Height*0.5, Width,Height))
	'Size = API.Thumbsize(Width*ScaleFactor,Height*ScaleFactor, 195,72, False,True)
	'BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X+Width*0.5 - Size.X*0.5, Y+Height*0.5 - Size.Y*0.5, Size.X+1,Size.Y+1))
End Sub

'text alignment 0=left,1=center,2=right
Sub CHX_DrawText(BG As Canvas, X As Int, Y As Int, Text As String, Align As Int, Color As Int)
	BG.DrawText(Text,X,Y+CHX_Height2-20, CHX_Font, CHX_Fontsize, Color, API.IIFIndex(Align, Array As String("LEFT", "CENTER", "RIGHT")))
End Sub
Sub CHX_DrawSubText(BG As Canvas, X As Int, Y As Int, Text As String, Color As Int) As Int 
	Dim temp As Int ,tempstr As String  ,HalfSize As Int=CHX_Fontsize*0.5
	Do Until Text.Length=0
		temp = Text.IndexOf("_")
		Select Case temp
			Case -1
				CHX_DrawText(BG,X,Y,Text,0,Color)
				X=X+1+CHX_TextWidth(BG,Text)
				Text=""
			Case 0
				tempstr= API.Mid(Text,1,1)
				BG.DrawText(tempstr,X,Y+CHX_Height2-20, CHX_Font, HalfSize, Color, "LEFT")
				Text=API.Right(Text,Text.length-2)
				X=X+1+BG.MeasureStringWidth(tempstr,CHX_Font,HalfSize)
			Case Else
				tempstr = API.Left(Text,temp)
				CHX_DrawText(BG,X,Y,tempstr,0,Color)
				X=X+CHX_TextWidth(BG,tempstr)+1
				Text=API.Right(Text,Text.Length-tempstr.Length)
		End Select
	Loop
	Return X
End Sub

Sub CHX_TextWidth(BG As Canvas, Text As String) As Int
	Return BG.MeasureStringWidth(Text,CHX_Font,CHX_Fontsize)
End Sub
Sub CHX_TextHeight As Int 
	Return CHX_Height2-20
End Sub

Sub CHX_GetWindow(Index As Int, Element As LCARelement) As CHX_Window
	Dim temp As CHX_Window ' lwidth=IconIndex,rwidth=FooterRows, colorid=WindowType
	temp.ElementIndex =Index
	temp.WindowType = Element.ColorID 
	temp.Val1= Element.Align 
	temp.Val2= Element.TextAlign 
	temp.Val3= Element.RedAlertHold 
	temp.Val4= API.ToNumber(Element.Tag)
	Return temp
End Sub
Sub CHX_SetWindow(Element As LCARelement,Window As CHX_Window)
	Element.Align=Window.Val1
	Element.TextAlign= Window.Val2
	Element.RedAlertHold =Window.Val3
	Element.Tag=Window.Val4
End Sub

Sub CHX_DrawWindow(BG As Canvas, IconIndex As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, TitleText As String, ButtonText As String, FooterText As String, FooterRows As Int,Window As CHX_Window) As CHX_Window 
	'start partially overlapping to the right of the icon
	'0/3a-1/3a (0-80)	enlarge to full width
	'1/3a-2/3a (81-160)	move over to X
	'2/3a-3/3a (161-	enlarge both upwards and downards to fit height
	'text/contents are now visible
	If CHX_LogoMode =-1 Then Return Window
	Dim stage As Int,X2 As Int, Y2 As Int,tempstr As String',SetWindow As Boolean   '0, 16, 32, 48, 64, 80, 		96, 112, 128, 144, 160,		176, 192, 208, 224, 240, 256
	If Alpha < 81 Then      'enlarging/shrinking horizontally, width is (alpha/80)*height
		X= CHX_Dimensions.Right - 10
		Y= CHX_GetIconY(IconIndex)
		Height = CHX_Height2
		Width = Max(5, Width * (Alpha/80))
	Else If Alpha < 161 Then'moving right horizontally,
		X= (CHX_Dimensions.Right - 10) + ( (X- CHX_Dimensions.Right - 10) * ((Alpha-80)/80) )
		Y= CHX_GetIconY(IconIndex)
		Height = CHX_Height2
		If Alpha>160 Then stage=1 'draw top/bottom
	Else If Alpha < 255 Then 'enlarging/shrinking vertically, size is (alpha-160/80)*height
		Height=((Alpha-160)/80)*Height
		Y=Max(CHX_Dimensions.Top, (CHX_GetIconY(IconIndex)+ (CHX_Height2*0.5)) - (Height*0.5) )
		stage=1'draw top/bottom
	Else
		stage=2'draw all
	End If
	
	If stage = 0 Then 
		CHX_DrawSquare(BG,X,Y,Width,Height,False, "", 2, CHX_LightBeige) 'draw bar
	Else
		CHX_DrawSquare(BG,X,Y,Width,Height,False, "", 2, CHX_Beige)
		CHX_DrawSquare(BG,X,Y,Width, CHX_Height2, False, "", 2, CHX_LightBeige)'top
		CHX_DrawSquare(BG,X,Y+Height-CHX_Height2*FooterRows,Width, CHX_Height2*FooterRows, False, "", 2, CHX_LightBeige)'bottom
		If stage=2 Then
			LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			'LCARSeffects.MakeClipPath(BG,X,Y,Width-CHX_Width2,Height)
				CHX_DrawText(BG,X+10,Y+10, TitleText, 0, CHX_DarkBlue)
				CHX_DrawSquare(BG,X+Width-CHX_Width2,Y,CHX_Width2, CHX_Height2, False, ButtonText, 2, CHX_LightBeige)
				CHX_DrawText(BG,X+10,Y+Height-CHX_Height2+10, FooterText, 0, CHX_DarkBlue)
			BG.RemoveClip 
			
			X=X+3
			Y=Y+CHX_Height2
			Width=Width-6
			Height=Height-CHX_Height2*(FooterRows+1)
			
			BG.RemoveClip 
			'stage = CHX_FindWindow(WindowID)
			'If stage>-1 Then
				'Window = CHX_Windows.Get(stage)
				'Log("Drawing: " & Window.WindowType)
				Select Case Window.WindowType 
					Case CHX_WinBlank:	Return Window'GNDN
					Case CHX_WinSIN
						'SetWindow=True
						Y=Y+2
						Height=Height-4
						'Log("Drawing SIN waves")
						Window.Val1 = CHX_DrawSINwave(BG,X,Y,Width,Height, Window.Val1, Height*0.50, Width * 0.5, 	Colors.Yellow, 	2, True)
						Window.Val2 = CHX_DrawSINwave(BG,X,Y,Width,Height, Window.Val2, Height*0.18, Width * 0.25, 	Colors.Yellow, 	2, True)
						Window.Val3 = CHX_DrawSINwave(BG,X,Y,Width,Height, Window.Val3, Height*0.33, Width * 0.5, 	Colors.red, 	2, True)
						Window.Val4 = CHX_DrawSINwave(BG,X,Y,Width,Height, Window.Val4, Height*0.25, Width * 0.1, 	CHX_DarkBlue, 	2, True)
						stage = CHX_DrawRuler(BG,X + Width + 6 - CHX_Width2, Y+ 10, 15, Height-20, 8,CHX_DarkBlue,2)
						CHX_DrawRuler(BG,X + 20, stage, Width-CHX_Width2-20, 15, 12, CHX_DarkBlue,2)
						Y=Y+Height+6
						Height=CHX_Height2*2
						LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
							X=20+ 	CHX_DrawSubText(BG,X+10,Y+CHX_Height2*0.25,"O_1=25.124 uZ", CHX_DarkBlue)'col 1
									CHX_DrawSubText(BG,X,Y+CHX_Height2*0.25,"O_2=13.4 uZ", CHX_DarkBlue)'col 2
							X=20+	CHX_DrawSubText(BG,X,Y+CHX_Height2,"O_3=84.267 uZ", CHX_DarkBlue)
									CHX_DrawSubText(BG,X+10,Y+CHX_Height2*0.25,"X_1=183.57 MHz", CHX_DarkBlue)'col 3
							X=20+	CHX_DrawSubText(BG,X+10,Y+CHX_Height2,"X_2=263.32 MHz", CHX_DarkBlue)
									CHX_DrawSubText(BG,X+10,Y+CHX_Height2*0.25,"X_3=143.42 MHz", CHX_DarkBlue)'col 4
									CHX_DrawSubText(BG,X+10,Y+CHX_Height2,"X_4=821.20 MHz", CHX_DarkBlue)
						BG.RemoveClip 
					Case CHX_WinSAT
						'Log("Drawing SAT " & Window.Val2)
						If Window.Val2 < 9 Then
							CHX_DrawImage(BG, Window.Val2, X,Y,Width,Height,False,False,False,0)'fractals
						Else If Window.val2=9 Then
							CHX_DrawImage(BG, 11, X+Width*0.5,Y+Height*0.5, 166,150, False,False,True,1)'small earth
						Else If Window.Val2 < 20 Then
							CHX_DrawImage(BG, 11, X+Width*0.5,Y+Height*0.5, 0,0, False,False,True,1)'small earth
							'LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
							tempstr= API.GetString("werx_seti0")'"TRIANGULATING EMISSION SOURCE"
							For stage = 1 To 3
								X2 = Rnd(X+Width*0.2, X+ Width*0.4)
								Y2 = Rnd(Y+Height*0.2, Y+ Height*0.4)
								BG.DrawLine(X, Y2, X+Width, Y2, Colors.Red, 2)
								BG.DrawLine(X2, Y, X2, Y+Height, Colors.Red, 2)
								BG.DrawCircle(X2,Y2, Width * 0.037, Colors.Red,False,2)
							Next
							stage = API.GetTextHeight(BG, -Width*0.75, tempstr,CHX_Font)
							BG.DrawText(tempstr,  X+ Width*0.5, Y+Height-2, CHX_Font, stage,CHX_DarkBlue, "CENTER")
							'CHX_DrawText(BG, X+ Width*0.5, Y+Height- CHX_Height2, "TRIANGULATING EMISSION SOURCE", 1, CHX_DarkBlue)
						Else If Window.Val2 < 30 Then '20 and 21
							CHX_DrawImage(BG,13, X+Width*0.5,Y+Height*0.5+12, 0,0, False, (Window.Val2 Mod 2=0), True,0)
							tempstr=API.GetString("werx_seti1")'"EMISSION SOURCE LOCATED"
							stage = API.GetTextHeight(BG, -(Width-20)*0.6, tempstr,CHX_Font)
							BG.DrawText(tempstr,  X+ Width*0.5, Y+Height-2, CHX_Font, stage,CHX_DarkBlue, "CENTER")
						Else '30 to 41
							tempstr=API.GetString("werx_seti2")'"GET DATA FILE HB-88/SETI STANDARD"'5 " " words
							stage = API.GetTextHeight(BG, -Width*0.75, tempstr,CHX_Font)
							Y2=BG.MeasureStringHeight(tempstr,CHX_Font, stage)
							tempstr=CHX_GetWords(tempstr, Window.Val2-29)
							BG.DrawText(tempstr,  X+20,Y+20+Y2, CHX_Font, stage, Colors.Black, "LEFT")
							If Window.Val2 > 35 Then'36
								tempstr=CHX_GetWords(API.GetString("werx_seti3"), Window.Val2-35 )'3 " " words, "ROUTE: DISH A-1"
								BG.DrawText(tempstr,  X+20,Y+22+Y2*2, CHX_Font, stage, Colors.Black, "LEFT")
								If Window.Val2 >= 40 Then 
									X2= Width*1.1
									tempstr=API.GetString("werx_seti4")'"TRANSMITTING STANDARD"
									stage= API.GetTextHeight(BG, -Width*0.75, tempstr,CHX_Font)
									Y2=BG.MeasureStringHeight(tempstr,CHX_Font, stage) 
									CHX_DrawSquare(BG,X+Width*0.5 - X2*0.5, Y+Height*0.5 - Y2*1.5, X2,Y2*3, False, "", 2, CHX_Beige)
									
									If Window.Val2 =40 Then
										BG.DrawText(tempstr, X+Width*0.5, Y+Height*0.5, CHX_Font, stage, CHX_DarkBlue, "CENTER")
										BG.DrawText(API.getstring("werx_seti5"), X+Width*0.5, Y+Height*0.5 + Y2, CHX_Font, stage, CHX_DarkBlue, "CENTER")'"SETI GREETING"
									End If
								End If
							End If
						End If
					Case CHX_WinTSH
						X=X+2
						Width=Width-3
						Y=Y+4
						Height=Height-8
						X2=Width-200'100% of width
						Y2=Height-43
						stage=Y2-136
						Y2=Y+Y2
						If Window.val2<100 Then LCAR.DrawRect(BG,X,Y+1,Width,Height+1, Colors.rgb(182,211,191),0)
						If Window.val1=100 And Window.val2>0 Then
							Dim P As Path , temp2 As Float 
							If Window.val2<100 Then
								temp2=(Window.val2*0.01)
								P.Initialize(X, Y+2)
								P.LineTo(X, Y+(Height*temp2))
								P.LineTo(X+ Height-(Height*temp2), Y+Height)
								P.LineTo(X+ Height+(Height*temp2), Y+Height)
								P.LineTo(X+(Height*temp2), Y+2)
								BG.ClipPath(P)
								LCAR.DrawRect(BG,X,Y-1,Width,Height+1, CHX_Beige,0)
							End If
							'diagonal
							BG.DrawLine(X+2,	Y,		X+Height-15,Y+Height-17, 	CHX_DarkBlue, 1)
							BG.DrawLine(X,		Y+4,		X+Height-21,Y+Height-17,  	CHX_DarkBlue, 1)
							'front, going right
							BG.DrawLine(X+75,	Y2,			X+Width,	Y2, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+9,		X+Width,	Y2+9, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+16,		X+Width,	Y2+16, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+19,		X+Width,	Y2+19, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+24,		X+Width,	Y2+24, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+30,		X+Width,	Y2+30, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+36,		X+Width,	Y2+36, 			CHX_DarkBlue, 1)
							BG.DrawLine(X+75,	Y2+42,		X+Width,	Y2+42, 			CHX_DarkBlue, 1)
							'front going up (left)
							BG.DrawLine(X,		Y2+21,		X,			Y,		  		CHX_DarkBlue, 1)'1
							BG.DrawLine(X+25,	Y2+21,		X+25,		Y,				CHX_DarkBlue, 1)'2
							BG.DrawLine(X+43,	Y2+21,		X+43,		Y,				CHX_DarkBlue, 1)'3
							BG.DrawLine(X+52,	Y2+21,		X+52,		Y,				CHX_DarkBlue, 1)'4
							BG.DrawLine(X+59,	Y2+21,		X+59,		Y,				CHX_DarkBlue, 1)'5
							'front going up (right)
							BG.DrawLine(X+91,	Y2+43,		X+91,		Y,				CHX_DarkBlue, 1)'6
							BG.DrawLine(X+98,	Y2+43,		X+98,		Y,				CHX_DarkBlue, 1)'7
							BG.DrawLine(X+107,	Y2+43,		X+107,		Y,				CHX_DarkBlue, 1)'8
							BG.DrawLine(X+124,	Y2+43,		X+124,		Y,				CHX_DarkBlue, 1)'9
							BG.DrawLine(X+150,	Y2+43,		X+150,		Y,				CHX_DarkBlue, 1)'connect 1
							'top going down/side going up
							BG.DrawLine(X+X2,	Y+68,		X+X2,		Y+Height-20,	CHX_DarkBlue, 1)
							BG.DrawLine(X+X2+24,Y+68,		X+X2+24,	Y+Height-20,	CHX_DarkBlue, 1)
							BG.DrawLine(X+X2+89,Y+68,		X+X2+89,	Y+Height-20,	CHX_DarkBlue, 1)
							BG.DrawLine(X+X2+125,Y+68,		X+X2+125,	Y+Height-20,	CHX_DarkBlue, 1)
							BG.DrawLine(X+X2+132,Y+68,		X+X2+132,	Y+Height-20,	CHX_DarkBlue, 1)'connect 2
							BG.DrawLine(X+X2+154,Y+68,		X+X2+154,	Y+Height-20,	CHX_DarkBlue, 1)
							BG.DrawLine(X+X2+170,Y+68,		X+X2+170,	Y+Height-20,	CHX_DarkBlue, 1)
							'Connecting bridge
							BG.DrawLine(X+150,	Y2-20,		X+X2+132,	Y2-20,			CHX_DarkBlue, 1)'connect 1+2
							'top going left (connects with front going up)
							BG.DrawLine(X,		Y,			X+X2+149,	Y,				CHX_DarkBlue, 1)'1
							BG.DrawLine(X+25,	Y+35,		X+X2+167,	Y+35,			CHX_DarkBlue, 1)'2
							BG.DrawLine(X+43,	Y+46,		X+X2+147,	Y+46,			CHX_DarkBlue, 1)'3
							BG.DrawLine(X+52,	Y+58,		X+X2+42,	Y+58,			CHX_DarkBlue, 1)'4
							BG.DrawLine(X+59,	Y+65,		X+X2,		Y+65,			CHX_DarkBlue, 1)'5
							BG.DrawLine(X+91,	Y+106,		X+X2+80,	Y+106,			CHX_DarkBlue, 1)'6
							BG.DrawLine(X+98,	Y+112,		X+X2+170,	Y+112,			CHX_DarkBlue, 1)'7
							BG.DrawLine(X+107,	Y+130,		X+X2+139,	Y+130,			CHX_DarkBlue, 1)'8
							BG.DrawLine(X+124,	Y+136,		X+X2+147,	Y+136,			CHX_DarkBlue, 1)'9
							If Window.val2<100 Then BG.RemoveClip 
						End If
						LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
							CHX_DrawImage(BG, 12,	X+X2-(X2*(Window.val1*0.01)), Y2,					75, 43,		False,False,False,0)'time ship front (left side)
							CHX_DrawImage(BG, 10, 	X+X2, Y2,											200,41,		False,False,False,0)'timeship left side	
							stage=Max(68,stage-(stage*(Window.val1*0.01)))
							CHX_DrawImage(BG,  9,   X+X2, Y+stage,	202,68,		False,False,False,0)'timeship top (left side)
						BG.RemoveClip 
					Case CHX_WinGAN
						If Window.Val1>0 Or Window.Val2>0 Then
							If Window.Val1>0 And Window.Val2<100 Then 'win1 0 to 100'draw win1 only at val1
								CHX_DrawImage(BG, 15,	X,Y,Width,Height, False,False,False, Window.val1) 'gantry solid
								If Window.Val1=100 And Window.Val2>0 Then CHX_DrawImage(BG, 16,	X,Y,Width,Height, False,False,False, Window.val2) 'gantry wireframe
							Else If Window.Val2=100 Then
								CHX_DrawImage(BG, 16,	X,Y,Width,Height, False,False,False, 0) 'gantry wireframe
								If Window.val1>0 Then CHX_DrawImage(BG, 15,	X,Y,Width,Height, False,False,False, Window.val1) 'gantry solid
							End If
						End If
					Case CHX_WinCLP
						Select Case Window.val2
							Case 0: Y2=10'17
							Case 1: Y2=46'18
							Case 2: Y2=65'19
							Case Else: Y2=90'20
						End Select
						CHX_DrawImage(BG, Min(20, Window.val2+17), X + Width-93, Y + Height - 45 - Y2/2, 0,0, False, False, False, 0)
						If Window.val2 > 2 Then
							X2=Width * ((Window.val2 - 2)/11.1)
							Y2=X2*0.8172043010752688
							CHX_DrawImage(BG, 21, X+Width/2 - (X2/2),Y+ Width*0.4086021505376344-Y2/2 , X2,Y2, False,False , False, 0 )'93,76
						End If
					Case CHX_WinNUM	'14 = gradient
						tempstr = API.getstring("werx_launch")
						X2 = BG.MeasureStringHeight(tempstr,CHX_Font,CHX_Fontsize)
						Y2=X2*0.5
						LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
						LCARSeffects2.DrawNumberBlock(BG,X+Y2*0.25,Y+Y2*0.5, Width-CHX_Width2-Y2,   Height-Y2, LCAR.LCAR_Chrono, Window.Index, LCAR.CHX_Window, "")
						CHX_DrawImage(BG, 14, X+Width-CHX_Width2+4,Y,CHX_Width2-4, Height, False, False, False, 0)
						BG.RemoveClip 
						BG.DrawText(tempstr, X+Y2*0.5, Y+Height+X2*1.5,  CHX_Font, CHX_Fontsize,  CHX_DarkBlue,  "LEFT")
						'CHX_DrawText(BG, X, Y+Height+2, "LAUNCH ACCESS", 0, CHX_DarkBlue)
				End Select
			'End If
		End If
	End If
	Return Window
End Sub

Sub CHX_GetWords(Text As String, Words As Int) As String 
	Dim tempstr As StringBuilder , tempstr2() As String = Regex.Split(" ", Text),temp As Int 
	If Words< tempstr2.Length Then
		tempstr.Initialize 
		For temp = 0 To Words-1
			tempstr.Append(API.IIF(temp=0,"", " ") & tempstr2(temp))
		Next
		Return tempstr.ToString 
	Else
		Return Text
	End If
End Sub

Sub CHX_MakeWindow(Width As Int, Height As Int, IconIndex As Int, TitleText As String,  FooterText As String, WindowType As Int)As Int 
	Dim temp As Int,temp2 As Int =  LCAR.ScaleHeight - CHX_Dimensions.Top -Height,Y As Int ,FooterRows As Int =1', Window As CHX_Window
	'If Not(CHX_Windows.IsInitialized) Then CHX_Windows.Initialize 
	If CHX_WindowCount< CHX_MaxWindows Then
		Width = Min(LCAR.ScaleWidth-(CHX_Dimensions.Right*3),Width)
		temp = LCAR.ScaleWidth-(CHX_Dimensions.Right*2)-Width ' X coordinate
		Y=Max(CHX_Dimensions.Top+5, Min(Max(CHX_Dimensions.Top,CHX_GetIconY(IconIndex)+CHX_Height2*0.5 - Height*0.5),temp2))
		CHX_AnimatedWindows=CHX_AnimatedWindows+1
		Select Case WindowType
			Case CHX_WinSIN, CHX_WinNUM:						FooterRows=2 
			Case CHX_WinSAT,CHX_WinTSH,CHX_WinGAN,CHX_WinCLP'animated
			Case Else:	CHX_AnimatedWindows=CHX_AnimatedWindows-1
		End Select
		temp = LCAR.RespondToAll(LCAR.LCAR_AddLCAR("CHXWIN" & CHX_WindowCount, 0, 		CHX_Dimensions.Right*2 + Rnd(0,temp) , Y,		 Width,Height,		 IconIndex,FooterRows,  WindowType,LCAR.CHX_Window, 	TitleText,FooterText,"0", 	CHX_GroupID,False, 0,True,0,0))
		'Window.Initialize 
		'Window.ElementIndex = temp
		'Window.Index = CHX_WindowCount'temp
		'Window.WindowType=WindowType
		'CHX_WindowCount=CHX_WindowCount+1
		'CHX_Windows.Add(Window)
		LCAR.ForceShow(temp,True)
		LCAR.stage=20
		CHX_WindowCount=CHX_WindowCount+1
		Return CHX_WindowCount-1
	Else
		CHX_ShowLogo(-1, False)
	End If
	Return -1
End Sub
'Sub CHX_FindWindow(WindowID As Int) As Int
'	Return CHX_FindWindowID(WindowID,True)
''	Dim temp As Int, Window As CHX_Window
''	For temp = 0 To CHX_Windows.Size -1
''		Window = CHX_Windows.Get(temp)
''		If Window.Index=WindowID Then Return temp
''	Next
''	Return -1
'End Sub
'Sub CHX_FindWindowID(ID As Int, UseWindowID As Boolean ) As Int
'	Dim temp As Int, Window As CHX_Window
'	For temp = 0 To CHX_Windows.Size -1
'		Window = CHX_Windows.Get(temp)
'		If API.IIF(UseWindowID,Window.Index,Window.ElementIndex) = ID Then Return temp
'	Next
'	Return -1
'End Sub
Sub CHX_IncWindow(ElementID As Int, Element As  LCARelement) As Boolean' WindowID As Int) As Boolean 
	Dim  Window As CHX_Window'temp As Int = CHX_FindWindow(WindowID), 
	'If temp>-1 Then
		Window = CHX_GetWindow(ElementID, Element) 'CHX_Windows.Get(temp)
		Select Case Window.WindowType 
			Case CHX_WinBlank:Return CHX_AnimatedWindows>0': Return False
			Case CHX_WinSIN
				Window.Val1 = Window.Val1 + 4
				Window.Val2 = Window.Val2 + 2
				Window.Val3 = Window.Val3 + 3
				Window.Val4 = Window.Val4 + 1
			Case CHX_WinSAT
				Window.Val1=Window.Val1+1
				If Window.Val1=10 Then 
					Window.Val1=0
					Window.Val2=Window.Val2+1
					If Window.Val2 = 42 Then Window.Val2 = 40
				End If
			Case CHX_WinTSH
				If Window.Val1 < 100 Then
					Window.Val1=Window.Val1+5
				Else If Window.Val2 < 100 Then 
					Window.Val2=Window.Val2+5
				Else
					Return CHX_AnimatedWindows>0': Return False
				End If
			Case CHX_WinGAN
				If Window.Val1 < 100 Then
					Window.Val1=Window.Val1+5
					If Window.Val1=100 Then Window.Val2=0
				Else If Window.Val2 < 100 Then 
					Window.Val2=Window.Val2+5
					If Window.Val2=100 Then Window.Val1=0
				End If
			Case CHX_WinCLP
				Window.Val1=Window.Val1+1
				If Window.Val1=10 Then 
					Window.Val1=0
					Window.Val2=Min(10,Window.Val2+1)
				End If
			Case CHX_WinNUM
				LCARSeffects2.IncrementNumbers
		End Select
		CHX_SetWindow(Element,Window)
		Return True
	'End If
End Sub
Sub CHX_HideWindow(Index As Int)
	Dim temp As Int, Window As CHX_Window, Element As LCARelement 
	If Index<0 Then'hide/show all
		'If CHX_Windows.IsInitialized Then
			For temp = LCAR.LCARelements.Size-1 To 0 Step -1
				Element=LCAR.LCARelements.Get(temp)
				If Element.ElementType= LCAR.CHX_Window Then
					'Window = CHX_GetWindow(temp,Element)'CHX_Windows.Get(temp)
					If Index=-1 Then'hide all
						CHX_HideWindow(temp)
					Else'show all
						If LCAR.LCARelements.Size < Window.ElementIndex Then
							LCAR.ForceShow(temp,True)
						Else
							CHX_DeleteWindow(Index)
						End If
					End If
				End If
			Next
			If Index=-1 Then
				CHX_WindowCount=0
				CHX_AnimatedWindows=0
				'CHX_Windows.Clear 
			End If
		'End If
	Else If Index < LCAR.LCARelements.size Then 'hide 1
		LCAR.GetElement(Index).Opacity.Desired=0
		'temp = CHX_FindWindowID(Index,False)
		'If temp > -1 Then CHX_Windows.RemoveAt(temp)
	End If
End Sub

Sub CHX_DeleteWindow(Index As Int)
	Dim temp As Int, Window As CHX_Window, Element As LCARelement' , Group As LCARgroup  ,Found As Int =-1
	If Index=-1 Then
		'Log("Delete all " & CHX_Windows.Size)
		
		'brute force all
		For temp = LCAR.LCARelements.Size -1 To 0 Step -1
			Element = LCAR.LCARelements.Get( temp )
			'Log(Element.ElementType & "=" & LCAR.CHX_Window & "=" & (Element.ElementType = LCAR.CHX_Window))
			If Element.ElementType = LCAR.CHX_Window Then
				'Log(temp & "=" & Element.Opacity.Current)
				If (Element.Opacity.Current=0 And Element.Opacity.Desired=0) Or Not(Element.visible) Then
					'Log("Window " & temp & " should be deleted")
					CHX_DeleteWindow(temp)
				End If
			End If
		Next
		'CHX_WindowCount=0
		
		'brute force visible
'		Group = LCAR.LCARGroups.Get(CHX_GroupID)
'		For temp = Group.LCARlist.Size-1 To 0 Step -1 
'			Found = Group.LCARlist.Get(temp)
'			Element = LCAR.LCARelements.Get( Found )
'			If Element.ElementType = LCAR.CHX_Window Then
'				Log(Found & "=" & Element.Opacity.Current)
'				If (Element.Opacity.Current=0 AND Element.Opacity.Desired=0) OR Not(Element.visible) Then
'					Log("Window " & Found & " should be deleted")
'					CHX_DeleteWindow(Found)
'				End If
'			End If
'		Next

'		For temp = CHX_Windows.Size-1 To 0 'Step -1
'			Log("START")
'			Window = CHX_Windows.Get(temp)
'			Element = LCAR.LCARelements.Get(Window.Index)
'			
'			Log("Checking: " & temp & ", eID: " & Window.Index)
'			Log("Window: " & Window.Index & "=" & Element.Opacity.Current & "/" & Element.Opacity.Desired & (Element.Opacity.Current=Element.Opacity.Desired) )
'			
'			If (Element.Opacity.Current=0 AND Element.Opacity.Desired=0) OR Not(Element.visible) Then
'				Log("Window " & Window.Index & " should be deleted")
'				CHX_DeleteWindow(Window.Index)
'			End If
'		Next
	Else
'		For temp = 0 To CHX_Windows.Size-1 'Step -1
'			'Window = CHX_Windows.Get(temp)
'			If Found>-1 Then
'				Element = LCAR.LCARelements.Get(Window.Index)
'				'Element.LWidth= Element.LWidth-1
'				'Window.Index = Window.Index-1
'			Else If Window.Index = Index Then
'				Found=temp 
'			End If
'		Next
		'If Found>-1 Then CHX_Windows.RemoveAt(Found)
		LCAR.LCAR_DeleteLCAR(Index)
		CHX_WindowCount = CHX_WindowCount - 1
	End If
End Sub


Sub CHX_ItemClick(BG As Canvas, ElementIndex As Int, ElementType As Int, ItemIndex As Int, X As Int, Y As Int, ActionID As Int)
	Dim Element As LCARelement ,Window As CHX_Window' ,temp As Int 
	Select Case ElementType
		Case LCAR.LCAR_List 
			Select Case ElementIndex 
				Case CHX_MenubarID
					Select Case ItemIndex
						Case 2: LCAR.SystemEvent(0,-1)
						Case Else: LCAR.ToastMessage(BG, "UNKNOWN MENUITEM " & ItemIndex, 3) 
					End Select
			End Select
		Case LCAR.CHX_Iconbar 
			Select Case ElementIndex 
				Case CHX_IconbarID
					'Log(ItemIndex)
					Select Case ItemIndex'CHX_WinSAT
						'0=painting,1=notepad,2=file cabinet,3=random numbers,4=chip,5=satelite,6=bits,7=math,8=dustpan
						Case 0: CHX_MakeWindow(400,400,   ItemIndex, API.getstring("werx_orbital"), "", CHX_WinSIN)'  "ORBITAL SPECTRUM ANALYSIS"
						Case 4: CHX_MakeWindow(400,400,   ItemIndex, API.getstring("werx_timeship") , "", CHX_WinTSH)'"FEDERATION TIMESHIP MODEL HB-88"
						Case 5: CHX_MakeWindow(400,400,   ItemIndex, API.getstring("werx_suborbital"), "", CHX_WinSAT)'"SUBORBITAL TRACKING"
						Case 6: CHX_MakeWindow(400,400,   ItemIndex, API.getstring("werx_hangar"), API.getstring("werx_timeship"), CHX_WinGAN)'"TIMESHIP HANGAR BAY/LAUNCH PLATFORM", "FEDERATION TIMESHIP MODEL HB-88"
						Case 7: 
							If Main.AprilFools Then 
								CHX_MakeWindow(400,400,   ItemIndex,  API.getstring("werx_assistant"), API.getstring("werx_clippy"), CHX_WinCLP)'"OFFICE ASSISTANT", "AGENT: CLP"
							Else
								CHX_MakeWindow(400,400,   ItemIndex, API.getstring("werx_spec"), API.getstring("NOW werx_nowavailable"), CHX_WinNUM)'"SPEC. APPS", "NOW AVAILABLE"
							End If
						Case 8: CHX_HideWindow(-1)'hide all	
						Case Else: CHX_MakeWindow(400,400, ItemIndex,  "TEST " & CHX_WindowCount,  "Total: " & CHX_WindowCount, CHX_WinBlank)
					End Select
			End Select
		Case LCAR.CHX_Window 
			If ElementIndex< LCAR.lcarelements.size Then
				Element = LCAR.lcarelements.Get(ElementIndex)
				Window = CHX_GetWindow(ElementIndex,Element)
				'temp = CHX_FindWindowID(ElementIndex,False)
				'If temp >-1 Then Window = CHX_Windows.Get(temp)
				
				Select Case ActionID
					Case LCAR.Event_Up
						If Y < CHX_Height2 And X > Element.Size.currY - CHX_Width2 Then 
							CHX_HideWindow(ElementIndex)
							If Window.IsInitialized Then
								Select Case Window.WindowType 
									Case CHX_WinSIN: CHX_AnimatedWindows = CHX_AnimatedWindows-1
								End Select
							End If
						Else
							LCAR.ReorderGroup(ElementIndex,-1)
							
						End If
				End Select
			End If
	End Select
End Sub

Sub CHX_DrawRuler(BG As Canvas, X As Int, Y As Int, Hor As Int, Ver As Int, BigUnits As Int, Color As Int, Stroke As Int) As Int 
	Dim temp As Int =BigUnits,	BigSize As Int, SmallUnits As Int , SmallSize As Int , Size As Int = Max(Hor,Ver)
	BigUnits= Floor(Size / BigUnits)
	SmallUnits = Floor(BigUnits / 4)
	BigUnits = SmallUnits*4
	
	If Hor > Ver Then 'horizontal ______	
		Hor=temp*BigUnits
		SmallSize=Ver*0.5
		BigSize=Ver
		BG.DrawLine(X,Y, X+ Hor,Y, Color,Stroke)
	Else
		Ver = temp*BigUnits
		SmallSize = Hor*0.5
		BigSize=Hor
		BG.DrawLine(X,Y,X,Y+Ver,Color,Stroke)
	End If
	
	BigUnits=temp
	For temp = 0 To BigUnits*4
		Size = API.IIF(temp Mod 4=0, BigSize, SmallSize)
		If Hor > Ver Then '_i_i_i_|_i_i_i_|
			BG.DrawLine(X, Y-Size, X,Y+Size, Color,Stroke)
			X=X+SmallUnits
		Else'=
			BG.DrawLine(X-Size, Y, X+Size, Y, Color,Stroke)
			Y=Y+SmallUnits
		End If
	Next
	If Hor > Ver Then 
		Return X - SmallUnits
	Else 
		Return Y - SmallUnits
	End If
End Sub
Sub CHX_DrawSINwave(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xoffset As Int, Amplitude As Int, Wavelength As Int, Color As Int, Stroke As Int, Top As Boolean) As Int 
	Dim HalfHeight As Int = Height*0.5, MiddleY As Int = Y + HalfHeight, temp As Int 
	If Top Then CHX_DrawSINwave(BG,X,Y,Width,Height,Xoffset,Amplitude,Wavelength,Color,Stroke,False)
	LCARSeffects.MakeClipPath(BG,X,Y + API.IIF(Top, 0,HalfHeight) ,Width,HalfHeight) 
	Y=Y+HalfHeight - Amplitude
	Xoffset=Abs(Xoffset) Mod Wavelength
	Wavelength=Wavelength*0.5
	X=X-Xoffset + API.IIF(Top, 0,Wavelength)
	Width = Width+Xoffset 
	Amplitude=Amplitude*2
	For temp = X To X+Width Step (Wavelength*2) - Stroke + 1
		BG.DrawOval(LCAR.SetRect(temp,Y,Wavelength,Amplitude), Color,False,Stroke)
	Next
	BG.RemoveClip 
	Return Xoffset
End Sub

Sub CHX_DrawImage(BG As Canvas, Index As Int, X As Int, Y As Int, Width As Int, Height As Int, FlipX As Boolean, FlipY As Boolean, Center As Boolean, Percent As Int)
	Dim Src As Rect,Dest As Rect, DoCircle As Boolean , DoPoints As Boolean , temp As Int ,X2 As Int, Y2 As Int 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "chron.png", LCAR.CHX_Window)
	Select Case Index
		'row 1
		Case 0: 	Src = LCAR.SetRect(0,	0,		159,	116)'fractal 1
		Case 1: 	Src = LCAR.SetRect(0,	116,	159,	116)'fractal 2
		Case 2: 	Src = LCAR.SetRect(0,	232,	159,	116)'fractal 3
		Case 3: 	Src = LCAR.SetRect(0,	348,	159,	116)'fractal 4
		Case 4: 	Src = LCAR.SetRect(0,	464,	159,	116)'fractal 5
		
		'row2
		Case 5: 	Src = LCAR.SetRect(159,	0,		159,	116)'fractal 6
		Case 6: 	Src = LCAR.SetRect(159,	116,	159,	116)'fractal 7
		Case 7:		Src = LCAR.SetRect(159,	232,	159,	116)'fractal 8
		Case 8: 	Src = LCAR.SetRect(159,	348,	159,	116)'fractal 9
		Case 9: 	Src = LCAR.SetRect(159,	464,	202,	68)'timeship top (left side)
		Case 10: 	Src = LCAR.SetRect(164, 539,	200,	41)'timeship left side
		
		'row 3
		Case 11'small earth
				Src = LCAR.SetRect(320,	231,	83,		75)
				DoPoints = (Percent > 0) And (Percent < 100)
				Percent=0
				
		Case 12: 	Src = LCAR.SetRect(328,	421,	75,		43)'time ship front (left side)
		
		'row 4
		Case 13'earth with the ring around it
				Src = LCAR.SetRect(318,	0,		270,	231)
				DoCircle = FlipX Or FlipY
				FlipX=False
				FlipY=False	
				
		Case 14: 	Src = LCAR.SetRect(614,	0,		6,		183)'gradient
		Case 15: 	Src = LCAR.SetRect(403,	244,	217,	168)'gantry solid
		Case 16: 	Src = LCAR.SetRect(403,	412,	217,	168)'gantry wireframe
		
		Case 17:	Src = LCAR.SetRect(620,	368,	93,		10)' Clippy 1
		Case 18:	Src = LCAR.SetRect(620,	378,	93,		46)' Clippy 2
		Case 19:	Src = LCAR.SetRect(620,	424,	93,		65)' Clippy 3
		Case 20:	Src = LCAR.SetRect(620,	490,	93,		90)' Clippy 4
		Case 21:	Src = LCAR.SetRect(620,	  0,	93,		76)' big bubble
	End Select
	Src.Right =			Src.Right + 1
	Src.Bottom =		Src.Bottom + 1
	If Width = 0 Then 	Width = 	Src.Right -		Src.Left 
	If Height = 0 Then 	Height = 	Src.Bottom -	Src.Top 
	If Percent > 0 And Percent < 100 Then
		temp= Src.Bottom -	Src.Top 
		Src.Bottom = Src.Top + temp*(Percent*0.01)
		Height = Height * (Percent*0.01)
	End If
	If Center Then
		Dest = LCAR.SetRect(X - Width*0.5, Y- Height*0.5, Width+1, Height+1)
	Else
		Dest = LCAR.SetRect(X, Y, Width+1, Height+1)
	End If
	If FlipX Or FlipY Then
		BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, Src, Dest,FlipY,FlipX)
	Else
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, Src, Dest)
		If Not(FlipX) And Not(FlipY) Then
			Select Case Index
				Case 9'timeship top (left side)
					Dest.Top = Dest.Top - Height
					Dest.Bottom = Dest.Bottom - Height
					BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, Src, Dest,True,False)
				Case 12'timeship front (left side)
					Dest.Left = Dest.Left+Width
					Dest.Right=Dest.Right+Width
					BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, Src, Dest,False,True)
			End Select
		End If
		If DoCircle Then BG.DrawCircle(X - Width * 0.35,  Y - Height * 0.26, Width * 0.037, Colors.Red, True, 0)
'		If DoPoints Then
'			For temp = 1 To 3
'				X2 = Rnd(X, X+ Width*0.25)
'				Y2 = Rnd(Y, Y+ Height*0.25)
'				BG.DrawLine(X, Y2, X+Width, Y2, Colors.Red, 2)
'				BG.DrawLine(X2, Y, X2, Y+Height, Colors.Red, 2)
'				BG.DrawCircle(X2,Y2, Width * 0.037, Colors.Red,False,2)
'			Next
'		End If
	End If
End Sub

'12:16 12:24 freq. analysis							<- todo
	'12:30 earth fractale
	'12:32 triangulating emission source
	'15:43 enter outgoing message
	'15:44 transmitting standard seti greeting
'16:28 SETI greeting
	'30:15 [SIN waves]
'30:15 skull error									<- todo
	'34:08 Chronowerx logo
	'34:09 34:26 please enter password:
	'34:50 transition sequence
'37:03 timeship window open							<- todo
'37:04 random number block 					
'37:11 circuit diagram
'37:13 random number block with side gradient small
'37:43 timeship gantry								<- todo
'37:44 random number block with side gradient big	<- todo
'38:11 38:37 40:29 misc static windows 				<- todo
'42:39 42:43 LCARS incursion 

Sub GetMonth(Name As String) As Int
	Dim Months As List = GetMonths
	Return Months.IndexOf(Name.ToUpperCase)
End Sub
Sub GetMonths As List
	Return API.GetStrings("date_", 0)
	'Return Array As String("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER")
	'Return Array As String("January","February","March", "April", "May", "June", "July", "August", "September", "October", "November", "December") 
End Sub

Sub NameOfMonth(Month As Int, LongForm As Boolean) As String 
	Dim tempstr As String = API.GetString("date_" & (Month-1))
	If Not(LongForm) Then tempstr = API.Left(tempstr,3)
	Return tempstr
End Sub
Sub GetDaysInMonth(Month As Int, Year As Int) As Int
   Dim DaysPerMonth() As Int = Array As Int (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)   
   If Month = 2 And IsLeapYear(Year) Then Return 29   
   Return DaysPerMonth(Month-1)
End Sub
Sub IsLeapYear(Year As Int) As Boolean
  If Year Mod 400 = 0 Then Return True
  If Year Mod 100 = 0 Then Return False
  If Year Mod 4 = 0 Then Return True
  Return False
End Sub
Sub DrawMonth(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Month As Int, Year As Int, Alpha As Int)
	Dim Today As Int, StartingDayOfWeek As Int,temp As Int ,DaysInMonth As Int,StartDate As Long ,Events As List ', Color As Int = LCAR.GetColor(LCAR.LCAR_Orange,False,Alpha)
	If Year = 0 Then Year = DateTime.GetYear(DateTime.Now)
	If Month=0 Then	Month = DateTime.GetMonth(DateTime.Now)
	If DateTime.GetYear(DateTime.Now) = Year And Month = DateTime.GetMonth(DateTime.Now) Then Today = DateTime.GetDayOfMonth(DateTime.Now)
	StartingDayOfWeek = DateTime.GetDayOfWeek( API.MakeDate(Year,Month, 1, 12,0,0,0)) -1 
	DaysInMonth = GetDaysInMonth(Month,Year)
	
	LCAR.DrawLCARelbow(BG,X,Y,Width,Height, 5, LCAR.ItemHeight, -2, LCAR.LCAR_Orange,False, NameOfMonth(Month,True).ToUpperCase, 0, Alpha, False)
	'temp = LCAR.DrawText2(BG, X+LCAR.ItemHeight*0.5+1, Y, LCAR.NumberTextSize , NameOfMonth(Month,True).ToUpperCase, Color, 0) + (LCAR.ItemHeight*0.5) +4
	'LCAR.DrawRect(BG, X+ temp, Y, Width-temp, LCAR.ItemHeight, Color, 0)
	
	StartDate = API.MakeDate(Year,Month,1, 0,0,0,0)
	Events = API.EnumAllEvents(StartDate, StartDate + (DateTime.TicksPerDay * DaysInMonth) )
	DrawCalendar(BG,X+7,Y+LCAR.ItemHeight+2,Width-7,Height-LCAR.ItemHeight-2,StartingDayOfWeek, DaysInMonth, Alpha, Today,StartDate, Events)
End Sub
Sub DrawCalendar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StartingDayOfWeek As Int, DaysInMonth As Int, Alpha As Int, Today As Int,StartDate As Long, Events As List)
	Dim Weeks As Int = Ceil( (DaysInMonth + StartingDayOfWeek) / 7), RowHeight As Int = Floor(Height / Weeks), ColWidth = Floor(Width/7), Y2 As Int = Y ,tempstr As String 
	Dim TextHeight As Int = API.GetTextHeight(BG, RowHeight*0.5, "123", LCAR.LCARfont), temp As Int , X2 As Int = X + (ColWidth*StartingDayOfWeek),ColorID As Int 
	For temp = 1 To DaysInMonth 
		ColorID = LCAR.LCAR_Orange
		If StartDate > 0 Then
			If API.EnumEvents(Events, StartDate,StartDate+DateTime.TicksPerDay ).Size > 0 Then 
				ColorID = LCAR.LCAR_Purple 
			Else If API.InternalEvents Then
				tempstr = API.GetHoliday(StartDate)
				If tempstr.Length>0 Then ColorID = LCAR.LCAR_Blue 
			End If
			StartDate=StartDate+DateTime.TicksPerDay 
		End If
		DrawDay(BG, X2,Y2, ColWidth, RowHeight, ColorID, temp=Today, temp, Alpha,TextHeight)
		StartingDayOfWeek=StartingDayOfWeek+1
		X2=X2+ColWidth
		If StartingDayOfWeek = 7 Then 
			StartingDayOfWeek=0
			X2=X
			Y2=Y2+RowHeight
		End If
	Next
End Sub
Sub DrawDay(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Filled As Boolean, Date As Int, Alpha As Int, TextSize As Int)
	Dim Color As Int = LCAR.GetColor(ColorID,False,Alpha)
	If Filled Then 
		Width = Width+1
		Height=Height+1
	End If
	LCAR.DrawRect(BG,X,Y,Width-1,Height-1, Color, API.IIF(Filled, 0, 1))
	API.DrawText(BG, Date, X+1,Y+2, LCAR.LCARfont, TextSize,  API.IIF(Filled, Colors.Black, Color), 1)
End Sub
Sub MakeEvent(AllDay As Boolean, CalID As Int, Description As String, EndTime As Long, EventID As Int, EventName As String, Loc As String, StartTime As Long) As CalendarEvent 
	Dim tempEvent As CalendarEvent
	tempEvent.Initialize 
	tempEvent.AllDay=AllDay
	tempEvent.CalID=CalID
	tempEvent.Description=Description
	tempEvent.EndTime=EndTime
	tempEvent.EventID=EventID
	tempEvent.EventName=EventName
	tempEvent.Loc=Loc
	tempEvent.StartTime =StartTime
	Return tempEvent
End Sub
Sub DrawEvents(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StardateMode As Int, StartDate As Long, EndDate As Long, Alpha As Int)
	If StartDate =0 Then StartDate = API.GetToday(0,0)'MakeDate( DateTime.GetYear(DateTime.Now), DateTime.GetMonth(DateTime.Now), DateTime.GetDayOfMonth(DateTime.Now),  0,0,0,0)
	If EndDate < StartDate Then EndDate = StartDate + (DateTime.TicksPerDay * 14)
	Dim Bottom As Int = Y+Height, Linesize As Int = LCAR.LCARfontheight+2, Color As Int, ColorID2 As Int, AllDay As String = API.GetString("date_allday"), Events As List = API.EnumAllEvents(StartDate, EndDate), LastDesc As String 
	Dim Column1Width As Int = LCAR.TextWidth(BG, "00:00-00:00 "), ColorID As Int, temp As Int , tempstr As String ,temp2 As Int,tempstr2 As String ,Bottom As Int = Y+ Height, DoneEvents As List, tempEvent As CalendarEvent
	Dim ThisLineHeight As Int, Color2 As Int 
	DoneEvents.Initialize
	
	Do Until StartDate >= EndDate Or Y+LCAR.ItemHeight >= Bottom
		'Dim TodaysEvents As List = API.EnumAllEvents(StartDate, StartDate+DateTime.TicksPerDay)
		Dim TodaysEvents As List = API.EnumEvents(Events,StartDate, StartDate+DateTime.TicksPerDay)
		LastDesc = ""
		'Filter duplicate events
		For temp = TodaysEvents.Size-1 To 0 Step -1 
			tempEvent = TodaysEvents.Get(temp)
			If DoneEvents.IndexOf(tempEvent.CalID & "." & tempEvent.EventID) > -1 Then 
				TodaysEvents.RemoveAt(temp)
			End If
		Next
		
		If API.InternalEvents Then tempstr = API.GetHoliday(StartDate)
		If tempstr.Length>0 Then TodaysEvents.Add(MakeEvent(True, -1, "",  StartDate+DateTime.TicksPerDay, -1, tempstr, "", StartDate))
		
		If TodaysEvents.Size>0 Then
			ColorID2 = LCAR.LCAR_RandomColor '(Linesize*TodaysEvents.Size)+2
			Color2 = LCAR.GetColor(ColorID2, False, Alpha)
			LCAR.DrawLCARelbow(BG,X,Y,Width+1, LCAR.ItemHeight+ 2,5 , LCAR.ItemHeight, -2,  ColorID2, False, LCAR.Stardate(StardateMode, StartDate, True, 0), 0, Alpha,False)
			ColorID2=LCAR.GetColor(ColorID2,False,Alpha)
			Y=Y+LCAR.ItemHeight+2
			For temp = 0 To TodaysEvents.Size-1
				tempEvent = TodaysEvents.Get(temp)
				If tempEvent.CalID = -1 And tempEvent.EventID=-1 Then 
					ColorID = LCAR.LCAR_Blue 
				Else 
					ColorID=ColorID2
					DoneEvents.Add(tempEvent.CalID & "." & tempEvent.EventID)
				End If
				Color = LCAR.GetColor(ColorID, False, Alpha)
				tempstr2 = AllDay
				If Not(tempEvent.AllDay) Then tempstr2 = API.TheTime(tempEvent.StartTime) & "-" & API.TheTime(tempEvent.EndTime)
				tempstr=API.uCase(API.IIF(tempEvent.EventName.Length=0, tempEvent.Description, tempEvent.EventName))
				If Not(tempstr.EqualsIgnoreCase(LastDesc)) Then
					If LCAR.TextWidth(BG,tempstr) <= Width-6-Column1Width Then
						temp2 = LCAR.Fontsize
						ThisLineHeight = Linesize
					Else
						temp2 = API.GetTextHeight(BG, -(Width-6-Column1Width), tempstr, LCAR.LCARfont)
						ThisLineHeight = BG.MeasureStringHeight(tempstr,LCAR.LCARfont,temp2)+1
					End If
					LCARSeffects4.DrawRect(BG,X,Y-1, 6, ThisLineHeight+3, Color2,0)
					LCAR.DrawText2(BG, X+6, Y, temp2,tempstr2, Color, 0)
					LCAR.DrawText2(BG, X+6+Column1Width, Y,temp2, tempstr, Color, 0)
					If API.debugMode And tempEvent.CalID > -1 Then 
						ColorID = BG.MeasureStringWidth(tempEvent.CalID, LCAR.LCARfont, temp2)
						LCARSeffects4.DrawRect(BG,X+Width-ColorID,Y-2, ColorID, ThisLineHeight+3, Color2,0)
						LCAR.DrawText2(BG, X+Width, Y, temp2,tempEvent.CalID, Colors.black, 2)
					End If
					Y=Y+ThisLineHeight+1
				End If 
				LastDesc = tempstr
			Next
		End If
		StartDate = StartDate + DateTime.TicksPerDay 
	Loop
	If Y < Bottom Then	LCAR.DrawRect(BG,X,Y-1,6, Bottom-Y, ColorID2,0)
End Sub


Sub NameOfMoon(AgeInDays As Double) As String 
	If AgeInDays < 1 Then Return "NEW"
	If AgeInDays < 7 Then Return "WAX CRS"
	If Floor(AgeInDays) = 7 Then Return "FIRST ¼"
	If AgeInDays < 14 Then Return "WAX GIB"
	If Floor(AgeInDays) = 14 Then Return "FULL"
	If AgeInDays < 22 Then Return "WNE GIB"
	If Floor(AgeInDays) = 22 Then Return "LAST ¼"
	If AgeInDays < 29 Then Return "WNE CRS"
	Return "NEW"
	'If AgeInDays = 0 	Then Return "NEW"
	'If AgeInDays <=7 	Then Return "1ST¼"
	'If AgeInDays >=14 	Then Return "FULL"
	'If AgeInDays >=21	Then Return "LAST¼"
	'Return "MERC"
End Sub
Sub DrawTextWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StarDateMode As Int, Alpha As Int)
	Dim AST As Astro, JulianDate As Double = AST.Julianday2(DateTime.Now, DateTime.GetTimeZoneOffsetAt(DateTime.Now)), OS As OperatingSystem 
	Dim MoonBuffer() As Double = AST.GetMoonData2(JulianDate), SunBuffer() As Double = AST.GetSunData2(JulianDate), Items As List , temp As Long 

	Items.Initialize 
	
	Items.Add("")
	Items.Add("TIME")
	'Items.Add("TIME: " & API.TheTime(DateTime.Now))
	Items.Add("DATE: " & API.getDate(DateTime.Now))
	Items.Add("STAR: " & LCAR.Stardate(StarDateMode, DateTime.Now, False,4))
	If API.TempAlarmS.Length > 0 Then
		Items.Add("NEXT ALARM: " & API.GetBetween(API.TempAlarmS, "(", ")"))
		Items.Add(API.Replace(API.GetSide(API.TempAlarmS, ")", False,False), "AT", "AT: "))
	End If
	
	Items.Add("")
	Items.Add("CAPACITY")
	Items.Add("INT: "  & API.CompressSize(OS.AvailableInternalMemorySize,2))
	If OS.AvailableInternalMemorySize <> OS.AvailableExternalMemorySize Then Items.Add("EXT: "  & API.CompressSize(OS.AvailableExternalMemorySize,2))
	temp=OS.AvailableMemory
	If temp = 0 Then temp = API.GetFreeMemory
	If temp > 0 Then Items.Add("RAM: "  & API.CompressSize(temp,2))
	Items.Add("CPU: " & API.FormatPercent(OS.calculateCPUusage,2))
		
	Items.Add("")
	Items.Add("BATTERY")
	Items.Add("LVL: " & LCAR.BatteryPercent & "%")
	Items.Add("PLUG: " & API.IIF(LCAR.isCharging, "YES", "NO"))
	Items.Add("TEMP: " & Round2(Trig.ConvertUnits(0, LCAR.BatteryTemp, "C", Weather.CurrentUnits),2) & Weather.GetUnit(Weather.CurrentUnits))
	
	Items.Add("")
	Items.Add("LUNAR")
	Items.Add("PHSE: " & Round2(MoonBuffer(0) * Trig.RadPi,1) & Chr(176))'multiply by 'rad' as all angles are provided in Radians!
	Items.Add("AGE: "  & Round2(MoonBuffer(1),1) & " D")
	Items.Add("MOON: " & NameOfMoon(Round2(MoonBuffer(1),1)))
	'Items.Add("SIZE: " & Round2(MoonBuffer(2),1) & "'")
	'Items.Add("ELNG: " & Round2(MoonBuffer(3) * Trig.RadPi,1) & Chr(176))
	'Items.Add("MAG: "  & Round2(MoonBuffer(4),1) & " VIS")
	Items.Add("DIS: "  & Round(AST.GetMoonDistance2(JulianDate)) & " KM")
	'Items.Add("LONG: " & Round2(AST.GetMoonLong2(JulianDate) * Trig.RadPi,1) & Chr(176))'ecliptic longitude
	'Items.Add("LAT: "  & Round2(AST.GetMoonLat2(JulianDate) * Trig.RadPi,1) & Chr(176))'ecliptic latitude

	Items.Add("")
	Items.Add("SOLAR")
	Items.Add("DIS: "  & Round2(SunBuffer(0),5) & " AU")
	Items.Add("SIZE: " & Round2(SunBuffer(1),1) & "'")
	Items.Add("MAG: "  & Round2(SunBuffer(2),1) & " VIS")
	Items.Add("LONG: " & Round2(AST.GetSunLong2(JulianDate) * Trig.RadPi,1) & Chr(176))  'ecliptic longitude, sun latitude is always 0

	'It shows on horizontal 4x1 place hours, minutes, day, month, next alarm, moon phase, free space on sd card, free memory, battery power, temperature, free internal memory and weather.
	'GetSunData2 - Returns an array of 3 doubles: Sun's distance in Astronomical Units AU. (1 Astronomical Unit = 149,598,000 kilometers) - The Sun's angular diameter - The sun's brightness (magnitude)
	'GetMoonData2 - Returns an array of 5 doubles: - Moon's phase in radians. - Moon's Age in days  - Moon's angular diameter in arcminutes - Moon's elongation in radians - Moon's brightness
	DrawTextItems(BG,X,Y,Width,Height,Items,Alpha)
End Sub
Sub DrawWeatherTextWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ForcastMode As Boolean, CurrentWeather As WeatherData, StardateMode As Int)
	Dim Items As List, temp As Int, tempDay As WeatherDay, S As String = " " ,temp2 As Int, tempIcon As WeatherIcon ,Threat As Int ,Today As Int
	Items.Initialize 
	Items.Add("")
	Items.Add( API.IIF(StardateMode = -9, "colorid: " & LCAR.LCAR_Orange, Weather.ProviderName(-1)))	
	If Weather.HasWeatherData(CurrentWeather) Then
		Today = Weather.FindToday(CurrentWeather)
		If Today>-1 Then
			For temp = Today To CurrentWeather.Days.Size-1 
				tempDay = CurrentWeather.days.Get(temp)
				'If Not(ForcastMode) Then
					If StardateMode >-9 Then 
						Items.Add("")
						Items.Add(LCAR.Stardate(StardateMode,  tempDay.Date, False, 0))
					End If
					'Items.Add(API.DayLabel( tempDay.Date, True))
				'End If
				For temp2 = Today To tempDay.Icons.Size -1 
					tempIcon = tempDay.Icons.Get(temp2)
					Items.Add("W: " & tempIcon.Description.ToUpperCase)
					Threat = Weather.IsDangerous( tempIcon )
					If Threat > 0 Then Items.Add("THREAT: " & API.IIF(Threat=1, "LOW", "HIGH"))
				Next
				Items.Add("HIGH: " & Round(Trig.ConvertUnits( 0, tempDay.Maximum, "C", Weather.CurrentUnits)) & S & CurrentWeather.Units) 'Trig.ConvertUnits( 0, tempDay.Maximum, "C", Weather.CurrentUnits)
				Items.Add("LOW: " & Round(Trig.ConvertUnits( 0, tempDay.Minimum, "C", Weather.CurrentUnits)) & S & CurrentWeather.Units)
				If temp = Today Then Items.Add("TEMP: " &  Round(Trig.ConvertUnits( 0, Weather.CurrentTemperature(tempDay), "C", Weather.CurrentUnits)) & S & CurrentWeather.Units)
				
				If Not(ForcastMode) Then
					If tempDay.Speed>0 Then Items.Add("WIND: " & Round2(tempDay.Speed,2) & S & CurrentWeather.UnitsSpeed)
					If tempDay.Rain>0 Then Items.Add("RAIN: " & Round2(tempDay.Rain,2) & S & CurrentWeather.UnitsDistance)
					If tempDay.Snow>0 Then Items.Add("SNOW: " & Round2(tempDay.Snow,2) & S & CurrentWeather.UnitsDistance)
					If tempDay.Humidity > 0 Then Items.Add("HUMIDITY: " & Round(tempDay.Humidity) & "%")
					If tempDay.Clouds >0 Then Items.Add("CLOUDS: " & Round(tempDay.Clouds) & "%")
					If tempDay.Pressure >0 Then Items.Add("PRESSURE: " & Round2(tempDay.Pressure,2) & S & CurrentWeather.UnitsPressure)
					temp =  CurrentWeather.Days.Size
				End If
			Next
		End If
	Else
		NoData(Items)
	End If
	DrawTextItems(BG,X,Y,Width,Height,Items,255)
End Sub
Sub NoData(Items As List)
	Items.Add("NO DATA")
	If Weather.CurrentCity.Length = 0 Then 
		Items.Add("GO TO SYS\")
		Items.Add("WEATHER SETTINGS")
		Items.Add("AND ADD A CITY")
	End If
End Sub

Sub DrawTextItems(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Items As List,Alpha As Int)
	Dim MaxWidth As Int , temp As Int ,tempstr As String, Cols As Int, Color As Int,Col As Int,X2 As Int , Bottom As Int = Y+Height
	Dim Linesize As Int = LCAR.LCARfontheight+2 ,HasColon As Boolean ,WhiteSpace As Int = 8, ColorID As Int, LockColor As Boolean 
	
	For temp = 0 To Items.Size-1 
		tempstr = Items.Get(temp)
		If tempstr.Length>0 Then MaxWidth = Max(MaxWidth, LCAR.TextWidth(BG, tempstr))
	Next
	
	If MaxWidth < Width Then
		Cols = Round(Width / MaxWidth)
		MaxWidth = Width / Cols 
		If Cols > 1 Then MaxWidth = MaxWidth - WhiteSpace
	Else
		Cols=1
		MaxWidth= Width
	End If
	
	X2=X
	For temp = 0 To Items.Size-1 
		tempstr = Items.Get(temp)
		If tempstr.Length= 0 Then
			If Col > 0 Then
				Col=0
				X2=X
				Y=Y+Linesize
			End If
			If Not(LockColor) Then
				ColorID = LCAR.LCAR_RandomColor2(ColorID)
				Color = LCAR.GetColor(ColorID,False,Alpha)
			End If
			If Y+Linesize*2 >= Bottom Then temp= Items.Size 
		Else If API.Left(tempstr, 7).EqualsIgnoreCase("colorid") Then 'If Y + Linesize <= Bottom Then 
			tempstr= API.Right(tempstr, tempstr.Length - 7).Replace(":", "").Trim 
			If IsNumber(tempstr) Then
				ColorID = tempstr
				Color = LCAR.GetColor(ColorID,False,Alpha)
				LockColor=True
			End If
		Else If tempstr.EqualsIgnoreCase("unlockcolor") Then
			LockColor=False
		Else	
			HasColon = tempstr.Contains(": ")
			DrawTextItem(BG,X2, Y, API.IIF(HasColon, MaxWidth,Width), Linesize, tempstr, Color)
			Col=Col+1
			If Not(HasColon) Then Col=Cols
			If Col = Cols Then
				Y=Y+Linesize
				X2=X
				Col=0
				If Y+Linesize >= Bottom Then temp= Items.Size 
			Else
				X2=X2+MaxWidth+WhiteSpace
			End If
		End If
	Next
End Sub

Sub DrawTextItem(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, Color As Int)
	Dim TextSize As Int = LCAR.Fontsize , TextHeight As Int, L As String, R As String 
	If LCAR.TextWidth(BG, Text) > Width Then TextSize = API.GetTextHeight(BG, -Width, Text, LCAR.LCARfont)
	TextHeight = BG.MeasureStringHeight(Text, LCAR.LCARfont, TextSize)
	Y= Y + (Height*0.5) - (TextHeight * 0.5)
	If Text.Contains(":") Then
		L = API.GetSide(Text, ": ", True, False).Trim & ":"
		R = API.GetSide(Text, ": ", False, False).Trim
		LCAR.DrawText2(BG, X, Y, TextSize, L, Color, 0)
		LCAR.DrawText2(BG, X+Width, Y, TextSize, R, Color, 2)
	Else
		LCAR.DrawText2(BG, X + (Width*0.5), Y, TextSize, Text, Color, 1)
		TextSize = BG.MeasureStringWidth(Text, LCAR.LCARfont, TextSize)
		TextSize=(Width - TextSize) * 0.5 - 1
		LCAR.DrawRect(BG,X,Y, TextSize, TextHeight+1, Color, 0)
		LCAR.DrawRect(BG,X+Width-TextSize+2,Y, TextSize-2, TextHeight+1, Color, 0)
	End If
End Sub

Sub DrawGraphicalElbows(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int, LeftText As String, RightText As String, TextItems As List, SmallItems As List, HasArt As Boolean)  As Rect 
	Dim Corner  As Int = LCAR.ItemHeight * 0.1, Threat As Int = LCAR.ItemHeight *0.5, Today As Int , Color As Int = LCAR.GetColor(ColorID, False,Alpha), Ret As Rect 
	Dim temp As Int, ColWidth As Int, TextSize As Int, BW As Int = 5
	
	'text limiting
	LCAR.CheckNumbersize(BG)
	If LeftText.Length>0 Then	
		LeftText = API.LimitTextWidth(BG, LeftText.ToUpperCase, LCAR.LCARfont, LCAR.NumberTextSize, Width- Threat*2, "...")
		Today =  BG.MeasureStringWidth(LeftText, LCAR.LCARfont, LCAR.NumberTextSize)
		If RightText.Length >0 Then RightText = API.LimitTextWidth(BG, RightText.ToUpperCase, LCAR.LCARfont, LCAR.NumberTextSize, Width- Threat*2-Today, "...")
	End If
	
	'Elbows
	LCAR.DrawLCARelbow(BG,X,							Y,										LCAR.ItemHeight, 	Height-LCAR.ItemHeight,			BW, LCAR.ItemHeight, -2,  ColorID, False, LeftText, 0, Alpha,False)
	LCAR.DrawLCARelbow(BG,X+Width-LCAR.ItemHeight+1,	Y,										LCAR.ItemHeight, 	Height-LCAR.ItemHeight ,		BW, LCAR.ItemHeight, -3,  ColorID, False, RightText, 0, Alpha,False)
	LCAR.DrawLCARelbow(BG,X,							Y+Height-LCAR.ItemHeight -Corner*2,		Threat, 			LCAR.ItemHeight+Corner*2,		BW,	LCAR.ItemHeight, -4,  ColorID, False, "", 0, Alpha, False)
	LCAR.DrawLCARelbow(BG,X+Width-Threat+1,				Y+Height-LCAR.ItemHeight -Corner*2,		Threat, 			LCAR.ItemHeight+Corner*2+1,		BW,	LCAR.ItemHeight, -5,  ColorID, False, "", 0, Alpha, False)
	
	'Text items
	If HasArt Then temp = Width*0.5-7-Corner Else temp = Width-14-Corner*2
	DrawTextItems(BG, X+5+Corner, Y+LCAR.ItemHeight+Corner, temp, Height - LCAR.ItemHeight*2-Corner*2, TextItems, Alpha)
	
	'Rectangle in the top-middle
	If RightText.Length >0 Then Corner = BG.MeasureStringWidth(RightText, LCAR.LCARfont,LCAR.NumberTextSize) Else Corner = -4
	LCAR.DrawRect(BG, X + Threat + 2 + Today, Y, Width - Threat*2-Corner-Today-4, LCAR.ItemHeight, Color, 0)
	
	'Return the art dimensions
	If HasArt Then Ret = LCARSeffects4.SetRect( X + Width*0.5 + Corner, Y + LCAR.ItemHeight + Corner, Width*0.5- Corner*2, Height- LCAR.ItemHeight *2 -  Corner* 2)
	'move to new location
	X= X+ Threat+1
	Y = Y + Height - LCAR.ItemHeight
	Width = Width - Threat*2
	Height = LCAR.ItemHeight-1
	
	'items along the bottom
	If SmallItems.Size = 0 Then
		LCARSeffects4.DrawRect(BG, X-2,Y, Width+2, Height, Color, 0)
	Else
		ColWidth= Width / SmallItems.Size
		TextSize = API.GetTextHeight(BG, Height*0.5-2, "1234567890/°KFC" , LCAR.lcarfont)
		For temp = 0 To SmallItems.Size -1 
			If Not(LCAR.LessRandom) Then Color = LCAR.GetColor(LCAR.LCAR_RandomColor, False,Alpha)
			LeftText = SmallItems.Get(temp)
			If LeftText.Contains("(") And LeftText.Contains(")") Then 
				RightText = Eval.GetFromBrackets(LeftText,False)
				LeftText = API.RemoveBrackets(LeftText,0)
				If RightText.Contains(":") Then 
					If API.Left(RightText, 7).EqualsIgnoreCase("colorid") Then 'If Y + Linesize <= Bottom Then 
						RightText= API.Right(RightText, RightText.Length - 7).Replace(":", "").Trim 
						If IsNumber(RightText) Then Color = LCAR.GetColor(RightText,False,Alpha)
					End If 
				End If 
			End If
			LCARSeffects4.DrawRect(BG, X,Y, ColWidth-2, Height, Color, 0)
			API.DrawTextAligned(BG, LeftText, X + ColWidth*0.5, Y+ Height*0.5, 0, LCAR.LCARfont, TextSize, Colors.black, 5, 0, 0)
			X=X+ColWidth
		Next
	End If
	Return Ret
End Sub

Sub DrawGraphicalWeather(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, CurrentWeather As WeatherData, StardateMode As Int, Alpha As Int)
	Dim Date As Long = DateTime.Now , Items As List, tempDay As WeatherDay, Today As Int, S As String = " ", HasData As Boolean ,Corner  As Int = LCAR.ItemHeight * 0.1
	Dim Temperature As String = "?", Threat As Int
	
	Items.Initialize 
	Items.Add("")
	Items.Add(Weather.ProviderName(-1))
	If Weather.HasWeatherData(CurrentWeather) Then
		Today = Weather.FindToday(CurrentWeather)
		If Today>-1 Then
			tempDay = CurrentWeather.days.Get(Today)
			Items.Add("HIGH: " & Round(Trig.ConvertUnits( 0, tempDay.Maximum, "C", Weather.CurrentUnits)) & S & CurrentWeather.Units)
			Items.Add("LOW: " & Round(Trig.ConvertUnits( 0, tempDay.Minimum, "C", Weather.CurrentUnits))  & S & CurrentWeather.Units)
			If tempDay.Speed>0 Then Items.Add("WIND: " & Round2(tempDay.Speed,2) & S & CurrentWeather.UnitsSpeed)
			If tempDay.Rain>0 Then Items.Add("RAIN: " & Round2(tempDay.Rain,2) & S & CurrentWeather.UnitsDistance)
			If tempDay.Snow>0 Then Items.Add("SNOW: " & Round2(tempDay.Snow,2) & S & CurrentWeather.UnitsDistance)
			If tempDay.Humidity > 0 Then Items.Add("HUMIDITY: " & Round(tempDay.Humidity) & "%")
			If tempDay.Clouds >0 Then Items.Add("CLOUDS: " & Round(tempDay.Clouds) & "%")
			If tempDay.Pressure >0 Then Items.Add("PRESSURE: " & Round2(tempDay.Pressure,2) & S & CurrentWeather.UnitsPressure)
			Temperature = Round(Trig.ConvertUnits( 0,Weather.CurrentTemperature(tempDay), "C", Weather.CurrentUnits)) & S & CurrentWeather.Units
			HasData=True
			
			Threat = LCAR.GetColor( API.IIF(LCAR.LessRandom, ColorID, LCAR.LCAR_RandomColor),False,Alpha)
			Items.Add(DrawWeatherIcon(BG, X + Width*0.5 + Corner, Y + LCAR.ItemHeight + Corner, Width*0.5- Corner*2, Height- LCAR.ItemHeight *2 -  Corner* 2, tempDay,Threat ))' LCAR.GetColor(LCAR.LCAR_RandomColor,False,Alpha) ))'Colors.Transparent))
		End If
	End If
	If Not(HasData) Then NoData(Items)
	
	Threat=LCAR.ItemHeight *0.5
	S=LCAR.StarDate(StardateMode, Date, True, 0)
	LCAR.DrawLCARelbow(BG,X,							Y,										LCAR.ItemHeight, Height-LCAR.ItemHeight,		5 , LCAR.ItemHeight, -2,  ColorID, False, S, 0, Alpha,False)
	LCAR.DrawLCARelbow(BG,X+Width-LCAR.ItemHeight+1,	Y,										LCAR.ItemHeight, Height-LCAR.ItemHeight ,		5 , LCAR.ItemHeight, -3,  ColorID, False, Temperature, 0, Alpha,False)
	LCAR.DrawLCARelbow(BG,X,							Y+Height-LCAR.ItemHeight -Corner*2,		Threat, LCAR.ItemHeight+Corner*2,		5,LCAR.ItemHeight, -4, ColorID,False, "", 0, Alpha, False)
	LCAR.DrawLCARelbow(BG,X+Width-Threat+1,	Y+Height-LCAR.ItemHeight -Corner*2,		Threat, LCAR.ItemHeight+Corner*2+1,	5,LCAR.ItemHeight, -5, ColorID,False, "", 0, Alpha, False)
	DrawTextItems(BG, X+5+Corner, 						Y+LCAR.ItemHeight+Corner, Width/2-7-Corner, Height - LCAR.ItemHeight*2-Corner*2, Items, Alpha)
	
	
	Corner=1
	DrawWeatherIcons(BG, X+ Threat+Corner, Y + Height - LCAR.ItemHeight , Width - Threat*2, LCAR.ItemHeight-1, CurrentWeather, Today, Alpha, LCAR.LCAR_Orange )
	
	Today = BG.MeasureStringWidth(S, LCAR.LCARfont, LCAR.NumberTextSize)
	Corner = BG.MeasureStringWidth(Temperature, LCAR.LCARfont,LCAR.NumberTextSize)
	LCAR.DrawRect(BG, X + Threat + 2 + Today, Y, Width - Threat*2-Corner-Today-4, LCAR.ItemHeight, LCAR.GetColor(ColorID,False,Alpha), 0)
End Sub
Sub DrawWeatherIcons(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CurrentWeather As WeatherData, Today As Int,Alpha As Int, ColorID As Int)
	Dim Days As Int, ColWidth As Int,Border As Int, DoImage As Boolean, Color As Int = LCAR.GetColor(ColorID, False,Alpha),Size As Point ,TextSize As Int ', ColWidth2 As Int
	Dim DaysOfWeek() As String = Array As String("SUN","MON","TUE","WED","THU","FRI","SAT"), CurrentDay As WeatherDay , Text As String 
	If Weather.HasWeatherData(CurrentWeather) Then Days = CurrentWeather.Days.Size - Today - 1
	If Days=0 Then 
		LCARSeffects4.DrawRect(BG, X-2,Y, Width+2, Height, Color, 0)
	Else
		ColWidth= Width / Days
		Size = API.Thumbsize(168,141, ColWidth-4, Height-2, False,False)
		If Size.X > ColWidth * 0.5 Then 'image is too big to fit
			'ColWidth2=ColWidth-2
		Else
			Border = (Height - Size.Y) / 2
			'ColWidth2 = ColWidth - Size.X-Border
			DoImage=True
		End If
		TextSize = API.GetTextHeight(BG, Height*0.5-2, "1234567890/°KFC" , LCAR.lcarfont)
		For temp = Today + 1 To CurrentWeather.Days.Size -1 
			If Not(LCAR.LessRandom) Then Color = LCAR.GetColor(LCAR.LCAR_RandomColor, False,Alpha)
			LCARSeffects4.DrawRect(BG, X,Y, ColWidth-2, Height, Color, 0)
			CurrentDay =  CurrentWeather.Days.Get(temp)
			If DoImage Then DrawWeatherIcon(BG,  X + ColWidth - 2- Border - Size.X,       Y,     Size.X,Height,         CurrentDay, Color )' Colors.black) 
			API.DrawTextAligned(BG,  DaysOfWeek( DateTime.GetDayOfWeek(CurrentDay.date)-1), X + (ColWidth - Border - Size.X)*0.5, Y+1, 0, LCAR.LCARfont, TextSize, Colors.black, 8, 0, 0)
			Text= Round(Trig.ConvertUnits( 0, CurrentDay.Minimum, "C", Weather.CurrentUnits) ) & "°/" & Round(Trig.ConvertUnits( 0, CurrentDay.Maximum, "C", Weather.CurrentUnits) )    & "°"
			If BG.MeasureStringWidth(Text, LCAR.LCARfont, TextSize) > ColWidth - Border - Size.X Then Text = Round(Trig.ConvertUnits( 0, (CurrentDay.Minimum + CurrentDay.Maximum) / 2, "C", Weather.CurrentUnits) ) & "°"
			API.DrawTextAligned(BG, Text , X + (ColWidth - Border - Size.X)*0.5, Y+ Height*0.5, 0, LCAR.LCARfont, TextSize, Colors.black, 8, 0, 0)
			X=X+ColWidth
		Next
	End If
End Sub
Sub DrawWeatherIcon(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CurrentDay As WeatherDay, BGColor As Int) As String 
	Dim tempIcon As WeatherIcon, S As String , Threat As Int , BMP As Bitmap ,Size As Point , Dest As Rect 
	tempIcon= CurrentDay.Icons.Get(0)
	S = tempIcon.Icon 
	If Not (S.Contains(".png")) Then S = S & ".png"
	If Not(File.Exists(File.DirAssets, S)) Then
		S = S.Replace("n", "d")
		If Not(File.Exists(File.DirAssets, S)) Then
			Threat = Weather.IsDangerous(tempIcon)
			BGColor = LCAR.GetColor(  API.IIFIndex(Threat, Array As Int( LCAR.Classic_Green, LCAR.LCAR_Yellow, LCAR.LCAR_RedAlert )),False,255)
			S = "alert.png"
		End If
	End If
	BMP.Initialize(File.DirAssets, S)
	Size=API.Thumbsize(BMP.Width, BMP.Height, Width,Height, True,False)
	Dest = LCARSeffects4.setrect(X + Width*0.5  - Size.X*0.5, Y+ Height *0.5 - Size.Y *0.5, Size.X, Size.Y)
	If BGColor <> Colors.Transparent Then BG.DrawRect(Dest, BGColor,True,0)
	BG.DrawBitmap(BMP, Null, Dest)
	'Size = API.Thumbsize(BMP.Width, BMP.Height, Width/2-7-Corner, Height - LCAR.ItemHeight*2-Corner*2, True,False)
	'BG.DrawBitmap(BMP, Null, LCARSeffects4.setrect(X + Width*0.75-7-Corner -Size.X/2, Y+ Height/2-Size.Y/2, Size.x, Size.Y))
	
	Return "W: " & tempIcon.Description.ToUpperCase
End Sub

'1=Android Red, 2=LCAR_Red False, 3=LCAR_Red True, 4=Yellow, 5=Orange, 6=Red, 7=Blue
Sub KlingonColor(ColorID As Int, Alpha As Int) As Int 
	Select Case ColorID
		Case 1: Return Colors.argb(Alpha, 255,0,0)'red
		Case 2: Return LCAR.getcolor(LCAR.LCAR_Red, False, Alpha)'LCAR_Red false
		Case 3: Return LCAR.getcolor(LCAR.LCAR_Red, True, Alpha)'LCAR_Red true
		Case 4: Return Colors.argb(Alpha, 222,244,57)'yellow
		Case 5: Return Colors.argb(Alpha, 235,196,65)'orange
		Case 6: Return Colors.argb(Alpha, 246,123,107)'another red
		Case 7: Return Colors.argb(Alpha, 192,232,223)'light blue
	End Select
End Sub
'Color: -1=Android Red, -2=LCAR_Red False, -3=LCAR_Red True, -4=Yellow, -5=Orange, -6=Red, -7=Blue
Sub DrawKlingonFrame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, BlackAlpha As Int, ExtendLeft As Boolean, ExtendRight As Boolean, Tag As String)
	Dim temp As Int, tempstr() As String = Regex.split(CRLF, Tag), MiddleWidth As Int = BG.MeasureStringWidth(" A ", LCARSeffects2.KlingonFont, ENTfontsize) * 0.5, LineSize As Int = BG.MeasureStringHeight("A123", LCARSeffects2.KlingonFont, LCAR.fontsize)+2, LineID As Int
	If ExtendLeft Then 
		temp = 6 * LCAR.scalefactor
		X = X- temp 
		Width = Width + temp 
	End If
	If ExtendRight Then 
		temp = 20 * LCAR.scalefactor
		Width = Width + temp 
	End If
	Dim LeftEdge As Int = Width * 0.08, CenterX As Int = X + Width * 0.5, CenterY As Int = Y + Height * 0.5, Bottom As Int = Y + Height, Right As Int = X + Width, BottomHeight As Int = LCAR.ItemHeight*0.5, SlantEdge As Int = BottomHeight*0.5, Size As Int = 20, WhiteSpace As Int = 2
	If Color < 0 Then Color = KlingonColor(Abs(Color), BlackAlpha)
	If BlackAlpha>0 Then LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.argb(BlackAlpha, 0,0,0), 0)
	DrawShape(BG, Array As Int(X + LeftEdge, Y,  CenterX-Size, Y,	X + LeftEdge + Size, Y + Size), Color, 0)'Top left
	DrawShape(BG, Array As Int(Right-LeftEdge, Y,  CenterX+Size, Y,	Right - LeftEdge - Size, Y + Size), Color, 0)'Top Right
	
	DrawShape(BG, Array As Int(X, CenterY,  X + LeftEdge, Bottom,	X + LeftEdge + SlantEdge, Bottom - BottomHeight ), Color, 0)'bottom left
	DrawShape(BG, Array As Int(Right, CenterY,  Right - LeftEdge, Bottom,	Right - LeftEdge - SlantEdge, Bottom - BottomHeight ), Color, 0)'bottom right
	DrawKlingonBottom(BG, X + LeftEdge + WhiteSpace, Bottom - BottomHeight, Width- LeftEdge*2 - WhiteSpace*2, BottomHeight, Color, SlantEdge)'Bottom middle
	
	'Center line of big text
	For temp = Bottom-BottomHeight*2-4 To Y+ENTSize Step -ENTSize
		BG.DrawText(API.Right(temp, 1), CenterX, temp, LCARSeffects2.KlingonFont, ENTfontsize, KlingonColor(temp Mod 6 + 1, BlackAlpha), "CENTER")
	Next
	
	'Sides of small text
	For temp = Bottom-BottomHeight*2-4 To Y+LineSize Step -LineSize
		If tempstr.Length>LineID Then BG.DrawText( tempstr(LineID),  CenterX - MiddleWidth, temp, LCARSeffects2.KlingonFont, LCAR.fontsize, Color, "RIGHT")
		If tempstr.Length>LineID+1 Then BG.DrawText( tempstr(LineID+1),  CenterX + MiddleWidth, temp, LCARSeffects2.KlingonFont, LCAR.fontsize, Color, "LEFT")
		LineID=LineID+1
	Next
	
	'						  left middle       left top							middle top		right top								right middle		right bottom												left bottom
	DrawShape(BG, Array As Int(X, CenterY,		X + LeftEdge + Size, Y + Size,		CenterX,Y,		Right - Size-LeftEdge, Y + Size,		Right,CenterY,		Right - LeftEdge - SlantEdge, Bottom - BottomHeight,		X + LeftEdge + SlantEdge, Bottom - BottomHeight), 0, -1)
	BottomHeight=BottomHeight*2
	DrawSeptagrid(BG,X,Y,Width,Height, BottomHeight*0.75, BottomHeight, Color, 2)
	BG.RemoveClip
	
	WhiteSpace=4'					0		1						2								3		4										5			6						7
	'						   		Bottom left (0,1)				top left (2,3)							top right (4,5)										bottom right (6,7)
	DrawKlingonEdge(BG, Array As Int(X, 	CenterY-WhiteSpace,		X + LeftEdge - WhiteSpace, 		Y, 		X + LeftEdge + Size - WhiteSpace, 		Y+Size,		X+Size+WhiteSpace, 		CenterY-Size), Color, True, WhiteSpace, Size, LeftEdge)
	DrawKlingonEdge(BG, Array As Int(Right, CenterY-WhiteSpace,		Right - LeftEdge + WhiteSpace, 	Y, 		Right - LeftEdge - Size + WhiteSpace, 	Y+Size,		Right-Size-WhiteSpace, 	CenterY-Size), Color, False, WhiteSpace, Size, LeftEdge)
End Sub
Sub DrawKlingonEdge(BG As Canvas, Points() As Int, Color As Int, IsLeft As Boolean, WhiteSpace As Int, Edge As Int, BigEdge As Int)
	Dim Left As Int, Right As Int, Top As Int, Bottom As Int, Width As Int, Height As Int, P As Path, temp As Int, P2 As Path, P3 As Path, P4 As Path
	If IsLeft Then 
		Left = Points(0)
		Right = Left+BigEdge+Edge'Points(6)
	Else 
		Left = Points(2) - Edge
		Right = Points(0)
	End If
	Top = Points(3)
	Bottom = Points(7)
	Width = Right-Left 
	Height = Bottom-Top
	DrawShape(BG, Points, Colors.blue, -1)
	
	'at 0.2168674698795181, 0.3012048192771084, 0.7469879518072289, 0.8433734939759036
	temp=Top+Height*0.20

	P.Initialize(Left,Top)
	P.LineTo(Right, Top)
	MakePoints(P, Left, temp, Width, Edge, IsLeft, False)
	BG.DrawPath(P, Color, True, 0)
		
	MakePoints(P2, Left, temp+WhiteSpace, Width, Edge, IsLeft, False)
	temp=Top+Height*0.30
	MakePoints(P2, Left, temp, Width, Edge, IsLeft, True)
	BG.DrawPath(P2, Color, True, 0)
	
	MakePoints(P3, Left, temp+WhiteSpace, Width, Edge, IsLeft, False)
	temp=Top+Height*0.75
	MakePoints(P3, Left, temp, Width, Edge, IsLeft, True)
	BG.DrawPath(P3, Color, True, 0)
	
	MakePoints(P4, Left, temp+WhiteSpace, Width, Edge, IsLeft, False)
	If IsLeft Then 
		P4.LineTo(Left,Bottom+Edge)
		P4.LineTo(Right,Bottom)
	Else 
		P4.LineTo(Left,Bottom)
		P4.LineTo(Right,Bottom+Edge)
	End If 
	BG.DrawPath(P4, Color, True, 0)
	
	BG.RemoveClip
End Sub
Sub MakePoints(P As Path, X As Int, Y As Int, Width As Int, Size As Int, IsLeft As Boolean, Flip As Boolean)
	If IsLeft Then 
		If Flip Then 
			MakePoint(P, X, Y-Size)
			MakePoint(P, X+Width, Y)
		Else 
			MakePoint(P, X+Width, Y)
			MakePoint(P, X, Y-Size)
		End If 
	Else 
		If Flip Then 
			MakePoint(P, X, Y)
			MakePoint(P, X+Width, Y-Size)
		Else 
			MakePoint(P, X+Width, Y-Size)
			MakePoint(P, X, Y)
		End If 
	End If
End Sub
Sub DrawSeptagrid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SizeX As Int, SizeY As Int, Color As Int, Stroke As Int)
	Dim Edge As Int = SizeX * 0.25, Right As Int = X + Width, X2 As Int = X, Bottom As Int = Y + Height, OffsetX As Int = SizeX-Edge, OffsetY As Int = SizeY*1.5, LineWidth As Int = SizeX*2-Edge*2
	Y = Y - SizeY*0.5
	Do Until Y >= Bottom 
		X = X2 
		Do Until X >= Right 
			DrawSelectagon(BG,X,Y,SizeX,SizeY,Edge, Color, Stroke, False, False, False, True, False, True)'Top left
			DrawSelectagon(BG,X,Y+SizeY,SizeX,SizeY,Edge, Color, Stroke, True, True, True, True, True, True)'Bottom left
			DrawSelectagon(BG,X+OffsetX, Y+OffsetY, SizeX,SizeY, Edge, Color, Stroke, False, True, False, True, True, True)'Bottom right 
			X = X + LineWidth
		Loop 
		Y = Y + SizeY * 2
	Loop
End Sub
Sub DrawSelectagon(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Edge As Int, Color As Int, Stroke As Int, TL As Boolean, Top As Boolean, TR As Boolean, BL As Boolean, Bot As Boolean, BR As Boolean)
	Dim CenterY As Int = Y + Height * 0.5, LeftEdge As Int = X + Edge, RightEdge As Int = X+Width-Edge, Bottom As Int = Y + Height
	If TL Then BG.DrawLine(X, CenterY, LeftEdge, Y, Color, Stroke)'/ (Top-left)
	If Top Then BG.DrawLine(LeftEdge, Y, RightEdge, Y, Color, Stroke)'- (Top) 
	If TR Then BG.DrawLine(RightEdge, Y, X+Width, CenterY, Color, Stroke)'\(Top-right)
	If BR Then BG.DrawLine(X+Width, CenterY, RightEdge, Bottom, Color, Stroke)'/(Bottom-right)
	If Bot Then BG.DrawLine(LeftEdge, Bottom, RightEdge, Bottom, Color, Stroke)'- (Bottom) 
	If BL Then BG.DrawLine(LeftEdge, Bottom, X, CenterY, Color, Stroke)'\(Bottom-left)
End Sub

Sub DrawKlingonBottom(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Edge As Int)
	Dim ItemWidth As Int = Height * 3, Items As Int = Max(1, Floor(Width / ItemWidth)), temp As Int, HalfWay As Int = Items * 0.5, WhiteSpace As Int = 4, SliceWidth As Int, HasDone As Boolean, HalfWidth As Int
	X=X+WhiteSpace
	Width = Width - WhiteSpace
	ItemWidth = Width / Items
	SliceWidth = ItemWidth * 0.1
	HalfWidth = ItemWidth*0.5
	For temp = 1 To Items
		If temp = 1 Then 
			DrawSmallKlingonTriangle(BG, X+Edge*2, Y-Height - WhiteSpace*2, HalfWidth, Height, Color)
			DrawSmallKlingonButton(BG, X+ItemWidth-SliceWidth-Edge,Y,SliceWidth-WhiteSpace+Edge,Height, Color, Edge, True,True, "")
			DrawSmallKlingonButton(BG, X,Y,ItemWidth-WhiteSpace-SliceWidth,Height, Color, Edge, True,True, "LE")
		Else if temp <= HalfWay Then 
			DrawSmallKlingonButton(BG, X-Edge,Y,ItemWidth-WhiteSpace+Edge,Height, Color, Edge, True, True, "A" & temp)
		else if HasDone Then 
			DrawSmallKlingonButton(BG, X-Edge,Y,ItemWidth-WhiteSpace+Edge,Height, Color, Edge, False, False, "B" & temp)
		Else 
			DrawSmallKlingonButton(BG, X-Edge,Y,ItemWidth-WhiteSpace+Edge,Height, Color, Edge, True, False, "MI")
			HasDone=True 
		End If
		If temp > 1 Then DrawSmallKlingonTriangle(BG, X+Edge, Y-Height - WhiteSpace*2, HalfWidth, Height, Color)
		X=X+ItemWidth
	Next
End Sub
Sub DrawSmallKlingonTriangle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	DrawShape(BG, Array As Int(X,Y+Height, X+Width*0.5,Y, X+Width,Y+Height), Color, 0)
End Sub
Sub DrawSmallKlingonButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Edge As Int, Left As Boolean, Right As Boolean, Text As String)
	Dim P As Path 
	If Left Then '/
		P.Initialize(X, Y + Height)'bottom left
		P.LineTo(X+Edge, Y)'top left
	Else '\
		P.Initialize(X+Edge, Y + Height)'bottom left
		P.LineTo(X, Y)'top left
	End If
	If Right Then '/
		P.LineTo(X+Width, Y)'top right
		P.LineTo(X+Width-Edge,Y+Height)'bottom right
	Else '\
		P.LineTo(X+Width-Edge, Y)'top right
		P.LineTo(X+Width,Y+Height)'bottom right
	End If
	BG.DrawPath(P, Color, True, 0)
	If Text.Length>0 Then BG.DrawText(Text, X+ Width * 0.5, Y + Height - 4, LCARSeffects2.KlingonFont, LCAR.Fontsize*0.75, Colors.Black, "CENTER")
End Sub

'Stroke: -1=clippath, 0=fill, else=stroke
Sub DrawShape(BG As Canvas, Points() As Int, Color As Int, Stroke As Int)
	Dim P As Path, temp As Int 
	P.Initialize(Points(0), Points(1))
	For temp = 2 To Points.Length - 1 Step 2
		P.LineTo(Points(temp), Points(temp+1))
	Next
	If Stroke = -1 Then 
		BG.ClipPath(P)
	Else
		BG.DrawPath(P, Color, Stroke=0,Stroke)
	End If 
End Sub

'Align: 0=top hor, 1=right ver, 2=down hor, 3=left ver
Sub DrawKlingonMeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BlackAlpha As Int, Align As Int, Value As Int, Tag As String) 
	Dim Radius As Int, Positions() As String = Regex.Split(",", Tag), temp As Int 
	If Not(Wireframe.SVGFile.EqualsIgnoreCase("klingon")) Then' Wireframe.LoadCardassianINI(0, "klingon")
		Radius = Min(LCAR.ScaleWidth, LCAR.ScaleHeight)
		Wireframe.SetupCadassianSVGs(0, Radius,Radius, "klingon")
	End If
	If Align = 3 Or Align = 1 Then 
		If BlackAlpha>0 Then LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.argb(BlackAlpha, 0,0,0), 0)
		'SVGids: 0=Big red and lines (red,1), 1=bottom and right diamond (blue,7), 2=right comb and claws (orange,5)
		'Colors: 1=Android Red, 2=LCAR_Red False, 3=LCAR_Red True, 4=Yellow, 5=Orange, 6=Red, 7=Blue
		Wireframe.DrawSVGwh(BG,X,Y,Width,Height,0, KlingonColor(1, BlackAlpha), False, BlackAlpha, 0, LCARSeffects2.KlingonFont, 10, False, False, 0.1)'Big red and lines (red,1)
		Wireframe.DrawSVGwh(BG,X,Y,Width,Height,1, KlingonColor(7, BlackAlpha), False, BlackAlpha, 0, LCARSeffects2.KlingonFont, 10, False, False, 0.1)'bottom and right diamond (blue,7)
		Wireframe.DrawSVGwh(BG,X,Y,Width,Height,2, KlingonColor(5, BlackAlpha), False, BlackAlpha, 0, LCARSeffects2.KlingonFont, 10, False, False, 0.1)'right comb and claws (orange,5)
		
		'0.3507340946166395 to 0.7601957585644372, 14*9 of 63*171 (0.3255813953488372 * 0.0526315789473684)
		Value = 100 - Value
		temp = Y + (Height * 0.35) + (Height * Value * 0.004)'0.01 * 0.40)
		Wireframe.DrawSVGwh(BG,X, temp, Width * 0.32, Height * 0.05, 3, KlingonColor(4, BlackAlpha), False, BlackAlpha, 0, LCARSeffects2.KlingonFont, 10, False, False, 0.1)'cursor (yellow,4)
		
		If Positions.Length > 0 Then 
			BG.DrawText(Positions(0), X + Width, Y + Height, LCARSeffects2.KlingonFont, ENTfontsize, KlingonColor(1, BlackAlpha), "RIGHT")
			temp = Width * 0.375
			X = X + Width - temp
			Width = temp * 0.15
			BlackAlpha = KlingonColor(6, BlackAlpha)
			BG.DrawCircle(X, Y + Height * (Positions(1) * 0.1), Width, BlackAlpha, True, 0)
			BG.DrawCircle(X, Y + Height * (Positions(2) * 0.1), Width, BlackAlpha, True, 0)
			DrawDiamond(BG,X, Y + Height * (Positions(3) * 0.1), temp,temp, BlackAlpha,0)
			DrawDiamond(BG,X, Y + Height * (Positions(4) * 0.1), temp,temp, BlackAlpha,0)
			If Positions.Length>5 Then DrawDiamond(BG,X, Y + Height * (Positions(5) * 0.1), temp,temp, BlackAlpha,0)
		End If 
	End If  
End Sub
Sub DrawDiamond(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)'24*24 of 64*172 (0.375*width)
	Dim CenterX As Int = X + Width * 0.5, CenterY As Int = Y + Height * 0.5, Right As Int = X + Width, Bottom As Int = Y + Height 
	DrawShape(BG, Array As Int(X,CenterY,	CenterX,Y,		Right,CenterY,		CenterX, Bottom), Color, Stroke)
End Sub
Sub RandomKlingonText(BG As Canvas, Width As Int, Height As Int) As String 
	Dim tempstr As StringBuilder, LineHeight As Int, A As Int = Asc("A")
	tempstr.Initialize
	If Width = -1 And Height = -1 Then 'meter
		Return Chr(A + Rnd(0,26)) & "," & Rnd(1,10) & "," & Rnd(1,10) & "," & Rnd(1,10) & "," & Rnd(1,10) & API.IIF(Rnd(0,10)>5, "," & Rnd(1,10), "")
	Else if Height = -1 Then'frame line
		LineHeight = BG.MeasureStringWidth("A", LCARSeffects2.KlingonFont, LCAR.Fontsize)
		Do Until Width < LineHeight
			Height = Rnd(0,40)
			If Height > 25 Then 
				tempstr.Append(" ")
			Else 
				tempstr.Append(Chr(A + Height))
			End If
			Width = Width - LineHeight
		Loop
	Else 'frame all
		Width = Width * 0.34 - BG.MeasureStringWidth("A", LCARSeffects2.KlingonFont, ENTfontsize) 
		Height = Height - LCAR.ItemHeight*1.5
		LineHeight = BG.MeasureStringHeight("0123", LCARSeffects2.KlingonFont, LCAR.Fontsize)
		Do Until Height < LineHeight
			tempstr.Append( RandomKlingonText(BG,Width, -1) & CRLF & RandomKlingonText(BG,Width, -1) & CRLF)
			Height = Height - LineHeight
		Loop
	End If
	Return tempstr.ToString
End Sub