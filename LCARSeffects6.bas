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

	'DNA stuff
	Public DNAstyles As Int = 4, DNAbits1 As List, DNAbits2 As List, RNDs(4) As List, RNDsBrackets(4) As List, MSBits As List, MSLastUpdate As Int, MSBovals(4) As TweenAlpha
	Type RNDCLaw(X As Float, Width As Float, Height As Float, ColorID As Int)
	Type MSBit(Color As Boolean, Value As String)
	
	'UFP LOGO Stuff
	Type UFPstar(Angle As Int, Distance As Int, Radius As Int, OffsetDistance As Int)
	Dim UFPStars As List, BigStars(3) As UFPstar
	
	'Plasma constriction stuff
	Type PlasmaCell(Height As Int, Width As TweenAlpha)
	Type PlasmaLayer(Start As Int, Cells As List)
	Dim Plasma As List 
	
	Type BORG_Circle(X As Float, Y As Float, Radius As Float, Value As Int, Value1 As Int, Value2 As Int, Value3 As Int, Value4 As Int, Value5 As Int, cType As Int)
	Dim BorgCircles As List 
End Sub

'Text: '#'s will be replaced with a number. '@' will allow for random lengths of the string to be returned
public Sub RandomNumber(Text As String) As String 
	Dim tempstr As StringBuilder, temp As Int, tempstr2 As String, RandomLength As Boolean = Text.Contains("@") 
	tempstr.Initialize
	For temp = 0 To Text.Length - 1
		tempstr2 = API.mid(Text, temp, 1)
		If tempstr2 = "#" Then tempstr2 = Rnd(0,10)
		If Not(tempstr2 = "@") Then tempstr.Append(tempstr2)
	Next
	If RandomLength Then Return API.Left(tempstr.ToString, Rnd(1, tempstr.Length))
	Return tempstr.ToString
End Sub

public Sub MakeBits(DNAbits As List, Number As Int, OnlyIfNotInit As Boolean) As Boolean 
	If API.ListSize(DNAbits) > 0 Then 
		If OnlyIfNotInit Then Return False 
	Else if Not(DNAbits.IsInitialized) Then
		DNAbits.Initialize
	End If
	If OnlyIfNotInit Then Number = Number + 1
	Do Until Number = 0 
		DNAbits.Add( Trig.SetPoint(Rnd(1, 100), LCAR.LCAR_RandomColor) )'1 through 99, 1 through 12
		Number = Number - 1
		If Not(OnlyIfNotInit) Then DNAbits.RemoveAt(0)
	Loop
End Sub
public Sub RandomDNA(temp As Int) As Int 
	If temp = -1 Then temp = API.dRnd(0, DNAstyles, LCAR.LCAR_DNA)
	Dim WhiteSpace As Int = 10, MovingSteps As Int = DNAdim(temp, 0), WaitingSteps As Int = DNAdim(temp, 1)
	DNAbits1.Initialize
	DNAbits2.Initialize
	Select Case temp
		Case 0'Voyager style
			LCAR.CurrentStyle = LCAR.LCAR_TNG
			CallSubDelayed3(WallpaperService, "AddRND", LCARSeffects4.SetRect(MovingSteps+WhiteSpace, 0, -1, WaitingSteps), "DNA ANALYSIS 0747")
			CallSubDelayed3(WallpaperService, "AddRND", LCARSeffects4.SetRect(MovingSteps+WhiteSpace, -WaitingSteps, -1, WaitingSteps), "")
		Case 1'Classic TNG
			LCAR.CurrentStyle = LCAR.LCAR_ClassicTNG
		Case 2'ENTERPRISE
			LCAR.CurrentStyle = LCAR.LCAR_ENT
			InitRNDs(False)
	End Select
	Return temp
End Sub
public Sub IncrementDNA(Element As LCARelement) As Boolean 
	Dim MovingSteps As Int = 10, WaitingSteps As Int = 40, RandomSteps As Int = WaitingSteps * 0.25, Bits1 As Int = 1, Bits2 As Int = 1', temp As Int 
	
	If Element.Align = -1 Then 'initialize
		Element.Align = RandomDNA(-1)
	Else 
		Select Case Element.Align
			Case 0, 1, 2, 4'VOY, Early TNG, ENT, 3D
				If Element.Align = 1 Or Element.Align = 4 Then'early/late TNG
					 Bits2 = 4
					 WaitingSteps = 10
				End If
				If Element.LWidth < MovingSteps Then 
					Element.LWidth = Element.LWidth + 1
					If Element.Align = 2 Then 
						'temp = Element.TextAlign
						Element.TextAlign = (Element.TextAlign + 1)'ENT 220=(MovingSteps*bits*cycles) bits = 11, cycles = 2
						'If (Element.TextAlign > 110 And temp < 110) Or Element.TextAlign > 220 Then InitRNDs(True)
						If Element.TextAlign > 220 Then 
							Element.TextAlign = Element.TextAlign Mod 220
							InitRNDs(True)
						End If 
					End If 
				Else 
					If Element.RWidth Mod RandomSteps = 0 And Element.Align = 0 Then Element.TextAlign = -1'VOY
					Element.RWidth = Element.RWidth + 1
					If Element.RWidth = WaitingSteps Then 
						Element.LWidth = 0
						Element.RWidth = 0
						MakeBits(DNAbits1, Bits1, False)
						MakeBits(DNAbits2, Bits2, False)
						If Element.Align = 1 Or Element.Align = 4 Then Element.TextAlign = 1-Element.TextAlign'early TNG
					End If 
				End If	
			Case 3'3D
				Element.LWidth = Element.LWidth + 1
				If Element.LWidth = MovingSteps Then 
					Element.LWidth = 0
					MakeBits(DNAbits1, Bits1, False)
					MakeBits(DNAbits2, Bits1, False)
					Element.TextAlign = Element.TextAlign - 1
					If Element.TextAlign < 0 Then Element.TextAlign = 10
				End If
				Element.RWidth = (Element.RWidth + 1) Mod WaitingSteps
		End Select
	End If 
	LCARSeffects2.IncrementNumbers
	Return True 
End Sub

public Sub DNAdim(Style As Int, Index As Int) As Int 
	Select Case Style 
		Case 0
			Select Case Index
				Case 0: Return API.IIF(LCAR.SmallScreen,50,100 * LCAR.ScaleFactor)'left
				Case 1: Return API.IIF(LCAR.SmallScreen,72,145)'height	
				Case 2: Return 10 * LCAR.ScaleFactor'barheight
			End Select 
	End Select
End Sub

