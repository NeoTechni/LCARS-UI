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

	Dim DRD_TextSize As Int,DRD_TextHeight As Int, DRD_TextWidth As Int ,DRD_Font As Typeface , DRD_Red As Int = Colors.RGB(252,75,143), DRD_Height As Int , DRD_LightRed As Int = Colors.RGB(223,160,160)
	Dim DRD_DarkBlue As Int = Colors.RGB(21,54,125), DRD_LightBlue = Colors.RGB(76,220,229), DRD_DarkRed As Int = Colors.RGB(96,44,46)'Colors.RGB(48,22,23)'
	
	Type CylonText	(X As Float, Y As Float, Letter As String, FontSize As Int, Color As Int, Frames As Int, Speed As Float )
	Dim CylonFont As Typeface ,CylonLetters As List ,CylonLetterCount As Int = 100
	
	Type MiniButton(Text As String, ColorID As Int)
	Type MorseCodeDigit(State As Boolean, Duration As Int)
	Type Blinky(RegionID As Int, Morsecode As List, CurrentMorseDigit As Int, R As Int, G As Int, B As Int, TimeTillNextDigit As Int, X As Int, Y As Int, Width As Int, Height As Int, State As Boolean )
	Dim TRI_Speed As Int = 4, TRI_Click As Int ,TRI_Alpha As Int , TRI_X As Int, TRI_Scalefactor As Float ,TRI_FrontCamera As Boolean, TRI_Section As Int ,TRI_Subsection As Int
	Dim TRI_FrameA As Bitmap, TRI_FrameB As Bitmap, TRI_FrameC As Bitmap, TRI_Frame As Boolean ,TRI_Pixelspace As Int  = 2,CameraIsOn As Boolean,CameraToggled As Boolean,FlashIsOn As Boolean, TRI_GraphID As Int = -1
	Dim TRI_Buttons As List, TRI_Angle As Int, TRI_ElementID As Int ,TRI_State As Boolean  ,TRI_LastUpdate As Long ,Blinkies As List ,MorseUnit As Int = 100, TRI_Stage As Int, TRI_Delay As Int 
	Dim TRI_CurrentSensor As Int, TRI_Sensors(3) As Point, TRI_CameraOrientation As Int' ,TRI_Channel As Int = 1
	Dim TRI_GEO_A As Int = 0, TRI_MET As Int = 1, TRI_BIO As Int = 2, TRI_GEO_B As Int = 3
	Dim TRI_Text As List, TRI_TextClean As Boolean ,TRI_SampleRate As Int,TRI_RecData() As Short 
	
	Type Planet(Name As String, BodyType As Byte, Aphelion As Float, Perihelion As Float, SemiMajorAxis As Float, Eccentricity As Float, OrbitalPeriod As Double, Radius As Float, Degree As Double, Moons As Byte, Class As Byte)
	Dim EarthRadius As Int = 5, AstronomicalUnit As Int, SOL_LastUpdate As Long , SOL_LW As Float, SOL_LH As Float, Planets As List ,CurrentSystem As Int = -1
	Dim Sun As Byte = 0, ClassD As Byte = 1, ClassF As Byte = 2, ClassH As Byte = 3, ClassJ As Byte = 4, ClassK As Byte = 5, ClassL As Byte = 6, ClassM As Byte = 7, ClassN As Byte = 8, ClassP As Byte = 9, ClassT As Byte = 10, ClassY As Byte = 11
	Dim Asteroids As Byte = 20, SOL_Speed As Float = 1, SOL_Beige As Int = Colors.RGB(195,170,142), SOL_Bars As List , OldPoint As Point 
	
	'Event Horizon
	Dim EH_Stage As Int, EH_SubStage As Int , EH_MaxStage As Int = 256, EH_TextSize As Int, EH_OldHeight As Int ,EH_LastSecond As Int ,EH_TextHeight As Int , EH_Better As Boolean ,EH_TextSize2 As Int , EH_ItemHeight As Int
End Sub

Sub ResizeElement(Width As Int, Height As Int) As Int 
	Dim temp As Int 
	If Width <  Height Then
		Return Width * (Width /Height)
	Else
		Return Height
	End If
End Sub

Sub DrawOval(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, RelativeToCenter As Boolean)
	If RelativeToCenter Then
		BG.DrawOval(SetRect(X-Width*0.5,Y-Height*0.5,Width,Height),Color, Stroke=0, Stroke)
	Else
		BG.DrawOval(SetRect(X,Y,Width,Height),Color, Stroke=0, Stroke)
	End If
End Sub
Sub SetRect(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	Dim Rect1 As Rect 
	Rect1.Initialize(X,Y,X+Width,Y+Height)
	Return Rect1
End Sub
Sub DrawRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int) As Int 
	If Width >0 And Height> 0 Then BG.DrawRect(SetRect(X,Y,Width,Height), Color, Stroke=0,Stroke)
	Return Y+Height
End Sub
Sub DrawSliver(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Left As Boolean)
	Dim P As Path , Dest As Rect
	LCARSeffects2.MakePoint(P, X,Y+Height)
	If Left Then
		LCARSeffects2.MakePoint(P, X+Height,Y)
		LCARSeffects2.MakePoint(P, X+Width,Y)
	Else
		LCARSeffects2.MakePoint(P, X,Y)
		LCARSeffects2.MakePoint(P, X+Width-Height,Y)
	End If
	LCARSeffects2.MakePoint(P, X+Width,Y+Height)
	BG.DrawPath(P, Color, False, 2)
	BG.DrawPath(P, Color, True, 0)
	'LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 2, True, False)
	'DrawRect(BG,X,Y,Width,Height,Color,0)
	'BG.RemoveClip 
End Sub

'Left/Right side: -3=(/),-2=/for top-left/bottom-right edge,-1=/,0=|,1=\,2=\ for bottom-left/top-right edge, 3=triangle
'Align: -1=left, 0=center 1=right, 2=OOO
Sub DrawSliver2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, LeftSide As Int, RightSide As Int, Text As String,TextColor As Int, Align As Int) As Int 
	Dim P As Path , Dest As Rect, TextHeight As Int = Height*0.5 
	Select Case LeftSide'top to bottom
		Case -3'(
			BG.DrawCircle(X+TextHeight, Y+ TextHeight, TextHeight, Color, True,0)
			LCARSeffects2.MakePoint(P, X+TextHeight,Y)'top
			LCARSeffects2.MakePoint(P, X+TextHeight,Y+Height)'bottom
		Case -2'/ for top half only
			LCARSeffects2.MakePoint(P, X+TextHeight,Y)'top
			LCARSeffects2.MakePoint(P, X,Y+TextHeight)'middle
			LCARSeffects2.MakePoint(P, X,Y+Height)'bottom
		Case -1'/
			LCARSeffects2.MakePoint(P, X+Height,Y)'top
			LCARSeffects2.MakePoint(P, X,Y+Height)'bottom
		Case 0'|
			LCARSeffects2.MakePoint(P, X,Y)'top
			LCARSeffects2.MakePoint(P, X,Y+Height)'bottom
		Case 1'\
			LCARSeffects2.MakePoint(P, X,Y)'top
			LCARSeffects2.MakePoint(P, X+Height,Y+Height)'bottom
		Case 2'\ for bottom half only
			LCARSeffects2.MakePoint(P, X,Y)'top
			LCARSeffects2.MakePoint(P, X,Y+TextHeight)'top
			LCARSeffects2.MakePoint(P, X+TextHeight,Y+Height)'bottom
		Case 3'triangle
			TextHeight= Height/3
			LCARSeffects2.MakePoint(P, X+TextHeight*2,Y+TextHeight)'below top point
			LCARSeffects2.MakePoint(P, X+TextHeight*2,Y)'top point
			LCARSeffects2.MakePoint(P, X,Y+TextHeight*2)'left point
			LCARSeffects2.MakePoint(P, X+Width-TextHeight*2,Y+TextHeight*2)'above bottom point
			LCARSeffects2.MakePoint(P, X+Width-TextHeight*2,Y+Height)'bottom point
			LCARSeffects2.MakePoint(P, X+Width, Y+TextHeight)'right point
	End Select
	Select Case RightSide'bottom to top
		Case -3')
			BG.DrawCircle(X+Width-TextHeight, Y+ TextHeight, TextHeight, Color, True,0)
			LCARSeffects2.MakePoint(P, X+Width-TextHeight,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width-TextHeight,Y)'top
		Case -2'/ for bottom half only
			LCARSeffects2.MakePoint(P, X+Width-TextHeight,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width,Y+TextHeight)'middle
			LCARSeffects2.MakePoint(P, X+Width,Y)'top
		Case -1'/
			LCARSeffects2.MakePoint(P, X+Width-Height,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width,Y)'top
		Case 0'|
			LCARSeffects2.MakePoint(P, X+Width,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width,Y)'top
		Case 1'\
			LCARSeffects2.MakePoint(P, X+Width,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width-Height,Y)'top
		Case 2'\ for top half only
			LCARSeffects2.MakePoint(P, X+Width,Y+Height)'bottom
			LCARSeffects2.MakePoint(P, X+Width,Y+TextHeight)'middle
			LCARSeffects2.MakePoint(P, X+Width-TextHeight,Y)'top
	End Select
	'LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 2, False, False)
	BG.ClipPath(P)
	DrawRect(BG,X,Y,Width,Height,Color,0)
	DrawScanlines(BG,X,Y,Width,Height,Colors.Black, 3,0,1)
	If Text.Length>0 Then
		LeftSide = API.GetTextHeight(BG, -(Width-Height*2), Text,DRD_Font)
		TextHeight=BG.MeasureStringHeight(Text,DRD_Font,LeftSide) 
		Y=Y+ (Height*0.5) + (TextHeight*0.5)
		Select Case Align
			Case -1:	BG.DrawText(Text, X+Height, 		Y, DRD_Font, LeftSide, TextColor, "LEFT")   'left
			Case 0:		BG.DrawText(Text, X+Width*0.5, 		Y, DRD_Font, LeftSide, TextColor, "CENTER") 'center
			Case 1:		BG.DrawText(Text, X+Width-Height, 	Y, DRD_Font, LeftSide, TextColor, "RIGHT")  'right
		End Select
	Else 
		Select Case Align
			Case 2'000
				TextHeight=Height*0.5
				LeftSide=Min(Height*0.4, (Width-(Height*2))/7)
				Align=Height+TextHeight
				BG.DrawCircle(X+Align, Y+TextHeight, LeftSide, TextColor,True, 0)
				BG.DrawCircle(X+Align, Y+TextHeight, LeftSide*0.2, Color,True, 0)
				
				BG.DrawCircle(X+Width*0.5, Y+TextHeight, LeftSide, TextColor,True, 0)
				BG.DrawCircle(X+Width*0.5, Y+TextHeight, LeftSide*0.2, Color,True, 0)
				
				BG.DrawCircle(X+Width-Align, Y+TextHeight, LeftSide, Colors.White,True, 0)
				BG.DrawCircle(X+Width-Align, Y+TextHeight, LeftSide*0.2, Color,True, 0)
			Case 3'gradient bar
				X=X+TextHeight+4
				Width=Width-TextHeight-Height-8
		End Select
	End If
	BG.RemoveClip 
	Return X+Width
End Sub

Sub DrawDRADIS(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Scanline As Int) As Rect 
	Dim temp As Int,temp2 As Int,temp3 As Int ,temp4 As Int,cW As Int = Width * 0.09, cH As Int,TextHeight As Int '= Height * 0.115'0.1095100864553314
	If Not(DRD_Font.IsInitialized) Then DRD_Font = Typeface.LoadFromAssets("dradis.ttf")
	
	Height=Height+1
	If Width < Height Then
		temp = ResizeElement(Width,Height)
		Y= Y + (Height*0.5) - (temp*0.5)
		Height=temp
	End If
	cH = Height * 0.115
	If DRD_TextSize = 0 Or DRD_Height <> Height Then 
		DRD_TextSize = 10
		DRD_Height=Height
		DRD_TextWidth = BG.MeasureStringWidth("999 ", DRD_Font, DRD_TextSize)
		DRD_TextHeight = BG.MeasureStringHeight("999", DRD_Font, DRD_TextSize)
	End If

	DrawRect(BG,X,Y,Width, LCAR.ItemHeight, Color, 0)'top
	DrawRect(BG,X,Y+LCAR.ItemHeight, DRD_TextWidth*1.5, Height-LCAR.ItemHeight, Color, 0)'left
	DrawRect(BG,X+Width-DRD_TextWidth*1.5,Y+LCAR.ItemHeight, DRD_TextWidth*1.5, Height-LCAR.ItemHeight, Color, 0)'right
	DrawRect(BG,X,Y+Height-LCAR.ItemHeight,Width, LCAR.ItemHeight, Color, 0)'bottom
	
	DrawCorner(BG, X+DRD_TextWidth*1.5, Y+LCAR.ItemHeight, cW,cH, Color, 0)'top left
	DrawCorner(BG, X+Width-DRD_TextWidth*1.5-cW, Y+LCAR.ItemHeight, cW,cH, Color, 1)'top right
	DrawCorner(BG, X+DRD_TextWidth*1.5, Y+Height-LCAR.ItemHeight-cH, cW,cH, Color, 2)'bottom left
	DrawCorner(BG, X+Width-DRD_TextWidth*1.5-cW, Y+Height-LCAR.ItemHeight-cH, cW,cH, Color, 3)'bottom right
	
	DrawRoundRect(BG,X+LCAR.ItemHeight*0.5, Y+ LCAR.ItemHeight*0.1+1, Width-LCAR.ItemHeight, LCAR.ItemHeight*0.8, Colors.Black, "", 0, 0, 0, 0)'top	
	DrawRoundRect(BG,X+LCAR.ItemHeight*0.5, Y+Height- LCAR.ItemHeight*0.9+1, Width-LCAR.ItemHeight, LCAR.ItemHeight*0.8, Colors.Black, "", 0, 0, 0, 0)'bottom
	
	BG.DrawLine(X+DRD_TextWidth*1.5, Y+Height-LCAR.ItemHeight-cH-DRD_TextWidth*1.5,    X+DRD_TextWidth*2.5, Y+Height-LCAR.ItemHeight-cH-DRD_TextWidth*2.5, Color, 3)
	BG.DrawLine(X+DRD_TextWidth*2.5,Y+Height-LCAR.ItemHeight-cH-DRD_TextWidth*2.5,     X+DRD_TextWidth*2.5,Y+cH+LCAR.ItemHeight, Color,3)
	
	'DrawRect(BG, X+DRD_TextWidth*0.25, Y+LCAR.ItemHeight+cH, DRD_TextWidth, Height - LCAR.ItemHeight*2 - cH*2 - DRD_TextWidth*1.5, Colors.Black, 0)'left
	DrawMeter(BG, X+DRD_TextWidth*0.25, Y+LCAR.ItemHeight+cH, DRD_TextWidth, Height - LCAR.ItemHeight*2 - cH*2 - DRD_TextWidth*1.5, Color)'left
	temp=DRD_TextWidth*0.75
	DrawRoundCorner(BG,      X+temp, Y+LCAR.ItemHeight+cH-DRD_TextWidth*0.5, 0, 0, 				DRD_TextWidth*0.5, Colors.Black, True,False, cW/cH)
	
	DrawRect(BG, X+Width-DRD_TextWidth*1.25, Y+Height*0.5, DRD_TextWidth, Height * 0.5 - LCAR.ItemHeight - cH, Colors.Black, 0)'right
	DrawRoundCorner(BG, X+Width-temp, Y+Height-LCAR.ItemHeight - cH+DRD_TextWidth*0.5, 	 X+Width-temp*2, Y+Height-LCAR.ItemHeight - cH-temp,	DRD_TextWidth*0.5, Colors.Black, True,True, cW/cH)
	
	If Scanline>0 Then DrawScanlines(BG,X,Y,Width,Height, Colors.Black, Scanline,0,1)
	
	temp = DRD_TextWidth * 0.25
	DrawSliver(BG, X, Y+ LCAR.ItemHeight + cH - temp, DRD_TextWidth*3+temp*4, temp, Color, False)'under top left
	DrawSliver(BG, X, Y+ LCAR.ItemHeight + cH - temp*3, DRD_TextWidth*3+temp*2, temp, Color, False)'top left
	
	TextHeight = cH - temp*4
	temp2= Y+ LCAR.ItemHeight + temp*0.5
	temp3= DrawRoundRect(BG,	X+cW+DRD_TextWidth*1.5, temp2, Width*0.13, TextHeight, DRD_DarkRed, "CENTRAL TRK", DRD_Red, 0,0, 0)+ 5
	DrawRoundRect(BG,temp3,temp2, Width*0.08,TextHeight,DRD_DarkRed, "H54 TAC", DRD_Red, 0,0, 0)
	
	temp3= X+Width-(cW+DRD_TextWidth*1.5)
	temp4=Width*0.065
	DrawRoundRect(BG, temp3-temp4, temp2, temp4, TextHeight, DRD_DarkRed,"OBJ/PKT", DRD_Red,0,0, 0)
	temp3=temp3-(temp4*2)-5
	DrawRoundRect(BG, temp3, temp2, temp4, TextHeight, DRD_DarkRed,"OBJ", DRD_Red,0,0,0)
	temp4=temp4*2
	
	DrawRoundRect(BG, temp3-temp4-5, temp2, temp4, TextHeight, DRD_DarkRed,"SECONDARY T", DRD_Red,0,0,0)
	DrawRoundRect(BG, temp3-temp4*2-10, temp2, temp4, TextHeight, DRD_DarkRed,"PRIMARY T", DRD_Red,0,0,0)
	
	temp2=DrawSliver2(BG, X+DRD_TextWidth*3+temp*2, Y+ LCAR.ItemHeight + cH - temp*3, Width*0.13, temp*3, DRD_Red, 1,1, "DRADIS", Colors.White, -1)
	DrawSliver2(BG, temp2, Y+ LCAR.ItemHeight + cH - temp*3, temp*9,temp*3,DRD_Red, 1,-1,"", 0,0)
	
	temp2=X+Width-(DRD_TextWidth*3+temp*4)
	DrawSliver(BG, temp2, Y+ LCAR.ItemHeight + cH - temp, DRD_TextWidth*3+temp*4, temp, Color, True)'under top right
	DrawSliver(BG, X+Width-(DRD_TextWidth*3+temp*2), Y+ LCAR.ItemHeight + cH - temp*3, DRD_TextWidth*3+temp*2, temp, Color, True)'top right
	TextHeight = Width*0.13 + temp*9
	DrawSliver2(BG,temp2-TextHeight+temp*2,Y+ LCAR.ItemHeight + cH - temp*3, TextHeight, temp*3, DRD_Red, 1,-1, "FIRMWARE: " & LCAR.CurrentVersion, Colors.White,-1)
	
	DrawRect(BG, X, Y+Height - LCAR.ItemHeight-temp*3, DRD_TextWidth*1.5 + cW + temp*2, temp, Color, 0)'bottom left
	temp2=DrawSliver2(BG, X+DRD_TextWidth*1.5 + cW + temp*2+5,Y+Height - LCAR.ItemHeight-temp*4, Width*0.13, temp*3, DRD_Red, 1,1, "", DRD_Red, 2)
	temp2=DrawSliver2(BG, temp2-temp, Y+Height - LCAR.ItemHeight-temp*4, temp*6,temp*3,DRD_Red, 1,1,"", 0,0)
	DrawSliver2(BG, temp2-temp, Y+Height - LCAR.ItemHeight-temp*4, Width*0.13,temp*3, DRD_Red,1,1, "SYS 4EN", Colors.White, -1)
	
	temp2=X+Width-(DRD_TextWidth*1.5 + cW + temp*2)
	DrawRect(BG, temp2, Y+Height - LCAR.ItemHeight-temp*3, DRD_TextWidth*1.5 + cW + temp*2, temp, Color, 0)'bottom right
	cW =  temp*4 + Width*0.26
	DrawSliver2(BG, temp2-cW-5,Y+Height - LCAR.ItemHeight-temp*4, cW, temp*3, DRD_Red, -1,-1, "CONFIGURATION PROFILE (USER DEFINED)", Colors.White,1)
	
	
	'Text buttons
	temp = BG.MeasureStringWidth(" SHUT DOWN ", DRD_Font, LCAR.Fontsize)
	cW=LCAR.Fontsize
	cH=Width - (LCAR.ItemHeight*2)
	If cH / temp < 4 Then  
		cW = API.GetTextHeight(BG, - cH*0.25, " SHUT DOWN ", DRD_Font)
		temp = BG.MeasureStringWidth(" SHUT DOWN ", DRD_Font, cW)
	End If
	TextHeight = BG.MeasureStringHeight("ABC", DRD_Font, cW) *0.5 
	DrawRoundRect(BG, X+LCAR.ItemHeight, Y+ LCAR.ItemHeight*0.15, temp, LCAR.ItemHeight*0.7, DRD_DarkRed, "SYS REL", Colors.White, TextHeight,cW,0)
	DrawRoundRect(BG, X+LCAR.ItemHeight+temp+5, Y+ LCAR.ItemHeight*0.15, temp, LCAR.ItemHeight*0.7, DRD_DarkRed, "SHUT DOWN", Colors.White, TextHeight,cW,0)
	DrawRoundRect(BG, X+Width-LCAR.ItemHeight-temp, Y+ LCAR.ItemHeight*0.15, temp, LCAR.ItemHeight*0.7, DRD_DarkRed, "ABORT", Colors.White, TextHeight,cW,0)
	
	'Gradient at the bottom
	DrawGradientBar(BG, X+LCAR.ItemHeight*0.5, Y+Height- LCAR.ItemHeight*0.9+1, Width-LCAR.ItemHeight, LCAR.ItemHeight*0.8)
End Sub

