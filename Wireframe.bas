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
	Type Model3D(isClean As Boolean, Dots As List, Verteces As List, Name As String, Width As Int, Height As Int, SelectedPoint As Int)
	Type Point3D(Angle As Int, cX As Int, cY As Int, cZ As Int, Radius As Float, Z As Float)',X As Float, Y As Float
	Type Vertx3D(ColorID As Int, Points As List)
	Dim Models As List , Scaleto100 As Boolean = False, Solid As Boolean, MouseIsDown As Int = -1, IsLocked As Int', MouseX As Int, MouseY As Int '= True
	Dim Bits As List, BitWidth As Int = 4 'for the 3d sine wave
		
	Dim SVGs As List, Anchors As List,CardassianFont As Typeface, SVGFile As String, SVGscreen As Int = -1, LastUpdate As Long, ColorScheme As Long, CurrentAnimation As Long, NextAnimation As Long, CacheSize As Int, FirstFrame As Boolean
	Dim SelectedSVG As Int, SelectedSVGanchor As Int, CardassianKeytone As Int = 1
	Type Incrementor(Current As Int, Desired As Int, IsOffset As Boolean, Speed As Float, Acceleration As Float)
	Type Anchor(X As Int, Y As Int, AnchorTo As Int, AngleFromAnchor As Incrementor, Radius As Incrementor, AngleOrientation As Incrementor, Distance As Incrementor, SVGid As Int, ColorID As Int, Alpha As TweenAlpha, State As Boolean, FlipX As Boolean, FlipY As Boolean, LockedtoAnchor As Boolean, Delay As Int, LineToAnchor As Int, HasAnchor As Boolean, Brightness As Int, BrightnessType As Byte, Corner As Byte, CornerPercent As Byte, AbsoluteMode As Boolean, GroupID As Int)
	
	'TCARS
	Type RNDNum(Current As Int, Desired As Int, Minimum As Int, Maximum As Int)
	Dim RNDlist As List, TCARSfont As Typeface, TCARStext As List 
End Sub

public Sub CachePoints(X As Int, Y As Int, RadiusX As Int, RadiusY As Int, Angle As Int) As Point()
	Dim Points(4) As Point, PT1 As Point = Trig.findOvalXY2(0,0, RadiusX, RadiusY, Angle), PT2 As Point = Trig.findOvalXY2(0,0, RadiusX, RadiusY, (Angle+90) Mod 360)
	Points(0) = Trig.SetPoint(X + PT1.X, Y + PT1.Y)'top left
	Points(1) = Trig.SetPoint(X + PT2.X, Y + PT2.Y)'top right
	Points(2) = Trig.SetPoint(X - PT2.X, Y - PT2.Y)'bottom left
	Points(3) = Trig.SetPoint(X - PT1.X, Y - PT1.Y)'bottom right
	'2 and 3 are swapped to keep the points compatible with the SVG code
	Return Points
End Sub

Public Sub HandleMouse(Index As Int, EventType As Int, X As Int,Y As Int)
	Dim Element As LCARelement 
	'Wireframe.DrawVerteces(BG, X ,Y, Width, Height, ModelID, ColorID, State, Alpha, Angle=Element.LWidth, RadiusY=Element.RWidth, FullZ=Element.TextAlign)
	Select Case EventType 
		Case LCAR.Event_Down 
			MouseIsDown=Index
			'MouseX=X
			'MouseY=Y
		Case LCAR.Event_Up 
			MouseIsDown=-1
		Case LCAR.Event_Move
			'MouseX = MouseX + X
			'MouseY = MouseY + Y
			Element = LCAR.LCARelements.Get(Index)
			Element.LWidth = (Element.LWidth - X) Mod 360
			If Element.LWidth < 0 Then Element.LWidth = Element.LWidth + 360
			Element.RWidth = Max(0,Element.RWidth - Y)
		Case LCAR.LCAR_Dpad 'X: 0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
			Select Case Index
				Case 3: Element.LWidth = Trig.correctangle(Element.LWidth - 15)'left
				Case 1: Element.LWidth = Trig.correctangle(Element.LWidth + 15)'right
				Case 2: Element.RWidth = Max(0, Element.RWidth - 10)'down
				Case 0: Element.RWidth = Min(1000, Element.RWidth + 10)'up
				Case -1: IsLocked = API.iif(IsLocked = 0, 2000, 0)'X
			End Select
			If Index <> -1 Then IsLocked = 200
	End Select
End Sub

Public Sub IncrementElement(Element As LCARelement, ElementIndex As Int) As Boolean 
	Dim Model As Model3D , Inc As Int = 45, Old As Int = Floor(Element.LWidth / Inc)
	If IsLocked > 0 Then 
		IsLocked = IsLocked - 1
		Return False 
	End If
	If Element.Align <> 0 Then 'lwidth=angle, align=angle increment
		If MouseIsDown <> ElementIndex Then
			Element.LWidth = (Element.LWidth + Element.Align) Mod 360
			If Element.LWidth<0 Then Element.LWidth = Element.LWidth + 360
		End If
		
		Model =	GetModel(Element.Text, Element.SideText)
		If Floor(Element.LWidth / Inc) <> Old Then 
			Model.SelectedPoint = API.IIF(Model.SelectedPoint =-1 , Rnd(0, Model.Dots.Size), -1)
		End If
		Model.isClean=False
		Return True
	End If
End Sub

Public Sub PurgeModels
	Models.Initialize
	MouseIsDown=-1
End Sub

Public Sub FindModel(Dir As String, Filename As String) As Int 
	Dim temp As Int, Model As Model3D 
	If Not(Models.IsInitialized ) Then Models.Initialize 
	'Filename = File.Combine(Dir,Filename)
	For temp = 0 To Models.Size - 1 
		Model = Models.Get(temp)
		If Model.Name = Filename Then Return temp
	Next
	Return-1
End Sub
Public Sub GetModel(Dir As String, Filename As String) As Model3D 
	Dim temp As Int = FindModel(Dir,Filename) 
	If temp >-1 Then 
		Return Models.Get(temp)
	Else
		Models.Add(LoadModel(Dir,Filename))
		Return Models.Get(Models.Size-1)
	End If
End Sub 

Public Sub NewModel(Filename As String) As Model3D 
	Dim Model As Model3D
	Model.Initialize 
	Model.Dots.Initialize 
	Model.Verteces.Initialize
	Model.SelectedPoint=-1
	Model.Name = Filename
	Return Model
End Sub
Public Sub LoadModel(Dir As String, Filename As String) As Model3D 
	Dim tempstr() As String, temp As Int, CurrentSection As String, Key As String, Value As String, Model As Model3D ,CurrLine As String 
	If Dir.Length=0 Then
		If File.Exists(LCAR.DirDefaultExternal,Filename) Then 
			Dir = LCAR.DirDefaultExternal
		Else If File.Exists(File.DirAssets,Filename) Then
			Dir=File.DirAssets 
		End If
	End If
	If File.Exists(Dir,Filename) Then
		tempstr = Regex.Split(CRLF, File.ReadString(Dir, Filename))
		Model=NewModel(Filename)
'		Model.Initialize 
'		Model.Dots.Initialize 
'		Model.Verteces.Initialize
'		Model.SelectedPoint=-1
'		Model.Name = Filename'File.Combine(Dir,Filename)
		For temp = 0 To tempstr.Length -1 
			CurrLine = tempstr(temp)
			CurrLine = CurrLine.Trim 
			If API.Left(CurrLine,1) = "[" And API.Right(CurrLine,1) = "]" Then 'section
				CurrentSection = API.Mid(CurrLine,1,CurrLine.Length-2)
			Else
				Key=API.GetSide(CurrLine, "=",True, False) 
				Value=API.GetSide(CurrLine, "=",False, False)
				If IsNumber(Key) Then
					If CurrentSection = "dots" Then
						AddPoint(Model, MakePointFromValue(Value))
					Else
						AddVertexFromString(Model, Value)
					End If
				End If
			End If
		Next
	End If
	Return Model
End Sub

Public Sub AddPoint(Model As Model3D ,thePoint As Point3D) As Int 
    Model.Dots.Add(thePoint)
    Model.IsClean = False
	Return Model.dots.Size-1
End Sub

Public Sub MakePointFromValue(tempstr As String) As Point3D
	Dim tempstr2() As String = Regex.Split(",", tempstr), thePoint As Point3D 
    Return MakeAPoint(tempstr2(0) , tempstr2(1),tempstr2(2))'thePoint
End Sub
Public Sub MakeAPoint(Angle As Int, Radius As Float, Z As Float) As Point3D 
	Dim temp As Int = 500, thePoint As Point3D, tempPoint As Point = Trig.FindAnglePoint(temp,temp,Radius*temp,Angle)
	thePoint.Initialize 
	thePoint.Angle = Angle
    thePoint.Radius = Radius
	temp=temp*2
	'thePoint.X = tempPoint.X / temp
	'thePoint.Y = tempPoint.Y / temp
    thePoint.Z = Z
    Return thePoint
End Sub

Public Sub AddVertexFromString(Model As Model3D, Text As String)
    Dim tempstr() As String = Regex.Split(",", Text), temp As Int, VertexID As Int
    VertexID = AddVertex(Model, tempstr(0))
    For temp = 1 To tempstr.Length -1 
        AddDotToVertex(Model, VertexID, tempstr(temp))
    Next
End Sub

Public Sub AddVertex(Model As Model3D, ColorID As Int) As Int 'Public Verteces() As Vertex, VertexCount As int
    Dim Vertex As Vertx3D 
	Vertex.Initialize 
	Vertex.ColorID = ColorID
	Vertex.Points.Initialize 
	Model.Verteces.Add(Vertex)
    Model.IsClean = False
	Return Model.Verteces.Size - 1
End Sub

Public Sub AddDotToVertex(Model As Model3D, VertexID As Int, DotID As Int)
	Dim Vertex As Vertx3D  = Model.Verteces.Get(VertexID)
	Vertex.Points.Add(DotID)
    Model.IsClean = False
End Sub

'RadiusY and FullZ must be an integer percentage (0 to 100)
Public Sub CacheDots(Model As Model3D, Angle As Int, RadiusY As Int, FullZ As Int, Width As Int, Height As Int)
	Dim temp As Int, cDot As Point3D , CenterX As Int = 50 ,RadiusX As Int = 50, CenterY As Int = 100-RadiusY, Points() As Point, tempP As Point, A As Int
	If Not(Scaleto100) Then
		CenterX=Width*0.5
		RadiusX=CenterX
		CenterY=Height-RadiusY
	End If
	Points = CachePoints(CenterX, CenterY, RadiusX, RadiusY, Angle)
	
	For temp = 0 To Model.Dots.Size-1 
		cDot = Model.Dots.Get(temp)
		A = (cDot.Angle + Angle) Mod 360
		cDot.cX = Trig.findXYAngle(CenterX, CenterY, cDot.Radius * RadiusX, A, True)
		cDot.cY = Trig.findXYAngle(CenterX, CenterY, cDot.Radius * RadiusY, A, False)
		
		'tempP = CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), cDot.X, cDot.Y, False, False)
		'cDot.cX = tempP.X
		'cDot.cY = tempP.Y
		
		cDot.cZ = cDot.cY 
		If FullZ > 0 Then cDot.cY = cDot.cY - (FullZ*cDot.Z)
		If Scaleto100 Then
			cDot.cX = cDot.cX * 0.01
			cDot.cY = cDot.cY * 0.01
		End If
	Next
	Model.Width = Width
	Model.Height = Height
	Model.isClean=True 
End Sub

'DISABLED: returns which vertex is pointing closest to north (going by it's first point only)
Public Sub DrawVerteces(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Model As Model3D, Stroke As Int, State As Boolean, Alpha As Int, Angle As Int, RadiusY As Int, FullZ As Int, DoClear As Boolean ) As Int 
	Dim temp As Int, temp2 As Int, Color As Int, LastVertex As Int=-1, cVertex As Vertx3D , NeedsInit As Boolean' , Ret As Int = -1, RetD As Int =360
	If DoClear Then 
		LCARSeffects4.DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
		LCARSeffects.MakeClipPath(BG,X,Y,Width+1,Height+1)
	End If
	If Width <> Height Then
		temp = Min(Width,Height)
		X = X+ Width*0.5 - temp*0.5
		Y = Y+ Height*0.5-temp*0.5
		Width=temp
		Height=temp
	End If
	temp = Min(Width,Height) * 0.0625'0.5
	RadiusY = Min(temp, RadiusY)
	If Model.Width <> Width Or Model.Height <> Height Or Not(Model.isclean) Then
		FullZ = FullZ * 0.01 * Height
		If RadiusY > 0 Then
			temp2 = 90 - (RadiusY / temp * 90)
			FullZ = Trig.findXYAngle(0,0, FullZ, temp2 ,True)
		End If
		CacheDots(Model, Angle, RadiusY * 0.01 * Height, FullZ,Width,Height)
	End If
	'If Model.Width <> Width Or Model.Height <> Height Or Not(Model.isclean) Then  CacheDots(Model, Angle, RadiusY * 0.01 * Height, FullZ * 0.01 * Height,Width,Height)
	
	'Y=Y+ Height*(1-(FullZ*0.02))'0.5
	
'	If API.debugMode Then
'		LCARSeffects4.DrawRect(BG,X,Y,Width+1,Height+1,Colors.red,2)
'		temp=Y+ Height* (1-(RadiusY*0.01))
'		BG.DrawLine(X, temp,X+Width,temp,Colors.Red,2)
'	End If
	
	For temp = 0 To Model.Verteces.Size - 1
		cVertex = Model.Verteces.Get(temp)
		If cVertex.Points.Size>1 Then
			Color = LCAR.GetColor(cVertex.ColorID ,State,Alpha)
			'Dim P As Path 
			'For temp2 = 0 To cVertex.Points.Size - 2
			'	If cVertex.Points.Get(temp2+1) <> LastVertex Then
		'			NeedsInit = ConnectTheDots(BG, X,Y, Width, Height, Model, Color, cVertex.Points.Get(temp2), cVertex.Points.Get(temp2+1), Stroke, P, False, NeedsInit)
		'		End If
		'		LastVertex = cVertex.Points.Get(temp2)
		'	Next
		'	NeedsInit= ConnectTheDots(BG,X,Y, Width, Height, Model, Color, cVertex.Points.Get(cVertex.Points.Size-1), cVertex.Points.Get(0), Stroke, P, True, NeedsInit)
			NeedsInit = DrawVertex(BG,X,Y,Width,Height, Model, Color, Stroke,NeedsInit, cVertex)
			
'			temp2 = GetDistanceToNorth(Model, Angle, cVertex.Points.Get(0))
'			If Ret = -1 OR temp2< RetD Then 
'				Ret = temp
'				RetD= temp2
'			End If
		End If
	Next
	If Model.SelectedPoint>-1 And Not(Scaleto100) Then
		Dim Dot1 As Point3D = Model.Dots.Get(Model.SelectedPoint)
		Color = LCAR.GetColor(LCAR.LCAR_Orange,State,Alpha)
		BG.DrawLine(X, Y+Dot1.cy, X+Width, Y+Dot1.cy, Color,2)
		BG.DrawLine(X+Dot1.cX, Y, X+Dot1.cX, Y+Height, Color,2)
	End If
	If DoClear Then BG.RemoveClip 
	'Return Ret
End Sub

Sub DrawVertex(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Model As Model3D, Color As Int, Stroke As Int, NeedsInit As Boolean, cVertex As Vertx3D) As Boolean 
	Dim P As Path, LastVertex As Int = -1 
	For temp2 = 0 To cVertex.Points.Size - 2
		If cVertex.Points.Get(temp2+1) <> LastVertex Then
			NeedsInit = ConnectTheDots(BG, X,Y, Width, Height, Model, Color, cVertex.Points.Get(temp2), cVertex.Points.Get(temp2+1), Stroke, P, False, NeedsInit)
		End If
		LastVertex = cVertex.Points.Get(temp2)
	Next
	Return ConnectTheDots(BG,X,Y, Width, Height, Model, Color, cVertex.Points.Get(cVertex.Points.Size-1), cVertex.Points.Get(0), Stroke, P, True, NeedsInit)
End Sub

Sub GetDistanceToNorth(Model As Model3D, Angle As Int, DotID As Int) As Int 
	Dim TheDot As Point3D = Model.Dots.Get(DotID)
	Return Trig.AngleDifference(0, (Angle + TheDot.Angle) Mod 360, True)
End Sub

Public Sub DrawPoint(BG As Canvas, X As Int, Y As Int, Color As Int, Stroke As Int)
	Dim Size As Int = 3
	BG.drawline(X-Size,Y,X+Size+1,Y,Color,2)
	BG.DrawLine(X,Y-Size,X,Y+Size+1,Color,2)
