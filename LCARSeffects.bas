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
	'Nav stuff
	Dim NAVALPHA As Int =64
	Dim NAVMAXDISTANCE As Int =10
	Dim NAVMAXLINETHICKNESS As Int =20
	Dim NAVMAXMODIFIER As Double =0.75
	Dim NAVSTARS As Boolean =True
	
	'Stars for GPS and nav
	Dim STARCACHE As List
	Type CachedStar(X As Int,Y As Int, Text As String, Magnitude As Int) 
	
	'GPS Stuff
	Dim GPSCoordinates As List ,GPSPoints As List , Starfleet As Bitmap , Klingon As Bitmap ,positionmoved As Point , gridpos As Point ,Largest As Int,GPSAzimuth As Int ,DoKlingon As Boolean
	Dim StarshipID As String, StarshipName As String, StarshipCaptain As String 
	
	'Prompt stuff
	Dim PromptID As Int,Prompt2Btns As Boolean, PromptQID As Int, PromptGroup As Int, BarHeight As Int=32, BarWidth As Int=BarHeight*3,IsMultiline As Boolean ,QuestionAsked As Boolean 
	Dim PromptHeight As Int=200,	PromptWidth As Int ,	was2buttons As Boolean ',Width2 As Int :
	
	'BorgStuff
	Dim BorgCount As Int=1, 	BorgScaleFactor As Double=1, BorgScaleFactorDirection As Double= 0.1, BorgOffset As Int, BorgOffsetDirection As Int=1
	
	'Frame stuff
	Dim FrameGroup1 As Int, FrameGroup2 As Int ,FrameElement As Int ,FrameLeftBar As Int ,NeedsRedrawFrame As Boolean ,NeedsLeftBar As Boolean , FrameOffset As Int,FrameBitsVisible As Boolean ,BlockFrame As Boolean 
	
	'Dpad stuff
	Dim DpadCenter As Float =0.125
	
	'Okudagram stuff
	Type OkudaSegment(SegmentType As Int, Top As Double, Bottom As Double, Left As Double, Right As Double, ColorID As Int, BlinkColorID As Int, Blinking As Boolean)
	Type Okudagram( Grid(10, 40) As OkudaSegment )
	Dim OkudaColsPerQuadrant As Int=10, OkudaRows As Int =10,OkudaColWidth As Double=360 / (OkudaColsPerQuadrant * 4) , OkudaLineWidth As Double=OkudaColWidth / 8 , Okuda As Okudagram, GridLines As Boolean , OkudaSeg As OkudaSegment, Okudatool As Int,SelectedSegment As Int, SelectedGrid As Point     ', Okudagrams As List
	Dim Blank As Int,aCircle As Int=1, aSquare As Int=2, SemiCircle As Int=3, Lines As Int=4, Bar As Int=5,  NoLine As Int, Color1Line As Int=1, Color2Line As Int=2, LoadedOkuda As Int , CachedAngles As List
		
	'Condition status alert stuff
	Dim OkudaStages As Int=25,CachedRadius As Int
	
	'SensorSweep and ShieldStatus Stuff
	Dim Enterprise As Bitmap, MaxShieldStages As Int=16
	
	'GradientStuff
	Type GradientCache(ColorID As Int, State As Boolean, Stages(16) As Int )
	Dim Gradients As List 
	
	'ENT E stuff
	Type ENTpoint(X As Float, Y As Float, Alpha As TweenAlpha)
	Dim ENTEpoints As List, ENTEx As TweenAlpha, ENTEy As TweenAlpha
	
	'.Initialize 
	Okuda.Initialize :OkudaSeg.Initialize :SelectedGrid.Initialize :Gradients.Initialize :STARCACHE.Initialize 'rows
	Starfleet.Initialize(File.DirAssets,"insigniasmall.png")
	Klingon.Initialize(File.DirAssets,"klingonsmall.png")
End Sub
Sub CacheGradient(ColorID As Int, State As Boolean) As Int
	Dim temp As Int , tempcache As GradientCache,tempcolor As LCARColor,R As Int, G As Int, B As Int ,temp2 As Double 
	For temp = 0 To Gradients.Size-1
		tempcache=Gradients.Get(temp)
		If tempcache.ColorID=ColorID And tempcache.State=State Then Return temp
	Next
	tempcache.Initialize 
	tempcache.ColorID=ColorID
	tempcache.State=State
	tempcolor=LCAR.LCARcolors.get(ColorID)
	If State Then 
		R=tempcolor.sR 
		G=tempcolor.sG
		B=tempcolor.sB 
	Else
		R=tempcolor.nR 
		G=tempcolor.nG
		B=tempcolor.nB
	End If
	For temp = 0 To 15
		temp2=temp/15 
		tempcache.stages(temp) = Colors.RGB(  R * temp2, G*temp2, B*temp2)
	Next
	Gradients.Add(tempcache)
	Return Gradients.Size-1
End Sub




Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String, tTypeFace As Typeface, IsHeight As Boolean ) As Int 
	Dim temp As Int,CurrentHeight As Int 
	Do Until temp >=  DesiredHeight
		CurrentHeight=CurrentHeight+1
		If IsHeight Then
			temp = BG.MeasureStringHeight(Text,tTypeFace, CurrentHeight)
		Else
			temp = BG.MeasureStringWidth(Text,tTypeFace, CurrentHeight)
		End If
	Loop
	If temp>DesiredHeight Then CurrentHeight=CurrentHeight-1
	Return CurrentHeight
End Sub


Sub SmallScreenMode
	Dim BarWidth2 As Int = 50, BarHeight2 As Int = 10
	BarHeight=LCAR.ItemHeight
	If LCAR.SmallScreen Then
		BarWidth=33 
	Else
		BarWidth=66
		BarWidth2=200 * LCAR.GetScalemode 
		BarHeight2=34
	End If
	PromptWidth= BarWidth+ LCAR.LCARCornerElbow2.width 
	
	If FrameElement>0 Then 'resize frame
		LCAR.ResizeElbowDimensions(FrameElement+1, BarWidth2, BarHeight2)
		LCAR.ResizeElbowDimensions(FrameElement+6, BarWidth2, BarHeight2)
	End If
	If PromptID>0 Then'resize prompt
		BarWidth=BarWidth2/2
		LCAR.ResizeElbowDimensions(PromptID,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+1,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+2,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+3,BarWidth,BarHeight)
	End If
End Sub









Sub ResizeLeftBar(Index As Int, Index2 As Int)
	Dim Y As Int =256,Width As Int=100
	If LCAR.SmallScreen Then 
		Y= 132
		Width=50
	Else If LCAR.CrazyRez>0 Then
		Y= LCAR.GetScaledPosition(4,False)'  Y*LCAR.CrazyRez
		Width=Width*LCAR.CrazyRez
	End If
	If Index = -1 Then 'hidekb, enlarge element 17
		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width,-1,0,-Index2, 255,255, True,True)
	Else'showkb, shrink element 17
		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width, Index2 ,0,Abs(Index2)-4, 255,255, True,True)
	End If
End Sub
Sub NextStage(Element1 As Int, Element2 As Int, LastStage As Int)
	LCAR.Stage=LCAR.Stage+1
	LCAR.LCAR_HideElement(Null, Element1, False,True,False)
	LCAR.LCAR_HideElement(Null, Element2,False,True,False)
	If NeedsLeftBar And LCAR.Stage=LastStage Then LCAR.LCAR_HideElement(Null, FrameElement+11,False,True,False)'stage was 7
End Sub
Sub IsFrameVisible As Boolean 
	Return LCAR.GroupVisible(FrameGroup1) And FrameGroup1>0 
