B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
'-------------------------------------------------------------------------------------------------------------------
'  FROM Article:    http://www.codeproject.com/Articles/7056/Code-to-extract-plain-text-from-a-PDF-file
'            By:    NeWi
'-------------------------------------------------------------------------------------------------------------------
'  As of 4/27/2015 I have changed the original code so much that I am not sure if the old code would be worth
'                    using as a reference  Bob Valentino
'-------------------------------------------------------------------------------------------------------------------
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Type  TTextPosition(Tx As Float, Ty As Float)   '  Tx (Left - Right position)  Ty (Top - Bottom position)
    Private  Const  bCR                As Byte     =  13
	Private  Const  bLF                As Byte     =  10
	Private  Const  bTAB               As Byte     =   9
	Private  Const  bSpace             As Byte     =  32
	Private  Const  bNumber0           As Byte     =  48
	Private  Const  bNumber9           As Byte     =  57
	Private  Const  bDecimalPt         As Byte     =  46
	Private  Const  bMinusSign         As Byte     =  45
	Private  Const  bCapA              As Byte     =  65
	Private  Const  bCapD              As Byte     =  68
	Private  Const  bCapF              As Byte     =  70
	Private  Const  bCapT              As Byte     =  84
	Private  Const  bLowerA            As Byte     =  97
	Private  Const  bLowerC            As Byte     =  99	
	Private  Const  bLowerD            As Byte     = 100
	Private  Const  bLowerF            As Byte     = 102
	Private  Const  bLowerM            As Byte     = 109
	Private  Const  bOpenParan         As Byte     =  40
	Private  Const  bCloseParan        As Byte     =  41
	Private  Const  bLessThan          As Byte     =  60
	Private  Const  bGreaterThan       As Byte     =  62
	Private  Const  bBackSlash         As Byte     =  92
    Private  InFile()                  As Byte
    Private  OldCharsSize              As Int      =  15 'Keep this many previous charactes for Back reference
	Private  OldChars(OldCharsSize)    As Byte
End Sub

Sub FindStringInBuffer(BufferStart As Long, StringToFind As String) As Long
    Dim  InFileLoop         As Long
	Dim  S2FindLoop         As Long
	Dim  FoundIt            As Boolean
	Dim  S2FindBytes()      As Byte    = StringToFind.GetBytes("UTF8")
	For InFileLoop = BufferStart To InFile.Length-1
	    FoundIt = True
	    For S2FindLoop = 0 To S2FindBytes.Length-1
		    If (InFileLoop+S2FindLoop) >= InFile.Length Then Return -1
		    If InFile(InFileLoop+S2FindLoop) <> S2FindBytes(S2FindLoop) Then 
			   FoundIt = False
			   Exit
			End If
	    Next
		If FoundIt Then Return InFileLoop
	Next
	Return -1
End Sub

Sub ReadPDF(FilePath As String, FileName As String) As Byte()      
    Return Bit.InputStreamToBytes(File.OpenInput(FilePath, FileName))	   
End Sub

Sub Decompression(BufferStart As Long, BufferLength As Long) As String
    Dim CompressDecompress            As CompressedStreams 
    Dim Data2Decompress(BufferLength) As Byte
	Dim BufferLoop                    As Long
	Dim BConverter                    As ByteConverter
	For BufferLoop = 0 To BufferLength-1
	    Data2Decompress(BufferLoop) = InFile(BufferStart+BufferLoop)
	Next
	Dim DecompressedBytes()           As Byte = CompressDecompress.DecompressBytes(Data2Decompress, "zlib")
	Return BConverter.StringFromBytes(DecompressedBytes, "UTF8")
End Sub

Sub IsDigit(Check As Byte) As Boolean
    If Check >= bNumber0 And Check <= bNumber9 Then Return True
	If Check = bDecimalPt Or Check = bMinusSign Then Return True	
End Sub

Sub GetTextMatrix(StartAt As Long, DataBytes() As Byte) As TTextPosition
	Dim BConverter        As ByteConverter
    Dim TextPosition      As TTextPosition
	Dim PositionLoop      As Long
	Dim NumberLoop        As Long
	Dim ProcessPosition   As Boolean
	Dim NumberBytes(10)   As Byte
	Dim NumberString      As String
	Dim SpacesCount 	  As Int
#If DebugX
    Dim Dump          As Long
	Dim DumpBytes(50) As Byte
	
	For Dump = 0 To DumpBytes.Length-1	    
	    DumpBytes(Dump) = DataBytes(StartAt+Dump)
    Next
	
    Log("DumpTextPosition:" &BConverter.StringFromBytes(DumpBytes, "UTF8"))
