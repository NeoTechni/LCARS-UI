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

	Dim Dots As List, MaxDots As Int = 6, CardyColors(6) As Byte, LastDrawnAt As Byte = -1,PreviousMode As Int ,CardyCache As List 
	
	'Type RomPoint(rf As Float, ri As Int)
	Dim RomX As List, RomY As List, ROM_Beige As Int = Colors.rgb(199, 161, 148), ROM_LightBlue As Int = Colors.rgb(13, 165, 176), ROM_DarkBlue As Int = Colors.rgb(4, 137, 146), ROM_Green As Int = Colors.rgb(4, 118, 84)
	Dim Rom_Fontsize As Int , Rom_FontsizeP As Int , ROM_LastUpdate As Int=-1, ROM_Texts As List , ROM_Angle As Int 
	
	'Tactical stuff
	Type TacStarship(X As Int, Y As Int, Name As String, Serial As String, Alpha As Int, Cloaked As Boolean, Velocity As Int, Angle As Int, RedAlert As Boolean, PhaserRecharge As Int, TorpedoRecharge As Int, Target As Point, Shields As Int)
	Type TacBattleGroup(Name As String, Prepend As String, Faction As Int, Ships As List, MaxShips As Int, HasCloak As Boolean, FollowFlagship As Boolean )
	Dim BattleGroups As List , PhaserRechargeTime As Int=20, TorpedoRechargeTime As Int=50, TacPlanet As Int = 9999, TacMaxWidth As Int = 500, TacMaxHeight As Int = 100
	Dim PhaserDamage As Int = 5, TorpedoDamage As Int = 10, SensorRange As Int = 50, EnemyShips As Int, AlliedShips As Int 
	
	'Qnet stuff
	Dim Q_Angles(3) As TweenAlpha, Q_BMP As Bitmap, Q_Stars As List 
	
	'Sheliak stuff
	Type SheliakChar(Index As Int, FlipX As Boolean, FlipY As Boolean, Color1 As Int, Color2 As Int)
	Type SheliakString(Chars As List, X As Int, Y As Int, Speed As Int, Size As Int, Alpha As Int)
	Dim Sheliak As List, SheliakStrings As List, ShowText As Boolean, S_CurrentLine As Int= -1, S_Lines As Int, S_Text() As String, S_Width As Int, S_LastUpdate As Long 
	
	'WARP FIELD stuff
	Dim WF_RND_ID As Int 
	
	'CARDY STUFF
	Dim CRD_LastUpdate As Long, GIFloaded As Boolean 
End Sub

Sub SetUpSheliak(Strings As Int)
	If Not(Sheliak.IsInitialized) Then
		Sheliak.Initialize
		Sheliak.Add(Array As Double(0.0125,0.475,0.25,0,0.475,0,0.475,0.175,0.4,0.175,0.25,0.475,-1,0,0.525,0.175,0.525,0,0.75,0,0.9875,0.475,0.75,0.475,0.6,0.175,-1,0,0.75,0.525,0.9875,0.525,0.75,1,0.525,1,0.525,0.825,0.6,0.825,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.9875,0.475,0.75,0,0.25,0,0.15,0.2,0.25,0.2,0.3,0.1,0.7,0.1,0.8125,0.325,0.0875,0.325,-1,0,0.9875,0.525,0.825,0.525,0.6875,0.8,0.4125,0.8,0.4125,0.675,0.0875,0.675,0.25,1,0.75,1,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.9875,0.475,0.75,0,0.625,0,0.8125,0.375,0.1625,0.375,0.35,0,0.25,0,-1,0,0.0125,0.525,0.9875,0.525,0.75,1,0.4,1,0.55,0.7,0.1875,0.7,0.3375,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0,0.5,0.1125,0.275,0.35,0.275,0.4625,0.5,0.35,0.725,0.1125,0.725,-1,0,1,0.5,0.8875,0.275,0.65,0.275,0.5375,0.5,0.65,0.725,0.8875,0.725,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.3,0.475,0.375,0.325,0.8,0.325,0.875,0.475,0.9875,0.475,0.75,0,0.25,0,-1,0,0.0125,0.525,0.9875,0.525,0.75,1,0.65,1,0.8125,0.675,0.375,0.675,0.5375,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.9875,0.475,0.75,0,0.25,0,-1,0,0.0125,0.525,0.9875,0.525,0.75,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.55,0.475,0.6125,0.35,0.925,0.35,0.75,0,0.65,0,0.775,0.25,0.125,0.25,-1,0,0.075,0.65,0.825,0.65,0.8875,0.525,0.9875,0.525,0.8625,0.775,0.6625,0.775,0.55,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.025,0.45,0.25,0,0.3,0,0.4625,0.325,0.525,0.325,0.6875,0,0.75,0,0.975,0.45,-1,0,0,0.5,1,0.5,0.95,0.6,0.4875,0.6,0.2875,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.475,0.175,0.475,0.3,0.225,0.55,0.225,0.6625,0,0.25,0,-1,0,0.0125,0.525,0.175,0.525,0.325,0.825,0.8375,0.825,0.75,1,0.25,1,-1,0,0.475,0.5125,0.6,0.7,0.7125,0.5125,-1,0,0.75,0.475,0.9875,0.475,0.86875,0.2375,-1,0))
		Sheliak.Add(Array As Double(1,0.5,0.9125,0.675,0.64375,0.2,0.74375,0,-1,0,0.75,1,0.625,0.75,0.375,0.75,0.23125,0.4625,0.36875,0.225,0.25625,0,0.00625,0.5,0.125,0.5,0.3125,0.875,0.1875,0.875,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.0875,0.325,0.6625,0.325,0.5,0,0.25,0,-1,0,0.4,0.375,0.35,0.475,0.9875,0.475,0.75,0,0.65,0,0.8375,0.375,-1,0,0,0.5,0.15,0.5,0.2875,0.775,0.4625,0.775,0.6,0.5,0.7875,0.5,0.65,0.775,0.8625,0.775,0.75,1,0.25,1,-1,0))
		Sheliak.Add(Array As Double(0.025,0.45,0.975,0.45,0.75,0,0.25,0,0.1625,0.175,0.25,0.175,0.3,0.075,0.675,0.075,0.775,0.275,0.1125,0.275,-1,0,0.25,1,0.1625,0.825,0.1875,0.775,0.3625,0.775,0.225,0.5,0.4125,0.5,0.55,0.775,0.7,0.775,0.8375,0.5,1,0.5,0.75,1,-1,0))
		Sheliak.Add(Array As Double(0.0125,0.525,0.175,0.525,0.3375,0.85,0.825,0.85,0.75,1,0.25,1,-1,0,0.9875,0.475,0.7875,0.475,0.625,0.15,0.525,0.15,0.525,0,0.75,0,-1,0,0.475,0.5,0.7125,0.5,0.5875,0.7,-1,0,0.0125,0.475,0.175,0.475,0.3375,0.15,0.425,0.15,0.425,0,0.25,0,-1,0))
		SheliakStrings.Initialize
		Do Until Strings < 1
			MakeSheliak (0, -1)
			Strings = Strings -1
		Loop
	End If
End Sub

Sub MakeSheliak(Digits As Int, Index As Int)
	Dim SS As SheliakString, PrevChar As Int = -1
	If Digits = 0 Then Digits = Rnd(5,13)
	SS.Initialize
	SS.Size = Rnd(5,11)
	SS.Speed = Rnd(1,5)
	SS.Alpha = Min(Rnd(6,16)*16, 255)
	If Index = -1 Then SS.X = Rnd(0,100) Else SS.X = 100
	SS.Y = Rnd(5,95)
	SS.Chars.Initialize
	Do Until Digits = 0 
		Dim sChar As SheliakChar
		sChar.Initialize
		sChar.Index  = PrevChar
		Do While sChar.Index = PrevChar
			sChar.Index  = Rnd(-1, Sheliak.Size)
		Loop 
		If Rnd(0,100) > 50 Then sChar.FlipX = True 
		If Rnd(0,100) > 50 Then sChar.FlipY = True 
		sChar.Color1 = RandomSheliakColor 
		sChar.Color2 = RandomSheliakColor
		Do While sChar.Color1 = sChar.Color2
			sChar.Color2 = RandomSheliakColor
		Loop 
		SS.Chars.Add(sChar)
		Digits = Digits - 1 
		PrevChar = sChar.Index
	Loop
	If Index = -1 Then 
		SheliakStrings.Add(SS)
	Else 
		SheliakStrings.Set(Index, SS)
	End If 
End Sub

Sub RandomSheliakColor As Int 
	Select Case Rnd(0, 6)
		Case 0: Return LCAR.LCAR_Yellow			'Colors.RGB(180,255,161)'yellow
		Case 1: Return LCAR.Classic_Turq		'Colors.rgb(142,228,201)'light green
		Case 2: Return LCAR.Classic_Green		'Colors.rgb(104,186,104)'dark green
		Case 3: Return LCAR.Classic_Blue		'Colors.rgb(38,70,157)'blue
		Case 4: Return LCAR.LCAR_Blue			'Colors.rgb(94,93,173)'purple
		Case 5: Return LCAR.Classic_LightBlue 	'Colors.rgb(134,242,254)'teal
	End Select 
End Sub

Sub DrawSheliak(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, FlipX As Boolean, FlipY As Boolean, Index As Int, Color1 As Int, Color2 As Int, Alpha As Int)
	Dim IsEven As Boolean, temp As Int, Character() As Double = Sheliak.Get(Index), temp2 As Int, P As Path,NeedsInit As Boolean, Color As Int 
	If Index =-1 Then Return 
	If FlipX Then 
		X=X+Width
		Width = Width*-1
	End If
	If FlipY Then 
		Y=Y+Height
		Height=Height*-1
	End If
	AddSheliakPoint(P, X, Y, Width, Height, Character, 0, True)
	For temp = 2 To Character.Length-1 Step 2
		temp2 = Character(temp)
		If temp2 = -1 Then 
			Color = LCAR.GetColor(API.IIF(IsEven, Color2,Color1), False, Alpha)
			BG.DrawPath(P, Color, True, 0)
			IsEven=Not(IsEven)
			NeedsInit=True 
		Else
			AddSheliakPoint (P, X, Y, Width, Height, Character, temp, NeedsInit)
			NeedsInit=False 
		End If
	Next
End Sub

Sub AddSheliakPoint(P As Path, X As Int, Y As Int, Width As Int, Height As Int, Character() As Double, Index As Int, IsFirst As Boolean)
	X = X + Character(Index) * Width 
	Y = Y + Character(Index+1) * Height
	If IsFirst Or Not(P.IsInitialized) Then 
		P.Initialize(X,Y)
	Else 
		P.LineTo(X,Y)
	End If
End Sub

Sub DrawFederationContract(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SubtractLines As Int)
	Dim Temp As Int, LineHeight As Int = BG.MeasureStringHeight("ABC[](),", LCAR.LCARfont, LCAR.Fontsize) + LCAR.ListitemWhiteSpace, Lines As Int = Height / LineHeight - SubtractLines, MaxHeight As Int = Y+Height - LineHeight*SubtractLines
	'S_CurrentLine As Int, S_Lines As Int, S_LastUpdate
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	If S_Width <> Width Then 
		S_Text = Regex.Split(CRLF,  API.TextWrap(BG, LCAR.LCARfont,  LCAR.Fontsize, File.ReadString(File.DirAssets, "armens.txt"), Width))
		S_Width = Width 
	End If
	If S_CurrentLine >= S_Text.Length Then 
		S_CurrentLine = -1
		S_Lines=0
	Else 
		For Temp = S_CurrentLine To S_CurrentLine + S_Lines
			If Temp > -1 And Temp < S_Text.Length And Y+LineHeight < MaxHeight Then 
				If Not( S_Text(Temp).StartsWith("%N%")) Then 
					LCAR.DrawTextbox(BG, S_Text(Temp), LCAR.LCAR_LightPurple,  X, Y,  0,0,  7)
				End If 
			End If
			Y=Y+LineHeight
		Next
		If S_Lines > S_CurrentLine + Lines + 10 Then 
			S_CurrentLine = S_CurrentLine + Lines 
			S_Lines=0
		End If 
	End If
	BG.RemoveClip
End Sub