End Sub
Sub ShowFrame(BG As Canvas, DoAnimation As Boolean, LeftBar As Boolean,Stage As Int ) 
	Dim Element As LCARelement, OneThird As Int,X As Int,X2 As Int, Factor As Float = 1, temp As Int, Whitespace As Int = LCAR.ListitemWhiteSpace 'ForceElementData
	Dim Top As Int = 145, Bottom As Int = 165
	If Stage=-1 Then Stage = 3
	If BlockFrame Then Return
	LCAR.DrawFPS=False
	OneThird= LCAR.ScaleWidth/3
	NeedsLeftBar=LeftBar
	'elements 6-17, (group 3 and 5)	
	
	If LCAR.GroupVisible(FrameGroup1) And LCAR.GroupVisible(FrameGroup2) And Not(NeedsRedrawFrame) Then Return False
	
	
	If DoAnimation Then LCAR.LCAR_HideAll(BG,False)
	
	LCAR.Stage=Stage
	LCAR.HideGroup(FrameGroup1,True,True)
	LCAR.HideGroup(FrameGroup2,True,True)
	
	If LCAR.SmallScreen Then
		LCAR.ForceElementData(FrameElement, 0,0,0,35,50,35,0,-35,0,255,True,DoAnimation)'top left square
		
		X=LCAR.ForceElementData(FrameElement+1,0, 38, 0,0,  OneThird,  44, -OneThird+ 50, 0, 0,255,True,DoAnimation)+3'7 and 12 elbows
		LCAR.ForceElementData(FrameElement+6,0,85, 0,0,  OneThird, 44, -OneThird+ 50 , 0, 0,255,True,DoAnimation)
		
		X2=LCAR.ForceElementData(FrameElement+2, X, 72, 0,0,  12, 10,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3'8 and 13 small squares
		LCAR.ForceElementData(FrameElement+7, X, 85, 0,0,  12, 10, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
		
		X=LCAR.ForceElementData(FrameElement+3, X2,   72, 0,        0,     OneThird-15, 10, -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'9 and 14 long rectangles
		LCAR.ForceElementData(FrameElement+8, X2,   85, 0,        0,     OneThird-15, 5,      -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
		
		X2=LCAR.ForceElementData(FrameElement+4, X,72,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'10 and 15 long rectangles
		LCAR.ForceElementData(FrameElement+9, X,85,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
		
		LCAR.ForceElementData(FrameElement+5, X2,72,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) '11 and 16 small squares
		LCAR.ForceElementData(FrameElement+10, X2,85,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) 
		
		LCAR.ForceElementData(FrameElement+11, 0,132+FrameOffset, 0,0, 50,LCAR.ScaleHeight-132-FrameOffset,0,-(LCAR.ScaleHeight-132-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
	Else 
		If LCAR.CrazyRez>1 Then 
			Factor=LCAR.CrazyRez
			Bottom = Bottom*Factor - (Whitespace*2)
			Top=Bottom - ((17*Factor)+Whitespace)
		End If
		
		LCAR.ForceElementData(FrameElement, 0,0,0,71*Factor,100*Factor,71*Factor,0,-71*Factor,0,255,True,DoAnimation)'top left square width=100, height=71
		
		'7 and 12 elbows			0,75,358,88,100,17,
		'If Factor > 2 Then X = Factor * 2 + ((Factor-3)*2)
		temp=(100*Factor)
		X2=temp*1.33
		If Factor <3 Then X=88*Factor Else X = Bottom - (71*Factor) - Whitespace*2
		X=LCAR.ForceElementData(FrameElement+1,	 	0, 71*Factor + Whitespace, 0,0,        X2, X , -X2+temp, 0, 0,255,True,DoAnimation)+3
		LCAR.ForceElementData(FrameElement+6,     0, Bottom, 0,0,      X2 , 88*Factor, -X2+temp , 0, 0,255,True,DoAnimation)
		
		OneThird = (LCAR.ScaleWidth - X+2) / 2
		
		Element=LCAR.LCARelements.Get(FrameElement+1)
		Element.LWidth=100*Factor
		Element.rWidth=17*Factor
		
		Select Case Factor
			Case 1.5: Element.Size.currY = Element.Size.currY - 4
			Case 2.5: Element.Size.currY = Element.Size.currY + 2
		End Select
		
		Element=LCAR.LCARelements.Get(FrameElement+6)
		Element.LWidth=100*Factor
		Element.rWidth=17*Factor
		
		'8 and 13 small squares		361,146,23,17,
		X2=LCAR.ForceElementData(FrameElement+2, X, Top, 0,0,  23*Factor, 17*Factor,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+7, X, Bottom, 0,0,  23*Factor, 17*Factor, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
		
		'9 and 14 long rectangles	388,146,118,17
		temp=OneThird - (23*Factor) - Whitespace' OneThird-26
		X=LCAR.ForceElementData(FrameElement+3,      X2,   Top, 0,        0,    temp, 17*Factor,      -temp, 0,0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+8,      X2,   Bottom, 0,        0,     temp, 6*Factor,      -temp, 0,0,255,Not(DoAnimation),DoAnimation)
		
		'10 and 15 long rectangles	509,146,-27,17
		X2=LCAR.ForceElementData(FrameElement+4, X,Top,0,0, temp, 17*Factor,-temp, 0,0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+9, X,Bottom,0,0, temp, 17*Factor,-temp, 0,0,255,Not(DoAnimation),DoAnimation)
		
		'11 and 16 small squares	-24,146,24,17
		LCAR.ForceElementData(FrameElement+5, X2,Top,0,0, 23*Factor,17*Factor,0,0,0,255,Not(DoAnimation),DoAnimation) 
		LCAR.ForceElementData(FrameElement+10, X2,Bottom,0,0, 23*Factor,17*Factor,0,0,0,255,Not(DoAnimation),DoAnimation) 
		
		'If leftbar Then				  '0,256,100,-1,0,0,  lcar.ScaleHeight-256
		
		X=Bottom +  (88*Factor) + Whitespace    '250*Factor + Whitespace*2'  API.iif(LCAR.crazyrez, 503,256)
		LCAR.ForceElementData(FrameElement+11,   0,X+FrameOffset, 0,0, 100*Factor,LCAR.ScaleHeight-X-FrameOffset,0,-(LCAR.ScaleHeight-X-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
	End If
	If Not(NeedsLeftBar) Then 'LCAR.ForceHide(FrameElement+11) 
		LCAR.LCAR_HideElement(BG, FrameElement+11, False, False,True)
	End If
	
	NeedsRedrawFrame= False
	FrameBitsVisible=True
End Sub

Sub MoveListY(ListID As Int)As Boolean  
	Dim Element As LCARelement ,AvailableSpace As Int  ,tList As LCARlist ,Y As Int = LCAR.GetScaledPosition(4,False)'= api.IIF(lcar.SmallScreen,12,17 * lcar.GetScalemode)
	If FrameElement>0 And FrameElement+6 < LCAR.LCARelements.size And ListID < LCAR.LCARlists.Size Then
		Element = LCAR.LCARelements.Get(FrameElement+6)
		tList= LCAR.LCARlists.Get(ListID)
		AvailableSpace = Max(0,Floor((Element.Size.currY + Element.Size.offY - Element.RWidth) / LCAR.ListItemsHeight(1)))'(Element.Size.currY + Element.Size.offY)
		'Y=Element.LOC.currY + Element.LOC.offY + Element.Size.currY + Element.Size.offY
		'If LCAR.ItemHeight <= AvailableSpace Then
		'	Y = Y - LCAR.ItemHeight
		'Else
		'	Y=Y + LCAR.ListitemWhiteSpace
		'End If
		'Log("Moving list " & ListID & " from " & tList.LOC.currY & " to " & Y & " to fit in " & AvailableSpace)
		tList.LOC.currY = Y - (AvailableSpace*LCAR.ListItemsHeight(1))
		tList.LOC.offY=0
		
		If ListID<>4 Then
			tList.LOC.currX = LCAR.GetScaledPosition(3,True) 'API.IIF(LCAR.SmallScreen, 50,100) + LCAR.ChartSpace
			tList.LOC.offX=0
		End If
		
		tList.IsClean=False
		Return True
	End If
End Sub

Sub MakeFrame(Group1 As Int, Group2 As Int)
	'frame top half (group 3)
	FrameGroup1=Group1
	FrameElement = LCAR.LCAR_AddLCAR("TopLeft", 0, 0,0,100,71,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 2,True,0,0)'element 6 button
	LCAR.LCAR_AddLCAR("TopElbo", 0, 0,75,358,88,100,17, LCAR.LCAR_DarkPurple, LCAR.LCAR_Elbow ,"","","", Group1, False, 0, True, 2,0)'element 7 elbow
	LCAR.LCAR_AddLCAR("MidLef1", 0, 361,146,23,17,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 8 short -
	LCAR.LCAR_AddLCAR("MidLef2", 0, 388,146,118,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 9 100x -
	LCAR.LCAR_AddLCAR("MidLef3", 0, 509,146,-27,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 10 variable -
	LCAR.LCAR_AddLCAR("MidLef4", 0, -24,146,24,17,0,0, LCAR.LCAR_Red, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 11 last -
	
	'frame bottom half (group 5)
	FrameGroup2=Group2
	LCAR.LCAR_AddLCAR("Mi2Left", 0, 0,167,358,71,100,17, LCAR.LCAR_Red, LCAR.LCAR_Elbow, "", "", "" , Group2, False,  0,True,0,0)'element 12 elbow
	LCAR.LCAR_AddLCAR("Mi2Lef1", 0, 361,167,23,17,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 13 short -
	LCAR.LCAR_AddLCAR("Mi2Lef2", 0, 388,167,118,6,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 14 100x -
	LCAR.LCAR_AddLCAR("Mi2Lef3", 0, 509,167,-27,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 15 variable -
	LCAR.LCAR_AddLCAR("Mi2Lef4", 0, -24,167,24,17,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 16 last -
	
	FrameLeftBar= LCAR.LCAR_AddLCAR("LeftBar", 0, 0,256,100, -1,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", Group2, False,8,True,0,0)'element 17'left bar if needed
	LCAR.SetAsync(FrameLeftBar, False)
	LCAR.ReorderGroup(FrameLeftBar,0)
	
	LCAR.HideGroup(Group1,False,False)
	LCAR.HideGroup(Group2,False,False)
End Sub
Sub HideAllFrameBits(BG As Canvas, Fade As Boolean, Visible As Boolean)
	HideFrameBits(BG,True, Fade,Visible)
	HideFrameBits(BG,False, Fade,Visible)
End Sub
Sub HideFrameBits(BG As Canvas, isTop As Boolean, Fade As Boolean, Visible As Boolean   )
	Dim temp As Int, Start As Int 
	Start=FrameElement + API.IIF(isTop, 2, 7)
	For temp = Start To Start + 3
		If Visible Then
			LCAR.ForceShow(temp, True)
		Else
			LCAR.LCAR_HideElement(BG, temp, False, Visible, Not(Fade) )
		End If
	Next
	FrameBitsVisible=Visible
End Sub

Sub ResizeFrame(Offset As Int)
	Dim Y As Int = LCAR.GetScaledPosition(4,False)
	'If LCAR.SmallScreen Then Y=132 Else Y= 256
	If Offset<0 Then
		FrameOffset=LCAR.ListItemsHeight(Abs(Offset))
	Else
		FrameOffset=Offset
	End If
	LCAR.ForceElementData(FrameElement+11,  0,Y+FrameOffset, 0,0,100*LCAR.GetScalemode ,LCAR.ScaleHeight-Y-FrameOffset,0,-(LCAR.ScaleHeight-Y-FrameOffset),0,255, True,False) 
End Sub







Sub DrawBorg(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int)'
	Dim DarkGreen As Int=Colors.RGB(0,120,0),LightGreen As Int=Colors.RGB(0,255,0), temp As Int,Radius As Int=LCAR.ItemHeight*BorgScaleFactor

	X=X+Width/2-1
	Y=Y+Height/2-1
	BG.DrawCircle(X, Y, LCAR.ItemHeight, DarkGreen,True,0)

	DrawBorgArm(BG, X,Y, Angle+270, BorgOffset, Radius , BorgCount, DarkGreen, LightGreen)
	DrawBorgArm(BG, X,Y, Angle+180, BorgOffset, Radius , BorgCount, DarkGreen, LightGreen)
	DrawBorgArm(BG, X,Y, Angle+90, BorgOffset, Radius , BorgCount, DarkGreen, LightGreen)
	DrawBorgArm(BG, X,Y, Angle, BorgOffset, Radius , BorgCount, DarkGreen, LightGreen) 'If Then BorgCount=BorgCount+1
	
	BorgScaleFactor=BorgScaleFactor+BorgScaleFactorDirection
	If BorgScaleFactor>=1.4 Or BorgScaleFactor < 0.2 Then BorgScaleFactorDirection=BorgScaleFactorDirection*-1
	BorgOffset=BorgOffset+BorgOffsetDirection
	If Abs(BorgOffset) >15 Then  BorgOffsetDirection=BorgOffsetDirection*-1
	
	If BorgCount<40 Then BorgCount=BorgCount+1
	
	X=X-Width/2
	Y=Y-Height/2
	
	DrawBorgRandom(BG, X, Y, Width, Height)
End Sub
Sub DrawBorgRandom(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	If LCARSeffects2.InitRandomNumbers(LCAR.LCAR_Borg, False ) Then
		LCARSeffects2.AddRowOfNumbers(0, LCAR.Classic_Green, Array As Int(-2,-1,1,-1))
		LCARSeffects2.AddRowOfNumbers(0, LCAR.Classic_Green, Array As Int(-2,-1,1,-1))
		LCARSeffects2.AddRowOfNumbers(0, LCAR.Classic_Green, Array As Int(-2,-1,1,-1))
	
		LCARSeffects2.AddRowOfNumbers(0, LCAR.Classic_Green, Array As Int(4,1))
		LCARSeffects2.AddRowOfNumbers(0, LCAR.LCAR_White, Array As Int(2,1, 9,1))
		LCARSeffects2.AddRowOfNumbers(0, LCAR.Classic_Green, Array As Int(2,1, 7,1))

		LCARSeffects2.AddRowOfNumbers(1, LCAR.Classic_Green, Array As Int(2,1, 4,-1))
		LCARSeffects2.AddRowOfNumbers(1, LCAR.Classic_Green, Array As Int(2,1, 4,-1))
		LCARSeffects2.AddRowOfNumbers(1, LCAR.Classic_Green, Array As Int(4,1))
		LCARSeffects2.DuplicateFirstLines(1, 5)
	End If
	
	Dim temp As Int = LCAR.Fontsize*2
	LCARSeffects2.DrawRandomNumbers(BG, X,Y + BG.MeasureStringHeight("0123", LCAR.LCARfont,temp)*2 , LCAR.LCARfont,  temp,   0,0,   0)
	LCARSeffects2.DrawRandomNumbers(BG, X+Width*0.5,Y + Height*0.75,  LCAR.LCARfont,  temp,   0,0,   1)
End Sub
Sub DrawBorgArm(BG As Canvas,X As Int, Y As Int, Angle As Int, AngleOffset As Int, Radius As Int, Fingers As Int, DarkGreen As Int, LightGreen As Int)As Boolean 
	Dim X2 As Int, Y2 As Int, temp As Int 
	Angle=Trig.CorrectAngle( Angle+AngleOffset)

	For temp = 1 To Fingers
		X2=Trig.findXYAngle(X,Y, Radius, Angle, True)
		Y2=Trig.findXYAngle(X,Y, Radius, Angle, False)
		
		BG.DrawCircle(X2, Y2, Radius,  API.IIF(IsEven(temp), DarkGreen, LightGreen), True,1)
		Angle=Trig.CorrectAngle( Angle+AngleOffset)
		
		X=X2
		Y=Y2
	Next
	
	If X > -1 And X < LCAR.ScaleWidth And Y>-1 And Y < LCAR.ScaleHeight Then Return True 
End Sub
Sub IsEven(Number As Int) As Boolean 
	Return (Number Mod 2) = 0
End Sub	









Sub MakePrompt(SurfaceID As Int, Group As Int)As Int
	Dim Width2 As Int,Y As Int 
	
	PromptGroup=Group
	'lcar.LCAR_AddLCAR("TopElbo", 0, 0,75,358,88,100,17, lcar.LCAR_DarkPurple, lcar.LCAR_Elbow ,"","","", 3, False, 0, True, 2,0)'element 7 elbow
	PromptID= LCAR.LCAR_AddLCAR("PromptTopRight", SurfaceID, -PromptWidth,0,0,PromptHeight+1, BarWidth,BarHeight, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,1,0)
	LCAR.LCAR_AddLCAR("PromptTopLeft", SurfaceID, 0,0,  -PromptWidth+1,PromptHeight, BarWidth,BarHeight, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "PROMPT", "", "", Group, False, 10,False,0,0)'+1
	LCAR.LCAR_AddLCAR("PromptBotLeft", SurfaceID, 0,PromptHeight-1, PromptWidth  ,PromptHeight, BarWidth,BarHeight*2, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,2,0)'+2
	LCAR.LCAR_AddLCAR("PromptBotRight", SurfaceID, -PromptWidth,PromptHeight-1, PromptWidth  ,PromptHeight, BarWidth,BarHeight*2, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,3,0)'+3
	
	LCAR.LCAR_AddLCAR("PromptText", SurfaceID, PromptWidth, BarHeight+LCAR.LCARCornerElbow2.Height,-PromptWidth, 18,-1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox ,"","","", Group, False,1,False,0,0)'+4
	
	Width2=(LCAR.ScaleWidth/2) - PromptWidth-5
	Y=PromptHeight*2-BarHeight*2-1
	LCAR.LCAR_AddLCAR("PromptYes",SurfaceID, PromptWidth+3,Y, Width2,  BarHeight*2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "YES", "", "", Group, False, 5,True,0,0)'+5 left
	LCAR.LCAR_AddLCAR("PromptNo",SurfaceID, PromptWidth+Width2+6,Y, -PromptWidth-3,  BarHeight*2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "NO", "", "", Group, False, 5,True,0,0)'+6 right
	
	Return PromptID
End Sub
Sub IsPromptVisible(BG As Canvas) As Boolean 
	If LCAR.GroupVisible(PromptGroup) Then
		If Not(BG=Null)Then	ShowPrompt(BG,-1, "", "", 0, "", "")
		Return True
	End If
End Sub

Sub HidePrompt
	LCAR.HideGroup(PromptGroup,False,False)
End Sub

'negative number animation stage=keyboard mode
Sub ShowPrompt(BG As Canvas, AnimationStage As Int, Prompt As String, Text As String, QuestionID As Int, RightBtn As String,  LeftBtnOPTIONAL As String )
	Dim X As Int = 100 * LCAR.GetScalemode + LCAR.LCARCornerElbow2.Width , Y As Int,DoAnimation As Boolean ,Y2 As Int,Width2 As Int,KBmode As Boolean , Height As Int, Y3 As Int, Width3 As Int = LCAR.ScaleWidth - X*2, Corner As Int 
	If X>100 Or BarHeight>100 Then Corner = Min(BarHeight, X) * 0.5 Else Corner = LCAR.LCARCornerElbow2.Height 

	LCAR.LCAR_HideAll(BG,False)
	QuestionAsked=False
	'Element= LCARelements.Get(KBCancelID+5)		Element.ElementType = API.IIF(Enabled, LCAR_MultiLine, LCAR_Textbox)
	If AnimationStage<0 Then
		If AnimationStage=-999 Then AnimationStage=0 Else AnimationStage=Abs(AnimationStage)
		LCAR.ShowKeyboard(BG,AnimationStage)
		KBmode=True
	End If
	
	DoAnimation= AnimationStage>0
	If Not(DoAnimation) Then
		If QuestionID>0 And IsMultiline Then QuestionID = -QuestionID
		LCAR.RemoveAnimation(LCAR.KBListID,True)
	End If
	'log("405 b")
	LCAR.SetRedAlert(False,"ShowPrompt")
	If PromptHeight*2> LCAR.ScaleHeight Then PromptHeight=LCAR.ScaleHeight/2
	'Width=PromptHeight
	If LCAR.IsKeyboardVisible(Null,0,False) Or KBmode Then 
		KBmode=True
		QuestionAsked=True
		Y2=(LCAR.ScaleHeight - LCAR.KeyboardHeight ) / 2
		'Log("SH: " & LCAR.ScaleHeight & " PH: " &  PromptHeight & " Y2: " & Y2 & " KBH: " & LCAR.KeyboardHeight)
		'If PromptHeight>Y2 Then PromptHeight=Y2
		PromptHeight=Y2
		IsMultiline = QuestionID<0
	Else
		Y= (LCAR.ScaleHeight/2)-PromptHeight
		IsMultiline=False
	End If
	Y2=Y+PromptHeight*2-BarHeight*2-1
	If AnimationStage>0 Then	 Prompt2Btns= LeftBtnOPTIONAL.Length>0 Else Prompt2Btns= was2buttons
	If LCAR.ElbowTextHeight=0 Then LCAR.ElbowTextHeight = LCAR.GetTextHeight(BG,  BarHeight, "PROMPT")'BarHeight
	
	'If QuestionID>=0 Then'replace x/width with Width
	If KBmode Then
		LCAR.ForceElementData(PromptID, 	-PromptWidth,Y, 					0, PromptHeight*2-BarHeight, 		0, PromptHeight*2+1,  													0,-PromptHeight*2+BarHeight, 			0,255,True, DoAnimation)'top right
		LCAR.ForceElementData(PromptID+1, 	0,Y,								0, PromptHeight*2-BarHeight, 		-PromptWidth+1, PromptHeight*2,											0,-PromptHeight*2+BarHeight,			0,255,True,DoAnimation)'top left+caption
	Else
		LCAR.ForceElementData(PromptID, 	-PromptWidth,Y, 					0, PromptHeight-BarHeight, 		0, PromptHeight+1,  													0,-PromptHeight+BarHeight, 			0,255,True, DoAnimation)'top right
		LCAR.ForceElementData(PromptID+1, 	0,Y,								0,PromptHeight-BarHeight, 		-PromptWidth+1, PromptHeight,											0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'top left+caption
		LCAR.ForceElementData(PromptID+2,	0,Y+PromptHeight-1,					0,0, 							API.IIF(Prompt2Btns, PromptWidth,LCAR.ScaleWidth/2-2),PromptHeight,		0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'bottom left
		LCAR.ForceElementData(PromptID+3, 	-PromptWidth,Y+PromptHeight-1,		0,0,							0,PromptHeight,															0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'bottom right
	End If
	Width2=(LCAR.ScaleWidth/2) - PromptWidth-5' PromptWidth-5'LCAR.LCARCornerElbow2.Width -5'
	Height = LCAR.ItemHeight' API.IIF(LCAR.CrazyRez = 0, BarHeight*2, BarHeight)'       API.IIF(LCAR.SmallScreen, BarHeight, BarHeight*2)
	Y3 = API.IIF(LCAR.SmallScreen, Y2+BarHeight, Y2)
	
	If Not(IsMultiline) Then	LCAR.ForceElementData(PromptID+4, X, Y+BarHeight+ Corner, 0, PromptHeight-BarHeight, -X,18,0,0,0,255,True,DoAnimation)'Text
	'If Not(IsMultiline) Then LCAR.ForceElementData(PromptID+4, PromptWidth, Y+BarHeight+LCAR.LCARCornerElbow2.Height, 0, PromptHeight-BarHeight, -PromptWidth,18,0,0,0,255,True,DoAnimation)'Text
	If KBmode Then 
		LCAR.ToggleMultiLine(IsMultiline)
		If IsMultiline Then
			QuestionID=Abs(QuestionID)
			'LCAR.ForceElementData(LCAR.KBCancelID+5, 0,0,      0,0,        -1,PromptHeight,        0,0,           0 ,255,True,AnimationStage>0)'KBText
			Y3=Y2-Y-BarHeight-LCAR.LCARCornerElbow2.Height
			Y2=Y+BarHeight+LCAR.LCARCornerElbow2.Height
			'Y3=PromptHeight*2'-BarHeight*2
			LCAR.LCAR_HideElement(BG,PromptID+4,False,False,True)
			LCAR.ForceElementData(LCAR.KBCancelID+5, 	X, Y2, 	 0, PromptHeight*2, 	-X,Y3,0,0,0,255,True,DoAnimation)'Text
		Else
			LCAR.ForceElementData(PromptID+4, 	X, Y+BarHeight+Corner,  	0, PromptHeight*2, 	-X,18,0,0,0,255,True,DoAnimation)'Text
			Y3=Y2+10'-lcar.KeyboardHeight  -API.TextHeightAtHeight(BG, LCAR.LCARfont, "ABCDEFyqpjg", LCAR.BigTextboxHeight) '-50 + API.IIF(LCAR.SmallScreen, BarHeight,0) - 5
			LCAR.ForceElementData(LCAR.KBCancelID+5, X, Y3, 0,-PromptHeight+BarHeight,  -X, 40,0,0,0 ,255,True,AnimationStage>0)'KBText
		End If
	Else		
		LCAR.ForceElementData(PromptID+6, 	PromptWidth+Width2+6,Y3+Height,	 		0,-PromptHeight+Height,		-PromptWidth-3,Height,													0,0,								0,255,True, DoAnimation)' NO (right button)
		LCAR.ForceElementData(PromptID+5, 	PromptWidth+3,Y3+Height,					0,-PromptHeight+Height,		Width2, Height,															0,0,								0,255,True, DoAnimation)' OK (left button)
	End If
	LCAR.HideGroup(PromptGroup, True,False)
	
	If DoAnimation Then
		PromptQID=QuestionID
		Text= API.TextWrap(BG, LCAR.LCARfont, 18, Text.ToUpperCase,     Min(LCAR.ScaleWidth,LCAR.ScaleHeight)-PromptWidth*2 )
		LCAR.LCAR_SetElementText(PromptID+1,Prompt.ToUpperCase, "")
		If IsMultiline Then LCAR.LCAR_SetElementText(PromptID+4,"","") Else LCAR.LCAR_SetElementText(PromptID+4,"", Text.ToUpperCase & " ")
		LCAR.LCAR_SetElementText(PromptID+6, RightBtn.ToUpperCase, "")
		
		was2buttons=Prompt2Btns
		If Prompt2Btns Then
			LCAR.LCAR_SetElementText(PromptID+5, LeftBtnOPTIONAL.ToUpperCase , "")
		'Else
		'	LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
		End If
		LCAR.Stage=AnimationStage
	End If
	If Not (was2buttons) Then LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
End Sub


Sub GetGPScoordinate(ID As Int) As Location 
	If GPSCoordinates.Size>ID Then Return GPSCoordinates.Get(ID)
End Sub

Sub AddGPScoordinate(ID As Int, Coordinates As Location, ListID As Int, Save As Boolean,Settings As Map )
	Dim Count As Int, COORD2 As Location 
	COORD2.Initialize2(Coordinates.Latitude, Coordinates.Longitude)
	If ID=-1 Or ID>= GPSCoordinates.Size  Then 
		GPSCoordinates.Add(COORD2)
	Else
		If ID=0 Then
			If gridpos.IsInitialized Then
				positionmoved = CompareGPScoordinate( GPSCoordinates.Get(0), COORD2)
				gridpos.X= gridpos.X - positionmoved.X 
				gridpos.Y=gridpos.Y-positionmoved.y
			Else
				gridpos.Initialize 
			End If
		End If
		GPSCoordinates.Set(ID,COORD2)
	End If
	If ID=-1 And ListID>-1 Then 
		'tempstr=API.IIF(LCAR.SmallScreen,"P", "PROBE ") & ResizeGPS(GPSitems+1)
		LCAR.LCAR_AddListItem(ListID, API.IIF(LCAR.SmallScreen,"P ", "PROBE ") & (GPSCoordinates.size-2), LCAR.LCAR_Random, ID,ID,False,"",0,False,-1)
		If Save Then
			Count=Settings.GetDefault("SavedCoordinates", 0)
			Settings.Put("SavedCoordinates", Count+1 )
			Settings.Put("SavedCoordinate" & Count,CoordToString(COORD2))
		End If
	End If
End Sub

Sub CoordToString(Coord As Location) As String 
	Dim tempstr As String
	tempstr= Coord.ConvertToSeconds( Coord.Latitude ) & "," & Coord.ConvertToSeconds( Coord.Longitude )
	Return tempstr
End Sub
Sub StringToCoord(Coord As String) As Location 
	Dim Coords() As String , LOC As Location 
	Try
		If Coord.Contains(",") Then
			Coords = Regex.Split(",", Coord)
			LOC.Initialize2( Coords(0), Coords(1) )
		End If
	Catch
	End Try
	Return LOC
End Sub

Sub NewShip
	StarshipID =""
	StarshipName =""
	StarshipCaptain =""
End Sub
Sub ClearGPScoordinates(Settings As Map)
	Dim Count As Int 
	Count = Settings.GetDefault("SavedCoordinates", 0)
	For temp = 0 To Count-1
		Settings.Remove("SavedCoordinate" & temp)
		If GPSPoints.IsInitialized Then  GPSPoints.RemoveAt(GPSPoints.Size -1)
	Next
	Settings.Put("SavedCoordinates", 0)
End Sub

Sub LoadGPScoordinates(Settings As Map, ListID As Int)As Int 
	Dim temploc As Location ,temp As Int, Count As Int , COORD As Location 
	If Not (GPSCoordinates.IsInitialized ) Then
		temploc.Initialize 
		GPSCoordinates.Initialize 
		AddGPScoordinate(0,temploc, -1, False,Settings)
		AddGPScoordinate(1,temploc, -1, False,Settings)
		Count = Settings.GetDefault("SavedCoordinates", 0)
		If Count<0 Then Settings.Put("SavedCoordinates", 0 )
		For temp = 0 To Count-1
			COORD=StringToCoord( Settings.Get("SavedCoordinate" & temp))
			If COORD.IsInitialized Then
				AddGPScoordinate(-1, COORD  , ListID, False,Settings)
			End If
		Next
		Return Count
	End If
End Sub
Sub RemoveGPScoordinate(ID As Int, Settings As Map)As Boolean 
	Dim temp As Int, Count As Int 
	If ID>1 Then
		'lcar.LCAR_RemoveListitem(listid,id+1)'LISTEN,CONNECT,DEPLOY,PROBE 0 (ID=2, INDEX=3) HARDCODED=BAD
		GPSCoordinates.RemoveAt(ID)
		Count = Settings.GetDefault("SavedCoordinates", 0)
		If Count>1 Then
			For temp = ID To Count-2
				Settings.Put("SavedCoordinate" & temp, Settings.Get("SavedCoordinate" & (temp+1)))
			Next
		End If
		Count=Count-1
		Settings.Put("SavedCoordinates", Count)
		Settings.Remove("SavedCoordinate" & Count)
		Return True
	End If
End Sub

Sub CompareGPScoordinate(Origin As Location, LOC As Location) As Point
	Dim Distance As Float, Angle As Float, Position As Point 
	Distance = Origin.DistanceTo(LOC)
	Angle = Trig.CorrectAngle( Origin.BearingTo(LOC) + GPSAzimuth)
	Position.X=Trig.findXYAngle(0,0, Distance, Angle,True)
	Position.Y=Trig.findXYAngle(0,0, Distance, Angle,False)
	Return Position
End Sub

Sub FindGPSscale( )  As Int 
	Dim temp As Int, LOC As Location,cLOC As Location, Position As Point 
	LOC=GPSCoordinates.Get(0)
	If GPSPoints.IsInitialized Then Position = GPSPoints.Get(0)
	GPSPoints.Initialize 
	Position.Initialize 
	GPSPoints.Add(Position)
	Largest=0
	For temp = 1 To GPSCoordinates.Size-1
		Position.Initialize 
		If temp>1 Or DoKlingon Then
			cLOC = GPSCoordinates.Get(temp)
			If cLOC.Latitude<>0 And cLOC.Longitude<>0 Then	Position=CompareGPScoordinate(LOC,cLOC)
		End If
		GPSPoints.Add(Position)
		
		Position.X=Abs(Position.X)
		If Position.X>Largest Then Largest=Position.X
		Position.Y=Abs(Position.Y)
		If Position.Y>Largest Then Largest=Position.Y
	Next
	Return Largest
End Sub

Sub DrawCompass(BG As Canvas, X As Int, Y As Int, Radius As Int, Angle As Int)
	Dim Color As Int 
	LCAR.ActivateAA(BG, True)
	BG.DrawCircle(X,Y, Radius, Colors.Black, True,0)
	Color=LCAR.GetColor(LCAR.LCAR_Orange, False, 255)
	BG.DrawCircle(X,Y, Radius, Color, False,1)
	BG.DrawCircle(X,Y, Radius-4, Color, False,3)
	DrawLine(BG, X,Y, Angle, 0, Radius-6, Color, 2)
	LCAR.ActivateAA(BG, False)
End Sub
Sub DrawGPS(BG As Canvas, X As Int, Y As Int, Width As Int, height As Int, Scale As Int) As Int'Scale = Meters per pixel
	Dim  temp As Int,SmallestAxis As Int,BiggestAxis As Int,LOC As Point , cX As Int, cY As Int, GridWidth As Int, GridHeight As Int
	SmallestAxis=Width
	BiggestAxis=height
	If height< Width Then 
		SmallestAxis = height
		BiggestAxis=Width
	End If
	
	GridWidth=BiggestAxis*0.25
	GridHeight=SmallestAxis*0.25
	If gridpos.IsInitialized Then
		If gridpos.X>0 Then 
			gridpos.X=gridpos.X-GridWidth
		Else If gridpos.X<GridWidth Then
			gridpos.X=gridpos.X+GridWidth
		End If
		If gridpos.Y>0 Then 
			gridpos.Y=gridpos.Y-GridHeight
		Else If gridpos.Y<GridHeight Then
			gridpos.Y=gridpos.Y+GridHeight
		End If
		DrawGrid(BG,X,Y,Width,height, GridWidth,GridHeight, gridpos.X, gridpos.Y,False, -1,-1,-1)
	End If	
	DrawCompass(BG, X+20,Y+20, 20, GPSAzimuth)
	'LCAR.DrawText(BG, X+40,Y, GPSAzimuth & DateTime.Now, LCAR.lcar_orange, 1,False,255,0)
	'dependant on coordinates of first point and scale 
	'drawgrid(bg, X,Y,Width,Height,SmallestAxis,BiggestAxis , 0.5,0.5, 0.25)
	
	X= X+Width/2
	Y=Y+height/2
	DrawBitmap(BG, Starfleet, X,Y)
	
	If GPSPoints.IsInitialized Then
		For temp = 1 To GPSPoints.Size-1
			LOC= GPSPoints.Get(temp)
			'LCAR.DrawText(BG, X, Y+ (temp-1)*20,   LOC.X & "-" & LOC.Y, LCAR.LCAR_Orange,4,False,255,0)
			If temp>1 Or LOC.X<>0 Or LOC.Y<>0 Then
				cX = X + (LOC.X / Scale)
				cY= Y+ (LOC.Y/Scale)
				If temp=1 Then
					DrawBitmap(BG, Klingon, cX,cY)
					LCAR.DrawText(BG,cX + Klingon.Width +2, cY, StarshipCaptain, LCAR.LCAR_Orange, 7, False,255,0)					
				Else
					DrawBitmap(BG, Starfleet, cX,cY)
				End If
			End If
		Next
	End If
	
	BG.RemoveClip
	Return Scale
End Sub 

Sub DrawBitmap(BG As Canvas, BMP As Bitmap, X As Int, Y As Int)
	BG.DrawBitmap(BMP, Null, LCAR.SetRect( X - BMP.Width/2, Y - BMP.Height/2, BMP.Width, BMP.Height))
End Sub





Sub DrawGrid(BG As Canvas, X As Int, Y As Int , Width As Int, Height As Int,gridwidth As Int,gridheight As Int, gridX As Int, gridY As Int,UseCachedPoints As Boolean, GridColorID As Int, TextColorID As Int, StarColorID As Int)
	Dim  temp As Int, gridstarty As Int, p As Path,gridstartx As Int ,Color As Int,tempstr As String ,ColorOrange As Int, px As Int, py As Int, tempstar As CachedStar
	If Width>0 And Height>0 Then
		If GridColorID = -1 Then GridColorID = LCAR.LCAR_DarkPurple
		If TextColorID = -1 Then TextColorID = LCAR.LCAR_Orange
		If StarColorID = -1 Then StarColorID = LCAR.LCAR_Orange
		p.Initialize(X,Y)
		p.LineTo(X+Width,Y)
		p.LineTo(X+Width, Y+Height)
		p.LineTo(X,Y+Height)
		p.LineTo(X,Y)
		BG.ClipPath(p)
		
		'gridwidth=BiggestAxis*Scale
		'gridheight=SmallestAxis*Scale
		
		BG.DrawRect( LCAR.SetRect(X,Y,Width+1,Height+1), Colors.Black , True,3)'clear screen
		Color=LCAR.GetColor(GridColorID, False,255)'LCAR.LCAR_DarkPurple
		ColorOrange=LCAR.GetColor(StarColorID, False,255)'LCAR.LCAR_Orange
		
		If gridY>0 Then 
			Do Until gridY <1
				gridY=gridY-gridheight
			Loop
		End If
		If gridX>0 Then
			Do Until gridX<1
				gridX=gridX-gridwidth
			Loop
		End If
	
		gridstarty=Y+gridY'-gridheight*yoffset
		'gridstartxtemp=-gridwidth*xoffset
		For currentz=0 To Ceil(Height/gridheight)+2
			gridstartx=X+gridX
			For temp = 0 To Ceil(Width/gridwidth)+1
				BG.DrawRect(LCAR.SetRect(gridstartx,gridstarty,gridwidth,gridheight), Color,False,1)
				If UseCachedPoints Then
					tempstar=GetCachedStar(temp,currentz,gridstartx,gridstarty, gridwidth,gridheight)
					tempstr=tempstar.Text ' Abs(((currentz+1)*gridstartx) + ((temp+1)*gridstarty))
					If TextColorID > 0 Then LCAR.DrawText(BG, gridstartx+5, gridstarty+5, tempstr , TextColorID , 1,False,255,0)
					If NAVSTARS And tempstr>999 Then 
						px=gridstartx+ tempstar.X 'gridstartx + (gridwidth* (api.Mid(tempstr,2,1)*0.1))
						py=gridstarty + tempstar.Y '(gridheight* (api.Mid(tempstr,3,1)*0.1))
						If px>X And py>Y Then BG.DrawCircle(px, py,  tempstar.Magnitude, ColorOrange, True,1)
					End If
				End If
				gridstartx=gridstartx+gridwidth
			Next
			gridstarty=gridstarty+gridheight
		Next
	End If
End Sub



Sub RandomStar(X As Int, Y As Int, gridstartx As Int,gridstarty As Int, gridwidth As Int,gridheight As Int) As CachedStar 
	Dim temp As CachedStar 
	temp.Initialize 
	temp.Text =Abs(((X+1)*gridstartx) + ((Y+1)*gridstarty)) 'temp2
	temp.X = Rnd(0,gridwidth)
	temp.Y = Rnd(0,gridheight)
	temp.Magnitude = Rnd(0, 10)
	Return temp
End Sub 

Sub GetCachedStar(X As Int, Y As Int, gridstartx As Int,gridstarty As Int, gridwidth As Int,gridheight As Int) As CachedStar 
	Dim temp As CachedStar , Col As List 
	
	If STARCACHE.Size <= Y Then
		temp=RandomStar(X,Y,gridstartx,gridstarty, gridwidth,gridheight)
		Col.Initialize
		Col.Add(temp)
		STARCACHE.Add(Col)
	Else
		Col = STARCACHE.Get(Y)
		If Col.Size <= X Then
			temp=RandomStar(X,Y,gridstartx,gridstarty, gridwidth,gridheight)
			Col.Add(temp)
			STARCACHE.Set(Y, Col)
		Else
			temp = Col.Get(X)
		End If
	End If
	
	Return temp
End Sub

Sub UniqueFilename(Dir As String, Filename As String, Append As String ) As String
	Dim temp As Int ,Lindex As Int, Lpart As String , Rpart As String ,DT As Boolean 
	If Append.Length=0 Then
		Append=" (#)"
	Else If Append = "DATETIME" Then
		DT = True
		'1 space, 10 date, 1 space, 5 time, 17 total  			'8 time, 20 total
		Append = " " & API.getDate(DateTime.now).Replace("/", "-").Replace("\", "-") & " " & DateTime.GetHour(DateTime.Now) & "-" & DateTime.GetMinute(DateTime.Now) 'DateTime.Time(DateTime.now).Replace(":", "-")
	End If
	
	If File.Exists(Dir, Filename) Or DT Then
		Lindex= Filename.LastIndexOf(".")
		If Lindex=-1 Then
			Lpart=Filename
		Else
			Lpart = Filename.SubString2(0,Lindex)
			Rpart = Filename.SubString(Lindex)
		End If
		If DT Then
			Return Lpart & Append & Rpart
		Else
			temp=1
			Do Until Not( File.Exists(Dir, Lpart & Append.Replace("#", temp) & Rpart))
				temp=temp+1
			Loop
			Return Lpart & Append.Replace("#", temp) & Rpart
		End If
	Else
		Return Filename
	End If
End Sub


Sub SaveScreenshot(BMP As Bitmap, Dir As String, FilenamePNG As String )As String 
	Return SaveImage(BMP,Dir,UniqueFilename(Dir, FilenamePNG, "DATETIME"),True)
End Sub
Sub SaveImage(BMP As Bitmap, Dir As String, FilenamePNG As String ,AddtoAndroid As Boolean)As String 
	Dim Out As OutputStream
	Try
		Out = File.OpenOutput(Dir, FilenamePNG, False)
		BMP.WriteToStream(Out, 100, "PNG")
		Out.Close
		If AddtoAndroid Then API.AddImageToAndroid(Dir, FilenamePNG)
		Return Dir & "/" & FilenamePNG
	Catch
		Return ""
	End Try
End Sub

Sub DrawPlaid(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, FirstDistance As Int, StartAngle As Int)
	Dim tempBG As Canvas, Radius As Int, R2 As Int,X2 As Int, Y2 As Int, HalfR As Int 'NeedsInit As Boolean ,
	tempBG= LCARSeffects2.InitUniversalBMP(Width,Height,LCAR.SBALLS_Plaid)
'	If Not(LCARSeffects2.CenterPlatform.IsInitialized ) OR LCARSeffects2.CenterPlatformID <> LCAR.LCAR_StarBase Then 
'		NeedsInit=True
'	Else If LCARSeffects2.CenterPlatform.Height<>Height OR LCARSeffects2.CenterPlatform.Width <> Width Then
'		NeedsInit=True
'	End If
'	If NeedsInit Then 
'		LCARSeffects2.CenterPlatform.InitializeMutable(Width,Height)
'		LCARSeffects2.CenterPlatformID = LCAR.SBALLS_Plaid 
'	End If
'	tempBG.Initialize2(LCARSeffects2.CenterPlatform)
	Radius=Min(Width,Height)
	HalfR=Radius*0.25
	R2=Radius*2
	X2=Width/2
	Y2=Height/2
	
	
	Dim temp As Int, SliceWidth As Double , Angle As Double , Lists(8) As List 
	Dim PointsOnScreen As Int,Distance As Int, DistanceInc As Int , MaxDistance As Int ,Color As Int

	
	SliceWidth= 360/92
	Angle= StartAngle'343
	For temp = 1 To 12 
		Angle = AddSlice(Lists(0), Angle, 2, SliceWidth) 'Orange 1
		If temp Mod 3 > 0 Then Angle = AddSlice(Lists(0), Angle, 2, SliceWidth)'Orange 2 if not the 3rd group
		Angle = AddSlice(Lists(1), Angle, 2, SliceWidth) 'red 1
		Angle = AddSlice(Lists(1), Angle, 2, SliceWidth) 'red 2
		Angle = AddSlice2(Lists(2), 315, Lists(3), Lists(4), Angle, 2, SliceWidth)' faded red 1
		Angle = AddSlice2(Lists(5), 315, Lists(6), Lists(7), Angle, 2, SliceWidth)' faded blue 1
		Angle = AddSlice2(Lists(2), 315, Lists(3), Lists(4), Angle, 2, SliceWidth)' faded red 2
		Angle = AddSlice2(Lists(5), 315, Lists(6), Lists(7), Angle, 2, SliceWidth)' faded blue 2
	Next
	
	'faded red
	temp=LCAR.GetColor(LCAR.LCAR_red, False,164)
	If  Lists(4).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,96), Radius, -0, Lists(4))
	If  Lists(2).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, temp , Radius, -5,Lists(2))
	If  Lists(3).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, temp  , Radius, -10,Lists(3))
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,96)  , Radius, -0, Array As Int(355,357,                                                                                                                180,182))
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,196)  , Radius, -5, Array As Int(       1,3,           36,38,                                            132,134,               148,150,154,156,        186,187,           221,223,             236,238,242,244,                                               324,326 )  )
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,196)  , Radius, -10, Array As Int(                                      53,55,59,61,    86,88,92,94,                                                                                                                  266,268,272,274,     309,311))
	
	'faded blue
	temp=LCAR.GetColor(LCAR.Classic_Blue, False,164)
	If  Lists(7).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.Classic_Blue, False,96), Radius, -0, Lists(7))
	If  Lists(5).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, temp  , Radius, -5,Lists(5))
	If  Lists(6).IsInitialized Then LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, temp  , Radius, -10,Lists(6))
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.Classic_Blue, False,96)  , Radius, -0, Array As Int(358,0,                                                                                                              183,185,188,190))
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.Classic_Blue, False,196)  , Radius, -5, Array As Int(                  39,41,                                            135,137,               151,153,157,159,                           224,226,             239,241,245,247,                                               327,329 )  )
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.Classic_Blue, False,196)  , Radius, -10, Array As Int(                                  56,58,62,64,    89,91,95,97,                                                                                                                  269,271,275,277,     312,314))
	
	'center block
	tempBG.DrawRect(LCAR.SetRect(X2-HalfR,Y2-HalfR,  Radius*0.5,Radius*0.5 ),Colors.Black, True,0)
	
	'sun
	Color = 4
	For temp =  HalfR - NAVMAXDISTANCE*2 To 0 Step -4
		If Color>0 Then
			tempBG.DrawCircle(X2,Y2, temp, LCAR.GetColor(LCAR.LCAR_Orange,False, Color), True, 0)
			Color=Color+8
			If Color>96 Then Color=0
		Else
			tempBG.DrawCircle(X2,Y2, temp, LCAR.GetColor(LCAR.LCAR_Yellow , True, Color), True, 0)
			Color=Color-8
		End If
	Next
	
	'solid 
	LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_Orange, False,255) , Radius, 0, Lists(0))
	LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,255) , Radius, 0, Lists(1))
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_Orange, False,255) , Radius, 0, Array As Int(343,345, 346,348,    24,26, 27,29,    44,46,          74,76, 77,79,    120,122, 123,125,      139,141,             168,170, 171,173,     209,211, 212,214,    227,229,              254,256, 257,259,    297,299, 300,302,   315,317 )  )' ORANGE
	'LCARSeffects2.DrawSegmentedCircle(tempBG,X2,Y2, R2, LCAR.GetColor(LCAR.LCAR_red, False,255) , Radius, 0, Array As Int(   349,351, 352,354,    30,32, 33,35,    47,49, 50,52,   80,82, 83,85,    126,128, 129,131,      142,144, 145,147,    174,176, 177,179,     215,217, 218,220,    230,232, 233,235,     260,262, 263,265,    303,305, 306,308,   318,320, 321,323)  )'RED
	
	'inner sun
	Color=96
	For temp = 24 To 1 Step -1
		tempBG.DrawCircle(X2,Y2, temp, Colors.ARGB(Color,255,255,255), True, 0)
		Color=Color+16
	Next
	
	'flares
	Color=64
	Distance=Colors.ARGB(96,255,255,255)
	For temp = 1 To 8
		LCAR.DrawGradient(tempBG, Distance ,Distance-1 , 6, X2-Color,Y2,  Color*2,8, 0, Rnd(0,360) )
	Next
	
	'inner 2 squares
	temp = HalfR - NAVMAXDISTANCE*3 + FirstDistance*3
	tempBG.DrawRect( LCAR.SetRect( X2-temp, Y2- temp, temp*2, temp*2), LCAR.GetColor(LCAR.LCAR_Orange, False,255), False, 5)
	temp=temp+5
	tempBG.DrawRect( LCAR.SetRect( X2-temp, Y2- temp, temp*2, temp*2), LCAR.GetColor(LCAR.LCAR_red, False,164), False, 5)
	Color= LCAR.GetColor(LCAR.LCAR_Orange, False,128)
	PointsOnScreen=100: Distance = HalfR: MaxDistance= Max(Width,Height)
	DistanceInc=5+FirstDistance'MaxDistance/PointsOnScreen+FirstDistance
	
	'squares flying towards/away from user
	For temp=1 To PointsOnScreen Step 2
		Distance=Distance + DistanceInc*2

		tempBG.DrawRect( LCAR.SetRect( X2-Distance, Y2- Distance, Distance*2, Distance*2), Color, False, temp)
		'DrawNavPoint(BG,X,Y,Width,Height,SmallestAxis,FOV, Distance,MaxDistance, Angle, CurrentZ, temp=PointsOnScreen-1)
		
		DistanceInc=DistanceInc+1
		If DistanceInc>MaxDistance Then temp=PointsOnScreen
	Next

	LCAR.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)'blank it out so alphas are preserved properly
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCAR.SetRect(X,Y,Width,Height))'purge framebuffer
End Sub