#End If

	TextPosition.Initialize
	'The proper way to find the TextMetrix values is to locate a Tm and back up 2 variables (using space as delimiter)
	For NumberLoop = StartAt To DataBytes.Length-2
	    If DataBytes(NumberLoop) = bCapT Then
		   If DataBytes(NumberLoop+1) = bLowerM Or DataBytes(NumberLoop+1) = bCapD Or DataBytes(NumberLoop+1) = bLowerD Then
			  'we have located Tm now make sure there is a space / line feed before it AND back up 2 more spaces
			  If DataBytes(NumberLoop-1) = bSpace Or DataBytes(NumberLoop-1) = bLF Then
			     SpacesCount = 0
			     For PositionLoop = NumberLoop-2 To StartAt Step -1
				     If DataBytes(PositionLoop) = bSpace Or DataBytes(PositionLoop) = bLF Then 
					    SpacesCount = SpacesCount + 1
					 End If
					 If SpacesCount = 2 Then
            	        ProcessPosition = True
						Exit
				     End If
			     Next
				 
				 If ProcessPosition Then Exit
			  End If
		   End If
	    Else If (NumberLoop-StartAt) > 150 Then 
			Exit				
	    End If
    Next			  
			  
    If ProcessPosition = False Then 
#If Debug
    Dim Dump          As Long
	Dim DumpBytes(50) As Byte

	For Dump = 0 To DumpBytes.Length-1	    
	    DumpBytes(Dump) = DataBytes(StartAt+Dump)
    Next
	
    Log("DumpTextPositionNotFound:" &BConverter.StringFromBytes(DumpBytes, "UTF8"))
#End If
	   Return TextPosition
	End If
	
	StartAt = PositionLoop
#If DebugX
    Dim Dump          As Long
	Dim DumpBytes(50) As Byte

	For Dump = 0 To DumpBytes.Length-1	    
	    DumpBytes(Dump) = DataBytes(StartAt+Dump)
    Next
	
    Log("DumpTextMatrix:" &BConverter.StringFromBytes(DumpBytes, "UTF8"))