End Sub
Public Sub ConnectTheDots(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Model As Model3D, Color As Int, DotID1 As Int, DotID2 As Int, Stroke As Int,P As Path, isLast As Boolean, NeedsInit As Boolean )As Boolean 
    Dim Dot1 As Point3D , Dot2 As Point3D 
	If DotID1 > -1 And DotID2 > -1 Then
		Dot1 = Model.Dots.Get(DotID1)
		Dot2 = Model.Dots.Get(DotID2)
		If Scaleto100 Then
			If Solid Or Stroke=0 Then
				MakePoint(P, X + Dot1.cX * Width,  Y+ Dot1.cY * Height, NeedsInit)
				MakePoint(P,  X + Dot2.cX * Width, Y+ Dot2.cY * Height, False)
				NeedsInit=False
			Else
				BG.DrawLine(X + Dot1.cX * Width,  Y+ Dot1.cY * Height, X + Dot2.cX * Width, Y+ Dot2.cY * Height, Color,Stroke) 
			End If
		Else
			If Solid Or Stroke=0 Then
				MakePoint(P, X + Dot1.cX ,  Y+ Dot1.cY , NeedsInit)
				MakePoint(P,  X + Dot2.cX , Y+ Dot2.cY , False)
				NeedsInit=False
			Else
				BG.DrawLine(X + Dot1.cX,  Y+ Dot1.cY, X + Dot2.cX, Y+ Dot2.cY, Color,Stroke) 
			End If
		End If
	Else
		isLast=True
    End If
	If isLast And P.IsInitialized Then	
		BG.DrawPath(P,Color,True,0)
		NeedsInit= True
	End If
	Return NeedsInit
End Sub
Public Sub MakePoint(P As Path, X As Int, Y As Int, NeedsInit As Boolean)
	If Not(P.IsInitialized) Or NeedsInit Then
		P.Initialize(X,Y)
	Else
		P.LineTo(X,Y)
	End If
End Sub

Sub CheckColor(ColorID As Int) As Int 
	If LCAR.RedAlert Then Return LCAR.RedAlertMode 
	Return ColorID
End Sub

Sub DrawRelativeRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	LCARSeffects4.DrawRect(BG, X-Width*0.5,Y-Height*0.5, Width,Height,Color,Stroke)
End Sub

'Assume 35 for RadiusY, a percentage of height
Sub Draw3Dwave(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, RingColorID As Int, WaveColorID As Int, RadiusY As Int, Stroke As Int)
	Dim temp As Int, ModelID As Int = FindModel(File.DirAssets, "sinewave"), Model As Model3D 
	LCARSeffects4.DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
	If Width <> Height Then
		temp = Min(Width,Height)
		X = X+ Width*0.5 - temp*0.5
		Y = Y+ Height*0.5-temp*0.5
		Width=temp
		Height=temp
	End If

	If ModelID = -1 Then ModelID = MakeSineModel(20, 10, 100, WaveColorID,30)
	Model = Models.Get(ModelID)
	Model.isClean = False 
	
	'background square
	temp = Width*0.05
	DrawVulcanSquare(BG,  X+temp,    Y,    Width-temp*2,   Height, Colors.White,4)
	
	'ring/halo
	temp= RadiusY * 0.01 * Height
	RingColorID = CheckColor(RingColorID)
	DrawBits(BG,X,Y,Width,Height, 360-Angle , temp, LCAR.GetColor(RingColorID,True, 255), LCAR.GetColor(RingColorID,False, 255), Stroke, True)', 0,360)
	
	'sine wave
	temp = Width*0.1
	X=X+temp
	Y=Y+temp
	Width=Width-temp*2
	Height= Height-temp*2
	temp = RadiusY * 0.01 * Height
	'North= DrawVerteces(BG,    X,    Y,    Width,   Height, Model,  Stroke,True,       255,     Angle,  RadiusY ,  RadiusY,   False)'wireframe
	CacheDots(Model, Angle,temp, temp,Width,Height)
	Draw3DModel(BG, X,    Y,    Width,   Height, Model, GetNorthernmostVertex(Model,Angle), Angle, False, Stroke)'3d model
End Sub

'Goes by the first point in the vertex
Sub GetNorthernmostVertex(Model As Model3D, Angle As Int)
	Dim temp As Int, cVertex As Vertx3D, Ret As Int = -1, RetD As Int =360, temp2 As Int
	For temp = 0 To Model.Verteces.Size - 1
		cVertex = Model.Verteces.Get(temp)
		If cVertex.Points.Size>1 Then
			temp2 = GetDistanceToNorth(Model, Angle, cVertex.Points.Get(0))
			If Ret = -1 Or temp2< RetD Then 
				Ret = temp
				RetD= temp2
			End If
		End If
	Next
	Return Ret
End Sub

Sub Draw3DModel(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Model As Model3D, North As Int, Angle As Int, State As Boolean, Stroke As Int)
	Dim cVertex As Vertx3D = Model.Verteces.Get(North), Down As Int= North, Up As Int= North, temp As Int , Color As Int = LCAR.GetColor(CheckColor(cVertex.ColorID), State, 255)
	DrawVertex(BG,X,Y,Width,Height, Model, CalculateColor(Model,Angle, cVertex, State), 0,True, cVertex)
	If Stroke>0 Then DrawVertex(BG,X,Y,Width,Height, Model, Color, Stroke,True, cVertex)
	For temp = 0 To Ceil( (Model.Verteces.Size-1) * 0.5)
		Down=Down-1 
		If Down<0 Then Down = Model.Verteces.Size-1
		cVertex = Model.Verteces.Get(Down)
		DrawVertex(BG,X,Y,Width,Height, Model, CalculateColor(Model,Angle, cVertex, State), 0,True, cVertex)
		If Stroke>0 Then DrawVertex(BG,X,Y,Width,Height, Model, Color, Stroke,True, cVertex)
		
		Up=Up+1
		If Up>Model.Verteces.Size-1 Then Up = 0 
		If Up <> Down Then
			cVertex = Model.Verteces.Get(Up)
			DrawVertex(BG,X,Y,Width,Height, Model, CalculateColor(Model,Angle, cVertex, State), 0,True, cVertex)
			If Stroke>0 Then DrawVertex(BG,X,Y,Width,Height, Model, Color, Stroke,True, cVertex)
		End If
	Next
End Sub

Sub CalculateColor(Model As Model3D, Angle As Int, cVertex As Vertx3D, State As Boolean) As Int
	Dim ThePoint As Point3D = Model.Dots.Get( cVertex.Points.Get(0)), ClosestAngle As Int, Difference As Int 
	Angle = (Angle + ThePoint.Angle) Mod 360
	ClosestAngle = Trig.ClosestAngle(Angle, 90)
	Difference = Trig.AngleDifference(Angle, ClosestAngle, False)'-45 to 45
	Return GetLCARScolor(CheckColor(cVertex.ColorID), State, 1+ (Difference / 90))
End Sub

'Brightness: 1=the same color as you put in
Sub GetLCARScolor(ColorID As Int, State As Boolean, Brightness As Float) As Int
	Dim Color As LCARColor = LCAR.LCARcolors.Get(ColorID)
	If State Then 
		Return GetColor(Color.sR, Color.sG, Color.SB, Brightness) 
	Else
		Return GetColor(Color.nR, Color.nG, Color.nB, Brightness) 
	End If
End Sub

'Brightness: 1=the same color as you put in
Sub GetColor(R As Int, G As Int, B As Int, Brightness As Float) As Int
	Return Colors.RGB(Max(0,Min(R*Brightness,255)), Max(0,Min(G*Brightness,255)), Max(0,Min(B*Brightness,255)))
End Sub

Sub DrawVulcanSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)
	Dim Size As Int = Width *0.075
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Color,Stroke)
	DrawVulcanGlyph(BG, X + Size, Y+10, Size, Size, Color, 4, 			Array As Byte(0,0,0,1,   1,1,1,1,   0,1,1,0,   0,0,0,0))
	DrawVulcanGlyph(BG, X + Width*0.318, Y+10, Size, Size, Color, 4, 	Array As Byte(1,1,1,1,   1,1,1,0,   0,1,1,1,   0,0,1,1))
	DrawVulcanGlyph(BG, X + Width*0.553, Y+10, Size, Size, Color, 4, 	Array As Byte(0,1,0,0,   0,0,1,1,   0,1,1,1,   1,0,0,0))
	DrawVulcanGlyph(BG, X + Width*0.787, Y+10, Size, Size, Color, 4, 	Array As Byte(0,1,0,1,   0,0,1,0,   0,0,0,0,   0,0,0,1))
	DrawVulcanGlyph(BG, X + Width-Size-10, Y+10, Size, Size, Color, 4, 	Array As Byte(0,1,1,1,   0,0,1,1,   0,0,1,1,   0,0,0,0))
End Sub
Sub DrawVulcanGlyph(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Cols As Int, Pixels() As Byte)
	Dim ColWidth As Int = Floor(Width / Cols), Rows As Int = Pixels.Length / Cols, RowHeight As Int = Floor(Height/Rows), temp As Int, oX As Int = X, Col As Int 
	For temp = 0 To Pixels.Length-1 
		Col = Col + 1
		If Pixels(temp) >0 Then LCARSeffects4.DrawRect(BG,X,Y,ColWidth,RowHeight, Color, 0)
		If Col = Cols Then 
			X=oX
			Y=Y+RowHeight
			Col=0
		Else
			X=X+ColWidth 
		End If
	Next
End Sub

Sub MakeSineModel(SpaceBetween As Int, internalRadius As Int, externalRadius As Int, ColorID As Int, AngleDiff As Int) As Int
	Dim Model As Model3D =NewModel("sinewave"), temp As Int , Angle As Int, PT1 As Int, PT2 As Int, Direction As Boolean=True, LastAngle As Int , Found As Boolean , First As Int 
	'AddVertex(Model, ColorID)'inner to outer ring connections
	'AddVertex(Model, ColorID)'inner ring
	'AddVertex(Model, ColorID)'outer ring
	For temp = 0 To 359 Step SpaceBetween		
		Found = temp >= 359 - SpaceBetween
		If Found Then AngleDiff=AngleDiff+1
		If Direction Then'up
			If Found Then LastAngle = Max(LastAngle,First)
			Angle = Rnd( Max(LastAngle, 90-AngleDiff), 91+AngleDiff)
		Else
			If Found Then LastAngle = Min(LastAngle,First)		
			Angle = Rnd(90-AngleDiff, Min(LastAngle,91+AngleDiff))
		End If
		If temp = 0 Then First = Angle 
		PT1 = AddPoint(Model, MakeAPoint(temp, internalRadius*0.01,0.5+ 0.01* Trig.findXYAngle(0,0, internalRadius, Angle, False )))'inner point
		PT2 = AddPoint(Model, MakeAPoint(temp, externalRadius*0.01,0.5+ 0.01* Trig.findXYAngle(0,0, externalRadius, Angle, False )))'outer point
		LastAngle = Angle
		Direction = Not(Direction)
	Next
'		Found=False
'		Do Until Found
'			If temp >= 359 - SpaceBetween Then 'LastAngle = First
'				If Direction Then LastAngle = Max(LastAngle,First) Else LastAngle = Min(LastAngle,First)			
'			End If 
'			Angle = Rnd(90-AngleDiff, 91+AngleDiff)
'			If temp = 0 Then First= Angle
'			Found =  (Direction AND Angle > LastAngle ) OR (Not(Direction) AND Angle < LastAngle)
'		Loop
				
		'LogColor("POINT: " & temp, Colors.Blue)
		'Log("INNER: " & MakeAPoint(temp, internalRadius*0.01, 0.01* Trig.findXYAngle(0,0, internalRadius, Angle, False )))
		'Log("OUTER: " & MakeAPoint(temp, externalRadius*0.01, 0.01* Trig.findXYAngle(0,0, externalRadius, Angle, False )))
		
		
		'AddDotToVertex(Model, 0, PT1)'inner to outer ring connections (inner)
		'AddDotToVertex(Model, 0, PT2)'inner to outer ring connections (outer)
		'AddDotToVertex(Model, 0, -1)'inner to outer ring connections (separator)
		'AddDotToVertex(Model, 1, PT1)'inner ring
		'AddDotToVertex(Model, 2, PT2)'outer ring
	'Next
	
	For temp = 0 To Model.Dots.Size-4 Step 2
		PT1 = AddVertex(Model, ColorID)
		AddDotToVertex(Model, PT1, temp)
		AddDotToVertex(Model, PT1, temp+1)
		AddDotToVertex(Model, PT1, temp+3)
		AddDotToVertex(Model, PT1, temp+2)
	Next
	PT1 = AddVertex(Model, ColorID)
	AddDotToVertex(Model, PT1, Model.Dots.Size-2)
	AddDotToVertex(Model, PT1, Model.Dots.Size-1)
	AddDotToVertex(Model, PT1, 1)
	AddDotToVertex(Model, PT1, 0)
	
	Models.Add(Model)
	Return Models.Size-1
End Sub

Sub Makebits
	If Not(Bits.IsInitialized) Then
		Dim Degrees As Int = 360 - BitWidth, temp As Int 
		Bits.Initialize 
		Do Until Degrees <= BitWidth
			temp = Min(Degrees, Rnd(1, 10))
			Degrees = Degrees - temp - BitWidth
			Bits.Add(temp)
		Loop
		'LCARSeffects.CacheAngles(Max(LCAR.ScaleWidth, LCAR.ScaleHeight)*2,-1)
	End If
	Return Bits.Size - 1
End Sub
Sub DoAngle(Angle As Int, AngleStart As Int, AngleFinish As Int) As Boolean 
	If AngleFinish > AngleStart Then 
		Return Angle >= AngleStart And Angle <= AngleFinish 
	Else
		Return Angle >= AngleStart Or Angle <= AngleFinish
	End If
End Sub

Sub DrawBits(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, RadiusY As Int, EdgeColor As Int, FillColor As Int, Stroke As Int, SkipLines As Boolean)', AngleStart As Int, AngleFinish As Int)
	Dim RadiusX As Int=Width*0.5, CenterX As Int=X + RadiusX, CenterY As Int =Y + Height-RadiusY, cX As Int, cY As Int, temp As Int , P As Path, RadiusY2 As Int= RadiusY * 0.8, RadiusX2 As Int = RadiusX * 0.8, Angle2 As Int 
	Dim TopLeft As Point, TopRight As Point, BottomLeft As Point, BottomRight As Point , Angle3 As Int = Angle
	If SkipLines Then P.Initialize(CenterX, CenterY)
	For temp = 0 To Makebits
		'If DoAngle(Angle, AngleStart, AngleFinish) Then
			Angle2=(Angle+BitWidth) Mod 360
			If SkipLines Then
				TopLeft = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX*2, RadiusY*2, Angle)
				TopRight = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX*2, RadiusY*2, Angle2)
				P.LineTo(TopLeft.X,TopLeft.Y)
				P.LineTo(TopRight.X, TopRight.Y)
				P.LineTo(CenterX, CenterY)
			Else
				TopLeft = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX, RadiusY, Angle)
				TopRight = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX, RadiusY, Angle2)
				BottomLeft = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX2, RadiusY2, Angle)
				BottomRight = Trig.FindAngleIndependPoint(CenterX, CenterY, RadiusX2, RadiusY2, Angle2)

				BG.DrawLine(TopLeft.X, TopLeft.Y, BottomLeft.X, BottomLeft.Y, EdgeColor, Stroke)
				BG.DrawLine(TopRight.X, TopRight.Y, BottomRight.X, BottomRight.Y, EdgeColor, Stroke)
			End If
		'End If
		Angle = (Angle2 + Bits.Get(temp)) Mod 360
	Next
	If SkipLines Then
		BG.ClipPath(P)
		LCARSeffects4.DrawOval(BG, CenterX, CenterY, Width, RadiusY*2, FillColor, 0, True)
		LCARSeffects4.DrawOval(BG, CenterX, CenterY, RadiusX2*2, RadiusY2*2, Colors.Black, 0, True)
		
		LCARSeffects4.DrawOval(BG, CenterX, CenterY, Width, RadiusY*2, EdgeColor, Stroke,  True)
		LCARSeffects4.DrawOval(BG, CenterX, CenterY, RadiusX2*2, RadiusY2*2, EdgeColor, Stroke,  True)
		
		BG.RemoveClip
		DrawBits(BG,X,Y,Width,Height,Angle3, RadiusY,EdgeColor,FillColor,Stroke,False)',AngleStart,AngleFinish)
	End If
End Sub











public Sub LoadCardassianINI(Screen As Int, Filename As String) As Map 
	Dim INI As Map, Screens As Int 
	SVGscreen=Screen 
	If WallpaperService.PreviewMode Then 
		Games.InitAudioPool(10)
		Select Case Filename 
			Case "cardassian"
				Games.InitAudioPool(5)
				For Screens = 0 To 6
					Games.LoadAudioFile2(File.DirAssets, "card" & Screens & ".ogg")
				Next
				Games.LoadAudioFile2(File.DirAssets, "beep4.ogg")
		End Select
	End If
	If File.Exists(LCAR.DirDefaultExternal, Filename & ".ini") Then 
		Log("LOADING BYPASS FILE")
		INI = API.LoadINI( File.ReadString(LCAR.DirDefaultExternal, Filename & ".ini"))
		SVGscreen=0
	Else
		Log("LOADING INTERNAL FILE: " & SVGscreen)
		If SVGscreen = -1 Then 
			Log("NOT SPECIFIED, RANDOMIZING")
			Select Case Filename
				Case "cardassian": Screens = 2
			End Select
			SVGscreen = API.dRnd(0,Screens, LCAR.CRD_Main)
		End If 
		If SVGscreen < 0 Then 
			INI = API.LoadINI( File.ReadString(File.DirAssets, Filename & ".ini"))
		Else 
			INI = API.LoadINI( File.ReadString(File.DirAssets, Filename & SVGscreen & ".ini"))
		End If 
	End If
	SVGFile= Filename
	Return INI 
