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

	'Ferengi stuff
	Type FerengiGrid(ScreenID As Int, X As Int, Y As Int, Xs As Float, Ys As Float, SpeedX As Int, SpeedY As Int, Width As Int, Height As Int, Chars As List, Hold As Int, TextDirection As Int, TextAlign As Int, EndPoint As Point)
	Dim FerengiFont As Typeface = Typeface.LoadFromAssets("ferengi.ttf")
	Dim FerengiLines As List, FerengiSize As Point  
	
	'Operations widget stuff
	Dim OperationsBMP As Bitmap
End Sub

'TextDirection: 0=||, 1=\\, 2=//
Sub NewText(TextDirection As Int, Characters As Int) As String 
	Dim tempstr As StringBuilder, Lower As Int, Higher As Int 
	tempstr.Initialize
	Select Case TextDirection
		Case 0'|| = 0123456789
			Lower = Asc("0")
			Higher = Asc("9")
		Case 1'\\ = abcdefghijklmnopqrstuvwxyz
			Lower = Asc("a")
			Higher = Asc("z")
		Case 2'// = ABCDEFGHIJKLMNOPQRSTUVWXYZ
			Lower = Asc("A")
			Higher = Asc("Z")
	End Select
	Do Until Characters < 1 
		tempstr.Append(Chr(Rnd(Lower,Higher+1)))
		Characters = Characters - 1
	Loop
	Return tempstr.ToString
End Sub

'CharType: -1=" " (space), 0=||, 1=\\, 2=//
public Sub ShiftLines(fGrid As FerengiGrid, AtStart As Boolean, Chars As Int, CharType As Int)
	Dim temp As Int, Character As String 
	For temp = 1 To Chars
		If CharType = -1 Then 
			Character = " "
		Else
			Character = NewText(CharType, 1)
		End If
		If AtStart Then 
			fGrid.Chars.InsertAt(0, Character)
			fGrid.Chars.RemoveAt(fGrid.Chars.Size - 1)
		Else 
			fGrid.Chars.RemoveAt(0)
			fGrid.Chars.Add(Character)
		End If 
	Next
End Sub

'Leave text blank to automatically generate it from the fGrid, X/Y/Direction = -1 will be randomized
public Sub OverlayText(Text As String, fGrid As FerengiGrid, X As Int, Y As Int, Direction As Int)
	Dim temp As Int = Max(fGrid.Width, fGrid.height) * 0.5, Index As Int
	If x = -1 Then x = Rnd(0, fGrid.Width)
	If y = -1 Then y = Rnd(0, fGrid.height*0.5)
	If Direction = -1 Then Direction = 2 + Rnd(0,4)*2'2,4,6 or 8
	If Text.Length = 0 Then 
		Select Case Direction
			Case 4,6: Text = NewText(fGrid.TextDirection, fGrid.Width*0.5)
			Case 8,2: Text = NewText(fGrid.TextDirection, fGrid.height*0.5)
			Case Else: Text = NewText(fGrid.TextDirection, temp)
		End Select
	End If
	For temp = 0 To Text.Length-1 
		Index = Y*fGrid.Width + X
		If fGrid.Chars.Get(Index) = " " Then 
			fGrid.Chars.Set( Index, API.Mid(Text, temp,1) )
		End If 
		Select Case Direction
			Case 7,4,1:X=X-1'left
			Case 9,6,3:X=X+1'right
		End Select
		Select Case Direction
			Case 7,8,9:Y=Y-1'up
			Case 1,2,3:Y=Y+1'down
		End Select
		If x <0 Or y < 0 Or x = fGrid.Width Or y = fGrid.Height Then temp = Text.Length 
	Next
End Sub

'TextDirection: 0=||, 1=\\, 2=//, OverlayDirection: numpad (-1=random), TextAlign: 1=left,2=center,3=right
Sub NewScreen(ScreenID As Int, SpeedX As Int, SpeedY As Int, Width As Int, Height As Int, TextDirection As Int, OverlayDirection As Int, X As Float, Y As Float, TextAlign As Int)
	Dim fGrid As FerengiGrid, temp As Int = Width * Height 
	fGrid.Initialize
	fGrid.Chars.Initialize
	Do Until fGrid.Chars.Size = temp 
		fGrid.Chars.Add(" ")
	Loop
	fGrid.Height   	= Height
	fGrid.ScreenID 	= ScreenID
	fGrid.SpeedX   	= SpeedX
	fGrid.SpeedY   	= SpeedY
	fGrid.Width    	= Width 
	fGrid.Hold 	  	= -Rnd(1, 5)
	fGrid.Xs	   	= X
	fGrid.Ys	   	= Y
	fGrid.TextAlign = TextAlign
	fGrid.TextDirection = TextDirection
	OverlayText(NewText(TextDirection, Max(Width,Height)), fGrid, 0, 0, OverlayDirection)'Rnd(0,Width), Rnd(0,Height)
	FerengiLines.Add(fGrid)
End Sub

Sub IncrementFerengi(Element As LCARelement) As Boolean
	Dim CurrentSecond As Int = DateTime.GetSecond(DateTime.Now), CurrentMilli As Int = API.GetMS, temp As Int, fGrid As FerengiGrid, CurrentQuadrant As Int = Floor(CurrentMilli / 250), IsNewQuadrant As Boolean, CharSize As Int = 10, IsGen As Boolean 
	If Element.LWidth= -1 Then 'Initialize
		Element.RWidth = Rnd(0,360)
		FerengiLines.Initialize
		
		'Middle Screen
		NewScreen(0, 1, 0, 15, 1, 0, 6, 0, 0.72, 3)'---
		NewScreen(0, 0, 1, 1, 11, 0, 2, 0.5, 0, 2)'|
		NewScreen(0, 0, 1, 1, 11, 1, 2, 0.04, 0, 1)'\
		NewScreen(0, 0, 1, 1, 11, 2, 2, 0.96, 0, 3)'/
		
		NewScreen(1, 0, -1, 14, 11, 0, -1, 0,1, 1)'upper
		NewScreen(2, 0, 1, 14, 11, 0, -1,  0,0, 1)'lower
		
		NewScreen(3, 0, 1, 14, 11, 2, -1,  0.5,0, 1)'lower left
		NewScreen(4, 0, 1, 14, 11, 1, -1,  -0.5,0, 3)'lower Right
		
		NewScreen(5, 0, -1, 14, 11, 1, -1,  0.5,1, 3)'upper left
		NewScreen(6, 0, -1, 14, 11, 2, -1,  -0.5,1, 1)'upper Right
	End If
	If CurrentSecond <> Element.LWidth Then 'new second 
		Element.LWidth = CurrentSecond
		'IsNewSecond = True 
	End If
	If CurrentQuadrant <> Element.TextAlign Then 'new 1/4 of second
		Element.TextAlign = CurrentQuadrant
		IsNewQuadrant = True 
	End If
	
	For temp = 0 To FerengiLines.Size-1
		fGrid = FerengiLines.Get(temp)
		IsGen = False 
		'If fGrid.Hold=0 Then 
		If fGrid.Hold > 0 Then 'generate random text
			If IsNewQuadrant Then 
				fGrid.Hold = fGrid.Hold - 1
				OverlayText("", fGrid, -1,-1, -1)'Generate random text
				If fGrid.Hold = 0 Then 
					fGrid.Hold = -Rnd(1,5)
				End If 
			End If 
		else if fGrid.Hold < 0 Then 'animate 
			fGrid.X = fGrid.X + fGrid.SpeedX
			If fGrid.X >= CharSize Or fGrid.X <= -CharSize Then 
				fGrid.X = 0
				fGrid.Hold = fGrid.Hold + 1
				IsGen = True 
			End If 
			
			fGrid.Y = fGrid.Y + fGrid.SpeedY
			If fGrid.Y >= CharSize Or fGrid.Y <= -CharSize Then 
				fGrid.Y = 0
				fGrid.Hold = fGrid.Hold + 1
				IsGen=True 
			End If 
			
			If IsGen Then 
				If fGrid.Height = 1 Or fGrid.Width = 1 Then 
					ShiftLines(fGrid, True, 1, fGrid.TextDirection)
					fGrid.Hold = -Rnd(1,5)
				Else 
					ShiftLines(fGrid, True, fGrid.Width, -1)'Max(fGrid.Height, fGrid.Width)
				End If 
			End If 
			If fGrid.Hold = 0 Then 
				If fGrid.Height > 1 Then 
					fGrid.Hold = Rnd(1,5)
				End If 
			End If 
		End If

	Next
	
	Element.Align = LCAR.Increment(Element.Align, 5, Element.RWidth)
	If Element.Align = Element.RWidth Then Element.RWidth = Rnd(0,360)
	Return True 
End Sub
Sub DrawFerengi(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int)
	Dim CenterX As Int = X + Width*0.5, CenterY As Int = Y + Height * 0.5, MinR As Int = Min(Width,Height)*0.5, MaxR As Int = Max(Width,Height)*0.5, Ret As Point, FontSize As Int
	Dim Dark_Brown As Int = Colors.RGB(69,56,38), Light_Brown As Int = Colors.RGB(78,50,27), Stroke As Int = 4, TextColor As Int = Colors.RGB(136, 145, 185), CharSize As Int 
	
	'Background
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Light_Brown, 0)
	BG.DrawCircle(CenterX,CenterY,MaxR, Dark_Brown, True, 0)
	LCARSeffects6.DrawOval(BG,X,Y,Width,Height,Colors.Black, 0)
	
	'Text blocks
	FontSize = API.GetTextHeight(BG, Height * 0.023169601482854494, "012ABCabc", FerengiFont)
	CharSize = BG.MeasureStringHeight("ABC123abc", FerengiFont, FontSize)'25
	'Log("CharSize: " & CharSize & " " & (CharSize/Height))'CharSize: 25 0.023169601482854494
	Dim Width2 As Int = CharSize*14, Height2 As Int = CharSize*10, HalfWidth2 As Int = Width2 * 0.5, HalfHeight2 As Int = Height2*0.5
	
	DrawFerengiTextScreen(BG, CenterX-HalfWidth2,CenterY-HalfHeight2,Width2, Height2, 0,			TextColor, FontSize, CharSize, 0, False)'middle
	DrawFerengiTextScreen(BG, CenterX-HalfWidth2,CenterY*0.5-HalfHeight2,Width2, Height2, 1,		TextColor, FontSize, CharSize, 0, False)'top
	DrawFerengiTextScreen(BG, CenterX-HalfWidth2,CenterY*1.5-HalfHeight2,Width2, Height2, 2,		TextColor, FontSize, CharSize, 0, False)'bottom

	DrawFerengiTextScreen(BG, CenterX*0.5-HalfWidth2,CenterY+HalfHeight2*0.5,Width2, Height2, 3,	TextColor, FontSize, CharSize, 2, False)'left bottom
	DrawFerengiTextScreen(BG, CenterX*1.5-HalfWidth2,CenterY+HalfHeight2*0.5,Width2, Height2, 4,	TextColor, FontSize, CharSize, 1, False)'right bottom

	DrawFerengiTextScreen(BG, CenterX*0.5-HalfWidth2,CenterY-HalfHeight2*1.5,Width2, Height2, 5,	TextColor, FontSize, CharSize, 1, True)'left top
	DrawFerengiTextScreen(BG, CenterX*1.5-HalfWidth2,CenterY-HalfHeight2*1.5,Width2, Height2, 6,	TextColor, FontSize, CharSize, 2, True)'right top
	
	'Lines
	MaxR = Width * 0.5
	LCARSeffects6.ClipOval(BG,X,Y,Width,Height)
	DrawFerengiLine(BG, X,Y,Width,Height, 	 	0.3268293, 0.5193799, 		0.4658537, 0.5193799, 	7,7,	Light_Brown,	Stroke)'Long horizontal line, in the middle/top
	DrawFerengiLine(BG, X,Y,Width,Height, 	 	0.4121951, 0.3410853, 		0.4609756, 0.3410853, 	7,0,	Dark_Brown,		Stroke)'Short horizontal line, at the top
	Ret = DrawFerengiLine(BG, X,Y,Width,Height, 0.4609756, 0.0000000, 		0.4609756, 0.4031008, 	0,0,	Light_Brown,	Stroke)'Long vertical line, at the top
	MinR = MaxR - Ret.X 
	BG.DrawLine(Ret.X,Ret.Y, X + MaxR, Ret.Y + MinR, Light_Brown, Stroke)
	BG.DrawLine(X+Width - Ret.X,Ret.Y, X + MaxR, Ret.Y + MinR, Light_Brown, Stroke)
	
	DrawFerengiLine(BG, X,Y,Width,Height, 	 	0.3317073, 0.5581396, 		0.5000000, 0.5581396, 	1,0,	Light_Brown,	Stroke)'Long horizontal line, in the middle/bottom
	DrawFerengiLine(BG, X,Y,Width,Height, 	 	0.3902439, 0.6627907, 		0.4585366, 0.6627907, 	1,0,	Dark_Brown,		Stroke)'Short horizontal line, at the bottom
	Ret = DrawFerengiLine(BG, X,Y,Width,Height, 0.4585366, 1.0000000, 		0.4585366, 0.6627907,	0,0,	Light_Brown,	Stroke)'Long vertical line, at the bottom
	MinR = MaxR - Ret.X 
	BG.DrawLine(Ret.X,Ret.Y, X + MaxR, Ret.Y - MinR, Light_Brown, Stroke)
	BG.DrawLine(X+Width - Ret.X,Ret.Y, X + MaxR, Ret.Y - MinR, Light_Brown, Stroke)
	BG.RemoveClip

	'Logo
	LCARSeffects2.LoadUniversalBMP(File.DirAssets,"ferengi.png", LCAR.FER_Ticker)'200x163
	Stroke = 2'Scalefactor
	MinR = 200 / Stroke'Width
	MaxR = 163 / Stroke'Height
	LCARSeffects2.DrawBitmapRotated(BG, LCARSeffects2.CenterPlatform, 0,0,200,163,	CenterX - MinR*0.5, CenterY, MinR,MaxR, Angle)' - MaxR*0.5