#End If
	
	For PositionLoop = 0 To 2    '  How many Matrix Numbers there should be
	    For NumberLoop = StartAt To DataBytes.Length-1
		    If IsDigit(DataBytes(NumberLoop)) Then Exit
		Next
		StartAt = NumberLoop
		NumberBytes = Array As Byte(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	    For NumberLoop = StartAt To DataBytes.Length-1
		    If IsDigit(DataBytes(NumberLoop)) = False Then Exit
			NumberBytes(NumberLoop-StartAt) = DataBytes(NumberLoop)
		Next
		NumberString = BConverter.StringFromBytes(NumberBytes, "UTF8")
		StartAt = NumberLoop
	
	    If IsNumber(NumberString) Then
		   Select PositionLoop
			 	Case 0:  TextPosition.Tx = NumberString
			 	Case 1:  TextPosition.Ty = NumberString
		   End Select
		Else
#If DebugX
        For NumberLoop = 0 To NumberBytes.Length-1
            Log("Not a Number:" &NumberBytes(NumberLoop))
		Next
#End If 
		End If
	Next
	
	Return TextPosition
End Sub

Sub Seen2(Search As String) As Boolean
    Dim SearchBytes() As Byte = Search.GetBytes("UTF8")
	Dim OldCharsLoop  As Int
	Dim SBLoop        As Int
	Dim Hit           As Boolean = False
	For OldCharsLoop = 0 To OldChars.Length-2	    
	    Hit = True
	    For SBLoop = 0 To SearchBytes.Length-1
		    If (OldCharsLoop + SBLoop) < OldChars.Length Then
		       If OldChars(OldCharsLoop + SBLoop) <> SearchBytes(SBLoop) Then 
			      Hit = False
			      Exit
			   End If			
			End If
		Next
		If Hit Then Return True
	Next
	Return Hit
End Sub

Sub ProcessOutput(Identity As Boolean, DecompressedData As String) As String
    Dim InTextObject         As Boolean 'Are we currently inside a text object?
	Dim NextLiteral          As Boolean 'Is the next character a literal
	Dim RBDepth              As Int     'Bracket nesting level text appears inside ()
	Dim OCLoop               As Int
	Dim DataLoop             As Long
    Dim SkipOver             As Int
    Dim TB                   As Byte
	Dim TE                   As Byte
	Dim InsertChar           As Char    = " "           ' Tab
	Dim PrevPosition         As TTextPosition
	Dim CurrPosition         As TTextPosition	
    Dim BConverter           As ByteConverter
    Dim DataBytes()          As Byte   = DecompressedData.GetBytes("UTF8")
    Dim LastLine             As String
	Dim ThisLine             As String
    Dim OutString            As String
 
#If DebugX
    Log("DecompressedData Length:" &DecompressedData.Length)
	
	Dim  I  As Int
	
	For I = 0 To DecompressedData.Length Step 1000
	    If (I+1000) > DecompressedData.Length Then
           Log(DecompressedData.SubString(I))
		Else
	       Log(DecompressedData.SubString2(I, (I+1000)))
		End If
		
		Log(" ")
		Log(" ")
		
		If I >= 5000 Then Exit
	Next
#End If
 
	If Identity Then
	   TB     = bLessThan
	   TE     = bGreaterThan
	Else
	   TB     = bOpenParan
	   TE     = bCloseParan
	End If

    For OCLoop = 0 To OldCharsSize-1
	    OldChars(OCLoop) = bSpace
	Next
	PrevPosition.Initialize
	CurrPosition.Initialize
	SkipOver = 0
	
	For DataLoop = 0 To DataBytes.Length-1
#If Debug
	    If (DataLoop Mod 1000) = 0 Then Log("DataLoop:" &DataLoop &" of " &DataBytes.Length)
#End If
 
	    If SkipOver > 0 Then
		   SkipOver = SkipOver - 1
		   Continue
		End If

	    If InTextObject Then
		   If RBDepth = 0 And Seen2("ET") Then
		      InTextObject = False
			  PrevPosition.Tx = CurrPosition.Tx
			  PrevPosition.Ty = CurrPosition.Ty			  			  
		   Else If DataBytes(DataLoop) = TB And RBDepth = 0 And NextLiteral = False Then		   
				   '  Start outputting Text
				   RBDepth = 1
		   Else If DataBytes(DataLoop) = TE And RBDepth = 1 And NextLiteral = False Then
				   '  Stop outputting Text
				   RBDepth = 0				 
				   If Identity Then SkipOver = 1	   
		   Else If RBDepth = 1 Then
    			   If Identity Then
				      SkipOver = 4
					  
                      Dim TempString  As String = DecompressedData.SubString2(DataLoop+2, DataLoop+4)
					  Dim TempBytes() As Byte   = TempString.GetBytes("UTF8")
					  Dim TempByte    As Byte   = TempBytes(0)
					  Dim TempByte2   As Byte   = TempBytes(1)
					  
					  If      TempByte >= bNumber0 And TempByte <= bNumber9 Then  '>= 0 and <= 9
					          TempByte  = Bit.ShiftLeft(TempByte-bNumber0, 4)
					  Else If TempByte >= bLowerA And TempByte <= bLowerF Then    '>= a and <= f
					          TempByte  = Bit.ShiftLeft(TempByte-87, 4)           ' Make hex 10 -> F0
					  Else If TempByte >= bCapA And TempByte <= bCapF Then        '>= A and <= F
					          TempByte  = Bit.ShiftLeft(TempByte-55, 4)           ' Make hex 10 -> F0					  
					  End If
					  
					  If      TempByte2 >= bNumber0 And TempByte2 <= bNumber9 Then  '>= 0 and <= 9
					          TempByte   = Bit.ShiftLeft(TempByte2-bNumber0, 4)
					  Else If TempByte2 >= bLowerA And TempByte2 <= bLowerF Then    '>= a and <= f
					          TempByte   = Bit.ShiftLeft(TempByte2-87, 4)           ' Make hex 10 -> F0
					  Else If TempByte >= bCapA And TempByte <= bCapF Then        '>= A and <= F
					          TempByte  = Bit.ShiftLeft(TempByte-55, 4)           ' Make hex 10 -> F0					  							  
					  End If

					  
					  Dim NewBytes(1)          As Byte
					  NewBytes(0) = TempByte	  
	                  Dim BConverter           As ByteConverter
	                  Dim ConvertedBytes       As String = BConverter.StringFromBytes(NewBytes, "UTF8")
					
					  ThisLine = ThisLine &ConvertedBytes
		           Else		   
				      If DataBytes(DataLoop) = bBackSlash And NextLiteral = False Then
                         '----------------------------------------------------------------
				         '  Only print out next character no what do not interpret
				         '----------------------------------------------------------------
				         NextLiteral = True
				      Else
				         NextLiteral = False
						  
					     If (DataBytes(DataLoop) >= bSpace And DataBytes(DataLoop) <= 142) Or DataBytes(DataLoop) >= 128 Then 
						     Dim Bytes(1) As Byte
							 Bytes(0) = DataBytes(DataLoop)
					         ThisLine = ThisLine &BConverter.StringFromBytes(Bytes, "UTF8")
				         End If
				      End If
				   End If
		   End If
		End If

        For OCLoop = 0 To OldCharsSize-2
	        OldChars(OCLoop) = OldChars(OCLoop + 1)
	    Next
    
		OldChars(OldCharsSize-1) = DataBytes(DataLoop)
		
		If InTextObject = False Then
		   If Seen2("BT") Then 
		      InTextObject = True
			  
			  CurrPosition = GetTextMatrix(DataLoop+1, DataBytes)
			  			  
			  If PrevPosition.Ty = CurrPosition.Ty Then 			  
			     ThisLine = ThisLine &InsertChar
			  Else
			     If ThisLine.CompareTo(LastLine) = 0 Then 
				    ThisLine = ""
				    Continue
				 End If
				 
				 LastLine = ThisLine
			     If OutString.Length > 0 Then OutString = OutString &Chr(13) &Chr(10)  '&CRLF
				 OutString = OutString &ThisLine
			
#If Debug
              Log(OutString)
			  Log(" ")
#End If
				 
				 ThisLine = ""
			  End If
		   End If
		End If
	Next	
	
	If ThisLine.Length > 0 And ThisLine.CompareTo(LastLine) <> 0 Then 
	   If OutString.Length > 0 Then 
	      OutString = OutString &Chr(13) &Chr(10) &ThisLine
	   Else
	      OutString = ThisLine 
	   End If
    End If	   
	
	Return OutString
End Sub

Sub ProcessPDFFile(FilePath As String, FileName As String) As String
    InFile = ReadPDF(FilePath, FileName)
	If InFile.Length = 0 Then Return ""
	Dim Identity        	As Boolean
    Dim MoreStreams     	As Boolean = True
    Dim StreamStart     	As Long
	Dim StreamEnd       	As Long
	Dim FilterAt        	As Long
	Dim BufferStart     	As Long
	Dim StreamText      	As String
	Dim PDFTextOut      	As StringBuilder
	Dim EndedWithNewline 	As Boolean = True 
	Dim DecompressedData  	As String
	Dim BTFound 			As Int
	Dim ETFound 			As Int
	
    PDFTextOut.Initialize
	If FindStringInBuffer(0, "Identity-H") >= 0 Then Identity = True
	Do While MoreStreams And BufferStart < InFile.Length	
	   StreamText  = ""
	   StreamStart = FindStringInBuffer(BufferStart, "stream")
	   If StreamStart = -1 Then Exit
       FilterAt    = FindStringInBuffer(StreamStart, "/Filter")	   
	   StreamEnd   = FindStringInBuffer(BufferStart, "endstream")
	   
       If StreamStart >= 0 And StreamEnd > StreamStart  Then
	      StreamStart = StreamStart + 6'Skip to begining and End of the data stream

		  If InFile(StreamStart) = bCR And InFile(StreamStart+1) = bLF Then
		     StreamStart = StreamStart + 2
		  Else
		     If InFile(StreamStart) = bLF Then StreamStart = StreamStart + 1
		  End If
		   
		  If InFile(StreamEnd-2) = bCR And InFile(StreamEnd-1) = bLF Then 
		     StreamEnd = StreamEnd - 2
		  Else 
		     If InFile(StreamEnd-1) = bLF Then StreamEnd = StreamEnd - 1
		  End If
		   
          DecompressedData  = Decompression(StreamStart, (StreamEnd - StreamStart + 1))
		  ' Verify there is at least one BT and ET otherwise do not call ProcessOutput	  
		  If DecompressedData.Length > 0 Then
		     	BTFound = DecompressedData.IndexOf("BT")
		     	ETFound = DecompressedData.IndexOf2("ET", BTFound)
       	     	If BTFound > -1 And ETFound > -1 Then StreamText = ProcessOutput(Identity, DecompressedData)
				If Not(EndedWithNewline) Then PDFTextOut.Append(CRLF) 
    	     	PDFTextOut.Append(StreamText)
			 	EndedWithNewline = EndsWith(StreamText,CRLF)
		  End If

		  BufferStart = StreamEnd + 7		  
	   Else
	      MoreStreams = False
	   End If	   
	Loop
	
	Return PDFTextOut.ToString
End Sub

Sub EndsWith(Text As String, EndCheck As String) As Boolean
	Dim EndText As String = Text.SubString(Text.Length-Min(Text.Length,EndCheck.Length))
	Return EndText.EqualsIgnoreCase(EndCheck)
End Sub