End Sub

public Sub SetupCadassianSVGs(Screen As Int, Width As Int, Height As Int, Filename As String) As Typeface
	Dim A As Anchor, Size As Int = Min(Width,Height), INI As Map,INIS As Map, temp As Long
	If Not(CardassianFont.IsInitialized) Then CardassianFont = Typeface.LoadFromAssets("cardassian.ttf") 
	If Screen = -1 Or Screen <> SVGscreen Or SVGFile <> Filename Then 
		INI = LoadCardassianINI(Screen, Filename)
		SelectedSVG=-1
		SelectedSVGanchor=-1
		INIS = API.GetSection(INI, "system")
		ColorScheme = LCAR.LCAR_Random
		If Not(INIS.ContainsKey("colorschemeanchors")) And Not(INIS.ContainsKey("colorschemesvgs")) Then ColorScheme = INIS.GetDefault("colorscheme", LCAR.LCAR_Random)
		If INIS.ContainsKey("font") Then CardassianFont = Typeface.LoadFromAssets(INIS.Get("font")) 
		
		SVGs.Initialize
		INIS = API.GetSection(INI, "svgs")
		For temp= 0 To INIS.Size-1
			SVGs.Add(LoadSVG(INIS.GetValueAt( temp )))
		Next		
		
		If LoadAnimation(0, INI, Size, Filename, 200) Then 
			INIS = API.GetSection(INI, "system")
			If INIS.ContainsKey("scattersvgs") Then Scatter(False, INIS.Get("scattersvgs"), Size, INIS.GetDefault("delay", INIS.GetDefault("scatterdelay", INIS.GetDefault("scattersvgsdelay", -1))))
			If INIS.ContainsKey("scatteranchors") Then Scatter(True, INIS.Get("scatteranchors"), Size, INIS.GetDefault("delay", INIS.GetDefault("scatterdelay", INIS.GetDefault("scatteranchorsdelay", -1))))
			
			If INIS.ContainsKey("expandsvgs") Then Scatter(False, INIS.Get("expandsvgs"), 0, INIS.GetDefault("delay", INIS.GetDefault("expanddelay", INIS.GetDefault("expandsvgsdelay", -1))))
			If INIS.ContainsKey("expandanchors") Then Scatter(True, INIS.Get("expandanchors"), 0, INIS.GetDefault("delay", INIS.GetDefault("expanddelay", INIS.GetDefault("expandanchorsdelay", -1))))
			
			rangeaction2(2, INIS.GetDefault("colorscheme", LCAR.LCAR_Random), INIS, "colorscheme")
			rangeaction2(-1, 0, INIS, "flash")
			rangeaction2(1, 0, INIS, "falsestate")
			rangeaction2(1, 1, INIS, "truestate")
			rangeaction2(1, 2, INIS, "randomstate")
			
			'If INIS.ContainsKey("flashsvgs") Then Scatter(False, INIS.Get("flashsvgs"), -2, 1)
			'If INIS.ContainsKey("flashanchors") Then Scatter(True, INIS.Get("flashsanchors"), -2, 1)
			'If INIS.ContainsKey("fixedstatesvgs") Then rangeaction(1, 0, False, INIS.Get("fixedstatesvgs"))
			'If INIS.ContainsKey("fixedstateanchors") Then rangeaction(1, 0, True, INIS.Get("fixedstateanchors"))
			
			rangeaction2(3, 8, INIS, "slideup")
			rangeaction2(3, 2, INIS, "slidedown")
			rangeaction2(3, 4, INIS, "slideleft")
			rangeaction2(3, 6, INIS, "slideright")
			
			rangeaction2(4, 200, INIS, "accumulatedelay")
			
			For Size = 1 To 9
				rangeaction2(0, Size, INIS, "corner#" & Size)
				rangeaction2(0, -Size, INIS, "corner#-" & Size)
				
				'If INIS.ContainsKey("cornersvgs" & Size) Then rangeaction(0, Size, False, INIS.Get("cornersvgs" & Size))
				'If INIS.ContainsKey("cornersvgs-" & Size) Then rangeaction(0, -Size, False, INIS.Get("cornersvgs-" & Size))
				'If INIS.ContainsKey("corneranchors" & Size) Then rangeaction(0, Size, True, INIS.Get("corneranchors" & Size))
				'If INIS.ContainsKey("corneranchors-" & Size) Then rangeaction(0, -Size, True, INIS.Get("corneranchors-" & Size))
			Next
		End If 
		
		'SVGscreen=Screen
		CRD_AssignGroups(API.GetSection(INI, "groups"))
		CacheSize = Max(CacheSize, 256)
		LCARSeffects2.InitUniversalBMP(CacheSize,CacheSize, LCAR.CRD_Main)
	End If 
	Return CardassianFont
End Sub

public Sub LoadAnimation(Index As Long, INI As Map, Size As Long, Filename As String, InitialDelay As Int) As Boolean 'NextAnimation
	Dim INIS As Map, RET As Boolean 
	If INI = Null Then INI = LoadCardassianINI(SVGscreen, Filename)
	CurrentAnimation=Index 
	NextAnimation=0
	FirstFrame=True 
	If Index = 0 Then Anchors.Initialize
	LastUpdate = DateTime.Now 
	INIS = API.GetSection(INI, "animation" & API.iif(Index=0, "", Index) )
	For temp= 0 To INIS.Size-1
		If IsNumber(INIS.GetKeyAt(temp)) Then 
			StringToAnchor(INIS.GetValueAt(temp), Size, INIS.GetKeyAt(temp), InitialDelay)
			RET=True 
		Else
			Select Case API.lCase(INIS.GetKeyAt(temp))
				Case "delay"
					NextAnimation = INIS.GetValueAt(temp)
			End Select
		End If 
	Next
	Return RET 
End Sub

Public Sub RemoveComment(Text As String) As String
	Dim temp As Long = Text.IndexOf("'")
	If temp > -1 Then Text = API.Left(Text, temp)
	Return Text.Trim 
End Sub

public Sub LoadSVG(Text As String) As List 
	Dim tempstr() As String = Regex.Split("\|", RemoveComment(Text)), SVG As List, temp As Int , temp2 As Int 
	SVG.Initialize
	Try 
		For temp = 0 To tempstr.Length -1
			Dim tempstr2() As String = Regex.Split(",", tempstr(temp))
			Dim SVG_BIT(tempstr2.Length) As Float 
			For temp2 = 0 To tempstr2.Length-1
				SVG_BIT(temp2) = tempstr2(temp2)
			Next
			SVG.Add(SVG_BIT)
		Next
	Catch
		LogColor("LoadSVG: " & SVGs.Size & " - " & Text, Colors.Red)
		LogColor("Error at: " & temp & " - " & tempstr(temp), Colors.Red)
		SVG.Initialize
	End Try
	Return SVG
End Sub

public Sub Add1Point(P As Path, Points() As Point, Data() As Float, FlipX As Boolean, FlipY As Boolean)
	Dim CurrentPoint As Point = CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), Data(0), Data(1), FlipX, FlipY)
	LCARSeffects3.MakePoint(P, CurrentPoint.x, CurrentPoint.Y)
End Sub

'shortcuts for drawSVG
public Sub SVGflags(FlipX As Boolean, FlipY As Boolean, SmallerEdge As Boolean, DrawBoundary As Boolean, CenterX As Boolean, CenterY As Boolean) As Int 
	Dim Flags As Int
	If FlipX Then Flags = 1
	If FlipY Then Flags = Flags + 2
	If SmallerEdge Then Flags = Flags + 4
	If DrawBoundary Then Flags = Flags + 8
	If CenterX Then Flags = Flags + 16
	If CenterY Then Flags = Flags + 32
	Return Flags
End Sub
public Sub DrawSVG3(BG As Canvas, Dimensions As Rect, Filename As String, SVGid As Int, Angle As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, FontID As Int, Flags As Int) 
	DrawSVG2(BG, Dimensions.Left, Dimensions.Top, Dimensions.Right-Dimensions.Left, Dimensions.Bottom-Dimensions.Top, Filename,SVGid,Angle,ColorID,State,Alpha,Stroke,FontID,Flags)
End Sub
'Flags: 112 is undistorted
public Sub DrawSVG2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Filename As String, SVGid As Int, Angle As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, FontID As Int, Flags As Int) 
	Dim Radius As Int, SmallerEdge As Boolean, FlipX As Boolean, FlipY As Boolean, DrawSquare As Boolean, Font As Typeface, CenterX As Boolean, CenterY As Boolean
	FlipX =  Bit.And(Flags, 1) = 1
	FlipY = Bit.And(Flags, 2) = 2
	SmallerEdge = Bit.And(Flags, 4) = 4
	If SmallerEdge Then 
		Radius = Min(Width,Height) * 0.5
	Else 
		Radius = Max(Width,Height) * 0.5
	End If
	DrawSquare= Bit.And(Flags,8) = 8
	CenterX = Bit.And(Flags,16) = 16
	CenterY = Bit.And(Flags,32) = 32
	
	If DrawSquare Then LCAR.DrawRect(BG,X,Y,Width,Height, Colors.Red, 0)
	Font = SetupCadassianSVGs(-2, Radius,Radius, Filename)
	If Not(CenterX) Then X = X+Width*0.5
	If Not(CenterY) Then Y = Y+Height*0.5

	If Bit.And(Flags,64) = 64 Then 
		DrawSVGwh(BG, X,Y,Width,Height, SVGid, ColorID, State, Alpha, Stroke, Font, 10, FlipX, FlipY, 0.1)
	Else 
		DrawSVG(BG, X,Y, SVGid, Radius, Angle, ColorID,State,Alpha, Stroke, Font, LCAR.Fontsize, FlipX,FlipY, 0.01)
	End If 
End Sub

'Draws an SVG centered at X,Y, rotated by angle (enforced square aspect ratio)
public Sub DrawSVG(BG As Canvas, X As Int, Y As Int, SVGid As Int, Radius As Int, Angle As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, Font As Typeface, TextSize As Float,FlipX As Boolean, FlipY As Boolean, CurveDT As Float) As Point()
	Dim Points(4) As Point, P As Path 
	If Angle = -1 Then 
		Points(0) = Trig.SetPoint(X-Radius,Y-Radius)'top left
		Points(1) = Trig.SetPoint(X+Radius,Y-Radius)'top right
		Points(2) = Trig.SetPoint(X-Radius,Y+Radius)'bottom left
		Points(3) = Trig.SetPoint(X+Radius,Y+Radius)'bottom right
	Else
		Points(0) = Trig.FindAnglePoint(x, y, Radius, Angle - 45)'top left
	    Points(1) = Trig.FindAnglePoint(x, y, Radius, Angle + 45)'top right
	    Points(2) = Trig.FindAnglePoint(x, y, Radius, Angle - 135)'bottom left
	    Points(3) = Trig.FindAnglePoint(x, y, Radius, Angle + 135)'bottom right
	End If
	Return DrawSVGloc(BG,P, Points, SVGid, Radius, Angle, ColorID, State,Alpha, Stroke, Font,TextSize,FlipX,FlipY,CurveDT)
End Sub

'Draws an SVG filling X,Y,Width,Height (allows for distorted aspect ratios)
public Sub DrawSVGwh(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SVGid As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, Font As Typeface, TextSize As Float,FlipX As Boolean, FlipY As Boolean, CurveDT As Float) As Point()
	Dim P As Path 
	Return DrawSVGwh2(BG,P, X, Y, Width, Height, SVGid, ColorID, State, Alpha, Stroke, Font,TextSize,FlipX,FlipY,CurveDT)
End Sub
'Allows for the injection of a path, use color ID -2 to not draw or clip the path
public Sub DrawSVGwh2(BG As Canvas, P As Path, X As Int, Y As Int, Width As Int, Height As Int, SVGid As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, Font As Typeface, TextSize As Float,FlipX As Boolean, FlipY As Boolean, CurveDT As Float) As Point()
	Dim Points(4) As Point, Radius As Int = Min(Width,Height)*0.5
	Points(0) = Trig.SetPoint(X,Y)'top left
	Points(1) = Trig.SetPoint(X+Width,Y)'top right
	Points(2) = Trig.SetPoint(X,Y+Height)'bottom left
	Points(3) = Trig.SetPoint(X+Width,Y+Height)'bottom right
	Return DrawSVGloc(BG,P, Points, SVGid, Radius, 0, ColorID, State, Alpha, Stroke, Font,TextSize,FlipX,FlipY,CurveDT)
End Sub

'Draws an SVG within the points() box (ColorID=-1 will merely clip the path, -2 will do nothing)
public Sub DrawSVGloc(BG As Canvas, P As Path, Points() As Point, SVGid As Int,Radius As Int, Angle As Int, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int, Font As Typeface, TextSize As Float,FlipX As Boolean, FlipY As Boolean, CurveDT As Float) As Point()
	Dim CurrentMode As Int, FirstPoint As Int=-1, CurrentPointID As Int, Data() As Float, CurrentPoint As Point, JustRemoved As Boolean ', PreviousPoint As Int
	Dim SVG As List = SVGs.Get(SVGid), P As Path, Disabled As Int, PrevData() As Float, GrabbedPoints As List , Color As Int = LCAR.GetColor(ColorID,State,Alpha)', ReturnPoints As List
	Try 
		For CurrentPointID = 0 To SVG.Size - 1 
			Data = SVG.Get(CurrentPointID)
			If Data(0) < 0 Then 
				Select Case Data(0)
					Case -1'tool change
						CurrentMode = Data(1)
						Select Case CurrentMode 
							Case 2'remove clip
								BG.RemoveClip 
								JustRemoved = True
								CurrentMode = 0'lines
							Case 5'break
								If Stroke <> 0 And Not(JustRemoved) And FirstPoint > -1 Then Add1Point(P, Points, SVG.Get(FirstPoint), FlipX, FlipY)
								P = DrawPath(BG, P, ColorID, State, Alpha, Stroke)
								CurrentMode = 0'lines
								FirstPoint = -1
						End Select
					'Case -2'close path	
					'	BG.DrawPath(P, Color, Stroke = 0, Stroke)
					Case -2'color change
						ColorID = Data(1)
						Color = LCAR.GetColor(ColorID,State,Alpha)
					Case -3'font change
						Font = LCAR.GetStyleFont(Data(1)) 
					Case -5'stroke change
						Stroke = Data(1)
				End Select
				PrevData = Data 
			Else 
				If FirstPoint = -1 Then FirstPoint = CurrentPointID
				CurrentPoint = CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), Data(0), Data(1), FlipX, FlipY)
				If Disabled = 0 Then 
					'If CurrentMode=0 Or (CurrentMode > 0 And FirstPoint > -1) Then
						Select Case CurrentMode
							Case 0'lines
								LCARSeffects3.MakePoint(P, CurrentPoint.x, CurrentPoint.Y)
							Case 1'curves
								GrabbedPoints = GrabPoints(SVG, CurrentPointID+1, 2,Points,FlipX,FlipY,FirstPoint)
								Dim PT2 As Point = GrabbedPoints.Get(0), PT3 As Point = GrabbedPoints.Get(1)
								LCARSeffects4.MakeCurvePath( CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, PT3.X,PT3.Y, 1/CurveDT,P)
								Disabled=1
							Case 3'text
								BG.DrawTextRotated(Chr(PrevData(2)), CurrentPoint.X, CurrentPoint.Y, Font, TextSize, ColorID, "CENTER", Angle) 
							Case 4,7,8'oval, rectangle, circle
								Dim PT2 As Point = GrabPointsSize(SVG, CurrentPointID, Radius, FirstPoint)
								DrawShape(BG, CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, Stroke, Color, Angle, CurrentMode)
								Disabled=2
							Case 6'bicubic curve
								If CurrentPointID < SVG.Size - 3 Then 
									GrabbedPoints = GrabPoints(SVG, CurrentPointID+1, 3, Points,FlipX,FlipY,FirstPoint)
									Dim PT2 As Point = GrabbedPoints.Get(0), PT3 As Point = GrabbedPoints.Get(1), PT4 As Point = GrabbedPoints.Get(2)
									Bicubic(P, CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, PT4.X, PT4.Y, PT3.X, PT3.Y, CurveDT)
									Disabled = BicubicDisabled(SVG, CurrentPointID)
								End If 
						End Select 
					'End If 
				Else 
					Disabled = Disabled - 1
				End If 
				'PreviousPoint = CurrentPointID
				JustRemoved=False
			End If
		Next
	Catch 
		LogColor("ERROR AT: " & SVGid & "." & CurrentPointID & ": " & LastException.Message, Colors.Red)
	End Try 
	If Stroke <> 0 And Not(JustRemoved) And FirstPoint>-1 Then Add1Point(P, Points, SVG.Get(FirstPoint), FlipX, FlipY)
	If ColorID=-1 Then 
		BG.ClipPath(P)
	Else if ColorID <> -2 Then 
		DrawPath(BG, P, ColorID, State, Alpha, Stroke)
		BG.RemoveClip 
	End If
	Return Points