public Sub DrawDNA(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Element As LCARelement)
	Dim Whitespace As Int = 10, temp As Int, temp2 As Int, tempX As Int, tempY As Int, Alpha As Int = Element.Opacity.Current, temp3 As Int = LCAR.TextHeight(BG, "99")
	LCAR.ActivateAA(BG, True)
	Select Case Element.Align'Use as style
		Case 0'Voyager style
			Dim FrameWidth As Int = DNAdim(Element.Align, 0), RNDHeight As Int = DNAdim(Element.Align, 2)
			X=X+ FrameWidth	+Whitespace
			Width = Width - FrameWidth - Whitespace
			Y=Y+RNDHeight+Whitespace
			Height = Height - (RNDHeight+Whitespace)*2
			
			Dim Bits As Int = 8, BitWidth As Int = Width / Bits, BitHeight As Int = BitWidth * 1.3, BitStroke As Int = 0.0476190476190476 * BitWidth, BarHeight As Int = BitWidth * 0.3380952380952381
			Dim TopRow As Int = Y + Height * 0.5 - BitHeight - DNAdim(0,2)*3, BottomRow As Int = y + Height * 0.5 + DNAdim(0,2)*3, PTs As List, TwoStroke As Int = BitStroke*2, TextHeight As Int
			MakeBits(DNAbits1, Bits, True)
			MakeBits(DNAbits2, Bits, True)
			
			LCARSeffects.MakeClipPath(BG, X,Y,Width,Height)
			tempX = X - (BitWidth * (Element.LWidth * 0.1))
			temp2 = temp3 * 0.5
			TextHeight = API.GetTextHeight(BG, BarHeight, "0123456789", LCAR.LCARfont)
			For temp = 0 To Bits
				DrawDNAbyteS1(BG, tempX, TopRow, BitWidth,BitHeight, BitStroke, BarHeight, DNAbits1.Get(temp), Alpha, temp2, -1, TextHeight)
				DrawDNAbyteS1(BG, tempX, BottomRow, BitWidth,BitHeight, BitStroke, BarHeight, DNAbits2.Get(temp), Alpha, temp2, -1, TextHeight)
				tempX = tempX + BitWidth		
			Next
			BG.RemoveClip
			
			Y=TopRow
			Height = BottomRow + BitHeight - TopRow
			BitStroke = BitStroke * 2
			BitWidth = Height * 0.8849557522123894
			BitHeight = Height 
			BarHeight = BitWidth * 0.3380952380952381
			X = X + Width * 0.5 - BitWidth
			Width = BitWidth*2
			
			tempX = X - (BitWidth * (Element.LWidth * 0.1))
			temp2 = LCAR.TextHeight(BG, "99") * 0.5

			LCARSeffects.MakeClipPath(BG, X-BitStroke,Y-BitStroke,Width+TwoStroke,Height+BitStroke*2)
			LCARSeffects4.DrawRect(BG, X-BitStroke,Y-BitStroke,Width+TwoStroke,Height+BitStroke*2, Colors.Black, 0)
			PTs.Initialize
			TextHeight = API.GetTextHeight(BG, BarHeight, "0123456789", LCAR.LCARfont)
			For temp = 2 To 4
				tempY=-1'2 (no crosshairs),3,4 Element.TextAlign
				If Element.TextAlign > 3 Then 
					If (temp = 3 And Element.TextAlign < 8) Or (temp = 4 And Element.TextAlign > 7) Then tempY = Element.TextAlign Mod 4 '4,5,6,7 & 8,9,10,11 
				End If 
				PTs.AddAll( DrawDNAbyteS1(BG, tempX, Y, BitWidth,BitHeight, BitStroke, BarHeight, DNAbits1.Get(temp), Alpha, temp2, tempY, TextHeight) )
				tempX = tempX + BitWidth
			Next
			If Element.LWidth = 10 Then 
				If Element.TextAlign = -1 Then 
					Do Until IsPointValid(PTs, Element.TextAlign) 
						Element.TextAlign = Rnd(4, PTs.Size)	
					Loop
				End If
				DrawCrosshairs(BG, X-BitStroke,Y-BitStroke,Width+TwoStroke,Height+TwoStroke, PTs.Get(Element.TextAlign), Colors.White, 2, BitStroke*2)
			End If 
			BG.RemoveClip
		
			tempX=20
			LCARSeffects2.DrawBracket(BG,X-tempX*2,Y, tempX, Height, True, False, LCAR.LCAR_TNG)
			LCARSeffects2.DrawBracket(BG,X+Width,Y, tempX, Height, False, False, LCAR.LCAR_TNG)
			
		Case 1, 4'Early/late TNG style
			Dim OldX As Int = X, OldWidth As Int = Width, BarWidth As Int = DNAdim(0,0), FullSpace As Int = BarWidth, TopBarHeight As Int = BarWidth * 0.5, BottomBarHeight As Int = BarWidth * 0.75, ColorID As Int = LCAR.Classic_Green
			Dim TopRow As Int = TopBarHeight + Whitespace, PTs As List, Color As Int, tempstr As StringBuilder, tempstr2 As String, SecondaryColorID As Int = ColorID, SecondaryColor As Int'OldBitHeight As Int, 
			If Element.Align = 4 Then 
				ColorID = LCAR.LCAR_Orange
				SecondaryColorID = LCAR.LCAR_Blue'LCAR.Classic_Blue 
			End If
			Color = LCAR.GetColor(ColorID, False, Alpha)
			SecondaryColor = LCAR.GetColor(SecondaryColorID, False, Alpha)
			
			tempstr.Initialize
			FullSpace = FullSpace + LCAR.InnerElbowSize2(BarWidth, BottomBarHeight*0.5, True)
			X = X + FullSpace
			Width = Width - FullSpace * 2 - BarWidth
						
			Dim Bits As Int = 19, BitWidth As Int = Width / Bits, BitHeight As Int = BitWidth * 3.8, BitStroke As Int = 0.1 * BitWidth, BarHeight As Int = BitHeight * 0.1692307692307692, TwoStroke As Int = BitStroke*2
			Dim ColorTrue As Int = LCAR.GetColor(ColorID, True, Alpha), ThickTop As Boolean, BottomRow As Int, Right As Int , Middle As Int = BitWidth * 8, MiddleWidth As Int = BitWidth * 5, OldBitWidth As Int = BitWidth
			MakeBits(DNAbits1, Bits, True)
			MakeBits(DNAbits2, Bits, True)
			
			'OldBitHeight=BitHeight
			tempX = X - (BitWidth * (Element.LWidth * 0.1))
			temp2 = LCAR.TextHeight(BG, "99") * 0.5
			For temp = 0 To Bits
				ThickTop = temp>8 And temp<14
				tempstr.Append( DrawDNAbyteS2A(BG, tempX, TopRow, BitWidth,BitHeight, BitStroke, BarHeight, DNAbits1.Get(temp), Alpha, temp2, API.IIF(ThickTop, ColorTrue, Color), ThickTop, SecondaryColorID) )
				tempX = tempX + BitWidth		
			Next
			
			ThickTop = Element.TextAlign = 1 
			Bits = 4
			BitWidth = Width / Bits
			BitHeight = BitWidth * 0.7875
			BottomRow = Y + Height - BitHeight - BottomBarHeight - Whitespace 
			Right = X+ BitWidth * Bits
			tempX = X - (BitWidth * (Element.LWidth * 0.1))
			For temp = 0 To Bits
				tempstr.Append(DrawDNAbyteS2B(BG, tempX, BottomRow, BitWidth,BitHeight, BitStroke, BarHeight, DNAbits2, temp*4, Alpha, temp2, Color, ThickTop, SecondaryColorID))
				tempX = tempX + BitWidth		
				ThickTop = Not(ThickTop)
			Next
			tempstr2 = tempstr.ToString
			
			X = OldX
			Width = OldWidth 
			LCARSeffects4.DrawRect(BG, Right,TopRow-Whitespace,FullSpace, BitHeight+Whitespace*2, Colors.Black, 0)
			LCARSeffects4.DrawRect(BG, Right,BottomRow-Whitespace,FullSpace+BarWidth, BitHeight+Whitespace*2, Colors.Black, 0)
			
			'TOP LEFT
			tempX = BottomBarHeight*0.5
			LCARSeffects4.DrawRect(BG, X,Y, BarWidth, TopBarHeight-Whitespace, SecondaryColor, 0)
			LCAR.DrawLCARelbow(BG,X,TopRow-Whitespace, FullSpace+Middle-Whitespace, BitHeight+ BottomBarHeight+Whitespace, BarWidth, tempX, 2, ColorID, False, API.Left(tempstr2,2) & " " & API.Mid(tempstr2, 2,4), 3, Alpha, Alpha<255)
			temp = LCAR.InnerElbowSize2(BarWidth, tempX, True)'corner width 
			temp2 = LCAR.InnerElbowSize2(BarWidth, tempX, False)'corner height
			LCARSeffects4.DrawRect(BG, X+BarWidth-1,TopRow-Whitespace, temp+1, BitHeight+ BottomBarHeight - tempX - temp2+Whitespace, Colors.black, 0)
			
			'BOTTOM LEFT
			tempY=BottomRow -TopRow -Whitespace
			LCAR.DrawLCARelbow(BG,X,tempY, FullSpace+Middle-Whitespace, TopBarHeight, BarWidth, TopBarHeight*0.4, 0, ColorID, False, "", 0, Alpha, Alpha<255)
			LCARSeffects4.DrawRect(BG, X+BarWidth,BottomRow-Whitespace, temp, BitHeight+Whitespace*2, Colors.black, 0)
			
			LCAR.DrawLCARbutton(BG, X,BottomRow-Whitespace, BarWidth+1, BitHeight+Whitespace*2+1, SecondaryColorID, False, API.Mid(tempstr2, 4, 2) & " " & API.Mid(tempstr2, 6,3), "", 0,0, False, 0, 9, -1, 255, False)
			temp = BottomRow+BitHeight+Whitespace*2
			LCAR.DrawLCARbutton(BG, X,temp, BarWidth+1, BottomBarHeight+1, ColorID, False, API.Mid(tempstr2, 9,4) & " " & API.Mid(tempstr2, 13,2), "", 0,0, False, 0, 3, -1, 255, False)
			
			'COL 2 TOP
			X = X + Middle+FullSpace
			temp2 = TopRow*0.6
			LCAR.DrawLCARelbow(BG,X,Y, MiddleWidth, TopBarHeight,   OldBitWidth*2, temp2, 0, SecondaryColorID, False, "", 0, Alpha, Alpha<255)
			temp2=TopBarHeight*0.33
			BitStroke = BitStroke * 3	
			LCARSeffects4.DrawRect(BG, X+MiddleWidth-Whitespace,Y, OldBitWidth*2+Whitespace, temp2, SecondaryColor, 0)
			
			LCARSeffects4.DrawRect(BG, X, TopRow+ BitHeight + Whitespace, OldBitWidth*2, tempX-Whitespace*2, SecondaryColor, 0)'-------
			LCARSeffects4.DrawRect(BG, X, TopRow+ BitHeight+ BottomBarHeight - tempX - BitStroke - Whitespace, MiddleWidth, BitStroke, SecondaryColor, 0)
			LCARSeffects4.DrawRect(BG, X + MiddleWidth-BitStroke*2, TopRow+ BitHeight + Whitespace, BitStroke*2, tempX-Whitespace*3, SecondaryColor, 0)
			
			LCAR.DrawLCARbutton(BG, X, TopRow+ BitHeight+ BottomBarHeight - tempX, MiddleWidth+1, tempX, ColorID, False, API.Mid(tempstr2, 2,4) & " " & API.Mid(tempstr2, 6,1), "", 0,0, False, 0, 1, -1, 255, False)
			
			'LCARSeffects4.DrawRect(BG, X, TopRow+ BitHeight+ BottomBarHeight - tempX, MiddleWidth, tempX-1, Color, 0)
			
			'COL 2'BOTTOM TOP
			LCARSeffects4.DrawRect(BG, X, tempY+Whitespace*2,OldBitWidth*2, TopBarHeight-Whitespace*2, Color, 0)
			LCARSeffects4.DrawRect(BG, X+OldBitWidth*2+Whitespace, tempY+Whitespace*2,MiddleWidth - OldBitWidth*2 - Whitespace, TopBarHeight-Whitespace*4, Color, 0)
			LCARSeffects4.DrawRect(BG, X + MiddleWidth-BitStroke, tempY+Whitespace*2, BitStroke, TopBarHeight-Whitespace*2, Color, 0)'|
		
			'2 bits
			LCARSeffects4.DrawRect(BG, X + MiddleWidth-BitStroke, temp, BitStroke, BitStroke+Whitespace*0.5, SecondaryColor, 0)'.
			LCARSeffects4.DrawRect(BG, X + MiddleWidth-BitStroke, temp+BitStroke+Whitespace, BitStroke, BitStroke+Whitespace*0.5, SecondaryColor, 0)'.
			
			'COL 2 BOTTOM BOTTOM
			LCAR.DrawLCARelbow(BG,X, Y+Height - TopBarHeight+1 , MiddleWidth, TopBarHeight, OldBitWidth*2, TopBarHeight*0.6, 2, SecondaryColorID, False, "", 0, Alpha, Alpha<255)
			LCARSeffects4.DrawRect(BG, X+MiddleWidth-Whitespace, Y+Height-temp3, OldBitWidth*2+Whitespace, temp3, SecondaryColor, 0)		
			LCAR.DrawText(BG, X+MiddleWidth+OldBitWidth*2+Whitespace, Y+Height-temp3, API.Mid(tempstr2, 1,4) & " " & API.Mid(tempstr2, 6,8), SecondaryColor,  4, True, Alpha, 0)
												
			'COL 3
			X = X + MiddleWidth + Whitespace 		
			LCARSeffects4.DrawRect(BG, X+OldBitWidth*3, Y, OldBitWidth*4, temp2, Color, 0)'top
			LCARSeffects4.DrawRect(BG, X, TopRow+ BitHeight+ BottomBarHeight - tempX, OldBitWidth*7, tempX-1, Color, 0)' top bottom
			LCARSeffects4.DrawRect(BG, X, tempY , OldBitWidth*7, temp2, Color, 0)'bottom top
			
			'COL 4
			X = X + OldBitWidth*7 + Whitespace 
			LCARSeffects4.DrawRect(BG, X, Y, BitWidth, temp2, Color, 0)'top
			LCARSeffects4.DrawRect(BG, X, TopRow+ BitHeight+ BottomBarHeight - tempX, BitWidth, tempX-1, Color, 0)' top bottom
			LCARSeffects4.DrawRect(BG, X, tempY , BitWidth, temp2, Color, 0)'bottom top
			
			BitStroke = BitStroke * 0.5
			BitWidth = OldX + Width - X
			OldBitWidth = OldBitWidth * 0.75
			DrawRNDS2(BG, X, TopRow, BitWidth, BitWidth, Alpha, 0, OldBitWidth, BitStroke, SecondaryColor, ColorID)
			DrawRNDS2(BG, X, BottomRow, BitWidth, BitHeight*0.5, Alpha, 1, OldBitWidth, BitStroke, SecondaryColor, ColorID)
			DrawRNDS2(BG, X, BottomRow+BitHeight-BitStroke, BitWidth, BitHeight*0.33, Alpha, 2, OldBitWidth, BitStroke, SecondaryColor, ColorID)
		
		Case 2'ENTERPRISE
			Dim Whitespace As Int = 100 * LCAR.ScaleFactor, Height2 As Int = Height * 0.5 - Whitespace * 0.75, HalfTextHeight As Int = BG.MeasureStringHeight("GATC", Typeface.DEFAULT, LCAR.fontsize) * 0.5
			DrawDNAent(BG, X, Y + Whitespace * 0.5, Width, Height2, Alpha, Element.LWidth, DNAbits1, 0, Element.TextAlign, Typeface.DEFAULT, HalfTextHeight, Element.Tag)
			DrawDNAent(BG, X, Y + Height * 0.5 + Whitespace * 0.5, Width, Height2, Alpha, Element.LWidth, DNAbits2, 1, Element.TextAlign, Typeface.DEFAULT, HalfTextHeight, API.StrReverse(Element.Tag))
		
		Case 3'3D
			'Dim Whitespace As Int = 10, temp As Int, temp2 As Int, tempX As Int, tempY As Int, Alpha As Int = Element.Opacity.Current, temp3 As Int = LCAR.TextHeight(BG, "99")
			LCARSeffects2.LoadUniversalBMP(File.DirAssets, "dna.png", LCAR.LCAR_DNA)
			Try 
				'LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Colors.RGB(19,28,112), 0)'draw background dark
				'DrawOval(BG,  X,Y,Width,Height, Colors.RGB(43,43,241), 0)'oval blue
				'DrawOval(BG,  X,Y,Width,Height, Colors.RGB(32,45,177), 20)'thin line
				
				LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Colors.RGB(43,43,241), 0)'draw background blue
							
				tempY = Height * 0.25
				DrawDNA3D(BG, X,Y+tempY,Width,Height*0.5, Element.LWidth, Element.RWidth, Alpha, 0, 0, Element.TextAlign, -45)
				
				PathRemCircle(BG, X,Y,Width,Height, 0,0,0,0)
				LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Colors.aRGB(128, 19,28,112), 0)'draw reverse oval blue
				BG.RemoveClip
				DrawOval(BG,  X,Y,Width,Height,  Colors.aRGB(128,32,45,177), 20)'thin line
				
				DrawMicroscope(BG, X,Y,Width,Height, Alpha)
			Catch 
				Log(LastException.Message)
			End Try 
	End Select
	LCAR.ActivateAA(BG, False)
End Sub

'microscope
public Sub MakeMSbit(TextFormat As String) As MSBit
	Dim tempBit As MSBit
	tempBit.Initialize
	tempBit.Color = Rnd(0,2) = 1
	tempBit.Value = RandomNumber(TextFormat)
	Return tempBit
