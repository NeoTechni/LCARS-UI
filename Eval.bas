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
	Dim EvalError As String, EvalMoreData As String, OverFlowLimit As Int=128,opchars As String ="+-^&*|/=\!~<>",Delimeter As String ="|", AngleMode As Int=1 ,CurrentLevel As Int, Internals As Boolean ,OptionExplicit As Boolean = True 
	Dim ch_numeric As Int, ch_operand As Int=1, ch_routine As Int=2,ch_delimit As Int=3,ch_leftbrk As Int=4, ch_rigtbrk As Int=5,ch_strings As Int=6,ch_boolean As Int=7,ch_any As Int=8, ch_array As Int=9, ch_custom As Int=10
	Dim vbRadians As Int , vbDegrees As Int =1,vbGradients As Int=2 , TXT As Int=ch_strings,NUM As Int=ch_numeric, BOOL As Int=ch_boolean ,ANY As Int=ch_any, ARR As Int=ch_array, vbQuote As String = Chr(34) ,Empty As String ="", None As String="" 
	
	Type Variable(name As String, varType As Int, Values As List, Scope As Int, isConst As Boolean,MinParams As Int, Equation As String )
	Type Parameter(name As String, varType As Int, Default As String, varTypeS As String  )
	Dim VarList As List, CurrentScope As Int ,VarsLoaded As Boolean ,DoVoice As Boolean, C As Int = 299792458  'meters/second 
	
	'for LCARS UI
	Dim EnumType As Int , VarStack As List, HelpText As String, HelpTopic As String , CurrentVar As Variable, CurrentPar As Parameter, VarIndex As Int =-1,ParIndex As Int ,IsEditing As Boolean
	
	VarStack.Initialize:CurrentVar.Initialize :CurrentPar.Initialize :VarList.Initialize
End Sub


'START LCARS UI SPECIFIC API
Sub EnumStrings(ID As Int) As List
	'Log("ENUMMING ID: " & ID)
	Dim templist As List 
	Select Case ID
		Case -1: Return Array As String("RADIANS", "DEGREES", "GRADIANTS" )
		Case -2: Return Array As String("CONSTANTS", "NUMBERS", "BOOLEANS", "STRINGS", "CUSTOM", "INT. SUBS", "EXT. SUBS")
		Case -3: Return  Array As String("number", "operand", "sub", "delimeter", "left bracket", "right bracket", "text", "boolean", "any", "array", "custom")
		Case -4'available types to edit/credit, so -5 for new, -4 for edit
			templist.Initialize 
			templist.AddAll(EnumStrings(-5))' Array As String("NUMBER", "TEXT", "BOOLEAN"))
			If Not(IsEditing) Then templist.AddAll( Array As String("SUB", "CUSTOM")) 'create only
			'templist.AddAll( EnumStrings(4) )
			Return templist
		Case -5: Return Array As String("NUMBER", "TEXT", "BOOLEAN")
		Case -6: Return Array As String("YES", "NO")
		Case -7: Return Array As String("TRUE", "FALSE")
		Case -8: Return Array As String("SQUARE", "CIRCLE")
		
		Case 0: Return EnumVariables(True, ch_routine,False,0,False,0)'CONSTANTS
		Case 1: Return EnumVariables(False,ch_numeric,True, 0,False,0)'NUMBERS
		Case 2: Return EnumVariables(False,ch_boolean,True, 0,False,0)'BOOLEANS
		Case 3: Return EnumVariables(False,ch_strings,True, 0,False,0)'STRINGS
		Case 4: Return EnumVariables(True, ch_custom, True, 0,False,0)'CUSTOM type definitions
		Case 5: Return EnumVariables(True, ch_routine,True, 0,False,0)'INT. SUBS
		Case 6: Return EnumVariables(False,ch_routine,True, 0,False,0)'EXT. SUBS
		
		Case 7: Return EnumCustomVariables(CurrentVar.Equation, 0,False,0)'variables of a custom type
	End Select
End Sub
Sub MapVariableType(VarType As Int) As Int
	Select Case VarType
		Case ch_numeric: Return 1
		Case ch_boolean: Return 2
		Case ch_strings: Return 3
		Case ch_custom:  Return 4
		Case ch_routine: Return 6
		Case Else: Return 7
	End Select
End Sub
Sub EnumCustomVariables(VarType As String, Scope As Int, FallbacktoZero As Boolean, FallbackScope As Int) As List
	Dim temp As Int, Var As Variable, Vlist As List
	RegisterInternals
	Vlist.Initialize
	For temp = 0 To VarList.Size-1
		Var = VarList.Get(temp)
		If Var.VarType=ch_custom And Not(Var.isConst) Then
			If Var.Equation.EqualsIgnoreCase(VarType) Then
				Vlist.Add(Var.name)
			End If
		End If
	Next
	Return Vlist
End Sub
Sub EnumVariables(Constants As Boolean, VarType As Int, Inclusive As Boolean, Scope As Int, FallbacktoZero As Boolean, FallbackScope As Int)As List 
	Dim temp As Int, Var As Variable, Vlist As List,Matches As Boolean 
	RegisterInternals
	Vlist.Initialize
	For temp = 0 To VarList.Size-1
		Var = VarList.Get(temp)
		'Log("CHECKING: " & var.name)
		If Var.Scope = Scope Or Var.Scope = FallbackScope Or (FallbacktoZero And Var.Scope=0) Then
			'Log(var.name & " passed scope test")
			If Constants = Var.isConst Then
				'Log(var.name & " passed const test")
				Matches=False 
				If VarType = -1 Or VarType = Var.VarType Then
					'Log(var.name & " passed inclusive test")
					Matches=Inclusive
				Else
					'Log(var.name & " passed exclusive test")
					Matches=Not(Inclusive)
				End If
				If Matches Then
					Vlist.Add(  Var.name.ToUpperCase    )
				End If
			End If
		End If
	Next
	Return Vlist
End Sub
Sub PushSubOntoStack(SubName As String)As Boolean 
	Dim temp As Int, Var As Variable, tempVar As Variable 
	temp = FindVariable(SubName, 0,False,0)
	If temp>-1 Then 
		Var = VarList.Get(temp)
		If Var.varType = ch_routine Then
			If VarStack.Size=0 Then LCAR.BackupRestoreKB(True,"") 
			tempVar=CopyVar(Var)
			tempVar.Equation = "0"
			VarStack.Add (tempVar)
			Return True
		End If
	End If
End Sub
Sub CheckForQuotes(Text As String) As String
	Dim tempstr As String 
	Text=Text.Trim 
	tempstr=API.Left(Text,1)
	Select Case tempstr
		Case "'", vbQuote
			If API.Right(Text,1) <> tempstr Then Return Text & tempstr
	End Select
	Return Text
End Sub
Sub SetStackItem(StackIndex As Int, ItemIndex As Int, Value As String)As Boolean 
	Dim Var As Variable, Par As Parameter ,tempstr As String 
	Value=CheckForQuotes(Value)
	If StackIndex<0 Then StackIndex = VarStack.Size-1
	If StackIndex< VarStack.Size And StackIndex>-1 Then
		Var = VarStack.Get(StackIndex)
		If ItemIndex=-1 Then
			Var.Equation = Value
		Else If ItemIndex < Var.Values.Size Then
			If ItemIndex<0 Then ItemIndex = Var.Equation 
			Par = Var.Values.Get(ItemIndex)
			Par.Default = Value
		Else If ItemIndex = -999 Then
			Var.name = Value
		End If
		Return True 
	End If
End Sub
Sub PullStackItem(doProcess As Boolean) As String 
	Dim tempstr As String 
	If doProcess Then
		tempstr= MakeStackItem(-1)
		VarStack.RemoveAt( VarStack.Size-1)
		SetStackItem(-1,-2, tempstr)
	Else
		VarStack.RemoveAt( VarStack.Size-1)
		tempstr = VarStack.Size
	End If
	If VarStack.Size=0 Then LCAR.BackupRestoreKB(False, tempstr)'last item in stack
	Return tempstr
End Sub
Sub MakeStackItem(StackIndex As Int) As String 
	Dim Var As Variable, Par As Parameter , temp As Int, tempstr As StringBuilder 
	tempstr.Initialize 
	If StackIndex< VarStack.Size Then
		If StackIndex<0 Then StackIndex = VarStack.Size-1
		Var = VarStack.Get(StackIndex)
		tempstr.Append(  Var.name & "(")
		'tempstr.Append(  Var.name )
		For temp = 0 To Var.Values.Size-1
			Par = Var.Values.Get(temp)
			'tempstr.Append( API.IIF(temp=0, "(", ", ") & Par.Default )
			tempstr.Append( API.IIF(temp=0, "", ", ") & Par.Default )
		Next
		'If Var.Values.Size>0 Then tempstr.Append(")")
	End If
	'Return tempstr.ToString 
	Return tempstr.ToString & ")"
End Sub
Sub ShowStackItem(StackIndex As Int, ListID As Int, BG As Canvas)
	Dim Var As Variable, Par As Parameter , temp As Int, temp2 As Int 
	If StackIndex< VarStack.Size And VarStack.Size>0 Then
		If StackIndex<0 Then StackIndex = VarStack.Size-1
		Var = VarStack.Get(StackIndex)
		LCAR.LCAR_clearlist(ListID,0)
		LCAR.LCAR_AddListItem(ListID, "INSERT SUB", LCAR.LCAR_Random, -1, "", False, Var.name.ToUpperCase, 0, False,-1)
		LCAR.LCAR_AddListItem(ListID, "REMOVE SUB", LCAR.LCAR_Random, -1, "", False, Var.name.ToUpperCase, 0, False,-1)
		DoHelp(BG,Var,-1)
		For temp = 0 To Var.Values.Size-1
			Par = Var.Values.Get(temp)
			Select Case Par.varType'=1:=2:=3: =4:=5:=6:=7:ch_array=9:=10:
				'case ch_operand, ch_delimit, ch_leftbrk, ch_rigtbrk, ch_array = system, should not be encountered
				Case ch_numeric, ch_custom: temp2=0
				Case ch_routine, ch_strings: temp2=1
				Case ch_boolean: temp2=2
			End Select
			LCAR.LCAR_AddListItem(ListID, Par.name.ToUpperCase & " AS " & GetVarType( Par.varType ).ToUpperCase ,  LCAR.LCAR_Random, -1, temp2, False,  Par.Default.ToUpperCase , 0,False,-1)
		Next
	End If
End Sub