End Sub

public Sub BicubicDisabled(SVG As List, Start As Int) As Int 
	If SVG.Size-1 >= Start + 4 Then
        Dim Data() As Float = SVG.Get(Start + 4)
        If Data(0) < 0 Then Return 3
    End If	
	Return 2 
End Sub

'Shape: 4=oval,7=rectangle,8=circle
public Sub DrawShape(BG As Canvas, X As Int, Y As Int, RadiusX As Int, RadiusY As Int, Stroke As Int, Color As Int, Angle As Int, Shape As Int)
	Dim Dest As Rect = LCARSeffects4.SetRect(X-RadiusX,Y-RadiusY,RadiusX*2,RadiusY*2)
	Select Case Shape
		Case 4: BG.DrawOvalRotated(Dest, Color, Stroke=0, Stroke, Angle)'oval
		Case 7: BG.DrawRectRotated(Dest,Color, Stroke=0, Stroke,Angle)'rectangle
		Case 8: BG.DrawCircle(X,Y, Min(RadiusX, RadiusY), Color, Stroke=0,Stroke)'circle
	End Select
End Sub

public Sub GrabPointsSize(SVG As List, Start As Int, Radius As Int, FirstPoint As Long) As Point 
	Dim Size As Int, Data() As Float, Points(3) As Point, Width As Int, Height As Int, Factor As Float = 1.4
	Do Until Size = 3 
		Data = SVG.Get(Start)
		If Data(0) >= 0 Then 
			Points(Size) = Trig.setpoint(CalculatePoint(0, Radius, Data(0)), CalculatePoint(0, Radius, Data(1)))
			Size = Size + 1
		End If
		Start = Start+ 1
		If Start = SVG.Size Then Start = FirstPoint 
	Loop
	Width = Max( Distance(Points(0).X, Points(1).X), Distance(Points(0).X, Points(2).X)) * Factor 
	Height= Max( Distance(Points(0).y, Points(1).y), Distance(Points(0).y, Points(2).y)) * Factor
	Return Trig.SetPoint(Width,Height)
End Sub
public Sub Distance(Start As Int, Point As Int) As Int 
	If Point > Start Then Return Point-Start Else Return Start-Point 
End Sub
public Sub GrabPoints(SVG As List, Start As Int, NumberOfPoints As Int, Points() As Point, FlipX As Boolean, FlipY As Boolean, FirstPoint As Int) As Point()
	Dim ReturnPoints(NumberOfPoints) As Point, Data() As Float, CurrentPoint As Int 
	Do Until CurrentPoint = NumberOfPoints 
		Data = SVG.Get(Start)
		If Data(0) >= 0 Then 
			ReturnPoints(CurrentPoint) = CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), Data(0), Data(1),FlipX,FlipY)
			CurrentPoint=CurrentPoint+1
		End If
		Start = Start+ 1
		If Start = SVG.Size Then Start = FirstPoint 
	Loop
	Return ReturnPoints
End Sub
public Sub DrawPath(BG As Canvas, P As Path, ColorID As Int, State As Boolean, Alpha As Int, Stroke As Int)As Path 
	Dim P2 As Path, DebugMode As Boolean = False
	If P.IsInitialized Then 
		If DebugMode Then 
			If Stroke < 0 Then 
				BG.ClipPath(P)
				ColorID = LCAR.LCAR_Orange 
				Stroke = 3
			End If 
			If Stroke > -1 Or API.debugMode Then BG.DrawPath(P, LCAR.GetColor(ColorID, State, Alpha), Stroke = 0, Stroke)
		Else 
			If Stroke < 0 Then 
				BG.ClipPath(P)
			Else	
				BG.DrawPath(P, LCAR.GetColor(ColorID, State, Alpha), Stroke = 0, Stroke)
			End If 
		End If 
	End If 
	Return P2
End Sub
Public Sub CalculatePoint(PT1 As Int, PT2 As Int, Percent As Float) As Int 
	Return (PT2 - PT1) * Percent + PT1
End Sub 
public Sub CalculatePointXY(PT1 As Point, PT2 As Point, Percent As Float) As Point
	Return Trig.setpoint( CalculatePoint(PT1.X, PT2.X, Percent), CalculatePoint(PT1.y, PT2.y, Percent))
End Sub
public Sub CalculatePointXY2(TopLeft As Point, TopRight As Point, BottomLeft As Point, BottomRight As Point, PercentX As Float, PercentY As Float, FlipX As Boolean, FlipY As Boolean) As Point
	If FlipX Then PercentX = 1-PercentX
	Dim PT1 As Point = CalculatePointXY(TopLeft, TopRight, PercentX), PT2 As Point = CalculatePointXY(BottomLeft, BottomRight, PercentX)
	If FlipY Then PercentY = 1-PercentY
	Return CalculatePointXY(PT1,PT2, PercentY)
End Sub

public Sub Bicubic(P As Path, X1 As Int, Y1 As Int, aX1 As Int, aY1 As Int, X2 As Int, Y2 As Int, aX2 As Int, aY2 As Int, Increment As Float)
	Dim Percent As Float, X3 As Int, Y3 As Int, X4 As Int, Y4 As Int
	If Increment <= 0 Then Increment = 0
	LCARSeffects3.MakePoint(P, X1, Y1)
	Do Until Percent > 1
		X3 = CalculatePoint(X1, aX1, Percent)
        Y3 = CalculatePoint(Y1, aY1, Percent)
		
        X4 = CalculatePoint(aX2, X2, Percent)
        Y4 = CalculatePoint(aY2, Y2, Percent)
        
        X3 = CalculatePoint(X3, X4, Percent)
        Y3 = CalculatePoint(Y3, Y4, Percent)
        LCARSeffects3.MakePoint(P, X3, Y3)
		Percent=Percent+Increment 
	Loop 
	LCARSeffects3.MakePoint(P, X2, Y2)
End Sub
public Sub Bicubic2(Ret As List, X1 As Int, Y1 As Int, aX1 As Int, aY1 As Int, X2 As Int, Y2 As Int, aX2 As Int, aY2 As Int, Increment As Float) 
	Dim Percent As Float, X3 As Int, Y3 As Int, X4 As Int, Y4 As Int
	If Increment <= 0 Then Increment = 0
	If Not(Ret.IsInitialized) Then Ret.Initialize
	Ret.Add(Trig.SetPoint(X1, Y1))
	Do Until Percent > 1
		X3 = CalculatePoint(X1, aX1, Percent)
        Y3 = CalculatePoint(Y1, aY1, Percent)
		
        X4 = CalculatePoint(aX2, X2, Percent)
        Y4 = CalculatePoint(aY2, Y2, Percent)
        
        X3 = CalculatePoint(X3, X4, Percent)
        Y3 = CalculatePoint(Y3, Y4, Percent)
        Ret.Add(Trig.SetPoint(X3, Y3))
		Percent=Percent+Increment 
	Loop 
	Ret.Add(Trig.SetPoint(X2, Y2))
End Sub