End Sub
public Sub DrawMicroscope(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int)
	Dim CenterX As Int = X + Width * 0.5, CenterY As Int = Y + Height * 0.5, R2 As Int = Min(Width,Height), RadiusH As Int = R2 * 0.5', Orange As Int = LCAR.GetColor(LCAR.LCAR_Orange, False, Alpha)
	Dim RadiusW As Int = RadiusH * 0.90, TK As Int = 100, CT As Int = TK * -0.5, LT As Int = TK * 0.1, temp As Int, FontSize As Int = 10, FontHeight As Int = BG.MeasureStringHeight("0123456789", LCAR.LCARfont,FontSize)
	'MSBits as List, LastUpdate
	If API.ListSize(MSBits) = 0 Or MSLastUpdate <> DateTime.GetSecond(DateTime.Now) Then 
		MSLastUpdate = DateTime.GetSecond(DateTime.Now)
		MSBits.Initialize
		For temp = 0 To 19'14 segments (0-13), 2 extra parts of the middle ones (14,15), 4 blocks (16-19)
			MSBits.Add(MakeMSbit("##-###"))
		Next
		MSBits.Add(MakeMSbit("######"))
		MSBits.Add(MakeMSbit("######"))
	End If
	LCAR.RedAlert = False 
		
	DrawSegmentedCircle(BG, CenterX, CenterY, Colors.Black,  FontSize, FontHeight, RadiusW+CT, RadiusH+CT, LT, 335,25,MST(20)) 	'50 LINE, MST(20)
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(0, Alpha), FontSize, FontHeight, RadiusW, RadiusH, CT, 0,36,  MST(0)) 	'6			CIRCLE
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(1, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 37,55, MST(1))	'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(2, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 56,74, MST(2))	'18
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(3, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 75,90,MST(3))	'90 		MIDDLE (90)
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(3, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 90,105,MST(14))	'90 		MIDDLE (90)
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(4, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 106,124,MST(4))	'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(5, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 125,143,MST(5))	'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(6, Alpha), FontSize, FontHeight, RadiusW, RadiusH, CT, 144,180,MST(6)) 	'6			CIRCLE
	
	DrawSegmentedCircle(BG, CenterX, CenterY, Colors.Black,  FontSize, FontHeight, RadiusW+CT, RadiusH+CT, LT, 155,205,MST(21))	'50 LINE, MST(21)
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(7, Alpha), FontSize, FontHeight, RadiusW, RadiusH, CT, 181,216,MST(7))	'6			CIRCLE
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(8, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 217,235,MST(8))	'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(9, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 236,254,MST(9))	'18
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(10, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 255,270,MST(10))'90 		MIDDLE (270)
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(10, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 270,285,MST(15))'90 		MIDDLE (270)
	
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(11, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 286,304,MST(11))'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(12, Alpha), FontSize, FontHeight, RadiusW, RadiusH, TK, 305,323,MST(12))'18
	DrawSegmentedCircle(BG, CenterX, CenterY, MSC(13, Alpha), FontSize, FontHeight, RadiusW, RadiusH, CT, 324,0,MST(13))	'6			CIRCLE
		
	For temp = 0 To 3
		If Not(MSBovals(temp).IsInitialized) Then 
			MSBovals(temp).Initialize
			MSBovals(temp).Current = Rnd(0,25)
			MSBovals(temp).Desired = Rnd(0,25)
		End If
		DrawSegmentedOval(BG, CenterX, CenterY, RadiusW+CT, RadiusH+CT, temp, MSBovals(temp).Current)
		MSBovals(temp).Current = LCAR.Increment(MSBovals(temp).Current, 2, MSBovals(temp).Desired)
		If MSBovals(temp).Current = MSBovals(temp).Desired Then MSBovals(temp).Desired = Rnd(0,25)
	Next
	
	temp=4'whitespace
	CenterX = Width * 0.5 - RadiusW - TK * 0.5 - temp
	TK = TK * 1.5
	CT = TK * 0.5
	RadiusH = CenterX * 0.4'short
	RadiusW = CenterX - RadiusH - temp'long
	Dim micro_mag As String = API.GetString("micro_mag"), micro_mic As String = API.GetString("micro_mic")
	DrawSegmentedRect(BG, X, CenterY-CT, RadiusH, TK,  16, Alpha, FontSize, FontHeight, micro_mic, False)
	DrawSegmentedRect(BG, X+RadiusH+temp, CenterY-CT, RadiusW, TK,  17, Alpha, FontSize, FontHeight, micro_mag, True)
	DrawSegmentedRect(BG, X+Width-CenterX, CenterY-CT, RadiusW, TK,  18, Alpha, FontSize, FontHeight, micro_mic, False)
	DrawSegmentedRect(BG, X+Width-RadiusH, CenterY-CT, RadiusH, TK,  19, Alpha, FontSize, FontHeight, micro_mag, False)
End Sub
public Sub DrawSegmentedOval(BG As Canvas, X As Int, Y As Int, RadiusX As Int, RadiusY As Int, Index As Int, OffsetDegree As Int)
	Dim Angle As Int, tempP As Point, Width As Int = 20, Height As Int = Width * 2
	Select Case Index 
		Case 0: Angle = 359-OffsetDegree
		Case 1: Angle = OffsetDegree
		Case 2: Angle = 180-OffsetDegree
		Case 3: Angle = 180+OffsetDegree
	End Select
	tempP = Trig.findOvalXY2(X,Y, RadiusX, RadiusY, Angle)
	BG.DrawOvalRotated(LCARSeffects4.SetRect(tempP.X - Width*0.5, tempP.Y - Height*0.5,Width,Height), Colors.ARGB(128,255,255,255), True, 0, Angle)
End Sub
public Sub DrawSegmentedRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Index As Int, Alpha As Int, FontSize As Int, FontHeight As Int, Text As String, LeftAlign As Boolean)
	Dim Whitespace As Int = 2
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height, MSC(Index, Alpha), 0)
	If LeftAlign Then 
		BG.DrawText(Text, X+Whitespace,Y+Height-Whitespace, LCAR.LCARfont, FontSize, Colors.Black, "LEFT")
	Else
		BG.DrawText(Text, X+Width-Whitespace,Y+Height-Whitespace, LCAR.LCARfont, FontSize, Colors.Black, "RIGHT")
	End If
End Sub
public Sub MST(Index As Int) As String
	Dim tempBit As MSBit = MSBits.Get(Index)
	Return tempBit.Value
End Sub
public Sub MSC(Index As Int, Alpha As Int) As Int 
	Dim tempBit As MSBit = MSBits.Get(Index), ColorID As Int = API.iif(tempBit.Color, LCAR.LCAR_Orange, LCAR.LCAR_Red)
	Return LCAR.GetColor(ColorID, False, Alpha)
End Sub
public Sub DrawSegmentedCircle(BG As Canvas, X As Int, Y As Int, Color As Int, FontSize As Int, FontHeight As Int, RadiusX As Int, RadiusY As Int, Thickness As Int, StartAngle As Int, EndAngle As Int, Text As String)
	Dim P As Path, tempP As Point, Smaller As Boolean, AngleDistance As Int = 3
	P.Initialize(X,Y)
	tempP=LCARSeffects.CacheAngles(0,StartAngle)
	P.LineTo( X+ tempP.X  ,  Y+ tempP.Y )
	tempP=LCARSeffects.CacheAngles(0,EndAngle)
	P.LineTo( X+ tempP.X  ,  Y+ tempP.Y )
	P.LineTo(X,Y)
	BG.ClipPath(P)
	If Thickness < 0 Then'Circle end
		If StartAngle < 90 Or (StartAngle > 180 And StartAngle < 270) Then 
			StartAngle = EndAngle + 2
		Else 
			StartAngle = StartAngle - 2
		End If 
		tempP = Trig.findOvalXY2(X,Y, RadiusX, RadiusY, StartAngle)		
		BG.DrawCircle(tempP.X,tempP.Y, Abs(Thickness), Color,True, 0)		
		BG.RemoveClip	
	Else'Segment
		DrawOval(BG, X-RadiusX,Y-RadiusY,RadiusX*2,RadiusY*2, Color, Thickness)
		If Color = Colors.Black Then 'Lines			
			Do Until StartAngle = EndAngle
				DrawSegmentedLine(BG,X,Y, Color, RadiusX, RadiusY, Thickness, StartAngle, Smaller)
				StartAngle = (StartAngle + 5) Mod 360
				Smaller = Not(Smaller)
			Loop
			DrawSegmentedLine(BG,X,Y, Color, RadiusX, RadiusY, Thickness, StartAngle, False)
		Else 
			If StartAngle <> 270 And (StartAngle = 75 Or StartAngle > 180 Or EndAngle = 270) Then 
				If StartAngle > 180 And StartAngle < 255 Then AngleDistance = AngleDistance * 2
				StartAngle = StartAngle + AngleDistance
			Else 
				If StartAngle > 90 And StartAngle < 180 Then AngleDistance = AngleDistance * 2
				StartAngle = EndAngle - AngleDistance
			End If 
			tempP = Trig.findOvalXY2(X,Y, RadiusX, RadiusY, StartAngle)
		End If 
		BG.RemoveClip
		If Color = Colors.Black Then 
			If StartAngle = 25 Then 
				BG.DrawText(StartAngle & " " & Text, X, Y - RadiusY + FontHeight*2.5, LCAR.LCARfont, FontSize, Colors.Black, "CENTER")
			Else 
				BG.DrawText(StartAngle & " " & Text, X, Y + RadiusY - FontHeight*1.5, LCAR.LCARfont, FontSize, Colors.Black, "CENTER")
			End If 
		Else
			If StartAngle >= 90 And StartAngle <= 270 Then FontHeight = 0
			BG.DrawText(Text, tempP.X,tempP.Y + FontHeight, LCAR.LCARfont, FontSize, Colors.Black, "CENTER")		
		End If 
	End If	
End Sub
public Sub DrawSegmentedLine(BG As Canvas, X As Int, Y As Int, Color As Int, RadiusX As Int, RadiusY As Int, Stroke As Int, Angle As Int, IsSmall As Boolean)
	Dim P1 As Point, P2 As Point, Thickness As Int = Stroke * 4
	If Not(IsSmall) Then Thickness = Thickness * 1.5
	Thickness = Thickness * 0.5
	P1 = Trig.findOvalXY2(X,Y, RadiusX-Thickness, RadiusY-Thickness, Angle)
	P2 = Trig.findOvalXY2(X,Y, RadiusX+Thickness, RadiusY+Thickness, Angle)
	BG.DrawLine(P1.X,P1.Y,P2.X,P2.Y, Color, Stroke)
End Sub

'3D style
public Sub DrawDNA3D(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Lwidth As Int, Rwidth As Int, Alpha As Int,XOffset As Int, YOffset As Int, Selected As Int, Shift As Int)
	Dim Bits As Int = 10, BitWidth As Int = Width / Bits, tempX As Int = X-(BitWidth * (Lwidth * 0.1)), temp As Int, BitWidth2 As Int, Degrees As Int = 9, Angle As Int = Rwidth * Degrees
	Dim PTs1 As List, PTs2 As List, LineColor As Int = Colors.Red, CenterX As Int, CenterY As Int, Radius As Int = 30 * LCAR.ScaleFactor' = -35 'degrees
	MakeBits(DNAbits1, Bits, True)
	PTs1.Initialize
	PTs2.Initialize
	If XOffset > 0 Or YOffset > 0 Then 
		Y=Y+YOffset
		Height=Height-YOffset*2
	End If 
	
	If Shift <> 0 Then 
		CenterX = (X + XOffset) + (Width-XOffset*2) * 0.5
		CenterY = Y + Height * 0.5
	End If

	For temp = 0 To Bits
		If temp < 5 Then 
			BitWidth2 = (5 - temp) * 0.1 * BitWidth 
		Else 
			BitWidth2 = (temp - 4) * 0.1 * BitWidth
		End If
		BitWidth2=BitWidth
		CalcDNAbyte3D(tempX, Y, BitWidth2, Height, Angle, PTs1, PTs2, CenterX, CenterY, Shift)
		DrawDNAbyte3D(BG, PTs1, PTs2, temp, Angle, Colors.Red, Colors.Green, LineColor, 10, Radius, temp = Selected)
		tempX = tempX + BitWidth 
		Angle = (Angle + Degrees) Mod 360
	Next	
End Sub