End Sub

'Shape: 0=||, 1=\\, 2=//
Sub DrawFerengiTextScreen(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int,  ScreenID As Int, TextColor As Int, FontSize As Int, CharSize As Int, Shape As Int, IsLeft As Boolean)
	Dim temp As Int, fGrid As FerengiGrid	
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	'LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.Red, 2)	

	For temp = 0 To FerengiLines.size - 1
		fGrid = FerengiLines.Get(temp)
		If fGrid.ScreenID = ScreenID Then 
			DrawFerengiText(BG,X,Y,Width,Height, FontSize, fGrid, TextColor, CharSize, ScreenID, IsLeft)
		End If
	Next 
	'BG.DrawText(ScreenID, x + Width * 0.5, y + Height * 0.5, Typeface.DEFAULT, 20, Colors.Red, "CENTER")
	BG.RemoveClip
End Sub
Sub DrawFerengiText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, FontSize As Int, fGrid As FerengiGrid, Color As Int, CharSize As Int, ScreenID As Int, IsLeft As Boolean)
	Dim tempX As Int = fGrid.X*0.1*CharSize, tempY As Int = fGrid.Y*0.1*CharSize, Xp As Int, temp As Int, Align As String, Factor As Float = 0.20, DoX As Boolean = True, DirectionX As Boolean, DirectionY As Boolean  'below 0.4
	If fGrid.SpeedY<0 Then Y = Y + CharSize
	If fGrid.SpeedX<0 Then X = X + CharSize
	'If fGrid.Xs< 0 Then 'use columns instead
	'	X = X + CharSize * Abs(fGrid.Xs) 
	'Else 
		X = X + (Width * fGrid.Xs) + tempX
	'End If 
	'If fGrid.Ys< 0 Then 'use rows instead
	'	Y = Y + CharSize * Abs(fGrid.Ys) 
	'Else 
		Y = Y + (Height * fGrid.Ys) + tempY
	'End If
	'If fGrid.SpeedY > 0 Then Log(fGrid.Y)
	'If fGrid.SpeedX>0 Then X = X - CharSize 
	'If fGrid.SpeedY>0 Then Y = Y - CharSize 
	Xp = X
	tempX=Max(tempX,Abs(tempY))
	Select Case fGrid.TextDirection '0=||, 1=\\, 2=//
		Case 0'||
			DoX = False' fGrid.SpeedX <> 0
			DirectionX = fGrid.SpeedX > 0
			DirectionY = fGrid.SpeedY > 0
		Case 1'\\
			If Not(IsLeft) Then		
				DirectionX = True 
				DirectionY = True 
			End If
		Case 2'//		
			If IsLeft Then DirectionX = True 
			DirectionY = True
	End Select
	
	If DoX Then 
		If DirectionX Then Xp = Xp + tempX Else Xp = Xp - tempX
	End If 
	If fGrid.SpeedY <> 0 Then 
		If DirectionY Then Y=Y+tempX*Factor Else Y=Y-tempX*Factor
	End If 
	
	X=Xp
	tempX=0
	tempY=0
	For temp = 0 To fGrid.Chars.Size - 1 
		Select Case fGrid.TextAlign
			Case 1: Align = "LEFT"
			Case 2: Align = "CENTER"
			Case 3: Align = "RIGHT"
		End Select
		BG.DrawText( fGrid.Chars.Get(temp), X,Y, FerengiFont, FontSize, Color, Align)
		tempX = tempX + 1
		
		If fGrid.SpeedX >= 0 Then
			X = X + CharSize 
		Else 
			If IsLeft And fGrid.TextDirection = 2 Then 
				X = X + CharSize 	
			Else 
				X = X - CharSize 
			End If 
		End If 
		
		If tempX = fGrid.Width Then 
			If IsLeft Then 
				Select Case fGrid.TextDirection '0=||, 1=\\, 2=//
					Case 2: Xp = Xp + CharSize
					Case 1: Xp = Xp - CharSize
				End Select
			Else 
				Select Case fGrid.TextDirection '0=||, 1=\\, 2=//
					Case 1: Xp = Xp + CharSize
					Case 2: Xp = Xp - CharSize
				End Select
			End If 
			tempX = 0 
			tempY = tempY+1
			X=Xp
			If fGrid.SpeedY > 0 Then 
				Y=Y+CharSize 
			Else 
				Y=Y-CharSize 
			End If 
		End If
	Next
End Sub
Sub DrawFerengiLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, X1 As Float, Y1 As Float, X2 As Float, Y2 As Float, O1 As Int, O2 As Int, Color As Int, Stroke As Int) As Point 
	Dim X1i As Int = Width * X1, Y1i As Int = Y + Height * Y1, X2i As Int = X2 * Width, Y2i As Int = y + Y2 * Height, Right As Int = X + Width 
	BG.DrawLine(X+X1i, Y1i, X+X2i, Y2i, Color, Stroke)
	DrawFerengiDiagonal(BG, X+X1i, Y1i, X,Y, Width,Height, O1, False, Color, Stroke)
	DrawFerengiDiagonal(BG, X+X2i, Y1i, X,Y, Width,Height, O2, False, Color, Stroke)
	
	BG.DrawLine(Right-X1i, Y1i, Right-X2i, Y2i, Color, Stroke)
	DrawFerengiDiagonal(BG, Right-X1i, Y1i, X,Y, Width,Height, O1, True, Color, Stroke)
	DrawFerengiDiagonal(BG, Right-X2i, Y1i, X,Y,  Width,Height, O2, True, Color, Stroke)
	Return Trig.SetPoint(X2i, Y2i)
End Sub
Sub DrawFerengiDiagonal(BG As Canvas, X1 As Int, Y1 As Int, X As Int, Y As Int, Width As Int, Height As Int, Orientation As Int, FlipX As Boolean, Color As Int, Stroke As Int)
	Dim X2 As Int, Y2 As Int 
	If Orientation > 0 Then 
		If FlipX Then 
			Select Case Orientation
				Case 1,7: Orientation = Orientation + 2
				Case 3,9: Orientation = Orientation - 2
			End Select
		End If
		Select Case Orientation
			Case 7'up left
				X2 = X1 - Y1 
			Case 9'up right
				X2 = X1 + Y1 
				
			Case 1'down left
				X2 = X1 - (Height- Y1)
				Y2 = Y + Height
			Case 3'down right 
				X2 = X1 + (Height- Y1) 
				Y2 = Y + Height
		End Select
		
		BG.DrawLine(X1,Y1,X2,Y2, Color, Stroke)
	End If 
End Sub



Sub RNDENTcolor As Int 
	'Classic_Yellow = 14, Classic_Green = 15, Classic_LightBlue = 16, Classic_Blue = 17, Classic_Turq = 18, Classic_Red = 19
	Return Rnd(14,19)
End Sub

'Corner: 0=no frame, 1=top left corner, 2=top left and right, 3=top right, 4=left (top and bottom), 5=all 4, 6=right (top and bottom), 7=bottom left corner, 8=bottom left and right, 9=bottom right, 10=no corners
'FrameTextAlign: 0=top left, 1=top right, 2=bottom left, 3=bottom right (add multiples of 4 to increase the textsize), rWidth (radius), lWidth (stroke)
Sub AddWallpaperLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String,Group As Int,  Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int, Stroke As Int, Corner As Int, FrameText As String, FrameTextAlign As Int) As Int
	Dim temp As Int, ret As Int, oX As Int = X, oY As Int = Y, oS As Int = Stroke, oW As Int = Width, oH As Int = Height, PutAfter As Boolean = True 
	If ColorID = LCAR.LCAR_Random Then ColorID = RNDENTcolor
	If ElementType <> LCAR.PCAR_Frame And Corner > 0 Then 
		If ElementType = LCAR.TMP_RndNumbers Then temp = ColorID Else temp = RNDENTcolor
		If ElementType = LCAR.LCAR_LWP Then 
			Select Case LWidth & "." & RWidth 
				Case "48.6", "48.7": Stroke = Stroke * 2'more spacing
				Case "48.12": temp = ColorID'match color IDs
				Case "48.17", "48.20", "48.21"'put element over the frame, match the color IDs of both
					PutAfter = False 
					temp = ColorID
			End Select
		End If
		If Not(PutAfter) Then LCARSeffects3.AddWallpaperLCAR("FRAME", 0, X,Y,Width, Height, Stroke, Stroke*2, temp, LCAR.PCAR_Frame, FrameText, "", "", 0, True, FrameTextAlign, False, Corner, Alpha)
		If ElementType = LCAR.TMP_RndNumbers Then Stroke = Stroke * 2
		X=X+Stroke 
		Y=Y+Stroke
		Width = Width - Stroke * 2
		Height = Height - Stroke * 2
	End If
	If ElementType = LCAR.TMP_RndNumbers And Text.Length > 0 Then
		temp = LCAR.EmergencyBG.MeasureStringHeight(Text, LCARSeffects2.StarshipFont, LCAR.Fontsize* 0.5)
		ColorID=RNDENTcolor
		AddWallpaperLCAR("STATUS", 0, X, Y, Width, Stroke*0.5, 48, -1,  ColorID, LCAR.LCAR_LWP, Text, "","", -1,True, 1,True,Stroke,255, 0,0, "", 0)
		Y=Y+Stroke
		Height = Height - Stroke
		Text = ""
	End If 
	ret = LCARSeffects3.AddWallpaperLCAR(Name, SurfaceID, X, Y, Width, Height, LWidth, RWidth, ColorID, ElementType, Text, SideText, Tag, Group,  Visible, TextAlign, Enabled, Align, Alpha)
	If ElementType <> LCAR.PCAR_Frame And Corner > 0 And PutAfter Then LCARSeffects3.AddWallpaperLCAR("FRAME", 0, oX,oY,oW, oH, oS, oS*2, temp, LCAR.PCAR_Frame, FrameText, "", "", 0, True, FrameTextAlign, False, Corner, Alpha)
	Return ret 
End Sub