Sub DrawGradientBar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	'DRD_DarkBlue  DRD_LightBlue
	LCARSeffects.MakeClipPath(BG,X,Y+(Height*0.4),Width,Height*0.6)
		X=X+4
		Width=Width-8
		Y=Y+4
		Height=Height-8
		
		DrawRoundRect(BG,X,Y, Width*0.10, Height-1, DRD_LightBlue, "", 0,0, 0,0)
		DrawRoundRect(BG,X+Width*0.90,Y, Width*0.10, Height-1, DRD_DarkBlue, "", 0,0, 0,0)
		
		DrawGradientBit(BG,X,Y,Width,Height,	0.07,	0.08, 0, False)
		
		DrawRect(BG,   X+ Width*0.26, Y, Width *0.12, Height-1, DRD_LightBlue, 0)
		DrawGradientBit(BG,X,Y,Width,Height,	0.145,	0.12,  0,True)
		
		DrawRect(BG,   X+ Width*0.48, Y, Width *0.12, Height-1, DRD_DarkBlue, 0)
		DrawGradientBit(BG,X,Y,Width,Height,	0.37,	0.12,  0,False)
		
		DrawGradientBit(BG,X,Y,Width,Height,	0.59,	0.10,  0,True)
		DrawGradientBit(BG,X,Y,Width,Height,	0.68,	0.05,  0,False)
		
		DrawRect(BG,   X+ Width*0.76, Y, Width *0.10, Height-1, DRD_LightBlue, 0)
		DrawGradientBit(BG,X,Y,Width,Height,	0.72,	0.05,  0,True)
	BG.RemoveClip 
		
	LCARSeffects.MakeClipPath(BG,X,Y+(Height*0.4),Width*0.95,Height*0.6)
		DrawGradientBit(BG,X,Y,Width,Height,	0.88,	0.04,  0,True)
		DrawGradientBit(BG,X,Y,Width,Height,	0.85,	0.04,  0,False)
		DrawGradientBit(BG,X,Y,Width,Height,	0.91,	0.04,  0,False)
	BG.RemoveClip 

	
	Width=Width - LCAR.ItemHeight*0.5
	Dim temp As Int, Right As Int= X + Width, Move As Int = Width/21, TextSize As Int = API.GetTextHeight(BG, Height*0.35, "0123", DRD_Font)
	Y= Y+ BG.MeasureStringHeight("0123", DRD_Font,TextSize)
	X = X + LCAR.ItemHeight*0.5 
	For temp = 0 To 100 Step 5
		BG.DrawText( API.PadtoLength(temp, True,2, "0"), X, Y, DRD_Font, TextSize, DRD_LightBlue, "CENTER")
		X=X+Move
	Next
End Sub

'Mode: False = light to dark, True = dark to light
Sub DrawGradientBit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Start As Float, WidthF As Float, CornerRadius As Int, Mode As Boolean)
	LCAR.DrawGradient(BG, API.IIF(Mode, DRD_DarkBlue,DRD_LightBlue),API.IIF(Mode, DRD_LightBlue,DRD_DarkBlue), 6, X+(Width*Start),Y,Width*WidthF,Height,CornerRadius,0)
End Sub

Sub DrawMeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	Dim temp2 As Int , Whitespace As Int = 1, temp As Int = Y+Height - DRD_TextHeight - Whitespace, tempstr As String 
	DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
	'X=X+(Width*0.5)
	Width=Width / 3
	Do Until temp < Y
		tempstr =  API.PadtoLength(temp2, True,3, "0")
		BG.DrawText(API.Left(tempstr,1),  X+Width ,temp + DRD_TextHeight, DRD_Font,  DRD_TextSize, Color, "RIGHT")
		BG.DrawText(API.mid(tempstr,1,1),  X+Width*2 ,temp + DRD_TextHeight, DRD_Font,  DRD_TextSize, Color, "RIGHT")
		BG.DrawText(API.right(tempstr,1),  X+Width*3 ,temp + DRD_TextHeight, DRD_Font,  DRD_TextSize, Color, "RIGHT")
		temp = temp - DRD_TextHeight - Whitespace
		temp2=temp2+10
	Loop
End Sub

'Align: -1=left, 0=center, 1=right
Sub DrawRoundRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Text As String, TextColor As Int, TextHeight As Int, FontSize As Int, Align As Int)As Int 
	Dim temp As ColorDrawable 
	If Width>Height Then
		temp.Initialize(Color, Height*0.5)
	Else
		temp.Initialize(Color, Width*0.5)
	End If
	BG.DrawDrawable(temp, SetRect(X,Y,Width,Height))
	If Text.Length>0 Then
		If FontSize = 0 Then FontSize = API.GetTextHeight(BG, -Width+Height, Text,DRD_Font)
		If TextHeight = 0 Then TextHeight = BG.MeasureStringHeight(Text, DRD_Font, FontSize )*0.5
		Select Case Align
			Case -1: BG.DrawText(Text, X+10, Y+Height*0.5 + TextHeight, DRD_Font, FontSize, TextColor, "LEFT")'left
			Case 0: BG.DrawText(Text, X+Width*0.5, Y+Height*0.5 + TextHeight, DRD_Font, FontSize, TextColor, "CENTER")'center
			Case 1:BG.DrawText(Text, X+Width-10, Y+Height*0.5 + TextHeight, DRD_Font, FontSize, TextColor, "RIGHT")'right
		End Select
	End If
	Return X+Width
End Sub

Sub DrawScanlines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, LinesBetween As Int, StartLine As Int, Stroke As Int)
	Dim temp As Int ,Right As Int = X+Width
	For temp = Y + StartLine To Y+Height Step LinesBetween
		BG.DrawLine(X, temp,  Right, temp, Color,Stroke)
	Next
End Sub

'Align: 0=top left, 1=top right, 2=bottom left, 3=bottom right
Sub DrawCorner(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Align As Int)
	Dim P As Path , Dest As Rect 
	If Align < 3 	Then LCARSeffects2.MakePoint(P, X,Y)'0
	If Align <> 2 	Then LCARSeffects2.MakePoint(P, X+Width,Y)'1
	If Align <> 1 	Then LCARSeffects2.MakePoint(P, X,Y+Height)'2
	If Align >0 	Then LCARSeffects2.MakePoint(P, X+Width,Y+Height)'3
	
	'LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 2, True, False)
	'BG.ClipPath(Pt)
	BG.DrawPath(P, Color, False, 2)
	BG.DrawPath(P, Color, True, 0)
	'DrawRect(BG,X,Y,Width,Height,Color,0)
	'BG.RemoveClip 
End Sub

Sub DrawRoundCorner(BG As Canvas, X As Int, Y As Int, X2 As Int, Y2 As Int, Radius As Int, Color As Int, UseFirst As Boolean, GoUp As Boolean, Aspect As Float)
	BG.DrawCircle(X,Y,Radius,Color,True,0)
	If Aspect <> 0 Then
		If GoUp Then 
			X2= X - Radius * Aspect
			Y2= Y + Radius '* Aspect
		Else
			X2= X + Radius * Aspect
			Y2= Y - Radius '* Aspect
		End If
	End If
	BG.DrawCircle(X2,Y2,Radius,Color,True,0)
	BG.DrawLine(X,Y,X2,Y2,Color,Radius*2)
	If Not(UseFirst) Then
		X=X2
		Y=Y2
	End If
	DrawRect(BG,X-Radius, API.IIF(GoUp, Y-Radius-1, Y), Radius*2, Radius,Color,0)
End Sub

'Halign: 0=left align, 1=center, 2=right align. Valign: 0=below Y, 1=center, 2=above y
Sub DrawDRADISText(BG As Canvas, X As Int, Y As Int, FontSize As Int , MaxWidth As Int, Text As String, TextColor As Int, Halign As Int, Valign As Int) As Int 
	Dim TextHeight As Int 
	If Text.Length>0 Then
		If Not(DRD_Font.IsInitialized) Then DRD_Font = Typeface.LoadFromAssets("dradis.ttf")
		If FontSize = 0 Then
			If MaxWidth >0 Then FontSize = API.GetTextHeight(BG, -MaxWidth, Text,DRD_Font) Else FontSize= LCAR.FontSize
		End If
		TextHeight = BG.MeasureStringHeight(Text, DRD_Font, FontSize )
		If Valign=1 Then TextHeight=TextHeight*0.5
		If Valign<2 Then Y=Y+TextHeight
		BG.DrawText(Text, X, Y, DRD_Font, FontSize, TextColor, API.IIFIndex(Halign, Array As String("LEFT", "CENTER", "RIGHT")))
		Return FontSize
	End If
End Sub



Sub GetUseableSpace(X As Int, Y As Int, Width As Int, Height As Int, FullScreen As Boolean) As Rect 
	Dim temp As Int
	If Width < Height Then
		temp = ResizeElement(Width,Height)
		Y= Y + (Height*0.5) - (temp*0.5)
		Height=temp
	End If
	If Not(FullScreen) Then 
		temp  = Width * 0.09
		X=X+ (DRD_TextWidth*1.5) + temp
		Width= Width-(DRD_TextWidth*3)-(temp*2)
		temp=Height * 0.115
		Y= Y+ LCAR.ItemHeight+temp *2
		Height= Height - (LCAR.ItemHeight*2)-(temp*3) 
	End If
	Return SetRect(X,Y,Width,Height)
End Sub

Sub DrawDRADISTimer(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Time As Int)
	Dim Screen As Rect = GetUseableSpace(X,Y,Width,Height,False), X2 As Int = Screen.Left, Y2 As Int = Screen.Top, Width2 As Int = Screen.Right-Screen.Left, Height2 As Int = Screen.Bottom - Screen.Top 
	
	Dim temp As Int = Height2*0.07, temp2 As Int =Height2*0.5 , temp3 As Int = Width2*0.33 , temp4 As Int=temp2*0.2241379310344828 , P As Path ,Textsize As Int
	LCARSeffects.MakeClipPath(BG,X2,Y2,Width2,Height2)
	DrawRect(BG,X2,Y2,Width2, temp, DRD_LightRed,0)'top
	temp=temp*0.5
	DrawRect(BG,X2,Y2, temp    ,temp2,DRD_LightRed,0)'left
	DrawRect(BG,X2+Width2-temp,Y2, temp    ,temp2,DRD_LightRed,0)'right
	BG.DrawLine(X2, Y2+temp2,X2+temp3, Y2+Height2, DRD_LightRed,temp)'\
	BG.DrawLine(X2 + Width2, Y2+temp2,X2+Width2- temp3, Y2+Height2, DRD_LightRed,temp)'/
	DrawRect(BG,X2+temp3-temp*0.5, Y2+Height2- temp, temp3+temp*2, temp,  DRD_LightRed,0)'_
	BG.RemoveClip 
	
	DrawDRADIS(BG,X, Y, Width,Height, DRD_Red, 3)
	
	Dim Hours As Int = Floor(Time / 3600), Minutes As Int = (Time Mod 3600) / 60, Seconds As Int = Time Mod 60, temp5 As Int = Width2*0.0958605664488017
	LCAR.ActivateAA(BG,True)
	Textsize= DrawDRADISText(BG,X2+temp+2, Y2+temp*2+2,  0, Width2*0.25, "FTL JUMP COUNTDOWN", DRD_LightRed, 0,0)
	DrawDigital(BG, X2+temp*2+temp5, Y2+ temp4, Width2-temp5*2, temp2-temp4*2, 					Hours,Minutes,Seconds, Time>-1)
	DrawCountDown(BG, X2+temp5*0.5, Y2+temp2, Width2-temp5,Height2, 	temp3,temp2-temp5*0.25,	Hours,Minutes,Seconds, Time>-1,DRD_LightRed, Textsize)
End Sub

Sub DrawCountDown(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, temp As Int,temp2 As Int, Hours As Int, Minutes As Int, Seconds As Int, IsNegative As Boolean, Color As Int, Textsize As Int)
	Dim Pt As Path, Degree As Int=150 ,X2 As Int 
	LCARSeffects2.MakePoint(Pt, X,Y)
	LCARSeffects2.MakePoint(Pt, X+temp*2,Y+Height)
	LCARSeffects2.MakePoint(Pt, X+Width-temp*2,Y+Height)
	LCARSeffects2.MakePoint(Pt, X+Width,Y)
	temp=Colors.RGB(32,32,32)
	'LCARSeffects2.CopyPlistToPath(P, Pt, BG, temp, 0, False, False)
	BG.ClipPath(Pt)
	DrawRect(BG,X,Y,Width,temp2,temp,0)
	
	
	Height=temp2
	temp=Height*0.5
	X=X+Width*0.5
	Y=Y+temp
	BG.DrawCircle(X, Y,  temp, Colors.Black, True,0)
	BG.RemoveClip 
	
	BG.DrawLine(X,Y, X-temp,Y, Color,2)'middle
	DrawDRADISText(BG, X-temp-10,  Y,  Textsize, 0, "ME2 (-12)", Color, 2,1)
	
	BG.DrawLine(X,Y-temp*0.95, X-temp,Y-temp*0.95, Color,2)'top
	DrawDRADISText(BG, X-temp-10,  Y-temp*0.95,  Textsize, 0, "FTL JUMP", Color, 2, 0)
	
	BG.DrawLine(X,Y-temp*0.60, X-temp,Y-temp*0.60, Color,2)'in between middle and top
	DrawDRADISText(BG, X-temp-10,  Y-temp*0.60,  Textsize, 0, "ME1 (-1)", Color, 2,1)
	
	BG.DrawCircle(X, Y,  temp*0.95, Colors.Black, True,0)
	
	Pt.Initialize(X,Y-temp)'top middle
	Pt.LineTo(X,Y)'middle middle
	X2=Trig.findXYAngle(X,Y, temp*0.95, Degree,True) 'angle=150
	Pt.LineTo(X2,Y+temp)'right bottom
	Pt.LineTo(X-temp,Y+temp)'left bottom
	Pt.LineTo(X-temp,Y-temp)'left top
	BG.ClipPath(Pt)
	BG.DrawCircle(X,Y, temp*0.95, Color, False, 2)'semi-circle
	BG.RemoveClip 
	BG.DrawCircle(X2, Trig.findXYAngle(X,Y, temp*0.95, Degree,False) , 5, Color,True, 0)'dot
	
	'LCARSeffects.DrawCircleSegment(BG, X, Y, temp*0.95, -2, 0,-210, Color, 4,3, 0)'outer ring with a dot
	Degree=354
	'Height=33
	For temp2 = 1 To Max(Minutes,Seconds)'6 degrees per minute/second
		'If temp2 <= Height Then LCARSeffects.DrawCircleSegment(BG, X, Y, temp*0.95, -2, temp2, 6, Color,  0, 3,0)
		If Seconds >= temp2 Then LCARSeffects.DrawCircleSegment(BG, X, Y, temp*0.85, -temp*0.1, Degree, 5, Color,  0,0,0)
		If Minutes >= temp2 Then LCARSeffects.DrawCircleSegment(BG, X, Y, temp*0.60, -temp*0.3, Degree, 5, Color,  0,0,0)	
		Degree=Degree-6
	Next
	Degree= 330
	For temp2 = 1 To Hours'30 degrees per hour (max of 12)
		LCARSeffects.DrawCircleSegment(BG, X, Y, temp*0.25, -temp*0.3, Degree, 29, Color, 0,0,0)
		Degree=Degree-30
	Next
End Sub
Sub DrawDigital(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Hours As Int, Minutes As Int, Seconds As Int, IsNegative As Boolean)
	Dim UnitWidth = Height * 0.6176470588235294, SpacePerDigit = Width / 8, ColorTrue As Int = Colors.RGB(249,218,172), ColorFalse As Int = Colors.RGB(62,22,26),ShowColon As Boolean = Seconds Mod 2=0
	
	DrawDigitalByte(BG, X,Y, UnitWidth, Height, ColorTrue,ColorFalse, API.IIF(IsNegative, -1,-2))'-
	
	DrawDigitalByte(BG, X+SpacePerDigit,Y, UnitWidth, Height, ColorTrue,ColorFalse, Floor(Hours / 10) )'hours tens
	DrawDigitalByte(BG, X+SpacePerDigit*2,Y, UnitWidth, Height, ColorTrue,ColorFalse, Hours Mod 10 )'hours ones
	DrawDigitalByte(BG, X+SpacePerDigit*3, Y, SpacePerDigit-UnitWidth, Height, ColorTrue,ColorFalse, API.IIF(ShowColon, -3,-4))' :
	
	DrawDigitalByte(BG, X+SpacePerDigit*3.5, Y, UnitWidth, Height, ColorTrue,ColorFalse, Floor(Minutes / 10) )'Minutes tens
	DrawDigitalByte(BG, X+SpacePerDigit*4.5,Y, UnitWidth, Height, ColorTrue,ColorFalse, Minutes Mod 10 )'Minutes ones
	DrawDigitalByte(BG, X+SpacePerDigit*5.5, Y, SpacePerDigit-UnitWidth, Height, ColorTrue,ColorFalse, API.IIF(ShowColon, -3,-4))' :
	
	DrawDigitalByte(BG, X+SpacePerDigit*6, Y, UnitWidth, Height, ColorTrue,ColorFalse, Floor(Seconds / 10) )'Seconds tens
	DrawDigitalByte(BG, X+SpacePerDigit*7,Y, UnitWidth, Height, ColorTrue,ColorFalse, Seconds Mod 10 )'Seconds ones
End Sub

Sub DrawDigitalByte(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorTrue As Int,ColorFalse As Int, Value As Int)
	Dim Bits() As Boolean , O As Boolean=False, I As Boolean=True, WhiteSpace As Int = 3, Unit As Int = Height * 0.1666666666666667, Unit2 As Int =Height*0.5, DoBits As Boolean
	Select Case Value'      0 1 2 3 4 5 6  
		'decimal
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
		
		'hexadecimal
		Case 10:Bits= Array As Boolean(I,I,I,O,I,I,I)
		Case 11:Bits= Array As Boolean(I,I,I,I,I,O,O)
		Case 12:Bits= Array As Boolean(O,I,I,I,O,O,I)
		Case 13:Bits= Array As Boolean(I,O,I,I,I,I,O)
		Case 14:Bits= Array As Boolean(I,I,I,I,O,O,I)
		Case 15:Bits= Array As Boolean(I,I,I,O,O,O,I)
		
		'symbols
		Case -1, -2' - and +
				Bits = Array As Boolean(I,O,O,O,O,O,O)' -
				DoBits= Value=-2'+
		Case -3 ,-4' : (lit, dim)
				Width=Width*0.5
				DrawRect(BG,X, Y+Unit2-WhiteSpace-Width, Width, Width,  API.IIF(Value = -3,  ColorTrue,ColorFalse), 0)
				DrawRect(BG,X, Y+Unit2+ (Unit2*0.5)- (Width*0.5), Width, Width, API.IIF(Value = -3,  ColorTrue,ColorFalse), 0)
				Return
	End Select
	'If DoBits Then
	DrawDigitalBit(BG, X+WhiteSpace, Y+Unit2 - Unit*0.5, Width-WhiteSpace*2, Unit, API.IIF( Bits(0),  ColorTrue,ColorFalse), 0)'middle hor
	Unit=Unit*0.9
	DrawDigitalBit(BG, X, Y+WhiteSpace, Unit, Unit2-WhiteSpace*2, API.IIF( Bits(1),  ColorTrue,ColorFalse), 1)'top left ver
	DrawDigitalBit(BG, X, Y+Unit2+WhiteSpace, Unit, Unit2-WhiteSpace*2, API.IIF( Bits(2),  ColorTrue,ColorFalse), 1)'bottom left ver
	DrawDigitalBit(BG, X+WhiteSpace,Y+Height-Unit, Width-WhiteSpace*2, Unit, API.IIF( Bits(3),  ColorTrue,ColorFalse), 4)' bottom left hor
	DrawDigitalBit(BG, X+Width-Unit, Y+Unit2+WhiteSpace, Unit, Unit2-WhiteSpace*2, API.IIF( Bits(4),  ColorTrue,ColorFalse), 2)'bottom right ver
	DrawDigitalBit(BG, X+Width-Unit, Y+WhiteSpace, Unit, Unit2-WhiteSpace*2, API.IIF( Bits(5),  ColorTrue,ColorFalse), 2)'top right ver
	DrawDigitalBit(BG, X+WhiteSpace,Y, Width-WhiteSpace*2, Unit, API.IIF( Bits(6),  ColorTrue,ColorFalse), 3)' top hor
End Sub

Sub DrawDigitalBit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, BitType As Int)
	Dim temp As Int , P As Path'BitType: 0= <_> 1= |> 2= <| 3= \_/ 4= /_\
	Select Case BitType
		Case 0'-
			temp = Height *0.5
			LCARSeffects2.MakePoint(P, X+temp,Y)
			LCARSeffects2.MakePoint(P, X,Y+temp)
			LCARSeffects2.MakePoint(P, X+temp,Y+Height)
			LCARSeffects2.MakePoint(P, X+Width-temp,Y+Height)
			LCARSeffects2.MakePoint(P, X+Width,Y+temp)
			LCARSeffects2.MakePoint(P, X+Width-temp,Y)
		Case 1'|>
			LCARSeffects2.MakePoint(P, X,Y)
			LCARSeffects2.MakePoint(P, X+Width,Y+Width)
			LCARSeffects2.MakePoint(P, X+Width,Y+Height-Width)
			LCARSeffects2.MakePoint(P, X,Y+Height)
		Case 2'<|
			LCARSeffects2.MakePoint(P, X,Y+Width)
			LCARSeffects2.MakePoint(P, X+Width,Y)
			LCARSeffects2.MakePoint(P, X+Width,Y+Height)
			LCARSeffects2.MakePoint(P, X,Y+Height-Width)
		Case 3'_ going down
			LCARSeffects2.MakePoint(P, X,Y)
			LCARSeffects2.MakePoint(P, X+Height,Y+Height)
			LCARSeffects2.MakePoint(P, X+Width-Height,Y+Height)
			LCARSeffects2.MakePoint(P, X+Width,Y)
		Case 4'_ going up
			LCARSeffects2.MakePoint(P, X,Y+Height)
			LCARSeffects2.MakePoint(P, X+Height,Y)
			LCARSeffects2.MakePoint(P, X+Width-Height,Y)
			LCARSeffects2.MakePoint(P, X+Width,Y+Height)
	End Select
	If P.IsInitialized Then 
		'LCARSeffects2.CopyPlistToPath(P, Pt, BG, Color, 0, False, False)
		'BG.ClipPath(P)
		'DrawRect(BG, X,Y,Width,Height,Color,0)
		'BG.RemoveClip 
		BG.DrawPath(P, Color, True, 0)
	End If
End Sub