public Sub DrawDNAbyte3D(BG As Canvas, PTs1 As List, PTs2 As List, Index As Int, Angle As Int, PT1Color As Int, PT2Color As Int, LineColor As Int, LineStroke As Int, Radius As Int, Selected As Boolean)
	Dim PT1 As Point, PT2 As Point, PT3 As Point, PT4 As Point, CurveDots As Int = 3
	PT1 = PTs1.Get(Index)
	PT2 = PTs2.Get(Index)
	If Index > 0 Then 
		PT3 = PTs1.Get(Index-1)
		PT4 = PTs2.Get(Index-1)
	End If 
	If Index > 0 Then DrawLineOfDots(BG, PT2.X, PT2.Y, PT4.X, PT4.Y, LineColor, CurveDots, Radius*2, True, False)
	DrawLineOfDots(BG, PT1.X, PT1.Y, PT2.X, PT2.Y, LineColor, 8, Radius, False, Selected)
	If Index > 0 Then DrawLineOfDots(BG, PT1.X, PT1.Y, PT3.X, PT3.Y, LineColor, CurveDots, Radius*2, True, False)
End Sub

public Sub DrawLineOfDots(BG As Canvas, X1 As Int, Y1 As Int, X2 As Int, Y2 As Int, Color As Int, Dots As Int, Radius As Int, Random As Boolean, Selected As Boolean)
	Dim Width As Int = X2-X1, Height As Int = Y2-Y1, IncX As Int = Width / Dots, IncY As Int = Height / Dots', temp As Int', Radius As Int = Min(Width,Height) / Dots
	X1 = X1 + IncX
	Y1 = Y1 + IncY
	If Not(Random) Then Dots = Dots - 1
	Do Until Dots < 0
		If Random Then 
			DrawDot(BG, X1,Y1, Dots Mod 2, Radius)
		Else if Selected And Dots = 2 Then 
			DrawDot(BG, X1,Y1, 5, Radius)'barcode
		Else 			
			DrawDot(BG, X1,Y1, 2, Radius)
		End If 
		X1 = X1 + IncX
		Y1 = Y1 + IncY 
		Dots = Dots - 1		
	Loop
End Sub
public Sub DrawDot(BG As Canvas, X As Int, Y As Int, DotID As Int, Radius As Int)
	Dim SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, ScaleFactor As Float
	Select Case DotID
		Case 0'RND
			SrcWidth=149
			SrcHeight=156
		Case 1'RND
			SrcX=149
			SrcWidth=180
			SrcHeight=136
		Case 2'center line
			SrcX=329
			SrcWidth=87
			SrcHeight=87
		Case 3'rnd small
			SrcX=416
			SrcWidth=60
			SrcHeight=59
		Case 4'rnd big
			SrcX=476
			SrcWidth=68
			SrcHeight=72
		Case 5'serial number
			SrcX=416
			SrcY=71
			SrcWidth=85
			SrcHeight=85
	End Select
	If SrcWidth > SrcHeight Then 
		ScaleFactor = Radius / SrcWidth
	Else 
		ScaleFactor = Radius / SrcHeight
	End If 
	DestWidth = SrcWidth * ScaleFactor
	DestHeight = SrcHeight * ScaleFactor
	DestX = X - DestWidth*0.5
	DestY = Y - DestHeight*0.5
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCARSeffects4.SetRect(DestX,DestY,DestWidth,DestHeight))
End Sub

Public Sub SimpleBracket(BG As Canvas, X As Int, Y As Int, RadiusX As Int, RadiusY As Int, Color As Int, Stroke As Int, Space As Int)
	BG.DrawLine(X-RadiusX, Y-RadiusY, X-RadiusX+Space, Y-RadiusY-Space, Color, Stroke)
	BG.DrawLine(X-RadiusX, Y-RadiusY, X-RadiusX, Y+RadiusY, Color, Stroke)
	BG.DrawLine(X-RadiusX, Y+RadiusY, X-RadiusX+Space, Y+RadiusY+Space, Color, Stroke)
	BG.DrawLine(X+RadiusX, Y-RadiusY, X+RadiusX-Space,Y-RadiusY-Space, Color, Stroke)
	BG.DrawLine(X+RadiusX, Y-RadiusY, X+RadiusX,Y+RadiusY, Color, Stroke)
	BG.DrawLine(X+RadiusX, Y+RadiusY, X+RadiusX-Space,Y+RadiusY+Space, Color, Stroke)	
End Sub

'X/Y is the center point
public Sub ShiftPoint(X As Int, Y As Int, X2 As Int, Y2 As Int, Degrees As Int) As Point
	If Degrees = 0 Then Return Trig.SetPoint(X2,Y2)
	Dim Angle As Int = Trig.GetCorrectAngle(X,Y, X2, Y2), Distance As Int = Trig.FindDistance(X,Y, X2, Y2), RET As Point
	Degrees = Trig.CorrectAngle(Angle + Degrees)
	RET = Trig.FindAnglePoint(X, Y, Distance, Degrees)'looking at 3.1 and 3.2 
	Return RET
End Sub

public Sub CalcDNAbyte3D(X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, PTs1 As List, PTs2 As List, CenterX As Int, CenterY As Int, Shift As Int) 
	Dim HalfWidth As Int = Width * 0.5, HalfHeight As Int = Height * 0.5, PT As Point = Trig.findOvalXY2(0,0, HalfWidth, HalfHeight, Angle), MiddleX As Int = X+HalfWidth, MiddleY As Int = Y+HalfHeight 
	PTs1.Add(ShiftPoint(CenterX, CenterY, MiddleX + PT.X, MiddleY + PT.Y, Shift))
	PTs2.Add(ShiftPoint(CenterX, CenterY, MiddleX - PT.X, MiddleY - PT.Y, Shift))
End Sub











'Early TNG style (1)
public Sub DrawRNDS2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Index As Int, OverFlow As Int, Stroke As Int, Color As Int, RNDColorID As Int)
	LCARSeffects4.DrawRect(BG, X-OverFlow, Y+Stroke, OverFlow, Stroke, Color,0) 
	Stroke=Stroke*2
	LCARSeffects4.DrawRect(BG, X, Y, Width, Stroke, Color,0) 
	Height = Height-Stroke
	Y=Y+Stroke
	LCARSeffects.MakeClipPath(BG,X, Y, Width, Height)'lwidth is index
	LCARSeffects2.DrawNumberBlock(BG,x,y,Width,Height, RNDColorID,  Index, LCAR.LCAR_RndNumbers, "")
	BG.RemoveClip 
End Sub

public Sub DrawDNAbyteS2B(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, BarHeight As Int, DNAbits As List, StartIndex As Int, Alpha As Int, TextHeight As Int, Color As Int, ThickTop As Boolean, ColorID As Int) As String 
	Dim P As Path, HalfHeight As Int = Height * 0.5, HalfBarHeight As Int = BarHeight * 0.5, ThickStroke As Int = Stroke * 3, ThickerStroke As Int = ThickStroke * 2
	Dim temp As Int, Value As Point, FifthWidth As Int = Width * 0.2, Ones As Int, Tens As Int, tempstr As StringBuilder
	'LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	'DrawOval(BG, X,Y,Width, Height, Colors.Black, Stroke*2)
	'BG.RemoveClip
	tempstr.Initialize
	DrawOval(BG, X,Y,Width, Height, Color, Stroke)
	If ThickTop Then 
		P.Initialize(X, Y + HalfHeight + HalfBarHeight+ThickStroke- Stroke)'LEFT
		P.LineTo(X+ThickStroke*0.5+Stroke, Y + HalfHeight + HalfBarHeight - ThickerStroke - Stroke )'ANGLE
		P.LineTo(X+Width - ThickStroke*0.5 - Stroke, Y + HalfHeight + HalfBarHeight - ThickerStroke - Stroke )
		P.LineTo(X+Width, Y + HalfHeight + HalfBarHeight)'RIGHT
		P.LineTo(X+Width+ThickerStroke, Y-Height)'TOP
		P.LineTo(X-ThickerStroke, Y-Height)
	Else 
		P.Initialize(X, Y + Height - HalfHeight - HalfBarHeight - ThickStroke + Stroke)'LEFT
		P.LineTo(X+ThickStroke*0.5+Stroke, Y + Height - HalfHeight - HalfBarHeight + ThickerStroke + Stroke )'ANGLE
		P.LineTo(X+Width - ThickStroke*0.5 - Stroke, Y + Height - HalfHeight - HalfBarHeight + ThickerStroke + Stroke )
		P.LineTo(X+Width, Y + Height - HalfHeight - HalfBarHeight)'RIGHT
		P.LineTo(X+Width+ThickerStroke, Y+Height*2)'TOP
		P.LineTo(X-ThickerStroke, Y+Height*2)
	End If
	BG.ClipPath(P)
	DrawOval(BG, X,Y,Width, Height, Color, ThickStroke)
	BG.RemoveClip
	ClipOval(BG,X,Y,Width,Height)
	For temp = 0 To 3
		X = X + FifthWidth
		Value = DNAbits.Get(temp+StartIndex)
		Ones = Value.X Mod 10
		Tens = Floor(Value.X / 10)
		tempstr.Append(Value.Y)
		DrawDNALines(BG, X, Y, 0, Height, BarHeight, ThickStroke, ThickStroke, True, Color, Stroke, Ones)
		DrawDNALines(BG, X, Y, 0, Height, BarHeight, ThickStroke, ThickStroke, False, Color, Stroke, Tens)
		LCAR.DrawText(BG, X + ThickStroke*0.5, Y+HalfHeight - TextHeight, Value.X, ColorID, 5, False, Alpha, 0)
	Next
	BG.RemoveClip
	Return tempstr.ToString
End Sub

Sub ClipOval(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim handpath As ABPath,oval As ABRectF
	oval.Initialize(X,Y,X+Width,Y+Height)
	handpath.addOval(oval, handpath.Direction_CW)
	LCAR.ExDraw.clipPath2(BG, handpath)
End Sub

public Sub DrawDNAbyteS2A(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, BarHeight As Int, Data As Point, Alpha As Int, TextHeight As Int, Color As Int, State As Boolean, TextColorID As Int) As String 
	Dim HalfHeight As Int = Height * 0.5, Middle As Int = Y + HalfHeight, Ones As Int = Data.X Mod 10, Tens As Int = Floor(Data.X / 10), HalfWidth As Int =  Width*0.5, SecondWidth As Int = Width * 0.15
	
	DrawOval(BG, X, Y, Width,Height, Color, Stroke)
	LCAR.DrawText(BG, X + HalfWidth, Middle - TextHeight, Data.X, TextColorID, 5, State, Alpha, 0)
	
	ClipOval(BG,X,Y,Width,Height)
	
	DrawDNALines(BG, X,Y, Width, Height, BarHeight, SecondWidth, SecondWidth, True,  Color, Stroke, Ones)
	DrawDNALines(BG, X,Y, Width, Height, BarHeight, SecondWidth, SecondWidth, False, Color, Stroke, Tens)
	
	BG.RemoveClip
	Return Data.Y'Ones & Tens
End Sub
public Sub DrawDNALines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarHeight As Int, SecondWidth As Int, SecondHeight As Int, IsTop As Boolean, Color As Int, Stroke As Int, Value As Int)
	Dim OldSecondWidth As Int = SecondWidth, Pwidth As Int = Width * 0.20, HalfHeight As Int = Height*0.5 , HalfBarHeight As Int = BarHeight * 0.5, Height2 As Int = HalfHeight - HalfBarHeight
	If Value < 3 Then 
		SecondWidth = 0
	else if Value > 5 Then 
		Stroke = (Stroke + SecondWidth) * 0.85
		SecondWidth = 0
	End If

	If Not(IsTop) Then Y = Y + HalfHeight + HalfBarHeight
	DrawDNALine(BG, X+Pwidth, Y, Stroke, Height2, SecondWidth, SecondHeight, IsTop, Color)
	If Width > 0 Then DrawDNALine(BG, X+Width-Pwidth-OldSecondWidth, Y, Stroke, Height2, SecondWidth, SecondHeight, IsTop, Color)
End Sub

public Sub DrawDNALine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SecondWidth As Int, SecondHeight As Int, IsTop As Boolean, Color As Int)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Color, 0)
	If SecondWidth > 0 And SecondHeight > 0 Then 
		If IsTop Then Y = Y + Height - SecondHeight
		LCARSeffects4.DrawRect(BG,X+Width,Y,SecondWidth,SecondHeight, Color, 0)		
	End If
End Sub