'12 groups of 2 oranges (every third group only has 1 orange), 2 reds, faded orange, faded blue, faded orange, faded blue (8 slices total per group except for every third which has 7)
'total slices = (8+8+7)*4 = 23*4 = 92 slices
Sub AddSlice2(List1 As List, Start As Int,  List2 As List, List3 As List, Angle As Int, Width As Int, TotalWidth As Double) As Double 
	If (Angle<360 And Angle+Width>360) Or (Angle<180  And Angle+Width>180) Or (Angle> Width And Angle<35) Or (Angle>180 And Angle <210) Then 
		Return AddSlice(List3, Angle, Width,TotalWidth)
	Else If (Angle >= Start And Angle <= Trig.CorrectAngle( Start+ 90)) Or (Angle>=Trig.CorrectAngle(Start+180) And Angle <=Trig.CorrectAngle(Start+270)) Then
		Return AddSlice(List2, Angle, Width,TotalWidth)
	Else
		Return AddSlice(List1, Angle, Width,TotalWidth)
	End If
End Sub

Sub AddSlice(tList As List, Angle As Int, Width As Int, TotalWidth As Double) As Double 
	If Not(tList.IsInitialized ) Then tList.Initialize 
	tList.Add(Angle)
	tList.Add(Angle+Width)
	Return Ceil( Angle+TotalWidth Mod 360)