Sub DrawCardassian(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Element As LCARelement)
	Dim temp As Int, temp2 As Int, CurrentAnchor As Anchor, Font As Typeface = SetupCadassianSVGs(Element.RWidth,Width,Height, Element.Text), Angle As Int, Color As Long, DoDraw As Boolean, Alpha As Int, Points() As Point  
	Dim BG2 As Canvas, temp3 As Int, Percent As Float, State As Boolean
	If LCARSeffects2.CenterPlatform.IsInitialized Then BG2.Initialize2(LCARSeffects2.CenterPlatform)
	If Element.LWidth = 0 Then IncrementCardassian(Width,Height, Element)
	LCAR.ActivateAA(BG,True)
	Element.RWidth =  SVGscreen
	For temp = 0 To Anchors.Size -1 
		CurrentAnchor = Anchors.Get(temp)
		If CurrentAnchor.LockedtoAnchor Then 
			Angle = 360-CurrentAnchor.AngleFromAnchor.Current + CurrentAnchor.AngleOrientation.Current
		Else
			Angle = CurrentAnchor.AngleOrientation.Current
		End If
		If CurrentAnchor.Alpha.Current > 0 Then 
			State = CurrentAnchor.State
			If temp = SelectedSVG Then
				State = Not(State)
			else if CurrentAnchor.AnchorTo > -1 And CurrentAnchor.AnchorTo = SelectedSVGanchor Then 
				State = Not(State)
			else if CurrentAnchor.GroupID > -1 And CurrentAnchor.GroupID = SelectedSVGanchor Then 
				State = Not(State)
			End If 
			
			If CurrentAnchor.Brightness = 0 Then 
				Alpha = CurrentAnchor.Alpha.Current
			Else 
				Alpha = -CurrentAnchor.Brightness
			End If 
			
			If CurrentAnchor.LineToAnchor > 0 Or CurrentAnchor.SVGid < 0 Then
				Color =  LCAR.GetColor(CurrentAnchor.ColorID, State, Alpha)
			End If 
			'DoDraw = True 
			'If API.debugMode Then 
			'	DoDraw = CurrentAnchor.HasAnchor Or CurrentAnchor.AnchorTo > -1 
			'End If 
			'If DoDraw Then 
				DrawAnchorLine(BG, X,Y,Width,Height, CurrentAnchor, Color)
				If CurrentAnchor.SVGid < 0 Then'circle
					If CurrentAnchor.Radius.Current > 0 Then 
						Angle = Abs(CurrentAnchor.SVGid)-1
						BG.DrawCircle(X+CurrentAnchor.X,  Y+CurrentAnchor.Y, CurrentAnchor.Radius.Current, Color,  Angle=0, Angle)
					End If 
				Else if CurrentAnchor.Corner = 0 Or CurrentAnchor.CornerPercent = 100 Then 'regular
					DrawSVG(BG, X+CurrentAnchor.X,  Y+CurrentAnchor.Y, CurrentAnchor.SVGid, CurrentAnchor.Radius.Current, Angle, CurrentAnchor.ColorID, State, Alpha, 0, Font, 12, CurrentAnchor.FlipX,CurrentAnchor.FlipY, 0.1)
				else if CurrentAnchor.CornerPercent <> 0 Then'bleeding clip path
					'Log("Drawing bleeding corner: " & CurrentAnchor.Corner & " " & CurrentAnchor.CornerPercent & "%")
					temp2 = CurrentAnchor.Radius.Current * 4
					If temp2 > CacheSize Then 
						CacheSize = temp2   
						BG2 = LCARSeffects2.InitUniversalBMP(CacheSize,CacheSize, LCAR.CRD_Main)
					End If 
					Dim P As Path
					Percent = CurrentAnchor.CornerPercent * 0.01
					temp2 = CacheSize * 0.5'Points: 0=top left, 1=top right, 2=bottom left, 3=bottom right
					BG2.DrawColor(Colors.Transparent)
					Points = DrawSVG(BG2, temp2,temp2, CurrentAnchor.SVGid, CurrentAnchor.Radius.Current, Angle, CurrentAnchor.ColorID, State, Alpha, 0, Font, 12, CurrentAnchor.FlipX,CurrentAnchor.FlipY, 0.1)
					For temp3 = 0 To 3 
						Points(temp3).X = Points(temp3).X - temp2 + X + CurrentAnchor.X
						Points(temp3).Y = Points(temp3).Y - temp2 + Y + CurrentAnchor.Y
					Next
					Select Case Abs(CurrentAnchor.Corner) 
						Case 4'left to right
							Add1Point(P, Points, Array As Float(0,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(Percent,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(Percent,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(0,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
						Case 8'top to bottom
							Add1Point(P, Points, Array As Float(0,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1,Percent), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(0,Percent), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
						Case 6'right to left
							Add1Point(P, Points, Array As Float(1,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1-Percent,0), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1-Percent,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
						Case 2'bottom to top 
							Add1Point(P, Points, Array As Float(0,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1,1), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(1,1-Percent), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
							Add1Point(P, Points, Array As Float(0,1-Percent), CurrentAnchor.FlipX,CurrentAnchor.FlipY)
					End Select
					BG.ClipPath(P)
					BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCARSeffects4.SetRect( X+CurrentAnchor.X-temp2, Y+CurrentAnchor.Y-temp2, LCARSeffects2.CenterPlatform.Width, LCARSeffects2.CenterPlatform.Height))
					BG.RemoveClip
				End If 
			'End If 
		End If 
	Next
	LCAR.ActivateAA(BG,False)
End Sub

Sub DrawAnchorLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CurrentAnchor As Anchor, Color As Long) As Point 
	Dim AnchoredTo As Anchor,X2 As Long, Y2 As Long 
	If CurrentAnchor.AnchorTo < 0 Then
		X2= Width*0.5
		Y2= Height*0.5
	Else
		AnchoredTo = Anchors.Get(CurrentAnchor.AnchorTo)
		X2 = AnchoredTo.X 
		Y2 = AnchoredTo.Y
	End If
	X2=X+ X2
	Y2=Y+Y2
	If CurrentAnchor.LineToAnchor > 0 Then 
		BG.DrawLine(X2,Y2, X+CurrentAnchor.X,  Y+CurrentAnchor.Y, Color, CurrentAnchor.LineToAnchor)
	End If 
	Return Trig.SetPoint(X2,Y2)
End Sub

Sub AnchorIsMoving(A As Anchor) As Boolean 
	If A.Distance.IsOffset Then Return A.Distance.desired <> 0 
	Return A.Distance.Desired <> A.Distance.Current 
End Sub

Sub IncrementCardassian(Width As Int, Height As Int, Element As LCARelement) 
	Dim temp As Int, CurrentAnchor As Anchor, X As Int, Y As Int, AnchoredTo As Anchor, TimeDifference As Int, DidMove As Boolean , Size As Int = Min(Width,Height)
	Dim NC1 As Int, NC2 As Int, Left As Int = Width * 0.5 - Size * 0.5, Top As Int = Height * 0.5 - Size * 0.5, IsNewSecond As Boolean = DateTime.GetSecond(LastUpdate) <> DateTime.GetSecond(DateTime.Now)
	If LastUpdate > 0 And DateTime.Now - LastUpdate < DateTime.TicksPerSecond Then TimeDifference = DateTime.Now - LastUpdate
	If IsNewSecond Then NC1 = LCAR.LCAR_RandomColor
	For temp = 0 To Anchors.Size -1
		CurrentAnchor = Anchors.Get(temp)
		If CurrentAnchor.Delay = 0 Or FirstFrame Then 
			If CurrentAnchor.Delay = 0 Then 
				If CurrentAnchor.Alpha.Current <> CurrentAnchor.Alpha.Desired Then DidMove = True 
				CurrentAnchor.Alpha.Current = LCAR.Increment(CurrentAnchor.Alpha.Current, LCAR.Alphaspeed, CurrentAnchor.Alpha.Desired)
				If IncrementIncrementor(CurrentAnchor.AngleFromAnchor,Not(CurrentAnchor.AbsoluteMode)) Then DidMove = True 
				If IncrementIncrementor(CurrentAnchor.AngleOrientation, CurrentAnchor.AbsoluteMode) Then DidMove = True 
				If IncrementIncrementor(CurrentAnchor.Radius,False) Then DidMove = True 
				If IncrementIncrementor(CurrentAnchor.Distance,False) Then DidMove = True 
			End If 
			
			If CurrentAnchor.AnchorTo < 0 Then
				X= Width*0.5
				Y= Height*0.5
			Else
				AnchoredTo = Anchors.Get(CurrentAnchor.AnchorTo)
				AnchoredTo.HasAnchor = True 
				X = AnchoredTo.X 
				Y = AnchoredTo.Y
			End If
			
			If CurrentAnchor.AbsoluteMode Then 
				CurrentAnchor.X = Left + CurrentAnchor.Distance.Current * 0.01 * Size
				CurrentAnchor.Y = Top + CurrentAnchor.AngleFromAnchor.Current * 0.01 * Size
			else If CurrentAnchor.Distance.Current = 0 Then 
				CurrentAnchor.X = X
				CurrentAnchor.Y = Y
			Else 
				CurrentAnchor.X = Trig.findXYAngle(X,Y, CurrentAnchor.Distance.Current, CurrentAnchor.AngleFromAnchor.Current, True)
				CurrentAnchor.Y = Trig.findXYAngle(X,Y, CurrentAnchor.Distance.Current, CurrentAnchor.AngleFromAnchor.Current, False)
			End If 
			
			If CurrentAnchor.Delay = 0 Then 
				Select Case CurrentAnchor.BrightnessType 
					Case 1'brighten on completion
						If DidMove Then 
							If Not(AnchorIsMoving(CurrentAnchor)) Then CurrentAnchor.BrightnessType = 2
						End If
					Case 2'brighten to 255
						CurrentAnchor.Brightness = LCAR.Increment(CurrentAnchor.Brightness, LCAR.Alphaspeed, 255)
						If CurrentAnchor.Brightness = 255 Then CurrentAnchor.BrightnessType = 3
					Case 3'darken to 0
						CurrentAnchor.Brightness = LCAR.Increment(CurrentAnchor.Brightness, LCAR.Alphaspeed, 0)
						If CurrentAnchor.Brightness = 0 Then CurrentAnchor.BrightnessType = 0
				End Select
				
				If CurrentAnchor.Corner < 0 Then 
					CurrentAnchor.CornerPercent = LCAR.Increment(CurrentAnchor.CornerPercent, 5, 0)
				Else 
					CurrentAnchor.CornerPercent = LCAR.Increment(CurrentAnchor.CornerPercent, 5, 100)
				End If 
			End If 
			
			If IsNewSecond And LCAR.PartyTime Then 'CurrentAnchor.ColorID = MakeColor(0)
				NC2=NC1
				NC1 = CurrentAnchor.ColorID 
				CurrentAnchor.ColorID = NC2 
			End If 
		Else 
			DidMove = True 
			CurrentAnchor.Delay = Max(0, CurrentAnchor.Delay - TimeDifference)
		End If 
	Next
	Element.LWidth = 1
	LastUpdate = DateTime.Now 
	If NextAnimation > 0 And Not(DidMove) Then
		NextAnimation = NextAnimation - TimeDifference
		If NextAnimation < 1 Then 
			LoadAnimation(CurrentAnimation+1, Null, Min(Width,Height), Element.Text, 0)
		End If 
	End If
	FirstFrame=False
End Sub

Sub MakeColor(ColorID As Int) As Int 
	If LCAR.PartyTime Then Return LCAR.LCAR_RandomColor
	If ColorScheme > LCAR.LCAR_Random Then ColorID = ColorScheme
	If ColorID < 1 Then 		
		Select Case ColorID
			Case LCAR.LCAR_TNG:		ColorID = LCAR.LCAR_RandomColor
			Case -LCAR.Cardassian: 	ColorID = Random(Array As Int(LCAR.Classic_Green, LCAR.LCAR_Red))
			'Case -LCAR.LCAR_TOS, -LCAR.LCAR_ENT, -LCAR.LCAR_TMP, -LCAR.Klingon, -LCAR.Ferengi, -LCAR.StarWars, -LCAR.BattleStar, -LCAR.FreedomWars,-LCAR.KnightRider,-LCAR.ChronowerX,-LCAR.Romulan,-LCAR.StarshipTroopers
		End Select
	End If
	Return ColorID 
End Sub
Sub MakeAnchor(Alpha_Current As Int, Alpha_Desired As Int, AnchorTo As Int, ColorID As Int, FlipX As Boolean, FlipY As Boolean, LockedtoAnchor As Boolean, SVGid As Int, Delay As Int, LineToAnchor As Int, AbsoluteMode As Boolean) As Anchor 
	Dim temp As Anchor
	temp.Initialize
	temp.Alpha.Initialize
	temp.Alpha.Current = Alpha_Current
	temp.Alpha.Desired = Alpha_Desired
	temp.GroupID = -1 
		
	temp.AngleFromAnchor = MakeIncrementor(0,0,False,0,0)
	temp.AngleOrientation = temp.AngleFromAnchor
	temp.Radius = temp.AngleFromAnchor
	temp.Distance = temp.AngleFromAnchor
		
	temp.AbsoluteMode = AbsoluteMode
	temp.AnchorTo = AnchorTo
	temp.ColorID = MakeColor(ColorID)
	temp.FlipX = FlipX
	temp.FlipY = FlipY
	temp.LockedtoAnchor = LockedtoAnchor
	temp.Delay = Delay
	temp.SVGid = SVGid
	temp.State = Rnd(0,100) > 50
	temp.LineToAnchor = LineToAnchor
	Anchors.Add(temp)
	Return temp 
End Sub
Sub MakeIncrementor(Current As Int, Desired As Int, IsOffset As Boolean, Speed As Float, Acceleration As Float) As Incrementor 
	Dim temp As Incrementor
	temp.Initialize
	temp.Current = Current
	temp.Acceleration = Acceleration
	temp.Desired = Desired 
	temp.IsOffset = IsOffset
	temp.Speed= Speed
	Return temp 
End Sub
Sub Random(Values As List) As Int
	Return Values.Get( Rnd(0, Values.size )	)
End Sub
Sub IncrementIncrementor(Inc As Incrementor, isAngle As Boolean) As Boolean 
	'Type Incrementor(Current As Int, Desired As Int, IsOffset As Boolean, Speed As Float, Acceleration As Float)
	Dim temp As Int, Ret As Boolean 
	If Inc.Speed > 0 Then  
		If isAngle Then 
			If Inc.IsOffset Then 
				Ret = Inc.Desired <> 0 
				IncrementOffset(Inc)
				Inc.Current = Trig.CorrectAngle(Inc.Current)
			Else 
				temp = Inc.Desired - Inc.Current
				Ret = temp <> 0 
				If temp > 180 Then 'go down
					If Inc.Current < 180 Then
                        Inc.Current = Trig.CorrectAngle(Inc.Current - Inc.Speed)
						If Inc.Current < 0 Then Inc.Current = Max(Inc.Current, Inc.Desired)
                    Else
                        Inc.Current = Trig.CorrectAngle(Inc.Current + Inc.Speed)
                        If Inc.Current < 180 Then Inc.Current = Min(Inc.Current, Inc.Desired)
                    End If
				Else
					Inc.Current = LCAR.Increment(Inc.Current, Inc.Speed, Inc.Desired)
				End If 
			End If 
		Else if Inc.IsOffset Then
			Ret = Inc.Desired <> 0
			IncrementOffset(Inc)
		Else
			Ret = Inc.Current <> Inc.Desired  
			Inc.Current = LCAR.Increment(Inc.Current, Inc.Speed, Inc.Desired)
		End If
		If Inc.Acceleration <> 0 Then Inc.Speed = Max(1, Inc.Speed + (Inc.Speed*Inc.Acceleration))
	End If 
	Return Ret 
End Sub

Sub IncrementOffset(Inc As Incrementor)
	If Inc.Desired > 0 Then 
		Inc.Current = Inc.Current + Min(Inc.Desired, Inc.Speed)
		Inc.Desired = Max(0, Inc.Desired - Inc.Speed)
	Else
		Inc.Current = Inc.Current + Max(Inc.Desired, Inc.Speed)
		Inc.Desired = Min(0, Inc.Desired + Inc.Speed)
	End If
End Sub

Sub StringToIncrementor(Text As String, ScaleFactor As Long) As Incrementor
	Dim tempstr() As String = Regex.Split(",", Text)
	Return MakeIncrementor(tempstr(0)* ScaleFactor, tempstr(1)* ScaleFactor, tempstr(2)=1, tempstr(3), tempstr(4))
End Sub

Sub StringToAnchor(Text As String, ScaleFactor As Long, Add As Int, InitialDelay As Int) As Anchor
	Dim tempstr() As String, tempstr2() As String, A As Anchor, AbsoluteMode As Boolean
	Text=RemoveComment(Text)
    tempstr = Regex.Split("\|", Text)
    tempstr2 = Regex.Split(",", tempstr(0))
	If Anchors.Size > Add Then 
		A = Anchors.Get(Add)
		A.Alpha.Desired = tempstr2(1)
		A.Delay = tempstr2(8) + InitialDelay
	Else 
		If tempstr2.Length > 10 Then AbsoluteMode = tempstr2(10) = 1
    	A = MakeAnchor(tempstr2(0), tempstr2(1), tempstr2(2), tempstr2(3), tempstr2(4) = 1, tempstr2(5) = 1,  tempstr2(6) = 1, tempstr2(7), tempstr2(8) + InitialDelay, tempstr2(9), AbsoluteMode)
	End If 

	A.Distance = StringToIncrementor(tempstr(3), API.IIF(A.AbsoluteMode, 1, ScaleFactor))'X
	A.AngleFromAnchor = StringToIncrementor(tempstr(1), 1)'Y
	A.AngleOrientation = StringToIncrementor(tempstr(2), 1)
    A.Radius = StringToIncrementor(tempstr(4), ScaleFactor)
	
	If Add> -1 Then 
		If Anchors.Size > Add Then 
			Anchors.Set(Add, A)
		Else 
			Anchors.Add(A)
		End If 
	End If
	Return a 
End Sub






Sub PointInRectangle(PT As Point, TopLeft As Point, TopRight As Point, BottomLeft As Point, BottomRight As Point) As Boolean
	If PointInTriangle(PT, TopLeft, TopRight, BottomLeft) Then Return True 
	If PointInTriangle(PT, BottomLeft , BottomRight, TopRight) Then Return True 
End Sub

Sub sign(p1 As Point, p2 As Point, p3  As Point) As Float 
  Return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
End Sub 

Sub PointInTriangle(pt As Point, v1 As Point, v2 As Point, v3 As Point) As Boolean 
  Dim b1 As Boolean, b2 As Boolean, b3 As Boolean
  b1 = sign(pt, v1, v2) < 0
  b2 = sign(pt, v2, v3) < 0
  b3 = sign(pt, v3, v1) < 0
  Return b1 = b2 And b2 = b3
End Sub 

Sub Scatter(isAnchor As Boolean, range As String, Size As Int, Delay As Long)
	Dim IDs As List = API.splitrange(range), temp As Int, A As Anchor, DOIT As Boolean
	Dim CurrentDelay As Long, CurrentAngle As Long = -1, CurrentDistance As Long  = -1
	For temp = 0 To Anchors.Size - 1
		If isAnchor Then 
			DOIT = IDs.IndexOf( temp ) > -1 Or range = "all"
		Else 'is SVG
			A = Anchors.get(temp)
			DOIT = IDs.IndexOf( A.SVGid ) > -1 Or IDs.IndexOf( API.IIF(A.SVGid < 0, "-", "+") ) > -1 Or range = "all"
		End If 
		If DOIT Then 
			Select Case Size 
				Case -2
					A.Brightnesstype = Delay 
				Case Else '-1 and higher
					A.Alpha.Current = 0
					A.Radius.Current = 0
					If Size > 0 Then A.Distance.Current = Size 
					A.AngleOrientation.Current = Trig.CorrectAngle(A.AngleOrientation.Current + 170)
					If CurrentAngle = A.AngleFromAnchor.Current And CurrentDistance = A.Distance.Desired Then 
						CurrentDelay = CurrentDelay + Delay 
						A.Delay = CurrentDelay
					Else
						CurrentDelay = 0 
						CurrentAngle = A.AngleFromAnchor.Current 
						CurrentDistance = A.Distance.Desired
					End If 
			End Select
		End If
	Next 
End Sub

'Key: # will be replaced with svgs/anchors
Sub rangeaction2(Action As Int, Tag As Int, INIS As Map, Key As String)
	Dim KeyName As String 
	If Not(Key.Contains("#")) Then Key = Key & "#"
	KeyName = Key.Replace("#", "svgs")
	If INIS.ContainsKey(KeyName) Then rangeaction(Action, Tag, False, INIS.Get(KeyName))
	KeyName = Key.Replace("#", "anchors")
	If INIS.ContainsKey(KeyName) Then rangeaction(Action, Tag, True, INIS.Get(KeyName))
End Sub
Sub rangeaction(Action As Int, Tag As Int, isAnchor As Boolean, Range As String)
	Dim IDs As List, temp As Int, A As Anchor, DOIT As Boolean
	Dim CurrentDelay As Long, CurrentAngle As Long = -1, CurrentDistance As Long  = -1
	If Range.Contains("(") Then 
		Tag = API.GetBetween(Range, "(", ")")
		Range = Range.Replace("(" & Tag & ")", "")
	End If
	IDs = API.splitrange(Range)
	Log("Checking: " & API.IIF(isAnchor, "Anchors", "SVGs") & " Action: " & API.IIFIndex(Action, Array As String("Corner", "Fixed State", "Color Scheme", "Slide", "Delay")) & ", Tag: " & Tag & " Range: " & Range)
	If Action = -1 Then 
		Select Case Tag 
			Case 0'flash
				Scatter(isAnchor, Range, -2, 1)
		End Select
	Else 
		For temp = 0 To Anchors.Size - 1
			If isAnchor Then 
				DOIT = IDs.IndexOf( temp ) > -1 Or Range = "all"
			Else 'is SVG
				A = Anchors.get(temp)
				DOIT = IDs.IndexOf( A.SVGid ) > -1 Or IDs.IndexOf( API.IIF(A.SVGid < 0, "-", "+") ) > -1 Or Range = "all"
			End If 
			If DOIT Then 
				Select Case Action
					 Case 0'corner
					 	A.Corner = Tag 
					Case 1'fixed state
						If Tag < 2 Then 
							A.State = Tag = 1
						Else 
							A.State = Rnd(0,100) > 50
						End If
					Case 2'colorscheme
						A.ColorID = MakeColor(Tag)
					Case 3'slide
						'8 = up, 2 = down, 4 = left, 6 = right, A.Distance = X, A.AngleFromAnchor = Y
						A.AbsoluteMode = True 
						A.Alpha.Current = 0
						A.Alpha.Desired = 255
						A.Delay = CurrentDelay
						CurrentDelay = CurrentDelay + 100				
						If Tag = 8 Or Tag = 2 Then'8 up/ 2 down
							A.AngleFromAnchor.Current = A.AngleFromAnchor.Desired + API.iif(Tag = 8, 16, -16)
						Else '4 left/ 6 right 
							A.AngleFromAnchor.Current = A.AngleFromAnchor.Desired + API.iif(Tag = 4, 16, -16)
						End If 	
					Case 4
						A.Delay = CurrentDelay
						CurrentDelay = CurrentDelay + Tag
				End Select
			End If 
		Next
	End If
End Sub







'Yaw (left, right) not supported, Pitch (up, down) not supported, Roll (clockwise/counter-clockwise)
public Sub Calc3DCube(X As Int, Y As Int, Width As Int, Height As Int, Yaw As Int, Pitch As Int, Roll As Int, ShiftX As Int, ShiftY As Int) As Point()
	Dim HalfWidth As Int = Width * 0.5, HalfHeight As Int = Height * 0.5, WidthOffset As Int = Width * 0.5
	Dim CenterX As Int = X + HalfWidth, CenterY As Int = Y + HalfHeight, Corners(8) As Point, temp As Int 
	
	Corners(4) = Trig.SetPoint(X+WidthOffset,Y+HalfHeight)					'Top Left Back
	Corners(5) = Trig.SetPoint(X+Width-WidthOffset, Y+HalfHeight)			'Top Right Back
	Corners(6) = Trig.SetPoint(X+WidthOffset,Y+HalfHeight)					'Bottom Left Back
	Corners(7) = Trig.SetPoint(X+Width-WidthOffset, Y+HalfHeight)			'Bottom Right Back
	
	X = X - HalfWidth
	Width = Width * 2
	Y = Y - HalfHeight
	Height=Height * 2
	
	Corners(0) = Trig.SetPoint(X+ShiftX,Y+ShiftY)							'Top Left Front
	Corners(1) = Trig.SetPoint(X+Width+ShiftX, Y+ShiftY)					'Top Right Front
	Corners(2) = Trig.SetPoint(X+ShiftX,Y+Height+ShiftY)					'Bottom Left Front
	Corners(3) = Trig.SetPoint(X+Width+ShiftX, Y+Height+ShiftY)				'Bottom Right Front
	
	If Roll <> 0 Then '(clockwise/counter-clockwise)
		If Roll < 0 Then Roll = Roll + 360 
		For temp = 0 To Corners.Length - 1
			Corners(temp) = RotatePointAround(Corners(temp), CenterX, CenterY, Roll)
		Next
	End If
	
	Return Corners 
End Sub

'Z: 0=front, 1=back
public Sub GetZ(Corners() As Point, Z As Float) As Point()
	Dim Ret(4) As Point, temp As Int 
	Z = Trig.Curve(Z)
	For temp = 0 To 3
		Ret(temp) = CalculatePointXY(Corners(temp), Corners(temp+4), Z)
	Next
	Return Ret 
End Sub

'Z is obtained from GetZ
Public Sub GetXY(X As Float, Y As Float, Z() As Point) As Point
	Return CalculatePointXY2(Z(0), Z(1), Z(2), Z(3), X, Y, False, False)
End Sub

public Sub RotatePointAround(PT As Point, CenterX As Int, CenterY As Int, Angle As Int) As Point
	Return LCARSeffects6.ShiftPoint(CenterX, CenterY, PT.X,PT.Y, Angle)
End Sub






public Sub IncrementCubes(Element As LCARelement) As Boolean 
	Element.LWidth = (Element.LWidth + 1) Mod 20 
	Element.RWidth = LCAR.Increment(Element.RWidth, 1, Element.Align)
	If Element.RWidth = Element.Align Then Element.Align = Rnd(-45,45)
	Return True 
End Sub
public Sub DrawCubes(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Element As LCARelement)
	Dim temp As Int, Start As Float = 1 - (Element.LWidth * 0.01), Zf() As Point, Zb() As Point, Corners() As Point = Calc3DCube(X,Y,Width,Height, 0,0, Element.RWidth, 0,0)
	
	'DrawLine(BG, Corners(0), Corners(1), Colors.White, 0)
	'DrawLine(BG, Corners(3), Corners(1), Colors.White, 1)
	DrawLine(BG, Corners(2), Corners(3), Colors.White, 2)
	'DrawLine(BG, Corners(0), Corners(2), Colors.White, 3)
	
	'DrawLine(BG, Corners(4), Corners(5), Colors.Red, 4)
	'DrawLine(BG, Corners(7), Corners(5), Colors.Red, 5)
	DrawLine(BG, Corners(6), Corners(7), Colors.Red, 2)
	'DrawLine(BG, Corners(4), Corners(7), Colors.Red, 7)
	
	'DrawLine(BG, Corners(0), Corners(4), Colors.Green, 8)
	'DrawLine(BG, Corners(1), Corners(5), Colors.Green, 9)
	DrawLine(BG, Corners(2), Corners(6), Colors.Green, 2)
	DrawLine(BG, Corners(3), Corners(7), Colors.Green, 2)
	
	For temp = 1 To 9
		Zb = GetZ(Corners, Start+0.08)
		Zf = GetZ(Corners, Start)
		
		'DrawCube(BG, Zf, Zb, 0.00,0.00,1.00, 1.00)
		DrawCube(BG, Zf, Zb, 0.20,0.25,0.20, 0.75)
		DrawCube(BG, Zf, Zb, 0.60,0.25,0.20, 0.75)
		'DrawCube(BG, Zf, Zb, 0.75,0.25,0.25, 0.75)
		'DrawCube(BG, Zf, Zb, 0.80,0.25,0.20, 0.75)
		Start = Start - 0.2
	Next
End Sub
public Sub DrawCube(BG As Canvas, Zfront() As Point, Zback() As Point, X As Float, Y As Float, Width As Float, Height As Float)
	Dim TLB As Point = GetXY(X,Y, Zback), TRB As Point = GetXY(X+Width, Y, Zback), TLF As Point = GetXY(X,Y, Zfront), TRF As Point = GetXY(X+Width,Y, Zfront)
	Dim BLB As Point = GetXY(X,Y+Height, Zback), BRB As Point = GetXY(X+Width, Y+Height, Zback), BLF As Point = GetXY(X,Y+Height, Zfront), BRF As Point = GetXY(X+Width,Y+Height, Zfront)
	Dim Color1 As Int = Colors.ARGB(64,79,234,162), Color2 As Int = Colors.ARGB(128,79,234,162), Stroke As Int = 2
	
	DrawFace(BG, BLB, BRB, BLF, BRF, Colors.Black, 0, 0)'bottom
	DrawFace(BG, TLB, TRB, TLF, TRF, Color1, Color2, Stroke)'top
	DrawFace(BG, TLB, TRB, BLB, BRB, Color1, Color2, Stroke)'back
	DrawFace(BG, TLF, TRF, BLF, BRF, Color1, Color2, Stroke)'front
	DrawFace(BG, TLB, TLF, BLB, BLF, Color1, Color2, Stroke)'left
	DrawFace(BG, TRB, TRF, BRB, BRF, Color1, Color2, Stroke)'right
End Sub
public Sub DrawFace(BG As Canvas, TL As Point, TR As Point, BL As Point, BR As Point, FaceColor As Int, EdgeColor As Int, Stroke As Int)
	Dim P As Path 
	P.Initialize(TL.X, TL.Y)
	P.LineTo(TR.X, TR.Y)
	P.LineTo(BR.X, BR.Y)
	P.LineTo(BL.X, BL.Y)
	P.LineTo(TL.X, TL.Y)
	If Stroke > 0 Then BG.DrawPath(P, EdgeColor, False, Stroke)
	BG.DrawPath(P, FaceColor, True, 0)
End Sub

public Sub DrawLine(BG As Canvas, PT1 As Point, PT2 As Point, Color As Int, Stroke As Int)
	Dim X As Int = (PT1.X + PT2.X) * 0.5, Y As Int = (PT1.Y + PT2.Y) * 0.5
	BG.DrawLine(PT1.X, PT1.Y, PT2.X, PT2.Y, Color, Stroke)
	'BG.DrawText(Stroke, X,Y, Typeface.DEFAULT, 10, Color, "CENTER")
End Sub













'Dim TCAR_DarkTurquoise As Int, 		TCAR_LightTurquoise As Int, 	TCAR_Yellow As Int, 			TCAR_Orange As Int, 		TCAR_DarkOrange As Int, TCAR_DarkPurple, TCAR_LightPurple
Sub RandomTCARS() As Int 
	Dim Index As Int = API.dRnd(0, 1, LCAR.TCAR_Main)
	LastUpdate=DateTime.Now
	RNDlist.Initialize
	TCARStext.Initialize
	If Not(TCARSfont.IsInitialized) Then TCARSfont = Typeface.LoadFromAssets("tostitle.ttf")
	Select Case Index 
		Case 0'main
			MakeRandomNumbers(18, LCAR.TCAR_DarkTurquoise, LCAR.TCAR_LightTurquoise+1, False)'0-17
			MakeRandomNumbers(1, LCAR.TCAR_DarkTurquoise, LCAR.TCAR_DarkTurquoise+1, False)'18
			MakeRandomNumbers(7, LCAR.TCAR_DarkPurple, LCAR.TCAR_LightPurple+1,False)'19-25
			MakeRandomNumbers(11, 1000, 10000, False)'26-36
			MakeRandomNumbers(2, 38, 159, True)'37,38
			MakeRandomNumbers(8, 1, 1000, False)'39-46
			MakeRandomNumbers(-2, 0, 360, True)'47,48
			MakeRandomNumbers(1, 10,30, True)'49
			MakeRandomNumbers(1, 40,70, True)'50
	End Select
	Return Index 
End Sub
Sub TCARSwidth(Index As Int, Height As Int) As Int 
	Select Case Index 
		Case 0: Return Height * 2.464953271028037'main
	End Select 
End Sub
Sub IncrementTCARS(Element As LCARelement) As Boolean 
	Dim temp As Int, tempRND As RNDNum
	Element.RWidth = (Element.RWidth + 1) Mod 20
	If Element.RWidth = 0 Then 
		Element.Align = (Element.Align + 1) Mod 7
		If Element.Align = 0 Then TCARStext.Initialize
	End If
	If Element.RWidth Mod 3 = 0 Then Element.textAlign = (Element.TextAlign + 1) Mod 20
	
	If LastUpdate < DateTime.Now - DateTime.TicksPerSecond Then 
		For temp = 0 To RNDlist.size - 1
			tempRND = RNDlist.Get(temp)
			If tempRND.Desired < tempRND.Minimum Then 
				If Rnd(0,2) = 0 Then tempRND.Current = Rnd(tempRND.Minimum, tempRND.Maximum)
			End If 
		Next
		LastUpdate = DateTime.Now 
	End If
	
	For temp = 0 To RNDlist.size - 1
		tempRND = RNDlist.Get(temp)
		If tempRND.Desired>tempRND.Maximum Then 
			tempRND.Current = tempRND.Current + 1
			If tempRND.Current >= tempRND.Maximum Then tempRND.Current = tempRND.Minimum
		else If tempRND.Desired>=tempRND.Minimum Then 
			tempRND.Current = LCAR.Increment(tempRND.Current, 5, tempRND.Desired)
			If tempRND.Current = tempRND.Desired Then tempRND.Desired = Rnd(tempRND.Minimum, tempRND.Maximum)
		End If
	Next
	
	Select Case Element.LWidth 
		Case 0'main
			
	End Select 
	Return True'for now
End Sub
Sub DrawTCARS(BG As Canvas, Index As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Timer20 As Int, Timer7 As Int, TimerS20 As Int, ColorID As Int, Text As String)
	Dim Font As Typeface = SetupCadassianSVGs(Index, Width, Height, "tcars"), temp As Int, CurveDT As Float = 0.01, Stroke As Int = 0, Color As Int = LCAR.GetColor(ColorID, False, Alpha)
	Dim tempX As Int = 0.8104265402843602 * Width, tempX2 As Int, tempX3 As Int, tempX4 As Int, tempX5 As Int, tempX0 As Int,	tempY As Int, tempY2 As Int, tempY3 As Int, tempY4 As Int
	
	Select Case Index 
		Case 0'main
			'height 428 (and width of right side), 1055 is total width 
			'855 is width of leftside (width*0.8104265402843602)
			'width is 2.464953271028037 * height
			
			'right side is 2-12, left side is 13-17  (13 and 17 are gradients), lines 18-25
			'element 13 height 175, 17 height 123, both have 3 units
			
			'Curve pulses
			tempX2 = X + tempX * 0.485
			tempY2 = Y + Height * 0.2683333
			tempX3=tempX * 0.07*2'full Width offset
			tempY3=Height * 0.175*2'full height offset
			tempX4=tempX * 0.13 - tempX3*2'current Width
			tempY4=Height * 0.4 - tempY3 * 2'Current Height
			If TimerS20 > 0 Then 
				tempX4 = tempX4 + (tempX3 * 0.05) * TimerS20
				tempY4 = tempY4 + (tempY3 * 0.05) * TimerS20
			End If
			DrawSVGwh(BG, X, Y, tempX, Height, 26, -1, False, 255, 0, LCAR.LCARfont, 0, False, False, CurveDT)
			For temp = 1 To 10
				DrawOval(BG, tempX2,tempY2, tempX4, tempY4, Color, 2, True, 340)
				tempX4 = tempX4 + tempX3
				tempY4 = tempY4 + tempY3
			Next
			BG.RemoveClip
			
			'tCARS elements
			DrawTCARSgradient(BG, X,Y,tempX,Height, 13, X,Y, tempX, Height*0.4088785046728972, 3, CurveDT)
			DrawTCARSgradient(BG, X,Y,tempX,Height, 17, X + Width * 0.2303317535545024, Y + Height * 0.7196261682242991, Width * 0.1459715639810427, Height * 0.2873831775700935, 3, CurveDT) '243 (of 1055) 308 (of 428) 154 (of 1055) 123 (of 428)
			For temp = 14 To 25
				If temp = 18 Then Stroke = 2
				If temp <> 17 Then DrawSVGwh(BG, X, Y, tempX, Height, temp, GetRND(temp), False, Alpha, Stroke, Font, 0, False, False, CurveDT)
			Next			

			'Splines
			tempX=x + Width-Height 
			For temp = 2 To 12
				DrawSVGwh(BG, tempX, Y, Height,Height, temp, GetRND(temp), False, Alpha, 0, LCAR.LCARfont, 0, False, False, CurveDT)
			Next 
			DrawSVGwh(BG, X, Y, Height, Height, 27, LCAR.TCAR_DarkTurquoise, False, Alpha, Stroke, Font, 0, False, False, CurveDT)
			DrawSVGwh(BG, X, Y, Height, Height, 28, LCAR.TCAR_DarkOrange, False, Alpha, Stroke, Font, 0, False, False, CurveDT)
			
			'Blinky	
			DrawTCARSblinkie(BG, X+Width*0.09,Y, Width*0.24, Height * 0.14, Timer7)
			
			'todo: gradient bar using LCAR.DrawGradient2, animated pulse and position indicators, rotating circles, text, insignia meters
			'Center point of circle
			tempX2 = X + 0.8310185 * Height 
			tempY2 = Y + 0.3402778 * Height 
			'Left bottom point of line
			tempX3 = X
			tempY3 = Y + 0.7731481 * Height 
			tempY = Height * 0.0280373831775701 * 0.5
			
			Color = LCAR.GetColor(LCAR.TCAR_LightTurquoise, False, Alpha)
			temp = LCAR.GetColor(LCAR.TCAR_DarkTurquoise, False, Alpha)
			TCAR_DrawBars(BG, tempX3,tempY3, tempX2,tempY2, Height, Array As Float(0.077819, 0.145833, 0.221106, 0.113426, 0.3261, 0.069444,   0.401449, 0.05787,  0.450858, 0.025463, 0.48915, 0.032407,  0.576851, 0.113426, 0.664552, 0.041667, 0.81772, 0.226852), tempY, Color, temp, Timer20, CurveDT)
			
			DrawSquircle(BG, x + Width * 0.8701422, Y + Height * 0.3621495, Height * 0.196, GetRND(47), Alpha, False, Height)
			DrawSquircle(BG, x + Width * 0.3402844, Y + Height * 0.3434579, Height * 0.079, GetRND(48), Alpha, False, Height)
			
			tempX = LCAR.Fontsize*0.5
			BG.DrawText(GetRND(26), x + Width * 0.6729858, Y+ Height * 0.1471963, TCARSfont, tempX, Color, "CENTER") 
			BG.DrawText(Text, x + Width * 0.9876778, Y+ Height * 6.775701E-02, TCARSfont, tempX, OppositeColor(2,Alpha), "RIGHT") 
			BG.DrawText(GetRND(27), x + Width * 0.9516588, Y+ Height * 0.3574766, TCARSfont, tempX, temp, "RIGHT") 
			BG.DrawText(GetRND(28), x + Width * 0.9478673, Y+ Height * 0.4345794, TCARSfont, tempX, Color, "RIGHT") 
			BG.DrawText(GetRND(29), x + Width * 0.9355450, Y+ Height * 0.5070093, TCARSfont, tempX, Color, "RIGHT") 
			BG.DrawText(GetRND(30), x + Width * 0.9232227, Y+ Height * 0.5654206, TCARSfont, tempX, temp, "RIGHT") 
			BG.DrawText(GetRND(31), x + Width * 0.8976303, Y+ Height * 0.6658878, TCARSfont, tempX, Color, "RIGHT") 
			BG.DrawText(GetRND(32), x + Width * 0.8729858, Y+ Height * 0.7546729, TCARSfont, tempX, Color, "RIGHT")
			BG.DrawText(GetRND(33), x + Width * 0.8037915, Y+ Height * 0.9439253, TCARSfont, tempX, Color, "RIGHT")
			
			BG.DrawText(GetRND(34), x + Width * 0.9905213, Y+ Height * 0.6308411, TCARSfont, tempX, OppositeColor(10,Alpha), "LEFT") 
			BG.DrawText(GetRND(35), x + Width * 0.9601896, Y+ Height * 0.7803738, TCARSfont, tempX, OppositeColor(11,Alpha), "LEFT") 
			BG.DrawText(GetRND(36), x + Width * 0.9071090, Y+ Height * 0.9579439, TCARSfont, tempX, OppositeColor(12,Alpha), "LEFT") 
			
			'TL 0.4312796, 0.6168224	TR 0.5052133, 0.6121495		BL 0.2919431, 0.978972	 	BR 0.5033175, 0.9742991
			TCARSDrawText(BG, x + Width * 0.2919431, Y + Height * 0.6168224, 0.2113744 * Width, 0.3621496 * Height, 0.64, 0, True, TCARSfont, tempX, Color)
			
			tempX=tempX*0.5
			BG.DrawText(GetRND(32) & GetRND(33), x + Width * 0.1706161, Y+ Height * 0.4929906, TCARSfont, tempX, Color, "RIGHT")
			BG.DrawText(GetRND(30) & GetRND(36), x + Width * 0.1895735, Y+ Height * 0.4088785, TCARSfont, tempX, Color, "LEFT") 
			
			Dim LT As Int = LCAR.TCAR_LightTurquoise, DT As Int = LCAR.TCAR_DarkTurquoise, ON As Int = LCAR.TCAR_Orange
			tempX = X+ Width * 0.5260664
			tempY = Height * 0.0794392523364486
			DrawInsigniaMeter(BG, tempX, Y + Height * 0.4299065, Array As Int(51, 41, -GetRND(39), 43, 58, 38, -GetRND(40)), tempY, Array As Int(LT,LT,LT,LT,LT,LT,LT, ON), False, Alpha, CurveDT) 
			DrawInsigniaMeter(BG, tempX, Y + Height * 0.5350468, Array As Int(51, 41, -GetRND(41), 43, 58, 38, 38, -GetRND(42)), tempY, Array As Int(LT,-LT,DT,-LT,DT,LT,LT, LT, LT), False, Alpha, CurveDT) 
			DrawInsigniaMeter(BG, tempX, Y + Height * 0.6425233, Array As Int(51, -GetRND(43), 43, GetRND(38), 38, -GetRND(44)), tempY, Array As Int(LT,-LT,LT,LT,LT,LT,-LT), False, Alpha, CurveDT) 
			DrawInsigniaMeter(BG, tempX, Y + Height * 0.7476636, Array As Int(51, 58, GetRND(37), 38, -GetRND(45)), tempY, Array As Int(LT,LT,ON, LT, LT, DT), False, Alpha, CurveDT) 'THIRD SCALES
			DrawInsigniaMeter(BG, tempX, Y + Height * 0.8574767, Array As Int(GetRND(38), 58, 38, -GetRND(46)), tempY, Array As Int(DT,LT,DT,LT,LT), False, Alpha, CurveDT) 'FIRST SCALES
	End Select
End Sub

Sub OppositeColor(Index As Int, Alpha As Int) As Int 
	Dim ColorID As Int = LCAR.TCAR_LightTurquoise
	If GetRND(Index) = LCAR.TCAR_LightTurquoise Then ColorID = LCAR.TCAR_DarkTurquoise
	Return LCAR.GetColor(ColorID, False, Alpha)
End Sub

'RelativeToCenter: True=X/Y will be the Center, False:X/Y will be the top-left corner
Sub DrawOval(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int, RelativeToCenter As Boolean, Angle As Int)
	Dim Dest As Rect 
	If Width=0 Or Height = 0 Then Return 
	If RelativeToCenter Then
		Dest = LCARSeffects4.SetRect(X-Width*0.5,Y-Height*0.5,Width,Height)
	Else
		Dest = LCARSeffects4.SetRect(X,Y,Width,Height)
	End If
	BG.DrawOvalRotated(Dest, Color, Stroke=0, Stroke, Angle)
End Sub

Sub DrawTCARSgradient(BG As Canvas, tX As Int, tY As Int, tWidth As Int, tHeight As Int, SVGid As Int, gradX As Int, gradY As Int, gradWidth As Int, gradHeight As Int, gradCount As Int, CurveDT As Float)
	Dim tempHeight As Int = gradHeight / gradCount, tempHeight2 As Int = tempHeight * 0.33, temp As Int, SecondColor As Int = Colors.RGB(143, 238,230) 
	DrawSVGwh(BG, tX, tY, tWidth, tHeight, SVGid, -1, False, 255, 0, LCAR.LCARfont, 0, False, False, CurveDT)
	For temp = 1 To gradCount
		LCAR.DrawGradient(BG, Colors.Black, SecondColor, 8, gradX, gradY, gradWidth, tempHeight2+2, 0,0)
		LCARSeffects4.DrawRect(BG, gradX, gradY+tempHeight2, gradWidth, tempHeight - tempHeight2*2, SecondColor, 0)
		LCAR.DrawGradient(BG, SecondColor, Colors.Black, 8, gradX, gradY+tempHeight-tempHeight2, gradWidth, tempHeight2, 0,0)
		gradY = gradY + tempHeight
	Next
	BG.RemoveClip
End Sub

Sub GetRND(Index As Int) As Int 
	Dim tempRND As RNDNum = RNDlist.Get(Index)
	Return tempRND.Current
End Sub

'If Count is above zero and not incrementing, Current will be randomized between minimum to maximum at random intervals of 1 second
'If Count is below Zero, Current will increment between minimum to maximum, then start over from minimum
'If Incrementing, Current will increment between Current and Desired, re-randomizing Desired when they match
Sub MakeRandomNumbers(Count As Int, Minimum As Int, Maximum As Int, Incrementing As Boolean)
	Dim temp As Int, IsNotRandom As Boolean = Count < 0
	For temp = 1 To Abs(Count)
		Dim tempRND As RNDNum
		tempRND.Initialize
		tempRND.Minimum = Minimum
		tempRND.Maximum = Maximum
		tempRND.Current = Rnd(Minimum, Maximum)
		tempRND.Desired = Minimum-10
		If IsNotRandom Then 
			Maximum = Abs(Maximum)
			tempRND.Current = Rnd(Minimum, Maximum)
			tempRND.Desired = Maximum + 10	
		Else If Incrementing Then 
			tempRND.Desired = Rnd(Minimum, Maximum)
		End If
		RNDlist.Add(tempRND)
	Next
End Sub

Sub DrawTCARSblinkie(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int)'w=250
	Dim UnitWidth As Int = Width / 7, WhiteSpace As Int = Width * 0.02, Units(7) As Int, temp As Int, Color As Int, Turq As Int = LCAR.GetColor(LCAR.TCAR_DarkTurquoise, False, 255) 
	If X + Width < 0 Then Return  
	LCARSeffects4.DrawRect(BG,X,Y,Width+WhiteSpace, Height, Colors.Black, 0)
	'0 1 2 [3] 4 5 6
	Select Case Stage
		'Case 0=all blank
		Case 1'3 lit 100%
			Units(3) = 100
		Case 2'2 And 4 lit 100%	3 lit 50%
			Units(2) = 100
			Units(3) = 50
			Units(4) = 100
		Case 3'1 And 5 lit 100%	2 And 4 lit 50%		3 lit 25%
			Units(1) = 100
			Units(2) = 50
			Units(3) = 25
			Units(4) = 50
			Units(5) = 100
		Case 4'0 And 6 lit 100%	1 And 5 lit 50%		2 And 4 lit 25%
			Units(0) = 100
			Units(1) = 50
			Units(2) = 25
			Units(4) = 25
			Units(5) = 50
			Units(6) = 100
		Case 5'0 And 6 lit 50%	1 And 5 lit 25%
			Units(0) = 50
			Units(1) = 25
			Units(5) = 25
			Units(6) = 50
		Case 6'0 And 6 lit 25%
			Units(0) = 25
			Units(6) = 25
	End Select

	Y=Y+WhiteSpace
	Height = Height - WhiteSpace * 2
	For temp = 0 To Units.Length - 1 
		Color = TCAR_A2C(Units(temp))
		LCARSeffects4.DrawRect(BG, X+WhiteSpace, Y, UnitWidth-WhiteSpace, Height, Color, 0)
		Select Case Units(temp)
			Case 0: Color = 275
			Case 25: Color = 895
			Case 50: Color = 234
			Case 100: Color = 349
		End Select
		API.DrawText(BG, Color, X+WhiteSpace, Y+ Height+ WhiteSpace*2, TCARSfont, LCAR.Fontsize*0.5, Turq, 7)
		X=X+UnitWidth
	Next
End Sub
Sub TCAR_A2C(Alpha As Int) As Int 
	Dim State As Boolean 
	Select Case Alpha
		Case 0: Alpha = 255
		Case 25: Alpha = -64
		Case 50: Alpha = -96
		Case 100: Alpha = -128
	End Select
	Return LCAR.GetColor(LCAR.TCAR_LightTurquoise, State, Alpha)
End Sub
'http://www.st-minutiae.com/resources/fonts/

Sub TCAR_DrawBars(BG As Canvas, leftX As Int, leftY As Int, rightX As Int, rightY As Int, WidthHeight As Int, CenterWidths() As Float, Height As Int, Color1 As Int, Color2 As Int, Timer20 As Int, CurveDT As Float)
	Dim temp As Long, C1 As Int = Color1, C2 As Int = Color2, C3 As Int, temp2 As Int 
	For temp = 0 To CenterWidths.Length - 1 Step 2
		TCAR_DrawBar(BG, leftX, leftY, rightX, rightY, WidthHeight, CenterWidths(temp), CenterWidths(temp+1), Height, C1,C2)
		C3=C1
		C1=C2
		C2=C3
	Next
	'rnds 49 and 50
	temp = WidthHeight * 0.11
	DrawTCARSbar(BG, leftX,leftY,rightX,rightY, temp, 0.10, Color1, Color2, CurveDT, 30, False, 0)
	DrawTCARSbar(BG, leftX,leftY,rightX,rightY, temp, 0.90, Color2, Color1, CurveDT, 30, False, 0)
	temp2 = 0.1 * temp 
	DrawTCARSbar(BG, leftX,leftY,rightX,rightY, temp, GetRND(49)*0.01, Color1, Color2, CurveDT, 31, False, temp2)
	DrawTCARSbar(BG, leftX,leftY,rightX,rightY, temp, GetRND(50)*0.01, Color2, Color1, CurveDT, 31, True, temp2)
	
	WidthHeight = WidthHeight * 0.03271
	leftX = CalculatePoint(leftX, rightX, 0.617613)
	leftY = CalculatePoint(leftY, rightY, 0.617613) 
	If Timer20 < 10 Then '0-9
		WidthHeight = WidthHeight * ((Timer20+1)*0.1)
	Else '10-19
		WidthHeight = WidthHeight * ((20-Timer20)*0.1)
	End If
	CircleGradient(BG, leftX,leftY, WidthHeight, Colors.White, Colors.ARGB(0,0,0,0))
End Sub
Sub CircleGradient(BG As Canvas, X As Int, Y As Int, Radius As Int, OuterColor As Int, InnerColor As Int)
	Dim Diameter As Int = Radius*2
	LCARSeffects2.ClipCircle(BG, X,Y,Radius)
	LCAR.DrawGradient(BG, InnerColor, OuterColor, 8, X-Radius,Y-Radius, Diameter, Diameter, -Radius,0)
	BG.RemoveClip
End Sub
Sub TCAR_DrawBar(BG As Canvas, leftX As Int, leftY As Int, rightX As Int, rightY As Int, WidthHeight As Int, Center As Float, Width As Float, Height As Int, Color1 As Int, Color2 As Int)
	Dim X As Int = CalculatePoint(leftX, rightX, Center), Y As Int = CalculatePoint(leftY, rightY, Center) 'Angles 28 or 208  Left As Float = Center - Width * 0.5, 
	Width = Width * WidthHeight
	LCAR.DrawGradient(BG, Color1, Color2, 6, X - Width*0.5,Y- Height*0.5, Width, Height, 0, 332.5)
End Sub
Sub DrawCrosshairs(BG As Canvas, X As Int, Y As Int, Width As Int, Color As Int, Stroke As Int)
	BG.DrawLine(X, Y-Width, X, Y+Width, Color, Stroke)
	BG.DrawLine(X-Width,Y,X+Width, Y, Color, Stroke)
End Sub

Sub DrawTCARSbar(BG As Canvas, leftX As Int, leftY As Int, rightX As Int, rightY As Int, Radius As Int, Percent As Float, Color1 As Int, Color2 As Int,  CurveDT As Float, SVGid As Int, FlipX As Boolean, Y As Int)
	leftX = CalculatePoint(leftX, rightX, Percent)
	leftY = CalculatePoint(leftY, rightY, Percent) - Y
	DrawSVG(BG, leftX,leftY, SVGid, Radius, 332, -1, False, 255, 2, LCAR.LCARfont, 10, FlipX, False, CurveDT)
	LCAR.DrawGradient(BG, Color1, Color2, 6, leftX-Radius,leftY-Radius, Radius*2, Radius*2, 0, 332.5)
	BG.RemoveClip
	
	If SVGid= 31 Then 
		rightX=Radius 
		Radius = Radius * 0.5
		DrawSVGwh(BG, leftX, leftY, rightX, rightX, 32, LCAR.TCAR_DarkTurquoise, True, 255, 0, LCAR.lcarfont, 0, False, False, CurveDT)
		DrawSVGwh(BG, leftX, leftY, rightX, rightX, 33, LCAR.TCAR_LightTurquoise, False, 255, 0, LCAR.lcarfont, 0, False, False, CurveDT)
	End If
End Sub

'Must have 1 more ColorID than Widths
Sub DrawInsigniaMeter(BG As Canvas, X As Int, Y As Int, Widths() As Int, Height As Int, ColorIDs() As Int, State As Boolean, Alpha As Int, CurveDT As Float) As Int 
	Dim temp As Int, WhiteSpace As Int = Height * 0.1470588235294118, NextIsNumeric As Boolean, NumericIsLast As Boolean, DidCurve As Boolean, Zeros As Int = BG.MeasureStringWidth("000", TCARSfont, LCAR.Fontsize)
	Dim TextHeight As Int = BG.MeasureStringHeight("0123", TCARSfont, LCAR.Fontsize), tempstr As String, ScaleFactor As Float = Height / 34, NegativeWhiteSpace As Int = WhiteSpace + 16*ScaleFactor
	For temp = 0 To Widths.Length - 1 
		NumericIsLast=False 
		NextIsNumeric=False 
		If temp < Widths.Length-1 Then 
			NextIsNumeric = Widths(temp+1) <= 0 
			If NextIsNumeric Then NumericIsLast = (temp = Widths.Length - 2)
		End If	
		If Widths(temp) <= 0 Then 'draw number 
			tempstr= API.ForceLength(Abs(Widths(temp)), 3, "0", False)
			BG.DrawText(tempstr, X, Y + Height*0.5 + TextHeight* 0.5, TCARSfont, LCAR.Fontsize, LCAR.GetColor(ColorIDs(temp), State, Alpha), "LEFT")
			X = X + Zeros + WhiteSpace
			DidCurve=False 
		Else 
			If DidCurve Then X=X-NegativeWhiteSpace'only flat if NumericIsLast
			Widths(temp) = Widths(temp) * ScaleFactor
			X = X + DrawInsignia(BG, X, Y, Widths(temp), Height, Abs(ColorIDs(temp)), State Or ColorIDs(temp) < 0, Alpha, CurveDT,  False, Not(NumericIsLast)) +WhiteSpace 
			DidCurve = Not(NumericIsLast)
		End If
	Next
	temp = ColorIDs( ColorIDs.Length-1)
	Return x + DrawInsignia(BG, X, Y, 0, Height, Abs(temp), State Or temp < 0, Alpha, CurveDT, True, False)
End Sub
Sub DrawInsignia(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Alpha As Int, CurveDT As Float, RightSide As Boolean, InsideCurve As Boolean) As Int 
	If RightSide Then 
		Width=Height*1.125'Width=36, height=32
		DrawInsigniaUnit(BG, X,Y, Width, Height, 29, ColorID, State, Alpha, CurveDT)
	Else 
		Dim WidthLeft As Int = 0.7647058823529412 * Height, WidthRight As Int, Color As Int = LCAR.GetColor(ColorID, State, Alpha)
		DrawInsigniaUnit(BG, X-WidthLeft, Y, WidthLeft*2, Height, 0, ColorID, State, Alpha, CurveDT)'Left side: SVGid=0, Height=34, Width=26
		If InsideCurve Then 'width=19, height=34
			WidthRight = 0.5588235294117647 * Height
			Width = Max(Width,  WidthLeft + WidthRight)
			DrawInsigniaUnit(BG, X + Width - WidthRight, Y, WidthRight, Height, 1, ColorID, State, Alpha, CurveDT)
		End If 
		WidthRight = Width-WidthLeft-WidthRight
		If WidthRight > 0 Then 
			LCARSeffects4.DrawRect(BG, X+WidthLeft, Y, WidthRight, Height, LCAR.GetColor(ColorID, State, Alpha), 0)
		End If 
	End If 
	Return Width
End Sub 
Sub DrawInsigniaUnit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SVGid As Int, ColorID As Int, State As Boolean, Alpha As Int, CurveDT As Float)
	'LCAR.DrawUnknownElement(BG,X,Y,Width,Height, ColorID, State, Alpha, SVGid)
	DrawSVGwh(BG,X,Y,Width, Height, SVGid, ColorID, State, Alpha, 0, LCAR.LCARfont, 0, False, False, CurveDT)
End Sub

Sub DrawSquircle(BG As Canvas, CenterX As Int, CenterY As Int, Radius As Int, Angle As Int, Alpha As Int, State As Boolean, SBRadius As Int) As Boolean 
	Dim SR As Float = Radius / 84, LT As Int, DT As Int, ON As Int, GR As Int = Colors.ARGB(128,128,128,128)
	'Out of bounds detection
	If CenterX + Radius < 0 Then Return False
	If CenterY + Radius < 0 Then Return False
	If CenterX - Radius > LCAR.ScaleWidth Then Return False
	If CenterY - Radius > LCAR.ScaleHeight Then Return False
	
	LT=LCAR.GetColor(LCAR.TCAR_LightTurquoise, State, Alpha)
	DT=LCAR.GetColor(LCAR.TCAR_DarkTurquoise, State, Alpha)
	ON=LCAR.GetColor(LCAR.TCAR_Orange, State, Alpha)

	'inner
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, LT, 39*SR, 20*SR, OffsetAngles(Angle, Array As Int(270, 0)))
	BG.DrawCircle(CenterX, CenterY, 33*SR, LT, True, 0)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, Colors.Black,  28*SR, 5*SR, OffsetAngles(Angle, Array As Int(270, 0,0, 90,90, 180)))'27 to 35 (r31 t8) 270 to 180
	
	'Dot
	'X: 76, Y: 76  -0.08982      -0.08982      Angle: 315    Distance: 10.6066           Radius: 83.5  Angle Diff: 23              Distance Diff: 9.355864
	'X: 77, Y: 65  -0.07784      -0.22156      Angle: 341    Distance: 19.60867          Radius: 83.5  Angle Diff: -26             Distance Diff: 9.002069
	Dim R2 As Int = 10 * SR, X2 As Int = Trig.findXY(CenterX, CenterY, R2, Angle,True), Y2 As Int = Trig.findXY(CenterX, CenterY, R2, Angle,False) 'CenterY + Radius * -0.08982
	BG.DrawCircle(X2,Y2, R2, ON, True, 0)
	BG.DrawCircle(X2,Y2, R2, Colors.black, False, 1)
	BG.DrawCircle(X2 - R2 * 0.30435, Y2 + R2 * 0.23077, R2 * 0.25, Colors.Black, True, 0)
	
	'thickness of -11 gets a clip path to manipulate
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, LT, 68*SR, 31*SR, OffsetAngles(Angle, Array As Int(351, 33)))'first bit that sticks out: angles=0 to 39 (39), distances:56 to 84 (28), light turquoise
		
	'Distance = 42 to 52 (radius 47 thickness 10), angles 180-359 (Orange), 0-179 (Dark turquoise)
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, DT, 47*SR, 11*SR, OffsetAngles(Angle, Array As Int(0, 90,90, 180,180, 270)))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, ON, 49*SR, 11*SR, OffsetAngles(Angle, Array As Int(180, 270,270, 359)))
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, GR, 52*SR, 6*SR,  OffsetAngles(Angle, Array As Int(180, 270,270, 359)))
	
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, ON, 67*SR, 26*SR, OffsetAngles(Angle, Array As Int(34, 90,90, 150,150, 214)))	'long bit on the outer ring: angles=40 to 220 (180), 56 to 82 (26), orange
	LCARSeffects2.DrawSegmentedCircle(BG, CenterX,CenterY, SBRadius, GR, 74*SR, 14*SR, OffsetAngles(Angle, Array As Int(34, 90,90, 150,150, 214)))	'long bit on the outer ring: angles=40 to 220 (180), 56 to 82 (26), orange	
	Return True 