Sub AddENTBpage(X As Int, Y As Int, Width As Int, Height As Int, PageType As Int) As Int 
	Dim Stroke As Int = LCAR.EmergencyBG.MeasureStringHeight("0123456789", LCARSeffects2.StarshipFont,LCAR.Fontsize), Radius As Int = Stroke * 2, temp As Int = Height * 0.67, temp2 As Int = Width*0.75, temp3 As Int, temp4 As Int  = Height-Stroke*2, temp5 As Int, RNDalign As Int = -1, BottomText As String, DoRND As Boolean = True
	'Align: 1=top left corner, 2=top middle, 3=top right, 4=left middle, 5=middle, 6=right middle, 7=bottom left corner, 8=bottom middle, 9=bottom right, 10=no corners
	'TextAlign: 0=top left, 1=top right, 2=bottom left, 3=bottom right (add multiples of 4 to increase the textsize), rWidth (radius), lWidth (stroke)
	Stroke = Stroke * 0.5
	temp3=Width-temp2-Stroke
	Select Case PageType
		Case -1: Return 19'max types
			'LCARSeffects2.RemoveGraph(4)
			'LCARSeffects2.RemoveGraph(5)
						
		Case 2000'INSIGNIA 
			AddWallpaperLCAR("STRFLT", 0, X, Y,Width,temp, 48,0,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "SYS STANDBY MODE", "","", -1,True, 42,True,8,255, Stroke, 2, "", 0)
			RNDalign = 2'bottom
			BottomText=API.GetString("sec_89_12")'"VEHICLE STATUS"
		
		Case 2001'NX-2000, ironically
			AddWallpaperLCAR("STRSHP", 0, X, Y,temp2,temp, 48,2,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255, Stroke, 1, "", 0)
			AddWallpaperLCAR("GRAPH", 0, X+temp2+Stroke,Y,temp3,temp, 48,3,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_1")'"SUBSYSTEM STATUS"
		
		Case 2002'radar
			AddWallpaperLCAR("RADAR", 0, X, Y,temp2,temp, 48,5,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255, Stroke, 1, "", 0)
			AddWallpaperLCAR("GRAPH", 0, X+temp2+Stroke,Y,temp3,temp, 48,4,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_2")'"SHORT RANGE SCAN"
		
		Case 2003'sensor scan
			temp2= Width * 0.5
			AddWallpaperLCAR("RNDBLOC", 0, X, Y,temp2,temp, 0,0,  LCAR.Classic_Blue, LCAR.TMP_RndNumbers, "", "","", -1,True, 0,True,0,255, Stroke, 1, "", 0)
			AddWallpaperLCAR("ANALYSS", 0, X+temp2+Stroke,Y,Width-temp2-Stroke,temp, 55,95,  LCAR.LCAR_Black, LCAR.LCAR_SensorGrid, "", "","", -1,True, 4,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = "SUBSPACE SCAN"
		
		Case 2004'analysis
			temp4=temp*0.70
			LCARSeffects2.SeedScanAnalysis(18, LCAR.LCAR_TMP)
			AddWallpaperLCAR("RNDBLOC", 0, X,Y,temp3-Stroke,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, Stroke, 1, "", 0)
			AddWallpaperLCAR("AlertStatus", 0, x+temp3,   y,    temp2-temp3,   temp4, 18, 0,  LCAR.Classic_Green, LCAR.LCAR_List, "", "","", 0, False,0,True,0,255, Stroke, 10, "", 0)
			AddWallpaperLCAR("CUST", 0, x+temp3,   y+temp4+Stroke,    temp2-temp3,   temp-temp4-Stroke, 48,6,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "GRAVIMETRIC", "DISTORTION","", -1,True,  0,True, 255,255, Stroke, 10, "", 0)			
			AddWallpaperLCAR("RNDBLOC", 0, X+temp2+Stroke,Y,temp3,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = "SUBSPACE SCAN " & Rnd(10,100)
		
		Case 2005'blue bars
			temp = Height-Stroke*3'new height
			temp2 = 0.21 * Width 
			AddWallpaperLCAR("RNDBLOC", 0, X,Y,temp2,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "AUXILIARY", "","", -1,True, 4,True,0,255, Stroke, 4, "", 0)
			temp3 = 0.13 * Width 
			AddWallpaperLCAR("BAR1", 0, X+temp2+Stroke,Y,temp3,temp, 48,7,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 0,True,0,255, Stroke, 10, "", 0)
			AddWallpaperLCAR("BAR2", 0, X+temp2+Stroke*2+temp3,Y,temp3,temp, 48,7,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "","", -1,True, 255,True, 1,255, Stroke, 10, "", 0)
			temp4 = temp2 + temp3*2 + Stroke*2
			temp5 = X + temp4 + Stroke 
			temp2 = Height * 0.30
			temp4 = Width - temp4 - Stroke
			AddWallpaperLCAR("RNDBLOC", 0, temp5,Y,temp4,temp2, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "CIVILIAN USE", "","", -1,True, 4,True,0,255, Stroke, 3, "", 0)
			temp3 = Y+temp2+Stroke
			AddWallpaperLCAR("RNDBLOC", 0, temp5,temp3,temp4,temp-temp2-Stroke, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "SYSTEM USE", "","", -1,True, 4,True,0,255, Stroke, 9, "####.#", 7)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_5")' "FUEL CONSUMPTION"
			DoRND = False 
		
		Case 2006'alert condition status
			AddWallpaperLCAR("ALERT", 0, X, Y,Width,temp, 48,8,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "ALERT", "","", -1,True, 256,True, 8,255, Stroke, 2, "", 0)
			RNDalign = 2'bottom
			BottomText = "VEHICLE STATUS"
		
		Case 2007'chart
			AddWallpaperLCAR("CHART", 0, X, Y,Width,temp, 48,9,  LCAR.LCAR_Random, LCAR.LCAR_LWP, Rnd(10000, 99999), Rnd(10000, 99999),"", -1,True, 0,True, Stroke ,255,  0, 0, "", 0)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_7")' "SYSTEM STATUS"
			
		'warp core, EM
		Case 2008'circles
			temp2 = Width * 0.3
			temp3 = (temp - Stroke) * 0.5
			AddWallpaperLCAR("CHART1", 0, X, Y,temp2,temp3, 48,10,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "", "" ,"", -1,True, 7,True,  4 ,255,  Stroke, 1, "", 0)
			AddWallpaperLCAR("CHART2", 0, X, Y+temp3+Stroke,temp2,temp3, 48,10,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "", "" ,"", -1,True, 7,True, 5 ,255,  Stroke, 10, "", 0)
			AddWallpaperLCAR("CIRCLES", 0, X+temp2+Stroke, Y,Width - temp2*2-Stroke*2,temp, 48,11,  LCAR.Classic_Green, LCAR.LCAR_LWP, "", "" ,"", -1,True, 0,True, 0,0,  Stroke, 10, "", 0)
			AddWallpaperLCAR("RNDBLOC", 0, X+Width-temp2,Y,temp2,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 0,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_8")' "STRUCTURE ANALYSIS"
		
		Case 2009'frequency stlye 4 or 5
			temp4=temp*0.70
			LCARSeffects2.SeedScanAnalysis(18, LCAR.LCAR_TMP)
			AddWallpaperLCAR("RNDBLOC", 0, X,Y,temp3-Stroke,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, Stroke, 1, "", 0)
			temp5 = (temp4-Stroke) * 0.5
			AddWallpaperLCAR("CHART1", 0, x+temp3,   y,    temp2-temp3,  temp5, 48,10,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "", "" ,"", -1,True, -2,True,   6 ,255,  Stroke, 10, "", 0)
			AddWallpaperLCAR("CHART2", 0, x+temp3,   y+Stroke+temp5,    temp2-temp3,  temp5, 48,10,  LCAR.LCAR_Random, LCAR.LCAR_LWP, "", "" ,"", -1,True,  -2,True,   7 ,255,  Stroke, 10, "", 0)
			AddWallpaperLCAR("CUST", 0, x+temp3,   y+temp4+Stroke,    temp2-temp3,   temp-temp4-Stroke, 48,6,  LCAR.Classic_Blue, LCAR.LCAR_LWP, "SIGNAL", "DETECTED","", -1,True,  0,True, 255,255, Stroke, 10, "", 0)
			AddWallpaperLCAR("RNDBLOC", 0, X+temp2+Stroke,Y,temp3,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, Stroke, 3, "", 0)
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_9")' "SUBSPACE COMM"
		
		Case 2010'EM
			RNDalign = 2'bottom
			BottomText = "DISPLAY TYPE: EMF RADIATION"
			DoRND = False 			
			temp = Height-Stroke*4
			temp2 = temp * 0.25
			temp3 = Width * 0.40
			AddWallpaperLCAR("EMF", -1, X, Y, Width, temp, 48, 12, LCAR.Classic_Blue, LCAR.LCAR_LWP,BottomText, "EM DISPLAY", "", 0, True, 0, True, 0, 255, Stroke, 5, "####.#", 7)
			
			AddWallpaperLCAR("RNDEMF1", -1, X + Stroke* 2, Y + temp*0.75 + Stroke, Width- Stroke * 4, temp2 - Stroke*4, 0,0,  LCAR.LCAR_White, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, 0, 0, "", 0)
			AddWallpaperLCAR("RNDEMF2", -1, X + Stroke* 2, Y + temp2* 0.5, temp3 - Stroke*3, temp2*0.5 - Stroke, 0,0,  LCAR.LCAR_White, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, 0, 0, "", 0)
			
			temp = Max(LCAR.EmergencyBG.MeasureStringWidth(BottomText, LCARSeffects2.StarshipFont, LCAR.Fontsize * 0.75) + Stroke * 1.5, Width * 0.40) + Stroke 
			temp4 = Width - temp - LCAR.EmergencyBG.MeasureStringWidth("EM DISPLAY", LCARSeffects2.StarshipFont, LCAR.Fontsize) - Stroke 
			AddWallpaperLCAR("RNDEMFR", -1, x + temp, Y + temp2 * 0.25 + Stroke * 0.5, temp4 * 0.5, temp2 * 0.75 - Stroke * 1.5, 0,0,  LCAR.LCAR_White, LCAR.TMP_RndNumbers, "", "","", -1,True, 4,True,0,255, 0, 0, "", 0)
			LCARSeffects2.AddRowOfNumbers(LCAR.TMP_RndNumbers-1, LCAR.LCAR_White, Array As Int(4,1,4,1))
			
			temp4 = Stroke * 0.5
			temp5 = Y+temp2+temp4*1.5
			temp = Width - temp3 - Stroke-temp4
			AddWallpaperLCAR("GRID", -1, X+Stroke, temp5, temp3-Stroke, temp2*2-temp4*3, 48, 13, LCAR.Classic_Blue, LCAR.LCAR_LWP, "", " ", "", 0, True, 0, True, Stroke, 255, 0, 0, "", 0)'GRID
			AddWallpaperLCAR("GRPH1", -1, X+temp3+temp4, temp5, temp, temp2-temp4*2, 48, 14, LCAR.LCAR_Orange, LCAR.LCAR_LWP, "", " ", "", 0, True, 5, True, 25, 255, 0, 0, "", 0)
			AddWallpaperLCAR("RNDG1", -1, X+temp3+temp4+Stroke, temp5+Stroke*2, temp*0.27 - Stroke * 3, temp2-temp4*2-Stroke*4, 0, 0, LCAR.LCAR_White, LCAR.TMP_RndNumbers, "", " ", "", 0, True, 0, True, 0, 255, 0, 0, "", 0)
			AddWallpaperLCAR("GRPH2", -1, X+temp3+temp4, temp5+temp2-temp4, temp, temp2-temp4*2, 48, 15, LCAR.LCAR_DarkBlue, LCAR.LCAR_LWP, "", " ", "", 0, True, Rnd(0,360), True, LCARSeffects3.RND_ID, 255, 0, 0, "", 0)
			LCARSeffects3.RND_ID = LCARSeffects3.RND_ID + 1
			BottomText = API.GetString("sec_89_10")' "LATERAL SENSOR ARRAY"
			
		Case 2011'CRONOS 1
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_11")' "SUBSPACE ANALYSIS"
			DoRND = False
			temp = Height-Stroke*4
			AddWallpaperLCAR("CRONOS", -1, X, Y, Width, temp, 48, 16, LCAR.Classic_Blue, LCAR.LCAR_LWP, "ORBITAL GRAVITATION", "", "", 0, True, 0, True, 0, 255, Stroke, 5, "####.#", 7)
		
		Case 2012	
			RNDalign = 2'bottom
			BottomText = API.getstring("sec_89_12")'"VEHICLE STATUS"
			AddWallpaperLCAR("STRSHP", 0, X, Y,temp2,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 0,True,0,255, Stroke, 1, "", 0)
			AddWallpaperLCAR("GRAPH", 0, X+temp2+Stroke,Y,temp3,temp, 0,0,  RNDENTcolor, LCAR.TMP_RndNumbers, "", "","", -1,True, 0,True,0,255, Stroke, 3, "", 0)
		
		Case 2013
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_13") & " " & Rnd(10,100)
			DoRND = False
			AddWallpaperLCAR("SECSCN", -1, X, Y, Width, temp4, 48, 17, LCAR.Classic_Blue, LCAR.LCAR_LWP,"", "", "", 0 , True, Stroke+1, True, 0, 255, Stroke, 5, "####.#", 7)
		
		Case 2014'BOP
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_14")
			DoRND = False
			temp4=Height * 0.33
			AddWallpaperLCAR("STATUS", 0, X, Y,Width,temp4, 48, 19, RNDENTcolor, LCAR.LCAR_LWP, "4 MINUTES TO INTERCEPT.", "CLOAKING DEVICE ENGAGED.","POSITION UNKNOWN.", -1,True, 0,True,0,255, Stroke, 2, "", 0)
			temp = Height-temp4-Stroke*5
			temp5 = RNDENTcolor
			AddWallpaperLCAR("KLINGN", -1, X, Y+temp4+Stroke, Width, temp, 48, 18, temp5 , LCAR.LCAR_LWP, "", "", "", 0, True, 0, True, 0, 255, Stroke, 8, "####.#", 7)
			
			temp2 = temp * 0.40'Height
			temp = Width * 0.13'Width 
			AddWallpaperLCAR("RNDKLN", -1,  X + Width - Stroke*2 - temp, Y+temp4+Stroke*5, temp, temp2, 0,0, temp5, LCAR.TMP_RndNumbers, "", "","", -1,True, 0,True,0, 255, 0, 0, "", 0)
		
		Case 2015'Tactical scan (sec_89_14 + rnd(10,100))
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_14") & " " & Rnd(10,100)' Tactical scan
			DoRND = False
			temp = Height-Stroke*4'height
			temp2 = Width * 0.25 	
			temp3 = (Width-temp2-Stroke*3) * 0.30'Width of Enterprise
			temp4 = temp3 * 0.2385321100917431'Half-Height of Enterprise
			temp5 = temp*0.5 - temp4 - Stroke*2 'Height of RND
			
			AddWallpaperLCAR("SCAN1", -1, X, Y, temp2, temp, 48, 21, RNDENTcolor, LCAR.LCAR_LWP, "", "", "", 0, True, Stroke, True, temp4, 255, Stroke, 4, "", 0)
			AddWallpaperLCAR("RND1", -1,  X+Stroke*2, Y+Stroke*2, temp2-Stroke*4, temp5, 0, 0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 0, "", 0)
			AddWallpaperLCAR("RND2", -1,  X+Stroke*2, Y+temp*0.5+temp4+Stroke, temp2-Stroke*4, temp5, 0, 0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 0, "", 0)
			AddWallpaperLCAR("SCAN2", -1, X+temp2+Stroke, Y, Width-temp2-Stroke, temp, 48, 20, RNDENTcolor, LCAR.LCAR_LWP, "", "", "", 0, True, 0, True, Stroke, 255, Stroke, 6, "####.#", 7)
			
		Case 2016'PRAXIS 2
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_16")'"WAVEFORM MONITOR"
			DoRND = False
			temp = Height-Stroke*4
			AddWallpaperLCAR("EMF2", -1, X, Y, Width, temp, 48, 22, LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "", "SPECTRAL ANALYSIS", 0, True, 0, True, Stroke * 0.5, 255, Stroke, 5, "####.#", 7)
			
			Width = Width - Stroke * 4
			temp2 = Width * 0.25 + Stroke*0.5'width of right
			temp3 = temp * 0.25'height of bottom
			temp4 = X + Stroke*2.5 + Width * 0.75'Start of right
			temp5 = Y + temp * 0.75'start of bottom
			
			AddWallpaperLCAR("RND1", -1,  X+ Stroke*2 + Width * 0.00870, temp5 + temp3*0.13208, Width * 0.19500, temp3*0.62264, 0, 0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 0, "", 0)
			AddWallpaperLCAR("GRPH", -1,  X+ Stroke*2 + Width * 0.21304, temp5 + temp3*0.13208, Width * 0.50435, temp3*0.62264, 0, 8, RNDENTcolor, LCAR.LCAR_Graph, "", "", "", 0, True, -341746, True, 0, 255, Stroke, 0, "", 0)
			
			temp = temp * 0.75 - Stroke*1.5'height
			temp5=Y + Stroke'Y
			Stroke = LCAR.EmergencyBG.MeasureStringHeight("1", LCARSeffects2.StarshipFont, LCAR.Fontsize*0.5)

			AddWallpaperLCAR("RND2", -1,  temp4 + temp2 * 0.0678, temp5 + temp * 0.02308, temp2 * 0.81356, temp * 0.17692, 0,0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, 0,0, "", 0)
			AddWallpaperLCAR("RND3", -1,  temp4 + temp2 * 0.0678, temp5 + temp * 0.2 + Stroke*0.5, temp2 * 0.81356, Stroke + 2, 0,0, LCAR.Classic_Red, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, 0,0, "", 0)
			AddWallpaperLCAR("RND4", -1,  temp4 + temp2 * 0.0678, temp5 + temp * 0.2 + Stroke * 2 + 4, temp2 * 0.81356, temp * 0.17692, 0,0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, 0,0, "", 0)
		
		Case 2017'map
			RNDalign = 2'bottom
			BottomText = API.GetString("sec_89_17")' "QUADRANT MAP"
			DoRND = False
			temp = Height-Stroke*4
			AddWallpaperLCAR("MAP", -1, X, Y, Width, temp, 48, 23, LCAR.Classic_Blue, LCAR.LCAR_LWP, "", "", "", 0, True, Stroke, True, 0, 255, Stroke, 5, "####.#", 7)
			Width = Width - Stroke * 4'0.62745, 0.04167, 0.35294, 0.18056
			Stroke = Stroke * 2
			AddWallpaperLCAR("RND1", -1,  X+ Stroke + Width * 0.62745, Y + Stroke + temp*0.04167, Width * 0.35294, temp3*0.18056, 0, 0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 0, "", 0)
			
		Case 2018'warp core
			RNDalign = 2
			BottomText = API.GetString("sec_89_18")'WARP PROP STATUS
			AddWallpaperLCAR("WARP", 0, X, Y,Width,temp, 0,0,  RNDENTcolor, LCAR.TMP_Engineering, API.GetString("warpnacelle"), API.GetString("port"),API.getstring("starboard"), -1,True,  0,True,0,255, Stroke, 2, "", 0)
			temp2 = temp*0.33
			AddWallpaperLCAR("RND1", -1,  X+ Stroke*2, Y + temp - temp2 - Stroke * 2, Width * 0.36124, temp2, 0, 0, RNDENTcolor, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 0, "", 0)

		Case Else
			RNDalign = 2'bottom
			BottomText = PageType & " NOT DEFINED"
			DoRND = False
			AddWallpaperLCAR("DEMO", 0, X,Y,Width,temp4, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_GNDN, "", "", "", 0, True, 0, True, 0, 255, Stroke, 5, "ERROR", 7)
	End Select
	
	Select Case RNDalign
		Case 2'bottom
			temp3=Y+temp+Stroke
			temp2 = Height-temp-Stroke*4
			temp = RNDENTcolor
			If DoRND Then AddWallpaperLCAR("RNDBLOC", -1, X, temp3, Width, temp2, 0,0, temp, LCAR.TMP_RndNumbers, "", "", "", 0, True, 0, True, 0, 255, Stroke, 8, "####.#", 7)
			If BottomText.Length > 0 Then AddWallpaperLCAR("STATUS", 0, X+Radius, Y+Height-Stroke, Width-Radius, Stroke, 48, 1,  LCAR.LCAR_Random, LCAR.LCAR_LWP, BottomText, "","", -1,True, 1,True,Stroke,255, 0,0, "", 0)
	End Select
End Sub







Sub GetBiggestWord(Text As String) As String 
	Dim tempstr() As String = Regex.Split(" ", Text), BiggestWord As String, Length As Int, temp As Int
	For temp = 0 To tempstr.Length - 1
		If tempstr(temp).Length > Length Then 
			Length = tempstr(temp).Length
			BiggestWord = tempstr(temp)
		End If
	Next
	Return BiggestWord
End Sub
'Alignment: uses numpad arrangement, Image: 0=White with Solid ring, 1=White with Transparent ring, 2=Black, 3=Klingon
Sub DrawInsignia(BG As Canvas, X As Int, Y As Int, Height As Int, Alignment As Int, Image As Int, Color As Int) As Int 
	Dim Width As Int = Height  * 0.734375'47*64 width of image
	If Not(OperationsBMP.IsInitialized) Then OperationsBMP.Initialize(File.DirAssets, "starfleet.png")
	Select Case Alignment
		Case 8,5,2: X = X - Width * 0.5 'middle col
		Case 9,6,3: X = X - Width 'right col
	End Select
	Select Case Alignment
		Case 4,5,6: Y=Y-Height * 0.5'middle row
		Case 1,2,3: Y=Y-Height'bottom row
	End Select
	If Color <> Colors.black Then LCARSeffects4.DrawRect(BG, X, Y, Width, Height, Color, 0)
	BG.DrawBitmap(OperationsBMP, LCARSeffects4.SetRect(Image * 94, 0, 94, 128), LCARSeffects4.SetRect(X, Y, Width, Height))
	Return Width
End Sub
'Starship: 0=Constitution, 1=Unknown, 2=Excelsior, Angle: 0=up, 90=right, 180=down, 270=left
Sub DrawStarship(BG As Canvas, X As Int, Y As Int, Starship As Int, Width As Int, Angle As Int)
	Dim SrcWidth As Int = 80, SrcHeight As Int = 38, AspectRatio As Float = 0.475, Height As Int, Src As Rect, Dest As Rect 
	If Not(OperationsBMP.IsInitialized) Then OperationsBMP.Initialize(File.DirAssets, "starfleet.png")
	If Starship = 2 Then 
		SrcWidth = 77
		SrcHeight = 30
		AspectRatio = 0.3896103896103896
	End If
	Height = Width * AspectRatio
	Src = LCARSeffects4.SetRect(376, Starship * 38, SrcWidth, SrcHeight)
	Dest = LCARSeffects4.SetRect(X - Width * 0.5, Y - Height * 0.5, Width, Height)	
	If Angle = 90 Then 
		BG.DrawBitmap(OperationsBMP, Src,Dest)
	else if Angle = 270 Then 
		BG.DrawBitmapFlipped(OperationsBMP, Src, Dest, False, True)
	Else 
		BG.DrawBitmapRotated(OperationsBMP, Src, Dest, Angle)
	End If
End Sub
Sub DrawOperations(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Name As String)
	Dim HeightOfBar As Int = Height * 0.0745501285347044, YofBar As Int = Height * 0.8046272493573265, WhiteSpace As Int = Height * 0.0102827763496144, OffWhite As Int = Colors.white' Colors.RGB(166, 182, 229)
	Dim FontSize As Int, FontWidth As Int = 2, FontHeight As Int = Width * 0.0162037037037037, CenterX As Int = X + Width * 0.5
	
	LCARSeffects2.DrawRoundRect(BG,X,Y,Width,Height, OffWhite, FontHeight)'7px
	LCARSeffects2.DrawRoundRect(BG,X+FontWidth,Y+FontWidth,Width-FontWidth*2,Height-FontWidth*2, Colors.Black, FontHeight - FontWidth)'7px
	LCARSeffects4.DrawRect(BG, X, Y + YofBar, Width, HeightOfBar, OffWhite, 0)
	
	If Name.Length = 0 Then 
		Dim StartDate As Long = API.GetToday(-1,-1), Events As List = API.EnumAllEvents(StartDate, StartDate + DateTime.TicksPerDay)
		If Events.Size > 0 Then 
			Dim tempEvent As CalendarEvent = Events.Get(0)
			Name=API.uCase(GetBiggestWord(API.IIF(tempEvent.EventName.Length=0, tempEvent.Description, tempEvent.EventName)))
		End If
		If Name.Length = 0 Then Name = API.GetString("opret2")
	End If

	FontHeight = Height * 0.0976863753213368'Height of image
	'FontSize = FontHeight * 0.734375'47*64 width of image
	'BG.DrawBitmap(OperationsBMP, Null, LCARSeffects4.SetRect(CenterX - FontSize*0.5, Y + YofBar - WhiteSpace*2 - FontHeight, FontSize, FontHeight))
	DrawInsignia(BG, CenterX - FontSize*0.5, Y + YofBar - WhiteSpace*2 - FontHeight, FontHeight, 8, 0, Colors.White)

	Name = API.GetStringVars("opret0", Array As String(Name))'"Operation Retrieve"
	FontHeight = HeightOfBar * 0.5862068965517241
	FontSize = API.GetTextHeight(BG, FontHeight, Name, LCARSeffects2.StarshipFont)
	'FontHeight = BG.MeasureStringHeight(Name, LCARSeffects2.StarshipFont, FontSize)
	BG.DrawText(Name, CenterX, Y + YofBar + HeightOfBar * 0.5 + FontHeight * 0.5, LCARSeffects2.StarshipFont, FontSize, Colors.Black, "CENTER")
		
	Name = API.GetString("opret1")'Command breifing
	FontHeight = FontHeight * 0.7647058823529412
	FontSize = API.GetTextHeight(BG, FontHeight, Name, LCARSeffects2.StarshipFont)
	'FontHeight = BG.MeasureStringHeight(Name, LCARSeffects2.StarshipFont, FontSize)
	FontWidth = BG.MeasureStringWidth(Name, LCARSeffects2.StarshipFont, FontSize)
	BG.DrawText(Name, CenterX, Y + YofBar + HeightOfBar + WhiteSpace + FontHeight, LCARSeffects2.StarshipFont, FontSize, OffWhite, "CENTER")
	
	FontWidth = Width * 0.5 - FontWidth * 0.5 - WhiteSpace
	LCARSeffects4.DrawRect(BG, X, Y + YofBar + HeightOfBar + WhiteSpace * 1.5, FontWidth, WhiteSpace, OffWhite, 0)
	LCARSeffects4.DrawRect(BG, X+Width-FontWidth, Y + YofBar + HeightOfBar + WhiteSpace * 1.5, FontWidth, WhiteSpace, OffWhite, 0)
End Sub
Sub DrawOperationsP2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim FontSize As Int = LCAR.Fontsize, FontWidth As Int = 2, FontHeight As Int, Radius As Int = Width * 0.0162037037037037, OffWhite As Int = Colors.white, Stroke As Int = Height * 0.0082101806239737'Height = 609
	Dim Name As String, BottomPart As Int = Height * 0.7660044150110375, X2 As Int, Width2 As Int, Radius2 As Int, Y2 As Int, Height2 As Int, TopPart As Int, OriginalFontHeight As Int' = Height * 0.1428571428571429
	
	FontHeight = BG.MeasureStringHeight("0", LCARSeffects2.StarshipFont, FontSize)
	OriginalFontHeight=FontHeight 
	TopPart = FontHeight * 3
	Height2 = Height - FontHeight + Stroke
	
	LCARSeffects2.DrawRoundRect(BG,X,Y,Width,Height, OffWhite, Radius)'7px
	LCARSeffects2.DrawRoundRect(BG,X+FontWidth,Y+FontWidth,Width-FontWidth*2,Height2-FontWidth*2, Colors.Black, Radius - FontWidth)'7px
	BG.DrawText(API.GetString("opret5"), Radius*3, Y + Height-FontWidth, LCARSeffects2.StarshipFont, FontSize*0.5, Colors.Black, "LEFT")'MISSION PARAMETERS
	
	X2 = X + FontWidth + Stroke
	Width2 = Width - FontWidth * 2-Stroke*2
	LCARSeffects4.DrawRect(BG, X, Y + TopPart, Width, Stroke, OffWhite, 0)'Top divisor
	LCARSeffects4.DrawRect(BG, X, Y + BottomPart, Width, Stroke, OffWhite, 0)'Bottom divisor
	Name = DrawOperationsTop(BG, X2, Y + TopPart + Stroke*2, Width2, BottomPart - TopPart - Stroke *3, OffWhite)
	Y2 = Width * 0.8804034582132565
	If BG.MeasureStringWidth(Name, LCARSeffects2.StarshipFont, FontSize) > Y2 Then 
		FontSize = API.GetTextHeight(BG, -Y2, Name, LCARSeffects2.StarshipFont)
		FontHeight = BG.MeasureStringHeight("0", LCARSeffects2.StarshipFont, FontSize)
	End If
	Y2 = Width * 0.0979827089337176	
	BG.DrawText(Name, X + Y2, Y + TopPart - Stroke * 2, LCARSeffects2.StarshipFont, FontSize, OffWhite, "LEFT")
	DrawInsignia(BG, X + Y2 * 0.5, Y + TopPart * 0.5, TopPart * 0.6774193548387097, 5, 1, Colors.White)
	BG.DrawText(API.GetStringVars("opret4", Array As String("•")), X + Y2, Y + TopPart - Stroke * 3 - FontHeight, LCARSeffects2.StarshipFont, LCAR.Fontsize*0.5, OffWhite, "LEFT")'FLEET OPERATIONS CENTER • SOL SECTOR
	BG.DrawText(API.GetString("opret3"), X + Y2, Y + TopPart - Stroke * 4 - FontHeight - OriginalFontHeight * 0.5, LCARSeffects2.StarshipFont, LCAR.Fontsize*0.5, OffWhite, "LEFT")'STARFLEET COMMAND
	
	Radius2 = Radius - Stroke '
	Y2 = Y + Height2 - Radius2-Stroke - FontWidth
	LCAR.ActivateAA(BG, True)
	BG.DrawCircle(X2 + Radius2-1, Y2, Radius2, OffWhite, True, 0)
	BG.DrawCircle(X2 + Width2 - Radius2+1, Y2, Radius2, OffWhite, True, 0)
	LCARSeffects4.DrawRect(BG, X2+Radius2-1, Y2, Width2-Radius2*2+2,Radius2, OffWhite, 0)
	DrawOperationsBottom(BG, X2, Y + BottomPart + Stroke * 2, Width2, Height2-BottomPart - Radius + FontWidth - Stroke*2, OffWhite, LCAR.Fontsize * 0.5, Stroke, Radius)' Top of bottom inside
	
	Name = Rnd(1000, 10000) & "." & Rnd(0,10)
	FontWidth = BG.MeasureStringWidth(Name, LCARSeffects2.StarshipFont, LCAR.Fontsize)
	X = X + Width - Radius * 3
	LCARSeffects4.DrawRect(BG,X - FontWidth - 2, Y + Height - OriginalFontHeight- 2, FontWidth + 4, OriginalFontHeight, OffWhite, 0)
	BG.DrawText(Name, X, Y + Height - 2, LCARSeffects2.StarshipFont, LCAR.Fontsize, Colors.Black, "RIGHT")'####.#
End Sub

Sub DrawOperationsTop(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, OffWhite As Int) As String 
	Dim StartDate As Long = API.GetToday(-1,-1), Events As List = API.EnumAllEvents(StartDate, StartDate + DateTime.TicksPerDay), Name As String, X2 As Int, Delimiter As String = ":", LineSize As Int, FontSize As Int = LCAR.Fontsize, temp As Int, temp2 As Int
	Dim ColWidth = Width * 0.0625, RowHeight As Int = Height / 6'0.1538461538461538'16 cols, 6.5 rows
	LCARSeffects4.DrawRect(BG, X, Y, Width, Height, OffWhite, 0) 'Middle inside
	LCARSeffects4.DrawGrid(BG,X,Y,Width,Height, ColWidth, RowHeight, Colors.Black, 1)
	LCARSeffects2.DrawRandomStars(BG,X,Y,Width,Height, Colors.Gray, 20, DateTime.Now)
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	If Events.Size > 0 Then'EVENT FOUND
		Dim tempEvent As CalendarEvent = Events.Get(0), Data As Map
		Data.Initialize
		Name = API.uCase(API.IIF(tempEvent.EventName.Length=0, tempEvent.Description, tempEvent.EventName))
		Data.Put(API.GetString("op_name"), Name)
		Data.Put(API.GetString("date_date"), API.DayLabel(tempEvent.StartTime, True))
		If tempEvent.AllDay Then 
			Data.Put(API.GetString("date_time"), API.GetString("date_allday"))
			Data.Put(API.GetString("stardate"), LCAR.Stardate(Widgets.StardateMode, tempEvent.StartTime, False, 0))
		Else 
			Data.Put(API.GetString("date_time"), API.TheTime(tempEvent.StartTime) & "-" & API.TheTime(tempEvent.EndTime))
			Data.Put(API.GetString("stardate"), LCAR.Stardate(Widgets.StardateMode, tempEvent.StartTime, False, 2)  & "-" & LCAR.Stardate(Widgets.StardateMode, tempEvent.EndTime, False, 2))
		End If
		Name = GetBiggestWord(Name)
		For temp = 0 To Data.Size - 1 
			temp2 = BG.MeasureStringWidth(Data.GetKeyAt(temp) & Delimiter, LCARSeffects2.StarshipFont, FontSize)
			If temp2 > X2 Then X2 = temp2 
		Next
		LineSize = BG.MeasureStringHeight("ABC123", LCARSeffects2.StarshipFont, FontSize) + 2
		Y = Y + Height * 0.5 - (LineSize*Data.Size) '* 0.5
		X2 = X + X2
		For temp = 0 To Data.Size - 1
			Y=Y+LineSize 
			BG.DrawText(Data.GetKeyAt(temp) & Delimiter, X, Y, LCARSeffects2.StarshipFont, FontSize, Colors.Black, "LEFT")
			BG.DrawText(Data.GetValueAt(temp), X2 * 0.5, Y+LineSize, LCARSeffects2.StarshipFont, FontSize, Colors.Black, "LEFT")
			Y=Y+LineSize
		Next
	Else'NO EVENT FOUND
		temp2 = ColWidth * 10
		BG.DrawLine(X + temp2, Y, X + temp2, Y + Height, Colors.Black, 2)	
		temp = Y + Height * 0.5 + RowHeight
		BG.DrawLine(X, temp, X + Width, temp, Colors.Black, 2)
		
		temp = Height * 0.12
		temp = DrawInsignia(BG, X + Rnd(temp, temp2), Y + Rnd(temp, Height - temp), temp, 5, 2, Colors.Black)'26x174/681x269, 31 FEDERATION
		
		'temp = Height * 0.10
		DrawInsignia(BG, X + Rnd(temp2, Width - temp), Y + Rnd(temp, Height - temp), temp, 5, 3, Colors.Black)'Klingon
		temp = Height * 0.09
		DrawInsignia(BG, X + Rnd(temp2, Width - temp), Y + Rnd(temp, Height - temp), temp, 5, 3, Colors.Black)'Klingon
		DrawInsignia(BG, X + Rnd(temp2, Width - temp), Y + Rnd(temp, Height - temp), temp, 5, 3, Colors.Black)'Klingon
		
		temp = Width * 0.04846'Width of Constitution
		For temp2 = 0 To 2
			DrawStarship(BG, X + Rnd(temp, ColWidth * 10), Y + Rnd(temp*0.5, Height - temp*0.5), temp2, temp, 90)
		Next		
	End If
	BG.RemoveClip
	If Name.Length = 0 Then Name = API.GetString("opret2")'Retrieve
	Return API.GetStringVars("opret0", Array As String(Name)) & " " & API.GetString("opret1")'"Operation [0]" Command Briefing
End Sub
Sub DrawOperationsBottom(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, OffWhite As Int, FontSize As Int, Stroke As Int, Radius As Int)
	Dim FontHeight As Int = BG.measurestringHeight("ABC123", LCARSeffects2.starshipfont, FontSize), temp As Int = FontHeight + Stroke * 2
	LCARSeffects4.DrawRect(BG, X, Y, Width, Height, OffWhite, 0)
	BG.DrawText(API.GetString("opret6"), X + Radius * 2, Y + Stroke + FontHeight, LCARSeffects2.starshipfont, FontSize, Colors.Black, "LEFT")
	Y = Y + temp
	Height = Height - temp 
	X = X + Radius * 2
	Width = Width - Radius * 3
	DrawRandomNumbers(BG, X, Y, Width, Height, Colors.Black, LCARSeffects2.starshipfont, FontSize, DateTime.Now)
End Sub
Sub DrawRandomNumbers(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Font As Typeface, FontSize As Int, Seed As Int)
	Dim WhiteSpace As Int = 1, FontHeight As Int = BG.measurestringHeight("123", Font, FontSize) + WhiteSpace, Digits As Int, ColWidth As Int, Y2 As Int, Bottom As Int = Y + Height, temp As Int, LeftAlignment As Boolean
	RndSeed(Seed)
	WhiteSpace=BG.MeasureStringWidth("0", Font, FontSize) * 0.5
	Do Until Width < 1 
		Y2=Y+FontHeight 
		Digits = Rnd(2,9)
		ColWidth = DigitWidth(BG, Font, FontSize, Digits)
		Do Until ColWidth <= Width Or Digits < 1
			Digits = Digits - 1 
			ColWidth = DigitWidth(BG, Font, FontSize, Digits)
		Loop
		If Digits = 0 Then 
			Width = 0
		Else 
			LeftAlignment = Rnd(0,2)=0
			Do Until Y2 >= Bottom 
				temp = Rnd(1, Power(10, Digits))
				If LeftAlignment Then 
					BG.DrawText(temp, X, Y2, Font, FontSize, Color, "LEFT")
				Else 
					BG.DrawText(temp, X+ColWidth, Y2, Font, FontSize, Color, "RIGHT")
				End If
				Y2 = Y2 + FontHeight
			Loop
				X = X + ColWidth + WhiteSpace
			Width = Width - ColWidth - WhiteSpace
		End If
	Loop
	API.SeedRND3
End Sub
Sub DigitWidth(BG As Canvas, Font As Typeface, FontSize As Int, Digits As Int) As Int 
	Dim tempstr As StringBuilder
	tempstr.Initialize
	Do Until Digits = 0
		tempstr.Append("0")
		Digits = Digits - 1 
	Loop
	Return BG.MeasureStringWidth(tempstr.ToString, Font, FontSize)
End Sub

Sub DrawDatasPainting(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Divisions As Int)
	Dim WhiteSpace As Int = Width * 0.0080971659919028, White As Int = Colors.RGB(231, 232, 237), temp As Int, tempHeight As Int 
	If Divisions = 0 Then Divisions = Rnd(10,20)' 13
	temp = Floor(Divisions*0.5)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,White,0)
	X=X+WhiteSpace
	Y=Y+WhiteSpace
	Width=Width-WhiteSpace*2
	Height=Height-WhiteSpace*2
	
	WhiteSpace=0.0171428571428571*Height
	tempHeight = (Height - WhiteSpace) * (Rnd(35,70) * 0.01)
	DrawDatasDivisions(BG,X,Y,Width,tempHeight, temp, WhiteSpace, White)
	LCARSeffects4.DrawRect(BG,X,Y+tempHeight,Width,WhiteSpace,Colors.Black,0)
	DrawDatasDivisions(BG,X,Y+tempHeight+WhiteSpace,Width,Height-tempHeight-WhiteSpace, Divisions-temp, WhiteSpace, White)
End Sub
Sub DrawDatasDivisions(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Divisions As Int, WhiteSpace As Int, White As Int)
	Dim Color As Int = -1, Size As Int, LeftTop As Boolean', OldColor As Int = -1 
	Do Until Divisions < 1
		Color = Rnd(0,9)
		Select Case Color 
			Case 0: Color = Colors.RGB(239,  86,   68)'Red
			Case 1: Color = Colors.Black 
			Case 2: Color = Colors.RGB(230, 194,   72)'Yellow
			Case 3: Color = Colors.RGB(46,   65,  194)'23,42,110)'Blue,
		End Select
		Size = Rnd(20,50)
		LeftTop = Rnd(0,2) = 0

		If Width > Height Then '----
			Size = Width * Size * 0.01
			If LeftTop Then 
				If Color < 4 Then LCARSeffects4.DrawRect(BG,X,Y, Size, Height, Color, 0)
				LCARSeffects4.DrawRect(BG,X + Size, Y, WhiteSpace, Height, Colors.Black, 0)
				X = X + Size + WhiteSpace 
			Else 
				If Color < 4 Then LCARSeffects4.DrawRect(BG,X+Width-Size,Y, Size, Height, Color, 0)
				LCARSeffects4.DrawRect(BG,X + Width - Size- WhiteSpace, Y, WhiteSpace, Height, Colors.Black, 0)
			End If 
			Width = Width - WhiteSpace - Size
		Else '|
			Size = Height * Size * 0.01
			If LeftTop Then 
				If Color < 4 Then LCARSeffects4.DrawRect(BG,X,Y, Width, Size, Color, 0)
				LCARSeffects4.DrawRect(BG,X, Y + Size, Width, WhiteSpace, Colors.Black, 0)
				Y = Y + Size + WhiteSpace
			Else 
				If Color < 4 Then LCARSeffects4.DrawRect(BG,X,Y+Height-Size, Width, Size, Color, 0)
				LCARSeffects4.DrawRect(BG,X, Y+Height-Size-WhiteSpace, Width, WhiteSpace, Colors.Black, 0)
			End If 
			Height = Height - WhiteSpace - Size 
		End If
		Divisions = Divisions - 1
	Loop
End Sub

Sub DrawWarpFieldStatus(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, ColorID As Int, WarpNacelle As String, Port As String, Starboard As String) As Boolean
	Dim Width2 As Int = Width * 0.2201, Height2 As Int = Height * 0.13861, Y2 As Int = Height * 0.20, Color As Int = LCAR.getcolor(ColorID, False, 255), Color2 As Int = LCAR.getcolor(ColorID, False, 128) 'LCARSeffects2.MaxStages As Int=16
	Dim SizeX As Int =Min(Width2,Height2)*0.5, BlackWidth As Int =SizeX * 0.125, BlackStart As Int =BlackWidth*2, WarpX As Int = Width * 0.66029, NX1 As Int = Width * 0.02392, NX2 As Int = Width * 0.33254
	Dim BarSize As Int = Height * 0.06, X2 As Int, Width3 As Int, WhiteSpace As Int = Height * 0.0198
	BlackWidth=BlackWidth*4
	
	Width3=NX2-NX1 - Width * 0.0239234449760766
	LCARSeffects2.DrawNacelle(BG, X + NX1, Y + Y2, Width2, Height2, Color2, Color, BlackStart, BlackWidth, Stage, ColorID)
	LCARSeffects2.DrawNacelle(BG, X + NX2, Y + Y2, Width2, Height2, Color2, Color, BlackStart, BlackWidth, Stage, ColorID)
	Color2 = LCAR.GetColorFlat2(ColorID, False, 128)
	DrawNacelle(BG, X + NX1, Y + WhiteSpace, Width3, Y2-WhiteSpace*2, Stage, ColorID, 3, WarpNacelle, Port,			Color, Color2)
	DrawNacelle(BG, X + NX2, Y + WhiteSpace, Width3, Y2-WhiteSpace*2, Stage, ColorID, 7, WarpNacelle, Starboard, 	Color, Color2)
		
	Y2 = Y2 + Height2 + 2
	X2 = NX1 + Width2 * 0.5 - BarSize * 0.5
	Height2 = Height * 0.5 - Y2 + 2
	LCARSeffects2.DrawBar(BG, X + X2, Y + Y2, BarSize, Height2, WarpX - X2, BarSize, Stage, Height2 * 0.5, Color, ColorID, False)	
	X2 = NX2 + Width2 * 0.5 - BarSize * 0.5
	LCARSeffects2.DrawBar(BG, X + X2, Y + Y2, BarSize, Height2 - BarSize-4, WarpX - X2, BarSize, Stage, Height2 * 0.5, Color, ColorID, False)
	
	X2 = X2 + BarSize * 2
	Y2 = Y2+ Height2 - BarSize-8
	NX2 = Width * 0.1244
	BlackStart = DrawWarpFieldButtons(BG, X + X2, Y + Y2, NX2, Height - Y2 - WhiteSpace * 2, Stage, ColorID, Color, 0, WhiteSpace, 0)'height of a unit
	
	BarSize = BarSize*2+10
	Y2 = Y + Height * 0.5 - BarSize * 0.5
	Height2 = Height * 0.97525
	Width2 = Width * 0.14115
	X = X + WarpX
	Y2 = LCARSeffects2.DrawWarpCore(BG, X, Y2, Width2, Height2, BarSize, Stage, 8, Color, ColorID, ColorID, Height * 0.20297, 2, True, Width * 0.07177, False, Width * 0.02392)
	X = X + Width2 + WhiteSpace 
	BlackWidth = BlackStart*2 + WhiteSpace
	DrawWarpFieldButtons(BG, X, Y2, NX2, BlackWidth, Stage, ColorID, Color, 1, WhiteSpace, BlackStart)
	WarpX = Y + Height * 0.5 - BlackStart*0.5
	DrawWarpFieldButtons(BG, X, WarpX, NX2, BlackStart, Stage, ColorID, Color, 2, WhiteSpace, BlackStart)
	Y2 = WarpX - Y2 - BlackWidth
	DrawWarpFieldButtons(BG, X, WarpX + BlackStart + Y2, NX2, BlackWidth, Stage, ColorID, Color, 3, WhiteSpace, BlackStart)
End Sub
Sub DrawWarpFieldButtons(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, ColorID As Int, Color As Int, Index As Int, WhiteSpace As Int, HeightOfUnits As Int) As Int 
	Dim Middle As Int = Width * 0.1111111111111111, Bottom As Int = Y + Height, Radius As Int, ID As Int = Index * 4, Alpha As Int'index: 0=left, 1=top, 2=middle, 3=bottom, stage(0-15)
	If HeightOfUnits = 0 Then HeightOfUnits = (Height - (WhiteSpace*3)) * 0.25
	Radius = HeightOfUnits * 0.5
	If Index <> 2 Then LCARSeffects4.DrawRect(BG, X + Width * 0.5 - Middle * 0.5, Y+HeightOfUnits*0.5, Middle, Height-HeightOfUnits, Color, 0)
	Do Until Y >= Bottom 
		Alpha = LCARSeffects2.Alpha512(Stage * 32, ID * 16)
		Alpha = Alpha * 0.75 + 64'shift up 64
		Color=LCAR.GetColorFlat2(ColorID, False, Alpha)
		LCARSeffects2.DrawRoundRect(BG,X, Y, Width, HeightOfUnits, Color, Radius)
		Y = Y + HeightOfUnits + WhiteSpace 
		ID = (ID + 1) Mod LCARSeffects2.MaxStages
	Loop
	Return HeightOfUnits
End Sub
Sub DrawNacelle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, ColorID As Int, Offset As Int, WarpNacelle As String, Side As String, Color1 As Int, Color2 As Int)
	Dim HalfStages As Int = LCARSeffects2.MaxStages*0.5, UnitWidth As Int = Floor(Width/HalfStages), WhiteSpace As Int = 2, FontSize As Int = LCAR.Fontsize * 0.5, FontHeight As Int = BG.MeasureStringHeight(Side, LCARSeffects2.StarshipFont, FontSize)
	Dim Height2 As Int, Width2 As Int , temp As Int, X2 As Int = X
	Stage = (Stage + Offset) Mod LCARSeffects2.MaxStages
	WarpNacelle = WarpNacelle.Replace("0", Side)
	BG.DrawText(WarpNacelle, X, Y + FontHeight, LCARSeffects2.StarshipFont, FontSize, Color1, "LEFT")
	Y=Y+FontHeight+WhiteSpace
	Height = Height - FontHeight - WhiteSpace
	Height2 = (Height - (WhiteSpace * 2)) * 0.5
	Width2 = (UnitWidth - WhiteSpace) * 0.5
	 
	LCARSeffects.MakeClipPath(BG,X,Y,Width, Height2)
	For temp = 0 To HalfStages - 1
		DrawNacelleBit(BG, X, Y,  UnitWidth-WhiteSpace, Height2, temp, Stage, Color1, Color2, Width2, True,  HalfStages)
		X = X + UnitWidth 
	Next
	BG.RemoveClip
	
	Y = Y + Height * 0.5 + WhiteSpace
	LCARSeffects.MakeClipPath(BG,X2,Y,Width, Height2)
	For temp = 0 To HalfStages - 1
		DrawNacelleBit(BG, X2, Y, UnitWidth-WhiteSpace, Height2, temp, Stage, Color1, Color2, Width2, False, HalfStages)
		X2 = X2 + UnitWidth
	Next
	BG.RemoveClip
End Sub
Sub DrawNacelleBit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, temp As Int, Stage As Int, Color1 As Int, Color2 As Int, Width2 As Int, IsTop As Boolean, HalfStages As Int)
	If IsTop Then 
		Color1 = GetColor(temp, Stage, HalfStages, Color1, Color2)
		BG.DrawCircle(X + Width2, Y + Width2, Width2, Color1, True, 0)
		Y=Y+Width2
	Else
		Color1 = GetColor(temp, Stage, HalfStages, Color2, Color1)
		BG.DrawCircle(X + Width2, Y + Height - Width2, Width2, Color1, True, 0)
	End If
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height - Width2, Color1, 0)
End Sub
Sub GetColor(temp As Int, Stage As Int, HalfStages As Int, Color1 As Int, Color2 As Int) As Int
	'0 1 2 3 4 5 6 7 8 9 A B C D E F
	If Stage > HalfStages Then
		Stage = Stage - HalfStages
		temp = temp Mod HalfStages
		If temp < Stage					Then Return Color2
	Else 
		If temp >= Stage 				Then Return Color2
	End If
	Return Color1 
End Sub



Sub DrawCaptainsWidget(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StartDate As Long, EndDate As Long)
	Dim LeftPart As Int = Width * 0.75, WhiteSpace As Int = 2, ColorID As Int = RNDENTcolor, Radius As Int = Min(Height * 0.19, Width * 0.08)
	Dim Stroke As Int = Min(Height * 0.05, Width * 0.01), HeightOfInsignia As Int = Min(Height * 0.43, Width * 0.1), FontSize As Int = LCAR.fontsize * 0.5
	Dim FontHeight As Int, tempstr(4) As String, FontWidth As Int, temp As Int, Color As Int, AllDay As String = "0000 ", X2 As Int, Y2 As Int 
	Dim Events As List = API.EnumAllEvents(StartDate, EndDate), tempEvent As CalendarEvent, Bottom As Int = Y + Height - Stroke * 2, MaxWidth As Int
	Dim SpaceNeeded As Int, StartOfRightPart As Int = X+LeftPart+WhiteSpace, RightPart As Int = Width - WhiteSpace - LeftPart
	LCARSeffects2.drawroundrect(BG,X,Y,Width, Height, Colors.Black, Radius)
	
	'Left half
	FontWidth = BG.MeasureStringWidth(AllDay, LCARSeffects2.StarshipFont, FontSize)
	FontHeight = BG.MeasureStringHeight(AllDay, LCARSeffects2.StarshipFont, FontSize)
	X2 = X + Radius
	Y2 = Y + Stroke * 2
	MaxWidth = LeftPart - Radius - Stroke * 2 - FontWidth
	
	Color = LCAR.GetColor(RNDENTcolor, False, 255)
	Y2 = Y2 + FontHeight
	BG.DrawText(API.GetDate(StartDate), X2, Y2, LCARSeffects2.StarshipFont, FontSize, Color, "LEFT")
	SpaceNeeded = Stroke * 4 + FontHeight
	
	If Events.Size = 0 Then 
		Events.Add(LCARSeffects3.MakeEvent(True, -1, API.GetString("mode4"), 0,0, "", "", 0))
	End If 
	For temp = 0 To Events.Size - 1 
		Y2 = Y2 + FontHeight + WhiteSpace
		SpaceNeeded = SpaceNeeded + FontHeight + WhiteSpace
		If Y2 > Bottom Then 
			temp = Events.Size
		Else 
			Color = LCAR.GetColor(RNDENTcolor, False, 255)
			tempEvent = Events.Get(temp)
			If tempEvent.AllDay Then tempstr(0) = AllDay Else tempstr(0) = API.TheTime(tempEvent.StartTime)
			tempstr(1)= API.LimitTextWidth(BG, API.uCase(API.IIF(tempEvent.EventName.Length=0, tempEvent.Description, tempEvent.EventName)), LCARSeffects2.StarshipFont, FontSize, MaxWidth, "...")
			BG.DrawText(tempstr(0), X2, Y2, LCARSeffects2.StarshipFont, FontSize, Color, "LEFT")
			BG.DrawText(tempstr(1), X2+FontWidth, Y2, LCARSeffects2.StarshipFont, FontSize, Color, "LEFT")
		End If 
	Next
	
	temp = Max(Radius, FontHeight + Stroke * 4) 'Stroke * 4 + WhiteSpace + FontHeight
	If Height - SpaceNeeded < temp Then'limited space
		LCARSeffects2.DrawPreCARSFrame(BG, X,Y,LeftPart, Height, ColorID, 255, 4, Radius, Stroke, "", 0, "")
	Else 'include bottom-left corner
		SpaceNeeded = Max(SpaceNeeded, Height - temp - WhiteSpace)
		LCARSeffects2.DrawPreCARSFrame(BG, X,Y,LeftPart, SpaceNeeded, ColorID, 255, 1, Radius, Stroke, "", 0, "")
		temp=Height-SpaceNeeded-WhiteSpace
		LCARSeffects2.DrawPreCARSFrame(BG, X,Y+SpaceNeeded+WhiteSpace,LeftPart, Height-SpaceNeeded-WhiteSpace, ColorID, 255, 7, Radius, Stroke, "", 0, "")
		LCARSeffects4.DrawRect(BG,X,Y+SpaceNeeded, Stroke, WhiteSpace, Colors.Black, 0)
		tempstr(0) = API.GetString("itin_btm")
		temp = temp-Stroke*4
		'FontSize = API.GetTextLimitedHeight(BG, temp,  LeftPart - Radius - Stroke * 3, tempstr(0), LCARSeffects2.StarshipFont)
		'FontHeight = BG.MeasureStringHeight(tempstr(0), LCARSeffects2.StarshipFont, FontSize)
		temp = (Y + Height - Stroke * 2) - temp*0.5 + FontHeight * 0.5
		BG.DrawText(tempstr(0), X2, temp, LCARSeffects2.StarshipFont, FontSize, LCAR.GetColor(ColorID, False, 255), "LEFT")
	End If
	
	'Right half
	LCARSeffects2.DrawPreCARSFrame(BG, StartOfRightPart,Y,RightPart, Height, ColorID, 255, 6, Radius, Stroke, "", 0, "")
	X = StartOfRightPart + RightPart*0.5
	Y = Y + Height * 0.4
	DrawInsignia(BG, X, Y, HeightOfInsignia, 5, 1, LCAR.GetColor(RNDENTcolor, False, 255))
	Y = Y + HeightOfInsignia * 0.5 + Stroke * 0.5
	Color = Colors.White 
	tempstr(0) = "CAPTAIN " & Main.YourName
	tempstr(1) = API.GetString("itin_com")
	tempstr(2) = "USS " & API.IIF(Main.Starshipname.Length=0, API.GetString("name_unnamed"), Main.Starshipname)
	tempstr(3) = Main.StarshipID
	FontWidth = RightPart - Stroke * 4
	For temp = 0 To tempstr.Length - 1 
		FontSize = Min(API.GetTextHeight(BG, -FontWidth, tempstr(temp), LCARSeffects2.StarshipFont), FontSize)
	Next 
	FontHeight = BG.MeasureStringHeight(tempstr(0), LCARSeffects2.StarshipFont, FontSize)
	For temp = 0 To tempstr.Length - 1
		If temp = 1 Then Color = LCAR.GetColor(ColorID, False, 255)
		Y=Y + FontHeight+1
		BG.DrawText(tempstr(temp), X, Y, LCARSeffects2.StarshipFont, FontSize, Color, "CENTER") 
	Next
 End Sub
 
Sub DrawENTBmeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Value As Int, ID As Int, Text As String, SideText As String, Align As Int)
	Dim Blue As Int = LCAR.GetColor(LCAR.Classic_Blue, False, 255), Fontsize As Int = LCAR.Fontsize*0.5, Stroke As Int, Green As Int = LCAR.GetColor(LCAR.Classic_Green, False, 255), LightBlue As Int, Turquoise As Int
	Dim temp As Int, temp2 As Int, temp3 As Int, temp4 As Int, Dot1 As Float, Dot2 As Float, UnitHeight As Int, Color As Int, Squares As Int, TextHeight As Int 
	Dim TopBlue As Float, TopGreen As Float, BottomBlue As Float, BottomGreen As Float, HalfStroke As Int, Digits As List 
	
	Select Case ID'ID: 0,1,2,3,4,5=left, 6,7,8,9,10=middle, 11,12,13,14,15,16=right
		'LEFT	BottomBlue is left
		Case 0
			TopGreen = 0.32363
			TopBlue = 0.60959
			Digits.Initialize2(Array As String("01", "02", "04", "08", "16", "32", "64", "128", "256", "512"))
		Case 1
			TopGreen = 0.63356
			TopBlue = 0.42123
			Digits.Initialize2(Array As String("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13"))
		Case 2
			TopGreen = 0.47432
			TopBlue = 0.57705
			Digits.Initialize2(Array As String("10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120", "130"))
		Case 3
			TopGreen =  0.44692
			TopBlue = 0.54452
			Digits.Initialize2(Array As String("03", "11", "22", "42", "53", "69", "78", "89", "91", "92", "99", "101", "111"))
		Case 4
			TopGreen = 0.32192
			TopBlue = 0.55651
			Digits.Initialize2(Array As String("05","21","32","39","41","47","55", "64", "77", "87", "89", "91", "94", "95"))
		Case 5
			TopGreen = 0.56021
			TopBlue = 0.48866
			Digits.Initialize2(Array As String("02","10","22","1217","2910","42","4951","421","252","8","433","77","4277","5288"))
			
		'MIDDLE
		Case 6
			TopBlue = 0.21538
			TopGreen = 0.46346
			BottomGreen = 0.64
			BottomBlue = 0.92885
			Squares = 2
			Digits.Initialize2(Array As String("060", "070", "080", "090", "100", "200", "300", "400", "500", "600", "700"))
		Case 7
			Dot1 = 0.41459
			Dot2 = 0.85029
			TopBlue = 0.46
			TopGreen = 0.46
			BottomGreen = 0.64875
			BottomBlue = 0.71785
			Squares = 1
			Digits.Initialize2(Array As String("10", "11", "12", "14", "18", "23", "26", "117", "230", "280", "401"))
		Case 8
			Dot1 = 0.23372
			Dot2 = 0.84866
			TopBlue = 0.32375
			TopGreen = 0.42529
			BottomGreen = 0.61
			BottomBlue = 0.79693
			Squares = 2
			Digits.Initialize2(Array As String(".01", ".1", ".2", ".3", ".4", ".5", ".6", ".7", ".8", ".9", "100"))
		Case 9
			TopBlue = 0.24952
			TopGreen = 0.38286
			BottomGreen = 0.62095
			BottomBlue = 0.62095
			Squares = 1
			Digits.Initialize2(Array As String("14", "15", "45", "50", "", "61", "90", "", "117", "250", "350"))
		Case 10
			Dot1 = 0.2271
			Dot2 = 0.87786
			TopBlue = 0.29008
			TopGreen = 0.29008
			BottomGreen = 0.62214
			BottomBlue = 0.85305
			Squares = 1
			Digits.Initialize2(Array As String("060", "070", "080", "090", "100", "200", "300", "400", "500", "600", "700"))
		
		'RIGHT
		Case 11
			TopGreen = 0.63317
			BottomBlue = 0.05779
			Digits.Initialize2(Array As String("02", "04", "06", "08", "10", "12", "14", "16", "18", "20"))
		Case 12 
			TopBlue = 0.34925
			TopGreen = 0.51508
			BottomBlue = 0.17588
			Digits.Initialize2(Array As String("05", "10", "15", "20", "25", "30", "35", "40", "45", "50"))
		Case 13
			TopBlue = 0.42211
			TopGreen = 0.48241
			BottomBlue = 0.20854
			Digits.Initialize2(Array As String("001", "003", "009", "027", "081", "243", "729"))
		Case 14
			TopBlue = 0.49749
			TopGreen = 0.38442
			BottomBlue = 0.23618
			Digits.Initialize2(Array As String("000", "010", "020", "030", "040", "050", "070", "080", "090", "100"))
		Case 15
			TopBlue = 0.52513
			TopGreen = 0.61558
			BottomBlue = 0.04523
			Digits.Initialize2(Array As String("25%", "50%", "75%"))
		Case 16 
			TopBlue = 0.44975
			TopGreen = 0.51005
			BottomBlue = 0.31658
			Digits.Initialize2(Array As String("1", "2", "3", "8", "15", "40", "90"))
	End Select

	If Text.Length > 0 Then 
		BG.DrawText(Text, X + Width * 0.5, Y + Height, LCARSeffects2.Starshipfont, Fontsize, Blue, "CENTER")
		TextHeight = BG.MeasureStringHeight(Text, LCARSeffects2.Starshipfont, Fontsize)
		Height = Height - TextHeight * 2 - 2
		If Squares > 0 Then 
			TextHeight = TextHeight * 2
			Height = Height - TextHeight
			temp= X + Width * 0.5
			If Squares = 1 Then 
				LCARSeffects2.DrawHollowRect(BG, temp - TextHeight - 2, Y + Height, TextHeight*2+2, TextHeight, Green, TextHeight*0.25)
			Else 
				LCARSeffects2.DrawHollowRect(BG, temp - TextHeight - 2, Y + Height, TextHeight, TextHeight, Green, TextHeight*0.25)
				LCARSeffects2.DrawHollowRect(BG, temp+ 2, Y + Height, TextHeight, TextHeight, Green, TextHeight*0.25)
			End If 
			Height = Height - 4
		End If
	End If 
	
	If ID < 6 Or ID > 10 Then 
		BottomGreen = 0.11344'tab height
		LightBlue = LCAR.GetColor(LCAR.Classic_LightBlue, False,255)
		Fontsize = Fontsize * 0.50
		TextHeight = BG.MeasureStringHeight("012", LCARSeffects2.StarshipFont, Fontsize)
	End If
	TopBlue = Height * TopBlue
	TopGreen = Height * TopGreen
	BottomGreen = Height * BottomGreen
	BottomBlue = Height * BottomBlue
	If ID < 6 Then
		'Turquoise = LCAR.GetColor(LCAR.Classic_Turq,False,255)
		temp = Width * 0.43'width of meter
		If ID=5 Then 
			temp2 = Width * 0.10
		Else 
			temp2 = Width * 0.15
		End If
		temp3 = X + Width - temp - temp2 * 1.5 - 2'X of meter
		LCARSeffects4.DrawRect(BG, temp3, Y, temp, TopGreen, Blue, 0)
		LCARSeffects4.DrawRect(BG, temp3, Y+TopGreen, temp, Height-TopGreen, LightBlue, 0)
		Align = Height * 0.025'40 lines
		temp3 = temp3 + Align 
		temp = temp - Align *2
		For temp4 = Y + Align To Y + Height - Align Step Align*2
			LCARSeffects4.DrawRect(BG, temp3, temp4, temp, Align, Colors.Black, 0)
		Next 
		
		LCARSeffects.MakeClipPath(BG,X,Y,Width,Height-1)
			temp4 = temp2*0.5'Halfwidth of bar
			temp3 = temp3 - Align - 2
			DrawDigits(BG, temp3, Y, Height, Digits, Green, Fontsize, TextHeight, LCARSeffects2.StarshipFont, "RIGHT")

			'Align= Height / Digits.size 
			'TextHeight = y + Align*0.5 + TextHeight * 0.5
			'For Turquoise = 0 To Digits.size - 1 
			'	BG.DrawText(Digits.Get(Turquoise), temp3, TextHeight, LCARSeffects2.StarshipFont, Fontsize, Green, "RIGHT")
			'	TextHeight = TextHeight + Align
			'Next 
			
			temp = X + Width - temp2-temp4'X of bar
			temp3 = Y + Value * 0.01 * Height - TopBlue * 0.5'Y of bar
			Select Case ID 'TopBlue is height of bar, BottomGreen is height of tab
				Case 0
					BottomBlue =  0.34062
					LCARSeffects4.DrawRect(BG,temp, temp3, temp4, BottomBlue, Green, 0)
					temp3 = temp3+BottomBlue+2
					LCARSeffects4.DrawRect(BG,temp, temp3, temp2, TopBlue-BottomBlue-2, Green, 0)
					DrawTab(BG,temp+temp2, temp3+temp2+temp4, temp4, BottomGreen,Green)
				Case 2
					BottomBlue = TopBlue*0.31395
					LCARSeffects4.DrawRect(BG,temp, temp3, temp4, BottomBlue, Blue, 0)
					LCARSeffects4.DrawRect(BG,temp, temp3+BottomBlue, temp2, TopBlue-BottomBlue, Green, 0)
					BottomBlue = TopBlue*0.64244
					DrawTab(BG,temp+temp2, temp3+BottomBlue, temp4, BottomGreen,Green)
				Case 1, 3
					BottomBlue = TopBlue*0.65931
					LCARSeffects4.DrawRect(BG,temp, temp3, temp2, BottomBlue, Green, 0)
					DrawTab(BG,temp+temp2, temp3+BottomBlue-temp4-BottomGreen, temp4, BottomGreen, Green)
					LCARSeffects4.DrawRect(BG,temp, temp3+BottomBlue+2, temp4, TopBlue-BottomBlue-2, Blue, 0)
				Case 4
					LCARSeffects4.DrawRect(BG,temp, temp3, temp2, TopBlue, Green, 0)
					DrawTab(BG,temp+temp2, temp3 + temp2, temp4, BottomGreen, Green)
				Case 5
					LCARSeffects4.DrawRect(BG,temp, temp3, temp4, TopBlue, LightBlue, 0)
					DrawTab(BG,temp+temp4, temp3 + TopBlue * 0.70504, temp4, BottomGreen, LightBlue)
			End Select 
		BG.RemoveClip
	else if ID < 11 Then
		TopBlue = Y + TopBlue
		TopGreen = Y + TopGreen
		BottomGreen = Y + BottomGreen
		BottomBlue = Y + BottomBlue
		
		temp = Y + Value * 0.01 * Height
		temp2 = Width  * 0.20
		temp3 = temp2 * 1.48
		Width = Width * 0.5
		Stroke = Width * 0.15
		HalfStroke = Stroke * 0.5
		LCARSeffects.DrawTriangle(BG, X-HalfStroke, temp - temp3 * 0.5, temp2, temp3, 3, Colors.Yellow)
		X = X + temp2 
		If Dot1 > 0 Then BG.DrawCircle(X, Y + Height * Dot1, Stroke*0.5, Green, True, 0)
		If Dot2 > 0 Then BG.DrawCircle(X, Y + Height * Dot2, Stroke*0.5, Green, True, 0)
		
		BG.DrawLine(X, TopBlue, X, BottomBlue, Blue, Stroke)
		BG.DrawLine(X, TopGreen, X, BottomGreen, Green, Stroke)
		X = X + Stroke
		BG.DrawLine(X, Y, X, Y+Height, Blue, Stroke)
		BG.DrawLine(X, TopGreen, X, BottomGreen, Green, Stroke)
		BG.DrawLine(X-HalfStroke, Y, X + Width+HalfStroke, Y, Blue, Stroke)
		BG.DrawLine(X, Y+Height-HalfStroke, X + Width, Y+Height-HalfStroke, Blue, Stroke)
		
		Width=Width*0.80
		UnitHeight = Height / 11
		temp = Width * 0.75
		temp2 = UnitHeight / 3
		Fontsize = Fontsize * 0.75
		TextHeight = BG.MeasureStringHeight("012", LCARSeffects2.StarshipFont, Fontsize)
		For Squares = 0 To 9
			DrawLines(BG,X,Y, temp, temp2, 2, HalfStroke, Blue, Green, TopGreen, BottomGreen, Digits.Get(Squares), Fontsize, TextHeight)
			Y = Y + UnitHeight
			If Y > TopGreen And Y < BottomGreen Then Color = Green Else Color = Blue
			BG.DrawLine(X, Y, X + Width, Y, Color, Stroke)
		Next
		DrawLines(BG,X,Y, temp, temp2, 2, HalfStroke, Blue, Green, TopGreen, BottomGreen, Digits.Get(10), Fontsize, TextHeight)
	else if ID < 17 Then
		LCARSeffects.MakeClipPath(BG,X-Width,Y,Width*2,Height-1)
		Width = Width * 0.33
		X = X + Width  
		DrawDigits(BG, X-2, Y, Height, Digits, Green, Fontsize, TextHeight, LCARSeffects2.StarshipFont, "RIGHT")
		temp3 = Y + Value * 0.01 * Height - TopGreen * 0.5'Y of bar, TopGreen is height of bar
		If ID = 16 Then 
			temp4 = Width*0.25
			X = X + temp4 
		Else 
			temp4 = Width*0.5
		End If
		DrawTab(BG, X + Width + 2, temp3, temp4, TopGreen, LightBlue)
		DrawTab(BG, X + Width + 2 + temp4, temp3+BottomBlue, temp4, BottomGreen, LightBlue)
		If TopBlue > 0 Then 
			LCARSeffects4.DrawRect(BG, X, Y, Width, TopBlue, Green, 0)
			Y = Y + TopBlue + 2
			Height = Height - TopBlue - 2
		End If
		LCARSeffects4.DrawRect(BG, X, Y, Width, Height, Blue, 0)
		BG.RemoveClip
 	Else 
		LCAR.DrawUnknownElement(BG,X,Y,Width, Height, LCAR.Classic_Blue, False, 255, ID & "=" & Value)
	End If 	