Sub RndLetter As String 
	Return Chr(Rnd(Asc("a"), Asc("o")))
End Sub
Sub NewCylonLetter(Middle As Boolean) As CylonText
	Dim temp As CylonText ,Alpha As Int , GoingDown As Boolean 
	temp.X = Rnd(0,101) * 0.01
	GoingDown = (Rnd(0,100)< 50)
	If Middle Then 
		temp.Y = API.IIF(GoingDown,  Rnd(0,21), Rnd(80,105)) * 0.01
	Else
		temp.Y = API.IIF(GoingDown, 0, 1)
	End If
	temp.Letter = RndLetter
	temp.FontSize = Rnd(5,30)
	temp.Frames = 5
	temp.Speed =  Rnd(1,7) * API.IIF(GoingDown, 0.01, -0.01)
	Alpha = Min(255, temp.FontSize * 8.5)
	temp.Color = Colors.ARGB(Alpha,215,89,111)
	Return temp
End Sub
Sub DrawCylon(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int , tempLetter As CylonText
	If Not(CylonFont.IsInitialized) Then CylonFont = Typeface.LoadFromAssets("cylon.ttf")
	If Not(CylonLetters.IsInitialized) Then
		CylonLetters.Initialize 
		For temp = 1 To CylonLetterCount
			CylonLetters.Add( NewCylonLetter(True) )
		Next
	End If
	For temp = 0 To CylonLetters.Size -1
		tempLetter = CylonLetters.Get(temp)
		BG.DrawText( tempLetter.Letter, X + Width * tempLetter.X, Y+ Height* tempLetter.Y,  CylonFont, tempLetter.FontSize, tempLetter.Color , "CENTER")
	Next
End Sub
Sub IncrementCylon
	Dim temp As Int , tempLetter As CylonText
	If CylonLetters.IsInitialized Then
		For temp = 0 To CylonLetters.Size -1
			tempLetter = CylonLetters.Get(temp)
			tempLetter.y = tempLetter.y + tempLetter.Speed '(API.IIF(tempLetter.goingdown,  tempLetter.fontsize, -tempLetter.fontsize) * 0.01)
			If tempLetter.y > 1.05 Or tempLetter.y < -0.05 Then
				CylonLetters.Set(temp, NewCylonLetter(False))
			Else
				tempLetter.Frames = tempLetter.Frames- 1
				If tempLetter.Frames = 0 Then
					tempLetter.Frames=5
					tempLetter.Letter = RndLetter
				End If
			End If
		Next
	End If
End Sub








Sub DrawAirplaneAlart(BG As Canvas, X As Int,Y  As Int, Width As Int,Height As Int, ColorID As Int,Stage As Int,Alpha As Int)
	Dim Size As Int = Min(Width,Height), Color As Int, Text As String , CenterX As Int =  X + Width/2, CenterY As Int = Y + Height/2, temp As Int 
	'pre-processing
	Select Case ColorID
		Case LCAR.Classic_Green, LCAR.LCAR_Yellow
			Color = Colors.rgb(255,255,189) 'beige
			Text = API.IIF(ColorID=LCAR.Classic_Green, "WEIRD", "BIZARRE")
		Case LCAR.LCAR_Red
			Alpha=255
			If Stage >13 Then Stage = LCARSeffects.OkudaStages - Stage
			If Stage < 13 Then Alpha = Min(255, 64 + (Stage * 16))
			Color = Colors.ARGB(Alpha,203,8,8) 'red
			Text = "STRANGE"
	End Select
	
	'frame
	DrawRect(BG,X,Y,Width,Height, Colors.RGB(66,66,66),0)
	LCARSeffects2.DrawRoundRect(BG, CenterX - Size/2, CenterY - Size/2, Size,Size, Colors.Black, Size*0.2)
	Size=Size*0.8
	LCARSeffects2.DrawLegacyButton(BG, CenterX - Size/2, CenterY - Size/2, Size,Size, Color, "", 1, 0)
	X = CenterX - Size/2
	Y = CenterY - Size/2
	LCARSeffects.MakeClipPath(BG, X,Y, Size,Size)
	
	'circles
	For temp = 0 To Size *0.25 Step Size * 0.025
		BG.DrawCircle(CenterX,CenterY, temp, Colors.Black, False,0)
	Next
	For temp = temp To Size * 1.5 Step Size * 0.05
		BG.DrawCircle(CenterX,CenterY, temp, Colors.Black, False,0)
	Next
	
	'lines
	For temp = 0 To Size Step Size * 0.05
		BG.DrawLine(X, Y+ temp, X+Size, Y+ temp, Colors.Black, 0)
		BG.DrawLine(X+ temp, Y, X+temp, Y+Size, Colors.Black, 0)
	Next
	
	'text
	API.DrawTextAligned(BG, Text, X + Size*0.085, CenterY - Size/4, 0, LCARSeffects2.StarshipFont, LCAR.Fontsize, Colors.Black, -4, 0, 0)
	BG.RemoveClip 
End Sub







Sub StartTricoder(ElementID As Int)
	TRI_Section=-1
	TRI_Subsection=0
	TRI_State=False
	TRI_ElementID=ElementID
	LCAR.SetLRwidth(ElementID,0,0)
	LCAR.ForceShow(ElementID, True)'element 102 (group 44)
	TRI_Buttons.Initialize 

	If Not(Blinkies.IsInitialized ) Then
		Blinkies.Initialize 
		MakeBlinky(1, "MICHAEL OKUDA", 	22,246,255,   51,34,   	28,16)'blue (TOP LEFT)
		
		MakeBlinky(2, "TOM NARDI", 		98,210,193,   50,90,   20,10)'green (SIGMA)
		MakeBlinky(4, "TECHNI MYOKO", 	22,246,255,   251,95,  	12,8)'blue (TOP RIGHT)
		
		MakeBlinky(10, "%", 			255,255,0,   79,365,  	17,10)'orange (GEO)
		MakeBlinky(11, "", 				255,255,0,   105,365,  	17,10)'orange (MET)
		MakeBlinky(12, "", 				255,255,0,   131,365,  	17,10)'orange (BIO)
		
		MakeBlinky(13, "Q DEEZY",		22,246,255,   173,365,   18,12)'blue (LB)
		MakeBlinky(14, "PHIL W",		22,246,255,   193,365,   18,12)'blue (AB)
		
		MakeBlinky(15, "",				255,122,120,  233,366,	24,20)'red (EMRG)
		
		MakeBlinky(16, "",				255,255,0,   78,410,	20,10)'orange (SENSOR SYS Left)
		MakeBlinky(17, "",				255,255,0,   127,410,	20,10)'orange (SENSOR SYS Right)
		
		MakeBlinky(19, "THANK YOU",		22,246,255,   231,414, 	15,13)'blue (INT)
		MakeBlinky(20, "EVERYONE",		22,246,255,   248,414, 	15,13)'blue (EXT)
		
		MakeBlinky(21, "I NEED SLEEP",	253,236,86,   127,441,	18,15)'yellow (OSX)
		
		MakeBlinky(25, "LOTS OF IT",	255,255,0,   233,488,	14,12)'orange (bottom right)
		
		TRI_GraphID= LCARSeffects2.AddGraph( LCARSeffects2.UnusedGraphID, 25, False)
	Else
		ResetBlinkies
		'SetBlinky(10, "%")
		'SetBlinky(11, "")
		'SetBlinky(12, "")
	End If
End Sub
Sub TRI_AddButtons(Buttons() As String)
	Dim temp As Int, lastcolor As Int 
	TRI_Buttons.Clear 
	For temp = 0 To Buttons.Length-1
		Dim tempButton As MiniButton 
		tempButton.Initialize 
		lastcolor = LCAR.LCAR_RandomColor2(lastcolor)
		tempButton.ColorID = lastcolor
		tempButton.Text=Buttons(temp)
		TRI_Buttons.Add(tempButton)
	Next
End Sub

Sub ClearFrames
	API.ClearBMP(TRI_FrameA, Colors.Black)
	API.ClearBMP(TRI_FrameB, Colors.Black)
	API.ClearBMP(TRI_FrameC, Colors.Black)
End Sub

'0=GEO 1=MET 2=BIO 3=2d/3d sensors
Sub SwitchTricorderSection(Section As Int, SubSection As Int)
	Dim Text As String = "SCAN ANALYSIS", SideText As String = "AUXILIARY SYSTEMS MONITOR 117"
	If TRI_Section <> Section Then''Dim TRI_GEO_A As Int = 0, TRI_MET As Int = 1, TRI_BIO As Int = 2, TRI_GEO_B As Int = 3
		SetBlinky(10, API.IIF(Section=TRI_GEO_A Or Section=TRI_GEO_B, "%", ""))
		SetBlinky(11, API.IIF(Section=TRI_MET, "%", ""))
		SetBlinky(12, API.IIF(Section=TRI_BIO, "%", ""))
		
		SetBlinky(16, "")
		SetBlinky(17, "")
		ClearFrames
		
		Select Case TRI_Section'leaving section
			Case TRI_GEO_A,TRI_GEO_B: If Section <> TRI_GEO_A And Section <> TRI_GEO_B Then CameraAction(6,"leaving 1")
			Case TRI_MET,TRI_BIO: CameraAction(1,"leaving 0") ' LCAR.pushevent(LCAR.SYS_Camera,  1, 0,0,0,0,0, LCAR.Event_Up)'leaving section 0, stop camera
		End Select
		Select Case Section'entering section
			Case TRI_GEO_A'1d sensors
				'0=mic  13=light, 14=pressure, 15=temperature, 16=proximity, 17=battery, 18=total magnetic field, 19=medical insurance remaining
				If TRI_Section<>TRI_GEO_A And TRI_Section<>TRI_GEO_B Then CameraAction(5, "entering GEOA")
				UseSensor(18)
				TRI_AddButtons(Array As String("MAG", "MIC", "LIT", "BAT"))
				SetBlinky(16, "NINTENDO")
			
			Case TRI_MET'camera	
				Text="CAM. ANALYSIS"
				TRI_CurrentSensor=1
				CameraAction(0,"entering MET")'LCAR.pushevent(LCAR.SYS_Camera, 0, 0,0,0,0,0, LCAR.Event_Up)'entering section 0, start camera
				TRI_AddButtons(Array As String("MOT", "HST"))
				
				
			Case TRI_GEO_B'2d/3d sensors
				'1,2,3=acc,  4,5,6=mag,   7,8,9=ori,   10,11,12=gyro,  
				If TRI_Section<>TRI_GEO_A And TRI_Section<>TRI_GEO_B Then CameraAction(5, "entering GEOB")
				UseSensor(-2)
				TRI_AddButtons(Array As String("ACC", "MAG", "ORI", "GYR"))
				SetBlinky(17, "SUCKS")
			
			Case TRI_BIO
				Text= "FREQ. ANALYSIS"
				TRI_AddButtons(Array As String("MIC", "GPS", "WEA"))
				TRI_Subsection=0
				TRI_CurrentSensor=0
				TRI_SampleRate=0
				CameraAction(9, "entering BIO")
		End Select
		LCAR.LCAR_SetElementText(TRI_ElementID, Text,SideText)
	End If
	TRI_Section=Section
	TRI_Subsection=SubSection
End Sub

'0: SetupCamera, 1: StopCamera, 2: camEx.ToggleFlash, 3: toggle camera, 4: TakePicture, 5: enable sensors, 6: disable sensors, 7: exit
'8: start gps, 9: start recording
Sub CameraAction(Index As Int, Reason As String) As Boolean 
	 Select Case Index
	 	Case 0'turn on camera
			If CameraToggled Or CameraIsOn Or Not(TRI_State) Or TRI_Angle <180 Then Return
			CameraToggled=True
			FlashIsOn=False 
		Case 1'turn off camera
			CameraToggled=False'to make sure it's not continually init'd
			LCAR.Lightpackevent(-1, 0, 255,255,255)
			FlashIsOn=False 
		Case 2'toggle flash
			FlashIsOn = Not(FlashIsOn)
			If Not(CameraIsOn) Then 
				Index = 0
				FlashIsOn = True 
			End If		
	End Select
	Log("CameraAction: " & Index & ") " & Reason)' & " " & API.IIFIndex(Index, Array As String("ON", "OFF", "FLASH", "CAMERA", "TAKE PIC")))
	LCAR.pushevent(LCAR.SYS_Camera,  Index, 0,0,0,0,0, LCAR.Event_Up)'leaving section 0, stop camera
End Sub

Sub TRI_HandleMouse(X As Int, Y As Int, Action As Int)As Int 
	Dim Region As Int = -1
	If Action = LCAR.Event_Move Then Return
	If LCAR.SmallScreen Then 
		Region=0
		Region = IsRegion(Region, 26,	X,Y,	0,		0,		LCAR.ScaleWidth,	50)'bottom screen in smallscreen mode
		
		If Region = 0 Then Region = -1
	End If
	
	If X>= TRI_X And X <= TRI_X + 299*TRI_Scalefactor Or Region>-1 Then
		If Region = -1 Then
			X=(X-TRI_X)/TRI_Scalefactor
			Y=Y/TRI_Scalefactor
			Region=0'out of bounds
		End If
		If TRI_Angle =180 Then
			'row 1 - Top half
			Region = IsRegion(Region,	 1, 	X,Y,    27,		27, 	61,		31)'top left
			'row 2
			Region = IsRegion(Region,	 2, 	X,Y,    25,		89, 	51,		17)'sigma
			Region = IsRegion(Region,	 3, 	X,Y,    80,		89, 	35,		17)'COM
			Region = IsRegion(Region,	 4, 	X,Y,    234,	92,		44,		20)'right
			'row 3
			Region = IsRegion(Region,	 5, 	X,Y,    28,		129,	238,	108)'top screen
			'row 4
			Region = IsRegion(Region,	 6, 	X,Y,    28,		249,	178,	29)'pad below screen
			Region = IsRegion(Region,	 7, 	X,Y,    227,	249,	41,		29)'red/blue lights
			'row 5 - Bottom half
			Region = IsRegion(Region,	 8, 	X,Y,    28,		314,	240,	41)'bottom screen
			'row 6
			Region = IsRegion(Region,	 9, 	X,Y,    20,		362,	38,		104)'left pad
			Region = IsRegion(Region,	10, 	X,Y,    69,		360,	32,		32)'GEO
			Region = IsRegion(Region,	11, 	X,Y,    101,	360,	32,		32)'MET
			Region = IsRegion(Region,	12, 	X,Y,    133,	360,	32,		32)'BIO
			Region = IsRegion(Region, 	13, 	X,Y,    165,	360,	29,		32)'LB
			Region = IsRegion(Region, 	14, 	X,Y,    190,	360,	32,		32)'LB
			Region = IsRegion(Region, 	15, 	X,Y,    222,	360,	49,		47)'EMRG
			'row 7
			Region = IsRegion(Region, 	16, 	X,Y,    69,		399,	45,		27)'SENSOR SYS LEFT
			Region = IsRegion(Region, 	17, 	X,Y,    114,	399,	45,		27)'SENSOR SYS RIGHT
			Region = IsRegion(Region, 	18, 	X,Y,    160,	394,	58,		35)'WHITE BLOCK
			Region = IsRegion(Region, 	19, 	X,Y,    223,	409,	25,		25)'INT
			Region = IsRegion(Region, 	20, 	X,Y,    248,	409,	25,		25)'EXT
			'row 8
			Region = IsRegion(Region, 	21, 	X,Y,    67,		434,	91,		30)'OSX
			Region = IsRegion(Region, 	22, 	X,Y,    161,	434,	59,		29)'INTRSHIP|RECORD
			Region = IsRegion(Region, 	23, 	X,Y,    224,	434,	48,		28)'HOLLOW BLOCK
			'row 9
			Region = IsRegion(Region, 	24, 	X,Y,    15,		476,	171,	43)'TEXT BLOCK
			Region = IsRegion(Region, 	25, 	X,Y,    211,	476,	57,		40)'Bottom right
		End If
		'Log("TRI_Region: " & Region)
		If Action>-1 Then
			TRI_HandleAction(X,Y,Action,Region)
		End If
	End If
	Return Region
End Sub
Sub IsRegion(RegionNow As Int, Region As Int, MouseX As Int, MouseY As Int, X As Int, Y As Int, Width As Int, Height As Int) As Int 
	If RegionNow = 0 Then'LOD
		If MouseX >=X AND MouseX<=X+Width AND MouseY>=Y AND MouseY<=Y+Height Then Return Region
	End If
	Return RegionNow
End Sub
Sub TRI_HandleAction(X As Int, Y As Int, Action As Int, Region As Int)
	Dim temp As Int = 34, Width As Int = 229-temp, ButtonIndex As Int = -1, OldSection As Int = TRI_Subsection 
	If Action = LCAR.Event_up Then Return
	If (Region=8 OR Region=26) AND TRI_Buttons.IsInitialized Then'TRI_X + 32*TRI_Scalefactor, Y + 320*TRI_Scalefactor, 229*TRI_Scalefactor, 31*TRI_Scalefactor
		If Region = 8 Then
			X=X-32-temp
			Y=Y-320
		Else
			Width=LCAR.ScaleWidth '/scalefactor 
			Region=8
		End If
		Width = Width/Max(TRI_Buttons.Size,4)
		ButtonIndex = Floor(X / Width)	
		Log("ButtonIndex: " & ButtonIndex & " " & Width)
		If TRI_Buttons.Size < 4 Then ButtonIndex = ButtonIndex - (4-TRI_Buttons.Size)
'		If TRI_Buttons.Size = 3 Then
'			ButtonIndex = ButtonIndex-1
'		Else If TRI_Buttons.Size < 4 Then 
'			ButtonIndex = ButtonIndex-TRI_Buttons.Size
'		End If
		ButtonIndex= Max(-1, ButtonIndex)
		If ButtonIndex >= TRI_Buttons.Size Then  ButtonIndex=-1
		If ButtonIndex>-1 Then TRI_Subsection = ButtonIndex
		ClearFrames
		Log("ButtonIndex: " & ButtonIndex)
	End If
	Select Case Region 
		Case 0'out of bounds
			If TRI_Angle< 180 Then LCAR.SetLRwidth(TRI_ElementID,TRI_Angle,180)'opens
		
		Case 10,11,12'GEO,MET,BIO
			SwitchTricorderSection(Region-10, 0)
		
		Case 15'EMRG
			LCAR.SetRedAlert(Not(LCAR.RedAlert), "TRICORDER")
			SetBlinky(15, API.IIF(LCAR.RedAlert,"RED ALERT",""))
		
		Case 24'text block
			CameraAction(1,"text block")
			TRI_State=False
			LCAR.SetLRwidth(TRI_ElementID,TRI_Angle,0)'closes
			LCAR.Lightpackevent(-1, 0, 255,255,255)
			
		Case 25'bottom right
			'CameraAction(7, "bottom right")
			LCAR.SystemEvent(0,-1)'exit
		Case Else
			Select Case TRI_Section 'Dim TRI_GEO_A As Int = 0, TRI_MET As Int = 1, TRI_BIO As Int = 2, TRI_GEO_B As Int = 3
				Case TRI_GEO_A'1d sensors
					Select Case Region
						'0=mic  13=light, 14=pressure, 15=temperature, 16=proximity, 17=battery, 18=total magnetic field, 19=medical insurance remaining
						Case 8'bottom screen
							UseSensor( API.IIFIndex(ButtonIndex, Array As Int( 18, 0, 13, 17, 19 )))
						Case 17
							SwitchTricorderSection(3,0)
					End Select
					
				Case TRI_MET'camera stuff
					Select Case Region 
						'Case 8:TRI_Subsection = ButtonIndex 'bottom screen
						Case 18
							TRI_CurrentSensor = TRI_CurrentSensor + 1
							If TRI_CurrentSensor = 11 Then TRI_CurrentSensor = 1
							LCAR.LCAR_SetElementText(TRI_ElementID, API.IIFIndex(TRI_CurrentSensor, Array As String("ALPHA", "RED", "GREEN", "BLUE", "LIGHTNESS", "AVERAGE", "LUMINOSITY", "HUE", "SATURATION", "VALUE", "RGB")),	LCAR.LCAR_IGNORE)
						Case 19,20:CameraAction(3,"INT/EXT")'INT/EXT
						Case 23: CameraAction(2,"HOLLOW")
					End Select
				
				Case TRI_GEO_B'3d sensors
					Select Case Region
						Case 8'bottom screen
							UseSensor( -1 - TRI_Subsection )
						Case 16
							SwitchTricorderSection(1,0)
					End Select
				
				Case TRI_BIO
					Select Case Region
						Case 8'bottom screen
							If TRI_Subsection <> OldSection Then 
								TRI_TextClean =False
								CameraAction(1, "changing BIO")
								LCAR.LCAR_SetElementText(TRI_ElementID, API.IIFindex(TRI_Subsection, Array As String("FREQ. ANALYSIS", "GPS+W3W", "OPENWEATHERMAP")), "AUXILIARY SYSTEMS MONITOR 117")
								Select Case TRI_Subsection 
									Case 0: CameraAction(9, "BIO mic")
									Case 1: CameraAction(8, "BIO gps")
									Case 2: Weather.CheckWeather("", False)
								End Select
							End If
					End Select
			End Select
	End Select
End Sub

Sub DrawTricorder(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, DidMove As Boolean, TopText As String, BottomText As String) ' TRI_X As Int, TRI_Scalefactor as Float 
	Dim Size As Point = API.Thumbsize(299, API.IIF(LCAR.SmallScreen, 239 ,531), Width, Height, True, False), temp As Int, X2 As Int ,Y2 As Int '355
	TRI_Scalefactor = Size.X / 299
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "tricorder.png", LCAR.VOY_Tricorder)
	TRI_Angle=Angle
	DrawRect(BG,X,Y,Width+1,Height+1, Colors.Black,0)
	temp= API.IIF(Angle<90, 237,228)*TRI_Scalefactor
	If Angle = 0 Or Angle = 180 Then
		X2=0
		Y2=temp
	Else
		X2 = Abs(Trig.findXYAngle(0,0, temp, Angle, True)) * 0.5 'Width offset of 1 edge
		Y2 = Abs(Trig.findXYAngle(0,0, temp, Angle, False))'Height
	End If
	temp= API.IIF(Angle<90, 299,310)*TRI_Scalefactor'original width	
	TRI_X = X+Width/2 - Size.X/2'top left corner scaled
	If Angle > 90 Then  LCARSeffects2.DrawTrapezoid(BG, LCARSeffects2.CenterPlatform,  SetRect(312,0, 310, 228),     X+Width/2- temp/2-X2 - 3*TRI_Scalefactor,  Y+301*TRI_Scalefactor,       temp, temp + X2*2, Y2, 255)'front panel	303,0 - 310*228      301
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, SetRect(2,0,299,308), SetRect(TRI_X, Y, Size.X, 308 * TRI_Scalefactor))'body
	If Angle < 90 Then LCARSeffects2.DrawTrapezoid(BG, LCARSeffects2.CenterPlatform,  SetRect(641,0,299,237),  X+Width/2- temp/2 - X2, Y+308*TRI_Scalefactor - Y2, temp + X2*2, temp, Y2, 255)'back panel	615,0 - 299*237 
	If DidMove And Not(LCAR.IsPlaying) Then'handle ratchet noise 
		LCAR.PlaySound(TRI_Click,True) 
		CameraAction(1, "Shouldntbe")
	Else If Angle = 180 And LCAR.IsPlaying Then
		If LCAR.WasPlaying = TRI_Click Then
			LCAR.Stop("TRI1") 
			LCAR.PlaySound(TRI_Click+1,True)
		End If
	Else If LCAR.IsPlaying Then 
		LCAR.Stop("TRI2")
	End If
	If Angle < 180 Then 
		TRI_Alpha = 0 
		TRI_LastUpdate=0
	Else 
		TRI_State=True
		TRI_Alpha = LCAR.Increment(TRI_Alpha, 16, 255)
		DrawTricorderScreen(BG, TRI_X + 36*TRI_Scalefactor, Y + 135*TRI_Scalefactor, 226*TRI_Scalefactor, 96*TRI_Scalefactor, True, TRI_Alpha, TopText) '36,135 - 226,97
		temp=DrawTricorderScreen(BG, TRI_X + 32*TRI_Scalefactor, Y + 320*TRI_Scalefactor, 229*TRI_Scalefactor, 31*TRI_Scalefactor, False, TRI_Alpha, BottomText)
		If TRI_Section=-1 And TRI_Alpha = 255 Then  SwitchTricorderSection( 0, 0)
		TRI_LastUpdate= DrawBlinkies(BG, TRI_X, Y, TRI_Scalefactor, TRI_LastUpdate)
		If LCAR.SmallScreen Then DrawMiniFrameBottom(BG, 0,0, Width, 50, 0,0,"")
	End If
