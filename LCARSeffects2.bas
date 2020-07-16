B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'1:28 autodestruct is offline

'cache xy speeds for angles

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	'Universal buffer stuff
	Dim CenterPlatformID As Int, CenterPlatform As Bitmap, WasInit As Boolean, UNIFILE As String
	'Dim GIFloaded As Boolean, GIFFrames As Int, GIFwidth As Int, GIFheight As Int, GIFdrawn as boolean 

	'Matrix stuff
	Dim LE_Turquoise255 As Int, LE_Turquoise000 As Int, LE_Blue As Int, LE_MaxLines As Int=30 , LE_Width As Int, LE_Height As Int ,LE_Changed As Boolean , LE_Border As Int=50 ,LE_IntBorder As Int 
	Dim LE_Initd As Boolean, LE_MinLength As Int, LE_MaxLength As Int , LE_MaxStatLines As Int=20 ,LE_StatLineHeight As Int=4,LE_MaxAngleLines As Int=10, LE_StringsPerLayer As Int, LE_MaxLayers As Int 
	Dim LE_StringLength As Int=20,LE_MaxStrings As Int = 5 , LE_GradAlpha As Boolean , LE_BloomThickness As Int=15, LE_Outside As Rect , LE_Inside As Rect ,LE_LastPath As Int
	Dim LE_TextR As Int,LE_TextG As Int,LE_TextB As Int ,LE_BlueR As Int, LE_BlueG As Int, LE_BlueB As Int ,ColorsSet As Boolean 
	Type LE_Line(X As Int, Y As Int, Thickness As Int, Angle As Int, Speed As Int, Length As Int, GoingIn As Boolean,PathType As Int )
	Type LE_String(X As Int, Y As Int, SpeedX As Int, SpeedY As Int, TextSize As Int, Alpha As Float, Text As String, Alphas As List, Frames As Int)
	Dim LE_Lines(LE_MaxLines+LE_MaxAngleLines) As LE_Line , LE_StatLines(LE_MaxStatLines) As Int
	Dim LE_Strings(LE_MaxStrings) As LE_String , aColors(17) As Int ,ColorsSet As Boolean , LockUniBMP As Boolean 
	
	'scan analysis stuff
	Dim Layer(4) As Int , LayerColors(3) As Int ,LayerCount(3) As Int, Ovals(2) As TweenAlpha, IsAnalysisInit As Boolean

	'starbase/starship clock stuff
	Type Movement(MovementType As Int, Quantity As Int)'towards/away from center by distance, around center by degrees, orientation by degrees, infinite movement sync with seconds
	Type Starship(Distance As Float, Angle As Int, Orientation As Int, Class As Int, Moving As Boolean, Registry As String, AI As List, Workbees As Int, DockingBay As Int, Door As Int, Origin As Point ,Cache As Rect,CacheNeedsInitializing As Boolean ,IsLeaving As Boolean,LastDrawn As Point  )
	Dim d45 As Int ,StarshipBMP As Bitmap ,Starships As List ,StarshipFont As Typeface ,StarshipsClean As Boolean ,OldDate As Int , StarshipScaleFactor As Int , DockingBays(8) As Boolean,Doors(4) As Boolean  
	Dim DoorsInUse As Int ,MovingShips As Int, DockedShips As Int ,DoorState(4)As Int ,oldseconds As Long=-1 ,StartAt As Float=1.2 ,OpenDoor As Int=5, DeleteShip As Int=6 ,OneTick As Double =1000/6,BorderThickness As Int =74
	Dim Constitution As Int=1, Excelsior As Int, Reliant As Int=2, Workbee As Int=3 , RotateAroundCenter As Int=1, MoveTowardsCenter As Int ,RotateWithSeconds As Int=2 ,TurnStarship As Int= 3, CloseDoor As Int= 4
	Dim InnerThickness As Int ,ChangeOrigin As Int=7,CurrRadius As Int, CurrentSecond As Int =-1, WorkbeeSpace As Int=10, MoveToAngle As Int=8, TurnToAngle As Int=9,WaitTicks As Int=10,WorkbeesRemaining As Int
	Dim StopDrawing As Int=11 , DoPaths As Boolean , RemovingStarships As Boolean ,ColorWhite As Int, ColorGrey As Int ,HelpMode As Boolean,PortraitMode As Boolean,ForceRedraw As Boolean 
	StarshipBMP.Initialize(File.DirAssets,"starships.gif")
	
	'graph stuff
	Type Graph(ID As Int, Points As List, MaxPoints As Int, CurrentPoint As Int, IsClearing As Boolean,IsClean As Boolean, ExpandWhenFull As Int, BracketX As Int, MaxV As Double, MinV As Double)
	Dim GraphList As List ,ResetToZero As Boolean, ZeroesInARow As Int  
	GraphList.Initialize 
	
	'PreCARS stuff
	Dim PCARfont As Typeface, cachedTS(3) As Int , isFalse As Bitmap, IsTrue As Bitmap ,PCARlastupdate As Long, PCARdelay As Int = 200'GeneratePreCARSwave
	Dim Images(10) As Bitmap , ENTTextSize As Int, ENTTextSize2 As Int, ENTScaleFactor As Float , ENTcanupdatewave As Boolean 
	
	isFalse.Initialize(File.DirAssets,"false.gif")
	IsTrue.Initialize(File.DirAssets,"true.gif")
	Images(0).Initialize(File.DirAssets,"t1.png")'top half of the top left corner
	Images(1).Initialize(File.DirAssets,"t2.png")'bottom half of the top left corner
	Images(2).Initialize(File.DirAssets,"tm.gif")'top middle bar
	Images(3).Initialize(File.DirAssets,"tr.gif")'top right corner
	Images(4).Initialize(File.DirAssets,"bl.gif")'bottom left corner
	Images(5).Initialize(File.DirAssets,"bm.gif")'bottom bar
	Images(6).Initialize(File.DirAssets,"br.gif")'bottom right corner
	Images(7).Initialize(File.DirAssets,"ml.gif")'middle left bar
	Images(8).Initialize(File.DirAssets,"mr.gif")'middle right bar
	Images(9).Initialize(File.DirAssets,"t0.png")'no corner
	
	'warp core status stuff
	Dim WarpMode As Boolean=True, MaxStages As Int=16,theDIR As Boolean,PlasmaWidth As Int',laststage As Int   'true=animated, false=static

	'real warp core stuff
	Dim WarpScaleFactor As Double, WarpLowRes As Boolean ', WarpLastX As Int	WarpLastX=-32760
	
	'klingon stuff
	Dim MaxKcycles As Int=32 ,  KlingonFont As Typeface
	
	'Omegastuff
	Dim CachedOmega As Rect ,TopTextWidth As Int, OmegaNeedsInit As Boolean 
	
	'Multispectral analysis
	Type AxisPoint(Value As Int, Color As Int,  Name As String, GraphID As Int, MinV As Int, MaxV As Int)
	Dim AxisCount As Int=20, LastUpdate As Int=-1, MS As Int = DateTime.TicksPerSecond /2
	Dim EnabledAxis As Int ,IsSetup As Boolean, IncDataPoints  As Int,CurrCols As Int, RealMax As Int, Axis(AxisCount) As AxisPoint 
	'Dim Axis As List
	
	'Moire stuff				http://tosdisplaysproject.wordpress.com/bridge-station-displays/library_computer/
	Dim MoireOffsets As Int =24
	
	'Photonic Sonar stuff
	Type SON_Point(Width As Int, CurrentOffset As Int, DesiredOffset As Int, Shade As Int, FullyOpaque As Boolean)
	Type SON_Line( Layers(2, 4) As SON_Point, LastShade As Int)
	Dim Sonar As List , SonarLines As Int=64, MaxSonarOffset As Int=10,SonarWidth As Int=40,SliverAura As Int=5, SonarTextSize As Int ,SonarTextHeight As Int
	
	'Random number stuff
	Type NumSec(Speed As Int, Y As Int)
	Type NumLin(Lines As Int, RedAlert As Int, RandomizeFullList As Int )
	Type NumCol(Digits As Int, Align As Int, ColorID As Int)
	Type NumLis(Columns As List, Values As List, ColorID As Int, Age As Int, ID As Int, TotalWidth As Int)
	Dim Numbers As List, LineList As List, ColumnList As List ,NumSection As Int ,LastSecond As Int,RandomizeFullList As Boolean ,ForcedNumber As Int=-1, LastAdditions As List, ScrollingMode As Boolean  
	
	'Periodic Table of Elements stuff
	Type PToEShell(Electrons As Int, Angle As Int, Speed As Int)'ElectronShells
	Type PToElement(X As Int,AtomicNumber As Int, Molecule As String, AtomicSymbol As String, AtomicWeight As Double, ElectronConfiguration As String, ElectronsPerShell As String,Color As Int)
	Type PtoELine(Y As Int, Cols As List)
	Dim Elements As List, SelectedElement As Point, PToECursor As Point, PToECursor2 As Point,PToECursor3 As Point   , PToExtsize As Int, PToExtCache As Int, PToEScrolling As Boolean ,PToEColWidth As Int
	Dim TheSelectedElement As Point , ElementData As PToElement,ElectronShells As List, LastUpdate As Int, ElementMode As Int,PTOESIZE As Int , PTOE_Longest As String 
	'PToEColWidth=135
	
	'Adv. Drawing stuff
	Dim mMatrix As ABMatrix, mPaint As ABPaint, mCamera As ABCamera,isAdvInit As Boolean 
	Dim AMBIENT_LIGHT As Int = 55		'Ambient light intensity
    Dim DIFFUSE_LIGHT As Int = 200		'Diffuse light intensity
    Dim SPECULAR_LIGHT As Float = 70		'Specular light intensity
    Dim SHININESS As Float = 200			'Shininess constant
    Dim MAX_INTENSITY As Int = 255		'The Max intensity of the light'0xFF
	
	'Shuttlebay stuff (6 paths of 12 positions each)
	Type Shuttle(Name As String,ColorID As Int, ShowIcon As Boolean , IsShuttle As Boolean, Index As Int, Status As String, Loc As String, inUse As Boolean, isOffship As Boolean)
	Type ShuttleLine(ShuttleID As Int, Position As Int, Direction As Boolean, Age As Int)
	Dim Shuttles As List ,ShuttleLines As List , MaxAge As Int =8,MaxPositions As Int=12,ShuttleTextHeight As Int ,ShuttleVehicleW As Int ,StatusW As Int, LocationW As Int
	
	'colored square block stuff
	Dim MaxSquareStages As Int  =16, CurrentSquare As Int=-1
End Sub

Sub InitUniversalBMP(Width As Int, Height As Int, ElementType As Int) As Canvas 
	Dim BG As Canvas, NeedsInit As Boolean 
	WasInit=False
	If Not(CenterPlatform.IsInitialized ) Or CenterPlatformID <> ElementType Then 
		NeedsInit=True
	Else If CenterPlatform.Height<>Height Or CenterPlatform.Width <> Width Then
		NeedsInit=True
	End If
	If NeedsInit Then 
		CenterPlatform.InitializeMutable(Width,Height)
		CenterPlatformID = ElementType
		WasInit=True
		UNIFILE=""
	End If
	BG.Initialize2(CenterPlatform)
	Return BG
End Sub
Sub FindDIR(Dir As String, Filename As String) As String
	If Dir.Length=0 Then
		If File.Exists(File.DirAssets, Filename) Then 
			Dir = File.DirAssets 'prioritize internal directory first
		Else If File.Exists(LCAR.DirDefaultExternal, Filename) Then 
			Dir = LCAR.DirDefaultExternal
		End If
	End If
	Return Dir 
End Sub
'Sub DrawGIF(BG As Canvas, Frame As Int, X As Int, Y As Int, Width As Int, Height As Int) As Boolean 
'	GIFdrawn = False
'	If Not(IsPaused(Main)) Then CallSub2(Main, "DrawGIF3", Array As Object(BG,Frame, LCARSeffects4.SetRect(X,Y,Width,Height)))
''	If Not(Async) Then 
''		Log("WAITING")
''		Do Until GIFdrawn
''			DoEvents 
''		Loop
''	End If
'	'LCAR.DrawText(BG,X,Y,"Frame: " & Frame & " " & Async, LCAR.LCAR_Orange, 0,False, 255,0)
'End Sub
'Sub LoadUniversalGIF(Dir As String, Filename As String, ElementType As Int) As Boolean 
'	'Sub DrawGIF(Frame As Int, Dest As Rect) As Boolean
'	Dim tempstr As String = Filename
'	If Filename.length >0 And Not(LockUniBMP) Then 'And Not(IsPaused(Main)) Then
'		If Dir.Length>0 Then tempstr = File.Combine(Dir, Filename)
'		If CenterPlatformID <> ElementType Or tempstr <> UNIFILE Or Not(GIFloaded) Then 
'			If Dir.Length=0 Then Dir = FindDIR(Dir,Filename)
'			If Dir.Length>0 And File.Exists(Dir,Filename) Then
'				CallSub3(Main, "LoadGIF", Dir, Filename)
'				CenterPlatformID = ElementType
'				UNIFILE=tempstr
'				Log("Loaded: " & File.Combine(Dir, Filename))
'				Return True
'			End If 
'		End If 
'	End If
'End Sub

Sub LoadUniversalBMP(Dir As String, Filename As String, ElementType As Int) As Boolean  
	Dim tempstr As String = Filename
	If Filename.length >0 And Not(LockUniBMP) Then
		If Dir.Length>0 Then tempstr = File.Combine(Dir, Filename)
		'Log(ElementType & " THISBMP: " & tempstr)
		'Log(CenterPlatformID & " UNIFILE: " & UNIFILE)
		If Not(CenterPlatform.IsInitialized ) Or CenterPlatformID <> ElementType Or tempstr <> UNIFILE Then 
			If Dir.Length=0 Then Dir = FindDIR(Dir,Filename)
			If Dir.Length>0 And File.Exists(Dir,Filename) Then
				Try
					'If CenterPlatform.IsInitialized then BitMap.recycle
					CenterPlatform.Initialize(Dir,Filename)
					CenterPlatformID = ElementType
					WasInit=True
					UNIFILE=tempstr
					Log("Loaded: " & File.Combine(Dir, Filename))
					Return True
				Catch
					Return False
				End Try
			End If
		End If
		Return True
	End If
End Sub


Sub ClearRandomNumbers
	LCARSeffects3.RND_ID=0
	LineList.Initialize 
	NumSection=0
	Numbers.Initialize 
	LastAdditions.Initialize 
	ColumnList.Initialize 
End Sub
Sub InitRandomNumbers(ElementType As Int, IncrementalUpdates As Boolean) As Boolean 
	If ElementType <> NumSection Or API.ListSize(LineList) = 0 Or API.ListSize(Numbers)=0 Then 
		'Log("Was: " & NumSection & " " & ElementType)
		ClearRandomNumbers
		ScrollingMode = False
		Select Case ElementType
			Case LCAR.CHX_Iconbar, LCAR.LCAR_RndNumbers
				'ScrollingMode = True
		End Select
		NumSection=ElementType
		RandomizeFullList = IncrementalUpdates
		LastSecond= DateTime.GetSecond( DateTime.Now )
		Return True 
	End If
	Return False
End Sub
Sub SetColRowColorID(Row As Int, Col As Int, ColorID As Int)
	Dim Rows As NumLis, Cols As NumCol 
	Rows = Numbers.Get(Row) 
	Cols = Rows.Columns.Get(Col)
	Cols.ColorID=ColorID
End Sub
'Digits (-number has no padding), align (1=left -1=right)
Sub AddRowsOfNumbers(ID As Int,Rows As Int, ColorID As Int, Data As List)
	Dim temp As Int
	For temp = 1 To Rows
		AddRowOfNumbers(ID, ColorID,Data)
	Next
End Sub
Sub HasALine(ID As Int) As Boolean 
	Dim temp As Int , Row As NumLis
	For temp = 0 To Numbers.Size-1
		Row= Numbers.Get(temp)
		If Row.ID = ID Then Return True
	Next
End Sub
Sub FindLineIndex(ID As Int, First As Boolean) As Int 
	Dim temp As Int , Row As NumLis, LineIndex As Int = -1
	For temp = 0 To Numbers.Size-1
		Row= Numbers.Get(temp)
		If Row.ID = ID Then 
			If First Then Return temp
			LineIndex = temp
		End If
	Next
	Return LineIndex
End Sub
Sub FindFirstLine(ID As Int,Index As Int) As NumLis
	Dim temp As Int , Row As NumLis, LineIndex As Int  
	For temp = 0 To Numbers.Size-1
		Row= Numbers.Get(temp)
		If Row.ID = ID Then 
			If Index=LineIndex Then
				Return Row
			Else
				LineIndex=LineIndex+1
			End If
		End If
	Next
End Sub
Sub DuplicateFirstLines(ID As Int, Count As Int)
	Dim temp As Int, Row As NumLis 
	Row = FindFirstLine(ID,0)
	For temp = 1 To Count
		DuplicateFirstLine(Row)
	Next
End Sub
Sub DuplicateFirstLine(Src As NumLis)
	Dim Row As NumLis , temp As Int 
	Row.Initialize 
	Row.id = Src.ID 
	Row.Columns.Initialize 
	Row.ColorID = Src.ColorID 
	For temp = 0 To Src.Columns.Size-1
		Row.Columns.Add( Src.Columns.Get(temp) )
	Next
	RandomizeRow(Row)
	AddLine(Src.ID )
	Numbers.Add(Row)
End Sub

Sub DrawNumberBlock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, ID As Int, ElementType As Int, Text As String ) As Boolean 
	Dim Font As Typeface = LCAR.LCARfont, MaxSize As Int , Color As Int = Colors.Black , NeedsInit As Boolean , Textsize As Int = LCAR.Fontsize, ColInfo As NumSec 
	Select Case ElementType
		Case LCAR.LCAR_WarpField: If ID>0 Then Textsize = Textsize * 0.5
		Case LCAR.TMP_RndNumbers
			Textsize = Textsize * 0.5
			Font = StarshipFont
			If ColorID = LCAR.LCAR_White Then Color = Colors.Transparent
		Case LCAR.CHX_Window, LCAR.CHX_Iconbar 
			Font = LCARSeffects3.CHX_Font 
			If ElementType = LCAR.CHX_Window Then
				Color = LCARSeffects3.CHX_Beige
			Else
				Color = Colors.Transparent ' LCARSeffects3.CHX_LightBlue 
				MaxSize = Width
			End If
		Case LCAR.ENT_RndNumbers
			Font=Typeface.DEFAULT 
			Textsize = Textsize * 0.5
	End Select
	If InitRandomNumbers(ElementType, True) Then NeedsInit=True
	
	If Color <> Colors.Transparent Then LCAR.DrawRect(BG,X,Y,Width+1,Height,Color, 0)
	If ScrollingMode Then
		If ID >= ColumnList.size Then
			ColInfo.Initialize 
			ColInfo.Speed = Rnd(1, 5)'LineSize*0.25)
			ColumnList.Add(ColInfo)
		Else
			ColInfo = ColumnList.Get(ID)
		End If
		Y=Y-ColInfo.Y
		'Log("ColInfo: " & ColInfo)
	End If 
	
	If DrawRandomNumbers(BG,X,Y+BG.MeasureStringHeight("0123", Font, Textsize), Font, Textsize, Width, Height, ID ) =0 Then 
		If API.debugMode And ElementType <>  LCAR.CHX_Iconbar Then Text = "SYSTEM ERROR " & ElementType & " " & NumSection
		If ElementType <> NumSection Then ClearRandomNumbers
		'Else
			NeedsInit = True
		'End If
	End If
	If NeedsInit Then
		If MaxSize = 0 Then MaxSize = Max(LCAR.ScaleHeight,LCAR.ScaleWidth) 
		MakeRowOfRandomNumbers(BG, Font, Textsize, MaxSize, ID, ColorID)
	End If
	If Text.Length >0 Then
		Textsize=Textsize*2
		MaxSize = BG.MeasureStringWidth(Text, LCAR.lcarfont, Textsize)
		If MaxSize < Width Then
			LCAR.DrawLCARtextbox(BG, X+Width+1,  Y,  -1, Textsize, -1,-1, Text, ColorID, 0,0, False,False, 3, 255)
		Else
			LCAR.DrawText(BG, X+Width+1,  Y, Text, ColorID, 3,False,255,-1)
		End If
	End If
	Return NeedsInit
End Sub

Sub MakeRowOfRandomNumbers(BG As Canvas, Font As Typeface, FontSize As Int, Width As Int, ID As Int, ColorID As Int)
	Dim CharWidth As Int ,TotalWidth As Int, CurrentWidth As Int , Row As NumLis , Digits As Int, Align As Int 
	CharWidth = BG.MeasureStringWidth("0", Font,FontSize) + 1
	Row.Initialize 
	Row.ID = ID 
	Row.Columns.Initialize 
	Row.ColorID = ColorID 
	Row.TotalWidth=Width
	Do Until TotalWidth>=Width
		If NumSection = LCAR.CHX_Iconbar Then
			Align = BG.MeasureStringWidth("0", LCARSeffects3.CHX_Font, FontSize)
			Digits = Width / Align
		Else
			Digits = Rnd(1,8) 
			If Rnd(0,2)=0 Then Digits = -Digits
			Align= Rnd(-1,1)
		End If
		'CurrentWidth=(Abs(Digits)+2)*CharWidth
		CurrentWidth= LCARSeffects7.DigitWidth(BG, Font, FontSize, Abs(Digits))
		TotalWidth=TotalWidth+CurrentWidth
		If TotalWidth > Width Then
			Do Until TotalWidth <= Width Or Abs(Digits) = 0
				If Digits > 0 Then Digits = Digits - 1 Else Digits = Digits + 1
				TotalWidth = TotalWidth - CharWidth
			Loop
		End If 
		If Abs(Digits) > 0 Then Row.Columns.Add(AddColOfNumbers(Digits,Align))
	Loop
	
	RandomizeRow(Row)
	AddLine(ID)
	Numbers.Add(Row)
End Sub

'ID=Virtual ID, Data = array(Digits (-number has no padding), align (1=left -1=right))
Sub AddRowOfNumbers(ID As Int, ColorID As Int, Data As List)As Int 
	Dim Row As NumLis,temp As Int '10^digits
	Row.Initialize 
	Row.ID = ID
	Row.Columns.Initialize 
	For temp = 0 To Data.Size-1 Step 2
		Row.Columns.Add (AddColOfNumbers(Data.Get(temp), Data.Get(temp+1)))
	Next
	Row.ColorID=ColorID
	RandomizeRow(Row)
	AddLine(ID)
	Numbers.Add(Row)
	Return Numbers.Size-1
End Sub
Sub AddColOfNumbers(Digits As Int, Align As Int) As NumCol
	Dim temp As NumCol
	temp.Initialize 
	temp.Digits=Digits
	If NumSection = LCAR.ENT_RndNumbers Then  
		temp.ColorID = API.IIFIndex(Rnd(0,2), Array As Int(LCAR.LCAR_White, LCAR.LCAR_Red))
		temp.Digits=-Digits
	End If
	temp.Align=Align
	Return temp
End Sub
Sub IncrementNumbers As Boolean 
	Dim temp As Int , Line As NumLin,Row As NumLin ,Cols As NumLis ,temp2 As Int, ColInfo As NumSec', temp3 As Int, temp4 As Int 
	If Numbers.IsInitialized Then
		'Log( DateTime.GetSecond( DateTime.Now )    & " "  & LastSecond & "   " &  Numbers.Size )
		If DateTime.GetSecond( DateTime.Now ) <> LastSecond Or Numbers.Size=0 Then
			'API.SeedRND
			LastSecond= DateTime.GetSecond( DateTime.Now )
			If Not(RandomizeFullList) Then
				For temp = 0 To Numbers.Size-1
					RandomizeRow( Numbers.Get(temp) )
				Next
			Else
				For temp = 0 To LineList.Size-1
					Row = LineList.Get(temp)
					Cols = FindFirstLine(temp, Row.RandomizeFullList)
					RandomizeRow(Cols)
					For temp2 = 0 To Row.Lines-1
						If temp2 <> Row.RandomizeFullList Then
							Cols = FindFirstLine(temp, temp2)
							AgeRow(Cols)
						End If
					Next
					Row.RandomizeFullList = (Row.RandomizeFullList+1) Mod Row.Lines 
				Next
			End If
			If LCAR.RedAlert Then
				For temp = 0 To LineList.Size-1
					Line = LineList.Get(temp)
					Line.RedAlert = (Line.RedAlert+1)  Mod Line.Lines 
				Next
			End If
			Return True
		End If
		If ScrollingMode Then
			temp2 = LCAR.EmergencyBG.MeasureStringHeight("10", LCARSeffects3.CHX_Font, LCARSeffects3.CHX_Fontsize)'lineheight
			For temp = 0 To ColumnList.Size 
				ColInfo = ColumnList.Get(temp)
				ColInfo.y = ColInfo.Y + ColInfo.Speed 
				If ColInfo.y > temp2 Then
					ColInfo.y = ColInfo.y Mod temp2
					EraseLines(temp)
				End If
			Next
		End If
	End If
	Return False
End Sub
Sub RandomizeRow(Row As NumLis)
	Dim temp As Int, Col As NumCol , tempstr As String  
	If Not(Row = Null ) Then
		Row.Values.Initialize 
		Row.Age=0
		For temp = 0 To Row.Columns.Size-1
			Col = Row.Columns.Get(temp)
			If NumSection = LCAR.CHX_Window Or NumSection = LCAR.CHX_Iconbar Then
				tempstr = MakeBinary(Abs(Col.Digits),NumSection = LCAR.CHX_Iconbar)
				If NumSection = LCAR.CHX_Window Then
					Row.Values.Add(tempstr)
				Else
					Row.Values.Add(Regex.Split(",", tempstr))
				End If
			Else If ForcedNumber = -1 Then
				Row.Values.Add(RandomNumber(Abs(Col.Digits),Col.Digits>0))
			Else
				Row.Values.Add(MakeString(Abs(Col.Digits), ForcedNumber))
			End If
		Next
	End If
End Sub
Sub MakeBinary(Digits As Int, Allow2 As Boolean) As String 
	Dim temp As Int, tempstr As StringBuilder, LastOne As Int 
	tempstr.Initialize 
	If Allow2 Then'I think I saw a 2
		Do Until Digits = 0 
			temp = Rnd(0,API.IIF(LastOne=2,2,3))'prevent strings of blocks
			If tempstr.Length > 0 Then tempstr.Append(",")
			tempstr.Append(temp)
			LastOne = temp
			If temp = 2 Then
				temp = Rnd(1, Digits)
				tempstr.Append("," & temp)
				Digits = Digits - temp
			Else
				Digits = Digits - 1
			End If
		Loop
	Else'Don't worry Bender, there's no such thing as 2
		For temp = 1 To Digits
			tempstr.Append( Rnd(0,2) )
		Next
	End If
	Return tempstr.ToString 
End Sub
Sub MakeString(Digits As Int, Character As String) As String 
	Dim temp As Int, tempstr As StringBuilder 
	tempstr.Initialize 
	For temp = 1 To Digits
		tempstr.Append(Character)
	Next
	Return tempstr.ToString 
End Sub
Sub AgeRow(Row As NumLis)
	If Row <> Null Then 
		If Row.IsInitialized Then Row.Age = Row.Age+1
	End If
End Sub
Sub DrawRandomNumbers(BG As Canvas, X As Int, Y As Int,Font As Typeface, FontSize As Int, MaxWidth As Int, MaxHeight As Int, ID As Int ) As Int
	Dim temp As Long, LineSize As Int , CharWidth As Int ,Height As Int, Src As NumLis, Curr As NumLis , Line As NumLin , CurrLin As Int, LineIndex As Int
	Dim RedAlert As Boolean , DoBG As Boolean,Drawn As Boolean 'ColInfo As NumSec,
	Try
		LineSize=BG.MeasureStringHeight("1234567890", Font, FontSize)+2
		If ID<0 Then 
			DoBG=True 
			Y=Y+LineSize-1
			ID=Abs(ID)
		End If		
		CharWidth = BG.MeasureStringWidth("0", Font,FontSize)
		CurrLin=-1
		
		For temp = 0 To Numbers.Size-1
			Curr = Numbers.Get(temp)
			'Log("Checking row: " & temp & " for ID " &  ID & ", it was " &  Curr.ID)
			If Curr.ID = ID Then
				'Log("Drawing row " & temp)
				If LCAR.RedAlert Then
					If CurrLin<> ID Then Line = LineList.Get(ID)
					RedAlert = Line.RedAlert = LineIndex
				End If
				DrawRow(BG, X,Y, Font,FontSize,CharWidth, Curr, ID ,MaxWidth, RedAlert,DoBG,LineSize)
				Drawn=True
				Y=Y+LineSize
				If MaxHeight>0 Then 
					If Not(Src.IsInitialized ) Then Src =Numbers.Get(temp)
					Height=Height+LineSize
					If Height>MaxHeight  Then Exit
				End If
				LineIndex=LineIndex+1
			End If
		Next
		
		If MaxHeight>0 And Height+LineSize<=MaxHeight And Src.IsInitialized Then'add more
			CharWidth=0
			If NumSection = LCAR.ENT_RndNumbers Then'only add 1 per second
				ForceListItems(LastAdditions, ID)
				temp = LastAdditions.Get(ID)
				'LogColor(ID & ": " & temp, Colors.Blue)
				If LastAdditions.Get(ID) > DateTime.Now - DateTime.TicksPerSecond*0.25 Then CharWidth= API.IIF(HasALine(ID), 1,0)
			End If
			If CharWidth =0 Then
				For temp = Height To MaxHeight Step LineSize
					Height=Height+LineSize
					If Height< MaxHeight Then
						DuplicateFirstLine(Src)
						CharWidth=CharWidth+1
					End If
					If NumSection = LCAR.ENT_RndNumbers Then 
						LastAdditions.Set(ID, DateTime.Now)
						temp = MaxHeight + LineSize 'only add 1 per second
					End If
				Next
			End If
		Else If NumSection = LCAR.ENT_RndNumbers Then 
			EraseLines(ID)'clear when full and start over
		End If
	Catch
		Log(LastException.Message)
	End Try
	
	If Drawn Then 
		Return LineSize
	Else
		Return 0
	End If
End Sub
Sub ForceListItems(Lst As List, Size As Int)
	If Not(Lst.IsInitialized) Then Lst.Initialize 
	Do Until Lst.Size > Size
		Lst.Add(0)
	Loop
End Sub
Sub EraseLines(ID As Int)
	Dim temp As Int, Curr As NumLis 
	Select Case NumSection
		Case LCAR.ENT_RndNumbers 
			For temp = Numbers.Size-1 To 0 Step -1
				Curr = Numbers.Get(temp)
				If Curr.ID = ID Then Numbers.RemoveAt(temp)
			Next
		Case LCAR.CHX_Iconbar
			If ScrollingMode Then
				temp = FindLineIndex(ID, True)
				If temp>-1 Then Numbers.RemoveAt(temp)
			End If
	End Select
End Sub
Sub DrawRow(BG As Canvas, X As Int, Y As Int, Font As Typeface, FontSize As Int, CharWidth As Int, Row As NumLis, ID As Int, MaxWidth As Int, RedAlert As Boolean, DoBackGround As Boolean, LineHeight As Int) As Boolean 
	Dim temp As Int , Col As NumCol,Text As String, Color As Int ,Width As Int,State As Boolean 
	If Row.ID = ID Then
		If MaxWidth>0 Then MaxWidth=MaxWidth+X
		For temp = 0 To Row.Columns.size-1
			Col = Row.Columns.Get(temp)
			If NumSection <> LCAR.CHX_Iconbar Then Text = Row.Values.Get(temp)
			'Width = Abs(Col.Digits) * (CharWidth+2)
			Width = LCARSeffects7.DigitWidth(BG, Font, FontSize, Abs(Col.Digits))
			Do While X + Width > MaxWidth And Col.Digits <> 0
				If Col.Digits < 0 Then Col.Digits = Col.Digits + 1 Else Col.Digits = Col.Digits - 1 
				If Col.Digits = 0 Then Return False 
				Width = LCARSeffects7.DigitWidth(BG, Font, FontSize, Abs(Col.Digits))
			Loop
			
			If RedAlert Then 
				State= True
			Else
				State= (Row.age<2) And RandomizeFullList
			End If
			If LCAR.RedAlert Then 
				Color = LCAR.LCAR_RedAlert 
				If Not(State) Then Color = LCAR.RedAlertMode
			Else 
				Color = API.IIF(Col.ColorID =0, Row.ColorID,Col.ColorID)
			End If
			'Log("Col " & temp & " = " & Text & " - " & Color)
		
			If Color <0 Then'													-1						-2							-3							-4							-5							-6
				Color = API.IIFIndex(Abs(Color)-1, Array As Int(LCARSeffects3.CHX_Beige, LCARSeffects3.CHX_DarkBlue, LCARSeffects3.CHX_DarkRed, LCARSeffects3.CHX_LightBeige, LCARSeffects3.CHX_LightBlue, LCARSeffects3.CHX_LightRed))
			Else
				Color = LCAR.GetColor(Color, State, 255)
			End If
			If DoBackGround Then LCAR.DrawRect(BG, X,Y-LineHeight ,Width-2,LineHeight+2, Colors.black , 0)
			If NumSection = LCAR.CHX_Iconbar Then'supports (=======) blocks
				DrawCHXline(BG, X,Y,CharWidth,LineHeight,Row.Values.Get(temp), Font,FontSize, Color)'NOT A STRING!
			Else If Col.Align=-1 Then'right align
				BG.DrawText(Text, X+Width,Y,Font, FontSize, Color, "RIGHT")
			Else'left align
				BG.DrawText(Text, X,Y,Font, FontSize, Color, "LEFT")
			End If
			X=X+Width+CharWidth
			
			If X>= MaxWidth And MaxWidth>0 Then temp=Row.Columns.size
		Next
		
		'If MaxWidth-x > CharWidth*4 Then AddColOfNumbers( End If
		Return True
	End If
	Return False
End Sub
Sub DrawCHXline(BG As Canvas, X As Int, Y As Int, CharWidth As Int, LineHeight As Int, tempstr() As String, Font As Typeface, FontSize As Int, Color As Int)
	Dim Text As Int, temp As Int, Cols As Int, WhiteY As Int = 4
	For temp = 0 To tempstr.Length - 1 
		Text = tempstr(temp)
		'Log("DrawCHXline: " & Text)
		If Text = 2 Then'block
			Cols = tempstr(temp+1)
			LCAR.DrawRoundedRectangle(BG,X,Y-LineHeight+WhiteY,Cols*CharWidth,LineHeight-WhiteY, 2, Color, 0)
			temp=temp+1
			X=X+CharWidth*Cols
		Else
			BG.DrawText(Text, X,Y,Font, FontSize, Color, "LEFT")
			X=X+CharWidth
		End If
	Next
End Sub
Sub AddLine(ID As Int)
	Dim Line As NumLin 
	If ID < LineList.Size Then
		Line = LineList.Get(ID)
		Line.Lines = Line.Lines+1
	Else
		Line.Initialize 
		Line.Lines=1
		LineList.Add(Line)
	End If
	'Log("ID: " & ID & " has " & Line.Lines )
End Sub







Sub InitAdvDrawingStuff
	If Not(isAdvInit) Then
		mMatrix.Initialize 
		mPaint.Initialize
		mPaint.SetAntiAlias(LCAR.AntiAliasing)
	    mPaint.SetFilterBitmap(LCAR.AntiAliasing)
		isAdvInit=True
	End If
End Sub
Sub DrawTrapezoid(BG As Canvas, BMP As Bitmap ,SRC As Rect , X As Int, Y As Int, TopWidth As Int, BottomWidth As Int, Height As Int, Alpha As Int)
	Dim BottomLeft As Int ,P As Path, DoClip As Boolean = Height>0
	If TopWidth = BottomWidth Then
		DrawBMP(BG, BMP, SRC.Left, SRC.Top, SRC.Right-SRC.Left, SRC.Bottom-SRC.Top, X,Y,TopWidth,Height,Alpha,False,False)
	Else
		Height = Abs(Height)
		LCAR.ExDraw.save2(BG, LCAR.ExDraw.MATRIX_SAVE_FLAG)
		If TopWidth=0 Then TopWidth=BottomWidth
		If BottomWidth=0 Then BottomWidth=TopWidth
		If BottomWidth> TopWidth Then X = X + (BottomWidth-TopWidth)/2
		BottomLeft = X+ TopWidth/2 - BottomWidth/2
		If SRC=Null Or Not(SRC.IsInitialized) Then SRC.Initialize(0,0, BMP.Width, BMP.Height)
		mPaint.Initialize 
		mPaint.SetAlpha(Alpha)
		mMatrix.setPolyToPoly( Array As Float(SRC.Left,SRC.Top,  SRC.Right,SRC.Top,   SRC.Right, SRC.Bottom,        SRC.Left,SRC.Bottom), 0,  Array As Float( X,Y, X+TopWidth,Y, BottomLeft+BottomWidth, Y+Height, BottomLeft, Y+Height   ), 0,4)
		
		If DoClip Then
			P.Initialize(X,Y)
			P.LineTo(X+TopWidth,Y)
			P.LineTo(BottomLeft+BottomWidth, Y+Height)
			P.LineTo(BottomLeft, Y+Height)
			BG.ClipPath(P)
		End If
		LCAR.ExDraw.drawBitmap4(BG, BMP,  mMatrix, mPaint)
		LCAR.ExDraw.restore(BG) 'before Activity.Invalidate 
		If DoClip Then BG.RemoveClip 
	End If
End Sub

'SRC and DEST are an array of X/Y coordinates
Sub DrawBMPpoly(BG As Canvas, BMP As Bitmap, SRC() As Float, DEST() As Float, Alpha As Int, NeedsClipPath As Boolean)
	Dim temp As Int, P As Path  
	If SRC.Length = DEST.Length Then
		LCAR.ExDraw.save2(BG, LCAR.ExDraw.MATRIX_SAVE_FLAG)
		mPaint.Initialize 
		mPaint.SetAlpha(Alpha)
		mMatrix.setPolyToPoly(SRC, 0, DEST, 0, DEST.Length *0.5)
		
		If API.debugMode Then
			BG.DrawLine(DEST(0),DEST(1), DEST( DEST.Length-2),DEST( DEST.Length-1), Colors.Blue,3)
			For temp = 0 To DEST.Length -3 Step 2
				BG.DrawLine(DEST(temp),DEST(temp+1), DEST(temp+2),DEST(temp+3), Colors.Red, 3)
			Next
		End If
		
		If NeedsClipPath Then
			P.Initialize(DEST(0),DEST(1))
			For temp = 2 To DEST.Length -1 Step 2
				P.LineTo(DEST(temp),DEST(temp+1))
			Next
			BG.ClipPath(P)
		End If
		
		LCAR.ExDraw.drawBitmap4(BG, BMP,  mMatrix, mPaint)
		LCAR.ExDraw.restore(BG) 'before Activity.Invalidate 
		
		If NeedsClipPath Then BG.RemoveClip 
	End If
End Sub

Sub DrawBMP(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, FlipX As Boolean, FlipY As Boolean)
	Dim Dest() As Float ,Right As Int, Bottom As Int, NeedsClip As Boolean =  SrcX <> 0 Or SrcY<> 0
	If SrcWidth=0 Then SrcWidth = BMP.Width -SrcX
	If SrcHeight=0 Then SrcHeight=BMP.Height - SrcY
	If Alpha = 255 Then
		If FlipX Or FlipY Then
			BG.DrawBitmapFlipped(BMP, LCARSeffects4.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCARSeffects4.SetRect(X,Y,Width,Height), FlipY, FlipX)
		Else
			BG.DrawBitmap(BMP, LCARSeffects4.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCARSeffects4.SetRect(X,Y,Width,Height))
		End If
	Else If Alpha>0 Then
		If SrcWidth <> BMP.Width Or SrcHeight <> BMP.Height Then NeedsClip = True 
		LCAR.ExDraw.save2(BG, LCAR.ExDraw.MATRIX_SAVE_FLAG)
		mPaint.Initialize 
		mPaint.SetAlpha(Alpha)
		Right=X+Width
		Bottom=Y+Height
		
		If FlipX And FlipY Then
			Dest=Array As Float(Right,Bottom,	X,Bottom,	X,Y,			Right,Y)
		Else If FlipX Then
			Dest=Array As Float(Right,Y,	X,Y,			X,Bottom,			Right,Bottom)
		Else If FlipY Then
			Dest=Array As Float(X,Bottom, 	Right,Bottom, 	Right,Y,  			X,Y)
		Else
			Dest=Array As Float(X,Y, 		Right,Y, 		Right, Bottom, 		X,Bottom )
		End If
		
		mMatrix.Initialize 
		If NeedsClip Then LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
		mMatrix.setPolyToPoly( Array As Float(SrcX,SrcY,         SrcX+SrcWidth, SrcY,      SrcX+SrcWidth,SrcY+SrcHeight,	SrcX,SrcY+SrcHeight), 0, Dest, 0,4)
		LCAR.ExDraw.drawBitmap4(BG, BMP,  mMatrix, mPaint)
		LCAR.ExDraw.restore(BG)
		If NeedsClip Then BG.RemoveClip 
	End If
End Sub


Sub SetupShine(RotationX As Float)
	Dim cosRotation As Double,  intensity As Int, highlightIntensity As Int, light As Int,  highlight As Int

	cosRotation = Cos(Trig.PI * RotationX / 180)
	intensity = Min(MAX_INTENSITY, AMBIENT_LIGHT + (DIFFUSE_LIGHT * cosRotation))
	highlightIntensity = Min(MAX_INTENSITY, SPECULAR_LIGHT * Power(cosRotation,SHININESS))	
	light = Colors.rgb(intensity, intensity, intensity)
	highlight = Colors.rgb(highlightIntensity, highlightIntensity, highlightIntensity)
    mPaint.SetLightingColorFilter(light, highlight)   
End Sub












Sub AddPToELine(Y As Int)As PtoELine 
	Dim temp2 As PtoELine 
	temp2.Initialize 
	temp2.Y=Y
	temp2.Cols.Initialize 
	Elements.Add(temp2)
	Return temp2
End Sub
Sub AddPToElement(X As Int, Y As Int, Molecule As String, AtomicSymbol As String, AtomicWeight As Double, ElectronConfiguration As String ,ElectronsPerShell As String,ColorID As Int )As PToElement 
	Dim temp As PToElement ,temp2 As PtoELine
	If Not(API.TransLanguage.EqualsIgnoreCase("english")) Then 
		If API.Translation.ContainsKey("ptoe_" & Molecule.ToLowerCase) Then Molecule = API.GetString("ptoe_" & Molecule.ToLowerCase)
		If API.Translation.ContainsKey("ptoe_" & AtomicSymbol.ToLowerCase) Then Molecule = API.GetString("ptoe_" & AtomicSymbol.ToLowerCase)
	End If
	If Molecule.Length > PTOE_Longest.Length Then PTOE_Longest = Molecule
	Y=Y-1
	PToExtCache=PToExtCache+1
	If Elements.IsInitialized  Then
		If Elements.Size=0 Then
			temp2=AddPToELine(0)
		Else
			temp2 = Elements.Get( Elements.Size-1)
			If temp2.Y <> Y Then temp2= AddPToELine(Y)
		End If
	Else
		Elements.Initialize 
		temp2=AddPToELine(0)
	End If
	
	temp.Initialize 
	temp.X =X-1
	temp.AtomicNumber=PToExtCache
	temp.Molecule =Molecule.ToUpperCase 
	temp.AtomicSymbol =AtomicSymbol
	temp.AtomicWeight = AtomicWeight
	temp.ElectronConfiguration =ElectronConfiguration.replace("] ", "]")
	temp.ElectronsPerShell = ElectronsPerShell.Replace(",", "")
	
	If PToExtCache<>119 Then 
		temp.Color = LCAR.GetColor(ColorID,False,255)
	Else
		temp.Color = Colors.Red 
	End If
	
	temp2.Cols.Add(temp)
	Return temp
End Sub
Sub SetupElements(Mode As Int)
	Dim R As Int,S As Int 
	If Elements.IsInitialized Then	Elements.Clear 
	PToExtCache=0
	PTOE_Longest=""
	If Mode=0 Then
		AddPToElement( 1,  1, "HYDROGEN",	"H",		1.008,	"1s1",					"1", 				LCAR.LCAR_DarkYellow)
		AddPToElement(18,  1, "HELIUM",		"He", 		4.003,	"1s2",					"2", 				LCAR.LCAR_Red)
		
		AddPToElement( 1,  2, "LITHIUM",	"Li",		6.941,	"1s2 2s1",				"2 1", 				LCAR.LCAR_DarkPurple  )
		AddPToElement( 2,  2, "beryllium",	"Be",		9.012,	"1s2 2s2",				"2 2", 				LCAR.LCAR_Orange )
		AddPToElement(13,  2, "boron",		"B",	   10.811,	"[He]2s2 2p1", 			"2 3",				LCAR.LCAR_DarkYellow)
		AddPToElement(14,  2, "Carbon",		"C",	   12.011,	"[He]2s2 2p2", 			"2 4",				LCAR.LCAR_DarkYellow)
		AddPToElement(15,  2, "Nitrogen",	"N",	   14.007,	"1s2 2s2 2p3", 			"2 5",				LCAR.LCAR_DarkYellow)
		AddPToElement(16,  2, "Oxygen",		"O",	   15.999,	"1s2 2s2 2p4", 			"2 6",				LCAR.LCAR_DarkYellow)
		AddPToElement(17,  2, "Flourine",	"F",	   18.998,	"1s2 2s2 2p5", 			"2 7",				LCAR.LCAR_DarkPurple)
		AddPToElement(18,  2, "Neon",		"Ne",	   20.180,	"1s2 2s2 2p6", 			"2 8",				LCAR.LCAR_Red)
		
		AddPToElement( 1,  3, "Sodium",		"Na",	   22.990,	"[Ne]3s1",				"2 8 1", 			LCAR.LCAR_DarkPurple )
		AddPToElement( 2,  3, "magnesium",	"Mg",	   24.305,	"[Ne]3s2",				"2 8 2", 			LCAR.LCAR_Orange )
		AddPToElement(13,  3, "aluminium",	"Al",	   26.982,	"[Ne]3s2 3p1",			"2 8 3", 			LCAR.LCAR_Purple )
		AddPToElement(14,  3, "silicon",	"Si",	   28.086,	"[Ne]3s2 3p2", 			"2 8 4",			LCAR.LCAR_DarkYellow)
		AddPToElement(15,  3, "phosphorus", "P",	   30.974,	"[Ne]3s2 3p3",			"2 8 5",			LCAR.LCAR_DarkYellow)
		AddPToElement(16,  3, "sulfur", 	"S",	   32.065,	"[Ne]3s2 3p4",			"2 8 6",			LCAR.LCAR_DarkYellow)
		AddPToElement(17,  3, "chlorine",	"Cl",	   35.453,	"[Ne]3s2 3p5",			"2 8 7",			LCAR.LCAR_LightPurple)
		AddPToElement(18,  3, "argon", 		"Ar",	   39.948,	"[Ne]3s2 3p6",			"2 8 8",			LCAR.LCAR_Red)
		
		AddPToElement( 1,  4, "Potassium",	"K",	   39.098,	"[Ar]4s1",				"2 8 8 1", 			LCAR.LCAR_DarkPurple )
		AddPToElement( 2,  4, "Calcium",	"Ca",	   40.078,	"[Ar]4s2",				"2 8 8 2", 			LCAR.LCAR_Orange )
		AddPToElement( 3,  4, "scandium",	"Sc",	   44.956,	"[Ar]3d1 4s2",			"2 8 9 2",	 		LCAR.LCAR_Yellow)
		AddPToElement( 4,  4, "titanium",	"Ti",	   47.867,	"[Ar]4s2 3d2",			"2 8 10 2", 		LCAR.LCAR_Yellow)
		AddPToElement( 5,  4, "Vanadium",	"V",	   50.942,	"[Ar]3d3 4s2",			"2 8 11 2", 		LCAR.LCAR_Yellow)
		AddPToElement( 6,  4, "Chromium",	"Cr",	   51.996,	"[Ar]4s1 3d5",			"2 8 13 1", 		LCAR.LCAR_Yellow)
		AddPToElement( 7,  4, "manganese",	"Mn",	   54.938,	"[Ar]4s2 3d5",			"2 8 13 2", 		LCAR.LCAR_Yellow)
		AddPToElement( 8,  4, "iron",		"Fe",	   55.845,	"[Ar]3d6 4s2",			"2 8 14 2", 		LCAR.LCAR_Yellow)
		AddPToElement( 9,  4, "cobalt",		"Co",	   58.933,	"[Ar]4s2 3d7",			"2 8 15 2", 		LCAR.LCAR_Yellow)
		AddPToElement(10,  4, "nickel",		"Ni",	   58.693,	"[Ar]4s2 3d8",			"2 8 16 2", 		LCAR.LCAR_Yellow)
		AddPToElement(11,  4, "copper",		"Cu",	   63.546,	"[Ar]3d10 4s1",			"2 8 18 1", 		LCAR.LCAR_Yellow)
		AddPToElement(12,  4, "zinc",		"Zn",	   65.380,	"[Ar]3d10 4s2",			"2 8 18 2", 		LCAR.LCAR_Yellow)
		AddPToElement(13,  4, "gallium",	"Ga",	   69.723,	"[Ar]4s2 3d10 4p1",		"2 8 18 3", 		LCAR.LCAR_Purple )
		AddPToElement(14,  4, "germanium",	"Ge",	   72.630,	"[Ar]3d10 4s2 4p2",		"2 8 18 4", 		LCAR.LCAR_Purple )
		AddPToElement(15,  4, "arsenic",	"As",	   74.922,	"[Ar]4s2 3d10 4p3", 	"2 8 18 5",			LCAR.LCAR_DarkYellow)
		AddPToElement(16,  4, "selenium",	"Se",	   78.971,	"[Ar]3d10 4s2 4p4",		"2 8 18 6", 		LCAR.LCAR_DarkYellow )
		AddPToElement(17,  4, "bromine",	"Br",	   79.904,	"[Ar]4s2 3d10 4p5", 	"2 8 18 7",			LCAR.LCAR_LightPurple )
		AddPToElement(18,  4, "krypton",	"Kr",	   83.798,	"[Ar]3d10 4s2 4p6", 	"2 8 18 8",			LCAR.LCAR_Red)
		
		AddPToElement( 1,  5, "rubidium",	"Rb",	   85.468,	"[Kr]5s1",				"2 8 18 8 1", 		LCAR.LCAR_DarkPurple )
		AddPToElement( 2,  5, "strontium",	"Sr",	   87.620,	"[Kr]5s2",				"2 8 18 8 2", 		LCAR.LCAR_Orange )
		AddPToElement( 3,  5, "yttrium",	"Y",	   88.906,	"[Kr]4d1 5s2",			"2 8 18 9 2",		LCAR.LCAR_Yellow)
		AddPToElement( 4,  5, "zirconium",	"Zr",	   91.224,	"[Kr]5s2 4d2",			"2 8 18 10 2",		LCAR.LCAR_Yellow)
		AddPToElement( 5,  5, "Niobium",	"Nb",	   92.906,	"[Kr]4d4 5s1",			"2 8 18 12 1",		LCAR.LCAR_Yellow)
		AddPToElement( 6,  5, "molybdenum",	"Mo",	   95.951,	"[Kr]5s1 4d5",			"2 8 18 13 1",		LCAR.LCAR_Yellow)
		AddPToElement( 7,  5, "technetium",	"Tc",	   98.000,	"[Kr]4d5 5s2",			"2 8 18 13 2",		LCAR.LCAR_Yellow)
		AddPToElement( 8,  5, "ruthenium",	"Ru",	  101.070,	"[Kr]4d7 5s1",			"2 8 18 15 1",		LCAR.LCAR_Yellow)
		AddPToElement( 9,  5, "rhodium",	"Rh",	  102.906,	"[Kr]5s1 4d8",			"2 8 18 16 1",		LCAR.LCAR_Yellow)
		AddPToElement(10,  5, "palladium",	"Pd",	  106.420,	"[Kr]4d10",				"2 8 18 18",		LCAR.LCAR_Yellow)
		AddPToElement(11,  5, "silver",		"Ag",	  107.868,	"[Kr]4d10 5s1",			"2 8 18 18 1",		LCAR.LCAR_Yellow)
		AddPToElement(12,  5, "cadmium",	"Cd",	  112.414,	"[Kr]5s2 4d10",			"2 8 18 18 2",		LCAR.LCAR_Yellow)
		AddPToElement(13,  5, "indium",		"In",	  114.818,	"[Kr]4d10 5s2 5p1",		"2 8 18 18 3", 		LCAR.LCAR_Purple )
		AddPToElement(14,  5, "tin",		"Sn",	  118.710,	"[Kr]4d10 5s2 5p2",		"2 8 18 18 4", 		LCAR.LCAR_Purple )
		AddPToElement(15,  5, "antimony",	"Sb",	  121.760,	"[Kr]4d10 5s2 5p3",		"2 8 18 18 5", 		LCAR.LCAR_Purple )
		AddPToElement(16,  5, "tellurium",	"Te",	  127.600,	"[Kr]4d10 5s2 5p4", 	"2 8 18 18 6",		LCAR.LCAR_DarkYellow)
		AddPToElement(17,  5, "iodine",		"I",	  126.904,	"[Kr]4d10 5s2 5p5", 	"2 8 18 18 7",		LCAR.LCAR_LightPurple)
		AddPToElement(18,  5, "xenon",		"Xe",	  131.293,	"[Kr]5s2 4d10 5p6", 	"2 8 18 18 8",		LCAR.LCAR_Red)
		
		AddPToElement( 1,  6, "caesium",	"Cs",	  132.905,	"[Xe]6s1",				"2 8 18 18 8 1", 	LCAR.LCAR_DarkPurple )
		AddPToElement( 2,  6, "barium",		"Ba",	  137.330,	"[Xe]6s2",				"2 8 18 18 8 2", 	LCAR.LCAR_Orange )
		AddPToElement( 3,  6, "lanthanum",	"La",	  138.905,	"[Xe]5d1 6s2",			"2 8 18 18 9 2",	LCAR.LCAR_Yellow):PToExtCache=71
		AddPToElement( 4,  6, "hafnium",	"Hf",	  178.490,	"[Xe]4f14 5d2 6s2",		"2 8 18 32 10 2",	LCAR.LCAR_Yellow)
		AddPToElement( 5,  6, "tantalum",	"Ta",	  180.948,	"[Xe]4f14 5d3 6s2",		"2 8 18 32 11 2",	LCAR.LCAR_Yellow)
		AddPToElement( 6,  6, "tungsten",	"W",	  183.840,	"[Xe]4f14 5d4 6s2",		"2 8 18 32 12 2",	LCAR.LCAR_Yellow)
		AddPToElement( 7,  6, "rhenium",	"Re",	  186.207,	"[Xe]4f14 5d5 6s2",		"2 8 18 32 13 2",	LCAR.LCAR_Yellow)
		AddPToElement( 8,  6, "osmium",		"Os",	  190.230,	"[Xe]4f14 5d6 6s2",		"2 8 18 32 14 2",	LCAR.LCAR_Yellow)
		AddPToElement( 9,  6, "iridium",	"Ir",	  192.217,	"[Xe]4f14 5d7 6s2",		"2 8 18 32 15 2",	LCAR.LCAR_Yellow)
		AddPToElement(10,  6, "platinum",	"Pt",	  195.084,	"[Xe]4f14 5d9 6s1",		"2 8 18 32 17 1",	LCAR.LCAR_Yellow)
		AddPToElement(11,  6, "Gold",		"Au",	  196.967,	"[Xe]4f14 5d10 6s1",	"2 8 18 32 18 1",	LCAR.LCAR_Yellow)
		AddPToElement(12,  6, "mercury",	"Hg",	  200.592,	"[Xe]4f14 5d10 6s2",	"2 8 18 32 18 2",	LCAR.LCAR_Yellow)
		AddPToElement(13,  6, "thallium",	"Tl",	  204.383,	"[Xe]4f14 5d10 6s2 6p1","2 8 18 32 18 3", 	LCAR.LCAR_Purple )
		AddPToElement(14,  6, "lead",		"Pb",	  207.200,	"[Xe]4f14 5d10 6s2 6p2","2 8 18 32 18 4",	LCAR.LCAR_Purple )
		AddPToElement(15,  6, "bismuth",	"Bi",	  208.980,	"[Xe]4f14 5d10 6s2 6p3","2 8 18 32 18 5", 	LCAR.LCAR_Purple )
		AddPToElement(16,  6, "polonium",	"Po",	  209.000,	"[Xe]6s2 4f14 5d10 6p4","2 8 18 32 18 6", 	LCAR.LCAR_Purple )
		AddPToElement(17,  6, "astatine",	"At",	  210.000,	"[Xe]4f14 5d10 6s2 6p5","2 8 18 32 18 7",	LCAR.LCAR_LightPurple)
		AddPToElement(18,  6, "radon",		"Rn",	  222.000,	"[Xe]4f14 5d10 6s2 6p6","2 8 18 32 18 8",	LCAR.LCAR_Red)
		
		AddPToElement( 1,  7, "francium",	"Fr",	  223.000,	"[Rn]7s1",				"2 8 18 32 18 8 1",	LCAR.LCAR_DarkPurple )
		AddPToElement( 2,  7, "radium",		"Ra",	  226.030,	"[Rn]7s2",				"2 8 18 32 18 8 2", LCAR.LCAR_Orange )
		AddPToElement( 3,  7, "actinium",	"Ac",	  227.000,	"[Rn]6d1 7s2",			"2 8 18 32 18 9 2",	LCAR.LCAR_Yellow):PToExtCache=103
		AddPToElement( 4,  7, "rutherfordium",	"Rf", 267.000,	"[Rn]5f14 6d2 7s2",		"2 8 18 32 32 10 2",LCAR.LCAR_Yellow)
		AddPToElement( 5,  7, "dubnium",	"Db",	  268.000,	"[Rn]5f14 6d3 7s2",		"2 8 18 32 32 11 2",LCAR.LCAR_Yellow)
		AddPToElement( 6,  7, "seaborgium",	"Sg",	  269.000,	"[Rn]7s2 5f14 6d4",		"2 8 18 32 32 12 2",LCAR.LCAR_Yellow)
		AddPToElement( 7,  7, "bohrium",	"Bh",	  270.000,	"[Rn]5f14 6d5 7s2",		"2 8 18 32 32 13 2",LCAR.LCAR_Yellow)
		AddPToElement( 8,  7, "hassium",	"Hs",	  269.000,	"[Rn]5f14 6d6 7s2",		"2 8 18 32 32 14 2",LCAR.LCAR_Yellow)
		AddPToElement( 9,  7, "meitnerium",	"Mt",	  278.000,	"[Rn]7s2 5f14 6d7",		"2 8 18 32 32 15 2",LCAR.LCAR_Yellow)
		AddPToElement(10,  7, "darmstadtium",	"Ds", 281.000,	"[Rn]7s2 5f14 6d8",		"2 8 18 32 32 16 2",LCAR.LCAR_Yellow)
		AddPToElement(11,  7, "roentgenium","Rg",     281.000,	"[Rn]5f14 6d9 7s2",		"2 8 18 32 32 17 2",LCAR.LCAR_Yellow)
		AddPToElement(12,  7, "copernicium","Cn",     285.000,	"[Rn]5f14 6d10 7s2",	"2 8 18 32 32 18 2",LCAR.LCAR_Yellow)
		AddPToElement(13,  7, "nihonium",	"Nh", 	  286.000,	"[Rn]5f14 6d10 7s2 7p1","2 8 18 32 32 18 3",LCAR.LCAR_White)'113
		AddPToElement(14,  7, "flerovium",	"Fl", 	  289.000,	"[Rn]5f14 6d10 7s2 7p2","2 8 18 32 32 18 4",LCAR.LCAR_White)'114
		AddPToElement(15,  7, "moscovium",	"Mc",    288.000,	"[Rn]5f14 6d10 7s2 7p3","2 8 18 32 32 18 5",LCAR.LCAR_White)'115
		AddPToElement(16,  7, "livermorium","Lv",     293.000,	"[Rn]5f14 6d10 7s2 7p4","2 8 18 32 32 18 6",LCAR.LCAR_White)'116
		AddPToElement(17,  7, "tennessine",	"Ts",    294.000,	"[Rn]5f14 6d10 7s2 7p5","2 8 18 32 32 18 7",LCAR.LCAR_White)'117
		AddPToElement(18,  7, "oganesson",	"Og",    294.000,	"[Rn]5f14 6d10 7s2 7p6","2 8 18 32 32 18 8",LCAR.LCAR_White)'118
		
		AddPToElement(18,  8, "RODDENBERRIUM", 	"Gr", 1996.00,	"[ST]TOS3 TNG7",		"3 7",				-Colors.red):PToExtCache=57
		
		AddPToElement( 3,  9, "cerium",		"Ce",	  140.116,	"[Xe]4f 5d 6s2",		"2 8 18 19 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 4,  9, "praseodymium",	"Pr", 140.908,	"[Xe]4f3 6s2",			"2 8 18 21 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 5,  9, "neodymium",	"Nd",	  144.242,	"[Xe]4f4 6s2",			"2 8 18 22 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 6,  9, "promethium",	"Pm",	  145.000,	"[Xe]4f5 6s2",			"2 8 18 23 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 7,  9, "samarium",	"Sm",	  150.360,	"[Xe]6s2 4f6",			"2 8 18 24 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 8,  9, "europium",	"Eu",	  151.964,	"[Xe]4f7 6s2",			"2 8 18 25 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 9,  9, "gadolinium",	"Gd",	  157.250,	"[Xe]4f7 5d1 6s2",		"2 8 18 25 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(10,  9, "terbium",	"Tb",	  158.925,	"[Xe]4f9 6s2",			"2 8 18 27 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(11,  9, "dysprosium",	"Dy",	  162.500,	"[Xe]4f10 6s2",			"2 8 18 28 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(12,  9, "holmium",	"Ho",	  164.930,	"[Xe]4f11 6s2",			"2 8 18 29 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(13,  9, "erbium",		"Er",	  167.259,	"[Xe]4f12 6s",			"2 8 18 30 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(14,  9, "thulium",	"Tm",	  168.934,	"[Xe]4f13 6s2",			"2 8 18 31 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(15,  9, "ytterbium",	"Yb",	  173.055,	"[Xe]4f14 6s2",			"2 8 18 32 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(16,  9, "lutetium",	"Lu",	  174.967,	"[Xe]6s2 4f14 5d1",		"2 8 18 32 9 2",	LCAR.LCAR_DarkOrange):PToExtCache=89
		
		AddPToElement( 3, 10, "thorium",	"Th",	  232.038,	"[Rn]6d2 7s2",			"2 8 18 32 18 10 2",LCAR.LCAR_DarkOrange)
		AddPToElement( 4, 10, "protactinium",	"Pa", 231.036,	"[Rn]5f2 6d1 7s2",		"2 8 18 32 20 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 5, 10, "uranium",	"U",	  238.029,	"[Rn]5f3 6d1 7s2",		"2 8 18 32 21 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 6, 10, "neptunium",	"Np",	  237.000,	"[Rn]5f4 6d1 7s2",		"2 8 18 32 22 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 7, 10, "plutonium",	"Pu",	  244.000,	"[Rn]5f6 7s2",			"2 8 18 32 24 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 8, 10, "americium",	"Am",	  243.000,	"[Rn]5f7 7s2",			"2 8 18 32 25 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement( 9, 10, "curium",		"Cm",	  247.000,	"[Rn]5f7 6d1 7s2",		"2 8 18 32 25 9 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(10, 10, "berkelium",	"Bk",	  247.000,	"[Rn]5f9 7s2",			"2 8 18 32 27 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(11, 10, "californium","Cf",	  251.000,	"[Rn]5f10 7s2",			"2 8 18 32 28 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(12, 10, "einsteinium","Es",	  252.000,	"[Rn]5f11 7s2",			"2 8 18 32 29 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(13, 10, "fermium",	"Fm",	  257.000,	"[Rn]5f12 7s2",			"2 8 18 32 30 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(14, 10, "mendelevium","Md",	  258.000,	"[Rn]5f13 7s2",			"2 8 18 32 31 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(15, 10, "nobelium",	"No",	  259.000,	"[Rn]5f14 7s2",			"2 8 18 32 32 8 2",	LCAR.LCAR_DarkOrange)
		AddPToElement(16, 10, "lawrencium",	"Lr",	  262.000,	"[Rn]7s2 5f14 7p1",		"2 8 18 32 32 8 3",	LCAR.LCAR_DarkOrange)
	Else
		R=12
		S=23
		AddPToElement( 1,  1, "HYDROGEN",	"H",		   01,	1,						"", 				LCAR.LCAR_Yellow)
		AddPToElement( 9,  1, "MAZIOAIUM",	"Rx",	   	   32,	2,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  1, "ESTONIANIUM","Es",	       84,	6,						"", 				LCAR.LCAR_DarkYellow)
		
		AddPToElement( 1,  2, "LITHIUM",	"Le",		   03,	2,						"", 				LCAR.Classic_Turq)
		AddPToElement( 2,  2, "BENIUM",		"Be",		   04,	2,						"", 				LCAR.LCAR_LightPurple)
		AddPToElement( 8,  2, "MAZIOAIUM",	"Rx",	   	   32,	2,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement( 9,  2, "BROWNFIELDIUM",	"Br",	  164,	3,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  2, "POI",		"Po",	   	  230,	10,						"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 1,  3, "SODIUM",		"Na",	   	   11,	3,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 2,  3, "MAGNUMIUM",	"Mg",	   	   12,	3,						"", 				LCAR.LCAR_LightPurple)
		AddPToElement( 8,  3, "BROWNFIELDIUM",	"Br",	  164,	3,						"", 				LCAR.LCAR_Yellow)
		AddPToElement( 9,  3, "FREEDOMIA",	"Fr",	  	   32,	6,						"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 1,  4, "SODIUM",		"K",	   	   18,	6,						"", 				LCAR.LCAR_LightPurple)
		AddPToElement( 2,  4, "CALIFORNIUM","Ca",	   	   19,	6,						"", 				LCAR.LCAR_Purple )
		AddPToElement( 3,  4, "ESTONIANIUM","Es",	       84,	6,						"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 4,  4, "STOOGEIAN",	"La",	       19,	-6,						"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 5,  4, "PARAMOUNT",	"Pa",	       23,	6,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 6,  4, "SNARKIUM",	"Sn",	       56,	-6,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 7,  4, "JOHNSONIUM",	"Es",	       99,	-6,						"", 				LCAR.Classic_Yellow)
		AddPToElement( 8,  4, "FREEDOMIA",	"Fr",	  	   32,	6,						"", 				LCAR.LCAR_Yellow)
		AddPToElement( 9,  4, "CHANOCKIAN",	"Ed",	  	   66,	9,						"", 				LCAR.LCAR_Yellow)
		AddPToElement(10,  4, "PILLERIUM",	"Mi",	  	   55,	R+9,					"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 1,  5, "RHUBARBIUM",	"Rb",	   	   37,	9,						"", 				LCAR.LCAR_LightPurple)
		AddPToElement( 2,  5, "COSMOIUM",	"Cs",	   	   37,	9,						"", 				LCAR.LCAR_Purple)
		AddPToElement( 3,  5, "POI",		"Po",	   	  230,	10,						"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 4,  5, "STOOGEIAN",	"Mo",	   	   10,	-11,					"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 5,  5, "POTATOEIUM",	"Qu",	   	   70,	8,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 6,  5, "QUARKIUM",	"Qk",	   	   37,	9,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 7,  5, "HARPO",		"Mx",	   	   88,	9,						"", 				LCAR.Classic_Yellow)
		AddPToElement( 8,  5, "CHANOCKIAN",	"Ed",	   	   66,	9,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 9,  5, "CHEESIUM",	"Sw",	   	   87,	R+9,					"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  5, "NESWORDMINIUM",	"An",	    9,	R+11,					"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 1,  6, "HYDROGEN",	"Cs",	   	   01,	11,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement( 2,  6, "BABALOD",	"B2",	   	   68,	11,						"", 				LCAR.LCAR_Purple)
		AddPToElement( 3,  6, "KRYPTONITE",	"Kr",	   	   01,	12,						"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 4,  6, "CURLY",		"Cr",	   	   90,	10,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 5,  6, "JAMESIUM",	"Rj",	   	  123,	11,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 6,  6, "CRAFTIAM",	"Ri",	   	   92,	10,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 7,  6, "GROUCHO",	"Mr",	   	   22,	11,						"", 				LCAR.Classic_Yellow)
		AddPToElement( 8,  6, "KEITHORIUM",	"Ke",	   	   22,	11,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement( 9,  6, "CAVORITE",	"Co",	   	   89,	R+9,					"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  6, "CHRONISTER",	"Fx",	   	   55,	R+11,					"", 				LCAR.LCAR_Purple)
		
		AddPToElement( 1,  7, "FRANCONIUM",	"Fr",	   	   87,	12,						"", 				LCAR.LCAR_LightBlue)
		AddPToElement( 2,  7, "GROUCHRIAN",	"Mx",	   	   87,	10,						"", 				LCAR.LCAR_Purple)
		AddPToElement( 3,  7, "DILITHIUM",	"Kr",	   	   87,	10,						"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 4,  7, "PRINCESSIUM","Di",	   	   77,	11,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 5,  7, "REDSKINIUM",	"Hg",	   	   92,	11,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 6,  7, "FIELDIUM",	"Wc",	   	  100,	8,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 7,  7, "ZEPPO",		"Mx",	   	   87,	11,						"", 				LCAR.Classic_Yellow)
		AddPToElement( 8,  7, "HOBBES",		"Ca",	   	   01,	11,						"", 				LCAR.Classic_Yellow)
		AddPToElement( 9,  7, "JONESIUM",	"Ch",	   	   87,	R+9,					"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  7, "ATOMSONIUM",	"Ma",	   	   87,	-R-9,					"", 				LCAR.LCAR_Purple)
		
		AddPToElement( 1,  8, "ACCUREDIUM",	"Ac",	   	  108,	12,						"", 				LCAR.LCAR_Orange)
		AddPToElement( 2,  8, "YACOBIAN",	"Br",	   	   39,	11,						"", 				LCAR.LCAR_Yellow)
		AddPToElement( 3,  8, "PURSEROMITE","Tm",	   	   66,	-11,					"", 				LCAR.LCAR_DarkBlue)
		AddPToElement( 4,  8, "TAGONIAN",	"St",	   	   77,	10,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 5,  8, "FIELDIUM",	"Wc",	   	  100,	8,						"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 6,  8, "SMUTKOIUM",	"Al",	   	   66,	-10,					"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 7,  8, "DENTIUM",	"Ar",	   	   87,	R+9,					"", 				LCAR.Classic_Yellow)
		AddPToElement( 8,  8, "BERMATIUM",	"Br",	   	   87,	-R-9,					"", 				LCAR.LCAR_Yellow)
		AddPToElement( 9,  8, "AVERYONIUM",	"Tx",	   	   55,	R+11,					"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 1,  9, "CHICO",		"Ab",	   	   55,	R+8,					"", 				LCAR.LCAR_LightBlue )
		AddPToElement( 9,  9, "EXITSTAGELEFT","Sn",	   	   87,	R+9,					"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10,  9, "THOMPSONIUM","Bi",	   	   55,	-R-9,					"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 3, 10, "MEESEIAN",	"Cd",	   	  189,	R+10,					"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 4, 10, "DISNEYIUM",	"Dy",	   	   87,	R+9,					"", 				LCAR.LCAR_Purple)
		AddPToElement( 5, 10, "BUGSOMIUM",	"Bu",	   	  120,	S+9,					"", 				LCAR.LCAR_Purple)
		AddPToElement( 6, 10, "DAFFYDUCKIUM","Da",	   	   87,	S+8,					"", 				LCAR.LCAR_Purple)
		AddPToElement( 7, 10, "DRAPANIUM",	"Wy",	   	  156,	S+7,					"", 				LCAR.LCAR_DarkYellow)
		AddPToElement( 8, 10, "BUCKROGERS",	"Da",	   	  139,	R+10,					"", 				LCAR.LCAR_Orange)
		AddPToElement( 9, 10, "SUFFERIN'SUCAT","Sy",   	   55,	S+6,					"", 				LCAR.LCAR_LightBlue)
		AddPToElement(10, 10, "HAWKEYE",	"Ef",	   	   87,	S+7,					"", 				LCAR.LCAR_LightBlue)
		
		AddPToElement( 4, 11, "MONTY",		"Py",	   	   87,	R+9,					"", 				LCAR.LCAR_Purple)
		AddPToElement( 5, 11, "ZEPPO",		"Mx",	   	   87,	S+9,					"", 				LCAR.LCAR_Purple)
		AddPToElement( 6, 11, "HAWKEYE",	"Md",	   	   87,	-S-9,					"", 				LCAR.LCAR_Purple)
	End If
	ElementMode=Mode
	PToExtCache=0
	SelectedElementChange
End Sub
Sub DrawPToE(BG As Canvas, X As Int ,Y As Int, Width As Int, Height As Int, TopText As String, BottomText As String, RedAlert As Int, Mode As Int)'0=normal 1=april fools
	Dim WhiteSpace As Int, Rows As Int,temp As Int, RowHeight As Int, FirstItems As List,X2 As Int ,Y2 As Int,Twidth As Int,Cols As Int, FirstOne As Int, Length As Int,FirstY As Int
	Dim RedAlertColor As Int,ButtonWidth As Int, DrawBottom As Boolean ,Y3 As Int,Columns As Int
	WhiteSpace=5
	'Width=Width+1:Height=Height+1
	LCAR.DrawRect(BG,X,Y,Width+2,Height+2, Colors.Black,0)
	temp= API.IIF(Mode=0, 3,4)
	Twidth=LCAR.ItemHeight/temp
	If Mode=0 Then
		'PToEColWidth= LCAR.ItemHeight + BG.MeasureStringWidth("RODDENBERRIUM", LCAR.LCARfont, PToExtsize )
		PToEColWidth= LCAR.ItemHeight + BG.MeasureStringWidth(PTOE_Longest, LCAR.LCARfont, PToExtsize )
		Columns=18
	Else
		If Not(CenterPlatform.IsInitialized ) Or CenterPlatformID <> LCAR.LCAR_PToE  Then
			CenterPlatformID=LCAR.LCAR_PToE
			CenterPlatform.Initialize(File.DirAssets, "elements.png")
		End If
		Columns=10
		TopText=API.GetString("ptoe_afm")' "THE TABLE OF ELEMENTS 99823"
		BottomText=""
		PToEColWidth= Twidth+ BG.MeasureStringWidth("NESWORDMINIUM ", LCAR.LCARfont, PToExtsize )*2'LCAR.ItemHeight +
	End If
	If Not(Elements.IsInitialized ) Or ElementMode<> Mode Then'heights of objects = LCAR.ItemHeight
		SelectedElement.Initialize 'col/row of selected element
		TheSelectedElement.Initialize 
		PToECursor.Initialize 'col/row of starting element
		'Log("798 2a")
		If LCAR.RedAlert Then LCAR.SetRedAlert(False,"DrawPToE")
		SetupElements(Mode)
	End If
	If PToExtCache <> LCAR.ItemHeight Then
		PToExtsize = API.GetTextHeight(BG, Twidth, "1234567890", LCAR.LCARfont) 
		PToExtCache=LCAR.ItemHeight
	End If
	If PToECursor.X>0 Then
		Cols=Floor(Width/(PToEColWidth+WhiteSpace))
		PToECursor.X = Min(PToECursor.X , Max(0, Columns+1-Cols))
	End If
	If LCAR.RedAlert Then RedAlertColor = LCAR.GetColor(LCAR.LCAR_redalert, False,255)
	
	
	'DrawTextButton(BG,X,Y,Width, LCAR.LCAR_LightBlue, LCAR.LCAR_Purple, LCAR.LCAR_LightBlue, 255, False,  TopText, LCAR.LCAR_Orange, False, True, False)
	'DrawTextButton(BG,X,Y+Height-LCAR.ItemHeight,Width, LCAR.LCAR_LightBlue, LCAR.LCAR_Purple, LCAR.LCAR_LightBlue, 255, False,  BottomText, LCAR.LCAR_Orange, False, False, False)
	Height=Height-LCAR.ItemHeight*2
	
	FirstY=PToEColWidth+WhiteSpace'width of column
	Length=FirstY*Columns'width of table
	PTOESIZE = Length
	
	FirstOne=Length/5'width of text block
	X2=X - (PToECursor.X*FirstY) 'left position
	
	RowHeight=Length+(LCAR.leftside + WhiteSpace+Twidth)*2
	ButtonWidth=RowHeight
	If PToECursor.Y=0 Then
		DrawTextButton(BG,X2,Y,RowHeight, LCAR.LCAR_LightBlue, LCAR.LCAR_Purple, LCAR.LCAR_LightBlue, 255, False,  TopText, LCAR.LCAR_Orange, False, True, False)
		Y=Y+LCAR.ItemHeight
	End If
	
	If TheSelectedElement.X<0 Then TheSelectedElement.X=0 
	If TheSelectedElement.Y<0 Then TheSelectedElement.Y=0 
	If TheSelectedElement.X>=PToECursor.X Then
		DrawPToEObject(BG, X+ Twidth+LCAR.leftside + WhiteSpace + ((TheSelectedElement.X-PToECursor.X)* (PToEColWidth+WhiteSpace)), Y, PToEColWidth,  LCAR.ItemHeight, 1, "",  PToECursor.Y,0,"","", TheSelectedElement.X , Twidth)
	End If
	
	RowHeight=LCAR.ItemHeight+WhiteSpace
	If Max(0,PToECursor.Y) <4 And Mode=0 Then
		X2=X+ Twidth+LCAR.leftside + WhiteSpace + ((3-PToECursor.X)* (PToEColWidth+WhiteSpace))
		DrawPToEObject(BG,X2,Y, 4*FirstY, RowHeight *4 - 5, 7,  "",PToECursor.Y*RowHeight,0,"","",0,0)
	End If
	
	FirstItems.Initialize2(Array As Int(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1))
	'Height=Height-(RowHeight*3)
	Rows=Ceil(Height/ RowHeight )'-1
	Y2=Y+RowHeight
	Y=Y+RowHeight*2
	
	If PToECursor.Y>0 Then PToECursor.Y = Min(PToECursor.Y , Max(0, 13-Rows+Mode))
	
	For temp = 0 To Rows
		Y = DrawPToELine(BG, temp + PToECursor.Y, X,Y, Width,LCAR.ItemHeight,  WhiteSpace, PToECursor.X ,FirstItems ,Twidth,RedAlert,RedAlertColor )
		If temp + PToECursor.Y >= Elements.Size-1 Then DrawBottom=True Else Y3=Y
		If Y=-1 Then Exit
	Next
	
	Rows=X+Width
	X2=X
	X=X+Twidth+LCAR.leftside + WhiteSpace
	
	
	FirstOne=0
	Length=0
	If Mode = 0 Then'draw normal column headers
		For temp = PToECursor.X To FirstItems.Size-1
			Y=FirstItems.Get(temp) - PToECursor.Y 
			If Y>-1 Then
				DrawPToEObject(BG, X,  Y2+ RowHeight* Y, PToEColWidth, LCAR.ItemHeight, 3,GetRomanNumeral(temp),  temp+1, 0, "","", Colors.Red, Twidth)  
				If temp>6 And temp<10 Then
					If FirstOne=0 Then FirstOne = X
					FirstY=Y2+ RowHeight* Y
					Length=Length+1
				End If
			End If
			X=X+PToEColWidth+WhiteSpace
			If X >Rows Then Exit'+PToEColWidth
		Next
		If Length>1  Then
			DrawPToEObject(BG, FirstOne, FirstY, PToEColWidth + ((Length-1)*(PToEColWidth+WhiteSpace))  , LCAR.ItemHeight, 5,GetRomanNumeral(8), 0, 0, "","", Colors.Red, Twidth)
		End If
	End If
	
	If DrawBottom Then
		FirstY=PToEColWidth+WhiteSpace'width of column
		Length=FirstY*Columns'width of table
		FirstOne=Length/5'width of text block
		X=X2
		X2=X+Twidth+LCAR.leftside + WhiteSpace - (PToECursor.X*FirstY) 'left position
		
		If Mode=0 Then
			Y2=Y3+LCAR.ItemHeight+5'Y+Height-LCAR.ItemHeight-5
			temp =DrawPToEObject(BG, X2, Y2, 5, 0,6, API.getstring("ptoe_nonmetals"), 0,0,"","",  LCAR.LCAR_DarkYellow, 0)'height of text
			DrawPToEObject(BG, X2, Y2+temp+2, 5, 0,6, API.getstring("ptoe_alkalimetals"), 0,0,"","",  LCAR.LCAR_DarkPurple, 0)
			X2=X2+FirstOne
			DrawPToEObject(BG, X2, Y2, 5, 0,6,API.getstring("ptoe_terranmetals"), 0,0,"","",  LCAR.LCAR_Orange, 0)
			DrawPToEObject(BG, X2, Y2+temp+2, 5, 0,6, API.getstring("ptoe_transitionmetals"), 0,0,"","",  LCAR.LCAR_Yellow, 0)
			X2=X2+FirstOne
			DrawPToEObject(BG, X2, Y2, 5, 0,6, API.getstring("ptoe_poormetals"), 0,0,"","",  LCAR.LCAR_Purple, 0)
			DrawPToEObject(BG, X2, Y2+temp+2, 5, 0,6, API.getstring("ptoe_halogens"), 0,0,"","",  LCAR.LCAR_LightPurple, 0)
			X2=X2+FirstOne
			Length=0'LCAR.TextHeight(BG,"NOBLE GAS / INERT ELEMENTS")-temp
			DrawPToEObject(BG, X2, Y2, 5, 0,6, API.getstring("ptoe_inert"), Length,0,"","",  LCAR.LCAR_Red, 0)
			DrawPToEObject(BG, X2, Y2+temp+2, 5, 0,6, "LANTHANIDE SERIES", 0,0,"","",  LCAR.LCAR_DarkOrange, 0)
			X2=X2+FirstOne
			DrawPToEObject(BG, X2, Y2, 5, 0,6, "CURRENTLY UNDER INVESTIGATION", 0,0,"","",  LCAR.LCAR_White, 0)
			DrawPToEObject(BG, X2, Y2+temp+2, 5, 0,6, "24TH CENTURY ELEMENTS", 0,0,"","",  Colors.red, 0)
		Else
			Dim texts As List = API.GetStrings("ptoe_text",0)
			For temp = 0 To texts.Size - 1 
				DrawPToEText2(BG,X2,Y3+(Twidth*temp), texts.Get(temp), PToExtsize, False, Colors.White) 	
			Next
			'DrawPToEText2(BG,X2,Y3, "THIS TABLE LISTS THOSE ELEMENTS UTILIZED BY THE" , PToExtsize, False, Colors.White) 
			'DrawPToEText2(BG,X2,Y3+Twidth, "STANDARDIZED TEXTS OF THE STARFLEET EDUCATIONAL" , PToExtsize, False, Colors.White)
			'DrawPToEText2(BG,X2,Y3+Twidth*2, "TEXTS. OTHER CHARTS ARE AVAILABLE BY ACCESSING" , PToExtsize, False, Colors.White)
			'DrawPToEText2(BG,X2,Y3+Twidth*3, "MATERIAL UNDER THE HEADING 'NEAT STUFF'." , PToExtsize, False, Colors.White)
			
			'LCAR.DrawText(BG, X2,Y3, "THIS TABLE LISTS THOSE ELEMENTS UTILIZED BY THE" & CRLF & "STANDARDIZED TEXTS OF THE STARFLEET EDUCATIONAL" & CRLF & "TEXTS. OTHER CHARTS ARE AVAILABLE BY ACCESSING" & CRLF & "MATERIAL UNDER THE HEADING 'NEAT STUFF'.",  LCAR.LCAR_Orange, 0,False,255,0)
		End If
		X2=X - (PToECursor.X*FirstY) 'left position
		DrawTextButton(BG,X2,Max(Y+Height+LCAR.ItemHeight-1, Y2+temp*2+6),ButtonWidth, LCAR.LCAR_LightBlue, LCAR.LCAR_Purple, LCAR.LCAR_LightBlue, 255, False,  BottomText, LCAR.LCAR_Orange, False, False, False)
	End If
End Sub
Sub GetRomanNumeral(Value As Int) As String
	Return API.IIFIndex(Value,Array As String( "IA", "IIA", "IIIB", "IVB", "VB", "VIB", "VIIB", "VIIIB", "VIIIB", "VIIIB", "IB", "IIB","IIIA","IVA","VA","VIA","VIIA", "VIIIA" ))
End Sub
Sub DrawPToELine(BG As Canvas, Row As Int,  X As Int, Y As Int, Width As Int, Height As Int,WhiteSpace As Int, Start As Int, FirstItems As List,Twidth As Int,RedAlert As Int,RedAlertColor As Int) As Int 
	Dim Line As PtoELine, Element As PToElement, temp As Int ,X2 As Int,  Top As Int,Color As Int,DrewElement As Int,ColWidth As Int,Y2 As Int 'row height = LCAR.ItemHeight
	If Row = TheSelectedElement.Y  Then
		DrawPToEObject(BG,X,Y, LCAR.leftside,LCAR.ItemHeight,2, "",0,0,"","", 0, Twidth)
	End If
	ColWidth=PToEColWidth+WhiteSpace
	DrewElement=-1
	If Row < Elements.Size And Row>-1 Then
		Line = Elements.Get(Row)
		If ElementMode=1 Then
			X2 = X+ Twidth+LCAR.leftside + WhiteSpace
			Y2=Y-5-PToExtsize
			Select Case Row
				Case 0
					DrawPToEObject(BG,X2+ (-Start* ColWidth),Y2, ColWidth-5, LCAR.ItemHeight, 3, "" , 0, 0,"","", LCAR.LCAR_Purple   ,Twidth)
					DrawPToEObject(BG,X2+ ((8-Start)* ColWidth), Y2, ColWidth*2-5, LCAR.ItemHeight,3, API.getstring("ptoe_transonic"), 0, 0,"","", LCAR.LCAR_Purple   ,Twidth)
				Case 3
					DrawPToEObject(BG,X2+ ((2-Start)* ColWidth), Y2, ColWidth*2-5, LCAR.ItemHeight,3, API.getstring("ptoe_hypersonic"), 0, 0,"","", LCAR.LCAR_Purple   ,Twidth)
					DrawPToEObject(BG,X2+ ((4-Start)* ColWidth), Y2, ColWidth-5, LCAR.ItemHeight,3, API.getstring("ptoe_gamma"), 0, 0,"","", LCAR.LCAR_Orange   ,Twidth)
					DrawPToEObject(BG,X2+ ((5-Start)* ColWidth), Y2, ColWidth-5, LCAR.ItemHeight,3, API.getstring("ptoe_omega"), 0, 0,"","", LCAR.LCAR_Orange   ,Twidth)
					DrawPToEObject(BG,X2+ ((6-Start)* ColWidth), Y2, ColWidth-5, LCAR.ItemHeight,3, API.getstring("ptoe_world"), 0, 0,"","", LCAR.LCAR_Purple   ,Twidth)
				Case 9
					DrawPToEObject(BG,X2+ ((2-Start)* ColWidth), Y2, ColWidth*6-5, LCAR.ItemHeight,3, API.getstring("ptoe_mega"), 0, 0,"","", LCAR.LCAR_Purple   ,Twidth)
			End Select
		End If
		For temp = 0 To Line.Cols.Size-1
			If temp>-1 Then
				Element=Line.Cols.Get(temp)
				If Element.X >= Start Then
					If Element.X<FirstItems.Size And Element.X>-1 Then
						Top=FirstItems.Get(Element.X)
						If Top =-1 Or Top> Row Then  
							If Row=8 Then
								FirstItems.Set(Element.X, Row-1)
							Else
								FirstItems.Set(Element.X, Row)
							End If
						End If
					End If
					X2 = X+ Twidth+LCAR.leftside + WhiteSpace + ((Element.X-Start)* ColWidth)
					If X2< X+Width Then'+PToEColWidth
						If LCAR.RedAlert Then
							Color = API.IIF(RedAlert=Element.AtomicNumber, Colors.White, RedAlertColor)
						Else
							Color =  Element.Color
						End If
						If DrewElement=-1 Then	DrewElement=X2
						DrawPToEObject(BG, X2, Y, PToEColWidth, LCAR.ItemHeight, 0, Element.AtomicSymbol , Element.AtomicNumber , Element.AtomicWeight , Element.Molecule , Element.ElectronConfiguration , Color, Twidth)
					End If
				End If
			End If
		Next
		If DrewElement>-1 And Row<8 Then'
			DrawPToEObject(BG,X+ LCAR.leftside,Y, 10, LCAR.ItemHeight, 4, "", Row+1, Twidth,"","", Colors.Red, Twidth)
			'DrawPToEObject(BG,DrewElement-16,Y, 10, LCAR.ItemHeight, 4, "", Row+1, Twidth,"","", Colors.Red, Twidth)
		End If
		Return Y + LCAR.ItemHeight + WhiteSpace
	End If
	Return -1
End Sub
Sub DrawPToEObject(BG As Canvas, X As Int ,Y As Int, Width As Int,Height As Int, ObjectType As Int, AtomicSymbol As String,AtomicNumber As Int, AtomicWeight As Double,Molecule As String,ElectronConfiguration As String,Color As Int,Twidth As Int )As Int
	Dim TriangleHeight As Int,orange As Int ,Radius As Int, Shell As PToEShell ,temp As Int ,angle As Int, Append As String = ": "
	Select Case ObjectType
		Case 0'Element
			TriangleHeight=Height*0.5'Height/3
			DrawLegacyButton(BG,X,Y,Width, Height, Color, "", -TriangleHeight, 0)
			If ElementMode=0 Then
				If AtomicSymbol.Length<3 Then
					LCAR.DrawTextbox(BG, AtomicSymbol, LCAR.LCAR_Black, X,Y, TriangleHeight,Height,5)
				Else
					DrawPToEText(BG, X+TriangleHeight/2, Y+Twidth, AtomicSymbol,  Twidth, True)
				End If
				DrawPToEText(BG, X+TriangleHeight, Y, AtomicNumber & "·" & AtomicWeight,  Twidth, False)
				DrawPToEText(BG, X+TriangleHeight, Y+Twidth, Molecule,  Twidth, False)
				'DrawPToEText(BG, X+TriangleHeight, Y+Twidth*2, ElectronConfiguration,  Twidth, False)
				DrawPToESuperText(BG, X+TriangleHeight, Y+Twidth*2, ElectronConfiguration, Twidth,PToExtsize, Colors.Black)
				
				If (AtomicNumber > 56 And AtomicNumber<72)  Or AtomicNumber = 89 Then 
					orange=LCAR.GetColor(LCAR.LCAR_Orange,False,255)
					LCAR.ActivateAA(BG,True)
					If AtomicNumber = 57  Then'shorter |
						LCAR.DrawRect(BG,X + Width +1,Y, 3, Height+6, orange, 0)
					Else If AtomicNumber = 58 Then'left -)
						Radius=Height/2
						TriangleHeight=Width- Radius+6
						
						LCAR.DrawRect(BG,X-4, Y-5, TriangleHeight+1, 3, orange,0)
						LCARSeffects.DrawCircleSegment(BG, X+TriangleHeight-4, Y-5-Radius, Radius-1,Radius+1,  90,90,orange,2,0,0)
					Else If AtomicNumber = 59 Then'right (-
						Radius=Height/2
						TriangleHeight=Width- Radius
						LCAR.DrawRect(BG,X+Height/2-4, Y-5, TriangleHeight+10, 3, orange,0)
						
						LCARSeffects.DrawCircleSegment(BG, X+Radius-3, Y-5-Radius, Radius-1,Radius+1, 270,-90,orange,2,0,0)
					Else If AtomicNumber>59 And AtomicNumber<72 Then'-----------
						LCAR.DrawRect(BG,X, Y-5, Width+6, 3, orange,0)
					Else If AtomicNumber = 89 Then'taller |
						LCAR.DrawRect(BG,X + Width +1,Y, 3, Height*1.5+6, orange, 0)
					End If
					LCAR.ActivateAA(BG,False)
				End If
			Else
				Radius=Width*0.5
				'LCAR.DrawText(BG, X+ Width*0.75, Y+1, AtomicSymbol, LCAR.LCAR_Black, 1,False,255,0)
				LCAR.DrawTextbox(BG, AtomicSymbol, LCAR.LCAR_Black, X+ Width*0.75-(TriangleHeight*0.5),Y+1,0,Height,2)
				DrawPToEText(BG, X+Radius, Y+TriangleHeight-1, Molecule,  Twidth, False)
				DrawPToEText(BG, X+Radius, Y+TriangleHeight+Twidth-1, "ATM WT " & API.PadtoLength(AtomicWeight,True,2,"0"),  Twidth, False)
				If ElectronConfiguration.length>0 Then'CenterPlatform  38x37
					orange = (Abs(ElectronConfiguration)-1) * 38
					TriangleHeight=TriangleHeight*0.5	
					If ElectronConfiguration>-1 Then
						BG.DrawBitmap(CenterPlatform, LCAR.SetRect(orange, 0, 37,37), LCAR.SetRect(X+TriangleHeight,Y,Height,Height))
					Else
						BG.DrawBitmapFlipped(CenterPlatform, LCAR.SetRect(orange, 0, 37,37), LCAR.SetRect(X+TriangleHeight,Y,Height,Height), True,True)
					End If
				End If
			End If
		Case 1'top triangle cursor
			TriangleHeight=20
			orange=255
			If Color >2 And Color<11 And AtomicNumber<4 Then orange=128
			LCARSeffects.DrawTriangle(BG, X+Width/2-TriangleHeight/2, Y+Height/2-TriangleHeight/2, TriangleHeight,TriangleHeight,  4, LCAR.GetColor(LCAR.LCAR_LightBlue,False,orange) )
		Case 2'left triangle cursor
			TriangleHeight=20
			LCARSeffects.DrawTriangle(BG, X, Y+Height/2-TriangleHeight/2, TriangleHeight,TriangleHeight, 3, LCAR.GetColor(LCAR.LCAR_LightBlue,False,255) )
		Case 3'column header
			TriangleHeight=Twidth'Height/3
			If ElementMode=0 Then
				LCAR.DrawRect(BG,X,Y,Width, TriangleHeight, Color, 0)
				DrawPToEText(BG,X+Width/2, Y, AtomicNumber, PToExtsize,True)
				
				LCAR.DrawRect(BG,X,Y+TriangleHeight*2+2,Width, TriangleHeight, Color, 0)
				DrawPToEText(BG,X+Width/2, Y+TriangleHeight*2+2, AtomicSymbol, PToExtsize,True)
			Else
				Color=LCAR.GetColor(Color,False,255)
				LCAR.DrawRect(BG,X,Y,Width,PToExtsize, Color,0)
				DrawPToEText2(BG,X+Width/2, Y, AtomicSymbol, -PToExtsize,True, Color)
			End If
		Case 4'row header
			If ElementMode=0 Then
				TriangleHeight=Twidth'Height/3
				LCAR.DrawRect(BG,X,Y,TriangleHeight,Height, Color,0)
				'LCAR.DrawTextbox(BG, AtomicNumber, LCAR.LCAR_Black, X,Y+Height/2-PToExtsize/2, Width,PToExtsize,5)
				BG.DrawText(AtomicNumber, X+Width/2+1, Y+Height/2+TriangleHeight/2, LCAR.LCARfont, PToExtsize, Colors.Black, "CENTER")
				'LCAR.DrawLCARtextbox(BG, X,Y+Height/2-PToExtsize/2, Width, PToExtsize, -1,0, AtomicNumber, LCAR.LCAR_Black,  -1,-1, False,False, 5,255)
			End If
		Case 5'long column header
			TriangleHeight=Twidth
			LCAR.DrawRect(BG,X,Y+TriangleHeight*2+2,Width, TriangleHeight, Color, 0)
			DrawPToEText(BG,X+Width/2, Y+TriangleHeight*2+2, AtomicSymbol, PToExtsize,True)
		Case 6'Legend text
			If AtomicSymbol.length>0 Then
				TriangleHeight = LCAR.TextHeight(BG, "ABC123")'AtomicSymbol)
			Else
				TriangleHeight = LCAR.TextHeight(BG, ElectronConfiguration)
			End If
			
			LCAR.DrawRect(BG,X,Y+ API.IIF(AtomicNumber=0,1,0)  +AtomicNumber,Width, TriangleHeight-AtomicNumber-API.IIF(AtomicNumber=0,0,1) ,LCAR.GetColor(LCAR.LCAR_LightBlue,False,255), 0)
			Y=Y-AtomicNumber
			If Color = Colors.Red Then
				BG.DrawText(AtomicSymbol, X+Width+3,  Y+TriangleHeight,LCAR.LCARfont, LCAR.Fontsize, Color,"LEFT")
			Else If ElectronConfiguration.Length =0 Then
				LCAR.DrawText(BG,X+Width+3, Y, AtomicSymbol, Color, 0,False,255,0)
			Else
				orange=LCAR.GetColor(Color,False,255)
				DrawPToESuperText(BG, X+Width+3, Y, ElectronConfiguration, TriangleHeight, LCAR.Fontsize, orange )
			End If
			Return TriangleHeight
		Case 7'selected element
			orange=LCAR.GetColor(LCAR.LCAR_Orange,False,255)
			If AtomicNumber>0 Then
				Radius=Y
				LCARSeffects.MakeClipPath(BG,X,Y,Width, Height-AtomicNumber)
				Y=Y-AtomicNumber
			End If
			TriangleHeight=LCARSeffects.DrawBracketS(BG, X, Y, Width,Height, orange, AtomicNumber=0)
			DrawPToEObject(BG,X+TriangleHeight,Y,Width-TriangleHeight*2, Height, 9, "", AtomicNumber, 0, "", "", 0, 0)
			If AtomicNumber>0 Then LCARSeffects.MakeClipPath(BG,X,Radius,Width*3, Height-AtomicNumber)
			
			Molecule = API.GetString("ptoe_molecule") & Append
			AtomicSymbol = API.GetString("ptoe_symbol") & Append
			ElectronConfiguration = API.getstring("ptoe_number") & Append 
			If ElementData.IsInitialized Then
				Molecule=Molecule & ElementData.Molecule 
				AtomicSymbol=AtomicSymbol & ElementData.AtomicSymbol 
				ElectronConfiguration=ElectronConfiguration & ElementData.AtomicNumber  
			End If
			X=X+Width +15
			Radius= DrawPToEObject(BG,X,Y, 5,0, 6, Molecule,  0,0,"","", LCAR.LCAR_Orange, 0)
			Radius= (Height-Radius)/4
			
			DrawPToEObject(BG,X,Y+Radius, 5,0, 6, AtomicSymbol,  0,0,"","", LCAR.LCAR_Orange, 0)
			DrawPToEObject(BG,X,Y+Radius*2, 5,0, 6, ElectronConfiguration,  0,0,"","", LCAR.LCAR_Orange, 0)
			
			AtomicSymbol = API.getstring("ptoe_weight") & Append 
			ElectronConfiguration = API.getstring("ptoe_electron") & Append  
			If ElementData.IsInitialized Then
				AtomicSymbol=AtomicSymbol & ElementData.AtomicWeight 
				ElectronConfiguration=ElectronConfiguration & ElementData.ElectronConfiguration 
			End If
			DrawPToEObject(BG,X,Y+Radius*3, 5,0, 6, AtomicSymbol,  0,0,"","", LCAR.LCAR_Orange, 0)
			DrawPToEObject(BG,X,Y+Radius*4, 5,0, 6, "",  0,0,"",ElectronConfiguration, LCAR.LCAR_Orange, 0)
			If AtomicNumber>0 Then BG.RemoveClip 
		Case 8'AtomicNumber=1=positron/AtomicNumber=0electron
			LCAR.ActivateAA(BG,True)
			If LCAR.RedAlert Then
				orange = LCAR.GetColor(LCAR.LCAR_RedAlert,AtomicNumber=1,255)
			Else If AtomicNumber=1 Then
				orange = Colors.RGB(203,153,190)
			Else 
				orange = Colors.RGB(203,103,153)
			End If
			BG.DrawCircle(X,Y, Width, orange,False,3)
			BG.DrawLine(X-Height,Y,X+Height,Y,orange,2)
			If AtomicNumber = 1 Then BG.DrawLine(X,Y-Height,X,Y+Height,orange,2)
			LCAR.ActivateAA(BG,False)
		Case 9'electron shells
			If ElectronShells.IsInitialized Then 
				LCARSeffects.MakeClipPath(BG,X,Y+AtomicNumber,Width, Height-AtomicNumber)
				Radius = (Width*0.6) / Max(4,ElectronShells.Size) / 2
				X=X+Width*0.6
				Y=Y+ Height* 0.6
				DrawPToEObject(BG, X, Y, Radius*2, Radius/2, 8, "", 1, 0,"","", 0,0)
				TriangleHeight=Radius*2
				For orange = 0 To ElectronShells.Size-1
					TriangleHeight=TriangleHeight+Radius
					Shell = ElectronShells.Get(orange)
					angle=Shell.angle 
					For temp = 1 To Shell.Electrons 
						DrawPToEObject(BG, Trig.findXYAngle(X,Y, TriangleHeight, angle, True), Trig.findXYAngle(X,Y, TriangleHeight, angle, False), Radius/2, Radius/4, 8,"",0,0,"","",0,0)
						angle=(angle+ 360/Shell.Electrons) Mod 360
					Next
				Next
				BG.RemoveClip 
			End If
	End Select
End Sub
Sub DrawPToEText2(BG As Canvas , X As Int, Y As Int, Text As String,TextHeight As Int, Center As Boolean ,Color As Int )
	Dim Width As Int 
	If TextHeight<0 Then 
		TextHeight=Abs(TextHeight)
		If Text.length>0 Then
			Width = BG.MeasureStringWidth(Text, LCAR.LCARfont,PToExtsize)+TextHeight
			LCAR.DrawRect(BG, X-Width/2,Y, Width, TextHeight, Colors.Black,0)
		End If
	End If
	BG.DrawText( Text, X,Y+TextHeight, LCAR.LCARfont,PToExtsize, Color, API.IIF(Center, "CENTER", "LEFT"))
End Sub
Sub DrawPToEText(BG As Canvas , X As Int, Y As Int, Text As String,TextHeight As Int, Center As Boolean )
	DrawPToEText2(BG,X,Y,Text,TextHeight,Center, Colors.Black)
End Sub
Sub PToEHandleMouse(X As Int, Y As Int, Action As Int)As Boolean 
	Dim WhiteSpace As Int,RowHeight As Int, Left As Int,Twidth As Int ,temp As Point , Shell As PToEShell,DidInit As Boolean 
	WhiteSpace=5:RowHeight=LCAR.ItemHeight+WhiteSpace:Twidth=RowHeight/3: Left = Twidth+LCAR.leftside + WhiteSpace
	DidInit=False
	If Action = LCAR.Event_Down Then
		PToECursor2 = Trig.SetPoint(X,Y)
		PToECursor3 = Trig.SetPoint(0,0)
		SelectedElement=GetPToEPoint(X,Y, WhiteSpace,RowHeight,Left,True)
		PToEScrolling=False
	Else If Action = LCAR.Event_Move Then
		PToECursor3.X  = PToECursor3.X+X
		PToECursor3.Y= PToECursor3.Y+Y
		temp=GetPToEPoint(PToECursor2.X+PToECursor3.X,PToECursor2.Y+PToECursor3.Y, WhiteSpace,RowHeight,Left,True)
		Return HandlePToEScrolling(SelectedElement, temp)
	Else If Action = LCAR.Event_Up And Not(PToEScrolling)  Then
		TheSelectedElement = Trig.SetPoint(SelectedElement.X,SelectedElement.Y)
		SelectedElementChange
		Return True
	Else If Action = LCAR.LCAR_Dpad Then
		Select Case X
			Case 0
				PToECursor.Y = Max(PToECursor.Y-1,0)'up
				TheSelectedElement.Y = Max(0, TheSelectedElement.Y-1)
			Case 1
				PToECursor.X = PToECursor.X+1'right
				TheSelectedElement.X = Min(17, TheSelectedElement.X+1)
			Case 2
				PToECursor.Y = PToECursor.Y+1'down
				TheSelectedElement.Y = Min(9, TheSelectedElement.Y+1)
			Case 3
				PToECursor.X = Max(0,PToECursor.X-1)'left
				TheSelectedElement.X = Max(0, TheSelectedElement.X-1)
			Case -1'center/X
				SelectedElementChange
		End Select
		Return True
	Else If Action = LCAR.LCAR_Timer Then
		If ElectronShells.IsInitialized Then 
			If PToECursor.Y <4 And PToECursor.X<7 Then
				DidInit =True
				For RowHeight = 0 To ElectronShells.Size -1
					Shell = ElectronShells.Get(RowHeight)
					Shell.Angle = (Shell.Angle + Shell.Speed) Mod 360
				Next
			End If
		End If
		If LCAR.RedAlert Then
			RowHeight=DateTime.GetSecond(DateTime.Now)
			If LastUpdate <> RowHeight Then
				LastUpdate=RowHeight
				Return True
			End If
		End If
	End If
	Return DidInit
End Sub
Sub SelectedElementChange
	Dim temp As Int , Line As PtoELine, Col As PToElement
	If TheSelectedElement.Y>-1 And TheSelectedElement.Y< Elements.Size Then
		Line = Elements.Get(TheSelectedElement.Y)
		For temp = 0 To Line.Cols.Size-1
			Col = Line.Cols.Get(temp) 
			If Col.X = TheSelectedElement.X Then
				ElementData = Col
				If ElementMode=0 Then
					LoadElectronShells(ElementData.ElectronsPerShell)				
				End If
				Exit
			End If
		Next
	End If
End Sub
Sub LoadElectronShells(ShellData As String)
	Dim tempstr() As String, temp As Int 
	ElectronShells.Initialize
	If ShellData.length>0 Then
		tempstr= Regex.Split(" ", ShellData)
		For temp =0 To tempstr.Length-1
			ElectronShells.Add( MakeShell(tempstr(temp), temp+1))
		Next
	End If
End Sub
Sub MakeShell(Electrons As Int, Shell As Int) As PToEShell 
	Dim temp As PToEShell 
	temp.Initialize 
	temp.Electrons = Electrons
	temp.Speed =Shell
	temp.Angle = Rnd(0,360)
	Return temp
End Sub

Sub HandlePToEScrolling(Before As Point, After As Point) As Boolean 
	If Before.X <> After.X Or Before.Y <> After.Y Then
		'Log(Before.X & " " & Before.Y & " BECAME: " & After.X & " " & After.Y & " moved into")
		PToEScrolling=True
		If Before.X< After.X And PToECursor.X>0 Then 
			PToECursor.X = PToECursor.X-1
		Else If Before.X> After.X Then
			PToECursor.X = PToECursor.X+1
		End If
		If Before.y< After.y And PToECursor.y>0 Then 
			PToECursor.y = PToECursor.y-1
		Else If Before.y> After.y Then
			PToECursor.y = PToECursor.y+1
		End If
		Return True
	End If
	Return False
End Sub
Sub GetPToEPoint(X As Int, Y As Int ,WhiteSpace As Int,RowHeight As Int, Left As Int, TakeStartIntoAccount As Boolean) As Point 
	Dim temp As Point 
	temp.Initialize 
	X=X-Left
	temp.X = Floor( X / (PToEColWidth+WhiteSpace) )
	Y=Y-LCAR.ItemHeight 
	temp.Y = Floor(Y/ RowHeight)
	If TakeStartIntoAccount Then
		temp.X = temp.X + PToECursor.X '+ 1
		temp.Y = temp.Y + PToECursor.Y - 1
		If PToECursor.Y=0 Then temp.Y=temp.Y-1
	End If
	Return temp
End Sub
Sub DrawPToESuperText(BG As Canvas , X As Int, Y As Int, Text As String,TextHeight As Int,TextSize As Int, Color As Int)
	Dim tempstr() As String ,temp As Int ,tempstr2 As String,tempstr3 As String  ,HalfSize As Int
	tempstr = Regex.split(" ", Text)
	HalfSize=TextSize/2
	For temp = 0 To tempstr.Length-1
		Text=tempstr(temp)
		tempstr3 = API.right(Text,1)
		If IsNumber(tempstr3) Then
			tempstr2=API.Left(Text, Text.length-1)
		Else
			tempstr3=""
			tempstr2=Text & " "
		End If
		'If TextSize = PToExtsize Then
		'	DrawPToEText(BG,X,Y, tempstr2, TextHeight, False)
		'Else
			BG.DrawText(tempstr2, X,Y+TextHeight, LCAR.LCARfont, TextSize, Color, "LEFT")
		'End If
		
		X=X+ BG.MeasureStringWidth(tempstr2, LCAR.LCARfont,TextSize)
		
		If tempstr3.Length>0 Then
			BG.DrawText(tempstr3, X,Y+TextHeight/2, LCAR.LCARfont,HalfSize, Color, "LEFT")
			X=X+BG.MeasureStringWidth(tempstr3, LCAR.LCARfont, HalfSize)
		End If
	Next
End Sub












Sub DrawPhotonicSonar(BG As Canvas, X As Int ,Y As Int, Radius As Int, ColorID As Int, Text As String )
	Dim Left As Int, Top As Int, Size As Int,temp As Int, temp2 As Int ,CurrentLine As SON_Line , LineHeight As Int,LinesNeeded As Int, Grad As GradientCache , handpath As ABPath 
	Left=X-Radius
	Top=Y-Radius
	Size=Radius*2
	Grad=LCARSeffects.Gradients.Get(  LCARSeffects.CacheGradient( API.IIF(LCAR.RedAlert, LCAR.LCAR_Red, ColorID), False))' Not(LCAR.RedAlert) ) )
	If InitRandomNumbers(LCAR.Legacy_Sonar, False ) Then
		AddRowOfNumbers(0, ColorID, Array As Int( 3,1,3,1,3,1  ))
		AddRowOfNumbers(0, ColorID, Array As Int( 3,1,3,1))
		AddRowOfNumbers(0, ColorID, Array As Int(-3,1,3,1))
	End If
	If Not(Sonar.IsInitialized)Then
		LCARSeffects.InitStarshipFont
		Sonar.Initialize 
		For temp= 1 To SonarLines
			Sonar.Add(MakeRandomSonarLine)
		Next
		LineHeight = SonarLines * 0.15 '1/8
		temp2= SonarLines * 0.5 -2
		'
		'/\ top
		'|| middle 1/4
		'\/ bottom
		'
		'middle
		For temp = temp2- LineHeight To temp2+ LineHeight
			CurrentLine= Sonar.Get(temp)
			MakeShapedSonarLine(CurrentLine, SonarWidth, 6,15)
		Next
		
		LinesNeeded=temp2+ LineHeight
		temp2=SonarWidth
		For temp = temp2-LineHeight-1 To 0 Step -1
			temp2=temp2-4
			LinesNeeded=LinesNeeded+1
			
			CurrentLine= Sonar.Get(temp)
			MakeShapedSonarLine(CurrentLine, temp2, 6,15)'top
			CurrentLine= Sonar.Get(LinesNeeded)
			MakeShapedSonarLine(CurrentLine, temp2, 6,15)'bottom
			
			If temp2<1 Then Exit
		Next
		
		SonarTextSize = API.GetTextHeight(BG, -Radius*0.75, Text, StarshipFont)
		SonarTextHeight = BG.MeasureStringHeight(Text, StarshipFont, SonarTextSize)
	End If
	
	LineHeight=(Size/SonarLines)'handpath As ABPath 
	handpath.addCircle(X, Y, Radius, handpath.Direction_CW)
	LCAR.ExDraw.clipPath2(BG, handpath)
	'Main.ExDraw.clipPath2(BG, handpath)'HARD CODED ROOT REFERENCE
	'BG.DrawCircle(X,y,Radius,Colors.Black, True,0)	
	LCAR.DrawRect(BG,X-Radius,Y,Size,Radius, Colors.Black, 0)
	
	Y=Top
	LinesNeeded= Ceil(Size/LineHeight)
	For temp= 0 To LinesNeeded-1'SonarLines-1
		CurrentLine = Sonar.Get(temp Mod SonarLines)
		DrawSonarLine(BG, CurrentLine, Left, Y,Size, LineHeight-1 , Grad, X)
		Y=Y+LineHeight
	Next
	
	Y=Top+ Size*0.80
	BG.DrawText(Text, X,Y,StarshipFont, SonarTextSize, Grad.Stages(15), "RIGHT")
	DrawRandomNumbers(BG, X,Y,StarshipFont, SonarTextSize, 0,0,0)
	'BG.DrawText("001 045 560", X, y, StarshipFont, 12, Grad.Stages(15), "CENTER")
	'BG.DrawText("003 112", X, y+14, StarshipFont, 12, Grad.Stages(15), "LEFT")
	'BG.DrawText("009 465 76", X, y+28, StarshipFont, 12, Grad.Stages(15), "LEFT")
	'BG.DrawText("24   314", X, y+42, StarshipFont, 12, Grad.Stages(15), "LEFT")
	
	BG.RemoveClip 
End Sub
Sub IncrementPhotonicSonar As Boolean 
	Dim CurrentLine As SON_Line ,temp As Int ,temp2 As Int 
	If Sonar.IsInitialized Then
		For temp= 0 To SonarLines-1
			CurrentLine = Sonar.Get(temp)
			For temp2 = 0 To 3
				IncrementSonarSliver(CurrentLine,0, temp2)
				IncrementSonarSliver(CurrentLine,1, temp2)
			Next
		Next
	End If
	IncrementNumbers
	Return True
End Sub
Sub IncrementSonarSliver(CurrentLine As SON_Line, LayerID As Int, Index As Int)
	Dim Sliver As SON_Point
	Sliver = CurrentLine.Layers(LayerID, Index)
	If Sliver.Width >0 Then
		Sliver.CurrentOffset  = LCAR.Increment(Sliver.CurrentOffset, 1, Sliver.DesiredOffset)
		If Sliver.CurrentOffset = Sliver.DesiredOffset Then RandomizeSliverOffset(Sliver,LayerID)'Sliver.DesiredOffset = Rnd(-Sliver.Width, Sliver.Width)
	End If
End Sub
Sub DrawSonarLine(BG As Canvas, CurrentLine As SON_Line, X As Int, Y As Int, Width As Int, Height As Int, Grad As GradientCache, CenterX As Int)
	Dim WidthRemaining As Int,temp As Int , Sliver As SON_Point,Size As Int 
	WidthRemaining=Width
	For temp = 0 To 3
		If WidthRemaining>0 Then
			Sliver = CurrentLine.Layers(0, temp)
			Size = DrawSonarSliver(BG, Sliver, X ,Y, Width,Height, False,Grad)
			WidthRemaining = WidthRemaining - Size
			X=X+Size
		End If
	Next
	If WidthRemaining > 0 Then LCAR.DrawRect(BG, X,Y,WidthRemaining+1,Height, Grad.Stages ( CurrentLine.LastShade),  0)
	
	
	Sliver = CurrentLine.Layers(1, 1)
	Size = DrawSonarSliver(BG, Sliver, CenterX, Y, Width, Height,True,Grad)

	Sliver = CurrentLine.Layers(1, 0)
	If Sliver.Width>0 Then
		DrawSonarSliver(BG, Sliver, CenterX-Size, Y, Width, Height,True,Grad)
		
		Sliver = CurrentLine.Layers(1, 2)
		Size = DrawSonarSliver(BG, Sliver, CenterX, Y, Width, Height,False,Grad)
		
		Sliver = CurrentLine.Layers(1, 3)
		DrawSonarSliver(BG, Sliver, CenterX+Size, Y, Width, Height,True,Grad)
	End If
	
End Sub
Sub DrawSonarSliver(BG As Canvas, Sliver As SON_Point, X As Int, Y As Int, Width As Int, Height As Int, GoLeft As Boolean, Grad As GradientCache) As Int 
	Dim Size As Int', Ret As Int 
	'If sliver.IsInitialized Then
		Size = ( (Sliver.Width + Sliver.CurrentOffset) * 0.01) * Width 
		If Size>0 Then
			If GoLeft Then  'X=X-Size
				LCAR.DrawRect(BG, X-Size,Y,Size+1,Height, Grad.Stages ( Sliver.Shade),  0)
			Else
				LCAR.DrawRect(BG, X,Y,Size+1,Height, Grad.Stages ( Sliver.Shade),  0)
			End If
		End If
	'End If
	Return Size'Ret''grad.Stages 
End Sub

Sub MakeShapedSonarLine(Line As SON_Line, Width As Int, Light As Int, Dark As Int)
	Line.Layers(1, 0) = MakeSliver(SliverAura,Light,False)
	Line.Layers(1, 1) = MakeSliver(Width/2,Dark,True)
	Line.Layers(1, 2) = MakeSliver(Width/2,Dark,True)
	Line.Layers(1, 3) = MakeSliver(SliverAura,Light,False)
End Sub
Sub MakeSliver(Width As Int, Shade As Int, Opaque As Boolean ) As SON_Point 
	Dim ret As SON_Point 
	ret.Initialize 
	ret.Width =Width
	'RandomizeSliverOffset(ret)
	ret.Shade =Shade
	ret.FullyOpaque =Opaque
	Return ret
End Sub

Sub MakeRandomSonarLine As SON_Line 
	Dim templine As SON_Line ,temp As Int , WidthRemaining As Int
	WidthRemaining=100
	templine.Initialize 
	If Rnd(0,4)=0 Then
		For temp = 0 To 3
			templine.Layers(1, temp).Initialize 
			templine.Layers(0, temp) = MakeForcedSliver(0)
		Next
		templine.Layers(0, 0) = MakeForcedSliver(100)
	Else
		For temp = 0 To 3
			templine.Layers(1, temp).Initialize 
			templine.Layers(0, temp) = MakeRandomSonarSliver(WidthRemaining)
			WidthRemaining= WidthRemaining-templine.Layers(0, temp).Width 
		Next
	End If
	templine.LastShade=Rnd(4,16)
	Return templine
End Sub
Sub MakeRandomSonarSliver(WidthRemaining As Int) As SON_Point 
	Dim ret As SON_Point
	ret.Initialize 
	If WidthRemaining>1 Then ret.Width = Rnd(1, WidthRemaining) Else ret.Width = WidthRemaining
	ret.Shade = Rnd(4,13)
	ret.FullyOpaque=True
	RandomizeSliverOffset(ret,0)
	Return ret
End Sub
Sub MakeForcedSliver(Width As Int) As SON_Point 
	Dim ret As SON_Point 
	ret = MakeRandomSonarSliver(Width)
	ret.Width = Width
	Return ret
End Sub
Sub RandomizeSliverOffset(Sliver As SON_Point, LayerID As Int )
	If Sliver.Width>0 And LayerID=0 Then 
		Sliver.DesiredOffset = Rnd(-Sliver.Width, Sliver.Width)
	Else If Sliver.Width = SliverAura Then
		Sliver.DesiredOffset = Rnd(1,SliverAura)
	Else
		Sliver.DesiredOffset = Rnd(1,MaxSonarOffset)
	End If
End Sub













Sub SetupAxis(ListID As Int)
	Dim temp As Int 
	If Not(IsSetup) Then
		'Axis.Initialize 
		IncDataPoints= 30
		RealMax=450
		IsSetup=True 
		temp = MakeSensor(temp, "MIC", "", ListID)'0
		
		temp = MakeSensor(temp, "ACC", "X", ListID)'1
		temp = MakeSensor(temp, "ACC", "Y", ListID)'2
		temp = MakeSensor(temp, "ACC", "Z", ListID)'3
		
		temp = MakeSensor(temp, "MAG", "X", ListID)'4
		temp = MakeSensor(temp, "MAG", "Y", ListID)'5
		temp = MakeSensor(temp, "MAG", "Z", ListID)'6

		temp = MakeSensor(temp, "ORI", "X", ListID)'7
		temp = MakeSensor(temp, "ORI", "Y", ListID)'8
		temp = MakeSensor(temp, "ORI", "Z", ListID)'9
		
		temp = MakeSensor(temp, "GYR", "X", ListID)'10
		temp = MakeSensor(temp, "GYR", "Y", ListID)'11
		temp = MakeSensor(temp, "GYR", "Z", ListID)'12
		
		temp = MakeSensor(temp, "LIT", "", ListID)'13
		temp = MakeSensor(temp, "PRS", "", ListID)'14
		temp = MakeSensor(temp, "TMP", "", ListID)'15
		temp = MakeSensor(temp, "PRX", "", ListID)'16

		temp = MakeSensor(temp, "BAT", "", ListID)'17	
		temp = MakeSensor(temp, "TMF", "", ListID)'18	
	End If
End Sub
Sub MakeMIR(ListID As Int, AprilFools As Boolean)
	If LCAR.LCAR_FindListItem(ListID, "MIR", 0, Not(AprilFools),-1) = -1 And AprilFools Then
		MakeSensor(19, "MIR", "", ListID)'19	
	End If
End Sub

Sub MakeSensor(Index As Int, SensorName As String, AxisName As String, ListID As Int)As Int 
	Dim temp As AxisPoint
	temp.Initialize 
	temp.GraphID=-1
	temp.Name = SensorName & API.IIF(AxisName.length>0, " " & AxisName, "")
	temp.minv = 32767
	LCAR.LCAR_AddListItem(ListID, SensorName, LCAR.LCAR_Random, Index, temp.Name, False,  AxisName ,0,False, -1)
	'temp.GraphID= AddGraph(IncDataPoints)	
	Axis(Index) = temp
	'Axis.Add(temp)
	Return Index+1
End Sub
Sub SetSensorData(AxisID As Int, Value As Int)
	'Dim temp As AxisPoint
	'temp = Axis.Get(AxisID)
	'temp.Value = Value
	Axis(AxisID).Value = Value
	Axis(AxisID).minv = Min(Axis(AxisID).minv, Value)
	Axis(AxisID).maxv = Max(Axis(AxisID).minv, Value)
End Sub
Sub ActivateAxis(AxisID As Int, ColorID As Int) As Int 
	Dim GraphID As Int
	If ColorID=-1 Then'deactivate 
		GraphID=FindGraph(Axis(AxisID).GraphID)
		If EnabledAxis>1 Then RemoveSmallestUnusedPoints'resync other graphs by removing the lowest amount of 0 data points from them all, pulling them all left to their first data point
		RemoveGraph(GraphID)'remove the graph
		Axis(AxisID).GraphID=-1'clear the ID pointer
		EnabledAxis=EnabledAxis-1'reduce enabled sensor count by one
		Return GraphID
	Else If Axis(AxisID).GraphID=-1 Then
		GraphID=AddPaddingPoints(AxisID,ColorID)
		EnabledAxis=EnabledAxis+1
		Return GraphID
	End If
End Sub
Sub SmallestUnusedPoints As Int
	Dim temp As Int, Smallest As Int ,UnusedTemp As Int,GraphID As Int
	Smallest=-1
	For temp = 0 To AxisCount-1
		If Axis(temp).GraphID>-1 Then
			GraphID=FindGraph(Axis(temp).GraphID)
			UnusedTemp = CountUnusedPoints(GraphID)
			If Smallest=-1 Or UnusedTemp<Smallest Then Smallest=UnusedTemp
		End If
	Next
	Return Smallest
End Sub
Sub RemoveSmallestUnusedPoints
	Dim temp As Int, Smallest As Int,GraphID As Int
	Smallest=SmallestUnusedPoints
	For temp = 0 To AxisCount-1
		If Axis(temp).GraphID>-1 Then
			GraphID=FindGraph(Axis(temp).GraphID)
			RemovePoints(GraphID,Smallest)
		End If
	Next
End Sub
Sub AddPaddingPoints(AxisID As Int, ColorID As Int)As Int
	Dim temp As Int,GraphID As Int', PaddingNeeded As Int
	'find how much data is needed to sync the new graph with the existing ones
	temp=PaddingNeeded
	GraphID=UnusedGraphID
	'add the new graph and padding
	Axis(AxisID).GraphID=GraphID
	Axis(AxisID).Color=LCAR.GetColor( ColorID, False, 255)
	AddGraph(GraphID, IncDataPoints, True)
	AddBlankPoints(GraphID, temp)
	Return GraphID
End Sub
Sub FindAxis(Name As String) As Int
	Dim temp As  Int 
	For temp = 0 To AxisCount-1
		'Try
			If Axis(temp).Name.EqualsIgnoreCase(Name) Then Return temp
		'Catch
		'	Return -1
		'End Try
	Next
	Return -1
End Sub
Sub PaddingNeeded As Int 
	Dim temp As Int,GraphID As Int
	If EnabledAxis>0 Then 
		For temp = 0 To AxisCount-1
			If Axis(temp).GraphID>-1 Then
				GraphID=FindGraph(Axis(temp).GraphID)
				Return GetGraph(GraphID).Points.Size 
			End If
		Next
	End If
End Sub
Sub AssimilateNewData(HandleTime As Boolean ) As Boolean 
	Dim temp As Int,GraphID As Int, Ret As Boolean 
	If HandleTime Then
		temp= Floor( (DateTime.Now Mod 1000) / 250)
		If LastUpdate =temp Then
			Return False
		Else
			LastUpdate=temp
		End If
	End If
	If EnabledAxis>0 Then 
		For temp = 0 To AxisCount-1
			If Axis(temp).GraphID>-1 Then
				GraphID=FindGraph(Axis(temp).GraphID)
				AddPoint(GraphID, Axis(temp).Value )
				Ret=True
			End If
		Next
	End If
	Return Ret
End Sub
Sub DrawAllGraphs(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BorderColorID As Int, Alpha As Int, Text As String )
	Dim temp As Int,GraphID As Int, Points As Int, temp2 As Int 
	LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black, 0)
	If EnabledAxis>0 Then 
		For temp = 0 To AxisCount-1
			If Axis(temp).GraphID>-1 Then
				GraphID=FindGraph(Axis(temp).GraphID)
				DrawGraph(GraphID, BG,X,Y,Width,Height, Colors.Black, Axis(temp).Color, Alpha, -1, 0,0)
				temp2=GetGraph(GraphID).Points.Size
				If temp2> Points Then Points=temp2
			End If
		Next
		'DrawCursor(BG,X,Y,Width,Height, Colors.White, PointWidth,2, tempGraph.MaxPoints *0.2,tempGraph.CurrentPoint)
		CurrCols= 0' Ceil(Points/IncDataPoints)
		DrawBox(BG,X,Y,Width,Height, LCAR.GetColor(BorderColorID, False,Alpha), CurrCols,4,2,1)
		
		If Points>RealMax Then 'ClearAllGraphs
			For temp = 0 To AxisCount-1
				If Axis(temp).GraphID>-1 Then
					GraphID=FindGraph(Axis(temp).GraphID)
					'ClearGraph(GraphID)
					RemovePoints(GraphID,4)
				End If
			Next
		End If
	Else
		LCAR.DrawTextbox(BG, Text, BorderColorID, X,Y,Width,Height,5)
	End If
End Sub










Sub DrawRuler(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, Whitespace As Int, Direction As Int, Cells As Int)
	Dim CellWidth As Int ,temp As Int 
	If Cells=-1 Then Cells = Max(1, CurrCols)
	Width=Width+2
	Whitespace=Max(1,Whitespace)
	If Direction<0 Then'down
		LCAR.DrawRect(BG, X, Y+Height, Width, Abs(Direction),  Colors.black,0)
	Else'up
		LCAR.DrawRect(BG, X, Y-Direction, Width, Direction, Colors.black,0)
	End If
	LCAR.DrawRect(BG,X,Y,Width,Height,Color,0)
	If Direction<>0 Then
		CellWidth=(Width/Cells)-Whitespace-Stroke
		For temp = 1 To Cells
			X=X+CellWidth
			If Direction<0 Then'down
				LCAR.DrawRect(BG, X, Y+Height-1, Stroke, Abs(Direction), Color,0)
			Else'up
				LCAR.DrawRect(BG, X, Y-Direction+1, Stroke, Direction, Color,0)
			End If
			X=X+Whitespace+Stroke
			LCAR.DrawRect(BG, X-Whitespace-1,Y,Whitespace,Height,Colors.Black,0)
		Next
	End If
End Sub










Sub SetKlingonFont
	If Not(KlingonFont.IsInitialized ) Then KlingonFont = Typeface.LoadFromAssets("klingon.ttf")
End Sub

Sub SetColors()
	ColorsSet= True
	If LCAR.RedAlert Then
		LE_BlueR =204
		LE_BlueG=102
		LE_BlueB=102
		
		LE_TextR = 255
		LE_TextG = 255
		LE_TextB = 255
		
		LE_Turquoise255 = Colors.aRGB(255, 255,155,155)
		
		ColorWhite=Colors.White 
		ColorGrey=Colors.red 
	Else
		LE_BlueR =11
		LE_BlueG=23
		LE_BlueB=151
		
		LE_TextR = 60
		LE_TextG = 130
		LE_TextB = 95
		
		LE_Turquoise255 = Colors.aRGB(255, 125,250,244)
		
		ColorWhite=Colors.White 
		ColorGrey=Colors.Gray 
	End If
	ColorsSet=False
	LE_Blue = Colors.ARGB(255,LE_BlueR,LE_BlueG,LE_BlueB)
	LE_Turquoise000 = Colors.ARGB(16,LE_BlueR,LE_BlueG,LE_BlueB)'Colors.aRGB(0, 125,250,244)'LE_Blue'Colors.Black '
End Sub

Sub DrawText(BG As Canvas, X As Int, Y As Int, Text As LE_String)
	If Not (Text.IsInitialized) Then Text = RandomString(0)
	If Text.Frames=0 Then DrawSliver(BG, X+ Text.X,  Y+ Text.Y,    BG.MeasureStringHeight("ABC", Typeface.DEFAULT, Text.TextSize ),        Text.Alpha , Text.TextSize, Text )
End Sub

Sub DrawSliver(BG As Canvas, X As Int, Y As Int, Space As Int, Alpha As Float,TextSize As Int, Text As LE_String   )
	Dim temp As Int ', Alpha2 As Int 
	If Text.Alphas.IsInitialized Then
		For temp =0 To Text.Alphas.Size-1
			'If LE_GradAlpha Then
			'	Alpha2= Text.Alphas.Get(temp)*Alpha
			'Else
			'	Alpha2= Text.Alphas.Get(temp)
			'End If
			DrawLetter(BG, X, Y, API.mid( Text.Text ,temp,1), Text.Alphas.Get(temp)*Alpha, TextSize )
			Y=Y+Space
		Next
	End If
End Sub
Sub DrawLetter(BG As Canvas, X As Int, Y As Int, Letter As String, Alpha As Int, TextSize As Int )
	Dim Color As Int
	If LE_GradAlpha Then
		Color= Colors.ARGB(Alpha,LE_TextR,LE_TextG,LE_TextB)
	Else
		Color= GetColor(Alpha)
	End If
	BG.DrawText(Letter, X, Y,  Typeface.DEFAULT_BOLD , TextSize, Color, "CENTER")
End Sub
Sub GetColor(Alpha As Int) As Int
	Dim temp As Int
	If Not(ColorsSet) Then
		For temp = 0 To 16
			aColors(temp) = Colors.ARGB(Min(255,temp*16),LE_TextR,LE_TextG,LE_TextB)
		Next
		ColorsSet=True
	End If
	Return aColors(Alpha)
End Sub
Sub IncrementText(Text As LE_String)As LE_String 
	Dim dorandom As Boolean 
	If Text.Frames>0 Then
		Text.Frames = Text.Frames -1
	Else
		If LE_GradAlpha Then
			Text.Alpha = Text.Alpha- 0.025
			If Text.Alpha<=0 Then dorandom=True
		End If
		If Not(dorandom) Then 
			Text.X = Text.X + Text.SpeedX 
			If Text.X <0 Or Text.X> LE_Width Then dorandom=True
		End If
		If Not(dorandom) Then 
			Text.Y = Text.Y + Text.SpeedY 
			If Text.Y>= LE_Height Then dorandom=True
		End If
		If Not(dorandom) Then Text.TextSize= Text.TextSize+1
		If dorandom Then  Text=RandomString(0)
	End If
	Return Text
End Sub


Sub RandomString(Frames As Int) As LE_String 
	Dim tempstr As StringBuilder, temp As Int , temple As LE_String 
	tempstr.Initialize
	temple.Initialize 
	temple.Frames = Frames
	temple.X=Rnd(LE_Width*0.25, LE_Width*0.75)
	If temple.X < LE_Width/2 Then
		temple.SpeedX =Rnd(-10,-6)
	Else
		temple.SpeedX =Rnd(5,11)
	End If
	temple.TextSize=Rnd(8,32)
	temple.Y=Rnd(-LE_Border, LE_Border)
	temple.Alpha = 1
	temple.Speedy =Rnd(5,11)
	
	temple.Alphas.Initialize 
	For temp = 1 To LE_StringLength
		tempstr.Append(RandomChar)
		If LE_GradAlpha Then
			temple.Alphas.Add( Rnd(0,256))
		Else
			temple.Alphas.Add( Rnd(0,17))
		End If
	Next
	temple.Text=tempstr.ToString 
	Return temple
End Sub

Sub RandomChar As String 
	Dim tempstr As String 
	tempstr = Chr( Rnd(0,128) )
	Return tempstr.ToUpperCase
End Sub

Sub LE_IncrementMatrix
	Dim temp As Int
	If LE_Changed Then
		'make random strings
		For temp = 0 To LE_MaxStrings-1
			LE_Strings(temp) = RandomString(temp*10)
		Next
		
		'make random lines
		For temp = 0 To LE_MaxLines-1
			LE_Lines(temp) = RandomLine(False)
		Next
		
		'make random angled lines
		For temp = LE_MaxLines To LE_MaxLines+LE_MaxAngleLines-1
			LE_Lines(temp) = RandomLine(True)
		Next
		
		'make random bottom/stationary lines
		For temp=0 To LE_MaxStatLines-1
			LE_StatLines(temp) = RandomStatLine
		Next
		
		LE_Initd= True
		LE_Changed=False
	Else If LE_Initd Then
		For temp = 0 To LE_MaxLines+LE_MaxAngleLines-1
			LE_Lines(temp) = IncrementLine( LE_Lines(temp) )
		Next
		
		For temp=0 To LE_MaxStatLines-1
			LE_StatLines(temp) = LE_StatLines(temp)-16
			If LE_StatLines(temp)<=0 Then LE_StatLines(temp) = RandomStatLine
		Next

		For temp = 0 To LE_MaxStrings-1
			LE_Strings(temp)=IncrementText(LE_Strings(temp))
		Next
	End If
End Sub

Sub IncrementLine(Line As LE_Line) As LE_Line 
	Dim X As Int, Y As Int , DoRandom As Boolean ,Angular As Boolean 
	Select Case Line.Angle 
		Case 0'going up
			Line.Y = Line.Y - Line.Speed 
			If Line.Y < -Line.Length Then DoRandom=True
		Case 90'going east
			Line.X=Line.X+Line.Speed 
			If Line.X> Line.Length+ LE_Width Then DoRandom=True
		Case 180'going south
			Line.Y=Line.Y+Line.Speed 
			If Line.Y> Line.Length+ LE_Height Then DoRandom=True
		Case 270'going west
			Line.X=Line.X-Line.Speed 
			If Line.X < -Line.Length Then DoRandom=True
		Case Else'by angle
			
			'Return Line
			Angular=True
			'Angle= Trig.GetCorrectAngle(LE_Outside.CenterX,LE_Outside.CenterY, Line.X,Line.Y)
			'If Not(Line.GoingIn) Then Angle= Trig.CorrectAngle(Line.Angle+180)
			X= Trig.findXYAngle(0,0,Line.Speed,Line.Angle,True)
			Y= Trig.findXYAngle(0,0,Line.Speed,Line.Angle,False)
			Line.X=Line.X+X
			Line.Y=Line.Y+Y
			
			'temp= Trig.CorrectAngle( Line.Angle-180)
			'X= Trig.findXY(Line.X,Line.Y,Line.length, temp,True)
			'Y= Trig.findXY(Line.X,Line.Y,Line.length, temp,False)
			'If Line.GoingIn Then
			'	DoRandom=True
			'Else
			'	If X<0 OR X> LE_Width OR Y<0 OR Y> LE_Height Then DoRandom=True
			'End If

	End Select
	If DoRandom Then
		Return RandomLine(Angular)
	Else
		Return Line
	End If
End Sub

Sub MakePath(BG As Canvas, PathType As Int, Mode As Boolean )
	Dim P As Path,Border As Int 'If mode = false then it's a bloom.
	If Not(Mode) Then Border=LE_BloomThickness
	If LE_LastPath<> PathType Then
		If LE_LastPath > -2 Then BG.RemoveClip  
		Select Case PathType
			Case -1						'entire screen
				P.Initialize(LE_Outside.Left,LE_Outside.Top)'top left
				P.LineTo(LE_Outside.Right,LE_Outside.Top)'top right
				P.LineTo(LE_Outside.Right,LE_Outside.Bottom )'bottom right
				P.LineTo(LE_Outside.Left,LE_Outside.Bottom)'bottom left
			Case 0'north going south	top quadrant
				P.Initialize(LE_Outside.Left,LE_Outside.Top)'top left
				P.LineTo(LE_Outside.Right,LE_Outside.Top)'top right
				P.LineTo(LE_Outside.Right,LE_Inside.Top+Border)'bottom right
				P.LineTo(LE_Outside.Left,LE_Inside.Top+Border)'bottom left
			Case 1'east going west		right quadrant
				P.Initialize(LE_Inside.Right-Border , LE_Outside.Top)'top left
				P.LineTo(LE_Outside.Right,LE_Outside.Top)'top right
				P.LineTo(LE_Outside.Right,LE_Outside.Bottom )'bottom right
				P.LineTo(LE_Inside.Right-Border , LE_Outside.Bottom)'bottom left
			Case 2'south going north	bottom quadrant
				P.Initialize(LE_Outside.Left, LE_Inside.Bottom-Border )'top left
				P.LineTo(LE_Outside.Right, LE_Inside.Bottom-Border)'top right
				P.LineTo(LE_Outside.Right,LE_Outside.Bottom )'bottom right
				P.LineTo(LE_Outside.Left,LE_Outside.Bottom)'bottom left
			Case 3'west going east		left quadrant
				P.Initialize(LE_Outside.Left,LE_Outside.Top)'top left
				P.LineTo(LE_Inside.Left+Border,LE_Outside.Top)'top right
				P.LineTo(LE_Inside.Left+Border,LE_Outside.bottom )'bottom right
				P.LineTo(LE_Outside.Left,LE_Outside.Bottom)'bottom left
		End Select
		BG.ClipPath(P)
		LE_LastPath=PathType
	End If
End Sub

Sub LE_SeedText(Text As String)
	LE_Strings(Rnd(0, LE_MaxStrings)).Text = Text
End Sub

Sub LE_DrawMatrix(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int , Y2 As Int
	If Not(ColorsSet) Then SetColors
	Width=Width+2
	Height=Height+2
	If LE_Width<> Width Or LE_Height <> Height Then
		LE_Width=Width
		LE_Height=Height
		LE_Changed = True
		
		temp= Min(LE_Width,LE_Height)
		LE_Border=temp*0.2
		LE_MaxLength=temp/2
		LE_MinLength=LE_MaxLength/2
	End If
	
	'clear screen
	LE_Inside=LCAR.SetRect(X+LE_Border,Y+LE_Border,Width-LE_Border*2,Height-LE_Border*2) 
	LE_Outside=LCAR.SetRect(X,Y,Width,Height)
	
	BG.DrawRect(LE_Outside, Colors.Black, True,0)
	
	LE_LastPath=-2
	MakePath(BG, -1,True)
	
	'draw falling text
	For temp = 0 To LE_MaxStrings-1
		DrawText(BG, X, Y, LE_Strings(temp) ) 
	Next
	
	'draw horizontal lines at the bottom
	Y2= Y + Height - 50
	For temp = 0 To LE_MaxStatLines-1
		DrawStatLine(BG, X,Y2,Width, LE_StatLineHeight , LE_StatLines(temp) )
		Y2=Y2-LE_StatLineHeight-1
	Next	
	
	'BG.RemoveClip
	'MakePath(BG, True)

	'draw bloom
	For temp = 0 To LE_MaxLines+LE_MaxAngleLines-1
		LE_Lines(temp)= DrawLine( BG,X,Y, LE_Lines(temp), False )
	Next

	'draw random direction lines
	For temp = 0 To LE_MaxLines+LE_MaxAngleLines-1
		DrawLine( BG,X,Y, LE_Lines(temp), True )
	Next	
	
	BG.RemoveClip
End Sub

Sub DrawStatLine(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int)
	Dim Color As Int 
	Color = Colors.ARGB(Alpha,LE_TextR,LE_TextG,LE_TextB)
	BG.DrawRect( LCAR.SetRect(X,Y,Width,Height), Color,True,0)
End Sub


Sub DrawLine(BG As Canvas,X As Int, Y As Int, Line As LE_Line, Mode As Boolean ) As LE_Line
	Dim PathType As Int 
	Select Case Line.Angle 
		Case 0,90,180,270
			PathType=-1
		Case Else
			PathType=Line.PathType 
	End Select
	MakePath(BG, PathType, Mode )
	
	If Mode Then
		
		Select Case Line.Angle 
			Case 0'south going north
				LCAR.DrawGradient(BG, LE_Turquoise255, LE_Turquoise000, 8, X+ Line.X-Line.Thickness,Y+ Line.Y, Line.Thickness*2, Line.Length, Line.Thickness, 0)
			Case 90'west going east
				LCAR.DrawGradient(BG, LE_Turquoise255, LE_Turquoise000, 4,X+ Line.X-Line.Length,Y+ Line.Y-Line.Thickness,Line.Length,Line.Thickness*2, Line.Thickness, 0)
			Case 180'north going south
				LCAR.DrawGradient(BG,  LE_Turquoise255,LE_Turquoise000, 2,X+ Line.X-Line.Thickness,Y+ Line.Y-Line.Length, Line.Thickness*2, Line.Length, Line.Thickness, 0)
			Case 270'east going west
				LCAR.DrawGradient(BG, LE_Turquoise255, LE_Turquoise000, 6, X+Line.X,Y+ Line.Y-Line.Thickness,Line.Length,Line.Thickness*2, Line.Thickness, 0)
			Case Else'angular
				LCAR.DrawGradient(BG, LE_Turquoise255, LE_Turquoise000, 8, X+ Line.X,Y+ Line.Y, Line.Thickness*2, Line.Length, Line.Thickness, Line.Angle )
		End Select
	Else
		Select Case Line.Angle 
			Case 0'south going north
				'LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 8, X+ Line.X-LE_BloomThickness,Y+ Line.Y-LE_BloomThickness, LE_BloomThickness*2, Line.Length+LE_BloomThickness*2,LE_BloomThickness, 0)
				DrawBloomH(BG, X+ Line.X, Y+ Line.Y, Line.Length, False, 0,False)
			Case 90'west going east
				'LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 6, X+Line.X-LE_BloomThickness-Line.Length,Y+ Line.Y-LE_BloomThickness,Line.Length+LE_BloomThickness*2,LE_BloomThickness*2, LE_BloomThickness, 0)
				DrawBloomH(BG, X+Line.X-Line.Length,Y+Line.Y, Line.Length,True,0,False)
			Case 180'north going south
				'LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 8, X+ Line.X-LE_BloomThickness,Y+ Line.Y-LE_BloomThickness-Line.Length, LE_BloomThickness*2, Line.Length+LE_BloomThickness*2,LE_BloomThickness, 0)
				DrawBloomH(BG, X+Line.X,Y+Line.Y-Line.Length, Line.Length,False,0,False)
			Case 270'east going west
				'LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 6, X+Line.X-LE_BloomThickness,Y+ Line.Y-LE_BloomThickness,Line.Length+LE_BloomThickness*2,LE_BloomThickness*2, LE_BloomThickness, 0)
				DrawBloomH(BG, X+Line.X, Y+Line.Y, Line.Length,True,0,False)
			Case Else'angular
				If DrawBloomH(BG, X+Line.X, Y+Line.Y+Line.Length*0.5, Line.Length,False,Line.Angle, Line.GoingIn ) Then
					Line=RandomLine(True)
				End If
	
		End Select
		Return Line
	End If
	
End Sub

Sub IsWithin(X As Int, Y As Int, RCT As Rect) As Boolean 
	If X >= RCT.Left Then
		If X <= RCT.Right Then
			If Y >= RCT.Top Then
				If Y <= RCT.Bottom 	Then
					Return True
				End If
			End If
		End If
	End If
End Sub
Sub IsInside(X As Int, Y As Int,X2 As Int, Y2 As Int, GoingIn As Boolean ) As Boolean 
	Dim temp As Boolean 
	If GoingIn Then
		temp=  IsWithin(X2,Y2, LE_Inside)
		If Not(temp) Then
			If Not( IsWithin(X,Y, LE_Outside)) Then temp = True
		End If
	Else
		temp= Not( IsWithin(X2,Y2, LE_Outside))
	End If
	Return temp
	'If IsWithin(X,Y, LE_Outside) Then Return Not (IsWithin(X,Y, LE_Inside))
End Sub

Sub DrawBloomH(BG As Canvas, X As Int, Y As Int, Length As Int, Hor As Boolean,Angle As Int, GoingIn As Boolean   )As Boolean 
	Dim temp As Int, LE_Blue2 As Int, X2 As Int, Y2 As Int, X3 As Int, Y3 As Int, Speed As Boolean , Inc As Int, temp2 As Float,temp3 As Float ,X4 As Int, Y4 As Int,ISIN As Boolean 
	If Not(Hor) And Angle > 0 And Not( GoingIn) Then Angle= Trig.CorrectAngle( Angle+180)
	Speed=True
	If LCAR.AntiAliasing Then
		LE_Blue2 = Colors.ARGB(16*Inc,LE_BlueR,LE_BlueG,LE_BlueB)
		If Speed Then
			Inc=2
			LE_Blue2 = Colors.ARGB(16*Inc,LE_BlueR,LE_BlueG,LE_BlueB)
		
			If Hor Then
				X2=X+Length
				Y2=Y
				For temp = 1 To LE_BloomThickness  Step Inc
					BG.DrawLine(X-temp,Y, X2+temp*2,Y2,LE_Blue2,temp*2)
				Next
			Else If Angle = 0 Then
				X2=X
				Y2=Y+Length
				For temp = 1 To LE_BloomThickness  Step Inc
					BG.DrawLine(X,Y-temp, X2,Y2+temp*2,LE_Blue2,temp*2)
				Next
			Else
				X3=Trig.findXYAngle(0,0, Length*0.5, Angle, True)
				Y3=Trig.findXYAngle(0,0, Length*0.5, Angle, False)
			
				X2=X+X3'Trig.findXYAngle(X,Y, Length, Angle, True)
				Y2=Y+Y3'Trig.findXYAngle(X,Y, Length, Angle, False)
				X=X-X3
				Y=Y-Y3
				
				X3=Trig.findXYAngle(0,0, LE_BloomThickness, Angle, True)
				Y3=Trig.findXYAngle(0,0, LE_BloomThickness, Angle, False)
				temp2=1/LE_BloomThickness
				temp3=temp2
				
				For temp = 1 To LE_BloomThickness  Step Inc
					X4=X3*temp3
					Y4=Y3*temp3
					BG.DrawLine(X-X4,Y-Y4, X2+X4*2,Y2+Y4*2,LE_Blue2,temp*2)
					temp3=temp3+ (temp2*Inc)
				Next
				
				ISIN =IsInside(X,Y,X2,Y2,GoingIn)
				Return ISIN
			End If
			
		Else
			Inc=4
			If Hor Then
				For temp = 1 To LE_BloomThickness  Step Inc
					LCAR.DrawGradient(BG, LE_Blue2, LE_Blue2, 6, X-temp,Y-temp,Length+temp*2,temp*2, temp, 0)
				Next
			Else If Angle=0 Then
				For temp = 1 To LE_BloomThickness  Step Inc
					LCAR.DrawGradient(BG, LE_Blue2, LE_Blue2, 8, X-temp,Y-temp, temp*2, Length+temp*2,temp, 0)
				Next
			Else
				For temp = 1 To LE_BloomThickness  Step Inc
					LCAR.DrawGradient(BG, LE_Blue2, LE_Blue2, 8, X-temp,Y-temp-Length*0.5, temp*2, Length+temp*2,temp, Angle)
				Next
				ISIN= IsInside(X,Y, Trig.findXYAngle(X,Y, Length, Angle, True),Trig.findXYAngle(X,Y, Length, Angle, False),GoingIn)
				Return ISIN
			End If
		End If
	Else
		If Hor Then
			LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 6, X-LE_BloomThickness,Y-LE_BloomThickness,Length+LE_BloomThickness*2,LE_BloomThickness*2, LE_BloomThickness, 0)
		Else If Angle = 0 Then
			LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 8, X-LE_BloomThickness,Y-LE_BloomThickness, LE_BloomThickness*2, Length+LE_BloomThickness*2,LE_BloomThickness, 0)
		Else
			LCAR.DrawGradient(BG, LE_Blue, LE_Blue, 8, X-LE_BloomThickness,Y-LE_BloomThickness-Length*0.5, LE_BloomThickness*2, Length+LE_BloomThickness*2,LE_BloomThickness, Angle)
			ISIN= IsInside(X,Y, Trig.findXYAngle(X,Y, Length, Angle, True),Trig.findXYAngle(X,Y, Length, Angle, False),GoingIn)
			Return ISIN
		End If
	End If
End Sub

Sub RandomStatLine As Int
	Return Rnd(0,16)*16
End Sub
Sub RandomLine(isAngular As Boolean) As LE_Line 
	Dim temp As LE_Line , Border As Int,temp2 As Int ,temp3 As Int
	temp.Initialize 
	temp.Thickness = Rnd(1,4)
	temp.Speed =Rnd(5,15)
	temp.Length = Rnd(LE_MinLength,LE_MaxLength)
	
	temp2=Rnd(0,4)'side
	temp.PathType=temp2
	If isAngular Then'(angular only)
		temp3=Rnd(0,2)'direction 
		temp.Length=temp.Length*0.5
		If temp3=0 Then'coming out from center
			Border=LE_IntBorder
		Else'going in towards the center
			Border=LE_Border
		End If
	End If
	
	Select Case temp2
		Case 0'north going south
			temp.Angle= 180
			temp.X=Rnd(Border, LE_Width-Border)
			temp.Y=Border
		Case 1'east going west
			temp.Angle=270 
			temp.X=LE_Width-Border
			temp.Y= Rnd(Border, LE_Height-Border)
		Case 2'south going north
			'temp.Angle=0
			temp.X=Rnd(Border, LE_Width-Border)
			temp.Y= LE_Height-Border
		Case 3'west going east
			temp.Angle=90
			temp.X=Border
			temp.y=Rnd(Border, LE_Height-Border)
	End Select
	
	If isAngular Then
		temp.Angle = Trig.GetCorrectAngle(LE_Width*0.5, LE_Height*0.5, temp.X, temp.Y)
		Do While IsInvalidAngle(temp.angle)
			temp = RandomLine(True)
		Loop
		temp.GoingIn=True
		If temp3=0 Then
			temp.GoingIn=False
			temp.Angle = Trig.CorrectAngle( temp.Angle -180 )
		End If
	End If
	
	Return temp
End Sub

Sub IsInvalidAngle(Angle As Int) As Boolean 
	If Angle < 5 Or (Angle>85 And Angle<95) Or (Angle>175 And Angle<185) Or (Angle>265 And Angle<275) Or Angle>355 Then Return True
End Sub



















Sub DrawClock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int,NeedsStarbase As Boolean )
	Dim Radius As Int, StarDate As String,CenterX As Int ,CenterY As Int, FontSize As Int, FontHeight As Int, temp As Int'"STARDATE: " & 
	
	If InitRandomNumbers(LCAR.LCAR_StarBase, False ) Then
		'Small block within the starbase
		AddRowOfNumbers(0, LCAR.LCAR_White, Array As Int(-2,-1,1,-1))
		AddRowOfNumbers(0, LCAR.LCAR_White, Array As Int(-2,-1,1,-1))
		AddRowOfNumbers(0, LCAR.LCAR_White, Array As Int(-2,-1,1,-1))
		
		'Red block of 1, blue of 2
		AddRowOfNumbers(1, LCAR.LCAR_Red, Array As Int(4,1))
		AddRowOfNumbers(2, LCAR.Classic_Blue, Array As Int(2,1, 9,1))
		AddRowOfNumbers(2, LCAR.Classic_Blue, Array As Int(2,1, 7,1))
		
		'blue block of 2
		AddRowOfNumbers(3, LCAR.Classic_Blue, Array As Int(2,1, 4,-1))
		AddRowOfNumbers(3, LCAR.Classic_Blue, Array As Int(2,1, 4,-1))
		
		'blue block of 1, 3 red blocks of 3
		AddRowOfNumbers(4, LCAR.Classic_Blue, Array As Int(4,1))
		SetColRowColorID(AddRowOfNumbers(5, LCAR.Classic_Blue, Array As Int(3,-1, 4,-1, -4,-1)),  0, LCAR.LCAR_Red )
		DuplicateFirstLines(5,2)
		For temp = 1 To 7
			AddRowOfNumbers(5, LCAR.Classic_Blue, Array As Int(-3,-1, -4,-1))
		Next		
	End If
	
	Radius=Min(Width,Height)/2
	CenterY=Y+ Height/2
	CenterX= X + Width/2
	DrawStarbase(BG,CenterX, CenterY, Radius,NeedsStarbase )
	PortraitMode=Height>Width
	If PortraitMode Then
		DrawBlock(BG, CenterX, CenterY-Radius, Radius, 40, True)
		DrawRandomNumbers(BG, X,CenterY+Radius, StarshipFont, 10, 0,0,-3)
	Else If Not(HelpMode) Then
		StarDate=LCAR.StarDate(LCAR.Stardatemode, DateTime.Now, False, 4)
		FontSize= API.IIF(LCAR.SmallScreen, 10,15)
		FontHeight = LCAR.LegacyTextHeight(BG, FontSize)
		temp=API.IIF(LCAR.SmallScreen, 25,45)
		Y=Y+ temp
		LCAR.DrawLegacyText(BG,X, Y+FontHeight, 0,0, API.GetString("stardate") &  ": ", FontSize, Colors.White ,0 )
		LCAR.DrawLegacyText(BG,X, Y+FontHeight*2, 0,0, StarDate, FontSize, Colors.White ,0 )
		DrawBlock(BG, CenterX+Radius, CenterY, Width, CenterY- LCAR.ItemHeight-10 ,False)'Radius-temp-10
	End If
End Sub
Sub DrawBlock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Top As Boolean)
	Dim Blue As Int , H2 As Int
	If Top Then
		Y=Y-Height
		LCAR.DrawRect(BG,X-1,Y, 4,Height, Colors.Red, 0)
		X=X-Width
		LCAR.DrawRect(BG,X, Y, Width, 4, Colors.Red,0)
		
		Y=Y+ DrawRandomNumbers(BG,X,Y, StarshipFont,12, 0,0,-1)
		DrawRandomNumbers(BG, X,Y, StarshipFont,10, 0,0,-2)
	Else
		Width = Width-X
		LCAR.DrawRect(BG,X,Y,Width,Height-5,Colors.Black,0)
		
		Blue=LCAR.GetColor(LCAR.Classic_Blue ,False,255)
		H2= LCAR.LegacyTextHeight(BG, 15) *0.5' 7
		H2= LCAR.DrawLegacyText(BG,X+2,Y-H2, 30,0, "15", 15, Blue, 0)+2
		X=X+H2
		Width=Width-H2
		H2=LCAR.LegacyTextHeight(BG, 12)'*0.5'15
		LCAR.DrawRect(BG,X, Y-2, Width, 4,  Blue, 0)
		LCAR.DrawRect(BG,X-H2,Y+H2,Width,4, Blue,0)
		BG.DrawLine(X+Width,Y, X+Width-H2-2,Y+H2+2, Blue, 4)
		
		DrawRandomNumbers(BG, X,Y+H2*0.5, StarshipFont,12, 0,0,-4)
		Height=Height-H2
		LCAR.DrawRect(BG,X-H2,Y+H2,4,Height, Blue,0)
		LCAR.DrawRect(BG,X-H2-3,Y+H2+Height*0.5,4,Height*0.5, Blue,0)
		
		Y=Y+H2*2
		DrawRandomNumbers(BG,X-5, Y, StarshipFont, 10, 0,0,-5)
	End If
End Sub

Sub FortyFive(Pixels As Int) As Int
	If d45= 0 Then	d45 = Trig.findXYAngle(0,0,100,45,True)
	Return Pixels/100 * d45
End Sub

Sub DrawStarbase(BG As Canvas, X As Int, Y As Int, Radius As Int ,NeedsDrawing As Boolean )
	Dim ThickLine As Int ,ThickSpace As Int, ThinLine As Int ,temp As Int,SquareLength As Int, SquareWidth As Int ,R2 As Int ,P As Path ,temp2 As Int,WasForced As Boolean  
	If Not(ColorsSet) Then SetColors
	SquareLength=BorderThickness* 0.66666666666666666666666666
	SquareWidth=40
	ThickLine=6
	ThinLine=ThickLine*0.5
	ThickSpace=ThickLine*2
	R2=Radius*2
	If ForceRedraw Then
		WasForced=True
		NeedsDrawing=True
	End If
	If NeedsDrawing Then 
		'BG.DrawRect( LCAR.SetRect(X-Radius, Y-Radius, R2,R2+1), Colors.Black, True,0)
		BG.DrawCircle(X,Y,Radius,Colors.Black, True,0)
		
		LCARSeffects.CacheAngles(R2,-1)
		LCARSeffects.InitStarshipFont
		AddStarships 
		
		'grey middle and white outer edge
		BG.DrawCircle(X,Y, Radius - BorderThickness*0.5, Colors.Gray ,False, BorderThickness)
		BG.DrawCircle(X,Y, Radius - ThickLine*0.5, Colors.White, False, ThickLine)
		
		'inner white border lines
		temp=Radius-BorderThickness-ThinLine+1
		
		If CurrentSecond>-1 Then
			temp2 = Trig.CorrectAngle( CurrentSecond * 6 - 3)
			DrawSegmentedCircle(BG, X,Y, R2, Colors.White, temp-ThickSpace, ThinLine, Array As Int(temp2, Trig.CorrectAngle(temp2+1), Trig.CorrectAngle(temp2+5),  Trig.CorrectAngle(temp2+6)))
		End If
		
		DrawSegmentedCircle(BG,X,Y,Radius, Colors.White, temp,   ThickLine, Array As Int( 339,16,32,48,77,	103,119,150,166,	194,227,243,251,	289,314,330)  )
		temp=temp+ThinLine-1
		BG.DrawCircle(X,Y, temp, Colors.White, False, ThinLine)
		'DrawSegmentedCircle(BG,X,Y,Radius, Colors.White, temp,   ThinLine, Array As Int(63,103,213,227,300,314)  )
		temp=temp+ThinLine-1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThickLine, Array As Int(352,32,48,62,77,	119,149,	213,243,	300,329,339 )  )
		
		'3 middle lines
		temp=temp+ThickSpace
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThinLine, Array As Int(10,26,62,70,	149,161,	242,262,	343,352 )  )
		DrawSegmentedLines(BG, X, Y, Colors.White , ThinLine,     Array As Int(26, temp,ThickSpace,     70, temp,ThickSpace, 149, temp,ThickLine,  161, temp,ThickSpace,242,temp,ThickSpace,  343, temp,ThickSpace ,    299, temp+ThickLine, ThinLine+1) ) 
		
		temp=temp+ThickLine
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThinLine, Array As Int(32,62,119,149,212,227,299,329  )  )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.Black, temp+ThinLine+1, ThinLine, Array As Int(32,62) )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp+ThinLine+1,   ThickSpace, Array As Int(66,68,155,157,158,160,260,262)  )
		
		temp=temp+ThickLine
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThinLine, Array As Int(26,32,    70,82,   98,119       , 161,172,         190,212,       227, 242,          289,299,    329,343 )  )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.Black, temp-ThinLine, ThinLine, Array As Int(162,172) )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp+ThinLine,   ThinLine, Array As Int(26,32))
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp+ThinLine+1,   ThickSpace, Array As Int(320,322,323,325,326,328)  )
		
		temp=temp+ThickLine+ThinLine-1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp,   ThickLine, Array As Int(277,279 )  )
		
		'outer 6 lines
		temp = Radius - ThickLine*0.5 - ThickSpace -ThickLine*4 - ThinLine
		
		
		temp=temp+ThickSpace
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThickLine, Array As Int(329,17,  62,68,   77,149,     167,212,     242,299 )  )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp-ThinLine,   ThinLine, Array As Int(99,114,120,134 )  )
		temp=temp+ThickLine-1
		BG.DrawCircle(X,Y, temp, Colors.White, False, ThickLine)
		
		temp=temp+ThickLine-1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThickLine, Array As Int(347,13,83,197,228,283,323,330 )  )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp,   ThinLine, Array As Int( 283,324 ))'this
		
		temp=temp+ThickLine-1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp,   ThickLine, Array As Int( 346,12,            81,97,171,193,         256,278)  )	
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp+1,   ThinLine, Array As Int( 131,213 ) )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp+ThinLine-1,   ThinLine, Array As Int(15,34, 61,99, 105,120,  213,284,    343,347 ) )
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp+ThinLine-1,   ThinLine, Array As Int(189,213))
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp-ThinLine,   ThinLine, Array As Int(228,256 ))
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp,   ThinLine, Array As Int(57,61))
		
		
		temp=temp+ThickLine-1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp,   ThickLine, Array As Int( 352,13, 81,104,171,193, 255,256,  258,259,    262,283 )  ) 
		DrawSegmentedCircle(BG,X,Y,R2, Colors.white, temp,   ThinLine, Array As Int( 34,61,120,131,    284,343 ))
		DrawSegmentedCircle(BG,X,Y,R2, Colors.black, temp-ThickLine,   ThinLine, Array As Int(134,149 ))
		
		
		temp=temp+ThinLine+1
		DrawSegmentedCircle(BG,X,Y,R2, Colors.White, temp,   ThinLine, Array As Int(352,32,     62,119,133,139,143,150,181,189,261,279 )  ) 
		
		'draw squares
		temp=Radius-BorderThickness-ThinLine+1
		MakeThePath(BG,P,X,Y,R2,SquareWidth,SquareLength,Radius,ThickLine,ThickSpace,ThinLine)	
		If WasForced Then ForceRedraw=False
	End If
	
	temp=Radius
		
	'center platform
	Radius=Radius-BorderThickness
	
	DrawInnerPlatform(BG, X,Y,Radius,R2,ThickLine,ThickSpace,ThinLine,temp)
	
	'drawstarships
	DrawStarships(BG,X,Y,temp,R2 )
	
	Radius=Radius*0.6
	DrawRandomNumbers(BG, X-Radius, Y+Radius, StarshipFont, 10, 0,0,0)
End Sub


Sub MoveOrigin(Ship As Starship, Door As Int, DoMove As Boolean,Angle As Int, Distance As Float )As Rect 
	If DoMove Then
		Distance = Ship.Distance
		Angle = Ship.Angle 
	End If
	Select Case Door
		Case 0 :	Return MoveStarshipOrigin(Ship,Distance, Angle, CurrRadius, 0,-InnerThickness, DoMove)'north
		Case 1 :	Return MoveStarshipOrigin(Ship,Distance, Angle, CurrRadius, InnerThickness,0, DoMove)'east
		Case 2 :	Return MoveStarshipOrigin(Ship,Distance, Angle, CurrRadius, 0,InnerThickness, DoMove)'south
		Case 3 :	Return MoveStarshipOrigin(Ship,Distance, Angle, CurrRadius, -InnerThickness,0, DoMove)'west
		Case Else :	Return MoveStarshipOrigin(Ship,Distance, Angle, CurrRadius, 0,0, DoMove)'center
	End Select
End Sub
Sub MoveStarshipOrigin(Ship As Starship,StarshipDistance As Float, StarshipAngle As Int, Radius As Int, X As Int, Y As Int, DoMove As Boolean )As Rect 
	Dim  Loc As Point , Distance As Int, Angle As Int ,temp As Rect  'Ship As Starship ,
	'Ship = Starships.Get(StarshipID)
	Loc = Trig.FindAnglePoint(Ship.Origin.X, Ship.Origin.Y, StarshipDistance*Radius,StarshipAngle)
	
	Distance = Trig.FindDistance(X,Y, Loc.X, Loc.Y)
	Angle = Trig.GetCorrectAngle(X,Y, Loc.X, Loc.Y)
	
	If DoMove Then
		Ship.Origin.X=X
		Ship.Origin.Y=Y
		Ship.Angle = Angle
		Ship.Distance = Distance/Radius
	Else
		temp.Initialize(X,Y, Distance,Angle)
		Return temp
	End If
	'Starships.set(StarshipID,Ship)
End Sub




Sub AddStarships()
	'sync old status with new one using OldDate and DateTime.Now
	Dim Minutes As Int ,temp As Int ,Reliants As Int 
	Minutes = DateTime.GetMinute(DateTime.Now)
	If Minutes<>OldDate Then ForceRedraw=True
	If StarshipsClean And Not (RemovingStarships) Then
		'check if new starships need to be added
		If Minutes>OldDate Then'RemoveStarshipByClass
			oldseconds=-1
			'max of 1 Constitution class ship, enters every 5 minutes, leaves every 10
			If IsAMultiple(Minutes,10) Then 
				RemoveStarshipByClass(Constitution)
				'5x Reliant class ships, 1 enters every 10 minutes, all leave at 60
				If Minutes >0 And Minutes <60 Then
					AddStarship(Reliant,GetFreeDockingBay)
				Else
					RemoveStarshipByClass(Reliant)
					'1x Excelsior class ship with registry of the current hour, orbiting the central platform in sync with the current second
					RemoveStarshipByClass(Excelsior)
					AddStarship(Excelsior, GetFreeDockingBay)
				End If
			Else If IsAMultiple(Minutes,5) Then
				AddStarship(Constitution, GetFreeDockingBay)
			End If
			
			'max of 4 Workbees, 1 enters every minute, all leave at 5
			If IsAMultiple(Minutes,5) Then 
				RemoveStarshipByClass(Workbee)
			Else
				AddWorkbees(1)
			End If
			
		Else If Minutes<OldDate Then	
			StarshipsClean=False
		End If
	Else 'the screen was exited or never entered, needs resyncing
		If Starships.IsInitialized Then'screen was exited
			If Not(RemovingStarships) Then	RemoveAllStarships
			RemovingStarships=True
		Else
			Starships.Initialize'screen was never entered
		End If
		
		If Starships.Size=0 Then
			RemovingStarships=False
			'add starships based on the new time
			AddStarship(Excelsior, GetFreeDockingBay)
			If NeedsConstitution(Minutes) Then AddStarship(Constitution, GetFreeDockingBay)
			Reliants=ReliantsNeeded(Minutes)
			For temp = 1 To Reliants
				AddStarship(Reliant, GetFreeDockingBay)
			Next
			AddWorkbees( WorkbeesNeeded(Minutes))
		End If
	End If
	
	OldDate = Minutes
	StarshipsClean=True
End Sub

Sub AddWorkbees(Count As Int) As Boolean 
	Dim temp As Int ,Ship As Starship
	For temp = 0 To Starships.Size-1
		If Count>0 Then
			Ship=Starships.Get(temp)
			If Not (Ship.Moving ) And Ship.Class<> Excelsior  Then
				Ship.Workbees = Ship.Workbees+Count
				Starships.Set(temp, Ship)
				Return True
			End If
		End If
	Next
	WorkbeesRemaining=(WorkbeesRemaining+Count)Mod 4
End Sub

Sub CountShips(Class As Int)  As Int
	Dim temp As Int, Ship As Starship, Count As Int 
	For temp = 0 To Starships.Size-1
		Ship=Starships.Get(temp)
		If Class =3 Then'count workbees
			If Ship.Moving Then Count = Count + Ship.Workbees 
		Else
			If Ship.Class = Class Then Count=Count+1
		End If
	Next
	Return Count
End Sub

Sub NeedsConstitution(Minute As Int) As Boolean 
	Return (Minute Mod 10) > 4  'between 4 and 9
End Sub
Sub ReliantsNeeded(Minute As Int) As Int
	Return Floor( (Minute Mod 60) /10)
End Sub
Sub WorkbeesNeeded(Minute As Int) As Int
	'can not be attached to an excelsior class ship
	Return Minute Mod 5
End Sub

Sub IsAMultiple(Value As Int, Number As Int) As Boolean 
	Return (Value Mod Number) = 0
End Sub

Sub GetFreeDockingBay As Int'returns a random docking bay
	Dim temp As Int, Free As Boolean 
	Free = True
	Do Until Not(Free)
		temp=Rnd(0,8)
		If Not( Doors( GetDockingBayDoor( temp ) ) ) Or DoorsInUse>3 Then
			Free=DockingBays(temp)
		End If
	Loop
	Return temp
End Sub
Sub GetDockingBayDoor (DockingBay As Int) As Int'returns the bay door closest to a docking bay
	Select Case DockingBay
		Case 0,1: Return 0'north
		Case 2,3: Return 1'east
		Case 4,5: Return 2'south
		Case 6,7: Return 3'west
	End Select
End Sub

Sub AddStarship(Class As Int, DockingBay As Int)
	Dim temp As Starship ,Door As Int 
	temp.Initialize 
	Door=GetDockingBayDoor(DockingBay)
	Select Case Door
		Case 0:temp.Angle=0 'north	
		Case 1:temp.Angle=90 'east
		Case 2:temp.Angle=180 'south
		Case 3:temp.Angle=270'west
	End Select
	temp.Origin.Initialize 
	temp.Orientation= Trig.CorrectAngle( temp.Angle+180 )
	temp.Class=Class
	temp.Distance=StartAt
	temp.Moving=True
	MovingShips=MovingShips+1
	If Class = Excelsior Then
		temp.Registry = "NX" & DateTime.GetHour(DateTime.Now) & Rnd(0,10)
		temp.DockingBay=-1
	Else
		temp.Registry = "NCC" &  Rnd(99,1000)
		temp.DockingBay=DockingBay
		DockingBays(DockingBay)=True
	End If
	temp.Door=Door
	Doors(Door)=True
	DoorsInUse=DoorsInUse+1
	
	MakeAI(temp,True)
	Starships.Add(temp)
End Sub
Sub MakeAI(Temp As Starship,GoingIn As Boolean  )
	'RotateAroundCenter As Int, MoveTowardsCenter As Int ,RotateWithSeconds As Int ,TurnStarship As Int
	Dim buffer As Int 
	If Not( Temp.AI.IsInitialized ) Then Temp.AI.Initialize 
	Select Case Temp.DockingBay 
		Case 0,2,4,6:buffer=1
		Case 1,3,5,7:buffer=-1
	End Select
	If GoingIn Then'entering
		AddAIMove(Temp.AI,OpenDoor, Temp.Door)
		AddAIMove(Temp.AI, MoveTowardsCenter, -(StartAt*100) +90)
		If Temp.Class = Excelsior Then
			AddAIMove(Temp.AI, CloseDoor, Temp.Door)
			AddAIMove(Temp.AI, TurnStarship, -90)
			AddAIMove(Temp.AI, RotateWithSeconds, 3600)
		Else
			AddAIMove(Temp.AI, TurnStarship,90 * buffer )
			AddAIMove(Temp.AI, CloseDoor, Temp.Door)
			AddAIMove(Temp.AI, RotateAroundCenter,-30 * buffer )
			AddAIMove(Temp.AI, ChangeOrigin, Temp.Door)
			AddAIMove(Temp.AI, TurnStarship,-90 * buffer )
			AddAIMove(Temp.AI, TurnToAngle, 45)
			AddAIMove(Temp.AI, MoveTowardsCenter, -50)
			AddAIMove(Temp.AI, StopDrawing, 0)
		End If'MoveToAngle TurnToAngle
	Else'leaving
		Temp.Moving=True
		If Temp.Class = Excelsior Then
			Temp.AI.Clear 
			'Temp.AI.RemoveAt(Temp.AI.Size-1)
			AddAIMove(Temp.AI, RotateAroundCenter, 90- (Temp.Angle Mod 90) )
			Temp.Door = GetNextDoor(Temp.Angle)
			buffer=1
			AddAIMove(Temp.AI, OpenDoor, Temp.Door)
		Else
			
			AddAIMove(Temp.AI, MoveTowardsCenter, (StartAt*100)-90) '50)
			
			AddAIMove(Temp.AI, TurnStarship,90 * -buffer )
			AddAIMove(Temp.AI, RotateAroundCenter,30 * buffer )
			
			'If Temp.Door=0 Then	
			'	AddAIMove(Temp.AI, MoveToAngle, 0)
			'Else
			'	AddAIMove(Temp.AI, MoveToAngle, 90)
			'End If
			AddAIMove(Temp.AI, MoveToAngle, Temp.Door*90)
			AddAIMove(Temp.AI, ChangeOrigin, 4)
		End If
		
		AddAIMove(Temp.AI, TurnStarship,90 * -buffer )
		AddAIMove(Temp.AI, OpenDoor, Temp.Door)
		AddAIMove(Temp.AI, MoveTowardsCenter, 50)
		AddAIMove(Temp.AI, CloseDoor, Temp.Door)
		AddAIMove(Temp.AI , DeleteShip, 0)
		
	End If
End Sub 

Sub GetNextDoor(Angle As Int) As Int
	If Angle = 0 Or Angle>270 Then
		Return 0
	Else If Angle >0 And Angle <91 Then
		Return 1 
	Else If Angle <181 Then
		Return 2
	Else 
		Return 3
	End If
End Sub

Sub AddAIMove(Lists As List, MoveType As Int, MoveQuantity As Int)
	Dim temp As Point 
	temp = LCARSeffects.SetPoint(MoveType, MoveQuantity)
	Lists.Add(temp)
End Sub

Sub RemoveAllStarships'program all starships to leave
	Dim temp As Int 
	For temp = 0 To Starships.Size-1
		RemoveStarship(temp)
	Next
	WorkbeesRemaining=0
End Sub
Sub RemoveStarshipByClass(Class As Int) As Boolean 
	Dim temp As Int ,Ship As Starship 
	For temp = 0 To Starships.Size-1
		Ship = Starships.Get(temp)
		If Class = Workbee Then
			If Ship.Workbees>0 Then 
				Ship.Workbees=0
				Starships.Set(temp,Ship)
			End If
			WorkbeesRemaining=0
		Else If Ship.Class = Class Then
			RemoveStarship(temp)
			Return True
		End If
	Next
	Return Class = Workbee
End Sub
Sub RemoveStarship(Index As Int)'program a starship to leave
	'set dockingbays(dockingbay) to false, starship.dockingbay to -1
	Dim Ship As Starship 
	If Index < Starships.Size Then
		Ship = Starships.Get(Index)
		Ship.Moving =True
		Ship.IsLeaving = True
		'If Not(Ship.AI.IsInitialized ) Then Ship.AI.Initialize 
		Ship.CacheNeedsInitializing = True
		MakeAI(Ship ,False)
		If Ship.DockingBay>-1 And Ship.DockingBay<8 Then DockingBays(Ship.DockingBay)=False
		Ship.DockingBay=-1
		Starships.Set(Index,Ship)
	End If
End Sub

Sub IncrementStarships As Boolean 'max of 4 can be moving at a time
	Dim temp As Long, SquareWidth As Int ,Ship As Starship , AImove As Point ,shipsinmotion As Int ,Seconds As Long ,Angle As Int 
	Dim rotateby As Int, MoveBy As Int, rotatearoundby As Int  ,ret As Boolean ,DeleteIt As Boolean 
	temp=DateTime.GetMinute(DateTime.Now)
	If temp > OldDate+1 Or temp<OldDate Then StarshipsClean =False
	
	rotateby=5:MoveBy = 1:rotatearoundby=2
	If Starships.IsInitialized Then
		IncrementNumbers
		ForceRedraw=True
		SquareWidth=20
		'inc doors
		For temp = 0 To 3
			If Doors( temp ) Then 
				DoorState(temp) = LCAR.Increment( DoorState(temp), 2, 0)
			Else
				DoorState(temp) = LCAR.Increment( DoorState(temp), 2, SquareWidth)
			End If
		Next
		
		'inc ships
		For temp =0 To Starships.Size -1
			' RotateAroundCenter As Int, MoveTowardsCenter As Int ,RotateWithSeconds As Int ,TurnStarship As Int
			DeleteIt=False
			If shipsinmotion<4 And Starships.Size > temp Then
				Ship = Starships.Get(temp) 
				If Ship.AI.Size>0 Then
					shipsinmotion=shipsinmotion+1
					AImove = Ship.AI.Get(0)
					Select Case AImove.X 'type of movement
						Case DeleteShip
							DeleteIt=True
							
						Case OpenDoor
							Doors(AImove.Y)=True
							If DoorState(AImove.Y) = 0 Then AImove.Y=0
							LCAR.IsClean=False
							
						Case CloseDoor
							Doors(AImove.Y)=False
							AImove.Y=0'DoorState(AImove.Y)
							LCAR.IsClean=False
					
						Case RotateAroundCenter
							Ship.Angle = IncValue(Ship.Angle, AImove.Y, rotatearoundby)
							Ship.Orientation=  IncValue(Ship.Orientation, AImove.Y, rotatearoundby)
							AImove.Y = LCAR.Increment(AImove.Y, rotatearoundby,0)
							
						Case MoveTowardsCenter
							Angle= IncValue( Ship.Distance *100, AImove.Y, MoveBy)
							Ship.Distance= Angle * 0.01
							AImove.Y = LCAR.Increment(AImove.Y, MoveBy,0)
							
						Case RotateWithSeconds
							Seconds = Floor(DateTime.Now / OneTick)' Floor((DateTime.Now Mod 1000) / OneTick)      'DateTime.GetSecond( DateTime.Now) 
							If Seconds > oldseconds Then
								'Angle = Ship.Angle/6
								'If Seconds > Angle-5 OR Seconds < Angle+5 Then
									Ship.Angle = (Ship.Angle+1) Mod 360
									If Ship.Angle > 90 And Ship.Angle < 270 Then ForceRedraw=True
									Ship.Orientation = Trig.CorrectAngle( Ship.Angle+90)
								'End If
								oldseconds=Seconds
							End If
							CurrentSecond = DateTime.GetSecond(DateTime.Now)
							
						Case TurnStarship
							Ship.Orientation =  IncValue(Ship.Orientation, AImove.Y, rotateby)
							AImove.Y = LCAR.Increment(AImove.Y, rotateby,0)
						
						Case ChangeOrigin'	'InnerThickness 
							Log("Change origin: " & MoveOrigin(Ship,AImove.Y, True, 0,0))
							AImove.Y=0				
						
						Case MoveToAngle
							If AImove.Y=0 Then
								If Ship.Angle<180 Then
									AImove.y = -Ship.Angle 
								Else
									AImove.y = 360-Ship.Angle 
								End If
							Else
								'AImove.X = Trig.ClosestAngle(Ship.Angle, AImove.Y)
								AImove.Y = Trig.AngleDifference( Ship.Angle,  AImove.y, False )'parameter aimove.y was x
							End If	
							AImove.X = RotateAroundCenter
							
						Case TurnToAngle
							'AImove.X = Trig.ClosestAngle(Ship.Orientation, AImove.Y)
							Select Case Ship.DockingBay 
								Case 0,7:AImove.X = 135
								Case 1,2:AImove.X = 225
								Case 3,4:AImove.X = 315
								Case 5,6:AImove.X = 45
							End Select
							AImove.Y = Trig.AngleDifference( Ship.Orientation, AImove.X,False )
							AImove.X = TurnStarship
						
						Case Else'WaitTicks
							If AImove.Y<>0 Then AImove.Y =Abs(AImove.Y) -1
					End Select
					If DeleteIt Then
						Starships.RemoveAt(temp)
						If Starships.Size=0 Then
							StarshipsClean=False
							AddStarships
						End If
					Else
						If AImove.X <> RotateWithSeconds Then
							If AImove.Y = 0 Then
								Ship.AI.RemoveAt(0)
								If Ship.AI.Size=0 Then 
									Ship.Moving=False
									If WorkbeesRemaining>0 Then
										Ship.Workbees=WorkbeesRemaining
										WorkbeesRemaining=0
									End If
									'Doors( Ship.Door) = False
								End If
							Else
								Ship.AI.Set(0,AImove)
							End If
						End If
						Starships.Set(temp, Ship)
					End If
					ret=True
				End If
			End If
		Next
	
	End If
	Return ret
End Sub

Sub StopShip(Index As Int)
	Dim Ship As Starship 
	Ship = Starships.Get(Index)
	Ship.AI.Clear 
	Ship.Moving=False
	Starships.Set(Index,Ship)
End Sub

Sub IncValue(Value As Int, IncQuantity As Int, IncBy As Int) As Int
	If IncQuantity <0 Then 
		Return Value -IncBy
	Else If IncQuantity>0 Then
		Return Value+IncBy
	End If
End Sub

Sub CacheCenterPlatform(BG As Canvas, X As Int, Y As Int, Radius As Int, R2 As Int, ThickLine As Int, Thickspace As Int, ThinLine As Int, temp As Int)As Int
	Dim temp2 As Int ,Left As Int ,Right As Int ,Top As Int,Bottom As Int, R3 As Int
	R3=R2
	R2=Radius-BorderThickness
	temp=R2 * 0.33
	temp2=temp
	InnerThickness=temp
	CurrRadius=Radius
	
	BG.DrawCircle(X,Y, temp, Colors.white, False,ThickLine)'outer circle
	
	R2=R2*0.6
	temp=temp * 0.75
	
	Left=X- R2
	Right=X+R2
	Top=Y-R2
	Bottom=Y+R2
	
	'big white rects
	BG.DrawLine(Left-ThickLine,   Top-ThickLine, Right+ThickLine, Bottom+ThickLine,  Colors.white,  temp+Thickspace)
	BG.DrawLine(Left-ThickLine,   Bottom+ThickLine, Right+ThickLine, Top-ThickLine,  Colors.white,  temp+Thickspace)
	'big grey rects inside white ones
	BG.DrawLine(Left,   Top, Right, Bottom,  Colors.Gray,  temp)
	BG.DrawLine(Left,   Bottom, Right, Top,  Colors.Gray,  temp)
	
	'white squares inside grey rects
	temp=temp-ThickLine
	BG.DrawLine(Left+ThinLine, Top+ThinLine, Left+temp-ThinLine, Top+temp-ThinLine,  Colors.white,  temp-ThinLine)'TL
	BG.DrawLine(Left+ThinLine, Bottom-ThinLine, Left+temp-ThinLine, Bottom-temp+ThinLine,  Colors.white,  temp-ThinLine)'BL
	BG.DrawLine(Right-ThinLine, Top+ThinLine, Right-temp+ThinLine, Top+temp-ThinLine,  Colors.white,  temp-ThinLine)'TR
	BG.DrawLine(Right-ThinLine, Bottom-ThinLine, Right-temp+ThinLine, Bottom-temp+ThinLine,  Colors.white,  temp-ThinLine)'BR
		
	BG.DrawCircle(X,Y, temp2-ThinLine, Colors.gray, True,0)'big grey circle
	
	'top left docking arm
	Bottom=DrawDockingArms(BG, X,Y,  temp *0.5,temp, R2,ThinLine,ThickLine,Thickspace)
	
	temp=temp*0.75
	BG.DrawCircle(X,Y, temp, Colors.white, False,ThinLine)'inner/middle circle
	
	'fancy middle circle bits
	DrawSegmentedCircle(BG,X,Y,R3, Colors.White, temp-ThinLine, ThinLine,  Array As Int(60,76,   90,185,   272,0,      260,250))
	DrawSegmentedCircle(BG,X,Y,R3, Colors.gray, temp, ThinLine,  Array As Int(114,167,331,210))'210 was 273
	DrawSegmentedCircle(BG,X,Y,R3, Colors.black, temp, ThinLine,  Array As Int(345,355))
	DrawSegmentedCircle(BG,X,Y,R3, Colors.White, temp+ThinLine, ThinLine,  Array As Int(90,185,   210,0))'210 was 272
	
	BG.DrawCircle(X,Y, 7, Colors.White, True,0)'inner most solid circle
	
	'little dots
	temp=temp2-ThickLine-ThinLine
	DrawCircle(BG, X,Y,temp,336, ThinLine)
	DrawCircle(BG, X,Y,temp,346, ThinLine)
	DrawCircle(BG, X,Y,temp,356, ThinLine)
	
	DrawCircle(BG, X,Y,temp,176, ThinLine)
	DrawCircle(BG, X,Y,temp,166, ThinLine)
	DrawCircle(BG, X,Y,temp,156, ThinLine)
	
	DrawCircle(BG, X,Y,temp-ThickLine,265, ThinLine+1)
	
	'BG.DrawText(Bottom, x,y, Typeface.DEFAULT, 30, Colors.Red, "LEFT")
End Sub
Sub DrawInnerPlatform(BG As Canvas, X As Int, Y As Int, Radius As Int, R2 As Int, ThickLine As Int, Thickspace As Int, ThinLine As Int, temp As Int)
	Dim tempBG As Canvas,R As Int '
	If Not(CenterPlatform.IsInitialized ) Or CenterPlatformID <> LCAR.LCAR_StarBase  Then 
		R=225
		CenterPlatformID=LCAR.LCAR_StarBase
		CenterPlatform.InitializeMutable(R*2,R*2)
		tempBG.Initialize2(CenterPlatform)
		CacheCenterPlatform(tempBG, R,R,R,R2,ThickLine,Thickspace,ThinLine,temp)
	End If
	BG.DrawBitmap(CenterPlatform, Null, LCAR.SetRect(X-Radius,Y-Radius,Radius*2,Radius*2))
End Sub
Sub DrawCircle(BG As Canvas, X As Int, Y As Int, Distance As Int, Angle As Int, Radius As Int)
	BG.DrawCircle(    Trig.findXYAngle(X,Y,Distance, Angle, True), Trig.findXYAngle(X,Y,Distance, Angle, False), Radius, Colors.White, True,0)
End Sub
Sub GetSize(MaxSize As Int, Size As Int) As Int
	If MaxSize=51 Then 
		Return Size
	Else
		Return (Size*0.02)*MaxSize'(Size/51)*MaxSize
	End If
End Sub
Sub DrawDockingArms(BG As Canvas, X As Int, Y As Int, HalfWidth As Int, Width As Int, Height As Int, ThinLine As Int, ThickLine As Int, ThickSpace As Int) As Int 
	Dim tX As Int,tY As Int,Size As Int,MaxSize As Int,temp As Int, px5 As Int 
	MaxSize=Height-Width-ThickSpace+ThinLine
	px5=GetSize(MaxSize, 5)
	
	'top left arm
	tX=HalfWidth+ThinLine
	tY=Height+ThickLine
	Size=px5*6
	DrawDiagonal(BG, X,Y, 0,tX, tY,0,Size,ThickLine, Colors.white)'outer top left edge
	
	tX=HalfWidth-ThickLine
	tY=Height-Width+ThinLine
	Size=px5*3
	DrawDiagonal(BG, X,Y, 0,tX-1, tY,0,Size,ThinLine, Colors.white)
	DrawDiagonal(BG, X,Y, 0,tX-HalfWidth-ThinLine+1, tY,0,MaxSize,ThinLine, Colors.white)'right line
	
	temp=GetSize(MaxSize, 7)
	DrawDiagonal(BG, X,Y, 0,tX-ThickLine, tY-ThinLine,0,temp,7, Colors.white)
	DrawDiagonal(BG, X,Y, 0,tX-ThickLine-4, tY-ThinLine,0,temp,ThinLine, Colors.black)
	
	tX=tX-ThinLine
	tY=tY-Size+ThinLine
	Size=px5*4
	DrawDiagonal(BG, X,Y, 0,tX,tY,0,Size,ThinLine, Colors.white)
	tX=tX+ThinLine*0.5
	tY=tY-Size+ThinLine
	DrawDiagonal(BG, X,Y, 0,tX,tY,0,Size,ThickLine, Colors.white)
	
	DrawDiagonal(BG, X,Y, 0,tX-ThickLine,tY,0,6,7, Colors.white)
	
	tX=tX-ThinLine*0.5
	tY=tY-5
	Size=Size-px5
	DrawDiagonal(BG, X,Y, 0,tX,tY,0,Size,ThinLine, Colors.black)
	
	'top right arm
	tX=HalfWidth+2
	tY=Height+ThickLine
	DrawDiagonal(BG,X,Y,1,tX-1,tY, HalfWidth+2,0,ThickLine,Colors.white)
	tX=tX- Width + HalfWidth*0.25-1
	DrawDiagonal(BG,X,Y,1,tX,tY, HalfWidth*0.5,0,ThickLine,Colors.white)
	
	tX=HalfWidth-ThickLine
	tY=Height-Width+ThinLine
	DrawDiagonal(BG, X,Y, 1,tX-1, tY,0,MaxSize,ThinLine, Colors.white)
	tX=tX-HalfWidth-ThinLine+1
	DrawDiagonal(BG, X,Y, 1,tX, tY,0,MaxSize,ThinLine, Colors.white)
	
	Size=px5*3
	DrawDiagonal(BG, X,Y, 1,tX, tY-Size,0,Size,ThinLine, Colors.black)
	
	Size=GetSize(MaxSize,8)
	tX=tX+ThinLine-1
	tY=tY-Size
	Size=px5*6
	DrawDiagonal(BG, X,Y, 1,tX, tY,0,Size,ThinLine, Colors.white)
	
	tX=tX+ThickLine
	Size=GetSize(MaxSize,7)
	DrawDiagonal(BG, X,Y, 1,tX, tY,0,Size,ThickLine, Colors.white)
	
	'bottom right arm
	tX=-HalfWidth+ThinLine+1
	tY=Height-ThinLine
	Size=Width-ThickLine
	DrawDiagonal(BG, X,Y, 2,tX, tY, 0,Size,ThinLine, Colors.black)
	
	tX=HalfWidth+ThinLine
	tY=Height+ThickLine
	Size=px5*2
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThinLine, Colors.white)'left lines
	tY=tY-Size*2
	Size=px5*3
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThinLine, Colors.white)
	
	tX=HalfWidth-ThickLine
	tY=Height-Width+ThinLine
	Size=px5*2
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThinLine, Colors.white)'|
	tY=tY-Size
	Size=HalfWidth*0.5
	DrawDiagonal(BG, X,Y, 2,tX, tY, Size,0,ThinLine, Colors.white)'-
	temp=tY
	tX=tX-Size
	Size=px5*4
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThinLine, Colors.white)'|
	tY=tY-Size
	Size=HalfWidth*0.5+ThinLine
	DrawDiagonal(BG, X,Y, 2,tX, tY, Size,0,ThickLine, Colors.white)'-
	
	tX=HalfWidth-ThickLine-1'blocks
	tY=temp-ThinLine
	Size=px5-1
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThickLine, Colors.white)'|
	tY=tY-Size-ThinLine
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThickLine, Colors.white)'|
	tY=tY-Size-ThinLine
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThickLine, Colors.white)'|
	
	tX=HalfWidth-ThickLine
	tX=tX-HalfWidth-ThinLine+1
	tY=Height-Width+ThinLine
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,MaxSize,ThinLine, Colors.white)'right line
	Size=MaxSize*0.25
	tY=tY-Size
	tX=tX+ThinLine-1
	Size=MaxSize*0.75
	DrawDiagonal(BG, X,Y, 2,tX, tY,0,Size,ThinLine, Colors.white)'right line
	
	'bottom left arm
	tX=-HalfWidth-ThinLine
	tY=Height+ThickLine
	Size=px5*3
	temp=px5*2
	DrawDiagonal(BG, X,Y, 3,tX, tY,0,Size,ThinLine, Colors.white)'right lines
	DrawDiagonal(BG, X,Y-ThickLine, 3,tX, tY,ThickLine,0,0, Colors.white)'right lines
	
	tY=tY-Size-temp
	Size=temp
	DrawDiagonal(BG, X,Y, 3,tX, tY,0,Size,ThinLine, Colors.white)
	tY=tY-Size*2-ThickLine
	DrawDiagonal(BG, X,Y, 3,tX, tY,ThickLine,0,0, Colors.white)'circle
	
	tX=HalfWidth-ThickLine
	tY=Height-Width+ThinLine
	Size=GetSize(MaxSize,33)
	DrawDiagonal(BG, X,Y, 3,tX-1, tY,0,Size,ThinLine, Colors.white)'left line
	
	DrawDiagonal(BG, X,Y, 3,tX-ThickLine, tY-ThinLine,0,px5*2,7, Colors.white)
	DrawDiagonal(BG, X,Y, 3,tX-ThickLine-4, tY-ThinLine,0,px5*2,ThinLine, Colors.black)
	
	tX=tX-ThinLine
	Size=Size-5
	tY=tY-Size
	Size=px5*4
	DrawDiagonal(BG, X,Y, 3,tX,tY,0,Size,ThinLine, Colors.white)
	
	tX=HalfWidth-ThickLine
	tX=tX-HalfWidth-ThinLine+1
	tY=Height-Width+ThinLine
	Size=px5*5
	DrawDiagonal(BG, X,Y, 3,tX,tY,0,Size,ThinLine, Colors.white)'right line
	temp=tX
	tX=tX+ThinLine-1
	tY=tY-Size+ThinLine
	Size=px5*2
	DrawDiagonal(BG, X,Y, 3,tX,tY,0,Size,ThinLine, Colors.white)'right line
	tX=temp
	tY=tY-Size+ThinLine
	Size=px5*4
	DrawDiagonal(BG, X,Y, 3,tX,tY,0,Size,ThinLine, Colors.white)'right line
	
	Return MaxSize
End Sub
Sub DrawDiagonal(BG As Canvas,oX As Int, oY As Int, DockingArm As Int, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, Color As Int)As Point 
	Dim tX As Int,tY As Int ,wX As Int, wY As Int 
	Select Case DockingArm
		Case 0'top left
			tX= (oX-Y)-X
			tY= (oY-Y)+X
			wX=tX+Width+Height
			wY=tY-Width+Height
		Case 1'top right
			tX=(oX+Y)-X
			tY=(oY-Y)-X
			wX=tX+Width-Height
			wY=tY+Width+Height
		Case 2'bottom right
			tX=(oX+Y)+X
			tY=(oY+Y)-X
			wX=tX-Width-Height
			wY=tY+Width-Height
		Case 3'bottom left
			tX=(oX-Y)+X
			tY=(oY+Y)+X
			wX=tX-Width+Height
			wY=tY-Width-Height
	End Select
	
	If Stroke>0 Then
		BG.DrawLine(tX,tY,wX,wY, Color,Stroke)
	Else
		BG.DrawCircle(tX,tY,Width, Color,True,0)
	End If
	
	Return Trig.SetPoint(wX,wY)
End Sub

Sub MakeSquare(BG As Canvas, X As Int,Y As Int, Width As Int,Height As Int, ThickLine As Int,ThinLine As Int,  Dir As Boolean )
	Dim temp As Int 
	BG.DrawRect( LCAR.SetRect(X,Y,Width,Height),  Colors.Black, True, 0)
	If Width>Height Then
		X=X+ThickLine
		If Dir Then X = X- 25 
		temp=Y-ThinLine
		BG.DrawLine(X,temp,X+BorderThickness,temp, Colors.white, ThickLine)
		temp=Y+Height+ThinLine-1
		BG.DrawLine(X,temp,X+BorderThickness,temp, Colors.white, ThickLine)
	Else
		If Dir Then Y = Y- 25 +ThickLine
		temp=X-ThinLine
		BG.DrawLine(temp,Y, temp,Y+BorderThickness, Colors.white, ThickLine)
		temp=X+Width+ThinLine-1
		BG.DrawLine(temp,Y, temp,Y+BorderThickness, Colors.white, ThickLine)
	End If
End Sub

Sub DrawDoors(BG As Canvas, X As Int, Y As Int, Radius As Int,  SquareWidth As Int, LineThickness As Int)
	Dim temp As Int,Half As Int 
	Half=SquareWidth*0.5
	
	temp=Y-Radius+BorderThickness
	DrawDoor(BG,X-Half,temp, SquareWidth, True, DoorState(0), LineThickness)'north
	
	temp=X+Radius-BorderThickness
	DrawDoor(BG,temp, Y-Half, SquareWidth, False, DoorState(1), LineThickness)'east
	
	temp=Y+Radius-BorderThickness
	DrawDoor(BG,X-Half,temp, SquareWidth, True, DoorState(2), LineThickness)'south
	
	temp=X-Radius+BorderThickness
	DrawDoor(BG,temp, Y-Half, SquareWidth, False, DoorState(3), LineThickness)'west
End Sub
Sub DrawDoor(BG As Canvas, X As Int, Y As Int,Size As Int, Horizontal As Boolean, State As Int, Thickness As Int)
	If Horizontal Then
		If State*2= Size Then
			BG.DrawLine(X,Y,X+Size-1,Y, Colors.White, Thickness)
		Else
			BG.DrawLine(X,Y,X+State,Y, Colors.White, Thickness)
			BG.DrawLine(X+Size,Y,X+Size-State,Y, Colors.White, Thickness)
		End If
	Else
		If State*2= Size Then
			BG.DrawLine(X,Y,X,Y+Size, Colors.White, Thickness)
		Else
			BG.DrawLine(X,Y,X,Y+State, Colors.White, Thickness)
			BG.DrawLine(X,Y+Size,X,Y+Size-State, Colors.White, Thickness)
		End If
	End If
End Sub

Sub MakeThePath(BG As Canvas, P As Path, X As Int, Y As Int, R2 As Int, SquareWidth As Int,SquareLength As Int, Radius As Int,  ThickLine As Int,ThickSpace As Int,ThinLine As Int)
	Dim temp As Int ,temp2 As Int
	MakeSquare(BG, X-SquareWidth*0.5, Y- Radius+BorderThickness -SquareLength,SquareWidth,SquareLength +ThickLine +1,ThickLine,ThinLine,True  )'north
	MakeSquare(BG,X-Radius+BorderThickness -SquareLength  , Y-SquareWidth*0.5 ,SquareLength +ThickSpace ,SquareWidth,ThickLine,ThinLine,True )'west
	MakeSquare(BG,X+Radius-BorderThickness-ThickSpace  , Y-SquareWidth*0.5 ,SquareLength+ThickSpace  ,SquareWidth ,ThickLine,ThinLine,False   )'east
	MakeSquare(BG,X-SquareWidth*0.5, Y+ Radius-BorderThickness-ThickLine,SquareWidth,SquareLength +ThickLine +1,ThickLine,ThinLine,False    )'south
	
	'BG.DrawRect( LCAR.SetRect(X-SquareWidth*0.5, Y- Radius+BorderThickness -SquareLength,SquareWidth,SquareLength +ThickLine +1   ), Colors.Black, True, 0)'north
	'BG.DrawRect( LCAR.SetRect(X-Radius+BorderThickness -SquareLength  , Y-SquareWidth*0.5 ,SquareLength +ThickSpace ,SquareWidth  ), Colors.Black, True, 0)'west
	'BG.DrawRect( LCAR.SetRect(X+Radius-BorderThickness-ThickSpace  , Y-SquareWidth*0.5 ,SquareLength+ThickSpace  ,SquareWidth  ), Colors.Black, True, 0)'east
	'BG.DrawRect( LCAR.SetRect(X-SquareWidth*0.5, Y+ Radius-BorderThickness-ThickLine,SquareWidth,SquareLength +ThickLine +1   ), Colors.Black, True, 0)'south
	
	SquareWidth=SquareWidth*0.5
	
	'DOORS
	'temp=X-Radius+BorderThickness
	'BG.DrawLine(temp, Y-SquareWidth, temp, Y+SquareWidth, Colors.White,ThinLine )
	'temp=Y+Radius-BorderThickness
	'BG.DrawLine(X-SquareWidth, temp, X+SquareWidth,temp,Colors.White,ThinLine )
	
	'north
	P.Initialize(X-SquareWidth, Y+R2)
	P.LineTo(X-SquareWidth, Y-R2)
	P.LineTo(X+SquareWidth, Y-R2)
	P.LineTo(X+SquareWidth, Y+R2)
	
	'east
	P.LineTo(X-R2, Y- SquareWidth)
	P.LineTo(X+R2,Y-SquareWidth)
	P.LineTo(X+R2,Y+SquareWidth)
	P.LineTo(X-R2,Y+SquareWidth)
	P.LineTo(X-R2, Y- SquareWidth)
		
	BG.ClipPath(P)
	temp=BorderThickness-SquareLength
	temp2=(SquareWidth-ThickLine)
	BG.DrawCircle(X,Y, Radius - temp*0.5, Colors.gray, False, temp-ThickLine*2)
	BG.RemoveClip 
	
	temp=X-Radius+ThickLine+ThinLine+1
	BG.DrawRect( LCAR.SetRect(temp,  Y-ThinLine-temp2, temp2*0.5, temp2)   , Colors.white,True,0)
	BG.DrawRect( LCAR.SetRect(temp,  Y+ThinLine, temp2*0.5, temp2)   , Colors.white,True,0)
	
End Sub

'Thickness: 0=will draw a rectangle?, -5=gradient(top and bottom), -10=gradient(left and right), -11=returns the radius+1/2 thickness without removing the clip path
Sub DrawSegmentedCircle(BG As Canvas, X As Int, Y As Int, SBRadius As Int , Color As Int, Radius As Int, Thickness As Int, Segments As List) As Int
	Dim P As Path,temp As Int ,toMiddle As Boolean , temp2 As Int,temp3 As Point 
	P.Initialize(X,Y)
	For temp = 0 To Segments.Size-1 
		temp2=Trig.CorrectAngle( Segments.Get(temp) )
		
		temp3=LCARSeffects.CacheAngles(0,temp2)
		P.LineTo( X+ temp3.X  ,  Y+ temp3.Y )
		'P.LineTo(  Trig.findXYAngle(X,Y, SBRadius, temp2, True) , Trig.findXYAngle(X,Y, SBRadius, temp2, False) )
		
		
		If toMiddle Then P.LineTo(X,Y)
		toMiddle= Not(toMiddle)
	Next
	If toMiddle Then P.LineTo(X,Y)
	BG.ClipPath(P)
	If Thickness>0 Then
		If Radius<=0 Then  Radius = Abs(Radius) + (Thickness*0.5)
		BG.DrawCircle(X,Y, Radius, Color, False, Thickness)
	Else 
		temp=Radius*2
		Select Case Thickness
			Case 0: LCAR.DrawRect(BG, X-Radius,Y-Radius,temp,temp, Color,0)
			
			'Case -1'"BR_TL"	
			'Case -2: LCAR.DrawGradient(BG, Colors.Black, Color,  2,X-Radius,Y-Radius,temp,Radius, 0,0)'"BOTTOM_TOP"
			'Case -3'"BL_TR"
			'Case -4'"RIGHT_LEFT"
				'LCAR.DrawGradient(BG, Colors.Black, Color,  4,X,Y-Radius,Radius,temp, 0,0)'"RIGHT_LEFT"
				
			Case -5'top and bottom
				'BG.RemoveClip 
				LCAR.DrawGradient(BG,  Color,  Colors.Black,   2,X-Radius,Y-Radius,temp,Radius, 0,0)'"BOTTOM_TOP"
				LCAR.DrawGradient(BG,  Color,  Colors.Black,   8,X-Radius,Y,temp,Radius, 0,0)'"TOP_BOTTOM"
				'Return
			'Case -6'"LEFT_RIGHT"
				LCAR.DrawGradient(BG, Colors.Black, Color,  6,X-Radius,Y-Radius,Radius,temp, 0,0)'"LEFT_RIGHT"
			'Case -7'"TR_BL"
			'Case -8: LCAR.DrawGradient(BG, Colors.Black, Color,  8,X-Radius,Y,temp,Radius, 0,0)'"TOP_BOTTOM"
			
			'Case 9'"TL_BR"
			Case -10'left and right
				LCAR.DrawGradient(BG, Color, Colors.Black,  6,X-Radius,Y-Radius,Radius,temp, 0,0)'"LEFT_RIGHT"
				LCAR.DrawGradient(BG, Color, Colors.Black,  4,X,Y-Radius,Radius,temp, 0,0)'"RIGHT_LEFT"
			Case -11: Return Radius+Thickness*0.5
			'Case-1,-2,-3,-4, -6,-7,-8,-9
			'	LCAR.DrawGradient(BG, Colors.Black, Color,  Abs(Thickness),X-Radius,Y-Radius,temp,temp, 0,0)
		End Select
	End If
	BG.RemoveClip 
End Sub
Sub DrawSegmentedLines(BG As Canvas, X As Int, Y As Int, Color As Int, Stroke As Int, Segments As List)
	Dim temp As Int ,Angle As Int , StartRadius As Int, EndRadius As Int 
	For temp = 0 To Segments.Size-1  Step 3
		Angle = Segments.Get(temp) Mod 360
		StartRadius= Segments.Get(temp+1)
		EndRadius=StartRadius+Segments.Get(temp+2)
		LCARSeffects.DrawLine(BG, X,Y, Angle, StartRadius, EndRadius, Color, Stroke)
	Next
End Sub


''starship stuff
	'Type Movement(MovementType As Int, Quantity As Int)'towards/away from center by distance, around center by degrees, orientation by degrees, infinite movement sync with seconds
	'Type Starship(Distance As Int, Angle As Int, Orientation As Int, Class As Int, Moving As Boolean, AI As List)
	'Dim d45 As Int ,StarshipBMP As Bitmap ,Starships As List 
	'StarshipBMP.Initialize(File.DirAssets,"starships.gif")

Sub DrawStarships(BG As Canvas, X As Int, Y As Int, Radius As Int,R2 As Int)', ) 
	Dim temp As Int, Ship As Starship ,Color As Int,R2 As Int,R3 As Int,Moving As Int,Index As Int,TempPoint As Point, TempPoint2 As Point, Minute As String, TextSize As Int = LCAR.LegacyTextHeight(BG, 10)    'P As Path ,
	If StarshipScaleFactor = 0 Then StarshipScaleFactor = Min(1, Radius/200)
	DrawDoors(BG,X,Y, Radius,  40, 6)
	'P.Initialize(X-Radius,Y-Radius)
	'P.LineTo(X+Radius,Y-Radius)
	'P.LineTo(X+Radius, Y+Radius)
	'P.LineTo(X-Radius,Y+Radius)
	'BG.ClipPath(P)
	'R2=Radius*2
	R3=Radius-74
	Index=Starships.Size-1
	For temp = 0 To Starships.Size-1
		Ship = Starships.Get(temp)
		If Ship.Moving Then Moving=Moving+1
		Color= DrawStarship( BG,X + Ship.Origin.X,Y + Ship.Origin.Y,R3, X,Y, R2, Ship,Moving<5) 
		If HelpMode Then 'AND Not(Ship.IsLeaving)  Then 
			TempPoint= DrawHelp(BG,X,Y,Radius, Ship, Color,Index, TextSize)			
			If Not(TempPoint2.IsInitialized) Then TempPoint2= TempPoint
		End If
		Index=Index-1
	Next
	If TempPoint2.IsInitialized Then
		Minute= DateTime.GetMinute(DateTime.Now)
		If Minute.Length=1 Then Minute= "0" & Minute
		If WorkbeesRemaining>0 Then Minute= Minute & " " & WorkbeesText(WorkbeesRemaining)
		LCAR.DrawLegacyText(BG, TempPoint2.X,TempPoint2.Y+TextSize, 0,0, API.GetString("date_time") & "=" & DateTime.GetHour(DateTime.Now) & ":" & Minute,  10, Colors.White,0)
	End If
	'BG.RemoveClip 
End Sub



		
		
Sub DrawHelp(BG As Canvas, X As Int, Y As Int, Radius As Int, Ship As Starship, Color As Int,Index As Int, TextSize As Int)As Point 
	Dim temp As Point,Text As StringBuilder,temp2 As Int,temp3 As Int '•Ω
	'If HelpMode Then
		temp=GetHelpSize(X,Y,Radius,Ship,Index)
		BG.DrawLine(Ship.LastDrawn.X, Ship.LastDrawn.Y, temp.X, temp.Y, Color, 2)
		Text.Initialize 
		If Ship.IsLeaving Then
			Text.Append(API.GetString("bay_loc1"))
		Else
			Select Case Ship.Class 
				Case Excelsior:		Text.Append (API.getstring("date_hour") & "=" & DateTime.GetHour(DateTime.Now) & " (" & API.Left(Ship.Registry, Ship.Registry.Length-1) & ")")
				Case Constitution:	Text.Append (API.getstring("date_min") & "+5")
				Case Reliant: 		Text.Append (API.getstring("date_min") & "+10")
			End Select
			If Ship.Workbees>0 Then Text.Append ("+" & Ship.Workbees & " " & WorkbeesText( Ship.Workbees) ) '(")
		End If
		If PortraitMode Then
			temp3= BG.MeasureStringWidth( Text.ToString, StarshipFont, 10)
			If temp.X+temp3> LCAR.ScaleWidth Then temp.X= temp.X - temp3-1
			LCAR.DrawLegacyText(BG,temp.X,temp.Y -  API.IIF(Ship.Class= Excelsior,3,0)   ,0,0, Text.ToString,10, Color,0)
		Else
			temp2=temp.X+Index*3
			temp3=LCAR.ItemHeight +2+ Index*TextSize '14
			BG.DrawLine(temp.X, temp.Y,temp2, temp.Y, Color, 2)
			BG.DrawLine(temp2, temp.Y,temp2, temp3, Color, 2)
			LCAR.DrawLegacyText(BG, temp2+1,temp3,0,0, Text.ToString,10, Color,0)
			temp.X=temp2+1
			temp.Y=temp3
		End If
		Return temp
	'End If
End Sub
Sub WorkbeesText(Bees As Int) As String
	Dim temp As Int,tempstr As String 
	If Bees>0 Then
		tempstr="("
		For temp=1 To Bees
			tempstr=tempstr & "•"
		Next
		Return tempstr & ")"
	End If
End Sub
Sub GetHelpSize(X As Int,Y As Int,Radius As Int, Ship As Starship,Index As Int) As Point
	Dim temp As Point 
	temp.Initialize
	If PortraitMode Then
		temp.X= Ship.LastDrawn.X
		temp.Y= Y + Radius + 5 + (Index*14) ' GetHelpSize2(X,Y,Radius,Ship,False, 12,Index)
	Else'landscape
		temp.X= X  + Radius + 10
		temp.Y= Ship.LastDrawn.Y
	End If
	Return temp
End Sub
Sub GetHelpSize2(X As Int,Y As Int,Radius As Int, Ship As Starship, IsX As Boolean, Offset As Int,Index As Int ) As Int
	Dim Left As Int, ShipX As Int ,temp As Int
	If IsX Then
		Left=X-Radius*0.5
		ShipX=Ship.LastDrawn.X-Left	
	Else
		Left=Y-Radius*0.5
		ShipX=Ship.LastDrawn.Y-Left
		temp=Index*Offset
	End If
	Return Radius*2-ShipX + temp
End Sub

Sub DrawStarship(BG As Canvas, X As Int, Y As Int, Radius As Int ,  oX As Int,oY As Int, R2 As Int, Ship As Starship,IsMoving As Boolean  )As Int 
	Dim SrcX As Int, srcY As Int, srcWidth As Int, srcHeight As Int, Dest As Point ,DestWidth As Int, DestHeight As Int ,Color As Int ,Dest2 As Point ,StarshipFontSize As Int,WB As Int
	'Radius=Radius-74'outer edge
	srcWidth=16
	StarshipFontSize=10
	If StarshipScaleFactor=0 Then StarshipScaleFactor = 1
	Select Case Ship.Class 
		Case 0'Excelsior
			srcHeight=37
			Color = Colors.RGB(213,199,2)
		Case 1'Constitution
			srcY=36
			srcHeight=33
			Color = Colors.RGB(11,102,251)
		Case 2'Reliant/Miranda
			srcY=69
			srcWidth=11
			srcHeight=18
			Color=Colors.RGB(242,6,6)
		'case 3'Workbees are drawn next to the starship itself, no animation
	End Select
	Dest=Trig.FindAnglePoint(X,Y, Ship.Distance*Radius,Ship.Angle)
	
	DestWidth=srcWidth*StarshipScaleFactor
	DestHeight=srcHeight*StarshipScaleFactor
	
	'clip starship
	'If Ship.Orientation = Trig.CorrectAngle(Angle+180) AND Ship.Distance>=1 Then
	'	Select Case Ship.Angle
	'		Case 0
	'		Case 90
	'		Case 180
	'		Case 270
	'	End Select
	'End If
	
	'Dest.X=Dest.X- (DestWidth*0.5)
	'Dest.Y=Dest.Y- (DestHeight*0.5)
	
	If Ship.Moving Then
		'Dest2=Trig.FindAnglePoint(Dest.X,Dest.Y, BG.MeasureStringWidth(Registry, StarshipFont, StarshipFontSize), Orientation+90)
		Dest2.X = Dest.X
		Dest2.Y = Dest.Y+ srcWidth +  Abs(Trig.findXYAngle(0,0, srcHeight, Ship.Orientation, False)) '
		If  DoPaths And IsMoving Then DrawAIpath(BG,oX,oY, R2, Radius, Color,Ship, 4  )
		
		BG.DrawText(Ship.Registry, Dest2.X, Dest2.Y, StarshipFont, StarshipFontSize, Color, "CENTER")
		If PortraitMode Then
			Dest2.Y=Dest2.Y+ BG.MeasureStringHeight(Ship.Registry, StarshipFont, StarshipFontSize)
		Else
			Dest2.X=Dest2.X+ BG.MeasureStringwidth(Ship.Registry, StarshipFont, StarshipFontSize)*0.5
			Dest2.Y=Dest2.Y-5
		End If
		Ship.LastDrawn=Dest2
		
	Else
		Ship.LastDrawn=Dest
		
		SrcX=srcWidth
	'End If
		If Ship.Workbees>0 Then
			WB=srcWidth'+5
			Select Case Ship.DockingBay				
				Case 0,3:DrawworkBees(BG,Dest.X,Dest.Y, Dest.X+ WB, Dest.Y-WB, Ship.Workbees,-WorkbeeSpace,-WorkbeeSpace)'top left, right middle bottom
				Case 1,6:DrawworkBees(BG,Dest.X,Dest.Y, Dest.X- WB, Dest.Y-WB, Ship.Workbees, WorkbeeSpace,-WorkbeeSpace)'top right, left middle bottom
				Case 2,5:DrawworkBees(BG,Dest.X,Dest.Y, Dest.X+ WB, Dest.Y+WB, Ship.Workbees, WorkbeeSpace,-WorkbeeSpace)'right middle top, bottom left
				Case 4,7:DrawworkBees(BG,Dest.X,Dest.Y, Dest.X- WB, Dest.Y+WB, Ship.Workbees,-WorkbeeSpace,-WorkbeeSpace)'bottom right, left middle top
			End Select
		End If
	End If
	
	BG.DrawBitmapRotated(StarshipBMP, LCAR.SetRect(SrcX,srcY,srcWidth,srcHeight), LCAR.SetRect(Dest.X- (DestWidth*0.5),Dest.Y- (DestHeight*0.5), DestWidth,DestHeight), Ship.Orientation)  
	'If Moving Then 
	
	'DrawHelp(BG,X,Y,Radius, Ship, Color)
	Return Color
End Sub
Sub DrawAIpath(BG As Canvas, X As Int, Y As Int,R2 As Int, Radius As Int,Color As Int, Ship As Starship ,Stroke As Int )
	Dim temp As Int,temp2 As Rect, AImove As Point  ,Origin As Point,Angle As Int,FirstMove As Boolean ,Distance As Float,temp3 As Int,LastMove As Int,DidDraw As Boolean ' ,Orientation As Int=Ship.Orientation
	Origin=Trig.SetPoint( Ship.Origin.X,  Ship.Origin.Y)
	Angle = Ship.Angle 
	FirstMove=True 
	Distance=Ship.Distance 
	If Ship.AI.Size>0 Then
			For temp = 0 To Ship.AI.Size-1
				AImove= Ship.AI.Get(temp)
				Select Case AImove.X
					Case RotateAroundCenter,MoveTowardsCenter,MoveToAngle,RotateWithSeconds
						LastMove=temp
					Case StopDrawing
						temp=Ship.AI.Size 
				End Select
			Next
	
			For temp = 0 To Ship.AI.Size-1
				AImove= Ship.AI.Get(temp)
				Select Case AImove.X
					'DeleteShip,OpenDoor,CloseDoor	
					Case ChangeOrigin
						If Not(Ship.IsLeaving ) Then Return
						If Ship.Cache.IsInitialized And Not(Ship.CacheNeedsInitializing) Then
							temp2=Ship.Cache 
						Else
							Ship.CacheNeedsInitializing=False
							temp2 =MoveOrigin(Ship, AImove.Y, False,   Angle, Distance)' MoveStarshipOrigin(Ship, Radius, X,Y,False)
							'Log(temp2)
							Ship.Cache = temp2
						End If
						
						'temp2.Initialize(left X ,top Y, right Distance, bottom Angle)
						Origin=Trig.SetPoint(Origin.X+ temp2.Left ,Origin.Y+ temp2.Top )
						'Log("CH: " & temp2.right)
						Distance= temp2.right/Radius
						
						If Ship.IsLeaving And Ship.Door =3 Then 
							Angle=270
						Else
							Angle = temp2.bottom
						End If
						
					'Case TurnStarship
						'Orientation= Trig.CorrectAngle( Orientation+ AImove.Y )
					'Case TurnToAngle
						'Orientation=AImove.y	
						
					Case RotateAroundCenter
						DidDraw=DrawPathSlice(BG, X+Origin.X,Y+ Origin.Y, R2, Radius, Distance, Color,FirstMove , Angle, AImove.Y, False, Stroke, False)  
						Angle=Trig.CorrectAngle(Angle+AImove.Y)
						If DidDraw Then FirstMove=False
					Case MoveTowardsCenter
						DidDraw=DrawAILine(BG,  X+Origin.X,Y+ Origin.Y , Radius, Distance, AImove.Y, Angle, FirstMove,Color, Stroke,temp=LastMove)
						Distance=Distance+(AImove.Y*0.01)
						If DidDraw Then FirstMove=False
					Case RotateWithSeconds
						DrawPathSlice(BG, X+Origin.X,Y+ Origin.Y, R2, Radius, Distance, Color,FirstMove , Angle, 30, False, Stroke, temp=LastMove)  
						FirstMove=False
					Case MoveToAngle
						temp3= Ship.Door*90
						'If Ship.Door=0 Then 
						'	temp3=0
						'Else
						'	temp3=Trig.ClosestAngle( Angle, AImove.Y)
						'End If
						DidDraw=DrawPathSlice(BG, X+Origin.X,Y+ Origin.Y, R2, Radius, Distance, Color,FirstMove , Angle,temp3, True, Stroke,False)  
						Angle=temp3
						If DidDraw Then FirstMove=False
						
					Case StopDrawing
						temp=Ship.AI.Size 
				End Select
			Next
		End If
End Sub
Sub DrawPathSlice(BG As Canvas, x As Int, Y As Int,R2 As Int,Radius As Int, Distance As Float,Color As Int, FirstMove As Boolean , Angle As Int,  Width As Int, Absolute As Boolean ,Stroke As Int ,LastMove As Boolean    )As Boolean 
	Dim Start As Int ,Finish As Int, Move As Int,dTemp As Int, Ret As Boolean 
	Start=Angle
	If Absolute Then 
		Finish=Width
	Else
		Finish=Trig.CorrectAngle( Angle+Width)
	End If
	Ret=True
	dTemp=Distance*Radius
	If FirstMove Then
		Move=6
		If Width>Move Then
			Start=Start+Move 
			DrawSegmentedCircle(BG, x,Y, R2, Color, dTemp,  Stroke, Array As Int(Start, Start+1, Start+2, Finish))
		Else If Width<-Move Then
			Start=Start-Move
			DrawSegmentedCircle(BG, x,Y, R2, Color, dTemp,  Stroke, Array As Int(Start, Start-1, Start-2, Finish))
		Else
			Ret = False
		End If
	Else
		DrawSegmentedCircle(BG, x,Y, R2, Color, dTemp,  Stroke, Array As Int(Start, Finish))
	End If
'	If LastMove Then
'		Move=Finish+1
'		X2=Trig.findXYangle(x,Y,dTemp, Move, True)
'		Y2=Trig.findXYangle(x,Y,dTemp, Move, False)
'		BG.DrawBitmapRotated(StarshipBMP, LCAR.SetRect(24,75, 6,12), LCAR.SetRect(X2,Y2,6,12), Move)
'	End If
	Return Ret
End Sub 
Sub DrawAILine(BG As Canvas, X As Int, Y As Int, Radius As Int, Distance As Float, Length As Int, Angle As Int, FirstMove As Boolean,Color As Int  ,Stroke As Int, LastMove As Boolean  ) As Boolean 
	Dim Start As Int, Finish As Int , Move As Int, dontdraw As Boolean ,temp As Rect 
	'Log("RADIUS: " & Radius)'225, 165
	If Not(FirstMove) And Radius< 225 Then Radius=Radius - ((225-Radius)*0.85)' (BorderThickness*0.5)
	Start=Distance*Radius 
	Finish=Start+(Length*0.01 * Radius)
	Move=15
	If FirstMove Then
		If Length<-Move Then'approaching center
			Start=Start-Move
		Else If Length>Move Then
			Start=Start+Move
		Else
			dontdraw=True
		End If
	End If
	If Not(dontdraw) Then
		temp= LCARSeffects.DrawLine(BG, X,Y,Angle,  Start, Finish, Color, Stroke)
		If FirstMove Then DrawSquare(BG, temp.Left,temp.Top, Angle, Stroke)
		If LastMove Then DrawSquare(BG, temp.Right,temp.Bottom, Angle, Stroke)
		Return True 
	End If
End Sub
Sub DrawSquare(Bg As Canvas, X As Int, Y As Int, Angle As Int, Stroke As Int)
	Dim Size As Int,Half As Int, temp As Rect 
	X=X-1
	Y=Y-1
	Size=Stroke*2'1.5
	Half=Size*0.5
	temp.Initialize(X-Half, Y-Half, X+Size,Y+Size)
	Bg.DrawRectRotated( temp ,Colors.black ,False, Stroke, Angle)
End Sub

Sub DrawworkBees(BG As Canvas,Xold As Int, Yold As Int, X As Int, Y As Int, Quantity As Int, UpX As Int, UpY As Int)
	Dim QT As Double 
	QT=Quantity*0.5
	DrawDots(BG,X+(UpX*QT), Y+(UpY*QT), Quantity, -UpX,-UpY)
End Sub
Sub DrawDots(BG As Canvas, X As Int, Y As Int, Quantity As Int, UpX As Int, UpY As Int)
	Dim temp As Int
	For temp = 1 To Quantity
		BG.DrawCircle(X,Y, 3, Colors.white, True, 0)
		X=X+UpX
		Y=Y+UpY
	Next
End Sub














'list: ColsLandscape holds # of layer 0 cells, ColsPortrait holds # of layer 1, 
'listitem: number and text hold the destinations, whitespace and colorid hold the current , sidetext holds the width, tag holds the index
Sub SetupAnalysis(Era As Int) As Boolean 
	Layer(3) = Era 
	Select Case Era
		Case LCAR.LCAR_TNG
			Layer(0)=80: LayerColors(0) = Colors.RGB(164,6,223) 'LCAR.GetColor(LCAR.LCAR_LightPurple,False,255)' LCAR.GetColor(LCAR.LCAR_Purple,False,255)
			Layer(1)=50: LayerColors(1) = LCAR.GetColor(LCAR.LCAR_Purple,False,255) 'LCAR.GetColor(LCAR.LCAR_DarkPurple,False,255)
			Layer(2)=25: LayerColors(2) = LCAR.GetColor(LCAR.LCAR_Yellow,False,255)
		Case LCAR.LCAR_TMP
			Layer(0)=50: LayerColors(0) = Colors.aRGB(96,255,255,255)
			Layer(1)=Layer(0): LayerColors(1) = LayerColors(0)
			Layer(2)=Layer(0): LayerColors(2) = LayerColors(0)
	End Select
End Sub

Sub SeedScanAnalysis(ListID As Int, Era As Int) As Boolean
	Dim temp As Int, temp2(3) As Int , Lists As LCARlist 
	If LCAR.LCARlists.Size <= ListID Then Return False 
	SetupAnalysis(Era)
	LCAR.LCAR_ClearList(ListID,0)
	For temp = 0 To 2
		temp2(temp)= SeedScanAnalysisLayer(ListID, temp)
		LayerCount(temp)=temp2(temp)
	Next
	Lists = LCAR.LCARlists.Get(ListID)
	Lists.ColsLandscape=temp2(0)
	Lists.ColsPortrait=temp2(1)
	Lists.ForcedMintCount=temp2(2)
	LCAR.LCARlists.Set(ListID, Lists)

	InitOvals
	IsAnalysisInit=True
	Return True
End Sub
Sub InitOvals
	Ovals(0).Initialize 
	Ovals(0).Desired= Rnd(10,91)
	Ovals(1).Initialize 
	Ovals(1).Desired= Rnd(10,91)
End Sub
Sub SeedScanAnalysisLayer(ListID As Int, LayerID As Int)As Int
	Dim Remaining As Int ,temp As Int 
	Remaining = Layer(LayerID)
	Do Until Remaining <= 5
		Remaining= AddSlice(ListID,LayerID, Remaining,temp)
		temp=temp+1
	Loop
	If Remaining>0 Then
		AddSlice(ListID,LayerID, Remaining,temp)
		temp=temp+1
	End If
	Return temp
End Sub
Sub AddSlice(ListID As Int, LayerID As Int,  Remaining As Int, Index As Int) As Int 
	Dim Slice As Int  
	If Remaining>0 Then
		If Remaining<=5 Then Slice= Remaining Else Slice =  Rnd(3,API.IIF(LCAR.LargeScreen,6, 11))
		'text=randomvalue, colorid=remaining, number=randomvalue, tag=index, side=width
		LCAR.LCAR_AddListItem(ListID,   RandomValue(LayerID,Remaining,Index),   Remaining,  RandomValue(LayerID,Remaining,Index),Index, False, Slice, 0, False, -1)
	End If
	Return Remaining-Slice
End Sub
Sub RandomValue(LayerID As Int, Remaining As Int, Index As Int) As Int'LayerCount
	Dim Mini As Int, Maxi As Int , Percent As Double ,Angle As Int ,Half As Int
	'Mini=Layer(LayerID)*0.1
	Maxi= Layer(LayerID)+1
	If LayerCount(LayerID)>0 Then
		'Method 1
		'Percent= (Mini+ (Layer(LayerID)-Remaining)) / Layer(LayerID)
		'Angle = Percent * 180
		'Maxi=Trig.findXYAngle(0,0, Maxi, Angle, True)
		
		'Method 2
'		Half=LayerCount(LayerID)*0.5
'		If Index<=Half Then
'			Percent= (Index+1)/Half
'		Else
'			Percent = (Half-(Index-Half))/Half
'		End If
'		If Percent<0.1 Then Percent = 0.1
'		Maxi = Percent*Maxi
		
		'Method 3
		Half=Layer(LayerID)*0.5
		Angle=Layer(LayerID)-Remaining
		If Angle<=Half Then
			Percent= Angle/Half
		Else
			Percent = (Half-(Angle-Half))/Half
		End If
		Maxi = Percent*Maxi

		Mini=Maxi*0.5
	End If
	
	If Maxi < Mini+10 Then Maxi = Mini+10
	Return  Rnd(Mini, Maxi) 
End Sub
Sub IncrementAnalysisList(Lists As LCARlist, SpeedSlider As Int )
	Dim temp As Int ,ListItem As LCARlistitem , CurrentLayer As Int, Remaining As Int = Layer(0),Index As Int
	
	For temp = 0 To Lists.ListItems.Size-1
		ListItem = Lists.ListItems.Get(temp)
		ListItem.WhiteSpace= LCAR.Increment(ListItem.WhiteSpace,SpeedSlider,ListItem.Number)	
		If ListItem.Number = ListItem.WhiteSpace Then ListItem.Number = RandomValue(CurrentLayer, Remaining ,Index )'RandomValue(CurrentLayer, ListItem.ColorID ,ListItem.Tag )
		ListItem.ColorID = LCAR.Increment(ListItem.ColorID,SpeedSlider,ListItem.Text)	
		If ListItem.ColorID = ListItem.Text Then ListItem.Text = RandomValue(CurrentLayer, Remaining ,Index )' RandomValue(CurrentLayer, ListItem.ColorID,ListItem.Tag )
		Lists.ListItems.Set(temp,ListItem)
		
		Remaining= Remaining- ListItem.Side 
		Index=Index+1
		If Remaining<1 Then
			Index=0
			CurrentLayer=CurrentLayer+1
			If CurrentLayer<3 Then Remaining= Layer(CurrentLayer)
		End If
	Next
	
	TweenOval(0,SpeedSlider)
	TweenOval(1,SpeedSlider)
End Sub
Sub TweenOval(Index As Int, SpeedSlider As Int )
	Ovals(Index).Current  = LCAR.Increment(Ovals(Index).Current, SpeedSlider, Ovals(Index).Desired)
	If Ovals(Index).Current = Ovals(Index).Desired Then Ovals(Index).Desired = Rnd(10,91)
End Sub

Sub DrawAnalysis(BG As Canvas,  Lists As LCARlist, X As Int, Y As Int, Width As Int, Height As Int, ListID As Int)
	Dim temp As Int , temp2 As Int, temp3 As Int, ListItem As LCARlistitem , CurrentLayer As Int, Remaining As Int ,Hor As Boolean , CenterX As Int, CenterY As Int 
	If Not(IsAnalysisInit) Then 
		SeedScanAnalysis(ListID, LCAR.CurrentStyle)
		Return
	End If
	
	CenterX= X + (Width/2)
	CenterY= Y+ (Height/2)
	
	Remaining= Layer(0)
	temp2=X+ ( ( (100-Remaining) *0.005 ) * Width )
	For temp = 0 To Lists.ListItems.Size-1
		ListItem = Lists.ListItems.Get(temp)
		'temp3=ListItem.Side * 0.01 * API.IIF(Hor, Height,Width)
		'DrawSlice(BG, X,Y, Width,Height,CenterX ,CenterY, CurrentLayer,  temp2, temp3, ListItem.WhiteSpace, ListItem.ColorID, Hor)		
		temp3=DrawSliceItem(BG, X,Y, Width,Height,CenterX ,CenterY, CurrentLayer, temp2, ListItem,  Hor)
		
		temp2=temp2+temp3-1
		Remaining= Remaining- ListItem.Side 
		If Remaining<1 Then
			CurrentLayer=CurrentLayer+1
			If CurrentLayer<3 Then 
				Hor=Not(Hor)
				Remaining= Layer(CurrentLayer)
				If Hor Then
					temp2= ( ( (100-Remaining) *0.005 ) *  Height ) + Y
				Else
					temp2= ( ( (100-Remaining) *0.005 ) *  Width  ) + X
				End If
			End If
		End If
	Next
	
	DrawBIGBrackets(BG,X,Y,Width,Height, Layer(0), Layer(3))
End Sub

Sub DrawBIGBrackets(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, WidthOfBrackets As Int, Era As Int)
	Dim temp As Int = Min(Width,Height)*0.1, temp2 As Int, temp3 As Int 
	DrawCrossLines(BG,X,Y,Width,Height, temp,temp*0.5, LCAR.GetColor(LCAR.LCAR_LightBlue ,False,255), 1)
	
	temp=Width * (100-WidthOfBrackets) * 0.005
	If Width>Height Then
		temp2=Height*0.05
	Else
		temp2=Height/6
	End If
	
	temp3=Height- temp2*2

	DrawBracket(BG, X+temp, Y+temp2, 30, temp3, True, True, Era)
	DrawBracket(BG, X+Width-temp-30, Y+temp2, 30,temp3, False, True, Era)
End Sub
Sub DrawSliceItem(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int,CenterX As Int, CenterY As Int, LayerID As Int, Pos As Int, ListItem As LCARlistitem, Horizontal As Boolean )As Int 
	Dim SliceSize As Int , SliceA As Double, SliceB As Double ,SliceSize2 As Int , SliceOrigin As Int ,Color As Int ', MaxSlice As Double  = Layer(LayerID) * 0.01
	'temp3=ListItem.Side * 0.01 * API.IIF(Hor, Height,Width)
	'DrawSlice(BG, X,Y, Width,Height,CenterX ,CenterY, CurrentLayer,  temp2, temp3, ListItem.WhiteSpace, ListItem.ColorID, Hor)		
	SliceA= ListItem.WhiteSpace * 0.01 '* MaxSlice
	SliceB= ListItem.ColorID * 0.01 '* MaxSlice
	Color=LayerColors(LayerID)
	If LCAR.RedAlert And Layer(3) = LCAR.LCAR_TNG Then
		Color = LCAR.GetColor(LCAR.lcar_orange, LayerID=1,255)
	End If
	
	If Horizontal Then'---
		SliceSize = ListItem.Side * 0.01 * Height
		SliceSize2 = Width * ((SliceA+SliceB)*0.5)
		SliceOrigin= CenterX - ((SliceA*0.5)*Width)
		''BG.DrawRect(  LCAR.SetRect(Pos,SliceOrigin, SliceSize,SliceSize2), LayerColors(LayerID), True, 0)
		BG.DrawRect(  LCAR.SetRect(SliceOrigin, Pos, SliceSize2,  SliceSize),Color , True, 0)
	Else'|||
		SliceSize = ListItem.Side * 0.01 * Width 'this is the width of the slice
		
		SliceSize2 = Height * ((SliceA+SliceB) * 0.5)'this is the height of the slice
		SliceOrigin= CenterY - ((SliceA*0.5)*Height)
		BG.DrawRect(  LCAR.SetRect(Pos,SliceOrigin, SliceSize,SliceSize2), Color, True, 0)
		'BG.DrawRect(  LCAR.SetRect(SliceOrigin, Pos, SliceSize2,  SliceSize), LayerColors(LayerID), True, 0)
	End If
	Return SliceSize
End Sub



'spacing = space between line segments that stick out from the lines, size = size of the line segments
Sub DrawCrossLines(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, Spacing As Int , Size As Int,Color As Int,Stroke As Int )
	Dim temp As Int ,CenterX As Int ,CenterY As Int,DoX As Boolean ,DoY As Boolean 
	CenterY=Y+(Height*0.5)
	CenterX=X+(Width*0.5)
	
	DoX=Spacing>0
	If Not (DoX) Then Spacing=Abs(Spacing)
	DoY=Stroke>0
	If Not (DoY) Then Stroke=Abs(Stroke)
	
	If DoX Then 
		BG.DrawLine(X ,CenterY, X+Width, CenterY, Color, Stroke)
		For temp = CenterX To X+Width Step Spacing
			BG.DrawLine(temp,CenterY,temp,CenterY+Size, Color, Stroke)
		Next
		For temp = CenterX-Spacing To X Step -Spacing
			BG.DrawLine(temp,CenterY,temp,CenterY+Size, Color, Stroke)
		Next
	End If
	
	If DoY Then
		BG.DrawLine(CenterX,Y, CenterX,Y+Height, Color, Stroke)
		For temp = CenterY-Spacing To Y Step -Spacing
			BG.DrawLine(CenterX,temp, CenterX+Size, temp, Color, Stroke)
		Next
		For temp = CenterY To Y+Height Step Spacing
			BG.DrawLine(CenterX,temp, CenterX+Size, temp, Color, Stroke)
		Next
	End If
End Sub

Sub DrawRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, StartY As Int, IncY As Int, Side As Int, Stroke As Int, Number As Int,CenterY As Int, State As Boolean)As Int
	Dim temp As Int ,Color As Int,FontColor As Int
	'CenterY=Y+ (Height*0.5)
	Color=LCAR.GetColor(ColorID, State, 255)
	BG.DrawRect( LCAR.SetRect(X,Y,Width,Height), Color, True, 0)
	If StartY>-1 Then
		For temp = StartY+1 To Y+Height Step IncY
			If temp>=Y Then
				FontColor = LCAR.LCAR_LightPurple 
				If temp > CenterY-IncY And temp < CenterY+IncY Then FontColor = LCAR.LCAR_Orange 
				If Side<0 Then
					BG.DrawLine(X+Side,temp, X,temp, Color, Stroke)
					'LCAR.DrawText(BG, X+Side,temp, API.IIF(Number<100, "0", "") & Number, FontColor, 6, False, 255,0)
					If Number>-1 Then LCAR.DrawTextbox(BG, API.IIF(Number<100, "0", "") & Number, FontColor,X+Side,temp, 0, 0,  6)
				Else
					BG.DrawLine(X+Width,temp, X+Width+Side,temp,Color,Stroke)
					'LCAR.DrawText(BG, X+Width+Side,temp, Number, FontColor, 4, False, 255,0)
					If Number>-1 Then LCAR.DrawTextbox(BG, Number, FontColor,X+Width+Side,temp, 0, 0,  4)
				End If
				If Number>-1 Then Number=Number+10
			End If
		Next
	End If
	Return Number
End Sub

Sub DrawBracketS(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, LeftSide As Boolean)As Boolean 
	Dim Fifth As Int=Height*0.20 ,WhiteSpace As Int=2 ,BarWidth As Int=2 , White As Int=Colors.White, Purple As Int =LCAR.GetColor(LCAR.LCAR_Purple,False,255),X2 As Int, Radius As Int=8,temp As Int 

	LCAR.ActivateAA(BG,True)
	BG.DrawRect(LCAR.SetRect(X,Y,Width,Fifth), White, True,0)'top
	temp=Fifth-BarWidth-WhiteSpace
	If LeftSide Then
		LCARSeffects.DrawPartOfCircle(BG,X-Radius+1,Y-Radius+1, Radius, 0, White , 0,0)'top left curve
		BG.DrawRect(LCAR.SetRect(X,Y-Radius+1, Width*2, Radius), White,True, 0)'top horizontal bar
		BG.DrawRect(LCAR.SetRect(X-Radius+1, Y, Radius, temp), White,True,0)'top vertical bar
		
		LCARSeffects.DrawPartOfCircle(BG,X-Radius+1,Y+Height-2, Radius, 2, White , 0,0)'bottom left curve
		BG.DrawRect(LCAR.SetRect(X,Y+Height-1, Width*2, Radius), White,True, 0)'bottom horizontal bar
		BG.DrawRect(LCAR.SetRect(X-Radius+1, Y+Height-temp-1, Radius, temp+1),White ,True,0)'bottom vertical bar
		
		X2=X-BarWidth*3
	Else
		LCARSeffects.DrawPartOfCircle(BG,X+Width-1,Y-Radius+1, Radius, 1, White , 0,0)'top left curve
		BG.DrawRect(LCAR.SetRect(X-Width,Y-Radius+1, Width*2, Radius), White,True, 0)'top horizontal bar
		BG.DrawRect(LCAR.SetRect(X+Width-1, Y, Radius, temp), White,True,0)'top vertical bar
		
		LCARSeffects.DrawPartOfCircle(BG,X+Width-1,Y+Height-2, Radius, 3, White , 0,0)'bottom left curve
		BG.DrawRect(LCAR.SetRect(X-Width,Y+Height-1, Width*2, Radius), White,True, 0)'bottom horizontal bar
		BG.DrawRect(LCAR.SetRect(X+Width-1, Y+Height-temp-1, Radius, temp+1),White ,True,0)'bottom vertical bar
		
		X2=X+Width+ BarWidth *2
	End If
	BG.DrawLine(X2, Y+Fifth-BarWidth, X2, Y+Height-Fifth-BarWidth+WhiteSpace, White,BarWidth*2)
	
	BG.DrawRect(LCAR.SetRect(X,Y+Fifth+WhiteSpace,Width,Fifth-WhiteSpace), Purple, True,0)'top purple
	BG.DrawRect(LCAR.SetRect(X,Y+Height*0.5-Fifth*0.5,Width,Fifth), White, True,0)'middle
	BG.DrawRect(LCAR.SetRect(X,Y+Height*0.5+Fifth*0.5+WhiteSpace,Width,Fifth-WhiteSpace), Purple, True,0)'bottom purple
	
	BG.DrawRect(LCAR.SetRect(X,Y+Height-Fifth,Width,Fifth), White, True,0)'bottom
	LCAR.ActivateAA(BG,False)
	Return False
End Sub

Sub DrawSmallBracket(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, LeftSide As Boolean) As Boolean
	Dim WhiteSpace As Int=2, Color As Int = Colors.RGB(188, 64,75),X2 As Int, temp As Int = Width/2'Fifth As Int=Height*0.20 ,BarWidth As Int=2 ,
	Dim X2 As Int, X3 As Int ,Width2 As Int = temp*0.5,Width3 As Int = Width2-WhiteSpace, Width4 As Int = temp-Width3-WhiteSpace
	If LeftSide Then
		LCAR.DrawCircle2(BG,X,Y, temp, temp, 1, Color, False)
		LCARSeffects4.DrawRect(BG, X+ temp, Y, temp, Width2, Color,0)
		
		LCAR.DrawCircle2(BG,X,Y+Height-temp, temp, temp, 7, Color, False)
		LCARSeffects4.DrawRect(BG, X+ temp, Y+Height-Width2, temp, Width2, Color,0)
		
		X2=X
		X3=X+temp-Width3+1
	Else
		LCAR.DrawCircle2(BG,X+temp,Y, temp, temp, 3, Color, False)
		LCARSeffects4.DrawRect(BG, X, Y, temp, Width2, Color,0)
	
		LCAR.DrawCircle2(BG,X+ temp,Y+Height-temp, temp, temp, 9, Color, False)
		LCARSeffects4.DrawRect(BG, X, Y+Height-Width2, temp, Width2, Color,0)
		
		X2=X+Width-Width4-1'temp+Width2+WhiteSpace
		X3=X+temp
	End If
	
	'x2=big outer, x3=small inner
	LCARSeffects4.DrawRect(BG, X3, Y+temp, Width3, temp, Color, 0)
	LCARSeffects4.DrawRect(BG, X3, Y+Height-temp*2, Width3, temp, Color , 0)
	
	LCARSeffects4.DrawRect(BG, X2, Y + temp+WhiteSpace+1, Width4, Height/2 - temp-WhiteSpace-1, Color ,0)
	LCARSeffects4.DrawRect(BG, X2, Y + Height/2 + WhiteSpace, Width4, temp, Color, 0)
	LCARSeffects4.DrawRect(BG, X2, Y + Height/2 + WhiteSpace*2+temp,Width4, Height/2 - temp*2 -WhiteSpace *3, Color,0)
	Return False
End Sub
Sub DrawBracket(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, LeftSide As Boolean, DoNumbers As Boolean, Era As Int) As Boolean 
	Dim CurveHeight As Int, MidW As Int ,Bottom As Int, StartSize As Int=20, tempHeight As Int,tempY As Int ,temp As Int, WhiteSpace As Int,temp2 As Int,tempY2 As Int,Inc As Int,tempHeight2 As Int
	Dim Stroke As Int=2,Size As Int=3,Number As Int=-1,CenterY As Int, OvalLeft As Int, OvalTop As Int,OvalHeight As Int,OvalWidth As Int, MinHeight As Int=300
	Dim Orange As Int, DarkOrange As Int, DarkPurple As Int, LightBlue As Int, State1 As Boolean, State2 As Boolean, Number2 As Int 
	If Height<MinHeight Then Return DrawSmallBracket(BG,X,Y,Width,Height,LeftSide)'remove OR TRUE

	CenterY=Y+Height*0.5
	CurveHeight=Width*2
	Bottom=Y+Height-1
	OvalHeight=StartSize
	OvalWidth=OvalHeight*2
	
	If Era = LCAR.LCAR_TNG Then  
		Orange = LCAR.LCAR_Orange
		DarkPurple = LCAR.LCAR_DarkPurple
		LightBlue = LCAR.LCAR_LightBlue
		DarkOrange = LCAR.LCAR_DarkOrange
		If DoNumbers Then Number=10
	Else 
		Orange = LCAR.Classic_Green
		DarkPurple = Orange
		LightBlue = Orange 
		DarkOrange = Orange 
		State2 = True
		DoNumbers = False 
	End If 
	temp=LCAR.GetColor(Orange,False,255)
	
	temp2=CurveHeight-Width
	LCAR.ActivateAA(BG,True)
	If LeftSide Then
		MidW=X+CurveHeight
		LCARSeffects.DrawCircleSegment(BG, MidW,Y+CurveHeight,  temp2,CurveHeight,270,90, temp, 0,0,0)'top curve
		DrawRect(BG, MidW,Y,StartSize*0.5, temp2, Orange,-1,0,0,0, 0,0, State1)
		
		LCARSeffects.DrawCircleSegment(BG,  MidW,Y+Height-CurveHeight-2 , temp2, CurveHeight,180,90, temp, 0,0,0)'bottom curve
		
		DrawRect(BG, MidW,Y+Height-temp2-1,StartSize*0.5, temp2, Orange,-1,0,0,0, 0,0, State1)
		
		OvalLeft=X+Width+WhiteSpace
		OvalTop=Ovals(0).Current 
	Else
		MidW=X-CurveHeight+Width-1
		LCARSeffects.DrawCircleSegment(BG, MidW,Y+CurveHeight,  temp2,CurveHeight,0,90, temp, 0,0,0)'top curve
		DrawRect(BG, MidW-StartSize*0.5+1,Y,StartSize*0.5, temp2, Orange ,-1,0,0,0, 0,0, State1)
		
		LCARSeffects.DrawCircleSegment(BG, MidW,Y+Height-CurveHeight-2, temp2,CurveHeight,90,90, temp, 0,0,0)'bottom curve
		DrawRect(BG, MidW-StartSize*0.5+1,Y+Height-temp2-1,StartSize*0.5, temp2, Orange ,-1,0,0,0, 0,0, State1)
		
		OvalLeft=X-WhiteSpace-OvalWidth
		OvalTop=Ovals(1).Current
	End If

	WhiteSpace=3
	MidW=(Width-WhiteSpace) *0.5
	tempY=Y+ CurveHeight + StartSize*2 + WhiteSpace
	tempY2=tempY-StartSize
	
	tempHeight=Height- (CurveHeight*2)  - (WhiteSpace *2) - StartSize
	'If LeftSide Then OvalTop=100 Else OvalTop=0
	
	If Era = LCAR.LCAR_TMP Then 
		OvalTop=tempY2 + ( tempHeight * OvalTop * 0.01) - OvalHeight*0.5
		If LeftSide Then 
			temp = X - OvalWidth - 2 
			Inc= 3
		Else 
			temp = X + Width + 2
			Inc = 2
		End If 
		LCARSeffects.DrawTriangle(BG, temp, OvalTop - OvalWidth*0.25, OvalWidth,OvalWidth * 0.5, Inc , LCAR.GetColor(LCAR.LCAR_LightBlue, False, 255))
	else If DoNumbers Then
		OvalTop=tempY2 + ( tempHeight * OvalTop * 0.01) - OvalHeight*0.5
		BG.DrawOval( LCAR.SetRect( OvalLeft,OvalTop, OvalWidth,OvalHeight), Colors.white,True,0)
	End If 
	
	tempHeight=tempHeight - (StartSize*3)
	
	temp=tempHeight*0.2
	
	tempHeight2=tempHeight+(StartSize*2)
	Inc=tempHeight2*0.1
	
	LCAR.ActivateAA(BG,False)
	
	'top
	DrawRect(BG, X, Y+CurveHeight, Width, StartSize, Orange, -1,0,0,0, 0,0, State1)
	
	If Height>MinHeight Then
		DrawRect(BG, X+MidW+WhiteSpace+1, Y+CurveHeight+StartSize-1, MidW, StartSize, Orange, -1,0,0,0, 0,0, State1)
		If LeftSide Then'right-side smaller boxes
			DrawRect(BG, X+MidW+WhiteSpace+1, tempY, MidW, temp, DarkPurple , -1, 0,0,0, 0,0, State2)
			DrawRect(BG, X+MidW+WhiteSpace+1, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), LightBlue, -1, 0,0,0, 0,0, State2)
			DrawRect(BG, X+MidW+WhiteSpace+1, tempY+tempHeight-temp, MidW, temp, Orange , -1, 0,0,0, 0,0, State1)
			If Era = LCAR.LCAR_TMP Then DrawNumbers(BG, X+MidW*2+WhiteSpace+2, tempY+temp+WhiteSpace, tempHeight- WhiteSpace - (temp*2), "LEFT", 10, 10, Orange)
		Else'should get notched
			Number=DrawRect(BG, X+MidW+WhiteSpace+1, tempY, MidW, temp, Orange , tempY2, Inc,Size,Stroke, Number,CenterY, State1)
			Number=DrawRect(BG, X+MidW+WhiteSpace+1, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), DarkOrange, tempY2, Inc,Size,Stroke, Number,CenterY, State2)
			Number=DrawRect(BG, X+MidW+WhiteSpace+1, tempY+tempHeight-temp, MidW, temp, Orange , tempY2, Inc,Size,Stroke, Number,CenterY, State1)
			If Era = LCAR.LCAR_TMP Then DrawNumbers(BG, X-MidW-2, tempY+temp+WhiteSpace, tempHeight- WhiteSpace - (temp*2), "RIGHT", 100, 100, Orange)
		End If
	Else
		tempY=CurveHeight+StartSize-1
		DrawRect(BG, X, Y+ tempY, Width, (Height/2-tempY+1)*2, Orange, -1,0,0,0, 0,0, State1)
	End If
	
	tempHeight=tempHeight2'tempHeight+(StartSize*2)
	tempY=tempY2
	temp=tempHeight*0.3333
	
	If Height>MinHeight Then
		If LeftSide Then'left-side bigger boxes should get notched
			Number=DrawRect(BG, X, tempY, MidW, temp, Orange , tempY2, Inc,-Size,Stroke, Number,CenterY, State1)
			Number=DrawRect(BG, X, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), Orange , tempY2,Inc,-Size,Stroke, Number,CenterY, State1)
			Number=DrawRect(BG, X, tempY+tempHeight-temp, MidW, temp, Orange , tempY2,Inc,-Size,Stroke, Number,CenterY, State1)
			'If Era = LCAR.LCAR_TMP Then LCARSeffects4.DrawRect(BG, X+MidW+2, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), Colors.red, 2)
		Else
			DrawRect(BG, X, tempY, MidW, temp, DarkPurple, -1, 0,0,0, 0,0, State2)
			DrawRect(BG, X, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), LightBlue , -1, 0,0,0, 0,0, State2)
			DrawRect(BG, X, tempY+tempHeight-temp, MidW, temp, DarkPurple, -1, 0,0,0, 0,0, State2)
			'If Era = LCAR.LCAR_TMP Then LCARSeffects4.DrawRect(BG, X-MidW-2, tempY+temp+WhiteSpace, MidW, tempHeight- (WhiteSpace*2) - (temp*2), Colors.red, 2)
		End If
		DrawRect(BG, X+MidW+WhiteSpace+1, Bottom-CurveHeight-(StartSize*2)+1, MidW, StartSize, Orange, -1,0,0,0, 0,0, State1)
	'Else
		'DrawRect(BG, X, Bottom-CurveHeight-(StartSize*2)+1, Width, StartSize, Orange, -1,0,0,0, 0,0)
	End If
	
	'bottom
	DrawRect(BG, X, Bottom-CurveHeight-StartSize, Width, StartSize, Orange, -1,0,0,0, 0,0, State1)
	Return True
End Sub

Sub DrawNumbers(BG As Canvas, X As Int, Y As Int, Height As Int, Align As String, Number As Int, Inc As Int, ColorID As Int)
	Dim Lines As Int = 6, LineHeight As Int = Height / Lines, TextSize As Int = API.GetTextHeight(BG,LineHeight*0.5,"012", StarshipFont), TextHeight As Int = BG.MeasureStringHeight("012", StarshipFont, TextSize), Color As Int = LCAR.GetColor(ColorID, False, 255)
	y = y + LineHeight * 0.5 + TextHeight * 0.5
	Do Until Lines = 0
		BG.DrawText( API.PadtoLength(Number, True, 3, "0"), X, Y, StarshipFont, TextSize, Color, Align)
		y = y + LineHeight
		Lines = Lines - 1 
		Number = Number + Inc 
	Loop
End Sub

Sub DrawEnterprise(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Int, Color As Int) As Rect 
	Dim iW As Int, iH As Int, Width2 As Int ,Dest As Rect ,DestP As Point , Orange As Int,HalfTextHeight As Int ,TextSize As Int ,Stroke As Int, Half As Float 
	Select Case Align
		Case 0'both
			Dim Text As List = API.getstrings("no1_",0)
			Orange=LCAR.GetColor(LCAR.LCAR_Orange, False,255)
			TextSize=LCAR.GetTextHeight(BG, Height*0.018, "TEST") '10
			Stroke=1
			Half = 0.46
			LCAR.ActivateAA(BG,True)
			'Log("X: " & X & " Y: " & Y & " WIDTH: " & Width & " HEIGHT: " & Height)
			iW=Width/2
			iH=Height/3
			Dest = DrawEnterprise(BG, X,Y+iH,Width,iH*2, 2, Color)	'bottom, top view	
			HalfTextHeight= BG.MeasureStringHeight("TEST", LCAR.LCARfont, TextSize) * 0.5' LCAR.TextHeight(BG, "TEST") * 0.5
			
			'right text
			DrawLabel(BG,Dest, 0.532, 0.463, -0.5, Orange , Stroke, Text.Get(0), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'-0.037
			DrawLabel(BG,Dest, 0.62, 0.181, -0.1, Orange,  Stroke, Text.Get(1),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.081
			DestP=DrawLabel(BG,Dest, 0.667, 0.5, -0.35, Orange,  Stroke, Text.Get(2),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.15
			LCAR.DrawLCARtextbox(BG,DestP.X, DestP.Y + HalfTextHeight*3,0,0,0,0,  Text.Get(3), LCAR.LCAR_LightBlue, 0,0,False,False,0,255)
			DestP=DrawLabel(BG,Dest, 0.679, 0.525, 0.3, Orange, Stroke, Text.Get(4),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.825
			LCAR.DrawLCARtextbox(BG,DestP.X, DestP.Y - HalfTextHeight*11,0,0,0,0,  Text.Get(5), LCAR.LCAR_LightBlue, 0,0,False,False,7,255)
			DrawLabel(BG,Dest, 0.46, 0.751, 0.25, Orange, Stroke, Text.Get(6),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'1.001
			
			'left text
			DrawLabel(BG,Dest, 0.426, 0.356,-0.393, Orange,Stroke, Text.Get(7),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'-0.037
			DrawLabel(BG,Dest, 0.397, 0.435,-0.354, Orange,Stroke,Text.Get(8),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.081
			DrawLabel(BG,Dest,0.325, 0.463,-0.313, Orange, Stroke, Text.Get(9),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.15
			DrawLabel(BG,Dest,0.156, 0.322, 0, Orange,Stroke, Text.Get(10), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.322
			DrawLabel(BG,Dest, 0.08, 0.458,-0.05, Orange,Stroke, Text.Get(11), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.408
			DrawLabel(BG,Dest, 0.089, 0.5,0, Orange,Stroke, Text.Get(12), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half) '0.5
			DrawLabel(BG,Dest, 0.08, 0.542,0.05, Orange,Stroke, Text.Get(13), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0592
			DrawLabel(BG,Dest, 0.093, 0.746, 0.06, Orange,Stroke, Text.Get(14), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.806
			DrawLabel(BG,Dest, 0.169, 0.774, 0.06, Orange,Stroke, Text.Get(15), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.834 (0.028)
			DrawLabel(BG,Dest, 0.295, 0.785, 0.077, Orange,Stroke, Text.Get(16), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.862
			DrawLabel(BG,Dest, 0.371, 0.757, 0.133, Orange,Stroke, Text.Get(17), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.89
			DrawLabel(BG,Dest, 0.397, 0.554, 0.364, Orange,Stroke, Text.Get(18), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.918
			
			Width2= Dest.Right-Dest.Left 
			Dest = DrawEnterprise(BG, X+iW - Width2/2,Y,Width2,iH, 1, Color)'top, side view, limited to width of top view
			Half=0.39
			
			'right text
			DrawLabel(BG,Dest, 0.675, 0,  -0.05  ,Orange,Stroke, Text.Get(19), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'-0.05
			DrawLabel(BG,Dest, 0.848, 0.132, -0.01, Orange,Stroke, Text.Get(20), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)' 0.122 (0.172)
			DrawLabel(BG,Dest, 0.823, 0.321, -0.027, Orange,Stroke, Text.Get(21), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.294 (0.172)
			DrawLabel(BG,Dest, 0.7, 0.434, 0.032 , Orange,Stroke, Text.Get(22), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.466 (0.172)
			DrawLabel(BG,Dest, 0.506, 0.585, 0.053 ,Orange,Stroke, Text.Get(23),LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.638 (0.172)
			DrawLabel(BG,Dest, 0.489, 0.774, 0.036 ,Orange,Stroke, Text.Get(24), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.81 (0.172)
			DrawLabel(BG,Dest, 0.392, 0.962, 0.02,Orange,Stroke, Text.Get(25), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.982 (0.172)
			
			'left text
			DrawLabel(BG,Dest,0.363, 0.453,  -0.503    ,Orange,Stroke, Text.Get(26), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'-0.05
			DrawLabel(BG,Dest,0.295, 0.491,  -0.369    ,Orange,Stroke,Text.Get(27), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)' 0.122 (0.172)
			DrawLabel(BG,Dest,0.084, 0.434,  -0.14    ,Orange,Stroke,Text.Get(28), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.294 (0.172)
			DrawLabel(BG,Dest,0.072, 0.792,  0.018    ,Orange,Stroke,Text.Get(29), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.81 
			DrawLabel(BG,Dest,0.131, 0.849,  0.133   ,Orange,Stroke,Text.Get(29), LCAR.LCAR_LightBlue,HalfTextHeight,TextSize,Half)'0.982 (0.172)
			
			LCAR.ActivateAA(BG,False)
		Case 1'side
			Return LCARSeffects.DrawEnterpriseD(BG,X,Y,Width,Height, Color, 3)'Don't ask
		Case 2'top
			Return LCARSeffects.DrawEnterpriseD(BG,X,Y,Width,Height, Color, 2)'Don't ask
	End Select
End Sub

Sub DrawLabel(BG As Canvas, Dest As Rect, X As Float, Y As Float, Height As Float, Color As Int,Stroke As Int, Text As String , TextColorID As Int,HalfTextHeight As Int,TextSize As Int, Half As Float  )As Point 
	Dim DestWidth As Int = Dest.Right - Dest.Left , DestHeight As Int = Dest.Bottom-Dest.Top , DestP As Point ,CurveHeight As Int=3,Align As Int ', CurveHeightF As Float
	'If Height<> 0 Then CurveHeightF=CurveHeight/DestHeight
	If X < Half Then'Go left
		If Height=0 Then
			DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight,X,Y, 0,Y, Color, Stroke,True, 0, Half)
		Else 'If Height<0 Then ' go up
			DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight,X,Y, X,Y+Height, Color, Stroke,True,CurveHeight, Half)
			DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight, DestP.X, DestP.Y, 0,0, Color, Stroke,False,0, Half)
		'Else 'height>0 go down
			'DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight,X,Y, X,Y+Height, Color, Stroke,True,CurveHeight)
		End If
		'If Height<>0 Then DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight, DestP.X, DestP.Y, 0,0, Color, Stroke,False,0)
		Align=3
		DestP.X=DestP.X-CurveHeight
	Else'go right
		'If Height < 0 Then' go up
		'	DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight,X,Y, X,Y-Height, Color, Stroke,True,CurveHeight)
		'Else 'height>0 go down
			DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight,X,Y, X,Y+Height, Color, Stroke,True,CurveHeight, Half)
		'End If
		DestP = DrawEntLine(BG, Dest.Left, Dest.Top,DestWidth,DestHeight, DestP.X, DestP.Y, 1,0, Color, Stroke,False,0, Half)
		Align=1
		DestP.X=DestP.X+CurveHeight
		'LCAR.DrawText(BG, DestP.X, DestP.Y, Text, TextColorID, 4, False, 255, 0)
	End If
	'LCAR.DrawText(BG, DestP.X, DestP.Y, Text, TextColorID, Align, False, 255, 0)
	'LCAR.DrawTextbox(BG, Text.Replace("%n", CRLF),TextColorID, DestP.X, DestP.Y-HalfTextHeight, 0, LCAR.LCARfontheight, Align)
	
	If Text.Length > 0 Then 
		If Text = "[BLOCK]" Then 
			BG.DrawLine(DestP.X-3, DestP.Y, HalfTextHeight + TextSize, DestP.Y, Color, Stroke) 
			If Height < 0 Then 'below
				LCARSeffects4.DrawRect(BG, HalfTextHeight + TextSize- TextColorID, DestP.Y, TextColorID, Stroke*3, Color, 0)
				DrawNumberBlock(BG,HalfTextHeight + TextSize- TextColorID, DestP.Y+Stroke*3+2, TextColorID, Stroke*20, LCAR.LCAR_Orange,  LCARSeffects5.WF_RND_ID, LCAR.LCAR_WarpField, "")
			Else'above
				LCARSeffects4.DrawRect(BG, HalfTextHeight + TextSize- TextColorID, DestP.Y-Stroke*3, TextColorID, Stroke*3, Color, 0)
				DrawNumberBlock(BG,HalfTextHeight + TextSize- TextColorID, DestP.Y-Stroke*23-2, TextColorID, Stroke*20, LCAR.LCAR_Orange,  LCARSeffects5.WF_RND_ID, LCAR.LCAR_WarpField, "")
			End If 
			LCARSeffects5.WF_RND_ID = LCARSeffects5.WF_RND_ID + 1
		Else 
			DestP.Y=DestP.Y-HalfTextHeight
			LCAR.DrawLCARtextbox(BG, DestP.X, DestP.Y, 0,TextSize, 0,0, Text, TextColorID, 0,0, False,False, Align, 255)
		End If 
	End If
	Return DestP
End Sub
Sub DrawEntLine(BG As Canvas, DestLeft As Int,DestTop As Int, DestWidth As Int, DestHeight As Int, X1 As Float, Y1 As Float, X2 As Float, Y2 As Float, Color As Int, Stroke As Int, UseFloats As Boolean,CurveHeight As Int ,Half As Float  )As Point 
	 Dim Dest As Point, Left As Int, Right As Int, GoLeft As Boolean 
	 If UseFloats Then
	 	Left=DestLeft + DestWidth*X1
		If Y1=Y2 Then 
			Right = DestLeft + DestWidth*X2
		Else
			Right=Left
		End If
		GoLeft=X1<Half
	 	Dest = Trig.SetPoint(Right, DestTop + DestHeight*Y2)
	 	BG.DrawLine(Left, DestTop + DestHeight*Y1, Dest.x, Dest.Y, Color, Stroke)
		If CurveHeight>0 Then Dest=DrawEndCurve(BG, Dest,  Y2<Y1,GoLeft, CurveHeight, Color,Stroke) 'draw curve
	Else
		If X2=0 Then 
			Dest = Trig.SetPoint(DestLeft, Y1)'DestTop + Y2)
		Else
			Dest = Trig.SetPoint(DestLeft + DestWidth, Y1)'DestTop + Y2)
		End If
		BG.DrawLine(X1,Y1, Dest.x, Dest.Y, Color, Stroke)
	End If
	Return Dest
End Sub
Sub DrawEndCurve(BG As Canvas, Src As Point, Up As Boolean, Left As Boolean , CurveHeight As Int, Color As Int, Stroke As Int) As Point 
	Dim dest As Point, DestY As Int ', DestX As Int,
	If Up Then
		DestY=Src.Y-CurveHeight
	Else
		DestY=Src.Y+CurveHeight
	End If
	If Left Then
		dest=Trig.SetPoint(Src.X-CurveHeight,DestY)
		BG.DrawLine(dest.X,dest.Y, Src.X, Src.Y, Color,Stroke)
	Else
		dest=Trig.SetPoint(Src.X+CurveHeight,DestY)
		BG.DrawLine(Src.X, Src.Y, dest.X,dest.Y, Color,Stroke)
	End If
	Return dest
End Sub

Sub DrawAngledElbow(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Align As Int, ColorID As Int, State As Boolean , Text As String,Alpha As Int,IsMoving As Boolean)As Rect
	Dim Points As Path , Slant As Int,Slant2 As Int,Color As Int ,Corner As Rect, ElbowHeight As Int,FlipX As Boolean, FlipY As Boolean , Dest As Point ,CornerHeight As Int
	Dim Slant3 As Int , ElbowWidth As Int,CornerWidth As Int  ,temp As Int
	ElbowHeight=LCAR.LCARCornerElbow.Height
	ElbowWidth=LCAR.LCARCornerElbow.Width
	CornerHeight=LCAR.LCARCornerElbow2.Height
	CornerWidth=LCAR.LCARCornerElbow2.Width
	Slant = (Height-ElbowHeight) * 0.1
	Slant2=(Height-BarHeight)*0.1 
	Slant3 = CornerHeight*0.1
	
	Color = LCAR.GetColor(ColorID,State,Alpha)
	
	'DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa,SetRect(X, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,False,True,IsMoving)
	'MakePoint(Points, X, Y+Height-LCAR.LCARCornerElbow.Height)'top left of bottom left corner
			'LCAR.DrawBitmap(BG, LCAR.LCARCornerElbow,LCAR.LCARCornerElbowa, 
			
	'MakePoint CopyPlistToPath    1 pixel right/left per 10 pixels up/down
	Select Case Align 'remember to end on the first point
		Case 4'top left /-			
			MakePoint(Points, X+BarWidth, Y+Height)'bottom right
			MakePoint(Points, X, Y+Height)'bottom left
			'MakePoint(Points, X +Slant, Y)'top left
			MakePoint(Points, X +Slant, Y+ElbowHeight)'bottom left of elbow
			MakePoint(Points, X +Slant, Y)'top left
			Dest = Trig.SetPoint(X+Slant,Y)
			MakePoint(Points, X +Width, Y)'top right
			MakePoint(Points, X +Width, Y+BarHeight)
			MakePoint(Points, X+BarWidth+  Slant2 , Y+BarHeight)'corner
			Corner = LCAR.SetRect(X+BarWidth+  Slant2-Slant3, Y+BarHeight, CornerWidth, CornerHeight)
			MakePoint(Points, X+BarWidth, Y+Height)
			temp= API.GetTextHeight(BG, BarHeight, Text, LCAR.LCARfont)
			If Text.length>0 Then LCAR.DrawLCARtextbox(BG,X+Width+5, Y, BG.MeasureStringWidth(Text,LCAR.LCARfont, temp)+5  ,temp,  0,0, Text, ColorID, 0,0, State,False, 0, Alpha)
			
		Case 5'top right
			MakePoint(Points, X,Y+BarHeight)
			MakePoint(Points, X,Y)'top left
			MakePoint(Points, X+Width-Slant,Y)'top right
			Dest = Trig.SetPoint(X+Width-Slant-ElbowWidth+2,Y)
			MakePoint(Points, X+Width-Slant,Y+ElbowHeight)'bottom right of elbow
			MakePoint(Points, X+Width, Y+Height)'bottom right			
			MakePoint(Points, X+Width-BarWidth,Y+Height)'bottom left
			MakePoint(Points, X+Width-BarWidth-Slant2, Y+BarHeight)'corner
			Corner = LCAR.SetRect(X+Width-BarWidth-Slant2+Slant3-CornerWidth+1, Y+BarHeight, CornerWidth, CornerHeight)
			MakePoint(Points, X,Y+BarHeight)
			FlipX=True
		Case 6'bottom left normal
			MakePoint(Points, X+Slant+BarWidth, Y)'top right
			MakePoint(Points, X+Slant, Y)'top left
			Dest = Trig.SetPoint(X, Y+ Height-ElbowHeight+1)
			FlipY=True
			MakePoint(Points, X, Dest.Y)'bottom left
			MakePoint(Points, X, Y+ Height)
			MakePoint(Points, X+Width, Y+ Height)'bottom right
			MakePoint(Points, X+Width, Y+ Height-BarHeight)'bottom
			temp=X+BarWidth+Slant-Slant2+Slant3+1
			MakePoint(Points, temp, Y+ Height-BarHeight)'corner
			MakePoint(Points, temp, Y+ Height-BarHeight-CornerHeight)'top of corner
			Corner = LCAR.SetRect(X+BarWidth+Slant-Slant2+Slant3+1, Y+ Height-BarHeight-CornerHeight+1, CornerWidth, CornerHeight)
			MakePoint(Points, X+Slant+BarWidth, Y)'top right
		Case 7'bottom right normal	
			MakePoint(Points, X+Width, Y+Height)'bottom right
			MakePoint(Points, X, Y+Height)'bottom left
			MakePoint(Points, X, Y+Height-BarHeight)
			temp=X+Width-BarWidth-Slant+Slant2-Slant3-1
			MakePoint(Points, temp, Y+Height-BarHeight)'corner
			MakePoint(Points, temp, Y+Height-BarHeight-CornerHeight)'corner
			MakePoint(Points, X+Width-BarWidth-Slant, Y)'top left
			MakePoint(Points, X+Width-Slant, Y)'top right
			MakePoint(Points, X+Width, Y+Height-ElbowHeight)
			MakePoint(Points, X+Width, Y+Height)'bottom right
			FlipX=True
			FlipY=True
			Dest = Trig.SetPoint(X+Width-ElbowWidth+1, Y+ Height-ElbowHeight+1)
			Corner = LCAR.SetRect(temp-CornerWidth+1, Y+Height-BarHeight-CornerHeight+1, CornerWidth, CornerHeight)
		Case 8'bottom left tabbed
			Slant=BarWidth+CornerWidth
			Slant2=X+Width-Slant'-CornerWidth
			Corner = LCAR.SetRect(Slant2, Y+Height- CornerHeight, CornerWidth,CornerHeight)
			LCAR.DrawRect(BG,Slant2, Y+Height-CornerHeight-1, Slant, CornerHeight, Color,0)
			LCAR.DrawBitmap(BG, LCAR.LCARCornerElbow2, LCAR.LCARCornerElbow2a, Corner, True,False,IsMoving)
			Corner = DrawAngledElbow(BG,X,Y,Width,Height - CornerHeight, BarWidth,BarHeight, 6, ColorID, State,Text,Alpha,IsMoving)
		Case 9'bottom right tabbed
			Corner = LCAR.SetRect(X+BarWidth, Y+Height- CornerHeight, CornerWidth,CornerHeight)
			LCAR.DrawRect(BG,X, Y+Height-CornerHeight-1, BarWidth+CornerWidth, CornerHeight, Color,0)
			LCAR.DrawBitmap(BG, LCAR.LCARCornerElbow2, LCAR.LCARCornerElbow2a, Corner, False,False,IsMoving)
			Corner = DrawAngledElbow(BG,X,Y,Width,Height - CornerHeight, BarWidth,BarHeight, 7, ColorID, State,Text,Alpha,IsMoving)
	End Select
	If Points.IsInitialized Then
		'CopyPlistToPath(Points, P, BG, Color,0, Not(IsMoving),False)
		'If IsMoving Then 
		'	BG.ClipPath(Points)
		'Else 
			BG.DrawPath(Points, Color, True, 0)
		'End If 
		'LCAR.DrawRect(BG,X,Y,Width,Height,Color,0)
		If Dest.IsInitialized Then LCAR.DrawBitmap(BG, LCAR.LCARCornerElbow,LCAR.LCARCornerElbowa,LCAR.SetRect(Dest.X,Dest.Y,ElbowWidth,ElbowHeight  ) , FlipX,FlipY,IsMoving)
		'BG.RemoveClip 
		'Select Case Align
		'	Case 4: LCAR.DrawRect(BG, Dest.X-1, Dest.Y, 2, ElbowHeight, Colors.black, 0)
		'	Case 5: LCAR.DrawRect(BG, Dest.X + ElbowWidth-2, Y, 2, ElbowHeight, Colors.red, 0)
		'End Select
		
	End If
	If Align = 9 Then 
		X = X + Width - 1
		BG.DrawLine(X, Y, X, Y + Height, Colors.black, 1)'fast fix, needs more work
	End If
	Return Corner
End Sub







Sub CopyPlistToPath(Plist As List, P As Path, BG As Canvas, Color As Int,Stroke As Int, DoDraw As Boolean, DoDrawAll As Boolean  ) As Rect 
	Dim Count As Int, temp As Point, temp2 As Point , dest As Rect 
	Dim Left As Int, Right As Int, Top As Int, Bottom As Int 
	Left=-1
	Top = -1
	
	temp = Plist.Get(0)
	P.Initialize(temp.X, temp.Y)
	If DoDraw Then LCAR.ActivateAA(BG, True)
	For Count = 1 To Plist.Size-1
		temp2 = Plist.Get(Count)
		
		If temp2.X< Left Or Left=-1 Then Left = temp2.X 
		If temp2.X> Right Then Right = temp2.X 
		If temp2.y< Top Or Top = -1 Then Top = temp2.y 
		If temp2.y> Bottom Then Bottom = temp2.y 
		
		P.LineTo(temp2.X, temp2.Y)
		If DoDraw  Then
			If (temp.x <> temp2.X And temp.Y <> temp2.Y) Or DoDrawAll Then
				BG.DrawLine(temp.x,temp.y, temp2.X,temp2.Y, Color, Stroke)
			End If
			temp.x=temp2.X
			temp.y=temp2.Y 
		End If
	Next
	If DoDraw Then BG.ClipPath(P)
	
	dest.Initialize(Left,Top,Right,Bottom)
	Return dest
End Sub

Sub DrawKlingonGlyph(BG As Canvas, X As Int, Y As Int, Direction As Int, Color As Int, Width As Int, Height As Int, Indent As Int )
	Dim Plist As Path 
	Select Case Direction
		Case 0'north
			MakeKlingonLine(Plist, X,Y+Height-1, Width*0.5, -Height, Indent, True)
			MakeKlingonLine(Plist, X+Width*0.5,Y, Width*0.5, Height, Indent, False)
			MakeKlingonLine(Plist, X+Width-1, Y+Height-1, -Width, 1, -Indent, False)
		Case 1'east
			MakeKlingonLine(Plist, X,Y, Width, Height*0.5, Indent, True)
			MakeKlingonLine(Plist, X+Width,Y+Height*0.5, -Width, Height*0.5, Indent, False)
			MakeKlingonLine(Plist, X, Y+Height-1, 1, -Height, Indent, False)
		Case 2'south
			MakeKlingonLine(Plist, X,Y, Width*0.5, Height, -Indent, True)
			MakeKlingonLine(Plist, X+Width*0.5,Y+Height, Width*0.5, -Height, -Indent, False)
			MakeKlingonLine(Plist, X+Width-1, Y, -Width, 1, Indent, True)
		Case 3'west
			MakeKlingonLine(Plist, X+Width-1,Y, -Width, Height*0.5, -Indent, True)
			MakeKlingonLine(Plist, X,Y+Height*0.5, Width, Height*0.5, -Indent, False)
			MakeKlingonLine(Plist, X+Width-1, Y+Height-1, 1, -Height, -Indent, False)
	End Select
	BG.DrawPath(Plist, Color, False, 1)
	BG.DrawPath(Plist, Color, True, 0)
	'BG.DrawRect(CopyPlistToPath(Plist,P, BG, Color, 1,  True,False) , Color, True, 0)BG.RemoveClip 
End Sub


Sub MakeKlingonLine(P As Path, X As Int, Y As Int, Width As Int, Height As Int, Size As Int, FirstPoint As Boolean)'size>0 then right side, <0 = left side
	Dim temp As Int, Angle As Int,Angle2 As Int , Distance As Int ,temp2 As Point ,temp3 As Point   'Rise/run
	If FirstPoint Then MakePoint(P, X,Y)
	If Width=1 Then'straight up/down
		temp=Height /3
		MakePoint(P,X, Y+temp)
		MakePoint(P,X+Size, Y+temp)
		MakePoint(P,X+Size, Y+temp*2)
		MakePoint(P,X, Y+temp*2)
		MakePoint(P,X, Y+Height-1)
	Else If Height = 1 Then'straight left/right
		temp=Width/3
		MakePoint(P,X+temp, Y)
		MakePoint(P,X+temp, Y+Size)
		MakePoint(P,X+temp*2, Y+Size)
		MakePoint(P,X+temp*2, Y)
		MakePoint(P,X+Width-1, Y)
	Else
		temp=Width/3
		
		Angle=Trig.GetCorrectAngle(0,0,Width,Height)
		Distance=Trig.FindDistance(0,0,Width,Height)
		temp=Distance/3
		
		temp2=Trig.FindAnglePoint(0,0, temp, Angle)
		temp3=Trig.SetPoint(X+ temp2.X,Y+ temp2.Y)
		MakePoint(P,temp3.X,temp3.Y)'correct
		
		If Size<0 Then 
			Angle2= Trig.CorrectAngle( Angle-90)
		Else
			Angle2= Trig.CorrectAngle( Angle+90)
		End If
		temp3=Trig.FindAnglePoint(temp3.X,temp3.Y, Abs(Size), Angle2)'correct
		MakePoint(P,temp3.X,temp3.Y)
		
		temp3=Trig.SetPoint(temp3.X+ temp2.X,temp3.Y+ temp2.Y)
		MakePoint(P,temp3.X,temp3.Y)
		
		temp3=Trig.SetPoint(X+ temp2.X*2,Y+ temp2.Y*2)
		MakePoint(P,temp3.X,temp3.Y)
		
		MakePoint(P, X+Width-1, Y+Height-1)
	End If
End Sub
Sub MakePoint(P As Path, X As Int, Y As Int)As Point 
	Return LCARSeffects3.MakePoint(P,X,Y)
End Sub
Sub RandomENT As String 
	Return RandomNumber(2,True) & "-" & RandomNumber(3,True)
End Sub


Sub DrawUTtext(BG As Canvas, X As Int, Y As Int, Text As String ,Color As Int, Align As Int)
	Dim Offset As Int 
	If Games.UT Then
		LCAR.DrawTextbox(BG,Text, LCAR.LCAR_Red,  X,Y,0,0,Align)
	Else
		If Align=8 Then Offset= BG.MeasureStringHeight(Text,KlingonFont , LCAR.Fontsize)
		BG.DrawText(Text,  X, Y+ Offset, KlingonFont , LCAR.Fontsize , Colors.Red, "CENTER")
	End If
End Sub

Sub DrawKlingonFrame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stage As Int, BottomPercent As Int, LeftPercent As Int, Text As String, Text2 As String,Alpha As Int, TextAlign As Int )
	Dim Points As Path,temp As Int  ,temp2 As Int, temp3 As Int, temp4 As Int, WhiteSpace As Int, LineWidth As Int,Dest As Point ,Dest2 As Point ,CenterSpace As Int, Unit As Int,GameMode As Boolean 
	If TextAlign=0 Then LCAR.DrawRect(BG,X,Y,Width,Height, Colors.black,0)
	
	LineWidth=20
	WhiteSpace=2
	X=X+WhiteSpace
	Width=Width-WhiteSpace*2
	Y=Y+WhiteSpace
	Height=Height-WhiteSpace-LineWidth*2
	Unit=Floor(Height*0.01)
	
	If BottomPercent=-1 Then 
		GameMode=TextAlign=0
		BottomPercent=Games.TurretTemp
		If Games.TotalTribbles=0 Then LeftPercent=0 Else LeftPercent=Games.tribblesround/Games.TotalTribbles*100
		Text=Games.TRI_Score 
		Text2= API.IIF(Games.UT, "LIVES: ", "") & Games.Lives 
		If GameMode Then Games.Dimensions.Initialize(X,Y,Width,Height)
	Else
		LCAR.ActivateAA(BG,True)
		LineWidth=5
	End If
	WhiteSpace=Height/3
	'clipping path
	
	MakePoint(Points, X+WhiteSpace, Y+Height)'left bottom
	MakePoint(Points, X, Y+WhiteSpace)'left middle
	MakePoint(Points, X+WhiteSpace*0.5, Y)'left top
	
	temp=Height*0.5
	temp2=X+Width- temp*0.5
	MakePoint(Points, temp2, Y)'right top
	MakePoint(Points, X+Width, Y+Height*0.5)'right middle
	MakePoint(Points, temp2, Y+Height)'right bottom
	
	MakePoint(Points, X+WhiteSpace, Y+Height)'left bottom repeat
	
	'whiskers
	If TextAlign=0 Then
		Dest=GetKlingonPoint(X,Y,Width,Height, 0, 0.15 , WhiteSpace, temp,temp2)
		Dest=DrawKlingonLine(BG, Dest.X,Dest.Y, Unit*-8,Unit*3,True,True,Color, 1)'first line coming off the top-left side
		DrawKlingonDiagonal(BG,Dest.X,Dest.Y, WhiteSpace, False,Color,2)  
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 0, 0.3 , WhiteSpace, temp,temp2)
		Dest=DrawKlingonLine(BG, Dest.X,Dest.Y,Unit*-4,Unit*4,True,True,Color, 1)'second line coming off the top-left side
		DrawKlingonDiagonal(BG,Dest.X,Dest.Y, WhiteSpace, False,Color,2) 
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 1, 0.4 , WhiteSpace, temp,temp2)
		Dest=DrawKlingonLine(BG, Dest.X+10,Dest.Y, Unit*-10,Unit*4,True,False,Color, 1)'first line coming off the bottom-left side
		Dest2=DrawKlingonDiagonal(BG,Dest.X-2,Dest.Y+2, WhiteSpace, True,Color,2)'downwards line
		
		temp4=X + (Dest2.X-X)*0.5
		DrawUTtext(BG, temp4, Dest2.Y-2, Text, Color, 8)
		DrawUTtext(BG, temp4, Dest2.Y, Text2, Color, 2)
		BG.DrawLine(Dest2.X,Dest2.Y,X,Dest2.Y,Color,2)
		
		Dest=DrawKlingonDiagonal(BG,Dest.X+6,Dest.Y, Unit*-6, True,Color,2)'upwards line
		DrawKlingonTriangle(BG,Dest.X+1,Dest.Y+1, 20,20,Color,-2,0)'tip
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 1, 0.6 , WhiteSpace, temp,temp2)
		Dest=DrawKlingonLine(BG, Dest.X+10,Dest.Y, Unit*-6,Unit*4,False,False,Color, 1)'second line coming off the bottom-left side
		DrawKlingonDiagonal(BG,Dest.X,Dest.Y, temp, True,Color,2) 
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 2, 0.33 , WhiteSpace, temp,temp2)
		Dest=DrawKlingonLine(BG, Dest.X,Dest.Y, LineWidth*0.5, Unit,False,False,Color, 2)'first line coming off the top-right side
		Dest= DrawKlingonDiagonal(BG,Dest.X,Dest.Y,  temp*0.5, True,Color,2) 'diagonal line
		BG.DrawLine(Dest.X,Dest.Y,Dest.X+Unit*2,Dest.Y, Color,2)'horizontal line
		DrawKlingonTriangle(BG,Dest.X+8,Dest.Y+2, Unit*3,Unit*3,Color,-1,0)'tip
		
		'triangles along bottom right edge
		temp4=Unit*3
		Dest=GetKlingonPoint(X,Y,Width,Height, 3, 0.05 , WhiteSpace, temp,temp2)
		DrawKlingonTriangle(BG,Dest.X,Dest.Y, temp4,temp4,Color,0,0)'tip
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 3, 0.15 , WhiteSpace, temp,temp2)
		DrawKlingonTriangle(BG,Dest.X,Dest.Y, temp4,temp4,Color,0,0)'tip
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 3, 0.25 , WhiteSpace, temp,temp2)
		DrawKlingonTriangle(BG,Dest.X,Dest.Y, temp4,temp4,Color,0,0)'tip
		
		Dest=GetKlingonPoint(X,Y,Width,Height, 3, 0.35 , WhiteSpace, temp,temp2)
		DrawKlingonTriangle(BG,Dest.X,Dest.Y, temp4,temp4,Color,0,0)'tip
	End If
	
	'grid
	BG.DrawPath(Points, Color, False, 3) 
	'CopyPlistToPath(Points, P, BG, Color,  3, True,True)
	BG.ClipPath(Points)
	
	If GameMode Then'game mode, under grid
		temp=X+WhiteSpace
		Games.TRI_DrawScreen(BG, temp, Y, temp2-temp, Height, False)
		DrawKlingonGrid(BG,X,Y,Width, Height, Height/11.5, 1,Color,False)
	Else
		LCAR.DrawRect(BG,X,Y,Width,Height,Colors.argb(Alpha,0,0,0),0)
		DrawKlingonGrid(BG,X,Y,Width, Height, Height/3, 1,Colors.argb(Alpha*0.5, 255,0,0),False)
		
		temp=Width*0.5
		Select Case TextAlign
			Case 1: temp=X+  temp'staying
			Case 2: temp=X+ temp*(Alpha/255)'alpha going up to 255/towards center from left
			Case 3: temp=X+ temp + (temp*((255-Alpha)/Alpha))'alpha going down to 0/towards right from center
		End Select
		temp3=LCAR.TextHeight(BG,Text)
		DrawUTtext(BG,temp, Y+Height/2+API.IIF(Games.UT, temp3/2 ,-temp3) , Text, Color,8)
		DrawUTtext(BG,temp, API.IIF(Games.UT, Y+5,Y+Height/2), Text2, Color,2)
	End If
	If GameMode Then Games.TRI_DrawScreen(BG, temp, Y, temp2-temp, Height, True)'on top of grid
	
	temp=X+WhiteSpace*0.5+LineWidth
	BG.DrawLine(temp+LineWidth, Y-LineWidth*2, temp-WhiteSpace*2,Y+WhiteSpace*4, Color,  LineWidth*2)'line along left edge
	
	'DrawKlingonLarson(BG,Height,X+WhiteSpace*0.5, temp+LineWidth, Y-LineWidth*2, Y, temp-WhiteSpace,Y+WhiteSpace*2,WhiteSpace, Colors.Yellow,  LineWidth*2, LeftPercent, 10,Unit)
	
	'If Games.LastP.IsInitialized AND GameMode Then 
	'	BG.DrawLine(X+Games.LastP.X, Games.LastP.Y,X+Width*0.5, Y+Height, Colors.Blue ,5)
	'	BG.DrawCircle(X+Games.LastP.X, Games.LastP.Y, 5, Colors.Green ,True, 0)
	'	BG.DrawCircle(X+Width*0.5, Y+Height, 5, Colors.Green ,True, 0)
	'End If
	
	'outside
	If TextAlign=0 Then
		DrawKlingonLarson(BG,X+WhiteSpace*0.5, Y, LineWidth *2,WhiteSpace,  Colors.Yellow,  LeftPercent, 10,Unit)                ' Y-LineWidth*2, Y, temp-WhiteSpace,Y+WhiteSpace*2,WhiteSpace, Colors.Yellow,  LineWidth*2, LeftPercent, 10,Unit)
	
		'bars
		temp= Width*0.5
		temp3=X+WhiteSpace+temp'+LineWidth
		temp4=Y+Height
		DrawKlingonLine(BG,X+WhiteSpace-1,temp4, temp, LineWidth*2,False,True, Color,-1)'line along bottom edge
		Dest=DrawKlingonLine(BG,temp3,temp4+ LineWidth,temp2-temp3+LineWidth , LineWidth*2,  True,True, Color,3)'line next to that line
		
		CenterSpace=DrawKlingonTriangles(BG, X+WhiteSpace-1,temp4+LineWidth*0.5, temp, LineWidth, 7, Max(0, BottomPercent)  , Colors.Yellow) *2
		
		temp4=temp4+ LineWidth*3-1
		If temp4< LCAR.scaleheight  Then
			temp=temp*0.5+LineWidth
			Dest2= DrawKlingonLine(BG,  temp3+5, temp4, -temp+CenterSpace-6,    6, True,True,Color,1)
			DrawKlingonTriangle(BG, Dest2.X,Dest2.Y+5, CenterSpace, CenterSpace, Color,-5, temp)
			temp3=Dest2.X-CenterSpace+5
			Dest2 = DrawKlingonLine(BG,  temp3, temp4, -temp+CenterSpace,    6, True,False,Color,1)
			BG.DrawRect( LCAR.SetRect(Dest2.X,Dest.Y+4          , CenterSpace,CenterSpace  ), Colors.Black, True,0)
			DrawKlingonTriangle(BG, Dest2.X+1,Dest2.Y, CenterSpace*0.5,CenterSpace,Color, -4, temp)
			
			Dest2.X=Dest2.X+LineWidth*0.5'starting x
			Dest2.Y=Dest2.Y+LineWidth*0.5+4'starting y
			temp4=CenterSpace-LineWidth*0.5-2'height
			temp3 = temp3-Dest2.X 'width of a half
			WhiteSpace=4
			temp=temp3* 0.04
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp*2,temp4,Color,0).Right +WhiteSpace
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp,temp4,Color,0).Right +WhiteSpace
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp,temp4,Color,0).Right +WhiteSpace
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp,temp4,Color,0).Right +WhiteSpace
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp*8,temp4,Color,0).Right +WhiteSpace
			'end
			LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp*8,temp4,Color,0)
			Dest2.X= DrawKlingonLine(BG, Dest2.X,Dest2.Y, temp3 - temp*13 - WhiteSpace*5, temp4, False,False,Color,3).X+CenterSpace
			'right side
			Dest2.X= DrawKlingonLine(BG, Dest2.X,Dest2.Y, temp3 * 0.75, temp4, True,False,Color,2).X
			Dest2.X = LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp4*0.5,temp4,Color,0).Right+WhiteSpace
			
			Dest2.X= LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp*2,temp4,Color,0).Right +WhiteSpace
			LCAR.DrawRect(BG, Dest2.X, Dest2.Y, temp3*0.25 - temp*2-WhiteSpace,temp4, Color,0) 'end
		End If
		
		temp= Width-Dest.X-LineWidth
		If Stage>-1 Then DrawKlingonScan(BG, Dest.X+LineWidth, Y, temp, Color,2,   Stage/(MaxKcycles-1)*temp   , temp*0.2)'sensor sweep
		
		WhiteSpace=LineWidth*9
		Dest=DrawKlingonLine(BG, Dest.X, Dest.Y, WhiteSpace, -Height*0.25,True,True,Color,1)'thick line connected to the line, next to the line along the bottom edge

		Dest = DrawKlingonLine(BG, Dest.X+LineWidth*0.25, Dest.Y-LineWidth*0.5,WhiteSpace, -LineWidth*0.5,True,True,Color,1 )'thin line above that line 
		DrawKlingonLine(BG, Dest.X+LineWidth*0.25, Dest.Y-LineWidth*0.5,WhiteSpace, -LineWidth,True,True,Color,1 ) 'thicker line above that line
	End If
	If GameMode Then LCAR.ActivateAA(BG,False)
	BG.RemoveClip 
End Sub



Sub GetKlingonPoint(X As Int, Y As Int, Width As Int, Height As Int, Quadrant As Int, Y2 As Double, ThirdHeight As Int,HalfHeight As Int,RightEdge As Int) As Point
	Dim X2 As Int, Y3 As Int,temp As Int
	Select Case Quadrant
		Case 0'top left	GAMMA
			Y3=Y2*ThirdHeight
			X2=-1+ (ThirdHeight- Y3)*0.5 
		Case 1'bottom left BETA
			temp=(Height-ThirdHeight)*Y2
			X2=temp*0.5
			Y3=ThirdHeight+temp
		
		Case 2'top right DELTA
			Y3= HalfHeight*Y2
			X2=RightEdge+ Y3*0.5
			
		Case 3'bottom right ALPHA
			temp= HalfHeight*Y2
			X2=Width - temp*0.5
			Y3=HalfHeight+temp
	End Select
	Return Trig.SetPoint(X+X2,Y+Y3)
End Sub

Sub DrawKlingonLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, LeftEnd As Boolean, RightEnd As Boolean, Color As Int, Ret As Int)As Point 
	Dim Points As Path ,HalfHeight As Int, thePoints As List 
	If Width<0 Then 
		Width=Width*-1
		X=X-Width
	End If
	If Height<0 Then
		Height=Height*-1
		Y=Y-Height
	End If
	thePoints.Initialize
	HalfHeight=Height*0.5
	If LeftEnd Then'/
		thePoints.Add(MakePoint(Points,X,Y+Height))'bottom left  						0
		thePoints.Add(MakePoint(Points,X+HalfHeight,Y))'top left						1
	Else'\
		thePoints.Add(MakePoint(Points,X+HalfHeight,Y+Height))'bottom left				0
		thePoints.Add(MakePoint(Points,X,Y))'top left									1
	End If
	If RightEnd Then'/
		thePoints.Add(MakePoint(Points,X+Width,Y))'top right							2
		thePoints.Add(MakePoint(Points,X+Width-HalfHeight,Y+Height))'bottom right		3
	Else'\
		thePoints.Add(MakePoint(Points,X+Width-HalfHeight,Y))'top right				2
		thePoints.Add(MakePoint(Points,X+Width,Y+Height))'bottom right					3
	End If
	'CopyPlistToPath(Points,P, BG, Color, 1, False,False)
	BG.DrawPath(Points, Color, False, 1)
	BG.DrawPath(Points, Color, True, 0)
	If Ret>-1 And Ret<thePoints.Size  Then Return thePoints.Get(Ret)
End Sub
Sub DrawKlingonDiagonal(BG As Canvas, X As Int, Y As Int, Height As Int, GoRight As Boolean,  Color As Int, Stroke As Int) As Point 
	Dim EndPoint As Point ,DoStartPoint As Boolean 
	If Height<0 Then 
		Height=Abs(Height)
		Y=Y-Height
		If GoRight Then
			X=X-Height*0.5
		Else
			X=X+Height*0.5
		End If
		DoStartPoint=True
	End If
	If GoRight Then
		EndPoint=Trig.SetPoint(X+Height*0.5,Y+Height)
	Else
		EndPoint=Trig.SetPoint(X-Height*0.5,Y+Height)
	End If
	BG.DrawLine(X,Y, EndPoint.X,EndPoint.Y, Color,Stroke)
	If DoStartPoint Then
		Return Trig.SetPoint(X,Y)
	Else
		Return EndPoint
	End If
End Sub


Sub DrawKlingonGrid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CellWidth As Int, Stroke As Int, Color As Int, DoClip As Boolean )
	Dim temp As Int,LineHeight As Int ,LineWidth As Int ,Cells As Double,CellHeight As Int 
	CellHeight=CellWidth*2
	Cells= Height/CellHeight
	LineWidth=CellWidth*Cells
	LineHeight=CellHeight*Cells
	If DoClip Then LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	For temp = X+CellWidth-1 To X+Width+Height Step CellWidth
		BG.DrawLine(temp, Y, temp+LineWidth, Y+Height, Color,Stroke)'
		BG.DrawLine(temp, Y, temp-LineWidth, Y+Height, Color,Stroke)
	Next
	For temp = Y To Y+Height Step CellHeight
		Cells=X+ Ceil(Width/CellWidth)*CellWidth'    X+Width
		
		'BG.DrawLine(X,temp,X+Width,temp,Color,Stroke)
		BG.DrawLine(X,temp,Cells,temp,Color,Stroke)
		
		'BG.DrawLine(X,temp+CellWidth,X+Width,temp+CellWidth,Color,Stroke)
		BG.DrawLine(X,temp+CellWidth,Cells,temp+CellWidth,Color,Stroke)
		
		BG.DrawLine(X,temp,X+LineWidth,temp+LineHeight,Color,Stroke)
		BG.DrawLine(Cells,temp,Cells-LineWidth,temp+LineHeight,Color,Stroke)
	Next
	If DoClip Then BG.RemoveClip 
End Sub

Sub DrawKlingonScan(BG As Canvas, X As Int, Y As Int, Width As Int, Color As Int,Stroke As Int, Stage As Int, Inc As Int) As Int
	Dim temp As Int ,Height As Int ,P As Path ,WidthHalf As Int
	WidthHalf=Width*0.5
	Height=Y+Width 
	
	P.Initialize(X,Y)
	P.LineTo(X+Width,Y)
	P.LineTo(X+WidthHalf,Y+Width)
	BG.ClipPath(P)
	
	BG.DrawRect(LCAR.SetRect(X,Y,Width,Width), Colors.Black,True,0)
	
	BG.DrawLine(X,Y+Stage, X+Width, Y+Stage, Color, Stroke*2)
	BG.DrawLine(X+Stage,Y, X+Stage+WidthHalf, Height, Color, Stroke*2)
	temp=X+Width-Stage
	BG.DrawLine(temp,Y, temp-WidthHalf, Height, Color, Stroke*2)
	
	BG.RemoveClip
	
	For temp = Width To Inc-1 Step -Inc*2
		Height=temp'*0.9
		DrawKlingonTriangle(BG, X,Y,temp,Height,Color,Stroke,temp*0.5)
		X=X+ Inc
		Y=Y+Inc*0.5
	Next
End Sub

Sub DrawKlingonLarson(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int,Level As Int, Bars As Int,BarHeight As Int)             ' cHeight As Int,cX As Int, X As Int, Y As Int, Y3 As Int, X2 As Int ,Y2 As Int, Height As Int, Color As Int, Stroke As Int, Level As Int, Bars As Int,BarHeight As Int)
	Dim temp As Int ,BarWidth As Int ,WhiteSpace As Int,Xover As Double,Xover2 As Double, BarPlusWhiteSpace As Int,PerLevel As Int , HighLevel As Int,LowLevel As Int,Percent As Double 
	Dim X2 As Int, Y2 As Int
	'BG.DrawLine(X, Y, X2,Y2, Colors.red, Stroke)'line along left edge
	BG.RemoveClip 
	X=X + Width*0.125'X- Stroke*0.5
	'Height=Height-Stroke
	
	'Width=Stroke'X-X2
	'Height=Y2-Y-(Stroke*2.5)
	BarWidth=Width*0.75
	BarPlusWhiteSpace=Height/ (Bars+4)
	WhiteSpace=BarPlusWhiteSpace - BarHeight
	
'	Percent=-0.5
'	Xover=BarPlusWhiteSpace*Percent' -GetKlingonPoint(0,0,0,0,  0,  BarPlusWhiteSpace/cHeight,  BarHeight,0,0).X        '(-BarPlusWhiteSpace) * 0.60' 0.50
'	Xover2=WhiteSpace*Percent
	
	Xover=BarPlusWhiteSpace/2'( 1+ ((1- BarPlusWhiteSpace*0.5) )) '*-1
	Xover2=WhiteSpace/2'( 1+ ( (1-WhiteSpace)*0.5 ))'*-1
	
'	PerLevel=Height*3
'	Xover= -GetKlingonPoint(0,0,0,PerLevel,  0,  BarPlusWhiteSpace/Height,  Height,0,0).X   /3     '(-BarPlusWhiteSpace) * 0.60' 0.50
'	Xover2= -GetKlingonPoint(0,0,0,PerLevel,  0,  WhiteSpace/Height,  Height,0,0).X         /3
	
	
	PerLevel=100 / Bars
	
	'BG.DrawLine(X,Y,X- Height/2, Y+ Height, Colors.Green ,3)
	'BG.DrawLine(X,Y,X- BarPlusWhiteSpace, Y+ BarPlusWhiteSpace*2, Colors.Yellow,2)
	
	'LCAR.DrawRect(BG,X,Y,5,5,Colors.Blue,1)
	Y=Y+ BarPlusWhiteSpace*2
	X=X- BarPlusWhiteSpace'Xover*2 'BarPlusWhiteSpace*1.5  ') '+(Width*0.125)'+ Xover*2
	'LCAR.DrawRect(BG,X,Y,5,5,Colors.green,1)
	
	HighLevel=100
	For temp = 0 To Bars-1
		'HighLevel=HighLevel+PerLevel
		LowLevel=HighLevel-PerLevel
		If Level>=HighLevel Then 
			Percent=1
		Else If Level<= LowLevel Then
			Percent=0
		Else
			Percent= (Level - LowLevel) / PerLevel
		End If
		
		X2=X - (temp*Xover)
		Y2=Y+ (temp*BarPlusWhiteSpace)
		
		'BG.DrawLine(X2,Y2,X2-Xover2, Y2+ WhiteSpace, Colors.Magenta  ,3)
		DrawKlingonBar(BG,X2-Xover2,Y2+WhiteSpace, BarWidth,BarHeight, Percent, Color)
		'LowLevel=HighLevel
		HighLevel=LowLevel
		'Y=Y+BarPlusWhiteSpace
		'X=X-Xover 'BarPlusWhiteSpace/2
	Next
End Sub
Sub DrawKlingonBar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Percent As Double, Color As Int)
	Dim temp As Int 
	If Percent=1 Then'/=true \=false
		DrawKlingonLine(BG,X,Y,Width,Height, True,True,Color,-1)
	Else
		DrawKlingonLine(BG,X,Y,Width,Height, True,True,Colors.Black,-1)
		If Percent>0 Then
			temp=Width*Percent
			DrawKlingonLine(BG,X,Y,temp,Height, True,temp>Width-Height,Color,-1)
		End If
	End If
End Sub

Sub DrawKlingonTriangles(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Triangles As Int, Level As Int, Color As Int)As Int
	Dim TriangleWidth As Int ,Center As Int,temp As Int, X2 As Int, X3 As Int, WhiteSpace As Int,CenterSpace As Int, PerLevel As Int, HighLevel As Int,LowLevel As Int,Percent As Double 
	TriangleWidth=Height*0.75
	Center=Width*0.5
	WhiteSpace=Center/(Triangles+1)-TriangleWidth
	CenterSpace=TriangleWidth+WhiteSpace
	Center=X+Center
	X2=Center-CenterSpace
	X3=Center+CenterSpace
	PerLevel=100 / Triangles
	For temp = 1 To Triangles
		HighLevel=HighLevel+PerLevel
		If Level>=HighLevel Then 
			Percent=1
		Else If Level<= LowLevel Then
			Percent=0
		Else
			Percent= (Level - LowLevel) / PerLevel
		End If
		DrawKlingonTriangleScan(BG,X2,Y,TriangleWidth,Height, Color, Percent,True)
		DrawKlingonTriangleScan(BG,X3,Y,TriangleWidth,Height, Color, Percent,False)
		LowLevel=HighLevel
		X2=X2-CenterSpace
		X3=X3+CenterSpace
	Next
	Return CenterSpace
End Sub

Sub DrawKlingonTriangleScan(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Percent As Double, GoLeft As Boolean )
	Dim Corner As Int
	Corner=API.IIF(GoLeft,-4,-3)
	If Percent=1 Then
		DrawKlingonTriangle(BG,X,Y,Width,Height,Color,Corner,0)
	Else
		DrawKlingonTriangle(BG,X,Y,Width,Height,Colors.black,Corner,0)
		DrawKlingonTriangle(BG,X,Y,Width*Percent,Height*Percent,Color,Corner,0)
	End If
End Sub

Sub DrawKlingonTriangle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int,Stroke As Int,WidthHalf As Int )As Boolean 
	Dim Points As Path ,temp As Int'Dest As Rect ,
	Select Case Stroke
		Case 0'from top corner
			MakePoint(Points,X,Y)
			MakePoint(Points,X-Width*0.5,Y+Height)
			MakePoint(Points,X+Width*0.5,Y+Height)
			'Dest=LCAR.SetRect(X-Width*0.5, Y, Width,Height)
		Case -1'from bottom left corner
			MakePoint(Points,X,Y)
			MakePoint(Points,X+Width*0.5,Y-Height)
			MakePoint(Points,X+Width,Y)
			'Dest=LCAR.SetRect(X,Y-Height,Width,Height)
		Case -2'from bottom right corner
			MakePoint(Points,X,Y)
			MakePoint(Points,X-Width,Y)
			MakePoint(Points,X-Width*0.5,Y-Height)
			'Dest=LCAR.SetRect(X-Width,Y-Height,Width,Height)
		
		Case -3'right angle from top left
			MakePoint(Points,X,Y)
			MakePoint(Points,X,Y+Height)
			MakePoint(Points,X+Width,Y)
			'Dest=LCAR.SetRect(X,Y,Width,Height)
			
		Case -4'right angle from top right
			MakePoint(Points,X,Y)
			MakePoint(Points,X,Y+Height)
			MakePoint(Points,X-Width,Y)
			'Dest=LCAR.SetRect(X-Width,Y,Width,Height)
		
		Case -5'going down from top right corner
			MakePoint(Points,X,Y)
			MakePoint(Points,X-Width,Y)
			MakePoint(Points,X-Width*0.5,Y+Height)
			'Dest=LCAR.SetRect(X-Width,Y,Width,Height)
		
		Case -6'going left from middle right point
			temp=Height*0.5
			Points.Initialize(X,Y)
			Points.LineTo(X-Width,Y-temp)
			Points.LineTo(X-Width,Y+temp)
			BG.ClipPath(Points)
			LCAR.DrawRect(BG, X-Width,Y-temp, Width,Height, Colors.Black,0)
			LCAR.DrawGradient(BG,Colors.ARGB(0,0,0,0), Color, 6, X-Width,Y-temp, Width,Height, 0,0)
			LCARSeffects.DrawRandomDots(BG,X-Width,Y-temp, Width*0.5, Height, Color,50)
			BG.RemoveClip 
			Return False
		Case Else'for sensor sweep
			BG.DrawLine(X,Y, X+Width, Y, Color, Stroke)
			BG.DrawLine(X,Y, X+WidthHalf, Y+Height, Color, Stroke)
			BG.DrawLine(X+Width,Y, X+WidthHalf, Y+Height, Color, Stroke)
			Return False
	End Select
	MakePoint(Points,X,Y)
	BG.DrawPath(Points, Color, True, 0)
	'CopyPlistToPath(Points,P,BG,Color,Stroke,False,False)
	'BG.ClipPath(P)
	'BG.DrawRect(Dest, Color,True,0)
	'BG.RemoveClip 
	Return True
End Sub






Sub DrawRoundRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, CornerRadius As Int)
	Dim temp As ColorDrawable
	temp.Initialize(Color, CornerRadius)
	BG.DrawDrawable(temp, LCARSeffects4.SetRect(X,Y,Width,Height))
End Sub

Sub DrawLegacyButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Text As String, Align As Int, TextSize As Int)
	Dim temp As ColorDrawable ,CornerRadius As Int,UseOtherFont As Boolean
	If Align<0 Then 
		CornerRadius=Abs(Align)
	Else
		CornerRadius=10
	End If
	If Width<0 Then
		Width=Abs(Width)
		UseOtherFont=True
		CornerRadius=Height/2
	End If
	temp.Initialize(Color, CornerRadius)
	'LCAR.ActivateAA(BG,True)
	BG.DrawDrawable(temp, LCAR.SetRect(X,Y,Width,Height))
	'LCAR.DrawTextbox(BG, Text, LCAR.LCAR_Black, X+CornerRadius,Y+CornerRadius, Width-CornerRadius*2,Height-CornerRadius*2, Align)
	If Text.Length>0 Then 	
		If UseOtherFont Then
			If Align=10 Then
				API.DrawTextAligned(BG,Text, X+Width - CornerRadius , Y, Height-2, LCAR.LCARfont,  API.GetTextLimitedHeight(BG, Height*0.5, (-Width+Height)*0.75, Text, LCAR.LCARfont), Colors.Black, -9, 0, 0)
			Else
				LCAR.DrawTextbox(BG, Text, LCAR.LCAR_Black, X+CornerRadius/2,Y+15, Width-CornerRadius,Height-30, Align)
			End If
		Else
			If TextSize = 0 Then TextSize = 15'I don't know why it's 15
			LCAR.DrawLegacyText(BG, X+CornerRadius,Y+CornerRadius, Width-CornerRadius*2, Height-CornerRadius*2, Text, TextSize, Colors.Black, Align)
		End If
	End If
	'LCAR.ActivateAA(BG,False)
End Sub




Sub UnusedGraphID As Int
	Dim temp As Int
	Do While FindGraph(temp)>-1
		temp=temp+1
	Loop
	Return temp
End Sub

'GraphID: Actual ID
Sub CountUnusedPoints(GraphID As Int) As Int
	Dim temp As Graph ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	For temp2 = 0 To temp.Points.Size-1
		If temp.Points.Get(temp2) >0 Then Return temp2-1
	Next
End Sub

'GraphID: Actual ID
Sub AddBlankPoints(GraphID As Int, Points As Int)
	Dim temp2 As Int 'temp As Graph ,
	If Points>0 Then
		'temp = GraphList.Get(GraphID)
		For temp2 = 1 To Points
			AddPoint(GraphID,0)
		Next
	End If
End Sub

'GraphID: Actual ID
Sub RemovePoints(GraphID As Int, Points As Int)
	Dim temp As Graph ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	For temp2 = Points-1 To 0 Step -1
		temp.Points.RemoveAt(temp2)
	Next
	temp.IsClean=False
	temp.CurrentPoint = Max(0 , temp.CurrentPoint - Points)
End Sub

'GraphID: Virtual ID
Sub FindGraph(ID As Int) As Int
	Dim temp As Graph ,temp2 As Int 
	For temp2 = 0 To GraphList.Size-1
		temp= GraphList.Get(temp2)
		If temp.ID = ID Then Return temp2
	Next
	Return -1
End Sub

'GraphID: Actual ID
Sub isGraphClean(GraphID As Int) As Boolean 
	If GraphID<0 Then Return False 
	Dim temp As Graph = GraphList.Get(GraphID)
	Return temp.IsClean 
End Sub

'GraphID: Actual ID
Sub GetGraph(GraphID As Int) As Graph 
	Return GraphList.Get(GraphID)
End Sub

'GraphID: Actual ID
Sub ClearGraph(GraphID As Int)
	Dim temp As Graph' ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	temp.IsClean=False
	temp.IsClearing =False
	temp.CurrentPoint=0
	temp.Points.Initialize 
	temp.MinV = 32767
	temp.maxv = 0
End Sub

'GraphID: Virtual ID
Sub AddGraph(ID As Int, MaxPoints As Int, ExpandWhenFull As Boolean ) As Int
	Dim temp As Graph 
	temp.Initialize 
	If ExpandWhenFull Then temp.ExpandWhenFull=MaxPoints
	temp.MaxPoints=MaxPoints
	temp.ID =ID 
	temp.MinV = 32767
	temp.Points.Initialize 
	GraphList.Add(temp)
	Return GraphList.Size-1
End Sub



Sub AddPoints2(GraphID As Int, RecData() As Short) As Boolean 
	Dim temp As Graph ,temp2 As Int ,temp3 As Int,temp4 As Int, N As Int = RecData.Length * 0.5, soundD(N) As Double
	temp = GraphList.Get(GraphID)
	If Not(temp.IsClearing) Then
		temp.IsClearing=True
		If temp.IsClean  Or temp.Points.Size <> RecData.Length Then'only update if it's been drawn already (vsync!)
			temp.Points.Initialize  
			'temp.Points.AddAll(RecData)
			For temp2 = 0 To N -1
				soundD(temp2) = RecData(temp2)
				temp3 = soundD(temp2)
				If Abs(temp3)> temp4 Then
					temp4 = Abs(temp3)
					temp.ExpandWhenFull= temp2
				End If
			Next
			temp.Points.AddAll(soundD)
			If temp4>temp.CurrentPoint Or ResetToZero Then temp.CurrentPoint=temp4 'highest point value
		End If
		temp.IsClean=False
		temp.IsClearing=False
		Return True
	End If
End Sub


Sub AddPoints(GraphID As Int, RecData() As Byte) As Boolean 
	Dim temp As Graph ,temp2 As Int ,temp3 As Int,temp4 As Int
	temp = GraphList.Get(GraphID)
	If Not(temp.IsClearing) Then
		temp.IsClearing=True
		temp2= RecData.Length /2
		temp4=0 'temp.CurrentPoint
		If temp.IsClean  Or temp.Points.Size <> temp2 Then'only update if it's been drawn already (vsync!)
			temp.Points.Initialize  
			For temp2 = 0 To RecData.Length -1 Step 2'RemoveRepeatedPoints(RecData)
				temp3 = API.Combine(RecData(temp2+1), RecData(temp2))'take 2 bytes to make a 16 bit number
				If Abs(temp3)> temp4 Then
					If temp2 >= RecData.Length-3 Then temp3 = Min(Abs(temp3),temp4*2)
					temp4 = Abs(temp3)
					temp.ExpandWhenFull= temp2'location of maximum point
					'If temp4>temp.CurrentPoint Then temp.CurrentPoint=temp4 'highest point value
				End If
				temp.Points.Add(temp3)
				'Log("Added: " & temp3 & " of " & temp.CurrentPoint)
			Next
			If temp4>temp.CurrentPoint Or ResetToZero Then 
				temp.CurrentPoint=temp4 'highest point value
			'Else If temp4<temp.CurrentPoint Then 
			'	temp.CurrentPoint = LCAR.Increment(temp.CurrentPoint, 1000, temp4)
			End If
			
			'Log("Max this cycle=" & temp4 & " all cycles=" & temp.CurrentPoint) 
			'temp.CurrentPoint=temp4 'highest point value
			'temp.CurrentPoint= Max(temp4,temp.CurrentPoint)
			temp.IsClean=False
		End If
		temp.IsClearing=False
		Return True
	End If
End Sub

'if UseAmplitude is false then it'll return the phase instead
'Sub FFTPoints(SrcGraphID As Int, DestGraphID As Int, UseAmplitude As Boolean)
'	Dim FFT1 As FFT , SrcGraph As Graph,DestGraph As Graph, CellCount As Int ,temp As Int , Maximum As Int ,temp2 As Int
'	SrcGraph = GraphList.Get(SrcGraphID)
'	'If Not(SrcGraph.IsClearing) Then
'		DestGraph=GraphList.Get(DestGraphID)
'
'		If Not(DestGraph.IsClearing) Then
'			'SrcGraph.IsClearing=True
'			DestGraph.IsClearing=True
'			CellCount= Get2toTheN( SrcGraph.Points.Size )
'			Dim TimeAmplitude(CellCount) As Double 
'			For temp = 0 To CellCount-1
'				TimeAmplitude(temp) = SrcGraph.Points.Get(temp)
'			Next
'			DestGraph.Points.Initialize 
'			
'			CellCount=CellCount * 0.5
'			Dim FFTReal(CellCount) As Double, FFTImag(CellCount) As Double, FFTresult(CellCount) As Double
'			FFT1.Transform2(TimeAmplitude, FFTReal, FFTImag)
'			FFT1.Transform( FFTReal, FFTImag)
'			If UseAmplitude Then
'				FFTresult = FFT1.ToAmplitude(FFTReal, FFTImag)	
'			Else
'				FFTresult = FFT1.ToPhase(FFTReal, FFTImag)
'			End If
'			
'			For temp = 0 To CellCount-1
'				'Log(temp & " = " & FFTresult(temp))
'				temp2=Round(FFTresult(temp))'*100'/Maximum * 100
'				If Abs(temp2)>Maximum Then 
'					Maximum = Abs(temp2)
'					DestGraph.ExpandWhenFull=temp'location of maximum point
'				End If
'				'Log("LOGGING " & temp & " as " & temp2)
'				DestGraph.Points.Add( temp2 )
'			Next
'			'DestGraph.MaxPoints=CellCount
'			If Maximum>DestGraph.CurrentPoint Then  DestGraph.CurrentPoint=Maximum 'highest point value
'			'DestGraph.CurrentPoint = Max(DestGraph.CurrentPoint, Maximum)
'			DestGraph.IsClean = False
'			SrcGraph.IsClean=True
'			DestGraph.IsClearing=False
'			SrcGraph.IsClearing=False
'		'End If
'	End If
'End Sub
Sub Get2toTheN(Value As Int) As Int
	Dim temp As Int ,temp2 As Int 
	temp = 1
	Do Until temp > Value
		temp2=temp
		temp=temp*2
	Loop
	Return temp2
End Sub





'Sub RemoveRepeatedPoints(RecData() As Byte) As Int'didnt work
'	Dim temp As Int , Count As Int , Current As Int , First As Int 
'	First = API.Combine(RecData(1), RecData(0))
'	For temp =2 To RecData.Length -1 Step 2
'		Current = API.Combine(RecData(temp+1), RecData(temp))
'		If Current = First Then
'			Count=Count+1
'		Else
'			Return Count
'		End If
'	Next
'End Sub

Sub RemoveGraph(GraphID As Int)
	If GraphID>-1 And GraphID< GraphList.Size Then  GraphList.RemoveAt(GraphID)
End Sub
Sub AddPoint(GraphID As Int, Value As Int)
	Dim temp As Graph ,temp2 As Double 
	temp = GraphList.Get(GraphID)
	If temp.CurrentPoint = temp.MaxPoints  Then
		If temp.ExpandWhenFull>0 Then
			temp.MaxPoints = temp.MaxPoints+temp.ExpandWhenFull
			temp.CurrentPoint=temp.CurrentPoint+1
		Else
			temp.CurrentPoint=0
		End If
	Else
		temp.CurrentPoint=temp.CurrentPoint+1
	End If
	temp2=Value*0.01
	temp.MaxV = Max(temp2, temp.MaxV)
	temp.minv = Min(temp2, temp.MinV)
	If temp.CurrentPoint < temp.Points.Size Then
		temp.Points.Set(temp.CurrentPoint, temp2)
	Else
		temp.Points.Add(temp2)
	End If
	temp.IsClean=False
End Sub
Sub IncrementGraph(GraphID As Int, Style As Int)
	Dim temp As Graph 
	If Style = 4 Then
		temp = GraphList.Get(GraphID)
		If temp.BracketX <> temp.ExpandWhenFull Then
			temp.BracketX = LCAR.Increment(temp.BracketX, 25, temp.ExpandWhenFull)
		End If
	End If
End Sub

Sub DebugText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, LOC As Point, ColorID As Int) As Point 
	Dim tW As Int = LCAR.TextWidth(BG,Text), tH As Int = LCAR.TextHeight(BG, "ABC123gjy")+1
	If API.debugMode Then
		If Not(LOC.IsInitialized) Then LOC = Trig.SetPoint(X,Y)
		If LOC.X + tW > X+Width Then 
			LOC.X=X
			LOC.Y=LOC.Y+tH
		End If
		LCAR.DrawText(BG,LOC.X,LOC.Y, Text,ColorID, 1,False,255,0)
		LOC.X=LOC.X+tW
	End If
	Return LOC
End Sub

Sub DrawGraph(GraphID As Int, BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, GraphColor As Int, Alpha As Int, Style As Int, Cols As Int, Rows As Int) As Boolean 
	Dim tempGraph As Graph, PointWidth As Int, PrevPoint As Double ,CurrPoint As Double, temp As Int, temp2 As Int, currX As Int, Color As Int,X2 As Int,X3 As Int, isclean As Boolean, CursorStyle As Int   ',P As Path 
	Dim DidDraw As Boolean, ActualBiggest As Double, tempstr As String  
	If GraphID < 0 Then Return DrawRandomGraph(BG,X,Y,Width,Height, Style, GraphColor, Abs(GraphID), Cols, Rows)
	'If GraphID < 0 Then 
	'	tempGraph.Initialize
	'	tempGraph.p
	'Else 
		tempGraph = GraphList.Get(GraphID)
	'End If 
	'If Style=4 Then
	'	PointWidth= Width / tempGraph.Points.Size
	'Else
		PointWidth= Width / tempGraph.MaxPoints 
	'End If
	LCAR.ActivateAA(BG,True)
	isclean=True
	currX=X
	If ColorID>-1 Then Color=LCAR.GetColor(ColorID, False,Alpha)
	If Style < 6 Or Style> 7 Then LCARSeffects.MakeClipPath(BG,X-1,Y-1,Width+1,Height)
	'P.Initialize(X-1,Y-1)
	'P.LineTo(X+Width,Y-1)
	'P.LineTo(X+Width,Y+Height)
	'P.LineTo(X-1,Y+Height)
	'BG.ClipPath(P)
	
	Select Case Abs(Style)
		Case 0,7 '/\ relative to center, 1 up and 1 down, Right angles from prev to next
			CursorStyle=1
			If tempGraph.Points.Size>0 Then
				PrevPoint=tempGraph.Points.Get(0)
				For temp = 1 To tempGraph.Points.Size-1
					CurrPoint=tempGraph.Points.Get(temp)
					DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 2, PrevPoint,CurrPoint)
					currX=currX+PointWidth
					PrevPoint=CurrPoint
				Next
				If Style= 7 Then 
					CursorStyle=2
					temp = Height * 0.14
					LCARSeffects4.DrawRect(BG, X, Y + Height * 0.5 - temp * 0.5, Width, temp, GraphColor, 2)
				End If
			End If
		Case 1'/  relative to bottom
			CursorStyle=1
			PrevPoint=0
			'GraphColor=Colors.White 
			For temp = 0 To tempGraph.Points.Size-1
				CurrPoint=tempGraph.Points.Get(temp)
				DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 1, PrevPoint, CurrPoint)
				currX=currX+PointWidth
				PrevPoint=CurrPoint
			Next
			
		Case 2'|  bars
			CursorStyle=1
			For temp = 0 To tempGraph.Points.Size-1
				CurrPoint=tempGraph.Points.Get(temp)
				DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 1, PrevPoint,CurrPoint)
				currX=currX+PointWidth
			Next
			If Style = -2 Then
				CursorStyle=2
				temp = Height * 0.10
				LCARSeffects4.DrawRect(BG,X, Y + Height * 0.5 - temp * 0.5, Width, temp, Color, 0)
			End If
			
		Case 3'circular
			DrawCircularGraph(BG, X+Width/2, Y+Width/2, Min(Width,Height)/2, tempGraph, GraphColor, Color, Cols, Rows)
		
		Case 4,5'frequency and spectrograph 		
			'.Currentpoint = max amplitude
			'.ExpandWhenFull = position of max amplitude
			'.IsClearing = locked. transferring data or drawing
			'.MaxPoints = tweened position of the brackets
			
			CurrPoint=2
			LCAR.DrawRect(BG,X-1,Y-1,Width+1,Height+1,Colors.Black,0)
			'If Style = 4 Then
				temp = API.IIF(LCAR.SmallScreen , 50,100 * LCAR.GetScalemode)
				Width=Width-temp
				currX=currX+temp
			'Else 
			'	GraphColor = LCAR.GetColor(LCAR.LCAR_Orange, False, Alpha)
			'End If
			
			If tempGraph.MaxPoints=0 Then
				PointWidth = (tempGraph.Points.Size / Width) * CurrPoint
			Else
				PointWidth = tempGraph.Points.Size / tempGraph.MaxPoints
			End If
			'If (tempGraph.IsClearing) Then
			'	isclean=False
			'Else
				tempGraph.IsClearing=True
				Try
					'If API.debugMode Then DebugPoint=DebugText(BG,X,Y,Width,Height,   tempGraph.Points.Size & " POINTS, PT WIDTH: " & PointWidth & " BIGGEST: " & tempGraph.CurrentPoint  ,DebugPoint,LCAR.LCAR_Orange)
					
					If Style=4 Then tempGraph.BracketX = LCAR.Increment(tempGraph.BracketX, PointWidth*5, tempGraph.ExpandWhenFull)
					For temp = 0 To tempGraph.Points.Size-1 Step PointWidth
						PrevPoint=0
						For temp2 = temp To temp+PointWidth
							If temp2 < tempGraph.Points.Size Then
								PrevPoint = PrevPoint + tempGraph.Points.Get(temp2)
							Else
								PointWidth=PointWidth-1
							End If
							If temp2 = tempGraph.BracketX Then 	X3 = X2
						Next
						
						'Log(currX & " = " & PrevPoint & " " & PointWidth & " " & tempGraph.CurrentPoint)
						
						PrevPoint = (PrevPoint / PointWidth) / tempGraph.CurrentPoint
						If PrevPoint > ActualBiggest Then ActualBiggest= PrevPoint
						If PrevPoint > 1 Then 
							tempGraph.CurrentPoint= PrevPoint*tempGraph.CurrentPoint
							PrevPoint=1
						End If
						'If Style=4 Then
							If LCAR.RedAlert Then
								GraphColor =GetRedColor(X2, Width)
							Else
								GraphColor = API.HSLtoRGB(X2/Width*239, 127,127,255)'currX/Width*239
							End If
						'End If
						
						temp2 = DrawPoint(BG,currX,Y,1, Height,   Style, GraphColor, 1, 0, PrevPoint)
						If temp2>0 Then DidDraw = True
						currX=currX+CurrPoint
						X2=X2+CurrPoint
					Next
				Catch
					isclean = False
				End Try
				tempGraph.IsClearing=False
			'End If
			'If Not(API.debugMode) Then 
				temp = API.IIF(LCAR.SmallScreen , 50,100 * LCAR.GetScalemode)
				DrawBox2(BG, X, temp, Y, Width, Height, Color, 60, 40, 2, X3)
			'End If
			If Not(ResetToZero) Then
				If DidDraw Then
					ZeroesInARow=0
				Else
					ZeroesInARow=ZeroesInARow+1
					If ZeroesInARow>5 Then ResetToZero=True
				End If
			End If
			'DebugPoint=DebugText(BG,X,Y,Width,Height, "ActualBiggest: " & ActualBiggest & " DataBiggest: " & tempGraph.CurrentPoint, DebugPoint, LCAR.LCAR_Purple)
			'tempGraph.CurrentPoint = LCAR.Increment(tempGraph.CurrentPoint, 50, ActualBiggest)
			If ActualBiggest< 0.5 Then 
				tempGraph.CurrentPoint=tempGraph.CurrentPoint*0.95
			End If
			
		Case 6' tricorder style
			LCAR.DrawGradient(BG, Colors.RGB(55,162,216), Colors.RGB(221,99,158), 8,  X,Y,Width,Height, 0,0)
			LCARSeffects4.DrawRect(BG, X+5,Y+5, Width-11,Height-11, Colors.Black,2)
			For temp = Y + 5 To Y + Height - 11 Step 5
				BG.DrawLine(X +5, temp, X+ 15, temp, Colors.Black,2)
			Next
			currX=X+17
			Width = Width - 30
			Y=Y+6
			Height=Height-12
			PointWidth= Width / tempGraph.MaxPoints 
			ColorID =Colors.RGB(161,19,43)
			GraphColor =Colors.RGB(60, 25,105)
			LCARSeffects.MakeClipPath(BG,currX,Y,Width,Height)
			
			If tempGraph.Points.Size>0 Then
				ActualBiggest= tempGraph.MaxV' GetHighestOrLowestValue(tempGraph,True)
				For temp = 0 To tempGraph.Points.Size-1
					X2 = tempGraph.Points.Get(temp) / ActualBiggest * Height
					LCAR.DrawGradient(BG, ColorID, GraphColor, 8, currX, Y+Height - X2, PointWidth-2, X2, 0,0)
					LCARSeffects4.DrawRect(BG, currX, Y+Height - X2, PointWidth-3, PointWidth-2, ColorID, 0)
					currX=currX+PointWidth
				Next
				
				currX=X+21
				X2 = tempGraph.CurrentPoint - 1 
				If X2 < 0 Then X2 = tempGraph.Points.Size - 1
				tempstr= ToByte(tempGraph.Points.Get( X2 ) / ActualBiggest * 255)
				temp = API.GetTextLimitedHeight(BG, Height / 8, Width * 0.75, tempstr, StarshipFont)
				LCARSeffects4.DrawRect(BG, currX, Y+4, BG.MeasureStringWidth(tempstr, StarshipFont, temp), BG.MeasureStringHeight(tempstr, StarshipFont, temp)+2, Colors.RGB(145, 146,194), 0)
				API.DrawTextAligned(BG, tempstr, currX+ 1, Y+5, 0, StarshipFont, temp, Colors.White, -1, 0,0)
			End If
			
		Case Else
			LCAR.DrawUnknownElement(BG,X,Y,Width,Height, ColorID, False, Alpha, "UNKNOWN CHART TYPE")
	End Select
	LCAR.ActivateAA(BG,False)
	
	If CursorStyle > 0 And ColorID>-1 Then 
		Select Case CursorStyle 
			Case 1: DrawCursor(BG,X,Y,Width,Height, Colors.White, PointWidth,2, tempGraph.MaxPoints *0.2,tempGraph.CurrentPoint)
			Case 2: DrawCursor(BG,X,Y,Width,Height, Colors.Black, PointWidth, 5, tempGraph.MaxPoints *0.2, tempGraph.CurrentPoint)
		End Select
		If Cols > 0 Or Rows > 0 Then DrawBox(BG,X,Y,Width,Height, Color, Cols,Rows,2,1)
	End If
	BG.RemoveClip 
	
	tempGraph.isclean=isclean
End Sub

Sub ToByte(Value As Int) As String 
	Return API.PadtoLength( Bit.ToBinaryString(Value Mod 255), True, 8, "0")
End Sub

Sub DrawCircularGraph(BG As Canvas, X As Int, Y As Int, Radius As Int, tempGraph As Graph, GraphColor As Int, BoxColor As Int, Cols As Int, Rows As Int)
	Dim DegreeWidth As Double , temp As Int , CurrValue As Double, NextValue As Double ,Inc As Double, Angle As Double , CurrCoord As Point, CurrPoint As Int, PrevCoord As Point 
	If tempGraph.Points.Size >1 Then
		DegreeWidth = 360 / tempGraph.Points.Size 
		CurrValue = Radius * tempGraph.Points.Get(0)
		Angle = DegreeWidth
		For temp = 0 To 359'curved method
			If temp>= Angle And CurrPoint+1<tempGraph.Points.Size Then 
				CurrPoint=CurrPoint+1
				NextValue = Radius * tempGraph.Points.Get(  CurrPoint )
				Inc = (NextValue - CurrValue) / DegreeWidth
				Angle = Angle+DegreeWidth
				
				'Log(CurrPoint & "@" & temp & " up until " & Angle & " the desired radius will be " & NextValue & " incrementing from " & CurrValue & " by " & Inc)
			End If
			CurrCoord = Trig.FindAnglePoint(X,Y, CurrValue, temp)
			If temp>0 Then BG.DrawLine(PrevCoord.X,PrevCoord.Y, CurrCoord.X,CurrCoord.Y, GraphColor, 1)
			PrevCoord = Trig.SetPoint( CurrCoord.X, CurrCoord.Y)
			'Log("Angle: " & temp & " Radius " & CurrValue)
			CurrValue = CurrValue+Inc' LCAR.Increment(CurrValue, Inc, NextValue)
		Next
		
		
'		For temp = 0 To tempGraph.Points.Size - 1 'linear method
'			CurrValue = Radius * tempGraph.Points.Get(temp)
'			CurrCoord = Trig.FindAnglePoint(X,Y, CurrValue, Angle)
'			If temp>0 Then
'				BG.DrawLine(PrevCoord.X,PrevCoord.Y, CurrCoord.X,CurrCoord.Y, GraphColor, 1)
'			End If
'			PrevCoord = Trig.SetPoint( CurrCoord.X, CurrCoord.Y)
'			Angle=Angle+ DegreeWidth
'		Next 
	End If
	DrawRadar(BG,X,Y,Radius,BoxColor,Cols,Rows)
End Sub

Sub DrawRadar(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Cols As Int, Rows As Int)
	Dim DegreeWidth As Double , temp As Int, CurrCoord As Point, Angle As Double
	If Cols>1 Then
		DegreeWidth = 360 / Cols 
		Angle=0
		For temp = 1 To Cols
			CurrCoord = Trig.FindAnglePoint(X,Y, Radius, Angle)
			BG.DrawLine(X, Y,  CurrCoord.X,CurrCoord.Y, Color, 1)
			Angle=Angle+DegreeWidth
		Next
	End If
	If Rows>1 Then
		DegreeWidth= Radius/ Rows
		Angle=0
		For temp = 1 To Rows-1
			Angle=Angle+DegreeWidth
			BG.DrawCircle(X,Y,Angle,Color, False,1)
		Next
	End If
	BG.DrawCircle(X,Y,Radius-1,Color, False,2)
End Sub

Sub GetRedColor(X As Int, Width As Int) As Int 
	Width=Width/2
	If X< Width Then
		Return Colors.RGB(  64 + X/Width*192    ,0,0)
	Else
		X=X-Width
		X= X/Width*255 
		Return Colors.RGB(255, X,X)
	End If
End Sub
Sub DrawPoint(BG As Canvas, X As Int, Y As Int, PointWidth As Int, Height As Int, Style As Int, Color As Int, Stroke As Int, PrevValue As Double, NewValue As Double )As Int 
	Dim X2 As Int,X3 As Int, Y2 As Int, Y3 As Int, HalfHeight As Int  
	HalfHeight=Height*0.5
	PointWidth=Max(2, PointWidth)
	Select Case Abs(Style)
		Case 0'/\ relative to center, 1 up and 1 down
			X2=X+PointWidth*0.5
			Y2=GetPoint(Y,HalfHeight,Height,PrevValue, True,False)    'Y + HalfHeight + ( HalfHeight * (1-PrevValue))
			Y3=GetPoint(Y,HalfHeight,Height,NewValue, True,True)' HalfHeight * (1-NewValue)
			BG.DrawLine(X,Y2,X2,Y3, Color, Stroke)
			X3=X+PointWidth
			Y2=GetPoint(Y,HalfHeight,Height,NewValue, True,False)'Y+HalfHeight + Y3
			BG.DrawLine(X2,Y3,X3, Y2  , Color, Stroke)
		Case 1'/  relative to bottom
			X2=X+PointWidth
			Y2=Y + Height*(1-PrevValue)  'Y + Height - Height*PrevValue
			Y3=Y + Height*(1-NewValue)  '  Y + Height - Height*NewValue
			BG.DrawLine(X,Y2,X2,Y3, Color, Stroke)
		Case 2, 7'|  bars
			If Style = 7 Then X2 = HalfHeight Else X2 = Height
			Y3= X2 * NewValue*2
			Y2= Y+ HalfHeight - (Y3*0.5)
			BG.DrawRect( LCAR.SetRect(X, Y2, PointWidth-1, Y3), Color, Abs(Style) = 2, Stroke)
			
		Case 4'lines, relative to center
			Y3= Height* NewValue
			If Y3>Height Then 
				Y3=Height 
			Else If Y3<-Height Then 
				Y3=-Height
			End If
			Y2= Y+ HalfHeight - (Y3*0.5)
			BG.DrawLine(X, Y2,  X, Y2+Y3,  Color,2)
			
			
		Case 5'lines relative to center
			NewValue=NewValue*100
			Y3= Height* Abs(NewValue)
			If NewValue>0 Then
				Y2= Y+ HalfHeight - (Y3*0.5)
			Else
				Y2= Y+ HalfHeight
			End If
			BG.DrawLine(X, Y2,  X, Y2+Y3,  Color,2)
			
			'Y2= Y+ Height
			'HalfHeight= Height* NewValue*50
			'Y3= Y2 - HalfHeight
			'BG.DrawLine(X, Y3,  X, Y2,  Color,2)
	End Select
	Return Y3
End Sub
Sub GetPoint(Y As Int, HalfHeight As Int, Height As Int, Value As Double , RelativeToCenter As Boolean , AboveCenter As Boolean ) As Int 
	Dim temp As Int 
	If RelativeToCenter Then
		temp = Y+HalfHeight
		If AboveCenter Then
			Return temp - (HalfHeight*Value)
		Else
			Return temp + (HalfHeight*Value)
		End If
	Else
		Return Y+ (Height*(1-Value))
	End If
End Sub

Sub DrawCursor(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, PointWidth As Int, PointsGradient As Int,PointsBlack As Int, StartPoint As Int)
	Dim X2 As Int, Width2 As Int 

	X2=X+(StartPoint-PointsGradient)*PointWidth
	Width2=PointWidth*PointsGradient
	LCAR.DrawGradient(BG, Colors.ARGB(0,0,0,0), Color, 6,  X2, Y, Width2,Height, 0,0)
	X2=X2+Width2-2
	Width2=PointWidth*PointsBlack
	BG.DrawRect(LCAR.SetRect(X2,Y,Width2,Height), Colors.Black, True,0)
End Sub

Sub DrawBox(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Cols As Int, Rows As Int, OuterStroke As Int, InnerStroke As Int)
	Dim temp As Int ,temp2 As Int
	If OuterStroke>0 Then BG.DrawRect( LCAR.SetRect(X,Y,Width,Height), Color, False,OuterStroke)
	If Rows>0 Then 
		temp2=Height/Rows
		For temp = Y+temp2 To Y+Height-temp2 Step temp2
			BG.DrawLine(X, temp, X+Width, temp, Color,InnerStroke)
		Next
	End If
	If Cols>0 Then
		temp2=Width/Cols
		For temp = X+temp2 To X+Width-temp2 Step temp2
			BG.DrawLine(temp, Y, temp, Y+Height, Color, InnerStroke)
		Next
	End If
End Sub

Sub DrawBox2(BG As Canvas, X As Int, BarWidth As Int, Y As Int, Width As Int, Height As Int, Color As Int, ColWidth As Int, RowHeight As Int, Stroke As Int, BracketX As Int)
	Dim temp As Int ,temp2 As Int,temp3 As Int , Orange As Int, X2 As Int,BitWidth As Int, BitHeight As Int , Value As Int, Cols As Int , Purple As Int ,Rows As Int , Text As String, RowHeight2 As Int,TextHeight As Int
	BitHeight = LCAR.Fontsize
	RowHeight2=RowHeight+3
	Orange=LCAR.GetColor(LCAR.LCAR_Orange,False,255)
	Purple=LCAR.GetColor(LCAR.LCAR_DarkPurple, False,255)
		
	Cols=Width/ColWidth
	If Cols>0 Then
		'ColWidth=Width/Cols
		BitWidth = ColWidth *0.2
		X2=X+Width+BarWidth-Stroke
		Value=Cols*20
		For temp =  Cols To 1 Step -1
			
			If temp = Cols Or temp = Cols-1 Then 
				Color = Colors.Red 
			Else If temp> Cols-5 Then Then
				Color = Orange
			Else
				Color =Colors.White 
			End If
			
			LCAR.DrawRect(BG, X2-BitWidth, Y, BitWidth,BitHeight, Color,0)
			BG.DrawLine(X2, Y, X2, Y+Height, Color, Stroke)
			LCAR.DrawRect(BG, X2-BitWidth, Y+Height-BitWidth, BitWidth,BitWidth, Color,0)
			If TextHeight=0 Then TextHeight = BG.MeasureStringHeight(Value,LCAR.LCARfont, LCAR.Fontsize)
			BG.DrawText(Value, X2-BitWidth, Y-2+ TextHeight, LCAR.LCARfont, LCAR.Fontsize, Color, "RIGHT")
			
			Value=Value-20
			X2=X2-ColWidth
		Next
	End If
	
	X2=Y+Height/2
	Cols=X2
	
	Width=X+Width+BarWidth'is now the right coordinate
	DrawGraphBar(BG,X,X2,BarWidth,Width, RowHeight, Purple,LCAR.LCAR_DarkPurple, GetGraphText(0))
	Rows=Floor( (Height/2) / (RowHeight+2))
	
	For temp = 1 To Rows
		Text= GetGraphText(temp)
		Cols=Cols-RowHeight2
		X2=X2+ RowHeight2
		
		DrawGraphBar(BG, X,X2,BarWidth,Width,RowHeight, Orange,LCAR.LCAR_Orange, Text)
		If temp< Rows-1 Then
			DrawGraphBar(BG, X,Cols,BarWidth,Width,RowHeight, Orange, LCAR.LCAR_Orange, Text)
		Else
			X2=X2+RowHeight-1
			LCAR.DrawRect(BG,X,X2, BarWidth, RowHeight, Orange ,0)
			RowHeight=RowHeight+ (Cols-Y)
			DrawGraphBar(BG, X,Y,BarWidth,BarWidth,RowHeight, LCAR.GetColor(LCAR.LCAR_Red,False,255), LCAR.LCAR_Red , Text)
			Exit
		End If
	Next	
	'draw the brackets
	RowHeight2 = RowHeight2/4
	BracketX = Min(Max(X+BarWidth + ColWidth/2 + RowHeight2,  BracketX - ColWidth/2), Width - ColWidth/2 - RowHeight2)
	BG.RemoveClip 
	
	'draw text
	X2=X+BarWidth
	LCAR.DrawRect(BG, X2,Y- TextHeight-5, Width-X2+2, TextHeight+5 , Colors.black, 0)
	Text=API.GetString("freq_artifact")
	X2 = LCAR.TextWidth(BG, Text)
	If BracketX+X2>Width Then
		X2=Width
		temp=3
		'LCAR.DrawText(BG, Width, Y- TextHeight, "FREQUENCY ARTIFACT", LCAR.LCAR_Orange, 3, False, 255,0)
	Else
		X2=BracketX
		temp=1
		'LCAR.DrawText(BG, BracketX, Y- TextHeight, "FREQUENCY ARTIFACT", LCAR.LCAR_Orange, 1, False, 255,0)
	End If
	LCAR.DrawText(BG, X2, Y- TextHeight-4, Text, LCAR.LCAR_Orange, temp, False, 255,0)
	
	
	
	X2=Y+Height-BitHeight-RowHeight2
	Y=Y+(RowHeight2*1.5)+TextHeight+2
	
	LCARSeffects.DrawCircleSegment(BG, BracketX, Y, RowHeight2, RowHeight2*2,  270,90,  Orange, 0,0,0)
	LCARSeffects.DrawCircleSegment(BG, BracketX+ColWidth, Y, RowHeight2, RowHeight2*2,  0,90,  Orange, 0,0,0)
	temp=Y- RowHeight2*1.5 
	BG.DrawLine(BracketX, temp, BracketX+ColWidth, temp, Orange, RowHeight2)'middle top
	temp = Y + Height*.20
	temp3 = X2 - Height*.20
	temp2=BracketX - RowHeight2*1.5 
	BG.DrawLine(temp2, Y, temp2, temp, Orange, RowHeight2)'top left
	BG.DrawLine(temp2, X2, temp2, temp3, Orange, RowHeight2)'bottom left
	
	temp2=BracketX+ColWidth + RowHeight2*1.5 
	BG.DrawLine(temp2, Y, temp2, temp, Orange, RowHeight2)'top right
	BG.DrawLine(temp2, X2, temp2, temp3, Orange, RowHeight2)'bottom right
	
	LCARSeffects.DrawCircleSegment(BG, BracketX, X2, RowHeight2, RowHeight2*2,  180,90,  Orange, 0,0,0)
	LCARSeffects.DrawCircleSegment(BG, BracketX+ColWidth, X2, RowHeight2, RowHeight2*2,  90,90,  Orange, 0,0,0)
	temp=X2+RowHeight2*1.5
	BG.DrawLine(BracketX, temp, BracketX+ColWidth, temp, Orange, RowHeight2)'middle bottom
End Sub
Sub GetGraphText(Row As Int) As String 
	Return API.PadtoLength(Row,True,2,"0") & "-" & API.PadtoLength( Power(2, Row), True, 3, "0")
End Sub
Sub DrawGraphBar(BG As Canvas, X As Int, Y As Int, BarWidth As Int, Right As Int, Height As Int, Color As Int, ColorID As Int, Text As String )
	BG.DrawLine(X, Y, Right, Y,Color,2)
	LCAR.DrawLCARbutton(BG, X,Y, BarWidth, Height, ColorID,False, Text, "", 0,0,False, 0, 9, -1, 255,False)
	'LCAR.DrawRect(BG, X ,Y, BarWidth, Height, Color,0)
End Sub

'http://tosdisplaysproject.wordpress.com/bridge-station-displays/library_computer/
Sub DrawTheMoire(BG As Canvas, X As Int, Y As Int, Radius As Int, Angle As Int, OffID As Int)
	Dim X2 As Int, Y2 As Int 
	If OffID <7 Then
		Y2 = -3
	Else If OffID < 13 Then
		X2= 3
	Else If OffID < 19 Then 
		Y2=3
	Else 
		X2=-3
	End If
	Select Case OffID
		Case 0,18: X2=-3' 0y=-3  18y=3
		Case 1,17: X2=-2' 1y=-3
		Case 2,16: X2=-1' 2y=-3
		'Case 3,15
		Case 4,14: X2=1	' 4y=-3
		Case 5,13: X2=2	' 5y=-3
		
		Case 6:  X2=3	' 6y=-3
		Case 12: Y2=3	' 12x=3
		
		Case 7,23: Y2=-2'  7x=3
		Case 8,22: Y2=-1'  8x=3
		'Case 9,21
		Case 10,20: Y2=1' 10x=3
		Case 11,19: Y2=2' 11x=3
	End Select
	
	DrawMoires(BG, X, Y, Radius, Angle , 3, X2,Y2, Colors.White, Colors.Black,2)
End Sub
Sub DrawMoires(BG As Canvas, X As Int, Y As Int, Radius As Int, Angle As Int,AngleSpace As Int, Xoff As Int, Yoff As Int, Color1 As Int, Color2 As Int, Stroke As Int)
	Dim tempBG As Canvas ,radius2 As Int , Obj1 As Reflector
	CacheAngles
	'LCAR.ActivateAA(BG,True)
	'BG.DrawCircle(X,Y,Radius, Colors.black , True,0)
	radius2=Radius*2
	tempBG = InitUniversalBMP(radius2,radius2, LCAR.TOS_Moires)
	If WasInit Then 
		tempBG.DrawRect( LCAR.SetRect(0,0,radius2,radius2), Colors.Black, True,0)
		Obj1.Target = tempBG
		Obj1.Target = Obj1.GetField("paint")
		Obj1.RunMethod2("setAntiAlias", True, "java.lang.boolean")
		DrawMoire(tempBG,Radius,Radius,Radius, 0, AngleSpace, Color1, Stroke)
	End If
	BG.DrawBitmap(CenterPlatform, Null , LCAR.SetRect(X-Radius,Y-Radius, radius2, radius2))
	'DrawMoire(BG,X,Y,Radius, 0, AngleSpace, API.IIF(LCAR.RedAlert,Colors.Red, Color1), Stroke)
	LCAR.ActivateAA(BG,True)
	DrawMoire(BG,X+Xoff,Y+Yoff,Radius, Angle, AngleSpace,Color2, Stroke)
	LCAR.ActivateAA(BG,False)
End Sub
Sub DrawMoire(BG As Canvas, X As Int, Y As Int, Radius As Int, Angle As Int, AngleSpace As Int, Color As Int, Stroke As Int)
	Dim temp As Int, dest As Point 
	For temp = 1 To 360 Step AngleSpace
		dest = Trig.FindAnglePoint(X,Y, Radius, Angle)
		BG.DrawLine(X,Y, dest.X,dest.Y, Color, Stroke)
		'dest =LCARSeffects.CacheAngles(Radius, Angle)
		'BG.DrawLine(X,Y, X+dest.X,Y+dest.Y, Color, Stroke)		
		Angle=(Angle + AngleSpace) Mod 360
	Next
End Sub'http://tosdisplaysproject.wordpress.com/bridge-station-displays/library_computer/

Sub GetStageColor(cStage As Int,Grad As GradientCache) As Int
	If cStage>-1 Then
		If cStage<16 Then	
			Return Grad.Stages(cStage)
		Else If cStage < 32 Then
			Return Grad.Stages( MaxStages - (cStage-(MaxStages-1))       )
		End If
	End If
End Sub

'LBarWidth: Width of vertical bar, LBarHeight: Height of vertical bar, BBarWidth: Width of horizontal bar, BBarHeight: Height of Horizontal bar
Sub DrawBar(BG As Canvas, X As Int, Y As Int, LBarWidth As Int, LBarHeight As Int, BBarWidth As Int, BBarHeight As Int, Stage As Int, BlackWidth As Int, Color As Int, ColorID As Int, State As Boolean)
	DrawGradients(BG, X, Y, LBarWidth, LBarHeight-LCAR.LCARCornerElbow2.Height,  Color, Colors.Black, -LBarHeight/BlackWidth, Stage, MaxStages,True)
	DrawGradients(BG, X+LBarWidth+LCAR.LCARCornerElbow2.width-2,Y+LBarHeight-1, BBarWidth,BBarHeight,  Color, Colors.Black, BBarWidth/BlackWidth,MaxStages-1-Stage,MaxStages,True)
	DrawCurve(BG, X, Y+LBarHeight-1, LBarWidth, BBarHeight, ColorID, State, Stage,2,BlackWidth,BBarHeight )
End Sub
Sub DrawGradients(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color1 As Int, Color2 As Int, Blocks As Int, Cycle As Int, Cycles As Int, SetPath As Boolean)
	Dim BlockWidth As Int, CycleWidth As Int ,temp As Int,X2 As Int ,blockhalfwidth As Int  ,x3 As Int, Right As Int
	If SetPath Then 
		LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
		BG.DrawRect(LCAR.SetRect(X,Y,Width,Height), Colors.Black,True,0)
	End If
	If Blocks>0 Then'Horizontal
		BlockWidth= Width/Blocks
		CycleWidth= BlockWidth/Cycles 
		BlockWidth = CycleWidth * Cycles 
		blockhalfwidth=BlockWidth*0.5
		
		If Cycle>0 Then X2 = X- BlockWidth + (Cycle*CycleWidth) Else X2=X
		Right=X+Width
		For temp = X2 To Right Step BlockWidth-1
			LCAR.DrawGradient(BG,Color1,Color2,4, temp, Y, blockhalfwidth, Height, 0,0)
			x3=temp+blockhalfwidth-1
			LCAR.DrawGradient(BG,Color1,Color2,6, x3, Y, blockhalfwidth, Height, 0,0)
		Next
	Else'Vertical
		BlockWidth= Height/Abs(Blocks)
		CycleWidth= BlockWidth/Cycles 
		BlockWidth = CycleWidth*Cycles
		blockhalfwidth=BlockWidth*0.5
		
		'If Cycle>0 Then X2 = Y- BlockWidth + (Cycle*CycleWidth) Else X2=Y
		'Right=Y+Height
		
		If Cycle>0 Then X2 = Y+Height  + BlockWidth- (Cycle*CycleWidth) Else X2=Y+Height
		Right=Y-BlockWidth'+Height
		
		For temp = X2 To Right Step -BlockWidth+1
		'For temp = X2 To Right Step BlockWidth-1
			LCAR.DrawGradient(BG,Color1,Color2,2, X,temp, Width, blockhalfwidth,0,0)
			x3=temp+blockhalfwidth-1
			LCAR.DrawGradient(BG,Color1,Color2,8, X,x3, Width, blockhalfwidth,0,0)
		Next
	End If
	BG.RemoveClip 
End Sub
Sub CacheAngles
	If Not(LCARSeffects.CachedAngles.IsInitialized ) Then LCARSeffects.CacheAngles(Min(LCAR.ScaleHeight,LCAR.ScaleWidth)*2, -1)
End Sub

Sub DrawCurve(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Stage As Int, Corner As Int, BarWidth As Int, BarHeight As Int) 
	Dim temp As Int , Start As Int, Finish As Int, Degrees As Double  ,P As Path,X2 As Int ,startAngle As Point ,finishAngle As Point ,Grad As GradientCache , Dest As Rect , MFactor As Int,CStage As Int
	CacheAngles
	If LCAR.RedAlert Then 
		ColorID = LCAR.RedAlertMode
		State = True 
	End If
	Grad=LCARSeffects.Gradients.Get( LCARSeffects.CacheGradient( ColorID, State) )
	
	Y=Y- LCAR.LCARCornerElbow2.Height 
	Height=Height+ LCAR.LCARCornerElbow2.Height 
	Width = Width+ LCAR.LCARCornerElbow2.Width
	Dest= LCAR.SetRect(X,Y+1,Width-1,Height-1)
	
	MFactor=2
	Start=180
	Degrees= 90/(MaxStages*MFactor)
	Finish=Start+Degrees
	X2=X+Width-1
	startAngle=LCARSeffects.CachedAngles.Get(Start)
	finishAngle=LCARSeffects.CachedAngles.Get(Finish)
	CStage=Stage*2
	theDIR=False'Stage<8

	For temp = 0 To MaxStages*MFactor
		P.Initialize(X2, Y)
		P.LineTo(X2 + startAngle.X, Y+ startAngle.Y)
		P.LineTo(X2 + finishAngle.X, Y+ finishAngle.Y)
		BG.ClipPath(P)
		
		ColorID=GetStageColor(CStage,Grad)
		BG.DrawRect(Dest, ColorID, True,0)
		BG.RemoveClip
		CStage=HandleDir(CStage)
			
		Start=Finish
		Finish=180 + ( Degrees*(temp+1) ) ' Finish+Degrees
		startAngle=finishAngle
		finishAngle=LCARSeffects.CachedAngles.Get(Finish)
	Next	
	LCAR.DrawLCARelbow(BG,  X,Y, Width,Height,   BarWidth,BarHeight, 2,  -1, True, "", 0,255,False)
	
	Wireframe.drawoval(BG, X + Width, Y, LCAR.LCARCornerElbow2.Width * 2, LCAR.LCARCornerElbow2.Height * 2, Colors.black, 0, True, 0)
	'LCAR.DrawText(BG, X+Width/2, Y+Height/2, CStage, LCAR.LCAR_red,  2, False, 255,0)
End Sub
Sub HandleDir(CStage As Int) As Int 
	If theDIR Then
		CStage=CStage+1
		If CStage>31 Then 'maxstages
			theDIR=False
			CStage=31'16
		End If
	Else
		CStage=CStage-1
		If CStage<0 Then 
			theDIR=True
			CStage=0
		End If
	End If
	Return CStage
End Sub

'Angle=degrees to rotate clockwise
Sub DrawBitmapRotated(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, Angle As Int)
	BG.DrawBitmapRotated(BMP, LCAR.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCAR.SetRect(DestX,DestY,DestWidth,DestHeight), Angle)
End Sub
Sub DrawBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, DestX As Int, DestY As Int, Width As Int, Height As Int, FlipX As Boolean, FlipY As Boolean)
	If Width>0 And Height>0 Then
		If FlipX Or FlipY Then
			BG.DrawBitmapFlipped(BMP, LCAR.SetRect(SrcX,SrcY,Width,Height), LCAR.SetRect(DestX,DestY,Width,Height) ,FlipY,FlipX)
		Else
			BG.DrawBitmap(BMP, LCAR.SetRect(SrcX,SrcY,Width,Height), LCAR.SetRect(DestX,DestY,Width,Height))
		End If
	End If
End Sub
Sub ScaleBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, FlipX As Boolean, FlipY As Boolean) As Point 
	Dim NewSize As Point, CenterY As Boolean ,CenterX As Boolean 
	If DestWidth=0 Then
		DestWidth=SrcWidth
		CenterX =True
	Else If DestHeight = 0 Then 
		DestHeight = SrcHeight
		CenterY=True
	End If
	NewSize=API.Thumbsize(SrcWidth,SrcHeight, DestWidth,DestHeight, False,False)
	If CenterY Then  DestHeight=0 
	If CenterX Then  DestWidth=0
	BG.DrawBitmapFlipped(BMP, LCAR.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCAR.SetRect(DestX+DestWidth*0.5-NewSize.X*0.5, DestY+DestHeight*0.5-NewSize.Y*0.5, NewSize.X,NewSize.Y)  ,FlipY,FlipX)
	Return NewSize
End Sub

'if destheight=0 then it'll tile horizontally, destwidth=0=vertically
Sub TileBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, FlipX As Boolean, FlipY As Boolean, Alpha As Int, ScaleFactor As Float)
	Dim tempY As Int ,FinishY As Int, tempX As Int, FinishX As Int, SrcWidth2 As Int =SrcWidth*ScaleFactor, SrcHeight2 As Int = SrcHeight*ScaleFactor
	If DestHeight=0 Or DestHeight=SrcHeight2 Then'tile horizontally
		FinishY=DestX+DestWidth'-1
		For tempY = DestX To FinishY Step SrcWidth2
			If tempY + SrcWidth2 > FinishY Then
				SrcWidth2= FinishY-tempY
				SrcWidth = SrcWidth2/ScaleFactor
			End If
			DrawBMP(BG,       BMP,       SrcX,   SrcY,   SrcWidth,  SrcHeight, tempY,  DestY,SrcWidth2,SrcHeight2,Alpha,  FlipX,      FlipY)
		Next
	Else If DestWidth=0 Or DestHeight=SrcHeight2 Then'tile vertically
		FinishX=DestY+DestHeight'-1
		For tempX=DestY To FinishX Step SrcHeight2
			If tempX + SrcHeight2 > FinishX Then
				SrcHeight2 = FinishX-tempX
				SrcHeight = SrcHeight2/ScaleFactor
			End If
			DrawBMP(BG, BMP, SrcX,SrcY, SrcWidth,SrcHeight, DestX,tempX, SrcWidth2,SrcHeight2, Alpha, FlipX,FlipY)
		Next
	Else'tile both axis
		FinishX=DestX+DestWidth'-1
		FinishY=DestY+DestHeight'-1
		For tempY=DestY To FinishY Step SrcHeight2
			If tempY + SrcHeight2 > FinishY Then
				SrcHeight2 = FinishY-tempY
				SrcHeight = SrcHeight2/ScaleFactor
			End If
			TileBitmap(BG, BMP, SrcX,SrcY,SrcWidth, SrcHeight, DestX, tempY, DestWidth, SrcHeight2, FlipX, FlipY, Alpha, ScaleFactor)
		Next
	End If
End Sub

Sub DrawFluxCapacitor(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int)
	Dim Border As Int ,Grey As Int , Ratio As Double 
	Grey=Colors.RGB(176,176,176)
	Width=Width+1
	Height=Height+1
	If Width>Height Then
		Ratio= Height/Width
		LCAR.DrawRect(BG,X,Y,Width,Height,Grey,0)
		Grey=Height*Ratio
		DrawFluxCapacitor(BG,X+Width/2- Grey/2, Y, Grey, Height-1,Stage)
	Else
		Border = 0.15*Width
		
		LoadUniversalBMP(File.DirAssets, "bttf.png", LCAR.BTTF_Flux)

		DrawCenterOfFlux(BG,X+Border,Y+Border,Width-Border*2,Height-Border*2 , Stage)'Draw CenterFlux
		'LCAR.DrawRect(BG,X+Border,Y+Border,Width-Border*2,Height-Border*2,Colors.Black,0)
		
		LCAR.DrawRect(BG,X,Y,Border,Height,Grey,0)'left
		LCAR.DrawRect(BG,X+Width-Border,Y,Border,Height,Grey,0)'right
		LCAR.DrawRect(BG,X+Border-1,Y,Width-Border*2+2,Border,Grey,0)'top
		LCAR.DrawRect(BG,X+Border-1,Y+Height-Border,Width-Border*2+2,Border,Grey,0)'bottom
		
		
		DrawBitmap(BG, CenterPlatform, 404,0, X+Border-1,Y+Border-1, 48,52, False,False)'top left corner
		DrawBitmap(BG, CenterPlatform, 404,0, X+Width-Border-46,Y+Border-1, 48,52, True,False)'top right corner
		
		Grey= Width- (Border+45)*2
		TileBitmap(BG, CenterPlatform, 453,0, 6,16,   X+Border+46, Y+Border-1,     Grey, 0,False,False, 255, 1)'top edge
		TileBitmap(BG, CenterPlatform, 453,0, 6,16,   X+Border+46, Y+Height-Border-14,     Grey, 0,False,True, 255, 1)'bottom edge
		
		Grey= Height - (Border+49)*2
		TileBitmap(BG, CenterPlatform, 405,53,17,6,   X+Border, Y+Border+50, 0,   Grey, False,False, 255, 1)'left edge
		TileBitmap(BG, CenterPlatform, 405,53,17,6,   X+Width-Border-17, Y+Border+50, 0,   Grey, True,False, 255, 1)'right edge
		
		DrawBitmap(BG, CenterPlatform, 404,0, X+Border-1  ,Y+Height- Border -50, 48,52, False,True)'bottom left corner
		DrawBitmap(BG, CenterPlatform, 404,0, X+Width-Border-46  ,Y+Height- Border -50, 48,52, True,True)'bottom right corner
		
		ScaleBitmap(BG, CenterPlatform, 59,0,    345,51,    X+ Width*0.25, Y+Border/2,  Width*0.5,  0, False,False)'disconnect capacitor drive before opening
		ScaleBitmap(BG, CenterPlatform, 59,51,   300,28,    X+ Width*0.3, Y + Height*0.75 ,   Width*0.4,  0, False,False)'shield eyes	
		
	End If
End Sub
Sub DrawCenterOfFlux(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int)
	Dim NewSize As Point ,Src As Rect , Ratio As Double,X2 As Int ,Y2 As Int, X3 As Int, Y3 As Int ,Thickness As Int',X4 As Int, Y4 As Int
	
	X2= Rnd(0,255)
	X2=Colors.RGB(X2,X2,X2)
	LCAR.DrawRect(BG,X,Y,Width,Height,X2,0)'background
	'LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)'background
	Src= LCAR.SetRect(0,0,60,106)
	NewSize=API.Thumbsize(Src.Right,Src.Bottom, Width*0.33,Height*0.4, True ,False)
	'Ratio =  NewSize.X/Src.Right ' 0.2963 '(32/108)
	Thickness=NewSize.X* 0.25
	
	'0,0     59,106  'plug
	Y2=Y+ NewSize.X *0.75
	Ratio=NewSize.X*0.75
	Y3=Width*0.225
	
	BG.DrawBitmapFlipped(CenterPlatform, Src,  LCAR.SetRect( X,Y2, NewSize.X, NewSize.Y  ), False,True)'left
	DrawAngledGradients(BG, X+Ratio, Y+Ratio*2, Y3, Thickness*0.6, Colors.White, Colors.Black, 4, Stage, MaxStages-1)
	
	X2=X+Width-NewSize.X
	BG.DrawBitmap(CenterPlatform, Src,  LCAR.SetRect( X2,Y2, NewSize.X, NewSize.Y  ))'right
	
	'LCAR.DrawRect(BG, X2, Y+Ratio*2,  Thickness*0.6,Thickness*0.6, Colors.Red, 0)

	DrawAngledGradients(BG, X2+ NewSize.X*0.25 , Y+Ratio*2, -Y3, Thickness*0.6, Colors.White, Colors.Black, 4, Stage, MaxStages-1)
	
	
	'Ratio = Ratio * 61
	
	X2=X+Width/2
	Y2=Y+Height-NewSize.X*0.5
	Ratio = 1.0983606557377049180327868852459
	Src= LCAR.SetRect(459,0,67,61)
	X3=NewSize.X*Ratio
	Y3=NewSize.X
	
	
	'X4=X2
	'Y4=Y2
	X2=X2 - X3/2
	Y2=Y2- Y3/2
	BG.DrawBitmap(CenterPlatform, Src, LCAR.SetRect(X2, Y2, X3,Y3))
	Ratio=Width*0.4'Height*0.3
	NewSize.X = Colors.White 
	If LCAR.RedAlert Then NewSize.X = LCAR.GetColor(LCAR.LCAR_Redalert,False,255)
	DrawGradients(BG, X2 +Y3/2 - Thickness/2, Y2+Y3*0.25 -Ratio, Thickness, Ratio , NewSize.X, Colors.Black, -4, Stage, MaxStages-1,  True)
	
	
'	X3 = Trig.findXYAngle(X2,Y2, Ratio , 315,True)
'	Y3 = Trig.findXYAngle(X2,Y2, Ratio ,315,False)
'	BG.DrawBitmapRotated(CenterPlatform, Src, LCAR.SetRect(X3, Y3, NewSize.X, NewSize.Y ), 315)'bottom/middle
'	BG.DrawLine(X2,Y2,X3,Y3, Colors.Red,4)
'	BG.DrawLine(X2,Y2,X3+NewSize.X/2,Y3+NewSize.Y/2, Colors.blue,4)
End Sub


Sub DrawAngledGradients(BG As Canvas, x As Int, Y As Int, Size As Int, Thickness As Int, Color1 As Int, Color2 As Int, Blocks As Int, Cycle As Int, Cycles As Int)
	Dim Plist As Path , HalfThick As Int ,Length As Int , BlockWidth As Int,CycleWidth As Int,X2 As Int, Y2 As Int,temp As Int,CStage As Int
	Dim Grad As GradientCache 
	Grad=LCARSeffects.Gradients.Get(  LCARSeffects.CacheGradient( API.IIF(LCAR.RedAlert, LCAR.LCAR_Red, LCAR.LCAR_White ), Not(LCAR.RedAlert) ) )
	
	HalfThick=Thickness/2
	Length = Trig.FindDistance(0,0,Size,Size)
	BlockWidth= Length/(Blocks*2)
	'blockhalfwidth=BlockWidth*0.5
	'HalfBlockLength As Int  HalfBlockLength = Trig.FindDistance(0,0,blockhalfwidth,blockhalfwidth)
	CycleWidth= Max(2, BlockWidth/Cycles )
	
	X2=x
	Y2=Y
	
	temp= ((Cycles-1) -Cycle) * (CycleWidth-1)    'BlockWidth + (Cycle*(CycleWidth-1))
	If Size>0 Then
		MakePoint(Plist, x- HalfThick+Size, Y+HalfThick+Size)'right side bottom
		MakePoint(Plist, x+ HalfThick+Size, Y-HalfThick+Size)'right side top
		MakePoint(Plist, x+ HalfThick, Y-HalfThick)'left side top
		MakePoint(Plist, x- HalfThick, Y+HalfThick)'left side bottom
		If Cycle>0 Then X2=x- temp
		
		'BG.DrawLine(x,Y, x+Size,Y+Size ,Colors.Blue,Thickness)
	Else
		MakePoint(Plist, x- HalfThick, Y-HalfThick)'left side top
		MakePoint(Plist, x+ HalfThick, Y+HalfThick)'left side bottom	
		MakePoint(Plist, x+ HalfThick+Size, Y+HalfThick-Size)'right side bottom
		MakePoint(Plist, x- HalfThick+Size, Y-HalfThick-Size)'right side top
		If Cycle>0 Then  X2=x+ temp
		
		'BG.DrawLine(x,Y, x-Size,Y+Size ,Colors.Magenta,Thickness)
	End If
	If Cycle>0 Then Y2=Y-temp
	
	'CopyPlistToPath(Plist ,P, BG, Colors.red, 2,  False, False)
	BG.ClipPath(Plist)

	CStage=Cycle*2
	For temp=0 To Length*1.5 'Step 'CycleWidth-1
		If Size>0 Then
			BG.DrawLine(X2+HalfThick, Y2-HalfThick, X2-HalfThick, Y2+HalfThick, GetStageColor(CStage, Grad), CycleWidth)
			X2=X2+CycleWidth-1
		Else
			BG.DrawLine(X2+HalfThick, Y2+HalfThick, X2-HalfThick, Y2-HalfThick, GetStageColor(CStage, Grad), CycleWidth)
			X2=X2-CycleWidth+1
		End If
		Y2=Y2+CycleWidth-1
		CStage=HandleDir(CStage)
	Next
	
	BG.RemoveClip 
End Sub






Sub DrawWarpFieldStatus(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, Gradient As Boolean) As Boolean 
	Dim SizeX As Int,SizeY As Int ,Yellow As Int ,Orange As Int ,Gold As Int, BlackStart As Int, BlackWidth As Int, NacelleSpace As Int, NacelleY As Int, Whitespace As Int ,Center As Int
	Dim CenterHeight As Int, CoreLeft As Int, ElbowSize As Int ,CenterLeft As Int, NacelleEnd As Int,ElbowStart As Int, temp As Int,WarpCoreWidth As Int
	Dim BAR As Rect ,stroke As Int 
	LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
	If InitRandomNumbers(LCAR.LCAR_Engineering, False ) Then
		AddRowOfNumbers(0, LCAR.LCAR_Orange, Array As Int(2,1))
		DuplicateFirstLines(0,2)
		AddRowOfNumbers(1, LCAR.LCAR_Orange, Array As Int(4,1))
		DuplicateFirstLines(1,2)
		
		AddRowOfNumbers(2, LCAR.LCAR_Orange, Array As Int(2,1,   4,1,   2,1))
		'DuplicateFirstLines(2,10)
		
		AddRowOfNumbers(3, LCAR.LCAR_Orange, Array As Int(2,1))
		'DuplicateFirstLines(3,10)
	End If
	
	Yellow= LCAR.GetColor( LCAR.LCAR_Yellow , False,255)
	Orange= LCAR.GetColor( LCAR.LCAR_Orange , False,255)
	Gold=  LCAR.GetColor( LCAR.LCAR_Orange , Not(LCAR.RedAlert),255)
	WarpMode= Gradient
	'Stage=CStage*0.5
	SizeX=Min(Width,Height)*0.5
	SizeY=SizeX*0.2
	BlackWidth=SizeX * 0.125
	BlackStart=BlackWidth*2
	BlackWidth=BlackWidth*1.5
	NacelleSpace=SizeY* 0.33 'includes the whitespace
	NacelleY=Height*0.15
	Whitespace=2
	CenterHeight= BlackWidth*0.75
	SizeX=Width*0.5
	ElbowSize=50
	
	'left side of the top bar
	BG.DrawRect(LCAR.SetRect(X,Y, BlackStart-Whitespace, CenterHeight), GetWarpColor( Gold,Stage,0,1)     ,True,0)
	BG.DrawRect(LCAR.SetRect(X+BlackStart,Y+4, BlackWidth, CenterHeight-4), GetWarpColor( Gold,Stage,1,1),True,0)
	Center=X+BlackStart+Whitespace+BlackWidth
	CoreLeft=SizeX-BlackWidth
	BG.DrawRect(LCAR.SetRect(Center,Y, CoreLeft-Center, CenterHeight), GetWarpColor( Gold,Stage,2,1),True,0)
	Center=X+CoreLeft+Whitespace
	BG.DrawRect(LCAR.SetRect(Center,Y, BlackWidth*0.5, CenterHeight),GetWarpColor( Orange,Stage,3,1) ,True,0)
	
'	If LCAR.SmallScreen Then
		'BG.DrawRect(LCAR.SetRect(Center,Y, (CoreLeft-Center)*0.5, CenterHeight), GetWarpColor( Gold,Stage,2,1),True,0)
		Center=X+CoreLeft+Whitespace
		CenterLeft=Center+(BlackWidth*0.5)+Whitespace
'	Else
'		BG.DrawRect(LCAR.SetRect(Center,Y, CoreLeft-Center, CenterHeight), GetWarpColor( Gold,Stage,2,1),True,0)
'		Center=X+CoreLeft+Whitespace
'		BG.DrawRect(LCAR.SetRect(Center,Y, BlackWidth, CenterHeight),GetWarpColor( Orange,Stage,3,1) ,True,0)
'		CenterLeft=Center+BlackWidth+Whitespace
'	End If
	
	'the top-left vertical bar
	temp=Y+CenterHeight+Whitespace
	WarpCoreWidth=NacelleY-NacelleSpace*2-CenterHeight
	BG.DrawRect (LCAR.SetRect(X+BlackStart,temp, BlackWidth, WarpCoreWidth),GetWarpColor( Gold,Stage,2,1) ,True,0)  
	temp=temp+WarpCoreWidth
	BG.DrawRect (LCAR.SetRect(X+BlackStart,temp+Whitespace, BlackWidth, NacelleSpace-Whitespace*2),GetWarpColor( Orange,Stage,3,1) ,True,0)  
	temp=temp+NacelleSpace
	BG.DrawRect (LCAR.SetRect(X+BlackStart,temp, BlackWidth, NacelleSpace-Whitespace*2),GetWarpColor( Gold,Stage,4,1) ,True,0)  'the square above the nacelles 
	
	'nacelles
	temp=Min(CenterLeft-X,SizeX)
	SizeY=DrawNacelle(BG,X,Y+NacelleY, temp, SizeY,Yellow,Orange,BlackStart,BlackWidth, Stage, LCAR.LCAR_Orange)'top nacelle
	NacelleEnd=Y+NacelleY+SizeY+NacelleSpace
	DrawNacelle(BG,X,NacelleEnd, temp, SizeY, Yellow,Orange,BlackStart,BlackWidth, Stage, LCAR.LCAR_Orange)'bottom nacelle
	
	BlackStart=X+BlackStart
	BG.DrawRect (LCAR.SetRect(BlackStart,Y+NacelleY+SizeY+Whitespace, BlackWidth, NacelleSpace-Whitespace*2),GetWarpColor( Gold,Stage,5,1),True,0)  'the square between the nacelles
	SizeY=Y+NacelleY+SizeY*2+Whitespace+NacelleSpace
	NacelleEnd=SizeY
	BG.DrawRect (LCAR.SetRect(BlackStart,SizeY, BlackWidth, NacelleSpace-Whitespace*2),GetWarpColor( Gold,Stage,6,1),True,0)  'the square under the nacelles
	SizeY=SizeY+NacelleSpace-Whitespace
	BG.DrawRect (LCAR.SetRect(BlackStart-NacelleSpace*2+Whitespace,SizeY, NacelleSpace*2-Whitespace*2, NacelleSpace*2-Whitespace*2),GetWarpColor( Gold,Stage,7,1),True,0)'the left square 
	BG.DrawRect (LCAR.SetRect(BlackStart,SizeY, BlackWidth*2, NacelleSpace*2-Whitespace*2),GetWarpColor( Orange,Stage,7,1),True,0)'the right square 
	
	stroke=(NacelleSpace-Whitespace)*0.5
	DrawNumberLine(BG, BlackStart+BlackWidth*2+Whitespace, SizeY + NacelleSpace*2-Whitespace*2, BlackWidth*2, 0,  stroke, Orange, False,  Array As Int(BlackWidth, 10,20,9999), Array As Int(0,1), 0)
	
	SizeY=SizeY+NacelleSpace*2-Whitespace
	Center=Height*0.66-BlackWidth'-ElbowSize
	Center=Center+Whitespace+BlackWidth+ElbowSize-CenterHeight
	'BG.DrawRect (LCAR.SetRect(BlackStart,SizeY, BlackWidth, Center - SizeY-1),GetWarpColor( Gold,Stage,8,1),True,0)  replace with DrawGradients
	temp=Center - SizeY   +1
	'DrawGradients(BG, BlackStart, SizeY, BlackWidth, temp,  Gold, Colors.Black, -temp/BlackWidth, MaxStages-1-Stage,MaxStages-1,True)
	BAR.Initialize(BlackStart, SizeY, BlackWidth, temp)
	Center=Height*0.66-BlackWidth'-ElbowSize
	
	ElbowStart=Center+Whitespace-1'elbow below the nacelles
	'DrawElbow(BG,  BlackStart,ElbowStart  , BlackWidth+ElbowSize,BlackWidth+ElbowSize+1,  BlackWidth,CenterHeight, 2,  LCAR.LCAR_Orange, True, Stage,8,1) 
	
	Center=Center+Whitespace+BlackWidth+ElbowSize-CenterHeight
	'DrawCurve(BG, BlackStart, Center, BlackWidth, CenterHeight, LCAR.LCAR_Orange, True, Stage,2,BlackWidth,CenterHeight )
	
	
	'middle horizontal bars replace with DrawGradients
	BlackStart=BlackStart+BlackWidth + LCAR.LCARCornerElbow2.Width-Whitespace
	'Center=Center+Whitespace+BlackWidth+ElbowSize-CenterHeight
	'BG.DrawRect(LCAR.SetRect(BlackStart,Center, 10, CenterHeight), GetWarpColor( Gold,Stage,10,1),True,0)
	'BlackStart=BlackStart+10+Whitespace
	CoreLeft=X+ Width*0.75
	'BG.DrawRect(LCAR.SetRect(BlackStart,Center, CoreLeft-BlackStart-Whitespace, CenterHeight), GetWarpColor( Gold,Stage,11,2),True,0)
	temp=CoreLeft-BlackStart-Whitespace
	'DrawGradients(BG, BlackStart,Center, temp,CenterHeight,  Gold, Colors.Black,temp/BlackWidth,MaxStages-1-Stage,MaxStages-1,True)
	DrawBar(BG, BAR.Left ,BAR.Top, BAR.Right, BAR.Bottom,  temp,CenterHeight, Stage,BlackWidth,Gold, LCAR.LCAR_Orange, True)

	temp=BAR.Left+BlackWidth
	DrawNumberLine(BG, temp, BAR.Top + BAR.Bottom+CenterHeight, temp-X, 20, stroke, Orange, True, Array As Int(0, BlackWidth+10, 20, 10), Array As Int(2,3), Height)
	
	'the left side of the middle bar
	ElbowSize=ElbowSize*0.5
	'LCAR.DrawLCARelbow(BG, CenterLeft, Y, BlackWidth+ElbowSize, NacelleEnd, BlackWidth, CenterHeight, 1, LCAR.LCAR_Orange, True, "", 0, 255, False)
	DrawElbow(BG,CenterLeft, Y, BlackWidth+ElbowSize, NacelleEnd, BlackWidth, CenterHeight, 1, LCAR.LCAR_Orange, True, Stage, 4,3)
	
	CenterLeft=CenterLeft+ElbowSize
	temp=Y+NacelleEnd+1
	BG.DrawRect(LCAR.SetRect( CenterLeft, temp, BlackWidth, ElbowStart-temp-2), GetWarpColor( Gold,Stage,7,3), True,0)
	BG.DrawRect(LCAR.SetRect( CenterLeft, ElbowStart, BlackWidth, Center-ElbowStart-Whitespace*2),GetWarpColor( Orange,Stage,10,1) , True,0)
	
	'the bottom
	temp=Center+CenterHeight+Whitespace*2
	WarpCoreWidth=Height-temp-(LCAR.itemheight+Whitespace)*2
	BG.DrawRect(LCAR.SetRect( CenterLeft, temp, BlackWidth, WarpCoreWidth), GetWarpColor( Gold,Stage,13,3), True,0)
	BG.DrawRect(LCAR.SetRect( CenterLeft+BlackWidth+Whitespace, temp, BlackWidth, WarpCoreWidth), GetWarpColor( Gold,Stage,13,3), True,0)
	
	temp=temp+WarpCoreWidth+Whitespace'y
	WarpCoreWidth=CenterLeft-LCAR.leftside-Whitespace*2'x
	BlackStart=(BlackWidth*2)+(Whitespace*3)+LCAR.leftside'width
	DrawButton(BG,WarpCoreWidth , temp,BlackStart , LCAR.ItemHeight, LCAR.LCAR_Orange, API.GetString("alert_alert"), Stage,14,1)
	DrawButton(BG, WarpCoreWidth, temp+LCAR.ItemHeight+Whitespace, BlackStart, LCAR.ItemHeight, LCAR.LCAR_Orange, API.GetString("exit"), Stage,15,1)
	
	'the right side of the middle bar
	CenterLeft=CenterLeft+BlackWidth+Whitespace
	NacelleEnd=NacelleEnd*0.95
	'LCAR.DrawLCARelbow(BG, CenterLeft, Y,BlackWidth+ElbowSize, NacelleEnd, BlackWidth,CenterHeight, 0, LCAR.LCAR_Orange, True, "",0,255,False) 
	DrawElbow(BG, CenterLeft, Y, BlackWidth+ElbowSize, NacelleEnd,   BlackWidth,CenterHeight, 0, LCAR.LCAR_Orange, True, Stage, 4,3)
	
	temp=Y+NacelleEnd+Whitespace
	WarpCoreWidth=BlackWidth*0.5
	BG.DrawRect(LCAR.SetRect( CenterLeft, temp, BlackWidth,WarpCoreWidth), GetWarpColor( Orange,Stage,7,1), True,0)
	temp=temp+WarpCoreWidth+Whitespace
	BG.DrawRect(LCAR.SetRect( CenterLeft, temp, BlackWidth,Center-temp-Whitespace*2), GetWarpColor(  Gold,Stage,8,3), True,0)
	
	'warp core and the bits on the end
	WarpCoreWidth =  Min(Height,Width)*0.20
	temp=Stage
	If LCAR.RedAlert Then temp = (temp * 4) Mod MaxStages
	DrawWarpCore(BG, CoreLeft, Center, WarpCoreWidth, Height * 0.67, CenterHeight, temp,8, GetGrey(temp), LCAR.Classic_Blue, LCAR.LCAR_Red, 50,1, False, WarpCoreWidth, True, 0)' Colors.Gray
	BlackStart=CoreLeft+Whitespace+WarpCoreWidth
	BG.DrawRect(LCAR.SetRect(BlackStart,Center, Width*0.02, CenterHeight), GetWarpColor(  Gold,Stage,14,1),True,0)
	BlackStart=BlackStart+Width*0.02+Whitespace
	LCARSeffects.DrawPartOfCircle(BG,BlackStart, Center, CenterHeight, 5, GetWarpColor(  Gold,Stage,15,1), 0,0) 
	
	'right side of the top bar
	CenterLeft=CenterLeft+BlackWidth+ElbowSize+Whitespace
	BG.DrawRect(LCAR.SetRect(CenterLeft,Y, WarpCoreWidth, CenterHeight),GetWarpColor( Orange,Stage,2,2) ,True,0)
	CenterLeft=CenterLeft+WarpCoreWidth+Whitespace
	BG.DrawRect(LCAR.SetRect(CenterLeft,Y, Width-CenterLeft, CenterHeight),GetWarpColor(  Gold,Stage,0,2),True,0)
	
	'CStage=CStage+1
	'If CStage=MaxStages*2 Then CStage=0
End Sub


Sub DrawStatic(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CellWidth As Int, CellHeight As Int, MaxRed As Int)
	Dim temp As Int, temp2 As Int ,Grey As Int ,Red As Int ,Color As Int 
	For temp2 = Y To Y+Height Step CellHeight
		For temp = X To X+Width Step CellWidth
			If MaxRed>0 Then Red = Rnd(0, MaxRed)
			Grey = Rnd(0, 256)
			If Red<Grey Then Red=Grey 
			Color = Colors.RGB(Red, Grey,Grey)			
			LCAR.DrawRect(BG, temp,temp2, CellWidth,CellHeight, Color, 0)
		Next
	Next
End Sub
	
Sub DrawNumberLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, Color As Int, GoLeft As Boolean, Widths As List, NumberIDs As List , ObjectHeight As Int)
	Dim temp As Int ,Width2 As Int, UseThick As Boolean ,ThickStroke As Int,Size As Int  ,NumberIndex As Int, Y2 As Int,MaxHeight As Int 
	ThickStroke=Stroke*2
	If Height=0 Then 
		Y=Y-Stroke
	Else
		LCAR.DrawRect(BG,X,Y, Stroke, Height, Color, 0)
		Y=Y+Height-1
	End If
	If GoLeft Then X= X-Width+Stroke+1
	LCAR.DrawRect(BG,X,Y, Width-1, Stroke , Color, 0)
	Y2=Y+ThickStroke+Stroke+3
	If ObjectHeight>0 Then MaxHeight = ObjectHeight-Y2
	For temp = 0 To Widths.Size-1
		Width2= Widths.Get(temp)
		If Width2<0 Then Width2 = Width2 * -0.01 * Width'percent
		Width2= Min(Width2, Width-Size)
		'If Size+Width2>Width Then Width2 = Width-Size
		If UseThick  Then 
			LCAR.DrawRect(BG,X,Y, Width2,  ThickStroke  , Color, 0)
			If NumberIDs.Size>0 Then
				If NumberIndex< NumberIDs.Size Then DrawRandomNumbers(BG, X,Y2, LCAR.LCARfont, 10,Width, MaxHeight, NumberIDs.Get(NumberIndex))
				NumberIndex=NumberIndex+1
			End If
		End If
		X=X+Width2'-1
		Size=Size+Width2
		UseThick=Not(UseThick)
	Next
End Sub

Sub GetGrey(Stage As Int)As Int 
	Dim temp As Int 
	If Stage<8 Then
		temp = 72+8*Stage
	Else'8=16   9=15   10=14
		temp= (24-Stage)*8
	End If
	'temp=Max(16, Min(255,temp))
	Return Colors.RGB(temp,temp,temp)
End Sub
Sub DrawButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Text As String, Stage As Int, StartStage As Int, Stages As Int) 
	Dim Alpha As Int =255,State As Boolean
	If LCAR.RedAlert Then
		If Stage>=StartStage And Stage < StartStage+Stages Then
			ColorID= LCAR.LCAR_RedAlert
			State=True
			Alpha=-1-((Stage-StartStage)*8)
		Else
			ColorID= LCAR.LCAR_RedAlert
			State=False
		End If
	End If
	LCAR.DrawLCARbutton(BG,X,Y,Width,Height, ColorID,State, Text, "", LCAR.leftside, 0,False, 4, 4,-1,Alpha,False)
End Sub

Sub DrawElbow(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Align As Int, ColorID As Int,State As Boolean, Stage As Int, StartStage As Int, Stages As Int) As Int 
	Dim Alpha As Int =255
	If LCAR.RedAlert Then
		If Stage>=StartStage And Stage < StartStage+Stages Then
			ColorID= LCAR.LCAR_RedAlert
			State=True
			Alpha=-1-((Stage-StartStage)*8)
		Else
			ColorID= LCAR.LCAR_RedAlert
			State=False
		End If
	End If
	LCAR.DrawLCARelbow(BG, X, Y,Width, Height, BarWidth,BarHeight,Align, ColorID, State, "",0,Alpha,False) 
End Sub
Sub DrawNacelle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Color2 As Int, BlackStart As Int, BlackWidth As Int, Stage As Int, ColorID As Int)As Int
	Dim SizeY As Int ,SizeX As Int , SizeZ As Int ,SizeB As Int, P As Path , temp As Int,temp2 As Int, tempcache As GradientCache 
	If Height Mod 2=1 Then Height=Height-1
	
	tempcache = LCARSeffects.Gradients.Get(LCARSeffects.CacheGradient(API.IIF(LCAR.RedAlert, LCAR.LCAR_Red, ColorID), False) )
	'DrawLegacyButton(BG, X,Y,Width,Height, Color, "", Height*-0.5)
	temp2=Stage
	SizeZ=Height/16
	For temp = 0 To 15
		SizeX=SizeZ*temp'(7-temp)
		Color=tempcache.Stages(temp2)
		DrawLegacyButton(BG, X+SizeX,Y+SizeX,Width-SizeX*2,Height-SizeX*2, Color, "", Height*-0.5, 0)
		temp2=temp2+1
		If temp2>15 Then temp2 = 0
	Next
	
	
	SizeZ=Y+ Height*0.5
	SizeY=Height*0.25
	SizeB= Width-(Height*0.75)'*0.90
	
	BG.DrawRect( LCAR.SetRect(X, SizeZ -SizeY*0.5-1,SizeB, SizeY+2  ), Colors.Black, True,0)'black rect
	
	temp2=SizeY*0.75
	temp=SizeZ -temp2-1
	P.Initialize (X+BlackStart, temp)'top left
	P.LineTo(X+BlackStart+BlackWidth, temp)'top right
	P.LineTo(X+BlackStart+BlackWidth+temp2,SizeZ)'right right
	temp=SizeZ +temp2-1
	P.LineTo(X+BlackStart+BlackWidth, temp)'bottom right
	P.LineTo(X+BlackStart, temp)'bottom left
	P.LineTo(X+BlackStart-temp2,SizeZ)'left left
	BG.ClipPath (P)
	BG.DrawRect(LCAR.SetRect(X,Y,Width,Height), Colors.Black,True,0)'the black tabs
	BG.RemoveClip 
	
	SizeX=X+SizeB
	SizeY=Height*0.6
	LCARSeffects.DrawTriangle(BG, SizeX-SizeY*0.5+1, Y, SizeY,Height, 2, Colors.Black )'black triangle

	SizeY=(Height*0.25)*0.75
	If WarpMode Then
		LCARSeffects.MakeClipPath(BG,X+4,SizeZ -SizeY*0.5, SizeB, SizeY)
		'DrawGradients(BG,X+4,SizeZ -SizeY*0.5, Width*0.75, SizeY,  Color2,Colors.Black,3, Stage, MaxStages, False)
		DrawGradients(BG,X+4,Y, Width, Height,  Color2,Colors.Black,4, Stage, MaxStages-1, False)
		SizeY=Height*0.5
		LCARSeffects.DrawTriangle(BG, SizeX-SizeY*0.5+1, Y, SizeY,Height, 2, LCAR.LCAR_Clear )'orange triangle
		DrawGradients(BG,X+4,Y, Width, Height,  Color2,Colors.Black,4, Stage, MaxStages-1, False)
	Else
		BG.DrawRect( LCAR.SetRect(X+4,SizeZ -SizeY*0.5, SizeB, SizeY  ), Color2, True,0)'orange rect
		SizeY=Height*0.5
		LCARSeffects.DrawTriangle(BG, SizeX-SizeY*0.5+1, Y, SizeY,Height, 2, Color2 )'orange triangle
	End If
	Return Height
End Sub

Sub GetWarpColor(Color As Int, Stage As Int, StartStage As Int, Stages As Int) As Int
	If LCAR.RedAlert Then
		If Stage>=StartStage And Stage < StartStage+Stages Then
			Color=Min(255,255-(Stage-StartStage)*8)
			Return Colors.RGB( Color,Color,Color) 
		Else
			Return LCAR.GetColor(LCAR.LCAR_RedAlert, False,255)
		End If
	Else
		Return Color
	End If
End Sub

Sub DrawWarpCore(BG As Canvas, X As Int, CenterY As Int, Width As Int, Height As Int, CenterHeight As Int, Stage As Int,MaxCycles As Int, CenterAndEndsColor As Int, ColorUpID As Int, ColorDownID As Int, EndsHeight As Int, WhiteSpace As Int, EndStyle As Boolean, UnitWidths As Int, UseWhite As Boolean, CenterCornerRadius As Int) As Int
	Dim temp As Int, Y1 As Int, Y2 As Int , CycleHeight As Int, CurrStage As Int, MidCycle As Int, X2 = X + Width * 0.5 - UnitWidths * 0.5
	Y1=CenterY
	Y2=CenterY+CenterHeight+WhiteSpace
	EndsHeight=Width*0.33
	CycleHeight=(Height-CenterHeight-(EndsHeight*2)-(WhiteSpace*4)) * 0.5 / (MaxCycles+1)
	CurrStage=Stage
	MidCycle=MaxCycles*0.5
	For temp = 1 To MaxCycles
		Y1=Y1-CycleHeight
		DrawWarpCycle(BG,X2,Y1,UnitWidths, CycleHeight-WhiteSpace, CurrStage, ColorUpID,   True,  temp=MidCycle,  UseWhite)
		DrawWarpCycle(BG,X2,Y2,UnitWidths, CycleHeight-WhiteSpace, CurrStage, ColorDownID, False, False, 		  UseWhite)
		Y2=Y2+CycleHeight
		CurrStage=CurrStage+1
		If CurrStage>=MaxStages Then CurrStage=0
	Next
	CycleHeight = Y1-EndsHeight-WhiteSpace*2-1
	DrawWarpEnd(BG, X,CycleHeight,  Width, EndsHeight, CenterAndEndsColor, True, EndStyle, UnitWidths)
	DrawWarpEnd(BG, X,Y2+WhiteSpace,Width, EndsHeight, CenterAndEndsColor, False, EndStyle, UnitWidths)
	If CenterCornerRadius = 0 Then 
		BG.DrawRect( LCAR.SetRect(X,CenterY,Width,CenterHeight), CenterAndEndsColor, True,0)
	Else 
		DrawRoundRect(BG,X,CenterY,Width,CenterHeight, CenterAndEndsColor, CenterCornerRadius)
		BG.DrawCircle(X + Width * 0.5, CenterY + CenterHeight * 0.5, CenterHeight *0.35, Colors.black, False, CenterHeight*0.1)
	End If
	Return CycleHeight
End Sub













Sub DrawTextButton(BG As Canvas, X As Int, Y As Int, Width As Int, LColorID As Int, MColorID As Int, RColorID As Int,Alpha As Int, State As Boolean, Text As String, TColorID As Int, TState As Boolean, LeftSide As Boolean, IsMoving As Boolean )As Int 
	Dim temp As Int,temp2 As Int,textwidth As Int
	temp=3'whitespace
	LCAR.CheckNumbersize(BG)
	LCAR.DrawLCARbutton(BG,X,Y, LCAR.LeftSide, LCAR.ItemHeight,  LColorID, State, "", "", LCAR.LeftSide,0,False,0,0,-1,Alpha, IsMoving)
	LCAR.DrawLCARbutton(BG,X+LCAR.LeftSide+temp,Y, Width- (LCAR.LeftSide+temp)*2, LCAR.ItemHeight, MColorID, State, "","", 0,0,False,0,0,-1,Alpha, IsMoving)
	LCAR.DrawLCARbutton(BG,X+Width-LCAR.LeftSide,Y,  LCAR.LeftSide, LCAR.ItemHeight, RColorID, State, "", "", 0,LCAR.LeftSide,True,0,0,-1,Alpha,IsMoving)
	
	textwidth = BG.MeasureStringWidth(Text, LCAR.LCARfont, LCAR.NumberTextSize)
	If LeftSide Then
		temp=X+LCAR.LeftSide-1
		temp2=9
	Else
		temp=X+Width-LCAR.LeftSide-textwidth-temp*2-2
		temp2=3
	End If
	LCAR.DrawRect(BG, temp,Y,textwidth+temp2,  LCAR.ItemHeight, Colors.Black,0)
	LCAR.DrawLCARtextbox(BG, temp+2,API.IIF(LeftSide, 1,0) + Y, 0, LCAR.NumberTextSize, -1,-1, Text, TColorID , -1, -1,  TState, False,-5,Alpha)
	
	Return textwidth
End Sub

Sub DrawOmega(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int,Alpha As Int, DOS As Int, IsMoving As Boolean, Symbol As String, BlinkState As Boolean)
	Dim temp As Int, temp2 As Int ,NeedsInit As Boolean ,Text As String ,Textwidth As Int
	
	NeedsInit=True
	temp=3'whitespace
	'top
	'LCAR.CheckNumbersize(BG)
	'LCAR.DrawLCARbutton(BG,X,Y, LCAR.leftside, LCAR.ItemHeight,  LCAR.LCAR_Orange, False, "", "", LCAR.leftside,0,False,0,0,-1,Alpha,False)
	'LCAR.DrawLCARbutton(BG,X+LCAR.leftside+temp,Y, Width- (LCAR.leftside+temp)*2, LCAR.ItemHeight, LCAR.LCAR_Red, False, "","", 0,0,False,0,0,-1,Alpha, False)
	'LCAR.DrawLCARbutton(BG,X+Width-LCAR.leftside,Y, LCAR.leftside, LCAR.ItemHeight,  LCAR.LCAR_Purple, False, "", "", 0,LCAR.leftside,True,0,0,-1,Alpha,False)
	
	'top text
	
	Text="LCARS ACCESS " & API.PadtoLength(DOS, True, 4, "0")
	'If TopTextWidth = 0 Then TopTextWidth = BG.MeasureStringWidth(Text, LCAR.LCARfont, LCAR.NumberTextSize)
	'temp2=X+Width-LCAR.leftside-TopTextWidth-temp
	'LCAR.DrawRect(BG, temp2,Y,TopTextWidth+3,  LCAR.ItemHeight, Colors.Black,0)
	'LCAR.DrawLCARtextbox(BG, temp2+3,Y-1, 0, LCAR.NumberTextSize, 0,0, Text, LCAR.LCAR_Orange , 0, 0,  False, False,4,Alpha)
	
	DrawTextButton(BG,X,Y,Width,LCAR.LCAR_Orange,LCAR.LCAR_Red,LCAR.LCAR_Purple, Alpha,False, Text, LCAR.LCAR_Orange, False,False,IsMoving) 
	
	
	'Bottom
	temp2=Y+Height-LCAR.ItemHeight
	'LCAR.DrawLCARbutton(BG,X,temp2, LCAR.leftside, LCAR.ItemHeight,  LCAR.LCAR_Purple, False, "","", LCAR.leftside,0,False,0,0,-1,Alpha,False)
	'LCAR.DrawLCARbutton(BG,X+LCAR.leftside+temp,temp2, Width- (LCAR.leftside+temp)*2, LCAR.ItemHeight, LCAR.LCAR_LightPurple, False, "","", 0,0,False,0,0,-1,Alpha, False)
	'LCAR.DrawLCARbutton(BG,X+Width-LCAR.leftside,temp2, LCAR.leftside, LCAR.ItemHeight,  LCAR.LCAR_Orange, False, "", "", 0,LCAR.leftside,True,0,0,-1,Alpha,False)
	
	'Bottom text
	'temp=X+LCAR.leftside
	Text="STATUS: STAND-BY"
	'If CachedOmega.IsInitialized Then
	'	Textwidth = CachedOmega.Top
	'Else
	'	Textwidth= BG.MeasureStringWidth(Text, LCAR.LCARfont, LCAR.NumberTextSize)
	'End If
	'LCAR.DrawRect(BG, temp,temp2,Textwidth+9,  LCAR.ItemHeight, Colors.Black,0)
	'LCAR.DrawLCARtextbox(BG, temp+3,temp2-2, 0, LCAR.NumberTextSize, 0,0, Text, LCAR.LCAR_LightOrange , 0, 0,  True, False,4,Alpha)
	DrawTextButton(BG,X,temp2,Width,LCAR.LCAR_Purple,LCAR.LCAR_LightPurple,LCAR.LCAR_Orange, Alpha,False, Text, LCAR.LCAR_LightOrange, BlinkState, True,IsMoving) 
	
	temp=LCAR.ItemHeight +10' Height*0.125
	Y=Y+temp
	Height=Height-(temp*2)
	If CachedOmega.IsInitialized Then
		If CachedOmega.Right = Width And CachedOmega.Bottom = Height Then 
			temp = CachedOmega.Left 
			NeedsInit=False
		End If
	End If
	If NeedsInit Or OmegaNeedsInit Then
		temp = API.GetTextHeight(BG, Height, Symbol, LCAR.LCARfont)
		temp2 = API.GetTextHeight(BG, -Width, Symbol, LCAR.LCARfont)
		temp=Min(temp,temp2)
		CachedOmega.Initialize(temp, Textwidth, Width,Height)
		OmegaNeedsInit=False
	End If
	'LCAR.DrawTextbox(BG, "Ω", LCAR.Classic_Blue , X,Y,Width, temp, 5)
	BG.DrawRect(LCAR.SetRect(X,Y,Width,Height), Colors.Black, True,0)
	Y=Y+Height*0.5- BG.MeasureStringHeight("Ω", LCAR.LCARfont, temp)*0.5
	
	temp2=5
	Textwidth=-3
	LCAR.DrawLCARtextbox(BG, X-temp2,Y-temp2,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,True,False,Textwidth,-32)
	LCAR.DrawLCARtextbox(BG, X-temp2,Y,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,True,False,Textwidth,-32)
	LCAR.DrawLCARtextbox(BG, X-temp2,Y+temp2,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,True,False,Textwidth,-32)
	
	LCAR.DrawLCARtextbox(BG, X+temp2,Y+temp2,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,True,False,Textwidth,255)
	LCAR.DrawLCARtextbox(BG, X+temp2,Y-temp2,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,True,False,Textwidth,255)
	
	LCAR.DrawLCARtextbox(BG, X,Y,Width,temp, 0,0, Symbol, LCAR.Classic_Blue, LCAR.Classic_Blue,LCAR.Classic_Blue,False,False,Textwidth,255)
	
	If Alpha<255 Then BG.DrawRect(LCAR.SetRect(X,Y-5,Width,Height+5), Colors.ARGB(255-Alpha,0,0,0), True,0)
End Sub

Sub DrawWarpCycle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, ColorID As Int, Direction As Boolean, DrawPlasma As Boolean, UseWhite As Boolean)
	Dim Color As Int' ,PlasmaSpeed As Int
	If LCAR.RedAlert Then
		If Direction Then
			Color=Min(255,255-Stage*8)
			Color=Colors.RGB(Color,Color,Color)
		Else
			Color = LCAR.GetColor(LCAR.LCAR_RedAlert, Direction, -1 - Stage*8)
		End If
	Else if UseWhite Then 
		Color = LCAR.GetColor(ColorID, False, -1 - Stage*8)
	Else 
		Color = LCAR.GetColor(ColorID, False, min(255,Stage*16))
	End If
	BG.DrawRect(LCAR.SetRect(X,Y,Width,Height), Color, True,0)
'	If DrawPlasma Then
'		PlasmaSpeed=5
'		Color=Width*0.5
'		If LCAR.RedAlert Then 
'			PlasmaWidth = LCAR.Increment(PlasmaWidth, PlasmaSpeed, Color) 
'		Else If PlasmaWidth>0 Then 
'			PlasmaWidth = LCAR.Increment(PlasmaWidth, PlasmaSpeed,  0)
'			If PlasmaWidth=0 Then LCAR.ClearScreen(BG)
'		End If
'		If PlasmaWidth>0 Then
'			DrawKlingonTriangle(BG,X,Y+Height*0.5, PlasmaWidth, PlasmaWidth*2, Colors.White ,-6,0)
'		End If
'	End If
End Sub

Sub DrawWarpEnd(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Direction As Boolean, Style As Boolean, UnitWidths As Int)
	Dim Plist As Path, Dest As Rect, tempX As Int, tempY As Int, CenterX As Int
	Dest=LCAR.SetRect(X,Y,Width,Height)
	BG.DrawRect(Dest, Colors.black, True, 0)
	If Style Then 
		tempX = Width * 0.1818181818181818
		tempY = Height * 0.3095238095238095
		UnitWidths = UnitWidths * 0.5
		CenterX = X + Width * 0.5
	End If
	If Direction Then'V
		If Style Then 
			Plist.Initialize(X+tempX,Y)'TL
			Plist.LineTo(X+Width-tempX, Y)'TR
			Plist.LineTo(X+Width, Y+tempY)'MR
			'Plist.LineTo(X+Width*0.5, Y+Height)'B
			Plist.LineTo(CenterX + UnitWidths, Y+Height)'BR
			Plist.LineTo(CenterX - UnitWidths, Y+Height)'BL
			Plist.LineTo(X, Y+tempY)'ML
		Else 
			Plist.Initialize(X,Y)
			Plist.LineTo(X+Height,Y+Height)
			Plist.LineTo(X+Width-Height,Y+Height)
			Plist.LineTo(X+Width,Y)
		End If 
	Else if Style Then '^
		Plist.Initialize(X+tempX,Y+Height)'TL
		Plist.LineTo(X+Width-tempX, Y+Height)'TR
		Plist.LineTo(X+Width, Y+Height-tempY)'MR
		'Plist.LineTo(X+Width*0.5, Y)'B
		Plist.LineTo(CenterX + UnitWidths, Y)'BR
		Plist.LineTo(CenterX - UnitWidths, Y)'BL
		Plist.LineTo(X, Y+Height-tempY)'ML
	Else '^
		Plist.Initialize(X,Y+Height)
		Plist.LineTo(X+Height,Y)
		Plist.LineTo(X+Width-Height,Y)
		Plist.LineTo(X+Width,Y+Height)
	End If
	BG.DrawPath(Plist, Color, False, 1)
	BG.DrawPath(Plist, Color, True, 0)
End Sub








Sub PreCARSStyle(Title As String) As String 
	Dim tempstr As String,tempstr2 As String =""
	If Title.Length=0 Then
		tempstr= "{COLOR: WHITE;}" & CRLF
		tempstr= CRLF & "a:link " & tempstr & "a:visited " & tempstr & "a:hover " & tempstr & "a:active " & tempstr 
		'tempstr2= "{COLOR: WHITE;}" & CRLF
		'tempstr2= CRLF & "TL:link " & tempstr2 & "TL:visited " & tempstr2 & "TL:hover " & tempstr2 & "TL:active " & tempstr2 
		Return "<html><head><style Type='text/css'>" & tempstr & CRLF & tempstr2 & CRLF & "p.vtext { -webkit-transform:rotate(270deg); -moz-transform:rotate(270deg); -o-transform:rotate(270deg); max-width: 25px; white-space:nowrap; overflowy:hidden;} " & CRLF & "@font-face { font-family: 'Corporate Condensed';	src: url('file:///android_asset/precars.ttf')" & CRLF & "; }" & CRLF & "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><body></style></head>"  
	Else
		Return "<TR height=100%><TD COLSPAN=2 align=right width=49 valign=bottom><P class=vtext>" & Title.ToUpperCase & "</P></TD></TR>"
	End If
End Sub

Sub PreCARSFrame(DotColor As String, Content As String, ImageURL As String ,Title As String, Width As Int )As String
	Dim tempstr As StringBuilder , L As String : L="file:///android_asset/"
	tempstr.Initialize 
	If Title.Contains(" ") Then Title = API.Left(Title, API.Instr(Title, " ", 0))
	tempstr.Append("<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 width=" & Width & "%>")
	tempstr.Append("<TR><TD bgcolor=" & DotColor & " width=49><IMG src=" & L & "t1.png width=49 height=29></TD><TD background=" & L & "tm.gif><TD><IMG SRC=" & L & "tr.gif></TR>")
	tempstr.Append("<TR><TD background=" & L & "t2.png height=11 bgcolor=" & DotColor & "></TD><TD></TD><TD background=" & L & "mr.gif rowspan=2 width=5></TR>")
	tempstr.Append("<TR><TD background=" & L & "ml.gif valign=bottom align=center width=49>" & PreCARSSquare("black", "<IMG SRC='" & ImageURL & "' width=30 height=30>", L,  API.Left( Title,6)) )
	tempstr.Append("</TD><TD valign=top cellpadding=4><FONT COLOR=white>" & Content & "</FONT></TD></TR>")
	tempstr.Append("<TR><TD background=" & L & "bl.gif height=5 ><TD background=" & L & "bm.gif><TD background=" & L & "br.gif height=5 width=5></TR></TABLE><P>")
	Return tempstr.ToString 
End Sub
Sub PreCARSSquare(Color As String, Content As String,L As String, Title As String  ) As String 
	Return "<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 width=49 height=40>" & PreCARSStyle(Title) & "<TR valign=bottom><TABLE CELLSPACING=0 CELLPADDING=0 width=49><TR><TD colspan=3 background=" & L & "n1.gif height=12 width=49></TR><TR><TD background=" & L & "n2.gif width=4 height=1><TD align=center valign=bottom bgcolor=" & Color & ">" & Content & "</TD><TD background=" & L & "n3.gif><IMG SRC=" & L & "n3.gif></TR><TR><TD colspan=3 background=" & L & "n4.gif height=1 width=49></TR></TABLE>"
End Sub


Sub PreCARSButton(TopColor As String, TopContent As String,BottomColor As String, BottomContent As String, Filled As Boolean) As String 
	Return "<TABLE BORDER=0 width=100 CELLSPACING=0 CELLPADDING=0><TR><TD bgcolor=" & TopColor & " align=right height=14><IMG SRC=file:///android_asset/" & Filled & ".gif border=0></TD></TR><TR><TD bgcolor=" & TopColor & " align=center>" & TopContent & "</TD></TR><TR><TD height=2></TR><TR><TD height=13 bgcolor=" & BottomColor & " align=center><font size=-1>" & BottomContent & "</FONT></TD></TR></TABLE>"
End Sub





Sub GeneratePreCARSwave(Width As Int, Height As Int, NewMinorFrame As Boolean, NewMajorFrame As Boolean, Offset As Int, Alpha As Int) As Boolean 
	Dim BG As Canvas, NeedsInit As Boolean, Dest As Rect = LCARSeffects4.SetRect(0,0, Width,Height), Frame As Boolean = LCARSeffects4.TRI_Frame 
	'ClearFrames 		TRI_GetFrame		TRI_Frame=Not(TRI_Frame)
	NeedsInit = Not(LCARSeffects4.TRI_FrameB.IsInitialized) Or Not(LCARSeffects4.TRI_FrameA.IsInitialized )
	If Not(NeedsInit) Then NeedsInit = LCARSeffects4.TRI_FrameA.Width <> Width Or  LCARSeffects4.TRI_FrameA.Height <> Height
	If Not(NeedsInit) Then NeedsInit = LCARSeffects4.TRI_FrameB.Width <> Width Or  LCARSeffects4.TRI_FrameB.Height <> Height
	If NeedsInit Then 
		LCARSeffects4.TRI_FrameA.InitializeMutable(Width,Height)
		LCARSeffects4.TRI_FrameB.InitializeMutable(Width,Height)
	End If
	BG.Initialize2(LCARSeffects4.TRI_GetFrame(Frame))' 'LCARSeffects4.TRI_FrameA)'A is the dest
	If Not(NeedsInit) And (NewMinorFrame Or NewMajorFrame) Then
		BG.DrawBitmap(LCARSeffects4.TRI_GetFrame(Not(Frame)), LCARSeffects4.SetRect(Offset,Offset, Width-Offset*2,Height-Offset*2), Dest)'take frameB, draw over frameA at an offset
		BG.DrawColor(Colors.ARGB(Alpha,0,0,0))'draw over it with low-opacity black to fade out
	End If
	If NeedsInit Or NewMinorFrame Or NewMajorFrame Then
		Dim handpath As ABPath, paint As ABPaint  , tempX As Int = Rnd(Width*0.10, Width*0.20) , tempAngle As Int , LastPoint As Point 
		paint.Initialize '40,96,151		51,121,191		128,174,221
		paint.reset 
		paint.SetAntiAlias(True)
		paint.SetColor(Colors.rgb(51,121,191))'128,174,221
		'paint.SetRadialGradient2 
		paint.SetStyle(paint.Style_FILL)' paint.Style_STROKE)
		handpath.Initialize 
		Width=Width*0.5
		Height=Height*0.5
		LastPoint = MovePath(BG, Width, Height, tempX, 0, handpath)
		For tempAngle = 15 To 345 Step 15
			tempX = Rnd(Width*0.10, Width*0.20)
			LastPoint=QuadTo(BG, Width,Height,  tempX, tempAngle,  handpath,LastPoint)
		Next
		handpath.close 
		
		'BG.DrawLine(Width*0.5 - tempX, Height*0.5-tempX, Width*0.5+tempX, Height*0.5+tempX, Colors.Blue, 2)
		'Log("Draw: " & NeedsInit & " " &  Width & " " & Height & " " & Frame)
		
		'LCAR.ExDraw.clipPath2(BG, handpath)
		LCAR.ExDraw.drawPath(BG, handpath, paint)
		paint.SetStrokeWidth(2)
		paint.SetColor(Colors.rgb(128,174,221))
		paint.SetStyle(paint.Style_STROKE)
		LCAR.ExDraw.drawPath(BG, handpath, paint)
		
		LCARSeffects4.TRI_Frame= Not(Frame)
	End If
	'BG.Initialize2(LCARSeffects4.OffsetTRI_FrameB)
	'BG.DrawBitmap(LCARSeffects4.TRI_FrameA, Null, Dest)
	
	Return NeedsInit Or NewMinorFrame Or NewMajorFrame'LCARSeffects4.TRI_GetFrame(Frame)
End Sub
Sub QuadTo(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, Angle As Int, handpath As ABPath, LastPoint As Point) As Point 
	Dim X As Int = Trig.findXYAngle(centerX, centerY, Radius, Angle, True)
	Dim Y As Int = Trig.findXYAngle(centerX, centerY, Radius, Angle, False)
	handpath.QuadTo(LastPoint.X, LastPoint.Y, X,Y)
	Return Trig.SetPoint(X,Y)
End Sub




Sub DrawPreCARSButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Alpha As Int, TopContent As String, BottomContent As String, Filled As Boolean)
	Dim TopHeight As Int, BottomHeight As Int, tempRect As Rect ,Whitespace As Int=2,ScaleFactor As Float = LCAR.ScaleFactor, W2 As Int=15*ScaleFactor, H2 As Int = 17*ScaleFactor 'tempBMP As Bitmap  ,
	BottomHeight=(Height/3)-Whitespace
	TopHeight=Height-BottomHeight-Whitespace
	If cachedTS(0)<> Height Then
		cachedTS(0)=Height
		cachedTS(1)=API.GetTextHeight(BG, TopHeight*0.5, "ABC123", PCARfont)
		cachedTS(2)=API.GetTextHeight(BG, BottomHeight*0.75, "ABC123", PCARfont)
	End If
	'If Filled Then tempBMP=IsTrue Else tempBMP=isFalse
	
	BG.DrawRect(LCAR.SetRect(X,Y,Width,TopHeight), LCAR.GetColor(ColorID, State, Alpha), True,0)
	tempRect=LCAR.SetRect(X+Width-W2, Y, W2,H2)
	LCAR.DrawRect(BG,tempRect.Left-1,  tempRect.Top, W2+2,H2+1, Colors.Black, 0)
	BG.DrawRect(tempRect, Colors.ARGB(Alpha,228,228,228), True,0)
	BG.DrawCircle(X+Width-8*ScaleFactor,Y+8*ScaleFactor, 5*ScaleFactor, Colors.ARGB(Alpha,255,255,255), True,0)
	BG.DrawCircle(X+Width-8*ScaleFactor,Y+8*ScaleFactor, 5*ScaleFactor, Colors.ARGB(Alpha,0,0,0), False,1)
	If Filled Then BG.DrawCircle(X+Width-8*ScaleFactor,Y+8*ScaleFactor, 3*ScaleFactor, Colors.ARGB(Alpha,0,0,0), True,1)
	
	'BG.DrawBitmap(tempBMP, Null, tempRect )
	'If Alpha<255 Then BG.DrawRect(tempRect, Colors.ARGB( 255-Alpha,0,0,0), True,0)
	'BG.DrawText(TopContent, X+Width*0.5, Y+TopHeight*0.5, PCARfont,  cachedTS(1),  Colors.Black, "CENTER")
	API.DrawText(BG, API.LimitTextWidth(BG, TopContent,PCARfont,cachedTS(1), Width-4, "..."), X+Width*0.5,  Y+TopHeight*0.5-BG.MeasureStringHeight(TopContent, PCARfont, cachedTS(1))*0.5 ,PCARfont, cachedTS(1),  Colors.Black, 2)
	
	W2 = API.IIF(State, 128,196)
	W2 = Colors.ARGB(Alpha, W2,W2,W2) 'LCAR.GetColor(ColorID, Not(State), Alpha)
	BG.DrawRect(LCAR.SetRect(X,Y+TopHeight+Whitespace,Width,BottomHeight), W2, True,0)
	'BG.DrawText(BottomContent, X+Width*0.5, Y+Height-BottomHeight*0.5, PCARfont, cachedTS(2),  Colors.Black, "CENTER")
	API.DrawText(BG, BottomContent, X+Width*0.5, Y+Height-BottomHeight*0.5-BG.MeasureStringHeight(BottomContent, PCARfont, cachedTS(2))*0.5,PCARfont, cachedTS(2),  Colors.Black, 2)
	
	If KlingonVirus Then 
		'ENTFrames As Int, ENTSize As Int, ENTfontsize As Int, use TopContent
		LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.argb(Alpha*0.5,0,0,0), 0)
		If LCARSeffects3.ENTSize <> Height Then 
			LCARSeffects3.ENTSize = Height
			LCARSeffects3.ENTfontsize = API.GetTextHeight(BG, Height, "0123456789", KlingonFont)
		End If 
		BG.DrawText( API.Left(TopContent, 2), X + Width * 0.5, Y + Height, KlingonFont, LCARSeffects3.ENTfontsize, Colors.Red, "CENTER")
	End If
End Sub

Sub KlingonVirus As Boolean 
	Return LCAR.RedAlert And LCARSeffects3.ENTFrames <0
End Sub
Sub GetPreCARSminimumWidth(Height As Int) As Int 
	Dim Dest As Rect = GetEntCARSFrameUsableSpace(0,0, Height*2,Height, -1), Scalefactor As Float = LCAR.GetScalemode
	Return Images(0).Width * Scalefactor  + Dest.Bottom 
End Sub
Sub GetEntCARSFrameUsableSpace(X As Int, Y As Int, Width As Int, Height As Int, Radius As Int) As Rect 
	Dim Scalefactor As Float = LCAR.GetScalemode ,X2 As Int =  Images(0).Width * Scalefactor, Y2 As Int = Images(0).Height * Scalefactor
	Dim W2 As Int = Images(6).Width* Scalefactor, H2 As Int = Images(6).Height* Scalefactor
	If Radius>-1 Then Return LCARSeffects4.SetRect( X + X2, Y+ Y2, Width-X2- W2, Height-Y2-H2)
	Y2= Y2 - 5*Scalefactor 
	W2 = Width-X2
	H2 = Height-Y2
	Return LCARSeffects4.SetRect(X + X2, Y+ Y2, W2, H2)
End Sub

'Align: 0=top hor, 1=right ver, 2=down hor, 3=left ver
Sub DrawPreCARSMeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Int, Value As Int, Text As String, ColorID As Int, Sections As Int)
	Dim Color As Int = LCARSeffects3.ENTcolor(-3), Size As Rect, SectionSize As Int, Stroke As Int = 2, temp As Int,X2 As Int, X3 As Int , Right As Boolean 
	If ColorID>-2 Then
		DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0 , Text, 5, "")
		Size = GetEntCARSFrameUsableSpace(X,Y,Width,Height,0)
		X=Size.Left 
		Y=Size.Top 
		Width = Size.Right-X
		Height = Size.Bottom-Y
	End If
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	'LCARSeffects4.drawrect(BG,X,Y,Width,Height,Colors.Red,0)
	If Height > Width Then'| vertical
		SectionSize = Floor(Height / Sections)
		temp= Y+Height*0.5
		X2=DrawPreCARSmeterunit(BG,X, Y+Height*0.5 - SectionSize*1.5, Width, SectionSize-Stroke, Align, 0,  Stroke, Color)
		DrawPreCARSmeterunit(BG,X, temp - SectionSize*0.5, Width, SectionSize-Stroke, Align, 0,  Stroke, Color)
		X3=DrawPreCARSmeterunit(BG,X, Y+Height*0.5 + SectionSize*0.5, Width, SectionSize-Stroke, Align, 0,  Stroke, Color)
		Do Until X2<= Y
			X2=DrawPreCARSmeterunit(BG,X, X2-SectionSize, Width, SectionSize-Stroke, Align, 1,  Stroke, Color)
			X3=DrawPreCARSmeterunit(BG,X, X3+SectionSize, Width, SectionSize-Stroke, Align, 2,  Stroke, Color)
		Loop

		X2=X
		X3=Width*0.5 - Stroke
		Right=Align=3
		If Right Then X2 = X+Width*0.5 + Stroke
		
		If Sections = 8 And ColorID = LCAR.Classic_Blue Then
			DrawPreCARSbar(BG, X2, temp- SectionSize*2.3+Stroke*2			,X3,		(SectionSize*0.8)-Stroke*3,		Right, True,	False, 	Colors.RGB(190,20,20))
			DrawPreCARSbar(BG, X2, temp- SectionSize*1.5					,X3,		SectionSize-Stroke*3,			Right, True,	False, 	Color)
			DrawPreCARSbar(BG, X2, temp-  SectionSize*0.5-Stroke*2         	,X3,      	SectionSize+Stroke*2,           Right, True, 	True, 	Color)
			DrawPreCARSbar(BG, X2, temp+ SectionSize*0.5+Stroke				,X3,		SectionSize-Stroke*2,			Right, False,	True, 	Color)
			DrawPreCARSbar(BG, X2, temp+ SectionSize*1.5					,X3,		(SectionSize*0.8)-Stroke*3,		Right, False,	True, 	Colors.RGB(190,20,20))
		Else If Sections = 8 And ColorID<0 Then
			DrawPreCARSbar(BG, X2, temp- SectionSize*3						,X3,		SectionSize*2.5-Stroke,			Right, True,	False, 	Color)
			DrawPreCARSbar(BG, X2, temp-  SectionSize*0.5         			,X3,      	SectionSize-Stroke,           	Right, True, 	True, 	Color)
			DrawPreCARSbar(BG, X2, temp+ SectionSize*0.5					,X3,		SectionSize*2.5,				Right, False,	True, 	Color)
		End If

		SectionSize = SectionSize * 0.5
		Y = Y + ((Height-SectionSize) * (Value * 0.01))
		If Align=3 Then X=X+ Width*0.45
		If Align >-1 Then DrawPreCARScursor(BG,X, Y, SectionSize*1.4,SectionSize,Align)
	Else'--- horizontal
		SectionSize = Floor(Width / Sections)
		X2=X+Width
		For temp = X To X2 Step SectionSize
			DrawPreCARSmeterunit(BG, temp,Y, SectionSize-Stroke, Height, 0, 0, Stroke, Color)
			Width=Width-SectionSize
		Next
		LCARSeffects4.DrawRect(BG,temp,Y, Width-Stroke,Height, Color,0)
	End If
	BG.RemoveClip 
End Sub



Sub DrawPreCARScursor(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Int)
	Dim P As Path
	AddPointRotated(P, X, Y, Width, Height, Align, 0.5, 0)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.79, 0.62)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.92, 0.69)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.95, 0.8)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.64, 0.87)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.5, 1)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.36, 0.87)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.05, 0.8)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.08, 0.69)
	AddPointRotated(P, X, Y, Width, Height, Align, 0.21, 0.62)
	BG.DrawPath(P, Colors.White,True, 0)	
End Sub

'Align: 0=north, 1=right, 2=down, 3=left
Sub AddPointRotated(P As Path, X As Int, Y As Int, Width As Int, Height As Int, Align As Int, X2 As Float, Y2 As Float)'X2/Y2 normalized pointing north
	Dim Xd As Int, Yd As Int 
	Select Case Align
		Case 0'north/up
			Xd= X+ Width*X2
			Yd= Y+ Height*Y2
		Case 1'right/east, rotate right
			Xd= X+ Width * (1-Y2)
			Yd= Y+Height*X2
		Case 2'south/down, flip vertically
			Xd= X+ Width*X2
			Yd= Y+ Height*(1-Y2)
		Case 3'left/west, rotate left
			Xd= X+ Width *Y2
			Yd= Y+Height*X2
	End Select
	If P.IsInitialized Then P.LineTo(Xd,Yd) Else P.Initialize(Xd,Yd)
End Sub

Sub DrawPreCARSgraph(BG As Canvas,  X As Int, Y As Int, Width As Int, Height As Int, Text As String, ColorID As Int, SmallGraph As String, GraphColorID As Int, iPercent As Int)
	Dim Size As Rect = GetEntCARSFrameUsableSpace(X,Y,Width,Height,0), Stroke As Int = 2, Stroke2 = 5, Percent As Float = iPercent * 0.01, P As Path 
	DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0 , Text, 5, "")
	X=Size.Left 
	Y=Size.Top
	Width = Size.Right-X
	Height = Size.Bottom-Y'-Stroke
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	P = LCARSeffects5.DrawSmallGraph2(X,Y,Width,Height, SmallGraph, Percent)
	If Stroke2>0 Then BG.DrawPath(P, LCAR.GetColor(GraphColorID, False, 128), False, Stroke2)
	BG.DrawPath(P, LCAR.GetColor(GraphColorID, False, 255), False, Stroke)
	BG.RemoveClip 
End Sub
Sub DrawPreCARS2Meters(BG As Canvas,  X As Int, Y As Int, Width As Int, Height As Int, Text As String, ColorID As Int) As Rect 
	Dim Size As Rect = GetEntCARSFrameUsableSpace(X,Y,Width,Height,0), Size2 As Int ,Stroke As Int = 2, temp As Int = 30 * LCAR.GetScalemode 'Images(0).Width
	DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0 , Text, 5, "")
	X=Size.Left 
	Y=Size.Top + Stroke
	Width = Size.Right-X
	Height = Size.Bottom-Y'-Stroke
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	Size2 = Ceil(Height / LCAR.ItemHeight)
	Size2 = DrawPreCARSTwoAxisMeter(BG, X+Stroke,Y,Width-Stroke,Height-Stroke,Size2, Stroke, temp)
	X=X+Size2
	Width=Width-Size2
	Height=Height-Size2- Stroke*2-temp
	BG.RemoveClip 
	Return LCARSeffects4.SetRect(X+Stroke*2,Y-1,Width-Stroke*5,Height)
End Sub
Sub DrawPreCARS2MetersTop(BG As Canvas,  X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int, Stroke As Int = 2,RowSize As Int = 30 * LCAR.GetScalemode', Cols As Int = Floor(Width/RowSize), UnitsY As Int = (Height / LCAR.ItemHeight)+1, Rows As Int = Floor(Height / RowSize)
	Dim Last As Boolean, Finish As Int = Y+Height-RowSize*0.5, Color As Int  = LCARSeffects3.ENTcolor(-5), Top As Boolean = True, Units As Int , Unit As Int , UnitsX As Int = Floor(Width/RowSize) - 4
	Dim First As Boolean, X1 As Int = X+RowSize*3 , X2 As Int = X+RowSize*UnitsX
	DrawPreCARSbar(BG, X1, Y, RowSize-Stroke, RowSize-Stroke, False, True, False, Color)
	DrawPreCARSbar(BG, X2, Y, RowSize-Stroke, RowSize-Stroke, True, True, False, Color)
	Color = LCARSeffects3.ENTcolor(-6)
	Y=Y+RowSize
	Units = ((Finish - Y) / (RowSize+1) ) + 1
	For temp = Y To Finish Step RowSize
		Unit=Unit+1
		Last = Units = Unit
		If Unit > Units*0.5 And Top Then 
			Top=False
			First=(Units Mod 2) = 1
		End If
		If Last Then Color = LCARSeffects3.ENTcolor(-5)
		BG.DrawLine(X, temp, X+Width+Stroke, temp, Colors.Black, Stroke)
		DrawPreCARSbar(BG, X1, temp+1, RowSize-Stroke, RowSize-Stroke, False, API.IIF(First, False, Top), API.IIF(First, False, Not(Top)), Color)
		DrawPreCARSbar(BG, X2, temp+1, RowSize-Stroke, RowSize-Stroke, True, API.IIF(First, False, Top), API.IIF(First, False, Not(Top)), Color)
		First=False
	Next
End Sub

Sub DrawPreCARSSin(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, ColorID As Int, Amplitude As Int, Wavelength As Int, Phase As Int, Color As Int)
	Dim Size As Rect = DrawPreCARS2Meters(BG,X,Y,Width,Height,Text,ColorID) 'GetEntCARSFrameUsableSpace(X,Y,Width,Height,0), Size2 As Int ,Stroke As Int = 2, temp As Int = Images(0).Width * LCAR.GetScalemode 
	'DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0 , Text, 5, "")
	X=Size.Left 
	Y=Size.Top 
	Width = Size.Right-X
	Height = Size.Bottom-Y
	'LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	'Size2 = Ceil(Height / LCAR.ItemHeight)
	'Size2 = DrawPreCARSTwoAxisMeter(BG, X+Stroke,Y,Width-Stroke,Height-Stroke,Size2, Stroke, temp)
	'X=X+Size2
	'Width=Width-Size2
	'Height=Height-Size2- Stroke*2-temp
	'LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Colors.Red, 0)
	If Wavelength = 0 Then 
		DrawPreCARSfreq(BG,X,Y,Width,Height)
	Else
		Wavelength = Wavelength *  0.01 * Width
		Phase = Phase * 0.01 * Width
		LCARSeffects3.CHX_DrawSINwave(BG,X,Y,Width,Height, Phase, Amplitude * 0.005 * Height, Wavelength, Colors.White, 2, True)
	End If
	'BG.RemoveClip 
	DrawPreCARS2MetersTop(BG,X,Y,Width,Height)
End Sub

'If bottom is below 0 then autoselect it's size to be the same as the meter * abs(bottom)
Sub DrawPreCARSTwoAxisMeter(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, UnitsY As Int, Stroke As Int, Bottom As Int) As Int 
	Dim Y2 As Int = Y, X2 As Int=X+Stroke, SectionSize As Int , Color As Int = LCARSeffects3.ENTcolor(-3), Color2 As Int = LCARSeffects3.ENTcolor(-4)
	If Bottom<>0 Then
		If Bottom <0 Then Bottom= Height / (UnitsY+1+Abs(Bottom))
		LCARSeffects4.DrawRect(BG,X-Stroke,Y+Height-Bottom,Width+Stroke*2,Bottom+Stroke, LCARSeffects3.ENTcolor(-8), 0)
		Height=Height-Bottom
	End If
	Width=Width-Stroke
	SectionSize= Height / (UnitsY+1)
	For temp = 1 To UnitsY
		DrawPreCARSmeterunit(BG, X+Stroke,Y2, (SectionSize-Stroke)*2, SectionSize-Stroke,  3,0, Stroke, Color)
		Y2=Y2+SectionSize
	Next
	DrawPreCARSmeterunit(BG, X+Stroke,Y2, SectionSize-Stroke, SectionSize-Stroke,  -1,0, Stroke,Color)
	UnitsY=Floor(Width / SectionSize)-1
	For temp = 1 To UnitsY
		X2=X2+SectionSize	
		DrawPreCARSmeterunit(BG, X2, Y2, SectionSize-Stroke, SectionSize-Stroke, 0,0, Stroke,API.IIF(temp<4 Or temp>(UnitsY-3), Color, Color2))
	Next
	temp=(Width Mod SectionSize) - Stroke *2
	If temp >0 Then LCARSeffects4.DrawRect(BG, X2+SectionSize, Y2, temp, SectionSize-Stroke, Color, 0)
	Return SectionSize
End Sub

Sub DrawPreCARSbar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Right As Boolean, Top As Boolean, Bottom As Boolean, Color As Int)
	Dim Stroke As Int = Width * 0.3, Stroke2 As Int = Stroke*0.5
	If Top Then LCARSeffects4.DrawRect(BG,X,Y,Width,Stroke2, Color, 0)
	If Bottom Then  LCARSeffects4.DrawRect(BG,X,Y+Height - Stroke2,Width,Stroke2, Color, 0)
	If Right Then X = X + Width-Stroke
	LCARSeffects4.DrawRect(BG,X,Y, Stroke,Height, Color,0)
End Sub

'Align: 0=top hor, 1=right ver, 2=down hor, 3=left ver
'Style: 0=0.75 width, 1=divit sticking out the top/left, 2=divit sticking out the bottom/right
Sub DrawPreCARSmeterunit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Align As Int, Style As Int,Stroke As Int, Color As Int) As Int 
	Dim Width2 As Int = Width*0.5, Height2 As Int = Height*0.5, width3 As Int = Width2*0.3, height3 As Int = Height2*0.3, temp As Int =Width*0.20, temp2 As Int =Height * 0.20
	Select Case Align & "." & Style
		'left edges
		Case "3.0"
			LCARSeffects4.DrawRect(BG,X+width3,Y,Width2-width3,Height,Color,0)
		Case "3.1", "3.2", "3.3"
			LCARSeffects4.DrawRect(BG,X,Y,Width2,Height, Color,0)
			If Style=1 Then
				BG.DrawLine(X+Width2, Y+temp2, X+Width2+width3, Y+temp2, Color, Stroke)
			Else If Style=2 Then
				BG.DrawLine(X+Width2, Y+Height-temp2-Stroke, X+Width2+width3, Y+Height-temp2-Stroke, Color, Stroke)
			End If
		
		'right edges
		Case "1.0"'right edge, style 0
			LCARSeffects4.DrawRect(BG,X+Width2,Y,Width2-width3,Height,Color,0)
		Case "1.1", "1.2"
			LCARSeffects4.DrawRect(BG,X+Width2,Y,Width2,Height, Color,0)
		
		'corner with circles in it
		Case "-1.0"
			temp=Min(Width,Height) * 0.5
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Color,0)
			BG.DrawCircle( X+Width2, Y+Height2, temp*0.8, Colors.Rgb(196,196,196), True,2)
			BG.DrawCircle( X+Width2, Y+Height2, temp*0.8, Colors.Black, False,2)
			
		'top edges (0)
		'bottom edges (2)
		
		Case Else
			LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Color,0)
	End Select
	'Divits
	Select Case Align 
		Case 1,3 
			If Align=3 Then X= X+ Width2-width3 Else X=X+Width2
			For temp = Y+temp2 To Y+Height-temp2 Step temp2
				BG.DrawLine(X, temp, X+width3,temp, Colors.black, Stroke)
			Next
			Return Y
		Case 0,2
			If Align=2 Then Y= Y+ Height2-height3' Else Y=Y+Height2
			For temp = X+temp To X+Width-temp Step temp
				BG.DrawLine(temp, Y, temp, Y+height3*2, Colors.Black, Stroke)
			Next
			Return X
	End Select
End Sub

Sub DrawPreCARSRND(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Text As String, RND_ID As Int, ButtonOffset As Int)'	ENT_RndNumbers
	Dim Size As Rect, WhiteSpace As Int = 10 * LCAR.GetScalemode 
	DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0, Text, 5, "")
	Size = GetEntCARSFrameUsableSpace(X,Y,Width,Height,-1)
	X=Size.Left 
	Y=Size.Top 
	Width = Size.Right-X
	Height = Size.Bottom-Y
	LCARSeffects.MakeClipPath(BG,X ,Y, Width-WhiteSpace,Height-WhiteSpace)
	DrawNumberBlock(BG,X+WhiteSpace ,Y+WhiteSpace, Width-WhiteSpace*3+1,Height-WhiteSpace*2+1, ColorID, RND_ID, LCAR.ENT_RndNumbers,"")
	BG.RemoveClip 
	'If API.debugMode Then LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange, False,255, "ID: " & RND_ID)
End Sub
Sub DrawPreCARSRadar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle1 As Int, Angle2 As Int, Angle3 As Int, ColorID As Int, Text As String, ButtonOffset As Int)
	Dim Size As Rect, CenterX As Int,  CenterY As Int, Radius As Int, Color As Int = LCARSeffects3.ENTcolor(-3), Radius2 As Int
	DrawPreCARSFrame(BG,X,Y,Width,Height,ColorID, 255,0, 0, 0, Text, 5, "")
	Size = GetEntCARSFrameUsableSpace(X,Y,Width,Height,-1)
	X=Size.Left 
	Y=Size.Top 
	Width = Size.Right-X
	Height = Size.Bottom-Y
	Radius = Height * 0.5 'Min(Width,Height) * 0.5 
	LCARSeffects4.DrawRect(BG, X + Width- Radius, Y, Radius, Height, Colors.black, 0)
	CenterX = X + Max(Radius, Width - Radius)
	CenterY = Y + Radius
	
	BG.DrawCircle(CenterX,CenterY,Radius, Colors.Black, True, 0)
	Radius=Radius-10
	
	Radius2=Radius*0.25
	DrawPreCARSGradient(BG, CenterX,CenterY, Radius, Angle1, Radius2)',		0,0,0,0)
	DrawPreCARSGradient(BG, CenterX,CenterY, Radius*0.75, Angle2, Radius2)',	0,0,0,0)
	DrawPreCARSGradient(BG, CenterX,CenterY, Radius*0.50, Angle3, Radius2)', 	0,0,0,0)
	
	LCARSeffects4.SOL_DrawMiniCompass(BG,CenterX,CenterY, Radius, Color, 2 * LCAR.GetScalemode, Radius2, 22.5)
	DrawPreCARSStuff(BG,CenterX, CenterY, Radius*0.80, Radius*-0.05, 10, Colors.RGB(255, 127,39))
	DrawPreCARSUnits(BG,CenterX, CenterY, Radius, Color, 5, 100, 0.25, 10)
End Sub	
Sub DrawPreCARSUnits(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, Color As Int, TextSize As Int, IncText As Int, IncPercent As Float, Offset As Int)
	Dim temp As Int, Count As Int = (1 / IncPercent) - 1, Text As Int , Distance As Int, DistanceInc As Int = Radius * IncPercent
	For temp = 1 To Count
		Text=Text+IncText
		Distance = Distance + DistanceInc
		
		API.DrawText(BG, Text, centerX + Distance - Offset, centerY + Offset, Typeface.DEFAULT, TextSize, Color, 6)
		API.DrawText(BG, Text, centerX + Offset, centerY -Distance + Offset, Typeface.DEFAULT, TextSize, Color, 4)
		
		API.DrawTextaligned(BG,  Text, centerX - Distance + Offset, centerY - Offset, 0, Typeface.DEFAULT, TextSize, Color, -4, 0,0)
		API.DrawTextaligned(BG,  Text, centerX - Offset, centerY + Distance - Offset, 0, Typeface.DEFAULT, TextSize, Color, -9, 0,0)
	Next
End Sub

'The circular orange bracket
Sub DrawPreCARSStuff(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, InnerRadius As Int, Stroke As Int, Color As Int)
	Dim P As Path , Stroke2 As Int = Stroke * 0.5
	MakePathPoint(P, centerX,centerY, 67.5  ,0)
	MakePathPoint(P, centerX,centerY, 247.5,0)
	MakePathPoint(P, centerX,centerY, 292.5,0)
	MakePathPoint(P, centerX,centerY, 112.5,0)
	BG.ClipPath(P)
	BG.DrawCircle(centerX,centerY,Radius, Color, False,Stroke)
	BG.RemoveClip 
	Stroke = Stroke * 0.66
	LCARSeffects4.SOL_DrawCompassUnit(BG, centerX,centerY, Radius+Stroke2,InnerRadius-Stroke2, 67.5, Color,  Stroke, 0,0)
	LCARSeffects4.SOL_DrawCompassUnit(BG, centerX,centerY, Radius+Stroke2,InnerRadius-Stroke2, 247.5, Color,  Stroke, 0,0)
	LCARSeffects4.SOL_DrawCompassUnit(BG, centerX,centerY, Radius+Stroke2,InnerRadius-Stroke2, 292.5, Color,  Stroke, 0,0)
	LCARSeffects4.SOL_DrawCompassUnit(BG, centerX,centerY, Radius+Stroke2,InnerRadius-Stroke2, 112.5, Color,  Stroke, 0,0)
End Sub
'If radius = 0 then it'll use cached angles
Sub MakePathPoint(P As Path, centerX As Int, centerY As Int, Angle As Int, Radius As Int)
	Dim tempP As Point
	If Radius=0 Then 
		tempP =LCARSeffects.CacheAngles(0,Trig.CorrectAngle( Angle ))
	Else
		tempP = Trig.FindAnglePoint(centerX,centerY,Radius,Angle)
	End If
	If P.IsInitialized Then
		P.LineTo(centerX+ tempP.X,  centerY+ tempP.Y)
	Else
		P.Initialize(centerX+ tempP.X,  centerY+ tempP.Y)
	End If
End Sub

Sub DrawPreCARSGradient(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, Angle As Int, CenterRadius As Int)
	DrawRadarWave(BG, centerX, centerY, CenterRadius, Radius, 45, 255,255,255, Angle)
	
'	Dim HR As Int = Radius * 0.5, HR2 As Int = HR * 0.5, handpath As ABPath, Oval As ABRectF, Sweep As Int = 75 ', R2 As Int = radius * 2
'	Dim X As Int = Trig.findXYAngle(centerX, centerY, HR, Angle, True)
'	Dim Y As Int = Trig.findXYAngle(centerX, centerY, HR, Angle, False)
'	X=X-HR2
'	Y=Y-HR
'	
'	Oval.Initialize(centerX-Radius, centerY-Radius,  centerX+Radius, centerY+Radius)
'	handpath.Initialize
'	handpath.arcTo(Oval, Angle+270, -Sweep)
'	Oval.Initialize(centerX-CenterRadius, centerY-CenterRadius,  centerX+CenterRadius, centerY+CenterRadius)
'	handpath.arcTo(Oval, Angle+270-Sweep, Sweep)
'	
'	LCAR.ExDraw.clipPath2(BG, handpath)
'	centerX = Trig.findXYAngle(X, Y, HR2, Angle+270, True)
'	centerY = Trig.findXYAngle(X, Y, HR2, Angle+270, False)
'	LCAR.DrawGradient(BG, Colors.ARGB(0,255,255,255), Colors.ARGB(196, 255,255,255), 6, centerX, centerY, Radius*0.5, Radius, 0, Angle)
'	
'	'LCAR.DrawGradient(BG, Colors.ARGB(0,255,255,255), Colors.ARGB(196, 255,255,255), 6, centerX, centerY, Radius*0.5, Radius, -Radius, Angle)
'	BG.RemoveClip 
End Sub
Sub MovePath(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, Angle As Int, handpath As ABPath) As Point 
	If Angle<360 Then Angle = Angle + 360
	Dim X As Int = Trig.findXYAngle(centerX, centerY, Radius, Angle, True)
	Dim Y As Int = Trig.findXYAngle(centerX, centerY, Radius, Angle, False)
	handpath.moveto(X, Y)
	Return Trig.SetPoint(X,Y)
End Sub

Sub DrawPreCARScoloredsquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorOffset As Int) As Int 
	Dim Width2 As Int = Width*0.5, Height2 As Int = Height * 0.5, P As Path, Stroke As Int, Size As Int = 15 * LCAR.ScaleFactor 
	Dim TheColors() As Int = Array As Int(Colors.RGB(149,143,165), Colors.RGB(149,162,193), Colors.RGB(148,161,186), Colors.RGB(112,112,43), Colors.RGB(130,140,186), Colors.RGB(45,153,209), Colors.RGB(199,83,44))
	Stroke=TheColors((ColorOffset + 1) Mod TheColors.Length)
	
	LCARSeffects4.DrawRect(BG, X,Y, Width2,Height2, TheColors(ColorOffset Mod TheColors.Length),0)
	LCARSeffects4.DrawRect(BG, X+Width2,Y, Width2,Height2, Stroke,0)
	LCARSeffects4.DrawRect(BG, X,Y+Height2, Width2,Height2, TheColors((ColorOffset + 2) Mod TheColors.Length),0)
	LCARSeffects4.DrawRect(BG, X+Width2,Y+Height2, Width2,Height2, TheColors((ColorOffset + 3) Mod TheColors.Length),0)
	
	LCARSeffects4.DrawRect(BG, X+Width-Size*2,Y+Size, Size,Size, Colors.Black,0)
	BG.DrawCircle(X+Width-Size*1.5,Y+Size*1.5, Size*0.25, Stroke, True, 0)
	
	P.Initialize(X+Width2,Y+Height2)
	P.LineTo(X+Width*0.25,Y)
	P.LineTo(X+Width*0.75,Y)
	BG.DrawPath(P, TheColors((ColorOffset + 4) Mod TheColors.Length), True, 0)
	
	Stroke=2
	BG.DrawLine(X, Y+Height2, X+Width, Y+Height2, Colors.Black, Stroke)
	BG.DrawLine(X+Width2, Y+Height2, X+Width2, Y+Height, Colors.Black, Stroke)
	BG.DrawLine(X+Width2,Y+Height2, X+Width*0.25,Y, Colors.Black, Stroke)
	BG.DrawLine(X+Width2,Y+Height2, X+Width*0.75,Y, Colors.Black, Stroke)
	'BG.ClipPath(P)
	'LCARSeffects4.DrawRect(BG, X+Width*0.25,Y, Width2,Height2, TheColors((ColorOffset + 4) Mod TheColors.Length),0)
	'BG.RemoveClip 
	Return Height*0.8
End Sub

Sub DrawPreCARSsquares(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, PCARframeID As Int, ENTbuttons As Int)As Int 
	Dim Scalefactor As Float = LCAR.GetScalemode , temp As Int, WidthOfSliver As Int = Width * 0.4, Y2 As Int = Y+Height-(Images(6).Height* Scalefactor)
	X=X+ (16*Scalefactor)
	Width=Width*0.8
	For temp = PCARframeID To PCARframeID+ENTbuttons-1
		If temp < WallpaperService.ENTdata.Size Then
			Dim tempButton As MiniButton = WallpaperService.ENTdata.Get(temp)
			Y2=Y2- DrawPreCARSsquare(BG, X-WidthOfSliver, Y2-Width, Width, Width, tempButton.ColorID, tempButton.Text, WidthOfSliver, 2*Scalefactor)
		End If'Log("Draw square: " & temp & " " & tempButton)
	Next
	Return temp
End Sub
Sub DrawPreCARSsquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Text As String, WidthOfSliver As Int, Stroke As Int) As Int 
	LCARSeffects4.DrawRect(BG, X-Stroke,Y-Stroke, Stroke, Height+Stroke, Colors.White, 0)
	LCARSeffects4.DrawRect(BG, X, Y-Stroke,WidthOfSliver,Stroke,Colors.White,0)
	LCARSeffects4.DrawRect(BG, X,Y,Width,Height, LCAR.GetColor(ColorID,False, 255), 0)
	API.DrawTextAligned(BG, Text, X+Width*0.5, Y+Height-Stroke, 0,  Typeface.DEFAULT, ENTTextSize2, Colors.Black, -8, 0,0)
	Return Height*1.20
End Sub

Sub DrawPreCARSFramestuff(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CircleMode As Int, TextAlign As Int) As Boolean
	Dim Size As Point, Radius As Int = Height*0.5, CenterX As Int, CenterY As Int, Color As Int = LCARSeffects3.ENTcolor(-3), Ret As Boolean = True 
	Dim IsCircle As Boolean = CircleMode = -1, IsSquircle As Boolean = CircleMode >0
	LoadUniversalBMP(File.DirAssets, "nx01.png", LCAR.PCAR_Frame)
	If IsCircle Then
		LCARSeffects4.DrawRect(BG, X + Width- Radius, Y, Radius, Height, Colors.black, 0)	
		CenterX = X + Max(Radius, Width - Radius)
		CenterY = Y + Radius
	Else If IsSquircle  Then
		DrawPreCARScoloredsquare(BG,X,Y,Width,Height, CircleMode)
		Radius=Radius*0.90
		CenterX = X + Width*0.5
		CenterY = Y + Height*0.5
	End If
	If CircleMode <> 0 Then
		BG.DrawCircle(CenterX,CenterY,Radius, Colors.Black, True, 0)
		If CircleMode = -1 Then Radius=Radius-10
	End If
	Select Case TextAlign
		Case 1,-1'Enterprise Top view
			If IsCircle Or IsSquircle Then
				Size = API.Thumbsize(501,296, Radius*1.6,Radius*1.6, True, False)
				DrawBitmapRotated(BG, CenterPlatform, 0,0,501,296,    CenterX-Size.X*0.5, CenterY-Size.Y*0.5, Size.X, Size.Y, 270)
			Else
				Size = API.Thumbsize(501,296, Width,Height, True, False)
				DrawBMP(BG, CenterPlatform, 0,0, 501,296, X+Width*0.5-Size.X*0.5, Y+Height*0.5-Size.Y*0.5, Size.X, Size.Y, 255, False,False)
				LCARSeffects4.DrawGrid(BG,X,Y,Width,Height, Width*0.1, Height*0.1, Color, 2)
				'LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Colors.Red, 0)
			End If
		Case 2'blue wavedar
			If GeneratePreCARSwave(Radius*2,Radius*2, ENTcanupdatewave, (DateTime.Now - PCARlastupdate >= PCARdelay), 16, 8) Then PCARlastupdate = DateTime.Now 
			ENTcanupdatewave=False
			If IsCircle Or IsSquircle Then
				ClipCircle(BG, CenterX, CenterY, Radius)
				BG.DrawBitmap( LCARSeffects4.TRI_GetFrame( Not(LCARSeffects4.TRI_Frame) ), Null, LCARSeffects4.SetRect(CenterX-Radius,CenterY-Radius,Radius*2,Radius*2))
				BG.RemoveClip
			Else
				BG.DrawBitmap( LCARSeffects4.TRI_GetFrame( Not(LCARSeffects4.TRI_Frame) ), Null, LCARSeffects4.SetRect(X,Y,Width,Height))
			End If
		Case 3'jagged thing
			DrawJagged(BG, CenterX, CenterY, Radius, Color, Radius/14)
			DrawENTrotatedBMP(BG, CenterX, CenterY, Radius*0.75, 0, 0)
		Case 4'arrow
			DrawENTrotatedBMP(BG, CenterX, CenterY, Radius*0.6, 335, 1)
			DrawPreCARSStuff(BG,CenterX, CenterY, Radius*0.80, Radius*-0.05, 10, Colors.RGB(255, 127,39))
			DrawENTdots(BG, CenterX, CenterY, Radius*0.90, 15, 3, Colors.White)
			DrawENTdots(BG, CenterX, CenterY, Radius*0.65, 15, 3, Colors.White)
		Case Else 
			Ret=False 
	End Select
	If IsCircle Then
		LCARSeffects4.SOL_DrawMiniCompass(BG,CenterX,CenterY, Radius, Color, 2 * LCAR.GetScalemode, Radius*0.25, -22.5)
		DrawPreCARSStuff(BG,CenterX, CenterY, Radius*0.80, Radius*-0.05, 10, Colors.RGB(255, 127,39))
		DrawPreCARSUnits(BG,CenterX, CenterY, Radius, Color, 5, 100, 0.25, 10)
	Else If IsSquircle Then
		'LCARSeffects4.SOL_DrawMiniCompass(BG,CenterX,CenterY, Radius, Color, 2 * LCAR.GetScalemode, Radius*0.25, 22.5)
		LCARSeffects4.SOL_DrawCompass(BG,CenterX, CenterY, Radius, Colors.black, -2 * LCAR.GetScalemode, 10, 0)
	End If
	Return Ret 
End Sub

Sub DrawENTdots(BG As Canvas, CenterX As Int, CenterY As Int, Radius As Int, AngleDiff As Int, Size As Int, Color As Int)
	Dim temp As Int, X As Int, Y As Int 
	For temp = 0 To 360-AngleDiff Step AngleDiff 
		X = Trig.findXYAngle(CenterX,CenterY,Radius, temp, True)
		Y = Trig.findXYAngle(CenterX,CenterY,Radius, temp, False)
		BG.DrawCircle(X,Y, Size,Color,True,0)
	Next
End Sub

Sub DrawENTrotatedBMP(BG As Canvas, CenterX As Int, CenterY As Int, Radius As Int, Angle As Int, ElementIndex As Int)
	Dim X As Int= 501, Y As Int, Width As Int, Height As Int, Radius2 As Int = Radius*2, W As Int = Radius2, H As Int = Radius2
	Select Case ElementIndex 
		Case 0'___[
			Y=191
			Width = 94
			Height=45
		Case 1' ^
			Width = 86
			Height = 191
	End Select
	If Width > Height Then
		H = Radius2/Width*Height
	Else
		W = Radius2/Height*Width
	End If
	If Angle = 0 Then
		DrawBMP(BG, CenterPlatform, X,Y,Width,Height,  CenterX-(W*0.5), CenterY-(H*0.5), W,H, 255,False,False)
	Else
		BG.DrawBitmapRotated(CenterPlatform, LCARSeffects4.SetRect(X,Y,Width,Height), LCARSeffects4.SetRect(CenterX-(W*0.5), CenterY-(H*0.5), W,H), Angle)
	End If
End Sub


Sub DrawPreCARSfreq(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim ColWidth As Int = 2, Color As Int = Colors.RGB(1, 254, 249), temp As Int, Value As Int, Middle As Int', MeterHeight As Int = 30 * LCAR.ScaleFactor', MeterWidth As Int = Width/MeterHeight
	'DrawPreCARSMeter(BG,X,Y+Height-MeterHeight, Width, MeterHeight,  0, -1, "", -2, Width / MeterWidth)
	'Middle = Y+Height-MeterHeight*0.5
	'BG.DrawLine(X, Middle, X+Width,Middle, Colors.Black, 2)
	'Height = Height - MeterHeight
	Middle = Y + Height *0.5
	For temp = X To X+Width Step ColWidth
		Value = Rnd(1,Height*0.5)
		LCARSeffects4.DrawRect(BG, temp, Middle-Value, ColWidth, Value*2, Color,0)
	Next
End Sub

Sub ClipCircle(BG As Canvas, X As Int, Y As Int, Radius As Int)
	Dim handpath As ABPath 
	handpath.addCircle(X, Y, Radius, handpath.Direction_CW)
	LCAR.ExDraw.clipPath2(BG, handpath)
End Sub

Sub DrawJagged(BG As Canvas, centerX As Int, centerY As Int, Radius As Int, Color As Int, JaggySize As Int)
	Dim P As Path 
	ClipJagged(P, centerX, centerY-Radius, Radius*2,  False, JaggySize)
	P.LineTo(centerX-Radius, centerY+Radius)
	ClipJagged(P, centerX-Radius, centerY, Radius*2,  True, JaggySize)
	P.LineTo(centerX+Radius, centerY-Radius)
	BG.ClipPath(P)
	BG.DrawCircle(centerX,centerY, Radius, Color,True, 0)
	BG.RemoveClip 
End Sub

Sub ClipJagged(P As Path, X As Int, Y As Int, Length As Int, isXaxis As Boolean, JaggySize As Int)
	Dim temp As Int, Stage As Boolean
	If isXaxis Then Y=Y-JaggySize*0.5 Else X=X-JaggySize*0.5
	For temp = 1 To Length Step JaggySize
		LCARSeffects3.MakePoint(P,X,Y)
		If isXaxis Then
			If Stage Then
				LCARSeffects3.MakePoint(P,X,Y+JaggySize)
				LCARSeffects3.MakePoint(P,X+JaggySize,Y+JaggySize)
			End If
			X=X+JaggySize
		Else
			If Stage Then 
				LCARSeffects3.MakePoint(P,X+JaggySize,Y)
				LCARSeffects3.MakePoint(P,X+JaggySize,Y+JaggySize)
			End If
			Y=Y+JaggySize
		End If
		Stage=Not(Stage)
	Next
End Sub

'Align: 0=ENTERPRISE, 1=top left corner, 2=top left+right, 3=top right, 4=left top+bottom, 5=middle, 6=right top+bottom, 7=bottom left corner, 8=bottom left+right, 9=bottom right, 10=no corners, (rwidth) Radius=-1 has no right edge
Sub DrawPreCARSFrame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int,Alpha As Int, Align As Int, Radius As Int, Stroke As Int, Text As String, TextAlign As Int, Tag As String) As Rect
	Dim temp As Int ,temp2 As Int,temp3 As Int ,temp4 As Int, temp5 As Int,temp6 As Int, temp7 As Int, Color As Int,textheight As Int, TL As Boolean, TR As Boolean, BL As Boolean, BR As Boolean, textwidth As Int, tempWidth As Int
	Dim Scalefactor As Float = LCAR.GetScalemode , X1 As Int, X2 As Int, X3 As Int, X4 As Int, DoL As Boolean = True, DoR As Boolean = True, P As Path 
	Color=LCAR.GetColor(ColorID,False,Alpha)
	If Align<1 Then'Enterprise
		temp2=(Images(0).Height+ Images(1).Height) * Scalefactor -1
		temp4=Width-(Images(4).Width + Images(6).Width)*Scalefactor+1
		If Radius =-1 Then Width = Width + Images(6).Width *Scalefactor
		
		If ColorID<0 Then
			LCAR.DrawPic2(BG,X,Y, Images(9), False, False, Scalefactor)'top left no-corner
		Else
			LCAR.DrawRect(BG,X,Y, Images(0).Width * Scalefactor , temp2, Color, 0)'colored dot
			LCAR.DrawPic2(BG,X,Y, Images(0), False, False, Scalefactor)'top half of top left corner
			LCAR.DrawPic2(BG,X,Y+Images(0).Height*Scalefactor-1, Images(1), False,False, Scalefactor)'bottom half of top left corner
		End If
		
		BG.DrawBitmap(Images(2), Null, LCARSeffects4.SetRect(X+ Images(0).Width*Scalefactor, Y, temp4, Images(2).Height*Scalefactor))'bar along the top
		If Radius>-1 Then LCAR.DrawPic2(BG, X+Width-Images(3).Width*Scalefactor, Y, Images(3), False,False,Scalefactor)'top right corner
		
		temp=Y+Height-(Images(4).Height*Scalefactor)
		LCAR.DrawPic2(BG,X,temp, Images(4), False,False,Scalefactor)'bottom left corner
		BG.DrawBitmap(Images(5), Null, LCARSeffects4.SetRect(X+ Images(4).Width*Scalefactor, temp, temp4, Images(6).Height*Scalefactor))'bar along the bottom
		
		If Radius>-1 Then
			LCAR.DrawPic2(BG,X+Width-Images(6).Width*Scalefactor,temp, Images(6), False,False,Scalefactor)'bottom right corner
			BG.DrawBitmap(Images(8), Null, LCARSeffects4.SetRect(X+Width-Images(8).Width*Scalefactor,Y+(Images(2).Height*Scalefactor),Images(8).Width*Scalefactor, temp-Images(2).Height*Scalefactor-Y+2 ))'middle right bar
		End If
		BG.DrawBitmap(Images(7), Null, LCARSeffects4.SetRect(X,Y+temp2-1,Images(7).Width*Scalefactor, temp-temp2-Y+2 ))'middle left bar
		
		If Text.Length>0 Then
			If ENTTextSize = 0 Or ENTScaleFactor <> Scalefactor Then 
				ENTTextSize = API.GetTextHeight(BG, 20*Scalefactor, Text, Typeface.DEFAULT) '12'26
				ENTTextSize2 =  API.GetTextHeight(BG, -20*Scalefactor, "999", Typeface.DEFAULT) 
				ENTScaleFactor = Scalefactor
			End If
			temp3=Images(9).Height*Scalefactor
			temp = BG.MeasureStringWidth(Text, Typeface.DEFAULT, ENTTextSize) + temp3
			temp2=ENTTextSize
			temp4= Images(0).Width * Scalefactor * 1.20 * WallpaperService.ENTbuttons + (Images(6).Height* Scalefactor)
			If temp > Height - temp3 - temp4 Then 
				temp2 = API.GetTextHeight(BG, -(Height - temp3 - temp4), Text, Typeface.DEFAULT)
				temp = BG.MeasureStringWidth(Text, Typeface.DEFAULT, temp2) + temp3
			End If
			BG.DrawTextRotated(Text, X+ 43*Scalefactor, Y+ temp, Typeface.DEFAULT, temp2, Colors.black, "LEFT", -90) 
		End If
		
		'Log("Draw Squares: " & WallpaperService.IsVisible & " " & WallpaperService.PreviewMode & " " & WallpaperService.PCARframeID)
		If (WallpaperService.IsVisible Or WallpaperService.PreviewMode) And WallpaperService.PCARframeID>-1 And ColorID>-1 Then'WallpaperService.ENTmode AND 
			DrawPreCARSsquares(BG, X,Y, Images(0).Width * Scalefactor, Height, WallpaperService.PCARframeID, WallpaperService.ENTbuttons)
		End If
		
		If TextAlign<>0 Then 
			Dim Size As Rect = GetEntCARSFrameUsableSpace(X,Y,Width,Height, Radius)
			If DrawPreCARSFramestuff(BG, Size.Left, Size.Top , Size.Right-Size.Left, Size.Bottom-Size.Top, Radius, TextAlign) And KlingonVirus Then 
				LCARSeffects3.DrawKlingonFrame(BG, X,Y,Width, Height, -1, Alpha*0.5, True, Radius=-1, Tag)	
				'Select Case TextAlign
				'	Case 1,-1'Enterprise top view
				'	Case 2'blue wavedar
				'	Case 3'jagged thing 
				'	Case 4'arrow
				'End Select
			End If 
		End If
		'BG.DrawRect(GetEntCARSFrameUsableSpace(X,Y,Width,Height,Radius) , Colors.Blue, True, 0)
	Else If Align<11 Then'TMP
		Select Case Align'case 0 is PRECARS frame above
			Case 1: TL=True										'top left corner
			Case 2: TL=True:	TR=True							'top middle
			Case 3: TR=True										'top right
			Case 4: TL=True:	BL=True							'left middle
			Case 5: TL=True:	TR=True:	BL=True:	BR=True	'middle
			Case 6: TR=True:	BR=True							'right middle
			Case 7: BL=True										'bottom left corner
			Case 8: BL=True:	BR=True							'bottom middle
			Case 9: BR=True										'bottom right
			'case 10:											'no corners
		End Select
		If Text.Length>0 Then	
			'temp3=Stroke*2
			LCARSeffects.InitStarshipFont
			textheight=BG.MeasureStringHeight(Text, StarshipFont, LCAR.Fontsize)
			'textheight = BG.MeasureStringHeight(Text,StarshipFont, temp3) *0.5 'DrawLegacyText
			If Abs(TextAlign) = 1 Or Abs(TextAlign)=3 Then textwidth = BG.MeasureStringwidth(Text,StarshipFont, LCAR.Fontsize)
			If TextAlign>-1 And TextAlign<2 Then Y=Y+ textheight*0.5
			'Height=Height-textheight 'bottom left, bottom right
		End If
		If Tag.Length>0 Then 
			If Tag.Contains(".") Then tempWidth = Width * Tag Else tempWidth = Tag 
			
		End If
		temp3=Stroke*0.5
		
		X1 = X+temp3
		X2 = X1
		X3 = X+Width-temp3
		X4 = X3
		If TL Then 
			LCARSeffects.DrawCircleSegment(BG,X+Radius + tempWidth,Y+Radius,  Radius-Stroke,Radius, 270,90, Color,  0, 0,0)
			temp  = X + Radius + tempWidth
			temp4 = Y + Radius
			X1 = X1 + tempWidth
		Else 
			temp  = X
			temp4 = Y
		End If
		If TR Then 
			LCARSeffects.DrawCircleSegment(BG,X+Width-Radius-tempWidth,Y+Radius,  Radius-Stroke,Radius, 0,90, Color, 0,0,0)
			temp2 = X + Width - Radius - tempWidth
			temp5 = Y + Radius
			X3 = X3 - tempWidth
		Else
			temp2 = X + Width
			temp5 = Y
		End If
		BG.DrawLine(temp, Y+ temp3, temp2, Y+temp3, Color, Stroke)'top bar
		
		If BL Then
			LCARSeffects.DrawCircleSegment(BG,X+Radius+tempWidth,Y+Height-Radius,  Radius-Stroke,Radius, 180,90, Color,  0, 0,0)
			temp6= Y + Height - Radius
			temp = X + Radius + tempWidth
			X2 = X2 + tempWidth
		Else
			temp  = X 
			temp6 = Y + Height
		End If
		If BR Then
			LCARSeffects.DrawCircleSegment(BG,X+Width-Radius-tempWidth,Y+Height-Radius,  Radius-Stroke,Radius, 90,90, Color,  0, 0,0)
			temp7 = Y + Height - Radius
			temp2 = X + Width - Radius - tempWidth
			X4 = X4 - tempWidth
		Else
			temp7 = Y + Height
			temp2 = X + Width
		End If
		If tempWidth > 0 Then 
			If TL Or BL Then 
				If Not(TL) Then temp4 = temp4 + Stroke
				P.Initialize(X1-temp3, temp4)
				P.LineTo(X1+temp3, temp4)
				P.LineTo(X2+temp3, temp6)
				P.LineTo(X2-temp3, temp6)
				BG.DrawPath(P, Color, True, 0)
				DoL=False 
			End If
			If TR Or BR Then 
				If Not(TR) Then temp5 = temp5 - Stroke
				P.Initialize(X3-temp3, temp5)
				P.LineTo(X3+temp3, temp5)
				P.LineTo(X4+temp3, temp7)
				P.LineTo(X4-temp3, temp7)
				BG.DrawPath(P, Color, True, 0)
				DoR=False
			End If
		End If
		If DoL Then BG.DrawLine(X1, temp4, X2, temp6, Color, Stroke)'left bar
		If DoR Then BG.DrawLine(X3, temp5, X4, temp7, Color, Stroke)'right bar
		BG.DrawLine(temp, Y+ Height-temp3, temp2, Y+Height-temp3, Color, Stroke)'bottom bar
		If Text.Length>0 Then	
			'textheight=textheight*0.5
			'Stroke=Stroke*0.5
			temp = 1 + (Abs(TextAlign) / 4)
			If TextAlign < 0 Then temp = -temp 
			Select Case Abs(TextAlign) Mod 4
				Case 0: DrawLegacyText(BG, X + Stroke*2 + API.IIF(TL, Radius,0), Y+Stroke, textwidth, textheight, Text, LCAR.Fontsize , Color, 1, temp, False, Stroke)'LCAR.DrawLegacyText(BG, X+ 5 + API.IIF(TL, Radius,0), Y-textheight/2-Stroke, 0,0, Text, LCAR.Fontsize , Color, 0)'top left
				Case 1: DrawLegacyText(BG, X + Width- Stroke*2 - API.IIF(TR, Radius,0), Y+Stroke, textwidth, textheight, Text, LCAR.Fontsize , Color, 3, temp, False, Stroke)'LCAR.DrawLegacyText(BG, X+ Width- 5 - API.IIF(TR, Radius,0)-textwidth, Y-textheight/2-Stroke, 0,0, Text, LCAR.Fontsize , Color, 0)'top right
				Case 2: DrawLegacyText(BG, X + Stroke*2 + API.IIF(BL, Radius,0), Y+Height, textwidth, textheight, Text, LCAR.Fontsize , Color, 1, temp, True, Stroke)'bottom left
				Case 3: DrawLegacyText(BG, X + Width- Stroke*2 - API.IIF(BR, Radius,0), Y+Height, textwidth, textheight, Text, LCAR.Fontsize , Color, 3, temp, True, Stroke)'bottom right
			End Select
		End If
	'Else
		'other era styles
	End If
	Return LCARSeffects4.SetRect(X,Y,Width,Height)
End Sub

Sub DrawLegacyText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Text As String, Textsize As Int, Color As Int, Align As Int, Size As Int, GoDown As Boolean, Stroke As Int)
	Dim AlignText As String 
	If Size>1 Then
		Textsize=Textsize*Size
		Width=Width*Size
		Height=Height*Size 
		If GoDown Then Y = Y + Height - Stroke
	else if Size < 0 Then 
		Textsize=Textsize*0.5
		Width=0
		Height=Stroke
		Y=Y+1
	End If
	If Width = 0 Then Width = BG.MeasureStringWidth(Text, StarshipFont, Textsize)
	If Height = 0 Then Height = BG.MeasureStringHeight(Text, StarshipFont, Textsize)
	Select Case Align 
		Case 0,2
			AlignText = "CENTER"
			If Color <> Colors.black Then LCARSeffects4.DrawRect(BG, X-Width*0.5,Y-Height, Width, Height+1, Colors.Black, 0)
		Case 1
			AlignText = "LEFT"
			If Color <> Colors.black Then LCARSeffects4.DrawRect(BG, X,Y-Height, Width, Height+1, Colors.Black, 0)
		Case 3
			AlignText = "RIGHT"
			If Color <> Colors.black Then LCARSeffects4.DrawRect(BG, X-Width,Y-Height, Width, Height+1, Colors.Black, 0)
	End Select
	BG.DrawText(Text, X, Y, StarshipFont, Textsize, Color, AlignText)
End Sub

Sub RandomNumber(Digits As Int, Pad As Boolean ) As String
	Dim tempstr As String 
	tempstr= Rnd(0, Power(10, Digits))
	If Pad Then
		Do Until tempstr.Length= Digits
			tempstr = "0" & tempstr
		Loop
	End If
	Return tempstr
End Sub







Sub DrawCustomElement(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, LwpID As Int, ElementID As Int, ColorID As Int, State As Boolean, Alpha As Int, Text As String, SideText As String, TextAlign As Int, Align As Int, Tag As String) 
	Dim temp As Int,temp2 As Int,temp3 As Int, temp4 As Int,temp5 As Int, temp6 As Int, temp7 As Int, temp8 As Int, temp9 As Int, temp0 As Int, Color As Int , P As Path, DidDraw As Boolean =True, tempF As Float, tempP As Point
	Color = LCAR.GetColor(ColorID,State,Alpha)
	CurrentSquare=-1
	Select Case LwpID 
		Case -1'Live wallpaper in it's entirety
			CallSubDelayed2(WallpaperService, "PreviewLWP", BG)
		Case 14 'transporter
			Select Case ElementID
				Case 0'align= width to subtract to get the middle, textalign=width of middle
					temp = Width * 0.2
					temp2=Height * 0.12
					'temp3=X+Width-Align'start x of middle bit

					temp3=X+temp + (Width-temp)/2 - TextAlign/2'start x of middle bit
					LCAR.DrawRect(BG,X,Y, temp+1, Height, Color, 0)
					LCAR.DrawRect(BG,X+temp, Y, Width-temp, temp2, Color,0)
					LCAR.DrawRect(BG,temp3, Y+ temp2*0.4, TextAlign, temp2*0.3, Colors.Black,0)
					LCAR.DrawRect(BG,X+temp, Y+Height-temp2, Width-temp, temp2, Color,0)
					LCAR.DrawRect(BG,temp3, Y+Height-temp2+2, TextAlign, temp2*0.3, Colors.Black,0)
					LCAR.DrawRect(BG,temp3, Y+Height, TextAlign, temp2*0.2, Colors.white,0)
					
					X=X+temp
					Width=Width-temp
					Y=Y+temp2
					Height=Height-temp2
					temp4 =Width-( X+Width-temp3)+1'width of smaller bit
					
					'127 (width) * 83 (height)
					temp= Height* 5/86'one unit = 5 pixels at regular size
					LCAR.DrawRect(BG,temp3,Y, TextAlign, temp, Colors.white, 0)
					LCAR.DrawRect(BG,X,Y+ temp, Width, temp, Colors.white, 0)
					LCAR.DrawRect(BG,X,Y+ temp*2+1, Width, temp*0.5, Colors.white, 0)
					
					LCAR.DrawRect(BG,temp3+TextAlign*0.33,Y+temp*3+1, TextAlign, temp, Color, 0)
					LCAR.DrawRect(BG,temp3+TextAlign*1.33-temp,Y+temp*3+1, temp, temp*5.5-1, Color, 0)
					LCAR.DrawRect(BG,temp3+TextAlign*1.3+3,Y+temp*3+1, TextAlign, temp*4.5, Color, 0)
					
					LCAR.DrawRect(BG,X,Y+ temp*5, temp4, temp*0.33, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*5, TextAlign, temp, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*6+1, TextAlign, temp, Colors.white, 0)
					
					LCAR.DrawRect(BG,temp3+TextAlign*0.33,Y+temp*7.5, TextAlign, temp, Color, 0)
					
					LCAR.DrawRect(BG,temp3,Y+temp*9, TextAlign, temp, Colors.white, 0)
					LCAR.DrawRect(BG,X,Y+ temp*10, Width, temp*0.5, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*10, TextAlign, temp, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*11+1, TextAlign, 2, Colors.white, 0)
					
					LCAR.DrawRect(BG,X,Y+ temp*11.5, Width, temp*0.5, Colors.white, 0)
					LCAR.DrawRect(BG,temp3-TextAlign,Y+ temp*12-1, TextAlign, temp*0.5, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*12.5, TextAlign, temp*0.5, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*13+1, TextAlign, temp*0.5, Colors.white, 0)
					LCAR.DrawRect(BG,temp3,Y+temp*13.5+1, TextAlign, temp, Colors.white, 0)
				Case 1'the weird square thing
					temp= (Height - LCAR.TextHeight(BG, Text) -2 ) /2
					LCAR.DrawRect(BG,X,Y, temp, Height-temp*2+1, Color,0)
					LCAR.DrawText(BG,X+temp+1,Y, Text, ColorID, 1, State,255,0)
					LCAR.DrawRect(BG,X,Y+Height-temp*2, Width, temp, Color,0)
					If Align <0 Then
						LCAR.DrawRect(BG,X+Width-LCAR.leftside*2,Y+Height-temp-1, LCAR.leftside*2, temp, Color,0)
						If Align>-3 Then Color = LCAR.GetColor(LCAR.LCAR_LightYellow, State,Alpha)
						If Align = -1 Then
							'If InitRandomNumbers(LCAR.LCAR_LWP, False ) Then
								
							'End If
						End If
					Else
						LCAR.DrawRect(BG,X+Width*0.4,Y+Height-temp-1, Width*0.2, temp, Color,0)
					End If
					
					temp3=temp
					temp2=Height*0.5
					temp=Width*0.2
					If Align > -1 Then Width=Width*0.6
					Y=Y+Height*3.5
					Height=Height*1.5 - 1
					'bottom part
					LCAR.DrawRect(BG,X,Y+temp3, Width, temp3, Color,0)'top line
					If Align <0 Then 						
						LCAR.DrawRect(BG,X+Width-LCAR.leftside*2, Y+temp3*0.5, LCAR.leftside*2, temp3, Color, 0)'the part that sticks up
					Else
						LCAR.DrawRect(BG,X+Width-temp, Y+temp3*0.5, temp, temp3, Color, 0)'the part that sticks up
					End If
					temp5=temp3*0.5
					LCAR.DrawRect(BG,X+Width-temp5,Y+temp3, temp5, Height-temp3-1,Color,0)'the right edge
					
					
					temp=temp*1.5
					temp2=temp2*0.5
					
					Select Case Align 'floating bit in the middle
						Case -1
							LCAR.DrawRect(BG,X,Y+Height-temp2-temp3-2, temp, temp2,LCAR.GetColor(LCAR.LCAR_LightBlue, State,Alpha) ,0)
						Case -2, -3
							LCAR.DrawRect(BG,X+temp+(temp2*0.5),Y+Height-temp2-temp3-2, temp2, temp2,LCAR.GetColor(LCAR.LCAR_Orange, State,Alpha) ,0)
						Case Else
							X=X+temp3
							Width=Width-temp3
							LCAR.DrawRect(BG,X,Y+Height-temp2-temp3-2, temp, temp2,Color ,0)
					End Select
					
					LCAR.DrawRect(BG,X,Y+Height-temp3, temp, temp3-2,Color ,0)'the left bit before the bottom
					LCAR.DrawRect(BG,X,Y+Height-temp3*0.5, Width-2, temp3*0.5,Color,0)'the bottom
				
				Case Else: DidDraw = False
			End Select
		Case 22'CONN
			Select Case ElementID
				Case 0'left-most slanted element
					temp3=Width-TextAlign*0.5-Align*0.5
					LCAR.DrawRect(BG,X+temp3+2,Y-LCAR.ItemHeight*0.25-2,Align, LCAR.ItemHeight*0.25, LCAR.GetColor(LCAR.LCAR_Orange,State,Alpha), 0)
					
					'textalign=width of dpad,align=width of center
					P.Initialize(X + Height*0.1, Y)
					P.LineTo(X,Y+Height)
					P.LineTo(X+Width,Y+Height)
					P.LineTo(X+Width,Y)
					BG.ClipPath(P)

					'top bar, purple orange blue
					LCAR.DrawRect(BG,X,Y,temp3, LCAR.ItemHeight, LCAR.GetColor(LCAR.LCAR_LightPurple,State,Alpha), 0)
					LCAR.DrawRect(BG,X+temp3+2,Y,Align, LCAR.ItemHeight, LCAR.GetColor(LCAR.LCAR_Orange,State,Alpha), 0)
					temp=Width-(temp3+4+Align)'width of right side
					LCAR.DrawRect(BG,X+Width-temp,Y, Width-temp, LCAR.ItemHeight, LCAR.GetColor(LCAR.LCAR_Blue,State,Alpha), 0)
					
					'second bar
					temp2=Y+ LCAR.ItemHeight*2
					LCAR.DrawRect(BG,X,temp2,temp3, LCAR.ItemHeight, LCAR.GetColor(LCAR.LCAR_Yellow,State,Alpha), 0)
					LCAR.DrawRect(BG,X+temp3+2,temp2,Align, LCAR.ItemHeight*1.25, LCAR.GetColor(LCAR.LCAR_Orange,State,Alpha), 0)
					LCAR.DrawRect(BG,X+temp3+2,temp2+LCAR.ItemHeight*0.75,Align, 3, Colors.Black, 0)
					LCAR.DrawRect(BG,X+temp3+2,temp2+LCAR.ItemHeight,Align, 3, Colors.Black, 0)
					LCAR.DrawRect(BG,X+Width-temp,temp2, Width-temp, LCAR.ItemHeight, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
				
					'vertical bar
					temp4=LCAR.ItemHeight*0.5'|
					LCAR.DrawRect(BG,X+Width-temp4+1,temp2, temp4, LCAR.ItemHeight*5-2 , LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
					
					'stars
					temp5=LCAR.ItemHeight*3+5
					temp2=Y+ temp5 + 5
					temp4=Width-temp4 - 10
					
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.27160, 0.09259, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.43827, 0.0463,  0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.59259, 0.07407, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.90741, 0.07407, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)

					DrawCEstar(BG,X, temp2, temp4,temp5,	0.22840, 0.25926, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.82099, 0.28704, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.85802, 0.37037, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha) 
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.27778, 0.52778, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha) 
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.79012, 0.45370, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.27160, 0.66667, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.47531, 0.64815, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.40123, 0.52778, 0.05556,		LCAR.LCAR_Yellow, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.48765, 0.41667, 0.05556,		LCAR.LCAR_Yellow, 		State,Alpha)
					
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.20988, 0.90741, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.35185, 0.87963, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.53086, 0.77778, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.59877, 0.89815, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.82716, 0.92593, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.92593, 0.83333, 0.02778,		LCAR.LCAR_DarkOrange,	State,Alpha)
					DrawCEstar(BG,X, temp2, temp4,temp5,	0.96914, 0.95370, 0.02778, 		LCAR.LCAR_Orange, 		State,Alpha)

					'middle bits
					temp2=Y+ LCAR.ItemHeight*3.4
					temp5=Width*0.27
					Color=LCAR.GetColor(LCAR.LCAR_Orange,State,Alpha)
					LCAR.DrawRect(BG,X+temp3+2,temp2,Align, 7, Color, 0)'middle up
					LCAR.DrawRect(BG,X+temp5,temp2+5,temp4-temp5, LCAR.ItemHeight*0.25, Color, 0)'top
					LCAR.DrawRect(BG,X+temp5,temp2+5, LCAR.ItemHeight*0.25, LCAR.ItemHeight*0.5, Color,0)'left
					LCAR.DrawRect(BG,X+temp4-LCAR.ItemHeight*0.25,temp2+5, LCAR.ItemHeight*0.25, LCAR.ItemHeight*0.7, Color,0)'right
					LCAR.DrawRect(BG,X+temp5,temp2+LCAR.ItemHeight*1.75,temp4-temp5, LCAR.ItemHeight*0.25, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)'bottom
					
					LCAR.DrawRect(BG,X+temp3+2+Align*0.5,temp2+LCAR.ItemHeight*0.6,Align*0.3, LCAR.ItemHeight*0.7, LCAR.GetColor(LCAR.LCAR_Yellow,State,Alpha), 0)'|
					LCAR.DrawRect(BG,X+temp3+2+Align*0.5-LCAR.ItemHeight*0.7,temp2+LCAR.ItemHeight*1.3,LCAR.ItemHeight*0.7, Align*0.3, LCAR.GetColor(LCAR.LCAR_Yellow,State,Alpha), 0)'-
					
					'third bar
					temp2=Y+ LCAR.ItemHeight *6+7'   +Height-LCAR.ItemHeight 
					temp4=LCAR.ItemHeight*0.4
					temp5=LCAR.ItemHeight*0.3
					LCAR.DrawRect(BG,X,temp2+temp4,temp3, LCAR.ItemHeight-temp4, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
					
					LCAR.DrawRect(BG,X+temp3+2,temp2, Align, temp5, Color, 0)
					LCAR.DrawRect(BG,X+temp3+2,temp2+temp5+2, Align, LCAR.ItemHeight-2-temp5, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
					
					LCAR.DrawRect(BG,X+Width-temp,temp2+temp4, Width-temp, LCAR.ItemHeight-temp4, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
					BG.RemoveClip 
					
					'last bar
					temp2=Y+ LCAR.ItemHeight *8-temp4+4'+Height + LCAR.ItemHeight- temp4
					LCAR.DrawRect(BG,X,temp2,Width,temp4, LCAR.GetColor(LCAR.LCAR_DarkOrange,State,Alpha), 0)
				Case 1'square thingie
					LCARSeffects.MakeClipPath(BG,X,Y,Width-1,Height-1)
						'Blues
						DrawCEsquare(BG,X,Y,Width,Height, 	0, 			0, 			0.38931, 	0.25781,		LCAR.LCAR_Blue, 		State,Alpha)'top left
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0, 			0.17557, 	0.09375,		LCAR.LCAR_Blue, 		State,Alpha)'top middle
						DrawCEsquare(BG,X,Y,Width,Height,	0.60305, 	0, 			0.38931, 	0.16406,		LCAR.LCAR_Blue, 		State,Alpha)'top right
						DrawCEsquare(BG,X,Y,Width,Height,	0.60305, 	0.17969, 	0.38931, 	0.49219,		LCAR.LCAR_Blue, 		State,Alpha)'big/middle right
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.88281, 	0.38168, 	0.20000,		LCAR.LCAR_Blue, 		State,Alpha)'bottom left
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.89844, 	0.5,	 	0.04688,		LCAR.LCAR_Blue, 		State,Alpha)'bit sticking out of the bottom right
						DrawCEsquare(BG,X,Y,Width,Height,	0.60305, 	0.78906, 	0.38931, 	0.21094,		LCAR.LCAR_Blue, 		State,Alpha)'bottom right
						DrawCEsquare(BG,X,Y,Width,Height,	0.60305, 	0.67969, 	0.38931, 	0.03125,		LCAR.LCAR_Blue, 		State,Alpha)'thin bit under the middle right
						'Black
						DrawCEsquare(BG,X,Y,Width,Height,	0.69466, 	0.35156, 	0.16794, 	0.1875,			LCAR.LCAR_Black,		State,Alpha)
						'Oranges
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.10156, 	0.17557, 	0.10156,		LCAR.LCAR_Orange,		State,Alpha)'top
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.54688, 	0.17557, 	0.10156,		LCAR.LCAR_Orange,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.70312, 	0.17557, 	0.04688,		LCAR.LCAR_Orange,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.95,	 	0.17557,	0.05469,		LCAR.LCAR_Orange,		State,Alpha)'bottom
						'Yellows
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.28125, 	0.57250, 	0.05469,		LCAR.LCAR_Yellow,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.22656, 	0.17557, 	0.10000,		LCAR.LCAR_Yellow,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.61719, 	0.38931, 	0.09375,		LCAR.LCAR_Yellow,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.75781, 	0.23664, 	0.0625,			LCAR.LCAR_Yellow,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.78906,	0.38931, 	0.03906,		LCAR.LCAR_Yellow,		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0.40458, 	0.83594, 	0.17557, 	0.03906,		LCAR.LCAR_Yellow,		State,Alpha)
						'Else
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.35938, 	0.58015, 	0.02344,		LCAR.LCAR_LightYellow,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.46875, 	0.58015, 	0.0625,			LCAR.LCAR_LightYellow,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,	0, 			0.5, 		0.38931, 	0.08594,		LCAR.LCAR_LightYellow,	State,Alpha)
					BG.RemoveClip 
				Case 2'curve thingie			textalign=y of joint, align=itemheight
					temp=Width*0.33333
					temp2=Width*0.5
					temp3=Align*0.5
					'Color = LCAR.GetColor(ColorID,State,Alpha)
					LCAR.DrawRect(BG,X,Y, temp2, Align, Color,0)'top left
									
					LCAR.DrawRect(BG,X,Y+Height-Align, temp2, Align, Color,0)'bottom left
					
					LCAR.DrawCircle(BG,X+temp2-temp3,Y,Align,Align,5, Color)'top right curve
					LCAR.DrawCircle(BG,X+temp2-temp3,Y+Height-Align,Align,Align,5, Color)'bottom right curve
					
					LCAR.DrawRect(BG,X+temp2-temp3,Y+temp3, Align, Height-Align, Color,0)'middle |
					
					LCAR.DrawRect(BG,X+temp2,Y+TextAlign, temp, Align, Color,0)'right joint
					
					LCAR.DrawCircle(BG,X+temp2-9-temp3,Y+Align-1,10,10, -3,Color)'top inside curve
					LCAR.DrawCircle(BG,X+temp2-9-temp3,Y+Height-Align-9,10,10, -9,Color)'top inside curve
				Case 3' slanted end piece
					temp=Height/11'slant
					Align=10
					temp2=Align*0.5
					
					P.Initialize(X, Y)
					P.LineTo(X,Y+Height)
					P.LineTo(X+Width,Y+Height)
					P.LineTo(X+Width-temp,Y)
					BG.ClipPath(P)

					BG.DrawLine(X+Width-temp,Y,				X+Width,Y+Height, 				Color, Align*2)
					BG.DrawLine(X, Y+temp2,					X+Width-temp-temp2,Y+temp2, 	Color, Align)
					BG.DrawLine(X, Y+Height-temp2,			X+Width-temp2,Y+Height-temp2, 	Color, Align)
					
					BG.RemoveClip 
					
					temp = LCAR.ItemHeight *0.5
					temp2=temp*1.5
					
					LCAR.DrawRect(BG,X, Y+Height-(temp2*1.5),temp2,temp, LCAR.GetColor(LCAR.LCAR_Blue,State,Alpha), 0)
					
				Case Else: DidDraw = False
			End Select
		Case 28'OPS
			Select Case ElementID'TOP: 1=left, 2=middle, 3=right	MIDDLE: 4=left, 5=middle, 6=right BOTTOM: 7=left, 8=middle, 9=right, use negatives for inside curve
				Case 0'block bit
					LCARSeffects4.DrawRect(BG,X,Y,Width,Height, Color, 0)
					temp=Width*0.5
					Select Case Align 
						Case 1: LCAR.DrawCircle2(BG,X,Y,temp, temp, Align, Color, True)
						Case 3: LCAR.DrawCircle2(BG,X+Width-temp,Y,temp, temp, Align, Color, True)
						Case 7: LCAR.DrawCircle2(BG,X,Y+Height-temp,temp, temp, Align, Color, True)
						Case 9: LCAR.DrawCircle2(BG,X+Width-temp,Y+Height-temp,temp, temp, Align, Color, True)
					End Select
					For temp2 = 0 To Text.Length -1
						If API.Mid(Text, temp2, 1) = "1" Then
							LCARSeffects4.DrawRect(BG,X+temp-10, Y+ (LCAR.ItemHeight *0.5) - TextAlign * 0.5, temp, TextAlign, Colors.Black, 0)
						End If
						Y=Y+LCAR.ItemHeight+2
					Next
				Case 1
					LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
						'Light Yellows
						DrawCEsquare(BG,X,Y,Width,Height,       0, 			0, 			1, 			0.08527,	LCAR.LCAR_LightYellow, 	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.21705, 	0.58779, 	0.24031,	LCAR.LCAR_LightYellow, 	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221,	0.23256,	0.17557,	0.26357,	LCAR.LCAR_LightYellow, 	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0,			0.69767,	0.38931,	0.04651,	LCAR.LCAR_LightYellow, 	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.69767, 	0.17557, 	0.04651,	LCAR.LCAR_LightYellow, 	State,Alpha)
						'Oranges
						DrawCEsquare(BG,X,Y,Width,Height,       0.60305, 	0.48837, 	0.39695, 	0.03101,	LCAR.LCAR_Orange, 		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.56589, 	0.17557, 	0.09302,	LCAR.LCAR_Orange, 		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.78295,	0.17557,	0.04651,	LCAR.LCAR_Orange, 		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.86047, 	0.17557, 	0.13953,	LCAR.LCAR_Orange, 		State,Alpha)
						'Blues
						DrawCEsquare(BG,X,Y,Width,Height,       0, 			0.11628, 	0.38931, 	0.50388,	LCAR.LCAR_LightBlue,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41221, 	0.16279, 	0.59542, 	0.04651,	LCAR.LCAR_LightBlue,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.60305, 	0.54264, 	0.39695, 	0.06977,	LCAR.LCAR_LightBlue,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0, 			0.76744,	0.38931, 	0.26357,	LCAR.LCAR_LightBlue,	State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.61069, 	0.69767, 	0.38931, 	0.31783,	LCAR.LCAR_LightBlue,	State,Alpha)
						'Blacks
						DrawCEsquare(BG,X,Y,Width,Height,       0.45038, 	0.28682, 	0.10687, 	0.06202,	LCAR.LCAR_Black, 		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.10687, 	0.44186, 	0.16794, 	0.10078,	LCAR.LCAR_Black, 		State,Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.1145, 	0.82946, 	0.16794, 	0.10853,	LCAR.LCAR_Black, 		State,Alpha)
					BG.RemoveClip 
				Case Else: DidDraw = False
			End Select
		Case 29
			temp=Width*0.6
			Y=Y+(Height*0.5)-(temp*0.5)
			Height=temp
			Select Case ElementID
				Case 0
					'oranges
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.0, 0.32248, 1,	ColorID, 	State,Alpha)'0
						DrawCEsquare(BG,X,Y,Width,Height,       0.00651, 0.1978, 0.49186, 0.24176,	ColorID, 	State,Alpha)'1
						DrawCEsquare(BG,X,Y,Width,Height,       0.49511, 0.0989, 0.29642, 0.42857,	ColorID, 	State,Alpha)'2
						DrawCEsquare(BG,X,Y,Width,Height,       0.80456, 0.0989, 0.18893, 0.12637,	ColorID, 	State,Alpha)'3
						DrawCEsquare(BG,X,Y,Width,Height,       0.62866, 0.28022, 0.36808, 0.25824,	ColorID, 	State,Alpha)'4
						DrawCEsquare(BG,X,Y,Width,Height,       0.62866, 0.28022, 0.36808, 0.25824,	ColorID, 	State,Alpha)'5
						DrawCEsquare(BG,X,Y,Width,Height,       0.64169, 0.60989, 0.18893, 0.25275,	ColorID, 	State,Alpha)'6    bottom= 0.86264
						DrawCEsquare(BG,X,Y,Width,Height,       0, 0.52747, 0.33225, 0.18681,		ColorID, 	State,Alpha)'7
						DrawCEsquare(BG,X,Y,Width,Height,       0.21173, 0.7033, 0.17915, 0.04945,	ColorID, 	State,Alpha)'8
						DrawCEsquare(BG,X,Y,Width,Height,       0.09121, 0.80769, 0.21498, 0.04945,	ColorID, 	State,Alpha)'9
						DrawCEsquare(BG,X,Y,Width,Height,       0.21498, 0.93407, 0.09446, 0.06593,	ColorID, 	State,Alpha)'10
						DrawCEsquare(BG,X,Y,Width,Height,       0.6645, 0.93407, 0.05212, 0.06593,	ColorID, 	State,Alpha)'11
						DrawCEsquare(BG,X,Y,Width,Height,       0.7329, 0.93407, 0.11075, 0.06593,	ColorID, 	State,Alpha)'12
						DrawCEsquare(BG,X,Y,Width,Height,       0.60586, 0.60989, 0.38436, 0.11538,	ColorID, 	State,Alpha)'13
					'not(oranges)
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0, 0.32248, 0.03297,	ColorID, 	Not(State),Alpha)'      _____________
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.08242, 0.32248, 0.03297,	ColorID, 	Not(State),Alpha)'-------------
						
						DrawCEsquare(BG,X,Y,Width,Height,       0.28013, 0.24725, 0.0228, 0.11538,	ColorID, 	Not(State),Alpha)'|
						DrawCEsquare(BG,X,Y,Width,Height,       0.28013, 0.24725, 0.41042, 0.06593,	ColorID, 	Not(State),Alpha)'-------------
						DrawCEsquare(BG,X,Y,Width,Height,       0.66775, 0.24725, 0.0228, 0.11538,	ColorID, 	Not(State),Alpha)'              |
						
						DrawCEsquare(BG,X,Y,Width,Height,       0.56026, 0.20879, 0.08795, 0.07143,	ColorID, 	Not(State),Alpha)'         ----
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.22527, 0.32000, 0.06593,	ColorID, 	Not(State),Alpha)'-------------
						
						DrawCEsquare(BG,X,Y,Width,Height,       0.42997, 0.40659, 0.04886, 0.08791,	ColorID, 	Not(State),Alpha)'| |
						DrawCEsquare(BG,X,Y,Width,Height,       0.49511, 0.40659, 0.04886, 0.08791,	ColorID, 	Not(State),Alpha)'    | |
						DrawCEsquare(BG,X,Y,Width,Height,       0.557, 0.40659, 0.07492, 0.08791,	ColorID, 	Not(State),Alpha)'           |    |
						
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.60989, 0.32248, 0.02747,	ColorID, 	Not(State),Alpha)'-------------
						
						DrawCEsquare(BG,X,Y,Width,Height,       0.28013, 0.60989, 0.0228, 0.07143,	ColorID, 	Not(State),Alpha)'|
						DrawCEsquare(BG,X,Y,Width,Height,       0.28013, 0.65385, 0.41368, 0.03297,	ColorID, 	Not(State),Alpha)'_____________
						DrawCEsquare(BG,X,Y,Width,Height,       0.67101, 0.60989, 0.0228, 0.07143,	ColorID, 	Not(State),Alpha)'              |	
					'light yellow
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.86264, 0.32248, 0.06593, LCAR.LCAR_LightYellow, State,Alpha)'0
					'dark orange
						DrawCEsquare(BG,X,Y,Width,Height,       0.05537, 0.0989, 0.23127, 0.07143, 	LCAR.LCAR_DarkOrange, State,Alpha)'0
					'black
						DrawCEsquare(BG,X,Y,Width,Height,       0.32573, 0.67033, 0.32248, 0.03297, LCAR.LCAR_Black,False,Alpha)
					'circles
						DrawCEsquare(BG,X,Y,Width,Height,       0.0456, 0.07143, 0.01954, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.30293, 0.04945, 0.01954,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.57003, 0.14835, 0.01629,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.15309, 0.27473, 0.0228, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.18567, 0.38462, 0.02932,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.78176, 0.3956, 0.01954,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.94463, 0.33516, 0.01954,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.88925, 0.49451, 0.02932, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.37785, 0.59341, 0.01954, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.58306, 0.57143, 0.0228, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.91205, 0.57143, 0.02606, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.05863, 0.75824, 0.03583, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.17915, 0.95000, 0.01629,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.36482, 0.76923, 0.01629,  0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.41042, 0.76923, 0.03257, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.55049, 0.76374, 0.03583, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.87296, 0.8022, 0.02932, 0,	ColorID, 	Not(State),Alpha)
						DrawCEsquare(BG,X,Y,Width,Height,       0.04235, 0.47253, 0.0228, 0,	ColorID, 	Not(State),Alpha)
				Case Else: DidDraw = False
			End Select
		Case 37'Transporter 2
			'ElementID/Rwidth is height of bottom bar, TextAlign/temp0 is height of top bar, Align is text size, Elbow aligns = 0 |^  top left, 3  _| bottom right
			temp = BG.MeasureStringWidth(Text, LCAR.LCARfont, Align)'Width of text
			temp2=Width*0.66'X of joint
			temp3=LCAR.ItemHeight 'width of bar
			BG.DrawText(Text, X, Y+Height, LCAR.LCARfont, Align, Color, "LEFT")
			
			LCAR.DrawLCARelbow(BG, X+temp, Y+TextAlign,  temp2-temp+temp3, Height-TextAlign,   temp3,ElementID,  3, ColorID,State, "", 0, Alpha, False)
			LCAR.DrawLCARelbow(BG, X+temp2, Y, Width-temp2, TextAlign*2, temp3, TextAlign, 0, ColorID,State,"",0, Alpha,False)
			
			If File.Exists(LCAR.DirDefaultExternal,"sysorange.png") Then 
				LoadUniversalBMP(LCAR.DirDefaultExternal,"sysorange.png", LCAR.LCAR_LWP)
				temp4= Height-ElementID-TextAlign
				Dim Size As Point = API.ThumbSize(1881, 411, Width,temp4, True ,False)
				temp4=temp4*0.5 - Size.Y*0.5 + TextAlign
				BG.DrawBitmap(CenterPlatform, LCARSeffects4.SetRect(0,0,1881,411), LCARSeffects4.SetRect(X+Width-Size.X,  temp4   , Size.X, Size.Y))
				LCARSeffects.makeclippath(BG, X+temp2, Y,temp3,Height)
				BG.DrawBitmap(CenterPlatform,LCARSeffects4.SetRect(0,411,1881,411), LCARSeffects4.SetRect(X+Width-Size.X,  temp4   , Size.X, Size.Y))
				BG.RemoveClip 
			End If
			
		Case 48'ENT-B Bridge
			LoadUniversalBMP(File.DirAssets,"excelsior.png", LCAR.LCAR_LWP)
			Select Case ElementID
				Case 0'STARFLEET INSIGNIA
					temp5 = LCAR.Fontsize * LCAR.ScaleFactor
					temp3 = BG.MeasureStringHeight(Text, StarshipFont, temp5)
					temp4 = LCAR.GetColor(LCAR.Classic_Blue, True, Alpha)
					BG.DrawText(Text, X+Width*0.5, Y+Height-temp3, StarshipFont, temp5, temp4, "CENTER")
					Height = Height - temp3*3
					
					If TextAlign > 0 Then 
						tempF = TextAlign * 0.01
						temp = Width * tempF
					End If
					If Align > 0 Then 
						tempF = Align * 0.01
						temp2 = Height * tempF
					End If
					LCAR.DrawLCARPicture(BG, X+temp,Y+temp2,Width-temp*2,Height-temp2*2, -1, 0, Alpha, False, 0, 1100, 218, 296)
				Case 1,-1'TEXT
					temp = LCAR.Fontsize
					If ElementID = -1 Then temp = temp * 0.5				
					Select Case TextAlign
						Case 1,2,3:temp2 = Y+Height'BOTTOM
						Case 7,8,9:temp2 = Y+BG.MeasureStringHeight(Text, StarshipFont, temp)'TOP
						Case 4,5,6:temp2 = Y+Height*0.5+BG.MeasureStringHeight(Text, StarshipFont, temp)*0.5'MIDDLE
					End Select
					Select Case TextAlign
						Case 7,4,1: BG.DrawText(Text, X, temp2, StarshipFont, temp, Color, "LEFT")
						Case 8,5,2: BG.DrawText(Text, X+Width*0.5, temp2, StarshipFont, temp, Color, "CENTER")
						Case 9,6,3: BG.DrawText(Text, X+Width, temp2, StarshipFont, temp, Color, "RIGHT")
					End Select
					'Log("Drawtext: " & X & " " & temp2 & " " & temp)'78, 1822 of 1080, 18
				Case 2'NX-2000
					temp7 = Min(Width,Height) * 0.5 'Radius
					temp3 = X + Width * 0.5			'Center X
					temp4 = Y + Height * 0.5		'Center Y
					temp5 = 5'Stroke
					BG.DrawCircle(temp3,temp4, temp7-temp5, Color, False, temp5)
					LCARSeffects6.ClipOval(BG, temp3-temp7, temp4-temp7, temp7*2, temp7*2)
					temp2 = LCAR.getcolor(LCAR.Classic_Yellow, False, Alpha)'Yellow
					temp8 = temp3-temp7*0.5'X
					BG.drawline(temp8, Y, temp8, Y + Height, temp2, temp5)'|
					For temp6 = temp4-temp7 To temp4 + temp7 Step LCAR.ItemHeight * 0.5
						BG.DrawLine(temp8, temp6, temp8+LCAR.ItemHeight * 0.25, temp6, temp2, temp5)'=
						temp0=temp0+1
						If temp0 = 6 Then temp9 = temp6
					Next
					BG.RemoveClip
					If temp9 = 0 Then temp9= temp4'backup
					BG.drawline(temp8, temp9, X+Width, temp9, temp2, temp5)'---
					For temp6 = temp3 + temp7 * 0.4 To X + Width Step LCAR.ItemHeight * 0.5
						BG.DrawLine(temp6, temp9, temp6, temp9 + LCAR.ItemHeight * 0.25, temp2, temp5)'| | | |
					Next
					
					
					temp = Min(1100, Height * 0.80)	'Height of image
					tempF = temp / 1100				'Aspect ratio
					temp2 = tempF * 218 			'Width of image
					temp6 = TextAlign
					If temp6 >= 100 Then temp6 = 100 - (temp6 - 100)
					temp6 = (temp7 * 2) * temp6 * 0.005'1/2 Width of shield
					'DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3 - temp2+1, temp4 - temp * 0.5, temp2,temp, Alpha,  False, False)'left side
					'DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3, temp4 - temp * 0.5, temp2,temp, Alpha,  True, False)'right side
					
					DidDraw = TextAlign < 50 Or (TextAlign >= 100 And TextAlign < 150)
					
					If DidDraw Then'Under
						DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3 - temp2+1, temp4 - temp * 0.5, temp2,temp, Alpha,  False, False)'left side
					Else 
						DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3, temp4 - temp * 0.5, temp2,temp, Alpha,  True, False)'right side
					End If
					
					LCARSeffects6.DrawOval(BG, temp3-temp6,temp4-temp7+temp5, temp6*2,temp7*2-temp5*2, Color, temp5)'First Oval
				
					'Second oval
					temp6 = (TextAlign + 100) Mod 200
					If temp6 >= 100 Then temp6 = 100 - (temp6 - 100)
					temp6 = (temp7 * 2) * temp6 * 0.005'1/2 Width of shield
					LCARSeffects6.DrawOval(BG, temp3-temp6,temp4-temp7+temp5, temp6*2,temp7*2-temp5*2, Color, temp5)
					
					If DidDraw Then'Over
						DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3, temp4 - temp * 0.5, temp2,temp, Alpha,  True, False)'right side
					Else
						DrawBMP(BG, CenterPlatform, 0,0,218,1100,    temp3 - temp2+1, temp4 - temp * 0.5, temp2,temp, Alpha,  False, False)'left side
					End If
					
					'Crosshairs 
					temp = TextAlign * 1.8'ANGLE
					temp2 = LCAR.getcolor(LCAR.Classic_Yellow, False, Alpha)'Yellow
					temp6 = Trig.findXYAngle(temp3,temp4, temp7, temp,True)'X
					temp7 = Trig.findXYAngle(temp3,temp4, temp7, temp,False)'Y
					BG.DrawLine(temp6, Y, temp6, Y+Height, temp2, temp5)
					BG.DrawLine(X, temp7, X+Width, temp7, temp2, temp5)
					BG.DrawCircle(temp6, temp7, temp5*2, temp2, True, 0)
					
					DidDraw=True 
				
				Case 3, 4'chart
					temp  = Width * 0.20'Left
					temp2 = Height * 0.02'top
					temp3 = Width * 0.15'width
					temp4 = Height * 0.90'Height
					temp5 = API.GetMS
					If ElementID = 3 Then 
						temp6 = DateTime.GetSecond(DateTime.Now) + DateTime.GetMinute(DateTime.Now) * 10
						temp7 = LCAR.GetColor(LCAR.Classic_Yellow, State, Alpha)
						temp8 = LCAR.GetColor(LCAR.Classic_Green, State, Alpha)
					Else 
						temp5 = 1000 - temp5
						temp6 = 650 + temp5 * -0.25
						temp7 = LCAR.GetColor(LCAR.Classic_Green, State, Alpha)
						temp8 = LCAR.GetColor(LCAR.Classic_Blue, State, Alpha)
					End If 
					DrawENTBchart(BG, X+temp, Y+temp2,temp3,temp4, False, State, Alpha, temp5, temp7, temp8)
					DrawENTBchart(BG, X+Width-temp-temp3, Y+temp2,temp3,temp4, True, State, Alpha, temp6, temp7, temp8)
					
				Case 5'radar					
					temp = X + Width * 0.60'centerX
					temp2 = Y + Height * 0.60'centerY
					temp3 = Height * 0.70 'Width * 0.44'radius (outer)
					temp4 = Height * 0.57 'Width * 0.34'radius (middle)
					temp5 = Height * 0.36'Width * 0.23'radius (inner)
					temp6 = Height * 0.024'Stroke
					'temp7 = Width * 0.0833333333333333'Width of Excelsior
					temp8 = Height * 0.27'temp7 * 2.531645569620253'Height of Excelsior
					temp7 = temp8 * 0.395'Width of Excelsior
					tempF = API.GetTextHeight(BG, Height * -0.13, "090", StarshipFont)'Fontsize
					temp9 = BG.MeasureStringHeight("ABC123", StarshipFont, tempF)'Font height
					temp0 = temp6 * 0.5 + 2'whitespace
					
					LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
					DrawRadarWave(BG, temp, temp2, 0, temp3, 45, 66, 239, 104, TextAlign)
					
					BG.DrawLine(X, temp2, X+Width, temp2, Color, temp6)'---
					BG.DrawLine(temp, Y, temp, temp+Height, Color, temp6)'|
					BG.DrawCircle(temp,temp2, temp3, Color, False, temp6)'Outer
					BG.DrawCircle(temp,temp2, temp4, Color, False, temp6)'Middle
					BG.DrawCircle(temp,temp2, temp5, Color, False, temp6)'Inner
				
					BG.DrawBitmap(CenterPlatform, LCARSeffects4.SetRect(0,1396,79,200), LCARSeffects4.SetRect(temp - temp7 * 0.5, temp2 - temp8*0.5, temp7,temp8))
					
					Color = Colors.ARGB(Alpha, 40, 253, 249)
					BG.DrawText("270", temp - temp3 + temp0, temp2 - temp0, StarshipFont, tempF, Color, "LEFT")
					BG.DrawText("PRT", temp - temp3 + temp0, temp2 + temp0 + temp9, StarshipFont, tempF, Color, "LEFT")
					
					BG.DrawText("090", temp + temp3 - temp0, temp2 - temp0, StarshipFont, tempF, Color, "RIGHT")
					BG.DrawText("STB", temp + temp3 - temp0, temp2 + temp0 + temp9, StarshipFont, tempF, Color, "RIGHT")
					
					BG.DrawText("050", temp, temp2 - temp5 + temp0 + temp9, StarshipFont, tempF, Color, "CENTER")
					BG.DrawText("050", temp, temp2 + temp5 - temp0, StarshipFont, tempF, Color, "CENTER")
					
					BG.DrawText("075", temp, temp2 - (Height*0.465) + temp9*0.5, StarshipFont, tempF, Color, "CENTER")
					'BG.drawtext("100", temp, temp2 - temp3 - temp9*0.5, StarshipFont, tempF, Colors.green, "CENTER")
					BG.DrawText("FOR", temp, Y + temp9 + 2, StarshipFont, tempF, Color, "CENTER")
					
					temp3 = Trig.findXYAngle(0,0, temp5+temp0, 45, True)'Offset
					BG.DrawText("045", temp + temp3, temp2 - temp3, StarshipFont, tempF, Color, "LEFT")
					BG.DrawText("135", temp + temp3, temp2 + temp3 + temp9, StarshipFont, tempF, Color, "LEFT")
					
					BG.DrawText("225", temp - temp3, temp2 + temp3 + temp9, StarshipFont, tempF, Color, "RIGHT")
					BG.DrawText("315", temp - temp3, temp2 - temp3, StarshipFont, tempF, Color, "RIGHT")
					
					BG.DrawText("PB", temp - temp7 * 0.5 - 2, temp2 - temp0*2, StarshipFont, tempF, Color, "RIGHT")
					BG.DrawText("PS", temp - temp7 * 0.5 - 2, temp2 + temp0*7, StarshipFont, tempF, Color, "RIGHT")
					
					BG.DrawText("SB", temp + temp7 * 0.5 + 2, temp2 - temp0*2, StarshipFont, tempF, Color, "LEFT")
					BG.DrawText("SS", temp + temp7 * 0.5 + 2, temp2 + temp0*7, StarshipFont, tempF, Color, "LEFT")
					
					'lcarseffects6.OpPath( ,0)
					'DrawPreCARSGradient(BG, temp, temp2, temp3, 60, 0)
					
					BG.RemoveClip
				
				Case 6'Gravimetric distortion
					temp = Height * 0.1
					temp3 = LCAR.GetColor(LCAR.Classic_Red, False, TextAlign)
					DrawRoundRect(BG,X,Y,Height,Height, temp3, temp)
					temp2 = 4
					temp = API.GetTextLimitedHeight(BG, (Height - 2) * 0.5, Width-Height-temp2, "GRAVIMETRIC", StarshipFont)
					temp4 = BG.MeasureStringHeight(Text, StarshipFont, temp)
					BG.DrawText(Text, X + Height + temp2, y + temp4, StarshipFont, temp, temp3, "LEFT")
					BG.DrawText(SideText, X + Height + temp2, y + Height, StarshipFont, temp, temp3, "LEFT")
				
				Case 7'Bars
					temp2 = Height / 11'Height of line
					temp3 = Min(Width, temp2 - 10)'Height of Square
					temp4 = temp3 * 0.1'corner radius
					temp5 = API.GetTextHeight(BG, temp3*0.4, "10", StarshipFont)
					For temp = 0 To 9
						DrawRoundRect(BG,X,Y, Width, temp3, LCAR.GetColor(LCAR.Classic_Blue, True, TextAlign), temp4)
						BG.DrawText(API.PadtoLength(temp*10, True, 2, "0"), X+Width-temp4, Y+temp3-temp4, StarshipFont, temp5, Colors.black, "RIGHT")
						Y = Y + temp2
						If Align = 1 Then 
							TextAlign = TextAlign - 16
							If TextAlign <= 0 Then 
								TextAlign = 0
								Align = 0
							End If
						Else 
							TextAlign = TextAlign + 16
							If TextAlign > 255 Then 
								TextAlign = 255
								Align = 0
							End If
						End If
					Next
					Height = Height - (temp2*10)
					temp = API.GetTextLimitedHeight(BG, Height,Width, "255", StarshipFont)
					temp2 = BG.MeasureStringHeight(TextAlign, StarshipFont, temp)
					BG.DrawText(TextAlign, x + Width * 0.5, Y + Height * 0.5 + temp2 * 0.5, StarshipFont, temp, Color, "CENTER")
				
				Case 8'Alert condition status 
					'212*68 of 386*229 = 55%*30%, use TextAlign as alpha
					DidDraw = True
					SideText = "alert_green"
					ColorID = LCAR.Classic_Green
					If LCAR.RedAlert Then 
						SideText = "alert_red"
						ColorID = LCAR.LCAR_Red
						If LCAR.RedAlertMode = LCAR.Classic_Blue Then 
							SideText = "alert_blue"
							ColorID = LCAR.Classic_Blue
						Else 
							DidDraw = False 
						End If
					End If
					SideText = API.GetString(SideText)
					temp = Width * 0.55
					temp2 = Height * 0.30
					temp3 = API.GetTextHeight(BG, -temp, SideText, StarshipFont)'CONDITION: RED fontsize
					
					If TextAlign > 0 Then 
						Color = LCAR.GetColor(ColorID, DidDraw, Min(255,TextAlign))
						BG.DrawText(SideText, x + Width * 0.5, y + Height * 0.5 + temp2 * 0.5, StarshipFont, temp3, Color, "CENTER")
						temp3 = BG.MeasureStringHeight(SideText, StarshipFont, temp3)'font height 
						temp3 = API.GetTextLimitedHeight(BG, temp2 - temp3 - 10, temp, Text, StarshipFont)'font size
						BG.DrawText(Text, x + Width * 0.5, Y + Height * 0.5 - temp2 * 0.5 + 5 + BG.MeasureStringHeight(Text, StarshipFont, temp3), StarshipFont, temp3, Colors.ARGB(Min(255,TextAlign), 185,218,255), "CENTER")'ALERT
					End If 
					
					temp3 = Height * 0.5 - temp2 * 0.5 'Y
					temp4 = temp3 * 0.0625'0.10'height
					temp6 = Width * 0.5 - temp * 0.5 'X
					temp7 = temp6 * 0.0625'0.10'width
					
					For temp5 = 0 To 15
						If TextAlign = 16 Then 
							Color = Colors.rgb(75,86,75)'Brown
						else if TextAlign = 0 Then 
							Color = Colors.RGB(185,218,255)'Light blue
						Else 
							Color = LCAR.GetColor(ColorID, DidDraw, Min(255,TextAlign))
						End If
						If Color <> Colors.black Then 
							LCARSeffects4.DrawRect(BG, X + temp6, Y + temp3 - temp4*(temp5+1), temp, temp4-1, Color, 0)' top 
							LCARSeffects4.DrawRect(BG, X + temp6, Y + temp3 + temp2 + 1 + temp4*temp5, temp, temp4-1, Color, 0)'Bottom 
							LCARSeffects4.DrawRect(BG, X + temp6 - temp7 * (temp5+1), Y + temp3, temp7-1, temp2, Color, 0)'left
							LCARSeffects4.DrawRect(BG, X + temp + temp6 + temp7 * temp5, Y + temp3, temp7-1, temp2, Color, 0)'Right
						End If 
						TextAlign = TextAlign - 16 
						If TextAlign < -48 Then TextAlign = 256
					Next
					DidDraw=True 
					
				Case 9'chart 
					temp3 = (Height - Align*2) * 0.1'lineheight
					temp4 = API.GetTextHeight(BG, temp3, "000", StarshipFont)'fontsize
					tempF = temp3/296'Aspect ratio of insignia
					temp8 = 218 * tempF'Width

					temp = BG.MeasureStringWidth("000", StarshipFont, temp4) + Align * 4'width
					temp2 = X+temp+Align'X of right side
					DrawPreCARSFrame(BG, X, Y, temp, Height, ColorID, Alpha, 1, Align*2, Align, "", 0, "")
					DrawPreCARSFrame(BG, temp2, Y, Width - temp-Align, Height, ColorID, Alpha, 3, Align*2, Align, "", 0, "")
					
					temp7 = Width -temp-Align'Width of right side
					temp5 = temp7 * 0.2162162162162162
					temp9 = temp7 * 0.08
					temp7 = temp2 + temp5 '(Width -temp-Align) * 0.5'center of right side
					temp0 = temp7 + temp9*0.5 - temp8
					LCAR.DrawLCARPicture(BG, temp0, Y+Align, temp8 ,temp3, -1, 0, 255, False, 0, 1100, 218, 296)
					BG.DrawText(Text, temp7+temp9, Y+Align+temp3, StarshipFont, temp4, Color, "LEFT")
					LCAR.DrawLCARPicture(BG, temp0,Y+Height-Align-temp3, temp8 ,temp3, -1, 0, 255, False, 0, 1100, 218, 296)
					BG.DrawText(SideText, temp7+temp9, Y+Height-Align, StarshipFont, temp4, Color, "LEFT")
					
					temp6 = x + temp*0.5'Middle of left side
					Y = Y + temp3 + Align 
					X = temp2 + Align
					Width = Width - temp - Align * 3'Width of right side
					temp = BG.MeasureStringWidth("360", StarshipFont, LCAR.Fontsize)
					For temp5 = 0 To 7 
						TextAlign = (TextAlign + 10) Mod 180
						DrawENTBgraph(BG, X, Y, Width-temp, temp3 - 2, 22 + TextAlign, DateTime.GetSecond(DateTime.Now) Mod 8 = temp5, temp, temp6, temp5, temp4)
						y = y + temp3 
					Next
				
				Case 10'graphs
					temp = FindGraph(Align)
					If temp = -1 Then 
						temp = 25
						If TextAlign <> 7 Then temp = temp * 2
						temp = AddGraph(Align, temp, False)
						temp3 = Rnd(1,25)
						For temp2 = 1 To temp3
							AddPoint(temp, Rnd(10,100) )
						Next 
					End If 	
					temp3 = 0
					temp2 = 0
					If TextAlign = 7 Then 
						temp3 = Width * 0.04
						temp2 = Height * 0.20
					End If
					LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
					DrawGraph(temp, BG, X,Y+temp2, Width + temp3, Height-temp2*2, ColorID, Color, 255, TextAlign, 0, 0)
					temp = Width * 0.25
					If TextAlign <> 7 Then temp = temp * 0.5
					temp2 = Height / 7
					temp4 = LCAR.Fontsize * 0.33
					temp5 = BG.MeasureStringHeight("0123", StarshipFont, temp4)
					LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)'just in case
					LCARSeffects4.DrawGrid(BG, X - temp*0.5, y - temp2 * 0.5, Width + temp, Height + temp2, temp, temp2, Color, 2) 
					If TextAlign = 7 Then 
						For temp3 = 0 To 6
							Tag = API.PadtoLength(temp3+1, True, 2, "0")
							tempF = temp3 + 0.5
							If temp3 < 4 Then BG.DrawText(Tag, x + temp*tempF, Y+temp5, StarshipFont, temp4, Color, "RIGHT")
							BG.DrawText(Tag, X, Y + temp2*tempF + temp5 + 6, StarshipFont, temp4, Color, "LEFT")
						Next 
					End If 
					BG.RemoveClip
					
				Case 11'circles
					LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
					temp2 = Height * 0.71'radius X
					temp3 = X + Width * 0.5'CenterX
					temp4 = Y + Height * 0.5 'CenterY
					temp = Min(Width,Height) * 0.1111111111111111'Diameter
					temp5 = Trig.findXYangle(0,0, temp + 2, TextAlign, True)'Row X
					temp6 = Trig.findXYangle(0,0, temp + 2, TextAlign, False)'Row Y
					temp7 = Trig.findXYangle(0,0, temp + 2, TextAlign+90, True)'Col X
					temp8 = Trig.findXYangle(0,0, temp + 2, TextAlign+90, False)'Col Y
					temp = temp * 0.5 
					Color = LCAR.GetColor(ColorID, True, 255)
					For temp0 = 0 To 4'X
						Align = temp7*temp0
						tempF = temp8*temp0
						For temp9 = 0 To 4'Y
							DrawENTBCircle(BG, temp3 + Align + (temp5*temp9), temp4 + tempF + (temp6*temp9), temp, Color, -temp0, temp9, TextAlign)'TR
							If temp0 > 0 Then DrawENTBCircle(BG, temp3 - Align + (temp5*temp9), temp4 - tempF + (temp6*temp9), temp, Color, -temp0, -temp9, TextAlign)'TL
							If temp9 > 0 Then 
								DrawENTBCircle(BG, temp3 + Align - (temp5*temp9), temp4 + tempF - (temp6*temp9), temp, Color, temp0, temp9, TextAlign)'BR
								If temp0 > 0 Then DrawENTBCircle(BG, temp3 - Align - (temp5*temp9), temp4 - tempF - (temp6*temp9), temp, Color, temp0, -temp9, TextAlign)'BL
							End If
						Next
					Next
					
					Color = LCAR.GetColor(ColorID, False, 255)
					temp = 4'Stroke
					temp5 = Height * 0.16'83/263
					temp8 = Trig.GetCorrectAngle(0,0, Width,Height)'Angle
					temp6 = Trig.findXYangle(0,0, temp5, temp8, True)'X
					temp7 = Trig.findXYangle(0,0, temp5, temp8, False)'Y
					BG.DrawLine(X,Y,  				temp3-temp6,	temp4-temp7, Color, temp)'TL
					BG.DrawLine(X+Width,Y,  		temp3+temp6,	temp4-temp7, Color, temp)'TR
					BG.DrawLine(X,Y+Height, 		temp3-temp6,	temp4+temp7, Color, temp)'BL
					BG.DrawLine(X+Width,Y+Height, 	temp3+temp6,	temp4+temp7, Color, temp)'BR
					temp6=Width*0.16'29/180
					BG.DrawLine(temp3, Y, temp3, temp4 - temp5, Color, temp)'| top
					BG.DrawLine(temp3, Y+Height, temp3, temp4 + temp5, Color, temp)'| bottom
					BG.DrawLine(X, temp4, temp3 - temp6, temp4, Color, temp)'- left
					BG.DrawLine(X+Width, temp4, temp3 + temp6, temp4, Color, temp)'- right
					
					LCARSeffects4.drawoval(BG, temp3,temp4, Width*1.15, Height*1.05, Color,temp, True)
					LCARSeffects4.drawoval(BG, temp3,temp4, Width*1.05, Height*0.95, Color,temp, True)'251/263
					LCARSeffects4.drawoval(BG, temp3,temp4, Width*0.90, Height*0.85, Color,temp, True)'223/263, 175/180
					LCARSeffects4.drawoval(BG, temp3,temp4, Width*0.77, Height*0.70, Color,temp, True)'184/263, 139/180
					LCARSeffects4.drawoval(BG, temp3,temp4, Width*0.61, Height*0.55, Color,temp, True)'147/263, 110/180
					BG.RemoveClip
					
				Case 12'EMF
					temp = Colors.RGB(134, 196, 252)'off-white
					Height = Height + 1
					Width = Width + 1
					LCARSeffects4.drawrect(BG,x,y,Width,Height, Colors.RGB(14,32,143), 0)'dark blue
					temp2 = Width * 0.40'Width of square
					temp3 = Height * 0.25 'Height of quarters
					temp4 = BG.MeasureStringHeight("0", StarshipFont,LCAR.Fontsize) * 0.25' Stroke
					BG.DrawLine(X, Y + temp3, X + Width, Y + temp3, temp, temp4)'Top
					BG.DrawLine(X+temp2, Y + temp3 * 2, X + Width, Y + temp3 * 2, temp, temp4)'Middle
					BG.DrawLine(X+temp2, Y + temp3, X+temp2, Y + temp3 * 3, temp, temp4)'|
					BG.DrawLine(X, Y + Height - temp3, X + Width, Y + Height - temp3, temp, temp4)'Bottom 
					
					temp5 = LCAR.Fontsize * 0.75
					temp6 = BG.MeasureStringHeight(Text, StarshipFont,temp5) 
					BG.DrawText(Text, x + temp4 * 2, y + temp3 * 0.25 + temp6 * 0.5, StarshipFont, temp5, temp, "LEFT")
					BG.drawtext(SideText, x + Width - temp4 *2, y + temp3 - temp4 * 4, StarshipFont, LCAR.Fontsize, temp, "RIGHT")
					temp7 = X + Max(BG.MeasureStringWidth(Text, StarshipFont,temp5) + temp4 * 3, temp2)
					BG.DrawLine(temp7, y + temp3 * 0.25 - temp6 * 0.5, temp7, y + temp3 - temp4*2, temp, temp4)'| top
				
				Case 13'Grid
					Color = Colors.RGB(14,32,143)'dark blue
					LCARSeffects4.drawrect(BG,x,y,Width,Height, Color, 0)
					temp2 = Min(Width, Height) * 0.4
					temp3 = x + Width * 0.5'center x
					temp4 = y + Height * 0.5'center y
					temp5 = Min(Width, Height) * 0.1
					temp6 = Trig.findXYAngle(temp3, temp4, temp5, TextAlign, True)
					temp7 = Trig.findXYAngle(temp3, temp4, temp5, TextAlign, False)
					Wireframe.circlegradient(BG, temp6, temp7, temp2, Color, Colors.white)
					
					temp = Width / 15'width of a column
					temp2 = Height / 15'height of a row
					temp0 = Align * 0.5'BG.MeasureStringHeight("0", StarshipFont, LCAR.Fontsize*0.5)'stroke
					temp7 = temp - temp0'width - stroke
					temp8 = temp2 - temp0'height-stroke
					temp9 = Height - (temp2*15)'remaining Y
					tempF = Width - (temp*15)'remaining X
					temp3 = X + tempF'starting X +*0.5
					Color = Colors.RGB(134, 196, 252)'off-white
					
					LCARSeffects.MakeClipPath(BG,x,y,Width,Height)
					For temp4 = 0 To 14
						temp6 = Y - temp9 *0.5'Starting Y
						If temp4 = 14 Then temp7 = temp7 + temp0 
						For temp5 = 0 To 14 
							If temp4 = 14 And tempF > 0 Then LCARSeffects4.drawrect(BG, X+Width-tempF, temp6, tempF, temp8, Colors.black, 0)
							LCARSeffects4.drawrect(BG, temp3, temp6, temp7, temp8, Colors.black, 0)
							temp6 = temp6 + temp2  
						Next
						LCARSeffects4.drawrect(BG, temp3, temp6, temp7, temp9*2, Colors.black, 0)
						temp3 = temp3 + temp
						If temp4 = 4 Or temp4 = 9 Then 
							BG.drawline(temp3 - temp0 * 0.5, Y, temp3 - temp0 * 0.5, Y + Height+ Align*2, Color, temp0)'DIVIDERS
						End If
					Next
					BG.removeclip
				Case 14'bar graph
					LCARSeffects4.drawrect(BG,x,y,Width,Height, Colors.Black, 0)
					temp4 = BG.MeasureStringHeight("0123", StarshipFont, LCAR.Fontsize * 0.5)' Textsize/stroke
					temp = Width * 0.27 - temp4 * 2'left side
					'align = graph number
					'textalign = stroke
					X = X + temp + temp4
					Y = Y + temp4
					Width = Width - temp - temp4 * 2
					Height = Height - temp4 * 2
					LCARSeffects4.DrawRect(BG, X, Y,Width, Height, Colors.RGB(84, 68, 127), temp4*0.5)
					temp = 2'whitespace
					temp2 = (Width + temp) * 0.125
					temp5 = DateTime.GetSecond(DateTime.Now) * 0.16
					For temp3 = 0 To 7 
						temp4 = (API.IIF(temp3 Mod 2 = 0, TextAlign, Align) + (temp3 * 4) + temp5) Mod 100 
						DrawENTBBar2(BG, X, Y, temp2, Height, temp4, temp)
						X=X+temp2
					Next
					
				Case 15'sin waves
					If Not(HasALine(Align)) Then
						AddRowOfNumbers(Align, LCAR.LCAR_DarkPurple, Array As Int(3,1,5,-1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
			
						AddRowOfNumbers(Align, LCAR.LCAR_DarkPurple, Array As Int(3,1,5,-1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
			
						AddRowOfNumbers(Align, LCAR.Classic_Blue, Array As Int(3,1,5,-1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
						AddRowOfNumbers(Align, LCAR.LCAR_White, Array As Int(2,1,6,-1,6,1))
					End If
					temp4 = BG.MeasureStringHeight("0123", StarshipFont, LCAR.Fontsize * 0.5)'Textsize/stroke
					temp = Min(Height - temp4, (temp4 + 2) * 9 - 2) 'Height of RND block
					temp2 = Width*0.27 - temp4*2'width of RND block
					LCARSeffects.MakeClipPath(BG, X+ temp4, Y + Height * 0.5 - temp * 0.5,	temp2, temp)
					DrawNumberBlock(BG, X+ temp4, Y + Height * 0.5 - temp * 0.5,	temp2, temp, LCAR.LCAR_White, Align, LCAR.TMP_RndNumbers, "")
					BG.RemoveClip
					X = X + temp2 + temp4
					Y = Y + temp4
					Width = Width - temp2 - temp4 * 2
					Height = Height - temp4 * 2
					temp = Colors.RGB(71, 123, 229)
					temp4 = temp4*0.5
					
					LCARSeffects4.DrawRect(BG, X, Y,Width, Height, temp, temp4)
					
					temp2 = Height * 0.20
					temp3 = Max(10, Abs(Trig.findXYAngle(0,0, Height * 0.16, TextAlign, False)))
					DrawENTSINwave(BG, X,Y,Width,Height, 0, temp3, Width * 0.50, temp, temp4, 1.5, 1)
					temp3 = Max(10, Abs(Trig.findXYAngle(0,0, Height * 0.24, TextAlign*2, True)))
					DrawENTSINwave(BG, X,Y,Width,Height, 0, temp3, Width * 0.75, Colors.RGB(212,32,0), temp4, 1.1, 1)
					temp3 = Max(10, Abs(Trig.findXYAngle(0,0, Height * 0.33, TextAlign*3, False)))
					DrawENTSINwave(BG, X,Y,Width,Height, 0, temp3, Width * 0.35, Colors.RGB(57,67,236), temp4, 1.3, 1)
										
					For temp3 = 1 To 4
						Y=Y+temp2
						BG.DrawLine(X,Y, X+Width, Y, temp, temp4)
					Next
				
				Case 16, 22'PRAXIS 1/2
					temp = Width * 0.75
					temp2 = Height * 0.75
					temp3 = Width * 0.25
					temp4 = 0
					If ElementID = 22 Then temp4 = 3
					DrawCustomElement(BG,X,Y, temp, temp2, 47, temp4 + 0, ColorID, State, Alpha, Text, "", TextAlign, Align, "")'TL
					DrawCustomElement(BG,X + temp, Y, temp3, temp2, 47, temp4 + 1, ColorID, State, Alpha, SideText, "", TextAlign, Align, "")'TR
					DrawCustomElement(BG,X,Y + temp2, Width, Height * 0.25, 47, temp4 + 2, ColorID, State, Alpha, Tag, "", TextAlign, Align, "")'Bottom
					temp5 = 5
					Color = Colors.white 
					BG.drawline(X + temp, Y, X + temp, Y + temp2, Color, temp5)
					BG.DrawLine(X, Y + temp2, X + Width, Y + temp2, Color, temp5)
					'548x476 of 716x626
				
				Case 17'ENT-A
					temp = TextAlign * 3
					temp2 = Y + Height * 0.5
					temp3 = X + Width * 0.5 
					temp4 = Colors.rgb(44,76,86)'dark grey
					temp5 = Colors.RGB(98,159,169)'light grey
					temp6 = Min(Width,Height) * 0.25 
					temp8 = Width * 0.5 - temp6 - temp - TextAlign
					ElementID = LCAR.fontsize * 0.5
					BG.drawcircle(temp3, temp2, temp6, temp5, False, TextAlign)
					LCARSeffects4.DrawRect(BG, temp3-TextAlign*2, temp2-temp6-TextAlign, TextAlign*4, TextAlign*2, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, temp3-TextAlign*2, temp2+temp6-TextAlign, TextAlign*4, TextAlign*2, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, temp3-temp6-TextAlign, temp2-TextAlign*2, TextAlign*2, TextAlign*4, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, temp3+temp6-TextAlign, temp2-TextAlign*2, TextAlign*2, TextAlign*4, Colors.black, 0)
					
					DrawStars(BG, X,Y,Width,Height, TextAlign*0.4, temp5, Array As Float(3.194103E-02, 0.1838235, 9.090909E-02, 0.1213235, 0.1597052, 8.088236E-02, 0.2825553, 5.147059E-02, 0.3071253, 6.617647E-02, 0.3243243, 2.205882E-02,  _ 
					0.4078624, 0.0992647, 0.4619165, 0.1727941, 0.4471745, 0.2205882, 0.4054054,0.2647059, 0.3685504, 0.3088235, 0.3218673, 0.4007353, 0.2530712, 0.4558823, 0.2506143, 0.4044118, 0.2186732, 0.3602941, 0.2088452, 0.3897059,  _ 
					0.1597052, 0.4264706, 8.353809E-02, 0.4007353, 8.108108E-02, 0.3308823, 6.142506E-02, 0.2941177, 0.1572482, 0.2867647, 0.2432432, 0.2647059, 0.3169533, 0.1691176, 0.4152334, 0.3492647, 0.3513514, 0.4191177, 0.3783784,   _
					0.4558823, 0.4570025, 0.4595588, 0.4594595, 0.4227941, 0.4373464, 0.3639706, 0.5405405, 0.3860294, 0.5356265, 0.2794118, 0.5675676, 0.3088235, 0.5995086, 0.3897059, 0.6486486, 0.4485294, 0.7100737, 0.4669118, 0.7567568, _
					 0.4117647, 0.6289926, 0.2867647, 0.6388206, 0.2463235, 0.5380836, 0.2279412, 0.5503685, 0.1433824, 0.5626535, 0.1580882, 0.6068796, 0.1617647, 0.5479115, 1.102941E-02, 0.6388206, 6.617647E-02, 0.6584767, 4.044118E-02,  _
					 0.7174447, 9.558824E-02, 0.7199017, 0.1397059, 0.7027027, 0.1985294, 0.7248157,0.2830882, 0.7346438, 0.3088235, 0.7592137, 0.2830882, 0.943489, 0.3272059, 0.9680589, 0.1617647, 0.990172, 7.352941E-02, 0.9606879,        _
					 5.882353E-02, 0.8820639, 0.1066176, 0.7960688, 0.1066176, 0.7985258, 6.985294E-02, 0.7493858, 4.779412E-02, 0.6486486, 0.5588235, 0.6289926, 0.5477941, 0.6191646, 0.6617647, 0.5429975, 0.6875, 0.5651106, 0.7169118,     _ 
					 0.4619165, 0.7316176, 0.4520884, 0.6948529, 0.3513514, 0.5588235, 0.2776413, 0.5882353, 0.2014742, 0.5992647, 0.1842752, 0.6176471, 0.1179361, 0.5882353, 1.965602E-02, 0.6764706, 7.125307E-02, 0.7316176, 9.582309E-02,  _
					 0.8014706, 4.422604E-02, 0.8676471, 5.896806E-02, 0.9227941, 4.422604E-02, 0.9485294, 0.1326781, 0.9375, 0.1351351, 0.9742647, 0.1891892, 0.9154412, 0.1277641, 0.7867647, 0.1990172, 0.6801471, 0.2604423, 0.7279412,     _
					 0.2506143, 0.7794118, 0.2727273, 0.8786765, 0.2653563, 0.9669118, 0.3267813, 0.9705882, 0.3783784, 0.8676471, 0.2997543, 0.8125, 0.3366093, 0.7794118, 0.3046683, 0.6911765, 0.3095823, 0.6397059, 0.4078624, 0.8051471,   _
					 0.4594595, 0.8345588, 0.4717445, 0.8492647, 0.4447174, 0.9044118, 0.8992629, 0.1544118, 0.6855037, 0.7316176, 0.5503685, 0.7830882, 0.5773956, 0.8786765, 0.5651106, 0.9742647, 0.6486486, 0.9779412, 0.7297297, 0.9191176 _
					 , 0.6977887, 0.8492647, 0.7223587, 0.7757353, 0.7223587, 0.6507353, 0.7248157, 0.625, 0.7002457, 0.5808824, 0.7493858, 0.5772059, 0.8058968, 0.6360294, 0.8574939, 0.7316176, 0.8280098, 0.7720588, 0.9017199, 0.7279412,  _
					 0.972973, 0.6286765, 0.9680589, 0.5551471, 0.9361179, 0.9044118, 0.992629, 0.9742647, 0.8968059, 0.8676471, 0.8378378, 0.9007353))
					
					DrawStar(BG, X, Y, Width, Height, 7.862408E-02, 3.860294E-02, 8.599509E-03, "02047", 74, 119, 129, Align, 32)
					DrawStar(BG, X, Y, Width, Height, 0.2137592, 0.1525735, 1.105651E-02, "365878", 15, 107, 62, Align, 64)
					DrawStar(BG, X, Y, Width, Height, 0.1326781, 0.2297794, 7.371007E-03, "0087", 19, 80, 124, Align, 96)
					DrawStar(BG, X, Y, Width, Height, 0.2837838, 0.3106618, 1.105651E-02, "102", 46, 87, 96, Align, 128)
					DrawStar(BG, X, Y, Width, Height, 0.3894349, 0.1599265, 7.371007E-03, "08912", 35, 85, 118, Align, 32)
					DrawStar(BG, X, Y, Width, Height, 0.576167, 6.433824E-02, 7.371007E-03, "001", 24, 63, 76, Align, 64)
					DrawStar(BG, X, Y, Width, Height, 0.8734643, 0.3529412, 7.371007E-03, "653", 39, 68, 83, Align, 96)
					DrawStar(BG, X, Y, Width, Height, 0.8771499, 0.5541176, 9.82801E-03, "20029", 109, 162, 165, Align, 128)
					DrawStar(BG, X, Y, Width, Height, 0.9422604, 0.7628676, 7.371007E-03, "0389", 45, 84, 105, Align, 32)
					DrawStar(BG, X, Y, Width, Height, 0.7506142, 0.7095588, 7.371007E-03, "092", 18, 40, 68, Align, 64)
					DrawStar(BG, X, Y, Width, Height, 0.6191646, 0.7977941, 9.82801E-03, "87663", 27, 121, 158, Align, 96)
					DrawStar(BG, X, Y, Width, Height, 0.2014742, 0.8180147, 8.599509E-03, "65777", 54, 91, 103, Align, 128)
					DrawStar(BG, X, Y, Width, Height, 0.1400491, 0.6911765, 1.351351E-02, "342", 13, 64, 34, Align, 160)
					DrawStar(BG, X, Y, Width, Height, 6.879607E-02, 0.6066176, 7.371007E-03, "78965", 98, 164, 172, Align, 192)

					BG.DrawText("0204", temp3 + temp, temp2 + temp, StarshipFont, ElementID, Colors.rgb(53,136,95), "LEFT")
					temp7 = TextAlign * 0.5
					temp2 = temp2 - temp * 0.5 
					temp3 = temp3 - temp * 0.5
					
					API.SeedRND
					temp9 = API.GetTextHeight(BG, temp6 * -0.80 + temp, "00 0000", StarshipFont)
					temp0 = BG.MeasureStringHeight("0", StarshipFont, temp9)
					Text = API.PadtoLength(Round(DateTime.GetSecond(DateTime.Now)/60*100), True, 2, "0") & " " & API.PadtoLength(API.GetMS, True, 4, "0")
					BG.DrawText(Text, temp3 - TextAlign, temp2 + temp + TextAlign*2 + temp0, StarshipFont, temp9, Colors.rgb(16,66,27), "RIGHT")
					Text = API.PadtoLength(Rnd(1,100), True, 2, "0") & " " & API.PadtoLength(Rnd(1,10000), True, 4, "0")
					BG.DrawText(Text, temp3 - TextAlign, temp2 + temp + TextAlign*2 + temp0*2 + 1, StarshipFont, temp9, Color, "RIGHT")
					Text = Rnd(1,10) & "   " & API.PadtoLength(Rnd(1,1000), True, 3, "0")
					BG.DrawText(Text, temp3 - TextAlign, temp2 + temp + TextAlign*2 + temp0*3 + 2, StarshipFont, temp9, Color, "RIGHT")				
					
					'OUTER
					LCARSeffects4.DrawRect(BG, temp3, temp2, temp, temp, temp4, 0)'MIDDLE
					LCARSeffects4.DrawRect(BG, X-TextAlign, temp2, TextAlign, temp, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, X+Width, temp2, TextAlign, temp, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, temp3, Y-TextAlign, temp, TextAlign, Colors.black, 0)
					LCARSeffects4.DrawRect(BG, temp3, Y+Height, temp, TextAlign, Colors.black, 0)
					
					'LEFT
					LCARSeffects4.DrawRect(BG, X, temp2, TextAlign, temp, temp4, 0)'|
					LCARSeffects4.DrawRect(BG, X+TextAlign+temp7, temp2, TextAlign, temp, temp4, 0)'|
					BG.DrawText("70891", X+temp+temp7, temp2-temp7, StarshipFont, ElementID, temp5, "LEFT")
					LCARSeffects4.DrawRect(BG, X+temp+temp7, temp2, temp8, temp, Color, 0)'------ on left
					LCARSeffects4.DrawRect(BG, X+temp+temp8+TextAlign, temp2, temp6 - temp*2+TextAlign, temp, temp4, 0)'----- on right
					LCARSeffects4.DrawRect(BG, temp3 - temp, temp2, TextAlign, temp, temp4, 0)'|
					
					'RIGHT
					temp9=X+Width
					LCARSeffects4.DrawRect(BG, temp9-TextAlign, temp2, TextAlign, temp, temp4, 0)'|
					LCARSeffects4.DrawRect(BG, temp9-TextAlign*2-temp7, temp2, TextAlign, temp, temp4, 0)'|
					BG.DrawText("280", temp9-temp-temp7, temp2-temp7, StarshipFont, ElementID, temp5, "RIGHT")
					LCARSeffects4.DrawRect(BG, temp9-temp8-temp-temp7, temp2, temp8, temp, Color, 0)'------ on right 
					LCARSeffects4.DrawRect(BG, temp3 + temp *2 + temp7, temp2, temp6 - temp*2+TextAlign, temp, temp4, 0)'------- on left
					LCARSeffects4.DrawRect(BG, temp3 + temp *2 - TextAlign, temp2, TextAlign, temp, temp4, 0)'|
					
					'Top
					temp8 = Height * 0.5 - temp6 - temp + temp7 
					temp0 = temp6 - temp + temp7
					LCARSeffects4.DrawRect(BG,temp3, Y, temp, TextAlign, temp5, 0)'-
					LCARSeffects4.DrawRect(BG,temp3, Y + TextAlign*2, temp, temp8, Color, 0)'| on top
					LCARSeffects4.DrawRect(BG, temp3, temp2 - temp0 - TextAlign, temp, temp0, temp4, 0)'| on bottom
					BG.DrawText("87863", temp3-temp7, Y + TextAlign*2 + BG.MeasureStringHeight("87863", StarshipFont, ElementID), StarshipFont, ElementID, temp4, "RIGHT")
					
					'Bottom
					temp9 = Y + Height
					BG.DrawText("029", temp3-temp7, temp9 - TextAlign*2, StarshipFont, ElementID, Color, "RIGHT")
					LCARSeffects4.DrawRect(BG,temp3, temp9-TextAlign, temp, TextAlign, temp5, 0)
					LCARSeffects4.DrawRect(BG,temp3, temp9 - temp8- TextAlign*2, temp, temp8, Color, 0)
					LCARSeffects4.DrawRect(BG, temp3, temp2 + temp + TextAlign, temp, temp0, temp4, 0)
				
				Case 18
					Width=Width+1
					'SRC: 0,1600 218x120 (Width=Height*1.816666666666667,Height=Widtth*0.5504587155963303), DEST: 0.28288, 0.34536, 0.30273, 0.39175
					temp0 = X + Width * 0.28288'X
					temp = Y + Height * 0.34536'Y
					temp2 = Height * 0.39175'Height 
					temp3 = temp2 * 1.816666666666667'Width 
					LCARSeffects4.DrawRect(BG, temp0,temp, temp3,temp2, LCAR.GetColor(ColorID, False, Alpha512(Align, 0)), 0)'COLOR
					BG.DrawBitmap(CenterPlatform, LCARSeffects4.SetRect(0, 1600, 218, 120), LCARSeffects4.SetRect(temp0,temp,temp3,temp2))
					'LCAR.DrawLCARPicture(BG, temp0,temp,temp3,temp2,  -1, 0, Alpha,  False, 0, 1600, 218, 120)'BOP
					DrawStars(BG, X, Y,Width, Height, 2, Color, Array As Float(0.1915423, 0.7835051, 0.2512438, 0.8453608, 0.2835821, 0.8969072, 0.2761194, 0.6804124, 0.2089552, 0.6804124, 0.1840796, 0.5979381,  _ 
					0.1940299, 0.4896907, 0.2562189, 0.4381443, 0.2711443, 0.4175258, 0.2711443, 0.5, 0.2711443, 0.5773196, 0.4253731, 0.5670103, 0.4975124, 0.6649485, 0.460199, 0.8505155, 0.5995025, 0.9329897,  _ 
					0.641791, 0.8556701, 0.6915423, 0.8659794, 0.6840796, 0.3814433, 0.5845771, 0.1546392, 0.5771144, 0.1391753, 0.6343284, 8.762886E-02, 0.4701492, 8.762886E-02, 0.4228856, 0.1185567, 0.3606965, _ 
					0.2731959, 0.2910448, 0.2835051, 0.6119403, 0.6340206, 0.2039801, 0.4175258))
					
					Alpha = 5'Stroke
					temp0 = Y+Height * 0.8453608
					temp = Y + Height * 0.7164949
					BG.DrawLine(X, temp0, X+Width, temp, Color, Alpha)'____
					temp2 = X + Width * 0.2910448'X of line 2
					temp3 = X + Width * 0.3681592'X2 of line 2
					temp4 = Y + Height * 0.8195876'Y2 of line 2
					temp9=Y+Height
					
					tempP = Trig.LineLineIntercept(X, temp0, X+Width, temp,  temp2, temp9, temp3, temp4)
					BG.DrawLine(temp2, temp9, tempP.x,tempP.Y, Color, Alpha)
					BG.DrawLine(X + Width * 0.3208955, Y, tempP.x,tempP.Y, Color, Alpha)

					temp2 = X + Width * 0.7189054'X1
					temp3 = Y + Height * 0.9948454'Y1
					temp4 = X + Width * 0.7388059'X2
					temp5 = Y + Height * 0.7628866'Y2
					tempP = Trig.LineLineIntercept(X, temp0, X+Width, temp,    temp2, temp3, temp4, temp5)
					BG.DrawLine(temp2, temp3, tempP.x,tempP.Y, Color, Alpha)
					BG.DrawLine(X + Width * 0.7089552, Y, tempP.x,tempP.Y, Color, Alpha)
					
					temp2 = X + Width * 0.1393035'BX
					temp3 = Y + Height * 0.3453608'BY
					temp4 = X + Width * 0.6343284'CX
					temp5 = Y + Height * 0.2886598'CY
					temp6 = X + Width * 0.2761194'FX
					temp0 = Y + Height * 0.2319588'FY
					temp7 = X + Width * 0.6691542'GX
					temp8 = Y + Height * 0.185567'GY
					
					BG.DrawLine(temp2,temp3, 						temp6,temp0,								Color, Alpha)'B-F
					BG.DrawLine(temp4,temp5, 						X+Width*0.6691542,Y+Height*0.185567, 		Color, Alpha)'C-G
					'A(0.1940299, Y+Height)-B(0.1393035, 0.3453608)-C(0.6343284, 0.2886598)-D(0.6691542, temp9)
					BG.DrawLine(X + Width * 0.1940299, temp9, 		temp2,temp3, 								Color, Alpha)'A-B
					BG.DrawLine(temp2,temp3, 						temp4,temp5, 								Color, Alpha)'B-C
					BG.DrawLine(temp4,temp5, 						X+Width*0.6691542,temp9, 					Color, Alpha)'C-D
					'E(0.2587065, Y)-F(0.2761194, 0.2319588)-G(0.6691542, 0.185567)-H(0.6616915, Y)
					BG.DrawLine(X + Width * 0.2587065,Y,			temp6,temp0,								Color, Alpha)'E-F
					BG.DrawLine(temp6,temp0,						temp7,temp8,								Color, Alpha)'F-G
					BG.DrawLine(temp7,temp8,						X + Width * 0.6616915, Y,					Color, Alpha)'G-H

				Case 19'18's text
					'ALIGN = 0-255 (fade in), 256-512 (fade out), >512 (invisible)
					temp0 = X + Width * 0.5
					temp = Y + Height * 0.5
					temp2 = LCAR.getColor(LCAR.LCAR_Red, False, 255)
					temp3 = BG.MeasureStringHeight("123", StarshipFont, LCAR.Fontsize)
					temp4 = 2'whitespace
					tempF = 0.03125'1/32
					If Align < 512 Then 
						temp5 = BG.MeasureStringWidth(Text, StarshipFont, LCAR.Fontsize)
						temp6 = temp0 - temp5 * 0.5 
						Text = GetWords(Text, Align * tempF)'4 MINUTES TO INTERCEPT.
						BG.DrawText(Text, temp6, temp-temp4, StarshipFont, LCAR.Fontsize, temp2, "LEFT")
					Else 
						temp5 = Max(BG.MeasureStringWidth(SideText, StarshipFont, LCAR.Fontsize), BG.MeasureStringWidth(Tag, StarshipFont, LCAR.Fontsize))
						temp6 = temp0 - temp5 * 0.5
						SideText = GetWords(SideText, (Align-512) * tempF)'CLOAKING DEVICE ENGAGED.
						BG.DrawText(SideText, temp6,temp-temp4, StarshipFont, LCAR.Fontsize, temp2, "LEFT")
						If Align > 1024 Then 
							Tag = GetWords(Tag, (Align-1024) * tempF)'POSITION UNKNOWN.
							BG.DrawText(Tag, temp6,temp+temp3+temp4, StarshipFont, LCAR.Fontsize, temp2, "LEFT")
						End If 
					End If 
				
				Case 20'ENT-A sensors
					LCAR.ActivateAA(BG,True)
					temp0 = Width * 0.30'Width
					temp = X + temp0* 0.5'CenterX
					temp2 = Y + Height * 0.5'CenterY
					tempF=1.31063829787234'1.52537579997023'Height = Width * tepF			 '0.6555761537711'Width = Height * tempF
					Y=Y+Align
					Width = Width - Align 
					Height = Height - Align * 2					
					
					Align=Align*0.5
					temp3 = Height * 0.17
					BG.drawline(temp, temp2, X+Width, temp2-temp3, Color, Align)
					BG.drawline(temp, temp2, X+Width, temp2+temp3, Color, Align)
					
					temp4 = X + Width'RIGHT
					temp5 = Y + Height'BOTTOM
					P.Initialize(temp, temp2)
					P.LineTo(temp4, temp2-temp3)
					P.LineTo(temp4, Y)
					P.LineTo(X,Y)
					P.LineTo(X,temp5)
					P.LineTo(temp4, temp5)
					P.LineTo(temp4, temp2+temp3)
					BG.ClipPath(P)
					DrawENToval(BG, temp, temp2, temp0, 0.7329843, tempF, Color, Align ,0,0,0)'A1
					DrawENToval(BG, temp, temp2, temp0, 1.0000000, tempF, Color, Align ,0,0,0)'A2
					DrawENToval(BG, temp, temp2, temp0, 1.2722510, tempF, Color, Align, 0,0,0)'A3
					BG.RemoveClip
					
					'GRADIENT
					temp4 = Trig.GetCorrectAngle(0, 0, Width, temp3)
					temp5 = temp0 * 0.5916230'Starting oval
					tempP = Trig.findOvalXY2(0, 0, temp5, temp5 * tempF, temp4)'B6 intersect
					tempP.Y = tempP.Y - Align * 2
					temp4 = Width - tempP.X - temp0 * 0.5'Width
					LwpID = tempP.Y*2
					DrawGradient(BG, temp+tempP.X, temp2 - tempP.Y, temp4, LwpID, LCAR.getcolor(ColorID, False, 64), Color, temp4*0.20, TextAlign * 0.005)'/200
					
					'LINES
					temp4 = Trig.GetCorrectAngle(0, 0, Width, Height * 0.23)
					temp5 = temp0 * 2.4136130'Radius X B6
					tempP = Trig.findOvalXY2(0, 0, temp5, temp5 * tempF, temp4)'B6 intersect
					temp6 = temp + tempP.X'X B6
					temp7 = temp2 + tempP.Y'Y B6
					BG.drawline(temp, temp2,      temp6, temp2 - tempP.Y, Color, Align*2)'Top line
					
					P.Initialize(temp, temp2)
					P.LineTo(temp6, temp2 - tempP.Y)
					P.LineTo(X+Width, temp2 - tempP.Y)
					P.LineTo(X+Width, Y)
					P.LineTo(X,Y)
					P.LineTo(X,Y+Height)
					P.LineTo(X+Width,Y+Height)
					P.LineTo(X+Width, temp2 + tempP.Y)
					P.LineTo(temp6, temp2 + tempP.Y)
					BG.ClipPath(P)
					DrawENToval(BG, temp, temp2, temp0, 2.4136130, tempF, Color, Align*2, 0,0,0)'B6 <--
					BG.RemoveClip
					
					BG.DrawRectRotated( LCARSeffects4.SetRect(temp6-Align, temp2 - tempP.Y-Align, Align*2, Align*2), Color, True, 0, 360-temp4)'Top right corner
					BG.DrawRectRotated( LCARSeffects4.SetRect(temp6-Align, temp2 + tempP.Y-Align, Align*2, Align*2), Color, True, 0, temp4 + 90)'Bottom right corner
					
					temp5 = temp0 * 1.8795810'Radius X B5
					tempP = Trig.findOvalXY2(0, 0, temp5, temp5 * tempF, temp4)'B5 intersect
					BG.drawline(temp6, temp7,    temp + tempP.X, temp2 + tempP.Y, Color, Align * 2)'Bottom last line
					
					temp5 = temp0 * 1.4031410'Radius X B4
					tempP = Trig.findOvalXY2(0, 0, temp5, temp5 * tempF, temp4)'B4 intersect
					BG.drawline(temp, temp2,    temp + tempP.X, temp2 + tempP.Y, Color, Align * 2)'Bottom First line
					'END LINES
					
					DrawRandomStars(BG, X,Y,Width,Height, Color, 20, 54397)
					
					LCARSeffects.MakeClipPath(BG, X, Y, Width, Height)'Stroke
					LwpID=LwpID*0.5
					temp3 = API.GetTextHeight(BG, Align * 2, "0", StarshipFont)'fontsize
					DrawENToval(BG, temp, temp2, temp0, 0.5916230, tempF, Colors.black, 0,0,0,0)'B1
					DrawENToval(BG, temp, temp2, temp0, 0.5916230, tempF, Color, Align, 0,0,0)'B1
					DrawENToval(BG, temp, temp2, temp0, 0.8638743, tempF, Color, Align, 0,0,0)'B2
					DrawENToval(BG, temp, temp2, temp0, 1.1361260, tempF, Color, Align, LwpID, 50, temp3)'B3 [#]
					DrawENToval(BG, temp, temp2, temp0, 1.4031410, tempF, Color, Align, LwpID, 100, temp3)'B4 [#] <--
					DrawENToval(BG, temp, temp2, temp0, 1.8795810, tempF, Color, Align, LwpID, 200, temp3)'B5 [#]
					DrawENToval(BG, temp, temp2, temp0, 2.4136130, tempF, Color, Align, LwpID, 300, temp3)'B6 [#] <--
					DrawENToval(BG, temp, temp2, temp0, 2.9476450, tempF, Color, Align, 0,0,0)'B7 (should be right at the edge)
					BG.RemoveClip
					
					'0,1720 - 218(Height*4.192307692307692)*52(Width*0.2385321100917431)
					temp3 = temp0 * 0.2385321100917431'Half-Height
					Align=Align*2
					LCARSeffects4.DrawRect(BG, X - Align-1, Y + Height * 0.5 - temp3, Align+2, temp3*2, Colors.black, 0)'overdraw
					LCARSeffects4.DrawRect(BG, X, temp2 - temp3+1, temp0, temp3*2-1, Color, 0)
					BG.DrawBitmap(CenterPlatform, LCARSeffects4.SetRect(0, 1720, 218, 52), LCARSeffects4.SetRect(X,temp2,temp0,temp3))
					BG.DrawBitmapFlipped(CenterPlatform, LCARSeffects4.SetRect(0, 1720, 218, 52), LCARSeffects4.SetRect(X,temp2-temp3+1,temp0,temp3), True, False)
					LCAR.ActivateAA(BG,False)
				
				Case 21'bit overdraws
					'align=height of enterprise, textalign=stroke
					temp2 = Y + Height * 0.5 - Align'Y
					Align=Align*2
					LCARSeffects4.drawrect(BG, X + Width, temp2, TextAlign+1, Align, Colors.black, 0)
					LCARSeffects4.drawrect(BG, X + Width-TextAlign, temp2, TextAlign, Align, Color, 0)
					temp = Width * 0.46
					LCARSeffects4.drawrect(BG, X + Width-TextAlign*1.5-temp, temp2, temp, TextAlign, Color, 0)
				
				Case 23'map (textalign=stroke)
					Wireframe.DrawSVG2(BG, X, Y, Width, Height, "tmp", 2, 0, ColorID, False, 255, TextAlign*0.5, 0, 112)
					Wireframe.DrawSVG2(BG, X, Y, Width, Height, "tmp", 3, 0, ColorID, False, 255, TextAlign, 0, 112)
					DrawRandomStars(BG, X, Y, Width, Height, Color, 30, 45345)
				
				Case 24'ENT-B thingie 48	
					'textalign = stroke 
					DrawPreCARSFrame(BG, X,Y,Width, Height, ColorID, Alpha, 5, 0, TextAlign, "", 0, "")
					temp  = Width * 0.5247747747747748' start of whitespace
					temp2 = Width * 0.0135135135135135'Whitespace 
					temp3 = Width * 0.045045045045045'bar thickness
					
					temp4 = TextAlign * 2
					temp5 = TextAlign * 1.5
					temp6 = temp5*0.25
					tempF = LCAR.getcolor(API.iif(ColorID = LCAR.Classic_Green, LCAR.Classic_Blue, LCAR.Classic_Green), False, 255)'opposite color
					DrawHollowRect(BG, X + temp4, Y + temp4, temp5, temp5, tempF, temp6)
					DrawHollowRect(BG, X + temp4, Y + temp4+temp5+2, temp5, temp5, tempF, temp6)
					DrawHollowRect(BG, X + temp4+temp5+2, Y + TextAlign * 2, temp5, temp5, tempF, temp6)
					
					LCARSeffects4.DrawRect(BG, X + temp-temp3, Y, temp3, Height, Color, 0)
					LCARSeffects4.DrawRect(BG, X + temp, Y, temp2, Height+1, Colors.Black, 0)
					LCARSeffects4.DrawRect(BG, X + temp + temp2, Y, temp3, Height, Color, 0)
					
					temp4 = X + temp + temp2*0.5'Center X
					temp5 = Y + Height * 0.5'Center Y
					temp6 = temp * 0.6025641025641026'Radius X
					temp7 = temp6 * 1.3'Radius Y
					
					'Outer slice
					'Color = Colors.RGB(37, 164, 241)
					temp8 = temp6 * 0.0727272727272727'thickness of outer layer/svg 4
					'temp9=temp8*0.5
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 4, 0, -1, False, 255, -1, 0, 112)
					Wireframe.DrawOval(BG, temp4,    temp5,  temp6*2-temp8-1, temp7*2-temp8-1,  Color, temp8, True, 0)
					BG.RemoveClip
					
					temp6 = temp6 - temp8 
					temp7 = temp7 - temp8 
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 5, 0, -1, False, 255, -1, 0, 112)
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2-temp8, temp7*2-temp8,  Color, temp8, True, 0)
					BG.RemoveClip
					
					temp6 = temp6 - temp8
					temp7 = temp7 - temp8
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2 + 2, temp7*2 + 2,  Color, 0, True, 0)
					
					temp8 = temp8 * 3
					temp6 = temp6 - temp8
					temp7 = temp7 - temp8
					Color = tempF 
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2, temp7*2,  Color, 0, True, 0)

					temp8 = temp7 * 0.3706896551724138
					temp9 = Colors.rgb(15,118,110)
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 6, 0, -1, False, 255, -1, 0, 112)
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2-temp8, temp7*2-temp8,  temp9, temp8, True, 0)
					BG.RemoveClip
					
					LCARSeffects6.clipoval(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2)
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 10, 0, 0, False, 255, 2, 0, 112)
					BG.RemoveClip
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 9, 0, 0, False, 255, 2, 0, 112)
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2, temp7*2,  Colors.black, 2, True, 0)
					
					temp6 = temp6 - temp8
					temp7 = temp7 - temp8
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2, temp7*2,  Color, 0, True, 0)
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 7, 0, -1, False, 255, -1, 0, 112)
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2, temp7*2,  temp9, 0, True, 0)
					BG.RemoveClip
					
					Wireframe.DrawSVG2(BG, temp4-temp6,   temp5-temp7, temp6*2, temp7*2, "tmp", 8, 0, -1, False, 255, -1, 0, 112)
					Wireframe.DrawOval(BG, temp4, temp5,  temp6*2-1, temp7*2-1,  Colors.Black, 2, True, 0)
					BG.RemoveClip
					
					temp = temp + temp2* 0.5 
					BG.DrawLine(X + temp, Y, X + temp, Y + Height, Colors.black, 2)
					BG.drawline(X + TextAlign, temp5, X + Width - TextAlign, temp5, Colors.black, 2)
					BG.drawline(X + TextAlign, temp5, temp4, temp5, Colors.Black, Height * 0.0158311345646438)
					
					temp6 = Width * 0.3162104412104412'0.5247747747747748 * 0.6025641025641026'Radius X
					temp7 = temp6 * 1.3'Radius Y
					temp8 = LCAR.Fontsize * 0.5
					temp9 = BG.MeasureStringHeight("0", StarshipFont, temp8)
					TextAlign = TextAlign * 0.5
					API.SeedRND
					BG.DrawText(Rnd(100,1000), temp4 - temp6 - TextAlign, temp5 + temp9 * 0.5, StarshipFont, temp8, tempF, "RIGHT")
					BG.DrawText(Rnd(100,1000), temp4 + temp6 + TextAlign, temp5 + temp9 * 0.5, StarshipFont, temp8, tempF, "LEFT")
					BG.DrawText(Rnd(100,1000), temp4 + TextAlign, temp5 - temp7 + TextAlign*7, StarshipFont, temp8, Colors.Black, "LEFT")
					TextAlign = TextAlign * 2
					temp7 = X + Width - TextAlign *2
					BG.DrawText(Rnd(10000,100000), temp7, Y + TextAlign*2 + temp9, StarshipFont, temp8, tempF, "RIGHT")
					BG.DrawText(Rnd(100,1000), temp7, Y + TextAlign*2 + temp9*2 + 1, StarshipFont, temp8, tempF, "RIGHT")
					API.SeedRND2
					
					temp2 = Height * 0.5'Height of Excelsior
					temp3 = temp2 * 0.2007168458781362'HalfWidth of Excelsior
					'218,0 112*558 (image) temp4 = Center X, temp5 = Center Y
					temp = temp5-temp2*0.5'top
					BG.DrawBitmap(CenterPlatform, LCARSeffects4.SetRect(218,0,112,558), LCARSeffects4.SetRect(temp4-temp3+1, temp,temp3,temp2))
					BG.DrawBitmapFlipped(CenterPlatform, LCARSeffects4.SetRect(218,0,112,558), LCARSeffects4.SetRect(temp4, temp,temp3,temp2), False, True)
					
					'Align = height of button, multiply by 3 and add textalign for width 
					
					temp = Align * 3 + TextAlign 
					y = y + Height - TextAlign*2 - Align
					DrawLegacyButton(BG, x + TextAlign*2, Y, temp,Align, tempF, Text, 9, temp8)
					DrawLegacyButton(BG, x + Width - TextAlign*2 - temp, Y, temp,Align, tempF, Text, 9, temp8)
				
				Case Else: DidDraw = False
			End Select
		Case 49'ENT-B helm (doesn't use centerplatform)
			Select Case ElementID
				Case 0'Blinker
					temp = BG.MeasureStringHeight(Text, StarshipFont, TextAlign)
					temp2 = LCAR.GetColor(LCAR.Classic_Blue, False,255)
					X = X + Width * 0.5
					BG.DrawText(Text, X, Y + Height, StarshipFont, TextAlign, temp2, "CENTER")
					Height = Height - temp * 2
					temp3 = Min(Width,Height) * 0.5 
					BG.DrawCircle(X, Y + temp3, temp3, Color, True, 0)
				Case 1,2'Gradient thingie
					LCARSeffects4.DrawRect(BG, X,Y, Height, Height, Color, 0)
					'align = %/50, textalign=ID(0 or 1)
					
					LCARSeffects.MakeClipPath(BG,X,Y,Height, Height)
					
					temp4 = Height* 0.5
					temp = X + temp4
					temp2 = Y + temp4
					temp5 = Colors.ARGB(32, 0,0,0)

					temp3 = Height * Align * 0.01
					temp4 = temp4*0.5
					temp3 = temp3-temp4
					For temp6 = 1 To 4
						DrawHalo(BG, temp, temp2, temp3, temp5, 4, 5)
						temp3 = temp3+temp4
					Next
					
					temp = Height * 0.20
					temp2 = temp * 0.5
					LCARSeffects4.drawgrid(BG, X - temp2, y - temp2, Height+temp, Height+temp, temp , temp , Colors.Black, -1)
					BG.RemoveClip
					
					temp3 = Width - Height - 2'size of a block
					temp5 = x + Height + 2
					temp7 = temp3 * 0.25
					If ElementID = 1 Then
						temp4 = Height* 0.5
						BG.DrawCircle(X + temp4, Y + temp4, Height * 0.2, Colors.black, True, 0)
						Color = LCAR.getcolor(LCAR.Classic_LightBlue, False, 255)
					End If
					temp4 = Y + Height
					For temp6 = 1 To 4
						If temp6 = 3 Then
							If ElementID = 1 Then Color = LCAR.Classic_Green Else Color = LCAR.Classic_LightBlue
							Color = LCAR.getcolor(Color, False, 255)
						End If
						temp4 = temp4 - temp3 - 1
						DrawHollowRect(BG,temp5, temp4, temp3,temp3, Color, temp7)
					Next
				Case Else: DidDraw = False
			End Select
		Case 47'ENT-B Bridge other
			LCARSeffects.MakeClipPath(BG,x,y,Width,Height)
			Select Case ElementID
				Case 0'CRONOS TL
					temp = Width * 0.004
					DrawStars(BG, X, Y, Width, Height, temp, Colors.white, Array As Float(2.466793E-02, 0.3417721, 1.897533E-02, 0.6329114, 3.036053E-02, 0.649789, 0.1100569, 0.7299578, 0.2732448, 0.9219409, 0.3092979, 0.613924, 0.2466793, _
					 	0.4409283, 0.2182163, 0.185654, 0.231499, 0.1476793, 0.2466793, 8.438819E-02, 0.4705882, 0.1118143, 0.5332068, 0.2869198, 0.7267552, 0.2383966, 0.5370019, 0.6054853, 0.6907021, 0.6540084, 0.6242884, 0.9388186, 0.9070209, _
					  	0.8987342, 0.943074, 0.8227848, 0.9943074, 0.5063291, 0.9013283, 1.054852E-02))
					
					temp = X + Width * 0.5'Center X
					temp6 = Height * 0.5'Distance
					temp2 = Y + temp6'Center Y
					temp3 = Width * 0.65'Starting radius X
					temp4 = 0.672 * temp6 * 0.04'Distance increment
					temp5 = temp3 * 0.04'Width increment
					
					temp7 = Trig.findxyangle(0, 0, temp4, 325, True)
					temp8 = Trig.findxyangle(0, 0, temp4, 325, False)
					temp9 = Width * 0.006
					For temp0 = 0 To 24 		
						Wireframe.DrawShape(BG, temp, temp2, temp3, temp3 * 0.55, temp9, CronosColor(temp0, TextAlign), 325, 4)
						temp3 = temp3 - temp5
						temp  = temp + temp7 
						temp2 = temp2 + temp8
						If temp0 Mod 2 = 0 Then 
							temp7 = temp7 - 1
							temp8 = temp8 - 1
						End If 
					Next 
					
					BG.drawtext(263272, X+Width* 0.6034155, Y + Height * 0.7552742, StarshipFont, LCAR.Fontsize * 0.5, Colors.white, "LEFT")
					temp = Min(Width,Height)'*0.5
					Wireframe.DrawShape(BG, X + Width, Y + Height, temp, temp * 0.55, 8, Colors.white, 55, 4)
					
				Case 1'CRONOS TR
					'LCARSeffects4.drawrect(BG,X,Y,Width,Height,Colors.black,0)
					temp = LCAR.Fontsize * 0.5
					temp2 = BG.MeasureStringHeight("PRO", StarshipFont, temp) + 1
					temp3 = Width / 8
					temp4 = API.GetMS
					BG.DrawText("PROJECTED", x + temp3, Y + temp2*2, StarshipFont, temp, Colors.White, "LEFT")
					BG.DrawText("TRAJECTORY", x + temp3, Y + temp2*3, StarshipFont, temp, Colors.White, "LEFT")
					
					BG.DrawText( API.PadtoLength(temp4, True, 4, "0"), x + temp3, Y + temp2*4 + 4, StarshipFont, temp, Colors.White, "LEFT")
					BG.DrawText( API.PadtoLength((temp4 + 243) Mod 1000, True, 4, "0"), x + Width - temp3, Y + temp2*4 + 4, StarshipFont, temp, Colors.White, "RIGHT")
					
					BG.DrawText( API.PadtoLength(Abs((temp4 - 646) Mod 1000), True, 4, "0"), x + temp3, Y + temp2*5 + 4, StarshipFont, temp, Colors.White, "LEFT")
					BG.DrawText( API.PadtoLength((temp4 + 697) Mod 1000, True, 4, "0"), x + Width - temp3, Y + temp2*5 + 4, StarshipFont, temp, Colors.White, "RIGHT")
					
					BG.DrawText( API.PadtoLength((temp4 + 355) Mod 1000, True, 4, "0"), x + temp3, Y + temp2*6 + 4, StarshipFont, temp, Colors.White, "LEFT")
					BG.DrawText( API.PadtoLength(Abs((temp4 - 869) Mod 1000), True, 4, "0"), x + Width - temp3, Y + temp2*6 + 4, StarshipFont, temp, Colors.White, "RIGHT")
					
					'255 of 462 = 55%
					temp4 = Height * 0.06875 ' 0.55 * 0.125 height of 1 of 8 units
					
					X = X + temp3
					temp6 = (temp2 - 1) * 0.5 
					temp2 = temp4 * 8
					Y = Y + Height - temp2 - temp4
					Width = temp3 * 6
					Height = temp2
					temp5 = Colors.rgb(110, 191, 255)
					temp = temp * 0.5 
					
					DrawGridWithLines(BG, X, Y, Width, Height, temp3, temp4, Colors.rgb(50, 64, 198), temp5, 1, temp, StarshipFont, 2, 2, 10, "%", 1, 0.1, "", Colors.white, "ORBITAL GRAVITATION", Colors.rgb(255,255,128))
					temp4 = temp4*0.1875
					LCARSeffects4.DrawCurve(BG, x + Width *  0.1338028, Y + Height, X + Width * 0.2, Y + Height * 0.2, X + Width, Y + Height * 8.267716E-02, 10, Colors.White, temp4)'6/32=0.1875of cellheight
					BG.DrawCircle( X + Width * 0.1690141, Y + Height * 0.6850393, temp4, Colors.white, True, 0)
					BG.DrawText("STD", X + Width * 0.2957746, Y + Height * 0.8307087, StarshipFont, temp, Colors.white, "LEFT")
					
				Case 2'CRONOS BOTTOM
					Text = "BEARING:  323"
					temp4 = LCAR.Fontsize * 0.25
					temp7 = API.GetTextLimitedHeight(BG, Height * 0.125, Width * 0.29 - BG.MeasureStringWidth("CURRENT", StarshipFont, temp4), Text, StarshipFont)'40 - 10% of 40 (6) - 5
					temp = Height * 0.25'BG.MeasureStringHeight("PRO", StarshipFont, temp7)
					temp2 = X + Width * 0.05
					temp3 = temp2 + BG.MeasureStringWidth(Text, StarshipFont, temp7)
					
					temp5 = Colors.rgb(110, 191, 255)
					temp6 = BG.MeasureStringHeight("PRO", StarshipFont, LCAR.Fontsize) * 0.5
					BG.DrawText("ORIGIN", temp2, Y + temp, StarshipFont, temp7, temp5, "LEFT")
					BG.DrawText("BEARING:", temp2, Y + temp*2, StarshipFont, temp7, Colors.white, "LEFT")
					BG.DrawText("323", temp3, Y + temp*2, StarshipFont, temp7, Colors.white, "RIGHT")
					BG.DrawText("MARK:", temp2, Y + temp*3, StarshipFont, temp7, Colors.white, "LEFT")
					BG.DrawText("75", temp3, Y + temp*3, StarshipFont, temp7, Colors.white, "RIGHT")
					
					X = X + Width * 0.40
					Width = Width * 0.57
					Y = Y + temp6*2 + 1
					Height = Height - temp6* 4 
					DrawGridWithLines(BG, X, Y, Width, Height, Width * 0.1, Height * 0.25, Colors.Black, temp5, 2, temp4, StarshipFont, 2, 2,10,"%", 1,1,"", Colors.white, "CET% EXP GRV", Colors.white)
					temp = Height * 0.03'625'* 0.25 * 0.25
					
					DrawStars(BG, X, Y, Width, Height, temp, Colors.white, Array As Float(6.849315E-02, 0.6306306, 0.1940639, 0.4234234, 0.1461187, 0.1171171, 0.2237443, 0.7837838, 0.4018265, 0.8108108, 0.4109589, 0.7387387, 0.3630137, 0.1621622, _
						0.4634703, 0.4684685, 0.5684931, 0.7927928, 0.6278539, 0.6576577,0.5913242, 0.2072072, 0.7100456, 0.5045045, 0.7214612, 0.9099099, 0.9474886, 0.7657658, 0.9178082, 0.2342342))
					BG.DrawText(8468, X+ Width * 0.2260274,  0.5045045, StarshipFont, temp4, Colors.white, "LEFT")
					BG.DrawText(3234, X+ Width *0.6552511, 0.7747748, StarshipFont, temp4, Colors.white, "LEFT")
					
					X = X - Width * 0.1
					BG.DrawText("CURRENT", X, Y + temp6, StarshipFont, temp4, Colors.white, "RIGHT")
					BG.DrawText("STATUS", X, Y + temp6*2+1, StarshipFont, temp4, Colors.white, "RIGHT")
				
				Case 3'PRAXIS 2 TL
					LCARSeffects4.drawrect(BG,X,Y,Width,Height, Colors.rgb(2,11,108),0)
					temp3 = Align * 0.5'Starting Y
					temp2 = Width*0.25' temp3 * 4.54'Starting width
					temp4 = Align + 1'inc
					temp7 = Height * 2					
					tempF = Width / (temp7 / temp4)
					Dim tempF2 As Float = tempF + temp2
					For temp = temp3 To temp7 Step temp4
						If TextAlign < 19 Then Wireframe.DrawOval(BG, X, Y, tempF2 * 2, temp*2, CronosColor2(TextAlign), Align, True, 0)
						TextAlign=(TextAlign+1) Mod 20
						tempF2 = tempF2 + tempF
						tempF=tempF* 1.01
					Next
					DrawRandomStars(BG,X,Y,Width,Height, CronosColor2(9), 20, 672161)
				
				Case 4'PRAXIS 2 TR
					'0.11864, 0.47692, 0.76271, 0.42308
					temp = LCAR.fontsize*0.25
					temp2 = BG.MeasureStringWidth("0.8", StarshipFont, temp)
					
					X = X + Width * 0.11864 + temp2
					Y = Y + Height * 0.5
					Width = Width * 0.76271 - temp2
					Height = Height * 0.42308
					
					DrawGridWithLines(BG, X, Y, Width, Height, Width/7, Height/7, Colors.Black, Colors.rgb(110, 191, 255), 1, temp, StarshipFont, 2, 2, 10, "%", 1, 0.1, "", Colors.white, "", Colors.rgb(255,255,128))
					Wireframe.DrawSVG2(BG, X, Y, Width, Height, "tmp", 0, 0, LCAR.lcar_white, False, 128, 2, 0, 112)
					Wireframe.DrawSVG2(BG, X, Y, Width, Height, "tmp", 1, 0, LCAR.lcar_white, False, 255, 2, 0, 112)
					
				Case 5'PRAXIS 2 Bottom
					'X+ Width * 0.0087, temp5 + temp3*0.13208, Width * 0.195, temp3*0.62264		0.21304, 0.13208, 0.50435, 0.60377
					'DrawRandomGraph(BG, X + Width * 0.21304, Y + Height * 0.13208, Width * 0.50435, Height * 0.60377, 0, Color, 341746, 0, 8)
					BG.DrawText(Text, X + Width * 0.22, Y + Height * 0.13208 - 4, StarshipFont, LCAR.fontsize*0.5, Color, "LEFT")
					

					X = X + Width * 0.72609
					Width = Width * 0.23043
					temp = X+ Width * 0.5'center X
					
					'drawtext here
					
					Y = Y + Height * 0.17647
					Height = Height * 0.62264
					temp2 = Y + Height * 0.5
					temp3 = Width * 0.62
					temp4 = API.getMS
					If temp4 < 500 Then 
						tempF = API.getMS * 0.002
					Else 
						tempF = (1000 - API.getMS) * 0.002
					End If
					
					Wireframe.Drawoval(BG, temp, temp2, temp3, Height, Color, 2, True, 0)
					Wireframe.Drawoval(BG, temp, temp2, temp3, Height*tempF, Color, 2, True, 0)
					Wireframe.Drawoval(BG, temp, temp2, temp3 * tempF, Height, Color, 2, True, 0)
					
					tempF = LCAR.fontsize * 0.5 
					temp3 = BG.MeasureStringHeight("0", StarshipFont, tempF)
					
					BG.DrawText("PB", X+2, Y+temp3, StarshipFont, tempF, Color, "LEFT")
					BG.DrawText("PS", X+2, Y+Height, StarshipFont, tempF, Color, "LEFT")
					
					X = X + Width - 2
					BG.DrawText("SB", X, Y+temp3, StarshipFont, tempF, Color, "RIGHT")'right top
					BG.DrawText("SS", X, Y+Height, StarshipFont, tempF, Color, "RIGHT")'right bottom
					
					
				Case Else: DidDraw = False
			End Select
			BG.RemoveClip
		Case Else: DidDraw = False
	End Select
	If Not(DidDraw) Then LCAR.DrawUnknownElement(BG,X,Y,Width,Height,ColorID, State,Alpha, LwpID & "." & ElementID & " NOT DEFINED")
End Sub

Sub IncrementCustomElement(Element As LCARelement) As Boolean 
	Dim temp As Int 
	Select Case Element.LWidth
		Case 48 'ENT-B bridge
			Select Case Element.RWidth
				Case 2, 20'NX-2000
					Element.TextAlign = (Element.TextAlign + 5) Mod 200 
				Case 5, 9, 13, 15'charts, grid, sin waves
					Element.TextAlign = (Element.TextAlign + 5) Mod 360
				Case 6'gravimetric distortion
					Element.TextAlign = LCAR.Increment(Element.TextAlign, 16, Element.Align)
					If Element.TextAlign = Element.Align Then Element.Align = API.IIF(Element.Align = 0, 255,0)
				Case 7'bars
					If Element.Align = 1 Then 
						Element.TextAlign = Element.TextAlign - 16
						If Element.TextAlign <= 0 Then 
							Element.TextAlign = 0
							Element.Align = 0
						End If
					Else 
						Element.TextAlign = Element.TextAlign + 16
						If Element.TextAlign > 255 Then 
							Element.TextAlign = 255 
							Element.Align = 1
						End If
					End If
				Case 8'alert condition status
					Element.TextAlign = Element.TextAlign - 16
					If Element.TextAlign < 0 Then Element.TextAlign= 256
				Case 10'graphs
					temp = FindGraph(Element.Align)
					If temp > -1 Then AddPoint(temp, Rnd(10,100))
				Case 11'circles
					Element.TextAlign = LCAR.Increment(Element.TextAlign, 5, Element.Align)
					If Element.TextAlign = Element.Align Then Element.Align = Rnd(-22,22)
				Case 14'graph 
					Element.TextAlign = (Element.TextAlign + Rnd(1, 25)) Mod Rnd(75,100)
					Element.Align = (Element.Align + Rnd(1, 25)) Mod Rnd(75,100)
				Case 16'CRONOS 1
					If LCAR.FramesDrawn Mod 2 = 0 Then Element.TextAlign = (Element.TextAlign + 1) Mod 5
				Case 17'SECTOR SCAN, TACTICAL SCAN II
					Element.Align = (Element.Align + 16) Mod 512
				Case 18, 19'TACTICAL SCAN
					Element.Align = (Element.Align + 8) Mod 2048
				Case 22'CRONOS 2
					'If LCAR.FramesDrawn Mod 2 = 0 Then 'Element.TextAlign = (Element.TextAlign + 1) Mod 20
						Element.TextAlign = Element.TextAlign - 1 
						If Element.TextAlign = -1 Then Element.TextAlign = 19 
					'End If
				Case Else: Return False 
			End Select
		Case 49'ENT-B Helm 
			Select Case Element.RWidth
				Case 0'blinker 
					If Element.Opacity.Current = Element.Opacity.Desired Then 
						If Element.Opacity.Desired = 255 Then Element.Opacity.Desired = 128 Else Element.Opacity.Desired = 255
					End If
				Case 1'square thing
					Element.Align = (Element.Align + 2) Mod 50 
				Case 2
					Element.Align = Element.Align - 3
					If Element.Align < 0 Then Element.Align = 47
			End Select
		Case Else: Return False 
	End Select
	Return True
End Sub

Sub DrawHalo(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Stroke As Int, Slices As Int)
	Dim NewStroke As Int
	Do Until Slices < 1 
		NewStroke = NewStroke + Stroke
		BG.DrawCircle(X,Y, Radius, Color, False, NewStroke)
		Slices = Slices - 1
	Loop
End Sub

Sub DrawRandomGraph(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Style As Int, Color As Int, Seed As Int, BigCols As Int, BigRows As Int) As Boolean
	Dim temp As Int, temp2 As Int, tempX As Int, tempY As Int = Y+Height, Stroke As Int = 2, temp3 As Int 
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	RndSeed(Seed)
	Select Case Style 
		Case 0'Praxis 2 bars from bottom
			tempX = 3'Width of a col
			Color = Colors.rgb(96,  145, 239)
			temp3 = Colors.RGB(106, 142, 136)
			For temp = X To X + Width - 1 Step tempX 
				temp2 = Rnd(0,100) * 0.01 * Height 
				LCAR.DrawGradient(BG, Color, temp3, 8, temp, tempY - temp2, tempX, temp2, 0, 0)
			Next
	End Select
	BG.RemoveClip
	API.SeedRND2
	
	LCARSeffects4.DrawRect(BG,X,y,Width,Height,Color,Stroke)
	If BigCols > 0 Then 
		tempX = X
		tempY = Y+Height
		temp2 = Width / BigCols
		For temp = 1 To BigCols - 1
			tempX = tempX + temp2 
			BG.DrawLine(tempX, Y, tempX, tempY, Color, Stroke)
		Next
	End If 
	If BigRows > 0 Then 
		tempY = Y 
		tempX = X + Width 
		temp2 = Height / BigRows
		For temp = 1 To BigRows - 1
			tempY = tempY + temp2
			BG.DrawLine(X, tempY, tempX, tempY, Color, Stroke)
		Next
	End If
	Return True 
End Sub

Sub DrawHollowRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Color,0)
	LCARSeffects4.DrawRect(BG,X+Stroke,Y+Stroke,Width-Stroke*2,Height-Stroke*2,Colors.black,0)
End Sub



'Index: 9=brightest
Sub CronosColor2(Index As Int) As Int
	If Index = 9 Then Return Colors.rgb(50,117,255)
	If Index < 3 Or Index > 15 Then Return Colors.rgb(7,30,168)
	Return Colors.rgb(11,48,190)
End Sub

Sub DrawGradient(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color1 As Int, Color2 As Int, SliceWidth As Int, Offset As Float)
	Dim temp, Right As Int = X + Width
	LCARSeffects.MakeClipPath(BG,x,Y,Width,Height)
	If Offset > 0 Then 
		temp = SliceWidth * Offset 
		X = X - SliceWidth + temp
	End If
	temp = SliceWidth * 0.5
	Do Until X >= Right 
		LCAR.DrawGradient(BG, Color1, Color2, 6, X, Y, temp+1, Height, 0, 0)
		LCAR.DrawGradient(BG, Color2, Color1, 6, X+temp, Y, temp, Height, 0, 0)
		x = x + SliceWidth 
	Loop
	BG.RemoveClip
End Sub

Sub DrawRandomStars(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Quantity As Int, Seed As Int)
	Dim X2 As Int, Y2 As Int, Radius As Int 
	RndSeed(Seed)
	Do Until Quantity < 1
		Radius = Rnd(1,10)
		X2 = X + Rnd(Radius, Width - Radius)
		Y2 = Y + Rnd(Radius, Height - Radius)
		BG.DrawCircle(X2,Y2, Radius, Color, True, 0)
		Quantity = Quantity - 1
	Loop
	API.SeedRND2
End Sub

Sub DrawENToval(BG As Canvas, CenterX As Int, CenterY As Int, Width As Int, RadiusX As Float, FactorY As Float, Color As Int, Stroke As Int, HalfHeight As Int, Number As Int, TextSize As Int)
	Width = Width * RadiusX
	Wireframe.DrawOval(BG, CenterX, CenterY, Width * 2, Width * FactorY * 2, Color, Stroke, True, 0)
	If Number > 0 Then 
		RadiusX = 2'whitespace
		BG.DrawText(Number, CenterX + Width + RadiusX, CenterY + HalfHeight + Stroke * 2 + RadiusX, StarshipFont, TextSize, Color, "LEFT")
	End If
End Sub
Sub GetWords(Text As String, Words As Int) As String 
	Dim tempstr As StringBuilder, temp As Int, Split() As String = Regex.Split(" ", Text)
	tempstr.Initialize
	Words = Min(Words, Split.Length)
	For temp = 0 To Words-1
		tempstr.Append( Split(temp) & " " )
	Next
	Return tempstr.ToString
End Sub
Sub Alpha512(Alpha As Int, Offset As Int) As Int 
	If Alpha < 0 Or Alpha > 512 Then Return 0
	Alpha = (Alpha + Offset) Mod 512
	If Alpha > 255 Then Alpha =  Max(0, 255 - (Alpha-256))
	Return Alpha
End Sub
Sub DrawStar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xf As Float, Yf As Float, Radius As Float, Text As String, R As Int, G As Int, B As Int, Alpha As Int, Offset As Int)
	'Alpha = (Alpha + Offset) Mod 512	'If Alpha > 255 Then Alpha =  Max(0, 255 - (Alpha-256))
	Offset = Colors.aRGB(Alpha512(Alpha, Offset), R,G,B)
	X = X + Width * Xf
	Y = Y + Height * Yf
	Radius = Width * Radius
	BG.DrawCircle(X, Y, Radius, Offset, True, 0)
	Height = LCAR.Fontsize * 0.5 
	Y = Y + Radius * 1.5 + BG.MeasureStringHeight(Text, StarshipFont, Height)
	BG.DrawText(Text, X, Y, StarshipFont, Height, Offset, "CENTER")
End Sub

Sub DrawStars(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Radius As Int, Color As Int, Locations() As Float)
	Dim temp As Int
	For temp = 0 To Locations.Length-1 Step 2
		BG.DrawCircle(X+ Width * Locations(temp) , Y + Height * Locations(temp+1), Radius, Color, True, 0)
	Next
End Sub

'HorInc and VerInc = Step (minimum of 1)
Sub DrawGridWithLines(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CellWidth As Int, CellHeight As Int, BGColor As Int, LineColor As Int, Stroke As Int, Fontsize As Int, Font As Typeface, WhiteSpace As Int, HorInc As Int, HorMult As Float, HorAppend As String, VerInc As Int, VerMult As Float, VerAppend As String, TextColor As Int, Title As String, TitleColor As Int)
	Dim temp As Int, FontHeight As Int = BG.MeasureStringHeight("0123", Font, Fontsize), Cols As Int, Rows As Int, X2 As Int, Text As String
	If Title.Length>0 Then BG.DrawText(Title, X, Y - WhiteSpace, Font, Fontsize, TitleColor, "LEFT")
	Width = Width - (Width Mod CellWidth)
	Height = Height - (Height Mod CellHeight)
	Cols = Width / CellWidth
	Rows = Height / CellHeight
	LCARSeffects4.DrawRect(BG, X, Y, Width, Height, BGColor, 0)
	LCARSeffects4.drawgrid(BG, X, Y, Width, Height, CellWidth, CellHeight, LineColor, Stroke)
	LCARSeffects4.DrawRect(BG, X, Y, Width, Height, LineColor, Stroke)
	Y = Y + Height
	
	DrawGridLines(BG, X,Y, CellWidth, True, HorAppend, Cols, HorInc, HorMult, LineColor, Stroke, Fontsize, FontHeight, Font, TextColor, WhiteSpace)
	DrawGridLines(BG, X,Y, CellWidth, False, VerAppend, Rows, VerInc, VerMult, LineColor, Stroke, Fontsize, FontHeight*0.5, Font, TextColor, WhiteSpace)
	
'	X2 = X	
'	For temp = 0 To Cols - 1 Step HorInc
'		Text = Round2(temp * HorMult, 1) & HorAppend
'		BG.DrawLine(X2, Y, X2, Y+WhiteSpace, LineColor, Stroke)
'		BG.DrawText(Text, X2, Y + WhiteSpace + 1 + FontHeight, Font, Fontsize, TextColor, "LEFT")
'		X2 = X2 + CellWidth * HorInc
'	Next
'	FontHeight=FontHeight*0.5
'	For temp = 0 To Rows Step VerInc
'		Text = Round2(temp * VerMult, 1) & VerAppend
'		BG.DrawLine(X, Y, X-WhiteSpace, Y, LineColor, Stroke)
'		BG.DrawText(Text, X-WhiteSpace-1, Y + FontHeight, Font, Fontsize, TextColor, "RIGHT")
'		Y = Y - CellHeight * VerInc
'	Next
End Sub
Sub DrawGridLines(BG As Canvas, X As Int, Y As Int, UnitWidthHeight As Int, Horizontal As Boolean, Append As String, ColRows As Int, Inc As Int, Multiplier As Float, LineColor As Int, Stroke As Int, FontSize As Int, FontHeight As Int, Font As Typeface, FontColor As Int, WhiteSpace As Int)
	Dim Text As String
	If Inc = 0 Then Inc = 1
	UnitWidthHeight = UnitWidthHeight * Inc 
	If Horizontal Then '------
		For temp = 0 To ColRows - 1 Step Inc
			Text = Round2(temp * Multiplier, 1) & Append
			BG.DrawLine(X, Y, X, Y+ WhiteSpace, LineColor, Stroke)
			BG.DrawText(Text, X, Y + WhiteSpace + 1 + FontHeight, Font, FontSize, FontColor, "LEFT")
			X = X + UnitWidthHeight 
		Next
	Else'|
		For temp = 0 To ColRows Step Inc
			Text = Round2(temp * Multiplier, 1) & Append
			BG.DrawLine(X, Y, X- WhiteSpace, Y, LineColor, Stroke)
			BG.DrawText(Text, X - WhiteSpace-1, Y + FontHeight, Font, FontSize, FontColor, "RIGHT")
			Y = Y - UnitWidthHeight
		Next
	End If 
End Sub

Sub CronosColor(Index As Int, TextAlign As Int) As Int 
	Dim Normal As Int, Bright As Int 
	Index = 24 - Index
	Select Case Index  
		Case 0, 1
			Normal = Colors.RGB(255, 255, 0)
			Bright = Colors.White
		Case 2
			Normal = Colors.RGB(164, 129, 229)
			Bright = Colors.RGB(196, 172, 242)
		Case Else 
			Normal = Colors.RGB(69, 93, 247)
			Bright = Colors.RGB(107, 199, 254)
	End Select
	If Index Mod 5 = TextAlign Then Return Bright 
	Return Normal 
End Sub

Sub DrawENTSINwave(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Xoffset As Int, Amplitude As Int, Wavelength As Int, Color As Int, Stroke As Int, AmplitudeF As Float, WavelengthF As Float) As Int
	Dim HalfHeight As Int = Height*0.5, Right As Int = X + Width, Middle As Int = Y+HalfHeight, Top As Boolean = Amplitude > 0
	If Top Then DrawENTSINwave(BG,X,Y,Width,Height,Xoffset,-Amplitude,Wavelength,Color,Stroke, AmplitudeF, WavelengthF) Else Amplitude = Abs(Amplitude)
	LCARSeffects.MakeClipPath(BG,X,Y + API.IIF(Top, 0,HalfHeight) ,Width,HalfHeight)
	Xoffset=Abs(Xoffset) Mod Wavelength
	Wavelength=Wavelength*0.5
	X=X-Xoffset + API.IIF(Top, 0,Wavelength)
	Width = Width+Xoffset
	Do Until X >= Right
		BG.DrawOval(LCAR.SetRect(X,Middle - Amplitude,Wavelength,Amplitude * 2), Color,False,Stroke)
		X=X+Wavelength * 2
		If AmplitudeF <> 1 Then Amplitude = Amplitude * AmplitudeF
		If WavelengthF <> 1 Then Wavelength = Wavelength * WavelengthF
	Loop
	BG.RemoveClip
	Return Xoffset
End Sub

Sub DrawENTBBar2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Value As Int, WhiteSpace As Int)
	Dim Red As Int = Colors.RGB(249, 128, 105), Yellow As Int = Colors.RGB(247, 249, 104), BottomPart As Int = Height * 0.75, Percent As Float = Value * 0.01, TopPart As Int
	Y=Y+Height
	Height = Height * Percent
	BottomPart = Min(BottomPart, Height)
	TopPart = Height - BottomPart
	Width = Width - WhiteSpace
	LCARSeffects4.DrawRect(BG, X, Y - BottomPart, Width, BottomPart, Red, 0)
	LCARSeffects4.DrawRect(BG, X, Y - Height, Width, TopPart, Yellow, 0)
End Sub
Sub DrawENTBCircle(BG As Canvas, CenterX As Int, CenterY As Int, Radius As Int, Color As Int, X As Int, Y As Int, Angle As Int)
	Dim SrcX As Int = 79, SrcY As Int = 1396, Index As Int 
	If Y = -4 And (X = -4 Or X >2) Then Return
	If Y = -3 And X = -4 Then Return 
	If Y = 3 And X = 4 Then Return 
	If Y = 4 And (X=4 Or X < -2) Then Return 
	BG.DrawCircle(CenterX, CenterY, Radius, Color, True, 0)
	Select Case Y 
		Case -4: If X = -3 Then Index = 6
		Case -3: If X = -3 Then Index = 16'Flip 6 X
		Case -2: If x = -4 Then Index = 6
		Case -1
			If x = -4 Then Index = 4
			If x = 4  Then Index = 2
		Case 0
			If x = -4 Then Index = 15
			If x = 4  Then Index = 14
		Case 1
			If x = -4 Then Index = 1
			If x = 4  Then Index = 2
		Case 2
			If x = -4 Then Index = 11
			If x = -4 Then Index = 1
		Case 3
			If x = -4 Then Index = 3
			If x = 3  Then Index = 13
		Case 4
			If x = -2 Then Index = 11
			If x = 0 Or x = 1 Then Index = 1
	End Select
	If Index > 0 Then
		If Index > 9 And Index < 20 Then Angle = Angle + 90 
		If Index > 19 And Index < 30 Then Angle = Angle + 180
		If Index > 29 And Index < 40 Then Angle = Angle + 270
		Index = Index Mod 10 
		If Index > 3 Then 
			SrcX = 146
			If Index > 1 Then SrcY = SrcY + (Index-3) * 68
		Else if Index > 1 Then 
			SrcY = SrcY + (Index-1) * 68
		End If
		Radius = Radius - 2
		BG.DrawBitmapRotated(CenterPlatform, LCARSeffects4.SetRect(SrcX, SrcY, 68,68), LCARSeffects4.SetRect(CenterX - Radius, CenterY-Radius, Radius*2, Radius*2), Angle)
	End If	
End Sub
Sub DrawRadarWave(BG As Canvas, X As Int, Y As Int, CenterRadius As Int, Radius As Int, Degrees As Int, R As Int, G As Int, B As Int, Angle As Int)
	Dim Alpha As Float = 255, DegreesInc As Int = 2, Lines As Int = Degrees / DegreesInc, AlphaInc As Float = 255 / Lines, temp As Int, X2 As Int, Y2 As Int, Stroke As Int, X3 As Int = X, Y3 As Int = Y
	Stroke = Trig.findXYAngle(0,0, Radius, 90 + DegreesInc*2, False)
	For temp = 1 To Lines 
		X2 = Trig.findXYAngle(X,Y, Radius, Angle, True)
		Y2 = Trig.findXYAngle(X,Y, Radius, Angle, False)
		If CenterRadius > 0 Then 
			X3 = Trig.findXYAngle(X,Y, CenterRadius, Angle, True)
			Y3 = Trig.findXYAngle(X,Y, CenterRadius, Angle, False)
		End If
		BG.DrawLine(X3,Y3, X2,Y2, Colors.ARGB(Alpha, R,G,B), Stroke)
		Alpha = Alpha - AlphaInc 
		Angle = Angle - DegreesInc
	Next
End Sub
Sub DrawENTBgraph(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, Selected As Boolean, WidthOfRightCol As Int, CenterOfLeftCol As Int, Index As Int, TextSize As Int)
	Dim ColorID As Int = LCAR.Classic_Green, Color As Int, NewWidth As Int = Width * 0.08, WhiteSpace As Int = Width * 0.0162162162162162, temp As Int = Width * 0.15, Blue As Int = Colors.RGB(50,168,255)
	If Selected Then ColorID = LCAR.Classic_Yellow
	Color = LCAR.GetColor(ColorID, False, 255)
	LCARSeffects4.DrawRect(BG, X+Width - NewWidth, Y, NewWidth, Height, Color, 0)
	
	If Index < 4 Then 
		Index = 16 + Index * 9
	Else 
		Index = 50 + Index * 11
	End If
	temp = DateTime.GetSecond(DateTime.Now) Mod 10 - 5
	BG.DrawText(API.PadtoLength(Index, True, 3, "0"), CenterOfLeftCol, Y + Height, StarshipFont, TextSize, Color, "CENTER")
	BG.DrawText(Angle + temp, X + Width + WidthOfRightCol*0.5, Y + Height*0.5 + BG.MeasureStringHeight(Angle, StarshipFont, LCAR.Fontsize) * 0.5, StarshipFont, LCAR.Fontsize, LCAR.GetColor(LCAR.Classic_Blue, Selected, 255), "CENTER")
	
	Width = Width - WhiteSpace*3 - NewWidth
	NewWidth = Trig.findXYAngle(0,0, Width, Angle, True) '+ temp
	LCARSeffects4.DrawRect(BG, X, Y, WhiteSpace, Height, Blue, 0)
	
	X=X+WhiteSpace * 2
	temp = Min(Width * 0.20, NewWidth)
	LCARSeffects4.DrawRect(BG, X, Y, temp, Height, Color, 0)
	NewWidth = NewWidth - temp - WhiteSpace
	
	X=X+WhiteSpace + temp
	temp = Min(Width * 0.08, NewWidth)
	LCARSeffects4.DrawRect(BG, X, Y, temp, Height, Blue, 0)
	NewWidth = NewWidth - temp - WhiteSpace
	
	X=X+WhiteSpace + temp
	temp = Min(Width * 0.03, NewWidth)
	LCARSeffects4.DrawRect(BG, X, Y, NewWidth - WhiteSpace, Height, Color, 0)
	LCARSeffects4.DrawRect(BG, X + NewWidth + WhiteSpace - temp, Y, temp, Height, Blue, 0)
	
	'first part is 20%, then 8%, the rest, 3%
End Sub
Sub DrawENTBchart(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, FlipX As Boolean, State As Boolean, Alpha As Int, Value As Int, Yellow As Int, Green As Int)
	Dim Left As Int, Middle As Int, Right As Int, Stroke As Int = 4, temp As Int = Width * 0.1, Y2 As Int = Y + Height, TextSize As Int, Align As String, TextColor As Int, TextHeight As Int
	TextColor = Colors.ARGB(Alpha,45,144,253)
	If FlipX Then 'Right side
		Left = X
		Middle = X + Width * 0.75
		Right = X + Width
		LCARSeffects4.DrawRect(BG,X,Y, temp, Height, Green, 0)
		DrawENTBBar(BG,X-Width,Y,Width,Height, Green, Yellow, Value, 0)
	Else 'Left Side
		Left = X + Width 
		Middle = X + Width * 0.25
		Right = X 
		LCARSeffects4.DrawRect(BG,X+ Width - temp,Y, temp, Height, Green, 0)
		DrawENTBBar(BG,X+Width,Y,Width,Height, Green, Yellow, Value, Height * 0.05)
	End If
	BG.DrawLine(X,Y, X+Width, Y, Yellow, Stroke)
	BG.DrawLine(X,Y2, X+Width, Y2, Yellow, Stroke)
	TextSize = API.GetTextLimitedHeight(BG, Height * 0.04, Width, "99", StarshipFont)
	TextHeight = BG.MeasureStringHeight("0123456789", StarshipFont, TextSize) * 0.5
	'0-70(25%) = low density, 70(25%)-250(90%) high density of 275 (% is from 0=top, 100=bottom)
	'yellow at 85(30%), 135(50%), 160(60%), 225(80%)
	Y2 = Y2 + TextHeight*3
	If FlipX Then
		BG.DrawText(Value, X, Y2, StarshipFont, TextSize, TextColor, "LEFT")
		X = X + Width + 2
		Align = "LEFT"
	Else
		BG.DrawText(Value, Left, Y2, StarshipFont, TextSize, TextColor, "RIGHT")
		X = X - 2
		Align = "RIGHT"
	End If
	For temp = 5 To 25 Step 5
		Y2 = Y + Height * temp * 0.01
		BG.DrawLine(Left, Y2, Right, Y2, Green, Stroke)
		DrawENTBLabel(BG, X, Y2, temp, TextSize, TextColor, Align, TextHeight)
	Next
	For temp = 30 To 90 Step 2
		Y2 = Y + Height * temp * 0.01
		If temp Mod 10 = 0 Then 
			BG.DrawLine(Left, Y2, Right, Y2, Yellow, Stroke)
			DrawENTBLabel(BG, X, Y2, temp, TextSize, TextColor, Align, TextHeight)
		Else 
			BG.DrawLine(Left, Y2, Middle, Y2, Green, Stroke)
		End If 
	Next
	For temp = 35 To 95 Step 10 
		Y2 = Y + Height * temp * 0.01
		DrawENTBLabel(BG, X, Y2, temp, TextSize, TextColor, Align, TextHeight)
	Next
End Sub
Sub DrawENTBLabel(BG As Canvas, X As Int, Y As Int, Percent As Int, TextSize As Int, Color As Int, Align As String, TextHeight As Int)
	Percent = 100 - Percent
	BG.DrawText(Percent, X,Y+TextHeight, StarshipFont, TextSize,  Color, Align)
End Sub
Sub DrawENTBBar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Green As Int, Yellow As Int, Value As Int, TopPart As Int)
	Dim WhiteSpace As Int = Width * 0.2, Percent As Float = Value/1000, Height2 As Int = Height * Percent, Top As Int = Y + Height - Height2
	Width = Width - WhiteSpace * 2
	X = X + WhiteSpace
	If TopPart > 0 Then
		TopPart = Min(TopPart, Height2)
		LCARSeffects4.DrawRect(BG,X,Top,Width,TopPart, Yellow, 0)
		Top = Top + TopPart 
		Height2 = Height2 - TopPart
	End If
	If Height2 > 0 Then LCARSeffects4.DrawRect(BG,X,Top,Width, Height2, Green, 0)
End Sub

Sub DrawCEstar(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, X2 As Float, Y2 As Float, R2 As Float, ColorID As Int, State As Boolean, Alpha As Int)
	Dim temp As Int 
	R2=Width*R2*0.5
	temp=R2*0.5
	BG.DrawCircle(X+(Width*X2)-temp, Y +(Height*Y2)-temp, R2, LCAR.GetColor(ColorID,State,Alpha), True,0)
End Sub
Sub DrawCEsquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, X2 As Float, Y2 As Float, Width2 As Float, Height2 As Float, ColorID As Int, State As Boolean, Alpha As Int)
	Dim Left As Int = X + (Width*X2), Top As Int = Y +(Height*Y2)
	If Width=0 And CurrentSquare >-1 Then
		CurrentSquare=CurrentSquare+1
	Else
		If Height2=0 Then
			Width2=Width2*Height
			BG.DrawCircle(Left,Top,  Width2,  LCAR.GetColor(ColorID,State,Alpha), True, 0)
		Else
			Width2=Width2*Width
			Height2=Height2*Height
			LCAR.DrawRect(BG, Left, Top, Width2, Height2, LCAR.GetColor(ColorID,State,Alpha), 0)
			If CurrentSquare>-1 Then
				LCAR.DrawRect(BG, Left, Top, Width2, Height2, LCAR.GetColor(ColorID,Not(State),Alpha), 1)
				BG.DrawText(CurrentSquare, Left+ Width2*0.5, Top + Height2*0.5,  LCAR.LCARfont, 10, Colors.Red, "LEFT")
				
				'X=X+Width + (CurrentSquare*20)
				'BG.DrawLine(Left+ Width2*0.5, Top + Height2*0.5, X, Top + Height2*0.5, Colors.Red, 0)
				'BG.DrawText(CurrentSquare,  X, Top + Height2*0.5, LCAR.LCARfont, 10, Colors.Red, "LEFT")
				CurrentSquare=CurrentSquare+1
			End If
		End If
	End If
End Sub











Sub SetupWarpCore(Height As Int) As Boolean 
	Dim Filename As String
	If CenterPlatformID <> LCAR.LCAR_WarpCore Then
		If API.FileExists(LCAR.DirDefaultExternal, "warpcorehi.jpg") Then
			Filename= "warpcorehi.jpg"
			WarpLowRes=False
		Else If API.FileExists(LCAR.DirDefaultExternal, "warpcorelo.jpg") Then
			Filename= "warpcorelo.jpg"
			WarpLowRes=True
		Else If Height=-1 And API.IsConnected Then
			API.Download("MSD", "https://sites.google.com/site/programalpha11/home/lcars/warpcore"& API.IIF(API.isWIFI_enabled, "hi","lo") &  ".jpg?attredirects=0")		
		End If
		If Height=-1 Or Filename.Length=0 Then Return False
		LoadUniversalBMP(LCAR.DirDefaultExternal, Filename, LCAR.LCAR_WarpCore)
	End If
	WarpScaleFactor=  Height/CenterPlatform.Height 
	WallpaperService.msdWidth= 1440 * WarpScaleFactor
	If WarpLowRes Then WallpaperService.msdWidth = WallpaperService.msdWidth* 0.5
	
	'Log(WarpScaleFactor & " " & Height & " " & CenterPlatform.Height & " "  & WallpaperService.msdWidth)
End Sub
Sub DrawWarpCoreReal(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int)As Boolean 
	'Original size: 0,0, 1440, 1080
	'Small size: 306, 72
	'Large coordinates: 542, 24 (MIDDLE)
	'Large size: 317, 413
	'Medium coordinates: 534, 824 (BOTTOM)
	'Medium size: 332, 160
	If WarpScaleFactor =0 Or CenterPlatformID <> LCAR.LCAR_WarpCore Then	
		If Not(SetupWarpCore(Height)) Then
			LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False, 255, API.GetString("warp_download"))
		End If
	Else
		'If Stage=0 OR WarpLastX <> X Then 
		DrawWarpCoreBit(BG, X,Y, 0,0,  0,0, 1440,1080)
		Select Case Stage
			Case 0'blank
			Case 1:DrawWarpCoreBit(BG, X,Y,		548,0,		1440,1008,		306,72)		
			Case 2:DrawWarpCoreBit(BG, X,Y,		541,24,		1440,0,			317,413)
			Case 3:DrawWarpCoreBit(BG, X,Y,		541,24,		1440,414,		317,413)
			Case 4:DrawWarpCoreBit(BG, X,Y,		541,24,		1758,0,			317,413)
			Case 5
				DrawWarpCoreBit(BG, X,Y,		541,24,		1758,414,		317,413)
				DrawWarpCoreBit(BG, X,Y,		518,813,	1745,920,		332,160)
			Case 6
				DrawWarpCoreBit(BG, X,Y,		541,24,		2076,0,			317,413)
				DrawWarpCoreBit(BG, X,Y,		518,813,	2078,920,		332,160)			
		End Select
		'WarpLastX=X
	End If
End Sub
Sub DrawWarpCoreBit(BG As Canvas, X As Int, Y As Int, destX As Int, destY As Int,srcX As Int, srcY As Int, Width As Int, Height As Int)
	Dim srcrect As Rect, destrect As Rect 
	If WarpLowRes Then 
		srcX=srcX * 0.5
		srcY=srcY*0.5
		Width=Width*0.5
		Height=Height*0.5
		destX=destX*0.5
		destY=destY*0.5
	End If
	srcrect = LCAR.SetRect(srcX,srcY,Width,Height)
	'If srcX>0 Then Log(WarpScaleFactor & " " & X & " " & destX & " " & (X + (destX*WarpScaleFactor)))
	destrect = LCAR.SetRect(X + (destX*WarpScaleFactor), Y+(destY*WarpScaleFactor), Width*WarpScaleFactor,Height*WarpScaleFactor)
	BG.DrawBitmap(CenterPlatform,  srcrect,destrect)
End Sub



Sub shuttleText(TextIndex As Int, Index As Int) As String 
	Select Case TextIndex
		Case 0'shuttle pods
			Return API.IIFIndex(Index, Array As String("OKUDA", "CHRIS PIKE", "VOLTAIRE", "EL-BAZ", "ONIZUKA", "HEINLEIN", "LINDBERG", "PT FARNSWORTH", "LEY", "SAM FREEDLE", "CAMPBELL", "COCHRANE", "ARMSTRONG", "CURIE", "FEYNMAN", "BERMAN"))
		Case 1'shuttles
			Return API.IIFIndex(Index, Array As String("SAKHAROV", "EINSTEIN", "CURIE", "VON BRAUN", "CLARKE", "ANSEL ADAMS", "GALILEO", "INDIANA JONES", "FERMI", "COUSTEAU", "DECARTES", "JUSTMAN", "FEYNMAN", "JF KENNEDY", "GODDARD", "HAWKING", "MAGELLAN", "PILLAR", "TERESHKOVA", "McAULIFFE"))'0-19
		Case 2'statuses
			Return API.GetString("bay_stat" & Index) 'API.IIFIndex(Index, Array As String("AVAILABLE", "OVERHAUL", "REFIT", "TESTING", "STANDBY", "OFF SHIP"))
		Case 3'locations
			Select Case Index 
				Case 2: TextIndex = 4
				Case 3: TextIndex = 6
				Case 5: TextIndex = 1000
				Case 6: TextIndex = 10
				Case Else: TextIndex = 0
			End Select 
			If TextIndex > 0 Then TextIndex = Rnd(1, TextIndex)
			Return API.GetStringVars("bay_loc" & Index, Array As String(TextIndex))
			'Return API.IIFIndex(Index, Array As String("ON APPROACH", "LEAVING", "BAY " & Rnd(1,4), "HANGAR " & Rnd(1,6), "MAIN BAY", "STARBASE " & Rnd(1,1000), "DEEP SPACE " & Rnd(1,10), "AWAY MISSION" ))
		Case 4'shuttle type
			Return API.GetString("bay_type" & Index)
			'Return API.IIFIndex(Index, Array As String("POD", "SHUTTLE"))', "WORKBEE", "CAPTAIN'S YACHT"))
	End Select
End Sub
Sub SetupShuttles(BG As Canvas)
	Dim temp As Int = 11
	If LCAR.CrazyRez>0 Then temp=temp*LCAR.CrazyRez
	ShuttleTextHeight= API.GetTextHeight(BG, temp, "TESTING", LCAR.LCARfont)'   API.TextHeightAtHeight(BG,LCAR.LCARfont, "TESTING", 11)	
	Shuttles.Initialize 
	temp=0
	Do While MakeShuttle(False, temp)'shuttles
		temp=temp+1
	Loop
	temp=0
	Do While MakeShuttle(True, temp)'pods
		temp=temp+1
	Loop
	ShuttleLines.Initialize 
	For temp = 1 To 6
		MakeShuttleLine
	Next
End Sub

Sub MakeShuttle(isPod As Boolean, Index As Int)As Boolean 
	Dim temp As Shuttle ,tempstr As String ,temp2 As Int 
	tempstr= shuttleText( API.IIF(isPod, 0,1), Index)
	If tempstr.Length>0 Then
		temp.Initialize 
		temp.Name = tempstr
		temp.Loc=shuttleText(3, Rnd(2,5))'bay,hangar,mainbay
		temp2=Rnd(0,5)
		temp.ShowIcon = temp2=0 Or temp2>2
		temp.Status = shuttleText(2,temp2)'"AVAILABLE", "OVERHAUL", "REFIT", "TESTING", "STANDBY"
		temp.IsShuttle = Not(isPod)
		temp.Index=Index+1
		temp.isOffship =False
		temp.colorid = LCAR.LCAR_RandomColor
		Shuttles.Add(temp)
		Return True
	End If
End Sub
Sub MakeShuttleLine'MaxAge=8:MaxPositions=12
	Dim temp As ShuttleLine 
	temp.Initialize 
	temp.Age=0
	temp.Direction=False'away from ship
	temp.Position=-1
	temp.ShuttleID=-1
	ShuttleLines.Add(temp)
	UseRandomShuttle( ShuttleLines.Size-1)
End Sub

Sub UseRandomShuttle(ShuttleLineID As Int)
	Dim tempLine As ShuttleLine, tempShuttle As Shuttle  
	tempLine=ShuttleLines.Get(ShuttleLineID)
	tempLine.ShuttleID=FindUnusedShuttle
	If tempLine.ShuttleID >-1 Then
		tempShuttle = Shuttles.Get(tempLine.ShuttleID)
		tempLine.Age = MaxAge
		tempShuttle.inUse=True
		tempShuttle.Status = shuttleText(2,5)
		If tempShuttle.isOffship Then
			tempShuttle.Loc = shuttleText(3,0)'on approach
			tempLine.Direction = True'towards ship
			tempLine.Position = MaxPositions-1 + Rnd(0,4)'last cell + random delay to desync the shuttles
		Else
			tempShuttle.Loc = shuttleText(3,1)'leaving
			tempLine.Direction = False'away from ship
			tempLine.Position = -Rnd(0,4)'first cell - random delay to desync the shuttles
		End If
	End If
	'Log("Shuttle id " & tempLine.ShuttleID & " (" & tempShuttle.Name & ") "  & tempShuttle.Status & " - " & tempShuttle.Loc)
End Sub

Sub FindUnusedShuttle As Int 
	Dim temp As Int,temp2 As Int, tempShuttle As Shuttle 
	temp=-1
	Do Until temp >-1 
		temp2 = Rnd(0, Shuttles.Size)
		tempShuttle= Shuttles.Get(temp2)
		If Not(tempShuttle.inUse ) Then temp = temp2
	Loop
	Return temp
	
	'For temp = 0 To Shuttles.Size-1
'		tempShuttle= Shuttles.Get(temp)
'		If Not(tempShuttle.inUse ) Then Return temp
	'Next
	'Return -1'should never occur
End Sub

Sub IncrementShuttles
	Dim temp As Int ,tempLine As ShuttleLine
	If ShuttleLines.IsInitialized Then
		For temp = 0 To ShuttleLines.Size -1
			tempLine=ShuttleLines.Get(temp)
			tempLine.Age= tempLine.Age-1 
			If tempLine.Age = 0 Then 
				tempLine.Age = MaxAge
				If tempLine.Direction Then'towards ship
					tempLine.Position = tempLine.Position-1
					If tempLine.Position = -1 Then 'is now in ship
						UnuseShuttle(tempLine.ShuttleID, True)
						UseRandomShuttle(temp)
					'Else
						'Log("Shuttle in line " & temp & " moved 1 cell closer to the ship")
					End If
				Else'away from ship
					tempLine.Position = tempLine.Position+1
					If tempLine.Position > MaxPositions-1 Then'is gone
						UnuseShuttle(tempLine.ShuttleID, False)
						UseRandomShuttle(temp)
					'Else
						'Log("Shuttle in line " & temp & " moved 1 cell farther from the ship")
					End If
				End If
			End If
		Next
	End If
End Sub
Sub UnuseShuttle(ID As Int, Direction As Boolean )
	Dim tempShuttle As Shuttle  ,temp As Int 
	tempShuttle = Shuttles.Get(ID)
	tempShuttle.inUse=False
	If Direction Then 'is now in ship
		tempShuttle.Loc=shuttleText(3, Rnd(2,5))'bay,hangar,mainbay
		temp=Rnd(0,5)
		tempShuttle.isOffship =False
	Else 'is gone
		tempShuttle.Loc=shuttleText(3, Rnd(5,8))'"STARBASE " & Rnd(1,1000), "DEEP SPACE " & Rnd(1,10), "AWAY MISSION" )
		temp=5
		tempShuttle.ShowIcon=False
		tempShuttle.isOffship =True	
	End If
	tempShuttle.Status = shuttleText(2,temp)'"AVAILABLE", "OVERHAUL", "REFIT", "TESTING", "STANDBY"
	tempShuttle.ShowIcon = (temp=0 Or temp=3 Or temp=4)
	
	'Log("Shuttle id " & ID & " (" & tempShuttle.Name & ") "  & tempShuttle.Status & " - " & tempShuttle.Loc)
End Sub

Sub DrawShuttleBay(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Index As Int)
	Dim temp As Int ,Dest As Rect ,tempLine As ShuttleLine, ScaleFactor As Float = 1
	If LCAR.CrazyRez > 0 Then ScaleFactor=LCAR.CrazyRez
'	temp = (Height/370) * 701 'width of starship at that height
'	If Width <> temp Then
'		X=X+Width/2 - temp/2
'		Width=temp
'	End If
	'11 (0.0156918687589158) by 9 pixels (0.0243243243243243)
	'Try
	
	'LoadUniversalBMP(File.DirAssets, "shuttlebays.png", LCAR.LCAR_Shuttlebay) '701 x 370 (185*2)
	If Not( Shuttles.IsInitialized) Then SetupShuttles(BG)
	Select Case Index 
		Case 0'main ship diagram
			temp=Height/2
			LoadUniversalBMP(File.DirAssets, "shuttlebays.png", LCAR.LCAR_Shuttlebay) '701 x 370 (185*2)
			
			'DrawBMP(BG,CenterPlatform, 0,0,0,0, X,Y,Width, temp, 128, False,True)
			'DrawBMP(BG,CenterPlatform, 0,0,0,0, X,Y+temp-1,Width, temp, 255, False,False)
			BG.DrawBitmapFlipped(CenterPlatform, Null, LCAR.SetRect(X,Y,Width, temp), True,False)
			BG.DrawBitmap(CenterPlatform,Null, LCAR.SetRect(X,Y+temp-2,Width, temp))
			
			For temp = 0 To 5
				DrawShuttleBay(BG,X,Y,Width,Height, temp+5)
			Next
			
		Case 1'SHUTTLE STATUS LIST
			'LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange ,False,255, "TESTING")
			DrawPartOfShuttleList(BG,X,Y,Width,Height, 0,19)
		Case 2'POD STATUS LIST 
			'LCAR.DrawUnknownElement(BG,X,Y,Width,Height,LCAR.LCAR_Orange ,False,255, "TESTING")
			DrawPartOfShuttleList(BG,X,Y,Width,Height, 20,Shuttles.Size-1)
	
		Case 3'Shuttle, use width as color, 22,174,   28,11
			Dest= LCAR.SetRect(X,Y, 28*ScaleFactor,11*ScaleFactor)
			BG.DrawRect(Dest, Width,True,0)
			BG.DrawBitmap(CenterPlatform, LCAR.SetRect(22,174,   28,11), Dest)
		Case 4'pod, use width as color,     0,174,  21,11
			Dest= LCAR.SetRect(X,Y, 21*ScaleFactor,11*ScaleFactor)
			BG.DrawRect(Dest, Width,True,0)
			BG.DrawBitmap(CenterPlatform, LCAR.SetRect(0,174,   21,11), Dest)
		
		Case Else'shuttle lines
			Index=Index-5
			'Log("DRAWING BAY " & Index)
			tempLine = ShuttleLines.Get(Index)
			If tempLine.Position>-1 And tempLine.Position < MaxPositions Then
				temp=((tempLine.Age+1) / MaxAge) * 255
				'temp = API.IIFIndex(tempLine.Age, Array As Int(64,128,192,255,255,192,128,64))
				temp=LCAR.GetColor(LCAR.LCAR_Orange, False, temp)
				BG.DrawRectRotated( LCAR.SetRect(X+GetSquarePosition(Index, 0, Width, tempLine.Position), Y+GetSquarePosition(Index, 1, Height, tempLine.Position), Width*0.0156918687589158*API.IIF(tempLine.Position=1 Or tempLine.Position=2, 0.5,1), Height*0.0243243243243243), temp, True,0,  GetSquarePosition(Index, 2,0,0))
			End If
	End Select
	
	'Catch
	'End Try
	
End Sub
Sub GetSquarePosition(Line As Int, ID As Int, Size As Int, Position As Int) As Int
	'MaxAge=8:MaxPositions=12
	'Dim sqH As Double = 0.0243243243243243
	Select Case Line'id 0=x, 1=y, 2=rotation
		Case 0'top top
			If ID=2 Then
				Return 10'Rotation
			Else
				Select Case Position
					Case 0:	Return ReturnVal(ID,Size, 0.60913,0.36216)
					Case 1: Return ReturnVal(ID,Size, 0.59914,0.35135)
					Case 2: Return ReturnVal(ID,Size, 0.59058,0.34595)
					Case 3: Return ReturnVal(ID,Size, 0.56633,0.33514)
					Case 4: Return ReturnVal(ID,Size, 0.54208,0.32703)
					Case 5: Return ReturnVal(ID,Size, 0.52068,0.31622)
					Case 6: Return ReturnVal(ID,Size, 0.49643,0.30811)
					Case 7: Return ReturnVal(ID,Size, 0.40514,0.27297)
					Case 8: Return ReturnVal(ID,Size, 0.31384,0.24054)
					Case 9: Return ReturnVal(ID,Size, 0.22111,0.20270)
					Case 10:Return ReturnVal(ID,Size, 0.12839,0.17297)
					Case 11:Return ReturnVal(ID,Size, 0.03424,0.13514)
				End Select
			End If
		Case 1'top bottom
			If ID=2 Then
				Return 10'Rotation
			Else
				Select Case Position
					Case 0:	Return ReturnVal(ID,Size, 0.60770, 0.39459)
					Case 1: Return ReturnVal(ID,Size, 0.59344, 0.39730)
					Case 2: Return ReturnVal(ID,Size, 0.58345, 0.39459)
					Case 3: Return ReturnVal(ID,Size, 0.56063, 0.38649)
					Case 4: Return ReturnVal(ID,Size, 0.53780, 0.37838)
					Case 5: Return ReturnVal(ID,Size, 0.51498, 0.37297)
					Case 6: Return ReturnVal(ID,Size, 0.49073, 0.36216)
					Case 7: Return ReturnVal(ID,Size, 0.39943, 0.32703)
					Case 8: Return ReturnVal(ID,Size, 0.30813, 0.29730)
					Case 9: Return ReturnVal(ID,Size, 0.21541, 0.26486)
					Case 10:Return ReturnVal(ID,Size, 0.12268, 0.23243)
					Case 11:Return ReturnVal(ID,Size, 0.02996, 0.20000)
				End Select
			End If

		Case 2,3' middle 2
			Select Case ID			
				Case 0'X
					Select Case Position
						Case 0:	Return Size*0.60342
						Case 1: Return Size*0.59201
						Case 2: Return Size*0.58060
						Case 3: Return Size*0.55920
						Case 4: Return Size*0.53352
						Case 5: Return Size*0.51070
						Case 6: Return Size*0.48787
						Case 7: Return Size*0.39515
						Case 8: Return Size*0.30100
						Case 9: Return Size*0.20827
						Case 10:Return Size*0.11412
						Case 11:Return Size*0.01997
					End Select
				Case 1'Y
					If Line=3 Then
						Return 0.46216 * Size
					Else
						Return 0.51622 * Size
					End If
			End Select
			
		Case 4'bottom top
			If ID=2 Then
				Return 170'Rotation
			Else
				Select Case Position
					Case 0:	Return ReturnVal(ID,Size, 0.60485, 0.58108)
					Case 1: Return ReturnVal(ID,Size, 0.59344, 0.57838)
					Case 2: Return ReturnVal(ID,Size, 0.58345, 0.58108)
					Case 3: Return ReturnVal(ID,Size, 0.55920, 0.58919)
					Case 4: Return ReturnVal(ID,Size, 0.53495, 0.59730)
					Case 5: Return ReturnVal(ID,Size, 0.51355, 0.60270)
					Case 6: Return ReturnVal(ID,Size, 0.48930, 0.61351)
					Case 7: Return ReturnVal(ID,Size, 0.39800, 0.64054)
					Case 8: Return ReturnVal(ID,Size, 0.30528, 0.67027)
					Case 9: Return ReturnVal(ID,Size, 0.21255, 0.70270)
					Case 10:Return ReturnVal(ID,Size, 0.12126, 0.73243)
					Case 11:Return ReturnVal(ID,Size, 0.02853, 0.76486)
				End Select
			End If
			
		Case 5'bottom bottom
			If ID=2 Then
				Return 170'Rotation
			Else
				Select Case Position
					Case 0:	Return ReturnVal(ID,Size, 0.60913, 0.61081)
					Case 1: Return ReturnVal(ID,Size, 0.59629, 0.62703)
					Case 2: Return ReturnVal(ID,Size, 0.58488, 0.62973)
					Case 3: Return ReturnVal(ID,Size, 0.56205, 0.63784)
					Case 4: Return ReturnVal(ID,Size, 0.53923, 0.64595)
					Case 5: Return ReturnVal(ID,Size, 0.51783, 0.65405)
					Case 6: Return ReturnVal(ID,Size, 0.49215, 0.66216)
					Case 7: Return ReturnVal(ID,Size, 0.40228, 0.69730)
					Case 8: Return ReturnVal(ID,Size, 0.30956, 0.72973)
					Case 9: Return ReturnVal(ID,Size, 0.21683, 0.76216)
					Case 10:Return ReturnVal(ID,Size, 0.12411, 0.79459)
					Case 11:Return ReturnVal(ID,Size, 0.03281, 0.82703)
				End Select
			End If
	End Select
	Return 0
End Sub
Sub ReturnVal(ID As Int, Size As Int, X As Double, Y As Double) As Int 
	If ID = 0 Then 
		Return X*Size
	Else
		Return Y*Size
	End If
End Sub

Sub DrawPartOfShuttleList(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StartIndex As Int, EndIndex As Int)
	Dim temp As Int ,LineHeight As Int,Color As Int, tempShuttle  As Shuttle, ScaleFactor As Float = 1
	LineHeight=2'whitespace
	Y=Y+LineHeight
	Height=Height-LineHeight
	If LCAR.CrazyRez > 0 Then ScaleFactor=LCAR.CrazyRez
	
	LineHeight=20*ScaleFactor	
	For temp = StartIndex To Min(EndIndex, Shuttles.Size-1)
		tempShuttle = Shuttles.Get(temp)
		Color = LCAR.GetColor(tempShuttle.ColorID, False,255)
		'ShuttleVehicleW As Int ,StatusW As Int, LocationW As Int
		
		If tempShuttle.ShowIcon Then DrawShuttleBay(BG,X,Y, Color,0,  API.IIF(tempShuttle.IsShuttle, 3,4) )
		
		BG.DrawText(shuttleText(4, API.IIF(tempShuttle.IsShuttle,1,0)) & " " & API.PadtoLength( tempShuttle.Index, True, 2,"0"), X+33*ScaleFactor, Y+11*ScaleFactor, LCAR.LCARfont, ShuttleTextHeight, Color, "LEFT")
		BG.DrawText(tempShuttle.Name, X+90*ScaleFactor, Y+11*ScaleFactor, LCAR.LCARfont, ShuttleTextHeight, Color, "LEFT")
		BG.DrawText(tempShuttle.Status, X+(ShuttleVehicleW*ScaleFactor)+4, Y+11*ScaleFactor, LCAR.LCARfont, ShuttleTextHeight, Color, "LEFT")
		BG.DrawText(tempShuttle.Loc, X+(ShuttleVehicleW+StatusW)*ScaleFactor+8, Y+11*ScaleFactor, LCAR.LCARfont, ShuttleTextHeight, Color, "LEFT")
		
		Y=Y+LineHeight
		Height=Height-LineHeight
		If Height<1 Then temp=EndIndex
	Next
End Sub



Sub DrawAnimatedSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, AprilFoolsMode As Boolean)
	Dim Row As Int,X2 As Int,X3 As Int ,W2 As Int, W3 As Int, H2 As Int, WidthofSquare As Int, Orange As Int,X4 As Int, OrangeB As Int , temp As Int,temp2 As Int, Blue As Int, BlueB As Int,Y2 As Int ,temp3 As Int
	LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
	'LCAR.CheckNumbersize(BG)
	Row = Height/12
	If Row< LCAR.ItemHeight Then
		LCAR.DrawUnknownElement(BG,X,Y,Width,Height, LCAR.LCAR_Orange, False, 255, API.GetString("resolution_too_low"))
		Return
	End If
	
	Orange= LCAR.GetColor(LCAR.LCAR_Orange, False,255)
	OrangeB= LCAR.GetColor(LCAR.LCAR_Orange, True,255)
	Blue= LCAR.GetColor(LCAR.Classic_Blue, False,128)
	BlueB= LCAR.GetColor(LCAR.Classic_Blue, True,-64)
	
	W3= Width/3
	X2=X+ W3
	W2=Width* (2/3)
	
	W3=W3/2.5
	X3=X2-W3-3
	H2=LCAR.ItemHeight*0.5
	WidthofSquare=(W2-W3)/7
	X4=X2+W3+3
	
	'top row
	temp=Row*2-H2-3
	LCAR.DrawRect(BG, X, Y+H2, W3*0.5, temp, OrangeB, 0)
	
	LCAR.DrawLCARelbow(BG,X3,Y+H2, W3*2, temp, W3,H2,  0, LCAR.LCAR_Orange, True , "", 0,255,False)
	If Not(AprilFoolsMode) Then 
		LCAR.DrawRect(BG, X4, Y+H2, WidthofSquare*4+2, H2, OrangeB, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4, Y+H2, WidthofSquare-3, H2*1.5, OrangeB , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*5, Y+H2, WidthofSquare*2-3, H2, OrangeB, 0)
	End If
	
	'first left col
	temp=Y+Row*5
	LCAR.DrawRect(BG, X3, Y+Row*2+LCAR.ItemHeight+3, W3, Row*3-LCAR.ItemHeight-6, OrangeB, 0)
	If Not(AprilFoolsMode) Then LCAR.DrawLCARbutton(BG, X3, temp,  W3, LCAR.ItemHeight, LCAR.LCAR_Orange, False , "856", "", 0,0, False, 0, 9,-1, 255,False)
	LCAR.DrawLCARbutton(BG, X, Y+Row*2+LCAR.ItemHeight+3,  W3*0.5, Row*4-LCAR.ItemHeight+H2-3, LCAR.LCAR_Orange, True , "47", "", 0,0, False, 0, 9,-1, 255,False)
	
	'final bit
	Y2=Y+Row*2
	If Not(AprilFoolsMode) Then LCAR.DrawLCARbutton(BG, X3, Y2,  W3, LCAR.ItemHeight, LCAR.LCAR_Orange, False , "314", "", 0,0, False, 0, 9,-1, 128,False)
	temp3=((W3*1.5)/3)-3
	For temp2 = 0 To 2
		LCAR.DrawRect(BG, X + ((temp3+3) * temp2), Y2, temp3,LCAR.ItemHeight , LCAR.GetColor(LCAR.LCAR_Orange, False,  API.IIFIndex(temp2, Array As Int(32,64,96 ) ) ), 0)
	Next
	
	'first row
	Y2=temp+3+LCAR.ItemHeight+(Row-H2-3)-H2
	If Not(AprilFoolsMode) Then 
		LCAR.DrawRect(BG, X3, temp+3+LCAR.ItemHeight,  W3, Row-H2-3, Orange, 0)
		LCAR.DrawRect(BG, X3+W3-1, Y2,  W3+2, H2, Orange, 0)
		
		'second row
		LCAR.DrawRect(BG, X4, Y2, WidthofSquare*4-3, H2, Blue, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4, Y2, WidthofSquare-3, H2*1.2, BlueB , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4.5, Y2+H2*0.25, WidthofSquare*0.4, H2*0.5, Colors.black , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*5, Y2, WidthofSquare*2-3, H2, Blue, 0)
	End If 
	
	'third row
	Y2=Y+Row*6.5+H2
	temp=Row-H2-3
	If Not(AprilFoolsMode) Then 
		LCAR.DrawLCARelbow(BG,X3,Y2, W3*2, Max(temp, H2+ LCAR.LCARCornerElbow2.Height)  , W3,H2,  0, LCAR.LCAR_Orange, True , "", 0,255,False)
		LCAR.DrawRect(BG, X3, Y2, W3, temp, OrangeB, 0)
		LCAR.DrawRect(BG, X4, Y2-H2*0.5, WidthofSquare*4+1, H2*1.5, Blue, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4, Y2-H2, WidthofSquare-3, H2*2, Blue, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4.5, Y2-H2*0.25, WidthofSquare*0.4, H2*0.5, Colors.black , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*5, Y2-H2*0.5, WidthofSquare*2-3, H2*1.5, Blue, 0)
	End If
	
	'second left col
	temp=temp+LCAR.ItemHeight+Row*0.25
	LCAR.DrawRect(BG, X, Y2, W3*0.5, temp, Blue, 0)
	Y2=Y2+temp-LCAR.ItemHeight
	temp2=X+W3*0.5-1
	LCAR.DrawRect(BG, temp2, Y2, W3*0.25, LCAR.ItemHeight, Blue, 0)
	LCAR.DrawRect(BG, temp2+W3*0.25+3, Y2, W3*0.25, LCAR.ItemHeight, Blue, 0)
	LCAR.DrawRect(BG, temp2+W3*0.5+6, Y2, W3*1.5-5, LCAR.ItemHeight, Orange, 0)
	
	'fourth row
	Y2=Y+Row*7.75+LCAR.ItemHeight
	LCAR.DrawLCARelbow(BG,X3,Y2, W3*2, LCAR.ItemHeight, W3,H2,  2, LCAR.LCAR_Orange, True , "", 0,255,False)
	Y2=Y2+LCAR.ItemHeight-H2
	If Not(AprilFoolsMode) Then
		LCAR.DrawRect(BG, X4, Y2, WidthofSquare*4+2, H2*0.75, OrangeB, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4, Y2, WidthofSquare-3, H2, OrangeB , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*5, Y2, WidthofSquare*2-3, H2*0.75, OrangeB, 0)
	End If
	
	'fifth row
	Y2=Y+Row*9.5
	temp=Y2+LCAR.ItemHeight+3
	LCAR.DrawRect(BG, X, Y2, W3*1.6, LCAR.ItemHeight, OrangeB, 0)
	LCAR.DrawRect(BG, X, temp, W3*0.5, Row*2.5 - LCAR.ItemHeight, Orange, 0)'NumberTextSize
	
	LCAR.DrawLCARelbow(BG,X3,Y2, W3*2, Row*2.5, W3,H2,  2, LCAR.LCAR_Orange, True , "", 0,255,False)
	Y2=Y2+Row*2.5-H2
	If Not(AprilFoolsMode) Then
		LCAR.DrawRect(BG, X4, Y2, WidthofSquare*4-3, H2, OrangeB, 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*4, Y2, WidthofSquare-3, H2, OrangeB , 0)
		LCAR.DrawRect(BG, X4+WidthofSquare*5, Y2, WidthofSquare*2-3, H2, OrangeB, 0)
	End If
	
	temp=API.iif(AprilFoolsMode,10,7)
	If AprilFoolsMode Then Y = Y + Row
	DrawLineofSquares(BG, X2, Y+Row, W2, LCAR.ItemHeight, 0, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	DrawLineofSquares(BG, X2, Y+Row*2, W2,LCAR.ItemHeight, 1, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	DrawLineofSquares(BG, X2, Y+Row*3, W2,LCAR.ItemHeight, 2, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	DrawLineofSquares(BG, X2, Y+Row*4, W2,LCAR.ItemHeight, 3, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	DrawLineofSquares(BG, X2, Y+Row*5, W2,LCAR.ItemHeight, 4, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	If AprilFoolsMode Then
		DrawLineofSquares(BG, X2, Y+Row*6, W2,LCAR.ItemHeight, 5, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
		DrawLineofSquares(BG, X2, Y+Row*7, W2,LCAR.ItemHeight, 6, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
		DrawLineofSquares(BG, X2, Y+Row*8, W2,LCAR.ItemHeight, 7, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
		DrawLineofSquares(BG, X2, Y+Row*9, W2,LCAR.ItemHeight, 8, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	Else
		DrawLineofSquares(BG, X2, Y+Row*7.75, W2,LCAR.ItemHeight, 5, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
		
		DrawLineofSquares(BG, X2, Y+Row*9.5, W2,LCAR.ItemHeight, 6, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
		DrawLineofSquares(BG, X2, Y+Row*10.5, W2,LCAR.ItemHeight, 7, Stage, LCAR.Classic_Blue,temp ,3,W3, AprilFoolsMode)
	End If
End Sub

Sub DrawLineofSquares(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, StartStage As Int, CurrentStage As Int, ColorID As Int, Squares As Int, WhiteSpace As Int,DoYellow As Int, AprilFoolsMode As Boolean)
	Dim temp As Int , WidthofSquare As Int  ,Alpha As Int ,Text As String,DoIt As Byte = 1, DoItA() As Byte 
	If DoYellow>3 Then 
		Width = Width-DoYellow-WhiteSpace
		If Not(AprilFoolsMode) Then LCAR.DrawLCARbutton(BG,X,Y,DoYellow-3,Height, LCAR.LCAR_Yellow, False, "", "", DoYellow-3,0,False, 0, 9,-1, 255, False)
		X=X+DoYellow+WhiteSpace
	End If
	
	WidthofSquare=(Width/Squares) - WhiteSpace
	CurrentStage=(CurrentStage+StartStage) Mod MaxSquareStages
	
	If AprilFoolsMode Then
		Select Case StartStage
			Case 0: 	DoItA = Array As Byte(1,1,1,1,1,1,2,0,1,0)
			Case 1: 	DoItA = Array As Byte(1,1,1,0,0,0,0,0,1,1)
			Case 2: 	DoItA = Array As Byte(1,1,1,0,0,0,0,0,1,1)
			Case 3: 	DoItA = Array As Byte(1,1,1,1,1,1,2,0,1,0)
			Case Else: 	DoItA = Array As Byte(1,1,1,0,0,0,0,0,0,0)
		End Select
	End If
	
	For temp = 1 To Squares
		Alpha= (CurrentStage/MaxSquareStages) * 255
		If AprilFoolsMode Then
			Select Case temp
				Case 2,4,6,7,10: Text = LCAR.LCAR_Block 
				Case Else: Text = ""
			End Select
		Else
			Text =  StartStage *16 + temp
		End If
		If AprilFoolsMode Then DoIt = DoItA(temp-1) 
		If DoIt =1 Then 
			LCAR.DrawLCARbutton(BG,X,Y,WidthofSquare,Height, ColorID, False, Text, "", 0,0,False, 0, 9,-1, Alpha, False)
		Else If DoIt=2 Then 
			LCAR.DrawLCARbutton(BG,X,Y,WidthofSquare*2+WhiteSpace,Height, ColorID, False, Text, "", 0,0,False, 0, 9,-1, Alpha, False)
		End If
		X=X+WidthofSquare+WhiteSpace
		CurrentStage=(CurrentStage+1) Mod MaxSquareStages
	Next
End Sub