End Sub

'Alignment: "LEFT","CENTER","RIGHT"
Sub DrawDigits(BG As Canvas, X As Int, Y As Int, Height As Int, Digits As List, Color As Int, TextSize As Int, TextHeight As Int, Font As Typeface, Alignment As String)
	If Not(Digits.IsInitialized) Then Return 
	Dim UnitHeight As Int = Height / Digits.size, temp As Int
	If TextHeight = 0 Then TextHeight = BG.MeasureStringHeight("012", Font, TextSize)
	Y = Y + UnitHeight*0.5 + TextHeight * 0.5
	For temp = 0 To Digits.size - 1
		BG.DrawText(Digits.Get(temp), X, Y, Font, TextSize, Color, Alignment)
		Y = Y + UnitHeight
	Next
End Sub
Sub DrawTab(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	Dim P As Path 
	P.Initialize(X,Y)
	P.LineTo(X+Width, Y+Width)
	P.LineTo(X+Width, Y+Height-Width)
	P.LineTo(X, Y+Height)
	BG.drawpath(P, Color,True,0)
End Sub
Sub DrawLines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Lines As Int, Stroke As Int, Blue As Int, Green As Int, TopGreen As Int, BottomGreen As Int, Text As String, Fontsize As Int, FontHeight As Int)
	Dim Color As Int 
	BG.DrawText(Text, X + Width * 1.5, Y + Height * 1.5 + FontHeight * 0.5, LCARSeffects2.StarshipFont, Fontsize, Green, "LEFT")
	Do Until Lines < 1 
		Y=Y+Height 
		If Y > TopGreen And Y < BottomGreen Then Color = Green Else Color = Blue
		BG.drawline(X, Y, X + Width, Y, Color, Stroke)
		Lines = Lines - 1
	Loop
End Sub