Sub DoHelp(BG As Canvas, Var As Variable, ParameterID As Int) 
	Dim Par As Parameter 
	If ParameterID=-1 Then
		Help(Var.name)
	Else If ParameterID< Var.Values.Size Then
		Par = Var.Values.Get(ParameterID)
		Help(Var.name & "(" & Par.name & ")")
	End If
	If EvalError.Length =0 And HelpText.Length>0 Then LCAR.ToastMessage(BG, HelpText.ToUpperCase, 5)
End Sub

Sub Answer(Index As Int) As String 
	Dim ListCount As Int'list 25
	ListCount= LCAR.GetListItemCount(25)
	If Index=-999 Then 
		Return ListCount-1
	Else If ListCount>0 Then
		Index=Index-1
		If Index<0 Or Index>=ListCount Then Index = ListCount-1
		Return LCAR.LCAR_GetListItem(25,Index).side 
	End If
	Return ""
End Sub
Sub ListValues(ListID As Int, Var As Variable)
	Dim temp As Int,temp2 As Int, Par As Parameter, tempstr As String  
	If Not(Var.IsInitialized) Then Var.Initialize 
	If Not(Var.Values.IsInitialized) Then 
		Var.Values.Initialize 
	Else
		temp2=-1
		For temp = 0 To Var.Values.Size-1
			If Var.varType = ch_routine Then
				Par = Var.Values.Get(temp)
				tempstr = Par.name & " AS " & GetVarType(Par.varType)
				If Par.Default.Length>0 Then tempstr = tempstr & " = " & Par.Default 
			Else
				tempstr = Var.Values.Get(temp)
				temp2=temp
			End If
			LCAR.LCAR_AddListItem(ListID, tempstr.ToUpperCase , LCAR.LCAR_Random, temp2, "", False, "", 0, False,-1)
		Next
	End If
End Sub
Sub DeleteValue(Var As Variable, Index As Int)As Boolean 
	If Var.Values.Size>1 And Index < Var.Values.Size Then 
		Var.Values.RemoveAt(Index)
		Return True
	End If
End Sub
Sub AppendText(tempstr As StringBuilder, Text As String)
	tempstr.Append(API.IIF(tempstr.Length=0, "", ", ") & Text)
End Sub
Sub AppendValue(Var As Variable)
	If Var.varType=ch_routine Then
		Var.Values.Add( MkP("NEWPAR" & (Var.Values.Size+1), ch_strings, ""))
	Else
		Var.Values.Add("")
	End If
End Sub
'END LCARS UI SPECIFIC API











Sub SetTimeVariables As String 
	SetVariable("now", 0, False, 0,			DateTime.Now, False)
	SetVariable("today", 0, False, 0,		API.OnlyDate(DateTime.Now), False)
	SetVariable("yesterday", 0, False, 0,	API.OnlyDate(DateTime.Now - DateTime.TicksPerDay), False)
	SetVariable("tomorrow", 0, False, 0,	API.OnlyDate(DateTime.Now + DateTime.TicksPerDay), False)
	SetVariable("seconds", 0, False, 0,		DateTime.TicksPerSecond, False)
	SetVariable("minutes", 0, False, 0,		DateTime.TicksPerMinute, False)
	SetVariable("hours", 0, False, 0,		DateTime.TicksPerHour, False)
	SetVariable("days", 0, False, 0,		DateTime.TicksPerDay, False)
	Return "Now (variable) = " & GetVariable("now", 0, False, 0) & " (actual) = " &  DateTime.Now'test
End Sub

Sub Val(Equation As String) As String 
	Dim Scope As Int, Left As Int, tempstr As String 
	EvalError=Empty
	CurrentLevel=0
	RegisterInternals
	'SetTimeVariables
	HelpText=""
	Left = API.Instr(Equation, "@",0)
	If Left>-1 Then
		tempstr = API.Left(Equation, Left)
		If IsNumber(tempstr) Then
			Scope=tempstr
			Equation =  API.Right(Equation, Equation.Length-Left-1) 
		End If
	End If
	Try
		tempstr = Evaluate(Equation, Scope,True,0)
		If EvalError.Length=0 Then SetVariable("answer", Scope, True, 0, tempstr,False)
	Catch
		EvalError = LastException.Message
		Log("ERROR: " & EvalError)
	End Try 
	OptionExplicit = True
	Return tempstr
