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
	'Type Point(X As Int, Y As Int) 'UNCOMMENT IF USED ELSEWHERE
	Dim Pi As Double = 3.14159265358979,RadPi As Double = 180 / Pi
End Sub
Sub SetPoint(X As Int, Y As Int) As Point 
	Dim temp As Point
	temp.Initialize
	temp.X=X
	temp.Y=Y
	Return temp
End Sub
'Value = 0 to 1
Sub Curve(Value As Float) As Float 
	Return Sin(Value*0.5 * Pi)
End Sub
Sub SetRect(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	Dim temp As Rect 
	temp.Initialize(X,Y,Width,Height)
	Return temp
End Sub
Sub MaxSizeOfOval(Width As Int, Height As Int, Angle As Int) As Int'method fails for corners
	Dim Middle As Point, EndOfCircle As Point , StartofLine As Point, EndofLine As Point, PointB As Point  
	Middle=SetPoint(Width/2, Height/2)
	Angle = Angle Mod 180'since it's symetrical
	EndOfCircle=SetPoint( findXYAngle(Middle.X,Middle.Y, Width, Angle,True), findXYAngle(Middle.X,Middle.Y, Width, Angle,False) )
	If Angle>=45 And Angle <=135 Then'vertical
		StartofLine=SetPoint(Width,0)
		EndofLine=SetPoint(Width,Height)
	Else If Angle<45 Then'horizontal
		StartofLine=SetPoint(0,0)
		EndofLine=SetPoint(Width,0)
	Else
		StartofLine=SetPoint(0,Height)
		EndofLine=SetPoint(Width,Height)
	End If
	PointB= LineLineIntercept(Middle.X,Middle.Y,  EndOfCircle.X, EndOfCircle.Y, StartofLine.X, StartofLine.Y, EndofLine.X,EndofLine.Y) 
	Return FindDistance(Middle.X,Middle.Y, PointB.X,PointB.Y)*2
End Sub

Sub MaxSizeOfOval2(Width As Int, Height As Int, Angle As Int) As Double 
	Dim Middle As Point, EndOfCircle As Point   
	Middle=SetPoint(Width/2, Height/2)
	EndOfCircle=SetPoint( findXYAngle(Middle.X,Middle.Y, Width, Angle,True), findXYAngle(Middle.X,Middle.Y, Height, Angle,False) )
	Return FindDistance(Middle.X,Middle.Y, EndOfCircle.X,EndOfCircle.Y)
End Sub

Sub LineAngleIntercept(X As Int, Y As Int, Angle As Int, X3 As Int, Y3 As Int, X4 As Int, Y4 As Int) As Point
	Dim X2 As Int, Y2 As Int, InfDistance As Int = 99999
	X2=findXY(X,Y,InfDistance,Angle,True)
	Y2=findXY(X,Y,InfDistance,Angle,False)
	Return LineLineIntercept(X,Y,X2,Y2,X3,Y3,X4,Y4)
End Sub

Sub LineAngledistance(X As Int, Y As Int, Angle As Int, X3 As Int, Y3 As Int, X4 As Int, Y4 As Int) As Int
	Dim temp As Point 
	temp=LineAngleIntercept(X,Y,Angle,X3,Y3,X4,Y4)
	If temp.IsInitialized Then Return FindDistance(X,Y, temp.X,temp.Y)
End Sub

Sub LineLineIntercept(X1 As Int, Y1 As Int, X2 As Int, Y2 As Int, X3 As Int, Y3 As Int, X4 As Int, Y4 As Int) As Point 
    Dim a1 As Int, a2 As Int, b1 As Int, b2 As Int, c1 As Int, c2 As Int, denom As Int, ret As Point 
    'Translated from Pascal, lost source
    a1 = Y2 - Y1
    b1 = X1 - X2
    c1 = X2 * Y1 - X1 * Y2 '  { a1*x + b1*y + c1 = 0 is line 1 }

    a2 = Y4 - Y3
    b2 = X3 - X4
    c2 = X4 * Y3 - X3 * Y4 '  { a2*x + b2*y + c2 = 0 is line 2 }

    denom = a1 * b2 - a2 * b1

    If denom <> 0 Then
        ret.initialize
        ret.X = (b1 * c2 - b2 * c1) / denom
        ret.Y = (a2 * c1 - a1 * c2) / denom
		Return ret 
    End If
End Sub

Sub CorrectAngle(Angle As Double) As Double
    Do While Angle < 0
        Angle = Angle + 360
    Loop
    Return Angle Mod 360
End Sub

Sub AngleBySection(X1 As Int, Y1 As Int, X2 As Int, Y2 As Int, Angle As Int) As Int
    Angle=CorrectAngle(Angle)

    If X1 < X2 Then 'the point is at the left of Center
        If Y1 = Y2 Then
            Return 90 'Corrected
        Else If Y1 < Y2 Then
            If 270 + Angle = 360 Then
                Return 0 'Corrected
            Else
                Return 180- (Angle -270)  'Corrected
            End If
        Else If Y1 > Y2 Then
            Return 90 - Angle 'Corrected
        End If
    Else
        If X1 > X2 Then 'the point is at the right of Center
            If Y1 > Y2 Then 'point is below center
                'Return 90 + Angle 'Corrected
				Return 360- (Angle-270)
            Else If Y1 < Y2 Then
                Return 270 - Angle 'Corrected
            End If
        Else
            If X1 = X2 Then
                If Y1 < Y2 Then
                    Return 180 'Corrected
                Else If Y1 > Y2 Then
                    Return 0 'Corrected
                End If
            End If
        End If
    End If
	
	Return 90'Corrected
End Sub

Sub FindSection(Angle As Int) As Int
	If Angle<=45 Or Angle >= 315 Then
		Return 0
	Else If Angle <= 135 Then
		Return 1
	Else If Angle <= 225 Then 
		Return 2
	Else
		Return 3
	End If
End Sub



Sub AngleSection(Angle As Int) As Int
	Return Floor(Angle/90)
End Sub

'You probably want GetCorrectAngle
Sub FindAngle(X1 As Int, Y1 As Int, X2 As Int, Y2 As Int) As Double
    Return ATan((Y2 - Y1) / (X1 - X2))
End Sub

Sub findXY(X As Int, Y As Int, Distance As Int, Angle As Int, IsX As Boolean) As Int
	Angle = CorrectAngle(180-Angle)
    If IsX Then 
		Return X + Sin(Angle) * Distance 
	Else 
		Return Y + Cos(Angle) * Distance
	End If
End Sub

Sub DegToRad(Deg As Int) As Double
    Return (Deg / 180) * Pi
End Sub
Sub RadToDeg(Rad As Double) As Int
    Return Rad * RadPi
End Sub
Sub GradtoRad(Grad As Double) As Double
    Return Grad * (200 / Pi)
End Sub

Sub FindAngleIndependPoint(X As Int, Y As Int, RadiusX As Int, RadiusY As Int, Angle As Int) As Point 
	Dim temp As Point 
	temp.Initialize
	temp.X=findXYAngle(X, Y, RadiusX, Angle, True)
	temp.Y=findXYAngle(X, Y, RadiusY, Angle, False)
	Return temp
End Sub
Sub FindAnglePoint(X As Int, Y As Int, Distance As Int, Angle As Int) As Point
	Dim temp As Point 
	temp.Initialize 
	temp.X=findXYAngle(X,Y,Distance,Angle,True)
	temp.Y=findXYAngle(X,Y,Distance,Angle,False)
	Return temp
End Sub

Sub findOvalXY(X As Int, Y As Int, Width As Int, Height As Int, Angle As Int) As Point 
	Dim ret As Point, HalfWidth As Int = Width * 0.5, HalfHeight As Int = Height * 0.5, CenterX As Int = X + HalfWidth, CenterY As Int = Y + HalfHeight
	ret.Initialize
	ret.X = findXYAngle(CenterX,CenterY, HalfWidth,  Angle, True)
	ret.Y = findXYAngle(CenterX,CenterY, HalfHeight, Angle, False)
	Return ret 
End Sub
Sub findOvalXY2(CenterX As Int, CenterY As Int, RadiusX As Int, RadiusY As Int, Angle As Double) As Point 
	Dim ret As Point
	ret.Initialize
	ret.X = findXYAngle(CenterX,CenterY, RadiusX,  Angle, True)
	ret.Y = findXYAngle(CenterX,CenterY, RadiusY, Angle, False)
	Return ret 
End Sub

Sub findXYAngle(X As Int, Y As Int, Distance As Int, Angle As Double, IsX As Boolean ) As Int
	Angle = CorrectAngle(180-Angle)
	If IsX Then
		Return X + Distance * SinD(Angle)
	Else
		Return Y + Distance * CosD(Angle)
	End If
End Sub

Sub GetCorrectAngle(X1 As Int, Y1 As Int, X2 As Int, Y2 As Int) As Int
	If Y1 = Y2 And X2 < X1 Then Return 270
    Return AngleBySection(X1, Y1, X2, Y2,  RadToDeg(	FindAngle(X1, Y1, X2, Y2)    )	 ) Mod 360 
End Sub

Sub FindDistance(X1 As Int, Y1 As Int, X2 As Int, Y2 As Int) As Double  
    If Y2 - Y1 = 0 Then Return Abs(X2 - X1)
    If X2 - X1 = 0 Then Return Abs(Y2 - Y1)
    Return Abs(Y2 - Y1) / Sin(ATan(Abs(Y2 - Y1) / Abs(X2 - X1)))
End Sub

Sub AngleDifference(Angle1 As Int, Angle2 As Int, Absolute As Boolean) As Int
    Dim temp As Int
    temp = Angle2 - Angle1
    If temp > 180 Then temp = -360 + temp
    If Absolute Then temp = Abs(temp)
    Return temp
End Sub

Sub ClosestAngle(CurrentAngle As Int, AngleIncrement As Int)As Int 
	Dim temp As Int, Angle As Int ,Diff As Int ,temp2 As Int 
	Angle=-1
	Diff=360
	For temp = 0 To 359 Step AngleIncrement
		temp2 =  AngleDifference(CurrentAngle, temp, True)
		If temp2<Diff Then
			Angle=temp
			Diff=temp2
		End If
	Next
	Return Angle
End Sub


Sub IsWithinAngle(Angle1 As Int, Angle2 As Int, Angle As Int) As Boolean
    Return AngleDifference(Angle1, Angle2,True) <= Abs(Angle)
End Sub

Sub RoundAngle(Angle1 As Int, Angle As Int) As Int
    Dim temp As Int, rAngle As Int, rDistance As Int, temp2 As Int
    rDistance = 360
    'temp = Angle
    'Do While temp <= 360
    For temp = 0 To 360 Step Angle
        temp2 = AngleDifference(Angle1, temp,True)
        If Abs(temp2) < rDistance Then
            rDistance = Abs(temp2)
            rAngle = temp
        End If
        'temp = temp + Angle
    Next
    'Loop
    Return rAngle
End Sub






Sub Sgn(Value As Double) As Int 
	If Value=0 Then
		Return 0
	Else If Value < 0 Then
		Return -1
	Else
		Return 1
	End If
End Sub
Sub Exp(Value As Double) As Double 
	Return Power(cE, Value)
End Sub 
Sub aLog(Value As Double) As Double 
	Return Logarithm(Value,cE)
End Sub



Sub Sec(Radians As Double) As Double
	Return 1 / Cos(Radians)
End Sub
Sub CoSec(Radians As Double) As Double
    Return 1 / Sin(Radians)
End Sub
Sub CoTan(Radians As Double) As Double
    Return 1 / Tan(Radians)
End Sub
Sub ArcSin(Radians As Double) As Double
    Return ATan(Radians / Sqrt(-Radians * Radians + 1))
End Sub
Sub ArcCos(Radians As Double) As Double 
	Return ATan(-Radians / Sqrt(-Radians * Radians + 1)) + 2 * ATan(1)
End Sub
Sub ArcSec(Radians As Double) As Double 
	Return ATan(Radians / Sqrt(Radians * Radians - 1)) + Sgn((Radians) - 1) * (2 * ATan(1))
End Sub
Sub ArcCoSec(Radians As Double) As Double 
	Return ATan(Radians / Sqrt(Radians * Radians - 1)) + (Sgn(Radians) - 1) * (2 * ATan(1))
End Sub
Sub ArcCoTan(Radians As Double) As Double 
	Return ATan(Radians) + 2 * ATan(1)
End Sub
Sub HSin(Radians As Double) As Double 
	Return (Exp(Radians) - Exp(-Radians)) / 2
End Sub
Sub HCos(Radians As Double) As Double
    Return (Exp(Radians) + Exp(-Radians)) / 2
End Sub
Sub HTan(Radians As Double) As Double
	Return (Exp(Radians) - Exp(-Radians)) / (Exp(Radians) + Exp(-Radians))
End Sub
Sub HSec(Radians As Double) As Double
	Return 2 / (Exp(Radians) + Exp(-Radians))
End Sub
Sub HCoSec(Radians As Double) As Double
	Return 2 / (Exp(Radians) - Exp(-Radians))
End Sub
Sub HCoTan(Radians As Double) As Double
	Return (Exp(Radians) + Exp(-Radians)) / (Exp(Radians) - Exp(-Radians))
End Sub

Sub HArcSin(Radians As Double) As Double
	Return aLog(Radians + Sqrt(Radians * Radians + 1))
End Sub
Sub HArcCos(Radians As Double) As Double
	Return aLog(Radians + Sqrt(Radians * Radians - 1))
End Sub
Sub HArcTan(Radians As Double) As Double
	Return aLog((1 + Radians) / (1 - Radians)) / 2
End Sub
Sub HArcSec(Radians As Double) As Double
	Return aLog((Sqrt(-Radians * Radians + 1) + 1) / Radians)
End Sub
Sub HArcCoSec(Radians As Double) As Double
	Return aLog((Sgn(Radians) * Sqrt(Radians * Radians + 1) + 1) / Radians)
End Sub
Sub HArcCoTan(Radians As Double) As Double
	Return aLog((Radians + 1) / (Radians - 1)) / 2
End Sub
Sub LogN(Radians As Double, BaseN As Int) As Double
	Return aLog(Radians) / aLog(BaseN)
End Sub











Sub ConvertNumbers(Input As String, InputBase As String, OutputBase As String) As String
	Dim Value As Int, tempstr As StringBuilder , LR As Int , IsNeg As String , temp As Int , tempMap As Map
	Eval.EvalError = ""
	If API.left(Input, 1) = "-" Then IsNeg = "-"
	If IsNeg = "-" Then Input = API.Right(Input, Input.Length-1)
	
	'tempstr.Initialize 
	'For temp = 0 To 35
'		tempstr.Append(ToChar(temp))
'	Next
'	Log(tempstr.ToString)
	
	If Not(IsNumber(InputBase)) Or Not(IsNumber(OutputBase)) Then
		tempMap = MakeUnitMap(API.getstring("units_23"))
		If Not(IsNumber(InputBase)) Then  InputBase = tempMap.GetDefault(InputBase.ToUpperCase, tempMap.Getdefault(InputBase.ToLowerCase,0))
		If Not(IsNumber(OutputBase)) Then OutputBase = tempMap.GetDefault(OutputBase.ToUpperCase, tempMap.Getdefault(OutputBase.ToLowerCase,0))
	End If
	If InputBase < 2 Or OutputBase <2 Or InputBase > 36 Or OutputBase > 36 Then
		Eval.EvalError = API.GetString("calc_bothbases")
	Else
		temp = FindBiggestBase(Input)
		If temp < InputBase Then
			Value = Bit.ParseInt(Input, InputBase)
			Select Case OutputBase
				Case 2: 	Return IsNeg & Bit.ToBinaryString(Value)
				Case 8: 	Return IsNeg & Bit.ToOctalString(Value)
				Case 10: 	Return IsNeg & Value
				Case 16: 	Return IsNeg & Bit.ToHexString(Value)
				Case Else
					tempstr.Initialize 
					LR= FindLargestRadix(Value, OutputBase)
					Do Until LR<2
						temp = Floor(Value / LR)
						tempstr.Append(ToChar(temp))
						'Log(Input & " / " & LR & " = " & temp & " ( " & ToChar(temp) & " ) ")
						Value = Value Mod LR '- (temp*lr)
						LR = LR / OutputBase
					Loop
					If Value>0 Then tempstr.Append(ToChar(Value))
					Return IsNeg & tempstr.ToString 
			End Select
		Else If temp = 255 Then
			Eval.EvalError = API.GetString("calc_invalidchar")
		Else
			Eval.EvalError = API.getstringvars("calc_toobig", Array As String(temp))
		End If
	End If
End Sub
Sub ToChar(Input As Int) As String 
	If Input<10 Then Return Input
	Return Chr(Asc("A") + (Input-10))
End Sub
Sub FindBiggestBase(Input As String) As Int
	Dim temp As Int, tchar As String, temp2 As Int, Largest As Int   
	For temp = 0 To Input.Length - 1 
		tchar = API.Mid(Input, temp,1).ToUpperCase 
		If IsNumber(tchar) Then 
			Largest = Max(Largest, tchar)
		Else
			temp2 = Asc(tchar)
			If temp2 < Asc("A") Or temp2 > Asc("Z") Then
				Largest=255
			Else
				Largest = Max(Largest, temp2  - Asc("A") + 10)
			End If
		End If
	Next
	Return Largest
End Sub
Sub FindLargestRadix(Input As Int, Base As Int) As Int
	Dim temp As Int = 1, LR As Int = -1
	Do Until temp > Input
		temp = temp * Base 
		If temp < Input Then LR=temp
	Loop
	Return LR
End Sub



Sub GetConversionValue(UnitType As String, Units As String) As Double 
	Dim tempMap As Map = MakeUnitMap(UnitType)
	Return tempMap.GetDefault(Units.ToUpperCase, tempMap.Getdefault(Units.ToLowerCase,0))
End Sub

'UnitType: 0=temperature
Sub ConvertUnits(UnitType As String, Input As Double, InputUnits As String, OutputUnits As String) As Double 
	Eval.EvalError = ""
	Select Case UnitType 
		Case 0, "TEMPERATURE"' normalized to C/metric, use weather.CurrentUnits
			Select Case InputUnits.ToUpperCase.Replace("°","") 
				Case "K", "KELVIN":					Input = Input -273.15 
				Case "F", "IMPERIAL", "FAHRENHEIT":	Input = (Input  -  32) * (5/9)
				Case "R", "RANKINE":				Input = (Input-491.67)/1.8
				Case "Ré", "REAUMUR":				Input = Input / 0.80000
				Case "Rø", "ROMER":					Input = (Input - 7.5) / 0.525
				Case "N", "NEWTON":					Input = Input / 0.33000
				Case "D", "DELISLE":				Input = (Input + 100) / 1.5
			End Select
			Select Case OutputUnits.ToUpperCase.Replace("°","")
				Case "K", "KELVIN":					Return Input + 273.15
				Case "F", "IMPERIAL", "FAHRENHEIT":	Return Input * (9/5) + 32
				Case "R", "RANKINE":				Return (Input*1.8)+491.67
				Case "Ré", "REAUMUR":				Return Input * 0.80000
				Case "Rø", "ROMER":					Return Input * 0.525 + 7.5
				Case "N", "NEWTON":					Return Input * 0.33000
				Case "D", "DELISLE":				Return Input * 1.5 - 100
			End Select
		Case Else'uses 2 step normalization, values retrieved from a map
			'Input = Input * GetUnitConversion(UnitType, InputUnits) / GetUnitConversion(UnitType, OutputUnits)
			Dim tempMap As Map = MakeUnitMap(UnitType)
			Dim InputConversion As Double = tempMap.GetDefault(InputUnits.ToUpperCase, tempMap.Getdefault(InputUnits.ToLowerCase,0))
			Dim OutputConversion As Double = tempMap.GetDefault(OutputUnits.ToUpperCase, tempMap.Getdefault(OutputUnits.ToLowerCase,0))
						
			If UnitType.EqualsIgnoreCase("SPEED") And (InputConversion <0 Or OutputConversion<0) Then
				'If OutputConversion < 0 Then 
				'	'Eval.EvalError = "CAN ONLY CONVERT FROM WARP, NOT TO IT"
				'	Input = Input ReverseWarp
				'If InputConversion < 0 Then  
				'	Input = Eval.WarpFactor(Input, Abs(InputConversion)) * Eval.C / OutputConversion
				'End If
					
				If InputConversion < 0 Then 
					Input = Eval.WarpFactor(Input, Abs(InputConversion)) 
					InputConversion = Eval.C 
				End If
				If OutputConversion < 0 Then Return Eval.ReverseWarp(Input, Abs(OutputConversion), 2) 
			End If

			'Log(Input & "/" & UnitType & " InputConversion: " & InputConversion & " OutputConversion: " & OutputConversion)
			Input = Input * InputConversion / OutputConversion
			'Log("After: " & Input)
			
	End Select
	Return Input
End Sub

Sub UnitList(UnitType As String) As List
	Dim tempMap As Map, templ As List,  temp As Int 
	'Select Case UnitType.ToUpperCase 
		'Case -1, "ALL": 		Return Array As String("TEMPERATURE", "DISTANCE")
		'Case 0, "TEMPERATURE": 	Return Array As String("CELSIUS", "KELVIN", "FAHRENHEIT")
		'Case 1, "DISTANCE":		Return Array As String("A.U.", "CENTIMETER", "FEET", "INCH", "KILOMETER", "LEAGUE", "LEAGUE (NAUT.)", "LIGHT SECOND", "LIGHT MINUTE", "LIGHT HOUR", "LIGHT DAY", "LIGHT YEAR (JUL.)", "LIGHT YEAR (TRAD.)", "LIGHT YEAR (TROP.)", "METER", "MILE", "MILLIMETER", "PARSEC", "YARD")
		'Case Else
			tempMap = MakeUnitMap(UnitType)
			templ.Initialize 
			For temp = 0 To tempMap.Size -1 
				templ.Add(API.uCase(tempMap.GetKeyAt(temp)))
			Next
			Return templ
	'End Select
End Sub
'Sub GetUnitConversion(UnitType As String, Unit As String) As Double 
'	Select Case UnitType.ToUpperCase 
'		Case 1, "DISTANCE"
'			Select Case Unit
'				Case "A.U.": 						Return 149597870691
'				Case "CENTIMETER":					Return 0.01
'				Case "FEET":						Return 0.3048
'				Case "INCH":						Return 0.3048/12
'				Case "KILOMETER": 					Return 1000
'				Case "LEAGUE":						Return 4828.0417
'				Case "LEAGUE (NAUT.)":				Return 5556
'				Case "LIGHT SECOND": 				Return 299792458
'				Case "LIGHT MINUTE": 				Return 299792458 * 60
'				Case "LIGHT HOUR": 					Return 299792458 * 60 * 60
'				Case "LIGHT DAY": 					Return 299792458 * 60 * 60 * 24
'				Case "LIGHT YEAR (JUL.)": 			Return 299792458 * 60 * 60 * 24 * 365.25
'				Case "LIGHT YEAR (TRAD.)":			Return 299792458 * 60 * 60 * 24 * 365
'				Case "LIGHT YEAR (TROP.)": 			Return 299792458 * 31556925.9747
'				Case "METER":						Return 1'normalization
'				Case "MILE":						Return 1609.344
'				Case "MILLIMETER":					Return 0.001
'				Case "PARSEC":						Return 149597870691 * 206264.8
'				Case "YARD":						Return 0.9144
'			End Select
'		Case 2, "ACCELERATION"
'	End Select
'End Sub
Sub PutItems(Dest As Map, Items As List)
	Dim temp As Int 
	For temp = 0 To Items.size-1 
		Dest.Put(Items.Get(temp), "")
	Next
End Sub
Sub MakeUnitMap(UnitType As String) As Map 'http://www.onlineconversion.com/
	Dim temp As Map
	temp.Initialize 
	Select Case UnitType.ToUpperCase 
		Case -1, "ALL"	
			PutItems(temp, Array As String("ACCELERATION", "ANGLES", "AREA", "COMPUTER MEMORY", "DENSITY", "DISTANCE", "ELECTRIC CAPACITANCE", "ELECTRIC CURRENT", "ENERGY", "FLOW RATE (MASS)", "FLOW RATE (MOLE)", "FLOW RATE (VOLUME)", "FORCE", "FREQUENCY", "ILLUMINANCE", "LUMINANCE", API.getstring("units_23"), "POWER", "PRESSURE", "SPEED", "TEMPERATURE", "TORQUE", "VOLUME", "WEIGHT/MASS", "PLANETARY WEIGHT"))
		
		Case 0, "TEMPERATURE"
			PutItems(temp, Array As String("CELSIUS", "DELISLE", "FAHRENHEIT", "KELVIN", "NEWTON", "RANKINE", "REAUMUR", "ROMER"))
	
		Case 1, "DISTANCE"
			temp.Put("A.U.", 										149597870691)
			temp.Put("CENTIMETER",									0.01)
			temp.Put("FEET",										0.3048)
			temp.Put("INCH",										0.3048/12)
			temp.Put("KILOMETER", 									1000)
			temp.Put("LEAGUE",										4828.0417)
			temp.Put("LEAGUE (NAUT.)",								5556)
			temp.Put("LIGHT SECOND", 								299792458)
			temp.Put("LIGHT MINUTE", 								299792458 * 60)
			temp.Put("LIGHT HOUR", 									299792458 * 60 * 60)
			temp.Put("LIGHT DAY", 									299792458 * 60 * 60 * 24)
			temp.Put("LIGHT YEAR (JUL.)", 							299792458 * 60 * 60 * 24 * 365.25)
			temp.Put("LIGHT YEAR (TRAD.)",							299792458 * 60 * 60 * 24 * 365)
			temp.Put("LIGHT YEAR (TROP.)", 							299792458 * 31556925.9747)
			temp.Put("METER",										1)'normalization
			temp.Put("MILE",										1609.344)
			temp.Put("MILLIMETER",									0.001)
			temp.Put("PARSEC",										149597870691 * 206264.8)
			temp.Put("YARD",										0.9144)
			
		Case 2, "ACCELERATION"
			temp.Put("CENTIGAL",									0.0001)'1
			temp.Put("centimeter/square second",					0.01)'2
			temp.Put("decigal",										0.001)'3
			temp.Put("decimeter/square second",						0.1)'4
			temp.Put("dekameter/square second",						10)'5
			temp.Put("foot/square second",							0.3048)'6
			temp.Put("g-unit (G)",									9.80665)'7
			temp.Put("gal,galileo",									0.01)'8,9
			temp.Put("g_n,grav",									9.80665)'10,11
			temp.Put("hectometer/square second",					100)'12
			temp.Put("inch/square second",							0.0254)'13
			temp.Put("kilometer/hour second",						0.277777777777778)'14
			temp.Put("kilometer/square second",						1000)'15
			temp.Put("meter/square second",							1)'16
			temp.Put("mile/hour minute",							0.0074506666666666667)'17
			temp.Put("mile/hour second",							0.44704)'18
			temp.Put("mile/square second",							1609.344)'19
			temp.Put("milligal",									0.00001)'20
			temp.Put("millimeter/square second",					0.001)'21
		
		Case 3, "WEIGHT/MASS"
			temp.Put("ARRATEL, ARTEL (ARAB)", 						0.5)
			temp.Put("ARROBA (PORTUGAL)", 							14.69)
			temp.Put("ARROBA (SPAIN)", 								11.502)
			temp.Put("AS, ASS (NORTHERN EUROPE)", 					0.000052)
			temp.Put("ATOMIC MASS UNIT (1960)", 					1.6603145e-27)
			temp.Put("ATOMIC MASS UNIT (1973)", 					1.6605655e-27)
			temp.Put("ATOMIC MASS UNIT (1986)", 					1.6605402e-27)
			temp.Put("ATOMIC MASS UNIT (1998)", 					1.66053873e-27)
			temp.Put("AVOGRAM", 									1.6605402e-27)
			temp.Put("BAG (PORTLAND CEMENT)", 						0.45359237*94)
			temp.Put("BAHT (THAILAND)", 							0.015)
			temp.Put("BALE (UK)", 									0.45359237*720)
			temp.Put("BALE (US)", 									0.45359237*480)
			temp.Put("BISMAR POUND (DENMARK)", 						5.993)
			temp.Put("CANDY (INDIA)", 								254)
			temp.Put("CARAT (INTERNATIONAL)",						0.0002)
			temp.Put("CARAT (METRIC)", 								0.0002)
			temp.Put("CARAT (UK)", 									0.00006479891*4)
			temp.Put("CARAT (PRE-1913 US)", 						0.0002053)
			temp.Put("CARGA (MEXICO)", 								140)
			temp.Put("CATTI (CHINA)", 								0.604875)
			temp.Put("CATTI (JAPAN)", 								0.594)
			temp.Put("CATTY (CHINA)", 								0.5)
			temp.Put("CATTY (JAPAN, THAILAND)", 					0.6)
			temp.Put("CENTAL", 0.45359237*100)
			temp.Put("CENTIGRAM", 0.00001)
			temp.Put("CENTNER (GERMANY)", 50)
			temp.Put("CENTNER (RUSSIA)", 100)
			temp.Put("CHALDER, CHALDRON", 2692.52)
			temp.Put("CHIN (CHINA)", 0.5)
			temp.Put("CHIN (JAPAN)", 0.6)
			temp.Put("CLOVE", 3.175)
			temp.Put("CRITH", 0.000089885)
			temp.Put("DALTON", 1.6605402e-27)
			temp.Put("DAN (CHINA)", 50)
			temp.Put("DAN (JAPAN)", 60)
			temp.Put("DECIGRAM", 0.0001)
			temp.Put("DECITONNE", 100)
			temp.Put("DEKAGRAM", 0.01)
			temp.Put("DEKATONNE", 10000)
			temp.Put("DENARO (ITALY)", 0.0011)
			temp.Put("DENIER (FRANCE)", 0.001275)
			temp.Put("DRACHME", 0.0038)
			temp.Put("DRAM", 0.45359237/256)
			temp.Put("DRAM (APOTHECARIES)", 0.00006479891*60)
			temp.Put("DYNE", 1.01971621E-06)
			temp.Put("ELECTRON", 9.109382e-31)
			temp.Put("ELECTRONVOLT", 1.782662e-36)
			temp.Put("ETTO (ITALY)", 0.1)
			temp.Put("EXAGRAM", 1.0e+15)
			temp.Put("FEMTOGRAM", 1.0e-18)
			temp.Put("FIRKIN (BUTTER, SOAP)", 0.45359237*56)
			temp.Put("FLASK", 34.7)
			temp.Put("FOTHER (LEAD)", (0.45359237*72)*30)
			temp.Put("FOTMAL (LEAD)", 0.45359237*72)
			temp.Put("FUNT, FUNTE (RUSSIA)", 0.4095)
			temp.Put("GAMMA", 0.000000001)
			temp.Put("GIGAELECTRONVOLT", 1.782662e-27)
			temp.Put("GIGAGRAM", 1000000)
			temp.Put("GIGATONNE", 1.0e+12)
			temp.Put("GIN (CHINA)", 0.6)
			temp.Put("GIN (JAPAN)", 0.594)
			temp.Put("GRAIN", 0.00006479891)
			temp.Put("GRAM", 0.001)
			temp.Put("GRAN (GERMANY)", 0.00082)
			temp.Put("GRANO, GRANI (ITALY)", 0.00004905)
			temp.Put("GROS", 0.003824)
			temp.Put("HECTOGRAM", 0.1)
			temp.Put("HUNDREDWEIGHT (LONG, UK)", 0.45359237*112)
			temp.Put("HUNDREDWEIGHT (SHORT, US)", 0.45359237*100)
			temp.Put("HYL", 9.80665)
			temp.Put("JIN (CHINA)", 0.5)
			temp.Put("JUPITER", 1.899e+27)
			temp.Put("KATI (CHINA)", 0.5)
			temp.Put("KATI (JAPAN)", 0.6)
			temp.Put("KEEL (COAL)", 0.45359237*47488)
			temp.Put("KEG (NAILS)", 0.45359237*100)
			temp.Put("KILODALTON", 1.6605402e-24)
			temp.Put("KILOGRAM", 1)
			temp.Put("KILOGRAM-FORCE", 1)
			temp.Put("KILOTON (LONG, UK)", (0.45359237*2240)*1000)
			temp.Put("KILOTON (SHORT, US)", (0.45359237*2000)*1000)
			temp.Put("KILOTONNE", 1000000)
			temp.Put("KIN (JAPAN)", 0.6)
			temp.Put("KIP", 0.45359237*1000)
			temp.Put("KOYAN (MALAYSIA)", 2419)
			temp.Put("KWAN (JAPAN)", 3.75)
			temp.Put("LAST (GERMANY)", 2000)
			temp.Put("LAST (US)", 0.45359237*4000)
			temp.Put("LAST (US, WOOL)", 0.45359237*4368)
			temp.Put("LB, LBS", 0.45359237)
			temp.Put("LIANG (CHINA)", 0.05)
			temp.Put("LIBRA (ITALY)", 0.339)
			temp.Put("LIBRA (PORTUGAL, SPAIN)", 0.459)
			temp.Put("LIBRA (ANCIENT ROME)", 0.323)
			temp.Put("LIBRA (METRIC)", 1)
			temp.Put("LIVRE (FRANCE)", 0.4895)
			temp.Put("LONG TON", 0.45359237*2240)
			temp.Put("LOT (GERMANY)", 0.015)
			temp.Put("MACE (CHINA)", 0.003778)
			temp.Put("MAHND (ARAB)", 0.9253284348)
			temp.Put("MARC (FRANCE)", 0.24475)
			temp.Put("MARCO (SPANISH)", 0.23)
			temp.Put("MARK (ENGLISH)", 0.2268)
			temp.Put("MARK (GERMAN)", 0.2805)
			temp.Put("MAUND (INDIA)", 37.3242)
			temp.Put("MAUND (PAKISTAN)", 40)
			temp.Put("MEGADALTON", 1.6605402e-21)
			temp.Put("MEGAGRAM", 1000)
			temp.Put("MEGATONNE", 1.0e+9)
			temp.Put("MERCANTILE POUND", 0.46655)
			temp.Put("METRIC TON", 1000)
			temp.Put("MIC", 1.0e-9)
			temp.Put("MICROGRAM", 1.0e-9)
			temp.Put("MILLIDALTON", 1.6605402e-30)
			temp.Put("MILLIER", 1000)
			temp.Put("MILLIGRAM", 0.000001)
			temp.Put("MILLIMASS UNIT", 1.6605402e-30)
			temp.Put("MINA (HEBREW)", 0.499)
			temp.Put("MOMME (JAPAN)", 0.00375)
			temp.Put("MYRIAGRAM", 10)
			temp.Put("NANOGRAM", 1.0e-12)
			temp.Put("NEWTON", 0.101971621)
			temp.Put("OBOL, OBOLOS, OBOLUS (GREECE)", 0.0001)
			temp.Put("OBOLOS (ANCIENT GREECE)", 0.0005)
			temp.Put("OBOLUS (ANCIENT ROME)", 0.00057)
			temp.Put("OKKA (TURKEY)", 1.28)
			temp.Put("ONÇA (PORTUGUESE)", 0.02869)
			temp.Put("ONCE (FRANCE)", 0.03059)
			temp.Put("ONCIA (ITALY)", 0.0273)
			temp.Put("ONZA (SPANISH)", 0.02869)
			temp.Put("ONS (DUTCH)", 0.1)
			temp.Put("OUNCE", 0.45359237/16)
			temp.Put("OUNCE-FORCE", 0.45359237/16)
			temp.Put("OUNCE (TROY)", ((144/175)*0.45359237)/12)
			temp.Put("PACKEN (RUSSIA)", 490.79)
			temp.Put("PENNYWEIGHT (TROY)", (((144/175)*0.45359237)/12)/20)
			temp.Put("PETAGRAM", 1.0e+12)
			temp.Put("PFUND (DENMARK, GERMANY)", 0.5)
			temp.Put("PICOGRAM", 1.0e-15)
			temp.Put("POINT", 0.000002)
			temp.Put("POND (DUTCH)", 0.5)
			temp.Put("POUND", 0.45359237)
			temp.Put("POUND-FORCE", 0.45359237)
			temp.Put("POUND (METRIC)", 0.5)
			temp.Put("POUND (TROY)", (144/175)*0.45359237)
			temp.Put("PUD, POOD (RUSSIA)", 16.3)
			temp.Put("PUND (SCANDINAVIA)", 0.5)
			temp.Put("QIAN (CHINA)", 0.005)
			temp.Put("QINTAR (ARAB)", 50)
			temp.Put("QUARTER (UK)", 0.45359237*28)
			temp.Put("QUARTER (US)", 0.45359237*25)
			temp.Put("QUARTER (TON) (US)", 0.45359237*500)
			temp.Put("QUARTERN", (0.45359237*14)/4)
			temp.Put("QUARTERN-LOAF", 0.45359237*4)
			temp.Put("QUINTAL (FRENCH)", 48.95)
			temp.Put("QUINTAL (METRIC)", 100)
			temp.Put("QUINTAL (PORTUGAL)", 58.752)
			temp.Put("QUINTAL (SPANISH)", 45.9)
			temp.Put("REBAH", 0.01142/4)
			temp.Put("ROBIE", 0.01)
			temp.Put("ROTL, ROTEL, ROTTLE, RATEL (ARAB)", 0.5)
			temp.Put("SACK (UK, WOOL)", 0.45359237*364)
			temp.Put("SCRUPLE (TROY)", (((144/175)*0.45359237)/12)/24)
			temp.Put("SEER (INDIA)", 37.3242/40)
			temp.Put("SEER (PAKISTAN)", 1)
			temp.Put("SHEKEL (HEBREW)", 0.01142)
			temp.Put("SHORT TON", 0.45359237*2000)
			temp.Put("SLINCH", 14.593903*12)
			temp.Put("SLUG", 14.593903)
			temp.Put("STONE", 0.45359237*14)
			temp.Put("TAEL, TAHIL (JAPAN)", 0.03751)
			temp.Put("TAHIL (CHINA)", 0.05)
			temp.Put("TALENT (HEBREW)", 30)
			temp.Put("TAN (CHINA)", 50)
			temp.Put("TECHNISCHE MASS EINHEIT (TME)", 9.80665)
			temp.Put("TERAGRAM", 1.0e+9)
			temp.Put("TETRADRACHM (HEBREW)", 0.014)
			temp.Put("TICAL (ASIA)", 0.0164)
			temp.Put("TOD", (0.45359237*14)*2)
			temp.Put("TOLA (INDIA)", (37.3242/40)/80)
			temp.Put("TOLA (PAKISTAN)", 1/80)
			temp.Put("TON (LONG, UK)", 0.45359237*2240)
			temp.Put("TON (METRIC)", 1000)
			temp.Put("TON (SHORT, US)", 0.45359237*2000)
			temp.Put("TONELADA (PORTUGAL)", 793.15)
			temp.Put("TONELADA (SPAIN)", 919.9)
			temp.Put("TONNE", 1000)
			temp.Put("TONNEAU (FRANCE)", 979)
			temp.Put("TOVAR (BULGARIA)", 128.8)
			temp.Put("TROY OUNCE", ((144/175)*0.45359237)/12)
			temp.Put("TROY POUND", (144/175)*0.45359237)
			temp.Put("TRUSS", 0.45359237*56)
			temp.Put("UNCIA (ROME)", 0.0272875)
			temp.Put("UNZE (GERMANY)", 0.03125)
			temp.Put("VAGON (YUGOSLAVIA)", 10000)
			temp.Put("YOCTOGRAM", 1.0e-27)
			temp.Put("YOTTAGRAM", 1.0e+21)
			temp.Put("ZENTNER (GERMANY)", 50)
			temp.Put("ZEPTOGRAM", 1.0e-24)
			temp.Put("ZETTAGRAM", 1.0e+18)
		
		Case 4, "AREA"
			temp.Put("ACRE", 0.09290304*43560)
			temp.Put("ACRE (SUBURBS)", 0.09290304*36000)
			temp.Put("ACRE (SURVEY)", 0.092903412*43560)
			temp.Put("ACRE (IRELAND)", 6555)
			temp.Put("ARE", 100)
			temp.Put("ARPENT (CANADA)", 3418.89)
			temp.Put("BARN", 1E-28)
			temp.Put("BOVATE", 60000)
			temp.Put("BUNDER", 10000)
			temp.Put("CABALLERIA (SPAIN/PERU)", 400000)
			temp.Put("CABALLERIA (CENTRAL AMERICA)", 450000)
			temp.Put("CABALLERIA (CUBA)", 134200)
			temp.Put("CARREAU", 12900)
			temp.Put("CARUCATE", 486000)
			temp.Put("CAWNEY", (4/3) * (0.09290304*43560))
			temp.Put("CENTIARE", 1)
			temp.Put("CONG", 1000)
			temp.Put("COVER", 2698)
			temp.Put("CUERDA", 3930)
			temp.Put("DEKARE", 1000)
			temp.Put("DESSIATINA", 10925)
			temp.Put("DHUR", 16.929)
			temp.Put("DUNUM, DUNHAM", 1000)
			temp.Put("FALL (SCOTS)", 32.15)
			temp.Put("FALL (ENGLISH)", 47.03)
			temp.Put("FANEGA", 6430)
			temp.Put("FARTHINGDALE", 1012)
			temp.Put("HACIENDA", 89600000)
			temp.Put("HECTARE", 10000)
			temp.Put("HIDE", 486000)
			temp.Put("HOMESTEAD", 647500)
			temp.Put("HUNDRED", 50000000)
			temp.Put("JERIB", 2000)
			temp.Put("JITRO, JOCH, JUTRO", 5755)
			temp.Put("JO (JAPAN)", 1.62)
			temp.Put("KAPPLAND", 154.26)
			temp.Put("KATTHA (NEPAL)", 338)
			temp.Put("LABOR", 716850)
			temp.Put("LEGUA", 17920000)
			temp.Put("MANZANA (COSTA RICAN)", 6988.96)
			temp.Put("MANZANA (ARGENTINA)", 10000)
			temp.Put("MANZANA (NICARAGUA)", 70.44*100)
			temp.Put("MORGEN (GERMANY)", 2500)
			temp.Put("MORGEN (SOUTH AFRICA)", 8567)
			temp.Put("MU", (1/15)*10000)
			temp.Put("NGARN", 400)
			temp.Put("NOOK", 80937.128)
			temp.Put("OXGANG", 60000)
			temp.Put("PERCH", 25.29285264)
			temp.Put("PERCHE (CANADA)", 34.19)
			temp.Put("PING", 3.305)
			temp.Put("PYONG", 3.306)
			temp.Put("RAI", 1600)
			temp.Put("ROOD", 1011.7141)
			temp.Put("SECTION", 2589998.5)
			temp.Put("SHED", 10E-52)
			temp.Put("SITIO", 18000000)
			temp.Put("SQUARE", 9.290304)
			temp.Put("SQUARE ANGSTROM", 1.0E-20)
			temp.Put("SQUARE ASTRONOMICAL UNIT", 2.2379523E+22)
			temp.Put("SQUARE ATTOMETER", 1.0E-36)
			temp.Put("SQUARE BICRON", 1.0E-24)
			temp.Put("SQUARE CENTIMETER", 0.0001)
			temp.Put("SQUARE CHAIN (GUNTER, SURVEY)", 404.68726)
			temp.Put("SQUARE CHAIN (RAMDEN, ENGINEER)", 929.03412)
			temp.Put("SQUARE CITY BLOCK (EAST U.S.)", 6474.97027584)
			temp.Put("SQUARE CITY BLOCK (MIDWEST U.S.)", 10117.141056)
			temp.Put("SQUARE CITY BLOCK (SOUTH, WEST U.S.)", 25899.88110336)
			temp.Put("SQUARE CUBIT", 0.20903184)
			temp.Put("SQUARE DECIMETER", 0.01)
			temp.Put("SQUARE DEKAMETER", 100)
			temp.Put("SQUARE EXAMETER", 1.0E+36)
			temp.Put("SQUARE FATHOM", 3.3445228)
			temp.Put("SQUARE FEMTOMETER", 1.0E-30)
			temp.Put("SQUARE FERMI", 1.0E-30)
			temp.Put("SQUARE FOOT", 0.09290304)
			temp.Put("SQUARE FOOT (SURVEY)", 0.092903412)
			temp.Put("SQUARE FURLONG", 40468.726)
			temp.Put("SQUARE GIGAMETER", 1.0E+18)
			temp.Put("SQUARE HECTOMETER", 10000)
			temp.Put("SQUARE INCH", 0.09290304/144)
			temp.Put("SQUARE INCH (SURVEY)", 0.092903412/144)
			temp.Put("SQUARE KILOMETER", 1000000)
			temp.Put("SQUARE LEAGUE (NAUTICAL)", 3.0869136E+07)
			temp.Put("SQUARE LEAGUE (U.S. STATUTE)", 2.3309986E+07)
			temp.Put("SQUARE LIGHT YEAR", 8.9505412E+31)
			temp.Put("SQUARE LINK (GUNTER, SURVEY)", 0.040468726)
			temp.Put("SQUARE LINK (RAMDEN, ENGINEER)", 0.092903412)
			temp.Put("SQUARE MEGAMETER", 1.0E+12)
			temp.Put("SQUARE METER", 1)
			temp.Put("SQUARE MICROINCH", 1.0E-6 * 6.4516E-10)
			temp.Put("SQUARE MICROMETER", 1.0E-12)
			temp.Put("SQUARE MICROMICRON", 1.0E-24)
			temp.Put("SQUARE MICRON", 1.0E-12)
			temp.Put("SQUARE MIL", 6.4516E-10)
			temp.Put("SQUARE MILE", 0.09290304*27878400)
			temp.Put("SQUARE MILE (NAUTICAL)", 3429904)
			temp.Put("SQUARE MILE (SURVEY, U.S. STATUTE)", 2589998.5)
			temp.Put("SQUARE MILLIMETER", 0.000001)
			temp.Put("SQUARE MILLIMICRON", 1.0E-18)
			temp.Put("SQUARE MYRIAMETER", 1.0E+8)
			temp.Put("SQUARE NANOMETER", 1.0E-18)
			temp.Put("SQUARE PARIS FOOT", 0.1055)
			temp.Put("SQUARE PARSEC", 9.5214087E+32)
			temp.Put("SQUARE PERCH", 25.292954)
			temp.Put("SQUARE PERCHE", 51.072)
			temp.Put("SQUARE PETAMETER", 1.0E+30)
			temp.Put("SQUARE PICOMETER", 1.0E-24)
			temp.Put("SQUARE ROD", 0.092903412*272.25)
			temp.Put("SQUARE TENTHMETER", 1.0E-20)
			temp.Put("SQUARE TERAMETER", 1.0E+24)
			temp.Put("SQUARE THOU", 6.4516E-10)
			temp.Put("SQUARE VARA (CALIFORNIA)", 0.70258205)
			temp.Put("SQUARE VARA (TEXAS)", 0.71684731)
			temp.Put("SQUARE YARD", 0.09290304*9)
			temp.Put("SQUARE YARD (SURVEY)", 0.092903412*9)
			temp.Put("SQUARE YOCTOMETER", 1.0E-48)
			temp.Put("SQUARE YOTTAMETER", 1.0E+48)
			temp.Put("STANG", 2709)
			temp.Put("STREMMA", 1000)
			temp.Put("TAREA", 628.8)
			temp.Put("TATAMI (JAPAN)", 1.62)
			temp.Put("TØNDE LAND", 5516)
			temp.Put("TOWNSHIP", 0.092903412*43560*23040)
			temp.Put("TSUBO", 3.3058)
			temp.Put("TUNNLAND", 4936.4)
			temp.Put("YARD", 0.09290304*9)
			temp.Put("VIRGATE", 120000)
		
		Case 5, "ENERGY"
			temp.Put("ATTOJOULE", 1.0e-18)
			temp.Put("BOARD OF TRADE UNIT", 3600000)
			temp.Put("BTU", 1055.0559)
			temp.Put("BTU (THERMOCHEMICAL)", 1054.3503)
			temp.Put("CALORIE (I.T.)", 4.1868)
			temp.Put("CALORIE (15° C)", 4.1858)
			temp.Put("CALORIE (NUTRITIONAL)", 4186.8)
			temp.Put("CALORIE (THERMOCHEMICAL)", 4.184)
			temp.Put("CELSIUS HEAT UNIT", 1899.1005)
			temp.Put("CENTIJOULE", 0.01)
			temp.Put("CHEVAL VAPEUR HEURE", 2647795.5)
			temp.Put("DECIJOULE", 0.1)
			temp.Put("DEKAJOULE", 10)
			temp.Put("DEKAWATT HOUR", 36000)
			temp.Put("DEKATHERM", 1.055057e+09)
			temp.Put("ELECTRONVOLT", 1.6021773e-19)
			temp.Put("ERG", 0.0000001)
			temp.Put("EXAJOULE", 1.0e+18)
			temp.Put("EXAWATT HOUR", 3.6e+21)
			temp.Put("FEMTOJOULE", 1.0e-15)
			temp.Put("FOOT POUND", 1.3558179)
			temp.Put("FOOT POUNDAL", 0.04214011)
			temp.Put("GALLON (UK) OF AUTOMOTIVE GASOLINE", 1.3176e+08*1.20095)
			temp.Put("GALLON (U.S.) OF AUTOMOTIVE GASOLINE", 1.3176e+08)
			temp.Put("GALLON (UK) OF AVIATION GASOLINE", 1.3176e+08*1.20095)
			temp.Put("GALLON (U.S.) OF AVIATION GASOLINE", 1.3176e+08)
			temp.Put("GALLON (UK) OF DIESEL OIL", 1.4652e+08*1.20095)
			temp.Put("GALLON (U.S.) OF DIESEL OIL", 1.4652e+08)
			temp.Put("GALLON (UK) OF DISTILATE #2 FUEL OIL", 1.4652e+08*1.20095)
			temp.Put("GALLON (U.S.) OF DISTILATE #2 FUEL OIL", 1.4652e+08)
			temp.Put("GALLON (UK) OF KEROSENE TYPE JET FUEL", 1.422e+08*1.20095)
			temp.Put("GALLON (U.S.) OF KEROSENE TYPE JET FUEL", 1.422e+08)
			temp.Put("GALLON (UK) OF LPG", 100757838.45*1.20095)
			temp.Put("GALLON (U.S.) OF LPG", 100757838.45)
			temp.Put("GALLON (UK) OF NAPHTHA TYPE JET FUEL", 1.3392e+08*1.20095)
			temp.Put("GALLON (U.S.) OF NAPHTHA TYPE JET FUEL", 1.3392e+08)
			temp.Put("GALLON (UK) OF KEROSENE", 1.422e+08*1.20095)
			temp.Put("GALLON (U.S.) OF KEROSENE", 1.422e+08)
			temp.Put("GALLON (UK) OF RESIDUAL FUEL OIL", 1.5804e+08*1.20095)
			temp.Put("GALLON (U.S.) OF RESIDUAL FUEL OIL", 1.5804e+08)
			temp.Put("GIGAELECTRONVOLT", 1.6021773e-10)
			temp.Put("GIGACALORIE (I.T.)", 4186800000)
			temp.Put("GIGACALORIE (15° C)", 4185800000)
			temp.Put("GIGAJOULE", 1.0e+09)
			temp.Put("GIGAWATT HOUR", 3.6e+12)
			temp.Put("GRAM CALORIE", 4.1858)
			temp.Put("HARTREE", 4.3597482e-18)
			temp.Put("HECTOJOULE", 100)
			temp.Put("HECTOWATT HOUR", 360000)
			temp.Put("HORSEPOWER HOUR", 2684519.5)
			temp.Put("HUNDRED CUBIC FOOT OF NATURAL GAS", 108720000)
			temp.Put("INCH OUNCE", 0.0070615518)
			temp.Put("INCH POUND", 0.112984825)
			temp.Put("JOULE", 1)
			temp.Put("KILOCALORIE (15° C)", 4185.8)
			temp.Put("KILOCALORIE (I.T.)", 4186.8)
			temp.Put("KILOCALORIE (THERMOCHEMICAL)", 4184)
			temp.Put("KILOELECTRONVOLT", 1.6021773e-16)
			temp.Put("KILOGRAM CALORIE", 4185.8)
			temp.Put("KILOGRAM-FORCE METER", 9.80665)
			temp.Put("KILOJOULE", 1000)
			temp.Put("KILOPOND METER", 9.80665)
			temp.Put("KILOTON (EXPLOSIVE)", 4.184e+12)
			temp.Put("KILOWATT HOUR", 3600000)
			temp.Put("LITER ATMOSPHERE", 101.325)
			temp.Put("MEGAELECTRONVOLT", 1.6021773e-13)
			temp.Put("MEGACALORIE (I.T.)", 4186800)
			temp.Put("MEGACALORIE (15° C)", 4185800)
			temp.Put("MEGAJOULE", 1000000)
			temp.Put("MEGALERG", 0.1)
			temp.Put("MEGATON (EXPLOSIVE)", 4.184e+15)
			temp.Put("MEGAWATTHOUR", 3.6e+09)
			temp.Put("METER KILOGRAM-FORCE", 9.80665)
			temp.Put("MICROJOULE", 0.000001)
			temp.Put("MILLIJOULE", 0.001)
			temp.Put("MYRIAWATT HOUR", 3.6e+07)
			temp.Put("NANOJOULE", 1.0e-09)
			temp.Put("NEWTON METER", 1)
			temp.Put("PETAJOULE", 1.0e+15)
			temp.Put("PETAWATTHOUR", 3.6e+18)
			temp.Put("PFERDESTÄRKENSTUNDE", 2647795.5)
			temp.Put("PICOJOULE", 1.0e-12)
			temp.Put("Q UNIT", 1.0550559e+21)
			temp.Put("QUAD", 1.0550559e+18)
			temp.Put("TERAELECTRONVOLT", 1.6021773e-7)
			temp.Put("TERAJOULE", 1.0e+12)
			temp.Put("TERAWATTHOUR", 3.6e+15)
			temp.Put("THERM (EUROPE)", 1.0550559e+08)
			temp.Put("THERM (U.S. (UNCOMMON))", 1.054804e+08)
			temp.Put("THERMIE", 4185800)
			temp.Put("TON (EXPLOSIVE)", 4.184e+09)
			temp.Put("TONNE OF COAL EQUIVALENT", 2.93076e+10)
			temp.Put("TONNE OF OIL EQUIVALENT", 4.1868e+10)
			temp.Put("WATTHOUR", 3600)
			temp.Put("WATTSECOND", 1)
			temp.Put("YOCTOJOULE", 1.0e-24)
			temp.Put("YOTTAJOULE", 1.0e+24)
			temp.Put("YOTTAWATTHOUR", 3.6e+27)
			temp.Put("ZEPTOJOULE", 1.0e-21)
			temp.Put("ZETTAJOULE", 1.0e+21)
			temp.Put("ZETTAWATTHOUR", 3.6e+24)
		
		Case 6, "FORCE"
			temp.Put("ATTONEWTON", 1.0e-18)
			temp.Put("CENTINEWTON", 0.01)
			temp.Put("DECIGRAM-FORCE", 0.00980665*0.1)
			temp.Put("DECINEWTON", 0.1)
			temp.Put("DEKAGRAM-FORCE", 0.00980665*10)
			temp.Put("DEKANEWTON", 10)
			temp.Put("DYNE", 0.00001)
			temp.Put("EXANEWTON", 1.0e18)
			temp.Put("FEMTONEWTON", 1.0e-15)
			temp.Put("GIGANEWTON", 1.0e9)
			temp.Put("GRAM-FORCE", 0.00980665)
			temp.Put("HECTONEWTON", 100)
			temp.Put("JOULE/METER", 1)
			temp.Put("KILOGRAM-FORCE", 0.00980665*1000)
			temp.Put("KILONEWTON", 1000)
			temp.Put("KILOPOND", 0.00980665*1000)
			temp.Put("KIP", 4.4482216*1000)
			temp.Put("MEGANEWTON", 1000000)
			temp.Put("MEGAPOND", 0.00980665*1000000)
			temp.Put("MICRONEWTON", 0.000001)
			temp.Put("MILLINEWTON", 0.001)
			temp.Put("NANONEWTON", 0.000000001)
			temp.Put("NEWTON", 1)
			temp.Put("OUNCE-FORCE", 4.4482216/16)
			temp.Put("PETANEWTON", 1.0e15)
			temp.Put("PICONEWTON", 1.0e-12)
			temp.Put("POND", 0.00980665)
			temp.Put("POUND-FORCE", 4.4482216)
			temp.Put("POUNDAL", 0.13825495)
			temp.Put("STHENE", 1000)
			temp.Put("TERANEWTON", 1.0e12)
			temp.Put("TON-FORCE (LONG)", 4.4482216*2240)
			temp.Put("TON-FORCE (METRIC)", 0.00980665*1000000)
			temp.Put("TON-FORCE (SHORT)", 4.4482216*2000)
			temp.Put("YOCTONEWTON", 1.0e-24)
			temp.Put("YOTTANEWTON", 1.0e24)
			temp.Put("ZEPTONEWTON", 1.0e-21)
			temp.Put("ZETTANEWTON", 1.0e21)
		
		Case 7, "ANGLES"
			temp.Put("RADIAN", 1)
			temp.Put("MIL", (Pi/3200))
			temp.Put("GRAD", (Pi/200))
			temp.Put("DEGREE", (Pi/180))
			temp.Put("MINUTE", (Pi/(180*60)))
			temp.Put("SECOND", (Pi/(180*3600)))
			temp.Put("POINT", (Pi/16))
			temp.Put("1/16 CIRCLE", (Pi/8))
			temp.Put("1/10 CIRCLE", (Pi/5))
			temp.Put("1/8 CIRCLE", (Pi/4))
			temp.Put("1/6 CIRCLE", (Pi/3))
			temp.Put("1/4 CIRCLE", (Pi/2))
			temp.Put("1/2 CIRCLE", (Pi))
			temp.Put("FULL CIRCLE", (2*Pi))
		
		Case 8, "ELECTRIC CURRENT"
			temp.Put("ABAMPERE,BIOT,DEKAAMPERE", 10)
			temp.Put("AMPERE,AMP,COULOMB/SECOND", 1)
			temp.Put("CENTIAMPERE", 0.01)
			temp.Put("DECIAMPERE", 0.1)
			temp.Put("ELECTROMAGNETIC UNIT OF CURRENT", 10)
			temp.Put("FRANKLIN/SECOND", 3.335641e-10)
			temp.Put("GIGAAMPERE", 1.0e+9)
			temp.Put("GILBERT", 0.79577472)
			temp.Put("HECTOAMPERE", 100)
			temp.Put("HENRY,OHM,VOLT,WATT,WEBER", 1)
			temp.Put("KILOAMPERE", 1000)
			temp.Put("MEGAAMPERE", 1000000)
			temp.Put("MICROAMPERE", 0.000001)
			temp.Put("MILLIAMPERE", 0.001)
			temp.Put("NANOAMPERE", 1.0e-9)
			temp.Put("PICOAMPERE", 1.0e-12)
			temp.Put("STATAMPERE", 3.335641e-10)
			temp.Put("TERAAMPERE", 1.0e+12)
			
		Case 9, "ELECTRIC CAPACITANCE"'
			temp.Put("ABFARAD", 0)
			temp.Put("CENTIFARAD", 2)
			temp.Put("COULOMB/VOLT", 3)
			temp.Put("DECIFARAD", 4)
			temp.Put("DEKAFARAD", 5)
			temp.Put("ELECTROMAGNETIC UNIT", 6)
			temp.Put("ELECTROSTATIC UNIT", 7)
			temp.Put("FARAD (SI STANDARD)", 8)
			temp.Put("FARAD (INTERNATIONAL)", 23)
			temp.Put("GAUSSIAN", 9)
			temp.Put("GIGAFARAD", 10)
			temp.Put("HECTOFARAD", 11)
			temp.Put("JAR", 12)
			temp.Put("KILOFARAD", 13)
			temp.Put("MEGAFARAD", 14)
			temp.Put("MICROFARAD", 15)
			temp.Put("MILLIFARAD", 16)
			temp.Put("NANOFARAD", 17)
			temp.Put("PICOFARAD", 18)
			temp.Put("PUFF", 19)
			temp.Put("SECOND/OHM", 20)
			temp.Put("STATFARAD", 21)
			temp.Put("TERAFARAD", 22)
			PutValues(temp, Array As Float(1e9,1,0.01,1,0.1,10,1e9,1.11265e-12,1,1.11265e-12,1e9,100,1/9e+8,1000,1000000,0.000001,0.001,1e-9,1e-12,1e-12,1,1.11265e-12,1e12,0.99951))
			
		Case 10, "COMPUTER MEMORY"
			temp.Put("BYTE",		1)
			temp.Put("KILOBYTE",	1024)
			temp.Put("MEGABYTE",	Power(1024,2))
			temp.Put("GIGABYTE",	Power(1024,3))
			temp.Put("TERABYTE",	Power(1024,4))
			temp.Put("PETABYTE",	Power(1024,5))
			temp.Put("EXABYTE",		Power(1024,6))
			temp.Put("ZETTABYTE",	Power(1024,7))
			temp.Put("YOTTTABYTE",	Power(1024,8))
			
			temp.Put("BIT",			0.125)
			temp.Put("KILOBIT",		temp.GetValueAt(1)*0.125)
			temp.Put("MEGABIT",		temp.GetValueAt(2)*0.125)
			temp.Put("GIGABIT",		temp.GetValueAt(3)*0.125)
			temp.Put("TERABIT",		temp.GetValueAt(4)*0.125)
			temp.Put("PETABIT",		temp.GetValueAt(5)*0.125)
			temp.Put("EXABIT",		temp.GetValueAt(6)*0.125)
			temp.Put("ZETTABIT",	temp.GetValueAt(7)*0.125)
			temp.Put("YOTTTABIT",	temp.GetValueAt(8)*0.125)
		
		Case 11, "DENSITY"
			temp.Put("GRAIN/CUBIC FOOT", ((0.45359237/16)*(192/175)/480)/((0.0037854118/231)*1728))
			temp.Put("GRAIN/CUBIC INCH", ((0.45359237/16)*(192/175)/480)/(0.0037854118/231))
			temp.Put("GRAIN/GALLON (UK)", ((0.45359237/16)*(192/175)/480)/0.00454609)
			temp.Put("GRAIN/GALLON (US)", ((0.45359237/16)*(192/175)/480)/0.0037854118)
			temp.Put("GRAIN/OUNCE (UK)", ((0.45359237/16)*(192/175)/480)/(0.00454609/160))
			temp.Put("GRAIN/OUNCE (US)", ((0.45359237/16)*(192/175)/480)/(0.0037854118/128))
			temp.Put("GRAIN/QUART (UK)", ((0.45359237/16)*(192/175)/480)/(0.00454609/4))
			temp.Put("GRAIN/QUART (US)", ((0.45359237/16)*(192/175)/480)/(0.0037854118/4))
			temp.Put("GRAM/CUBIC CENTIMETER", 0.001/0.000001)
			temp.Put("GRAM/CUBIC KILOMETER", 0.001/1.0E+9)
			temp.Put("GRAM/CUBIC METER", 0.001/1)
			temp.Put("GRAM/CUBIC MILLIMETER", 0.001/1.0E-9)
			temp.Put("GRAM/KILOLITER", 0.001/1)
			temp.Put("GRAM/LITER", 0.001/0.001)
			temp.Put("GRAM/MICROLITER", 0.001/1.0E-9)
			temp.Put("GRAM/MILLILITER", 0.001/0.000001)
			temp.Put("HECTOGRAM/CUBIC CENTIMETER", 0.1/0.000001)
			temp.Put("HECTOGRAM/CUBIC KILOMETER", 0.1/1.0E+9)
			temp.Put("HECTOGRAM/CUBIC METER", 0.1/1)
			temp.Put("HECTOGRAM/CUBIC MICROMETER", 0.1/1.0E-18)
			temp.Put("HECTOGRAM/CUBIC MILLIMETER", 0.1/1.0E-9)
			temp.Put("HECTOGRAM/HECTOLITER", 0.1/0.1)
			temp.Put("HECTOGRAM/KILOLITER", 0.1/1)
			temp.Put("HECTOGRAM/LITER", 0.1/0.001)
			temp.Put("HECTOGRAM/MICROLITER", 0.1/1.0E-9)
			temp.Put("HECTOGRAM/MILLILITER", 0.1/0.000001)
			temp.Put("KILOGRAM/CUBIC CENTIMETER", 1/0.000001)
			temp.Put("KILOGRAM/CUBIC KILOMETER", 1/1.0E+9)
			temp.Put("KILOGRAM/CUBIC METER", 1/1)
			temp.Put("KILOGRAM/CUBIC MICROMETER", 1/1.0E-18)
			temp.Put("KILOGRAM/CUBIC MILLIMETER", 1/1.0E-9)
			temp.Put("KILOGRAM/KILOLITER", 1/1)
			temp.Put("KILOGRAM/LITER", 1/0.001)
			temp.Put("KILOGRAM/MICROLITER", 1/1.0E-9)
			temp.Put("KILOGRAM/MILLILITER", 1/0.000001)
			temp.Put("KILOTON/CUBIC MILE (UK)", ((0.45359237*2240)*1000)/(((0.0037854118/231)*1728*27)*5451776000))
			temp.Put("KILOTON/CUBIC MILE (US)", ((0.45359237*2000)*1000)/(((0.0037854118/231)*1728*27)*5451776000))
			temp.Put("KILOTON/CUBIC YARD (UK)", ((0.45359237*2240)*1000)/((0.0037854118/231)*1728*27))
			temp.Put("KILOTON/CUBIC YARD (US)", ((0.45359237*2000)*1000)/((0.0037854118/231)*1728*27))
			temp.Put("KILOTONNE/CUBIC KILOMETER", 1000000/1.0E+9)
			temp.Put("KILOTONNE/CUBIC METER", 1000000/1)
			temp.Put("KILOTONNE/KILOLITER", 1000000/1)
			temp.Put("KILOTONNE/LITER", 1000000/0.001)
			temp.Put("MICROGRAM/CUBIC CENTIMETER", 1.0E-9/0.000001)
			temp.Put("MICROGRAM/CUBIC KILOMETER", 1.0E-9/1.0E+9)
			temp.Put("MICROGRAM/CUBIC METER", 1.0E-9/1)
			temp.Put("MICROGRAM/CUBIC MICROMETER", 1.0E-9/1.0E-18)
			temp.Put("MICROGRAM/CUBIC MILLIMETER", 1.0E-9/1.0E-9)
			temp.Put("MICROGRAM/CUBIC NANOMETER", 1.0E-9/1E-27)
			temp.Put("MICROGRAM/KILOLITER", 1.0E-9/1)
			temp.Put("MICROGRAM/LITER", 1.0E-9/0.001)
			temp.Put("MICROGRAM/MICROLITER", 1.0E-9/1.0E-9)
			temp.Put("MICROGRAM/MILLILITER", 1.0E-9/0.000001)
			temp.Put("MILLIGRAM/CUBIC CENTIMETER", 0.000001/0.000001)
			temp.Put("MILLIGRAM/CUBIC KILOMETER", 0.000001/1.0E+9)
			temp.Put("MILLIGRAM/CUBIC METER", 0.000001/1)
			temp.Put("MILLIGRAM/CUBIC MILLIMETER", 0.000001/1.0E-9)
			temp.Put("MILLIGRAM/KILOLITER", 0.000001/1)
			temp.Put("MILLIGRAM/LITER", 0.000001/0.001)
			temp.Put("MILLIGRAM/MICROLITER", 0.000001/1.0E-9)
			temp.Put("MILLIGRAM/MILLILITER", 0.000001/0.000001)
			temp.Put("NANOGRAM/CUBIC CENTIMETER", 1.0E-12/0.000001)
			temp.Put("NANOGRAM/CUBIC KILOMETER", 1.0E-12/1.0E+9)
			temp.Put("NANOGRAM/CUBIC METER", 1.0E-12/1)
			temp.Put("NANOGRAM/CUBIC MILLIMETER", 1.0E-12/1.0E-9)
			temp.Put("NANOGRAM/KILOLITER", 1.0E-12/1)
			temp.Put("NANOGRAM/LITER", 1.0E-12/0.001)
			temp.Put("NANOGRAM/MICROLITER", 1.0E-12/1.0E-9)
			temp.Put("NANOGRAM/MILLILITER", 1.0E-12/0.000001)
			temp.Put("OUNCE/CUBIC FOOT", (0.45359237/16)/((0.0037854118/231)*1728))
			temp.Put("OUNCE/CUBIC INCH", (0.45359237/16)/(0.0037854118/231))
			temp.Put("OUNCE/GALLON (UK)", (0.45359237/16)/0.00454609)
			temp.Put("OUNCE/GALLON (US)", (0.45359237/16)/0.0037854118)
			temp.Put("POUND/CUBIC FOOT", 0.45359237/((0.0037854118/231)*1728))
			temp.Put("POUND/CUBIC INCH", 0.45359237/(0.0037854118/231))
			temp.Put("POUND/CUBIC MILE", 0.45359237/(((0.0037854118/231)*1728*27)*5451776000))
			temp.Put("POUND/CUBIC YARD", 0.45359237/((0.0037854118/231)*1728*27))
			temp.Put("POUND/GALLON (UK)", 0.45359237/0.00454609)
			temp.Put("POUND/GALLON (US)", 0.45359237/0.0037854118)
			temp.Put("TONNE/CUBIC KILOMETER", 1000/1.0E+9)
			temp.Put("TONNE/CUBIC METER", 1000/1)
			temp.Put("TONNE/KILOLITER", 1000/1)
			temp.Put("TONNE/LITER", 1000/0.001)
			temp.Put("WATER (0°C, SOLID)", 915)
			temp.Put("WATER (20°C)", 998.2)
			temp.Put("WATER (4°C)", 1000)
		
		Case 12, "FREQUENCY"
			temp.Put("CYCLE/SECOND", 1)
			temp.Put("DEGREE/HOUR", 1/1296000)
			temp.Put("DEGREE/MINUTE", 1/21600)
			temp.Put("DEGREE/SECOND", 1/360)
			temp.Put("GIGAHERTZ", 1000000000)
			temp.Put("HERTZ", 1)
			temp.Put("KILOHERTZ", 1000)
			temp.Put("MEGAHERTZ", 1000000)
			temp.Put("MILLIHERTZ", 1/1000)
			temp.Put("RADIAN/HOUR", 1/22619.467)
			temp.Put("RADIAN/MINUTE", 1/376.99112)
			temp.Put("RADIAN/SECOND", 1/6.2831853)
			temp.Put("REVOLUTION/HOUR", 1/3600)
			temp.Put("REVOLUTION/MINUTE", 1/60)
			temp.Put("REVOLUTION/SECOND", 1)
			temp.Put("RPM", 1/60)
			temp.Put("TERRAHERTZ", 1000000000000)
		
		Case 13, "ILLUMINANCE"
			temp.Put("FOOTCANDLE", 10.7639104)
			temp.Put("KILOLUX", 1000)
			temp.Put("LUMEN/SQUARE CENTIMETER", 10000)
			temp.Put("LUMEN/SQUARE FOOT", 10.7639104)
			temp.Put("LUMEN/SQUARE INCH", 10.7639104*144)
			temp.Put("LUMEN/SQUARE METER", 1)
			temp.Put("LUX", 1)
			temp.Put("METERCANDLE", 1)
			temp.Put("MILLIPHOT", 10)
			temp.Put("NOX", 0.001)
			temp.Put("PHOT", 10000)
			
		Case 14, "LUMINANCE"	
			temp.Put("APOSTILB", 3183.0989/10000)
			temp.Put("BLONDEL", 3183.0989/10000)
			temp.Put("CANDELA/SQUARE CENTIMETER", 10000)
			temp.Put("CANDELA/SQUARE FOOT", 10.76391)
			temp.Put("CANDELA/SQUARE INCH", 10.76391*144)
			temp.Put("CANDELA/SQUARE METER", 1)
			temp.Put("FOOTLAMBERT", 3.4262591)
			temp.Put("KILOCANDELA/SQUARE CENTIMETER", 10000*1000)
			temp.Put("KILOCANDELA/SQUARE FOOT", 10.76391*1000)
			temp.Put("KILOCANDELA/SQUARE INCH", (10.76391*144)*1000)
			temp.Put("KILOCANDELA/SQUARE METER", 1000)
			temp.Put("LAMBERT", 3183.0989)
			temp.Put("MILLILAMBERT", 3183.0989*0.001)
			temp.Put("NIT", 1)
			temp.Put("STILB", 10000)
		
		Case 15, "POWER"
			temp.Put("ATTOWATT", 1.0e-18)
			temp.Put("BTU/HOUR (I.T.)", 0.29307107)
			temp.Put("BTU/MINUTE (I.T.)", 0.29307107*60)
			temp.Put("BTU/SECOND (I.T.)", 0.29307107*60*60)
			temp.Put("CALORIE/HOUR (I.T.)", 11630 * 1.0e-7)
			temp.Put("CALORIE/MINUTE (I.T.)", 11630 * 60 * 1.0e-7)
			temp.Put("CALORIE/SECOND (I.T.)", 11630 * 60 * 60 *1.0e-7)
			temp.Put("CENTIWATT", 0.01)
			temp.Put("CHEVAL VAPEUR", 9.80665 * 75)
			temp.Put("CLUSEC", 0.0000013332237)
			temp.Put("DECIWATT", 0.1)
			temp.Put("DEKAWATT", 10)
			temp.Put("DYNE CENTIMETER/HOUR", (1.0e-7 / 60) / 60)
			temp.Put("DYNE CENTIMETER/MINUTE", 1.0e-7 / 60)
			temp.Put("DYNE CENTIMETER/SECOND", 1.0e-7)
			temp.Put("ERG/HOUR", (1.0e-7 / 60) / 60)
			temp.Put("ERG/MINUTE", 1.0e-7 / 60)
			temp.Put("ERG/SECOND", 1.0e-7)
			temp.Put("EXAWATT", 1.0e+18)
			temp.Put("FEMTOWATT", 1.0e-15)
			temp.Put("FOOT POUND-FORCE/HOUR", 1.3558179 / 60 / 60)
			temp.Put("FOOT POUND-FORCE/MINUTE", 1.3558179 / 60)
			temp.Put("FOOT POUND-FORCE/SECOND", 1.3558179)
			temp.Put("FOOT POUNDAL/HOUR", 0.04214011 / 60 / 60)
			temp.Put("FOOT POUNDAL/MINUTE", 0.04214011 / 60)
			temp.Put("FOOT POUNDAL/SECOND", 0.04214011)
			temp.Put("GIGAWATT", 1.0e+9)
			temp.Put("GRAM-FORCE CENTIMETER/HOUR", 0.0000980665 / 60 / 60)
			temp.Put("GRAM-FORCE CENTIMETER/MINUTE", 0.0000980665 / 60)
			temp.Put("GRAM-FORCE CENTIMETER/SECOND", 0.0000980665)
			temp.Put("HECTOWATT", 100)
			temp.Put("HORSEPOWER (INTERNATIONAL)", 745.69987)
			temp.Put("HORSEPOWER (ELECTRIC)", 746)
			temp.Put("HORSEPOWER (METRIC)", 9.80665 * 75)
			temp.Put("HORSEPOWER (WATER)", 746.043)
			temp.Put("INCH OUNCE-FORCE REVOLUTION/MINUTE", 0.00073948398)
			temp.Put("JOULE/HOUR", 1 / 60 / 60)
			temp.Put("JOULE/MINUTE", 1 / 60)
			temp.Put("JOULE/SECOND", 1)
			temp.Put("KILOCALORIE/HOUR (I.T.)", 1.163)
			temp.Put("KILOCALORIE/MINUTE (I.T.)", 1.163 * 60)
			temp.Put("KILOCALORIE/SECOND (I.T.)", 1.163 * 60 * 60)
			temp.Put("KILOGRAM-FORCE METER/HOUR", 9.80665 / 60 / 60)
			temp.Put("KILOGRAM-FORCE METER/MINUTE", 9.80665 / 60)
			temp.Put("KILOGRAM-FORCE METER/SECOND", 9.80665)
			temp.Put("KILOPOND METER/HOUR", 9.80665 / 60 / 60)
			temp.Put("KILOPOND METER/MINUTE", 9.80665 / 60)
			temp.Put("KILOPOND METER/SECOND", 9.80665)
			temp.Put("KILOWATT", 1000)
			temp.Put("MEGAWATT", 1000000)
			temp.Put("MICROWATT", 0.000001)
			temp.Put("MILLION BTU/HOUR (I.T.)", 293071.07)
			temp.Put("MILLIWATT", 0.001)
			temp.Put("NANOWATT", 1.0e-9)
			temp.Put("NEWTON METER/HOUR", 1 / 60 / 60)
			temp.Put("NEWTON METER/MINUTE", 1 / 60)
			temp.Put("NEWTON METER/SECOND", 1)
			temp.Put("PETAWATT", 1.0e+15)
			temp.Put("PFERDESTARKE", 9.80665 * 75)
			temp.Put("PICOWATT", 1.0e-12)
			temp.Put("PONCELET", 9.80665 * 100)
			temp.Put("POUND SQUARE FOOT/CUBIC SECOND", 0.04214011)
			temp.Put("TERAWATT", 1.0e+12)
			temp.Put("TON OF REFRIGERATION", 0.012 * 293071.07)
			temp.Put("WATT", 1)
			temp.Put("YOCTOWATT", 1.0e-24)
			temp.Put("YOTTAWATT", 1.0e+24)
			temp.Put("ZEPTOWATT", 1.0e-21)
			temp.Put("ZETTAWATT", 1.0e+21)
		
		Case 16, "PRESSURE"
			temp.Put("ATMOSPHERE (STANDARD)", 101325.01)
			temp.Put("ATMOSPHERE (TECHNICAL)", 98066.5)
			temp.Put("ATTOBAR", 1.0e-13)
			temp.Put("ATTOPASCAL", 1.0e-18)
			temp.Put("BAR", 100000)
			temp.Put("BARAD", 0.1)
			temp.Put("BARYE", 0.1)
			temp.Put("CENTIBAR", 1000)
			temp.Put("CENTIHG", 1333.2239)
			temp.Put("CENTIMETER OF MERCURY (0 °C)", 1333.2239)
			temp.Put("CENTIMETER OF WATER (4 °C)", 98.0665)
			temp.Put("CENTIPASCAL", 0.01)
			temp.Put("CENTITORR", 1.3332237)
			temp.Put("DECIBAR", 10000)
			temp.Put("DECIPASCAL", 0.1)
			temp.Put("DECITORR", 13.332237)
			temp.Put("DEKABAR", 1000000)
			temp.Put("DEKAPASCAL", 10)
			temp.Put("DYNE/SQUARE CENTIMETER", 0.1)
			temp.Put("EXABAR", 1.0e+23)
			temp.Put("EXAPASCAL", 1.0e+18)
			temp.Put("FEMTOBAR", 1.0e-10)
			temp.Put("FEMTOPASCAL", 1.0e-15)
			temp.Put("FOOT OF AIR (0 °C)", 3.8640888)
			temp.Put("FOOT OF AIR (15 °C)", 3.6622931)
			temp.Put("FOOT OF HEAD", 2989.0669)
			temp.Put("FOOT OF MERCURY (0 °C)", 40636.664)
			temp.Put("FOOT OF WATER (4 °C)", 2989.0669)
			temp.Put("GIGABAR", 1.0e+14)
			temp.Put("GIGAPASCAL", 1.0e+9)
			temp.Put("GRAM-FORCE/SQUARE CENTIMETER", 98.0665)
			temp.Put("HECTOBAR", 1.0e+7)
			temp.Put("HECTOPASCAL", 100)
			temp.Put("INCH OF AIR (0 °C)", 3.8640888/12)
			temp.Put("INCH OF AIR (15 °C)", 3.6622931/12)
			temp.Put("INCH OF MERCURY (0 °C)", 40636.664/12)
			temp.Put("INCH OF WATER (4 °C)", 2989.0669/12)
			temp.Put("KILOBAR", 1.0e+8)
			temp.Put("KILOGRAM-FORCE/SQUARE CENTIMETER", 98066.5)
			temp.Put("KILOGRAM-FORCE/SQUARE METER", 9.80665)
			temp.Put("KILOGRAM-FORCE/SQUARE MILLIMETER", 9806650)
			temp.Put("KILONEWTON/SQUARE METER", 1000)
			temp.Put("KILOPASCAL", 1000)
			temp.Put("KILOPOND/SQUARE CENTIMETER", 98066.5)
			temp.Put("KILOPOND/SQUARE METER", 9.80665)
			temp.Put("KILOPOND/SQUARE MILLIMETER", 9806650)
			temp.Put("KIP/SQUARE FOOT", 430.92233*(1/0.009))
			temp.Put("KIP/SQUARE INCH", (430.92233*(1/0.009))*144)
			temp.Put("MEGABAR", 1.0e+11)
			temp.Put("MEGANEWTON/SQUARE METER", 1000000)
			temp.Put("MEGAPASCAL", 1000000)
			temp.Put("METER OF AIR (0 °C)", 12.677457)
			temp.Put("METER OF AIR (15 °C)", 12.015397)
			temp.Put("METER OF HEAD", 9804.139432)
			temp.Put("MICROBAR", 0.1)
			temp.Put("MICROMETER OF MERCURY (0 °C)", 0.13332239)
			temp.Put("MICROMETER OF WATER (4 °C)", 0.00980665)
			temp.Put("MICRON OF MERCURY (0 °C)", 0.13332239)
			temp.Put("MICROPASCAL", 0.000001)
			temp.Put("MILLIBAR", 100)
			temp.Put("MILLIHG", 133.32239)
			temp.Put("MILLIMETER OF MERCURY (0 °C)", 133.32239)
			temp.Put("MILLIMETER OF WATER (4 °C)", 9.80665)
			temp.Put("MILLIPASCAL", 0.001)
			temp.Put("MILLITORR", 0.13332237)
			temp.Put("NANOBAR", 0.0001)
			temp.Put("NANOPASCAL", 1.0e-9)
			temp.Put("NEWTON/SQUARE METER", 1)
			temp.Put("NEWTON/SQUARE MILLIMETER", 1000000)
			temp.Put("OUNCE/SQUARE INCH", 430.92233)
			temp.Put("PASCAL", 1)
			temp.Put("PETABAR", 1.0e+20)
			temp.Put("PETAPASCAL", 1.0e+15)
			temp.Put("PICOBAR", 0.0000001)
			temp.Put("PICOPASCAL", 1.0e-12)
			temp.Put("PIEZE", 1000)
			temp.Put("POUND/SQUARE FOOT", 430.92233/9)
			temp.Put("POUND/SQUARE INCH", 430.92233*16)
			temp.Put("POUNDAL/SQUARE FOOT", 1.4881639)
			temp.Put("STHENE/SQUARE METER", 1000)
			temp.Put("TECHNICAL ATMOSPHERE", 98066.5)
			temp.Put("TERABAR", 1.0e+17)
			temp.Put("TERAPASCAL", 1.0e+12)
			temp.Put("TON/SQUARE FOOT (LONG)", 430.92233*(248 + (1/1.125)))
			temp.Put("TON/SQUARE FOOT (SHORT)", 430.92233*(1/0.0045))
			temp.Put("TON/SQUARE INCH (LONG)", (430.92233*(248 + (1/1.125)))*144)
			temp.Put("TON/SQUARE INCH (SHORT)", (430.92233*(1/0.0045))*144)
			temp.Put("TON/SQUARE METER", 9806.65)
			temp.Put("TORR", 133.32237)
			temp.Put("WATER COLUMN (CENTIMETER)", 98.0665)
			temp.Put("WATER COLUMN (INCH)", 2989.0669/12)
			temp.Put("WATER COLUMN (MILLIMETER)", 9.80665)
			temp.Put("YOCTOBAR", 1.0e-19)
			temp.Put("YOCTOPASCAL", 1.0e-24)
			temp.Put("YOTTABAR", 1.0e+29)
			temp.Put("YOTTAPASCAL", 1.0e+24)
			temp.Put("ZEPTOBAR", 1.0e-16)
			temp.Put("ZEPTOPASCAL", 1.0e-21)
			temp.Put("ZETTABAR", 1.0e+26)
			temp.Put("ZETTAPASCAL", 1.0e+21)
		
		Case 17, "SPEED"
			temp.Put("BENZ", 1)
			temp.Put("CENTIMETER/DAY", 0.01/86400)
			temp.Put("CENTIMETER/HOUR", 0.01/3600)
			temp.Put("CENTIMETER/MINUTE", 0.01/60)
			temp.Put("CENTIMETER/SECOND", 0.01)
			temp.Put("DEKAMETER/DAY", 10/86400)
			temp.Put("DEKAMETER/HOUR", 10/3600)
			temp.Put("DEKAMETER/MINUTE", 10/60)
			temp.Put("DEKAMETER/SECOND", 10)
			temp.Put("FOOT/DAY", 0.3048/86400)
			temp.Put("FOOT/HOUR", 0.3048/3600)
			temp.Put("FOOT/MINUTE", 0.3048/60)
			temp.Put("FOOT/SECOND", 0.3048)
			temp.Put("FURLONG/DAY (SURVEY)", 201.1684/86400)
			temp.Put("FURLONG/FORTNIGHT (SURVEY)", 201.1684/1209600)
			temp.Put("FURLONG/HOUR (SURVEY)", 201.1684/3600)
			temp.Put("FURLONG/MINUTE (SURVEY)", 201.1684/60)
			temp.Put("FURLONG/SECOND (SURVEY)", 201.1684)
			temp.Put("HECTOMETER/DAY", 100/86400)
			temp.Put("HECTOMETER/HOUR", 100/3600)
			temp.Put("HECTOMETER/MINUTE", 100/60)
			temp.Put("HECTOMETER/SECOND", 100)
			temp.Put("INCH/DAY", (0.3048/12)/86400)
			temp.Put("INCH/HOUR", (0.3048/12)/3600)
			temp.Put("INCH/MINUTE", (0.3048/12)/60)
			temp.Put("INCH/SECOND", 0.3048/12)
			temp.Put("KILOMETER/DAY", 1000/86400)
			temp.Put("KILOMETER/HOUR", 1000/3600)
			temp.Put("KILOMETER/MINUTE", 1000/60)
			temp.Put("KILOMETER/SECOND", 1000)
			temp.Put("KNOT", 1852/3600)
			temp.Put("LEAGUE/DAY (STATUTE)", 4828.0417/86400)
			temp.Put("LEAGUE/HOUR (STATUTE)", 4828.0417/3600)
			temp.Put("LEAGUE/MINUTE (STATUTE)", 4828.0417/60)
			temp.Put("LEAGUE/SECOND (STATUTE)", 4828.0417)
			temp.Put("MACH", 340.29)
			temp.Put("MEGAMETER/DAY", 1000000/86400)
			temp.Put("MEGAMETER/HOUR", 1000000/3600)
			temp.Put("MEGAMETER/MINUTE", 1000000/60)
			temp.Put("MEGAMETER/SECOND", 1000000)
			temp.Put("METER/DAY", 1/86400)
			temp.Put("METER/HOUR", 1/3600)
			temp.Put("METER/MINUTE", 1/60)
			temp.Put("METER/SECOND", 1)
			temp.Put("MILE/DAY", (0.3048*5280)/86400)
			temp.Put("MILE/HOUR", (0.3048*5280)/3600)
			temp.Put("MILE/MINUTE", (0.3048*5280)/60)
			temp.Put("MILE/SECOND", 0.3048*5280)
			temp.Put("MILLIMETER/DAY", 0.001/86400)
			temp.Put("MILLIMETER/HOUR", 0.001/3600)
			temp.Put("MILLIMETER/MINUTE", 0.001/60)
			temp.Put("MILLIMETER/SECOND", 0.001)
			temp.Put("MILLIMETER/MICROSECOND", 1000)
			temp.Put("MILLIMETER/100 MICROSECOND", 10)
			temp.Put("NAUTICAL MILE/DAY", 1852/86400)
			temp.Put("NAUTICAL MILE/HOUR", 1852/3600)
			temp.Put("NAUTICAL MILE/MINUTE", 1852/60)
			temp.Put("NAUTICAL MILE/SECOND", 1852)
			temp.Put("SPEED OF LIGHT (AIR)", 299702547)
			temp.Put("SPEED OF LIGHT (GLASS)", 199861638)
			temp.Put("SPEED OF LIGHT (ICE)", 228849204)
			temp.Put("SPEED OF LIGHT (VACUUM)", 299792458)
			temp.Put("SPEED OF LIGHT (WATER)", 225407863)
			temp.Put("SPEED OF SOUND (AIR)", 340.29)
			temp.Put("SPEED OF SOUND (METAL)", 5000)
			temp.Put("SPEED OF SOUND (WATER)", 1500)
			temp.Put("YARD/DAY", (0.3048*3)/86400)
			temp.Put("YARD/HOUR", (0.3048*3)/3600)
			temp.Put("YARD/MINUTE", (0.3048*3)/60)
			temp.Put("YARD/SECOND", 0.3048*3)
			
			temp.Put("WARP (TOS)", -1) 
			temp.Put("WARP (TNG)", -2)
			'temp.Put("WARP (AGT)", -3)
	
		Case 18, "TORQUE"
			temp.Put("DYNE CENTIMETER", 0.0000001)
			temp.Put("GRAM CENTIMETER", 9.80665/100000)
			temp.Put("KILOGRAM CENTIMETER", 9.80665/100)
			temp.Put("KILOGRAM METER", 9.80665)
			temp.Put("KILONEWTON METER", 1000)
			temp.Put("KILOPOND METER", 9.80665)
			temp.Put("MEGANEWTON METER", 1000000)
			temp.Put("MICRONEWTON METER", 0.000001)
			temp.Put("MILLINEWTON METER", 0.001)
			temp.Put("NEWTON CENTIMETER", 0.01)
			temp.Put("NEWTON METER", 1)
			temp.Put("OUNCE FOOT", 0.084738622)
			temp.Put("OUNCE INCH", 0.084738622/12)
			temp.Put("POUND FOOT", 0.084738622*16)
			temp.Put("POUNDAL FOOT", 0.0421401099752144)
			temp.Put("POUND INCH", 0.084738622/12*16)
		
		Case 19, "VOLUME"
			temp.Put("ACRE FOOT", 0.028316847*43560)
			temp.Put("ACRE FOOT (US SURVEY)", 1233.489)
			temp.Put("ACRE INCH", 0.028316847*3630)
			temp.Put("BARREL (UK, WINE)", 0.00454609*31.5)
			temp.Put("BARREL (UK)", 0.00454609*36)
			temp.Put("BARREL (US, DRY)", (0.003785411784/231)*7056)
			temp.Put("BARREL (US, FEDERAL)", 0.003785411784*31)
			temp.Put("BARREL (US, LIQUID)", 0.003785411784*31.5)
			temp.Put("BARREL (US, PETROLEUM)", 0.003785411784*42)
			temp.Put("BOARD FOOT", ((0.003785411784/231)*1728)/12)
			temp.Put("BUCKET (UK)", 0.00454609*4)
			temp.Put("BUCKET (US)", 0.003785411784*5)
			temp.Put("BUSHEL (UK)", 0.00454609*8)
			temp.Put("BUSHEL (US, DRY)", 0.0044048838*8)
			temp.Put("CENTILITER", 0.00001)
			temp.Put("CORD (FIREWOOD)", 0.028316847*128)
			temp.Put("CORD FOOT (TIMBER)", 0.028316847*16)
			temp.Put("CUBIC CENTIMETER", 0.000001)
			temp.Put("CUBIC CUBIT (ANCIENT EGYPT)", 0.144)
			temp.Put("CUBIC DECIMETER", 0.001)
			temp.Put("CUBIC DEKAMETER", 1000)
			temp.Put("CUBIC FOOT", (0.003785411784/231)*1728)
			temp.Put("CUBIC INCH", 0.003785411784/231)
			temp.Put("CUBIC KILOMETER", 1.0e+9)
			temp.Put("CUBIC METER", 1)
			temp.Put("CUBIC MILE", (((0.003785411784/231)*1728)*43560)*3379200)
			temp.Put("CUBIC MICROMETER", 1.0e-18)
			temp.Put("CUBIC MILLIMETER", 1.0e-9)
			temp.Put("CUBIC YARD", ((0.003785411784/231)*1728)*27)
			temp.Put("CUP (CANADA)", 0.00454609*0.05)
			temp.Put("CUP (METRIC)", 0.00025)
			temp.Put("CUP (US)", 0.003785411784/16)
			temp.Put("DECILITER", 0.0001)
			temp.Put("DEKALITER", 0.01)
			temp.Put("DRAM", (0.003785411784/128)/8)
			temp.Put("DRUM (US, PETROLEUM)", 0.003785411784*55)
			temp.Put("DRUM (METRIC, PETROLEUM)", 0.001*200)
			temp.Put("FIFTH", 0.003785411784/5)
			temp.Put("GALLON (UK)", 0.00454609)
			temp.Put("GALLON (US, DRY)", 0.0044048838)
			temp.Put("GALLON (US, LIQUID)", 0.003785411784)
			temp.Put("GILL (UK)", 0.00454609/32)
			temp.Put("GILL (US)", 0.003785411784/32)
			temp.Put("HECTARE METER", 10000)
			temp.Put("HECTOLITER", 0.1)
			temp.Put("HOGSHEAD (UK)", 0.00454609*63)
			temp.Put("HOGSHEAD (US)", 0.003785411784*63)
			temp.Put("IMPERIAL GALLON", 0.00454609)
			temp.Put("JIGGER", (0.003785411784/128)*1.5)
			temp.Put("KILOLITER", 1)
			temp.Put("LITER", 0.001)
			temp.Put("MEASURE (ANCIENT HEBREW)", 0.0077)
			temp.Put("MEGALITER", 1000)
			temp.Put("MICROLITER", 1.0e-9)
			temp.Put("MILLILITER", 0.000001)
			temp.Put("MINIM (UK)", (0.00454609/160)/480)
			temp.Put("MINIM (US)", (0.003785411784/128)/480)
			temp.Put("OUNCE (UK, LIQUID)", 0.00454609/160)
			temp.Put("OUNCE (US, LIQUID)", 0.003785411784/128)
			temp.Put("PECK (UK)", 0.00454609*2)
			temp.Put("PECK (US)", 0.0044048838*2)
			temp.Put("PINT (UK)", 0.00454609/8)
			temp.Put("PINT (US, DRY)", 0.0044048838/8)
			temp.Put("PINT (US, LIQUID)", 0.003785411784/8)
			temp.Put("PIPE (UK)", 0.00454609*108)
			temp.Put("PIPE (US)", 0.003785411784*126)
			temp.Put("PONY", 0.003785411784/128)
			temp.Put("QUART (GERMANY)", 0.00114504)
			temp.Put("QUART (ANCIENT HEBREW)", 0.00108)
			temp.Put("QUART (UK)", 0.00454609/4)
			temp.Put("QUART (US, DRY)", 0.0044048838/4)
			temp.Put("QUART (US, LIQUID)", 0.003785411784/4)
			temp.Put("QUARTER (UK, LIQUID)", 0.00454609*64)
			temp.Put("ROBIE", 0.00001)
			temp.Put("SHOT", 0.003785411784/128)
			temp.Put("STERE", 1)
			temp.Put("TABLESPOON (METRIC)", 0.000015)
			temp.Put("TABLESPOON (UK)", (0.00454609/160)/2)
			temp.Put("TABLESPOON (US)", (0.003785411784/128)/2)
			temp.Put("TEASPOON (METRIC)", 0.000005)
			temp.Put("TEASPOON (UK)", (0.00454609/160)/8)
			temp.Put("TEASPOON (US)", (0.003785411784/128)/6)
			temp.Put("YARD", ((0.003785411784/231)*1728)*27)
		
		Case 20, "FLOW RATE (MASS)"
			temp.Put("CENTIGRAM/DAY", 0.00001/60/60/24)
			temp.Put("CENTIGRAM/HOUR", 0.00001/60/60)
			temp.Put("CENTIGRAM/MINUTE", 0.00001/60)
			temp.Put("CENTIGRAM/SECOND", 0.00001)
			temp.Put("GRAM/DAY", 0.001/60/60/24)
			temp.Put("GRAM/HOUR", 0.001/60/60)
			temp.Put("GRAM/MINUTE", 0.001/60)
			temp.Put("GRAM/SECOND", 0.001)
			temp.Put("KILOGRAM/DAY", 1/60/60/24)
			temp.Put("KILOGRAM/HOUR", 1/60/60)
			temp.Put("KILOGRAM/MINUTE", 1/60)
			temp.Put("KILOGRAM/SECOND", 1)
			temp.Put("MILLIGRAM/DAY", 0.000001/60/60/24)
			temp.Put("MILLIGRAM/HOUR", 0.000001/60/60)
			temp.Put("MILLIGRAM/MINUTE", 0.000001/60)
			temp.Put("MILLIGRAM/SECOND", 0.000001)
			temp.Put("OUNCE/DAY", 0.0283495/60/60/24)
			temp.Put("OUNCE/HOUR", 0.0283495/60/60)
			temp.Put("OUNCE/MINUTE", 0.0283495/60)
			temp.Put("OUNCE/SECOND", 0.0283495)
			temp.Put("POUND/DAY", (0.0283495*16)/60/60/24)
			temp.Put("POUND/HOUR", (0.0283495*16)/60/60)
			temp.Put("POUND/MINUTE", (0.0283495*16)/60)
			temp.Put("POUND/SECOND", 0.0283495*16)
			temp.Put("TON/DAY (LONG)", (0.0283495*16*2240)/60/60/24)
			temp.Put("TON/DAY (METRIC)", 1000/60/60/24)
			temp.Put("TON/DAY (SHORT)", (0.0283495*16*2000)/60/60/24)
			temp.Put("TON/HOUR (LONG)", (0.0283495*16*2240)/60/60)
			temp.Put("TON/HOUR (METRIC)", 1000/60/60)
			temp.Put("TON/HOUR (SHORT)", (0.0283495*16*2000)/60/60)
			temp.Put("TON/MINUTE (LONG)", (0.0283495*16*2240)/60)
			temp.Put("TON/MINUTE (METRIC)", 1000/60)
			temp.Put("TON/MINUTE (SHORT)", (0.0283495*16*2000)/60)
			temp.Put("TON/SECOND (LONG)", 0.0283495*16*2240)
			temp.Put("TON/SECOND (METRIC)", 1000)
			temp.Put("TON/SECOND (SHORT)", 0.0283495*16*2000)
			
		Case 21, "FLOW RATE (VOLUME)"
			temp.Put("ACRE FOOT/DAY", 1233.48184/60/60/24)
			temp.Put("ACRE FOOT/HOUR", 1233.48184/60/60)
			temp.Put("ACRE FOOT/MINUTE", 1233.48184/60)
			temp.Put("ACRE FOOT/SECOND", 1233.48184)
			temp.Put("ACRE FOOT/DAY (SURVEY)", 1233.48924/60/60/24)
			temp.Put("ACRE FOOT/HOUR (SURVEY)", 1233.48924/60/60)
			temp.Put("ACRE FOOT/MINUTE (SURVEY)", 1233.48924/60)
			temp.Put("ACRE FOOT/SECOND (SURVEY)", 1233.48924)
			temp.Put("ACRE INCH/DAY", (1233.48184/12)/60/60/24)
			temp.Put("ACRE INCH/HOUR", (1233.48184/12)/60/60)
			temp.Put("ACRE INCH/MINUTE", (1233.48184/12)/60)
			temp.Put("ACRE INCH/SECOND", 1233.48184/12)
			temp.Put("ACRE INCH/DAY (SURVEY)", (1233.48924/12)/60/60/24)
			temp.Put("ACRE INCH/HOUR (SURVEY)", (1233.48924/12)/60/60)
			temp.Put("ACRE INCH/MINUTE (SURVEY)", (1233.48924/12)/60)
			temp.Put("ACRE INCH/SECOND (SURVEY)", 1233.48924/12)
			temp.Put("BARREL/DAY (PETROLEUM)", (0.003785411784/60/60/24)*42)
			temp.Put("BARREL/HOUR (PETROLEUM)", (0.003785411784/60/60)*42)
			temp.Put("BARREL/MINUTE (PETROLEUM)", (0.003785411784/60)*42)
			temp.Put("BARREL/SECOND (PETROLEUM)", 0.003785411784*42)
			temp.Put("BARREL/DAY (UK)", (0.00454609/60/60/24)*36)
			temp.Put("BARREL/HOUR (UK)", (0.00454609/60/60)*36)
			temp.Put("BARREL/MINUTE (UK)", (0.00454609/60)*36)
			temp.Put("BARREL/SECOND (UK)", 0.00454609*36)
			temp.Put("BARREL/DAY (US)", (0.003785411784/60/60/24)*31.5)
			temp.Put("BARREL/HOUR (US)", (0.003785411784/60/60)*31.5)
			temp.Put("BARREL/MINUTE (US)", (0.003785411784/60)*31.5)
			temp.Put("BARREL/SECOND (US)", 0.003785411784*31.5)
			temp.Put("BARREL/DAY (US BEER/WINE)", (0.003785411784/60/60/24)*31)
			temp.Put("BARREL/HOUR (US BEER/WINE)", (0.003785411784/60/60)*31)
			temp.Put("BARREL/MINUTE (US BEER/WINE)", (0.003785411784/60)*31)
			temp.Put("BARREL/SECOND (US BEER/WINE)", 0.003785411784*31)
			temp.Put("BILLION CUBIC FOOT/DAY", 28316847/60/60/24)
			temp.Put("BILLION CUBIC FOOT/HOUR", 28316847/60/60)
			temp.Put("BILLION CUBIC FOOT/MINUTE", 28316847/60)
			temp.Put("BILLION CUBIC FOOT/SECOND", 28316847)
			temp.Put("CENTILITER/DAY", 0.00001/60/60/24)
			temp.Put("CENTILITER/HOUR", 0.00001/60/60)
			temp.Put("CENTILITER/MINUTE", 0.00001/60)
			temp.Put("CENTILITER/SECOND", 0.00001)
			temp.Put("CUBEM/DAY", 4168181830/60/60/24)
			temp.Put("CUBEM/HOUR", 4168181830/60/60)
			temp.Put("CUBEM/MINUTE", 4168181830/60)
			temp.Put("CUBEM/SECOND", 4168181830)
			temp.Put("CUBIC CENTIMETER/DAY", 0.000001/60/60/24)
			temp.Put("CUBIC CENTIMETER/HOUR", 0.000001/60/60)
			temp.Put("CUBIC CENTIMETER/MINUTE", 0.000001/60)
			temp.Put("CUBIC CENTIMETER/SECOND", 0.000001)
			temp.Put("CUBIC DECIMETER/DAY", 0.001/60/60/24)
			temp.Put("CUBIC DECIMETER/HOUR", 0.001/60/60)
			temp.Put("CUBIC DECIMETER/MINUTE", 0.001/60)
			temp.Put("CUBIC DECIMETER/SECOND", 0.001)
			temp.Put("CUBIC DEKAMETER/DAY", 1000/60/60/24)
			temp.Put("CUBIC DEKAMETER/HOUR", 1000/60/60)
			temp.Put("CUBIC DEKAMETER/MINUTE", 1000/60)
			temp.Put("CUBIC DEKAMETER/SECOND", 1000)
			temp.Put("CUBIC FOOT/DAY", 0.028316847/60/60/24)
			temp.Put("CUBIC FOOT/HOUR", 0.028316847/60/60)
			temp.Put("CUBIC FOOT/MINUTE", 0.028316847/60)
			temp.Put("CUBIC FOOT/SECOND", 0.028316847)
			temp.Put("CUBIC INCH/DAY", 0.028316847/1728/60/60/24)
			temp.Put("CUBIC INCH/HOUR", 0.028316847/1728/60/60)
			temp.Put("CUBIC INCH/MINUTE", 0.028316847/1728/60)
			temp.Put("CUBIC INCH/SECOND", 0.028316847/1728)
			temp.Put("CUBIC KILOMETER/DAY", 1000000000/60/60/24)
			temp.Put("CUBIC KILOMETER/HOUR", 1000000000/60/60)
			temp.Put("CUBIC KILOMETER/MINUTE", 1000000000/60)
			temp.Put("CUBIC KILOMETER/SECOND", 1000000000)
			temp.Put("CUBIC METER/DAY", 1/60/60/24)
			temp.Put("CUBIC METER/HOUR", 1/60/60)
			temp.Put("CUBIC METER/MINUTE", 1/60)
			temp.Put("CUBIC METER/SECOND", 1)
			temp.Put("CUBIC MILE/DAY", 4168181830/60/60/24)
			temp.Put("CUBIC MILE/HOUR", 4168181830/60/60)
			temp.Put("CUBIC MILE/MINUTE", 4168181830/60)
			temp.Put("CUBIC MILE/SECOND", 4168181830)
			temp.Put("CUBIC MILLIMETER/DAY", 0.000000001/60/60/24)
			temp.Put("CUBIC MILLIMETER/HOUR", 0.000000001/60/60)
			temp.Put("CUBIC MILLIMETER/MINUTE", 0.000000001/60)
			temp.Put("CUBIC MILLIMETER/SECOND", 0.000000001)
			temp.Put("CUBIC YARD/DAY", (0.028316847*27)/60/60/24)
			temp.Put("CUBIC YARD/HOUR", (0.028316847*27)/60/60)
			temp.Put("CUBIC YARD/MINUTE", (0.028316847*27)/60)
			temp.Put("CUBIC YARD/SECOND", 0.028316847*27)
			temp.Put("CUSEC", 0.028316847)
			temp.Put("DECILITER/DAY", 0.0001/60/60/24)
			temp.Put("DECILITER/HOUR", 0.0001/60/60)
			temp.Put("DECILITER/MINUTE", 0.0001/60)
			temp.Put("DECILITER/SECOND", 0.0001)
			temp.Put("DEKALITER/DAY", 0.01/60/60/24)
			temp.Put("DEKALITER/HOUR", 0.01/60/60)
			temp.Put("DEKALITER/MINUTE", 0.01/60)
			temp.Put("DEKALITER/SECOND", 0.01)
			temp.Put("GALLON/DAY (UK)", 0.00454609/60/60/24)
			temp.Put("GALLON/HOUR (UK)", 0.00454609/60/60)
			temp.Put("GALLON/MINUTE (UK)", 0.00454609/60)
			temp.Put("GALLON/SECOND (UK)", 0.00454609)
			temp.Put("GALLON/DAY (US)", 0.003785411784/60/60/24)
			temp.Put("GALLON/HOUR (US)", 0.003785411784/60/60)
			temp.Put("GALLON/MINUTE (US)", 0.003785411784/60)
			temp.Put("GALLON/SECOND (US)", 0.003785411784)
			temp.Put("HECTARE METER/DAY", 10000/60/60/24)
			temp.Put("HECTARE METER/HOUR", 10000/60/60)
			temp.Put("HECTARE METER/MINUTE", 10000/60)
			temp.Put("HECTARE METER/SECOND", 10000)
			temp.Put("HECTOLITER/DAY", 0.1/60/60/24)
			temp.Put("HECTOLITER/HOUR", 0.1/60/60)
			temp.Put("HECTOLITER/MINUTE", 0.1/60)
			temp.Put("HECTOLITER/SECOND", 0.1)
			temp.Put("KILOLITER/DAY", 1/60/60/24)
			temp.Put("KILOLITER/HOUR", 1/60/60)
			temp.Put("KILOLITER/MINUTE", 1/60)
			temp.Put("KILOLITER/SECOND", 1)
			temp.Put("LAMBDA/DAY", 0.000000001/60/60/24)
			temp.Put("LAMBDA/HOUR", 0.000000001/60/60)
			temp.Put("LAMBDA/MINUTE", 0.000000001/60)
			temp.Put("LAMBDA/SECOND", 0.000000001)
			temp.Put("LITER/DAY", 0.001/60/60/24)
			temp.Put("LITER/HOUR", 0.001/60/60)
			temp.Put("LITER/MINUTE", 0.001/60)
			temp.Put("LITER/SECOND", 0.001)
			temp.Put("MILLILITER/DAY", 0.000001/60/60/24)
			temp.Put("MILLILITER/HOUR", 0.000001/60/60)
			temp.Put("MILLILITER/MINUTE", 0.000001/60)
			temp.Put("MILLILITER/SECOND", 0.000001)
			temp.Put("MILLION ACRE FOOT/DAY", 1233481840/60/60/24)
			temp.Put("MILLION ACRE FOOT/HOUR", 1233481840/60/60)
			temp.Put("MILLION ACRE FOOT/MINUTE", 1233481840/60)
			temp.Put("MILLION ACRE FOOT/SECOND", 1233481840)
			temp.Put("MILLION CUBIC FOOT/DAY", 28316.847/60/60/24)
			temp.Put("MILLION CUBIC FOOT/HOUR", 28316.847/60/60)
			temp.Put("MILLION CUBIC FOOT/MINUTE", 28316.847/60)
			temp.Put("MILLION CUBIC FOOT/SECOND", 28316.847)
			temp.Put("MILLION GALLON/DAY (UK)", 4546.09/60/60/24)
			temp.Put("MILLION GALLON/HOUR (UK)", 4546.09/60/60)
			temp.Put("MILLION GALLON/MINUTE (UK)", 4546.09/60)
			temp.Put("MILLION GALLON/SECOND (UK)", 4546.09)
			temp.Put("MILLION GALLON/DAY (US)", 3785.4118/60/60/24)
			temp.Put("MILLION GALLON/HOUR (US)", 3785.4118/60/60)
			temp.Put("MILLION GALLON/MINUTE (US)", 3785.4118/60)
			temp.Put("MILLION GALLON/SECOND (US)", 3785.4118)
			temp.Put("MINER'S INCH (AZ, CA, OR) ", 0.028316847/60*1.5)
			temp.Put("MINER'S INCH (CO)", 0.028316847/60*1.5625)
			temp.Put("MINER'S INCH (ID, WA, NM)", 0.003785411784/60*9)
			temp.Put("OUNCE/DAY (UK)", 0.00454609/160/60/60/24)
			temp.Put("OUNCE/HOUR (UK)", 0.00454609/160/60/60)
			temp.Put("OUNCE/MINUTE (UK)", 0.00454609/160/60)
			temp.Put("OUNCE/SECOND (UK)", 0.00454609/160)
			temp.Put("OUNCE/DAY (US)", 0.003785411784/128/60/60/24)
			temp.Put("OUNCE/HOUR (US)", 0.003785411784/128/60/60)
			temp.Put("OUNCE/MINUTE (US)", 0.003785411784/128/60)
			temp.Put("OUNCE/SECOND (US)", 0.003785411784/128)
			temp.Put("PETROGRAD STANDARD/DAY", (0.028316847*165)/60/60/24)
			temp.Put("PETROGRAD STANDARD/HOUR", (0.028316847*165)/60/60)
			temp.Put("PETROGRAD STANDARD/MINUTE", (0.028316847*165)/60)
			temp.Put("PETROGRAD STANDARD/SECOND", 0.028316847*165)
			temp.Put("STERE/DAY", 1/60/60/24)
			temp.Put("STERE/HOUR", 1/60/60)
			temp.Put("STERE/MINUTE", 1/60)
			temp.Put("STERE/SECOND", 1)
			temp.Put("THOUSAND CUBIC FOOT/DAY", 28.316847/60/60/24)
			temp.Put("THOUSAND CUBIC FOOT/HOUR", 28.316847/60/60)
			temp.Put("THOUSAND CUBIC FOOT/MINUTE", 28.316847/60)
			temp.Put("THOUSAND CUBIC FOOT/SECOND", 28.316847)
			temp.Put("TRILLION CUBIC FOOT/DAY", 28316847000/60/60/24)
			temp.Put("TRILLION CUBIC FOOT/HOUR", 28316847000/60/60)
			temp.Put("TRILLION CUBIC FOOT/MINUTE", 28316847000/60)
			temp.Put("TRILLION CUBIC FOOT/SECOND", 28316847000)
			
		Case 22, "FLOW RATE (MOLE)"
			temp.Put("CENTIMOLE/DAY", 0.01/60/60/24)
			temp.Put("CENTIMOLE/HOUR", 0.01/60/60)
			temp.Put("CENTIMOLE/MINUTE", 0.01/60)
			temp.Put("CENTIMOLE/SECOND", 0.01)
			temp.Put("MEGAMOLE/DAY", 1000000/60/60/24)
			temp.Put("MEGAMOLE/HOUR", 1000000/60/60)
			temp.Put("MEGAMOLE/MINUTE", 1000000/60)
			temp.Put("MEGAMOLE/SECOND", 1000000)
			temp.Put("MICROMOLE/DAY", 0.000001/60/60/24)
			temp.Put("MICROMOLE/HOUR", 0.000001/60/60)
			temp.Put("MICROMOLE/MINUTE", 0.000001/60)
			temp.Put("MICROMOLE/SECOND", 0.000001)
			temp.Put("MILLIMOLE/DAY", 0.001/60/60/24)
			temp.Put("MILLIMOLE/HOUR", 0.001/60/60)
			temp.Put("MILLIMOLE/MINUTE", 0.001/60)
			temp.Put("MILLIMOLE/SECOND", 	0.001)
			temp.Put("MOLE/DAY", 			1/60/60/24)
			temp.Put("MOLE/HOUR", 			1/60/60)
			temp.Put("MOLE/MINUTE", 		1/60)
			temp.Put("MOLE/SECOND", 		1)
		
		Case 23, API.getstring("units_23")
			temp.Put("BINARY",			2)
			temp.Put("TERNARY", 		3)
			temp.Put("quaternary",		4)
			temp.Put("quinary",			5)
			temp.Put("senary",			6)
			temp.Put("septenary",		7)
			temp.Put("OCTAL", 			8)
			temp.Put("nonary",			9)
			temp.Put("DECIMAL", 		10)
			temp.Put("undecimal",		11)
			temp.Put("duodecimal",		12)
			temp.Put("tridecimal",		13)
			temp.Put("tetradecimal",	14)
			temp.Put("pentadecimal",	15)
			temp.Put("HEXADECIMAL", 	16)
			temp.Put("octodecimal",		18)
			temp.Put("vigesimal",		20)
			temp.Put("tetravigesimal",	24)
			temp.Put("pentavigesimal",	25)
			temp.Put("hexavigesimal",	26)
			temp.Put("septemvigesimal", 27)
			temp.Put("octovigesimal", 	28)
			temp.Put("trigesimal", 		30)
			temp.Put("duotrigesimal", 	32)
			temp.Put("hexatrigesimal", 	36)
		
		Case 24, "PLANETARY WEIGHT"
			temp.Put("SOL",				27.9)
			temp.Put("MERCURY",			0.38)
			temp.Put("VENUS",			0.91)
			temp.Put("EARTH",			1.00)
			temp.Put("LUNA",			0.17)
			temp.Put("MARS",			0.38)
			temp.Put("JUPITER",			2.54)
			temp.Put("SATURN",			1.08)
			temp.Put("URANUS",			0.91)
			temp.Put("NEPTUNE",			1.19)
			temp.Put("PLUTO",			0.06)
 		
	End Select
	Return temp 
End Sub 
Sub PutValues(tempMap As Map, Values() As Float)
	Dim temp As Int 
	For temp = 0 To tempMap.Size - 1 
		tempMap.Put( tempMap.GetKeyAt(temp), Values( tempMap.GetValueAt(temp) ))
	Next
End Sub
'Ohms law
'P = Power In watts
'P = E2/R
'P = I2 * R
'P = E * I

'E = voltage In volts
'E = Sqrt(P * R)
'E = P/I
'E = I * R

'I = current In amps
'I = E/R
'I = P/E
'I = Sqrt(P/R)

'R = resistance In ohms
'R = E/I
'R = E2/P
'R = P/I2

'any of the letters representing numbers in the Roman numerical system: 
'I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1,000. 
'In this system, a letter placed after another of greater value adds (thus XVI or xvi is 16)
'whereas a letter placed before another of greater value subtracts (thus XC or xc is 90).