'VOY style (0)
Sub DrawOval(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	BG.DrawOval(LCARSeffects4.SetRect(X, Y, Width,Height), Color, Stroke=0, Stroke)
End Sub
public Sub DrawCrosshairs(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, pt As Point, Color As Int, Stroke As Int, Space As Int)
	BG.DrawLine(X, pt.Y, pt.X-Space, pt.Y, Color, Stroke)
	BG.DrawLine(X+ Width, pt.Y, pt.X+Space, pt.Y, Color, Stroke)
	BG.DrawLine(pt.X, Y, pt.X, pt.Y-Space, Color, Stroke)
	BG.DrawLine(pt.X, Y+Height, pt.X, pt.Y+Space, Color, Stroke)
	DrawBrokenBox(BG, pt.X-Space, pt.Y-Space, Space*2, Space*2, Color, Stroke*2, Space*0.5)
End Sub
public Sub DrawBrokenBox(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, Space As Int)
	Dim HalfWidth As Int = Width *0.5, HalfHeight As Int = Height * 0.5, HalfSpace As Int = Space * 0.5
	BG.DrawLine(X, y, X+ HalfWidth - HalfSpace, Y, Color, Stroke)'TL-
	BG.DrawLine(X+HalfWidth+HalfSpace, y, X+ Width, Y, Color, Stroke)'TR-
	BG.DrawLine(X, Y+Height, X+ HalfWidth - HalfSpace, Y+Height, Color, Stroke)'BL-
	BG.DrawLine(X+HalfWidth+HalfSpace, Y+Height, X+ Width, Y+Height, Color, Stroke)'BR-
	BG.DrawLine(X, Y, X, Y+ HalfHeight-HalfSpace, Color, Stroke)'TL|
	BG.DrawLine(X, Y+HalfHeight+HalfSpace, X, Y+ Height, Color, Stroke)'BL|
	BG.DrawLine(X+Width, Y, X+Width, Y+ HalfHeight-HalfSpace, Color, Stroke)'TR|
	BG.DrawLine(X+Width, Y+HalfHeight+HalfSpace, X+Width, Y+ Height, Color, Stroke)'BR|
End Sub
public Sub IsPointValid(LST As List, Index As Int) As Boolean
	If Index = -1 Then Return False 
	Dim tempP As Point = LST.Get(Index)
	Return tempP.IsInitialized
End Sub
public Sub DrawDNAbyteS1(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, BarHeight As Int, Data As Point, Alpha As Int, TextHeight As Int, HighlightPoint As Int, TextSize As Int) As Point()
	Dim HalfStroke As Int = Stroke * 0.5, HalfHeight As Int = Height * 0.5, Middle As Int = Y + HalfHeight, Ones As Int = Data.Y Mod 10, Tens As Int = Floor(Data.Y / 10), HalfWidth As Int =  Width*0.5, PTS(4) As Point 
	Dim Color As Int = LCAR.GetColor(Data.Y, False, Alpha)
	
	PTS(0) = DrawDNAbitS1(BG,X,Y,Width,Height,Stroke,BarHeight, True, Ones, Alpha, HalfWidth,HalfHeight,HalfStroke, HighlightPoint=0)
	PTS(1) = DrawDNAbitS1(BG,X,Y,Width,Height,Stroke,BarHeight, False, 2+Ones Mod 10, Alpha, HalfWidth,HalfHeight,HalfStroke, HighlightPoint=1)
	PTS(2) = DrawDNAbitS1(BG,X,Y,Width,Height,Stroke,BarHeight, False, Tens, Alpha, HalfWidth,HalfHeight,HalfStroke, HighlightPoint=2)
	PTS(3) = DrawDNAbitS1(BG,X,Y,Width,Height,Stroke,BarHeight, True, 5+Tens Mod 10, Alpha, HalfWidth,HalfHeight,HalfStroke, HighlightPoint=3)

	DrawOval(BG, X, Y, Width,Height, Color, Stroke)
	LCARSeffects4.DrawRect(BG,X-HalfStroke, Middle - BarHeight * 0.5, Width+Stroke, BarHeight, Colors.Black, 0)
	'LCAR.DrawText(BG, X + HalfWidth, Middle - TextHeight, Data.X, Data.Y, 5, False, Alpha, 0)
	BG.DrawText(Data.X, X + HalfWidth, Middle + BarHeight*0.5, LCAR.lcarfont, TextSize, Color, "CENTER")
	Return PTS 
End Sub
public Sub DrawDNAbitS1(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, BarHeight As Int, IsTop As Boolean, Data As Int, Alpha As Int, HalfWidth As Int, HalfHeight As Int, HalfStroke As Int, State As Boolean) As Point
	Dim ColorID As Int = Data + 1, Angle As Int = Data * 10 - 45, POS As Point, Color As Int = LCAR.getcolor(ColorID, State, Alpha), Tolerance As Int = Width * 0.05 , ret As Point 
	If Data >= 7 Then Stroke = Stroke * 1.5
	If Data <= 3 Then Stroke = Stroke * 0.75
	If Not(IsTop) Then Angle = 180 + Angle 
	POS = Trig.findOvalXY(X,Y,Width,Height, Angle)'User 45 degree window before/after 0 and 180
	If IsTop Then 
		Height = HalfHeight - (POS.Y-Y)
	Else
		Height = -(HalfHeight - (Y+Height - POS.Y))
	End If
	If POS.X > X + Tolerance And POS.X < X + Width - Tolerance Then 
		BG.DrawLine(POS.X,POS.Y, POS.X, POS.Y+Height, Color, Stroke)
		If IsTop Then Height = Height - HalfStroke Else Height = Height + HalfStroke
		ret = Trig.setpoint(POS.X, POS.Y+Height)
	End If 
	Return ret
End Sub

'ENTERPRISE STYLE
public Sub DrawDNAent(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, LWidth As Int, DNAbits As List, Index As Int, BarOffset As Int, Font As Typeface, HalfTextHeight As Int, Tag As String) As Int
	'PHASE 1: PreCARS frame
	Dim Size As Rect = LCARSeffects2.GetEntCARSFrameUsableSpace(X,Y,Width,Height,-1), SelectedStart As Int = -1, SelectedEnd As Int = -1', HalfTextHeight As Int = BG.MeasureStringHeight("GATC", Font, LCAR.fontsize) * 0.5
	Dim OriginalSize As Rect = LCARSeffects4.SetRect(X,Y,Width,Height)
	LCARSeffects2.DrawPreCARSFrame(BG,X,Y,Width,Height, LCAR.Classic_Red, 255,0, 0, 0 , "DNA SAMPLE " & Index, 5, "")
	X=Size.Left 
	Y=Size.Top + 8
	Width = Size.Right-X - 9
	Height = Size.Bottom-Y - 8
	LCARSeffects.MakeClipPath(BG, X,Y,Width,Height)
	
	'PHASE 2: Greebles
	Dim Height2 As Int = Height * 0.25, Y2 As Int = Y + Height - Height2, Bits As Int = 11, BitWidth As Int = Width / Bits, WhiteSpace As Int = 4, Height3 As Int = Height2*0.5, Y3 As Int = Y + Height3
	Dim X2 = X - (BitWidth * (BarOffset * 0.1)), temp As Int, IsFirst As Boolean = True, Width2 As Int = Width * 2
	For temp = 0 To 1
		Select Case Index'Y3=top middle row, Y2=bottom row										  --------if you ever change these, don't forget to update the lengths in InitRNDs------
			Case 0'																							   1  2  3  4  5    1  2  3  4  5				 1 2 3 4 5  1 2 3 4 5
				DrawDNAblocksENT(BG,X2, Y3, Width2, Height3, BitWidth, WhiteSpace, Alpha, IsFirst, Array As Int(5, 4, 2, 		4, 1, 3, 2, 1), Array As Int(2,0,1,		0,0,3,1,0),		0, Font, HalfTextHeight, True)
				DrawDNAblocksENT(BG,X2, Y2, Width2, Height3, BitWidth, WhiteSpace, Alpha, IsFirst, Array As Int(4, 3, 4,		2, 3, 1, 5), 	Array As Int(3,1,2,		1,0,3,0),		1, Font, HalfTextHeight, False)
				SelectedStart = 3
				SelectedEnd = 5
			Case 1
				DrawDNAblocksENT(BG,X2, Y3, Width2, Height3, BitWidth, WhiteSpace, Alpha, IsFirst, Array As Int(2, 1, 3, 5,		3, 8), 			Array As Int(0,0,1,3,	1,0),			2, Font, HalfTextHeight, True)
				DrawDNAblocksENT(BG,X2, Y2, Width2, Height3, BitWidth, WhiteSpace, Alpha, IsFirst, Array As Int(3, 1, 3, 2, 2,	2, 5, 2, 2), 	Array As Int(1,0,1,0,2,	1,0,1,0),		3, Font, HalfTextHeight, False)
				SelectedStart = 6
				SelectedEnd = 8
		End Select
		IsFirst = False
		X2 = X2 + (BitWidth*Bits*2) + WhiteSpace - 1
	Next
	X = X - (BitWidth * (LWidth * 0.1))
	Y = Y + Height2
	Height = Height - Height2*2
	
	'PHASE 3: DNA
	MakeBits(DNAbits, Bits, True)
	DrawDNAbyteENT(BG, X,Y, BitWidth, Height, Alpha, DNAbits, SelectedStart, SelectedEnd, LWidth = 10, Font, WhiteSpace, HalfTextHeight)
	BG.RemoveClip
	
	Alpha=Alpha*0.5
	If LCARSeffects2.KlingonVirus Then LCARSeffects3.DrawKlingonFrame(BG, OriginalSize.Left, OriginalSize.top, OriginalSize.Width,OriginalSize.Height, -1, Alpha, True, False, Tag)
	Return BarOffset
End Sub

public Sub DrawENTclaw(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, NotLCARScolorID As Int, Alpha As Int, IsTop As Boolean)
	Dim HalfHeight As Int = Height * 0.5, Radius As Int = HalfHeight * 0.5, Color As Int = NotLCARScolor(NotLCARScolorID, Alpha), X2 As Int = X+Width-Radius
	Dim TopRow As Int = Y, BottomRow As Int = Y + Radius
	If Not(IsTop) Then 
		TopRow = Y + HalfHeight
		BottomRow = Y
	End If
	LCARSeffects4.DrawRect(BG, X+Radius, TopRow, Width-HalfHeight, HalfHeight, Color, 0)
	BG.DrawCircle(X+Radius, TopRow+Radius, Radius, Color, True, 0)
	BG.DrawCircle(X2, TopRow+Radius, Radius, Color, True, 0)
	LCARSeffects4.DrawRect(BG, X, BottomRow, Radius, Height-Radius, Color, 0)
	LCARSeffects4.DrawRect(BG, X2, BottomRow, Radius, Height-Radius, Color, 0)
End Sub

'NotLCARScolorIDs: 0=light grey, 1=dark grey, 2=yellow, 3=white
public Sub NotLCARScolor(ID As Int, Alpha As Int) As Int 
	Select Case ID
		Case -1: Return Rnd(0,4)'random ID
		Case 0: Return Colors.aRGB(Alpha, 193,198,204)'light grey
		Case 1: Return Colors.aRGB(Alpha, 145,145,145)'dark grey
		Case 2: Return Colors.aRGB(Alpha, 255,255,0)'yellow
		Case 3: Return Colors.aRGB(Alpha, 255,255,255)'white
	End Select
End Sub

'Retain=false (init, generate 2 blocks) true (delete 1 block, generate 1 block)
Sub InitRNDs(Retain As Boolean)
	Dim temp As Int, temp2 As Int, Lengths() As Int = Array As Int(8,7,6,9), Length As Int'0: 3+5=8	1: 3+4=7		2: 4+2=6		3: 5+4=9
	For temp = 0 To RNDs.Length -1
		'If API.ListSize(RNDs(temp)) = 0 Then RNDs(temp).Initialize
		Length = Lengths(temp) 
		If Not(Retain) Then 
			RNDs(temp).Initialize
			RNDsBrackets(temp).Initialize
			RNDsBrackets(temp).Add(MakeRNDclaws(-1))
			Length = Length * 2
		End If
		If Retain Then RNDsBrackets(temp).RemoveAt(0)
		RNDsBrackets(temp).Add(MakeRNDclaws(-1))
		For temp2 = 0 To Length - 1
			If Retain Then RNDs(temp).RemoveAt(0)
			RNDs(temp).Add( RandomNumber("#####@") )
		Next
	Next
End Sub

Sub MakeRNDclaws(Quantity As Int) As List 
	Dim RET As List, X As Int, Width As Int, LastColorID As Int = -1	'RNDsBrackets
	RET.Initialize
	If Quantity < 1 Then Quantity = Rnd(6,10)
	Do Until Quantity < 1 
		Dim Bracket As RNDCLaw
		Bracket.Initialize
		X = Rnd(0, 80)
		Width = Rnd(5, 100-X)
		Bracket.X = X * 0.01
		Bracket.Width = Width * 0.01
		Bracket.Height = (50 + (5 * Rnd(0,11))) * 0.01
		Bracket.ColorID = -1 
		Do Until Bracket.ColorID <> LastColorID And Bracket.ColorID > -1 
			Bracket.ColorID = NotLCARScolor(-1, 0)
		Loop
		RET.Add(Bracket)
		Quantity = Quantity - 1
		LastColorID = Bracket.ColorID
	Loop
	Return RET 
End Sub

public Sub DrawDNAclaws(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ListIndex As Int, IsFirst As Boolean, Alpha As Int, IsTop As Boolean)
	Dim Sizes As List = RNDsBrackets(ListIndex).Get( API.IIF(IsFirst, 0, 1) ), temp As Int, Bracket As RNDCLaw, Y2 As Int = Y, Height2 As Int, WhiteSpace As Int = 2
	Y = Y + WhiteSpace 
	Height = Height - WhiteSpace*2
	For temp = 0 To Sizes.Size - 1 
		Bracket = Sizes.Get(temp)
		Height2 = Height * Bracket.Height
		If IsTop Then Y2 = Y + Height - Height2
		DrawENTclaw(BG, X + Width * Bracket.X,Y2,Width * Bracket.Width,Height2, Bracket.ColorID, Alpha, IsTop)
	Next
End Sub

'Widths must add up to a multiple 11, RNDs and NotLCARScolorIDs must have the same size as Widths (NotLCARScolorIDs: 0=light grey, 1=dark grey, 2=yellow, 3=white)
public Sub DrawDNAblocksENT(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BitWidth As Int, WhiteSpace As Int, Alpha As Int, IsFirst As Boolean, Widths As List, NotLCARScolorIDs As List, Index As Int, Font As Typeface, HalfTextHeight As Int, IsTop As Boolean)
	Dim temp As Int, temp2 As Int = Y + Height, RNDtext As List = RNDs(Index)
	If API.ListSize(RNDtext) = 0 Then InitRNDs(False)
	If IsTop Then temp2 = Y - Height 
	DrawDNAclaws(BG, X, temp2, Width, Height, Index, IsFirst, Alpha, IsTop)	
	For temp = 0 To Widths.Size - 1 
		Width = Widths.Get(temp) * BitWidth 
		If temp = 0 And IsFirst Then Width = Width + WhiteSpace 
		temp2 = temp 
		If Not(IsFirst) Then temp2 = temp2 + Widths.Size
		LCARSeffects4.DrawRect(BG,X,Y,Width-WhiteSpace,Height, NotLCARScolor(NotLCARScolorIDs.Get(temp), Alpha), 0)
		BG.DrawText(RNDtext.Get(temp2), X + Width * 0.5, Y + Height*0.5+HalfTextHeight, Font, LCAR.Fontsize, Colors.Black, "CENTER")
		X=X+Width 
	Next
End Sub

Public Sub DrawDNAbyteENT(BG As Canvas, X As Int, Y As Int, BitWidth As Int, Height As Int, Alpha As Int, DNAbits As List, StartSelected As Int, EndSelected As Int, DoSelected As Boolean, Font As Typeface, WhiteSpace As Int, HalfTextHeight As Int)
	Dim temp As Int, Bits = DNAbits.Size, BitHeight As Int= Height * 0.5, Ones As Int, Tens As Int, Value As Point, Selected As Boolean
	Dim TopRow As Int = Y + WhiteSpace, BottomRow As Int = Y + BitHeight + WhiteSpace * 0.5, BitHeight2 As Int = BitHeight - WhiteSpace*1.5', BitWidth As Int = Width / Bits
	X=X+WhiteSpace
	For temp = 0 To Bits - 1
		Value = DNAbits.Get(temp)
		Ones = Value.X Mod 4'10
		Tens = 3-Ones'MUST BE AT/TA (1/2) or CG/GC (0/3))
		If DoSelected Then Selected = temp >= StartSelected And temp <= EndSelected
		DrawDNAbitENT(BG, X, TopRow,    BitWidth - WhiteSpace, BitHeight2, Ones, Selected, True,  Alpha, HalfTextHeight, Font)
		DrawDNAbitENT(BG, X, BottomRow, BitWidth - WhiteSpace, BitHeight2, Tens, Selected, False, Alpha, HalfTextHeight, Font)
		X = X + BitWidth 
	Next
End Sub
public Sub DrawDNAbitENT(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Index As Int, State As Boolean, IsTop As Boolean, Alpha As Int, HalfTextHeight As Int, Font As Typeface)
	Dim Letter As String, R As Int, G As Int, B As Int, Brightness As Int = 64, Color As Int, Y2 As Int = Y, Y3  As Int = Y', ColorID As Int
	Dim Height2 As Int = Height * 0.33, Width2 As Int = Width * 0.20, Height3 As Int = Height-Height2
	Select Case Index Mod 4
		Case 0
			Letter = "G"'ColorID = LCAR.LCAR_LightPurple
			R = 197
			G = 133
			B = 186
		Case 1
			Letter = "A"'ColorID = LCAR.Classic_Blue
			'R = 0
			G = 170
			B = 230
		Case 2
			Letter = "T"'ColorID = LCAR.Classic_Red
			R = 206
			G = 47
			B = 41
		Case 3
			Letter = "C"'ColorID = LCAR.LCAR_Orange
			R = 254
			G = 201
			B = 69
	End Select
	If State Then 
		R = Min(255, R + Brightness)
		G = Min(255, G + Brightness)
		B = Min(255, B + Brightness)
	End If
	Color = Colors.ARGB(Alpha,R,G,B)
	If IsTop Then 
		Y2 = Y2 + Height2
	Else 
		Y3 = Y3 + Height - Height2
	End If
	LCARSeffects4.DrawRect(BG,X, Y3, Width, Height2, Color, 0)'---
	LCARSeffects4.DrawRect(BG,X+Width2, Y2, Width - Width2*2, Height3, Color, 0)' |
	BG.DrawText(Letter, X + Width * 0.5, Y2 + Height3*0.5+HalfTextHeight, Font, LCAR.Fontsize, Colors.Black , "CENTER")
End Sub

















'New UFP 
public Sub InitAlpha(Start As Int, Finish As Int) As TweenAlpha
	Dim temp As TweenAlpha
	temp.Initialize
	temp.Current = Start
	temp.Desired = Finish 
	Return temp 
End Sub
public Sub IncrementUFPlogo(Element As LCARelement) As Boolean 
	Dim temp As Int, AnimatingStars As Boolean, tempstar As UFPstar
	If Element.LWidth = -1 Then 'initialize
		Element.LWidth = 0
		Element.RWidth = 8
		UFPStars.Initialize
		MakeStars(Array As Int(8, 230, 158,		7, 214, 189,	8, 235, 199,	7, 164, 175,	10, 140, 159,	7, 156, 146,	10, 183, 137,	7, 225, 219,	9, 182, 231,	6, 207, 232,	6, 179, 238))
		MakeStars(Array As Int(7, 175, 244, 	7, 156, 243,	8, 144, 234,	8, 123, 225,	8, 90, 235,		8, 113, 239,	9, 111, 250,	8, 128, 253,	8, 143, 257,	9, 183, 255,	6, 197, 251))
		MakeStars(Array As Int(10, 221, 246,	10, 209, 262,	7, 189, 276,	7, 109, 275,	8, 98, 263,		6, 80, 267,		7, 90, 289,		7, 141, 288,	10, 215, 292,	8, 66, 312,		8, 51, 277))
		MakeStars(Array As Int(8, 5, 34,		6, 29, 173,		7, 58, 180,		6, 66, 111,		9, 194, 99,		6, 218, 108,	7, 157, 90,		4, 122, 81,		8, 45, 51,		7, 24, 356,		8, 45, 340))
		MakeStars(Array As Int(4, 53, 3,		8, 54, 25,		7, 85, 17,		12, 102, 1,		8, 81, 339,		8, 122, 348,	7, 139, 347,	6, 135, 340,	10, 170, 343,	7, 177, 353,	7, 164, 357))
		MakeStars(Array As Int(13, 137, 24,		7, 124, 33,		7, 85, 47,		7, 117, 49,		8, 131, 55,		7, 148, 70,		12, 181, 54,	10, 154, 47,	7, 146, 41,		6, 171, 45,		7, 218, 45))
		MakeStars(Array As Int(4, 208, 43,		8, 230, 34,		7, 188, 31,		8, 192, 25,		8, 170, 31,		7, 227, 59,		10, 213, 73,	10, 212, 80,	8, 232, 352))
		BigStars(0) = MakeBigStar(169,263,108, -60)'big/left
		BigStars(1) = MakeBigStar(276,172,78, 0)'top
		BigStars(2) = MakeBigStar(323,321,78, -120)'bottom
		'If WallpaperService.PreviewMode Then LCAR.PlaySound(1, False)
	else if Element.LWidth > 0 Then'skip first frame (0-100)
		If Element.RWidth = -1 Then 
			For temp = 0 To BigStars.Length - 1 '<0 is not visible, 0-100=growing, 100-200=growing shine, 200-300 shrinking shrine
				If BigStars(temp).OffsetDistance < 300 Then 
					BigStars(temp).OffsetDistance = LCAR.Increment(BigStars(temp).OffsetDistance, 5, 300)
					AnimatingStars = True 
				End If 
			Next
			If Not(AnimatingStars) Then	
				Element.RWidth = -2
				If WallpaperService.PreviewMode And Not(LCAR.IsPlaying) Then LCAR.SystemEvent(0,-1)
			End If 
		Else if Element.RWidth > -1 Then 
			If Element.RWidth> 0 Then Element.RWidth = Element.RWidth-1'frames (8 to 0)
			For temp = 0 To UFPStars.Size - 1
				tempstar = UFPStars.Get(temp)
				If tempstar.OffsetDistance > 0 Then 
					tempstar.OffsetDistance = LCAR.Increment(tempstar.OffsetDistance, 5, 0)
					AnimatingStars = True 
				End If
			Next
			If Not(AnimatingStars) Then	 Element.RWidth = -1	
		End If 
	End If
	
	Element.LWidth = LCAR.Increment(Element.LWidth, 5, 100)'Lwidth = Blue BG percent
	Return True 
End Sub
public Sub MakeBigStar(X As Int, Y As Int, Radius As Int, StartingPercent As Int) As UFPstar
	Dim tempstar As UFPstar
	tempstar.Initialize
	tempstar.Angle = X
	tempstar.Distance = Y
	tempstar.Radius = Radius 
	tempstar.OffsetDistance = StartingPercent
	Return tempstar
End Sub
public Sub MakeStars(Numbers() As Int)
	Dim temp As Int 
	For temp = 0 To Numbers.Length -1 Step 3
		MakeStar( Numbers(temp), Numbers(temp+1), Numbers(temp+2) )
	Next
End Sub
public Sub MakeStar(Radius As Int, Distance As Int, Angle As Int)
	Dim tempstar As UFPstar
	tempstar.Initialize
	tempstar.Radius = Radius
	tempstar.Angle = Angle
	tempstar.Distance = Distance
	tempstar.OffsetDistance = Rnd(200,300)
	UFPStars.Add(tempstar)
End Sub
public Sub ScaleDimension(IsWidth As Boolean, ActualWidthHeight As Int, DesiredWidthHeight As Int) As Int 
	Dim SourceWidthHeight As Int = 650
	If IsWidth Then SourceWidthHeight = 798
	Return ActualWidthHeight/SourceWidthHeight * DesiredWidthHeight
End Sub
public Sub DrawUFPlogo(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Element As LCARelement)
	Dim tempY As Int = LCAR.ItemHeight*2, DEST As Point = API.Thumbsize(798,650, Width, (Height-tempY)*0.75, True, False), temp As Int, temp2 As Int, tempP As Float = Element.LWidth * 0.01, White As Int = Colors.ARGB(Alpha, 255,255,255)
	Dim OldX As Int = X, OldWidth As Int = Width, OldY = Y + LCAR.ItemHeight, OldHeight As Int = Height - tempY
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "ufplogo.png", LCAR.LCAR_UFP)
	LCARSeffects2.DrawTextButton(BG,X,Y,Width,LCAR.LCAR_Purple,LCAR.LCAR_Red,LCAR.LCAR_Purple, Alpha, False, Element.Text,  LCAR.LCAR_LightBlue, False, True,Alpha<255)
	LCARSeffects2.DrawTextButton(BG,X,Y+Height - LCAR.ItemHeight,Width,LCAR.LCAR_Purple,LCAR.LCAR_Red,LCAR.LCAR_Purple, Alpha, False, Element.SideText,  LCAR.LCAR_Purple, False,False,Alpha<255)
	If tempP < 1 Then 
		temp = (1-tempP)*Width 
		temp2 = X + Width - temp
		LCARSeffects4.DrawRect(BG, temp2, Y,Width, LCAR.ItemHeight, Colors.Black, 0)
		LCARSeffects4.DrawRect(BG, temp2, Y+Height - LCAR.ItemHeight,Width, LCAR.ItemHeight, Colors.Black, 0)
	End If 
	
	Height = Height-tempY
	LCARSeffects.MakeClipPath(BG, X,Y+LCAR.ItemHeight, Width,Height)	
	X = X + Width * 0.5 - DEST.X * 0.5
	Y = Y + LCAR.ItemHeight + Height * 0.5 - DEST.Y * 0.5 
	Width = DEST.X
	Height = DEST.Y 
	
	tempY = Y + ScaleDimension(False, Height, 286)'Center of Blue BG
	DEST.X = ScaleDimension(True, Width, 489 * tempP)'Width of blue bg
	DEST.Y = ScaleDimension(False, Height, 514 * tempP)'Height of blue bg
	DrawOval(BG, X+Width*0.5 - DEST.X*0.5, tempY-DEST.Y * 0.5, DEST.X, DEST.Y, Colors.ARGB(Alpha, 0,0,255), 0)'BLUE BG
	
	tempP = 2-tempP
	temp = ScaleDimension(True, Width, 548 * tempP)'Width of Ring
	temp2 = ScaleDimension(False, Height, 573 * tempP)'Height of Ring
	
	If (Element.LWidth = 100 And Element.RWidth< 1) Or ((Element.RWidth > -1 And Element.LWidth < 100) And Element.RWidth < 8 And Not(Element.LWidth = -1 And Element.RWidth = 0)) Then 
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 548,0, 		92,82, 		132,18) '1
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 548,82, 	62,107, 	91,63)  '2
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 548,189, 	62,123,		60,109) '3
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 548,312, 	77,133, 	31,163) '4
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 1164,312, 	92,134,		10,229) '5
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 1044,170,	108,129,	0,300)  '6
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 548,474,	120,99,		10,395) '7
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 1508,488,	105,85,		63,460) '8
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 1284,0,		107,82,		110,506)'9
		DrawUFPolive(BG,X,Y,Width,Height,Alpha, Element.RWidth, 1044,82,	162,88,		212,562)'10
	End If 
	
	LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 0,0, 548,573, X+Width*0.5 - temp*0.5, tempY - temp2*0.5, temp,temp2, Alpha, False, False)'Ring
	
	LCARSeffects.MakeClipPath(BG, OldX,OldY, OldWidth,OldHeight)	
	temp2=X+Width*0.5
	If Not(UFPStars.IsInitialized) Then IncrementUFPlogo(Element)
	For temp = 0 To UFPStars.Size - 1
		DrawUFPstar(BG, Width, Height, temp2, tempY, DEST, White, temp)'Small stars
	Next
	BG.RemoveClip
	If Element.RWidth < 0 Then
		temp2 = temp2 - (DEST.X * 0.5)
		tempY = tempY - (DEST.Y * 0.5)
		For temp = 0 To BigStars.Length - 1
			DrawBIGstar(BG, Width, Height, temp2, tempY, DEST, temp)'Big stars
		Next
	End If
	'If API.debugMode Then  LCAR.DrawText(BG,X,Y, Element.LWidth & "-" & Element.RWidth, LCAR.LCAR_Orange, 4, False, 255,0)