Sub DrawSheliakContract(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim Y2 As Int = Y+Height-LCAR.ItemHeight, Y3 As Int 
	If Not(SheliakStrings.IsInitialized) Then IncrementSheliak
	If ShowText Then 
		Y3 = Height*0.5
		DrawFederationContract(BG, X+LCAR.leftside, Y+LCAR.ItemHeight+LCAR.ListitemWhiteSpace,  Width - LCAR.leftside*2, Y3 - LCAR.ListitemWhiteSpace*3, 2)
		DrawSheliakStrings(BG, X,Y+Y3+ 10+LCAR.ListitemWhiteSpace, Width, Y3 - LCAR.ListitemWhiteSpace*2)
		LCAR.DrawTextbox(BG, "ENGLISH LANGUAGE VERSION (UNITED FEDERATION OF PLANETS)", LCAR.LCAR_LightPurple,  X+Width-LCAR.leftside, Y+ Y3 - 10 - LCAR.ListitemWhiteSpace*2, 0,0, 9)
		LCAR.DrawTextbox(BG, "SHELIAK LANGUAGE VERSION (SHELIAK CORPORATE)", LCAR.LCAR_LightPurple,  X+Width-LCAR.leftside, Y2 - LCAR.ListitemWhiteSpace*2, 0,0,9)
		LCARSeffects4.DrawRect(BG, X+  LCAR.leftside, Y+Y3-10, Width-LCAR.leftside*2, 20, LCAR.GetColor(LCAR.LCAR_Purple, False, 255), 0)
	Else 
		DrawSheliakStrings(BG, X,Y+LCAR.ItemHeight+ LCAR.ListitemWhiteSpace, Width, Height - LCAR.ItemHeight*2 - LCAR.ListitemWhiteSpace*2)
	End If
	LCARSeffects4.DrawRect(BG,X,Y,Width,LCAR.ItemHeight+LCAR.ListitemWhiteSpace, LCAR.LCAR_Black, 0)
	LCARSeffects4.DrawRect(BG,X,Y2-LCAR.ListitemWhiteSpace,Width,LCAR.ItemHeight+LCAR.ListitemWhiteSpace, LCAR.LCAR_Black, 0)
	LCARSeffects2.DrawTextButton(BG,X,Y,Width,LCAR.LCAR_LightYellow,LCAR.LCAR_LightOrange,LCAR.LCAR_LightYellow, 255,False,  "FILE 337-02 TREATY OF ARMENS", LCAR.LCAR_Orange, False, True,False) 
	LCARSeffects2.DrawTextButton(BG,X,Y2,Width, LCAR.LCAR_LightBlue,LCAR.LCAR_LightOrange,LCAR.LCAR_Orange, 255,False, "", LCAR.LCAR_LightOrange, True, True,False) 
End Sub

Sub DrawSheliakStrings(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int, SS As SheliakString, X2 As Int, Y2 As Int, Size As Int, temp2 As Int, WhiteSpace As Int = 2, sChar As SheliakChar 
	For temp = 0 To SheliakStrings.Size - 1 
		SS = SheliakStrings.Get(temp)
		X2 = X + Width * (SS.X * 0.01)
		Y2 = Y + Height * (SS.Y * 0.01)
		Size = Min(Width,Height) * (SS.Size * 0.01)
		For temp2 = 0 To SS.Chars.Size - 1
			sChar = SS.Chars.Get(temp2)
			If X2 + Size > X And X2 < X + Width And sChar.Index > -1 Then 
				DrawSheliak(BG, X2,Y2, Size,Size, sChar.FlipX, sChar.FlipY, sChar.Index, sChar.Color1, sChar.Color2, SS.Alpha)
			End If
			X2 = X2 + Size + WhiteSpace
		Next 
	Next
End Sub

Sub IncrementSheliak As Boolean 
	Dim temp As Int, SS As SheliakString
	If Not(SheliakStrings.IsInitialized) Then 
		SetUpSheliak(15)
		S_LastUpdate = DateTime.Now 
	Else 
		For temp = 0 To SheliakStrings.Size - 1 
			SS = SheliakStrings.Get(temp)
			SS.X = SS.X - SS.Speed 
			If SS.X < 0 Then 
				If SS.X + (SS.Size * SS.Chars.Size) <= 0 Then 
					MakeSheliak (0, temp)
				End If
			End If 
		Next
		If ShowText And S_LastUpdate < DateTime.Now - DateTime.TicksPerSecond*0.1 Then 
			S_Lines = S_Lines+ 1
			S_LastUpdate = DateTime.Now 
		End If
	End If
	Return True 
End Sub










Sub RandomizeCardyColors
	Dim temp As Int , temp2 As Int, temp3 As Int,temp4 As Int, MaxColors As Int = CardyColor(-4, 0)
	If LastDrawnAt = -1  Then
		For temp = 0 To CardyColors.Length -1
			CardyColors(temp)= Rnd(1,MaxColors)
			If temp>0 Then
				Do While CardyColors(temp)=CardyColors(temp-1)'reduce touching colors
					CardyColors(temp)= Rnd(1,MaxColors)
				Loop
			End If
		Next
		LastDrawnAt = DateTime.GetSecond(DateTime.Now)
	Else If LastDrawnAt <> DateTime.GetSecond(DateTime.Now) Then
		temp = Rnd(0, CardyColors.Length)
		temp2= Rnd(1,MaxColors)
		temp3 = temp+1 
		If temp3 = CardyColors.Length Then temp3=0'reduce touching colors
		temp4= temp-1
		If temp4<0 Then temp4 = CardyColors.Length-1
		Do While temp2 = CardyColors(temp) Or temp2 = CardyColors(temp3) Or temp2 = CardyColors(temp4)
			temp2= Rnd(1,MaxColors)
		Loop
		CardyColors(temp) = temp2
		LastDrawnAt = DateTime.GetSecond(DateTime.Now)
	End If
End Sub
Sub DrawShatterglass(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Mode As Int)
	Dim MaxRadius As Int = Min(Width,Height)*0.5, CenterX As Int = X + Width*0.5, CenterY As Int = Y + Height*0.5, R2 As Int = MaxRadius*2, temp As Int ,P As Path, Gray As Int = CardyColor(-2,128), DrawCardy As Boolean
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Colors.black, 0)
	DrawCardy = DrawCardyMode(BG, CenterX, CenterY, MaxRadius, Mode, True)
		
	RandomizeCardyColors	
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,0), MaxRadius*-0.95, MaxRadius, Array As Int(0,50))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,0), MaxRadius*-1.00, MaxRadius, Array As Int(50,90))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,1), MaxRadius*-1.00, MaxRadius, Array As Int(90,130))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,1), MaxRadius*-0.85, MaxRadius, Array As Int(130,135))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,2), MaxRadius*-1.00, MaxRadius, Array As Int(180,220))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,2), MaxRadius*-0.95, MaxRadius, Array As Int(220,270))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,3), MaxRadius*-0.95, MaxRadius, Array As Int(270,290))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,4), MaxRadius*-0.95, MaxRadius, Array As Int(290,315))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, CardyColor(-3,5), MaxRadius*-0.95, MaxRadius, Array As Int(315,360))
	If Width>Height Then
		temp=Width*0.5-MaxRadius
		LCARSeffects4.DrawRect(BG,X,Y, temp, Height, Colors.Black,0)
		LCARSeffects4.DrawRect(BG,X+Width-temp,Y, temp, Height, Colors.Black,0)
	Else
		temp=Height*0.5-MaxRadius
		LCARSeffects4.DrawRect(BG,X,Y, Width,temp,Colors.Black,0)
		LCARSeffects4.DrawRect(BG,X,Y+Height-temp, Width,temp,Colors.Black,0)
	End If
	
	'block 1 (up)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Colors.Gray, MaxRadius*0.95, 4, Array As Int(0,50, 220,245, 245,290, 290,360))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.75,4, Array As Int(0,50))
	
	'block 2 (right)
	DrawLine(BG, CenterX,CenterY, 50, MaxRadius*0.55, MaxRadius*1.00, Gray, 4)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.55,4, Array As Int(50,130))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Colors.Gray, MaxRadius*1.00,4, Array As Int(50,130))
	DrawLine(BG, CenterX,CenterY, 130, MaxRadius*0.55, MaxRadius*1.00, Gray, 4)
	
	'block 3 (small segments, down right)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.65,4, Array As Int(130,140))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.75,4, Array As Int(130,140))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Colors.Gray, MaxRadius*0.85,4, Array As Int(130,140))
	
	'block 4 (down)
	DrawLine(BG, CenterX,CenterY, 140, MaxRadius*0.55, MaxRadius*1.00, Gray, 4)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.55,4, Array As Int(140,220))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Colors.Gray, MaxRadius*1.00,4, Array As Int(140,220))
	DrawLine(BG, CenterX,CenterY, 220, MaxRadius*0.55, MaxRadius*1.00, Gray, 4)
	
	'block 5 (left)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.65,16, Array As Int(220,245, 245,290, 290,360))'220 to 360 THICK
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.75,4, Array As Int(220,270))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, R2, Gray, MaxRadius*0.85,4, Array As Int(270,300, 300,330, 330,360))'270 to 360
	DrawLine(BG, CenterX,CenterY, 0, MaxRadius*0.65, MaxRadius*0.85, Gray, 4)	
	
	DrawDots(BG, CenterX,CenterY, MaxRadius, Gray,16)
	
	'extra lines
	LCARSeffects.MakeClipPath(BG,CenterX-MaxRadius,CenterY-MaxRadius,R2,R2)
		DrawLine(BG, CenterX,CenterY, 0, MaxRadius*0.95, MaxRadius*1.50, Colors.Gray, 4)'block 1
		DrawLine(BG, CenterX,CenterY, 65, MaxRadius*1.00, MaxRadius*1.50, Colors.Gray, 4)'block 2
		DrawLine(BG, CenterX,CenterY, 135, MaxRadius*0.65, MaxRadius*1.5, Colors.Gray, 4)'block 3
		DrawLine(BG, CenterX,CenterY, 270, MaxRadius*0.65, MaxRadius*1.5, Colors.Gray, 4)'block 5a	
		DrawLine(BG, CenterX,CenterY, 280, MaxRadius*0.85, MaxRadius*1.5, Colors.Gray, 4)'block 5b	
		DrawLine(BG, CenterX,CenterY, 290, MaxRadius*0.95, MaxRadius*1.50, Colors.Gray, 4)'block 5c
		DrawLine(BG, CenterX,CenterY, 315, MaxRadius*0.95, MaxRadius*1.50, Colors.Gray, 4)'block 5d
		If DrawCardy Then DrawCardyMode(BG, CenterX, CenterY, MaxRadius, Mode, True)
	BG.RemoveClip
	
	'borders
	LCARSeffects.MakeClipPath(BG,CenterX-MaxRadius-temp*2,CenterY-MaxRadius-temp*2,R2+temp*3,R2+temp*3)
		temp=8
		CenterX=CenterX-MaxRadius
		CenterY=CenterY-MaxRadius
	'top
	BG.DrawLine(CenterX, CenterY, CenterX+R2-MaxRadius*0.6, CenterY, Colors.Gray, 16)
		P.Initialize (CenterX+R2-MaxRadius*0.6, CenterY)
		P.LineTo(CenterX+R2, CenterY+MaxRadius*0.4)
		P.LineTo(CenterX+R2, CenterY)
		P.LineTo(CenterX+R2-MaxRadius*0.6, CenterY)
		BG.DrawPath(P, Colors.black, True,0)
		BG.DrawLine(CenterX+R2-MaxRadius*0.6-temp, CenterY, CenterX+R2+temp*2, CenterY+MaxRadius*0.4+temp, Colors.Gray, 16)
	BG.RemoveClip
	LCARSeffects4.DrawRect(BG, CenterX+R2+temp*2, CenterY, 10, R2, Colors.Black, 0)'cover up edge
	
	If Height>Width Then
		'bottom 
		BG.DrawLine(CenterX-temp, CenterY+R2+temp, CenterX+MaxRadius*1.2, CenterY+R2+temp, Colors.Gray, 16)
		BG.DrawLine(CenterX+MaxRadius*1.4, CenterY+R2+temp, CenterX+R2+temp, CenterY+R2+temp, Colors.Gray, 16)
	
		Gray=Height*0.5 - MaxRadius
		'down/left
		BG.DrawLine(CenterX+MaxRadius*1.2, CenterY+R2, CenterX+MaxRadius*1.3, CenterY+R2+(Gray*0.5), Colors.Gray, 16)
		BG.DrawLine(CenterX+MaxRadius*1.3+temp, CenterY+R2+(Gray*0.5)-temp, CenterX, Y+Height, Colors.Gray, 16)
		'down right
		BG.DrawLine(CenterX+MaxRadius*1.4, CenterY+R2, CenterX+MaxRadius*1.5, CenterY+R2+(Gray*0.5), Colors.Gray, 16)
		BG.DrawLine(CenterX+MaxRadius*1.5-temp, CenterY+R2+(Gray*0.5)-temp, X+Width+(Gray*0.5), Y+Height, Colors.Gray, 16)
		
		BG.DrawLine(X+Height-temp, CenterY+MaxRadius*0.5,  CenterX+MaxRadius  , Y-Gray, Colors.Gray, 16)
	Else
		'left
		BG.DrawLine(CenterX-temp, CenterY-temp, CenterX-temp, CenterY+MaxRadius*0.2, Colors.Gray, 16)
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*0.2-temp, X, CenterY+MaxRadius*0.1-temp, Colors.Gray, 16)'out
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*0.4+temp, X, CenterY+MaxRadius*0.3+temp, Colors.Gray, 16)'out
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*0.4, CenterX-temp, CenterY+MaxRadius*1.2, Colors.Gray, 16)
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*1.2-temp, X, CenterY+MaxRadius*1.3-temp, Colors.Gray, 16)'out
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*1.4+temp, X, CenterY+MaxRadius*1.5+temp, Colors.Gray, 16)'out
		BG.DrawLine(CenterX-temp, CenterY+MaxRadius*1.4, CenterX-temp, CenterY+MaxRadius*2, Colors.Gray, 16)	
		
		'right
		BG.DrawLine(CenterX+R2+temp, CenterY+MaxRadius*0.4, CenterX+R2+temp, CenterY+MaxRadius*0.9, Colors.Gray, 16)
		BG.DrawLine(CenterX+R2+temp, CenterY+MaxRadius*1.1, CenterX+R2+temp, CenterY+R2+temp, Colors.Gray, 16)
		
		Gray=Width*0.5 - MaxRadius
		'right/up
		BG.DrawLine(CenterX+R2+temp, CenterY+MaxRadius*0.9-temp, X+Width, CenterY+MaxRadius*0.8, Colors.Gray, 16)
		BG.DrawLine(X+Width-temp, CenterY+MaxRadius*0.8, X+Width-temp, CenterY+MaxRadius*0.5, Colors.Gray, 16)
		'right/down
		BG.DrawLine(CenterX+R2+temp, CenterY+MaxRadius*1.1+temp, X+Width, CenterY+MaxRadius*1.2, Colors.Gray, 16)
		BG.DrawLine(X+Width-temp, CenterY+MaxRadius*1.2, X+Width-temp, Y+Height, Colors.Gray, 16)
		
		BG.DrawLine(X+Width, CenterY+MaxRadius*0.5+temp,  CenterX+MaxRadius*1.2  , Y-Gray, Colors.Gray, 16)
	End If
	'return centerX/Y to center coordinates
	If DrawCardy Then DrawCardyMode(BG, CenterX+MaxRadius, CenterY+MaxRadius , MaxRadius, Mode, False)
End Sub
Sub DrawLine(BG As Canvas, X As Int, Y As Int, Angle As Int, StartRadius As Int, EndRadius As Int, Color As Int, Stroke As Int)
	BG.DrawLine( Trig.findXYAngle(X,Y,StartRadius, Angle, True), Trig.findXYAngle(X,Y,StartRadius, Angle, False), Trig.findXYAngle(X,Y,EndRadius, Angle, True), Trig.findXYAngle(X,Y,EndRadius, Angle, False), Color,Stroke)
End Sub
Sub CardyColor(Index As Int, Alpha As Int) As Int
	Select Case Index
		Case -4: Return 10'max colors
		Case -3: Return CardyColor(CardyColors(Alpha), 255)
	
		Case -2: Return Colors.ARGB(Alpha, 182, 176, 167)	'grey
		Case -1: Return Colors.Transparent 					'transparent
		
		Case 0:  Return Colors.ARGB(Alpha, 0,   0,     0)	'black
		Case 1:  Return Colors.ARGB(Alpha, 143, 141,  48)	'gold
		Case 2:  Return Colors.ARGB(Alpha, 187, 53,   30)	'light red
		Case 3:  Return Colors.ARGB(Alpha, 97,  29,   10)	'dark red
		Case 4:  Return Colors.ARGB(Alpha, 28,  217, 234)	'turquoise 
		Case 5:  Return Colors.ARGB(Alpha,  89, 215, 124)	'neon green
		Case 6:  Return Colors.ARGB(Alpha, 174, 153, 210)	'light purple
		Case 7:  Return Colors.ARGB(Alpha, 105, 130, 135)	'dark turquoise
		Case 8:  Return Colors.ARGB(Alpha, 199, 124,  63)	'dark orange
		Case 9:	 Return Colors.ARGB(Alpha, 202, 189, 128)	'dark yellow 
	End Select
End Sub
Sub SetupAndIncrementDots As Int 
	Dim temp As Int 
	If Not(Dots.IsInitialized) Then	'dots are of type tweenalpha
		Dots.Initialize 
		For temp = 1 To MaxDots
			Dim tempDot As TweenAlpha 
			tempDot.Initialize 
			tempDot.Current = Rnd(0,301)
			tempDot.Desired = Rnd(0,301)
			Dots.Add(tempDot)
		Next
	End If
	For temp = 0 To Dots.Size-1 'increment dots
		Dim tempDot As TweenAlpha = Dots.Get(temp)
		tempDot.Current = LCAR.Increment(tempDot.Current, 5, tempDot.Desired)
		If tempDot.Current = tempDot.Desired Then tempDot.Desired = Rnd(0,301)
	Next
End Sub
Sub DrawDots(BG As Canvas, CenterX As Int, CenterY As Int, MaxRadius As Int, Color As Int, Radius As Int)
	SetupAndIncrementDots
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(0),	  	220,	1.00,	0.65,	360,	0.85)'along thick left edge
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(1),		50,		0.55,	1.00,	130,	0.55)'right block
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(2),		130,	1.00,	0.65,	140,	1.00)'small segments, down right
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(3),		140,	0.55,	1.00,	220,	0.55)'bottom block
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(4),		220,	0.55,	0.95,	50,		0.55)'left/top outer edge
	DrawDot(BG,CenterX,CenterY,MaxRadius,Color,Radius,		Dots.Get(5),		270,	0.65,	0.85,	360,	0.65)'upper/left middle edge
End Sub
Sub DrawDot(BG As Canvas, CenterX As Int, CenterY As Int, MaxRadius As Int, Color As Int, Radius As Int, Dot As TweenAlpha, LeftAngle As Int, LeftStartRadius As Float, LeftEndRadius As Float, RightAngle As Int, RightEndRadius As Float) 
	Dim Angle As Int=-1, Distance As Int ,Value As Int = Dot.Current 
	If Value> 100 And Value < 200 Then
		Distance= LeftEndRadius*MaxRadius
		Value=Value-100
		If LeftAngle<RightAngle Then
			Angle = (RightAngle-LeftAngle) * (Value*0.01) + LeftAngle
		Else
			Angle = ((360-LeftAngle +RightAngle) * (Value*0.01) + LeftAngle) Mod 360
		End If
	Else
		If Value<=100 Then 
			Angle = LeftAngle 
			Distance = GetDistance(Value*0.01,LeftStartRadius,LeftEndRadius,MaxRadius)
		Else 
			Angle = RightAngle
			Distance = GetDistance((Value-200)*0.01,LeftEndRadius,RightEndRadius,MaxRadius)
		End If
	End If
	BG.DrawCircle(Trig.findXYAngle(CenterX,CenterY,Distance,Angle, True),	Trig.findXYAngle(CenterX,CenterY,Distance,Angle, False), 	Radius, Color, True, 0)
End Sub
Sub GetDistance(Value As Float, StartDistance As Float, EndDistance As Float,MaxRadius As Int) As Int 
	If StartDistance < EndDistance Then
		Return ((EndDistance-StartDistance) * Value + StartDistance) * MaxRadius
	Else
		Return ((StartDistance-EndDistance) * (1-Value) + EndDistance) * MaxRadius
	End If
End Sub

Sub SetupDS9(CurrentSection As Int, IsMain As Boolean)
	If (CurrentSection = 63 And IsMain) Or Not(IsMain) Then 
		GIFloaded = File.exists(LCAR.DirDefaultExternal, "sysds9.png")
		If GIFloaded Then LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal, "sysds9.png", LCAR.CRD_Shatter)
	End If 
End Sub
Sub IncrementCardy(Mode As Int) 
	Dim NeedsInit As Boolean = PreviousMode <> Mode, temp As Int 
	If NeedsInit Then CardyCache.Initialize 
	Select Case Mode
		Case 1'weird, green line things
			If NeedsInit Then
				CardyCache.Add( Rnd(0, 360))'0
				CardyCache.Add( Rnd(0, 360))'1
				For temp = 1 To 10 'each unit
					CardyCache.Add(CardyColor(Rnd(4,6),255))'0 color
					Dim tempAlpha As TweenAlpha , tempBeta As TweenAlpha 
					tempAlpha.Initialize 
					tempAlpha.Current = Rnd(10,110)
					tempAlpha.desired = Rnd(10,110)
					CardyCache.Add( tempAlpha)'1 (radius %*100)
					tempBeta.Initialize 
					tempBeta.Current=Rnd(0,360)
					tempBeta.Desired=Rnd(0,360)
					CardyCache.Add(tempBeta)'2 (angle)
				Next
			End If
			CardyCache.Set(0, (CardyCache.Get(0) + 15) Mod 360)'0
			temp = CardyCache.Get(1) - 15
			If temp <0 Then temp = temp+ 360
			CardyCache.Set(1, temp)'1
			For temp = 2 To CardyCache.Size - 1 Step 3
				CardyCache.Set(temp+1, IncrementTweenAlpha(CardyCache.Get(temp+1), 5,  10,110))'1 (radius %*100)
				CardyCache.Set(temp+2, IncrementAngle(CardyCache.Get(temp+2), 5))'2 (angle)
			Next
		Case 2'DS9 wireframe
			If GIFloaded Then
				If DateTime.Now < CRD_LastUpdate + 100 Then Return 			
			End If
			ROM_Angle=ROM_Angle+1
			If GIFloaded Then  
				If ROM_Angle >= 15 Then ROM_Angle= 0
			Else 
				Wireframe.GetModel(File.DirAssets, "ds9.3d").isClean=False 
				If ROM_Angle >=360 Then ROM_Angle = 0
			End If 
			CRD_LastUpdate = DateTime.Now
	End Select
	NeedsInit=False
	PreviousMode=Mode
End Sub