End Sub


Sub DrawNavigation(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Azimuth As Int, AngleZ As Int, PointsOnScreen As Int, FirstDistance As Int, FOV As Int  )
	Dim Angle As Int, AngleInc As Int, Distance As Int , DistanceInc As Int, AngleZinc As Int, CurrentZ As Int,MaxDistance As Int , temp As Int
	Dim SmallestAxis As Int,BiggestAxis As Int ,direction As Int,GridWidth As Int, GridHeight As Int 
	
	SmallestAxis=Width
	BiggestAxis=Height
	If Height< Width Then 
		SmallestAxis = Height
		BiggestAxis=Width
	End If
	
	GridWidth=BiggestAxis*0.25
	GridHeight=SmallestAxis*0.25
	DrawGrid(BG,X,Y,Width,Height, GridWidth,GridHeight, -GridWidth*0.5, -GridHeight*0.5,True, -1,-1,-1)
	
	Distance=FirstDistance
	MaxDistance=NAVMAXDISTANCE*PointsOnScreen*NAVMAXMODIFIER
	DistanceInc=MaxDistance/PointsOnScreen
	AngleZinc=AngleZ/PointsOnScreen
	If Azimuth<-90 Or Azimuth>90 Then direction=-1 Else direction=1
	If Azimuth<0 And Azimuth< -FOV Then 
		Azimuth = -FOV 
	Else If Azimuth>0 And Azimuth>FOV Then 
		Azimuth=FOV
	End If
	AngleInc=Azimuth/PointsOnScreen
	CurrentZ=AngleZinc* (FirstDistance/NAVMAXDISTANCE)
	
	If LCAR.scalewidth>LCAR.scaleheight Then
		SmallestAxis=SmallestAxis*0.75
	End If
	
	'bg.DrawRect( lcar.SetRect(x,y,width,height), lcar.GetColor(lcar.LCAR_Orange, False,255), False,3)'border
	DrawNavPoint(BG,X,Y,Width,Height,SmallestAxis,FOV, FirstDistance,MaxDistance, 0, CurrentZ,False)
	
	For temp=1 To PointsOnScreen-1
		Distance=Distance + DistanceInc
		Angle= Angle+ AngleInc
		CurrentZ=CurrentZ+AngleZinc
		DrawNavPoint(BG,X,Y,Width,Height,SmallestAxis,FOV, Distance,MaxDistance, Angle, CurrentZ, temp=PointsOnScreen-1)
	Next
	BG.RemoveClip
End Sub

Sub DrawNavPoint(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, SmallestAxis As Int,FOV As Int, Distance As Int,MaxDistance As Int, Angle As Int, Z As Int, LastPoint As Boolean )
	Dim Size As Int,Left As Int ,Top As Int,temp As Double , LineThickness As Int,Color As Int,p As Path
	temp=(Distance/MaxDistance)
	Angle=Angle*(1-temp)
	LineThickness=NAVMAXLINETHICKNESS*temp
	Size=temp*SmallestAxis
	Color=LCAR.GetColor(LCAR.LCAR_Orange, False,255)
	
	Left=Width/2 
	Left=X+ Left - (Left * (Angle/FOV))- (Size*0.5)
	If Left-LineThickness<X Then 
		Left=X +LineThickness
	Else If Left+Size+LineThickness > X+Width Then
		Left=X+Width-Size-LineThickness
	End If
	
	Top=Height/2
	Top=Y+Top - (Top* (Z/FOV))-(Size*0.5)
	If Top-LineThickness<Y Then 
		Top=Y+LineThickness
	Else If Top+Size+LineThickness*2 > Y+Height Then
		Top=Y+Height-Size-LineThickness*2
	End If
	
	p.Initialize(X,Y)
	p.LineTo(X+Width,Y)
	p.LineTo(X+Width, Y+Height)
	p.LineTo(X,Y+Height)
	p.LineTo(X,Y)
	BG.ClipPath(p)
	
	If Not(LastPoint) Then BG.DrawRect( LCAR.SetRect(Left-1,Top-LineThickness,Size+2,Size+LineThickness*2), Colors.ARGB(NAVALPHA, 255,255,255), True,0)'middle
	
	BG.DrawRect(  LCAR.setrect(Left-LineThickness,Top,LineThickness,Size), Color,True,0)'left
	BG.DrawRect(  LCAR.setrect(Left-1,Top-LineThickness+1,LineThickness*2,LineThickness), Color,True,0)'left top
	BG.DrawRect(  LCAR.setrect(Left-1,Top+Size-1,LineThickness*2,LineThickness), Color,True,0)'left bottom

	BG.DrawRect(  LCAR.setrect(Left+Size,Top,LineThickness,Size), Color,True,0)'right
	BG.DrawRect(  LCAR.setrect(Left+Size-LineThickness*2+1,Top-LineThickness+1,LineThickness*2,LineThickness), Color,True,0)'right top	
	BG.DrawRect(  LCAR.setrect(Left+Size-LineThickness*2+1,Top+Size-1,LineThickness*2,LineThickness), Color,True,0)'right bottom
	
	DrawPartOfCircle(BG, Left-LineThickness,Top-LineThickness+1,LineThickness,0, Color, X,Y)'left top edge
	DrawPartOfCircle(BG, Left-LineThickness,Top+Size-1,LineThickness,2, Color, X,Y)'left bottom edge
	DrawPartOfCircle(BG, Left+Size,Top-LineThickness+1,LineThickness,1, Color, X,Y)'right top edge
	DrawPartOfCircle(BG, Left+Size,Top+Size-1,LineThickness,3, Color, X,Y)'left top edge
	
	BG.RemoveClip 
End Sub

Sub DrawBrackets(BG As Canvas, Left As Int, Top As Int, Width As Int, Height As Int, Color As Int, DoTop As Boolean)As Int
	Dim LineThickness As Int,Left2 As Int
	LineThickness=10
	LCAR.ActivateAA(BG,True)
	Left2=Left+Width-LineThickness
	If DoTop Then
		DrawPartOfCircle(BG, Left,Top,LineThickness,0, Color, 0,0)'left top corner
		BG.DrawRect(  LCAR.setrect(Left+LineThickness-1,Top,LineThickness*2,LineThickness), Color,True,0)'left top edge -
		BG.DrawRect(  LCAR.setrect(Left,Top+LineThickness-1,LineThickness,Height-LineThickness*2+2), Color,True,0)'left |
		
		DrawPartOfCircle(BG, Left2,Top,LineThickness,1, Color, 0,0)'right top corner
		BG.DrawRect(  LCAR.setrect(Left2-LineThickness*2+1,Top,LineThickness*2,LineThickness), Color,True,0)'right top edge -
		BG.DrawRect(  LCAR.setrect(Left2,Top+LineThickness-1,LineThickness,Height-LineThickness*2+2), Color,True,0)'right |
	Else
		BG.DrawRect(  LCAR.setrect(Left,Top,LineThickness,Height-LineThickness+1), Color,True,0)'left |
		BG.DrawRect(  LCAR.setrect(Left2,Top,LineThickness,Height-LineThickness+1), Color,True,0)'right |
	End If
	
	BG.DrawRect(  LCAR.setrect(Left+LineThickness-1,Top+Height-LineThickness,LineThickness*2,LineThickness), Color,True,0)'left bottom edge
	BG.DrawRect(  LCAR.setrect(Left2-LineThickness*2+1,Top+Height-LineThickness,LineThickness*2,LineThickness), Color,True,0)'right bottom edge -
	
	DrawPartOfCircle(BG, Left,Top+Height-LineThickness,LineThickness,2, Color, 0,0)'left bottom corner
	DrawPartOfCircle(BG, Left2,Top+Height-LineThickness,LineThickness,3, Color, 0,0)'right bottom corner
	LCAR.ActivateAA(BG,False)
	Return LineThickness
End Sub

Sub DrawPartOfCircle(BG As Canvas , X As Int, Y As Int, Radius As Int, Section As Int, Color As Int , Left As Int, Top As Int)
'	Dim P As Path
	MakeClipPath(BG,X,Y,Radius,Radius)
'	P.Initialize(X,Y)
'	P.LineTo(X+Radius-1,Y)
'	P.LineTo(X+Radius-1,Y+Radius-1)
'	P.LineTo(X, Y+Radius-1)
'	P.LineTo(X,Y)
'	BG.ClipPath(P)
	Select Case Section
		Case 0:BG.DrawCircle(X+Radius,Y+Radius, Radius,Color,True,0) 'top left
		Case 1:BG.DrawCircle(X,Y+Radius, Radius,Color,True,0) 'top right	
		Case 2:BG.DrawCircle(X+Radius,Y, Radius,Color,True,0) 'bottom left
		Case 3:BG.DrawCircle(X,Y, Radius,Color,True,0) 'bottom right	
		
		Case 4: Radius=Radius*0.5:BG.DrawCircle(X+Radius, Y+Radius, Radius, Color,True,0)'left
		Case 5: Radius=Radius*0.5:BG.DrawCircle(X, Y+Radius, Radius, Color,True,0)  'right
		Case 6'top
		Case 7'bottom
	End Select
	BG.RemoveClip
End Sub

Sub DrawArc(cnvs As Canvas, x As Float, y As Float, radius As Float, startAngle As Float, endAngle As Float, Color As Int)
    Dim s As Float
    s = startAngle
    startAngle = 180 - endAngle
    endAngle = 180 - s
    If startAngle >= endAngle Then endAngle = endAngle + 360
    Dim p As Path
    p.Initialize(x, y)
    For i = startAngle To endAngle Step 10
        p.LineTo(x + 2 * radius * SinD(i), y + 2 * radius * CosD(i))
    Next
    p.LineTo(x + 2 * radius * SinD(endAngle), y + 2 * radius * CosD(endAngle))
    p.LineTo(x, y)
    cnvs.ClipPath(p) 'We are limiting the drawings to the required slice
    cnvs.DrawCircle(x, y, radius, Color, True, 0)
    cnvs.RemoveClip
End Sub




