End Sub
public Sub DrawBIGstar(BG As Canvas, Width As Int, Height As Int, CenterX As Int, CenterY As Int, BlueBG As Point, Index As Int)
	Dim tempstar As UFPstar = BigStars(Index), Percent As Float = (tempstar.OffsetDistance Mod 100) * 0.01, StarRadius As Float = 1, GlowRadius As Float = 0
	'tempstar.Angle = X out of 489, tempstar.Distance = Y out of 514, tempstar.Radius = Radius, tempstar.OffsetDistance = StartingPercent
	If tempstar.OffsetDistance > 0 Then 
		CenterX = CenterX + (tempstar.Angle / 489 * BlueBG.X)
		CenterY = CenterY + (tempstar.Distance / 514 * BlueBG.Y)
		If tempstar.OffsetDistance < 100 Then'growing star
			StarRadius = Percent 
		Else if tempstar.OffsetDistance < 200 Then 'growing glow
			GlowRadius = Percent 
		else if tempstar.OffsetDistance < 300 Then 'shrinking glow
			GlowRadius = 1-Percent 
		End If 
		DrawUFPsprite(BG,CenterX,CenterY,Width, 1908,170,108,108, StarRadius, tempstar.Radius)
		DrawUFPsprite(BG,CenterX,CenterY,Width, 2017,171,100,100, GlowRadius, tempstar.Radius*2)
	End If 