Sub DrawCardyMode(BG As Canvas, CenterX As Int, CenterY As Int, Radius As Int, Mode As Int, Before As Boolean) As Boolean 
	Dim temp As Int, X As Int=CenterX-Radius, Y As Int=CenterY-Radius, Angle As Int, Distance As Int =Radius*2, Color As Int 
	
	If PreviousMode = Mode Or GIFloaded Then
		'Log("CARDY: " & PreviousMode & " " & Mode & " " & GIFloaded & " " & Before)
		
		Select Case Mode
			Case 1'weird, green line things				
				If Before Then Return True 
				Angle = CardyCache.Get(0)
				LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, Radius, CardyColor(7,255), 0, Radius*0.55, Array As Int(Angle, Angle+45, Angle+45, Angle+90, Angle+90, Angle+135, Angle+135, Angle+180))
				LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, Radius, CardyColor(8,255), 0, Radius*0.55, Array As Int(Angle+180,Angle+225,  Angle+225,Angle+270,    Angle+270,Angle+315,   Angle+315,Angle))
				LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, Radius, Colors.Gray, Radius*0.55, 4, Array As Int(0,45,  45,90,  90,135,   135,180,   180,225,  225,270,    270,315,   315,360))
				For temp = 2 To CardyCache.Size - 1 Step 3
					Color = CardyCache.Get(temp)
					Distance = ReturnTweenAlpha(CardyCache.Get(temp+1)).Current * 0.01 * Radius
					Angle = ReturnTweenAlpha(CardyCache.Get(temp+2)).Current 
					X = Trig.findXYAngle(CenterX,CenterY,Distance,Angle,True)
					Y = Trig.findXYAngle(CenterX,CenterY,Distance,Angle,False)
					BG.DrawLine(CenterX,CenterY, X,Y, Color, 20)
					BG.DrawCircle(X,   Y,     40,       Color,   True,       0)
				Next
				Angle = CardyCache.Get(1)'6 purple 9 yellow
				LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, Radius, CardyColor(9,255), 0, Radius*0.25, Array As Int(Angle,   Angle+45,   Angle+90, Angle+135,   Angle+145, Angle+150  ))
				LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, Radius, CardyColor(6,255), 0, Radius*0.25, Array As Int(Angle+45,Angle+90,   Angle+135,Angle+145,   Angle+150, Angle+225  ))
			Case 2'DS9 wireframe
				'If WallpaperService.CurrentMode="PRV" Then 
				'	LCARSeffects2.LoadUniversalGIF(LCAR.DirDefaultExternal, "ds9.gif", LCAR.CRD_Shatter)
				'End If 
				Angle=Radius*0.2
				If GIFloaded And Before Then 
					'LCARSeffects2.DrawGIF(BG, ROM_Angle, X+Angle ,Y+Angle, Distance-Angle*2, Distance-Angle*2)
					BG.DrawBitmap( LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(495*ROM_Angle,0,495,410), LCARSeffects4.SetRect(X+Angle ,Y+Angle, Distance-Angle*2, Distance-Angle*2))
					Return False
				Else if Not(Before) Then 
					temp=35
					Wireframe.DrawVerteces(BG, X+Angle ,Y+Angle, Distance-Angle*2, Distance-Angle*2, Wireframe.GetModel(File.DirAssets, "ds9.3d"), 1, False,255, ROM_Angle,temp, temp, False)
				End If 
		End Select
	End If
	Return True 
End Sub
'Sub ReturnSegments(Start As Int, Finish As Int, Increment As Int) As List 
'	Dim temp As Int, templist As List 
'	templist.Initialize 
'	For temp = start To finish Step increment
'		templist.Add(temp Mod 360)
'		templist.Add(temp Mod 360)
'	Next
'	Return templist
'End Sub
Sub ReturnTweenAlpha(Value As TweenAlpha) As TweenAlpha 
	Return Value
End Sub
Sub IncrementAngle(Value As TweenAlpha, Speed As Int) As TweenAlpha
	If Value.Desired<90 And Value.Current > 270 Then
		Value.Current = (Value.Current + Speed) Mod 360
	Else If Value.Desired > 270 And Value.Current <90 Then
		Value.Current = Value.Current - Speed
		If Value.Current <0 Then Value.Current = Value.Current + 360
	Else
		Return IncrementTweenAlpha(Value,Speed,0,360)
	End If
	If Value.Current = Value.Desired Then Value.Desired = Rnd(0,360)
	Return Value
End Sub
Sub IncrementTweenAlpha(Value As TweenAlpha, Speed As Int, RndMin As Int, RndMax As Int) As TweenAlpha 
	Value.Current = LCAR.Increment(Value.Current, Speed, Value.Desired)
	If Value.Current = Value.Desired Then Value.Desired = Rnd(RndMin,RndMax)
	Return Value
End Sub





Sub DrawMiniFrame(BG As Canvas, X As Int, Y As Int, DividerWidth As Int, TotalWidth As Int, Height As Int, ID As Int, Alpha As Int, Text As String)
	Dim WhiteSpace As Int = 10, Width As Int =TotalWidth, Y2 As Int = Y, X2 As Int = TotalWidth*0.25, X3 As Int = X2, C As Float 
	LCAR.DrawText(BG, X+TotalWidth+1,  Y, Text, LCAR.LCAR_Orange, 3,False,Alpha,-1)
	
	If ID = 1 Then X3 = TotalWidth * 0.15	
	LCAR.DrawLCARelbow(BG,     X,    Y+Height-X3-DividerWidth,X2,X3+DividerWidth,DividerWidth,DividerWidth,        -4, LCAR.Classic_Blue, False, "", 0, Alpha, False)
	
	Select Case ID
		Case 0
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.16375		, True, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.135625	, True, LCAR.LCAR_LightBlue,	True)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.07625		, True, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.245		, True, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.0825		, True, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.148125	, True, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		1-C			, True, LCAR.LCAR_LightBlue,	True)
			
			C=0
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.60, 	0.75		, False, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.35, 	1.00		, False, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.05, 	1.00		, False, LCAR.LCAR_LightBlue,	True)
		Case 1
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.25		, True, LCAR.LCAR_LightPurple,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.10		, True, LCAR.LCAR_Yellow,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.05		, True, LCAR.LCAR_Yellow,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.20		, True, LCAR.LCAR_LightPurple,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		1-C			, True, LCAR.LCAR_LightBlue,	False)
		
			C=0
			   DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.60, 	0.20		, False, LCAR.LCAR_LightPurple,	False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0.25, 	0.60, 	0.80		, False, LCAR.LCAR_LightPurple,	False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.32, 	1.00		, False, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.08, 	1.00		, False, LCAR.LCAR_LightBlue,	True)
		Case 2
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.15		, True, LCAR.LCAR_LightBlue,	True)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.12		, True, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.32		, True, LCAR.LCAR_LightPurple,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.06		, True, LCAR.LCAR_LightBlue,	False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		0.04		, True, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X3, DividerWidth, TotalWidth,Height, Alpha,       0, C, 	1, 		1-C			, True, LCAR.LCAR_LightPurple,	False)
			
			C=0
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.60, 	0.30		, False, LCAR.LCAR_LightBlue,	True)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.35, 	1.00		, False, LCAR.LCAR_Orange,		False)
			C= DrawMiniSquare( BG, X,Y, X2, DividerWidth, TotalWidth,Height, Alpha,       C, 0, 	0.05, 	1.00		, False, LCAR.LCAR_LightBlue,	False)
	End Select
	
	
	
	
	
'	Y2 = LCARSeffects4.DrawRect(BG,X,Y2,DividerWidth, Height*0.25, Red, 0) 
'	Y2 = LCARSeffects4.DrawRect(BG,X,Y2+ WhiteSpace,DividerWidth, Height*0.15, LCAR.GetColor( API.IIF(ID=1,LCAR.LCAR_DarkOrange, LCAR.LCAR_LightBlue ),False,Alpha), 0)
'	Y2 = LCARSeffects4.DrawRect(BG,X,Y2+ WhiteSpace,DividerWidth, Height*0.25, Orange, 0)+WhiteSpace
'	
'	LCAR.DrawLCARelbow(BG,X, Y2,  X2, Height-(Y2-Y), DividerWidth,DividerWidth,  -4, LCAR.Classic_Blue, False, "", 0, Alpha, False)
'	
'	TotalWidth=TotalWidth-X2-WhiteSpace
'	X2=X+X2+WhiteSpace
'	Y2=Y+Height-DividerWidth
'	If ID=1 Then
'		LCARSeffects4.DrawRect(BG,X2,Y2, TotalWidth*0.8, DividerWidth*0.5, Red, 0)
'		LCARSeffects4.DrawRect(BG,X2,Y2+DividerWidth*0.1, TotalWidth*0.8, DividerWidth*0.3, Red, 0)
'		LCARSeffects4.DrawRect(BG,X2+TotalWidth*0.8+WhiteSpace,Y2, TotalWidth*0.2-WhiteSpace, DividerWidth*0.9, Orange,0)
'	Else
'		LCARSeffects4.DrawRect(BG,X2,Y2, TotalWidth*0.7, DividerWidth * API.IIF(ID=0,0.7,0.5),LCAR.GetColor(LCAR.LCAR_LightPurple,False,Alpha), 0)
'		
'		DividerWidth=DividerWidth*0.9
'		X2=X2+ TotalWidth*0.7+WhiteSpace
'		LCARSeffects4.DrawRect(BG,X2,Y2, TotalWidth * 0.15, DividerWidth, Orange, 0)
'		
'		X2=X2+ TotalWidth*0.15+WhiteSpace
'		LCARSeffects4.DrawRect(BG,X2,Y2, TotalWidth * 0.10, DividerWidth, LCAR.GetColor( API.IIF(ID=0,LCAR.Classic_Blue, LCAR.LCAR_Red ), False,Alpha), 0)
'		
'		X2=X2+ TotalWidth*0.10+WhiteSpace
'		Y=X2-X
'		LCARSeffects4.DrawRect(BG,X2,Y2, Width-Y, DividerWidth,  LCAR.GetColor( LCAR.LCAR_DarkOrange, False,Alpha),0)
'	End If
End Sub
Sub DrawMiniSquare(BG As Canvas, X As Int, Y As Int, X3 As Int, DividerWidth As Int, TotalWidth As Int, Height As Int, Alpha As Int, X2 As Float, Y2 As Float, Width2 As Float, Height2 As Float, IsX As Boolean, ColorID As Int, State As Boolean)  As Float 
	Dim Whitespace As Int = 4
	If IsX Then
		Height=Height-DividerWidth-X3
		LCARSeffects4.DrawRect(BG, X, Y+ Y2*Height, Width2*DividerWidth, (Height*Height2)-Whitespace, LCAR.GetColor(ColorID,State,Alpha), 0)
		Return Y2+Height2
	Else
		TotalWidth = TotalWidth-X3-Whitespace
		X=X+ X3+Whitespace'+DividerWidth
		LCARSeffects4.DrawRect(BG, X + TotalWidth*X2, Y+Height-DividerWidth+(DividerWidth*Y2), TotalWidth*Width2-Whitespace, DividerWidth*Height2 - API.IIF(Height2=1, 0,Whitespace), LCAR.GetColor(ColorID,State,Alpha), 0)
		Return X2+Width2
	End If
End Sub



Sub AddRomPoint(IsXaxis As Boolean, Pos As Int)
	Dim temp As Float
	'temp.Initialize 
	temp = Pos/API.IIF(IsXaxis, 717,558)
	If IsXaxis Then 
		RomX.Add(temp)
	Else
		RomY.Add(temp)
	End If
End Sub