End Sub

Sub DrawTricorderScreen(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, IsTop As Boolean, Alpha As Int, Text As String) As Int 
	Dim Dest As Rect , Size As Point ,DestOld As Rect = SetRect(X,Y,Width,Height)
	If IsTop Then
		Dest = DrawMiniFrameTop(BG, X,Y,Width,Height, Width * 0.15, Height * 0.04, Text)'"SCAN ANALYSIS")
		X = Dest.Left 
		Y = Dest.Top 
		Width = Dest.Right-Dest.Left
		Height = Dest.Bottom-Dest.Top
	Else
		If Y >= LCAR.scaleheight Then Return 0
		DrawMiniFrameBottom(BG, X,Y,Width,Height, Width * 0.15, Height*0.13, Text)' "AUXILIARY SYSTEMS MONITOR 117")
	End If
	 
	
	'Log(X & " " & Y & " " & Width & " " & Height)
	
	If IsTop Then
		Select Case TRI_Section''Dim TRI_GEO_A As Int = 0, TRI_MET As Int = 1, TRI_BIO As Int = 2, TRI_GEO_B As Int = 3
			Case TRI_GEO_A'1d sensors
				LCARSeffects2.DrawGraph(TRI_GraphID, BG, X,Y,Width,Height, 0,0,255, 6,25,0)
				
			Case TRI_MET'camera
				'If TRI_FrameA.IsInitialized Then BG.DrawBitmap(TRI_FrameA, Null, SetRect( X,Y, Width-Size.X, Height*0.5))
				'If TRI_FrameB.IsInitialized Then BG.DrawBitmap(TRI_FrameB, Null, SetRect( X,Y+Height, Width-Size.X, Height*0.5))
				If TRI_FrameC.IsInitialized And CameraIsOn Then
					Size = API.Thumbsize(   TRI_FrameC.Width , TRI_FrameC.Height ,  Width, Height, True,False)
					BG.DrawBitmap(TRI_FrameC, Null, SetRect( X+Width/2-Size.X/2, Y+Height/2-Size.Y/2, Size.X,Size.Y))
					'BG.DrawBitmap(TRI_FrameC, Null, SetRect( X+Width-Size.X, Y+Height/2-Size.Y/2, Size.X,Size.Y))
				Else
					CameraAction(0,"DrawTricorderScreen")
					LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange,False,255, "CAMERA IS OFFLINE")
				End If
			
			Case TRI_BIO'
				Select Case TRI_Subsection 
					Case 0'mic
						TRI_DrawHist(True)
						If TRI_FrameC.IsInitialized Then Size = API.Thumbsize(   TRI_FrameC.Width , TRI_FrameC.Height ,  Width, Height, True,False)
					Case 1'gps
						TRI_GenerateText(Width, Height)		
					Case 2'weather
						TRI_DrawWeather(Width, Height)
				End Select 
				
				If TRI_FrameC.IsInitialized Then'AND TRI_Subsection >0 Then
					If Not(Size.IsInitialized) Then	Size = Trig.SetPoint(Width, Height)
					BG.DrawBitmap(TRI_FrameC, Null, SetRect( X+Width/2-Size.X/2, Y+Height/2-Size.Y/2, Size.X,Size.Y))
				End If
			
			Case TRI_GEO_B'2d/3d sensors
				DrawSensorBlob(BG,X,Y,Width,Height)
			
			Case Else
				LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange,False,255, "LOADING...")
		End Select
	End If
	If Alpha < 255 Then BG.DrawRect(DestOld, Colors.ARGB( 255-Alpha, 0,0,0), True,0)'  DrawRect(BG, X,Y,Width,Height,  Colors.ARGB( 255-Alpha, 0,0,0), 0)
	Return 1
End Sub

Sub DrawMiniFrameTop(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Title As String) As Rect 
	Dim H2 As Int = (Height - BarHeight - 2) * 0.20 , W2 As Int = (Width - (BarWidth*1.5) - 2) * 0.25, Yellow As Int = LCAR.GetColor(LCAR.LCAR_Yellow, False,255), temp As Int
	Dim Orange As Int = LCAR.GetColor(LCAR.LCAR_Orange, False,255) ,Textheight As Int = API.GetTextHeight(BG, BarHeight, "0123", LCAR.LCARfont), Top As Int, Left As Int 
	Dim Purple As Int = LCAR.GetColor(LCAR.LCAR_DarkPurple, False,255),Yellow2 As Int = LCAR.GetColor(LCAR.LCAR_Yellow, True,255)
	
	API.DrawTextAligned(BG, Title, X+Width, Y, 0, LCAR.LCARfont,API.GetTextLimitedHeight(BG, H2*0.5, (Width-BarWidth)*0.5, Title,LCAR.LCARfont)  , Purple, -3, 0, 0)
	
	LCAR.DrawLCARelbow(BG,X,Y,BarWidth*1.5,H2, BarWidth,BarHeight,  -4, LCAR.LCAR_Yellow, TRI_Stage=0, "", 9, 255, False)'"201"
	API.DrawTextAligned(BG, "201", X+BarWidth-4, Y+H2-8, 0, LCAR.LCARfont, Textheight, Colors.black, 3, 0, 0)
	LCAR.DrawLCARelbow(BG,X,Y+H2+2, BarWidth*1.5, H2+BarHeight+1,   BarWidth,BarHeight,  -2, LCAR.LCAR_Yellow, TRI_Stage=1, "", 9, 255, False)'"011"
	API.DrawTextAligned(BG, "011", X+BarWidth-4, Y+H2*2+BarHeight-6, 0, LCAR.LCARfont, Textheight, Colors.black, 3, 0, 0)
	
	For temp = 2 To 4'squares along the left edge
		DrawRect(BG,X, Y+((H2+2)*temp)+BarHeight, BarWidth-1, H2-1, API.IIF(temp = TRI_Stage,Yellow2,  Yellow),  0)
		API.DrawTextAligned(BG, API.IIFindex(temp-2, Array As String("041", "201", "111-762")), X+BarWidth-4, Y+((H2+2)*(temp+1))+2, 0, LCAR.LCARfont, Textheight, Colors.black, 3, 0, 0)
	Next
	
	Top = Y + H2 - BarHeight 
	Left = X+ BarWidth*1.5 + 2
	BarHeight=BarHeight-1

	DrawRect(BG, Left, 					Top, 				W2-BarHeight-4, 	BarHeight, 		Purple, 0)'first col
	DrawRect(BG, Left +W2-BarHeight-2, 	Top, 				BarHeight, 			BarHeight, 		Orange, 0)
	DrawRect(BG, Left, 					Top+BarHeight+3, 	W2-BarHeight-4, 	BarHeight, 		Yellow, 0)
	DrawRect(BG, Left+W2-BarHeight-2, 	Top+BarHeight+3,	BarHeight, 			BarHeight, 		Yellow, 0)
	DrawRect(BG, Left+W2, 				Top, 				W2-2, 				BarHeight, 		Yellow, 0)'second col
	DrawRect(BG, Left+W2, 				Top+BarHeight+3, 	W2-2, 				BarHeight, 		Yellow, 0)
	DrawRect(BG, Left+W2,				Top+3,				W2*0.5,				BarHeight*2-2, 	Colors.Black,0)
	DrawRect(BG, Left+W2,				Top+5,				BarHeight,			BarHeight*2-6,		Colors.Blue,0)
	
	DrawRect(BG, Left+W2,				Top-BarHeight*0.5,				W2*0.5,				BarHeight*0.5-1, 	Yellow,0)
	DrawRect(BG, Left+W2,				Top+BarHeight*2+5,				W2*0.5,				BarHeight*0.5-1, 	Yellow,0)
	
	DrawRect(BG, Left+W2*2, 			Top, 				W2-3, 				BarHeight, 		Yellow, 0)'third col
	DrawRect(BG, Left+W2*2, 			Top+BarHeight+3, 	W2-3, 				BarHeight, 		Orange, 0)	
	DrawRect(BG, Left+W2*3, 			Top, 				W2-3, 				BarHeight, 		Orange, 0)'fourth col
	DrawRect(BG, Left+W2*3, 			Top+BarHeight+3, 	W2-3, 				BarHeight, 		Yellow, 0)
	
	Top=Top + BarHeight * 2.5+ 5
	Return SetRect(Left - BarWidth *0.5+10,Top+5, Width-BarWidth-15, Height-H2 - BarHeight * 1.5- 4 )
End Sub
Sub DrawMiniFrameBottom(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Title As String) 'As Rect 
	Dim h2 As Int = (Height - BarHeight - 2) * 0.5, Color As Int = LCAR.GetColor(LCAR.LCAR_Red, False,255), Top As Int = Y + Height-BarHeight+1, W2 As Int = Width * 0.15,Textheight As Int = API.GetTextHeight(BG, BarHeight, "0123", LCAR.LCARfont),State As Boolean 
	If BarWidth>0 Then
		Dim TitleSize As Int = API.GetTextHeight(BG, (Width-BarWidth)*-0.5, Title, LCAR.lcarfont   ), TitleHeight As Int = BG.MeasureStringHeight(Title,LCAR.LCARfont,TitleSize)
		API.DrawTextAligned(BG, Title, X+Width, Y, 0, LCAR.LCARfont, TitleSize, LCAR.GetColor(LCAR.LCAR_Orange, False,255), -3, 0, 0)
		DrawRect(BG,X,Y, BarWidth-1, h2, Color, 0)
		API.DrawTextAligned(BG, "01-0010", X+BarWidth-4, Y+h2-8, 0, LCAR.LCARfont, Textheight, Colors.black, 3, 0, 0)
		LCAR.DrawLCARelbow(BG,X,Y+h2+2,Width*0.5-BarHeight-2,h2+BarHeight, BarWidth,BarHeight,  -4, LCAR.LCAR_Blue, False, "", 3, 255, False)'"111-762"
		API.DrawTextAligned(BG, "111-762", X+BarWidth-4, Y+h2+8, 0, LCAR.LCARfont, Textheight, Colors.black, 3, 0, 0)
		
		Top=Top-1
		DrawRect(BG, X + Width*0.5 -BarHeight, Top, BarHeight, BarHeight-1, LCAR.GetColor(LCAR.LCAR_Yellow, False,255), 0)
		DrawRect(BG, X + Width*0.5 + 2, Top, W2-2, BarHeight-1, Color, 0) 
		DrawRect(BG, X + Width*0.5 + W2 + 2, Top, Width *0.5 - W2 - 4 - BarHeight, BarHeight-1, Color, 0)
		DrawRect(BG, X + Width - BarHeight-1, Top, BarHeight+1, BarHeight-1, Color, 0)
	End If
	
	If TRI_Buttons.Size>0 Then
		X=X+BarWidth + 10
		Width=Width - BarWidth-10
		Y=Y+TitleHeight+4
		Height=Height-BarHeight-12 - TitleHeight
		W2= Width/Max(TRI_Buttons.Size,4)
		If TRI_Buttons.Size<4 Then X = X+ W2*(4-TRI_Buttons.Size)
		For h2 = 0 To TRI_Buttons.Size-1
			Dim tempButton As MiniButton = TRI_Buttons.Get(h2)'LCARSeffects2.DrawLegacyButton(BG, Dimensions.currX, Dimensions.currY, -Dimensions.offX, Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current), Element.Text, Element.TextAlign)
			State = (TRI_Subsection = h2) And (DateTime.GetSecond(DateTime.Now) Mod 2) = 0 
			Color = LCAR.GetColor(tempButton.ColorID, State,255)
			LCARSeffects2.DrawLegacyButton(BG, X,Y, -W2+2, Height, Color, tempButton.Text, 10, 0)
			X=X+W2
		Next
	End If
	'Return SetRect(X + BarWidth + 10, Y, Width - BarWidth-10, Height-BarHeight-10)
End Sub






'Sub TRI_CameraUpdate(SRC As Panel) As Boolean 
'	'Dim TRI_FrameA As Bitmap, TRI_FrameB As Bitmap, TRI_Frame As Boolean
'	Dim BG As Canvas , BMPd As BitmapDrawable ',BG2 As Canvas
'	Return False
'	
'	If TRI_Section = 0 Then'camera stuff
'		If TRI_Frame Then
'			If Not(TRI_FrameB.IsInitialized) Then TRI_FrameB.InitializeMutable( SRC.Width,SRC.Height)
'			BG.Initialize2(TRI_FrameB)
'		Else
'			If Not(TRI_FrameA.IsInitialized) Then TRI_FrameA.InitializeMutable(SRC.Width,SRC.Height)
'			BG.Initialize2(TRI_FrameA)
'		End If
'		
'		'BG2.Initialize(SRC)
'		'BMPd = SRC.Background
'		'BG.DrawBitmap(BMPd.Bitmap , Null, SetRect(0,0, SRC.Width,SRC.Height))
'
'		'If Not(File.Exists(File.DirRootExternal , "image.png")) Then LCARSeffects.SaveScreenshot( TRI_GetFrame(TRI_Frame), File.DirRootExternal , "image.png")
'
'		'Log("P2: " & BG.Bitmap.GetPixel(10,10))
'
'		'BG.DrawDrawable( SRC.Background  , SetRect(0,0, SRC.Width,SRC.Height))
'		
'		
'		ProcessImage
'	End If
'End Sub

Sub TRI_CameraUpdate2(SRC As Bitmap) As Boolean 
	If TRI_Section = TRI_MET Then'camera stuff
		If TRI_Frame Then
			TRI_FrameB=SRC
		Else
			TRI_FrameA=SRC
		End If
		ProcessImage
	End If
End Sub

Sub ProcessImage
	Select Case TRI_Subsection
		Case 0 'motion sensor
			API.CompareImage(TRI_GetFrame(TRI_Frame), TRI_GetFrame(Not(TRI_Frame)), TRI_FrameC, TRI_Pixelspace)
		Case 1 'histogram
			TRI_DrawHist(False)
			
			
		Case Else:Log("unhandled tri_section")
	End Select
	TRI_Frame=Not(TRI_Frame)
End Sub
Sub TRI_GetFrame(Frame As Boolean) As Bitmap 
	If Frame Then Return TRI_FrameB Else Return TRI_FrameA
End Sub
Sub ProcessRecData(SampleRate As Int,RecData() As Short )
	Dim temp As Int, tempData(RecData.Length) As Short 
	If TRI_SampleRate=0 Then
		For temp = 0 To RecData.Length-1 
			tempData(temp) = RecData(temp)
		Next
		TRI_RecData = tempData
		TRI_SampleRate = SampleRate
	End If
	'Dim HIST As Histogram = API.RecData2Histogram(SampleRate,RecData)
	'If HIST.Values.Size > 0 Then API.DrawHistogram(TRI_FrameC, HIST, 255,  Colors.Black, LCAR.GetColor(LCAR.LCAR_Orange,False, 255), "", LCAR.LCARfont, 0)
End Sub
Sub ProcessGPS(Coord As Location)
	'Dim TRI_Text As List, TRI_TextClean As Boolean 
	Dim temp As Int 
	What3Words.RequestURL(Coord.Latitude, Coord.Longitude)
	TRI_Text.Initialize 
	TRI_Text.Add("colorid: " & LCAR.LCAR_Orange)
	TRI_Text.Add("")
	If What3Words.LastWords.Size>0 Then TRI_Text.Add(What3Words.AllWords.ToUpperCase)	
	TRI_Text.Add("LAT: " & Coord.ConvertToSeconds( Coord.Latitude ))
	TRI_Text.Add("LON: " & Coord.ConvertToSeconds( Coord.Longitude ))
	If Coord.AccuracyValid Then TRI_Text.Add("ACC: " & Round(Coord.Accuracy) & " %")
	If Coord.AltitudeValid Then TRI_Text.Add("ALT: " & Round(Coord.Altitude) & " m")
	If Coord.BearingValid Then TRI_Text.Add("BER: " & Round(Coord.Bearing) & " °")
	If Coord.SpeedValid Then TRI_Text.Add("SPD: " & Round(Coord.Speed) & " m/s")
	TRI_TextClean=False
End Sub

Sub TRI_GenerateText(Width As Int, Height As Int) As Bitmap 
	Dim BG As Canvas 
	If API.InitDest(TRI_FrameC, Width,Height) Then TRI_TextClean =False
	If Not(TRI_TextClean) Then
		If API.ListSize(TRI_Text) = 0 Then 
			TRI_Text.Initialize 
			TRI_Text.Add("colorid: " & LCAR.LCAR_Orange)
'			If API.IsLocationON Then
				TRI_Text.Add("IF GPS TAKES TOO LONG")
				TRI_Text.Add("TO ACTIVATE THEN")
				TRI_Text.Add("TRY SWITCHING TO MIC")
				TRI_Text.Add("THEN BACK TO GPS")
'			Else
'				TRI_Text.Add("LOCATION SERVICES")
'				TRI_Text.Add("NEEDS TO BE TURNED")
'				TRI_Text.Add("ON TO USE GPS")
'			End If
		End If
		BG.Initialize2(TRI_FrameC)
		BG.DrawColor(Colors.Black)
		LCARSeffects3.DrawTextItems(BG, 0,0, Width,Height, TRI_Text, 255)
		TRI_TextClean=True
	End If
	Return TRI_FrameC
End Sub


Sub UpdateWeather'(CurrentWeather As WeatherData)
	TRI_CurrentSensor = 1
End Sub
Sub TRI_DrawWeather(Width As Int, Height As Int) As Bitmap
	Dim BG As Canvas 
	If API.InitDest(TRI_FrameC, Width,Height) Or TRI_CurrentSensor = 1 Then
		BG.Initialize2(TRI_FrameC)
		BG.DrawColor(Colors.Black)
		LCARSeffects3.DrawWeatherTextWidget(BG, 0,0, Width,Height, False, Weather.CurrentWeather, -9)
		TRI_CurrentSensor=0
	End If
End Sub
Sub TRI_DrawHist(UseMIC As Boolean )
	Dim HIST As Histogram, Text As String, BG As Canvas , OffsetX As Int = 4, OffsetY As Int =OffsetX * -1, NeedsInit As Boolean 
	If TRI_SampleRate>0 Then 
		If UseMIC Then
			 HIST = API.RecData2Histogram(TRI_SampleRate,TRI_RecData)
		Else
			HIST = API.MakeHistogram(TRI_GetFrame(Not(TRI_Frame)) , TRI_CurrentSensor , TRI_Pixelspace) 
		End If
		
		If HIST.Values.Size > 0 Then 
			NeedsInit = Not(TRI_FrameC.IsInitialized) Or Not(TRI_FrameA.IsInitialized )
			If Not(NeedsInit) Then NeedsInit = TRI_FrameA.Width <> TRI_FrameC.Width Or TRI_FrameA.Height <> TRI_FrameC.Height 
			If NeedsInit Then 
				API.DrawHistogram(TRI_FrameC, HIST, 255,  Colors.Transparent, Colors.Black, Text, LCAR.LCARfont, LCAR.Fontsize)
				TRI_FrameA.InitializeMutable(TRI_FrameC.Width,TRI_FrameC.Height)
			Else		
				BG.Initialize2(TRI_FrameA)
				BG.DrawBitmap(TRI_FrameC, Null, SetRect(OffsetX,OffsetY, TRI_FrameC.Width,TRI_FrameC.Height))'take framec, draw over framea at a 1x1 offset
				BG.DrawColor(Colors.ARGB(8,0,0,0))'draw over it with low-opacity black to fade out
				API.DrawHistogram(TRI_FrameA, HIST, 255,  Colors.Transparent, Colors.Black , Text, LCAR.LCARfont, LCAR.Fontsize)'draw hist
				
				BG.Initialize2(TRI_FrameC)
				BG.DrawBitmap(TRI_FrameA, Null, SetRect(0,0, TRI_FrameC.Width,TRI_FrameC.Height))
			End If
			
			If UseMIC Then TRI_SampleRate=0
		End If
	End If