End Sub
public Sub DrawUFPsprite(BG As Canvas, centerX As Int, centerY As Int, WidthOfArea As Int, srcX As Int, srcY As Int, srcWidth As Int, srcHeight As Int, Percent As Float, Size As Int)
	If Percent <= 0 Then Return 
	Size = ScaleDimension(True, WidthOfArea, Percent * Size)
	centerX = centerX - Size * 0.5
	centerY = centerY - Size * 0.5
	LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,srcY, srcWidth, srcHeight, centerX, centerY, Size, Size, 255, False, False)
End Sub
public Sub DrawUFPstar(BG As Canvas, Width As Int, Height As Int, CenterX As Int, CenterY As Int, BlueBG As Point, Color As Int, Index As Int)
	Dim tempstar As UFPstar = UFPStars.Get(Index), Percent As Float = tempstar.OffsetDistance * 0.01, ActualDistance As Int = tempstar.Distance + Width * Percent , Distance As Int = ScaleDimension(True, Width, ActualDistance)
	Dim X As Int = Trig.findXY(CenterX, CenterY, Distance, tempstar.Angle, True), Y As Int = Trig.findXY(CenterX, CenterY, Distance, tempstar.Angle, False), Radius As Int = tempstar.Radius + (tempstar.Radius * Percent * 5)
	BG.DrawCircle(X,Y, Radius, Color, True, 0)
End Sub
public Sub DrawUFPolive(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Frame As Int, srcX As Int, srcY As Int, srcWidth As Int, srcHeight As Int, destX As Int, destY As Int)
	Dim destWidth As Int = ScaleDimension(True, Width, srcWidth), destHeight As Int = ScaleDimension(False, Height, srcHeight), destLeft As Int, destRight As Int 
	destX = ScaleDimension(True, Width, destX)
	destY = Y + ScaleDimension(False, Height, destY)
	destLeft = X + destX
	destRight = X + Width - destX - destWidth
	LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,srcY, srcWidth, srcHeight, destLeft, destY, destWidth, destHeight, Alpha, False, False)
	LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,srcY, srcWidth, srcHeight, destRight, destY, destWidth, destHeight, Alpha, True, False)
	If Frame > 0 And Frame < 8 Then 
		srcX = srcX + Frame * srcWidth
		LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,srcY, srcWidth, srcHeight, destLeft, destY, destWidth, destHeight, Alpha, False, False)
		LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,srcY, srcWidth, srcHeight, destRight, destY, destWidth, destHeight, Alpha, True, False)	
	End If 
End Sub

public Sub GlobalCrosshairs(BG As Canvas, X As Int, Y As Int, Color As Int, Stroke As Int)
	BG.DrawLine(0, Y, LCAR.ScaleWidth, Y, Color, Stroke)
	BG.DrawLine(X, 0, X, LCAR.ScaleHeight, Color, Stroke)
End Sub



'Operation: -1=Subtract the second path from the first path, 0=Intersect the two paths, 1=Subtract the first path from the second path, 2=Union (inclusive-or) the two paths, 3=Exclusive-or the two paths
Sub OpPath(Path1 As Path, Path2 As Path, Op As Int) As Path
	Dim Operation As String 
	Select Case Op
		Case -1: 	Operation = "DIFFERENCE"
		Case 0: 	Operation = "INTERSECT"
		Case 1: 	Operation = "REVERSE_DIFFERENCE"		
		Case 2: 	Operation = "UNION"'merge 2 paths together
		Case 3: 	Operation = "XOR"
	End Select
    Dim jo As JavaObject = Path1, success As Boolean = jo.RunMethod("op", Array(Path2, Operation))
 	Return Path1   
End Sub
'If RadiusY = 0 or RadiusX, then it'll be a circle. Otherwise an Oval
Sub PathAddCircle(Path As Path, CenterX As Float, CenterY As Float, RadiusX As Float, RadiusY As Float)
	If Not(Path.IsInitialized) Then Path.Initialize(CenterX, CenterY)
	Dim jo As JavaObject = Path
	If RadiusX = RadiusY Or RadiusY=0 Then 
  		jo.RunMethod("addCircle", Array(CenterX, CenterY, RadiusX, "CW"))
	Else 
		jo.RunMethod("addOval", Array(CenterX-RadiusX, CenterY-RadiusY, CenterX+RadiusX, CenterY+RadiusY, "CW"))
	End If 
	'https://developer.android.com/reference/android/graphics/Path.html
	'addArc(float left, float top, float right, float bottom, float startAngle, float sweepAngle) 
	'addRoundRect(float left, float top, float right, float bottom, float rx, float ry, Path.Direction dir) 
	'arcTo(float left, float top, float right, float bottom, float startAngle, float sweepAngle, boolean forceMoveTo) 
	'cubicTo(float x1, float y1, float x2, float y2, float x3, float y3) 
	'quadTo(float x1, float y1, float x2, float y2) 
End Sub

'If RadiusY = 0 or RadiusX, then it'll be a circle. Otherwise an Oval
Sub PathRemCircle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CenterX As Float, CenterY As Float, RadiusX As Float, RadiusY As Float)
	Dim fullScreen As Path
   	fullScreen.Initialize(X, Y)
   	fullScreen.LineTo(X+Width, Y)
   	fullScreen.LineTo(X+Width, Y+Height)
   	fullScreen.LineTo(X, Y+Height)
   
    If RadiusX = 0 And RadiusY = 0 Then 
		RadiusX = Width * 0.5
		RadiusY = Height * 0.5
		If CenterX = 0 And CenterY = 0 Then 
			CenterX = X + RadiusX
			CenterY = Y + RadiusY
		End If 	
	End If
   
   	Dim circle As Path
	PathAddCircle(circle, CenterX, CenterY, RadiusX, RadiusY)
	
	Dim p As Path = OpPath(fullScreen, circle, -1)
	BG.ClipPath(p)
End Sub








Sub MakePlasma
	Dim PlasmaLayers As Int = 3
	If Not(Plasma.IsInitialized) Then 
		Plasma.Initialize
		Do Until PlasmaLayers = 0
			Dim Layer As PlasmaLayer, Percent As Int = 100
			Layer.Initialize
			Layer.Cells.Initialize
			Do Until Percent < 1
				Dim PlasmaUnit As PlasmaCell = MakePlasmaCell(Percent)
				Percent = Percent - PlasmaUnit.Height
				Layer.Cells.Add(PlasmaUnit)
			Loop
			Dim PlasmaUnit As PlasmaCell = MakePlasmaCell(20)
			Layer.Cells.Add(PlasmaUnit)
			Layer.Start = -PlasmaUnit.Height
			Plasma.Add(Layer)
			PlasmaLayers = PlasmaLayers - 1
		Loop
		LCARSeffects2.InitOvals
	End If
End Sub
Sub MakePlasmaCell(Maximum As Int) As PlasmaCell
	Dim PlasmaUnit As PlasmaCell
	PlasmaUnit.Initialize
	If Maximum < 10 Then 
		PlasmaUnit.Height = Maximum
	Else 
		PlasmaUnit.Height = Rnd(1, Min(Maximum, 20))
	End If
	PlasmaUnit.Width.Initialize
	PlasmaUnit.Width.Current = Rnd(1,100)
	PlasmaUnit.Width.Desired = Rnd(1,100)
	Return PlasmaUnit