Sub DrawCirLCAR(BG As Canvas, Circ As Okudagram, X As Int, Y As Int, Radius As Int, Blink As Boolean, Alpha As Int, Era As Int)
    Dim Row As Int, Col As Int, CurrAngle As Int, Height As Int, Color As Int, TempColor As Int,Width As Int 
    Dim cStart As Int, cFinish As Int, temp As Int, temp2 As Int, temp3 As Double , X2 As Int, Y2 As Int,OS As OkudaSegment , BarAngle As Int
    Height = Radius / OkudaRows
    cFinish = Height
	Width=OkudaColWidth
	CacheAngles(Radius*2,-1)
    For Row = 0 To OkudaRows-1   
		CurrAngle=0
		BarAngle=0
        For Col = 0 To OkudaColsPerQuadrant * 4-1
            OS= Circ.Grid(Row, Col)
			If OS.SegmentType>0 Then
                If Blink And OS.Blinking Then Color = OS.BlinkColorID Else Color = OS.ColorID
				If Color>12 Then Color=Color+1
				Select Case Era
					Case 0: Color = LCAR.GetColor(Color, False,  Alpha)'ENT-A
					Case 1: Color = Colors.argb(Alpha, 238,192,34)'ENT-J
				End Select
               
				
                Select Case OS.SegmentType
                    Case aCircle
                        temp = CurrAngle + (Width / 2) - (OS.Left * Width)  
						temp2=cStart + (Height / 2) + (Height * OS.Bottom)
                        X2 = Trig.findXYangle(X, Y, temp2, temp, True)
                        Y2 = Trig.findXYangle(X, Y, temp2, temp, False)
						If OS.Top >2 Then OS.Top = 2
						temp2= OS.Top * (Height / 2)
						If Era = 0 Then 'ENT-A
							BG.drawcircle(X2,Y2, temp2,  Color, True,0)
						Else 'ENT-J
							BG.drawcircle(X2,Y2, temp2,  Colors.Black, True, 0)
							temp2 = temp2 * 0.66
							Color = Colors.ARGB(Alpha, 255,255,255)'White
							BG.drawcircle(X2,Y2, temp2,  Color, True, 0)'White
							temp2 = temp2 - 2
							BG.drawcircle(X2,Y2, temp2,  Colors.ARGB(Alpha, 35,55,101), True, 0)'Navy Blue
							Y2 = Y2 - temp2 * 0.5
							temp2 = temp2 * 0.25
							BG.drawcircle(X2,Y2, temp2,  Color, True, 0)'White
						End If 
						
                    Case aSquare 'size is relative to radius, not height/width
                        Select Case Col+1
                            Case 1, OkudaColsPerQuadrant * 4:                            		temp2 = 0 'Top
                            Case OkudaColsPerQuadrant * 3, OkudaColsPerQuadrant * 3 + 1:     	temp2 = 6 'left
                            Case OkudaColsPerQuadrant, OkudaColsPerQuadrant + 1:              	temp2 = 2 'Right
                            Case OkudaColsPerQuadrant * 2, OkudaColsPerQuadrant * 2 + 1:      	temp2 = 4 'Bottom
                            
                            Case OkudaColsPerQuadrant / 2, OkudaColsPerQuadrant / 2 + 1:      	temp2 = 1 'top right
                            Case OkudaColsPerQuadrant * 1.5, OkudaColsPerQuadrant * 1.5 + 1:  	temp2 = 3
                            Case OkudaColsPerQuadrant * 2.5, OkudaColsPerQuadrant * 2.5 + 1:  	temp2 = 5
                            Case OkudaColsPerQuadrant * 3.5, OkudaColsPerQuadrant * 3.5 + 1:  	temp2 = 7
							Case Else: 															temp2= -1 'Unknown
                        End Select
						If temp2 > -1 Then CirLCAR_DrawSquare( BG, X, Y, Height * OS.Right, Height * OS.Left, temp2, Color, Height * Row)
						
                    Case SemiCircle
						DrawCirLCARsemicircle(BG, X, Y, OS,CurrAngle, cStart, Width, Height, Color, 0,0,0)
						
                    Case Lines
						temp2 = CurrAngle '+ Width
						temp2=DrawCirLCARline(BG, X, Y,  CurrAngle, cStart, cFinish, OS.Top, OS.ColorID, OS.BlinkColorID, Alpha,1)
						temp2=DrawCirLCARline(BG, X, Y,  temp2, cStart, cFinish, OS.Bottom, OS.ColorID, OS.BlinkColorID, Alpha,1)
						temp2=DrawCirLCARline(BG, X, Y,  temp2, cStart, cFinish, OS.Left, OS.ColorID, OS.BlinkColorID, Alpha,1)
						temp2=DrawCirLCARline(BG, X, Y,  temp2, cStart, cFinish, OS.Right, OS.ColorID, OS.BlinkColorID, Alpha,1)
						
                    Case Bar
						temp3 = 0.5
						OS.bottom = (1-temp3)* 0.5
						OS.Top = 1- OS.bottom
						temp2=temp3* Height
						'If BarAngle = 0 Then BarAngle = trig.GetCorrectAngle(x,y,x+temp2/2, y- cStart)'/2
						DrawCirLCARsemicircle(BG, X, Y, OS,CurrAngle, cStart+OS.bottom*Height, Width, temp2, Color,  1, 0, BarAngle)
                        
                    'Case GridLine
                    '    DrawCirLCARsemicircle(BG, X, Y, OS,CurrAngle, cStart, Width, Height, color, 2,1)
						
                End Select
            'End With
			End If
			LCAR.ActivateAA(BG, True)	
			If GridLines Then
				If Row=OkudaRows-1 Then	BG.DrawLine(X,Y, Trig.findXYAngle(X,Y, cFinish, CurrAngle,True)      , Trig.findXYAngle(X,Y, cFinish, CurrAngle,False)         , Colors.Red,1)
				If Row = SelectedGrid.Y And Col = SelectedGrid.X Then
					'DrawCirLCARsemicircle(BG, X, Y, OS,CurrAngle, cStart, Width, Height,  Colors.Blue , 2,3)
					DrawCirLCARline(BG, X, Y,  CurrAngle, cStart, cFinish, 1, LCAR.LCAR_RedAlert , LCAR.LCAR_White , 255,3)
					DrawCirLCARline(BG, X, Y,  CurrAngle+Width, cStart, cFinish,  1, LCAR.LCAR_RedAlert, LCAR.LCAR_White, 255,3)
				End If
			End If
			LCAR.ActivateAA(BG, False)	
            CurrAngle = CurrAngle + Width
            If CurrAngle >= 360 Then CurrAngle = CurrAngle - 360
        Next
        cStart = cStart + Height-1
        cFinish = cStart + Height
		If GridLines Then BG.DrawCircle(X,Y,  cStart, Colors.Red, False,1)
    Next
End Sub


Sub CirLCAR_DrawSquare(BG As Canvas, X As Int, Y As Int, Width As Int, Length As Int, Angle As Int, Color As Int, Start As Int)
    Dim temp As Int, temp2 As Int, X2 As Int, Y2 As Int, X3 As Int, Y3 As Int, NewAngle As Int, P As Path ,PS(4) As Point , Dest As Rect 
    temp = Width / 2
    If Width Mod 1 = 0 Then Width = Width + 1
    Select Case Angle
        Case 0 '  |   up
            BG.DrawRect( LCAR.SetRect( X - temp, Y - Length - Start, Width, Length),  Color, True,0)
        Case 6 '-     left
			BG.DrawRect( LCAR.SetRect(X - Length - Start, Y - temp, Length, Width),  Color, True,0)
        Case 2 '    - right
			BG.DrawRect(  LCAR.SetRect(X + Start, Y - temp, Length, Width),  Color, True,0)
        Case 4 '  |   down
			BG.DrawRect(  LCAR.SetRect( X - temp, Y + Start, Width, Length),  Color, True,0)
        Case Else
			NewAngle= Angle*45
			temp = Width / 3
			
			X2 = Trig.findXYangle(X, Y, Start, NewAngle, True)
            Y2 = Trig.findXYangle(X, Y, Start, NewAngle, False)
			
			X3 = Trig.findXYangle(X, Y, Start+Length-1, NewAngle, True)
            Y3 = Trig.findXYangle(X, Y, Start+Length-1, NewAngle, False)
			
			Select Case Angle
                Case 1 ' \  up right 45		(X2 - temp, Y2 - temp)-(X2 + temp + 1, Y2 + temp + 1)
					PS(0) = SetPoint(X2 - temp, Y2 - temp)'bottom left
					PS(1) = SetPoint(X2 + temp + 1, Y2 + temp + 1)'bottom right
					PS(2) = SetPoint(X3 - temp, Y3 - temp)'top left
					PS(3) = SetPoint(X3 + temp + 1, Y3 + temp + 1)'top right
					Dest.Initialize(PS(0).X, PS(2).Y, PS(3).X, PS(1).Y)
                Case 3 ' /  down right 135	(X2 + temp - 1, Y2 - temp + 1)-(X2 - temp, Y2 + temp)
					PS(0) = SetPoint(X2 + temp - 1, Y2 - temp + 1)'top right
					PS(1) = SetPoint(X2 - temp, Y2 + temp)'top left
					PS(2) = SetPoint(X3 + temp - 1, Y3 - temp + 1)'bottom right
					PS(3) = SetPoint(X3 - temp, Y3 + temp)'bottom left
					Dest.Initialize(PS(1).X, PS(0).Y, PS(2).X, PS(3).Y)
                Case 5 '\   down left 225	(X2 - temp, Y2 - temp)-(X2 + temp + 1, Y2 + temp + 1)
					PS(0) = SetPoint(X2 - temp, Y2 - temp)'top left
					PS(1) = SetPoint(X2 + temp + 1, Y2 + temp + 1)'top right
					PS(2) = SetPoint(X3 - temp, Y3 - temp)'bottom left
					PS(3) = SetPoint(X3 + temp + 1, Y3 + temp + 1)'bottom right
					Dest.Initialize(PS(2).X, PS(0).Y, PS(1).X, PS(3).Y)
                Case 7 '/   up left 315		(X2 + temp - 1, Y2 - temp - 1)-(X2 - temp - 2, Y2 + temp)
					PS(0) = SetPoint(X2 - temp - 2, Y2 + temp)'bottom left
					PS(1) = SetPoint(X2 + temp - 1, Y2 - temp - 1)'bottom right
					PS(2) = SetPoint(X3 - temp - 2, Y3 + temp)'top left
					PS(3) = SetPoint(X3 + temp - 1, Y3 - temp - 1)'top right
					Dest.Initialize(PS(2).X, PS(3).Y, PS(1).X,  PS(0).Y )
            End Select 
			P.Initialize(PS(0).X, PS(0).Y)
			P.LineTo(PS(1).X, PS(1).Y)
			P.LineTo(PS(3).X, PS(3).Y)
			P.LineTo(PS(2).X, PS(2).Y)
			P.LineTo(PS(0).X, PS(0).Y)
            If Dest.IsInitialized Then
            	BG.ClipPath(P)
				BG.DrawRect(Dest, Color, True,0)
				BG.RemoveClip 
			End If
    End Select
End Sub

Sub SetPoint(X As Int, Y As Int) As Point 
	Dim temp As Point
	temp.Initialize
	temp.X=X
	temp.Y=Y
	Return temp
End Sub

Sub DrawCirLCARline(BG As Canvas , X As Int, Y As Int, Angle As Int , StartRadius As Int, EndRadius As Int, OSvalue As Double, ColorID As Int, BlinkColorID As Int, Alpha As Int,Stroke As Int) As Int 
	Dim Color As Int
	Color= LCAR.GetColor(API.IIF(OSvalue=1, ColorID , BlinkColorID ) , False,  Alpha)
	DrawLine(BG, X,Y, Angle, StartRadius, EndRadius, Color ,Stroke )
	Return Angle + OkudaLineWidth * 2
End Sub

Sub DrawCirLCARsemicircle(BG As Canvas, X As Int, Y As Int, OS As OkudaSegment,CurrAngle As Int, cStart As Int, Width As Int, Height As Int, Color As Int, EndType As Int, Stroke As Int, EndAngle As Int) 
	Dim StartRadius As Int ,EndRadius As Int , Degrees As Int ,StartAngle As Int 
	StartRadius=cStart + (OS.Bottom * Height)
	EndRadius = cStart + (OS.Top * Height)
	Degrees=(OS.Right - OS.Left) * Width
	StartAngle= CurrAngle + (OS.Left * Width)  
	
	'If os.Left < 0 Then
	'	StartAngle= CurrAngle + (os.Left * Width)       
    'Else
	'	StartAngle= CurrAngle + ( (os.Right+OS.Left) * Width) + (OS.Left * Width)   
    'End If
	DrawCircleSegment(BG, X, Y, StartRadius,  EndRadius, StartAngle,  Degrees, Color, Stroke, EndType, EndAngle)           
End Sub


Sub CirLCAR_SetAllGridlines(ColorID As Int, BlinkColorID As Int) As Okudagram 
    Dim temp As Long, temp2 As Long, Circ As Okudagram 
	Circ.Initialize 
    For temp = 0 To OkudaRows-1
        For temp2 = 0 To OkudaColsPerQuadrant * 4 -1
            If ColorID = -1 Then
                'CirLCAR_SetBlank Circ, temp, temp2
            Else
                'CirLCAR_SetGridline Circ, temp, temp2, ColorID, BlinkColorID
            End If
        Next
    Next
    Return Circ
End Sub

Sub CacheAngles(RadiusTimes2 As Int, Angle As Int)As Point 
	Dim temp As Int ,res As Point 
	If RadiusTimes2>0 Or Not(CachedAngles.IsInitialized) Then
		If RadiusTimes2= 0 Then  RadiusTimes2 = 10000
		If Not(CachedAngles.IsInitialized) Or (CachedRadius < RadiusTimes2)  Then
			CachedAngles.Initialize 
			For temp =0 To 359
				CachedAngles.Add( Trig.FindAnglePoint(0,0,RadiusTimes2,temp) )
			Next
			CachedRadius=RadiusTimes2
			'For temp =0 To 359
			'	res=CachedAngles.Get(temp)
			'	Log("CHECKING: " & temp & " X: " & res.X & " Y: " & res.Y)
			'Next
		End If
	End If
	If Angle>-1 Then
		Angle=Trig.CorrectAngle( Angle)
		res= CachedAngles.Get(Angle)
		'res.X= X + res.x 'NOT WORKING
		'res.y= Y + res.y 'NOT WORKING
		Return res
	End If
End Sub

Sub DrawCircleSegment(BG As Canvas, X As Int, Y As Int,StartRadius As Int, EndRadius As Int, StartAngle As Int, Degrees As Int, Color As Int, Stroke As Int, EndType As Int, RoundEndAngle As Int )
	Dim X1 As Int=X, X2 As Int, Y1 As Int=Y, Y2 As Int, X3 As Int, Y3 As Int, P As Path,temp As Int,EndAngle As Int, RadiusDelta As Int,RadiusDelta2 As Int,temp2 As Point 
	EndAngle=Trig.CorrectAngle(StartAngle+Degrees-RoundEndAngle)
	StartAngle = Trig.CorrectAngle( StartAngle+RoundEndAngle)
	
	'X1=  Trig.findXYAngle(X,Y, EndRadius*2, StartAngle , True)
	'Y1= Trig.findXYAngle(X,Y, EndRadius*2, StartAngle, False)
	'X2=    Trig.findXYAngle(X,Y, EndRadius*2, EndAngle, True)
	'Y2=   Trig.findXYAngle(X,Y, EndRadius*2, EndAngle, False)
	
	If Degrees = 90 And (StartAngle Mod 90) = 0 Then'AND StartAngle = 180 
		Select Case StartAngle
			Case 180'bottom left
				X1=X-EndRadius
			Case 270'top left
				X1=X-EndRadius
				Y1=Y-EndRadius
			Case 0'top right
				Y1=Y-EndRadius
		End Select
		MakeClipPath(BG,X1,Y1,EndRadius+1,EndRadius+1)
	Else If Degrees<360 Then
		temp2=CacheAngles(0,StartAngle)
		X1=temp2.X + X
		Y1=temp2.Y + Y
		
		temp2=CacheAngles(0,EndAngle)
		X2=temp2.X + X
		Y2=temp2.Y + Y
	
		P.Initialize(X, Y)'center/origin
		P.LineTo(X1,Y1)'start angle @ radius
		
		If Abs(Degrees) > 45 Then
			X3= API.IIF(Degrees>0, 45, -45)
			For Y3 = StartAngle + X3 To EndAngle Step X3 
				temp2 = CacheAngles(0, Y2)
				P.LineTo(temp2.X + X,temp2.Y + Y)
			Next
		End If
		'P.Initialize(X1,Y1)'start angle @ radius
		'If StartRadius=0 Then
		'	P.LineTo(X,Y)'center/origin
		'Else
			'For temp = StartAngle To EndAngle' Step 10
			'	P.LineTo( Trig.findXYAngle(X,Y,StartRadius, temp, True), Trig.findXYAngle(X,Y,StartRadius, temp, False) )
			'Next
		'End If
		
		P.LineTo(X2,Y2)'end angle @ radius
		'P.LineTo(X1,Y1)'start angle @ radius
		P.LineTo(X,Y)'center/origin
	End If
	If P.IsInitialized Then BG.ClipPath(P)
	
	If EndRadius > 0 Then
		temp=(EndRadius-StartRadius)
		'BG.DrawCircle(0,0, StartRadius + temp *0.5, Color, False, temp)
		BG.DrawCircle(X,Y, StartRadius + temp *0.5, Color, False, temp)
	Else
		BG.DrawCircle(X,Y, StartRadius, Color, False, Abs(EndRadius))
	End If
	
	'BG.DrawCircle(X,Y,EndRadius, Color, Stroke=0, Stroke)
	If Degrees<360 Then BG.RemoveClip 
	
	Select Case EndType 
		Case 1'curved
			RadiusDelta2= ( (EndRadius-StartRadius) /2 )
			RadiusDelta=StartRadius + RadiusDelta2
			BG.DrawCircle( Trig.findXYAngle(X,Y,RadiusDelta,StartAngle, True), Trig.findXYAngle(X,Y,RadiusDelta,StartAngle, False),RadiusDelta2,  Color, True, 0)			
			BG.DrawCircle( Trig.findXYAngle(X,Y,RadiusDelta,EndAngle, True), Trig.findXYAngle(X,Y,RadiusDelta,EndAngle, False),RadiusDelta2,  Color, True, 0)
		Case 2'lines
			DrawLine(BG, X,Y,  StartAngle, StartRadius, EndRadius, Color, Stroke)
			DrawLine(BG, X,Y, EndAngle, StartRadius, EndRadius, Color, Stroke)
		Case 3'circle
			BG.DrawCircle( Trig.findXYAngle(X,Y,StartRadius,EndAngle, True), Trig.findXYAngle(X,Y,StartRadius,EndAngle, False),Stroke,  Color, True, 0)
	End Select