End Sub

Sub TRI_NeedsInit(Frame As Bitmap, Width As Int, Height As Int) As Boolean 
	Dim NeedsInit As Boolean = Not(Frame.IsInitialized)
	If Not(NeedsInit) Then NeedsInit = Frame.Width <> Width Or Frame.Height <> Height
	If NeedsInit Then Frame.InitializeMutable(Width,Height)
	Return NeedsInit
End Sub


Sub ResetBlinkies
	Dim temp As Int, tempBlinky As Blinky 
	For temp = 0 To Blinkies.Size-1
		tempBlinky = Blinkies.Get(temp)
		tempBlinky.TimeTillNextDigit = 0
		tempBlinky.CurrentMorseDigit =-1
		tempBlinky.State=False
	Next
	LCAR.Lightpackevent(-1, 0, 255,255,255)
	TRI_LastUpdate=0
End Sub
Sub DrawBlinkies(BG As Canvas, X As Int, Y As Int, ScaleFactor As Float, LastUpdate As Long) As Long
	Dim temp As Int, tempBlinky As Blinky , Diff As Long = DateTime.Now - LastUpdate, Brightness As Float 
	For temp = 0 To Blinkies.Size-1
		tempBlinky = Blinkies.Get(temp)
		Brightness=0
		If tempBlinky.CurrentMorseDigit = -1 Or LastUpdate = 0 Then' or tempBlinky.CurrentMorseDigit >=  Then
			PullDigit(tempBlinky, 0)
		Else
			tempBlinky.TimeTillNextDigit = tempBlinky.TimeTillNextDigit - Diff
			If tempBlinky.TimeTillNextDigit<=0 Then PullDigit(tempBlinky, tempBlinky.CurrentMorseDigit+1)
		End If
		
		'Log(tempBlinky.CurrentMorseDigit & ": " & tempBlinky.TimeTillNextDigit)
		
		If tempBlinky.State Then
			Brightness = DrawBlinky(BG, X + tempBlinky.X*ScaleFactor, Y + tempBlinky.Y*ScaleFactor, tempBlinky.Width*ScaleFactor, tempBlinky.Height*ScaleFactor, tempBlinky.R,tempBlinky.G,tempBlinky.b)
			Brightness = 0.5 + (Brightness * 0.5)
			LCAR.Lightpackevent(temp, 0,   tempBlinky.R * Brightness, tempBlinky.G * Brightness, tempBlinky.B * Brightness)
		Else
			LCAR.Lightpackevent(temp, 0, 255,255,255)
		End If
	Next
	
	If LastUpdate > 0 Then
		TRI_Delay = TRI_Delay + Diff 
		If TRI_Delay >= MorseUnit Then
			TRI_Stage=TRI_Stage+1
			If TRI_Stage>4 Then TRI_Stage = 0 '82,3, 230,10
			TRI_Delay=0
			UpdateSensors
		End If
	End If
	
	Diff=( 12 * TRI_Stage ) *ScaleFactor
	temp=23*ScaleFactor / 2
	X=X+ 82*ScaleFactor
	DrawBlinky(BG, X + Diff, Y, temp, 10*ScaleFactor, 0,0,255)
	DrawBlinky(BG, X + (140*ScaleFactor) - Diff, Y, temp, 10*ScaleFactor, 0,0,255)
	
	Return DateTime.Now 
End Sub
Sub DrawBlinky(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, R As Int, G As Int, B As Int) As Float 
	'LCARSeffects3.DrawBubbles(BG, 8,0, 8, X,Y, Width*3, R,G,B)
	Dim temp As Int ,X2 As Int= X+Width/2, Y2 As Int = Y+Height/2, Radius As Int =Max(Width,Height)/2, W As Int = Radius * 0.1, Color As Int=Colors.argb(16, R,G,B), Color2 As Int ,Ret As Float

	'DrawRect(BG,X,Y,Width,Height, Colors.argb(16, R,G,B),0)
	temp=Radius 
	Radius = Rnd(Radius*0.8, Radius*1.2)
	Ret = ( Radius - (temp * 0.8) ) / ( temp * 0.4)
	
	'LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	'	BG.DrawCircle(X2, Y2, Radius, Colors.rgb(R,G,B), True, 0)
	'BG.RemoveClip 
	If Main.AprilFools Then 
		Width = Radius*20	
'		R=R*0.5
'		G=G*0.5
'		B=B*0.5
		For temp = 0 To 10
			Radius=Radius+W
			BG.DrawOval(SetRect( X2- Radius*2, Y2-Radius, Radius*4, Radius*2), Color, True, 0)

'			Color2=Colors.aRGB(16, Min(255,R),Min(255,G),Min(255,B))
'			DrawRect(BG, X2-Width, Y2-Radius*0.5, Width*2, Radius, Color2, 0)
'			R=R+8
'			G=G+8
'			B=B+8
		Next
		
		Height = Radius*0.3
		Y=Radius*0.1
		Color=Colors.argb(128, R,G,B)
		Color2=Colors.Transparent'Colors.aRGB(0, R,G,B)
		LCAR.DrawGradient(BG, Color2, Color, 6, X2-Width, Y2-Height-Y , Width,  Height, 0,0)
		LCAR.DrawGradient(BG, Color, Color2, 6, X2, Y2-Height-Y , Width,  Height, 0,0)
		
		LCAR.DrawGradient(BG, Color2, Color, 6, X2-Width, Y2+Y , Width,  Height, 0,0)
		LCAR.DrawGradient(BG, Color, Color2, 6, X2, Y2+Y , Width,  Height, 0,0)
		
		LCAR.DrawGradient(BG, Color2, Color, 8, X2-Y, Y2-Width, Y*2, Width, 0,0)
		LCAR.DrawGradient(BG, Color, Color2, 8, X2-Y, Y2, Y*2, Width, 0,0)
	Else
		For temp = 0 To 10
			Radius=Radius+W
			BG.DrawCircle(X2, Y2, Radius, Color, True, 0)
		Next
	End If
	Return Ret
End Sub
Sub PullDigit(tempBlinky As Blinky, Digit As Int) 
	Dim tempDigit As MorseCodeDigit 
	If  tempBlinky.Morsecode.Size = 0 Then
		tempBlinky.TimeTillNextDigit = 10000
		tempBlinky.CurrentMorseDigit=-1
		tempBlinky.state=False
	Else
		If Digit > tempBlinky.Morsecode.Size-1 OR  Digit < 0 Then Digit=0
		tempDigit = tempBlinky.Morsecode.Get(Digit)
		tempBlinky.CurrentMorseDigit=Digit
		tempBlinky.state = tempDigit.state
		tempBlinky.TimeTillNextDigit = MorseUnit * tempDigit.Duration 
	End If
End Sub
Sub MakeBlinky(RegionID As Int, Morsecode As String, R As Int, G As Int, B As Int, X As Int, Y As Int, Width As Int, Height As Int)
	Dim tempBlinky As Blinky 
	tempBlinky.Initialize 
	tempBlinky.RegionID=RegionID
	tempBlinky.Morsecode = ToMorseCode(Morsecode)
	tempBlinky.R=R
	tempBlinky.G=G
	tempBlinky.B=B
	tempBlinky.X=X
	tempBlinky.Y=Y
	tempBlinky.Width = Width
	tempBlinky.Height=Height
	tempBlinky.CurrentMorseDigit=-1
	Blinkies.Add(tempBlinky)
End Sub
Sub SetBlinky(RegionID As Int, Morsecode As String) As Boolean 
	Dim temp As Int = FindBlinky(RegionID), tempBlinky As Blinky 
	If temp>-1 Then
		tempBlinky = Blinkies.Get(temp)
		tempBlinky.Morsecode = ToMorseCode(Morsecode)
		Return True
	End If
End Sub
Sub FindBlinky(RegionID As Int) As Int
	Dim temp As Int, tempBlinky As Blinky 
	For temp = 0 To Blinkies.Size - 1
		tempBlinky = Blinkies.Get(temp)
		If tempBlinky.RegionID = RegionID Then Return temp
	Next
	Return -1
End Sub

'Text: %=always on
Sub ToMorseCode(Text As String) As List 
	Dim temp As Int , Code As List, tempstr2 As String 
	Code.Initialize 
	Text = Text.ToUpperCase 
	For temp = 0 To Text.Length-1 
		Select Case API.Mid( Text , temp, 1)
			Case "A": tempstr2 = "·–"
			Case "B": tempstr2 = "–···"
			Case "C": tempstr2 = "–·–·"
			Case "D": tempstr2 = "–··"
			Case "E": tempstr2 = "·"
			
			Case "F": tempstr2 = "··–·"
			Case "G": tempstr2 = "––·"
			Case "H": tempstr2 = "····"
			Case "I": tempstr2 = "··"
			Case "J": tempstr2 = "·–––"
			
			Case "K": tempstr2 = "–·–"
			Case "L": tempstr2 = "·–··"
			Case "M": tempstr2 = "––"
			Case "N": tempstr2 = "–·"
			Case "O": tempstr2 = "–––"
			
			Case "P": tempstr2 = "·––·"
			Case "Q": tempstr2 = "––·–"
			Case "R": tempstr2 = "·–·"
			Case "S": tempstr2 = "···"
			Case "T": tempstr2 = "–"
			
			Case "U": tempstr2 = "··–"
			Case "V": tempstr2 = "···–"
			Case "W": tempstr2 = "·––"
			Case "X": tempstr2 = "–··–"
			Case "Y": tempstr2 = "–·––"
			
			Case "Z": tempstr2 = "––··"
			Case "0": tempstr2 = "–––––"
			Case "1": tempstr2 = "·––––"
			Case "2": tempstr2 = "··–––"
			Case "3": tempstr2 = "···––"
			
			Case "4": tempstr2 = "····–"
			Case "5": tempstr2 = "·····"
			Case "6": tempstr2 = "–····"
			Case "7": tempstr2 = "––···"
			Case "8": tempstr2 = "–––··"
			
			Case "9": tempstr2 = "––––·"
			Case ".": tempstr2 = "·–·–·–"
			Case ",": tempstr2 = "––··––"
			Case "?": tempstr2 = "··––··"
			Case "'": tempstr2 = "·––––·"
			
			Case "!": tempstr2 = "–·–·––"
			Case "/": tempstr2 = "–··–·"
			Case "(": tempstr2 = "–·––·"
			Case ")": tempstr2 = "–·––·–"
			Case "&": tempstr2 = "·–···"
			
			Case ":": tempstr2 = "–––···"
			Case ";": tempstr2 = "–·–·–·"
			Case "=": tempstr2 = "–···–"
			Case "+": tempstr2 = "·–·–·"
			Case "-": tempstr2 = "–····–"
			
			Case "_": tempstr2 = "··––·–"
			Case Eval.vbQuote : tempstr2 = "·–··–·"
			Case "$": tempstr2 = "···–··–"
			Case "@": tempstr2 = "·––·–·"
			Case " ": tempstr2 = " "
			
			Case "·": tempstr2 = "·"
			Case "–": tempstr2 = "–"
			Case "%": Code.Add( MakeMorseCodeDigit(True, 1))
			Case Else: tempstr2 = ""
		End Select
		If tempstr2.Length>0 Then AddMorseCode(Code, tempstr2)
	Next
	Return Code
End Sub
Sub AddMorseCode(Code As List, MorseCode As String) 
	Dim temp As Int
	For temp = 0 To MorseCode.Length-1
		Select Case API.Mid(MorseCode, temp,1)
			Case "·": Code.Add( MakeMorseCodeDigit(True, 1) )
			Case "–": Code.Add( MakeMorseCodeDigit(True, 3) )
			Case " ": Code.Add( MakeMorseCodeDigit(True, 4) )
		End Select
		Code.Add( MakeMorseCodeDigit(False, 1) )'If temp < MorseCode.length - 1 Then 
	Next
	Code.Add( MakeMorseCodeDigit(False, 3) )
End Sub
Sub MakeMorseCodeDigit(State As Boolean, Units As Int) As MorseCodeDigit 
	Dim temp As MorseCodeDigit 
	temp.Initialize 
	temp.State=State
	temp.Duration = Units
	Return temp 
End Sub





'0=mic,  1,2,3=acc,  4,5,6=mag,   7,8,9=ori,   10,11,12=gyro,    13=light, 14=pressure, 15=temperature, 16=proximity, 17=battery, 18=total magnetic field, 19=medical insurance remaining
Sub UseSensor(ID As Int)
	TRI_CurrentSensor=ID
	LCARSeffects2.ClearGraph(TRI_GraphID)
	'lcarseffects2.Axis(AxisID).Value 
End Sub

Sub SensorPercent(MinV As Int, MaxV As Int, V As Int) As Int 
	 Return Abs((V - MinV) / (MaxV - MinV) * 100)
End Sub
Sub UpdateSensors
	Dim SensorAxis As Int, MaxV As Int, MinV As Int
	If TRI_CurrentSensor < 0 Then
		SensorAxis = 1 + (Abs(TRI_CurrentSensor)-1)*3
		
		MinV= Min(Min(LCARSeffects2.Axis(SensorAxis).MinV, LCARSeffects2.Axis(SensorAxis+1).MinV), LCARSeffects2.Axis(SensorAxis+2).MinV)
		MaxV= Max(Max(LCARSeffects2.Axis(SensorAxis).MaxV, LCARSeffects2.Axis(SensorAxis+1).MaxV), LCARSeffects2.Axis(SensorAxis+2).MaxV)
		
		'Log("MaxV: " & MaxV & " " & LCARSeffects2.Axis(SensorAxis).Value & " " & LCARSeffects2.Axis(SensorAxis+1).Value & " " & LCARSeffects2.Axis(SensorAxis+2).Value)
		TRI_Sensors(0).X = SensorPercent(MinV,MaxV, LCARSeffects2.Axis(SensorAxis).Value)'LCARSeffects2.Axis(SensorAxis).Value / MaxV * 100
		TRI_Sensors(1).X = SensorPercent(MinV,MaxV, LCARSeffects2.Axis(SensorAxis+1).Value)'LCARSeffects2.Axis(SensorAxis+1).Value / MaxV * 100
		TRI_Sensors(2).X = SensorPercent(MinV,MaxV, LCARSeffects2.Axis(SensorAxis+2).Value)'LCARSeffects2.Axis(SensorAxis+2).Value / MaxV * 100
		'Log("VALUES: " & TRI_Sensors(0).X & " " & TRI_Sensors(1).X & " " & TRI_Sensors(2).X)
		
		MaxV=5'speed
		TRI_Sensors(0).y = LCAR.Increment(TRI_Sensors(0).y, MaxV, TRI_Sensors(0).X)
		TRI_Sensors(1).y = LCAR.Increment(TRI_Sensors(1).y, MaxV, TRI_Sensors(1).X)
		TRI_Sensors(2).y = LCAR.Increment(TRI_Sensors(2).y, MaxV, TRI_Sensors(2).X)
	Else  
		LCARSeffects2.AddPoint(TRI_GraphID, LCARSeffects2.Axis(TRI_CurrentSensor).Value) 
	End If