'Alpha: Hour, Beta: Minute, Gamma: Month, Delta: Day
Sub DrawRomulan(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, AlphaQ As Int, BetaQ As Int, GammaQ As Int, DeltaQ As Int, Scale As Boolean )
	Dim P As Path , temp As Int , Size As tween
	If AlphaQ = -1 Then AlphaQ = DateTime.GetHour(DateTime.Now)
	If BetaQ  = -1 Then BetaQ  = DateTime.GetMinute(DateTime.Now)
	If GammaQ = -1 Then GammaQ = DateTime.GetMonth(DateTime.Now)
	If DeltaQ = -1 Then DeltaQ = DateTime.GetDayOfMonth(DateTime.Now)
	If Scale Then 
		Size = LCAR.ThumbSize(717,558, Width, Height, True, False)
		X= X + Width*0.5 - Size.currX *0.5
		Y= Y+ Height*0.5-Size.curry*0.5
		Width=Size.currX
		Height=Size.curry
	End If
	If Not(RomX.IsInitialized) Then
		If Not(LCAR.ROMfont.IsInitialized) Then LCAR.ROMfont = Typeface.LoadFromAssets("rom.ttf")
		RomX.Initialize 
		RomY.Initialize 
        AddRomPoint(True,  0 )
        AddRomPoint(True,  28 )
        AddRomPoint(True,  55 )
        AddRomPoint(True,  60 )
        AddRomPoint(True,  102 )
        AddRomPoint(True,  130 )
        AddRomPoint(True,  159 )
        AddRomPoint(True,  188 )
        AddRomPoint(True,  218 )
        AddRomPoint(True,  247 )
        AddRomPoint(True,  298 )
        AddRomPoint(True,  309 )
        AddRomPoint(True,  328 )
        AddRomPoint(True,  346 )
        AddRomPoint(True,  367 )
        AddRomPoint(True,  387 )
        AddRomPoint(True,  404 )
        AddRomPoint(True,  416 )
        AddRomPoint(True,  431 )
        AddRomPoint(True,  443 )
        AddRomPoint(True,  473 )
        AddRomPoint(True,  502 )
        AddRomPoint(True,  496 )
        AddRomPoint(True,  526 )
        AddRomPoint(True,  555 )
        AddRomPoint(True,  584 )
        AddRomPoint(True,  615 )
        AddRomPoint(True,  620 )
        AddRomPoint(True,  657 )
        AddRomPoint(True,  662 )
        AddRomPoint(True,  688 )
        AddRomPoint(True,  716 )
        AddRomPoint(True,  282 )
        AddRomPoint(True, 169)
        AddRomPoint(True, 324)
        AddRomPoint(True, 393)
        AddRomPoint(True, 548)
		AddRomPoint(True, 96)

        AddRomPoint(False,  0 )
        AddRomPoint(False,  18 )
        AddRomPoint(False,  25 )
        AddRomPoint(False,  53 )
        AddRomPoint(False,  65 )
        AddRomPoint(False,  80 )
        AddRomPoint(False,  84 )
        AddRomPoint(False,  103 )
        AddRomPoint(False,  122 )
        AddRomPoint(False,  143 )
        AddRomPoint(False,  161 )
        AddRomPoint(False,  179 )
        AddRomPoint(False,  202 )
        AddRomPoint(False,  220 )
        AddRomPoint(False,  231 )
        AddRomPoint(False,  250 )
        AddRomPoint(False,  270 )
        AddRomPoint(False,  289 )
        AddRomPoint(False,  309 )
        AddRomPoint(False,  328 )
        AddRomPoint(False,  341 )
        AddRomPoint(False,  358 )
        AddRomPoint(False,  376 )
        AddRomPoint(False,  418 )
        AddRomPoint(False,  437 )
        AddRomPoint(False,  456 )
        AddRomPoint(False,  471 )
        AddRomPoint(False,  475 )
        AddRomPoint(False,  480 )
        AddRomPoint(False,  494 )
        AddRomPoint(False,  506 )
        AddRomPoint(False,  534 )
        AddRomPoint(False,  541 )
        AddRomPoint(False,  558 )
        AddRomPoint(False, 151)
        AddRomPoint(False, 396)
	End If'ROM_Beige, ROM_LightBlue, ROM_DarkBlue, ROM_Green
	
	Rom_FontsizeP = ROM_GetPoint(0,0,Width,Height, False, 17) - ROM_GetPoint(0,0,Width,Height, False, 16)
	Rom_Fontsize = API.GetTextHeight(BG, Rom_FontsizeP, "ABC", LCAR.ROMfont)
	If ROM_LastUpdate <> DateTime.GetMinute(DateTime.Now) Then
		ROM_Texts.Initialize 
		For temp = 0 To 21
			ROM_Texts.Add(ROM_MakeText(API.IIF(temp<4,2,1),3))
		Next
		
		ROM_LastUpdate=DateTime.GetMinute(DateTime.Now)
	End If
	
	'top left squares
	ROM_DrawShape(BG, X, Y, Width, Height,   			2, 	4, 	38, 14, ROM_Beige, 0,1,1, 5)
	ROM_DrawShape(BG, X, Y, Width, Height,   			38, 4, 	11, 14, ROM_LightBlue, 0,1,3, 6)
	ROM_PrintText(BG, ROM_GetPoint(X,Y,Width,Height,True,38), Y, 0, ROM_Texts.Get(0), ROM_LightBlue, Rom_Fontsize*2)
	'top right
	ROM_DrawShape(BG, X, Y, Width, Height,   			18, 4, 28, 14,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			28, 4, 31, 14,	ROM_DarkBlue,0,1,3, 7)
	ROM_PrintText(BG, ROM_GetPoint(X,Y,Width,Height,True,28), Y, 2, ROM_Texts.Get(1), ROM_LightBlue, Rom_Fontsize*2)
	'bottom left
	ROM_DrawShape(BG, X, Y, Width, Height,   			2, 21, 38, 31,	ROM_DarkBlue,0,1,1, 8)
	ROM_DrawShape(BG, X, Y, Width, Height,   			38, 21, 33, 31,	ROM_LightBlue,0,1,0, 0)
	ROM_PrintText(BG, ROM_GetPoint(X,Y,Width,Height,True,38), Y+Height-Rom_FontsizeP*2, 0, ROM_Texts.Get(2), ROM_LightBlue, Rom_Fontsize*2)
	'bottom right
	ROM_DrawShape(BG, X, Y, Width, Height,   			19, 21, 28, 31,	ROM_LightBlue,0,1,10,11)
	ROM_DrawShape(BG, X, Y, Width, Height,   			28, 21, 31, 31, ROM_Beige, 0,1,3,13 )
	ROM_PrintText(BG, ROM_GetPoint(X,Y,Width,Height,True,28), Y+Height-Rom_FontsizeP*2, 2, ROM_Texts.Get(3), ROM_LightBlue, Rom_Fontsize*2)
	'middle
	ROM_DrawShape(BG, X, Y, Width, Height,   			6, 	9, 26, 25, Colors.Transparent, 0, 2, 0,0)
	
	'top 3 squares
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 1,	13, 2,	ROM_LightBlue,0,2,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			13, 1,	16, 2,	ROM_LightBlue,0,2,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			16, 1,	17, 2,	ROM_LightBlue,0,2,0,0)
	'below top 3 squares (5 rects,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 3, 13, 6,	ROM_LightBlue,0,1,2,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			13, 3, 14, 6,	ROM_DarkBlue,0,1,2,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			14, 3, 15, 6,	ROM_DarkBlue,0,1,2,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			15, 3, 16, 6,	ROM_DarkBlue,0,1,2,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			16, 3, 17, 6,	ROM_LightBlue,0,1,2,0)
	'below that
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 7, 13, 10,	ROM_LightBlue,0,1,0,0)	
	ROM_DrawShape(BG, X, Y, Width, Height,   			13, 7, 16, 10,	ROM_DarkBlue,0,1,11, 14)
	ROM_DrawShape(BG, X, Y, Width, Height,   			16, 7, 17, 10,	ROM_LightBlue,0,1,0,0)
	
	'middle-left
	ROM_DrawShape(BG, X, Y, Width, Height,   			1, 15, 3, 16,	ROM_DarkBlue,0,1,6,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			1, 16, 3, 17,	ROM_LightBlue,0,1,6,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			1, 17, 3, 18,	ROM_LightBlue,0,1,6,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			1, 18, 3, 19,	ROM_LightBlue,0,1,6,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			1, 19, 3, 20,	ROM_DarkBlue,0,1,6,0)
	'right of middle-left
	ROM_DrawShape(BG, X, Y, Width, Height,   			4, 15, 7, 16,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			4, 16, 7, 19,	ROM_DarkBlue,0,1,5, 15)
	ROM_DrawShape(BG, X, Y, Width, Height,   			4, 19, 7, 20,	ROM_LightBlue,0,1,0,0)
	
	'middle-right
	ROM_DrawShape(BG, X, Y, Width, Height,   			30, 15, 32, 16,	ROM_LightBlue,0,1,4,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			30, 16, 32, 17,	ROM_LightBlue,0,1,4,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			30, 17, 32, 18,	ROM_LightBlue,0,1,4,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			30, 18, 32, 19,	ROM_LightBlue,0,1,4,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			30, 19, 32, 20,	ROM_LightBlue,0,1,4,0)
	'left of middle-right
	ROM_DrawShape(BG, X, Y, Width, Height,   			25, 15, 29, 16,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			25, 16, 29, 19,	ROM_DarkBlue,0,1,7,17)
	ROM_DrawShape(BG, X, Y, Width, Height,   			25, 19, 29, 20,	ROM_LightBlue,0,1,0,0)
	
	'top of bottom
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 24, 13, 27,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			13, 24, 16, 27,	ROM_DarkBlue,0,1,9, 19)
	ROM_DrawShape(BG, X, Y, Width, Height,   			16, 24, 17, 27,	ROM_LightBlue,0,1,0,0)
	'middle of bottom
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 29, 13, 32,	ROM_LightBlue,0,1,8,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			13, 29, 14, 32,	ROM_DarkBlue,0,1,8,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			14, 29, 15, 32,	ROM_DarkBlue,0,1,8,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			15, 29, 16, 32,	ROM_DarkBlue,0,1,8,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			16, 29, 17, 32,	ROM_LightBlue,0,1,8,0)
	'bottom of bottom
	ROM_DrawShape(BG, X, Y, Width, Height,   			12, 33, 14, 34,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			14, 33, 15, 34,	ROM_LightBlue,0,1,0,0)
	ROM_DrawShape(BG, X, Y, Width, Height,   			15, 33, 17, 34,	ROM_LightBlue,0,1,0,0)
	
	'middle
	ROM_DrawShape(BG, X, Y, Width, Height,   			7, 10, 25, 24, ROM_Green, 0, 4,10, 20)
	BG.drawpath(ROM_MakePath(X, Y, Width, Height,		Array As Int(7, 10, 33, 24, 12, 24)), Colors.Black , True, 0)'left
	BG.drawpath(ROM_MakePath(X, Y, Width, Height,		Array As Int(25, 10, 17, 24, 19, 24)), Colors.Black , True, 0)'right
	BG.drawpath(ROM_MakePath(X, Y, Width, Height,		Array As Int(7, 10, 12, 24, 17, 24, 25, 10)), ROM_LightBlue, True,0)'center
	
	'.'. pattern
	P = ROM_MakePath(X, Y, Width, Height,				Array As Int(34, 35, 35, 36, 36, 36, 37, 35))
	BG.ClipPath(P)
	ROM_DrawShape(BG, X, Y, Width, Height,				34, 35, 37, 36, Colors.Black,1, 2,     0,0)
	BG.RemoveClip 
	
	'Alpha Quadrant	(hour)									'ROM_Beige, ROM_Green
	ROM_DrawBit(BG, X, Y, Width, Height,					23, 26, 24, 28,	ROM_Beige, AlphaQ, 0, 1)
	ROM_DrawBit(BG, X, Y, Width, Height,					24, 26, 25, 28, ROM_Beige, AlphaQ, 0, 2)
	ROM_DrawBit(BG, X, Y, Width, Height,					24, 28, 25, 30, ROM_Beige, AlphaQ, 0, 3)
	ROM_DrawBit(BG, X, Y, Width, Height,					25, 25, 26, 26, ROM_Green, AlphaQ, 0, 4)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 21, 27, 22, ROM_Green, AlphaQ, 0, 5)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 22, 27, 23, ROM_Green, AlphaQ, 0, 6)

	'Beta Quadrant (minute)
	ROM_DrawBit(BG, X, Y, Width, Height,					5, 24, 6, 25, ROM_Beige, BetaQ, 1, 1)
	ROM_DrawBit(BG, X, Y, Width, Height,					5, 25, 6, 26, ROM_Beige, BetaQ, 1, 2)
	ROM_DrawBit(BG, X, Y, Width, Height,					5, 26, 6, 28, ROM_Beige, BetaQ, 1, 3)
	ROM_DrawBit(BG, X, Y, Width, Height,					6, 25, 7, 26, ROM_Green, BetaQ, 1, 4)
	ROM_DrawBit(BG, X, Y, Width, Height,					7, 26, 8, 28, ROM_Beige, BetaQ, 1, 5)
	ROM_DrawBit(BG, X, Y, Width, Height,					8, 28, 9, 30, ROM_Green, BetaQ, 1, 6)
	ROM_DrawBit(BG, X, Y, Width, Height,					9, 25, 10, 26, ROM_Green, BetaQ, 1, 7)
	ROM_DrawBit(BG, X, Y, Width, Height,					9, 26, 10, 28, ROM_Green, BetaQ, 1, 8)
	
	'Gamma Quadrant (month)
	ROM_DrawBit(BG, X, Y, Width, Height,					5, 5, 6, 7, ROM_Beige, GammaQ, 2, 1)
	ROM_DrawBit(BG, X, Y, Width, Height,					5, 13, 6, 14, ROM_Beige, GammaQ, 2, 2)
	ROM_DrawBit(BG, X, Y, Width, Height,					6, 7, 7, 8, ROM_Green, GammaQ, 2, 3)
	ROM_DrawBit(BG, X, Y, Width, Height,					6, 8, 7, 9, ROM_Beige, GammaQ, 2, 4)
	ROM_DrawBit(BG, X, Y, Width, Height,					7, 8, 8, 9, ROM_Green, GammaQ, 2, 5)
	ROM_DrawBit(BG, X, Y, Width, Height,					8, 7, 9, 8, ROM_Green, GammaQ, 2, 6)
	ROM_DrawBit(BG, X, Y, Width, Height,					9, 7, 10, 8, ROM_Beige, GammaQ, 2, 7)
	
	'Delta Quadrant (day)
	ROM_DrawBit(BG, X, Y, Width, Height,					18, 8, 20, 9, ROM_Green, DeltaQ, 3, 1)
	ROM_DrawBit(BG, X, Y, Width, Height,					20, 7, 21, 8, ROM_Green, DeltaQ, 3, 2)
	ROM_DrawBit(BG, X, Y, Width, Height,					20, 8, 21, 9, ROM_Green, DeltaQ, 3, 3)
	ROM_DrawBit(BG, X, Y, Width, Height,					21, 7, 22, 8, ROM_Green, DeltaQ, 3, 4)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 5, 27, 7, ROM_Beige, DeltaQ, 3, 5)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 7, 27, 8, ROM_Beige, DeltaQ, 3, 6)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 8, 27, 9, ROM_Beige, DeltaQ, 3, 7)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 9, 27, 10, ROM_Beige, DeltaQ, 3, 8)
	ROM_DrawBit(BG, X, Y, Width, Height,					26, 11, 27, 12, ROM_Green, DeltaQ, 3, 9)
End Sub

Sub ROM_DrawBit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, X1 As Int, Y1 As Int, X2 As Int, Y2 As Int, Color As Int, Value As Int, Quadrant As Int, BitIndex As Int)
	Dim DoIt As Boolean = Bit.And(Value,  Power(2, BitIndex-1)) >0, BitC As Int , Dest As Rect 
	Dest = ROM_DrawShape(BG, X, Y, Width, Height,				X1,Y1,X2,Y2, API.IIF(DoIt, Color, Colors.Transparent), 0, 2, BitC,0)
	'If Quadrant = 2 AND BitIndex = 2 Then
	'Select Case Quadrant + BitIndex * 0.1
		'Gamma
		'Case 2.2
			'ROM_PrintText(BG, Dest.Left + Rom_FontsizeP*0.5, Dest.Top, 3, ROM_MakeText(1,3), Colors.Black, Rom_Fontsize)
		
	'End Select
	'End If
End Sub
Sub ROM_GetPoint(X As Int, Y As Int, Width As Int, Height As Int, Xaxis As Boolean, Index As Int) As Int
	If Xaxis Then Return X + (RomX.Get(Index-1) * Width) 
	Return Y + (RomY.Get(Index-1) * Height)
End Sub
Sub ROM_MakePath(X As Int, Y As Int, Width As Int, Height As Int, Points() As Int) As Path 
	Dim P As Path , temp As Int 
	P.Initialize( ROM_GetPoint(X,Y,Width,Height,True, Points(0)), ROM_GetPoint(X,Y,Width,Height,False, Points(1)))
	For temp = 2 To Points.Length-1 Step 2
		P.LineTo( ROM_GetPoint(X,Y,Width,Height,True, Points(temp)), ROM_GetPoint(X,Y,Width,Height,False, Points(temp+1)))
	Next
	Return P 
End Sub
Sub ROM_MakeText(MinDigits As Int, MaxDigits As Int) As String 
	Dim Count As Int = Rnd(MinDigits, MaxDigits+1), temp As Int, tempstr As StringBuilder , Low As Int = Asc("A"), High As Int = Asc("Z")+1
	tempstr.Initialize 
	For temp = 1 To Count
		tempstr.Append(Chr(Rnd(Low,High)))
	Next
	Return tempstr.ToString 
End Sub

'Dir: 0=left to right, 1=top to bottom
Sub ROM_PrintText(BG As Canvas, X As Int, Y As Int, Dir As Int, Text As String, Color As Int, Size As Int)
	If Not(LCAR.ROMfont.IsInitialized) Then LCAR.ROMfont = Typeface.LoadFromAssets("rom.ttf")
	If Dir = 0 Then
		API.DrawText(BG, Text, X,Y, LCAR.ROMfont, Size, Color, 0)
	Else
		Dim Height As Int = BG.MeasureStringHeight(Text, LCAR.ROMfont, Size), Degree As Float = Dir * 90
		Select Case Dir
			Case 1:X=X-Height
			Case 2
			Case 3:X=X+Height
		End Select
		BG.DrawTextRotated(Text, X,Y, LCAR.ROMfont, Size, Color, "LEFT", Degree)
	End If 
End Sub