End Sub
Sub DrawLine(BG As Canvas, X As Int, Y As Int, Angle As Int, StartRadius As Int, EndRadius As Int, Color As Int, Stroke As Int)As Rect 
	Dim X1 As Int, Y1 As Int,X2 As Int, Y2 As Int,temp As Rect 
	If StartRadius=0 Then
		X1=X
		Y1=Y
	Else
		X1=Trig.findXYAngle(X,Y,StartRadius,Angle, True)
		Y1=Trig.findXYAngle(X,Y,StartRadius,Angle, False)
	End If
	X2=Trig.findXYAngle(X,Y,EndRadius,Angle, True)
	Y2=Trig.findXYAngle(X,Y,EndRadius,Angle, False)
	BG.DrawLine(X1, Y1, X2,Y2, Color, Stroke)
	
	temp.Initialize(X1,Y1,X2,Y2)
	Return temp
End Sub

Sub SaveCirLCAR(O As Okudagram) As String
        Dim D As String,Row As Long, Col As Long, tempstr As StringBuilder, tempstr2 As StringBuilder , OS As OkudaSegment : D = " "
		tempstr.Initialize
        For Row = 0 To OkudaRows-1
            tempstr2.Initialize 
            For Col = 0 To OkudaColsPerQuadrant * 4 -1
				OS= O.Grid(Row,Col)
                'With Cir.Grid(Row, Col)
                    tempstr2.Append( OS.SegmentType & D & OS.ColorID & D & OS.BlinkColorid & D & OS.Top & D & OS.Bottom & D & OS.Left & D & OS.Right & D )
                'End With
            Next
            tempstr.Append(tempstr2.ToString )
        Next
		tempstr.Remove( tempstr.Length -1, tempstr.Length)
        Return tempstr.ToString 
End Sub

Sub LoadCirLCAR(O As Okudagram, Text As String, StartCol As Int, EndCol As Int) As Okudagram 
    Dim Row As Int, Col As Int, tempstr() As String, temp As Int, Required As Int ', OS As OkudaSegment 
    If EndCol <= StartCol Then EndCol = OkudaColsPerQuadrant * 4
    Required = (7 * OkudaRows * OkudaColsPerQuadrant * 4)
    tempstr = Regex.Split(" ", Text)' Split(Text, " ")
    If tempstr.length = Required Then
		
		For temp = 0 To tempstr.Length-1 Step 7
			If Col >= StartCol And Col <= EndCol Then
				'With Cir.Grid(Row, Col)
					O.Grid(Row,Col).Initialize 
					O.Grid(Row,Col).SegmentType = tempstr(temp)
					If O.Grid(Row,Col).SegmentType>0 Then
						O.Grid(Row,Col).ColorID = tempstr(temp + 1)
						O.Grid(Row,Col).BlinkColorID = tempstr(temp + 2)
						O.Grid(Row,Col).Top = tempstr(temp + 3)
						O.Grid(Row,Col).Bottom = tempstr(temp + 4)
						O.Grid(Row,Col).Left = tempstr(temp + 5)
						O.Grid(Row,Col).Right = tempstr(temp + 6)
						'o.Grid(Row,Col) = os
					End If
				'End With
			End If
			
			Col = Col + 1
			If Col >= OkudaColsPerQuadrant * 4 Then
				Col = 0
				Row = Row + 1
			End If
		Next
	End If
	Return O
End Sub

Sub LoadFile(Dir As String, Filename As String) As String 
	If File.Exists(Dir, Filename) Then	
		Return File.ReadString(Dir, Filename)
	End If
End Sub
Sub LoadInternalOkudagram(Index As Int) As String 
	If Index<1 Or Index> 6 Then Index = Rnd(1,7)
	Return LoadFile(File.DirAssets, Index & ".cir")
End Sub

Sub GetInternalOkudagram(Index As Int,Settings As Map) As Okudagram 
	Dim temp As Okudagram, Item As Int , Maxi As Int
	temp.Initialize 
	If Index>0 And Index<7 Then
		temp= LoadCirLCAR(temp, LoadInternalOkudagram(Index), 0,0)
		LoadedOkuda=Index
	Else If Index<0 Then
		Item=OkudaCount(Settings)
		If Abs(Index)>Item Then
			DeleteOkuda(Abs(LoadedOkuda),Item, Settings)
			LoadedOkuda=0
		Else
			temp=LoadOkuda(Settings, Abs(Index))
			LoadedOkuda=Index
		End If
	Else
		Maxi=(OkudaColsPerQuadrant * 4) -1
		For Item = 0 To Maxi Step OkudaColsPerQuadrant / 2
            temp = LoadCirLCAR(temp, LoadInternalOkudagram(0), Item, (Item + OkudaColsPerQuadrant / 2) - 1) 
        Next
		LoadedOkuda=0
	End If
	Return temp
End Sub

Sub OkudaCount(Settings As Map) As Int
	Return Settings.GetDefault("OkudaCount", "0")
End Sub
Sub DeleteOkuda(Index As Int, Count As Int, Settings As Map)
	If Index< Count Then
		Settings.Put("Okuda" & Index,  Settings.Get("Okuda" & Count))
	End If
	Settings.Remove("Okuda" & Count)
	Count=Count-1
	Settings.Put("OkudaCount", Count)
	LoadedOkuda=0
End Sub
Sub SaveOkuda(Settings As Map)
	Dim Count As Int
	Count= OkudaCount(Settings)
	Count=Count+1
	Settings.Put("Okuda" & Count, SaveCirLCAR(Okuda))
	Settings.Put("OkudaCount", Count)
End Sub
Sub LoadOkuda(Settings As Map, Index As Int) As Okudagram 
	Dim temp As Okudagram
	temp.Initialize
	Return LoadCirLCAR(temp, Settings.Get("Okuda" & Index), 0,0)
End Sub
Sub LoadOkudagrams(ListID As Int, Settings As Map)As Int
	Dim Count As Int ,temp As Int 
	Count=OkudaCount(Settings)
	For temp = 1 To Count
		LCAR.LCAR_AddListItem(ListID, API.GetStringVars("okuda_custom", Array As String(temp)), LCAR.LCAR_Random, -1, "", False,  "" , 0,False,-1)
	Next
	If Count>0 And LoadedOkuda<0 Then
		LCAR.LCAR_AddListItem(ListID, API.GetStringVars("okuda_delete", Array As String(Abs(LoadedOkuda))), LCAR.LCAR_Random, -1, "", False,  "" , 0,False,-1)
		Count=Count+1
	End If
	Return Count
End Sub

Sub SelectCoordinate(X As Int, Y As Int)
	If Y<0 Then Y= OkudaRows-1
	If Y>=OkudaRows Then Y = 0
	If X>=(OkudaColsPerQuadrant * 4) -1 Then X= 0 
	If X<0 Then X = (OkudaColsPerQuadrant * 4) -1
	SelectedGrid.X=X
	SelectedGrid.Y=Y
	Select Case Okudatool
		Case 0,2'get,auto
			CopySegment( Okuda.Grid(Y,X), OkudaSeg)
		Case 1'set
			CopySegment(OkudaSeg,  Okuda.Grid(Y,X))
	End Select
	LCAR.IsClean=False
End Sub
Sub SaveSegment
	If Okudatool=2 Then 
		CopySegment(OkudaSeg, Okuda.Grid(SelectedGrid.Y,SelectedGrid.X))
		LCAR.IsClean=False
	End If
End Sub
Sub CopySegment(Src As OkudaSegment, Dest As OkudaSegment)As OkudaSegment
	Dest.Initialize 
	Dest.BlinkColorID= Src.BlinkColorID
	Dest.Blinking= Src.Blinking
	Dest.Bottom= Src.Bottom
	Dest.ColorID= Src.ColorID
	Dest.Left= Src.Left
	Dest.Right= Src.Right
	Dest.SegmentType= Src.SegmentType
	Dest.Top= Src.Top
	Return Dest
End Sub

Sub GetOkudaSegColor(IsBlinking As Boolean) As String 
	Dim Value As Int = API.IIF(IsBlinking, OkudaSeg.BlinkColorID, OkudaSeg.ColorID),Color As LCARColor
	If Value = -1 Then Return API.getstring("okuda_none")
	Color = LCAR.LCARcolors.Get(Value)
	Return Color.Name.ToUpperCase 
End Sub






'0: out of bounds, 1: south east, 2: south, 3: south west, 4: west, 5: center, 6: east, 7: north east, 8: north, 9: north west
Sub GetDPADdirection(X As Int, Y As Int, Width As Int, Height As Int, mouseX As Int, mouseY As Int) As Int
	Dim X2 As Int = Width/2, Y2 As Int = Height/2, CenterX As Int = X+X2, CenterY As Int=Y+Y2, Radius As Int = Min(Width,Height) * DpadCenter ' * 0.5
	If mouseX < X Or mouseX > X+Width Or mouseY < Y Or mouseY > Y+Height Then Return 0'out of bounds
	If mouseX >  CenterX - Radius And mouseX < CenterX+Radius Then'in the middle column
		If mouseY > CenterY - Radius And mouseY < CenterY + Radius Then Return 5'center
		If mouseY < CenterY Then Return 8'north
		If mouseY > CenterY Then Return 2'south
	Else If mouseY >  CenterY - Radius And mouseY < CenterY+Radius Then'in the middle row
		If mouseX < CenterX Then Return 4'west
		If mouseX > CenterX Then Return 6'east
	Else If mouseX < CenterX Then'left side
		If mouseY < CenterY Then Return 7'north east
		If mouseY > CenterY Then Return 1'south east
	Else'right side
		If mouseY < CenterY Then Return 9'north west
		If mouseY > CenterY Then Return 3'south west
	End If
End Sub

Sub DrawDpad(BG As Canvas, X As Int, Y As Int, Radius As Int, ColorID As Int, InnerRadius As Int, InnerColorID As Int, Border As Int, Alpha As Int,BlinkState As Boolean, Direction As Int)
	Dim P As Path , Left As Int , MiddleLeft As Int,MiddleRight As Int, Right As Int  , Top As Int , Bottom As Int , MiddleTop As Int, MiddleBottom As Int, Color As Int,temp As Int 
	Left= X-Radius
	MiddleLeft=X-InnerRadius+1
	MiddleRight=X+InnerRadius-1
	Right= X+Radius
	
	Top=Y-Radius
	MiddleTop=Y-InnerRadius+1
	MiddleBottom=Y+InnerRadius-1
	Bottom=Y+Radius
	
	LCAR.ActivateAA(BG, True)	
	Color=LCAR.GetColor (ColorID, False, Alpha)
	BG.DrawCircle(X,Y, Radius, Color, True, 0)
	LCAR.ActivateAA(BG, False)	
	'bg.DrawRect( lcar.SetRect(x-radius,y-InnerRadius-Border, radius*2, (Border+InnerRadius)*2), Colors.Black, True, 0)'internal + black -
	'bg.DrawRect( lcar.SetRect(x-InnerRadius-Border,y-radius, (Border+InnerRadius)*2, radius*2), Colors.Black, True, 0)'internal + black |
	
	P.Initialize(Left, MiddleTop)'top left corner along left edge
	P.LineTo(MiddleLeft,MiddleTop)'top left corner inside
	P.LineTo(MiddleLeft,Top)'top left corner along top edge
	P.LineTo(MiddleRight, Top)'top right corner along top edge
	P.LineTo(MiddleRight,MiddleTop)'top right corner inside
	P.LineTo(Right, MiddleTop)'top right corner along right edge
	P.LineTo(Right, MiddleBottom)'bottom right corner along right edge
	P.LineTo(MiddleRight,MiddleBottom)'bottom right corner inside
	P.LineTo(MiddleRight, Bottom)'bottom right corner along bottom edge
	P.LineTo(MiddleLeft,Bottom)'bottom left corner along bottom edge
	P.LineTo(MiddleLeft,MiddleBottom)'bottom left corner inside
	P.LineTo(Left,MiddleBottom)'bottom left corner along left edge
	P.LineTo(Left, MiddleTop)'top left corner along left edge (start)
	
	BG.ClipPath(P)
	BG.DrawCircle(X,Y,Radius, LCAR.GetColor (InnerColorID, False, Alpha), True,0)
	BG.RemoveClip 
	
	BG.DrawLine(Left, MiddleTop, Right, MiddleTop, Colors.Black ,Border)
	BG.DrawLine(Left, MiddleBottom, Right, MiddleBottom, Colors.Black ,Border)
	BG.DrawLine(MiddleLeft, Top, MiddleLeft, Bottom, Colors.Black ,Border)
	BG.DrawLine(MiddleRight, Top, MiddleRight, Bottom, Colors.Black ,Border)
	
	BG.DrawRect(  LCAR.SetRect(X - Radius*0.5 - InnerRadius, MiddleTop, InnerRadius, InnerRadius*2), Colors.Black, True,0)'left
	temp=X - Radius*0.5 - InnerRadius+Border
	DrawTriangle(BG, temp+Border, MiddleTop+Border*2, InnerRadius - Border*4, InnerRadius*2 - Border*4, 2, Color)
	BG.DrawLine(temp+Border, MiddleBottom+Border*2  , temp+ InnerRadius - Border*4     , MiddleBottom+Border*2     , Colors.black,Border)'-
	
	BG.DrawRect(  LCAR.SetRect(X + Radius*0.5+1 , MiddleTop, InnerRadius, InnerRadius*2), Colors.Black, True,0)'right
	temp=X + Radius*0.5 +Border+1
	DrawTriangle(BG, temp+Border, MiddleTop+Border*2, InnerRadius - Border*4, InnerRadius*2 - Border*4, 3, Color)
	BG.DrawLine(temp+Border, MiddleTop-Border*2  , temp+ InnerRadius - Border*4     ,  MiddleTop-Border*2  , Colors.black,Border)'-
	
	BG.DrawRect(  LCAR.SetRect(MiddleLeft , Y - Radius*0.5 - InnerRadius , InnerRadius*2, InnerRadius), Colors.Black, True,0)'top
	temp=Y-InnerRadius*1.5
	BG.DrawLine(MiddleLeft,temp, MiddleRight, temp, Colors.black,Border)'|
	DrawTriangle(BG,MiddleLeft+Border*2, Y - Radius*0.5 - InnerRadius+Border*2, InnerRadius*2 - Border*4,InnerRadius - Border*4, 1, Color)
	
	BG.DrawRect(  LCAR.SetRect(MiddleLeft , Y + Radius*0.5+1 , InnerRadius*2, InnerRadius), Colors.Black, True,0)'bottom
	DrawTriangle(BG,MiddleLeft+Border*2, Y + Radius*0.5 +Border*2 +1, InnerRadius*2 - Border*4,InnerRadius - Border*4, 4, Color)
End Sub

'Alignment: 1=north, 2=west, 3=east, 4=south
Sub DrawTriangle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alignment As Int, Color As Int)
	Dim P As Path, Right As Int, Bottom As Int, MiddleX As Int, MiddleY As Int 	
	Select Case Alignment
		Case 1,4'horizontal,    width=height*2
			MiddleX=Height*2
			X=X+ (Width-MiddleX)/2
			Width= MiddleX
		Case Else'vertical,		height=width*2
			MiddleX=Width*2
			Y=Y+ (Height-MiddleX)/2
			Height= MiddleX
	End Select
	
	Right=X+Width-1
	Bottom=Y+Height-1
	MiddleX=X+(Width*0.5)-1
	MiddleY=Y+(Height*0.5)
	Select Case Alignment 
		Case 1'North
			P.Initialize(X, Bottom)
			P.LineTo(Right,Bottom)
			P.LineTo(MiddleX, Y)
			P.LineTo(X, Bottom)
		Case 2'west
			P.Initialize(Right,Y)
			P.Initialize(Right,Bottom)
			P.LineTo(X, MiddleY)
			P.LineTo(Right,Y)
		Case 3'east
			P.Initialize(X,Y)
			P.LineTo(X,Bottom)
			P.LineTo(Right, MiddleY)
			P.LineTo(X,Y)
		Case 4'south
			P.Initialize(X,Y)
			P.LineTo(MiddleX,Bottom)
			P.LineTo(Right,Y)
			P.LineTo(X,Y)
	End Select
	BG.clippath(P)
	If Color <> LCAR.LCAR_Clear Then
		BG.drawrect(LCAR.SetRect(X,Y,Width,Height), Color,True,0)
		BG.RemoveClip 
	End If