End Sub
Sub OffsetAngles(Angle As Int, Angles() As Int) As Int()
	Dim temp As Int 
	If Angle > 0 Then 
		For temp = 0 To Angles.Length - 1 
			Angles(temp) = (Angles(temp) + Angle) Mod 360 
		Next
	End If 
	Return Angles 
End Sub

Sub TCARSDrawText(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, TopXpercent As Float, BottomXpercent As Float, AngleOnLeft As Boolean, Font As Typeface, FontSize As Int, Color As Int)
	Dim LineWhiteSpace As Int = 3, LineHeight As Int = BG.MeasureStringHeight("0123456789", Font, FontSize), temp As Int, Align As String = "LEFT"
	If API.ListSize(TCARStext) = 0 Then 
		Dim TopX As Int = Width * TopXpercent, BottomX As Int = Width * BottomXpercent, LineWidth As Int, Y2 As Int, Line As String
		TCARStext.Initialize
		Do Until Y2 >= Height 
			LineWidth = Trig.LineLineIntercept(0, Y2, Width, Y2,  TopX,0, BottomX, Height).X
			If AngleOnLeft Then LineWidth = Width - LineWidth
			Line = GenerateRandomText(BG, LineWidth, Font, FontSize)
			TCARStext.Add(Line)
			Y2=Y2+LineHeight+LineWhiteSpace
		Loop
	End If
	If AngleOnLeft Then 
		X = X + Width
		Align="RIGHT"
	End If 
	For temp = 0 To TCARStext.Size -1 
		BG.DrawText(TCARStext.Get(temp), X, Y+LineHeight, Font, FontSize, Color, Align)
		Y=Y+LineHeight+LineWhiteSpace
	Next