'BitC: 0 = normal/nothing, MARKS: 2=bottom, 4=left, 6=right, 8=top, TEXT: 1=bottom left, 3=top right, 5=left side*2, 7=right side*2, 9=bottom, 10=bottom left and right*2, 11=top
Sub ROM_DrawShape(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, X1 As Int, Y1 As Int, X2 As Int, Y2 As Int, Color As Int, Tool As Int, Stroke As Int, BitC As Int, TextID As Int) As Rect 
	Dim temp As Int, temp2 As Int, temp3 As Int ,temp4 As Int, temp5 As Int , temp6 As Boolean   ,Size As tween 
	X1=ROM_GetPoint(X,Y,Width,Height,True, X1)
	Y1=ROM_GetPoint(X,Y,Width,Height,False, Y1)
	X2=ROM_GetPoint(X,Y,Width,Height,True, X2)
	Y2=ROM_GetPoint(X,Y,Width,Height,False, Y2)
	X=Width
	Y=Height
	Width=X2-X1
	Height=Y2-Y1
	Select Case Tool
		Case 0'square
			If Color <> Colors.Transparent Then LCARSeffects4.DrawRect(BG, X1,Y1, Width, Height, Color,0)
			If Stroke>0 Then LCARSeffects4.DrawRect(BG, X1,Y1, Width, Height, Colors.black,Stroke)
			If BitC >0 Then temp = Y * 0.0075
			Select Case BitC
				Case 0'GNDN
				'MARKS
				Case 2,8' |
					If BitC=2 Then temp2 = Y1+Height -temp*3 Else temp2 = Y1+ temp
					LCARSeffects4.DrawRect(BG, X1+ Width*0.5-temp*0.5, temp2, temp,temp*2, Colors.Black, 0)
				Case 4,6'---
					If BitC=4 Then temp2=X1+temp Else temp2 = X1+Width-temp*3
					LCARSeffects4.DrawRect(BG, temp2, Y1+Height*0.5-temp*0.5, temp*2,temp, Colors.Black,0)
				'TEXT
				Case 1'bottom left
					ROM_PrintText(BG, X1+ Rom_FontsizeP*0.5, Y1+Height - Rom_FontsizeP*0.5, 3, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
				Case 3'top right
					ROM_PrintText(BG, X1+Width-Rom_FontsizeP*0.5, Y1+Rom_FontsizeP*0.5,  1, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
				Case 5'left side
					ROM_PrintText(BG, X1+ Rom_FontsizeP*0.5, Y1+Rom_FontsizeP*0.5, 0, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
					ROM_PrintText(BG, X1+ Rom_FontsizeP*0.5, Y1+Height-Rom_FontsizeP*1.5, 0, ROM_Texts.Get(TextID+1), Colors.black, Rom_Fontsize)
				Case 7'right side
					ROM_PrintText(BG, X1+Width- Rom_FontsizeP*0.5, Y1+Rom_FontsizeP*0.5, 2, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
					ROM_PrintText(BG, X1+Width- Rom_FontsizeP*0.5, Y1+Height-Rom_FontsizeP*1.5, 2, ROM_Texts.Get(TextID+1), Colors.black, Rom_Fontsize)
				Case 9'bottom
					ROM_PrintText(BG, X1+Width- Rom_FontsizeP*0.5, Y1+Height-Rom_FontsizeP*1.5, 2, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
				Case 11'top
					ROM_PrintText(BG, X1+Width*0.5, Y1+Rom_FontsizeP*0.5, 1, ROM_Texts.Get(TextID), Colors.Black, Rom_Fontsize)
					
				Case 10	'both bottom corners
					ROM_PrintText(BG, X1+ Rom_FontsizeP*0.5, Y1+Height - Rom_FontsizeP*0.5, 3, ROM_Texts.Get(TextID), Colors.black, Rom_Fontsize)
					ROM_PrintText(BG, X1+ Width- Rom_FontsizeP*1.5, Y1+Height - Rom_FontsizeP*0.5, 3, ROM_Texts.Get(TextID+1), Colors.black, Rom_Fontsize)
				'Case 12 'outside top left and inside top right
					'ROM_PrintText(BG, X1-Rom_FontsizeP, Y+Rom_FontsizeP, 1, ROM_MakeText(1,3), Colors.black, Rom_Fontsize)
					'ROM_PrintText(BG, X1+Width-Rom_FontsizeP, Y+Rom_FontsizeP, 1, ROM_MakeText(1,3), Colors.red, Rom_Fontsize)
					
				Case Else: Log("Rom align: " & BitC)
			End Select
		Case 1'.'. pattern
			temp3=Height*0.1 '20
			temp4=temp3*0.5 + Stroke*0.5
			temp5=Width*0.025
			For temp = Y1 To Y2 + temp4 Step temp3+(Stroke*LCAR.ScaleFactor)
				temp6=False
				For temp2 = X1 To X2 Step temp5 ' Stroke*2
					If temp6 Then
						BG.DrawLine(temp2, temp-temp4, temp2, temp-temp4+temp3, Color, Stroke)
					Else
						BG.DrawLine(temp2, temp, temp2, temp+temp3, Color, Stroke)
					End If
					'temp5= temp + API.IIF(temp6, temp4,0)
					'BG.DrawLine(temp2, temp5, temp2, temp5+2, API.IIF(temp6, Color, Colors.Red), Stroke)
					temp6=Not(temp6)
				Next
			Next
			LCARSeffects2.LoadUniversalBMP(File.DirAssets, "romulan.png", LCAR.ROM_Square)'width*274/378 (72%)
			Size = LCAR.ThumbSize(LCARSeffects2.CenterPlatform.Width,LCARSeffects2.CenterPlatform.Height, Width*0.72, Height, False,False)
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCARSeffects4.SetRect(X1+ Width*0.5 - Size.currX*0.5, Y1+Height*0.5-Size.currY*0.5, Size.currX,Size.currY))
	End Select
	Return LCAR.SetRect(X1,X2,X,Y)
End Sub

'this one must be the only element being drawn
'Hour/Minute/Second: -1=now, -2=do not show, 0 to 12/59/59=the hour/minute/second
Sub DrawKlingonClock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Hour As Int, Minute As Int, Second As Int)
	Dim temp As Int = 0.122969837587007 * Width
	X= X + temp
	Width = Width - temp
		
	Dim Size As tween = LCAR.ThumbSize(431,537, Width, Height, True,False), cX As Int, cY As Int ', temp As Int api.GetDeviceSize(True)
	Dim W3 As Int = BG.Bitmap.Width , H3 As Int = BG.Bitmap.Height, R2 As Int = Max(W3,H3)' X2 As Int = X, Y2 As Int = Y, W2 As Int = Width, H2 As Int = Height, 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "klingon.png", LCAR.Klingon_Clock)
	X = X + Width*0.5 - Size.currX * 0.5 
	Y = Y + Height*0.5 - Size.currY * 0.5 
	Width = Size.currX'TODO: Crop the image to get rid of the knives
	Height = Size.currY
	
	If Hour = -1 Then 	Hour = 		DateTime.GetHour(DateTime.Now)
	If Minute = -1 Then Minute  = 	DateTime.GetMinute(DateTime.Now)
	If Second = -1 Then Second = 	DateTime.GetSecond(DateTime.Now)
	
	Hour = Hour Mod 12 
	Minute = Minute Mod 60
	Second = Second Mod 60
	
	cX = X + Width * 0.433	'187/431=0.43387470997679814385150812064965
	cY = Y + Height * 0.678	'364/537=0.67783985102420856610800744878957
	'radius = 141/431=0.32714617169373549883990719257541
	'thickness = 5/431=0.01160092807424593967517401392111
	
	'LCARSeffects.CacheAngles(R2,-1)
'	If Second>-1 Then 'LCARSeffects2.DrawSegmentedCircle(BG, cX,cY, R2, Colors.White, Width * 0.327, Width * 0.015, Array As Int(Second*6, (Second+1)*6 ))
'		DrawHand(BG, cX,cY, Height * 0.559, 1, 0, Colors.White, Second*6,2)'300/537=0.55865921787709497206703910614525
'		'If X>0 Then LCARSeffects4.DrawRect(BG,0,0, X, H3, Colors.Black, 0)'left bar
'		'If Y>0 Then LCARSeffects4.DrawRect(BG,0,0, W3, Y, Colors.Black,0)'top bar
'		'If X+Width<= W3 Then LCARSeffects4.DrawRect(BG,X+Width, 0, W3-X-Width, H3, Colors.Black, 0)'right bar
'		'If Y+Height<=H3 Then LCARSeffects4.DrawRect(BG,0, Y+Height, W3, H3-Y-Height, Colors.Black , 0)'bottom bar
'	End If 
	'BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,0,431,537), LCARSeffects4.SetRect(X,Y,Width,Height))
	
	
	If Hour > -1 Then 	DrawHand(BG, cX,cY, Width, 0.15, 3, Colors.green, Hour * 30, 30, 0, R2)
	If Minute > -1 Then DrawHand(BG, cX,cY, Width, 0.25, 2, Colors.Blue, Minute * 6,6, 1, R2)
	If Second>-1 Then 	DrawHand(BG, cX,cY,Width, 1, 0, Colors.White, Second*6,6 ,2, R2)'300/537=0.55865921787709497206703910614525'Height * 0.559
	 
	If X>0 Then LCARSeffects4.DrawRect(BG,0,0, X, H3, Colors.Black, 0)'left bar
	If Y>0 Then LCARSeffects4.DrawRect(BG,0,0, W3, Y, Colors.Black,0)'top bar
	If X+Width<= W3 Then LCARSeffects4.DrawRect(BG,X+Width, 0, W3-X-Width, H3, Colors.Black, 0)'right bar
	If Y+Height<=H3 Then LCARSeffects4.DrawRect(BG,0, Y+Height, W3, H3-Y-Height, Colors.Black , 0)'bottom bar
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,0,431,537), LCARSeffects4.SetRect(X,Y,Width,Height))
End Sub
Sub DrawHand(BG As Canvas, Xcenter As Int, Ycenter As Int, Width As Int, Radius As Float, Stroke As Int, Color As Int, Angle As Int, AngleWidth As Int, Index As Int, R2 As Int)
	Radius=1
	Stroke=0
	Dim WR As Int = Width*Radius, X As Int =Trig.findXYAngle(Xcenter,Ycenter, WR, Angle, True), Y As Int = Trig.findXYAngle(Xcenter,Ycenter, WR, Angle, False), P As Path 
	'LCARSeffects2.DrawSegmentedCircle(BG, Xcenter,Ycenter, R2, Color, Width * 0.327, Width * 0.015, Array As Int(Angle, Angle+ AngleWidth))
	
'	If index <2 Then Width=WR*0.37
'	Select Case Index
'		Case 0'hour
'			BG.DrawBitmapRotated(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(431,0,95,267), LCARSeffects4.SetRect(X-Width*0.5,Y-WR*0.5, Width,WR), Angle)'0.36964980544747081712062256809339
'		Case 1'minute
'			BG.DrawBitmapRotated(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(431, 271, 95,267), LCARSeffects4.SetRect(X-Width*0.5,Y-WR*0.5, Width,WR), Angle)
'		Case 2'second
			P.Initialize(Xcenter,Ycenter)
			P.LineTo(X,Y)
			X = Trig.findXYAngle(Xcenter,Ycenter, Width, Angle+AngleWidth, True)
			Y = Trig.findXYAngle(Xcenter,Ycenter, Width, Angle+AngleWidth, False)
			P.LineTo(X,Y)
			BG.DrawPath(P, Color,Stroke=0,Stroke)
'	End Select'BG.DrawLine(Xcenter, Ycenter, X, Y, Color,Stroke)
End Sub



'Whale probe: Sensor DATA In Starship font
'RIGHT HALF: White square moves from top left of the square To the corner of the probe (takes 6 steps)
'White square blinks 3 times, switching from white To black
'MAG FACTOR 89.0 appears instantly
'
'LEFT HALF: a clip Path starts from the left AND sweeps left, drawing the part of the probe the white square Is zoomed In on.
'Blue grid blinks white twice

Sub DrawRoundRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, CornerRadius As Int, Stroke As Int, Text As String, TextColor As Int, TextSize As Int, SmallText As String)
	LCARSeffects2.DrawRoundRect(BG, X,Y, Width, Height, Color, CornerRadius)
	LCARSeffects2.DrawRoundRect(BG, X+Stroke,Y+Stroke, Width-Stroke*2, Height-Stroke*2, Colors.Black, CornerRadius-Stroke*2)
	X=X+Width*0.5
	If TextSize>0 Then API.DrawTextAligned(BG, Text, X, Y+Height*0.5, 0,  LCARSeffects3.CHX_Font,  TextSize, TextColor, 5, 0, 0)
	If SmallText.Length>0 Then API.DrawTextAligned(BG, SmallText, X, Y-Stroke*2, 0, LCARSeffects3.CHX_Font, LCAR.Fontsize*0.5, Color,2, 0,0)
End Sub

Sub DrawSanctuaryDistrictClock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Time As Long, Alpha As Int, CurrentWeather As WeatherData)
	Dim temp As Int = Y + (Height * 0.33) - (LCAR.ItemHeight*0.5), Color As Int = Colors.ARGB(Alpha, 124,165,171), tempDay As WeatherDay,Stroke As Int = 5
	Dim temp2 As Int = Width * 0.57, temp3 As Int ,temp4 As Int , Red As Int = Colors.ARGB(Alpha, 193,71,40), Temperature As String = "???"
	DrawRoundRect(BG, X,Y,Width,Height, Color, Height * 0.20, Stroke*2, "", 0, 0, "")
	
	temp3=X + Width* 0.05 
	DrawRoundRect(BG, temp3,  temp, temp2, LCAR.ItemHeight, Color, LCAR.ItemHeight*0.5 , Stroke, API.GetDateString(0, DateTime.GetDayOfWeek(Time), False), Red, LCAR.Fontsize, "TODAY" )'TODAY
	
	temp = temp + (LCAR.ItemHeight*0.2)'Y
	temp3 = temp3+ temp2 + Width*0.05'X
	temp2 = Width * 0.24'Width
	If Weather.HasWeatherData(CurrentWeather) Then
		temp4 = Weather.FindToday(CurrentWeather)
		If temp4>-1 Then
			tempDay = CurrentWeather.days.Get(temp4)
			Temperature = Round(Trig.ConvertUnits( 0, Weather.CurrentTemperature(tempDay), "C", Weather.CurrentUnits)) & CurrentWeather.Units
		End If
	End If
	DrawRoundRect(BG, temp3,  temp, temp2, LCAR.ItemHeight * 0.6, Color, LCAR.ItemHeight*0.3,  Stroke, Temperature, Red, LCAR.Fontsize*0.6, "")'TEMPERATURE
	
	temp=Y + (Height * 0.66) - (LCAR.ItemHeight * 0.5)'Y
	temp2 = Width * 0.57'Width
	temp3 = X + Width * 0.95- temp2'X
	Temperature=DateTime.getmonth(Time) & "/" & DateTime.GetDayOfMonth(Time) & "/" & ( DateTime.GetYear(Time) Mod 100 )
	DrawRoundRect(BG, temp3,  temp, temp2, LCAR.ItemHeight, Color, LCAR.ItemHeight*0.5, Stroke, Temperature, Red, LCAR.Fontsize, "DATE")'DATE

	temp= temp+ (LCAR.ItemHeight * 0.1)'Y
	temp2=Width*0.03'Width
	temp3 = temp3 - Width*0.05'X
	For temp4 = 1 To 3
		temp3 = temp3 - Width * 0.04
		DrawRoundRect(BG, temp3,  temp, temp2, LCAR.ItemHeight*0.8, Color, LCAR.ItemHeight*0.4, Stroke, "", 0, 0, "")'()
	Next
End Sub














Sub FindBattleGroup(Name As String) As Int 
	Dim temp As Int, BattleGroup As TacBattleGroup 
	For temp = 0 To BattleGroups.Size-1
		BattleGroup = BattleGroups.Get(temp)
		If Name.EqualsIgnoreCase(BattleGroup.Name) Then Return temp
	Next
	Return -1
End Sub

Sub TouchTactical(X As Int,Y As Int,EventType As Int, Width As Int, Height As Int)
	Dim X2 As Int = X/Width * TacMaxWidth, Y2 As Int = Y/Height * TacMaxHeight
	'LogColor("TOUCH " & X & " "  & Y & " " & Width & " " & Height  & " " & EventType, Colors.Green)
	If EventType = LCAR.Event_Down Then
		DirectStarship(0, "NCC-1701-E", X2,Y2)'Enterprise
		DirectStarship(0, "NCC-74656", X2,Y2)'Voyager
	End If
End Sub

Sub DirectStarship(Faction As Int, Serial As String, X As Int, Y As Int) As Boolean 
	Dim Ship As TacStarship, ShipID As Point = FindShip(Faction,Serial)
	If ShipID.X>-1 Then
		Ship = GetStarship(ShipID.X,ShipID.Y)
		Ship.Angle = Trig.GetCorrectAngle(Ship.X,Ship.Y, X,Y)
		LogColor("Directed: " & Ship.Name & " (" & Ship.Serial & ") to: " & X & " " & Y & " From: " & Ship.X & " " & Ship.Y & " course: " & Ship.Angle, Colors.Blue) 
		Return True
	End If
End Sub

'0 Starfleet (DS9/VOY era), 1 Klingon, 2 Romulan,3 Cardassian
Sub MakeBattleGroup(Name As String, Prepend As String, Faction As Int, FollowFlagship As Boolean, HasCloak As Boolean,  MaxShips As Int) As Int
	Dim BattleGroup As TacBattleGroup, temp As Int = FindBattleGroup(Name)
	If temp >-1 Then Return temp
	BattleGroup.Initialize 
	BattleGroup.Ships.Initialize 

	BattleGroup.Name=Name.ToUpperCase 
	BattleGroup.Faction=Faction
	BattleGroup.FollowFlagship=FollowFlagship
	BattleGroup.HasCloak=HasCloak
	BattleGroup.MaxShips=MaxShips
	BattleGroup.Prepend=Prepend
	
	BattleGroups.Add(BattleGroup)
	Return BattleGroups.Size-1
End Sub
'0 Starfleet (DS9/VOY era), 1 Klingon, 2 Romulan,3 Cardassian
Sub AreFactionsEnemies(Faction1 As Int, Faction2 As Int) As Boolean 
	If Faction1 = Faction2 Or Faction1 = TacPlanet Or Faction2 = TacPlanet Then Return False
	Select Case Faction1 & "." & Faction2 'only needs to handle allies
		Case "0.1", "1.0", "0.4", "4.0": Return False'Federation-Klingon, DS9/VOY-TOS
	End Select
	Return True
End Sub
'0 Starfleet (DS9/VOY era), 1 Klingon, 2 Romulan,3 Cardassian
Sub MakeStarship(BattleGroupID As Int,  Name As String, Serial As String, X As Int, Y As Int) As TacStarship
	Dim BattleGroup As TacBattleGroup = BattleGroups.Get(BattleGroupID), Ship As TacStarship, FlagShip As TacStarship, Random As Int = 15, Margin As Int = 5
	If Not(IsShipUsed(BattleGroup.Faction, Serial)) Or BattleGroup.Faction = TacPlanet Then
		Ship.Initialize
		Ship.Name = Name.ToUpperCase 
		'if API.Left(Serial,1) = "-" then Serial = rnd(
		Ship.Serial = Serial.ToUpperCase 
		Ship.Target = Trig.SetPoint(-1,-1)
		If AreFactionsEnemies(0, BattleGroup.Faction) And BattleGroup.Faction <> TacPlanet Then EnemyShips = EnemyShips + 1 Else AlliedShips = AlliedShips + 1
		If BattleGroup.HasCloak Then Ship.Cloaked = Rnd(0,2)=0
		Ship.Alpha = API.IIF(Ship.Cloaked, 0,255)
		Ship.Angle = Rnd(1,360)
		Ship.Velocity = Rnd(5,15)
		
		If X = -1 Or Y = -1 Then'randomize location
			X=Rnd(0, TacMaxWidth)
			Y=Rnd(0, TacMaxHeight)			
			If BattleGroup.FollowFlagship And BattleGroup.Ships.Size>0 Then
				FlagShip = BattleGroup.Ships.Get(0)
				X = FlagShip.X + Rnd(-Random,Random)
				Y = FlagShip.Y + Rnd(-Random,Random)
				Ship.Angle = FlagShip.Angle 
				Ship.Velocity = FlagShip.Velocity
			End If
		End If
		Ship.X = Min(Max(X, -Margin), TacMaxWidth+Margin)
		Ship.Y = Min(Max(Y, -Margin), TacMaxHeight+Margin)
		Ship.Shields=100
		
		Select Case BattleGroup.Faction 
			Case TacPlanet
				Ship.X = MinMax(Ship.X , Margin, TacMaxWidth+Margin)
				Ship.Y = MinMax(Ship.Y , Margin, TacMaxHeight+Margin)
				'Ship.Y = Min(TacMaxHeight - Margin, Max(Ship.Y, TacMaxHeight+Margin))
			Case 100: Ship.Shields=200'borg
		End Select
		
		BattleGroup.Ships.Add(Ship)
	End If
	Return Ship
End Sub
Sub MinMax(Value As Int, Smallest As Int, Biggest As Int) As Int 
	If Value < Smallest Then Value = Smallest 
	If Value > Biggest Then Value = Biggest 
	Return Value 
End Sub
Sub FindShip(Faction As Int, Serial As String) As Point 
	Dim temp As Int, temp2 As Int, BattleGroup As TacBattleGroup, Ship As TacStarship
	For temp = 0 To BattleGroups.Size -1 
		BattleGroup = BattleGroups.Get(temp)
		If BattleGroup.Faction = Faction Then
			For temp2 = 0 To BattleGroup.Ships.Size-1
				Ship = BattleGroup.Ships.Get(temp2)
				If Ship.Serial.EqualsIgnoreCase(Serial) Then Return Trig.SetPoint(temp,temp2)
			Next
		End If
	Next
	Return Trig.SetPoint(-1,-1)
End Sub
Sub IsShipUsed(Faction As Int, Serial As String) As Boolean
	Return FindShip(Faction,Serial).X > -1 