End Sub

Sub InitStarshipFont
	'If Not(LCARSeffects2.StarshipFont.IsInitialized) Then LCARSeffects2.StarshipFont=Typeface.LoadFromAssets("federation.ttf")   
End Sub




Sub GetTime(Now As Long) As String 
	Return API.PadtoLength( DateTime.GetHour(Now),True,2,"0") & API.IIF(DateTime.GetSecond(Now) Mod 2=1," ",":") & API.PadtoLength(DateTime.GetMinute(Now),True,2,"0")
End Sub
Sub GetColor(ChargingColor As Int) As Int 
	If LCAR.RedAlert Then
		Return LCAR.RedAlertMode 
	Else If LCAR.isCharging And ChargingColor>0 Then
		Return ChargingColor
	Else If API.IsOuya Or LCAR.BatteryPercent>50 Then 
		Return LCAR.Classic_Green
	Else If LCAR.BatteryPercent>25 Then
		Return LCAR.LCAR_Yellow 
	Else 
		Return LCAR.LCAR_Red 
	End If
End Sub

Sub DrawAlert(BG As Canvas, X As Int, Y As Int, Radius As Int, StatusMode As Int, Stage As Int, Alpha As Int, TextSize As Int, Text As String, Status As String, UseCircle As Boolean)As Int
	Dim Color As Int , P As Path, OneThird As Double, Points(11) As Int, CLR As LCARColor  , temp As Int,Alpha2 As Int, Y2 As Int, Y3 As Int,X2 As Int
	Dim Width As Int,textsize2 As Int, CLR2 As ColorDrawable, Angle As Float, HasColon As Boolean 
	OneThird=1/3	
	If Stage<0 Then 
		Stage=Stage+Stage
	Else if UseCircle Then 
		BG.DrawCircle(X,Y,Radius,Colors.Black,True,0)
	Else 
		BG.drawrect(LCAR.SetRect(X-Radius,Y-Radius,Radius*2,Radius*2), Colors.Black, True,0)
	End If
	If StatusMode<0 Then
		Text = API.GetTimer("Main")
		If Text.Length = 0 Then
			Text=GetTime(DateTime.Now)
			Status=API.getDate(DateTime.Now)
			StatusMode=GetColor(LCAR.Classic_Blue)
		Else
			Text = Text.Replace(":", API.IIF(DateTime.GetSecond(DateTime.Now) Mod 2=1," ",":"))
			Status = API.GetString("alert_destruct")
			StatusMode=LCAR.LCAR_Red 
		End If
		HasColon = Text.Contains(":")
		If HasColon Then Text = Text.Replace(":", " ")
	End If
	If StatusMode>-1 Then
		CLR= LCAR.LCARcolors.Get(StatusMode)
		Color = LCAR.GetColor(StatusMode,False,Alpha)
		If Status.Length=0 Then Status= API.GetString("alert_" & CLR.Name.ToLowerCase) '"CONDITION: " & CLR.Name.ToUpperCase 
		
		Points(0)=Radius*0.25		'not it
		Points(1)=Radius*OneThird	'not it
		Points(2)=Radius*0.4		'not it
		Points(3)=Radius*0.5		'not it
		Points(4)=Radius*0.7		'not it
		Points(5)=Radius*0.18		'for square
		Points(6)=Radius*0.03		'for bar
		Points(7)=Radius*0.01		'for bar whitespace
		Points(8)=Alpha/16			'for alpha
		Points(9)=Radius*0.9
		Points(10)=Points(6) + Points(7)
		
		If LCAR.AntiAliasing Then
			Angle=Radius*1.224
			X2=Trig.findXYAngle(Points(3),Points(0), Angle,49,True)
			Y2=Trig.findXYAngle(Points(3), Points(0), Angle,49,False)
			
			P.Initialize(X + X2 +1, Y - Y2-1)
			P.LineTo(X - X2-1, Y - Y2-1)
			P.LineTo(X + X2+1, Y + Y2+1)
			P.LineTo(X - X2-1, Y + Y2+1)
			BG.ClipPath(P)
			
			BG.DrawLine(X + Points(3)+1,Y - Points(0)-1, X + Radius, Y - Points(4)    , Color, 2)'right up
			BG.DrawLine(X - Points(3)-1,Y - Points(0)-1, X - Radius, Y - Points(4)    , Color, 2)'left up
			BG.DrawLine(X + Points(3)+1,Y + Points(0)+1, X + Radius, Y + Points(4)    , Color, 2)'right down
			BG.DrawLine(X - Points(3)-1,Y + Points(0)+1, X - Radius, Y + Points(4)    , Color, 2)'left down
			
			BG.RemoveClip
		End If

		'top half
		P.Initialize(X + Points(3),Y - Points(0))'bottom right corner
		P.lineto(X + Radius, Y - Points(4) )'top right corner
		P.LineTo(X + Radius, Y - Radius)'top right corner of entire square
		
		'right square
		P.LineTo(X + Radius, Y-Points(5))'top right
		P.LineTo(X + Points(4), Y-Points(5))'top left
		P.LineTo(X + Points(4), Y+Points(5))'bottom left
		P.LineTo(X + Radius, Y+Points(5))'bottom right
		
		'bottom half
		P.lineto(X + Radius, Y + Points(4) )'bottom right corner
		P.lineto(X + Points(3),Y + Points(0))'top right corner
		P.lineto(X - Points(3),Y + Points(0))'top left corner
		P.lineto(X - Radius, Y + Points(4) )'bottom left corner
		P.lineto(X - Radius, Y + Radius )'bottom left corner of entire square			bottom half
		P.lineto(X - Points(2), Y + Radius)'middle bottom left corner 					middle bottom left
		P.lineto(X - Points(2), Y + Points(1))'middle top left corner					middle top left
		P.lineto(X + Points(2), Y + Points(1))'middle top right corner					middle top right
		P.lineto(X + Points(2), Y + Radius)'middle bottom right corner 					middle bottom right
		P.lineto(X + Radius, Y + Radius )'bottom right corner of entire square
		
		'top half
		P.LineTo(X + Radius, Y - Radius)'return to top right corner of entire square	top half
		P.lineto(X + Points(2), Y - Radius)'middle top right corner						middle top right
		P.lineto(X + Points(2), Y - Points(1))'middle bottom right corner				middle bottom right
		P.lineto(X - Points(2), Y - Points(1))'middle bottom left corner				middle bottom left
		P.lineto(X - Points(2), Y - Radius)'middle top left corner						middle top left
		P.LineTo(X - Radius, Y - Radius)'top left corner
		
		'left square
		P.LineTo(X - Radius, Y-Points(5))'top left
		P.LineTo(X - Points(4), Y-Points(5))'top right
		P.LineTo(X - Points(4), Y+Points(5))'bottom right
		P.LineTo(X - Radius, Y+Points(5))'bottom left
		
		'top half
		P.LineTo(X - Radius, Y - Radius)'return to top left corner
		P.lineto(X - Radius, Y - Points(4))'top left corner of top half
		P.lineto(X - Points(3),Y - Points(0))'bottom left corner of top half
		
		BG.clippath(P)
		LCAR.ActivateAA(BG, True)
		If UseCircle Then 
			BG.DrawCircle(X,Y,Radius, Color,True,1)
		Else 
			BG.drawrect(LCAR.SetRect(X-Radius,Y-Radius,Radius*2,Radius*2), Color, True,0)
		End If 
		BG.RemoveClip
		
		If Text.Length = 0 Then Text = API.GetString("alert_alert")
		If TextSize=0 Then  TextSize= GetTextHeight(BG,    Radius*0.2, Text, LCARSeffects2.StarshipFont,True)
		BG.DrawText(Text, X,Y, LCARSeffects2.StarshipFont, TextSize, Color, "CENTER")
		If HasColon Then BG.DrawText(":", X,Y, LCARSeffects2.StarshipFont, TextSize, Color, "CENTER")
		textsize2=TextSize*OneThird
		BG.DrawText(Status, X, Y+ BG.MeasureStringHeight(Status, LCARSeffects2.StarshipFont , textsize2)*2, LCARSeffects2.StarshipFont,  textsize2, Color, "CENTER")
		
		'stage 0=brightest is at topmost position
		Alpha2=Alpha
		Y2=Y-Points(9) + (Points(10)*(Stage-1))
		Y3=Y+Points(9) - (Points(10)*(Stage+1))+Points(7)
		X2=X - Points(2) + Points(7)
		Width=X + Points(2) - Points(7)  - X2
		
		LCAR.drawrect(BG,X2,Y-Radius+Points(6)*2,Width,Points(6), Colors.black, 0)
		LCAR.drawrect(BG,X2,Y+Radius-Points(6)*3,Width,Points(6), Colors.black, 0)
		
		For temp = 1 To 5
			If Stage >=0  Then
				Y3=Y3+ Points(10)
				If Alpha2>0 And Y2<Y - Points(1)-Points(6) Then
					'Color= lcar.GetColor(StatusMode,True,alpha2)
					CLR2.Initialize(LCAR.GetColor(StatusMode,True,Alpha2), Points(6)*0.5)
					'bg.DrawRect(lcar.SetRect(x2,y2, width, points(6)), Color, True,0)
					'bg.DrawRect(lcar.SetRect(x2,y3, width, points(6)), Color, True,0)
					BG.DrawDrawable(CLR2, LCAR.SetRect(X2,Y2, Width, Points(6)))
					BG.DrawDrawable(CLR2, LCAR.SetRect(X2,Y3, Width, Points(6)))
					Alpha2=Alpha2-Points(8)
				End If
				Y2=Y2- Points(10)
			End If
			Stage=Stage-1
		Next
		LCAR.ActivateAA(BG, False)
	End If
	
	If Not(UseCircle) Then 'assumes fullscreen
		If LCAR.Landscape Then 
			LCARSeffects4.drawrect(BG, 0,			Y-Points(5), x-Radius+1, Points(5)*2, Color, 0)'left square
			LCARSeffects4.drawrect(BG, X+Radius-1,	Y-Points(5), x-Radius+1, Points(5)*2, Color, 0)'right square
		End If 
		LCARSeffects4.drawrect(BG, X-Radius,	Y-Radius, Radius*2, Points(1), Colors.Black, 0)'top bar
		LCARSeffects4.drawrect(BG, X-Radius,	Y+Radius-Points(1), Radius*2, Points(1), Colors.Black, 0)'bottom bar
	End If 
		
	Return TextSize
End Sub






