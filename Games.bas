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
	Dim Paused As Boolean, MouseIsMoving As Boolean

	'Angry Tribbles
	Type Tribble(X As Int, Y As Int, SrcX As Int, aType As Int, Angle As Int, Speed As Int)
	Type Bullet(X As Int, Y As Int, Angle As Int)
	Dim TribbleS As List, Bullets As List , BulletSpeed As Int , Level As Int,Lives As Int,TribblesRound As Int, Kills As Int, Turret As Point  ,TurretAngle As Int, TurretTemp As Int
	Dim Overheat As Boolean ,TribbleSize As Int, TribblesOnScreen As Int, TribblesGIF As Bitmap , TurretBMP As Bitmap, Dimensions As Rect, UT As Boolean  'Quadrotriticale
	Dim LastP As Point, TRI_Regular As Int, TRI_Pregnate As Int, TRI_Bomb As Int, TRI_Slow As Int, TRI_Poisoned As Int , TribblePeriods(5) As Point , BulletTemp As Int ,LitterSize As Int, MaxSpeed As Int, Slow As Int
	Dim TRI_Coo As Int, TRI_Cannon As Int, TRI_Fail As Int, TRI_Overheat As Int, XYLOC As Point, NewXYLOC As Point ,TotalTribbles As Int,TRI_Score As Int,TRI_Multiplier As Int,TribbleSound As Int ',PTS(2) As Point 
	TRI_Regular=0:TRI_Pregnate=1:TRI_Bomb=2:TRI_Slow=3:TRI_Poisoned=4: TRI_Coo=5:TRI_Cannon=6: TRI_Fail=7: TRI_Overheat=8
	'scream			snap		boom        weirdnoise scanner         coo        turret       manytribbles  overheat
	
	Dim AudioServer As SoundPool, AudioFiles As List,AudioStreams As Int 
	Dim ToastText As String, ToastPos As Int, ToastSeconds As Int
	Dim CenterPlatform As Bitmap, CenterPlatformID As Int, WasInit As Boolean, UNIFILE As String  'backup universal bmp
	AudioFiles.Initialize 
	
	'PdP stuff				"MARATHON", "PUZZLE", "LINES", "TIMED"
	Dim PdP_Normal As Int, PdP_Puzzle As Int=2, PdP_LineClear As Int=3, PdP_TimeLimit As Int=4, PdP_Edit As Int=1', PdP_Garbage As Int = 5'Game modes
	Dim PdP_MoveUp As Int, PdP_MoveDown As Int=1, PdP_MoveLeft As Int =2, PdP_MoveRight As Int=3 , PdP_Increment As Int=4 , PdP_MoveBoard As Int=5, PdP_DestroyGarbage As Int=6, PdP_DropGarbage As Int=7,PdP_GameOver As Int=8, PdP_Rumble As Int=9, PDP_Paused As Int=10, PDP_ScoreMade As Int=11'Actions
	Dim PDP_Points As Int, PDP_Combo As Int=2, PDP_Chain As Int=1, PDP_CustomLevel As Int = 5, PDP_EndOption As Int ,PDP_Colors As Int = 6
	Type PdPTile(ColorID As Int, Width As Int, Height As Int, X As Float, Y As Float, Z As Int, isClean As Boolean , isChain As Boolean ,Text As String, Alpha As Int, Blinks As Int, IsMoving As Boolean, GhostStage As Int ,GhostStages As Int, isGarbage As Boolean)
	Type PdPGrid(Bottom As Int, IsRunning As Boolean, Tiles(11,12) As PdPTile ,Chains(12) As Point,ChainList As List, isClean As Boolean, ShiftPeriod As Int, TicksRemaining As Int,NeedsDrawing As Boolean,   LastUpdate As Int, TilesRemaining As Int, Cursor As Point,Mouse As Point, Moves As Int,Yoffset As Float,Yoffset2 As Int, Score As Int,Size As Point,BlockSize As Point,PDPwasPaused As Boolean ,GameOver As Int ,PDPStage As Int ,Moving As Int ,LinesRemaining As Int, LinesStarted As Int, LinesToClear As Int , Top As Int, GarbageLines As Int)
	Dim PdP_Width As Int=6, PdP_Height As Int=10, PdP_Grid(1) As PdPGrid ,ThreeDEffect As List ,ThreeDMode As Boolean ,PdPStyle As Int, PdPMode As Int, PDPGarbage As Boolean  ,YouLost As Int=1, YouWon As Int =2,StartGhostStages As Int=12
	Dim PdP_Level As Int=1, PdP_SubLevel As Int=1, PdP_Stack As List ,PDPScreensize As Point ,PDPfontsize As Int, PDPSelectedColor As Int, PDPWasSelected As Int, PDPFilename As String, PDP_Difficulty As Int , PDP_NeedsReset As Boolean 
	Dim PDP_LastUpdate As Int, PDP_Remaining As Int 
	
	'Battle of the Mutara Nebula
	Dim CurrentCode As String,PassCode As String, CurrentStage As Int=-1, YourShields As TweenAlpha,DifficultyLevel As Int, EnemyShields As TweenAlpha , PassGuesses As TweenAlpha , AttackAttempts As TweenAlpha ,GroupID As Int ,SwitchList As Int,Digits As Int,FirstElement As Int,ReliantSound As Int=-1
	
	'3d board games
	Type ThreeDPoint(X As Int, Y As Int, Z As Int)
	Type ThreeDLevel(Loc As ThreeDPoint, Width As Int, Height As Int, Grid As List, Player As Int )
	Type ThreeDPiece(Xoffset As Int, Yoffset As Int, Team As Int, Piece As Int, Uncovered As Boolean, Checked As Boolean, Mark As Boolean, Flag As Boolean)
	Type ThreeDboard(Gametype As Int, Levels As List, Difficulty As Int, Time As Long, ScoreWhite As Int, ScoreBlack As Int, LastUpdate As Long, tCamera As ThreeDPoint, Size As ThreeDPoint, Mines As Int, Flags As Int, TotalTiles As Int, IsMoving As Boolean)
	Dim ThreeD_NoGame As Byte = 0, ThreeD_Minesweeper As Byte = 1, ThreeD_Checkers As Byte = 2, ThreeD_Chess As Byte = 3, ThreeD_TicTacToe As Byte = 4, ThreeDGame As ThreeDboard ,ThreeDSize As Int,ThreeDGridStyle As Int , ThD_GameOver As String
	Dim ThreeD_Menu As List , ThreeD_Queue As List , MIN_Mine As Byte = -1 , ThD_MouseLoc As Point,ThD_GridLoc As Point , ThD_Landscape As Boolean ,ThD_IsScrolling As Boolean ,ThD_Fontsize As Int ,ThD_Screensize As Point 
	Dim ThreeD_Sprites As Bitmap , ThreeD_SelectedMenu As Int, MIN_Immovable As Byte = -1, MIN_Neutral As Byte = -2, MIN_White As Byte = 1, MIN_Black As Byte = 2, ThreeD_ElementID As Int =-1 ,TurnsTaken As Int , LastTurn As ThreeDPoint 
	Dim CHK_Pawn As Int = 0, CHK_King As Int = 1, Player1Type As Byte, Player2Type As Byte, CurrentPlayer As Byte, PT_Local As Byte = 0, PT_Remote As Byte =1, PT_AI As Byte = 2, PT_Server As Byte = 3, AIMoves As List
	Dim CHS_Bishop As Int = 1, CHS_Knight  As Int = 2, CHS_Rook  As Int = 3, CHS_Queen  As Int = 4, CHS_King As Int = 5, Selected3DTile As ThreeDPoint, ThreeD_8589934592 As Byte = 5, ThreeD_Opacity As Int = 128, ThreeD_Dpad As Boolean 
	Dim THD_Angle As Int, THD_Zoom As Float = 1, SavedPoints(5) As Point, SavedZ As Int', tempRet(2) As Float'3D drawing
	ThreeDGame.Initialize 
	ThreeD_Queue.Initialize 
	
	'Card stuff
	Type Card(Loc As tween, Value As Int, Face As Boolean, Suite As Int, Size As Byte, Blink As Boolean, Angle As Int)
	Type Cardpile(Cards As List, X As Int, Y As Int, Style As Int, Selected As Int, Loc As tween, Surface As Int)
	Dim PileList As List, SelectedPile As Int, CARD_Game As Int, CardWidth As Int = 196, CARD_Face As Int = 1, CARD_OldWidth As Int , CARD_ElementID As Int = -1, CARD_MaxX As Int, CARD_MaxY As Int
	Dim CARD_Cash As Int, CARD_NextBet As Int, CARD_Pot As Int, CARD_LastUpdate As Int, CARD_TimePassed As Int , CARD_CurrBid As Long = 1, CARD_DecreasingBid As Boolean 
	Dim CARD_IsWinning As Boolean, CARD_WinningCard As Card, CARD_Factor As Int, CARD_GameOver As Boolean, CARD_Locked As Boolean, CARD_oX As Int, CARD_oY As Int, CARD_X3 As Int, CARD_Y3 As Int
	Dim CARD_X As Int, CARD_Y As Int, CARD_Width As Int, CARD_Height As Int, CARD_Red As Int=2, CARD_Black As Int=15, CARD_Moving As Boolean ,CARD_X2 As Int, CARD_Y2 As Int , CARD_UseMulti As Boolean
	Dim CARD_Invisible = -1, CARD_Deck As Byte, CARD_Dealt As Byte = 1, CARD_Aces As Byte = 2, CARD_Cards As Byte = 3, CARD_Horizontal As Byte = 4, CARD_Scores(4) As Point 
	Dim UndoStack As List, CARD_CanBet As Boolean, CARD_J As Byte = 11, CARD_Q As Byte = 12, CARD_K As Byte = 13, CARD_A As Byte = 14, CARD_TimesDealt As Int, CARD_Heart As Byte = 1, CARD_Diamond As Byte = 2, CARD_Club As Byte = 3, CARD_Spade As Byte = 4, CARD_Turn As Int
	Dim SOL_MaxRotations As Int, SOL_MaxCards As Int=3, SOL_ScoringMethod As Int, SOL_TimedGame As Boolean, SOL_Rotations As Int, SOL_BufferPile As Int'Solitaire stuff
	Dim BLK_HasStayed As Boolean, BLK_Risk As Int = 15 'Blackjack stuff
	Dim PKR_Zilch As Byte = 0, PKR_Pair As Byte = 1, PKR_TwoPair As Byte = 2, PKR_ThreeOfAKind As Byte = 3, PKR_Straight As Byte = 4, PKR_Flush As Byte = 5, PKR_FullHouse As Byte = 6, PKR_FourOfAKind As Byte = 7, PKR_StraightFlush As Byte = 8, PKR_RoyalFlush As Byte = 9 'TwoPair and FullHouse Requires two card values to check, RoyalFlush: A-K-Q-J-10, all same suit
	Dim PRS_Bum As Byte = 0, PRS_ViceBum As Byte = 1, PRS_VicePresident As Byte = 2, PRS_President As Byte = 3, PRS_Rank As Byte, PRS_Passes As Int, PRS_availrank As Byte'President stuff
	Dim HRT_Score As Int = 50, HRT_Unlocked As Byte, HRT_Highest As Int, HRT_Player As Int, HRT_CanPlay As Boolean, HRT_Locked As Boolean 
	
	'Dr. Pulaski stuff
	Type DrP_Tile(Color As Int,Y As Int,Clean As Boolean, Ghost As Int,Viral As Boolean,Bound As Boolean,Angle As Int,bX As Int,bY As Int)
	Type DrP_MiniTile(Color1 As Int,Color2 As Int,X As Int,Y As Int,YOffset As Int,Angle As Int)
	Dim DrP_Text As String, DrP_TextSize As TweenAlpha, DrP_Motion As Boolean, DrP_MotionX As Byte, DrP_DpadRadius As Int', DrP_MotionY As Byte
	Dim DrP_NoAngle As Byte = -1, DrP_RotateTiles As Byte = 6, DrP_LostGame As Byte = 7, DrP_NewFutureTile As Byte = 8, DrP_VirusChanged As Byte = 9, DrP_PulledTile As Byte = 10, DrP_WonGame As Byte = 11, DrP_TilesCleared As Byte = 12, Drp_VirusKilled As Byte = 13, DrP_Assimilated As Byte = 14'Event IDs
	Dim DrP_GridWidth As Byte = 8, DrP_GridHeight As Byte = 16, DrP_Colors As Byte = 3, DrP_GhostFrames As Int = 10, DrP_Gameisover As Boolean = True, DrP_VirusLevel As Byte=1, DrP_VirusDifficulty As Byte, DrP_HighScore As Int,DrP_VirusState As Boolean 'Global Variables
	Dim DrP_Grid(DrP_GridHeight+1, DrP_GridWidth) As DrP_Tile, DrP_CurrentTile As DrP_MiniTile, DrP_FutureTiles As List, DrP_FutureTileCount As Byte = 1, DrP_VirusCounts(5) As Int, DrP_Tiles As Int, DrP_Clean As Boolean,  DrP_Total As Int, DrP_OldVirii As Int, DrP_Locked As Boolean, DrP_CurrentScore As Int, DrP_LastUpdate As Long, DrP_Delay As Int, DrP_PillsPopped As Byte, DrP_LastTilesize As Int 'Per-Player Variables
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

Sub InitAudioPool(Channels As Int)
	If AudioServer.IsInitialized  Then AudioServer.Release
	AudioServer.Initialize(Channels)
	AudioStreams=Channels
	AudioFiles.Initialize 
End Sub

Sub LoadAudioFiles(StartIndex As Int, EndIndex As Int)
	Dim temp As Int
	InitAudioPool(10)
	For temp=StartIndex To EndIndex 
		LoadAudioFile(temp)
	Next
End Sub
Sub LoadAudioFile(Index As Int) As Int
	Dim temp As LCARSound,ret As Int  'FindSound
	temp = LCAR.SoundList.Get(Index)
	ret=AudioServer.Load(temp.Dir , temp.Filename) ' 
	temp.spid=ret
	'Msgbox(File.Combine(temp.Dir,temp.Filename), ret)
	'Log(temp.Name & "=" & ret)
	AudioFiles.Add(ret)
	Return ret
End Sub

Sub LoadAudioFile2(Dir As String, Filename As String)As Int
	If Dir.Length = 0 Then Dir = File.DirAssets
	Dim Ret As Int = AudioServer.Load(Dir, Filename)
	AudioFiles.Add(Ret)
	Return Ret
End Sub

'ID: -1=random
Sub PlayFile(ID As Int)As Boolean 
	Dim Volume As Int 
	If API.ListSize(AudioFiles) = 0 Then Return False 
	If ID= -1 Then ID = Rnd(0,AudioFiles.Size)
	If ID<AudioFiles.Size Then
		Volume=1'LCAR.cVol*0.01
		Return AudioServer.Play( AudioFiles.Get(ID) , Volume,Volume,0,0,1) <> 0
	End If
	Log("Invalid ID given")
End Sub

Sub SetElement18Text(Text As String) 
	LCAR.forceshow(18, True)
	If API.Translation.ContainsKey(Text) Then Text = API.GetString(Text)
	LCAR.LCAR_SetElementText( 18, Text.ToUpperCase  , "")
	LCAR.GetElement(18).Opacity.Current = 255
End Sub
Sub HideToast
	LCAR.HideToast
End Sub
Sub Toast(Text As String)
	If API.Translation.ContainsKey(Text) Then Text = API.GetString(Text)
	LCAR.ToastMessage(LCAR.EmergencyBG, Text,3)
End Sub
Sub SeedSetting(Name As String, Description As String, CurrentValue As String) As Int 
	If API.Translation.ContainsKey(Name) Then Name = API.GetString(Name)
	If API.Translation.ContainsKey(Description) Then Description = API.GetString(Description)
	Return LCAR.LCAR_AddListItem(3, Name, LCAR.LCAR_Random, -1, Description, False, CurrentValue,0,False,-1)
End Sub

Sub HideSideBar(BG As Canvas)
	LCAR.HideSideBar(BG,19,3)
End Sub
Sub ShowSection(Section As Int, GNDN As Boolean)
	LCAR.SystemEvent(0, Section)
End Sub
Sub SeedSideBar(BG As Canvas, Items As List,DoAnimation As Boolean, LeftBar As Boolean )
	LCAR.SeedSideBar(BG,19,Items, DoAnimation, LeftBar, 3)
End Sub












Sub PDP_ShowSubLevel(BG As Canvas, ListID As Int)
	'LCAR.LCAR_AddListItems(3, LCAR.LCAR_Random, 0, Array As String("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"))
	Dim temp As Int,IsDefeated As Boolean, Check As String = "√", Incomplete As String = "×", tempstr As String 
	If PdP_Level=0 Then
		LCAR.LCAR_AddListItem(ListID, API.GetString("pdp_new"), LCAR.LCAR_Random, temp, "", False,  ""  ,0,False,-1)
		For temp = 1 To PDP_CustomLevel -1 
			IsDefeated = PDP_IsLevelClear(temp)
			If ListID = 4 Then tempstr = " " & API.IIF(IsDefeated, Check, Incomplete)
			LCAR.LCAR_AddListItem(ListID, temp & tempstr, LCAR.LCAR_Random, temp, "", False,  API.IIF(IsDefeated, API.GetString("pdp_clear"), "")  ,0,False,-1)
		Next
	Else
		For temp = 1 To 15
			IsDefeated= API.HandleSetting("PdP" & PdP_Level & "-" & temp, False,False,False)
			If ListID = 4 Then tempstr = " " & API.IIF(IsDefeated, Check, Incomplete)
			LCAR.LCAR_AddListItem(ListID, PdP_Level & "-" & temp & tempstr, LCAR.LCAR_Random, temp, "", False,  API.IIF(IsDefeated, API.GetString("pdp_clear"), "")     ,0,False,-1)
		Next
	End If
End Sub

Sub PDP_PuzzleSidebar(BG As Canvas)
	PDP_ShowGameBoard(BG)
	PdP_Grid(0).IsRunning=True
	SeedSideBar(BG, Array As String(API.GetString("side_edit1"), API.GetString("log_side0"), "-1", "+1"), False,True)
	PDP_ShowColorSelector(BG)
	PDPDrawScore(0)
End Sub


Sub PDP_ShowColorSelector(BG As Canvas)
	Dim TextHeight As Int, ScaleMode As Float = LCAR.GetScalemode 
	TextHeight=LCAR.TextHeight(BG,"ABC123")+4
	If LCAR.SmallScreen Then
		LCAR.MoveLCAR(76, 53,TextHeight,-1,65- TextHeight,0,True,True,False)
	Else
		LCAR.MoveLCAR(76, 115*ScaleMode,TextHeight, -1,(130*ScaleMode)- TextHeight, 0,True,True,False)
	End If
	LCAR.ForceShow(76 ,True)
End Sub



Sub PDP_SaveCustom(BG As Canvas, MakeUnique As Boolean )
	If MakeUnique Then PDPFilename = LCARSeffects.UniqueFilename( LCAR.DirDefaultExternal, PDPFilename, "")
	PDPSaveMap(LCAR.DirDefaultExternal,  PDPFilename, 0)
	LCAR.ToastMessage(BG, API.GetString("pdp_saved") & " " & PDPFilename, 3)
End Sub

Sub PDP_ShowGameBoard(BG As Canvas)
	HideSideBar(BG)
	LCAR.LCAR_SetElementText(LCARSeffects.FrameElement+11, API.GetString("pdp_pause"), "")
	LCAR.LCAR_HideElement(BG, 3,True, False,True)
	LCAR.LCAR_HideElement(BG, 4,True, False, True)
	Main.CurrentSection=17'HARDCODED
	PDPStart(0)
	LCAR.ForceShow(74 ,True)
	LCAR.ToastAlign=True
End Sub

Sub PDP_IsLevelClear(MainLevel As Int) As Boolean 
	Dim temp As Int , IsDefeated As Boolean 
	For temp = 1 To 15
		IsDefeated= API.HandleSetting("PdP" & MainLevel & "-" & temp, False,False,False)
		If Not(IsDefeated) Then Return False
	Next
	Return True
End Sub
Sub PDP_StartIndex As Int 
	Select Case PdPMode
		Case PdP_Puzzle, PdP_Edit: Return 0
		Case Else: Return 1
	End Select
End Sub
Sub PDP_Settings(BG As Canvas, Index As Int) As List 
	Dim Items As List 
	Items.Initialize
	Select Case Index
		Case 0'play mode		Dim PdP_Normal As Int, PdP_Puzzle As Int=1, PdP_LineClear As Int=3, PdP_TimeLimit As Int=4, PdP_Edit As Int=2, PdP_Garbage As Int = 5'Game modes
			'Items.AddAll(Array As String("MARATHON", "PUZZLE", "LINES", "TIMED"))
			Items.AddAll(API.getstrings("pdp_mode", 0))
		Case 1,2'garbage
			If PDP_StartIndex > 0 Then Items.AddAll(Array As String(API.getstring("enabled"), API.getstring("disabled"))) 
			
		Case Else
			Index=Index-PDP_StartIndex
			Log(PdPMode & " Index: " & Index)
			Select Case PdPMode
				Case PdP_Normal
					Select Case Index
						Case 1: Items.AddAll(API.getstrings("pdp_diff", 0))'Array As String("EASY", "MEDIUM", "HARD"))
					End Select
				Case PdP_Puzzle
					Select Case Index
						Case 1: Items.AddAll(Array As String(API.getstring("pdp_custom"), "1", "2", "3", "4"))
						Case 2: PDP_ShowSubLevel(BG,4) 'Items.AddAll(Array As String("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"))
					End Select
				Case PdP_LineClear
					Select Case Index
						Case 1: Items.AddAll(API.getstrings("pdp_diff", 0))'  Array As String("EASY", "MEDIUM", "HARD"))
						Case 2: Items.AddAll(Array As String("10", "20", "30", "40", "50"))
					End Select
				Case PdP_TimeLimit
					Select Case Index
						Case 1: Items.AddAll(API.getstrings("pdp_diff", 0))'Array As String("EASY", "MEDIUM", "HARD"))
						Case 2: Items.AddAll(Array As String("1", "2", "5", "10", "15", "20"))
					End Select
			End Select
	End Select
	Return Items
End Sub
Sub PDP_Mode As Int'	"MARATHON", "PUZZLE", "LINES", "TIMED"
	Select Case PdPMode
		Case PdP_Normal: Return 0
		Case PdP_Puzzle,PdP_Edit: Return 1
		Case PdP_LineClear: Return 2
		Case PdP_TimeLimit: Return 3
	End Select
End Sub
Sub PDP_HandleSettings(BG As Canvas, ListID As Int, Index As Int) As Int 
	Dim SettingIndex As Int = Main.SettingIndex, Items As List, Value As String = LCAR.LCAR_GetListitemText(ListID, Index, 0), BoolValue As Boolean = (Index = 0), tempitem As LCARlistitem = LCAR.LCAR_GetListItem(ListID,Index)
	Select Case ListID
		Case 0'seed
			SetElement18Text("sec_17")
			SeedSetting("set-13.0", "pdp_mode", PDP_Settings(BG, 0).get(PDP_Mode) )'listitem 0
			SeedSetting("pdp_garbage", "", API.BoolToText(PDPGarbage))'listitem 0
			If PDP_StartIndex > 1 Then SeedSetting("pdp_3d", "", API.BoolToText(ThreeDMode))'listitem 1
			
			Select Case PdPMode'Dim PdP_Normal As Int, PdP_Puzzle As Int=1, PdP_LineClear As Int=2, PdP_TimeLimit As Int=3, PdP_Edit As Int=4'Game modes
				Case PdP_Normal
					SeedSetting("twok_difficulty", "twok_selectdiff", PDP_Settings(BG, 1).get(PDP_Difficulty))'listitem 0
				Case PdP_Puzzle
					SeedSetting("tri_level", "pdp_level", PdP_Level)
					SeedSetting("pdp_sublevel", "pdp_sublevel_d", PdP_SubLevel)
				Case PdP_LineClear
					If PDP_EndOption = 0 Then PDP_EndOption = 10
					SeedSetting("twok_difficulty", "twok_selectdiff", PDP_Settings(BG, 1).get(PDP_Difficulty))'listitem 0
					SeedSetting("pdp_lines", "pdp_lines_d", PDP_EndOption)
				Case PdP_TimeLimit
					If PDP_EndOption = 0 Then PDP_EndOption = 1
					SeedSetting("twok_difficulty", "twok_selectdiff", PDP_Settings(BG, 1).get(PDP_Difficulty))'listitem 0
					SeedSetting("pdp_min", "pdp_min_d", PDP_EndOption)
			End Select
			SeedSetting("set-6.3", "", "")
			If PdP_Grid(0).IsRunning And PdP_Grid(0).GameOver<1 And Not(PDP_NeedsReset) Then SeedSetting("set-6.4", "", "")
			
			
			
		Case 3'main list
			If Value= API.GetString("set-6.3") Then
				Log("START GAME: " & PdPMode & " " & PdP_Level & " " & PdP_SubLevel)
				PDP_NeedsReset= False
				Select Case PdPMode						
					Case PdP_Puzzle
						PDPClearUndo
						If PdP_Level= 0 Then'custom
							If PdP_SubLevel = 0 Then 'new
								PdPMode = PdP_Edit
								PDPClearGrid(0,True)
								PdP_Grid(0).Moves=1
								PDP_PuzzleSidebar(BG)
								Return 2
							Else
								PDPFilename =  API.GetFile(tempitem.Tag)
								PDPLoadCustom(LCAR.DirDefaultExternal, API.GetFile(tempitem.Tag), 0, True)'API.GetDir(tempitem.Tag)
								PdP_Level=0
								PdP_SubLevel=0
								PDP_PuzzleSidebar(BG)
								SetElement18Text("")
							End If
						Else
							PDPLoadInternal(PdP_Level,PdP_SubLevel,0)
						End If
						
					Case Else 
						PDPSeedBoard(18+ PDP_Difficulty*6, DateTime.TicksPerSecond, 50 - PDP_Difficulty*10, 0, (2-PDP_Difficulty)*5)
						Select Case PdPMode
							Case PdP_TimeLimit: PDP_Remaining = PDP_EndOption * 60
							Case PdP_LineClear: PdP_Grid(0).LinesToClear = PDP_EndOption
						End Select
				End Select
				PDP_ShowGameBoard(BG)
				PDPDrawScore(0)
				Return 2
			Else If Value = API.GetString("set-6.4") Then
				Select Case PdPMode
					Case PdP_Edit
						PDP_PuzzleSidebar(BG) 
					Case Else
						PDP_ShowGameBoard(BG)
				End Select
				PDPDrawScore(0)
				Return 2
			Else
				Items = PDP_Settings(BG, Index)
				If Items.Size > 0 Then
					LCAR.LCAR_AddListItems(4, LCAR.LCAR_Random,0, Items)
					LCAR.LCAR_SetSelectedItem(4, Items.IndexOf(LCAR.LCAR_GetListitemText(3,Index, 1)))
				End If
			End If
			
			
			
		Case 4'sub items
			PDP_NeedsReset = True
			LCAR.LCAR_FindListItem(3, API.GetString("set-6.4"), 0, True, -1)
			If SettingIndex = 0 Then
				PDP_EndOption = 0
				Select Case Value
					Case API.GetString("pdp_mode0"): 	PdPMode = PdP_Normal
					Case API.GetString("pdp_mode1"): 		PdPMode = PdP_Puzzle
					Case API.GetString("pdp_mode2"):		PdPMode = PdP_LineClear
					Case API.GetString("pdp_mode3"):		PdPMode = PdP_TimeLimit
					Case "EDIT":		PdPMode = PdP_Edit
				End Select
				'PdPMode = Index
				Return 1
			Else If PDP_StartIndex > 0 And SettingIndex = 1 Then ' garbage
				PDPGarbage = BoolValue
			Else If PDP_StartIndex > 1 And SettingIndex = 2 Then'3d mode
				ThreeDMode = BoolValue
			Else
				SettingIndex=SettingIndex-PDP_StartIndex
				Select Case PdPMode
					Case PdP_Normal
						Select Case SettingIndex
							Case 1'difficulty
								PDP_Difficulty = Index
						End Select
					Case PdP_Puzzle
						Select Case SettingIndex
							Case 1'level
								PdP_Level = Index
								PdP_SubLevel = 1
								Return 1
							Case 2'sub-level
								If PdP_Level = 0 Then
									PDPFilename = API.GetFile(tempitem.tag)
								Else
									PdP_SubLevel= Index + 1
								End If
						End Select
					Case PdP_LineClear
						Select Case SettingIndex
							Case 1'difficulty
								PDP_Difficulty = Index
							Case 2'lines
								PDP_EndOption = Value
						End Select
					Case PdP_TimeLimit
						Select Case SettingIndex
							Case 1'difficulty
								PDP_Difficulty = Index
							Case 2'minutes
								PDP_EndOption = Value
						End Select
				End Select
			End If
			
			
			
			
		Case 17'sidebar
			If Not(PdPMode= PdP_Edit And Not(Paused) ) Then HideSideBar(BG)
			Select Case PdPMode
				Case PdP_Normal 
					Select Case Index
						Case 0
							ShowSection(17,False)
					End Select
				Case PdP_Edit
					If Paused Then
						Select Case Index
							Case 0:	ShowSection(17,False)
							Case 1: PDPClearGrid(0,True)
						End Select
					Else
						Select Case Index
							Case 0'save
								If PDPTilesRemaining(0,True)=0 Then
									LCAR.PlaySound(0,False)
									LCAR.ToastMessage(BG, API.GetString("pdp_empty"), 3)
								Else
									If PDPFilename.Length=0 Then
										LCARSeffects.ShowPrompt(BG,-10, API.GetString("pdp_name"), API.GetString("pdp_name_d"), 4, API.getstring("kb_ok"), API.getstring("cancel"))
									Else
										PDP_SaveCustom(BG, False)
									End If
								End If
							Case 1'play
								HideSideBar(BG)
								PdPMode = PdP_Puzzle 
								PDPPushUndo(0)
								
							Case 2'-1
								If PdP_Grid(0).Moves>1 Then
									PdP_Grid(0).Moves = PdP_Grid(0).Moves - 1
									PDPDrawScore(0)
								End If
							Case 3'+1
								PdP_Grid(0).Moves = PdP_Grid(0).Moves + 1
								PDPDrawScore(0)
						End Select
					End If
				Case PdP_Puzzle
					If Paused Then
						If Index =0 Then
							ShowSection(17,False)
						Else
							Select Case PdPMode 
								Case PdP_Puzzle 
									Select Case Index
										Case 1:PDPLoadInternal(-1,-1,0)'Retry	
										Case 2:PDPPullUndo(0)'Undo
									End Select
									PDPPause
							End Select
						End If
					Else
						Select Case Index
							Case 0'retry (lose) next (win)
								If PdP_Level =0 Then
									PDPPullFirstUndo(0)
									PdPMode=PdP_Edit 
									PDP_PuzzleSidebar(BG)
								Else
									If PdP_Grid(0).GameOver= YouWon Then
										PdP_SubLevel = PdP_SubLevel+1
										If PdP_SubLevel=16 And PdP_Level < PDP_CustomLevel-1 Then
											PdP_Level =PdP_Level+1
											PdP_SubLevel=1
										End If
									End If
									PDPLoadInternal(PdP_Level,PdP_SubLevel,0)
									PDP_ShowGameBoard(BG)
								End If
							Case 1'
								ShowSection(17,False)
						End Select
					End If
			End Select
	End Select
End Sub

'PdPStyles: -3=ENT -2=TOS -1=TOS Movies 0=TNG/VOY LCARS 1=Nemesis LCARS 2=tcars 3=Klingon 4=Romulan
Sub PDPSetup
	'PDPLoadInternal(3,13,0)
	'PdPStyle=-3
End Sub
'index=gridid, index2=index

Sub PDPClearGrid(GridID As Int, ClearStack As Boolean )
	Dim temp As Int,temp2 As Int, Grid As PdPGrid = PdP_Grid(GridID)
	PDPScreensize.Initialize 
	Grid.Initialize 
	Grid.Cursor = Trig.SetPoint(2,1)
	PDPFilename=""
	LCAR.Stop("CLR")
	If ClearStack Then PDPClearUndo
'	PdP_Grid(GridID).isClean=False
'	PdP_Grid(GridID).Moves=0
'	PdP_Grid(GridID).ShiftPeriod=0
'	PdP_Grid(GridID).TicksRemaining=0
'	PdP_Grid(GridID).TilesRemaining=0
'	PdP_Grid(GridID).Yoffset=0
	Grid.top = 0
	Grid.Score=0
	Grid.GameOver=0
	Grid.IsRunning=False
	'PdP_Grid(GridID).Chains(12).Initialize 
	Grid.ChainList.Initialize 
	For temp = 0 To 11'X
		Grid.Chains(temp)=Trig.SetPoint(0,0)
		For temp2 = 0 To 10'Y
			Grid.Tiles(temp2,temp) = PDPMakeTile(0)
		Next
	Next
End Sub
Sub PDPMakeTile(Color As Int) As PdPTile 
	Dim temp As PdPTile
	temp.Initialize 
	If Color<0 Then Color = Rnd(2,6)
	temp.ColorID=Color
	temp.Height=1
	temp.Width=1
	temp.isChain=False
	temp.isClean=False
	temp.X=0
	temp.Y=0
	temp.Z=0
	temp.Alpha=255
	If Color>0 Then temp.Text = LCARSeffects2.RandomNumber(3,True)
'		If PdPStyle=-3 Then
'			temp.Text=LCARSeffects2.RandomENT
'		Else
'			temp.Text = LCARSeffects2.RandomNumber(4)
'		End If
'	End If
	Return temp
End Sub




Sub PDPLoadInternal(Stage As Int, SubStage As Int, GridID As Int)As Boolean 
	If Stage<0 Then Stage = PdP_Level
	If SubStage<0 Then SubStage=PdP_SubLevel
	If Stage=0 Or SubStage = 0 Then
		PDPPullFirstUndo(GridID)
	Else
		PdP_Level=Stage
		PdP_SubLevel=SubStage
		Return PDPLoadCustom(File.DirAssets, Stage & "-" & SubStage & ".pon",GridID, True)
	End If
End Sub
Sub PDPEnumCustomLevels(ListID As Int)
	Dim temp As Int 
	LCAR.LCAR_AddListItem(ListID, API.GetString("pdp_new"), LCAR.LCAR_Orange, -1, "", True, "", 0, False,-1)
	temp= PDPEnumCustomDir(ListID, LCAR.DirDefaultExternal,1)
	temp=PDPEnumCustomDir(ListID, File.DirInternal,temp)
	PDPEnumCustomDir(ListID, File.DirRootExternal,temp)
End Sub
Sub PDPEnumCustomDir(ListID As Int, Dir As String, temp2 As Int)As Int
	Dim temp As Int, templist As List, tempstr As String 
	templist = File.ListFiles(Dir)
	For temp = 0 To templist.Size-1
		tempstr = templist.Get(temp)
		If tempstr.EndsWith(".pon") Then
			LCAR.LCAR_AddListItem(ListID, API.Left(tempstr, tempstr.Length-4), LCAR.LCAR_Random, temp2, File.Combine(Dir, tempstr), False, "", 0, False, -1)
			temp2=temp2+1
		End If
	Next
	Return temp2
End Sub





Sub PDPSeedBoard(Tiles As Int, Period As Int,Lines As Int, GridID As Int, GarbageLines As Int )
	Dim Grid As PdPGrid = PdP_Grid(GridID)
	PDPClearGrid(GridID, True)
	Do Until Tiles =0 
		PDPRandomTile(GridID)
		Tiles=Tiles-1
	Loop
	PdPStyle=0
	PDPfontsize=0
	PDPRandomizeCache(GridID)
	Grid.IsRunning=True
	Grid.ShiftPeriod=Period
	Grid.TicksRemaining=Period
	Grid.LinesRemaining=Lines
	Grid.LinesStarted=Lines
	If API.debugMode Then GarbageLines = 4
	Grid.GarbageLines = GarbageLines
End Sub

'if filename is empty, it'll load dir as if it's the contents of a file
Sub PDPLoadCustom(Dir As String, Filename As String, GridID As Int, ClearStack As Boolean )As Boolean 
	Dim tempstr() As String ,tempstr2() As String ,temp As Int,temp2 As Int, Grid As PdPGrid = PdP_Grid(GridID)
	If Filename.Length=0 Then
		tempstr = Regex.Split(CRLF, Dir)
	Else If Dir.Length=0 Then
		tempstr = Regex.Split(CRLF, Filename)
	Else
		If File.Exists(Dir,Filename) Then tempstr = Regex.Split(CRLF, File.ReadString(Dir, Filename))
	End If
	If tempstr.Length>0 Then 
		PDPClearGrid(GridID, ClearStack)
		'tempstr = GridWidth & "," & GridHeight & "," & Mode & "," & Moves & "," & Lines & "," & Score & "," & PixelSpeed & vbNewLine
		tempstr2= Regex.Split(",", tempstr(0))
		ThreeDMode = tempstr2(0)>6
		PdPMode=tempstr2(2)		
		Grid.Moves = tempstr2(3)
		Grid.linesremaining= tempstr2(4)
		Grid.LinesStarted=Grid.linesremaining
		Grid.Score = tempstr2(5)
		Grid.ShiftPeriod=tempstr2(6)
		Grid.TicksRemaining=Grid.ShiftPeriod
		If PdPMode=PdP_Puzzle Or PdPMode=PdP_Edit Then Grid.ShiftPeriod=0
		Grid.IsRunning=True
		'Msgbox(PdPMode & CRLF & ThreeDMode & CRLF & Grid.Moves & CRLF & Grid.linesremaining & CRLF & Grid.Score & CRLF & Grid.ShiftPeriod, "TEST")
		For temp = 1 To tempstr.Length-1'X
			tempstr2= Regex.Split(",", tempstr(temp))
			For temp2 = 0 To tempstr2.Length-1'Y
				If tempstr2(temp2) > "0" Then Grid.TilesRemaining = Grid.TilesRemaining+1
				Grid.Tiles(temp2,temp-1) = PDPMakeTile( tempstr2(temp2))
			Next
		Next
		PDPDrawScore(GridID)
	End If
End Sub
Sub PDPSaveMap(Dir As String, Filename As String, GridID As Int) As String 
	Dim tempstr As StringBuilder, C As String ,temp As Int,temp2 As Int, Tile As PdPTile , Grid As PdPGrid = PdP_Grid(GridID)
	C=","
	tempstr.Initialize 
	tempstr.Append(PdP_Width & C & PdP_Height & C & PdPMode & C & Grid.Moves & C & Grid.linesremaining & C & Grid.Score & C & Grid.ShiftPeriod)
	For temp = 0 To PDP_GridWidth - 1
		tempstr.Append(CRLF)
		For temp2 = 0 To PdP_Height
			Tile= PDPGetTile(temp,temp2,GridID)
			tempstr.Append(Tile.ColorID & API.IIF(temp<PdP_Height, C, ""))
		Next
	Next
	If Dir.Length>0 And Filename.Length >0 Then File.WriteString(Dir,Filename, tempstr.ToString )
	Return tempstr.ToString 
End Sub


Public Sub PDPGhostGarbage(X As Int, Y As Int, GridID As Int, ColorID As Int, Start As Boolean) As Boolean 
	Dim Tile As PdPTile, Garbage As Rect, GridWidth As Int = PDP_GridWidth
	If PDPGarbage Then
		If Start Then
			PDPGhostGarbage(X-1,Y, GridID, ColorID, False)
			PDPGhostGarbage(X+1,Y, GridID, ColorID, False)
			PDPGhostGarbage(X,Y-1, GridID, ColorID, False)
			PDPGhostGarbage(X,Y+1, GridID, ColorID, False)
		Else If X >-1 And Y>0 And X< GridWidth And Y < 11 Then
			Garbage = PDPGarbageSrc(X,Y,GridID,0)
			If Garbage.IsInitialized Then
				Tile = PDPGetTile(Garbage.Left, Garbage.Top,GridID)
				If Tile.ColorID = ColorID Then' PDPDestroyGarbage(X,Y,GridID)
					PDPGhostTile(Garbage.Left, Garbage.Top,GridID, StartGhostStages)
				End If
			End If
		End If
	End If
	Return False 
End Sub

Sub PDPGhostTile(X As Int, Y As Int, GridID As Int, GhostStages As Int )
	Dim Tile As PdPTile, Grid As PdPGrid = PdP_Grid(GridID)
	Tile = PDPGetTile(X,Y,GridID)
	If Tile.GhostStage=0 Then
		Tile.isMoving=True 
		Tile.GhostStages=GhostStages
		Grid.Moving=Grid.Moving+1
		Tile.GhostStage=1
		PDPGhostGarbage(X,Y, GridID, Tile.ColorID, True)
		PDPAddScore(GridID, 10)
		PDPPushEvent(GridID, PDP_ScoreMade, PDP_Points, 10,Grid.Score,0,0)
		PDP_TestLine(Y,GridID)
	End If
End Sub
Sub PDPStart(GridID As Int)
	Paused=False
	PdP_Grid(GridID).LastUpdate = DateTime.Now
End Sub
Sub PDPAddScore(GridID As Int, Points As Int)
	Dim Grid As PdPGrid = PdP_Grid(GridID)
	Grid.Score = Grid.Score+Points
	PDPDrawScore(GridID)
End Sub

Sub PDPDrawScore(GridID As Int)
	If GridID = 0 Then
		Dim Grid As PdPGrid = PdP_Grid(GridID), tempstr As String = API.GetString("pdp_score") & ": " & Grid.Score
		If Grid.GameOver <1 Then 
			Select Case PdPMode
				Case PdP_Puzzle
					tempstr= Grid.Moves & " " & API.getstringvars("pdp_moves", Array As String(API.Plural(Grid.Moves, "", API.GetString("plural"))))
				Case PdP_TimeLimit
					tempstr = tempstr & " " & API.GetString("date_time") & ": " & API.GetTime(PDP_Remaining)
				Case PdP_LineClear
					tempstr = tempstr & " " & API.getstring("pdp_lines") & ": " & Grid.LinesToClear
				'Case PdP_Normal'GNDN
			End Select
		End If
		SetElement18Text(tempstr)
	End If
End Sub

Sub PDPIncrement(GridID As Int)As Boolean 
	Dim MaxX As Int, temp As Int, temp2 As Int , Tile As PdPTile ,Checkit As Boolean ,MovedOne As Boolean , OnY As Boolean , Rumble As Boolean ,TilesTotal As Int, Grid As PdPGrid = PdP_Grid(GridID), NeedsGarbage As Boolean 
	If Paused Or Grid.GameOver>0 Then
		Grid.PDPStage=Grid.PDPStage+1
		If Grid.PDPStage=LCARSeffects.OkudaStages Then Grid.PDPStage = 0
		Grid.isClean=False
	Else	
		Grid.Moving=0
		MaxX=PDP_GridWidth'API.IIF(ThreeDMode,11, 5)
		Grid.Bottom =0
		For temp = 0 To 10'Y
			For temp2 = 0 To MaxX-1'X
				Tile= Grid.Tiles(temp,temp2)
				If Tile.ColorID>0 Then Grid.Bottom = temp
				If Tile.GhostStage>0 Then
					Tile.GhostStage = Tile.GhostStage+1
					Tile.isClean=False
					MovedOne=True
					Grid.Moving=Grid.Moving+1
					If Tile.GhostStage >= Tile.GhostStages Then 
						Tile.Alpha = LCAR.Increment(Tile.Alpha, 16,0)
						If Tile.Alpha<=0 Then NeedsGarbage = PDPRemoveTile(temp2,temp,GridID)
					End If
				Else
					Checkit=False
					OnY=False
		'			If Tile.ColorID=0 Then
		'				Tile.X=0 
		'				Tile.Y=0
		'			Else
					If Tile.X<0 Then 	
						Tile.isMoving=True:Grid.Moving=Grid.Moving+1
						Tile.X=Tile.X+0.1
						If Tile.X>=0 Then Tile.X=0 : Checkit=True: PDPDropColumn(temp2-1,temp,GridID)
					Else If Tile.X>0 Then 
						MovedOne=True:Grid.Moving=Grid.Moving+1
						Tile.X= Tile.X-0.1
						If Tile.X<=0 Then Tile.X=0 : Checkit=True: PDPDropColumn(temp2+1,temp,GridID)
					Else If Tile.Y<0 Then 
						MovedOne=True:Grid.Moving=Grid.Moving+1
						Tile.y=Tile.y+0.1
						If Tile.y>=0 Then Tile.y=0 : Checkit=True:OnY=True
					Else If Tile.Y>0 Then 
						MovedOne=True:Grid.Moving=Grid.Moving+1
						Tile.X=Tile.X-0.1
						If Tile.y<=0 Then Tile.y=0 : Checkit=True:OnY=True
					End If
					If Checkit Then
						NeedsGarbage = True
						Tile.isClean=False
						If Tile.X=0 And Tile.Y=0 And Not(Tile.isGarbage) Then 
							TilesTotal=TilesTotal+PDPCheckTile(temp2,temp, OnY, GridID)
							If Tile.isMoving Then 
								If Tile.GhostStage>0 And OnY Then Rumble=True
							Else
								If  Tile.GhostStage=0 Then Grid.Moving=Grid.Moving-1
								Rumble=OnY
							End If
						End If
					End If
				End If
			Next
		Next
		If NeedsGarbage Then PDP_DropAll(GridID)
		'combo/chain test
		PDPCombo(PDP_Combo, TilesTotal,GridID)
		PDPCombo(PDP_Chain, PDPCheckChain(GridID),GridID)
		'End If
		
		If Grid.LastUpdate=0 Then 
			Grid.LastUpdate = DateTime.Now
		Else If Grid.ShiftPeriod>0 And PdPMode <> PdP_Puzzle Then
			temp = DateTime.Now-Grid.LastUpdate  
			Grid.TicksRemaining= Grid.TicksRemaining-temp
			Grid.LastUpdate = DateTime.Now
			If Grid.TicksRemaining< 0 Then 
				Grid.TicksRemaining = Grid.TicksRemaining + Grid.ShiftPeriod
				Grid.Yoffset = Grid.Yoffset- 0.1
				If Grid.Yoffset <= -1 Then PDPShiftUp(GridID, True)
			End If
		Else If MovedOne And Grid.Moving=0 And Grid.GameOver<1 Then
			If PdPMode = PdP_Puzzle And Grid.Moves=0 Then  
				Grid.TilesRemaining = PDPTilesRemaining(GridID,True)
				PDPGameOver(Grid.TilesRemaining =0,GridID)
			End If
		End If
	End If
	If Rumble Then	PDPPushEvent(GridID, PdP_Rumble	, 0,0,0,0,0)
	If Grid.PDPwasPaused <> Paused Then	 
		Grid.isClean=False
		If Grid.GameOver<1 Then PDPPushEvent(GridID, PDP_Paused, API.IIF(Paused,1,0),0,0,0,0)
		Grid.PDPwasPaused = Paused 
	End If
	Return MovedOne
End Sub

Sub PDPCheckChain(GridID As Int) As Int
	Dim temp As Int, temp2 As Int, Grid As PdPGrid = PdP_Grid(GridID) 
	For temp = 0 To PDP_GridWidth - 1'X
		'temp2 = Max(temp2, PDPisColMoving(temp, GridID))
		If Grid.Chains(temp).Y>0 Then
			If PDPisChainMoving( Grid.Chains(temp).Y , GridID, False) = 0 Then
				temp2= PDPisChainMoving( Grid.Chains(temp).Y , GridID, True)
				Log("CHAIN ID: " & Grid.Chains(temp).Y & " is not moving, has a value of " & temp2)
				PDPClearChain(Grid.Chains(temp).Y,GridID)
			End If
		End If
	Next
	Return temp2
End Sub
Sub PDPisColMoving(X As Int, GridID As Int)As Boolean 
	Dim y As Int, Tile As PdPTile ,Moving As Boolean 
	For y = 1 To 10
		Tile=PDPGetTile(X,y,GridID)
		If PDPisTileMoving(Tile) Then' Tile.isMoving Then
			y=11
			Moving=True
		End If
	Next
	Return Moving
	'If Not(Moving) Then
		'y=PdP_Grid(GridID).Chains(X)
		'PdP_Grid(GridID).Chains(X) = Trig.SetPoint(0,0)
		'Return y
	'End If
	'Return 0
End Sub

Sub PDPisChainMoving(ChainID As Int,GridID As Int, GetCount As Boolean) As Int 
	Dim temp As Int,Count As Int, Grid As PdPGrid = PdP_Grid(GridID)
	For temp = 0 To PDP_GridWidth-1'X
		If Grid.Chains(temp).Y = ChainID Then
			If GetCount Then
				'Count = Max(Grid.Chains(temp).X, Count)
				Count = PDPGetChainValue(ChainID, GridID)
			Else If PDPisColMoving(temp,GridID) Then 'Return True
				Return 1
			End If
		End If
	Next
	Return Count
End Sub
Sub PDPClearChain(ChainID As Int, GridID As Int)
	Dim temp As Int, Grid As PdPGrid = PdP_Grid(GridID)
	For temp = 0 To PDP_GridWidth-1'X
		If Grid.Chains(temp).Y = ChainID Then
			Grid.Chains(temp) = Trig.SetPoint(0,0)
		End If
	Next
	If ChainID = Grid.ChainList.Size Then
		Grid.ChainList.RemoveAt(ChainID-1)
	Else
		Grid.ChainList.Set(ChainID-1,0)
	End If
End Sub
Sub PDPGetChainID(GridID As Int,X As Int, Width As Int,  Clear As Boolean )As Int
	Dim temp As Int, Grid As PdPGrid = PdP_Grid(GridID)
	If Clear Then 
		Grid.Chains(12).X = 0
		Grid.ChainList.Clear 
	Else
		'MaxX=API.IIF(ThreeDMode,11, 5)
		For temp = X To X+Width-1'X
			If Grid.Chains(temp).Y>0 Then Return Grid.Chains(temp).Y
		Next
		Grid.ChainList.Add(0)
		Return Grid.ChainList.Size
		'PdP_Grid(GridID).Chains(12).X = PdP_Grid(GridID).Chains(12).X+1
		'Return PdP_Grid(GridID).Chains(12).X
	End If
End Sub
Sub PDPGetChainValue(ChainID As Int, GridID As Int) As Int 
	If ChainID <= PdP_Grid(GridID).ChainList.Size Then Return PdP_Grid(GridID).ChainList.Get(ChainID-1)
End Sub
Sub PDPSetChainValue(ChainID As Int, Value As Int, GridID As Int)
	If ChainID <= PdP_Grid(GridID).ChainList.Size Then PdP_Grid(GridID).ChainList.set(ChainID-1, Value)
End Sub





Sub PDPisTileMoving(Tile As PdPTile) As Boolean 
	Return Tile.ColorID>0 And (Tile.X<> 0 Or Tile.Y<> 0 Or Tile.GhostStage <> 0 Or Tile.isMoving )
End Sub

Sub PDPPushEvent(Index_GridID As Int, ElementType_Event As Int, Index2_Index As Int, X_Index2 As Int, Y_Index3 As Int, X2_Index4 As Int, Y2_Index5 As Int)
	LCAR.PushEvent(ElementType_Event, Index_GridID, Index2_Index, X_Index2, Y_Index3,X2_Index4,Y2_Index5, LCAR.LCAR_PdP) 
End Sub
Sub PDPTilesRemaining(GridID As Int,AbortAt1 As Boolean )As Int
	Dim temp As Int, temp2 As Int, Tile As PdPTile , MaxX As Int=PDP_GridWidth ,Tiles As Int, Grid As PdPGrid = PdP_Grid(GridID)
	For temp = 0 To 10'Y
		For temp2 = 0 To MaxX-1'X
			Tile= Grid.Tiles(temp,temp2)
			If Tile.ColorID>0 And Tile.GhostStage=0 Then 
				Tiles=Tiles + 1
				If AbortAt1 Then Return 1
			End If
		Next
	Next
	Return Tiles
End Sub
Sub PDPCombo(Mode As Int, TilesTotal As Int,GridID As Int)
	Dim mintiles As Int
	mintiles=API.IIF(Mode = PDP_Chain, 1,3) 
	If TilesTotal>mintiles  Then
		'If Mode = PDP_Chain Then Log("Chain made: " & TilesTotal)''If MovedOne Then' AND PdP_Grid(GridID).Moving=0
		PDPHold(TilesTotal-mintiles, GridID)
		PDPPushEvent(GridID, PDP_ScoreMade, Mode, TilesTotal,0,0,0)
		mintiles= PDPPoints(Mode,TilesTotal)
		PDPAddScore(GridID,mintiles)
		PDPPushEvent(GridID, PDP_ScoreMade, PDP_Points, mintiles,PdP_Grid(GridID).Score,0,0)
	End If
End Sub
Sub PDPPoints(Mode As Int, Tiles As Int) As Int
	Dim temp As Int ,Points As Int, temp3 As Int ,Start As Int ,Add As Int 
	'combos
	'4=100 pts 
	'5=240 pts (140)
	'6=390 pts (150)
	'7=550 pts (160)
	
	'chain
	'2=50 pts
	'3=180 pts (130)
	If Mode = PDP_Combo Then
		Points=100
		temp3=140
		Start=5
		Add=10
	Else
		Points=50
		temp3=130
		Start=3
		Add=20
	End If
	For temp = Start To Tiles
		temp3=temp3+Add
		Points=Points+temp3
	Next
	Return Points
End Sub
Sub PDPHold(Seconds As Int, GridID As Int)
	If Seconds>0 Then PdP_Grid(GridID).TicksRemaining = PdP_Grid(GridID).TicksRemaining + DateTime.TicksPerSecond*Seconds
End Sub

Sub PDPGetTile(X As Int, Y As Int, GridID As Int) As PdPTile 
	Dim Tile As PdPTile 
	If X>-1 And X< 12 Then
		If Y>-1 And Y<11 Then
			Tile = PdP_Grid(GridID).Tiles(Y,X)
		End If
	End If
	Return Tile
End Sub
Sub PDPDropColumn(X As Int, Y As Int, GridID As Int) 
	'PDPDropTile (X, Y, GridID)
	For Y = Y To PdP_Height
        PDPDropTile (X, Y, GridID)
		If PDPGarbage Then PDPGarbageSrc(X,Y,GridID,PdP_DropGarbage)
    Next
End Sub
Sub PDPRemoveTile(X As Int, Y As Int, GridID As Int) As Boolean 
	Dim Grid As PdPGrid = PdP_Grid(GridID), Tile As PdPTile = Grid.Tiles(Y,X)
	If Tile.isGarbage Then
		Log("PDPRemoveTile")
		PDPDestroyGarbage(X,Y,GridID)
	Else
		Grid.TilesRemaining = Grid.TilesRemaining-1
		Grid.Moving=Grid.Moving-1
		Grid.Tiles(Y,X) = PDPMakeTile(0)
		PDPDropColumn(X,Y+1,GridID)
		'If PdPMode = PdP_Puzzle AND PdP_Grid(GridID).TilesRemaining =0 Then  PdP_Grid(GridID).GameOver = YouWon
		Return True
	End If
End Sub
Sub PDPDropTile(X As Int, Y As Int, GridID As Int)As Boolean 
	Dim Tile As PdPTile,WasMoving As Boolean, Grid As PdPGrid = PdP_Grid(GridID),Garbage As Rect
	Tile = PDPGetTile(X,Y,GridID)' PdP_Grid(GridID).Tiles(Y,X)
	If PDPGarbage And Not(Tile.IsInitialized) Then
		Log("Garbage mode: no tile found above")
		Garbage = PDPGarbageSrc(X,Y,GridID,0)
		If Garbage.IsInitialized Then Tile = PDPGetTile(Garbage.Left,Garbage.Top,GridID)
	End If
	If Tile.IsInitialized Then		
		WasMoving=Tile.isMoving
		Tile.isMoving=False
		If PDPBottom(X,Y,GridID)< Y And Tile.X=0 And Tile.Y=0 And Tile.ColorID>0 And Tile.GhostStage=0 Then
			If PDPGarbage Then
				If Tile.isGarbage Then 
					If Not(PDP_CanDropGarbage(X, Y, GridID)) Then Return False 'The the tile is a garbage block, and cant fall, exit this sub
				Else If PDP_IsGarbage(X, Y - 1, GridID) Then 
					Return False 'if the tile underneath is occupied by garbage then exit sub
				End If
			End If 
		
			Tile.isMoving=True
			Tile.isClean=False
			Tile.Y=-1
			Grid.Tiles(Y-1,X)=Tile
			Grid.Tiles(Y,X) = PDPMakeTile(0)
			If Not(WasMoving) Then Grid.Moving=Grid.Moving+1
			If Not(PDPDropTile(X,Y+1,GridID)) Then PDP_TestLine(Y,GridID)
'				If PDP_IsRowEmpty(Y, GridID) Then 
'					Grid.Top = Grid.Top - 1
'					Grid.LinesToClear = Grid.LinesToClear - 1
'					If Grid.LinesToClear = 0 Then Grid.GameOver = YouWon
'					PDPDrawScore(GridID)
'				End If
			Return True
		End If
	End If
	Return False 
End Sub
Sub PDP_Top(GridID As Int) As Int 
	Dim Grid As PdPGrid = PdP_Grid(GridID), Y As Int
	For Y = Grid.top To 0 Step -1
		If PDP_IsRowEmpty(Y, GridID) Then
			Grid.top = Grid.top - 1
		Else
			Return Grid.top
		End If
	Next
	Return Grid.top
End Sub
Sub PDP_TestLine(Y As Int, GridID As Int) 
	Dim Grid As PdPGrid = PdP_Grid(GridID)
	'Msgbox(Y & " " & Grid.top, PDP_IsRowEmpty(Y, GridID))
	If Y >= Grid.Top Then 'AND PdPMode = PdP_LineClear Then  
		If PDP_IsRowEmpty(Y, GridID) Then 
			Grid.Top = PDP_Top(GridID)
			If PdPMode = PdP_LineClear Then  
				Grid.LinesToClear = Grid.LinesToClear - 1
				If Grid.LinesToClear = 0 Then Grid.GameOver = YouWon
				PDPDrawScore(GridID)
			End If
		End If
	End If
End Sub
Sub PDP_GridWidth() As Int
	Return API.IIF(ThreeDMode,12, 6)
End Sub

Sub PDP_IsRowEmpty(Y As Int, GridID As Int) As Boolean 
	Dim Grid As PdPGrid = PdP_Grid(GridID), x As Int, MaxX As Int = PDP_GridWidth, Tile As PdPTile 
	For x= 0 To MaxX 
		Grid.Chains(x)=Trig.SetPoint(0,0)
		Tile = PDPGetTile(x,Y,GridID)
		If Tile.ColorID>0 And Tile.GhostStage=0 Then Return False
	Next
	Return True
End Sub
Sub PDPBottom(X As Int, Y As Int, GridID As Int)As Int 
	Dim temp As Int, Garbage As Rect ,Tile As PdPTile, Grid As PdPGrid = PdP_Grid(GridID)
	Garbage=PDPGarbageSrc(X,Y,GridID,0)
	If Garbage.IsInitialized Then Y = Y - (Garbage.Bottom) '+ 1
	For temp = Y - 1 To 0 Step -1
		Tile = Grid.Tiles(temp,X)
		If PDPGarbageSrc(X,temp,GridID,0).IsInitialized Or Tile.ColorID > 0 Or temp = 0 Then
            Return temp + 1
		End If
	Next
	Return 1
End Sub

Sub PDP_IsTileOccupied(GridID As Int, X As Int, Y As Int) As Boolean 
	Dim Grid As PdPGrid = PdP_Grid(GridID), tempTile As PdPTile = Grid.Tiles(Y,X) 
	If tempTile.ColorID > 0 Then Return True
	If PDPGarbage Then Return PDP_IsGarbage(X,Y,GridID) 
	Return False 
End Sub
Sub PDP_DropAll(GridID As Int) As Boolean 
	Dim X As Int, Y As Int, Grid As PdPGrid = PdP_Grid(GridID), GridWidth As Int = PDP_GridWidth, tempTile As PdPTile
	If PDPGarbage Then
		For Y = 1 To 10'Y'Y
			For X = 0 To GridWidth-1'X
				tempTile = Grid.Tiles(Y,X)
				If tempTile.isGarbage Then	PDPDropTile(X,Y,GridID)	
			Next
		Next
	End If
	Return False 
End Sub
Sub PDP_CanDropGarbage(X As Int,Y As Int, GridID As Int) As Boolean 
	Dim temp As Int, Grid As PdPGrid = PdP_Grid(GridID), tempTile As PdPTile = Grid.Tiles(Y,X), CanDropGarbage As Boolean, Garbage As Rect 
	If tempTile.ColorID = 0 And PDPGarbage Then 
		Garbage = PDPGarbageSrc(X,Y,GridID,0)
		If Garbage.IsInitialized Then tempTile = Grid.tiles(Garbage.Top, Garbage.Left)
	End If
	If tempTile.isGarbage Then
		Y=Y-tempTile.Height
        CanDropGarbage = True
        For temp = X To X + tempTile.Width - 1
            If PDP_IsTileOccupied(GridID, temp, Y) Then CanDropGarbage=False'Return False
			'Log("Checking " & temp & ", " & Y & " = " & PDP_IsTileOccupied(GridID, temp, Y))
        Next
	End If
    Return CanDropGarbage
End Sub
Sub PDP_IsGarbage(X As Int,Y As Int, GridID As Int) As Boolean 
	If Not(PDPGarbage) Then Return False
	Dim Garbage As Rect = PDPGarbageSrc(X,Y,GridID,0)', Tile As PdPTile 
	Return Garbage.IsInitialized' Then Return True
		'Tile = pdpgettile(Garbage.Left, Garbage.Top, gridid)
		'Return Tile.X <= X AND Tile.Y <= Y AND Tile.X + Tile.Width -1 >=X AND Tile.y + Tile.Height -1 >= Y 
	'End If
End Sub
Sub PDPGarbageSrc(X As Int,Y As Int, GridID As Int, Action As Int) As Rect 
	Dim temp As Int, temp2 As Int ,temprect As Rect, Tile As PdPTile, Grid As PdPGrid = PdP_Grid(GridID) 
	If PDPGarbage Then
		For temp = 1 To 10'Y'Y
			For temp2 = 0 To X'X
				Tile = Grid.Tiles(temp,temp2)
				If Tile.ColorID>0 And (Tile.Width>1 Or Tile.Height>1)  Then
					If temp2+Tile.Width -1 >= X Then
						If temp >= Y And temp-Tile.height +1 <= Y Then
							Select Case Action
								Case PdP_DropGarbage
									PDPDropTile(temp, temp2, GridID)
								Case PdP_DestroyGarbage
									Log("PDPGarbageSrc")
									PDPDestroyGarbage(temp, temp2, GridID)
							End Select
							temprect.Initialize(temp2,temp,  Tile.Width,Tile.Height)
							Return temprect'Trig.SetRect(temp2,temp,  Tile.Width,Tile.Height)
						End If
					End If
				End If
			Next
		Next
	End If
	Return temprect
End Sub

Sub PDPWillItMakeAScore(X As Int, Y As Int, Color As Int, GridID As Int) As Boolean 
	Dim temp As Rect 
	If Color>0 Then
		temp=PDPFindConcurrentAxis(X,Y,Color,GridID)
		Return temp.Left+temp.Right+1 >2 Or temp.Top+temp.Bottom+1>2 
	End If
	Return False
End Sub

Sub PDPFindConcurrentAxis(X As Int, Y As Int, Color As Int,GridID As Int ) As Rect
	Dim temp As Rect 
	temp.Initialize( PDPFindConcurrentTiles(X,Y, Color, True,True,GridID), PDPFindConcurrentTiles(X,Y, Color, False,False,GridID), PDPFindConcurrentTiles(X,Y, Color, False,True,GridID) ,PDPFindConcurrentTiles(X,Y, Color, True,False,GridID))
	Return temp
End Sub
Sub PDPFindConcurrentTiles(X As Int, Y As Int, Color As Int, IsLeftDown As Boolean, IsX As Boolean, GridID As Int  )As Int
	Dim theMax As Int= PDP_GridWidth-1, Tiles As Int ,Tile As PdPTile 
	If Color=-1 Then Color=PDPGetTile(X,Y,GridID).ColorID
	Do Until X<0 Or Y<1 Or X> theMax Or Y>10
		If IsX Then
			X=PDPPlusOne(X,IsLeftDown)
		Else
			Y=PDPPlusOne(Y,IsLeftDown)
		End If
		If Y>0 Then
			Tile = PDPGetTile(X,Y,GridID)
			If Tile.IsInitialized Then
				If (Tile.ColorID = 1 Or Tile.ColorID = Color) And (Tile.X=0 And Tile.Y=0) And Tile.GhostStage = 0 And Not(Tile.isGarbage) Then
				'If (Tile.ColorID = 1 Or Tile.ColorID = Color) And (Tile.X=0 And Tile.Y=0) And Tile.GhostStage<= Tile.GhostStages And Not(Tile.isGarbage) Then
					Tiles=Tiles+1
				Else
					X=-1
				End If
			Else
				X=-1
			End If
		Else
			X=-1
		End If
	Loop
	Return Tiles
End Sub
Sub PDPPlusOne(X As Int, IsLeft As Boolean) As Int
	If IsLeft Then Return X-1 Else Return X+1
End Sub

Sub PDPCheckTile(X As Int, Y As Int, Fell As Boolean , GridID As Int) As Int
	Dim Tile As PdPTile, temp As Rect, TilesX As Int, TilesY As Int, TilesTotal As Int, ChainID As Int, DoChain As Boolean, Grid As PdPGrid = PdP_Grid(GridID)', X2 As Int
	If PdPMode <> PdP_Edit Then 
		DoChain=True
		Tile= Grid.Tiles(Y, X)
		If Tile.ColorID=0 Then
			PDPDropColumn(X,Y, GridID)
		Else If Not(PDPDropTile(X,Y,GridID)) Then
			temp=PDPFindConcurrentAxis(X,Y,-1, GridID )
			TilesX = temp.Left+temp.Right+1
			TilesY = temp.Top+temp.Bottom+1
			'Log( X & "," & Y & " X from: " & temp.Left & " TO " & temp.Right & " Y from: " & temp.bottom & " TO " & temp.top)
			If TilesX >2 Then
				TilesTotal=TilesX
				'X2=X-temp.Left
				ChainID= PDPGetChainID(GridID,X-temp.Left, TilesX,False) ' X+temp.Right-X2,False) 'temp.Right,  False)
				'Log( X & "X SCORE FROM " & (X-temp.Left) & " TO " & (X+temp.Right ) & " Tiles: " &  TilesX)
				PDPGhostTiles(X,Y, temp.Left,temp.Right , 0,0,GridID,DoChain,ChainID)
			End If
			If TilesY>2 Then
				If TilesTotal= 0 Then
					TilesTotal = TilesY
					ChainID= PDPGetChainID(GridID,X,1,False)
				Else
					TilesTotal=TilesTotal+TilesY-1
					DoChain=False
				End If
				'Log( Y & " Y SCORE FROM " & (Y-temp.bottom) & " TO " & (Y+temp.top)  & " Tiles: " &  TilesY)
				PDPGhostTiles(X,Y, 0,0,  temp.top,temp.bottom,GridID,DoChain,ChainID)
			End If
		End If
	End If 
	Return TilesTotal
End Sub

Sub PDPGhostTiles(X As Int, Y As Int, Left As Int, Right As Int, Top As Int, Bottom As Int, GridID As Int,DoChain As Boolean, ChainID As Int )
	Dim temp As Int ,temp2 As Int , Stage As Int , Grid As PdPGrid = PdP_Grid(GridID)
	If Left+Right+1>2 Then
		For temp = X-Left To X+Right
			Stage=Stage+ StartGhostStages
			PDPGhostTile(temp,Y, GridID, Stage)
			'temp2= Max(temp2, PdP_Grid(GridID).Chains(temp).x)
		Next
		temp2=PDPGetChainValue( ChainID,GridID)
		If ChainID>0 And DoChain Then 'PdP_Grid(GridID).Chains(temp) = PdP_Grid(GridID).Chains(temp)+1
			temp2=temp2+1
			For temp = X-Left To X+Right
				'Log("X SET " & temp & " CHAIN TO: " & temp2 & " CHAIN ID: " & ChainID)
				Grid.Chains(temp) = Trig.SetPoint( temp2,ChainID)
			Next
			'Msgbox("Setting chain: " & ChainID , "To: " & temp2)
			PDPSetChainValue(ChainID,temp2,GridID)
		End If
	Else If Top + Bottom + 1> 2 Then
		For temp = Y-Bottom To Y+Top 
			Stage=Stage+ StartGhostStages
			PDPGhostTile(X,temp, GridID,Stage)
		Next
		If ChainID>0 And DoChain Then 
			'Log("Y SET " & X & " CHAIN TO: " & (PdP_Grid(GridID).Chains(X).x+1) & " CHAIN ID: " & ChainID)
			Grid.Chains(X) =  Trig.SetPoint( Grid.Chains(X).X+1, ChainID)
			
			temp2=PDPGetChainValue( ChainID,GridID)+1
			'Msgbox("Setting chain: " & ChainID , "To: " & temp2)
			PDPSetChainValue(ChainID,temp2, GridID)
		End If
	End If
End Sub

Sub PDPClearUndo
	If PdP_Stack.IsInitialized Then	PdP_Stack.Clear 
End Sub
Sub PDPPushUndo(GridID As Int)
	If PdPMode = PdP_Puzzle Then
		If Not(PdP_Stack.IsInitialized ) Then PdP_Stack.Initialize 
		PdP_Stack.Add(		PDPSaveMap("","", GridID) )
	End If
End Sub
Sub PDPPullUndo(GridID As Int)As Boolean 
	Dim Index As Int 
	If PdPMode = PdP_Puzzle And PdP_Stack.IsInitialized Then
		If PdP_Stack.Size>0 Then
			Index=PdP_Stack.Size-1
			PDPLoadCustom( PdP_Stack.Get(Index), "", GridID, False)
			PdP_Stack.RemoveAt(Index)
			PDPPushEvent(GridID, PDP_Paused, 0,0,0,0,0)
			Return True
		End If
	End If
End Sub
Sub PDPPullFirstUndo(GridID As Int)
	Dim temp As Int 
	If PdPMode = PdP_Puzzle And PdP_Stack.IsInitialized Then
		For temp = 1 To PdP_Stack.Size-1
			PdP_Stack.RemoveAt(PdP_Stack.Size-1)
		Next
		PDPPullUndo(GridID)
		PdP_Grid(GridID).GameOver=0
	End If
End Sub

Sub PDPShiftUp(GridID As Int, AllowAtTop As Boolean)As Boolean 
	Dim x As Int, y As Int , MaxX As Int = PDP_GridWidth ,Tile As PdPTile ,TilesTotal As Int, Grid As PdPGrid = PdP_Grid(GridID) 
	If PDP_StartIndex = 0 Then Return False'Select Case PdPMode: Case PdP_Puzzle, PdP_Edit: Return False: End Select
	If Not(AllowAtTop) And Grid.GameOver = -1 Then Return False
	Grid.Yoffset = 0
	If Not(PDP_IsRowEmpty(10, GridID)) Then
		'If Not(AllowAtTop) Then Return False
	'For x= 0 To MaxX
	'	Grid.Chains(x)=Trig.SetPoint(0,0)
	'	If PDPGetTile(x,10,GridID).ColorID>0 Then
			PDPGameOver(False,GridID)
			Return False
	'	End If
	'Next
	End If
	
	Grid.Top = Grid.top + 1
	For y = 9 To 0 Step -1
		For x= 0 To MaxX - 1
			Tile=PDPGetTile(x,y,GridID)
			If Tile.Height >11 Then
				PDPGameOver(False,GridID)
				Return False
			Else
				Grid.Tiles(y+1,x) = Tile
				Grid.Tiles(y,x) = PDPMakeTile(0)
			End If
		Next
	Next
	
	For x= 0 To MaxX-1
		TilesTotal=TilesTotal+PDPCheckTile(x,1,True,GridID)
	Next
	PDPCombo(PDP_Combo, TilesTotal,GridID)
	
	Grid.Cursor.y= Grid.Cursor.y+1
	PDPRandomizeCache(GridID)
	
	Grid.LinesRemaining = Grid.LinesRemaining-1
	Log("Garbage: " & (Grid.LinesRemaining Mod Grid.GarbageLines))
	If Grid.LinesRemaining Mod Grid.GarbageLines = 0 And PDPGarbage Then 
		PDPAutoCreateRandomGarbage(GridID,False,-1)
	End If
	If Grid.LinesRemaining=0 Then'PdPMode = PdP_Normal AND
		Grid.LinesRemaining = Grid.LinesStarted
		Grid.ShiftPeriod = Max(10, Grid.ShiftPeriod-5)
	End If
End Sub

Sub PDPGameOver(Winner As Boolean, GridID As Int)
	PdP_Grid(GridID).GameOver = API.IIF(Winner,YouWon,YouLost)
	PDPPushEvent(GridID, PdP_GameOver,  PdP_Grid(GridID).GameOver,  PdP_Level, PdP_SubLevel,  0,0)
	LCAR.Stop("GAME OVER")
End Sub
Sub PDPRandomTile(GridID As Int)
	Dim X As Int, Y As Int, ColorID As Int , Found As Boolean , MaxX As Int = PDP_GridWidth, temp As Rect, Grid As PdPGrid = PdP_Grid(GridID) 
	Do Until Found = True
		X=Rnd(0,MaxX)
		Y=PDPBottom(X,10, GridID)
		If Y<7 Then
			ColorID=Rnd(2,PDP_Colors)
			temp=PDPFindConcurrentAxis(X,Y,ColorID, GridID )
			If temp.Left+temp.Right+1 <3 And  temp.Top+temp.Bottom+1<3 Then 
				Found=True
				Grid.Tiles(Y,X) = PDPMakeTile(ColorID)'	PDPGetTile(X,Y,GridID)
				Grid.Top = Max(Grid.Top,Y)
			End If
		End If
	Loop
End Sub
Sub PDPRandomizeCache(GridID As Int)
	Dim temp As Int,LastColor As Int, Grid As PdPGrid = PdP_Grid(GridID)  
	For temp=0 To PDP_GridWidth  - 1
		Grid.Tiles(0,temp) = PDPMakeTile(-1)
		If temp>1 Then
			Do While Grid.Tiles(0,temp).ColorID = LastColor
				Grid.Tiles(0,temp) = PDPMakeTile(-1)
			Loop
		End If
		LastColor=Grid.Tiles(0,temp).ColorID 
	Next
End Sub

Sub PDPSwapTiles(GridID As Int) As Boolean 
	Dim tempColor As Int, tempRND As String, srcTile As PdPTile ,srcTile2 As PdPTile, Grid As PdPGrid = PdP_Grid(GridID)   
	If PdPMode = PdP_Puzzle And Grid.Moves=0 Then Return False
	'PdP_Grid(GridID).GameOver = YouLost
	
	'srcTile= PdP_Grid(GridID).Tiles( PdP_Grid(GridID).Cursor.Y, PdP_Grid(GridID).Cursor.X)
	If PdPMode = PdP_Edit Then
		Grid.Tiles(Grid.Cursor.Y, Grid.Cursor.X) = PDPMakeTile(PDPSelectedColor)
		'srcTile.ColorID = PDPSelectedColor
		'srcTile.isClean=False
		If PDPSelectedColor=0 Then PDPDropColumn(Grid.Cursor.X,Grid.Cursor.Y+1, GridID)
	Else If Grid.Cursor.Y>0 Then 
		If PDP_IsGarbage(Grid.Cursor.X, Grid.Cursor.Y, GridID) Then Return False
		srcTile= Grid.Tiles( Grid.Cursor.Y, Grid.Cursor.X)
		If Grid.Cursor.X = 11 Then
			srcTile2= Grid.Tiles( Grid.Cursor.Y, 0)
			If PDP_IsGarbage(0, Grid.Cursor.Y, GridID) Then Return False
		Else
			srcTile2= Grid.Tiles( Grid.Cursor.Y, Grid.Cursor.X+1)
			If PDP_IsGarbage(Grid.Cursor.X+1, Grid.Cursor.Y, GridID) Then Return False
		End If
		
		If srcTile.X=0 And srcTile.Y=0 And srcTile.GhostStage=0 Then
			If srcTile2.X=0 And srcTile2.Y=0 And srcTile2.GhostStage=0 Then
				If srcTile.ColorID >0 Or srcTile2.ColorID>0 Then
					If PdPMode = PdP_Puzzle Then
						PDPPushUndo(GridID)
						Grid.Moves= Grid.Moves-1
						PDPDrawScore(GridID)
					End If
					
					tempColor = srcTile.ColorID 
					tempRND = srcTile.Text 
						
					srcTile.isMoving=True
					srcTile.ColorID= srcTile2.ColorID 
					srcTile.Text= srcTile2.Text 
					srcTile.isClean=False
					'If srcTile2.ColorID >0 Then PdP_Grid(GridID).Moving=PdP_Grid(GridID).Moving+1
					srcTile.X=1
					
					srcTile2.isMoving=True
					srcTile2.ColorID = tempColor
					srcTile2.Text=tempRND
					srcTile2.isclean=False
					'If tempColor >0 Then  PdP_Grid(GridID).Moving=PdP_Grid(GridID).Moving+1
					srcTile2.X=-1
					
					If PDPGarbage Then
						PDPDropTile(Grid.Cursor.X, Grid.Cursor.Y + 1, GridID)
						PDPDropTile( API.IIF(Grid.Cursor.X = 11, 0, Grid.Cursor.X+1), Grid.Cursor.Y + 1, GridID)
					End If
					Return True
				End If
			End If
		End If
	End If
End Sub

Sub PDPDrawColorSelector(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim TileWidth As Int , temp As Int ,Tile As PdPTile 
	TileWidth=Width/6
	LCAR.DrawRect(BG,X,Y-8,Width,Height+16,Colors.Black,0)
	For temp = 0 To 5
		Tile=PDPMakeTile(temp)
		Tile.Text=API.IIF(temp=1, "WILD",  (temp-1) )
		If temp=0 Then
			LCAR.DrawRect(BG,X+1,Y+1,TileWidth-5,Height-2, Colors.White, 2)
		Else
			PDPDrawTile(BG, X,Y,False, TileWidth-3,Height, Tile,False,False)
		End If
		If temp=PDPSelectedColor Then PDPDrawBrackets(BG, X,Y,TileWidth*0.1, -Height)'*0.1)
		X=X+TileWidth
	Next
End Sub

Sub PDPDrawScreen(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, GridID As Int)
	Dim TileWidth As Int,TileHeight As Int, X2 As Int, Y2 As Int,temp As Int, temp2 As Int,IsBottomRow As Boolean ,Tu As Int, Tu2 As Int, Grid As PdPGrid = PdP_Grid(GridID)
	Dim GridWidth As Int, Status As String, Color As Int, Top As Int , ThreeDBypass As Boolean = Width <0 , BG2 As Canvas 
	Width=Abs(Width)
	If Not(Grid.isClean) Then LCAR.DrawRect(BG, X-1,Y,Width+2,Height+1, Colors.Black,0)
	If (Paused Or Grid.GameOver>0) And Not(API.debugMode) Then
		If Grid.GameOver = YouLost Then
			Color = LCAR.LCAR_Red  
			If PdPMode = PdP_Puzzle Then
				Status = API.GetString("pdp_lost")
			Else
				Status = API.GetString("pdp_score") & ": " & Grid.Score
			End If
		Else If Grid.GameOver = YouWon Then
			Color =  LCAR.Classic_Green 
			If PdPMode = PdP_TimeLimit Or PdPMode = PdP_LineClear Then
				Status = API.GetString("pdp_score") & ": " & Grid.Score
			Else
				Status = API.getstring("pdp_won")
			End If
		Else If Paused Then 
			Color = LCAR.LCAR_Yellow 
			Status = API.GetString("pdp_score")
		End If
		LCARSeffects.DrawAlert(BG, X+Width/2,Y+Height/2, Min(Width,Height)/2,   Color     , Grid.PDPStage, 255, 0, "ALERT", Status, True)
		If PdPMode = PdP_TimeLimit Then PDP_LastUpdate = DateTime.GetSecond(DateTime.now)
	Else
		If ThreeDMode And Not(ThreeDBypass) Then
			LCARSeffects2.InitUniversalBMP(Width*2, Height, LCAR.LCAR_PdP)
			BG2.Initialize2(LCARSeffects2.CenterPlatform)
			PDPDrawScreen(BG2,0,0,Width*2,Height, GridID)
			
			BG.DrawBitmap(LCARSeffects2.CenterPlatform, Null, LCARSeffects4.SetRect(0,0, Width*2,Height))
		Else
			If PDPScreensize.X =Width And PDPScreensize.Y = Height Then
				TileWidth= Grid.BlockSize.X
				TileHeight=Grid.BlockSize.Y 
			Else
				TileWidth=Width/PdP_Width
				TileHeight=Height/PdP_Height
				Grid.BlockSize = Trig.SetPoint(TileWidth,TileHeight)
				PDPScreensize = Trig.SetPoint(Width,Height)
				PDPfontsize=0
			End If
			If PDPfontsize= 0 Then PDPfontsize = API.GetTextHeight(BG, TileHeight*0.4, "0123",  LCAR.LCARfont)   'API.TextHeightAtHeight(BG, LCAR.LCARfont, "0123",  )
			Tu=TileWidth*0.1
			Tu2=TileHeight*0.1
			Grid.Size=Trig.SetPoint(Width,Height)
			LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			Grid.Yoffset2=(TileHeight * (Grid.Yoffset))+3
			Y2=Y+Height+Grid.Yoffset2
			Y2=Y2-10*TileHeight
			GridWidth=5*TileWidth
		
			For temp = 10 To 0 Step -1' 0 To 10'Y
				IsBottomRow=temp=0
				If ThreeDMode And Not(ThreeDBypass) Then 
				
				Else
					X2=X + GridWidth
					For temp2 = 5 To 0 Step -1' 0 To 5'X
						If PDPDrawTile(BG,X2,Y2,IsBottomRow, TileWidth-3,TileHeight-3, Grid.Tiles(temp,temp2), Grid.isClean, False  ) Then
							If (temp2 = Grid.Cursor.X Or (PdPMode<> PdP_Edit And temp2 = Grid.Cursor.X+1)) And temp = Grid.Cursor.Y Then 
								PDPDrawBrackets(BG,X2,Y2,Tu,Tu2)
							End If
						End If
						X2=X2-TileWidth
					Next
					If temp = Grid.Top - Grid.LinesToClear Then Top = Y2
				End If
				Y2=Y2+TileHeight
			Next
			If PdPMode = PdP_LineClear And Top>0 Then 
				If Top < Y+Height Then PDPDrawLine(BG, X, Top, Width, TileWidth, TileHeight)
			End If
			Grid.isClean = True
			Grid.NeedsDrawing = False
			BG.RemoveClip 
			
		 	If PdPMode = PdP_TimeLimit Then
				temp = DateTime.GetSecond(DateTime.now)
				If PDP_LastUpdate <> temp And PDP_Remaining > 0 Then
					PDP_Remaining = PDP_Remaining - 1
					If PDP_Remaining = 0 Then Grid.GameOver = YouWon 
					PDPDrawScore(0)
				End If
				PDP_LastUpdate = temp
			End If
		End If
	End If
End Sub
Sub PDPDrawLine(BG As Canvas, X As Int, Y As Int, Width As Int, TileWidth As Int, TileHeight As Int)
	Dim Color As Int = LCAR.GetColor(LCAR.LCAR_Purple, False, 255), Right As Int = X+Width, Stroke As Int = TileHeight * 0.1, temp As Int
	Dim WhiteSpace As Int = TileWidth*0.1, TileWidth2 As Int = TileWidth-(WhiteSpace*2)
	BG.DrawLine(X,Y,Right,Y, Color, Stroke)
	Stroke = Stroke * 0.8
	For temp = X To Right Step TileWidth
		BG.DrawLine(temp+WhiteSpace, Y, temp+WhiteSpace+TileWidth2, Y, Colors.Black, Stroke)
	Next
End Sub

Sub PDPDrawBrackets(BG As Canvas, X As Int, Y As Int, Xunit As Int, Yunit As Int)
	If Yunit<0 Then
		LCARSeffects2.DrawBracketS(BG,X+Xunit,Y,Xunit, Abs(Yunit), True)
		LCARSeffects2.DrawBracketS(BG,X+Xunit*8-3,Y,Xunit, Abs(Yunit), False)
	Else
		LCARSeffects2.DrawBracketS(BG,X+Xunit,Y+Yunit*2,Xunit, Yunit*6, True)
		LCARSeffects2.DrawBracketS(BG,X+Xunit*8-3,Y+Yunit*2,Xunit, Yunit*6, False)
	End If
End Sub
Sub PDPDrawTile(BG As Canvas, X As Int, Y As Int, IsBottomRow As Boolean, TileWidth As Int,TileHeight As Int, Tile As PdPTile, isClean As Boolean, IsGameOver As Boolean  )As Boolean 
	Dim ColorID As Int=-1, WhiteSpace As Int = 3, State As Boolean, Alpha As Int, Width As Int, Height As Int '0=blank, 1=wild, 2-5=colors (4)
	If Not(Tile.isClean) Or Not(isClean)  Then
		Width = Tile.Width * (TileWidth+WhiteSpace) - WhiteSpace
		Height = Tile.Height * (TileHeight+WhiteSpace) - WhiteSpace
		X=X+ Tile.X*TileWidth
		Y=Y+ Tile.Y*TileHeight
		'If Not(Tile.Y<0 AND ColorID=0) Then LCAR.DrawRect(BG, X,Y,TileWidth,TileHeight, Colors.Black, 0)
		If Tile.ColorID>0 Then
			'If Paused AND Not(IsGameOver) Then Then
			'	LCAR.DrawRect(BG, X,Y,TileWidth,TileHeight, Colors.Gray  , 0)
			'Else
				If Tile.GhostStage=0 Then
					Alpha= API.IIF(IsBottomRow,127,255)
				Else
					Alpha = Tile.Alpha 
					If Alpha=255 Then
						State = (Tile.GhostStage Mod 2) =1 
					Else
						State=True
					End If
				End If
				Select Case PdPStyle
					Case -3'ENT
						ColorID=API.IIFIndex(Tile.ColorID, Array As Int( 0, LCAR.LCAR_White,LCAR.LCAR_Red, LCAR.LCAR_Yellow, LCAR.LCAR_LightBlue, LCAR.Classic_Green))
						LCARSeffects2.DrawPreCARSButton(BG,X,Y,Width,Height, ColorID, State, Alpha, Tile.Text, Tile.ColorID, True)
						ColorID=-1
					Case 0' TNG/VOY
						ColorID=API.IIFIndex(Tile.ColorID, Array As Int( 0, LCAR.LCAR_White, LCAR.LCAR_Orange, LCAR.LCAR_Purple, LCAR.LCAR_LightBlue, LCAR.LCAR_Red))
					Case Else'Else
						ColorID = Tile.ColorID
				End Select
				If ColorID>-1 Then
					LCAR.DrawRect(BG, X,Y,Width,Height, LCAR.GetColor(ColorID,State,Alpha) , 0)
					LCAR.drawlcartextbox(BG, X,Y, Width-1, PDPfontsize, 0,0, Tile.Text, LCAR.LCAR_Black, 0,0,False,False, -4, Alpha) 
				End If
			'End If
		End If
		Tile.isClean=True
		Return True
	End If
	Return False 
End Sub
Sub PDPMoveCursor(X As Int, Y As Int, GridID As Int)
	Dim temp As Int, Grid As PdPGrid = PdP_Grid(GridID) 
	If Y<1 Then Y=1
	PDPDirtyTile(GridID, Grid.Cursor.X, Grid.Cursor.Y, True)
	If Grid.size.X> Grid.size.Y Then PDPDirtyTile(GridID, Grid.Cursor.X, Grid.Cursor.Y+1, True)
	If PdPMode = PdP_Edit Then 'Y =
		temp =  PDPBottom(X,Y,GridID)
		If Y>temp Then Y=temp
	End If
	Grid.Cursor = Trig.SetPoint(X,Y)
	PDPDirtyTile(GridID, X, Y, True)
	
	If API.debugMode Then
		Log(X & ", " & Y & " Is occupied: " & PDP_IsTileOccupied(GridID, X,Y))
		If PDP_IsGarbage(X,Y,GridID) Then
			Log("Is garbage. Can drop: " & PDP_CanDropGarbage(X,Y,GridID))
		End If
	End If
End Sub
Sub PDPPause()
	Dim temp As Int
	Paused = Not(Paused)
	For temp = 0 To PdP_Grid.Length -1
		PdP_Grid(temp).LastUpdate = DateTime.Now
	Next
End Sub
Sub PDPHandleMouse(X As Int, Y As Int, Action As Int, GridID As Int)As Boolean 
	Dim temppos As Point, Grid As PdPGrid = PdP_Grid(GridID)
	If Action=-1 Then
		PDPIncrement(GridID)
		If Not(Paused) And Grid.GameOver<1 Then
			Select Case PdPMode
				Case PdP_Edit, PdP_Puzzle 
				Case Else
					If Grid.Bottom<7 Then
						If LCAR.IsPlaying Then LCAR.Stop("MOUSE")
						Grid.GameOver = 0
					Else
						If Not(LCAR.IsPlaying) Then LCAR.PlaySound(13,True)
						Grid.GameOver = -1
					End If
			End Select
		End If
	Else If Grid.GameOver >0 Then
		Return False
	Else If Paused Then
		Select Case Action
			Case LCAR.LCAR_Dpad
				If X= 8 Then
					PDPPause
					Return True
				End If
			Case Case LCAR.Event_Up ,LCAR.Event_Move, LCAR.Event_Down
				PDPPause
				Return True
		End Select
		Return False
	Else
		Select Case Action
			Case LCAR.LCAR_Dpad '0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
				If X <> 8 Then Paused= False
				Select Case X
					Case 0: PDPMoveCursor(Grid.Cursor.X,Min( Grid.Cursor.Y+1, 10), GridID)'  Grid.Cursor.Y = Min( Grid.Cursor.y+1, 10)'up
					Case 2: PDPMoveCursor(Grid.Cursor.X,Max( Grid.Cursor.Y-1,  1), GridID)'     Grid.Cursor.Y = Max( Grid.Cursor.y-1, 1)'down
					
					Case 1 'right
						If ThreeDMode Then
						
						Else
							PDPMoveCursor(Min( Grid.Cursor.X + 1, API.IIF(PdPMode=PdP_Edit,5, 4)), Grid.Cursor.Y, GridID)
							'Grid.Cursor.X = Min( Grid.Cursor.X + 1, 4)
						End If 
					Case 3'left
						If ThreeDMode Then
						
						Else
							PDPMoveCursor(Max( Grid.Cursor.X - 1, 0), Grid.Cursor.Y, GridID)
							'Grid.Cursor.X = Max( Grid.Cursor.X - 1, 0)
						End If 
					
					Case -1'cross/enter, 				swap tiles
						PDPSwapTiles(GridID)
					Case 5'triangle, delete, 			undo
						PDPPullUndo(GridID)
					Case 4,6,7'square, L/R shoulder, 	shift up
						If PdPMode=PdP_Edit Then
							Select Case X
								Case 4'square
									PDPSelectedColor = PDPSelectedColor+1
									If PDPSelectedColor>5 Then PDPSelectedColor=0
								Case 6'L
									If PDPSelectedColor>0 Then PDPSelectedColor=PDPSelectedColor-1
								Case 7'R
									If PDPSelectedColor<5 Then PDPSelectedColor=PDPSelectedColor+1
							End Select
						Else
							PDPShiftUp(GridID, False)
						End If
					Case 8'start, search, F 			pause
						PDPPause
				End Select
			Case LCAR.Event_Up 
				temppos=PDPFindCursor(GridID, Grid.Mouse.X, Grid.Mouse.Y, True)
				PDPMoveCursor(temppos.X, temppos.Y, GridID)
			Case LCAR.Event_Move'X/Y are relative
				Paused= False
				Grid.Mouse = Trig.SetPoint( Grid.Mouse.X+X, Grid.Mouse.Y+Y)
				temppos=PDPFindCursor(GridID, Grid.Mouse.X, Grid.Mouse.Y, False)
				Select Case temppos.X 
					Case Grid.Cursor.X-1
						Grid.Cursor = temppos
						PDPSwapTiles(GridID)
					Case Grid.Cursor.X
						If temppos.Y > Grid.Cursor.Y Then
							PDPShiftUp(GridID, False)
						Else If temppos.Y< Grid.Cursor.Y Then
							PDPPullUndo(GridID)	
						End If 
					Case Grid.Cursor.X+1
						PDPSwapTiles(GridID)
				End Select	
				'Grid.Cursor = temppos' PDPFindCursor(GridID, Grid.Mouse.X, Grid.Mouse.Y, True)
				PDPMoveCursor(temppos.X,temppos.Y,GridID)
				
			Case LCAR.Event_Down'X/Y are absolute
				Paused= False
				Grid.Mouse = Trig.SetPoint(X,Y)
				temppos=PDPFindCursor(GridID, X, Y, False)
				PDPMoveCursor(temppos.X,temppos.Y,GridID)
				'PDPDirtyTile(GridID, Grid.Cursor.X, Grid.Cursor.y, True)
				'Grid.Cursor = PDPFindCursor(GridID,X,Y)
				'PDPDirtyTile(GridID, Grid.Cursor.X, Grid.Cursor.y, True)
				
			'Case -1'Increment all, X=gridid
				'PDPIncrement(GridID)
				
		End Select
	End If
	Grid.isClean=False
	Return True'Grid.NeedsDrawing
End Sub

Sub PDPDirtyTile(GridID As Int, X As Int,Y As Int, NextOver As Boolean)
	'PdP_Grid(GridID).Tiles(PdP_Grid(GridID).Mouse.Y,PdP_Grid(GridID).Mouse.X).isChain = False
	Dim Grid As PdPGrid = PdP_Grid(GridID)
	If X>=0 And Y>=0 Then
		If X<11 And Y<10 Then
			Grid.Tiles(Y,X).isClean=False
			If NextOver And X<11 Then Grid.Tiles(Y,X+1).isClean=False
		End If
	End If
End Sub
Sub PDPFindCursor(GridID As Int, X As Int, Y As Int, Clip As Boolean ) As Point 
	Dim temp As Point, Grid As PdPGrid = PdP_Grid(GridID)
	temp.Initialize 
	temp.X = Max(0, Floor(X/ Grid.BlockSize.X ))
	If Not(ThreeDMode) And temp.X >4 And Clip  Then temp.X=4
	temp.Y =10- Floor((Y- Grid.Yoffset2) / Grid.BlockSize.Y)
	Return temp
End Sub








'Create Garbage blocks
Sub PDPCreateGarbage(GridID As Int, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, isachain As Boolean) As Int 
    Dim Grid As PdPGrid = PdP_Grid(GridID), tempTile As PdPTile = Grid.Tiles(Y,X), Temp As Int, temp2 As Int 
	If tempTile.ColorID = 0 Then
		For Temp = X To X+Width-1
			For temp2 = Y-Height+1 To Y 
				If PDP_IsTileOccupied(GridID,X,Y) Then Return 0
			Next
		Next
		tempTile.ischain = isachain
		tempTile.isGarbage = True
	    tempTile.ColorID = Color
	    tempTile.Height = Height
	    tempTile.Width = Max(2,Width)
	    'RaiseEvent GarbageCreated(X, Y, Width, Height)
	    PDPDropTile(X, Y, 	GridID)
		Return Width*Height
	End If
End Sub
Sub PDPCreateRandomGarbage(GridID As Int, Width As Int, Height As Int, isachain As Boolean) As Int 
    Dim Grid As PdPGrid = PdP_Grid(GridID), X As Int, temp As Int, GridHeight As Int = 10, GridWidth As Int = PDP_GridWidth
    temp = Rnd(2,PDP_Colors)
    If Grid.GarbageLines > 0 Or Height > 0 Then
        If Height = 0 Then
            Width =  Rnd(GridWidth*0.5, GridWidth)' Int(Rnd * (GridWidth / 2) + (GridWidth / 2))
            Height = Rnd(1,4)'Int(Rnd * 3) + 1
		End If
		If Width < GridWidth-1 Then X = Rnd(0, GridWidth - Width)
        Return PDPCreateGarbage(GridID, X, GridHeight, Width, Height, temp, isachain)
    End If
End Sub

'use ischain=false and count=-1 for random garbage
Sub PDPAutoCreateRandomGarbage(GridID As Int, ischain As Boolean, count As Int) As Int 
    Dim temp As Int, Width As Int, Height As Int=1, Grid As PdPGrid = PdP_Grid(GridID), GridWidth As Int = PDP_GridWidth
    If Grid.GameOver > 0 Then Return 0
    If ischain Then
        If count < 2 Then Return 0
        If count > 13 Then count = 13
        Height = Min(count - 1, 10-Grid.Top)
        Width = GridWidth
    Else If count = -1 Then'random garbage
		Select Case PDP_Difficulty
			Case 0'easy
				Width = 3
			Case 1'medium
				Width = PDP_GridWidth
			Case Else'hard, and anything else
				Width = PDP_GridWidth
				Height = PDP_Difficulty
		End Select
	Else 'is a normal combo
        If count < 4 Then Return 0
        Height = 1
        For temp = 1 To count
            Width = Width + 1
            If Width > GridWidth Then
                Height = Height + 1
                Width = GridWidth '2
            End If
        Next
    End If
    Return PDPCreateRandomGarbage(GridID, Width, Height, ischain)
End Sub

'Destroys garbage blocks
Public Sub PDPDestroyGarbage(X As Int, Y As Int, GridID As Int)
    Dim temp As Int, temp2 As Int, temptile As PdPTile, Grid As PdPGrid = PdP_Grid(GridID) , Score As Int 
    temptile = Grid.Tiles(Y, X)
	If temptile.isGarbage Then
	

'        If .ischain Then
'            Grid(Y, X).Height = .Height - 1
'            If Grid(Y, X).Height = 0 Then ClearTile X, Y
'            If Y < GridHeight Then
'                Grid(Y + 1, X) = Grid(Y, X)
'                ClearTile X, Y
'            End If
'            .Height = 1
'        End If
'    End With
'    temp4 = 1
'    temp3 = -Ghost * 3 'TEST VALUE FOR NOW
		For temp = Y - temptile.Height + 1 To Y
			PDPGhostGarbage(X-1, temp, GridID, temptile.ColorID, True)
			PDPGhostGarbage(X + temptile.Width, temp, GridID, temptile.ColorID, True)
		Next
	    For temp = X To X + temptile.Width - 1
			PDPGhostGarbage(X, Y+1, GridID, temptile.ColorID, True)
			PDPGhostGarbage(X, Y - temptile.Height, GridID, temptile.ColorID, True)
			
	        For temp2 = Y - temptile.Height + 1 To Y'bottom to top
				Grid.Tiles(temp2,temp) = PDPMakeTile(-1)
				PDPDropTile(temp,temp2,GridID)
				Score = Score + 20
	'                With Grid(temp2, temp)
	'                    ClearTile temp, temp2, True
	'                    '.Color = 1
	'                    .Z = temp3
	'                    RaiseEvent GarbageSubstituted(temp, temp2, .Color)
	'                End With
	'                'temp3 = temp3 + Ghost
	'                'End If
	        Next
	'            temp4 = temp4 + 1
	'            'DropColumn temp, (Y - temptile.height) + 1
	    Next
		PDPAddScore(GridID, Score)
	End If
End Sub














'http://www.kli.org/tlh/newwords.html
'http://www.angelfire.com/md/startrekkie1701/klindic.html

Sub TRI_HandleMouse(X As Int, Y As Int, Action As Int)As Boolean 
	TRI_HideToast'
	Select Case Action
		Case LCAR.LCAR_Dpad '0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
			Select Case X
				Case 1: TRI_MoveTurret(15, True)
				Case 3: TRI_MoveTurret(-15,True)
				Case -1: TRI_CreateBullet
				Case 8: Paused=Not(Paused)
			End Select
		Case LCAR.Event_Move
			XYLOC.X= XYLOC.X+X
			XYLOC.Y=XYLOC.Y+Y
			'Log("MOVE BY " & X & " " & Y & " TO " & XYLOC.X & " " & XYLOC.Y)
			TRI_HandleMouse(XYLOC.X,XYLOC.Y, -1)
		Case LCAR.Event_Down
			'Log("MOVE TO " & X & " " & Y)
			XYLOC = Trig.SetPoint(X,Y)
			If TRI_HandleMouse(XYLOC.X,XYLOC.Y, -1) Then TRI_CreateBullet
		Case -1
			'Log("FIRE AT " & X & " " & Y)
			LastP=Trig.SetPoint(X,Y)
			If Y> Dimensions.bottom * 0.4 Then
				TurretAngle = Trig.GetCorrectAngle(Dimensions.Right*0.5, Dimensions.Bottom, X,Y)
				
				
				'TurretAngle = Trig.CorrectAngle( Trig.GetCorrectAngle(50, 100 ,X/Dimensions.Right*100,Y/Dimensions.Bottom*100))
				'TurretAngle = Trig.GetCorrectAngle( Dimensions.Right-Dimensions.Left*0.5, Dimensions.Bottom ,X,Y)
				'TurretAngle = Trig.GetCorrectAngle(Dimensions.Right*0.5, Dimensions.Bottom,X/Dimensions.Right*100,Y/Dimensions.Bottom*100) 
				Return True
			Else If Y < Dimensions.bottom * 0.25 Then
				If X> Dimensions.Right*0.75 Then Paused = Not(Paused)
			End If
	End Select
End Sub


Sub TRI_doDeath As Boolean 
	If Lives > 0 Then
		Lives = Lives - 1
		Return True
	Else
		TRI_LoadLevel(1)
	End If
End Sub
Sub TRI_Init
	TribblesGIF.Initialize(File.DirAssets, "tribbles.png")
	TurretBMP.Initialize(File.DirAssets, "cursor.png")
	LCARSeffects2.SetKlingonFont
	
	LoadAudioFiles(TribbleSound,TribbleSound+8)'15-23
	
	'TribbleSize=API.IIF(LCAR.SmallScreen, 32,64)
	TurretAngle = 0        
  
	TRI_LoadLevel(1)
End Sub

Sub TRI_Toast(English As String, Klingon As String , Seconds As Int)
	'Dim ToastText As String, ToastPos As Double, ToastSeconds As Int
	ToastText = API.IIF(UT, English,  Klingon)
	ToastPos=-25
	ToastSeconds=Seconds
End Sub

Sub TRI_IncrementToast As Boolean 
	Dim ToastInc As Int
	ToastInc=5
	If ToastText.Length>0 Then
		If ToastPos <> 50 Then
			ToastPos=ToastPos+ToastInc
			If ToastPos > 120 Then
				ToastText= "" 
				If Lives=0 Then TRI_LoadLevel(1)
			End If
		Else If ToastPos = 50 Then
			If ToastSeconds>0 Then ToastSeconds=ToastSeconds-1
			If ToastSeconds=0 Then ToastPos=ToastPos+ToastInc
		End If
	Else
		Return True
	End If
End Sub
Sub TRI_HideToast'
	ToastSeconds=0
End Sub


Sub TRI_LoadLevel(Stage As Int)
	Level=Stage
	TribbleS.Initialize
	Bullets.Initialize 
	TRI_Toast(API.GetString("tri_level") & " " & Stage, "boq " & Stage, 30)
	Select Case Level'													-----PERIODS-----------------------
		'							LITTER	BULLET	TOTAL	ONSCREEN	PREGNATES	BOMBS	SLOWS	POISONS		SPEED
		Case 1:		TRI_SetPeriods(	10, 	33,		10,		2, 			0,			0,		0,		0,			5)
					TRI_Score=0:	TRI_Multiplier=0:		BulletSpeed = 5:		Lives = 5: 		Kills = 0
		Case 2:		TRI_SetPeriods(	10, 	33,		20,		4, 			0,			0,		0,		0,			5)	
		Case 3:		TRI_SetPeriods(	10, 	33,		40,		8, 			0,			0,		0,		0,			5)
		Case 4:		TRI_SetPeriods(	15, 	24,		40,		8, 			10,			0,		0,		0,			10)	
		Case 5:		TRI_SetPeriods(	15, 	24,		80,		16,			13,			0,		51,		41,			10)
		Case 6:		TRI_SetPeriods(	20, 	24,		80,		16,			10,			20,		40,		30,			10)
		Case 7:		TRI_SetPeriods(	20, 	11,		120,	16,			12,			20,		43,		33,			15)
		Case 8:		TRI_SetPeriods(	20, 	11,		160,	20,			13,			20,		43,		33,			15)
		Case 9:		TRI_SetPeriods(	25, 	11,		200,	20,			14,			20,		45,		35,			15)
		Case 10:	TRI_SetPeriods(	30, 	9,		300,	20,			18,			20,		55,		45,			20)
		
		Case Else:	TRI_SetPeriods(	40, 	9,		-1,		20,			20,			20,		55,		45,			20)'INFINITE MODE
	End Select
End Sub
Sub TRI_SetPeriods(TRILitterSize As Int, TRIBulletTemp As Int, TRITotalTribbles As Int, TRIMaxOnScreen As Int, Pregnates As Int, Bombs As Int, Slows As Int, Poisons As Int, Speed As Int)
	TribblePeriods(TRI_Pregnate) = Trig.SetPoint(Pregnates,Pregnates)
	TribblePeriods(TRI_Bomb) = Trig.SetPoint(Bombs,Bombs)
	TribblePeriods(TRI_Slow) = Trig.SetPoint(Slows,Slows)
	TribblePeriods(TRI_Poisoned) = Trig.SetPoint(Poisons,Poisons)
	
	LitterSize=TRILitterSize
	BulletTemp=TRIBulletTemp
	TotalTribbles=TRITotalTribbles
	TribblesRound=TRITotalTribbles
	TribblesOnScreen=TRIMaxOnScreen
	MaxSpeed=Speed
End Sub
Sub TRI_GetaType As Int
	Dim temp As Int,RET As Int
	RET=TRI_Regular
	For temp = TRI_Pregnate To TRI_Poisoned
		If TribblePeriods(temp).y>0 Then
			TribblePeriods(temp).X = TribblePeriods(temp).X-1
			If TribblePeriods(temp).X = 0 Then 
				RET= temp
				TribblePeriods(temp).X= TribblePeriods(temp).y
			End If
		End If
	Next
	Return RET
End Sub
Sub TRI_CreateBullet As Int 
	Dim temp As Bullet 
	Paused=False
	If Lives > 0 Then
		If TurretTemp<100 And Not(Overheat) Then
			temp.Initialize 
			temp.Angle=TurretAngle
			temp.X=50'Turret.X
			temp.Y=100'Turret.Y 
			Bullets.Add(temp)
			TurretTemp=TurretTemp+BulletTemp
			If TurretTemp>=100 Then 
				Overheat=True
				TRI_PlaySound(TRI_Overheat)
				'LCAR.Vibrate.Vibrate(150)
				LCAR.Rumble(2)
			Else
				'LCAR.Vibrate.Vibrate(75)
				LCAR.Rumble(1)
				TRI_PlaySound(TRI_Cannon)
			End If
			
			Return Bullets.Size-1 
		End If
    End If
End Sub

Sub TRI_DeleteBullet(Index As Int)
	Bullets.RemoveAt(Index)
End Sub
Sub TRI_IsBulletWithin(BulletIndex As Int, X As Int, Y As Int, Width As Int, Height As Int) As Boolean
	Dim temp As Bullet 
	temp = Bullets.Get(BulletIndex)
    Return IsWithin(X, temp.X, X + Width) And IsWithin(Y, temp.Y, Y + Height)
End Sub

Sub TRI_NewKill
	Kills = Kills + 1
    If Kills Mod 100 = 0 Then Lives = Lives + 1
	TribblesRound=TribblesRound-1
	If TribblesRound=0 Then' TRI_EndRound
		TRI_LoadLevel(Level+1)
	End If
End Sub

Sub TRI_MoveTurret(Direction As Int, Relative As Boolean )
	Paused=False
	If Relative Then
		TurretAngle=TurretAngle+Direction
		If TurretAngle<0 Then TurretAngle=TurretAngle+360
		If TurretAngle<180 Then
			If TurretAngle>90 Then TurretAngle=90
		Else
			If TurretAngle<270 Then TurretAngle=270
		End If
	Else
		TurretAngle = Direction
	End If
End Sub

Sub TRI_DrawScreen(BG As Canvas , X As Int, Y As Int, Width As Int, Height As Int, Layer As Boolean )
	If Not(TribbleS.IsInitialized) Then TRI_Init
	'Dimensions.Initialize(X,Y,Width,Height)' =LCAR.SetRect(X,Y,Width,Height)
	If Layer Then
		TRI_DrawCannon(BG,X,Y,Width,Height)
		TRI_DrawToast(BG,X,Y,Width,Height)
	Else
		TribbleSize=Height/8.703125
		TRI_DrawTribbles(BG,X,Y,Width,Height)
		TRI_DrawBullets(BG,X,Y,Width,Height)
	End If
End Sub
Sub TRI_DrawToast(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	'Dim ToastText As String, ToastPos As Double, ToastSeconds As Int, UT
	'X-logh boq'egh multiplication
	If UT Then
		LCAR.DrawText(BG,  X + Width* (ToastPos*0.01), Y+ Height*0.5, ToastText, LCAR.LCAR_Red, 5, False, 255,0)
	Else
		BG.DrawText(ToastText,  X + Width* (ToastPos*0.01), Y+ Height*0.5, LCARSeffects2.KlingonFont , LCAR.Fontsize , Colors.Red, "CENTER")
	End If
End Sub

Sub TRI_IncrementAll
	If Not (Paused) Then
		If TRI_IncrementToast Then
			If Not(TribbleS.IsInitialized) Then TRI_Init
			TRI_MoveTribbles
			TRI_MoveBullets
			If TurretTemp>0 Then
				TurretTemp=LCAR.Increment(TurretTemp, 5,0)
				If TurretTemp=0 Then Overheat=False
			End If
		End If
	End If
End Sub

Sub TRI_DrawTribbles(BG As Canvas , X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int, TRB As Tribble , tempP As Point 
	If TribbleS.Size=0 Then
		TRI_CreateRandomTribble(TribblesOnScreen)
	Else
		For temp = 0 To TribbleS.Size-1 
			TRB=TribbleS.Get(temp)
			tempP= Trig.SetPoint(X+ Width*(TRB.X*0.01), Y+Height*(TRB.Y*0.01))
			'Msgbox("DRAWING TRIBBLE " & tempP.x & " " &  tempP.y, "TRIBBLE")
			TRI_DrawTribble(BG, TRB, tempP.X  , tempP.Y)
		Next
	End If
End Sub

Sub TRI_DrawTribble(BG As Canvas ,  Temp As Tribble ,X As Int, Y As Int)
	Dim dest As Rect ,TribbleSize2 As Int
	TribbleSize2=TribbleSize
	Select Case Temp.aType 
		Case TRI_Pregnate:	TribbleSize2=TribbleSize2*2
		Case TRI_Bomb:		BG.DrawCircle(X,Y,TribbleSize, Colors.Red, False,2)
		Case TRI_Slow:		BG.DrawCircle(X,Y,TribbleSize, Colors.Yellow, False,2)
		Case TRI_Poisoned:	BG.DrawCircle(X,Y,TribbleSize, Colors.Green, False,2)
	End Select
	dest = LCAR.SetRect( X- TribbleSize2*0.5, Y- TribbleSize2*0.5, TribbleSize2,TribbleSize2)
	BG.DrawBitmap(TribblesGIF, LCAR.SetRect(Temp.SrcX, 0, 64,64), dest)
End Sub

Sub TRI_MoveTribbles
	Dim temp As Int, tempTribble As Tribble ,tempPoint As Point 
	If TribbleS.IsInitialized Then
		For temp = TribbleS.Size-1 To 0 Step -1
			tempTribble= TribbleS.Get(temp)
			If tempTribble.Angle=180 Then
				tempTribble.Y= tempTribble.Y+ tempTribble.Speed 
			Else
				tempPoint=Trig.FindAnglePoint(tempTribble.X ,tempTribble.y,tempTribble.Speed, tempTribble.angle )
				tempTribble.X = Max(0, Min(100, tempPoint.x))
				tempTribble.y=tempPoint.Y 
				tempTribble.Angle = LCAR.Increment(tempTribble.Angle, 15,180)
			End If
			If tempTribble.y > 100 Then
				If tempTribble.aType <> TRI_Poisoned Then
					TRI_IncScore(False)
					TRI_PlaySound(TRI_Fail)
				End If
				TribbleS.RemoveAt(temp)
				TRI_CreateRandomTribble(1)
			End If
		Next
	End If
End Sub

Sub TRI_CreateRandomTribble(Count As Int)
	Dim temp As Int, TRB As Tribble  
	If Count<1 Then
		TRB= TribbleS.Get(Abs(Count))
		For temp = 1 To LitterSize
			TribbleS.Add(TRI_CreateTribble( TRB.x+ Rnd(-5,5), TRB.y+ Rnd(-5,5),  Rnd(0,8)*64, Rnd(2, MaxSpeed), TRI_GetaType, Rnd(135,225) ))
		Next
	Else
		If TribblesRound>-1 Then TribblesRound=TribblesRound-Count
		For temp = 1 To Count
			TribbleS.Add(TRI_CreateTribble( Rnd(0,100), -Rnd(TribbleSize*0.5, TribbleSize*3),  Rnd(0,8)*64, Rnd(2, MaxSpeed), TRI_GetaType, 180          ))
		Next
		TRI_PlaySound(TRI_Coo)
	End If
End Sub
Sub TRI_CreateTribble(X As Int, Y As Int, SrcX As Int, Speed As Int, aType As Int, Angle As Int) As Tribble 
	Dim temp As Tribble 
	temp.X =X
	temp.Y = Y
	temp.SrcX  =SrcX
	If Slow>0 Then 
		Speed = Speed *0.5
		Slow=Slow-1
	End If
	temp.Speed =Speed
	temp.aType =aType
	temp.Angle =Angle
	Return temp
End Sub

Sub TRI_DrawCannon(BG As Canvas , X As Int, Y As Int, Width As Int, Height As Int)
	Dim Dest As Point 
	Turret = Trig.SetPoint(Width*0.5,Height)
	Dest=Trig.FindAnglePoint(X+Turret.X, Y+Turret.Y, Height*0.20, TurretAngle)
	If Not(TurretBMP.IsInitialized) Then TRI_Init
	If LCAR.SmallScreen Or Not(LCAR.Landscape)  Then
		BG.DrawBitmap(TurretBMP, Null, LCAR.SetRect(Dest.X-TurretBMP.Width*0.25,Dest.Y-TurretBMP.Height*0.25,TurretBMP.Width*0.5,TurretBMP.Height *0.5))
	Else
		BG.DrawBitmap(TurretBMP, Null, LCAR.SetRect(Dest.X-TurretBMP.Width*0.5,Dest.Y-TurretBMP.Height*0.5,TurretBMP.Width,TurretBMP.Height ))
	End If
End Sub





Sub TRI_MoveBullets
	Dim temp As Int, X As Int, Y As Int, TempBullet As Bullet 
	For temp = Bullets.Size-1 To 0 Step -1
		TempBullet=Bullets.Get(temp)
		X = Trig.findXYAngle( TempBullet.X, TempBullet.Y, BulletSpeed, TempBullet.Angle ,True)
		Y = Trig.findXYAngle( TempBullet.X, TempBullet.Y, BulletSpeed, TempBullet.Angle ,False)
		If X > 0 And X < 100 And Y > 0 Then
			TempBullet.X=X
			TempBullet.Y=Y
			TRI_CollisionCheck(TempBullet.X,TempBullet.Y)
		Else
			TRI_DeleteBullet(temp)
		End If
	Next
End Sub

Sub TRI_DrawBullets(BG As Canvas , X As Int, Y As Int, Width As Int, Height As Int)
	Dim temp As Int, TempBullet As Bullet ,temppoint As Point
	For temp = Bullets.Size-1 To 0 Step -1
		TempBullet=Bullets.Get(temp)
		'Msgbox(TempBullet.x,TempBullet.y)
		temppoint=Trig.SetPoint(X+   (TempBullet.X*0.01)*Width,  Y+ (TempBullet.Y*0.01)*Height)
		'Msgbox(temppoint.x,temppoint.y)
		BG.DrawCircle( temppoint.X,temppoint.Y, 3, Colors.Magenta, True,0)
	Next
End Sub

Sub TRI_CollisionCheck(X As Int, Y As Int)
	Dim temp As Int, TRB As Tribble,TRBSize As Int '0.1149012567324955
	For temp = TribbleS.Size-1 To 0 Step -1
		TRB=TribbleS.Get(temp)
		TRBSize= API.iIf( TRB.aType= TRI_Pregnate,12,6)
		If IsWithin(TRB.X-TRBSize,    X, TRB.X+ TRBSize) Then
			If IsWithin(TRB.Y-TRBSize,    Y, TRB.Y+ TRBSize) Then
				Select Case TRB.Atype
					Case TRI_Pregnate
						TRI_CreateRandomTribble(-temp)
					Case TRI_Bomb
						TRI_ScatterTribbles(TRB,temp)
					Case TRI_Slow
						Slow=10
					Case TRI_Poisoned
						Overheat=True
						TurretTemp=100
				End Select
				TRI_IncScore(True)
				TRI_PlaySound(TRB.Atype)
				TribbleS.RemoveAt(temp)
			End If
		End If
	Next
End Sub

Sub TRI_IncScore(Success As Boolean)
	If Success Then
		TRI_Multiplier=TRI_Multiplier+1
		TRI_Score=TRI_Score+TRI_Multiplier
	Else
		TotalTribbles=TotalTribbles+LitterSize
		TribblesRound=TribblesRound+LitterSize
		Lives=Lives-1
		TRI_Multiplier=0
		
		If Lives=0 Then TRI_Toast(api.GetString("tri_gameover"), "DavHam", -1)
	End If
End Sub

Sub TRI_ScatterTribbles(CurrentTribble As Tribble, Index As Int)
	Dim temp As Int, TRB As Tribble, Threshold As Int, Distance As Int, Angle As Int, Speed As Int
	Threshold=20
	For temp = TribbleS.Size-1 To 0 Step -1
		If temp <> Index Then
			TRB=TribbleS.Get(temp)
			Distance=Trig.FindDistance(CurrentTribble.X, CurrentTribble.Y, TRB.X,TRB.Y)
			If Distance < Threshold Then
				'Speed=Speed+ Distance/Threshold*Speed
				'Angle=Trig.GetCorrectAngle(CurrentTribble.X, CurrentTribble.Y, TRB.X,TRB.Y)
				'TRB.Angle=Angle
				'TRB.Speed=Speed
				TRI_IncScore(True)
				TribbleS.RemoveAt(temp)
			End If
		End If
	Next
End Sub

Sub IsWithin(lo As Int, mid As Int, hi As Int) As Boolean
    Return mid >= lo And mid <= hi
End Sub

Sub TRI_PlaySound(Index As Int)
	'TRI_Regular=0:TRI_Pregnate=1:TRI_Bomb=2:TRI_Slow=3:TRI_Poisoned=4: TRI_Scream=5:TRI_Cannon=6: TRI_Fail=7: TRI_Overheat=8
	If Not(PlayFile(Index)) Then LCAR.PlaySound(15+Index,False)
End Sub















Sub BMN_NewGame(Difficulty As Int, Yours As Int, Enemies As Int, Guesses As Int, Attacks As Int, DigitsNeeded As Int)
	If DifficultyLevel=Difficulty Then
		LCARSeffects3.YourATKt=-1
		LCARSeffects3.TheirATKt=-1
	
		YourShields=	MakeTween(Yours)
		EnemyShields=	MakeTween(Enemies)
		PassGuesses=	MakeTween(Guesses)
		AttackAttempts=	MakeTween(Attacks)
		Digits=			DigitsNeeded
		CurrentStage=2
		LCAR.SetLRwidth(FirstElement+1,Digits,0)
	End If
End Sub
Sub MakeTween(Value As Int) As TweenAlpha 
	Dim temp As TweenAlpha 
	temp.Initialize
	temp.Current=Value
	temp.Desired=Value
	Return temp
End Sub

Sub LoadTMPsounds'LoadAudioFiles(ReliantSound, ReliantSound+#)'change the #
	Dim temp As Int 
	
	ReliantSound = LCAR.AddSound("SHIELDS", "reliant.ogg", "")'sound +0 reliants shields
	LCAR.AddSound("KHANNNN", "khan.ogg", "")'sound +1 Khan!
	LCAR.AddSound("PHASERS", "phaser.ogg", "")'sound +2 phasers
	LCAR.AddSound("PHOTORP", "torpedo.ogg", "")'sound +3 photorp
	LCAR.AddSound("BIGBANG", "hullbreak.ogg", "")'sound +4 crash
	LCAR.AddSound("EVASIVE", "evade.ogg", "")'sound +5 evade
	LCAR.AddSound("STANDBY", "twokstandby.ogg", "")'sound +6 evade
	LCAR.AddSound("TWOKWIN", "twokwin.ogg", "")'sound +7 evade
	
	For temp = 1 To 99
		If LCAR.FindSound("BEEP " & temp) = -1 Then
			LCAR.LCAR_Beeps = temp-1
			Return
		End If
	Next
End Sub

Sub BMN_EnterSystem(BG As Canvas, Fresh As Boolean)
	Dim GameInProgress As Boolean = CurrentStage>0 And CurrentStage<6  ,temp As Int =Min(LCAR.ScaleWidth,LCAR.ScaleHeight)
	'Log("BMN_EnterSystem: " & CurrentStage)
	If CurrentStage=-1 Then'create UI
		GroupID=LCAR.AddGroup 
		SwitchList= LCAR.LCAR_AddList("WOKList",0,5,10,0,temp/2, -1 , temp/2  ,False,0,0,0,False,False,False,LCAR.TMP_Switch)  'List of TMP_Switches
		LCAR.LCAR_AddListItems(SwitchList, LCAR.LCAR_Black, 0, Array As String("1","2","3","4","5","6","7","8","9","0"))
		LCAR.LCAR_AddList("Entries", 0, 1,2,     0,100,-1, LCAR.ScaleHeight/2-100, False, 0,0,150,False,False,False, LCAR.TMP_Numbers)
		
		FirstElement=LCAR.LCAR_AddLCAR("Reliant", 0,0,0,-1,-1,0,0,0, LCAR.TMP_Reliant ,"","","",GroupID,False,0,True,0,255)'Reliant's shields
		LCAR.LCAR_AddLCAR("Pass", 0,0,0, -1, 100,0,0, LCAR.LCAR_White, LCAR.TMP_Numbers , "", "", "", GroupID, False,0,False,0,255)'password entry display
		LCAR.LCAR_AddLCAR("FCS", 0, 0,0,-1,-1,0,0,0,LCAR.TMP_FireControl , "", "", "", GroupID, False, 0,True,0,255)'fire control station
		
		
		'TMP_Numbers element and list
		'viewscreen
		'controls
		CurrentStage=0
	End If
	If CurrentStage=0 Or Fresh Then'just entered or prompt to resume
		LCAR.ForceHideAll(BG)
		If Not(LoadImagePack(False)) Then
			If API.IsConnected Then
				LCARSeffects3.ShowTMPPrompt(BG, API.getstring("twok_imagepack"), API.getstring("twok_whichpack"), Array As String("LOW", "HIGH"), 2)
			Else
				LCARSeffects3.ShowTMPPrompt(BG, API.getstring("twok_imagepack"), API.getstring("twok_offline"), Array As String(API.GetString("kb_ok")), 1)
			End If
		Else
			LoadAudioFiles(ReliantSound, ReliantSound+7)
			LoadAudioFile(LCAR.FindSound("TRB BOMB"))'sound +2 explosion
			
			LCARSeffects3.ShowTMPPrompt(BG, API.getstring("twok_difficulty"), API.getstring("twok_selectdiff") & API.IIF(GameInProgress, API.getstring("twok_resume"), ""), Array As String("EASY", "MED", "HARD"), 0)
			If GameInProgress Then LCAR.LCAR_AddListItem(LCARSeffects3.TMPlist, "RSM", LCAR.Classic_Green, -1,"", False, "", 0,False,-1)	
		End If
	Else
		LCAR.ForceHideAll(BG)
		Select Case CurrentStage
			Case 1'new game
				BMN_NewGame(0, 4,3,STimer.Infinite ,5,4) 'easy
				BMN_NewGame(1, 3,4,STimer.Infinite,4,5) 'med
				BMN_NewGame(2, 2,5,STimer.Infinite,3,6) 'hard
				BMN_EnterSystem(BG,False)
			Case 2'shields up
				LCAR.HideToast' ("shields up")
				CheckPassword(BG, True)
				LCAR.SetLRwidth(FirstElement, 0, LCARSeffects3.MaxShields)
				LCAR.forceshow( FirstElement,True)
				LCARSeffects3.YourATKt = -1
				If DifficultyLevel =2 Then LCARSeffects3.TheirATKt=-1
			Case 3'password entry
				PlayFile(6)
				LCAR.ResizeList(SwitchList+1, -1, LCAR.ScaleHeight/2-110, 150, 0,105,True)
				LCAR.LCAR_HideElement(BG,SwitchList+1,True,True,False)
				LCAR.MoveList(SwitchList,0,LCAR.ScaleHeight/2)
				LCAR.LCAR_HideElement(BG,SwitchList,True,True,False)
				LCAR.forceshow( FirstElement+1,True)
				
			Case 4'shields down
				LCAR.SetLRwidth(FirstElement, LCARSeffects3.MaxShields, 0)
				LCAR.forceshow( FirstElement,True)
				LCARSeffects3.YourATKt = -1
				LCARSeffects3.TheirATKt = -1 
				LCARSeffects3.ResetViewScreen(LCARSeffects3.ReliantDamaged)
			
			Case 5'attack selection
				LoadImagePack(True)
				LCARSeffects3.ResetViewScreen(EnemyShields.Current < (EnemyShields.Desired*0.5))
				LCAR.forceshow( FirstElement+2,True)
			
			Case 6'game over/won
				
		End Select
	End If
	''LCAR.LCAR_AddLCAR("TWOK", 0, 0,0, 150,200, 0,0, LCAR.LCAR_Black, LCAR.TMP_Switch , "1", "", "", 41,False, 0,True,0,255)'element 98 (group 41)	
	'LCAR.LCAR_AddLCAR("TWOK2", 0,  150,0, 150,200, 0,0, LCAR.Classic_Green, LCAR.TMP_Switch , "2", "", "", 41,False, 0,True,0,255)'element 99 (group 41)	
End Sub


Sub LoadImagePack(DoLoad As Boolean) As Boolean
	Dim Filename As String 	
	Filename = API.HILOFile(LCAR.DirDefaultExternal,"twokhi.png","twoklo.png")
	If Filename.Length=0 Then Return False
	LCARSeffects2.WarpLowRes= Filename.Contains("lo.")
	If DoLoad Then LCARSeffects2.LoadUniversalBMP(LCAR.DirDefaultExternal,Filename, LCAR.TMP_FireControl)
	Return True
End Sub
Sub ImagePackDone(Filename As String)
	Dim HighQuality As String = Filename.Contains("hi.")
	Select Case Filename 
		Case "twokhi.png",		"twoklo.png": 		DownloadMSD("twoklose.jpg", HighQuality)
		Case "twoklosehi.jpg", 	"twokloselo.jpg":	DownloadMSD("twokwin.jpg", HighQuality)
		Case "twokwinhi.jpg",	"twoklo.jpg":		LCAR.SystemEvent(0,40)'go back in
		Case "bridge.ogg"
			If WallpaperService.isInPmode Then
				Select Case WallpaperService.CurrentSection
					Case 10, 14, 16, 22, 27, 28, 29, 36, 37'second in command, transporter console, shuttle bay, CONN, Voyager conference room, OPS, third in command, transporter 2, hallway
						If File.Exists(LCAR.DirDefaultExternal, Filename) Then 
							LCAR.PlaySound(LCAR.AddSound("AMBIENT", Filename, LCAR.DirDefaultExternal),True)
						Else If API.IsOnWifi Then
							API.Download("MSD", "http://sites.google.com/site/programalpha11/home/lcars/bridge.ogg?attredirects=0&d=1")
						End If
					Case 33'TOS bridge
						LCAR.PlaySound(28,True)
					Case 34'ENT/NX bridge
				End Select
			End If
	End Select
End Sub
Sub CheckPassword(BG As Canvas, MakeRandom As Boolean) As Boolean 
	Dim Tempstr As String ,temp As Int, temp2 As Int 
	If MakeRandom Then
		PassCode=""
		LCAR.LCAR_ClearList(SwitchList+1,0)
		
		temp=(YourShields.Current/YourShields.desired)*100
		LCAR.LCAR_AddListItem(SwitchList+1, API.GetString("twok_you") & ": " & temp & "/100", LCAR.LCAR_White, -1,"", False, "", 0, False,-1)
		temp2=(EnemyShields.Current/EnemyShields.desired)*100
		LCAR.LCAR_AddListItem(SwitchList+1, API.GetString("twok_them") & ": " & temp2 & "/100", LCAR.LCAR_White, -1,"", False, "", 0, False,-1)
		
		Do Until PassCode.Length= Digits
			Tempstr= Rnd(0,10)
			If Not(PassCode.Contains(Tempstr)) Then PassCode=PassCode & Tempstr
		Loop
		Log("The passcode is: " & PassCode)
		ResetCode
		If API.debugMode Then LCAR.ToastMessage(BG,"CODE: " & PassCode ,5)
		'clear list
		Return True
	Else
		If PassCode = CurrentCode Then'user guessed correctly
			'go to shields going down, then battle
			CurrentStage=4
			BMN_EnterSystem(BG,False)
		Else'user got it wrong
			'add to a list
			For temp = 0 To CurrentCode.Length -1
				'If DifficultyLevel=0 Then
				'	If PassCode.Contains( API.Mid(CurrentCode,temp,1)) Then temp2=temp2+1
				'Else
					If API.Mid(PassCode,temp,1) = API.Mid(CurrentCode,temp,1) Then temp2 = temp2+1
				'End If
			Next
			'Log(CurrentCode & " had " & temp2 & " spots right")
			LCAR.LCAR_AddListItem(SwitchList+1, CurrentCode, LCAR.LCAR_White,-1,"", False, temp2, 0,False,-1)
			
			
			If PassGuesses.Desired<>STimer.Infinite Then 'user has limited guesses
				PassGuesses.Current = PassGuesses.Current-1
				If PassGuesses.Current = 0 Then 
					'lose a shield point
				Else
					LCAR.ToastMessage(BG, API.getstringvars("twok_incorrect", Array As String(PassGuesses.Current)), 3)
				End If
			End If
			ResetCode
			Return True
		End If
	End If
End Sub

Sub ResetCode
	Dim temp As Int ', Lists As LCARlist  
	'Lists = lcar.GetList(SwitchList)
	'For temp = 0 To Lists.listitems.Size -1
	'	LCAR.LCAR_AddLCAR.g
	'Next
	For temp = 0 To LCAR.GetListItemCount(SwitchList)-1
		LCAR.LCAR_GetListItem(SwitchList, temp).colorid = LCAR.lcar_black
	Next
	LCAR.SetSelectedItem(LCAR.GetList(SwitchList),-1)
	AttackAttempts.Current =AttackAttempts.Desired 
	CurrentCode=""
	If PassGuesses.Desired <> STimer.Infinite Then PassGuesses.Current = PassGuesses.Desired
	LCAR.LCAR_SetElementText(FirstElement+1, CurrentCode, "")
End Sub

Sub ToggleTMPSwitch(BG As Canvas, ListID As Int, Index As Int)
	Dim Listitem As LCARlistitem = LCAR.LCAR_GetListItem(ListID,Index), NewValue As Boolean = Listitem.ColorID = LCAR.LCAR_Black 
	If NewValue Then'add value to text
		If CurrentCode.Length=Digits Then
			If CheckPassword(BG, False) Then 
				Return
			End If
		Else
			CurrentCode=CurrentCode & Listitem.Text 
		End If
	Else'remove value from text
		CurrentCode=CurrentCode.Replace(Listitem.Text, "")
	End If
	If LCAR.cVol>0 Then API.Beep(100, 200+ Index*50)
	LCAR.LCAR_SetElementText(FirstElement+1, CurrentCode, "")
	Listitem.ColorID = API.IIF(NewValue, LCAR.Classic_Green,LCAR.LCAR_Black)
End Sub
Sub PerformAction(BG As Canvas, You As Boolean , Index As Int) 
	Dim tempstr As String ,DidEnd As Boolean 
	If Index=-1 And Not(You) Then
		If LCARSeffects3.TheirATKt = LCARSeffects3.TMP_Phasers Then
			Index=LCARSeffects3.TMP_Evade
		Else
			Index=Rnd(0,3)
			If LCARSeffects3.YourATKt = LCARSeffects3.TMP_Phasers Then
				If Rnd(0,101) > API.IIFIndex(DifficultyLevel, Array As Int(25,50,75)) Then Index= LCARSeffects3.TMP_PhoTorps
			End If
		End If
	End If
	LCAR.Toastmessage(BG, API.getstring(API.IIF(You, "twok_you", "twok_them")) & ": " & API.GetString("twok_act" & Index), 3)
	If You Then LCARSeffects3.YourATKt = Index  Else  LCARSeffects3.TheirATKt = Index
	Select Case Index
		Case LCARSeffects3.TMP_Phasers,LCARSeffects3.TMP_PhoTorps
			If You Then 
				LCARSeffects3.YourATKc.Current=0
				LCARSeffects3.YourATKc.desired=100 
				LCARSeffects3.YourATKa = MakeTween(100)
			Else 
				LCARSeffects3.TheirATKc.Current=0
				LCARSeffects3.TheirATKc.desired=100 
				LCARSeffects3.TheirATKa = MakeTween(100)
			End If
			If Not(You) And LCARSeffects3.YourATKt=LCARSeffects3.TheirATKt Then
				LCARSeffects3.YourATKc.desired=50
				LCARSeffects3.TheirATKc.desired=50
			End If
		Case LCARSeffects3.TMP_Evade
			If You Then 
				LCARSeffects3.Nebula.Desired=0
			Else 
				LCARSeffects3.Reliant.Current = 0
				LCARSeffects3.Reliant.Desired = 100
			End If
	End Select
	If Not(You) Then
		Select Case LCARSeffects3.YourATKt & LCARSeffects3.TheirATKt
			'you used phasers
			Case LCARSeffects3.TMP_Phasers & LCARSeffects3.TMP_Phasers: 	tempstr = "twok_phasers_phasers"
			Case LCARSeffects3.TMP_Phasers & LCARSeffects3.TMP_Evade: 		tempstr = "twok_phasers_evade"
			Case LCARSeffects3.TMP_Phasers & LCARSeffects3.TMP_PhoTorps: 	tempstr = "twok_phasers_torpedo"
				DidEnd=Attack(BG,True)
			
			'you used photon torpedos
			Case LCARSeffects3.TMP_PhoTorps & LCARSeffects3.TMP_Phasers: 	tempstr = "twok_torpedo_phasers"
				DidEnd=Attack(BG,False)
			Case LCARSeffects3.TMP_PhoTorps & LCARSeffects3.TMP_Evade: 		tempstr = "twok_torpedo_evade"
				DidEnd=Attack(BG,True)
			Case LCARSeffects3.TMP_PhoTorps & LCARSeffects3.TMP_PhoTorps: 	tempstr = "twok_torpedo_torpedo"
			
			'you evaded
			Case LCARSeffects3.TMP_Evade & LCARSeffects3.TMP_Phasers: 		tempstr = "twok_evade_phasers"
			Case LCARSeffects3.TMP_Evade & LCARSeffects3.TMP_Evade: 		tempstr = "twok_evade_evade"
			Case LCARSeffects3.TMP_Evade & LCARSeffects3.TMP_PhoTorps: 		tempstr = "twok_evade_torpedo"
				DidEnd=Attack(BG,False)
			
			Case Else: tempstr="ERROR: " & LCARSeffects3.YourATKt & LCARSeffects3.TheirATKt & " IS UNHANDLED"
		End Select
		If tempstr.StartsWith("twok_") Then tempstr = API.GetString(tempstr)
		
		If Not(DidEnd) Then LCAR.Toastmessage(BG, tempstr, 3)
	Else
		If LCARSeffects3.YourATKt = LCARSeffects3.TMP_Phasers Then LCAR.Toastmessage(BG, API.GetString("twok_recharging"), 3)
	End If
End Sub
Sub Attack(BG As Canvas, Reliant As Boolean)As Boolean 
	'YourShields As TweenAlpha,DifficultyLevel As Int, EnemyShields As TweenAlpha , '
	If Reliant Then
		EnemyShields.Current = EnemyShields.Current -1
		If EnemyShields.Current <1 Then 
			CurrentStage=6
			LCARSeffects3.endgame=1
			PlayFile(7)
			LCAR.Toastmessage(BG, API.GetString(API.IIF(API.debugMode, "twok_cheated", "twok_win")), 3)
			Return True
		End If
	Else
		YourShields.Current = YourShields.Current-1
		If YourShields.Current = 0 Then 
			CurrentStage=6
			LCARSeffects3.endgame=2
			LCAR.PlaySound(ReliantSound+1,False)
			LCAR.Toastmessage(BG, API.GetString("twok_lose"), 3)
			Return True
		Else
			LCARSeffects3.FlashViewscreen 
		End If
	End If
	'If CurrentStage=6 Then BMN_EnterSystem(BG,False)
End Sub
Sub DoSounds 
	If LCARSeffects3.endgame<1 Then
		LCAR.IsClean=False
		If LCARSeffects3.YourATKt = LCARSeffects3.TMP_Phasers Or LCARSeffects3.TheirATKt= LCARSeffects3.TMP_Phasers Then PlayFile(2)
		If LCARSeffects3.YourATKt = LCARSeffects3.TMP_PhoTorps Or LCARSeffects3.TheirATKt= LCARSeffects3.TMP_PhoTorps Then PlayFile(3)
		If LCARSeffects3.YourATKt = LCARSeffects3.TMP_Evade Or LCARSeffects3.TheirATKt= LCARSeffects3.TMP_Evade Then PlayFile(5)
	End If
End Sub
Sub BMN_HandleAnswer(BG As Canvas, ListID As Int ,Index As Int)
	'If ListID>-1 Then Log(ListID & ": " & LCAR.LCAR_GetListitemText(ListID, Index,0))
	'LCAR.ToastMessage(BG, LCARSeffects3.FullscreenMode & ": " & ListID & " " & CurrentStage & " " & Index, 4)
	Select Case ListID
		Case -1'reliant shields have dropped/risen
			CurrentStage=CurrentStage+1
			BMN_EnterSystem(BG,False)
		Case -2'reliant was clicked
			Dim temp As LCARelement = LCAR.GetElement(FirstElement)
			If temp.RWidth>0 Then temp.LWidth = temp.rwidth-1 Else temp.LWidth=1
		Case -3'console touched
			'Log("Prev attack: " & LCARSeffects3.YourATKt & " Phasers: " & LCARSeffects3.TMP_Phasers & " Current attack: " & Index & " Evade: " &  LCARSeffects3.TMP_Evade)
		
			If LCARSeffects3.FullscreenMode Then
				LCARSeffects3.IncrementViewscreen(True)
				LCARSeffects3.FullscreenMode=False
			Else If CurrentStage=6 Then
				CurrentStage=0
				BMN_EnterSystem(BG,True)
				LCAR.Toastmessage(BG, API.GetString("twok_gameover"), 3)
			Else If (LCARSeffects3.YourATKt = LCARSeffects3.TMP_Phasers) And (Index<>LCARSeffects3.TMP_Evade) Then 
				LCAR.PlaySound(LCAR.FindSound("ERROR"),False)
				LCAR.Toastmessage(BG, API.GetString("twok_mustevade"), 3)
			Else If AttackAttempts.Current >0 Then
				LCAR.HideToast' ("BMN_HandleAnswer")
				PerformAction(BG, True, Index)
				PerformAction(BG, False, -1)
				LCARSeffects3.FullscreenMode=True
				DoSounds
				AttackAttempts.Current = AttackAttempts.Current-1
			Else 
				BMN_HandleAnswer(BG,-4,0)
			End If
			
		Case -4'done incrementing
			If CurrentStage <6 Then
				LCAR.IsClean=False
				LCARSeffects3.ResetViewScreen(LCARSeffects3.ReliantDamaged)
				If AttackAttempts.Current=0 Then
					AttackAttempts.Current = AttackAttempts.Desired 
					CurrentStage=2
					BMN_EnterSystem(BG,False)
				Else If LCARSeffects3.endgame <1 Then
					LCAR.ToastMessage(BG, API.GetStringVars("twok_turnsleft", Array As String(AttackAttempts.Current)),2)
				End If
			End If
			
		Case SwitchList
			ToggleTMPSwitch(BG, ListID,Index)
		
		Case LCARSeffects3.TMPlist 
			Select Case LCARSeffects.PromptQID
				Case 0'difficulty level
					If Index < 3 Then
						DifficultyLevel=Index
						CurrentStage=1'new game
					End If
					BMN_EnterSystem(BG,False)	
				Case 1'internet connection not found
					'CallSub(Main,"ShowModeSelect")
					LCAR.SystemEvent(0,-1)
				Case 2'texture pack quality
					LCAR.SystemEvent(0,-1)
					DownloadMSD("twok.png", Index=1)
					'HttpUtils.Download("MSD", "https://sites.google.com/site/programalpha11/home/lcars/twok"& API.IIF(Index=1, "hi","lo") &  ".png?attredirects=0")		
					LCAR.ToastMessage(BG, API.getstring("twok_standby"),3 )
			End Select
	End Select
End Sub

Sub DownloadMSD(Name As String, HighQuality As Boolean)
	API.Download("MSD", "https://sites.google.com/site/programalpha11/home/lcars/" & Name.Replace(".", API.IIF(HighQuality, "hi.","lo.")) & "?attredirects=0")		
End Sub











'3d board games
'Type ThreeDLevel(X As Int, Y As Int, Z As Int, Width As Int, Height As Int, Grid As List)
'Type ThreeDPiece(Xoffset As Int, Yoffset As Int, Team As Int, Piece As Int)
'Type ThreeDboard(Gametype As Int, Levels As List)
'Dim NoGame As Int = 0, ThreeD_Minesweeper As Int = 1, ThreeD_Checkers As Int = 2, ThreeD_Chess As Int = 3
Sub ThD_NewGame(ElementID As Int, GameType As Int, Difficulty As Int, Multi1 As Int)
	Dim temp As Int, temp2 As Int, NeedsAI As Boolean  
	ThD_SetupMultiplayer
	LCAR.CurrentStyle=LCAR.LCAR_TOS
	LCAR.DrawFPS=True
	LCAR.HideToast'	("ThD_NewGame")
	CurrentPlayer =MIN_White
	ThD_MultiplayerData(True, -1, GameType, Difficulty, Multi1, 0)
	
	'If Player1Type = PT_AI OR Player2Type = PT_AI Then
		If ThreeDGame.IsInitialized Then
			If ThreeDGame.Difficulty <> Difficulty Or ThreeDGame.GameType <> GameType Or ThreeDGame.Mines <> Multi1 Then NeedsAI = True  
		Else
			NeedsAI = True 
		End If
		If API.ListSize(AIMoves) = 0 Then NeedsAI = True
	'End If
	
	ThreeDGame.initialize 
	ThreeDGame.Levels.Initialize 
	ThreeDGame.tCamera.Initialize 
	ThreeDGame.Size.Initialize 
	ThreeDGame.Mines = Multi1
	ThreeDGame.ScoreBlack=0
	ThreeDGame.ScoreWhite=0
	THD_Angle=-1
	ThreeD_Dpad=False
	'ThD_GridMode=False
	ThreeD_Opacity=128
	
	If ElementID>-1 Then ThreeD_ElementID = ElementID 'Else ElementID = ThreeD_ElementID
	If ThreeD_ElementID= -1 Then ThreeD_ElementID = LCAR.FindElement(LCAR.LCAR_ThreeDGame)
	LCAR.ForceShow(ThreeD_ElementID,True)
	LCAR.GetElement(ThreeD_ElementID).Opacity.Current = 255
	ThreeDGame.GameType=GameType
	ThreeDGame.Difficulty = Difficulty
	ThreeDGame.LastUpdate = DateTime.Now 
	LastTurn = ThD_Set3DPoint(-1,-1,-1)
	If ThreeDSize = 0 Then 
		ThreeDSize = 128 * LCAR.ScaleFactor 
		ThD_SetAnimation(10)
	End If 
	PDPfontsize=0
	ThD_SetAnimation(0)
	ThD_Fontsize=0
	ThD_GameOver=""
	If Not(ThreeD_Sprites.IsInitialized) Then ThreeD_Sprites.Initialize(File.DirAssets, "sprites.png")
	'If LCAR.CrazyRez >0 Then ThreeDSize = ThreeDSize * LCAR.CrazyRez
	LCARSeffects2.LoadUniversalBMP("", "ufp.png", LCAR.LCAR_ThreeDGame)
	ThreeD_Menu.Initialize 
	ThreeD_Menu.AddAll(Array As String("NEW", "+", "-"))
	ThreeDGridStyle=2
	Select Case GameType
		Case ThreeD_Minesweeper
			ThreeDGridStyle=1
			ThreeD_SelectedMenu=3
			ThreeD_Menu.AddAll(Array As String("CHK", "FLG","?"))
			If Difficulty<0 Then
    			'Beginner: 81 tiles (9x9), 10 mines
    			'Intermediate: 256 tiles (16x16), 40 mines
    			'Expert: 480 tiles, 99 mines

				ThD_AddLevel(ThreeDGame, 0,0,0, Abs(Difficulty), Abs(Difficulty), MIN_Immovable)
			Else
				Select Case Difficulty
					Case 0'MIN_Immovable As Int = -1, MIN_Neutral As Int = -2, MIN_White As Int = 0, MIN_Black As Int = 1
						ThD_AddLevel(ThreeDGame, 0,0, 3,   2,2, MIN_White)'top left
						ThD_AddLevel(ThreeDGame, 5,0, 3,   2,2, MIN_White)'top right
						ThD_AddLevel(ThreeDGame, 1,1, 2,   5,5,	MIN_Immovable)'top big
						ThD_AddLevel(ThreeDGame, 1,5, 1,   5,5,	MIN_Immovable)'middle big
						ThD_AddLevel(ThreeDGame, 0,13,1,   2,2, MIN_Black)'bottom left
						ThD_AddLevel(ThreeDGame, 5,13,1,   2,2, MIN_Black)'bottom right
						ThD_AddLevel(ThreeDGame, 1,9, 0,   5,5,	MIN_Immovable)'bottom big
				End Select
			End If
			MIN_PlaceMines(ThreeDGame, Multi1)
			
		Case ThreeD_Checkers
			Select Case Difficulty
				Case 0'3D
					ThD_AddLevel(ThreeDGame, 0,0, 3,   4,4,	MIN_Immovable)'top 
					ThD_AddLevel(ThreeDGame, 0,0, 2,   4,4,	MIN_Immovable) 
					ThD_AddLevel(ThreeDGame, 0,0, 1,   4,4,	MIN_Immovable) 
					ThD_AddLevel(ThreeDGame, 0,0, 0,   4,4,	MIN_Immovable)'bottom 
					ThD_AddPieces(ThreeDGame, Array As Int(0,2), 0,3,  MIN_White, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3), 1,3,  MIN_White, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3), 0,2,  MIN_White, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(0,2), 1,2,  MIN_White, CHK_Pawn)
					
					ThD_AddPieces(ThreeDGame, Array As Int(0,2), 2,1,  MIN_Black, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3), 3,1,  MIN_Black, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3), 2,0,  MIN_Black, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(0,2), 3,0,  MIN_Black, CHK_Pawn)
				Case 1'2D
					ThD_AddLevel(ThreeDGame, 0,0, 0,   8,8,	MIN_Immovable)'bottom 
					ThD_AddPieces(ThreeDGame, Array As Int(1,3,5,7), 0,0,  MIN_White, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(0,2,4,6), 1,0,  MIN_White, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3,5,7), 2,0,  MIN_White, CHK_Pawn)
					
					ThD_AddPieces(ThreeDGame, Array As Int(0,2,4,6), 5,0,  MIN_Black, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(1,3,5,7), 6,0,  MIN_Black, CHK_Pawn)
					ThD_AddPieces(ThreeDGame, Array As Int(0,2,4,6), 7,0,  MIN_Black, CHK_Pawn)
			End Select	
		Case ThreeD_Chess
			Log("Chess: " & API.IIF(Difficulty=0, "3D", "2D"))
			Select Case Difficulty
				Case 0'3D
					'Multi1 (Attackboards): 0=4 boards, 1=6 boards
					If Multi1 = 0 Then'4 attack boards
						ThD_AddLevel(ThreeDGame, 0, 0, 3,   2,2,	MIN_Immovable)'top left attack (white)
						ThD_AddLevel(ThreeDGame, 4, 0, 3,   2,2,	MIN_Immovable)'top right attack (white)
						
						ThD_AddLevel(ThreeDGame, 1, 1, 2,   4,4,	MIN_Immovable)'top (white)
						ThD_AddLevel(ThreeDGame, 1, 3, 1,   4,4,	MIN_Immovable)'middle
						ThD_AddLevel(ThreeDGame, 1, 5, 0,   4,4,	MIN_Immovable)'bottom (black)

						ThD_AddLevel(ThreeDGame, 0, 8, 1,   2,2,	MIN_Immovable)'bottom left attack (black)
						ThD_AddLevel(ThreeDGame, 4, 8, 1,   2,2,	MIN_Immovable)'bottom right attack (black)
						
						CHS_AddPieces(ThreeDGame, 0, 0, 3, MIN_White, 0)
						CHS_AddPieces(ThreeDGame, 1, 1, 2, MIN_White, 1)
						CHS_AddPieces(ThreeDGame, 4, 0, 3, MIN_White, 2)
						
						CHS_AddPieces(ThreeDGame, 0, 8, 1, MIN_Black, 0)
						CHS_AddPieces(ThreeDGame, 1, 7, 0, MIN_Black, 1)
						CHS_AddPieces(ThreeDGame, 4, 8, 1, MIN_Black, 2)
					Else '6 attack boards
					
					End If
					
				Case 1'2D
					ThD_AddLevel(ThreeDGame, 0, 0, 0,   8,8,	MIN_Immovable)'bottom 
					ThD_AddPieces(ThreeDGame, Array As Int(0,7), 0,0,  MIN_White, CHS_Rook)
					ThD_AddPieces(ThreeDGame, Array As Int(1,6), 0,0,  MIN_White, CHS_Knight)
					ThD_AddPieces(ThreeDGame, Array As Int(2,5), 0,0,  MIN_White, CHS_Bishop)
					ThD_AddPiece(ThreeDGame, 3, 0, 0,   MIN_White, CHS_Queen, False,True)
					ThD_AddPiece(ThreeDGame, 4, 0, 0,   MIN_White, CHS_King, False,True)
					ThD_AddPieces(ThreeDGame, Array As Int(0,1,2,3,4,5,6,7), 1,0,  MIN_White, CHK_Pawn)
					
					ThD_AddPieces(ThreeDGame, Array As Int(0,7), 7,0,  MIN_Black, CHS_Rook)
					ThD_AddPieces(ThreeDGame, Array As Int(1,6), 7,0,  MIN_Black, CHS_Knight)
					ThD_AddPieces(ThreeDGame, Array As Int(2,5), 7,0,  MIN_Black, CHS_Bishop)
					ThD_AddPiece(ThreeDGame, 3, 7, 0,   MIN_Black, CHS_Queen, False,True)
					ThD_AddPiece(ThreeDGame, 4, 7, 0,   MIN_Black, CHS_King, False,True)
					ThD_AddPieces(ThreeDGame, Array As Int(0,1,2,3,4,5,6,7), 6,0,  MIN_Black, CHK_Pawn)
			End Select
		Case ThreeD_TicTacToe
			ThreeDGridStyle=1
			ThD_AddLevel(ThreeDGame, 0,0,0, Difficulty,Difficulty, MIN_Immovable)' bottom
			If Multi1 = 1 Then
				For temp = 1 To Difficulty-1
					ThD_AddLevel(ThreeDGame, 0,0,temp, Difficulty,Difficulty, MIN_Immovable)
				Next
			End If
			If NeedsAI Then TTT_GenerateAImoves
		
		Case ThreeD_8589934592
			ThreeD_Opacity=0
			ThreeDGridStyle=1
			ThreeD_Dpad=True
			PdPStyle=1
			temp = Multi1 + 4
			temp2 = API.IIF(Difficulty=0, temp,1)
			ThD_AddLevels(ThreeDGame, temp,temp,temp2)
			NUM_RandomTiles(ThreeDGame, temp*0.5)
	End Select
	ThreeD_Menu.Add("BCK")
	ThD_RefreshScores
End Sub
Sub ThD_AddLevels(Board As ThreeDboard, Width As Int, Height As Int, Depth As Int)
	Dim Temp As Int
	For Temp = 1 To Depth
		ThD_AddLevel(Board, 0,0, Temp-1, Width,Height,MIN_Immovable)
	Next
End Sub

Sub CHS_AddPieces(Board As ThreeDboard, X As Int, Y As Int, Z As Int, Team As Int, Block As Int)
	Dim FrontRow As Int = Y, BackRow As Int = Y
	If Team = MIN_White Then 
		FrontRow=Y+1
	Else
		BackRow=Y+1
	End If
	Select Case Block
		Case 0'left attack board
			ThD_AddPieces(Board, Array As Int(X,X+1), FrontRow,Z,  Team, CHK_Pawn)
			ThD_AddPiece(Board, X, BackRow, Z,   Team, CHS_Rook, False,True)
			ThD_AddPiece(Board, X+1, BackRow, Z,   Team, CHS_Queen, False,True)
		Case 1' main board
			ThD_AddPieces(Board, Array As Int(X,X+1,X+2,X+3), FrontRow,Z,  Team, CHK_Pawn)
			ThD_AddPieces(Board, Array As Int(X,X+3), BackRow,Z,  Team, CHS_Knight)
			ThD_AddPieces(Board, Array As Int(X+1,X+2), BackRow,Z,  Team, CHS_Bishop)
		Case 2'right attack board
			ThD_AddPieces(Board, Array As Int(X,X+1), FrontRow,Z,  Team, CHK_Pawn)
			ThD_AddPiece(Board, X, BackRow, Z,   Team, CHS_King, False,True)
			ThD_AddPiece(Board, X+1, BackRow, Z,   Team, CHS_Rook, False,True)
	End Select
End Sub


Sub ThD_AddPieces(Board As ThreeDboard, Xs As List, Y As Int, Z As Int, TeamID As Int, PieceID As Int)
	Dim temp As Int 
	For temp = 0 To Xs.Size-1
		ThD_AddPiece(Board, Xs.Get(temp),Y,Z,TeamID,PieceID, False, True)
	Next
End Sub
Sub ThD_AddScore(Board As ThreeDboard,TeamID As Int, Value As Int, Relative As Boolean) As Int 
	If TeamID = MIN_White Then
		If Relative Then
			Board.ScoreWhite = Board.ScoreWhite + Value
		Else
			Board.ScoreWhite = Value
		End If
		Return Board.ScoreWhite 
	Else If TeamID = MIN_Black Then
		If Relative Then
			Board.ScoreBlack = Board.ScoreBlack + Value
		Else
			Board.ScoreBlack = Value
		End If
		Return Board.ScoreBlack
	End If
End Sub
Sub ThD_SetPiece(Board As ThreeDboard, X As Int, Y As Int, Z As Int, Piece As ThreeDPiece)
	Dim TileID As Point = ThD_Get3Dpoint(Board, X, Y, Z) , tempPiece As ThreeDPiece = ThD_Get3DpieceP(Board, TileID)
	tempPiece.Piece = Piece.Piece
	tempPiece.Team = Piece.Team
	tempPiece.Uncovered = Piece.Uncovered
End Sub
Sub ThD_AddPiece(Board As ThreeDboard, X As Int, Y As Int, Z As Int, TeamID As Int, PieceID As Int, AllowIfOccupied As Boolean, AddToScore As Boolean) As Boolean 
	Dim TileID As Point = ThD_Get3Dpoint(Board, X, Y, Z) , tempPiece As ThreeDPiece = ThD_Get3DpieceP(Board, TileID)
	If AddToScore Then ThD_AddScore(Board, TeamID, 1, True)
	If tempPiece.IsInitialized And TileID.X > -1 And TileID.Y > -1 Then
		If tempPiece.Team>0 And Not(AllowIfOccupied) Then Return False
		tempPiece.Team=TeamID
		tempPiece.Piece=PieceID
		Return True
	End If
	Return False
End Sub

Sub ThD_RefreshScores
	Dim Left As String, Right As String 
	Select Case ThreeDGame.GameType
		Case ThreeD_8589934592
			Right = ThreeDGame.ScoreWhite 
			If ThreeDGame.ScoreBlack=1 Then Left = API.GetString("tri_gameover")
		Case ThreeD_Minesweeper
			Left = API.getstring("3d_flags") & ": " & ThreeDGame.Flags
			Right = API.GetString("3d_set4") & ": " & ThreeDGame.Mines
		Case Else 
			Right = API.GetString("tri_gameover")
			If ThreeDGame.ScoreBlack = 0 Then
				Left = API.GetString("3d_white_won")
			Else If ThreeDGame.ScoreWhite = 0 Then
				Left = API.GetString("3d_black_won")
			Else
				Left = API.GetString( API.IIF(CurrentPlayer = MIN_White, "3d_white_turn", "3d_black_turn") )
				Select Case API.IIF(CurrentPlayer = MIN_White, Player1Type, Player2Type)
					Case PT_Local: 	Right = "3d_local"
					Case PT_Remote: Right = "3d_remote"
					Case PT_AI: Right = "3d_ai"
				End Select
				If Right.Length>0 Then Right = API.GetString(Right)
			End If
	End Select
	LCAR.LCAR_SetElementText(ThreeD_ElementID, Left, Right)
End Sub

Sub ThD_HandleAI
	If API.IIF(CurrentPlayer = MIN_White, Player1Type, Player2Type) = PT_AI Then
		If ThD_GameOver.Length=0 Then
			Select Case ThreeDGame.Gametype 
				Case ThreeD_TicTacToe: ThD_Click3DPoint(TTT_MakeAIMove(ThreeDGame),PT_AI) 
			End Select
		Else If Player1Type= PT_AI And Player2Type = PT_AI Then 
			If Main.AprilFools Then 
				If ThD_SetAnimation(-1) Then LCAR.PlaySoundFile("", "woprstrange.ogg", False)
			End If
			ThD_NewGame(-1, ThreeDGame.Gametype, ThreeDGame.Difficulty, ThreeDGame.Mines) 
		End If
	End If
End Sub

Sub ThD_Set3DPoint(X As Int, Y As Int, Z As Int) As ThreeDPoint
	Dim temp As ThreeDPoint 
	temp.Initialize 
	temp.X=X
	temp.Y=Y
	temp.Z=Z
	Return temp
End Sub
Sub ThD_Click3DPoint(PT As ThreeDPoint, InputType As Int)
	ThreeDGame.tCamera.Z= PT.Z 
	ThD_GridLoc = Trig.SetPoint(PT.X, PT.Y)
	ThD_GridClicked( PT.x, PT.y, PT.z, InputType)
End Sub

Sub ThD_AddLevel(Board As ThreeDboard, X As Int, Y As Int, Z As Int, Width As Int, Height As Int, Player As Int)
	Dim tempLevel As ThreeDLevel, temp As Int , Total As Int = Width*Height
	tempLevel.Initialize 
	tempLevel.Player = Player
	tempLevel.Loc = ThD_Set3DPoint(X,Y,Z)
	tempLevel.Width=Width
	tempLevel.Height=Height
	tempLevel.Grid.Initialize 
	Board.TotalTiles = Board.TotalTiles + Total
	For temp = 0 To Total - 1
		Dim tempSquare As ThreeDPiece 
		tempSquare.Initialize 
		If ThreeDGame.Gametype  = ThreeD_Minesweeper  Then
			tempSquare.Xoffset = (temp Mod Width) + X
			tempSquare.Yoffset = (Floor(temp / Height)) + Y
		End If
		tempLevel.Grid.Add(tempSquare)
	Next
	Board.Levels.Add(tempLevel)
	Board.Size.X = Max(Board.size.X, X+Width)
	Board.Size.Y = Max(Board.size.Y, Y+Height)
	Board.size.Z = Max(Board.size.Z, Z)
End Sub

Sub ThD_Draw3Dgame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int)
	Dim Size As Int 
	If ThD_Landscape Then 'landscape ----
		Size = Min(ThreeDSize, Height / (ThreeDGame.Size.Z+1))
		'LCARSeffects4.DrawRect(BG,X,Y,Width, LCAR.ItemHeight, Colors.black, 0)'----
		X=X+Size+1
		Width=Width-Size
		Y=Y+LCAR.ItemHeight+1
		Height=Height-LCAR.ItemHeight
		Height=Height-LCAR.ItemHeight
	Else'portrait |
		Size = Min(ThreeDSize, Width / (ThreeDGame.Size.Z+1))
		Y=Y+LCAR.ItemHeight+1 + Size+1
		Height = Height - Size - LCAR.ItemHeight - 2
	End If
	ThD_Draw3D(BG,X,Y,Width+1,Height+1, THD_Angle, ThreeDGame, ColorID)
End Sub
Sub ThD_Drawgame(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, Text As String, SideText As String, ColorID As Int)
	Dim tempLevel As ThreeDLevel , temp As Int, Index As Int, SmallSize As Int,Size As Int, Color As Int = LCAR.GetColor(ColorID, False,Alpha)  
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)'clear screen
	ThD_Landscape = Width>Height
	If THD_Angle > -1 Then ThD_Draw3Dgame(BG, X,Y,Width,Height, ColorID)
	If ThD_Landscape Then 'landscape ----
		If ThreeDGame.Size.Z>0 Then
			Size = Min(ThreeDSize, Height / (ThreeDGame.Size.Z+1))
			SmallSize= Floor(Size / Max( ThreeDGame.Size.X , ThreeDGame.Size.Y))
			ThD_DrawLevelSelect(BG, X,Y,SmallSize, Size, ThreeDGame, True, ColorID, Width, Height)
			X=X+Size+1
			Width=Width-Size
		End If
		ThD_DrawMenu(BG,X+1,Y,Width, LCAR.ItemHeight, Color, ColorID)
		Y=Y+LCAR.ItemHeight+1
		Height=Height-LCAR.ItemHeight
	Else'portrait |
		ThD_DrawMenu(BG,X,Y,Width, LCAR.ItemHeight, Color, ColorID)
		Y=Y+LCAR.ItemHeight+1
		If ThreeDGame.Size.Z>0 Then
			Size = Min(ThreeDSize, Width / (ThreeDGame.Size.Z+1))
			SmallSize= Floor(Size / Max( ThreeDGame.Size.X , ThreeDGame.Size.Y))
			ThD_DrawLevelSelect(BG, X,Y,SmallSize, Size, ThreeDGame, False, ColorID, Width, Height)
			Y=Y+Size+1
			Height = Height - Size - LCAR.ItemHeight
		End If
	End If
	LCARSeffects.MakeClipPath(BG,X,Y,Width+1,Height+1)
	If THD_Angle = -1 Then '2D drawing mode
		If PDPfontsize=0 Then PDPfontsize = API.GetTextHeight(LCAR.EmergencyBG, ThreeDSize*0.4, "0123",  LCAR.LCARfont)
		For temp = 0 To ThreeDGame.Levels.Size-1 
			tempLevel=ThreeDGame.Levels.Get(temp)
			ThD_Screensize = Trig.SetPoint( Floor(Width / ThreeDSize), Floor(Height/ThreeDSize))
			Index = Index + ThD_DrawLevel(BG, X + (ThreeDGame.tCamera.X + tempLevel.Loc.X)*ThreeDSize, Y + (ThreeDGame.tCamera.Y + tempLevel.loc.Y) * ThreeDSize, ThreeDSize, tempLevel, API.IIF(ThreeDGame.tCamera.Z = tempLevel.Loc.Z, 255, 128), tempLevel.Loc.Z, Index, ColorID)
		Next
	End If 
	If Text.Length>0 Then API.DrawTextAligned(BG, Text, X,Y, 0, LCAR.TOSFont, LCAR.Fontsize, Colors.green, -1, 0, 0)
	If SideText.Length>0 Then API.DrawTextAligned(BG, SideText, X+Width,Y, 0, LCAR.TOSFont, LCAR.Fontsize, Colors.green, -3, 0, 0)
	If ThD_GameOver.Length >0  Then 
		temp = BG.MeasureStringWidth(ThD_GameOver, LCAR.TOSFont, LCAR.Fontsize*2)'width
		Size = BG.MeasureStringheight(ThD_GameOver, LCAR.TOSFont, LCAR.Fontsize*2)'height
		LCARSeffects3.DrawStyledToast(BG,  LCAR.LCAR_TOS, 0, ThD_GameOver, 255, temp + 20, Size, Width,Height)
		'temp = BG.MeasureStringWidth(Text, LCAR.TOSFont, LCAR.Fontsize*2)'width
		'LCAR.DrawRect(BG, X - 12, Y-12,Width+24,Height+24 , Colors.black , 0)
		'LCAR.DrawRect(BG, X - 10, Y-10,Width+20,Height+20 , Color , 10)	
		'Size = API.DrawTextAligned(BG, ThD_GameOver, X+Width/2,Y+Height/2, 0, LCAR.TOSFont, LCAR.Fontsize*2, Colors.red, -5)	
	End If
	BG.RemoveClip 
	If ThreeD_Dpad Then 
		temp= 150 * LCAR.GetScalemode
		'If Not(ThD_Landscape) Then y = y - LCAR.ItemHeight
		LCARSeffects.DrawDpad(BG, X+Width-temp, Y+Height-temp, temp, LCAR.LCAR_LightOrange, temp*LCARSeffects.DpadCenter*2, LCAR.LCAR_Orange, 2, 255 , False, -1)
	End If
End Sub

Sub LogPoints(Name As String, Points() As Point)
	Dim temp As Int , tempstr As StringBuilder
	tempstr.Initialize
	tempstr.Append(Name & ": " & Points.Length & " cells -")
	For temp = 0 To Points.Length - 1
		tempstr.Append(" " & temp & " X: " & Points(temp).X & " Y: " & Points(temp).Y)
	Next
	Log(tempstr.ToString)
End Sub

Sub ThD_Draw3D(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Angle As Int, Game As ThreeDboard, ColorID As Int)
	Dim Points() As Point, CenterX As Int = X + Width * 0.5, RadiusX As Int = Min(Width, Height) * 0.5 * THD_Zoom, RadiusY As Int = RadiusX * 0.5, CenterY As Int = Y + Height - RadiusY, temp As Int, Zoffset As Int, Longest As Int, tempLevel As ThreeDLevel, temp2 As Int, Percent As Double
	Dim StartX As Float, StartY As Float, Alpha As Int, BG2 As Canvas', tempF As Float 
	Points = Wireframe.CachePoints(CenterX,CenterY, RadiusX, RadiusY, Angle)'LogPoints("DATA", Points)
	If ThD_Fontsize = 0 Then ThD_Fontsize = API.GetTextLimitedHeight(BG, 64,64, "99", LCAR.TOSFont)
	If PDPfontsize= 0 Then PDPfontsize = API.GetTextHeight(BG, 26, "0123",  LCAR.LCARfont)
	Zoffset = (Height - RadiusY) / (Game.Size.Z+1) * THD_Zoom
	Longest = Max(Game.Size.X, Game.Size.Y)
	Percent = (100/Longest) * 0.01
	StartX = (Longest * 0.5 - Game.Size.X * 0.5)/Longest
	StartY = (Longest * 0.5 - Game.Size.Y * 0.5)/Longest
	If Game.tCamera.Z > 1 Then 
		temp = Zoffset*(Game.tCamera.Z-1)
		CenterY = CenterY - temp
		For temp2 = 0 To 3
			Points(temp2).Y = Points(temp2).Y + temp
		Next
	End If 
	SavedPoints(4) = Trig.SetPoint(RadiusX,RadiusY)
	LCARSeffects4.TRI_NeedsInit(LCARSeffects4.TRI_FrameA, 64,64)
	BG2.Initialize2(LCARSeffects4.TRI_FrameA)
	For temp = 0 To Game.Size.Z
		Alpha = API.IIF(Game.tCamera.Z = temp, 255, 128)
		For temp2 = 0 To Game.Levels.Size-1
			tempLevel = Game.Levels.Get(temp2)
			If tempLevel.Loc.Z = temp Then ThD_Draw3DLevel(BG, tempLevel, Points, Percent, Longest, Game.Size, StartX, StartY, ColorID, Alpha, temp, BG2)
		Next
		If temp = Game.tCamera.Z Then 
			ThD_Draw3Dsquare(BG, Points, 0, 0, Longest, Longest, Percent, 0,0, Colors.Blue, 2, 0)
		End If 
		For temp2 = 0 To 3
			If Game.tCamera.Z = temp Then SavedPoints(temp2) = Trig.SetPoint(Points(temp2).X, Points(temp2).Y)
			Points(temp2).Y = Points(temp2).Y - Zoffset
		Next
		CenterY = CenterY - Zoffset
	Next
	SavedZ=Zoffset
End Sub
Sub ThD_Draw3DLevel(BG As Canvas, TheLevel As ThreeDLevel, Points() As Point, Percent As Double, Longest As Int, BoardSize As ThreeDPoint, StartX As Float, StartY As Float, ColorID As Int, Alpha As Int, Z As Int, BG2 As Canvas)
	Dim Color As Int = LCAR.GetColor(ColorID, False, Alpha), Stroke As Int = 2, tempX As Int, tempY As Int, State As Boolean, TempTileID As Int, tempPiece As ThreeDPiece, Offset As Double = Percent * 0.1, X As Int, Y As Int = TheLevel.loc.Y
	If (Z Mod 2) = 0 Then ThD_Draw3DSprite(BG, Points, TheLevel.loc.X, TheLevel.loc.Y, TheLevel.Width,TheLevel.Height, Percent, StartX,StartY, -1, 9999, Colors.black, Alpha, True, BG2)'UFP logo, distorted aspect ratio ;_;
	For tempY = 0 To TheLevel.Height - 1
		X = TheLevel.loc.X
		If tempY > 0 And ThreeDGridStyle = 1 Then ThD_Draw3Dline(BG, Points, x, y, x + TheLevel.Width, y, Percent, StartX,StartY, Color, Stroke)
		For tempX = 0 To TheLevel.Width - 1
			Select Case ThreeDGridStyle
				Case 1: If tempY = 0 Then ThD_Draw3Dline(BG, Points, X, TheLevel.loc.Y, X, TheLevel.loc.Y + TheLevel.Height, Percent, StartX,StartY, Color, Stroke)
				Case 2: If State Then ThD_Draw3Dsquare(BG,Points, x,y,1,1,Percent,StartX,StartY,Color,0, 0)
			End Select
			If ThreeDGame.tCamera.Z = Z Then'draw selected tile indicator
				If ThD_GridLoc.X = tempX + TheLevel.Loc.X And ThD_GridLoc.Y  = tempY + TheLevel.Loc.Y Then ThD_Draw3Dsquare(BG,Points, x,y,1,1,Percent,StartX,StartY,Colors.Red,0, -Offset)
			End If
			'START DRAW TILE
			tempPiece = TheLevel.Grid.Get(TempTileID)
			Select Case ThreeDGame.Gametype
				Case ThreeD_Minesweeper 'ThD_Fontsize
					If tempPiece.Uncovered Or API.debugMode Then
						If tempPiece.Piece = MIN_Mine Then
							ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, 8,0, Color, Alpha, True, BG2)'ThD_DrawSprite(BG,X,Y,Size,8,0, Orange)
						Else If tempPiece.Piece>0 Then
							ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, -1, tempPiece.Piece, Color, Alpha, True, BG2)'ThD_DrawSprite(BG, X,Y, Size, -1, tempPiece.Piece, Orange)
						End If
					Else'End If If Not(tempPiece.Uncovered) Then
						ThD_Draw3Dsquare(BG,Points, x,y,1,1,	Percent,StartX,StartY,Color,0, -Offset)
						If tempPiece.Mark Then
							ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, -1,0, Colors.black, Alpha, True, BG2)'ThD_DrawSprite(BG, X,Y, Size, -1, 0, Colors.black)'?
						Else If tempPiece.Flag Then
							ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, 8,1, Color, Alpha, True, BG2)'ThD_DrawSprite(BG, X,Y, Size, 8, 1, Orange)
						End If
					End If
				Case ThreeD_Checkers, ThreeD_Chess'CHK_Pawn As Int = 0, CHK_King As Int = 1
					If tempPiece.Mark Then	ThD_Draw3Dsquare(BG,Points, x,y,1,1,Percent,StartX,StartY,Colors.Blue,0,0)'can move to this spot
					If tempPiece.Team>0 Then
						ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, API.IIF(ThreeDGame.Gametype=ThreeD_Checkers, 6,0) + tempPiece.Piece ,tempPiece.Team-1, 0, Alpha, True, BG2)
						'ThD_DrawSprite(BG, X + (tempPiece.Xoffset * 0.01 * Size), Y + (tempPiece.Yoffset * 0.01 * Size), Size, API.IIF(ThreeDGame.Gametype=ThreeD_Checkers, 6,0) + tempPiece.Piece ,tempPiece.Team-1, 0)
					End If
				Case ThreeD_TicTacToe
					If tempPiece.Team>0 Then ThD_Draw3DSprite(BG, Points, x, y,1,1,Percent, StartX,StartY, 6, tempPiece.Team-1, 0, Alpha, True, BG2)'ThD_DrawSprite(BG, X, Y, Size, 6, tempPiece.Team-1, 0)
				Case ThreeD_8589934592
					If tempPiece.Piece>0 Then ThD_Draw3DSprite(BG, Points, x + (tempPiece.Xoffset*0.01*Percent), y + (tempPiece.Yoffset * 0.01* Percent),1,1,Percent, StartX,StartY, -2, tempPiece.Piece, tempPiece.Team, Alpha, True, BG2)
					'If tempPiece.Piece>0 Then NUM_DrawSprite(BG, X + (tempPiece.Xoffset * 0.01 * Size), Y + (tempPiece.Yoffset * 0.01 * Size), Size, tempPiece.Piece, tempPiece.Team)
			End Select
			
			'END DRAW TILE
			State=Not(State)
			TempTileID=TempTileID+1
			X=X+1
		Next
		If TheLevel.Width Mod 2 = 0 Then State=Not(State)'TheLevel.Width = 2 OR TheLevel.Height =2
		Y=Y+1
	Next
	ThD_Draw3Dsquare(BG, Points, TheLevel.loc.X, TheLevel.loc.Y, TheLevel.Width, TheLevel.Height, Percent, StartX,StartY, Color, Stroke, 0)'board edge
End Sub
Sub InitPoint(P As Path, PT As Point)
	P.Initialize(PT.X,PT.Y) 
End Sub
Sub MakePoint(P As Path, PT As Point)
	LCARSeffects3.MakePoint(P,PT.X,PT.Y)
End Sub
Sub MakePointP(Points() As Point, X As Float, Y As Float, Percent As Double, StartX As Float, StartY As Float, OffsetX As Float, OffsetY As Float) As Point
	Return Wireframe.CalculatePointXY2(Points(0), Points(1), Points(2), Points(3), StartX+X*Percent + OffsetX, StartY+Y*Percent + OffsetY, False, False)
End Sub
Sub ThD_Draw3Dline(BG As Canvas, Points() As Point, X1 As Float, Y1 As Float, X2 As Float, Y2 As Float, Percent As Double, StartX As Float, StartY As Float, Color As Int, Stroke As Int)
	Dim XY1 As Point = MakePointP(Points, X1, Y1, Percent, StartX, StartY, 0,0), XY2 As Point = MakePointP(Points, X2, Y2, Percent, StartX, StartY, 0,0)
	BG.DrawLine(XY1.X,XY1.Y, XY2.X,XY2.Y, Color, Stroke)
End Sub
'Offset: Positive=bigger, negative=smaller
Sub ThD_Draw3Dsquare(BG As Canvas, Points() As Point, X As Int, Y As Int, Width As Int, Height As Int, Percent As Double, StartX As Float, StartY As Float, Color As Int, Stroke As Int, Offset As Float)
	Dim P As Path
	MakePoint(P, MakePointP(Points, X, Y, Percent, StartX, StartY, -Offset, -Offset))'top left
	MakePoint(P, MakePointP(Points, X+Width, Y, Percent, StartX, StartY, Offset, -Offset))'top right
	MakePoint(P, MakePointP(Points, X+Width, Y + Height, Percent, StartX, StartY, Offset, Offset))'bottom right
	MakePoint(P, MakePointP(Points, X, Y + Height, Percent, StartX, StartY, -Offset, Offset))'bottom left
	If Stroke > 0 Then MakePoint(P, MakePointP(Points, X, Y, Percent, StartX, StartY, -Offset, -Offset))'top left
	BG.DrawPath(P, Color, Stroke=0,Stroke)
End Sub




Sub ThD_DrawMenu(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, ColorID As Int)
	Dim W2 As Int = Width / ThreeD_Menu.Size , temp As Int 
	ColorID = LCAR.GetColor(ColorID, True, 255)
	For temp = 0 To ThreeD_Menu.Size -1 
		LCARSeffects3.DrawTOSButton(BG,X,Y,W2-2,Height, API.IIF(temp = ThreeD_SelectedMenu,ColorID, Color), ThreeD_Menu.Get(temp))
		X=X+W2
	Next
End Sub

Sub ThD_DrawLevelSelect(BG As Canvas, X As Int, Y As Int, SmallSize As Int, BigSize As Int, Game As ThreeDboard, Landscape As Boolean, ColorID As Int, WidthLeft As Int, HeightLeft As Int)
	Dim temp As Int, Orange As Int = LCAR.GetColor(ColorID, False, 255), Width As Int = Game.Size.X * SmallSize * 0.5, Height As Int = Game.Size.Y * SmallSize * 0.5 , tempstr As String 
	Dim Red As Int = LCAR.GetColor(LCAR.LCAR_Red, False, 128)
	If Landscape Then 
		LCARSeffects4.DrawRect(BG,X,Y, BigSize,HeightLeft, Colors.black, 0)
	Else 
		LCARSeffects4.DrawRect(BG,X,Y, WidthLeft,BigSize, Colors.black, 0)
	End If
	If ThD_GridLoc.X < 0 Then ThD_GridLoc.X = 0
	If ThD_GridLoc.Y < 0 Then ThD_GridLoc.Y = 0
	For temp = 0 To Game.Size.Z
		LCARSeffects4.DrawRect(BG,X,Y, BigSize,BigSize,Orange, 1)
		If temp = ThreeDGame.tCamera.Z Then LCARSeffects4.DrawRect(BG, X+6,Y+6, BigSize-12, BigSize-12, Orange, 6)'border
		ThD_DrawLevels(BG,X + BigSize*0.5 - Width,Y + BigSize*0.5 - Height,temp, SmallSize, Game, ColorID)
		If temp = ThreeDGame.tCamera.Z Then'crosshairs
			LCARSeffects4.DrawRect(BG, X+3,    Y+ (SmallSize*ThD_GridLoc.Y), BigSize-6, SmallSize, Red, 0)
			LCARSeffects4.DrawRect(BG, X+ BigSize*0.5 -Width  + (SmallSize*ThD_GridLoc.X),    Y+3, SmallSize, BigSize-6, Red, 0)
		End If
		tempstr = temp
		If temp = 0 Then 
			tempstr = "BTM"
		Else If temp = Game.size.Z Then
			tempstr = "TOP"
		End If
		API.DrawTextAligned(BG, tempstr, X,Y, 0, LCAR.TOSFont, LCAR.Fontsize, Colors.blue, -1, 0, 0)
		If Landscape Then'|
			If temp > 0 Then BG.DrawLine(X,Y, X+BigSize,Y, Colors.black,2)
			Y = Y + BigSize
			HeightLeft = HeightLeft - BigSize 
		Else '---
			If temp > 0 Then BG.DrawLine(X,Y,X,Y+BigSize, Colors.Black,2)
			X = X + BigSize
			WidthLeft = WidthLeft - BigSize
		End If
	Next
	tempstr = API.iif(THD_Angle = -1, "2D", "3D")
	If Landscape Then WidthLeft = BigSize Else HeightLeft = BigSize
	LCARSeffects4.DrawRect(BG,X,Y, WidthLeft,HeightLeft,Colors.blue, 0)
	temp = BG.MeasureStringHeight(tempstr, LCAR.TOSFont, LCAR.Fontsize)*0.5
	BG.DrawText(tempstr, X+WidthLeft*0.5,Y+HeightLeft*0.5+temp , LCAR.TOSFont, LCAR.Fontsize, Colors.black, "CENTER")
End Sub
Sub ThD_DrawLevels(BG As Canvas, X As Int, Y As Int, Z As Int, Size As Int, Game As ThreeDboard, ColorID As Int)
	Dim tempLevel As ThreeDLevel , temp As Int
	If ThreeD_Opacity > 0 Then
		For temp = 0 To Game.Levels.Size-1 
			tempLevel=ThreeDGame.Levels.Get(temp)
			If Z <> tempLevel.Loc.Z Then ThD_DrawLevel(BG,X + tempLevel.Loc.X*Size, Y + tempLevel.loc.Y * Size,Size, tempLevel, ThreeD_Opacity, Z, -1, ColorID)
		Next
	End If
	For temp = 0 To Game.Levels.Size-1 
		tempLevel=ThreeDGame.Levels.Get(temp)
		If Z = tempLevel.Loc.Z Then ThD_DrawLevel(BG,X + tempLevel.Loc.X*Size, Y + tempLevel.loc.Y * Size,Size, tempLevel, 255, Z, -1, ColorID)
	Next
End Sub
Sub ThD_DrawLevel(BG As Canvas, X As Int, Y As Int, Size As Int, TheLevel As ThreeDLevel, Alpha As Int, Z As Int, Index As Int, ColorID As Int) As Int 
	Dim Width As Int = TheLevel.Width * Size, Height As Int = TheLevel.Height * Size , Thumbsize As Point , tempPiece As ThreeDPiece, TempTileID As Int  
	Dim Orange As Int = LCAR.GetColor(ColorID, False, Alpha), tempx As Int, tempy As Int ,CurrX As Int =X, State As Boolean , Count As Int = 2, Size2 As Int = Size * 0.5
	If Index = -1 Then 
		LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Orange,0)
		If ThreeDGame.Gametype <> ThreeD_Minesweeper And Z =  TheLevel.Loc.Z Then
			Y=Y+Size/2
			For tempy = 0 To TheLevel.Height-1
				X = CurrX + Size2
				For tempx = 0 To TheLevel.Width - 1 
					tempPiece = TheLevel.Grid.Get(TempTileID)
					If tempPiece.Mark Then LCARSeffects4.DrawRect(BG, X-Size2+Count, Y-Size2+Count, Size-Count*2, Size-Count*2,  Colors.Blue, 0)
					If tempPiece.Team>0 Then BG.DrawCircle( X, Y, Size2, API.IIF(tempPiece.Team = MIN_White, Colors.White, Colors.Black), True, 0)
					X=X+Size
					TempTileID=TempTileID+1
				Next
				Y=Y+Size
			Next
		End If
	Else
		If (Z Mod 2) = 0 Then 
			Thumbsize = API.Thumbsize(316,246, Width,Height, True,False)
			Count=(Height - Thumbsize.Y) * 0.5
			LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, 0,0,0,0,    X+ Width/2 - Thumbsize.X/2, Y+Height/2 - Thumbsize.Y/2, Thumbsize.X, Thumbsize.Y, Alpha, False,False)
			Thumbsize.X = Colors.ARGB(Alpha,0,0,0)
			LCARSeffects4.DrawRect(BG,X,Y,Width, Count, Thumbsize.X, 0)
			LCARSeffects4.DrawRect(BG,X,Y+Count+Thumbsize.Y,Width, Count, Thumbsize.X, 0)
			Count=0
		End If
		LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Orange,2)
		For tempy = 0 To TheLevel.Height-1
			X = CurrX
			If ThreeDGridStyle= 1 Then BG.DrawLine(X, Y, X + Width, Y, Orange,1)
			For tempx = 0 To TheLevel.Width - 1 
				Select Case ThreeDGridStyle
					Case 1: If tempy = 0 Then BG.DrawLine(X, Y, X, Y+Height, Orange,1)
					Case 2: If State Then LCARSeffects4.DrawRect(BG,X,Y,Size,Size,Orange,0)
				End Select
				If ThreeDGame.tCamera.Z = Z Then'draw selected tile indicator
					If ThD_GridLoc.X = tempx + TheLevel.Loc.X And ThD_GridLoc.Y  = tempy + TheLevel.Loc.Y Then LCARSeffects4.DrawRect(BG,X-3,Y-3,Size+6,Size+6, Colors.Red ,0)
				End If
				'START DRAW TILE
				'TempTileID = ThD_GetPoint(tempx, tempy, 0,0, TheLevel.Width, TheLevel.Height)
				tempPiece = TheLevel.Grid.Get(TempTileID)
				Select Case ThreeDGame.Gametype 
					Case ThreeD_Minesweeper 'ThD_Fontsize
						If tempPiece.Uncovered Or API.debugMode Then
							'If API.debugMode AND Not(tempPiece.Uncovered) Then LCARSeffects4.DrawRect(BG,X+6,Y+6,Size-12,Size-12, Orange,0)
							If tempPiece.Piece = MIN_Mine Then
								ThD_DrawSprite(BG,X,Y,Size,8,0, Orange)
							Else If tempPiece.Piece>0 Then
								ThD_DrawSprite(BG, X,Y, Size, -1, tempPiece.Piece, Orange)
							End If
						Else'End If If Not(tempPiece.Uncovered) Then
							LCARSeffects4.DrawRect(BG,X+6,Y+6,Size-12,Size-12, Orange,0)
							If tempPiece.Mark Then 
							 	ThD_DrawSprite(BG, X,Y, Size, -1, 0, Colors.black)'?
							Else If tempPiece.Flag Then
								ThD_DrawSprite(BG, X,Y, Size, 8, 1, Orange)
							End If
						End If
					Case ThreeD_Checkers, ThreeD_Chess'CHK_Pawn As Int = 0, CHK_King As Int = 1
						'Space Checkers adapts traditional checkers to the 3rd dimension. Instead of 12 men on an 8x8 square,
						'Each side has 8 men on a 4x4x4 cube. The adaptation Is straight-forward: Black sets up near the south lower edge AND 
						'can only move north AND up; Red sets up near the north upper edge AND can only move south AND down. Captures AND 
						'crowning are 3D analogs To the 2D Case.
						If tempPiece.Mark Then	LCARSeffects4.DrawRect(BG,X,Y,Size,Size,Colors.Blue,0)'can move to this spot
						If tempPiece.Team>0 Then
							ThD_DrawSprite(BG, X + (tempPiece.Xoffset * 0.01 * Size), Y + (tempPiece.Yoffset * 0.01 * Size), Size, API.IIF(ThreeDGame.Gametype=ThreeD_Checkers, 6,0) + tempPiece.Piece ,tempPiece.Team-1, 0)
						End If
					Case ThreeD_TicTacToe
						If tempPiece.Team>0 Then ThD_DrawSprite(BG, X, Y, Size, 6, tempPiece.Team-1, 0)
					Case ThreeD_8589934592
						If tempPiece.Piece>0 Then NUM_DrawSprite(BG, X + (tempPiece.Xoffset * 0.01 * Size), Y + (tempPiece.Yoffset * 0.01 * Size), Size, tempPiece.Piece, tempPiece.Team)
				End Select
				'END DRAW TILE
				X=X+Size
				State=Not(State)
				Count=Count+1
				TempTileID=TempTileID+1
			Next
			If TheLevel.Width Mod 2 = 0 Then State=Not(State)'TheLevel.Width = 2 OR TheLevel.Height =2
			Y=Y+Size
		Next
		Return Count
	End If
End Sub

Sub ThD_CanResume(DoResume As Boolean) As Boolean 
	If ThreeDGame.isinitialized Then
		If ThreeDGame.Size.X>0 And ThD_GameOver.Length=0 Then
			If DoResume Then 
				LCAR.ForceShow(ThreeD_ElementID,True)
				LCAR.GetElement(ThreeD_ElementID).Opacity.Current = 255
			End If
			Return True
		End If
	End If
End Sub

'Row: -1 Text (0=?) 1 and up will print the number
'Columns:       0      1       2      3      4      5      6     7    8
'Row: 0 White (Pawn, Bishop, Knight, Rook, Queen, King) (Pawn, King) Mine
'Row: 1 Black (Pawn, Bishop, Knight, Rook, Queen, King) (Pawn, King) Flag 
Sub ThD_DrawSprite(BG As Canvas, X As Int, Y As Int, Size As Int, Col As Int, Row As Int, Color As Int)
	Dim Text As String 
	If Col=-1 Then
		If ThD_Fontsize = 0 Then ThD_Fontsize = API.GetTextLimitedHeight(BG, Size,Size, "99", LCAR.TOSFont)
		If Row > 0 Then Text = Row Else Text = API.IIFIndex(Abs(Row), Array As String("?", "X"))
		API.DrawTextAligned(BG, Text,  X+Size/2, Y+Size/2, 0, LCAR.TOSFont, ThD_Fontsize, Color, -5, 0, 0)
	Else
		BG.DrawBitmap(ThreeD_Sprites, LCARSeffects4.SetRect(Col*64, Row*64, 64,64), LCARSeffects4.SetRect(X,Y,Size,Size))
	End If
End Sub

'Row: 9999=UFP logo
'Col: -2: PdP/2048 tile, -1= Row: Positive=print that number, -1: ?, -2: X
Sub ThD_Draw3DSprite(BG As Canvas, Points() As Point, X As Float, Y As Float, Width As Float, Height As Float, Percent As Double, StartX As Float, StartY As Float, Col As Int, Row As Int, Color As Int, Alpha As Int, Flat As Boolean, BG2 As Canvas)
	Dim P(4) As Point, Text As String, Left As Int = P(0).X, Right As Int = P(0).X, Top As Int = P(0).Y, Bottom As Int = P(0).Y, temp As Int
	If Col<0 Or Flat Then 
		P(0) = MakePointP(Points, X, Y, Percent, StartX, StartY, 0, 0)'top left
		P(1) = MakePointP(Points, X+Width, Y, Percent, StartX, StartY, 0, 0)'top right
		P(2) = MakePointP(Points, X+Width, Y + Height, Percent, StartX, StartY, 0, 0)'bottom right
		P(3) = MakePointP(Points, X, Y + Height, Percent, StartX, StartY, 0, 0)'bottom left
		For temp = 1 To 3
			If P(temp).X < Left Then Left = P(temp).X
			If P(temp).Y < Top Then Top = P(temp).Y
			If P(temp).X > Right Then Right = P(temp).X
			If P(temp).Y > Bottom Then Bottom = P(temp).Y
		Next
		Width = Right - Left
		Height = Bottom - Top
		temp=Max(Width,Height)
	End If 
	If Row = 9999 Then'UFP logo
		LCARSeffects2.DrawBMPpoly(BG, LCARSeffects2.CenterPlatform, Array As Float(0,0,	LCARSeffects2.CenterPlatform.Width,0,	LCARSeffects2.CenterPlatform.Width,LCARSeffects2.CenterPlatform.Height,	0,LCARSeffects2.CenterPlatform.Height), Array As Float(P(0).X, P(0).Y,  	 P(1).X, P(1).Y,			P(2).X, P(2).Y,			P(3).X, P(3).Y), Alpha, True)
	else if Col= -2 Then'2048 square using PdP
		NUM_DrawSprite(BG2, 0, 0, 64, Row, Color)
		LCARSeffects2.DrawBMPpoly(BG, LCARSeffects4.TRI_FrameA, Array As Float(0,0,	64,0,	64,64,	0,64), Array As Float(P(0).X, P(0).Y,  	 P(1).X, P(1).Y,			P(2).X, P(2).Y,			P(3).X, P(3).Y), Alpha, True)
	else If Col=-1 Then'Text (minesweeper)
		If Row > 0 Then Text = Row Else Text = API.IIFIndex(Abs(Row), Array As String("?", "X"))
		BG2.DrawColor(Colors.Transparent)
		temp = BG2.MeasureStringHeight(Text, LCAR.TOSFont, ThD_Fontsize) 
		BG2.DrawText(Text, 32, 32 + temp * 0.5, LCAR.TOSFont, ThD_Fontsize, Color, "CENTER")
		LCARSeffects2.DrawBMPpoly(BG, LCARSeffects4.TRI_FrameA, Array As Float(0,0,	64,0,	64,64,	0,64), Array As Float(P(0).X, P(0).Y,  	 P(1).X, P(1).Y,			P(2).X, P(2).Y,			P(3).X, P(3).Y), Alpha, True)
	Else'Sprite
		X = Col*64
		Y = Row*64
		If Flat Then 
			LCARSeffects2.DrawBMPpoly(BG, ThreeD_Sprites, Array As Float(X,Y,	X+64,Y,	X+64,Y+64,	X,Y+64), Array As Float(P(0).X, P(0).Y,  	 P(1).X, P(1).Y,			P(2).X, P(2).Y,			P(3).X, P(3).Y), Alpha, True)
		Else 
			BG.DrawBitmap(ThreeD_Sprites, LCARSeffects4.SetRect(X, Y, 64,64), LCARSeffects4.SetRect(Left, Top + Height * 0.5 - Width, Width,Width))
		End If 
	End If
End Sub


Sub ThD_GetPoint(X As Int, Y As Int, bX As Int, bY As Int, bWidth As Int, bHeight As Int) As Int
	X=X-bX
	Y=Y-bY
	If X>= bWidth Or Y>= bHeight Or X<0 Or Y<0 Then Return -1 Else Return Y * bWidth + X
End Sub
Sub ThD_Get3Dpoint(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Point 
	Dim temp As Int, tempLevel As ThreeDLevel , temp2 As Int  
	If X <0 Or Y<0 Or Z<0 Then'get random tile
		temp = Rnd(0, Game.Levels.Size )
		tempLevel = Game.Levels.Get( temp )
		temp2 = Rnd(0, tempLevel.Grid.Size)
		Return Trig.SetPoint(temp, temp2)
	Else
		For temp = 0 To Game.Levels.Size-1
			tempLevel = Game.Levels.Get(temp)
			If tempLevel.Loc.Z = Z Then
				If X >= tempLevel.Loc.X And X < tempLevel.Loc.X + tempLevel.Width Then
					If Y >= tempLevel.Loc.Y And Y < tempLevel.Loc.Y + tempLevel.Height Then
						temp2 = ThD_GetPoint(X,Y, tempLevel.loc.X, tempLevel.Loc.Y, tempLevel.Width, tempLevel.height)
						If temp2>-1 And temp2 < tempLevel.Grid.Size Then Return Trig.SetPoint(temp, temp2)
					End If
				End If
			End If
		Next
		Return Trig.SetPoint(-1,-1)
	End If
End Sub
Sub ThD_Get3Dpoint2(Game As ThreeDboard, X As Int, Y As Int) As Point 
	Dim temp As Int, tempPoint As Point 
	For temp = 0 To Game.Size.Z 
		tempPoint = ThD_Get3Dpoint(Game,X,Y,temp)
		If tempPoint.X >-1 And tempPoint.Y >-1 Then Return tempPoint
	Next
	Return Trig.SetPoint(-1,-1)
End Sub
Sub ThD_Get3DpieceP(Game As ThreeDboard, tPiece As Point ) As ThreeDPiece
	Return ThD_Get3Dpiece(Game, tPiece.x, tPiece.y)
End Sub
Sub ThD_Get3Dpiece(Game As ThreeDboard, tLevel As Int, SpotIndex As Int) As ThreeDPiece 
	Dim tempLevel As ThreeDLevel = Game.Levels.Get( tLevel )
	Return tempLevel.Grid.Get(SpotIndex)
End Sub
Sub ThD_Get3DpieceXYZ(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As ThreeDPiece 
	Dim temp As Point = ThD_Get3Dpoint(Game, X,Y,Z), temp2 As ThreeDPiece
	If temp.X > -1 And temp.Y>-1 And Z >-1 And Z< Game.Levels.Size Then Return ThD_Get3DpieceP(Game, temp)
	Return temp2
End Sub
Sub ThD_ToggleDrawingMode
	If ThreeDGame.Size.Z > 1 Then 
		ThD_Fontsize = 0
		PDPfontsize = 0
		If THD_Angle = -1 Then THD_Angle = 0 Else THD_Angle = -1 
		LCAR.IsClean=False
	End If
End Sub
Sub ThD_HandleMouse(X As Int, Y As Int, Action As Int)
	Dim Region As Int, Index As Int, IndexY As Int, DiffX As Int = X, DPADSize As Int, DiffY As Int = Y, Size As Int  = Min(ThreeDSize, API.IIF(ThD_Landscape, LCAR.scaleHeight,LCAR.scalewidth) / (ThreeDGame.Size.Z+1)), Width As Int=LCAR.ScaleWidth, Height As Int = LCAR.ScaleHeight ,temp As Int
	Dim ThD_WasScrolling As Boolean = ThD_IsScrolling
	'SavedPoints(5) = Trig.setpoint(X,Y)
	If Action = LCAR.LCAR_Dpad Then'0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
		Select Case ThreeDGame.Gametype 
			Case ThreeD_Minesweeper
				Select Case X 
					Case -1: ThreeD_SelectedMenu= 3 'x (CHK)
					Case 4:  ThreeD_SelectedMenu= 4 '[] (FLG)
					Case 5:  ThreeD_SelectedMenu= 5 'TRI (?)
				End Select
			Case ThreeD_8589934592
				Select Case X 
					Case 0,1,2,3:	NUM_ShiftBoard(ThreeDGame, X)'Direction: 0=north, 1=east, 2=south, 3=west, 4=up, 5=down
					Case -1,7:		NUM_ShiftBoard(ThreeDGame, 4)'X, Rs (Up)
					Case 4,6:		NUM_ShiftBoard(ThreeDGame, 5)'[],LS (Down)
				End Select
				Return
		End Select
		Select Case X 
			Case 0'UP
				ThD_GridLoc.Y = Max(0, ThD_GridLoc.Y - 1)
				ThreeDGame.tCamera.Y = Min(0, ThreeDGame.tCamera.Y + 1)
				
			Case 1'RIGHT
				ThD_GridLoc.X = Min(ThreeDGame.Size.X, ThD_GridLoc.X + 1)
				ThreeDGame.tCamera.X = Max(-ThreeDGame.Size.X + ThD_Screensize.X, ThreeDGame.tCamera.X -1)
				
			Case 2'DOWN
				ThD_GridLoc.Y = Min(ThreeDGame.Size.Y, ThD_GridLoc.Y + 1)
				ThreeDGame.tCamera.Y = Max(-ThreeDGame.Size.Y + ThD_Screensize.Y, ThreeDGame.tCamera.Y -1)
				
			Case 3'LEFT
				ThD_GridLoc.X = Max(0, ThD_GridLoc.X - 1)
				ThreeDGame.tCamera.X = Min(0, ThreeDGame.tCamera.X + 1)
			
			Case 4,5'[],Tri
				If THD_Angle > -1 Then 
					'If X = 4 Then THD_Angle = THD_Angle - 15 Else THD_Angle = THD_Angle + 15
					'THD_Angle = Trig.CorrectAngle(THD_Angle)
				End If
			
			Case 6: ThreeDGame.tCamera.z = Max(0,ThreeDGame.tCamera.z-1)'left shoulder
			Case 7: ThreeDGame.tCamera.z = Min(ThreeDGame.Size.Z, ThreeDGame.tCamera.z+1)'right shoulder
		End Select
		If X>-2 And X<6 Then 
			If X >-1 Then ThD_IsScrolling = True
			ThD_GridClicked(ThD_GridLoc.X, ThD_GridLoc.Y, ThreeDGame.tCamera.Z, PT_Local)
			ThD_IsScrolling = False
		End If
		
		LCAR.IsClean=False
		Return
	Else If Action = LCAR.Event_Move Then 
		ThD_MouseLoc.X = ThD_MouseLoc.X + X
		ThD_MouseLoc.Y = ThD_MouseLoc.Y+ Y
	Else
		ThD_MouseLoc = Trig.SetPoint(X,Y)
		ThD_IsScrolling=False
	End If
	X=ThD_MouseLoc.X
	Y=ThD_MouseLoc.Y
	
	If ThreeD_Dpad Then
		DPADSize = 300 * LCAR.GetScalemode
		If X > LCAR.scalewidth-DPADSize And Y > LCAR.scaleheight-DPADSize Then Region = 3
	End If
	If Region = 0 Then
		If ThD_Landscape Then '[|----]
			If X < Size And ThreeDGame.Size.Z>0 Then 
				Region = 1'Z level select
				'Index = Min(Floor(Y / Size), ThreeDGame.Size.Z)
				Index = Floor(Y / Size)
				If Index > ThreeDGame.Size.Z Then Region = 4'toggle 3d
			Else If Y <= LCAR.ItemHeight Then
				Index = Floor((X-Size) / ((LCAR.scalewidth-Size) / ThreeD_Menu.Size))
			Else
				Region = 2
				If ThreeDGame.Size.Z>0 Then
					X=X-Size-1
					Width=Width-Size-1
				End If
				Y=Y-LCAR.ItemHeight-1
				Height=Height-LCAR.ItemHeight-1
			End If
		Else'|
			If Y<=LCAR.ItemHeight Then'menu
				Index = Floor(X / (LCAR.scalewidth / ThreeD_Menu.Size))
			Else If Y<= LCAR.ItemHeight + Size  And ThreeDGame.Size.Z>0  Then
				Region = 1'Z level select
				'Index = Min(Floor(X / Size),ThreeDGame.Size.Z)
				Index = Floor(X / Size)
				If Index > ThreeDGame.Size.Z Then Region = 4'toggle 3d
			Else
				Region = API.IIF(ThreeDGame.Size.Z>0 , 2+Size ,1)
				Y=Y-LCAR.ItemHeight- Region
				Height = Height - LCAR.ItemHeight- Region
				Region = 2'board
			End If
		End If
	End If
	
	Select Case Region
		Case 0'menu
			If Action = LCAR.Event_Up Then
				If Index >= ThreeD_Menu.Size-1 Then'Back
					LCAR.SystemEvent(0,49)
				Else 
					Select Case Index
						Case 0'new
							ThD_NewGame(-1, ThreeDGame.Gametype, ThreeDGame.Difficulty, ThreeDGame.Mines) 
						Case 1, 2' +/-
							ThreeDSize= Max(ThreeDSize* API.IIF(Index=1,2, 0.5), 32)
							PDPfontsize = 0'API.GetTextHeight(LCAR.EmergencyBG, ThreeDSize*0.4, "0123",  LCAR.LCARfont) 
							ThD_Fontsize=0
						Case Else
							Select Case ThreeDGame.Gametype '& "." & Index
								Case ThreeD_Minesweeper
									ThreeD_SelectedMenu = Index ' 3 CHK, 4 FLG, 5 ?
							End Select
					End Select
					LCAR.IsClean=False
					'Log("MENU ITEM: " & ThreeD_Menu.Get(Index))
				End If
			End If
		Case 1'Z level select
			If Action = LCAR.Event_Up Then
				ThreeDGame.tCamera.z = Index
				Log("Z: " & Index)
				LCAR.IsClean=False
			End If
		Case 2'grid
			If THD_Angle = -1 Then '2D drawing mode
				If Action <> LCAR.Event_Up Then 
					Index = Floor(X/ThreeDSize) - ThreeDGame.tCamera.X
					IndexY = Floor(Y/ThreeDSize) - ThreeDGame.tCamera.Y
				End If
				If Action= LCAR.Event_Move And ThD_GridLoc.IsInitialized Then
					If Index <> ThD_GridLoc.X Or IndexY <> ThD_GridLoc.Y Then
						ThD_IsScrolling = True
						DiffX= ThD_GridLoc.X -Index
						DiffY = ThD_GridLoc.Y - IndexY
						temp=Min(0, Max( ThreeDGame.tCamera.X - DiffX, -ThreeDGame.Size.X + Floor(Width/ThreeDSize)))
						If temp <> ThreeDGame.tCamera.X Then
							ThreeDGame.tCamera.X = temp
							Index = Index + DiffX
						End If
						temp= Min(0, Max( ThreeDGame.tCamera.Y - DiffY, -ThreeDGame.Size.Y+ Floor(Height/ThreeDSize)))
						If temp <> ThreeDGame.tCamera.Y Then
							ThreeDGame.tCamera.Y = temp'Min(0, Max( ThreeDGame.tCamera.Y - DiffY, -ThreeDGame.Size.Y+ Floor(Height/ThreeDSize)))
							IndexY = IndexY + DiffY
						End If
						LCAR.IsClean=False
					End If
				End If
				If Action <> LCAR.Event_Up Then ThD_GridLoc = Trig.SetPoint(Index,IndexY)
				If Action = LCAR.Event_Up And Not(ThD_WasScrolling) Then
					ThD_GridClicked(ThD_GridLoc.X, ThD_GridLoc.Y, ThreeDGame.tCamera.Z, PT_Local)
					LCAR.IsClean=False
				End If
			Else'3D drawing mode
				If Not(ThD_IsScrolling) Then
					Dim tempP As ThreeDPoint = ThD_GetClickedGrid(ThD_MouseLoc.X,ThD_MouseLoc.Y, SavedPoints, THD_Angle, ThreeDGame)
					If tempP.Z <> ThreeDGame.tCamera.Z And tempP.Z> -1 Then 
						ThreeDGame.tCamera.Z = tempP.Z
						LCAR.IsClean=False
					End If
					If tempP.X = -1 Or tempP.Y = -1  Or tempP.Z = -1 Then 
						If Action = LCAR.Event_Down Then 
							ThD_IsScrolling = True 
							'LCAR.PlaySound(12,False)'play error noise
							'LCAR.ToastMessage(LCAR.EmergencyBG, "YOU MUST CLICK WITHIN THE BLUE SQUARE", 2)
						End If
					else If Action = LCAR.Event_Down Then
						ThD_GridLoc = Trig.SetPoint(tempP.X, tempP.Y)
						'Log("Down at: " & tempP.X & ", " & tempP.Y)
					else if Action = LCAR.Event_Move And ThD_GridLoc.IsInitialized And Not(ThD_IsScrolling) Then
						If tempP.X <> ThD_GridLoc.X Or tempP.Y <> ThD_GridLoc.Y Then ThD_IsScrolling = True
					else if Action = LCAR.Event_Up Then
						'Log("UP")
						ThD_GridClicked(ThD_GridLoc.X, ThD_GridLoc.Y, ThreeDGame.tCamera.Z, PT_Local)
						LCAR.IsClean=False
					End If
				End If 
				'If Action = LCAR.Event_Up Then'ThD_GetClickedCoordinate(ThD_MouseLoc.X,ThD_MouseLoc.Y, SavedPoints, THD_Angle)
				If Action = LCAR.Event_Move And ThD_IsScrolling Then 
					THD_Angle = Trig.CorrectAngle(THD_Angle - DiffX)
					ThD_Fontsize = 0
					THD_Zoom = Min(Max(0.1, THD_Zoom - DiffY*0.01), 10)
					LCAR.IsClean=False
				End If
			End If 
		Case 3'dpad
			If Action = LCAR.Event_Up Then
				Index = LCARSeffects.GetDPADdirection(LCAR.ScaleWidth - DPADSize, LCAR.ScaleHeight-DPADSize, DPADSize,DPADSize, X,Y)
				'Log("DIRECTION BEFORE: " & Index & " 1: south east, 2: south, 3: south west, 4: west, 5: center, 6: east, 7: north east, 8: north, 9: north west")
				Index = DPAD_TO_DPAD(Index)
				'Log("DIRECTION AFTER: " & Index & " 0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start")
				If Index > -2 Then ThD_HandleMouse(Index, 0, LCAR.LCAR_Dpad)
				LCAR.IsClean=False
			End If
		Case 4'toggle 3d
			If Action = LCAR.Event_Up Then ThD_ToggleDrawingMode
	End Select
End Sub

Sub ThD_GetClickedGrid(X As Int, Y As Int, Points() As Point, Angle As Int, Game As ThreeDboard) As ThreeDPoint
	Dim XY() As Float = ThD_GetClickedCoordinate(X,Y,Points,Angle), temp As Int', StartX As Int, StartY As Int, Longest As Int = Max(Game.Size.X, Game.Size.Y)
	'StartX = (Longest * 0.5 - Game.Size.X * 0.5)/Longest
	'StartY = (Longest * 0.5 - Game.Size.Y * 0.5)/Longest
	'tempRet(0) = XY(0) tempRet(1) = XY(1)
	If XY(0) >= 0 And XY(0) <= 1 And XY(1) >= 0 And XY(1) <= 1 Then Return Set3DPoint(XY(0) * Game.Size.X, XY(1) * Game.Size.Y, Game.tCamera.Z)
	temp = Game.size.Z - Game.tCamera.Z
	'Log(Game.tCamera.Z & " FAILED: " & temp)
	'LogPoints("BASE", Points)
	For temp = -1 To Game.size.Z - Game.tCamera.Z
		If temp <> 0 Then 
			XY = ThD_GetClickedCoordinate(X,Y,PointsAlias(Points, SavedZ, temp),Angle)
			'Log(temp & ": " & XY(0) & " - " & XY(1))
			If XY(0) >= 0 And XY(0) <= 1 And XY(1) >= 0 And XY(1) <= 1 Then Return Set3DPoint(XY(0) * Game.Size.X, XY(1) * Game.Size.Y, Game.tCamera.Z + temp)
		End If
	Next 
	Return Set3DPoint(-1,-1,-1)
End Sub
Sub Set3DPoint(X As Int, Y As Int, Z As Int) As ThreeDPoint
	Dim RET As ThreeDPoint
	RET.Initialize
	RET.X = X 
	RET.Y = Y 
	RET.Z = Z 
	Return RET 
End Sub
Sub PointsAlias(Points() As Point, Zoffset As Int, Z As Int) As Point()
	Dim temp As Int, PointsCopy(4) As Point 
	Zoffset = Zoffset * -Z
	For temp = 0 To 3
		PointsCopy(temp) = Trig.setpoint( Points(temp).X, Points(temp).Y + Zoffset )
	Next
	'LogPoints("PointsAlias " & Z, PointsCopy)
	Return PointsCopy
End Sub
'Returns the X,Y clicked within a rotated/flattened grid using the points() format from wireframe.cachepoints
Sub ThD_GetClickedCoordinate(X As Int, Y As Int, Points() As Point, Angle As Int) As Float()
	'Points(): 0=top left, 1=top right, 2=bottom left, 3=bottom right, 4=RadiusX,RadiusY	
	Dim XY2 As Point = Trig.setpoint(X + Points(0).X-Points(2).X, Y + Points(0).Y-Points(2).Y) 'away from X,Y at angle+Angle2
	Dim XY3 As Point = Trig.setpoint(X + (Points(0).X-Points(1).X), Y + (Points(0).Y-Points(1).Y))'away from X,Y at angle-Angle2
	Dim Xint As Point = Trig.LineLineIntercept(Points(0).X, Points(0).Y, Points(1).X, Points(1).Y, X,Y, XY2.X, XY2.Y)'intercept of X,Y+away from X,Y+angle2 and points(0)+points(1)
	Dim Yint As Point = Trig.LineLineIntercept(Points(0).X, Points(0).Y, Points(2).X, Points(2).Y, X,Y, XY3.X, XY3.Y)'intercept of X,Y+away from X,Y-angle2 and points(0)+points(1)
	Dim RET(2) As Float
	RET(0) = GetPercent(Points(0).X, Points(1).X, Xint.X)
	RET(1) = GetPercent(Points(0).Y, Points(2).Y, Yint.Y)
	Return RET 
End Sub
'Sub PT2S(PT As Point) As String 
'	Return " - X: " & PT.X & " Y: " & PT.Y
'End Sub
Sub GetPercent(Bottom As Int, Top As Int, Value As Int) As Float 
	'Log("GetPercent: " & Bottom & " " & Top & " = " & Value)
	If Bottom > Top Then Return 1-(Value - Top)/(Bottom - Top)
	Return (Value - Bottom)/(Top - Bottom)
End Sub

'Input: Dpad direction from the LCARS element
'0: out of bounds, 1: south east, 2: south, 3: south west, 4: west, 5: center, 6: east, 7: north east, 8: north, 9: north west
'Output: Dpad direction for HandleMouse
'0=up, 1=right, 2=down, 3=left, -1=X (Up), 4=[] (Down), 5=Tri, 6=Ls (Down), 7=Rs (Up), 8=Start
Sub DPAD_TO_DPAD(Index As Int) As Int 
	Select Case Index 
		Case 1:Return 4'down left ([])
		Case 2:Return 2'down (down)
		Case 3:Return 6'down right (Ls)
		Case 4:Return 3'left (left)
		Case 5:Return -2'middle (nothing)
		Case 6:Return 1'right (right)
		Case 7:Return 7'up left (Rs)
		Case 8:Return 0'up (up)
		Case 9:Return -1'up right (X)
	End Select
End Sub
Sub ThD_GridClicked(X As Int, Y As Int, Z As Int, InputType As Int)As Boolean 
	Dim TileID As Point = ThD_Get3Dpoint(ThreeDGame, X, Y, Z) , tempPiece As ThreeDPiece , tempLevel As ThreeDLevel 
	If ThreeDGame.Gametype <> ThreeD_Minesweeper And API.IIF(CurrentPlayer =MIN_White, Player1Type, Player2Type) <> InputType Then Return False
	
	If TileID.X = -1 And TileID.Y = -1 Then 'map to next level if this tile is empty
		TileID = ThD_Get3Dpoint2(ThreeDGame,X,Y)
		If TileID.X <> -1 And TileID.Y <> -1 Then
			tempLevel = ThreeDGame.Levels.Get(TileID.X)
			Z = tempLevel.Loc.Z 
			ThreeDGame.tCamera.Z = Z
			LCAR.IsClean = False
		End If
	End If
	If ThD_IsScrolling Then Return False 
	
	Log("ThD_GridClicked: " & X & " " & Y & " " & Z & " Level index: " & TileID.X & " Tile Index: " & TileID.Y)
	If TileID.X > -1 And TileID.Y > -1 And ThD_GameOver.Length=0 Then
		ThD_MultiplayerData(True, ThreeD_SelectedMenu, X,Y,Z, 0)
		tempPiece = ThD_Get3DpieceP(ThreeDGame, TileID)
		Select Case ThreeDGame.Gametype '& "." & Index
			Case ThreeD_Minesweeper
				Select Case ThreeD_SelectedMenu
					Case 3'CHK
						If TurnsTaken = 0 And tempPiece.Piece = MIN_Mine Then'make sure first move doesn't have a mine
							MIN_PlaceMines(ThreeDGame, 1)
							tempPiece.Piece = 0
						End If
						TurnsTaken = TurnsTaken + 1
						MIN_ClearMap(ThreeDGame,   True,         False,           False,        False,      False,     False,          False)'sets all checked values to false
                		MIN_Uncover(ThreeDGame, X, Y, Z, True, True)'check XYZ
						MIN_CheckForWin(ThreeDGame)
					Case 4'FLG
						If Not(tempPiece.Uncovered) Then
							tempPiece.Flag = Not(tempPiece.Flag)
							ThreeDGame.Flags = ThreeDGame.Flags + API.IIF(tempPiece.Flag, 1, -1)
							ThD_RefreshScores
							MIN_CheckForWin(ThreeDGame)
						End If
					Case 5: If Not(tempPiece.Uncovered) Then tempPiece.Mark = Not(tempPiece.Mark) '?
				End Select
			
			Case ThreeD_TicTacToe'
				If ThD_AddPiece(ThreeDGame, X,Y,Z, CurrentPlayer, 0, False, False) Then 
					If TTT_CheckIfWon(ThreeDGame, X,Y,Z, CurrentPlayer) Then
						ThD_PlayerWon(CurrentPlayer)
					Else If TTT_CheckIfFull(ThreeDGame) Then
						ThD_PlayerWon(0) 
					Else
						ThD_ChangeTeam
					End If
				End If
			
			Case ThreeD_Checkers, ThreeD_Chess
				CHK_Action(ThreeDGame, X,Y,Z)
				
		End Select
		LastTurn = ThD_Set3DPoint(X,Y,Z)
		ThD_SetAnimation(0)
	End If
	Return True
End Sub

Sub ThD_SetAnimation(Frames As Int) As Boolean 
	Dim Element As LCARelement = LCAR.LCARelements.Get(ThreeD_ElementID)
	If Frames >0 Then 
		Element.RWidth = Frames 
		Element.Align=0
	Else If Frames = 0 Then
		Element.LWidth = Element.RWidth 
	Else 'if frames < 0 then
		If Element.RWidth = 1 Then 'Return True
			If Element.Align = 0 Then 
				Element.Align= 1
				Return True
			End If
		End If
		Element.RWidth = Max(1,Element.RWidth + Frames )
	End If
End Sub









'TicTacToe-specific code
Sub TTT_CheckIfWon(Game As ThreeDboard, X As Int,Y As Int,Z As Int, PlayerID As Int) As Boolean
	Dim BestMoveID As Int = TTT_FindBestMove(Game, PlayerID), SizeXY As Int = ThreeDGame.Difficulty
	If TTT_ValueOfMove(ThreeDGame,BestMoveID,CurrentPlayer) = SizeXY Then Return True 
	
'	Dim temp As Int, Count1 As Int, Count2 As Int, Count3 As Int, Count4 As Int, Count5 As Int, SizeXY As Int = ThreeDGame.Difficulty 'Game.Size.X
'	For temp = 0 To SizeXY-1'-|/\ on 2d plane
'		If TTT_CheckTile(Game, temp, Y,Z,PlayerID) Then 								Count1 = Count1+1	'- left/right centered on Y
'		If TTT_CheckTile(Game, X, temp,Z,PlayerID) Then 								Count2 = Count2+1	'| up/down centered on X
'		If TTT_CheckTile(Game, temp, temp,Z,PlayerID) Then 								Count3 = Count3+1	'\ up-left/down-right
'		If TTT_CheckTile(Game, temp, SizeXY-temp-1,Z,PlayerID) Then 					Count4 = Count4+1	'/ up-right/down-left
'	Next
'	If Count1 = SizeXY OR Count2 = SizeXY OR Count3 = SizeXY OR Count4 = SizeXY Then Return True 
'	If Game.Size.Z>0 Then
'		Count1=0:Count2=0:Count3=0:Count4=0'reset
'		For temp = 0 To SizeXY-1'3d plane centered on XYZ
'			If TTT_CheckTile(Game, X,Y, temp, PlayerID)  Then							Count1 = Count1+1	'up/down centered on X/Y
'			If TTT_CheckTile(Game, temp,Y, temp, PlayerID) Then							Count2 = Count2+1	'up-left/down-right centered on Y
'			If TTT_CheckTile(Game, SizeXY-temp-1,Y, temp, PlayerID) Then				Count3 = Count3+1	'up-right/down-left centered on Y
'			If TTT_CheckTile(Game, X,temp, temp, PlayerID) Then							Count4 = Count4+1	'up-north/down-south centered on X
'			If TTT_CheckTile(Game, X,SizeXY-temp-1, temp, PlayerID) Then				Count4 = Count4+1	'up-south/down-north centered on X
'		Next
'		If Count1 = SizeXY OR Count2 = SizeXY OR Count3 = SizeXY OR Count4 = SizeXY OR Count5 = SizeXY Then Return True 
'		Count1=0:Count2=0:Count3=0:Count4=0:Count5=0'reset
'		For temp = 0 To SizeXY-1'3d plane diagonals
'			If TTT_CheckTile(Game, temp,temp, temp, PlayerID)  Then						Count1 = Count1+1	'up-left-north/down-right-south
'			If TTT_CheckTile(Game, SizeXY-temp-1,temp, temp, PlayerID) Then				Count2 = Count2+1	'up-right-north/down-left-south
'			If TTT_CheckTile(Game, temp,SizeXY-temp-1, temp, PlayerID)  Then			Count3 = Count3+1	'up-left-south/down-right-north
'			If TTT_CheckTile(Game, SizeXY-temp-1,SizeXY-temp-1, temp, PlayerID) Then	Count4 = Count4+1	'up-right-south/down-left-north
'		Next
'		If Count1 = SizeXY OR Count2 = SizeXY OR Count3 = SizeXY OR Count4 = SizeXY Then Return True 
'	End If
End Sub
Sub TTT_CheckTile(Game As ThreeDboard, X As Int,Y As Int,Z As Int, PlayerID As Int) As Boolean 
'	Dim TileID As Point = ThD_Get3Dpoint(ThreeDGame, X, Y, Z) , tempPiece As ThreeDPiece
'	If TileID.X > -1 AND TileID.Y > -1 Then
'		tempPiece = ThD_Get3DpieceP(ThreeDGame, TileID)
'		If tempPiece.Team = PlayerID Then Return True
'	End If
	Return TTT_GetTeam(Game,X,Y,Z) = PlayerID
End Sub
Sub TTT_GetTeam(Game As ThreeDboard, X As Int,Y As Int,Z As Int) As Int
	Dim TileID As Point = ThD_Get3Dpoint(ThreeDGame, X, Y, Z) , tempPiece As ThreeDPiece
	If TileID.X > -1 And TileID.Y > -1 Then
		tempPiece = ThD_Get3DpieceP(ThreeDGame, TileID)
		Return tempPiece.Team
	End If
	Return -1
End Sub

'Sub TTT_CheckStats(Game As ThreeDboard, X As Int,Y As Int,Z As Int, PlayerID As Int, ReturnPoints As Int) As List 
'	Dim temp As Int, Count1 As Int, Count2 As Int, Count3 As Int, Count4 As Int, Count5 As Int, SizeXY As Int = Game.Size.X, RetList As List 
'	RetList.Initialize 
'	For temp = 0 To SizeXY-1'-|/\ on 2d plane
'		Count1 = TTT_CheckStat(Game, temp, Y,Z,PlayerID,ReturnPoints, 0, RetList, Count1)								'- left/right centered on Y
'		Count2 = TTT_CheckStat(Game, X, temp,Z,PlayerID,ReturnPoints, 1, RetList, Count2)								'| up/down centered on X
'		Count3 = TTT_CheckStat(Game, temp, temp,Z,PlayerID,ReturnPoints, 2, RetList, Count3)							'\ up-left/down-right
'		Count4 = TTT_CheckStat(Game, temp, SizeXY-temp-1,Z,PlayerID,ReturnPoints, 3, RetList, Count4)					'/ up-right/down-left
'	Next
'	If ReturnPoints=-1 Then RetList.AddAll( Array As Int(Count1, Count2, Count3, Count4))
'	If Game.Size.Z>0 Then
'		Count1=0:Count2=0:Count3=0:Count4=0'reset
'		For temp = 0 To SizeXY-1'3d plane centered on XYZ
'			Count1 = TTT_CheckStat(Game, X,Y, temp, PlayerID,ReturnPoints, 4, RetList, Count1)							'up/down centered on X/Y
'			Count2 = TTT_CheckStat(Game, temp,Y, temp, PlayerID,ReturnPoints, 5, RetList, Count2)						'up-left/down-right centered on Y
'			Count3 = TTT_CheckStat(Game, SizeXY-temp-1,Y, temp, PlayerID,ReturnPoints, 6, RetList, Count3)				'up-right/down-left centered on Y
'			Count4 = TTT_CheckStat(Game, X,temp, temp, PlayerID,ReturnPoints, 7, RetList, Count4)						'up-north/down-south centered on X
'			Count5 = TTT_CheckStat(Game, X,SizeXY-temp-1, temp, PlayerID,ReturnPoints, 8, RetList, Count5)				'up-south/down-north centered on X
'		Next
'		If ReturnPoints=-1 Then RetList.AddAll( Array As Int(Count1, Count2, Count3, Count4, Count5))
'		Count1=0:Count2=0:Count3=0:Count4=0:Count5=0'reset
'		For temp = 0 To SizeXY-1'3d plane diagonals
'			Count1 = TTT_CheckStat(Game, temp,temp, temp, PlayerID,ReturnPoints, 9, RetList, Count1)					'up-left-north/down-right-south
'			Count2 = TTT_CheckStat(Game, SizeXY-temp-1,temp, temp, PlayerID,ReturnPoints, 10, RetList, Count2)			'up-right-north/down-left-south
'			Count3 = TTT_CheckStat(Game, temp,SizeXY-temp-1, temp, PlayerID,ReturnPoints, 11, RetList, Count3)			'up-left-south/down-right-north
'			Count4 = TTT_CheckStat(Game, SizeXY-temp-1,SizeXY-temp-1, temp, PlayerID,ReturnPoints, 12, RetList, Count4)	'up-right-south/down-left-north
'		Next
'		If ReturnPoints=-1 Then RetList.AddAll(Array As Int(Count1, Count2, Count3, Count4))
'	End If
'	Return RetList
'End Sub
'Sub TTT_CheckStat(Game As ThreeDboard, X As Int,Y As Int,Z As Int, PlayerID As Int, ReturnPoints As Int, PointsID As Int, RetList As List, Count As Int) As Int 
'	Dim temp As ThreeDPoint 
'	If ReturnPoints >-1 Then
'		If ReturnPoints = PointsID Then
'			temp = ThD_Set3DPoint(X,Y,Z)
'			RetList.Add(temp)
'		End If
'	Else If TTT_CheckTile(Game, X,Y, Z, PlayerID) Then
'		Return Count+ 1
'	End If
'	Return Count
'End Sub

Sub TTT_MakeAIMove(Game As ThreeDboard) As ThreeDPoint 
	Dim BestFloor As Int, Size As Int = Game.Difficulty , Middle As Int =-1, RetVal As ThreeDPoint ,OppositePlayer As Int = API.IIF(CurrentPlayer = MIN_White, MIN_Black,MIN_White)
	Dim BestMoveID As Int , BestOpponentsMoveID As Int 
	If Size Mod 2 = 1 Then Middle = API.IIF(Size=3, 1, 2)
	If Game.Mines = 1 And  Middle >-1 Then BestFloor = Middle  'is 3d

	'get middle point
	If Middle>-1 Then
		If TTT_IsSpotFree(Game, Middle,Middle, BestFloor) Then Return ThD_Set3DPoint(Middle,Middle,BestFloor)
	End If
	
	'Log("First check If you can win " & (Size-1))
	BestMoveID = TTT_FindBestMove(ThreeDGame, CurrentPlayer)
	If TTT_ValueOfMove(ThreeDGame,BestMoveID,CurrentPlayer) = Size-1 Then Return TTT_FindEmptySpot(ThreeDGame, BestMoveID)

	'Log("Then If you didn't win, check if the other player can win " & (Size-1))
	BestOpponentsMoveID = TTT_FindBestMove(ThreeDGame,OppositePlayer)
	If TTT_ValueOfMove(ThreeDGame,BestOpponentsMoveID,OppositePlayer) = Size-1 Then Return TTT_FindEmptySpot(ThreeDGame, BestOpponentsMoveID)
	
	'checks for double win scenarios 
	
	'Log("return best point")
	RetVal = TTT_FindEmptySpot(ThreeDGame, BestMoveID)
	
	'return random point (fallback)
	If Not(RetVal.IsInitialized) Then RetVal = ThD_Set3DPoint( Rnd(0, Game.Size.X +1), Rnd(0, Game.Size.y +1), Rnd(0, Game.Size.Z +1))
	
	'make sure it's free
	Do While Not(TTT_IsSpotFree(Game, RetVal.X, RetVal.Y, RetVal.z)) 
		RetVal = ThD_Set3DPoint( Rnd(0, Game.Size.X +1), Rnd(0, Game.Size.y +1), Rnd(0, Game.Size.Z +1))
	Loop
	Return RetVal
End Sub
Sub TTT_IsSpotFree(Game As ThreeDboard, X As Int,Y As Int,Z As Int) As Boolean 
'	Dim TileID As Point = ThD_Get3Dpoint(ThreeDGame, X, Y, Z) , tempPiece As ThreeDPiece
'	If TileID.X > -1 AND TileID.Y > -1 Then
'		tempPiece = ThD_Get3DpieceP(ThreeDGame, TileID)
'		Return tempPiece.Team = 0 
'	End If
	Return TTT_GetTeam(Game,X,Y,Z) = 0
End Sub
Sub TTT_CheckIfFull(Game As ThreeDboard) As Boolean 
	Dim temp As Int, Z As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece
	For Z = 0 To Game.Levels.Size-1
		tempLevel = Game.Levels.Get(Z)
		For temp = 0 To tempLevel.Grid.Size- 1
			tempPiece = tempLevel.Grid.Get(temp)
			If tempPiece.Team = 0 Then Return False
		Next
	Next
	Return True
End Sub

Sub TTT_ConnectPoints(X1 As Int, Y1 As Int, Z1 As Int, X2 As Int, Y2 As Int, Z2 As Int) As List  
	Dim RetVal As List 
	RetVal.Initialize 
	RetVal.Add(ThD_Set3DPoint(X1,Y1,Z1))
	Do Until X1 = X2 And Y1 = Y2 And Z1 = Z2 
		X1 = LCAR.Increment(X1, 1, X2)
		Y1 = LCAR.Increment(Y1, 1, Y2)
		Z1 = LCAR.Increment(Z1, 1, Z2)
		RetVal.Add(ThD_Set3DPoint(X1,Y1,Z1))
	Loop
	Return RetVal
End Sub
Sub TTT_CheckPoints(Game As ThreeDboard, Points As List, PlayerID As Int) As Int
	Dim temp As Int, tempPoint As ThreeDPoint , Count As Int 
	For temp = 0 To Points.Size -1
		tempPoint = Points.Get(temp)
		If TTT_CheckTile(Game , tempPoint.X, tempPoint.Y, tempPoint.z, PlayerID) Then Count = Count + 1
	Next
	Return Count
End Sub
Sub TTT_LogPoints(MoveID As Int, Moves As List)
	Dim temp As Int 
	Log("MoveID: " & MoveID)
	For temp = 0 To Moves.Size-1
		Log("Point " & temp & ": " & ThD_Point2Text(Moves.get(temp)))
	Next
End Sub
Sub TTT_FindEmptySpot(Game As ThreeDboard, MoveID As Int) As ThreeDPoint 
	Dim temp As Int, tempPoint As ThreeDPoint , Moves As List = AIMoves.Get(MoveID), tempPoint2 As ThreeDPoint 
	'TTT_LogPoints(moveid, moves)
	tempPoint = Moves.Get(Moves.Size-1)
	If TTT_GetTeam(Game, tempPoint.X,tempPoint.Y,tempPoint.z) = 0 Then Return tempPoint 
	For temp = 0 To Moves.Size-2
		tempPoint = Moves.Get(temp)
		If TTT_GetTeam(Game, tempPoint.X,tempPoint.Y,tempPoint.z) = 0 Then Return tempPoint 
	Next
	Return tempPoint2
End Sub
Sub TTT_FindBestMove(Game As ThreeDboard, PlayerID As Int) As Int
	Dim temp As Int, MoveID As Int, MoveValue As Int ,tempValue As Int 
	If Player1Type = PT_AI And Player2Type = PT_AI Then MoveID = Rnd(0,AIMoves.Size)
	For temp = 0 To AIMoves.Size - 1 
		tempValue  = TTT_ValueOfMove(Game, temp, PlayerID)
		If tempValue > MoveValue Then 
			MoveValue = tempValue 
			MoveID = temp  'i dont know why it needs -1ing
		End If
	Next
	'Log("Best move: " & MoveID & "(" & MoveValue & ")")
	Return MoveID
End Sub
Sub TTT_ValueOfMove(Game As ThreeDboard, MoveID As Int, PlayerID As Int) As Int 
	Dim Moves As List = AIMoves.Get(MoveID), temp As Int ,OppositePlayer As Int = API.IIF(PlayerID = MIN_White, MIN_Black,MIN_White), tempPoint As ThreeDPoint, Size As Int = Game.Difficulty
	Dim PlayerCount As Int, Team As Int 
	For temp = 0 To Moves.Size - 1
		tempPoint = Moves.Get(temp)
		Team = TTT_GetTeam(Game,tempPoint.X,tempPoint.Y,tempPoint.Z)
		If Team = PlayerID Then 
			PlayerCount = PlayerCount + 1 
		Else If Team = OppositePlayer Then
			'PlayerCount=-1
			'temp = Moves.Size 
			Return -1
		End If
	Next
	'Log(MoveID & ": " & ThD_Point2Text(Moves.Get(0)) & " to " & ThD_Point2Text(tempPoint) & " = " & PlayerCount & API.IIF(PlayerCount=-1, " BLOCKED", ""))
	'TTT_LogPoints(MoveID, Moves)
	Return PlayerCount ' PlayerCount = Size
End Sub
Sub ThD_Point2Text( tempPoint As ThreeDPoint) As String 
	Return "(" & tempPoint.x & "," & tempPoint.y & "," & tempPoint.z & ")"
End Sub
Sub TTT_GenerateAImoves
	Dim BestFloor As Int, Size As Int = ThreeDGame.Difficulty, Middle As Int =-1, RetVal As ThreeDPoint ,Is3D As Boolean ,IsOdd As Boolean , temp As Int , temp2 As Int 
	IsOdd = Size Mod 2 = 1 
	If IsOdd Then Middle = API.IIF(Size=3, 1, 2)
	Is3D=ThreeDGame.Mines = 1 
	If Is3D And Middle >-1 Then BestFloor = Middle
	AIMoves.Initialize
	Size=Size-1
	'Log("isOdd: " & IsOdd & " is3D: " & Is3D & " Middle: " & Middle & " BestFloor: " & BestFloor & " Size: " & Size)
	
	'criss cross from BestFloor corners to BestFloor opposite corners going through center point(s)
	AIMoves.Add( TTT_ConnectPoints(0,0,BestFloor,  		Size,Size, BestFloor) )'\
	AIMoves.Add( TTT_ConnectPoints(0,Size,BestFloor,   	Size,0, BestFloor) )'/
	If Is3D Then	'criss cross from top corners to bottom opposite corners going through center point(s)
		AIMoves.Add( TTT_ConnectPoints(0,0,0,    			Size,Size,Size))'bottom floor, top left corner -to- top floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(Size,Size,0,    		0,0,Size))'bottom floor, bottom right corner -to- top floor, top left corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0,    		0,Size,Size))
		AIMoves.Add( TTT_ConnectPoints(0,Size,0,    		Size,0,Size))
		If IsOdd Then'criss crossing top middle to bottom middle going through center point
			AIMoves.Add( TTT_ConnectPoints(0,Middle, 0, 	Size,Middle,Size))
			AIMoves.Add( TTT_ConnectPoints(Size,Middle, 0, 	0,Middle,Size))
			AIMoves.Add( TTT_ConnectPoints(Middle,0, 0, 	Middle,Size,Size))
			AIMoves.Add( TTT_ConnectPoints(Middle,Size, 0, 	Middle,0,Size))
		End If'connecting corners of the outer surface
		
		'bottom floor, top left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				Size, 0,0))'bottom floor, top right corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				0,Size,0))'bottom floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				Size,Size,0))'bottom floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				0,0,Size))'top floor, top left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				0, Size, Size))'top floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,0, 				Size, 0, Size))'top floor, top right corner
		
		'bottom floor, top right corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0, 			0,0,Size))'top floor, top left corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0, 			Size, 0, Size))'top floor, top right corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0, 			Size, Size, Size))'top floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0, 			Size, Size, 0))'bottom floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,0, 			0, Size, 0))'bottom floor, bottom left corner
		
		'bottom floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(0,Size,0,			Size, Size, 0))'bottom floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(0,Size,0,			Size, Size, Size))'top floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(0,Size,0,			0, Size, Size))'top floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(0,Size,0,			0,0,Size))'top floor, top left corner
		
		'bottom floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(Size,Size,0,			Size,Size,Size))'top floor, bottom right corner
		AIMoves.Add( TTT_ConnectPoints(Size,Size,0,			0, Size, Size))'top floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(Size,Size,0,			Size, 0, Size))'top floor, top right corner
		
		'top floor, top left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,Size,			Size, 0, Size))'top floor, top right corner
		AIMoves.Add( TTT_ConnectPoints(0,0,Size,			0, Size, Size))'top floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(0,0,Size,			Size, Size, Size))'top floor, bottom right corner
		
		'top floor, top right corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,Size,			0, Size, Size))'top floor, bottom left corner
		AIMoves.Add( TTT_ConnectPoints(Size,0,Size,			Size, Size, Size))'top floor, bottom right corner
		
		'top floor, bottom right
		AIMoves.Add( TTT_ConnectPoints(Size,Size,Size,		0,Size,Size))'top floor, bottom left corner
		
		'- | for each floor, bottom to top (| \ and /)
		For temp = 0 To Size
			For temp2 = 0 To Size
				AIMoves.Add( TTT_ConnectPoints(temp,temp2,0, temp, temp2, Size))' bottom to top
				AIMoves.Add( TTT_ConnectPoints(temp,0,temp2, temp,Size,temp2))'left to right
				AIMoves.Add( TTT_ConnectPoints(0,temp,temp2, Size,temp,temp2))'north to south
			Next
			If temp <> Middle Then
				AIMoves.Add( TTT_ConnectPoints(0,0,temp,     Size,Size,temp))'top left to bottom right
				AIMoves.Add( TTT_ConnectPoints(Size,0,temp,     0,Size,temp))'top right to bottom left
				If temp > 0 And temp < Size Then
					AIMoves.Add( TTT_ConnectPoints(0,temp,0,	Size,temp,Size))'/ from bottom floor, left side to top floor right side
					AIMoves.Add( TTT_ConnectPoints(Size,temp,0,	0,temp,Size))'/ from bottom floor, right side to top floor left side
					AIMoves.Add( TTT_ConnectPoints(temp,0,0,	Size,temp,Size))'/ from bottom floor, north to top floor south
					AIMoves.Add( TTT_ConnectPoints(temp,Size,0,	temp,0,Size))'/ from bottom floor, south to top floor north
				End If
			End If
		Next
	Else
		For temp = 0 To Size
			AIMoves.Add( TTT_ConnectPoints(0,temp, BestFloor,		Size,temp,BestFloor))'-
			AIMoves.Add( TTT_ConnectPoints(temp,0, BestFloor,		temp,Size,BestFloor))'|
		Next
	End If
End Sub






'minesweeper-specific code
Sub MIN_PlaceMines(Game As ThreeDboard, Mines As Int)
	Dim tempSpot As Point , tempPiece As ThreeDPiece 
	Mines = Min(Mines, Game.TotalTiles -1)
	Do Until Mines = 0 
		tempSpot = ThD_Get3Dpoint(Game, -1,-1,-1)
		tempPiece = ThD_Get3Dpiece(Game, tempSpot.X, tempSpot.Y)
		If tempPiece.Piece <> MIN_Mine And Not(tempPiece.Uncovered) Then
			Game.Mines = Game.Mines + 1
			tempPiece.Piece = MIN_Mine
			Mines = Mines - 1
		End If
	Loop
End Sub

Sub MIN_ClearMap(Game As ThreeDboard, Checked As Boolean, Uncovered As Boolean, Queued As Boolean, Value As Boolean, Flag As Boolean, MinesOnly As Boolean, Marks As Boolean)
    Dim temp As Int,  tempLevel As ThreeDLevel , tLevel As Int , tempPiece As ThreeDPiece,X As Int, Y As Int  
	If Queued Then ThreeD_Queue.Initialize 
	For tLevel = 0 To Game.Levels.Size - 1 
		tempLevel = Game.Levels.Get(tLevel)
        For temp = 0 To tempLevel.Grid.Size -1
			tempPiece = tempLevel.Grid.Get(temp)
			
            If Checked Then 
				tempPiece.Checked = False
				If tempPiece.Uncovered And tempPiece.Flag Then
					tempPiece.Flag= False
					Game.Flags = Game.Flags-1
				End If
			End If
            If Uncovered Then
				tempPiece.Uncovered = False
                If Not(tempPiece.Piece = MIN_Mine) Then
                    tempPiece.Piece = MIN_AdjacentMines(Game, X + tempLevel.Loc.X, Y+ tempLevel.Loc.Y, tempLevel.Loc.Z)
                End If
			End If
            If Value Then tempPiece.Piece = 0
            If Flag Then tempPiece.Flag = 0
            If Marks Then tempPiece.Mark = False
            If MinesOnly And tempPiece.Piece = MIN_Mine Then tempPiece.Uncovered = True
			
			X=X+1
			If X = tempLevel.Width Then 
				X=0
				Y=Y+1
			End If
        Next
	Next
End Sub

Public Sub MIN_UncoverMap(Game As ThreeDboard, Value As Boolean)
    Dim temp As Int,  tempLevel As ThreeDLevel , tLevel As Int , tempPiece As ThreeDPiece
	For tLevel = 0 To Game.Levels.Size - 1 
		tempLevel = Game.Levels.Get(tLevel)
        For temp = 0 To tempLevel.Grid.Size -1
			tempPiece = tempLevel.Grid.Get(temp)
			tempPiece.Uncovered = Value
		Next
	Next
    If Not(Value) Then MIN_ClearMap(Game, True,False,False,False,False,False,False)
End Sub

Sub MIN_HasFlag(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Boolean
	Dim tempPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	If X > -1 And Y > -1 And Z > -1 And tempPiece.IsInitialized Then Return tempPiece.Flag 
End Sub

Sub MIN_HasMine(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Boolean
	Dim tempPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	If X > -1 And Y > -1 And Z > -1 And tempPiece.IsInitialized Then 
		If tempPiece.Piece = MIN_Mine Then Return True
	End If
End Sub

Sub MIN_Mine2Value(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Int
	Dim HasMine As Boolean = MIN_HasMine(Game, X, Y,Z)
    Return API.IIF( HasMine,1,0)
End Sub

Sub MIN_QueueTiles(Game As ThreeDboard, X As Int, Y As Int, Z As Int)
    MIN_Queue9(Game,X,Y,Z-1,True)
	MIN_Queue9(Game,X,Y,Z,False)
	MIN_Queue9(Game,X,Y,Z+1,True)
End Sub
Sub MIN_Queue9(Game As ThreeDboard, X As Int, Y As Int, Z As Int, DoCenter As Boolean)
	MIN_QueueTile (Game, X - 1, Y - 1, Z)
    MIN_QueueTile (Game, X, Y - 1, Z)
    MIN_QueueTile (Game, X + 1, Y - 1, Z)
    
    MIN_QueueTile (Game, X - 1, Y, Z)
	If DoCenter Then MIN_QueueTile (Game, X, Y, Z)
    MIN_QueueTile (Game, X + 1, Y, Z)
    
    MIN_QueueTile (Game, X - 1, Y + 1, Z)
    MIN_QueueTile (Game, X, Y + 1, Z)
    MIN_QueueTile (Game, X + 1, Y + 1, Z)
End Sub

Sub MIN_AdjacentMines(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Int
    Return MIN_Adjacent9(Game,X,Y,Z, False) + MIN_Adjacent9(Game,X,Y,Z-1, True) + MIN_Adjacent9(Game,X,Y,Z+1, True)
End Sub
Sub MIN_Adjacent9(Game As ThreeDboard, X As Int, Y As Int, Z As Int, DoCenter As Boolean) As Int
	Dim temp As Long = MIN_Mine2Value(Game, X - 1, Y - 1, Z) + MIN_Mine2Value(Game, X, Y - 1, Z) + MIN_Mine2Value(Game, X + 1, Y - 1, Z) 'upleft, upup, upright
    temp = temp + MIN_Mine2Value(Game, X - 1, Y, Z) + MIN_Mine2Value(Game, X + 1, Y, Z) 'middleleft, middleright
    temp = temp + MIN_Mine2Value(Game, X - 1, Y + 1, Z) + MIN_Mine2Value(Game, X, Y + 1, Z) + MIN_Mine2Value(Game, X + 1, Y + 1, Z) 'downleft, downdownm downright
	If DoCenter Then temp = temp + MIN_Mine2Value(Game,X,Y,Z)
	Return temp
End Sub

Sub MIN_QueueTile(Game As ThreeDboard, X As Int, Y As Int, Z As Int)
	Dim tempPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	If tempPiece.IsInitialized And X>-1 And Y>-1 And Z>-1 Then
		If Not(tempPiece.Uncovered) Then
			If Not(tempPiece.Checked) Then
				tempPiece.Checked = True
				ThreeD_Queue.Add( ThD_Set3DPoint(X,Y,Z) )
			End If
		End If
	End If
End Sub

'pulls one tile from the queue to scan it
Sub MIN_UncoverIndex(Game As ThreeDboard)As Boolean 
	Dim P As ThreeDPoint 
	If ThreeD_Queue.Size>0 Then
		P = ThreeD_Queue.Get(ThreeD_Queue.Size-1)
		ThreeD_Queue.RemoveAt(ThreeD_Queue.Size-1)
		MIN_Scan(Game, P.x, P.Y, P.Z)
		Return True
	End If
End Sub

Sub MIN_Scan(Game As ThreeDboard, X As Int, Y As Int, Z As Int)
	Dim tempPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	If tempPiece.IsInitialized And X>-1 And Y>-1 And Z>-1 Then
		If tempPiece.Piece =0 Then
			tempPiece.Piece = MIN_AdjacentMines(Game,X,Y,Z)
			tempPiece.Uncovered = True
			If tempPiece.Piece = 0 Then MIN_QueueTiles(Game, X,Y,Z)
		End If
    End If
End Sub

Sub MIN_CheckForWin(Game As ThreeDboard) As Boolean
	Dim temp As Int, tempLevel As ThreeDLevel , tLevel As Int , tempPiece As ThreeDPiece
	If Game.Mines - Game.Flags = 0 Then
		For tLevel = 0 To Game.Levels.Size - 1 
			tempLevel = Game.Levels.Get(tLevel)
			For temp = 0 To tempLevel.Grid.Size -1
				tempPiece = tempLevel.Grid.Get(temp)
				If tempPiece.Flag And Not(tempPiece.Piece = MIN_Mine) Then Return False
			Next
		Next
		ThD_GameOver = API.GetString("pdp_won")
		Return True
	End If
End Sub

Sub MIN_Uncover(Game As ThreeDboard, X As Int, Y As Int, Z As Int, Recurse As Boolean, First As Boolean)
	Dim tempPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	'Log("MIN_HasMine: " & X & " " & Y & " " & Z  & " = " & MIN_HasMine(Game,X,Y,Z))
	If tempPiece.IsInitialized And X>-1 And Y>-1 And Z>-1 Then
		If tempPiece.Piece = MIN_Mine Then
			ThD_GameOver = API.GetString("tri_gameover")
			MIN_ClearMap(Game,         False,        False,           False,       False,       False,      True,          False)
		Else
			MIN_Scan(Game,X,Y,Z)
			Do While MIN_UncoverIndex(Game)
				'GNDN
			Loop
		End If 
	End If
End Sub







'mulyiplayer-specific code
Sub ThD_MultiplayerData(ToSend As Boolean, Action As Int, X As Int, Y As Int, Z As Int, Misc As Int)
	Dim Text As String = "Ignoring"
	If ToSend Then
		If ThD_DataNeedsSending Then
			Text = "Sending"
			LCAR.PushEvent(LCAR.LCAR_ThreeDGame, ThreeD_ElementID, Action, X, Y, Z, Misc, LCAR.Event_Other)
		End If
	Else
		Text = "Recieving"
		If Action = -1 Then
			ThD_NewGame(ThreeD_ElementID, X, Y, Z)
		Else
			ThreeD_SelectedMenu=Action
			ThD_GridClicked(X,Y,Z,PT_Remote)
		End If
	End If
	If API.debugMode Then Log("ThD_" & Text & ": " & Action & " - " & X & "," & Y & "," & Z & " " & Misc)
End Sub
Sub ThD_IsOnline As Boolean 
	Return LCAR.SRV_State <> PT_Local
End Sub
Sub ThD_DataNeedsSending As Boolean
	If ThD_IsOnline Then Return API.IIF(CurrentPlayer = MIN_White, Player1Type, Player2Type) = PT_Local
End Sub
Sub ThD_SetupMultiplayer
	'Player1Type As Byte, Player2Type As Byte, CurrentPlayer As Byte, PT_Local As Byte = 0, PT_Remote As Byte =1, PT_AI As Byte = 2, PT_Server As Byte = 3
	'LCAR.SRV_State As Byte = PT_Local 
	If LCAR.SRV_State <> PT_Local Then
		If LCAR.SRV_State = PT_Server Then
			Player1Type = PT_Local
			Player2Type = PT_Remote
		Else
			Player1Type = PT_Remote
			Player2Type = PT_Local
		End If
	End If
End Sub
Sub ThD_PlayerWon(PlayerID As Byte)
	If PlayerID = 0 Then
		ThD_GameOver = API.GetString("3d_tie")
	Else
		ThD_GameOver = API.GetString(API.iif(PlayerID = MIN_White, "3d_white_won", "3d_black_won") )
	End If
	If Player1Type = PT_AI And Player2Type = PT_AI Then ThD_SetAnimation(0)
End Sub
Sub ThD_ChangeTeam
	If ThD_GameOver.Length=0 Then
		If CurrentPlayer = 0 Then
			If Rnd(0,256) < 128 Then CurrentPlayer = MIN_White Else CurrentPlayer = MIN_Black 
		Else If CurrentPlayer = MIN_White Then 
			CurrentPlayer = MIN_Black 
		Else 
			CurrentPlayer = MIN_White
		End If
		ThD_RefreshScores
	End If
End Sub


'settings handling for main
Sub ThD_Strings(Index As Int, Mode As String, GameType As String) As List
	Log (Mode & GameType & " " & Index)
	Select Case Index
		Case 0: 								Return Array As String("MINESWEEPER", "TICTACTOE", "CHECKERS", "CHESS", "8589934592")
		Case 1: 								Return Array As String("2D", "3D")'mode
		Case 2'size of the board
			Select Case Mode & GameType
				Case "2DMINESWEEPER": 			Return Array As String("5", "10", "25", "50", "100", "200")
				Case "3DMINESWEEPER": 			Return Array As String("SMALL")
				
				Case "2DCHECKERS", "2DCHESS": 	Return Array As String("8X8")
				Case "3DCHECKERS": 				Return Array As String("4X4X4")
				Case "3DCHESS": 				Return Array As String("4ATK")', "6ATK")
				
				Case "2DTICTACTOE": 			Return Array As String("3X3", "4X4", "5X5")
				Case "3DTICTACTOE": 			Return Array As String("3X3X3", "4X4X4", "5X5X5")
				
				Case "2D8589934592":			Return Array As String("4X4", "5X5", "6X6")
				Case "3D8589934592":			Return Array As String("4X4X4", "5X5X5", "6X6X6")
			End Select
		Case 3'mines
			If GameType = "MINESWEEPER" Then 	Return Array As String("5",  "10", "15", "20", "25", "30", "40", "50", "75", "100") 
		Case 4, 5'player types (1,2)
			If LCAR.SRV_State <> PT_Local Then Return Array As String(API.IIF(Index=4,"LOCAL", "REMOTE"))
			Select Case GameType
				Case "MINESWEEPER": If Index = 5 Then Return Array As String("NONE")
				Case "CHESS", "CHECKERS"
				Case Else: If LCAR.SRV_State = PT_Local Then Return Array As String("LOCAL", "AUTO")
			End Select
			Return Array As String("LOCAL")
		Case 6
			Return Array As String("OPEN")
			'Select Case GameType
			'	Case "MINESWEEPER", "TICTACTOE": Return Array As String("OPEN")
			'End Select
	End Select
	Return Array As String("")
End Sub
















'checkers/chess code
Sub ThD_Increment() As Boolean 
	Dim temp As Int, Z As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece, Ret As Boolean, Speed As Int = 20
	If ThreeDGame.isMoving Then
		For Z = 0 To ThreeDGame.Levels.Size - 1 
			tempLevel = ThreeDGame.Levels.Get(Z)
			For temp = 0 To tempLevel.Grid.Size -1
				tempPiece = tempLevel.Grid.Get(temp)
				If tempPiece.Xoffset <> 0 Or tempPiece.Yoffset <> 0 Then
					tempPiece.Xoffset = LCAR.Increment(tempPiece.Xoffset, Speed, 0)
					tempPiece.Yoffset = LCAR.Increment(tempPiece.Yoffset, Speed, 0)
					Ret = True
				End If
			Next
		Next
	End If
	Return Ret
End Sub
Sub ThD_EnumPieces(Game As ThreeDboard, Team As Int) As List
	Dim X As Int, Y As Int, Z As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece, Pieces As List 
	Pieces.Initialize 
	For Z = 0 To Game.Levels.Size - 1 
		tempLevel  = Game.Levels.Get(Z)
		X=tempLevel.Loc.X
		Y=tempLevel.Loc.Y
		For temp = 0 To tempLevel.Grid.Size -1
			tempPiece = tempLevel.Grid.Get(temp)
			If tempPiece.Team = Team Then Pieces.Add (ThD_Set3DPoint(X,Y,Z))
			X=X+1
			If X = tempLevel.Width Then
				X=tempLevel.Loc.X
				Y=Y+1
			End If
		Next
	Next
	Return Pieces
End Sub
Sub ThD_CanMove(Game As ThreeDboard, Team As Int) As Boolean 
	Dim Pieces As List = ThD_EnumPieces(Game, Team), temp As Int, tempPiece As ThreeDPiece, Moves As List, tempPoint As ThreeDPoint, CanMove As Boolean = (Game.Gametype = ThreeD_Chess)
	For temp = 0 To Pieces.Size -1 
		tempPoint = Pieces.Get(temp)
		tempPiece = ThD_Get3DpieceXYZ(Game, tempPoint.X,tempPoint.Y,tempPoint.Z)
		Moves = CHK_EnumMoves(Game, tempPoint.X,tempPoint.Y,tempPoint.Z, tempPiece.Team, tempPiece.Piece, Not(tempPiece.Uncovered)) 
		If Game.Gametype = ThreeD_Checkers Then
			If Moves.Size > 0 Then Return True
		Else If Game.Gametype = ThreeD_Chess Then
			If tempPiece.Piece = CHS_King And Moves.Size>0 Then
				If CHS_WillMoveBeDangerous(Game, Team, -1,-1,-1, tempPoint.X,tempPoint.Y,tempPoint.Z).IsInitialized Then
					If CHS_SafeMoves(Game, tempPiece, tempPoint, Moves).Size = 0 Then Return False
				End If
			End If
		End If
	Next
	Return CanMove
End Sub
Sub CHS_SafeMoves(Game As ThreeDboard, Piece As ThreeDPiece, LOC As ThreeDPoint, Moves As List) As List 
	Dim temp As Int, tempMove As ThreeDPoint
	For temp = Moves.Size - 1 To 0 Step -1
		tempMove = Moves.Get(temp)
		If CHS_WillMoveBeDangerous(Game, Piece.Team, LOC.X, LOC.Y,LOC.Z, tempMove.X, tempMove.Y, tempMove.Z).IsInitialized Then Moves.RemoveAt(temp)
	Next
	Return Moves
End Sub
Sub CHS_WillMoveBeDangerous(Game As ThreeDboard, YourTeam As Int, Xsrc As Int, Ysrc As Int, Zsrc As Int, Xdest As Int, Ydest As Int, Zdest As Int) As ThreeDPoint 
	Dim EnemyPieces As List, Moves As List, temp As Int, temp2 As Int, tempPiece As ThreeDPiece, tempPoint As ThreeDPoint, tempMove As ThreeDPoint, endPoint As ThreeDPoint 
	Dim destPiece As ThreeDPiece, srcPiece As ThreeDPiece',Game As ThreeDboard'
	If Xsrc = Xdest And Ysrc = Ydest And Zsrc=Zdest Then
		Xsrc=-1
		Ysrc=-1
		Zsrc=-1
	End If
	If Xsrc>-1 And Ysrc>-1 And Zsrc>-1 Then'copy game data
		srcPiece = CHS_CopyPiece( ThD_Get3DpieceXYZ(Game, Xsrc, Ysrc, Zsrc))
		destPiece = CHS_CopyPiece( ThD_Get3DpieceXYZ(Game, Xdest,Ydest,Zdest))
		'Game=CHS_CopyGame(OldGame)', EnemyPieces, OtherTeam(YourTeam))
		'Log("Move from : "  & Xsrc & ", " & Ysrc & ", " & Zsrc & " to " & Xdest & ", " & Ydest & ", " & Zdest)
		CHK_MovePiece(Game, Xsrc,Ysrc,Zsrc,Xdest,Ydest,Zdest, False)
	End If
	EnemyPieces = ThD_EnumPieces(Game, OtherTeam(YourTeam))
	'test each possible move of each Enemy Piece to see if it'll take dest
	For temp = 0 To EnemyPieces.Size -1 
		tempPoint = EnemyPieces.Get(temp)
		tempPiece = ThD_Get3DpieceXYZ(Game, tempPoint.X, tempPoint.Y, tempPoint.Z)
		Moves = CHK_EnumMoves(Game, tempPoint.X, tempPoint.Y, tempPoint.Z, tempPiece.Team, tempPiece.Piece, Not(tempPiece.Uncovered))
		For temp2 = 0 To Moves.Size - 1
			tempMove = Moves.Get(temp2)
			If Game.Gametype = ThreeD_Checkers Then
				If CHK_CheckforChecker(Game, tempPoint.X, tempPoint.Y, tempPoint.Z, tempMove.X, tempMove.Y, tempMove.Z, False) Then endPoint= tempPoint
			Else If Game.Gametype = ThreeD_Chess Then
				If tempMove.X = Xdest And tempMove.Y = Ydest And tempMove.Z = Zdest Then endPoint= tempPoint
			End If
			If endPoint.IsInitialized Then 
				temp = EnemyPieces.Size
				temp2 = Moves.size
			End If
		Next
	Next
	If Xsrc>-1 And Ysrc>-1 And Zsrc>-1 Then'put it back the way it was
		'Log("Move back from : "  & Xdest & ", " & Ydest & ", " & Zdest & " to " & Xsrc & ", " & Ysrc & ", " & Zsrc)
		'CHK_MovePiece(Game, Xdest,Ydest,Zdest, Xsrc,Ysrc,Zsrc, False)
		ThD_SetPiece(Game, Xsrc,Ysrc,Zsrc, srcPiece)
		ThD_SetPiece(Game, Xdest,Ydest,Zdest, destPiece)
	End If
	Return endPoint
End Sub


'Sub CHS_CopyGame(Game As ThreeDboard) As ThreeDboard', Pieces As List, Team As Int) As ThreeDboard
'	Dim NewGame As ThreeDboard, Z As Int'Pieces.Initialize
'	NewGame.Initialize 
'	NewGame.Gametype = Game.Gametype 
'	NewGame.Difficulty = Game.Difficulty 
'	NewGame.Size = CHS_Copy3Dpoint(Game.Size)
'	NewGame.Levels.Initialize 
'	For Z = 0 To Game.Levels.Size - 1
'		Game.Levels.Add(CHS_CopyLevel(Game.Levels.Get(Z)))', Pieces, Team, Z))
'	Next
'End Sub
Sub CHS_Copy3Dpoint(thePoint As ThreeDPoint) As ThreeDPoint 
	Return ThD_Set3DPoint(thePoint.x, thePoint.y,thePoint.z)
End Sub
Sub CHS_CopyPiece(Piece As ThreeDPiece) As ThreeDPiece
	Dim tempPiece As ThreeDPiece 
	tempPiece.Initialize 
	tempPiece.Piece = Piece.Piece 
	tempPiece.Team = Piece.team 
	tempPiece.Uncovered = Piece.Uncovered 
	Return tempPiece
End Sub 

'Sub CHS_CopyLevel(theLevel As ThreeDLevel) As ThreeDLevel', Pieces As List, Team As Int, Z As Int) As ThreeDLevel
'	Dim newLevel As ThreeDLevel, temp As Int, tempPiece As ThreeDPiece', X As Int, Y As Int
'	newLevel.Initialize 
'	newLevel.Height= theLevel.Height
'	newLevel.Width=theLevel.Width 
'	newLevel.Loc = CHS_Copy3Dpoint(theLevel.Loc)
'	newLevel.Grid.Initialize
'	'X=newLevel.Loc.X 
'	'Y=newLevel.Loc.Y
'	For temp = 0 To theLevel.Grid.Size-1
'		tempPiece = CHS_CopyPiece(theLevel.Grid.Get(temp))
'		newLevel.Grid.Add(tempPiece)
'		'If Team >0 Then
'		'	If Team = tempPiece.Team Then Pieces.Add(ThD_Set3DPoint(X,Y,Z))
'		'	X=X+1
'		'	If X=theLevel.Width Then 
'		'		X=newLevel.Loc.X 
'		'		Y=Y+1
'		'	End If
'		'End If
'	Next
'	Return newLevel
'End Sub

Sub OtherTeam(Team As Int) As Int 
	If Team = MIN_White Then Return MIN_Black 
	Return MIN_White
End Sub
Sub CHK_TogglePlayer(Game As ThreeDboard, Scored As Boolean)
	If Not(Scored) Then CurrentPlayer = OtherTeam(CurrentPlayer)
	If Not(ThD_CanMove(Game, CurrentPlayer)) Then ThD_AddScore(Game, CurrentPlayer, 0, False)
	ThD_RefreshScores
End Sub
Sub CHK_Action(Game As ThreeDboard, X As Int, Y As Int, Z As Int) 
	Dim tempPiece As ThreeDPiece = CHS_Get3DpieceXYZ(Game,X,Y,Z), Moves As List, Scored As Boolean',TTT_IsSpotFree
	If tempPiece.Team = CurrentPlayer Then 'if it's a piece, mark available tiles
		CHS_UnmarkAll(Game)
		Moves = CHK_EnumMoves(Game, X,Y,Z, tempPiece.Team, tempPiece.Piece, Not(tempPiece.Uncovered))
		If Moves.Size = 0 Then 
			LCAR.PlaySound(12,False)'play error noise
		Else
			CHS_MarkMoves(Moves, Game) 
			Selected3DTile = ThD_Set3DPoint(X,Y,Z)
		End If
	Else If tempPiece.Mark Then 'if it's a marked tile, move the piece to it
		Scored = CHK_CheckforChecker(Game, Selected3DTile.X, Selected3DTile.Y, Selected3DTile.Z, X,Y,Z, True)
		tempPiece = CHK_MovePiece(Game, Selected3DTile.X, Selected3DTile.Y, Selected3DTile.Z, X,Y,Z, True)
		CHK_CheckforChecker(Game, -1, -1, -1, X,Y,Z, True)
		CHK_TogglePlayer(Game, Scored)
		CHS_UnmarkAll(Game)
	Else 'if it's an unmarked tile, do nothing
		LCAR.PlaySound(12,False)'play error noise
	End If
End Sub
Sub CHK_CheckforChecker(Game As ThreeDboard, Xsrc As Int, Ysrc As Int, Zsrc As Int, Xdest As Int, Ydest As Int, Zdest As Int, DoScore As Boolean) As Boolean
	Dim tempPiece As ThreeDPiece = CHS_Get3DpieceXYZ(Game,Xdest,Ydest,Zdest) 'white are north, blacks are south
	If Xsrc =-1 And Ysrc=-1 And Zsrc=-1 Then'check for king
		If tempPiece.Piece = CHK_Pawn Then
			Ysrc=0'MIN_Black
			If Game.Difficulty = 0 Then'3D
				If Game.Gametype = ThreeD_Checkers Then
					If tempPiece.Team = MIN_White Then Ysrc = 3
				Else
					'''''''''''''''''''''''''''''''''''''''''''If tempPiece.Team = MIN_Black Then Ysrc = XXXXXX
				End If
			Else '2D
				If tempPiece.Team = MIN_White Then Ysrc = 7
			End If
			If Ydest = Ysrc Then  tempPiece.Piece = API.IIF(Game.Gametype = ThreeD_Checkers, CHK_King, CHS_Queen)
		End If
	Else If Game.Gametype = ThreeD_Checkers Then'check for a leapfrog
		If CHK_Diff(Xsrc,Xdest)>1 Or CHK_Diff(Ysrc,Ydest)>1 Or CHK_Diff(Zsrc,Zdest)>1 Then
			'Log("Before: " & Xsrc & ", " & Ysrc & ", " & Zsrc)
			'Log("After: " & Xdest & ", " & Ydest & ", " & Zdest)
			Xdest = (Xsrc + Xdest) / 2
			Ydest = (Ysrc + Ydest) / 2
			Zdest = (Zsrc + Zdest) / 2
			'Log("Middle: " & Xdest & ", " & Ydest & ", " & Zdest)
			tempPiece = CHS_Get3DpieceXYZ(Game,Xdest,Ydest,Zdest)
			If tempPiece.Team > 0 Then
				'Log("Destroy/Score!")
				If DoScore Then
					ThD_AddScore(Game, tempPiece.Team, -1, True)
					ThD_AddPiece(Game,Xdest, Ydest, Zdest, 0, 0, True, False)
				End If
				Return True
			End If
		End If
	End If
End Sub
Sub CHK_Diff(Src As Int, Dest As Int) As Int 
	Return Max(Src,Dest)-Min(Src,Dest)
End Sub
Sub CHK_IsOccupied(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As Boolean 
	Return CHS_Get3DpieceXYZ(Game, X, Y, Z).Team > 0
End Sub
Sub CHK_MovePiece(Game As ThreeDboard, Xsrc As Int, Ysrc As Int, Zsrc As Int, Xdest As Int, Ydest As Int, Zdest As Int, DoScore As Boolean) As ThreeDPiece 
	Dim srcPiece As ThreeDPiece = CHS_Get3DpieceXYZ(Game, Xsrc, Ysrc, Zsrc), destPiece As ThreeDPiece = CHS_Get3DpieceXYZ(Game,Xdest,Ydest,Zdest)
	If srcPiece.Team <> destPiece.Team Then'do not allow you to move to your own piece
		If DoScore Then
			If destPiece.Team > 0 Then 
				If Game.Gametype = ThreeD_Chess And destPiece.Piece = CHS_King Then
					ThD_AddScore(Game, destPiece.Team, 0, False)
				Else
					ThD_AddScore(Game, destPiece.Team, -1, True)
				End If
			End If
		End If
		ThD_AddPiece(Game,Xdest,Ydest,Zdest, srcPiece.Team, srcPiece.Piece, True, False)
		ThD_AddPiece(Game,Xsrc, Ysrc, Zsrc, 0, 0, True, False)
		If DoScore Then 
			destPiece = CHS_Get3DpieceXYZ(Game,Xdest,Ydest,Zdest)
			destPiece.Uncovered = True
			'Offset is a percent, where 100 = 100% of the size of a tile
			destPiece.Xoffset = (Xsrc-Xdest) * 100
			destPiece.Yoffset = (Ysrc-Ydest) * 100
			Game.isMoving = True
		End If
	End If
	Return destPiece
End Sub
Sub CHK_IsWithinBounds(Game As ThreeDboard, ThePoint As ThreeDPoint) As Boolean 
	If ThePoint.Z < 0 Or ThePoint.Z > Game.Size.Z Then Return False 
	If ThePoint.X = -1 Or ThePoint.Y = -1 Or ThePoint.Z = -1 Then Return False
	Return TTT_GetTeam(Game, ThePoint.X, ThePoint.Y, ThePoint.Z) > -1
End Sub
Sub CHK_EnumMoves(Game As ThreeDboard, X As Int, Y As Int, Z As Int, Team As Int, Piece As Int, FirstMove As Boolean) As List 
	Dim Moves As List, temp As Int, temppoint As ThreeDPoint, Remove As Boolean, DirY As Int = -1, DirZ As Int = 1'north/up
	Moves.Initialize 
	Select Case ThreeDGame.Gametype 
		Case ThreeD_Checkers
			'Space Checkers adapts traditional checkers to the 3rd dimension. Instead of 12 men on an 8x8 square,
			'Each side has 8 men on a 4x4x4 cube. The adaptation Is straight-forward: Black sets up near the south lower edge AND
			'can only move north AND up; Red sets up near the north upper edge AND can only move south AND down. Captures AND
			'crowning are 3D analogs To the 2D Case.
			'Log("Checkers:")
			If Team = MIN_Black Or Piece = CHK_King Then'blacks or kings
				Moves.Add(CHK_Move(Game, X,Y,Z, Team, -1,	-1,	  0))'up left,  same-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team,  1,	-1,	  0))'up right, same-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team, -1,	-1,	  1))'up left,  up-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team,  1,	-1,	  1))'up right, up-level
			End If
			If Team = MIN_White Or Piece = CHK_King Then'whites or kings
				Moves.Add(CHK_Move(Game, X,Y,Z, Team, -1,	 1,	  0))'down left,  same-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team,  1,	 1,	  0))'down right, same-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team, -1,	 1,	 -1))'down left,  down-level
				Moves.Add(CHK_Move(Game, X,Y,Z, Team,  1,	 1,	 -1))'down right, down-level
			End If
		Case ThreeD_Chess
			Select Case Piece'Dim CHS_Bishop As Int = 2, CHS_Knight As Int = 3, CHS_Rook  As Int = 4, CHS_Queen  As Int = 5
				Case CHK_Pawn'   | 1 spot at a time (or 2 for the first move), or \/ if occupied by the enemy
					'Log("CHK_Pawn at: " & X & ", " & Y & ", " & Z)
					If Team = MIN_White Then 'south/down
						DirY = 1'south
						DirZ = -1'down
					End If
					If Not(CHK_IsOccupied(Game, X, Y+DirY, Z)) Then Moves.Add(ThD_Set3DPoint(X, Y+DirY, Z))
					If Not(CHK_IsOccupied(Game, X, Y+DirY, Z+DirZ)) Then Moves.Add(ThD_Set3DPoint(X, Y+DirY, Z+DirZ))
					If FirstMove Then 
						If Not(CHK_IsOccupied(Game, X, Y+DirY*2, Z)) Then Moves.Add(ThD_Set3DPoint(X, Y+DirY*2, Z))
						If Not(CHK_IsOccupied(Game, X, Y+DirY*2, Z+DirZ)) Then Moves.Add(ThD_Set3DPoint(X, Y+DirY*2, Z+DirZ))
					End If
					If CHK_IsOccupied(Game, X-1, Y+DirY, Z) Then Moves.Add(ThD_Set3DPoint(X-1, Y+DirY, Z))
					If CHK_IsOccupied(Game, X+1, Y+DirY, Z) Then Moves.Add(ThD_Set3DPoint(X+1, Y+DirY, Z))
				Case CHS_Bishop' X
					'Log("CHS_Bishop at: " & X & ", " & Y & ", " & Z)
					CHS_AddLines(Game, Moves, X, Y, Z, Team, False, True)
				Case CHS_Knight' L
					'Log("CHS_Knight at: " & X & ", " & Y & ", " & Z)
					Moves.Add(ThD_Set3DPoint(X-1, Y+2, Z))
					Moves.Add(ThD_Set3DPoint(X-2, Y+1, Z))
					Moves.Add(ThD_Set3DPoint(X-1, Y-2, Z))
					Moves.Add(ThD_Set3DPoint(X-2, Y-1, Z))
					Moves.Add(ThD_Set3DPoint(X+1, Y+2, Z))
					Moves.Add(ThD_Set3DPoint(X+2, Y+1, Z))
					Moves.Add(ThD_Set3DPoint(X+1, Y-2, Z))
					Moves.Add(ThD_Set3DPoint(X+2, Y-1, Z))
					
					Moves.Add(ThD_Set3DPoint(X+2, Y, Z+1))
					Moves.Add(ThD_Set3DPoint(X+1, Y, Z+2))
					Moves.Add(ThD_Set3DPoint(X-2, Y, Z+1))
					Moves.Add(ThD_Set3DPoint(X-1, Y, Z+2))
					Moves.Add(ThD_Set3DPoint(X, Y+2, Z+1))
					Moves.Add(ThD_Set3DPoint(X, Y+1, Z+2))
					Moves.Add(ThD_Set3DPoint(X, Y-2, Z+1))
					Moves.Add(ThD_Set3DPoint(X, Y-1, Z+2))
					
					Moves.Add(ThD_Set3DPoint(X+2, Y, Z-1))
					Moves.Add(ThD_Set3DPoint(X+1, Y, Z-2))
					Moves.Add(ThD_Set3DPoint(X-2, Y, Z-1))
					Moves.Add(ThD_Set3DPoint(X-1, Y, Z-2))
					Moves.Add(ThD_Set3DPoint(X, Y+2, Z-1))
					Moves.Add(ThD_Set3DPoint(X, Y+1, Z-2))
					Moves.Add(ThD_Set3DPoint(X, Y-2, Z-1))
					Moves.Add(ThD_Set3DPoint(X, Y-1, Z-2))
				Case CHS_Rook'   +
					'Log("CHS_Rook at: " & X & ", " & Y & ", " & Z)
					CHS_AddLines(Game, Moves, X, Y, Z, Team, True, False)
				Case CHS_Queen'  *
					'Log("CHS_Queen at: " & X & ", " & Y & ", " & Z)
					CHS_AddLines(Game, Moves, X, Y, Z, Team, True, True)
				Case CHS_King'   O 1 spot at a time, in any direction
					'Log("CHS_King at: " & X & ", " & Y & ", " & Z)
					CHS_AddBlock(Game, Team, Moves, X-1,Y-1,Z-1, X+1, Y+1, Z+1)
			End Select
	End Select
	For temp = Moves.Size-1 To 0 Step -1'remove invalid points
		Remove=False
		temppoint = Moves.Get(temp)
		If Not(temppoint.IsInitialized) Then Remove = True
		If ThreeDGame.Gametype = ThreeD_Chess Then
			If Not(CHK_IsWithinBounds(ThreeDGame, temppoint)) Then Remove=True
			If temppoint.X = X And temppoint.Y = Y And temppoint.Z = Z Then Remove=True'same point
		End If
		'Log("Move " & temp & ": " & temppoint & " " & Remove)
		If Remove Then Moves.RemoveAt(temp)
	Next
	Return Moves
End Sub

Sub CHS_AddLines(Game As ThreeDboard, Moves As List, X As Int, Y As Int, Z As Int, Team As Int, Straight As Boolean, Diagonal As Boolean)
	If Straight Then 
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1,  0,  0)'Left
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1,  0,  0)'Right
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  0, -1,  0)'North
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  0,  1,  0)'South
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  0,  0,  1)'Up
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  0,  0, -1)'Down
	End If
	If Diagonal Then 
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1, -1,  0)'Left/North
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1,  1,  0)'Left/South
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1, -1,  0)'Right/North
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1,  1,  0)'Right/South
		
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1, -1,  1)'Left/North Up
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1,  1,  1)'Left/South Up
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1, -1,  1)'Right/North Up
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1,  1,  1)'Right/South Up
		
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1, -1,  1)'Left/North Down
		CHS_AddLine(Game, Moves, X, Y, Z, Team, -1,  1,  1)'Left/South Down
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1, -1,  1)'Right/North Down
		CHS_AddLine(Game, Moves, X, Y, Z, Team,  1,  1,  1)'Right/South Down
	End If
End Sub
Sub CHS_AddLine(Game As ThreeDboard, Moves As List, X As Int, Y As Int, Z As Int, Team As Int, MoveX As Int, MoveY As Int, MoveZ As Int)
	Dim CanContinue As Boolean = True, AddPoint As Boolean = True, NewTeam As Int 
	Do Until Not(CanContinue) 
		X=X+MoveX
		Y=Y+MoveY
		Z=Z+MoveZ
		NewTeam = TTT_GetTeam(Game, X, Y, Z)
		If NewTeam = -1 Then
			CanContinue = False
			AddPoint = False 
		Else If NewTeam > 0 Then
			CanContinue = False
			If NewTeam = Team Then AddPoint = False 
		End If
		If AddPoint Then Moves.Add(ThD_Set3DPoint(X,Y,Z))
	Loop
End Sub
Sub CHS_AddBlock(Game As ThreeDboard, Team As Int, Moves As List, Xsrc As Int, Ysrc As Int, Zsrc As Int, Xdest As Int, Ydest As Int, Zdest As Int) 
	Dim X As Int, Y As Int, Z As Int
	For X = Xsrc To Xdest 
		For Y = Ysrc To Ydest
			For Z = Zsrc To Zdest 
				If TTT_GetTeam(Game, X,Y,Z) <> Team Then Moves.Add(ThD_Set3DPoint(X,Y,Z))
			Next
		Next
	Next
End Sub
Sub CHK_Move(Game As ThreeDboard, X As Int, Y As Int, Z As Int, Team As Int, MoveX As Int, MoveY As Int, MoveZ As Int) As ThreeDPoint 
	Dim NewTeam As Int = TTT_GetTeam(Game, X+MoveX, Y+MoveY, Z+MoveZ), Temppoint As ThreeDPoint, C As String = ", "'uninitialized
	'Log("Checking " & X & C & Y & C & Z & " by " & MoveX & C & MoveY & C & MoveZ)
	If NewTeam > -1 Then
		If NewTeam = 0 Then 
			'Log("Not occupied. Returning")
			Return ThD_Set3DPoint(X+MoveX, Y+MoveY, Z+MoveZ)'empty spot
		End If
		If NewTeam <> Team Then'occupied by the other team
			'Log("Occupied, checking: " & (MoveX*2) & C & (MoveY*2) & C & (MoveZ*2))
			If TTT_GetTeam(Game, X+MoveX*2, Y+MoveY*2, Z+MoveZ*2) = 0 Then 
				'Log("Not occupied. Returning")
				Return ThD_Set3DPoint(X+MoveX*2, Y+MoveY*2, Z+MoveZ*2)'empty spot
			End If
		End If
	End If
	Return Temppoint
End Sub
Sub CHS_IsOtherTeam(Game As ThreeDboard, X As Int, Y As Int, Z As Int, Team As Int) As Boolean 
	Dim NewTeam As Int = TTT_GetTeam(Game, X, Y, Z)
	Return NewTeam >0 And NewTeam <> Team
End Sub
Sub CHS_Move(Moves As List, Game As ThreeDboard, X As Int, Y As Int, Z As Int, Team As Int)
	If CHS_IsOtherTeam(Game, X,Y,Z, Team) Then Moves.Add(ThD_Set3DPoint(X, Y, Z))
End Sub
Sub CHS_UnmarkAll(Game As ThreeDboard) 
	MIN_ClearMap(Game, False, False, False, False, False, False, True)
'	Dim temp As Int, Z As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece
'	For z = 0 To Game.Levels.Size - 1
'		tempLevel = Game.Levels.Get(z)
'		For temp = 0 To tempLevel.Grid.Size -1
'			tempPiece = tempLevel.Grid.Get(temp)
'			If tempPiece.Mark = False 
'		Next
'	Next
End Sub 
Sub CHS_MarkMoves(Moves As List, Game As ThreeDboard)
	Dim temp As Int, tempPiece As ThreeDPiece, tempPoint As ThreeDPoint 
	For temp = 0 To Moves.Size - 1 
		tempPoint = Moves.Get(temp)
		'Log("Marking: " & tempPoint.X & ", " & tempPoint.Y & ", " & tempPoint.Z)
		tempPiece = CHS_Get3DpieceXYZ(Game, tempPoint.X, tempPoint.Y, tempPoint.Z)
		tempPiece.Mark = True 
	Next
End Sub
Sub CHS_Get3DpieceXYZ(Game As ThreeDboard, X As Int, Y As Int, Z As Int) As ThreeDPiece
	Dim tempPiece As ThreeDPiece
	If X>-1 And Y>-1 And Z>-1 Then tempPiece = ThD_Get3DpieceXYZ(Game,X,Y,Z)
	Return tempPiece
End Sub











Sub NUM_DebugBoard(Game As ThreeDboard)
	Dim temp As Int, tempLevel As ThreeDLevel, X As Int, Y As Int, temp2 As Int, tempPiece As ThreeDPiece, tempstr As String  
	For temp = 0 To Game.Levels.Size - 1 
		tempLevel = Game.Levels.Get(temp)
		X=0
		Y=0
		Log("Level: " & temp)
		For temp2 = 0 To tempLevel.Grid.Size - 1 
			tempPiece = tempLevel.Grid.Get(temp2)
			tempstr = tempstr & API.PadtoLength(tempPiece.Piece, True, 2, "0") & " "
			X=X+1
			If X = tempLevel.Width Then 
				Log(tempstr.Trim)
				tempstr=""
				X=0
				Y=Y+1
			End If
		Next
	Next
End Sub
'Direction: 0=north, 1=east, 2=south, 3=west, 4=up, 5=down
'Log("DIRECTION AFTER: " & Index & " 0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start")
Sub NUM_ShiftBoard(Game As ThreeDboard, Direction As Int) As Boolean 
	Dim temp As Int, Ret As Boolean
	If Direction >=0 And Direction < 6 Then 
		Log("NUM_ShiftBoard: " & Direction & " - " & API.IIFIndex(Direction, Array As String("North", "East", "South", "West", "Up", "Down")))
	Else 
		Log("NUM_ShiftBoard: OB - " & Direction)
		Return False 
	End If 
	
	ThD_GridLoc = Trig.SetPoint(-1,-1)
	If Direction = 5 Then'down
		If Game.Levels.Size>1 Then
			For temp = Game.Levels.Size - 1 To 1 Step -1
				Ret = NUM_ShiftLevel(Game, temp, 5)
			Next
		End If
	Else
		If Direction = 4 And Game.Levels.Size = 1 Then Return False
		For temp = 0 To Game.Levels.Size - 1
			If Not(Direction = 4 And temp = Game.Levels.Size - 1) Then 
				Ret = NUM_ShiftLevel(Game, temp, Direction)
			End If
		Next
	End If
	If Ret Then 
		If NUM_RandomTiles(Game, 1) = 0 Then Game.ScoreBlack = 1 
		Game.isMoving = True
		'NUM_DebugBoard(Game)
		ThD_RefreshScores
		Return Ret 
	End If
End Sub
Sub NUM_ShiftLevel(Game As ThreeDboard, Z As Int, Direction As Int) As Boolean 
	Dim x As Int, y As Int, tempLevel As ThreeDLevel = Game.Levels.Get(Z), DirZ As Int, Ret As Boolean 
	Select Case Direction
		Case 0'north
			For y = tempLevel.Height -1 To 1 Step -1 
				For x = 0 To tempLevel.Width -1 
					If NUM_ShiftTile(Game, x,y,Z, 	0,-1,0, 	0,100) Then Ret = True
				Next
			Next
		Case 1'east
			For x = 0 To tempLevel.Width - 2
				For y = 0 To tempLevel.Height - 1
					If NUM_ShiftTile(Game, x,y,Z, 	1,0,0,		-100,0) Then Ret = True
				Next
			Next
		Case 2'south
			For y = 0 To tempLevel.Height - 2
				For x = 0 To tempLevel.Width -1 
					If NUM_ShiftTile(Game, x,y,Z, 	0,1,0, 		0,-100) Then Ret = True
				Next
			Next
		Case 3'west
			For x = tempLevel.Width - 1 To 1 Step -1
				For y = 0 To tempLevel.Height - 1
					If NUM_ShiftTile(Game, x,y,Z, 	-1,0,0, 	100,0) Then Ret = True
				Next
			Next
		Case 4, 5'up/down
			DirZ = API.IIF(Direction=4,1,-1)
			For x = 0 To tempLevel.Width - 1
				For y = 0 To tempLevel.Height - 1
					If NUM_ShiftTile(Game, x,y,Z, 	0,0,DirZ, 	0,0) Then Ret = True
				Next
			Next
	End Select
	Return Ret
End Sub
Sub NUM_ShiftTile(Game As ThreeDboard, X As Int, Y As Int, Z As Int, DirX As Int, DirY As Int, DirZ As Int, OffsetX As Int, OffsetY As Int) As Boolean 
	Dim srcPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game, X, Y, Z), destPiece As ThreeDPiece = ThD_Get3DpieceXYZ(Game, X+DirX, Y+DirY, Z+DirZ), DoIt As Boolean, Value As Int 
	If destPiece.Piece = 0 Or srcPiece.Piece = destPiece.Piece Then 
		destPiece.Piece = API.IIF(destPiece.Piece = 0, srcPiece.Piece, srcPiece.Piece+1)
		destPiece.Team = srcPiece.Team + destPiece.Team
		destPiece.Xoffset=OffsetX + srcPiece.Xoffset
		destPiece.Yoffset=OffsetY + srcPiece.Yoffset
		
		srcPiece.Piece = 0 
		srcPiece.Team = 0
		srcPiece.Xoffset = 0
		srcPiece.Yoffset = 0
		
		Game.ScoreWhite = Game.ScoreWhite + destPiece.Team
		
		Return True
	End If
End Sub

Sub NUM_DrawSprite(BG As Canvas, X As Int, Y As Int, Size As Int, Piece As Int, Team As Int)
	Dim Whitespace As Int = 2, Color As Int, Tile As PdPTile 
	Tile.Initialize
	Tile.Alpha=255
	Tile.Text = Team 
	Tile.Width=1
	Tile.Height=1
	Size=Size-Whitespace*2
	Tile.ColorID=Piece Mod LCAR.LCARcolors.Size
	If Tile.ColorID>12 Then Tile.ColorID= Tile.ColorID+1 'skip red alert
	PDPDrawTile(BG,X+Whitespace,Y+Whitespace,False,Size, Size, Tile, False,False)
End Sub

Sub NUM_RandomTiles(Game As ThreeDboard, Tiles As Int) As Int 
	Dim Count As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece 
	If NUM_CanMove(Game) Then 
		Do Until Tiles = 0
			tempLevel = Game.Levels.Get(Rnd(0, Game.Levels.Size))
			tempPiece = tempLevel.Grid.Get(Rnd(0, tempLevel.Grid.Size))
			If tempPiece.Piece=0 Then 
				tempPiece.Piece = Rnd(1,3)'1 or 2
				tempPiece.Team = tempPiece.Piece
				Tiles = Tiles - 1
				Count=Count+1
				If Tiles > 0 Then
					If Not(NUM_CanMove(Game)) Then Tiles = 0 
				End If
			End If
		Loop
	End If
	Return Count
End Sub

Sub NUM_CanMove(Game As ThreeDboard) As Boolean 
	Dim temp As Int, temp2 As Int, tempLevel As ThreeDLevel, tempPiece As ThreeDPiece 
	For temp = 0 To Game.Levels.Size-1
		tempLevel = Game.Levels.Get(temp)
		For temp2 = 0 To tempLevel.Grid.Size - 1 
			tempPiece = tempLevel.Grid.Get(temp2)
			If tempPiece.Piece=0 Then Return True
		Next
	Next
End Sub





'Type Card(Loc As tween, Value As Int, Face As Boolean, Suit As Int)
'Type Cardpile(Cards As List, X As Int, Y As Int, Style As Int, Selected As Int)
'Dim PileList As List, SelectedPile As Int, CardParams As Map, CardWidth As Int = 196

'Game: -1=resume
Sub CARD_StartGame(BG As Canvas, ElementID As Int, Game As Int, FirstTime As Boolean)
	Dim temp As Int, CardHeight As Int = CARD_GetCardHeight
	LCAR.HideToast
	If ElementID=-1 Then ElementID = CARD_ElementID
	LCAR.RespondToAll(ElementID)
	LCAR.LCAR_HideAll(BG, False)
	LCARSeffects.ShowFrame(BG, True, True, 3)
	LCAR.ForceShow(ElementID,True)
	LCAR.GetElement(ElementID).Blink=True
	CARD_X = 0
	CARD_Y = 0
	CARD_TimesDealt=0
	If Game>-1 Then
		PileList.Initialize 
		CARD_Pot=0
		CARD_Game = Game	
		CARD_IsWinning=False
		CARD_GameOver=False
		SelectedPile=0
		CARD_TimePassed=0
		CARD_Locked=True
		CARD_MaxX=0
		CARD_MaxY=0
		Select Case Game
			Case 0: SOL_Init(CardHeight)'Solitaire
			Case 1: HL_Init(CardHeight,FirstTime)'higher/lower
			Case 2: BLK_Init(CardHeight)'Blackjack
			Case 3: PKR_Init(CardHeight)'Poker
			Case 4: PRS_Init(CardHeight)'President
			Case 5: HRT_Init(CardHeight)'Hearts
		End Select
		CARD_Locked=False
		Game = CARD_Game
		CARD_ClearUndo
	End If
	
	If CARD_UseMulti Then
		LCAR.ForceShow(ElementID+1,True)
		LCAR.GetElement(ElementID+1).Blink=True
	End If
	
	CARD_HandleOptions(BG, -2,0)

	If CARD_Red=0 Then CARD_Red = LCAR.LCAR_Orange 
	If CARD_Black=0 Then CARD_Black = LCAR.Classic_Green 
	CARD_ElementID=ElementID
End Sub

Sub CARD_GetCardHeight As Int
	Return CardWidth * 1.306122448979592
End Sub

Sub CARD_ColorName(Index As Int) As String 
	Dim Color As LCARColor = LCAR.LCARcolors.Get(Index)
	Return Color.Name.ToUpperCase 
End Sub
Sub CARD_EnumColors As String()
	Dim temp As Int, TheColors(LCAR.LCARcolors.Size-1) As String, tempstr As StringBuilder, Color As LCARColor 
	For temp = 1 To LCAR.LCARcolors.Size-1
		Color = LCAR.LCARcolors.Get(temp)
		If tempstr.IsInitialized Then
			tempstr.Append("," & Color.Name)
		Else
			tempstr.Initialize
			tempstr.Append(Color.Name)
		End If
	Next
	Return Regex.Split(",",tempstr.ToString.ToUpperCase)
End Sub

Sub CARD_Options(Index As Int) As String()
	Select Case Index
		Case -1,7: Return Array As String("ENABLED", "DISABLED")'BOOLEAN
		Case 0:
			If PileList.IsInitialized Then 
				If PileList.Size>0 Then Return Array As String("START", "RESUME")
			End If
			Return Array As String("START")
		Case 1: Return Array As String("SOLITAIRE", "PSYCHIC TEST", "BLACKJACK", "POKER", "CAPTAIN", "HEARTS")
		Case 2: Return Array As String("49", "98", "147", "196", "245", "294", "343", "392", "441", "490")'
		Case 3,4,5: Return CARD_EnumColors
		Case 6: Return Array As String("FEDERATION")'room for 3 more
		
		'case X: SEPARATOR
		Case Else': Return Array As String("N/A")
			Select Case CARD_Game
				Case 0' Solitaire
					Select Case Index - CARD_SettingsStartAt
						Case 0: Return Array As String("1", "2", "3", "4", "5")'deal
						Case 1: Return Array As String("DISABLED", "VEGAS", "STANDARD")'score method
						Case 2: Return CARD_Options(-1)'timed
					End Select
				Case 5'hearts
					Select Case Index - CARD_SettingsStartAt
						Case 0: Return Array As String("50", "100", "150", "200")
					End Select
			End Select
			Return Array As String("N/A: " & CARD_Game  & "." & (Index- CARD_SettingsStartAt))
	End Select
	Return Array As String("N/A: " & CARD_Game  & "." & Index)
End Sub

Sub CARD_SettingsStartAt As Int
	Return 9
End Sub
Sub CARD_HandleOptions(BG As Canvas, ListID As Int, Index As Int) As Boolean 
	'Dim SOL_MaxRotations As Int, SOL_MaxCards As Int=3, SOL_ScoringMethod As Int, SOL_TimedGame As Boolean, SOL_Rotations As Int, 
	Dim tempList As List, SettingIndex As Int = Main.SettingIndex, CurrentGame As String = CARD_Options(1)(CARD_Game), TextValue As String ,NeedsReset As Boolean 	
	Select Case ListID
		Case -2'seed button list
			Select Case CARD_Game'betting games
				Case 1,2,3'higher/lower,blackjack/poker
					LCAR.SeedSideBar(BG, -1, Array As String("+", "-", "1", "5", "10", "50", "100", "500"), False, True, -1)
				Case Else
					LCARSeffects.ShowFrame(BG, False,True,-1)
					'LCAR.SeedSideBar(BG, -1, Array As String("+", "-"),  False, True, -1)
			End Select
			Select Case CARD_Game
				Case 0'solitaire
					LCAR.SeedButtonBar(BG, Array As String("DEAL " & SOL_MaxCards, "NEW", "AI", "UNDO"))
				Case 1'higher/lower
					LCAR.SeedButtonBar(BG, Array As String("HI", "LOW"))
				Case 2'blackjack
					LCAR.SeedButtonBar(BG, Array As String("HIT", "STAY"))
				Case 3'poker
					LCAR.SeedButtonBar(BG, Array As String("DEAL"))
				Case 4'president
					LCAR.SeedButtonBar(BG, Array As String(API.GetString("kb_ok")))
			End Select		
		Case -1'seed main list
			LCAR.LCAR_ClearList(3,0)
			SetElement18Text("sec_72")
			SeedSetting( "set-6.3", "",  "")'listitem 0
			SeedSetting( "mode3", "card_whichgame", CurrentGame)'listitem 1
			
			SeedSetting( "card_size", "card_size_d",  CardWidth)'listitem 2
			SeedSetting( "card_edge", "card_edge_d",  CARD_ColorName(LCAR.GetElement(CARD_ElementID).ColorID))'listitem 3
			SeedSetting( API.GetStringVars("card_fed_klingon", Array As String(CARD_SuiteToString(CARD_Heart), CARD_SuiteToString(CARD_Diamond))), "card_color_of_red",  CARD_ColorName(CARD_Red))'listitem 4
			SeedSetting( API.GetStringVars("card_rom_borg", Array As String(CARD_SuiteToString(CARD_Club), CARD_SuiteToString(CARD_Spade))), "card_color_of_black",  CARD_ColorName(CARD_Black))'listitem 5
			SeedSetting( "card_back", "card_back_d", CARD_Options(6)(CARD_Face-1))'listitem 6
			SeedSetting( "card_wind", "card_wind_d", API.BoolToText(CARD_UseMulti))'listitem 7
			SeedSetting( CurrentGame & " OPTIONS:", "card_warning", "")'listitem 8
			SettingIndex=CARD_SettingsStartAt
			Select Case CARD_Game
				Case 0'Solitaire
					SeedSetting("card_sol_dealx", "card_sol_dealx_d",  SOL_MaxCards)
					SeedSetting("card_sol_score", "", CARD_Options(SettingIndex+1)(SOL_ScoringMethod))
					SeedSetting("card_sol_timed", "card_sol_timed_d", API.BoolToText(SOL_TimedGame))
				Case 5'Hearts
					SeedSetting("card_heart_until", "card_heart_until_d",  HRT_Score)
				Case Else
					SeedSetting("card_no_options", "",  "")
			End Select
		Case 3'big list
			tempList.Initialize2(CARD_Options(Index))
			LCAR.LCAR_AddListItems(4, LCAR.LCAR_Random,0, tempList)
			LCAR.LCAR_SetSelectedItem(4, API.FindIndex(CARD_Options(Index), LCAR.LCAR_GetListitemText(3,Index, 1)))
		Case 4'suboptions
			TextValue=LCAR.LCAR_GetListItem(4,Index).Text
			Select Case SettingIndex
				Case 0'start game
					CARD_StartGame(BG, CARD_ElementID, API.IIF(Index=0,CARD_Game,-1), Index=0 Or NeedsReset Or Not(PileList.IsInitialized))
				Case 1'change game
					CARD_Game = Index
					CARD_HandleOptions(BG,-1,0)'refresh settings
					NeedsReset=True
				Case 2'card size
					CardWidth = TextValue
					NeedsReset=True
				Case 3'edge color
					LCAR.GetElement(CARD_ElementID).ColorID = Index+1
				Case 4'FED/KLNGON color
					CARD_Red = Index+1
				Case 5'BORG/Romulan color
					CARD_Black = Index+1
				Case 6'card back
					CARD_Face = Index+1 
				Case 7
					CARD_UseMulti = Index = 0
				Case Else 
					Select Case CARD_Game
						Case 0'solitaire
							Select Case SettingIndex - CARD_SettingsStartAt
								Case 0: SOL_MaxCards = TextValue
								Case 1: SOL_ScoringMethod = Index
								Case 2: SOL_TimedGame = Index = 0
							End Select
							NeedsReset=True
						Case 5'hearts
							Select Case SettingIndex - CARD_SettingsStartAt
								Case 0: HRT_Score = TextValue
							End Select
					End Select
			End Select
			If NeedsReset Then PileList.Initialize 
		Case 5'button menu
			Select Case CARD_Game
				Case 0'solitaire
					Select Case Index
						Case 0: SOL_Deal3Cards(SOL_MaxCards, "Button menu")
						Case 1: SOL_Init(CARD_GetCardHeight)
						Case 2: SOL_AI
						Case 3: CARD_PullUndo
					End Select
				Case 1'higher lower
					HL_Guess(Index=0)
				Case 2'blackjack
					BLK_Action(Index=0)
				Case 3'poker
					PKR_ChooseSelected(0)
				Case 4'president
					PRS_OK
			End Select
		Case 19'sidebar
			Select Case CARD_Game
				Case 1,2,3'Hi/Lo, blackjack, poker (betting games)
					If CARD_CanBet Then
						Select Case Index
							Case 0:CARD_DecreasingBid=False'+
							Case 1:CARD_DecreasingBid=True'-
							Case Else: CARD_HandleBid(LCAR.LCAR_GetListitemText(19, Index, 0))
						End Select
					End If
				'Case Else
					'If Index = 0 Then'+
					'	"49", "98", "147", "196", "245", "294", "343", "392", "441", "490"
			End Select
		Case Else 
			Log("ListID: " & ListID & " is unhandled (" & Index & ")")
	End Select
End Sub 

Sub CARD_UpdateCash(Bid As Boolean)'CARD_CurrBid
	Dim tempstr As StringBuilder 
	tempstr.Initialize
	tempstr.Append(API.GetStringVars("card_you_have", Array As String( CARD_Cash)))
	If Bid Then 
		tempstr.Append( " " & API.GetStringVars("card_bet", Array As String(CARD_CurrBid, API.GetString(API.IIF(CARD_DecreasingBid, "card_bet_decreasing", "card_bet_increasing")) )) )
		If CARD_Pot>0 Then tempstr.Append(" " & API.GetStringVars("card_pot_has", Array As String( CARD_Pot)))
	End If
	SetElement18Text(tempstr.ToString)
End Sub

Sub CARD_HandleBid(Value As Int)
	If CARD_DecreasingBid Then 
		CARD_CurrBid = Max(1,CARD_CurrBid - Value)
	Else 
		CARD_CurrBid = CARD_CurrBid + Value
	End If
	CARD_UpdateCash(True)
End Sub

Sub CARD_PileCard(Pile As Cardpile, CardIndex As Int) As Card 
	If CardIndex<0 Then CardIndex = Pile.Cards.Size+CardIndex
	Return Pile.Cards.Get(CardIndex)
End Sub
Sub CARD_Card(Pile As Int, CardIndex As Int)As Card 
	Return CARD_PileCard(CARD_Pile(Pile),CardIndex)
End Sub
Sub CARD_Pile(Index As Int) As Cardpile 
	Return PileList.Get(Index)
End Sub

Sub CARD_DrawCards(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, Alpha As Int, State As Boolean, Surface As Int, DoOffset As Boolean)
	Dim Color As Int = LCAR.GetColor(ColorID,False,255), CardHeight As Int = CARD_GetCardHeight
	Dim temp As Int,temp2 As Int, tempPile As Cardpile, tempS As Point, Selected As Point 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "cards.png", LCAR.LCAR_Cards)
	LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
	LCARSeffects4.DrawRect(BG,X,Y,Width,Height,Colors.Black,0)
	If DoOffset Then
		CARD_Width=Width
		CARD_Height=Height
		X=X+CARD_X
		Y=Y+CARD_Y
		If CARD_IsWinning Then CARD_Height = CARD_Height + Abs(CARD_Y)
	End If
	CARD_X3=X
	CARD_Y3=Y
	If PileList.IsInitialized And Not(CARD_Locked) Then
		If CARD_OldWidth <> Width Then CARD_Resize(Width,Height)
'		For temp = 0 To PileList.Size - 1
'			tempPile = PileList.Get(temp)
'			If tempPile.X>-1 AND tempPile.Y>-1 Then
'				'CARD_TweenPile(tempPile,0,  X + tempPile.X, Y + tempPile.Y)
'				'tempS = CARD_DrawCardPile(BG, tempPile, tempPile.Loc.currX, tempPile.Loc.currY, Alpha, CardHeight, Color, temp = SelectedPile,X,Y,State)
'				tempS = CARD_DrawCardPile(BG, tempPile, X+tempPile.X, Y+tempPile.Y, Alpha, CardHeight, Color, temp = SelectedPile,X,Y,State)
'				If tempS.IsInitialized Then Selected = tempS
'			End If
'		Next
		Selected = CARD_DrawPiles(BG,X,Y,Color,CardHeight,Alpha,State,False,Selected, Surface)
		Selected = CARD_DrawPiles(BG,X,Y,Color,CardHeight,Alpha,State,True,Selected, Surface)
		If CARD_IsWinning Then 
			CARD_DrawCardStyle(BG, CARD_WinningCard.Loc.currX, CARD_WinningCard.Loc.currY, Alpha,CardHeight, CARD_WinningCard, Color, CARD_FillColor(CARD_WinningCard,Alpha,False)) 
		End If
		If Selected.IsInitialized And Not(CARD_IsWinning) Then CARD_DrawSelected(BG,Selected.X,Selected.Y, CardWidth, CardHeight, LCAR.GetColor(ColorID,State,255), Alpha)
	Else If CARD_Locked Then
		LCAR.DrawUnknownElement(BG,X,Y,Width,Height, ColorID,State, Alpha, API.getstring("card_dealing"))
	End If
	temp =  DateTime.GetSecond(DateTime.Now)
	If CARD_LastUpdate<> temp Then 
		CARD_TimePassed=CARD_TimePassed+1
		Select Case CARD_Game
			Case 0: If SOL_TimedGame Then SOL_Draw
		End Select
	End If
	'LCAR.DrawUnknownElement(BG,X,Y,Width,Height,ColorID,State,Alpha,Surface)
	BG.RemoveClip 
	CARD_LastUpdate = temp
End Sub

Sub CARD_DrawPiles(BG As Canvas, X As Int, Y As Int, Color As Int, CardHeight As Int, Alpha As Int, State As Boolean, Moving As Boolean, Selected As Point, Surface As Int) As Point 
	Dim temp As Int,temp2 As Int, tempPile As Cardpile, tempS As Point, PileHeight As Int 
	For temp = 0 To PileList.Size - 1
		tempPile = PileList.Get(temp)
		If tempPile.X>-1 And tempPile.Y>-1 Then'AND tempPile.Surface=Surface Then
			'CARD_TweenPile(tempPile,0,  X + tempPile.X, Y + tempPile.Y)
			'tempS = CARD_DrawCardPile(BG, tempPile, tempPile.Loc.currX, tempPile.Loc.currY, Alpha, CardHeight, Color, temp = SelectedPile,X,Y,State)
			tempS = CARD_DrawCardPile(BG, tempPile, X+tempPile.X, Y+tempPile.Y, Alpha, CardHeight, Color, temp = SelectedPile,X,Y,State, Moving, Surface)
			PileHeight= CARD_PileHeight(tempPile, CardHeight)-CardHeight
			If tempPile.Style = CARD_Cards And Moving Then PileHeight=CARD_PileHeight(tempPile,CardHeight) 'only needs to calculate it once per cycle
			CARD_VirtualMAX(X,Y,X+tempPile.X + CARD_PileWidth(tempPile) - CardWidth, Y+tempPile.Y, PileHeight)
			If tempS.IsInitialized Then Selected = tempS
		End If
	Next
	Return Selected
End Sub

'Sub CARD_TweenPile(tempPile As Cardpile, SpeedXY As Int, X As Int, Y As Int)
'	Dim DidInit As Boolean 
'	If Not(tempPile.Loc.IsInitialized) Then
'		tempPile.Loc.Initialize 
'		DidInit = True
'	End If 
'	If SpeedXY= 0 Then
'		tempPile.Loc.offX = X
'		tempPile.Loc.offY = Y
'	End If
'	If DidInit Then 
'		tempPile.Loc.currX = tempPile.Loc.offX
'		tempPile.Loc.currY = tempPile.Loc.offY
'	Else If SpeedXY>0 Then
'		tempPile.Loc.currX = LCAR.Increment(tempPile.Loc.currX, SpeedXY, tempPile.Loc.offX)
'		tempPile.Loc.currY = LCAR.Increment(tempPile.Loc.currY, SpeedXY, tempPile.Loc.offY)
'	End If
'End Sub

Sub CARD_IncrementCards As Boolean 
	Dim tempPile As Cardpile, PileIndex As Int, tempCard As Card, CardIndex As Int, Ret As Boolean, SpeedSize As Int = 5, SpeedXY As Int = 10
	If LCAR.CrazyRez>1 Then SpeedXY = SpeedXY * LCAR.CrazyRez
	For PileIndex = 0 To PileList.Size-1
		tempPile = PileList.Get(PileIndex)
		CARD_IncrementLOC(tempPile.Loc,SpeedXY)
		'CARD_TweenPile(tempPile, SpeedXY, 0,0)
		For CardIndex = 0 To tempPile.Cards.Size - 1
			If CARD_IncrementCard(tempPile.Cards.Get(CardIndex), SelectedPile = PileIndex And tempPile.Selected = CardIndex, SpeedXY, SpeedSize) Then Ret = True
		Next
	Next
	CARD_oX = 0
	CARD_oY = 0
	If CARD_IsWinning Then 
		Ret=True
		CARD_AnimateCard
	End If
	Return Ret Or CARD_IsWinning
End Sub

Sub CARD_IncrementLOC(LOC As tween, Speed As Int)
	If LOC.currX = -1 Then LOC.currX = LOC.offX
	If LOC.currY = -1 Then LOC.currY = LOC.offY
	LOC.currX = LCAR.Increment(LOC.currX, Speed, LOC.offX)
	LOC.currY = LCAR.Increment(LOC.currY, Speed, LOC.offY)
End Sub
Sub CARD_IncrementCard(tempCard As Card, Selected As Boolean, SpeedXY As Int, SpeedS As Int)
	Dim Ret As Boolean, DesiredSize As Byte = API.IIF(Selected, 100, 0)
	Ret = tempCard.LOC.currX <> tempCard.Loc.offX Or tempCard.Loc.offY <> tempCard.LOC.currY Or tempCard.Size <> DesiredSize
	CARD_IncrementLOC(tempCard.LOC,SpeedXY)
	'tempCard.LOC.currX = LCAR.Increment(tempCard.LOC.currX + CARD_oX, SpeedXY, tempCard.Loc.offX)
	'tempCard.LOC.currY = LCAR.Increment(tempCard.LOC.currY + CARD_oY, SpeedXY, tempCard.Loc.offY)
	tempCard.Size = LCAR.Increment(tempCard.Size, SpeedS, DesiredSize)
	tempCard.Angle = LCAR.Increment(tempCard.Angle, SpeedXY, API.IIF(tempCard.Face, 180,0))
	Return Ret
End Sub

Sub CARD_AddPile(X As Int, Y As Int, Style As Int, Surface As Int) As Cardpile 
	Dim tempPile As Cardpile 
	tempPile.Initialize 
	tempPile.Cards.Initialize 
	tempPile.X = X
	tempPile.Y = Y
	tempPile.Surface=Surface
	tempPile.Selected = -1
	tempPile.Style = Style
	PileList.Add(tempPile)
	CARD_MaxX = Max(CARD_MaxX,X)
	CARD_MaxY = Max(CARD_MaxY,Y)
	Return tempPile
End Sub
Sub CARD_AddPile2(Col As Int, Row As Int, Style As Int, Surface As Int) As Cardpile 
	Dim CardHeight As Int = CARD_GetCardHeight
	Return CARD_AddPile(CARD_Col(Col), CARD_Row(Row, CardHeight), Style, Surface)
End Sub

Sub CARD_DeletePiles()
    PileList.Initialize 
	SelectedPile = -1
	CARD_Locked=True
End Sub

Sub CARD_DealCards(srcPile As Cardpile, destPile As Cardpile, Cards As Int, srcPileID As Int, destPileID As Int)
    Dim temp As Int
    For temp = 1 To Cards
        CARD_MoveCard (srcPile, srcPile.Cards.Size - 1, destPile, srcPileID, destPileID)
    Next
End Sub

Sub CARD_FindCard(Value As Int, Suite As Int) As Point 
	Dim temp As Int, Index As Int 
	For temp = 0 To PileList.Size - 1
		Index = CARD_CardCount( CARD_Pile(temp), Value, Suite, True)
		If Index > -1 Then Return Trig.SetPoint(temp,Index)
	Next
	Return Trig.SetPoint(-1,-1)
End Sub

'Index: True = Returns Index, False = Returns Count. Value/Suite: 0 = Wildcard
Sub CARD_CardCount(Pile As Cardpile, Value As Int, Suite As Int, Index As Boolean) As Int 
	Dim temp As Int, tempCard As Card, Found As Boolean, Count As Int 
	If Index Then Count = -1
	For temp = 0 To Pile.Cards.Size - 1 
		tempCard = Pile.Cards.Get(temp)
		Found=False
		If Value>0 Then
			If Suite>0 Then
				If Value = tempCard.Value And Suite = tempCard.Suite Then Found = True
			Else
				If Value = tempCard.Value Then Found = True
			End If
		Else
			If tempCard.Suite = Suite Then Found = True
		End If
		If Found Then
			If Index Then Return temp
			Count = Count+1
		End If 
	Next
	Return Count
End Sub	

Sub CARD_HasCard(Pile As Cardpile, Value As Int, Suite As Int) As Boolean 
	Return CARD_CardCount(Pile, Value, Suite, True)>0
End Sub

Sub CARD_EmptyPile(Pile As Cardpile)
	If Not(Pile.IsInitialized) Then Pile.Initialize
	Pile.Cards.Initialize
	Pile.Selected = -1
End Sub

Sub CARD_MakeCard(Value As Int, Suite As Int, Face As Boolean, Blink As Boolean) As Card
	Dim tempCard As Card
	tempCard.Initialize 
	tempCard.Face = Face
	tempCard.Suite = Suite
	tempCard.Value = Value
	tempCard.Loc.Initialize
	tempCard.Loc.currX = -1
	tempCard.Loc.currY = -1
	tempCard.Blink = Blink
	Return tempCard
End Sub
Sub CARD_AddCard(Pile As Cardpile, Value As Int, Suite As Int, Face As Boolean) As Card 
	Dim tempCard As Card = CARD_MakeCard(Value,Suite,Face,False)
	If Not(Pile.IsInitialized) Then Pile.Initialize 
	Pile.Cards.Add(tempCard)
	Return tempCard
End Sub

Sub CARD_DeleteCard(Pile As Cardpile, Index As Int)
	If Index<0 Then Index = Pile.Cards.Size+Index
	Pile.Cards.RemoveAt(Index)
End Sub

'true = red (FED/Klingon)
Sub CARD_GetColor(Suite As Int) As Boolean 
	Return Suite < 3
End Sub
Sub CARD_FillColor(tempCard As Card, Alpha As Int,State As Boolean ) As Int
	If tempCard.Blink Then State = State And tempCard.Blink
	Return LCAR.GetColor(API.IIF(CARD_GetColor(tempCard.Suite), CARD_Red,CARD_Black), State, Alpha)
End Sub

Sub CARD_SeedDeck(destPile As Cardpile, Face As Boolean)
	For temp = 1 To 13
		CARD_AddCard(destPile, temp, 1, Face)'heart
		CARD_AddCard(destPile, temp, 2, Face)'diamond
		CARD_AddCard(destPile, temp, 3, Face)'club
		CARD_AddCard(destPile, temp, 4, Face)'spade
	Next
End Sub
Sub CARD_ShuffleDeck(destPile As Cardpile, Decks As Int, Face As Boolean)
	Dim srcPile As Cardpile, temp As Int, temp2 As Int
	CARD_EmptyPile(srcPile)
	For temp = 1 To Decks
		CARD_SeedDeck(srcPile, Face)
	Next
	For temp = 1 To Decks*52
		CARD_MoveCard(srcPile, Rnd(0, srcPile.Cards.size), destPile, -1,-1)
	Next
End Sub

Sub CARD_MoveCard(srcPile As Cardpile, Index As Int, destPile As Cardpile, srcPileID As Int, destPileID As Int) As Int 
	Dim newCard As Card, tempCard As Card
	If Index<0 Then Index = srcPile.Cards.size + Index
	If Index < srcPile.Cards.Size And Index>-1 Then
		tempCard = srcPile.Cards.Get(Index)
		newCard = CARD_AddCard(destPile, tempCard.Value, tempCard.Suite, tempCard.Face)
		CARD_Transpose(tempCard,srcPile,newCard)
		CARD_DeleteCard(srcPile, Index)
		If srcPileID>-1 And destPileID>-1 Then CARD_PushUndo(srcPileID,destPileID, destPile.cards.size-1)
		Return Index
	End If
	Return -1
End Sub

Sub CARD_ClearUndo
	UndoStack.Initialize 
End Sub
Sub CARD_PushUndo(srcPileID As Int, destPileID As Int, destIndex As Int)
	Dim tempUndo As Point
	If Not(UndoStack.IsInitialized) Then CARD_ClearUndo
	tempUndo.Initialize 
	tempUndo.X = srcPileID
	tempUndo.Y = destPileID
	'tempUndo.Z = destIndex
	UndoStack.Add(tempUndo)
End Sub
Sub CARD_PullUndo As Boolean 
	Dim tempUndo As Point, srcPile As Cardpile, destPile As Cardpile, temp As Int 
	If Not(UndoStack.IsInitialized) Then Return False
	For temp = UndoStack.Size - 1 To 0 Step -1
		tempUndo = UndoStack.Get(temp)
		srcPile = CARD_Pile(tempUndo.Y)
		destPile = CARD_Pile(tempUndo.X)
		CARD_MoveCard(srcPile, -1, destPile, -1,-1)
	Next
	CARD_ClearUndo
	Return True
End Sub

Sub CARD_Untranspose(tempCard As Card)
	tempCard.Loc.currX = -1
	tempCard.Loc.currY = -1
End Sub
Sub CARD_Transpose(srcCard As Card, srcPile As Cardpile, destCard As Card)'Off is destination, curr is current position
	'Log("destCard before: " & destCard.Loc)
	Select Case srcPile.style 
		Case CARD_Aces, CARD_Deck
			'If srcPile.style = CARD_Aces AND srcPile.Cards.Size>0 Then
			'	srcCard = CARD_GetCard(srcPile,-1)
			'	destCard.Loc.currX = srcCard.Loc.currX 
			'	destCard.Loc.currY = srcCard.Loc.currY 
			'Else
			If srcPile.loc.isinitialized Then
				'destCard.Loc.currX = srcPile.loc.x
				'destCard.Loc.currY = srcPile.loc.Y
				destCard.Loc.currX = srcPile.loc.currX
				destCard.Loc.currY = srcPile.loc.currY
			Else
				destCard.Loc.currX = CARD_X3 - CARD_X + srcPile.X
				destCard.Loc.currY = CARD_Y3 - CARD_Y + srcPile.Y
			End If
			'Log("SRCPILE: " & srcPile.X & " " & srcPile.Y)
		Case CARD_Invisible
			destCard.Loc.currX = -1
			destCard.Loc.currY = -1
		Case Else
			destCard.Loc.currX = srcCard.Loc.currX 
			destCard.Loc.currY = srcCard.Loc.currY 
			'Log("srcCard: " & srcCard.Loc)
	End Select
	destCard.Angle = srcCard.Angle 
	'Log("destCard after: " & destCard.Loc)
End Sub

Sub CARD_MoveCards(srcpile As Cardpile, Index As Int, destPile As Cardpile, srcPileID As Int, destPileID As Int)
	Dim temp As Int, Cards As Int = srcpile.Cards.Size - 1
	For temp = Index To Cards
		CARD_MoveCard(srcpile, Index, destPile, srcPileID, destPileID)
	Next
End Sub

Sub CARD_RelativeCard(Value As Int, Direction As Int) As Int
	Value = Min(14, Value + Direction)
	If Value < 1 Then Value = (Value Mod 14) + 13
	Return Value 
End Sub

Sub CARD_RevealHand(Pile As Cardpile, Face As Boolean)
	Dim temp As Int, tempCard As Card
	For temp = 0 To Pile.Cards.Size - 1
		tempCard = Pile.Cards.Get(temp)
		tempCard.Face = Face
	Next
End Sub

Sub CARD_DealCardsMulti(srcpile As Cardpile, Cards As Long, destPiles() As Int, srcPileID As Int)
	Dim temp As Int, temp2 As Int 
	For temp = 1 To Cards
		For temp2 = 0 To destPiles.Length -1 
			CARD_MoveCard(srcpile, srcpile.Cards.Size - 1, PileList.Get(destPiles(temp2)), srcPileID, destPiles(temp2))
		Next
	Next
End Sub

'Value: 0=back of the card, -1=(Suite: 0=Selection Cursor, 1=Empty spot), Else=Cards themselves (1=Ace,2,3,4,5,6,7,8,9,10,11=J,12=Q,13=K)
Sub CARD_DrawCard(BG As Canvas, X As Int, Y As Int, EdgeColor As Int, FillColor As Int, Alpha As Int, CardHeight As Int, Suite As Int, Value As Int)'196 * 256
	Dim CornerRadius As Int = CardWidth * 0.1, srcY As Int = 256*(Suite-1), srcX As Int = Value*196
	If Value= 0 Then 'FACE
		Dim ShrinkFactor As Float = 0.05, ShrinkFactor2 As Float = 1-(ShrinkFactor*2)
		LCAR.DrawRoundedRectangle(BG,X,Y,CardWidth, CardHeight,CornerRadius, EdgeColor, 0)
		Select Case Suite
			Case 1: FillColor = Colors.ARGB(Alpha, 37,53,129) 'Federation
		End Select
		CARD_DrawStencil(BG, X+ CardWidth*ShrinkFactor, Y+CardHeight*ShrinkFactor, CardWidth*ShrinkFactor2, CardHeight*ShrinkFactor2,  srcX,srcY,196,256,FillColor)
	Else If Value = -1 Then
		Select Case Suite 
			Case 0'selected
				srcX = 10'whitespace
				srcY = 4'stroke
				LCAR.DrawRoundedRectangle(BG,X-srcX,Y-srcX, CardWidth+(srcX*2), CardHeight+ (srcX*2), CornerRadius, EdgeColor, srcY)
			Case 1'empty spot
				LCARSeffects4.DrawRect(BG,X,Y,CardWidth-2,CardHeight, EdgeColor, 0)
		End Select
	Else
		CARD_DrawStencil(BG,    X,   Y,CardWidth,CardHeight,  srcX,srcY, 196,256, FillColor)
		LCAR.DrawRoundedRectangle(BG,X,Y,CardWidth, CardHeight,CornerRadius, EdgeColor, 2)
	End If
End Sub

Sub CARD_DrawStencil(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, srcX As Int, srcY As Int, srcWidth As Int, srcHeight As Int, Color As Int)
	Dim Dest As Rect = LCARSeffects4.SetRect(X,Y,Width,Height)
	BG.DrawRect(Dest,Color,True,0)
	BG.DrawBitmap(LCARSeffects2.CenterPlatform,  LCARSeffects4.SetRect(srcX,srcY,srcWidth,srcHeight), Dest)
End Sub

Sub CARD_PileWidth(Pile As Cardpile) As Int 
	Dim temp As Int, TempCard As Card, Width As Int 
	Select Case Pile.Style
		Case CARD_Deck, CARD_Aces, CARD_Cards: Return CardWidth
		Case CARD_Dealt, CARD_Horizontal
			For temp = 0 To Pile.Cards.Size - 1 
				TempCard = Pile.Cards.Get(temp)
				Width = Width + CARD_Size(Pile,temp,0, TempCard.Size)
			Next
			Return Width
	End Select
End Sub
Sub CARD_PileHeight(Pile As Cardpile, CardHeight As Int) As Int 
	Dim temp As Int, TempCard As Card, Height As Int
	Select Case Pile.Style
		Case CARD_Deck, CARD_Aces, CARD_Horizontal, CARD_Dealt: Return CardHeight
		Case CARD_Cards
			For temp = 0 To Pile.Cards.Size - 1 
				TempCard = Pile.Cards.Get(temp)
				Height = Height + CARD_Size(Pile,temp,CardHeight, TempCard.Size)
			Next
			Return Max(Height,CardHeight)
	End Select
End Sub

Sub CARD_HandleMouse(X As Int, Y As Int, Action As Int, Width As Int, Height As Int) As Boolean'Event_Down,Event_Up,Event_Move
	Dim ClickedCard As Point, tempCard As Card, tempPile As Cardpile, oX As Int, oY As Int  
	Select Case Action 
		Case LCAR.Event_Down
			ClickedCard = CARD_FindClickedCard(X,Y, CARD_X,CARD_Y, -1,Width,Height)
			CARD_Moving= ClickedCard.X = -1
			If Not(CARD_IsWinning) Then
				SelectedPile=-1
				If Not(CARD_Moving) Then
					tempPile = PileList.get(ClickedCard.X)
					'If ClickedCard.Y>-1 Then tempCard = tempPile.Cards.Get(ClickedCard.Y)
					SelectedPile = ClickedCard.X
					tempPile.Selected = ClickedCard.Y 
				End If
			End If
			CARD_X2=X
			CARD_Y2=Y
		Case LCAR.Event_Move 
			CARD_X2=CARD_X2+X
			CARD_Y2=CARD_Y2+Y
			If CARD_Moving Then
				'CARD_oX As Int, CARD_oY As Int
				oX=CARD_X
				oY=CARD_Y
				'Log("CARD_HandleMouse: " & (CARD_X+X) & "," & (CARD_Y+Y) & " - " & CARD_Width & "," & CARD_Height & " - " & Width & "," & Height)
				CARD_X=Max(Min(CARD_X+X,0),-Max(CARD_Width,Width)+Width)
				CARD_Y=Max(Min(CARD_Y+Y,0),-Max(CARD_Height,Height)+Height)
				CARD_oX = CARD_oX + (CARD_X - oX)
				CARD_oY = CARD_oY + (CARD_Y - oY)
			Else
				ClickedCard = CARD_FindClickedCard(CARD_X2,CARD_Y2, CARD_X,CARD_Y, SelectedPile,Width,Height)
				tempPile = PileList.get(SelectedPile)
				If ClickedCard.Y <> tempPile.Selected Then 
					CARD_Moving= True
					tempPile.Selected = ClickedCard.Y
				End If
			End If
		Case LCAR.Event_Up 
			If SelectedPile>-1 And Not(CARD_Moving) And Not (CARD_IsWinning) Then CARD_HandleMouse(-1,0, LCAR.LCAR_Dpad, Width,Height)
			CARD_Moving=False
		Case LCAR.LCAR_Dpad 
			Select Case X '0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
				Case 0,1,2,3
					If SelectedPile = -1 Then 
						SelectedPile = 0
					Else 
						oX = CARD_Pile(SelectedPile).Selected
						oY = SelectedPile
						SelectedPile = CARD_SelectPileDirection(X, False)
						If SelectedPile = -1 Then SelectedPile= 0
						tempPile = CARD_Pile(SelectedPile)
						If SelectedPile <> oY Then tempPile.Selected = Max(0, Min(oX, tempPile.Cards.Size -1))
						oY=CARD_GetCardHeight
						CARD_X = Min(-tempPile.X + CARD_Width*0.5 - CardWidth,0)', CARD_MaxX) 'CARD_Width - CardWidth)
						CARD_Y = -tempPile.Y', CARD_MaxY) 'CARD_Height - oY)
					End If
				Case -1'X/enter
					If Not(CARD_GameOver) Then
						CARD_ClearUndo
						Select Case CARD_Game
							Case 0: SOL_Action 'Solitaire
							Case 1: SelectedPile = -1'high/low
							Case 2: 'GNDN 'blackjack
							Case 3: PKR_ChooseSelected(-1)'poker
							Case 4: PRS_Select
							Case 5: HRT_Select
						End Select
					End If
				Case Else: Return True 
			End Select
	End Select
	'Log(X & " " & Y & " " & Action & " " & Width & " " & Height & " " & CARD_X & " " & CARD_Y & " " & CARD_X2 & " " & CARD_Y2)
	'If ClickedCard.IsInitialized Then Log(ClickedCard)
	'If tempCard.IsInitialized Then Log(tempCard)
End Sub

Sub CARD_SelectPileDirection(Direction As Int, Aggressive As Boolean) As Int '0=up, 1=right, 2=down, 3=left
	Dim currentPile As Cardpile, tempPile As Cardpile, temp As Int, Found As Boolean, PileID As Int, Distance As Int, tempDistance As Int'CardHeight As Int = CARD_GetCardHeight, 
	If SelectedPile = -1 Then Return 0
	PileID= SelectedPile
	currentPile = PileList.Get(SelectedPile)
	
	'Log("CARD_Cards: " & CARD_Cards & " CARD_Horizontal: " & CARD_Horizontal & " CARD_Dealt: " & CARD_Dealt)
	'Log(Direction & " " & currentPile.Style & " " & currentPile.Selected)
	
	Select Case Direction' CARD_Deck, CARD_Dealt, CARD_Aces, CARD_Cards, CARD_Horizontal
		Case 0'UP
			If currentPile.Style = CARD_Cards And currentPile.Selected >0 Then
				currentPile.Selected = currentPile.Selected - 1
				Return SelectedPile
			End If
		Case 1'Right
			If (currentPile.Style = CARD_Dealt Or currentPile.Style = CARD_Horizontal) And currentPile.Selected < currentPile.Cards.Size - 1 Then
				currentPile.Selected = currentPile.Selected + 1
				Return SelectedPile
			End If
		Case 2'Down
			If currentPile.Style = CARD_Cards And currentPile.Selected < currentPile.Cards.Size - 1 Then
				currentPile.Selected = currentPile.Selected + 1
				Return SelectedPile
			End If
		Case 3'left
			If (currentPile.Style = CARD_Dealt Or currentPile.Style = CARD_Horizontal) And currentPile.Selected >0 Then
				currentPile.Selected = currentPile.Selected - 1
				Return SelectedPile
			End If
	End Select

	For temp = 0 To PileList.size - 1
		If temp <> SelectedPile Then
			tempPile = PileList.Get(temp)
			tempDistance = Trig.FindDistance(currentPile.X, currentPile.Y, tempPile.X, tempPile.Y)
			If Distance = 0 Or tempDistance < Distance Then
				Select Case Direction 
					Case 0: Found = tempPile.X = currentPile.X And tempPile.Y < currentPile.Y 'UP
					Case 1: Found = tempPile.y = currentPile.y And tempPile.x > currentPile.x 'Right
					Case 2: Found = tempPile.X = currentPile.X And tempPile.Y > currentPile.Y 'Down
					Case 3: Found = tempPile.y = currentPile.y And tempPile.x < currentPile.x 'left	
				End Select
				If Found Then 
					Distance = tempDistance
					PileID = temp 
					Found = False 
				End If
			End If
		End If
	Next
	Return PileID
End Sub

Sub CARD_FindClickedCard(X As Int, Y As Int, Xoffset As Int, Yoffset As Int, TryOnly As Int, Width As Int, Height As Int) As Point 
	Dim Pile As Cardpile, tempCard As Card, CardIndex As Int, PileIndex As Int, CardHeight As Int = CARD_GetCardHeight, temp As Int, CardSize As Int
	X=X-Xoffset
	Y=Y-Yoffset
	'If X2<0 Then X2 = Width+X2
	'If Y2<0 Then Y2 = Height+Y2
	If Not(CARD_IsWinning) Then
		For PileIndex = 0 To PileList.Size - 1
			If TryOnly = -1 Or TryOnly= PileIndex Then
				Pile = PileList.Get(PileIndex)
				 Select Case Pile.Style
					Case CARD_Deck, CARD_Aces'[]
						If LCAR.IsWithin(X,Y, Pile.X,Pile.Y , CardWidth,CardHeight,False) Then Return Trig.SetPoint(PileIndex,Pile.Cards.Size-1)
					Case CARD_Horizontal, CARD_Dealt'[][][][][][] 
						If IsWithin(Pile.Y , Y, Pile.Y +CardHeight) Or TryOnly=PileIndex Then
							temp=Pile.X
							If Pile.Cards.Size = 0 And IsWithin(Pile.X , X, Pile.X +CardWidth) Then Return Trig.SetPoint(PileIndex,-1)
							For CardIndex = 0 To Pile.Cards.Size - 1 
								tempCard = Pile.cards.Get(CardIndex)
								CardSize = CARD_Size(Pile,CardIndex,0, tempCard.Size)
								If IsWithin(temp, X, temp + CardSize) Then Return Trig.SetPoint(PileIndex,CardIndex)
								temp = temp + CardSize
							Next
						End If
					Case CARD_Cards'V
						If IsWithin(Pile.X, X, Pile.X+CardWidth) Or TryOnly=PileIndex Then
							temp=Pile.Y 
							If Pile.Cards.Size = 0 And IsWithin(Pile.Y, Y, Pile.Y +CardHeight) Then Return Trig.SetPoint(PileIndex,-1)
							For CardIndex = 0 To Pile.Cards.Size - 1 
								tempCard = Pile.cards.Get(CardIndex)
								CardSize = CARD_Size(Pile,CardIndex,CardHeight, tempCard.size)
								If IsWithin(temp, Y, temp + CardSize) Then Return Trig.SetPoint(PileIndex,CardIndex)
								temp = temp + CardSize
							Next
						End If
				End Select
			End If
		Next
	End If
	Return Trig.SetPoint(-1,-1)
End Sub

Sub CARD_VirtualMAX(Xo As Int, Yo As Int, X As Int, Y As Int, CardHeight As Int)
	CARD_Width = Max(CARD_Width,X-Xo+CardWidth)
	CARD_Height = Max(CARD_Height,Y-Yo+CardHeight)
End Sub

Sub CARD_IsMoving(tempCard As Card) As Boolean 
	Return (tempCard.Loc.currX <> tempCard.Loc.offX And tempCard.Loc.currX > -1) Or (tempCard.Loc.currY <> tempCard.Loc.offY And tempCard.Loc.currY > -1) Or tempCard.Angle <> API.IIF(tempCard.Face, 180,0)
End Sub
Sub CARD_DrawCardPile(BG As Canvas, Pile As Cardpile, X As Int, Y As Int, Alpha As Int, CardHeight As Int, EdgeColor As Int, Selected As Boolean, Xo As Int, Yo As Int, State As Boolean, Moving As Boolean, Surface As Int) As Point
	Dim temp As Int, tempCard As Card, SelectedPos As Point
	If Not(Selected) Then State = False
	'Pile.loc = Trig.SetPoint(X,Y)
	If Surface = Pile.Surface Then
		Pile.Loc.offX = X
		Pile.Loc.offY = Y
	End If
	X= Pile.Loc.CurrX
	Y= Pile.Loc.CurrY
	Select Case Pile.Style 
		Case CARD_Invisible'GNDN
		Case CARD_Deck,CARD_Aces' []
			If Pile.Cards.Size = 0 Then 
				If Not(Moving) Then CARD_DrawCard(BG,X,Y, EdgeColor,EdgeColor, Alpha,CardHeight, 1,-1)'empty spot
			Else If Pile.style = CARD_Deck Then 
				If Not(Moving) Then CARD_DrawCard(BG,X,Y, Colors.White,Colors.White, Alpha, CardHeight, CARD_Face,0)'back 
			Else 'If Pile.Style = CARD_Aces Then 
				tempCard = CARD_GetCard(Pile, -1)
				If CARD_IsMoving(tempCard) And Not(Moving) Then
					If Pile.Cards.Size > 1 Then
						CARD_DrawCardStyle(BG, X,Y, Alpha, CardHeight, CARD_GetCard(Pile, -2), EdgeColor, CARD_FillColor(tempCard,Alpha,State))
					Else
						CARD_DrawCard(BG,X,Y, EdgeColor,EdgeColor, Alpha,CardHeight, 1,-1)'empty spot
					End If
				End If
				SelectedPos = CARD_TweenCard(BG,X,Y,Xo,Yo,Alpha,CardHeight,EdgeColor,tempCard,State, Selected, True, SelectedPos, Moving)
			End If
			If Selected Then SelectedPos = Trig.SetPoint(X,Y)
			'If Selected Then CARD_DrawSelected(BG,X,Y, CardWidth, CardHeight, EdgeColor, Alpha)
			'CARD_DrawCard(BG,X,Y,EdgeColor,EdgeColor, Alpha, CardHeight, 0,-1)
			'CARD_VirtualMAX(Xo,Yo,X,Y,CardHeight)
		Case CARD_Dealt,CARD_Horizontal,CARD_Cards' [[[ ], [ ][ ][ ][ ][ ][ ][ ], V
			For temp = 0 To Pile.Cards.Size - 1   	
				tempCard = Pile.Cards.Get(temp)
				'tempCard.Loc.OffX = X
				'tempCard.Loc.OffY = Y
				'If tempCard.Loc.currX = -1 Then tempCard.Loc.currX = tempCard.Loc.OffX
				'If tempCard.Loc.currY = -1 Then tempCard.Loc.currY = tempCard.Loc.OffY
				'CARD_DrawCardStyle(BG,tempCard.Loc.currX,tempCard.Loc.currY,Alpha, CardHeight, tempCard, EdgeColor, CARD_FillColor(tempCard,Alpha,State AND Pile.Selected=temp))
				'CARD_VirtualMAX(Xo,Yo,X,Y,CardHeight)
				'If Selected AND temp = Pile.Selected Then SelectedPos = Trig.SetPoint(X,Y)
				SelectedPos = CARD_TweenCard(BG,X,Y,Xo,Yo,Alpha,CardHeight,EdgeColor,tempCard,State, Selected, Pile.Selected = temp, SelectedPos, Moving)
				If Pile.Style = CARD_Cards Then
					Y=Y+CARD_Size(Pile, temp, CardHeight, tempCard.Size)
				Else
					X=X+CARD_Size(Pile, temp, 0, tempCard.Size)
				End If 
			Next
			If Pile.Cards.Size = 0 And Selected Then SelectedPos = Trig.SetPoint(X, Y)
			
			'If SelectedPos.IsInitialized Then CARD_DrawSelected(BG, SelectedPos.X,SelectedPos.y, CardWidth,CardHeight, EdgeColor, Alpha)
		'Case CARD_Rotating
		'	If Pile.Cards.Size > 0 Then 
		'		tempCard = Pile.Cards.Get(Pile.Cards.Size -1)
		'		CARD_DrawRotatingCard(BG, X,Y, Alpha, CardHeight,tempCard,EdgeColor) 
		'	End If
	End Select
	'For Each tempCard As Card In Pile.Cards	
	Return SelectedPos
End Sub

Sub CARD_TweenCard(BG As Canvas, X As Int, Y As Int, Xo As Int, Yo As Int, Alpha As Int, CardHeight As Int, EdgeColor As Int, tempCard As Card, State As Boolean, PileIsSelected As Boolean, CardIsSelected As Boolean, SelectedPos As Point, Moving As Boolean) As Point
	If Moving = CARD_IsMoving(tempCard) Then
		tempCard.Loc.OffX = X'desired X
		tempCard.Loc.OffY = Y'desired Y
		If tempCard.Loc.currX = -1 Then tempCard.Loc.currX = tempCard.Loc.OffX'new cards have actual X/Y = -1, no tweening
		If tempCard.Loc.currY = -1 Then tempCard.Loc.currY = tempCard.Loc.OffY
		CARD_DrawCardStyle(BG,tempCard.Loc.currX,tempCard.Loc.currY,Alpha, CardHeight, tempCard, EdgeColor, CARD_FillColor(tempCard,Alpha,State And PileIsSelected))
		'CARD_VirtualMAX(Xo,Yo,X,Y,CardHeight)'set the max dimensions of the virtual screen space, Xo/Yo are the offset, to be subtracted from the X/Y of the card
		If PileIsSelected And CardIsSelected Then SelectedPos = Trig.SetPoint(X,Y)'selection cursor
	End If
	Return SelectedPos
End Sub

Sub CARD_Size(Pile As Cardpile, CardIndex As Int, CardHeight As Int, SelectedSize As Int) As Int
	Dim StartsAt As Int, EndsAt As Int, Uses As Int, Temp As Int = 2, IsLast As Boolean  'whitespace
	IsLast= CardIndex = Pile.Cards.Size -1 Or Pile.Cards.Size = 0
	Select Case Pile.Style '196 x 256
		Case CARD_Dealt' [[[ ] starts at 29
			If IsLast Then Return CardWidth
			StartsAt = 29 '0.1479591836734694 
			EndsAt = 196
			Uses = CardWidth
		Case CARD_Cards' V
			If IsLast Then Return CardHeight
			StartsAt = 58
			EndsAt = 256
			Uses = CardHeight
		Case CARD_Horizontal
			Return CardWidth+Temp
	End Select
	Temp = (EndsAt-StartsAt) * (SelectedSize*0.01) + StartsAt
	Return Temp/EndsAt * Uses
End Sub

Sub CARD_DrawCardStyle(BG As Canvas, X As Int, Y As Int, Alpha As Int, CardHeight As Int, tempCard As Card, EdgeColor As Int, FillColor As Int)
	'Dim WhiteSpace As Int = 5, Width As Int = CardWidth+ (WhiteSpace*2), Stroke As Int = 2
	Dim Rotating As Boolean = tempCard.Angle < 180 And tempCard.Angle > 0
	If Rotating Then
		CARD_DrawRotatingCard(BG,X,Y,Alpha, CardHeight, tempCard, EdgeColor, FillColor)
	Else
		If tempCard.Face Then
			CARD_DrawCard(BG,X,Y, EdgeColor, FillColor, Alpha, CardHeight, tempCard.Suite, tempCard.Value)
		Else
			CARD_DrawCard(BG,X,Y, Colors.White,Colors.White, Alpha, CardHeight, CARD_Face,0)
		End If
	End If
	
	'If Selected Then 'LCAR.DrawRoundedRectangle(BG,X-WhiteSpace,Y-WhiteSpace, Width, CardHeight+ (WhiteSpace*2),  Width*0.1, Color, Stroke)
		'CARD_DrawSelected(BG,X,Y,CardWidth,CardHeight)
		'CARD_DrawCard(BG,X,Y, EdgeColor, FillColor, Alpha, CardHeight, 0,-1)
	'End If
End Sub
Sub CARD_DrawSelected(BG As Canvas, X As Int, Y As Int,Width As Int, Height As Int,   EdgeColor As Int, Alpha As Int)
	If Not(CARD_IsWinning) Then CARD_DrawCard(BG,X,Y, EdgeColor, EdgeColor, Alpha, Height, 0,-1)
	'Dim Width2 As Int = Width*0.5
	'Width=Width+(Width2*2)
	'PDPDrawBrackets(BG, X-Width2,Y,Width*0.10, -Height)
	'PDPDrawBrackets(BG, X,Y,Width*0.1, -Height)
End Sub

Sub CARD_DrawRotatingCard(BG As Canvas, X As Int, Y As Int, Alpha As Int, CardHeight As Int, tempCard As Card, EdgeColor As Int, FillColor As Int)	'Size goes from 0 to 100
	Dim Angle = tempCard.Angle, X2 As Int = Abs(Trig.findXYAngle(0,0, CardWidth*0.25, Angle, True)), Y2 As Int = Abs(Trig.findXYAngle(0,0, CardHeight*0.5, Angle, False)), BG2 As Canvas 
	If Angle>0 And Angle <180 Then BG2 = InitUniversalBMP(CardWidth, CardHeight, LCAR.LCAR_Cards)
	If Angle = 0 Then 'back of card (normal)
		CARD_DrawCard(BG,X,Y, Colors.White,Colors.White, Alpha, CardHeight, CARD_Face,0)
	Else If Angle = 180 Then 'front of card (normal)
		CARD_DrawCard(BG,X,Y, EdgeColor, FillColor, Alpha, CardHeight, tempCard.Suite, tempCard.Value)
	Else If Angle<90 Then'back of card
		CARD_DrawCard(BG2,0,0, Colors.White,Colors.White, 255, CardHeight, CARD_Face,0)
		LCARSeffects2.DrawTrapezoid(BG, CenterPlatform, Null, X-X2, Y + CardHeight *0.5 - Y2, CardWidth+X2*2, CardWidth-X2, Y2*-2, Alpha) 
	Else If Angle>90 Then'front of card
		CARD_DrawCard(BG2,0,0, EdgeColor, FillColor, 255, CardHeight, tempCard.Suite, tempCard.Value)
		LCARSeffects2.DrawTrapezoid(BG, CenterPlatform, Null, X-X2, Y + CardHeight *0.5 - Y2, CardWidth-X2, CardWidth+X2*2, Y2*-2, Alpha) 
	End If
End Sub

Sub CARD_Col(Index As Int) As Int 
	Dim Whitespace As Int = 2 * LCAR.GetScalemode 
	If Index = 0 Then Return 0
	Return (CardWidth+Whitespace) * Index
End Sub
Sub CARD_Row(Index As Int, CardHeight As Int) As Int
	Dim Whitespace As Int = 2 * LCAR.GetScalemode 
	If Index = 0 Then Return 0
	Return (CardHeight+Whitespace) * Index
End Sub

Sub CARD_GetCard(Pile As Cardpile, Index As Int) As Card 
	Dim tempCard As Card 
	If Index <0 Then Index = Pile.Cards.Size + Index
	If Pile.Cards.Size > Index And Index>-1 Then tempCard = Pile.Cards.Get(Index)
	Return tempCard
End Sub
Sub CARD_RevealCard(Pile As Cardpile, Index As Int, State As Boolean)
	Dim tempCard As Card = CARD_GetCard(Pile, Index)
	If tempCard.IsInitialized Then tempCard.Face = State
End Sub
Sub CARD_BlinkCard(Pile As Cardpile, Index As Int, State As Boolean)
	Dim tempCard As Card = CARD_GetCard(Pile, Index)
	tempCard.Blink = State
End Sub
Sub CARD_AddCash(Value As Int) As Int 
	CARD_Cash = CARD_Cash + Value
	Return CARD_Cash
End Sub

Sub CARD_Resize(Width As Int, Height As Int)
	Dim CardHeight As Int = CARD_GetCardHeight, tempPile As Cardpile 
	Select Case CARD_Game
		Case 0'solitaire
			'move selection pile to the bottom of the screen
			tempPile = CARD_Pile(14)
			If tempPile.Surface = 0 Then tempPile.Y = Height - CardHeight
	End Select
	CARD_OldWidth = CARD_Width
End Sub

















Sub SOL_Score(srcPile As Long, destPile As Long) As Boolean 
	If srcPile = -1 Or destPile = -1 Then Return False
	Dim destPileStyle As Int = CARD_Pile(destPile).Style
	Select Case CARD_Pile(srcPile).Style
		Case CARD_Dealt
			If destPileStyle = CARD_Aces Then
				CARD_AddCash( SOL_ScorePoints(5,10))
			Else
				CARD_AddCash( SOL_ScorePoints(0,5))
			End If
		Case CARD_Aces
			CARD_AddCash( SOL_ScorePoints(-5,-10))
		Case CARD_Cards
			If destPileStyle = CARD_Aces Then CARD_AddCash( SOL_ScorePoints(5,10))
	End Select
	Return True
End Sub

Sub SOL_UnflipACard()
	If SOL_ScoringMethod = 2 Then CARD_AddCash(5)
End Sub

Sub SOL_ScorePoints(Vegas As Int, Standard As Int) As Int
	If SOL_ScoringMethod > 0 Then Return API.IIF(SOL_ScoringMethod = 1, Vegas, Standard)
End Sub

Sub SOL_CompletedRotation()
    If SOL_ScoringMethod = 2 And CARD_Cash > 0 Then CARD_AddCash(-20)
End Sub

Sub SOL_OneSecondPassed()
	If CARD_TimePassed Mod 10 = 0 And SOL_ScoringMethod = 2 And SOL_TimedGame And CARD_Cash>0 Then CARD_AddCash(-2)
End Sub

Sub SOL_Init(CardHeight As Int)
	Dim temp As Int, temp2 As Int, pile0 As Cardpile, tempPile As Cardpile 
	If CardHeight = 0 Then CardHeight = CARD_GetCardHeight
	CARD_TimePassed=0
	SOL_Rotations = SOL_MaxRotations
	If SOL_ScoringMethod = 1 Then CARD_AddCash(-52)
	CARD_DeletePiles
	
	CARD_AddPile2(0, 0, CARD_Deck, 0) '0 Deck
    CARD_AddPile2(1, 0, CARD_Dealt, 0) '1 X dealt cards
    
    CARD_AddPile2(3, 0, CARD_Aces, 0) '2 ace pile 1
    CARD_AddPile2(4, 0, CARD_Aces, 0) '3 ace pile 2
    CARD_AddPile2(5, 0, CARD_Aces, 0) '4 ace pile 3
    CARD_AddPile2(6, 0, CARD_Aces, 0) '5 ace pile 4
    
    CARD_AddPile2(0, 1, CARD_Cards, 0) '6 card pile 1
    CARD_AddPile2(1, 1, CARD_Cards, 0) '7 card pile 2
    CARD_AddPile2(2, 1, CARD_Cards, 0) '8 card pile 3
    CARD_AddPile2(3, 1, CARD_Cards, 0) '9 card pile 4
    CARD_AddPile2(4, 1, CARD_Cards, 0) '10 card pile 5
    CARD_AddPile2(5, 1, CARD_Cards, 0) '11 card pile 6
    CARD_AddPile2(6, 1, CARD_Cards, 0) '12 card pile 7
    
    CARD_AddPile2(-1, 0, CARD_Invisible, 0) '13 discard pile
	If CARD_UseMulti Then
		CARD_AddPile(0, 0, CARD_Dealt, 1) '14 Selected cards
	Else
    	CARD_AddPile(0, CARD_Height-CardHeight, CARD_Dealt, 0) '14 Selected cards
    End If
	
	pile0 = CARD_Pile(0)
    CARD_ShuffleDeck(pile0, 1, False)
    
    'Deal cards to the 7 piles
    For temp = 1 To 7
        For temp2 = 1 To temp
			tempPile = CARD_Pile(5+temp)
            CARD_MoveCard (pile0, pile0.Cards.Size - 1, tempPile, -1,-1)
			CARD_RevealCard(tempPile,-1,temp2 = temp)
        Next
    Next
    
    SOL_Deal3Cards(SOL_MaxCards, "init")
	SOL_Draw
	CARD_Locked = False
End Sub

Sub SOL_HasWon() As Boolean
    Dim temp As Int
    For temp = 2 To 5
        If CARD_Pile(temp).Cards.Size < 13 Then Return False
    Next
    Return True
End Sub

Sub SOL_RemoveCardFromStack()
	Dim pile14 As Cardpile = CARD_Pile(14), selected As Cardpile = CARD_Pile(SelectedPile)
    If pile14.Cards.Size  > 0 Then
		CARD_RevealCard(pile14, 0, True)
        CARD_MoveCard (pile14, 0, CARD_Pile(SOL_BufferPile), 14, SOL_BufferPile)
        selected.selected = selected.Cards.size - 1
        SOL_Draw
    End If
End Sub

Sub SOL_SelectLastCard()
	Dim pile14 As Cardpile = CARD_Pile(14)
    Do Until pile14.Cards.Size = 1
        SOL_RemoveCardFromStack
    Loop
End Sub

Sub SOL_PurgeStack(destPile As Int)
	Dim pile14 As Cardpile = CARD_Pile(14), dest As Cardpile 
    If destPile = -1 Then destPile = SOL_BufferPile
	dest = CARD_Pile(destPile)
	dest.Selected = dest.Cards.Size 
    Do Until pile14.Cards.Size = 0
		CARD_RevealCard(pile14, 0, True)
        CARD_MoveCard(pile14, 0, dest, 14, destPile)
    Loop
    SOL_Draw
End Sub

Sub SOL_Action()
    If PileList.Size > 0 Then
		CARD_ClearUndo
        Select Case SelectedPile
            Case 0: SOL_Deal3Cards(SOL_MaxCards, "Selected pile") 'deal 3 cards from the deck
            Case 1, 2, 3, 4, 5: SOL_SelectCard 'dealt cards and the ace pile
            Case 6, 7, 8, 9, 10, 11, 12: SOL_SelectCards 'card piles
			Case 14: SOL_PutThemBack'clicking holding pile
        End Select 'selected cards pile cant be the selected pile so ignore
        If SOL_HasWon Then 
			'If a game takes more than 30 seconds, you also receive bonus points based on the time it takes to finish. The bonus formula: 700,000 divided by total game time in seconds.
			If SOL_ScoringMethod = 2 And CARD_TimePassed Then CARD_Cash = CARD_Cash + (700000/CARD_TimePassed)
			CARD_WINGAME
		End If
    Else
        SOL_Init(0)
    End If
End Sub

Sub SOL_PutThemBack
	If SOL_BufferPile >0 Then
		SOL_Score(SelectedPile, SOL_BufferPile)
		SOL_PurgeStack(SOL_BufferPile)
	End If
End Sub

Sub SOL_Draw()
    Dim temp As Int, IsSelected As Int, title As String' = "Solitaire"
    If SOL_ScoringMethod > 0 Then title = title & "$ " & CARD_Cash & ".00"
    If SOL_TimedGame Then title = title & " " & API.GetTime(CARD_TimePassed) 'Thank you to my MCI handler code again
	If CARD_GameOver Then title = API.GetString("pdp_won")
	If SOL_HasWon Then 
		title = API.GetString("pdp_won")
		If Not(CARD_IsWinning) Then
			SelectedPile = -1
			SOL_Action
			' CARD_WINGAME
		End If
	End If
    SetElement18Text(title)
End Sub

Sub SOL_CanPlaceStack(DesiredPile As Int) As Boolean
	Dim pile14 As Cardpile = CARD_Pile(14), Selected As Cardpile = CARD_Pile(DesiredPile)
	If pile14.Cards.Size > 0 Then 'if there is a selected card
	    Select Case DesiredPile
	        Case 2, 3, 4, 5 'ace piles
	            'Can only place one card at a time
	            If pile14.Cards.Size = 1 Then
	                If CARD_Pile(DesiredPile).Cards.Size = 0 Then
	                    'is the ace pile empty and the selected card is an ace then
						Return CARD_PileCard(pile14, 0).Value = 1'Ace
	                Else
	                    If CARD_PileCard(pile14, 0).Value = CARD_PileCard(Selected, -1).Value + 1 Then
	                        'if the selected card is 1 higher than the last card on the pile, and matches the suite then
	                        Return CARD_PileCard(pile14, 0).Suite = CARD_PileCard(Selected, 0).Suite 
	                    End If
	                End If
	            End If
	        Case 6, 7, 8, 9, 10, 11, 12 'card piles
	            'can place multiple cards at a time
	            If CARD_Pile(DesiredPile).Cards.Size = 0 Then
	                'if pile is empty, and the selected card is a king then
	                Return CARD_PileCard(pile14,0).Value = 13
	            Else
	                'if the selected card is 1 lower than the last card on the pile, and is opposite in color then
	                If CARD_GetColor(CARD_PileCard(pile14,0).Suite) = Not(CARD_GetColor(CARD_PileCard(Selected, -1).Suite)) Then
	                    Return CARD_PileCard(pile14,0).Value = CARD_PileCard(Selected, -1).Value - 1 
	                End If
	            End If
	    End Select
	End If
End Sub

Sub SOL_TopCard() As Int
    Dim temp As Int, temp2 As Int, Selected As Cardpile = CARD_Pile(SelectedPile) 
    temp2 = Selected.Cards.Size - 1
    For temp = Selected.Cards.Size - 2 To Selected.Selected Step -1
        'If the card is face down, or the same color as the one on top of it, or not 1 higher in value than the one on top of it then cancel
		Dim ThisCard As Card = CARD_PileCard(Selected, temp)
		Dim NextCard As Card = CARD_PileCard(Selected, temp+1)
		'fail conditions
        If Not(CARD_PileCard(Selected, temp).Face) Then Return temp2'if it's not facing up
        If CARD_GetColor(ThisCard.Suite) = CARD_GetColor(NextCard.Suite) Then Return temp2'color is the same
        If ThisCard.Value - 1 <> NextCard.Value Then Return temp2'is not the nextcard.value-1
        temp2 = temp
    Next
    Return temp2
End Sub

 
Sub SOL_SelectCard()
	Dim pile14 As Cardpile = CARD_Pile(14), Selected As Cardpile = CARD_Pile(SelectedPile), pile13 As Cardpile = CARD_Pile(13)
	Dim pile1 As Cardpile = CARD_Pile(1)
    If pile14.Cards.Size = 0 Then 'if there are no selected cards already, select one
        SOL_BufferPile = SelectedPile 'Used to undo selection
        CARD_MoveCard(Selected, -1, pile14, SelectedPile, 14)
        If Selected.Selected >= Selected.Cards.Size Then Selected.Selected = Selected.Selected - 1
        If SelectedPile = 1 And CARD_Pile(1).Cards.Size = 0 Then 'SolitaireMoveCursor -1 'dealt cards is empty,
            If CARD_Pile(13).Cards.Size = 0 Then 'take the cursor off of it cause its empty
                SelectedPile = 0'SolitaireMoveCursor -1
            Else 'move one from discard pile back into the dealt cards
                CARD_MoveCard(pile13, -1, pile1, 13,1)
            End If
        End If
        SOL_Draw
    Else 'place them down if you can, or are clicking the undo pile
        If SelectedPile = SOL_BufferPile Then
            SOL_RemoveCardFromStack
        Else If SOL_CanPlaceStack(SelectedPile) Then
            SOL_Score(SOL_BufferPile, SelectedPile)
            SOL_PurgeStack(SelectedPile)
        End If
    End If
    If Selected.Selected = -1 Then 
		Selected.Selected = Selected.Cards.Size - 1
		SOL_Draw
	End If
End Sub

Sub SOL_ForceWin()
    Dim temp As Int
    For temp = 0 To 14
        CARD_EmptyPile(CARD_Pile(temp))
    Next
    For temp = 1 To 13
        CARD_AddCard(CARD_Pile(2), temp, 1, False)
        CARD_AddCard(CARD_Pile(3), temp, 2, False)
        CARD_AddCard(CARD_Pile(4), temp, 3, False)
        CARD_AddCard(CARD_Pile(5), temp, 4, False)
    Next
    SelectedPile = -1
    SOL_Draw
    CARD_WINGAME
End Sub

Sub SOL_SelectCards()
	Dim pile14 As Cardpile = CARD_Pile(14), Selected As Cardpile = CARD_Pile(SelectedPile), temp As Int, temp2 As Int
    If pile14.Cards.Size = 0 Then 'if there are no selected cards already,select as much as possible
        SOL_BufferPile = SelectedPile 'Used to undo selection
        'if the top card is face down, make it face up
        If Selected.Cards.Size = 0 Then Return
        If Not(CARD_PileCard(Selected, -1).Face) Then
            SOL_UnflipACard
			CARD_RevealCard(Selected, -1, True)
        Else
            temp = SOL_TopCard
            For temp2 = temp To Selected.Cards.Size - 1
                CARD_MoveCard(Selected, temp, pile14, SelectedPile, 14)
            Next
        End If
		SOL_Draw
    Else 'place them down if you can, or are clicking the undo pile
        If SelectedPile = SOL_BufferPile Then
            SOL_PurgeStack(-1)
        Else
            If SOL_CanPlaceStack(SelectedPile) Then
                SOL_Score(SOL_BufferPile, SelectedPile)
                SOL_PurgeStack(SelectedPile)
            End If
        End If
    End If
End Sub

Sub SOL_Deal3Cards(Amount As Int, Reason As String)
    Dim temp As Int, pile0 As Cardpile = CARD_Pile(0), pile1 As Cardpile = CARD_Pile(1), pile13 As Cardpile = CARD_Pile(13), pile14 As Cardpile = CARD_Pile(14), tempCard As Card
	Log("SOL_Deal3Cards: " & Reason)
    If pile14.Cards.Size > 0 Then Return 'Cards are selected
	If Amount = 0 Then Amount = SOL_MaxCards
    Do Until pile1.Cards.Size = 0
        CARD_MoveCard(pile1, 0, pile13, 1, 13)
    Loop
    If pile0.Cards.Size > 0 Then
        For temp = 1 To Max(Amount,1)
            If pile0.Cards.Size > 0 Then 
				CARD_MoveCard(pile0, -1, pile1, 0, 1)
				tempCard = pile1.Cards.Get(pile1.Cards.Size-1)' CARD_GetCard(pile1,-1)
				Log(tempCard)
				tempCard.Face = True
				tempCard.Angle = 0
				tempCard.Loc.currY = -1
			End If
        Next
    Else'Full rotation
        If SOL_MaxRotations > 0 Then SOL_Rotations = SOL_Rotations - 1
        If SOL_Rotations <= 0 And SOL_MaxRotations>0 Then
            CARD_GameOver = True
        Else
            SOL_CompletedRotation
            Do Until pile13.Cards.Size = 0
                CARD_MoveCard(pile13, -1, pile0, 13,0)
            Loop
        End If
    End If
    SOL_Draw
End Sub

Sub SOL_RevealAll
	Dim temp As Int, tempPile As Cardpile
	For temp = 6 To 12'flip last card in the 7 piles upwards
		tempPile = CARD_Pile(temp)
		CARD_RevealCard(tempPile, -1, True)
	Next
End Sub
Sub SOL_AI As Boolean 
	Dim pile14 As Cardpile = CARD_Pile(14), temp As Int, tempPile As Cardpile, DidIt As Boolean, tempCard As Card
	CARD_ClearUndo
	If pile14.Cards.Size > 0 Then'place the selected cards in the best spot
		For temp = 2 To 12
			If temp <> SOL_BufferPile And Not(DidIt) Then
				If SOL_CanPlaceStack(temp) Then
					SOL_Score(SOL_BufferPile, temp)
            		SOL_PurgeStack(temp)
					DidIt=True
				End If
			End If
		Next
		If DidIt Then 
			SOL_RevealAll
		Else
			SOL_PutThemBack
		End If
		Return DidIt
	Else
		'try one of the dealt cards
		pile14 = CARD_Pile(1)
		If pile14.Cards.Size = 0 Then SOL_Deal3Cards(SOL_MaxCards, "AI") 
		SelectedPile = 1
		SOL_SelectCard
		If SOL_AI Then Return
		SOL_AllToTop'move all cards that can go on the aces piles, to the aces piles
	End If
End Sub
Sub SOL_AllToTop
	Dim DoContinue As Boolean = True, temp As Int, Ace As Int 
	Do While DoContinue
		DoContinue = False
		SOL_RevealAll
		For temp = 6 To 12'flip last card in the 7 piles upwards
			Ace = SOL_CanGoUp(temp)
			If Ace > -1 Then
				DoContinue = True
				CARD_MoveCard( CARD_Pile(temp), -1, CARD_Pile(Ace), temp, Ace)
				'SelectedPile = temp
				'SOL_SelectCards
				'SelectedPile = Ace
				'SOL_SelectCard
			End If
		Next
	Loop
End Sub
Sub SOL_CanGoUp(PileID As Int) As Int 
	Dim tempPile As Cardpile, tempCard As Card, temp As Int, AcePile As Cardpile, AceCard As Card 
	tempPile = CARD_Pile(PileID)
	If tempPile.Cards.Size > 0 Then 
		tempCard = tempPile.Cards.Get(tempPile.Cards.Size-1)
		For temp = 2 To 5 'ace piles
			AcePile = CARD_Pile(temp)
			If AcePile.Cards.Size = 0 Then
				If tempCard.Value = 1 Then Return temp
			Else
				AceCard = AcePile.Cards.Get(AcePile.Cards.Size-1)
				If AceCard.Suite = tempCard.Suite And tempCard.Value = AceCard.Value + 1 Then Return temp
			End If
		Next
	End If
	Return -1
End Sub












Sub HL_Init(CardHeight As Int, FirstTime As Boolean)
	Dim pile0 As Cardpile, pile1 As Cardpile, pile2 As Cardpile
	If CardHeight=0 Then CardHeight = CARD_GetCardHeight	
	If FirstTime Then
		CARD_DeletePiles
		pile0 = CARD_AddPile(0, 0, CARD_Invisible,0) '0 Deck
		pile1 = CARD_AddPile2(0, 0, CARD_Aces,0) '1 face card
		pile2 = CARD_AddPile2(2, 0, CARD_Aces,0) '2 hidden card
		CARD_ShuffleDeck(pile0, 1, False)
	Else
		SelectedPile = -1
		pile0 = CARD_Pile(0)
		pile1 = CARD_Pile(1)
		pile2 = CARD_Pile(2)
		CARD_EmptyPile(pile1)
		CARD_EmptyPile(pile2)
		If pile0.Cards.Size < 2 Then CARD_ShuffleDeck(pile0, 1, True)
	End If
	CARD_CanBet=True
	CARD_MoveCard(pile0, -1, pile1, -1,-1)
	CARD_RevealCard(pile1, -1, True)
	CARD_MoveCard(pile0, -1, pile2, -1,-1)
	CARD_Untranspose(CARD_GetCard(pile1,-1))
	CARD_Untranspose(CARD_GetCard(pile2,-1))
	CARD_UpdateCash(True)
	CARD_Locked = False
End Sub
Sub HL_Guess(Higher As Boolean)
	If SelectedPile = -1 Then
		Dim pile1 As Cardpile = CARD_Pile(1), pile2 As Cardpile = CARD_Pile(2), Card1 As Card, Card2 As Card 
		SelectedPile = 2
		CARD_RevealCard(pile2, -1, True)
		pile2.Selected = pile2.Cards.Size- 1
		Card1 = CARD_GetCard(pile1, -1)
		Card2 = CARD_GetCard(pile2, -1)
		LCAR.HideToast
		If (Card2.Value > Card1.Value And Higher) Or (Card2.Value < Card1.Value And Not(Higher)) Then
			CARD_AddCash(CARD_CurrBid)
			LCAR.ToastMessage(LCAR.EmergencyBG, API.GetString("card_hilo_correct"), 3)
		Else If Card2.Value = Card1.Value Then
			LCAR.ToastMessage(LCAR.EmergencyBG, API.GetString("card_hilo_match"), 3)
		Else
			CARD_AddCash(-CARD_CurrBid)
			LCAR.ToastMessage(LCAR.EmergencyBG, API.GetString("card_hilo_incorrect"), 3)
		End If
		CARD_UpdateCash(True)
	Else
		HL_Init(0, False)
	End If
End Sub















Sub CARD_DropCard(Pile As Int) As Boolean 
	Dim thePile As Cardpile, theCard As Card, CardHeight As Int = CARD_GetCardHeight
	If Pile > -1 Then
		If Pile >= PileList.Size Then Pile = 0
		thePile = CARD_Pile(Pile)
		If thePile.Cards.Size>0 Then
			theCard=CARD_PileCard(thePile,-1)
			SelectedPile = Pile
			CARD_WinningCard = CARD_MakeCard(theCard.Value, theCard.suite, True, False)
			CARD_WinningCard.Face = theCard.Face
			CARD_WinningCard.Loc = theCard.Loc 
			'CARD_Transpose(theCard, thePile, CARD_WinningCard)
			CARD_DeleteCard(thePile,-1)
			
			CARD_WinningCard.Loc.offX = Rnd(2,10) * Max(1,LCAR.GetScalemode)' * API.IIF(API.RNDBOOL, 1,-1) 'speed + direction
			'If CARD_WinningCard.Loc.currX>0 Then CARD_WinningCard.Loc.currX = CARD_WinningCard.Loc.currX - CardWidth
			If CARD_WinningCard.Loc.currX> CARD_Width*0.5 Then CARD_WinningCard.Loc.offX = -CARD_WinningCard.Loc.offX'make it go right
			
			CARD_WinningCard.Loc.offY = 90'angle
			CARD_Factor = CARD_Height - CARD_WinningCard.Loc.currY - CardHeight
			Return True
		End If
	End If
	SelectedPile=Pile
End Sub

Sub CARD_FindNextDeck(Deck As Int) As Int
	Deck = CARD_FindFirstDeck(Deck+1)
	If Deck = -1 Then Deck = CARD_FindFirstDeck(0)
	Return Deck
End Sub
Sub CARD_FindFirstDeck(Start As Int) As Int 
	Dim temp As Int 
	For temp = Start To PileList.Size-1
		If CARD_Pile(temp).Cards.Size > 0 Then Return temp 
	Next
	Return -1
End Sub

Sub CARD_WINGAME()
    If CARD_IsWinning Then Return 'prevents multiple instances as theyd interfere
	CARD_IsWinning=True
	CARD_GameOver=True
	CARD_ClearUndo
	CARD_DropCard(CARD_FindFirstDeck(0))
End Sub


Sub CARD_GetCardY(MaxHeight As Int, Angle As Int, CardHeight As Int) As Int
    Dim temp As Int = Abs(SinD(Angle) * MaxHeight)
	Return CARD_Height-CardHeight-temp
End Sub

Sub CARD_AnimateCard As Boolean 
	Dim CardHeight As Int = CARD_GetCardHeight, Selected As Cardpile = CARD_Pile(SelectedPile), Angle As Int = CARD_WinningCard.Loc.offY +5
	Dim AngleDiff As Int = CARD_GetCardY(CARD_Factor, Angle, CardHeight)
	CARD_WinningCard.Loc.currX = CARD_WinningCard.Loc.currX - CARD_WinningCard.Loc.offX 'Move along X
	CARD_WinningCard.Loc.currY = AngleDiff'Move along Y
	
	CARD_WinningCard.Loc.currY = Min(CARD_WinningCard.Loc.currY, CARD_Height - CardHeight)
	If Angle = 185 Then
		Angle = 0
		CARD_Factor = CARD_Factor * (Rnd(50,75) * 0.01) 'randomize % of energy lost per bounce (in between 50% and 75%)
	End If
	CARD_WinningCard.Loc.offY = Angle
	
	If CARD_WinningCard.Loc.currX < -CardWidth Or CARD_WinningCard.Loc.currX > (CARD_Width +CardWidth) Then
		Return CARD_DropCard(CARD_FindNextDeck(SelectedPile))
	Else
		Return True
	End If
End Sub














Sub BLK_Init(CardHeight As Int)
	If CardHeight = 0 Then CardHeight = CARD_GetCardHeight
	CARD_DeletePiles
	BLK_HasStayed = False
	CARD_CanBet=True
	
	CARD_AddPile(0,0, CARD_Invisible, 0)'Deck
	
	CARD_AddPile(0, CardHeight, CARD_Dealt, 0)'Your hand
	CARD_AddPile(0, 0, CARD_Dealt, 0)'AI's hand
	CARD_ShuffleDeck(PileList.Get(0), 1, False)
   
	CARD_DealCards(PileList.Get(0), PileList.Get(1), 2, 0,1)
	CARD_DealCards(PileList.Get(0), PileList.Get(2), 2, 0,2)
	CARD_RevealHand(PileList.Get(1), True)
	CARD_RevealCard(PileList.Get(2), 1, True)
	
	CARD_Locked=False
	BLK_Draw
End Sub
Sub BLK_HighestOpponent(IgnorePile As Int) As Int 
	Dim Highest As Int, temp As Int 
	For temp = 1 To PileList.Size - 1 
		If temp <> IgnorePile Then
			Highest = Max(Highest, BLK_BestPileValue(PileList.get(temp)))
		End If
	Next
	Return Highest
End Sub
Sub BLK_AI(Risk As Int, DestPile As Int) As Boolean
    Dim temp As Int = BLK_BestPileValue(PileList.get(DestPile)), Enemies As Int = BLK_HighestOpponent(DestPile)
	If Risk = 0 Then Risk = BLK_Risk
    If temp <= Risk Or (temp < Enemies And Enemies < 22) Then
        CARD_DealCards (PileList.get(0), PileList.get(DestPile), 1, 0, DestPile)
		CARD_RevealCard(PileList.Get(DestPile), -1, True)
        If BLK_HasStayed Then Return BLK_AI(Risk, DestPile)
		Return True
    End If
End Sub
Sub BLK_Action(Hit As Boolean)
	Dim temp As Int
	CARD_CanBet=False
	If Hit And BLK_BestPileValue(PileList.get(1)) > 20 Then'don't allow hitting if it's 21 or higher
		Hit=False
		LCAR.PlaySound(8,False)
	End If
	BLK_HasStayed = Not(Hit)
    If Hit Then
        CARD_DealCards (PileList.get(0), PileList.get(1), 1, 0,1)
		CARD_RevealCard(PileList.Get(1), -1, True)
    End If 
    temp = BLK_CheckWinner
    If temp>-2 Then
	    If temp > 0 Then'game was won
			BLK_EndGame (API.GetString(API.IIf(temp = 1, "pdp_won", "pdp_lost")), True)
	        CARD_AddCash (API.IIf(temp = 1, CARD_CurrBid * 3, -CARD_CurrBid))
	    Else If temp<>-1 And BLK_HasStayed Then'no one acted
			BLK_EndGame (API.GetString("3d_tie"), False)
	        CARD_AddCash (CARD_CurrBid)
	    End If
    End If
    BLK_Draw
End Sub
Sub BLK_EndGame(text As String, DoBoth As Boolean)
	Dim You As Int = BLK_BestPileValue(PileList.get(1)), AI As Int = BLK_BestPileValue(PileList.get(2))
	BLK_Init(0)
	LCAR.ToastMessage(LCAR.EmergencyBG, text & " WITH: " & You & API.IIF(DoBoth," VS: " & AI, ""), 3)
End Sub
Sub BLK_CheckWinner() As Int
	Dim Yours As Int, AIs As Int, AIhasHit As Boolean = BLK_AI(0, 2)
	If Not(AIhasHit) And BLK_HasStayed Then
	    Yours = BLK_BestPileValue(PileList.get(1))
	    AIs = BLK_BestPileValue(PileList.get(2))
		
	    If Yours = AIs Then Return 0'tie
	    If Yours > 21 And AIs > 21 Then Return 0'tie
		
	    If Yours = 21 Then Return 1
	    If AIs = 21 Then Return 2
	    
	    If Yours <= 21 And Yours > AIs Then Return 1
	    If AIs <= 21 And AIs > Yours Then Return 2
	    
	    If AIs > 21 Then Return 1
	    If Yours > 21 Then Return 2
	Else 
		If AIhasHit Then Return -1'AI acted
	End If
	Return -2'no one won, game may continue
End Sub
Sub BLK_Draw()
	SetElement18Text(API.getstringvars("card_blk_score", Array As String(BLK_BestPileValue(PileList.get(1)), CARD_CurrBid, CARD_Cash)))
End Sub
Sub BLK_BasePileValue(Pile As Cardpile) As Int
    Dim temp As Int, temp2 As Int, temp3 As Int, tempcard As Card 
    For temp = 0 To Pile.Cards.Size-1
		tempcard = Pile.Cards.Get(temp)
        If tempcard.Value <> 14 Then '10, J=11, Q=12, K=13, --[(A=14)]--
            temp3 =Min(10, tempcard.Value)
            temp2 = temp2 + temp3
        End If
    Next
    Return temp2
End Sub
Sub BLK_BestPileValue(Pile As Cardpile) As Int
    Dim AceCount As Int, BaseValue As Int, temp As Int, temp3 As Int, RET As Int 
    BaseValue = BLK_BasePileValue(Pile)
    AceCount = CARD_CardCount(Pile, 14, 0, False) 'Also base ace value
    RET = BaseValue
    For temp = 0 To AceCount
        temp3 = BaseValue + AceCount + temp * 10
        If temp3 <= 21 Then RET = temp3
    Next
	Return RET
End Sub
















Sub PKR_PrintHand(Pile As Cardpile)
	Log(PKR_HandName(PKR_EvalHand(Pile)))
	Log(CARD_PrintHand(Pile))
End Sub
Sub CARD_DebugAll
	Dim temp As Int 
	For temp = 0 To PileList.Size- 1
		Log(temp & ": " & CARD_PrintHand( PileList.Get(temp)))
	Next
End Sub
Sub CARD_PrintHand(Pile As Cardpile)
	Dim tempstr As StringBuilder, temp As Int, tempCard As Card, tempstr2 As String 
	tempstr.Initialize
	For temp = 0 To Pile.Cards.Size - 1
		tempCard = Pile.Cards.Get(temp)
		tempstr2 = CARD_PrintCard(tempCard)
		If tempstr2.Length = 2 Then tempstr2 = " " & tempstr2
		tempstr.Append("[" & tempstr2 & "]")
	Next
	Return tempstr.ToString 
End Sub
Sub CARD_PrintCard(tempCard As Card) As String 
	Return CARD_ValueToString(tempCard.Value) & CARD_SuiteToString(tempCard.suite)
End Sub
Sub CARD_ValueToString(Value As Int) As String 
	Select Case Value
		Case CARD_J: 	Return "J"
		Case CARD_Q: 	Return "Q"
		Case CARD_K: 	Return "K"
		Case CARD_A,1: 	Return "A"
		Case Else: 		Return Value
	End Select
End Sub
Sub CARD_SuiteToString(Suite As Int) As String 
	Select Case Suite
		Case CARD_Heart: 	Return "♥"'FEDERATION
		Case CARD_Diamond: 	Return "♦"'KLINGON
		Case CARD_Club: 	Return "♣"'ROMULAN
		Case CARD_Spade: 	Return "♠"'BORG
	End Select
End Sub
Sub CARD_SuiteToSpecies(Suite As Int) As String 
	Select Case Suite
		Case CARD_Heart: 	Return "FEDERATION"	'♥
		Case CARD_Diamond: 	Return "KLINGON"	'♦
		Case CARD_Club: 	Return "ROMULAN"	'♣
		Case CARD_Spade: 	Return "BORG"		'♠
	End Select
End Sub
'Poker
Sub PKR_HandName(Hand As Byte) As String
    'Dim temp() As String = Array As String("Nothing", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush", "Full House", "Four of a Kind", "Straight Flush", "Royal Flush")
	Return API.GetString("card_pkr_hand" & Hand)
End Sub 
Sub PKR_EvalHand(Pile As Cardpile) As Byte
	Dim temp As Int, temp2 As Int, RetVal As ThreeDPoint
	RetVal.Initialize
	For temp = 0 To Pile.Cards.Size - 1
	    For temp2 = 0 To Pile.Cards.Size - 1
	        If temp <> temp2 Then
				RetVal = PKR_Checkforhand(	Pile, PKR_TwoPair, 			RetVal, temp, temp2)
				RetVal = PKR_Checkforhand(	Pile, PKR_FullHouse, 		RetVal, temp, temp2)
	        End If
	    Next
		RetVal = PKR_Checkforhand(			Pile, PKR_Pair, 			RetVal, temp, 0)
		RetVal = PKR_Checkforhand(			Pile, PKR_ThreeOfAKind, 	RetVal, temp, 0)
		RetVal = PKR_Checkforhand(			Pile, PKR_Flush, 			RetVal, temp, 0)
		RetVal = PKR_Checkforhand(			Pile, PKR_FourOfAKind, 		RetVal, temp, 0)
		RetVal = PKR_Checkforhand(			Pile, PKR_StraightFlush, 	RetVal, temp, 0)
		RetVal = PKR_Checkforhand(			Pile, PKR_RoyalFlush, 		RetVal, temp, 0)
		If Pile.Cards.Size = 2 Then temp = Pile.Cards.Size
	Next
	Return RetVal.X
End Sub

Sub PKR_Checkforhand(Pile As Cardpile, Hand As Byte, RetVal As ThreeDPoint, Index As Int, Index2 As Int) As ThreeDPoint
    Dim temp As Int, temp2 As Int, Percent As Int
    temp = CARD_GetCard(Pile, Index).Value 
    If Hand = PKR_TwoPair Or Hand = PKR_FullHouse Then
	    temp2 = CARD_GetCard(Pile, Index2).Value
    Else
        temp2 = CARD_GetCard(Pile, Index).Suite
    End If
    Percent = PKR_HasHand(Pile, Hand, temp, temp2)
    If Percent = 100 And RetVal.X < Hand Then
        RetVal.X = Hand
        RetVal.Y = Index
        RetVal.Z = Index2
    End If
	Return RetVal
End Sub

Sub PKR_HasHand(Pile As Cardpile, Hand As Byte, StartValue As Int, Suite As Int) As Int
	Dim temp As Int, temp2 As Int, temp3 As Int
	Select Case Hand  
	    Case PKR_Pair 'two cards, same value
	        temp2 = 2
	        temp = CARD_CardCount(Pile, StartValue, 0, False)
	    
	    Case PKR_TwoPair 'two PKR_Pairs, d'uh
	        temp2 = 4 'Suite is treated as the second card value
	        If Suite <> StartValue Then temp = CARD_CardCount(Pile, StartValue, 0, False) + CARD_CardCount(Pile, Suite, 0, False)
	    
	    Case PKR_ThreeOfAKind 'three cards, same value
	        temp2 = 3
	        temp = CARD_CardCount(Pile, StartValue, 0, False)
	        
	    Case PKR_Straight 'any five consecutive cards
	        temp2 = 5
	        If StartValue <= 10 Then
	            temp = PKR_HasCardVal(Pile, StartValue,0)
	            For temp3 = 1 To 4
	                temp = temp + PKR_HasCardVal(Pile, CARD_RelativeCard(StartValue, temp),0)
	            Next
	        End If
	                
	    Case PKR_Flush 'any five cards of the same suit
	        temp2 = 5
	        temp = CARD_CardCount(Pile, 0, Suite, False)
	        
	    Case PKR_FullHouse 'Three-of-a-Kind and a PKR_Pair
	        temp2 = 5 'Suite is treated as the second card value
	        If Suite <> StartValue Then temp = CARD_CardCount(Pile, StartValue,0, False) + CARD_CardCount(Pile, Suite,0, False)
	    
	    Case PKR_FourOfAKind 'four cards, same value
	        temp2 = 4
	        temp = CARD_CardCount(Pile, StartValue,0, False)
	    
	    Case PKR_StraightFlush 'any five consecutive cards, all same suit
	        temp2 = 5
	         If StartValue <= 10 Then
	            temp = PKR_HasCardVal(Pile, StartValue, Suite)
	            For temp3 = 1 To 4
	                temp = temp + PKR_HasCardVal(Pile, CARD_RelativeCard(StartValue, temp), Suite)
	            Next
	        End If
	        
	    Case PKR_RoyalFlush 'A-K-Q-J-10, all same suit
	        temp2 = 5
	        temp = PKR_HasCardVal(Pile, 10, Suite)
	        temp = temp + PKR_HasCardVal(Pile, CARD_J, Suite)
	        temp = temp + PKR_HasCardVal(Pile, CARD_Q, Suite)
	        temp = temp + PKR_HasCardVal(Pile, CARD_K, Suite)
	        temp = temp + PKR_HasCardVal(Pile, CARD_A, Suite)
	        
	End Select
	temp = Min(temp, Pile.Cards.Size)
	'Log( PKR_HandName(Hand) & " has " & temp & "/" & temp2 & " cards")
	If (Hand = PKR_Pair Or Hand = PKR_TwoPair) And temp < temp2 Then Return 0  'I dont want the AI trying to get PKR_Pairs
	Return Round(Min(temp,temp2) / temp2 * 100)
End Sub

Sub PKR_HasCardVal(Pile As Cardpile, Value As Int, Suite As Int) As Int
	If CARD_HasCard(Pile, Value, Suite) Then Return 1
End Sub

Sub PKR_ChooseSelected(Index As Int)
	Dim SelectedCard As Int 
	If Index = -1 Then Index = SelectedPile
    Select Case Index
        Case 0 'Deck
            CARD_TimesDealt = CARD_TimesDealt + 1
            CARD_CanBet = False
            Select Case CARD_TimesDealt
                Case 0, 1, 2: PKR_DealNonHelds
                Case 3: PKR_Endround
                Case Else: PKR_Init(0)
            End Select
        Case 3 'not held
			SelectedCard = CARD_Pile(3).Selected
            CARD_MoveCard(PileList.get(3), SelectedCard, PileList.get(4), 3, 4)
        Case 4 'held
			SelectedCard = CARD_Pile(4).Selected
            CARD_MoveCard(PileList.get(4), SelectedCard, PileList.get(3), 4, 3)
    End Select
End Sub

Sub PKR_DealNonHelds()
    Dim temp As Int, Cards As Int 
    temp = CARD_Pile(3).Cards.Size
	PKR_PrintHand(CARD_Pile(4))
    If temp > 3 Then
		Toast(API.GetString("card_pkr_min"))
    Else
		Cards= CARD_Pile(3).Cards.Size
		Toast(API.getstringvars("card_you_got", Array As String(Cards, API.IIf(Cards = 1, "", API.GetString("plural")))))
        CARD_EmptyPile (PileList.get(3))
        CARD_DealCards (PileList.get(0), PileList.get(3), temp, 0,3)
        CARD_RevealHand(PileList.get(3),True)
    End If
End Sub

Sub PKR_Endround()
    'Move non held cards to the held card pile
    Dim temp As Int
    CARD_DealCards (PileList.get(3), PileList.get(4), CARD_Pile(3).Cards.Size, 3,4)
    'DealCards CARD_PILE(1), CARD_PILE(2), CARD_PILE(3).Cards.Size
	PKR_PrintHand(CARD_Pile(4))
    temp = PKR_EvalHand(CARD_Pile(4))
    If temp > 0 Then
		Toast(API.getstringvars("card_pkr_won", Array As String(PKR_HandName(temp), CARD_CurrBid)))
        CARD_AddCash(temp * CARD_CurrBid)
    Else
        Toast( API.getstringvars("card_pkr_lost", Array As String(CARD_CurrBid)))
        CARD_AddCash(-CARD_CurrBid)
    End If
	PKR_Init(0)
End Sub

Public Sub PKR_Init(CardHeight As Int)
	Dim Deck0 As Cardpile 
	If CardHeight = 0 Then CardHeight = CARD_GetCardHeight
	CARD_CanBet= True
    SelectedPile = 0
    CARD_TimesDealt = 0
    CARD_DeletePiles
    
    Deck0 = CARD_AddPile(0, 0, CARD_Deck,0) '0) Deck
	CARD_AddPile(CardWidth, 0, CARD_Dealt,0) '1) AI's NON-held cards
	CARD_AddPile(CardWidth*3, 0, CARD_Dealt,0) '2) AI's held cards (must move up 131-pileheight)
    
    CARD_AddPile(0, CardHeight, CARD_Horizontal,0) '3) Your NON-held cards
    CARD_AddPile(0, CardHeight*2, CARD_Horizontal,0) '4) Your held cards
   
    If API.debugMode Then
		CARD_AddCards(Deck0, 2,1,52)
	Else 
		CARD_ShuffleDeck(Deck0, 1, False)
	End If
	CARD_DealCardsMulti(Deck0, 5, Array As Int(1, 3), 0)
	CARD_RevealHand(PileList.get(3), True)
  
	SetElement18Text(API.getstring("card_pkr_bet"))
	CARD_Locked=False
End Sub
Sub CARD_AddCards(Pile As Cardpile, Value As Int, Suite As Int, Quantity As Int)
	Do While Quantity>0
		CARD_AddCard(Pile,Value,Suite,True)
		Quantity=Quantity-1
	Loop
End Sub
















Sub PRS_Init(CardHeight As Int)
	Dim ClearVars As Boolean = CardHeight>0, Whitespace As Int = 2* LCAR.ScaleFactor 
	If CardHeight = 0 Then CardHeight = CARD_GetCardHeight
	CARD_DeletePiles
    If ClearVars Then PRS_Rank = PRS_President
   
    CARD_AddPile(0, 0, CARD_Deck, 0) 											'0) Deck
    CARD_AddPile(CardWidth+Whitespace, 0, CARD_Horizontal,0)  					'1) (bufferpile) current hand to be beaten
 
    CARD_AddPile( 0, CardHeight+Whitespace, CARD_Aces,0) 						'2) AI number 1
    CARD_AddPile(CardWidth+Whitespace, CardHeight+Whitespace, CARD_Aces,0) 		'3) AI number 2
    CARD_AddPile((CardWidth+Whitespace)*2, CardHeight+Whitespace, CARD_Aces,0) 	'4) AI number 3
    CARD_AddPile(0, (CardHeight+Whitespace)*3, CARD_Dealt,0) 					'5) Your hand
    CARD_AddPile(0, (CardHeight+Whitespace)*2, CARD_Dealt,0) 					'6) Your selected cards
       
	CARD_ShuffleDeck(CARD_Pile(0), 1, False)
	CARD_DealCardsMulti (CARD_Pile(0), 7, Array As Int(2, 3, 4, 5), 0)
    PRS_availrank = PRS_President
    PRS_Passes = 0
	
	Toast("YOU ARE THE " & PRS_GetRank(PRS_Rank))
    Select Case PRS_Rank
        Case PRS_President
            PRS_AIgivecard(3, 2, 5) 'AI gives 3 cards to you
            PRS_AIgivecard(1, 3, 4) 'AI gives 1 card to someone else
			Toast("card_cap_yourturn")
        Case PRS_VicePresident
            PRS_AIgivecard(1, 2, 5) 'AI gives 1 card to you
            PRS_AIgivecard(2, 3, 4) 'AI gives 2 cards to someone else
            PRS_AILeadOff(4)
        Case PRS_ViceBum
            PRS_AIgivecard(1, 5, 2) 'You give AI 1, 1 card
            PRS_AIgivecard(2, 3, 4) 'AI gives 2 cards to someone else
            PRS_AILeadOff(4)
            PRS_AI(2)
        Case PRS_Bum
            PRS_AIgivecard(2, 5, 2) 'You give AI 1, 2 cards
            PRS_AIgivecard(1, 3, 4) 'AI gives 1 card to someone else
            PRS_AILeadOff(2)
            PRS_AI(3)
            PRS_AI(4)
    End Select
	CARD_RevealHand (CARD_Pile(5), True)
	CARD_RevealHand (CARD_Pile(1), True)
	CARD_Locked=False
End Sub

Sub PRS_GetRank(theRank As Byte) As String 
	Select Case theRank
		Case PRS_Bum: 			Return API.getstring("card_cap_bum")
		Case PRS_ViceBum: 		Return API.getstring("card_cap_vicebum")
		Case PRS_VicePresident: Return API.getstring("card_cap_vicepres")
		Case PRS_President: 	Return API.getstring("card_cap_pres")
	End Select
End Sub

Sub PRS_LastHand()
 	If CARD_Pile(5).Cards.Size = 0 Then
 		PRS_Init(0)
	Else If PRS_Passes = 4 Then
        CARD_EmptyPile(CARD_Pile(1))
		Toast("card_cap_newround")
        Select Case PRS_Rank
            Case PRS_President
				Toast("card_cap_yourturn")
            Case PRS_VicePresident
                PRS_AILeadOff(4)
            Case PRS_ViceBum
                PRS_AILeadOff(4)
                PRS_AI(2)
            Case PRS_Bum
                PRS_AILeadOff(2)
                PRS_AI(3)
                PRS_AI(4)
        End Select
		PRS_Passes = 0
    End If
End Sub
Sub PRS_OK() As Boolean 
	Dim buffer As Boolean, Deck1Value As Int, Deck6Value As Int, Deck1Size As Int, Deck6Size As Int  
	If CARD_Pile(6).Cards.Size = 0 Then
		If CARD_Pile(5).Cards.Size < 14 Then
		    CARD_DealCards(CARD_Pile(0), CARD_Pile(5), 1, 0,5)
			CARD_RevealHand(CARD_Pile(5),True)
			Toast(API.GetStringVars("card_cap_dealta", Array As String(CARD_ValueToString(CARD_GetCard(CARD_Pile(5), -1).Value))))
		Else
			Toast("card_cap_mercy")
		End If
		PRS_Passes = PRS_Passes + 1
		PRS_CheckEmptyDeck
		PRS_DoAI
		PRS_LastHand
	Else
		'if the cards you put down are 2 then
        'if the deck has a 2, then you must have more 2's than it does
        'if not, then you can place it
    	'if not then you must have the same number of cards as the pile, unless its 2's
    	
		Deck1Value = PRS_Value(PRS_DeckValue(1))'POT
		Deck1Size = CARD_Pile(1).Cards.Size		'POT
		Deck6Value = PRS_Value(PRS_DeckValue(6))'USER
		Deck6Size = CARD_Pile(6).Cards.Size		'USER
		
		buffer = (Deck6Size = Deck1Size And Deck1Value < Deck6Value) Or (Deck6Value = 15 And Deck1Value = 15 And Deck6Size > Deck1Size)
	    'buffer = (Deck6Size = Deck1Size AND Deck1Value < 15) OR (Deck6Value = 15 AND Deck1Value < 15) OR (Deck6Value = 15 AND Deck1Value = 15 AND Deck6Size > Deck1Size)
		Log("1 (POT): " & Deck1Value & " (" & Deck1Size & " cards) 6 (USER): " & Deck6Value & " (" & Deck6Size & " cards) - " & buffer)
		
	    If buffer Then
	        CARD_EmptyPile(CARD_Pile(1))
			Toast(API.GetStringVars("card_cap_threw", Array As String(API.GetString("twok_you"), CARD_Pile(6).Cards.Size, CARD_ValueToString(CARD_GetCard(CARD_Pile(6),0).Value), API.IIf(CARD_Pile(6).Cards.Size = 1, "", API.GetString("plural")))))
	        CARD_DealCards(CARD_Pile(6), CARD_Pile(1), CARD_Pile(6).Cards.Size, 6,1)
	        If CARD_Pile(5).Cards.Size = 0 Then
				Toast (API.GetStringVars("card_cap_out", Array As String(PRS_GetRank(PRS_availrank))))
	            PRS_Rank = PRS_availrank
	            PRS_availrank = PRS_availrank - 1
	            PRS_Passes = 4
				Return True
	        Else
	            PRS_DoAI
	        End If
		Else
			Toast("card_cap_notgood")
	    End If
	End If
End Sub

Sub PRS_Select()
	Dim SelectedCard As Int = CARD_Pile(SelectedPile).Selected 
    Select Case SelectedPile
        Case 0 'is the deck (no cards in 6 is a pass)
            If CARD_Pile(1).Cards.Size = 0 Then 'You are leading off, you must throw down card(s)
                If CARD_Pile(6).Cards.Size > 0 Then
                    CARD_DealCards(CARD_Pile(6), CARD_Pile(1), CARD_Pile(6).Cards.Size, 6,1)				
					SetElement18Text(API.GetStringVars("card_cap_youput", Array As String(CARD_Pile(1).Cards.Size, CARD_ValueToString(PRS_DeckValue(1)), API.IIf(CARD_Pile(1).Cards.Size = 1, "", API.GetString("plural")))))
                    PRS_DoAI
                End If
            Else 'You are not leading off, check the deck
                'to see if you are passing, or that your cardcount matches, and the value is higher, or if you put a 2 down
                'if its a 2, make sure the deck doesnt have a 2, if it does you need to put more down
                'if you pass, you get another card
                PRS_OK
            End If
        Case 5 'is non held cards (your hand)
            If Not(PRS_CanMoveCard(CARD_GetCard(CARD_Pile(5), SelectedCard).Value)) Then
                CARD_MoveCards(CARD_Pile(6), 0, CARD_Pile(5), 6,5)
            End If
			CARD_MoveCard(CARD_Pile(5), SelectedCard, CARD_Pile(6), 5,6)
        Case 6 'is held cards (your buffer)
            CARD_MoveCard(CARD_Pile(6), SelectedCard, CARD_Pile(5), 6,5)
    End Select
	If PRS_Passes = 4 Then
		Toast("card_cap_passed")
		PRS_LastHand
	End If
End Sub

Sub PRS_CanMoveCard(Value As String) As Boolean
    Dim temp As Int = PRS_DeckValue(6) 'if pile is empty, or pile value matches selected card, if selected card is 2, or pile value is 2 was removed
	Return (temp = Value) Or (CARD_Pile(6).Cards.Size = 0) ' Or (tempstr = "2") or (Value = "2")
End Sub

Sub PRS_DeckValue(deck As Int) As Int
    Dim temp As Int, tempstr As Int = 0, tempPile As Cardpile = CARD_Pile(deck)
    If tempPile.Cards.Size > 0 Then
        tempstr = CARD_GetCard(tempPile,0).Value
        If tempstr = 2 Then
		    For temp = 1 To CARD_Pile(deck).Cards.Size - 1
                If CARD_GetCard(tempPile,temp).Value <> 2 Then
                    Return CARD_GetCard(tempPile,temp).Value
                End If
            Next
        End If
    End If
    Return tempstr
End Sub

Sub PRS_HighestCard(pileindex As Int) As Int
    Dim temp As Int, temp2 As Int, tempPile As Cardpile = CARD_Pile(pileindex) '2 A K Q J 10 9 8 7 6 5 4 3 (greatest to least)
    temp2 = 0
    If tempPile.Cards.Size > 0 Then
        For temp = 1 To CARD_Pile(pileindex).Cards.Size - 1
            If PRS_Value(CARD_GetCard(tempPile,temp).Value) > PRS_Value(CARD_GetCard(tempPile,temp2).Value) Then
                temp2 = temp
            End If
        Next
    End If
    Return temp2
End Sub

Sub PRS_Value(cardvalue As Int) As Int
    If cardvalue = 1 Then Return 14 'ace is second highest
    If cardvalue = 2 Then Return 15 '2 card is highest
    Return cardvalue
End Sub

'Cards=1, AIPile=2, destPile=5
Sub PRS_AIgivecard(Cards As Int, AIPile As Int, destPile As Int)
    Dim temp As Int
    For temp = 1 To Cards
        CARD_MoveCard (CARD_Pile(AIPile), PRS_HighestCard(AIPile), CARD_Pile(destPile), AIPile,destPile)
    Next
	Toast(API.GetStringVars("card_cap_gave", Array As String(PRS_PlayerName(AIPile),PRS_PlayerName(destPile),Cards,API.IIf(Cards = 1, "", API.GetString("plural")))))
End Sub

Sub PRS_PlayerName(pileindex As Int) As String
    Select Case pileindex
		Case 2, 3, 4: Return API.getstring("card_cap_ai") & (pileindex - 1)
		Case 5: Return API.getstring("twok_you")
    End Select
End Sub

Sub PRS_unvalue(Value As Int) As Int
	If Value = 14 Then Return 1
	If Value = 15 Then Return 2
	Return Value
End Sub

Sub PRS_HighestCardCount(indexpile As Int) As Int
    Dim temp As Int, temp2 As Int, temp3 As Int, temp4 As Int, tempPile As Cardpile = CARD_Pile(indexpile), cardvalue As Int
    For temp = 0 To tempPile.Cards.Size - 1
		cardvalue=CARD_GetCard(tempPile, temp).Value
        If PRS_Value( CARD_GetCard(tempPile, temp).Value) <> temp2 And cardvalue <> 2 Then 'I dont want the AI throwing a bunch of 2's down
            temp3 = CARD_CardCount(tempPile, cardvalue, 0, False)
            If temp3 > temp4 Then
                temp4 = temp3
                temp2 = temp
            End If
        End If
    Next
	Return temp2
End Sub

'AIdeck=2
Sub PRS_AILeadOff(AIDeck As Int)
    Dim temp As Int = PRS_HighestCardCount(AIDeck), tempPile As Cardpile = CARD_Pile(AIDeck), temp2 As Int, temp3 As Int, cardvalue As Int = CARD_GetCard(tempPile, temp).Value
    For temp2 = tempPile.Cards.Size - 1 To 0 Step -1
        If CARD_GetCard(tempPile, temp2).Value = cardvalue Then
            CARD_MoveCard (tempPile, temp2, CARD_Pile(1), AIDeck, 1)
            temp3 = temp3 + 1
        End If
    Next
    'Toast(PRS_PlayerName(AIDeck) & " LEAD OFF WITH " & temp3 & " " &  CARD_ValueToString(cardvalue) & API.IIf(temp3 = 1, "", "'S"))
	Toast( API.GetStringVars("card_cap_lead", Array As String(PRS_PlayerName(AIDeck), temp3,CARD_ValueToString(cardvalue), API.IIf(temp3 = 1, "", API.GetString("plural")))))
End Sub

Sub PRS_DoAI() 'true is before you, false is after you
    PRS_AI(2)
    PRS_AI(3)
    PRS_AI(4)
End Sub

Sub PRS_AI(AIDeck As Int) As Boolean
    Dim temp As Int, Value As Int, Quantity As Int, tempQuantity As Int, tempValue As Int, pileValue As Int  = PRS_Value(PRS_DeckValue(1)), tempPile As Cardpile = CARD_Pile(AIDeck)
    If tempPile.Cards.Size > 0 And PRS_Passes < 4 Then ' The AI may have won already
        'get the lowest card value with the closest quantity to the number of cards in pile 1
        If pileValue = 15 Then 'The buffer deck is all 2's
            tempQuantity = CARD_CardCount(tempPile,2,0,False)
            If tempQuantity > CARD_Pile(1).Cards.Size Then
                Quantity = tempQuantity
                Value = 15
            End If
        Else

        For temp = 0 To tempPile.Cards.Size - 1
            tempValue = PRS_Value(CARD_GetCard(CARD_Pile(AIDeck),temp).Value)
            If tempValue > pileValue And tempValue < 15 Then 'If the card is greater than the value of the buffer deck
                tempQuantity = CARD_CardCount(tempPile, CARD_GetCard(tempPile, temp).Value, 0, False)
                'If the buffer is empty,
                'or the quantity is greater than or equal to the card count in the buffer pile
                'and the value is smaller than the buffer card
                If (tempQuantity >= CARD_Pile(1).Cards.Size And ((tempValue < Value) Or (Value = 0))) Then
                    Quantity = tempQuantity
                    Value = tempValue
                End If
            End If
        Next
        End If
        PRS_AITransfer (AIDeck, PRS_unvalue(Value))
    End If
End Sub

Sub PRS_CheckEmptyDeck()
	Dim temppile As Cardpile = CARD_Pile(0)
    If temppile.Cards.Size = 0 Then
		Toast("card_cap_shuffled")
		CARD_ShuffleDeck(temppile, 1, False)
    End If
End Sub

Private Sub PRS_AITransfer(AIDeck As Int, Value As Int)
    Dim temp As Int, temp2 As Int, temp3 As String, tempPile As Cardpile = CARD_Pile(AIDeck)
    If Value = 0 Then 'AI passed/couldnt find cards to use
        CARD_DealCards (CARD_Pile(0), CARD_Pile(AIDeck), 1, 0, AIDeck)
		Toast(API.getstringvars("card_cap_passed", Array As String(PRS_PlayerName(AIDeck))))
        PRS_Passes = PRS_Passes + 1
        PRS_CheckEmptyDeck
    Else 'AI must throw down (the number of cards in the buffer pile) * (the cards matching Value)
        temp2 = CARD_Pile(1).Cards.Size
        temp3 = CARD_ValueToString(Value)
        If Value = 2 Then temp2 = temp2 + 1
        CARD_EmptyPile (CARD_Pile(1))
		Toast(API.getstringvars("card_cap_threw",Array As String(  PRS_PlayerName(AIDeck) , temp2, temp3, API.IIf(temp2 = 1, "", API.GetString("plural")))))
        For temp = tempPile.Cards.Size - 1 To 0 Step -1
            If temp2 > 0 Then
                If CARD_GetCard(tempPile, temp).Value = Value Then
                    CARD_MoveCard (CARD_Pile(AIDeck), temp, CARD_Pile(1), AIDeck,1)
                    temp2 = temp2 - 1
                End If
            End If
        Next
        CARD_RevealHand(CARD_Pile(1),True)
    End If
    If CARD_Pile(AIDeck).Cards.Size = 0 Then
		Toast(API.getstringvars("card_cap_isout", Array As String(PRS_PlayerName(AIDeck))))
        PRS_availrank = PRS_availrank - 1
        If PRS_availrank = PRS_Bum Then
			Toast ("card_cap_you_los")
            PRS_Rank = PRS_Bum
            PRS_Passes = 4
        End If
    End If
End Sub





Public Sub HRT_Init(CardHeight As Int)
	Dim ClearVars As Boolean = CardHeight>0, Whitespace As Int = 2* LCAR.ScaleFactor 
	If CardHeight = 0 Then CardHeight = CARD_GetCardHeight
	CARD_DeletePiles
	Log("HRT_Init")
    
    CARD_AddPile(0, 0, CARD_Invisible, 0) 										'0) Deck
    CARD_AddPile(0, 0, CARD_Horizontal,0)  										'1) (bufferpile) current hand to be beaten
 
    CARD_AddPile( 0, CardHeight+Whitespace, CARD_Aces,0) 						'2) AI number 1
    CARD_AddPile(CardWidth+Whitespace, CardHeight+Whitespace, CARD_Aces,0) 		'3) AI number 2
    CARD_AddPile((CardWidth+Whitespace)*2, CardHeight+Whitespace, CARD_Aces,0) 	'4) AI number 3
    CARD_AddPile(0, (CardHeight+Whitespace)*3, CARD_Dealt,0) 					'5) Your hand
    CARD_AddPile(0, (CardHeight+Whitespace)*2, CARD_Dealt,0) 					'6) Your selected cards
       
	CARD_ShuffleDeck(CARD_Pile(0), 1, False)
	CARD_DealCardsMulti (CARD_Pile(0), 13, Array As Int(2, 3, 4, 5), 0)
	CARD_RevealHand (CARD_Pile(5), True)
	CARD_Locked=False
	SOL_Rotations=0
	HRT_Unlocked=-1
	CARD_Turn=2
	If ClearVars Then
		PRS_Passes = 0
		For CardHeight = 0 To 3
			CARD_Scores(CardHeight)=  Trig.SetPoint(0,0)
		Next	
	Else
		PRS_Passes = PRS_Passes + 1
		For CardHeight = 0 To 3
			CARD_Scores(CardHeight).x= CARD_Scores(CardHeight).x+ CARD_Scores(CardHeight).y
			CARD_Scores(CardHeight).y= 0
		Next	
	End If
	HRT_CanPlay=False	
	HRT_Locked = False
	HRT_AI(False)
	'Players begin each hand by passing three cards to their opponent (except for every fourth hand, when no cards are passed).
End Sub
Sub HRT_StartRound
	Dim CardHeight As Int
	HRT_Locked=False
	HRT_CanPlay=True
	CARD_Turn = CARD_FindCard(2, CARD_Spade).X
	For CardHeight = 0 To 3
		CARD_Scores(CardHeight).x= CARD_Scores(CardHeight).x+ CARD_Scores(CardHeight).y
		CARD_Scores(CardHeight).y= 0
	Next	
End Sub
Sub HRT_AI(IsYours As Boolean)
	Dim temp As Int, NewRound As Boolean, tempPile As Cardpile, MyPile As Cardpile
	'For temp = 2 To 5
	'	If CARD_Pile(temp).Cards.Size = 0 Then NewRound = True
	'Next
	NewRound = CARD_Pile(5).Cards.Size = 0
	If NewRound Then 
		Log("HRT_AI: NEW ROUND!")
		HRT_Init(0)
		HRT_Unlocked=-1
	End If
	If Not(IsYours) Then
		If CARD_Turn > 5 Then CARD_Turn = 5
		If CARD_Turn = 5 Then
			tempPile=CARD_Pile(5)
			HRT_SortPile(tempPile)
			Log("HRT_AI: " & CARD_Turn & " " & HRT_Unlocked & " " & HRT_CanPlay & " " & tempPile.Cards.Size)
			If tempPile.Cards.Size = 16 Or Not(HRT_CanPlay) Then HRT_Unlocked =-1 
			If HRT_Unlocked= -1 Then
				Toast("card_hrt_give3")
				CARD_RevealHand (tempPile, True)
				HRT_Locked=True
			Else
				LCAR.HideToast 
				Toast("card_hrt_yourturn")
			End If
			Return
		Else 
			MyPile = CARD_Pile(CARD_Turn)
			If MyPile.Cards.Size > 0 Then
				If HRT_Unlocked = -1 And MyPile.Cards.size > 12  Then
					'block the 3 cards this AI just recieved, unless it's AI #2 which didn't get any
					If CARD_Turn> 2 Then CARD_MoveCards(MyPile, MyPile.Cards.Size - 3, CARD_Pile(1), CARD_Turn,1)
					tempPile = CARD_Pile(CARD_Turn + 1)
					CARD_MoveCard(MyPile, HRT_PassCard(CARD_Turn), tempPile, CARD_Turn, CARD_Turn + 1)
					CARD_MoveCard(MyPile, HRT_PassCard(CARD_Turn), tempPile, CARD_Turn, CARD_Turn + 1)
					CARD_MoveCard(MyPile, HRT_PassCard(CARD_Turn), tempPile, CARD_Turn, CARD_Turn + 1)
					If CARD_Turn> 2 Then CARD_MoveCards(CARD_Pile(1), 0, MyPile, 1,CARD_Turn)'put them back
				Else If HRT_CanPlay Then
					temp = HRT_PassCard(CARD_Turn)
					Log("HRT_AI: Running AI for " & CARD_Turn & " CARD: " & temp)
					HRT_PlayCard(CARD_Turn-2, temp)
				Else 
					Log("HRT_AI: CANNOT RUN AI")
				End If
			End If
			CARD_RevealHand(MyPile, False)
		End If
	End If
	
	If HRT_Locked Then Return 
	CARD_Turn = CARD_Turn + 1
	SOL_Rotations = SOL_Rotations + 1
	Log("HRT_AI: TURN: " & HRT_Unlocked & " " & CARD_Turn & " ROTATIONS: " & SOL_Rotations)
	If SOL_Rotations >3 Then 
		If HRT_Unlocked < 1 Then
			HRT_Unlocked = HRT_Unlocked + 1
			If HRT_Unlocked = 0 Then 
				temp = CARD_FindCard(2, CARD_Spade).X
				Log("Player " & temp & " has the 2 of spades")
				If temp> 0 Then CARD_Turn = temp
			End If
			Log("HRT_Unlocked: " & HRT_Unlocked & " " & CARD_Turn & "." & CARD_FindCard(2, CARD_Club).Y)
		End If
		HRT_EndTurn
		SOL_Rotations=0
	End If
	CARD_DebugAll
	HRT_AI(False)
End Sub

Sub HRT_BufferSuite As Int 
	Dim tempPile As Cardpile = CARD_Pile(1), tempCard As Card
	If tempPile.Cards.Size > 0 Then
		tempCard = tempPile.Cards.Get(0)
		Return tempCard.Suite 
	End If
End Sub
Sub HRT_PlayCard(Player As Int, CardIndex As Int)
	Dim temp As Int, tempCard As Card, tempPile As Cardpile , BufferPile As Cardpile = CARD_Pile(1)
	Player = Player+ 2
	If Player = 5 Then Player = 6
	tempPile = CARD_Pile(Player)
	If tempPile.Cards.Size = 0 Then  Return 
	tempCard = tempPile.Cards.Get(CardIndex)
	
	If HRT_Value(tempCard.Value) > HRT_Highest Then
		If HRT_BufferSuite = tempCard.Suite Then
			HRT_Highest = HRT_Value(tempCard.Value)
			HRT_Player = Player
		End If
		If HRT_Player = 6 Then HRT_Player = 5
	End If
	If tempCard.suite = CARD_Heart Then HRT_Unlocked = 2
	Log("HRT_PlayCard: Highest so far: " & HRT_Highest & " Player: " & Player & " [" & CARD_PrintCard(tempCard) & "] buffer suite: " & CARD_SuiteToString(HRT_BufferSuite) & "/" & CARD_SuiteToSpecies(HRT_BufferSuite))
	If BufferPile.Cards.Size = 4 Then CARD_EmptyPile(BufferPile)
	CARD_MoveCard(CARD_Pile(Player), CardIndex, BufferPile, Player, 1)	
	CARD_RevealHand (BufferPile, True)
	CARD_RevealHand(tempPile, HRT_Player = 5)
End Sub

Sub HRT_EndTurn
	Dim temp As Int, ShootingTheMoon As Int = -1, HandScore As Int = HRT_DeckValue(1), Player As Int = HRT_Player - 2, GameOver As Boolean, Name As String = "YOU"
	SOL_Rotations=0
	If Player < 0 Then Return
	For temp = 0 To 3'+2
		If CARD_Scores(temp).y = 26 Then ShootingTheMoon = temp
	Next
	If Player < 3 Then Name = API.GetString("card_cap_ai") & (Player+1)
	Log("HRT_EndTurn: " & Name)
	If ShootingTheMoon = -1 Then 'winner = highest card, gets to go first next round, collects POINTS FROM the buffer pile
		CARD_Scores(Player).y = CARD_Scores(Player).y + HandScore
		GameOver = CARD_Scores(Player).x + CARD_Scores(Player).y > HRT_Score
		CARD_Turn = HRT_Player
	Else'if a player has all 13 hearts + queen of spades, they get 0 points, everyone else gets 26
		For temp = 0 To 3'+2
			If ShootingTheMoon <> temp Then 
				CARD_Scores(temp).y = CARD_Scores(temp).y + 26
				If CARD_Scores(temp).X + CARD_Scores(temp).y > HRT_Score Then GameOver = True
			End If
		Next
	End If
	HRT_Highest=0
	If GameOver Then 'game ends when someone reaches the HRT_Score, winner is the lowest score
		temp = HRT_HowManyAbove(3, False) 
'		Name = "YOU CAME IN "
'		Select Case temp 
'			Case 0: Name = Name & "LAST PLACE"
'			Case 1: Name = Name & "SECOND PLACE"
'			Case 2: Name = Name & "THIRD PLACE"
'			Case 3: Name = Name & "FOURTH PLACE"
'		End Select
		
		Name = API.getstringvars("card_hrt_place", Array As String(API.GetString("card_hrt_" & temp)))
		
		temp = HRT_HowManyAbove(3,True) 
		If temp > 1 Then Name = Name & " " &  API.GetStringVars("card_hrt_tie", Array As String(temp))
		HRT_Init(0)
		HRT_Unlocked=-1
		Toast(Name)
	Else 
		If ShootingTheMoon = -1 Then
			If HandScore = 0 Then 
				HRT_DrawText(API.GetStringvars("card_hrt_nopts", Array As String(Name)))
			Else 
				HRT_DrawText(API.GetStringvars("card_hrt_somepts", Array As String(Name, HandScore, API.IIF(HandScore=1, "", API.GetString("plural")))))
			End If
		Else 
			'HRT_DrawText("EVERYONE EXCEPT " & Name & " " & (Player+1) & " GOT 26 POINTS")
			HRT_DrawText(API.GetStringvars("card_hrt_26pts", Array As String(Name)))
		End If
		CARD_EmptyPile(CARD_Pile(1))
		Log("EMPTYING BUFFER: " & HRT_Unlocked)
		'HRT_AI(False)
	End If
End Sub
Sub HRT_GetScore(Player As Int) As Int 
	Return CARD_Scores(Player).x + CARD_Scores(Player).y
End Sub
Sub HRT_DrawText(Text As String)
	Text = Text & CRLF & "AI 1: " & HRT_GetScore(0) & " AI 2: " & HRT_GetScore(1) & " AI 3: " & HRT_GetScore(2) & " YOU: " & HRT_GetScore(3) & " (TO: " & HRT_Score & ")"
	SetElement18Text(Text)
End Sub
Sub HRT_HowManyAbove(Than As Int, Equal As Boolean) As Int
	Dim Count As Int 
	For temp = 0 To CARD_Scores.Length -1 
		If Equal Then 
			If CARD_Scores(temp).x = CARD_Scores(Than).x Then Count = Count + 1
		Else If temp <> Than Then
			If CARD_Scores(temp).x > CARD_Scores(Than).x Then Count = Count + 1
		End If
	Next
	Return Count 
End Sub
Sub HRT_Value(Value As Int) As Int 
	If Value = 1 Then Return CARD_A 
	Return Value
End Sub
Sub HRT_PassCard(PileIndex As Int) As Int 
	Dim temp As Int, YourPile As Cardpile = CARD_Pile(PileIndex), tempCard As Card, Highest As Int, Index As Int = -1, theSuite As Int, AvoidLosing As Boolean, BufferPile As Cardpile = CARD_Pile(1)
	Dim BufferSuite As Int = HRT_BufferSuite, Lowest As Int 
	Log("HRT_PassCard 0: " & PileIndex & " = " & CARD_PrintHand(YourPile))
	If HRT_Unlocked = -1 Then '(pass aces or face cards if you can.)
		Index = HRT_HighestCard(YourPile, 0, True, 0) 
		Log("HRT_PassCard 1: " & Index & " " & PileIndex)
		tempCard = YourPile.Cards.Get(Index)
		If HRT_Value(tempCard.Value) < CARD_J Then 'pass smallest suite
			theSuite= HRT_SmallestSuite(PileIndex, True)
			Index = HRT_HighestCard(YourPile, theSuite,True, 0)
			Log("HRT_PassCard 2: " & Index & " " & CARD_SuiteToString(theSuite) & " " &  PileIndex)
		End If
	Else 'AI TO PLAY A CARD
		AvoidLosing = CARD_CardCount(BufferPile, 0, CARD_Heart, False) > 0 Or CARD_CardCount(BufferPile, CARD_Q, CARD_Spade, False) > 0
		If HRT_IsShootingTheMoon(PileIndex-2) Then AvoidLosing = False 
		If BufferPile.Cards.Size = 0 Then 'empty pile, this AI's turn to discard any card
			'discard 2 of spades
			Index = CARD_CardCount(YourPile, 2, CARD_Spade, True)
			Log("HRT_PassCard 3: " & Index & " " & PileIndex)
			If Index = -1 Then
				'discard lowest card of lowest deck
				Highest = HRT_SmallestSuite(PileIndex, HRT_Unlocked=2)'which suite has the least cards
				'Index = CARD_CardCount(Pile, 0, Highest, False)'how many cards it has
				Index = HRT_HighestCard(YourPile, Highest, False, 100)
				Log("HRT_PassCard 4: " & CARD_SuiteToString(Highest) & " " & Index)
			End If
		Else 
			If CARD_CardCount(YourPile, 0,  BufferSuite, False) > 0 Then'use highest card of a lower value than the buffer card of same suite
				If AvoidLosing Then 
					Highest = HRT_HighestCard(BufferPile, BufferSuite, True, 0)'highest card
					tempCard = BufferPile.Cards.Get(Highest)
					Log("HRT_PassCard 5: (HIGHEST BUFFER CARD) #" & Highest & " = [" & CARD_PrintCard(tempCard) & "]")
					Highest = HRT_Value(tempCard.Value)
					
					For temp = 0 To YourPile.Cards.Size -1 
						tempCard = YourPile.Cards.Get(temp)
						Log("HRT_PassCard 5.5 Suite: " & CARD_SuiteToString(BufferSuite) & " Lowest: " & Lowest & " Highest: " & Highest & " [" & CARD_PrintCard(tempCard) & "]")
						theSuite = HRT_Value(tempCard.Value)
						If tempCard.Suite = BufferSuite And theSuite < Highest And theSuite > Lowest Then 
							Index = temp
							Lowest= theSuite
							Log("HRT_PassCard 6: " & Lowest & " " & Index)
						End If
					Next
				End If
				If Index = -1 Then'throw out highest card
					Index = HRT_HighestCard(YourPile, BufferSuite, True, 0)
					Log("HRT_PassCard 7: " & Index)
				End If
			Else 
				If HRT_Unlocked = 2 Then'get rid of hearts or queen of spades
					Index = CARD_CardCount(YourPile, CARD_Q, CARD_Spade, True) 
					If Index = -1 Then Index = HRT_HighestCard(YourPile, CARD_Heart, True, 0)
					Log("HRT_PassCard 7: " & Index)
				End If
				If Index = -1 Then
					Lowest = HRT_SmallestSuite(PileIndex, HRT_Unlocked=2)'which suite has the least cards
					Index = HRT_HighestCard(YourPile, Lowest, False, 100)
					Log("HRT_PassCard 8: " & CARD_SuiteToString(Lowest) & " " & Index)
				End If
			End If
		End If
	End If
	If Index = -1 Then 'Index = Rnd(0, YourPile.Cards.size)'final failsafe
		Msgbox(CARD_PrintHand(YourPile), "INDEX SHOULD NEVER BE -1")
	End If
	Return Index
End Sub
Sub HRT_HighestCard(Pile As Cardpile, Suite As Int, GetHighest As Boolean, Highest As Int) As Int 
	Dim temp As Int, tempCard As Card, Index As Int = -1, Found As Boolean, Value As Int 'Pile As Cardpile = CARD_Pile(pileindex)
	If Not(GetHighest) And Highest = 0 Then Highest = 100
	For temp = 0 To Pile.Cards.Size - 1
		tempCard = Pile.Cards.Get(temp)
		Value = HRT_Value(tempCard.Value)
		If GetHighest Then 
			Found = Value > Highest
		Else
			Found = Value < Highest
		End If 
		'Log(CARD_ValueToString(tempCard.Value) & CARD_SuiteToString(tempCard.suite) & " " & GetHighest & " " & Highest & " " & Suite & " " & Found)
		If Found And (tempCard.Suite = Suite Or Suite = 0) Then 
			Highest = Value
			Index = temp
		End If
	Next
	'Log(Index & " IS THE " & API.IIF(GetHighest, "HIGHEST", "LOWEST") & " (SUITE: " & CARD_SuiteToString(Suite) & ") CARD IN: " & CARD_PrintHand(Pile))
	Return Index
End Sub
Sub HRT_SmallestSuite(PileIndex As Int, IncludeHearts As Boolean) As Int 
	Dim temp As Int, temp2 As Int, LowestSuite As Int, LowestCount As Int, tempPile As Cardpile = CARD_Pile(PileIndex)
	For temp = 1 To 4 
		If temp = CARD_Heart And IncludeHearts Or temp <> CARD_Heart Then
			temp2 = CARD_CardCount(tempPile, 0, temp, False)
			If temp2>0 And (temp2 < LowestCount Or LowestSuite = 0) Then 
				LowestCount = temp2
				LowestSuite = temp 
			End If
		End If
	Next
	Return LowestSuite
End Sub
Sub HRT_CanPlayCard(DeckIndex As Int, Suite As Int, Value As Int) As Int 
	Dim BufferPile As Cardpile = CARD_Pile(1), YourPile As Cardpile = CARD_Pile(DeckIndex), tempCard As Card, Locked As Boolean = Suite = CARD_Heart Or (Suite = CARD_Spade And Value = CARD_Q)
	If CARD_HasCard(YourPile, 2, CARD_Spade) And (Suite <> CARD_Spade Or Value <> 2) Then Return 1'if you have the 2 of spades, you must use it
	If BufferPile.Cards.Size = 0 Then'if pile 1 is empty
		If HRT_OnlyHeartsLeft(DeckIndex) Then Return 0
		If HRT_Unlocked < 2 And Locked Then Return 2 'if HRT_Unlocked < 2, cannot discard a heart or queen of spades
	Else
		tempCard = BufferPile.cards.Get(0)
		If tempCard.Suite = Suite Then Return 0
		If CARD_CardCount(YourPile, 0, tempCard.Suite, False) > 0 Then Return 3'if has a suite matching pile 1, must use it
		'if does not have a matching suite:
		If HRT_OnlyHeartsLeft(DeckIndex) Then Return 0
		If HRT_Unlocked = 0 And Locked Then Return 2 'if is first turn (HRT_Unlocked=0) cannot discard a heart, or queen of spades
	End If
	Return 0'can use any card
End Sub
Sub HRT_OnlyHeartsLeft(PileIndex As Int) As Boolean 
	Dim tempPile As Cardpile = CARD_Pile(PileIndex), temp As Int, tempCard As Card 
	For temp = 0 To tempPile.Cards.Size -1 
		tempCard = tempPile.Cards.Get(temp)
		If tempCard.Suite <> CARD_Heart Then Return False
	Next
	Return True
End Sub
Sub HRT_CardReason(tempCard As Card, PlayCard As Boolean) As Boolean 
	Dim temp As Int = HRT_CanPlayCard(5, tempCard.Suite,tempCard.Value)  
	Log("HRT_CardReason: " & temp)
	LCAR.HideToast
	Select Case temp
		Case 0: If PlayCard Then HRT_PlayCard(3,0)
		Case 1: Toast(API.getstringvars("card_hrt_mustplay2", Array As String(CARD_SuiteToString(CARD_Spade),CARD_SuiteToSpecies(CARD_Spade))))
		Case 2: Toast(API.getstringvars("card_hrt_cantplay", Array As String(CARD_SuiteToString(CARD_Spade),CARD_SuiteToSpecies(CARD_Spade))))
		Case 3: Toast(API.getstringvars("card_hrt_mustplay", Array As String(CARD_SuiteToString(HRT_BufferSuite),CARD_SuiteToSpecies(HRT_BufferSuite))))
	End Select
	Return temp = 0
End Sub
Sub HRT_Select()
	Dim SelectedCard As Int = CARD_Pile(SelectedPile).Selected, tempCard As Card
	If SelectedPile <> 0 And SelectedCard > -1 Then tempCard = CARD_Pile(SelectedPile).Cards.Get(SelectedCard)
    Select Case SelectedPile
        Case 0,1,2,3,4 'is the deck (no cards in 6 is a pass)
			If HRT_Unlocked = -1 Then
				If CARD_Pile(6).Cards.Size = 3 Then
					CARD_MoveCards( CARD_Pile(6), 0, CARD_Pile(2), 6,2)
					CARD_RevealHand(CARD_Pile(2), False)
					HRT_StartRound
				Else
					Toast("card_hrt_give3")
					Return 
				End If
			Else If CARD_Pile(6).Cards.Size>0 Then
				tempCard = CARD_Pile(6).Cards.Get(0)
				If Not(HRT_CardReason(tempCard, True)) Then Return 
			Else 
				Toast("card_hrt_nocards")
				Return
			End If
			CARD_Turn = 1
			Log("NEXT PLAYER'S TURN")
			HRT_AI(True)
        Case 5 'is non held cards (your hand)
			If HRT_Unlocked >-1 Then
				If Not(HRT_CardReason(tempCard, False)) Then Return
	            If CARD_Pile(6).Cards.Size > 0 Then CARD_MoveCards(CARD_Pile(6), 0, CARD_Pile(5), 6,5)
			Else If CARD_Pile(6).Cards.Size > 2 Then
	            CARD_MoveCard(CARD_Pile(6), 0, CARD_Pile(5), 6,5)
			End If
			CARD_MoveCard(CARD_Pile(5), SelectedCard, CARD_Pile(6), 5,6)
        Case 6 'is held cards (your buffer)
            CARD_MoveCard(CARD_Pile(6), SelectedCard, CARD_Pile(5), 6,5)
    End Select
End Sub

Sub HRT_ShootTheMoon(deck As Int) As Boolean 
	Dim tempPile As Cardpile = CARD_Pile(deck)
	Return CARD_CardCount(tempPile, 0, CARD_Heart, False) = 13 And CARD_CardCount(tempPile, CARD_Q, CARD_Spade, False) = 1
End Sub
Sub HRT_IsShootingTheMoon(IgnorePlayer As Int) As Boolean 
	For temp = 0 To 3
		If IgnorePlayer <> temp Then 
			If CARD_Scores(temp).Y > 10 Then Return True
		End If
	Next
End Sub
Sub HRT_DeckValue(deck As Int) As Int
    Dim temp As Int, tempstr As Int = 0, tempPile As Cardpile = CARD_Pile(deck), tempCard As Card 
    If tempPile.Cards.Size > 0 Then'heart = 1 point, queen of spades = 13 points
        For temp = 0 To tempPile.Cards.Size - 1 
			tempCard = tempPile.Cards.Get(temp)
			If tempCard.Suite = CARD_Heart Then tempstr = tempstr + 1
			If tempCard.suite = CARD_Spade And tempCard.Value = CARD_Q Then tempstr = tempstr + 13
		Next
    End If
    Return tempstr
End Sub
Sub HRT_SortPile(Pile As Cardpile)
	Dim temppile As Cardpile, Suite As Int, Cards As Int, Index As Int, temp As Int 
	'Log("BEFORE: " & card_printhand(Pile))
	temppile.Initialize
	temppile.Cards.Initialize
	CARD_MoveCards(Pile, 0, temppile, -1,-1)
	For Suite = 1 To 4
		Cards = CARD_CardCount(temppile, 0, Suite, False) 
		For temp = 1 To Cards
			Index = HRT_HighestCard(temppile, Suite, False,100)
			CARD_MoveCard(temppile, Index, Pile, -1,-1)
		Next
	Next
	CARD_RevealHand(Pile,True)
	'Log("AFTER: " & CARD_PrintHand(Pile))
End Sub








'Angle: 0/1=virus, 2=garbage, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
Sub DrP_FromPdP(PDPdirection As Int) As Int
	Select Case PDPdirection
		Case DrP_NoAngle:	Return 3'blank
		Case PdP_MoveLeft: 	Return 4'2
		Case PdP_MoveRight: Return 5'3
		Case PdP_MoveDown:	Return 6'1
		Case PdP_MoveUp:	Return 7'0
	End Select
	Return PDPdirection
End Sub
Sub DrP_DrawTile(BG As Canvas, X As Int, Y As Int, Size As Int, Color As Int, Angle As Int, Alpha As Int)
	Dim DrP_Tilesize As Int = 16, SrcX As Int = Angle * DrP_Tilesize
	If Angle > -1 Then 
		LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform, SrcX, (Color-1) * DrP_Tilesize, DrP_Tilesize, DrP_Tilesize, X,Y, Size,Size, Alpha,False,False)
		'BG.DrawText(x & "," & y,  X + Size*0.5, Y+Size, LCAR.lcarfont, 10, Colors.White, "CENTER")
	End If
End Sub
Sub DrP_doGameOver(ElementID As Int)
    DrP_Gameisover = True
    DrP_RaiseEvent(ElementID, DrP_LostGame,0)
	HideToast
	Toast("tri_gameover")
End Sub
Sub DrP_doWinGame(ElementID As Int)
	DrP_Clean = False 
    DrP_Gameisover = True
    DrP_RaiseEvent(ElementID, DrP_WonGame, 0)
	DrP_ClearBoard(ElementID)
	HideToast
	Toast("drp_clear")
End Sub
Sub DrP_Pause 
	Paused=Not(Paused)
	If Paused Then 
		HideToast
		Toast("pdp_paused")
	Else if Not(DrP_Gameisover) Then 
		LCAR.HideToast
	End If
	DrP_RefreshScoreboard
End Sub
Sub DrP_RaiseEvent(ElementID As Int, EventID As Int, X As Int)
	Dim Score As Int 
	LCAR.PushEvent(LCAR.DrP_Board, ElementID, EventID,0,0,0,0, LCAR.DrP_Board)
	'Other events: DrP_RotateTiles, DrP_NewFutureTile, DrP_TilesCleared
	Select Case EventID
		Case DrP_PulledTile
			Score = DrP_Score(DrP_VirusDifficulty, 1)
			If DrP_PillsPopped = 10 Then 
				DrP_PillsPopped=0
				If DrP_Delay * 0.9 > 0 Then DrP_Delay = DrP_Delay * 0.9
				DrP_Borg(ElementID)
			End If
		Case Drp_VirusKilled	
			Score = DrP_Score(DrP_VirusDifficulty, X)	
		Case DrP_WonGame
			DrP_VirusLevel=Min(20,DrP_VirusLevel+1)
	End Select
	If Score > 0 Then
		DrP_CurrentScore = Min(9999999, DrP_CurrentScore + Score)
		DrP_HighScore=Max(DrP_HighScore,DrP_CurrentScore)
	End If
	DrP_RefreshScoreboard
End Sub
Sub DrP_RandomFutureTile(ElementID As Int)
    Dim temptile As DrP_MiniTile 
	temptile.Initialize 
    temptile.Color1 = DrP_RandomTile(False)
    temptile.Color2 = DrP_RandomTile(False)
    DrP_FutureTiles.Add(temptile)
	DrP_RaiseEvent(ElementID, DrP_NewFutureTile,0)
End Sub
Sub DrP_SwitchViral() As Boolean 
    DrP_VirusState = Not(DrP_VirusState)
    DrP_Clean = False
	Return True 
End Sub
Sub Init_DrPulaski(ElementID As Int, Count As Int, MaxLevel As Int, VirusColors As Byte, Delay As Int) As Int 
	Dim temp As Int
	LCAR.HideToast
	LCAR.CurrentStyle=LCAR.DrP_Board
	DrP_Delay = Delay 
    DrP_ClearBoard(ElementID)
	DrP_Colors = VirusColors
	Count = Min(Count, DrP_GridWidth*(MaxLevel-2))
    Do Until Count = 0
        DrP_RandomizeViral(MaxLevel)
        Count = Count - 1
    Loop
	DrP_RaiseEvent(ElementID, DrP_VirusChanged, DrP_Total)
	DrP_FutureTiles.Initialize
	For temp = 1 To DrP_FutureTileCount
    	DrP_RandomFutureTile(ElementID)
	Next 
	DrP_PullTile(ElementID)
    DrP_Gameisover = False
End Sub
'Draws a blank square
Sub DrP_DrawSquare(BG As Canvas, X As Int, Y As Int, Tilesize As Int)
	LCAR.drawrect(BG,X,Y,Tilesize,Tilesize,Colors.Black, 0)
End Sub
Sub DrP_PullTile(ElementID As Int)
	Dim FutureTile As DrP_MiniTile
    If DrP_Tiles > 0 Then 
		FutureTile=DrP_FutureTiles.Get(0)
		DrP_CurrentTile.Initialize 
		DrP_CurrentTile.Color1=FutureTile.Color1 
		DrP_CurrentTile.Color2=FutureTile.Color2
	    DrP_CurrentTile.Angle = 1
	    DrP_CurrentTile.x = DrP_GridWidth * 0.5 - 1
	    DrP_CurrentTile.y = DrP_GridHeight-1
	    DrP_CurrentTile.YOffset = DrP_GhostFrames'offset will now need to be percentage based to allow for scaling
	    If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x).color <> 0 Or DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 1).color <> 0 Then DrP_doGameOver(ElementID)
	    DrP_Locked = False
	    DrP_OldVirii = DrP_Total
		DrP_FutureTiles.RemoveAt(0)
	    DrP_RandomFutureTile(ElementID)
		DrP_PillsPopped=DrP_PillsPopped+1
		DrP_RaiseEvent(ElementID, DrP_PulledTile, 0)
	End If 
End Sub
Sub DrP_RandomizeViral(MaxLevel As Int)
    Dim X As Int, Y As Int, Color As Int = DrP_RandomTile(True), temp As Boolean, Tries As Int 
    If MaxLevel = 0 Then MaxLevel = DrP_GridHeight
    Do Until temp 'DrP_Grid(Y, X).Color = 0
        X = Rnd(0, DrP_GridWidth)
        Y = Rnd(0, MaxLevel)
        If DrP_Grid(y, x).color = 0 Then temp = Not(DrP_IsAScore(x, y, Color))
		If Not(temp) Then Tries = Tries + 1
		If Tries > 10 Then 
			Color = DrP_RandomTile(False)
			Tries = 0
		End If
    Loop
    DrP_ClearTile(x, y, True, Color)
    DrP_Total = DrP_Total + 1
    DrP_VirusCounts(Color) = DrP_VirusCounts(Color) + 1
    DrP_Tiles = DrP_Tiles + 1
    DrP_Grid(y, x).Viral = True
End Sub

Sub DrP_ClearBoard(ElementID As Int) 
    Dim temp As Int, temp2 As Int
    DrP_Tiles = 0
	DrP_PillsPopped=0
	
    DrP_CurrentTile.Initialize 
    DrP_FutureTiles.Initialize 
    For temp = 0 To DrP_VirusCounts.Length- 1
        DrP_VirusCounts(temp) = 0
    Next
    DrP_Total = 0
    DrP_RaiseEvent(ElementID,  DrP_VirusChanged, DrP_Total)
    For temp = 0 To DrP_GridWidth - 1
        For temp2 = 0 To DrP_GridHeight - 1 
            DrP_ClearTile(temp, temp2, True, 0)
        Next
    Next
End Sub

'IsVirus: Chooses the least-used color to force an equal distribution
'not IsVirus: Chooses a random tile color (0 is the cursor, 1 is the placeholder)
Sub DrP_RandomTile(IsVirus As Boolean) As Int
	Dim temp As Long, Lowest As Long 
	If Not(IsVirus) Then Return Rnd(0, DrP_Colors)+1
	For temp = 1 To DrP_VirusCounts.Length - 1
		If Lowest = 0 Or DrP_VirusCounts(Lowest) > DrP_VirusCounts(temp) And temp <= DrP_Colors Then Lowest=temp
	Next
    Return Lowest
End Sub

Sub DrP_ClearTile(X As Int, Y As Int, Setit As Boolean, Color As Int) As Int
	Dim Tile As DrP_Tile
    If Color = -1 And Setit Then Color = DrP_RandomTile(False)
    If x > -1 And x < DrP_GridWidth And y > -1 And Y < DrP_GridHeight Then
	    Tile = DrP_Grid(y, x)
		Tile.Initialize
	    Tile.color = Color
	End If 
    Return Color
End Sub

Sub DrP_GetAngle(Z As Int, isViral As Boolean, Bound As Boolean, Angle As Int) As Int
    If Z > 0 Then Return 2'popping
    If isViral Then 
		If DrP_VirusState Then Return 1 Else Return 0'virus
	End If
    If Bound Then Return Angle'angle
    Return 3'single
End Sub

Sub DrP_DropAll()
    Dim temp As Int
    For temp = 0 To DrP_GridWidth - 1
        DrP_DropColumn(temp, 1)
    Next
End Sub

Sub DrP_CreateTile(x As Int, y As Int, color As Int)
    If color = 0 Then color = DrP_RandomTile(False)
    DrP_ClearTile(x, y, True, color)
    DrP_MoveTileDown(x, y)
End Sub

'Find the start of concurrent DrP_Tiles in a row
Sub DrP_StartX(x As Int, y As Int, color As Int) As Int
    Dim temp As Int
    If color = -1 Then color = DrP_Grid(y, x).color
    For temp = x - 1 To 0 Step -1
        If DrP_Grid(y, temp).color <> color Or DrP_Grid(y, temp).Ghost > 0 Then Return temp + 1
    Next
End Sub
'Find the start of concurrent DrP_Tiles in a column
Sub DrP_StartY(x As Int, y As Int, color As Int) As Int
    Dim temp As Int
    If color = -1 Then color = DrP_Grid(y, x).color
    For temp = y - 1 To 0 Step -1
        If DrP_Grid(temp, x).color <> color Or DrP_Grid(temp, x).Ghost > 0 Then Return temp + 1
    Next
End Sub
'Find the end of concurrent DrP_Tiles in a row
Sub DrP_EndX(x As Int, y As Int, color As Int) As Int
    Dim temp As Int
    If color = -1 Then color = DrP_Grid(y, x).color
    For temp = x + 1 To DrP_GridWidth -1
        If DrP_Grid(y, temp).color <> color Or DrP_Grid(y, temp).Ghost > 0 Then Return temp - 1
    Next
    Return DrP_GridWidth-1
End Sub

'Find the end of concurrent DrP_Tiles in a column
Sub DrP_EndY(x As Int, y As Int, color As Int) As Int
    Dim temp As Int
    If color = -1 Then color = DrP_Grid(y, x).color
    For temp = y + 1 To DrP_GridHeight - 1
        If DrP_Grid(temp, x).color <> color Or DrP_Grid(temp, x).Ghost > 0 Then Return  temp - 1
    Next
    Return DrP_GridHeight-1
End Sub

'Find the number of concurrent DrP_Tiles in a row
Sub DrP_CountX(x As Int, y As Int, color As Int) As Int
    Dim temp As Int, temp2 As Int
    temp = DrP_StartX(x, y, color)
    temp2 = DrP_EndX(x, y, color)
    Return temp2 - temp + 1
End Sub

'Find the number of concurrent DrP_Tiles in a column
Sub DrP_CountY(x As Int, y As Int, color As Int) As Int
    Dim temp As Int, temp2 As Int
    temp = DrP_StartY(x, y, color)
    temp2 = DrP_EndY(x, y, color)
    Return temp2 - temp + 1
End Sub

'Check if the resulting tile placement will result in a DrP_Score
Sub DrP_IsAScore(x As Int, y As Int, color As Int) As Boolean
    Return color > 0 And (DrP_CountX(x, y, color) > 3 Or DrP_CountY(x, y, color) > 3)
End Sub

'Drop a DrP_Tiles above a certain tile
Sub DrP_DropColumn(x As Int, y As Int)
    For y = y To DrP_GridHeight -1 
         If DrP_Grid(y, x).color > 0 Then DrP_MoveBoardDown(x, y)
    Next
End Sub

'Ghosts a horizontal Score
Sub DrP_GhostX(x As Int, y As Int, X2 As Int) As Int
    Dim temp As Int, Index As Int, Color As Int = DrP_Grid(y,x).Color
    For temp = x To X2
		Index = Index + 1
        DrP_GhostTile(temp, y, Index)
    Next
    Return Index 
End Sub

'Ghosts a vertical Score
Sub DrP_GhostY(X As Int, Y As Int, Y2 As Int) As Int
    Dim temp As Int, Index As Int, Color As Int = DrP_Grid(y,x).Color
    For temp = Y To Y2 
		Index = Index + 1
    	DrP_GhostTile(x, temp, Index)
    Next
    Return Index
End Sub

Sub DrP_Score(Speed As Int, ViriiKilled As Int) As Int
    Dim temp As Int
    Speed = Speed + 1
    Select Case ViriiKilled
        Case 0
        Case 1, 2: temp = ViriiKilled
        Case Else: temp = Power(2, ViriiKilled)
    End Select
    Return temp * 100 * Speed
End Sub

Sub DrP_CheckTile(ElementID As Int, x As Int, y As Int) As Int
    Dim pLeft As Int, pRight As Int, pTop As Int, pBottom As Int, color As Int, HOR As Boolean, VER As Boolean
    color = DrP_Grid(y, x).color
    'DrP_ShouldUnbind(x,y) 
	
    pLeft = DrP_StartX(x, y, color)
    pRight = DrP_EndX(x, y, color)
    HOR = pRight - pLeft + 1 > 3
        
    pTop = DrP_StartY(x, y, color)
    pBottom = DrP_EndY(x, y, color)
    VER = pBottom - pTop + 1 > 3
        
    color = 0
    If HOR Then color = DrP_GhostX(pLeft, y, pRight)
    If VER Then color = color + DrP_GhostY(x, pTop, pBottom)
	
    If color > 3 Then DrP_RaiseEvent(ElementID, DrP_TilesCleared, color)
	Return color
End Sub

Sub DrP_DecrementCurrentTile(ElementID As Int) As Boolean 
    If Not(DrP_Gameisover) Then
        If DrP_CurrentTile.Color1 > 0 And DrP_CurrentTile.Color2 > 0 Then
            DrP_CurrentTile.YOffset = DrP_CurrentTile.YOffset - 1
            If DrP_CurrentTile.YOffset = 0 Then
                If DrP_MoveCurrentTileDown Then
                    DrP_CurrentTile.y = DrP_CurrentTile.y - 1
                    DrP_CurrentTile.YOffset = DrP_GhostFrames
                Else
                    DrP_Locked = DrP_TransferTile(ElementID)
                End If
            End If
        End If
        If Not(DrP_Locked) Then
            If DrP_CurrentTile.Color1 = 0 And DrP_CurrentTile.Color2 = 0 Then DrP_CurrentTile.YOffset = 0
            If DrP_CurrentTile.YOffset = 0 Then DrP_PullTile(ElementID)
        End If
		Return True 
	End If 
End Sub

Sub DrP_MoveCurrentTileDown() As Boolean
    Dim temp As Boolean
    If DrP_CurrentTile.y > 0 Then
        temp = DrP_Grid(DrP_CurrentTile.y - 1, DrP_CurrentTile.x).color = 0
		If temp Then
			Select Case DrP_CurrentTile.Angle
				Case PdP_MoveLeft
					temp = DrP_IsntOccupied(DrP_CurrentTile.x + 1, DrP_CurrentTile.y-1, True)
				Case PdP_MoveRight
					temp = DrP_IsntOccupied(DrP_CurrentTile.x - 1, DrP_CurrentTile.y-1, True)
				Case PdP_MoveDown
					If DrP_CurrentTile.y > 1 Then temp = DrP_IsntOccupied(DrP_CurrentTile.x, DrP_CurrentTile.y - 2, True)
			End Select
		End If 
    End If
    Return temp
End Sub

Sub DrP_MoveTileDown(x As Int, y As Int) As Boolean
	Dim Tile As DrP_Tile = DrP_Grid(y, x), X2 As Int 
    If y <1 Or x <0 Then Return False 
    If DrP_Grid(y - 1, x).color > 0 Or Tile.y > 0 Then Return False 
	'Angle: 0/1=virus, 2=garbage, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
	If Tile.Bound And Tile.Angle<6 Then 
		Dim Pair As Point = DrP_GetPair(x,y)
		If DrP_ShouldUnbind(x,y, Pair.X,Pair.Y) Then
			DrP_Unbind(x,y, True, "DrP_MoveTileDown")
		End If 
	End If
	If Tile.Bound And (Tile.Angle = 4 Or Tile.Angle = 5) Then 
		If Tile.Angle = 4 Then X2 = X + 1 Else X2 = X - 1
		If DrP_IsOccupied(X2,y-1, False) Then Return False 
		DrP_Grid(y - 1, X2) = DrP_CopyTile(DrP_Grid(y, X2))
		DrP_Grid(y - 1, X2).Y = DrP_GhostFrames
		DrP_ClearTile(X2, y, False, 0)
	End If  
    DrP_Grid(y - 1, x) = DrP_CopyTile(DrP_Grid(y, x))
	DrP_Grid(y - 1, x).Y = DrP_GhostFrames
	DrP_ClearTile(x, y, False, 0)
	Return True
End Sub

Sub DrP_CopyTile(Source As DrP_Tile) As DrP_Tile
	Dim ret As DrP_Tile
	ret.Initialize
	ret.Angle= Source.Angle 
	ret.Bound= Source.Bound
	ret.bX= Source.bX 
	ret.bY= Source.bY 
	ret.Clean = False 
	ret.Color= Source.Color 
	ret.Viral= Source.Viral 
	ret.Y= Source.Y 
	ret.Ghost= Source.Ghost
	Return ret 
End Sub

Sub DrP_MoveBoardDown(x As Int, y As Int) As Boolean
	Dim Tile As DrP_Tile
    If DrP_CanMoveTileDown(x, y) Then
		Tile = DrP_Grid(y, x)
        If Tile.Bound Then
			'Angle: 0/1=virus, 2=garbage, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
            Select Case Tile.Angle
                Case 4: 	DrP_MoveTileDown(x + 1, y)'PdP_MoveLeft
                Case 5: 	DrP_MoveTileDown(x - 1, y)'PdP_MoveRight
                Case 7: 	DrP_MoveTileDown(x, y - 1)'PdP_MoveDown
                Case 6:		DrP_MoveTileDown(x, Y + 1)'PdP_MoveUp
            End Select
        End If
        DrP_MoveTileDown (x, y)
        Return True
    End If
End Sub

Sub DrP_DoAction(ElementID As Int, Index As Int) As Boolean
    Dim OldScore As Int, DidWin As Boolean 
	If DrP_Gameisover Then 
		DidWin = DrP_Total=0
		OldScore=DrP_CurrentScore
		If DidWin Then DrP_VirusLevel=DrP_VirusLevel+1
		DrP_StartGame(ElementID, True)
		If DidWin Then DrP_CurrentScore = OldScore 
		DrP_RefreshScoreboard
	Else 
		If Paused Then DrP_Pause
	    Select Case Index'with DrP_CurrentTile
	        Case PdP_MoveLeft
				If DrP_CurrentTile.x > 0 Then
		            Select Case DrP_CurrentTile.Angle
		                Case PdP_MoveLeft, PdP_MoveRight
							If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x - 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x - 1 Else Return False 
		                Case PdP_MoveUp
							If DrP_CurrentTile.y > 0 Then 
								If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x - 1).color = 0 And DrP_Grid(DrP_CurrentTile.y - 1, DrP_CurrentTile.x - 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x - 1  Else Return False 
							Else 
								Return False 
							End If 
		                Case PdP_MoveDown
							If DrP_CurrentTile.y < DrP_GridHeight Then 
								If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x - 1).color = 0 And DrP_Grid(DrP_CurrentTile.y + 1, DrP_CurrentTile.x - 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x - 1  Else Return False 
							Else 
								Return False 
							End If 
		            End Select
				Else 
					 Return False 
				End If 
	        Case PdP_MoveRight
				If DrP_CurrentTile.x < DrP_GridWidth - 1 Then
		            Select Case DrP_CurrentTile.Angle
		                Case PdP_MoveLeft
							If DrP_CurrentTile.x < DrP_GridWidth - 2 Then
								If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 2).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x + 1  Else Return False 
							Else 
								 Return False 
							End If 
		                Case PdP_MoveRight 
							If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x + 1  Else Return False 
		                Case PdP_MoveDown
							If DrP_CurrentTile.y < DrP_GridHeight Then 
								If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 1).color = 0 And DrP_Grid(DrP_CurrentTile.y + 1, DrP_CurrentTile.x + 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x + 1  Else Return False 
							Else 
								Return False 
							End If 	
		                Case PdP_MoveUp
							If DrP_CurrentTile.y > 0 Then 
								If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 1).color = 0 And DrP_Grid(DrP_CurrentTile.y - 1, DrP_CurrentTile.x + 1).color = 0 Then DrP_CurrentTile.x = DrP_CurrentTile.x + 1  Else Return False 
							Else 
								Return False 
							End If 
		            End Select
				Else 
					 Return False 
				End If
	        Case PdP_MoveDown
				If DrP_CurrentTile.YOffset > 1 Then 
	            	DrP_CurrentTile.YOffset = 1
	            	DrP_DecrementCurrentTile(ElementID)
				Else 
					Return False 
				End If 
	        Case DrP_RotateTiles
				If Not(DrP_RotateTile) Then Return False 
	    End Select
	End If 
	DrP_Clean=False 
	Return True 
End Sub

Sub DrP_RotateTile() As Boolean 
    Dim temp As Int, OldAngle As Int = DrP_CurrentTile.Angle, Success As Boolean, X As Int = DrP_CurrentTile.X, Y As Int = DrP_CurrentTile.Y
    Select Case DrP_CurrentTile.Angle
        Case PdP_MoveLeft'--
            If y < DrP_GridHeight Then
                If DrP_IsntOccupied(x, y+1, True)  Then DrP_CurrentTile.Angle = PdP_MoveDown
            Else
                DrP_CurrentTile.Angle = PdP_MoveDown
            End If
        Case PdP_MoveUp
				Log("ROTATE PdP_MoveUp")
		'		If DrP_CurrentTile.x < DrP_GridWidth-1 Then 
		'			If DrP_Grid(DrP_CurrentTile.y, DrP_CurrentTile.x + 1).color = 0 Then DrP_CurrentTile.Angle = PdP_MoveLeft
		'		End If
        'Case PdP_MoveRight
		'	Log("ROTATE PdP_MoveRight")
			'If y > 0 Then 
				'If DrP_IsntOccupied(X, y - 1, False) Then DrP_CurrentTile.Angle = PdP_MoveUp
			'End If
        Case PdP_MoveDown ': If DrP_Grid(.Y, .X - 1).Color = 0 Then .Angle = PdP_MoveRight
            'If y > 0 Then '< DrP_GridHeight Then
                If x = DrP_GridWidth-1 Then'along right edge
					If DrP_IsntOccupied(x - 1, Y, False) Then 
						x = x - 1
					Else
						Return False'can't rotate
					End If 
				End If 
				
				'Occupies X,Y and X,Y-1
				'If x < DrP_GridWidth Then 
				'	If DrP_Grid(0, X+1).Color = 0 Then Success = True 
				'End If 
				'If x > 0 Then 
				'	If DrP_Grid(0, X-1).Color = 0 Then 
				'		Success = True 
				'		X=X-1
				'	End If 
				'End If 
							
				If y < DrP_GridHeight Then
					'If Success Then 
					If DrP_IsntOccupied(X+1, Y, False) Then
						Log("SUCCESS RIGHT")
						Success=True
					else If DrP_IsntOccupied(X-1, Y, False) Then
						Log("SUCCESS LEFT")
						Success=True
						X=X-1
					Else If DrP_IsntOccupied(X,Y-1,False) And DrP_IsntOccupied(X+1,Y-1,False) Then 
						Log("SUCCESS DOWN")
						Success=True
						Y=Y-1
					Else If DrP_IsntOccupied(X,Y-1,False) And DrP_IsntOccupied(X-1,Y-1,False) Then 
						Log("SUCCESS DOWN LEFT")
						Success=True
						Y=Y-1
						X=X-1
					End If 
                    If x < DrP_GridWidth-1 And Success Then'DrP_Grid(DrP_CurrentTile.y + 1, DrP_CurrentTile.x).color = 0 And 
						DrP_CurrentTile.X=X
						DrP_CurrentTile.Y=Y
                        temp = DrP_CurrentTile.Color1
                        DrP_CurrentTile.Color1 = DrP_CurrentTile.Color2
                        DrP_CurrentTile.Color2 = temp
                        DrP_CurrentTile.Angle = PdP_MoveLeft
                    End If
                End If
            'End If
    End Select
	Log("Should rotate: " & Success)
	Return DrP_CurrentTile.Angle <> OldAngle
End Sub

Sub DrP_IsInRange(X As Int, Y As Int) As Boolean 
	Return x >-1 And y >-1 And X<DrP_GridWidth And y < DrP_GridHeight
End Sub
Sub DrP_IsOccupied(X As Int, Y As Int, OutOfRange As Boolean) As Boolean
	If Not(DrP_IsInRange(X,Y)) Then Return OutOfRange
	Return DrP_Grid(y, x).color > 0
End Sub
Sub DrP_IsntOccupied(X As Int, Y As Int, OutOfRange As Boolean) As Boolean
	If Not(DrP_IsInRange(X,Y)) Then Return OutOfRange
	Return DrP_Grid(y, x).color = 0
End Sub

Sub Incement_DrPulaski(ElementID As Int) As Boolean
    Dim temp As Int, temp2 As Int, wasPaused As Boolean, Ret As Boolean, Tile As DrP_Tile, Rumble As Boolean 
	If Not(DrP_Gameisover) And Not(Paused) Then
		If DrP_Motion Then 
			If DrP_CurrentTile.X > DrP_MotionX Then 
				DrP_DoAction(ElementID, PdP_MoveLeft)
			Else If DrP_CurrentTile.X < DrP_MotionX Then 
				DrP_DoAction(ElementID, PdP_MoveRight)
			End If 
			'If DrP_MotionY = DrP_GridHeight-1 Then DrP_DoAction(ElementID, PdP_MoveDown)
		End If 
		If DrP_LastUpdate > DateTime.Now - DrP_Delay And Not(DrP_Locked) Then Return Not(DrP_Clean)
	    wasPaused = DrP_Locked
	    DrP_Locked = False
		If Not(DrP_Clean) Then Ret = True 
	    For temp = 0 To DrP_GridWidth -1
	        For temp2 = 0 To DrP_GridHeight 
				Tile=DrP_Grid(temp2, temp)
                If Tile.y > 0 Or Tile.Ghost > 0 Then
                    Ret = True
                    DrP_Locked = True
                    If Tile.Ghost > 0 Then'Disappearing Tile
                        Tile.Ghost = Tile.Ghost - 1
                        If Tile.Ghost = 0 Then
                            'Decrease viral count by 1, and check for win game status
                            If Tile.Viral And Tile.color > 0 Then
                                DrP_VirusCounts(Tile.color) = DrP_VirusCounts(Tile.color) - 1
                                DrP_Total = DrP_Total - 1
                                DrP_RaiseEvent(ElementID,  DrP_VirusChanged, DrP_Total)
								DrP_ClearTile(temp,temp2,True,0)
                                DrP_Tiles = DrP_Tiles - 1
                                If DrP_Tiles <= 0 Then
                                    DrP_RaiseEvent(ElementID, Drp_VirusKilled, DrP_OldVirii)
                                    DrP_doWinGame(ElementID)
                                End If
                            End If
							Tile.Angle = 0
                            Tile.color = 0
                        End If
					End If 
					If Tile.y > 0 Then 'Falling Tile
                        Tile.y = Tile.y - 1
                        If Tile.y < 1 Then 
							If Not(DrP_MoveBoardDown(temp, temp2)) Then 
								Rumble=True 
								DrP_CheckTile(ElementID, temp, temp2)
							End If 
						End If 
                    End If
                End If
	        Next
	    Next
	    DrP_DropAll
		If Not(DrP_Locked) Then
			If DrP_DecrementCurrentTile(ElementID) Then Ret = True 
		    If wasPaused Then
		        If DrP_OldVirii <> DrP_Total Then
		            DrP_RaiseEvent(ElementID, Drp_VirusKilled, DrP_OldVirii - DrP_Total)
		            DrP_OldVirii = DrP_Total
		        End If
		    End If
		End If 
		DrP_LastUpdate = DateTime.Now 
	End If 
	wasPaused = API.GetHalfSecond
	If wasPaused <> DrP_VirusState Then Ret = DrP_SwitchViral 
	If Rumble Then LCAR.Rumble(1)
	Return Ret 
End Sub

Sub DrP_CalcX(BoardX As Int, TileSize As Int, TileX As Int) As Int 
	Return BoardX + (TileX * TileSize)
End Sub
Sub DrP_CalcY(BoardY As Int, TileSize As Int, BoardHeight As Int, TileY As Int, Offset As Int) As Int 
	Return BoardY + BoardHeight - ((1+TileY + (Offset * 0.1)) * TileSize)  
End Sub
Sub DrP_GetPair(X As Int, Y As Int) As Point 
	Dim Tile As DrP_Tile = DrP_Grid(y, x), Ret As Point 
	If Tile.Bound Then 
		Select Case Tile.Angle
			'Angle: 0/1=virus, 2=garbage, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
			Case 4: Ret = Trig.SetPoint(x+1,y) 
			Case 5: Ret = Trig.SetPoint(x-1,y)
			Case 6: Ret = Trig.SetPoint(x,y-1)
			Case 7: Ret = Trig.SetPoint(x,y+1)
		End Select
	End If 
	Return Ret 
End Sub
Sub DrP_DrawGridTile(BG As Canvas, X As Int, Y As Int, TileX As Int, TileY As Int, TileSize As Int, BoardHeight As Int)
    Dim Tile As DrP_Tile, Offset As Int
    Tile = DrP_Grid(TileY, TileX)
    If Not(Tile.Clean) Or Not(DrP_Clean) Then
        If Tile.y <> 0 And Tile.color = 0 Then Return
        If Tile.color > 0 Then
			'DrP_Unbind(temp,temp2,False)
			
			DrP_MoveBoardDown(X,Y)'final check
			If Tile.Bound Then 
				Select Case Tile.Angle
					'Angle: 0/1=virus, 2=garbage, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
					Case 3
						DrP_Unpair(TileX,TileY, "DrP_DrawGridTile 3")
						Tile.bound = False 
					Case 4'leftside, check right
						If DrP_ShouldUnbind(TileX,TileY, TileX+1,TileY) Then 
							DrP_Unpair(TileX,TileY, "DrP_DrawGridTile 4a")
							DrP_Unpair(TileX+1,TileY, "DrP_DrawGridTile 4b")
						End If
					Case 5'rightside, check left
						If DrP_ShouldUnbind(TileX,TileY, TileX-1,TileY) Then 
							DrP_Unpair(TileX,TileY, "DrP_DrawGridTile 5a")
							DrP_Unpair(TileX-1,TileY, "DrP_DrawGridTile 5b")
						End If
					Case 6'bottomside, check up
						If DrP_ShouldUnbind(TileX,TileY, TileX,TileY+1) Then 
							DrP_Unpair(TileX,TileY, "DrP_DrawGridTile 6a")
							DrP_Unpair(TileX,TileY+1, "DrP_DrawGridTile 6b")
						End If
					Case 7'topside, check down
						If DrP_ShouldUnbind(TileX,TileY, TileX,TileY-1) Then 
							DrP_Unpair(TileX,TileY, "DrP_DrawGridTile 7a")
							DrP_Unpair(TileX,TileY-1, "DrP_DrawGridTile 7b")
						End If
				End Select
			End If 
			X=DrP_CalcX(x, TileSize, TileX)
			Y=DrP_CalcY(Y, TileSize,BoardHeight,TileY, Tile.Y)
            DrP_DrawTile(BG, X, Y, TileSize, Tile.color, DrP_GetAngle(Tile.Ghost, Tile.Viral, Tile.Bound, DrP_FromPdP(Tile.Angle)), 255)
        End If
        Tile.Clean = True
    End If
End Sub

Sub DrP_Bind(ElementID As Int, X1 As Int, Y1 As Int, Angle1 As Int, Color1 As Int, X2 As Int, Y2 As Int, Angle2 As Int, Color2 As Int) As Boolean
	Dim temp1 As Int
	Bind2(ElementID, X1,Y1,Angle1,Color1)
	Bind2(ElementID, X2,Y2,Angle2,Color2)
	temp1 = DrP_CheckTile(ElementID, X1, Y1) + DrP_CheckTile(ElementID, X2, Y2)
    Return temp1 > 0
End Sub
Sub Bind2(ElementID As Int, X As Int, Y As Int, Angle As Int, Color As Int) 
	Dim Tile As DrP_Tile
	If x>-1 And Y>-1 And X< DrP_GridWidth And Y<DrP_GridHeight Then 
		Tile = DrP_Grid(Y, X)
		Tile.Color = Color
	    Tile.Bound = True
	    Tile.bX = X
	    Tile.bY = Y
		Tile.Ghost=0
		Tile.Clean = False 
		Tile.Viral = False 
	    Tile.Angle = Angle
	End If 
End Sub
Sub DrP_TransferTile(ElementID As Int) As Boolean
    Dim ret As Boolean
	If DrP_Tiles = 0 Then Return False
	Select Case DrP_CurrentTile.Angle	'X1					Y1						A1	Color1						X2						Y2						A2	Color2			
		Case PdP_MoveLeft
			ret = DrP_Bind(ElementID, 	DrP_CurrentTile.x, 	DrP_CurrentTile.y, 		4, 	DrP_CurrentTile.Color1, 	DrP_CurrentTile.x + 1, 	DrP_CurrentTile.y, 		5, 	DrP_CurrentTile.Color2)
		Case PdP_MoveDown
			DrP_CurrentTile.Y = Max(1,DrP_CurrentTile.Y)
			If DrP_Grid(DrP_CurrentTile.y-1,DrP_CurrentTile.x).Color > 0 Then DrP_CurrentTile.y = DrP_CurrentTile.y + 1
			ret = DrP_Bind(ElementID, 	DrP_CurrentTile.x, 	DrP_CurrentTile.y-1, 	6, 	DrP_CurrentTile.Color1, 	DrP_CurrentTile.x, 		DrP_CurrentTile.y , 	7, 	DrP_CurrentTile.Color2)'I don't get the logic of this...
		Case PdP_MoveUp: 	
			DrP_CurrentTile.Y = Max(2,DrP_CurrentTile.Y)
			If DrP_Grid(DrP_CurrentTile.y-2,DrP_CurrentTile.x).Color > 0 Then DrP_CurrentTile.y = DrP_CurrentTile.y + 1
			If DrP_Grid(DrP_CurrentTile.y-1,DrP_CurrentTile.x).Color > 0 Then DrP_CurrentTile.y = DrP_CurrentTile.y + 1
			ret = DrP_Bind(ElementID, 	DrP_CurrentTile.x, 	DrP_CurrentTile.y-1, 	7, 	DrP_CurrentTile.Color1, 	DrP_CurrentTile.x, 		DrP_CurrentTile.y - 2, 	6, 	DrP_CurrentTile.Color2)'I don't get the logic of this...
		Case PdP_MoveRight
			ret = DrP_Bind(ElementID, 	DrP_CurrentTile.x, 	DrP_CurrentTile.y, 		5, 	DrP_CurrentTile.Color1, 	DrP_CurrentTile.x - 1, 	DrP_CurrentTile.y, 		4, 	DrP_CurrentTile.Color2)
	End Select
	'PdP_MoveUp and PdP_MoveDown are checking 1 and 2 tiles below for some reason. Don't know why, but it works
	DrP_CurrentTile.Color1 = 0
	DrP_CurrentTile.Color2 = 0
	LCAR.Rumble(1)
    Return ret
End Sub
Sub DrP_DrawCurrentTile(BG As Canvas, X As Int, Y As Int, TileSize As Int, BoardHeight As Int, Alpha As Int)
   'Angle: 0/1=virus, 2=ghost, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
    Dim X2 As Int, Y2 As Int, Offset As Int, Angle As Int = DrP_CurrentTile.Angle
    If DrP_CurrentTile.Color1 > 0 And DrP_CurrentTile.Color2 > 0 Then
		X2=DrP_CurrentTile.X
		If Alpha = 255 Then 'current position
			Y2=DrP_CurrentTile.Y
			Offset=DrP_CurrentTile.YOffset
		Else 'lowest prediction
			Y2=DrP_LowestPoint 
			If Y2 = DrP_GridHeight-1 Then Return False
		End If 
		X2=DrP_CalcX(X,TileSize, X2)
		Y2=DrP_CalcY(Y,TileSize,BoardHeight, Y2, Offset)
        DrP_DrawPill(BG,X2,Y2, TileSize, DrP_GetAngle(0, False, True, DrP_FromPdP(DrP_CurrentTile.Angle)), DrP_CurrentTile.Color1, DrP_CurrentTile.Color2, Alpha)
		'DrP_DrawTile(BG, X2, Y2, TileSize, DrP_CurrentTile.Color1, DrP_GetAngle(0, False, True, DrP_FromPdP(DrP_CurrentTile.Angle)), Alpha)
        'Select Case DrP_CurrentTile.Angle
        '   Case PdP_MoveLeft:	DrP_DrawTile(BG, X2+TileSize, Y2, TileSize,DrP_CurrentTile.Color2, 5, Alpha)
        '   'Case PdP_MoveUp:	DrP_DrawTile(BG, X2, Y2+TileSize, TileSize,DrP_CurrentTile.Color2, 6, Alpha)
        '   Case PdP_MoveDown:	DrP_DrawTile(BG, X2, Y2-TileSize, TileSize,DrP_CurrentTile.Color2, 7, Alpha)
        '   Case PdP_MoveRight:	DrP_DrawTile(BG, X2-TileSize, Y2, TileSize,DrP_CurrentTile.Color2, 4, Alpha)
        'End Select
    End If
End Sub

Sub DrP_DrawPill(BG As Canvas, X As Int, Y As Int, TileSize As Int, Angle As Int, Color1 As Int, Color2 As Int, Alpha As Int)
	DrP_DrawTile(BG, X, Y, TileSize, Color1, Angle, Alpha)
    Select Case Angle
        Case 4:	DrP_DrawTile(BG, X+TileSize, Y, TileSize, Color2, 5, Alpha)'PdP_MoveLeft,
        Case 7:	DrP_DrawTile(BG, X, Y+TileSize, TileSize, Color2, 6, Alpha)'PdP_MoveUp
        Case 6:	DrP_DrawTile(BG, X, Y-TileSize, TileSize, Color2, 7, Alpha)'PdP_MoveDown
        Case 5:	DrP_DrawTile(BG, X-TileSize, Y, TileSize, Color2, 4, Alpha)'PdP_MoveRight
    End Select
End Sub

Sub DrP_DrawNext(BG As Canvas, X As Int, Y As Int, Tilesize As Int, Angle As Int, Alpha As Int, Index As Int)
	If DrP_FutureTiles.Size > Index Then 
		Dim NextTile As DrP_MiniTile = DrP_FutureTiles.Get(Index)
		DrP_DrawPill(BG, x, y, Tilesize, Angle, NextTile.Color2, NextTile.Color1, Alpha)
	End If 
End Sub

'returns the diameter of the dpad if present
Sub DrP_DrawScreen(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int) As Int 
    Dim temp As Int, temp2 As Int, Tilesize As Int = Min(Floor(Width / (DrP_GridWidth+1)),Floor(Height/DrP_GridHeight)), BoardWidth As Int = Tilesize * DrP_GridWidth, BoardHeight As Int = Tilesize * DrP_GridHeight
	Dim HalfStroke As Int = 1, BoardX As Int = X+HalfStroke, BoardY As Int = Y+Height*0.5-BoardHeight*0.5, Stroke As Int = HalfStroke * 2', tempstr As String 
	LCARSeffects2.LoadUniversalBMP(File.DirAssets, "pulaski.png", LCAR.DrP_Board)
    If Not(DrP_Clean) Then LCARSeffects4.DrawRect(BG, X,Y,Width,Height, Colors.black, 0)
	'If Width < Height Then BoardX = X + Width * 0.5 - BoardWidth * 0.5	
	LCARSeffects4.DrawRect(BG,BoardX-HalfStroke,BoardY-HalfStroke, BoardWidth + Stroke, BoardHeight + Stroke, Color, Stroke)
	LCARSeffects.MakeClipPath(BG,BoardX,BoardY,BoardWidth,BoardHeight)
    For temp = 0 To DrP_GridWidth -1 
        For temp2 = 0 To DrP_GridHeight 
            DrP_DrawGridTile(BG,BoardX,BoardY, temp, temp2, Tilesize, BoardHeight)
        Next
    Next
	DrP_DrawCurrentTile(BG,BoardX,BoardY, Tilesize, BoardHeight, 128)'destroys clip path
	LCARSeffects.MakeClipPath(BG,BoardX,BoardY,BoardWidth,BoardHeight)
	DrP_DrawCurrentTile(BG,BoardX,BoardY, Tilesize, BoardHeight, 255)
	BG.removeclip
	If Width > Height Then 'landscape
		temp= Min(150 * LCAR.GetScalemode, (Width-BoardWidth)*0.5)
		LCARSeffects.DrawDpad(BG, X+Width-temp, Y+Height-temp- LCAR.ItemHeight, temp, LCAR.LCAR_LightOrange, temp*LCARSeffects.DpadCenter*2, LCAR.LCAR_Orange, 2, 255 , False, -1)
		temp2=BoardWidth+Stroke
		HalfStroke = LCAR.ItemHeight*2
		If Not(DrP_Clean) Then 
			If Width - temp2 - temp*2 - HalfStroke > Height - temp*2 - HalfStroke Then 
				DrP_DrawScoreboard(BG,BoardX+temp2+LCAR.ItemHeight, BoardY, Width-temp2-temp*2- HalfStroke, BoardHeight)
			Else 
				DrP_DrawScoreboard(BG,BoardX+temp2, BoardY, Width-temp2, Height-temp*2-HalfStroke)
			End If 
		End If 
		DrP_DpadRadius = temp 
	Else if DrP_FutureTiles.IsInitialized Then 'portrait
		temp2=BoardY
		For temp = 0 To DrP_FutureTiles.Size - 1
			DrP_DrawNext(BG, BoardX+BoardWidth+Stroke, temp2, Tilesize, 7, 255, temp)
			temp2= temp2 + Tilesize*2 + Stroke 
		Next 
		DrP_DpadRadius = 0
	End If
	
	'If DrP_Gameisover Then tempstr = "GAMEOVER "
	'If DrP_Locked Then tempstr = tempstr & "LOCKED "
	'If DrP_Total = 0 Then tempstr = tempstr & "WON "
	'If Paused Then tempstr = tempstr & "PAUSED "
	'If tempstr.length > 0 Then BG.DrawText(tempstr, BoardX + BoardWidth * 0.5, BoardY + BoardHeight * 0.5, LCAR.lcarfont, LCAR.Fontsize, Color, "CENTER")
	
	DrP_LastTilesize=Tilesize
End Sub


Sub DrP_VirusDifficultyString(Difficulty As Byte) As Object 
	Dim Levels As List
	'Levels.Initialize2(Array As String("LOW", "MEDIUM", "HIGH", "EXTREME"))
	Levels.Initialize2(API.getstrings("drp_diff", 0))
	If Difficulty < 0 Then Return Levels 
	Return Levels.get(Difficulty)
End Sub

Sub DrP_StartGame(ElementID As Int, NewGame As Boolean) As Int 
	Dim Delay As Int, VirusCount As Int = 3, OldScore As Int = DrP_CurrentScore
	If NewGame Then 
		DrP_CurrentScore=0
		Select Case DrP_VirusDifficulty
			Case 0: Delay=700
			Case 1: Delay=600'1185
			Case 2: Delay=500'2370
			Case 3
				Delay=500	
				VirusCount=4
		End Select
		Init_DrPulaski(ElementID, (DrP_VirusLevel + 2) * 2, 12, VirusCount, Delay)
	End If 
	LCAR.ForceShow(ElementID, True)
	Paused=False 
	DrP_RefreshScoreboard
	Return OldScore
End Sub

Sub DrP_RefreshScoreboard
	Dim tempstr As StringBuilder, temp As Long, Total As Int, ColorsRemaining As Int, VirusColors() As String = Array As String("", "drp_red", "drp_blue", "drp_yellow", "drp_green")
	tempstr.Initialize 
	tempstr.append(API.getstring("pdp_score") & ": " & API.PadtoLength(DrP_CurrentScore, True, 10, "0"))
	If DrP_HighScore = DrP_CurrentScore And DrP_HighScore>0 Then 
		tempstr.append(", " & API.getstring("drp_highest"))
	Else 
		tempstr.append(", " &  API.getstringvars("drp_highscore", Array As String(API.PadtoLength(DrP_HighScore, True, 10, "0"))))
	End If
	tempstr.append(CRLF)
	If Paused Then 
		tempstr.Append("pdp_paused")
	else if DrP_Gameisover Then 
		HideToast
		If DrP_Total = 0 Then 
			tempstr.Append(API.GetString("drp_win"))
			Toast("pdp_won")
		Else 
			tempstr.Append(API.GetString("drp_lose"))
			Toast("tri_gameover")
		End If 
	Else 
		For temp = 1 To DrP_VirusCounts.Length - 1
			If DrP_VirusCounts(temp)>0 Then 
				If ColorsRemaining > 0 Then tempstr.Append(", ")
				tempstr.Append(API.GetString(VirusColors(temp)) & ": " & DrP_VirusCounts(temp))
				Total=Total+DrP_VirusCounts(temp)
				ColorsRemaining=ColorsRemaining+1
			End If
		Next
		If ColorsRemaining>1 Then tempstr.Append(", " & API.GetString("drp_total") & ": " & Total)
	End If
	SetElement18Text(tempstr.tostring)
End Sub

Sub DrP_HandleMouse(ElementID As Int, X As Int, Y As Int, Action As Int, Width As Int, Height As Int)
	Dim didMove As Boolean, dpadX As Int, dpadY As Int
	If Not(LCAR.IsElementVisible(ElementID)) Then Return 
	If Action = LCAR.Event_Move Or Action = LCAR.Event_Down And DrP_DpadRadius > 0 Then 
		dpadX = Width - DrP_DpadRadius*2
		dpadY = Height - DrP_DpadRadius*2 - LCAR.ItemHeight
	End If 
	Select Case Action
		Case LCAR.LCAR_Dpad '0=up, 1=right, 2=down, 3=left, -1=X, 4=[], 5=Tri, 6=Ls, 7=Rs, 8=Start
			Select Case X
				Case 0, -1,4,5,6,7:DrP_DoAction(ElementID, DrP_RotateTiles)
				Case 1: DrP_DoAction(ElementID,PdP_MoveRight)
				Case 3: DrP_DoAction(ElementID,PdP_MoveLeft)
				Case 2: DrP_DoAction(ElementID,PdP_MoveDown)
				Case 8: Paused=Not(Paused)
			End Select
		Case LCAR.LCAR_SensorChanged
			'X: -100 (leftside-down) to +100 (leftside-up)	0 is flat
			'Y: -100 (topside-down)  to +100 (topside-up)   0 is flat
			DrP_MotionX = LCAR.ScaleValue(X, -50,50,0, DrP_GridWidth-1)
			'DrP_MotionY = LCAR.ScaleValue(X, -50,50,0, DrP_GridHeight-1)
		Case LCAR.Event_Move
			If DrP_DpadRadius > 0 Then 
				If XYLOC.x >= dpadX And XYLOC.y >= dpadY Then Return 
			End If 
			NewXYLOC.X = NewXYLOC.X+X
			NewXYLOC.Y = NewXYLOC.Y+Y		
			If NewXYLOC.X < XYLOC.X - DrP_LastTilesize  Then 
				didMove = DrP_DoAction(ElementID,PdP_MoveLeft)
			else if NewXYLOC.X > XYLOC.X + DrP_LastTilesize Then 
				didMove = DrP_DoAction(ElementID,PdP_MoveRight)
			End If 
			If NewXYLOC.Y > XYLOC.Y + DrP_LastTilesize Then 
				didMove = DrP_DoAction(ElementID,PdP_MoveDown)
			End If  
			If didMove Then 
				XYLOC.X = NewXYLOC.X
				XYLOC.Y = NewXYLOC.Y
				MouseIsMoving=True
			End If
		Case LCAR.Event_Down
			XYLOC = Trig.SetPoint(X,Y)
			If XYLOC.x >= dpadX And XYLOC.y >= dpadY And DrP_DpadRadius > 0 Then 
				Action = LCARSeffects.GetDPADdirection(dpadX, dpadY, DrP_DpadRadius*2,DrP_DpadRadius*2, X,Y)
				'0: out of bounds, 1: south east, 2: south, 3: south west, 4: west, 5: center, 6: east, 7: north east, 8: north, 9: north west
				Select Case Action 
					Case 2: DrP_DoAction(ElementID,PdP_MoveDown)
					Case 4: DrP_DoAction(ElementID,PdP_MoveLeft)
					Case 6: DrP_DoAction(ElementID,PdP_MoveRight)
					Case 8: DrP_DoAction(ElementID, DrP_RotateTiles)
				End Select
				MouseIsMoving=True
				Return  
			End If			
			NewXYLOC = Trig.SetPoint(X,Y)
			MouseIsMoving=False 
		Case LCAR.Event_Up
			If Not(MouseIsMoving) Then DrP_DoAction(ElementID, DrP_RotateTiles)
	End Select
End Sub


Sub DrP_GetTile(X As Int, Y As Int) As DrP_Tile
	Dim temp As DrP_Tile
	If DrP_IsInRange(X,Y) Then temp = DrP_Grid(Y,X)
	Return temp 
End Sub

'Angle: 0/1=virus, 2=ghost, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
Sub DrP_CanMoveTileDown(x As Int, y As Int) As Boolean
	Dim temp As Boolean, Tile As DrP_Tile, Unbind As Boolean ', Tile2 As DrP_Tile
	If DrP_IsInRange(x,y) Then 
	    Tile = DrP_Grid(y, x)
	    If y > 0 And Not(Tile.Viral) And Tile.Ghost = 0 Then
			temp = DrP_IsntOccupied(x, y-1, False)
			If Tile.Bound And temp Then
				Select Case Tile.Angle
					Case 4'PdP_MoveLeft
						temp = DrP_IsntOccupied(x+1,y-1, False)
					Case 5'PdP_MoveRight
						temp = DrP_IsntOccupied(x-1,y-1, False)
					Case 6,7'PdP_MoveDown
						temp = DrP_IsntOccupied(x,y-1, False)
				End Select
			End If
	    End If
	End If 
	Return temp
End Sub

Sub DrP_ShouldUnbind(X As Int, Y As Int, X2 As Int, Y2 As Int) As Boolean 
	Dim Ret As String 
	If Not(DrP_IsInRange(X,Y)) Or Not(DrP_IsInRange(X2,Y2)) Then
		Ret = "out-of-range"
	Else 
		Dim Tile As DrP_Tile = DrP_Grid(y, x), Tile2 As DrP_Tile = DrP_Grid(Y2, X2), Tile3 As DrP_Tile
		If x = X2 And Tile2.Color=0 Then 
			Log("DOUBLE CHECK")
			If Y2 = Y+1 And Y2 < DrP_GridHeight-1 Then 'check one above 
				Tile3=DrP_Grid(Y2+1, X)
				Log("CHECK ABOVE " & Y2 & " " & Tile3)
				If Tile3.Bound And Tile3.Angle = 7 Then Return False
			else if Y2 = y -1 And y > 0 Then 
				Log("CHECK BELOW " & Y  & " " & Tile3)
				Tile3=DrP_Grid(Y-1, X)
				If Tile3.Bound And Tile3.Angle = 6 Then Return False 
			End If 
		End If 
		If Not(Tile.Bound) Or Not(Tile2.Bound) Then Ret = Ret & "not-bound "
		If Tile.Color = 0 Or Tile2.Color = 0 Then Ret = Ret & "color-mismatch "
		If Tile.Viral Or Tile2.Viral Then Ret = Ret & "virals "
		Select Case Tile.Angle 
			Case 4: If Tile2.angle <> 5 Then Ret = Ret & "angle-4(" & Tile2.angle & ")"
			Case 5: If Tile2.angle <> 4 Then Ret = Ret & "angle-5(" & Tile2.angle & ")"
			Case 6: If Tile2.angle <> 7 Then Ret = Ret & "angle-6(" & Tile2.angle & ")"
			Case 7: If Tile2.angle <> 6 Then Ret = Ret & "angle-7(" & Tile2.angle & ")"
		End Select
	End If 
	If Ret.Length>0 Then 
		Log("Checked if " & X & "," & Y & " should unbind with " & X2 & ", " & Y2 & " = " & Ret)
		Return True 
	End If
End Sub

'Angle: 0/1=virus, 2=ghost, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
Sub DrP_Unbind(X As Int, Y As Int, ForceUnbind As Boolean, Reason As String) As Boolean 
	Dim Tile As DrP_Tile = DrP_Grid(y, x), X2 As Int= x, Y2 As Int = y
	If Tile.Bound Then 
		Select Case Tile.Angle
			Case 4:X2=X+1'leftside, pair is right 
			Case 5:X2=X-1'rightside, pair is left
			Case 6:Y2=Y+1'bottomside, pair is up
			Case 7:Y2=Y-1'topside, pair is down
		End Select
		If DrP_IsInRange(X2,Y2) Then 
			Log("CURRENT BIND: " & X2 & ", " & Y2 & " " & ForceUnbind & " - " & Reason)
			If Not(ForceUnbind) Then ForceUnbind = DrP_ShouldUnbind(X,Y, X2, Y2)
			If ForceUnbind Then Return DrP_Unpair(X,Y, "DrP_Unbind 1") And DrP_Unpair(X2,Y2, "DrP_Unbind 2")
		Else 
			Return DrP_Unpair(X,Y, "DrP_Unbind 3")
		End If 
	else if Tile.Angle>3 Then 
		Return DrP_Unpair(X,Y, "DrP_Unbind 4")
	End If
End Sub

Sub DrP_Unpair(X As Int, Y As Int, Reason As String ) As Boolean 
	If DrP_IsInRange(X,Y) Then 
		Log("DrP_Unpair " & X & "," & Y & ": " & Reason)
		Dim Tile As DrP_Tile = DrP_Grid(Y, X)
		Tile.Angle=3
		Tile.Clean=False
		Tile.Bound=False
		Return True 
	End If 
End Sub

'Ghosts a single tile
'Angle: 0/1=virus, 2=ghost, 3=lone pill, 4=leftside, 5=rightside, 6=bottomside, 7=topside
Sub DrP_GhostTile(x As Int, y As Int, Index As Int)
	Dim Tile As DrP_Tile
    If x >= 0 And x < DrP_GridWidth And y >= 0 And y <= DrP_GridHeight Then
		Tile=DrP_Grid(y, x)
        Tile.Clean = False
        Tile.Ghost = DrP_GhostFrames * Index
        If Tile.Bound Then
			Select Case Tile.Angle
				Case 4:	Tile.bX = Tile.bX + 1'leftside, pair is right
				Case 5:	Tile.bX = Tile.bX - 1'rightside, pair is left
				Case 6:	Tile.bY = Tile.bY + 1'bottomside, pair is up
				Case 7:	Tile.bY = Tile.bY - 1'topside, pair is down
			End Select	
			DrP_Unpair(x, y, "DrP_GhostTile 1")
			DrP_Unpair(Tile.bX, Tile.bY, "DrP_GhostTile 2")
            DrP_DropColumn(Tile.bX, Tile.bY)
        End If
		Tile.Angle = 3
    End If
End Sub


Sub DrP_LowestPoint() As Int 
	Dim temp As Int 
	For temp = DrP_CurrentTile.Y-1 To 0 Step -1
		If DrP_Grid(temp, DrP_CurrentTile.X).Color > 0 Then Return temp+1
		Select Case DrP_CurrentTile.Angle
			Case PdP_MoveLeft 
				If DrP_Grid(temp, DrP_CurrentTile.X+1).Color > 0 Then Return temp+1		
			Case PdP_MoveRight 
				If DrP_Grid(temp, DrP_CurrentTile.X-1).Color > 0 Then Return temp+1		
			Case PdP_MoveUp
				If temp>1 Then 
					If DrP_Grid(temp-1, DrP_CurrentTile.X).Color > 0 Then Return temp+1
				End If 
		End Select 
	Next
End Sub

Sub DrP_Borg(ElementID As Int) As Boolean 
	Dim tempX As Int, tempY As Int, Tile As DrP_Tile, Tiles As List, Count As Int, tempP As Point 
	If DrP_VirusCounts(4)>0 And DrP_VirusDifficulty>2 Then 
		Count = Max(1, DrP_VirusCounts(4) * 0.1)
		Tiles.Initialize
		For tempX = 0 To DrP_GridWidth - 1
			For tempY = 0 To DrP_GridHeight - 1
				Tile = DrP_Grid(tempY,tempX)
				If Not(Tile.Viral) And Tile.Color = 4 Then 
					Tiles.Add(Trig.SetPoint(tempX,tempY))
				End If
			Next 
		Next
		If Tiles.Size>0 Then 
			Do Until Count = 0
				tempX = Rnd(0, Tiles.Size)
				tempP = Tiles.Get(tempX)
				DrP_Unbind(tempP.X,tempP.Y, True, "BORG")
				Tile = DrP_Grid(tempP.Y,tempP.X)
				Tile.Color = 4				
				Tile.Angle = 0
				Tile.Clean = False 
				Tile.Viral = True 
				DrP_VirusCounts(4) = DrP_VirusCounts(4) + 1
				DrP_Total = DrP_Total + 1
				DrP_RefreshScoreboard
				DrP_RaiseEvent(ElementID, DrP_Assimilated, 1)
				Count=Count-1
			Loop
		End If 
	End If
End Sub



Sub DrP_DrawScoreboard(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int) 
	Dim Items As List, ColorID As Int = LCAR.LCAR_Orange, SmallItems As List, TileSize As Int = LCAR.ItemHeight - 4, Size As Point, Art As Rect 
	Items.Initialize 
	Items.Add("")
	Items.Add("colorid: " & ColorID)
	Items.Add(API.GetString("tri_level") & ": " & DrP_VirusLevel)
	Items.Add(API.getstring("drp_speed") & ": " & DrP_VirusDifficultyString(DrP_VirusDifficulty))
	Items.Add(API.getstring("drp_virus") & ": " & DrP_Total)
	SmallItems.Initialize
	SmallItems.Add("(colorid: " & ColorID & ")")
	Art = LCARSeffects3.DrawGraphicalElbows(BG,X,Y,Width,Height, ColorID, 255, API.GetString("pdp_score"), "", Items, SmallItems, True)
	DrP_DrawNext(BG, X+ Width*0.5 - TileSize, Y+Height-LCAR.ItemHeight*0.5-TileSize*0.5, TileSize, 4, 255,0)
	'Size = API.Thumbsize(41,64, Art.Width,Art.Height, False, False)
	'LCARSeffects2.DrawBMP(BG, LCARSeffects2.CenterPlatform,    128,0,41,64,       Art.Right-Size.X-5, Art.Bottom - Size.y, Size.X, Size.Y, 255, False, False)
End Sub