End Sub
Sub IncrementTactical(Mode As Int) As Boolean 
	Dim temp As Int, temp2 As Int, BattleGroup As TacBattleGroup
	If BattleGroups.IsInitialized And EnemyShips > 0 And AlliedShips > 0 Then 
		For temp = 0 To BattleGroups.Size -1 
			If temp < BattleGroups.Size Then
				BattleGroup = BattleGroups.Get(temp)
				For temp2 = BattleGroup.Ships.Size - 1 To 0 Step -1
					If temp2<BattleGroup.Ships.Size Then 
						IncrementStarship(BattleGroup, temp, BattleGroup.Ships.Get(temp2), temp2, False)
					End If
				Next
			End If
		Next
	Else
		If Not(BattleGroups.IsInitialized) Or AlliedShips=0 Then BattleGroups.Initialize 
		AlliedShips = 0
		EnemyShips = 0
	
		If Mode = 0 Then 
			temp = MakeBattleGroup("Planets", "", TacPlanet, False,False,1)
				MakeStarship(temp, "Planetoid", "-2", -1,-1)
		
			temp = MakeBattleGroup("STAR FLEET", "USS", 0, False, False, 2)'DS9/VOY FED
				MakeStarship(temp, "ENTERPRISE", "NCC-1701-E", -1,-1)
				MakeStarship(temp, "VOYAGER", "NCC-74656", -1,-1)
				
			temp = MakeBattleGroup("STAR FLEET battle group omega", "USS", 0, True, False, 7)
				MakeStarship(temp, "Intrepid", "NCC-74600", -1,-1)
				MakeStarship(temp, "Valiant", "NCC-75418", -1,-1)
				MakeStarship(temp, "Galaxy", "NCC-70637", -1,-1)
				MakeStarship(temp, "Aries", "NCC-45167", -1,-1)
				MakeStarship(temp, "Nova", "NCC-73515", -1,-1)
				MakeStarship(temp, "Hood", "NCC-42296", -1,-1)
				MakeStarship(temp, "Archer", "NCC-44278", -1,-1)
			
			temp = MakeBattleGroup("BORG", "VESSEL =", 100, False, False, 1)
				MakeStarship(temp, "BORG TYPE 03", "09 5054 87887", -1,-1)
			
			'http://memory-beta.wikia.com/wiki/Romulan_starships
			temp = MakeBattleGroup("ROMULAN", "RIS", 2, False, True, 1)	
				MakeStarship(temp, "Alidar", "IRC-13402", -1, -1)
				MakeStarship(temp, "Bochral", "IRC-13003", -1,-1)
		
			AlliedShips=9
			EnemyShips=3
		Else 
			temp = MakeBattleGroup("STAR FLEET", "USS", 4, False, False, 2)'TOS FED
				MakeStarship(temp, "ENTERPRISE", "NCC-1701", -1,-1)
			
			temp = MakeBattleGroup("ROMULAN", "RIS", 5, False, True, 1)	'TOS ROM
				MakeStarship(temp, "VAS HATHAM", "IRC-417", -1, -1)
			
			temp = MakeBattleGroup("PLANETS", "", TacPlanet, False, False, 1)', TacMaxWidth As Int = 500, TacMaxHeight As Int = 100
				MakeStarship(temp, "ROMULUS", "-3", 0.80*TacMaxWidth,67)'365 182 of 453 270
				MakeStarship(temp, "ROMII", "-4", 0.77*TacMaxWidth,80)'350 216 of 453 270
				MakeStarship(temp, "", "-6", 0.43*TacMaxWidth, 35)'scale 197 94
				
				MakeStarship(temp, "1", "-5", 0.40*TacMaxWidth, 87)'fed starbase 179 235
				MakeStarship(temp, "2", "-5", 205/453*TacMaxWidth, 211/270*TacMaxHeight)'fed starbase 205 211
				MakeStarship(temp, "3", "-5", 222/453*TacMaxWidth, 169/270*TacMaxHeight)'fed starbase 222 169
				MakeStarship(temp, "4", "-5", 227/453*TacMaxWidth, 122/270*TacMaxHeight)'fed starbase 227 122
				MakeStarship(temp, "5", "-5", 257/453*TacMaxWidth, 87/270*TacMaxHeight)'fed starbase 257 087
				MakeStarship(temp, "6", "-5", 282/453*TacMaxWidth, 48/270*TacMaxHeight)'fed starbase 282 048
				MakeStarship(temp, "7", "-5", 318/453*TacMaxWidth, 16/270*TacMaxHeight)'fed starbase 318 016
				
				AlliedShips=1
				EnemyShips=1
		End If 
		LogColor("START AlliedShips: " & AlliedShips & " EnemyShips: " & EnemyShips, Colors.Red) 
	End If
	Return True
End Sub
Sub IncrementStarship(BattleGroup As TacBattleGroup, BattleGroupID As Int, Ship As TacStarship, ShipID As Int, Accurate As Boolean)
 	'PhaserRechargeTime, TorpedoRechargeTime, TacPlanet, TacMaxWidth, TacMaxHeight, PhaserDamage, TorpedoDamage, SensorRange, DestroyStarship
	Dim X2 As Int, Y2 As Int, Whitespace As Int = 5, Target As Point, Distance As Int = -1, Destroyed As Boolean, EnemyBattleGroup As TacBattleGroup, Enemy As TacStarship
	If BattleGroup.Faction = TacPlanet Then Return
	Ship.Alpha = LCAR.Increment(Ship.Alpha, 16, API.IIF(Ship.Cloaked, 0, 255)) 
	If Ship.Angle mod 90 = 0 Then Ship.Angle = Ship.Angle + Rnd(1,45)
	If BattleGroup.followflagship And ShipID>0 Then 
		Enemy = BattleGroup.Ships.Get(0)'NOT THE ENEMY
		Ship.Target = Enemy.Target 
		Ship.Velocity = Enemy.Velocity 
		Ship.Angle = Enemy.Angle	
	End If
	If Ship.Target.x = -1 Then 'not targetted an enemy
		X2 = Trig.findXYAngle(Ship.X, Ship.Y, Ship.Velocity, Ship.Angle, True) Mod (TacMaxWidth + Whitespace)
		Y2 = Trig.findXYAngle(Ship.X, Ship.Y, Ship.Velocity, Ship.Angle, False) Mod (TacMaxHeight + Whitespace)
		If X2 < -Whitespace Then X2 = X2 + Whitespace + TacMaxWidth
		If Y2 < -Whitespace Then Y2 = Y2 + Whitespace + TacMaxHeight
		Ship.X=X2
		Ship.Y=Y2
		If Not(BattleGroup.followflagship) Or ShipID=0 Then Target = FindClosestEnemy(BattleGroup, BattleGroupID, Ship, ShipID, Accurate)	
		If Target.X >-1 And Target.X< BattleGroups.Size Then 
			EnemyBattleGroup = BattleGroups.Get(Target.X)
			If Target.Y < EnemyBattleGroup.Ships.Size Then
				Enemy = EnemyBattleGroup.Ships.Get(Target.Y)
				Distance = ShipDistance(Ship, Enemy, Accurate)
				If Distance <= SensorRange Then 
					Ship.PhaserRecharge  = PhaserRechargeTime
					Ship.TorpedoRecharge = TorpedoRechargeTime
					Ship.Target = Target
					Ship.Cloaked = False
				End If
			End If
		End If	
	Else 'End If	If Ship.Target.x > -1 Then 'targetted an enemy
		Destroyed=True
		If Ship.Target.X < BattleGroups.Size Then 
			EnemyBattleGroup = BattleGroups.Get(Ship.Target.X)
			If Ship.Target.Y < EnemyBattleGroup.Ships.Size Then
				Enemy = EnemyBattleGroup.Ships.Get(Ship.Target.Y)
				Destroyed = ShipDistance(Ship,Enemy,Accurate) <= SensorRange *2
			End If
		End If
		If Destroyed Then
			Destroyed= False
			Ship.Target = Trig.SetPoint(-1,-1)
		Else
			If Enemy.Cloaked Then 
				LogColor("Enemy is cloaked", Colors.Blue)
				DoShipDamage(Ship.Target.X, Ship.Target.Y,0, BattleGroupID, ShipID)
			Else If Ship.Alpha > 128 Then
				'LogColor(Ship.PhaserRecharge & " " & Ship.TorpedoRecharge, Colors.Blue)
				Ship.PhaserRecharge=Ship.PhaserRecharge-1
				Ship.TorpedoRecharge=Ship.TorpedoRecharge-1
				If Ship.PhaserRecharge<1 Then
					'LogColor(BattleGroup.Prepend & " " & Ship.name & " fired phasers at " EnemyBattleGroup.Prepend , Colors.Red)
					'Ship.PhaserRecharge=PhaserRechargeTime
					'Destroyed = DoShipDamage(Ship.Target.X, Ship.Target.Y, PhaserDamage, BattleGroupID, ShipID)
					Destroyed = FireWeapon(BattleGroup, BattleGroupID, Ship, ShipID, True, EnemyBattleGroup, Enemy)
				End If 
				If Ship.TorpedoRecharge<1 And Not(Destroyed) Then
					'LogColor(BattleGroup.Prepend & " " & Ship.name & " fired torpedoes", Colors.Red)
					'Ship.TorpedoRecharge = TorpedoRechargeTime
					'Destroyed = DoShipDamage(Ship.Target.X, Ship.Target.Y, TorpedoDamage, BattleGroupID, ShipID)
					Destroyed = FireWeapon(BattleGroup, BattleGroupID, Ship, ShipID, False, EnemyBattleGroup, Enemy)
				End If
				If Destroyed Then 
					Ship.Cloaked = BattleGroup.HasCloak 
					Ship.Target = Trig.SetPoint(-1,-1)
					'If BattleGroup.FollowFlagship 
				End If
			End If
		End If
	End If
End Sub

Sub FireWeapon(BattleGroup As TacBattleGroup, BattleGroupID As Int, Ship As TacStarship, ShipID As Int, Phasers As Boolean, EnemyBattleGroup As TacBattleGroup, EnemyShip As TacStarship)As Boolean 
	Dim Ret As Boolean, tempstr As String
	tempstr= BattleGroup.Prepend & " " & Ship.name & " fired " & API.IIF(Phasers,"phasers", "torpedoes") & " at " & EnemyBattleGroup.Prepend & " " &  EnemyShip.Name
	If Phasers Then 
		Ship.PhaserRecharge=PhaserRechargeTime
	Else
		Ship.TorpedoRecharge = TorpedoRechargeTime
	End If
	Ret= DoShipDamage(Ship.Target.X, Ship.Target.Y, API.IIF(Phasers,PhaserDamage, TorpedoDamage)+Rnd(-2,3),BattleGroupID, ShipID)
	If Ret Then 
		LogColor(tempstr & " (destroyed) AlliedShips: " & AlliedShips & " EnemyShips: " & EnemyShips, Colors.Red) 
	Else
		LogColor(tempstr & " (shields: " & Ship.Shields & "%)", Colors.Red)
	End If
	Return Ret
End Sub

Sub DoShipDamage(BattleGroupID As Int, ShipID As Int, Damage As Int, SrcBattleGroupID As Int, SrcShipID As Int) As Boolean 
	Dim BattleGroup As TacBattleGroup = BattleGroups.Get(BattleGroupID), Ship As TacStarship = BattleGroup.Ships.Get(ShipID)
	Ship.Cloaked = False
	If Ship.Target.x=-1 Then Ship.Target = Trig.SetPoint(SrcBattleGroupID, SrcShipID)
	Ship.Shields = Max(0, Ship.Shields - Damage)
	If Ship.Shields <1 Then Return DestroyStarship(BattleGroupID, ShipID, BattleGroup.Faction)
End Sub

Sub FindClosestEnemy(BattleGroup As TacBattleGroup, BattleGroupID As Int, Ship As TacStarship, ShipID As Int, Accurate As Boolean) As Point 
	Dim temp As Int, temp2 As Int, BattleGroup2 As TacBattleGroup, Ship2 As TacStarship , Distance As Int=-1, tempDistance As Int, Target As Point = Trig.SetPoint(-1,-1)
	For temp = 0 To BattleGroups.Size - 1
		BattleGroup2 = BattleGroups.Get(temp)
		If AreFactionsEnemies(BattleGroup.Faction, BattleGroup2.Faction) Then
			For temp2 = 0 To BattleGroup2.Ships.Size - 1
				Ship2 = BattleGroup2.Ships.Get(temp2)
				tempDistance = ShipDistance(Ship, Ship2, Accurate)
				If tempDistance<Distance Or Distance=-1 Then Target = Trig.SetPoint(temp, API.IIF(BattleGroup2.FollowFlagship,0, temp2))
			Next
		End If
	Next
	Return Target
End Sub
Sub ShipDistance(Ship1 As TacStarship, Ship2 As TacStarship, Accurate As Boolean) As Int 
	If Accurate Then
		Return Trig.FindDistance(Ship1.X, Ship1.Y, Ship2.X, Ship2.y)
	Else
		Return Max( Abs(Ship1.X-Ship2.X), Abs(Ship1.Y - Ship2.y))
	End If
End Sub 
Sub GetStarship(BattleGroupID As Int, ShipID As Int) As TacStarship 
	Dim BattleGroup As TacBattleGroup = BattleGroups.Get(BattleGroupID)
	Return BattleGroup.Ships.Get(ShipID)
End Sub
Sub ShipCount(BattleGroupID As Int) As Int
	Dim BattleGroup As TacBattleGroup = BattleGroups.Get(BattleGroupID)
	Return BattleGroup.Ships.size 
End Sub
Sub DestroyStarship(BattleGroupID As Int, ShipID As Int, Faction As Int) As Boolean 
	Dim temp As Int, temp2 As Int, BattleGroup As TacBattleGroup = BattleGroups.Get(BattleGroupID), Ship As TacStarship = BattleGroup.Ships.Get(ShipID)
	BattleGroup.Ships.RemoveAt(ShipID)
	For temp = 0 To BattleGroups.Size - 1
		If BattleGroup.Faction <> Faction And BattleGroup.Faction <> TacPlanet Then 
			For temp2 = 0 To BattleGroup.Ships.Size - 1 
				Ship = BattleGroup.Ships.Get(temp2)
				If Ship.Target.X = BattleGroupID And Ship.Target.Y = ShipID Then Ship.Target = Trig.SetPoint(-1,-1)
			Next
		End If 
	Next
	If AreFactionsEnemies(0, Faction) Then EnemyShips = EnemyShips-1 Else AlliedShips=AlliedShips-1
	Return True
End Sub
Sub RandomTactical() As Int 
	AlliedShips = 0
	EnemyShips = 0
	Return API.dRnd(0,2, LCAR.LCAR_Tactical2)
End Sub
Sub DrawTactical(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Mode As Int)
	'Dim Starships As List 'Type TacStarship(X As Int, Y As Int, Class As Int, Name As String, Serial As String, Alpha As Int, Cloaked As Boolean, Velocity As Int, Angle As Int)
	Dim Scalefactor As Float = LCAR.GetScalemode, GridColorID As Int = -1, TextColorID As Int = -1, StarcolorID As Int = -1, GridWidth As Int, GridHeight As Int, Font As Typeface 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "tactical.png", LCAR.LCAR_Tactical2)
	If Not(BattleGroups.IsInitialized) Then IncrementTactical(Mode)
	Width=Width+1
	Height=Height+1
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	Select Case Mode 
		Case 0'VOY/DS9
			Font = LCAR.LCARfont
			GridWidth = Width*0.1'10
			GridHeight = Height*0.2'5
		Case 1'TOS
			Font = Typeface.DEFAULT_BOLD
			GridColorID = LCAR.LCAR_Yellow
			TextColorID = LCAR.LCAR_Black
			StarcolorID = GridColorID
			GridWidth = Width * 0.05'20
			GridHeight = Height*0.1'10
	End Select
	LCARSeffects.DrawGrid(BG,X,Y,Width,Height, GridWidth, GridHeight, 0,0,True, GridColorID, TextColorID, StarcolorID)
	If Mode = 1 Then 'TOS
		DrawNeutralZone(BG,X,Y,Width,Height, Font, GridColorID)
	End If	
	DrawShips(BG,X,Y,Width,Height,Scalefactor, False, Mode, Font)
	DrawShips(BG,X,Y,Width,Height,Scalefactor, True, Mode, Font)
	BG.RemoveClip 
End Sub
Sub DrawNeutralZone(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Font As Typeface, ColorID As Int)
	Dim L As List, temp As Int, Stroke As Int = LCAR.Fontsize * 5'Width * 0.03'-70,-50
	L.Initialize
	MakeNZpoint(L,x,y,Width,Height, 0.4922737, 1.040741)'		0
	MakeNZpoint(L,x,y,Width,Height, 0.5011038, 0.9962963)'		1
	MakeNZpoint(L,x,y,Width,Height, 0.5121413, 0.9148148)'		2 	N
	MakeNZpoint(L,x,y,Width,Height, 0.5275938, 0.8444445)'		3 	E
	MakeNZpoint(L,x,y,Width,Height, 0.5408388, 0.7629629)'		4 	U
	MakeNZpoint(L,x,y,Width,Height, 0.5540839, 0.6888889)'		5 	T
	MakeNZpoint(L,x,y,Width,Height, 0.5651214, 0.6259259)'		6 	R
	MakeNZpoint(L,x,y,Width,Height, 0.580574, 0.5555556)'		7 	A
	MakeNZpoint(L,x,y,Width,Height, 0.593819, 0.4888889)'		8 	L
	MakeNZpoint(L,x,y,Width,Height, 0.6004415, 0.4333333)'		9
	MakeNZpoint(L,x,y,Width,Height, 0.611479, 0.4074074)'		10
	MakeNZpoint(L,x,y,Width,Height, 0.6335541, 0.362963)'		11 	Z
	MakeNZpoint(L,x,y,Width,Height, 0.6644592, 0.3074074)'		12 	O
	MakeNZpoint(L,x,y,Width,Height, 0.6909492, 0.2407407)'		13 	N
	MakeNZpoint(L,x,y,Width,Height, 0.7196468, 0.1888889)'		14 	E
	MakeNZpoint(L,x,y,Width,Height, 0.7637969, 0.1148148)'		15
	MakeNZpoint(L,x,y,Width,Height, 0.8013245, 5.555556E-02)'	16
	MakeNZpoint(L,x,y,Width,Height, 0.8366446, 7.407407E-03)'	17
	MakeNZpoint(L,x,y,Width,Height, 0.8587196, -5.185185E-02)'	18
	
	BG.DrawPath(MakePath(L, 5), LCAR.GetColor(ColorID, False, 128), False, Stroke)
	
	'BG.DrawTextRotated("N  E  U  T  R  A  L", X + Width*0.5121413, Y + Height * 0.9111111, LCAR.LCARfont, LCAR.Fontsize, Colors.red, "LEFT", FirstAngle+5)
	Stroke = FindSpaces(BG, "NEUTRAL", Font, LCAR.Fontsize, Height * 0.5, 10)
	DrawNZtext(BG, L, 287, 187, 2, "NEUTRAL", Font, Stroke)
	DrawNZtext(BG, L, 310, 135, 11, "ZONE", Font, Stroke)
	'DrawNZtext(BG, L, FirstAngle,   2, "NEUTRAL")
	'DrawNZtext(BG, L, SecondAngle, 11, "ZONE")
	
	temp = LCAR.GetColor(LCAR.LCAR_Orange, False, 255)
	Stroke = LCAR.Fontsize*1.5
	API.DrawTextAligned(BG, "EARTH OUTPOST" & CRLF & "SECTOR Z-6", X + Width * 0.31, Y + Height * 0.16, 0, Font, Stroke, temp, 1, 0,0)'140 43 of 453 270
	API.DrawTextAligned(BG, "ROMULAN" & CRLF & "STAR EMPIRE", X + Width * 0.95, Y + Height * 0.45, 0, Font, Stroke, temp, 3, 0,0)'432 121 of 453 270