End Sub
Sub IncrementPlasma As Boolean 
	Dim temp As Int, LayerID As Int, Layer As PlasmaLayer, Speed As Int = 1', SpeedFactor As Int = 2
	MakePlasma
	For LayerID = 0 To Plasma.Size - 1 
		Layer = Plasma.Get(LayerID)
		For temp = 0 To Layer.Cells.Size - 1 
			Dim Cell As PlasmaCell = Layer.Cells.Get(temp)
			Cell.Width.Current = LCAR.Increment(Cell.Width.Current, 5, Cell.Width.Desired)
			If Cell.Width.Desired = Cell.Width.Current Then Cell.Width.Desired = Rnd(1,100)
		Next 
		Layer.Start = Layer.Start + Speed 
		If Layer.Start > -1 Then 
			Dim PlasmaUnit As PlasmaCell = MakePlasmaCell(20)
			Layer.Cells.Add(PlasmaUnit)
			Layer.Start = Layer.Start - PlasmaUnit.Height
		End If
		Speed = Speed +1'* SpeedFactor
	Next
	
	Speed=1
	LCARSeffects2.TweenOval(0,Speed)
	LCARSeffects2.TweenOval(1,Speed)
	Return True 
End Sub
Sub DrawPlasmaAll(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int)
	Dim Width2 As Int = Width * 0.5, Color As Int = LCAR.GetColor(ColorID, False, Alpha * 0.5)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	DrawPlasma(BG,X+Width2*0.5,Y,Width2,Height, Color)
	LCARSeffects2.DrawBIGBrackets(BG,X,Y,Width,Height, 60, LCAR.LCAR_TNG)
	BG.RemoveClip
End Sub
Sub DrawPlasma(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int)
	Dim temp As Int, LayerID As Int, Layer As PlasmaLayer, Y2 As Int, Center As Int = X + Width * 0.5
	MakePlasma
	For LayerID = 0 To Plasma.Size - 1
		Layer = Plasma.Get(LayerID)
		Y2 = Y + Height - (Height * Layer.Start * 0.01)
		For temp = Layer.Cells.Size - 1 To 0 Step -1
			Dim Cell As PlasmaCell = Layer.Cells.Get(temp), CellHeight As Int = Height * Cell.Height * 0.01, CellWidth As Int = Width * Cell.Width.Current * 0.01
			Y2=Y2 - CellHeight
			DrawOval(BG, Center - CellWidth * 0.5, Y2, CellWidth, CellHeight, Color, 0)
		Next
	Next
End Sub







Sub Init_Borg
	Dim Circles As Int = 15, Crosshairs As Int = 5, Nodes As Int = 5*2, BorgCount As Int = Circles + Crosshairs + Nodes, PrevColor As Int = LCAR.LCAR_Orange, PrevType As Int = 0
	BorgCircles.Initialize
	Do Until BorgCount=0
		Dim cBorg As BORG_Circle
		cBorg.Initialize
		cBorg.X = Rnd(0,100) * 0.01
		cBorg.Y = Rnd(0,100) * 0.01
		If Circles > 0 Then 
			Circles=Circles-1
		else if Crosshairs > 0 Then 
			Crosshairs=Crosshairs-1
			cBorg.cType = 1	
		else if Nodes > 0 Then 
			Nodes= Nodes - 1
			cBorg.cType = 2 + PrevType
			PrevType = 1 - PrevType
		End If
		Select Case cBorg.cType
			Case 0'circle
				cBorg.Radius = Rnd(5,15) * 0.01
				cBorg.Value1 = Rnd(0,10)*5
				cBorg.Value2 = 50 + Rnd(0,10)*5
				cBorg.Value = Rnd(cBorg.Value1, cBorg.Value2)
			Case 1'crosshairs
				cBorg.Value1 = Rnd(0,1000)
				cBorg.Value2 = Rnd(0,1000)
				cBorg.Value = API.IIF(PrevColor = LCAR.LCAR_Orange, LCAR.BORG_Color, LCAR.LCAR_Orange)
				PrevColor = cBorg.Value
			Case 2,3'nodes
				cBorg.Radius = Rnd(5,10) * 0.01
				cBorg.Value1 = Rnd(0,100)
				cBorg.Value2 = Rnd(0,100) 
				cBorg.Value3 = Rnd(0,100) 
				cBorg.Value4 = Rnd(0,100) 
				cBorg.Value5 = Rnd(0,100) 
				
				cBorg.Value = Rnd(0,16) 
		End Select
		BorgCircles.Add(cBorg)
		BorgCount=BorgCount-1
	Loop
End Sub
Sub IncrementBorg(Element As LCARelement) As Boolean 
	Dim temp As Int, cBorg As BORG_Circle, temp2 As Int, Speed As Int, tempstr As StringBuilder
	For temp = 0 To BorgCircles.Size - 1
		cBorg = BorgCircles.Get(temp)
		Select Case cBorg.cType
			Case 0'circle
				Speed=5
				If cBorg.Value3 = 0 Then 
					cBorg.Value = cBorg.Value + Speed
					If cBorg.Value > cBorg.Value2 Then cBorg.Value3 = 1
				Else 
					cBorg.Value = cBorg.Value - Speed
					If cBorg.Value < cBorg.Value1 Then cBorg.Value3 = 0
				End If 
			Case 1'crosshairs
				Speed=5
				temp2 = LCAR.Increment(cBorg.X*1000, Speed, cBorg.Value1)
				If temp2=cBorg.Value1 Then cBorg.Value1 = Rnd(0,1000)
				cBorg.X = temp2 * 0.001
				temp2 = LCAR.Increment(cBorg.Y*1000, Speed, cBorg.Value2)
				If temp2=cBorg.Value2 Then cBorg.Value2 = Rnd(0,1000)
				cBorg.Y = temp2 * 0.001
				'Log(temp & " " & cBorg)
			Case 2'nodes
				cBorg.Value = (cBorg.Value + 1) Mod 16
		End Select 
	Next
	temp=DateTime.GetSecond(DateTime.Now)
	If Element.LWidth <> temp Or Element.SideText.Length = 0 Then 
		Element.LWidth = temp
		Speed = 3
		tempstr.Initialize
		For temp = 0 To 5
			For temp2 = 1 To Speed 
				tempstr.Append(Rnd(0,10))
			Next 
			tempstr.Append(CRLF)
		Next
		Element.SideText = tempstr.ToString
	End If
	Return True 
End Sub
Sub DrawBORG(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Text As String, SideText As String)
	Dim temp As Int, cBorg As BORG_Circle, Size As Int = Min(Width,Height), X2 As Int, Y2 As Int, Radius As Int, Color As Int = LCAR.GetColor(LCAR.BORG_Color, False, Alpha), Color2 As Int
	Dim CrossSize As Int = Size * 0.10, Right As Int = X + Width, Bottom As Int = Y+ Height, Stroke As Int = 8, PrevPoint(3) As Int, BorgColors(16) As Int
	For temp = 0 To BorgColors.Length- 1
		BorgColors(BorgColors.Length -1 - temp) = LCAR.GetColor(LCAR.BORG_Color, False, Max(temp*-16,-255))
	Next
	For temp = 0 To BorgCircles.Size - 1
		cBorg = BorgCircles.Get(temp)
		Radius = cBorg.Radius * Size 
		X2 = X + Min(Max(cBorg.X * Width, Radius), Width-Radius)
		Y2 = Y + Min(Max(cBorg.Y * Height , Radius), Height-Radius)
		Select Case cBorg.cType
			Case 0'gradient
				Wireframe.CircleGradient(BG, X2, Y2, Radius * cBorg.Value * 0.01, Color, Colors.Black)
			Case 1'crosshairs
				Color2 = LCAR.GetColor(cBorg.Value, False, Alpha*0.5)
				BG.DrawLine(X,Y2,Right,Y2, Color2,1)
				BG.DrawLine(X2,Y,X2,Bottom, Color2,1)
				BG.DrawLine(Max(X2-CrossSize,X), Y2, Min(X2+CrossSize, Right), Y2, Color2, Stroke)
				BG.DrawLine(X2, Max(Y2-CrossSize,Y),X2,Min(Y2+CrossSize,Bottom), Color2, Stroke)
			Case 2'begin node
				PrevPoint(0) = X2
				PrevPoint(1) = Y2
				PrevPoint(2) = Radius
			Case 3'end node
				DrawBORGnode(BG,X,Y,Width,Height, Alpha, BorgCircles.Get(temp-1), PrevPoint(0), PrevPoint(1),PrevPoint(2), cBorg, X2,Y2,Radius, Color, BorgColors, Stroke)
		End Select
	Next
	
	Color = LCAR.GetColor(LCAR.Classic_Blue, False, Alpha)
	API.DrawText(BG,SideText, X+Width*0.75, Bottom,LCAR.BorgFont, LCAR.Fontsize*2, Color, -1)
End Sub
Sub DrawBORGnode(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Previous As BORG_Circle, PrevX As Int, PrevY As Int, PrevRadius As Int, Current As BORG_Circle, CurrX As Int, CurrY As Int, CurrRadius As Int, Color As Int, BorgColors() As Int, Radius As Int)
	Dim X2 As Int = X + (Previous.Value1 * 0.01 * Width), Y2 As Int = Y + (Previous.Value2 * 0.01 * Height), X3 As Int = X + (Current.Value1 * 0.01 * Width), Y3 As Int = Y + (Current.Value2 * 0.01 * Height)
	Dim X4 As Int = X + (Previous.Value3 * 0.01 * Width), Y4 As Int = Y + (Previous.Value4 * 0.01 * Height), X5 As Int = X + (Current.Value3 * 0.01 * Width), Y5 As Int = Y + (Current.Value4 * 0.01 * Height)
	Dim X6 As Int = X + (Previous.Value5 * 0.01 * Width), Y6 As Int = Y + (Current.Value5 * 0.01 * Height), CurveDT As Float = 0.005
	Dim CurrP As Point, Points As List, temp As Int, CurrentColor As Int = Previous.Value'use Bicubic2 to get a list of points instead of a path
	
	Wireframe.Bicubic2(Points, PrevX,PrevY, X2,Y2, 		X4,Y4, X5,Y5, CurveDT)
	Wireframe.Bicubic2(Points, X4,Y4,X6,Y6,      		CurrX,CurrY, X3,Y3, CurveDT)
	
	For temp = 0 To Points.Size - 1 
		CurrP = Points.Get(temp)
		BG.DrawCircle(CurrP.X, CurrP.Y, Radius, BorgColors(CurrentColor), True, 0)
		CurrentColor = (CurrentColor+ 1) Mod BorgColors.Length
	Next
	
	DrawBORGnodeCircle(BG, PrevX, PrevY, PrevRadius, Color, Points, 4, Previous.Value)
	DrawBORGnodeCircle(BG, CurrX, CurrY, CurrRadius, Color, Points, Points.Size-5, CurrentColor)
End Sub
Sub DrawBORGnodeCircle(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Points As List, ID As Int, Value As Int)
	Dim Pt As Point = Points.Get(ID), Angle As Int = (Trig.GetCorrectAngle(X,Y, Pt.X, Pt.Y)+180) Mod 360, Distance As Int, Offset As Point, Offset2 As Point, Offset3 As Point 
	Dim X2 As Int, Y2 As Int, P As Path 
	BG.DrawCircle(X, Y, Radius, Color, False, 5)
	
	If ID > 16 Then Value = 15-Value
	Distance = (Radius*2*Value*0.0625)-Radius
	
	Offset = Trig.FindAnglePoint( X,Y, Distance, Angle)
	Offset2 = Trig.FindAnglePoint(0, 0, Radius, (Angle+90) Mod 360)
	Offset3 = Trig.FindAnglePoint(0,0, Radius*2, Angle)

	X2=Offset.X+Offset2.X
	Y2=Offset.Y+Offset2.Y
	P.Initialize(X2,Y2)
	P.LineTo(X2+Offset3.X, Y2+Offset3.Y) 
	X2=Offset.X-Offset2.X
	Y2=Offset.Y-Offset2.Y
	P.LineTo(X2+Offset3.X, Y2+Offset3.Y)
	P.LineTo(X2, Y2)
	BG.ClipPath(P)
	
	BG.DrawCircle(X, Y, Radius*0.2, Color, True, 0)
	BG.DrawCircle(X, Y, Radius*0.6, Color, False, Radius*0.4)
	
	BG.RemoveClip
End Sub