End Sub
Sub GenerateRandomText(BG As Canvas, MaxWidth As Int, Font As Typeface, FontSize As Int) As String 
	Dim tempstr As StringBuilder,CurrentWidth As Int, LetterWidth As Int, Letter As String 
	tempstr.Initialize
	Do Until CurrentWidth >= MaxWidth
		Letter = Rnd(0,11)
		If Letter = 10 Then Letter = " "
		LetterWidth = BG.MeasureStringWidth(Letter, Font, FontSize)
		CurrentWidth = CurrentWidth + LetterWidth
		If CurrentWidth <= MaxWidth Then tempstr.Append(Letter)
	Loop
	Return tempstr.ToString.Trim
End Sub











Sub CheckPointInPolygon(Points As List, X As Int, Y As Int) As Boolean
	If Points.Size = 0 Then Return False 
    Dim x1 As Int, y1 As Int, x2 As Int, y2 As Int, D As Double, i As Int, ni As Int, cPoint As Point = Points.Get(0)
	'https://www.b4x.com/android/forum/threads/geo-zone-determination-point-in-polygon.53929/#post-339569
    ni = 0
    x1 = cPoint.X
    y1 = cPoint.Y
    For i = 1 To Points.Size
        If i < Points.Size Then
			cPoint = Points.Get(i)
        Else
			cPoint = Points.Get(0)' checks the last line
        End If
      	x2 = cPoint.X   
        y2 = cPoint.Y
        If y >= Min(y1, y2) Then
            If y <= Max(y1, y2) Then
                If x <= Max(x1, x2) Then
                    If (x = x1 And y = y1) Or (x = x1 And x = x2) Then Return True' checks vertices and vertical lines
                    If y1 <> y2 Then
                        D = (y - y1) * (x2 - x1) / (y2 - y1) + x1
                        If x1 = x2 Or x <= D Then ni = ni + 1
                    End If
                End If
            End If
        End If
        x1 = x2
        y1 = y2
    Next
  	Return ni Mod 2 > 0