End Sub

Sub FindSpaces(BG As Canvas, Text As String, Font As Typeface, TextSize As Int, MinWidth As Int, MaxSpaces As Int) As Int 
	Dim temp As Int, tempstr As StringBuilder
	tempstr.Initialize
	tempstr.Append(Text)
	For temp = 1 To MaxSpaces - 1
		tempstr.Append( MakeString(" ", Text.Length) )
		If BG.MeasureStringWidth(tempstr.ToString, Font, TextSize) >= MinWidth Then Return temp '- 1
	Next
	Return MaxSpaces
End Sub

Sub MakePath(L As List, Polygons As Int) As Path
	Dim temp As Int, P As Path, PT(3) As Point
	For temp = 0 To L.Size - 3 Step 2
		PT(0) = L.Get(temp)
		PT(1) = L.Get(temp+1)
		PT(2) = L.Get(temp+2)
		LCARSeffects4.MakeCurvePath( PT(0).X, PT(0).Y, PT(1).X, PT(1).Y, PT(2).X, PT(2).Y, 1/Polygons, P)
	Next
	Return P 
End Sub
Sub MakeString(Text As String, Quantity As Int) As String
	Dim tempstr As StringBuilder
	tempstr.Initialize
	Do Until Quantity < 1
		tempstr.Append(Text)
		Quantity = Quantity - 1
	Loop
	Return tempstr.ToString
End Sub
Sub AddSpaces(Text As String, Spaces As Int) As String
	Dim tempstr As StringBuilder, temp As Int, tempstr2 As String = MakeString(" " , Spaces)
	If Spaces = 0 Then Return Text 
	tempstr.Initialize
	For temp = 0 To Text.Length - 2
		tempstr.Append( API.Mid(Text, temp, 1) & tempstr2)
	Next
	tempstr.Append( API.Right(Text,1) )
	Return tempstr.ToString
End Sub
Sub DrawNZtext(BG As Canvas, L As List, Angle As Int, SecondAngle As Int, Index As Int, Text As String, Font As Typeface, Spaces As Int)
	Dim PT As Point = L.Get(Index), Distance As Int = LCAR.LCARfontheight * 0.5, X As Int, Y As Int', Angle2 As Int = Angle-270
	X = Trig.findXY(PT.X, PT.Y, Distance, SecondAngle, True)
	Y = Trig.findXY(PT.X, PT.Y, Distance, SecondAngle, False)
	BG.DrawTextRotated(AddSpaces(Text, Spaces), X, Y, Font, LCAR.Fontsize, Colors.Black, "LEFT", Angle)
	'BG.DrawLine(X,Y, PT.X, PT.Y, Colors.Red, 2)
End Sub
Sub MakeNZpoint(L As List, X As Int, Y As Int, Width As Int, Height As Int, Xp As Float, Yp As Float) As Point
	X = X + Width * Xp
	Y = Y + Height * Yp
	L.Add(Trig.SetPoint(X,Y))'LCARSeffects3.MakePoint(P,X,Y)
End Sub
Sub DrawShips(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Scalefactor As Float, Full As Boolean, Mode As Int, Font As Typeface)
	Dim temp As Int
	For temp = 0 To BattleGroups.Size - 1
		DrawBattleGroup(BG,X,Y,Width,Height,Scalefactor, BattleGroups.Get(temp), Full, Mode, Font)
	Next
End Sub
Sub DrawBattleGroup(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Scalefactor As Float, BattleGroup As TacBattleGroup , Full As Boolean, Mode As Int, Font As Typeface)
	Dim temp As Int, Ship As TacStarship, Radius As Int= 150 *  Scalefactor, Y2 As Int, X2 As Int, Dest As Point, Height2 As Int, Whitespace As Int = 1, Align As Int = 6
	For temp = 0 To BattleGroup.Ships.Size-1
		Ship = BattleGroup.Ships.Get(temp)
		Dest = DrawStarship(BG,X,Y,Width,Height,Scalefactor, BattleGroup, Ship, Full, Mode, Font)
		If BattleGroup.FollowFlagship Then
			If temp = 0 Then 
				If Ship.X > TacMaxWidth * 0.5 Then
					X2 = Dest.X - (Radius*1.20)
				Else
					X2 = Dest.X + (Radius*1.20)
					Align=4
				End If
				Height2 = API.TextHeightAtHeight(BG, Font, BattleGroup.Name,  LCAR.Fontsize+2) + Whitespace + ( API.TextHeightAtHeight(BG, Font, Ship.Name,  LCAR.Fontsize)+Whitespace) * BattleGroup.Ships.Size 
				Y2 = Dest.Y - Height2*0.5
				Height2= API.DrawTextAligned(BG, BattleGroup.Name, X2,Y2,0, Font, LCAR.Fontsize+2,  Colors.White, Align, 0,0)
				'BG.DrawCircle(X2+ API.IIF(Align = 6, 6,-6)*Scalefactor ,Y2 + Height2*0.25, 4*Scalefactor, Colors.White,True, 0) 
				API.DrawTextAligned(BG, "•", X2+API.IIF(Align = 6, 10,-25)*Scalefactor,Y2+Height2*0.5-BG.MeasureStringHeight("•", Font, LCAR.Fontsize+2),0, Font, LCAR.Fontsize+2,  Colors.White, -1, 0,0)
				Y2=Y2+Height2+Whitespace
				DrawBrokenCircle(BG, Dest.X, Dest.Y, Radius, Colors.White, 10*Scalefactor, 20*Scalefactor)
			End If
			Y2=Y2+ API.DrawTextAligned(BG, BattleGroup.Prepend & " " & Ship.Name & " " & Ship.serial, X2,Y2,0, Font, LCAR.Fontsize,  Colors.White, Align, 0,0)+Whitespace
		End If
	Next
End Sub
Sub DrawStarship(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Scalefactor As Float, BattleGroup As TacBattleGroup, Ship As TacStarship, Full As Boolean, Mode As Int, Font As Typeface) As Point 
	Dim ColorID As Int = 32, Radius1 As Int=100, Radius2 As Int=150, Radius3 As Int=200, R As Int=29, G As Int, B As Int=193
	X = X + (Width *  (Ship.X/TacMaxWidth))
	Y = Y + (Height * (Ship.Y/TacMaxHeight))
	If Full Then
		If BattleGroup.Faction = TacPlanet Then
			If Mode = 0 Then DrawBMP(BG,X,Y,Scalefactor, -1, 255)
			If Ship.Serial < -4 Then Scalefactor = Scalefactor * 2
			Radius1 = DrawBMP(BG,X,Y,Scalefactor, Ship.Serial , 255)
			If Mode = 1 Then API.DrawTextAligned(BG, Ship.Name, X, Radius1, 0, Font, LCAR.Fontsize, LCAR.GetColor(LCAR.LCAR_Yellow, False, Ship.Alpha), 8, 0,0)
		Else If Ship.Alpha>0 Then
			DrawBMP(BG,X,Y,Scalefactor, Abs(BattleGroup.Faction), Ship.Alpha)
			If Not(BattleGroup.FollowFlagship) Then
				Select Case BattleGroup.Faction
					Case 0,1:	ColorID = LCAR.LCAR_Orange 
					Case 4:		ColorID = LCAR.LCAR_Yellow
					Case Else:  ColorID = LCAR.LCAR_Red
				End Select
				If Mode = 1 Then ColorID = LCAR.LCAR_Yellow
				API.DrawTextAligned(BG, ShipText(BattleGroup, Ship) , X-(75*Scalefactor), Y+ (50*Scalefactor),  0, Font, LCAR.Fontsize, LCAR.GetColor(ColorID, False, Ship.alpha), 4, 0,0)
			End If
		End If
	Else If Ship.Target.X>-1 And Ship.Alpha>0 Then'AND Not(Ship.Cloaked) Then'weapons ranges
		Select Case BattleGroup.Faction 
			Case 0,1'klingon, federation
			Case Else
				R=239
				G=33
				B=19
				Radius1=160
				Radius2=200
				Radius3=220
		End Select
		If Ship.Alpha<255 Then ColorID = ColorID * (Ship.Alpha/255)'cloaking/decloaking
		DrawCircle(BG,X,Y, Radius1*Scalefactor, R,G,B, ColorID, 255, 3)
		DrawCircle(BG,X,Y, Radius2*Scalefactor, R,G,B, ColorID, 255, 3)
		DrawCircle(BG,X,Y, Radius3*Scalefactor, R,G,B, ColorID, 255, 3)
	End If
	Return Trig.SetPoint(X,Y)
End Sub
Sub ShipText(BattleGroup As TacBattleGroup, Ship As TacStarship) As String 
	Dim tempstr As StringBuilder, Particle As String = "PHASERS"
	Select Case BattleGroup.Faction 
		Case 1,2: Particle = "DISRUPTORS" 'klingons, romulans
	End Select
	tempstr.Initialize 
	tempstr.Append(BattleGroup.Prepend & " " & Ship.Name & CRLF & Ship.Serial)
	If Ship.Alpha < 255 Then tempstr.Append(CRLF & API.IIF(Ship.Cloaked, "CLOAKING", "DECLOAKING"))
	'If Ship.PhaserRecharge>0 Then tempstr.Append(CRLF & Particle & " CHARGING")
	'If Ship.TorpedoRecharge>0 Then tempstr.Append(CRLF & "TORPEDOES LOADING")
	Return tempstr.ToString 
End Sub
Sub DrawBMP(BG As Canvas, X As Int, Y As Int, Scalefactor As Float, Index As Int, Alpha As Int) As Int 
	Dim Src As Rect = GetRect(Index), Width As Int = Src.Right-Src.Left, Height As Int = Src.Bottom - Src.Top , Width2 As Int = Width*Scalefactor, Height2 As Int = Height*Scalefactor
	LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, Src.Left, Src.Top, Width,Height, X- Width2*0.5, Y - Height2 * 0.5, Width2,Height2,Alpha, False,False)
	Return Y + Height2 * 0.5 + 2
End Sub
Sub GetRect(Index As Int) As Rect 
	Select Case Index  
		Case -6: Return LCARSeffects4.SetRect(	472,  259,	72,		22)'scale
		Case -5: Return LCARSeffects4.SetRect(	428,  262,	18,		19)'federation starbase
		Case -4: Return LCARSeffects4.SetRect(	446,  260,	26,		21)'yellow dot no ring planet
		Case -3: Return LCARSeffects4.SetRect(	498, 	0,	46,		39)'red dot with ring planet
			
		Case -2: Return LCARSeffects4.SetRect(	292,	39,	252,	130)'Yellow ringed planet
		Case -1: Return LCARSeffects4.SetRect(	0,		36,	292,	245)'Planet Background
	
		Case 0: Return LCARSeffects4.SetRect(	0,		0,	43, 	36)	'Starfleet (DS9/VOY era)
		Case 1: Return LCARSeffects4.SetRect(	43,		0,	30,		36)	'Klingon
		Case 2: Return LCARSeffects4.SetRect(	73,		0,	53,		35)	'Romulan
		Case 3: Return LCARSeffects4.SetRect(	126,	0,	22,		35)	'Cardassian
		Case 4: Return LCARSeffects4.SetRect(	148,	0,	27, 	36)	'Starfleet (TOS era)
		Case 5: Return LCARSeffects4.SetRect(	176,	0,	39, 	37)	'Romulan (TOS era)
			
		'Borg, Ferengi
		Case Else: Return LCARSeffects4.SetRect(API.iif(DateTime.GetSecond(DateTime.Now) Mod 2 =0,452,498), 0,46,39)'Blinking dot
	End Select
End Sub
Sub DrawCircle(BG As Canvas, X As Int, Y As Int, Radius As Int, R As Int, G As Int, B As Int, InternalAlpha As Int, EdgeAlpha As Int, Stroke As Int)
	BG.DrawCircle(X,Y, Radius, Colors.ARGB(InternalAlpha,R,G,B), True,0)
	BG.DrawCircle(X,Y, Radius, Colors.ARGB(EdgeAlpha,R,G,B), False,Stroke)
End Sub
Sub DrawBrokenCircle(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Stroke As Int, Break As Int)
	Dim P As Path 
	P.Initialize(X-Radius-Break, Y+Break)
	P.LineTo(X+Radius+Break, Y+Break)
	P.LineTo(X+Radius+Break,Y+Radius+Break)
	P.LineTo(X+Break,Y+Radius+Break)
	P.LineTo(X+Break,Y+Break)
	P.LineTo(X-Break,Y+Break)
	P.LineTo(X-Break,Y+Radius+Break)
	P.LineTo(X-Radius-Break, Y+Radius+Break)
	P.LineTo(X-Radius-Break, Y+Break)
	BG.ClipPath(P)
	BG.DrawCircle(X,Y,Radius, Color, False, Stroke)
	BG.RemoveClip 
	
	P.Initialize(X-Radius-Break, Y-Break)
	P.LineTo(X+Radius+Break, Y-Break)
	P.LineTo(X+Radius+Break,Y-Radius-Break)
	P.LineTo(X+Break,Y-Radius-Break)
	P.LineTo(X+Break,Y-Break)
	P.LineTo(X-Break,Y-Break)
	P.LineTo(X-Break,Y-Radius-Break)
	P.LineTo(X-Radius-Break, Y-Radius-Break)
	P.LineTo(X-Radius-Break, Y-Break)
	BG.ClipPath(P)
	BG.DrawCircle(X,Y,Radius, Color, False, Stroke)
	BG.RemoveClip 
End Sub








Sub DrawUFPlogo(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, Alpha As Int)'476-316=160
	Dim Size As Point = API.Thumbsize(316, 246, Width+0,Height+0, True, False), X2 As Int, Y2 As Int, Width2 As Int, Height2 As Int, Height3 As Int=Size.X*0.15, CenterX As Int, CenterY As Int
	Dim Y3 As Int, Y4 As Int 
	X2 = Trig.findXYAngle(0,0, Size.X*0.5, Angle, True)
	Y2 = Trig.findXYangle(0,0, Height3*0.5, Angle,False)
	Width2=Width*0.5
	Height2 = Height*0.5
	CenterX = X + Width2
	CenterY = Y+Height*0.5
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "ufp2.png", LCAR.LCAR_UFP)
	'LCAR.DrawUnknownElement(BG, CenterX-Size.X*0.5, CenterY-Size.y*0.5, Size.x,Size.y, LCAR.LCAR_Orange, False, 255, Angle)
	Y3=CenterY-Height2+Height3
	Y4=CenterY+Height2-Height3
	
	LCARSeffects2.DrawBMPpoly(BG, LCARSeffects2.CenterPlatform, Array As Float(316,0,	476,0,	476,246,	316,246), Array As Float(CenterX+X2, Y3 + Y2,  	 CenterX, Y3,			CenterX, Y4,			CenterX+X2, Y4 - Y2), Alpha, True)
	LCARSeffects2.DrawBMPpoly(BG, LCARSeffects2.CenterPlatform, Array As Float(0,0, 	316,0,	316,246,	0,246), Array As Float(CenterX-X2, Y3 + Y2,  	CenterX+X2, Y3 - Y2,	CenterX+X2, Y4 + Y2,	CenterX-X2, Y4 - Y2), Alpha, True)
	LCARSeffects2.DrawBMPpoly(BG, LCARSeffects2.CenterPlatform, Array As Float(316,0,	476,0,	476,246,	316,246), Array As Float(CenterX-X2, Y3 - Y2,  	 CenterX, Y3,			CenterX, Y4,			CenterX-X2, Y4 + Y2), Alpha, True)
End Sub










Sub IncrementQnet() As Boolean 
	Dim MinAngle As Int = 80, MaxAngle As Int = 100, Speed As Int = 1, temp As Int, Stars As Int = 50 'Dim Q_Angles(3) As TweenAlpha
	If Not(Q_BMP.IsInitialized) Then 
		Q_BMP.Initialize(File.DirAssets, "q.png")
		Q_Stars.Initialize 
		For temp = 1 To Stars
			Q_Stars.Add(Rnd(0,100)*0.01)
			Q_Stars.Add(Rnd(0,100)*0.01)
		Next
	End If
	For temp = 0 To Q_Angles.Length-1
		If Q_Angles(temp).IsInitialized Then
			Q_Angles(temp).Current =  LCAR.Increment(Q_Angles(temp).Current, Speed, Q_Angles(temp).Desired)
			If Q_Angles(temp).Current = Q_Angles(temp).Desired Then	Q_Angles(temp).Desired = API.IIF(Q_Angles(temp).Desired=MinAngle, MaxAngle,MinAngle)
		Else
			Q_Angles(temp).Initialize 
			Q_Angles(temp).Current = Rnd(MinAngle, MaxAngle)
			Q_Angles(temp).Desired = MaxAngle
		End If
	Next
	LCARSeffects3.IncrementStars(False)
	Return True 