End Sub
Sub DrawSensorBlob(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim CenterX As Int, CenterY As Int, tempP(6) As Point , Radius As Int = 100'Min(width, height)/2' X + width/2 'Y + height/2,
	Dim Points As List 
	'Log("SENSOR BLOB: " & TRI_Sensors(0).y & " " & TRI_Sensors(1).y & " " & TRI_Sensors(2).y)
'	Log( (TRI_Sensors(0).y / 100 * Radius) )
'	Log( (TRI_Sensors(1).y / 100 * Radius) )
'	Log( (TRI_Sensors(2).y / 100 * Radius) )
	
	tempP(0) = Trig.FindAnglePoint(CenterX,CenterY, TRI_Sensors(0).Y, 0)' / 100 * Radius, 0)'red
	tempP(1) = Trig.FindAnglePoint(CenterX,CenterY, TRI_Sensors(1).Y, 120)' / 100 * Radius, 120)'blue
	tempP(2) = Trig.FindAnglePoint(CenterX,CenterY, TRI_Sensors(2).Y, 240)' / 100 * Radius, 240)'green
	
	tempP(3) = Trig.FindAnglePoint(CenterX,CenterY, ((TRI_Sensors(0).Y + TRI_Sensors(1).Y)/2), 60)' / 100 * Radius, 60)'
	tempP(4) = Trig.FindAnglePoint(CenterX,CenterY, ((TRI_Sensors(1).Y + TRI_Sensors(2).Y)/2), 180)' / 100 * Radius, 180)
	tempP(5) = Trig.FindAnglePoint(CenterX,CenterY, ((TRI_Sensors(0).Y + TRI_Sensors(2).Y)/2), 300)' / 100 * Radius, 300)
	
	'Log(tempP(0) & " " & tempP(1))
	
	MakeCurve(tempP(0).X, tempP(0).Y,  tempP(3).X, tempP(1).Y, tempP(1).X, tempP(1).Y, 10, Points)
	MakeCurve(tempP(1).X, tempP(1).Y,  tempP(4).X, tempP(4).Y, tempP(2).X, tempP(2).Y, 10, Points)
	MakeCurve(tempP(2).X, tempP(2).Y,  tempP(5).X, tempP(5).Y, tempP(0).X, tempP(0).Y, 10, Points)
	
	CenterX = X + Width/2
	CenterY = Y + Height/2
	Radius = Min(Width, Height)/2
	DrawPointsBlob(BG,CenterX,CenterY, Radius, Points, Colors.RGB(5,41,181))
	DrawPointsBlob(BG,CenterX,CenterY, Radius*0.75, Points, Colors.RGB(44,148,221))
	DrawPointsBlob(BG,CenterX,CenterY, Radius*0.5, Points, Colors.RGB(120,234,245))
	
	CenterX=Width*0.06
	CenterY=Height * 0.16
	DrawCircles(BG,X,Y,Width,Height,CenterX,CenterY, tempP)
	Radius= Colors.rgb(77,111,120)
	DrawTriangles(BG, X+CenterX*0.5, Y+CenterY, CenterX, Height-CenterY*2,  Radius,True)
	DrawTriangles(BG, X+Width-CenterX*1.5, Y+CenterY, CenterX, Height-CenterY*2,  Radius,False)
	LCARSeffects2.DrawCrossLines(BG,X+Width*0.2+CenterX*0.5,Y+CenterY-5,Width*0.6-CenterX,Height-CenterY*2+10, Height*0.1, 5, Colors.RGB(44,148,221), 2)
	LCARSeffects2.DrawBracket(BG, X + Width * 0.2, Y+CenterY, CenterX, Height-CenterY*2, True, True, LCAR.LCAR_TNG)
	LCARSeffects2.DrawBracket(BG, X + Width * 0.8-CenterX, Y+CenterY, CenterX, Height-CenterY*2, False, True, LCAR.LCAR_TNG)
	
	
	'BG.Drawline(CenterX,CenterY, tempP(0).x,tempP(0).Y, Colors.Red, 3)
	'BG.Drawline(CenterX,CenterY, tempP(1).x,tempP(1).Y, Colors.blue, 3)
	'BG.Drawline(CenterX,CenterY, tempP(2).x,tempP(2).Y, Colors.green, 3)
	
	'DrawCurve(BG, tempP(0).X, tempP(0).Y,  tempP(3).X, tempP(1).y, tempP(1).x, tempP(1).y, 10, Colors.Green , 2)
	'DrawCurve(BG, tempP(1).X, tempP(1).Y,  tempP(4).X, tempP(4).y, tempP(2).x, tempP(2).y, 10, Colors.red , 2)
	'DrawCurve(BG, tempP(2).X, tempP(2).Y,  tempP(5).X, tempP(5).y, tempP(0).x, tempP(0).y, 10, Colors.blue , 2)
	'''''DrawCurve(BG, tempP(2).X, tempP(2).Y,  tempP(0).X, tempP(0).y, tempP(1).x, tempP(1).y, 10, Colors.blue, 2)', Colors.blue, False, 2dip)
End Sub

Sub DrawCircles(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, CenterX As Int, CenterY As Int, tempP() As Point )
	Dim temp As Int 
	X=X+Width*0.2+CenterX*0.5
	Y=Y+CenterY+CenterX
	Height = Height - (CenterY+CenterX)*2
	Width = Width *0.8 -  CenterX
	CenterX=CenterX*0.25
	For temp = 0 To 4
		BG.DrawCircle(X + Width * Abs(tempP(temp).X/100), Y + Height * Abs(tempP(temp).Y/100), CenterX, Colors.White, True,0)
	Next
End Sub

Sub DrawTriangles(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, Color As Int,isLeft As Boolean)
	Dim IncY As Int = Height*0.2, temp As Int ,P As Path
	Height = IncY * 0.5 
	For temp = 1 To 5
		If isLeft Then
			P.Initialize(X, Y + Height*0.5)
			P.LineTo(X, Y + Height*1.5)
			P.LineTo(X+Width,Y+Height)
		Else
			P.Initialize(X+Width, Y + Height*0.5)
			P.LineTo(X+Width, Y + Height*1.5)
			P.LineTo(X,Y+Height)
		End If
		BG.DrawPath(P, Color,True,0)
		Y=Y+IncY
	Next
End Sub
Sub DrawPointsBlob(BG As Canvas, X As Int, Y As Int, Radius As Int, Points As List, Color As Int)
	Dim temp As Int , P As Path , temppoint As Point ,X2 As Int, Y2 As Int 
	For temp =  0 To Points.Size - 1
		temppoint = Points.Get(temp)
		X2 = X + temppoint.X/100 * Radius
		Y2 = Y + temppoint.Y/100 * Radius
		
		'Log("P: " & temp & " " & temppoint.X & " " & temppoint.Y & " - " & X & " " & Y & " - " & Radius)
		If temp = 0 Then
			P.Initialize(X2,Y2)
		Else
			P.LineTo(X2,Y2)
		End If
	Next
	BG.DrawPath(P, Color,True, 0)
End Sub


Sub DrawCurve(BG As Canvas, x1 As Int,y1 As Int,x2 As Int,y2 As Int,x3 As Int,y3 As Int, numpolys As Double, Color As Int, Stroke As Int) As Double 
'	Dim i As Double =0, x As Double ,y As Double, i2 As Double, iminus1 As Double, P As Path ' div1numpolys As Double = 1/ Max(2,numpolys),
'	P.Initialize(x3,y3)
'	If numpolys >=1 Then numpolys = 1/numpolys
'	Do While i<1
'		i2 = i*i
'		iminus1 = 1-i
'		x = x1*i2 + x2*i*(iminus1+iminus1) + x3*iminus1*iminus1
'		y = y1*i2 + y2*i*(iminus1+iminus1) + y3*iminus1*iminus1
'		P.LineTo(x,y)
'		i=i+numpolys
'	Loop
'	P.LineTo(x1,y1)
'	BG.DrawPath(P,Color,False,Stroke)
'	Return numpolys
	Dim P As Path
	numpolys = MakeCurvePath(x1,y1, x2,y2, x3,y3, numpolys, P)
	BG.DrawPath(P,Color,False,Stroke)
	Return numpolys
End Sub

Sub MakeCurvePath(x1 As Int,y1 As Int,x2 As Int,y2 As Int,x3 As Int,y3 As Int, numpolys As Double, P As Path)  As Double 
	Dim i As Double =0, x As Double ,y As Double, i2 As Double, iminus1 As Double ' div1numpolys As Double = 1/ Max(2,numpolys),
	If P.IsInitialized Then P.LineTo(x3,y3) Else P.Initialize(x3,y3)
	If numpolys >=1 Then numpolys = 1/numpolys
	Do While i<1
		i2 = i*i
		iminus1 = 1-i
		x = x1*i2 + x2*i*(iminus1+iminus1) + x3*iminus1*iminus1
		y = y1*i2 + y2*i*(iminus1+iminus1) + y3*iminus1*iminus1
		P.LineTo(x,y)
		i=i+numpolys
	Loop
	P.LineTo(x1,y1)
	Return numpolys
End Sub

'numpolys: 0=the distance between XY1 to XY2 to XY3, below zero=the same distance as 0 / abs(numpolys), between 0 and 1=the percentage of the curve each step will be, 1 and above=number of polygons
Sub MakeCurve(x1 As Int,y1 As Int,x2 As Int,y2 As Int,x3 As Int,y3 As Int, numpolys As Double, PointsList As List) As Double
	Dim i As Double =0, x As Double, y As Double, i2 As Double, iminus1 As Double', div1numpolys As Double = 1/ Max(2,numpolys)
	If numpolys <= 0 Then
		iminus1 = Trig.FindDistance(x1, y1, x2, y2) + Trig.FindDistance(x3, y3, x2, y2)
		If numpolys = 0 Then numpolys = iminus1 Else numpolys = iminus1 / Abs(numpolys)
	End If
	If numpolys >=1 Then numpolys = 1/numpolys
	Do While i<1
		i2 = i*i
		iminus1 = 1-i
		x = x1*i2 + x2*i*(iminus1+iminus1) + x3*iminus1*iminus1
		y = y1*i2 + y2*i*(iminus1+iminus1) + y3*iminus1*iminus1
		MakePoint(PointsList, x,y, False)
		i=i+numpolys
	Loop
	MakePoint(PointsList, x1,y1, False)
	Return numpolys
End Sub
Public Sub MakePoint(P As List, X As Int, Y As Int, NeedsInit As Boolean)
	If Not(P.IsInitialized) Or NeedsInit Then P.Initialize
	P.Add(Trig.SetPoint(X,Y))
End Sub










Sub SOL_HandleMouse(X As Int,Y As Int,EventType As Int , Width As Int, Height As Int)
	Dim temp As Int ,temp2 As Int 
	Select Case EventType 
		Case LCAR.Event_Down:	OldPoint = Trig.SetPoint(X,Y)
		Case LCAR.Event_Move:	OldPoint = Trig.SetPoint(OldPoint.X + X, OldPoint.Y+Y)
		Case LCAR.LCAR_Dpad
			Select Case X'X: 0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
				Case 3'left
					SOL_Speed = Max(0.1, SOL_Speed - 0.1)
				Case 1'right
					SOL_Speed = Min(6, SOL_Speed + 0.1)
				Case 0'up
					AstronomicalUnit = Min(1000, AstronomicalUnit + 10)
				Case 2'down
					AstronomicalUnit = Max(10, AstronomicalUnit - 10)
			End Select
			Return 
	End Select
	If EventType = LCAR.Event_Move Then
		If Width > Height Then '-------
			temp = Height*0.15
			If OldPoint.Y >= Height-temp Then'along bottom bar (zoom)
				AstronomicalUnit = AstronomicalUnit + X
			Else If OldPoint.X >= Width-temp Then'along right bar (time)
				temp=temp*1.25
				If OldPoint.Y<temp Then
					SOL_Speed=6
				Else If OldPoint.Y > Y+Height-temp Then
					SOL_Speed=0.1
				Else
					temp2=Height-temp*2
					SOL_Speed = ((temp2 - OldPoint.Y+temp) / temp2) * 6
				End If
			Else'center
			
			End If
		Else'|
			temp = Width*0.15
			If OldPoint.X<= temp Then'along left bar (zoom)
				AstronomicalUnit = AstronomicalUnit + Y
			Else If OldPoint.Y >= Height-temp Then'along bottom bar (time)
				temp=temp*1.25
				If OldPoint.X<temp Then
					SOL_Speed=0.1
				Else If OldPoint.X> X+Width-temp Then
					SOL_Speed=6
				Else
					temp2=Width-temp*2
					SOL_Speed = (OldPoint.X - temp) / temp2 * 6
				End If
			Else'center
			
			End If
		End If
		AstronomicalUnit = Max(AstronomicalUnit, 10)
		SOL_Speed = Max(SOL_Speed , 0.1)
	End If
End Sub
Sub SOL_DrawCircle(BG As Canvas, X As Int, Y As Int, Radius As Int, Alpha As Int, R As Int, G As Int, B As Int, Stroke As Int, Radius2 As Int)
	BG.DrawCircle(X,Y,Radius,Colors.ARGB(Alpha,R,G,B), True,0 )
	R=Colors.RGB(R,G,B)
	BG.DrawCircle(X,Y,Radius,R, False, Stroke)
	If Radius2>0 Then BG.DrawCircle(X,Y,Radius2,R, False, Stroke)
End Sub
Sub SOL_DrawPlanets(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, System As Int)
	Dim Angle As Int = API.IIF(Width>Height, 0,90), tempPlanet As Planet, temp As Int , CenterX As Int = X+Width/2, CenterY As Int = Y + Height/2, Update As Double
	Dim Brown As Int = Colors.RGB(122 ,60,41), temp2 As Int 
	Width=Width+2
	Height=Height+2
	DrawRect(BG,X,Y,Width,Height, SOL_Beige, 0)
	If System <> CurrentSystem Then SOL_MakePlanets(System)
	If AstronomicalUnit = 0 Then AstronomicalUnit  = Min( Max(Width,Height) / SOL_LW, Min(Width,Height) / SOL_LH)
	LCARSeffects.CacheAngles(Max(Height,Width)*2,-1)
	If Angle = 0 Then'----------
		temp = Height*0.15
		LCAR.DrawGradient2(BG,  Array As Int( Colors.RGB(108,111,106), Colors.RGB(175,146,94), Colors.RGB(191,112,80)),  6  ,X + Width * 0.1635544108177721 ,Y,Width *0.7559562137797811 ,Height+1-temp,0,0)
		SOL_DrawBars(BG, X + Width * 0.1635544108177721 ,Y+temp,Width *0.7559562137797811 ,Height+1-temp*2,temp)
		BG.DrawLine(X, CenterY, X+Width, CenterY, Colors.RGB(93,61,59), 3)'---------- center
		
		SOL_DrawGraph(BG, X, Y + Height - temp, Width, temp*0.5, False, Brown,   AstronomicalUnit*5, 0, 4, 3,2, False,-1,-1,-1)
		temp=temp*1.25
		Update = (Height-temp*2)*0.16
		temp2 = Update * 6
		SOL_DrawGraph(BG, X+Width-temp, Y+Height/2 - temp2/2, temp, temp2, False, Brown, Update, temp * 0.3, 5, 4,2,True, SOL_Speed,0,6)
		'SOL_DrawGraph(BG, X+Width-temp, Y+temp, temp, Height-temp*2, False, Brown, (Height-temp*2)*0.16, temp * 0.3, 5, 4,2)
	Else'|
		temp = Width*0.15
		LCAR.DrawGradient2(BG,  Array As Int( Colors.RGB(108,111,106), Colors.RGB(175,146,94), Colors.RGB(191,112,80)),  8  ,X +temp,Y + Height * 0.1635544108177721,Width+1-temp,Height*0.7559562137797811,0,0)
		SOL_DrawBars(BG, X +temp,Y + Height * 0.1635544108177721,Width+1-temp*2,Height*0.7559562137797811,temp)
		BG.DrawLine(CenterX, Y, CenterX, Y+Height, Colors.RGB(93,61,59), 3)'----------
		
		SOL_DrawGraph(BG, X+ temp*0.5, Y, temp*0.5, Height, False,Brown,   AstronomicalUnit*5, 0, 4, 3,2,False,-1,-1,-1)
		temp=temp*1.25
		Update = (Width-temp*2)*0.16
		temp2 = Update * 6
		SOL_DrawGraph(BG, X+ Width/2 - temp2/2, Y+ Height-temp,temp2, temp, True,  Brown, Update, temp * 0.3, 5, 4,2,True,SOL_Speed,0,6)
		'SOL_DrawGraph(BG, X+ temp, Y+ Height-temp, Width-temp*2, temp, True,  Brown, (Width-temp*2)*0.16, temp * 0.3, 5, 4,2)
	End If
	
	'SOL_DrawLines(BG, X,Y,Width,Height,CenterX,CenterY, Brown, 2, Array As Double( 0.1275571600481348,0.1829121540312876,0.2274368231046931, 0.2623345367027677, 0.3032490974729242, 0.381468110709988, 0.6594464500601685,0.9217809867629362 ))'831
	If SOL_LastUpdate > 0 Then Update = (SOL_LastUpdate - DateTime.Now) / DateTime.TicksPerSecond Else Update = 0
	For temp = 0 To Planets.Size - 1
		tempPlanet = Planets.Get(temp)
		Select Case tempPlanet.BodyType 
			Case Sun
				SOL_DrawCircle(BG, CenterX,CenterY, 20,     64,   41,66,100,  2,0)
				'BG.DrawCircle(CenterX,CenterY, 20, Colors.RGB(44,69,79), True, 0)
			Case Asteroids
				temp2=20
				If Angle = 0 Then
					DrawRect(BG, CenterX + tempPlanet.Aphelion*AstronomicalUnit, CenterY -temp2, 5, temp2, Brown, 0)
				Else
					DrawRect(BG, CenterX -temp2, CenterY + tempPlanet.Aphelion*AstronomicalUnit, temp2, 5, Brown, 0)
				End If
				
			Case Else'planet (ClassD, ClassH, ClassJ, ClassK, ClassL, ClassM, ClassN, ClassT, ClassY)
				SOL_DrawPlanet(BG, tempPlanet, CenterX, CenterY, Angle,  Update, Brown)
		End Select
	Next
	temp = Min(Width,Height)' * 0.15
	SOL_DrawCompass(BG,CenterX, CenterY, temp* 0.2, Brown, 2, 10, Angle)
	temp = temp * 0.15
	LCAR.DrawGradient2(BG,  Array As Int(Colors.Black, Colors.ARGB(0,0,0,0)), 6, X,Y, temp,Height+1, 0,0)'left
	LCAR.DrawGradient2(BG,  Array As Int(Colors.Black, Colors.ARGB(0,0,0,0)), 4, X+Width-temp+1,Y,temp,Height+1,0,0)'right
	LCAR.DrawGradient2(BG,  Array As Int(Colors.Black, Colors.ARGB(0,0,0,0)), 8, X,Y, Width+1, temp, 0,0)'top
	LCAR.DrawGradient2(BG,  Array As Int(Colors.Black, Colors.ARGB(0,0,0,0)), 2, X,Y+Height-temp+1, Width+1, temp, 0,0)'bottom
	SOL_LastUpdate = DateTime.Now 
End Sub
Sub SOL_DrawBars(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, TempHeight As Int)
	Dim MaxPercent As Int, tempbar As Point ,temp As Int ,temp2 As Int ,X2 As Int = X, Y2 As Int = Y, Color As Int = Colors.aRgb(128,253,83,83),Stroke As Int = 8, Squaresize As Int = 25 * LCAR.GetScalemode
	If Not(SOL_Bars.IsInitialized) Then
		SOL_Bars.Initialize 
		For temp = 1 To 20
			SOL_Bars.Add ( Trig.SetPoint(Rnd(0,100), Rnd(0,100)))
		Next
	Else
		MaxPercent = API.IIF(Width > Height, Width, Height) / SOL_Bars.Size
		If Width>Height Then'---------
			temp=Y - TempHeight*0.5
			BG.DrawLine(X, temp-Stroke, X, Y+ Height*0.9,Color, Stroke)'left
			BG.DrawLine(X+Width, temp-Stroke, X+Width, Y+ Height*0.9,Color, Stroke)'right
			BG.DrawLine(X+Stroke*0.5,temp, X+Width-Stroke*0.5, temp, Color, Stroke*2)'top
		Else'    =|
			temp=X - TempHeight*0.5
			BG.DrawLine(X + Width*0.1, Y,   X+Width+temp-Stroke, Y, Color,Stroke)'top
			BG.DrawLine(X + Width*0.1, Y+Height,   X+Width+temp-Stroke, Y+Height, Color,Stroke)'bottom
			BG.DrawLine(X+Width+temp,  Y-Stroke*0.5,  X+Width+temp,   Y+Height+Stroke*0.5, Color, Stroke*2)'right
		End If
		For temp = 0 To SOL_Bars.Size-1
			tempbar = SOL_Bars.Get(temp)
			temp2=(MaxPercent*tempbar.X*0.01)
			If Width > Height Then '------ so bars go ||
				Color = API.HSLtoRGB(    (1- ((X2+temp2-X)/Width))    *179,127,127,255)
				SOL_DrawBar(BG, X2+ temp2, Y, Squaresize, Height, Color, 2)
				X2=X2+MaxPercent
			Else'| so bars go ===
				Color = API.HSLtoRGB(  (1-((Y2+temp2-Y)/Height))*179,127,127,255)
				SOL_DrawBar(BG, X, Y2 + temp2, Width, Squaresize, Color,2)
				Y2=Y2+MaxPercent
			End If
			tempbar.X = LCAR.Increment(tempbar.X, 5, tempbar.Y)
			If tempbar.X = tempbar.Y Then tempbar.Y = Rnd(0,100)
		Next
	End If
End Sub
Sub SOL_DrawBar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	If Width > Height Then '-----------
		BG.DrawLine(X,Y, X+Width, Y, Color, Stroke)
		DrawRect(BG, X, Y-Height*0.5, Height,Height, Color,0)
		DrawRect(BG, X+Width-Height, Y-Height*0.5, Height,Height, Color,0)
	Else'|
		BG.DrawLine(X,Y, X, Y+Height, Color, Stroke)
		DrawRect(BG, X-Width*0.5, Y, Width,Width, Color,0)
		DrawRect(BG, X-Width*0.5, Y+Height-Width, Width,Width, Color,0)
	End If
End Sub
Sub SOL_DrawLines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CenterX As Int, CenterY As Int, Color As Int, Stroke As Int, Percentages() As Double )
	Dim LandScape As Boolean = Width> Height, temp As Int , Finish As Int = API.IIF( LandScape, X+Width, Y+Height)
	For temp = 0 To Percentages.Length -1 
		If LandScape Then
			BG.DrawLine(CenterX,CenterY, Finish, Height * Percentages(temp), Color, Stroke)
		Else
			BG.DrawLine(CenterX,CenterY, Width * (1-Percentages(temp)), Finish, Color, Stroke)
		End If
	Next
End Sub
Sub SOL_DrawCompass(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Stroke As Int, Radius2 As Int, Offset As Int) 'every 10 degrees
	Dim temp As Int, Stroke2 As Int = Stroke*0.5 ,Angle As Int = Trig.findXYAngle(0,0, Radius+Radius2, 10, True), TextSize As Int = API.GetTextHeight(BG, -Angle, " 360", Typeface.DEFAULT)
	Dim DoInc As Boolean = Stroke>0, Inc As Int = 10
	If DoInc Then
		BG.DrawCircle(X,Y,Radius, Color,False, Stroke)
	Else
		Stroke=Abs(Stroke)
		Inc=2
	End If
	For temp = 0 To 359 Step Inc
		Angle = (temp+Offset) Mod 360
		DoInc = temp Mod 10 = 0
		SOL_DrawCompassUnit(BG, X,Y,Radius,Radius2,Angle,Color,API.IIF(DoInc,Stroke,Stroke2),temp,API.IIF(DoInc, TextSize,0))
		
		'X2=Trig.findXYAngle(X,Y, Radius, Angle, True)
		'Y2=Trig.findXYAngle(X,Y, Radius, Angle, False)
		
		'X3=Trig.findXYAngle(X,Y, Radius+Radius2, Angle, True)
		'Y3=Trig.findXYAngle(X,Y, Radius+Radius2, Angle, False)
		
		'BG.DrawLine( X2,Y2,  X3,Y3,    Color,Stroke)
		'BG.DrawTextRotated(temp,    X3,Y3,    Typeface.DEFAULT, TextSize,   Color,   "RIGHT",    Angle)
	Next
End Sub
Sub SOL_DrawMiniCompass(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Stroke As Int, Radius2 As Int, Inc As Float)
	Dim Angle As Float,Radius3 As Int = Radius-Radius2,DrawCompass As Boolean = Inc > 0 
	'BG.DrawCircle(X,Y,Radius*0.25, Colors.Black , True, 0)
	Inc=Abs(Inc)
	Do Until Angle >= 360 'For Angle = 0 To 359 Step Inc
		SOL_DrawCompassUnit(BG, X,Y,Radius2,Radius3,Angle,Color,Stroke,Angle,0)
		Angle=Angle+Inc
	Loop'Next
	Stroke=Stroke-1
	If DrawCompass Then SOL_DrawCompass(BG, X,Y, Radius*0.9, Color, -Stroke, 10, 0)
	BG.DrawCircle(X,Y,Radius, Color, False, 10)
	BG.DrawCircle(X,Y,Radius*0.75, Color, False, 3)
	BG.DrawCircle(X,Y,Radius*0.50, Color, False, 3)
	BG.DrawCircle(X,Y,Radius*0.25, Color, False, 3)
End Sub

'Textsize needs to be above 0 to draw text
Sub SOL_DrawCompassUnit(BG As Canvas, X As Int, Y As Int, Radius As Int, Radius2 As Int, Angle As Int, Color As Int, Stroke As Int, temp As Int, TextSize As Int)
	Dim X2 As Int, Y2 As Int, X3 As Int, Y3 As Int
	X2=Trig.findXYAngle(X,Y, Radius, Angle, True)
	Y2=Trig.findXYAngle(X,Y, Radius, Angle, False)
	
	X3=Trig.findXYAngle(X,Y, Radius+Radius2, Angle, True)
	Y3=Trig.findXYAngle(X,Y, Radius+Radius2, Angle, False)
	
	BG.DrawLine( X2,Y2,  X3,Y3,    Color,Stroke)
	If TextSize>0 Then BG.DrawTextRotated(temp,    X3,Y3,    Typeface.DEFAULT, TextSize,   Color,   "RIGHT",    Angle)
End Sub


Sub SOL_DrawPlanet(BG As Canvas, tempPlanet As Planet, X As Int, Y As Int, Angle As Int, Update As Double, MoonColor As Int)
	Dim Aphelion As Int = tempPlanet.Aphelion * AstronomicalUnit, R As Int, G As Int, B As Int', Perihelion As Int = tempPlanet.Perihelion * AstronomicalUnit
	Dim Width As Int = Aphelion*2, Height As Int = Width - Width* tempPlanet.Eccentricity,Radius2 As Int '+Perihelion
	Dim Dest As Rect, X2 As Int, Y2 As Int ,Radius As Int, Offset As Int = Aphelion, Distance As Int' tempPlanet.SemiMajorAxis * AstronomicalUnit
	'Aphelion     FOCUS Perihelion
	'(--------------O-------)
	'Orbital eccentricity:
	'0	= circle
	'<1	= elliptic orbit
	'1	= parabolic trajectory
	'>1 = hyperbolic trajectory
	If Angle = 0 Then'-----
		Dest = SetRect(X - Offset, Y- Height/2, Width, Height)
		Radius = X - Offset + (Width * 0.5)
		X2 = Trig.findXYAngle(Radius, Y,  Offset, tempPlanet.Degree, True)
		Y2 = Trig.findXYAngle(Radius, Y,  Height/2, tempPlanet.Degree, False)
	Else'|
		Dest = SetRect(X - Height/2, Y-Offset, Height,Width)
		Radius =Y - Offset + (Width * 0.5)
		X2 = Trig.findXYAngle(X, Radius, Height/2, tempPlanet.Degree+Angle, True)
		Y2 = Trig.findXYAngle(X, Radius, Offset, tempPlanet.Degree+Angle, False)
	End If
	Distance= Max(Offset, Height/2)
	Radius = Max(EarthRadius * tempPlanet.Radius * (AstronomicalUnit*0.01) ,5)
	BG.DrawOval(Dest,Colors.rgb(81,96,107), False,4)'RGB(148,148,139)'orbit
	Select Case tempPlanet.BodyType 
		Case ClassD'Ceres,Pluto (Planetoid or moon; uninhabitable)
			R=128:	G=128:	B=128
		Case ClassF'geologically inactive with no atmosphere
			R=128:	G=64:	B=0
		Case ClassH'Mercury (Generally uninhabitable)
			R=192:	G=192:	B=192
		Case ClassJ'Jupiter,Saturn (Gas giant)
			R=157:	G=0:	B=157
			Radius2= Radius*4
		Case ClassK'Mars (Adaptable with pressure domes)
			R=209:	G=97:	B=97
			Radius2= Radius*4
		Case ClassL'Marginally habitable 
			R=0:	G=128:	B=0
			Radius2= Radius*3
		Case ClassM'Earth (Habitable)
			R=145:	G=255:	B=145
			Radius2= Radius*4
		Case ClassN'Venus (Sulfuric)
			R=109:	G=115:	B=43
			Radius2= Radius*2
		Case ClassP'glaciated
			R=6:	G=140:	B=151
			Radius2= Radius*3
		Case ClassT'Uranus,Neptune (Gas giant)
			R=170:	G=175:	B=240
			Radius2= Radius*4
		Case ClassY'Demon class
			R=157:	G=0:	B=4
	End Select
	SOL_DrawCircle(BG,    X2,  Y2,   Radius,  128,      R,   G,    B,     2,       Radius2)' , )
	If tempPlanet.Moons > 0 Then SOL_DrawMoons(BG,     X,   Y,   Distance*2, 10,     tempPlanet.Moons, 2,       MoonColor,tempPlanet.Degree+Angle, 2)
	'BG.DrawCircle(X2,Y2, Radius, Colors.Rgb(134,75,70), True, 0)'planet
	tempPlanet.Degree = tempPlanet.degree + (tempPlanet.OrbitalPeriod * SOL_Speed) '(Update * tempPlanet.OrbitalPeriod)
	If tempPlanet.Degree >=360 Then tempPlanet.Degree = tempPlanet.Degree - 360
	If tempPlanet.Degree <0 Then tempPlanet.Degree = tempPlanet.Degree + 360
End Sub

Sub SOL_DrawMoons(BG As Canvas, X As Int, Y As Int, Radius As Int, Length As Int, Moons As Int, DegreesBetween As Int, Color As Int, Degree As Double, Stroke As Int)
	Dim Angle As Int = (Moons + 1) * DegreesBetween , Start As Int = Trig.CorrectAngle( Degree - Angle*0.5 ), temp As Int , tempAngle As Point = LCARSeffects.CacheAngles(0, Start), P As Path 
	P.Initialize(X,Y)
	P.LineTo(tempAngle.X+X, tempAngle.Y+Y)
	SOL_DrawLine(BG,     X,   Y,    0,       Radius,   Start,   Color,    Stroke)
	For temp = 1 To Moons + 1
		If temp <= Moons Then 
			SOL_DrawLine(BG,     X,   Y,    Radius-Length*0.5, API.IIF(temp Mod 5 = 0 , Length*2.5,  Length*1.5),   Start, Color, Stroke) 
			If temp< Moons Then Start=(Start+DegreesBetween) Mod 360
		Else
			SOL_DrawLine(BG,     X,   Y,    0,       Radius,   Start,   Color,    Stroke)
		End If
		tempAngle = LCARSeffects.CacheAngles(0, Start)
		P.LineTo(tempAngle.X+X, tempAngle.Y+Y)
	Next
	P.LineTo(X,Y)
	BG.ClipPath(P)
		BG.DrawCircle(X,Y, Radius-Length*0.5, Color, False, Length)
	BG.RemoveClip
End Sub
Sub SOL_DrawLine(BG As Canvas, X As Int, Y As Int, Radius As Int, Length As Int, Angle As Int, Color As Int, Stroke As Int )
	BG.DrawLine( Trig.findXYAngle(X,Y, Radius, Angle, True), Trig.findXYAngle(X,Y, Radius, Angle, False), Trig.findXYAngle(X,Y, Radius+Length, Angle, True), Trig.findXYAngle(X,Y, Radius+Length, Angle, False), Color,Stroke)
End Sub


Sub SOL_DrawGraph(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Boolean, Color As Int, BigSpace As Int, BarSize As Int, LittleBars As Int, BigStroke As Int, LittleStroke As Int, Alternate As Boolean, Value As Float, MinValue As Float, MaxValue As Float) As Int 
	Dim LittleHeight As Int , temp As Int , Temp2 As Int, LittleSpace As Int = BigSpace / (LittleBars + 1), Temp3 As Int , State As Boolean ,StateHeight As Int 
	'Align=true     |,,,,|,,,,|,,,,| (against bottom/left) |-
	'               ----------------
	'               ________________
	'Align=false    |''''|''''|''''| (against top/right)   -|
'	If LittleSpace <= 1 Then
'		For temp = 10 To 2
'			If (temp+1) * (temp+1) = BigSpace Then
'				LittleBars = temp
'				LittleSpace = BigSpace / (LittleBars + 1)
'				temp=0
'				Log(LittleBars & " " & LittleSpace)
'			End If
'		Next
'	End If
	If Width>Height Then'horizontal
		If BarSize > 0 Then
			If Align Then
				'DrawRect(BG,X,Y+Height-BarSize-1,Width, BarSize, Color, 0)
				SOL_DrawIndicator(BG,X,Y+Height-BarSize-1,Width, BarSize, Color, SOL_Beige, Value,MinValue,MaxValue)
			Else
				'DrawRect(BG,X,Y,Width, BarSize, Color, 0)
				Y=Y+SOL_DrawIndicator(BG,X,Y,Width, BarSize, Color, SOL_Beige, Value,MinValue,MaxValue)
				'Y=Y+BarSize
			End If
			Height = Height-BarSize
		End If
		LittleHeight = Height/2
		StateHeight = Height/3
		For temp = X To X + Width Step LittleSpace
			If Temp2 = 0 Then
				If State Or Not(Alternate) Then
					BG.DrawLine(temp, Y, temp, Y+Height, Color,BigStroke)
				Else
					BG.DrawLine(temp, Y+StateHeight+BarSize, temp, Y+Height, Color,BigStroke)
				End If
				If Alternate Then State = Not(State)
			Else
				Temp3 = Y + API.IIF(Align, LittleHeight,0)
				BG.DrawLine(temp, Temp3, temp, Temp3 + LittleHeight, Color, LittleStroke)
			End If
			'If LittleBars >0 Then Temp2 = Temp2+1 Mod (LittleBars + 1)
			Temp2=Temp2+1
			If Temp2 = LittleBars+1  Then Temp2 = 0
		Next
	Else'vertical'|
		If BarSize > 0 Then
			If Align Then
				'DrawRect(BG,X,Y,BarSize,Width,Color,0)
				X=X+SOL_DrawIndicator(BG,X,Y, BarSize,Width, Color, SOL_Beige, Value,MinValue,MaxValue)
				'X=X+BarSize
			Else
				'DrawRect(BG,X+Width-BarSize-1,Y,BarSize, Height, Color, 0)
				SOL_DrawIndicator(BG,X+Width-BarSize-1,Y,BarSize, Height, Color,  SOL_Beige, Value,MinValue,MaxValue)
			End If
			Width=Width-BarSize
		End If
		LittleHeight = Width/2
		StateHeight = Width/3
		For temp = Y To Y + Height Step LittleSpace
			If Temp2 = 0 Then
				If State Or Not(Alternate) Then
					BG.DrawLine(X, temp, X+Width, temp, Color,BigStroke)
				Else
					BG.DrawLine(X+StateHeight, temp, X+Width+BarSize, temp, Color,BigStroke)
				End If
				If Alternate Then State = Not(State)
			Else
				Temp3 = X + API.IIF(Align, 0,LittleHeight )
				BG.DrawLine(Temp3, temp,  Temp3+ LittleHeight, temp, Color, LittleStroke)
			End If
			Temp2 = Temp2+1 
			If Temp2 = (LittleBars + 1) Then Temp2 = 0
		Next
	End If
	Return LittleBars
End Sub
Sub SOL_DrawIndicator(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, IndicatorColor As Int, Value As Float, MinValue As Float, MaxValue As Float) As Int
	Dim Size As Int = Min(Width,Height), Percent As Float ,Offset As Int  = Size * 0.25
	DrawRect(BG,X,Y,Width,Height,Color,0)
	If MinValue <> MaxValue Then
		Percent = (Value-MinValue) / (MaxValue-MinValue)
		If Width > Height Then '-----------
			DrawRect(BG, X - Offset + (Width-Size)*Percent+1, Y+1, Size-2, Size-2,  IndicatorColor, 0)
		Else'|
			DrawRect(BG, X+1, Y+ Offset + (Height-Size)*(1-Percent)+1,  Size-2, Size-2,  IndicatorColor, 0)
		End If
	End If
	Return Size
End Sub
Sub SOL_MakePlanets(System As Int) 
	Planets.Initialize 
	AstronomicalUnit=0
	SOL_LastUpdate=0
	SOL_LW =0
	SOL_LH =0
	Select Case System'     Class       Name        Aphelion        Perihelion      SemiMajorAxis   Eccentricity    OrbitalPeriod Radius    Moons
		Case 0'"sol"'http://en.wikipedia.org/wiki/Solar_System
			SOL_MakePlanet(Sun,			"Sol", 		0,				0,				0,				0,				0,			109,		0) 		'http://en.wikipedia.org/wiki/Sun (G-type)
			'Inner planets
			SOL_MakePlanet(ClassH, 		"Mercury", 	0.466697,		0.307499,		0.387098,		0.205630, 		0.240846,	0.3829,		0)  	'http://en.wikipedia.org/wiki/Mercury_%28planet%29
			SOL_MakePlanet(ClassN, 		"Venus",	0.728213,		0.718440,		0.723327,		0.0067,			0.615198,	0.9499,		0)		'http://en.wikipedia.org/wiki/Venus
			SOL_MakePlanet(ClassM,		"Earth",	1.01671388,		0.98329134,		1.00000261,		0.01671123,		1,			1,			1)		'http://en.wikipedia.org/wiki/Earth
			SOL_MakePlanet(ClassK, 		"Mars",		1.665861,		1.381497,		1.523679,		0.093315,		1.8808,		0.533,		2)		'http://en.wikipedia.org/wiki/Mars

			SOL_MakePlanet(Asteroids,	"Belt",		2.06,			2.06,			2.06,			0,				0,			0,			0)		'http://en.wikipedia.org/wiki/Asteroid_belt
			SOL_MakePlanet(ClassD,		"Ceres",	2.9765,			2.5570,			2.7668,			0.075797,		4.60,		0.073,		0)		'http://en.wikipedia.org/wiki/Ceres_(dwarf_planet)
			'Outer planets
			SOL_MakePlanet(ClassJ,		"Jupiter",	5.458104,		4.950429,		5.204267,		0.048775,		11.8618,	11.209,		67)		'http://en.wikipedia.org/wiki/Jupiter
			SOL_MakePlanet(ClassJ, 		"Saturn",	10.11595804,	9.04807635, 	9.5820172,		0.055723219,	29.4571,	9.4492,		62)		'http://en.wikipedia.org/wiki/Saturn
			SOL_MakePlanet(ClassT, 		"Uranus",	20.08330526,	18.37551863,	19.22941195,	0.044405586,	-84.323326,	4.007,		27)		'http://en.wikipedia.org/wiki/Uranus
			SOL_MakePlanet(ClassT, 		"Neptune",	30.44125206,	29.76607095,	30.10366151,	0.011214269,	-164.79,	3.883,		14)		'http://en.wikipedia.org/wiki/Neptune
			'http://en.wikipedia.org/wiki/Centaur_(minor_planet)
			'Trans-Neptunian region
			'http://en.wikipedia.org/wiki/Kuiper_belt
			SOL_MakePlanet(ClassD, 		"Pluto",	48.871,			29.657,			39.264,			0.244671664,	247.68,		0.18,		5)		'http://en.wikipedia.org/wiki/Pluto
			'http://en.wikipedia.org/wiki/Makemake_(dwarf_planet)
			'http://en.wikipedia.org/wiki/Haumea_(dwarf_planet)
			'http://en.wikipedia.org/wiki/Scattered_disc
			'http://en.wikipedia.org/wiki/Eris_(dwarf_planet)
			'Detached objects
			'http://en.wikipedia.org/wiki/90377_Sedna
			'http://en.wikipedia.org/wiki/Oort_cloud
		Case 1'"vulcan"'http://en.wikipedia.org/wiki/40_Eridani
	End Select
	CurrentSystem=System
End Sub'Sun As Byte = 0, sPlanet As Byte = 1, Asteroids As Byte = 2 
Sub SOL_MakePlanet(BodyType As Byte, Name As String, Aphelion As Float, Perihelion As Float, SemiMajorAxis As Float, Eccentricity As Float, OrbitalPeriod As Float, Radius As Float, Moons As Byte)
	Dim temp As Planet 
	temp.Initialize 
	temp.BodyType 		= BodyType
	temp.Degree 		= Rnd(0,360)
	temp.Name			= Name
	temp.Aphelion		= Aphelion
	temp.Perihelion		= Perihelion
	temp.SemiMajorAxis	= SemiMajorAxis
	temp.Eccentricity	= Eccentricity
	temp.OrbitalPeriod	= 1/OrbitalPeriod
	temp.Radius			= Radius'6378.1 km
	temp.Moons 			= Moons
	Planets.Add(temp)
	
	SOL_LW = Max(SOL_LW, Aphelion*2)
	SOL_LH = Max(SOL_LH, SOL_LW - (SOL_LW * Eccentricity))
End Sub












Sub EVN_and_BTL_HandleMouse(Action As Int, X As Int, Y As Int, Width As Int, Height As Int, ElementType As Int)
	Dim Index As Int = -1, X2 As Int, Y2 As Int, Thumbsize As Point 
	If Action = LCAR.Event_Down Then
		If ElementType = LCAR.EVENT_Horizon Then
			If Width > Height Then
				If EH_Stage=-2 Then
					EH_Stage=-1'open bomb
					EH_SubStage=0
				Else If EH_Stage <3 Then'next stage
					EH_Stage=EH_Stage+1
					EH_SubStage=0
				Else'buttons at the bottom
					If EH_Better Then 
						Thumbsize = API.Thumbsize(665,406, Width,Height, True, False)
						X2=Width*0.5- Thumbsize.X*0.5
						X2= X2 + (Thumbsize.X * 0.05413533834586466165413533834586)
						Width = Thumbsize.X * 0.89774436090225563909774436090226'597
						If X > X2 And X < X2+Width Then	Index = Floor((X - X2) / (Width/6))
					Else
						Index = Floor(X / (Width/6))
					End If
				End If
			End If
		Else'DRADIS
			If Width < Height Then
				X2 = ResizeElement(Width,Height)
				Y2= (Height*0.5) - (X2*0.5)
				Height=X2
			End If
			If Y > Y2 And Y < Y2 + LCAR.ItemHeight*2 Then Index = 3'abort/belay
		End If
		LCAR.PushEvent(LCAR.EVENT_Horizon, Index,     0,X,Y,Width,Height, Action)       'LCAR.LCAR_LWP,
	End If
End Sub

Sub ResetEventHorizon(BG As Canvas, ElementID As Int) As Boolean 
	If ElementID>-1 Then
		LCAR.ForceHideAll(BG)
		LCAR.DrawFPS=True
		LCAR.ForceShow(ElementID, True)
		EH_Stage=0
		EH_SubStage=0
		LCAR.CurrentStyle=LCAR.Event_Horizon
		EH_TextHeight = 0
		EH_Better=File.Exists(LCAR.DirDefaultExternal, "syseventhor.png")
		LCARSeffects2.CenterPlatformID=0'force reload
		If EH_Better Then
			LCARSeffects2.LoadUniversalBMP(File.DirDefaultExternal, "syseventhor.png", LCAR.EVENT_Horizon)
			'http://sites.google.com/site/programalpha11/home/lcars/syseventhor.png?attredirects=0
			EH_Stage=-2
		Else
			LCARSeffects2.LoadUniversalBMP(File.DirAssets, "eventhor.png", LCAR.EVENT_Horizon)
		End If
	Else 
		If LCAR.Landscape And EH_Stage>-2 And EH_Stage < 5 Then 'increment stages
			EH_SubStage = EH_SubStage + API.IIF(EH_Stage=3,1, 2)
			If EH_Stage= -1 Then EH_SubStage = EH_SubStage + 2
			If EH_SubStage >= EH_MaxStage Then
				EH_SubStage= 0 
				EH_Stage = EH_Stage + 1
			End If
		End If
		Return True
	End If
End Sub

'LCARSeffects2.CenterPlatform is usually the SRC, but color must be Colors.Transparent to use the SRC
Sub DrawTrapezoid(BG As Canvas, SRC As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, Angle As Int, DestX As Int, DestY As Int, DestWidth As Int, GoUp As Boolean, Color As Int)
	Dim Scalefactor As Float = DestWidth/SrcWidth,  X2 As Int, Y2 As Int ,P As Path ,DestHeight As Int = SrcHeight*Scalefactor
	'Log (Scalefactor & " " & DestWidth & " " & SrcWidth & " " & DestHeight)
	If Angle = 0 Or Angle = 180 Then
		If GoUp Then DestY=DestY-DestHeight
		If Color = Colors.Transparent Then
			BG.DrawBitmap(SRC, SetRect(SrcX,SrcY, SrcWidth,SrcHeight), SetRect(DestX,DestY,DestWidth,DestHeight))
		Else
			DrawRect(BG,DestX,DestY,DestWidth,DestHeight, Color, 0)
		End If
	Else
		X2 = Abs(Trig.findXYAngle(0,0, DestHeight, Angle, True)) * 0.5 'Width offset of 1 edge
		Y2 = Abs(Trig.findXYAngle(0,0, DestHeight, Angle, False))'Height
		If Color <> Colors.Transparent Then
			P.Initialize(DestX,DestY)
			If GoUp Then'   \-/
				P.LineTo(DestX - X2, DestY-Y2)
				P.LineTo(DestX +DestWidth + X2, DestY-Y2)
			Else'           /-\
				P.LineTo(DestX - X2, DestY + Y2)
				P.LineTo(DestX +DestWidth + X2, DestY+Y2)
			End If
			P.LineTo(DestX + DestWidth, DestY)
			BG.DrawPath(P, Color,True,0)
			BG.RemoveClip 
		Else If GoUp Then '                                                                                              X          Y                       top width         bottom width      height
			LCARSeffects2.DrawTrapezoid(BG, SRC,  SetRect(SrcX,SrcY, SrcWidth, SrcHeight),      DestX-X2,  DestY+DestHeight - Y2,  DestWidth + X2*2, DestWidth,        Y2, 255)'(UP)
		Else
			LCARSeffects2.DrawTrapezoid(BG, SRC,  SetRect(SrcX,SrcY, SrcWidth, SrcHeight),      DestX-X2,  DestY,                  DestWidth,        DestWidth + X2*2, Y2, 255)'(DOWN)
		End If
	End If
End Sub

Sub CheckFontSize(BG As Canvas, Width As Int, Height As Int)
	If EH_OldHeight <> Height Then
		EH_TextSize2 = API.GetTextHeight(BG, Width * -0.33  ,"emergency evacuation procedure", Typeface.DEFAULT_BOLD)
		EH_TextSize = API.GetTextLimitedHeight(BG, Height * 0.43, Width * 0.93, "00:00:00", Typeface.DEFAULT_BOLD)
		EH_ItemHeight = BG.MeasureStringHeight("emer", Typeface.DEFAULT_BOLD, EH_TextSize2)*3
		EH_OldHeight = Height
	End If
End Sub
Sub Draw_EventHorizon(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SecondsRemaining As Int)
	Dim temp As Int, temp2 As Int, Grid As Point , X2 As Int=665, Y2 As Int=406,TextWidth As Int, Width2 As Int, Height2 As Int  ,Scalefactor As Float, tempstr As String 
	Dim Thumbsize As Point
	Width=Width+1'HttpUtils.Download("MSD",
	Height=Height+1
	If Width< Height Then
		LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False, 255, "PLEASE ROTATE THE SCREEN")
		Return
		temp = ResizeElement(Width,Height)
		Y= Y + (Height*0.5) - (temp*0.5)
		Height=temp
	End If
	
	If EH_Better Then
		Thumbsize = API.Thumbsize(X2,Y2, Width,Height, True, False)
		
		X2=X+Width*0.5- Thumbsize.X*0.5
		Y2=Y+Height*0.5-Thumbsize.Y*0.5
		
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, GetSrcRect(3), SetRect(X2, Y2,Thumbsize.X,Thumbsize.Y))
		
		If EH_Stage = -2 Then Return
		
		X= X2 + (Thumbsize.X * 0.05413533834586466165413533834586)'36
		Y= Y2 + (Thumbsize.Y * 0.0197044334975369458128078817734)'8
		Width = Thumbsize.X * 0.89774436090225563909774436090226'597
		Height = Thumbsize.Y * 0.63546798029556650246305418719212'258
		
	End If'36,8 597,258  out of  665, 406
	
	'stage -2
	'closed, waiting to be clicked

	'stage -1
	'opening bomb cover

	'emergency evacuation procedure
	'foredecks		main corridor		engineering
	
	'stage 0
	'starts at 1:22:14
	'status : arming
	'ship drawn in full
	'bomb bars 1-8 drawn in incrementally 
	
	'stage 1
	'status : detonation initiated 
	'then bomb bars are drawn out with alpha blending, destroying the main corridor
	
	'stage 2
	'status : evacuation complete
	'foredecks changes to lifeboat
	'lifeboat floats left
	
	'stage 3 at 1:24:03, 
	'bomb screen, shows status of 8 bombs (#4 is missing)
	
	'stage 4 at 1:11:34
	'timer
	If EH_Stage < 3 Then
		If EH_Stage = 0 And EH_SubStage = 2 Then LCAR.PlaySoundFile("", "eh1.ogg", False)
		DrawRect( BG, X,Y,Width,Height, Colors.RGB(106,30,0), 0)'background color
		CheckFontSize(BG, Width, Height)