End Sub

'Draws an SVG centered at X,Y, rotated by angle (enforced square aspect ratio)
public Sub CheckPointInRotatedSVG(X As Int, Y As Int, SVGid As Int, Radius As Int, Angle As Int, FlipX As Boolean, FlipY As Boolean, CurveDT As Float, mouseX As Int, mouseY As Int) As Boolean
	Dim Points(4) As Point 
	If Angle = -1 Then 
		Points(0) = Trig.SetPoint(X-Radius,Y-Radius)'top left
		Points(1) = Trig.SetPoint(X+Radius,Y-Radius)'top right
		Points(2) = Trig.SetPoint(X-Radius,Y+Radius)'bottom left
		Points(3) = Trig.SetPoint(X+Radius,Y+Radius)'bottom right
	Else
		Points(0) = Trig.FindAnglePoint(x, y, Radius, Angle - 45)'top left
	    Points(1) = Trig.FindAnglePoint(x, y, Radius, Angle + 45)'top right
	    Points(2) = Trig.FindAnglePoint(x, y, Radius, Angle - 135)'bottom left
	    Points(3) = Trig.FindAnglePoint(x, y, Radius, Angle + 135)'bottom right
	End If
	Return CheckPointInSVG(Points, SVGid, Radius, Angle, FlipX,FlipY,CurveDT, mouseX,mouseY)
End Sub
public Sub CheckPointInSVG(Points() As Point, SVGid As Int,Radius As Int, Angle As Int, FlipX As Boolean, FlipY As Boolean, CurveDT As Float, X As Int, Y As Int) As Boolean 
	Dim CurrentMode As Int, FirstPoint As Int=-1, CurrentPointID As Int, Data() As Float, CurrentPoint As Point, JustRemoved As Boolean
	Dim SVG As List = SVGs.Get(SVGid), Plist As List, Disabled As Int, PrevData() As Float, GrabbedPoints As List

	Plist.Initialize'Check the binding boundary first
	Plist.Add(Points(0))'top left
	Plist.Add(Points(1))'top right
	Plist.Add(Points(3))'bottom right
	Plist.Add(Points(2))'bottom left
	If Not(CheckPointInPolygon(Plist,X,Y)) Then Return False 
	
	Plist.Initialize
	For CurrentPointID = 0 To SVG.Size - 1 
		Data = SVG.Get(CurrentPointID)
		If Data(0) < 0 Then 
			Select Case Data(0)
				Case -1'tool change
					CurrentMode = Data(1)
					Select Case CurrentMode 
						Case 2'remove clip
							Plist.Initialize'don't test as it's not a closed shape
							JustRemoved = True
							CurrentMode = 0'lines
						Case 5'break
							If CheckPointInPolygon(Plist,X,Y) Then Return True'Test if X/Y are inside plist
							Plist.Initialize
							CurrentMode = 0'lines
							FirstPoint = -1
					End Select
			End Select
			PrevData = Data 
		Else 
			If FirstPoint = -1 Then FirstPoint = CurrentPointID
			CurrentPoint = CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), Data(0), Data(1), FlipX, FlipY)
			If Disabled = 0 Then 
				Select Case CurrentMode 
					Case 0'lines
						Plist.Add(Trig.SetPoint(CurrentPoint.x, CurrentPoint.Y))					
					Case 1'curves
						GrabbedPoints = GrabPoints(SVG, CurrentPointID+1, 2,Points,FlipX,FlipY,FirstPoint)
						Dim PT2 As Point = GrabbedPoints.Get(0), PT3 As Point = GrabbedPoints.Get(1)
						LCARSeffects4.MakeCurve( CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, PT3.X,PT3.Y, 1/CurveDT, Plist)
						Disabled=1

					Case 4,7,8'oval, rectangle, circle
						Dim PT2 As Point = GrabPointsSize(SVG, CurrentPointID, Radius, FirstPoint)
						If IsInShape(X,Y, CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, Angle, CurrentMode) Then Return True 
						Disabled=2
						
					Case 6'bicubic curve
						If CurrentPointID < SVG.Size - 3 Then 
							GrabbedPoints = GrabPoints(SVG, CurrentPointID+1, 3, Points,FlipX,FlipY,FirstPoint)
							Dim PT2 As Point = GrabbedPoints.Get(0), PT3 As Point = GrabbedPoints.Get(1), PT4 As Point = GrabbedPoints.Get(2)
							Bicubic2(Plist, CurrentPoint.X, CurrentPoint.Y, PT2.X, PT2.Y, PT4.X, PT4.Y, PT3.X, PT3.Y, CurveDT)
							Disabled = BicubicDisabled(SVG, CurrentPointID)
						End If 
				End Select 
			Else 
				Disabled = Disabled - 1
			End If 
			JustRemoved=False
		End If
	Next
	If Plist.Size> 0 Then Return CheckPointInPolygon(Plist,X,Y)
End Sub
'Shape: 4=oval,7=rectangle,8=circle
public Sub IsInShape(X As Int, Y As Int, centerX As Int, centerY As Int, RadiusX As Int, RadiusY As Int, Angle As Int, Shape As Int) As Boolean 
	'Dim Dest As Rect = LCARSeffects4.SetRect(centerX-RadiusX,centerY-RadiusY,RadiusX*2,RadiusY*2)
	Dim temp As Int, temp2 As Int, temp3 As Int, tempP As Point
	Select Case Shape
		Case 4'oval
			temp = Trig.CorrectAngle(Trig.GetCorrectAngle(centerX,centerY,X,Y) - Angle)
			'tempP = RotatePointAround(Trig.SetPoint(X,Y), centerX, centerY, -Angle)
			tempP = Trig.findOvalXY(centerX,centerY, RadiusX, RadiusY, temp) 
			Return Trig.FindDistance(centerX,centerY,X,Y) <= Trig.FindDistance(centerX,centerY, tempP.X, tempP.Y)	
			
		Case 7'rectangle
			tempP = RotatePointAround(Trig.SetPoint(X,Y), centerX, centerY, -Angle)
			If tempP.X >= centerX-RadiusX And tempP.X <= centerX+RadiusX Then 
				Return tempP.y >= centerY-RadiusY And tempP.y <= centerY+RadiusY
			End If
			
		Case 8'circle
			Return Trig.FindDistance(centerX,centerY,X,Y) <= Min(RadiusX, RadiusY)
	End Select
End Sub



'Leave OnlyCheck as -1 to check every ID
Sub GetClickedCardassian(Width As Int, Height As Int, X As Int, Y As Int, OnlyCheck As Int) As Int'assume starting X and Y are both 0 since X and Y are normalized to it
	Dim temp As Int, CurrentAnchor As Anchor, Angle As Int, Start As Int, Finish As Int = Anchors.Size -1
	If OnlyCheck > -1 Then 
		Start = OnlyCheck
		Finish = OnlyCheck
	End If
	For temp = Start To Finish
		CurrentAnchor = Anchors.Get(temp)
		If CurrentAnchor.LockedtoAnchor Then 
			Angle = 360-CurrentAnchor.AngleFromAnchor.Current + CurrentAnchor.AngleOrientation.Current
		Else
			Angle = CurrentAnchor.AngleOrientation.Current
		End If
		If CurrentAnchor.Alpha.Current > 0 Then 
			If CurrentAnchor.SVGid < 0 Then'circle
				If CurrentAnchor.Radius.Current > 0 Then 
					If Trig.FindDistance(CurrentAnchor.X, CurrentAnchor.Y, X, Y) <= CurrentAnchor.Radius.Current Then Return temp
				End If 
			Else 
				If CheckPointInRotatedSVG(CurrentAnchor.X, CurrentAnchor.Y, CurrentAnchor.SVGid, CurrentAnchor.Radius.Current, Angle, CurrentAnchor.FlipX,CurrentAnchor.FlipY, 0.2, X,Y) Then Return temp'SVG
			End If  
		End If 
	Next
	Return -1 
End Sub

Sub GetAnchor(ID As Int) As Int
	If ID = -1 Then Return -1
	Dim CurrentAnchor As Anchor = Anchors.Get(ID), SVGid As Int = CurrentAnchor.SVGid
	If CurrentAnchor.AnchorTo > -1 Then Return CurrentAnchor.AnchorTo
	If CurrentAnchor.GroupID > -1 Then Return CurrentAnchor.GroupID
	Return -1 
End Sub

Sub CRD_AssignGroups(Groups As Map)
	Dim ID As Int, CurrentAnchor As Anchor, SVGid As Int, temp As Int, temp2 As Int, Range As List  
	If Groups.Size = 0 Then'Hardcoded
		For ID = 0 To Anchors.size - 1 
			CurrentAnchor = Anchors.Get(ID)
			SVGid = CurrentAnchor.SVGid
			Select Case SVGFile & SVGscreen
				Case "cardassian0"
					If ID < 18 Then 
						CurrentAnchor.GroupID = 0
					else If ID < 36 Or (ID > 134 And ID < 153) Then 
						CurrentAnchor.GroupID = ID - (SVGid-10)
					else if ID < 78 Or (ID > 152 And ID < 195) Then 
						CurrentAnchor.GroupID = ID - (SVGid-3)
					else if ID < 96 Or (ID > 194 And ID < 213) Then 
						CurrentAnchor.GroupID = ID - SVGid
					else if ID < 102 Or ID > 212 Then 
						CurrentAnchor.GroupID = ID - (SVGid-13)
					else if ID < 117 Then 
						CurrentAnchor.GroupID = 102
					else if ID < 135 Then 
						CurrentAnchor.GroupID = ID - (SVGid-19)
					End If
				Case "cardassian1"
					If ID < 35 Then 
						If SVGid = 2 Then 'swap
							SVGid = 3 
						else if SVGid = 3 Then 
							SVGid = 2
						End If 
						CurrentAnchor.GroupID = ID - SVGid
					else If ID < 68 Then 
						CurrentAnchor.GroupID = ID - (SVGid-11)
					else if ID < 108 Then 
						CurrentAnchor.GroupID = ID - (SVGid-14)
					else if ID < 124 Then 
						CurrentAnchor.GroupID = ID - (SVGid-21)	
					else if ID < 132 Then 
						CurrentAnchor.GroupID = ID - (SVGid-24)	
					Else
						CurrentAnchor.GroupID = 132
					End If
			End Select 
			'Log(SVGFile & SVGscreen & "." & ID & "=" & CurrentAnchor.GroupID)
		Next
	Else
		For temp = 0 To Groups.Size - 1 
			ID = Groups.GetKeyAt(temp)
			Range = API.SplitRange(Groups.GetValueAt(temp))
			For temp2 = 0 To Range.Size - 1 
				CurrentAnchor = Range.Get(temp2)
				CurrentAnchor.GroupID = ID 
			Next 
		Next
	End If 
End Sub

Sub CRD_HandleMouse(X As Int, Y As Int, Action As Int, Width As Int, Height As Int)
	Dim OldGroup As Int = SelectedSVGanchor, DoIT As Boolean
	Select Case Action
		'Case LCAR.LCAR_Dpad 'X: 0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
		Case LCAR.Event_Move
			Games.NewXYLOC.X = Games.NewXYLOC.X+X
			Games.NewXYLOC.Y = Games.NewXYLOC.Y+Y		
			CRD_HandleMouse(Games.NewXYLOC.X, Games.NewXYLOC.Y, LCAR.Event_Move_Absolute, Width, Height)
			Return 
			
		Case LCAR.Event_Move_Absolute
			If SelectedSVG = -1 Then 
				SelectedSVG = GetClickedCardassian(Width, Height, X,Y, -1)
			Else if GetClickedCardassian(Width, Height, X,Y, SelectedSVG) = -1 Then 'only check them all if the mouse has left the clicked one
				SelectedSVG = GetClickedCardassian(Width, Height, X, Y, -1)
			End If 
			'DoIT=True 
			SelectedSVGanchor = GetAnchor(SelectedSVG)
			
		Case LCAR.Event_Up'Down, I don't know why it's reversed...
			Games.XYLOC = Trig.SetPoint(X,Y)
			SelectedSVG = GetClickedCardassian(Width, Height, X,Y, -1)
			SelectedSVGanchor = GetAnchor(SelectedSVG)
			DoIT=True 
			
		Case LCAR.Event_Down'UP
			SelectedSVG=-1
			SelectedSVGanchor=-1
	End Select
	If OldGroup <> SelectedSVGanchor And SelectedSVGanchor > -1 And DoIT And WallpaperService.PreviewMode And CardassianKeytone > 0 Then Games.PlayFile(CardassianKeytone - 2)'0=off, 1=random, 2-8 = keytones 0-6
	'Log("CRD_HandleMouse X: " & X & " Y: " & Y & " Width: " & Width & " Height: " & Height & " SelectedSVG: " & SelectedSVG & " SelectedSVGanchor: " & SelectedSVGanchor)
End Sub

'Add keytones to LoadCardassianINI