End Sub
Sub QDirection(Q_Angle As TweenAlpha, MinAngle As Int, MaxAngle As Int) As Boolean 
	If Q_Angle.Desired = MaxAngle Then' Down/True = going to MaxAngle
		Return Q_Angle.Current < MaxAngle
	Else' Q_Angle.Desired = MinAngle then
		Return Q_Angle.Current <= MinAngle 
	End If
End Sub
Sub DrawQnet(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim MinAngle As Int = 80, MaxAngle As Int = 100, Speed As Int = 1, Scalefactor As Float = LCAR.GetScalemode, Size As Int, Size2 As Int,Size3 As Int,Size4 As Int 
	If Not(Q_Angles(0).IsInitialized) Then IncrementQnet'Initialize
	If LCARSeffects3.StarBG And LCARSeffects3.StarFull Then 
		Size = LCARSeffects2.CenterPlatform.Width/LCARSeffects2.CenterPlatform.Height*Height
		LCARSeffects.MakeClipPath(BG,X,Y, Size+1, Height+1)'LCARSeffects2.CenterPlatform
	End If
	
	'draw stars
	For Size = 0 To Q_Stars.Size -1 Step 2
		Size2=Q_Stars.Get(Size)*Width'X
		Size3=Q_Stars.Get(Size+1)*Height'Y
		Size4 = Max(1,(Size Mod 4)*Scalefactor)'Size
		BG.DrawCircle(X+Size2, Y+Size3, Size4, Colors.White, True,0)
	Next
	
	'Draw Net
	Size=Q_BMP.Height 
	Size3=Size*Scalefactor
	Size2 = Size3*0.5
	Size4 = Size2*0.5
	DrawQnetLayer(BG,X -Size4,Y-Size3,Width+Size4,Height+Size3, Q_Angles(2).Current, Q_Angles(2).Desired = MaxAngle, Size*2,0,Size,Scalefactor,MinAngle,MaxAngle,Speed)'.
	DrawQnetLayer(BG,X -Size2,Y-Size3,Width+Size2,Height+Size3, Q_Angles(0).Current, QDirection(Q_Angles(0),MinAngle,MaxAngle), Size,0,Size,Scalefactor,MinAngle,MaxAngle,Speed)'_|
	DrawQnetLayer(BG,X,Y-Size3,Width,Height+Size3, Q_Angles(1).Current, QDirection(Q_Angles(1),MinAngle,MaxAngle), 0,0,Size,Scalefactor,MinAngle,MaxAngle,Speed)'-
	
	'Draw image
	If LCARSeffects3.StarBG And LCARSeffects3.StarFull Then BG.RemoveClip 
	LCARSeffects3.DrawStarBG(BG,X,Y,Width,Height, False)
End Sub
Sub DrawQnetLayer(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, GoingDown As Boolean, SrcX As Int, SrcY As Int, SrcSize As Int, Scalefactor As Float, MinAngle As Int, MaxAngle As Int, Speed As Int)
	Dim EndX As Int = X+Width, EndY As Int = Y+Height, Size As Int = SrcSize*Scalefactor, DistanceX As Int,DistanceY As Int,Y2 As Int = Y, Y3 As Int, DestAngle As Int , DrawX As Boolean , DrawY As Boolean 
	Dim Cache As Bitmap, BG2 As Canvas , Y4 As Int 
	Cache.InitializeMutable(Size,Size*2)
	BG2.Initialize2(Cache)
	Do Until X >= EndX
		DrawX=Not(DrawX)
		DrawY=DrawX
		DistanceX = Trig.findXYAngle(0,0, Size, Angle, True)
		DistanceY = Trig.findXYAngle(0,0, Size, Angle, False)
		
		LCARSeffects.MakeClipPath(BG2, 0,0, DistanceX,Cache.Height)
		BG2.DrawColor(Colors.Transparent)
		Y4=API.IIF(DistanceY>=0,0,-DistanceY)
		LCARSeffects2.DrawBMPpoly(BG2, Q_BMP, Array As Float(SrcX, SrcY, SrcX+SrcSize,SrcY,  SrcX+SrcSize,SrcY+SrcSize, SrcX,SrcY+SrcSize), Array As Float(0,Y4, DistanceX,Y4+DistanceY, DistanceX,Y4+DistanceY+Size, 0,Y4+Size), 255, False)
				
		'LCARSeffects.MakeClipPath(BG, X,Y, DistanceX,Height)
		For Y3=Y2 To EndY Step Size 
			If DrawY Then	
				BG.DrawBitmap(Cache, Null, LCARSeffects4.SetRect(X, Y3 + API.IIF(DistanceY>=0,0,DistanceY)  ,Cache.Width, Cache.Height))
				'LCARSeffects2.DrawBMPpoly(BG, Q_BMP, Array As Float(SrcX, SrcY, SrcX+SrcSize,SrcY,  SrcX+SrcSize,SrcY+SrcSize, SrcX,SrcY+SrcSize), Array As Float(X,Y3, X+DistanceX,Y3+DistanceY, X+DistanceX,Y3+DistanceY+Size, X,Y3+Size), 255, False)
			End If
			DrawY=Not(DrawY)
		Next
		'BG.RemoveClip 
		X=X+DistanceX
		Y2=Y2+DistanceY
		
		DestAngle=API.IIF(GoingDown, MaxAngle, MinAngle)
		Angle = LCAR.Increment(Angle, Speed, DestAngle)
		If Angle = DestAngle Then GoingDown = Not(GoingDown)
		
		'If GoingDown Then
		'	Angle = Angle + Speed
		'	If Angle >=MaxAngle Then GoingDown = False
		'Else
		'	Angle = Angle - Speed
		'	If Angle <= MinAngle Then GoingDown = True
		'End If
	Loop
End Sub













Sub GetP(Text As String, Digit As Int) As Int 
	Dim DigitS As String = Text.SubString2(Digit,Digit+1)
	If DigitS="A" Then Return 10 
	Return DigitS
End Sub 
Sub GetP2(Text1 As String, Text2 As String, Digit As Int, Percent As Float, Height As Int) As Int 
	Dim P1 As Int = GetP(Text1, Digit), P2 As Int = GetP(Text2, Digit),Value As Int 
	If P1=P2 Then 
		Value = P1
	Else If P1 < P2 Then
		Value = (P2-P1) * Percent + P1
	Else'if p1 > p2 then
		Value = (P1-P2) * (1-Percent) + P2
	End If
	Return Value * 0.1 * Height
End Sub
Sub DrawSmallGraph2(X As Int, Y As Int, Width As Int, Height As Int, Text As String, Percent As Float) As Path
	Dim Length As Int = Text.Length * 0.5, Text1 As String = API.Left(Text, Length), Text2 As String = API.Right(Text,Length)
	Return DrawSmallGraph(X,Y,Width,Height,Text1,Text2,Percent)
End Sub
Sub NewGraph2(OldGraph As String) As String 
	Dim Length As Int = OldGraph.Length * 0.5, Text1 As String = API.Right(OldGraph, Length), Text2 As String = NewGraph(Length)
	Return Text1 & Text2 
End Sub
Sub NewGraph(Digits As Int) As String 
	Dim tempstr As StringBuilder, temp As Int, RandomNumber As Int 
	tempstr.Initialize 
	For temp = 1 To Digits
		RandomNumber = Rnd(0,11)
		If RandomNumber = 10 Then 
			tempstr.Append("A")
		Else
			tempstr.Append(RandomNumber)
		End If
	Next
	Return tempstr.ToString 
End Sub
Sub DrawSmallGraph(X As Int, Y As Int, Width As Int, Height As Int, Text1 As String, Text2 As String, Percent As Float) As Path
	Dim Columns As Int = Text1.Length, ColumnWidth As Int = Width/Columns, temp As Int, X2 As Int = X, CurrPoint As Int, P As Path
	For temp = 0 To Columns-1 
		CurrPoint = Y + GetP2(Text1,Text2,temp, Percent, Height) 
		If temp = 0 Then 
			P.Initialize(X,CurrPoint)
		Else
			P.LineTo(X2,CurrPoint)
		End If
		If temp = Columns-2  Then 
			X2 = X+Width
		Else
			X2= X2+ColumnWidth
		End If
	Next
	'BG.DrawPath(P, Color, False, Stroke)
	Return P 
End Sub

Sub ScaleWithin(outerX As Int, outerY As Int, outerWidth As Int, outerHeight As Int, innerX As Float, innerY As Float, innerWidth As Float, innerHeight As Float) As Rect 
	Return LCARSeffects4.SetRect(outerX+(outerWidth*innerX), outerY+(outerHeight*innerY), outerWidth*innerWidth, outerHeight*innerHeight)
End Sub
Sub ScaleWithin2(outer As Rect, innerX As Float, innerY As Float, innerWidth As Float, innerHeight As Float) As Rect 
	Return ScaleWithin(outer.Left, outer.Top, outer.Right-outer.Left, outer.Bottom-outer.Top,     innerX,innerY,innerWidth,innerHeight)
End Sub
Sub ClipRect(BG As Canvas, DEST As Rect)
	LCARSeffects.MakeClipPath(BG, DEST.Left, DEST.Top, DEST.Right-DEST.Left, DEST.Bottom-DEST.Top)
End Sub

Sub DrawWarpField(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int, State As Boolean, Stage As Int)
	Dim Flags As Int, SideField As Rect, TopField As Rect, Percent As Float = Stage * 0.01, Half As Float = 0.46, Color As Int = LCAR.GetColor(ColorID,State,Alpha)
	'If API.debugMode Then Flags = 8'draw background
	WF_RND_ID=0
	DrawBlock2(BG, X + Width * 0.82809, Y + Height * 0.95579, Width * 0.17191, 0, 0, Height * 0.04421, LCAR.LCAR_DarkPurple) 'WF_RND_ID = 14
	
	LCAR.ActivateAA(BG,True)
	SideField = ScaleWithin(X,Y,Width,Height, 0.26634, 0.2, 0.64165, 0.16421)'0.26574, 0.19944, 0.63981, 0.16394
	TopField = ScaleWithin(X,Y,Width,Height, 0.26634, 0.48842, 0.64165, 0.37053)
	
	'ClipRect(BG,SideField) 'TOP
	Wireframe.DrawSVG3(BG,SideField, "warpfield", 0, -1, LCAR.LCAR_Black, State, Alpha, 20, 0, Flags)'side field lines
	Wireframe.DrawSVG3(BG,SideField, "warpfield", 0, -1, LCAR.LCAR_LightBlue, State, Alpha, 2, 0, Flags)'side field lines
	ClipRect(BG,SideField)
	Pulsate(BG,SideField,Percent, 0.520115, 0.51379)
	
	'ClipRect(BG,TopField) 'SIDE
	Wireframe.DrawSVG3(BG,TopField, "warpfield", 1, -1, LCAR.LCAR_Black, State, Alpha, 20, 0, Flags)'top field lines
	Wireframe.DrawSVG3(BG,TopField, "warpfield", 1, -1, LCAR.LCAR_Black, State, Alpha, 20, 0, 2)'top field lines, flip Y
	
	Wireframe.DrawSVG3(BG,TopField, "warpfield", 1, -1, LCAR.LCAR_LightBlue, State, Alpha, 2, 0, Flags)'top field lines
	Wireframe.DrawSVG3(BG,TopField, "warpfield", 1, -1, LCAR.LCAR_LightBlue, State, Alpha, 2, 0, 2)'top field lines, flip Y
	ClipRect(BG,TopField)
	Pulsate(BG,TopField,Percent, 0.520115, 0.5)
	BG.RemoveClip
	
	Percent = Width * 0.07506'width of small unit
	Wireframe.DrawSVG3(BG,ScaleWithin2(SideField, 0.54993, 0.51379, 0.20741, 0), "warpfield", 2, -1, LCAR.LCAR_Orange, State, Alpha, 0, 0, 48)'side ent
	LCARSeffects2.DrawLabel(BG, SideField, 0.52, 0, -0.30, Color, 3, "[BLOCK]", Percent, X, Width, Half)
	LCARSeffects2.DrawLabel(BG, SideField, 0.8, 0.05, -0.05, Color, 2, "[BLOCK]", Percent, X, Width, Half)
	DrawBlock(BG, SideField, X+Width, 0.5, Percent, 10, Color, 6)
	LCARSeffects2.DrawLabel(BG, SideField, 0.8, 0.72, 0.27, Color, 2, "[BLOCK]", Percent, X, Width, Half)
	
	Wireframe.DrawSVG3(BG,ScaleWithin2(TopField, 0.54993, 0.5, 0.20741, 0), "warpfield", 3, -1, LCAR.LCAR_Orange, State, Alpha, 0, 0, 48)'top ent
	LCARSeffects2.DrawLabel(BG, TopField, 0.8, 0.08, -0.05, Color, 2, "[BLOCK]", Percent, X, Width, Half)
	DrawBlock(BG, TopField, X+Width, 0.25, Percent, 10, LCAR.GetColor(LCAR.LCAR_LightBlue, State,Alpha), 6)
	DrawBlock(BG, TopField, X+Width, 0.5, Percent, 0, Color, 6)
	DrawBlock(BG, TopField, X+Width, 0.75, Percent, 10, Color, 6)
	LCARSeffects2.DrawLabel(BG, TopField, 0.8, 0.92,  0.05, Color, 2, "[BLOCK]", Percent, X, Width, Half)
	LCARSeffects2.DrawLabel(BG, TopField, 0.52, 1, 0.15, Color, 3, "[BLOCK]", Percent, X, Width, Half)
	
	Half = SideField.Bottom - SideField.Top 
	LCARSeffects4.DrawRect(BG, X+Width - Percent, SideField.Top + Half * -0.3 -20, Percent, 10, Color, 0)
	
	X = X + Width * 0.09927-1'width of left column
	Half = Height * 0.27579'top of left elbow
	DrawBlock2(BG, X, Y+Half, Percent, 10, Color, Height * 0.04632, LCAR.LCAR_Orange)
	
	Y = Height * 0.61473 + 2 + LCAR.ListitemWhiteSpace'start of buttons
	Half = Height * 0.04632'height of lower blocks
	DrawBlock2(BG, X, Y-1, Percent, 10, Color, Half, LCAR.LCAR_Orange)
	DrawBlock2(BG, X, Y + Half + 2, Percent, 10, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), Half, LCAR.LCAR_DarkOrange)
	DrawBlock2(BG, X, Y + Half*2 + 5, Percent, 10, Color, Half, LCAR.LCAR_Orange)
	
	LCAR.ActivateAA(BG,False)
End Sub

Sub IncrementWarpField(Element As LCARelement) As Boolean 
	Element.LWidth = Element.LWidth + 5
	If Element.LWidth >= 25 Then Element.LWidth = 0
	Return True
End Sub

Sub Pulsate(BG As Canvas, Dest As Rect, Percent As Float, CenterX As Float, CenterY As Float)
	Dim Width As Int = Dest.Right-Dest.Left, Height As Int = Dest.Bottom-Dest.Top, Radius As Int = Max(Width, Height) * 0.5, X As Int = Dest.Left + Width * CenterX, Y As Int = Dest.Top + Height * CenterY
	
	DrawCircles(BG, X, Y, Radius * Percent)
	DrawCircles(BG, X, Y, Radius * (Percent + 0.25) )
	DrawCircles(BG, X, Y, Radius * (Percent + 0.50) )
	DrawCircles(BG, X, Y, Radius * (Percent + 0.75) )
End Sub
Sub DrawCircles(BG As Canvas, X As Int, Y As Int, Radius As Int)
	Dim Color As Int = Colors.ARGB(64, 0,0,0)
	BG.DrawCircle(X, Y, Radius, Color, False, 20)
	BG.DrawCircle(X, Y, Radius, Color, False, 10)
	BG.DrawCircle(X, Y, Radius, Color, False, 5)
	BG.DrawCircle(X, Y, Radius, Color, False, 1)
End Sub
Sub DrawBlock(BG As Canvas, Dest As Rect, X As Int, Y As Float, Width As Int, SmallWidth As Int, Color As Int, Height As Int)
	Dim DestHeight As Int = Dest.Bottom-Dest.Top
	X = X-Width
	Y = Dest.Top + DestHeight * Y
	LCARSeffects4.DrawRect(BG, X, Y, Width, Height, Color, 0)
	If SmallWidth > 0 Then LCARSeffects4.DrawRect(BG, X-SmallWidth, Y, SmallWidth, 2, Color, 0)
	
	LCARSeffects2.DrawNumberBlock(BG,x, y+Height+2, Width, Height*5, LCAR.LCAR_Orange, WF_RND_ID, LCAR.LCAR_WarpField, "")
	WF_RND_ID = WF_RND_ID + 1
End Sub
Sub DrawBlock2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Height2 As Int, ColorID As Int)
	If Height >0 Then LCARSeffects4.DrawRect(BG, X, Y, Width, Height, Color, 0)
	If X+Width > 0 Then LCARSeffects2.DrawNumberBlock(BG,x, y+Height+2, Width, Height2-Height-2, ColorID, WF_RND_ID, LCAR.LCAR_WarpField, "")
	WF_RND_ID = WF_RND_ID + 1
End Sub