'		If EH_OldHeight <> Width Then
'			EH_TextSize = API.GetTextHeight(BG, Width * -0.5  ,"emergency evacuation procedure", Typeface.DEFAULT_BOLD)
'			EH_OldHeight = Width
'		End If
			
		temp = 20
		X=X+temp 
		Y=Y+temp 
		Width=Width -temp *2
		Height = Height - temp * 2
			
		Grid = DrawGrid( BG, X, Y, Width, Height, 32, 16, Colors.RGB(212, 175, 193), 2)'grid
		DrawRect( BG, X, Y, Width, Height, Colors.RGB(212, 175, 193), 4)'outer border
		
		'x/y 0,91     width/height 311 by 318 of 1212 by 499
		
		X = Grid.X 
		Width = Grid.Y 

		Height2 = Height * 0.64
		LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
		
		TextWidth= BG.MeasureStringWidth("emergency evacuation procedure", Typeface.DEFAULT_BOLD, EH_TextSize2) + 20
		DrawSquare(BG, X, Y+8, TextWidth, EH_ItemHeight, Colors.RGB(93, 25,4), 3,  Colors.RGB(206,169,160), "emergency evacuation procedure", Colors.RGB(199, 186,195), True, False)

		Scalefactor =  Min( (Height-32) / 458, (Width-64)/882)
		X2 = X + Width * 0.58'align ship to this X coordinate
		Y2 = Y + Height * 0.5
		
		'ovals
		temp = X2 - (444*Scalefactor) 
		temp2 =  Colors.RGB(212, 175, 193)
		DrawOvals( BG, temp, Y2, Width*0.5, Height * 0.66,temp2, 2, 6)
		DrawOvals( BG, X2 + 84*Scalefactor, Y2, Width*0.28, Height*0.97, temp2, 2, 6)
		DrawOvals( BG, X2 + 292*Scalefactor, Y2, Width*0.24, Height*0.80, temp2, 2, 6)
		'oval rects
		DrawOvalRect(BG, X, Y2, Width*0.87, Height*0.32, temp2, -2)
		DrawOvalRect(BG, X + Width*0.07, Y2, Width*0.73, Height*0.29, temp2, -2)
		DrawOvalRect(BG, X + Width*0.13, Y2, Width*0.60, Height*0.23, temp2, -2)
		
		LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
		'partial squares
		temp = Colors.RGB(190,159,131)
		temp2 =  Colors.RGB(119,81,70) 'color of text squares
		Y2 = Y + 0.18 * Height
		TextWidth= API.GetBiggestTextDimension(True, BG, Typeface.DEFAULT_BOLD, EH_TextSize2, Array As String("foredecks", "main corridor", "engineering", "lifeboat")) + 20
		If EH_Stage <2 Then
			DrawPartialSquare(BG, X, Y2, Width*  0.25, Height2, temp, 3, 1, 0.23, "foredecks", TextWidth, 1, temp2, "")
		Else
			DrawPartialSquare(BG, X, Y2, Width*  0.25, Height2, temp, 3, 1, 0.23, "lifeboat", TextWidth, 1, Colors.rgb(117, 105, 40), "")
		End If
		DrawPartialSquare(BG, X + Width * 0.28, Y2, Width*  0.32, Height2, temp, 3, 0.23, 0.23, "main corridor", TextWidth, 1.5, temp2, "")'339 
		DrawPartialSquare(BG, X + Width * 0.72, Y2, Width*  0.28, Height2, temp, 3, 0, 1, "engineering", TextWidth, 2, temp2, "") 
		
		'starship
		Y2 = Y + Height * 0.5
		If DrawPartOfShip(BG, X2 - (360*Scalefactor), Y2, 2, Scalefactor) Then LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)'corridor 
		DrawPartOfShip(BG, X2, Y2, 0, Scalefactor)'engineering
		DrawPartOfShip(BG, X2 - (533*Scalefactor), Y2, 1, Scalefactor)'foredecks
		BG.RemoveClip 
		
		'final text
		Y2 = Y + 0.18 * Height
		tempstr = "status : " & API.IIFindex(EH_Stage+1,Array As String("arming", "arming", "detonation initiated", "evacuation complete"))
		TextWidth = BG.MeasureStringHeight("aditpg", Typeface.DEFAULT_BOLD, EH_TextSize2)
		BG.DrawText(tempstr, X + Width * 0.28 + 32, Y2 + 4 + TextWidth, Typeface.DEFAULT_BOLD, EH_TextSize2 , Colors.White, "LEFT")
		
		If EH_Stage = -1 Then 
			temp = EH_SubStage * 0.5 '0 to 128 angle
			If temp < 90 Then DrawTrapezoid(BG, LCARSeffects2.CenterPlatform, 418,8,597,258,     temp,   X-20,Y-20,Width+40, False, Colors.Transparent )
		End If
	Else
		DrawRect( BG, X,Y,Width,Height, API.IIF(EH_Stage=3, Colors.RGB(148,135,141) , Colors.Black), 0)'background color
	
		If EH_Stage = 3 Then 'bomb status
			LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			Width2 = Width * 0.62
			Scalefactor = Width2 / 382
			temp2 = API.IIF( Floor(EH_SubStage / 8) Mod 2 = 0, Colors.RGB(160,160,160), Colors.RGB(187,73,64))
			If EH_SubStage Mod 80 = 0 Then LCAR.PlaySoundFile("", "eh3.ogg", False)
			
			Height2=44*Scalefactor
			DrawBombs(BG, X+Width*0.5-Width2*0.5, Y+Height-(LCAR.ItemHeight*3)-Height2, Width2,Height2, 3,  Colors.rgb(31,46,72)  ,  temp2, Scalefactor)
			
			Width2= Width * 0.43
			Height2 = LCAR.ItemHeight*3
			DrawUnitStatus(BG, X+ 20, Y+20, Width2,Height2, temp2, 1)
			DrawUnitStatus(BG, X+ Width- Width2-20, Y+20, Width2,Height2, Colors.Black, 0)
			EH_LastSecond = SecondsRemaining
			BG.RemoveClip 
		Else'timer