Sub MakeClipPath(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim P As Path 
	P.Initialize(X,Y)
	P.LineTo(X+Width,Y)
	P.LineTo(X+Width,Y+Height)
	P.LineTo(X,Y+Height)
	BG.ClipPath(P)
End Sub

Sub DrawOval(BG As Canvas, DEST As Rect, ColorID As Int, State As Boolean, Stroke As Int, DoBlur As Boolean)
	Dim temp As Int, temp2 As Int, Alpha As Int, X As Int = DEST.Left, Y As Int = DEST.Top, Width As Int = DEST.Right - DEST.Left, Height As Int = DEST.Bottom- DEST.Top 
	Dim OriginalStroke As Int = Stroke, DidAdd As Boolean = True 
	BG.DrawOval(LCAR.SetRect(X,Y,Width,Height), LCAR.GetColor(ColorID,State, 255), Stroke=0, Stroke)'Outer Oval
	If DoBlur Then 
		For temp = 1 To 16 
			temp2 = Max(1, (temp * OriginalStroke) - 1)
			Alpha = Max(0, 255 - temp*16)
			BG.DrawOval(LCAR.SetRect(X+temp2,Y+temp2,Width-temp2*2,Height-temp2*2), LCAR.GetColor(ColorID,State, Alpha), False, Stroke)'Outer Oval
			If DidAdd Then 
				DidAdd=False
				Stroke=Stroke+1
			End If
		Next
	End If
End Sub

Sub DrawShieldStatus(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int,Stage2 As Int, ColorID As Int, Alpha As Int, ShipID As Int, Angle As Int)
	Dim Center As Point ,temp As Int ,HorOval As Rect, VerOval As Rect, HalfHeight As Int, HalfWidth As Int, Stroke = API.iif(ShipID=0, 2,4),X2 As Int, Y2 As Int, DoBlur As Boolean, CID As Int = ColorID 'MaxShieldStages
	ColorID=LCAR.GetColor(ColorID,False, 255)
	If Height>Width And ShipID > 0 Then'Voyager, Ent-E
		temp = LCARSeffects4.ResizeElement(Width,Height)
		Y= Y + (Height*0.5) - (temp*0.5)
		Height=temp		
	End If
	If ShipID=2 Then DoBlur=True
	HalfHeight=Height*0.5
	HalfWidth=Width*0.5
	Center=Trig.SetPoint(X+HalfWidth,Y+HalfHeight)
	'LCAR.DrawRect(BG,X,Y,Width,Height, Colors.black,0)
	temp=Height/MaxShieldStages*Stage'height of oval at this stage
	VerOval = LCAR.SetRect(X,Center.Y-(temp*0.5)  ,Width,  temp)
	temp=Width/MaxShieldStages*(MaxShieldStages-1-Stage)'width of oval at inverted stage
	HorOval = LCAR.SetRect(Center.X-(temp*0.5), Y, temp, Height)
	
	'Clear internal area
	Select Case ShipID
		Case 0: 	BG.DrawOval(LCAR.SetRect(X,Y,Width,Height), Colors.Black , True, 0)'Ent-D mini
		Case 1,2: 	LCAR.DrawRect(BG,X,Y,Width+1,Height+1, Colors.black,0)'Voyager, Ent-E
	End Select
	
	LCAR.ActivateAA(BG,True)
	DrawOval(BG, LCARSeffects4.SetRect(X,Y,Width,Height), CID, False, Stroke, DoBlur)
	'BG.DrawOval(LCAR.SetRect(X,Y,Width,Height), ColorID, False, Stroke)'Outer Oval
	
	If LCAR.RedAlert And ShipID < 2 Then 
		ColorID = Colors.White 
		CID = LCAR.LCAR_RedAlert 
	End If
	
	'Underneath ovals
	If DoBlur Then 
		MakeClipPath(BG,X,Y+ API.IIF(Stage2=0, HalfHeight,0), Width, HalfHeight)
		DrawOval(BG,VerOval, CID, LCAR.RedAlert, Stroke, DoBlur)'|
		BG.RemoveClip 
		
		MakeClipPath(BG,X+ API.IIF(Stage2=0, HalfWidth,0),Y, HalfWidth, Height)
		DrawOval(BG,HorOval, CID, LCAR.RedAlert, Stroke, DoBlur)
		BG.RemoveClip
	Else 
		DrawOval(BG,HorOval, CID, False, Stroke, False)'---
		DrawOval(BG,VerOval, CID, False, Stroke, False)'|
	End If
	
	Select Case ShipID
		Case 0: DrawEnterpriseD(BG, Center.X, Center.Y, HalfHeight, 0, 0,0)'Ent-D mini
		Case 1: DrawVoyager(BG, X,Y,Width,Height)'Voyager
		Case 2: DrawEnterpriseE(BG, X,Y,Width,Height)'Ent-E
	End Select
	
	'over top ovals
	MakeClipPath(BG,X,Y+ API.IIF(Stage2=0, 0,HalfHeight), Width, HalfHeight)
	DrawOval(BG,VerOval, CID, DoBlur And LCAR.RedAlert, Stroke, DoBlur)'|
	BG.RemoveClip 
	
	MakeClipPath(BG,X+ API.IIF(Stage2=0, 0,HalfWidth),Y, HalfWidth, Height)
	DrawOval(BG,HorOval, CID, DoBlur And LCAR.RedAlert, Stroke, DoBlur)
	BG.RemoveClip
	
	If Angle>-1 And Not(DoBlur) Then'crosshairs
		MakeClipPath(BG,X,Y,Width,Height)
		X2 = Trig.findXYAngle(Center.X,Center.Y, Width*0.5,Angle, True)
		Y2 = Trig.findXYAngle(Center.X,Center.Y, Height*0.5, Angle, False)'(Height/MaxShieldStages*Stage)
		BG.DrawLine(X, Y2,X+Width,Y2, ColorID, Stroke)
		BG.DrawLine(X2, Y,X2,Y+Height, ColorID, Stroke)
		BG.DrawCircle(X2,Y2,Stroke*2, ColorID,True,0)
		BG.RemoveClip 
	End If
	
	LCAR.ActivateAA(BG,False)
	If Alpha<255 Then LCAR.DrawRect(BG,X,Y,Width,Height, Colors.ARGB(255-Alpha,0,0,0),0)
End Sub

Sub DrawSensorSweep(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int, Stage2 As Int)
	Dim Origin As Int , Origin2 As Int , Origin3 As Int, LineColor As Int ,Angle As Int, temp As Int ,P As Path , Orange As Int
	Dim DoGrey As Boolean = Stage<>1, DoBox As Boolean = (Stage Mod 2)=0
	'Log(temp & " " & DoGrey & " " &  DoBox)
	LineColor=LCAR.GetColor(LCAR.LCAR_Red,False,255)
	Orange=LCAR.GetColor(LCAR.LCAR_orange,False,255)
	
	Origin = Height * 0.55
	Origin2 = Height*0.5
	Origin3 = Height * 0.4
	
	Angle=Origin2-Origin3
	DrawGrid(BG,X,Y,Width,Height, Origin3,Origin3,Angle,Angle,False, -1,-1,-1)
	
	'Angle=Trig.GetCorrectAngle(0, 0, Height*0.25, -Width)
	Angle=Height*0.25
	MakeClipPath(BG,X,Y,Width,Height)
	LCAR.ActivateAA(BG,True)
	'PT1 = DrawLine(BG,  X+ Origin2, Y+Origin2, 90-Angle, 0, Width*1.5, LineColor,2)'right and bottom = x2 and y2
	'PT2 = DrawLine(BG,  X+ Origin2, Y+Origin2, 90+Angle, 0, Width*1.5, LineColor,2)
	BG.DrawLine( X+ Origin2, Y+Origin2, X+Width, Y+Angle, LineColor,2)
	BG.DrawLine( X+ Origin2, Y+Origin2, X+Width, Y+Height-Angle, LineColor,2)
	
	BG.DrawCircle(X+ Origin2, Y+Origin2, Origin, LineColor , False, 2)
	BG.DrawCircle(X+ Origin2, Y+Origin2, Origin3, LineColor , False, 2)
	If DoGrey Then 
		DrawCircleSegment(BG, X+ Origin2, Y+Origin2, 0,Origin3, 270,90,  Colors.Gray, 0,0,0)'top left grey quadrant
		temp=Trig.GetCorrectAngle(0, 0, Angle, -Width)
	
		P.Initialize(X+ Origin2, Y+Origin2)'center of ship
		P.LineTo(X+Width,  Y+Height-Angle)'bottom right corner of line
		P.LineTo(X+Width,  Y+Height)'bottom right corner
		P.LineTo(X+ Origin2, Y+Height)'center bottom
		BG.ClipPath(P)
		DrawCircleSegment(BG, X+ Origin2, Y+Origin2, Origin3,Origin, 90+temp,360,  Colors.Gray, 0,0,0)'bottom right grey quadrant
	End If
	BG.RemoveClip
	
	'MakeClipPath(BG,X,Y,Width,Height)
	temp=Width-Origin2-Origin
	LCARSeffects2.DrawCrossLines(BG,X,Y, Origin2*2,Origin2*2, Height/-10, -5, LineColor, 2)
	LCARSeffects2.DrawCrossLines(BG,X+Origin2+Origin,Y, temp,Origin2*2, temp/25, 5, LineColor, -2)

	P.Initialize(X+ Origin2, Y+Origin2)'center of ship
	P.LineTo(X+Width,  Y+Angle)'top right corner
	P.LineTo(X+Width,  Y+Height-Angle)'bottom right corner
	BG.ClipPath(P)
	If Not(DoGrey) Then DrawCircleSegment(BG, X+ Origin2, Y+Origin2, Origin3,Origin, 0 ,360,  Orange , 0,0,0)'bottom right grey quadrant
	LCAR.DrawGradient(BG, Colors.ARGB(0,0,0,0), Orange, 6, X+Origin2+Origin + temp* (Stage*0.02), Y, 30, Height, 0,0)'sensor sweep
	DrawCircleSegment(BG, X+ Origin2, Y+Origin2,  Origin-2,Origin+2, 90-temp,temp*2,  LineColor, 0,0,0)'thick bit
	
	
	'draw debris
	If Stage2>0 Then 
		BG.ClipPath(P)
		temp=Origin2+Origin + temp* (Stage2*0.02)
		Angle = Angle/ (Width-Origin2) * temp
		Orange=Height*0.5
		DrawRandomDots(BG, X+temp,Y+Orange-Angle, 30, Angle*2, Colors.White ,  30)
		BG.RemoveClip 
		If DoBox Then BG.DrawRect(LCAR.SetRect(X+temp - Origin3+15, Y+Height/2-Origin3, Origin3*2+1,Origin3*2+1), LCAR.GetColor(LCAR.LCAR_Yellow,True,255),False,1)
	End If
	BG.RemoveClip 
	
	DrawEnterpriseD(BG, X+ Origin2, Y+Origin2,  Origin2,  0,0, 0)
	LCAR.ActivateAA(BG,False)
End Sub
Sub DrawRandomDots(BG As Canvas,X As Int, Y As Int, Width As Int,Height As Int, Color As Int, Dots As Int)
	Dim temp As Int 
	If Width>0 And Height>0 Then
		For temp = 1 To Dots
			BG.DrawPoint(Rnd(X,X+Width), Rnd(Y, Y+Height), Color)
		Next
	End If
End Sub

Sub DrawShip(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, Filename As String, ImageHeight As Int) As Rect 
	Dim Size As Point, CenterX As Int = X + Width*0.5, CenterY As Int = Y + Height *0.5, SrcY As Int' = API.IIF(LCAR.RedAlert, 145,0)'716x145,
	LCARSeffects2.LoadUniversalBMP(File.DirAssets , Filename, LCAR.LCAR_ShieldStatus )
	If LCAR.RedAlert Then
		SrcY = ImageHeight
		If LCAR.RedAlertMode = LCAR.Classic_Blue Then SrcY=SrcY*2' LCAR.RedAlertMode = LCAR.LCAR_RedAlert 
	End If
	Size = API.Thumbsize(LCARSeffects2.CenterPlatform.Width,ImageHeight*2, Width,Height,True,False)
	Size.X = Size.X *0.75
	Size.Y = Size.Y * 0.75
	BG.DrawBitmap(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,SrcY , LCARSeffects2.CenterPlatform.Width, ImageHeight), LCARSeffects4.SetRect(CenterX-Size.X*0.5, CenterY-Size.Y*0.5+1, Size.X,Size.Y*0.5))
	BG.DrawBitmapflipped(LCARSeffects2.CenterPlatform, LCARSeffects4.SetRect(0,SrcY , LCARSeffects2.CenterPlatform.Width, ImageHeight), LCARSeffects4.SetRect(CenterX-Size.X*0.5, CenterY, Size.X,Size.Y*0.5), True,False)
	Return LCARSeffects4.SetRect(CenterX-Size.X*0.5, CenterY-Size.Y*0.5+1, Size.X,Size.Y)
End Sub

Sub DrawEnterpriseE(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Long, CP As ENTpoint, PointWidth As Int = Width * 0.01389, DEST As Rect 
	DEST = DrawShip(BG,X,Y,Width,Height, "sovereign.png", 160)
	If LCAR.RedAlert Or API.debugMode Then 
		X = DEST.Left 
		Y = DEST.Top
		Width = DEST.Right - DEST.Left 
		Height = DEST.Bottom - DEST.Top 
		
		'color = 207,29,39
		'src = 0,478,900,159
		If Not(ENTEpoints.IsInitialized) Then 
			ENTEpoints.Initialize	
			MakeENTEpoint(0.78222, 1, False)'bridge	
			MakeENTEpoint(0.94889, 1, False)'front
			MakeENTEpoint(0.33444, 1, False)'back of engineering
			MakeENTEpoint(0.36889, 1, False)'middle of engineering
			MakeENTEpoint(0.40334, 1, False)'front of engineering
			
			MakeENTEpoint(0.71444, 0.20000, False)'top back of saucer
			MakeENTEpoint(0.78222, 0.25625, False)'top of saucer
			MakeENTEpoint(0.60333, 0.55625, False)'back of saucer
			MakeENTEpoint(0.88667, 0.43125, False)'front of saucer
			MakeENTEpoint(0.17444, 0.26250, False)'back of nacelle
			MakeENTEpoint(0.21200, 0.26250, False)'front of nacelle
			
			MakeENTEpoint(0.71444, 0.20000, True)'top back of saucer
			MakeENTEpoint(0.78222, 0.25625, True)'top of saucer
			MakeENTEpoint(0.60333, 0.55625, True)'back of saucer
			MakeENTEpoint(0.88667, 0.43125, True)'front of saucer
			MakeENTEpoint(0.17444, 0.26250, True)'back of nacelle
			MakeENTEpoint(0.21200, 0.26250, True)'front of nacelle
			
			ENTEx.Initialize
			ENTEx.Current = Rnd(0,100)
			ENTEx.Desired = 100
			ENTEy.Initialize
			ENTEy.Current = Rnd(0,100)
			ENTEy.Desired = 100
		Else 	
			DrawAlphaSlice(BG, X,Y,Width,Height, LCARSeffects2.CenterPlatform, 0, 480, 900, 320, True, ENTEx.Current * 0.01, 0.1, 4)
			DrawAlphaSlice(BG, X,Y,Width,Height, LCARSeffects2.CenterPlatform, 0, 480, 900, 320, False, ENTEy.Current * 0.01, 0.1, 4)
			ENTEx.Current = LCAR.Increment(ENTEx.Current, 5, ENTEx.Desired)
			ENTEy.Current = LCAR.Increment(ENTEy.Current, 2, ENTEy.Desired)
			If ENTEx.Current = ENTEx.Desired Then ENTEx.Desired = 100 - ENTEx.Desired
			If ENTEy.Current = ENTEy.Desired Then ENTEy.Desired = 100 - ENTEy.Desired
			
			For temp = 0 To ENTEpoints.Size - 1
				CP = ENTEpoints.Get(temp)
				If CP.Alpha.Current > 0 And CP.Alpha.Current < 256 Then  
					BG.DrawCircle(x + Width * CP.X, Y + Height * CP.Y, PointWidth, Colors.ARGB( CP.Alpha.Current, 207,29,39), True,0)
				End If 
				CP.Alpha.Current = LCAR.Increment(CP.Alpha.Current, 16, CP.Alpha.Desired)
				If CP.Alpha.Current = CP.Alpha.Desired Then 
					CP.Alpha.Desired = 255 - CP.Alpha.Desired
					If CP.Alpha.Desired = 255 Then CP.Alpha.Current = Rnd(-8,0) * 16
				End If
			Next
		End If
	End If 
End Sub

Sub DrawAlphaSlice(BG As Canvas, destX As Int, destY As Int, destWidth As Int, destHeight As Int, src As Bitmap, srcX As Int, srcY As Int, srcWidth As Int, srcHeight As Int, IsX As Boolean, Percent As Float, SliceSize As Float, Slices As Int)
	Dim StartDest As Int, EndDest As Int, StartSrc As Int, EndSrc As Int, temp As Int, SliceSizeDest As Int, SliceSizeSrc As Int, Alpha As Int = 255, AlphaInc As Int = 256 / Slices 
	'ScaleX As Float = destWidth / srcWidth, ScaleY As Float = destHeight/srcHeight,
	If IsX Then 
		StartDest = destX + (destWidth * Percent)
		StartSrc = srcX + (srcWidth * Percent)
		SliceSizeDest = destWidth * SliceSize / Slices
		SliceSizeSrc = srcWidth * SliceSize / Slices
		
		EndDest = StartDest 
		EndSrc = StartSrc
		
		For temp = 0 To Slices - 1 
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, StartSrc, srcY, SliceSizeSrc, srcHeight, StartDest, destY, SliceSizeDest, destHeight, Alpha, False,False)
			
			EndDest = EndDest - SliceSizeDest
			EndSrc = EndSrc - SliceSizeSrc
			If EndSrc >= srcX And EndDest >= destX Then 
				LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, EndSrc, srcY, SliceSizeSrc, srcHeight, EndDest, destY, SliceSizeDest, destHeight, Alpha, False,False)
			End If
				
			Alpha = Alpha - AlphaInc
		Next
	Else 
		StartDest = destY + (destHeight * Percent)
		StartSrc = srcY + (srcHeight * Percent)
		SliceSizeDest = destHeight * SliceSize / Slices
		SliceSizeSrc = srcHeight * SliceSize / Slices
		
		EndDest = StartDest 
		EndSrc = StartSrc
		
		For temp = 0 To Slices - 1 
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,StartSrc, srcWidth, SliceSizeSrc, destX, StartDest, destWidth, SliceSizeDest, Alpha, False,False)
					
			EndDest = EndDest - SliceSizeDest
			EndSrc = EndSrc - SliceSizeSrc
			If EndSrc >= srcY And EndDest >= destY Then 
				LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, srcX,EndSrc, srcWidth, SliceSizeSrc, destX, EndDest, destWidth, SliceSizeDest, Alpha, False,False)				
			End If
				
			Alpha = Alpha - AlphaInc
		Next
	End If
End Sub


Sub MakeENTEpoint(X As Float, Y As Float, FlipY As Boolean)
	Dim temp As ENTpoint
	temp.Initialize
	temp.X=X
	temp.Y = Y * 0.5
	If FlipY Then temp.Y = 1 - temp.Y 
	temp.Alpha.Initialize
	If Rnd(0,100) < 50 Then 
		temp.Alpha.Desired = 0
		temp.Alpha.Current = Rnd(8,16) * 16
	Else 
		temp.Alpha.Desired = 255
		temp.Alpha.Current = Rnd(-8,8) * 16
	End If
	ENTEpoints.Add(temp)
End Sub 

Sub DrawVoyager(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int)
	DrawShip(BG,X,Y,Width,Height, "voyager.png", 145)
End Sub

'Mode: 0=mini, 1=side view, small asset, 2=top view, large asset, use angle as color, width=along x axis of picture, 3=side view, large asset, use angle as color
Sub DrawEnterpriseD(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, AngleColor As Int, Mode As Int) As Rect 
	Dim W2 As Int = 137, H2 As Int = 50, src As Rect, Height2 As Int,Width2 As Int  ,CenterX As Int, CenterY As Int ,Dest As Rect 
	'small asset = height=137 width=(50*2) 
	'large asset = height=563 width=(128*2)   LoadUniversalBMP
	Width2=Width
	Select Case Mode
		Case 0'top view, 0=small asset, 1=big asset, width=along Y axis of picture
			If LCAR.SmallScreen Then 
				If Not(Enterprise.IsInitialized ) Then Enterprise.Initialize(File.DirAssets, "ent.png")
			Else 
				If Not(Enterprise.IsInitialized ) Then Enterprise.Initialize(File.DirAssets, "ent2.png")
				W2 = 540
				H2 = 200
			End If
			Width2 = H2*2
			
			If LCAR.redalert Then Height2= API.IIF(LCAR.RedAlertMode = LCAR.Classic_Blue, Width2, H2)
			src=LCAR.SetRect(0,Height2, Enterprise.Width, H2)
			Height = W2 * (Width/Width2)
			
			W2=Width*0.5
			H2=Height*0.5
			If AngleColor=0 Then
				BG.DrawBitmap(Enterprise, src, LCAR.SetRect(X-H2,Y-W2+1,Height,W2))
				BG.DrawBitmapflipped(Enterprise, src, LCAR.SetRect(X-H2,Y,Height,W2) ,True,False)
			End If
			Return Dest
		Case 1'side view, small asset
			'not available yet
			Return Dest
		Case 2'top view, large asset, use angle as color, width=along x axis of picture
			Height2 = 0.37102473498233215547703180212014 * Width'height of image/width of image * desired width
			If Height2>Height/2 Then 
				Height2=Height/2
				Width2 = Height2 * 2.6952380952380952380952380952381 'width/height
			End If
			src = LCAR.SetRect(0,128,566,210)
		Case 3'side view, large asset, use angle as color
			Height2 = 0.22380106571936056838365896980462*Width' 126/563
			If Height2>Height Then 
				Height2=Height
				Width = Height * 4.468253968253968253968253968254' 563/126
			End If
			src = LCAR.SetRect(1,1,563,126)
	End Select
	LCARSeffects2.LoadUniversalBMP(File.DirAssets , "starships2.png", LCAR.LCAR_NCC1701D )
	CenterX= X+ Width/2
	CenterY = Y+ Height/2
	W2=Width2*0.5
	H2=Height2*0.5
	'Log("DFHFDH X: " & X & " Y: " & Y & " WIDTH: " & Width & " HEIGHT: " & Height)
	If Mode=3 Then
		LCAR.DrawRect(BG,CenterX-W2,CenterY-H2 +2, Width2, Height2-3, AngleColor,0)
		Dest=LCAR.SetRect(CenterX-W2,CenterY-H2,Width2, Height2)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, src, Dest)
	Else
		Dest  = LCAR.SetRect(CenterX-W2,CenterY-Height2 +2, Width2, Height2*2-2)
		BG.DrawRect(Dest, AngleColor, True, 0)
		'LCAR.DrawRect(BG,CenterX-W2,CenterY-Height2 +2, Width2, Height2*2-2, AngleColor,0)
		BG.DrawBitmapflipped(LCARSeffects2.CenterPlatform, src, LCAR.SetRect(CenterX-W2,CenterY - Height2 +2, Width2, Height2), True,False)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, src, LCAR.SetRect(CenterX-W2,CenterY,Width2, Height2))
	End If
	Return Dest
End Sub