End Sub
Sub Evaluate(Equation As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int) As String 
	Dim Equ As List, tempstr2() As String , temp As Int ,tempstr As String , tempstr3 As String, PAR As Parameter , Var As Variable , isConst As Boolean 
	If CurrentLevel<OverFlowLimit Then
		CurrentLevel=CurrentLevel+1
		EvalError=Empty
		'tempstr2 = Regex.Split(" ", Equation)
		'tempstr= tempstr2(0)
		Equ = splitbychartype(Equation, True, True, True)
		If Equ.Size>0 Then
			tempstr=Equ.Get(0)
			Select Case tempstr.ToLowerCase 
				Case "const", "dim", "sub", "funct", "ifunct", "function", "internal", "var"		
					Equ.RemoveAt(0)
					tempstr3=tempstr
					tempstr=List2String(Equ, " ")
					PAR =MkPFromString(tempstr) ' MkFromString(List2String(Equ, " ")).Get(0)
					Select Case tempstr3.ToLowerCase 
						Case "const"
							isConst=True
						Case "sub", "ifunct", "internal"
							isConst=True
							PAR.varType = ch_routine
						Case "funct", "function"
							PAR.varType = ch_routine
					End Select	
					If PAR.varType = ch_routine Then
						If isinbrackets2( Equation ) Then
							PAR.Default ="(" & GetFromBrackets(Equation,False) & ")"
							PAR.name = JustTheName(PAR.name)
						End If
						Var = RegisterVariable(PAR.name, 0, ch_routine, isConst,  MkFromString(PAR.Default))
						If Not(isConst) Then
							tempstr = API.GetBetween(Equation, "=", "(")
							PAR.varTypeS = tempstr.Trim 
						End If
					Else If isinbrackets( PAR.Default ) Then
						Var = RegisterVariable(PAR.name, Scope, PAR.varType, isConst , splitparameters(GetFromBrackets(PAR.Default,False), True) ) 
					Else
						Var = RegisterVariable(PAR.name, Scope, PAR.varType, isConst , Array As String(PAR.Default))
					End If
					Var.Equation = PAR.varTypeS 
					Return EvalError.Length=0
				Case "type"
					Equ.RemoveAt(0)
					tempstr=List2String(Equ, " ")
					RegisterType(JustTheName(tempstr) , MkFromString(GetFromBrackets(tempstr, False)))
					Return EvalError.Length=0
				Case "set"
					Equ.RemoveAt(0)'remove the word set
					tempstr = Equ.Get(0)'List2String(Equ, " ")
					'tempstr = JustTheName(tempstr)
					Equ.RemoveAt(0)'remove the variable name
					If Equ.Get(0) = "=" Then Equ.RemoveAt(0)'remove the = sign
					tempstr3=List2String(Equ, " ")
					tempstr3=Evaluate(tempstr3, Scope, FallbackToZero, FallbackScope)
					If EvalError.Length> 0 Then 
						Return EvalError
					else If VarExists(tempstr, Scope, FallbackToZero, FallbackScope) Then 
						SetVariable(tempstr, Scope, FallbackToZero, FallbackScope, tempstr3, False)
					Else 
						RegisterVariable(tempstr, Scope, ch_strings, False, Array As String(tempstr3))
					End If
					'Log("SET '" & tempstr & "' TO: '" & tempstr3 & "' RESULTS: '" & GetVariable(tempstr, 0,False, 0) & "'")
				
				Case Else
					'preprocessor
					ProcessSingles(Equ)
					Process(Equ, Array As String("+=", "=+"), Scope, FallbackToZero, FallbackScope)
					Process(Equ, Array As String("-="), Scope, FallbackToZero, FallbackScope)
					Process(Equ, Array As String("=="), Scope, FallbackToZero, FallbackScope)
					
					'evaluate sub-equations
					For temp = 0 To Equ.Size-1
						tempstr = Equ.Get(temp)
						If temp>0 And tempstr = "++" Then
							SetVariable(Equ.Get(temp-1),Scope,FallbackToZero,FallbackScope, "1",  True)
						Else If isinbrackets(tempstr) Then
							'tempstr = EvaluateParameters(GetFromBrackets(tempstr,False),Scope, FallbackToZero, FallbackScope)
							tempstr = Evaluate(GetFromBrackets(tempstr,False),Scope, FallbackToZero, FallbackScope)
							Equ.Set(temp,tempstr)
						Else
							If CharType(tempstr) = ch_routine Then
								tempstr= EvaluateParameters(tempstr,Scope, FallbackToZero, FallbackScope)
								tempstr = GetVariable(tempstr, Scope, FallbackToZero, FallbackScope)
								Equ.Set(temp,tempstr)
							End If
						End If
						If EvalError.Length>0 Then Return Empty
					Next
					
					Process(Equ, Array As String("^"), 0, False, 0)
					Process(Equ, Array As String("*", "/", "\", "~"), 0, False, 0)
					Process(Equ, Array As String("+", "-"), 0, False, 0)
					Process(Equ, Array As String("&", "|", "=", "!", "<", ">", "<>", "><", "!=", "=!", "~!","!~", ">=", "<=", "=<", "=>"), 0, False, 0)
					
					CurrentLevel=CurrentLevel-1
					Return Equ.Get(Equ.Size-1)
			'		If Equ.Size=1 Then
			'			Return Equ.Get(0)
			'		Else
			'			EvalError = "Formula did not evaluate to a single value"
			'			EvalMoreData = Equation & "=" & ListToString(Equ,True)
			'		End If
			End Select
		End If
	Else
		EvalError = API.getstring("calc_stackoverflow")
		CurrentLevel=0
	End If
	Return Empty
End Sub
Sub ProcessSingles(Equation As List)
	Dim Right As String, Op As String, temp As Int ,Value As String 
	If EvalError.Length =0 Then
		For temp = 0 To Equation.Size - 2
			If temp < Equation.Size And EvalError.Length=0 Then
				Op = Equation.Get(temp)
				Right = Equation.Get(temp+1)
				If IsNumber(Right) Then
					Select Case Op
						Case "√":	Value = Sqrt(Right)
						Case Else:	Value=""
					End Select
					If Value.Length>0 Then
						Equation.Set(temp, Value)
						Equation.RemoveAt(temp+1)
					End If
				End If
			End If
		Next
		ProcessAdjacentVariables(Equation)
	End If
End Sub
Sub ProcessAdjacentVariables(Equation As List)'separate variables with a *
	Dim Left As String, Right As String, temp As Int, temp2 As Int 
	If EvalError.Length =0 Then
		For temp = Equation.Size - 2 To 0 Step -1
			Left = Equation.Get(temp)
			temp2 = CharType(Left)
			If temp2 = ch_routine Or temp2 = ch_numeric Then
				Right = Equation.Get(temp+1)
				temp2 = CharType(Right)
				If temp2 = ch_routine Or temp2 = ch_numeric Then
					Equation.InsertAt(temp+1, "*")
				End If
			End If
		Next
	End If
End Sub
Sub Process(Equation As List, Ops As List, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int)
	Dim Left As String, Right As String, Op As String, temp As Int ,Value As String 
	If EvalError.Length =0 Then
		For temp = 1 To Equation.Size - 2
			If temp < Equation.Size And EvalError.Length=0 Then
				Op = Equation.Get(temp) 
				If DoOp(Ops,Op) Then
					Left = Equation.Get(temp-1)
					Right = Equation.Get(temp+1)
					Value = ProcessOp(Left, Op, Right, Scope, FallbackToZero, FallbackScope)
					Equation.Set(temp-1, Value)
					Equation.RemoveAt(temp+1)
					Equation.RemoveAt(temp)
					temp=temp-1
				End If
			Else
				Exit
			End If
		Next
	End If
	'Log("Processing: " & ListToString(Ops,True) & " becomes " & ListToString(Equation,True))
End Sub
Sub DoOp(Ops As List, Op As String) As Boolean 
	Return Ops.IndexOf(Op)>-1
End Sub
Sub ProcessOp(Left As String, Op As String, Right As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int) As String 
	Dim DivisionByZero As Boolean 
	If isabool(Left,True) Then Left = toBool(Left)
	If isabool(Right,True) Then Right = toBool(Right)
	If IsNumber(Left) And IsNumber(Right) Then
		Select Case Op
			Case "^": Return Power(Left,Right)
			Case "*": Return Left * Right
			Case "/": If Right=0 Then DivisionByZero=True Else Return Left / Right
			Case "~": If Right=0 Then DivisionByZero=True Else Return Floor(Left/Right)
			Case "+": Return Left + Right
			Case "-": Return Left - Right
			
			Case "=": Return Left = Right
			Case ">": Return Left > Right
			Case "<": Return Left < Right
			Case "<=", "=<": Return Left <= Right
			Case ">=", "=>": Return Left >= Right
			Case "!=", "<>", "><": Return Left <> Right
			
			Case "&": Return Bit.And(Left,Right)' Left AND Right
			Case "|": Return Bit.Or(Left,Right)' Left OR Right
			Case ">>": Return Bit.ShiftRight(Left,Right)
			Case "<<": Return Bit.ShiftLeft(Left,Right)
		End Select
		If DivisionByZero Then
			EvalError = API.GetString("calc_dividebyzero")
			EvalMoreData = Left & " / " & Right
			Return Empty
		End If
	Else if Op.Length > 0 Then 
		Left = RemoveFromQuotes(Left)
		Right = RemoveFromQuotes(Right)
		Select Case Op
			'preprocessor
			Case "==": SetVariable(Left,Scope, FallbackToZero,FallbackScope, Right,   False): Return EvalError.Length=0
			Case "+=", "=+": SetVariable(Left,Scope, FallbackToZero,FallbackScope, Right, True): Return EvalError.Length=0
			Case "-=": SetVariable(Left,Scope, FallbackToZero,FallbackScope, Right*-1, True): Return EvalError.Length=0
			
			'is string data
			Case "&", "+": Return PutInQuotes(RemoveFromQuotes(Left) & RemoveFromQuotes(Right))
			Case "=": Return Left = Right
			Case "~": Return Left.EqualsIgnoreCase(Right)
			Case ">": Return Left.CompareTo(Right) > 0
			Case "<": Return Left.CompareTo(Right) < 0
			Case "<=", "=<": Return Left.CompareTo(Right) <= 0
			Case ">=", "=>": Return Left.CompareTo(Right) >= 0
			Case "!=", "<>", "><": Return Not(Left=Right)
			Case "~!", "!~": Return Not(Left.EqualsIgnoreCase(Right))
		End Select
	End If
	
End Sub
Sub EvaluateParameters(Text As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int) As String 
	Dim Values As String, ValueList As List ,temp As Int ,tempstr As StringBuilder ,tempstr2 As String 
	If API.Instr(Text,"(",0)>-1 Then
		Values=GetFromBrackets(Text,False)		
		tempstr.Initialize 
		tempstr.Append (API.Left(Text, API.Instr(Text, "(",0)+1).Trim )
		ValueList= splitparameters(Values, False)
		For temp = 0 To ValueList.Size-1
			tempstr2=Evaluate( ValueList.Get(temp), Scope, FallbackToZero,FallbackScope)
			tempstr.Append( API.IIF(temp=0,Empty, ", ") &  tempstr2)
		Next
		Return tempstr.ToString & ")"
	Else
		Return Text
	End If
End Sub












'Variable creation
Sub SaveVar(Var As Variable) As String 
	Dim temp As Int,tempstr As StringBuilder,tempstr2 As String,tempstr3 As String, Value As String
	tempstr.Initialize 
	If Var.IsInitialized  Then
		If Var.Scope <> 0 Then tempstr.Append (Var.Scope & "@")
		If Var.varType = ch_routine Then'function, internal or user-defined
			tempstr.Append (API.IIF(Var.isConst, "sub", "funct"))
		Else If Var.varType = ch_custom And Var.Equation.Length=0 Then'custom type definition
			tempstr.Append ("type")
		Else'regular variable
			tempstr.Append (API.IIF(Var.isConst, "const", "dim"))
		End If
		tempstr.Append( " " & Var.Name & " as " )
		If Var.varType = ch_custom And Var.Equation.Length>0 Then
			tempstr.Append(Var.Equation)
		Else
			tempstr.Append( GetVarType(Var.varType))
		End If
		If Var.varType = ch_routine And Not(Var.isConst) Then'user-defined sub
			tempstr2 = SaveParameters(Var.Values)
			tempstr3 = Var.Equation 
		Else If Var.Values.Size =1 Then
			tempstr2= Var.Values.Get(0)
		Else If Var.Values.Size>1 Then
			tempstr2="(" & JoinList( Var.Values) & ")"  'Evaluate(Name,Scope,FallbackToZero,FallbackScope)
		End If
		If tempstr3.Length>0 Then tempstr.Append(" = " & tempstr3)
		If tempstr2.Length>0 Then tempstr.Append(API.IIF(tempstr3.Length=0, " = ", " ") & tempstr2)
	End If
	Return tempstr.ToString 
End Sub
Sub SaveParameters(pList As List) As String 
	Dim temp As Int,tempstr As StringBuilder,tempstr2 As String
	tempstr.Initialize 
	For temp = 0 To pList.Size-1
		tempstr2= MkPintoString( pList.Get(temp) )
		tempstr.Append( API.IIF(temp=0, "(", ", ") & tempstr2)
	Next
	If pList.Size>0 Then tempstr.Append(")")
	Return tempstr.ToString 
End Sub

Sub SetVariable(Name As String, Scope As Int,FallbackToZero As Boolean, FallbackScope As Int, Contents As String, Relative As Boolean)
	Dim Var As Variable , PAR As List, tempstr As String, temp As Int
	Var = GetVariableData(Name,Scope,  FallbackToZero,FallbackScope)
	If Var.IsInitialized Then 
		If Var.isConst Then
			EvalError = API.GetStringVars("calc_constant", Array As String(Name))
			EvalMoreData = Name
		Else
			tempstr = GetFromBrackets(Name, False)
			PAR= splitparameters(tempstr, True)
			If Not(PAR.IsInitialized) Then PAR.Initialize 
			tempstr = GetFromPeriod(Name)
			If tempstr.Length>0 And Var.varType= ch_custom Then 
				temp = GetMethodIndex(Var.Equation, tempstr)
				If temp>-1 Then PAR.Add(temp)
			End If
			GetValue(PAR, Var.Values, Contents, Relative)
		End If
	Else 'If Not(OptionExplicit) Then
		RegisterVariable(Name, Scope, TXT, False, splitparameters(Contents, True))
	End If
End Sub

Sub MakeParFromArray(Values As List) As Parameter 
	Dim temp As Int, par As Parameter ,Key As String, Value As String 
	par.Initialize 
	For temp = 0 To Values.Size-1
		Value = Values.Get(temp)
		Key = API.GetSide(Value, "=",True,False)
		Value = API.GetSide(Value, "=",False,False)
		Select Case Key.ToLowerCase 
			Case "default": par.Default = Value
			Case "vartypes": par.varTypeS= Value
			Case "name": par.name = Value
			Case "vartype": par.varType = Value
		End Select
	Next
	Return par
End Sub

Sub GetMethodIndex(VarType As String, Method As String ) As Int 
	Dim Var As Variable, PAR As Parameter  , temp As Int 
	Var = GetVariableData(VarType, 0, False,0)
	If Var.IsInitialized Then
		For temp = 0 To Var.Values.Size-1
			PAR = Var.Values.Get(temp)
			If PAR.name.EqualsIgnoreCase(Method) Then Return temp
		Next
	Else
		EvalError = api.GetString("calc_customnotfound")
		EvalMoreData=VarType
	End If
	Return -1
End Sub

Sub MkP(Name As String, varType As Int, Default As String) As Parameter 
	Dim temp As Parameter 
	temp.Initialize 
	temp.Name = Name.Trim 
	temp.varType=varType 
	temp.Default=Default.Trim 
	Return temp
End Sub

Sub MkFromString(Parameters As String) As List
	Dim Plist As List, temp As Int , RetList As List , PAR As Parameter 
	If isinbrackets2(Parameters) Then Parameters = GetFromBrackets(Parameters,False)
	Plist = splitparameters(Parameters, False)
	RetList.Initialize 
	For temp = 0 To Plist.Size-1
		PAR=MkPFromString(Plist.Get(temp))
		If PAR.IsInitialized Then RetList.Add( PAR)
	Next
	Return RetList
End Sub	
Sub MkPintoString(Par As Parameter) As String 
	Dim tempstr As String 
	tempstr = Par.name & " as " & API.IIF(Par.varType=ch_custom, Par.varTypeS , GetVarType(Par.varType)) 
	If Par.Default.Length>0 Then tempstr = tempstr & " = " & Par.Default 
	Return tempstr
End Sub

Sub MkPFromString(Var As String) As Parameter 
	Dim Plist As List, temp As Int, PAR As Parameter ,tempstr As String ,temp2 As Int
	Plist = splitbychartype(Var, False ,True,False)
	If Plist.Size >0 Then
		PAR.Initialize 
		PAR.name = Plist.Get(0)
		For temp = 1 To Plist.Size-2
			tempstr = Plist.Get(temp)
			Select Case tempstr.ToLowerCase 
				Case "as"
					PAR.varType = GetVarType(Plist.Get(temp+1))
					If PAR.varType = ch_custom Then
						temp2 = FindVariable(Plist.Get(temp+1), 0,False,0)
						If temp2>-1 Then PAR.varTypeS = GetVariableData(Plist.Get(temp+1), 0,False,0).name 
					End If
				Case "="
					PAR.Default = Plist.Get(temp+1)
			End Select
		Next
	End If
	Return PAR
End Sub
'Name, vartype
Sub MkMethods(Parameters As List) As List
	Dim temp As Int, Plist As List 
	Plist.Initialize 
	For temp =0 To Parameters.Size-1 Step 2
		Plist.Add( MkP(Parameters.Get(temp), Parameters.Get(temp+1),""))
		If Parameters.Get(temp+1) = ch_array Then Exit
	Next
	Return Plist
End Sub	
'Name, vartype, [default]
Sub MkParameters(Parameters As List) As List
	Dim temp As Int, Plist As List 
	Plist.Initialize 
	For temp =0 To Parameters.Size-1 Step 3
		Plist.Add( MkP(Parameters.Get(temp), Parameters.Get(temp+1),Parameters.Get(temp+2) ))
		If Parameters.Get(temp+1) = ch_array Then Exit
	Next
	Return Plist
End Sub	


Sub ReplaceParameters(Equation As List, Parameters As List, MinRequired As Int, Scope As Int, Register As Boolean )As Boolean 
	Dim temp As Int , tempstr As String ,PAR As Parameter, Value As String  ,Value2 As String ,MaxParameters As Int 
	'Equation is the split-up parameter portion of the equation, ie: functname(this, this2, this3)
	'Parameters is the parameter list from the function data
	'Use VerifyParameter to check
	'adding missing values using default values
	MaxParameters = Parameters.Size
	If MaxParameters>0 Then
		PAR= Parameters.Get(Parameters.Size-1)
		If PAR.varType = ch_array Then MaxParameters = Equation.Size 
	End If
	If Equation.Size < MinRequired Or Equation.Size > MaxParameters Then
		If MinRequired<Parameters.Size Then
			EvalError = API.GetStringVars("calc_range_params", Array As String(MinRequired, Parameters.Size, Equation.Size)) 
		Else
			EvalError = API.GetStringVars("calc_min_params", Array As String(MinRequired, Equation.Size))
		End If
		Return False
	Else
		For temp = 0 To Parameters.Size-1
			PAR= Parameters.Get(temp)
			If temp < Equation.Size Then
				Value= Equation.Get(temp)
				If Not( VerifyParameter(Value, PAR.varType, Scope, False, Scope)) Then
					EvalError = API.GetStringVars("calc_typemismatch", Array As String(Value, GetVarType(PAR.varType)))
					Return False
				Else 
					If Register Then 
						Value = RemoveFromQuotes(Value)
					Else If PAR.varType = ANY Or PAR.varType = TXT Then
						Value2 = RemoveFromQuotes(Value)
						If Value2.Length<Value.Length Then Equation.Set(temp, Value2)
					End If
				End If
			Else
				Value = PAR.Default 
				If Not(Register) Then Equation.Add(Value)
			End If
			If Register Then RegisterVariable(PAR.name, Scope, PAR.varType, False, Array As String(Value))
		Next
	End If
	Return True
End Sub

Sub GetVarType(varType As String) As String 
	Dim temp As Int , Var As Variable 
	If IsNumber(varType) Then
		Return API.IIFIndex(varType, EnumStrings(-3) )
	Else
		Select Case varType.ToLowerCase 
			Case "int", "integer", "long", "single", "double", "number", "num", "byte", "float", "val": Return NUM
			Case "string", "text", "txt", "char": Return TXT 
			Case "yesno", "boolean", "bool", "bit": Return BOOL
			Case "type", "custom": Return ch_custom
			Case "sub", "funct", "ifunt", "function", "ifunction": Return ch_routine
			Case Else
				temp = FindVariable(varType, 0, False,0)
				If temp=-1 Then
					EvalError = API.GetString("calc_typenotfound")
					EvalMoreData = varType
				Else
					Var= VarList.Get(temp)
					If Var.varType = ch_custom And Var.Equation.Length = 0 Then
						Return ch_custom
					Else
						EvalError = API.GetString("calc_notvalidtype")
						EvalMoreData = Var.name 
					End If
				End If
		End Select
	End If
	Return Empty
End Sub
Sub isinbrackets2(Text As String) As Boolean 
	Dim temp As Int, temp2 As Int
	temp = API.Instr(Text, "(",0)
	temp2 = API.Instrrev(Text, ")")
	Return temp2>temp And temp>-1
End Sub
Sub GetFromBrackets(Text As String, ProcessPeriod As Boolean ) As String
	Dim temp As Int, temp2 As Int , FromBrackets As String 
	temp = API.Instr(Text, "(",0)
	temp2 = API.Instrrev(Text, ")")
	FromBrackets= API.Mid(Text, temp+1, temp2-temp-1)
	If ProcessPeriod Then
		Text=GetFromPeriod(Text)
		If FromBrackets.Length =0 Then 
			Return Text
		Else
			Return FromBrackets & ", " & Text
		End If
	End If
	Return FromBrackets
End Sub
Sub GetFromPeriod(Text As String) As String 
	Dim temp As Int 
	temp = API.Instrrev(Text,".")
	If temp>-1 Then	Return API.right(Text, Text.Length - temp - 1) Else Return Empty
End Sub

Sub JustTheName(Text As String) As String
	Dim temp As Int
	temp= API.Instr(Text,"(",0) 
	If temp>-1 Then Text = API.Left(Text, temp)
	temp= API.Instr(Text,".",0) 
	If temp>-1 Then Text = API.Left(Text, temp)
	'filter non-alphanumeric characters

	Return Text
End Sub
Sub VarExists(Name As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int) As Boolean 
	Return FindVariable(Name,Scope,FallbackToZero,FallbackScope)>-1
End Sub
Sub FindVariable(Name As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int) As Int
	Dim temp As Int, tempfunct As Variable , FallbackID As Int 
	FallbackID=-1
	Name = JustTheName(Name)
	For temp =0 To VarList.Size-1
		tempfunct= VarList.Get(temp)
		If tempfunct.Name.EqualsIgnoreCase(Name) Then' tempfunct.Scope = Scope Then Return temp
			Select Case tempfunct.Scope
				Case Scope: Return temp
				Case 0: If FallbackID =-1 Then FallbackID=temp
				Case FallbackScope: If FallbackScope <> 0 Then FallbackID=temp
			End Select
		End If
	Next
	Return FallbackID
End Sub
Sub DeleteVariable(Index As Int)
	If Index>-1 And Index < VarList.Size Then VarList.RemoveAt(Index)
End Sub
Sub DeleteVariableByName(Name As String, Scope As Int, FallbackToZero As Boolean , FallbackScope As Int)As Boolean 
	Dim temp As Int
	temp=FindVariable(Name,Scope,FallbackToZero,FallbackScope)
	If temp>-1 Then
		VarList.RemoveAt(temp)
		Return True	
	End If
	Return False
End Sub

'use MkMethods to make methods list
Sub RegisterType(name As String, Methods As List)As Boolean 
	Return RegisterVariable(name,0, ch_custom, True, Methods).IsInitialized 
End Sub

'use MkParameters to make parameters list
Sub RegisterFunction(name As String,  Parameters As List, Equation As String )As Boolean 
	Dim temp As Variable 
	temp = RegisterVariable(name,0, ch_routine, True, Parameters)
	If temp.IsInitialized Then
		temp.Equation = Equation
		Return True
	End If
End Sub
Sub CountMinParameters(Parameters As List) As Int
	Dim temp As Int, Count As Int ,Par As Parameter 
	If Parameters.IsInitialized Then
		For temp = 0 To Parameters.Size-1
			Par= Parameters.Get(temp)
			If Par.Default.Length =0 And Par.varType <> ch_array Then 
				Count=Count+1
			Else
				Exit
			End If
		Next
	End If
	Return Count
End Sub
Sub RegisterCustomVariable(name As String, Scope As Int, varType As String, isConst As Boolean, Values As List) As Variable 
	Dim tempfunct As Variable, temp As Int 
	tempfunct= GetVariableData(varType,0,False,0)
	If tempfunct.IsInitialized Then
		If Values.Size < tempfunct.Values.Size Then
			For temp = Values.Size To tempfunct.Values.Size
				Values.Add("")
			Next
		End If
		tempfunct= RegisterVariable(name, Scope, ch_custom, isConst, Values)
		If tempfunct.IsInitialized Then
			tempfunct.Equation = varType
		End If
	End If
	Return tempfunct
End Sub
Sub RegisterVariable(name As String, Scope As Int, varType As Int, isConst As Boolean, Values As List)As Variable 
	Dim tempfunct As Variable 
	If FindVariable(name, Scope, False,Scope)=-1 Then
		tempfunct.Initialize 
		tempfunct.name=name
		tempfunct.varType=varType
		If varType = ch_routine  Then 
			tempfunct.MinParams=CountMinParameters(Values)
			Scope=0
		End If
		tempfunct.Scope=Scope
		tempfunct.isConst=isConst'if it's a function/routine and isConst is true then it's an internal function not a user-defined one
		tempfunct.Values = Values
		
		If IsValidVar(tempfunct,True) Then VarList.Add(tempfunct)
	Else
		EvalError = API.GetString("calc_alreadydefined")
		EvalMoreData = JustTheName(name)
	End If
	Return tempfunct
End Sub
Sub IsValidVar(Var As Variable, IsInternal As Boolean) As Boolean 
	Dim tempstr As StringBuilder, tempstr2 As String 
	EvalError = ""
	EvalMoreData= ""
	tempstr.Initialize 
	If Var.name.Length = 0 Then
		AppendText(tempstr, API.GetString("calc_noname"))
	Else 
		VarIndex = FindVariable(Var.name, 0,False,0)
		If IsEditing Then
			If VarIndex=-1 Then AppendText(tempstr, API.GetString("calc_varnotfound"))
		Else
			If VarIndex>-1 Then AppendText(tempstr, API.GetString("calc_alreadydefined"))
		End If
	End If
	If (Var.varType <> ch_routine) Or (Var.varType = ch_routine And Not(Var.isConst)) Then
		If Var.Values.Size=0 Then AppendText(tempstr, API.GetString("calc_novalues"))
	End If
	Select Case Var.varType 
		Case ch_routine: 
			If Var.Equation.Length=0 And Not(Var.isConst) And Not(IsInternal) Then AppendText(tempstr, API.GetString("calc_noequation"))
			tempstr2 = CountDuplicateParameters(Var)
			If tempstr2.Length>0 Then AppendText(tempstr, API.GetStringVars("calc_dupeparameter", Array As String(tempstr2)))
			tempstr2=VerifyOptionalParameters(Var.Values)
			If tempstr2.Length>0 Then AppendText(tempstr, API.GetStringVars("calc_nonoptional", Array As String(tempstr2)))
		Case ch_custom: 
			If Not(Var.isConst) Then
				If Var.Equation.Length=0 And Not(IsInternal) Then
					AppendText(tempstr, API.GetString("calc_notype"))
				Else If Not(VarExists(Var.Equation , 0,False,0)) Then
					AppendText(tempstr, API.GetString("calc_typenotfound"))
				End If
			End If
	End Select
	EvalError = tempstr.ToString 
	If EvalError.Length>0 Then EvalMoreData = SaveVar(Var)
	Return EvalError.Length=0
End Sub
Sub CountDuplicateParameters(Var As Variable) As String
	Dim PLIST As List ,temp As Int, temp2 As Int ,Par As Parameter, tempstr As String 
	PLIST.Initialize 
	For temp = 0 To Var.Values.Size-1
		Par = Var.Values.Get(temp)
		tempstr=Par.name.ToLowerCase  
		For temp2 = temp+1 To Var.Values.Size-1
			Par = Var.Values.Get(temp2)
			If Par.name.EqualsIgnoreCase(tempstr) Then
				If PLIST.IndexOf(tempstr)=-1 Then PLIST.Add(tempstr)
			End If
		Next
	Next
	Return JoinList(PLIST)
End Sub
Sub VerifyOptionalParameters(Parameters As List)As String 
	Dim temp As Int , PAR As Parameter , OptionalFound As Boolean 
	For temp = 0 To Parameters.Size-1
		PAR = Parameters.Get(temp)
		If PAR.Default.Length>0 Then
			OptionalFound=True
		Else If OptionalFound Then
			Return PAR.name 
		End If
	Next
	Return ""
End Sub
Sub GetVariable(name As String, Scope As Int, FallbackToZero As Boolean, FallbackScope As Int) As String 
	Dim temp As Int, Var As Variable , Equation As List ,Values As String ,ValueList As List , AfterPeriod As String ,temp2 As Int
	temp = FindVariable(name,Scope, FallbackToZero,FallbackScope)
	If EvalError.Length=0 Then EvalMoreData=name
	If temp>-1 Then
		Var = VarList.Get(temp)
		temp = API.instr(name, "(", 0)
		If temp=-1 Then
			If Var.varType = ch_routine Then
				Return Var.Equation 
			Else
				If Var.varType = ch_custom Then
					AfterPeriod= GetFromPeriod(name)
					temp2= GetMethodIndex( Var.Equation, AfterPeriod)
					If temp2>-1 Then
						ValueList.Initialize
						ValueList.Add(temp2)
						Return GetValue(ValueList, Var.Values,Empty,False)
					Else If AfterPeriod.Length=0 Then
						Return ListToString(Var.Values, True)
					End If
				Else
					Return ListToString(Var.Values, True)
				End If
			End If
		Else
			Values=GetFromBrackets(name,False)
			ValueList= splitparameters(Values, False)
			If Var.varType = ch_routine Then
				ReplaceParameters(ValueList, Var.Values, Var.MinParams, Scope+1, Not(Var.isConst))
				If EvalError.Length=0 Then
					If Var.isConst Then'internal function
						Return InternalFunction(Var.name, ValueList)
					Else 'external function
						Values= Evaluate(Var.Equation, Scope+1, FallbackToZero,FallbackScope)
						DeleteScope(Scope+1)
						Return Values
					End If
				End If
			Else 
				If Var.varType = ch_custom Then
					AfterPeriod= GetFromPeriod(name)
					temp2= GetMethodIndex( Var.Equation, AfterPeriod)
					If temp2>-1 Then  ValueList.Add(temp2)
				End If
				Return GetValue(ValueList, Var.Values,Empty,False)
			End If
		End If
	Else If isabool(name,True) Then
		Return toBool(name)
	Else if OptionExplicit Then 
		EvalError = API.GetStringVars("calc_varnotfound", Array As String(name)) 
		EvalMoreData = name	
	End If
	Return Empty
End Sub
Sub GetVariableData(name As String, Scope As Int, FallbackToZero As Boolean, FallbackScope As Int)As Variable 
	Dim temp As Int, Var As Variable 
	temp = FindVariable(name,Scope, FallbackToZero,FallbackScope)
	If temp>-1 Then Var = VarList.Get(temp)
	Return Var
End Sub
Sub GetValue(Indexes As List, Values As List, Default As String, Relative As Boolean  )As String 
	Dim Index As Int , Value As Object , Values2 As List	
	If Indexes.Size=0 Then		
		Indexes.Add(0)
	End If
	If IsNumber(Indexes.Get(0)) Then Index = Indexes.Get(0)
	If Indexes.Size = 1 Then
		Indexes.Clear 
	Else
		Indexes.RemoveAt(0)
	End If
	If Index<Values.Size Then
		Value = Values.Get(Index)
		If Indexes.Size = 0 Then
			If Default.Length>0 Then
				Values2 = splitparameters(Default, False)
				If Values2.Size=1 Then
					If Relative And IsNumber(Value) Then
						Values.set(Index,Value+Default)
					Else
						Values.set(Index,Default)
					End If
				Else
					Values.set(Index,Values2)
				End If
			End If
			If Value Is List Then
				Return ListToString(Value, True)
			Else	
				Return Value
			End If
		Else If Value Is List Then
			Return GetValue(Indexes, Value,Default,Relative)
		Else
			EvalError = API.GetStringVars("calc_outofbounds", Array As String(Indexes.Get(0))) 
		End If
	Else
		EvalError = API.GetStringVars("calc_outofbounds", Array As String(Index)) 
	End If
	Return Empty
End Sub
Sub CopyVar(Var As Variable) As Variable 
	Dim temp As Int, tempvar As Variable  ,Par As Parameter
	tempvar.Initialize 
	If Var.IsInitialized Then
		tempvar.name = Var.name 
		tempvar.varType = Var.varType 
		tempvar.Scope = Var.Scope 
		tempvar.isConst= Var.isConst 
		tempvar.MinParams = Var.MinParams 
		tempvar.Equation = Var.Equation 
		tempvar.Values.Initialize 
		If Var.Values.IsInitialized Then
			For temp = 0 To Var.Values.size -1 
				If tempvar.varType = ch_routine Then
					Par =Var.Values.Get(temp)' MakeParFromArray( Var.Values.Get(temp) )
					tempvar.Values.Add( MkP(Par.name, Par.varType, Par.Default) )' Par)'
				Else
					tempvar.Values.Add( Var.Values.Get(temp) )
				End If
			Next
		End If
	End If
	Return tempvar
End Sub
Sub CopyPar(Par As Parameter) As Parameter 
	Dim temp As Parameter 
	temp = MkP(Par.name, Par.varType, Par.Default)
	temp.varTypeS = Par.varTypeS 
	Return temp
End Sub
Sub SetValue(Var As Variable, Index As Int, Value As String) As Boolean 
	Dim Char1 As String 
	If Var.Values.Size>0 And Var.Values.Size > Index Then
		Value=Value.trim
		Char1 = API.left(Value,1)
		If Char1 = vbQuote Or Char1 = "'" And API.right(Value,1) <> Char1 Then Value=Value & Char1		
		Var.Values.Set(Index,Value)
		Return True
	End If
End Sub
Sub NewScope As Int 
	CurrentScope = CurrentScope+1
End Sub
Sub DeleteScope(Scope As Int)
	Dim temp As Int,tempfunct As Variable 
	If Scope>0 Then
		For temp =VarList.Size-1 To 0 Step -1
			tempfunct= VarList.Get(temp)
			If tempfunct.Scope = Scope Then	VarList.RemoveAt(temp)
		Next
	End If
End Sub
Sub ListToString(TheList As List, DoAppend As Boolean ) As String 
	Dim tempstr As StringBuilder ,temp As Int , temp2 As Object ,temp3 As String
	If TheList.Size=1 Then
		temp2 = TheList.Get(0)
		If temp2 Is String Or temp2 Is Double Or temp2 Is Int Or temp2 Is Long Or temp2 Is Byte Or temp2 Is Float Then
			Return temp2
		Else
			Return ListToString(temp2, DoAppend)
		End If
	Else
		tempstr.Initialize 
		If DoAppend Then tempstr.Append("(")
		temp3=", "
		For temp = 0 To TheList.size-1
			temp2 = TheList.Get(temp)
			If temp = TheList.Size-1 Then temp3= ""
			If temp2 Is String Or temp2 Is Double Or temp2 Is Int Or temp2 Is Long Or temp2 Is Byte Or temp2 Is Float Then
				tempstr.Append( temp2 & temp3)
			Else If temp2 Is List Then
				tempstr.Append( ListToString(temp2, DoAppend) & temp3)
			End If
		Next
		Return tempstr.ToString & API.IIF(DoAppend, ")", Empty)
	End If
End Sub
Sub List2String(templist As List, Delimiter As String) As String 
	Dim temp As Int,tempstr As StringBuilder 
	tempstr.Initialize 
	For temp = 0 To templist.Size -1
		tempstr.Append(API.IIF(temp=0,Empty,Delimiter) & templist.Get(temp))
	Next
	Return tempstr.ToString 
End Sub
Sub VerifyParameter(Value As String, varType As Int, Scope As Int, FallbackToZero As Boolean, FallbackScope As Int) As Boolean 
	If varType = ANY Then 
		Return True
	Else
		If CharType(Value) = ch_routine Then
			Select Case Value.ToLowerCase 
				Case "true", "false": Return varType=ch_boolean
				Case Else: Return GetVariableData(Value, Scope, FallbackToZero,FallbackScope).varType = varType
			End Select
		Else
			Select Case varType
				Case ch_numeric: Return IsNumber(Value)
				Case ch_strings: Return True
			End Select
		End If
	End If
End Sub















Sub CharType(Text As String) As Int
	If Text.Length=0 Then Return -1
	Select Case API.Left(Text,1)
		Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".": Return ch_numeric
	    Case " ", ",": Return ch_delimit
	    Case "/", "\", "*", "-", "+", "^", "&", ">", "<", "=", "!", "|", "!", "~", "√": Return ch_operand
	    Case "(": Return ch_leftbrk
	    Case ")": Return ch_rigtbrk
	    Case vbQuote, "'": Return ch_strings
	    Case Else: Return ch_routine
	End Select
End Sub

Sub getendbracket(Text As String, Start As Int) As Int
	Dim Level As Int
	Level=1
	Start=Start+1
	Do Until Level =0 Or Start>= Text.Length 
		Select Case  CharType(API.Mid(Text, Start, 1))
			Case ch_strings : Start = findendquote(Text,Start)
			Case ch_leftbrk: Level=Level+1
			Case ch_rigtbrk: Level=Level-1
		End Select
		Start = Start + 1
	Loop
	Return Start+1
End Sub
Sub getendroutine(Text As String, Start As Int, CombineBrackets As Boolean) As Int
	Dim ctype As Int ,Digit As String 
    Start = Start + 1
	Digit=API.Mid(Text, Start, 1)
	ctype=CharType(Digit)
    Do Until ctype <> ch_routine And ctype<> ch_numeric And API.Mid(Text, Start, 1) <> "." And ctype <> ch_leftbrk Or Start >= Text.length 'ctype<> ch_delimit AND 
        If ctype=ch_leftbrk Then
			If CombineBrackets Then
            	Start =getendbracket(Text,Start)' API.InStr(Text, ")",Start)
            	If Start = -1 Then 
					Start = Text.length 
				Else 
					If API.Mid(Text, Start-1,1) = "." Then
						Return getendroutine(Text,Start, CombineBrackets)
					Else
						Return Start-1
					End If
				End If
			Else
				Return Start-1
			End If
        End If
        Start = Start + 1
		If Start < Text.length Then ctype=CharType(API.Mid(Text, Start, 1))
    Loop
    Return Start '- 1
End Sub
Sub getendops(Text As String, Start As Int) As Int
    Start = Start + 1
    Do Until API.instr("<>=", API.Mid(Text, Start, 1), Start) = -1 Or Start >= Text.length
        Start = Start + 1
    Loop
    Return Start '- 1
End Sub
Sub findendquote(Text As String, Start As Int) As Int
    Dim temp As Int, QuoteChar As String 'finds the next " or ' (depends on the start char) to end the string, ignores double quotes
	QuoteChar = API.Mid(Text,Start,1)'vbQuote
    temp = API.InStr(Text, QuoteChar,Start + 1)
    Do Until API.Mid(Text, temp + 1, 1) <> QuoteChar Or temp = -1
        temp = API.InStr(Text, QuoteChar,temp + 2)
    Loop
    Return temp+1
End Sub
Sub findendnumeric(Text As String, Start As Int) As Int
    Dim temp As Int, tempstr As String 
    temp = Start + 1
    Do Until CharType(API.Mid(Text, temp, 1)) <> ch_numeric
        temp = temp + 1
        If Text.length > temp + 1 Then
			tempstr= API.Mid(Text, temp, 2)
            If tempstr = "E" Or tempstr = "." Then temp = temp + 2 ' OR API.Mid(Text, temp, 2) = "E-" 
        End If
    Loop
    Return temp '- 1
End Sub
Sub splitbychartype(Equation As String, rejoin As Boolean, CombineBrackets As Boolean, CombineOperands As Boolean  ) As List 
	Dim cellcount As Long, count As Long, currtype As Int, temptype As Int, Start As Int, tempstr As String, strarray As List, FINISH As Int
	strarray.Initialize 
	Do Until Equation.Length = 0
		FINISH=0
    	Select Case CharType(API.Left(Equation, 1))
        	Case ch_strings
            	FINISH = findendquote(Equation, 0)
            	If FINISH = 0 Then
                	Equation = Empty
					EvalMoreData=Equation
                	EvalError = API.GetString("calc_illbeback")
            	End If
        	Case ch_operand
            	If API.Left(Equation, 1) = "-" And CharType(GetUbound(strarray)) = ch_operand Then
                	FINISH = findendnumeric(Equation, 0)
            	Else
                	FINISH = getendops(Equation, 0)
            	End If
        	Case ch_numeric
				FINISH= findendnumeric(Equation, 0)
        	Case ch_delimit
				Equation = API.Right(Equation, Equation.Length-1)
			Case ch_rigtbrk
				FINISH = 1
			Case ch_leftbrk
				If CombineBrackets Then
					FINISH= getendbracket(Equation, 0)-1
				Else
					FINISH=1
				End If
        	Case ch_routine
				FINISH= getendroutine(Equation, 0,CombineBrackets)
    	End Select
		If FINISH>0 Then Equation=Append(Equation, FINISH, strarray)
	Loop
	If rejoin Then rejoinbyoperand(strarray,CombineOperands)
	Return strarray
End Sub

Sub VReplace(Text As String, Extended As Boolean) As String
	Dim tempstr() As String, temp As Int, tempstr2 As StringBuilder 
	If Text.Contains(" ") Then
		tempstr = Regex.Split(" ", Text)
		tempstr2.Initialize 
		For temp = 0 To tempstr.Length-1
			tempstr(temp) = VReplace(tempstr(temp), Extended)
			tempstr2.Append( API.IIF(temp=0, "", " ") & tempstr(temp))
		Next
		Return tempstr2.ToString 
	Else
		Select Case Text.ToLowerCase
			Case "zero": Return 0
			Case "one": Return 1
			Case "two": Return 2
			Case "three": Return 3
			Case "four":Return 4
			Case "five":Return 5
			Case "six":Return 6
			Case "seven":Return 7
			Case "eight":Return 8
			Case "nine":Return 9
			Case "ten":Return 10
			Case "eleven":Return 11
			Case "twelve":Return 12
			Case "thirteen":Return 13
			Case "fourteen":Return 14
			Case "fifteen":Return 15
			Case "sixteen":Return 16
			Case "seventeen":Return 17
			Case "eighteen":Return 18
			Case "nineteen":Return 19
			Case "twenty":Return 20
			Case "thirty":Return 30
			Case "forty":Return 40
			Case "fifty":Return 50
			Case "sixty":Return 60
			Case "seventy":Return 70
			Case "eighty":Return 80
			Case "ninety":Return 90
			
			Case "plus", "add": Return  "+"
			Case "minus", "subtract": Return  "-"
			Case "multiply", "multiple", "times", "multiplied": Return  "*"
			Case "divide": Return  "/"
			Case "and": Return  "&"
			Case "or": Return  "|"
			Case "power", "exponent": Return  "^"
			Case "like": Return  "~"
			Case "equals", "equal", "is": Return  "="
			Case "lesser", "less": Return  "<"
			Case "greater", "more": Return  ">"
			Case "pie": Return  "pi"
			Case "percent": Return  "%"
			Case Else
				If Extended Then
					Select Case Text.ToLowerCase
						Case "an", "a": Return 1							
						Case "to": Return 2
						Case "for": Return 4
					End Select
				End If
		End Select
		Return Text
	End If
End Sub
Sub rejoinbyoperand(Equation As List, CombineOperands As Boolean)
	Dim temp As Int, ThisCell As String ,NextCell As String ,doMerge As Boolean 
	If DoVoice Then
		For temp =  Equation.Size -1 To 0 Step -1
			ThisCell = Equation.Get(temp)
			doMerge=True
			
			NextCell = VReplace(ThisCell, False)
			If ThisCell <> NextCell Then 
				ThisCell = NextCell
			Else
				Select Case ThisCell.ToLowerCase
					Case "squared"
						ThisCell="^"
						Equation.InsertAt(temp+1, 2)
					Case "cubed"
						ThisCell="^"
						Equation.InsertAt(temp+1, 3)
					Case "to", "the", "than", "then", "by", "what", "is"'"of"
						Equation.RemoveAt(temp)
						doMerge=False
					Case Else:doMerge=False
				End Select
			End If
			If doMerge Then Equation.Set(temp, ThisCell)
		Next
	End If
	
	For temp =  Equation.Size -2 To 0 Step -1
		ThisCell = Equation.Get(temp)
		NextCell=Equation.Get(temp+1)
		ThisCell=ThisCell.Trim 
		NextCell=NextCell.Trim 
		If isanop(ThisCell) Then
			If isanop(NextCell) Then
				Select Case ThisCell & NextCell
					Case "=>", "=>", ">=", "<=", "!=", "=!" 'merge
						Equation.Set(temp, ThisCell & NextCell)
						Equation.RemoveAt(temp+1)
					Case "--"'replace with +
						Equation.Set(temp, "+")
						Equation.RemoveAt(temp+1)
					Case Else
						If NextCell = "-" Then'lone negative, merge with next cell
							Equation.RemoveAt(temp+1)
							Equation.Set(temp+1, "-" & Equation.Get(temp+1))
						Else If NextCell =ThisCell Then'both are the same, remove them
							If CombineOperands Then	Equation.Set(temp, ThisCell & ThisCell)
							Equation.RemoveAt(temp+1)
						End If
				End Select
			End If
		Else If isinbrackets(NextCell) And CharType(ThisCell) = ch_routine Then
			If API.Instr(ThisCell,"(",0) =-1 Then
				Equation.Set(temp, ThisCell & NextCell)
				Equation.RemoveAt(temp+1)
			Else
				EvalError = API.GetString("calc_noop")
				EvalMoreData = ThisCell & " ? " & NextCell
			End If
		End If
		If temp=0 And ThisCell= "-" And IsNumber(NextCell) Then
			Equation.Set(0, "-" & NextCell)
			Equation.RemoveAt(1)
		End If
		If DoVoice Then
			doMerge=True
			Select Case ThisCell.ToLowerCase & " " & NextCell.ToLowerCase
				Case "left bracket", "start bracket", "open bracket", "opening bracket"
					Equation.Set(temp, "(")
				Case "right bracket", "end bracket", "finish bracket", "closing bracket", "close bracket"
					Equation.Set(temp, ")")
				Case "not equal"
					Equation.Set(temp, "!=")
				Case "square root"
					Equation.Set(temp, "√")
				Case Else
					doMerge=False			
			End Select
			If doMerge Then Equation.RemoveAt(temp+1)
		End If
		
		If (NextCell = "%" Or NextCell.EqualsIgnoreCase("percent")) And IsNumber(ThisCell) Then
			ThisCell= ThisCell * 0.01
			doMerge=True
			Select Case GetCell(Equation, temp-1)'temp-2=number temp-1=operand temp(thiscell)=number temp+1(NextCell)=percent
				Case "*"
				Case "+": ThisCell=ThisCell+1
				Case "-": ThisCell=1-ThisCell
				Case "/": ThisCell=1/ThisCell
				
				Case Else
					doMerge=False
					If GetCell(Equation, temp+2) = "of" Then 'temp(thiscell)=number temp+1(NextCell)=percent temp+2=of temp+3=number
						Equation.Set(temp, ThisCell)
						Equation.Set(temp+1, "*")
						Equation.RemoveAt(temp+2)
					Else
						EvalError = API.GetString("calc_percent")
					End If
			End Select
			If doMerge Then
				Equation.Set(temp-1, "*")
				Equation.Set(temp, ThisCell)
				Equation.RemoveAt(temp+1)
			End If
		End If 
	Next
	
	If DoVoice Then
		For temp =  Equation.Size -1 To 0 Step -1
			ThisCell = Equation.Get(temp)
			Select Case ThisCell.ToLowerCase
				Case "of":Equation.RemoveAt(temp)
			End Select
		Next
	End If
End Sub

Sub GetCell(Equation As List, Cell As Int) As String
	If Cell>-1 And Cell< Equation.Size Then Return Equation.Get(Cell)
	Return ""
End Sub

Sub IsAnEquation(Text As String) As Boolean 
	If Text.Contains("***") Then Return False
	If Text.StartsWith("what is ") Or Text.StartsWith("what's ") Then Return True
	Dim tempstr As List = splitbychartype(Text,False, False,False)
	Return HasWords(tempstr, Array As String("x", "-", "*", "+", "/", "=", "<", ">", "plus", "add", "minus", "subtract", "squared", "cubed", "divide", "power", "exponent", "like", "equals", "equal", "lesser", "less", "more", "greater", "bracket", "times", "percent"))
End Sub
Sub HasWords(Source As List, Words As List) As Boolean 
	Dim temp As Int, temp2 As Int , tempstr As String 
	For temp = 0 To Source.Size-1
		tempstr = Source.Get(temp)
		For temp2 = 0 To Words.size-1
			If tempstr.EqualsIgnoreCase(Words.Get(temp2)) Then Return True
		Next
	Next
End Sub

Sub isabool(Text As String, OnlyText As Boolean ) As Boolean 
	Select Case Text.ToLowerCase 
		Case "true", "false": Return True
		Case "0", "1": Return Not(OnlyText)
		Case Else: Return False
	End Select
End Sub
Sub toBool(Text As String) As Boolean 
	Select Case Text.ToLowerCase 
		Case "true", "1": Return True
		Case "false", "0": Return False
	End Select
End Sub
Sub isComparitor(Text As String) As Boolean 
	Dim temp As Int
	For temp = 0 To Text.Length-1
		Select Case API.Mid(Text,temp,1)
			Case "<", ">", "="
			Case Else: Return False
		End Select
	Next
	Return False
End Sub
Sub isinbrackets(Text As String) As Boolean 
	Return API.Left(Text,1)= "(" And API.Right(Text,1)=")"
End Sub

Sub isanop(Text As String) As Boolean
    'isanop = killchars(Text, opchars) = Empty AND Text <> Empty
	Dim temp As Int
	Text=Text.Trim 
	If Text.Length=0 Then Return False
	For temp = 0 To Text.Length-1
		If API.instr(opchars, API.Mid(Text,temp,1), 0)=-1 Then Return False
	Next
	Return True
End Sub

Sub splitparameters(Equation As String, ForceOne As Boolean) As List
	Dim Finish As Int , strarray As List, tChar As String 
	strarray.Initialize 
	Do Until Equation.Length=0
		Finish = API.Instr2(Equation, 0, Array As String(",", vbQuote, ","))
		tChar= API.mid(Equation, Finish,1)
		Equation=Append(Equation, Finish, strarray)
		Select Case tChar
			Case vbQuote, "'" 
				Finish = findendquote(Equation, 0)
				If Finish=0 Then 
					Equation = Empty
					EvalMoreData=Equation
	                EvalError = API.GetString("calc_illbeback")
				Else
					Equation=Append(Equation, Finish, strarray)
				End If
			Case ","
				Equation=API.right(Equation, Equation.Length-1)
		End Select
	Loop
	If strarray.Size = 0 And ForceOne Then strarray.Add("")
	Return strarray
End Sub

Sub GetUbound(Dst As List) As String
	If Dst.Size>0 Then Return Dst.Get(Dst.Size-1)
End Sub
Sub Append(Src As String, Length As Long, Dst As List)As String 
	Dst.Add(API.Left(Src,Length).Trim)
	If Length <= Src.Length Then Return API.Right(Src, Src.Length-Length)
	Return Empty
End Sub
Sub RemoveFromQuotes(Text As String) As String 
	Dim L As String, R As String 
	If Text.Length>1 Then
		L= API.Left(Text,1)
		R= API.Right(Text,1)
		If (L= vbQuote And R=vbQuote) Or (L = "'" And R = "'") Then 
			Text = API.mid(Text, 1, Text.Length -2)
		End If
	End If
	Return Text
End Sub
Sub PutInQuotes(Text As String) As String 
	Return vbQuote & Text & vbQuote
End Sub

Sub ConvertToRadians(Degrees As Double) As Double
    Select Case AngleMode
        Case vbRadians: Return Degrees
        Case vbDegrees: Return Trig.DegToRad(Degrees)'  Trig.RadToDeg(Radians)
        Case vbGradients: Return Trig.GradtoRad(Degrees)
    End Select
End Sub






Sub SaveLoadCustomVars(Settings As Map, Save As Boolean )
	Dim temp As Int, Last As Int, tempstr As String ,temp2 As Int 
	If Save Then
		Last = FindVariable("exp", 0,False,0)
		Settings.Put("VariableCount", VarList.Size-Last)
		For temp = Last+1 To VarList.Size-1
			tempstr = SaveVar( VarList.Get(temp) )
			Settings.Put("Variable" & temp2, tempstr)
			temp2=temp2+1
		Next
	Else If Not(VarsLoaded) Then'load
		Last = Settings.Getdefault("VariableCount", 0)
		For temp = 0 To Last-1
			Val( Settings.Get("Variable" & temp) )
		Next
		VarsLoaded=True
	End If
End Sub

Sub RegisterInternals
	If Not(Internals ) Then
		Internals=True
		
		'constants
		Val("const pi as num = " & Trig.Pi)'π
		Val("const e as num = " & cE)
		Val("const c as num = " & C)
		
		'string handling
		Val("sub asc (text as txt)") 
		Val("sub chr (value as num)")
		Val("sub instr (text as txt, txttofind as txt, start as num = 0)")
		Val("sub instrrev (text as txt, txttofind as txt)")
		Val("sub left (text as txt, digits as num)")
		Val("sub right (text as txt, digits as num)")
		Val("sub mid (text as txt, start as num, digits as num)")
		'Val("sub ucase (text as txt)")' = 'Returns the upper case of text'")
		'Val("sub lcase (text as txt)")' = 'Returns the lower case of text'")
		Val("sub trim (text as txt)")
		Val("sub replace (text as txt, txttofind as txt, replacewith as txt)")
		Val("sub gdate (text as txt)")'ValidDate
		
		'system
		Val("sub answer (index as num = 0)")' 
		Val("sub copy (text as txt)")'
		Val("sub paste")'
		Val("sub help (text as txt = '')")'
		
		'star trek
		Val("sub warp (warpfactor as num, era as num = 1)")'
		
		'trig
		Val("sub exp (number as num)")'Returns e raised to a power of value'")
		Val("sub log (number as num)")
		Val("sub sin (radian as num)")' = 'Returns the sin of angle in radians'")
		Val("sub cos (radian as num)")' = 'Returns the cos of angle in radians'")
		Val("sub tan (radian as num)")' = 'Returns the tan of angle in radians'")
		Val("sub atan (radian as num)")' = 'Returns the atan of angle in radians'")
		Val("sub sec (radian as num)")
		Val("sub cosec (radian as num)")
		Val("sub cotan (radian as num)")
		Val("sub arcsin (radian as num)")
		Val("sub arccos (radian as num)")
		Val("sub arcsec (radian as num)")
		Val("sub arccosec (radian as num)")
		Val("sub arccotan (radian as num)")
		Val("sub hsin (radian as num)")
		Val("sub hcos (radian as num)")
		Val("sub htan (radian as num)")
		Val("sub hsec (radian as num)")
		Val("sub hcosec (radian as num)")
		Val("sub hcotan (radian as num)")
		Val("sub harcsin (radian as num)")
		Val("sub harccos (radian as num)")
		Val("sub harctan (radian as num)")
		Val("sub harcsec (radian as num)")
		Val("sub harccosec (radian as num)")
		Val("sub harccotan (radian as num)")
		Val("sub sgn (number as num)")
		Val("sub logn (valuea as num, valueb as num)")
		Val("sub degtorad (angle as num)")' = 'Converts angle from degrees to radians'")
		Val("sub radtodeg (angle as num)")' = 'Converts angle from radians to degrees'")
		Val("sub radtograd (angle as num)")' = 'Converts angle from radians to gradients'")
		Val("sub getx (x as num, y as num, radius as num, angle as num)")' = 'Finds the X coordinate from X,Y at angle and radius'")
		Val("sub gety (x as num, y as num, radius as num, angle as num)")' = 'Finds the Y coordinate from X,Y at angle and radius'")
		Val("sub getangle (x1 as num, y1 as num, x2 as num, y2 as num)")' = 'Finds the angle between X1,Y1 and X2,Y2 in degrees where 0 is north'")
		Val("sub getdistance (x1 as num, y1 as num, x2 as num, y2 as num)")' = 'Finds the distance between X1,Y1 and X2,Y2'")
		
		'math
		Val("sub abs (value as num)")' = 'Returns the absolute of value'")
		Val("sub tobin (value as num)")' = 'Returns the binary string of value'")
		Val("sub tohex (value as num)")' = 'Returns the hexadecimal string of value'")
		Val("sub tooct(value as num)")' = 'Returns the octal string of value'")
		Val("sub rand (min as num=0, max as num=100)")' = 'Returns a random number between min and max'")
		Val("sub sqrt (value as num)")' = 'Returns the square root of value'")
		Val("sub round (value as num, digits as num=0)")' = 'Returns value rounded to digits'")
		'Val("sub exp (value as num)")'LAST VARIABLE				= 
	End If
	'DONT FORGET TO CHANGE LAST VARIABLE IN SaveLoadCustomVars
End Sub
Sub JoinList(tARR As List) As String 
	Dim temp As StringBuilder,temp2 As Int 
	temp.Initialize 
	For temp2 = 0 To tARR.size-1
		temp.Append( API.IIF(temp2=0, "", ", ") &  tARR.Get(temp2))
	Next
	Return temp.ToString 
End Sub
Sub GetP(Parameters As List, Index As Int) As String 
	If Index< Parameters.Size Then	Return Parameters.Get(Index)
	Return ""
End Sub
Sub InternalFunction(FunctionName As String, Parameters As List)As String 
	Select Case FunctionName.ToLowerCase 
		'string handling
		Case "asc":					Return Asc(API.left(RemoveFromQuotes( Parameters.Get(0)),1))
		Case "chr":					Return PutInQuotes(Chr(Parameters.Get(0)))
		Case "instr":				Return API.Instr(RemoveFromQuotes( Parameters.Get(0)), Parameters.Get(1), Parameters.Get(2))
		Case "instrev":				Return API.InstrRev(RemoveFromQuotes( Parameters.Get(0)), Parameters.Get(1))
		Case "left":				Return PutInQuotes(	API.Left(	RemoveFromQuotes(	Parameters.Get(0)	), Parameters.Get(1)	)	) 
		Case "right":				Return PutInQuotes( API.right(RemoveFromQuotes( Parameters.Get(0)), Parameters.Get(1)))
		Case "mid":					Return PutInQuotes( API.mid(RemoveFromQuotes( Parameters.Get(0)), Parameters.Get(1), Parameters.Get(2)))
		'Case "ucase":				Return API.uCase( Parameters.Get(0) )
		'Case "lcase":				Return API.lCase( Parameters.Get(0) )
		Case "trim":				Return PutInQuotes(API.trim(RemoveFromQuotes(Parameters.Get(0))))
		Case "replace":				Return PutInQuotes(API.Replace(RemoveFromQuotes(Parameters.Get(0)),   RemoveFromQuotes(Parameters.Get(1)), RemoveFromQuotes(Parameters.Get(2))))
		Case "gdate":				Return API.getdate(RemoveFromQuotes(Parameters.Get(0)))
		
		'system
		Case "answer":				Return Answer(Parameters.Get(0))
		Case "copy":				API.clipboard(0,Parameters.Get(0)): Return "true"
		Case "paste":				Return API.clipboard(1,"")
		Case "help":				Help(GetP(Parameters,0))
		
		'startrek
		Case "warp":				Return WarpFactor(Parameters.Get(0), Parameters.Get(1))
		
		'trig
		'Case "sind":				Return SinD(Parameters.Get(0))
		'Case "cosd":				Return CosD(Parameters.Get(0))
		'Case "tand":				Return TanD(Parameters.Get(0))
		'Case "atand":				Return ATanD(Parameters.Get(0))
		Case "sin":					Return Sin(ConvertToRadians(Parameters.Get(0)))
		Case "cos":					Return Cos(ConvertToRadians(Parameters.Get(0)))
		Case "tan":					Return Tan(ConvertToRadians(Parameters.Get(0)))
		Case "atan":				Return ATan(ConvertToRadians(Parameters.Get(0)))
		Case "exp":					Return Trig.Exp(ConvertToRadians(Parameters.Get(0)))
		Case "log":					Return Trig.alog(ConvertToRadians(Parameters.Get(0)))      
		Case "sec":					Return Trig.Sec(ConvertToRadians(Parameters.Get(0))) 
		Case "cosec":				Return Trig.CoSec(ConvertToRadians(Parameters.Get(0)))
		Case "cotan":				Return Trig.CoTan(ConvertToRadians(Parameters.Get(0)))
		Case "arcsin":				Return Trig.ArcSin(ConvertToRadians(Parameters.Get(0)))
		Case "arccos":				Return Trig.ArcCos(ConvertToRadians(Parameters.Get(0)))
		Case "arcsec":				Return Trig.ArcSec(ConvertToRadians(Parameters.Get(0)))
		Case "arccosec":			Return Trig.ArcCoSec(ConvertToRadians(Parameters.Get(0)))
		Case "arccotan":			Return Trig.ArcCoTan(ConvertToRadians(Parameters.Get(0)))
		Case "hsin":				Return Trig.HSin(ConvertToRadians(Parameters.Get(0)))
		Case "hcos":				Return Trig.HCos(ConvertToRadians(Parameters.Get(0)))
		Case "htan":				Return Trig.HTan(ConvertToRadians(Parameters.Get(0)))
		Case "hsec":				Return Trig.HSec(ConvertToRadians(Parameters.Get(0)))
		Case "hcosec":				Return Trig.HCoSec(ConvertToRadians(Parameters.Get(0)))
		Case "hcotan":				Return Trig.HCoTan(ConvertToRadians(Parameters.Get(0)))
		Case "harcsin":				Return Trig.HArcSin(ConvertToRadians(Parameters.Get(0)))
		Case "harccos":				Return Trig.HArcCos(ConvertToRadians(Parameters.Get(0)))
		Case "harctan":				Return Trig.HArcTan(ConvertToRadians(Parameters.Get(0)))
		Case "harcsec":				Return Trig.HArcSec(ConvertToRadians(Parameters.Get(0)))
		Case "harccosec":			Return Trig.HArcCoSec(ConvertToRadians(Parameters.Get(0)))
		Case "harccotan":			Return Trig.HArcCoTan(ConvertToRadians(Parameters.Get(0)))
		Case "sgn":					Return Trig.Sgn(Parameters.Get(0))
		Case "logn":				Return Trig.logn(Parameters.Get(0), Parameters.Get(1))
	
		Case "degtorad":			Return Trig.DegToRad(Parameters.Get(0))
		Case "radtodeg":			Return Trig.RadToDeg(Parameters.Get(0))
		Case "gradtorad":			Return Trig.GradToRad(Parameters.Get(0))
		Case "getx":				Return Trig.findXYAngle(Parameters.Get(0), Parameters.Get(1), Parameters.Get(2), Parameters.Get(3), True)
		Case "gety":				Return Trig.findXYAngle(Parameters.Get(0), Parameters.Get(1), Parameters.Get(2), Parameters.Get(3), False)
		Case "getangle":			Return Trig.GetCorrectAngle(Parameters.Get(0), Parameters.Get(1), Parameters.Get(2), Parameters.Get(3))
		Case "getdistance":			Return Trig.FindDistance(Parameters.Get(0), Parameters.Get(1), Parameters.Get(2), Parameters.Get(3))
		
		'math
		Case "abs":					Return Abs(Parameters.Get(0))
		Case "tobin":				Return PutInQuotes( Bit.ToBinaryString(Parameters.Get(0)) )
		Case "tohex":				Return PutInQuotes( Bit.ToHexString(Parameters.Get(0)) )
		Case "tooct":				Return PutInQuotes( Bit.ToOctalString(Parameters.Get(0)) )
		Case "rand":				Return Rnd(Parameters.Get(0), Parameters.Get(1)+1)
		Case "sqrt":				Return Sqrt(Parameters.Get(0))
		Case "round":				Return Round2(Parameters.Get(0), Parameters.Get(1))
	
		Case Else
			EvalError = "Unknown internal function was used"
			EvalMoreData = FunctionName
	End Select
End Sub

Sub Help(Topic As String)As String 
	Dim Par As String
	HelpTopic=": " & Topic.ToUpperCase 
	EvalError=""
	If isinbrackets2(Topic) Then Par = GetFromBrackets(Topic,False).ToLowerCase
	Topic = RemoveFromQuotes( Topic.Trim.ToLowerCase )
	If Topic.Length = "0" Then 
		Topic = "welcome"
		HelpTopic = ""
	End If
	If API.TransLation.ContainsKey("calc_" & Topic) Then 
		HelpText = API.getstringvars("calc_" & Topic, Array As String(Answer(-999)))
	Else if API.TransLation.ContainsKey("calc_" & Par) Then 
		HelpText = API.getstringvars("calc_" & Par, Array As String(API.IIFIndex(AngleMode, EnumStrings(-1)))) 
	Else 
		HelpText = API.getstring("calc_unknown")
	End If	
	Return HelpText
End Sub




'get the warp factor of a given speed in C
Sub ReverseWarp(SpeedOfLightFactor As Double, Phase As Int, MaxDigits As Int) As Double 
	Dim tempstr As String, temp As Int, tempC As Double
	For temp = 0 To API.IIFIndex(Phase, Array As Int(29,9,14))
		tempC = WarpFactor(temp, Phase)
		If tempC <= SpeedOfLightFactor Then
			tempstr = temp
		Else
			temp=30
		End If
	Next
	If tempstr.Length=0 Then tempstr = "0." Else tempstr = tempstr & "."
	For temp = 1 To MaxDigits 
		'Log("BEFORE: " & tempstr)
		tempstr = ReverseWarp2(SpeedOfLightFactor, Phase, tempstr)
		'Log("AFTER: " & tempstr)
		If WarpFactor(tempstr, Phase) = SpeedOfLightFactor Then Return tempstr
	Next
	Return tempstr
End Sub
Sub ReverseWarp2(SpeedOfLightFactor As Double, Phase As Int, tempstr As String) As String 
	Dim temp As Int, tempC As Double, tempWarp As Double , CurrentC As Double, Closest As String 'CurrentWarp As Double, 
	For temp = 0 To 9
		tempWarp = Val(tempstr & temp)'warp factor
		tempC = WarpFactor(tempWarp, Phase) 'speed of light
		If CurrentC = 0 Or Abs(tempC-SpeedOfLightFactor) < Abs(CurrentC-SpeedOfLightFactor) Then
			'Log(tempWarp & " (" & tempC & ") is closer to " & SpeedOfLightFactor & " than " & Closest)
			CurrentC=tempC
			Closest=tempstr & temp
		End If
	Next
	If Closest.Length=0 Then Return tempstr
	If Closest.EndsWith(".") Then Return API.left(Closest, Closest.Length-1)
	Return Closest
End Sub

Sub WarpFactor(Warp As Double, Phase As Int ) As Double
	Dim MaxSpeed As Int 
	Select Case Phase
		Case 0'TOS
			MaxSpeed=30
			If Warp<MaxSpeed Then Return Power(Warp,3) '* C
		Case 1'TNG
			MaxSpeed=10
			If Warp<MaxSpeed Then Return Power(Warp, 10/3) '*C
		Case 2'All Good Things
			MaxSpeed=15
			If Warp >9 Then Warp = 9 + ((Warp-9) /6)
			If Warp<MaxSpeed Then Return Power(Warp, 10/3)
		Case Else
			EvalError = API.GetString("calc_maxera")
			EvalMoreData = API.GetString("calc_maxera_more")
			Return 0
	End Select
	EvalError = API.GetString("calc_maxwarp")
	EvalMoreData = API.GetStringVars("calc_maxwarp_more", Array As String(Phase, MaxSpeed))
	Return 0
End Sub

 