'			If EH_OldHeight <> Height Then
'				EH_TextSize = API.GetTextLimitedHeight(BG, Height * 0.43, Width * 0.93, "00:00:00", Typeface.DEFAULT_BOLD)
'				EH_OldHeight = Height
'			End If
			CheckFontSize(BG, Width, Height)
			temp = Floor(SecondsRemaining / 60) 'minutes
			temp2 = SecondsRemaining Mod 60'seconds
			API.DrawTextAligned(BG, "00:" & API.PadtoLength(temp, True, 2, "0") & ":" & API.PadtoLength(temp2, True, 2, "0"),   X+Width*0.5, (Y+Height-LCAR.ItemHeight*2) * 0.5, 0,  Typeface.DEFAULT_BOLD , EH_TextSize, Colors.White, 5, 0, 0)
			API.DrawTextAligned(BG,"seconds remaining :", X+10, Y+10, 0, Typeface.DEFAULT_BOLD, LCAR.Fontsize, Colors.White, 7, 0, 0)
			If EH_LastSecond <> SecondsRemaining Then
				LCAR.PlaySoundFile("", "eh4.ogg", False)
				EH_LastSecond = SecondsRemaining
			End If
		End If
		
		Height2 = LCAR.ItemHeight*2' Height * 0.25
		DrawMenu(BG, X, Y+Height-Height2, Width,Height2, 4)
	End If
End Sub
Sub DrawUnitStatus(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Index As Int)
	Dim temp As Int 
	DrawRect(BG,X,Y,Width,Height,Color,0)
	If Index = 0 Then
		temp = BG.MeasureStringHeight("ready for manual detonation", Typeface.DEFAULT_BOLD , LCAR.Fontsize)
		BG.Drawtext("ready for", X + temp*0.5, Y + Height * 0.5 - temp, Typeface.DEFAULT_BOLD , LCAR.Fontsize, Colors.White, "LEFT")
		BG.Drawtext("manual detonation", X + temp*0.5, Y + Height - temp, Typeface.DEFAULT_BOLD , LCAR.Fontsize, Colors.White, "LEFT")
	Else
		temp = Height - 10
		DrawRect(BG,X + Width - Height + 5, Y+ 5, temp,temp, Colors.Black, 0)
		API.drawtextaligned(BG, Index, X+Width-Height + temp*0.5, Y+5+ temp*0.5, 0, Typeface.DEFAULT, LCAR.Fontsize*2, Color, 5, 0, 0)
		
		temp = BG.MeasureStringHeight("explosive unit", Typeface.DEFAULT_BOLD , LCAR.Fontsize*0.75)
		BG.Drawtext("explosive unit", X + temp*0.5, Y + Height * 0.5 - temp, Typeface.DEFAULT_BOLD , LCAR.Fontsize*0.75, Colors.White, "LEFT")'
		
		temp = BG.MeasureStringHeight("armed", Typeface.DEFAULT_BOLD , LCAR.Fontsize*1.5)'
		BG.Drawtext("armed", X + temp*0.25, Y + Height - temp, Typeface.DEFAULT_BOLD , LCAR.Fontsize*1.5, Colors.White, "LEFT")
	End If
End Sub
Sub DrawBombs(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, Color As Int, Color2 As Int, Scalefactor As Float)
	Dim temp As Int , Width2 As Int = Width/8, Textsize As Int = BG.MeasureStringHeight("12345678", Typeface.DEFAULT_BOLD, LCAR.Fontsize),Y2 As Int = Y
	Width=Floor(Width/8) * 8
	
	temp=Y+Height*0.5
	DrawPartOfShip(BG, X-(177*Scalefactor), temp, 1,Scalefactor)'foredecks/lifeboat
	DrawPartOfShip(BG, X+Width - (22*Scalefactor), temp, 0, Scalefactor)'engineering
	
	DrawRect(BG, X,Y, Width, Height, Colors.white, 0)
	DrawRect(BG, X,Y, Width, Height, Color, Stroke)
	DrawRect(BG,X,Y,Width2,Height, Color2, 0)
	DrawRect(BG,X,Y,Width2,Height, Color, Stroke*3)
	Y=Y+Height*0.5+Textsize*0.5
	Textsize=Width2*0.5
	X=X+Textsize
	For temp = 1 To 8
		If temp = 4 Then 'X
			BG.DrawLine(X-Textsize, Y2, X+Textsize, Y2+Height, Color, Stroke-1)
			BG.DrawLine(X+Textsize, Y2, X-Textsize, Y2+Height, Color, Stroke-1)
		Else
			BG.DrawText(temp, X, Y, Typeface.DEFAULT_BOLD, EH_TextSize2, Colors.Black, "CENTER")
		End If
		BG.DrawLine(X+Textsize, Y2, X+Textsize,Y2+Height, Colors.Black, Stroke)
		X=X+Width2
	Next
End Sub

Sub DrawMenu(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int)
	Dim Width2 = Width / 3, X2 As Int = Width2 * 0.12, Y2 As Int = Height * 0.13, temp As Int,temp2 As Int , tempstr() As String , Width3 As Int = Width2 * 0.40, WhiteSpace As Int = Width2 * 0.02
	DrawRect(BG,X,Y,Width,Height, Colors.White, 0)  '132,161,198
	BG.DrawLine(X + Width2, Y, X+ Width2, Y+Height-20, Colors.Black, Stroke)
	BG.DrawLine(X + Width- Width2, Y, X+ Width- Width2, Y+Height-20, Colors.Black, Stroke)
	For temp = 0 To 2
		Select Case temp
			Case 0: tempstr = Array As String("unit specify", "select", "time")
			Case 1: tempstr = Array As String("detonator", "arm", "disarm")
			Case 2: tempstr = Array As String("remote device", "disable", "release")
		End Select
		temp2  = BG.MeasureStringHeight(tempstr(2), Typeface.DEFAULT_BOLD,LCAR.Fontsize)
		BG.DrawText(tempstr(0), X + X2, Y + Y2 + temp2, Typeface.DEFAULT_BOLD,LCAR.Fontsize, Colors.black, "LEFT")
		'API.DrawText(BG, tempstr(0), X + X2, Y + Y2, Typeface.DEFAULT_BOLD, LCAR.Fontsize, Colors.Black, 1)
		DrawSquare(BG, X + Width2/2 - WhiteSpace - Width3, Y + LCAR.ItemHeight, Width3,LCAR.ItemHeight, Colors.Black, 0, 0, tempstr(1), Colors.White, False,False)
		DrawSquare(BG, X + Width2/2 + WhiteSpace, Y + LCAR.ItemHeight, Width3,LCAR.ItemHeight, Colors.Black, 0, 0, tempstr(2), Colors.White, False,False)
		X = X + Width2
	Next
End Sub

'PartOfShip: 0=engineering, 1=foredecks, 2=corridor
Sub DrawPartOfShip(BG As Canvas,X As Int, CenterY As Int, PartOfShip As Int, ScaleFactor As Float)  As Boolean 
	Dim Src As Rect = GetSrcRect(PartOfShip), Width As Int = (Src.Right-Src.Left) * ScaleFactor, height As Int = (Src.Bottom - Src.Top) * ScaleFactor, temp As Int, LastAlpha As Int = 255
	If EH_Stage = 2 And PartOfShip = 1 Then'drift lifepod left
		X = X- EH_SubStage
	Else If EH_Stage = 1 And PartOfShip = 2 Then'clip corridor
		temp = Width * ( (EH_MaxStage- EH_SubStage) / EH_MaxStage )
		LCARSeffects.MakeClipPath(BG, X, 0, temp, LCAR.ScaleHeight)
	End If
	If Not(EH_Stage = 2 And PartOfShip = 2) Then
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, Src, SetRect(X, CenterY-height, Width, height))
		BG.DrawBitmapFlipped(LCARSeffects2.CenterPlatform, Src, SetRect(X, CenterY, Width, height), True,False)
	End If
	If EH_Stage>-1 And EH_Stage < 2 And PartOfShip = 2 Then'draw bombs
		If EH_Stage= 0 Then
			temp = Floor(EH_SubStage/ 24) '15 whitespace then 23 by 124 with 23 whitespace
			If EH_SubStage Mod 24 = 0 And Not(LCAR.IsPlaying) And temp <9 Then LCAR.PlaySoundFile("", "eh2.ogg", False)
		Else
			temp = Ceil( (EH_MaxStage- EH_SubStage) / 32)
			LastAlpha = ((EH_MaxStage- EH_SubStage) Mod 32) * 8
			If EH_SubStage Mod 32 = 0  And Not(LCAR.IsPlaying) Then LCAR.PlaySoundFile("", "eh3.ogg", False)
		End If
		X=X + 15 * ScaleFactor 
		If EH_Stage = 1 Then BG.RemoveClip 
		For height = 1 To Min(8,temp )
			X = DrawBomb(BG,X, CenterY, ScaleFactor, API.IIF(height=temp,LastAlpha, 255), height)
		Next
		If EH_Stage = 1 Then Return True
	End If
End Sub

Sub DrawBomb(BG As Canvas,X As Int, CenterY As Int, ScaleFactor As Float, Opacity As Int, Index As Int) As Int 
	Dim Percent As Float, Height As Int ,Width As Int 
	If Opacity = 255 Then
		DrawSquare(BG, X, CenterY - (62*ScaleFactor), 23 * ScaleFactor, 124 * ScaleFactor,  Colors.RGB(154,34,20), 2, Colors.White,  Index, Colors.White, True, True)
	Else
		Percent = 1 + ((255-Opacity) * 0.005)
		Width = 23*ScaleFactor*Percent
		X= X + (12*ScaleFactor) - Width*0.5
		Height = 124 * ScaleFactor*Percent
		DrawRect(BG, X, CenterY- Height*0.5,  Width, Height, Colors.ARGB(Opacity, 154,34,20), 0)
	End If
	Return X + (46 * ScaleFactor)
End Sub

'PartOfShip: 0=engineering, 1=foredecks, 2=corridor, 3=bomb cover
Sub GetSrcRect(PartOfShip As Int) As Rect 
	Select Case PartOfShip
		Case 0: Return SetRect(0,0,356,229)'engineering
		Case 1: Return SetRect(0,229,179,52)'foredecks
		Case 2: Return SetRect(0,281,382,22)'corridor
		Case 3: Return SetRect(382,0,665,406)'bomb cover
		Case 4: Return SetRect(418,8,597,258)'just the lid   382+36	8		597,258		
	End Select
End Sub

'if stroke is lower than 0 then Y is treated as the center, not the top
Sub DrawOvalRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	Dim Width2 As Int = Height * 0.16 'width is 1050, height is 164, width of oval is 27, percent of oval width to height is 16
	If Stroke<0 Then
		Stroke = Abs(Stroke)
		Y = Y-Height*0.5
	End If
	BG.DrawLine(X,Y,X+Width,Y, Color,Stroke)
	BG.DrawLine(X,Y+Height,X+Width,Y+Height, Color,Stroke)
	LCARSeffects.MakeClipPath(BG,X,Y-Stroke, Width,Height+Stroke*2)
	BG.DrawOval(SetRect(X-Width2*0.5, Y, Width2,Height), Color, False, Stroke)
	BG.DrawOval(SetRect(X+Width-Width2*0.5, Y, Width2,Height), Color, False, Stroke)
	BG.RemoveClip 
End Sub

Sub DrawOvals(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, Ovals As Int)
	Dim Reduce As Float = 0.82
	Do Until Ovals = 0
		BG.DrawOval(SetRect( X - Width*0.5, Y - Height*0.5, Width, Height), Color, False, Stroke)
		Width=Width * Reduce
		Height = Height * Reduce
		Ovals = Ovals -1
	Loop
End Sub
Sub DrawGrid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CellWidth As Int, CellHeight As Int, Color As Int, Stroke As Int) As Point 
	Dim temp As Int = Floor(Width / CellWidth) * CellWidth, temp2 As Int, DoDots As Boolean = Stroke < 0, Radius As Int 
	Stroke = Abs(Stroke)
	X = X + Width/2 - temp/2
	Width = temp 
	For temp = X To X + Width Step CellWidth
		BG.DrawLine(temp,Y, temp, Y+Height, Color,Stroke)
	Next
	
	temp = Floor(Height/CellHeight) * CellHeight
	Y = Y + Height/2 - temp/2
	Height = temp 
	For temp = Y + CellHeight To Y + Height - CellHeight Step CellHeight 
		BG.DrawLine(X, temp, X + Width, temp, Color, Stroke)
	Next
	
	If DoDots Then 
		Radius = CellWidth * 0.18
		Color = LCAR.GetColor(LCAR.Classic_Green, False, 255) 
		For temp = Y + CellHeight To Y + Height - CellHeight Step CellHeight
			For temp2 = X To X + Width Step CellWidth
				BG.DrawCircle(temp2+Radius+1, temp+Radius+1, Radius, Color, True, 0)
			Next
		Next
	End If
	
	Return Trig.SetPoint(X, Width)
End Sub
Sub DrawPartialSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, LeftSide As Float, RightSide As Float, Text As String, TextWidth As Int, Units As Float, TextSquareColor As Int, Text2 As String)
	BG.DrawLine(X,Y, X+Width, Y, Color, Stroke)
	BG.DrawLine(X,Y+Height, X+Width, Y+Height, Color, Stroke)
	DrawPartialLine(BG, X, Y, Height, Color, Stroke, LeftSide)
	DrawPartialLine(BG, X+Width, Y, Height, Color, Stroke, RightSide)
	If Text2.Length>0 Then		API.DrawTextAligned(BG, Text2, X+ 32, Y+ 4, 0, Typeface.DEFAULT_BOLD, EH_TextSize2, Colors.White, 7, 0, 0)
	DrawSquare(BG, X + Width - (Units*32) - TextWidth, Y + Height - 16 - LCAR.ItemHeight , TextWidth, EH_ItemHeight, TextSquareColor, 3, Colors.RGB(203, 174, 166), Text, Colors.RGB(208, 195, 213), True, False)
End Sub
Sub DrawSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, StrokeColor As Int, Text As String, TextColor As Int, Center As Boolean, Bottom As Boolean)
	'Dim EH_TextHeight As Int = bg.MeasureStringHeight("fkitdlgyp", Typeface.DEFAULT_BOLD,  LCAR.Fontsize)', TextHeight2 As Int = bg.MeasureStringHeight(text, Typeface.DEFAULT_BOLD,  LCAR.Fontsize)
	If EH_TextHeight = 0 Then EH_TextHeight =  BG.MeasureStringHeight("fkitdlgyp", Typeface.DEFAULT_BOLD,  EH_TextSize2)
	DrawRect(BG,X,Y,Width,Height,Color,0)
	If Stroke>0 Then DrawRect(BG,X,Y,Width,Height,StrokeColor, Stroke)
	
	If Bottom Then 
		Y = Y+Height - 3
	Else
		Y=Y+Height/2+EH_TextHeight/2
	End If
	
	'If TextHeight2<TextHeight Then Y =Y  - (TextHeight-TextHeight2)
	If Center Then 
		BG.DrawText(Text, X+Width/2, Y, Typeface.DEFAULT_BOLD,  EH_TextSize2, TextColor, "CENTER")
	Else
		BG.DrawText(Text, X+20, 	Y, Typeface.DEFAULT_BOLD,  LCAR.Fontsize, TextColor, "LEFT")
	End If
End Sub
Sub DrawPartialLine(BG As Canvas, X As Int, Y As Int, Height As Int, Color As Int, Stroke As Int, Percent As Float)
	Dim temp As Int = Height*Percent
	If Percent = 100 Then
		BG.DrawLine(X,Y,X,Y+Height, Color, Stroke)
	Else If Percent > 0 Then
		BG.DrawLine(X,Y,X,Y+temp, Color, Stroke)
		BG.DrawLine(X,Y+Height,X,Y+Height-temp, Color, Stroke)
	End If
End Sub
Sub DrawButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, Alpha As Int)
	Dim S As Int = 2, S2 As Int = S*2, R As Float = 0.25
	If EH_TextHeight = 0 Then EH_TextHeight =  BG.MeasureStringHeight("fkitdlgyp", Typeface.DEFAULT_BOLD,  LCAR.Fontsize)
	LCARSeffects2.DrawRoundRect(BG, X,Y,Width,Height, Colors.White, Height * R ) '
	LCARSeffects2.DrawRoundRect(BG, X+S,Y+S,Width-S2,Height-S2, Colors.black, (Height-S2) * R)
	S=3
	S2=6
	LCARSeffects2.DrawRoundRect(BG, X+S,Y+S,Width-S2,Height-S2, Colors.ARGB(Alpha, 22, 69,107), (Height-S2) * R)
	
	BG.DrawText(Text, X + Height*0.4, Y + Height*0.4 + EH_TextHeight *0.5, Typeface.DEFAULT_BOLD, LCAR.Fontsize, Colors.white, "LEFT")
	
	'API.DrawTextAligned(BG, Text, X + Height*0.3, Y, Height, Typeface.DEFAULT_BOLD, LCAR.Fontsize, Colors.white, -4 )
End Sub